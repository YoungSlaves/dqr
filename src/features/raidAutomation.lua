-- Extracted verbatim from harvardd.lua lines 122927-124003; presentation owned elsewhere.
return function(context)
    local config = context.CFG
    local runtimeState = context.RT
    local sharedValue = getService("Players")
    local sharedValue2 = getService("ReplicatedStorage")
    local sharedValue3 = getService("HttpService")
    local sharedValue4 = getService("TeleportService")
    local localPlayer, sharedValue5 =
        context.LocalPlayer, { Version = "1.1.1", Status = "Off", Alive = true, builtIn = true }
    context.RAID = sharedValue5
    local defaults, cfg =
        {
            enabled = false,
            firstLevel = 130,
            lastLevel = 140,
            fixedTier = 0,
            maxTier = 30,
            advance = true,
            resumeOrbital = true,
            finishDelay = 8,
        }, {}
    for key, default in pairs(defaults) do
        cfg[key] = default
    end
    sharedValue5.cfg = cfg
    sharedValue5.DEFAULTS = defaults
    local state = { party = {}, records = {}, keys = {}, keysKnown = false }
    state.keysAt = -math.huge
    state.actions = {}
    state.busy = {}
    state.lowest = nil
    state.complete = false
    state.participant = false
    state.host = false
    state.rosterKey = ""
    state.route = "waiting"
    state.desired = nil
    state.owned = false
    state.failures = 0
    state.cooldownUntil = 0
    state.finishedAt = nil
    state.nextEligible = false
    state.actual = { accounts = {} }
    sharedValue5.state = state
    local policy = {
        route = function(argument, argument2, argument3, argument4)
            if argument2 then
                if not argument then
                    return "waiting"
                end
            else
                return "waiting"
            end
            if argument >= argument3 then
                if argument < argument4 then
                    return "raid"
                end
            end
            return "dungeon"
        end,
        commonTier = function(argument, argument2, argument3, argument4)
            local value
            for index = 1, argument3, 1 do
                if argument4 == 0 or argument4 == index then
                    local value2 = #argument > 0
                    for index2, entry in ipairs(argument) do
                        index2 = argument2[string.lower(entry.name)]
                        if
                            (if index2 then not index2.keys else not index2)
                            or index2.keys[tostring(index)] ~= true
                        then
                            value2 = false
                            break
                        end
                    end
                    value = if value2 then index else value
                end
            end
            return value
        end,
        canAdvance = function(argument, argument2, argument3, argument4, argument5)
            if #argument == 0 then
                return false
            elseif argument4 >= argument5 then
                return false
            end
            for index, entry in ipairs(argument) do
                argument5 = argument2[string.lower(entry.name)]
                if argument5 then
                    if argument5.job ~= argument3 then
                        return false
                    elseif argument5.tier ~= argument4 then
                        return false
                    elseif argument5.nextEligible ~= true then
                        return false
                    end
                else
                    return false
                end
            end
            return true
        end,
    }
    sharedValue5.Policy = policy
    local function helper(argument)
        return string.lower(tostring(argument or ""))
    end
    local function helper2()
        return os.clock()
    end
    local function helper3(argument)
        if not readfile then
            return nil
        end
        local success, value = pcall(function()
            local value2 = argumentHelpers[108](readfile(argument))
            return sharedValue3:JSONDecode(argumentHelpers:unpackValues(value2))
        end)
        return success and type(value) == "table" and value or nil
    end
    local function helper4(argument, argument2)
        if not writefile then
            return false
        end
        return (
            pcall(function()
                writefile(argument, sharedValue3:JSONEncode(argument2))
            end)
        )
    end
    local function helper5()
        cfg.enabled = cfg.enabled == true
        cfg.firstLevel = math.max(130, math.floor(tonumber(cfg.firstLevel) or 130))
        cfg.lastLevel = math.max(cfg.firstLevel + 1, math.floor(tonumber(cfg.lastLevel) or 140))
        cfg.maxTier = math.clamp(math.floor(tonumber(cfg.maxTier) or 30), 1, 30)
        cfg.fixedTier = math.clamp(math.floor(tonumber(cfg.fixedTier) or 0), 0, cfg.maxTier)
        cfg.finishDelay = math.clamp(tonumber(cfg.finishDelay) or 8, 5, 60)
    end
    local sharedValue6 = false
    local function helper6()
        if sharedValue6 then
            return
        end
        local value = helper3("HarvardLabs/data/bossraid_extension.json")
        if value then
            for default2 in pairs(defaults) do
                if value[default2] ~= nil then
                    cfg[default2] = value[default2]
                end
            end
        end
        helper5()
    end
    sharedValue5.save = function()
        helper5()
        helper4("HarvardLabs/data/bossraid_extension.json", cfg)
    end
    sharedValue5.saveSoon = function()
        helper5()
        if sharedValue6 then
            return
        end
        sharedValue6 = true
        task.delay(0.5, function()
            sharedValue6 = false
            sharedValue5.save()
        end)
    end
    local function helper7(status)
        sharedValue5.Status = status
        if state.owned then
            if context.AF then
                context.AF.status = "boss raids: " .. status
                if context.LB then
                    context.LB.status = "boss raids: " .. status
                end
            end
        end
    end
    local function helper8(argument)
        local remotes = sharedValue2:FindFirstChild("remotes")
        return remotes and (remotes:FindFirstChild(argument))
    end
    local function helper9(argument, argument2, argument3)
        if state.busy[argument] then
            return false
        elseif helper2() - (state.actions[argument] or -math.huge) < argument2 then
            return false
        end
        state.actions[argument], state.busy[argument] = helper2(), true
        task.spawn(function()
            local success, value = pcall(argument3)
            state.busy[argument] = nil
            if not success then
                if sharedValue5.Alive then
                    helper7(argument .. ": " .. tostring(value):sub(1, 180))
                end
            end
        end)
        return true
    end
    local function helper10(argument, argument2)
        local valueObject = argument and (argument:FindFirstChild(argument2))
        return valueObject and valueObject:IsA("ValueBase") and valueObject.Value or nil
    end
    local function helper11(argument)
        for index, entry in ipairs(sharedValue:GetPlayers()) do
            if helper(entry.Name) == helper(argument) then
                return entry
            end
        end
    end
    local function helper12(argument)
        return tonumber(helper10(argument and (argument:FindFirstChild("leaderstats")), "Level"))
    end
    local sharedValue7 = {
        Steampunk = true,
        Steampunk2 = true,
        ["Realm Of The Gods"] = true,
        ["Realm Of The Gods2"] = true,
        ["Mystical Garden"] = true,
        MysticalGarden = true,
        ["Mystical Garden2"] = true,
    }
    local function isRaid()
        return sharedValue7[tostring(helper10(workspace, "dungeonName") or "")] == true
    end
    sharedValue5.isRaid = isRaid
    local function helper13()
        local value = context.LB and context.LB.pm
        if value then
            if type(value.GetPlaceName) == "function" then
                local success, value2 = pcall(value.GetPlaceName)
                if success then
                    if value2 == "Lobby" then
                        return true
                    end
                end
            end
        end
        return game.PlaceId == 77649408247578
    end
    local function helper14()
        if tostring(helper10(workspace, "dungeonProgress")) == "bossKilled" then
            return true
        end
        local dungeon = workspace:FindFirstChild("dungeon")
        return helper10(dungeon, "dungeonFinished") == true
            or helper10(dungeon and dungeon:FindFirstChild("bossRoom"), "dungeonFinished") == true
    end
    local function helper15(argument)
        return "HarvardLabs/data/" .. "bossraid_presence_" .. helper(argument):gsub("[^%w_]", "") .. ".json"
    end
    local function helper16(argument, argument2)
        local value = argument and os.time() - (tonumber(argument.at) or 0)
        return value and value >= -5 and value <= argument2
    end
    sharedValue5.absent = function(argument)
        if helper11(argument) then
            return false
        end
        local partyQueue = context.AF
        if partyQueue then
            if not partyQueue.presence then
                return false
            end
        else
            return false
        end
        local value = partyQueue.presence(argument, 86400)
        if value then
            if tonumber(value.resting) then
                if tonumber(value.resting) > os.time() then
                    return true
                end
            end
        end
        if value then
            if tonumber(value.stuck) then
                if os.time() - tonumber(value.stuck) <= (config.afStuckFresh or 120) then
                    return true
                end
            end
        end
        if partyQueue.presence(argument, config.afOnlineAge or 60) then
            return false
        end
        return not (partyQueue.onItsWay and partyQueue.onItsWay(argument))
    end
    sharedValue5.waitedOut = function(argument)
        local value = helper2()
        if state.rosterWaitSince then
            if value - (state.rosterWaitLast or -math.huge) > 10 then
                state.rosterWaitSince = value
            end
        else
            state.rosterWaitSince = value
        end
        state.rosterWaitLast = value
        local value2 = math.max(tonumber(state.actual and state.actual.waitMax) or 120, 30)
        if value - state.rosterWaitSince < value2 then
            return false
        end
        state.rosterWaitSince, state.cooldownUntil = nil, os.time() + 300
        helper7(
            ("Waited %ds for %s - ordinary dungeons for 5 minutes"):format(
                math.floor(value2),
                tostring(argument)
            )
        )
        if context.log then
            context.log(
                "Boss raids",
                ("waited %ds for %s - ordinary dungeons for 5 minutes"):format(
                    math.floor(value2),
                    tostring(argument)
                )
            )
        end
        return true
    end
    local function helper17()
        local partyQueue = context.AF
        local actual = partyQueue.loadReal and partyQueue.loadReal() or partyQueue.load()
        state.party = {}
        state.records = {}
        state.lowest = nil
        state.participant = false
        state.host = false
        state.complete = true
        state.leader = nil
        state.actual = actual
        local value = {}
        for index, entry in ipairs(actual.accounts or {}) do
            if entry.enabled ~= false then
                if type(entry.name) == "string" then
                    if entry.name ~= "" then
                        index = helper(entry.name) == helper(localPlayer.Name)
                        if index or not sharedValue5.absent(entry.name) then
                            state.party[#state.party + 1] = entry
                        end
                        value[#value + 1] = helper(entry.name) .. ":" .. tostring(entry.role)
                        if index then
                            state.participant = true
                            state.myRole = entry.role
                        end
                    end
                end
            end
        end
        local value2 = partyQueue.carry and partyQueue.carry(actual) or nil
        state.leader = value2 and value2.name or nil
        table.sort(value)
        state.rosterKey = table.concat(value, "|")
        state.host = state.leader ~= nil and helper(state.leader) == helper(localPlayer.Name)
        state.participant = state.participant and actual.on == true and state.leader ~= nil
        for index2, entry2 in ipairs(state.party) do
            value2, index2 = helper11(entry2.name), helper3(helper15(entry2.name))
            if helper16(index2, 30) then
                if index2.roster == state.rosterKey then
                    state.records[helper(entry2.name)] = index2
                else
                    index2 = nil
                end
            else
                index2 = nil
            end
            actual = helper12(value2) or index2 and tonumber(index2.level)
            if not actual then
                if partyQueue then
                    if partyQueue.presence then
                        value = partyQueue.presence(entry2.name, 86400)
                        actual = value and tonumber(value.level) or nil
                    end
                end
            end
            if actual then
                if actual < 1 then
                    state.complete = false
                else
                    state.lowest = math.min(state.lowest or math.huge, actual)
                end
            else
                state.complete = false
            end
        end
        if #state.party == 0 then
            state.complete = false
        end
        state.route = policy.route(state.lowest, state.complete, cfg.firstLevel, cfg.lastLevel)
    end
    local function helper18()
        if not state.participant then
            return
        end
        local value = {
            at = os.time(),
            name = localPlayer.Name,
            level = helper12(localPlayer),
            job = game.JobId,
            place = helper13() and "Lobby" or "Run",
            roster = state.rosterKey,
            tier = tonumber(helper10(workspace, "tier")) or 0,
            keys = state.keysKnown and state.keys or nil,
            ready = helper10(localPlayer, "ready") == true,
            nextEligible = state.nextEligible == true,
        }
        state.records[helper(localPlayer.Name)] = value
        helper4(helper15(localPlayer.Name), value)
    end
    local function helper19()
        if not state.leader then
            return "HarvardLabs/data/bossraid_plan.json"
        end
        return "HarvardLabs/data/" .. "bossraid_plan_" .. helper(state.leader):gsub("[^%w_]", "") .. ".json"
    end
    local function helper20(argument)
        return helper16(argument, 30)
            and argument.roster == state.rosterKey
            and helper(argument.leader) == helper(state.leader)
    end
    local function helper21()
        local plan = helper3(helper19())
        if not state.host then
            state.plan = helper20(plan) and plan or nil
            return
        end
        if helper20(plan) then
            state.cooldownUntil = math.max(state.cooldownUntil, tonumber(plan.cooldownUntil) or 0)
        end
        plan = {
            at = os.time(),
            leader = localPlayer.Name,
            roster = state.rosterKey,
            job = game.JobId,
            place = helper13() and "Lobby" or "Run",
            lowest = state.lowest,
            mode = state.route,
            cooldownUntil = state.cooldownUntil,
        }
        if state.route == "raid" then
            local value = true
            for index, entry in ipairs(state.party) do
                index = state.records[helper(entry.name)]
                value = if index then if type(index.keys) ~= "table" then false else value else false
            end
            if state.cooldownUntil > os.time() then
                plan.mode = "fallback"
                plan.reason = "Raid retry cooldown; ordinary dungeons"
            elseif value then
                plan.tier = policy.commonTier(state.party, state.records, cfg.maxTier, cfg.fixedTier)
                if not plan.tier then
                    plan.mode = "fallback"
                    plan.reason = "No shared unlocked tier; ordinary dungeons"
                end
            else
                plan.mode = "waiting"
                plan.reason = "Waiting for every account's raid key data"
            end
        end
        state.plan = plan
        helper4(helper19(), plan)
    end
    local function wantsControl()
        if not state.participant then
            return false
        end
        if isRaid() then
            return cfg.enabled or state.managedRaid == true
        end
        if not cfg.enabled then
            return false
        end
        local plan = state.plan
        if plan then
            if plan.mode == "fallback" then
                return false
            elseif plan.mode == "dungeon" then
                return false
            end
        end
        if helper13() then
            return state.route == "raid" or state.route == "waiting"
        end
        return helper14() and state.route == "raid" and (if plan then plan.mode ~= "fallback" else not plan)
    end
    sharedValue5.wantsControl = wantsControl
    local function helper22(argument)
        helper9("return to lobby", 25, function()
            if not sharedValue5.Alive then
                return
            end
            local value = helper8("ReturnToLobbyEvent")
            if not value then
                error("ReturnToLobbyEvent is unavailable")
            end
            helper7(argument)
            value:FireServer()
        end)
    end
    local function helper23(argument)
        local bossLobbies = workspace:FindFirstChild("bossLobbies")
        if not bossLobbies then
            return nil
        end
        for index, child in ipairs(bossLobbies:GetChildren()) do
            if helper(child.Name) == helper(argument) then
                return child
            end
        end
    end
    local function helper24(argument, argument2)
        if not argument then
            return false
        end
        for index, child in ipairs(argument:GetChildren()) do
            if helper(child.Name) == helper(argument2) then
                return true
            end
        end
        return false
    end
    local function helper25(argument)
        local value = {}
        for index, entry in ipairs(state.party) do
            if not (helper24(argument, entry.name)) then
                value[#value + 1] = entry.name
            end
        end
        return #value == 0, table.concat(value, ", ")
    end
    local function helper26()
        state.finishedAt = nil
        state.nextEligible = false
        state.replaySentAt = nil
        local plan = state.plan
        if not plan or plan.mode == "waiting" then
            helper7(plan and plan.reason or "Waiting for leader's raid plan")
            return
        end
        if plan.mode ~= "raid" then
            return
        end
        if not state.host then
            if not (helper11(state.leader)) then
                if plan.place == "Lobby" then
                    if plan.job then
                        if plan.job ~= game.JobId then
                            helper9("follow leader", 30, function()
                                if sharedValue5.Alive then
                                    helper7("Following leader to the lobby")
                                    sharedValue4:TeleportToPlaceInstance(
                                        77649408247578,
                                        plan.job,
                                        localPlayer
                                    )
                                end
                            end)
                        else
                            helper7("Waiting for leader to return to the lobby")
                        end
                    else
                        helper7("Waiting for leader to return to the lobby")
                    end
                else
                    helper7("Waiting for leader to return to the lobby")
                end
                return
            end
            local value = helper23(state.leader)
            if not value then
                helper7("Waiting for leader's boss raid lobby")
                return
            end
            if helper24(value:FindFirstChild("players"), localPlayer.Name) then
                helper7("Joined Tier " .. tostring(helper10(value, "tier")) .. "; waiting for party")
                return
            end
            if helper10(value, "private") == true then
                if not (helper24(value:FindFirstChild("whitelist"), localPlayer.Name)) then
                    if not (helper24(value:FindFirstChild("private"), localPlayer.Name)) then
                        helper7("Waiting for raid whitelist")
                        return
                    end
                end
            end
            helper9("join raid", 5, function()
                local value2 = helper8("playerJoinBossLobby")
                if value2 then
                    if sharedValue5.Alive then
                        local value3 = value2:InvokeServer(value)
                        if sharedValue5.Alive then
                            helper7(
                                value3 == true and "Joined boss raid party"
                                    or "Raid join declined; waiting to retry"
                            )
                        end
                    end
                end
            end)
            return
        end
        local value4, value5 = helper25(sharedValue)
        if not value4 then
            if not (sharedValue5.waitedOut(value5)) then
                helper7("Waiting for accounts: " .. value5)
            end
            return
        end
        local value6 = helper23(localPlayer.Name)
        if not value6 then
            helper9("create raid", 15, function()
                local value2 = helper8("createBossLobby")
                if not value2 then
                    error("createBossLobby is unavailable")
                end
                if not sharedValue5.Alive then
                    return
                end
                helper7("Creating private Tier " .. tostring(plan.tier) .. " raid")
                local success, value3 = pcall(value2.InvokeServer, value2, plan.tier, true, 0)
                if not sharedValue5.Alive then
                    return
                end
                if if success then value3 ~= true else not success then
                    state.failures = state.failures + 1
                    helper7("Raid creation declined (" .. state.failures .. "/3)")
                    if state.failures >= 3 then
                        state.cooldownUntil = os.time() + 300
                        state.failures = 0
                    end
                else
                    state.failures = 0
                end
            end)
            return
        end
        for index, entry in ipairs(state.party) do
            if helper(entry.name) ~= helper(localPlayer.Name) then
                if not (helper24(value6:FindFirstChild("whitelist"), entry.name)) then
                    if not (helper24(value6:FindFirstChild("private"), entry.name)) then
                        helper9("whitelist " .. entry.name, 5, function()
                            local value2 = helper8("addPlayerToBossWhitelist")
                            if value2 then
                                if sharedValue5.Alive then
                                    value2:FireServer(entry.name)
                                end
                            end
                        end)
                    end
                end
            end
        end
        value4, value5 = helper25(value6:FindFirstChild("players"))
        if not value4 then
            if not (sharedValue5.waitedOut(value5)) then
                helper7("Raid party waiting for: " .. value5)
            end
            return
        end
        state.rosterWaitSince = nil
        helper9("start raid", 20, function()
            local value2 = helper8("startBossRaid")
            if not value2 then
                error("startBossRaid is unavailable")
            end
            if sharedValue5.Alive then
                value2:FireServer()
                helper7(
                    "Tier " .. tostring(helper10(value6, "tier")) .. " start requested; waiting for teleport"
                )
            end
        end)
    end
    local function helper27()
        local value, value2 = {}, { "dungeonName", "dungeonProgress", "dungeonStarted", "hardcore", "tier" }
        for index, entry in ipairs(value2) do
            value[entry] = helper10(workspace, entry)
        end
        value.isHardcore = value.hardcore
        value2 = workspace:FindFirstChild("dungeon")
        if value2 then
            local iterateArray, value3 = ipairs, { value2, value2:FindFirstChild("bossRoom") }
            for key2, entry2 in iterateArray(value3) do
                for index2, child in ipairs(entry2:GetChildren()) do
                    if child:IsA("ValueBase") then
                        value[child.Name] = child.Value
                    end
                end
            end
        end
        return value
    end
    local function helper28()
        local value = isRaid()
        if value then
            state.managedRaid = true
        end
        if not cfg.enabled then
            helper7("Paused; no raid actions will be sent")
            return
        end
        if value then
            if tostring(helper10(workspace, "dungeonProgress")) == "playersNotReady" then
                if helper10(localPlayer, "ready") ~= true then
                    helper9("ready", 3, function()
                        local value2 = helper8("readyUp")
                        if value2 then
                            if sharedValue5.Alive then
                                helper7("Readying for the boss raid")
                                value2:FireServer()
                            end
                        end
                    end)
                end
            end
        end
        if not (helper14()) then
            state.finishedAt = nil
            state.nextEligible = false
            state.replaySentAt = nil
            if value then
                helper7("Tier " .. tostring(helper10(workspace, "tier")) .. " raid in progress")
            end
            return
        end
        state.finishedAt = state.finishedAt or helper2()
        if helper2() - state.finishedAt < cfg.finishDelay then
            helper7("Run finished; waiting for rewards")
            return
        end
        if context.WH then
            if tonumber(context.WH.pendingUntil) then
                if helper2() < context.WH.pendingUntil then
                    if helper2() - state.finishedAt < 35 then
                        helper7("Waiting for the run report")
                        return
                    end
                end
            end
        end
        if not value then
            if state.plan then
                if state.plan.mode == "raid" then
                    helper22("Run complete; returning for boss raids")
                else
                    helper7("Run complete; waiting for raid plan")
                end
            else
                helper7("Run complete; waiting for raid plan")
            end
            return
        end
        if state.route == "dungeon" then
            helper22("Raid level range completed; returning to ordinary dungeons")
            return
        elseif state.plan then
            if state.plan.mode == "dungeon" then
                helper22("Raid level range completed; returning to ordinary dungeons")
                return
            end
        end
        if state.actual.replay == false then
            helper7("Raid finished; party replay is off")
            return
        end
        if state.replaySentAt then
            if helper2() - state.replaySentAt > 60 then
                helper22("Replay did not restart; regrouping in the lobby")
            end
            return
        end
        if cfg.advance then
            if cfg.fixedTier == 0 then
                helper9("check next tier", 8, function()
                    local value2 = helper8("checkNextTierKey")
                    if value2 then
                        if sharedValue5.Alive then
                            local value3 = value2:InvokeServer()
                            if sharedValue5.Alive then
                                state.nextEligible = type(value3) == "table" and value3.eligible == true
                            end
                        end
                    end
                end)
            end
        end
        if not state.host then
            helper7("Raid complete; waiting for leader's replay")
            return
        end
        local value4, value5 = helper25(sharedValue)
        if not value4 then
            helper22("Regrouping with missing accounts: " .. value5)
            return
        end
        if helper2() - state.finishedAt < cfg.finishDelay + 5 then
            helper7("Checking the party's next-tier eligibility")
            return
        end
        local value6 = tonumber(helper10(workspace, "tier")) or 0
        local value7 = cfg.advance
            and cfg.fixedTier == 0
            and policy.canAdvance(state.party, state.records, game.JobId, value6, cfg.maxTier)
        helper9("replay raid", 60, function()
            local value2 = helper8("replayDungeon")
            if value2 then
                if not sharedValue5.Alive then
                    return
                end
            else
                return
            end
            local value3 = helper27()
            if not value3.dungeonName then
                error("Missing raid replay data")
            end
            if value7 then
                value3.advanceTier = true
            end
            state.replaySentAt = helper2()
            helper7(value7 and "Advancing to Tier " .. value6 + 1 or "Replaying Tier " .. value6)
            value2:FireServer(value3)
        end)
    end
    local lobbyTick = context.lobbyTick
    context.lobbyTick = function(placeAt, ...)
        if sharedValue5.Alive then
            if wantsControl() then
                state.owned = true
                if context.AF then
                    if context.AF.restartWait then
                        context.AF.restartWait()
                    end
                end
                if context.AF then
                    if context.AF.tickAlways then
                        pcall(context.AF.tickAlways, placeAt)
                    end
                end
                if context.LB then
                    context.LB.place = helper13() and "Lobby" or "Level"
                    context.LB.placeAt = placeAt
                end
                if config.autoFarmByPlace then
                    if context.LB then
                        if context.LB.farmAppliedFor ~= context.LB.place then
                            context.LB.farmAppliedFor = context.LB.place
                            runtimeState.farmEnabled = not helper13()
                            if context.setLoopButtonState then
                                pcall(context.setLoopButtonState)
                            end
                        end
                    end
                end
                return
            end
        end
        state.owned = false
        return lobbyTick(placeAt, ...)
    end
    local afRole = context.afRole
    context.afRole = function(...)
        local value = afRole(...)
        if sharedValue5.Alive then
            if cfg.enabled then
                if state.participant then
                    if isRaid() then
                        if value == "carry" then
                            return nil
                        end
                    end
                end
            end
        end
        return value
    end
    local plan2 = context.AF.plan
    context.AF.plan = function(...)
        local value, value2, value3, value4 = plan2(...)
        local value5 = context.AF.loadReal and context.AF.loadReal() or context.AF.load()
        local value6 = value5.hardest or value5.cap
        if sharedValue5.Alive then
            if cfg.enabled then
                if cfg.resumeOrbital then
                    if value5.auto ~= false then
                        if value6 == "Steampunk Sewers" then
                            if state.complete then
                                if state.lowest then
                                    if state.lowest >= cfg.lastLevel then
                                        if state.lowest >= 140 then
                                            local value7, value8, value9 = context.AF.bestFor(
                                                state.lowest,
                                                "Orbital Outpost",
                                                value5.start
                                            )
                                            if value7 then
                                                return value7, value8, value9, state.lowest
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return value, value2, value3, value4
    end
    local function helper29()
        local value = getgenv and getgenv() or _G
        local value2 = rawget(value, "HLBossRaids")
        if value2 ~= nil then
            if value2 ~= sharedValue5 then
                if type(value2) == "table" and value2.builtIn == true then
                    value2.Alive = false
                else
                    if type(value2) == "table" then
                        if type(value2.Destroy) == "function" then
                            pcall(value2.Destroy)
                        end
                    end
                    if helper3("HarvardLabs/data/bossraid_extension.json") == nil then
                        cfg.enabled = true
                        sharedValue5.save()
                    end
                    context.log(
                        "Boss raids",
                        "the separate boss raids script was switched off - they are built in now (Party > Boss raids)"
                    )
                end
            end
        end
        value.HLBossRaids = sharedValue5
    end
    sharedValue5.Destroy = function() end
    sharedValue5.Inspect = function()
        local settings = {}
        for key2, entry in pairs(cfg) do
            settings[key2] = entry
        end
        return {
            version = sharedValue5.Version,
            status = sharedValue5.Status,
            attached = true,
            queueOwned = state.owned,
            route = state.route,
            partyLowest = state.lowest,
            partyComplete = state.complete,
            leader = state.leader,
            host = state.host,
            plan = state.plan,
            settings = settings,
            raid = isRaid(),
            keysKnown = state.keysKnown,
        }
    end
    sharedValue5.tickOnce = function()
        if context.WSC then
            if context.WSC.holding() then
                return
            end
        end
        helper17()
        if state.participant then
            if cfg.enabled and (state.route == "raid" or isRaid()) then
                if helper2() - state.keysAt >= 30 then
                    helper9("read raid keys", 30, function()
                        local keys = helper8("reloadInvy")
                        if not keys then
                            return
                        end
                        local value = keys:InvokeServer()
                        if sharedValue5.Alive then
                            if type(value) ~= "table" then
                                return
                            end
                        else
                            return
                        end
                        keys = {}
                        for key2, entry in pairs(value.keys or {}) do
                            if entry == true then
                                keys[tostring(key2)] = true
                            end
                        end
                        state.keys, state.keysKnown, state.keysAt = keys, true, helper2()
                    end)
                end
            end
            if helper2() - (state.lastPublish or -math.huge) >= 2 then
                state.lastPublish = helper2()
                helper18()
            end
            if helper2() - (state.lastPlan or -math.huge) >= 2 then
                state.lastPlan = helper2()
                helper21()
            end
            state.owned = wantsControl()
            if state.owned then
                if helper13() then
                    local value2, value3 = false
                    if context.MD then
                        if context.MD.lobbyHold then
                            value2, value3 = context.MD.lobbyHold()
                        end
                    end
                    if value2 then
                        helper7(value3 or "mod detection cooldown")
                    else
                        helper26()
                    end
                else
                    helper28()
                end
            elseif cfg.enabled then
                if state.plan and state.plan.mode == "fallback" then
                    helper7(state.plan.reason)
                elseif state.route == "raid" then
                    helper7("Finishing the current dungeon before switching to raids")
                else
                    helper7(
                        "Ordinary dungeons | boss raids at " .. cfg.firstLevel .. "-" .. cfg.lastLevel - 1
                    )
                end
            else
                helper7("Off")
            end
        else
            state.owned = false
            helper7("Turn on party mode and crown a leader in Parties & Runs")
        end
    end
    task.spawn(function()
        local value = { "HarvardLabs", "HarvardLabs/data" }
        for index, entry in ipairs(value) do
            if makefolder then
                pcall(makefolder, entry)
            end
        end
        helper6()
        pcall(helper29)
        task.wait()
        local value2 = -math.huge
        local value3 = helper2()
        local value4 = helper2()
        while sharedValue5.Alive and not runtimeState.destroyed do
            local value5, value6, value7 =
                cfg.enabled or state.managedRaid == true and isRaid(), pcall(function()
                    if helper2() - value3 >= (helper2() - value4 < 120 and 2 or 15) then
                        value3 = helper2()
                        helper29()
                    end
                    if helper2() - value2 >= 2 then
                        value2 = helper2()
                        helper6()
                    end
                    if cfg.enabled or state.managedRaid and isRaid() then
                        sharedValue5.tickOnce()
                    else
                        state.owned = false
                        state.participant = false
                        helper7("Off")
                    end
                    if sharedValue5.onRefresh then
                        pcall(sharedValue5.onRefresh)
                    end
                end)
            if not value6 then
                helper7("error: " .. tostring(value7):sub(1, 180))
            end
            task.wait(value5 and 0.5 or 2)
        end
        sharedValue5.Alive = false
    end)
end
