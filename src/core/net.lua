-- core/net.lua -- the ONLY transport resolver in the build.
--
-- Allowlist, in full:
--   1. raw.githubusercontent.com/<owner>/dqr/<branch>/...   (loader modules)
--   2. the exact webhookUrl the user typed                  (webhook events)
-- Nothing else may call this module.  HttpService never makes a request here;
-- it is used for JSON only.
--
-- Resolver order (first available wins), per the DQR network policy:
--   1. request                                                         GET + POST
--   2. httpget   (Potassium; alias HttpGet)                            GET only
--   3. syn.request                                                     GET + POST
--   4. fluxus.request, bare http_request, http.request                 GET + POST
--
-- Every call is pcall'ed: a throwing transport reads as network failure, never
-- as an uncaught error and never as empty success.  Success means 2xx AND a
-- non-empty body.
return function(context)
    local net = {
        kind = nil,
        name = nil,
        available = false,
    }

    -- the loader already probed the chain before any module was downloaded;
    -- adopt that exact resolution so the order cannot drift between the two.
    if type(context.netTransport) == "table" and type(context.netTransport.fn) == "function" then
        net.fn = context.netTransport.fn
        net.kind = context.netTransport.kind or "request"
        net.name = context.netTransport.name or "request"
        net.available = true
        context.net = net
    end

    local function globalTable()
        local ok, genv = pcall(function()
            return type(getgenv) == "function" and getgenv() or nil
        end)
        if ok and type(genv) == "table" then
            return genv
        end
        return _G
    end

    local function lookup(name)
        local ok, found = pcall(function()
            local env = globalTable()
            local value = rawget(env, name)
            if value == nil and env ~= _G then
                value = rawget(_G, name)
            end
            return value
        end)
        if not ok then
            return nil
        end
        if type(found) == "function" then
            return found
        end
        return nil
    end

    local function lookupHttpRequest()
        local ok, httpTable = pcall(function()
            local env = globalTable()
            local value = rawget(env, "http")
            if value == nil and env ~= _G then
                value = rawget(_G, "http")
            end
            return value
        end)
        if ok and type(httpTable) == "table" and type(httpTable.request) == "function" then
            return httpTable.request
        end
        return nil
    end

    -- 1. Potassium `request`.
    if not net.fn then
        local fn = lookup("request")
        if fn then
            net.fn, net.kind, net.name = fn, "request", "request"
        end
    end

    -- 2. Potassium `httpget` (GET only, body only).
    if not net.fn then
        local httpget = lookup("httpget") or lookup("HttpGet")
        if httpget then
            net.fn, net.kind, net.name = httpget, "httpget", "httpget"
        end
    end

    -- 3. syn.request
    if not net.fn then
        local ok, synTable = pcall(function()
            local env = globalTable()
            return rawget(env, "syn") or rawget(_G, "syn")
        end)
        if ok and type(synTable) == "table" and type(synTable.request) == "function" then
            net.fn, net.kind, net.name = synTable.request, "request", "syn.request"
        end
    end

    -- 4. last resort globals
    if not net.fn then
        local ok, fluxusTable = pcall(function()
            local env = globalTable()
            return rawget(env, "fluxus") or rawget(_G, "fluxus")
        end)
        if ok and type(fluxusTable) == "table" and type(fluxusTable.request) == "function" then
            net.fn, net.kind, net.name = fluxusTable.request, "request", "fluxus.request"
        else
            local bare = lookup("http_request")
            if bare then
                net.fn, net.kind, net.name = bare, "request", "http_request"
            else
                local http = lookupHttpRequest()
                if http then
                    net.fn, net.kind, net.name = http, "request", "http.request"
                end
            end
        end
    end

    net.available = net.fn ~= nil
    context.net = net

    -- strip endpoint-like strings out of failures before they reach a log line
    local function scrub(message)
        local text = tostring(message or "unknown error")
        return (text:gsub("[%w]+://[^%s\"']+", "<endpoint>"))
    end

    local function invoke(payload)
        if not net.fn then
            return nil, "unavailable (no request function)"
        end
        local ok, response = pcall(net.fn, payload)
        if not ok then
            return nil, scrub(response)
        end
        if type(response) ~= "table" then
            return nil, "malformed response"
        end
        return response
    end

    local function normalise(response)
        local code = response.StatusCode
            or response.status_code
            or (type(response.status) == "table" and response.status.code)
            or (type(response.status) == "number" and response.status)
            or 0
        local body = response.Body
        if body == nil then
            body = response.body
        end
        return tonumber(code) or 0, body, response.Success
    end

    local function backoffOf(response, fallback)
        if type(response) ~= "table" then
            return fallback
        end
        local ok, decoded = pcall(function()
            return context.HttpService:JSONDecode(response.Body or response.body or "{}")
        end)
        if ok and type(decoded) == "table" then
            local retry = tonumber(decoded.retry_after)
            if retry then
                return retry
            end
        end
        return fallback
    end

    -- GET -> body, err
    function net.get(url)
        if type(url) ~= "string" or url == "" then
            return nil, "empty url"
        end
        if not net.fn then
            return nil, "unavailable (no request function)"
        end
        if net.kind == "httpget" then
            local ok, body = pcall(net.fn, url)
            if not ok then
                return nil, scrub(body)
            end
            if type(body) ~= "string" or body == "" then
                return nil, "empty response"
            end
            return body
        end
        local response, err = invoke({ Url = url, Method = "GET" })
        if not response then
            return nil, err
        end
        local code, body, success = normalise(response)
        if success == false then
            return nil, "HTTP transport failure"
        end
        if code < 200 or code >= 300 then
            return nil, ("HTTP %d"):format(code)
        end
        if type(body) ~= "string" or body == "" then
            return nil, "empty response"
        end
        return body
    end

    -- POST JSON -> ok, status, err, retryAfter
    function net.postJson(url, encoded)
        if type(url) ~= "string" or url == "" then
            return false, nil, "empty url"
        end
        if type(encoded) ~= "string" or encoded == "" then
            return false, nil, "empty body"
        end
        if not net.fn then
            return false, nil, "unavailable (no request function)"
        end
        if net.kind == "httpget" then
            return false, nil, "GET only (httpget) - cannot post"
        end
        local response, err = invoke({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = encoded,
        })
        if not response then
            return false, nil, err
        end
        local code, _body, success = normalise(response)
        if success == false then
            return false, code, "HTTP transport failure"
        end
        if code == 429 then
            return false, code, "rate limited", backoffOf(response, 1)
        end
        if code < 200 or code >= 300 then
            return false, code, ("HTTP %d"):format(code)
        end
        return true, code
    end

    function net.describe()
        if not net.fn then
            return "unavailable (no request function)"
        end
        return net.name .. " (" .. net.kind .. ")"
    end
end
