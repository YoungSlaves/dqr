-- Extracted verbatim from harvardd.lua lines 118107-122925; presentation owned elsewhere.
    local config = context.CFG
    local runtimeState = context.RT
    local workspaceService = context.Workspace
    local replicatedStorage = context.ReplicatedStorage
    local localPlayer = context.LocalPlayer
    local log, sharedValue = context.log, { place = nil }
    sharedValue.placeAt = -math.huge
    sharedValue.lastAttempt = -math.huge
    sharedValue.lastStartPress = -math.huge
    sharedValue.attempts = 0
    sharedValue.busy = false
    sharedValue.status = "off"
    local function helper()
        if sharedValue.pm == nil then
            local success, value = pcall(function()
                return require(replicatedStorage.Utility.PlaceManager)
            end)
            sharedValue.pm = success and value or false
        end
        return sharedValue.pm or nil
    end
    context.GS_LOADOUT_DEFAULT = {
        armor = "Gildenscale Warrior Armor",
        helmet = "Gildenscale Warrior Helmet",
        weapon = "Gildenscale Oath And Aegis",
        q = "Enhanced Inner Rage",
        e = "Flame Shuriken",
    }
    context.gsLoadoutMissing = function()
        local value, value2, value3 =
            type(config.gsLoadout) == "table" and config.gsLoadout or context.GS_LOADOUT_DEFAULT,
            {},
            localPlayer:FindFirstChild("PlayerGui")
        local value4 = value3 and (value3:FindFirstChild("MainUI"))
        value3 = value4 and (value4:FindFirstChild("inventoryFrame"))
        local value5 = value3 and (value3:FindFirstChild("Inventory"))
        if not value5 then
            return value2, nil
        end
        value3 = { "armor", "helmet", "weapon" }
        for index, entry in ipairs(value3) do
            index = value[entry]
            if type(index) == "string" and index ~= "" then
                local value6, slot = false
                for index2, child in ipairs(value5:GetChildren()) do
                    local name2, itemType = child:FindFirstChild("name"), child:FindFirstChild("itemType")
                    if child:IsA("GuiButton") then
                        if name2 then
                            if itemType then
                                if name2.Value == index then
                                    if itemType.Value == entry then
                                        index2 = child:FindFirstChild("equip")
                                        value6, slot =
                                            if index2 then if index2.Visible then true else value6 else value6,
                                            slot or child
                                    end
                                end
                            end
                        end
                    end
                end
                if slot then
                    if not value6 then
                        value2[#value2 + 1] = { kind = entry, slot = slot, name = index }
                    end
                end
            end
        end
        value3 = { { "q", "spell1", "qMain" }, { "e", "spell2", "eMain" } }
        for index3, entry2 in ipairs(value3) do
            local name3, slot2 = value[entry2[1]], value4:FindFirstChild(entry2[2])
            index3 = slot2 and (slot2:FindFirstChild("name"))
            if type(name3) == "string" and name3 ~= "" and index3 and index3.Value ~= name3 then
                slot2 = nil
                for index4, child2 in ipairs(value5:GetChildren()) do
                    local name4, itemType2 = child2:FindFirstChild("name"), child2:FindFirstChild("itemType")
                    if child2:IsA("GuiButton") then
                        if name4 then
                            if itemType2 then
                                if name4.Value == name3 then
                                    if itemType2.Value == "spell" then
                                        slot2 = child2
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                if slot2 then
                    value2[#value2 + 1] = { kind = entry2[1], slot = slot2, name = name3, key = entry2[3] }
                end
            end
        end
        return value2, value4
    end
    context.gsLoadoutTick = function(gsEquipAt)
        if game.PlaceId ~= 101088859550383 then
            return
        elseif config.gsAutoEquip == false then
            return
        elseif type(getconnections) ~= "function" then
            return
        end
        if context.gsEquipBusy then
            return
        elseif gsEquipAt - (context.gsEquipAt or -math.huge) < (config.gsEquipEvery or 2) then
            return
        end
        local character = localPlayer.Character
        local humanoid = character and (character:FindFirstChildOfClass("Humanoid"))
        if humanoid then
            if not (humanoid.Health > 0) then
                return
            end
        else
            return
        end
        context.gsEquipAt = gsEquipAt
        local value, value2 = context.gsLoadoutMissing()
        if #value == 0 then
            return
        elseif not value2 then
            return
        end
        context.gsEquipBusy = true
        task.spawn(function()
            local spellSelect = value2:FindFirstChild("spellSelect")
            local value3 = spellSelect ~= nil and spellSelect.Visible
            for index, entry in ipairs(value) do
                pcall(function()
                    for index2, entry2 in ipairs(getconnections(entry.slot.MouseButton1Click)) do
                        task.spawn(function()
                            entry2:Fire()
                        end)
                    end
                end)
                task.wait(0.15)
                if entry.key then
                    if spellSelect then
                        pcall(function()
                            local value4, iterateArray, value5 =
                                spellSelect.Frame.Frame[entry.key], ipairs, getconnections
                            for key, entry2 in iterateArray(value5(value4.TextButton.MouseButton1Click)) do
                                task.spawn(function()
                                    entry2:Fire()
                                end)
                            end
                        end)
                        task.wait(0.15)
                    end
                end
                log("Queue", ("gs-test: equipped %s (%s)"):format(entry.name, entry.kind))
            end
            if spellSelect and not value3 then
                pcall(function()
                    spellSelect.Visible = false
                end)
            end
            context.gsEquipBusy = false
        end)
    end
    local function helper2()
        local value = helper()
        if value then
            if value.GetPlaceName then
                local success, value2 = pcall(value.GetPlaceName)
                if success then
                    if type(value2) == "string" then
                        if value2 ~= "" then
                            return value2
                        end
                    end
                end
            end
        end
        if context.gsShim then
            pcall(context.gsShim)
        end
        value = workspaceService:FindFirstChild("dungeonName")
        return value and value.Value ~= "" and "Level"
            or workspaceService:FindFirstChild("Lobby") and "Lobby"
            or "?"
    end
    local function helper3(status)
        if sharedValue.status ~= status then
            sharedValue.status = status
            if context.refreshQueuePanel then
                context.refreshQueuePanel()
            end
        end
    end
    local function helper4(argument)
        local remotes = replicatedStorage:FindFirstChild("remotes")
        return remotes and (remotes:FindFirstChild(argument))
    end
    local function helper5(argument, argument2)
        local value = (argument2 or workspaceService):FindFirstChild(argument)
        return value and value:IsA("ValueBase") and value or nil
    end
    local function helper6()
        local dungeon = workspaceService:FindFirstChild("dungeon")
        local value = dungeon and (dungeon:FindFirstChild("bossRoom"))
        return value and (helper5("dungeonFinished", value))
    end
    local function helper7()
        if config.replayOnBossKilled == false then
            return false
        end
        local valueObject = helper5("dungeonProgress")
        return valueObject ~= nil and tostring(valueObject.Value) == "bossKilled"
    end
    local function queueNow(reason)
        if context.AF then
            if context.AF.soloQueueBlocked then
                if context.AF.soloQueueBlocked() then
                    helper3("queued by your party")
                    return false
                end
            end
        end
        if context.queueLog then
            context.queueLog(
                "queue",
                { reason = reason, map = config.autoQueueMap, diff = config.autoQueueDifficulty }
            )
        end
        if sharedValue.busy then
            return false
        end
        sharedValue.busy, sharedValue.lastAttempt, sharedValue.attempts =
            true, os.clock(), sharedValue.attempts + 1
        task.spawn(function()
            local success, value = pcall(function()
                local value2, value3 = helper4("createLobby"), helper4("startDungeon")
                if value2 then
                    if not value3 then
                        error("the lobby remotes are not present")
                    end
                else
                    error("the lobby remotes are not present")
                end
                local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
                local value4 = playerGui
                    and playerGui:FindFirstChild("queueGui")
                    and playerGui.queueGui:FindFirstChild("lobbyInfo")
                if value4 then
                    if value4.Visible then
                        helper3("party open; starting")
                        value3:FireServer()
                        return
                    end
                end
                helper3(
                    ("creating %s, %s"):format(
                        tostring(config.autoQueueMap),
                        tostring(config.autoQueueDifficulty)
                    )
                )
                if config.autoQueueMap == "Northern Lands" or config.autoQueueMap == "Gilded Skies" then
                    if config.autoQueueDifficulty ~= "Insane" then
                        if config.autoQueueDifficulty ~= "Nightmare" then
                            config.autoQueueDifficulty = "Nightmare"
                            helper3(
                                ("error: %s only runs on Insane or Nightmare - set to Nightmare"):format(
                                    tostring(config.autoQueueMap)
                                )
                            )
                            log(
                                "Queue",
                                ("%s only runs on Insane or Nightmare; difficulty set to Nightmare"):format(
                                    tostring(config.autoQueueMap)
                                )
                            )
                        end
                    end
                end
                value4 = value2:InvokeServer(
                    config.autoQueueMap,
                    config.autoQueueDifficulty,
                    tonumber(config.autoQueueMinLevel) or 0,
                    config.autoQueueHardcore == true,
                    true,
                    false
                )
                if value4 ~= true then
                    helper3("declined by the game")
                    log("Queue", "declined: " .. tostring(value4))
                    if context.notify then
                        context.notify("warning", "Queue declined", "The game said no: " .. tostring(value4))
                    end
                    return
                end
                task.wait(config.autoQueueStartDelay)
                helper3("starting")
                value3:FireServer()
                log(
                    "Queue",
                    ("queued %s on %s (%s)"):format(
                        tostring(config.autoQueueMap),
                        tostring(config.autoQueueDifficulty),
                        tostring(reason or "auto")
                    )
                )
                if context.notify then
                    context.notify(
                        "party",
                        "Queued",
                        ("%s, %s."):format(
                            tostring(config.autoQueueMap),
                            tostring(config.autoQueueDifficulty)
                        )
                    )
                end
            end)
            if not success then
                helper3("failed; will retry")
                log("Queue", "queueing threw: " .. tostring(value))
            end
            sharedValue.busy = false
        end)
        return true
    end
    local function queueLog(argument, argument2)
        pcall(function()
            local value =
                { k = argument, who = localPlayer.Name, wall = os.time(), job = string.sub(game.JobId, 1, 8) }
            for key, entry in pairs(argument2 or {}) do
                value[key] = type(entry) == "table" and entry or tostring(entry)
            end
            local value2 = getService("HttpService"):JSONEncode(value)
            if runtimeState.bugLog then
                pcall(runtimeState.bugLog, "queue.jsonl", value2)
            end
            if config.devLogs == true then
                appendfile("HarvardLabs/logs/queue.jsonl", value2 .. "\10")
            end
        end)
    end
    context.queueLog = queueLog
    local function replayNow()
        local value = helper4("replayDungeon")
        if not value then
            sharedValue.replayFired, sharedValue.replayAt = true, os.clock()
            helper3("replay: the game's replayDungeon remote is missing")
            log("Queue", "replay not sent: remotes.replayDungeon is missing")
            return false
        end
        local value2, value3 = {}, { "dungeonName", "dungeonProgress", "dungeonStarted", "hardcore" }
        for index, entry in ipairs(value3) do
            index = helper5(entry)
            if index then
                value2[entry] = index.Value
            end
        end
        if value2.hardcore ~= nil then
            value2.isHardcore = value2.hardcore
        end
        local dungeon, iterateArray = workspaceService:FindFirstChild("dungeon"), ipairs
        value3 = { dungeon, dungeon and (dungeon:FindFirstChild("bossRoom")) }
        for key, entry2 in iterateArray(value3) do
            for index2, child in ipairs(entry2:GetChildren()) do
                if child:IsA("ValueBase") then
                    value2[child.Name] = child.Value
                end
            end
        end
        if not value2.dungeonName then
            sharedValue.replayFired, sharedValue.replayAt = true, os.clock()
            helper3("replay: no dungeon name to send")
            log("Queue", "replay not sent: workspace.dungeonName is missing")
            return false
        end
        sharedValue.replayFired, sharedValue.replayAt = true, os.clock()
        do
            local plan
            if context.AF then
                if context.AF.role then
                    if context.AF.role() then
                        pcall(function()
                            plan = context.AF.plan()
                        end)
                    end
                end
            end
            queueLog(
                "replay",
                { dungeon = value2.dungeonName, progress = value2.dungeonProgress, plan = plan, owner = true }
            )
        end
        value:FireServer(value2)
        helper3("replay sent")
        log("Queue", ("replay sent for %s"):format(tostring(value2.dungeonName)))
        if context.notify then
            context.notify("run", "Replaying", tostring(value2.dungeonName) .. " again, same party.")
        end
        return true
    end
    sharedValue.ownerCache = sharedValue.ownerCache or { at = -math.huge }
    local function helper8()
        local ownerCache = sharedValue.ownerCache
        if os.clock() - ownerCache.at >= (config.ownerCacheFor or 1) then
            if not ownerCache.busy then
                ownerCache.busy = true
                task.spawn(function()
                    local value = helper()
                    local value2, value3, value4
                    if value then
                        if type(value.GetPublishedOwnerId) == "function" then
                            pcall(function()
                                value2 = value.GetPublishedOwnerId()
                            end)
                        end
                        if type(value.GetDungeonOwnerId) == "function" then
                            pcall(function()
                                value3 = value.GetDungeonOwnerId()
                            end)
                        end
                        if type(value.IsDungeonOwner) == "function" then
                            local success, value5 = pcall(value.IsDungeonOwner, localPlayer)
                            value4 = if success
                                then if type(value5) == "boolean" then value5 else value4
                                else value4
                        end
                    end
                    ownerCache.pub, ownerCache.dun, ownerCache.isOwn, ownerCache.has =
                        tonumber(value2),
                        tonumber(value3),
                        value4,
                        value ~= nil and type(value.IsDungeonOwner) == "function"
                    ownerCache.at = os.clock()
                    ownerCache.busy = false
                end)
            end
        end
        return ownerCache.pub, ownerCache.dun, ownerCache.isOwn, ownerCache.has
    end
    local function isRunOwner()
        local value, value2, value3, success = helper8()
        if value then
            return value == localPlayer.UserId
        end
        if success then
            if value3 ~= nil then
                if value2 == nil then
                    return true
                end
                return value3
            end
        end
        local value4 = helper()
        success, value = pcall(function()
            return value4.GetPlaceTeleportData()
        end)
        return (if success then type(value) ~= "table" else not success)
            or value.ownerId == nil
            or value.ownerId == localPlayer.UserId
    end
    local function runOwnerId()
        local value, value2 = helper8()
        return value or value2
    end
    context.partyNotHere = function()
        if sharedValue.tdJob ~= game.JobId then
            sharedValue.tdJob = game.JobId
            sharedValue.tdIds = {}
            pcall(function()
                local value = getService("TeleportService"):GetLocalPlayerTeleportData()
                if type(value) == "table" and type(value.playerIds) == "table" then
                    for key, playerId in pairs(value.playerIds) do
                        key = tonumber(playerId)
                        if key then
                            sharedValue.tdIds[#sharedValue.tdIds + 1] = key
                        end
                    end
                end
            end)
        end
        local value2, value3 = {}, getService("Players")
        for index, entry in ipairs(sharedValue.tdIds) do
            if entry ~= localPlayer.UserId then
                if not (value3:GetPlayerByUserId(entry)) then
                    value2[#value2 + 1] = entry
                end
            end
        end
        return value2
    end
    context.GS_PLACE = 101088859550383
    context.GS_LOBBY = 135086580
    context.gsNewRun = function(argument)
        if runtimeState.gsNewRunAt then
            if os.clock() - runtimeState.gsNewRunAt < 8 then
                return
            end
        end
        runtimeState.gsNewRunAt = os.clock()
        local value
        pcall(function()
            value = getService("TeleportService"):GetLocalPlayerTeleportData()
        end)
        log("Queue", "Gilded Skies: a new run (" .. tostring(argument) .. ")")
        if context.notify then
            context.notify("run", "New run", "Gilded Skies: starting a new run.")
        end
        pcall(function()
            local value2, lobby, value3 = getService("TeleportService"), context.GS_LOBBY, { hlGs = "run" }
            value3.Difficulty = context.gsDiff(value)
            value2:Teleport(lobby, localPlayer, value3)
        end)
    end
    context.gsToLobby = function(argument)
        if runtimeState.gsLobbyAt then
            if os.clock() - runtimeState.gsLobbyAt < 8 then
                return
            end
        end
        runtimeState.gsLobbyAt = os.clock()
        log("Queue", "Gilded Skies: to the lobby (" .. tostring(argument) .. ")")
        pcall(function()
            local value, lobby, value2 = getService("TeleportService"), context.GS_LOBBY, { hlGs = "stay" }
            value2.Difficulty = context.gsDiff()
            value:Teleport(lobby, localPlayer, value2)
        end)
    end
    context.gsDiff = function(argument)
        local value = config.gsDifficulty
        if type(value) ~= "string" or value == "" then
            if argument == nil then
                pcall(function()
                    argument = getService("TeleportService"):GetLocalPlayerTeleportData()
                end)
            end
            value = type(argument) == "table" and argument.Difficulty or "Easy"
        end
        value = string.lower(tostring(value))
        local value2 = { "Easy", "Medium", "Hard", "Nightmare" }
        for index, entry in ipairs(value2) do
            if string.lower(entry) == value then
                return entry
            end
        end
        return "Easy"
    end
    context.gsLobbyButton = function()
        local parent = localPlayer:FindFirstChildOfClass("PlayerGui")
        if not parent then
            return
        end
        local hlGsLobby = parent:FindFirstChild("HLGsLobby")
        if hlGsLobby then
            hlGsLobby:Destroy()
        end
        hlGsLobby = Instance.new("ScreenGui")
        hlGsLobby.Name = "HLGsLobby"
        hlGsLobby.ResetOnSpawn = false
        hlGsLobby.DisplayOrder = 50
        hlGsLobby.IgnoreGuiInset = true
        local parent2 = Instance.new("TextButton")
        parent2.AnchorPoint, parent2.Position, parent2.Size =
            Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 8), UDim2.fromOffset(200, 34)
        parent2.BackgroundColor3 = Color3.fromRGB(46, 140, 72)
        parent2.BorderSizePixel = 0
        parent2.AutoButtonColor = true
        parent2.Text, parent2.TextColor3, parent2.Font =
            "START GILDED SKIES", Color3.new(1, 1, 1), Enum.Font.GothamBold
        parent2.TextSize = 14
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = parent2
        local function helper9()
            if sharedValue.gsL then
                sharedValue.gsL.intent = "run"
            end
        end
        parent2.MouseButton1Click:Connect(helper9)
        parent2.Parent = hlGsLobby
        hlGsLobby.Parent = parent
        runtimeState.gsLobbyGui = hlGsLobby
    end
    context.gsReadL = function(argument)
        local value
        pcall(function()
            value = getService("HttpService"):JSONDecode(
                readfile("HarvardLabs/data/gsl_" .. string.lower(argument) .. ".json")
            )
        end)
        if type(value) == "table" then
            if os.time() - (tonumber(value.at) or 0) <= (config.gsLobbyFresh or 10) then
                return value
            end
        end
        return nil
    end
    context.gsLobbyTick = function(argument)
        local value, value2 = sharedValue.gsL
        if value then
            value2 = value
        else
            local value3
            pcall(function()
                value3 = getService("TeleportService"):GetLocalPlayerTeleportData()
            end)
            value = {}
            local value4 = type(value3) == "table" and value3.hlGs or config.gsLobbyAuto == true and "run"
            value.intent = value4 or "stay"
            sharedValue.gsL = value
            value2 = value
        end
        if config.gsRunButtons ~= false then
            if runtimeState.gsLobbyGui then
                if not runtimeState.gsLobbyGui.Parent then
                    pcall(context.gsLobbyButton)
                end
            else
                pcall(context.gsLobbyButton)
            end
        end
        if context.WSC then
            if context.WSC.lobbyArmed then
                if context.WSC.lobbyArmed() then
                    helper3("REMOTE HOLD // standing by for the uplink")
                    return
                end
            end
        end
        if context.MD then
            if context.MD.halted then
                return
            end
        end
        local value5 = string.lower(localPlayer.Name)
        local value6
        pcall(function()
            value6 = context.AF and context.AF.role and context.AF.role()
        end)
        local value7
        if value6 ~= nil then
            pcall(function()
                local value8 = context.AF.carry()
                value7 = value8 and value8.name
            end)
        end
        local value9 = value7 == nil or string.lower(value7) == value5
        if argument - (value2.wroteAt or -math.huge) >= 3 then
            value2.wroteAt = argument
            pcall(function()
                writefile(
                    "HarvardLabs/data/gsl_" .. value5 .. ".json",
                    getService("HttpService"):JSONEncode({
                        job = game.JobId,
                        at = os.time(),
                        intent = value2.intent,
                    })
                )
            end)
        end
        if value2.intent ~= "run" then
            helper3("Gilded Skies lobby: START GILDED SKIES (top) for a new run")
            return
        end
        local value10 = getService("ReplicatedStorage")
        local events = value10:FindFirstChild("Events")
        local dungeons, value11 =
            value10:FindFirstChild("Dungeons"), localPlayer:FindFirstChild("DungeonJoined")
        if events and dungeons then
            if not value11 then
                helper3("Gilded Skies lobby: loading")
                return
            end
        else
            helper3("Gilded Skies lobby: loading")
            return
        end
        value10 = getService("Players")
        if value9 then
            local value12 = dungeons:FindFirstChild(localPlayer.Name)
            if if value12 then value11.Value ~= value12 else not value12 then
                if argument - (value2.createAt or -math.huge) >= (config.gsCreateRetry or 8) then
                    value2.createAt = argument
                    value2.madeAt = nil
                    value2.tpAt = nil
                    local value13 = context.gsDiff()
                    local value14 = config.gsPrivate ~= false
                    pcall(function()
                        events.CreatedLobbyEvent:Fire(value14)
                    end)
                    pcall(function()
                        events.CreateLobby:FireServer("Gilded Skies", value13, value14)
                    end)
                    log(
                        "Queue",
                        ("Gilded Skies lobby: Create Lobby (%s%s)"):format(
                            value13,
                            value14 and ", private" or ""
                        )
                    )
                end
                helper3("Gilded Skies lobby: making the run")
                return
            end
            value2.madeAt = value2.madeAt or argument
            local joinedPlayers, value15, value16 =
                value12:FindFirstChild("JoinedPlayers"), value12:FindFirstChild("WhitelistedPlayers"), 0
            if value6 ~= nil then
                local value17
                pcall(function()
                    value17 = context.AF.load()
                end)
                local iterateArray, value18 = ipairs, type(value17) == "table" and value17.accounts or {}
                for key, entry in iterateArray(value18) do
                    if type(entry) == "table" then
                        if entry.enabled ~= false then
                            if type(entry.name) == "string" then
                                if string.lower(entry.name) ~= value5 then
                                    key = nil
                                    for index, entry2 in ipairs(value10:GetPlayers()) do
                                        if string.lower(entry2.Name) == string.lower(entry.name) then
                                            key = entry2
                                            break
                                        end
                                    end
                                    if key then
                                        value2.wlAt = value2.wlAt or {}
                                        if
                                            value15
                                            and not value15:FindFirstChild(key.Name)
                                            and argument - (value2.wlAt[key.Name] or -math.huge) >= 5
                                        then
                                            value2.wlAt[key.Name] = argument
                                            local name2 = key.Name
                                            task.spawn(function()
                                                pcall(function()
                                                    events.WhitelistPlayer:InvokeServer(name2)
                                                end)
                                            end)
                                        end
                                        value16 = if joinedPlayers
                                            then if joinedPlayers:FindFirstChild(key.Name)
                                                then value16
                                                else value16 + 1
                                            else value16 + 1
                                    else
                                        value12 = context.gsReadL(entry.name)
                                        value16 = if value12
                                            then if value12.intent == "run" then value16 + 1 else value16
                                            else value16
                                    end
                                end
                            end
                        end
                    end
                end
            end
            value15 = argument - value2.madeAt
            if value16 > 0 then
                if value15 < (config.gsLobbyWaitMax or 45) then
                    helper3(
                        ("Gilded Skies lobby: waiting for %d of the party (%.0fs)"):format(
                            value16,
                            (config.gsLobbyWaitMax or 45) - value15
                        )
                    )
                    return
                end
            end
            if value15 < (config.gsLobbyStartDelay or 1) then
                return
            end
            if argument - (value2.tpAt or -math.huge) >= (config.gsTpRetry or 6) then
                value2.tpAt = argument
                pcall(function()
                    events.TPPlayers:FireServer()
                end)
                log("Queue", "Gilded Skies lobby: Start (teleporting the run in)")
            end
            helper3("Gilded Skies lobby: starting the run")
            return
        end
        local value19 = context.gsReadL(value7)
        if not value19 then
            helper3("Gilded Skies lobby: waiting for " .. value7 .. " to reach the lobby")
            return
        end
        if value19.job ~= game.JobId then
            if argument - (value2.hopAt or -math.huge) >= 15 then
                value2.hopAt = argument
                log("Queue", "Gilded Skies lobby: to the host's lobby server")
                pcall(function()
                    local value8, lobby, job, value20 =
                        getService("TeleportService"), context.GS_LOBBY, value19.job, { hlGs = "run" }
                    value20.Difficulty = context.gsDiff()
                    value8:TeleportToPlaceInstance(lobby, job, localPlayer, nil, value20)
                end)
            end
            helper3("Gilded Skies lobby: going to " .. value7 .. "'s server")
            return
        end
        local value21
        value9, value10 = ipairs, argumentHelpers[108](dungeons:GetChildren())
        for key2, entry3 in value9(argumentHelpers:unpackValues(value10)) do
            if string.lower(entry3.Name) == string.lower(value7) then
                value21 = entry3
                break
            end
        end
        if not value21 then
            helper3("Gilded Skies lobby: waiting for " .. value7 .. "'s run")
            return
        end
        if value11.Value == value21 then
            helper3("Gilded Skies lobby: in " .. value7 .. "'s run - waiting for its Start")
            return
        end
        value11, value10 = value21:FindFirstChild("Private"), value21:FindFirstChild("WhitelistedPlayers")
        if value11 then
            if value11.Value == true then
                if not (value10 and value10:FindFirstChild(localPlayer.Name)) then
                    helper3("Gilded Skies lobby: waiting for " .. value7 .. " to let me in")
                    return
                end
            end
        end
        if argument - (value2.joinAt or -math.huge) >= 5 then
            value2.joinAt = argument
            pcall(function()
                events.JoinLobby:Fire(value21)
            end)
            pcall(function()
                events.LobbyOptions:FireServer(1, value21.Name)
            end)
            log("Queue", "Gilded Skies lobby: joining " .. value7 .. "'s run")
        end
        helper3("Gilded Skies lobby: joining " .. value7 .. "'s run")
    end
    context.gsRunButtons = function()
        local parent = localPlayer:FindFirstChildOfClass("PlayerGui")
        if not parent then
            return
        end
        local parent2 = parent:FindFirstChild("HLGsRun")
        if parent2 then
            parent2:Destroy()
        end
        parent2 = Instance.new("ScreenGui")
        parent2.Name = "HLGsRun"
        parent2.ResetOnSpawn = false
        parent2.DisplayOrder = 50
        parent2.IgnoreGuiInset = true
        local parent3 = Instance.new("Frame")
        parent3.AnchorPoint, parent3.Position, parent3.Size =
            Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 8), UDim2.fromOffset(250, 34)
        parent3.BackgroundTransparency = 1
        parent3.Parent = parent2
        local function helper9(text, argument, backgroundColor3, argument2)
            local parent4 = Instance.new("TextButton")
            parent4.Size, parent4.Position = UDim2.fromOffset(120, 34), UDim2.fromOffset(argument, 0)
            parent4.BackgroundColor3 = backgroundColor3
            parent4.BorderSizePixel = 0
            parent4.AutoButtonColor = true
            parent4.Text, parent4.TextColor3, parent4.Font = text, Color3.new(1, 1, 1), Enum.Font.GothamBold
            parent4.TextSize = 14
            backgroundColor3 = Instance.new("UICorner")
            backgroundColor3.CornerRadius = UDim.new(0, 8)
            backgroundColor3.Parent = parent4
            parent4.Parent = parent3
            local function helper10()
                pcall(argument2)
            end
            parent4.MouseButton1Click:Connect(helper10)
        end
        helper9("RESTART RUN", 0, Color3.fromRGB(46, 140, 72), function()
            context.gsNewRun("the RESTART RUN button")
        end)
        helper9("LOBBY", 130, Color3.fromRGB(60, 64, 78), function()
            context.gsToLobby("the LOBBY button")
        end)
        parent2.Parent = parent
        runtimeState.gsRunGui = parent2
    end
    local function lobbyTick(argument)
        local value = sharedValue.place
        if (if value then sharedValue.place == "?" else not value) or argument - sharedValue.placeAt > 5 then
            sharedValue.place = helper2()
            sharedValue.placeAt = argument
        end
        if context.AF then
            pcall(context.AF.tickAlways, argument)
        end
        if context.loadoutTick then
            pcall(context.loadoutTick, argument)
        end
        value = workspaceService:FindFirstChild("dungeonName")
        local farmEnabled = sharedValue.place == "Level"
            or sharedValue.place == "100+"
            or sharedValue.place ~= "Lobby" and value ~= nil and value:IsA("StringValue") and value.Value ~= ""
            or (game.PlaceId == 101088859550383 or HLGSF == true)
        if farmEnabled then
            if context.WSC then
                if context.WSC.lobbyArmed() then
                    value = context.WSC.leaveIn and context.WSC.leaveIn() or 0
                    if value > 0 then
                        helper3(
                            ("REMOTE OVERRIDE // extracting to the lobby in %ds"):format(math.ceil(value))
                        )
                        return
                    end
                    if argument - (sharedValue.remoteLobbyAt or -math.huge) > 15 then
                        if context.MD then
                            if context.MD.goLobby then
                                sharedValue.remoteLobbyAt = argument
                                if context.log then
                                    context.log("Remote", "panel order: leaving the run for the lobby now")
                                end
                                pcall(context.MD.goLobby)
                            end
                        end
                    end
                    helper3("REMOTE OVERRIDE // extracting to the lobby")
                    return
                end
            end
        end
        if game.PlaceId == context.GS_LOBBY then
            if context.gsLobbyTick then
                local success, value2 = pcall(context.gsLobbyTick, argument)
                if not success then
                    helper3("Gilded Skies lobby: error " .. tostring(value2))
                end
                return
            end
        end
        if
            config.autoFarmByPlace
            and sharedValue.place ~= sharedValue.farmAppliedFor
            and (farmEnabled or sharedValue.place == "Lobby")
        then
            sharedValue.farmAppliedFor = sharedValue.place
            if runtimeState.farmEnabled ~= farmEnabled then
                runtimeState.farmEnabled = farmEnabled
                if context.setLoopButtonState then
                    pcall(context.setLoopButtonState)
                end
                if context.notify then
                    context.notify(
                        farmEnabled and "run" or "info",
                        farmEnabled and "Autofarm on" or "Autofarm off",
                        farmEnabled and "In a dungeon - farming."
                            or "In the lobby - it switches back on in the next dungeon."
                    )
                end
            end
        end
        if sharedValue.place == "Lobby" then
            if context.MD then
                if context.MD.lobbyHold then
                    local value3, value4 = context.MD.lobbyHold()
                    if value3 then
                        sharedValue.arrivedAt = nil
                        if context.AF then
                            if context.AF.restartWait then
                                context.AF.restartWait()
                            end
                        end
                        helper3(value4)
                        return
                    end
                end
            end
        end
        if sharedValue.place == "Lobby" then
            if context.WSC then
                if context.WSC.lobbyArmed() then
                    sharedValue.arrivedAt = nil
                    if context.AF then
                        if context.AF.restartWait then
                            context.AF.restartWait()
                        end
                    end
                    helper3("REMOTE HOLD // standing by for the uplink")
                    if not context.WSC.heldSaid then
                        context.WSC.heldSaid = true
                        context.WSC.alert(
                            "Extracted - holding in the lobby",
                            "Standing by for the uplink until the panel releases it.",
                            16705372
                        )
                    end
                    return
                end
            end
        end
        value = false
        do
            local value5
            pcall(function()
                value5 = context.AF and context.AF.role and context.AF.role()
            end)
            value = if value5 ~= nil
                then context.AF.isHost() == true or context.AF.ownRun ~= nil and context.AF.ownRun() == true
                else value
        end
        if game.PlaceId == 101088859550383 then
            if context.gsLoadoutTick then
                pcall(context.gsLoadoutTick, argument)
            end
        end
        if game.PlaceId == 101088859550383 then
            if config.gsRunButtons ~= false then
                if runtimeState.gsRunGui then
                    if not runtimeState.gsRunGui.Parent then
                        pcall(context.gsRunButtons)
                    end
                else
                    pcall(context.gsRunButtons)
                end
            end
            if config.gsAutoRestart ~= false then
                local win, lose =
                    workspaceService:FindFirstChild("win"), workspaceService:FindFirstChild("lose")
                if
                    win and win:IsA("BoolValue") and win.Value
                    or lose and lose:IsA("BoolValue") and lose.Value
                    or context.runFailed and context.runFailed()
                then
                    sharedValue.gsOverAt = sharedValue.gsOverAt or argument
                    local value6 = (config.gsRestartAfter or 6) - (argument - sharedValue.gsOverAt)
                    if value6 > 0 then
                        helper3(("Gilded Skies: the run is over - a new run in %.0fs"):format(value6))
                    else
                        pcall(context.gsNewRun, "the run is over")
                    end
                else
                    sharedValue.gsOverAt = nil
                end
            end
        end
        if
            (game.PlaceId == 101088859550383 or HLGSF == true)
            and config.gsAutoStart ~= false
            and not (context.MD and context.MD.halted)
        then
            local value7
            pcall(function()
                value7 = context.AF and context.AF.role and context.AF.role()
            end)
            local started = workspaceService:FindFirstChild("started")
            if (value7 == nil or value) and started and started:IsA("BoolValue") and not started.Value then
                sharedValue.levelArrivedAt = sharedValue.levelArrivedAt or argument
                local value8 = context.partyNotHere and context.partyNotHere() or {}
                local value9, value10 =
                    #value8 > 0 and argument - sharedValue.levelArrivedAt < (config.startPartyWaitMax or 45),
                    context.RT and context.RT.preWalk
                local value11 = value10 ~= nil and (value10.done == true or value10.pointsDone == true)
                local value12, value13 =
                    value11 or argument - sharedValue.levelArrivedAt >= (config.gsStartAfter or 0), 0
                if config.gsAutoEquip ~= false then
                    if context.gsLoadoutMissing then
                        pcall(function()
                            value13 = #context.gsLoadoutMissing()
                        end)
                    end
                end
                value10 = value13 > 0
                    and argument - sharedValue.levelArrivedAt < (config.gsEquipWaitMax or 30)
                sharedValue.startWhy = value9 and ("waiting for %d of the party to load in"):format(#value8)
                    or (
                        value10 and "equipping the loadout"
                        or (value11 and "walk done" or (value12 and "ready" or "walking"))
                    )
                if
                    (if value9 then not value9 else not value10)
                    and value12
                    and argument - sharedValue.levelArrivedAt >= (config.gsStartDelay or 1)
                    and argument - (sharedValue.lastStartPress or -math.huge) >= (config.gsStartRetry or 12)
                    and not (
                        localPlayer:FindFirstChild("PlayerGui")
                        and localPlayer:FindFirstChild("PlayerGui"):FindFirstChild("countDownGui")
                    )
                then
                    value8 = localPlayer:FindFirstChild("PlayerGui")
                    local value14 = value8 and (value8:FindFirstChild("MainUI"))
                    local value15 = value14 and (value14:FindFirstChild("startButton"))
                    local value16 = value15 and (value15:FindFirstChild("TextButton", true))
                    if value16 and value15.Visible then
                        sharedValue.lastStartPress = argument
                        local value17 = 0
                        pcall(function()
                            if getconnections then
                                local iterateArray, value18 =
                                    ipairs, argumentHelpers[108](getconnections(value16.MouseButton1Click))
                                for key, entry in iterateArray(argumentHelpers:unpackValues(value18)) do
                                    task.spawn(function()
                                        pcall(function()
                                            entry:Fire()
                                        end)
                                    end)
                                    value17 += 1
                                end
                            elseif firesignal then
                                firesignal(value16.MouseButton1Click)
                                value17 = 1
                            end
                        end)
                        log(
                            "Queue",
                            ("gs-test: START pressed (%s, %d click handler(s))"):format(
                                tostring(sharedValue.startWhy),
                                value17
                            )
                        )
                        if context.notify then
                            context.notify("run", "Starting the run", "Gilded Skies: START pressed.")
                        end
                    else
                        sharedValue.startWhy = "no START button on screen"
                    end
                end
            end
        end
        if farmEnabled then
            if value then
                if not (context.MD and context.MD.halted) then
                    if game.PlaceId ~= 101088859550383 then
                        if HLGSF ~= true then
                            sharedValue.levelArrivedAt = sharedValue.levelArrivedAt or argument
                            local valueObject, value19 =
                                helper5("dungeonStarted"), context.RT and context.RT.preWalk
                            local value20, value21, value22, value23 =
                                value19 ~= nil
                                    and (value19.done == true or argument - (value19.at or 0) > 1.5),
                                argument - sharedValue.levelArrivedAt >= (config.autoStartWalkMax or 90),
                                config.startCountdown or 5,
                                context.RT and context.RT.preWalk
                            local value24, value25 =
                                config.startTimed ~= false
                                    and value23 ~= nil
                                    and value23.pointsDone == true
                                    and argument - (value23.at or 0) < 1.5,
                                true
                            if config.startTimed ~= false then
                                value25 = if (context.nextCastIn and context.nextCastIn() or 0)
                                        > value22
                                    then false
                                    else value25
                                if context.buffState then
                                    local value26, A, value27 = context.buffState(argument)
                                    value25 = if value26 == "gap"
                                        then if (value27 or 0) > value22 then false else value25
                                        else value25
                                end
                            end
                            sharedValue.startWhy = value21 and "backstop"
                                or (value24 and "timed" or (value20 and "walk done" or "walking"))
                                    .. (value25 and "" or ", abilities not ready by the countdown")
                            value19 = context.partyNotHere and context.partyNotHere() or {}
                            value22 = #value19 > 0
                                and argument - sharedValue.levelArrivedAt
                                    < (config.startPartyWaitMax or 45)
                            if value22 then
                                sharedValue.startWhy = ("waiting for %d of the party to load in"):format(
                                    #value19
                                )
                            end
                            if not value22 then
                                if context.AF then
                                    if context.AF.allAtStart then
                                        local success2, value28 = pcall(context.AF.allAtStart, argument)
                                        if success2 then
                                            if value28 then
                                                if
                                                    argument - sharedValue.levelArrivedAt
                                                    < (config.startAllMax or 180)
                                                then
                                                    sharedValue.startWhy = ("waiting for %s at the start"):format(
                                                        value28
                                                    )
                                                    value22 = true
                                                else
                                                    if sharedValue.startAllSaid ~= game.JobId then
                                                        sharedValue.startAllSaid = game.JobId
                                                        if context.log then
                                                            context.log(
                                                                "Queue",
                                                                ("starting without %s at the start - waited %ds"):format(
                                                                    value28,
                                                                    config.startAllMax or 180
                                                                )
                                                            )
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            sharedValue.startMissing = #value19
                            if
                                valueObject
                                and not valueObject.Value
                                and not value22
                                and (value21 or (value20 or value24) and value25)
                            then
                                if argument - sharedValue.levelArrivedAt >= config.autoStartDelay then
                                    if argument - sharedValue.lastStartPress >= 10 then
                                        sharedValue.lastStartPress = argument
                                        value23 = helper4("changeStartValue")
                                        if value23 then
                                            pcall(value23.FireServer, value23)
                                            log(
                                                "Queue",
                                                "START pressed (" .. tostring(sharedValue.startWhy) .. ")"
                                            )
                                            if context.notify then
                                                context.notify(
                                                    "run",
                                                    "Starting the run",
                                                    (sharedValue.startMissing or 0) == 0 and "Everyone is in."
                                                        or ("%d of the party never loaded in - starting without them."):format(
                                                            sharedValue.startMissing
                                                        )
                                                )
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
        if farmEnabled then
            value = helper5("bonusBossVotingActive")
            if value and value.Value then
                sharedValue.bonusVoteSeenAt = sharedValue.bonusVoteSeenAt or argument
                local bonusVoted = sharedValue.bonusVoted
                if
                    if bonusVoted
                        then not bonusVoted
                        else argument - sharedValue.bonusVoteSeenAt >= config.bonusVoteDelay
                then
                    sharedValue.bonusVoted = true
                    sharedValue.bonusVoteAt = argument
                    local value29 = helper4("bonusBossPlayerVote")
                    local value30 = config.bonusBoss and "yes" or "no"
                    if value29 then
                        task.spawn(function()
                            pcall(value29.InvokeServer, value29, value30)
                        end)
                        log("Queue", "bonus boss vote: " .. value30)
                    end
                end
            else
                sharedValue.bonusVoteSeenAt = nil
                sharedValue.bonusVoted = false
            end
        end
        value = context.AF and context.AF.role() or nil
        if
            sharedValue.place == "Lobby"
            and value
            and argument - (sharedValue.playPressAt or -math.huge) > 3
        then
            local value31 = localPlayer:FindFirstChild("PlayerGui")
            local value32, value33, value34 = value31 and (value31:FindFirstChild("introGui"))
            if value32 and value32.Enabled ~= false then
                value31 = value32:FindFirstChild("title")
                local value35 = value31 and (value31:FindFirstChild("Frame"))
                value33 = value35 and (value35:FindFirstChildWhichIsA("TextButton"))
                value34 = value33
            else
                value34 = value33
            end
            if value34 and value34.Visible then
                if value34.AbsoluteSize.X > 1 then
                    sharedValue.playPressAt = argument
                    pcall(function()
                        if getconnections then
                            local value18 = { "MouseButton1Click", "Activated", "MouseButton1Down" }
                            for index, entry in ipairs(value18) do
                                for index2, entry2 in ipairs(getconnections(value34[entry])) do
                                    entry2:Fire()
                                end
                            end
                        elseif firesignal then
                            firesignal(value34.MouseButton1Click)
                        end
                    end)
                    helper3("title screen: pressing Play")
                    return
                end
            end
        end
        if sharedValue.place == "Lobby" then
            if context.RD then
                context.RD.resetUsed, context.RD.catchUpUsed = nil, nil
            end
            sharedValue.arrivedAt = sharedValue.arrivedAt or argument
            sharedValue.replayFired = false
            sharedValue.finishedSeenAt = nil
            sharedValue.runOverAt = nil
            sharedValue.rodinPhase = false
            sharedValue.rodinSeenAt = nil
            sharedValue.rodinFinishedAt = nil
            sharedValue.rodinWasAlive = nil
            if value then
                pcall(context.AF.lobbyTick, argument)
                return
            end
            helper3("not in a running party - runs start from a party (Parties & Runs)")
        elseif farmEnabled then
            sharedValue.arrivedAt = nil
            sharedValue.sawLevel = true
            if context.MD then
                if context.MD.halted then
                    return
                end
            end
            local value36 = helper6()
            if config.bonusBoss then
                if context.bonusBossRun then
                    if context.bonusBossRun() then
                        local value37 = helper5("bonusBossStatus")
                        local value38, value39 =
                            if value37 then tostring(value37.Value or "") else "",
                            helper5("bonusBossVotingActive")
                        local value40, value41 =
                            value39 ~= nil and value39.Value == true,
                            context.rodinAlive ~= nil and context.rodinAlive()
                        if value41 then
                            sharedValue.rodinWasAlive = true
                        end
                        value37, value39 =
                            value38 == "success"
                                or sharedValue.rodinWasAlive == true
                                    and not value41
                                    and value38 ~= "active",
                            sharedValue.bonusVoted == true
                                and argument - (sharedValue.bonusVoteAt or 0)
                                    < (config.rodinAfterVote or 150)
                        local value42 = (value40 or value41 or value38 ~= "" or value39) and not value37
                        if value37 then
                            if sharedValue.rodinPhase then
                                sharedValue.rodinPhase = false
                                sharedValue.rodinSeenAt = nil
                            end
                        end
                        if value38:lower():find("fail", 1, true) then
                            sharedValue.rodinPhase = false
                            sharedValue.rodinSeenAt = nil
                            sharedValue.replayFired = false
                            sharedValue.finishedSeenAt = nil
                            helper3("dungeon failed - waiting for the game to send us back to town")
                            return
                        end
                        value37 = value36 and value36.Value or helper7()
                        if not value37 then
                            sharedValue.rodinFinishedAt = nil
                        end
                        if value37 then
                            sharedValue.rodinFinishedAt = sharedValue.rodinFinishedAt or argument
                        end
                        if value42 then
                            sharedValue.rodinPhase = true
                            sharedValue.rodinSeenAt = argument
                        end
                        if sharedValue.rodinPhase then
                            if not value42 then
                                if argument - (sharedValue.rodinSeenAt or 0) > (config.rodinSettle or 45) then
                                    sharedValue.rodinPhase = false
                                end
                            end
                        end
                        value39 = value37
                            and not sharedValue.rodinPhase
                            and argument - (sharedValue.rodinFinishedAt or argument)
                                < (config.rodinVoteWait or 8)
                        if sharedValue.rodinPhase or value39 then
                            sharedValue.replayFired = false
                            sharedValue.finishedSeenAt = nil
                            if value41 then
                                helper3("fighting the bonus boss")
                            elseif sharedValue.rodinPhase then
                                helper3(
                                    "staying for the bonus boss" .. (value38 ~= "" and " - " .. value38 or "")
                                )
                            else
                                helper3(
                                    ("run finished; holding the replay %.0fs for the bonus boss vote"):format(
                                        (config.rodinVoteWait or 8)
                                            - (argument - (sharedValue.rodinFinishedAt or argument))
                                    )
                                )
                            end
                            return
                        end
                    end
                end
            end
            if not (value36 and value36.Value) then
                if not (helper7()) then
                    sharedValue.replayFired = false
                    sharedValue.finishedSeenAt = nil
                    sharedValue.runOverAt = nil
                    helper3("in a run")
                    return
                end
            end
            sharedValue.runOverAt = sharedValue.runOverAt or argument
            if context.MD then
                if context.MD.pendingDrop then
                    helper3("run over - resting after a big drop, to the lobby")
                    return
                end
            end
            if context.MD then
                if context.MD.pendingBreak then
                    helper3("run over - taking a break, to the lobby")
                    return
                end
            end
            value36 = value ~= nil and context.AF.isHost() and context.AF.load().replay ~= false
            if value36 then
                if context.AF.others then
                    local value43 = {}
                    for index3, entry3 in ipairs(getService("Players"):GetPlayers()) do
                        value43[string.lower(entry3.Name)] = true
                    end
                    local value44 = value36
                    for index4, entry4 in ipairs(context.AF.others()) do
                        index4 = context.AF.presence and context.AF.presence(entry4.name, 86400)
                        local value45 = index4 and tonumber(index4.resting)
                        if
                            (
                                value45 and value45 > os.time()
                                or index4
                                    and index4.dropPending
                                    and os.time() - (tonumber(index4.at) or 0) <= 60
                            )
                            and (config.afRestHoldsParty == true or value43[string.lower(entry4.name)])
                        then
                            value44 = false
                            break
                        end
                    end
                    value36 = value44
                end
            end
            value36 = value36
                and (
                    if context.AF.pendingNewSave
                        then if context.AF.pendingNewSave() then false else value36
                        else value36
                )
            if value36 then
                if context.AF.others then
                    local value46 = {}
                    for index5, entry5 in ipairs(getService("Players"):GetPlayers()) do
                        value46[string.lower(entry5.Name)] = true
                    end
                    local value47 = value36
                    for index6, entry6 in ipairs(context.AF.others()) do
                        if not value46[string.lower(entry6.name)] then
                            index6 = context.AF.presence
                                and context.AF.presence(entry6.name, config.afOnlineAge or 60)
                            local value48 = index6 and tonumber(index6.resting)
                            if
                                index6
                                and not (index6 and tonumber(index6.stuck) and os.time() - tonumber(
                                    index6.stuck
                                ) <= (config.afStuckFresh or 120))
                                and not (value48 and value48 > os.time())
                            then
                                value47 = false
                                break
                            end
                        end
                    end
                    value36 = value47
                end
            end
            sharedValue.afMoveOn = nil
            if value36 then
                local success3, value49, value50 = pcall(context.AF.plan)
                local valueObject2 = helper5("dungeonName")
                local value51 = context.WH and context.WH.liveDungeon and context.WH.liveDungeon()
                    or valueObject2 and tostring(valueObject2.Value)
                    or ""
                if success3 then
                    if value49 then
                        if value51 ~= "" then
                            if value49 ~= value51 then
                                sharedValue.afMoveOn = ("%s %s"):format(tostring(value49), tostring(value50))
                                value36 = false
                            end
                        end
                    end
                end
                if value36 and success3 and value50 and context.WH and context.WH.liveDifficulty then
                    local value52 = context.WH.liveDifficulty()
                    local value53 = value52 and value52:gsub(" %(Hardcore%)", "") or nil
                    if not value53 or value53 == "" then
                        pcall(function()
                            local value18 = getService("HttpService"):JSONDecode(
                                readfile(context.AF.partyFile("af_party"))
                            )
                            if value18 then
                                if value18.map == value51 then
                                    value53 = value18.diff
                                end
                            end
                        end)
                    end
                    if value53 and value53 ~= "" then
                        if string.lower(value53) ~= string.lower(tostring(value50)) then
                            sharedValue.afMoveOn = ("%s %s"):format(tostring(value49), tostring(value50))
                            value36 = false
                        end
                    end
                end
            end
            local value54 = false
            if value ~= nil then
                if context.AF.isHost() then
                    local value55 = runOwnerId()
                    if value55 ~= nil then
                        if value55 ~= localPlayer.UserId then
                            local value56, value57 = true, false
                            value36, value54 = value57, value56
                        end
                    end
                end
            end
            sharedValue.sellTrip = nil
            if value ~= nil and not value36 then
                local value58, value59 = context.AF.carry(), false
                if value58 then
                    for index7, entry7 in ipairs(getService("Players"):GetPlayers()) do
                        if string.lower(entry7.Name) == string.lower(value58.name) then
                            value59 = true
                            break
                        end
                    end
                end
                value58 = context.AF.isHost()
                local value60 = value == "carry" and value58 and config.afCarryLeave ~= false
                if
                    value == "party"
                    or value60
                    or value54
                    or sharedValue.sellTrip
                    or (if value58 then not value58 else not value59)
                then
                    if value58 or not value59 then
                        sharedValue.ptLeaveSince = sharedValue.ptLeaveSince or argument
                        local value61 = value58
                                and (value60 and not value54 and not sharedValue.sellTrip and (config.afCarryLeaveAfter or 40) or 15)
                            or 25
                        if argument - sharedValue.ptLeaveSince >= value61 then
                            if argument - (sharedValue.ptLeaveAt or -math.huge) > 15 then
                                if context.MD then
                                    if context.MD.goLobby then
                                        sharedValue.ptLeaveAt = argument
                                        pcall(context.MD.goLobby)
                                    end
                                end
                            end
                        end
                        helper3(
                            (
                                sharedValue.sellTrip and "run over - back to the lobby to sell in %.0fs"
                                or sharedValue.afMoveOn and "run over - the party moves on to " .. sharedValue.afMoveOn .. ": back to the lobby in %.0fs"
                                or "party: run over - back to the lobby to regroup in %.0fs"
                            ):format(
                                math.max(0, value61 - (argument - sharedValue.ptLeaveSince))
                            )
                        )
                    else
                        sharedValue.ptLeaveSince = nil
                    end
                end
                return
            end
            if not value36 then
                if value == nil then
                    if context.MD then
                        if context.MD.goLobby then
                            sharedValue.noPartyLeaveSince = sharedValue.noPartyLeaveSince or argument
                            local value62 = (config.noPartyLeaveAfter or 25)
                                - (argument - sharedValue.noPartyLeaveSince)
                            if value62 <= 0 then
                                if argument - (sharedValue.noPartyLeaveAt or -math.huge) > 15 then
                                    sharedValue.noPartyLeaveAt = argument
                                    pcall(context.MD.goLobby)
                                end
                            end
                            helper3(
                                ("run over - not in a party, back to the lobby in %.0fs"):format(
                                    math.max(0, value62)
                                )
                            )
                        end
                    end
                end
                return
            end
            if context.WH then
                if context.WH.pendingUntil then
                    if os.clock() < context.WH.pendingUntil then
                        helper3(
                            ("run finished; replay waits for the win post (%.0fs max)"):format(
                                context.WH.pendingUntil - os.clock()
                            )
                        )
                        return
                    end
                end
            end
            if sharedValue.replayFired then
                if argument - (sharedValue.replayAt or 0) < (config.autoQueueReplayRetry or 12) then
                    return
                end
            end
            sharedValue.finishedSeenAt = sharedValue.finishedSeenAt or argument
            if not (isRunOwner()) then
                helper3("run finished; the party owner sends the replay")
                return
            end
            value36 = config.autoQueueReplayDelay
            local value63 = (if value ~= nil then math.max(value36, config.afReplaySettle or 5) else value36)
                - (argument - sharedValue.finishedSeenAt)
            if value63 > 0 then
                helper3(("run finished; replay in %.0fs"):format(value63))
            else
                replayNow()
            end
        else
            helper3("off")
        end
    end
    context.LB = sharedValue
    context.lobbyTick = lobbyTick
    context.queueNow = queueNow
    context.replayNow = replayNow
    context.isRunOwner = isRunOwner
    context.runOwnerId = runOwnerId
    local partyQueue = { file = "HarvardLabs/data/altfarm.json", cfg = nil }
    partyQueue.cfgAt = -math.huge
    partyQueue.raw = ""
    partyQueue.lastJoin = -math.huge
    partyQueue.lastHop = -math.huge
    partyQueue.lastCreate = -math.huge
    partyQueue.lastStart = -math.huge
    partyQueue.lastWhite = {}
    partyQueue.lastKick = {}
    partyQueue.hereSince = nil
    partyQueue.lobbySince = nil
    partyQueue.status = "off"
    context.AF = partyQueue
    local sharedValue2 = getService("HttpService")
    local sharedValue3 = getService("Players")
    local function helper11(argument)
        return string.lower(tostring(argument or ""))
    end
    partyQueue.defaults = function()
        return {
            on = false,
            accounts = {},
            map = config.autoQueueMap or "Desert Temple",
            difficulty = config.autoQueueDifficulty or "Nightmare",
            waitMax = 120,
            replay = true,
            auto = true,
            cap = "Steampunk Sewers",
            hardest = "Northern Lands",
            start = "Desert Temple",
        }
    end
    partyQueue.LEVELS = {
        ["Desert Temple"] = { Easy = 1, Medium = 6, Hard = 12, Insane = 20, Nightmare = 27 },
        ["Winter Outpost"] = { Easy = 33, Medium = 40, Hard = 45, Insane = 50, Nightmare = 55 },
        ["Pirate Island"] = { Insane = 60, Nightmare = 65 },
        ["King's Castle"] = { Insane = 70, Nightmare = 75 },
        ["The Underworld"] = { Insane = 80, Nightmare = 85 },
        ["Samurai Palace"] = { Insane = 90, Nightmare = 95 },
        ["The Canals"] = { Insane = 100, Nightmare = 105 },
        ["Ghastly Harbor"] = { Insane = 110, Nightmare = 115 },
        ["Steampunk Sewers"] = { Insane = 120, Nightmare = 125 },
        ["Orbital Outpost"] = { Insane = 140, Nightmare = 145 },
        ["Volcanic Chambers"] = { Insane = 150, Nightmare = 155 },
        ["Aquatic Temple"] = { Insane = 160, Nightmare = 165 },
        ["Enchanted Forest"] = { Insane = 170, Nightmare = 175 },
        ["Northern Lands"] = { Insane = 180, Nightmare = 185 },
        ["Gilded Skies"] = { Insane = 190, Nightmare = 195 },
    }
    partyQueue.EXTRA_DIFFS = {}
    partyQueue.allowedDiffs = function(argument)
        argument = tostring(argument or "")
        local value = context.EVENT_DIFF and context.EVENT_DIFF[argument]
        if value then
            return { [value] = true }
        end
        value = partyQueue.LEVELS[argument]
        if value and next(value) then
            local value2 = {}
            for entry in pairs(value) do
                value2[entry] = true
            end
            return value2
        end
        return partyQueue.EXTRA_DIFFS[argument] or { Insane = true, Nightmare = true }
    end
    partyQueue.validDiff = function(argument, argument2)
        local value = partyQueue.allowedDiffs(argument)
        if argument2 then
            if value[argument2] then
                return argument2
            end
        end
        local value2, value3 =
            context.QUEUE_DIFFICULTIES or { "Easy", "Medium", "Hard", "Insane", "Nightmare" }, 1
        for index, entry in ipairs(value2) do
            value3 = if entry == argument2 then index else value3
        end
        for index2 = value3, #value2, 1 do
            if value[value2[index2]] then
                return value2[index2]
            end
        end
        for index3 = #value2, 1, -1 do
            if value[value2[index3]] then
                return value2[index3]
            end
        end
        return argument2
    end
    partyQueue.refreshLevels = function()
        if partyQueue.levelsLive then
            return
        end
        local value = helper4("getDungeonStats")
        if not value then
            return
        end
        partyQueue.levelsLive = true
        task.spawn(function()
            for level in pairs(partyQueue.LEVELS) do
                local success, value2 = pcall(value.InvokeServer, value, level)
                if success and type(value2) == "table" then
                    local value3, value4 = {}, { "Easy", "Medium", "Hard", "Insane", "Nightmare" }
                    for index, entry in ipairs(value4) do
                        if type(value2[entry]) == "table" then
                            if tonumber(value2[entry].levelReq) then
                                value3[entry] = tonumber(value2[entry].levelReq)
                            end
                        end
                    end
                    if next(value3) then
                        partyQueue.LEVELS[level] = value3
                    end
                end
                task.wait(0.2)
            end
        end)
    end
    partyQueue.bestFor = function(argument, argument2, argument3)
        local value, value2, value3, value4 =
            partyQueue.LEVELS[argument2 or ""], partyQueue.LEVELS[argument3 or ""], math.huge, -math.huge
        if value then
            value3 = 0
            for key, entry in pairs(value) do
                value3 = math.max(value3, entry)
            end
        end
        if value2 then
            value4 = math.huge
            for key2, entry2 in pairs(value2) do
                value4 = math.min(value4, entry2)
            end
        end
        value4 = if value4 > value3 then -math.huge else value4
        local value5, value6, value7 = -1
        for key3, level in pairs(partyQueue.LEVELS) do
            for key4, entry3 in pairs(level) do
                if entry3 <= argument then
                    if entry3 <= value3 then
                        if entry3 >= value4 then
                            if entry3 > value5 then
                                value5, value6, value7 = entry3, key3, key4
                            end
                        end
                    end
                end
            end
        end
        if not value6 then
            if value2 then
                if value4 > -math.huge then
                    argument, value, argument2 = value6, value5, value7
                    for key5, entry4 in pairs(value2) do
                        if argument == nil then
                            argument, value, argument2 = argument3, entry4, key5
                        else
                            if entry4 < value then
                                argument, value, argument2 = argument3, entry4, key5
                            end
                        end
                    end
                    value6, value7, value5 = argument, argument2, value
                end
            end
        end
        return value6, value7, value5
    end
    local function helper12(argument, argument2)
        argument = argument or partyQueue.load()
        local value
        local value2, value3, value4 = false, false
        local value5 = false
        for index, account in ipairs(argument.accounts) do
            if account.enabled ~= false then
                index = sharedValue3:FindFirstChild(account.name)
                if not index then
                    for index2, entry in ipairs(sharedValue3:GetPlayers()) do
                        if helper11(entry.Name) == helper11(account.name) then
                            index = entry
                            break
                        end
                    end
                end
                local value6 = index and (index:FindFirstChild("leaderstats"))
                local value7 = value6 and (value6:FindFirstChild("Level"))
                local value8, value9 =
                    value7 and tonumber(value7.Value) or nil, partyQueue.presence(account.name, 86400)
                value7 = value9 and tonumber(value9.level) or nil
                value8 = if value7
                    then if value8 then if value7 > value8 then value7 else value8 else value7
                    else value8
                if value8 then
                    if value8 > 0 then
                        value7 = math.min(value or math.huge, value8)
                        value = value7
                    else
                        value9 = true
                        value2 = value9
                    end
                else
                    value6 = true
                    value2 = value6
                end
                value7 = index ~= nil
                if not value7 then
                    value9 = partyQueue.presence(account.name, tonumber(config.afPlanAge) or 180)
                    value6 = value9
                        and tonumber(value9.stuck)
                        and os.time() - tonumber(value9.stuck) <= (config.afStuckFresh or 120)
                    value7 = value9 ~= nil
                        and not value6
                        and not (partyQueue.restingNow and partyQueue.restingNow(account.name))
                end
                if value7 then
                    value3 = true
                    if value8 then
                        if value8 > 0 then
                            value9 = math.min(value4 or math.huge, value8)
                            value4 = value9
                        else
                            value6 = true
                            value5 = value6
                        end
                    else
                        local value10 = true
                        value5 = value10
                    end
                end
            end
        end
        if not value3 then
            value4, value5 = value, value2
        end
        if argument.auto ~= false then
            if value4 then
                if not value5 then
                    local value11, value12, value13 =
                        partyQueue.bestFor(value4, argument.hardest, argument.start)
                    if value11 then
                        if not argument2 then
                            partyQueue.lastPlan =
                                { value11, value12, value13, value4, (partyQueue.carry(argument) or {}).name }
                        end
                        return value11, value12, value13, value4
                    end
                end
            end
            if partyQueue.lastPlan then
                if not argument2 then
                    if partyQueue.lastPlan[5] == (partyQueue.carry(argument) or {}).name then
                        return partyQueue.lastPlan[1],
                            partyQueue.lastPlan[2],
                            partyQueue.lastPlan[3],
                            partyQueue.lastPlan[4]
                    end
                end
            end
            if value4 then
                local value14, value15, value16 = partyQueue.bestFor(value4, argument.hardest, argument.start)
                if value14 then
                    return value14, value15, value16, value4
                end
            end
            return "Desert Temple", "Easy", 1, value4
        end
        argument2 = partyQueue.LEVELS[argument.map or ""]
        if context.EVENT_DIFF then
            if context.EVENT_DIFF[argument.map or ""] then
                return argument.map, context.EVENT_DIFF[argument.map], 0, value4
            end
        end
        local value17 = partyQueue.validDiff(argument.map, argument.difficulty)
        return argument.map, value17, argument2 and argument2[value17] or 0, value4
    end
    partyQueue.plan = function()
        local now, planCache = os.clock(), partyQueue.planCache
        if planCache then
            if now - planCache.at < 1 then
                if planCache.raw == partyQueue.raw then
                    return planCache.m, planCache.d, planCache.r, planCache.lo
                end
            end
        end
        local value, value2, value3, value4 = helper12()
        partyQueue.planCache =
            { at = now, raw = partyQueue.raw, m = value, d = value2, r = value3, lo = value4 }
        return value, value2, value3, value4
    end
    partyQueue.planFor = function(argument)
        if argument == nil then
            return partyQueue.plan()
        elseif argument == partyQueue.load() then
            return partyQueue.plan()
        end
        return helper12(argument, true)
    end
    partyQueue.load = function(argument)
        return partyQueue.loadReal(argument)
    end
    partyQueue.soloQueueBlocked = function()
        local value = partyQueue.loadReal(true)
        if not partyQueue.cfg then
            local success, value2 = pcall(isfile, partyQueue.file)
            return success and value2 == true
        end
        local value3 = partyQueue.entry(localPlayer.Name, value)
        return value.on == true and value3 ~= nil and value3.enabled ~= false
    end
    context.queuePick = function()
        local value
        pcall(function()
            value = partyQueue.role()
        end)
        if value ~= nil then
            local success, value2, value3 = pcall(partyQueue.plan)
            if success then
                if value2 then
                    return value2, value3, false
                end
            end
        end
        return config.autoQueueMap, config.autoQueueDifficulty, config.autoQueueHardcore == true
    end
    local function helper13(argument, argument2)
        local value = helper11(argument2)
        for index, account in ipairs(argument.accounts) do
            if type(account) == "table" then
                if helper11(account.name) == value then
                    return account
                end
            end
        end
        return nil
    end
    partyQueue.migrate = function(argument)
        if argument.v == 2 then
            return false
        end
        local value
        for index, account in ipairs(argument.accounts) do
            if type(account) == "table" then
                if account.role == "carry" then
                    value = value or (if account.enabled ~= false then account else value)
                    account.role = "fight"
                else
                    if account.role ~= "leech" then
                        if account.role ~= "fight" then
                            if account.role ~= "leader" then
                                account.role = "leech"
                            end
                        end
                    end
                end
            end
        end
        local success, value2 = pcall(function()
            local value3 = argumentHelpers[108](readfile("HarvardLabs/data/party.json"))
            return sharedValue2:JSONDecode(argumentHelpers:unpackValues(value3))
        end)
        if success then
            if type(value2) == "table" then
                if type(value2.members) == "table" then
                    for index2, member in ipairs(value2.members) do
                        if type(member) == "table" then
                            if member.name then
                                if not (helper13(argument, member.name)) then
                                    argument.accounts[#argument.accounts + 1] = {
                                        name = tostring(member.name),
                                        role = "fight",
                                        enabled = member.enabled ~= false,
                                    }
                                end
                            end
                        end
                    end
                    value = value
                        or (
                            if tostring(value2.leader or "") ~= ""
                                then helper13(argument, value2.leader)
                                else value
                        )
                    if value2.on == true then
                        argument.on = true
                    end
                end
            end
        end
        if not value then
            for index3, account2 in ipairs(argument.accounts) do
                if type(account2) == "table" then
                    if account2.role == "fight" then
                        if account2.enabled ~= false then
                            value = account2
                            break
                        end
                    end
                end
            end
        end
        if value then
            value.role = "leader"
        end
        argument.v = 2
        return true
    end
    partyQueue.partyOf = function(argument, argument2)
        local value, parties = helper11(argument), (argument2 or partyQueue.doc or {}).parties
        for index, entry in ipairs(type(parties) == "table" and parties or {}) do
            for index2, entry2 in ipairs(entry.accounts or {}) do
                if type(entry2) == "table" then
                    if helper11(entry2.name) == value then
                        return entry, index
                    end
                end
            end
        end
        return nil
    end
    local function helper14()
        local success, value = pcall(function()
            return sharedValue2:GenerateGUID(false)
        end)
        return success and type(value) == "string" and value
            or "p" .. tostring(os.time()) .. tostring(math.random(100000, 999999))
    end
    local function helper15()
        local value = partyQueue.partyOf(localPlayer.Name, partyQueue.doc)
        if value then
            return value
        end
        partyQueue.outside = partyQueue.outside or partyQueue.defaults()
        return partyQueue.outside
    end
    partyQueue.loadReal = function(argument)
        local cfgAt = os.clock()
        if not argument then
            if partyQueue.cfg then
                if cfgAt - partyQueue.cfgAt < 1.5 then
                    return partyQueue.cfg
                end
            end
        end
        if not argument then
            if not partyQueue.cfg then
                if partyQueue.noList then
                    if cfgAt - partyQueue.cfgAt < 1.5 then
                        return partyQueue.noList
                    end
                end
            end
        end
        partyQueue.cfgAt = cfgAt
        local success, raw = pcall(readfile, partyQueue.file)
        if success and type(raw) == "string" and raw ~= "" then
            if raw ~= partyQueue.raw or not partyQueue.doc then
                local success2, value = pcall(function()
                    local raw2 = raw
                    return sharedValue2:JSONDecode(raw2)
                end)
                local doc
                if success2 and type(value) == "table" then
                    argument = false
                    if type(value.parties) ~= "table" then
                        value = { v = 2, parties = { value } }
                        doc, argument = value, true
                    else
                        doc = value
                    end
                    for index = #doc.parties, 1, -1 do
                        cfgAt = doc.parties[index]
                        if type(cfgAt) ~= "table" then
                            table.remove(doc.parties, index)
                            argument = true
                        else
                            for key, entry in pairs((partyQueue.defaults())) do
                                if cfgAt[key] == nil then
                                    cfgAt[key] = entry
                                end
                            end
                            if type(cfgAt.accounts) ~= "table" then
                                cfgAt.accounts = {}
                            end
                            argument = if partyQueue.migrate(cfgAt) then true else argument
                            if type(cfgAt.id) ~= "string" or cfgAt.id == "" then
                                cfgAt.id = helper14()
                                argument = true
                            end
                        end
                    end
                    if doc.v ~= 2 then
                        doc.v = 2
                        argument = true
                    end
                    if argument then
                        pcall(function()
                            local value2 = sharedValue2:JSONEncode(doc)
                            writefile(partyQueue.file, value2)
                            raw = value2
                        end)
                    end
                    partyQueue.doc = doc
                    partyQueue.raw = raw
                else
                    doc = value
                end
            end
        end
        if partyQueue.doc then
            partyQueue.cfg = helper15()
            return partyQueue.cfg
        end
        argument = partyQueue.defaults()
        if partyQueue.migrate(argument) then
            if #argument.accounts > 0 then
                argument.id = helper14()
                partyQueue.doc = { v = 2, parties = { argument } }
                pcall(function()
                    local raw2 = sharedValue2:JSONEncode(partyQueue.doc)
                    writefile(partyQueue.file, raw2)
                    partyQueue.raw = raw2
                end)
                partyQueue.cfg = argument
                return argument
            end
        end
        partyQueue.noList = argument
        return argument
    end
    partyQueue.save = function()
        local value = partyQueue.loadReal()
        if not partyQueue.doc then
            if type(value.id) ~= "string" then
                value.id = helper14()
            end
            partyQueue.doc = { v = 2, parties = { value } }
        end
        local success, raw = pcall(function()
            local doc = partyQueue.doc
            return sharedValue2:JSONEncode(doc)
        end)
        if success then
            pcall(writefile, partyQueue.file, raw)
            partyQueue.raw = raw
        end
        partyQueue.cfg = helper15()
        partyQueue.cfgAt = os.clock()
    end
    partyQueue.parties = function(argument)
        partyQueue.loadReal(argument)
        return partyQueue.doc and partyQueue.doc.parties or {}
    end
    partyQueue.editParty = function(parties)
        partyQueue.loadReal(parties)
        if not partyQueue.doc then
            partyQueue.doc = { v = 2, parties = {} }
        end
        parties = partyQueue.doc.parties
        if #parties == 0 then
            local value = partyQueue.defaults()
            value.v, value.id = 2, helper14()
            parties[1] = value
        end
        local editIdx
        if partyQueue.editId then
            for index, partie in ipairs(parties) do
                if partie.id == partyQueue.editId then
                    editIdx = index
                    break
                end
            end
        end
        if not editIdx then
            local p, value2 = partyQueue.partyOf(localPlayer.Name, partyQueue.doc)
            editIdx = value2 or 1
        end
        partyQueue.editIdx, partyQueue.editId = editIdx, parties[editIdx].id
        return parties[editIdx], editIdx
    end
    partyQueue.pickParty = function(argument)
        local value = partyQueue.parties()
        if value[argument] then
            partyQueue.editId = value[argument].id
        end
    end
    partyQueue.newParty = function()
        partyQueue.editParty(true)
        local parties, value = partyQueue.doc.parties, partyQueue.defaults()
        value.v, value.id = 2, helper14()
        parties[#parties + 1] = value
        partyQueue.editId = value.id
        partyQueue.save()
        return value, #parties
    end
    partyQueue.soloParty = function(argument)
        partyQueue.loadReal(true)
        if not partyQueue.doc then
            partyQueue.doc = { v = 2, parties = {} }
        end
        local value, value2 = partyQueue.partyOf(localPlayer.Name, partyQueue.doc)
        if value then
            return nil, ("in Party %d already"):format(value2 or 0)
        end
        value, value2 = partyQueue.doc.parties
        for index, entry in ipairs(value) do
            if type(entry.accounts) ~= "table" then
                value2 = entry
                break
            elseif #entry.accounts == 0 then
                value2 = entry
                break
            end
        end
        if not value2 then
            value2 = partyQueue.defaults()
            value2.v, value2.id = 2, helper14()
            value[#value + 1] = value2
        end
        value2.accounts = { { name = localPlayer.Name, role = "leader", enabled = true } }
        value2.on = false
        if type(argument) == "table" then
            for key, entry2 in pairs(argument) do
                value2[key] = entry2
            end
        end
        partyQueue.editId = value2.id
        partyQueue.save()
        return value2
    end
    partyQueue.deleteParty = function(argument)
        partyQueue.editParty(true)
        local parties = partyQueue.doc.parties
        for index, partie in ipairs(parties) do
            if partie.id == argument then
                table.remove(parties, index)
                break
            end
        end
        partyQueue.editId = nil
        partyQueue.save()
    end
    partyQueue.partyFile = function(argument)
        local value = partyQueue.carry()
        return "HarvardLabs/data/"
            .. argument
            .. (value and "_" .. helper11(value.name):gsub("[^%w_]", "") or "")
            .. ".json"
    end
    partyQueue.entry = function(argument, argument2)
        local value = helper11(argument)
        for index, account in ipairs((argument2 or partyQueue.load()).accounts) do
            if helper11(account.name) == value then
                return account, index
            end
        end
        return nil
    end
    partyQueue.entryReal = function(argument)
        return partyQueue.entry(argument)
    end
    partyQueue.levelling = function(argument)
        for index, account in ipairs((argument or partyQueue.load()).accounts) do
            if account.enabled ~= false then
                if account.role == "leech" then
                    return true
                end
            end
        end
        return false
    end
    partyQueue.role = function()
        local value = partyQueue.load()
        if value.on ~= true then
            return nil
        end
        local value2 = partyQueue.entry(localPlayer.Name, value)
        if value2 then
            if value2.enabled == false then
                return nil
            end
        else
            return nil
        end
        if value2.role == "leech" then
            return "leech"
        end
        return partyQueue.levelling(value) and "carry" or "party"
    end
    partyQueue.crowned = function(argument)
        local accounts = (argument or partyQueue.load()).accounts
        for index, account in ipairs(accounts) do
            if account.enabled ~= false then
                if account.role == "leader" then
                    return account
                end
            end
        end
        for index2, account2 in ipairs(accounts) do
            if account2.enabled ~= false then
                if account2.role == "fight" then
                    return account2
                elseif account2.role == "carry" then
                    return account2
                end
            end
        end
        return nil
    end
    partyQueue.restingNow = function(argument)
        local value = partyQueue.presence and partyQueue.presence(argument, 86400)
        argument = value and tonumber(value.resting)
        return argument ~= nil and argument > os.time()
    end
    partyQueue.carry = function(argument)
        local value = partyQueue.crowned(argument)
        if value then
            if config.afRestStandIn == false then
                return value
            elseif not (partyQueue.restingNow(value.name)) then
                return value
            end
        else
            return value
        end
        for index, account in ipairs((argument or partyQueue.load()).accounts) do
            if
                account ~= value
                and account.enabled ~= false
                and (account.role == "leader" or account.role == "fight" or account.role == "carry")
            then
                if not (partyQueue.restingNow(account.name)) then
                    return account
                end
            end
        end
        return value
    end
    partyQueue.isHost = function()
        local value = partyQueue.carry()
        return value ~= nil and helper11(value.name) == helper11(localPlayer.Name)
    end
    context.carryMates = function()
        local carryMatesAt = os.clock()
        if partyQueue.carryMatesAt then
            if carryMatesAt - partyQueue.carryMatesAt < 1 then
                return partyQueue.carryMatesL
            end
        end
        partyQueue.carryMatesAt = carryMatesAt
        partyQueue.carryMatesL = {}
        local success, value = pcall(partyQueue.load)
        if success then
            if type(value) ~= "table" then
                return partyQueue.carryMatesL
            elseif value.on ~= true then
                return partyQueue.carryMatesL
            end
        else
            return partyQueue.carryMatesL
        end
        success = helper11(localPlayer.Name)
        for index, entry in ipairs(value.accounts or {}) do
            if
                type(entry) == "table"
                and entry.enabled ~= false
                and entry.role ~= "leech"
                and helper11(entry.name) ~= success
            then
                for index2, entry2 in ipairs(sharedValue3:GetPlayers()) do
                    if helper11(entry2.Name) == helper11(entry.name) then
                        index2 = entry2.Character
                        index, carryMatesAt =
                            index2 and (index2:FindFirstChild("HumanoidRootPart")),
                            index2 and (index2:FindFirstChildOfClass("Humanoid"))
                        if index then
                            if carryMatesAt then
                                if carryMatesAt.Health > 0 then
                                    partyQueue.carryMatesL[#partyQueue.carryMatesL + 1] = {
                                        name = helper11(entry2.Name),
                                        x = index.Position.X,
                                        z = index.Position.Z,
                                    }
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
        return partyQueue.carryMatesL
    end
    partyQueue.others = function()
        local value, value2 = partyQueue.carry(), {}
        for index, account in ipairs(partyQueue.load().accounts) do
            if account.enabled ~= false then
                if value then
                    if helper11(account.name) ~= helper11(value.name) then
                        value2[#value2 + 1] = account
                    end
                else
                    value2[#value2 + 1] = account
                end
            end
        end
        return value2
    end
    partyQueue.leechers = function()
        local value = {}
        for index, account in ipairs(partyQueue.load().accounts) do
            if account.enabled ~= false then
                if account.role == "leech" then
                    value[#value + 1] = account
                end
            end
        end
        return value
    end
    partyQueue.carryReal = function()
        return partyQueue.carry()
    end
    partyQueue.presCache = {}
    partyQueue.presence = function(argument, argument2)
        local value, value2 = helper11(argument), os.clock()
        argument = partyQueue.presCache[value]
        if if argument then value2 - argument.at >= 1 else not argument then
            local value3
            local success, value4 = pcall(readfile, "HarvardLabs/data/af_" .. value .. ".json")
            if success then
                if type(value4) == "string" then
                    local success2, value5 = pcall(function()
                        return sharedValue2:JSONDecode(value4)
                    end)
                    value3 = if success2 then if type(value5) == "table" then value5 else value3 else value3
                end
            end
            argument = {
                at = value2,
                t = if value3 == nil
                    then if argument then if argument.t then argument.t else value3 else value3
                    else value3,
            }
            partyQueue.presCache[value] = argument
        end
        value2 = argument.t
        if value2 then
            if os.time() - (tonumber(value2.at) or 0) <= (argument2 or 20) then
                return value2
            end
        end
        return nil
    end
    partyQueue.injected = function(argument)
        local now, value = os.clock(), partyQueue.injCache and partyQueue.injCache[argument or "any"]
        if value then
            if now - value.at < 5 then
                return value.list
            end
        end
        local list = {}
        pcall(function()
            for index, entry in ipairs(listfiles("HarvardLabs/data")) do
                index = tostring(entry):match("af_([^/\\]+)%.json$")
                if index then
                    if not (index:find("^party")) then
                        if not (index:find("^levelhist")) then
                            local success, value2 = pcall(function()
                                local value3 = argumentHelpers[108](readfile(entry))
                                return sharedValue2:JSONDecode(argumentHelpers:unpackValues(value3))
                            end)
                            local value4 = success
                                and type(value2) == "table"
                                and type(value2.name) == "string"
                                and value2.name
                            if value4 then
                                if argument then
                                    if os.time() - (tonumber(value2.at) or 0) <= argument then
                                        list[#list + 1] = value4
                                    end
                                else
                                    list[#list + 1] = value4
                                end
                            end
                        end
                    end
                end
            end
        end)
        partyQueue.injCache = partyQueue.injCache or {}
        partyQueue.injCache[argument or "any"] = { at = now, list = list }
        return list
    end
    partyQueue.autoDetect = function()
        if config.afAutoDetect ~= true then
            return 0
        end
        partyQueue.loadReal(true)
        if not partyQueue.doc then
            return 0
        end
        local value = partyQueue.partyOf(localPlayer.Name, partyQueue.doc)
        if value then
            if not (type(value.accounts) == "table") then
                return 0
            end
        else
            return 0
        end
        local value2 = partyQueue.entry(localPlayer.Name, value)
        if not (value2 ~= nil and value2.role == "leader") then
            local value3 = false
            for index, account in ipairs(value.accounts) do
                if account.role == "leader" then
                    value3 = true
                    break
                end
            end
            local value4 = value.accounts[1]
            if value3 then
                return 0
            elseif value4 ~= nil then
                if not (helper11(value4.name) == helper11(localPlayer.Name)) then
                    return 0
                end
            else
                return 0
            end
        end
        value2 = {}
        for index2, entry in ipairs(partyQueue.injected(config.afOnlineAge or 60)) do
            if helper11(entry) ~= helper11(localPlayer.Name) then
                if not (partyQueue.partyOf(entry, partyQueue.doc)) then
                    value.accounts[#value.accounts + 1] = { name = entry, role = "leech", enabled = true }
                    value2[#value2 + 1] = entry
                end
            end
        end
        if #value2 > 0 then
            partyQueue.save()
            if context.log then
                context.log(
                    "AltFarm",
                    ("found running Harvard Labs on this PC - added to the party: %s"):format(
                        table.concat(value2, ", ")
                    )
                )
            end
        end
        return #value2
    end
    task.spawn(function()
        while not runtimeState.destroyed do
            task.wait(config.afAutoDetectEvery or 5)
            pcall(partyQueue.autoDetect)
        end
    end)
    lobbyTick = partyQueue.presence(localPlayer.Name, 86400)
    if lobbyTick then
        if lobbyTick.place == "Level" and type(lobbyTick.job) == "string" then
            partyQueue.lastRunJob = lobbyTick.job
        elseif type(lobbyTick.lastRun) == "string" then
            partyQueue.lastRunJob = lobbyTick.lastRun
        end
        if type(lobbyTick.job) == "string" then
            if lobbyTick.job ~= game.JobId then
                partyQueue.cameFromJob = lobbyTick.job
            end
        end
        if lobbyTick.noFreeSlot == true then
            partyQueue.noFreeSlotSeen = true
        end
    end
    partyQueue.onItsWay = function(argument)
        local value = partyQueue.presence(argument, tonumber(config.afTransitAge) or 150)
        if value then
            if os.time() - (tonumber(value.at) or 0) <= 8 then
                return false
            end
        else
            return false
        end
        return value.hop == game.JobId
            or partyQueue.cameFromJob ~= nil and value.job == partyQueue.cameFromJob
    end
    local function helper16(argument)
        local value = helper11(argument)
        for index, entry in ipairs(sharedValue3:GetPlayers()) do
            if helper11(entry.Name) == value then
                return entry
            end
        end
        return nil
    end
    local function helper17(argument)
        local games = workspaceService:FindFirstChild("games")
        local value = games and (games:FindFirstChild("inLobby"))
        return value and value:FindFirstChild(argument) or nil
    end
    local function helper18(argument)
        local value = {}
        for index, child in ipairs(argument:GetChildren()) do
            if child.Name ~= "mapName" then
                value[helper11(child.Name)] = child.Name
            end
        end
        return value
    end
    local function helper19(status)
        partyQueue.status = status
        helper3("alt farm: " .. status)
    end
    partyQueue.requestRejoin = function(host, argument, rejoinAt)
        if partyQueue.load().rejoin == false then
            return false
        end
        if context.WSC then
            if context.WSC.holding() then
                return false
            end
        end
        local value = argument.started == false and partyQueue.load().joinEarly ~= false
        if
            partyQueue.load().joinAny == false
            and (partyQueue.lastRunJob == nil or argument.job ~= partyQueue.lastRunJob)
        then
            if not value then
                if context.MD then
                    if context.MD.restRejoinOk then
                        if not (context.MD.restRejoinOk()) then
                            return false
                        end
                    else
                        return false
                    end
                else
                    return false
                end
            end
        end
        if argument.over == true then
            return false
        end
        if tonumber(argument.at) then
            if os.time() - tonumber(argument.at) > 20 then
                return false
            end
        else
            return false
        end
        if partyQueue.rejoinJob ~= argument.job then
            partyQueue.rejoinJob = argument.job
            partyQueue.rejoinTries = 0
            partyQueue.rejoinSaid = nil
        end
        if rejoinAt - (partyQueue.rejoinAt or -math.huge) < (config.afRejoinEvery or 20) then
            helper19(
                ("%s is in a run - asked to join it (%s)"):format(
                    host,
                    tostring(partyQueue.rejoinSaid or "sending")
                )
            )
            return true
        end
        if (partyQueue.rejoinTries or 0) >= (config.afRejoinMax or 30) then
            helper19(
                ("%s is in a run - asked %d times, waiting for it to come back"):format(
                    host,
                    partyQueue.rejoinTries
                )
            )
            return true
        end
        value = getService("ReplicatedStorage"):FindFirstChild("remotes")
        local value2 = value and (value:FindFirstChild("sendJoinRequest"))
        if not (value2 and (value2:IsA("RemoteFunction"))) then
            return false
        end
        partyQueue.rejoinAt, partyQueue.rejoinTries = rejoinAt, (partyQueue.rejoinTries or 0) + 1
        local try = partyQueue.rejoinTries
        local value3 = type(argument.name) == "string" and argument.name ~= "" and argument.name or host
        task.spawn(function()
            local success, value4, value5, value6 = pcall(value2.InvokeServer, value2, value3, false)
            if success then
                if value4 then
                    if value6 == true then
                        success, value4, value5 = pcall(value2.InvokeServer, value2, value3, true)
                    end
                end
            end
            partyQueue.rejoinSaid = success and (value4 and "request sent" or tostring(value5 or "refused"))
                or "request failed"
            if context.queueLog then
                context.queueLog("rejoin_request", {
                    host = host,
                    ok = tostring(success),
                    sent = tostring(value4),
                    msg = tostring(value5),
                    force = tostring(value6),
                    try = try,
                })
            end
        end)
        helper19(("%s is in a run - asking to join it (try %d)"):format(host, try))
        return true
    end
    partyQueue.allAtStart = function(argument)
        if partyQueue.load().startAll ~= true then
            return nil
        end
        argument = workspaceService:FindFirstChild("dungeonName")
        if argument then
            if not (tostring(argument.Value) == "Northern Lands") then
                return nil
            end
        else
            return nil
        end
        argument = {}
        for index, entry in ipairs(partyQueue.mates()) do
            if not (partyQueue.restingNow(entry.name)) then
                index = helper16(entry.name) ~= nil
                local value = index and entry.role ~= "leech" and partyQueue.presence(entry.name, 15) or nil
                if index then
                    if entry.role ~= "leech" then
                        if value then
                            if value.job == game.JobId then
                                if not (value.atStart == true) then
                                    argument[#argument + 1] = entry.name
                                end
                            else
                                argument[#argument + 1] = entry.name
                            end
                        else
                            argument[#argument + 1] = entry.name
                        end
                    end
                else
                    argument[#argument + 1] = entry.name
                end
            end
        end
        return #argument > 0 and table.concat(argument, ", ") or nil
    end
    partyQueue.mates = function()
        local value, value2 = {}, helper11(localPlayer.Name)
        for index, account in ipairs(partyQueue.load().accounts) do
            if account.enabled ~= false then
                if helper11(account.name) ~= value2 then
                    value[#value + 1] = account
                end
            end
        end
        return value
    end
    partyQueue.ownRun = function()
        local value = workspaceService:FindFirstChild("dungeonName")
        if value then
            if not (tostring(value.Value) ~= "") then
                return false
            end
        else
            return false
        end
        value = context.runOwnerId and context.runOwnerId()
        return value ~= nil and value == localPlayer.UserId
    end
    partyQueue.rejoinHostTick = function(argument)
        if argument - (partyQueue.rjHostAt or -math.huge) < 1 then
            return
        end
        partyQueue.rjHostAt = argument
        if partyQueue.load().rejoin == false then
            return
        end
        if not (partyQueue.isHost()) then
            local value = partyQueue.carry()
            if value then
                if helper16(value.name) then
                    return
                end
            else
                return
            end
        end
        local value2 = workspaceService:FindFirstChild("dungeonName")
        if value2 then
            if not (tostring(value2.Value) ~= "") then
                return
            end
        else
            return
        end
        value2 = getService("ReplicatedStorage"):FindFirstChild("remotes")
        if not value2 then
            return
        end
        if not partyQueue.rjConn then
            local showJoinRequest, respondJoinRequest =
                value2:FindFirstChild("showJoinRequest"), value2:FindFirstChild("respondJoinRequest")
            if showJoinRequest then
                if not respondJoinRequest then
                    return
                end
            else
                return
            end
            partyQueue.rjIds = partyQueue.rjIds or {}
            partyQueue.rjConn = showJoinRequest.OnClientEvent:Connect(
                function(argument2, argument3, argument4, argument5)
                    if runtimeState.destroyed then
                        return
                    elseif argument4 == "close" then
                        return
                    elseif argument2 == nil then
                        return
                    end
                    argument4 = false
                    for index, entry in ipairs(partyQueue.mates()) do
                        index = helper11(entry.name)
                        if helper11(argument3) == index then
                            argument4 = true
                            break
                        end
                        if partyQueue.rjIds[index] == nil then
                            local success, value3 = pcall(function()
                                local name2 = entry.name
                                return sharedValue3:GetUserIdFromNameAsync(name2)
                            end)
                            partyQueue.rjIds[index] = success and value3 or false
                        end
                        if
                            partyQueue.rjIds[index]
                            and tostring(partyQueue.rjIds[index]) == tostring(argument2)
                        then
                            argument4 = true
                            break
                        end
                    end
                    argument4 = argument4
                        and (
                            if partyQueue.runFighters
                                then if partyQueue.runFighters() == 0
                                    then if partyQueue.runStarted() then false else argument4
                                    else argument4
                                else argument4
                        )
                    argument4 = argument4
                        and (
                            if context.runFailed
                                then if context.runFailed() then false else argument4
                                else argument4
                        )
                    if not argument4 then
                        if context.queueLog then
                            context.queueLog("rejoin_unanswered", {
                                id = tostring(argument2),
                                name = tostring(argument3),
                                level = tostring(argument5),
                            })
                        end
                        return
                    end
                    pcall(respondJoinRequest.FireServer, respondJoinRequest, argument2, true)
                    task.delay(0.3, function()
                        pcall(function()
                            local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
                            local value4 = playerGui
                                and playerGui:FindFirstChild("joinRequestConfirm_" .. tostring(argument2))
                            if value4 then
                                value4:Destroy()
                            end
                        end)
                    end)
                    if context.queueLog then
                        context.queueLog("rejoin_answer", {
                            id = tostring(argument2),
                            name = tostring(argument3),
                            level = tostring(argument5),
                            accepted = tostring(argument4),
                        })
                    end
                end
            )
        end
        if context.runComplete then
            if context.runComplete() then
                partyQueue.lateJoinWanted = nil
                return
            end
        end
        local value5 = {}
        for index2, entry2 in ipairs(sharedValue3:GetPlayers()) do
            value5[helper11(entry2.Name)] = true
        end
        local missing
        for index3, entry3 in ipairs(partyQueue.mates()) do
            index3 = value5[helper11(entry3.name)]
            if if index3 then not index3 else not partyQueue.restingNow(entry3.name) then
                missing = entry3.name
                break
            end
        end
        if not missing then
            partyQueue.rjMissingSince = nil
            partyQueue.lateJoinWanted = nil
            return
        end
        if partyQueue.rjMissingJob ~= game.JobId then
            partyQueue.rjMissingJob = game.JobId
            partyQueue.rjMissingSince = argument
        end
        partyQueue.rjMissingSince = partyQueue.rjMissingSince or argument
        if argument - partyQueue.rjMissingSince < (config.afRejoinOpenAfter or 15) then
            return
        end
        partyQueue.lateJoinWanted = game.JobId
        local value6, joinRequests =
            localPlayer:FindFirstChild("lateJoin"), localPlayer:FindFirstChild("joinRequests")
        value6 = if value6 then if value6:IsA("StringValue") then value6 else nil else nil
        if value6 then
            if value6.Value == "on" then
                if
                    not (joinRequests and joinRequests:IsA("StringValue") and joinRequests.Value ~= "anyone")
                then
                    partyQueue.ljOpen = game.JobId
                    if partyQueue.ljTryJob == game.JobId then
                        partyQueue.ljTries = 0
                    end
                    return
                end
            end
            value5 = localPlayer:FindFirstChild("dataLoaded")
            if value5 then
                if value5:IsA("BoolValue") then
                    if value5.Value ~= true then
                        return
                    end
                end
            end
            if partyQueue.ljTryJob ~= game.JobId then
                partyQueue.ljTryJob = game.JobId
                partyQueue.ljTries = 0
                partyQueue.ljTryAt = nil
            end
            if partyQueue.ljTries >= (config.ljTriesMax or 10) then
                return
            elseif argument - (partyQueue.ljTryAt or -math.huge) < (config.ljRetry or 3) then
                return
            end
            partyQueue.ljTryAt, partyQueue.ljTries = argument, partyQueue.ljTries + 1
        elseif partyQueue.ljOpen == game.JobId then
            return
        end
        argument = partyQueue.rjOpenedJob ~= game.JobId
        partyQueue.rjOpenedJob, partyQueue.ljOpen = game.JobId, game.JobId
        local hostSetLateJoin, hostSetJoinRequestMode =
            value2:FindFirstChild("hostSetLateJoin"), value2:FindFirstChild("hostSetJoinRequestMode")
        if hostSetLateJoin then
            if value6 then
                if value6.Value ~= "on" then
                    pcall(hostSetLateJoin.FireServer, hostSetLateJoin, "on")
                end
            else
                pcall(hostSetLateJoin.FireServer, hostSetLateJoin, "on")
            end
        end
        if hostSetJoinRequestMode then
            if joinRequests then
                if joinRequests:IsA("StringValue") then
                    if joinRequests.Value ~= "anyone" then
                        pcall(hostSetJoinRequestMode.FireServer, hostSetJoinRequestMode, "anyone")
                    end
                else
                    pcall(hostSetJoinRequestMode.FireServer, hostSetJoinRequestMode, "anyone")
                end
            else
                pcall(hostSetJoinRequestMode.FireServer, hostSetJoinRequestMode, "anyone")
            end
        end
        if argument then
            if context.queueLog then
                context.queueLog("rejoin_open", { missing = missing })
            end
            if context.log then
                context.log(
                    "AltFarm",
                    ("%s is not in the run - late join on, its request will be accepted"):format(missing)
                )
            end
        end
    end
    partyQueue.giveHostBack = function(hostBackAt)
        if hostBackAt - (partyQueue.hostBackAt or -math.huge) < (config.hostBackEvery or 5) then
            return
        end
        if partyQueue.load().on ~= true then
            return
        elseif partyQueue.isHost() then
            return
        end
        local value = workspaceService:FindFirstChild("dungeonName")
        if value then
            if not (tostring(value.Value) ~= "") then
                return
            end
        else
            return
        end
        value = partyQueue.carry()
        local value2 = value and helper16(value.name)
        if not value2 then
            return
        end
        if (context.runOwnerId and context.runOwnerId()) ~= localPlayer.UserId then
            return
        end
        value = getService("ReplicatedStorage"):FindFirstChild("remotes")
        local value3 = value and (value:FindFirstChild("hostTransfer"))
        if not value3 then
            return
        end
        partyQueue.hostBackAt = hostBackAt
        pcall(value3.FireServer, value3, value2)
        if context.queueLog then
            context.queueLog("host_back", { to = value2.Name })
        end
        if context.log then
            context.log(
                "AltFarm",
                ("%s, the party's leader, is back in the run - handing the host back"):format(value2.Name)
            )
        end
    end
    partyQueue.runFighters = function()
        local value, value2 = partyQueue.load(), 0
        for index, entry in ipairs(sharedValue3:GetPlayers()) do
            index = partyQueue.entry(entry.Name, value)
            value2 = if index
                then if index.enabled ~= false
                    then if index.role ~= "leech"
                        then if entry:GetAttribute("LateJoiner") ~= true then value2 + 1 else value2
                        else value2
                    else value2
                else value2
        end
        return value2
    end
    partyQueue.runStarted = function()
        local dungeonStarted = workspaceService:FindFirstChild("dungeonStarted")
        return dungeonStarted ~= nil and dungeonStarted.Value == true
    end
    partyQueue.deadUnstarted = function(deadLeftAt, argument)
        if config.deadUnstartedAfter == false then
            partyQueue.unstartedSince = nil
            return false
        elseif partyQueue.runStarted() then
            partyQueue.unstartedSince = nil
            return false
        end
        argument = workspaceService:FindFirstChild("dungeonName")
        if argument then
            if tostring(argument.Value) ~= "" then
                if partyQueue.role() ~= "leech" then
                    partyQueue.unstartedSince = nil
                    return false
                end
            else
                partyQueue.unstartedSince = nil
                return false
            end
        else
            partyQueue.unstartedSince = nil
            return false
        end
        if partyQueue.runFighters() > 0 then
            partyQueue.unstartedSince = nil
            return false
        end
        partyQueue.unstartedSince = partyQueue.unstartedSince or deadLeftAt
        argument = (tonumber(config.deadUnstartedAfter) or 120) - (deadLeftAt - partyQueue.unstartedSince)
        if argument > 0 then
            helper19(
                ("the leader is not in this run yet - letting it in, else to the lobby in %.0fs"):format(
                    argument
                )
            )
            return true
        end
        if deadLeftAt - (partyQueue.deadLeftAt or -math.huge) < 15 then
            return true
        end
        partyQueue.deadLeftAt = deadLeftAt
        if context.log then
            context.log(
                "AltFarm",
                "the leader never came into this run - back to the lobby to make the party again"
            )
        end
        if context.MD and context.MD.goLobby then
            pcall(context.MD.goLobby)
        else
            pcall(function()
                getService("TeleportService"):Teleport(77649408247578, localPlayer)
            end)
        end
        return true
    end
    partyQueue.deadRunTick = function(argument)
        if argument - (partyQueue.deadCheckAt or -math.huge) < 1 then
            return
        end
        partyQueue.deadCheckAt = argument
        local value = partyQueue.load()
        if value.on ~= true then
            partyQueue.deadSince = nil
            return
        elseif not (partyQueue.entry(localPlayer.Name, value)) then
            partyQueue.deadSince = nil
            return
        end
        if partyQueue.deadUnstarted(argument, value) then
            return
        end
        local value2, value3 =
            workspaceService:FindFirstChild("dungeonName"), workspaceService:FindFirstChild("dungeonStarted")
        if value2 then
            if tostring(value2.Value) ~= "" then
                if value3 then
                    if value3.Value == true then
                        if context.runComplete then
                            if context.runComplete() then
                                partyQueue.deadSince = nil
                                return
                            end
                        end
                    else
                        partyQueue.deadSince = nil
                        return
                    end
                else
                    partyQueue.deadSince = nil
                    return
                end
            else
                partyQueue.deadSince = nil
                return
            end
        else
            partyQueue.deadSince = nil
            return
        end
        value2 = 0
        for index, entry in ipairs(sharedValue3:GetPlayers()) do
            index = partyQueue.entry(entry.Name, value)
            value2 = if index
                then if index.enabled ~= false
                    then if index.role ~= "leech"
                        then if entry:GetAttribute("LateJoiner") ~= true then value2 + 1 else value2
                        else value2
                    else value2
                else value2
        end
        if value2 > 0 then
            partyQueue.deadSince = nil
            return
        end
        partyQueue.deadSince = partyQueue.deadSince or argument
        value3 = (config.deadRunAfter or 20) - (argument - partyQueue.deadSince)
        if value3 > 0 then
            helper19(
                ("nobody here can clear this run (late joiners are spectators) - to the lobby in %.0fs"):format(
                    value3
                )
            )
            return
        end
        if argument - (partyQueue.deadLeftAt or -math.huge) < 15 then
            return
        end
        partyQueue.deadLeftAt = argument
        if context.queueLog then
            value3, value2 = context.queueLog, {}
            value2.waited = math.floor(argument - partyQueue.deadSince)
            value3("dead_run", value2)
        end
        if context.log then
            context.log(
                "AltFarm",
                "nobody in this run can clear it - back to the lobby to make the party again"
            )
        end
        if context.notify then
            context.notify(
                "warning",
                "Back to the lobby",
                "Nobody left in this run can clear it - making the party again."
            )
        end
        if context.MD and context.MD.goLobby then
            pcall(context.MD.goLobby)
        else
            pcall(function()
                getService("TeleportService"):Teleport(77649408247578, localPlayer)
            end)
        end
    end
    context.runFailed = function()
        local value = localPlayer:FindFirstChildOfClass("PlayerGui")
        local value2, value3 = value and (value:FindFirstChild("failedGui"))
        if value2 then
            local value4 = value2:IsA("ScreenGui")
            value3 = if value4 then value2.Enabled else not value4
        else
            value3 = value2
        end
        if value3 then
            local frame = value2:FindFirstChild("Frame")
            if frame == nil then
                return true
            elseif frame:IsA("GuiObject") then
                if frame.Visible then
                    return true
                end
            else
                return true
            end
        end
        value3 = value and (value:FindFirstChild("MainUI"))
        value2 = value3 and (value3:FindFirstChild("a"))
        value3 = value2 and (value2:FindFirstChild("main"))
        if value3 then
            if value3:IsA("TextLabel") then
                if value3.Visible then
                    if value2:IsA("GuiObject") then
                        if value2.Visible then
                            if string.upper(value3.Text):find("FAILED", 1, true) then
                                value = workspaceService:FindFirstChild("started")
                                if value then
                                    if value:IsA("BoolValue") then
                                        if value.Value == true then
                                            if context.pinnedBy then
                                                if context.pinnedBy(localPlayer.Character) then
                                                    return true
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
        end
        value2 = workspaceService:FindFirstChild("bonusBossStatus")
        return value2 ~= nil and string.lower(tostring(value2.Value)):find("fail", 1, true) ~= nil
    end
    partyQueue.failedTick = function(argument)
        if argument - (partyQueue.failCheckAt or -math.huge) < 1 then
            return
        end
        partyQueue.failCheckAt = argument
        if workspaceService:FindFirstChild("dungeonName") then
            if context.runFailed then
                if not (context.runFailed()) then
                    partyQueue.failedSince = nil
                    return
                end
            else
                partyQueue.failedSince = nil
                return
            end
        else
            partyQueue.failedSince = nil
            return
        end
        partyQueue.failedSince = partyQueue.failedSince or argument
        local value = (config.failedStuckAfter or 150) - (argument - partyQueue.failedSince)
        if value > 0 then
            helper19(
                ("dungeon failed - waiting for the game's teleport to town (lobby by ourselves in %.0fs)"):format(
                    value
                )
            )
            return
        end
        if argument - (partyQueue.failedLeftAt or -math.huge) < 15 then
            return
        end
        partyQueue.failedLeftAt = argument
        if context.queueLog then
            local queueLog2, value2 = context.queueLog, {}
            value2.waited = math.floor(argument - partyQueue.failedSince)
            queueLog2("failed_stuck", value2)
        end
        if context.log then
            context.log(
                "AltFarm",
                "the run failed and the game did not send us to town - back to the lobby to make the party again"
            )
        end
        if context.notify then
            context.notify("error", "Run failed", "Back to the lobby to make the party again.")
        end
        if context.MD and context.MD.goLobby then
            pcall(context.MD.goLobby)
        else
            pcall(function()
                getService("TeleportService"):Teleport(77649408247578, localPlayer)
            end)
        end
    end
    partyQueue.LEAVING_TITLE = "Leaving the dungeon"
    partyQueue.LEAVING_BODY = "Back to the lobby with the whole party."
    partyQueue.leaveGo = function(argument, argument2)
        local leaving = partyQueue.leaving
        if leaving then
            if argument - leaving.at < 12 then
                return
            end
        end
        partyQueue.leaving = { at = argument, tries = (leaving and leaving.tries or 0) + 1 }
        if context.log then
            context.log(
                "AltFarm",
                ("%s - back to the lobby now (try %d)"):format(argument2, partyQueue.leaving.tries)
            )
        end
        if context.MD and context.MD.goLobby then
            pcall(context.MD.goLobby)
        else
            pcall(function()
                getService("TeleportService"):Teleport(77649408247578, localPlayer)
            end)
        end
    end
    partyQueue.cardLeaving = function(argument)
        if not argument or argument.gone then
            return false
        end
        pcall(argument.set, partyQueue.LEAVING_TITLE, partyQueue.LEAVING_BODY)
        pcall(function()
            argument.busy = true
            argument.button.Text = "Leaving..."
        end)
        return true
    end
    partyQueue.leaveNowAll = function(argument)
        pcall(function()
            partyQueue.loadReal(true)
            local value = partyQueue.partyOf(localPlayer.Name, partyQueue.doc)
            if value then
                value.leaveNow = { job = game.JobId, at = os.time() }
                partyQueue.save()
            end
        end)
        partyQueue.cardLeaving(argument)
        partyQueue.leaveGo(os.clock(), "Leave now (Run this party is off)")
    end
    partyQueue.offNoticeTick = function(offCheckAt, argument)
        if offCheckAt - (partyQueue.offCheckAt or -math.huge) < 1 then
            return
        end
        partyQueue.offCheckAt = offCheckAt
        if not (sharedValue.place == "Level") then
            if not (sharedValue.place == "100+") then
                if partyQueue.offCard then
                    pcall(partyQueue.offCard.close)
                    partyQueue.offCard = nil
                end
                return
            end
        end
        local value = argument or partyQueue.load()
        argument = partyQueue.entry(localPlayer.Name, value)
        if not argument then
            return
        end
        local leaveNow = value.leaveNow
        if type(leaveNow) == "table" then
            if leaveNow.job == game.JobId then
                if tonumber(leaveNow.at) then
                    if math.abs(os.time() - tonumber(leaveNow.at)) <= 90 then
                        if not partyQueue.leaving then
                            if not (partyQueue.cardLeaving(partyQueue.offCard)) then
                                if context.notify then
                                    context.notify(
                                        "party",
                                        partyQueue.LEAVING_TITLE,
                                        "Leave now was pressed - back to the lobby with the whole party."
                                    )
                                end
                            end
                        end
                        partyQueue.leaveGo(offCheckAt, "Leave now was pressed")
                        return
                    end
                end
            end
        end
        if value.on == true then
            if argument.enabled ~= false then
                partyQueue.partyRunJob = game.JobId
            end
            partyQueue.offShown = nil
            if partyQueue.offCard then
                pcall(partyQueue.offCard.close)
                partyQueue.offCard = nil
            end
            return
        end
        if partyQueue.partyRunJob ~= game.JobId then
            return
        elseif partyQueue.offShown == game.JobId then
            return
        end
        partyQueue.offShown = game.JobId
        if context.log then
            context.log(
                "AltFarm",
                "Run this party was switched off during this run - to the lobby after it (Leave now on the card: at once)"
            )
        end
        if context.notifyCard then
            partyQueue.offCard = context.notifyCard(
                "party",
                "Going to lobby after this dungeon",
                "Run this party was switched off. Leave now takes the whole party out.",
                nil,
                {
                    sticky = true,
                    button = {
                        text = "Leave now",
                        onClick = function(argument2)
                            partyQueue.leaveNowAll(argument2)
                        end,
                    },
                }
            )
        end
    end
    partyQueue.stuckTick = function(argument)
        if not partyQueue.tpFailConn then
            partyQueue.tpFailConn = true
            pcall(function()
                partyQueue.tpFailConn = getService("TeleportService").TeleportInitFailed:Connect(
                    function(argument2, argument3)
                        if argument2 == localPlayer then
                            if argument3 == Enum.TeleportResult.IsTeleporting then
                                partyQueue.tpBusyLast = os.time()
                                partyQueue.tpBusyFirst = partyQueue.tpBusyFirst or os.time()
                            end
                        end
                    end
                )
            end)
        end
        local value = localPlayer:FindFirstChild("teleporting")
        if value then
            if value:IsA("BoolValue") then
                if value.Value == true then
                    partyQueue.tpFlagSince = partyQueue.tpFlagSince or argument
                else
                    partyQueue.tpFlagSince = nil
                end
            else
                partyQueue.tpFlagSince = nil
            end
        else
            partyQueue.tpFlagSince = nil
        end
        if partyQueue.tpBusyLast then
            if os.time() - partyQueue.tpBusyLast > 120 then
                partyQueue.tpBusyFirst = nil
                partyQueue.tpBusyLast = nil
            end
        end
        value = tonumber(config.afStuckTpAfter) or 60
        if
            partyQueue.tpFlagSince ~= nil and argument - partyQueue.tpFlagSince >= value
            or partyQueue.tpBusyLast ~= nil
                and os.time() - partyQueue.tpBusyLast <= 30
                and os.time() - (partyQueue.tpBusyFirst or os.time()) >= value
        then
            if not partyQueue.stuckAt then
                if context.log then
                    context.log(
                        "AltFarm",
                        "stuck in a teleport that never finished - the party goes on without this account; its Roblox needs a restart"
                    )
                end
                if context.notify then
                    pcall(
                        context.notify,
                        "warning",
                        "Stuck in a teleport",
                        "The game never finished moving this account. Its party goes on without it - restart this Roblox to bring it back."
                    )
                end
            end
            partyQueue.stuckAt = os.time()
        elseif partyQueue.stuckAt then
            if os.time() - partyQueue.stuckAt > 30 then
                partyQueue.stuckAt = nil
            end
        end
    end
    partyQueue.minLeechLevel = function()
        local value
        for index, entry in ipairs(partyQueue.leechers()) do
            index = helper16(entry.name)
            local value2 = index and (index:FindFirstChild("leaderstats"))
            index = value2 and (value2:FindFirstChild("Level"))
            value2 = if index then tonumber(index.Value) else nil
            if if value2 then value2 <= 0 else not value2 then
                index = partyQueue.presence(entry.name, 86400)
                value2 = index and tonumber(index.level) or nil
            end
            value = if value2
                then if value2 > 0 then math.min(value or math.huge, value2) else value
                else value
        end
        return value
    end
    partyQueue.skipFinalTick = function(argument)
        if config.afSkipFinalBoss == false then
            return
        elseif argument - (partyQueue.sfAt or -math.huge) < 0.5 then
            return
        end
        partyQueue.sfAt = argument
        if sharedValue.place == "Level" or sharedValue.place == "100+" then
            if partyQueue.role() == nil then
                return
            elseif not (partyQueue.levelling()) then
                return
            end
        else
            return
        end
        if context.isEvent and context.isEvent() then
            return
        elseif context.runComplete then
            if context.runComplete() then
                return
            end
        end
        local value = partyQueue.minLeechLevel()
        if value then
            if value >= (tonumber(config.afSkipFinalUntil) or 155) then
                return
            end
        else
            return
        end
        local value2 = workspaceService:FindFirstChild("dungeon")
        local value3 = value2 and (value2:FindFirstChild("bossRoom"))
        value2 = value3 and (value3:FindFirstChild("fightingBoss"))
        if value2 then
            if value2:IsA("ValueBase") then
                if not (value2.Value == true) then
                    return
                end
            else
                return
            end
        else
            return
        end
        if partyQueue.sfJob ~= game.JobId then
            partyQueue.sfJob = game.JobId
            if context.log then
                context.log(
                    "AltFarm",
                    ("final boss up, a leecher is level %d (under %d) - restarting the run, no completion"):format(
                        value,
                        tonumber(config.afSkipFinalUntil) or 155
                    )
                )
            end
        end
        context.skipFinalAt = os.clock()
        if context.WH then
            context.WH.run = nil
        end
        if partyQueue.sfSeenJob ~= game.JobId then
            partyQueue.sfSeenJob = game.JobId
            partyQueue.sfSeenAt = argument
        end
        if argument - partyQueue.sfSeenAt < (tonumber(config.afSkipReplayWait) or 25) then
            value = context.isRunOwner and context.isRunOwner()
            helper19(
                ("final boss up - leechers under %d: %s"):format(
                    tonumber(config.afSkipFinalUntil) or 155,
                    value and "replaying the run (host)" or "waiting for the host to replay"
                )
            )
            if value then
                if context.replayNow then
                    if argument - (partyQueue.sfReplayAt or -math.huge) >= 10 then
                        partyQueue.sfReplayAt = argument
                        pcall(context.replayNow)
                    end
                end
            end
            return
        end
        helper19("final boss up - the replay did not restart the run: back to the lobby")
        if argument - (partyQueue.sfLeftAt or -math.huge) < 15 then
            return
        end
        partyQueue.sfLeftAt = argument
        if context.MD and context.MD.goLobby then
            pcall(context.MD.goLobby)
        else
            pcall(function()
                getService("TeleportService"):Teleport(77649408247578, localPlayer)
            end)
        end
    end
    partyQueue.tickAlways = function(presAt)
        if partyQueue.skipFinalTick then
            pcall(partyQueue.skipFinalTick, presAt)
        end
        if partyQueue.rejoinHostTick then
            pcall(partyQueue.rejoinHostTick, presAt)
        end
        if partyQueue.deadRunTick then
            pcall(partyQueue.deadRunTick, presAt)
        end
        if partyQueue.failedTick then
            pcall(partyQueue.failedTick, presAt)
        end
        if partyQueue.offNoticeTick then
            pcall(partyQueue.offNoticeTick, presAt)
        end
        if partyQueue.stuckTick then
            pcall(partyQueue.stuckTick, presAt)
        end
        if partyQueue.apartTick then
            pcall(partyQueue.apartTick, presAt)
        end
        if partyQueue.giveHostBack then
            pcall(partyQueue.giveHostBack, presAt)
        end
        local value = partyQueue.role()
        if value ~= partyQueue.fpsRole then
            partyQueue.fpsRole = value
            if context.applyFps then
                pcall(context.applyFps)
            end
            if context.applyRender then
                pcall(context.applyRender)
            end
        end
        value = partyQueue.load().leechDraw == true
        if value ~= partyQueue.drawWas then
            partyQueue.drawWas = value
            if context.applyRender then
                pcall(context.applyRender)
            end
        end
        if presAt - (partyQueue.presAt or -math.huge) < 3 then
            return
        end
        partyQueue.presAt = presAt
        presAt = localPlayer:FindFirstChild("leaderstats")
        value = presAt and (presAt:FindFirstChild("Level"))
        local value2 = value and tonumber(value.Value) or 0
        if partyQueue.mySlot == nil or os.clock() - (partyQueue.slotAskedAt or 0) > 60 then
            if not partyQueue.slotAsk then
                partyQueue.slotAsk = true
                partyQueue.slotAskedAt = os.clock()
                task.spawn(function()
                    local value3 = partyQueue.slotInfo()
                    if value3 then
                        if tonumber(value3.selectedSlot) then
                            partyQueue.mySlot = tonumber(value3.selectedSlot)
                        end
                    end
                    partyQueue.slotAsk = false
                end)
            end
        end
        value = partyQueue.presence(localPlayer.Name, 600)
        local value4
        if
            value
            and tonumber(value.level)
            and tonumber(value.level) > value2
            and (value.slot == nil or partyQueue.mySlot == nil or tonumber(value.slot) == partyQueue.mySlot)
        then
            value2 = tonumber(value.level)
            value4 = value2
        else
            value4 = value2
        end
        if sharedValue.place == "Level" then
            partyQueue.lastRunJob = game.JobId
        elseif sharedValue.place == "100+" then
            partyQueue.lastRunJob = game.JobId
        end
        local over
        pcall(function()
            if sharedValue.place == "Level" or sharedValue.place == "100+" then
                if sharedValue.runOverAt ~= nil then
                    over = true
                elseif context.runFailed ~= nil then
                    if context.runFailed() == true then
                        over = true
                    end
                end
            end
        end)
        if value4 > 0 or sharedValue.place == "Lobby" then
            local xpBoost = localPlayer:FindFirstChild("xpBoost")
            pcall(function()
                writefile(
                    "HarvardLabs/data/af_" .. helper11(localPlayer.Name) .. ".json",
                    sharedValue2:JSONEncode({
                        name = localPlayer.Name,
                        level = value4 > 0 and value4 or nil,
                        place = sharedValue.place or "?",
                        job = game.JobId,
                        at = os.time(),
                        uid = localPlayer.UserId,
                        host = (sharedValue.place == "Level" or sharedValue.place == "100+")
                                and context.runOwnerId
                                and context.runOwnerId()
                            or nil,
                        slot = partyQueue.mySlot,
                        xpBoost = xpBoost and tonumber(xpBoost.Value) or nil,
                        noFreeSlot = partyQueue.noFreeSlot
                            or partyQueue.newSaveGaveUp
                            or partyQueue.noFreeSlotSeen
                            or nil,
                        owner = partyQueue.ownRun and partyQueue.ownRun() or nil,
                        lastRun = partyQueue.lastRunJob,
                        over = over,
                        hop = partyQueue.hopJob,
                        loading = sharedValue.place == "Lobby" and value4 <= 0 or nil,
                        stuck = partyQueue.stuckAt
                                and os.time() - partyQueue.stuckAt <= 60
                                and partyQueue.stuckAt
                            or nil,
                        setup = runtimeState.configAsk == true or nil,
                        started = (sharedValue.place == "Level" or sharedValue.place == "100+")
                                and (function()
                                    local dungeonStarted = workspaceService:FindFirstChild("dungeonStarted")
                                    return dungeonStarted ~= nil and dungeonStarted.Value == true
                                end)()
                            or nil,
                        atStart = (sharedValue.place == "Level" or sharedValue.place == "100+")
                                and context.RT
                                and context.RT.preWalk
                                and context.RT.preWalk.pointsDone == true
                            or nil,
                        resting = context.MD and context.MD.restingUntil and context.MD.restingUntil() or nil,
                        restBreak = context.MD and context.MD.breakAt and context.MD.breakAt() or nil,
                        dropPending = context.MD
                                and (context.MD.pendingDrop ~= nil or context.MD.pendingBreak ~= nil)
                            or nil,
                    })
                )
            end)
        end
    end
    partyQueue.leaderRejoinTick = function(argument)
        if partyQueue.load().rejoin == false then
            return false
        end
        partyQueue.lrArrive = partyQueue.lrArrive or argument
        if argument - partyQueue.lrArrive < (config.afLeaderRejoinAfter or 20) then
            return false
        elseif argument - (partyQueue.lastStart or -math.huge) < 60 then
            return false
        end
        local value, value2 = {}
        for index, entry in ipairs(partyQueue.others()) do
            index = partyQueue.presence(entry.name, 20)
            if index and (index.place == "Level" or index.place == "100+") then
                if type(index.job) == "string" then
                    if index.job ~= "" then
                        if index.job ~= game.JobId then
                            if index.over ~= true then
                                value[index.job] = value[index.job] or {}
                                table.insert(value[index.job], { name = entry.name, p = index })
                                value2 = if index.owner == true
                                    then { name = entry.name, p = index }
                                    else value2
                            end
                        end
                    end
                end
            end
        end
        local value3
        for key, entry2 in pairs(value) do
            for index2, entry3 in ipairs(entry2) do
                index2 = tonumber(entry3.p.host)
                if index2 then
                    for index3, entry4 in ipairs(entry2) do
                        if tonumber(entry4.p.uid) == index2 then
                            value3 = entry4
                            break
                        end
                    end
                end
                if value3 then
                    break
                end
            end
            if value3 then
                break
            end
        end
        value3 = value3 or value2
        if not value3 then
            local value4
            for key2, entry5 in pairs(value) do
                value4 = if value4 then if #entry5 > #value4 then entry5 else value4 else entry5
            end
            if not value4 then
                return false
            end
            value3 =
                value4[(partyQueue.rejoinJob == value4[1].p.job and (partyQueue.rejoinTries or 0) or 0) % #value4 + 1]
        end
        if partyQueue.rejoinJob == value3.p.job then
            if (partyQueue.rejoinTries or 0) >= (config.afRejoinMax or 30) then
                return false
            end
        end
        if partyQueue.lrSaid ~= value3.p.job then
            partyQueue.lrSaid = value3.p.job
            if context.log then
                context.log(
                    "AltFarm",
                    ("the party is in a run without this account - asking %s to let it back in"):format(
                        value3.name
                    )
                )
            end
        end
        return partyQueue.requestRejoin(value3.name, value3.p, argument) == true
    end
    partyQueue.restartWait = function()
        partyQueue.startClockJob = nil
        partyQueue.hereSince = nil
        partyQueue.lobbySince = nil
    end
    partyQueue.togetherWait = function(argument, argument2, argument3, argument4)
        if config.afTogether == false then
            return false
        elseif #argument2 == 0 then
            return false
        end
        local value, value2 =
            argument - (partyQueue.startClock or argument), tonumber(config.afTogetherWait) or 600
        if value >= value2 then
            return false
        end
        if value > (tonumber(config.afTogetherHop) or 90) then
            if partyQueue.togetherHopJob ~= game.JobId then
                if (partyQueue.togetherHops or 0) < (tonumber(config.afTogetherHops) or 2) then
                    if context.MD then
                        if context.MD.lowPopServer then
                            partyQueue.togetherHopJob, partyQueue.togetherHops =
                                game.JobId, (partyQueue.togetherHops or 0) + 1
                            helper19(
                                ("%s still not here after %.0fs - moving the party to an emptier lobby server"):format(
                                    table.concat(argument2, ", "),
                                    value
                                )
                            )
                            if context.log then
                                context.log(
                                    "AltFarm",
                                    ("%s could not reach this lobby server - moving to an emptier one so they can follow"):format(
                                        table.concat(argument2, ", ")
                                    )
                                )
                            end
                            task.spawn(function()
                                local success, value3 = pcall(context.MD.lowPopServer)
                                if success then
                                    if value3 then
                                        pcall(function()
                                            getService("TeleportService"):TeleportToPlaceInstance(
                                                77649408247578,
                                                value3,
                                                localPlayer
                                            )
                                        end)
                                    end
                                end
                            end)
                            return true
                        end
                    end
                end
            end
        end
        helper19(
            ("%skeeping the party together - waiting for %s (%.0fs)%s"):format(
                argument4 or "",
                table.concat(argument2, ", "),
                value2 - value,
                argument3 or ""
            )
        )
        return true
    end
    partyQueue.apartTick = function(argument)
        if config.afApartLeave == false then
            return
        end
        if argument - (partyQueue.apartAt or -math.huge) < 2 then
            return
        end
        partyQueue.apartAt = argument
        if sharedValue.place == "Level" or sharedValue.place == "100+" then
            if partyQueue.role() ~= "carry" then
                partyQueue.apart = nil
                return
            elseif not (partyQueue.isHost()) then
                partyQueue.apart = nil
                return
            end
        else
            partyQueue.apart = nil
            return
        end
        if
            context.WSC and context.WSC.holding and context.WSC.holding()
            or context.runComplete and context.runComplete()
        then
            partyQueue.apart = nil
            return
        elseif context.runFailed then
            if context.runFailed() then
                partyQueue.apart = nil
                return
            end
        end
        if not (partyQueue.apart and partyQueue.apart.job == game.JobId) then
            partyQueue.apart = { job = game.JobId, since = {} }
        end
        local value, name2 = 0
        for index, entry in ipairs(partyQueue.leechers()) do
            local value2, value3 = helper11(entry.name), helper16(entry.name)
            index = (if value3 then not value3 else partyQueue.presence(entry.name, config.afOnlineAge or 60))
                or nil
            value3 = index
                and tonumber(index.stuck)
                and os.time() - tonumber(index.stuck) <= (config.afStuckFresh or 120)
            if
                index
                and index.place == "Lobby"
                and index.hop ~= game.JobId
                and not value3
                and not partyQueue.restingNow(entry.name)
            then
                partyQueue.apart.since[value2] = partyQueue.apart.since[value2] or argument
                if argument - partyQueue.apart.since[value2] > value then
                    value, name2 = argument - partyQueue.apart.since[value2], entry.name
                end
            else
                partyQueue.apart.since[value2] = nil
            end
        end
        local value4 = tonumber(config.afApartLeave) or 150
        if name2 then
            if value >= value4 then
                if argument - (partyQueue.apartLeftAt or -math.huge) > 60 then
                    if context.MD then
                        if context.MD.goLobby then
                            partyQueue.apartLeftAt = argument
                            if context.log then
                                context.log(
                                    "AltFarm",
                                    ("%s has been in a lobby for %.0fs and could not get into this run - leaving so the party regroups"):format(
                                        name2,
                                        value
                                    )
                                )
                            end
                            helper19(
                                ("%s could not get into this run - back to the lobby to regroup"):format(
                                    name2
                                )
                            )
                            pcall(context.MD.goLobby)
                        end
                    end
                end
            end
        end
    end
    partyQueue.carryTick = function(argument)
        local value = partyQueue.load()
        if partyQueue.allAtNewSave() then
            partyQueue.newSaveWaitSince = partyQueue.newSaveWaitSince or argument
            if argument - partyQueue.newSaveWaitSince < 120 then
                helper19("the leechers are starting their new saves - holding the party")
                partyQueue.restartWait()
                return
            end
        else
            partyQueue.newSaveWaitSince = nil
        end
        if partyQueue.leaderRejoinTick then
            if partyQueue.leaderRejoinTick(argument) then
                return
            end
        end
        local value2, value3 = {}, {}
        for index, entry in ipairs(partyQueue.others()) do
            index = partyQueue.presence(entry.name, 86400)
            local value4 = index and tonumber(index.resting)
            if value4 then
                if value4 > os.time() then
                    value3[#value3 + 1] = entry.name
                else
                    value2[#value2 + 1] = entry
                end
            else
                value2[#value2 + 1] = entry
            end
        end
        if config.afRestHoldsParty == true then
            local value5, value6 = {}, 0
            for index2, entry2 in ipairs(partyQueue.others()) do
                index2 = partyQueue.presence(entry2.name, 86400)
                local value7 = index2 and tonumber(index2.resting)
                if value7 and value7 > os.time() then
                    value5[#value5 + 1] = entry2.name
                    value6 = math.max(value6, value7 - os.time())
                else
                    if index2 then
                        if index2.dropPending then
                            if os.time() - (tonumber(index2.at) or 0) <= 60 then
                                value5[#value5 + 1] = entry2.name
                            end
                        end
                    end
                end
            end
            if #value5 > 0 then
                helper19(
                    ("holding the party - %s resting after a big drop%s"):format(
                        table.concat(value5, ", "),
                        value6 > 0
                                and (" (%dm %02ds left)"):format(
                                    math.floor(value6 / 60),
                                    math.floor(value6 % 60)
                                )
                            or ""
                    )
                )
                partyQueue.restartWait()
                return
            end
        end
        local value8, value9, value10, value11, value12 = {}, {}, {}, {}
        for index3, entry3 in ipairs(value2) do
            local value13, value14 = helper16(entry3.name), partyQueue.presence(entry3.name)
            index3 = value13 and (value13:FindFirstChild("leaderstats"))
            local valueObject = index3 and (index3:FindFirstChild("Level"))
            index3 = valueObject and tonumber(valueObject.Value) or value14 and tonumber(value14.level) or nil
            value12 = if index3 then math.min(value12 or math.huge, index3) else value12
            index3 = value14
                and tonumber(value14.stuck)
                and os.time() - tonumber(value14.stuck) <= (config.afStuckFresh or 120)
            if value14 then
                if not index3 then
                    if partyQueue.stuckMates then
                        partyQueue.stuckMates[helper11(entry3.name)] = nil
                    end
                end
            end
            if index3 then
                value10[#value10 + 1] = entry3.name .. " (stuck in a teleport - restart its Roblox)"
                partyQueue.stuckMates = partyQueue.stuckMates or {}
                partyQueue.stuckMates[helper11(entry3.name)] = os.time()
            elseif value13 then
                value8[#value8 + 1] = value13
                value11[helper11(entry3.name)] = true
            elseif
                partyQueue.presence(entry3.name, config.afOnlineAge or 60)
                or partyQueue.onItsWay(entry3.name)
            then
                value9[#value9 + 1] = entry3.name
                value11[helper11(entry3.name)] = true
            else
                value10[#value10 + 1] = entry3.name
            end
        end
        local value15 = #value10 > 0
                and (" - not waiting for %s (not running)"):format(table.concat(value10, ", "))
            or ""
        value15 = if #value3 > 0
            then value15 .. (" - %s resting after a big drop"):format(table.concat(value3, ", "))
            else value15
        local value16 = math.min(
            math.max(tonumber(value.waitMax) or 120, 15),
            tonumber(config.afStartWaitCap) or math.huge
        )
        if partyQueue.startClockJob ~= game.JobId then
            partyQueue.startClockJob = game.JobId
            partyQueue.startClock = argument
        end
        local function mapName(argument2)
            local value17 = {}
            for index4, entry4 in ipairs(argument2) do
                index4 = partyQueue.presence(entry4, config.afOnlineAge or 60)
                if index4 then
                    if index4.setup then
                        value17[#value17 + 1] = entry4 .. " (setting up a new account)"
                    end
                end
            end
            return value17
        end
        local value18, value19 =
            math.max(tonumber(config.afSetupWaitMax) or 600, value16), helper17(localPlayer.Name)
        if not value19 then
            partyQueue.lobbySince = nil
            if partyQueue.lastStart > (partyQueue.startClock or math.huge) then
                if argument - partyQueue.lastStart > 15 then
                    partyQueue.startClock = argument
                    partyQueue.hereSince = nil
                end
            end
            partyQueue.hereSince = partyQueue.hereSince or argument
            if #value9 > 0 then
                if argument - partyQueue.hereSince < value16 then
                    if argument - (partyQueue.startClock or argument) < value16 then
                        helper19(
                            ("waiting for %s to reach this server (%.0fs)%s"):format(
                                table.concat(value9, ", "),
                                value16 - (argument - partyQueue.hereSince),
                                value15
                            )
                        )
                        return
                    end
                end
            end
            if #value9 > 0 then
                if partyQueue.togetherWait(argument, value9, value15, "") then
                    return
                end
            end
            value = #value9 > 0 and mapName(value9) or {}
            if #value > 0 then
                if argument - (partyQueue.startClock or argument) < value18 then
                    helper19(
                        ("waiting for %s (%.0fs)%s"):format(
                            table.concat(value, ", "),
                            value18 - (argument - (partyQueue.startClock or argument)),
                            value15
                        )
                    )
                    return
                end
            end
            if argument - partyQueue.lastCreate < 12 then
                return
            end
            local value20 = localPlayer:FindFirstChild("leaderstats")
            local valueObject2 = value20 and (value20:FindFirstChild("Level"))
            value20 = valueObject2 ~= nil and (tonumber(valueObject2.Value) or 0) > 0
            if not value20 then
                if argument - (partyQueue.hereSince or argument) < 20 then
                    helper19("waiting for this account's data to load")
                    return
                end
            end
            if not value20 then
                if not localPlayer.Character then
                    if argument - (partyQueue.hereSince or argument) > (config.afUnloadedHop or 45) then
                        if argument - (partyQueue.unloadedHopAt or -math.huge) > 60 then
                            partyQueue.unloadedHopAt = argument
                            helper19(
                                "this account never loaded into the lobby - moving to a fresh lobby server"
                            )
                            if context.queueLog then
                                local queueLog2, value21 = context.queueLog, { reason = "never loaded" }
                                value21.waited = math.floor(argument - (partyQueue.hereSince or argument))
                                queueLog2("lobby_hop", value21)
                            end
                            pcall(function()
                                getService("TeleportService"):Teleport(77649408247578, localPlayer)
                            end)
                            return
                        end
                    end
                end
            end
            partyQueue.lastCreate = argument
            local value22 = helper4("createLobby")
            if not value22 then
                helper19("the game's createLobby remote is missing")
                return
            end
            local map, diff, value23, value24 = partyQueue.plan()
            local req = math.max(0, math.floor(math.min(value23 or 0, value12 or value23 or 0)))
            helper19(
                ("creating a private %s (%s) party, level %d+%s"):format(
                    tostring(map),
                    tostring(diff),
                    req,
                    value24 and (" - best for level %d"):format(value24) or ""
                )
            )
            local hardcore = false
            pcall(function()
                hardcore = partyQueue.load().hardcore == true
            end)
            if context.queueLog then
                context.queueLog(
                    "create",
                    { map = map, diff = diff, req = req, lo = value24, hardcore = hardcore }
                )
            end
            pcall(function()
                local value17, value25, value26 =
                    writefile, partyQueue.partyFile("af_party"), { map = map, diff = diff }
                value26.at = os.time()
                value17(value25, sharedValue2:JSONEncode(value26))
            end)
            task.spawn(function()
                local success, res =
                    pcall(value22.InvokeServer, value22, map, diff, req, hardcore, true, false)
                if context.queueLog then
                    context.queueLog("create_result", { ok = success, res = res })
                end
                if if success then res ~= true else not success then
                    helper19("the game declined the party: " .. tostring(res))
                end
            end)
            return
        end
        partyQueue.hereSince = nil
        partyQueue.lobbySince = partyQueue.lobbySince or argument
        value9 = value19:FindFirstChild("mapName")
        value = value9 and (value9:FindFirstChild("private"))
        for index5, entry5 in ipairs(value8) do
            if value then
                if not (value:FindFirstChild(entry5.Name)) then
                    if argument - (partyQueue.lastWhite[entry5.Name] or -math.huge) > 4 then
                        partyQueue.lastWhite[entry5.Name] = argument
                        value9 = helper4("addPlayerToWhitelist")
                        if value9 then
                            pcall(value9.FireServer, value9, entry5.Name)
                        end
                    end
                end
            end
        end
        value = helper18(value19)
        for key, entry6 in pairs(value) do
            if key ~= helper11(localPlayer.Name) then
                if not (partyQueue.entry(entry6)) then
                    if argument - (partyQueue.lastKick[entry6] or -math.huge) > 4 then
                        partyQueue.lastKick[entry6] = argument
                        value9 = helper4("kickPlayer")
                        if value9 then
                            pcall(value9.FireServer, value9, entry6)
                        end
                    end
                end
            end
        end
        value9 = {}
        for index6, entry7 in ipairs(value2) do
            if
                not (
                    partyQueue.stuckMates
                    and partyQueue.stuckMates[helper11(entry7.name)]
                    and os.time() - partyQueue.stuckMates[helper11(entry7.name)]
                        <= (config.afStuckFresh or 120)
                )
            then
                if not value[helper11(entry7.name)] then
                    if value11[helper11(entry7.name)] then
                        value9[#value9 + 1] = entry7.name
                    elseif partyQueue.presence(entry7.name, config.afOnlineAge or 60) then
                        value9[#value9 + 1] = entry7.name
                    end
                end
            end
        end
        value11 = argument - partyQueue.lobbySince
        if
            #value9 > 0
            and value11 < value16
            and (argument - (partyQueue.startClock or argument) < value16 or value11 < 15)
        then
            helper19(
                ("party open - waiting for %s (%.0fs)%s"):format(
                    table.concat(value9, ", "),
                    value16 - value11,
                    value15
                )
            )
            return
        end
        value = #value9 > 0 and mapName(value9) or {}
        if #value > 0 then
            if argument - (partyQueue.startClock or argument) < value18 then
                helper19(
                    ("party open - waiting for %s (%.0fs)%s"):format(
                        table.concat(value, ", "),
                        value18 - (argument - (partyQueue.startClock or argument)),
                        value15
                    )
                )
                return
            end
        end
        if #value9 > 0 then
            if partyQueue.togetherWait(argument, value9, value15, "party open - ") then
                return
            end
        end
        partyQueue.togetherHops = 0
        if context.AS then
            if context.AS.holdStart then
                if context.AS.holdStart() then
                    helper19("selling in the lobby before the run starts")
                    return
                end
            end
        end
        if argument - partyQueue.lastStart < 10 then
            return
        end
        partyQueue.lastStart = argument
        value8 = helper4("startDungeon")
        if context.queueLog then
            mapName = value19:FindFirstChild("mapName")
            context.queueLog("start", { lobbyMap = mapName and mapName.Value, missing = #value9 })
        end
        if value8 then
            pcall(value8.FireServer, value8)
        end
        helper19(
            #value9 == 0 and "everyone is in - starting"
                or ("starting without %s"):format(table.concat(value9, ", "))
        )
        if #value9 > 0 or #value10 > 0 or #value3 > 0 then
            if partyQueue.saidWithout ~= partyQueue.lobbySince then
                if context.log then
                    partyQueue.saidWithout = partyQueue.lobbySince
                    context.log(
                        "AltFarm",
                        ("starting after %.0fs%s%s"):format(
                            argument - (partyQueue.startClock or argument),
                            #value9 > 0 and " without " .. table.concat(value9, ", ") or "",
                            value15
                        )
                    )
                end
            end
        end
    end
    partyQueue.leechTick = function(argument)
        if partyQueue.stuckAt then
            helper19(
                "stuck in a teleport that never finished - restart this Roblox (the party goes on without it)"
            )
            return
        end
        local value = partyQueue.carry()
        if not value then
            helper19("no leader - press a crown in Parties & Runs")
            return
        end
        local value2 = helper16(value.name)
        if not value2 then
            local value3 = partyQueue.presence(value.name)
            if not value3 then
                helper19(("waiting for %s to come online"):format(value.name))
                return
            end
            if value3.place ~= "Lobby" then
                if value3.place == "Level" or value3.place == "100+" then
                    if partyQueue.requestRejoin then
                        if partyQueue.requestRejoin(value.name, value3, argument) then
                            return
                        end
                    end
                end
                helper19(("%s is in a run - waiting for it to come back"):format(value.name))
                return
            end
            if value3.job then
                if value3.job ~= "" then
                    if value3.job ~= game.JobId then
                        if argument - partyQueue.lastHop > 25 then
                            partyQueue.lastHop = argument
                            partyQueue.hopJob = value3.job
                            helper19(("moving to %s's lobby server"):format(value.name))
                            pcall(function()
                                getService("TeleportService"):TeleportToPlaceInstance(
                                    77649408247578,
                                    value3.job,
                                    localPlayer
                                )
                            end)
                        end
                    end
                end
            end
            return
        end
        local value4 = helper17(value2.Name)
        if not value4 then
            helper19(("with %s - waiting for its party"):format(value.name))
            return
        end
        if helper18(value4)[helper11(localPlayer.Name)] then
            helper19(("in %s's party - waiting for the start"):format(value.name))
            return
        end
        local mapName = value4:FindFirstChild("mapName")
        local valueObject, value5 =
            mapName and (mapName:FindFirstChild("minLevelReq")), localPlayer:FindFirstChild("leaderstats")
        value4 = value5 and (value5:FindFirstChild("Level"))
        value5 = value4 and tonumber(value4.Value) or 0
        if valueObject then
            if tonumber(valueObject.Value) then
                if value5 < tonumber(valueObject.Value) then
                    helper19(
                        ("the party needs level %d, this account is %d"):format(
                            tonumber(valueObject.Value),
                            value5
                        )
                    )
                    return
                end
            end
        end
        value5 = mapName and (mapName:FindFirstChild("private"))
        if value5 then
            if value5.Value == true then
                value4 = localPlayer.Name
                if not (value5:FindFirstChild(value4)) then
                    helper19("waiting for the carry to whitelist this account")
                    return
                end
            end
        end
        if argument - partyQueue.lastJoin < 5 then
            return
        end
        partyQueue.lastJoin = argument
        helper19(("joining %s's party"):format(value.name))
        local value6 = helper4("joinDungeon")
        if value6 then
            task.spawn(function()
                pcall(value6.InvokeServer, value6, value2.Name)
            end)
        end
    end
    partyQueue.slotInfo = function()
        local value = helper4("getCharacterSlots")
        if not value then
            return nil
        end
        local success, value2 = pcall(value.InvokeServer, value)
        if success then
            if type(value2) == "table" then
                return value2
            end
        end
        return nil
    end
    partyQueue.newSaveAt = function()
        local value = partyQueue.load()
        if value.newSave ~= true then
            return nil
        end
        return tonumber(value.newSaveLevel) or 100
    end
    partyQueue.pendingNewSave = function()
        local value = partyQueue.newSaveAt()
        if not value then
            return false
        end
        for index, account in ipairs(partyQueue.load().accounts) do
            if account.enabled ~= false then
                if account.role == "leech" then
                    index = partyQueue.presence(account.name, 120)
                    if index then
                        if tonumber(index.level) then
                            if tonumber(index.level) >= value then
                                if index.noFreeSlot ~= true then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    partyQueue.allAtNewSave = partyQueue.pendingNewSave
    partyQueue.newSaveTick = function(newSaveTryAt)
        local value = partyQueue.newSaveAt()
        if partyQueue.role() ~= "leech" then
            return false
        elseif value then
            if partyQueue.noFreeSlot then
                return false
            elseif partyQueue.newSaveGaveUp then
                return false
            end
        else
            return false
        end
        local value2 = 0
        pcall(function()
            value2 = tonumber(localPlayer.leaderstats.Level.Value) or 0
        end)
        if value2 < value then
            return false
        end
        if newSaveTryAt - (partyQueue.newSaveTryAt or -math.huge) < 30 then
            helper19("starting a new save...")
            return true
        end
        partyQueue.newSaveTries = (partyQueue.newSaveTries or 0) + 1
        if partyQueue.newSaveTries > (tonumber(config.afNewSaveTries) or 4) then
            partyQueue.newSaveGaveUp = true
            helper19("new save: the switch did not go through - staying on this save for now")
            if context.log then
                context.log(
                    "AltFarm",
                    "new save: the slot switch did not go through after 4 tries - staying on this save for now"
                )
            end
            return false
        end
        partyQueue.newSaveTryAt = newSaveTryAt
        newSaveTryAt = partyQueue.slotInfo()
        if not newSaveTryAt then
            helper19("new save: could not read the character slots")
            return true
        end
        local from = tonumber(newSaveTryAt.selectedSlot)
        local value3
        value = tonumber(newSaveTryAt.maxSlots) or 5
        for index = 1, value, 1 do
            local value4 = newSaveTryAt.slots
                and (newSaveTryAt.slots[index] or newSaveTryAt.slots[tostring(index)])
            if value4 and value4.unlocked == true and value4.created ~= true then
                value3 = index
                break
            end
        end
        if not value3 then
            partyQueue.noFreeSlot = true
            helper19("new save: no free unlocked slot left - staying on this one")
            return false
        end
        partyQueue.noFreeSlotSeen = nil
        local fromLevel = 0
        pcall(function()
            fromLevel = tonumber(localPlayer.leaderstats.Level.Value) or 0
        end)
        helper19(
            ("new save: switching from save %s (Lv %d) to a fresh one in slot %d"):format(
                tostring(from),
                fromLevel,
                value3
            )
        )
        local value5 = helper4("selectCharacterSlot")
        if not value5 then
            return true
        end
        task.spawn(function()
            local success, value6 = pcall(value5.InvokeServer, value5, value3)
            if success and value6 then
                task.wait(3)
                local value7 = helper4("characterSwapClosed")
                if value7 then
                    pcall(value7.FireServer, value7)
                end
                partyQueue.mySlot = value3
                pcall(function()
                    writefile(
                        "HarvardLabs/data/af_" .. helper11(localPlayer.Name) .. ".json",
                        sharedValue2:JSONEncode({
                            name = localPlayer.Name,
                            level = 1,
                            place = sharedValue.place or "?",
                            job = game.JobId,
                            at = os.time(),
                            slot = value3,
                        })
                    )
                end)
                if context.queueLog then
                    context.queueLog("new_save", { from = from, to = value3, fromLevel = fromLevel })
                end
                if context.WH then
                    if context.WH.newSave then
                        pcall(context.WH.newSave, localPlayer.Name, fromLevel, from, value3)
                    end
                end
            else
                helper19("new save: the game declined the slot switch (" .. tostring(value6) .. ")")
            end
        end)
        return true
    end
    task.spawn(function()
        task.wait(10 + math.random() * 5)
        for index = 1, 60, 1 do
            if not runtimeState.configAsk then
                break
            end
            task.wait(5)
        end
        if runtimeState.destroyed then
            return
        elseif config.autoQueue ~= true then
            return
        end
        for index2 = 1, 3, 1 do
            partyQueue.loadReal(true)
            if partyQueue.doc then
                if partyQueue.partyOf(localPlayer.Name, partyQueue.doc) then
                    break
                end
            end
            pcall(partyQueue.soloParty, {
                auto = false,
                map = config.autoQueueMap or "Desert Temple",
                difficulty = config.autoQueueDifficulty or "Nightmare",
                replay = config.autoQueueReplay ~= false,
            })
            task.wait(2 + math.random() * 3)
        end
        partyQueue.loadReal(true)
        if partyQueue.doc then
            if partyQueue.partyOf(localPlayer.Name, partyQueue.doc) then
                config.autoQueue = false
                if context.saveConfig then
                    pcall(context.saveConfig)
                end
                if context.log then
                    context.log(
                        "Party",
                        "runs only start from a party now - this account has a party of its own (see Parties & Runs)"
                    )
                end
                if context.refreshQueueMode then
                    pcall(context.refreshQueueMode)
                end
            end
        end
    end)
    partyQueue.lobbyTick = function(argument)
        if context.WSC then
            if context.WSC.holding() then
                helper19("REMOTE HOLD - the party waits until the panel releases this account")
                return
            end
        end
        local value = partyQueue.role()
        if not value then
            return
        end
        partyQueue.refreshLevels()
        if value == "leech" then
            if partyQueue.newSaveTick(argument) then
                return
            end
        end
        pcall(partyQueue.noteStandIn)
        if partyQueue.isHost() then
            partyQueue.carryTick(argument)
        else
            partyQueue.leechTick(argument)
        end
    end
    partyQueue.noteStandIn = function()
        local standInFor = partyQueue.load()
        local value, value2, value3 =
            partyQueue.crowned(standInFor), partyQueue.carry(standInFor), helper11(localPlayer.Name)
        standInFor = value
                and value2
                and helper11(value2.name) == value3
                and helper11(value.name) ~= value3
                and value.name
            or nil
        if standInFor == partyQueue.standInFor then
            return
        end
        if standInFor then
            if context.log then
                context.log(
                    "AltFarm",
                    ("%s is resting after a big drop - this account hosts the party until it is back"):format(
                        standInFor
                    )
                )
            end
            if context.notify then
                context.notify(
                    "party",
                    "Hosting the party",
                    ("%s is resting after a big drop - this account hosts until it is back."):format(
                        standInFor
                    ),
                    8
                )
            end
        elseif partyQueue.standInFor then
            if context.log then
                context.log(
                    "AltFarm",
                    ("%s's rest is over - it hosts the party again"):format(partyQueue.standInFor)
                )
            end
        end
        partyQueue.standInFor = standInFor
    end
    context.runComplete = function()
        if context.rodinAlive ~= nil then
            if context.rodinAlive() then
                return false
            end
        end
        local valueObject, valueObject2 = helper6(), helper5("bonusBossVotingActive")
        return valueObject ~= nil and valueObject.Value == true
            or valueObject2 ~= nil and valueObject2.Value == true
            or (helper7())
    end
    context.QUEUE_MAPS = {
        "Desert Temple",
        "Winter Outpost",
        "Pirate Island",
        "King's Castle",
        "The Underworld",
        "Samurai Palace",
        "The Canals",
        "Steampunk Sewers",
        "Ghastly Harbor",
        "Orbital Outpost",
        "Volcanic Chambers",
        "Enchanted Forest",
        "Aquatic Temple",
        "Northern Lands",
        "Gilded Skies",
        "Pumpkin King",
    }
    context.EVENT_DIFF = { ["Pumpkin King"] = "Nightmare" }
    context.isEvent = function()
        local dungeonName = workspace:FindFirstChild("dungeonName")
        return dungeonName ~= nil and context.EVENT_DIFF[tostring(dungeonName.Value)] ~= nil
    end
    context.QUEUE_DIFFICULTIES = { "Easy", "Medium", "Hard", "Insane", "Nightmare" }

return function(context)
end
