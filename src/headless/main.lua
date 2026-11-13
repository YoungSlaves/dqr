return function(Context)
    local CFG = Context.CFG
    local RT = Context.RT or {}
    Context.SWANGY = Context.SWANGY or {}
    local Settings = Context.SWANGY
    local Automation = Settings.Automation or {}
    Context.RT = RT
    RT.destroyed = false
    RT.modHalt = false
    RT.farmEnabled = Automation.Enabled ~= false
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

    local ToggleButton, ToggleGui
    local function SetEnabled(Enabled, Save)
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
        end
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
        ToggleGui.IgnoreGuiInset = true
        ToggleGui.DisplayOrder = 500
        ToggleGui.Parent = PlayerGui

        ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "Power"
        ToggleButton.AnchorPoint = Vector2.new(1, 0)
        ToggleButton.Position = UDim2.new(1, -14, 0, 14)
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

        ToggleButton.Activated:Connect(function()
            SetEnabled(not Context.headlessEnabled, true)
        end)
        Context.toggleGui = ToggleGui
        Context.toggleButton = ToggleButton
    end

    SetEnabled(Automation.Enabled ~= false, false)
    BuildToggle()

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