-- DQR loader -- one short bootstrap: loading card, manifest, cache, gate.
-- No build step, no bundler. Only network peers: raw.githubusercontent.com for
-- these modules, and the exact webhook URL the user typed (inside the build).
local LOADER_VERSION = 2
local OWNER, REPO, BRANCH = "YoungSlaves", "dqr", "main"
local BASE = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(OWNER, REPO, BRANCH)
local MANIFEST_URL = BASE .. "modules.json"
local CACHE_ROOT = "dqr/cache/"
local CACHE_ORDER = CACHE_ROOT .. "order.txt"
local MAX_CACHED = 2

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
while not player do
    task.wait()
    player = Players.LocalPlayer
end

-- single instance: stop a previous copy, keep its destructor until we replace it
if type(_G.DQR_TEARDOWN) == "function" then
    pcall(_G.DQR_TEARDOWN)
end
if type(_G.DungeonAutofarmDestruct) == "function" then
    pcall(_G.DungeonAutofarmDestruct)
end

-- ---------------------------------------------------------------- filesystem
local fs = {}
function fs.read(path)
    if type(readfile) ~= "function" then
        return nil
    end
    local ok, value = pcall(readfile, path)
    if ok and type(value) == "string" then
        return value
    end
    return nil
end
function fs.write(path, text)
    if type(writefile) ~= "function" then
        return false
    end
    return (pcall(writefile, path, text))
end
function fs.exists(path)
    if type(isfile) == "function" then
        local ok, value = pcall(isfile, path)
        return ok and value == true
    end
    return fs.read(path) ~= nil
end
function fs.folder(path)
    if type(makefolder) == "function" then
        pcall(makefolder, path)
    end
end
function fs.list(path)
    if type(listfiles) ~= "function" then
        return {}
    end
    local ok, value = pcall(listfiles, path)
    if ok and type(value) == "table" then
        return value
    end
    return {}
end
function fs.remove(path)
    if type(delfile) == "function" then
        pcall(delfile, path)
    end
end

local function writeAtomic(path, text)
    local temp = path .. ".tmp"
    if not fs.write(temp, text) then
        return false
    end
    local renamed = false
    if os and type(os.rename) == "function" then
        renamed = pcall(os.rename, temp, path)
    end
    if not renamed and not fs.write(path, text) then
        fs.remove(temp)
        return false
    end
    fs.remove(temp)
    return fs.read(path) == text
end

-- ------------------------------------------------------------ transport boot
-- First available wins, in policy order. core/net.lua adopts this result.
local function globalOf(name)
    local ok, value = pcall(function()
        local env = type(getgenv) == "function" and getgenv() or _G
        return rawget(env, name) or rawget(_G, name)
    end)
    if ok and type(value) == "function" then
        return value
    end
    return nil
end

local transport
do
    local fn, name = globalOf("request"), "request"
    if not fn then
        fn, name = globalOf("http_request"), "http_request"
    end
    if not fn then
        local ok, httpTable = pcall(function()
            local env = type(getgenv) == "function" and getgenv() or _G
            return rawget(env, "http") or rawget(_G, "http")
        end)
        if ok and type(httpTable) == "table" and type(httpTable.request) == "function" then
            fn, name = httpTable.request, "http.request"
        end
    end
    if fn then
        transport = { fn = fn, kind = "request", name = name }
    else
        local get = globalOf("httpget") or globalOf("HttpGet")
        if get then
            transport = { fn = get, kind = "httpget", name = "httpget" }
        end
    end
    if not transport then
        local ok, synTable = pcall(function()
            local env = type(getgenv) == "function" and getgenv() or _G
            return rawget(env, "syn") or rawget(_G, "syn")
        end)
        if ok and type(synTable) == "table" and type(synTable.request) == "function" then
            transport = { fn = synTable.request, kind = "request", name = "syn.request" }
        end
    end
    if not transport then
        local ok, fluxusTable = pcall(function()
            local env = type(getgenv) == "function" and getgenv() or _G
            return rawget(env, "fluxus") or rawget(_G, "fluxus")
        end)
        if ok and type(fluxusTable) == "table" and type(fluxusTable.request) == "function" then
            transport = { fn = fluxusTable.request, kind = "request", name = "fluxus.request" }
        end
    end
    if not transport then
        local bare = globalOf("http_request")
        if bare then
            transport = { fn = bare, kind = "request", name = "http_request" }
        end
    end
