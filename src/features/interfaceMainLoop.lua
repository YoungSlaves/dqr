-- Extracted verbatim from harvardd.lua lines 142557-164652; presentation owned elsewhere.
return function(context)
    local uiLibrary = context.UIKit
    local theme = context.UIKit.Theme
    local config = context.CFG
    local runtimeState = context.RT
    local hazardReader = context.RD
    local uiSettings = context.UI
    local localPlayer = context.LocalPlayer
    local runService = context.RunService
    local userInputService = context.UserInputService
    local workspaceService = context.Workspace
    local sliderConnections = context.sliderConnections
    local releaseMover = context.releaseMover
    local restoreWalkSpeed = context.restoreWalkSpeed
    local readerStop = context.readerStop
    local clearDrawing = context.clearDrawing
    pcall(function()
        local virtualUser = getService("VirtualUser")
        sliderConnections[#sliderConnections + 1] = localPlayer.Idled:Connect(function()
            pcall(function()
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end)
    local saveConfig = context.saveConfig
    local loadConfig = context.loadConfig
    local ver, sharedValue, sharedValue2, sharedValue3 = context.SCRIPT_VERSION, {}, {}, false
    local function helper(argument)
        sharedValue[#sharedValue + 1] = argument
        return argument
    end
    local function refreshAll()
        for index, entry in ipairs(sharedValue) do
            if type(entry) == "table" then
                if entry.render then
                    pcall(entry.render)
                end
            end
        end
    end
    context.refreshAll = refreshAll
    local function helper2()
        local L, value, value2 = context.character()
        pcall(releaseMover, value, value2)
        return value
    end
    local sharedValue4 = { saved = {}, box = nil, coreChanged = {} }
    sharedValue4.lastApply = -math.huge
    sharedValue4.on = false
    local sharedValue5 = getService("Players")
    local sharedValue6 = getService("StarterGui")
    local visualRoot = context.visualRoot
    local function helper3(argument, argument2, argument3)
        if argument[argument2] == argument3 then
            return
        end
        local value = sharedValue4.saved[argument]
        if not value then
            value = {}
            sharedValue4.saved[argument] = value
        end
        if value[argument2] == nil then
            value[argument2] = argument[argument2]
        end
        argument[argument2] = argument3
    end
    sharedValue4.fakes = sharedValue4.fakes or {}
    local function helper4(argument, text)
        if argument then
            if not (argument:IsA("TextLabel")) then
                helper3(argument, "Visible", false)
                return
            end
        else
            helper3(argument, "Visible", false)
            return
        end
        text = tostring(text or "")
        if text == "" then
            helper3(argument, "Visible", false)
            return
        end
        helper3(argument, "TextTransparency", 1)
        helper3(argument, "TextStrokeTransparency", 1)
        local value = sharedValue4.fakes[argument]
        if if value then not value.Parent else not value then
            value = argument:Clone()
            for index, child in ipairs(value:GetChildren()) do
                if not (child:IsA("UIStroke")) then
                    if not (child:IsA("UICorner")) then
                        if not (child:IsA("UIGradient")) then
                            if not (child:IsA("UITextSizeConstraint")) then
                                if not (child:IsA("UIPadding")) then
                                    child:Destroy()
                                end
                            end
                        end
                    end
                end
            end
            value.Name = "streamerFake"
            value.TextTransparency, value.TextStrokeTransparency = 0, argument.TextStrokeTransparency
            value.Visible = true
            value.ZIndex = argument.ZIndex + 1
            value.Parent = argument.Parent
            sharedValue4.fakes[argument] = value
        end
        if value.Text ~= text then
            value.Text = text
        end
    end
    sharedValue4.plates = sharedValue4.plates or {}
    sharedValue4.plateKeys = sharedValue4.plateKeys
        or { name = true, title = true, vip = true, healthamount = true, level = true }
    local function helper5(argument)
        local value, value2 = sharedValue4.plates[argument]
        if value then
            value2 = value
        else
            for key, plate in pairs(sharedValue4.plates) do
                local value3 = game
                if not (key:IsDescendantOf(value3)) then
                    for index, conn in ipairs(plate.conns) do
                        pcall(conn.Disconnect, conn)
                    end
                    sharedValue4.plates[key] = nil
                end
            end
            value2 = { list = {}, dirty = true, at = 0, conns = {} }
            local function helper6(argument2)
                if runtimeState.destroyed then
                    for index2, conn2 in ipairs(value2.conns) do
                        pcall(conn2.Disconnect, conn2)
                    end
                    return
                end
                if not value2.dirty then
                    if argument2:IsA("GuiObject") then
                        value2.dirty = true
                    end
                end
            end
            value2.conns[1] = argument.DescendantAdded:Connect(helper6)
            value2.conns[2] = argument.DescendantRemoving:Connect(helper6)
            sharedValue4.plates[argument] = value2
        end
        local now = os.clock()
        if value2.dirty or now - value2.at > 5 then
            value2.dirty = false
            value2.at = now
            local list, plateKeys = {}, sharedValue4.plateKeys
            for index3, descendant in ipairs(argument:GetDescendants()) do
                if descendant:IsA("GuiObject") then
                    if descendant.Name ~= "streamerFake" then
                        index3 = string.lower(descendant.Name)
                        if plateKeys[index3] then
                            list[#list + 1] = descendant
                            list[#list + 1] = index3
                        end
                    end
                end
            end
            value2.list = list
        end
        return value2.list
    end
    local function helper7(argument, argument2)
        if not argument then
            return
        end
        local value = helper5(argument)
        for index = 1, #value, 2 do
            local value2, value3 = value[index], value[index + 1]
            if value3 == "name" then
                if argument2 then
                    if config.streamerName then
                        helper4(value2, config.streamerNameText)
                    end
                else
                    helper3(value2, "Visible", false)
                end
            elseif value3 == "title" or value3 == "vip" then
                if argument2 then
                    if config.streamerName then
                        helper3(value2, "Visible", false)
                    end
                else
                    helper3(value2, "Visible", false)
                end
            end
            if argument2 then
                if value3 == "healthamount" then
                    if config.streamerHealth then
                        helper4(value2, config.streamerHealthText)
                    end
                end
            end
            if
                argument2
                and value3 == "level"
                and config.streamerLevel
                and (config.streamerLevelText or "") ~= ""
            then
                helper4(value2, config.streamerLevelText)
            elseif value3 == "level" and config.streamerLevel then
                argument = value2
                for index2 = 1, 2, 1 do
                    index2 = argument.Parent
                    if index2 then
                        if index2:IsA("GuiObject") then
                            if index2.Parent then
                                if not (index2.Parent:IsA("GuiObject")) then
                                    break
                                end
                            else
                                break
                            end
                        else
                            break
                        end
                    else
                        break
                    end
                    argument = index2
                end
                helper3(argument, "Visible", false)
            end
        end
    end
    local function helper8(char)
        local body, body2 = sharedValue4.body
        if if body then body.char ~= char else not body then
            if body then
                for index, conn in ipairs(body.conns) do
                    pcall(conn.Disconnect, conn)
                end
            end
            body2 = { char = char, dirty = true, list = {}, conns = {} }
            local function helper6(argument)
                if runtimeState.destroyed then
                    for index2, conn2 in ipairs(body2.conns) do
                        pcall(conn2.Disconnect, conn2)
                    end
                    return
                end
                if body2.dirty then
                    return
                end
                if argument:IsA("BasePart") then
                    body2.dirty = true
                elseif argument:IsA("Decal") then
                    body2.dirty = true
                elseif argument:IsA("Texture") then
                    body2.dirty = true
                elseif argument:IsA("ParticleEmitter") then
                    body2.dirty = true
                elseif argument:IsA("Trail") then
                    body2.dirty = true
                elseif argument:IsA("Beam") then
                    body2.dirty = true
                end
            end
            body2.conns[1] = char.DescendantAdded:Connect(helper6)
            body2.conns[2] = char.DescendantRemoving:Connect(helper6)
            sharedValue4.body = body2
        else
            body2 = body
        end
        if body2.dirty then
            body2.dirty = false
            local list = {}
            for index3, descendant in ipairs(char:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    list[#list + 1] = descendant
                    list[#list + 1] = 1
                elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                    list[#list + 1] = descendant
                    list[#list + 1] = 2
                elseif
                    descendant:IsA("ParticleEmitter")
                    or descendant:IsA("Trail")
                    or descendant:IsA("Beam")
                then
                    list[#list + 1] = descendant
                    list[#list + 1] = 3
                end
            end
            body2.list = list
        end
        return body2.list
    end
    local function helper9(streamer)
        local rootPart, value = streamer:FindFirstChild("HumanoidRootPart"), helper8(streamer)
        for index = 1, #value, 2 do
            local value2, value3 = value[index], value[index + 1]
            if value3 == 1 then
                if value2 ~= rootPart then
                    helper3(value2, "Transparency", 1)
                    helper3(value2, "CastShadow", false)
                end
            elseif value3 == 2 then
                helper3(value2, "Transparency", 1)
            else
                helper3(value2, "Enabled", false)
            end
        end
        if rootPart then
            streamer = sharedValue4.box
            if if streamer then not streamer.Parent else not streamer then
                streamer = Instance.new("Part")
                streamer.Name = "streamer"
                streamer.Anchored = true
                streamer.CanCollide = false
                streamer.CanQuery = false
                streamer.CanTouch = false
                streamer.CastShadow = false
                streamer.Material, streamer.Color, streamer.Size =
                    Enum.Material.SmoothPlastic,
                    config.streamerBodyColor or Color3.new(0, 0, 0),
                    Vector3.new(2, 5, 2)
                streamer.Parent = visualRoot()
                sharedValue4.box = streamer
            end
            streamer.CFrame = rootPart.CFrame
            if config.streamerBodyColor then
                if streamer.Color ~= config.streamerBodyColor then
                    streamer.Color = config.streamerBodyColor
                end
            end
        end
    end
    local function helper10()
        local playerGui = localPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            return
        end
        local value = playerGui:FindFirstChild("playerStatus")
        value = value and (value:FindFirstChild("Frame"))
        if value then
            local value2, healthFrame =
                value:FindFirstChild("playerName"), value:FindFirstChild("healthFrame")
            if value2 then
                if config.streamerName then
                    helper4(value2, config.streamerNameText)
                end
            end
            if healthFrame then
                if config.streamerHealth then
                    value2 = healthFrame:FindFirstChild("health")
                    if (config.streamerHealthText or "") ~= "" then
                        if value2 then
                            helper4(value2, config.streamerHealthText)
                        else
                            helper3(healthFrame, "Visible", false)
                        end
                    else
                        helper3(healthFrame, "Visible", false)
                    end
                end
            end
        end
        if value then
            if config.streamerLevel then
                local value3 = value:FindFirstChild("portraitBorder")
                local value4, value5 =
                    value3 and (value3:FindFirstChild("portrait")),
                    context.customLogo and context.customLogo() or nil
                if value3 then
                    if value5 then
                        if value4 then
                            helper3(value4, "Image", value5)
                            helper3(value4, "ImageColor3", Color3.new(1, 1, 1))
                            helper3(value4, "ScaleType", Enum.ScaleType.Crop)
                        else
                            helper3(value3, "Visible", false)
                        end
                    else
                        helper3(value3, "Visible", false)
                    end
                end
                value3 = value:FindFirstChild("levelBorder")
                value5 = value3 and (value3:FindFirstChild("level"))
                if (config.streamerLevelText or "") ~= "" then
                    if value5 then
                        helper4(value5, config.streamerLevelText)
                    elseif value3 then
                        helper3(value3, "Visible", false)
                    end
                elseif value3 then
                    helper3(value3, "Visible", false)
                end
            end
            if config.streamerWealth then
                local moneyMain, xpFrame = value:FindFirstChild("moneyMain"), value:FindFirstChild("xpFrame")
                local value6, value7, value8 =
                    moneyMain and (moneyMain:FindFirstChild("TextLabel")),
                    moneyMain and (moneyMain:FindFirstChild("GemsText")),
                    xpFrame and (xpFrame:FindFirstChild("xp"))
                if moneyMain then
                    if
                        ((config.streamerGoldText or "") ~= "" or (config.streamerGemsText or "") ~= "")
                        and value6
                    then
                        if value7 then
                            helper4(value6, config.streamerGoldText)
                            helper4(value7, config.streamerGemsText)
                        else
                            helper3(moneyMain, "Visible", false)
                        end
                    else
                        helper3(moneyMain, "Visible", false)
                    end
                end
                if xpFrame then
                    if (config.streamerXpText or "") ~= "" and value8 then
                        helper4(value8, config.streamerXpText)
                    else
                        helper3(xpFrame, "Visible", false)
                    end
                end
            end
        end
        if config.streamerName then
            local value9 = playerGui:FindFirstChild("Cmdr")
            local value10 = value9 and (value9:FindFirstChild("Frame"))
            value10 = value10 and (value10:FindFirstChild("Entry"))
            value9 = value10 and (value10:FindFirstChildWhichIsA("TextLabel"))
            if value9 then
                helper3(value9, "Visible", false)
            end
        end
        local value11, value12 =
            playerGui:FindFirstChild("playerStatsLeaderboard"),
            context.isAlt1186 ~= nil and context.isAlt1186()
        if value11 and (config.streamerLeaderboard or value12) then
            helper3(value11, "Enabled", false)
        end
        if config.streamerLeaderboard or value12 then
            value11 = playerGui:FindFirstChild("playerStatus")
            local value13 = value11
                and value11:FindFirstChild("Frame")
                and value11.Frame:FindFirstChild("teammateHolder")
            if value13 then
                helper3(value13, "Visible", false)
            end
            value13 = playerGui:FindFirstChild("leaderboard")
            if value13 then
                if value13:IsA("ScreenGui") then
                    helper3(value13, "Enabled", false)
                end
            end
        end
    end
    local function helper11(argument, argument2)
        local success, value = pcall(sharedValue6.GetCoreGuiEnabled, sharedValue6, argument)
        if not success then
            return
        end
        if argument2 then
            if value then
                sharedValue4.coreChanged[argument] = true
                pcall(sharedValue6.SetCoreGuiEnabled, sharedValue6, argument, false)
            end
        elseif sharedValue4.coreChanged[argument] then
            sharedValue4.coreChanged[argument] = nil
            pcall(sharedValue6.SetCoreGuiEnabled, sharedValue6, argument, true)
        end
    end
    local function helper12()
        for key, entry in pairs(sharedValue4.saved) do
            for key2, entry2 in pairs(entry) do
                pcall(function()
                    key[key2] = entry2
                end)
            end
        end
        table.clear(sharedValue4.saved)
        for key3, entry3 in pairs(sharedValue4.fakes or {}) do
            pcall(function()
                entry3:Destroy()
            end)
        end
        sharedValue4.fakes = {}
        for key4, entry4 in pairs(sharedValue4.plates or {}) do
            for index, conn in ipairs(entry4.conns) do
                pcall(conn.Disconnect, conn)
            end
        end
        sharedValue4.plates = {}
        if sharedValue4.body then
            for index2, conn2 in ipairs(sharedValue4.body.conns) do
                pcall(conn2.Disconnect, conn2)
            end
            sharedValue4.body = nil
        end
        if sharedValue4.box then
            sharedValue4.box:Destroy()
            sharedValue4.box = nil
        end
        helper11(Enum.CoreGuiType.PlayerList, false)
        helper11(Enum.CoreGuiType.Chat, false)
        sharedValue4.on = false
    end
    local function helper13(lastApply)
        if not config.streamer then
            if sharedValue4.on then
                helper12()
            end
            return
        end
        sharedValue4.on = true
        local value = localPlayer.Character
        local value2 = value and (value:FindFirstChild("HumanoidRootPart"))
        if sharedValue4.box then
            if sharedValue4.box.Parent then
                if value2 then
                    sharedValue4.box.CFrame = value2.CFrame
                end
            end
        end
        if lastApply - sharedValue4.lastApply < 0.5 then
            return
        end
        sharedValue4.lastApply = lastApply
        for entry in pairs(sharedValue4.saved) do
            if not entry.Parent then
                sharedValue4.saved[entry] = nil
            end
        end
        if value then
            if config.streamerBody then
                helper9(value)
            elseif sharedValue4.box then
                sharedValue4.box:Destroy()
                sharedValue4.box = nil
            end
            helper7(value:FindFirstChild("playerNameplate"), true)
        end
        helper10()
        value = context.isAlt1186 ~= nil and context.isAlt1186()
        if config.streamerOthers or value then
            for index, entry2 in ipairs(sharedValue5:GetPlayers()) do
                if entry2 ~= localPlayer then
                    if entry2.Character then
                        helper7(entry2.Character:FindFirstChild("playerNameplate"), false)
                    end
                end
            end
        end
        helper11(Enum.CoreGuiType.PlayerList, config.streamerLeaderboard == true or value)
        helper11(Enum.CoreGuiType.Chat, config.streamerChat == true)
    end
    context.streamerRefresh = function()
        helper12()
        sharedValue4.lastApply = -math.huge
    end
    do
        local function helper14(argument)
            runtimeState.speedOff = not argument
            context.log(
                "Speed",
                argument and ("escape speed ON, %.0f (fixed)"):format(config.tweenEscape)
                    or "escape speed OFF (walking pace)"
            )
        end
        sliderConnections[#sliderConnections + 1] = userInputService.InputBegan:Connect(
            function(input, argument)
                if argument then
                    return
                end
                if input.KeyCode == Enum.KeyCode.F9 then
                    helper14(runtimeState.speedOff == true)
                end
            end
        )
        sliderConnections[#sliderConnections + 1] = localPlayer.Chatted:Connect(function(argument)
            local value = tostring(argument):match("^/speed%s*(%S*)")
            if not value then
                return
            end
            argument = string.lower(value)
            if argument == "" then
                helper14(runtimeState.speedOff == true)
            elseif argument == "on" then
                helper14(true)
            elseif argument == "off" then
                helper14(false)
            elseif tonumber(argument) then
                context.log(
                    "Speed",
                    ("the escape speed is fixed at %.0f; nothing sets it"):format(config.tweenEscape)
                )
            end
        end)
    end
    local function destructScript()
        if runtimeState.destroyed then
            return
        end
        runtimeState.destroyed = true
        pcall(saveConfig)
        pcall(function()
            local hlBeamWalls = workspaceService:FindFirstChild("HLBeamWalls")
            if hlBeamWalls then
                hlBeamWalls:Destroy()
            end
        end)
        pcall(function()
            if context.bugStop then
                context.bugStop("the script was closed")
            end
        end)
        pcall(function()
            if context.bugGui then
                context.bugGui:Destroy()
                context.bugGui = nil
            end
        end)
        for index, sliderConnection in ipairs(sliderConnections) do
            pcall(sliderConnection.Disconnect, sliderConnection)
        end
        table.clear(sliderConnections)
        local value = { "hudConnection", "mainConnection", "streamerConnection" }
        for index2, entry in ipairs(value) do
            if runtimeState[entry] then
                runtimeState[entry]:Disconnect()
                runtimeState[entry] = nil
            end
        end
        pcall(helper12)
        pcall(function()
            if uiLibrary then
                if uiLibrary.stopSweeps then
                    uiLibrary.stopSweeps()
                end
            end
        end)
        pcall(function()
            if context.WALLS then
                (context.WALLS.detach or context.WALLS.stop)()
            end
        end)
        pcall(restoreWalkSpeed, helper2())
        pcall(function()
            if context.LC then
                context.LC.stop()
            end
        end)
        pcall(readerStop)
        pcall(function()
            if context.BB then
                context.BB.stop()
            end
        end)
        pcall(function()
            if context.applyBirdsEye then
                context.applyBirdsEye()
            end
        end)
        pcall(clearDrawing)
        pcall(function()
            getService("RunService"):Set3dRenderingEnabled(true)
        end)
        pcall(function()
            if context.rodinTags then
                context.rodinTags(false)
            end
        end)
        pcall(function()
            if context.rodinJanitor then
                context.rodinJanitor(false)
            end
        end)
        pcall(function()
            if context.AC then
                if context.AC.restore then
                    context.AC.restore()
                end
            end
        end)
        pcall(function()
            if context.MM then
                if context.MM.stop3D then
                    context.MM.stop3D()
                end
            end
        end)
        pcall(function()
            if context.MM then
                if context.MM.stopGui then
                    context.MM.stopGui()
                end
            end
        end)
        pcall(function()
            if context.ClassicPlus then
                if context.ClassicPlus.destroy then
                    context.ClassicPlus.destroy()
                end
            end
        end)
        pcall(function()
            if context.UIMotion then
                if context.UIMotion.destroy then
                    context.UIMotion.destroy()
                end
            end
        end)
        value = { "visualRoot", "scriptGui" }
        for index3, entry2 in ipairs(value) do
            if runtimeState[entry2] then
                runtimeState[entry2]:Destroy()
                runtimeState[entry2] = nil
            end
        end
        if _G.DungeonAutofarmDestruct == destructScript then
            _G.DungeonAutofarmDestruct = nil
        end
        if _G.DungeonAutofarmVersion == ver then
            _G.DungeonAutofarmVersion = nil
        end
    end
    _G.DungeonAutofarmDestruct = destructScript
    local function helper15(argument, argument2, argument3, argument4, argument5, argument6)
        return helper(uiLibrary.toggle(argument, argument2, function()
            return config[argument3]
        end, function(argument7)
            config[argument3] = argument7
            if argument6 then
                argument6(argument7)
            end
            saveConfig()
        end, argument4, argument5))
    end
    local sharedValue7 = false
    local function helper16()
        if sharedValue7 then
            return
        end
        sharedValue7 = true
        task.delay(0.5, function()
            sharedValue7 = false
            pcall(saveConfig)
        end)
    end
    local function helper17(
        argument,
        argument2,
        argument3,
        argument4,
        argument5,
        argument6,
        argument7,
        argument8,
        argument9,
        argument10
    )
        return helper(
            uiLibrary.slider(argument, argument2, argument3, argument4, argument5, argument6, function()
                return config[argument7]
            end, function(argument11)
                config[argument7] = argument11
                helper16()
            end, argument8, argument9, argument10)
        )
    end
    local sharedValue8, sharedValue9 =
        context.PATH.configs .. "/profiles.json", { current = "Default", list = {} }
    local sharedValue10 = tostring(getService("Players").LocalPlayer.UserId)
    local function helper18()
        pcall(function()
            local value = context.readJson(sharedValue8, "HarvardLabs_configs.json")
            if type(value) == "table" then
                if type(value.list) == "table" then
                    sharedValue9 = value
                    local value2 = sharedValue9
                    value2.current = value2.current or "Default"
                end
            end
        end)
        if type(sharedValue9.currentBy) ~= "table" then
            sharedValue9.currentBy = {}
        end
        if sharedValue9.currentBy[sharedValue10] == nil then
            sharedValue9.currentBy[sharedValue10] = sharedValue9.current or "Default"
        end
        local value3 = sharedValue9
        value3.current = value3.currentBy[sharedValue10]
        if sharedValue9.current ~= "Default" then
            local iterateArray, list, value4 = ipairs, sharedValue9.list, false
            for key, entry in iterateArray(list) do
                if entry.name == sharedValue9.current then
                    value4 = true
                    break
                end
            end
            if not value4 then
                sharedValue9.current = "Default"
            end
        end
    end
    local function helper19()
        pcall(context.ensureFolders)
        if type(sharedValue9.currentBy) ~= "table" then
            sharedValue9.currentBy = {}
        end
        sharedValue9.currentBy[sharedValue10] = sharedValue9.current or "Default"
        pcall(function()
            local value = context.readJson(sharedValue8, "HarvardLabs_configs.json")
            if type(value) == "table" and type(value.currentBy) == "table" then
                local iteratePairs, currentBy = pairs, value.currentBy
                for key, entry in iteratePairs(currentBy) do
                    if key ~= sharedValue10 then
                        sharedValue9.currentBy[key] = entry
                    end
                end
            end
        end)
        pcall(function()
            writefile(sharedValue8, context.HttpService:JSONEncode(sharedValue9))
        end)
    end
    local function helper20(argument)
        local value, value2 = {}, { "sellLegendary", "sellUltimate" }
        for index, entry in ipairs(value2) do
            if argument[entry] == true then
                if config[entry] ~= true then
                    value[#value + 1] = entry
                end
            end
        end
        for index2, entry2 in ipairs(context.PERSIST) do
            value2, index2 = argument[entry2], config[entry2]
            if typeof(index2) == "Color3" and type(value2) == "string" then
                local success, value3 = pcall(Color3.fromHex, value2)
                if success then
                    config[entry2] = value3
                end
            elseif value2 ~= nil then
                if typeof(value2) == typeof(index2) then
                    config[entry2] = value2
                elseif index2 == nil then
                    if type(value2) ~= "table" then
                        config[entry2] = value2
                    end
                end
            end
        end
        for index3, entry3 in ipairs(value) do
            config[entry3] = false
        end
        if #value > 0 then
            if context.askHeldSells then
                task.defer(context.askHeldSells, value)
            end
        end
        if context.autoClass then
            pcall(context.autoClass, true)
        end
    end
    local function helper21(argument)
        local value = sharedValue9
        for index, entry in ipairs(value.list) do
            if entry.name == argument then
                return entry, index
            end
        end
        return nil
    end
    local profiles = {
        current = function()
            local value = sharedValue9.current or "Default"
            return value
        end,
        list = function()
            local value = sharedValue9
            return value.list
        end,
        save = function(argument)
            local value = helper21(argument)
            if not value then
                value = { name = argument }
                sharedValue9.list[#sharedValue9.list + 1] = value
            end
            value.data, value.savedAt = context.snapshot(), os.date("%m/%d/%Y : %H:%M")
            sharedValue9.current = argument
            helper19()
            saveConfig()
        end,
        select = function(current)
            if current == "Default" then
                helper20(context.CFG_DEFAULTS or {})
                sharedValue9.current = "Default"
            else
                local value = helper21(current)
                if not value then
                    return
                end
                helper20(value.data or {})
                sharedValue9.current = current
            end
            helper19()
            saveConfig()
            if context.streamerRefresh then
                pcall(context.streamerRefresh)
            end
            if
                context.WALLS
                and context.WALLS.set
                and (config.wallsOn ~= true or (context.WALLS.inWallsMap or context.WALLS.inNorthernLands)())
            then
                pcall(context.WALLS.set, config.wallsOn == true)
            end
        end,
        rename = function(argument, argument2)
            local value = helper21(argument)
            if value then
                if helper21(argument2) then
                    return
                end
            else
                return
            end
            value.name = argument2
            if sharedValue9.current == argument then
                sharedValue9.current = argument2
            end
            helper19()
        end,
    }
    profiles.delete = function(argument)
        local value, value2 = helper21(argument)
        if not value then
            return
        end
        table.remove(sharedValue9.list, value2)
        if sharedValue9.current == argument then
            profiles.select("Default")
        end
        helper19()
    end
    profiles.autosave = function()
        local data = sharedValue9.current
        if data then
            if data == "Default" then
                return
            end
        else
            return
        end
        local value = helper21(data)
        if not value then
            return
        end
        data = context.snapshot()
        local success, value2 = pcall(context.HttpService.JSONEncode, context.HttpService, data)
        local success2, value3 = pcall(context.HttpService.JSONEncode, context.HttpService, value.data or {})
        if success then
            if success2 then
                if value2 ~= value3 then
                    value.data, value.savedAt = data, os.date("%m/%d/%Y : %H:%M")
                    helper19()
                    if context.rebuildConfigList then
                        pcall(context.rebuildConfigList)
                    end
                end
            end
        end
    end
    helper18()
    context.profiles = profiles
    context.buildShell = function(argument)
        return context.UI.buildShell(argument)
    end
    local function hlBugReport()
        local statusChip = localPlayer:WaitForChild("PlayerGui")
        local value3 = nil
        if value3 then
            value3:Destroy()
        end
        local dungeonAutofarmUi = context.UI.menuGui()
        runtimeState.scriptGui = dungeonAutofarmUi
        uiLibrary.ensureTip(dungeonAutofarmUi)
        local shell = context.buildShell(dungeonAutofarmUi)
        context.Shell = shell
        function context.menuPage(argument)
            return shell.menuPage(argument)
        end
        value3 = workspaceService.CurrentCamera
        local value4 = value3 and value3.ViewportSize.X or 1600
        local value5 = value3 and value3.ViewportSize.Y or 900
        statusChip = math.clamp(value5 - 140, 320, 640)
        local function weakKeys(argument, argument2, y, argument3, g, g, argument4, N)
            argument3 = shell.page(argument, argument2, argument4)
            sharedValue2[argument] = argument3
            return argument3
        end
        local value6, runsThisAccount, addAccount =
            weakKeys("Farm", "Farm", 24, 24, 330, statusChip, "The loop, the class, and the master switch.").body,
            uiLibrary.dropdown,
            {}
        argumentHelpers:appendValues(
            addAccount,
            0,
            { value = "mage", label = "Mage" },
            { value = "warrior", label = "Warrior" }
        )
        helper(
            runsThisAccount(
                value6,
                "Class",
                addAccount,
                function()
                    return config.classProfile
                end,
                function(argument)
                    config.classAuto = false
                    if context.applyClassProfile then
                        context.applyClassProfile(argument)
                    end
                    if context.BG then
                        if context.BG.check then
                            context.BG.check()
                        end
                    end
                end,
                0,
                "Mage or Warrior: the ranges, radii and timings tuned for that class are loaded and saved. Picking one by hand turns Class from the stats off."
            )
        )
        helper(
            uiLibrary.toggle(
                value6,
                "Class from the stats",
                function()
                    return config.classAuto ~= false
                end,
                function(classAuto)
                    config.classAuto = classAuto
                    if context.saveConfig then
                        pcall(context.saveConfig)
                    end
                    if classAuto then
                        if context.autoClass then
                            pcall(context.autoClass)
                        end
                    end
                end,
                0,
                "Mage or Warrior from where the stat points went: more physical power - Warrior, more spell power - Mage. Checked on start and whenever the stats change."
            )
        )
        local textControl = { Text = "" }
        runsThisAccount = uiLibrary.section(
            value6,
            "Autofarm",
            1,
            "The master switch and the bonus boss, for every account."
        ).content
        uiSettings.masterRender = helper(uiLibrary.toggle(runsThisAccount, "Enable Autofarm", function()
            return runtimeState.farmEnabled
        end, function(farmEnabled)
            runtimeState.farmEnabled = farmEnabled
            if not farmEnabled then
                helper2()
            end
            if context.notify then
                context.notify(
                    farmEnabled and "run" or "info",
                    farmEnabled and "Autofarm on" or "Autofarm off",
                    farmEnabled and "Switched on by hand." or "Switched off by hand."
                )
            end
        end, 0, "The master switch. Off in the lobby and on in a dungeon by itself.")).render
        helper15(
            runsThisAccount,
            "Stay for the bonus boss",
            "bonusBoss",
            1,
            "Northern Lands Nightmare only (the one run with a bonus boss): vote yes when the vote comes up, stay in the room for it, and hold the replay until it is dead."
        )
        runsThisAccount = Instance.new("Frame")
        runsThisAccount.Name, runsThisAccount.BackgroundTransparency, runsThisAccount.AutomaticSize, runsThisAccount.Size =
            "RunsThisAccount", 1, Enum.AutomaticSize.Y, UDim2.new(1, 0, 0, 0)
        uiLibrary.vlist(runsThisAccount, theme.GapSm)
        context.runsThisAccount = runsThisAccount
        local textControl2 = uiLibrary.caption(runsThisAccount, "", 0)
        local textControl3 = uiLibrary.label(runsThisAccount, "", "captionSub", 10)
        textControl3.Size = UDim2.new(1, 0, 0, 22)
        function context.refreshQueuePanel()
            if textControl3.Parent then
                textControl3.Text = "Status: " .. tostring(context.LB.status)
            end
        end
        context.refreshQueuePanel()
        local value7 = uiLibrary.buttonRow(runsThisAccount, 11)
        local value8 = value7.add(
            "Party of just me",
            "accent",
            function()
                local success, value, value2 = pcall(context.AF.soloParty)
                if success then
                    if not value then
                        if context.log then
                            context.log("Party", "no new party: this account is " .. tostring(value2))
                        end
                    end
                end
                pcall(context.refreshQueueMode)
                if context.refreshAllWidgets then
                    pcall(context.refreshAllWidgets)
                end
            end,
            "Make a party with only this account in it, switched on: it queues, starts and replays its own runs. It picks the dungeon by level - change that under Dungeon."
        )
        function context.refreshQueueMode()
            local value
            local value2, value9 = false
            local value10 = false
            pcall(function()
                value = context.AF.role()
                local value11, value12 = context.AF.partyOf(localPlayer.Name)
                local value13, value14, value15 = value11 ~= nil, value11 ~= nil
                value15, value2, value9 = value14 and value11.on == true, value13, value12
                value10 = value15
            end)
            local value16, text
            if not value2 then
                value16 =
                    "This account isn't in a party, so it won't start any runs. Press Party of just me below, or add it to a party above."
                text = value16
            else
                if not value10 then
                    value16 = ("This account is in Party %d, which is switched off - turn on Run this party above."):format(
                        value9 or 0
                    )
                    text = value16
                else
                    text = "Runs come from your party."
                    pcall(function()
                        local value11 = context.AF.carry()
                        if value == "leech" then
                            text ..= value11 and (" You're a leecher, the leader is %s."):format(value11.name) or " You're a leecher."
                        elseif context.AF.isHost() then
                            text ..= " You're the leader."
                        elseif value11 then
                            text ..= (" The leader is %s."):format(value11.name)
                        end
                        local value12, value13 = context.AF.plan()
                        if value12 then
                            text ..= (" Next run: %s %s."):format(tostring(value12), tostring(value13 or ""))
                        end
                    end)
                end
            end
            if textControl2.Text ~= text then
                textControl2.Text = text
            end
            if value8 then
                if value8.Visible == value2 then
                    value8.Visible = not value2
                end
            end
            if value7.frame.Visible == value2 then
                value7.frame.Visible = not value2
            end
        end
        pcall(context.refreshQueueMode)
        if config.mode1186 == nil then
            config.mode1186 = false
        end
        if config.role1186 == nil then
            config.role1186 = "carry"
        end
        if config.pulseRadius == nil then
            config.pulseRadius = 20
        end
        if config.pulseLead == nil then
            config.pulseLead = 1.45
        elseif config.pulseLead < 1.3 then
            config.pulseLead = 1.45
        end
        if config.altFollow == nil then
            config.altFollow = 22
        end
        if config.carryName == nil then
            config.carryName = ""
        end
        if config.carryKeepMoving == nil then
            config.carryKeepMoving = true
        end
        do
            addAccount = weakKeys("ModDetect", "Mod Detection", 24, 24, 330, statusChip, "").body
            if config.modLeaveLegendary == nil then
                config.modLeaveLegendary = true
            end
            if config.modLeaveUltimate == nil then
                config.modLeaveUltimate = true
            end
            if config.modLeaveValT3 == nil then
                config.modLeaveValT3 = true
            end
            if config.modLeaveEpic == nil then
                config.modLeaveEpic = false
            end
            if config.modLeaveValAny == nil then
                config.modLeaveValAny = false
            end
            value3 = uiLibrary.section(
                addAccount,
                "Detection",
                1,
                "A stranger in the run: every account stops, then rests 2 hours before queueing again. A big drop: leave and wait before queueing again."
            ).content
            helper(
                uiLibrary.toggle(
                    value3,
                    "Enabled",
                    function()
                        return config.modDetect
                    end,
                    function(argument)
                        local function helper6(modDetect)
                            config.modDetect = modDetect
                            if context.MD then
                                if context.MD.setOn then
                                    context.MD.setOn(modDetect)
                                end
                            end
                            saveConfig()
                            refreshAll()
                        end
                        if argument == true then
                            helper6(true)
                            return
                        end
                        context.confirmPop({
                            title = "Turn off mod detection?",
                            icon = "shield",
                            text = "With it off, a stranger or a moderator joining your run no longer stops your accounts - they keep farming in front of them - and a big drop no longer sends the account to the lobby to wait. Are you sure?",
                            yes = "Turn it off",
                            no = "Keep it on",
                            onYes = function()
                                helper6(false)
                            end,
                        })
                    end,
                    1,
                    "In a dungeon, anyone who is not one of your accounts or on the whitelist - in the run or asking to join it - stops every account in the run (autofarm off, standing still, or kicked with Kick instead of the lobby) and posts the webhook; every account in that run then rests 2 hours before queueing again. A drop ticked under After a big drop sends this account to the lobby to wait. Off ends a wait."
                )
            )
            helper15(
                value3,
                "Kick instead of the lobby",
                "modKick",
                2,
                "A stranger joining kicks every account in the run out of the game at once (after the webhook post) instead of standing still until the run ends. A big drop still goes to the lobby and waits there. A kicked account stays out until you rejoin."
            )
            helper15(
                value3,
                "Webhook on detection",
                "whModDetect",
                3,
                "Post to your webhook when it flags, and why: a player not on the whitelist joined the run, or a good drop - the item and how long it waits before queueing again. Leaving waits for the post."
            )
            local textControl4 = uiLibrary.label(value3, "", "captionSub", 4)
            textControl4.Size = UDim2.new(1, 0, 0, 22)
            function context.refreshModPanel(text)
                if textControl4.Parent then
                    if textControl4.Text ~= text then
                        textControl4.Text = text
                    end
                end
            end
            runsThisAccount = uiLibrary.section(
                addAccount,
                "Whitelist",
                2,
                "Friends who may be in your runs. Your own accounts never need adding - they are always allowed."
            ).content
            local textControl5 = uiLibrary.caption(runsThisAccount, "", 1)
            local function helper22()
                local value, value2 = {}, {}
                pcall(function()
                    for index, entry in ipairs(context.AF.parties()) do
                        for index2, entry2 in
                            ipairs(
                                type(entry) == "table" and type(entry.accounts) == "table" and entry.accounts
                                    or {}
                            )
                        do
                            index2 = type(entry2) == "table" and tostring(entry2.name or "") or ""
                            if index2 ~= "" then
                                if not value2[index2:lower()] then
                                    value2[index2:lower()] = true
                                    value[#value + 1] = index2
                                end
                            end
                        end
                    end
                end)
                pcall(function()
                    for index, entry in ipairs(context.AF.injected(config.modOursAge or 2592000)) do
                        if entry ~= "" then
                            if not value2[entry:lower()] then
                                value2[entry:lower()] = true
                                value[#value + 1] = entry
                            end
                        end
                    end
                end)
                if #value == 0 then
                    return "Added to the list on their own: every account you put in a party under Parties & Runs, and any account that ran Swangy on this PC."
                end
                local value9 = {}
                for index3 = 1, math.min(#value, 12), 1 do
                    value9[index3] = value[index3]
                end
                local value10, value11, value12, value13 =
                    #value,
                    #value == 1 and "" or "s",
                    table.concat(value9, ", "),
                    #value > 12 and (" and %d more"):format(#value - 12) or ""
                return ("%s the %d account%s in your parties or running Swangy on this PC (%s%s)."):format(
                    "Added to the list on their own:",
                    value10,
                    value11,
                    value12,
                    value13
                )
            end
            textControl5.Text = helper22()
            task.spawn(function()
                while true do
                    local text = runtimeState.destroyed
                    if not (if text then not text else textControl5.Parent) then
                        break
                    end
                    task.wait(2)
                    text = helper22()
                    if textControl5.Text ~= text then
                        textControl5.Text = text
                    end
                end
            end)
            helper(
                uiLibrary.listInput(
                    runsThisAccount,
                    "Friends",
                    "Usernames, not display names. A new box opens as you fill the last.",
                    function()
                        return config.modWhitelist
                    end,
                    function(modWhitelist)
                        config.modWhitelist = modWhitelist
                        helper16()
                    end,
                    2,
                    "Players who are not your accounts but may be in your runs - a friend joining is not flagged. Empty a box to remove a name.",
                    "Add a friend's username",
                    5
                )
            )
            local content = uiLibrary.section(
                addAccount,
                "After a big drop",
                3,
                "A drop ticked here: the account finishes the run, goes to the lobby and waits before queueing again."
            ).content
            uiLibrary.caption(content, "Leave the run after a drop of:", 1)
            helper15(content, "Legendary", "modLeaveLegendary", 2, "Any legendary drop.")
            helper15(content, "Ultimate", "modLeaveUltimate", 3, "Any ultimate drop.")
            helper15(
                content,
                "Gildenscale T3 Mage / Warrior",
                "modLeaveValT3",
                4,
                "A Gildenscale Mage or Warrior piece at tier 3: epic (purple) or legendary and up. Rare and lower do not count."
            )
            helper15(content, "Any epic", "modLeaveEpic", 5, "Every epic drop, whatever it is.")
            helper15(
                content,
                "Any Gildenscale piece",
                "modLeaveValAny",
                6,
                "Every Gildenscale drop, any class and rarity."
            )
            helper15(
                content,
                "Enhanced Inner Focus / Rage",
                "modLeaveEnhanced",
                6.5,
                "An Enhanced Inner Focus or Enhanced Inner Rage drop, any rarity. On by default."
            )
            helper(
                uiLibrary.rangeSlider(
                    content,
                    "Wait before requeueing",
                    "A random time between the two handles",
                    1,
                    60,
                    function()
                        return config.modWaitMin, config.modWaitMax
                    end,
                    function(modWaitMin, modWaitMax)
                        config.modWaitMin = modWaitMin
                        config.modWaitMax = modWaitMax
                        helper16()
                    end,
                    7,
                    "How long to stay in the lobby after a big drop before queueing again: a random time between the low and high handle. A stranger in the run is always 2 hours.",
                    "min"
                )
            )
            content = uiLibrary.section(
                addAccount,
                "Breaks",
                4,
                "Farm for a while, then rest in the lobby before queueing again - the whole party together, like the wait after a big drop."
            ).content
            helper(
                uiLibrary.toggle(
                    content,
                    "Take breaks",
                    function()
                        return context.MD ~= nil and context.MD.bOn ~= nil and context.MD.bOn()
                    end,
                    function(argument)
                        if context.MD then
                            if context.MD.bset then
                                context.MD.bset({ breakOn = argument == true })
                            end
                        end
                        if not argument then
                            if context.MD then
                                if context.MD.endBreak then
                                    context.MD.endBreak("Take breaks off")
                                end
                            end
                        end
                    end,
                    1,
                    "The whole party takes its breaks together: it farms for a random time between the Farm for handles, every account plays out the run it is in, then they all rest in the lobby for a random time between the Then rest for handles and come back together. These are the party's settings - change them on any of its accounts. The clock counts from the start of the session and is kept through crashes and rejoins. Off ends a break."
                )
            )
            helper(
                uiLibrary.rangeSlider(
                    content,
                    "Farm for",
                    "A random time between the two handles",
                    1,
                    24,
                    function()
                        local value = context.MD
                        return value and value.bget and value.bget("breakFarmMin") or 3,
                            value and value.bget and value.bget("breakFarmMax") or 5
                    end,
                    function(breakFarmMin, breakFarmMax)
                        if context.MD then
                            if context.MD.bset then
                                context.MD.bset({ breakFarmMin = breakFarmMin, breakFarmMax = breakFarmMax })
                            end
                        end
                    end,
                    2,
                    "How long the party farms before a rest: a random time between the low and high handle, picked when the farm starts. Both handles on one number: always that long.",
                    "h"
                )
            )
            helper(
                uiLibrary.rangeSlider(
                    content,
                    "Then rest for",
                    "A random time between the two handles",
                    5,
                    360,
                    function()
                        local value = context.MD
                        return value and value.bget and value.bget("breakRestMin") or 20,
                            value and value.bget and value.bget("breakRestMax") or 40
                    end,
                    function(breakRestMin, breakRestMax)
                        if context.MD then
                            if context.MD.bset then
                                context.MD.bset({ breakRestMin = breakRestMin, breakRestMax = breakRestMax })
                            end
                        end
                    end,
                    3,
                    "How long each rest in the lobby lasts: a random time between the low and high handle, the same for every account of the party. Both handles on one number: always that long.",
                    "min"
                )
            )
            local textControl6 = uiLibrary.label(content, "", "captionSub", 4)
            textControl6.Size = UDim2.new(1, 0, 0, 22)
            function context.refreshBreakPanel(text)
                if textControl6.Parent then
                    if textControl6.Text ~= text then
                        textControl6.Text = text
                    end
                end
            end
            uiLibrary.caption(
                content,
                "The sliders count from the next farm or rest. Apply restarts the one running now with them.",
                5
            )
            local value17 = uiLibrary.buttonRow(content, 6)
            value17.add(
                "Apply settings to current phase",
                "accent",
                function()
                    if context.MD then
                        if context.MD.applyPhase then
                            context.MD.applyPhase()
                        end
                    end
                end,
                "For the whole party. Farming: the farm timer starts again from now, with a new time from the sliders. Resting: the rest starts again from now, with a new time from the sliders."
            )
            value17.add(
                "Test rest: 30s",
                "plain",
                function()
                    if context.MD then
                        if context.MD.testRest then
                            context.MD.testRest()
                        end
                    end
                end,
                "A 30 second rest for every account of the party, to try it out: each after the run it is in (at once in the lobby), then back to the party. Works with Take breaks off too. Requeue now on the countdown card ends a rest early."
            )
        end
        function context.confirmPop(argument)
            if context.confirmOpen then
                pcall(function()
                    context.confirmOpen:Destroy()
                end)
                context.confirmOpen = nil
            end
            local value = uiLibrary.window(dungeonAutofarmUi, {
                name = "HLConfirm",
                title = argument.title,
                icon = argument.icon or "info",
                width = 380,
                height = 190,
                visible = true,
                autoHeight = true,
                maxHeight = 460,
                position = UDim2.fromOffset(math.max(8, (value4 - 380) / 2), math.max(8, value5 / 2 - 120)),
            })
            value.frame.ZIndex = 61
            context.confirmOpen = value.frame
            uiLibrary.caption(value.body, argument.text, 1)
            local value2 = uiLibrary.buttonRow(value.body, 2)
            local function helper6()
                if context.confirmOpen == value.frame then
                    context.confirmOpen = nil
                end
                pcall(function()
                    value.frame:Destroy()
                end)
            end
            value2.add(argument.yes, "danger", function()
                helper6()
                pcall(argument.onYes)
            end, argument.yesTip or "")
            value2.add(argument.no or "Cancel", "accent", function()
                helper6()
                if argument.onNo then
                    pcall(argument.onNo)
                end
            end, argument.noTip or "")
        end
        function context.askHeldSells(argument)
            local value = {}
            for index, entry in ipairs(argument) do
                value[#value + 1] = entry == "sellUltimate" and "Ultimate" or "Legendary"
            end
            local value2, confirmPop = table.concat(value, " and "), context.confirmPop
            local value9, value10 =
                { title = "Sell " .. value2 .. " items too?", icon = "coins" },
                argumentHelpers[108](value2:lower())
            value9.text = ("The settings you just loaded also sell %s items. That part was NOT turned on. Turn it on as well? Auto sell would then sell every unequipped %s item in your bag, and a sold item cannot be brought back."):format(
                value2,
                argumentHelpers:unpackValues(value10)
            )
            value9.yes = "Yes, sell " .. value2
            value9.no = "Keep them"
            value9.onYes = function()
                for index2, entry2 in ipairs(argument) do
                    config[entry2] = true
                end
                saveConfig()
                refreshAll()
            end
            confirmPop(value9)
        end
        if context.firstRunSeed then
            task.defer(function()
                local firstRunSeed = context.firstRunSeed
                if not firstRunSeed or runtimeState.destroyed then
                    return
                end
                local value = uiLibrary.window(dungeonAutofarmUi, {
                    name = "HLFirstRun",
                    title = "New account",
                    icon = "users",
                    width = 360,
                    height = 190,
                    visible = true,
                    autoHeight = true,
                    maxHeight = 420,
                    position = UDim2.fromOffset(
                        math.max(8, (value4 - 360) / 2),
                        math.max(8, value5 / 2 - 110)
                    ),
                })
                value.frame.ZIndex = 60
                local value2 = "another account on this PC"
                local value9 = tonumber(string.match(firstRunSeed.name or "", "release_(%d+)%.json"))
                local textControl7 = uiLibrary.caption(value.body, "", 1)
                local function helper6()
                    textControl7.Text = ("This account has no settings yet. Copy the settings from %s, or start with the defaults?"):format(
                        value2
                    )
                end
                helper6()
                if value9 then
                    task.spawn(function()
                        local success, value10 = pcall(function()
                            return sharedValue5:GetNameFromUserIdAsync(value9)
                        end)
                        if success then
                            if value10 then
                                if textControl7.Parent then
                                    value2 = tostring(value10)
                                    helper6()
                                end
                            end
                        end
                    end)
                end
                local value11 = uiLibrary.buttonRow(value.body, 2)
                local function helper23()
                    context.firstRunSeed = nil
                    runtimeState.configAsk = false
                    pcall(function()
                        value.frame:Destroy()
                    end)
                end
                value11.add(
                    "Copy settings",
                    "accent",
                    function()
                        helper20(firstRunSeed.data or {})
                        helper23()
                        saveConfig()
                        refreshAll()
                        pcall(function()
                            if context.applyFps then
                                context.applyFps()
                            end
                        end)
                        pcall(function()
                            if context.applyRender then
                                context.applyRender()
                            end
                        end)
                        pcall(function()
                            if context.streamerRefresh then
                                context.streamerRefresh()
                            end
                        end)
                        pcall(function()
                            if context.MM then
                                if context.MM.apply then
                                    context.MM.apply()
                                end
                            end
                        end)
                        pcall(function()
                            local colorThemes = context.colorThemes
                            if colorThemes then
                                for index, entry in ipairs(colorThemes.list) do
                                    if entry.name == config.colorTheme then
                                        colorThemes.set(index)
                                        break
                                    end
                                end
                            end
                        end)
                        context.log("Config", "first run: copied the settings from " .. value2)
                    end,
                    "Use that account's settings here. A few of them (keys, window spots) take effect from the next teleport."
                )
                value11.add("Keep defaults", "accent", function()
                    helper23()
                    saveConfig()
                    context.log("Config", "first run: kept the default settings")
                end, "Start this account on the default settings.")
            end)
        end
        do
            local workspace3 = game:GetService("Workspace")
            local localPlayer2, value18, value19, value20, connection, value21, hlRodinTags =
                getService("Players").LocalPlayer,
                { thirdbossmultirings = "dodge" },
                { thirdbossmultirings = true, bonusbosstallswirly = true },
                {}
            local function helper24(argument)
                local value = (context.BONUS_BOSS_LC or {})[argument]
                if value == "hazard" then
                    return "DODGE", Color3.fromRGB(255, 90, 90)
                end
                if value == "colour" then
                    return "COLOR BEAM - harmless", Color3.fromRGB(150, 200, 255)
                end
                if value == "pickup" then
                    return "TOUCH (green orb)", Color3.fromRGB(90, 255, 120)
                end
                if value == "split" then
                    return "SPLIT - leave the lethal half", Color3.fromRGB(255, 170, 60)
                end
                if value == "arena" then
                    return "ARENA PART - not an attack", Color3.fromRGB(190, 190, 190)
                end
                value = value18[argument]
                if value == "dodge" then
                    return "DODGE", Color3.fromRGB(255, 90, 90)
                end
                if value == "blast" then
                    return "BLAST", Color3.fromRGB(255, 140, 200)
                end
                if argument:sub(1, 9) == "bonusboss" then
                    return "NOT ON ANY LIST", Color3.fromRGB(255, 255, 90)
                end
                return nil
            end
            local function helper25(argument)
                return argument:sub(1, 9) == "bonusboss" or value18[argument] ~= nil
            end
            local function helper26(argument)
                if argument:IsA("Part") then
                    if argument.Shape == Enum.PartType.Ball then
                        return "ball"
                    end
                end
                if argument:IsA("Part") then
                    if argument.Shape == Enum.PartType.Cylinder then
                        return "cylX"
                    end
                end
                local value, value2, value9 = argument.Size.X, argument.Size.Y, argument.Size.Z
                if math.abs(value2 - value9) <= 0.02 * math.max(value2, value9) then
                    if value < 0.25 * value2 then
                        return "cylX"
                    end
                end
                if math.abs(value - value9) <= 0.02 * math.max(value, value9) then
                    if value2 < 0.25 * value then
                        return "cylY"
                    end
                end
                if math.abs(value - value2) <= 0.02 * math.max(value, value2) then
                    if value9 < 0.25 * value then
                        return "cylZ"
                    end
                end
                return "box"
            end
            local function helper27(argument)
                local value, size = argument.a, argument.p.Size
                if argument.flat then
                    value.Size = Vector3.new(size.X, context.CFG and context.CFG.rodinSweepDrawH or 5, size.Z)
                    local color3 = context.RD and context.RD.rodinSweep
                    local value2 = color3 and color3.segs and color3.segs[argument.p.Parent]
                    if value2 then
                        if context.sweepPlan then
                            pcall(context.sweepPlan, os.clock())
                        end
                    end
                    color3 = argument.col
                    color3 = if value2 and value2.T == math.huge
                        then Color3.fromRGB(90, 255, 120)
                        else if value2
                            then if value2.fireAt then Color3.fromRGB(140, 20, 20) else color3
                            else color3
                    if color3 then
                        if value.Color3 ~= color3 then
                            value.Color3 = color3
                        end
                    end
                    return
                end
                if argument.kind == "ball" then
                    value.Radius = math.min(size.X, size.Y, size.Z) * 0.5
                elseif argument.kind == "cylX" then
                    value.Height, value.Radius = size.X, math.min(size.Y, size.Z) * 0.5
                elseif argument.kind == "cylY" then
                    value.Height, value.Radius = size.Y, math.min(size.X, size.Z) * 0.5
                elseif argument.kind == "cylZ" then
                    value.Height, value.Radius = size.Z, math.min(size.X, size.Y) * 0.5
                else
                    value.Size = size
                end
            end
            local function helper28(adornee, argument, argument2, flat)
                local kind, value = flat and "box" or helper26(adornee)
                if kind == "ball" then
                    value = Instance.new("SphereHandleAdornment")
                else
                    if kind == "box" then
                        value = Instance.new("BoxHandleAdornment")
                    else
                        value = Instance.new("CylinderHandleAdornment")
                        if kind == "cylX" then
                            value.CFrame = CFrame.Angles(0, 1.5707963267948966, 0)
                        elseif kind == "cylY" then
                            value.CFrame = CFrame.Angles(1.5707963267948966, 0, 0)
                        end
                    end
                end
                value.Name = "HLHit"
                value.Adornee = adornee
                value.AlwaysOnTop = false
                value.ZIndex = 1
                value.Transparency = 0.6
                value.Color3 = argument
                local value2 = { a = value, p = adornee, kind = kind, flat = flat, col = argument }
                helper27(value2)
                value.Parent = hlRodinTags
                argument2[#argument2 + 1] = value2
            end
            local function helper29(argument)
                local value = {}
                if argument:IsA("BasePart") then
                    value[1] = argument
                    return value
                end
                local value2 = { "hitbox", "precast" }
                for index, entry in ipairs(value2) do
                    for index2, descendant in ipairs(argument:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            index2 = string.lower(descendant.Name)
                            if index2:find(entry, 1, true) then
                                if entry == "precast" then
                                    if not (index2:find("good", 1, true)) then
                                        value[#value + 1] = descendant
                                    end
                                else
                                    value[#value + 1] = descendant
                                end
                            end
                        end
                    end
                    if #value > 0 then
                        return value
                    end
                end
                for index3, descendant2 in ipairs(argument:GetDescendants()) do
                    if descendant2:IsA("BasePart") then
                        if descendant2 ~= argument.PrimaryPart then
                            if string.lower(descendant2.Name) ~= "particles" then
                                value[#value + 1] = descendant2
                            end
                        end
                    end
                end
                return value
            end
            local function helper30(adornee, text, textColor3, label)
                local parent = Instance.new("BillboardGui")
                parent.Name, parent.AlwaysOnTop, parent.LightInfluence, parent.Size =
                    "HLTag", true, 0, UDim2.fromOffset(240, 40)
                parent.ResetOnSpawn = false
                parent.StudsOffset = Vector3.new(0, label or 4, 0)
                parent.MaxDistance = 1500
                parent.Adornee = adornee
                label = Instance.new("TextLabel")
                label.BackgroundTransparency, label.Size, label.Font =
                    1, UDim2.fromScale(1, 1), Enum.Font.GothamBold
                label.TextSize = 13
                label.TextColor3 = textColor3
                label.TextStrokeTransparency = 0.2
                label.Text = text
                label.Parent = parent
                parent.Parent = hlRodinTags
                return parent
            end
            local function helper31(argument)
                if value20[argument] then
                    return
                elseif not (argument:IsA("BasePart")) then
                    if not (argument:IsA("Model")) then
                        return
                    end
                end
                local parent, value = argument.Parent, { draws = {} }
                if argument:IsA("BasePart") and parent and parent.Name == "bonusBossColorSafeSpots" then
                    value.bb =
                        helper30(argument, "SAFE SPOT: " .. argument.Name, Color3.fromRGB(90, 200, 255))
                elseif
                    argument:IsA("BasePart")
                    and parent
                    and parent.Name == "bonusBossMemoryModel"
                    and argument.Name ~= "PrimaryPart"
                then
                    local value2, color, value9 = string.lower(argument.Name), Color3.fromRGB(255, 90, 90), 4
                    if value2:find("hitbox", 1, true) then
                        color, value9 = Color3.fromRGB(255, 170, 60), 14
                    else
                        if value2:find("good", 1, true) then
                            color, value9 = Color3.fromRGB(90, 255, 120), 9
                        end
                    end
                    value.bb = helper30(argument, "split part: " .. argument.Name, color, value9)
                else
                    local value10 = string.lower(argument.Name)
                    if value10 == "bonusbosscolorsafespots" then
                        return
                    elseif not (helper25(value10)) then
                        return
                    end
                    local value11 = parent
                    while value11 and value11 ~= workspace3 do
                        if helper25(string.lower(value11.Name)) then
                            return
                        end
                        value11 = value11.Parent
                    end
                    local value12, value13 = helper24(value10)
                    if not value12 then
                        return
                    end
                    value11 = argument:IsA("BasePart") and argument
                        or argument.PrimaryPart
                        or argument:FindFirstChildWhichIsA("BasePart", true)
                    if not value11 then
                        return
                    end
                    value.bb = helper30(
                        value11,
                        argument.Name
                            .. "\10"
                            .. value12
                            .. ((context.ATTACKS or {})[value10] == true and "  (on dodge list)" or ""),
                        value13
                    )
                    value12 = value19[value10]
                    if if value12 then not value12 else (context.BONUS_BOSS_LC or {})[value10] ~= "arena" then
                        for index, entry in ipairs(helper29(argument)) do
                            helper28(entry, value13, value.draws, value10 == "bonusbosssweepingflames")
                        end
                    end
                end
                value20[argument] = value
            end
            local function helper32(argument, argument2)
                pcall(function()
                    argument2.bb:Destroy()
                end)
                for index, draw in ipairs(argument2.draws) do
                    pcall(function()
                        draw.a:Destroy()
                    end)
                end
                value20[argument] = nil
            end
            local function helper33()
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
                value21 = nil
                for key, entry in pairs(value20) do
                    helper32(key, entry)
                end
                if hlRodinTags then
                    pcall(function()
                        hlRodinTags:Destroy()
                    end)
                    hlRodinTags = nil
                end
            end
            function context.rodinTags(parent)
                helper33()
                if not parent then
                    return
                end
                parent = localPlayer2 and (localPlayer2:FindFirstChildOfClass("PlayerGui"))
                if not parent then
                    return
                end
                hlRodinTags = Instance.new("Folder")
                hlRodinTags.Name = "HLRodinTags"
                hlRodinTags.Parent = parent
                for index, descendant in ipairs(workspace3:GetDescendants()) do
                    pcall(helper31, descendant)
                end
                connection = workspace3.DescendantAdded:Connect(function(argument)
                    task.defer(function()
                        pcall(helper31, argument)
                    end)
                end)
                local value = {}
                value21 = value
                task.spawn(function()
                    while true do
                        local parent2 = value21
                        if not (parent2 == value) then
                            break
                        end
                        if if hlRodinTags then not hlRodinTags.Parent else not hlRodinTags then
                            parent2 = localPlayer2 and (localPlayer2:FindFirstChildOfClass("PlayerGui"))
                            if parent2 then
                                hlRodinTags = Instance.new("Folder")
                                hlRodinTags.Name = "HLRodinTags"
                                hlRodinTags.Parent = parent2
                            end
                        end
                        parent2 = {}
                        for key, entry in pairs(value20) do
                            if key:IsDescendantOf(workspace3) then
                                local value2 = not (entry.bb and entry.bb.Parent)
                                for index2, draw in ipairs(entry.draws) do
                                    if draw.a.Parent then
                                        if draw.p.Parent then
                                            pcall(helper27, draw)
                                        end
                                    else
                                        value2 = true
                                    end
                                end
                                if value2 then
                                    helper32(key, entry)
                                    parent2[#parent2 + 1] = key
                                end
                            else
                                helper32(key, entry)
                            end
                        end
                        for index3, entry2 in ipairs(parent2) do
                            pcall(helper31, entry2)
                        end
                        task.wait(0.15)
                    end
                end)
            end
            local value22, value23 =
                {
                    bonusbossgroundflame = true,
                    bonusbosslongline = true,
                    bonusbosssmallspiralflame = true,
                    bonusbosssweepingflames = "segments",
                    thirdbossmultirings = true,
                }, { units = {}, conn = nil, run = nil }
            local function helper34(argument)
                if not value23.units[argument] then
                    local units, value = value23.units, { lit = {}, darkSince = nil }
                    value.born, units[argument] = os.clock(), value
                end
            end
            local function helper35(argument)
                if argument:IsA("Model") then
                    if argument.Parent ~= workspace3 then
                        return
                    end
                else
                    return
                end
                local value = value22[string.lower(argument.Name)]
                if not value then
                    return
                end
                if value == "segments" then
                    for index, child in ipairs(argument:GetChildren()) do
                        if child:IsA("Model") then
                            helper34(child)
                        end
                    end
                else
                    helper34(argument)
                end
            end
            local function helper36(argument, argument2)
                local hazardReader2 = context.RD
                hazardReader2.janitor = hazardReader2.janitor or { n = 0, recent = {} }
                hazardReader2.janitor.n = hazardReader2.janitor.n + 1
                local value = ""
                pcall(function()
                    local position = argument:GetPivot().Position
                    value = ("%.0f,%.0f"):format(position.X, position.Z)
                end)
                local recent = hazardReader2.janitor.recent
                recent[#recent + 1] = ("%s @%s after %.1fs (clock %.1f)"):format(
                    argument.Name,
                    value,
                    argument2,
                    os.clock()
                )
                if #recent > 30 then
                    table.remove(recent, 1)
                end
            end
            function context.rodinJanitor(argument)
                if value23.conn then
                    value23.conn:Disconnect()
                    value23.conn = nil
                end
                value23.run = nil
                value23.units = {}
                if not argument then
                    return
                end
                for index, child in ipairs(workspace3:GetChildren()) do
                    pcall(helper35, child)
                end
                value23.conn = workspace3.ChildAdded:Connect(function(argument2)
                    task.defer(function()
                        pcall(helper35, argument2)
                    end)
                end)
                local run = {}
                value23.run = run
                task.spawn(function()
                    while value23.run == run do
                        local now, config2 = os.clock(), context.CFG
                        for key, unit in pairs(value23.units) do
                            if key.Parent then
                                if string.lower(key.Name) == "bonusbosssmallspiralflame" then
                                    local precast = key:FindFirstChild("precast")
                                    if precast then
                                        if precast:IsA("BasePart") then
                                            unit.base = unit.base or precast.Transparency
                                            if
                                                math.abs(precast.Transparency - unit.base) > 0.05
                                                or now - unit.born >= (config2.janSpiralLife or 0.72)
                                            then
                                                helper36(key, now - unit.born)
                                                pcall(function()
                                                    key:Destroy()
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                            if key.Parent then
                                local value = true
                                for index2, descendant in ipairs(key:GetDescendants()) do
                                    if descendant:IsA("BasePart") then
                                        if descendant.Transparency < 0.9 then
                                            unit.lit[descendant] = true
                                            value = false
                                        end
                                    end
                                end
                                if value and next(unit.lit) ~= nil then
                                    unit.darkSince = unit.darkSince or now
                                    local value2 = string.lower(key.Name) == "bonusbosssmallspiralflame" and 0
                                        or (config2.janDark or 0.1) + (config2.janGrace or 0.05)
                                    if now - unit.darkSince >= value2 then
                                        local parent = key.Parent
                                        helper36(key, now - unit.born)
                                        value23.units[key] = nil
                                        pcall(function()
                                            key:Destroy()
                                        end)
                                        if parent and parent ~= workspace3 then
                                            if parent:IsA("Model") then
                                                if not (parent:FindFirstChildWhichIsA("Model")) then
                                                    pcall(function()
                                                        parent:Destroy()
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                else
                                    unit.darkSince = nil
                                end
                            else
                                value23.units[key] = nil
                            end
                        end
                        task.wait(0.03)
                    end
                end)
            end
            task.spawn(function()
                for index = 1, 60, 1 do
                    for index2, child in ipairs(workspace3:GetChildren()) do
                        if child.Name == "dungeonName" then
                            if child:IsA("StringValue") then
                                if child.Value == "Northern Lands" then
                                    if not context.NOVIS then
                                        pcall(context.rodinTags, true)
                                    end
                                    pcall(context.rodinJanitor, true)
                                    return
                                end
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
        value3 = weakKeys(
            "Visuals",
            "Visuals",
            1408,
            24,
            340,
            statusChip,
            "What you see: the screen, the camera, the minimap, the item cards and streamer mode."
        ).body
        runsThisAccount = uiLibrary.section(
            value3,
            "Screen",
            1,
            "What is on screen and how much the game draws: the HUD, the FPS cap, and the world not drawn at all."
        )
        addAccount = runsThisAccount.content
        helper(
            uiLibrary.toggle(
                addAccount,
                "Show the HUD",
                function()
                    local hudShown = context.hudShown
                    return if hudShown then context.hudShown() else not hudShown
                end,
                function(argument)
                    if context.fpsSharedSet then
                        context.fpsSharedSet("hud", argument == true)
                    end
                end,
                0.5,
                "The panel in the bottom left: playtime, status, attack and ping. Every account on this PC at once."
            )
        )
        helper(
            uiLibrary.toggle(
                addAccount,
                "Cap FPS",
                function()
                    return context.fpsShared().cap == true
                end,
                function(argument)
                    context.fpsSharedSet("cap", argument == true)
                end,
                1,
                "Every account on this PC at once: leechers run at Leech FPS, every other account at Carry FPS. Saves a lot of CPU and GPU with several accounts open. Off: Uncap FPS decides."
            )
        )
        helper(
            uiLibrary.slider(
                addAccount,
                "Carry FPS",
                "fps",
                15,
                240,
                false,
                function()
                    return tonumber(context.fpsShared().carry) or 45
                end,
                function(argument)
                    context.fpsSharedSet("carry", argument)
                end,
                1.1,
                "With Cap FPS on: the FPS of every account that fights (and any account in no party). Every account on this PC.",
                5
            )
        )
        helper(uiLibrary.slider(addAccount, "Leech FPS", "fps", 5, 60, false, function()
            return tonumber(context.fpsShared().leech) or 15
        end, function(argument)
            context.fpsSharedSet("leech", argument)
        end, 1.2, "With Cap FPS on: the FPS of every leecher. Every account on this PC.", 1))
        helper(
            uiLibrary.toggle(
                addAccount,
                "Uncap FPS",
                function()
                    return context.fpsShared().uncap == true
                end,
                function(argument)
                    context.fpsSharedSet("uncap", argument == true)
                end,
                1.3,
                "Only while Cap FPS is off: lifts Roblox's 60 FPS cap on every account on this PC. Off puts the 60 cap back."
            )
        )
        helper15(
            addAccount,
            "Ultimate low quality",
            "renderOff",
            2,
            "Stops the game drawing the world at all - the MAP VIEW fills the screen instead (its Blank screen button leaves it blank) and this menu stays where it is. The bot plays on exactly as it did; it is the biggest saving there is on a machine running several accounts. Off brings the picture back.",
            function(argument)
                if context.applyRender then
                    pcall(context.applyRender, true)
                end
                if context.MM then
                    if context.MM.onUltimate then
                        pcall(context.MM.onUltimate, argument == true)
                    end
                end
            end
        )
        runsThisAccount.setOpen(true)
        addAccount = uiLibrary.section(
            value3,
            "Minimap",
            3,
            "The minimap in the top right, the MAP VIEW it opens and the key for it."
        )
        runsThisAccount = addAccount.content
        helper15(
            runsThisAccount,
            "Show the minimap",
            "minimap",
            1,
            "A map of every mob, player and enemy attack round you, north up. Click it for the MAP VIEW - the red X in its corner closes that. Scroll over it to zoom; middle-drag to move it.",
            function()
                if context.MM then
                    if context.MM.apply then
                        pcall(context.MM.apply)
                    end
                end
            end
        )
        helper15(
            runsThisAccount,
            "Map button",
            "mapButton",
            1.2,
            "A MINIMAP button right under the small map - it opens the MAP VIEW, the same as the map key.",
            function()
                if context.MM then
                    if context.MM.apply then
                        pcall(context.MM.apply)
                    end
                end
            end
        )
        helper15(
            runsThisAccount,
            "Follow player",
            "mapFollow",
            1.5,
            "On: the map keeps you in the middle. Off: it stays where it is and you move across it - middle-drag the MAP VIEW to move it, middle-click to put it on you again. Each place keeps its own spot.",
            function(argument)
                if context.MM then
                    if context.MM.onFollow then
                        pcall(context.MM.onFollow, argument)
                    end
                end
            end
        )
        helper15(
            runsThisAccount,
            "Smooth 2D map",
            "minimapSmooth",
            1.8,
            "The classic 2D map redraws every frame instead of 10-20 times a second, so everything on it moves smoothly. Off if it costs you frames."
        )
        helper15(
            runsThisAccount,
            "Custom attack color",
            "mapAttackOneColor",
            2,
            "Every enemy attack in the color below - on the map, and the attacks themselves in the world, every part of them. Off puts their own colors back."
        )
        helper15(
            runsThisAccount,
            "Rainbow attacks",
            "mapAttackRainbow",
            2,
            "Every enemy attack cycles through the rainbow - on the map, the attack zones and the attacks themselves in the world. Takes over from the color below while it is on. Picking the Rainbow or Chroma theme turns it on; switching to another theme turns it back off, unless you set it here yourself.",
            function()
                config.attackRainbowAuto = nil
            end
        )
        helper(
            uiLibrary.colorWheel(
                runsThisAccount,
                "Attack color",
                function()
                    return typeof(config.mapAttackColor) == "Color3" and config.mapAttackColor
                        or Color3.fromRGB(255, 60, 60)
                end,
                function(mapAttackColor)
                    config.mapAttackColor = mapAttackColor
                    helper16()
                end,
                3,
                'The color of every enemy attack while "Custom attack color" is on. Click to open the wheel: hue round it, paler to the middle, brightness on the bar.'
            )
        )
        uiSettings.mapKeyButton = uiLibrary.button(
            runsThisAccount,
            "Map key: " .. tostring(config.mapKey) .. " (click, then press a key)",
            "accent",
            function()
                runtimeState.mapKeyCapture = true
                runtimeState.menuKeyCapture = false
                if uiSettings.menuKeyButton then
                    uiSettings.menuKeyButton.Text = "Menu key: "
                        .. tostring(config.menuKey)
                        .. " (click, then press a key)"
                end
                if uiSettings.mapKeyButton then
                    uiSettings.mapKeyButton.Text = "Press the new key... (Escape cancels)"
                end
            end,
            4,
            "The key that opens and closes the MAP VIEW - M to begin with. Click, then press the new key; Escape keeps the old one."
        )
        addAccount.setOpen(true)
        runsThisAccount = uiLibrary.section(
            value3,
            "Item cards",
            4,
            "How the game's item cards show their numbers."
        ).content
        helper(
            uiLibrary.toggle(
                runsThisAccount,
                "Abbreviate item stats",
                function()
                    return config.itemStatsAbbrev ~= false
                end,
                function(itemStatsAbbrev)
                    config.itemStatsAbbrev = itemStatsAbbrev
                    saveConfig()
                end,
                1,
                "Show inventory item stats short (9.76k, 11.0b - three figures) instead of the full number. On by default."
            )
        )
        helper(
            uiLibrary.toggle(
                runsThisAccount,
                "Abbreviate the upgrade count",
                function()
                    return config.upgradeCountAbbrev ~= false
                end,
                function(upgradeCountAbbrev)
                    config.upgradeCountAbbrev = upgradeCountAbbrev
                    saveConfig()
                end,
                2,
                "The item card's upgrade line as well - short on, written out with commas off. On by default. It needs the stats-at-max hook, the same one that puts the bracketed number on the card."
            )
        )
        helper(
            uiLibrary.toggle(
                runsThisAccount,
                "Godpot %",
                function()
                    return config.itemGodpot ~= false
                end,
                function(itemGodpot)
                    config.itemGodpot = itemGodpot
                    saveConfig()
                    if itemGodpot ~= true then
                        if context.gpHide then
                            pcall(context.gpHide)
                        end
                    end
                end,
                3,
                "On every weapon and armor in the inventory (a badge in the corner) and on its item card: how good it rolled for its kind and rarity - where its stat after every upgrade left sits between the worst and the best roll, 0-100%. On by default."
            )
        )
        do
            local value24 = uiLibrary.section(
                value3,
                "Streamer mode",
                -1,
                "Hide anything on screen that says who is playing."
            )
            local function helper37()
                context.streamerRefresh()
            end
            helper15(
                value24.content,
                "Streamer mode",
                "streamer",
                1,
                "Hide or replace everything below. Off puts it all back.",
                helper37
            )
            local function helper38(argument)
                return function()
                    return config[argument]
                end
            end
            local function helper39(argument)
                return function(argument2)
                    config[argument] = tostring(argument2 or "")
                    helper37()
                    saveConfig()
                end
            end
            local function helper40(argument, argument2, argument3, argument4)
                helper(
                    uiLibrary.textInput(
                        value24.content,
                        argument,
                        helper38(argument2),
                        helper39(argument2),
                        argument3,
                        argument4
                    )
                )
            end
            helper40("Name", "streamerNameText", 2, "Shown instead of your name. Empty hides it.")
            helper40("Health", "streamerHealthText", 3, "Shown instead of your health. Empty hides it.")
            helper40("Level", "streamerLevelText", 4, "Shown instead of your level. Empty hides it.")
            helper40("Gold", "streamerGoldText", 5, "Shown instead of your gold. Empty hides the row.")
            helper40("Gems", "streamerGemsText", 6, "Shown instead of your gems. Empty hides the row.")
            helper40("XP", "streamerXpText", 7, "Shown instead of your XP. Empty hides the bar.")
            helper15(
                value24.content,
                "Hitbox as body",
                "streamerBody",
                8,
                "Draw the character as a plain block in the color below.",
                helper37
            )
            helper(
                uiLibrary.colorWheel(
                    value24.content,
                    "Hitbox color",
                    function()
                        return typeof(config.streamerBodyColor) == "Color3" and config.streamerBodyColor
                            or Color3.fromHex("5bff9c")
                    end,
                    function(streamerBodyColor)
                        config.streamerBodyColor = streamerBodyColor
                        helper16()
                    end,
                    9,
                    "The color of the block drawn in place of your character. Click to open the wheel: hue round it, paler to the middle, brightness on the bar."
                )
            )
            helper15(
                value24.content,
                "Hide other players' names",
                "streamerOthers",
                10,
                "Other players' nameplates.",
                helper37
            )
            helper15(
                value24.content,
                "Hide the player lists",
                "streamerLeaderboard",
                11,
                "The game's and Roblox's player lists.",
                helper37
            )
            helper15(
                value24.content,
                "Hide the chat",
                "streamerChat",
                12,
                "The Roblox chat window.",
                helper37
            )
            local value25 = {
                "streamer",
                "streamerNameText",
                "streamerHealthText",
                "streamerLevelText",
                "streamerGoldText",
                "streamerGemsText",
                "streamerXpText",
                "streamerBody",
                "streamerBodyColor",
                "streamerOthers",
                "streamerLeaderboard",
                "streamerChat",
            }
            local value26 = getService("HttpService")
            local function helper41()
                local value = {}
                for index, entry in ipairs(value25) do
                    index = config[entry]
                    index = if typeof(index) == "Color3" then "#" .. index:ToHex() else index
                    value[#value + 1] = index == nil and { entry } or { entry, index }
                end
                local success, value2 = pcall(function()
                    return value26:JSONEncode(value)
                end)
                return success and value2 or nil
            end
            local function helper42(argument)
                local success, value = pcall(function()
                    return value26:JSONDecode(argument)
                end)
                if success then
                    if type(value) ~= "table" then
                        return false
                    end
                else
                    return false
                end
                success = {}
                for index, entry in ipairs(value25) do
                    success[entry] = true
                end
                for index2, entry2 in ipairs(value) do
                    local value2, value9
                    if type(entry2) == "table" then
                        value2, value9 = entry2[1], entry2[2]
                    end
                    if success[value2] then
                        if value2 == "streamerBodyColor" then
                            if type(value9) == "string" then
                                index2, entry2 = pcall(Color3.fromHex, (value9:gsub("^#", "")))
                                if index2 then
                                    config[value2] = entry2
                                end
                            else
                                config[value2] = value9
                            end
                        else
                            config[value2] = value9
                        end
                    end
                end
                return true
            end
            local function helper43()
                local success, value = pcall(function()
                    return isfile("HarvardLabs/configs/streamer_shared.json")
                            and readfile("HarvardLabs/configs/streamer_shared.json")
                        or nil
                end)
                return success and value or nil
            end
            local function helper44(argument)
                if not (helper42(argument)) then
                    return
                end
                pcall(saveConfig)
                pcall(helper37)
                if context.refreshAllWidgets then
                    pcall(context.refreshAllWidgets)
                end
            end
            local value27
            runsThisAccount = helper43()
            if runsThisAccount then
                helper44(runsThisAccount)
                value27 = runsThisAccount
            else
                addAccount = helper41()
                if addAccount then
                    pcall(writefile, "HarvardLabs/configs/streamer_shared.json", addAccount)
                    value27 = addAccount
                end
            end
            local value28, value29 = helper41(), value27
            local value30 = value28
            task.spawn(function()
                while not runtimeState.destroyed do
                    task.wait(1)
                    pcall(function()
                        local value = helper43()
                        if value then
                            if value ~= value29 then
                                value29 = value
                                helper44(value)
                                value30 = helper41()
                                return
                            end
                        end
                        value = helper41()
                        if value then
                            if value ~= value30 then
                                value30 = value
                                pcall(writefile, "HarvardLabs/configs/streamer_shared.json", value)
                                value29 = value
                            end
                        end
                    end)
                end
            end)
        end
        runsThisAccount = uiLibrary.section(
            value3,
            "Notifications",
            0,
            "A card in the bottom right whenever something happens: a run queued, started, won or lost, a mod in the run, a good drop, auto sell, autofarm switching on or off."
        )
        helper(
            uiLibrary.toggle(
                runsThisAccount.content,
                "Notifications",
                function()
                    return config.notifications ~= false
                end,
                function(notifications)
                    config.notifications = notifications
                    saveConfig()
                end,
                1,
                "Show a card in the bottom right of the screen for everything the script does. Off: none."
            )
        )
        uiLibrary.button(
            runsThisAccount.content,
            "Show examples",
            "accent",
            function()
                if shell.notifyExamples then
                    shell.notifyExamples()
                end
            end,
            2,
            "Play one of each kind: queued, run started, mod, run won, drop, auto sell, autofarm off, run lost."
        )
        function context.initColorThemes(gradient)
            local value9, value10 = getService("RunService"), getService("HttpService")
            local scriptGui = runtimeState.scriptGui
            local function helper6(argument, argument2, argument3)
                return Color3.fromRGB(argument, argument2, argument3)
            end
            local function helper23(argument, argument2, argument3)
                return Color3.fromHSV(argument % 1, math.clamp(argument2, 0, 1), math.clamp(argument3, 0, 1))
            end
            local list = {}
            local function helper45(name2, tint, anim, tintAnim)
                list[#list + 1] = {
                    cat = "ANIMATED",
                    name = name2,
                    tint = tint,
                    anim = anim,
                    tintAnim = tintAnim,
                    accent = anim(0),
                }
            end
            local function parent(argument, argument2, argument3)
                helper45(argument, helper6(44, 44, 44), function(argument4)
                    local value = 0.5 + 0.5 * math.sin(argument4 * 1.3)
                    return argument2:Lerp(argument3, value)
                end)
            end
            parent("Crimson", helper6(213, 0, 0), helper6(244, 49, 32))
            parent("Ember", helper6(232, 97, 0), helper6(255, 138, 42))
            parent("Gold", helper6(230, 176, 0), helper6(255, 213, 74))
            parent("Emerald", helper6(18, 179, 86), helper6(62, 227, 132))
            parent("Azure", helper6(26, 108, 240), helper6(74, 149, 255))
            parent("Violet", helper6(128, 67, 238), helper6(174, 123, 255))
            parent("Rose", helper6(230, 64, 143), helper6(255, 116, 186))
            helper45("Chroma", helper6(24, 24, 30), function(argument)
                return helper23(argument * 0.08, 0.4, 1)
            end)
            list[#list].spatial = function(argument, argument2, argument3)
                return helper23(argument * 0.08 + argument2 / 600 + argument3 / 1200, 0.4, 1)
            end
            local value11 = 1
            do
                local value12, value13 = config.colorTheme
                if value12 == "Chrome" then
                    value12 = "Chroma"
                    value13 = value12
                else
                    value13 = value12
                end
                if value13 == nil or value13 == "Crimson" then
                    pcall(function()
                        if isfile then
                            if isfile("hl_theme.json") then
                                value13 = value10:JSONDecode(readfile("hl_theme.json")).theme
                            end
                        end
                    end)
                end
                for index, entry in ipairs(list) do
                    if entry.name == value13 then
                        value11 = index
                    end
                end
            end
            local function helper46(attackRainbowTheme)
                local value, value2 = attackRainbowTheme == "Rainbow" or attackRainbowTheme == "Chroma", false
                if value and config.attackRainbowTheme ~= attackRainbowTheme then
                    config.attackRainbowTheme = attackRainbowTheme
                    if config.mapAttackRainbow ~= true then
                        config.mapAttackRainbow = true
                        config.attackRainbowAuto = true
                    end
                    value2 = true
                else
                    if not value then
                        if config.attackRainbowTheme ~= nil then
                            config.attackRainbowTheme = nil
                            if config.attackRainbowAuto == true then
                                config.mapAttackRainbow = false
                                config.attackRainbowAuto = nil
                            end
                            value2 = true
                        end
                    end
                end
                if value2 then
                    if context.refreshAll then
                        pcall(context.refreshAll)
                    end
                end
                return value2
            end
            if helper46(list[value11].name) then
                pcall(saveConfig)
            end
            parent = getgenv and getgenv() or _G
            if parent.__HLThemes then
                pcall(parent.__HLThemes.destroy)
            end
            local value14, value15 = { identity = true }
            local function helper47(argument)
                if not (value15 and value15.Parent) then
                    value15 = scriptGui and scriptGui:FindFirstChild("HLMenu")
                end
                if value15 then
                    local value = value15
                    if argument:IsDescendantOf(value) then
                        local value2 = value15
                        return value2.AbsolutePosition
                    end
                end
                return Vector2.zero
            end
            local function helper48(argument)
                return (argument.R * 0.299 + argument.G * 0.587 + argument.B * 0.114) * 255
            end
            local function helper49(argument)
                local value, value2, value16 = argument:ToHSV()
                return value2 > 0.45 and (value < 0.07 or value > 0.93) and value16 > 0.3
            end
            local function helper50(argument)
                if value14.identity then
                    return argument
                end
                local value, value2, value16 = argument:ToHSV()
                if value2 > 0.45 and (value < 0.07 or value > 0.93) then
                    if value16 > 0.3 then
                        local value31, value32, value33 = value14.accent:ToHSV()
                        return Color3.fromHSV(value31, value32, math.clamp(value16 / 0.835 * value33, 0, 1))
                    end
                end
                if value2 > 0.35 then
                    return argument
                end
                value = helper48(argument)
                if value <= 1 then
                    return argument
                elseif value >= 250 then
                    return argument
                end
                argument, value16, value2 = value14.tint:ToHSV()
                if value14.light then
                    return Color3.fromHSV(
                        argument,
                        value16 * (value < 90 and 1 or 0.15),
                        math.clamp(1 - value / 255 * 0.9, 0, 1)
                    )
                end
                if value < 90 then
                    return Color3.fromHSV(
                        argument,
                        value16,
                        math.clamp(value / 255 * (value2 / 0.17254901960784313), 0, 1)
                    )
                end
                if value < 200 then
                    return Color3.fromHSV(argument, math.min(value16, 0.25) * 0.6, value / 255)
                end
                return Color3.fromHSV(argument, math.min(value16, 0.25) * 0.12, value / 255)
            end
            value14.same = function(argument, argument2)
                if argument == argument2 then
                    return true
                end
                local value16 = typeof(argument)
                if value16 ~= typeof(argument2) then
                    return false
                end
                if value16 == "Color3" then
                    return math.abs(argument.R - argument2.R) < 0.002
                        and math.abs(argument.G - argument2.G) < 0.002
                        and math.abs(argument.B - argument2.B) < 0.002
                end
                if value16 == "ColorSequence" then
                    local keypoints, keypoints2 = argument.Keypoints, argument2.Keypoints
                    if #keypoints ~= #keypoints2 then
                        return false
                    end
                    for index2 = 1, #keypoints, 1 do
                        local value, value2 = keypoints[index2].Value, keypoints2[index2].Value
                        if math.abs(keypoints[index2].Time - keypoints2[index2].Time) > 0.002 then
                            return false
                        elseif math.abs(value.R - value2.R) >= 0.002 then
                            return false
                        elseif math.abs(value.G - value2.G) >= 0.002 then
                            return false
                        elseif math.abs(value.B - value2.B) >= 0.002 then
                            return false
                        end
                    end
                    return true
                end
                return false
            end
            local function helper51(argument, argument2)
                if argument.tint == nil then
                    if not argument.anim then
                        value14.identity = true
                        return
                    end
                end
                value14.identity = false
                local value, value2
                if argument.anim then
                    value, value2 = argument.anim(argument2 or os.clock())
                end
                value14.accent, value14.tint, value14.light =
                    value or argument.accent, value2 or argument.tint, argument.light == true
                value14.spatial = argument.spatial
            end
            local value34, weakKeys2, value35 =
                {
                    { "GuiObject", { "BackgroundColor3" } },
                    { "TextLabel", { "TextColor3" } },
                    { "TextButton", { "TextColor3" } },
                    { "TextBox", { "TextColor3", "PlaceholderColor3" } },
                    { "ImageLabel", { "ImageColor3" } },
                    { "ImageButton", { "ImageColor3" } },
                    { "ScrollingFrame", { "ScrollBarImageColor3" } },
                    { "UIStroke", { "Color" } },
                    { "UIGradient", { "Color" } },
                }, { __mode = "k" }, {}
            local value36 = setmetatable({}, weakKeys2)
            local value37 = setmetatable({}, weakKeys2)
            local value38 = setmetatable({}, weakKeys2)
            local value39 = setmetatable({}, weakKeys2)
            local value40 = setmetatable({}, weakKeys2)
            local value41 = setmetatable({}, weakKeys2)
            local function helper52(argument)
                if argument:GetAttribute("HLThemeSkip") ~= nil then
                    return true
                elseif argument.Name == "HLMinimap" then
                    return true
                elseif argument.Name == "HLThemeSwatches" then
                    return true
                elseif argument:FindFirstAncestor("HLMinimap") ~= nil then
                    return true
                elseif argument:FindFirstAncestor("HLThemeSwatches") ~= nil then
                    return true
                end
                local value = argument
                while value and value ~= scriptGui do
                    if value:GetAttribute("HLThemeSkipTree") ~= nil then
                        return true
                    end
                    value = value.Parent
                end
                return false
            end
            local function helper53(argument)
                if typeof(argument) == "Color3" then
                    return helper49(argument)
                end
                if typeof(argument) == "ColorSequence" then
                    for index2, keypoint in ipairs(argument.Keypoints) do
                        if helper49(keypoint.Value) then
                            return true
                        end
                    end
                end
                return false
            end
            local function helper54(argument)
                if typeof(argument) == "Color3" then
                    return helper50(argument)
                end
                if typeof(argument) == "ColorSequence" then
                    local value = {}
                    for index2, keypoint in ipairs(argument.Keypoints) do
                        value[index2] = ColorSequenceKeypoint.new(keypoint.Time, helper50(keypoint.Value))
                    end
                    return ColorSequence.new(value)
                end
                return argument
            end
            value14.CH = setmetatable({}, weakKeys2)
            value14.chromaSeq = function(argument, argument2, argument3, argument4)
                local value = {}
                for index2 = 0, 6, 1 do
                    value[#value + 1] = ColorSequenceKeypoint.new(
                        index2 / 6,
                        value14.spatial(argument4, argument + argument2 * index2 / 6, argument3)
                    )
                end
                return ColorSequence.new(value)
            end
            value14.chroma = function(parent2, argument)
                local value = parent2:IsA("UIStroke") and parent2.Parent or parent2
                if value then
                    if not (value:IsA("GuiObject")) then
                        return false
                    end
                else
                    return false
                end
                local hlChroma = value14.CH[parent2]
                if not (hlChroma and hlChroma.Parent == parent2) then
                    for index2, child in ipairs(parent2:GetChildren()) do
                        if child:IsA("UIGradient") then
                            return false
                        end
                    end
                    hlChroma = Instance.new("UIGradient")
                    hlChroma.Name = "HLChroma"
                    hlChroma:SetAttribute("HLThemeSkip", true)
                    hlChroma.Parent = parent2
                    value14.CH[parent2] = hlChroma
                end
                local vector, absoluteSize = value.AbsolutePosition - helper47(value), value.AbsoluteSize
                hlChroma.Color = value14.chromaSeq(
                    vector.X,
                    math.max(absoluteSize.X, 1),
                    vector.Y + absoluteSize.Y * 0.5,
                    argument
                )
                return true
            end
            local function helper55(argument)
                local value = value36[argument]
                if not value then
                    return
                end
                local value2 = value14.spatial ~= nil and not value14.identity and value38[argument] == true
                if value14.CH[argument] then
                    if not value2 then
                        pcall(function()
                            value14.CH[argument]:Destroy()
                        end)
                        value14.CH[argument] = nil
                    end
                end
                if value2 then
                    local now = os.clock()
                    if argument:IsA("UIGradient") then
                        local parent2 = argument.Parent
                        if parent2 and (parent2:IsA("GuiObject")) then
                            local value16, absoluteSize =
                                parent2.AbsolutePosition - helper47(parent2), parent2.AbsoluteSize
                            local color = value14.chromaSeq(
                                value16.X,
                                math.max(absoluteSize.X, 1),
                                value16.Y + absoluteSize.Y * 0.5,
                                now
                            )
                            value16 = value37[argument]
                            if not value16 then
                                value16 = {}
                                value37[argument] = value16
                            end
                            value16.Color = color
                            pcall(function()
                                argument.Color = color
                            end)
                            return
                        end
                    elseif value14.chroma(argument, now) then
                        value14.accent = Color3.new(1, 1, 1)
                    else
                        local value31 = argument:IsA("GuiObject") and argument
                            or argument.Parent and argument.Parent:IsA("GuiObject") and argument.Parent
                        if value31 then
                            local vector, absoluteSize2 =
                                value31.AbsolutePosition - helper47(value31), value31.AbsoluteSize
                            value14.accent = value14.spatial(
                                now,
                                vector.X + absoluteSize2.X * 0.5,
                                vector.Y + absoluteSize2.Y * 0.5
                            )
                        end
                    end
                end
                value2 = value37[argument]
                if not value2 then
                    value2 = {}
                    value37[argument] = value2
                end
                for key, entry2 in pairs(value) do
                    local value32 = helper54(entry2)
                    if key == "BackgroundColor3" and value40[argument] and typeof(value32) == "Color3" then
                        value32 = value32:Lerp(Color3.new(0, 0, 0), value40[argument])
                    end
                    value2[key] = value32
                    pcall(function()
                        argument[key] = value32
                    end)
                end
            end
            local function helper56(argument)
                local value = false
                for key, entry2 in pairs(value36[argument]) do
                    value = if helper53(entry2) then true else value
                end
                value38[argument] = value or nil
            end
            local function helper57(argument)
                if value36[argument] then
                    return
                elseif helper52(argument) then
                    return
                end
                local value = {}
                for index2, entry2 in ipairs(value34) do
                    if argument:IsA(entry2[1]) then
                        for index3, entry3 in ipairs(entry2[2]) do
                            value[#value + 1] = entry3
                        end
                    end
                end
                if #value == 0 then
                    return
                end
                local value2 = {}
                value36[argument] = value2
                local success = argument
                while success and success.Parent ~= scriptGui do
                    success = success.Parent
                end
                if success then
                    if success:IsA("GuiObject") then
                        value39[argument] = success
                    end
                end
                for index4, entry4 in ipairs(value) do
                    success, index4 = pcall(function()
                        return argument[entry4]
                    end)
                    if success then
                        value2[entry4] = index4
                        value35[#value35 + 1] = argument:GetPropertyChangedSignal(entry4):Connect(function()
                            local value16, value31 = argument[entry4], value37[argument]
                            if value31 then
                                if value14.same(value31[entry4], value16) then
                                    return
                                end
                            end
                            value2[entry4] = value16
                            helper56(argument)
                            helper55(argument)
                        end)
                    end
                end
                if
                    argument:IsA("GuiButton")
                    and argument.AutoButtonColor
                    and value2.BackgroundColor3 ~= nil
                then
                    pcall(function()
                        argument.AutoButtonColor = false
                    end)
                    value41[argument] = true
                    local function helper58(argument2)
                        value40[argument] = argument2
                        helper55(argument)
                    end
                    value35[#value35 + 1] = argument.MouseEnter:Connect(function()
                        helper58(0.2)
                    end)
                    value35[#value35 + 1] = argument.MouseLeave:Connect(function()
                        helper58(nil)
                    end)
                    value35[#value35 + 1] = argument.MouseButton1Down:Connect(function()
                        helper58(0.35)
                    end)
                    value35[#value35 + 1] = argument.MouseButton1Up:Connect(function()
                        helper58(0.2)
                    end)
                end
                helper56(argument)
                helper55(argument)
            end
            local value42, connection2 = false
            local function helper59()
                if value42 then
                    return
                elseif runtimeState.destroyed then
                    return
                end
                value42 = true
                for index2, descendant in ipairs(scriptGui:GetDescendants()) do
                    helper57(descendant)
                end
                connection2 = scriptGui.DescendantAdded:Connect(function(argument)
                    task.defer(function()
                        if value42 then
                            if argument.Parent then
                                helper57(argument)
                            end
                        end
                    end)
                end)
                sliderConnections[#sliderConnections + 1] = connection2
            end
            local function helper60()
                for entry2 in pairs(value36) do
                    if entry2.Parent then
                        helper55(entry2)
                    end
                end
            end
            local function helper61()
                if not value42 then
                    return
                end
                helper60()
                value42 = false
                if connection2 then
                    connection2:Disconnect()
                    connection2 = nil
                end
                for index2, entry2 in ipairs(value35) do
                    entry2:Disconnect()
                end
                table.clear(value35)
                for entry3 in pairs(value41) do
                    pcall(function()
                        entry3.AutoButtonColor = true
                    end)
                end
                local value = { value36, value37, value38, value39, value40, value41 }
                for index3, entry4 in ipairs(value) do
                    for entry5 in pairs(entry4) do
                        entry4[entry5] = nil
                    end
                end
            end
            local value43, value44, value45, value46 =
                uiLibrary.section(
                    gradient,
                    "Color theme",
                    -2,
                    "Seven colors, every one animated. Chroma runs a rainbow through all of it instead."
                ),
                getService("TweenService"),
                0
            for index5, entry6 in ipairs(list) do
                if entry6.spatial then
                    value46 = index5
                else
                    value45 += 1
                end
            end
            local colorBar = Instance.new("Frame")
            colorBar.Name, colorBar.BackgroundColor3, colorBar.BorderSizePixel, colorBar.Size =
                "ColorBar", theme.SurfaceElement, 0, UDim2.new(1, 0, 0, 54)
            colorBar.LayoutOrder = 1
            colorBar.Parent = value43.content
            uiLibrary.corner(colorBar, theme.RadiusMd)
            uiLibrary.stroke(colorBar, theme.Hairline, 1)
            parent = uiLibrary.label(colorBar, "Color", "rowLabel", 1)
            parent.Position, parent.Size = UDim2.fromOffset(12, 5), UDim2.new(1, -170, 0, 18)
            local textControl7 = uiLibrary.label(colorBar, "", "rowLabel", 2)
            textControl7.AnchorPoint, textControl7.Position, textControl7.Size, textControl7.TextXAlignment =
                Vector2.new(1, 0),
                UDim2.new(1, -12, 0, 5),
                UDim2.fromOffset(160, 18),
                Enum.TextXAlignment.Right
            textControl7.TextColor3 = theme.AccentMid
            uiLibrary.setFont(textControl7, "sans", Enum.FontWeight.SemiBold)
            local colorTrack = Instance.new("Frame")
            colorTrack.Name, colorTrack.BackgroundColor3 = "ColorTrack", theme.SurfaceField
            colorTrack.BorderSizePixel = 0
            colorTrack.Active = true
            colorTrack.Position, colorTrack.Size = UDim2.fromOffset(12, 28), UDim2.new(1, -24, 0, 18)
            colorTrack:SetAttribute("HLThemeSkipTree", true)
            colorTrack.Parent = colorBar
            uiLibrary.corner(colorTrack, theme.RadiusSm)
            uiLibrary.stroke(colorTrack, theme.Hairline, 1)
            local value47 = {}
            for index6 = 1, value45, 1 do
                parent = Instance.new("Frame")
                parent.BackgroundColor3 = Color3.new(1, 1, 1)
                parent.BorderSizePixel = 0
                parent.Position, parent.Size =
                    UDim2.new((index6 - 1) / value45, 2, 0, 3), UDim2.new(1 / value45, -4, 1, -6)
                parent.Parent = colorTrack
                uiLibrary.corner(parent, 3)
                gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new(list[index6].accent)
                gradient.Parent = parent
                value47[index6] = { g = gradient, th = list[index6] }
            end
            local barKnob = Instance.new("Frame")
            barKnob.Name, barKnob.AnchorPoint, barKnob.Size, barKnob.BackgroundColor3 =
                "BarKnob", Vector2.new(0.5, 0.5), UDim2.fromOffset(10, 26), theme.TextPrimary
            barKnob.BorderSizePixel = 0
            barKnob.ZIndex = 4
            barKnob.Parent = colorTrack
            uiLibrary.corner(barKnob, 3)
            local value48 = uiLibrary.stroke(barKnob, theme.Hairline, 1)
            local set
            local function helper62()
                if not list[value11].spatial then
                    local value = value11
                    return value
                end
                for index2 = 1, value45, 1 do
                    if list[index2].name == config.colorThemeBase then
                        return index2
                    end
                end
                return 1
            end
            local function helper63(argument)
                local value = helper62()
                local position = UDim2.fromScale((value - 0.5) / value45, 0.5)
                barKnob.BackgroundTransparency = 0
                value48.Transparency = 0
                if argument then
                    value44
                        :Create(barKnob, TweenInfo.new(0.09, Enum.EasingStyle.Quint), { Position = position })
                        :Play()
                else
                    barKnob.Position = position
                end
                textControl7.Text = list[value11].spatial and "Chroma - " .. list[value].name
                    or list[value].name
            end
            local value49 = false
            local function helper64(argument)
                if colorTrack.AbsoluteSize.X <= 0 then
                    return
                end
                local value = math.clamp(
                    (argument - colorTrack.AbsolutePosition.X) / colorTrack.AbsoluteSize.X,
                    0,
                    0.9999
                )
                argument = math.floor(value * value45) + 1
                if argument ~= value11 then
                    value = list[value11].spatial ~= nil
                    set(argument)
                    if value then
                        if context.refreshAll then
                            pcall(context.refreshAll)
                        end
                    end
                end
                helper63(true)
            end
            colorTrack.InputBegan:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    if context.pressOnTop(colorTrack, input) then
                        value49 = true
                        helper64(input.Position.X)
                    end
                end
            end)
            sliderConnections[#sliderConnections + 1] = userInputService.InputChanged:Connect(function(input)
                local value = value49
                    and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    )
                if value then
                    helper64(input.Position.X)
                end
            end)
            sliderConnections[#sliderConnections + 1] = userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    value49 = false
                elseif input.UserInputType == Enum.UserInputType.Touch then
                    value49 = false
                end
            end)
            uiLibrary.tip(
                colorBar,
                "Slide along the bar: it snaps to each color and the menu takes it on. Every color is animated. Crimson is the original look."
            )
            set = function(argument)
                value11 = argument
                config.colorTheme = list[argument].name
                helper46(list[argument].name)
                pcall(saveConfig)
                helper51(list[argument], os.clock())
                if value14.identity then
                    helper61()
                else
                    helper59()
                    helper60()
                end
                helper63()
                if context.MM then
                    if context.MM.setAccent then
                        pcall(context.MM.setAccent, list[argument].accent)
                    end
                end
            end
            if value46 then
                helper(
                    uiLibrary.toggle(
                        value43.content,
                        "Chroma",
                        function()
                            local spatial = list[value11].spatial
                            return spatial ~= nil
                        end,
                        function(argument)
                            if argument then
                                if not list[value11].spatial then
                                    config.colorThemeBase = list[value11].name
                                end
                                set(value46)
                            else
                                set(helper62())
                            end
                        end,
                        2,
                        "A rainbow through every accent part of the menu, drifting across it - the knob above glides along the colors while it is on. Picking a color stops it there."
                    )
                )
            end
            value43.setOpen(true)
            helper63()
            local value50, value51, value52, value53, value54, value55, value56 =
                { list = {}, pos = 1, built = 0, sig = "", due = 0 }, 0, {}, 1, 0, ""
            local function helper65(argument)
                local value = value39[argument]
                return value == nil or value.Visible
            end
            sliderConnections[#sliderConnections + 1] = value9.Heartbeat:Connect(function(argument)
                if next(value40) then
                    local vector = userInputService:GetMouseLocation()
                    for entry2 in pairs(value40) do
                        local absolutePosition, absoluteSize = entry2.AbsolutePosition, entry2.AbsoluteSize
                        if
                            not (
                                entry2.Parent
                                and entry2.Visible
                                and vector.X >= absolutePosition.X
                                and vector.X <= absolutePosition.X + absoluteSize.X
                                and vector.Y >= absolutePosition.Y
                                and vector.Y <= absolutePosition.Y + absoluteSize.Y
                            )
                        then
                            value40[entry2] = nil
                            if entry2.Parent then
                                helper55(entry2)
                            end
                        end
                    end
                end
                local value, value2 = colorBar.Parent ~= nil, colorBar
                while value and value2 and value2 ~= scriptGui do
                    value, value2 =
                        if value2:IsA("GuiObject") then if value2.Visible then value else false else value,
                        value2.Parent
                end
                if value then
                    value51 += argument
                    if value51 >= 0.06666666666666667 then
                        value51 = 0
                        local now = os.clock()
                        for index2, entry3 in ipairs(value47) do
                            index2 = entry3.th.anim and entry3.th.anim(now) or entry3.th.accent
                            local value16, value31 = index2:Lerp(Color3.new(1, 1, 1), 0.18), {}
                            for index3 = 0, 4, 1 do
                                local value32 = index3 / 4
                                value31[#value31 + 1] = ColorSequenceKeypoint.new(
                                    value32,
                                    index2:Lerp(
                                        value16,
                                        0.5 + 0.5 * math.cos((value32 - now * 0.2) * 3.141592653589793 * 2)
                                    )
                                )
                            end
                            entry3.g.Color = ColorSequence.new(value31)
                        end
                    end
                end
                if value and list[value11].spatial and not value49 then
                    local value33 = value45
                    local value57 = os.clock() / (tonumber(config.chromaKnobLoop) or value33) % 1
                    barKnob.Position = UDim2.fromScale((0.5 + value57 * (value33 - 1)) / value33, 0.5)
                    local value58 = math.clamp(math.min(value57, 1 - value57) / 0.05, 0, 1)
                    barKnob.BackgroundTransparency, value48.Transparency = 1 - value58, 1 - value58
                    value58 = math.floor(value57 * (value33 - 1) + 0.5) + 1
                    if value58 ~= value56 then
                        value56 = value58
                        textControl7.Text = "Chroma - " .. list[value58].name
                    end
                elseif value56 then
                    value56 = nil
                    barKnob.BackgroundTransparency = 0
                    value48.Transparency = 0
                end
                local value59 = list[value11]
                if value42 then
                    if not value59.anim then
                        return
                    end
                else
                    return
                end
                helper51(value59, os.clock())
                if value59.tintAnim then
                    local value60 = ""
                    for index4, child in ipairs(scriptGui:GetChildren()) do
                        value60 = if child:IsA("GuiObject")
                            then if child.Visible then value60 .. child.Name .. "|" else value60
                            else value60
                    end
                    if value60 ~= value55 or os.clock() - value54 > 2 or #value52 == 0 then
                        value55 = value60
                        table.clear(value52)
                        for entry4 in pairs(value36) do
                            if entry4.Parent then
                                if helper65(entry4) then
                                    value52[#value52 + 1] = entry4
                                end
                            end
                        end
                        value54, value53 = os.clock(), 1
                    end
                    local value61 = #value52
                    local value62 = math.min(80, value61)
                    for index7 = 1, value62, 1 do
                        if value53 > value61 then
                            value53 = 1
                        end
                        index7 = value52[value53]
                        value53 += 1
                        if index7 then
                            if index7.Parent then
                                helper55(index7)
                            end
                        end
                    end
                else
                    local sig = ""
                    for index8, child2 in ipairs(scriptGui:GetChildren()) do
                        sig = if child2:IsA("GuiObject")
                            then if child2.Visible then sig .. child2.Name .. "|" else sig
                            else sig
                    end
                    if sig ~= value50.sig or os.clock() - value50.built > 1 or #value50.list == 0 then
                        value50.sig = sig
                        table.clear(value50.list)
                        for entry5 in pairs(value38) do
                            if entry5.Parent then
                                if helper65(entry5) then
                                    value50.list[#value50.list + 1] = entry5
                                end
                            end
                        end
                        value50.built = os.clock()
                        value50.pos = 1
                    end
                    local value63 = #value50.list
                    if value63 == 0 then
                        return
                    end
                    value50.due =
                        math.min(value50.due + value63 * argument * (value14.spatial and 10 or 30), value63)
                    local value64 = math.floor(value50.due)
                    value50.due = value50.due - value64
                    for index9 = 1, value64, 1 do
                        if value50.pos > value63 then
                            value50.pos = 1
                        end
                        index9 = value50.list[value50.pos]
                        value50.pos = value50.pos + 1
                        if index9 then
                            if index9.Parent then
                                if value38[index9] then
                                    helper55(index9)
                                end
                            end
                        end
                    end
                end
            end)
            if list[value11].tint ~= nil or list[value11].anim then
                task.delay(1, function()
                    if runtimeState.destroyed then
                        return
                    end
                    helper51(list[value11], os.clock())
                    helper59()
                end)
            end
            context.colorThemes = {
                list = list,
                set = set,
                current = function()
                    local value = list[value11]
                    return value.name
                end,
            }
            function context.themeAccent()
                local value = list[value11]
                return value.accent
            end
            function context.themeLive(argument)
                local value = list[value11]
                if value.spatial then
                    return nil, value.spatial
                end
                if value.anim then
                    return (value.anim(argument or os.clock()))
                end
                return value.accent
            end
            if context.MM then
                if context.MM.setAccent then
                    pcall(context.MM.setAccent, list[value11].accent)
                end
            end
        end
        context.initColorThemes(value3)
        value3 = weakKeys(
            "Webhook",
            "Webhook",
            370,
            24,
            330,
            statusChip,
            "Post a summary of every run to a Discord channel."
        )
        do
            addAccount = value3.body
            do
                local value65 = {
                    "webhook",
                    "webhookUrl",
                    "webhookUser",
                    "whStarted",
                    "whHideName",
                    "whWins",
                    "whRodin",
                    "whRatio",
                    "whDeaths",
                    "whItems",
                    "whGodpot",
                    "whTime",
                    "whDungeon",
                    "whGold",
                    "whWorth",
                    "whInv",
                    "whLevel",
                    "whLate",
                    "whPingId",
                    "whPingMin",
                    "whPingValT3",
                    "whImages",
                    "whBest",
                    "whAccent",
                    "whModDetect",
                }
                local value66 = getService("HttpService")
                local function helper66()
                    local value = {}
                    for index, entry in ipairs(value65) do
                        value[#value + 1] = config[entry] == nil and { entry } or { entry, config[entry] }
                    end
                    local success, value2 = pcall(function()
                        return value66:JSONEncode(value)
                    end)
                    return success and value2 or nil
                end
                local function helper67(argument)
                    local success, value = pcall(function()
                        return value66:JSONDecode(argument)
                    end)
                    if success then
                        if type(value) ~= "table" then
                            return false
                        end
                    else
                        return false
                    end
                    success = {}
                    for index, entry in ipairs(value65) do
                        success[entry] = true
                    end
                    for index2, entry2 in ipairs(value) do
                        if type(entry2) == "table" then
                            if success[entry2[1]] then
                                config[entry2[1]] = entry2[2]
                            end
                        end
                    end
                    pcall(saveConfig)
                    refreshAll()
                    return true
                end
                local function helper68()
                    local success, value = pcall(function()
                        return isfile("HarvardLabs/configs/webhook_shared.json")
                                and readfile("HarvardLabs/configs/webhook_shared.json")
                            or nil
                    end)
                    return success and value or nil
                end
                local function helper69(argument)
                    local value, value2, value9 =
                        {}, pcall(function()
                            local value10 = argument or ""
                            return value66:JSONDecode(value10)
                        end)
                    if value2 and type(value9) == "table" then
                        for index, entry in ipairs(value9) do
                            if type(entry) == "table" then
                                if type(entry[1]) == "string" then
                                    value[entry[1]] = { entry[2] }
                                end
                            end
                        end
                    end
                    return value
                end
                function context.whShared(argument)
                    local value = helper69(helper68())[argument]
                    if value then
                        return value[1]
                    end
                    return nil
                end
                local function helper70(argument, argument2)
                    local value, success, value2, value9 =
                        helper69(argument), helper69(argument2), helper69(helper68()), {}
                    for index, entry in ipairs(value65) do
                        local value10, value11, value12 = value[entry], success[entry], value2[entry]
                        value12 = if (value10 and value10[1]) ~= (value11 and value11[1])
                            then value11
                            else if value12 == nil then value11 else value12
                        if value12 then
                            if value12[1] ~= nil then
                                value9[#value9 + 1] = { entry, value12[1] }
                            else
                                value9[#value9 + 1] = { entry }
                            end
                        else
                            value9[#value9 + 1] = { entry }
                        end
                    end
                    success, argument = pcall(function()
                        return value66:JSONEncode(value9)
                    end)
                    return success and argument or argument2
                end
                local value67
                runsThisAccount = helper68()
                if runsThisAccount and (helper67(runsThisAccount)) then
                    value67 = runsThisAccount
                else
                    local value68 = helper66()
                    if value68 then
                        pcall(writefile, "HarvardLabs/configs/webhook_shared.json", value68)
                        value67 = value68
                    end
                end
                local value69, value70 = helper66(), value67
                local value71 = value69
                task.spawn(function()
                    while not runtimeState.destroyed do
                        task.wait(1)
                        pcall(function()
                            local value, value2 = helper68(), helper66()
                            local value9 = value2 ~= nil and value2 ~= value71
                            if value then
                                if value ~= value70 then
                                    if not value9 then
                                        value70 = value
                                        helper67(value)
                                        value71 = helper66()
                                        return
                                    end
                                end
                            end
                            if value9 then
                                value = helper70(value71, value2)
                                pcall(writefile, "HarvardLabs/configs/webhook_shared.json", value)
                                value70 = value
                                if value ~= value2 then
                                    helper67(value)
                                end
                                value71 = helper66()
                            end
                        end)
                    end
                end)
            end
            helper15(
                addAccount,
                "Send to Discord",
                "webhook",
                1,
                "Post one message per run. Off stops everything below."
            )
            local value72 = false
            local value73 = helper(
                uiLibrary.textInput(
                    addAccount,
                    "Webhook URL",
                    function()
                        return config.webhookUrl
                    end,
                    function(webhookUrl)
                        webhookUrl = tostring(webhookUrl or "")
                        if webhookUrl:match("^%*+$") then
                            return
                        end
                        config.webhookUrl = webhookUrl
                        saveConfig()
                    end,
                    2,
                    "Your Discord channel's webhook URL. Click to reveal it, click away to hide it again.",
                    "paste your webhook URL"
                )
            )
            do
                local box = value73.box
                local function render()
                    if value72 then
                        return
                    end
                    local value = tostring(config.webhookUrl or "")
                    box.Text = value ~= "" and string.rep("*", math.min(#value, 32)) or ""
                end
                box.Focused:Connect(function()
                    value72 = true
                    box.Text = tostring(config.webhookUrl or "")
                end)
                box.FocusLost:Connect(function()
                    value72 = false
                    local webhookUrl = box.Text
                    if webhookUrl ~= "" then
                        if not (webhookUrl:match("^%*+$")) then
                            config.webhookUrl = webhookUrl
                            saveConfig()
                        end
                    end
                    render()
                end)
                value73.render = render
                render()
            end
            helper(uiLibrary.textInput(addAccount, "Bot name", function()
                return config.webhookUser
            end, function(argument)
                config.webhookUser = tostring(argument or "")
                saveConfig()
            end, 3, "The name the message is posted under."))
            value73 = uiLibrary.section(
                addAccount,
                "What to send",
                4,
                "Everything is on to begin with; switch off what you do not want posted."
            )
            helper15(
                value73.content,
                "Hide your name",
                "whHideName",
                0.25,
                "Leave your display name and username out of every message."
            )
            helper15(
                value73.content,
                "Dungeon started",
                "whStarted",
                0.5,
                "Post a yellow message when a run begins."
            )
            helper15(
                value73.content,
                "Wins / losses",
                "whWins",
                1,
                "The result, and the session's win and loss counts."
            )
            helper15(
                value73.content,
                "Rodin clears",
                "whRodin",
                2,
                "A message every time Odin Reincarnation, the bonus boss, is beaten."
            )
            helper15(value73.content, "Win rate", "whRatio", 3, "Wins as a percentage of the session's runs.")
            helper15(
                value73.content,
                "Deaths that round",
                "whDeaths",
                4,
                "How many times you died during the run."
            )
            helper15(value73.content, "Items", "whItems", 5, "The loot list for the run.")
            helper15(value73.content, "Run time", "whTime", 6, "How long the run took.")
            helper15(
                value73.content,
                "Dungeon and difficulty",
                "whDungeon",
                7,
                "Which dungeon, on which difficulty."
            )
            helper15(
                value73.content,
                "Gold and gems",
                "whGold",
                8,
                "What the run earned, and what you are sitting on."
            )
            helper15(value73.content, "Haul value", "whWorth", 9, "What the drops would sell for, added up.")
            helper15(value73.content, "Bag space", "whInv", 10, "How full the inventory is out of 300.")
            helper15(value73.content, "Character level", "whLevel", 11, "Your level at the end of the run.")
            helper15(
                value73.content,
                "Late drops",
                "whLate",
                12,
                "Some items arrive half a minute after the run closes. Post them in a follow-up."
            )
            helper15(
                value73.content,
                "Best drop",
                "whBest",
                13,
                "Name the best thing that dropped in a field of its own."
            )
            helper15(
                value73.content,
                "Godpot %",
                "whGodpot",
                13,
                "The drop's godpot % next to its stats, when the item has one."
            )
            helper15(
                value73.content,
                "Drop artwork",
                "whImages",
                14,
                "Attach the item's picture from the wiki. A legendary gets the full-width shot."
            )
            helper15(
                value73.content,
                "Rarity color",
                "whAccent",
                15,
                "Tint the message to match the best drop, rare and above."
            )
            local value74 = uiLibrary.section(
                addAccount,
                "Stats",
                4.7,
                "Send what each run did to the key bot, so it can be totalled up and shown with /stats."
            )
            helper15(
                value74.content,
                "Send run stats",
                "statsEnabled",
                1,
                "One small post per finished run. Nothing is sent without an address below."
            )
            helper(
                uiLibrary.textInput(value74.content, "License key", function()
                    return config.statsKey
                end, function(argument)
                    config.statsKey = tostring(argument or "")
                    saveConfig()
                end, 3, "Leave blank - the loader's own key is used. Only fill this in for testing.", "auto")
            )
            uiSettings.statsNote = uiLibrary.caption(value74.content, "Stats: idle", 4)
            value73.setOpen(true)
            value73 = uiLibrary.section(
                addAccount,
                "Ping on a good drop",
                4.5,
                "Mention yourself - or everyone you list - in the post when something worth stopping for lands."
            )
            local dropdown, content2, value75 = uiLibrary.dropdown, value73.content, {}
            argumentHelpers:appendValues(
                value75,
                0,
                { value = "off", label = "Off" },
                { value = "epic", label = "Epic and up" },
                { value = "legendary", label = "Legendary and up" },
                { value = "ultimate", label = "Ultimate only" }
            )
            helper(dropdown(content2, "Ping on", value75, function()
                return config.whPingMin
            end, function(whPingMin)
                config.whPingMin = whPingMin
                saveConfig()
            end, 1, "The lowest rarity worth being pulled away from what you are doing."))
            helper15(
                value73.content,
                "Gildenscale T3 Mage / Warrior",
                "whPingValT3",
                2,
                "Also ping when a Gildenscale Mage or Gildenscale Warrior armor or helmet drops at tier 3: epic (purple) and up, whatever Ping on is set to. Blue and green Gildenscale do not ping. On by default. Needs at least one Discord user ID below."
            )
            helper(
                uiLibrary.listInput(
                    value73.content,
                    "Discord user IDs",
                    "One ID per box. A new box opens as you fill the last.",
                    function()
                        local value = {}
                        for entry in tostring(config.whPingId or ""):gmatch("%d+") do
                            value[#value + 1] = entry
                        end
                        return value
                    end,
                    function(argument)
                        local value, value2 = {}, {}
                        for index, entry in ipairs(argument) do
                            index = tostring(entry):gsub("%D", "")
                            if index ~= "" then
                                if not value2[index] then
                                    value2[index] = true
                                    value[#value + 1] = index
                                end
                            end
                        end
                        config.whPingId = table.concat(value, ", ")
                        helper16()
                    end,
                    3,
                    "Everyone listed is mentioned in the post - right-click a name in Discord and Copy User ID. Empty every box for no ping.",
                    "000000000000000000",
                    4
                )
            )
            value73.setOpen(false)
            uiLibrary.button(addAccount, "Send a test message", "accent", function()
                if context.WH then
                    context.WH.post({
                        username = context.WH.name and context.WH.name()
                            or tostring(config.webhookUser or "Swangy"),
                        embeds = {
                            { title = "Test", description = "Swangy is connected.", color = 3909981 },
                        },
                    })
                end
            end, 5, "Posts a short message so you can confirm the URL works.")
        end
        do
            local value76 = { busy = false, pending = false, last = nil }
            context.BG = value76
            local value77 = getService("ReplicatedStorage")
            local function helper71(argument)
                local remotes = value77:FindFirstChild("remotes")
                return remotes and (remotes:FindFirstChild(argument))
            end
            local function helper72(argument)
                local valueObject = localPlayer:FindFirstChild(argument)
                return valueObject and valueObject.Value
            end
            local function helper73()
                local leaderstats = localPlayer:FindFirstChild("leaderstats")
                local valueObject = leaderstats and (leaderstats:FindFirstChild("Level"))
                return valueObject and tonumber(valueObject.Value) or math.huge
            end
            local function helper74(argument)
                argument = tonumber(argument) or 0
                local value, value2 =
                    math.abs(argument), context.sig3 or function(argument2)
                        return ("%.2f"):format(argument2)
                    end
                if value >= 999500000000 then
                    return value2(argument / 1000000000000) .. "t"
                end
                if value >= 999500000 then
                    return value2(argument / 1000000000) .. "b"
                end
                if value >= 999500 then
                    return value2(argument / 1000000) .. "m"
                end
                if value >= 999.5 then
                    return value2(argument / 1000) .. "k"
                end
                return tostring(math.floor(argument + 0.5))
            end
            local function helper75()
                return config.classProfile == "warrior" and "Warrior" or "Mage"
            end
            local function helper76(argument, argument2, argument3)
                if argument3 == "Mage" then
                    return tonumber(argument.spellPower) or 0
                end
                if argument2 == "weapon" then
                    return tonumber(argument.physicalDamage) or 0
                end
                return tonumber(argument.physicalPower) or 0
            end
            local function helper77(argument)
                return tonumber(tostring(argument):match("_(%d+)$"))
            end
            local function helper78()
                if game.PlaceId == 77649408247578 then
                    return false
                end
                local dungeonStarted = workspaceService:FindFirstChild("dungeonStarted")
                if dungeonStarted then
                    if not (dungeonStarted.Value == true) then
                        return false
                    end
                else
                    return false
                end
                return not (context.LB and context.LB.runOverAt)
            end
            local value78 = {
                { bucket = "weapons", type = "weapon", label = "Weapon" },
                { bucket = "helmets", type = "helmet", label = "Helmet" },
                { bucket = "chests", type = "chest", label = "Armor" },
            }
            local function helper79(argument, argument2, argument3)
                local value, value2, value9, value10 = helper73(), {}, 1, 1
                for key, entry in pairs(argument or {}) do
                    if type(entry) == "table" then
                        if (tonumber(entry.levelReq) or 0) <= value then
                            if helper77(key) then
                                local main, value11 =
                                    helper76(entry, argument2, argument3), tonumber(entry.health) or 0
                                local value12, value13 = math.max(value9, main), math.max(value10, value11)
                                value2[#value2 + 1] =
                                    { n = helper77(key), key = key, item = entry, main = main, hp = value11 }
                                value9, value10 = value12, value13
                            end
                        end
                    end
                end
                value, argument, argument3 = nil
                for index, entry2 in ipairs(value2) do
                    index = if config.bestGearPriority == "Balanced"
                        then if argument2 ~= "weapon"
                            then 0.7 * entry2.main / value9 + 0.3 * entry2.hp / value10
                            else entry2.main + entry2.hp * 1.0E-9
                        else entry2.main + entry2.hp * 1.0E-9
                    if entry2.item.equipped == true then
                        index, value = index + 1.0E-12, entry2
                    end
                    if argument then
                        if index > argument then
                            argument, argument3 = index, entry2
                        end
                    else
                        argument, argument3 = index, entry2
                    end
                end
                return argument3, value
            end
            local function helper80(argument, argument2)
                local value = argument == "Mage" and "spellPower" or "physicalPower"
                local value2, value9 =
                    (tonumber(helper72(value == "spellPower" and "physicalPower" or "spellPower")) or 0)
                        + (tonumber(helper72("stamina")) or 0),
                    "Skill points: " .. (argument == "Mage" and "spell power" or "physical power")
                value9 = if value2 > 0 then value9 .. (" (%d elsewhere)"):format(value2) else value9
                argument = tonumber(helper72("skillPoints")) or 0
                if argument > 0 then
                    value9 ..= " +" .. argument
                    value2 = helper71("spendSkillPoint")
                    if value2 then
                        pcall(value2.FireServer, value2, value, argument)
                    end
                end
                argument2[#argument2 + 1] = value9
            end
            local planSpells, value79
            do
                local value80
                local function helper81(argument)
                    if not value80 then
                        value80 = {}
                        local iterateArray, value = ipairs, context.AS and context.AS.items or {}
                        for key, entry in iterateArray(value) do
                            if entry.kind == "ability" then
                                key = value80
                                key[entry.key] = entry.sub
                            end
                        end
                    end
                    local value2 = context.AS and context.AS.nameKey and context.AS.nameKey(argument.name)
                        or string.lower(tostring(argument.name))
                    local value9, value10 =
                        value80[value2], string.lower(tostring(argument.description or ""))
                    argument = value10:find("movement speed", 1, true) ~= nil
                    if value9 == "damaging" then
                        if value10:find("scales with spell", 1, true) then
                            return "Mage", false, argument
                        end
                        if value10:find("scales with physical", 1, true) then
                            return "Warrior", false, argument
                        end
                    elseif value9 == "boosting" then
                        if value10:find("spell damage", 1, true) then
                            return "Mage", true, argument
                        end
                        if value10:find("physical damage", 1, true) then
                            return "Warrior", true, argument
                        end
                    end
                    return nil, false, false
                end
                local function helper82(argument)
                    return argument ~= nil
                        and context.CARRY_SKILLS ~= nil
                        and context.CARRY_SKILLS[string.lower(tostring(argument))] == true
                end
                local value81 = { { "q", "e" }, { "q2", "e2" } }
                local function helper83()
                    local value, iterateArray, value2 =
                        {}, ipairs, { localPlayer:FindFirstChild("Backpack"), localPlayer.Character }
                    for key, entry in iterateArray(value2) do
                        if entry then
                            for index, child in ipairs(entry:GetChildren()) do
                                if child:IsA("Tool") then
                                    value[child.Name] = true
                                end
                            end
                        end
                    end
                    return value
                end
                planSpells = function(argument, argument2, argument3)
                    local value, slots, value2, value9 = helper73(), {}, {}, {}
                    for key, entry in pairs(argument.abilities or {}) do
                        local value10 = helper77(key)
                        if type(entry) == "table" and value10 then
                            local where
                            if type(entry.equipped) == "table" then
                                for key2, entry2 in pairs(entry.equipped) do
                                    if entry2 == true then
                                        slots[key2] = { n = value10, key = key, name = entry.name }
                                        where = key2
                                    end
                                end
                            end
                            if (tonumber(entry.levelReq) or 0) <= value then
                                if not (helper82(entry.name)) then
                                    local value11, buff, speed = helper81(entry)
                                    if value11 == argument2 then
                                        local value12, value13 =
                                            {
                                                n = value10,
                                                key = key,
                                                name = entry.name,
                                                buff = buff,
                                                speed = speed,
                                                req = tonumber(entry.levelReq) or 0,
                                                price = tonumber(entry.sellPrice) or 0,
                                                where = where,
                                            }, value9[entry.name]
                                        if value13 then
                                            if where then
                                                if not value13.where then
                                                    value9[entry.name] = value12
                                                end
                                            end
                                        else
                                            value9[entry.name] = value12
                                        end
                                    end
                                end
                            end
                        end
                    end
                    for key3, entry3 in pairs(value9) do
                        value2[#value2 + 1] = entry3
                    end
                    local function helper6(argument4, argument5, argument6, argument7)
                        if argument4.buff ~= argument5.buff then
                            return argument4.buff == argument6
                        end
                        if argument4.buff then
                            if argument4.speed ~= argument5.speed then
                                return argument4.speed
                            end
                        end
                        if argument4.req ~= argument5.req then
                            return argument4.req > argument5.req
                        end
                        local value14, value15 =
                            argument4.where ~= nil and argument4.where == argument7 and 2
                                or argument4.where ~= nil and 1
                                or 0,
                            argument5.where ~= nil and argument5.where == argument7 and 2
                                or argument5.where ~= nil and 1
                                or 0
                        if value14 ~= value15 then
                            return value14 > value15
                        end
                        if argument4.price ~= argument5.price then
                            return argument4.price > argument5.price
                        end
                        return tostring(argument4.name) < tostring(argument5.name)
                    end
                    local value16 = argument3 or (helper83())
                    local function helper23(argument4)
                        for index, entry4 in ipairs(argument4) do
                            index = slots[entry4]
                            if index then
                                if not value16[index.name] then
                                    return false
                                end
                            else
                                return false
                            end
                        end
                        return true
                    end
                    local value31, value32, moves, keep, value33 =
                        helper23(value81[2]) and not helper23(value81[1]) and { value81[2], value81[1] } or {
                            value81[1],
                            value81[2],
                        }, {}, {}, {}, argument2 == "Warrior" and "arrow rain" or "pulse waves"
                    local function helper45(argument4)
                        return argument4 ~= nil and string.lower(tostring(argument4.name)) == value33
                    end
                    value9 = false
                    for index2, entry5 in ipairs(value81) do
                        value9 = if helper45(slots[entry5[1]])
                            then if helper45(slots[entry5[2]]) then true else value9
                            else value9
                    end
                    if not value9 then
                        helper23 = {}
                        for key4, entry6 in pairs(argument.abilities or {}) do
                            argument2 = helper77(key4)
                            if type(entry6) == "table" then
                                if argument2 then
                                    if string.lower(tostring(entry6.name)) == value33 then
                                        if (tonumber(entry6.levelReq) or 0) <= value then
                                            helper23[#helper23 + 1] =
                                                { n = argument2, key = key4, name = entry6.name }
                                        end
                                    end
                                end
                            end
                        end
                        if #helper23 >= 2 then
                            local value34 = value81[2]
                            for index3, entry7 in ipairs(value81) do
                                value34 = if helper45(slots[entry7[1]])
                                    then entry7
                                    else if helper45(slots[entry7[2]]) then entry7 else value34
                            end
                            local value35 = {}
                            for index4, entry8 in ipairs(value34) do
                                if helper45(slots[entry8]) then
                                    value35[slots[entry8].n] = true
                                end
                            end
                            for index5, entry9 in ipairs(value34) do
                                if not (helper45(slots[entry9])) then
                                    index5 = nil
                                    for index6, entry10 in ipairs(helper23) do
                                        index5 = if value35[entry10.n] then index5 else index5 or entry10
                                    end
                                    if index5 then
                                        value35[index5.n] = true
                                        moves[#moves + 1] =
                                            { slot = entry9, n = index5.n, name = index5.name }
                                        for key5, slot in pairs(slots) do
                                            if slot.n == index5.n then
                                                slots[key5] = nil
                                            end
                                        end
                                        slots[entry9] = { n = index5.n, key = index5.key, name = index5.name }
                                    end
                                end
                            end
                        end
                    end
                    for index7, entry11 in ipairs(value81) do
                        for index8, entry12 in ipairs(entry11) do
                            if helper45(slots[entry12]) then
                                keep[slots[entry12].key] = true
                            end
                        end
                    end
                    argument = {}
                    for slot2 in pairs(slots) do
                        argument[slot2] = true
                    end
                    argument2 = false
                    for index9, entry13 in ipairs(value31) do
                        value, index9, value9 = {}, {}, not argument2
                        for index10, entry14 in ipairs(entry13) do
                            helper23 = helper45(slots[entry14])
                            if if helper23 then not helper23 else value9 or argument[entry14] then
                                value[#value + 1] = entry14
                                local value36
                                for index11, entry15 in ipairs(value2) do
                                    value36 = if value32[entry15.name]
                                        then value36
                                        else if value36
                                            then if helper6(entry15, value36, index10 == 1, entry14)
                                                then entry15
                                                else value36
                                            else entry15
                                end
                                if value36 then
                                    value32[value36.name] = true
                                    index9[entry14] = value36
                                    keep[value36.key] = true
                                end
                            end
                        end
                        argument2 = if #value > 0 then true else argument2
                        entry13 = true
                        for index12, entry16 in ipairs(value) do
                            local value37, value38 = index9[entry16], false
                            for index13, entry17 in ipairs(value) do
                                value38 = if value37
                                    then if slots[entry17]
                                        then if slots[entry17].name == value37.name then true else value38
                                        else value38
                                    else value38
                            end
                            entry13 = if value37 then if value38 then entry13 else false else entry13
                        end
                        if not entry13 then
                            for index14, entry18 in ipairs(value) do
                                index14 = index9[entry18]
                                if
                                    index14 and not (slots[entry18] and slots[entry18].name == index14.name)
                                then
                                    moves[#moves + 1] = { slot = entry18, n = index14.n, name = index14.name }
                                    for key6, slot3 in pairs(slots) do
                                        if slot3.n == index14.n then
                                            slots[key6] = nil
                                        end
                                    end
                                    slots[entry18] = { n = index14.n, key = index14.key, name = index14.name }
                                end
                            end
                        end
                    end
                    return { moves = moves, keep = keep, slots = slots }
                end
                local function helper84(argument, argument2, argument3)
                    local value, list = planSpells(argument, argument2), {}
                    for index, move in ipairs(value.moves) do
                        index = nil
                        for key, entry in pairs(argument.abilities or {}) do
                            index = if type(entry) == "table"
                                then if type(entry.equipped) == "table"
                                    then if entry.equipped[move.slot] == true
                                        then tostring(entry.name) .. "#" .. tostring(helper77(key))
                                        else index
                                    else index
                                else index
                        end
                        list[#list + 1] = ("%s <- %s#%s%s"):format(
                            move.slot,
                            tostring(move.name),
                            tostring(move.n),
                            index and " (took off " .. index .. ")" or ""
                        )
                    end
                    value76.lastMoves = { at = os.time(), list = list }
                    list, argument = 0, 0
                    for index2, move2 in ipairs(value.moves) do
                        local value2 = helper71("equipItem")
                        index2, argument2 = pcall(function()
                            return value2 and value2:InvokeServer("ability", move2.n, move2.slot)
                        end)
                        task.wait(0.15)
                        if index2 then
                            if argument2 == true then
                                local value9 = list + 1
                                list = value9
                            else
                                local value10 = argument + 1
                                argument = value10
                            end
                        else
                            local value11 = argument + 1
                            argument = value11
                        end
                    end
                    if list > 0 then
                        runtimeState.speedSetCache = nil
                    end
                    argument2 = {}
                    for index3, entry2 in ipairs(value81) do
                        local value12, value13 = value.slots[entry2[1]], value.slots[entry2[2]]
                        index3, entry2 =
                            value12 and value12.name or "empty", value13 and value13.name or "empty"
                        if helper82(value12 and value12.name) then
                            if helper82(value13 and value13.name) then
                                argument2[#argument2 + 1] = (
                                    index3 == entry2 and index3 .. " x2" or index3 .. " + " .. entry2
                                )
                                    .. " (carry kit, left alone)"
                            else
                                argument2[#argument2 + 1] = index3 .. " + " .. entry2
                            end
                        else
                            argument2[#argument2 + 1] = index3 .. " + " .. entry2
                        end
                    end
                    argument3[#argument3 + 1] = "Spells: "
                        .. table.concat(argument2, "  |  ")
                        .. (list > 0 and "  (" .. list .. " put on)" or "")
                        .. (argument > 0 and "  (" .. argument .. " could not be put on)" or "")
                    return list
                end
                value79 = helper84
            end
            value76.planSpells = planSpells
            local value82
            value76.keepers = function(argument)
                local value, value2 = {}, helper75()
                for index, entry in ipairs(value78) do
                    index = helper79(argument[entry.bucket], entry.type, value2)
                    if index then
                        value[entry.bucket .. ":" .. tostring(index.key)] = true
                    end
                end
                local success, value9 = pcall(planSpells, argument, value2)
                if success and type(value9) == "table" then
                    for entry2 in pairs(value9.keep) do
                        value["abilities:" .. tostring(entry2)] = true
                    end
                end
                local value10, value11, value12 = value2 == "Warrior" and "arrow rain" or "pulse waves", {}, 0
                for key, entry3 in pairs(argument.abilities or {}) do
                    if type(entry3) == "table" then
                        if string.lower(tostring(entry3.name)) == value10 then
                            value9 = false
                            if type(entry3.equipped) == "table" then
                                for key2, entry4 in pairs(entry3.equipped) do
                                    value9 = if entry4 == true then true else value9
                                end
                                if value9 then
                                    value12 += 1
                                else
                                    value11[#value11 + 1] = key
                                end
                            else
                                value11[#value11 + 1] = key
                            end
                        end
                    end
                end
                table.sort(value11, function(argument2, argument3)
                    return tostring(argument2) < tostring(argument3)
                end)
                for index2 = 1, math.min(#value11, math.max(0, 2 - value12)), 1 do
                    value["abilities:" .. tostring(value11[index2])] = true
                end
                return value
            end
            value76.run = function()
                if value76.busy then
                    return
                end
                if context.isEvent then
                    if context.isEvent() then
                        value76.last = "Not in an event run - its gear comes from Quick Gear Select."
                        if value82 then
                            value82.Text = value76.last
                        end
                        return
                    end
                end
                value76.busy = true
                local value
                pcall(function()
                    local value2 = helper71("reloadInvy")
                    value = value2 and value2:InvokeServer()
                end)
                if type(value) ~= "table" then
                    value76.busy = false
                    value76.last = "Could not read the bag - it tries again on the next change."
                    if value82 then
                        value82.Text = value76.last
                    end
                    return
                end
                if context.AS then
                    if context.AS.noteWorn then
                        pcall(context.AS.noteWorn, value)
                    end
                end
                local value9, value10, value11 = helper75(), {}, 0
                for index, entry in ipairs(value78) do
                    local value12, value13 = helper79(value[entry.bucket], entry.type, value9)
                    if value12 then
                        local value14, value15 = if value13 then value13.n ~= value12.n else not value13, true
                        if value14 then
                            local value16 = helper71("equipItem")
                            local success, value31 = pcall(function()
                                return value16 and value16:InvokeServer(entry.type, value12.n)
                            end)
                            value15 = value16 ~= nil and success and value31 ~= false
                            value11 = if value15 then value11 + 1 else value11
                            task.wait(0.15)
                        end
                        local value32, label, toString, item =
                            #value10 + 1, entry.label, tostring, value12.item
                        local value33, value34, value35 =
                            toString(item.name),
                            helper74(value12.main),
                            value14 and (value15 and "  (put on)" or "  (could not put on)")
                        value10[value32] = ("%s: %s  %s%s"):format(label, value33, value34, value35 or "")
                    end
                end
                if config.bestGearSpells ~= false then
                    local success2, value36 = pcall(value79, value, value9, value10)
                    if success2 then
                        value11 += tonumber(value36) or 0
                    else
                        value10[#value10 + 1] = "Spells: could not be put on"
                    end
                else
                    value10[#value10 + 1] = "Spells: left as they are (Equip best spells is off)"
                end
                if config.bestGearSkills ~= false then
                    helper80(value9, value10)
                else
                    value10[#value10 + 1] = "Skill points: left as they are (Spend skill points is off)"
                end
                value76.busy = false
                value76.last = ("%s - %s\10%s"):format(
                    value9,
                    value11 == 0 and "already wearing the best" or value11 .. " swapped",
                    table.concat(value10, "\10")
                )
                if value82 then
                    value82.Text = value76.last
                end
                return value11
            end
            value76.check = function()
                if config.bestGearAuto ~= true then
                    return
                elseif value76.pending then
                    return
                end
                if context.isEvent then
                    if context.isEvent() then
                        return
                    end
                end
                value76.pending = true
                task.delay(0.5, function()
                    value76.pending = false
                    if runtimeState.destroyed then
                        return
                    elseif config.bestGearAuto ~= true then
                        return
                    end
                    if config.bestGearOutOfRun ~= false then
                        if helper78() then
                            value76.afterRun = true
                            return
                        end
                    end
                    value76.afterRun = false
                    value76.run()
                end)
            end
            value76.beforeSale = function()
                if config.bestGearAuto ~= true then
                    return
                end
                if config.bestGearOutOfRun ~= false then
                    if helper78() then
                        return
                    end
                end
                local now = os.clock()
                while value76.busy and os.clock() - now < 20 do
                    task.wait(0.2)
                end
                if not value76.busy then
                    value76.run()
                end
            end
            addAccount, value3 = context.sliderConnections, { "updateLocalInventoryTable", "reloadInventory" }
            for index15, entry19 in ipairs(value3) do
                runsThisAccount = helper71(entry19)
                if runsThisAccount then
                    if runsThisAccount:IsA("RemoteEvent") then
                        addAccount[#addAccount + 1] = runsThisAccount.OnClientEvent:Connect(function()
                            value76.check()
                        end)
                    end
                end
            end
            local value83 = localPlayer:FindFirstChild("skillPoints")
            if value83 then
                addAccount[#addAccount + 1] = value83.Changed:Connect(function()
                    value76.check()
                end)
            end
            value83 = localPlayer:FindFirstChild("leaderstats")
            local value84 = value83 and (value83:FindFirstChild("Level"))
            if value84 then
                addAccount[#addAccount + 1] = value84.Changed:Connect(function()
                    value76.check()
                end)
            end
            task.spawn(function()
                task.wait(8)
                value76.check()
                while not runtimeState.destroyed do
                    task.wait(2)
                    if value76.afterRun then
                        if not (helper78()) then
                            value76.check()
                        end
                    end
                end
            end)
            value83 = uiLibrary.section(
                value6,
                "Gear, Spells & Stats",
                2,
                "Wears the strongest weapon, helmet and armor for the Class picked above, puts its best spells on and spends its skill points on its stat - the spells and the skill points each have their own switch. Auto sell never sells what it picks. These settings are the same on every account on this PC."
            ).content
            helper15(
                value83,
                "Auto mode",
                "bestGearAuto",
                1,
                "Gear by itself - and the spells and skill points while their switches are on - whenever the bag, the level or the skill points change, and always before a sale. Pulse Waves and Arrow Rain (the 1-186 carry kit) are never moved. Every account on this PC at once. Off: only Apply best now.",
                function(argument)
                    if argument then
                        task.spawn(value76.run)
                    end
                end
            )
            local dropdown2, value85 = uiLibrary.dropdown, {}
            argumentHelpers:appendValues(
                value85,
                0,
                { value = "Damage", label = "Damage" },
                { value = "Balanced", label = "Balanced" }
            )
            helper(
                dropdown2(
                    value83,
                    "Priority",
                    value85,
                    function()
                        return config.bestGearPriority == "Balanced" and "Balanced" or "Damage"
                    end,
                    function(bestGearPriority)
                        config.bestGearPriority = bestGearPriority
                        saveConfig()
                        value76.check()
                    end,
                    2,
                    "Damage: the biggest class stat wins. Balanced: helmet and armor weigh 70% damage and 30% health. The weapon is always damage."
                )
            )
            if config.bestGearSpells == nil then
                config.bestGearSpells = true
            end
            if config.bestGearSkills == nil then
                config.bestGearSkills = true
            end
            helper15(
                value83,
                "Equip best spells",
                "bestGearSpells",
                3,
                "Puts the best class spells on with the gear: a speed buff on Q and the best attack on E. A slot holding the carry kit is never touched. Off: your spells stay as you set them.",
                function(argument)
                    if argument then
                        value76.check()
                    end
                end
            )
            helper15(
                value83,
                "Spend skill points",
                "bestGearSkills",
                4,
                "Every unspent skill point goes into the class stat - spell power for a Mage, physical power for a Warrior - as soon as it is earned. Off: the points are left for you to spend.",
                function(argument)
                    if argument then
                        value76.check()
                    end
                end
            )
            helper15(
                value83,
                "Only swap outside a run",
                "bestGearOutOfRun",
                5,
                "Waits for the lobby, the wait before Start or the end of a run. Off: it swaps the moment something better drops."
            )
            value84 = uiLibrary
                .buttonRow(value83, 6)
                .add(
                    "Apply best now",
                    "accent",
                    function()
                        task.spawn(value76.run)
                    end,
                    "Gear now on this account - and the spells and skill points while their switches are on - whether Auto mode is on or not."
                )
                :FindFirstChildOfClass("UISizeConstraint")
            if value84 then
                value84:Destroy()
            end
            value82 = uiLibrary.caption(
                value83,
                value76.last or "Nothing done yet - turn on Auto mode or press Apply best now.",
                7
            )
            do
                local value86 = {
                    "bestGearAuto",
                    "bestGearPriority",
                    "bestGearSpells",
                    "bestGearSkills",
                    "bestGearOutOfRun",
                }
                local value87 = getService("HttpService")
                local function helper85()
                    local value = {}
                    for index, entry in ipairs(value86) do
                        value[#value + 1] = config[entry] == nil and { entry } or { entry, config[entry] }
                    end
                    local success, value2 = pcall(function()
                        return value87:JSONEncode(value)
                    end)
                    return success and value2 or nil
                end
                local function helper86(argument, argument2)
                    local success, value = pcall(function()
                        return value87:JSONDecode(argument)
                    end)
                    if success then
                        if type(value) ~= "table" then
                            return false
                        end
                    else
                        return false
                    end
                    success = {}
                    for index, entry in ipairs(value86) do
                        success[entry] = true
                    end
                    for index2, entry2 in ipairs(value) do
                        if type(entry2) == "table" then
                            if success[entry2[1]] then
                                config[entry2[1]] = entry2[2]
                            end
                        end
                    end
                    pcall(saveConfig)
                    refreshAll()
                    if not argument2 then
                        value76.check()
                    end
                    return true
                end
                local function helper87()
                    local success, value = pcall(function()
                        return isfile("HarvardLabs/configs/bestgear_shared.json")
                                and readfile("HarvardLabs/configs/bestgear_shared.json")
                            or nil
                    end)
                    return success and value or nil
                end
                local value88
                value84 = helper87()
                if value84 and (helper86(value84, true)) then
                    value88 = value84
                else
                    value83 = helper85()
                    if value83 then
                        pcall(writefile, "HarvardLabs/configs/bestgear_shared.json", value83)
                        value88 = value83
                    end
                end
                local value89, value90 = helper85(), value88
                local value91 = value89
                task.spawn(function()
                    while not runtimeState.destroyed do
                        task.wait(1)
                        pcall(function()
                            local value = helper87()
                            if value then
                                if value ~= value90 then
                                    value90 = value
                                    helper86(value)
                                    value91 = helper85()
                                    return
                                end
                            end
                            value = helper85()
                            if value then
                                if value ~= value91 then
                                    value91 = value
                                    pcall(writefile, "HarvardLabs/configs/bestgear_shared.json", value)
                                    value90 = value
                                end
                            end
                        end)
                    end
                end)
            end
        end
        runsThisAccount = uiLibrary.section(
            value6,
            "Connection",
            8.5,
            "How far ahead of itself the bot has to dodge to allow for the round trip."
        )
        helper17(
            runsThisAccount.content,
            "Ping",
            "ms",
            0,
            400,
            false,
            "pingManual",
            1,
            "Leave this at 0 and your ping is read from the server every second, which is right for nearly everyone. Set it if that reading swings about and the dodges look mistimed: put in the ping you actually see. Higher means the bot leaves more room, so it dodges earlier and stands further off.",
            10
        )
        runsThisAccount.setOpen(true)
        runsThisAccount =
            uiLibrary.section(value6, "Script", 9, "The key that opens this window, and the off switch.")
        uiSettings.menuKeyButton = uiLibrary.button(
            runsThisAccount.content,
            "Menu key: " .. tostring(config.menuKey) .. " (click, then press a key)",
            "accent",
            function()
                runtimeState.menuKeyCapture = true
                runtimeState.mapKeyCapture = false
                if uiSettings.mapKeyButton then
                    uiSettings.mapKeyButton.Text = "Map key: "
                        .. tostring(config.mapKey)
                        .. " (click, then press a key)"
                end
                if uiSettings.menuKeyButton then
                    uiSettings.menuKeyButton.Text = "Press the new key... (Escape cancels)"
                end
            end,
            1,
            "Rebind the key that opens and closes this window: click, then press the new key. Escape keeps the old one."
        )
        uiLibrary.button(
            runsThisAccount.content,
            "Close the script",
            "danger",
            destructScript,
            2,
            "Remove everything this script made and stop."
        )
        runsThisAccount.setOpen(true)
        local dim = Instance.new("Frame")
        dim.Name, dim.BackgroundColor3, dim.BackgroundTransparency, dim.BorderSizePixel, dim.Size =
            "Dim", Color3.new(0, 0, 0), 0.5, 0, UDim2.fromScale(1, 1)
        dim.Visible = false
        dim.ZIndex = 1
        dim.Parent = dungeonAutofarmUi
        do
            local inventoryAutomation = context.AS
            local body, helper88 = weakKeys(
                "AutoSell",
                "Auto Sell",
                716,
                24,
                330,
                statusChip,
                "Sell what drops, keep what matters."
            ).body
            local value92 = {
                { cfg = "sellCommon", label = "Common", hint = "The gray drops." },
                { cfg = "sellUncommon", label = "Uncommon", hint = "The green drops." },
                { cfg = "sellRare", label = "Rare", hint = "The blue drops." },
                { cfg = "sellEpic", label = "Epic", hint = "The purple drops." },
                { cfg = "sellLegendary", label = "Legendary", hint = "The orange drops. Off to begin with." },
                {
                    cfg = "sellUltimate",
                    label = "Ultimate",
                    hint = "The red drops - the very best. Off to begin with.",
                },
            }
            local function helper89()
                local value = {}
                for index, entry in ipairs(value92) do
                    if config[entry.cfg] == true then
                        value[#value + 1] = string.lower(entry.label)
                    end
                end
                return value
            end
            local function helper90()
                local value = helper89()
                if config.autoSell ~= true then
                    if #value == 0 then
                        return "Switched off. No rarities are ticked either, so it would sell nothing."
                    end
                    local value2, value9, value10, value11 =
                        table.concat(value, ", "),
                        tonumber(config.sellKeepLevel) or 0,
                        inventoryAutomation.keptCount(),
                        inventoryAutomation.keptCount() == 1 and "" or "s"
                    return ("Switched off. It would sell %s, keeping level %d and up and %d protected item%s."):format(
                        value2,
                        value9,
                        value10,
                        value11
                    )
                end
                local value12, value13, value14, totalSold, note =
                    inventoryAutomation.sellAfter(),
                    inventoryAutomation.games(),
                    #value == 0 and "No rarities ticked" or "Selling " .. table.concat(value, ", "),
                    inventoryAutomation.totalSold,
                    inventoryAutomation.note
                return ("On: sells every %d games right in the dungeon, and on every arrival in the lobby (%d played since the last sale). %s. Sold %d so far. Last: %s."):format(
                    value12,
                    value13,
                    value14,
                    totalSold,
                    note
                )
            end
            value3 = uiLibrary.section(
                body,
                "Auto sell",
                0.5,
                "Sells unequipped items out of your bag every few games right in the dungeon - no trip to the lobby - and whenever it arrives in the lobby."
            )
            local textControl8 = uiLibrary.caption(value3.content, helper90(), 2)
            local textControl9 = uiLibrary.caption(value3.content, "", 3)
            textControl9.Visible = false
            local value93 = uiLibrary.buttonRow(value3.content, 4)
            value93.frame.Visible = false
            local function helper91()
                value93.frame.Visible = false
                textControl9.Visible = false
            end
            helper(uiLibrary.toggle(value3.content, "Enabled", function()
                return config.autoSell == true
            end, function(argument)
                if argument ~= true then
                    config.autoSell = false
                    helper91()
                    saveConfig()
                    textControl8.Text = helper90()
                    refreshAll()
                    return
                end
                argument = helper89()
                textControl9.Visible = true
                textControl9.Text = #argument == 0
                        and "No rarities are ticked, so this would sell nothing. Tick the ones you want sold first."
                    or ("THIS SELLS ITEMS AND CANNOT BE UNDONE.\10Every unequipped %s item in your bag will be sold, every %d games and on every arrival in the lobby, except items at level %d or above and the %d you have protected. Are you sure?"):format(
                        table.concat(argument, ", "),
                        inventoryAutomation.sellAfter(),
                        tonumber(config.sellKeepLevel) or 0,
                        inventoryAutomation.keptCount()
                    )
                value93.frame.Visible = #argument > 0
                refreshAll()
            end, 1, "Nothing is sold until you confirm it."))
            helper17(
                value3.content,
                "Sell after",
                " games",
                1,
                50,
                false,
                "sellAfterGames",
                1,
                "How many games between sales. The sale happens in the dungeon as that game starts, one item a second. It also sells on every arrival in the lobby.",
                1
            )
            value93.add("Yes, sell them", "danger", function()
                config.autoSell = true
                helper91()
                saveConfig()
                textControl8.Text = helper90()
                refreshAll()
            end, "Start selling: every few games in the dungeon, and on arrival in the lobby.")
            value93.add("Cancel", "accent", function()
                helper91()
                refreshAll()
            end, "Leave it switched off.")
            uiLibrary.buttonRow(value3.content, 5).add("Sell once now", "accent", function()
                if inventoryAutomation.busy then
                    return
                end
                inventoryAutomation.busy = true
                pcall(inventoryAutomation.sellNow)
                inventoryAutomation.busy = false
                textControl8.Text = helper90()
            end, "Sell now - in a dungeon or in the lobby.")
            value3.setOpen(true)
            addAccount = uiLibrary.section(
                body,
                "Rarities to sell",
                1,
                "Rarity belongs to the drop, so this is read off each item as it is found."
            )
            for index16, entry20 in ipairs(value92) do
                if entry20.cfg == "sellLegendary" or entry20.cfg == "sellUltimate" then
                    helper(uiLibrary.toggle(addAccount.content, entry20.label, function()
                        return config[entry20.cfg]
                    end, function(argument)
                        local function helper6(argument2)
                            config[entry20.cfg] = argument2
                            saveConfig()
                            if config.autoSell == true then
                                helper91()
                            end
                            textControl8.Text = helper90()
                            refreshAll()
                        end
                        if argument ~= true then
                            helper6(false)
                            return
                        end
                        local confirmPop, value, label, value2, value9, value10 =
                            context.confirmPop,
                            { title = "Sell " .. entry20.label .. " items?", icon = "coins" },
                            entry20.label,
                            entry20.label:lower(),
                            config.autoSell == true and ", starting with the next check"
                                or " once auto sell is switched on",
                            tonumber(config.sellKeepLevel)
                        value.text = ("Ticking %s makes auto sell SELL every unequipped %s item in your bag%s (only items at level %d or above and the ones you protected are kept). A sold item cannot be brought back. Are you sure?"):format(
                            label,
                            value2,
                            value9,
                            value10 or 0
                        )
                        value.yes = "Yes, sell " .. entry20.label
                        value.no = "Cancel"
                        value.onYes = function()
                            helper6(true)
                        end
                        confirmPop(value)
                    end, index16, entry20.hint))
                else
                    helper15(addAccount.content, entry20.label, entry20.cfg, index16, entry20.hint, function()
                        if config.autoSell == true then
                            helper91()
                        end
                        textControl8.Text = helper90()
                    end)
                end
            end
            addAccount.setOpen(true)
            helper17(
                uiLibrary.section(body, "Limits", 2, "The guards that apply on top of the rarities.").content,
                "Keep level and above",
                "",
                0,
                200,
                false,
                "sellKeepLevel",
                1,
                "Anything needing this level or higher is never sold. 0 turns the guard off.",
                1
            )
            local value94, value95, value96, value97 =
                uiLibrary.section(
                    body,
                    "Protected items",
                    3,
                    "Switch an item on to keep it in every rarity, or light only the rarities to keep under it - it is never sold as a lit one. 898 items, straight off the wiki."
                ),
                { text = "", kind = "any", dung = "any", tier = "any" },
                { { value = "any", label = "Every dungeon" } },
                {}
            for index17, dungeon in ipairs(inventoryAutomation.dungeons) do
                value97[dungeon] = true
            end
            for index18, entry21 in ipairs(context.QUEUE_MAPS or inventoryAutomation.dungeons) do
                if value97[entry21] then
                    value96[#value96 + 1] = { value = entry21, label = entry21 }
                end
            end
            helper(uiLibrary.textInput(value94.content, "Search", function()
                return value95.text
            end, function(argument)
                value95.text = tostring(argument or "")
                helper88()
            end, 1, "Part of an item name.", "mjolnir"))
            helper(uiLibrary.dropdown(value94.content, "Type", {
                { value = "any", label = "Everything" },
                { value = "weapon", label = "Weapons" },
                { value = "ability", label = "Spells" },
                { value = "helmet", label = "Helmets" },
                { value = "chest", label = "Armor" },
            }, function()
                return value95.kind
            end, function(kind)
                value95.kind = kind
                helper88()
            end, 2, "Weapons, spells, helmets or armor."))
            helper(uiLibrary.dropdown(value94.content, "Dungeon", value96, function()
                return value95.dung
            end, function(dung)
                value95.dung = dung
                helper88()
            end, 3, "Where the item comes from."))
            helper(
                uiLibrary.dropdown(
                    value94.content,
                    "Rarity",
                    {
                        { value = "any", label = "Any rarity" },
                        { value = "legendary", label = "Legendary" },
                        { value = "ultimate", label = "Ultimate" },
                        { value = "epic", label = "Epic" },
                        { value = "rare", label = "Rare" },
                        { value = "uncommon", label = "Uncommon" },
                        { value = "common", label = "Common" },
                        { value = "", label = "Untagged" },
                    },
                    function()
                        return value95.tier
                    end,
                    function(tier)
                        value95.tier = tier
                        helper88()
                    end,
                    4,
                    "The wiki's base tier. Most of the game is untagged, which is why the sell rules do not use it."
                )
            )
            local value98 = {}
            value98.common = Color3.fromHex("94a5b8")
            value98.uncommon = Color3.fromHex("22c55e")
            value98.rare = Color3.fromHex("3b80f6")
            value98.epic = Color3.fromHex("a855f6")
            value98.legendary = Color3.fromHex("ff9900")
            value98.ultimate = Color3.fromHex("ff3b3b")
            local value99 = {
                common = "Com",
                uncommon = "Unc",
                rare = "Rare",
                epic = "Epic",
                legendary = "Leg",
                ultimate = "Ult",
            }
            local textControl10 = uiLibrary.caption(value94.content, "", 5)
            local value100, items = uiLibrary.buttonRow(value94.content, 6), Instance.new("Frame")
            items.Name = "Items"
            items.BackgroundTransparency = 1
            items.AutomaticSize = Enum.AutomaticSize.Y
            items.Size = UDim2.new(1, 0, 0, 0)
            items.LayoutOrder = 7
            items.Parent = value94.content
            uiLibrary.vlist(items, 8)
            local function helper92(argument)
                if value95.kind ~= "any" then
                    if argument.kind ~= value95.kind then
                        return false
                    end
                end
                if value95.dung ~= "any" then
                    if argument.dung ~= value95.dung then
                        return false
                    end
                end
                if value95.tier ~= "any" then
                    if argument.tier ~= value95.tier then
                        return false
                    end
                end
                if value95.text ~= "" then
                    if
                        not (string.find(argument.key, inventoryAutomation.nameKey(value95.text), 1, true))
                    then
                        return false
                    end
                end
                return true
            end
            local function helper93()
                local value = {}
                for index = 1, #inventoryAutomation.items, 1 do
                    local value2 = inventoryAutomation.items[index]
                    if helper92(value2) then
                        value[#value + 1] = value2
                    end
                end
                return value
            end
            helper88 = function()
                for index, child in ipairs(items:GetChildren()) do
                    if not (child:IsA("UIListLayout")) then
                        child:Destroy()
                    end
                end
                local value, value2 = helper93(), math.max(tonumber(config.sellListMax) or 40, 5)
                local value9 = math.min(#value, value2)
                for index2 = 1, value9, 1 do
                    local value10 = value[index2]
                    local value11, item =
                        value10.tier ~= "" and " - " .. value10.tier or "", Instance.new("Frame")
                    item.Name, item.BackgroundTransparency, item.AutomaticSize =
                        "Item", 1, Enum.AutomaticSize.Y
                    item.Size = UDim2.new(1, 0, 0, 0)
                    item.LayoutOrder = index2
                    item.Parent = items
                    uiLibrary.vlist(item, 3)
                    local value12, helper6 = {}
                    local value13 = value10.tier ~= ""
                    local value14 = uiLibrary.toggle(
                        item,
                        value10.name,
                        function()
                            return inventoryAutomation.isKept(value10.name, value13 and value10.tier or nil)
                        end,
                        function(argument)
                            inventoryAutomation.setKept(value10.name, argument)
                            saveConfig()
                            textControl8.Text = helper90()
                            helper6()
                        end,
                        1,
                        value13
                                and ("%s%s%s. Always drops as %s. On: never sold."):format(
                                    value10.kind,
                                    value11,
                                    value10.dung ~= "" and " - " .. value10.dung or "",
                                    value10.tier
                                )
                            or ("%s%s%s. On: kept in every rarity. Light only some rarities below to keep just those."):format(
                                value10.kind,
                                value11,
                                value10.dung ~= "" and " - " .. value10.dung or ""
                            )
                    )
                    index2 = Instance.new("Frame")
                    index2.Name, index2.BackgroundTransparency, index2.Size =
                        "Rarities", 1, UDim2.new(1, 0, 0, 22)
                    index2.LayoutOrder = 2
                    index2.Visible = not value13
                    index2.Parent = item
                    uiLibrary.hlist(index2, 4)
                    helper6 = function()
                        for index3, entry in ipairs(value12) do
                            local value15, value16 =
                                inventoryAutomation.isKept(value10.name, entry.t), value98[entry.t]
                            index3 = 0.299 * value16.R + 0.587 * value16.G + 0.114 * value16.B > 0.5
                            entry.b.BackgroundColor3 = value15 and value16 or uiLibrary.Theme.SurfaceField
                            local textControl7, value31 =
                                entry.b, value15 and (index3 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1))
                            textControl7.TextColor3 = value31 or uiLibrary.Theme.TextMuted
                            entry.s.Color = value15 and value16 or uiLibrary.Theme.Hairline
                        end
                    end
                    for index4, entry2 in ipairs(inventoryAutomation.TIER_ORDER) do
                        item = Instance.new("TextButton")
                        item.Name, item.AutoButtonColor, item.BorderSizePixel, item.Text =
                            inventoryAutomation.TIER_LONG[entry2], false, 0, value99[entry2]
                        item.TextSize = 11
                        item.Size = UDim2.new(0.16666666666666666, -4, 1, 0)
                        item.LayoutOrder = index4
                        uiLibrary.setFont(item, "sans", Enum.FontWeight.SemiBold)
                        uiLibrary.corner(item, uiLibrary.Theme.RadiusSm)
                        value12[index4] =
                            { t = entry2, b = item, s = uiLibrary.stroke(item, uiLibrary.Theme.Hairline, 1) }
                        item.Parent = index2
                        local function helper23()
                            local value15, value16 = inventoryAutomation.keptRule(value10.name), {}
                            for index3, entry in ipairs(inventoryAutomation.TIER_ORDER) do
                                value16[entry] = value15 == true
                                    or type(value15) == "table" and value15[entry] == true
                            end
                            value16[entry2] = not value16[entry2]
                            inventoryAutomation.setKept(value10.name, value16)
                            saveConfig()
                            textControl8.Text = helper90()
                            helper6()
                            value14.render()
                        end
                        item.MouseButton1Click:Connect(helper23)
                        uiLibrary.tip(
                            item,
                            ("%s %s: lit = kept, never sold when it drops as %s."):format(
                                inventoryAutomation.TIER_LONG[entry2],
                                value10.name,
                                inventoryAutomation.TIER_LONG[entry2]
                            )
                        )
                    end
                    helper6()
                end
                textControl10.Text = #value == 0 and "Nothing matches that."
                    or ("Showing %d of %d. %d protected in total."):format(
                        value9,
                        #value,
                        inventoryAutomation.keptCount()
                    )
            end
            value100.add(
                "Protect these",
                "accent",
                function()
                    for index, entry in ipairs(helper93()) do
                        inventoryAutomation.setKept(entry.name, true)
                    end
                    saveConfig()
                    helper88()
                    textControl8.Text = helper90()
                    refreshAll()
                end,
                "Protect every item the filters above are showing, not only the ones on screen, in every rarity."
            )
            value100.add("Unprotect these", "accent", function()
                for index, entry in ipairs(helper93()) do
                    inventoryAutomation.setKept(entry.name, false)
                end
                saveConfig()
                helper88()
                textControl8.Text = helper90()
                refreshAll()
            end, "Drop the protection from every item the filters are showing.")
            helper88()
        end
        do
            local partyQueue = context.AF
            value6 = weakKeys(
                "AltFarm",
                "Party",
                1062,
                24,
                330,
                statusChip,
                "Every run starts from a party - one account on its own is a party of one. Each party queues and runs its own dungeon."
            ).body
            local function helper94(argument)
                return partyQueue.editParty(argument)
            end
            local textControl11, textControl12, textControl13 =
                { Text = "", Visible = false }, { Text = "" }, { Text = "" }
            value3 = uiLibrary.section(
                value6,
                "Parties",
                0,
                "Every run starts from a party; one account alone is a party of one (Just me). An account is in one party. The crown leads. Carry: plays the dungeon with its own abilities. Leech: an alt that waits at spawn for the XP - with leechers on the list the carries level them up."
            )
            local helper95
            local partyPick = Instance.new("Frame")
            partyPick.Name, partyPick.BackgroundTransparency, partyPick.AutomaticSize =
                "PartyPick", 1, Enum.AutomaticSize.Y
            partyPick.Size = UDim2.new(1, 0, 0, 0)
            partyPick.LayoutOrder = 0
            partyPick.Parent = value3.content
            uiLibrary.vlist(partyPick, 4)
            local value101
            local function helper96()
                local value, P, value2 = partyQueue.parties(), helper94()
                local u, value9 = partyQueue.partyOf(localPlayer.Name)
                local value10 = ("%d|%s|%s"):format(#value, tostring(value2), tostring(value9))
                if value10 == value101 then
                    return
                end
                value101 = value10
                for index, child in ipairs(partyPick:GetChildren()) do
                    if not (child:IsA("UIListLayout")) then
                        child:Destroy()
                    end
                end
                local value11, value12 = uiLibrary.buttonRow(partyPick, 1), #value
                for index2 = 1, value12, 1 do
                    value10 = (#value <= 3 and "Party " .. index2 or tostring(index2))
                        .. (index2 == value9 and " *" or "")
                    value11.add(
                        value10,
                        index2 == value2 and "accent" or "plain",
                        function()
                            partyQueue.pickParty(index2)
                            value101 = nil
                            helper95()
                            refreshAll()
                        end,
                        ("Show party %d%s."):format(
                            index2,
                            index2 == value9 and " - this account's party" or ""
                        )
                    )
                end
                value11.add("New", "plain", function()
                    partyQueue.newParty()
                    value101 = nil
                    helper95()
                    refreshAll()
                end, "Start another party with its own accounts, leader and dungeon.")
            end
            local value102 = ""
            local value103 = uiLibrary.textInput(value3.content, "Username", function()
                local value = value102
                return value
            end, function(argument)
                value102 = tostring(argument or "")
            end, 1, "The account's Roblox username - not its display name.", "roblox username")
            local textControl14 = uiLibrary.caption(value3.content, "", 3)
            textControl14.Visible = false
            local altRows = Instance.new("Frame")
            altRows.Name = "AltRows"
            altRows.BackgroundTransparency = 1
            altRows.AutomaticSize = Enum.AutomaticSize.Y
            altRows.Size = UDim2.new(1, 0, 0, 0)
            altRows.LayoutOrder = 4
            altRows.Parent = value3.content
            uiLibrary.vlist(altRows, 4)
            local value104 = uiLibrary.caption(
                value3.content,
                "No accounts in this party yet. Type a username above, or press Find accounts.",
                5
            )
            runsThisAccount = uiLibrary.buttonRow(value3.content, 6)
            helper(
                uiLibrary.toggle(
                    value3.content,
                    "Run this party",
                    function()
                        return helper94().on == true
                    end,
                    function(argument)
                        helper94(true).on = argument == true
                        partyQueue.save()
                        pcall(context.refreshQueueMode)
                    end,
                    7,
                    "On: the leader makes a private party, every account on the list meets it in its server and joins, and the leader starts and replays the runs. Off: nobody on this party queues - runs only ever start from a party."
                )
            )
            value3.setOpen(true)
            local value105 = {}
            local function helper97(text)
                textControl14.Text = text
                textControl14.Visible = text ~= ""
            end
            local function helper98(argument)
                for index, account in ipairs(argument.accounts) do
                    if account.role == "leader" then
                        return true
                    end
                end
                return false
            end
            local function helper99(name2)
                local value = helper94(true)
                if partyQueue.entry(name2, value) then
                    return false, "is already in this party"
                end
                local value2, accounts = partyQueue.partyOf(name2)
                if value2 then
                    if value2 ~= value then
                        return false, ("is in Party %d - take it off there first"):format(accounts or 0)
                    end
                end
                value2, accounts = value.accounts, value.accounts
                local value9, value10 = #accounts + 1, { name = name2 }
                value10.role, value10.enabled, value2[value9] =
                    helper98(value) and "leech" or "leader", true, value10
                return true
            end
            local function helper100()
                local value = tostring(value103.box.Text or value102 or ""):gsub("^%s+", ""):gsub("%s+$", "")
                if value == "" then
                    helper97("Type a username first.")
                    return
                end
                if value:match("^[%w_]+$") then
                    if #value < 3 then
                        helper97("That is not a Roblox username - 3 to 20 letters, numbers or _.")
                        return
                    elseif #value > 20 then
                        helper97("That is not a Roblox username - 3 to 20 letters, numbers or _.")
                        return
                    end
                else
                    helper97("That is not a Roblox username - 3 to 20 letters, numbers or _.")
                    return
                end
                local value2, value9 = helper99(value)
                if not value2 then
                    helper97(value .. " " .. tostring(value9) .. ".")
                    return
                end
                partyQueue.save()
                value102, value103.box.Text = "", ""
                helper97("")
                helper95()
            end
            local value106, helper101 =
                value103.box, function(argument)
                    if argument then
                        helper100()
                    end
                end
            value106.FocusLost:Connect(helper101)
            addAccount = Instance.new("TextButton")
            addAccount.Name = "AddAccount"
            addAccount.Text = ""
            addAccount.AutoButtonColor = false
            addAccount.BorderSizePixel = 0
            addAccount.BackgroundColor3 = uiLibrary.Theme.AccentB
            addAccount.Size = UDim2.fromOffset(24, 24)
            addAccount.LayoutOrder = 3
            addAccount.Parent = value103.row
            uiLibrary.corner(addAccount, uiLibrary.Theme.RadiusSm)
            uiLibrary.stroke(addAccount, uiLibrary.Theme.Hairline, 1)
            value106 = uiLibrary.icon(addAccount, "check", 15, uiLibrary.Theme.TextOnAccent)
            value106.AnchorPoint, value106.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
            if context.Shell then
                if context.Shell.pressable then
                    context.Shell.pressable(addAccount)
                end
            end
            addAccount.MouseButton1Click:Connect(helper100)
            uiLibrary.tip(
                addAccount,
                "Add this username to the party. The first account wears the crown; the rest start as leechers - press Carry for the ones that fight."
            )
            value103.box.Size = UDim2.fromOffset(148, 24)
            runsThisAccount.add(
                "Find accounts",
                "accent",
                function()
                    local value = {}
                    for index, entry in ipairs(sharedValue5:GetPlayers()) do
                        if
                            entry == localPlayer or partyQueue.presence(entry.Name, config.afOnlineAge or 60)
                        then
                            if helper99(entry.Name) then
                                value[#value + 1] = entry.Name
                            end
                        end
                    end
                    pcall(function()
                        for index2, entry2 in
                            ipairs(listfiles(context.PATH and context.PATH.data or "HarvardLabs/data"))
                        do
                            index2 = tostring(entry2):match("af_([^/\\]+)%.json$")
                            if index2 then
                                if not (index2:find("^party")) then
                                    if not (index2:find("^levelhist")) then
                                        local success, value2 = pcall(function()
                                            local value9, value10 =
                                                getService("HttpService"),
                                                argumentHelpers[108](readfile(entry2))
                                            return value9:JSONDecode(argumentHelpers:unpackValues(value10))
                                        end)
                                        local value11 = success
                                            and type(value2) == "table"
                                            and type(value2.name) == "string"
                                            and value2.name
                                        if value11 then
                                            if partyQueue.presence(value11, config.afOnlineAge or 60) then
                                                if helper99(value11) then
                                                    value[#value + 1] = value11
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    if #value == 0 then
                        helper97(
                            "No accounts running Swangy on this PC that are not in a party already."
                        )
                        return
                    end
                    partyQueue.save()
                    helper97(("Added %d: %s"):format(#value, table.concat(value, ", ")))
                    helper95()
                end,
                "Add every account running Swangy on this PC that is not in a party yet - in this server or any other."
            )
            runsThisAccount.add(
                "Just me",
                "plain",
                function()
                    local value, value2 = partyQueue.soloParty()
                    if value then
                        helper97("Party made, switched off - turn on Run this party when it is set up.")
                    else
                        helper97("This account is " .. tostring(value2) .. ".")
                    end
                    value101 = nil
                    helper95()
                    refreshAll()
                end,
                "A party of only this account. It starts off - switch Run this party on when it is set up, then it queues, starts and replays its own runs."
            )
            local value107, value108, value109 = -math.huge
            value109 = runsThisAccount.add(
                "Delete party",
                "plain",
                function()
                    local value = helper94(true)
                    if os.clock() - value107 > 3 or value.id ~= value108 then
                        local now, value2 = os.clock(), value.id
                        value107, value108 = now, value2
                        value109.Text = "Press again"
                        task.delay(3, function()
                            if value109 then
                                if value109.Parent then
                                    if os.clock() - value107 >= 3 then
                                        value109.Text = "Delete party"
                                    end
                                end
                            end
                        end)
                        return
                    end
                    value107, value108 = -math.huge, nil
                    value109.Text = "Delete party"
                    partyQueue.deleteParty(value.id)
                    value101 = nil
                    helper95()
                    refreshAll()
                end,
                "Delete the party shown (press twice). Its accounts stop queueing until they are in a party again."
            )
            local value110, value111, value112, value113, value114 = 96, 26, 20, 20, 6
            local function helper102(textControl7, argument)
                textControl7.BackgroundColor3 = argument and theme.AccentB or theme.SurfaceChip
                textControl7.TextColor3 = argument and theme.TextOnAccent or theme.TextSub
            end
            local function helper103(argument)
                local value, value2 =
                    partyQueue.presence(argument.name),
                    string.lower(argument.name) == string.lower(localPlayer.Name)
                local value9 = (argument.role == "leader" and " - leader" or "")
                    .. (value2 and " - this account" or "")
                if not value then
                    local value10
                    for index, entry in ipairs(sharedValue5:GetPlayers()) do
                        if string.lower(entry.Name) == string.lower(argument.name) then
                            value10 = entry
                            break
                        end
                    end
                    if value10 then
                        if not value2 then
                            local value11 = value10:FindFirstChild("leaderstats")
                            local valueObject = value11 and (value11:FindFirstChild("Level"))
                            value11 = valueObject and tonumber(valueObject.Value) or 0
                            return ("Lv %d - in this server%s"):format(value11, value9)
                        end
                    end
                    return (value2 and "this account" or "offline - not running the script")
                        .. (argument.role == "leader" and " - leader" or "")
                end
                value2 = value.place == "Lobby" and "in the lobby"
                    or value.place == "Level" and "in a run"
                    or tostring(value.place)
                value2 = if value.setup
                    then value2 .. ", setting up (new account)"
                    else if value.loading then value2 .. ", loading" else value2
                return (tonumber(value.level) and ("Lv %d - "):format(tonumber(value.level)) or "")
                    .. value2
                    .. value9
            end
            local function helper104(argument, role)
                local value = helper94(true)
                local value2 = partyQueue.entry(argument, value)
                if not value2 then
                    return
                end
                if role == "leader" then
                    for index, account in ipairs(value.accounts) do
                        if account.role == "leader" then
                            account.role = "fight"
                        end
                    end
                    value2.role = "leader"
                else
                    argument = value2.role == "leader"
                    value2.role = role
                    if argument then
                        for index2, account2 in ipairs(value.accounts) do
                            if account2 ~= value2 then
                                if account2.role == "fight" then
                                    if account2.enabled ~= false then
                                        account2.role = "leader"
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                partyQueue.save()
            end
            helper95 = function()
                pcall(helper96)
                for index, child in ipairs(altRows:GetChildren()) do
                    if not (child:IsA("UIListLayout")) then
                        child:Destroy()
                    end
                end
                table.clear(value105)
                local accounts = helper94().accounts
                value104.Visible = #accounts == 0
                for index2, account in ipairs(accounts) do
                    local parent = Instance.new("Frame")
                    parent.Name = "Alt_" .. account.name
                    parent.BackgroundColor3 = theme.SurfaceElement
                    parent.BorderSizePixel = 0
                    parent.Size = UDim2.new(1, 0, 0, 42)
                    parent.LayoutOrder = index2
                    parent.Parent = altRows
                    uiLibrary.corner(parent, theme.RadiusMd)
                    uiLibrary.stroke(parent, theme.Hairline, 1)
                    local value, label =
                        value111 + value110 + value112 + value113 + value114 * 4 + 8,
                        Instance.new("TextLabel")
                    label.BackgroundTransparency = 1
                    label.Position, label.Size = UDim2.fromOffset(10, 5), UDim2.new(1, -(value + 10), 0, 18)
                    label.Text, label.TextXAlignment, label.TextTruncate =
                        account.name, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd
                    label.TextSize = 13
                    label.TextColor3 = account.enabled == false and theme.TextMuted or theme.TextPrimary
                    uiLibrary.setFont(label, "sans", Enum.FontWeight.SemiBold)
                    label.Parent = parent
                    label = Instance.new("TextLabel")
                    label.BackgroundTransparency = 1
                    label.Position, label.Size = UDim2.fromOffset(10, 22), UDim2.new(1, -(value + 10), 0, 14)
                    label.Text, label.TextXAlignment, label.TextTruncate, label.TextSize, label.TextColor3 =
                        helper103(account),
                        Enum.TextXAlignment.Left,
                        Enum.TextTruncate.AtEnd,
                        10,
                        theme.TextMuted
                    uiLibrary.setFont(label, "sans", Enum.FontWeight.Regular)
                    label.Parent = parent
                    value105[#value105 + 1] = { label = label, acc = account }
                    value, index2 = account.role == "leader", Instance.new("TextButton")
                    index2.AutoButtonColor = false
                    index2.BorderSizePixel = 0
                    index2.AnchorPoint, index2.Position, index2.Size =
                        Vector2.new(1, 0.5),
                        UDim2.new(1, -(value110 + value112 + value113 + value114 * 3 + 8), 0.5, 0),
                        UDim2.fromOffset(value111, 26)
                    index2.Text = ""
                    label = uiLibrary.icon(index2, "crown", 15, value and theme.TextOnAccent or theme.TextSub)
                    label.AnchorPoint, label.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
                    label.ImageTransparency = value and 0 or 0.45
                    index2.BackgroundColor3 = value and theme.AccentB or theme.SurfaceChip
                    index2.Parent = parent
                    uiLibrary.corner(index2, theme.RadiusSm)
                    uiLibrary.stroke(index2, theme.Hairline, 1)
                    local function button()
                        helper104(account.name, "leader")
                        helper95()
                    end
                    index2.MouseButton1Click:Connect(button)
                    uiLibrary.tip(
                        index2,
                        value and "The leader: it makes the party and every account on the list joins it."
                            or "Make this account the leader."
                    )
                    local parent2 = Instance.new("Frame")
                    parent2.BackgroundColor3 = theme.SurfaceChip
                    parent2.BorderSizePixel = 0
                    parent2.AnchorPoint, parent2.Position, parent2.Size =
                        Vector2.new(1, 0.5),
                        UDim2.new(1, -(value112 + value113 + value114 * 2 + 8), 0.5, 0),
                        UDim2.fromOffset(value110, 26)
                    parent2.Parent = parent
                    uiLibrary.corner(parent2, theme.RadiusSm)
                    uiLibrary.stroke(parent2, theme.Hairline, 1)
                    local value2 = account.role ~= "leech"
                    local function helper6(text, argument, argument2)
                        local button2 = Instance.new("TextButton")
                        button2.AutoButtonColor = false
                        button2.BorderSizePixel = 0
                        button2.Position, button2.Size =
                            UDim2.new(argument, argument == 0 and 2 or 0, 0, 2), UDim2.new(0.5, -2, 1, -4)
                        button2.Text = text
                        button2.TextSize = 12
                        uiLibrary.setFont(button2, "sans", Enum.FontWeight.SemiBold)
                        button2.Parent = parent2
                        uiLibrary.corner(button2, theme.RadiusSm - 1)
                        helper102(button2, value2 == (argument2 == "fight"))
                        local function helper23()
                            if argument2 == "fight" then
                                if account.role == "leader" then
                                    return
                                end
                            end
                            helper104(account.name, argument2)
                            helper95()
                        end
                        button2.MouseButton1Click:Connect(helper23)
                        uiLibrary.tip(
                            button2,
                            argument2 == "fight"
                                    and "Carry: fights in the run and carries the leechers (the leader is always a carry)."
                                or "Joins the party and waits at spawn for the XP."
                        )
                    end
                    helper6("Carry", 0, "fight")
                    helper6("Leech", 0.5, "leech")
                    label = Instance.new("TextButton")
                    label.AutoButtonColor = false
                    label.BorderSizePixel = 0
                    label.AnchorPoint, label.Position, label.Size =
                        Vector2.new(1, 0.5),
                        UDim2.new(1, -(value113 + value114 + 8), 0.5, 0),
                        UDim2.fromOffset(value112, value112)
                    label.Text = ""
                    label.BackgroundColor3 = account.enabled ~= false and theme.AccentB or theme.SurfaceChip
                    label.Parent = parent
                    uiLibrary.corner(label, 3)
                    uiLibrary.stroke(label, theme.Hairline, 1)
                    local function helper45()
                        local value9 = helper94(true)
                        local value10 = partyQueue.entry(account.name, value9)
                        if value10 then
                            value10.enabled = value10.enabled == false
                            partyQueue.save()
                        end
                        helper95()
                    end
                    label.MouseButton1Click:Connect(helper45)
                    uiLibrary.tip(
                        label,
                        (account.enabled ~= false and "On" or "Off")
                            .. " - click to switch. Accounts switched off stay on the list but sit out."
                    )
                    button = Instance.new("TextButton")
                    button.AutoButtonColor = false
                    button.BackgroundTransparency = 1
                    button.AnchorPoint, button.Position, button.Size =
                        Vector2.new(1, 0.5), UDim2.new(1, -8, 0.5, 0), UDim2.fromOffset(value113, 24)
                    button.Text = ""
                    value = uiLibrary.icon(button, "x", 14, theme.TextMuted)
                    value.AnchorPoint, value.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
                    uiLibrary.setFont(button, "sans", Enum.FontWeight.Bold)
                    button.Parent = parent
                    local function helper46()
                        local value9 = helper94(true)
                        local value10, value11 = partyQueue.entry(account.name, value9)
                        if value11 then
                            local value12 = value10.role == "leader"
                            table.remove(value9.accounts, value11)
                            if value12 then
                                for index3, account2 in ipairs(value9.accounts) do
                                    if account2.role == "fight" then
                                        if account2.enabled ~= false then
                                            account2.role = "leader"
                                            break
                                        end
                                    end
                                end
                            end
                            partyQueue.save()
                        end
                        helper95()
                    end
                    button.MouseButton1Click:Connect(helper46)
                    uiLibrary.tip(button, "Take this account off the list.")
                end
            end
            local value115, value116, value117 =
                uiLibrary.section(value6, "Dungeon", 3, "Which dungeon the leader queues."), {}, {}
            for index19, entry22 in ipairs(context.QUEUE_MAPS or {}) do
                value116[#value116 + 1] = { value = entry22, label = entry22 }
            end
            for index20, entry23 in ipairs(context.QUEUE_DIFFICULTIES or {}) do
                value117[#value117 + 1] = { value = entry23, label = entry23 }
            end
            local helper105
            helper(
                uiLibrary.toggle(
                    value115.content,
                    "Pick the dungeon for me",
                    function()
                        return helper94().auto ~= false
                    end,
                    function(argument)
                        helper94(true).auto = argument == true
                        partyQueue.save()
                        if helper105 then
                            helper105()
                        end
                    end,
                    1,
                    "On: it starts at the starting dungeon and goes up with the party's levels, up to the hardest dungeon. Off: pick the dungeon and difficulty yourself."
                )
            )
            value106 = {}
            for index21, entry24 in ipairs(context.QUEUE_MAPS or {}) do
                if partyQueue.LEVELS[entry24] then
                    value106[#value106 + 1] = { value = entry24, label = entry24 }
                end
            end
            local value118 =
                helper(uiLibrary.dropdown(value115.content, "Hardest dungeon", value106, function()
                    return helper94().hardest or "Northern Lands"
                end, function(hardest)
                    helper94(true).hardest = hardest
                    partyQueue.save()
                end, 2, "Never harder than this, however high the accounts are."))
            local value119 = helper(
                uiLibrary.dropdown(value115.content, "Starting dungeon", value106, function()
                    return helper94().start or "Desert Temple"
                end, function(start)
                    helper94(true).start = start
                    partyQueue.save()
                end, 3, "Never easier than this: the party starts here and goes up with its levels.")
            )
            local value120 = helper(
                uiLibrary.dropdown(
                    value115.content,
                    "Dungeon",
                    value116,
                    function()
                        return helper94().map
                    end,
                    function(map)
                        local value = helper94(true)
                        value.map = map
                        if context.EVENT_DIFF then
                            if context.EVENT_DIFF[map] then
                                value.difficulty = context.EVENT_DIFF[map]
                            end
                        end
                        partyQueue.save()
                        refreshAll()
                        if helper105 then
                            pcall(helper105)
                        end
                    end,
                    4,
                    "The dungeon the leader queues. Pumpkin King (the Halloween event) is Nightmare only."
                )
            )
            local value121 = helper(uiLibrary.dropdown(value115.content, "Difficulty", value117, function()
                return helper94().difficulty
            end, function(difficulty)
                helper94(true).difficulty = difficulty
                partyQueue.save()
            end, 5, "The difficulty the leader queues."))
            helper(
                uiLibrary.toggle(
                    value115.content,
                    "Hardcore",
                    function()
                        return helper94().hardcore == true
                    end,
                    function(argument)
                        helper94(true).hardcore = argument == true
                        partyQueue.save()
                    end,
                    5.5,
                    "Every dungeon the leader queues starts as Hardcore - the game's own Hardcore switch. Off by default. Pumpkin King too: 1 life each instead of 3."
                )
            )
            local textControl15 = uiLibrary.caption(value115.content, "", 6)
            helper105 = function()
                local visible = helper94().auto == false
                value120.holder.Visible, value121.holder.Visible = visible, visible
                value118.holder.Visible, value119.holder.Visible = not visible, not visible
                visible = helper94().map or ""
                local difficulty, menu =
                    partyQueue.allowedDiffs(visible), value121.holder:FindFirstChild("Menu")
                if menu then
                    for index, child in ipairs(menu:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.Visible = difficulty[child.Name] == true
                        end
                    end
                end
                difficulty = partyQueue.validDiff(visible, helper94().difficulty)
                if difficulty ~= helper94().difficulty then
                    helper94(true).difficulty = difficulty
                    partyQueue.save()
                    pcall(value121.render)
                end
            end
            value115.setOpen(true)
            if context.RAID then
                local raidAutomation = context.RAID
                local cfg = raidAutomation.cfg
                local value122, value123 =
                    uiLibrary.section(
                        value6,
                        "Boss raids",
                        4,
                        "Boss raids between the start and stop levels. Every enabled account must be running the script and join before the leader starts."
                    ),
                    {}
                local function helper106(argument)
                    value123[#value123 + 1] = argument
                    return helper(argument)
                end
                local function helper107(argument, argument2, argument3, argument4)
                    helper106(uiLibrary.toggle(value122.content, argument, function()
                        return cfg[argument2]
                    end, function(argument5)
                        cfg[argument2] = argument5 == true
                        raidAutomation.save()
                    end, argument3, argument4))
                end
                helper107(
                    "Enabled",
                    "enabled",
                    1,
                    "Switch the party to boss raids after the current run, between the start and stop levels. Shared by every account on this PC."
                )
                helper106(
                    uiLibrary.rangeSlider(
                        value122.content,
                        "Levels",
                        "Start level to stop level",
                        130,
                        200,
                        function()
                            return cfg.firstLevel, cfg.lastLevel
                        end,
                        function(firstLevel, lastLevel)
                            cfg.firstLevel = firstLevel
                            cfg.lastLevel = lastLevel
                            raidAutomation.saveSoon()
                        end,
                        2,
                        "Boss raids start when the lowest account reaches the left handle (130 at least) and stop when every enabled account reaches the right one - then it's ordinary dungeons again."
                    )
                )
                helper106(
                    uiLibrary.rangeSlider(
                        value122.content,
                        "Tiers",
                        "Start tier (0 = auto) to maximum tier",
                        0,
                        30,
                        function()
                            return cfg.fixedTier, cfg.maxTier
                        end,
                        function(fixedTier, maxTier)
                            cfg.fixedTier = fixedTier
                            cfg.maxTier = maxTier
                            raidAutomation.saveSoon()
                        end,
                        3,
                        "Left handle: the start tier - 0 picks the highest raid key every account has; 1-30 locks that tier and it stays there. Right handle: the highest tier it moves up to by itself."
                    )
                )
                helper107(
                    "Advance tiers",
                    "advance",
                    4,
                    "Move up a tier only when every account passes the game's next-tier check (with the start tier at 0)."
                )
                helper107(
                    "Resume at Orbital",
                    "resumeOrbital",
                    5,
                    "At level 140+, go on to Orbital Outpost when the hardest dungeon is still Steampunk Sewers."
                )
                local textControl16 = uiLibrary.caption(value122.content, "", 6)
                local textControl17 = uiLibrary.caption(value122.content, "", 7)
                local text2
                raidAutomation.onRefresh = function()
                    if not value122.holder.Parent then
                        return
                    end
                    local text = table.concat({
                        tostring(cfg.enabled),
                        tostring(cfg.firstLevel),
                        tostring(cfg.lastLevel),
                        tostring(cfg.fixedTier),
                        tostring(cfg.maxTier),
                        tostring(cfg.advance),
                        tostring(cfg.resumeOrbital),
                    }, "|")
                    if text ~= text2 then
                        text2 = text
                        for index, entry in ipairs(value123) do
                            pcall(entry.render)
                        end
                    end
                    text = "Status: " .. tostring(raidAutomation.Status)
                    if textControl16.Text ~= text then
                        textControl16.Text = text
                    end
                    text = raidAutomation.state.plan
                    local value = ("Party minimum: %s%s\10Waits for every enabled account."):format(
                        tostring(raidAutomation.state.lowest or "unknown"),
                        text and text.tier and " - Tier " .. tostring(text.tier) or ""
                    )
                    if textControl17.Text ~= value then
                        textControl17.Text = value
                    end
                    value = cfg.enabled == true
                    if textControl17.Visible ~= value then
                        textControl17.Visible = value
                    end
                end
                pcall(raidAutomation.onRefresh)
                value122.setOpen(cfg.enabled == true)
            end
            helper101 = uiLibrary.section(value6, "Options", 5, "Extras - the defaults are fine.")
            helper(
                uiLibrary.toggle(
                    helper101.content,
                    "Replay with the party",
                    function()
                        return helper94().replay ~= false
                    end,
                    function(argument)
                        helper94(true).replay = argument == true
                        partyQueue.save()
                    end,
                    1,
                    "When a run ends the leader replays it with everyone in the server; otherwise they all go back to the lobby and the party is made again."
                )
            )
            helper(
                uiLibrary.slider(
                    helper101.content,
                    "Wait for accounts",
                    "s",
                    30,
                    300,
                    false,
                    function()
                        return tonumber(helper94().waitMax) or 120
                    end,
                    function(waitMax)
                        helper94(true).waitMax = waitMax
                        partyQueue.save()
                    end,
                    2,
                    "How long the leader waits for accounts that are online but not in its party yet before it starts without them.",
                    10
                )
            )
            helper(
                uiLibrary.toggle(
                    helper101.content,
                    "Start with everyone at the start",
                    function()
                        return helper94().startAll == true
                    end,
                    function(argument)
                        helper94(true).startAll = argument == true
                        partyQueue.save()
                    end,
                    3,
                    "Northern Lands: the leader only presses START once every account of the party is in the run and standing at the start (a leecher just has to be in). At most 3 minutes, then it starts without the missing ones."
                )
            )
            helper(
                uiLibrary.toggle(
                    helper101.content,
                    "New save at level 100",
                    function()
                        return helper94().newSave == true
                    end,
                    function(argument)
                        helper94(true).newSave = argument == true
                        partyQueue.save()
                    end,
                    4,
                    "When every leecher reaches level 100 they each start a fresh save in their next free slot (the level-100 XP boost reward carries over) and the farm starts again from Desert Temple."
                )
            )
            helper(
                uiLibrary.toggle(
                    helper101.content,
                    "Leechers draw the world",
                    function()
                        return helper94().leechDraw == true
                    end,
                    function(argument)
                        helper94(true).leechDraw = argument == true
                        partyQueue.save()
                    end,
                    5,
                    "Off: leechers skip drawing the world (a white screen) to save the PC. On: they draw it again and you can watch them dance. They stay at 15 FPS either way."
                )
            )
            if config.loadoutSwap == nil then
                config.loadoutSwap = true
            end
            helper15(
                helper101.content,
                "Swap carries",
                "loadoutSwap",
                6,
                "An Alt Farm carry keeps its carry kit - Pulse Waves x2 on a mage, Arrow Rain x2 on a warrior - on every map while it one-shots the mobs, and swaps (F) to its speed + attack set once mobs start living through its kit casts (2 in one run). Other fighters: the kit up to Orbital Outpost, the NL kit from Volcanic Chambers up. If the kit isn't on the other set, or the set is empty, it swaps straight back. This account only."
            )
            local function helper108()
                local value, value2, value9 = partyQueue.loadReal(), helper94()
                local B, value10 = partyQueue.partyOf(localPlayer.Name)
                local value11, value12, value13 =
                    partyQueue.role(), partyQueue.entry(localPlayer.Name, value), partyQueue.levelling(value)
                if value12 then
                    if value.on ~= true then
                        textControl12.Text = ("This account is in Party %d, which is switched off - turn on Run this party to start its runs."):format(
                            value10 or 0
                        )
                    elseif value12.enabled == false then
                        textControl12.Text = ("This account is in Party %d but switched off."):format(
                            value10 or 0
                        )
                    elseif value11 == "leech" then
                        textControl12.Text =
                            "This account is a leecher - it joins the party and waits at spawn."
                    elseif partyQueue.isHost() then
                        textControl12.Text = value13 and "This account leads and carries the leechers."
                            or "This account leads the party and fights."
                    else
                        textControl12.Text = value13 and "This account carries the leechers."
                            or "This account is a carry in the leader's party."
                    end
                else
                    textControl12.Text = "This account ("
                        .. localPlayer.Name
                        .. ") isn't in a party, so it won't start any runs. Press Just me for a party of only this account, or add it to one."
                end
                textControl13.Text = "Status: " .. tostring(partyQueue.status or "off")
                if value2.on == true then
                    value = 0
                    for index, account in ipairs(value2.accounts) do
                        value = if account.enabled ~= false
                            then if account.role == "leech" then value + 1 else value
                            else value
                    end
                    textControl11.Text = value > 0
                            and ("Mode: levelling alts - the carries level up %d leecher%s."):format(
                                value,
                                value == 1 and "" or "s"
                            )
                        or "Mode: carries only - every account plays the dungeon with its own abilities."
                    textControl11.Visible = true
                else
                    textControl11.Visible = false
                end
                pcall(context.refreshQueueMode)
                value13, value, value12, value11 = partyQueue.planFor(value2)
                value10 = nil
                if value13 then
                    local value14, value15, value16, value31 =
                        value9 or 0, tostring(value13), tostring(value), tonumber(value12)
                    local value32, value33 =
                        value31 or 0,
                        value2.auto == false
                            and (
                                partyQueue.levelling(value2)
                                    and ' - your pick: it stays on this one ("Pick the dungeon for me" takes the party up with its levels)'
                                or " - your pick"
                            )
                    value10 = ("Party %d's next run: %s %s (level %d)%s."):format(
                        value14,
                        value15,
                        value16,
                        value32,
                        value33
                            or (
                                value11 and (" - best for the lowest account, level %d"):format(value11)
                                or ""
                            )
                    )
                else
                    value10 = value13
                end
                textControl15.Text = value10 or ""
                helper105()
            end
            helper95()
            helper108()
            task.spawn(function()
                local raw = partyQueue.raw
                while true do
                    local destroyed = runtimeState.destroyed
                    if not (if destroyed then not destroyed else dungeonAutofarmUi.Parent) then
                        break
                    end
                    task.wait(1.5)
                    pcall(function()
                        partyQueue.loadReal()
                        if partyQueue.raw ~= raw then
                            raw = partyQueue.raw
                            helper95()
                            refreshAll()
                        end
                        for index, entry in ipairs(value105) do
                            entry.label.Text = helper103(entry.acc)
                        end
                        helper108()
                    end)
                end
            end)
        end
        local function helper109()
            shell.setShown(sharedValue3)
            dim.Visible = false
            if not sharedValue3 then
                uiLibrary.hideTip()
            end
        end
        shell.onClose = function()
            sharedValue3 = false
            helper109()
        end
        shell.finish()
        sliderConnections[#sliderConnections + 1] = userInputService.InputBegan:Connect(
            function(input, argument)
                if runtimeState.menuKeyCapture then
                    if not argument then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            runtimeState.menuKeyCapture = false
                            local keyCode = input.KeyCode
                            if keyCode ~= Enum.KeyCode.Escape then
                                if keyCode ~= Enum.KeyCode.Unknown then
                                    if keyCode.Name ~= config.mapKey then
                                        config.menuKey = keyCode.Name
                                        saveConfig()
                                    end
                                end
                            end
                            if uiSettings.menuKeyButton then
                                uiSettings.menuKeyButton.Text = "Menu key: "
                                    .. tostring(config.menuKey)
                                    .. " (click, then press a key)"
                            end
                            return
                        end
                    end
                end
                if runtimeState.mapKeyCapture then
                    if not argument then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            runtimeState.mapKeyCapture = false
                            local keyCode2 = input.KeyCode
                            if keyCode2 ~= Enum.KeyCode.Escape then
                                if keyCode2 ~= Enum.KeyCode.Unknown then
                                    if keyCode2.Name ~= config.menuKey then
                                        config.mapKey = keyCode2.Name
                                        saveConfig()
                                    end
                                end
                            end
                            if uiSettings.mapKeyButton then
                                uiSettings.mapKeyButton.Text = "Map key: "
                                    .. tostring(config.mapKey)
                                    .. " (click, then press a key)"
                            end
                            return
                        end
                    end
                end
                if not argument then
                    if input.KeyCode.Name == config.menuKey then
                        sharedValue3 = not sharedValue3
                        helper109()
                    end
                end
                if not argument then
                    if input.KeyCode.Name == config.mapKey then
                        if context.MM then
                            if context.MM.toggle then
                                pcall(context.MM.toggle)
                            end
                        end
                    end
                end
            end
        )
        helper109()
        statusChip = config.menuButtonAnyTouch ~= false
        addAccount = userInputService.TouchEnabled and (statusChip or not userInputService.KeyboardEnabled)
        addAccount = if statusChip then if context.COMPACT == true then true else addAccount else addAccount
        local function helper110()
            if runtimeState.mobileMenuButton then
                if runtimeState.mobileMenuButton.Parent then
                    return
                end
            end
            runtimeState.mobileMenuButton = shell.menuButton(function()
                sharedValue3 = not sharedValue3
                helper109()
            end)
        end
        addAccount = config.mobileButton ~= false and (config.mobileButtonAlways == true or addAccount)
        if addAccount then
            helper110()
        elseif config.mobileButton ~= false and statusChip then
            local connection3
            connection3 = userInputService.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end
                if connection3 then
                    connection3:Disconnect()
                    connection3 = nil
                end
                if not runtimeState.destroyed then
                    pcall(helper110)
                end
            end)
            sliderConnections[#sliderConnections + 1] = connection3
        end
        do
            local function helper111(argument)
                local value, value2 = 1, tostring(math.floor(argument + 0.5))
                while value > 0 do
                    value2, value = value2:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
                end
                return value2
            end
            local value124 = context.sig3
                or function(argument)
                    return ("%.2f"):format(argument)
                end
            local function helper112(argument)
                argument = tonumber(argument) or 0
                local value = argument < 0 and -argument or argument
                if value >= 999500000000 then
                    return value124(argument / 1000000000000) .. "t"
                end
                if value >= 999500000 then
                    return value124(argument / 1000000000) .. "b"
                end
                if value >= 999500 then
                    return value124(argument / 1000000) .. "m"
                end
                if value >= 999.5 then
                    return value124(argument / 1000) .. "k"
                end
                return tostring(math.floor(argument + 0.5))
            end
            statusChip, addAccount = setmetatable, { __mode = "k" }
            local value125 = statusChip({}, addAccount)
            local function helper113(argument)
                local value = argument:FindFirstChild("upgrades")
                if value then
                    if not (value:IsA("TextLabel")) then
                        return
                    end
                else
                    return
                end
                local value2, cur, value9 = value125[value]
                if value2 and tostring(value.Text) == value2.wrote then
                    cur, value9 = value2.cur, value2.mx
                else
                    local value10, value11 = tostring(value.Text):match("^%s*([%d,]+)%s*/%s*([%d,]+)%s*$")
                    if value10 then
                        cur, value9 = tonumber((value10:gsub(",", ""))), tonumber((value11:gsub(",", "")))
                        value2 = { cur = cur, mx = value9 }
                        value125[value] = value2
                    else
                        if value2 then
                            cur, value9 = value2.cur, value2.mx
                        else
                            return
                        end
                    end
                end
                if cur then
                    if not value9 then
                        return
                    end
                else
                    return
                end
                local value12 = config.upgradeCountAbbrev ~= false
                        and ("%s / %s"):format(helper112(cur), helper112(value9))
                    or ("%s / %s"):format(helper111(cur), helper111(value9))
                if tostring(value.Text) ~= value12 then
                    value.Text = value12
                end
                value2.wrote = value12
                local value13, value14, value15, value16 =
                    {}, {}, {}, { "physicalDamage", "physicalPower", "spellPower", "health" }
                for index, entry in ipairs(value16) do
                    value = argument:FindFirstChild(entry)
                    if value then
                        if value:IsA("TextLabel") then
                            value12 = tostring(value.Text)
                            index = value12:match("^%s*([%d,]+)%s*$") or value12:match("^%s*([%d,]+)%s*%(")
                            local value31 = index and tonumber((index:gsub(",", "")))
                            if value31 then
                                local value32 = entry == "spellPower" and "spell"
                                    or entry == "health" and "hp"
                                    or "phys"
                                value13[value32] = value31
                                value14[value32] = value
                                value15[value32] = index
                            end
                        end
                    end
                end
                value16, value12 =
                    argument:FindFirstChild("name"),
                    argument.Name == "weaponMain" and "weapon"
                        or argument.Name == "petMain" and "pet"
                        or "armor"
                value = context.upgradeKey
                    and context.upgradeKey(
                        value16 and value16.Text,
                        value12,
                        value13.phys,
                        value13.spell,
                        value13.hp
                    )
                for key, entry2 in pairs(value14) do
                    argument, value16, value12 = value13[key], value15[key]
                    if key == value and value9 > cur then
                        local value33 = context.upgradeStatAfter(argument, value9 - cur)
                        value12 = config.itemStatsAbbrev ~= false
                                and ("%s (%s)"):format(helper112(argument), helper112(value33))
                            or ("%s (%s)"):format(value16, helper111(value33))
                    else
                        value12 = config.itemStatsAbbrev ~= false and helper112(argument) or value16
                    end
                    if tostring(entry2.Text) ~= value12 then
                        entry2.Text = value12
                    end
                end
            end
            value6, weakKeys = setmetatable, { __mode = "k" }
            local value126 = value6({}, weakKeys)
            local function helper114(argument)
                if value126[argument] then
                    return
                elseif not (argument:IsA("GuiObject")) then
                    return
                end
                value126[argument] = true
                local function helper6()
                    pcall(helper113, argument)
                end
                local value = { "physicalDamage", "spellPower", "health", "upgrades" }
                for index, entry in ipairs(value) do
                    index = argument:FindFirstChild(entry)
                    if index then
                        sliderConnections[#sliderConnections + 1] =
                            index:GetPropertyChangedSignal("Text"):Connect(helper6)
                    end
                end
                sliderConnections[#sliderConnections + 1] =
                    argument:GetPropertyChangedSignal("Visible"):Connect(helper6)
                helper6()
            end
            local value127 = { "armorMain", "weaponMain", "petMain" }
            local function helper115(argument)
                for index, entry in ipairs(value127) do
                    index = argument:FindFirstChild(entry)
                    if index then
                        helper114(index)
                    end
                end
            end
            runsThisAccount = sharedValue5.LocalPlayer
                and sharedValue5.LocalPlayer:FindFirstChild("PlayerGui")
            if config.itemFinalStats ~= false and runsThisAccount then
                for index22, descendant3 in ipairs(runsThisAccount:GetDescendants()) do
                    if descendant3.Name == "itemStatFrame" then
                        helper115(descendant3)
                    end
                end
                sliderConnections[#sliderConnections + 1] = runsThisAccount.DescendantAdded:Connect(
                    function(argument)
                        if runtimeState.destroyed then
                            return
                        end
                        if argument.Name == "itemStatFrame" then
                            task.defer(helper115, argument)
                        elseif argument.Parent and argument.Parent.Name == "itemStatFrame" then
                            for index, entry in ipairs(value127) do
                                if argument.Name == entry then
                                    task.defer(helper114, argument)
                                    break
                                end
                            end
                        end
                    end
                )
            end
        end
        do
            local gearProfiles, setMetatable, weakKeys3 = context.GP, setmetatable, { __mode = "k" }
            local value128, value129, weakKeys4 = setMetatable({}, weakKeys3), setmetatable, { __mode = "k" }
            local value130 = value129({}, weakKeys4)
            local function helper116()
                local value = sharedValue5.LocalPlayer
                    and sharedValue5.LocalPlayer:FindFirstChild("PlayerGui")
                local value2 = value and (value:FindFirstChild("inventory"))
                return value2, value2 and (value2:FindFirstChild("itemStatFrame"))
            end
            local function helper117(argument)
                if runtimeState.destroyed then
                    return
                elseif not gearProfiles then
                    return
                end
                local s, success = helper116()
                if not success then
                    return
                end
                local value = argument and argument.Parent and argument:FindFirstChild("itemType")
                local value2 = value and tostring(value.Value)
                local parent = if config.itemGodpot ~= false
                    then if value2 == "weapon"
                        then success:FindFirstChild("weaponMain")
                        else if value2 == "chest"
                            then success:FindFirstChild("armorMain")
                            else if value2 == "helmet" then success:FindFirstChild("armorMain") else nil
                    else nil
                for index, child in ipairs(success:GetChildren()) do
                    index = child:FindFirstChild("__HLGodpot")
                    if index then
                        if child ~= parent then
                            index.Visible = false
                        end
                    end
                end
                if not parent then
                    return
                end
                local uniqueItemNum, imageId =
                    value:FindFirstChild("uniqueItemNum"), value:FindFirstChild("imageId")
                success, value = pcall(
                    gearProfiles.forItem,
                    value2,
                    uniqueItemNum and uniqueItemNum.Value,
                    imageId and imageId.Value,
                    argument.Parent.Name == "leftSideFrame"
                )
                value = if success then value else nil
                local hlGodpot = parent:FindFirstChild("__HLGodpot")
                if not value then
                    if hlGodpot then
                        hlGodpot.Visible = false
                    end
                    return
                end
                local hlGodpot2
                if hlGodpot then
                    hlGodpot2 = hlGodpot
                else
                    hlGodpot = Instance.new("TextLabel")
                    hlGodpot.Name, hlGodpot.BackgroundTransparency, hlGodpot.TextScaled, hlGodpot.TextXAlignment =
                        "__HLGodpot", 1, true, Enum.TextXAlignment.Right
                    hlGodpot.ZIndex = 12
                    hlGodpot.Parent = parent
                    value130[hlGodpot] = true
                    hlGodpot2 = hlGodpot
                end
                local levelReq = parent:FindFirstChild("levelReq")
                if levelReq then
                    hlGodpot2.Position =
                        UDim2.new(0.5, 0, levelReq.Position.Y.Scale, levelReq.Position.Y.Offset)
                    hlGodpot2.Size = UDim2.new(0.46, 0, levelReq.Size.Y.Scale, levelReq.Size.Y.Offset)
                    pcall(function()
                        hlGodpot2.FontFace = levelReq.FontFace
                    end)
                end
                hlGodpot2.Text = ("Godpot %.1f%%"):format(value)
                hlGodpot2.TextColor3 = gearProfiles.color(value)
                hlGodpot2.Visible = true
            end
            function context.gpHide()
                for entry in pairs(value130) do
                    pcall(function()
                        entry.Visible = false
                    end)
                end
            end
            addAccount, value129 = setmetatable, { __mode = "k" }
            local value131 = addAccount({}, value129)
            local function helper118(argument, text)
                local itemType = argument:FindFirstChild("itemType")
                local value, value2, valueObject =
                    itemType and tostring(itemType.Value),
                    itemType and (itemType:FindFirstChild("uniqueItemNum")),
                    itemType and (itemType:FindFirstChild("imageId"))
                local hlGodpotBadge, value9, value10 =
                    tostring(value) .. ":" .. tostring(value2 and value2.Value) .. ":" .. tostring(
                        valueObject and valueObject.Value
                    ),
                    value131[argument]
                if
                    value9
                    and value9.key == hlGodpotBadge
                    and (value9.gp ~= nil or os.clock() - value9.at < 3)
                then
                    value10 = value9.gp
                else
                    if value == "weapon" or value == "chest" or value == "helmet" then
                        local success, value11 = pcall(
                            gearProfiles.forItem,
                            value,
                            value2 and value2.Value,
                            valueObject and valueObject.Value,
                            text.Name == "leftSideFrame"
                        )
                        value10 = if success then value11 else value10
                    end
                    value131[argument] = { key = hlGodpotBadge, gp = value10, at = os.clock() }
                end
                hlGodpotBadge = argument:FindFirstChild("__HLGodpotBadge")
                if not value10 then
                    if hlGodpotBadge then
                        hlGodpotBadge.Visible = false
                    end
                    return
                end
                if not hlGodpotBadge then
                    hlGodpotBadge = Instance.new("TextLabel")
                    hlGodpotBadge.Name, hlGodpotBadge.AnchorPoint, hlGodpotBadge.Position, hlGodpotBadge.Size =
                        "__HLGodpotBadge",
                        Vector2.new(1, 1),
                        UDim2.new(1, -3, 1, -3),
                        UDim2.fromOffset(44, 16)
                    hlGodpotBadge.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
                    hlGodpotBadge.BackgroundTransparency = 0.15
                    hlGodpotBadge.BorderSizePixel = 0
                    hlGodpotBadge.Font = Enum.Font.GothamBold
                    hlGodpotBadge.TextSize = 11
                    hlGodpotBadge.Parent = argument
                    value130[hlGodpotBadge] = true
                end
                value, value2 = helper116()
                argument = value2 and value2:IsA("GuiObject") and math.max(value2.ZIndex - 1, 1) or 10
                if hlGodpotBadge.ZIndex ~= argument then
                    hlGodpotBadge.ZIndex = argument
                end
                text = (value10 >= 99.95 and "%.0f%%" or "%.1f%%"):format(value10)
                if hlGodpotBadge.Text ~= text then
                    hlGodpotBadge.Text = text
                end
                hlGodpotBadge.TextColor3 = gearProfiles.color(value10)
                hlGodpotBadge.Visible = true
            end
            local function helper119(argument)
                if value128[argument] then
                    return
                end
                local value = {}
                local function button()
                    helper117(argument)
                    task.defer(helper117, argument)
                end
                argumentHelpers:appendValues(value, 0, argument.MouseEnter:Connect(button))
                button = argument:FindFirstChild("button")
                if button then
                    if button:IsA("GuiButton") then
                        value[#value + 1] = button.SelectionGained:Connect(function()
                            task.defer(helper117, argument)
                        end)
                    end
                end
                value128[argument] = value
            end
            task.spawn(function()
                while not runtimeState.destroyed do
                    task.wait(1)
                    pcall(function()
                        if config.itemGodpot == false then
                            return
                        elseif not gearProfiles then
                            return
                        end
                        local value = helper116()
                        local value2 = value and (value:FindFirstChild("mainBackground"))
                        if value then
                            if value.Enabled then
                                if value2 then
                                    if not value2.Visible then
                                        return
                                    end
                                else
                                    return
                                end
                            else
                                return
                            end
                        else
                            return
                        end
                        value = value2:FindFirstChild("innerBackground")
                        local value9, value10 = value and (value:FindFirstChild("rightSideFrame")), {}
                        if value9 then
                            if value9:FindFirstChild("ScrollingFrame") then
                                value10[#value10 + 1] = value9.ScrollingFrame
                            end
                        end
                        if value then
                            if value:FindFirstChild("leftSideFrame") then
                                value10[#value10 + 1] = value.leftSideFrame
                            end
                        end
                        for index, entry in ipairs(value10) do
                            for index2, child in ipairs(entry:GetChildren()) do
                                if child:IsA("GuiObject") then
                                    if child:FindFirstChild("itemType") then
                                        helper119(child)
                                        pcall(helper118, child, entry)
                                    end
                                end
                            end
                        end
                    end)
                end
                for key, entry2 in pairs(value128) do
                    for index3, entry3 in ipairs(entry2) do
                        pcall(function()
                            entry3:Disconnect()
                        end)
                    end
                end
                for entry4 in pairs(value130) do
                    pcall(function()
                        entry4:Destroy()
                    end)
                end
            end)
        end
        local hud = Instance.new("Frame")
        hud.Name, hud.BackgroundTransparency, hud.AnchorPoint, hud.Position, hud.Size =
            "HUD", 1, Vector2.new(0, 1), UDim2.new(0, 24, 1, -24), UDim2.fromOffset(600, 214)
        hud.ZIndex = 2
        hud.Parent = dungeonAutofarmUi
        local HP = theme.palette
        local function helper120(name2, parent, argument, band)
            local panel = Instance.new("Frame")
            panel.Name, panel.BackgroundColor3, panel.BorderSizePixel, panel.Position, panel.Size =
                name2, HP.DeepForest, 0, UDim2.fromOffset(0, parent), UDim2.fromOffset(argument, band)
            panel.BackgroundTransparency = 0.04
            panel.ZIndex = 3
            panel.Parent = hud
            uiLibrary.corner(panel, 12)
            uiLibrary.stroke(panel, HP.Bark, 1)
            local inner = Instance.new("UIStroke")
            inner.Color, inner.Thickness, inner.Transparency = HP.Fern, 1, 0.78
            inner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            inner.Parent = panel
            local signal = Instance.new("Frame")
            signal.Name = "Signal"
            signal.BackgroundColor3, signal.BorderSizePixel = HP.Fern, 0
            signal.Position, signal.Size = UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 2)
            signal.ZIndex = 5
            signal.Parent = panel
            uiLibrary.corner(signal, 999)
            local signalGradient = Instance.new("UIGradient")
            signalGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, HP.Fern),
                ColorSequenceKeypoint.new(0.55, HP.LeafLight),
                ColorSequenceKeypoint.new(1, HP.Hot),
            })
            signalGradient.Parent = signal
            return panel
        end
        local function helper121(
            argument,
            argument2,
            argument3,
            argument4,
            argument5,
            argument6,
            argument7,
            textColor3,
            argument8
        )
            local textControl7 = uiLibrary.label(argument, argument2, argument3, 1)
            textControl7.Position, textControl7.Size, textControl7.TextTruncate =
                UDim2.fromOffset(argument4, argument5),
                UDim2.fromOffset(argument6, argument7),
                Enum.TextTruncate.AtEnd
            textControl7.ZIndex = 4
            if textColor3 then
                textControl7.TextColor3 = textColor3
            end
            if argument8 then
                textControl7.TextXAlignment = Enum.TextXAlignment.Right
            end
            return textControl7
        end
        runsThisAccount = helper120("TitleChip", 0, 600, 46, 12)
        helper121(runsThisAccount, "SWANGY // OS", "windowChip", 16, 12, 190, 22)
        local hudLeaf = Instance.new("Frame")
        hudLeaf.Name, hudLeaf.BackgroundColor3, hudLeaf.BorderSizePixel = "Leaf", HP.LeafLight, 0
        hudLeaf.AnchorPoint, hudLeaf.Position = Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, 0)
        hudLeaf.Size, hudLeaf.Rotation, hudLeaf.ZIndex = UDim2.fromOffset(7, 7), 0, 5
        hudLeaf.Parent = runsThisAccount
        uiLibrary.corner(hudLeaf, 999)
        value3, value6 =
            ipairs, {
                helper121(runsThisAccount, "|", "captionKey", 214, 12, 8, 20, theme.TextMuted),
                helper121(runsThisAccount, ver, "rowStat", 228, 12, 100, 20, theme.TextSub),
                (helper121(runsThisAccount, "|", "captionKey", 336, 12, 8, 20, theme.TextMuted)),
            }
        for key7, entry25 in value3(value6) do
            entry25.TextXAlignment = Enum.TextXAlignment.Center
        end
        local textControl18 = helper121(runsThisAccount, "fps: --", "monoStat", 468, 12, 118, 20, nil, true)
        local value132 = helper120("Stats", 54, 600, 112, 12)
        local function helper122(argument, argument2, argument3)
            local index = ({ [11] = 1, [37] = 2, [63] = 3, [89] = 4 })[argument2] or 1
            local column = (index - 1) % 2
            local row = math.floor((index - 1) / 2)
            local cell = Instance.new("Frame")
            cell.Name = "Stat"
            cell.BackgroundColor3, cell.BackgroundTransparency, cell.BorderSizePixel =
                HP.Moss, 0.16, 0
            cell.Position = UDim2.fromOffset(10 + column * 294, 6 + row * 50)
            cell.Size = UDim2.fromOffset(280, 44)
            cell.ZIndex = 2
            cell.Parent = value132
            uiLibrary.corner(cell, 8)
            local accent = Instance.new("Frame")
            accent.Name = "Accent"
            accent.BackgroundColor3, accent.BorderSizePixel = index % 2 == 0 and HP.Hot or HP.Fern, 0
            accent.Position, accent.Size = UDim2.fromOffset(0, 10), UDim2.fromOffset(2, 24)
            accent.ZIndex = 3
            accent.Parent = cell
            uiLibrary.corner(accent, 999)
            local label = helper121(cell, argument, "captionKey", 10, 5, 260, 13)
            label.TextColor3 = theme.TextMuted
            return helper121(cell, "--", "rowStat", 10, 20, 260, 19, nil, argument3)
        end
        local textControl19 = helper122("Playtime", 11)
        local textControl20 = helper122("Status", 37, true)
        local textControl21 = helper122("Attack", 63, true)
        local textControl22 = helper122("Ping", 89)
        statusChip = uiLibrary.label(hud, "[" .. config.menuKey .. "] to open GUI", "rowLabel", 1)
        statusChip.Position, statusChip.Size, statusChip.TextColor3 =
            UDim2.fromOffset(10, 178), UDim2.fromOffset(260, 20), theme.TextSub
        statusChip.TextStrokeTransparency = 0.1
        statusChip.ZIndex = 3
        statusChip = Instance.new("Frame")
        statusChip.Name, statusChip.BackgroundColor3, statusChip.BorderSizePixel, statusChip.Position, statusChip.Size =
            "StatusChip", HP.Moss, 0, UDim2.fromOffset(350, 176), UDim2.fromOffset(240, 30)
        statusChip.ZIndex = 3
        statusChip.Parent = hud
        uiLibrary.corner(statusChip, 8)
        uiLibrary.stroke(statusChip, HP.Bark, 1)
        local dot = Instance.new("Frame")
        dot.Name, dot.BackgroundColor3, dot.BorderSizePixel, dot.AnchorPoint, dot.Position, dot.Size =
            "Dot", theme.StatusBad, 0, Vector2.new(0, 0.5), UDim2.new(0, 9, 0.5, 0), UDim2.fromOffset(6, 6)
        dot.ZIndex = 4
        dot.Parent = statusChip
        uiLibrary.corner(dot, 3)
        value3 = uiLibrary.label(statusChip, "Autofarm:", "captionKey", 1)
        value3.Position, value3.Size = UDim2.fromOffset(21, 0), UDim2.new(1, -21, 1, 0)
        value3.ZIndex = 4
        local textControl23 = uiLibrary.label(statusChip, "Disabled", "captionStat", 2)
        textControl23.Position, textControl23.Size, textControl23.TextColor3 =
            UDim2.fromOffset(76, 0), UDim2.new(1, -85, 1, 0), theme.StatusBad
        textControl23.ZIndex = 4
        local clockChip = Instance.new("Frame")
        clockChip.Name, clockChip.BackgroundColor3, clockChip.BorderSizePixel, clockChip.Position, clockChip.Size =
            "ClockChip", HP.Moss, 0, UDim2.fromOffset(528, 176), UDim2.fromOffset(62, 30)
        clockChip.ZIndex = 3
        clockChip.Parent = hud
        uiLibrary.corner(clockChip, 8)
        uiLibrary.stroke(clockChip, HP.Bark, 1)
        local textControl24 = uiLibrary.label(clockChip, "--:--", "captionStat", 2)
        textControl24.Position, textControl24.Size = UDim2.fromOffset(0, 0), UDim2.new(1, 0, 1, 0)
        textControl24.ZIndex = 4
        textControl24.TextXAlignment = Enum.TextXAlignment.Center
        local value133 = -1
        local function helper123()
            local value = os.date("*t")
            local value2 = value.hour % 12
            return ("%d:%02d %s"):format(
                if value2 == 0 then 12 else value2,
                value.min,
                value.hour < 12 and "AM" or "PM"
            ),
                value.hour * 60 + value.min
        end
        local value134, value135, value136 = getService("Stats"), 0, 0
        runtimeState.hudPlayStart = runtimeState.hudPlayStart or os.clock()
        runtimeState.hudConnection = runService.Heartbeat:Connect(function(visible)
            if runtimeState.destroyed then
                return
            end
            local value, hudStopAt = value135 + 1, value136 + visible
            value135, value136 = value, hudStopAt
            if value136 < 0.25 then
                return
            end
            textControl18.Text = ("fps: %d"):format(math.floor(value135 / value136 + 0.5))
            value135, value136 = 0, 0
            visible = config.hudClock ~= false
            if clockChip.Visible ~= visible then
                clockChip.Visible = visible
            end
            if visible then
                local success, text, value2 = pcall(helper123)
                if success then
                    if value2 ~= value133 then
                        value133 = value2
                        textControl24.Text = text
                    end
                end
            end
            value = context.hudShown
            visible = (if value then context.hudShown() else not value)
                and not (context.MM and context.MM.big)
            if hud.Visible ~= visible then
                hud.Visible = visible
            end
            hudStopAt, value =
                workspaceService:FindFirstChild("dungeonName"),
                workspaceService:FindFirstChild("dungeonStarted")
            local value9, text3 =
                hudStopAt ~= nil and tostring(hudStopAt.Value) ~= "", value ~= nil and value.Value == true
            if value9 then
                if text3 then
                    runtimeState.hudRunAt = runtimeState.hudRunAt or os.clock()
                    visible = context.WH and context.WH.run
                    if visible then
                        if not visible.hudAt then
                            if visible.at then
                                if math.abs(visible.at - runtimeState.hudRunAt) < 30 then
                                    visible.hudAt = runtimeState.hudRunAt
                                end
                            end
                        end
                    end
                    if not runtimeState.hudStopAt then
                        if config.hudStopAtEnd ~= false then
                            if context.runStopAt then
                                value, hudStopAt = pcall(context.runStopAt, runtimeState.hudRunAt)
                                if value then
                                    if hudStopAt then
                                        runtimeState.hudStopAt = hudStopAt
                                    end
                                end
                            end
                        end
                    end
                    local value10 = (runtimeState.hudStopAt or os.clock())
                        - runtimeState.hudRunAt
                        - (config.startCountdown or 5)
                    if value10 < 0 then
                        textControl19.Text = ("-00:%02d"):format(math.ceil(-value10))
                    else
                        textControl19.Text = ("%02d:%02d"):format(
                            math.floor(value10 / 60),
                            math.floor(value10 % 60)
                        ) .. (runtimeState.hudStopAt and " - completed" or "")
                    end
                else
                    textControl19.Text = "Not started"
                    runtimeState.hudRunAt = nil
                    runtimeState.hudStopAt = nil
                end
            else
                textControl19.Text = "Not in dungeon"
                runtimeState.hudRunAt = nil
                runtimeState.hudStopAt = nil
            end
            if runtimeState.lastErrorAt and os.clock() - runtimeState.lastErrorAt < 6 then
                textControl20.Text = "ERROR " .. tostring(runtimeState.lastError)
            else
                visible = 0
                for model in pairs(hazardReader.models) do
                    visible += 1
                end
                textControl21.Text = tostring(runtimeState.attackState or "--")
                text3 = config.drawSpots and #(context.DG.cands or {}) or -1
                textControl20.Text = ("%s  [%d attacks, %s]"):format(
                    tostring(runtimeState.movementState),
                    visible,
                    text3 < 0 and "spots off" or ("%d spots"):format(text3)
                )
            end
            value = {}
            for key, entry in pairs(hazardReader.abilitySlots or {}) do
                value9, hudStopAt = #value + 1, string
                text3, visible = hudStopAt.upper(key), entry.name
                local value11, value12 =
                    visible or "?",
                    entry.cap and entry.cap .. " studs" or (entry.reach and "at least " .. entry.reach or "?")
                value[value9] = ("%s %s: %s%s"):format(
                    text3,
                    value11,
                    value12,
                    entry.aoeX
                            and ", AoE " .. math.floor(entry.aoeX + 0.5) .. (entry.aoeRound and " round" or " x " .. math.floor(
                                entry.aoeZ + 0.5
                            ))
                        or ""
                )
            end
            table.sort(value)
            if uiSettings.statsNote then
                text3 = context.ST
                if text3 then
                    if config.statsEnabled == false then
                        uiSettings.statsNote.Text = "Stats: switched off"
                    elseif text3.url then
                        if text3.url() ~= "" then
                            uiSettings.statsNote.Text = ("Stats: %s  (%d sent, %d failed, %d mobs this run)"):format(
                                tostring(text3.note or "idle"),
                                text3.sent or 0,
                                text3.failed or 0,
                                text3.mobs or 0
                            )
                        else
                            uiSettings.statsNote.Text = "Stats: no endpoint compiled into this build"
                        end
                    else
                        uiSettings.statsNote.Text = "Stats: no endpoint compiled into this build"
                    end
                else
                    uiSettings.statsNote.Text = "Stats: module not loaded"
                end
            end
            textControl.Text = #value > 0
                    and "Measured - " .. table.concat(value, "; ") .. ". The least ranged one sets the fight distance."
                or "Ability range: not measured yet (cast at a target)"
            if os.clock() - (runtimeState.profileSaveAt or 0) > 10 then
                runtimeState.profileSaveAt = os.clock()
                pcall(context.profiles.autosave)
            end
            local value13 = 0
            pcall(function()
                value13 = value134.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            textControl22.Text = ("%d"):format(math.floor(value13 + 0.5))
            visible = runtimeState.farmEnabled and not runtimeState.destroyed
            text3, value =
                visible and "Running" or "Disabled", visible and theme.StatusGood or theme.StatusBad
            if textControl23.Text ~= text3 then
                textControl23.Text = text3
                textControl23.TextColor3 = value
                dot.BackgroundColor3 = value
            end
        end)
    end
    context.destructScript = destructScript
    context.refreshAllWidgets = refreshAll
    context.setLoopButtonState = function()
        if uiSettings.masterRender then
            pcall(uiSettings.masterRender)
        end
    end
    print(
        ('SWANGY %s "%s"  |  build %s'):format(
            ver,
            context.SCRIPT_CODENAME,
            context.SCRIPT_BUILD_DATE
        )
    )
    local green, band2 = pcall(loadConfig)
    if not green then
        runtimeState.lastError, runtimeState.lastErrorAt =
            "config load failed, using defaults: " .. tostring(band2), os.clock()
        context.log("Config", "could not be loaded (" .. tostring(band2) .. ") - running on defaults")
    end
    green, band2 = pcall(function()
        if context.applyClassProfile then
            context.applyClassProfile(config.classProfile or "mage", true)
            pcall(loadConfig, true)
            saveConfig()
        end
        if context.autoClass then
            pcall(context.autoClass, true)
        end
        pcall(function()
            local localPlayer2, value, value2 = getService("Players").LocalPlayer, {}, 0
            local function helper6()
                value2 += 1
                local value3 = value2
                task.delay(config.classAutoSettle or 2, function()
                    if value3 == value2 then
                        if not (context.RT and context.RT.destroyed) then
                            if context.autoClass then
                                pcall(context.autoClass)
                            end
                        end
                    end
                end)
            end
            local function helper22(argument)
                if value[argument] then
                    return
                elseif not (argument.Name == "physicalPower") then
                    if argument.Name ~= "spellPower" then
                        return
                    end
                end
                value[argument] = true
                local connection = argument.Changed:Connect(helper6)
                if context.sliderConnections then
                    context.sliderConnections[#context.sliderConnections + 1] = connection
                end
            end
            local value4 = { "physicalPower", "spellPower" }
            for index, entry in ipairs(value4) do
                index = localPlayer2:FindFirstChild(entry)
                if index then
                    helper22(index)
                end
            end
            local function helper23(argument)
                if context.RT then
                    if context.RT.destroyed then
                        return
                    end
                end
                local value3 = value[argument]
                if
                    if value3
                        then not value3
                        else argument.Name == "physicalPower" or argument.Name == "spellPower"
                then
                    helper22(argument)
                    helper6()
                end
            end
            value4 = localPlayer2.ChildAdded:Connect(helper23)
            if context.sliderConnections then
                context.sliderConnections[#context.sliderConnections + 1] = value4
            end
        end)
    end)
    if not green then
        runtimeState.lastError, runtimeState.lastErrorAt =
            "class profile failed: " .. tostring(band2), os.clock()
        context.log("Config", "class profile could not be applied (" .. tostring(band2) .. ")")
    end
    context.detectClass = function()
        local value = localPlayer:FindFirstChild("leaderstats")
        local valueObject, physicalPower, spellPower =
            value and (value:FindFirstChild("Level")),
            localPlayer:FindFirstChild("physicalPower"),
            localPlayer:FindFirstChild("spellPower")
        value = valueObject and tonumber(valueObject.Value)
        if value then
            if physicalPower then
                if not spellPower then
                    return nil, "not loaded yet"
                end
            else
                return nil, "not loaded yet"
            end
        else
            return nil, "not loaded yet"
        end
        local value2, value3 = tonumber(physicalPower.Value) or 0, tonumber(spellPower.Value) or 0
        if value <= 1 then
            return nil, "level 1 - the copied class stays"
        end
        if value2 == value3 then
            return nil, ("%d points in each - the copied class stays"):format(value2)
        end
        return value3 > value2 and "mage" or "warrior",
            ("%d points in spell power, %d in physical power"):format(value3, value2)
    end
    if context.firstRunNoConfig then
        task.spawn(function()
            local function helper6()
                local value, value2 = context.detectClass()
                if value and value ~= config.classProfile and context.applyClassProfile then
                    context.applyClassProfile(value)
                    local value3 = value == "mage" and "Mage" or "Warrior"
                    context.log("Config", ("first run: class set to %s (%s)"):format(value3, value2))
                    if context.notify then
                        pcall(context.notify, "info", "Class", ("Set to %s: %s."):format(value3, value2))
                    end
                    if context.BG then
                        if context.BG.check then
                            pcall(context.BG.check)
                        end
                    end
                else
                    context.log(
                        "Config",
                        ("first run: class kept as %s (%s)"):format(tostring(config.classProfile), value2)
                    )
                end
            end
            local value4 = os.clock()
            while true do
                local destroyed = runtimeState.destroyed
                if
                    not (
                        (
                            if destroyed
                                then not destroyed
                                else select(2, context.detectClass()) == "not loaded yet"
                        ) and os.clock() - value4 < 120
                    )
                then
                    break
                end
                task.wait(0.5)
            end
            if runtimeState.destroyed then
                return
            end
            helper6()
            if runtimeState.configAsk then
                while true do
                    value4 = runtimeState.destroyed
                    if not (if value4 then not value4 else runtimeState.configAsk) then
                        break
                    end
                    task.wait(0.5)
                end
                if not runtimeState.destroyed then
                    helper6()
                end
            end
        end)
    end
    if context.profiles then
        if context.profiles.current() ~= "Default" then
            pcall(context.profiles.select, context.profiles.current())
        end
    end
    do
        local sharedValue11
        local sharedValue12 = {}
        sharedValue12.at = -math.huge
        sharedValue12.raw = nil
        sharedValue12.v = nil
        context.fpsSharedSave = function()
            local success, raw = pcall(function()
                local value, value2 = getService("HttpService"), sharedValue12.v
                return value:JSONEncode(value2)
            end)
            if success then
                pcall(writefile, "HarvardLabs/data/fps.json", raw)
                sharedValue12.raw, sharedValue12.at = raw, os.clock()
            end
        end
        context.fpsShared = function()
            local now = os.clock()
            if sharedValue12.v then
                if now - sharedValue12.at < 1.5 then
                    return sharedValue12.v
                end
            end
            sharedValue12.at = now
            local success, raw = pcall(readfile, "HarvardLabs/data/fps.json")
            if success then
                if type(raw) == "string" then
                    if raw ~= "" then
                        if raw ~= sharedValue12.raw then
                            local success2, value = pcall(function()
                                return getService("HttpService"):JSONDecode(raw)
                            end)
                            if success2 then
                                if type(value) == "table" then
                                    sharedValue12.v = value
                                    sharedValue12.raw = raw
                                end
                            end
                        end
                    end
                end
            end
            if not sharedValue12.v then
                sharedValue12.v = {
                    cap = false,
                    carry = tonumber(config.carryFpsCap) or 45,
                    leech = tonumber(config.leechFpsCap) or 15,
                    uncap = false,
                }
                context.fpsSharedSave()
            end
            return sharedValue12.v
        end
        context.hudShown = function()
            return context.fpsShared().hud ~= false
        end
        context.fpsSharedSet = function(argument, argument2)
            context.fpsShared()[argument] = argument2
            context.fpsSharedSave()
            if context.applyFps then
                pcall(context.applyFps, true)
            end
        end
        context.applyFps = function(fpsWant)
            if type(setfpscap) ~= "function" then
                return
            end
            local value, value2 = context.fpsShared(), context.afRole and context.afRole() or nil
            if value.cap == true then
                fpsWant = value2 == "leech" and (tonumber(value.leech) or 15) or (tonumber(value.carry) or 45)
                context.fpsWant = fpsWant
                pcall(setfpscap, fpsWant)
                return
            end
            if value.uncap == true then
                if sharedValue11 == nil then
                    if type(getfpscap) == "function" then
                        fpsWant, value2 = pcall(getfpscap)
                        if fpsWant then
                            if type(value2) == "number" then
                                if value2 > 0 then
                                    if value2 < (config.fpsUncapAt or 999) then
                                        if value2 >= 30 then
                                            sharedValue11 = value2
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                context.fpsWant = config.fpsUncapAt or 999
                pcall(setfpscap, context.fpsWant)
            else
                context.fpsWant = 60
                pcall(setfpscap, 60)
            end
        end
    end
    pcall(context.applyFps)
    task.spawn(function()
        local value = {}
        while not runtimeState.destroyed do
            task.wait(3)
            if runtimeState.destroyed then
                break
            end
            if context.fpsWant then
                if type(getfpscap) == "function" then
                    local success, value2 = pcall(getfpscap)
                    if success then
                        if type(value2) == "number" then
                            if value2 ~= context.fpsWant then
                                if not value[value2] then
                                    value[value2] = true
                                    context.log(
                                        "FPS",
                                        ("the FPS cap was %s, not %s - set again"):format(
                                            tostring(value2),
                                            tostring(context.fpsWant)
                                        )
                                    )
                                end
                            end
                        end
                    end
                end
            end
            pcall(context.applyFps)
        end
    end)
    do
        local sharedValue13 = false
        context.applyRender = function(argument)
            local value, value2 = config.leechRenderOff ~= false
                and context.isAlt1186 ~= nil
                and context.isAlt1186() == true
            if value and context.AF and context.AF.load then
                local success, value3 = pcall(function()
                    return context.AF.load().leechDraw == true
                end)
                if success then
                    if value3 then
                        local value4 = false
                        value = value4
                    end
                end
                value2 = value
            else
                value2 = value
            end
            local success2 = pcall(function()
                getService("RunService"):Set3dRenderingEnabled(
                    config.renderOff ~= true and context.fps2D ~= true and not value2
                )
            end)
            if success2 then
                sharedValue13 = false
                return
            end
            if argument or config.renderOff == true then
                if not sharedValue13 then
                    sharedValue13 = true
                    context.log("Config", "this executor will not switch the game's drawing off")
                end
            end
        end
    end
    pcall(context.applyRender)
    task.spawn(function()
        while not (context.RT and context.RT.destroyed) do
            task.wait(5)
            local value = context.CFG and context.CFG.renderOff == true
            if
                value
                or (if context.isAlt1186 then if context.isAlt1186() == true then true else value else value)
            then
                if context.applyRender then
                    pcall(context.applyRender)
                end
            end
        end
    end)
    do
        local sharedValue14 = getService("RunService")
        local sharedValue15, success3, sharedValue16, sharedValue17 =
            getService("UserInputService"), false, {}
        local sharedValue18, sharedValue19 = 0, false
        local function helper124()
            if runtimeState.destroyed then
                return
            elseif config.birdsEyeCam ~= true then
                return
            elseif context.MM ~= nil then
                if context.MM.cam3On == true then
                    return
                end
            end
            local camera, character = workspaceService.CurrentCamera, localPlayer.Character
            local value = character and (character:FindFirstChild("HumanoidRootPart"))
            if camera then
                if not value then
                    return
                end
            else
                return
            end
            local position, value2 = value.Position, sharedValue17 or (config.birdsEyeHeight or 150)
            sharedValue17 = value2
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.lookAt(
                position + Vector3.new(0, sharedValue17, 0),
                position,
                Vector3.new(math.sin(sharedValue18), 0, -math.cos(sharedValue18))
            )
        end
        local function helper125()
            sharedValue16[#sharedValue16 + 1] = sharedValue15.InputChanged:Connect(function(input, argument)
                if input.UserInputType == Enum.UserInputType.MouseWheel and not argument then
                    local clamp, value = math.clamp, sharedValue17 or (config.birdsEyeHeight or 150)
                    sharedValue17 = clamp(
                        value * (1 - 0.12 * input.Position.Z),
                        config.birdsEyeMin or 30,
                        config.birdsEyeMax or 600
                    )
                elseif input.UserInputType == Enum.UserInputType.MouseMovement then
                    if sharedValue19 then
                        local value2 = sharedValue18
                        sharedValue18 = value2 + input.Delta.X * (config.birdsEyeTurn or 0.006)
                    end
                end
            end)
            sharedValue16[#sharedValue16 + 1] = sharedValue15.InputBegan:Connect(function(input, argument)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    if not argument then
                        sharedValue19 = true
                    end
                end
            end)
            sharedValue16[#sharedValue16 + 1] = sharedValue15.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    sharedValue19 = false
                end
            end)
        end
        context.applyBirdsEye = function()
            local value = config.birdsEyeCam == true and not runtimeState.destroyed
            if value and not success3 then
                pcall(function()
                    sharedValue14:UnbindFromRenderStep("DQBirdsEye")
                end)
                success3 = pcall(function()
                    sharedValue14:BindToRenderStep("DQBirdsEye", Enum.RenderPriority.Last.Value, helper124)
                end)
                if success3 then
                    pcall(helper125)
                end
            elseif if value then not value else success3 then
                pcall(function()
                    sharedValue14:UnbindFromRenderStep("DQBirdsEye")
                end)
                success3 = false
                for index, entry in ipairs(sharedValue16) do
                    pcall(function()
                        entry:Disconnect()
                    end)
                end
                table.clear(sharedValue16)
                sharedValue17, sharedValue18, sharedValue19 = nil, 0, false
                local camera = workspaceService.CurrentCamera
                if camera then
                    if camera.CameraType == Enum.CameraType.Scriptable then
                        camera.CameraType = Enum.CameraType.Custom
                    end
                end
            end
        end
    end
    config.birdsEyeCam = (context.devPrefs or {})._birdsEye == true
    config.autoCandy = false
    pcall(context.applyBirdsEye)
    task.delay(tonumber(config.whRodinRecoverAfter) or 8, function()
        if context.WH then
            if context.WH.rodinRecover then
                pcall(context.WH.rodinRecover)
            end
        end
    end)
    task.defer(function()
        if config.wallsOn then
            if context.WALLS then
                if context.WALLS.on then
                    return
                end
            else
                return
            end
        else
            return
        end
        if context.WALLS.adopt then
            if context.WALLS.adopt() then
                return
            end
        end
        if _G.DungeonAutofarmMapDown == game.JobId then
            if workspaceService:FindFirstChild("Map") == nil then
                if context.WALLS.inWallsMap() then
                    pcall(context.WALLS.build)
                    return
                end
            end
        end
        local now, value = os.clock(), false
        while true do
            local value2, wallsWaitFor = os.clock() - now, config.wallsWaitFor
            if not (value2 < (wallsWaitFor or 180)) then
                break
            end
            if context.WALLS.on then
                return
            elseif not config.wallsOn then
                return
            end
            if context.WALLS.adopt then
                if context.WALLS.adopt() then
                    return
                end
            end
            workspaceService:FindFirstChild("dungeonName")
            if context.WALLS.inWallsMap() then
                if workspaceService:FindFirstChild("Map") ~= nil then
                    pcall(context.WALLS.build)
                    return
                end
            end
            if not value then
                context.log("Walls", "saved on: waiting for the Northern Lands map to stream in")
                value = true
            end
            task.wait(1)
        end
        context.log("Walls", "saved on, but no Northern Lands map appeared: left alone")
    end)
    hlBugReport()
    context.readerStart()
    if context.fireLoop then
        context.fireLoop()
    end
    do
        local sharedValue20 = getService("HttpService")
        local sharedValue21 = getService("LogService")
        local sharedValue22 = getService("GuiService")
        local sharedValue23, bug =
            getService("Stats"), {
                on = false,
                file = nil,
                buf = {},
                all = nil,
                bytes = 0,
                n = 0,
                t0 = 0,
                conns = {},
                last = {},
                cfg = {},
                frames = 0,
                part = 0,
            }
        context.BUG = bug
        local sharedValue24 = type(appendfile) == "function"
        local function helper126()
            return (context.PATH and context.PATH.data or "HarvardLabs/data")
                .. "/bugrec_"
                .. tostring(localPlayer.UserId)
                .. ".json"
        end
        local function helper127()
            local value
            pcall(function()
                if type(isfile) == "function" then
                    if isfile(helper126()) then
                        value = sharedValue20:JSONDecode(readfile(helper126()))
                    end
                end
            end)
            local value2 = type(value) == "table"
                    and value.on == true
                    and type(value.session) == "string"
                    and value
                or nil
            return value2
        end
        local function helper128(argument)
            pcall(context.ensureFolders)
            pcall(function()
                writefile(helper126(), sharedValue20:JSONEncode(argument or { on = false }))
            end)
        end
        local sharedValue25, sharedValue26, sharedValue27, sharedValue28, sharedValue29, sharedValue30 =
            {
                webhookUrl = true,
                statsKey = true,
                whPingId = true,
                statsUrl = true,
                webhookUser = true,
                streamerNameText = true,
            }, {}, {}, 0, 0, 0
        local sharedValue31, sharedValue32 = -math.huge, false
        local function helper129(argument, argument2)
            argument = tostring(argument or ""):match("^%s*@?(.-)%s*$") or ""
            if #argument < 3 then
                return
            end
            local value = argument:lower()
            if sharedValue26[value] then
                return
            end
            argument2 = if type(argument2) == "function" then argument2() else argument2
            sharedValue26[value] = argument2
            local value2 = sharedValue27
            value2[#value2 + 1] = value
            sharedValue32 = true
        end
        local function helper130()
            sharedValue28 += 1
            local value = sharedValue28
            return ("<account %d>"):format(value)
        end
        local function helper131()
            sharedValue29 += 1
            local value = sharedValue29
            return ("<player %d>"):format(value)
        end
        local function helper132()
            sharedValue30 += 1
            local value = sharedValue30
            return ("<whitelisted %d>"):format(value)
        end
        local function helper133(player)
            if not player then
                return
            end
            if player == localPlayer then
                helper129(player.Name, "<you>")
                helper129(player.DisplayName, "<you>")
                helper129(tostring(player.UserId), "<your user id>")
                return
            end
            helper129(player.Name, helper131)
            local value = sharedValue26
            local value2 = value[tostring(player.Name):lower()] or helper131()
            helper129(player.DisplayName, value2)
            helper129(tostring(player.UserId), (value2:gsub(">$", " user id>")))
        end
        local sharedValue33 = {}
        local function helper134(player)
            if #sharedValue33 < 400 then
                sharedValue33[#sharedValue33 + 1] =
                    { Name = player.Name, DisplayName = player.DisplayName, UserId = player.UserId }
            end
        end
        pcall(function()
            for index, entry in ipairs(sharedValue5:GetPlayers()) do
                helper134(entry)
            end
        end)
        local connection4
        pcall(function()
            connection4 = sharedValue5.PlayerAdded:Connect(function(argument)
                if runtimeState.destroyed then
                    if connection4 then
                        connection4:Disconnect()
                    end
                    return
                end
                pcall(helper134, argument)
            end)
        end)
        local function helper135()
            helper133(localPlayer)
            pcall(function()
                local value = context.AF and context.AF.doc
                for index, entry in
                    ipairs(
                        type(value) == "table" and type(value.parties) == "table" and value.parties
                            or { context.AF and context.AF.load and context.AF.load() }
                    )
                do
                    for index2, entry2 in
                        ipairs(
                            type(entry) == "table" and type(entry.accounts) == "table" and entry.accounts
                                or {}
                        )
                    do
                        helper129(entry2.name, helper130)
                    end
                end
            end)
            if type(config.carryName) == "string" then
                helper129(config.carryName, helper130)
            end
            if type(listfiles) == "function" then
                if os.clock() - sharedValue31 >= 10 then
                    sharedValue31 = os.clock()
                    pcall(function()
                        for index, entry in
                            ipairs(listfiles(context.PATH and context.PATH.data or "HarvardLabs/data"))
                        do
                            index = tostring(entry):match("([^/\\]+)$") or ""
                            entry = index:match("^af_(.+)%.json$")
                                or index:match("^haul_(.+)%.json$")
                                or index:match("^rodin_(.+)%.json$")
                                or index:match("^lvl_(.+)%.json$")
                                or index:match("^bossraid_presence_(.+)%.json$")
                            index = entry
                                and (
                                    entry == "party"
                                    or entry == "levelhist"
                                    or entry:match("^party_")
                                    or entry:match("^levelhist_")
                                )
                            if entry then
                                if not index then
                                    helper129(entry, helper130)
                                end
                            end
                        end
                    end)
                    pcall(function()
                        for index, entry in ipairs(listfiles("HarvardLabs/configs")) do
                            index = tostring(entry):match("release_(%d+)%.json$")
                            if index then
                                helper129(index, "<user id>")
                            end
                        end
                    end)
                end
            end
            for index3, entry3 in ipairs(type(config.modWhitelist) == "table" and config.modWhitelist or {}) do
                helper129(entry3, helper132)
            end
            for entry4 in tostring(config.whPingId or ""):gmatch("%d+") do
                helper129(entry4, "<discord id>")
            end
            if type(config.webhookUser) == "string" then
                if config.webhookUser ~= "Swangy" then
                    helper129(config.webhookUser, "<webhook name>")
                end
            end
            if type(config.streamerNameText) == "string" then
                if config.streamerNameText ~= "harvard student" then
                    helper129(config.streamerNameText, "<streamer name>")
                end
            end
            for index4, entry5 in ipairs(sharedValue5:GetPlayers()) do
                helper133(entry5)
            end
            for index5, entry6 in ipairs(sharedValue33) do
                helper133(entry6)
            end
        end
        local function helper136(argument)
            argument = tostring(argument)
            if sharedValue32 then
                table.sort(sharedValue27, function(argument2, argument3)
                    return #argument2 > #argument3
                end)
                sharedValue32 = false
            end
            local value, value2 = argument:lower(), sharedValue27
            for index, entry in ipairs(value2) do
                if value:find(entry, 1, true) then
                    local value3, value4 = {}, 1
                    while true do
                        local value5, value6 = value:find(entry, value4, true)
                        if not value5 then
                            break
                        end
                        if
                            value:sub(value5 - 1, value5 - 1):match("%w")
                            or value:sub(value6 + 1, value6 + 1):match("%w")
                        then
                            value3[#value3 + 1] = argument:sub(value4, value6)
                        else
                            value3[#value3 + 1] = argument:sub(value4, value5 - 1) .. sharedValue26[entry]
                        end
                        value4 = value6 + 1
                    end
                    value3[#value3 + 1] = argument:sub(value4)
                    argument = table.concat(value3)
                    value = (argument:lower())
                end
            end
            return (
                argument
                    :gsub("([Uu][Ss][Ee][Rr][Ss][\\/]+)[^\\/%s\"']+", "%1<user>")
                    :gsub("(/home/)[^/%s\"']+", "%1<user>")
                    :gsub("[Dd]iscord%a*%.com/api/webhooks/%S+", "<webhook>")
                    :gsub("(Players[%.:]+)([%a_][%w_]*)", function(argument2, argument3)
                        if argument3 == "LocalPlayer" then
                            return nil
                        elseif argument3 == "PlayerAdded" then
                            return nil
                        elseif argument3 == "PlayerRemoving" then
                            return nil
                        elseif argument3 == "GetPlayers" then
                            return nil
                        elseif argument3 == "GetPlayerFromCharacter" then
                            return nil
                        end
                        return argument2 .. "<player>"
                    end)
            )
        end
        local function hide(argument)
            local success, value = pcall(helper136, argument)
            return success and value or "<line left out: it could not be checked for names>"
        end
        bug.hide = hide
        local function helper137(argument, argument2)
            argument, argument2 = tostring(argument):gsub("%c", " "), argument2 or 900
            return if #argument > argument2 then argument:sub(1, argument2) .. " ..." else argument
        end
        local function helper138(argument)
            local value = typeof(argument)
            if value == "Color3" then
                return "#" .. argument:ToHex()
            end
            if value == "table" then
                local success, value2 = pcall(sharedValue20.JSONEncode, sharedValue20, argument)
                return success and value2 or "<table>"
            end
            return tostring(argument)
        end
        local function add(argument, argument2)
            if not bug.on then
                return
            end
            local value = ("[%s +%7.1fs] %-8s "):format(os.date("%H:%M:%S"), os.clock() - bug.t0, argument)
            argument2 = tostring(argument2):sub(1, 2000)
            bug.buf[#bug.buf + 1] = { value, argument2 }
            bug.bytes = bug.bytes + #value + math.min(#argument2, 904) + 1
            bug.n = bug.n + 1
        end
        bug.add = add
        local function helper139()
            return pcall(writefile, bug.file, table.concat(bug.all))
        end
        local function helper140()
            if bug.file then
                if #bug.buf == 0 then
                    return
                end
            else
                return
            end
            pcall(helper135)
            local value = {}
            for index, entry in ipairs(bug.buf) do
                value[index] = entry[1] .. helper137(hide(entry[2])) .. "\10"
            end
            local value2 = table.concat(value)
            table.clear(bug.buf)
            if sharedValue24 then
                if not bug.all then
                    if pcall(appendfile, bug.file, value2) then
                        return
                    end
                    bug.all = {}
                    pcall(function()
                        bug.all[1] = readfile(bug.file)
                    end)
                end
            end
            bug.all = bug.all or {}
            bug.all[#bug.all + 1] = value2
            helper139()
        end
        local function helper141(argument)
            local valueObject = workspaceService:FindFirstChild(argument)
            return valueObject and valueObject:IsA("ValueBase") and tostring(valueObject.Value) or "-"
        end
        local function helper142(argument)
            local value, iterateArray, value2 =
                {}, ipairs, { localPlayer:FindFirstChildOfClass("Backpack"), localPlayer.Character }
            for key, entry in iterateArray(value2) do
                if entry then
                    for index, child in ipairs(entry:GetChildren()) do
                        if child:IsA("Tool") then
                            key, index = child:FindFirstChild("abilitySlot"), child:FindFirstChild("cooldown")
                            local value3 = ("%s[%s]"):format(
                                child.Name,
                                key and tostring(key.Value) or "no slot"
                            )
                            value3 = if argument
                                then if index
                                    then value3 .. ("%.1f"):format(tonumber(index.Value) or 0)
                                    else value3
                                else value3
                            value[#value + 1] = value3
                        end
                    end
                end
            end
            table.sort(value)
            return #value > 0 and table.concat(value, " ") or "none"
        end
        local function helper143()
            local value = {}
            pcall(helper135)
            local function helper6(argument, argument2)
                value[#value + 1] = ("%-20s %s"):format(argument, helper137(hide(argument2), 4000))
            end
            value[#value + 1] =
                "Swangy bug report - send every file of this recording (the whole folder) with your report."
            value[#value + 1] = ""
            helper6(
                "script",
                ('%s "%s", build %s'):format(
                    tostring(context.SCRIPT_VERSION),
                    tostring(context.SCRIPT_CODENAME),
                    tostring(context.SCRIPT_BUILD_DATE)
                )
            )
            helper6("recorded", os.date("%Y-%m-%d %H:%M:%S"))
            helper6(
                "recording part",
                ("%d - the recording started %s; one file per server, numbered in order"):format(
                    bug.part or 1,
                    tostring(bug.since or "?")
                )
            )
            helper6(
                "account",
                "not recorded - names are hidden: <you> is this account, <account N> one on the party list, <player N> anyone else"
            )
            local value2 = "unknown"
            pcall(function()
                if type(identifyexecutor) == "function" then
                    value2 = table.concat({ identifyexecutor() }, " ")
                elseif type(getexecutorname) == "function" then
                    value2 = tostring(getexecutorname())
                end
            end)
            helper6("executor", value2)
            local value3 = {}
            local function helper22(argument, argument2)
                value3[#value3 + 1] = argument .. (type(argument2) == "function" and "" or " MISSING")
            end
            helper22("writefile", writefile)
            helper22("appendfile", appendfile)
            helper22("readfile", readfile)
            helper22("listfiles", listfiles)
            helper22("setfpscap", setfpscap)
            helper22("getconnections", getconnections)
            helper22("firesignal", firesignal)
            helper22("getgc", getgc)
            helper22("request", context.net and context.net.fn or nil)
            helper22("loadstring", loadstring)
            helper22("getcustomasset", getcustomasset)
            helper22("queue_on_teleport", queue_on_teleport)
            helper6("executor functions", table.concat(value3, ", "))
            helper22 = workspaceService.CurrentCamera
            helper6(
                "device",
                ("touch %s, keyboard %s, mouse %s, gamepad %s, screen %s"):format(
                    tostring(userInputService.TouchEnabled),
                    tostring(userInputService.KeyboardEnabled),
                    tostring(userInputService.MouseEnabled),
                    tostring(userInputService.GamepadEnabled),
                    helper22 and ("%dx%d"):format(helper22.ViewportSize.X, helper22.ViewportSize.Y) or "?"
                )
            )
            helper6("server", ("place %s, job %s"):format(tostring(game.PlaceId), tostring(game.JobId)))
            helper22 = {}
            for index, entry in ipairs(sharedValue5:GetPlayers()) do
                helper22[#helper22 + 1] = entry.Name
            end
            helper6("players here", table.concat(helper22, ", "))
            local value4 = "?"
            pcall(function()
                value4 = tostring(localPlayer.leaderstats.Level.Value)
            end)
            helper6("level", value4)
            helper6("class", config.classProfile)
            helper6(
                "dungeon",
                ("%s, started %s, progress %s, hardcore %s"):format(
                    helper141("dungeonName"),
                    helper141("dungeonStarted"),
                    helper141("dungeonProgress"),
                    helper141("hardcore")
                )
            )
            local value5, value6, value7
            pcall(function()
                value5 = context.afRole and context.afRole()
            end)
            pcall(function()
                value6 = context.AF and context.AF.isHost and context.AF.isHost()
            end)
            pcall(function()
                local value8, value9, value10, value11 = context.AF.plan()
                if value8 then
                    value7 = ("%s %s (level %s, lowest account %s)"):format(
                        tostring(value8),
                        tostring(value9),
                        tostring(value10),
                        tostring(value11)
                    )
                end
            end)
            helper6(
                "accounts",
                ("role %s, host %s, next run %s, status %s"):format(
                    tostring(value5 or "none (not on the list or party mode off)"),
                    tostring(value6),
                    tostring(value7 or "-"),
                    tostring(context.AF and context.AF.status or "-")
                )
            )
            pcall(function()
                if context.AF then
                    if context.AF.raw then
                        if context.AF.raw ~= "" then
                            helper6("accounts file", context.AF.raw)
                        end
                    end
                end
            end)
            helper6("kit", helper142(true))
            helper6(
                "farm",
                ("autofarm %s, mod detection hold %s, last error %s"):format(
                    tostring(runtimeState.farmEnabled),
                    tostring(runtimeState.modHalt == true),
                    tostring(runtimeState.lastError or "-")
                )
            )
            value[#value + 1] = ""
            value[#value + 1] =
                "settings (webhook URL and name, licence key, Discord ID and streamer name hidden):"
            for index2, entry2 in ipairs(context.PERSIST or {}) do
                index2 = config[entry2]
                helper22 = sharedValue25[entry2] and (index2 ~= nil and index2 ~= "" and "<set>" or "<empty>")
                    or helper137(hide(helper138(index2)), 600)
                value[#value + 1] = ("  %-28s %s"):format(entry2, helper22)
                bug.cfg[entry2] = helper22
            end
            value[#value + 1] = ""
            value[#value + 1] =
                "timeline (TICK every 0.5s: farm, position, horizontal speed, WalkSpeed, HP, humanoid state, BUFF when the game's"
            value[#value + 1] = "speed buff is on, fps, ping, cooldowns, then | status | attack):"
            return table.concat(value, "\10") .. "\10"
        end
        local function helper144()
            local character = localPlayer.Character
            local value, success, value2 =
                character and (character:FindFirstChildOfClass("Humanoid")),
                character and (character:FindFirstChild("HumanoidRootPart")),
                { runtimeState.farmEnabled and "farm" or "OFF" }
            if runtimeState.modHalt then
                value2[#value2 + 1] = "MODHOLD"
            end
            if success then
                local position, linearVelocity = success.Position, success.AssemblyLinearVelocity
                value2[#value2 + 1] = ("pos %.0f,%.0f,%.0f spd %.1f"):format(
                    position.X,
                    position.Y,
                    position.Z,
                    Vector3.new(linearVelocity.X, 0, linearVelocity.Z).Magnitude
                )
            else
                value2[#value2 + 1] = "no character"
            end
            if value then
                value2[#value2 + 1] = ("ws %.1f hp %d/%d %s"):format(
                    value.WalkSpeed,
                    math.floor(value.Health),
                    math.floor(value.MaxHealth),
                    value:GetState().Name
                )
            end
            if character then
                if character:FindFirstChild("spellBuff") then
                    value2[#value2 + 1] = "BUFF"
                end
            end
            local value3 = 0
            pcall(function()
                value3 = sharedValue23.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            value2[#value2 + 1] = ("fps %d ping %d"):format(bug.fps or 0, math.floor(value3 + 0.5))
            success, value = pcall(function()
                return getfpscap and getfpscap()
            end)
            local value4 = {}
            for key, entry in pairs(runtimeState.stMax or {}) do
                value4[#value4 + 1] = { key, entry }
            end
            table.sort(value4, function(argument, argument2)
                return argument[2] > argument2[2]
            end)
            local value5 = {}
            for index = 1, math.min(4, #value4), 1 do
                value5[#value5 + 1] = ("%s %.1fms"):format(value4[index][1], value4[index][2] * 1000)
            end
            value2[#value2 + 1] = ("cap %s gap %.0fms slowest: %s"):format(
                success and tostring(value) or "?",
                (bug.gap or 0) * 1000,
                table.concat(value5, ", ")
            )
            bug.gap = 0
            if runtimeState.stMax then
                table.clear(runtimeState.stMax)
            end
            success, value4, value = {}, ipairs, { localPlayer:FindFirstChildOfClass("Backpack"), character }
            for key2, entry2 in value4(value) do
                if entry2 then
                    for index2, child in ipairs(entry2:GetChildren()) do
                        index2, key2 = child:FindFirstChild("abilitySlot"), child:FindFirstChild("cooldown")
                        if child:IsA("Tool") then
                            if index2 then
                                if key2 then
                                    success[#success + 1] = ("%s %.1f"):format(
                                        tostring(index2.Value),
                                        tonumber(key2.Value) or 0
                                    )
                                end
                            end
                        end
                    end
                end
            end
            table.sort(success)
            if #success > 0 then
                value2[#value2 + 1] = "cd " .. table.concat(success, " ")
            end
            value2[#value2 + 1] = "| " .. tostring(runtimeState.movementState)
            value2[#value2 + 1] = "| " .. tostring(runtimeState.attackState)
            return table.concat(value2, " ")
        end
        local function helper145(argument, argument2, argument3)
            argument2 = tostring(argument2)
            if bug.last[argument] ~= argument2 then
                bug.last[argument] = argument2
                add(argument3, argument2)
            end
        end
        local function helper146()
            pcall(helper135)
            helper145(
                "dungeon",
                ("%s, started %s, progress %s"):format(
                    helper141("dungeonName"),
                    helper141("dungeonStarted"),
                    helper141("dungeonProgress")
                ),
                "DUNGEON"
            )
            helper145("queue", context.LB and context.LB.status or "-", "QUEUE")
            helper145("afstatus", context.AF and context.AF.status or "-", "ACCOUNTS")
            local value
            pcall(function()
                value = context.afRole and context.afRole()
            end)
            helper145("role", "role " .. tostring(value or "none"), "ACCOUNTS")
            helper145("afraw", context.AF and context.AF.raw or "-", "LIST")
            helper145("error", runtimeState.lastError or "-", "ERROR")
            helper145("kit", helper142(false), "KIT")
            helper145("sell", context.AS and context.AS.note or "-", "SELL")
            for index, entry in ipairs(context.PERSIST or {}) do
                index = config[entry]
                local value2 = sharedValue25[entry]
                        and (index ~= nil and index ~= "" and "<set>" or "<empty>")
                    or helper137(hide(helper138(index)), 600)
                if bug.cfg[entry] ~= value2 then
                    add("SETTING", ("%s: %s -> %s"):format(entry, tostring(bug.cfg[entry]), value2))
                    bug.cfg[entry] = value2
                end
            end
        end
        helper18 = localPlayer:WaitForChild("PlayerGui")
        band2 = helper18:FindFirstChild("HLBugReport")
        if band2 then
            band2:Destroy()
        end
        hlBugReport = Instance.new("ScreenGui")
        hlBugReport.Name, hlBugReport.ResetOnSpawn, hlBugReport.IgnoreGuiInset, hlBugReport.DisplayOrder, hlBugReport.ZIndexBehavior =
            "HLBugReport", false, true, 250, Enum.ZIndexBehavior.Sibling
        hlBugReport.Parent = helper18
        context.bugGui = hlBugReport
        green = userInputService.TouchEnabled
            and (config.menuButtonAnyTouch ~= false or not userInputService.KeyboardEnabled)
        local sharedValue34, bugButton =
            (if config.menuButtonAnyTouch ~= false
                then if context.COMPACT == true then true else green
                else green) and -170 or -16,
            Instance.new("TextButton")
        bugButton.Name = "BugButton"
        bugButton.Text = ""
        bugButton.AutoButtonColor = true
        bugButton.BorderSizePixel = 0
        bugButton.AnchorPoint, bugButton.Position, bugButton.Size =
            Vector2.new(1, 1), UDim2.new(1, -16, 1, sharedValue34), UDim2.fromOffset(40, 40)
        bugButton.BackgroundColor3 = theme.SurfaceChip
        bugButton.BackgroundTransparency = 0.08
        bugButton.Parent = hlBugReport
        uiLibrary.corner(bugButton, theme.RadiusMd)
        local sharedValue35 = uiLibrary.stroke(bugButton, theme.Hairline, 1)
        local sharedValue36 = uiLibrary.icon(bugButton, "bug", 20, theme.TextSub)
        sharedValue36.AnchorPoint, sharedValue36.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
        local rec = Instance.new("Frame")
        rec.Name, rec.AnchorPoint, rec.Position, rec.Size =
            "Rec", Vector2.new(1, 0), UDim2.new(1, -4, 0, 4), UDim2.fromOffset(8, 8)
        rec.BorderSizePixel = 0
        rec.BackgroundColor3 = theme.StatusBad
        rec.Visible = false
        rec.Parent = bugButton
        uiLibrary.corner(rec, 4)
        uiLibrary.tip(
            bugButton,
            "Bug report: press to record what the bot does into files you can send us - a new file for every server. It keeps recording until you press it again."
        )
        local bugToast = Instance.new("TextButton")
        bugToast.Name = "BugToast"
        bugToast.Text = ""
        bugToast.AutoButtonColor = false
        bugToast.BorderSizePixel = 0
        bugToast.AnchorPoint, bugToast.Position = Vector2.new(1, 1), UDim2.new(1, -16, 1, sharedValue34 - 50)
        bugToast.Size, bugToast.AutomaticSize = UDim2.fromOffset(320, 0), Enum.AutomaticSize.Y
        bugToast.BackgroundColor3 = theme.SurfaceChip
        bugToast.Visible = false
        bugToast.Parent = hlBugReport
        uiLibrary.corner(bugToast, theme.RadiusMd)
        uiLibrary.stroke(bugToast, theme.Hairline, 1)
        sharedValue34 = Instance.new("UIPadding")
        sharedValue34.PaddingTop, sharedValue34.PaddingBottom, sharedValue34.PaddingLeft, sharedValue34.PaddingRight =
            UDim.new(0, 10), UDim.new(0, 10), UDim.new(0, 12), UDim.new(0, 12)
        sharedValue34.Parent = bugToast
        sharedValue34 = Instance.new("UIListLayout")
        sharedValue34.SortOrder, sharedValue34.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
        sharedValue34.Parent = bugToast
        local function helper147(layoutOrder, textSize, argument, textColor3)
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.LayoutOrder = layoutOrder
            label.TextSize = textSize
            label.TextColor3 = textColor3
            label.Size, label.AutomaticSize, label.TextWrapped, label.TextXAlignment =
                UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, true, Enum.TextXAlignment.Left
            uiLibrary.setFont(label, "sans", argument)
            label.Parent = bugToast
            return label
        end
        local textControl25 = helper147(1, 14, Enum.FontWeight.SemiBold, theme.TextPrimary)
        local textControl26, sharedValue37 = helper147(2, 12, Enum.FontWeight.Regular, theme.TextSub), 0
        local function helper148(text, text2, argument)
            sharedValue37 += 1
            local value = sharedValue37
            textControl25.Text = text
            textControl26.Text = text2
            bugToast.Visible = true
            task.delay(argument or 8, function()
                if sharedValue37 == value then
                    if bugToast.Parent then
                        bugToast.Visible = false
                    end
                end
            end)
        end
        local function helper149()
            sharedValue36.ImageColor3 = bug.on and theme.StatusBad or theme.TextSub
            sharedValue35.Color = bug.on and theme.StatusBad or theme.Hairline
            rec.Visible = bug.on
        end
        local function bugStop(argument)
            if not bug.on then
                return
            end
            local value = os.clock() - bug.t0
            add(
                "END",
                ("part %d stopped: %s - %.0fs, %d lines"):format(bug.part or 1, argument, value, bug.n + 1)
            )
            helper140()
            bug.on = false
            runtimeState.bugLog = nil
            runtimeState.bugKey = nil
            for index, conn in ipairs(bug.conns) do
                pcall(function()
                    conn:Disconnect()
                end)
            end
            table.clear(bug.conns)
            bug.all = nil
            pcall(helper149)
            if argument == "stopped by hand" then
                helper128(nil)
                pcall(
                    helper148,
                    "Bug report saved.",
                    ("%d file%s (one per server) in %s in your executor's workspace folder. Send us all of them with your report."):format(
                        bug.part or 1,
                        (bug.part or 1) == 1 and "" or "s",
                        tostring(bug.where or bug.file)
                    ),
                    14
                )
            end
            context.log("Bug report", ("stopped (%s): %s"):format(argument, tostring(bug.file)))
        end
        bug.stop = bugStop
        context.bugStop = bugStop
        local function helper150(argument)
            local humanoid = argument and (argument:WaitForChild("Humanoid", 10))
            if not (humanoid and bug.on) then
                return
            end
            local walkSpeed = humanoid.WalkSpeed
            local value = humanoid.Health
            bug.conns[#bug.conns + 1] = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                add("SPEED", ("WalkSpeed %.1f -> %.1f"):format(walkSpeed, humanoid.WalkSpeed))
                walkSpeed = humanoid.WalkSpeed
            end)
            bug.conns[#bug.conns + 1] = humanoid.HealthChanged:Connect(function(argument2)
                local value2 = value - argument2
                if value2 >= math.max(1, humanoid.MaxHealth) * 0.05 then
                    add(
                        "HIT",
                        ("-%d (%.0f%%) -> %d/%d"):format(
                            math.floor(value2),
                            value2 / math.max(1, humanoid.MaxHealth) * 100,
                            math.floor(argument2),
                            math.floor(humanoid.MaxHealth)
                        )
                    )
                end
                value = argument2
            end)
            bug.conns[#bug.conns + 1] = humanoid.Died:Connect(function()
                add("DIED", "while: " .. tostring(runtimeState.movementState))
                helper140()
            end)
        end
        local function start2(argument)
            if bug.on then
                return
            end
            if type(writefile) ~= "function" then
                helper148("Can't record a bug report.", "This executor can't save files.", 8)
                return
            end
            pcall(context.ensureFolders)
            local success, value =
                context.PATH and context.PATH.logs or "HarvardLabs/logs", argument and helper127() or nil
            if not value then
                local value2
                pcall(function()
                    value2 = sharedValue20:GenerateGUID(false):gsub("%W", ""):sub(1, 6):lower()
                end)
                value = {
                    on = true,
                    session = ("bugreport_%s_%s"):format(
                        os.date("%Y-%m-%d_%H-%M-%S"),
                        value2 or tostring(math.random(100000, 999999))
                    ),
                    part = 0,
                    since = os.date("%Y-%m-%d %H:%M:%S"),
                }
            end
            value.part = (tonumber(value.part) or 0) + 1
            local value3, value4 = success .. "/" .. value.session, false
            pcall(function()
                if type(isfolder) == "function" then
                    if type(makefolder) == "function" then
                        if not (isfolder(value3)) then
                            makefolder(value3)
                        end
                        value4 = isfolder(value3)
                    end
                end
            end)
            bug.part, bug.since, bug.where = value.part, value.since, value4 and value3 or success
            bug.file = value4
                    and ("%s/part%02d_%s_place%s.txt"):format(
                        value3,
                        value.part,
                        os.date("%H-%M-%S"),
                        tostring(game.PlaceId)
                    )
                or ("%s/%s_part%02d.txt"):format(success, value.session, value.part)
            argument = nil
            argument, sharedValue26, sharedValue27, sharedValue28, sharedValue29, sharedValue30 =
                -math.huge, {}, {}, 0, 0, 0
            sharedValue31 = argument
            bug.buf = {}
            bug.all = nil
            bug.bytes = 0
            bug.n = 0
            bug.last = {}
            bug.cfg = {}
            bug.t0 = os.clock()
            success, argument = pcall(helper143)
            argument = if success
                then argument
                else "Swangy bug report\10header failed: " .. tostring(argument) .. "\10"
            if not (pcall(writefile, bug.file, argument)) then
                helper148("Can't record a bug report.", "Could not write " .. bug.file .. ".", 8)
                return
            end
            if not sharedValue24 then
                bug.all = { argument }
            end
            bug.bytes = #argument
            bug.on = true
            helper128(value)
            function runtimeState.bugLog(argument2, argument3)
                add("LOG", ("[%s] %s"):format(tostring(argument2), tostring(argument3)))
            end
            function runtimeState.bugKey(argument2, argument3)
                add(
                    "KEY",
                    (typeof(argument2) == "EnumItem" and argument2.Name or tostring(argument2))
                        .. (argument3 and " - held back: a kit swap is due" or "")
                )
            end
            success = bug.conns
            success[#success + 1] = runService.Heartbeat:Connect(function(gap)
                bug.frames = bug.frames + 1
                if gap > (bug.gap or 0) then
                    bug.gap = gap
                end
            end)
            success[#success + 1] = localPlayer.CharacterAdded:Connect(function(argument2)
                add("SPAWN", "new character")
                task.spawn(helper150, argument2)
            end)
            success[#success + 1] = sharedValue5.PlayerAdded:Connect(function(argument2)
                pcall(helper133, argument2)
                add("PLAYER", "joined: " .. tostring(argument2.Name))
            end)
            success[#success + 1] = sharedValue5.PlayerRemoving:Connect(function(argument2)
                pcall(helper133, argument2)
                add("PLAYER", "left: " .. tostring(argument2.Name))
            end)
            local value5, value6, value7 = 0, 0
            success[#success + 1] = sharedValue21.MessageOut:Connect(function(argument2, argument3)
                local now = os.clock()
                if now - value5 >= 1 then
                    value5, value6 = now, 0
                end
                value6 += 1
                if value6 > 40 then
                    return
                elseif argument2 == value7 then
                    return
                end
                value7 = argument2
                add(
                    "CONSOLE",
                    tostring(argument3 and argument3.Name or "?"):gsub("^Message", "")
                        .. ": "
                        .. tostring(argument2)
                )
            end)
            success[#success + 1] = sharedValue22.ErrorMessageChanged:Connect(function(argument2)
                if argument2 then
                    if argument2 ~= "" then
                        add("KICK", argument2)
                        helper140()
                    end
                end
            end)
            success[#success + 1] = localPlayer.OnTeleport:Connect(function(argument2, argument3)
                add(
                    "TELEPORT",
                    ("%s, place %s"):format(tostring(argument2 and argument2.Name), tostring(argument3))
                )
                if argument2 == Enum.TeleportState.Started then
                    bugStop("switched servers")
                elseif argument2 == Enum.TeleportState.RequestedFromServer then
                    bugStop("switched servers")
                end
            end)
            task.spawn(helper150, localPlayer.Character)
            helper149()
            if value.part == 1 then
                helper148(
                    "Now recording bug report, click to stop.",
                    ("Saving to %s in your executor's workspace folder, a new file every time you change server. It keeps recording until you press the bug again."):format(
                        bug.where
                    ),
                    10
                )
            else
                helper148(
                    ("Still recording the bug report (part %d)."):format(value.part),
                    ("A new file for this server in %s. Press the bug to stop recording."):format(bug.where),
                    8
                )
            end
            context.log("Bug report", "recording to " .. bug.file)
            task.spawn(function()
                local now, value8, now2, value9 = os.clock(), -math.huge, (os.clock()), false
                while bug.on and not runtimeState.destroyed do
                    local now3 = os.clock()
                    bug.fps = math.floor(bug.frames / math.max(now3 - now, 0.05) + 0.5)
                    bug.frames = 0
                    local success2, value10 = pcall(helper144)
                    add("TICK", success2 and value10 or "could not read: " .. tostring(value10))
                    if now3 - value8 >= 2 then
                        pcall(helper146)
                        value8 = now3
                    end
                    if now3 - now2 >= 1 then
                        helper140()
                        now2 = now3
                    end
                    value9, rec.BackgroundTransparency = not value9, (if value9 then not value9 else 0) or 0.6
                    if bug.bytes >= (sharedValue24 and 16 or 3) * 1024 * 1024 then
                        bugStop("the file reached its size limit")
                        task.defer(start2, true)
                        now = now3
                        break
                    end
                    task.wait(0.5)
                    now = now3
                end
            end)
        end
        bug.start = start2
        local function helper151()
            if bug.on then
                bugStop("stopped by hand")
            else
                start2()
            end
        end
        bugButton.Activated:Connect(helper151)
        if helper127() then
            task.delay(3, function()
                if not runtimeState.destroyed then
                    if not bug.on then
                        start2(true)
                    end
                end
            end)
        end
        do
            local connection5
            local function helper152(argument)
                if runtimeState.destroyed then
                    connection5:Disconnect()
                    return
                end
                if argument == Enum.TeleportState.Failed then
                    if not bug.on then
                        if helper127() then
                            task.delay(1, start2, true)
                        end
                    end
                end
            end
            connection5 = localPlayer.OnTeleport:Connect(helper152)
        end
        local function helper153()
            if bug.on then
                bugStop("stopped by hand")
            else
                bugToast.Visible = false
            end
        end
        bugToast.Activated:Connect(helper153)
    end
    do
        local sharedValue38, sharedValue39 =
            getService("HttpService"), { hold = nil, halted = false, tries = 0 }
        sharedValue39.lastTry = -math.huge
        context.MD = sharedValue39
        sharedValue39.canFiles = type(writefile) == "function"
            and type(readfile) == "function"
            and type(isfile) == "function"
        sharedValue39.file = function()
            return (context.PATH and context.PATH.data or "HarvardLabs/data")
                .. "/modhold_"
                .. tostring(localPlayer.UserId)
                .. ".json"
        end
        sharedValue39.pendFile = function()
            return (context.PATH and context.PATH.data or "HarvardLabs/data")
                .. "/modpending_"
                .. tostring(localPlayer.UserId)
                .. ".json"
        end
        sharedValue39.savePending = function(argument)
            if not sharedValue39.canFiles then
                return
            end
            pcall(context.ensureFolders)
            pcall(function()
                writefile(sharedValue39.pendFile(), argument and sharedValue38:JSONEncode(argument) or "{}")
            end)
        end
        sharedValue39.save = function()
            if not sharedValue39.canFiles then
                return
            end
            pcall(context.ensureFolders)
            pcall(function()
                if sharedValue39.hold then
                    writefile(sharedValue39.file(), sharedValue38:JSONEncode(sharedValue39.hold))
                elseif isfile(sharedValue39.file()) or sharedValue39.restEndedAt then
                    writefile(
                        sharedValue39.file(),
                        sharedValue38:JSONEncode({ holdUntil = 0, restEndedAt = sharedValue39.restEndedAt })
                    )
                end
            end)
        end
        sharedValue39.norm = function(argument)
            return tostring(argument or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("^@", ""):lower()
        end
        sharedValue39.names = function()
            local value = {}
            for index, entry in ipairs(type(config.modWhitelist) == "table" and config.modWhitelist or {}) do
                index = sharedValue39.norm(entry)
                if index ~= "" then
                    value[index] = true
                end
            end
            return value
        end
        sharedValue39.syncWhitelist = function()
            if config.modWhitelistSync == false then
                return 0
            end
            local value = sharedValue39.names()
            local modWhitelist, value2 =
                type(config.modWhitelist) == "table" and config.modWhitelist or {}, {}
            local function helper6(argument)
                argument = tostring(argument or ""):gsub("^%s+", ""):gsub("%s+$", "")
                local value3 = sharedValue39.norm(argument)
                if value3 ~= "" then
                    if not value[value3] then
                        value[value3] = true
                        modWhitelist[#modWhitelist + 1] = argument
                        value2[#value2 + 1] = argument
                    end
                end
            end
            pcall(function()
                for index, entry in ipairs(context.AF.parties()) do
                    for index2, entry2 in ipairs(type(entry) == "table" and entry.accounts or {}) do
                        helper6(entry2.name)
                    end
                end
            end)
            pcall(function()
                for index, entry in ipairs(context.AF.injected(config.modOursAge or 2592000)) do
                    helper6(entry)
                end
            end)
            if #value2 == 0 then
                return 0
            end
            config.modWhitelist = modWhitelist
            if context.saveConfig then
                pcall(context.saveConfig)
            end
            if context.refreshAll then
                pcall(context.refreshAll)
            end
            if context.log then
                context.log(
                    "ModDetect",
                    ("whitelist: added %d of your accounts (%s)"):format(#value2, table.concat(value2, ", "))
                )
            end
            return #value2
        end
        task.spawn(function()
            task.wait(5)
            while not runtimeState.destroyed do
                pcall(sharedValue39.syncWhitelist)
                task.wait(config.wlSyncEvery or 30)
            end
        end)
        sharedValue39.partyIds = function()
            if sharedValue39.partyAt then
                if os.clock() - sharedValue39.partyAt < 30 then
                    return sharedValue39.party
                end
            end
            sharedValue39.partyAt = os.clock()
            local party
            pcall(function()
                local value = getService("TeleportService"):GetLocalPlayerTeleportData()
                if type(value) == "table" and type(value.playerIds) == "table" then
                    party = {}
                    local value2, playerIds = pairs, value.playerIds
                    for key, playerId in value2(playerIds) do
                        key = tonumber(playerId)
                        if key then
                            party[key] = true
                        end
                    end
                    if tonumber(value.ownerId) then
                        value2 = party
                        value2[tonumber(value.ownerId)] = true
                    end
                end
            end)
            sharedValue39.party = party
            return party
        end
        sharedValue39.logWhy = function(argument)
            sharedValue39.why = argument.text
            pcall(function()
                argument.at, argument.job, argument.who =
                    os.time(), string.sub(game.JobId, 1, 8), localPlayer.Name
                local value = workspaceService:FindFirstChild("dungeonName")
                argument.dungeon = value and tostring(value.Value) or ""
                value = sharedValue38:JSONEncode(argument) .. "\10"
                if config.devLogs ~= true then
                    return
                end
                if type(appendfile) == "function" then
                    appendfile("HarvardLabs/logs/moddetect.jsonl", value)
                else
                    local value2 = ""
                    pcall(function()
                        value2 = readfile("HarvardLabs/logs/moddetect.jsonl")
                    end)
                    writefile("HarvardLabs/logs/moddetect.jsonl", value2 .. value)
                end
            end)
        end
        sharedValue39.allowed = function(player, argument)
            if player == localPlayer then
                return true
            end
            if (argument or sharedValue39.names())[sharedValue39.norm(player.Name)] == true then
                return true
            end
            argument = sharedValue39.inDungeon() and sharedValue39.partyIds()
            if argument then
                if argument[player.UserId] then
                    return true
                end
            end
            sharedValue39.ours = sharedValue39.ours or {}
            local value, now = sharedValue39.norm(player.Name), os.clock()
            argument = sharedValue39.ours[value]
            if if argument then now - argument.at > 10 else not argument then
                argument = {
                    at = now,
                    ours = context.AF and context.AF.entry and context.AF.entry(player.Name) ~= nil
                        or context.AF and context.AF.partyOf and context.AF.partyOf(player.Name) ~= nil
                        or context.AF and context.AF.presence and context.AF.presence(
                            player.Name,
                            config.modOursAge or 2592000
                        ) ~= nil
                        or false,
                }
                sharedValue39.ours[value] = argument
            end
            return argument.ours
        end
        sharedValue39.LEVEL_IDS = { [85776757589518] = true, [115445507767090] = true }
        sharedValue39.inDungeon = function()
            if sharedValue39.LEVEL_IDS[game.PlaceId] then
                return true
            end
            local value = context.LB and context.LB.place
            if value == "Level" then
                return true
            elseif value == "100+" then
                return true
            end
            if value == "Lobby" then
                return false
            elseif game.PlaceId == 77649408247578 then
                return false
            end
            value = workspaceService:FindFirstChild("dungeonName")
            return value ~= nil and value:IsA("StringValue") and value.Value ~= ""
        end
        sharedValue39.queueText = function()
            local value, autoQueueDifficulty, value2 =
                config.autoQueueMap, config.autoQueueDifficulty, config.autoQueueHardcore == true
            if context.queuePick then
                value, autoQueueDifficulty, value2 = context.queuePick()
            end
            local value3, value4 = tostring(value or "?"), tostring(autoQueueDifficulty or "?")
            return ("%s, %s%s"):format(value3, value4, value2 and " (Hardcore)" or "")
        end
        sharedValue39.left = function()
            return sharedValue39.hold
                    and math.max(0, (tonumber(sharedValue39.hold.holdUntil) or 0) - os.time())
                or 0
        end
        sharedValue39.restingUntil = function()
            local hold = sharedValue39.hold
            if
                if hold
                    then config.modDetect ~= true
                        and not sharedValue39.hold.stranger
                        and not sharedValue39.hold.farmBreak
                    else not hold
            then
                return nil
            elseif sharedValue39.hold.reason ~= "drop" then
                return nil
            elseif sharedValue39.left() <= 0 then
                return nil
            end
            return tonumber(sharedValue39.hold.holdUntil)
        end
        sharedValue39.fmt = function(argument)
            local value = math.floor(argument / 60)
            return ("%dm %02ds"):format(value, argument % 60)
        end
        sharedValue39.stopAll = function()
            runtimeState.modHalt = true
            runtimeState.farmEnabled = false
            pcall(context.setLoopButtonState)
            local value = helper2()
            pcall(function()
                if value then
                    value:Move(Vector3.zero)
                end
            end)
            pcall(clearDrawing)
        end
        sharedValue39.goLobby = function()
            sharedValue39.tries, sharedValue39.lastTry = sharedValue39.tries + 1, os.clock()
            if game.PlaceId == 101088859550383 then
                if context.gsNewRun then
                    if sharedValue39.hold then
                        if context.gsToLobby then
                            context.gsToLobby("a rest")
                        else
                            context.gsNewRun("leaving the run")
                        end
                    else
                        context.gsNewRun("leaving the run")
                    end
                    return
                end
            end
            local remotes = getService("ReplicatedStorage"):FindFirstChild("remotes")
            local value = remotes and (remotes:FindFirstChild("ReturnToLobbyEvent"))
            if value then
                if sharedValue39.tries <= 2 then
                    pcall(value.FireServer, value)
                    context.log("ModDetect", "ReturnToLobbyEvent sent (try " .. sharedValue39.tries .. ")")
                    return
                end
            end
            local value2 = 77649408247578
            pcall(function()
                local value3 = require(getService("ReplicatedStorage").Utility.PlaceManager)
                value2 = value3.GetLivePlaceIdByName("Lobby") or value2
            end)
            pcall(function()
                getService("TeleportService"):Teleport(value2, localPlayer)
            end)
            context.log("ModDetect", "teleport to the lobby place sent (try " .. sharedValue39.tries .. ")")
        end
        sharedValue39.noteKick = function(argument)
            if not sharedValue39.canFiles then
                return
            end
            pcall(context.ensureFolders)
            pcall(function()
                local value, paths = writefile, context.PATH
                local value2, toString, userId =
                    paths and context.PATH.data or "HarvardLabs/data", tostring, localPlayer.UserId
                local value3, value4 =
                    value2 .. "/modkick_" .. toString(userId) .. ".json", {
                        at = os.time(),
                        userId = localPlayer.UserId,
                        name = localPlayer.Name,
                        why = tostring(argument),
                    }
                value4.job = string.sub(game.JobId, 1, 8)
                value(value3, sharedValue38:JSONEncode(value4))
            end)
        end
        sharedValue39.kick = function(argument)
            if sharedValue39.kicked then
                return
            end
            sharedValue39.kicked = true
            context.log("ModDetect", "kicking the account: " .. tostring(argument))
            sharedValue39.noteKick(argument)
            pcall(function()
                localPlayer:Kick("Swangy mod detection: " .. tostring(argument))
            end)
        end
        sharedValue39.clear = function()
            sharedValue39.hold = nil
            sharedValue39.save()
            if context.LB then
                context.LB.sawLevel, context.LB.arrivedAt, context.LB.lastAttempt = true, nil, -math.huge
            end
        end
        sharedValue39.setOn = function(argument)
            if argument then
                return
            end
            if sharedValue39.hold then
                if not sharedValue39.hold.farmBreak then
                    sharedValue39.clear()
                end
            end
            if sharedValue39.halted then
                sharedValue39.halted = false
                runtimeState.modHalt = false
            end
        end
        sharedValue39.restRejoinOk = function()
            return sharedValue39.restEndedAt ~= nil
                and os.time() - sharedValue39.restEndedAt < (tonumber(config.afRestRejoinFor) or 1800)
        end
        sharedValue39.toRest = function()
            if sharedValue39.hold then
                if not (sharedValue39.hold.reason == "user") then
                    return
                end
            else
                return
            end
            if sharedValue39.inDungeon() then
                if sharedValue39.hold.job == game.JobId then
                    return
                end
            end
            sharedValue39.hold.reason, sharedValue39.hold.stranger = "drop", true
            sharedValue39.hold.holdUntil = tonumber(sharedValue39.hold.restUntil)
                or (tonumber(sharedValue39.hold.at) or os.time())
                    + (tonumber(config.modStrangerRest) or 7200)
            sharedValue39.save()
            context.log(
                "ModDetect",
                ("a stranger was in the last run - resting until %s before queueing again"):format(
                    os.date("%H:%M", sharedValue39.hold.holdUntil)
                )
            )
            if context.notify then
                context.notify(
                    "warning",
                    "Resting",
                    ("A stranger was in the last run - resting until %s."):format(
                        os.date("%H:%M", sharedValue39.hold.holdUntil)
                    ),
                    8
                )
            end
        end
        -- DQR network policy: the Roblox games.roblox.com server probe is gone.
        -- Callers already treat nil as "no low-pop server found".
        sharedValue39.lowPopServer = function()
            return nil
        end
        sharedValue39.spreadLobby = function()
            if config.lobbySpread == false then
                return
            elseif game.PlaceId ~= 77649408247578 then
                return
            end
            if sharedValue39.hold then
                if sharedValue39.hold.spread then
                    return
                end
            else
                return
            end
            if os.clock() - (sharedValue39.spreadTried or -math.huge) < (config.lobbySpreadRetry or 20) then
                return
            end
            sharedValue39.spreadTried = os.clock()
            local value = sharedValue39.lowPopServer()
            if not value then
                return
            end
            sharedValue39.hold.spread = true
            pcall(sharedValue39.save)
            context.log(
                "ModDetect",
                "resting - moving to a quieter Dungeon Quest server so the accounts spread across lobbies"
            )
            pcall(function()
                getService("TeleportService"):TeleportToPlaceInstance(77649408247578, value, localPlayer)
            end)
        end
        sharedValue39.lobbyHold = function()
            if not sharedValue39.hold then
                return false
            end
            sharedValue39.toRest()
            if config.modDetect ~= true then
                if not sharedValue39.hold.stranger then
                    if not sharedValue39.hold.farmBreak then
                        sharedValue39.clear()
                        return false
                    end
                end
            end
            local value = sharedValue39.left()
            if value <= 0 then
                if sharedValue39.hold.farmBreak then
                    sharedValue39.breakOver()
                    return false
                end
                sharedValue39.restEndedAt = os.time()
                sharedValue39.clear()
                context.log(
                    "ModDetect",
                    "the wait is over - back to the party (joining its run if it is in one)"
                )
                if context.notify then
                    context.notify(
                        "info",
                        "Back to the party",
                        "The wait after the mod detection is over - rejoining the party."
                    )
                end
                return false
            end
            if sharedValue39.spreadLobby then
                pcall(sharedValue39.spreadLobby)
            end
            local value2, value3 =
                sharedValue39.hold.farmBreak and "on a break; requeueing in %s"
                    or "mod detection flagged; requeueing in %s",
                argumentHelpers[108](sharedValue39.fmt(value))
            return true, value2:format(argumentHelpers:unpackValues(value3))
        end
        sharedValue39.flagFile = function()
            return (context.PATH and context.PATH.data or "HarvardLabs/data") .. "/modflag.json"
        end
        sharedValue39.readFlag = function()
            if not sharedValue39.canFiles then
                return nil
            end
            local success, value = pcall(function()
                local value2 = argumentHelpers[108](readfile(sharedValue39.flagFile()))
                return sharedValue38:JSONDecode(argumentHelpers:unpackValues(value2))
            end)
            return success and type(value) == "table" and value or nil
        end
        sharedValue39.still = function(argument, argument2, how, argument3)
            sharedValue39.halted = true
            sharedValue39.stopAll()
            if config.modKick == true or argument3 == true then
                local now = os.clock()
                task.spawn(function()
                    while true do
                        local value, toNumber = os.clock() - now, tonumber
                        if not (value < (toNumber(config.modKickMaxWait) or 4)) then
                            break
                        end
                        if argument2 and (sharedValue39.post == nil or sharedValue39.post.over) then
                            if os.clock() - now > 0.3 then
                                break
                            end
                        end
                        if not argument2 then
                            break
                        end
                        task.wait(0.1)
                    end
                    sharedValue39.kick(
                        ("a player not on the whitelist %s the run (%s)"):format(
                            tostring(how or "joined"),
                            tostring(argument)
                        )
                    )
                end)
            end
            if config.modStillReset ~= false and sharedValue39.resetJob ~= game.JobId then
                sharedValue39.resetJob = game.JobId
                local character = localPlayer.Character
                local humanoid = character and (character:FindFirstChildOfClass("Humanoid"))
                if humanoid and humanoid.Health > 0 then
                    runtimeState.selfResetAt = os.clock()
                    pcall(function()
                        humanoid.Health = 0
                    end)
                    pcall(function()
                        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                    end)
                    context.log("ModDetect", "reset the character - standing still at the spawn")
                end
            end
            local dungeonName = workspaceService:FindFirstChild("dungeonName")
            sharedValue39.hold = {
                holdUntil = os.time() + math.floor((tonumber(config.modStillMax) or 30) * 60),
                at = os.time(),
                who = tostring(argument or "?"),
                reason = "user",
                kick = config.modKick == true or argument3 == true or nil,
                restUntil = os.time() + (tonumber(config.modStrangerRest) or 7200),
                job = game.JobId,
                dungeon = dungeonName and tostring(dungeonName.Value) or "",
                queue = sharedValue39.queueText(),
            }
            sharedValue39.save()
            if context.WH then
                context.WH.run = nil
            end
            if argument2 then
                pcall(context.ensureFolders)
                pcall(function()
                    writefile(
                        sharedValue39.flagFile(),
                        sharedValue38:JSONEncode({
                            job = game.JobId,
                            at = os.time(),
                            by = localPlayer.Name,
                            who = tostring(argument or "?"),
                            how = how,
                            kick = config.modKick == true or argument3 == true or nil,
                        })
                    )
                end)
                sharedValue39.post = context.WH
                        and context.WH.modDetected
                        and context.WH.modDetected(tostring(argument), sharedValue39.hold.queue, nil, how)
                    or nil
                sharedValue39.postAt = os.clock()
                context.log(
                    "ModDetect",
                    "flagged - every account here stands still until the run ends, then back to the lobby"
                )
                if context.notify then
                    context.notify(
                        "warning",
                        "Mod in the run",
                        "A stranger joined. Every account stands still until the run ends.",
                        8
                    )
                end
            else
                context.log("ModDetect", "another account here flagged - standing still until the run ends")
                if context.notify then
                    context.notify(
                        "warning",
                        "Mod in the run",
                        "Another account flagged it. Standing still until the run ends.",
                        8
                    )
                end
            end
        end
        sharedValue39.allowedName = function(argument, argument2)
            local value = sharedValue39.norm(argument)
            if value == "" then
                return true
            elseif value == sharedValue39.norm(localPlayer.Name) then
                return true
            end
            if sharedValue39.names()[value] == true then
                return true
            end
            value = sharedValue39.inDungeon() and sharedValue39.partyIds()
            if value then
                if argument2 then
                    if value[argument2] then
                        return true
                    end
                end
            end
            if context.AF then
                if context.AF.entry then
                    if context.AF.entry(argument) ~= nil then
                        return true
                    end
                end
            end
            if context.AF then
                if context.AF.partyOf then
                    if context.AF.partyOf(argument) ~= nil then
                        return true
                    end
                end
            end
            if context.AF then
                if context.AF.presence then
                    if context.AF.presence(argument, 86400) ~= nil then
                        return true
                    end
                end
            end
            return false
        end
        sharedValue39.reportStranger = function(argument, argument2, how)
            if config.strangerReport == false then
                return
            end
            sharedValue39.reported = sharedValue39.reported or {}
            local value = sharedValue39.norm(argument) .. "|" .. tostring(game.JobId)
            if sharedValue39.reported[value] then
                return
            end
            sharedValue39.reported[value] = true
            local value2 = context.ST
            local value3 = (value2 and value2.url and value2.url() or ""):gsub("/v1/run.*$", "")
            local key = context.licenceKey and context.licenceKey() or nil
            if value3 == "" then
                return
            elseif not key then
                return
            elseif not (value2 and value2.post) then
                return
            end
            local dungeonName = workspaceService:FindFirstChild("dungeonName")
            local success, value4 = pcall(function()
                local value5 = {
                    key = key,
                    name = tostring(argument),
                    uid = tonumber(argument2) or 0,
                    how = how,
                    dungeon = dungeonName and tostring(dungeonName.Value) or "",
                    job = tostring(game.JobId),
                    place = game.PlaceId,
                    seen = tostring(localPlayer.Name),
                }
                return sharedValue38:JSONEncode(value5)
            end)
            if not success then
                return
            end
            task.spawn(function()
                for index = 1, 3, 1 do
                    if value2.post(value3 .. "/v1/stranger", value4) then
                        return
                    end
                    task.wait(index * 2)
                end
            end)
        end
        sharedValue39.onJoinRequest = function(argument, player, userId, argument2)
            if userId == "close" then
                return
            elseif type(player) ~= "string" then
                return
            elseif argument == nil then
                return
            end
            if config.modDetect ~= true then
                return
            elseif config.modJoinRequests == false then
                return
            elseif sharedValue39.halted then
                return
            elseif runtimeState.destroyed then
                return
            elseif not (sharedValue39.inDungeon()) then
                return
            end
            userId = tonumber(tostring(argument):match("^(%d+)_"))
            if sharedValue39.allowedName(player, userId) then
                return
            end
            sharedValue39.logWhy({
                reason = "join request",
                player = player,
                userId = userId,
                level = tostring(argument2),
                text = ("%s asked to join the run and is not in the party or on the whitelist"):format(
                    player
                ),
            })
            pcall(sharedValue39.reportStranger, player, userId, "asked to join")
            sharedValue39.still(player, true, "asked to join")
        end
        sharedValue39.hookJoins = function()
            if sharedValue39.joinsHookedJob == game.JobId then
                return
            end
            local value = getService("ReplicatedStorage"):FindFirstChild("remotes")
            local value2 = value and (value:FindFirstChild("showJoinRequest"))
            if not value2 then
                return
            end
            sharedValue39.joinsHookedJob = game.JobId
            value = context.sliderConnections or {}
            value[#value + 1] = value2.OnClientEvent:Connect(
                function(argument, argument2, argument3, argument4)
                    local success, value3 =
                        pcall(sharedValue39.onJoinRequest, argument, argument2, argument3, argument4)
                    if not success then
                        if context.log then
                            context.log("ModDetect", "join request check failed: " .. tostring(value3))
                        end
                    end
                end
            )
            value[#value + 1] = sharedValue5.PlayerAdded:Connect(function(argument)
                pcall(sharedValue39.detect, argument)
            end)
        end
        sharedValue39.lateJoinGuard = function()
            if config.lateJoinGuard == false then
                return
            elseif not (sharedValue39.inDungeon()) then
                return
            end
            if context.AF then
                if context.AF.ownRun then
                    if not (context.AF.ownRun()) then
                        return
                    end
                else
                    return
                end
            else
                return
            end
            if context.AF.lateJoinWanted == game.JobId then
                return
            end
            local value, value2 =
                localPlayer:FindFirstChild("dataLoaded"), localPlayer:FindFirstChild("lateJoin")
            local value3 = value ~= nil
                and value:IsA("BoolValue")
                and value2 ~= nil
                and value2:IsA("StringValue")
            if value3 then
                if value.Value ~= true then
                    return
                end
                if value2.Value == "off" then
                    if sharedValue39.ljClosedJob ~= game.JobId then
                        sharedValue39.ljClosedJob, context.AF.ljOpen = game.JobId, nil
                    end
                    if sharedValue39.ljTryJob == game.JobId then
                        sharedValue39.ljTries = 0
                    end
                    return
                end
            else
                if sharedValue39.ljWaitJob ~= game.JobId then
                    sharedValue39.ljWaitJob, sharedValue39.ljWaitAt = game.JobId, os.clock()
                end
                if os.clock() - sharedValue39.ljWaitAt < (config.ljValueWait or 30) then
                    return
                end
                if sharedValue39.ljClosedJob == game.JobId then
                    if context.AF.ljOpen ~= game.JobId then
                        return
                    end
                end
            end
            if sharedValue39.ljTryJob ~= game.JobId then
                sharedValue39.ljTryJob = game.JobId
                sharedValue39.ljTries = 0
                sharedValue39.ljTryAt = nil
            end
            if sharedValue39.ljTries >= (config.ljTriesMax or 10) then
                return
            end
            if os.clock() - (sharedValue39.ljTryAt or -math.huge) < (config.ljRetry or 3) then
                return
            end
            value2 = getService("ReplicatedStorage"):FindFirstChild("remotes")
            value = value2 and (value2:FindFirstChild("hostSetLateJoin"))
            if not value then
                return
            end
            sharedValue39.ljTryAt, sharedValue39.ljTries = os.clock(), sharedValue39.ljTries + 1
            if not value3 then
                sharedValue39.ljClosedJob, context.AF.ljOpen = game.JobId, nil
            end
            pcall(value.FireServer, value, "off")
            if sharedValue39.ljTries == 1 then
                context.log(
                    "ModDetect",
                    "late join closed for this run (opened only while an account of ours is out of it)"
                )
            elseif sharedValue39.ljTries >= (config.ljTriesMax or 10) then
                context.log(
                    "ModDetect",
                    ("late join would not close after %d tries - left as it is"):format(sharedValue39.ljTries)
                )
            end
        end
        sharedValue39.detect = function(player)
            if sharedValue39.halted then
                return
            elseif config.modDetect ~= true then
                return
            elseif runtimeState.destroyed then
                return
            end
            if player.Parent then
                if player.Parent:IsA("Players") then
                    if sharedValue39.allowed(player) then
                        return
                    elseif not (sharedValue39.inDungeon()) then
                        return
                    end
                else
                    return
                end
            else
                return
            end
            local value = sharedValue39.partyIds()
            sharedValue39.logWhy({
                reason = "player",
                player = player.Name,
                userId = player.UserId,
                inParty = value ~= nil and value[player.UserId] == true,
                partyKnown = value ~= nil,
                text = player.Name .. " is not in the party or on the whitelist",
            })
            pcall(sharedValue39.reportStranger, player.Name, player.UserId, "joined")
            sharedValue39.still(player.Name, true)
        end
        sharedValue39.RANK =
            { common = 0.1, uncommon = 0.2, rare = 0.5, epic = 1, legendary = 2, ultimate = 3 }
        sharedValue39.bigDrop = function(argument, argument2)
            local value, value2 = tostring(argument2 or ""):lower(), tostring(argument or ""):lower()
            argument = value2:find("gildenscale mage", 1, true) ~= nil
                or value2:find("gildenscale warrior", 1, true) ~= nil
            if value == "ultimate" then
                if config.modLeaveUltimate ~= false then
                    return true
                end
            end
            if value == "legendary" then
                if config.modLeaveLegendary ~= false then
                    return true
                end
            end
            if argument then
                if config.modLeaveValT3 ~= false then
                    if value == "epic" then
                        return true
                    elseif value == "legendary" then
                        return true
                    elseif value == "ultimate" then
                        return true
                    end
                end
            end
            if value == "epic" then
                if config.modLeaveEpic == true then
                    return true
                end
            end
            if config.modLeaveValAny == true then
                if value2:find("gildenscale", 1, true) ~= nil then
                    return true
                end
            end
            if config.modLeaveEnhanced ~= false then
                if value2 == "enhanced inner focus" then
                    return true
                elseif value2 == "enhanced inner rage" then
                    return true
                end
            end
            return false
        end
        sharedValue39.restSecs = function()
            local value = math.clamp(math.floor(tonumber(config.modWaitMin) or 10), 1, 60)
            local value2 = math.clamp(math.floor(tonumber(config.modWaitMax) or 30), value, 60)
            return math.random(value * 60, value2 * 60)
        end
        sharedValue39.dropWait = function()
            local value = config.whMerge ~= false and (tonumber(config.whMergeWait) or 12) or 0
            return math.max(
                (tonumber(config.whLootWait) or 3) + (tonumber(config.whGatherFor) or 3),
                tonumber(config.whRodinGather) or 4
            ) + value + 4
        end
        sharedValue39.dropRest = function(name2, rarity)
            if sharedValue39.halted then
                return
            elseif config.modDetect ~= true then
                return
            elseif runtimeState.destroyed then
                return
            elseif not (sharedValue39.inDungeon()) then
                return
            end
            local dungeonName = workspaceService:FindFirstChild("dungeonName")
            if dungeonName then
                if not (tostring(dungeonName.Value) == "Northern Lands") then
                    return
                end
            else
                return
            end
            local logWhy, value =
                sharedValue39.logWhy, { reason = "drop", item = tostring(name2), rarity = tostring(rarity) }
            value.text = ("%s (%s) dropped"):format(tostring(name2), tostring(rarity))
            logWhy(value)
            if sharedValue39.pendingDrop then
                return
            end
            sharedValue39.pendingDrop = { name = name2, rarity = rarity, at = os.clock() }
            sharedValue39.savePending({
                name = tostring(name2),
                rarity = tostring(rarity),
                job = game.JobId,
                at = os.time(),
            })
            context.log(
                "ModDetect",
                ("%s (%s) dropped - finishing the run (the bonus boss too), then the lobby and a rest"):format(
                    tostring(name2),
                    tostring(rarity)
                )
            )
            if context.notify then
                context.notify(
                    tostring(rarity):lower() == "ultimate" and "dropUltimate" or "drop",
                    "Leaving after this run",
                    ("%s (%s) - then a rest before the next queue."):format(tostring(name2), tostring(rarity)),
                    8
                )
            end
        end
        sharedValue39.finishDrop = function()
            local pendingDrop = sharedValue39.pendingDrop
            if pendingDrop then
                if sharedValue39.halted then
                    return
                end
            else
                return
            end
            local name2, rarity = pendingDrop.name, pendingDrop.rarity
            sharedValue39.pendingDrop = nil
            sharedValue39.savePending(nil)
            if sharedValue39.inDungeon() then
                sharedValue39.halted = true
                sharedValue39.stopAll()
            end
            local value, who, dungeonName =
                sharedValue39.restSecs(),
                ("%s (%s)"):format(tostring(name2 or "?"), tostring(rarity or "?")),
                workspaceService:FindFirstChild("dungeonName")
            sharedValue39.hold = {
                holdUntil = os.time() + value,
                at = os.time(),
                who = who,
                reason = "drop",
                job = game.JobId,
                dungeon = dungeonName and tostring(dungeonName.Value) or "",
                queue = sharedValue39.queueText(),
            }
            sharedValue39.save()
            pcall(function()
                local value2 = "HarvardLabs/data/af_" .. string.lower(localPlayer.Name) .. ".json"
                local value3 = sharedValue38:JSONDecode(readfile(value2))
                if type(value3) == "table" then
                    value3.resting, value3.dropPending, value3.at =
                        sharedValue39.hold.holdUntil, nil, os.time()
                    writefile(value2, sharedValue38:JSONEncode(value3))
                end
            end)
            sharedValue39.post = context.WH
                    and context.WH.dropRest
                    and context.WH.dropRest(
                        name2,
                        rarity,
                        sharedValue39.hold.queue,
                        sharedValue39.hold.holdUntil
                    )
                or nil
            sharedValue39.postAt = os.clock()
            sharedValue39.goAt = os.clock() + (config.modFinishWait or 3)
            context.log(
                "ModDetect",
                ("run over after the %s drop - to the lobby, requeueing in %s"):format(
                    who,
                    sharedValue39.fmt(value)
                )
            )
        end
        sharedValue39.BREAK_KEYS =
            { "breakOn", "breakFarmMin", "breakFarmMax", "breakRestMin", "breakRestMax" }
        sharedValue39.testSeen = os.time()
        sharedValue39.bParty = function()
            local value
            pcall(function()
                if context.AF then
                    if context.AF.load then
                        context.AF.load()
                    end
                end
                if context.AF then
                    if context.AF.partyOf then
                        value = context.AF.partyOf(localPlayer.Name, context.AF.doc)
                    end
                end
            end)
            if type(value) == "table" then
                if type(value.id) == "string" then
                    if value.id ~= "" then
                        return value
                    end
                end
            end
            return nil
        end
        sharedValue39.bget = function(argument)
            if sharedValue39.bPend then
                if sharedValue39.bPend[argument] ~= nil then
                    return sharedValue39.bPend[argument]
                end
            end
            local value = sharedValue39.bParty()
            if value then
                if value.breakOn == nil and config.breakOn == true and not sharedValue39.bMigrated then
                    sharedValue39.bMigrated = true
                    local value2 = {}
                    for index, key in ipairs(sharedValue39.BREAK_KEYS) do
                        value2[key] = config[key]
                    end
                    sharedValue39.bset(value2)
                    if sharedValue39.bPend then
                        if sharedValue39.bPend[argument] ~= nil then
                            return sharedValue39.bPend[argument]
                        end
                    end
                end
                if value[argument] ~= nil then
                    return value[argument]
                end
                if argument == "breakOn" then
                    return false
                end
            end
            return config[argument]
        end
        sharedValue39.bOn = function()
            return sharedValue39.bget("breakOn") == true
        end
        sharedValue39.bset = function(argument)
            sharedValue39.bPend = sharedValue39.bPend or {}
            for key, entry in pairs(argument) do
                config[key] = entry
                sharedValue39.bPend[key] = entry
            end
            pcall(helper16)
            if sharedValue39.bFlushing then
                return
            end
            sharedValue39.bFlushing = true
            task.delay(0.5, function()
                sharedValue39.bFlushing = false
                local bPend = sharedValue39.bPend
                sharedValue39.bPend = nil
                if not bPend then
                    return
                end
                pcall(function()
                    if context.AF then
                        if context.AF.loadReal then
                            if context.AF.partyOf then
                                if not context.AF.save then
                                    return
                                end
                            else
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                    context.AF.loadReal(true)
                    local value = context.AF.partyOf(localPlayer.Name, context.AF.doc)
                    if type(value) ~= "table" then
                        return
                    end
                    for key2, entry2 in pairs(bPend) do
                        value[key2] = entry2
                    end
                    context.AF.save()
                end)
            end)
        end
        sharedValue39.brkFile = function()
            local value, value2 =
                context.PATH and context.PATH.data or "HarvardLabs/data", sharedValue39.bParty()
            if value2 then
                return value .. "/partybreak_" .. tostring(value2.id) .. ".json", true
            end
            return value .. "/modbreak_" .. tostring(localPlayer.UserId) .. ".json", false
        end
        sharedValue39.brkRead = function(argument)
            local brkF, value = sharedValue39.brkFile()
            local brkAt = os.clock()
            if
                argument
                or not sharedValue39.brk
                or sharedValue39.brkF ~= brkF
                or brkAt - (sharedValue39.brkAt or -math.huge) >= 1
            then
                local value2 = sharedValue39.canFiles and context.readJson and context.readJson(brkF)
                sharedValue39.brk = type(value2) == "table" and value2 or {}
                sharedValue39.brkF = brkF
                sharedValue39.brkAt = brkAt
            end
            return sharedValue39.brk, value
        end
        sharedValue39.brkSave = function()
            if sharedValue39.canFiles then
                if sharedValue39.brk then
                    if not sharedValue39.brkF then
                        return
                    end
                else
                    return
                end
            else
                return
            end
            pcall(context.ensureFolders)
            pcall(function()
                writefile(sharedValue39.brkF, sharedValue38:JSONEncode(sharedValue39.brk))
            end)
            sharedValue39.brkAt = os.clock()
        end
        sharedValue39.rollFarm = function()
            if tonumber(config.breakFarmSecs) then
                return math.floor(tonumber(config.breakFarmSecs))
            end
            local value = math.clamp(math.floor(tonumber(sharedValue39.bget("breakFarmMin")) or 3), 1, 24)
            local value2 =
                math.clamp(math.floor(tonumber(sharedValue39.bget("breakFarmMax")) or 5), value, 24)
            return math.random(value * 3600, value2 * 3600)
        end
        sharedValue39.rollRest = function()
            if tonumber(config.breakRestSecs) then
                return math.floor(tonumber(config.breakRestSecs))
            end
            local value = math.clamp(math.floor(tonumber(sharedValue39.bget("breakRestMin")) or 20), 1, 360)
            local value2 =
                math.clamp(math.floor(tonumber(sharedValue39.bget("breakRestMax")) or 40), value, 360)
            return math.random(value * 60, value2 * 60)
        end
        sharedValue39.newPhase = function(argument, start)
            local seen = os.time()
            argument.n, argument.start, argument.len, argument.restLen =
                (tonumber(argument.n) or 0) + 1, start, sharedValue39.rollFarm(), sharedValue39.rollRest()
            argument.restUntil = nil
            argument.restAt = nil
            argument.seen = seen
            sharedValue39.brkSave()
        end
        sharedValue39.brkState = function()
            local value, value2 = sharedValue39.brkRead()
            local seen, value3 = os.time(), value
            if value2 then
                local value4 = tonumber(config.whSessionGap) or 21600
                local value5 = tonumber(value3.restUntil)
                local function helper6()
                    return value5 and seen >= value5
                        or (
                            if value5
                                then not value5
                                else seen - (tonumber(value.seen) or 0) > value4 or not tonumber(
                                    value.start
                                ) or not tonumber(value.len)
                        )
                end
                if helper6() then
                    value = sharedValue39.brkRead(true)
                    value5 = tonumber(value.restUntil)
                    if helper6() then
                        local value6 = seen - (tonumber(value.seen) or 0) > value4
                        if value5 and seen >= value5 then
                            sharedValue39.newPhase(value, value6 and seen or value5)
                        else
                            sharedValue39.newPhase(
                                value,
                                math.min(
                                    math.floor(tonumber(context.WH and context.WH.sessionStart) or seen),
                                    seen
                                )
                            )
                        end
                    end
                else
                    if seen - (tonumber(value3.seen) or 0) >= 60 then
                        value = sharedValue39.brkRead(true)
                        value.seen = seen
                        sharedValue39.brkSave()
                    else
                        value = value3
                    end
                end
                return value
            end
            local value7, start =
                math.floor(tonumber(context.WH and context.WH.sessionStart) or seen),
                tonumber(value3.restUntil)
            if start and seen >= start then
                value3.start, value3.len = start, sharedValue39.rollFarm()
                value3.restUntil = nil
                value3.session = value7
                sharedValue39.brkSave()
            elseif
                if start
                    then not start
                    else tonumber(value3.session) ~= value7 or not tonumber(value3.start) or not tonumber(
                        value3.len
                    )
            then
                value3.session, value3.start, value3.len = value7, value7, sharedValue39.rollFarm()
                sharedValue39.brkSave()
            end
            return value3
        end
        sharedValue39.hm = function(argument)
            argument = math.max(0, math.floor(tonumber(argument) or 0))
            if argument >= 3600 then
                local value, value2 = math.floor(argument / 3600), math.floor(argument / 60) % 60
                return ("%dh %02dm"):format(value, value2)
            end
            local value3 = math.floor(argument / 60)
            return ("%dm %02ds"):format(value3, argument % 60)
        end
        sharedValue39.onBreak = function()
            return sharedValue39.hold ~= nil and sharedValue39.hold.farmBreak == true
        end
        sharedValue39.breakAt = function()
            if sharedValue39.onBreak() then
                if sharedValue39.hold.test then
                    return nil
                elseif sharedValue39.left() <= 0 then
                    return nil
                end
            else
                return nil
            end
            return tonumber(sharedValue39.hold.at)
        end
        sharedValue39.breakPresence = function(resting, restBreak)
            pcall(function()
                local value = "HarvardLabs/data/af_" .. string.lower(localPlayer.Name) .. ".json"
                local value2 = sharedValue38:JSONDecode(readfile(value))
                if type(value2) == "table" then
                    value2.resting, value2.restBreak, value2.dropPending, value2.at =
                        resting, restBreak, nil, os.time()
                    writefile(value, sharedValue38:JSONEncode(value2))
                end
            end)
        end
        sharedValue39.breakTick = function(argument)
            local value, value2 = sharedValue39.brkRead()
            local holdUntil = os.time()
            if sharedValue39.onBreak() then
                if value2 then
                    if not sharedValue39.hold.test then
                        local holdUntil2, value3, value4 =
                            tonumber(value.restUntil),
                            tonumber(sharedValue39.hold.holdUntil) or 0,
                            (tonumber(value.n) or 0) == (tonumber(sharedValue39.hold.bn) or -1)
                        if
                            value4
                            and holdUntil2
                            and holdUntil2 > holdUntil
                            and math.abs(holdUntil2 - value3) >= 2
                        then
                            sharedValue39.hold.holdUntil = holdUntil2
                            sharedValue39.save()
                            sharedValue39.breakPresence(holdUntil2, sharedValue39.breakAt())
                        elseif value4 then
                        elseif holdUntil2 then
                        elseif value3 > holdUntil then
                            sharedValue39.hold.holdUntil = holdUntil
                            sharedValue39.save()
                        end
                    end
                end
                if sharedValue39.left() <= 0 then
                    if sharedValue39.halted then
                    elseif argument then
                        sharedValue39.breakOver()
                    end
                end
                return
            end
            local pendingBreak = sharedValue39.pendingBreak
            if pendingBreak then
                if not pendingBreak.test then
                    if value2 then
                        local value5, value6 = tonumber(value.restUntil), sharedValue39.bOn()
                        if
                            if value6
                                then (tonumber(value.n) or 0) ~= (tonumber(pendingBreak.bn) or -1)
                                    and not (value5 and value5 > holdUntil)
                                else not value6
                        then
                            sharedValue39.pendingBreak = nil
                            context.log("ModDetect", "the party's break was called off - farming on")
                            pendingBreak = nil
                        end
                    end
                end
            end
            if not pendingBreak then
                if not sharedValue39.hold then
                    if not sharedValue39.pendingDrop then
                        local value7 = value2 and tonumber(value.testAt)
                        if value7 and value7 > (sharedValue39.testSeen or 0) and holdUntil - value7 < 600 then
                            sharedValue39.testSeen = value7
                            sharedValue39.pendingBreak = {
                                at = os.clock(),
                                restSecs = tonumber(value.testSecs) or 30,
                                test = true,
                                testAt = value7,
                            }
                            context.log(
                                "ModDetect",
                                ("test rest for the party (%ds) %s"):format(
                                    sharedValue39.pendingBreak.restSecs,
                                    argument and "after this run" or "now"
                                )
                            )
                            if argument then
                                if context.notify then
                                    context.notify(
                                        "info",
                                        "Test rest after this run",
                                        ("A %ds test rest for the party once this run is over."):format(
                                            sharedValue39.pendingBreak.restSecs
                                        ),
                                        8
                                    )
                                end
                            end
                        elseif sharedValue39.bOn() then
                            local value8 = sharedValue39.brkState()
                            local value9, joinUntil =
                                holdUntil - (tonumber(value8.start) or holdUntil),
                                value2 and tonumber(value8.restUntil)
                            if joinUntil and joinUntil > holdUntil + 5 then
                                sharedValue39.pendingBreak =
                                    { at = os.clock(), bn = value8.n, joinUntil = joinUntil }
                                context.log(
                                    "ModDetect",
                                    ("the party is taking its break - resting with it until %s %s"):format(
                                        os.date("%H:%M:%S", joinUntil),
                                        argument and "after this run" or "now"
                                    )
                                )
                                if argument then
                                    if context.notify then
                                        context.notify(
                                            "info",
                                            "Rest after this run",
                                            ("The party is taking its break - resting with it until %s once this run is over."):format(
                                                os.date("%H:%M", joinUntil)
                                            ),
                                            8
                                        )
                                    end
                                end
                            elseif value9 >= (tonumber(value8.len) or math.huge) then
                                sharedValue39.pendingBreak = {
                                    at = os.clock(),
                                    bn = value8.n,
                                    restSecs = tonumber(value8.restLen) or sharedValue39.rollRest(),
                                }
                                context.log(
                                    "ModDetect",
                                    ("%sfarmed %s - a %s rest after this run"):format(
                                        value2 and "the party " or "",
                                        sharedValue39.hm(value9),
                                        sharedValue39.hm(sharedValue39.pendingBreak.restSecs)
                                    )
                                )
                                if argument then
                                    if context.notify then
                                        context.notify(
                                            "info",
                                            "Rest after this run",
                                            ("%s %s - a %s rest once this run is over."):format(
                                                value2 and "The party farmed" or "Farmed",
                                                sharedValue39.hm(value9),
                                                sharedValue39.hm(sharedValue39.pendingBreak.restSecs)
                                            ),
                                            8
                                        )
                                    end
                                end
                            end
                        end
                    end
                end
            end
            pendingBreak = sharedValue39.pendingBreak
            if not pendingBreak then
                return
            end
            if
                (if argument then context.runFailed ~= nil and context.runFailed() == true else not argument)
                or context.LB ~= nil and context.LB.runOverAt ~= nil
            then
                sharedValue39.finishBreak()
            elseif os.clock() - (pendingBreak.at or 0) > (tonumber(config.breakPendingMax) or 1800) then
                sharedValue39.finishBreak()
            end
        end
        sharedValue39.finishBreak = function()
            local pendingBreak = sharedValue39.pendingBreak
            if pendingBreak then
                if sharedValue39.halted then
                    return
                end
            else
                return
            end
            sharedValue39.pendingBreak = nil
            local restAt, value, value2 = os.time(), sharedValue39.brkRead(true)
            local value3, value4, value5 = false, tonumber(value.start) or restAt
            if value2 then
                if pendingBreak.test then
                    local value6 = tonumber(value.testUntil)
                    if
                        tonumber(value.testFor) == tonumber(pendingBreak.testAt)
                        and value6
                        and value6 > restAt
                    then
                        value5, value3 = value6, true
                    else
                        value5 = restAt + (tonumber(pendingBreak.restSecs) or 30)
                        value.testUntil, value.testFor = value5, pendingBreak.testAt
                        sharedValue39.brkSave()
                    end
                else
                    local value7 = tonumber(value.restUntil)
                    if value7 and value7 > restAt then
                        value5, value3 = value7, true
                    else
                        value5 = restAt
                            + (
                                tonumber(value.restLen)
                                or tonumber(pendingBreak.restSecs)
                                or sharedValue39.rollRest()
                            )
                        value.restUntil = value5
                        value.restAt = restAt
                        sharedValue39.brkSave()
                    end
                end
            else
                local value8 = sharedValue39.brkState()
                value4, value5 =
                    tonumber(value8.start) or restAt,
                    tonumber(pendingBreak.joinUntil)
                        or restAt + (tonumber(pendingBreak.restSecs) or sharedValue39.rollRest())
                value8.restUntil = value5
                sharedValue39.brkSave()
            end
            local value9, value10 = restAt - value4, workspaceService:FindFirstChild("dungeonName")
            sharedValue39.hold = {
                holdUntil = value5,
                at = restAt,
                who = pendingBreak.test and "Test rest" or "Break",
                reason = "drop",
                farmBreak = true,
                test = pendingBreak.test or nil,
                job = game.JobId,
                dungeon = value10 and tostring(value10.Value) or "",
                queue = sharedValue39.queueText(),
                bn = value2 and not pendingBreak.test and value.n or nil,
            }
            sharedValue39.save()
            value10, value = sharedValue39.breakPresence, pendingBreak.test
            value10(value5, (if value then not value else restAt) or nil)
            sharedValue39.post = context.WH
                    and context.WH.breakRest
                    and context.WH.breakRest(
                        value9,
                        value5,
                        sharedValue39.hold.queue,
                        pendingBreak.test == true,
                        value3
                    )
                or nil
            sharedValue39.postAt = os.clock()
            if sharedValue39.inDungeon() then
                sharedValue39.halted = true
                sharedValue39.stopAll()
                sharedValue39.goAt = os.clock() + (config.modFinishWait or 3)
            end
            context.log(
                "ModDetect",
                ("%s - resting until %s, then back to the party"):format(
                    pendingBreak.test and "test rest" or "break",
                    os.date("%H:%M:%S", value5)
                )
            )
            if context.notify then
                context.notify(
                    "info",
                    pendingBreak.test and "Test rest" or "Taking a break",
                    ("Resting until %s, then back to the party."):format(os.date("%H:%M:%S", value5)),
                    8
                )
            end
        end
        sharedValue39.breakOver = function()
            sharedValue39.restEndedAt = os.time()
            sharedValue39.clear()
            sharedValue39.brkState()
            context.log(
                "ModDetect",
                "the break is over - back to the party (joining its run if it is in one)"
            )
            if context.notify then
                context.notify("info", "Break over", "Back to farming - rejoining the party.")
            end
        end
        sharedValue39.endBreak = function(argument)
            if not (sharedValue39.onBreak()) then
                if not (sharedValue39.pendingBreak ~= nil) then
                    return false
                end
            end
            local value = sharedValue39.onBreak() and sharedValue39.hold.test == true
                or sharedValue39.pendingBreak ~= nil and sharedValue39.pendingBreak.test == true
            sharedValue39.pendingBreak = nil
            if sharedValue39.onBreak() then
                sharedValue39.restEndedAt = os.time()
                sharedValue39.clear()
                sharedValue39.breakPresence(nil, nil)
                if sharedValue39.halted then
                    sharedValue39.halted = false
                    runtimeState.modHalt = false
                    if sharedValue39.inDungeon() then
                        runtimeState.farmEnabled = true
                    end
                    pcall(context.setLoopButtonState)
                end
                if context.LB then
                    if context.LB.place == "Lobby" then
                        if context.queueNow then
                            pcall(context.queueNow, "break ended")
                        end
                    end
                end
            end
            local value2, value3 = sharedValue39.brkRead(true)
            if value3 then
                if not value then
                    sharedValue39.newPhase(value2, os.time())
                end
            else
                value2.start, value2.len = os.time(), sharedValue39.rollFarm()
                value2.restUntil = nil
                sharedValue39.brkSave()
            end
            value2 = sharedValue39.brkRead()
            context.log(
                "ModDetect",
                ("the %sbreak was ended (%s) - farming again, next rest in %s"):format(
                    value3 and "party's " or "",
                    tostring(argument or "by hand"),
                    sharedValue39.hm(value2.len)
                )
            )
            if context.notify then
                context.notify(
                    "info",
                    "Break ended",
                    ("Farming again - the next rest in %s."):format(sharedValue39.hm(value2.len))
                )
            end
            return true
        end
        sharedValue39.applyPhase = function()
            local value, value2 = sharedValue39.brkRead(true)
            if sharedValue39.onBreak() then
                local value3 = os.time() + sharedValue39.rollRest()
                sharedValue39.hold.holdUntil = value3
                sharedValue39.save()
                if value2 then
                    if not sharedValue39.hold.test then
                        value.restUntil = value3
                        sharedValue39.brkSave()
                    end
                else
                    sharedValue39.brkState().restUntil = value3
                    sharedValue39.brkSave()
                end
                sharedValue39.breakPresence(value3, sharedValue39.breakAt())
                context.log(
                    "ModDetect",
                    "rest restarted from the sliders - until " .. os.date("%H:%M:%S", value3)
                )
                if context.notify then
                    context.notify(
                        "info",
                        "Rest restarted",
                        ("Resting until %s."):format(os.date("%H:%M:%S", value3))
                    )
                end
                return
            end
            sharedValue39.pendingBreak = nil
            if value2 then
                sharedValue39.newPhase(value, os.time())
            else
                local value4 = sharedValue39.brkState()
                value4.start, value4.len = os.time(), sharedValue39.rollFarm()
                value4.restUntil = nil
                sharedValue39.brkSave()
            end
            value = sharedValue39.brkRead()
            context.log(
                "ModDetect",
                "farm timer restarted from the sliders - next rest in " .. sharedValue39.hm(value.len)
            )
            if context.notify then
                context.notify(
                    "info",
                    "Farm timer restarted",
                    ("The next rest in %s%s."):format(
                        sharedValue39.hm(value.len),
                        sharedValue39.bOn() and "" or " (Take breaks is off)"
                    )
                )
            end
        end
        sharedValue39.testRest = function()
            if sharedValue39.onBreak() then
                return false
            elseif sharedValue39.halted then
                return false
            end
            local value, value2, value3 =
                math.floor(tonumber(config.breakTestSecs) or 30), sharedValue39.brkRead(true)
            local value4 = sharedValue39.inDungeon()
            if value3 then
                value2.testAt = os.time()
                value2.testSecs = value
                value2.testUntil = nil
                value2.testFor = nil
                sharedValue39.brkSave()
                context.log("ModDetect", ("test rest (%ds) for the whole party"):format(value))
                if context.notify then
                    context.notify(
                        "info",
                        "Test rest for the party",
                        ("A %ds rest for every account of the party, each %s, then back to farming."):format(
                            value,
                            value4 and "once its run is over" or "at once in the lobby"
                        )
                    )
                end
                return true
            end
            sharedValue39.pendingBreak = { at = os.clock(), restSecs = value, test = true }
            context.log(
                "ModDetect",
                ("test rest (%ds) %s"):format(value, value4 and "after this run" or "now")
            )
            if context.notify then
                context.notify(
                    "info",
                    value4 and "Test rest after this run" or "Test rest",
                    ("A %ds rest%s, then back to the party."):format(
                        value,
                        value4 and " once this run is over" or ""
                    )
                )
            end
            return true
        end
        sharedValue39.breakText = function()
            if sharedValue39.onBreak() then
                local value = sharedValue39.hold.test and "Test rest" or "Resting"
                if sharedValue39.halted then
                    local value2 = argumentHelpers[108](os.date("%H:%M:%S", sharedValue39.hold.holdUntil))
                    return ("%s - to the lobby, back at %s"):format(
                        value,
                        argumentHelpers:unpackValues(value2)
                    )
                end
                local value3, value4 =
                    os.date("%H:%M:%S", sharedValue39.hold.holdUntil),
                    argumentHelpers[108](sharedValue39.hm(sharedValue39.left()))
                return ("%s - back at %s (%s left)"):format(
                    value,
                    value3,
                    argumentHelpers:unpackValues(value4)
                )
            end
            local pendingBreak = sharedValue39.pendingBreak
            if pendingBreak then
                if pendingBreak.joinUntil then
                    local value5 = argumentHelpers[108](os.date("%H:%M", pendingBreak.joinUntil))
                    return ("Resting with the party after this run, until %s"):format(
                        argumentHelpers:unpackValues(value5)
                    )
                end
                local value6, value7 =
                    pendingBreak.test and "Test rest" or "Rest",
                    argumentHelpers[108](sharedValue39.hm(pendingBreak.restSecs))
                return ("%s after this run - %s"):format(value6, argumentHelpers:unpackValues(value7))
            end
            if not (sharedValue39.bOn()) then
                return "Off - it farms without breaks"
            end
            local h, value8 = sharedValue39.brkRead()
            local value9, value10 = sharedValue39.brkState(), value8 and "The party: farming" or "Farming"
            local value11, value12, value13 =
                sharedValue39.hm(os.time() - (tonumber(value9.start) or os.time())),
                sharedValue39.hm(value9.len),
                argumentHelpers[108](
                    os.date("%H:%M", (tonumber(value9.start) or os.time()) + (tonumber(value9.len) or 0))
                )
            return ("%s %s of %s - rest at about %s"):format(
                value10,
                value11,
                value12,
                argumentHelpers:unpackValues(value13)
            )
        end
        sharedValue39.onLoot = function(argument)
            if type(argument) ~= "table" then
                return
            elseif type(argument.items) ~= "table" then
                return
            end
            local iteratePairs, items, value, value2, value3 = pairs, argument.items, 0
            for key, item in iteratePairs(items) do
                if type(item) == "table" and item.template ~= nil then
                    local value4 = item.itemName
                    if value4 == nil then
                        pcall(function()
                            value4 = item.template.Name
                        end)
                    end
                    if sharedValue39.bigDrop(value4, item.rarity) then
                        key = sharedValue39.RANK[tostring(item.rarity):lower()] or 0
                        if key > value then
                            value3 = value4
                            value, value2 = key, item
                        end
                    end
                end
            end
            if value2 then
                sharedValue39.dropRest(tostring(value3), tostring(value2.rarity):lower())
            end
        end
        sharedValue39.hookLoot = function()
            if sharedValue39.lootConn then
                return
            end
            local remotes = getService("ReplicatedStorage"):FindFirstChild("remotes")
            local value = remotes and (remotes:FindFirstChild("cloneRewardGui"))
            if value then
                if not (value:IsA("RemoteEvent")) then
                    return
                end
            else
                return
            end
            sharedValue39.lootConn = value.OnClientEvent:Connect(function(argument)
                pcall(sharedValue39.onLoot, argument)
            end)
            sliderConnections[#sliderConnections + 1] = sharedValue39.lootConn
        end
        pcall(sharedValue39.hookLoot)
        helper18 = sharedValue39.canFiles and context.readJson and context.readJson(sharedValue39.file())
        if type(helper18) == "table" then
            if (tonumber(helper18.holdUntil) or 0) > os.time() then
                sharedValue39.hold = helper18
            end
        end
        if type(helper18) == "table" then
            if tonumber(helper18.restEndedAt) then
                sharedValue39.restEndedAt = tonumber(helper18.restEndedAt)
            end
        end
        if sharedValue39.canFiles then
            band2, green = pcall(function()
                local value = argumentHelpers[108](readfile(sharedValue39.pendFile()))
                return sharedValue38:JSONDecode(argumentHelpers:unpackValues(value))
            end)
            if band2 then
                if type(green) == "table" then
                    if green.name then
                        if config.modDetect == true then
                            if not sharedValue39.hold then
                                if
                                    os.time() - (tonumber(green.at) or 0)
                                    < (tonumber(config.modPendingMax) or 900)
                                then
                                    sharedValue39.pendingDrop =
                                        { name = green.name, rarity = green.rarity, at = os.clock() }
                                    if green.job ~= game.JobId then
                                        context.log(
                                            "ModDetect",
                                            ("%s (%s) dropped in an earlier run that this account left before its rest - resting now"):format(
                                                tostring(green.name),
                                                tostring(green.rarity)
                                            )
                                        )
                                        task.defer(function()
                                            pcall(sharedValue39.finishDrop)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        pcall(sharedValue39.toRest)
        if
            sharedValue39.hold
            and (config.modDetect == true or sharedValue39.hold.stranger == true or sharedValue39.hold.farmBreak == true)
            and (
                sharedValue39.hold.job == game.JobId
                or sharedValue39.hold.reason == "drop" and sharedValue39.left() > 0
            )
        then
            if sharedValue39.inDungeon() then
                sharedValue39.halted = true
                sharedValue39.stopAll()
                sharedValue39.lastTry = os.clock() - 9
            end
        end
        sliderConnections[#sliderConnections + 1] = sharedValue5.PlayerAdded:Connect(function(argument)
            task.delay(0.5, function()
                pcall(sharedValue39.detect, argument)
            end)
        end)
        task.spawn(function()
            while not runtimeState.destroyed do
                pcall(function()
                    if not sharedValue39.lootConn then
                        pcall(sharedValue39.hookLoot)
                    end
                    local value = sharedValue39.inDungeon()
                    if value then
                        pcall(sharedValue39.lateJoinGuard)
                    end
                    if value then
                        if config.modDetect == true then
                            pcall(sharedValue39.hookJoins)
                        end
                    end
                    if value then
                        if sharedValue39.restEndedAt then
                            sharedValue39.restEndedAt = nil
                            sharedValue39.save()
                        end
                    end
                    if config.modDetect == true and not sharedValue39.halted and value then
                        local value2 = sharedValue39.names()
                        for index, entry in ipairs(sharedValue5:GetPlayers()) do
                            if not (sharedValue39.allowed(entry, value2)) then
                                sharedValue39.detect(entry)
                                break
                            end
                        end
                    end
                    if sharedValue39.halted then
                    elseif value then
                        if not runtimeState.destroyed then
                            local value3 = sharedValue39.readFlag()
                            if value3 then
                                if value3.job == game.JobId then
                                    if os.time() - (tonumber(value3.at) or 0) < 3600 then
                                        sharedValue39.still(
                                            value3.who or value3.by,
                                            false,
                                            value3.how,
                                            value3.kick == true
                                        )
                                    end
                                end
                            end
                        end
                    end
                    if sharedValue39.pendingDrop then
                        if not sharedValue39.halted then
                            if
                                context.runFailed ~= nil and context.runFailed() == true
                                or context.LB ~= nil and context.LB.runOverAt ~= nil
                            then
                                sharedValue39.finishDrop()
                            elseif value then
                                if
                                    os.clock() - (sharedValue39.pendingDrop.at or 0)
                                    > (config.modPendingMax or 900)
                                then
                                    sharedValue39.finishDrop()
                                end
                            else
                                sharedValue39.finishDrop()
                            end
                        end
                    end
                    if not sharedValue39.halted then
                        if not runtimeState.destroyed then
                            pcall(sharedValue39.breakTick, value)
                        end
                    end
                    local value4 = sharedValue39.halted
                    if
                        (if value4 then not value4 else value)
                        and sharedValue39.hold
                        and (
                            config.modDetect == true
                            or sharedValue39.hold.stranger == true
                            or sharedValue39.hold.farmBreak == true
                        )
                    then
                        if sharedValue39.hold.reason == "drop" then
                            if sharedValue39.left() > 0 then
                                sharedValue39.halted = true
                                sharedValue39.stopAll()
                                sharedValue39.post, sharedValue39.goAt = nil, os.clock()
                                context.log(
                                    "ModDetect",
                                    "resting after a big drop but in a run (the party's replay took it along) - back to the lobby"
                                )
                                if context.notify then
                                    context.notify(
                                        "warning",
                                        "Resting",
                                        "Taken into a run while resting - back to the lobby.",
                                        6
                                    )
                                end
                            end
                        end
                    end
                    if sharedValue39.halted then
                        runtimeState.farmEnabled = false
                        if sharedValue39.hold and sharedValue39.hold.reason == "user" then
                            local value5, post =
                                context.runComplete ~= nil and context.runComplete() == true
                                    or os.time() >= (tonumber(sharedValue39.hold.holdUntil) or 0),
                                sharedValue39.post
                            value4 = (if post then sharedValue39.post.over else not post)
                                or os.clock() - (sharedValue39.postAt or 0) > (config.modPostWait or 8)
                            if config.modKick == true or sharedValue39.hold.kick == true then
                                if
                                    value4
                                    or os.clock() - (sharedValue39.postAt or 0)
                                        > (config.modKickPostWait or 3)
                                then
                                    sharedValue39.kick(
                                        ("a player not on the whitelist joined the run (%s)"):format(
                                            tostring(sharedValue39.hold.who)
                                        )
                                    )
                                end
                            elseif value then
                                if value5 then
                                    if value4 then
                                        if os.clock() - sharedValue39.lastTry > 10 then
                                            sharedValue39.goLobby()
                                        end
                                    end
                                end
                            end
                        else
                            local post2 = sharedValue39.post
                            local value6 = (if post2 then sharedValue39.post.over else not post2)
                                or os.clock() - (sharedValue39.postAt or 0) > (config.modPostWait or 8)
                            if value then
                                if value6 then
                                    if os.clock() >= (sharedValue39.goAt or 0) then
                                        if os.clock() - sharedValue39.lastTry > 10 then
                                            sharedValue39.goLobby()
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if context.refreshModPanel then
                        value4 = 0
                        for entry2 in pairs(sharedValue39.names()) do
                            value4 += 1
                        end
                        local value7
                        if config.modDetect == true and sharedValue39.onBreak() then
                            value7 = sharedValue39.halted and "Status: on a break - going back to the lobby"
                                or ("Status: on a break, requeueing in %s (%s)"):format(
                                    sharedValue39.fmt(sharedValue39.left()),
                                    os.date("%H:%M", sharedValue39.hold.holdUntil)
                                )
                        else
                            if config.modDetect ~= true then
                                value7 = "Status: off"
                            else
                                if sharedValue39.pendingDrop and not sharedValue39.halted then
                                    value7 = ("Status: %s (%s) dropped - resting after this run"):format(
                                        tostring(sharedValue39.pendingDrop.name),
                                        tostring(sharedValue39.pendingDrop.rarity)
                                    )
                                else
                                    if
                                        sharedValue39.halted
                                        and sharedValue39.hold
                                        and sharedValue39.hold.reason == "drop"
                                    then
                                        local value8 =
                                            math.max(0, math.ceil((sharedValue39.goAt or 0) - os.clock()))
                                        value7 = (
                                            value8 > 0
                                                and ("Status: flagged - to the lobby in %ds"):format(value8)
                                            or "Status: flagged - going back to the lobby"
                                        )
                                            .. (sharedValue39.why and " (" .. sharedValue39.why .. ")" or "")
                                    else
                                        value7 = if sharedValue39.halted
                                                and sharedValue39.hold
                                                and sharedValue39.hold.reason == "user"
                                            then "Status: flagged - standing still until the run ends"
                                                .. (
                                                    sharedValue39.why and " (" .. sharedValue39.why .. ")"
                                                    or ""
                                                )
                                            else if sharedValue39.halted
                                                then "Status: flagged - going back to the lobby"
                                                else if sharedValue39.hold
                                                        and sharedValue39.left() > 0
                                                    then ("Status: flagged, requeueing in %s (%s)"):format(
                                                        sharedValue39.fmt(sharedValue39.left()),
                                                        os.date("%H:%M", sharedValue39.hold.holdUntil)
                                                    )
                                                    else ("Status: watching %s (%d friend%s on the whitelist)"):format(
                                                        value and "this dungeon" or "dungeons",
                                                        value4,
                                                        value4 == 1 and "" or "s"
                                                    )
                                    end
                                end
                            end
                        end
                        context.refreshModPanel(value7)
                    end
                    if context.refreshBreakPanel then
                        context.refreshBreakPanel("Status: " .. sharedValue39.breakText())
                    end
                end)
                task.wait(1)
            end
        end)
    end
    do
        local zone = {}
        zone.big = config.mapViewOpen == true
        zone.zoomS = tonumber(config.mapZoomS) or 1
        zone.zoomB = tonumber(config.mapZoomB) or 1
        zone.lastAt = 0
        zone.panX = 0
        zone.panZ = 0
        zone.statsAt = 0
        zone.frames = 0
        zone.fpsAt = os.clock()
        zone.fps = 0
        context.MM = zone
        if config.renderOff == true then
            if not zone.big then
                zone.big = true
                zone.ultOpened = true
            end
        end
        zone.blank = function()
            return zone.big == true and config.mapBlankScreen == true
        end
        local sharedValue40, theme2 = config.minimapSize or 220, {}
        local MP = theme.palette
        theme2.Bg = MP.DeepForest
        theme2.Panel = MP.Moss
        theme2.Raised = MP.Wood
        theme2.Stroke = MP.Bark
        theme2.StrokeSoft = MP.Bark
        theme2.Text = MP.Parchment
        theme2.Muted = MP.Muted
        theme2.Faint = MP.Muted
        theme2.Green = MP.LeafLight
        theme2.Red = theme.danger
        theme2.Purple = MP.Hot
        theme2.Pink = MP.Fern
        theme2.Blue = MP.Fern
        theme2.White = MP.Parchment
        zone.theme = theme2
        theme2.Orb = MP.LeafLight
        local sharedValue41 = {}
        pcall(function()
            sharedValue41.Regular, sharedValue41.Medium =
                Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular),
                Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium)
            sharedValue41.Semi, sharedValue41.Bold =
                Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
                Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
            sharedValue41.Mono = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium)
        end)
        local sharedValue42, sharedValue43, sharedValue44, sharedValue45 = 360, 16, 16, 64
        local sharedValue46 = getService("TweenService")
        local function helper154(argument, argument2, argument3)
            pcall(function()
                sharedValue46
                    :Create(
                        argument,
                        TweenInfo.new(argument2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                        argument3
                    )
                    :Play()
            end)
        end
        local function helper155(argument, argument2, parent)
            local value = Instance.new(argument)
            if value:IsA("GuiObject") then
                value.BorderSizePixel = 0
            end
            for key, entry in pairs(argument2) do
                value[key] = entry
            end
            if parent then
                value.Parent = parent
            end
            return value
        end
        local function helper156(argument, argument2)
            return helper155("UICorner", { CornerRadius = UDim.new(0, argument2) }, argument)
        end
        local function helper157(argument, argument2, argument3)
            return helper155("UIStroke", {
                Color = argument2 or theme2.Stroke,
                Transparency = argument3 or 0,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            }, argument)
        end
        local function helper158(argument, argument2, argument3, argument4, argument5)
            argument3, argument4 = argument3 or argument2, argument4 or argument2
            argument5 = argument5 or argument3
            return helper155("UIPadding", {
                PaddingTop = UDim.new(0, argument2),
                PaddingRight = UDim.new(0, argument3),
                PaddingBottom = UDim.new(0, argument4),
                PaddingLeft = UDim.new(0, argument5),
            }, argument)
        end
        local function helper159(argument, argument2, argument3, argument4)
            return helper155("UIListLayout", {
                FillDirection = argument2 and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
                Padding = UDim.new(0, argument3),
                HorizontalAlignment = argument4 or Enum.HorizontalAlignment.Left,
                VerticalAlignment = argument2 and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, argument)
        end
        local function helper160(parent, argument)
            local value = helper155("TextLabel", {
                BackgroundTransparency = 1,
                TextColor3 = theme2.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                AutomaticSize = Enum.AutomaticSize.XY,
                Size = UDim2.fromOffset(0, 0),
            }, nil)
            local fontFace = argument.FontFace or sharedValue41.Medium
            for key, entry in pairs(argument) do
                if key ~= "FontFace" then
                    value[key] = entry
                end
            end
            if fontFace then
                pcall(function()
                    value.FontFace = fontFace
                end)
            end
            value.Parent = parent
            return value
        end
        local function helper161(argument, backgroundColor3, argument2, argument3)
            local value = helper155("Frame", {
                Size = UDim2.fromOffset(argument2, argument2),
                BackgroundColor3 = backgroundColor3,
                LayoutOrder = argument3 or 1,
            }, argument)
            helper156(value, math.floor(argument2 / 2))
            return value
        end
        local function helper162(argument, rotation)
            local new = NumberSequenceKeypoint.new
            return helper155("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, MP.Wood),
                    ColorSequenceKeypoint.new(0.45, MP.Moss),
                    ColorSequenceKeypoint.new(0.7, MP.Bark),
                    ColorSequenceKeypoint.new(1, MP.Wood),
                }),
                Rotation = rotation,
                Transparency = NumberSequence.new({ new(0, 0.05), new(0.55, 0.28), new(1, 1) }),
            }, argument)
        end
        local hlMinimap = Instance.new("Frame")
        hlMinimap.Name = "HLMinimap"
        hlMinimap.BackgroundTransparency = 1
        hlMinimap.BorderSizePixel = 0
        hlMinimap.ZIndex = 1
        hlMinimap.Parent = runtimeState.scriptGui
        local backdrop = Instance.new("TextButton")
        backdrop.Name = "Backdrop"
        backdrop.Text = ""
        backdrop.AutoButtonColor = false
        backdrop.BorderSizePixel = 0
        backdrop.BackgroundColor3, backdrop.BackgroundTransparency, backdrop.Size =
            theme2.Bg, 0, UDim2.fromScale(1, 1)
        backdrop.ZIndex = 1
        backdrop.Visible = false
        backdrop.Parent = hlMinimap
        local sharedValue47 = {}
        for index23 = 1, 4, 1 do
            band2 = Instance.new("TextButton")
            band2.Name = "Band"
            band2.Text = ""
            band2.AutoButtonColor = false
            band2.BorderSizePixel = 0
            band2.BackgroundColor3 = theme2.Bg
            band2.BackgroundTransparency = 0
            band2.ZIndex = 1
            band2.Visible = false
            band2.Parent = hlMinimap
            sharedValue47[index23] = band2
        end
        local view = Instance.new("Frame")
        view.Name, view.BackgroundColor3 = "View", theme2.Panel
        view.BorderSizePixel = 0
        view.ClipsDescendants = true
        view.ZIndex = 2
        view.Parent = hlMinimap
        local corner = Instance.new("UICorner")
        corner.Parent = view
        local stroke2 = Instance.new("UIStroke")
        stroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke2.Parent = view
        stroke2.Color = MP.Bark
        stroke2.Thickness = 3
        local strokeInner = Instance.new("UIStroke")
        strokeInner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        strokeInner.Color = MP.LeafLight
        strokeInner.Thickness = 1
        strokeInner.Transparency = 0.55
        strokeInner.Parent = view
        local mapMoss = Instance.new("Frame")
        mapMoss.Name = "Signal"
        mapMoss.BackgroundColor3 = MP.Fern
        mapMoss.BackgroundTransparency = 0.1
        mapMoss.BorderSizePixel = 0
        mapMoss.Size = UDim2.new(1, 0, 0, 2)
        mapMoss.ZIndex = 35
        mapMoss.Parent = view
        local mapSignal = Instance.new("UIGradient")
        mapSignal.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, MP.Fern),
            ColorSequenceKeypoint.new(0.55, MP.LeafLight),
            ColorSequenceKeypoint.new(1, MP.Purple),
        })
        mapSignal.Parent = mapMoss
        local sharedValue48 = helper155("Frame", {
            Name = "Header",
            BackgroundColor3 = theme2.Panel,
            Size = UDim2.new(1, 0, 0, 132),
            ZIndex = 30,
            Visible = false,
        }, view)
        helper162(sharedValue48, 90)
        local sharedValue49 = helper155("Frame", {
            Name = "Footer",
            BackgroundColor3 = theme2.Panel,
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 64),
            ZIndex = 30,
            Visible = false,
        }, view)
        helper162(sharedValue49, -90)
        local sharedValue50 = helper155("Frame", {
            Name = "Title",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 18, 0, 27),
            ZIndex = 45,
        }, view)
        helper159(sharedValue50, true, 8)
        helper161(sharedValue50, theme2.Green, 8, 1)
        helper160(
            sharedValue50,
            { Text = "Swangy map", FontFace = sharedValue41.Bold, TextSize = 18, LayoutOrder = 2 }
        )
        helper160(sharedValue50, { Text = "Live", TextSize = 13, TextColor3 = theme2.Muted, LayoutOrder = 3 })
        local sharedValue51 = helper155("Frame", {
            Name = "Hints",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 18, 1, -21),
            ZIndex = 45,
        }, view)
        helper159(sharedValue51, true, 18)
        hlBugReport =
            { { "Scroll", "zoom" }, { "Middle-drag", "look around" }, { "Middle-click", "follow you" } }
        for index24, entry26 in ipairs(hlBugReport) do
            helper162 = helper155(
                "Frame",
                { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = index24 },
                sharedValue51
            )
            helper159(helper162, true, 7)
            index24 = helper155("Frame", {
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromOffset(0, 22),
                BackgroundColor3 = theme2.Raised,
                LayoutOrder = 1,
            }, helper162)
            helper156(index24, 6)
            helper157(index24)
            helper158(index24, 0, 7)
            helper160(index24, {
                Text = entry26[1],
                FontFace = sharedValue41.Semi,
                TextSize = 12,
                Size = UDim2.fromScale(0, 1),
                AutomaticSize = Enum.AutomaticSize.X,
            })
            helper160(
                helper162,
                { Text = entry26[2], TextSize = 13, TextColor3 = theme2.Muted, LayoutOrder = 2 }
            )
        end
        local sharedValue52 = helper155("Frame", {
            Name = "Legend",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -18, 1, -21),
            ZIndex = 45,
        }, view)
        helper159(sharedValue52, true, 16)
        local viewBox, hit =
            ipairs, {
                { theme2.Red, "Mob" },
                { theme2.Purple, "Boss" },
                { theme2.Blue, "Player" },
                { theme2.White, "You" },
                { theme2.Orb, "Orb" },
            }
        for key8, entry27 in viewBox(hit) do
            helper162 = helper155(
                "Frame",
                { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = key8 },
                sharedValue52
            )
            helper159(helper162, true, 6)
            helper161(helper162, entry27[1], 8, 1)
            helper160(
                helper162,
                { Text = entry27[2], TextSize = 13, TextColor3 = theme2.Muted, LayoutOrder = 2 }
            )
        end
        hit = Instance.new("TextButton")
        hit.Name, hit.BackgroundTransparency, hit.Text, hit.AutoButtonColor, hit.Size =
            "Hit", 1, "", false, UDim2.fromScale(1, 1)
        hit.ZIndex = 40
        hit.Parent = view
        zone.overMenu = function()
            local scriptGui = runtimeState.scriptGui
            if not scriptGui then
                return false
            end
            local vector, value =
                userInputService:GetMouseLocation() - getService("GuiService"):GetGuiInset(),
                workspaceService.CurrentCamera
            local value2 = value and value.ViewportSize.X or 1000000000
            for index, child in ipairs(scriptGui:GetChildren()) do
                value = child.Name == "HLMenu"
                if
                    child ~= hlMinimap
                    and child:IsA("GuiObject")
                    and child.Visible
                    and (child.Active or value)
                then
                    local absolutePosition, absoluteSize = child.AbsolutePosition, child.AbsoluteSize
                    if value or absoluteSize.X < value2 - 2 then
                        if vector.X >= absolutePosition.X then
                            if vector.X <= absolutePosition.X + absoluteSize.X then
                                if vector.Y >= absolutePosition.Y then
                                    if vector.Y <= absolutePosition.Y + absoluteSize.Y then
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
        zone.mapBtn = helper155("TextButton", {
            Name = "MapButton",
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 1, 10),
            Size = UDim2.fromOffset(150, 26),
            ZIndex = 5,
            Visible = false,
        }, hlMinimap)
        zone.mapBtnStroke = helper157(zone.mapBtn)
        zone.mapBtnCorner = helper156(zone.mapBtn, 8)
        viewBox, helper162 =
            zone.mapBtn, function()
                if zone.overMenu() then
                    return
                end
                if zone.setBig then
                    zone.setBig(true)
                end
            end
        viewBox.Activated:Connect(helper162)
        local sharedValue53 = helper155("TextButton", {
            Name = "Close",
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -18, 0, 18),
            Size = UDim2.fromOffset(32, 32),
            BackgroundColor3 = theme2.Raised,
            ZIndex = 50,
            Visible = false,
        }, view)
        helper156(sharedValue53, 8)
        local sharedValue54 = helper157(sharedValue53)
        local sharedValue55 = uiLibrary.icon(sharedValue53, "x", 16, theme2.Muted, 51)
        sharedValue55.AnchorPoint, sharedValue55.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
        local function helper163()
            helper154(sharedValue53, 0.15, { BackgroundColor3 = theme2.Red })
            helper154(sharedValue54, 0.15, { Color = theme2.Red })
            helper154(sharedValue55, 0.15, { ImageColor3 = theme2.White })
        end
        sharedValue53.MouseEnter:Connect(helper163)
        local function helper164()
            helper154(sharedValue53, 0.15, { BackgroundColor3 = theme2.Raised })
            helper154(sharedValue54, 0.15, { Color = theme2.Stroke })
            helper154(sharedValue55, 0.15, { ImageColor3 = theme2.Muted })
        end
        sharedValue53.MouseLeave:Connect(helper164)
        local sharedValue56 = helper155("Frame", {
            Name = "Options",
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -234, 0, 27),
            ZIndex = 45,
        }, view)
        helper159(sharedValue56, true, 6)
        sharedValue53.AnchorPoint, sharedValue53.Position = Vector2.new(1, 0.5), UDim2.new(1, -18, 0, 27)
        local sharedValue57 = {}
        local function helper165(argument, argument2)
            if argument == "mapBg3D" and config.renderOff == true then
                config.mapBg3D = true
                config.renderOff = false
                zone.ultOpened = nil
                if context.applyRender then
                    pcall(context.applyRender, true)
                end
                if context.refreshAll then
                    pcall(context.refreshAll)
                end
            elseif argument2 then
                config[argument] = config[argument] == false
            else
                config[argument] = config[argument] ~= true
            end
            pcall(helper16)
        end
        local function helper166(layoutOrder, text, argument, argument2, argument3)
            local value = helper155("TextButton", {
                Name = "Chip",
                Text = "",
                AutoButtonColor = false,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromOffset(0, 28),
                BackgroundColor3 = theme2.Green,
                BackgroundTransparency = 1,
                LayoutOrder = layoutOrder,
                ZIndex = 46,
            }, sharedValue56)
            helper156(value, 14)
            helper158(value, 0, 12, 0, 10)
            helper159(value, true, 7)
            local value2 = helper157(value)
            local value3 = helper161(value, theme2.Faint, 6, 1)
            local value4 = helper160(value, { Text = text, TextSize = 13, LayoutOrder = 2 })
            local function helper6()
                if argument2 then
                    return config[argument] ~= false
                end
                return config[argument] == true
            end
            local function render(argument4)
                local value5 = helper6() and not (argument == "mapBg3D" and config.renderOff == true)
                argument4 = argument4 or 0
                helper154(value, argument4, { BackgroundTransparency = value5 and 0.88 or 1 })
                helper154(
                    value2,
                    argument4,
                    { Color = value5 and theme2.Green or theme2.Stroke, Transparency = value5 and 0.5 or 0 }
                )
                helper154(value3, argument4, { BackgroundColor3 = value5 and theme2.Green or theme2.Faint })
                helper154(value4, argument4, { TextColor3 = value5 and theme2.Text or theme2.Muted })
            end
            local function helper22()
                if not (helper6()) then
                    helper154(value4, 0.15, { TextColor3 = theme2.Text })
                end
            end
            value.MouseEnter:Connect(helper22)
            local function helper23()
                render(0.15)
            end
            value.MouseLeave:Connect(helper23)
            local function helper24()
                if zone.overMenu() then
                    return
                end
                helper165(argument, argument2)
                render(0.18)
                if zone.apply then
                    zone.apply()
                end
            end
            value.Activated:Connect(helper24)
            uiLibrary.tip(value, argument3)
            render(0)
            sharedValue57[argument] = { b = value, render = render }
        end
        viewBox = {
            {
                2,
                "Health bars",
                "mapHealthBars",
                true,
                "A small health bar under every mob, boss and player.",
            },
            {
                3,
                "Names",
                "mapNames",
                true,
                "Every mob's, boss's and player's name beside them (\"YOU\" for this account; no player names in streamer mode).",
            },
        }
        for index25, entry28 in ipairs(viewBox) do
            helper166(entry28[1], entry28[2], entry28[3], entry28[4], entry28[5])
        end
        zone.VIEW_W = 168
        zone.VIEW_H = 28
        zone.viewMode = function()
            if config.mapBlankScreen == true then
                return "blank"
            end
            if config.mapBg3D ~= false then
                if config.renderOff ~= true then
                    return "3d"
                end
            end
            return "2d"
        end
        zone.setView = function(argument)
            if argument == "3d" then
                if config.renderOff == true then
                    config.renderOff = false
                    zone.ultOpened = nil
                    if context.applyRender then
                        pcall(context.applyRender, true)
                    end
                end
                config.mapBg3D = true
                config.mapBlankScreen = false
            elseif argument == "2d" then
                config.mapBg3D = false
                config.mapBlankScreen = false
            else
                config.mapBlankScreen = true
            end
            pcall(helper16)
            if context.refreshAll then
                pcall(context.refreshAll)
            end
            zone.apply()
        end
        zone.viewSpot = function()
            local vector, vector2, value =
                workspaceService.CurrentCamera and workspaceService.CurrentCamera.ViewportSize or Vector2.new(
                    1920,
                    1080
                ),
                getService("GuiService"):GetGuiInset(),
                zone.big and config.mapStatsHidden == true and 10 or sharedValue42 + sharedValue43
            return Vector2.new(
                vector.X - sharedValue44 - value - 58 - zone.VIEW_W,
                sharedValue45 - vector2.Y + 27 - zone.VIEW_H / 2
            ),
                Vector2.new(zone.VIEW_W, zone.VIEW_H)
        end
        viewBox = helper155("Frame", {
            Name = "ViewSwitch",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -58, 0, 27),
            Size = UDim2.fromOffset(zone.VIEW_W, zone.VIEW_H),
            BackgroundColor3 = theme2.Raised,
            ZIndex = 46,
            Visible = false,
        }, view)
        helper156(viewBox, 14)
        helper157(viewBox)
        helper158(viewBox, 2)
        helper159(viewBox, true, 2)
        zone.viewSegs = {}
        helper162 = {
            {
                "2d",
                "2D",
                48,
                "The flat map - the walls, the attacks, every mob and player as a dot, with names and health bars. The world is not drawn meanwhile (as with Ultimate low quality) - the most FPS there is.",
            },
            {
                "3d",
                "3D",
                48,
                "The world itself from straight above - greyed, every height and attack as it really is. Turns Ultimate low quality off (the world has to be drawn for it).",
            },
            {
                "blank",
                "Blank",
                64,
                "Nothing drawn - no map, no stats - only this switch stays, to bring the map back. With Ultimate low quality on it is the least there is to draw.",
            },
        }
        for index26, entry29 in ipairs(helper162) do
            helper164 = helper155("TextButton", {
                Name = entry29[1],
                Text = "",
                AutoButtonColor = false,
                Size = UDim2.new(0, entry29[3], 1, 0),
                BackgroundColor3 = theme2.Green,
                BackgroundTransparency = 1,
                LayoutOrder = index26,
                ZIndex = 47,
            }, viewBox)
            helper156(helper164, 12)
            local sharedValue58 = helper160(helper164, {
                Text = entry29[2],
                FontFace = sharedValue41.Semi,
                TextSize = 13,
                TextColor3 = theme2.Muted,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.fromScale(1, 1),
                AutomaticSize = Enum.AutomaticSize.None,
                ZIndex = 48,
            })
            local function helper167()
                if zone.viewMode() ~= entry29[1] then
                    helper154(sharedValue58, 0.15, { TextColor3 = theme2.Text })
                end
            end
            helper164.MouseEnter:Connect(helper167)
            local function helper168()
                zone.paintView(0.15)
            end
            helper164.MouseLeave:Connect(helper168)
            local function helper169()
                if zone.overMenu() then
                    return
                end
                zone.setView(entry29[1])
            end
            helper164.Activated:Connect(helper169)
            uiLibrary.tip(helper164, entry29[4])
            zone.viewSegs[entry29[1]] = { b = helper164, l = sharedValue58 }
        end
        zone.paintView = function(argument)
            local value = zone.viewMode()
            for key, viewSeg in pairs(zone.viewSegs) do
                local value2, value3, value4 = viewSeg.b, argument or 0, {}
                value4.BackgroundTransparency = key == value and 0.78 or 1
                helper154(value2, value3, value4)
                value4, value2, value3 = viewSeg.l, argument or 0, {}
                value3.TextColor3 = key == value and theme2.Text or theme2.Muted
                helper154(value4, value2, value3)
            end
        end
        zone.viewBox = viewBox
        zone.CAM_VIEWS = {
            { name = "TOP", pitch = 89.5 },
            { name = "TILT", pitch = 68 },
            { name = "3D", pitch = 52 },
            { name = "ISO", pitch = 35, yaw = 45 },
            { name = "LOW", pitch = 22 },
            { name = "CHASE", pitch = 30, heading = true },
            { name = "ORBIT", pitch = 45, spin = 18 },
            { name = "FREE", free = true },
            { name = "AUTO", auto = true },
        }
        zone.camIndex = function()
            for index, view2 in ipairs(zone.CAM_VIEWS) do
                if view2.name == config.map3DView then
                    return index
                end
            end
            return 1
        end
        zone.camShot = function(argument)
            local value = zone.CAM_VIEWS[zone.camIndex()]
            local value2 = value.auto == true
            if value2 then
                local autoView = zone.autoView
                if (if autoView then not zone.autoAt else not autoView) or argument >= zone.autoAt then
                    local value3 = {}
                    for index, view2 in ipairs(zone.CAM_VIEWS) do
                        if not view2.auto then
                            if not view2.free then
                                if view2 ~= zone.autoView then
                                    value3[#value3 + 1] = view2
                                end
                            end
                        end
                    end
                    zone.autoView = value3[math.random(1, #value3)]
                    zone.autoAt = argument
                        + math.clamp(tonumber(config.map3DSwitch) or 4, 1.5, 15)
                            * (0.75 + math.random() * 0.5)
                    zone.autoYaw = math.random() * 360
                end
                value = zone.autoView
            end
            local value4, value5 = value.pitch or 55, value.yaw or 0
            if value.free then
                value4, value5 = tonumber(config.map3DFreePitch) or 55, tonumber(config.map3DFreeYaw) or 0
            end
            value5 = if value2
                then if value.yaw == nil
                    then if value.heading
                        then value5
                        else if value.spin
                            then value5
                            else if value.name ~= "TOP" then zone.autoYaw or 0 else value5
                    else value5
                else value5
            if value.heading then
                value2 = localPlayer.Character
                local value6 = value2 and (value2:FindFirstChild("HumanoidRootPart"))
                if value6 then
                    local lookVector = value6.CFrame.LookVector
                    value5 = if lookVector.X * lookVector.X + lookVector.Z * lookVector.Z > 0.01
                        then math.deg(math.atan2(-lookVector.X, -lookVector.Z))
                        else value5
                end
            end
            return value4, if value.spin then argument * value.spin % 360 else value5
        end
        do
            local camBox = helper155("Frame", {
                Name = "Camera3D",
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -18, 1, -12),
                Size = UDim2.fromOffset(240, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme2.Raised,
                BackgroundTransparency = 0.06,
                ZIndex = 46,
                Visible = false,
            }, view)
            helper156(camBox, 12)
            helper157(camBox)
            helper158(camBox, 8, 10)
            helper159(camBox, false, 6)
            helper163 = helper155("TextButton", {
                Name = "View",
                Text = "",
                AutoButtonColor = false,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = theme2.Panel,
                LayoutOrder = 1,
                ZIndex = 47,
            }, camBox)
            helper156(helper163, 8)
            local sharedValue59 = helper157(helper163)
            local textControl27, sharedValue60 =
                helper160(helper163, {
                    Text = "",
                    FontFace = sharedValue41.Semi,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Size = UDim2.fromScale(1, 1),
                    AutomaticSize = Enum.AutomaticSize.None,
                    ZIndex = 48,
                }), { "chevron-left", "chevron-right" }
            for index27, entry30 in ipairs(sharedValue60) do
                helper166 = uiLibrary.icon(helper163, entry30, 14, theme2.Muted, 48)
                helper166.AnchorPoint = Vector2.new(index27 == 1 and 0 or 1, 0.5)
                helper166.Position = UDim2.new(index27 == 1 and 0 or 1, index27 == 1 and 8 or -8, 0.5, 0)
            end
            local function helper170()
                helper154(sharedValue59, 0.15, { Color = theme2.Green })
            end
            helper163.MouseEnter:Connect(helper170)
            local function helper171()
                helper154(sharedValue59, 0.15, { Color = theme2.Stroke })
            end
            helper163.MouseLeave:Connect(helper171)
            local function helper172(layoutOrder, argument, argument2, argument3, name2, argument4, argument5)
                local value = helper155("TextButton", {
                    Name = name2,
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    LayoutOrder = layoutOrder,
                    ZIndex = 47,
                }, camBox)
                local textControl = helper160(value, {
                    Text = "",
                    FontFace = sharedValue41.Mono,
                    TextSize = 12,
                    TextColor3 = theme2.Muted,
                    Size = UDim2.new(0, 94, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.None,
                    ZIndex = 48,
                })
                local value2 = helper155("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 98, 0.5, 0),
                    Size = UDim2.new(1, -104, 0, 4),
                    BackgroundColor3 = theme2.Stroke,
                    ZIndex = 48,
                }, value)
                helper156(value2, 2)
                local value3 = helper155(
                    "Frame",
                    { Size = UDim2.fromScale(0, 1), BackgroundColor3 = theme2.Green, ZIndex = 49 },
                    value2
                )
                helper156(value3, 2)
                local value4 = helper155("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.fromOffset(10, 10),
                    BackgroundColor3 = theme2.White,
                    ZIndex = 50,
                }, value2)
                helper156(value4, 5)
                local function helper6()
                    return math.clamp(tonumber(config[name2]) or argument4, argument, argument2)
                end
                local function helper22()
                    local value5 = (helper6() - argument) / (argument2 - argument)
                    value3.Size, value4.Position, textControl.Text =
                        UDim2.fromScale(value5, 1), UDim2.fromScale(value5, 0.5), argument5(helper6())
                end
                local value6 = false
                local function helper23(argument6)
                    local value5 = math.clamp(
                        (argument6 - value2.AbsolutePosition.X) / math.max(1, value2.AbsoluteSize.X),
                        0,
                        1
                    )
                    config[name2] = math.clamp(
                        math.floor((argument + (argument2 - argument) * value5) / argument3 + 0.5) * argument3,
                        argument,
                        argument2
                    )
                    helper22()
                end
                value.InputBegan:Connect(function(input)
                    if zone.overMenu() then
                        return
                    end
                    if
                        input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch
                    then
                        value6 = true
                        helper23(input.Position.X)
                    end
                end)
                sliderConnections[#sliderConnections + 1] = userInputService.InputChanged:Connect(
                    function(input)
                        local value5 = value6
                            and (
                                input.UserInputType == Enum.UserInputType.MouseMovement
                                or input.UserInputType == Enum.UserInputType.Touch
                            )
                        if value5 then
                            helper23(input.Position.X)
                        end
                    end
                )
                sliderConnections[#sliderConnections + 1] = userInputService.InputEnded:Connect(
                    function(input)
                        if value6 then
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                value6 = false
                                pcall(helper16)
                            elseif input.UserInputType == Enum.UserInputType.Touch then
                                value6 = false
                                pcall(helper16)
                            end
                        end
                    end
                )
                helper22()
                return value, helper22
            end
            local WP, sharedValue61 = helper172(2, 0.2, 6, 0.1, "map3DZoom", 1, function(argument)
                return ("ZOOM x%.1f"):format(argument)
            end)
            local sharedValue62, sharedValue63 = helper172(
                3,
                1.5,
                15,
                0.5,
                "map3DSwitch",
                4,
                function(argument)
                    return ("SWITCH %.1fs"):format(argument)
                end
            )
            uiLibrary.tip(
                sharedValue62,
                "AUTO: about how long each view is held before it glides to another."
            )
            zone.paintCam = function()
                local value = zone.CAM_VIEWS[zone.camIndex()]
                textControl27.Text = "Camera: " .. value.name
                sharedValue62.Visible = value.auto == true
                sharedValue61()
                sharedValue63()
            end
            local function helper173(argument)
                config.map3DView = zone.CAM_VIEWS[(zone.camIndex() - 1 + argument) % #zone.CAM_VIEWS + 1].name
                zone.autoAt = nil
                pcall(helper16)
                zone.paintCam()
            end
            local function helper174()
                if zone.overMenu() then
                    return
                end
                helper173(1)
            end
            helper163.MouseButton1Click:Connect(helper174)
            local function helper175()
                if zone.overMenu() then
                    return
                end
                helper173(-1)
            end
            helper163.MouseButton2Click:Connect(helper175)
            uiLibrary.tip(
                helper163,
                "The 3D view's camera: TOP (straight down), TILT, 3D, ISO, LOW, CHASE (behind you), ORBIT, FREE (right-drag the map) or AUTO. Left-click for the next, right-click for the one before."
            )
            local function helper176(camCur)
                if camCur.UserInputType ~= Enum.UserInputType.MouseButton2 then
                    return
                elseif zone.cam3On then
                    if zone.overMenu() then
                        return
                    end
                else
                    return
                end
                zone.orbitAt = { x = camCur.Position.X, y = camCur.Position.Y }
                if config.map3DView ~= "FREE" then
                    camCur = zone.camCur
                    config.map3DFreePitch = camCur and math.clamp(camCur.p, 8, 89.5) or 55
                    config.map3DFreeYaw = camCur and camCur.y or 0
                    config.map3DView = "FREE"
                    zone.paintCam()
                end
            end
            hit.InputBegan:Connect(helper176)
            sliderConnections[#sliderConnections + 1] = userInputService.InputChanged:Connect(function(input)
                local orbitAt = zone.orbitAt
                if orbitAt then
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                        return
                    end
                else
                    return
                end
                local value, value2 = input.Position.X - orbitAt.x, input.Position.Y - orbitAt.y
                orbitAt.x, orbitAt.y = input.Position.X, input.Position.Y
                config.map3DFreeYaw = ((tonumber(config.map3DFreeYaw) or 0) - value * 0.35) % 360
                config.map3DFreePitch =
                    math.clamp((tonumber(config.map3DFreePitch) or 55) + value2 * 0.3, 8, 89.5)
            end)
            sliderConnections[#sliderConnections + 1] = userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    if zone.orbitAt then
                        zone.orbitAt = nil
                        pcall(helper16)
                    end
                end
            end)
            zone.camBox = camBox
            zone.paintCam()
        end
        zone.setAccent = function(argument)
            if typeof(argument) ~= "Color3" then
                return
            end
            local green2 = theme2.Green
            theme2.Green = argument
            local function helper6(argument2)
                return argument2
                    and math.abs(argument2.R - green2.R)
                            + math.abs(argument2.G - green2.G)
                            + math.abs(argument2.B - green2.B)
                        < 0.012
            end
            for index, descendant in ipairs(hlMinimap:GetDescendants()) do
                if not (descendant:IsDescendantOf(sharedValue52)) then
                    if descendant:IsA("GuiObject") then
                        if helper6(descendant.BackgroundColor3) then
                            descendant.BackgroundColor3 = argument
                        end
                    end
                    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                        if helper6(descendant.TextColor3) then
                            descendant.TextColor3 = argument
                        end
                    end
                    if descendant:IsA("UIStroke") then
                        if helper6(descendant.Color) then
                            descendant.Color = argument
                        end
                    end
                end
            end
            if zone.apply then
                pcall(zone.apply)
            end
        end
        zone.opacity = function()
            return 100
        end
        zone.opaque = function()
            return true
        end
        local statsFrame = helper155("Frame", {
            Name = "Stats",
            BackgroundColor3 = theme2.Panel,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -16, 0, sharedValue45),
            Size = UDim2.new(0, sharedValue42, 1, -80),
            ZIndex = 2,
            Visible = false,
        }, hlMinimap)
        helper156(statsFrame, 14)
        helper157(statsFrame)
        helper160(statsFrame, {
            Text = "Stats",
            FontFace = sharedValue41.Bold,
            TextSize = 18,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 18, 0, 27),
        })
        helper155("Frame", {
            Position = UDim2.fromOffset(0, 55),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = theme2.StrokeSoft,
        }, statsFrame)
        zone.statsFrame = statsFrame
        zone.viewFrame = view
        do
            local statsArrow = helper155("TextButton", {
                Name = "StatsArrow",
                Text = ">",
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -378, 0.5, 0),
                Size = UDim2.fromOffset(14, 48),
                BackgroundColor3 = theme2.Raised,
                TextColor3 = theme2.Muted,
                FontFace = sharedValue41.Bold,
                TextSize = 14,
                ZIndex = 6,
                Visible = false,
            }, hlMinimap)
            helper156(statsArrow, 7)
            local sharedValue64 = helper157(statsArrow)
            local function helper177()
                helper154(statsArrow, 0.15, { TextColor3 = theme2.Text })
                helper154(sharedValue64, 0.15, { Color = theme2.Purple })
            end
            statsArrow.MouseEnter:Connect(helper177)
            local function helper178()
                helper154(statsArrow, 0.15, { TextColor3 = theme2.Muted })
                helper154(sharedValue64, 0.15, { Color = theme2.Stroke })
            end
            statsArrow.MouseLeave:Connect(helper178)
            local function helper179()
                if zone.overMenu() then
                    return
                end
                config.mapStatsHidden = config.mapStatsHidden ~= true
                pcall(helper16)
                if zone.apply then
                    zone.apply()
                end
            end
            statsArrow.Activated:Connect(helper179)
            uiLibrary.tip(
                statsArrow,
                "Fold the Stats sidebar away (the map takes the whole width) - click again to bring it back."
            )
            zone.statsArrow = statsArrow
        end
        local sharedValue65 = helper155("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(18, 76),
            Size = UDim2.new(1, -40, 0, 76),
        }, statsFrame)
        helper155("UIGridLayout", {
            CellSize = UDim2.new(0.5, -8, 1, 0),
            CellPadding = UDim2.fromOffset(16, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, sharedValue65)
        local function helper180(layoutOrder, text)
            local value = helper155(
                "Frame",
                { BackgroundColor3 = theme2.Raised, LayoutOrder = layoutOrder },
                sharedValue65
            )
            helper156(value, 10)
            helper157(value, theme2.StrokeSoft)
            helper158(value, 12, 14)
            layoutOrder = helper160(
                value,
                { Text = "-", FontFace = sharedValue41.Bold, TextSize = 30, TextColor3 = theme2.Green }
            )
            helper160(value, {
                Text = text,
                TextSize = 12,
                TextColor3 = theme2.Muted,
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.fromScale(0, 1),
            })
            return layoutOrder
        end
        local textControl28 = helper180(1, "Session wins")
        local textControl29 = helper180(2, "Win rate")
        local sharedValue66 = helper155("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(18, 176),
            Size = UDim2.new(1, -26, 1, -190),
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme2.Stroke,
        }, statsFrame)
        helper159(sharedValue66, false, 18)
        helper158(sharedValue66, 0, 14, 0, 0)
        local sharedValue67, layoutOrder2 = {}, 0
        local function weakKeys5(argument, argument2)
            layoutOrder2 += 1
            local value = helper155("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = layoutOrder2,
            }, sharedValue66)
            helper159(value, false, 0)
            local value2 = helper155(
                "Frame",
                { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 0 },
                value
            )
            helper160(value2, {
                Text = string.upper(argument),
                FontFace = sharedValue41.Semi,
                TextSize = 11,
                TextColor3 = theme2.Faint,
                Size = UDim2.fromOffset(0, 16),
            })
            helper155("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, -2),
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = theme2.StrokeSoft,
            }, value2)
            for index, entry in ipairs(argument2) do
                local text, value3, value4 =
                    entry[1],
                    entry[2],
                    helper155(
                        "Frame",
                        { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = index },
                        value
                    )
                helper160(value4, {
                    Text = text,
                    TextColor3 = theme2.Muted,
                    Size = UDim2.fromScale(0, 1),
                    AutomaticSize = Enum.AutomaticSize.X,
                })
                index = nil
                if value3 then
                    argument = helper155("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.fromScale(1, 0.5),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2.fromOffset(0, 20),
                        BackgroundColor3 = theme2.Green,
                        BackgroundTransparency = 0.86,
                    }, value4)
                    helper156(argument, 10)
                    helper158(argument, 0, 9)
                    index = helper160(argument, {
                        Text = "-",
                        FontFace = sharedValue41.Semi,
                        TextSize = 13,
                        TextColor3 = theme2.Green,
                        Size = UDim2.fromScale(0, 1),
                        AutomaticSize = Enum.AutomaticSize.X,
                    })
                else
                    index = helper160(value4, {
                        Text = "-",
                        FontFace = sharedValue41.Semi,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.fromScale(1, 0.5),
                        Size = UDim2.new(0.64, 0, 1, 0),
                        AutomaticSize = Enum.AutomaticSize.None,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                    })
                end
                sharedValue67[text] = index
            end
        end
        local sharedValue68 = helper155("Frame", {
            Name = "BossHud",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 76),
            Size = UDim2.fromOffset(config.mapBossBarW or 400, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 55,
        }, view)
        helper159(sharedValue68, false, 10, Enum.HorizontalAlignment.Center)
        local sharedValue69 = helper155("Frame", {
            Name = "Timer",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, 32),
            BackgroundColor3 = theme2.Raised,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0, 27),
            ZIndex = 55,
            Visible = false,
        }, view)
        helper156(sharedValue69, 8)
        helper157(sharedValue69)
        helper158(sharedValue69, 0, 14)
        local textControl30 = helper160(sharedValue69, {
            Text = "00:00",
            FontFace = sharedValue41.Mono,
            TextSize = 16,
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = Enum.AutomaticSize.X,
        })
        local sharedValue70 = helper155("Frame", {
            Name = "BossBar",
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme2.Raised,
            BackgroundTransparency = 0.08,
            LayoutOrder = 2,
            Visible = false,
        }, sharedValue68)
        helper156(sharedValue70, 10)
        helper157(sharedValue70)
        helper158(sharedValue70, 12, 14, 14, 14)
        helper159(sharedValue70, false, 8)
        viewBox = helper155(
            "Frame",
            { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 1 },
            sharedValue70
        )
        helper163 = helper155(
            "Frame",
            { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1) },
            viewBox
        )
        helper159(helper163, true, 8)
        helper161(helper163, theme2.Purple, 8, 1)
        local textControl31 =
            helper160(helper163, { Text = "", FontFace = sharedValue41.Semi, TextSize = 14, LayoutOrder = 2 })
        local textControl32 = helper160(viewBox, {
            Text = "",
            FontFace = sharedValue41.Mono,
            TextSize = 13,
            TextColor3 = theme2.Muted,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.fromScale(1, 0.5),
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        helper162 = helper155(
            "Frame",
            { Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = theme2.Bg, LayoutOrder = 2 },
            sharedValue70
        )
        helper156(helper162, 3)
        local sharedValue71 =
            helper155("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = theme2.White }, helper162)
        helper156(sharedValue71, 3)
        helper155("UIGradient", { Color = ColorSequence.new(theme2.Purple, theme2.Pink) }, sharedValue71)
        local sharedValue72 = { on = false, want = {}, conns = {} }
        local function helper181(argument)
            if argument:IsA("ScreenGui") then
                if argument == runtimeState.scriptGui then
                    return
                end
            else
                return
            end
            if sharedValue72.want[argument] == nil then
                sharedValue72.want[argument] = argument.Enabled
                sharedValue72.conns[#sharedValue72.conns + 1] = argument
                    :GetPropertyChangedSignal("Enabled")
                    :Connect(function()
                        if sharedValue72.on then
                            if argument.Enabled then
                                sharedValue72.want[argument] = true
                                pcall(function()
                                    argument.Enabled = false
                                end)
                            end
                        end
                    end)
            end
            if argument.Enabled then
                pcall(function()
                    argument.Enabled = false
                end)
            end
        end
        sharedValue72.bossBarDone = function()
            local success, value = pcall(function()
                local value2 = require(localPlayer.PlayerScripts.Ui.bossHealth)
                if type(value2) ~= "table" then
                    return false
                elseif type(value2.ConnectBoss) ~= "function" then
                    return false
                end
                local value3 = value2.ConnectedBoss
                value2 = type(value3) == "table" and value3.boss or nil
                if typeof(value2) == "Instance" then
                    value3 = workspace
                    if not (value2:IsDescendantOf(value3)) then
                        return true
                    end
                else
                    return true
                end
                value3 = value2:FindFirstChildOfClass("Humanoid")
                return not (value3 and value3.Health > 0)
            end)
            return success and value == true
        end
        sharedValue72.set = function(argument)
            if argument == sharedValue72.on then
                return
            end
            sharedValue72.on = argument
            if argument then
                local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    for index, child in ipairs(playerGui:GetChildren()) do
                        pcall(helper181, child)
                    end
                    sharedValue72.conns[#sharedValue72.conns + 1] = playerGui.ChildAdded:Connect(
                        function(argument2)
                            task.defer(function()
                                if sharedValue72.on then
                                    pcall(helper181, argument2)
                                end
                            end)
                        end
                    )
                end
            else
                for index2, conn in ipairs(sharedValue72.conns) do
                    pcall(conn.Disconnect, conn)
                end
                sharedValue72.conns = {}
                for key, entry in pairs(sharedValue72.want) do
                    if entry and key.Name == "bossHealth" and sharedValue72.bossBarDone() then
                        entry = false
                    end
                    pcall(function()
                        if key.Parent then
                            key.Enabled = entry
                        end
                    end)
                end
                sharedValue72.want = {}
            end
        end
        zone.GH = sharedValue72
        zone.stopGui = function()
            sharedValue72.set(false)
        end
        if not zone.big then
            pcall(function()
                local bossHealth = localPlayer.PlayerGui:FindFirstChild("bossHealth")
                if bossHealth then
                    if bossHealth:IsA("ScreenGui") then
                        if bossHealth.Enabled then
                            if sharedValue72.bossBarDone() then
                                bossHealth.Enabled = false
                            end
                        end
                    end
                end
            end)
        end
        zone.drawTimer = function()
            local value = localPlayer:FindFirstChildOfClass("PlayerGui")
            local value2 = value and (value:FindFirstChild("timeLeftGui"))
            value = value2 and (value2:FindFirstChild("Frame"))
            local textControl, text = value and (value:FindFirstChild("time"))
            if value2 and (value2.Enabled or sharedValue72.want[value2] == true) then
                if value then
                    if value:IsA("GuiObject") then
                        if value.Visible then
                            if textControl then
                                if textControl:IsA("TextLabel") then
                                    if textControl.Visible then
                                        local value3 = tostring(textControl.Text)
                                        text = if value3:match("%d+:%d%d") then value3 else text
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if not text then
                if sharedValue69.Visible then
                    sharedValue69.Visible = false
                end
                return
            end
            if textControl30.Text ~= text then
                textControl30.Text = text
            end
            value2 = {}
            for entry in text:gmatch("%d+") do
                value2[#value2 + 1] = tonumber(entry)
            end
            value = 0
            for index, entry2 in ipairs(value2) do
                value = value * 60 + entry2
            end
            textControl30.TextColor3 = value < 60 and theme2.Red or theme2.Text
            if zone.big then
                if not (zone.blank()) then
                    if not sharedValue69.Visible then
                        sharedValue69.Visible = true
                    end
                end
            end
        end
        zone.drawBoss = function()
            local value, humanoid
            local value2, value3 = math.huge, hazardReader.rodinRig
            if value3 then
                if value3.Parent then
                    local humanoid2 = value3:FindFirstChildOfClass("Humanoid")
                    if humanoid2 then
                        if humanoid2.Health > 0 then
                            value, humanoid = value3, humanoid2
                        end
                    end
                end
            end
            if not value then
                value3 = localPlayer.Character
                local value4 = value3 and (value3:FindFirstChild("HumanoidRootPart"))
                for index, entry in ipairs(hazardReader.enemies or {}) do
                    if entry.isBoss then
                        if entry.model then
                            if entry.model.Parent then
                                if entry.humanoid then
                                    if entry.humanoid.Health > 0 then
                                        index = value4
                                                and (entry.x - value4.Position.X) ^ 2 + (entry.z - value4.Position.Z) ^ 2
                                            or 0
                                        if index < value2 then
                                            local model, humanoid3 = entry.model, entry.humanoid
                                            value2, value, humanoid = index, model, humanoid3
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if not (value and humanoid and humanoid.MaxHealth > 0) then
                if sharedValue70.Visible then
                    sharedValue70.Visible = false
                end
                return
            end
            value2 = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            textControl31.Text = value.Name
            textControl32.Text = ("%.1f%%"):format(value2 * 100)
            sharedValue71.Size = UDim2.fromScale(value2, 1)
            if not sharedValue70.Visible then
                sharedValue70.Visible = true
            end
        end
        viewBox = {
            { "Session", { { "Runs lost" }, { "Mob kills" }, { "Boss kills" } } },
            { "This run", { { "Dungeon" }, { "Run time" }, { "Deaths" }, { "Kills" } } },
            { "Around you", { { "Mobs" }, { "Bosses" }, { "Enemy attacks" }, { "Players" } } },
            { "You", { { "Level" }, { "Gold" }, { "Gems" }, { "Ping" }, { "FPS" } } },
            { "Bot", { { "Doing", true }, { "Queue" }, { "Mod detection" } } },
        }
        for index28, entry31 in ipairs(viewBox) do
            weakKeys5(entry31[1], entry31[2])
        end
        local function helper182(argument)
            argument = tonumber(argument) or 0
            local value = math.abs(argument)
            if value >= 1000000000000 then
                return ("%.2fT"):format(argument / 1000000000000)
            end
            if value >= 1000000000 then
                return ("%.2fB"):format(argument / 1000000000)
            end
            if value >= 1000000 then
                return ("%.2fM"):format(argument / 1000000)
            end
            if value >= 1000 then
                return ("%.1fK"):format(argument / 1000)
            end
            return tostring(math.floor(argument))
        end
        local function helper183(argument)
            argument = math.max(math.floor(argument), 0)
            local value = math.floor(argument / 60)
            return ("%d:%02d"):format(value, argument % 60)
        end
        local sharedValue73 = getService("Stats")
        zone.drawStats = function()
            local value, w, value2 = context.WH, context.ST, context.MD
            local text, value3 = value and value.wins or 0, value and value.losses or 0
            textControl28.Text = tostring(text)
            textControl29.Text = text + value3 > 0
                    and ("%d%%"):format(math.floor(text / (text + value3) * 100 + 0.5))
                or "-"
            sharedValue67["Runs lost"].Text = tostring(value3)
            text = value and value.run
            local value4, text2 =
                sharedValue67.Dungeon,
                text and tostring(text.dungeon or "?") .. ", " .. tostring(text.difficulty or "?")
                    or (context.LB and context.LB.place == "Lobby" and "in the lobby" or "-")
            value4.Text = text2
            sharedValue67["Run time"].Text = text and text.at and helper183(value.runSecs(text)) or "-"
            sharedValue67.Deaths.Text = text and tostring(text.deaths or 0) or "-"
            text2, value4 = value and value.mobKills or 0, value and value.bossKills or 0
            sharedValue67["Mob kills"].Text = tostring(text2)
            sharedValue67["Boss kills"].Text = tostring(value4)
            if text then
                value, value3 =
                    math.max(text2 - (text.killM or text2), 0), math.max(value4 - (text.killB or value4), 0)
                sharedValue67.Kills.Text = ("%d mob%s, %d boss%s"):format(
                    value,
                    value == 1 and "" or "s",
                    value3,
                    value3 == 1 and "" or "es"
                )
            else
                sharedValue67.Kills.Text = "-"
            end
            text = nil
            value4, value = 0, 0
            for index, entry in ipairs(hazardReader.enemies or {}) do
                if entry.isBoss then
                    value4 = value4 + 1
                else
                    value = value + 1
                end
            end
            text2 = hazardReader.rodinRig
            if text2 then
                if text2.Parent then
                    value3 = text2:FindFirstChildOfClass("Humanoid")
                    text = if value3
                        then if value3.MaxHealth > 0
                            then math.floor(value3.Health / value3.MaxHealth * 100 + 0.5)
                            else text
                        else text
                end
            end
            sharedValue67.Mobs.Text = tostring(value)
            sharedValue67.Bosses.Text = tostring(value4) .. (text and " - Rodin " .. text .. "%" or "")
            value4, value3 = context.DG and context.DG.now or os.clock(), 0
            for index2, entry2 in ipairs(context.DG and context.DG.boxes or {}) do
                value3 = if entry2.attack
                    then if entry2.untilAt
                        then if value4 <= entry2.untilAt then value3 + 1 else value3
                        else value3
                    else value3
            end
            sharedValue67["Enemy attacks"].Text = tostring(value3)
            sharedValue67.Players.Text = tostring(#sharedValue5:GetPlayers())
            local leaderstats = localPlayer:FindFirstChild("leaderstats")
            local function helper6(argument)
                local valueObject = leaderstats and (leaderstats:FindFirstChild(argument))
                return valueObject and valueObject.Value
            end
            sharedValue67.Level.Text = tostring(helper6("Level") or "-")
            sharedValue67.Gold.Text = helper6("Gold") and helper182((helper6("Gold"))) or "-"
            sharedValue67.Gems.Text = helper6("Gems") and helper182((helper6("Gems"))) or "-"
            local value5
            pcall(function()
                value5 = sharedValue73.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            sharedValue67.Ping.Text = value5 and ("%d ms"):format(math.floor(value5 + 0.5)) or "-"
            sharedValue67.FPS.Text = tostring(zone.fps or 0)
            sharedValue67.Doing.Text = os.clock() - (zone.movedAt or -math.huge) < 0.6 and "cooking"
                or "chilling"
            sharedValue67.Queue.Text = tostring(context.LB and context.LB.status or "-")
            text = if config.modDetect == true
                then if value2
                    then value2.hold and value2.left and value2.left() > 0 and "resting, " .. helper183(
                        value2.left()
                    ) .. " left" or "watching"
                    else "off"
                else "off"
            sharedValue67["Mod detection"].Text = text
        end
        local sharedValue74, setMetatable2, sharedValue75 = {}, setmetatable, { __mode = "k" }
        local sharedValue76 = setMetatable2({}, sharedValue75)
        local function helper184(argument, make)
            sharedValue74[argument] = { items = {}, n = 0, make = make }
        end
        helper184("round", function()
            local parent = Instance.new("Frame")
            parent.BorderSizePixel, parent.AnchorPoint = 0, Vector2.new(0.5, 0.5)
            parent.Visible = false
            local value = Instance.new("UICorner")
            value.CornerRadius = UDim.new(1, 0)
            value.Parent = parent
            value = Instance.new("UIStroke")
            value.Enabled = false
            value.Parent = parent
            sharedValue76[parent] = value
            parent.Parent = view
            return parent
        end)
        helper184("rect", function()
            local frame = Instance.new("Frame")
            frame.BorderSizePixel, frame.AnchorPoint = 0, Vector2.new(0.5, 0.5)
            frame.Visible = false
            frame.Parent = view
            return frame
        end)
        helper184("label", function()
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency, label.AnchorPoint, label.Size =
                1, Vector2.new(0, 0.5), UDim2.fromOffset(200, 14)
            label.Visible = false
            label.TextSize, label.TextStrokeTransparency, label.ZIndex, label.TextXAlignment =
                12, 0.35, 9, Enum.TextXAlignment.Left
            uiLibrary.setFont(label, "sans", Enum.FontWeight.Medium)
            if sharedValue41.Medium then
                pcall(function()
                    label.FontFace = sharedValue41.Medium
                end)
            end
            label.Parent = view
            return label
        end)
        helper184("fuse", function()
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency, label.AnchorPoint, label.Size =
                1, Vector2.new(0.5, 1), UDim2.fromOffset(40, 14)
            label.Visible = false
            label.TextSize, label.TextStrokeTransparency, label.ZIndex, label.TextXAlignment =
                13, 0.2, 10, Enum.TextXAlignment.Center
            uiLibrary.setFont(label, "sans", Enum.FontWeight.Bold)
            label.Parent = view
            return label
        end)
        sharedValue75, weakKeys5 = setmetatable, { __mode = "k" }
        local sharedValue77, setMetatable3, weakKeys6 =
            sharedValue75({}, weakKeys5), setmetatable, { __mode = "k" }
        local sharedValue78 = setMetatable3({}, weakKeys6)
        helper184("arc", function()
            local parent = Instance.new("Frame")
            parent.BorderSizePixel, parent.AnchorPoint = 0, Vector2.new(0.5, 0.5)
            parent.Visible = false
            parent.BackgroundTransparency = 1
            local parent2 = Instance.new("UICorner")
            parent2.CornerRadius = UDim.new(1, 0)
            parent2.Parent = parent
            parent2 = Instance.new("UIStroke")
            parent2.Parent = parent
            local gradient = Instance.new("UIGradient")
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.499, 1),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1, 0),
            })
            gradient.Parent = parent2
            sharedValue76[parent] = parent2
            sharedValue77[parent] = gradient
            parent.Parent = view
            return parent
        end)
        helper184("bar", function()
            local parent = Instance.new("Frame")
            parent.BorderSizePixel, parent.AnchorPoint = 0, Vector2.new(0.5, 0)
            parent.Visible = false
            parent.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
            parent.BackgroundTransparency = 0.3
            local fill = Instance.new("Frame")
            fill.Name, fill.BorderSizePixel, fill.Size = "Fill", 0, UDim2.fromScale(1, 1)
            fill.Parent = parent
            sharedValue78[parent] = fill
            parent.Parent = view
            return parent
        end)
        local function helper185(argument)
            local value = sharedValue74[argument]
            value.n = value.n + 1
            argument = value.items[value.n]
            if not argument then
                argument = value.make()
                value.items[value.n] = argument
            end
            return argument
        end
        local function helper186()
            for key, entry in pairs(sharedValue74) do
                key = entry.items
                for index = 1, #key, 1 do
                    local visible = index <= entry.n
                    if key[index].Visible ~= visible then
                        key[index].Visible = visible
                    end
                end
                entry.n = 0
            end
        end
        local sharedValue79, sharedValue80, sharedValue81, sharedValue82, sharedValue83 = 0, 0, 0, 0, 1
        local function helper187(argument, argument2)
            local value, value2, value3 =
                sharedValue79 * 0.5 + (argument - sharedValue81) * sharedValue83,
                sharedValue80 * 0.5,
                (argument2 - sharedValue82) * sharedValue83
            return value, value2 + value3
        end
        local function helper188(argument, argument2, argument3)
            local value = argument + argument3 >= 0
                and argument - argument3 <= sharedValue79
                and argument2 + argument3 >= 0
                and argument2 - argument3 <= sharedValue80
            return value
        end
        local function helper189(argument, argument2, argument3, argument4, argument5, zIndex, thickness)
            local value, value2 = helper187(argument, argument2)
            if not (helper188(value, value2, argument3)) then
                return
            end
            argument = helper185("round")
            argument.Position, argument.Size =
                UDim2.fromOffset(value, value2), UDim2.fromOffset(argument3 * 2, argument3 * 2)
            argument.ZIndex = zIndex
            argument2 = sharedValue76[argument]
            if thickness then
                argument.BackgroundTransparency = 1
                argument2.Enabled = true
                argument2.Color = argument4
                argument2.Thickness = thickness
                argument2.Transparency = argument5
            else
                argument.BackgroundColor3 = argument4
                argument.BackgroundTransparency = argument5
                if argument2.Enabled then
                    argument2.Enabled = false
                end
            end
        end
        local function helper190(
            argument,
            argument2,
            argument3,
            argument4,
            argument5,
            backgroundColor3,
            backgroundTransparency,
            zIndex
        )
            local value, value2 = helper187(argument, argument2)
            argument2, argument =
                math.max(argument3 * 2 * sharedValue83, 1), math.max(argument4 * 2 * sharedValue83, 1)
            if not (helper188(value, value2, math.max(argument2, argument))) then
                return
            end
            argument4 = helper185("rect")
            argument4.Position, argument4.Size, argument4.Rotation =
                UDim2.fromOffset(value, value2), UDim2.fromOffset(argument2, argument), math.deg(argument5)
            argument4.ZIndex = zIndex
            argument4.BackgroundColor3 = backgroundColor3
            argument4.BackgroundTransparency = backgroundTransparency
        end
        local function helper191(argument, argument2, text, textColor3, argument3)
            local value, value2 = helper187(argument, argument2)
            if not (helper188(value, value2, 80)) then
                return
            end
            argument2 = helper185("label")
            argument2.Position = UDim2.fromOffset(value + argument3 + 4, value2)
            argument2.Text = text
            argument2.TextColor3 = textColor3
        end
        local red = theme2.Red
        local purple = theme2.Purple
        local white = theme2.White
        local blue = theme2.Blue
        local orb = theme2.Orb
        local color2 = Color3.fromRGB(110, 116, 132)
        local function helper192()
            local value = localPlayer.Character
            local value2 = value and (value:FindFirstChild("HumanoidRootPart"))
            if value2 then
                zone.cx, zone.cy, zone.cz = value2.Position.X, value2.Position.Y, value2.Position.Z
            end
            if not zone.cx then
                return false
            end
            value2 = view.AbsoluteSize
            if config.mapFollow == false then
                local value3, value4, value5 = zone.anchor(), value2.X, value2.Y
                local value6, value7 = value3.x, value3.z
                sharedValue79, sharedValue80, sharedValue81, sharedValue82 = value4, value5, value6, value7
            else
                local value8, value9, value10 = zone.big and zone.freeAt or nil, value2.X, value2.Y
                local value11, value12 = value8 and value8.x or zone.cx, value8 and value8.z or zone.cz
                sharedValue79, sharedValue80, sharedValue81, sharedValue82 = value9, value10, value11, value12
            end
            value = zone.big and (config.minimapBigRange or 160) or (config.minimapRange or 110)
            sharedValue83 = math.min(sharedValue79, sharedValue80)
                * 0.5
                / value
                * (zone.big and zone.zoomB or zone.zoomS)
            value2 = sharedValue83
            return value2 > 0
        end
        local function helper193(argument, argument2, argument3, argument4)
            local transform, size, value = argument.CFrame, argument.Size, argument:IsA("Part")
            local value2 = value and argument.Shape or nil
            if value2 == Enum.PartType.Ball then
                helper189(
                    transform.X,
                    transform.Z,
                    math.max(size.X * 0.5 * sharedValue83, 2),
                    argument2,
                    argument3,
                    argument4
                )
                return
            end
            local rightVector, upVector, lookVector =
                transform.RightVector, transform.UpVector, transform.LookVector
            if value2 == Enum.PartType.Cylinder then
                if math.abs(rightVector.Y) > 0.7 then
                    helper189(
                        transform.X,
                        transform.Z,
                        math.max(math.min(size.Y, size.Z) * 0.5 * sharedValue83, 2),
                        argument2,
                        argument3,
                        argument4
                    )
                else
                    helper190(
                        transform.X,
                        transform.Z,
                        size.X * 0.5,
                        math.min(size.Y, size.Z) * 0.5,
                        math.atan2(rightVector.Z, rightVector.X),
                        argument2,
                        argument3,
                        argument4
                    )
                end
                return
            end
            local value3, value4, value5 =
                math.abs(rightVector.Y), math.abs(upVector.Y), math.abs(lookVector.Y)
            local value6, value7, value8
            if value4 >= value3 and value4 >= value5 then
                value6, value7, value8 = rightVector, size.X * 0.5, size.Z * 0.5
            else
                if value3 >= value5 then
                    value6, value7, value8 = upVector, size.Y * 0.5, size.Z * 0.5
                else
                    value6, value7, value8 = rightVector, size.X * 0.5, size.Y * 0.5
                end
            end
            if if value then argument:FindFirstChildOfClass("SpecialMesh") ~= nil else not value then
                if value7 > 1 then
                    if value8 > 1 then
                        if math.abs(value7 - value8) <= math.max(value7, value8) * 0.1 then
                            helper189(
                                transform.X,
                                transform.Z,
                                math.max(value7, value8) * sharedValue83,
                                argument2,
                                argument3,
                                argument4
                            )
                            return
                        end
                    end
                end
            end
            helper190(
                transform.X,
                transform.Z,
                value7,
                value8,
                math.atan2(value6.Z, value6.X),
                argument2,
                argument3,
                argument4
            )
        end
        local function helper194(
            argument,
            argument2,
            argument3,
            argument4,
            argument5,
            color,
            transparency,
            zIndex
        )
            local value, value2 = helper187(argument, argument2)
            if not (helper188(value, value2, argument3 * sharedValue83)) then
                return
            end
            argument2, argument = math.max((argument3 - argument4) * sharedValue83, 1), helper185("arc")
            argument.Position, argument.Size =
                UDim2.fromOffset(value, value2), UDim2.fromOffset(argument2 * 2, argument2 * 2)
            argument.ZIndex = zIndex
            value2 = sharedValue76[argument]
            value2.Color, value2.Thickness = color, math.max(argument4 * sharedValue83, 1)
            value2.Transparency = transparency
            sharedValue77[argument].Rotation = math.deg(argument5)
        end
        zone.clearMarks = function()
            for key, entry in pairs(sharedValue74) do
                entry.n = 0
            end
            helper186()
        end
        zone.fuse3 = {}
        zone.drawFuse3D = function(argument)
            local value, camera = 0, workspaceService.CurrentCamera
            if argument then
                if config.orbFuseLabels ~= false then
                    if hazardReader.orbScan then
                        if camera then
                            local absolutePosition, value2, now, value3 =
                                view.AbsolutePosition, {}, os.clock(), value
                            for index, entry in ipairs(hazardReader.orbScan) do
                                index = entry.part
                                entry = index and hazardReader.parts[index]
                                if index then
                                    if index.Parent then
                                        if entry then
                                            if entry.spawn then
                                                if not value2[index] then
                                                    value2[index] = true
                                                    local vector, value4 = camera:WorldToScreenPoint(
                                                        index.Position + Vector3.new(0, 3.5, 0)
                                                    )
                                                    if value4 then
                                                        local value5 = value3 + 1
                                                        local hlFuse3D = zone.fuse3[value5]
                                                        if not hlFuse3D then
                                                            hlFuse3D = Instance.new("TextLabel")
                                                            hlFuse3D.Name = "HLFuse3D"
                                                            hlFuse3D.BackgroundTransparency, hlFuse3D.AnchorPoint, hlFuse3D.Size =
                                                                1,
                                                                Vector2.new(0.5, 1),
                                                                UDim2.fromOffset(44, 16)
                                                            hlFuse3D.TextSize = 15
                                                            hlFuse3D.TextStrokeTransparency = 0.15
                                                            hlFuse3D.ZIndex = 12
                                                            hlFuse3D.Font = Enum.Font.GothamBold
                                                            hlFuse3D.Parent = view
                                                            zone.fuse3[value5] = hlFuse3D
                                                        end
                                                        local value6, value7 =
                                                            math.max(
                                                                (config.orbFuse or 20) - (now - entry.spawn),
                                                                0
                                                            ),
                                                            string.lower(index.Name)
                                                        hlFuse3D.TextColor3 = value7:find("red", 1, true)
                                                                and Color3.fromRGB(255, 90, 90)
                                                            or value7:find("green", 1, true) and Color3.fromRGB(
                                                                90,
                                                                255,
                                                                90
                                                            )
                                                            or value7:find("yellow", 1, true) and Color3.fromRGB(
                                                                255,
                                                                235,
                                                                60
                                                            )
                                                            or Color3.new(1, 1, 1)
                                                        hlFuse3D.Text = value6 < 5 and ("%.1f"):format(value6)
                                                            or ("%.0f"):format(value6)
                                                        hlFuse3D.Position = UDim2.fromOffset(
                                                            vector.X - absolutePosition.X,
                                                            vector.Y - absolutePosition.Y
                                                        )
                                                        if not hlFuse3D.Visible then
                                                            hlFuse3D.Visible = true
                                                        end
                                                        value3 = value5
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            value = value3
                        end
                    end
                end
            end
            for index2 = value + 1, #zone.fuse3, 1 do
                if zone.fuse3[index2].Visible then
                    zone.fuse3[index2].Visible = false
                end
            end
        end
        local function helper195(
            argument,
            argument2,
            argument3,
            argument4,
            backgroundColor3,
            argument5,
            zIndex
        )
            local value, value2 = helper187(argument, argument2)
            if not (helper188(value, value2, argument5)) then
                return
            end
            argument = helper185("bar")
            argument.Position, argument.Size =
                UDim2.fromOffset(value, value2 + argument3 + 3), UDim2.fromOffset(argument5, 3)
            argument.ZIndex = zIndex
            value2 = sharedValue78[argument]
            value2.Size = UDim2.fromScale(math.clamp(argument4, 0, 1), 1)
            value2.BackgroundColor3 = backgroundColor3
            value2.ZIndex = zIndex
        end
        zone.draw = function()
            if not (helper192()) then
                helper186()
                return
            end
            local value, value2 = zone.use3D(), context.DG
            local value3, value4, value5 =
                value2 and value2.now or os.clock(), context.WALLS and context.WALLS.parts, zone.cy or 0
            if value4 and not value then
                for index = 1, math.min(#value4, 400), 1 do
                    local value6 = value4[index]
                    if value6 then
                        if value6.Parent then
                            local transform, size = value6.CFrame, value6.Size
                            index = size.Y * 0.5
                            if math.abs(transform.UpVector.Y) > 0.7 then
                                if transform.Y + index > value5 - 1 then
                                    if transform.Y - index < value5 + 4 then
                                        local rightVector = transform.RightVector
                                        helper190(
                                            transform.X,
                                            transform.Z,
                                            size.X * 0.5,
                                            size.Z * 0.5,
                                            math.atan2(rightVector.Z, rightVector.X),
                                            color2,
                                            0.35,
                                            2
                                        )
                                    end
                                end
                            end
                        end
                    end
                end
            end
            value4 = hazardReader.rodinRig
            if value then
            elseif value4 then
                if value4.Parent then
                    if hazardReader.arenaCentre then
                        value5 = hazardReader.arenaCentre
                        helper189(
                            value5.X,
                            value5.Z,
                            (config.rodinSweepArenaR or 100) * sharedValue83,
                            color2,
                            0.3,
                            2,
                            2
                        )
                    end
                end
            end
            value4 = not value
            if if value then value4 else config.mapCrystals ~= false then
                value5 = workspaceService:FindFirstChild("secondBossCrystals")
                if value5 then
                    local iterateArray, value7 = ipairs, argumentHelpers[108](value5:GetChildren())
                    for key, entry in iterateArray(argumentHelpers:unpackValues(value7)) do
                        key = string.lower(entry.Name)
                        local value8 = key == "red" and Color3.fromRGB(255, 60, 60)
                            or key == "green" and Color3.fromRGB(60, 255, 60)
                            or key == "yellow" and Color3.fromRGB(255, 235, 40)
                        if value8 then
                            if entry:IsA("BasePart") then
                                key = math.max(entry.Size.X * 0.5 * sharedValue83, 6)
                                helper189(entry.Position.X, entry.Position.Z, key, value8, 0.15, 6)
                                helper189(entry.Position.X, entry.Position.Z, key + 3, value8, 0.2, 6, 2)
                            end
                        end
                    end
                end
            end
            if (if value then value4 else config.mapOrbLinks ~= false) and hazardReader.orbScan then
                local function helper6(
                    argument,
                    argument2,
                    argument3,
                    argument4,
                    argument5,
                    argument6,
                    argument7
                )
                    local value9, value10 = argument3 - argument, argument4 - argument2
                    local value11 = math.sqrt(value9 * value9 + value10 * value10)
                    if value11 < 1 then
                        return
                    end
                    helper190(
                        (argument + argument3) * 0.5,
                        (argument2 + argument4) * 0.5,
                        value11 * 0.5,
                        argument6 * 0.5 / math.max(sharedValue83, 0.01),
                        math.atan2(value10, value9),
                        argument5,
                        argument7,
                        4
                    )
                end
                value5 = localPlayer.Character
                local value12, value13, value14 =
                    value5 and (value5:FindFirstChild("HumanoidRootPart")),
                    context.otherRoots and context.otherRoots() or {},
                    {}
                for index2, entry2 in ipairs(hazardReader.orbScan) do
                    index2 = entry2.part
                    local value15 = index2 and hazardReader.parts[index2]
                    if index2 and index2.Parent and value15 and not value14[index2] then
                        value14[index2] = true
                        local position, value16 = index2.Position, entry2.colour
                        local value17 = value16 == "red" and Color3.fromRGB(255, 60, 60)
                            or value16 == "green" and Color3.fromRGB(60, 255, 60)
                            or value16 == "yellow" and Color3.fromRGB(255, 235, 40)
                            or Color3.new(1, 1, 1)
                        if entry2.mine and value12 then
                            value16 = hazardReader.orbNear and hazardReader.orbNear.part == index2
                            helper6(
                                value12.Position.X,
                                value12.Position.Z,
                                position.X,
                                position.Z,
                                value17,
                                value16 and 3 or 2,
                                value16 and 0.05 or 0.35
                            )
                        elseif (value15.stick == "other" or value15.owner == "other") and #value13 > 0 then
                            local value18, value19 = math.huge
                            for index3, entry3 in ipairs(value13) do
                                index3 = (entry3.Position.X - position.X) ^ 2
                                    + (entry3.Position.Z - position.Z) ^ 2
                                if index3 < value18 then
                                    value18, value19 = index3, entry3
                                end
                            end
                            value19 = if value15.lineRoot
                                then if value15.lineRoot.Parent then value15.lineRoot else value19
                                else value19
                            if value19 then
                                helper6(
                                    value19.Position.X,
                                    value19.Position.Z,
                                    position.X,
                                    position.Z,
                                    Color3.fromRGB(150, 155, 170),
                                    1,
                                    0.45
                                )
                            end
                        end
                    end
                end
            end
            if (if value then value4 else config.orbFuseLabels ~= false) and hazardReader.orbScan then
                local value20, now, iterateArray2, orbScan = {}, os.clock(), ipairs, hazardReader.orbScan
                for key2, entry4 in iterateArray2(orbScan) do
                    value5 = entry4.part
                    key2 = value5 and hazardReader.parts[value5]
                    if value5 then
                        if value5.Parent then
                            if key2 then
                                if key2.spawn then
                                    if not value20[value5] then
                                        value20[value5] = true
                                        local value21, value22, value23 =
                                            math.max((config.orbFuse or 20) - (now - key2.spawn), 0),
                                            helper187(value5.Position.X, value5.Position.Z)
                                        if helper188(value22, value23, 20) then
                                            entry4 = string.lower(value5.Name)
                                            local textColor3, textControl =
                                                entry4:find("red", 1, true) and Color3.fromRGB(255, 90, 90)
                                                    or entry4:find("green", 1, true) and Color3.fromRGB(
                                                        90,
                                                        255,
                                                        90
                                                    )
                                                    or entry4:find("yellow", 1, true) and Color3.fromRGB(
                                                        255,
                                                        235,
                                                        60
                                                    )
                                                    or Color3.new(1, 1, 1),
                                                helper185("fuse")
                                            textControl.Position = UDim2.fromOffset(
                                                value22,
                                                value23 - math.max(3 * sharedValue83, 5) - 3
                                            )
                                            textControl.Text = value21 < 5 and ("%.1f"):format(value21)
                                                or ("%.0f"):format(value21)
                                            textControl.TextColor3 = textColor3
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if
                value
                and config.orbFuseLabels ~= false
                and hazardReader.orbScan
                and workspaceService.CurrentCamera
            then
                local camera, absolutePosition, value24, now2 =
                    workspaceService.CurrentCamera, view.AbsolutePosition, {}, os.clock()
                for index4, entry5 in ipairs(hazardReader.orbScan) do
                    value5 = entry5.part
                    index4 = value5 and hazardReader.parts[value5]
                    if value5 then
                        if value5.Parent then
                            if index4 then
                                if index4.spawn then
                                    if not value24[value5] then
                                        value24[value5] = true
                                        local vector, value25 = camera:WorldToScreenPoint(
                                            value5.Position + Vector3.new(0, 3.5, 0)
                                        )
                                        if value25 then
                                            local value26, value27 =
                                                math.max((config.orbFuse or 20) - (now2 - index4.spawn), 0),
                                                string.lower(value5.Name)
                                            local textColor32, textControl2 =
                                                value27:find("red", 1, true) and Color3.fromRGB(255, 90, 90)
                                                    or value27:find("green", 1, true) and Color3.fromRGB(
                                                        90,
                                                        255,
                                                        90
                                                    )
                                                    or value27:find("yellow", 1, true) and Color3.fromRGB(
                                                        255,
                                                        235,
                                                        60
                                                    )
                                                    or Color3.new(1, 1, 1),
                                                helper185("fuse")
                                            textControl2.Position = UDim2.fromOffset(
                                                vector.X - absolutePosition.X,
                                                vector.Y - absolutePosition.Y
                                            )
                                            textControl2.Text = value26 < 5 and ("%.1f"):format(value26)
                                                or ("%.0f"):format(value26)
                                            textControl2.TextColor3 = textColor32
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            local value28, value29, value30 =
                config.colorLive or Color3.fromRGB(255, 50, 50),
                config.colorSoon or Color3.fromRGB(255, 220, 40),
                context.attackColourNow()
            if value30 then
                value28, value29 = value30, value30
            end
            if not value then
                local value31, value32, value33, value34, value35 =
                    0.4, 0.6, 0.35, value2 and value2.boxes or {}, config.minimapMaxAttacks or 250
                value30, value5 = #value34, 0
                for index5 = 1, value30, 1 do
                    if value5 >= value35 then
                        break
                    end
                    local zone2 = value34[index5]
                    if zone2.attack then
                        if zone2.untilAt then
                            if value3 <= zone2.untilAt then
                                if not zone2.gsNoDraw then
                                    local value36, src = value5 + 1, zone2.src
                                    if src and src.Parent and src:IsA("BasePart") then
                                        local value37, value38 =
                                            zone2.moving or value3 >= (zone2.from or value3),
                                            string.lower(src.Name)
                                        index5 = if value38:find("secondboss", 1, true)
                                                and value38:find("orb", 1, true)
                                            then value38:find("red", 1, true) and Color3.fromRGB(255, 60, 60)
                                                or value38:find("green", 1, true) and Color3.fromRGB(
                                                    60,
                                                    255,
                                                    60
                                                )
                                                or value38:find("yellow", 1, true) and Color3.fromRGB(
                                                    255,
                                                    235,
                                                    40
                                                )
                                                or nil
                                            else if value38:find("bouncingorbbad", 1, true)
                                                then if config.mapRodinRedOrb ~= false
                                                    then Color3.fromRGB(255, 30, 30)
                                                    else nil
                                                else nil
                                        helper193(
                                            src,
                                            index5 or (value37 and value28 or value29),
                                            index5 and 0.1
                                                or (
                                                    zone2.moving and value33
                                                    or (value37 and value31 or value32)
                                                ),
                                            value37 and 4 or 3
                                        )
                                    elseif zone2.moving then
                                        local value39 = (zone2.offset or 0)
                                            + (zone2.speed or 0)
                                                * math.max(value3 - (zone2.pathStart or value3), 0)
                                        value39 = if zone2.endAlong
                                            then if value39 > zone2.endAlong then zone2.endAlong else value39
                                            else value39
                                        local value40, value41, value42 =
                                            zone2.ox + zone2.dx * value39,
                                            zone2.oz + zone2.dz * value39,
                                            string.lower(tostring(zone2.name or ""))
                                        local value43 = if value42:find("secondboss", 1, true)
                                            then if value42:find("orb", 1, true)
                                                then value42:find("red", 1, true) and Color3.fromRGB(
                                                    255,
                                                    60,
                                                    60
                                                ) or value42:find(
                                                    "green",
                                                    1,
                                                    true
                                                ) and Color3.fromRGB(
                                                    60,
                                                    255,
                                                    60
                                                ) or value42:find(
                                                    "yellow",
                                                    1,
                                                    true
                                                ) and Color3.fromRGB(
                                                    255,
                                                    235,
                                                    40
                                                ) or nil
                                                else nil
                                            else nil
                                        if value43 then
                                            helper189(
                                                value40,
                                                value41,
                                                math.max((zone2.r or 3) * sharedValue83, 5),
                                                value43,
                                                0,
                                                7
                                            )
                                            helper189(
                                                value40,
                                                value41,
                                                math.max((zone2.r or 3) * sharedValue83, 5) + 2,
                                                Color3.new(1, 1, 1),
                                                0.3,
                                                7,
                                                1
                                            )
                                        else
                                            local value44 = (
                                                value42:find("bouncingorbbad", 1, true)
                                                or value42:find("red orb", 1, true)
                                            )
                                                    and config.mapRodinRedOrb ~= false
                                                    and Color3.fromRGB(255, 30, 30)
                                                or value28
                                            if zone2.r then
                                                helper189(
                                                    value40,
                                                    value41,
                                                    math.max(zone2.r * sharedValue83, 2),
                                                    value44,
                                                    value33,
                                                    4
                                                )
                                            else
                                                helper190(
                                                    value40,
                                                    value41,
                                                    zone2.halfL or 1,
                                                    zone2.halfW or 1,
                                                    math.atan2(zone2.dz, zone2.dx),
                                                    value44,
                                                    value33,
                                                    4
                                                )
                                            end
                                        end
                                    elseif zone2.cx then
                                        local value45 = value3 >= (zone2.from or value3)
                                        local value46, value47 =
                                            value45 and value28 or value29, value45 and value31 or value32
                                        if zone2.r then
                                            if zone2.ring then
                                                helper189(
                                                    zone2.cx,
                                                    zone2.cz,
                                                    (zone2.r + zone2.ring) * 0.5 * sharedValue83,
                                                    value46,
                                                    value47,
                                                    3,
                                                    math.max((zone2.r - zone2.ring) * sharedValue83, 1)
                                                )
                                            else
                                                helper189(
                                                    zone2.cx,
                                                    zone2.cz,
                                                    math.max(zone2.r * sharedValue83, 2),
                                                    value46,
                                                    value47,
                                                    3
                                                )
                                            end
                                        elseif zone2.ha then
                                            helper190(
                                                zone2.cx,
                                                zone2.cz,
                                                zone2.ha,
                                                zone2.hb,
                                                math.atan2(zone2.az, zone2.ax),
                                                value46,
                                                value47,
                                                3
                                            )
                                        end
                                    end
                                    value5 = value36
                                end
                            end
                        end
                    end
                end
                if config.mapPkZones ~= false and context.PK and context.isEvent and context.isEvent() then
                    value33 = #value34
                    for index6 = 1, value33, 1 do
                        value35 = value34[index6]
                        index6 = value35.name
                        if value35.kind == "zone" then
                            if type(index6) == "string" then
                                if index6:sub(1, 3) == "pk " then
                                    if index6 ~= "pk border" then
                                        if value35.untilAt then
                                            if value3 <= value35.untilAt then
                                                if value35.cx then
                                                    local value48 = value3 >= (value35.from or value3)
                                                    local value49, value50 =
                                                        value48 and value28 or value29,
                                                        value48 and value31 or value32
                                                    if value35.r then
                                                        if value35.ring then
                                                            helper189(
                                                                value35.cx,
                                                                value35.cz,
                                                                (value35.r + value35.ring)
                                                                    * 0.5
                                                                    * sharedValue83,
                                                                value49,
                                                                value50,
                                                                3,
                                                                math.max(
                                                                    (value35.r - value35.ring) * sharedValue83,
                                                                    1
                                                                )
                                                            )
                                                        else
                                                            helper189(
                                                                value35.cx,
                                                                value35.cz,
                                                                math.max(value35.r * sharedValue83, 2),
                                                                value49,
                                                                value50,
                                                                3
                                                            )
                                                        end
                                                    elseif value35.ha then
                                                        helper190(
                                                            value35.cx,
                                                            value35.cz,
                                                            value35.ha,
                                                            value35.hb,
                                                            math.atan2(value35.az, value35.ax),
                                                            value49,
                                                            value50,
                                                            3
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
                    local value51 = workspaceService:FindFirstChild("BossBarriers")
                    if value51 then
                        for index7, child in ipairs(value51:GetChildren()) do
                            if child:IsA("BasePart") then
                                helper193(child, color2, 0.05, 2)
                            end
                        end
                    end
                    value51 = context.PK.arena and context.PK.arena()
                    local value52 = value51 and context.PK.thornDepth and context.PK.thornDepth() or 0
                    if value51 then
                        if value52 > 0 then
                            local value53, value54, value55, value56 =
                                value51.x0, value51.x1, value51.z0, value51.z1
                            local value57, value58, value59, value60 =
                                (value53 + value54) * 0.5,
                                (value55 + value56) * 0.5,
                                (value54 - value53) * 0.5,
                                (value56 - value55) * 0.5
                            helper190(
                                value53 + value52 * 0.5,
                                value58,
                                value52 * 0.5,
                                value60,
                                0,
                                value28,
                                value31,
                                3
                            )
                            helper190(
                                value54 - value52 * 0.5,
                                value58,
                                value52 * 0.5,
                                value60,
                                0,
                                value28,
                                value31,
                                3
                            )
                            helper190(
                                value57,
                                value55 + value52 * 0.5,
                                value59,
                                value52 * 0.5,
                                0,
                                value28,
                                value31,
                                3
                            )
                            helper190(
                                value57,
                                value56 - value52 * 0.5,
                                value59,
                                value52 * 0.5,
                                0,
                                value28,
                                value31,
                                3
                            )
                        end
                    end
                end
                value35 = hazardReader.spikePaths
                if value35 and config.mapSpikePaths ~= false then
                    local now3, value61, value62 = os.clock(), #value35, 0
                    for index8 = value61, 1, -1 do
                        value33 = value35[index8]
                        if now3 <= value33.t1 then
                            if value62 < (config.mapSpikePathMax or 24) then
                                index8 = math.clamp(value33.speed * (now3 - value33.t0), 0, value33.len)
                                value34 = value33.len - index8
                                if value34 > 2 then
                                    local value63, value64, value65, value66, value67 =
                                        value62 + 1,
                                        value33.ox + value33.dx * index8,
                                        value33.oz + value33.dz * index8,
                                        math.atan2(value33.dz, value33.dx),
                                        math.max(1.2 / sharedValue83, 0.6)
                                    helper190(
                                        value64 + value33.dx * value34 * 0.5,
                                        value65 + value33.dz * value34 * 0.5,
                                        value34 * 0.5,
                                        value67,
                                        value66,
                                        value28,
                                        0.6,
                                        3
                                    )
                                    local value68 = config.mapSpikeArrowEvery or 30
                                    local value69 = value68 - index8 % value68
                                    while value69 < value34 - 4 do
                                        local value70, value71, value72 =
                                            value64 + value33.dx * value69,
                                            value65 + value33.dz * value69,
                                            { 1, -1 }
                                        for index9, entry6 in ipairs(value72) do
                                            index9 = value66 + 3.141592653589793 + entry6 * 0.6
                                            helper190(
                                                value70 + math.cos(index9) * 2.5,
                                                value71 + math.sin(index9) * 2.5,
                                                2.5,
                                                value67,
                                                index9,
                                                value28,
                                                0.3,
                                                3
                                            )
                                        end
                                        value69 += value68
                                    end
                                    value62 = value63
                                end
                            end
                        end
                    end
                end
                if workspaceService:FindFirstChild("thirdBossMultiRings") then
                    value35, value34 = ipairs, argumentHelpers[108](workspaceService:GetChildren())
                    for key3, entry7 in value35(argumentHelpers:unpackValues(value34)) do
                        if entry7.Name == "thirdBossMultiRings" then
                            key3, value33 = ipairs, argumentHelpers[108](entry7:GetChildren())
                            for key4, entry8 in key3(argumentHelpers:unpackValues(value33)) do
                                if entry8:IsA("BasePart") then
                                    if entry8.Transparency < 0.95 then
                                        key4 = string.lower(entry8.Name)
                                        if key4 == "ring" and entry8.Size.X > 20 then
                                            local lookVector = entry8.CFrame.LookVector
                                            local value73 = math.sqrt(
                                                lookVector.X * lookVector.X + lookVector.Z * lookVector.Z
                                            )
                                            if value73 > 0.01 then
                                                local value74, value75, position2, value76 =
                                                    lookVector.X / value73,
                                                    lookVector.Z / value73,
                                                    entry8.Position,
                                                    math.max(entry8.Size.X, entry8.Size.Z) * 0.5
                                                local value77 = config.mapRingW
                                                    or (
                                                        value76 >= 100
                                                            and (config.ringThicknessOuter or 17.5)
                                                        or (config.ringThickness or 12.5)
                                                    )
                                                helper194(
                                                    position2.X - value74 * entry8.Size.X * 0.25,
                                                    position2.Z - value75 * entry8.Size.X * 0.25,
                                                    entry8.Size.X * 0.5,
                                                    value77,
                                                    math.atan2(value75, value74),
                                                    value28,
                                                    value31,
                                                    3
                                                )
                                            end
                                        elseif key4 == "center" then
                                            local position3 = entry8.Position
                                            helper189(
                                                position3.X,
                                                position3.Z,
                                                math.max(
                                                    math.max(entry8.Size.Y, entry8.Size.Z)
                                                        * 0.5
                                                        * sharedValue83,
                                                    2
                                                ),
                                                value28,
                                                value31,
                                                3
                                            )
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                value34 = workspaceService:FindFirstChild("bonusBossSweepingFlames")
                if value34 then
                    for index10, child2 in ipairs(value34:GetChildren()) do
                        value35 = child2:FindFirstChild("precast")
                        if value35 then
                            if value35:IsA("BasePart") then
                                if value35.Transparency < 0.9 then
                                    child2 = value35.Transparency < 0.5
                                    helper193(
                                        value35,
                                        child2 and value28 or value29,
                                        child2 and value31 or value32,
                                        child2 and 4 or 3
                                    )
                                end
                            end
                        end
                    end
                end
            end
            value = hazardReader.rodinGoodOrbs
            if value and value4 then
                for entry9 in pairs(value) do
                    if typeof(entry9) == "Instance" then
                        if entry9.Parent then
                            if entry9:IsA("BasePart") then
                                value5, value2 =
                                    entry9.Position, math.max(entry9.Size.X * 0.5 * sharedValue83, 3)
                                helper189(value5.X, value5.Z, value2, orb, 0.15, 5)
                            end
                        end
                    end
                end
            end
            value3, value2, value4 =
                zone.big and config.mapNames ~= false,
                zone.big and config.mapHealthBars ~= false,
                hazardReader.enemies or {}
            value30 = math.min(#value4, 150)
            for index11 = 1, value30, 1 do
                value = value4[index11]
                value5, index11 = value.x, value.z
                if value.root then
                    if value.root.Parent then
                        local position4 = value.root.Position
                        local value78, value79 = position4.X, position4.Z
                        value5, index11 = value78, value79
                    end
                end
                if value5 then
                    if index11 then
                        local value80, value81 =
                            value.isBoss and purple or red,
                            value.isBoss and math.max((value.extent or 3) * sharedValue83, 6) or math.max(
                                (value.extent or 1.5) * sharedValue83,
                                3
                            )
                        helper189(value5, index11, value81, value80, value.isBoss and 0.05 or 0.1, 6)
                        if value3 then
                            if value.model then
                                helper191(value5, index11, value.model.Name, value80, value81)
                            end
                        end
                        local humanoid = value.humanoid
                        if value2 then
                            if humanoid then
                                if humanoid.MaxHealth > 0 then
                                    helper195(
                                        value5,
                                        index11,
                                        value81,
                                        humanoid.Health / humanoid.MaxHealth,
                                        value80,
                                        value.isBoss and 34 or 18,
                                        6
                                    )
                                end
                            end
                        end
                    end
                end
            end
            value4, value5 = ipairs, argumentHelpers[108](sharedValue5:GetPlayers())
            for key5, entry10 in value4(argumentHelpers:unpackValues(value5)) do
                value30 = entry10.Character
                value = value30 and (value30:FindFirstChild("HumanoidRootPart"))
                if value then
                    local position5, humanoid2 = value.Position, value30:FindFirstChildOfClass("Humanoid")
                    if entry10 == localPlayer then
                        key5 = value.CFrame.LookVector
                        local value82 = math.sqrt(key5.X * key5.X + key5.Z * key5.Z)
                        if value82 > 0.1 then
                            local value83 = math.max(10 / sharedValue83, 4)
                            helper190(
                                position5.X + key5.X / value82 * value83 * 0.5,
                                position5.Z + key5.Z / value82 * value83 * 0.5,
                                value83 * 0.5,
                                1 / sharedValue83,
                                math.atan2(key5.Z, key5.X),
                                white,
                                0,
                                8
                            )
                        end
                        helper189(position5.X, position5.Z, 5, white, 0, 8)
                        if value3 then
                            helper191(position5.X, position5.Z, "YOU", white, 5)
                        end
                        if value2 then
                            if humanoid2 then
                                if humanoid2.MaxHealth > 0 then
                                    helper195(
                                        position5.X,
                                        position5.Z,
                                        5,
                                        humanoid2.Health / humanoid2.MaxHealth,
                                        white,
                                        26,
                                        8
                                    )
                                end
                            end
                        end
                    else
                        helper189(position5.X, position5.Z, 4.5, blue, 0, 7)
                        if value3 then
                            if config.streamer ~= true then
                                helper191(position5.X, position5.Z, entry10.Name, blue, 4.5)
                            end
                        end
                        if value2 then
                            if humanoid2 then
                                if humanoid2.MaxHealth > 0 then
                                    helper195(
                                        position5.X,
                                        position5.Z,
                                        4.5,
                                        humanoid2.Health / humanoid2.MaxHealth,
                                        blue,
                                        18,
                                        7
                                    )
                                end
                            end
                        end
                    end
                end
            end
            helper186()
        end
        zone.use3D = function()
            return zone.big == true
                and config.mapBg3D ~= false
                and config.renderOff ~= true
                and not zone.blank()
                and not runtimeState.destroyed
        end
        local sharedValue84, sharedValue85, sharedValue86, sharedValue87 =
            { on = false, orig = {}, conns = {}, gen = 0 }, {
                dungeon = true,
                Map = true,
                map = true,
                Lobby = true,
                lobby = true,
                stairRamps = true,
                thirdBossBounceWalls = true,
                secondBossCrystals = true,
                bossRoomRunes = true,
            }, { NorthernWall = true }, {
                "Grass",
                "Slate",
                "Concrete",
                "Brick",
                "Sand",
                "WoodPlanks",
                "Rock",
                "Glacier",
                "Snow",
                "Sandstone",
                "Mud",
                "Basalt",
                "Ground",
                "CrackedLava",
                "Asphalt",
                "Cobblestone",
                "Ice",
                "LeafyGrass",
                "Salt",
                "Limestone",
                "Pavement",
            }
        local function helper196(argument, argument2, argument3)
            local value = sharedValue84.orig[argument]
            if not value then
                value = {}
                sharedValue84.orig[argument] = value
            end
            if value[argument2] == nil then
                local success, value2 = pcall(function()
                    return argument[argument2]
                end)
                if success then
                    if value2 == nil then
                        return
                    end
                else
                    return
                end
                value[argument2] = value2
            end
            pcall(function()
                argument[argument2] = argument3
            end)
        end
        local function helper197(argument)
            if argument:IsA("BasePart") then
                if argument.Transparency >= 0.98 then
                    return
                end
                helper196(
                    argument,
                    "Color",
                    typeof(config.map3DGrey) == "Color3" and config.map3DGrey or Color3.fromRGB(96, 104, 122)
                )
                helper196(argument, "Material", Enum.Material.SmoothPlastic)
                if argument:IsA("MeshPart") then
                    helper196(argument, "TextureID", "")
                end
                if argument:IsA("UnionOperation") then
                    helper196(argument, "UsePartColor", true)
                end
            elseif argument:IsA("Decal") then
                helper196(argument, "Transparency", 1)
            elseif argument:IsA("Texture") then
                helper196(argument, "Transparency", 1)
            elseif argument:IsA("SpecialMesh") then
                helper196(argument, "TextureId", "")
            elseif argument:IsA("SurfaceAppearance") then
                helper196(argument, "Parent", nil)
            end
        end
        local function helper198(argument)
            local value = (argument:FindFirstAncestorOfClass("Model"))
            while value do
                if value:FindFirstChildOfClass("Humanoid") then
                    return true
                end
                value = (value:FindFirstAncestorOfClass("Model"))
            end
            return false
        end
        local function helper199(argument, argument2)
            for index, child in ipairs(argument:GetChildren()) do
                if not (child:IsA("Model") and child:FindFirstChildOfClass("Humanoid")) then
                    argument2[#argument2 + 1] = child
                    helper199(child, argument2)
                end
            end
        end
        sharedValue84.set = function(argument)
            if argument == sharedValue84.on then
                return
            end
            sharedValue84.on = argument
            sharedValue84.gen = sharedValue84.gen + 1
            for index, conn in ipairs(sharedValue84.conns) do
                pcall(conn.Disconnect, conn)
            end
            sharedValue84.conns = {}
            if argument then
                local gen, value = sharedValue84.gen, {}
                for index2, child in ipairs(workspaceService:GetChildren()) do
                    if sharedValue85[child.Name] then
                        helper199(child, value)
                    elseif sharedValue86[child.Name] then
                        if child:IsA("BasePart") then
                            value[#value + 1] = child
                        end
                    end
                end
                local value2 = typeof(config.map3DGrey) == "Color3" and config.map3DGrey
                    or Color3.fromRGB(96, 104, 122)
                local terrain = workspaceService:FindFirstChildOfClass("Terrain")
                if terrain then
                    sharedValue84.tcol = {}
                    for index3, entry in ipairs(sharedValue87) do
                        pcall(function()
                            local value3 = Enum.Material[entry]
                            sharedValue84.tcol[entry] = terrain:GetMaterialColor(value3)
                            terrain:SetMaterialColor(value3, value2)
                        end)
                    end
                end
                for index4, child2 in ipairs(getService("Lighting"):GetChildren()) do
                    if child2:IsA("Atmosphere") then
                        helper196(child2, "Density", config.map3DHaze or 0.12)
                    elseif child2:IsA("DepthOfFieldEffect") then
                        helper196(child2, "Enabled", false)
                    elseif child2:IsA("BlurEffect") then
                        helper196(child2, "Enabled", false)
                    end
                end
                task.spawn(function()
                    for index5 = 1, #value, 1 do
                        if sharedValue84.gen ~= gen then
                            return
                        end
                        pcall(helper197, value[index5])
                        if index5 % 400 == 0 then
                            task.wait()
                        end
                    end
                end)
                for index6, child3 in ipairs(workspaceService:GetChildren()) do
                    if sharedValue85[child3.Name] then
                        sharedValue84.conns[#sharedValue84.conns + 1] = child3.DescendantAdded:Connect(
                            function(argument2)
                                task.defer(function()
                                    if sharedValue84.on then
                                        if sharedValue84.gen == gen then
                                            if argument2.Parent then
                                                if not (helper198(argument2)) then
                                                    pcall(helper197, argument2)
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                        )
                    end
                end
                sharedValue84.conns[#sharedValue84.conns + 1] = workspaceService.ChildAdded:Connect(
                    function(argument2)
                        if sharedValue86[argument2.Name] then
                            task.defer(function()
                                if sharedValue84.on then
                                    if sharedValue84.gen == gen then
                                        if argument2:IsA("BasePart") then
                                            pcall(helper197, argument2)
                                        end
                                    end
                                end
                            end)
                        end
                    end
                )
            else
                for key, entry2 in pairs(sharedValue84.orig) do
                    for key2, entry3 in pairs(entry2) do
                        pcall(function()
                            key[key2] = entry3
                        end)
                    end
                end
                sharedValue84.orig = {}
                local terrain2 = workspaceService:FindFirstChildOfClass("Terrain")
                if terrain2 and sharedValue84.tcol then
                    for key3, entry4 in pairs(sharedValue84.tcol) do
                        pcall(function()
                            terrain2:SetMaterialColor(Enum.Material[key3], entry4)
                        end)
                    end
                end
                sharedValue84.tcol = nil
            end
        end
        local see, setMetatable4, weakKeys7 = {}, setmetatable, { __mode = "k" }
        see.a = setMetatable4({}, weakKeys7)
        see.t = 0
        see.hit = nil
        see.ray = nil
        see.geo = function(argument)
            if argument:IsA("Terrain") then
                return false
            elseif argument.Anchored then
                if argument.CanCollide then
                    if not (argument.Transparency < 0.95) then
                        return false
                    end
                else
                    return false
                end
            else
                return false
            end
            local value = argument
            while value and value ~= workspaceService do
                argument = string.lower(value.Name)
                if argument:find("hitbox", 1, true) then
                    return false
                elseif argument:find("precast", 1, true) then
                    return false
                elseif argument:find("telegraph", 1, true) then
                    return false
                elseif argument:find("warning", 1, true) then
                    return false
                elseif argument:find("safespot", 1, true) then
                    return false
                elseif argument:find("safezone", 1, true) then
                    return false
                elseif argument == "abilities" then
                    return false
                elseif argument == "enemyprojectiles" then
                    return false
                elseif argument == "projectiles" then
                    return false
                elseif argument == "vfxpool" then
                    return false
                elseif argument == "enemypool" then
                    return false
                elseif argument == "sfxpool" then
                    return false
                elseif argument == "enemies" then
                    return false
                elseif argument == "enemyfolder" then
                    return false
                end
                if value:IsA("Model") then
                    if value:FindFirstChildOfClass("Humanoid") then
                        return false
                    end
                end
                value = value.Parent
            end
            return true
        end
        see.clear = function()
            for entry in pairs(see.a) do
                pcall(function()
                    entry.LocalTransparencyModifier = 0
                end)
                see.a[entry] = nil
            end
            see.hit = nil
        end
        see.step = function(argument, argument2, argument3)
            see.t = see.t + argument
            if see.t >= 0.05 or not see.hit then
                see.t = 0
                local hit2 = {}
                see.ray = see.ray or RaycastParams.new()
                see.ray.FilterType = Enum.RaycastFilterType.Exclude
                see.ray.FilterDescendantsInstances = { localPlayer.Character }
                local position, value, value2 = argument2.CFrame.Position, {}, { 2, 0, -1.5 }
                for index, entry in ipairs(value2) do
                    value[#value + 1] = (argument3 + Vector3.new(0, entry, 0) - position).Unit
                end
                local value3, value4 =
                    view.AbsolutePosition + getService("GuiService"):GetGuiInset(), view.AbsoluteSize
                for index2 = 0, 7, 1 do
                    for index3 = 0, 4, 1 do
                        value[#value + 1] = argument2:ViewportPointToRay(
                            value3.X + value4.X * (index2 + 0.5) / 8,
                            value3.Y + value4.Y * (index3 + 0.5) / 5
                        ).Direction.Unit
                    end
                end
                value2 = (argument3 - position).Magnitude + 3
                for index4, entry2 in ipairs(value) do
                    index4, value3 = position, value2
                    for index5 = 1, 5, 1 do
                        index5 = workspaceService:Raycast(index4, entry2 * value3, see.ray)
                        if not index5 then
                            break
                        end
                        value4 = index5.Instance
                        if value4:IsA("Terrain") then
                            break
                        end
                        if see.geo(value4) then
                            if index5.Normal.Y > 0.7 then
                                if index5.Position.Y < argument3.Y + 4 then
                                    break
                                elseif math.min(value4.Size.X, value4.Size.Z) < 10 then
                                    break
                                end
                            end
                            hit2[value4] = true
                        end
                        value3 -= (index5.Position - index4).Magnitude + 0.05
                        if value3 <= 0 then
                            break
                        end
                        index4 = index5.Position + entry2 * 0.05
                    end
                end
                for index6, entry3 in ipairs(workspaceService:GetPartBoundsInRadius(position, 1)) do
                    if see.geo(entry3) then
                        hit2[entry3] = true
                    end
                end
                see.hit = hit2
            end
            for entry4 in pairs(see.hit) do
                if not see.a[entry4] then
                    see.a[entry4] = 0
                end
            end
            argument3 = math.min(1, argument * 8)
            for key, entry5 in pairs(see.a) do
                argument = see.hit[key] and (config.map3DSeeAlpha or 0.72) or 0
                entry5 += (argument - entry5) * argument3
                if argument == 0 and entry5 < 0.02 then
                    see.a[key] = nil
                    pcall(function()
                        key.LocalTransparencyModifier = 0
                    end)
                else
                    see.a[key] = entry5
                    pcall(function()
                        key.LocalTransparencyModifier = entry5
                    end)
                end
            end
        end
        zone.see = see
        local sharedValue88 = { on = false, fov = 70 }
        local function helper200(argument)
            if not sharedValue88.on then
                return
            end
            local camera = workspaceService.CurrentCamera
            if camera then
                if not (helper192()) then
                    return
                end
            else
                return
            end
            local viewportSize, camCur = camera.ViewportSize, config.map3DFov or 50
            local value, value2 =
                viewportSize.Y * 0.5 / math.tan(math.rad(camCur) * 0.5), config.map3DMaxH or 1200
            local value3, value4 = value / sharedValue83 * math.clamp(tonumber(config.map3DZoom) or 1, 0.2, 6)
            if value3 > value2 then
                value3, value4 =
                    value2,
                    math.min(math.deg(2 * math.atan(math.tan(math.rad(camCur) * 0.5) * value3 / value2)), 110)
            else
                value4 = camCur
            end
            value, value2 = zone.camShot(os.clock())
            camCur = zone.camCur
            if not camCur then
                camCur = { p = value, y = value2, d = value3, f = value4 }
                zone.camCur = camCur
            end
            local value5 = 1 - math.exp(-(tonumber(argument) or 0.016) * 5)
            camCur.p = camCur.p + (value - camCur.p) * value5
            camCur.y = (camCur.y + ((value2 - camCur.y + 180) % 360 - 180) * value5) % 360
            camCur.d = camCur.d + (value3 - camCur.d) * math.min(1, value5 * 2)
            camCur.f = camCur.f + (value4 - camCur.f) * math.min(1, value5 * 2)
            value, value5 =
                view.AbsolutePosition + getService("GuiService"):GetGuiInset(),
                camCur.d * math.tan(math.rad(camCur.f) * 0.5) / math.max(viewportSize.Y * 0.5, 1)
            local value6, value7, value8, value9 =
                (value.X + sharedValue79 * 0.5 - viewportSize.X * 0.5) * value5,
                (value.Y + sharedValue80 * 0.5 - viewportSize.Y * 0.5) * value5,
                math.rad(camCur.y),
                sharedValue81
            value2, value5 = value9 - math.cos(value8) * value6 - math.sin(value8) * value7, sharedValue82
            local value10, value11 =
                value5 + math.sin(value8) * value6 - math.cos(value8) * value7,
                (zone.cy or 0) - (config.map3DGroundDrop or 3)
            if camera.CameraType ~= Enum.CameraType.Scriptable then
                camera.CameraType = Enum.CameraType.Scriptable
            end
            if math.abs(camera.FieldOfView - camCur.f) > 0.01 then
                camera.FieldOfView = camCur.f
            end
            value7 = Vector3.new(value2, value11, value10)
            if camCur.p >= 89.4 then
                camera.CFrame = CFrame.lookAt(
                    value7 + Vector3.new(0, camCur.d, 0),
                    value7,
                    Vector3.new(-math.sin(value8), 0, -math.cos(value8))
                )
            else
                value10, value2 =
                    math.rad(math.clamp(camCur.p, 5, 89.4)),
                    Vector3.new(sharedValue81, zone.cy or value11, sharedValue82)
                local transform, value12, value13, value14 =
                    CFrame.lookAt(
                        value2
                            + Vector3.new(
                                    math.sin(value8) * math.cos(value10),
                                    math.sin(value10),
                                    math.cos(value8) * math.cos(value10)
                                )
                                * camCur.d,
                        value2
                    ),
                    camCur.d / (viewportSize.Y * 0.5 / math.tan(math.rad(camCur.f) * 0.5)),
                    value.X + sharedValue79 * 0.5 - viewportSize.X * 0.5,
                    value.Y + sharedValue80 * 0.5 - viewportSize.Y * 0.5
                camera.CFrame = transform
                    - transform.RightVector * (value13 * value12)
                    + transform.UpVector * (value14 * value12)
            end
            if config.map3DSeeThrough ~= false then
                pcall(
                    see.step,
                    tonumber(argument) or 0.016,
                    camera,
                    Vector3.new(sharedValue81, zone.cy or value11, sharedValue82)
                )
            elseif next(see.a) then
                see.clear()
            end
        end
        zone.sync3D = function()
            local cam3On = zone.use3D()
            if cam3On == sharedValue88.on then
                return
            end
            sharedValue88.on = cam3On
            zone.cam3On = cam3On
            local camera = workspaceService.CurrentCamera
            if cam3On then
                zone.camCur = nil
                sharedValue88.fov = camera and camera.FieldOfView or 70
                pcall(function()
                    runService:UnbindFromRenderStep("HLMap3D")
                end)
                pcall(function()
                    runService:BindToRenderStep("HLMap3D", Enum.RenderPriority.Last.Value + 1, helper200)
                end)
                sharedValue84.set(true)
            else
                pcall(function()
                    runService:UnbindFromRenderStep("HLMap3D")
                end)
                sharedValue84.set(false)
                pcall(see.clear)
                if camera then
                    pcall(function()
                        camera.FieldOfView = sharedValue88.fov or 70
                        if config.birdsEyeCam ~= true then
                            camera.CameraType = Enum.CameraType.Custom
                        end
                    end)
                end
            end
        end
        zone.stop3D = function()
            zone.sync3D()
        end
        local function placeBands()
            local value, absoluteSize, value2 =
                view.AbsolutePosition, view.AbsoluteSize, hlMinimap.AbsolutePosition
            local value3, value4 = value.X - value2.X, value.Y - value2.Y
            value2, value = value3 + absoluteSize.X, value4 + absoluteSize.Y
            sharedValue47[1].Position, sharedValue47[1].Size =
                UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, math.max(value4, 0))
            sharedValue47[2].Position, sharedValue47[2].Size =
                UDim2.fromOffset(0, value), UDim2.new(1, 0, 1, -value)
            sharedValue47[3].Position, sharedValue47[3].Size =
                UDim2.fromOffset(0, value4), UDim2.fromOffset(math.max(value3, 0), absoluteSize.Y)
            sharedValue47[4].Position, sharedValue47[4].Size =
                UDim2.fromOffset(value2, value4), UDim2.new(1, -value2, 0, absoluteSize.Y)
        end
        zone.placeBands = placeBands
        local function helper201(argument)
            local value, value2 =
                type(config.mapAnchors) == "table" and config.mapAnchors or {}, tostring(game.PlaceId)
            local value3 = value[value2]
            if argument or type(value3) ~= "table" or not tonumber(value3.x) or not tonumber(value3.z) then
                local mapAnchors = localPlayer.Character
                local value4 = mapAnchors and (mapAnchors:FindFirstChild("HumanoidRootPart"))
                mapAnchors = value4 and value4.Position
                value3 = {
                    x = mapAnchors and mapAnchors.X or zone.cx or 0,
                    z = mapAnchors and mapAnchors.Z or zone.cz or 0,
                }
                mapAnchors = {}
                for key, entry in pairs(value) do
                    mapAnchors[key] = entry
                end
                mapAnchors[value2] = value3
                config.mapAnchors = mapAnchors
                pcall(helper16)
            end
            return value3
        end
        zone.anchor = function()
            return helper201(false)
        end
        zone.onFollow = function(argument)
            if not argument then
                helper201(true)
            end
            zone.panX = 0
            zone.panZ = 0
            zone.lastAt = 0
        end
        zone.apply = function()
            hlMinimap.Visible = config.minimap ~= false or zone.big
            if zone.big then
                hlMinimap.AnchorPoint, hlMinimap.Position, hlMinimap.Size =
                    Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(1, 1)
                zone.statsAt = 0
                backdrop.BackgroundTransparency = 0
                view.AnchorPoint, view.Position =
                    Vector2.new(0, 0), UDim2.fromOffset(sharedValue44, sharedValue45)
                local value = config.mapStatsHidden == true
                view.Size = value
                        and UDim2.new(1, -(2 * sharedValue44 + 10), 1, -(sharedValue45 + sharedValue44))
                    or UDim2.new(
                        1,
                        -(2 * sharedValue44 + sharedValue42 + sharedValue43),
                        1,
                        -(sharedValue45 + sharedValue44)
                    )
                statsFrame.Visible = not value
                if zone.statsArrow then
                    zone.statsArrow.Text = value and "<" or ">"
                    zone.statsArrow.Position = value and UDim2.new(1, -4, 0.5, 0)
                        or UDim2.new(1, -(sharedValue44 + sharedValue42 + 2), 0.5, 0)
                end
                corner.CornerRadius, view.BackgroundColor3 = UDim.new(0, 10), theme2.Panel
                view.BackgroundTransparency = 0
                stroke2.Color = theme2.Stroke
                stroke2.Thickness = 3
                stroke2.Transparency = 0
                pcall(function()
                    stroke2.LineJoinMode = Enum.LineJoinMode.Round
                end)
                backdrop.BackgroundColor3 = theme2.Bg
                for index, entry in ipairs(sharedValue47) do
                    entry.BackgroundColor3 = theme2.Bg
                end
            else
                local vector, value2, value3 =
                    workspaceService.CurrentCamera and workspaceService.CurrentCamera.ViewportSize
                        or Vector2.new(1920, 1080),
                    tonumber(config.minimapX) or -1,
                    tonumber(config.minimapY) or -1
                if value2 >= 0 and value3 >= 0 then
                    hlMinimap.AnchorPoint = Vector2.new(0, 0)
                    hlMinimap.Position = UDim2.fromOffset(
                        math.clamp(value2, 0, math.max(vector.X - sharedValue40, 0)),
                        math.clamp(value3, 0, math.max(vector.Y - sharedValue40, 0))
                    )
                else
                    hlMinimap.AnchorPoint, hlMinimap.Position =
                        Vector2.new(1, 0), UDim2.new(1, -16, 0, config.minimapTop or 64)
                end
                hlMinimap.Size = UDim2.fromOffset(sharedValue40, sharedValue40)
                view.AnchorPoint, view.Position, view.Size =
                    Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(1, 1)
                statsFrame.Visible = false
                sharedValue70.Visible = false
                sharedValue69.Visible = false
                corner.CornerRadius, view.BackgroundColor3 = UDim.new(0, 10), theme2.Panel
                view.BackgroundTransparency = 0
                stroke2.Color = theme2.Stroke
                stroke2.Thickness = 3
                stroke2.Transparency = 0
                pcall(function()
                    stroke2.LineJoinMode = Enum.LineJoinMode.Round
                end)
            end
            local value4 = zone.blank()
            local visible = zone.big and not value4
            backdrop.Visible = zone.big
            sharedValue50.Visible = visible
            sharedValue51.Visible = visible
            sharedValue48.Visible = visible
            sharedValue49.Visible = visible
            sharedValue53.Visible = visible
            sharedValue68.Visible = visible
            if zone.statsArrow then
                zone.statsArrow.Visible = visible
            end
            if not visible then
                sharedValue69.Visible = false
            end
            view.Visible = true
            if value4 then
                statsFrame.Visible = false
                sharedValue52.Visible = false
                view.BackgroundTransparency = 1
                stroke2.Transparency = 1
                if zone.clearMarks then
                    zone.clearMarks()
                end
            end
            local value5 = zone.use3D()
            if zone.big then
                if value5 then
                    backdrop.Visible = false
                    view.BackgroundTransparency = 1
                    placeBands()
                    if zone.clearMarks then
                        zone.clearMarks()
                    end
                end
            end
            sharedValue52.Visible = visible and not value5
            for index2, entry2 in ipairs(sharedValue47) do
                entry2.Visible = zone.big and value5
            end
            for key, entry3 in pairs(sharedValue57) do
                entry3.render()
                entry3.b.Visible = if value4
                    then not value4
                    else not (value5 and (key == "mapHealthBars" or key == "mapNames"))
            end
            sharedValue56.Visible = zone.big
            zone.viewBox.Visible = zone.big == true
            zone.paintView()
            if zone.camBox then
                zone.camBox.Visible = zone.use3D() == true
                if zone.camBox.Visible then
                    if zone.paintCam then
                        zone.paintCam()
                    end
                end
            end
            zone.sync3D()
            sharedValue72.set(zone.big == true)
            visible = runtimeState.scriptGui and runtimeState.scriptGui:FindFirstChild("HUD")
            if visible then
                value4 = zone.big
                local value6, visible2 = not value4
                if value4 then
                    visible2 = value6
                else
                    value5 = context.hudShown
                    visible2 = if value5 then context.hudShown() else not value5
                end
                visible.Visible = visible2
            end
            do
                local mapBtn = zone.mapBtn
                local mapBtnStroke = zone.mapBtnStroke
                value5 = zone.big
                mapBtn.Visible = if value5 then not value5 else config.mapButton ~= false
                mapBtn.Text = "SWANGY MAP [" .. tostring(config.mapKey or "M") .. "]"
                pcall(function()
                    mapBtn.FontFace = sharedValue41.Semi
                end)
                mapBtn.TextSize, mapBtn.TextColor3, mapBtn.BackgroundColor3 = 13, MP.Parchment, MP.Wood
                mapBtn.BackgroundTransparency = 0.15
                mapBtnStroke.Color = MP.Bark
                mapBtnStroke.Thickness = 2
                mapBtnStroke.Transparency = 0
                pcall(function()
                    mapBtnStroke.LineJoinMode = Enum.LineJoinMode.Round
                end)
                zone.mapBtnCorner.CornerRadius = UDim.new(0, 4)
            end
            zone.lastAt = 0
        end
        zone.setBig = function(argument, argument2)
            argument = argument == true
            if not argument2 then
                zone.ultOpened = nil
                config.mapViewOpen = argument
                pcall(helper16)
            end
            if zone.big ~= argument then
                zone.big = argument
                zone.panX = 0
                zone.panZ = 0
                zone.freeAt = nil
            end
            zone.apply()
        end
        zone.toggle = function()
            zone.setBig(not zone.big)
        end
        zone.onUltimate = function(argument)
            if argument and not zone.big then
                zone.setBig(true, true)
                zone.ultOpened = true
            elseif argument then
                zone.apply()
            elseif zone.ultOpened then
                zone.ultOpened = nil
                zone.setBig(false, true)
            else
                zone.apply()
            end
        end
        zone.apply()
        local function helper202()
            if zone.big then
                return
            end
            if zone.overMenu() then
                return
            end
            zone.setBig(true)
        end
        hit.Activated:Connect(helper202)
        local function helper203()
            if zone.overMenu() then
                return
            end
            zone.setBig(false)
        end
        sharedValue53.Activated:Connect(helper203)
        local sharedValue89 = getService("GuiService")
        local function helper204(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton3 then
                return
            elseif zone.overMenu() then
                return
            end
            local absolutePosition, anchor, freeAt =
                hlMinimap.AbsolutePosition,
                zone.big and config.mapFollow == false and zone.anchor() or nil,
                zone.freeAt
            zone.drag = {
                mode = zone.big and "pan" or "move",
                sx = input.Position.X,
                sy = input.Position.Y,
                moved = false,
                ax = absolutePosition.X,
                ay = absolutePosition.Y + sharedValue89:GetGuiInset().Y,
                px = anchor and anchor.x or (freeAt and freeAt.x or zone.cx or 0),
                pz = anchor and anchor.z or (freeAt and freeAt.z or zone.cz or 0),
                anchor = anchor,
            }
        end
        hit.InputBegan:Connect(helper204)
        sliderConnections[#sliderConnections + 1] = userInputService.InputChanged:Connect(function(argument)
            local drag = zone.drag
            if drag then
                if argument.UserInputType ~= Enum.UserInputType.MouseMovement then
                    return
                end
            else
                return
            end
            local value, value2 = argument.Position.X - drag.sx, argument.Position.Y - drag.sy
            if not drag.moved then
                if value * value + value2 * value2 < 9 then
                    return
                end
            end
            drag.moved = true
            if drag.mode == "move" then
                argument = workspaceService.CurrentCamera and workspaceService.CurrentCamera.ViewportSize
                    or Vector2.new(1920, 1080)
                config.minimapX =
                    math.floor(math.clamp(drag.ax + value, 0, math.max(argument.X - sharedValue40, 0)))
                config.minimapY =
                    math.floor(math.clamp(drag.ay + value2, 0, math.max(argument.Y - sharedValue40, 0)))
                hlMinimap.AnchorPoint, hlMinimap.Position =
                    Vector2.new(0, 0), UDim2.fromOffset(config.minimapX, config.minimapY)
            elseif drag.anchor then
                drag.anchor.x, drag.anchor.z =
                    drag.px - value / sharedValue83, drag.pz - value2 / sharedValue83
                zone.lastAt = 0
            else
                zone.freeAt = { x = drag.px - value / sharedValue83, z = drag.pz - value2 / sharedValue83 }
                zone.lastAt = 0
            end
        end)
        sliderConnections[#sliderConnections + 1] = userInputService.InputEnded:Connect(function(input)
            local drag = zone.drag
            if drag then
                if input.UserInputType ~= Enum.UserInputType.MouseButton3 then
                    return
                end
            else
                return
            end
            zone.drag = nil
            if drag.mode == "move" then
                if not drag.moved then
                    config.minimapX = -1
                    config.minimapY = -1
                    zone.apply()
                end
                pcall(helper16)
            elseif drag.anchor then
                if not drag.moved then
                    helper201(true)
                end
                pcall(helper16)
                zone.lastAt = 0
            elseif not drag.moved then
                zone.panX = 0
                zone.panZ = 0
                zone.freeAt = nil
                zone.lastAt = 0
            end
        end)
        local function helper205()
            if zone.overMenu() then
                return
            end
            if zone.big then
                zone.zoomB = math.min(zone.zoomB * 1.15, 6)
            else
                zone.zoomS = math.min(zone.zoomS * 1.15, 6)
            end
            config.mapZoomS, config.mapZoomB = zone.zoomS, zone.zoomB
            pcall(helper16)
            zone.lastAt = 0
        end
        hit.MouseWheelForward:Connect(helper205)
        local function helper206()
            if zone.overMenu() then
                return
            end
            if zone.big then
                zone.zoomB = math.max(zone.zoomB / 1.15, 0.25)
            else
                zone.zoomS = math.max(zone.zoomS / 1.15, 0.25)
            end
            config.mapZoomS, config.mapZoomB = zone.zoomS, zone.zoomB
            pcall(helper16)
            zone.lastAt = 0
        end
        hit.MouseWheelBackward:Connect(helper206)
        sliderConnections[#sliderConnections + 1] = runService.Heartbeat:Connect(function()
            if runtimeState.destroyed then
                return
            end
            local value = zone.big == true and zone.viewMode() == "2d"
            if value ~= (context.fps2D == true) then
                context.fps2D = value
                if context.applyRender then
                    pcall(context.applyRender)
                end
            end
            value = zone.cam3On == true
            if value ~= sharedValue84.on then
                sharedValue84.set(value)
            end
            if config.minimap == false then
                if not zone.big then
                    return
                end
            end
            value = os.clock()
            if zone.use3D() ~= (zone.cam3On == true) then
                zone.apply()
            end
            if zone.cam3On then
                placeBands()
            end
            local success = localPlayer.Character
            local value2 = success and (success:FindFirstChild("HumanoidRootPart"))
            if value2 then
                success = value2.AssemblyLinearVelocity
                if success.X * success.X + success.Z * success.Z > 4 then
                    zone.movedAt = value
                end
            end
            zone.frames = zone.frames + 1
            if value - zone.fpsAt >= 1 then
                zone.fps = math.floor(zone.frames / (value - zone.fpsAt) + 0.5)
                zone.frames = 0
                zone.fpsAt = value
            end
            if zone.blank() then
                return
            end
            if zone.big then
                if value - (zone.bossAt or 0) >= 0.25 then
                    zone.bossAt = value
                    pcall(zone.drawBoss)
                    pcall(zone.drawTimer)
                end
            end
            if zone.big then
                if statsFrame.Visible then
                    if value - zone.statsAt >= 0.5 then
                        zone.statsAt = value
                        success, value2 = pcall(zone.drawStats)
                        if not success then
                            if not zone.statsErrAt then
                                zone.statsErrAt = value
                                context.log("Minimap", "stats failed: " .. tostring(value2))
                            end
                        end
                    end
                end
            end
            pcall(zone.drawFuse3D, zone.cam3On == true and config.mapFuse3D == true)
            if zone.cam3On then
                return
            end
            value2 = config.minimapSmooth ~= false and zone.viewMode() == "2d"
            if not value2 then
                if
                    value - zone.lastAt
                    < (zone.big and (config.minimapBigEvery or 0.05) or (config.minimapEvery or 0.1))
                then
                    return
                end
            end
            if value2 then
                if config.perfMemo ~= false then
                    if value - zone.lastAt < 1 / (config.minimapSmoothHz or 30) then
                        return
                    end
                end
            end
            zone.lastAt = value
            success, value2 = pcall(zone.draw)
            if not success then
                if not zone.errAt then
                    zone.errAt = value
                    context.log("Minimap", "draw failed: " .. tostring(value2))
                end
            end
        end)
    end
    band2, helper18 = pcall(function()
        local value3, value4, value5 =
            getgenv and getgenv() or _G, "__HLClassicMinimapPlus", "hl_classic_minimap_plus.json"
        if type(value3[value4]) == "table" then
            if type(value3[value4].destroy) == "function" then
                pcall(value3[value4].destroy)
            end
        end
        local value6 = getService("Players")
        local value7 = getService("RunService")
        local value8 = getService("HttpService")
        local value9 = getService("Stats")
        local value10, classicPlus =
            getService("TweenService"), {
                alive = true,
                version = 2,
                status = "Waiting for Harvard",
                controls = {},
                values = {},
                errors = 0,
                activeTweens = 0,
                tweensStarted = 0,
            }
        value3[value4] = classicPlus
        context.ClassicPlus = classicPlus
        local helper6, value11 = Color3.fromRGB, {}
        value11.bg = helper6(16, 18, 23)
        value11.card = helper6(22, 25, 33)
        value11.control = helper6(32, 36, 48)
        value11.line = helper6(48, 54, 70)
        value11.text = helper6(241, 243, 250)
        value11.muted = helper6(153, 165, 186)
        value11.accent = helper6(170, 156, 255)
        value11.pill = helper6(53, 46, 83)
        value11.green = helper6(83, 219, 156)
        value11.red = helper6(255, 108, 126)
        value11.amber = helper6(255, 200, 105)
        local font, value12 =
            Enum.Font.BuilderSans, {
                tab = "Overview",
                refresh = 0.25,
                compact = false,
                smooth = true,
                animations = true,
                radius = 100,
                healthWarning = 30,
                coordinates = false,
                vitals = true,
                progress = true,
                performance = true,
                abilities = true,
                nearby = true,
                party = true,
                automation = false,
            }
        local value13 = table.clone(value12)
        value13.native = {}
        local value14, value15, value16 =
            {
                mapFollow = true,
                mapNames = true,
                mapHealthBars = true,
                minimapBigRange = 160,
                mapBgOpacity = 55,
                minimapMaxAttacks = 250,
                mapRingW = 4,
            }, {
                minimapBigRange = { 40, 400 },
                mapBgOpacity = { 0, 100 },
                minimapMaxAttacks = { 50, 500 },
                mapRingW = { 1, 12 },
                mapZoomB = { 0.25, 5 },
            }, { Default = false }
        value16.Red = helper6(255, 85, 105)
        value16.Amber = helper6(255, 194, 77)
        value16.Cyan = helper6(71, 219, 255)
        local function helper22(argument)
            return type(argument) == "number" and argument == argument and math.abs(argument) < math.huge
        end
        local function helper23(argument, argument2)
            if value15[argument] then
                return helper22(argument2)
                    and argument2 >= value15[argument][1]
                    and argument2 <= value15[argument][2]
            end
            if type(value14[argument]) == "boolean" then
                return type(argument2) == "boolean"
            end
            if argument == "palette" then
                return value16[argument2] ~= nil
            end
            return false
        end
        if isfile then
            if readfile then
                pcall(function()
                    if not (isfile(value5)) then
                        return
                    end
                    local value = value8:JSONDecode(readfile(value5))
                    if type(value) ~= "table" then
                        return
                    end
                    for key, entry in pairs(value12) do
                        if type(value[key]) == type(entry) then
                            value13[key] = value[key]
                        end
                    end
                    if type(value.native) == "table" then
                        for key2, entry2 in pairs(value.native) do
                            if helper23(key2, entry2) then
                                value13.native[key2] = entry2
                            end
                        end
                    end
                end)
            end
        end
        if not (table.find({ "Overview", "Combat", "Session" }, value13.tab)) then
            value13.tab = "Overview"
        end
        if not (table.find({ 0.1, 0.25, 0.5, 1 }, value13.refresh)) then
            value13.refresh = 0.25
        end
        if not (helper22(value13.radius)) then
            value13.radius = 100
        end
        value13.radius = math.clamp(value13.radius, 25, 500)
        if not (helper22(value13.healthWarning)) then
            value13.healthWarning = 30
        end
        value13.healthWarning = math.clamp(value13.healthWarning, 0, 75)
        local value17, value18, config2, statsFrame2, value19, value20, value21
        local value22, value23, value24, value25, value26, value27, value28, value29, value30, now =
            {}, {}, {}, {}, {}, {}, {}, {}, false
        local value31, value32, value33, value34, value35, minimapBigEvery, minimapEvery = 0, 0
        local value36 = { frames = 0, draws = 0 }
        value36.since = os.clock()
        value36.fps = 0
        value36.mapFps = 0
        value36.last = nil
        local value37, value38, value39, connection, connection2, helper24, helper25, value40, value41, tab, compact, animations =
            0
        local value42, value43, value44, value45 = {}, {}, {}, { "Overview", "Combat", "Session" }
        local function helper26(argument, argument2, argument3)
            if argument[argument2] ~= argument3 then
                argument[argument2] = argument3
            end
        end
        local function helper27(argument)
            if value20 then
                if not value20.Visible then
                    return false
                end
            else
                return false
            end
            local value = argument
            while value do
                if value:IsA("GuiObject") then
                    if not value.Visible then
                        return false
                    end
                end
                if value:IsA("ScreenGui") then
                    return value.Enabled
                end
                value = value.Parent
            end
            return false
        end
        local function helper28(argument, argument2, argument3)
            local value = value43[argument]
            local value46 = value and value[argument2]
            if not value46 then
                return
            end
            value[argument2] = nil
            if next(value) == nil then
                value43[argument] = nil
            end
            value46.connection:Disconnect()
            value46.tween:Cancel()
            classicPlus.activeTweens = classicPlus.activeTweens - 1
            if argument3 then
                for key, goal in pairs(value46.goals) do
                    helper26(argument, key, goal)
                end
            end
        end
        local function helper29(argument, argument2)
            local value = {}
            for key, entry in pairs(value43) do
                if
                    (if argument2 then key == argument2 else not argument2) or key:IsDescendantOf(argument2)
                then
                    for entry2 in pairs(entry) do
                        value[#value + 1] = { key, entry2 }
                    end
                end
            end
            for index, entry3 in ipairs(value) do
                helper28(entry3[1], entry3[2], argument)
            end
        end
        local function helper30(argument, argument2, argument3, argument4, argument5)
            local value = value43[argument]
            local value46, tween =
                value and value[argument2],
                (if argument5 then not argument5 else value13.animations) and helper27(argument)
            if value46 and tween then
                argument5 = true
                for key, entry in pairs(argument3) do
                    if value46.goals[key] ~= entry then
                        argument5 = false
                        break
                    end
                end
                if argument5 then
                    return
                end
            end
            helper28(argument, argument2, false)
            value46 = false
            for key2, entry2 in pairs(argument3) do
                if argument[key2] ~= entry2 then
                    value46 = true
                    break
                end
            end
            if not value46 then
                return
            end
            if not tween then
                for key3, entry3 in pairs(argument3) do
                    helper26(argument, key3, entry3)
                end
                return
            end
            argument4 = argument4 or 0.14
            if not value44[argument4] then
                value44[argument4] = TweenInfo.new(argument4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
            tween = value10:Create(argument, value44[argument4], argument3)
            local value47 = { tween = tween }
            value47.goals = table.clone(argument3)
            value = value43[argument] or {}
            value43[argument] = value
            value[argument2] = value47
            classicPlus.activeTweens = classicPlus.activeTweens + 1
            classicPlus.tweensStarted = classicPlus.tweensStarted + 1
            value47.connection = tween.Completed:Connect(function()
                value47.connection:Disconnect()
                if value43[argument] then
                    if value43[argument][argument2] == value47 then
                        value43[argument][argument2] = nil
                        if next(value43[argument]) == nil then
                            value43[argument] = nil
                        end
                        classicPlus.activeTweens = classicPlus.activeTweens - 1
                    end
                end
            end)
            tween:Play()
        end
        local function helper31(argument, argument2)
            local connection3 = argument:Connect(argument2)
            value22[#value22 + 1] = connection3
            return connection3
        end
        local function helper32(argument, argument2, parent)
            local value = Instance.new(argument)
            for key, entry in pairs(argument2) do
                value[key] = entry
            end
            value.Parent = parent
            return value
        end
        local function helper33(argument, argument2)
            helper32("UICorner", { CornerRadius = UDim.new(0, argument2 or 8) }, argument)
        end
        local function helper34(argument)
            return helper32("UIStroke", {
                Color = value11.line,
                Thickness = 1,
                Transparency = 0.45,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            }, argument)
        end
        local function helper35(argument, name2, text, argument2)
            return helper32("TextLabel", {
                Name = name2,
                Text = text,
                Font = font,
                TextSize = argument2 or 13,
                TextColor3 = value11.text,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 62,
            }, argument)
        end
        local function helper36(argument, argument2)
            local value = value42[argument]
            if not value then
                return
            end
            local value46, value47 =
                value.hover or value.focus, value.selected and value11.pill or value11.control
            local accent, value48 = value11.accent, value.down and 0.18 or value46 and 0.09
            helper30(argument, "surface", {
                BackgroundColor3 = value47:Lerp(accent, value48 or 0),
                BackgroundTransparency = value.tab and (value46 and 0.75 or 1) or 0,
                TextColor3 = value.selected and value11.accent or value11.text,
            }, 0.12, argument2)
            if value.stroke then
                helper30(value.stroke, "border", {
                    Color = value46 and value11.accent or value11.line,
                    Transparency = value46 and 0.25 or 0.5,
                }, 0.12, argument2)
            end
            value47, argument = value.scale, {}
            argument.Scale = value.down and 0.97 or 1
            helper30(value47, "press", argument, value.down and 0.07 or 0.12, argument2)
        end
        local function helper37(argument, name2, text, argument2, tab2)
            local value = helper32("TextButton", {
                Name = name2,
                Text = text,
                Font = font,
                TextSize = 12,
                TextColor3 = value11.text,
                BackgroundColor3 = value11.control,
                BorderSizePixel = 0,
                BackgroundTransparency = tab2 and 1 or 0,
                AutoButtonColor = false,
                ZIndex = 64,
            }, argument)
            helper33(value, 7)
            local value46 = { tab = tab2 }
            value46.scale = helper32("UIScale", { Scale = 1 }, value)
            if not tab2 then
                value46.stroke = helper34(value)
            end
            value42[value] = value46
            helper31(value.MouseEnter, function()
                value46.hover = true
                helper36(value)
            end)
            helper31(value.MouseLeave, function()
                value46.hover = false
                value46.down = false
                helper36(value)
            end)
            helper31(value.SelectionGained, function()
                value46.focus = true
                helper36(value)
            end)
            helper31(value.SelectionLost, function()
                value46.focus = false
                value46.down = false
                helper36(value)
            end)
            helper31(value.MouseButton1Down, function()
                value46.down = true
                helper36(value)
            end)
            helper31(value.MouseButton1Up, function()
                value46.down = false
                helper36(value)
            end)
            helper31(value.Activated, function()
                local success, value47 = pcall(argument2)
                if not success then
                    classicPlus.errors = classicPlus.errors + 1
                    warn("[Classic Plus] Control failed: " .. tostring(value47))
                end
                value46.down = false
                helper36(value)
                if value20 then
                    if helper24 then
                        helper24()
                    end
                end
            end)
            return value
        end
        local function helper38(argument, argument2)
            local valueObject = argument and (argument:FindFirstChild(argument2))
            if valueObject then
                if valueObject:IsA("ValueBase") then
                    return valueObject.Value
                end
            end
            return nil
        end
        local function helper39(argument, argument2)
            if not (helper22(argument)) then
                return "--"
            end
            local value = argument < 0 and "-" or ""
            argument = math.abs(argument)
            local value46 = {
                { 1000000000000000, "Qa" },
                { 1000000000000, "T" },
                { 1000000000, "B" },
                { 1000000, "M" },
                { 1000, "K" },
            }
            for index, entry in ipairs(value46) do
                if argument >= entry[1] then
                    return value .. string.format("%.2f", argument / entry[1]):gsub("%.?0+$", "") .. entry[2]
                end
            end
            return value .. string.format("%." .. tostring(argument2 or 0) .. "f", argument)
        end
        local function helper40()
            now = os.clock()
        end
        local function helper41()
            if not writefile then
                return
            end
            local success, value = pcall(value8.JSONEncode, value8, value13)
            if success then
                local success2, value46 = pcall(writefile, value5, value)
                if not success2 then
                    warn("[Classic Plus] Could not save preferences: " .. tostring(value46))
                end
            end
        end
        local function helper42(argument, argument2)
            if not config2 then
                return
            end
            if not value23[argument] then
                value23[argument] = { value = config2[argument] }
            end
            config2[argument] = argument2
            value29[argument] = argument2
        end
        local function helper43(argument, argument2)
            if not (helper23(argument, argument2)) then
                return
            end
            if argument == "palette" then
                helper42("mapAttackOneColor", argument2 ~= "Default")
                if argument2 ~= "Default" then
                    helper42("mapAttackColor", value16[argument2])
                end
            elseif argument == "mapZoomB" then
                helper42(argument, argument2)
                if not value23._zoom then
                    value23._zoom = { value = value18.zoomB }
                end
                value18.zoomB = argument2
                value29._zoom = argument2
            else
                helper42(argument, argument2)
            end
            value18.lastAt = 0
        end
        local function helper44()
            if value35 then
                if config2 then
                    if config2.minimapBigEvery == 0 then
                        config2.minimapBigEvery = minimapBigEvery
                    end
                    if config2.minimapEvery == 0 then
                        config2.minimapEvery = minimapEvery
                    end
                end
            end
            value35, minimapBigEvery, minimapEvery = false, nil, nil
        end
        local function helper45()
            local value = value3.__HLClassicMinimapSmooth
            if value ~= value33 then
                helper44()
                if value33 then
                    if value33.alive then
                        if value33.setEnabled then
                            value33.setEnabled(value34)
                        end
                    end
                end
                value33 = value
                value34 = value33 and value33.enabled
            end
            if value33 then
                if value33.alive then
                    if type(value33.setEnabled) == "function" then
                        if value33.enabled ~= value13.smooth then
                            value33.setEnabled(value13.smooth)
                        end
                        return
                    end
                end
            end
            value = value13.smooth
                and not value18.cam3On
                and value18.viewMode() == "2d"
                and not value18.blank()
            if value then
                if value35 then
                    if not value then
                        helper44()
                    end
                else
                    local minimapBigEvery2, value46 = config2.minimapBigEvery, config2.minimapEvery
                    minimapBigEvery, minimapEvery = minimapBigEvery2, value46
                    value46 = config2
                    value46.minimapBigEvery, value46.minimapEvery = 0, 0
                    value35 = true
                end
            elseif value then
            else
                helper44()
            end
        end
        local function helper46(argument, argument2, argument3)
            local value = helper32("Frame", {
                Name = argument3 or argument2,
                BackgroundColor3 = value11.card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -6, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #argument:GetChildren(),
                ZIndex = 61,
            }, argument)
            helper33(value, 10)
            helper34(value)
            helper32("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 9),
            }, value)
            helper32(
                "UIListLayout",
                { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder },
                value
            )
            argument = helper35(value, "Heading", string.upper(argument2), 11)
            argument.Font = Enum.Font.BuilderSansBold
            argument.TextColor3 = value11.accent
            argument.Size = UDim2.new(1, 0, 0, 30)
            argument.LayoutOrder = 0
            helper32("Frame", {
                Name = "Divider",
                Position = UDim2.new(0, 0, 1, -2),
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = value11.line,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                ZIndex = 62,
            }, argument)
            if argument3 then
                value25[argument3] = value
            end
            return value
        end
        local function helper47(label, name2, value, bar)
            local frame = helper32("Frame", {
                Name = name2,
                Size = UDim2.new(1, 0, 0, bar and 42 or 28),
                BackgroundColor3 = value11.card,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = #label:GetChildren(),
                ZIndex = 61,
            }, label)
            helper33(frame, 5)
            label = helper35(frame, "Label", value, 12)
            label.Size = UDim2.new(0.43, 0, 0, 26)
            label.TextColor3 = value11.muted
            value = helper35(frame, "Value", "--", 13)
            value.AnchorPoint = Vector2.new(1, 0)
            value.Position = UDim2.fromScale(1, 0)
            value.Size = UDim2.new(0.56, 0, 0, 26)
            value.TextXAlignment = Enum.TextXAlignment.Right
            local fill
            if bar then
                local value46 = helper32("Frame", {
                    Name = "Track",
                    Position = UDim2.fromOffset(0, 30),
                    Size = UDim2.new(1, 0, 0, 5),
                    BackgroundColor3 = value11.line,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 62,
                }, frame)
                helper33(value46, 3)
                fill = helper32("Frame", {
                    Name = "Fill",
                    Size = UDim2.fromScale(0, 1),
                    BackgroundColor3 = value11.accent,
                    BorderSizePixel = 0,
                    ZIndex = 63,
                }, value46)
                helper33(fill, 3)
            end
            value24[name2] = { frame = frame, label = label, value = value, fill = fill, bar = bar }
        end
        local function helper48(argument, argument2, argument3, argument4)
            local value = value24[argument]
            if not value then
                return
            end
            argument2 = tostring(argument2 or "--")
            local value46 = value.value.Text ~= argument2
            helper26(value.value, "Text", argument2)
            local value47, textControl = value.value, {}
            textControl.TextColor3 = argument3 or value11.text
            helper30(value47, "color", textControl, 0.14, not value.initialized)
            classicPlus.values[argument] = argument2
            if value.fill then
                value47 = math.floor(math.clamp(argument4 or 0, 0, 1) * 1000 + 0.5) / 1000
                helper30(
                    value.fill,
                    "bar",
                    { Size = UDim2.fromScale(value47, 1), BackgroundColor3 = argument3 or value11.accent },
                    math.min(0.18, value13.refresh),
                    not value.initialized
                )
            end
            if
                value46
                and value.initialized
                and value13.animations
                and helper27(value.frame)
                and (argument2 == "READY" or argument2 == "LOW HEALTH")
            then
                helper28(value.frame, "notice", false)
                value.frame.BackgroundColor3 = argument3 or value11.accent
                value.frame.BackgroundTransparency = 0.85
                helper30(value.frame, "notice", { BackgroundTransparency = 1 }, 0.3)
            end
            value.initialized = true
        end
        helper24 = function()
            if value20 then
                if not value17 then
                    return
                end
            else
                return
            end
            local value = value18.big == true
            local value46, value47 =
                value and not value20.Visible,
                value20.Visible and not value or animations and not value13.animations
            if value47 then
                helper29(true)
                for key, entry in pairs(value42) do
                    entry.hover = false
                    entry.down = false
                    entry.focus = false
                end
            end
            helper26(value20, "Visible", value)
            animations = value13.animations
            classicPlus.status = value and "Classic / " .. value13.tab or "Ready (open Classic map)"
            value47 = tab
            local value48, value49 = value47 ~= value13.tab, table.find(value45, value13.tab) or 1
            value47 = table.find(value45, tab) or value49
            if value then
                value30 = true
                helper26(value19, "Size", UDim2.new(1, -24, 1, -222))
                helper26(value19, "Visible", value13.tab == "Session")
                local value50 = value13.tab == "Session" and (value48 or value46)
                if value50 then
                    if value13.animations then
                        helper28(value19, "page", false)
                        local value51 = value19
                        value51.Position = UDim2.fromOffset(20, 210)
                    end
                end
                local value52, value53 = value19, {}
                value53.Position = UDim2.fromOffset(12, 210)
                helper30(value52, "page", value53, 0.16)
            elseif value30 then
                value30 = false
                local value54 = value19
                value54.Position = value21.position
                value54 = value19
                value54.Size = value21.size
                value54 = value19
                value54.Visible = value21.visible
            end
            for key2, entry2 in pairs(value26) do
                local value55 = key2 == value13.tab
                if not value55 then
                    if entry2.Visible then
                        helper29(true, entry2)
                    end
                end
                helper26(entry2, "Visible", value55)
                if value55 then
                    if value48 or value46 then
                        if value13.animations then
                            if value then
                                helper28(entry2, "page", false)
                                entry2.Position = UDim2.fromOffset(value49 >= value47 and 9 or -9, 48)
                            end
                        end
                    end
                    helper30(entry2, "page", { Position = UDim2.fromOffset(0, 48) }, 0.16)
                end
            end
            value48, value47 = value41, {}
            value47.Position = UDim2.new((value49 - 1) / 3, 3, 0, 3)
            helper30(value48, "slide", value47, 0.18, not tab)
            for key3, entry3 in pairs(value27) do
                value42[entry3].selected = key3 == value13.tab
                helper36(entry3, not value)
            end
            for key4, entry4 in pairs(value25) do
                if value13[key4] ~= nil then
                    if entry4.Visible ~= value13[key4] then
                        if not value13[key4] then
                            helper29(true, entry4)
                        end
                        entry4.Visible = value13[key4]
                    end
                end
            end
            value48 = compact
            if value48 ~= value13.compact then
                for key5, entry5 in pairs(value24) do
                    value49, key5, value46, value47 =
                        entry5.frame, {}, UDim2.new, entry5.bar and 42 or (value13.compact and 24 or 29)
                    key5.Size = value46(1, 0, 0, value47)
                    helper30(value49, "density", key5, 0.16, compact == nil)
                end
                compact = value13.compact
            end
            for key6, entry6 in pairs(value28) do
                key6 = entry6.get()
                if entry6.toggle then
                    value42[entry6.button].selected = key6 == true
                    helper36(entry6.button, not value)
                    helper30(entry6.thumb, "switch", {
                        Position = UDim2.fromOffset(key6 and 23 or 3, 3),
                        BackgroundColor3 = key6 and value11.accent or value11.muted,
                    }, 0.14)
                else
                    value48 = entry6.format and entry6.format(key6) or tostring(key6)
                    if entry6.button then
                        helper26(entry6.button, "Text", value48)
                        helper36(entry6.button, not value)
                    end
                    if entry6.label then
                        helper26(entry6.label, "Text", value48)
                    end
                end
            end
            tab = value13.tab
        end
        local function helper49()
            value20 = helper32("Frame", {
                Name = "ClassicMinimapPlus",
                Position = UDim2.fromOffset(12, 162),
                Size = UDim2.new(1, -24, 1, -174),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 60,
            }, statsFrame2)
            value40 = helper32("Frame", {
                Name = "Tabs",
                Size = UDim2.new(1, -4, 0, 36),
                BackgroundColor3 = value11.card,
                BorderSizePixel = 0,
                ZIndex = 61,
            }, value20)
            helper33(value40, 10)
            helper34(value40)
            value41 = helper32("Frame", {
                Name = "ActiveTab",
                Position = UDim2.fromOffset(3, 3),
                Size = UDim2.new(0.3333333333333333, -6, 0, 30),
                BackgroundColor3 = value11.pill,
                BorderSizePixel = 0,
                ZIndex = 62,
            }, value40)
            helper33(value41, 7)
            for index, entry in ipairs(value45) do
                local value = helper37(value40, entry, entry, function()
                    value13.tab = entry
                    helper40()
                    helper24()
                    helper25()
                end, true)
                value.Position = UDim2.new((index - 1) / 3, 3, 0, 3)
                value.Size = UDim2.new(0.3333333333333333, -6, 0, 30)
                value.TextSize = 11
                value.Font = Enum.Font.BuilderSansMedium
                value27[entry] = value
                if entry ~= "Session" then
                    value = helper32("ScrollingFrame", {
                        Name = entry .. "Page",
                        Position = UDim2.fromOffset(0, 48),
                        Size = UDim2.new(1, 0, 1, -48),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Visible = false,
                        ScrollBarThickness = 3,
                        ScrollBarImageColor3 = value11.accent,
                        ScrollBarImageTransparency = 0.4,
                        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        CanvasSize = UDim2.new(),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ZIndex = 61,
                    }, value20)
                    helper32(
                        "UIListLayout",
                        { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder },
                        value
                    )
                    helper32("UIPadding", { PaddingBottom = UDim.new(0, 12) }, value)
                    value26[entry] = value
                end
            end
            local value46 = helper46(value26.Overview, "Player", "vitals")
            helper47(value46, "health", "Health", true)
            helper47(value46, "healthState", "Condition")
            helper47(value46, "speed", "Speed / walking")
            helper47(value46, "position", "Position X / Y / Z")
            value46 = helper46(value26.Overview, "Progress", "progress")
            helper47(value46, "level", "Level")
            helper47(value46, "xp", "XP progress", true)
            helper47(value46, "xpLeft", "XP to next level")
            helper47(value46, "gold", "Gold")
            helper47(value46, "gems", "Gems")
            helper47(value46, "skillPoints", "Unspent points")
            helper47(value46, "physical", "Physical points")
            helper47(value46, "spell", "Spell points")
            helper47(value46, "stamina", "Stamina points")
            value46 = helper46(value26.Overview, "Performance", "performance")
            helper47(value46, "fps", "Game FPS")
            helper47(value46, "mapFps", "Map updates / sec")
            helper47(value46, "frameTime", "Frame time")
            helper47(value46, "ping", "Ping")
            helper47(value46, "memory", "Client memory")
            value46 = helper46(value26.Combat, "Abilities", "abilities")
            helper47(value46, "qName", "Q ability")
            helper47(value46, "qCooldown", "Q cooldown", true)
            helper47(value46, "eName", "E ability")
            helper47(value46, "eCooldown", "E cooldown", true)
            helper47(value46, "buff", "Buff remaining")
            helper47(value46, "reach", "Ability reach")
            value46 = helper46(value26.Combat, "Nearby", "nearby")
            helper47(value46, "enemyCount", "Enemies in range")
            helper47(value46, "bossCount", "Bosses in range")
            helper47(value46, "nearest", "Nearest enemy")
            helper47(value46, "distance", "Distance")
            helper47(value46, "enemyHealth", "Enemy health", true)
            helper47(value46, "activeAttacks", "Active attacks")
            helper47(value46, "pendingAttacks", "Incoming attacks")
            helper47(value46, "threat", "Threat at player")
            value46 = helper46(value26.Combat, "Party", "party")
            helper47(value46, "partyCount", "Players alive")
            for index2 = 1, 8, 1 do
                helper47(value46, "party" .. index2, "Player " .. index2, true)
            end
            value46 = helper46(value26.Combat, "Automation", "automation")
            helper47(value46, "movement", "Movement")
            helper47(value46, "attack", "Attack status")
            helper47(value46, "coverage", "Cast coverage")
            helper47(value46, "decision", "Decision time")
            helper47(value46, "route", "Route")
            helper31(value19:GetPropertyChangedSignal("Visible"), function()
                if value30 then
                    if value20.Visible then
                        if value13.tab ~= "Session" then
                            if value19.Visible then
                                value19.Visible = false
                            end
                        end
                    end
                end
            end)
        end
        local function helper50(argument)
            return argument and (argument:FindFirstChildOfClass("Humanoid"))
        end
        helper25 = function()
            if value17 then
                if not value20 then
                    return
                end
            else
                return
            end
            local value = value17.LocalPlayer or value6.LocalPlayer
            local value46 = value.Character
            local value47, value48 =
                value46 and (value46:FindFirstChild("HumanoidRootPart")), helper50(value46)
            local value49, value50 = value48 and value48.Health, value48 and value48.MaxHealth
            local value51 = helper22(value50) and value50 > 0 and math.clamp(value49 / value50, 0, 1) or 0
            local value52 = value48
                and value49 > 0
                and value13.healthWarning > 0
                and value51 * 100 <= value13.healthWarning
            local value53 = value52 and value11.red or value11.green
            helper48(
                "health",
                value48 and helper39(value49) .. " / " .. helper39(value50) or "No character",
                value53,
                value51
            )
            value51 = not value48
            helper48(
                "healthState",
                (if value48 then value51 else "Waiting for character")
                    or value49 <= 0 and "Respawning"
                    or value52 and "LOW HEALTH"
                    or "Healthy",
                value53
            )
            value49 = value47 and value47.AssemblyLinearVelocity
            helper48(
                "speed",
                value48
                        and helper39(value49 and math.sqrt(value49.X * value49.X + value49.Z * value49.Z), 1) .. " / " .. helper39(
                            value48.WalkSpeed,
                            1
                        ) .. " studs/s"
                    or "--"
            )
            helper48(
                "position",
                value47
                        and string.format(
                            "%.0f / %.0f / %.0f",
                            value47.Position.X,
                            value47.Position.Y,
                            value47.Position.Z
                        )
                    or "--"
            )
            value24.position.frame.Visible = value13.coordinates
            value53, value52, value49 =
                value:FindFirstChild("leaderstats"), helper38(value, "XP"), helper38(value, "XPNeeded")
            value50 = helper22(value52)
                    and helper22(value49)
                    and value49 > 0
                    and math.clamp(value52 / value49, 0, 1)
                or 0
            helper48("level", helper39(helper38(value53, "Level")))
            helper48(
                "xp",
                helper22(value52)
                        and helper22(value49)
                        and helper39(value52) .. " / " .. helper39(value49) .. "  " .. string.format(
                            "%.1f%%",
                            value50 * 100
                        )
                    or "--",
                value11.accent,
                value50
            )
            helper48(
                "xpLeft",
                helper22(value52) and helper22(value49) and helper39(math.max(0, value49 - value52)) or "--"
            )
            helper48("gold", helper39(helper38(value53, "Gold")), value11.amber)
            helper48("gems", helper39(helper38(value53, "Gems")), value11.accent)
            helper48("skillPoints", helper39(helper38(value, "skillPoints")))
            helper48("physical", helper39(helper38(value, "physicalPower")))
            helper48("spell", helper39(helper38(value, "spellPower")))
            helper48("stamina", helper39(helper38(value, "stamina")))
            value49 = os.clock()
            if value49 - value37 >= 1 then
                value37 = value49
                pcall(function()
                    value38 = value9.Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                pcall(function()
                    value39 = value9:GetTotalMemoryUsageMb()
                end)
            end
            helper48("fps", helper39(value36.fps))
            helper48("mapFps", helper39(value36.mapFps))
            helper48("frameTime", value36.fps > 0 and string.format("%.1f ms", 1000 / value36.fps) or "--")
            helper48(
                "ping",
                helper22(value38) and helper39(value38) .. " ms" or "--",
                helper22(value38) and value38 > 200 and value11.amber or value11.text
            )
            helper48("memory", helper22(value39) and helper39(value39) .. " MB" or "--")
            local value54 = {}
            local function helper51(argument)
                if not argument then
                    return
                end
                for index, child in ipairs(argument:GetChildren()) do
                    if child:IsA("Tool") then
                        index = helper38(child, "abilitySlot")
                        if type(index) == "string" then
                            value54[index:lower()] = child
                        end
                    end
                end
            end
            helper51(value:FindFirstChildOfClass("Backpack"))
            helper51(value46)
            value46 = { "q", "e" }
            for index2, entry in ipairs(value46) do
                helper51 = value54[entry]
                value53, index2 =
                    helper51 and (helper38(helper51, "cooldown")),
                    helper51 and (helper38(helper51, "cooldownLength"))
                helper48(entry .. "Name", helper51 and helper51.Name or "Not equipped")
                local value55, value56, value57, value58 =
                    helper22(value53) and value53 <= 0,
                    helper22(value53) and helper22(index2) and index2 > 0 and 1 - math.clamp(
                        value53 / index2,
                        0,
                        1
                    ) or 0,
                    entry .. "Cooldown",
                    helper22(value53)
                helper48(
                    value57,
                    (if value58 then not value58 else "--")
                        or value55 and "READY"
                        or string.format("%.1f s", value53),
                    value55 and value11.green or value11.amber,
                    value56
                )
            end
            value53, value50, value46 = value17.RT or {}, value17.RD or {}, value17.DG or {}
            value52 = helper22(value53.buffUpUntil) and math.max(0, value53.buffUpUntil - value49) or 0
            helper48(
                "buff",
                (if value48 then value51 else "--")
                    or value52 > 0 and string.format("%.1f s", value52)
                    or "Inactive",
                value52 > 0 and value11.green or value11.muted
            )
            helper48(
                "reach",
                helper22(value50.abilityReach or value50.abilityRange)
                        and helper39(value50.abilityReach or value50.abilityRange) .. " studs"
                    or "--"
            )
            value51, value48, value52 = 0, 0
            helper51 = math.huge
            if value47 then
                for key, entry2 in pairs(value50.enemies or {}) do
                    local root, humanoid = entry2.root, entry2.humanoid
                    if root then
                        if root.Parent then
                            if humanoid then
                                if humanoid.Parent then
                                    if humanoid.Health > 0 then
                                        key = root.Position - value47.Position
                                        local value59 = math.sqrt(key.X * key.X + key.Z * key.Z)
                                        if value59 <= value13.radius then
                                            local value60 = value51 + 1
                                            value48 = if entry2.isBoss then value48 + 1 else value48
                                            if value59 < helper51 then
                                                helper51, value52 = value59, entry2
                                            end
                                            value51 = value60
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            helper48("enemyCount", value47 and tostring(value51) or "--")
            helper48("bossCount", value47 and tostring(value48) or "--")
            helper48("nearest", value52 and value52.model and value52.model.Name or "None in range")
            helper48("distance", value52 and helper39(helper51, 1) .. " studs" or "--")
            value48 = value52 and value52.humanoid
            helper48(
                "enemyHealth",
                value48 and helper39(value48.Health) .. " / " .. helper39(value48.MaxHealth) or "--",
                value11.red,
                value48 and value48.MaxHealth > 0 and value48.Health / value48.MaxHealth or 0
            )
            value48, value51, value50, helper51 =
                helper22(value46.now) and value46.now or value49,
                helper22(value46.now) and math.abs(value49 - value46.now) <= 1,
                0,
                0
            for key2, entry3 in pairs(value46.boxes or {}) do
                if entry3.attack then
                    if helper22(entry3.untilAt) then
                        if value48 <= entry3.untilAt then
                            if value48 >= (entry3.from or value48) then
                                value49 = value50 + 1
                                value50 = value49
                            else
                                value52 = helper51 + 1
                                helper51 = value52
                            end
                        end
                    end
                end
            end
            helper48(
                "activeAttacks",
                value47 and value51 and tostring(value50) or "--",
                value50 > 0 and value11.red or value11.text
            )
            helper48(
                "pendingAttacks",
                value47 and value51 and tostring(helper51) or "--",
                helper51 > 0 and value11.amber or value11.text
            )
            value49 = helper22(value46.dangerHere) and value46.dangerHere > 0
            value50 = (if value47 then not value47 else "--")
                or (if value51 then not value51 else "No recent scan")
                or value49 and "Detected"
            value46, value48 =
                value50 or "None detected",
                (if value51 then not value51 else value11.muted) or value49 and value11.red
            helper48("threat", value46, value48 or value11.green)
            value50 = value6:GetPlayers()
            table.sort(value50, function(player, player2)
                return player.UserId < player2.UserId
            end)
            helper51 = 0
            for index3, entry4 in ipairs(value50) do
                value52 = helper50(entry4.Character)
                helper51 = if value52 then if value52.Health > 0 then helper51 + 1 else helper51 else helper51
            end
            helper48("partyCount", tostring(helper51) .. " / " .. tostring(#value50))
            for index4 = 1, 8, 1 do
                value48, value51 = value24["party" .. index4], value50[index4]
                value48.frame.Visible = value51 ~= nil
                if value51 then
                    value52, value47, helper51 =
                        helper50(value51.Character),
                        value48.label,
                        value51 == value and "You" or config2.streamer and "Player " .. index4
                    value47.Text = helper51 or value51.DisplayName
                    value46 = value52 and value52.MaxHealth > 0 and value52.Health / value52.MaxHealth or 0
                    helper48(
                        "party" .. index4,
                        value52 and string.format("%.0f%%", value46 * 100) .. "  " .. helper39(value52.Health)
                            or "Respawning",
                        value46 > 0.3 and value11.green or value11.red,
                        value46
                    )
                end
            end
            helper48("movement", value53.movementState or "--")
            helper48("attack", value53.attackState or "--")
            helper48("coverage", value53.castCoverage or "--")
            helper48(
                "decision",
                helper22(value53.tickMs) and string.format("%.2f ms", value53.tickMs) or "--"
            )
            helper48("route", value17.BR and value17.BR.pathKind or "--")
        end
        local lastAt
        local function helper52()
            if value17 then
                if value18 then
                    if config2 then
                        if config2.mapAttackOneColor then
                            return
                        end
                    else
                        return
                    end
                else
                    return
                end
            else
                return
            end
            if (context.CFG or config2).perfMemo ~= false then
                if value18.lastAt == lastAt then
                    return
                end
                lastAt = value18.lastAt
            end
            if type(value18.viewMode) == "function" then
                if value18.viewMode() ~= "2d" then
                    return
                end
            end
            local value = value17.DG
            if type(value) ~= "table" then
                return
            end
            local value46 = value18.viewFrame
            if not value46 then
                local value47 = value6.LocalPlayer and value6.LocalPlayer:FindFirstChildOfClass("PlayerGui")
                local value48 = value47 and (value47:FindFirstChild("DungeonAutofarmUI"))
                value47 = value48 and (value48:FindFirstChild("HLMinimap"))
                value46 = value47 and (value47:FindFirstChild("View"))
            end
            if not value46 then
                return
            end
            local value49, value50 = helper22(value.now) and value.now or os.clock(), {}
            for key, entry in pairs(value.boxes or {}) do
                local value51, value52 = type(entry) == "table" and entry.attack
                if value51 then
                    key = helper22(entry.untilAt)
                    value52 = if key then value49 <= entry.untilAt else not key
                else
                    value52 = value51
                end
                key = nil
                if value52 then
                    value51 = helper22(entry.from)
                    key = if value51 then value49 + 0.08 >= entry.from else not value51
                else
                    key = value52
                end
                if key then
                    value51 = entry.src
                    if typeof(value51) == "Instance" then
                        if value51:IsA("BasePart") then
                            if value51.Parent then
                                local round, value53, value54 = entry.round == true
                                    or entry.cyl == true
                                    or helper22(entry.r)
                                if not round then
                                    value53, value54 =
                                        math.abs(tonumber(entry.ha) or 0), math.abs(tonumber(entry.hb) or 0)
                                    if value53 <= 0 or value54 <= 0 then
                                        value53, value54 =
                                            (math.max(0.01, value51.Size.X * 0.5)),
                                            math.max(0.01, value51.Size.Z * 0.5)
                                    end
                                end
                                local value55, value56 =
                                    #value50 + 1,
                                    { color = value51.Color, round = round, a = value53, b = value54 }
                                value56.r, value50[value55] = math.abs(tonumber(entry.r) or 0), value56
                            end
                        end
                    end
                end
            end
            if #value50 == 0 then
                return
            end
            value49 = {}
            for index, child in ipairs(value46:GetChildren()) do
                if child:IsA("Frame") then
                    if child.Name == "Frame" then
                        if child.ZIndex == 4 then
                            if child.Visible then
                                value49[#value49 + 1] = child
                            end
                        end
                    end
                end
            end
            if #value49 == 0 then
                return
            end
            value = {}
            for index2, entry2 in ipairs(value49) do
                if not (entry2:FindFirstChildOfClass("UICorner")) then
                    local value57, value58 =
                        math.max(1, entry2.Size.X.Offset), math.max(1, entry2.Size.Y.Offset)
                    local value59, value60, value61 = math.max(value57, value58)
                        / math.max(1, math.min(value57, value58))
                    for index3, entry3 in ipairs(value50) do
                        if not entry3.round then
                            if entry3.a then
                                if entry3.b then
                                    if entry3.a > 0 then
                                        if entry3.b > 0 then
                                            index3 = math.max(entry3.a, entry3.b)
                                                / math.max(0.01, math.min(entry3.a, entry3.b))
                                            index2 = math.abs(math.log(value59 / index3))
                                            if value60 then
                                                if index2 < value60 then
                                                    value60, value61 = index2, entry3
                                                end
                                            else
                                                value60, value61 = index2, entry3
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if value61 then
                        if value60 < 0.28 then
                            value[#value + 1] = math.max(value57, value58)
                                / (2 * math.max(value61.a, value61.b))
                        end
                    end
                end
            end
            table.sort(value)
            local value62
            if #value > 0 then
                local value63 = math.floor((#value + 1) / 2)
                value62 = #value % 2 == 1 and value[value63] or (value[value63] + value[value63 + 1]) * 0.5
            end
            for index4, entry4 in ipairs(value49) do
                local value64, value65, value66 =
                    entry4:FindFirstChildOfClass("UICorner") ~= nil,
                    math.max(1, entry4.Size.X.Offset),
                    math.max(1, entry4.Size.Y.Offset)
                value, index4 = nil
                for index5, entry5 in ipairs(value50) do
                    if entry5.round == value64 then
                        index5 = nil
                        if value64 then
                            index5 = if value62
                                then if entry5.r > 0
                                    then math.abs(math.max(value65, value66) / (2 * entry5.r) - value62)
                                        / math.max(value62, 0.001)
                                    else 0
                                else 0
                        else
                            if entry5.a then
                                if entry5.b then
                                    if entry5.a > 0 then
                                        if entry5.b > 0 then
                                            local value67, value68 =
                                                math.max(value65, value66) / math.max(
                                                    1,
                                                    math.min(value65, value66)
                                                ),
                                                math.max(entry5.a, entry5.b) / math.max(
                                                    0.01,
                                                    math.min(entry5.a, entry5.b)
                                                )
                                            local value69 = math.abs(math.log(value67 / value68))
                                            if value62 then
                                                value67 = math.max(value65, value66)
                                                    / (2 * math.max(entry5.a, entry5.b))
                                                index5 = value69
                                                    + math.abs(value67 - value62)
                                                        / math.max(value62, 0.001)
                                                        * 0.35
                                            else
                                                index5 = value69
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if index5 then
                            if value then
                                if index5 < value then
                                    value, index4 = index5, entry5
                                end
                            else
                                value, index4 = index5, entry5
                            end
                        end
                    end
                end
                if index4 then
                    entry4.BackgroundColor3 = index4.color
                    value65 = entry4:FindFirstChildOfClass("UIStroke")
                    if value65 then
                        value65.Color = index4.color
                    end
                end
            end
        end
        local function helper53()
            helper44()
            if value33 then
                if value33.alive then
                    if value33.setEnabled then
                        pcall(value33.setEnabled, value34)
                    end
                end
            end
            value33, value34 = nil, nil
            for index, entry in ipairs(value22) do
                entry:Disconnect()
            end
            table.clear(value22)
            if value19 then
                if value19.Parent then
                    if value21 then
                        local value = value19
                        value.Position = value21.position
                        value = value19
                        value.Size = value21.size
                        value = value19
                        value.Visible = value21.visible
                    end
                end
            end
            if config2 then
                for key, entry2 in pairs(value23) do
                    if key ~= "_zoom" then
                        if config2[key] == value29[key] then
                            local config3 = config2
                            config3[key] = entry2.value
                        end
                    end
                end
            end
            if value18 then
                if value23._zoom then
                    if value18.zoomB == value29._zoom then
                        local value46 = value18
                        value46.zoomB = value23._zoom.value
                    end
                end
            end
            if value20 then
                value20:Destroy()
            end
            value17, value18, config2, statsFrame2, value19, value20, value21 =
                nil, nil, nil, nil, nil, nil, nil
            table.clear(value23)
            table.clear(value29)
            table.clear(value24)
            table.clear(value25)
            table.clear(value26)
            table.clear(value27)
            table.clear(value28)
            table.clear(classicPlus.controls)
            value30 = false
            classicPlus.status = "Waiting for Harvard"
        end
        local function helper54(argument)
            local value, config3
            value, config3, value17 = argument.MM, argument.CFG, argument
            value18, config2 = value, config3
            statsFrame2 = value18.statsFrame
            value19 = statsFrame2 and statsFrame2:FindFirstChildOfClass("ScrollingFrame")
            if not value19 then
                value17, value18, config2 = nil, nil, nil
                return false
            end
            value21 = { position = value19.Position, size = value19.Size, visible = value19.Visible }
            for key, entry in pairs(value13.native) do
                helper43(key, entry)
            end
            helper49()
            helper24()
            helper25()
            value36.last = value18.lastAt
            classicPlus.status = "Ready (open Classic map)"
            return true
        end
        local function helper55()
            local value = context.MM
            if type(value) == "table" then
                if value.statsFrame then
                    if value.statsFrame.Parent then
                        if context.CFG then
                            if context.RT then
                                if not context.RT.destroyed then
                                    helper54(context)
                                end
                            end
                        end
                    end
                end
            end
        end
        classicPlus.show = function(tab2)
            assert(table.find({ "Overview", "Combat", "Session" }, tab2), "Unknown tab")
            value13.tab = tab2
            helper40()
            if helper24 then
                if value20 then
                    helper24()
                    helper25()
                end
            end
        end
        classicPlus.inspect = function()
            local value = {
                alive = classicPlus.alive,
                status = classicPlus.status,
                attached = value17 ~= nil,
                tab = value13.tab,
                errors = classicPlus.errors,
                gameFPS = value36.fps,
                mapFPS = value36.mapFps,
                uiInstances = value20 and #value20:GetDescendants() or 0,
                values = table.clone(classicPlus.values),
            }
            return value
        end
        classicPlus.destroy = function()
            if not classicPlus.alive then
                return
            end
            classicPlus.alive = false
            if now then
                helper41()
                now = nil
            end
            pcall(value7.UnbindFromRenderStep, value7, "HLClassicNativeAttackColors")
            if connection then
                connection:Disconnect()
            end
            if connection2 then
                connection2:Disconnect()
            end
            helper53()
            classicPlus.status = "Stopped"
            if value3[value4] == classicPlus then
                value3[value4] = nil
            end
            if context.ClassicPlus == classicPlus then
                context.ClassicPlus = nil
            end
        end
        local function value2()
            value36.frames = value36.frames + 1
        end
        connection2 = value7.RenderStepped:Connect(value2)
        pcall(value7.UnbindFromRenderStep, value7, "HLClassicNativeAttackColors")
        value2, helper6 =
            Enum.RenderPriority.Last.Value, function()
                if classicPlus.alive then
                    pcall(helper52)
                end
            end
        value7:BindToRenderStep("HLClassicNativeAttackColors", value2 + 100, helper6)
        connection = value7.Heartbeat:Connect(function()
            if not classicPlus.alive then
                return
            end
            local since = os.clock()
            if value17 then
                if value18.lastAt ~= value36.last then
                    value36.last = value18.lastAt
                    value36.draws = value36.draws + 1
                end
            end
            local value = since - value36.since
            if value >= 1 then
                value36.fps = value36.frames / value
                value36.mapFps = value36.draws / value
                value36.frames = 0
                value36.draws = 0
                value36.since = since
            end
            if since - value31 < 0.1 then
                return
            end
            value31 = since
            local success, value46 = pcall(function()
                if now then
                    if since - now >= 0.6 then
                        helper41()
                        now = nil
                    end
                end
                if not value17 then
                    return
                end
                if value17.RT.destroyed then
                    classicPlus.destroy()
                    return
                end
                if value17.MM ~= value18 then
                    helper53()
                    return
                elseif value17.CFG ~= config2 then
                    helper53()
                    return
                elseif not statsFrame2.Parent then
                    helper53()
                    return
                end
                helper45()
                helper24()
                if value20.Visible then
                    if value13.tab ~= "Session" then
                        if since - value32 >= value13.refresh then
                            value32 = since
                            helper25()
                        end
                    end
                end
            end)
            if not success then
                classicPlus.errors = classicPlus.errors + 1
                warn("[Classic Plus] Restored original panel after error: " .. tostring(value46))
                classicPlus.destroy()
            end
        end)
        task.spawn(function()
            while classicPlus.alive do
                if not value17 then
                    local success, value = pcall(helper55)
                    if not success then
                        classicPlus.errors = classicPlus.errors + 1
                        warn("[Classic Plus] Could not attach: " .. tostring(value))
                        classicPlus.destroy()
                        return
                    end
                end
                task.wait(2)
            end
        end)
    end)
    if not band2 then
        warn("[Classic Plus] " .. tostring(helper18))
    end
    do
        local sharedValue90 = { last = 0, previewUntil = 0 }
        sharedValue90.placedAt = -math.huge
        context.RC = sharedValue90
        local sharedValue91, sharedValue92, sharedValue93 = config.restCardW or 440, 104, 148
        local hlRestCard = Instance.new("Frame")
        hlRestCard.Name, hlRestCard.AnchorPoint, hlRestCard.Position =
            "HLRestCard", Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, config.restCardTop or 66)
        hlRestCard.Size, hlRestCard.BackgroundColor3 =
            UDim2.fromOffset(sharedValue91, sharedValue92), Color3.fromRGB(40, 40, 40)
        hlRestCard.BackgroundTransparency = 0.18
        hlRestCard.BorderSizePixel = 0
        hlRestCard.ZIndex = 5
        hlRestCard.Visible = false
        hlRestCard.Parent = runtimeState.scriptGui
        green = Instance.new("UICorner")
        green.CornerRadius = UDim.new(0, 12)
        green.Parent = hlRestCard
        hlBugReport = Instance.new("UIStroke")
        hlBugReport.Color, hlBugReport.Thickness, hlBugReport.Transparency, hlBugReport.ApplyStrokeMode =
            Color3.fromRGB(115, 115, 115), 2, 0.15, Enum.ApplyStrokeMode.Border
        hlBugReport.Parent = hlRestCard
        local function helper207(argument, argument2)
            if
                not (
                    pcall(function()
                        argument.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", argument2)
                    end)
                )
            then
                argument.Font = Enum.Font.GothamBold
            end
        end
        local function stroke3(argument, argument2, textSize, textColor3, argument3)
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency, label.Position, label.Size =
                1, UDim2.new(0, 12, 0, argument), UDim2.new(1, -24, 0, argument2)
            label.ZIndex = 6
            label.TextXAlignment, label.TextYAlignment =
                Enum.TextXAlignment.Center, Enum.TextYAlignment.Center
            label.TextSize = textSize
            label.TextColor3 = textColor3
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Text = ""
            helper207(label, argument3)
            label.Parent = hlRestCard
            return label
        end
        helper18 = Color3.fromRGB(135, 240, 130)
        local textControl33 = stroke3(9, 26, 24, helper18, Enum.FontWeight.Bold)
        local textControl34 = stroke3(35, 36, 32, Color3.fromRGB(255, 255, 255), Enum.FontWeight.ExtraBold)
        local textControl35 = stroke3(72, 22, 18, Color3.fromRGB(255, 255, 255), Enum.FontWeight.Bold)
        local requeueNow = Instance.new("TextButton")
        requeueNow.Name = "RequeueNow"
        requeueNow.Text = "Requeue now"
        requeueNow.AutoButtonColor = false
        requeueNow.BorderSizePixel = 0
        requeueNow.AnchorPoint, requeueNow.Position, requeueNow.Size =
            Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 104), UDim2.fromOffset(190, 32)
        requeueNow.ZIndex = 7
        requeueNow.Visible = false
        requeueNow.BackgroundColor3 = Color3.fromRGB(62, 62, 62)
        requeueNow.TextColor3 = helper18
        requeueNow.TextSize = 18
        helper207(requeueNow, Enum.FontWeight.Bold)
        requeueNow.Parent = hlRestCard
        band2 = Instance.new("UICorner")
        band2.CornerRadius = UDim.new(0, 8)
        band2.Parent = requeueNow
        stroke3 = Instance.new("UIStroke")
        stroke3.Color, stroke3.Thickness, stroke3.Transparency, stroke3.ApplyStrokeMode =
            helper18, 1.5, 0.2, Enum.ApplyStrokeMode.Border
        stroke3.Parent = requeueNow
        local function helper208()
            requeueNow.BackgroundColor3 = Color3.fromRGB(78, 78, 78)
        end
        requeueNow.MouseEnter:Connect(helper208)
        local function helper209()
            requeueNow.BackgroundColor3 = Color3.fromRGB(62, 62, 62)
        end
        requeueNow.MouseLeave:Connect(helper209)
        local function helper210()
            local value = context.MD
            if value then
                if value.hold then
                    if value.halted then
                        return
                    end
                else
                    return
                end
            else
                return
            end
            if value.hold.farmBreak then
                if value.endBreak then
                    value.endBreak("Requeue now")
                    sharedValue90.last = 0
                    return
                end
            end
            value.clear()
            if context.LB then
                if context.LB.place == "Lobby" then
                    if context.queueNow then
                        pcall(context.queueNow, "rest skipped")
                    end
                end
            end
            if context.log then
                context.log("ModDetect", "the wait was skipped by hand (Requeue now) - queueing")
            end
            sharedValue90.last = 0
        end
        requeueNow.Activated:Connect(helper210)
        local function dhms(argument)
            argument = math.max(math.floor(argument), 0)
            local value, value2, value3, value4 =
                math.floor(argument / 86400),
                math.floor(argument / 3600) % 24,
                math.floor(argument / 60) % 60,
                argument % 60
            if value > 0 then
                return ("%dd %dh %dm %ds"):format(value, value2, value3, value4)
            end
            if value2 > 0 then
                return ("%dh %dm %ds"):format(value2, value3, value4)
            end
            return ("%dm %ds"):format(value3, value4)
        end
        sharedValue90.dhms = dhms
        local function helper211(argument)
            local value = argument
            while value and not value:IsA("LayerCollector") do
                if value:IsA("GuiObject") then
                    if not value.Visible then
                        return false
                    end
                end
                value = value.Parent
            end
            return value ~= nil and value:IsA("ScreenGui") and value.Enabled
        end
        sharedValue90.place = function()
            local top, value, value2, value3 =
                getService("GuiService"):GetGuiInset().Y,
                hlRestCard.AbsoluteSize.X,
                hlRestCard.AbsoluteSize.Y,
                workspaceService.CurrentCamera and workspaceService.CurrentCamera.ViewportSize or Vector2.new(
                    1920,
                    1080
                )
            local value4, value5, value6, value7 =
                value3.X * 0.5 - value * 0.5,
                value3.X * 0.5 + value * 0.5,
                {},
                localPlayer:FindFirstChildOfClass("PlayerGui")
            if value7 then
                for index, descendant in ipairs(value7:GetDescendants()) do
                    if descendant:IsA("GuiObject") then
                        if
                            not (runtimeState.scriptGui and descendant:IsDescendantOf(runtimeState.scriptGui))
                        then
                            index, value = descendant.AbsolutePosition, descendant.AbsoluteSize
                            if value.X > 6 then
                                if value.Y > 6 then
                                    if value.X < value3.X * 0.6 then
                                        if value.Y < value3.Y * 0.5 then
                                            if index.X < value5 then
                                                if index.X + value.X > value4 then
                                                    if index.Y < 360 then
                                                        if
                                                            descendant.BackgroundTransparency < 0.9
                                                            or (descendant:IsA("TextLabel") or descendant:IsA(
                                                                "TextButton"
                                                            )) and descendant.Text ~= "" and descendant.TextTransparency < 0.9
                                                            or (
                                                                    descendant:IsA("ImageLabel")
                                                                    or descendant:IsA("ImageButton")
                                                                )
                                                                and descendant.Image ~= ""
                                                                and descendant.ImageTransparency < 0.9
                                                        then
                                                            if helper211(descendant) then
                                                                local value8, value9 =
                                                                    #value6 + 1, { y0 = index.Y + top }
                                                                value9.y1, value6[value8] =
                                                                    index.Y + value.Y + top, value9
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
                end
            end
            value3 = runtimeState.scriptGui and runtimeState.scriptGui:FindFirstChild("HLMinimap")
            if value3 then
                if value3.Visible then
                    if not (context.MM and context.MM.big) then
                        value, value7 = value3.AbsolutePosition, value3.AbsoluteSize
                        if value.X < value5 then
                            if value.X + value7.X > value4 then
                                local value10, value11 = #value6 + 1, { y0 = value.Y + top }
                                value11.y1, value6[value10] = value.Y + value7.Y + top, value11
                            end
                        end
                    end
                end
            end
            top = config.restCardTop or 66
            for index2 = 1, 8, 1 do
                value3 = false
                for index3, entry in ipairs(value6) do
                    if entry.y0 < top + value2 then
                        if entry.y1 > top then
                            value5, value4 = entry.y1 + 8, true
                            top, value3 = value5, value4
                        end
                    end
                end
                if not value3 then
                    break
                end
            end
            hlRestCard.Position = UDim2.new(0.5, 0, 0, top)
            sharedValue90.top = top
        end
        sharedValue90.preview = function(argument)
            sharedValue90.previewUntil = os.clock() + (tonumber(argument) or 15)
            sharedValue90.last = 0
        end
        sliderConnections[#sliderConnections + 1] = runService.Heartbeat:Connect(function()
            if runtimeState.destroyed then
                return
            end
            local value = os.clock()
            if value - sharedValue90.last < 0.25 then
                return
            end
            sharedValue90.last = value
            pcall(function()
                local value2 = context.MD
                local value3 = value2 and value2.hold
                local value4, value5 =
                    value3 and value2.left and value2.left() or 0, value < sharedValue90.previewUntil
                if
                    not (
                        value5
                        or value3 ~= nil
                            and value4 > 0
                            and (config.modDetect == true or value3.farmBreak == true)
                            and config.modRestCard ~= false
                    )
                then
                    if hlRestCard.Visible then
                        hlRestCard.Visible = false
                    end
                    return
                end
                local visible = value5 or value3 ~= nil and not value2.halted
                if requeueNow.Visible ~= visible then
                    requeueNow.Visible = visible
                    hlRestCard.Size =
                        UDim2.fromOffset(sharedValue91, visible and sharedValue93 or sharedValue92)
                    sharedValue90.placedAt = -math.huge
                end
                visible = hlRestCard.Visible
                if if visible then value - sharedValue90.placedAt > 2 else not visible then
                    sharedValue90.placedAt = value
                    pcall(sharedValue90.place)
                end
                if not hlRestCard.Visible then
                    hlRestCard.Visible = true
                end
                textControl33.Text = "Countdown to requeue"
                if value5 then
                    if not (value3 and value4 > 0) then
                        textControl34.Text = dhms(sharedValue90.previewUntil - value + 1000)
                        textControl35.Text = "Mod detection flagged - requeues "
                            .. tostring(value2 and value2.queueText and value2.queueText() or "?")
                        return
                    end
                end
                textControl34.Text = dhms(value4)
                local value6, value7 =
                    value3.farmBreak and (value3.test and "Test rest" or "On a break")
                        or "Mod detection flagged",
                    false
                pcall(function()
                    value7 = context.AF and context.AF.role and context.AF.role() ~= nil
                end)
                value5, visible, value4 = value7, value2.halted and " - heading back to the lobby"
                if visible then
                    value4 = visible
                else
                    local value8
                    if value5 then
                        local toString, value9 =
                            tostring, value3.queue or value2.queueText and value2.queueText()
                        value8 = " - requeues " .. toString(value9 or "?")
                    else
                        value8 = value5
                    end
                    value4 = value8 or " - not in a running party"
                end
                textControl35.Text = value6 .. value4
            end)
        end)
    end
    do
        local candy = { got = 0, note = "off", bad = {} }
        context.CANDY = candy
        local sharedValue94, sharedValue95 =
            getService("PathfindingService"), {
                ["inner focus"] = true,
                ["inner rage"] = true,
                ["enhanced inner focus"] = true,
                ["enhanced inner rage"] = true,
                ["pulse waves"] = true,
                ["arrow rain"] = true,
            }
        candy.gameList = function()
            if candy.tab then
                return candy.tab
            end
            if os.clock() - (candy.tabTry or -math.huge) < 5 then
                return nil
            end
            candy.tabTry = os.clock()
            pcall(function()
                for index, entry in ipairs(getconnections(runService.RenderStepped)) do
                    index = entry.Function
                    if
                        type(index) == "function"
                        and tostring(debug.info(index, "s")):find("LobbyGhosts", 1, true)
                    then
                        for key, entry2 in pairs(debug.getupvalues(index)) do
                            if type(entry2) == "table" then
                                entry, key = next(entry2)
                                if key == nil then
                                    candy.tab = entry2
                                elseif type(key) == "table" then
                                    if typeof(key.point) == "Vector3" then
                                        if key.landTime ~= nil then
                                            candy.tab = entry2
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            return candy.tab
        end
        candy.candies = function()
            local value, success = {}, candy.gameList()
            if success then
                for key, entry in pairs(success) do
                    if type(entry) == "table" then
                        if typeof(entry.point) == "Vector3" then
                            value[key] = entry.point
                        end
                    end
                end
                return value
            end
            for index, child in ipairs(workspaceService:GetChildren()) do
                if child.Name == "Candy" then
                    if child:IsA("Model") then
                        success, index = pcall(function()
                            return child:GetPivot().Position
                        end)
                        if success then
                            value[child] = index
                                - Vector3.new(0, tonumber(child:GetAttribute("RestHeight")) or 1.3, 0)
                        end
                    end
                end
            end
            return value
        end
        candy.pick = function(argument)
            local now, position = os.clock(), argument.Position
            argument = candy.candies()
            local function helper6(vector)
                return Vector3.new(vector.X - position.X, 0, vector.Z - position.Z).Magnitude
                    + math.abs(vector.Y - position.Y) * 0.5
            end
            local value, value2, goalId
            for key, entry in pairs(argument) do
                if not (candy.bad[key] and candy.bad[key] > now) then
                    local value3 = helper6(entry)
                    if value then
                        if value3 < value then
                            value, value2, goalId = value3, entry, key
                        end
                    else
                        value, value2, goalId = value3, entry, key
                    end
                end
            end
            local value4 = candy.goalId ~= nil and argument[candy.goalId]
            if value4 then
                if goalId ~= candy.goalId then
                    if not (candy.bad[candy.goalId] and candy.bad[candy.goalId] > now) then
                        if helper6(value4) - (value or 0) < (config.candySwitch or 8) then
                            return value4, candy.goalId, (helper6(value4))
                        end
                    end
                end
            end
            candy.goalId = goalId
            return value2, goalId, value
        end
        candy.route = function(argument, pathGoal, pathFor)
            local value = os.clock()
            if
                not (
                    candy.pathFor ~= pathFor
                    or candy.path == nil
                    or candy.pathGoal and (candy.pathGoal - pathGoal).Magnitude > 3
                )
            then
                if candy.path == false then
                    if not (value - (candy.pathAt or -math.huge) > 2) then
                        return true
                    end
                else
                    return true
                end
            end
            candy.pathFor = pathFor
            candy.pathGoal = pathGoal
            candy.pathAt = value
            candy.path = false
            candy.wp = 1
            local value2 = sharedValue94:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                WaypointSpacing = 8,
            })
            if
                pcall(function()
                    value2:ComputeAsync(argument.Position, pathGoal)
                end) and value2.Status == Enum.PathStatus.Success
            then
                value = value2:GetWaypoints()
                pathFor = value[#value]
                if pathFor then
                    if
                        Vector3.new(pathFor.Position.X - pathGoal.X, 0, pathFor.Position.Z - pathGoal.Z).Magnitude
                        > 3.5
                    then
                        return false
                    elseif math.abs(pathFor.Position.Y - pathGoal.Y) > 5 then
                        return false
                    end
                end
                if #value > 0 then
                    candy.path, candy.wp = value, math.min(2, #value)
                end
            elseif math.abs(argument.Position.Y - pathGoal.Y) > 6 then
                return false
            end
            return true
        end
        candy.press = function(argument, vector)
            local pressAt = os.clock()
            if pressAt - (candy.pressAt or -math.huge) < (config.candyPressEvery or 0.45) then
                return
            end
            local character = localPlayer.Character
            local valueObject = character and (character:FindFirstChild("busyCasting"))
            if valueObject then
                if valueObject.Value == true then
                    return
                end
            end
            local iterateArray, value = ipairs, { localPlayer.Backpack, character }
            for key, entry in iterateArray(value) do
                for index, entry2 in ipairs(entry and entry:GetChildren() or {}) do
                    if entry2:IsA("Tool") and sharedValue95[string.lower(entry2.Name)] then
                        local cooldown, localEvent =
                            entry2:FindFirstChild("cooldown"), entry2:FindFirstChild("localEvent")
                        if
                            cooldown
                            and localEvent
                            and localEvent:IsA("BindableEvent")
                            and (tonumber(cooldown.Value) or 0) <= 0
                        then
                            candy.pressAt = pressAt
                            local vector2 =
                                Vector3.new(vector.X - argument.Position.X, 0, vector.Z - argument.Position.Z)
                            if vector2.Magnitude > 1 then
                                pcall(function()
                                    argument.CFrame =
                                        CFrame.lookAt(argument.Position, argument.Position + vector2)
                                end)
                            end
                            pcall(function()
                                localEvent:Fire()
                            end)
                            return
                        end
                    end
                end
            end
        end
        candy.stop = function()
            local value = candy.active
            candy.active = false
            candy.goal = nil
            candy.path = nil
            candy.pathFor = nil
            candy.goalId = nil
            candy.moveTarget = nil
            if not value then
                return
            end
            value = localPlayer.Character
            local humanoid = value and (value:FindFirstChildOfClass("Humanoid"))
            local value2 = value and (value:FindFirstChild("HumanoidRootPart"))
            if humanoid then
                pcall(function()
                    if value2 then
                        humanoid:MoveTo(value2.Position)
                    end
                    humanoid.WalkSpeed = config.tweenWalk or 16
                end)
            end
        end
        candy.set = function(argument)
            if not argument then
                candy.stop()
                candy.note = "off"
            end
        end
        candy.status = function()
            if config.autoCandy ~= true then
                return "Off."
            end
            local candy2, note, got = localPlayer:FindFirstChild("Candy"), candy.note, candy.got
            local value = candy2 and " (you have " .. tostring(candy2.Value) .. ")" or ""
            return ("%s. Picked up %d since it was switched on%s."):format(note, got, value)
        end
        candy.tick = function()
            local lastCandy = localPlayer.Character
            local humanoid = lastCandy and (lastCandy:FindFirstChildOfClass("Humanoid"))
            local value, value2 =
                lastCandy and (lastCandy:FindFirstChild("HumanoidRootPart")),
                localPlayer:FindFirstChild("Candy")
            if value2 then
                lastCandy = tonumber(value2.Value) or 0
                if candy.lastCandy then
                    if lastCandy > candy.lastCandy then
                        if config.autoCandy == true then
                            candy.got = candy.got + (lastCandy - candy.lastCandy)
                        end
                    end
                end
                candy.lastCandy = lastCandy
            end
            value2 = if config.autoCandy ~= true
                then "Off"
                else if game.PlaceId ~= 77649408247578
                    then "Waiting for the lobby"
                    else if runtimeState.modHalt or context.MD and context.MD.halted
                        then "Held still by mod detection"
                        else if humanoid and value
                            then if humanoid.Health > 0 then nil else "Waiting for the character"
                            else "Waiting for the character"
            if value2 then
                candy.stop()
                candy.note = value2
                return
            end
            local goal, progFor, progPos = candy.pick(value)
            if not goal then
                candy.stop()
                candy.note = "Waiting for the ghosts to throw candy"
                return
            end
            candy.active = true
            candy.note = ("Going for a candy %d studs away"):format(math.floor(progPos or 0))
            value2, progPos = os.clock(), value.Position
            if Vector3.new(goal.X - progPos.X, 0, goal.Z - progPos.Z).Magnitude < 3.5 then
                if math.abs(progPos.Y - goal.Y) > 6 then
                    candy.bad[progFor] = value2 + (config.candySkipFor or 60)
                    candy.goalId = nil
                    candy.goal = nil
                    candy.note = "A candy on a roof - skipped"
                    return
                end
            end
            lastCandy = candy.progAt
            if if lastCandy then candy.progFor ~= progFor else not lastCandy then
                candy.progPos = progPos
                candy.progAt = value2
                candy.progFor = progFor
                candy.stalls = 0
            elseif value2 - candy.progAt > 1.5 then
                if Vector3.new(progPos.X - candy.progPos.X, 0, progPos.Z - candy.progPos.Z).Magnitude < 2 then
                    if Vector3.new(goal.X - progPos.X, 0, goal.Z - progPos.Z).Magnitude > 3 then
                        candy.stalls = candy.stalls + 1
                        pcall(function()
                            humanoid.Jump = true
                        end)
                        candy.path = nil
                        if candy.stalls >= 3 then
                            candy.bad[progFor] = value2 + 60
                            candy.goalId = nil
                            candy.stalls = 0
                        end
                    end
                end
                candy.progPos = progPos
                candy.progAt = value2
            end
            if candy.route(value, goal, progFor) == false then
                candy.bad[progFor] = value2 + (config.candySkipFor or 60)
                candy.goalId = nil
                candy.goal = nil
                candy.path = nil
                candy.pathFor = nil
                candy.note = "A candy on a roof - skipped"
                return
            end
            candy.goal = goal
            candy.press(value, goal)
        end
        sliderConnections[#sliderConnections + 1] = runService.Heartbeat:Connect(function()
            if candy.active then
                if runtimeState.destroyed then
                    return
                end
            else
                return
            end
            local value = localPlayer.Character
            local humanoid, value2 =
                value and (value:FindFirstChildOfClass("Humanoid")),
                value and (value:FindFirstChild("HumanoidRootPart"))
            if humanoid then
                if value2 then
                    if not candy.goal then
                        return
                    end
                else
                    return
                end
            else
                return
            end
            value = tonumber(config.candySpeed) or 28
            if humanoid.WalkSpeed ~= value then
                humanoid.WalkSpeed = value
            end
            local position, moveTarget, path = value2.Position, candy.goal, candy.path
            if path then
                value = path[candy.wp]
                while
                    value
                    and Vector3.new(position.X - value.Position.X, 0, position.Z - value.Position.Z).Magnitude < 3
                    and candy.wp < #path
                do
                    candy.wp = candy.wp + 1
                    value = path[candy.wp]
                    if value then
                        if value.Action == Enum.PathWaypointAction.Jump then
                            humanoid.Jump = true
                        end
                    end
                end
                moveTarget = if value
                    then if candy.wp < #path then value.Position else moveTarget
                    else moveTarget
            end
            if Vector3.new(candy.goal.X - position.X, 0, candy.goal.Z - position.Z).Magnitude < 1.5 then
                if candy.moveTarget then
                    candy.moveTarget = nil
                    humanoid:MoveTo(position)
                end
                return
            end
            value, value2 = os.clock(), candy.moveTarget
            if
                (if value2 then (candy.moveTarget - moveTarget).Magnitude > 0.5 else not value2)
                or value - (candy.moveAt or 0) > 1
            then
                candy.moveTarget = moveTarget
                candy.moveAt = value
                humanoid:MoveTo(moveTarget)
            end
        end)
        task.spawn(function()
            while not runtimeState.destroyed do
                local success, value = pcall(candy.tick)
                if not success then
                    candy.note = "Error: " .. tostring(value)
                end
                task.wait(candy.active and 0.1 or 0.5)
            end
            pcall(candy.stop)
        end)
    end
    do
        local evstart = {}
        evstart.pickAt = -math.huge
        evstart.readyAt = -math.huge
        evstart.tries = 0
        context.EVSTART = evstart
        local sharedValue96 = getService("ReplicatedStorage")
        getService("Players")
        evstart.choice = function()
            local value = config.pkEventClass or "Mage"
            if evstart.healerOff then
                evstart.healerOff = true
                return value
            elseif evstart.tries >= 2 then
                if evstart.picked == "Healer" then
                    evstart.healerOff = true
                    return value
                end
            end
            local value2 = {}
            pcall(function()
                for index, entry in ipairs(context.AF.load().accounts or {}) do
                    if type(entry) == "table" then
                        if entry.enabled ~= false then
                            value2[#value2 + 1] = tostring(entry.name)
                        end
                    end
                end
            end)
            if #value2 >= (tonumber(config.pkHealerMin) or 2) then
                if string.lower(value2[#value2]) == string.lower(localPlayer.Name) then
                    return "Healer"
                end
            end
            return value
        end
        local function helper212()
            local iterateArray, value =
                ipairs, { localPlayer:FindFirstChildOfClass("Backpack"), localPlayer.Character }
            for key, entry in iterateArray(value) do
                if entry then
                    for index, child in ipairs(entry:GetChildren()) do
                        if child:IsA("Tool") then
                            return true
                        end
                    end
                end
            end
            return false
        end
        evstart.tick = function()
            local remotes = sharedValue96:FindFirstChild("remotes")
            if not remotes then
                return
            end
            local dungeonProgress, value, value2 =
                workspaceService:FindFirstChild("dungeonProgress"),
                context.isEvent and context.isEvent(),
                os.clock()
            if evstart.job ~= game.JobId then
                evstart.job, evstart.arrived, evstart.picked, evstart.done, evstart.tries, evstart.pickAt, evstart.readyAt =
                    game.JobId, value2, nil, false, 0, -math.huge, -math.huge
                evstart.healerOff = nil
                evstart.firstPickAt = nil
                evstart.sugarAt = nil
                evstart.sugarTries = 0
            end
            if not value then
                return
            end
            local value3 = localPlayer:FindFirstChildOfClass("PlayerGui")
            local value4 = value3 and (value3:FindFirstChild("selectClassGui"))
            value3 = remotes:FindFirstChild("equipSet")
            if value or value4 then
                if not evstart.done then
                    if evstart.picked and helper212() then
                        evstart.done = true
                        if context.log then
                            context.log("Event", "Quick Gear Select: " .. tostring(evstart.picked))
                        end
                    elseif
                        evstart.picked
                        and evstart.firstPickAt
                        and value2 - evstart.firstPickAt > (tonumber(config.pkPickMaxWait) or 10)
                    then
                        evstart.done = true
                        if context.log then
                            context.log(
                                "Event",
                                "Quick Gear Select: "
                                    .. tostring(evstart.picked)
                                    .. " - no spells came, readying anyway"
                            )
                        end
                    elseif value4 and value3 then
                        if value2 - evstart.pickAt < 3 then
                            return
                        end
                        if evstart.picked then
                            evstart.tries = evstart.tries + 1
                        end
                        evstart.firstPickAt = evstart.firstPickAt or value2
                        evstart.picked = evstart.choice()
                        evstart.pickAt = value2
                        pcall(value3.FireServer, value3, evstart.picked)
                        pcall(function()
                            value4.Enabled = false
                        end)
                        return
                    else
                        return
                    end
                end
            end
            if value and evstart.done and config.pkSugarstorm ~= false and evstart.picked ~= "Healer" then
                local iterateArray, value5, pkSugar, value6 =
                    ipairs,
                    { localPlayer:FindFirstChildOfClass("Backpack"), localPlayer.Character },
                    false,
                    false
                for key, entry in iterateArray(value5) do
                    if entry then
                        for index, child in ipairs(entry:GetChildren()) do
                            if child:IsA("Tool") then
                                if child.Name == "Sugarstorm" then
                                    pkSugar = true
                                else
                                    value6 = if child.Name == "Witches Brew" then true else value6
                                end
                            end
                        end
                    end
                end
                runtimeState.pkSugar = pkSugar
                if pkSugar then
                    evstart.sugarTries = 0
                elseif value6 then
                    if value2 - (evstart.sugarAt or -math.huge) > 2.5 then
                        if (evstart.sugarTries or 0) < 4 then
                            value5 = localPlayer.Character
                            value3 = value5 and (value5:FindFirstChild("busyCasting"))
                            if not (value3 and value3.Value == true) then
                                evstart.sugarAt, evstart.sugarTries = value2, (evstart.sugarTries or 0) + 1
                                runtimeState.swapHoldUntil = os.clock() + 0.8
                                pcall(function()
                                    local value7 = getService("VirtualInputManager")
                                    local keyCode, value8 = Enum.KeyCode, game
                                    value7:SendKeyEvent(true, keyCode.F, false, value8)
                                    task.delay(0.05, function()
                                        pcall(value7.SendKeyEvent, value7, false, Enum.KeyCode.F, false, game)
                                    end)
                                end)
                                if context.log then
                                    context.log(
                                        "Event",
                                        "Sugarstorm: set swap (F), try " .. tostring(evstart.sugarTries)
                                    )
                                end
                            end
                        end
                    end
                end
            else
                runtimeState.pkSugar = false
            end
            if dungeonProgress then
                if not (dungeonProgress.Value == "playersNotReady") then
                    return
                end
            else
                return
            end
            value3, value = localPlayer:FindFirstChild("ready"), remotes:FindFirstChild("readyUp")
            if value3 then
                if value3.Value == false then
                    if not value then
                        return
                    end
                else
                    return
                end
            else
                return
            end
            if value2 - evstart.pickAt < 1.5 then
                return
            end
            if #(context.partyNotHere and context.partyNotHere() or {}) > 0 then
                if value2 - (evstart.arrived or value2) < (tonumber(config.startPartyWaitMax) or 45) then
                    return
                end
            end
            if value2 - evstart.readyAt < 3 then
                return
            end
            evstart.readyAt = value2
            pcall(value.FireServer, value)
            if context.log then
                context.log("Event", "ready")
            end
        end
        task.spawn(function()
            while not runtimeState.destroyed do
                pcall(evstart.tick)
                task.wait(0.5)
            end
        end)
    end
    do
        local sharedValue97 = { hooked = false, candy = {}, snap = {}, on = {}, err = nil }
        context.PK = sharedValue97
        sharedValue97.MODELS = {
            passivecircle = true,
            staffslamline = true,
            staffbeamstrail = true,
            breathbeam = true,
            pumpkinshockwave = true,
            rainpumpkin = true,
            headexplosion = true,
            thrownpumpkinhead = true,
            snapvines = true,
            thornwall = true,
            branchhub = true,
            treebranch = true,
            candy = true,
            vinepoison = true,
        }
        local sharedValue98 = getService("ReplicatedStorage")
        local sharedValue99, sharedValue100 =
            getService("Players"), {
                "PassiveCircle",
                "LineStrike",
                "Trail",
                "JackOLanternBreath",
                "HeadThrow",
                "PumpkinRain",
                "ThornVines",
                "Snapvines",
                "SnapvineStrike",
                "CandyScatter",
                "CandyTaken",
                "ArenaShrink",
            }
        local function helper213()
            return workspace:GetServerTimeNow()
        end
        local function helper214(argument)
            return os.clock() + ((tonumber(argument) or 0) - helper213())
        end
        local function helper215(vector, vector2)
            local value, value2 = vector.X - vector2.X, vector.Z - vector2.Z
            return math.sqrt(value * value + value2 * value2)
        end
        local function helper216(argument)
            local value = sharedValue98:FindFirstChild("enemyAssets")
            value = value and (value:FindFirstChild("Pumpkin King"))
            return value and (value:FindFirstChild(argument))
        end
        local function helper217()
            return tonumber(config.pkPad) or 2.5
        end
        local function helper218(argument, cframe, size, argument2, untilAt, argument3, ring)
            if not context.addZone then
                return nil
            end
            local value = {
                name = "pk " .. argument,
                kind = "zone",
                bubbleKeep = true,
                exact = true,
                weight = 1,
                madeAt = os.clock(),
                hardPending = true,
                cframe = cframe,
                size = size,
                round = argument2 or nil,
                ring = ring,
                from = argument3 or os.clock(),
                untilAt = untilAt,
            }
            pcall(context.addZone, value)
            return value
        end
        local function helper219(argument, argument2, argument3, argument4, argument5, argument6)
            local value = argument3 + helper217()
            return helper218(
                argument,
                CFrame.new(argument2),
                Vector3.new(value * 2, 14, value * 2),
                true,
                argument4,
                argument5,
                argument6
            )
        end
        local function helper220(argument, argument2, argument3, argument4, untilAt, argument5)
            if not context.addZone then
                return
            end
            local value, value2 = argument3 + helper217(), { { 1, 0 }, { -1, 0 } }
            for index, entry in ipairs(value2) do
                pcall(context.addZone, {
                    name = "pk " .. argument,
                    kind = "zone",
                    bubbleKeep = true,
                    exact = true,
                    weight = 1,
                    madeAt = os.clock(),
                    hardPending = true,
                    cframe = CFrame.new(argument2),
                    size = Vector3.new(value * 2, 14, value * 2),
                    round = true,
                    ring = math.max(argument4 - helper217(), 0.5),
                    sx = entry[1],
                    sz = entry[2],
                    from = argument5 or os.clock(),
                    untilAt = untilAt,
                })
            end
        end
        local function helper221(argument, argument2, argument3, argument4, argument5, argument6, argument7)
            local value = Vector3.new(argument3.X, 0, argument3.Z)
            if value.Magnitude < 0.001 then
                return nil
            end
            value = value.Unit
            argument3 = argument2 + value * (argument4 / 2)
            return helper218(
                argument,
                CFrame.lookAt(argument3, argument3 + value),
                Vector3.new(argument5 + helper217() * 2, 14, argument4 + helper217()),
                false,
                argument6,
                argument7
            )
        end
        local sharedValue101 = sharedValue97.on
        sharedValue97.lanes = {}
        local function helper222(argument, vector, argument2, argument3, hitAt, untilAt)
            if typeof(argument) ~= "Vector3" then
                return
            end
            local value = Vector3.new(vector.X, 0, vector.Z)
            if value.Magnitude < 0.001 then
                return
            end
            value = value.Unit
            table.insert(sharedValue97.lanes, {
                o = argument,
                ux = value.X,
                uz = value.Z,
                len = tonumber(argument2) or 60,
                half = tonumber(argument3) or 3.5,
                hitAt = hitAt,
                untilAt = untilAt,
            })
            while #sharedValue97.lanes > 64 do
                table.remove(sharedValue97.lanes, 1)
            end
        end
        sharedValue97.laneOut = function(vector, argument)
            if config.pkLaneOut == false then
                return nil
            end
            local value, value2 = tonumber(config.pkLaneMargin) or 3, {}
            for index, lane in ipairs(sharedValue97.lanes) do
                if argument < lane.untilAt then
                    value2[#value2 + 1] = lane
                end
            end
            if #value2 == 0 then
                return nil
            end
            local function helper6(argument2, argument3, argument4, argument5)
                local value3, value4 = argument2 - argument4.o.X, argument3 - argument4.o.Z
                argument3 = value3 * argument4.ux + value4 * argument4.uz
                if argument3 < -1 then
                    return false
                elseif argument3 > argument4.len + 1 then
                    return false
                end
                return math.abs(-value3 * argument4.uz + value4 * argument4.ux) < argument4.half + argument5
            end
            argument = nil
            for index2, entry in ipairs(value2) do
                argument = if helper6(vector.X, vector.Z, entry, value)
                    then if argument then if entry.hitAt < argument.hitAt then entry else argument else entry
                    else argument
            end
            if not argument then
                return nil
            end
            local value5, value6 = vector.X - argument.o.X, vector.Z - argument.o.Z
            local value7, value8, value9, value10, value11, value12, value13 =
                -value5 * argument.uz + value6 * argument.ux,
                -argument.uz,
                argument.ux,
                argument.half + value + 0.5,
                { 1, -1 },
                math.huge
            for index3, entry2 in ipairs(value11) do
                value6 = entry2 * value10 - value7
                value5, index3 =
                    Vector3.new(vector.X + value8 * value6, vector.Y, vector.Z + value9 * value6),
                    math.abs(value6)
                for index4, entry3 in ipairs(value2) do
                    index3 = if entry3 ~= argument
                        then if helper6(value5.X, value5.Z, entry3, value * 0.5) then index3 + 50 else index3
                        else index3
                end
                index3 = if sharedValue97.inside
                    then if sharedValue97.inside(value5, 0) then index3 else index3 + 100
                    else index3
                index3 = if sharedValue97.redOnPath
                    then if sharedValue97.redOnPath(vector.X, vector.Z, value5.X, value5.Z)
                        then index3 + 200
                        else index3
                    else index3
                index3 = if sharedValue97.nearRoot
                    then if sharedValue97.nearRoot(value5.X, value5.Z, 1.5) then index3 + 150 else index3
                    else index3
                if index3 < value12 then
                    value12, value13 = index3, value5
                end
            end
            return value13
        end
        sharedValue97.circles = {}
        sharedValue101.PassiveCircle = function(argument)
            local value = helper216("PassiveCircle")
            local value2 = value and value:GetAttribute("Radius") or 12.5
            value = helper219("circle", argument.point, value2, helper214(argument.hitTime) + 0.3)
            if value then
                value.weight = context.pkNoHits and context.pkNoHits() and 1
                    or (tonumber(config.pkCircleWeight) or 0.35)
            end
            if typeof(argument.point) == "Vector3" then
                table.insert(
                    sharedValue97.circles,
                    { p = argument.point, r = tonumber(value2) or 12.5, hitAt = helper214(argument.hitTime) }
                )
                while #sharedValue97.circles > 40 do
                    table.remove(sharedValue97.circles, 1)
                end
            end
        end
        sharedValue97.dashOk = function(vector, argument, argument2, argument3)
            if config.pkCandyDash == false then
                return false
            end
            local value, value2 = argument.X - vector.X, argument.Z - vector.Z
            argument = math.sqrt(value * value + value2 * value2)
            local value3 = math.max(argument - (config.pkDashReach or 2.5), 0)
            if value3 < 0.5 then
                return true
            end
            local value4, value5, value6 = value / argument, value2 / argument, math.max(argument2 or 16, 8)
            if sharedValue97.redOnPath then
                if
                    sharedValue97.redOnPath(
                        vector.X,
                        vector.Z,
                        vector.X + value4 * value3,
                        vector.Z + value5 * value3
                    )
                then
                    return false
                end
            end
            for index, entry in ipairs(sharedValue97.lanes or {}) do
                if argument3 < entry.untilAt then
                    for index2 = 0, value3, 2 do
                        argument2, index = vector.X + value4 * index2, vector.Z + value5 * index2
                        argument, value2 = argument2 - entry.o.X, index - entry.o.Z
                        value = argument * entry.ux + value2 * entry.uz
                        if value >= -1 then
                            if value <= entry.len + 1 then
                                if math.abs(-argument * entry.uz + value2 * entry.ux) < entry.half + 3 then
                                    return false
                                end
                            end
                        end
                    end
                end
            end
            for index3, entry2 in ipairs(sharedValue97.lethal or {}) do
                if argument3 < entry2.landAt + 0.1 then
                    for index4 = 0, value3, 2 do
                        value, argument2 = vector.X + value4 * index4, vector.Z + value5 * index4
                        if
                            (value - entry2.p.X) ^ 2 + (argument2 - entry2.p.Z) ^ 2
                            < (entry2.r + helper217()) ^ 2
                        then
                            return false
                        end
                    end
                end
            end
            for index5 = 0, value3, 2 do
                if sharedValue97.nearRoot then
                    if
                        sharedValue97.nearRoot(vector.X + value4 * index5, vector.Z + value5 * index5, 1.5)
                    then
                        return false
                    end
                end
            end
            argument2 = config.pkDashBody or 1.5
            for index6, circle in ipairs(sharedValue97.circles) do
                if argument3 < circle.hitAt + 0.1 then
                    argument, value, index6 =
                        circle.r + argument2, vector.X - circle.p.X, vector.Z - circle.p.Z
                    value2 = value * value4 + index6 * value5
                    local value7 = value2 * value2 - (value * value + index6 * index6 - argument * argument)
                    if value7 > 0 then
                        local value8 = -value2 - math.sqrt(value7)
                        if -value2 + math.sqrt(value7) > 0 then
                            if value8 < value3 then
                                if
                                    argument3 + (value3 + (value3 - math.max(value8, 0))) / value6
                                    > circle.hitAt - (config.pkDashMargin or 0.25)
                                then
                                    return false
                                end
                            end
                        end
                    end
                end
            end
            return true
        end
        sharedValue101.LineStrike = function(argument)
            sharedValue97.firstFan = true
            local value = os.clock()
            if sharedValue97.lineAt then
                if value - sharedValue97.lineAt > 5 then
                    sharedValue97.fanAt = value
                end
            else
                sharedValue97.fanAt = value
            end
            sharedValue97.lineAt = value
            if typeof(argument.origin) == "Vector3" then
                sharedValue97.fanO = argument.origin
            end
            for index, entry in ipairs(argument.dirs or {}) do
                index, value = ipairs, { entry, -entry }
                for key, entry2 in index(value) do
                    helper221(
                        "line",
                        argument.origin,
                        entry2,
                        argument.radius,
                        argument.width + 2 * (config.pkFanExtra or 0),
                        helper214(argument.hitTime) + (config.pkFanAfter or 0.15)
                    )
                    helper222(
                        argument.origin,
                        entry2,
                        argument.radius,
                        (tonumber(argument.width) or 7) / 2,
                        helper214(argument.hitTime),
                        helper214(argument.hitTime) + (config.pkFanAfter or 0.15)
                    )
                end
            end
        end
        sharedValue101.Trail = function(argument)
            sharedValue97.softUntil =
                math.max(sharedValue97.softUntil or 0, helper214(argument.hitTime) + 0.5)
            for index, entry in ipairs(argument.segments or {}) do
                local value, value2 = entry[1], tonumber(entry[2]) or 0
                if typeof(value) == "CFrame" then
                    helper218(
                        "trail",
                        value,
                        Vector3.new(argument.width + helper217() * 2, 14, value2 + helper217()),
                        false,
                        helper214(argument.hitTime) + 0.35
                    )
                end
            end
        end
        sharedValue101.JackOLanternBreath = function(argument)
            local value = Vector3.new(math.cos(argument.aim), 0, math.sin(argument.aim))
            helper221(
                "breath",
                argument.origin + value * 3,
                value,
                math.max(argument.length - 3, 1) + helper217(),
                argument.width,
                helper214(argument.fireEnd) + 0.3
            )
            helper222(
                argument.origin,
                value,
                argument.length,
                (tonumber(argument.width) or 20) / 2,
                helper214(argument.shootStart),
                helper214(argument.fireEnd) + 0.2
            )
        end
        sharedValue97.lethal = {}
        sharedValue101.HeadThrow = function(argument)
            helper219(
                "head",
                argument.impact,
                tonumber(argument.radius) or 30,
                helper214(argument.impactTime) + 0.3
            )
            if typeof(argument.impact) == "Vector3" then
                table.insert(sharedValue97.lethal, {
                    p = argument.impact,
                    r = tonumber(argument.radius) or 30,
                    landAt = helper214(argument.impactTime),
                    name = "head throw",
                })
                while #sharedValue97.lethal > 16 do
                    table.remove(sharedValue97.lethal, 1)
                end
            end
        end
        sharedValue101.PumpkinRain = function(argument)
            sharedValue97.softUntil = math.max(
                sharedValue97.softUntil or 0,
                helper214(
                    (argument.landTime or 0) + 3 * (argument.ringInterval or 0) + (argument.ringDelay or 0)
                ) + 0.5
            )
            local value, value2 = {}, helper216("PumpkinShockwave")
            for index, entry in ipairs(value2 and value2:GetChildren() or {}) do
                index = entry:GetAttribute("Radius")
                if index then
                    if entry:IsA("BasePart") then
                        local value3, value4 = #value + 1, { inner = index }
                        value4.outer, value[value3] = math.max(entry.Size.Y, entry.Size.Z) / 2, value4
                    end
                end
            end
            table.sort(value, function(argument2, argument3)
                return argument2.inner < argument3.inner
            end)
            value = if #value == 0
                then {
                    { inner = 0, outer = 11.75 },
                    { inner = 26, outer = 29.5 },
                    { inner = 44, outer = 47.5 },
                }
                else value
            for index2, entry2 in ipairs(argument.impacts or {}) do
                for index3, entry3 in ipairs(value) do
                    index2 = helper214(
                        (argument.landTime or 0)
                            + (index3 - 1) * (argument.ringInterval or 0)
                            + (argument.ringDelay or 0)
                    )
                    value2 = index3 == 1 and os.clock() or index2 - (config.pkRingLead or 0.9)
                    if index3 == 1 then
                        helper219("ring" .. index3, entry2, entry3.outer, index2 + 0.3, value2)
                    else
                        helper220("ring" .. index3, entry2, entry3.outer, entry3.inner, index2 + 0.3, value2)
                    end
                end
            end
        end
        sharedValue101.ThornVines = function(argument)
            sharedValue97.thorn = {
                centre = argument.centre,
                angles = argument.angles or {},
                speed = tonumber(argument.speed) or 0,
                spinStart = argument.spinStart,
                spinEnd = argument.spinEnd,
                growStart = argument.growStart,
            }
        end
        sharedValue97.roots = {}
        sharedValue101.Snapvines = function(argument)
            sharedValue97.snap[argument.id] = tonumber(argument.precastRadius) or 8
            local untilAt = tonumber(argument.expire) and helper214(argument.expire) or os.clock() + 15
            for key, entry in pairs(argument.vines or {}) do
                if type(entry) == "table" and typeof(entry.base) == "Vector3" then
                    key = tonumber(config.pkVineRootR) or 6
                    helper219("vine root", entry.base, key, untilAt)
                    table.insert(sharedValue97.roots, { p = entry.base, r = key, untilAt = untilAt })
                    while #sharedValue97.roots > 8 do
                        table.remove(sharedValue97.roots, 1)
                    end
                end
            end
        end
        sharedValue97.nearRoot = function(argument, argument2, argument3)
            local now = os.clock()
            for index, entry in ipairs(sharedValue97.roots or {}) do
                if now < entry.untilAt then
                    if
                        (argument - entry.p.X) ^ 2 + (argument2 - entry.p.Z) ^ 2
                        < (entry.r + (argument3 or 0)) ^ 2
                    then
                        return true
                    end
                end
            end
            return false
        end
        sharedValue101.SnapvineStrike = function(argument)
            helper219(
                "vine",
                argument.target,
                sharedValue97.snap[argument.id] or 8,
                helper214(argument.landed) + 0.3
            )
            if typeof(argument.target) == "Vector3" then
                table.insert(sharedValue97.lethal, {
                    p = argument.target,
                    r = sharedValue97.snap[argument.id] or 12,
                    landAt = helper214(argument.landed),
                    name = "grab circle",
                })
                while #sharedValue97.lethal > 16 do
                    table.remove(sharedValue97.lethal, 1)
                end
            end
        end
        sharedValue97.lethalOut = function(vector, argument, argument2)
            if config.pkLethalOut == false then
                return nil
            end
            local value, value2 = {}
            for index, entry in ipairs(sharedValue97.lethal) do
                if argument2 < entry.landAt + 0.1 then
                    value[#value + 1] = entry
                    value2 = value2
                        or (if helper215(vector, entry.p) < entry.r + helper217() then entry else value2)
                end
            end
            if not value2 then
                return nil
            end
            argument2 = value2.r + helper217() + (config.pkLethalOutMargin or 2)
            if argument ~= nil then
                if typeof(argument.point) == "Vector3" then
                    if not (argument.label and tostring(argument.label):find("last resort", 1, true)) then
                        if not (context.BB and context.BB.pickedSafe == false) then
                            if helper215(argument.point, value2.p) >= argument2 then
                                return nil
                            end
                        end
                    end
                end
            end
            argument = workspace:FindFirstChild("enemies")
            local value3 = argument and (argument:FindFirstChild("Pumpkin King"))
            argument = value3 and (value3:FindFirstChild("HumanoidRootPart") or value3.PrimaryPart)
            local vector2, value4, value5 =
                argument and argument.Position, vector.X - value2.p.X, vector.Z - value2.p.Z
            local value6, value7, value8 =
                value4 * value4 + value5 * value5 - argument2 * argument2, math.huge
            for index2 = 0, 15, 1 do
                argument = index2 * 3.141592653589793 / 8
                index2, value3 = math.cos(argument), math.sin(argument)
                local value9 = index2 * value4 + value3 * value5
                local value10 = value9 * value9 - value6
                if value10 >= 0 then
                    local value11 = -value9 + math.sqrt(value10)
                    local vector3, value12 =
                        Vector3.new(vector.X + index2 * value11, vector.Y, vector.Z + value3 * value11),
                        sharedValue97.inside
                    local value13 = (if value12 then sharedValue97.inside(vector3, 0) else not value12)
                        and not sharedValue97.redOnPath(vector.X, vector.Z, vector3.X, vector3.Z)
                    for index3, entry2 in ipairs(value) do
                        value13 = value13
                            and (
                                if entry2 ~= value2
                                    then if helper215(vector3, entry2.p) < entry2.r + helper217()
                                        then false
                                        else value13
                                    else value13
                            )
                    end
                    if
                        value13
                        and (
                            if sharedValue97.nearRoot
                                then if sharedValue97.nearRoot(vector3.X, vector3.Z, 1.5)
                                    then false
                                    else value13
                                else value13
                        )
                    then
                        value12 = nil
                        if vector2 then
                            local value14, value15 = vector2.X - vector.X, vector2.Z - vector.Z
                            local value16 = math.clamp(value14 * index2 + value15 * value3, 0, value11)
                            local value17, value18, pkBossKeep =
                                vector.X + index2 * value16 - vector2.X,
                                vector.Z + value3 * value16 - vector2.Z,
                                config.pkBossKeep
                            value12 = if pkBossKeep
                                then if pkBossKeep > 0
                                    then if math.sqrt(value17 * value17 + value18 * value18)
                                            < config.pkBossKeep
                                        then value11 + 25
                                        else value11
                                    else value11
                                else value11
                        else
                            value12 = value11
                        end
                        if value12 < value7 then
                            value7, value8 = value12, vector3
                        end
                    end
                end
            end
            if not value8 then
                argument = math.sqrt(value4 * value4 + value5 * value5)
                if argument < 0.5 then
                    value4, value5, argument = 1, 0, 1
                end
                value8 = Vector3.new(
                    value2.p.X + value4 / argument * argument2,
                    vector.Y,
                    value2.p.Z + value5 / argument * argument2
                )
            end
            return value8, value2.name
        end
        sharedValue101.CandyScatter = function(argument)
            sharedValue97.throwAt = os.clock()
            local value =
                { landAt = helper214(argument.landTime), endAt = helper214(argument.endTime), pieces = {} }
            for index, entry in ipairs(argument.candies or {}) do
                local value2 = { point = entry.point, good = entry.good == true }
                if not value2.good then
                    value2.zone = helper219(
                        "red candy",
                        entry.point,
                        tonumber(config.pkRedR) or 6,
                        value.endAt + 0.5,
                        os.clock()
                    )
                end
                value.pieces[index] = value2
            end
            sharedValue97.candy[argument.id] = value
        end
        sharedValue101.CandyTaken = function(argument)
            local value = sharedValue97.candy[argument.id]
            local value2 = value and value.pieces[argument.index]
            if value2 then
                value2.taken = true
                if value2.zone then
                    value2.zone.untilAt = os.clock()
                end
            end
        end
        sharedValue101.ArenaShrink = function(argument)
            sharedValue97.shrink = {
                start = argument.start,
                moveTime = tonumber(argument.moveTime) or 1,
                holdTime = tonumber(argument.holdTime) or 0,
                inset = tonumber(argument.inset) or 0,
            }
        end
        sharedValue97.nextFan = function()
            local now = os.clock()
            if sharedValue97.throwAt then
                if now - sharedValue97.throwAt < 8 then
                    if not (sharedValue97.fanAt and sharedValue97.fanAt > sharedValue97.throwAt) then
                        return sharedValue97.throwAt + (config.pkFanAfterThrow or 4.5)
                    end
                end
            end
            if sharedValue97.fanAt then
                return sharedValue97.fanAt + (config.pkFanLoop or 45.1)
            end
            if sharedValue97.startAt then
                return sharedValue97.startAt + (config.pkFirstFan or 11.9)
            end
            return nil
        end
        sharedValue97.fanWindow = function()
            local now = os.clock()
            if sharedValue97.fanAt then
                if now - sharedValue97.fanAt < (config.pkFanTail or 3.2) then
                    return true
                end
            end
            local value = sharedValue97.nextFan()
            if not value then
                return false
            end
            return now >= value - (config.pkFanLead or 3.5) and now <= value + (config.pkFanTail or 3.2)
        end
        sharedValue97.openingHold = function()
            if config.pkOpeningHold == false then
                return false
            elseif sharedValue97.firstFan then
                return false
            end
            local value = workspace:FindFirstChild("enemies")
            local value2 = value and (value:FindFirstChild("Pumpkin King"))
            value = value2 and (value2:FindFirstChildOfClass("Humanoid"))
            if value then
                if value.MaxHealth <= 0 then
                    return false
                end
            else
                return false
            end
            return value.Health >= value.MaxHealth - 1
        end
        sharedValue97.redTouch = function(argument, argument2, argument3, argument4)
            local now, value, value2, value3 =
                os.clock(), tonumber(config.pkRedTouch) or 6, argument3 - argument, argument4 - argument2
            argument3 = value2 * value2 + value3 * value3
            for key, entry in pairs(sharedValue97.candy) do
                if now < entry.endAt then
                    for index, piece in ipairs(entry.pieces) do
                        if not piece.good then
                            if not piece.taken then
                                argument4, key = piece.point.X - argument, piece.point.Z - argument2
                                index = argument3 > 1.0E-6
                                        and math.clamp((argument4 * value2 + key * value3) / argument3, 0, 1)
                                    or 0
                                local value4, value5 = argument4 - value2 * index, key - value3 * index
                                if index > 0.02 then
                                    if value4 * value4 + value5 * value5 < value * value then
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
        sharedValue97.redOnPath = function(argument, argument2, argument3, argument4)
            local now, value, value2, value3 =
                os.clock(), tonumber(config.pkRedClear) or 6, argument3 - argument, argument4 - argument2
            argument4 = value2 * value2 + value3 * value3
            for key, entry in pairs(sharedValue97.candy) do
                if now < entry.endAt then
                    for index, piece in ipairs(entry.pieces) do
                        if not piece.good then
                            if not piece.taken then
                                index, key = piece.point.X - argument, piece.point.Z - argument2
                                argument3 = argument4 > 1.0E-6
                                        and math.clamp((index * value2 + key * value3) / argument4, 0, 1)
                                    or 0
                                local value4, value5 = index - value2 * argument3, key - value3 * argument3
                                if value4 * value4 + value5 * value5 < value * value then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
            return false
        end
        sharedValue97.greenLive = function()
            local now = os.clock()
            for key, entry in pairs(sharedValue97.candy) do
                if now < entry.endAt then
                    for index, piece in ipairs(entry.pieces) do
                        if piece.good then
                            if not piece.taken then
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end
        local function helper223(pos)
            local value = {}
            pcall(function()
                for index, entry in ipairs(context.AF.load().accounts or {}) do
                    if type(entry) == "table" then
                        if entry.enabled ~= false then
                            value[string.lower(tostring(entry.name))] = true
                        end
                    end
                end
            end)
            value[string.lower(localPlayer.Name)] = true
            local value2 = {}
            for index2, entry2 in ipairs(sharedValue99:GetPlayers()) do
                if value[string.lower(entry2.Name)] then
                    index2 = entry2.Character
                    local humanoid, value3 =
                        index2 and (index2:FindFirstChildOfClass("Humanoid")),
                        index2 and (index2:FindFirstChild("HumanoidRootPart"))
                    if entry2 == localPlayer then
                        value2[#value2 + 1] = { name = entry2.Name, pos = pos, me = true }
                    elseif humanoid then
                        if value3 then
                            if humanoid.Health > 0 then
                                value2[#value2 + 1] = { name = entry2.Name, pos = value3.Position }
                            end
                        end
                    end
                end
            end
            table.sort(value2, function(argument, argument2)
                return argument.name < argument2.name
            end)
            return value2
        end
        sharedValue97.goal = function(argument)
            local myCandy, value = os.clock(), {}
            for key, entry in pairs(sharedValue97.candy) do
                if myCandy > entry.endAt + 1 then
                    sharedValue97.candy[key] = nil
                else
                    for index, piece in ipairs(entry.pieces) do
                        if
                            piece.good
                            and not piece.taken
                            and not piece.skip
                            and myCandy < entry.endAt - 0.2
                            and math.abs(argument.Y - 3 - piece.point.Y) <= (config.pkCandyDy or 6)
                            and (
                                config.pkCandyThorns ~= false
                                    and not (context.pkNoHits and context.pkNoHits())
                                    and sharedValue97.inArena(piece.point, 0.5)
                                or sharedValue97.inside(piece.point, 1)
                            )
                        then
                            piece.landAt = entry.landAt
                            local value2, aim = tonumber(config.pkRedClear) or 6, piece.point
                            for index2, piece2 in ipairs(entry.pieces) do
                                if not piece2.good then
                                    if not piece2.taken then
                                        index2, index =
                                            piece.point.X - piece2.point.X, piece.point.Z - piece2.point.Z
                                        local value3 = math.sqrt(index2 * index2 + index * index)
                                        if value3 < value2 + 3.5 then
                                            if value3 > 0.3 then
                                                local value4 = math.min(2.5, value2 + 3.5 - value3)
                                                aim = Vector3.new(
                                                    piece.point.X + index2 / value3 * value4,
                                                    piece.point.Y,
                                                    piece.point.Z + index / value3 * value4
                                                )
                                            end
                                        end
                                    end
                                end
                            end
                            local value5 = true
                            for index3, piece3 in ipairs(entry.pieces) do
                                index3 = piece3.good
                                if
                                    (if index3 then not index3 else not piece3.taken)
                                    and helper215(aim, piece3.point) < value2
                                then
                                    value5 = false
                                    break
                                end
                            end
                            piece.aim = aim
                            if value5 then
                                value[#value + 1] = { p = piece, endAt = entry.endAt }
                            end
                        end
                    end
                end
            end
            if #value == 0 then
                sharedValue97.myCandy = nil
                return nil
            end
            local value6, value7, value8, value9, value10 =
                helper223(argument),
                tonumber(config.pkCandySpeed) or 16,
                sharedValue97.fanO or Vector3.new(config.pkFanX or 104, 0, config.pkFanZ or 1042)
            if sharedValue97.fanAt and myCandy - sharedValue97.fanAt < (config.pkFanTail or 3.2) then
                value9, value10 = myCandy - 1, sharedValue97.fanAt + (config.pkFanTail or 3.2)
            else
                if sharedValue97.nextFan then
                    argument = sharedValue97.nextFan()
                    if argument then
                        if argument > myCandy - 1 then
                            local value11, value12 =
                                argument + (config.pkFanHitAfter or 0.93),
                                argument + (config.pkFanTail or 3.2)
                            value9, value10 = value11, value12
                        end
                    end
                end
            end
            local value13, value14, value15 = {}, {}, {}
            for index4, entry2 in ipairs(value6) do
                value13[index4], value14[index4] = myCandy, entry2.pos
            end
            argument = {}
            for index5 = 1, #value, 1 do
                argument[index5] = true
            end
            myCandy = nil
            for index6 = 1, #value, 1 do
                local value16, value17, value18
                for index7, entry3 in ipairs(value6) do
                    for index8, entry4 in ipairs(value) do
                        if argument[index8] then
                            index6 = helper215(value14[index7], entry4.p.aim or entry4.p.point)
                            index6 = if entry3.me
                                then if value15[index7]
                                    then index6
                                    else if sharedValue97.myCandy == entry4.p
                                        then math.max(index6 - (config.pkCandyStick or 4), 0)
                                        else index6
                                else index6
                            local value19 = value13[index7] + index6 / value7
                            if
                                value10
                                and (config.pkCandyFanRule == true or context.pkNoHits and context.pkNoHits())
                            then
                                local value20 = helper215(entry4.p.aim or entry4.p.point, value8)
                                value19 = if value20 < (config.pkFanCandyFar or 30)
                                    then if value19
                                            > value9
                                                - math.max(0, (config.pkFanSafeR or 40) - value20) / value7
                                                - (config.pkFanSpare or 0.6)
                                        then if value19 < value10
                                            then value10 + ((config.pkFanSafeR or 40) + 5 - value20) / value7
                                            else value19
                                        else value19
                                    else value19
                            end
                            if
                                value19 < entry4.endAt - 0.2
                                and (
                                    (if value16 then value19 < value16 - 1.0E-6 else not value16)
                                    or math.abs(value19 - value16) <= 1.0E-6
                                        and (index7 < value17 or index7 == value17 and index8 < value18)
                                )
                            then
                                value16, value17, value18 = value19, index7, index8
                            end
                        end
                    end
                end
                if not value17 then
                    break
                end
                argument[value18] = false
                value13[value17], value14[value17] =
                    value16 + (config.pkCandyPickT or 0.3), value[value18].p.aim or value[value18].p.point
                if not value15[value17] then
                    value15[value17] = value[value18].p
                    myCandy = if value6[value17].me then value[value18].p else myCandy
                end
            end
            sharedValue97.myCandy = myCandy
            return myCandy and (myCandy.aim or myCandy.point) or nil
        end
        local sharedValue102
        local function helper224()
            if sharedValue102 then
                local value = sharedValue102
                return value
            end
            local value2 = helper216("Thornwall")
            local value3, value4, iterateArray, value5, value6 =
                value2 and tonumber(value2:GetAttribute("HalfX")) or 62.42,
                value2 and tonumber(value2:GetAttribute("HalfZ")) or 41.43,
                ipairs,
                { value2 and (value2:FindFirstChild("Vines")), value2 and (value2:FindFirstChild("Thorns")) },
                0
            for key, entry in iterateArray(value5) do
                for index, entry2 in ipairs(entry and entry:GetChildren() or {}) do
                    value2, index = ipairs, { entry2:GetAttribute("A"), entry2:GetAttribute("B") }
                    for key2, entry3 in value2(index) do
                        if typeof(entry3) == "Vector3" then
                            key = math.min(value3 - math.abs(entry3.X), value4 - math.abs(entry3.Z))
                                + (tonumber(entry2:GetAttribute("Radius")) or 0.5)
                            value6 = if key > value6 then key else value6
                        end
                    end
                end
            end
            sharedValue102 = math.clamp(value6, 2, 20)
            value2 = sharedValue102
            return value2
        end
        local function helper225()
            local shrink = sharedValue97.shrink
            if not shrink then
                return 0
            end
            local value = helper213() - (tonumber(shrink.start) or 0)
            if value <= 0 then
                return 0
            end
            local value2, value3 =
                math.clamp(value / shrink.moveTime, 0, 1),
                math.clamp((value - shrink.moveTime - shrink.holdTime) / shrink.moveTime, 0, 1)
            return shrink.inset * (value2 * value2 * (3 - value2 * 2) - value3 * value3 * (3 - value3 * 2))
        end
        sharedValue97.arena = function()
            local bossBarriers = workspace:FindFirstChild("BossBarriers")
            local value, value2, value3, value4 =
                bossBarriers and (bossBarriers:FindFirstChild("BarrierWest")),
                bossBarriers and (bossBarriers:FindFirstChild("BarrierEast")),
                bossBarriers and (bossBarriers:FindFirstChild("BarrierNorth")),
                bossBarriers and (bossBarriers:FindFirstChild("BarrierSouth"))
            if value then
                if value2 then
                    if value3 then
                        if not value4 then
                            return nil
                        end
                    else
                        return nil
                    end
                else
                    return nil
                end
            else
                return nil
            end
            local value5, value6, value7, value8 =
                value.Position.X + value.Size.X / 2,
                value2.Position.X - value2.Size.X / 2,
                value3.Position.Z + value3.Size.Z / 2,
                value4.Position.Z - value4.Size.Z / 2
            if value5 > value6 then
                value5, value6 = value6, value5
            end
            if value7 > value8 then
                value7, value8 = value8, value7
            end
            return { x0 = value5, x1 = value6, z0 = value7, z1 = value8 }
        end
        sharedValue97.borderDepth = function()
            local value = workspace:FindFirstChild("enemies")
            local value2 = value and (value:FindFirstChild("Pumpkin King"))
            value = value2 and (value2:GetAttribute("BorderSlamTime"))
            if value then
                if helper213() < value then
                    return 0
                end
            else
                return 0
            end
            value2 = tonumber(config.pkBorderPad) or 6
            value2 = if sharedValue97.greenLive
                then if sharedValue97.greenLive()
                    then math.min(value2, tonumber(config.pkBorderPadCandy) or 4)
                    else value2
                else value2
            local shrink, value3 = sharedValue97.shrink, helper225()
            value3 = if shrink
                then if helper213() - (tonumber(shrink.start) or 0)
                        <= (tonumber(shrink.moveTime) or 2.5) + (tonumber(shrink.holdTime) or 8)
                    then math.max(value3, tonumber(shrink.inset) or 0)
                    else value3
                else value3
            return helper224() + value3 + value2
        end
        sharedValue97.thornDepth = function()
            local value = workspace:FindFirstChild("enemies")
            local value2 = value and (value:FindFirstChild("Pumpkin King"))
            value = value2 and (value2:GetAttribute("BorderSlamTime"))
            if value then
                if helper213() < value then
                    return 0
                end
            else
                return 0
            end
            return helper224() + helper225()
        end
        sharedValue97.clamp = function(vector, argument)
            local value = sharedValue97.arena()
            if not value then
                return vector
            end
            local value2 = (argument or 0) + sharedValue97.borderDepth()
            if value.x1 - value.x0 <= value2 * 2 then
                return vector
            elseif value.z1 - value.z0 <= value2 * 2 then
                return vector
            end
            return Vector3.new(
                math.clamp(vector.X, value.x0 + value2, value.x1 - value2),
                vector.Y,
                math.clamp(vector.Z, value.z0 + value2, value.z1 - value2)
            )
        end
        green, band2 = setmetatable, { __mode = "k" }
        sharedValue97.maxHp = green({}, band2)
        sharedValue97.attackersOut = function()
            local value, value2, value3 = false, 0, 0
            for index, entry in ipairs(sharedValue99:GetPlayers()) do
                index = entry.Character
                local value4 = index and (index:FindFirstChildOfClass("Humanoid"))
                index = value4 ~= nil and value4.Health > 0
                if index then
                    if value4.MaxHealth > 500 then
                        sharedValue97.maxHp[entry] = value4.MaxHealth
                    end
                end
                value4 = sharedValue97.maxHp[entry]
                if value4 then
                    if value4 >= (tonumber(config.pkHealerHp) or 4000) then
                        value = if index then true else value
                    else
                        value2 += 1
                        local lives = entry:FindFirstChild("lives")
                        value3 = if index
                            then value3
                            else if lives
                                then if tonumber(lives.Value)
                                    then if lives.Value <= 0 then value3 + 1 else value3
                                    else value3
                                else value3
                    end
                end
            end
            return value2 > 0 and value3 == value2 and value, value2
        end
        task.spawn(function()
            while not runtimeState.destroyed do
                task.wait(1)
                pcall(function()
                    if config.pkRestartNoDps == false then
                        sharedValue97.outSince = nil
                        return
                    elseif context.isEvent then
                        if not (context.isEvent()) then
                            sharedValue97.outSince = nil
                            return
                        end
                    else
                        sharedValue97.outSince = nil
                        return
                    end
                    local dungeonProgress = workspace:FindFirstChild("dungeonProgress")
                    if dungeonProgress then
                        if dungeonProgress.Value == "inProgress" then
                            if sharedValue97.restartJob == game.JobId then
                                sharedValue97.outSince = nil
                                return
                            end
                        else
                            sharedValue97.outSince = nil
                            return
                        end
                    else
                        sharedValue97.outSince = nil
                        return
                    end
                    local value, value2 = sharedValue97.attackersOut()
                    if not value then
                        sharedValue97.outSince = nil
                        return
                    end
                    sharedValue97.outSince = sharedValue97.outSince or os.clock()
                    if os.clock() - sharedValue97.outSince < (tonumber(config.pkRestartWait) or 2) then
                        return
                    end
                    sharedValue97.restartJob = game.JobId
                    if context.log then
                        context.log(
                            "Event",
                            ("all %d attackers are out of lives - the healer cannot finish the boss: restarting the run"):format(
                                value2
                            )
                        )
                    end
                    if context.notify then
                        context.notify(
                            "warning",
                            "Restarting the run",
                            ("All %d attackers are out - the healer cannot finish the boss. Back to the lobby to start again."):format(
                                value2
                            ),
                            8
                        )
                    end
                    local localPlayer2 = sharedValue99.LocalPlayer
                    pcall(function()
                        local partyQueue = context.AF
                        partyQueue.loadReal(true)
                        local value3 = partyQueue.partyOf(localPlayer2.Name, partyQueue.doc)
                        if value3 then
                            value3.leaveNow = { job = game.JobId, at = os.time() }
                            partyQueue.save()
                        end
                    end)
                    if context.AF and context.AF.leaveGo then
                        context.AF.leaveGo(os.clock(), "every attacker is out of lives - restarting the run")
                    elseif context.MD then
                        if context.MD.goLobby then
                            pcall(context.MD.goLobby)
                        end
                    end
                end)
            end
        end)
        task.spawn(function()
            while not runtimeState.destroyed do
                pcall(function()
                    if config.hideHurtFlash == false then
                        return
                    end
                    local value, health = getService("StarterGui"), Enum.CoreGuiType.Health
                    if value:GetCoreGuiEnabled(health) then
                        value:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
                    end
                end)
                task.wait(3)
            end
        end)
        sharedValue97.inArena = function(vector, argument)
            local value = sharedValue97.arena()
            if not value then
                return true
            end
            argument = argument or 0
            return vector.X > value.x0 + argument
                and vector.X < value.x1 - argument
                and vector.Z > value.z0 + argument
                and vector.Z < value.z1 - argument
        end
        sharedValue97.inside = function(vector, argument)
            local vector2 = sharedValue97.clamp(vector, argument)
            return math.abs(vector2.X - vector.X) < 0.01 and math.abs(vector2.Z - vector.Z) < 0.01
        end
        sharedValue97.border = function(argument)
            local value = sharedValue97.arena()
            if not value then
                return
            end
            local value2, value3, value4, value5, value6 =
                value.x0, value.x1, value.z0, value.z1, sharedValue97.borderDepth()
            if value6 <= 0 then
                return
            end
            local value7, value8, value9, value10, value11, value12 =
                os.clock() + 0.6,
                (value2 + value3) / 2,
                (value4 + value5) / 2,
                value3 - value2,
                value5 - value4,
                tonumber(config.pkBorderOut) or 40
            helper218(
                "border",
                CFrame.new(value2 + (value6 - value12) / 2, argument, value9),
                Vector3.new(value6 + value12, 14, value11 + value12 * 2),
                false,
                value7
            )
            helper218(
                "border",
                CFrame.new(value3 - (value6 - value12) / 2, argument, value9),
                Vector3.new(value6 + value12, 14, value11 + value12 * 2),
                false,
                value7
            )
            helper218(
                "border",
                CFrame.new(value8, argument, value4 + (value6 - value12) / 2),
                Vector3.new(value10 + value12 * 2, 14, value6 + value12),
                false,
                value7
            )
            helper218(
                "border",
                CFrame.new(value8, argument, value5 - (value6 - value12) / 2),
                Vector3.new(value10 + value12 * 2, 14, value6 + value12),
                false,
                value7
            )
        end
        local sharedValue103
        local function helper226()
            if sharedValue103 then
                local value = sharedValue103
                return value
            end
            local value2 = helper216("TreeBranch")
            local value3 = value2 and (value2:FindFirstChild("Branch"))
            sharedValue103 = if value2
                then if value2.PrimaryPart
                    then if value3
                        then math.abs(value2.PrimaryPart.CFrame:ToObjectSpace(value3.CFrame).Position.Z)
                            + value3.Size.Z / 2
                        else 57.5
                    else 57.5
                else 57.5
            value3 = sharedValue103
            return value3
        end
        sharedValue97.thornJump = function(argument, argument2)
            local thorn = sharedValue97.thorn
            if not thorn then
                return
            end
            local value = helper213()
            if value > (thorn.spinEnd or 0) + 0.5 then
                sharedValue97.thorn = nil
                return
            end
            if value < (thorn.growStart or 0) + 0.45 then
                return
            end
            local value2, value3 = argument2.X - thorn.centre.X, argument2.Z - thorn.centre.Z
            argument2 = math.sqrt(value2 * value2 + value3 * value3)
            if argument2 > helper226() + 3 then
                return
            elseif argument2 < 2 then
                return
            end
            local value4, value5 = math.atan2(value3, value2), tonumber(config.pkThornLead) or 0.18
            local function helper6(argument3)
                return math.clamp(
                    argument3 - (thorn.spinStart or 0),
                    0,
                    (thorn.spinEnd or 0) - (thorn.spinStart or 0)
                ) * thorn.speed
            end
            local value6, value7, value8 =
                helper6(value), helper6(value + value5), math.atan2(2.5, math.max(argument2, 1))
            for index, angle in ipairs(thorn.angles) do
                value5, value2 = angle + value6, angle + value7
                if value2 < value5 then
                    value5, value2 = value2, value5
                end
                helper6 = value4
                while helper6 < value5 - value8 - 3.141592653589793 do
                    helper6 += 6.283185307179586
                end
                while helper6 > value5 - value8 + 3.141592653589793 do
                    helper6 -= 6.283185307179586
                end
                if helper6 >= value5 - value8 then
                    if helper6 <= value2 + value8 then
                        if argument.FloorMaterial ~= Enum.Material.Air then
                            argument.Jump = true
                        end
                        return
                    end
                end
            end
        end
        sharedValue97.hook = function()
            if sharedValue97.hooked then
                return true
            end
            local value
            pcall(function()
                local iterateArray, value2 = ipairs, argumentHelpers[108](getgc(false))
                for key, entry in iterateArray(argumentHelpers:unpackValues(value2)) do
                    if
                        type(entry) == "function"
                        and islclosure(entry)
                        and tostring(debug.info(entry, "s")):find("EnemyClientEffects", 1, true)
                    then
                        local iteratePairs, value3 = pairs, argumentHelpers[108](debug.getupvalues(entry))
                        for key2, entry2 in iteratePairs(argumentHelpers:unpackValues(value3)) do
                            if type(entry2) == "table" then
                                for key3, entry3 in pairs(entry2) do
                                    if type(key3) == "string" then
                                        if key3:find("Pumpkin King", 1, true) then
                                            if type(entry3) == "table" then
                                                if type(rawget(entry3, "CandyScatter")) == "function" then
                                                    value = entry3
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if value then
                                break
                            end
                        end
                    end
                    if value then
                        break
                    end
                end
            end)
            if not value then
                return false
            end
            local value4 = rawget(value, "__hlOrig")
            if type(value4) ~= "table" then
                value4 = {}
                rawset(value, "__hlOrig", value4)
            end
            for index, entry4 in ipairs(sharedValue100) do
                local value5 = value4[entry4] or rawget(value, entry4)
                if type(value5) == "function" then
                    value4[entry4] = value5
                    rawset(value, entry4, function(argument, argument2, argument3)
                        local value2 = sharedValue101[entry4]
                        if value2 then
                            if type(argument3) == "table" then
                                if not runtimeState.destroyed then
                                    local success, value3 = pcall(value2, argument3, argument)
                                    if not success then
                                        sharedValue97.err = tostring(value3)
                                    end
                                end
                            end
                        end
                        return value5(argument, argument2, argument3)
                    end)
                end
            end
            sharedValue97.hooked = true
            if context.log then
                context.log("PK", "Pumpkin King: reading the boss's attacks")
            end
            return true
        end
        local function helper227()
            local dungeonName = workspace:FindFirstChild("dungeonName")
            return dungeonName ~= nil and tostring(dungeonName.Value) == "Pumpkin King"
        end
        task.spawn(function()
            local value = -math.huge
            local value2 = -math.huge
            while not runtimeState.destroyed do
                task.wait(0.1)
                pcall(function()
                    if not (helper227()) then
                        return
                    end
                    local value3 = workspace:FindFirstChild("dungeonProgress")
                    local value4 = value3 and tostring(value3.Value) or ""
                    if value4 == "playersNotReady" then
                        sharedValue97.sawNotReady = true
                    end
                    if value4 == "inProgress" then
                        if sharedValue97.sawNotReady then
                            if not sharedValue97.startAt then
                                sharedValue97.startAt = os.clock()
                            end
                        end
                    end
                    value3 = os.clock()
                    if not sharedValue97.hooked then
                        if value3 - value > 3 then
                            value = value3
                            sharedValue97.hook()
                        end
                    end
                    value4 = localPlayer.Character
                    local humanoid, value5 =
                        value4 and (value4:FindFirstChildOfClass("Humanoid")),
                        value4 and (value4:FindFirstChild("HumanoidRootPart"))
                    if humanoid then
                        if value5 then
                            if not (humanoid.Health > 0) then
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                    if value3 - value2 > 0.4 then
                        value2 = value3
                        sharedValue97.border(value5.Position.Y)
                        value4 = workspace:FindFirstChild("enemies")
                        local value6 = value4 and (value4:FindFirstChild("Pumpkin King"))
                        local value7, value8 =
                            value6 and (value6:FindFirstChild("HumanoidRootPart") or value6.PrimaryPart),
                            sharedValue97.greenLive() and workspace:FindFirstChild("Snapvines") == nil
                        if value7 then
                            value6 = config.pkBossKeep
                            if value6 then
                                if value6 > 0 then
                                    local value9 = value8
                                            and math.min(config.pkBossKeepCandy or 10, config.pkBossKeep)
                                        or config.pkBossKeep
                                    helper218(
                                        "boss keep-out",
                                        CFrame.new(value7.Position.X, value5.Position.Y, value7.Position.Z),
                                        Vector3.new(value9 * 2, 14, value9 * 2),
                                        true,
                                        os.clock() + 0.6
                                    )
                                end
                            end
                        end
                    end
                    if config.pkThornJump ~= false then
                        sharedValue97.thornJump(humanoid, value5.Position)
                    end
                end)
            end
        end)
    end
    do
        local sharedValue104, setMetatable5, sharedValue105 = {}, setmetatable, { __mode = "k" }
        sharedValue104.orig = setMetatable5({}, sharedValue105)
        band2, hlBugReport = setmetatable, { __mode = "k" }
        sharedValue104.done = band2({}, hlBugReport)
        sharedValue105, helper18 = setmetatable, { __mode = "k" }
        sharedValue104.lists = sharedValue105({}, helper18)
        sharedValue104.last = 0
        sharedValue104.was = false
        sharedValue104.key = ""
        context.AC = sharedValue104
        local function helper228(argument, argument2, argument3)
            local value = sharedValue104.orig[argument]
            if not value then
                value = {}
                sharedValue104.orig[argument] = value
            end
            if value[argument2] == nil then
                local success, value2 = pcall(function()
                    return argument[argument2]
                end)
                if not success then
                    return
                end
                value[argument2] = value2
            end
            pcall(function()
                if argument[argument2] ~= argument3 then
                    argument[argument2] = argument3
                end
            end)
        end
        local function helper229(argument, argument2, argument3, argument4)
            if argument:IsA("BasePart") then
                if argument.Color ~= argument2 then
                    helper228(argument, "Color", argument2)
                end
                if argument:IsA("MeshPart") then
                    if argument.TextureID ~= "" then
                        helper228(argument, "TextureID", "")
                    end
                end
                return
            end
            if sharedValue104.done[argument] == argument4 then
                return
            end
            sharedValue104.done[argument] = argument4
            if argument:IsA("ParticleEmitter") then
                helper228(argument, "Color", argument3)
            elseif argument:IsA("Beam") then
                helper228(argument, "Color", argument3)
            elseif argument:IsA("Trail") then
                helper228(argument, "Color", argument3)
            elseif argument:IsA("Decal") then
                helper228(argument, "Color3", argument2)
            elseif argument:IsA("Texture") then
                helper228(argument, "Color3", argument2)
            elseif argument:IsA("SpecialMesh") then
                if argument.TextureId ~= "" then
                    helper228(argument, "TextureId", "")
                end
                helper228(argument, "VertexColor", Vector3.new(argument2.R, argument2.G, argument2.B))
            elseif argument:IsA("Light") then
                helper228(argument, "Color", argument2)
            elseif argument:IsA("Highlight") then
                helper228(argument, "FillColor", argument2)
                helper228(argument, "OutlineColor", argument2)
            elseif argument:IsA("SurfaceAppearance") then
                helper228(argument, "Color", argument2)
            end
        end
        local function helper230(argument)
            local value, value2 = sharedValue104.lists[argument]
            if value then
                value2 = value
            else
                value2 = { argument }
                for index, descendant in ipairs(argument:GetDescendants()) do
                    value2[#value2 + 1] = descendant
                end
                sharedValue104.lists[argument] = value2
                local function helper6(argument2)
                    value2[#value2 + 1] = argument2
                    if sharedValue104.cur then
                        pcall(
                            helper229,
                            argument2,
                            sharedValue104.cur,
                            sharedValue104.curSeq,
                            sharedValue104.curKey
                        )
                    end
                end
                argument.DescendantAdded:Connect(helper6)
            end
            return value2
        end
        sharedValue104.apply = function(cur)
            local curKey = cur:ToHex()
            local curSeq = ColorSequence.new(cur)
            sharedValue104.cur = cur
            sharedValue104.curSeq = curSeq
            sharedValue104.curKey = curKey
            local function helper6(argument)
                local value = helper230(argument)
                for index = 1, #value, 1 do
                    argument = value[index]
                    if argument.Parent then
                        helper229(argument, cur, curSeq, curKey)
                    end
                end
            end
            for key, entry in pairs(hazardReader.models or {}) do
                if typeof(key) == "Instance" then
                    if key.Parent then
                        if not entry.safeFamily then
                            if not (tostring(entry.name or ""):find("safe", 1, true)) then
                                helper6(key)
                            end
                        end
                    end
                end
            end
            for entry2 in pairs(hazardReader.parts or {}) do
                local value2 = typeof(entry2) == "Instance" and string.lower(entry2.Name) or ""
                if typeof(entry2) == "Instance" then
                    if entry2.Parent then
                        if not (value2:find("good", 1, true)) then
                            if not (value2:find("secondboss", 1, true) and value2:find("orb", 1, true)) then
                                if value2:find("bouncingorbbad", 1, true) then
                                    if config.mapRodinRedOrb == false then
                                        helper6(entry2)
                                    end
                                else
                                    helper6(entry2)
                                end
                            end
                        end
                    end
                end
            end
        end
        sharedValue104.restore = function()
            for key, entry in pairs(sharedValue104.orig) do
                if key.Parent then
                    for key2, entry2 in pairs(entry) do
                        pcall(function()
                            key[key2] = entry2
                        end)
                    end
                end
            end
            local value, value2 = setmetatable, { __mode = "k" }
            sharedValue104.orig = value({}, value2)
            value2, value = setmetatable, { __mode = "k" }
            sharedValue104.done = value2({}, value)
            sharedValue104.cur = nil
        end
        sharedValue104.paintNow = function(argument)
            local cur = context.attackColourNow and context.attackColourNow()
            if cur then
                if typeof(argument) ~= "Instance" then
                    return
                elseif not argument.Parent then
                    return
                end
            else
                return
            end
            local curKey = string.lower(argument.Name)
            if curKey:find("secondboss", 1, true) then
                if curKey:find("orb", 1, true) then
                    return
                end
            end
            if curKey:find("bouncingorbbad", 1, true) then
                if config.mapRodinRedOrb ~= false then
                    return
                end
            end
            sharedValue104.was = true
            curKey = cur:ToHex()
            if sharedValue104.curKey ~= curKey then
                sharedValue104.cur, sharedValue104.curSeq = cur, ColorSequence.new(cur)
                sharedValue104.curKey = curKey
            end
            cur = helper230(argument)
            for index = 1, #cur, 1 do
                argument = cur[index]
                if argument.Parent then
                    helper229(argument, sharedValue104.cur, sharedValue104.curSeq, sharedValue104.curKey)
                end
            end
        end
        sliderConnections[#sliderConnections + 1] = runService.Heartbeat:Connect(function()
            if runtimeState.destroyed then
                return
            end
            local value = os.clock()
            if value - sharedValue104.last < 0.15 then
                return
            end
            sharedValue104.last = value
            local value2 = context.attackColourNow()
            if value2 then
                sharedValue104.was = true
                local success, value3 = pcall(sharedValue104.apply, value2)
                local attackColour = os.clock() - value
                if runtimeState.stMax then
                    if attackColour > (runtimeState.stMax.attackColour or 0) then
                        runtimeState.stMax.attackColour = attackColour
                    end
                end
                if not success then
                    if not sharedValue104.errAt then
                        sharedValue104.errAt = value
                        context.log("AttackColour", "failed: " .. tostring(value3))
                    end
                end
            elseif sharedValue104.was then
                sharedValue104.was = false
                pcall(sharedValue104.restore)
            end
        end)
    end
    do
        local sharedValue106 = { gui = {}, last = 0 }
        local localPlayer3 = getService("Players").LocalPlayer
        local function helper231(argument)
            return argument:find("red", 1, true) and Color3.fromRGB(255, 90, 90)
                or argument:find("green", 1, true) and Color3.fromRGB(90, 255, 90)
                or argument:find("yellow", 1, true) and Color3.fromRGB(255, 235, 60)
                or Color3.new(1, 1, 1)
        end
        local function helper232()
            for key, entry in pairs(sharedValue106.gui) do
                pcall(function()
                    entry:Destroy()
                end)
                sharedValue106.gui[key] = nil
            end
        end
        pcall(function()
            local value = localPlayer3 and (localPlayer3:FindFirstChildOfClass("PlayerGui"))
            for index, entry in ipairs(value and value:GetChildren() or {}) do
                if entry.Name == "HLOrbFuse" then
                    entry:Destroy()
                end
            end
        end)
        sliderConnections[#sliderConnections + 1] = getService("RunService").Heartbeat:Connect(function()
            if runtimeState.destroyed then
                helper232()
                return
            end
            local last = os.clock()
            if last - sharedValue106.last < 0.1 then
                return
            end
            sharedValue106.last = last
            local parent = localPlayer3 and (localPlayer3:FindFirstChildOfClass("PlayerGui"))
            if not parent then
                return
            end
            local value = {}
            if config.orbFuseLabels ~= false and hazardReader.orbScan then
                for index, entry in ipairs(hazardReader.orbScan) do
                    index = entry.part
                    entry = index and hazardReader.parts[index]
                    if index and index.Parent and entry and entry.spawn and not value[index] then
                        value[index] = true
                        local hlOrbFuse = sharedValue106.gui[index]
                        if not (hlOrbFuse and hlOrbFuse.Parent == parent) then
                            if hlOrbFuse then
                                pcall(function()
                                    hlOrbFuse:Destroy()
                                end)
                            end
                            hlOrbFuse = Instance.new("BillboardGui")
                            hlOrbFuse.Name = "HLOrbFuse"
                            hlOrbFuse.ResetOnSpawn = false
                            hlOrbFuse.Size = UDim2.fromOffset(46, 20)
                            hlOrbFuse.StudsOffset = Vector3.new(0, 4.5, 0)
                            hlOrbFuse.AlwaysOnTop = true
                            hlOrbFuse.LightInfluence = 0
                            local label = Instance.new("TextLabel")
                            label.Name = "t"
                            label.BackgroundTransparency, label.Size = 1, UDim2.fromScale(1, 1)
                            label.TextSize = 15
                            label.TextStrokeTransparency = 0.15
                            label.Font = Enum.Font.GothamBold
                            label.TextColor3 = helper231(string.lower(index.Name))
                            label.Parent = hlOrbFuse
                            hlOrbFuse.Adornee = index
                            hlOrbFuse.Parent = parent
                            sharedValue106.gui[index] = hlOrbFuse
                        end
                        local value2, textControl =
                            math.max((config.orbFuse or 20) - (last - entry.spawn), 0),
                            hlOrbFuse:FindFirstChild("t")
                        if textControl then
                            textControl.Text = value2 < 5 and ("%.1f"):format(value2)
                                or ("%.0f"):format(value2)
                        end
                    end
                end
            end
            for key, entry2 in pairs(sharedValue106.gui) do
                if not value[key] then
                    pcall(function()
                        entry2:Destroy()
                    end)
                    sharedValue106.gui[key] = nil
                end
            end
        end)
    end
    context.setState("ready")
    local sharedValue107 = {}
    local function newSet()
        return {
            stages = {},
            fns = {},
            frames = { n = 0, gap50 = 0, gap100 = 0, gap250 = 0, maxGap = 0, spikes = {} },
            work = { n = 0, sum = 0, max = 0, over8 = 0, over16 = 0, over33 = 0 },
            ping = { n = 0, sum = 0, max = 0, over150 = 0, over300 = 0 },
        }
    end
    hlBugReport = { since = os.clock(), sets = { other = newSet(), rodin = newSet() } }
    hlBugReport.cur = hlBugReport.sets.other
    hlBugReport.newSet = newSet
    runtimeState.perf = hlBugReport
    _G.DungeonAutofarmPerf = hlBugReport
    context.perfAdd = function(argument, argument2, max)
        local value = argument[argument2]
        if not value then
            value = { n = 0, sum = 0, max = 0, over4 = 0, over8 = 0 }
            argument[argument2] = value
        end
        value.n, value.sum = value.n + 1, value.sum + max
        if max > value.max then
            value.max = max
        end
        if max > 0.004 then
            value.over4 = value.over4 + 1
        end
        if max > 0.008 then
            value.over8 = value.over8 + 1
        end
    end
    runtimeState.stMax = runtimeState.stMax or {}
    local function helper233(argument, argument2, argument3)
        local value, value2, value3 = os.clock(), pcall(argument2, argument3)
        argument3 = os.clock() - value
        if argument3 > (runtimeState.stMax[argument] or 0) then
            runtimeState.stMax[argument] = argument3
        end
        if runtimeState.perf then
            context.perfAdd(runtimeState.perf.cur.stages, argument, argument3)
        end
        if value2 then
            return
        end
        if argument == "brain" then
            helper2()
        end
        runtimeState.lastError, runtimeState.lastErrorAt =
            ("%s: %s"):format(argument, tostring(value3)), os.clock()
        runtimeState.errorLog = runtimeState.errorLog or {}
        value = ("%s: %s"):format(argument, tostring(value3))
        value2 = runtimeState.errorLog[value]
        if value2 then
            value2.n, value2.last = value2.n + 1, os.clock()
        else
            runtimeState.errorLog[value] = { n = 1, first = os.clock(), last = os.clock() }
        end
        if os.clock() - (sharedValue107[argument] or -math.huge) > 5 then
            sharedValue107[argument] = os.clock()
            warn(("[DQ %s] %s: %s"):format(ver, argument, tostring(value3)))
        end
    end
    local helper234
    local function helper235(argument)
        if runtimeState.farmEnabled then
            context.brainTick(argument)
            if context.redPushApply then
                context.redPushApply(argument)
            end
            if context.spiralGuardApply then
                context.spiralGuardApply(argument)
            end
            if context.unionEscapeApply then
                context.unionEscapeApply(argument)
            end
            if context.orbBounceApply then
                context.orbBounceApply(argument)
            end
            if context.orbPushApply then
                context.orbPushApply(argument)
            end
        else
            helper2()
            context.setState("off")
        end
        pcall(helper234, argument)
    end
    local sharedValue108 = context.PATH and context.PATH.logs .. "/watch.txt" or "dq_watch.txt"
    pcall(function()
        if type(delfile) == "function" and type(isfile) == "function" then
            local iterateArray, value =
                ipairs, {
                    sharedValue108,
                    "dq_watch.txt",
                    (context.PATH and context.PATH.root or "HarvardLabs") .. "/logs/watch.txt",
                }
            for key, entry in iterateArray(value) do
                pcall(function()
                    if isfile(entry) then
                        delfile(entry)
                    end
                end)
            end
        end
    end)
    local sharedValue109, sharedValue110, health2 = {}
    local sharedValue111, sharedValue112, sharedValue113, sharedValue114, sharedValue115, sharedValue116, sharedValue117 =
        0, false
    helper234 = function(argument)
        if config.watchToFile ~= true then
            return
        elseif config.watchDisabled ~= false then
            return
        end
        if argument - (runtimeState.watchAt or 0) < (config.watchSampleEvery or 0.1) then
            return
        end
        runtimeState.watchAt = argument
        local f, humanoid, value = context.character()
        if humanoid then
            if not value then
                return
            end
        else
            return
        end
        local bubbleBoss, success, value2, value3 = context.BB, context.RD
        for index, entry in ipairs(success.enemies or {}) do
            if entry.isBoss then
                if entry.humanoid.Health > 0 then
                    index = math.sqrt((value.Position.X - entry.x) ^ 2 + (value.Position.Z - entry.z) ^ 2)
                    if value2 then
                        if index < value2 then
                            value2, value3 = index, entry
                        end
                    else
                        value2, value3 = index, entry
                    end
                end
            end
        end
        if health2 and humanoid.Health < health2 - 1 then
            local value4 = {}
            for index2, entry2 in ipairs(context.DG.boxes or {}) do
                local value5, value6, value7 =
                    context.depthOf and not entry2.moving and entry2.cx and context.depthOf(
                        entry2,
                        value.Position.X,
                        value.Position.Y,
                        value.Position.Z,
                        context.DG.halfHeight or 4
                    ) or nil,
                    entry2.moving and entry2.ox or entry2.cx,
                    entry2.moving and entry2.oz or entry2.cz
                if value6 then
                    local value8, value9 =
                        math.sqrt((value.Position.X - value6) ^ 2 + (value.Position.Z - value7) ^ 2),
                        value5 ~= nil and value5 <= -100000000
                    local value10, value11 =
                        value5 ~= nil and not value9 and value5 >= -12,
                        (entry2.from or 0) <= (context.DG.now or 0)
                            and (entry2.untilAt or math.huge) >= (context.DG.now or 0)
                    if value8 < 40 or value10 or value9 then
                        local value12, value13 = #value4 + 1, tostring
                        local value14, moving = value13(entry2.name), entry2.moving
                        index2, value13 = moving and "/mov" or "", value11 and ""
                        local value15, value16 =
                            value13 or "/DEAD",
                            value9 and " CUT(offhalf-or-height)"
                                or (value10 and (" INSIDE(depth %.0f)"):format(value5) or "")
                        value4[value12] = ("%s@%.0f%s%s%s"):format(value14, value8, index2, value15, value16)
                    end
                end
            end
            local value17, value18, health = sharedValue109, #sharedValue109 + 1, health2
            local value19, health3, value20, value21, value22, value23, value24, value25, value26, walkSpeed, value27, value28 =
                health - humanoid.Health,
                humanoid.Health,
                bubbleBoss.active and "ON" or "--",
                bubbleBoss.lethal and "!" or " ",
                bubbleBoss.count or 0,
                bubbleBoss.warmCount or 0,
                bubbleBoss.warnCount or 0,
                value2 and (("%.0f"):format(value2)) or "-",
                success.leash and "Y" or "n",
                humanoid.WalkSpeed,
                tostring(runtimeState.movementState),
                argumentHelpers[108](table.concat(value4, " "))
            value17[value18] = ("HIT -%.0f -> %.0f | bb=%s%s thr=%d/%dwarm/%dyellow bossD=%s leash=%s ws=%.0f | %s | near: %s"):format(
                value19,
                health3,
                value20,
                value21,
                value22,
                value23,
                value24,
                value25,
                value26,
                walkSpeed,
                value27,
                argumentHelpers:unpackValues(value28)
            )
        end
        health2 = humanoid.Health
        local value29 = value.Position
        if sharedValue113 then
            local value30, value31 = value29.X - sharedValue113.X, value29.Z - sharedValue113.Z
            local value32, value33 =
                math.sqrt(value30 * value30 + value31 * value31),
                math.max(argument - (sharedValue114 or argument), 0.001)
            if sharedValue115 then
                if value32 > 3 then
                    if value33 < 0.6 then
                        value = math.sqrt(sharedValue115 * sharedValue115 + sharedValue116 * sharedValue116)
                        if value > 0.5 then
                            local value34 = (value30 * sharedValue115 + value31 * sharedValue116)
                                / (value32 * value)
                            if value34 < -0.5 then
                                sharedValue117 = (sharedValue117 or 0) + 1
                                local value35 = sharedValue109
                                value35[#value35 + 1] = ("LAGBACK %.1f studs backwards in %.2fs (ws=%.0f, state=%s) total=%d"):format(
                                    value32,
                                    value33,
                                    humanoid.WalkSpeed,
                                    tostring(runtimeState.movementState),
                                    sharedValue117
                                )
                            end
                        end
                    end
                end
            end
            if value32 > 0.2 then
                local value36, value37 = value30 / value32, value31 / value32
                sharedValue115, sharedValue116 = value36, value37
            end
        end
        sharedValue113, sharedValue114 = value29, argument
        value29 = tostring(runtimeState.movementState)
        if argument - (runtimeState.wWallAt or 0) >= 0.1 then
            runtimeState.wWallAt = argument
            local iteratePairs, value38 = pairs, success.walls or {}
            for key, entry3 in iteratePairs(value38) do
                if entry3.cx then
                    local value39, ball2 = key:FindFirstChild("ball1"), key:FindFirstChild("ball2")
                    local value40, value41, value42 =
                        value39 and (value39:FindFirstChildWhichIsA("BasePart")),
                        ball2 and (ball2:FindFirstChildWhichIsA("BasePart")),
                        math.sqrt(entry3.vx * entry3.vx + entry3.vz * entry3.vz)
                    value39, value =
                        value42 > 0.5 and entry3.ax and math.abs(
                            (entry3.ax * entry3.vx + entry3.az * entry3.vz) / value42
                        ) or -1,
                        sharedValue109
                    value[#value + 1] = ("WALL %7.1f %s c=(%.0f,%.0f) v=(%.1f,%.1f) sp=%.1f halfLen=%.0f axis=(%.2f,%.2f) |axis.v|=%.2f b1=%s b2=%s"):format(
                        argument % 100000,
                        key.Name,
                        entry3.cx,
                        entry3.cz,
                        entry3.vx,
                        entry3.vz,
                        value42,
                        entry3.halfLen or -1,
                        entry3.ax or 0,
                        entry3.az or 0,
                        value39,
                        value40 and ("(%.0f,%.0f)"):format(value40.Position.X, value40.Position.Z) or "?",
                        value41 and ("(%.0f,%.0f)"):format(value41.Position.X, value41.Position.Z) or "?"
                    )
                end
            end
        end
        if value29 ~= sharedValue110 or argument - sharedValue111 > 2 then
            sharedValue110 = value29
            value = sharedValue109
            value[#value + 1] = ("%7.1f hp=%3.0f%% ws=%2.0f bb=%s%s thr=%d bossD=%s leash=%s | %s"):format(
                argument % 100000,
                humanoid.Health / math.max(humanoid.MaxHealth, 1) * 100,
                humanoid.WalkSpeed,
                bubbleBoss.active and "ON" or "--",
                bubbleBoss.lethal and "!" or " ",
                bubbleBoss.count or 0,
                value2 and ("%.0f"):format(value2) or "-",
                success.leash and "Y" or "n",
                value29
            )
        end
        if argument - sharedValue111 > 2 then
            if #sharedValue109 > 0 then
                sharedValue111 = argument
                success = pcall(function()
                    if not sharedValue112 then
                        if isfile then
                            if not (isfile(sharedValue108)) then
                                writefile(sharedValue108, "")
                            end
                        else
                            writefile(sharedValue108, "")
                        end
                        sharedValue112 = true
                    end
                    appendfile(sharedValue108, table.concat(sharedValue109, "\10") .. "\10")
                end)
                if success then
                    sharedValue109 = {}
                elseif #sharedValue109 > 400 then
                    sharedValue109 = {}
                end
            end
        end
    end
    runtimeState.streamerConnection = runService.Heartbeat:Connect(function()
        if runtimeState.destroyed then
            return
        end
        local now = os.clock()
        pcall(helper13, now)
        local streamer = os.clock() - now
        if runtimeState.stMax then
            if streamer > (runtimeState.stMax.streamer or 0) then
                runtimeState.stMax.streamer = streamer
            end
        end
    end)
    if config.perfProbe ~= false and not context.NOVIS then
        local function helper236(argument, argument2, argument3)
            local value = argument and argument[argument2]
            if type(value) ~= "function" then
                return
            elseif argument["__perf_" .. argument2] then
                return
            end
            argument["__perf_" .. argument2] = value
            argument[argument2] = function(...)
                local now, value2, value3, value4, value5 = os.clock(), value(...)
                if runtimeState.perf then
                    context.perfAdd(runtimeState.perf.cur.fns, argument3, os.clock() - now)
                end
                return value2, value3, value4, value5
            end
        end
        if context.BB then
            hlBugReport = {
                "tick",
                "pathTouchesRed",
                "orbPathSafe",
                "route",
                "detour",
                "yellowAt",
                "orbLaneHit",
                "blueBeams",
                "onBlueBeam",
                "orbCrossIn",
                "orbArrive",
                "redRoute",
                "pathBlocked",
            }
            for index29, entry32 in ipairs(hlBugReport) do
                helper236(context.BB, entry32, "BB." .. entry32)
            end
        end
        helper18 = { "spiralList", "spiralArms", "spiralWalkBad", "spiralRedOn", "groupPlan" }
        for index30, entry33 in ipairs(helper18) do
            helper236(context, entry33, entry33)
        end
        context.GS_PERF_STEPS = {
            "gsShortOut",
            "gsFwdRun",
            "gsKcRim",
            "gsSnakeOut",
            "gsCircleExit",
            "gsBossOut",
            "gsSafePick",
            "gsZPassPoint",
            "gsVyZonesTick",
            "gsVyWallGap",
            "gsVyEscVec",
            "gsLapEdge",
            "gsGroupPlan",
            "gsPlanTarget",
            "gsFwdEnvelope",
            "gsWrapHull",
            "gsOrbitPath",
            "gsRoomCircle",
            "gsPathEdges",
            "gsGreenLane",
            "gsGreenSafe",
            "gsFlameWay",
            "gsBallPlan",
            "gsSweepPlan",
            "gsCraggFlameWalk",
            "gsRampRun",
            "gsLookTick",
            "gsBeamWallTick",
            "gsBallistaBoxes",
            "gsBlockGuard",
            "gsEscCheck",
            "gsLeastDanger",
            "gsFwdMill",
            "gsNoStillStep",
            "gsSpeedTick",
            "gsCraggOrbTick",
            "gsCraggMeteorTick",
            "gsSafeSpot",
            "gsGrowCircle",
            "gsCornerOut",
            "gsOpenSpot",
            "gsSpiralEntry",
        }
        local function helper237(argument)
            local value = context[argument]
            if type(value) ~= "function" then
                return
            elseif context["__perf_" .. argument] then
                return
            end
            context["__perf_" .. argument] = value
            context[argument] = function(...)
                local now, value2 = os.clock(), table.pack(value(...))
                if runtimeState.perf then
                    context.perfAdd(runtimeState.perf.cur.fns, argument, os.clock() - now)
                end
                return table.unpack(value2, 1, value2.n)
            end
        end
        if config.gsPerfSteps ~= false and context.DEV then
            for index31, step in ipairs(context.GS_PERF_STEPS) do
                helper237(step)
            end
        end
    end
    runtimeState.mainConnection = runService.Heartbeat:Connect(function()
        if runtimeState.destroyed then
            return
        end
        runtimeState.frameN = (runtimeState.frameN or 0) + 1
        if runtimeState.modHalt then
            return
        end
        local value = os.clock()
        local perf, cur = runtimeState.perf
        if perf then
            local wasRodin = hazardReader.rodinRig ~= nil and hazardReader.rodinRig.Parent ~= nil
            if perf.wasRodin then
                if not wasRodin then
                    if not context.NOVIS then
                        pcall(function()
                            local value2, value3 =
                                (context.PATH and context.PATH.logs or "HarvardLabs/logs")
                                    .. "/perf_rodin.jsonl",
                                getService("HttpService"):JSONEncode({
                                    ver = ver,
                                    at = os.time(),
                                    set = perf.sets.rodin,
                                })
                            if appendfile and isfile and isfile(value2) then
                                appendfile(value2, value3 .. "\10")
                            elseif writefile then
                                writefile(value2, value3 .. "\10")
                            end
                        end)
                        perf.sets.rodin = perf.newSet()
                    end
                end
            end
            perf.wasRodin = wasRodin
            cur = wasRodin and perf.sets.rodin or perf.sets.other
            perf.cur = cur
            if value - (perf.pingAt or 0) > 1 then
                perf.pingAt = value
                local max, ping = (runtimeState.pingS or 0) * 1000, cur.ping
                ping.n, ping.sum = ping.n + 1, ping.sum + max
                if max > ping.max then
                    ping.max = max
                end
                if max > 150 then
                    ping.over150 = ping.over150 + 1
                end
                if max > 300 then
                    ping.over300 = ping.over300 + 1
                end
            end
            if not context.NOVIS then
                if value - (perf.savedAt or 0) > 10 then
                    perf.savedAt = value
                    pcall(function()
                        if writefile then
                            writefile(
                                (context.PATH and context.PATH.logs or "HarvardLabs/logs") .. "/perf.json",
                                getService("HttpService"):JSONEncode({
                                    ver = ver,
                                    secs = value - perf.since,
                                    sets = perf.sets,
                                })
                            )
                        end
                    end)
                end
            end
            wasRodin = cur.frames
            local value4 = value - (wasRodin.last or value)
            wasRodin.last, wasRodin.n = value, wasRodin.n + 1
            if value4 > wasRodin.maxGap then
                wasRodin.maxGap = value4
            end
            if value4 > 0.05 then
                wasRodin.gap50 = wasRodin.gap50 + 1
            end
            if value4 > 0.1 then
                wasRodin.gap100 = wasRodin.gap100 + 1
                if value4 > 0.25 then
                    wasRodin.gap250 = wasRodin.gap250 + 1
                end
                local spikes = wasRodin.spikes
                local value5, value6 =
                    #spikes + 1, { at = value - perf.since, gap = value4, work = wasRodin.lastWork or 0 }
                value6.state, spikes[value5] = tostring(runtimeState.movementState or ""):sub(1, 70), value6
                if #spikes > 40 then
                    table.remove(spikes, 1)
                end
            end
        end
        local mainLoop = config.tickHz or 0
        if mainLoop > 0 then
            if runtimeState.lastTickAt then
                if value - runtimeState.lastTickAt < 1 / mainLoop then
                    return
                end
            end
            runtimeState.lastTickAt = value
        end
        helper233("reader", context.readerTick, value)
        helper233("lobby", context.lobbyTick, value)
        helper233("config", context.autosaveTick, value)
        helper233("range", context.judgeCasts, value)
        helper233("buffs", context.buffTick, value)
        helper233("brain", helper235, value)
        helper233("caster", context.casterTick, value)
        helper233("face", context.faceTick, value)
        runtimeState.econN = (runtimeState.econN or 0) + 1
        mainLoop = config.lowEndEconomy ~= false
            and (runtimeState.tickMs or 0) > (config.lowEndLoad or 2)
            and runtimeState.econN % 2 == 0
        if
            if mainLoop
                then not mainLoop
                else not (config.drawFrameBudget ~= false and os.clock() - value > (tonumber(
                    config.drawFrameBudgetMs
                ) or 12) / 1000 and (runtimeState.drawSkipN or 0) < 2)
        then
            runtimeState.drawSkipN = 0
            runtimeState.drawRestAt = nil
            helper233("draw", context.drawTick, value)
            if runtimeState.drawRestAt then
                if runtimeState.perf then
                    if runtimeState.perf.cur then
                        if context.perfAdd then
                            context.perfAdd(
                                runtimeState.perf.cur.fns,
                                "draw.rest",
                                os.clock() - runtimeState.drawRestAt
                            )
                        end
                    end
                end
            end
        else
            runtimeState.drawSkipN = (runtimeState.drawSkipN or 0) + 1
        end
        mainLoop = os.clock() - value
        if mainLoop > (runtimeState.stMax.mainLoop or 0) then
            runtimeState.stMax.mainLoop = mainLoop
        end
        runtimeState.tickMs = runtimeState.tickMs * 0.9 + (os.clock() - value) * 100
        if cur then
            local value7, work = os.clock() - value, cur.work
            work.n, work.sum = work.n + 1, work.sum + value7
            if value7 > work.max then
                work.max = value7
            end
            if value7 > 0.008 then
                work.over8 = work.over8 + 1
            end
            if value7 > 0.016 then
                work.over16 = work.over16 + 1
            end
            if value7 > 0.033 then
                work.over33 = work.over33 + 1
            end
            cur.frames.lastWork = value7
        end
    end)
end
