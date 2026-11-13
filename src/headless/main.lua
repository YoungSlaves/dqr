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
        return (Humanoid and tonumber(Humanoid.WalkSpeed)) or 0
    end

    -- The script must not lock or overwrite WalkSpeed. These stubs keep the
    -- movement modules from taking speed control, while leaving the value the
    -- game or the player set exactly as it is.
    local function DisableWalkSpeedControl()
        Context.speedHoldTick = function() end
        Context.speedApply = function() end
        Context.speedCustomOn = function()
            return false
        end
        Context.speedNormal = CurrentWalkSpeed
        Context.speedBurst = CurrentWalkSpeed
        Context.walkNormal = function(Humanoid)
            return (Humanoid and Humanoid.WalkSpeed) or CurrentWalkSpeed()
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
        end
        if Context.MV then
            Context.MV.walkSpeed = nil
            Context.MV.walkSpeedBefore = nil
        end
    end
    DisableWalkSpeedControl()

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
    local ToggleGui, ToggleButton, PowerButton, PerfButton, BlackButton, SpoofButton, ResetButton
    local HudGui, HudPanel, HudLabels
    local BlackGui, SpoofGui, SpoofPanel, SpoofToggle
    local HatModel, HatConnection
    local SpoofFields = {}
    local SpoofOriginals = {}
    local SpoofFakes = {}
    local SpoofAssets = {}

    -- ------------------------------------------------------------------ look
    -- Shared skin for the control rail, stats strip, spoofer and blackout.
    -- Tokens come from ui/theme.lua (palette, button states, hud metrics, fonts).
    -- The fallback only keeps this file working if the theme has not run yet.
    local TweenService = game:GetService("TweenService")
    local Theme = Context.Theme
    local Look
    do
        if Theme and Theme.palette and Theme.states and Theme.hud then
            Look = {
                palette = Theme.palette,
                states = Theme.states,
                radius = Theme.hud.radius,
                size = Theme.hud.size,
                quick = Theme.hud.quick,
                press = Theme.hud.press,
            }
        else
            local function Hex(Value)
                return Color3.fromHex(Value)
            end
            local P = {
                DeepForest = Hex("0d1210"),
                Moss = Hex("17211b"),
                Fern = Hex("748b71"),
                LeafLight = Hex("a6b79a"),
                Bark = Hex("4a3d31"),
                Wood = Hex("26221c"),
                Parchment = Hex("e7dfcb"),
                Firefly = Hex("c7ad76"),
                Hot = Hex("a35f52"),
                Muted = Hex("8d897b"),
            }
            local function Tone(Color, Text, Amount)
                return {
                    fill = Color:Lerp(P.DeepForest, Amount),
                    hover = Color:Lerp(P.DeepForest, Amount - 0.12),
                    text = Text,
                    line = Color:Lerp(P.DeepForest, 0.4),
                    dot = Color,
                }
            end
            Look = {
                palette = P,
                states = {
                    off = {
                        fill = P.Moss,
                        hover = P.Moss:Lerp(P.Bark, 0.45),
                        text = P.Muted,
                        line = P.Bark,
                        dot = P.Muted:Lerp(P.DeepForest, 0.45),
                    },
                    leaf = Tone(P.Fern, P.LeafLight, 0.72),
                    warm = Tone(P.Firefly, P.Firefly, 0.8),
                    ember = Tone(P.Hot, P.Hot:Lerp(P.Parchment, 0.4), 0.72),
                    parch = Tone(P.Parchment, P.Parchment, 0.88),
                    reset = {
                        fill = P.Moss,
                        hover = P.Moss:Lerp(P.Hot, 0.2),
                        text = P.Hot:Lerp(P.Parchment, 0.3),
                        line = P.Hot:Lerp(P.Bark, 0.55),
                        dot = P.Hot,
                    },
                },
                radius = { panel = 10, button = 6, field = 4, tag = 3, pill = 999 },
                size = { button = 12, stat = 12, brand = 14, title = 15, field = 12, caption = 11 },
                quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                press = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            }
        end
    end

    local function Face(Object, Role)
        if Theme and Theme.applyFont then
            Theme.applyFont(Object, Role)
        else
            Object.Font = Role == "ledger" and Enum.Font.Garamond or Enum.Font.SourceSans
        end
    end

    local function Round(Object, Radius)
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, Radius)
        Corner.Parent = Object
        return Corner
    end

    -- Border mode is explicit: on a TextButton the default mode outlines the
    -- text instead of the box.
    local function Outline(Object, Color, Transparency)
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color
        Stroke.Thickness = 1
        Stroke.Transparency = Transparency or 0
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Parent = Object
        return Stroke
    end

    local function Inset(Object, Top, Right, Bottom, Left)
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, Top)
        Padding.PaddingRight = UDim.new(0, Right)
        Padding.PaddingBottom = UDim.new(0, Bottom)
        Padding.PaddingLeft = UDim.new(0, Left)
        Padding.Parent = Object
        return Padding
    end

    local function Paint(Button, Instant)
        if not (Button and Button.Parent) then
            return
        end
        local State = Look.states[Button:GetAttribute("State") or "off"] or Look.states.off
        local Fill = Button:GetAttribute("Hover") == true and State.hover or State.fill
        local Stroke = Button:FindFirstChildOfClass("UIStroke")
        local Dot = Button:FindFirstChild("Dot")
        if Instant then
            Button.BackgroundColor3 = Fill
            Button.TextColor3 = State.text
        else
            TweenService:Create(Button, Look.quick, { BackgroundColor3 = Fill, TextColor3 = State.text }):Play()
        end
        if Stroke then
            Stroke.Color = State.line
        end
        if Dot then
            Dot.BackgroundColor3 = State.dot
        end
    end

    local function SetButtonState(Button, StateName)
        if not (Button and Button.Parent) then
            return
        end
        Button:SetAttribute("State", StateName)
        Paint(Button)
    end

    -- One button for the rail and the spoofer. The dot is the on/off lamp, so
    -- state never depends on colour alone.
    local function MakeButton(Parent, Name, Text, Order, StateName, HasDot)
        local Button = Instance.new("TextButton")
        Button.Name = Name
        Button.LayoutOrder = Order
        Button.AutomaticSize = Enum.AutomaticSize.X
        Button.Size = UDim2.new(0, 0, 1, 0)
        Button.BorderSizePixel = 0
        Button.Text = Text
        Button.TextSize = Look.size.button
        Button.TextWrapped = false
        Button.Active = true
        Button.AutoButtonColor = false
        Face(Button, "hud")
        Round(Button, Look.radius.button)
        Outline(Button, Look.states.off.line)
        Inset(Button, 0, 11, 0, HasDot and 23 or 11)
        local Scale = Instance.new("UIScale")
        Scale.Parent = Button
        if HasDot then
            local Dot = Instance.new("Frame")
            Dot.Name = "Dot"
            Dot.AnchorPoint = Vector2.new(0, 0.5)
            Dot.Position = UDim2.new(0, -14, 0.5, 0)
            Dot.Size = UDim2.fromOffset(6, 6)
            Dot.BorderSizePixel = 0
            Round(Dot, Look.radius.pill)
            Dot.Parent = Button
        end
        Button:SetAttribute("State", StateName)
        Button.Parent = Parent
        Paint(Button, true)
        Button.MouseEnter:Connect(function()
            Button:SetAttribute("Hover", true)
            Paint(Button)
        end)
        Button.MouseLeave:Connect(function()
            Button:SetAttribute("Hover", false)
            Paint(Button)
            TweenService:Create(Scale, Look.press, { Scale = 1 }):Play()
        end)
        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Scale, Look.press, { Scale = 0.95 }):Play()
        end)
        Button.MouseButton1Up:Connect(function()
            TweenService:Create(Scale, Look.press, { Scale = 1 }):Play()
        end)
        return Button
    end

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
            if not Moved then
                if Delta.Magnitude <= 8 then
                    return
                end
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
    local function SpoofSettings()
        Context.SWANGY.Universal = Context.SWANGY.Universal or {}
        Context.SWANGY.Universal.Spoofer = Context.SWANGY.Universal.Spoofer or {}
        return Context.SWANGY.Universal.Spoofer
    end

    local function SpoofTarget()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")
        local Status = PlayerGui and PlayerGui:FindFirstChild("playerStatus")
        return Status and Status:FindFirstChild("Frame")
    end

    local function RestoreSpoof()
        for Object, Properties in pairs(SpoofOriginals) do
            if Object.Parent then
                for Property, Record in pairs(Properties) do
                    pcall(function()
                        Object[Property] = Record.Value
                    end)
                end
            end
        end
        SpoofOriginals = {}
        for _, Fake in pairs(SpoofFakes) do
            if Fake and Fake.Parent then
                pcall(Fake.Destroy, Fake)
            end
        end
        SpoofFakes = {}
    end

    local function SetSpoof(Object, Property, Value)
        if not Object then
            return
        end
        local Properties = SpoofOriginals[Object]
        if not Properties then
            Properties = {}
            SpoofOriginals[Object] = Properties
        end
        local Record = Properties[Property]
        if not Record then
            Record = { Value = Object[Property] }
            Properties[Property] = Record
        end
        if Value ~= nil and tostring(Value) ~= "" then
            pcall(function()
                Object[Property] = Value
            end)
        else
            pcall(function()
                Object[Property] = Record.Value
            end)
        end
    end

    local function SpoofText(Object, Text)
        if not Object then
            return
        end
        Text = tostring(Text or "")
        local Fake = SpoofFakes[Object]
        if Fake and not Fake.Parent then
            Fake = nil
            SpoofFakes[Object] = nil
        end
        if Text == "" then
            if Fake then
                Fake.Visible = false
            end
            SetSpoof(Object, "Visible", false)
            return
        end
        SetSpoof(Object, "TextTransparency", 1)
        SetSpoof(Object, "TextStrokeTransparency", 1)
        if not Fake then
            local Ok, Clone = pcall(Object.Clone, Object)
            if not Ok or not Clone then
                return
            end
            for _, Child in ipairs(Clone:GetChildren()) do
                if
                    not Child:IsA("UIStroke")
                    and not Child:IsA("UICorner")
                    and not Child:IsA("UIGradient")
                    and not Child:IsA("UITextSizeConstraint")
                    and not Child:IsA("UIPadding")
                then
                    Child:Destroy()
                end
            end
            Clone.Name = "streamerFake"
            Clone.TextTransparency = 0
            Clone.TextStrokeTransparency = Object.TextStrokeTransparency
            Clone.Visible = true
            Clone.ZIndex = Object.ZIndex + 1
            Clone.Parent = Object.Parent
            SpoofFakes[Object] = Clone
            Fake = Clone
        end
        Fake.Visible = true
        if Fake.Text ~= Text then
            Fake.Text = Text
        end
    end

    local function SpoofImage(Value)
        if type(Value) ~= "string" then
            return nil
        end
        local Raw = Value:match("^%s*(.-)%s*$")
        if Raw == "" then
            return nil
        end
        if Raw:match("^rbxassetid://") or Raw:match("^https?://") then
            return Raw
        end
        if Raw:match("^%d+$") then
            return "rbxassetid://" .. Raw
        end
        if type(isfile) ~= "function" or type(getcustomasset) ~= "function" then
            return nil
        end
        local Images = (Context.PATH and Context.PATH.images)
            or (Context.SWANGY_PATHS and Context.SWANGY_PATHS.Images)
            or "swangy/images"
        local CacheKey = Images .. "|" .. Raw
        if SpoofAssets[CacheKey] then
            return SpoofAssets[CacheKey]
        end
        local Candidates, Seen = {}, {}
        local function Add(Path)
            Path = tostring(Path):gsub("\\", "/")
            if Path ~= "" and not Seen[Path] then
                Seen[Path] = true
                Candidates[#Candidates + 1] = Path
            end
        end
        local Base = Raw:gsub("\\", "/")
        local Prefix = Images .. "/"
        if Base:sub(1, #Prefix):lower() == Prefix:lower() then
            Add(Base)
        elseif Base:sub(1, 7):lower() == "images/" then
            Add(Images .. "/" .. Base:sub(8))
        elseif Base:find("/", 1, true) then
            Add(Base)
        else
            Add(Images .. "/" .. Base)
        end
        if not Base:match("%.([%w]+)$") then
            local Count = #Candidates
            for Index = 1, Count do
                local Path = Candidates[Index]
                Add(Path .. ".png")
                Add(Path .. ".jpg")
                Add(Path .. ".jpeg")
                Add(Path .. ".webp")
            end
        end
        for _, Path in ipairs(Candidates) do
            local Exists = select(2, pcall(isfile, Path))
            if Exists then
                local Ok, Asset = pcall(getcustomasset, Path)
                if Ok and Asset then
                    SpoofAssets[CacheKey] = Asset
                    return Asset
                end
            end
        end
        if type(listfiles) == "function" then
            local Ok, Files = pcall(listfiles, Images)
            if Ok and type(Files) == "table" then
                local Wanted = Base:lower()
                for _, File in ipairs(Files) do
                    local Name = tostring(File):gsub("\\", "/"):match("([^/]+)$")
                    if Name and Name:lower() == Wanted then
                        local AssetOk, Asset = pcall(getcustomasset, File)
                        if AssetOk and Asset then
                            SpoofAssets[CacheKey] = Asset
                            return Asset
                        end
                    end
                end
            end
        end
        return nil
    end

    -- A value of "*" is a sentinel for a blank text field. The original label
    -- is hidden as well, so a spoofed name never falls back to the real value.
    local function SpoofValue(Value)
        local Text = tostring(Value or "")
        if Text:match("^%s*%*%s*$") then
            return ""
        end
        return Text
    end

    local function ApplySpoof()
        local Data = SpoofSettings()
        -- Toggling the spoofer off disables every fake label and restores the
        -- real local playerStatus values.
        if Data.Enabled ~= true then
            RestoreSpoof()
            return
        end
        local Frame = SpoofTarget()
        if not Frame then
            return
        end
        local function Find(...)
            local Object = Frame
            for _, Name in ipairs({ ... }) do
                if not Object then
                    return nil
                end
                Object = Object:FindFirstChild(Name)
            end
            return Object
        end
        SpoofText(Find("playerName"), SpoofValue(Data.Name))
        SpoofText(Find("levelBorder", "level"), SpoofValue(Data.Level))
        SpoofText(Find("moneyMain", "TextLabel"), SpoofValue(Data.Gold))
        SpoofText(Find("moneyMain", "GemsText"), SpoofValue(Data.Gems))
        SpoofText(Find("xpFrame", "xp"), SpoofValue(Data.EXP))
        SpoofText(Find("healthFrame", "health"), SpoofValue(Data.Health))
        local Portrait = Find("portraitBorder", "portrait")
        local Image = SpoofImage(tostring(Data.PFP or ""))
        SetSpoof(Portrait, "Image", Image)
        if Portrait then
            SetSpoof(Portrait, "ImageColor3", Image and Color3.new(1, 1, 1) or nil)
            SetSpoof(Portrait, "ScaleType", Image and Enum.ScaleType.Crop or nil)
        end

        -- The world-space nameplate is separate from the HUD playerStatus
        -- frame, so spoof it as well. VIP/title are hidden while spoofing to
        -- avoid showing the real identity beside the fake nameplate.
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local Character = Player and Player.Character
        local Plate = Character and Character:FindFirstChild("playerNameplate")
        local PlateFrame = Plate and Plate:FindFirstChild("Frame")
        if PlateFrame then
            SpoofText(PlateFrame:FindFirstChild("name"), SpoofValue(Data.Name))
            local HealthBackground = PlateFrame:FindFirstChild("healthBackground")
            SpoofText(
                HealthBackground and HealthBackground:FindFirstChild("healthAmount"),
                SpoofValue(Data.Health)
            )
            local PlateInner = PlateFrame:FindFirstChild("Frame")
            local FrameInner = PlateInner and PlateInner:FindFirstChild("frameInner")
            SpoofText(FrameInner and FrameInner:FindFirstChild("level"), SpoofValue(Data.Level))
            SetSpoof(PlateFrame:FindFirstChild("title"), "Visible", false)
            SetSpoof(PlateInner and PlateInner:FindFirstChild("vip"), "Visible", false)
        end
    end

    local function UpdateSpoofButton()
        local Enabled = SpoofSettings().Enabled == true
        if SpoofButton and SpoofButton.Parent then
            SetButtonState(SpoofButton, Enabled and "parch" or "off")
        end
        if SpoofToggle and SpoofToggle.Parent then
            SpoofToggle.Text = Enabled and "Spoof on" or "Spoof off"
            SetButtonState(SpoofToggle, Enabled and "parch" or "off")
        end
    end

    local function BuildSpoofPanel()
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")
        if not PlayerGui then
            return
        end
        local Existing = PlayerGui:FindFirstChild("SwangySpoof")
        if Existing then
            Existing:Destroy()
        end
        SpoofGui = Instance.new("ScreenGui")
        SpoofGui.Name = "SwangySpoof"
        SpoofGui.ResetOnSpawn = false
        SpoofGui.IgnoreGuiInset = false
        SpoofGui.DisplayOrder = 9003
        SpoofGui.Enabled = false
        SpoofGui.Parent = PlayerGui

        local Palette = Look.palette

        SpoofPanel = Instance.new("Frame")
        SpoofPanel.Name = "Panel"
        SpoofPanel.AnchorPoint = Vector2.new(0.5, 0.5)
        SpoofPanel.Position = UDim2.fromScale(0.5, 0.5)
        SpoofPanel.Size = UDim2.fromOffset(380, 330)
        SpoofPanel.BackgroundColor3 = Palette.Wood
        SpoofPanel.BackgroundTransparency = 0.03
        SpoofPanel.BorderSizePixel = 0
        SpoofPanel.Active = true
        SpoofPanel.Parent = SpoofGui
        Round(SpoofPanel, Look.radius.panel + 2)
        Outline(SpoofPanel, Palette.Bark)

        local Title = Instance.new("TextLabel")
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.fromOffset(16, 9)
        Title.Size = UDim2.new(1, -60, 0, 24)
        Title.Text = "Local spoofer"
        Title.TextColor3 = Palette.Parchment
        Title.TextSize = Look.size.title
        Face(Title, "ledger")
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = SpoofPanel

        local Divider = Instance.new("Frame")
        Divider.Name = "Divider"
        Divider.Position = UDim2.fromOffset(16, 40)
        Divider.Size = UDim2.new(1, -32, 0, 1)
        Divider.BackgroundColor3 = Palette.Bark
        Divider.BorderSizePixel = 0
        Divider.Parent = SpoofPanel

        local Close = Instance.new("TextButton")
        Close.Name = "Close"
        Close.AnchorPoint = Vector2.new(1, 0)
        Close.Position = UDim2.new(1, -10, 0, 9)
        Close.Size = UDim2.fromOffset(24, 24)
        Close.BackgroundColor3 = Palette.Moss
        Close.BackgroundTransparency = 1
        Close.BorderSizePixel = 0
        Close.AutoButtonColor = false
        Close.Text = "×"
        Close.TextColor3 = Palette.Muted
        Close.TextSize = 18
        Face(Close, "hud")
        Close.Parent = SpoofPanel
        Round(Close, Look.radius.pill)
        Close.MouseEnter:Connect(function()
            Close.BackgroundTransparency = 0
            Close.TextColor3 = Palette.Parchment
        end)
        Close.MouseLeave:Connect(function()
            Close.BackgroundTransparency = 1
            Close.TextColor3 = Palette.Muted
        end)
        Close.MouseButton1Click:Connect(function()
            if SpoofGui then
                SpoofGui.Enabled = false
            end
        end)

        local Rows = {
            { Key = "Name", Label = "Name", Placeholder = "Display name" },
            { Key = "PFP", Label = "Portrait", Placeholder = "filename in swangy/images" },
            { Key = "Level", Label = "Level", Placeholder = "Level" },
            { Key = "Gold", Label = "Gold", Placeholder = "Gold amount" },
            { Key = "Gems", Label = "Gems", Placeholder = "Gem amount" },
            { Key = "EXP", Label = "XP", Placeholder = "EXP display" },
            { Key = "Health", Label = "Health", Placeholder = "Health display" },
        }
        SpoofFields = {}
        for Index, Row in ipairs(Rows) do
            local Y = 52 + (Index - 1) * 32
            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.fromOffset(16, Y)
            Label.Size = UDim2.fromOffset(64, 24)
            Label.Text = Row.Label
            Label.TextColor3 = Palette.Muted
            Label.TextSize = Look.size.button
            Face(Label, "hud")
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SpoofPanel
            local Box = Instance.new("TextBox")
            Box.Name = Row.Key
            Box.Position = UDim2.fromOffset(88, Y)
            Box.Size = UDim2.fromOffset(276, 24)
            Box.BackgroundColor3 = Palette.DeepForest
            Box.BorderSizePixel = 0
            Box.Text = tostring(SpoofSettings()[Row.Key] or "")
            Box.PlaceholderText = Row.Placeholder
            Box.PlaceholderColor3 = Palette.Muted:Lerp(Palette.DeepForest, 0.4)
            Box.TextColor3 = Palette.Parchment
            Box.TextSize = Look.size.field
            Face(Box, "hud")
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = false
            Box.Parent = SpoofPanel
            Round(Box, Look.radius.field)
            Inset(Box, 0, 8, 0, 8)
            local BoxStroke = Outline(Box, Palette.Bark)
            Box.Focused:Connect(function()
                BoxStroke.Color = Palette.Firefly
            end)
            Box.FocusLost:Connect(function()
                BoxStroke.Color = Palette.Bark
                SpoofSettings()[Row.Key] = Box.Text
                SaveAutomation()
                ApplySpoof()
            end)
            SpoofFields[Row.Key] = Box
        end

        SpoofToggle = MakeButton(SpoofPanel, "Enabled", "Spoof off", 0, "off", true)
        SpoofToggle.AutomaticSize = Enum.AutomaticSize.None
        SpoofToggle.Position = UDim2.fromOffset(16, 286)
        SpoofToggle.Size = UDim2.fromOffset(120, 30)
        SpoofToggle.MouseButton1Click:Connect(function()
            local Data = SpoofSettings()
            Data.Enabled = not (Data.Enabled == true)
            SaveAutomation()
            UpdateSpoofButton()
            ApplySpoof()
        end)

        local Hint = Instance.new("TextLabel")
        Hint.Name = "Hint"
        Hint.BackgroundTransparency = 1
        Hint.Position = UDim2.fromOffset(150, 286)
        Hint.Size = UDim2.fromOffset(214, 30)
        Hint.Text = "Changes apply when you leave a field."
        Hint.TextColor3 = Palette.Muted
        Hint.TextSize = Look.size.caption
        Hint.TextWrapped = true
        Hint.TextXAlignment = Enum.TextXAlignment.Left
        Face(Hint, "hud")
        Hint.Parent = SpoofPanel

        UpdateSpoofButton()
        Context.spoofGui = SpoofGui
    end

    local function ToggleSpoofPanel()
        if not SpoofGui or not SpoofGui.Parent then
            BuildSpoofPanel()
        end
        if SpoofGui then
            SpoofGui.Enabled = not SpoofGui.Enabled
        end
    end

    task.spawn(function()
        while not RT.destroyed do
            task.wait(0.25)
            pcall(ApplySpoof)
        end
    end)

    -- A small local-only straw hat built from flat cylinders. It is welded to
    -- the head, uses no external asset, and never glows.
    local function RemoveChineseHat()
        if HatModel then
            pcall(HatModel.Destroy, HatModel)
            HatModel = nil
        end
    end

    local function BuildChineseHat(Character, Head)
        RemoveChineseHat()
        local Existing = Character:FindFirstChild("SwangyChineseHat")
        if Existing then
            Existing:Destroy()
        end
        local Hat = Instance.new("Model")
        Hat.Name = "SwangyChineseHat"

        -- Anchor the hat to the actual top of the head. R6 and R15 heads have
        -- different heights, so a fixed offset makes the brim float.
        local headTop = math.max(Head.Size.Y * 0.5, 0.35)
        local headWidth = math.max(Head.Size.X, Head.Size.Z)
        local brimY = headTop + 0.02
        local brimRadius = math.max(headWidth * 0.95 + 0.2, 1.6)

        local function Disc(Name, Y, Radius, Height, Color)
            local Part = Instance.new("Part")
            Part.Name = Name
            Part.Anchored = false
            Part.CanCollide = false
            Part.CanQuery = false
            Part.CanTouch = false
            Part.CastShadow = false
            Part.Massless = true
            Part.Material = Enum.Material.SmoothPlastic
            Part.Shape = Enum.PartType.Cylinder
            Part.Size = Vector3.new(Height, Radius * 2, Radius * 2)
            Part.Color = Color
            Part.CFrame = Head.CFrame * CFrame.new(0, Y, 0) * CFrame.Angles(0, 0, math.rad(90))
            Part.Parent = Hat
            local Weld = Instance.new("WeldConstraint")
            Weld.Part0 = Head
            Weld.Part1 = Part
            Weld.Parent = Part
            return Part
        end
        Disc("Brim", brimY, brimRadius, 0.1, Color3.fromRGB(166, 139, 94))
        Disc("Band", brimY + 0.08, brimRadius * 0.92, 0.1, Color3.fromRGB(119, 52, 45))
        for Index = 1, 7, 1 do
            local Radius = brimRadius * (0.84 - (Index - 1) * 0.1)
            Disc(
                "Cone" .. tostring(Index),
                brimY + 0.14 + (Index - 1) * 0.14,
                math.max(Radius, 0.3),
                0.14,
                Index % 2 == 0 and Color3.fromRGB(188, 160, 108) or Color3.fromRGB(156, 130, 88)
            )
        end
        Hat.Parent = Character
        HatModel = Hat
    end

    local function UpdateChineseHat()
        if CFG.chineseHat == false or RT.destroyed then
            RemoveChineseHat()
            return
        end
        local Player = Context.LocalPlayer or (Context.Players and Context.Players.LocalPlayer)
        local Character = Player and Player.Character
        local Head = Character and Character:FindFirstChild("Head")
        if not Head then
            RemoveChineseHat()
            return
        end
        if HatModel and HatModel.Parent == Character then
            return
        end
        BuildChineseHat(Character, Head)
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
            PowerButton.Text = Enabled and "ON" or "OFF"
            SetButtonState(PowerButton, Enabled and "leaf" or "off")
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
        PerfButton.Text = "Performance"
        SetButtonState(PerfButton, Enabled and "warm" or "off")
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
        BlackGui.DisplayOrder = 9000
        BlackGui.Enabled = RT.BlackScreen == true
        local Shade = Instance.new("Frame")
        Shade.Name = "Shade"
        Shade.BackgroundColor3 = Look.palette.DeepForest
        Shade.BackgroundTransparency = 0
        Shade.BorderSizePixel = 0
        Shade.Active = false
        Shade.Size = UDim2.fromScale(1, 1)
        Shade.Parent = BlackGui

        -- A quiet note in the corner so a dark screen reads as "paused", not
        -- "crashed". It never takes input.
        local Note = Instance.new("Frame")
        Note.Name = "Note"
        Note.AnchorPoint = Vector2.new(0, 1)
        Note.Position = UDim2.new(0, 28, 1, -28)
        Note.Size = UDim2.fromOffset(340, 0)
        Note.AutomaticSize = Enum.AutomaticSize.Y
        Note.BackgroundTransparency = 1
        Note.Active = false
        Note.Parent = Shade
        local NoteLayout = Instance.new("UIListLayout")
        NoteLayout.SortOrder = Enum.SortOrder.LayoutOrder
        NoteLayout.Padding = UDim.new(0, 4)
        NoteLayout.Parent = Note

        local Heading = Instance.new("TextLabel")
        Heading.Name = "Heading"
        Heading.LayoutOrder = 1
        Heading.BackgroundTransparency = 1
        Heading.AutomaticSize = Enum.AutomaticSize.Y
        Heading.Size = UDim2.new(1, 0, 0, 0)
        Heading.Text = "3D view is off"
        Heading.TextColor3 = Look.palette.Parchment:Lerp(Look.palette.DeepForest, 0.35)
        Heading.TextSize = 18
        Heading.TextWrapped = true
        Heading.TextXAlignment = Enum.TextXAlignment.Left
        Face(Heading, "ledger")
        Heading.Parent = Note

        local Detail = Instance.new("TextLabel")
        Detail.Name = "Detail"
        Detail.LayoutOrder = 2
        Detail.BackgroundTransparency = 1
        Detail.AutomaticSize = Enum.AutomaticSize.Y
        Detail.Size = UDim2.new(1, 0, 0, 0)
        Detail.Text = "Rendering is paused to save GPU. Switch GPU rendering back on from the control bar."
        Detail.TextColor3 = Look.palette.Muted:Lerp(Look.palette.DeepForest, 0.3)
        Detail.TextSize = 13
        Detail.TextWrapped = true
        Detail.TextXAlignment = Enum.TextXAlignment.Left
        Face(Detail, "hud")
        Detail.Parent = Note

        BlackGui.Parent = PlayerGui
        Context.blackGui = BlackGui
    end

    local function UpdateBlackButton()
        if not (BlackButton and BlackButton.Parent) then
            return
        end
        local Enabled = RT.BlackScreen == true
        BlackButton.Text = "GPU rendering"
        SetButtonState(BlackButton, Enabled and "ember" or "off")
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
        ToggleGui.DisplayOrder = 9002
        ToggleGui.Parent = PlayerGui

        local Palette = Look.palette

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
        Rail.AutomaticSize = Enum.AutomaticSize.X
        Rail.Size = UDim2.fromOffset(0, 40)
        Rail.BackgroundColor3 = Palette.Wood
        Rail.BackgroundTransparency = 0.06
        Rail.BorderSizePixel = 0
        Rail.Parent = ToggleGui
        Round(Rail, Look.radius.panel)
        Outline(Rail, Palette.Bark)
        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 5)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Rail
        Inset(Rail, 5, 5, 5, 4)

        -- Drag handle: a 2x3 block of studs instead of a text glyph.
        local Grip = Instance.new("TextButton")
        Grip.Name = "Grip"
        Grip.LayoutOrder = 0
        Grip.Size = UDim2.new(0, 16, 1, 0)
        Grip.BackgroundTransparency = 1
        Grip.BorderSizePixel = 0
        Grip.Text = ""
        Grip.Active = true
        Grip.AutoButtonColor = false
        Grip.Parent = Rail
        for Column = -1, 1, 2 do
            for Row = -1, 1 do
                local Stud = Instance.new("Frame")
                Stud.AnchorPoint = Vector2.new(0.5, 0.5)
                Stud.Position = UDim2.new(0.5, Column * 3, 0.5, Row * 6)
                Stud.Size = UDim2.fromOffset(3, 3)
                Stud.BackgroundColor3 = Palette.Bark:Lerp(Palette.Muted, 0.45)
                Stud.BorderSizePixel = 0
                Round(Stud, Look.radius.pill)
                Stud.Parent = Grip
            end
        end

        PowerButton = MakeButton(Rail, "Power", "ON", 1, "off", true)
        PerfButton = MakeButton(Rail, "Performance", "Performance", 2, "off", true)
        BlackButton = MakeButton(Rail, "GPU", "GPU rendering", 3, "off", true)
        SpoofButton = MakeButton(Rail, "Spoof", "Spoof", 4, "off", true)
        ResetButton = MakeButton(Rail, "ResetStats", "Reset stats", 5, "reset", false)
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
        Bind(SpoofButton, function()
            ToggleSpoofPanel()
        end)
        Bind(ResetButton, function()
            ResetStats()
        end)

        Context.toggleDragConnections = {}
        AddDrag(Grip, Rail, "ControlPosition", Context.toggleDragConnections)
        SetPerformance(CFG.performanceMode ~= false, false)
        PowerButton.Text = Context.headlessEnabled and "ON" or "OFF"
        SetButtonState(PowerButton, Context.headlessEnabled and "leaf" or "off")
        UpdateBlackButton()
        UpdateSpoofButton()
        Context.toggleGui = ToggleGui
        Context.toggleButton = PowerButton
        Context.controlRail = Rail
        Context.controlButtons = { PowerButton, PerfButton, BlackButton, SpoofButton, ResetButton }
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
        HudGui.DisplayOrder = 9001
        HudGui.Parent = PlayerGui

        local Palette = Look.palette

        HudPanel = Instance.new("Frame")
        HudPanel.Name = "Stats"
        HudPanel.AnchorPoint = Vector2.new(1, 0)
        HudPanel.Position = UDim2.new(1, -14, 0, 14)
        local SavedPosition = (Context.SWANGY.Automation or {}).HudPosition
        if type(SavedPosition) == "table" and tonumber(SavedPosition.X) and tonumber(SavedPosition.Y) then
            HudPanel.AnchorPoint = Vector2.new(0, 0)
            HudPanel.Position = UDim2.fromOffset(SavedPosition.X, SavedPosition.Y)
        end
        HudPanel.AutomaticSize = Enum.AutomaticSize.X
        HudPanel.Size = UDim2.fromOffset(0, 36)
        HudPanel.BackgroundColor3 = Palette.Wood
        HudPanel.BackgroundTransparency = 0.06
        HudPanel.BorderSizePixel = 0
        HudPanel.Active = true
        HudPanel.Parent = HudGui
        Round(HudPanel, Look.radius.panel)
        Outline(HudPanel, Palette.Bark)

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 10)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = HudPanel
        Inset(HudPanel, 4, 12, 4, 12)

        -- Name tag, set a couple of degrees off level like a hung sign.
        local Brand = Instance.new("TextLabel")
        Brand.Name = "Brand"
        Brand.BackgroundTransparency = 1
        Brand.AutomaticSize = Enum.AutomaticSize.X
        Brand.Size = UDim2.new(0, 0, 1, 0)
        Brand.Text = "Swangy"
        Brand.TextColor3 = Palette.Firefly
        Brand.TextSize = Look.size.brand
        Brand.Rotation = -2
        Face(Brand, "ledger")
        Brand.TextXAlignment = Enum.TextXAlignment.Left
        Brand.LayoutOrder = 1
        Brand.Parent = HudPanel

        local LiveState = Look.states.leaf
        local Badge = Instance.new("Frame")
        Badge.Name = "Badge"
        Badge.AutomaticSize = Enum.AutomaticSize.X
        Badge.Size = UDim2.fromOffset(0, 20)
        Badge.BackgroundColor3 = LiveState.fill
        Badge.BorderSizePixel = 0
        Badge.LayoutOrder = 2
        Badge.Parent = HudPanel
        Round(Badge, Look.radius.pill)
        Outline(Badge, LiveState.line)
        local BadgeLayout = Instance.new("UIListLayout")
        BadgeLayout.FillDirection = Enum.FillDirection.Horizontal
        BadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        BadgeLayout.Padding = UDim.new(0, 5)
        BadgeLayout.SortOrder = Enum.SortOrder.LayoutOrder
        BadgeLayout.Parent = Badge
        Inset(Badge, 0, 9, 0, 8)
        local BadgeDot = Instance.new("Frame")
        BadgeDot.Name = "Dot"
        BadgeDot.LayoutOrder = 1
        BadgeDot.Size = UDim2.fromOffset(5, 5)
        BadgeDot.BackgroundColor3 = LiveState.dot
        BadgeDot.BorderSizePixel = 0
        Round(BadgeDot, Look.radius.pill)
        BadgeDot.Parent = Badge
        local BadgeText = Instance.new("TextLabel")
        BadgeText.BackgroundTransparency = 1
        BadgeText.AutomaticSize = Enum.AutomaticSize.X
        BadgeText.Size = UDim2.new(0, 0, 1, 0)
        BadgeText.LayoutOrder = 2
        BadgeText.Text = "live"
        BadgeText.TextColor3 = LiveState.text
        BadgeText.TextSize = Look.size.caption
        Face(BadgeText, "hud")
        BadgeText.Parent = Badge

        local function AddSeparator(Order)
            local Separator = Instance.new("Frame")
            Separator.Name = "Separator"
            Separator.Size = UDim2.fromOffset(1, 14)
            Separator.BackgroundColor3 = Palette.Bark
            Separator.BorderSizePixel = 0
            Separator.LayoutOrder = Order
            Separator.Parent = HudPanel
        end

        -- Labels keep their original keys (Context.hudLabels.RUNS etc.); only
        -- the text shown to the player changes.
        local StatTitle = {
            FPS = "FPS",
            RUNS = "Runs",
            DEATHS = "Deaths",
            KILLS = "Kills",
            WINS = "Wins",
            LOSSES = "Losses",
        }
        local MutedHex, InkHex = Palette.Muted:ToHex(), Palette.Parchment:ToHex()
        local GoodHex, BadHex = Palette.LeafLight:ToHex(), Look.states.ember.text:ToHex()
        local function StatText(Name, Value, Tone)
            return ('<font color="#%s">%s</font>  <font color="#%s">%s</font>'):format(
                MutedHex,
                StatTitle[Name] or Name,
                Tone or InkHex,
                tostring(Value)
            )
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
            Label.TextColor3 = Palette.Parchment
            Label.Text = StatText(Name, 0)
            Label.TextSize = Look.size.stat
            Face(Label, "hud")
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
            local function Count(Value)
                return tonumber(Value) or 0
            end
            HudLabels.FPS.Text = StatText("FPS", Fps)
            HudLabels.RUNS.Text = StatText("RUNS", Stats.Runs)
            HudLabels.DEATHS.Text = StatText("DEATHS", Stats.Deaths, Count(Stats.Deaths) > 0 and BadHex or nil)
            HudLabels.KILLS.Text = StatText("KILLS", Stats.Kills)
            HudLabels.WINS.Text = StatText("WINS", Stats.Wins, Count(Stats.Wins) > 0 and GoodHex or nil)
            HudLabels.LOSSES.Text = StatText("LOSSES", Stats.Losses, Count(Stats.Losses) > 0 and BadHex or nil)
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
    UpdateChineseHat()
    HatConnection = RunService.Heartbeat:Connect(function()
        if RT.destroyed or os.clock() - (RT.hatAt or 0) < 0.5 then
            return
        end
        RT.hatAt = os.clock()
        pcall(UpdateChineseHat)
    end)
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
        RestoreSpoof()
        RemoveChineseHat()
        if HatConnection then
            pcall(HatConnection.Disconnect, HatConnection)
            HatConnection = nil
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
            SpoofButton = nil
            ResetButton = nil
            Context.toggleButton = nil
            Context.controlButtons = nil
        end
        if BlackGui then
            pcall(BlackGui.Destroy, BlackGui)
            BlackGui = nil
            Context.blackGui = nil
        end
        if SpoofGui then
            pcall(SpoofGui.Destroy, SpoofGui)
            SpoofGui = nil
            SpoofPanel = nil
            SpoofToggle = nil
            SpoofFields = {}
            SpoofAssets = {}
            Context.spoofGui = nil
        end
        if RunService and RunService.Set3dRenderingEnabled then
            pcall(RunService.Set3dRenderingEnabled, RunService, true)
        end
    end

    if Context.log then
        Context.log("Headless", "started from " .. tostring(Context.SWANGY_CONFIG_PATH))
    end
end