end

local function fetch(url)
    if not transport then
        return nil, "unavailable (no request function)"
    end
    if transport.kind == "httpget" then
        local ok, body = pcall(transport.fn, url)
        if ok and type(body) == "string" and body ~= "" then
            return body
        end
        return nil, ok and "empty response" or "transport error"
    end
    local ok, response = pcall(transport.fn, { Url = url, Method = "GET" })
    if not ok or type(response) ~= "table" then
        return nil, "transport error"
    end
    local code = tonumber(response.StatusCode or response.status_code or 0) or 0
    local body = response.Body or response.body
    if code < 200 or code >= 300 then
        return nil, ("HTTP %d"):format(code)
    end
    if type(body) ~= "string" or body == "" then
        return nil, "empty response"
    end
    return body
end

-- ------------------------------------------------------------ loading card
local C = {
    forest = Color3.fromHex("0f2a1d"),
    moss = Color3.fromHex("2f5d3a"),
    fern = Color3.fromHex("5b8c3a"),
    leaf = Color3.fromHex("a8c66c"),
    bark = Color3.fromHex("4a3222"),
    wood = Color3.fromHex("7a5230"),
    parchment = Color3.fromHex("efe6c8"),
    firefly = Color3.fromHex("f2d974"),
    warning = Color3.fromHex("e8b84b"),
    danger = Color3.fromHex("cf5b3a"),
}

