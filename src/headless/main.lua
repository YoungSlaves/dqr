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
            if Context.restoreWalkSpeed then
                pcall(Context.restoreWalkSpeed, Humanoid)
            end
            pcall(function()
                Humanoid:Move(Vector3.zero, false)
            end)
            if Humanoid.WalkSpeed <= 0 then
                Humanoid.WalkSpeed = 16
            end
            Humanoid.AutoRotate = true
        end
        if Context.MV then
            Context.MV.driving = false
            Context.MV.controlsOff = false
            Context.MV.controlsAt = 0
            Context.MV.cmdDir = nil
        end
    end

    local ToggleButton, ToggleGui
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
        if ToggleButton and ToggleButton.Parent then
            ToggleButton.Text = Enabled and "SWANGY: ON" or "SWANGY: OFF"
            ToggleButton.BackgroundColor3 = Enabled and Color3.fromRGB(26, 118, 78) or Color3.fromRGB(118, 42, 48)
        end
        if Save and Context.saveSwangyConfig then
            pcall(Context.saveSwangyConfig)
        end
    end

    local function BuildToggle()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then
            return
        end
        local Existing = PlayerGui:FindFirstChild("SwangyToggle")
        if Existing then
            Existing:Destroy()
        end
        ToggleGui = Instance.new("ScreenGui")
        ToggleGui.Name = "SwangyToggle"
        ToggleGui.ResetOnSpawn = false
        ToggleGui.IgnoreGuiInset = false
        ToggleGui.DisplayOrder = 500
        ToggleGui.Parent = PlayerGui

        ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "Power"
        ToggleButton.AnchorPoint = Vector2.new(1, 0)
        ToggleButton.Position = UDim2.new(1, -14, 0, 14)
        local SavedPosition = (Context.SWANGY.Automation or {}).ButtonPosition
        if type(SavedPosition) == "table" and tonumber(SavedPosition.X) and tonumber(SavedPosition.Y) then
            ToggleButton.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Position = UDim2.fromOffset(SavedPosition.X, SavedPosition.Y)
        end
        ToggleButton.Size = UDim2.fromOffset(138, 34)
        ToggleButton.BackgroundColor3 = Context.headlessEnabled and Color3.fromRGB(26, 118, 78) or Color3.fromRGB(118, 42, 48)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Text = Context.headlessEnabled and "SWANGY: ON" or "SWANGY: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(234, 247, 255)
        ToggleButton.TextSize = 13
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.AutoButtonColor = true
        ToggleButton.Parent = ToggleGui

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = ToggleButton
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(117, 242, 199)
        Stroke.Thickness = 1
        Stroke.Transparency = 0.35
        Stroke.Parent = ToggleButton

        local ArmedAt, LastToggle = os.clock() + 0.5, 0
        local function OnToggle()
            local Now = os.clock()
            if Now < ArmedAt or Now < (RT.SuppressToggleUntil or 0) or Now - LastToggle < 0.35 then
                return
            end
            LastToggle = Now
            SetEnabled(not Context.headlessEnabled, true)
        end
        ToggleButton.MouseButton1Click:Connect(OnToggle)
        ToggleButton.TouchTap:Connect(OnToggle)

        local UserInputService = game:GetService("UserInputService")
        local StartPosition, StartInput, Dragging, Moved
        local function BeginDrag(Input)
            if
                Input.UserInputType ~= Enum.UserInputType.MouseButton1
                and Input.UserInputType ~= Enum.UserInputType.Touch
            then
                return
            end
            Dragging, Moved = true, false
            StartPosition, StartInput = ToggleButton.AbsolutePosition, Input.Position
        end
        local function MoveDrag(Input)
            if not Dragging then
                return
            end
            local Delta = Input.Position - StartInput
            if Delta.Magnitude > 3 then
                Moved = true
            end
            local Camera = workspace.CurrentCamera
            local Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
            local Size = ToggleButton.AbsoluteSize
            ToggleButton.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Position = UDim2.fromOffset(
                math.clamp(StartPosition.X + Delta.X, 0, math.max(Viewport.X - Size.X, 0)),
                math.clamp(StartPosition.Y + Delta.Y, 0, math.max(Viewport.Y - Size.Y, 0))
            )
        end
        local function EndDrag()
            if not Dragging then
                return
            end
            Dragging = false
            if not Moved then
                return
            end
            RT.SuppressToggleUntil = os.clock() + 0.5
            Context.SWANGY.Automation = Context.SWANGY.Automation or {}
            Context.SWANGY.Automation.ButtonPosition = {
                X = ToggleButton.Position.X.Offset,
                Y = ToggleButton.Position.Y.Offset,
            }
            if Context.saveSwangyConfig then
                pcall(Context.saveSwangyConfig)
            end
        end
        Context.toggleDragConnections = {
            ToggleButton.InputBegan:Connect(BeginDrag),
            UserInputService.InputChanged:Connect(MoveDrag),
            UserInputService.InputEnded:Connect(EndDrag),
        }
        Context.toggleGui = ToggleGui
        Context.toggleButton = ToggleButton
    end

    local HudGui, HudLabels
    local function BuildHUD()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then
            return
        end
        local Existing = PlayerGui:FindFirstChild("SwangyHUD")
        if Existing then
            Existing:Destroy()
        end
        HudGui = Instance.new("ScreenGui")
        HudGui.Name = "SwangyHUD"
        HudGui.ResetOnSpawn = false
        HudGui.IgnoreGuiInset = false
        HudGui.DisplayOrder = 499
        HudGui.Parent = PlayerGui

        local Panel = Instance.new("Frame")
        Panel.Name = "Stats"
        Panel.AnchorPoint = Vector2.new(1, 0)
        Panel.Position = UDim2.new(1, -14, 0, 58)
        Panel.Size = UDim2.fromOffset(164, 156)
        Panel.BackgroundColor3 = Color3.fromRGB(9, 17, 22)
        Panel.BackgroundTransparency = 0.18
        Panel.BorderSizePixel = 0
        Panel.Active = false
        Panel.Parent = HudGui
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Panel
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(117, 242, 199)
        Stroke.Thickness = 1
        Stroke.Transparency = 0.55
        Stroke.Parent = Panel

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.fromOffset(10, 7)
        Title.Size = UDim2.new(1, -20, 0, 18)
        Title.Text = "SWANGY STATS"
        Title.TextColor3 = Color3.fromRGB(117, 242, 199)
        Title.TextSize = 12
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Panel

        HudLabels = {}
        local Rows = { "FPS", "RUNS", "DEATHS", "KILLS", "WINS", "LOSSES" }
        for Index, Name in ipairs(Rows) do
            local Label = Instance.new("TextLabel")
            Label.Name = Name
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.fromOffset(10, 27 + (Index - 1) * 19)
            Label.Size = UDim2.new(1, -20, 0, 17)
            Label.Text = Name .. "   0"
            Label.TextColor3 = Name == "FPS" and Color3.fromRGB(117, 242, 199)
                or Color3.fromRGB(226, 238, 246)
            Label.TextSize = 12
            Label.Font = Enum.Font.Code
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Panel
            HudLabels[Name] = Label
        end

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

        Context.hudConnections = { RenderConnection, CharacterConnection }
        Context.hudGui = HudGui
        Context.hudLabels = HudLabels
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
                HudLabels.FPS.Text = ("FPS      %d"):format(Fps)
                HudLabels.RUNS.Text = ("RUNS     %d"):format(Stats.Runs)
                HudLabels.DEATHS.Text = ("DEATHS   %d"):format(Stats.Deaths)
                HudLabels.KILLS.Text = ("KILLS    %d"):format(Stats.Kills)
                HudLabels.WINS.Text = ("WINS     %d"):format(Stats.Wins)
                HudLabels.LOSSES.Text = ("LOSSES   %d"):format(Stats.Losses)
            end
        end)
    end

    SetEnabled(not ManualOff and Automation.Enabled ~= false, false)
    BuildToggle()
    BuildHUD()

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
        if RT.Stats and RT.Stats.DeathConnections then
            for _, DeathConnection in ipairs(RT.Stats.DeathConnections) do
                pcall(DeathConnection.Disconnect, DeathConnection)
            end
        end
        if HudGui then
            pcall(HudGui.Destroy, HudGui)
            HudGui = nil
            Context.hudGui = nil
        end
        if ToggleGui then
            pcall(ToggleGui.Destroy, ToggleGui)
            ToggleGui = nil
            ToggleButton = nil
        end
    end

    if Context.log then
        Context.log("Headless", "started from " .. tostring(Context.SWANGY_CONFIG_PATH))
    end
end