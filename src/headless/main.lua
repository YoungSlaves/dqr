return function(Context)
    local CFG = Context.CFG
    local RT = Context.RT or {}
    Context.SWANGY = Context.SWANGY or {}
    local Settings = Context.SWANGY
    local Automation = Settings.Automation or {}
    Context.RT = RT
    local Global = (type(getgenv) == "function" and getgenv()) or _G
    local ManualOff = Global.SwangyManualOff == true
    RT.destroyed = false
    RT.modHalt = false
    RT.farmEnabled = Automation.Enabled ~= false
    RT.Stats = { Runs = 0, Deaths = 0, Kills = 0, Wins = 0, Losses = 0 }
    Context.NOVIS = false
    CFG.visuals = true
    CFG.minimap = false

    local function CurrentHumanoid()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local Character = Player and Player.Character
        return Character and Character:FindFirstChildOfClass("Humanoid")
    end

    local function CurrentWalkSpeed()
        local Humanoid = CurrentHumanoid()
        local Speed = Humanoid and tonumber(Humanoid.WalkSpeed)
        return if Speed and Speed > 0 then Speed else nil
    end

    local function DisableWalkSpeedControl()
        local Baseline = CurrentWalkSpeed() or tonumber(CFG.tweenWalk) or 16
        RT.WalkSpeedBaseline = Baseline
        CFG.tweenWalk = Baseline
        CFG.speedCustom = false
        Context.speedHoldTick = function() end
        Context.speedApply = function() end
        Context.speedCustomOn = function()
            return false
        end
        Context.speedNormal = function()
            return CurrentWalkSpeed() or Baseline
        end
        Context.speedBurst = function()
            return CurrentWalkSpeed() or Baseline
        end
        Context.walkNormal = function(Humanoid)
            return (Humanoid and Humanoid.WalkSpeed) or CurrentWalkSpeed() or Baseline
        end
        Context.buffHoldsSpeed = function()
            return false
        end
        Context.restoreWalkSpeed = function() end
        if type(Context.LC) == "table" then
            Context.LC.on = function(_, Speed)
                return Speed
            end
            Context.LC.off = function() end
            Context.LC.stop = function() end
            Context.LC.boosted = function()
                return false
            end
            Context.LC.active = function()
                return false
            end
            Context.LC.speed = function()
                return nil
            end
            if type(Context.LC.CONFIG) == "table" then
                Context.LC.CONFIG.FallbackSpeed = Baseline
            end
        end
        if Context.MV then
            Context.MV.walkSpeed = nil
            Context.MV.walkSpeedBefore = nil
        end
    end
    DisableWalkSpeedControl()

    local function InstallWalkSpeedGuard(Humanoid)
        if not Humanoid or RT.destroyed then
            return
        end
        RT.WalkSpeedConnections = RT.WalkSpeedConnections or {}
        RT.WalkSpeedHumanoid = Humanoid
        RT.WalkSpeedConnections[#RT.WalkSpeedConnections + 1] = Humanoid.Changed:Connect(function(Property)
            if Property ~= "WalkSpeed" or RT.destroyed then
                return
            end
            local Baseline = tonumber(RT.WalkSpeedBaseline)
            if
                Baseline
                and Baseline > 0
                and Humanoid.Parent ~= nil
                and Humanoid.Health > 0
                and math.abs(Humanoid.WalkSpeed - Baseline) > 0.01
            then
                Humanoid.WalkSpeed = Baseline
            end
        end)
    end

    InstallWalkSpeedGuard(CurrentHumanoid())
    local CharacterAddedConnection
    local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
    if Player then
        CharacterAddedConnection = Player.CharacterAdded:Connect(function(Character)
            local Humanoid = Character:WaitForChild("Humanoid", 10)
            if Humanoid then
                InstallWalkSpeedGuard(Humanoid)
            end
        end)
        RT.WalkSpeedConnections = RT.WalkSpeedConnections or {}
        RT.WalkSpeedConnections[#RT.WalkSpeedConnections + 1] = CharacterAddedConnection
    end

    local Resume = {
        autoQueue = Automation.AutoQueue ~= false,
        autoQueueReplay = Automation.AutoQueueReplay ~= false,
        autoStartDungeon = Automation.AutoStart ~= false,
        autoAttack = CFG.autoAttack,
        autoE = CFG.autoE,
        autoQ = CFG.autoQ,
        autoSell = CFG.autoSell,
        wallsOn = CFG.wallsOn,
        visuals = true,
    }

    local Multifarm = (((Settings.LobbySettings or {}).GameCreation or {}).Multifarm or {})
    if Context.AF and type(Context.AF.load) == "function" then
        local BaseLoad = Context.AF.load
        Context.AF.load = function(argument)
            local Party = BaseLoad(argument)
            if type(Party) == "table" and argument == nil then
                Party.on = Multifarm.Enabled == true
                if Party.on then
                    Party.map = CFG.autoQueueMap
                    Party.difficulty = CFG.autoQueueDifficulty
                    Party.replay = CFG.autoQueueReplay ~= false
                    local Accounts = {}
                    if type(Multifarm.HostAccount) == "string" and Multifarm.HostAccount ~= "" then
                        Accounts[#Accounts + 1] = { name = Multifarm.HostAccount, role = "leader", enabled = true }
                    end
                    for Key, Value in pairs(type(Multifarm.JoinerAccounts) == "table" and Multifarm.JoinerAccounts or {}) do
                        local Name = if type(Value) == "string" then Value else Key
                        if type(Value) == "table" then
                            Name = Value.Name or Value.name or Key
                        end
                        if type(Name) == "string" and Name ~= "" then
                            Accounts[#Accounts + 1] = { name = Name, role = "fight", enabled = true }
                        end
                    end
                    if #Accounts > 0 then
                        if Accounts[1].role ~= "leader" then
                            Accounts[1].role = "leader"
                        end
                        Party.accounts = Accounts
                    end
                end
            end
            return Party
        end
    end
    if Context.RAID and Context.RAID.cfg then
        Context.RAID.cfg.fixedTier = tonumber(CFG.bossRaidTier) or Context.RAID.cfg.fixedTier
    end

    local function SpotTick(Now)
        local DG = Context.DG
        if not (DG and DG.origin and Context.dangerAt) then
            return
        end
        if CFG.visuals == false or CFG.drawSpots == false then
            return
        end
        if Now - (RT.spotAt or 0) < (tonumber(CFG.spotEvery) or 0.35) then
            return
        end
        RT.spotAt = Now
        local Boxes = DG.boxes
        if type(Boxes) ~= "table" or #Boxes == 0 then
            DG.cands = {}
            return
        end
        local Origin = DG.origin
        local Radius = math.max(tonumber(CFG.spotRadius) or 48, 16)
        local Step = math.max(tonumber(CFG.spotStep) or 8, 4)
        local FloorY = Origin.Y - 2.4
        local MoveAt = tonumber(CFG.dodgeMoveAt) or 0.15
        local Cands = {}
        for OffsetX = -Radius, Radius, Step do
            for OffsetZ = -Radius, Radius, Step do
                local X, Z = Origin.X + OffsetX, Origin.Z + OffsetZ
                local Danger = Context.dangerAt(X, FloorY, Z, 0)
                local Soon = Context.dangerAt(X, FloorY, Z, 0.6)
                Cands[#Cands + 1] = {
                    x = X,
                    y = FloorY,
                    z = Z,
                    ox = OffsetX,
                    oz = OffsetZ,
                    danger = Danger,
                    endDanger = math.max(Danger, Soon),
                    safe = Danger <= MoveAt,
                    valid = true,
                    blocked = false,
                }
            end
        end
        DG.cands = Cands
    end
    Context.spotTick = SpotTick

    local RunService = Context.RunService
    local LastTick = 0
    local Ticks = {
        "readerTick",
        "lobbyTick",
        "autoStartTick",
        "judgeCasts",
        "buffTick",
        "brainTick",
        "spotTick",
        "casterTick",
        "faceTick",
        "drawTick",
    }

    local Reported = {}
    local function Report(Name, ErrorMessage)
        if Reported[Name] or not Context.log then
            return
        end
        Reported[Name] = true
        Context.log("Headless", Name .. ": " .. tostring(ErrorMessage))
    end

    local function AutoStartTick(Now)
        if not CFG.autoStartDungeon or RT.destroyed or RT.modHalt then
            return
        end
        local Workspace = Context.Workspace or game:GetService("Workspace")
        local Name = Workspace:FindFirstChild("dungeonName")
        local Started = Workspace:FindFirstChild("dungeonStarted")
        if not (Name and tostring(Name.Value) ~= "" and Started and Started.Value == false) then
            RT.autoStartKey, RT.autoStartAt = nil, nil
            return
        end
        local Key = tostring(game.JobId) .. ":" .. tostring(game.PlaceId)
        if RT.autoStartKey ~= Key then
            RT.autoStartKey = Key
            RT.autoStartAt = Now + (tonumber(CFG.autoStartDelay) or 1)
        end
        if Now < (RT.autoStartAt or 0) or Now - (RT.autoStartFired or 0) < 8 then
            return
        end
        local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("remotes")
        local Remote = Remotes
            and (Remotes:FindFirstChild("changeStartValue") or Remotes:FindFirstChild("startDungeon"))
        if not Remote then
            return
        end
        RT.autoStartFired = Now
        local Ok, ErrorMessage = pcall(Remote.FireServer, Remote)
        if not Ok then
            Report("autoStart", ErrorMessage)
        end
    end
    Context.autoStartTick = AutoStartTick

    local function FreeMovement()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local Character = Player and Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Context.LC and Context.LC.off then
            pcall(Context.LC.off)
        end
        pcall(function()
            local PlayerModule = Player and Player.PlayerScripts:FindFirstChild("PlayerModule")
            if PlayerModule then
                require(PlayerModule):GetControls():Enable()
            else
                local ControlModule = game:GetService("StarterPlayer"):FindFirstChild("PlayerModule")
                    and game:GetService("StarterPlayer").PlayerModule:FindFirstChild("ControlModule")
                if ControlModule and ControlModule.hlMoveFn then
                    ControlModule.moveFunction = ControlModule.hlMoveFn
                    ControlModule.hlMoveFn = nil
                end
            end
        end)
        if Humanoid then
            pcall(function()
                Humanoid:Move(Vector3.zero, false)
            end)
            Humanoid.AutoRotate = true
        end
        if Context.MV then
            Context.MV.driving = false
            Context.MV.controlsOff = false
            Context.MV.controlsAt = 0
            Context.MV.cmdDir = nil
        end
    end

    local function ResetStats()
        local Stats = RT.Stats or {}
        RT.Stats = Stats
        Stats.Runs = 0
        Stats.Deaths = 0
        Stats.Kills = 0
        Stats.Wins = 0
        Stats.Losses = 0
        Stats.RunJob = game.JobId

        local WH = Context.WH
        if type(WH) == "table" then
            WH.wins = 0
            WH.losses = 0
            WH.mobKills = 0
            WH.bossKills = 0
            Stats.LastRun = WH.run
            if type(WH.run) == "table" then
                WH.run.deaths = 0
                WH.run.killM = 0
                WH.run.killB = 0
            end
        end

        local function RemoveFile(Path)
            if type(isfile) == "function" and type(delfile) == "function" then
                local Ok, Exists = pcall(isfile, Path)
                if Ok and Exists then
                    pcall(delfile, Path)
                end
            end
        end

        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local UserId = Player and tonumber(Player.UserId)
        if UserId then
            RemoveFile(("DQSession_%d.json"):format(UserId))
        end
        RemoveFile("HarvardLabs/data/session_all.json")
        if type(listfiles) == "function" and type(delfile) == "function" then
            local Ok, Files = pcall(listfiles, "HarvardLabs/data/sessionruns")
            if Ok and type(Files) == "table" then
                for _, Path in ipairs(Files) do
                    pcall(delfile, Path)
                end
            end
        end

        if Context.refreshHUD then
            pcall(Context.refreshHUD)
        end
    end

    local UIS = game:GetService("UserInputService")
    local ToggleGui, ToggleButton, PowerButton, PerfButton, BlackButton, ResetButton
    local HudGui, HudPanel, HudLabels
    local BlackGui

    local function SaveAutomation()
        if Context.saveSwangyConfig then
            pcall(Context.saveSwangyConfig)
        end
    end

    local function AddDrag(Handle, Target, SaveKey, Connections)
        local StartPosition, StartInput, Dragging, Moved = nil, nil, false, false
        local function BeginDrag(Input)
            if
                Input.UserInputType ~= Enum.UserInputType.MouseButton1
                and Input.UserInputType ~= Enum.UserInputType.Touch
            then
                return
            end
            Dragging, Moved = true, false
            StartPosition, StartInput = Target.AbsolutePosition, Input.Position
        end
        local function MoveDrag(Input)
            if not Dragging or not Target.Parent then
                return
            end
            local Delta = Input.Position - StartInput
            if Delta.Magnitude > 3 then
                Moved = true
                RT.SuppressToggleUntil = os.clock() + 0.5
            end
            local Camera = workspace.CurrentCamera
            local Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
            local Size = Target.AbsoluteSize
            Target.AnchorPoint = Vector2.new(0, 0)
            Target.Position = UDim2.fromOffset(
                math.clamp(StartPosition.X + Delta.X, 0, math.max(Viewport.X - Size.X, 0)),
                math.clamp(StartPosition.Y + Delta.Y, 0, math.max(Viewport.Y - Size.Y, 0))
            )
        end
        local function EndDrag()
            if not Dragging then
                return
            end
            Dragging = false
            if not Moved or not Target.Parent then
                return
            end
            RT.SuppressToggleUntil = os.clock() + 0.5
            Context.SWANGY.Automation = Context.SWANGY.Automation or {}
            Context.SWANGY.Automation[SaveKey] = {
                X = Target.Position.X.Offset,
                Y = Target.Position.Y.Offset,
            }
            SaveAutomation()
        end
        Connections[#Connections + 1] = Handle.InputBegan:Connect(BeginDrag)
        Connections[#Connections + 1] = UIS.InputChanged:Connect(MoveDrag)
        Connections[#Connections + 1] = UIS.InputEnded:Connect(EndDrag)
    end
    local function SetEnabled(Enabled, Save)
        if Enabled and not Save and Global.SwangyManualOff == true then
            Enabled = false
        end
        Context.headlessEnabled = Enabled
        Context.SWANGY.Automation = Context.SWANGY.Automation or {}
        Context.SWANGY.Automation.Enabled = Enabled
        if Enabled then
            CFG.autoQueue = Resume.autoQueue
            CFG.autoQueueReplay = Resume.autoQueueReplay
            CFG.autoStartDungeon = Resume.autoStartDungeon
            CFG.autoAttack = Resume.autoAttack
            CFG.autoE = Resume.autoE
            CFG.autoQ = Resume.autoQ
            CFG.autoSell = Resume.autoSell
            CFG.wallsOn = Resume.wallsOn
            CFG.visuals = Resume.visuals
            Context.NOVIS = false
            RT.modHalt = false
            RT.farmEnabled = true
            if not Context.fireLooped and Context.fireLoop then
                local Ok, ErrorMessage = pcall(Context.fireLoop)
                if not Ok then
                    Report("fireLoop", ErrorMessage)
                else
                    Context.fireLooped = true
                end
            end
        else
            CFG.autoQueue = false
            CFG.autoQueueReplay = false
            CFG.autoStartDungeon = false
            CFG.autoAttack = false
            CFG.autoE = false
            CFG.autoQ = false
            CFG.autoSell = false
            CFG.wallsOn = false
            CFG.visuals = false
            Context.NOVIS = true
            RT.modHalt = true
            RT.farmEnabled = false
            if Context.clearDrawing then
                pcall(Context.clearDrawing)
            end
            FreeMovement()
        end
        Global.SwangyManualOff = not Enabled
        if PowerButton and PowerButton.Parent then
            PowerButton.Text = Enabled and "POWER ON" or "POWER OFF"
            PowerButton.BackgroundColor3 = Enabled and Color3.fromRGB(27, 63, 53)
                or Color3.fromRGB(31, 33, 39)
            PowerButton.TextColor3 = Enabled and Color3.fromRGB(145, 235, 195)
                or Color3.fromRGB(177, 184, 195)
        end
        if Save and Context.saveSwangyConfig then
            pcall(Context.saveSwangyConfig)
        end
    end

    local function UpdatePerformanceButton()
        if not (PerfButton and PerfButton.Parent) then
            return
        end
        local Enabled = CFG.performanceMode ~= false
        PerfButton.Text = Enabled and "PERF ON" or "PERF OFF"
        PerfButton.BackgroundColor3 = Enabled and Color3.fromRGB(48, 39, 63)
            or Color3.fromRGB(31, 33, 39)
        PerfButton.TextColor3 = Enabled and Color3.fromRGB(207, 177, 255)
            or Color3.fromRGB(177, 184, 195)
    end

    local function SetPerformance(Enabled, Save)
        Context.SWANGY.Optimizations = Context.SWANGY.Optimizations or {}
        Context.SWANGY.Optimizations.PerformanceMode = Enabled
        CFG.performanceMode = Enabled
        CFG.perfMemo = Enabled
        UpdatePerformanceButton()
        if Save then
            SaveAutomation()
        end
    end

    local function BuildBlackScreen()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then
            return
        end
        local Existing = PlayerGui:FindFirstChild("SwangyBlack")
        if Existing then
            Existing:Destroy()
        end
        BlackGui = Instance.new("ScreenGui")
        BlackGui.Name = "SwangyBlack"
        BlackGui.ResetOnSpawn = false
        BlackGui.IgnoreGuiInset = true
        BlackGui.DisplayOrder = 400
        BlackGui.Enabled = RT.BlackScreen == true
        local Shade = Instance.new("Frame")
        Shade.Name = "Shade"
        Shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Shade.BackgroundTransparency = 0
        Shade.BorderSizePixel = 0
        Shade.Active = false
        Shade.Size = UDim2.fromScale(1, 1)
        Shade.Parent = BlackGui
        BlackGui.Parent = PlayerGui
        Context.blackGui = BlackGui
    end

    local function UpdateBlackButton()
        if not (BlackButton and BlackButton.Parent) then
            return
        end
        local Enabled = RT.BlackScreen == true
        BlackButton.Text = Enabled and "BLACK ON" or "BLACK OFF"
        BlackButton.BackgroundColor3 = Enabled and Color3.fromRGB(47, 38, 48)
            or Color3.fromRGB(31, 33, 39)
        BlackButton.TextColor3 = Enabled and Color3.fromRGB(247, 202, 215)
            or Color3.fromRGB(177, 184, 195)
    end

    local function SetBlackScreen(Enabled, Save)
        RT.BlackScreen = Enabled
        Context.SWANGY.Automation = Context.SWANGY.Automation or {}
        Context.SWANGY.Automation.BlackScreen = Enabled
        if RunService and RunService.Set3dRenderingEnabled then
            pcall(RunService.Set3dRenderingEnabled, RunService, not Enabled)
        end
        if Enabled then
            if not BlackGui or not BlackGui.Parent then
                BuildBlackScreen()
            elseif BlackGui then
                BlackGui.Enabled = true
            end
        elseif BlackGui then
            BlackGui.Enabled = false
        end
        UpdateBlackButton()
        if Save then
            SaveAutomation()
        end
    end

    local function BuildToggle()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then
            return
        end
        if Context.toggleDragConnections then
            for _, Connection in ipairs(Context.toggleDragConnections) do
                pcall(Connection.Disconnect, Connection)
            end
            Context.toggleDragConnections = nil
        end
        local Existing = PlayerGui:FindFirstChild("SwangyToggle")
        if Existing then
            Existing:Destroy()
        end
        ToggleGui = Instance.new("ScreenGui")
        ToggleGui.Name = "SwangyToggle"
        ToggleGui.ResetOnSpawn = false
        ToggleGui.IgnoreGuiInset = false
        ToggleGui.DisplayOrder = 550
        ToggleGui.Parent = PlayerGui

        local Rail = Instance.new("Frame")
        Rail.Name = "Controls"
        Rail.AnchorPoint = Vector2.new(1, 0)
        Rail.Position = UDim2.new(1, -14, 0, 54)
        local Automation = Context.SWANGY.Automation or {}
        local SavedPosition = Automation.ControlPosition
        if type(SavedPosition) == "table" and tonumber(SavedPosition.X) and tonumber(SavedPosition.Y) then
            Rail.AnchorPoint = Vector2.new(0, 0)
            Rail.Position = UDim2.fromOffset(SavedPosition.X, SavedPosition.Y)
        end
        Rail.Size = UDim2.fromOffset(328, 34)
        Rail.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
        Rail.BackgroundTransparency = 0.08
        Rail.BorderSizePixel = 0
        Rail.Parent = ToggleGui
        local RailCorner = Instance.new("UICorner")
        RailCorner.CornerRadius = UDim.new(0, 9)
        RailCorner.Parent = Rail
        local RailStroke = Instance.new("UIStroke")
        RailStroke.Color = Color3.fromRGB(56, 59, 70)
        RailStroke.Thickness = 1
        RailStroke.Transparency = 0.35
        RailStroke.Parent = Rail
        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 4)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Rail
        local RailPadding = Instance.new("UIPadding")
        RailPadding.PaddingLeft = UDim.new(0, 4)
        RailPadding.PaddingRight = UDim.new(0, 4)
        RailPadding.PaddingTop = UDim.new(0, 3)
        RailPadding.PaddingBottom = UDim.new(0, 3)
        RailPadding.Parent = Rail

        local function NewButton(Name, Text, Width, Order)
            local Button = Instance.new("TextButton")
            Button.Name = Name
            Button.LayoutOrder = Order
            Button.Size = UDim2.new(0, Width, 1, 0)
            Button.BackgroundColor3 = Color3.fromRGB(31, 33, 39)
            Button.BorderSizePixel = 0
            Button.Text = Text
            Button.TextColor3 = Color3.fromRGB(180, 187, 198)
            Button.TextSize = 10
            Button.Font = Enum.Font.GothamBold
            Button.TextWrapped = false
            Button.TextTruncate = Enum.TextTruncate.AtEnd
            Button.Active = true
            Button.AutoButtonColor = false
            Button.Parent = Rail
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = Button
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(65, 69, 80)
            Stroke.Thickness = 1
            Stroke.Transparency = 0.55
            Stroke.Parent = Button
            return Button
        end

        PowerButton = NewButton("Power", "POWER", 78, 1)
        PerfButton = NewButton("Performance", "PERF", 70, 2)
        BlackButton = NewButton("Black", "BLACK", 72, 3)
        ResetButton = NewButton("ResetStats", "RESET STATS", 88, 4)
        ResetButton.TextColor3 = Color3.fromRGB(238, 155, 170)
        ToggleButton = PowerButton

        local ArmedAt = os.clock() + 0.5
        local function Bind(Button, Callback)
            local Last = 0
            local function Run()
                local Now = os.clock()
                if Now < ArmedAt or Now < (RT.SuppressToggleUntil or 0) or Now - Last < 0.25 then
                    return
                end
                Last = Now
                Callback()
            end
            Button.MouseButton1Click:Connect(Run)
            Button.TouchTap:Connect(Run)
        end

        Bind(PowerButton, function()
            SetEnabled(not Context.headlessEnabled, true)
        end)
        Bind(PerfButton, function()
            SetPerformance(CFG.performanceMode == false, true)
        end)
        Bind(BlackButton, function()
            SetBlackScreen(not RT.BlackScreen, true)
        end)
        Bind(ResetButton, function()
            ResetStats()
        end)

        Context.toggleDragConnections = {}
        AddDrag(PowerButton, Rail, "ControlPosition", Context.toggleDragConnections)
        SetPerformance(CFG.performanceMode ~= false, false)
        PowerButton.Text = Context.headlessEnabled and "POWER ON" or "POWER OFF"
        PowerButton.BackgroundColor3 = Context.headlessEnabled and Color3.fromRGB(27, 63, 53)
            or Color3.fromRGB(31, 33, 39)
        PowerButton.TextColor3 = Context.headlessEnabled and Color3.fromRGB(145, 235, 195)
            or Color3.fromRGB(177, 184, 195)
        UpdateBlackButton()
        Context.toggleGui = ToggleGui
        Context.toggleButton = PowerButton
        Context.controlRail = Rail
        Context.controlButtons = { PowerButton, PerfButton, BlackButton, ResetButton }
    end

    local function BuildHUD()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then
            return
        end
        if Context.hudConnections then
            for _, Connection in ipairs(Context.hudConnections) do
                pcall(Connection.Disconnect, Connection)
            end
            Context.hudConnections = nil
        end
        if Context.hudDragConnections then
            for _, Connection in ipairs(Context.hudDragConnections) do
                pcall(Connection.Disconnect, Connection)
            end
            Context.hudDragConnections = nil
        end
        local Existing = PlayerGui:FindFirstChild("SwangyHUD")
        if Existing then
            Existing:Destroy()
        end
        HudGui = Instance.new("ScreenGui")
        HudGui.Name = "SwangyHUD"
        HudGui.ResetOnSpawn = false
        HudGui.IgnoreGuiInset = false
        HudGui.DisplayOrder = 540
        HudGui.Parent = PlayerGui

        HudPanel = Instance.new("Frame")
        HudPanel.Name = "Stats"
        HudPanel.AnchorPoint = Vector2.new(1, 0)
        HudPanel.Position = UDim2.new(1, -14, 0, 14)
        local SavedPosition = (Context.SWANGY.Automation or {}).HudPosition
        if type(SavedPosition) == "table" and tonumber(SavedPosition.X) and tonumber(SavedPosition.Y) then
            HudPanel.AnchorPoint = Vector2.new(0, 0)
            HudPanel.Position = UDim2.fromOffset(SavedPosition.X, SavedPosition.Y)
        end
        HudPanel.Size = UDim2.fromOffset(620, 34)
        HudPanel.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
        HudPanel.BackgroundTransparency = 0.08
        HudPanel.BorderSizePixel = 0
        HudPanel.Active = true
        HudPanel.Parent = HudGui
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 9)
        Corner.Parent = HudPanel
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(56, 59, 70)
        Stroke.Thickness = 1
        Stroke.Transparency = 0.35
        Stroke.Parent = HudPanel

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = HudPanel
        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.PaddingRight = UDim.new(0, 10)
        Padding.PaddingTop = UDim.new(0, 4)
        Padding.PaddingBottom = UDim.new(0, 4)
        Padding.Parent = HudPanel

        local Brand = Instance.new("TextLabel")
        Brand.Name = "Brand"
        Brand.BackgroundTransparency = 1
        Brand.AutomaticSize = Enum.AutomaticSize.X
        Brand.Size = UDim2.new(0, 0, 1, 0)
        Brand.Text = "SWANGY"
        Brand.TextColor3 = Color3.fromRGB(255, 111, 170)
        Brand.TextSize = 11
        Brand.Font = Enum.Font.GothamBold
        Brand.TextXAlignment = Enum.TextXAlignment.Left
        Brand.LayoutOrder = 1
        Brand.Parent = HudPanel

        local Badge = Instance.new("Frame")
        Badge.Name = "Badge"
        Badge.Size = UDim2.fromOffset(32, 18)
        Badge.BackgroundColor3 = Color3.fromRGB(50, 38, 66)
        Badge.BorderSizePixel = 0
        Badge.LayoutOrder = 2
        Badge.Parent = HudPanel
        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(0, 5)
        BadgeCorner.Parent = Badge
        local BadgeText = Instance.new("TextLabel")
        BadgeText.BackgroundTransparency = 1
        BadgeText.Size = UDim2.fromScale(1, 1)
        BadgeText.Text = "LIVE"
        BadgeText.TextColor3 = Color3.fromRGB(207, 177, 255)
        BadgeText.TextSize = 8
        BadgeText.Font = Enum.Font.GothamBold
        BadgeText.Parent = Badge

        local function AddSeparator(Order)
            local Separator = Instance.new("TextLabel")
            Separator.Name = "Separator"
            Separator.BackgroundTransparency = 1
            Separator.AutomaticSize = Enum.AutomaticSize.X
            Separator.Size = UDim2.new(0, 0, 1, 0)
            Separator.Text = "│"
            Separator.TextColor3 = Color3.fromRGB(64, 69, 80)
            Separator.TextSize = 11
            Separator.Font = Enum.Font.GothamMedium
            Separator.LayoutOrder = Order
            Separator.Parent = HudPanel
        end

        HudLabels = { Brand = Brand, Badge = BadgeText }
        local Rows = { "FPS", "RUNS", "DEATHS", "KILLS", "WINS", "LOSSES" }
        AddSeparator(3)
        local Order = 4
        for Index, Name in ipairs(Rows) do
            local Label = Instance.new("TextLabel")
            Label.Name = Name
            Label.BackgroundTransparency = 1
            Label.AutomaticSize = Enum.AutomaticSize.X
            Label.Size = UDim2.new(0, 0, 1, 0)
            Label.RichText = true
            Label.TextColor3 = Color3.fromRGB(242, 245, 250)
            Label.Text = ("<font color=\"#778191\">%s</font>  <font color=\"#F2F5FA\">0</font>"):format(Name)
            Label.TextSize = 11
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.LayoutOrder = Order
            Label.Parent = HudPanel
            HudLabels[Name] = Label
            Order += 1
            if Index < #Rows then
                AddSeparator(Order)
                Order += 1
            end
        end

        Context.hudDragConnections = {}
        AddDrag(HudPanel, HudPanel, "HudPosition", Context.hudDragConnections)

        local Stats = RT.Stats
        local Frames, FpsAt, Fps = 0, os.clock(), 0
        local RenderConnection = RunService.RenderStepped:Connect(function()
            Frames += 1
            local Now = os.clock()
            if Now - FpsAt >= 1 then
                Fps = math.floor(Frames / (Now - FpsAt) + 0.5)
                Frames, FpsAt = 0, Now
            end
        end)

        local function WatchDeaths()
            local Character = Player.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if not Humanoid or Stats.DeathHumanoid == Humanoid then
                return
            end
            Stats.DeathHumanoid = Humanoid
            Stats.DeathConnections = Stats.DeathConnections or {}
            Stats.DeathConnections[#Stats.DeathConnections + 1] = Humanoid.Died:Connect(function()
                Stats.Deaths += 1
            end)
        end
        WatchDeaths()
        local CharacterConnection = Player.CharacterAdded:Connect(function()
            task.wait(0.5)
            WatchDeaths()
        end)

        local KillHook = Context.noteKillAll
        if type(KillHook) == "function" and not Context.HeadlessKillHook then
            Context.HeadlessKillHook = true
            Context.noteKillAll = function(Boss)
                Stats.Kills += 1
                return KillHook(Boss)
            end
        end

        local function RenderHUD()
            if not HudLabels then
                return
            end
            local function Stat(Name, Value)
                return ("<font color=\"#778191\">%s</font>  <font color=\"#F2F5FA\">%s</font>"):format(
                    Name,
                    tostring(Value)
                )
            end
            HudLabels.FPS.Text = Stat("FPS", Fps)
            HudLabels.RUNS.Text = Stat("RUNS", Stats.Runs)
            HudLabels.DEATHS.Text = Stat("DEATHS", Stats.Deaths)
            HudLabels.KILLS.Text = Stat("KILLS", Stats.Kills)
            HudLabels.WINS.Text = Stat("WINS", Stats.Wins)
            HudLabels.LOSSES.Text = Stat("LOSSES", Stats.Losses)
        end

        Context.hudConnections = { RenderConnection, CharacterConnection }
        Context.hudGui = HudGui
        Context.hudPanel = HudPanel
        Context.hudLabels = HudLabels
        Context.refreshHUD = RenderHUD
        RenderHUD()
        task.spawn(function()
            while not RT.destroyed do
                task.wait(0.35)
                local WH = Context.WH
                local Started = workspace:FindFirstChild("dungeonStarted")
                if WH then
                    if WH.run and WH.run ~= Stats.LastRun then
                        Stats.LastRun = WH.run
                        Stats.Runs += 1
                    end
                    Stats.Kills = math.max(Stats.Kills, (tonumber(WH.mobKills) or 0) + (tonumber(WH.bossKills) or 0))
                    Stats.Wins = tonumber(WH.wins) or Stats.Wins
                    Stats.Losses = tonumber(WH.losses) or Stats.Losses
                    Stats.Runs = math.max(Stats.Runs, Stats.Wins + Stats.Losses)
                elseif Started and Started.Value and Stats.RunJob ~= game.JobId then
                    Stats.RunJob = game.JobId
                    Stats.Runs += 1
                end
                RenderHUD()
            end
        end)
    end

    RT.BlackScreen = (Context.SWANGY.Automation or {}).BlackScreen == true
    SetEnabled(not ManualOff and Automation.Enabled ~= false, false)
    BuildToggle()
    BuildHUD()
    if RT.BlackScreen then
        BuildBlackScreen()
        if RunService and RunService.Set3dRenderingEnabled then
            pcall(RunService.Set3dRenderingEnabled, RunService, false)
        end
    end

    task.spawn(function()
        while not RT.destroyed do
            task.wait(1)
            if RT.destroyed then
                return
            end
            local ActivePlayer = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
            local ActiveGui = ActivePlayer and ActivePlayer:FindFirstChildOfClass("PlayerGui")
            if ActiveGui then
                if not ToggleGui or ToggleGui.Parent ~= ActiveGui or not PowerButton or not PowerButton.Parent then
                    BuildToggle()
                end
                if not HudGui or HudGui.Parent ~= ActiveGui or not HudPanel or not HudPanel.Parent then
                    BuildHUD()
                end
                if RT.BlackScreen and (not BlackGui or BlackGui.Parent ~= ActiveGui) then
                    BuildBlackScreen()
                end
            end
        end
    end)

    if Context.readerStart then
        local Ok, ErrorMessage = pcall(Context.readerStart)
        if not Ok then
            Report("readerStart", ErrorMessage)
        end
    end
    if RT.farmEnabled and Context.fireLoop then
        local Ok, ErrorMessage = pcall(Context.fireLoop)
        if not Ok then
            Report("fireLoop", ErrorMessage)
        end
    end

    local Connection = RunService.Heartbeat:Connect(function()
        if RT.destroyed or RT.modHalt then
            return
        end
        local Now = os.clock()
        local TickHz = math.clamp(tonumber(CFG.tickHz) or 30, 1, 120)
        if Now - LastTick < 1 / TickHz then
            return
        end
        LastTick = Now
        for _, Name in ipairs(Ticks) do
            local Tick = Context[Name]
            if type(Tick) == "function" then
                local Ok, ErrorMessage = pcall(Tick, Now)
                if not Ok then
                    Report(Name, ErrorMessage)
                end
            end
        end
    end)

    Context.headlessConnection = Connection
    Context.headlessSetEnabled = SetEnabled
    Context.headlessStop = function()
        RT.destroyed = true
        Context.NOVIS = true
        pcall(Connection.Disconnect, Connection)
        if Context.readerStop then
            pcall(Context.readerStop)
        end
        if Context.clearDrawing then
            pcall(Context.clearDrawing)
        end
        FreeMovement()
        if Context.toggleDragConnections then
            for _, DragConnection in ipairs(Context.toggleDragConnections) do
                pcall(DragConnection.Disconnect, DragConnection)
            end
            Context.toggleDragConnections = nil
        end
        if Context.hudConnections then
            for _, HudConnection in ipairs(Context.hudConnections) do
                pcall(HudConnection.Disconnect, HudConnection)
            end
            Context.hudConnections = nil
        end
        if Context.hudDragConnections then
            for _, DragConnection in ipairs(Context.hudDragConnections) do
                pcall(DragConnection.Disconnect, DragConnection)
            end
            Context.hudDragConnections = nil
        end
        if RT.Stats and RT.Stats.DeathConnections then
            for _, DeathConnection in ipairs(RT.Stats.DeathConnections) do
                pcall(DeathConnection.Disconnect, DeathConnection)
            end
        end
        if RT.WalkSpeedConnections then
            for _, SpeedConnection in ipairs(RT.WalkSpeedConnections) do
                pcall(SpeedConnection.Disconnect, SpeedConnection)
            end
            RT.WalkSpeedConnections = nil
        end
        if HudGui then
            pcall(HudGui.Destroy, HudGui)
            HudGui = nil
            HudPanel = nil
            HudLabels = nil
            Context.hudGui = nil
            Context.hudLabels = nil
            Context.refreshHUD = nil
        end
        if ToggleGui then
            pcall(ToggleGui.Destroy, ToggleGui)
            ToggleGui = nil
            ToggleButton = nil
            PowerButton = nil
            PerfButton = nil
            BlackButton = nil
            ResetButton = nil
            Context.toggleButton = nil
            Context.controlButtons = nil
        end
        if BlackGui then
            pcall(BlackGui.Destroy, BlackGui)
            BlackGui = nil
            Context.blackGui = nil
        end
        if RunService and RunService.Set3dRenderingEnabled then
            pcall(RunService.Set3dRenderingEnabled, RunService, true)
        end
    end

    if Context.log then
        Context.log("Headless", "started from " .. tostring(Context.SWANGY_CONFIG_PATH))
    end
end