local function round(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function outline(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    if transparency then
        stroke.Transparency = transparency
    end
    stroke.Parent = parent
    return stroke
end

local function text(parent, value, size, color, transparency)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = value
    label.TextSize = size
    label.TextColor3 = color
    label.TextTransparency = transparency or 0
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Size = UDim2.new(1, 0, 1, 0)
    local ok, face = pcall(function()
        return Font.new("rbxasset://fonts/families/Merriweather.json")
    end)
    if ok and face then
        pcall(function()
            label.FontFace = face
        end)
    else
        label.Font = Enum.Font.SourceSans
    end
    label.Parent = parent
    return label
end

local function guiHost()
    local ok, holder = pcall(function()
        return type(gethui) == "function" and gethui() or nil
    end)
    if ok and holder then
        return holder
    end
    return player:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
end

local cardGui, card, statusLabel, progressFill, barFill, moduleRows, counterLabel
local cardShownAt = os.clock()

local function setStatus(value)
    if statusLabel then
        statusLabel.Text = value
    end
end

local progress = 0
local function setProgress(value)
    if not progressFill then
        return
    end
    value = math.clamp(value, progress, 1)
    progress = value
    TweenService = TweenService or game:GetService("TweenService")
    TweenService:Create(progressFill, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Size = UDim2.fromScale(value, 1) }):Play()
end

local function buildCard(total)
    cardGui = Instance.new("ScreenGui")
    cardGui.Name = "DQRLoading"
    cardGui.DisplayOrder = 50
    cardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    cardGui.IgnoreGuiInset = true
    cardGui.ResetOnSpawn = false
    cardGui.Parent = guiHost()

    card = Instance.new("Frame")
    card.Name = "LoadingCard"
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(340, 168)
    card.BackgroundColor3 = C.forest
    card.BorderSizePixel = 0
    card.Rotation = -0.5
    card.Active = false
    card.Parent = cardGui
    round(card, 10)
    outline(card, C.bark, 3)
    local inset = Instance.new("Frame")
    inset.BackgroundTransparency = 1
    inset.Position = UDim2.fromOffset(2, 2)
    inset.Size = UDim2.new(1, -4, 1, -4)
    inset.Parent = card
    round(inset, 8)
    outline(inset, C.leaf, 1, 0.45)
    for index = 1, 3 do
        local segment = Instance.new("Frame")
        segment.BackgroundColor3 = C.fern
        segment.BackgroundTransparency = 0.25
        segment.BorderSizePixel = 0
        segment.Position = UDim2.fromOffset((index - 1) * (336 / 3 + 1), 0)
        segment.Size = UDim2.fromOffset(336 / 3 - 2, 4)
        segment.Parent = card
        round(segment, 1)
    end

    local sign = Instance.new("Frame")
    sign.BackgroundTransparency = 1
    sign.Position = UDim2.fromOffset(12, 12)
    sign.Size = UDim2.fromOffset(316, 44)
    sign.Parent = card
    local branch = Instance.new("Frame")
    branch.BackgroundColor3 = C.bark
    branch.BorderSizePixel = 0
    branch.Size = UDim2.new(1, 0, 0, 4)
    branch.Parent = sign
    for _, x in ipairs({ 92, 196 }) do
        local rope = Instance.new("Frame")
        rope.BackgroundColor3 = C.bark
        rope.BorderSizePixel = 0
        rope.Position = UDim2.fromOffset(x, 0)
        rope.Size = UDim2.fromOffset(2, 6)
        rope.Parent = sign
    end
    local plank = Instance.new("Frame")
    plank.BackgroundColor3 = C.wood
    plank.BorderSizePixel = 0
    plank.AnchorPoint = Vector2.new(0.5, 0)
    plank.Position = UDim2.new(0.5, 0, 0, 6)
    plank.Size = UDim2.fromOffset(120, 26)
    plank.Rotation = -1
    plank.Parent = sign
    round(plank, 3)
    outline(plank, C.bark, 3)
    local brand = Instance.new("TextLabel")
    brand.BackgroundTransparency = 1
    brand.Size = UDim2.fromScale(1, 1)
    brand.Text = "DQR"
    brand.TextSize = 14
    brand.TextColor3 = C.parchment
    pcall(function()
        brand.FontFace = Font.new("rbxasset://fonts/families/Fondamento.json")
    end)
    brand.Parent = plank
    local pulse = Instance.new("Frame")
    pulse.BackgroundColor3 = C.firefly
    pulse.BorderSizePixel = 0
    pulse.Position = UDim2.fromOffset(300, 16)
    pulse.Size = UDim2.fromOffset(6, 6)
    pulse.Parent = sign
    round(pulse, 3)
    pulse.BackgroundTransparency = 0.4
    game:GetService("TweenService")
        :Create(
            pulse,
            TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { BackgroundTransparency = 1 }
        )
        :Play()

    statusLabel = text(card, "preparing", 11, C.parchment)
    statusLabel.Position = UDim2.fromOffset(12, 58)
    statusLabel.Size = UDim2.fromOffset(316, 14)
    statusLabel.TextTransparency = 0.30

    local track = Instance.new("Frame")
    track.BackgroundColor3 = C.bark
    track.BorderSizePixel = 0
    track.Position = UDim2.fromOffset(12, 76)
    track.Size = UDim2.fromOffset(316, 4)
    track.Parent = card
    round(track, 2)
    progressFill = Instance.new("Frame")
    progressFill.BackgroundColor3 = C.fern
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.fromScale(0, 1)
    progressFill.Parent = track
    round(progressFill, 2)
    barFill = Instance.new("Frame")
    barFill.BackgroundColor3 = C.firefly
    barFill.BorderSizePixel = 0
    barFill.AnchorPoint = Vector2.new(0.5, 0.5)
    barFill.Size = UDim2.fromOffset(8, 8)
    barFill.Position = UDim2.fromScale(0, 0.5)
    barFill.Parent = track
    round(barFill, 4)
    progressFill:GetPropertyChangedSignal("Size"):Connect(function()
        barFill.Position = UDim2.new(progressFill.Size.X.Scale, 0, 0.5, 0)
    end)

    moduleRows = {}
    for index = 1, 3 do
        local row = Instance.new("Frame")
        row.BackgroundTransparency = 1
        row.Position = UDim2.fromOffset(12, 88 + (index - 1) * 14)
        row.Size = UDim2.fromOffset(316, 14)
        row.Parent = card
        local dot = Instance.new("Frame")
        dot.BackgroundColor3 = C.firefly
        dot.BorderSizePixel = 0
        dot.Position = UDim2.fromOffset(0, 4)
        dot.Size = UDim2.fromOffset(6, 6)
        dot.Parent = row
        round(dot, 3)
        local label = text(row, "", 10, C.parchment, 0.5)
        label.Position = UDim2.fromOffset(12, 0)
        label.Size = UDim2.fromOffset(300, 14)
        moduleRows[index] = { row = row, dot = dot, label = label }
    end

    local buildChip = Instance.new("Frame")
    buildChip.BackgroundColor3 = C.bark
    buildChip.BorderSizePixel = 0
    buildChip.AnchorPoint = Vector2.new(0, 1)
    buildChip.Position = UDim2.fromOffset(12, -10)
    buildChip.Size = UDim2.fromOffset(62, 16)
    buildChip.Parent = card
    round(buildChip, 3)
    local buildLabel = text(buildChip, "v" .. tostring(LOADER_VERSION), 10, C.parchment, 0.5)
    buildLabel.TextXAlignment = Enum.TextXAlignment.Center
    counterLabel = text(card, "0/" .. tostring(total or 0) .. " modules", 10, C.parchment, 0.5)
    counterLabel.AnchorPoint = Vector2.new(1, 1)
    counterLabel.Position = UDim2.new(1, -12, 1, -10)
    counterLabel.Size = UDim2.fromOffset(160, 16)
    counterLabel.TextXAlignment = Enum.TextXAlignment.Right
    progress = 0
    setProgress(0)
    cardShownAt = os.clock()
end

local function destroyCard()
    if card then
        pcall(function()
            card:Destroy()
        end)
        card = nil
    end
    if cardGui then
        pcall(function()
            cardGui:Destroy()
        end)
        cardGui = nil
    end
end

local function abort(stage, detail, expected, cachedVersion)
    destroyCard()
    error(
        ("[DQR] abort at %s: %s | expected %s | last valid cached version: %s"):format(
            tostring(stage),
            tostring(detail),
            tostring(expected),
            tostring(cachedVersion or "none")
        ),
        0
    )
end

-- ------------------------------------------------------------------- cache
local function readOrder()
    local order = {}
    local raw = fs.read(CACHE_ORDER)
    if raw then
        for line in raw:gmatch("[^\r\n]+") do
            if line ~= "" then
                order[#order + 1] = line
            end
        end
    end
    return order
end

local function loadCache()
    local order = readOrder()
    for index = #order, 1, -1 do
        local version = order[index]
        local dir = CACHE_ROOT .. version .. "/"
        local manifestText = fs.read(dir .. "modules.json")
        if manifestText then
            local ok, manifest = pcall(HttpService.JSONDecode, HttpService, manifestText)
            if ok and type(manifest) == "table" and manifest.version == version and type(manifest.modules) == "table" then
                local sources, complete = {}, true
                for _, module in ipairs(manifest.modules) do
                    local source = fs.read(dir .. module.name .. ".lua")
                    if not source then
                        complete = false
                        break
                    end
                    sources[module.name] = source
                end
                if complete and #manifest.modules > 0 then
                    return manifest, sources, version
                end
            end
        end
    end
    return nil
end

local function saveCache(manifestText, manifest, sources)
    if type(writefile) ~= "function" then
        return
    end
    local version = manifest.version
    local dir = CACHE_ROOT .. version .. "/"
    fs.folder(CACHE_ROOT)
    fs.folder(dir)
    for _, module in ipairs(manifest.modules) do
        if not writeAtomic(dir .. module.name .. ".lua", sources[module.name] or "") then
            return
        end
    end
    if not writeAtomic(dir .. "modules.json", manifestText) then
        return
    end
    local order = readOrder()
    local kept = {}
    for _, entry in ipairs(order) do
        if entry ~= version then
            kept[#kept + 1] = entry
        end
    end
    kept[#kept + 1] = version
    while #kept > MAX_CACHED do
        local dropped = table.remove(kept, 1)
        if dropped then
            for _, file in ipairs(fs.list(CACHE_ROOT .. dropped .. "/")) do
                fs.remove(file)
            end
        end
    end
    fs.write(CACHE_ORDER, table.concat(kept, "\n"))
end

-- -------------------------------------------------------------------- main
local function main()
    setStatus("preparing")
    buildCard(0)
    setStatus("preparing")

    local manifest, sources, offline, cachedVersion
    local manifestText

    setStatus("fetching manifest")
    for attempt = 1, 2 do
        local url = MANIFEST_URL .. (attempt > 1 and ("?t=" .. tostring(os.time())) or "")
        local body = fetch(url)
        if body then
            local ok, parsed = pcall(HttpService.JSONDecode, HttpService, body)
            if ok and type(parsed) == "table" and type(parsed.modules) == "table" and parsed.version then
                manifest, manifestText = parsed, body
                break
            end
        end
        if attempt == 1 then
            task.wait(0.3)
        end
    end

    if manifest and tonumber(manifest.minLoader or 0) > LOADER_VERSION then
        manifest = nil
    end

    if manifest then
        setStatus("downloading 0/" .. #manifest.modules)
        local total = #manifest.modules
        local base = manifest.basePath or BASE
        local fetched = 0
        local failures = 0
        sources = {}
        for index, module in ipairs(manifest.modules) do
            local url = base .. module.path
            local body = fetch(url)
            if not body then
                body = fetch(url .. (url:find("?", 1, true) and "&" or "?") .. "t=" .. tostring(os.time()))
            end
            if body then
                sources[module.name] = body
                fetched += 1
                setStatus("downloading " .. fetched .. "/" .. total)
                setProgress(0.10 + 0.70 * (fetched / total))
                local rowIndex = ((index - 1) % 3) + 1
                if moduleRows and moduleRows[rowIndex] then
                    moduleRows[rowIndex].label.Text = module.name
                    moduleRows[rowIndex].dot.BackgroundColor3 = C.firefly
                    moduleRows[rowIndex].dot.BackgroundTransparency = 0
                end
                if counterLabel then
                    counterLabel.Text = fetched .. "/" .. total .. " modules"
                end
            else
                failures += 1
                local rowIndex = ((index - 1) % 3) + 1
                if moduleRows and moduleRows[rowIndex] then
                    moduleRows[rowIndex].label.Text = module.name
                    moduleRows[rowIndex].dot.BackgroundColor3 = C.warning
                end
                break
            end
        end
        if failures > 0 then
            manifest, sources = nil, nil
        end
    end

    local usedVersion
    if not manifest then
        setStatus("fetching manifest")
        local ok, cachedManifest, cachedSources, cached = pcall(loadCache)
        if ok and cachedManifest then
            manifest, sources, usedVersion = cachedManifest, cachedSources, cached
            offline = true
            cachedVersion = cached
            if counterLabel then
                counterLabel.Text = "offline · cached v" .. tostring(cached)
            end
        else
            abort("manifest", "no manifest and no complete cache", MANIFEST_URL, nil)
        end
    end

    usedVersion = usedVersion or manifest.version
    if offline and manifest and counterLabel then
        counterLabel.Text = "offline · cached v" .. tostring(manifest.version)
    end

    if counterLabel then
        counterLabel.Text = "0/" .. #manifest.modules .. " modules"
    end

    -- compile gate: every module, before any menu Instance exists
    if type(loadstring) ~= "function" then
        abort("compile", "loadstring unavailable in this executor", "modules.json", nil)
    end
    local total = #manifest.modules
    local compiled = {}
    local compiledCount = 0
    setStatus("compiling 0/" .. total)
    for index, module in ipairs(manifest.modules) do
        local chunk, err = loadstring(sources[module.name] or "", "@dqr/" .. module.path)
        if not chunk then
            if not offline then
                local ok, cachedManifest, cachedSources = pcall(loadCache)
                if ok and cachedManifest then
                    manifest, sources = cachedManifest, cachedSources
                    offline, usedVersion = true, cachedManifest.version
                    compiled, compiledCount = {}, 0
                    setStatus("compiling 0/" .. #manifest.modules)
                    for _, candidate in ipairs(manifest.modules) do
                        local retryChunk = loadstring(sources[candidate.name] or "", "@dqr/" .. candidate.path)
                        if not retryChunk then
                            abort("compile", tostring(candidate.name) .. ": " .. tostring(err), candidate.path, nil)
                        end
                        compiledCount += 1
                        compiled[candidate.name] = retryChunk
                        setStatus("compiling " .. compiledCount .. "/" .. #manifest.modules)
                        setProgress(0.80 + 0.20 * (compiledCount / #manifest.modules))
                    end
                    break
                end
            end
            abort("compile", tostring(module.name) .. ": " .. tostring(err), module.path, nil)
        end
        compiledCount += 1
        compiled[module.name] = chunk
        setStatus("compiling " .. compiledCount .. "/" .. total)
        setProgress(0.80 + 0.20 * (compiledCount / total))
        local rowIndex = ((index - 1) % 3) + 1
        if moduleRows and moduleRows[rowIndex] then
            moduleRows[rowIndex].label.Text = module.name
            moduleRows[rowIndex].dot.BackgroundColor3 = C.leaf
        end
    end

    local remaining = 0.25 - (os.clock() - cardShownAt)
    if remaining > 0 then
        task.wait(remaining)
    end
    setStatus("starting")
    if card then
        pcall(function()
            game:GetService("TweenService")
                :Create(
                    card,
                    TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { BackgroundTransparency = 1 }
                )
                :Play()
        end)
    end
    task.wait(0.12)
    destroyCard()

    local context = {}
    context.netTransport = transport
    context.DQR = { version = usedVersion, loader = LOADER_VERSION, offline = offline == true }
    context.DQR_makeGui = guiHost

    local function environment()
        -- `_G` is a shared-value table, not the standard global environment;
        -- modules still need table/math/string/task/game and friends.
        local fallback = _G
        if type(getfenv) == "function" then
            local ok, env = pcall(getfenv)
            if ok and type(env) == "table" then
                fallback = env
            end
        end
        return setmetatable({
            context = context,
            getService = context.getService,
            argumentHelpers = context.argumentHelpers,
            players = Players,
            player = player,
        }, { __index = fallback })
    end

    for _, module in ipairs(manifest.modules) do
        local chunk = compiled[module.name]
        if type(setfenv) == "function" then
            pcall(setfenv, chunk, environment())
        end
        local ok, err = pcall(chunk, context)
        if ok and type(err) == "function" then
            ok, err = pcall(err, context)
        end
        if not ok then
            pcall(function()
                if context.UI and context.UI.teardown then
                    context.UI.teardown()
                end
            end)
            destroyCard()
            error(("[DQR] abort at run %s: %s | expected %s"):format(module.name, tostring(err), module.path), 0)
        end
    end

    if not offline and manifestText then
        pcall(saveCache, manifestText, manifest, sources)
    end

    local previousDestruct = _G.DungeonAutofarmDestruct
    _G.DQR_TEARDOWN = function()
        if type(previousDestruct) == "function" then
            pcall(previousDestruct)
        end
        pcall(function()
            if context.UI and context.UI.teardown then
                context.UI.teardown()
            end
        end)
        destroyCard()
        _G.DQR_TEARDOWN = nil
    end
    _G.DungeonAutofarmDestruct = function()
        if type(_G.DQR_TEARDOWN) == "function" then
            _G.DQR_TEARDOWN()
        end
    end
    _G.DQR_RELOAD = function()
        if type(_G.DQR_TEARDOWN) == "function" then
            pcall(_G.DQR_TEARDOWN)
        end
        return main()
    end
    return context
end

return main()
