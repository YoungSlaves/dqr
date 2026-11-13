return function(Context)
    local HttpService = Context.HttpService
    local Paths = {
        Root = "swangy",
        Configs = "swangy/config",
        Images = "swangy/images",
        Logs = "swangy/logs",
        Data = "swangy/data",
    }
    local ConfigPath = Paths.Configs .. "/config.json"

    local Defaults = {
        LobbySettings = {
            GameCreation = {
                DungeonSettings = {
                    Dungeon = "Northern Lands",
                    AutoSelectHighest = true,
                    Hardcore = false,
                    BossRaidTeir = 1,
                    Difficulty = "Nightmare",
                    DoBonusBoss = false,
                },
                Multifarm = {
                    Enabled = false,
                    HostAccount = "",
                    LowestLevelIsHost = false,
                    JoinerAccounts = {},
                },
            },
            AutoEquip = { Enabled = false, Class = "" },
            AutoSkillpoints = { Class = "" },
            Autosell = {
                Enabled = false,
                KeepRarities = {},
                ItemLevelRequirement = "",
                PreviewAutosell = true,
                KeepTable = {},
            },
            AutoUpgrade = { Enabled = false, Class = "" },
            CharacterOptions = { HideNameTag = true },
        },
        GameSettings = {
            LimitSpellCasting = false,
            CustomMap = { Color = "#fc0313", Transparency = 0.25 },
            ReturnInventoryLimit = 9999,
            Optimizations = { DestroyGear = true, PerformanceMode = true },
            BossSettings = { CastingRange = 75, EnemyDistance = 55 },
            OrbitMobs = false,
            KillOnWave = 100000,
            CastBetweenEnemies = { Enabled = true, Range = 40 },
            DisableDodging = false,
            MobSettings = { CastingRange = 75, EnemyDistance = 50 },
        },
        Universal = {
            Webhook = {
                Enabled = false,
                RarityPing = {},
                ItemPing = {},
                HidePlayerName = false,
                DiscordUserID = "everyone",
                Url = "",
            },
            CustomUI = {
                Enabled = true,
                EXPField = "",
                Name = "Swangy",
                Level = "",
                Health = "",
                Image = "logo.png",
            },
            Spoofer = {
                Enabled = false,
                Name = "",
                PFP = "pfp.png",
                Level = "",
                Gold = "",
                Gems = "",
                EXP = "",
                Health = "",
            },
        },
        Automation = {
            Enabled = true,
            TickHz = 30,
            AutoAttack = true,
            AutoE = true,
            AutoQ = true,
            AutoStart = true,
            StartDelay = 1,
            AutoQueue = true,
            AutoQueueReplay = true,
            AutoFarmByPlace = true,
            Walls = true,
            BlackScreen = false,
        },
        Visuals = {
            DrawHazards = true,
            DrawPath = true,
            DrawSpots = true,
            DrawTarget = true,
            DrawAbility = true,
            DrawAoe = true,
            DrawScan = true,
            DrawGroups = true,
            DrawBubble = true,
            DrawLeads = true,
            DrawNoGo = true,
            DrawWaypoints = true,
            Labels = false,
            MarkerScale = 1,
            SpotRadius = 48,
            SpotStep = 8,
            SpotEvery = 0.35,
            SafeColor = "#3cdc78",
            SoonColor = "#ffdc28",
            DangerColor = "#ff3232",
            TargetColor = "#ffffff",
            AbilityColor = "#50c8ff",
        },
        Logging = { Debug = false, AutosaveSeconds = 10 },
    }

    local function Clone(Value)
        if type(Value) ~= "table" then
            return Value
        end
        local Result = {}
        for Key, Entry in pairs(Value) do
            Result[Key] = Clone(Entry)
        end
        return Result
    end

    local function Merge(Base, Override)
        local Result = Clone(Base)
        if type(Override) ~= "table" then
            return Result
        end
        for Key, Value in pairs(Override) do
            if type(Value) == "table" and type(Result[Key]) == "table" then
                Result[Key] = Merge(Result[Key], Value)
            else
                Result[Key] = Clone(Value)
            end
        end
        return Result
    end

    local function EnsureFolder(Path)
        if type(makefolder) ~= "function" then
            return
        end
        local Current = ""
        for Part in Path:gmatch("[^/]+") do
            Current = Current == "" and Part or Current .. "/" .. Part
            if type(isfolder) == "function" then
                local Ok, Exists = pcall(isfolder, Current)
                if not Ok or not Exists then
                    pcall(makefolder, Current)
                end
            else
                pcall(makefolder, Current)
            end
        end
    end

    local function WriteLog(Message)
        if type(appendfile) ~= "function" then
            return
        end
        pcall(appendfile, Paths.Logs .. "/boot.log", os.date("[%Y-%m-%d %H:%M:%S] ") .. Message .. "\n")
    end

    local function IsArray(Value)
        local Count = 0
        for Key in pairs(Value) do
            if type(Key) ~= "number" then
                return false
            end
            Count += 1
        end
        for Index = 1, Count do
            if Value[Index] == nil then
                return false
            end
        end
        return Count > 0
    end

    local function Encode(Value, Depth)
        local Kind = type(Value)
        if Kind == "string" or Kind == "number" or Kind == "boolean" then
            return HttpService:JSONEncode(Value)
        end
        if Kind ~= "table" then
            return "null"
        end
        local Indent = string.rep("    ", Depth + 1)
        local CloseIndent = string.rep("    ", Depth)
        if IsArray(Value) then
            local Items = {}
            for Index = 1, #Value do
                Items[Index] = Indent .. Encode(Value[Index], Depth + 1)
            end
            return "[\n" .. table.concat(Items, ",\n") .. "\n" .. CloseIndent .. "]"
        end
        local Keys = {}
        for Key in pairs(Value) do
            if type(Key) == "string" then
                Keys[#Keys + 1] = Key
            end
        end
        table.sort(Keys)
        local Items = {}
        for _, Key in ipairs(Keys) do
            Items[#Items + 1] = Indent .. HttpService:JSONEncode(Key) .. ": " .. Encode(Value[Key], Depth + 1)
        end
        return "{\n" .. table.concat(Items, ",\n") .. "\n" .. CloseIndent .. "}"
    end

    local function WriteConfig(Value)
        if type(writefile) ~= "function" then
            return false
        end
        local Ok, Encoded = pcall(Encode, Value, 0)
        if not Ok then
            return false
        end
        return (pcall(writefile, ConfigPath, Encoded .. "\n"))
    end

    local function ReadConfig()
        if type(readfile) ~= "function" then
            return nil
        end
        local Ok, Raw = pcall(readfile, ConfigPath)
        if not Ok or type(Raw) ~= "string" or Raw == "" then
            return nil
        end
        local DecodedOk, Decoded = pcall(HttpService.JSONDecode, HttpService, Raw)
        if DecodedOk and type(Decoded) == "table" then
            return Decoded
        end
        WriteLog("config.json is invalid; using defaults")
        return nil
    end

    EnsureFolder(Paths.Root)
    EnsureFolder(Paths.Configs)
    EnsureFolder(Paths.Images)
    EnsureFolder(Paths.Logs)
    EnsureFolder(Paths.Data)

    local UserConfig = ReadConfig()
    local Config = Merge(Defaults, UserConfig or {})
    for _, SectionName in ipairs({ "BossSettings", "MobSettings" }) do
        local Section = Config.GameSettings and Config.GameSettings[SectionName]
        if type(Section) == "table" then
            Section.Walkspeed = nil
        end
    end
    if not WriteConfig(Config) then
        WriteLog("could not write " .. ConfigPath)
    end

    Context.SWANGY = Config
    Context.SWANGY_PATHS = Paths
    Context.SWANGY_CONFIG_PATH = ConfigPath
    Context.saveSwangyConfig = function()
        if not WriteConfig(Context.SWANGY) then
            WriteLog("could not save " .. ConfigPath)
        end
    end
    Context.PATH = {
        root = Paths.Root,
        configs = Paths.Configs,
        images = Paths.Images,
        data = Paths.Data,
        logs = Paths.Logs,
    }

    local CFG = Context.CFG
    local Settings = Config.LobbySettings or {}
    local Creation = Settings.GameCreation or {}
    local Dungeon = Creation.DungeonSettings or {}
    local Multifarm = Creation.Multifarm or {}
    local Equip = Settings.AutoEquip or {}
    local Skillpoints = Settings.AutoSkillpoints or {}
    local Autosell = Settings.Autosell or {}
    local Upgrade = Settings.AutoUpgrade or {}
    local Character = Settings.CharacterOptions or {}
    local Game = Config.GameSettings or {}
    local CustomMap = Game.CustomMap or {}
    local Optimizations = Game.Optimizations or {}
    local Universal = Config.Universal or {}
    local Webhook = Universal.Webhook or {}
    local Auto = Config.Automation or {}
    local Visuals = Config.Visuals or {}
    local Logging = Config.Logging or {}

    local function Set(Key, Value)
        if Value ~= nil then
            CFG[Key] = Value
        end
    end

    local function Hex(Value, Fallback)
        if type(Value) == "string" then
            local Ok, Result = pcall(Color3.fromHex, Value)
            if Ok then
                return Result
            end
        end
        return Fallback
    end

    local Class = string.lower(tostring(Equip.Class or Skillpoints.Class or Upgrade.Class or ""))
    if Class == "mage" or Class == "warrior" then
        CFG.classProfile = Class
        CFG.classAuto = false
        if Context.applyClassProfile then
            pcall(Context.applyClassProfile, Class, true)
        end
    end

    Set("headless", true)
    Set("minimap", false)
    Set("gsRunButtons", false)
    Set("gsLookTimer", false)
    Set("tickHz", tonumber(Auto.TickHz) or CFG.tickHz)
    Set("autoQueueMap", Dungeon.Dungeon)
    Set("autoQueueDifficulty", Dungeon.Difficulty)
    Set("autoQueueHardcore", Dungeon.Hardcore == true)
    Set("autoFarmByPlace", Dungeon.AutoSelectHighest ~= false and Auto.AutoFarmByPlace ~= false)
    Set("bonusBoss", Dungeon.DoBonusBoss == true)
    Set("autoQueue", Auto.Enabled ~= false and Auto.AutoQueue ~= false)
    Set("autoQueueReplay", Auto.AutoQueueReplay ~= false)
    Set("autoStartDungeon", Auto.Enabled ~= false and Auto.AutoStart ~= false)
    Set("autoStartDelay", tonumber(Auto.StartDelay) or CFG.autoStartDelay)
    Set("autoAttack", Auto.AutoAttack ~= false)
    Set("autoE", Auto.AutoE ~= false)
    Set("autoQ", Auto.AutoQ ~= false)
    Set("wallsOn", Auto.Walls ~= false)
    if Class ~= "mage" and Class ~= "warrior" then
        Set("classAuto", true)
    end
    Set("autoSell", Autosell.Enabled == true)
    if Autosell.ItemLevelRequirement == "" then
        Set("sellKeepLevel", 0)
    else
        Set("sellKeepLevel", tonumber(Autosell.ItemLevelRequirement) or CFG.sellKeepLevel)
    end
    Set("sellKeep", type(Autosell.KeepTable) == "table" and Autosell.KeepTable or CFG.sellKeep)
    Set("autosellPreview", Autosell.PreviewAutosell ~= false)
    Set("bestGearAuto", Equip.Enabled == true)
    Set("gsAutoEquip", Equip.Enabled == true)
    Set("autoUpgrade", Upgrade.Enabled == true)
    Set("autoSkillpoints", Skillpoints.Class or "")
    Set("webhook", Webhook.Enabled == true)
    Set("webhookUrl", Webhook.Url or CFG.webhookUrl)
    Set("webhookUser", Webhook.DiscordUserID or CFG.webhookUser)
    Set("whHideName", Webhook.HidePlayerName == true)
    Set("hideNameTag", Character.HideNameTag == true)
    Set("limitSpellCasting", Game.LimitSpellCasting == true)
    Set("returnInventoryLimit", tonumber(Game.ReturnInventoryLimit) or CFG.returnInventoryLimit)
    Set("destroyGear", Optimizations.DestroyGear == true)
    Set("performanceMode", Optimizations.PerformanceMode == true)
    Set("perfMemo", Optimizations.PerformanceMode ~= false)
    Set("orbitMobs", Game.OrbitMobs == true)
    Set("killOnWave", tonumber(Game.KillOnWave) or CFG.killOnWave)
    Set("castBetweenEnemies", type(Game.CastBetweenEnemies) == "table" and Game.CastBetweenEnemies or CFG.castBetweenEnemies)
    Set("disableDodging", Game.DisableDodging == true)
    CFG.bossWalkSpeed = nil
    CFG.mobWalkSpeed = nil
    Set("bossCastingRange", tonumber((Game.BossSettings or {}).CastingRange) or CFG.bossCastingRange)
    Set("bossEnemyDistance", tonumber((Game.BossSettings or {}).EnemyDistance) or CFG.bossEnemyDistance)
    Set("mobCastingRange", tonumber((Game.MobSettings or {}).CastingRange) or CFG.mobCastingRange)
    Set("mobEnemyDistance", tonumber((Game.MobSettings or {}).EnemyDistance) or CFG.mobEnemyDistance)
    Set("multifarm", Multifarm)
    Set("bossRaidTier", tonumber(Dungeon.BossRaidTeir or Dungeon.BossRaidTier) or CFG.bossRaidTier)
    Set("customUIName", (Universal.CustomUI or {}).Name)
    Set("debugPrints", Logging.Debug == true)
    Set("autosaveInterval", tonumber(Logging.AutosaveSeconds) or CFG.autosaveInterval)

    Set("visuals", true)
    Set("drawHazards", Visuals.DrawHazards ~= false)
    Set("drawPath", Visuals.DrawPath ~= false)
    Set("drawSpots", Visuals.DrawSpots ~= false)
    Set("drawTarget", Visuals.DrawTarget ~= false)
    Set("drawAbility", Visuals.DrawAbility ~= false)
    Set("drawAoe", Visuals.DrawAoe ~= false)
    Set("drawScan", Visuals.DrawScan ~= false)
    Set("drawGroups", Visuals.DrawGroups ~= false)
    Set("drawBubble", Visuals.DrawBubble ~= false)
    Set("drawLeads", Visuals.DrawLeads ~= false)
    Set("drawNoGo", Visuals.DrawNoGo ~= false)
    Set("drawWaypoints", Visuals.DrawWaypoints ~= false)
    Set("labelHazards", Visuals.Labels == true)
    Set("labelUnknown", Visuals.Labels == true)
    Set("markerScale", tonumber(Visuals.MarkerScale) or CFG.markerScale)
    Set("spotRadius", tonumber(Visuals.SpotRadius) or CFG.spotRadius)
    Set("spotStep", tonumber(Visuals.SpotStep) or CFG.spotStep)
    Set("spotEvery", tonumber(Visuals.SpotEvery) or CFG.spotEvery)
    Set("hazardTransparency", tonumber(CustomMap.Transparency) or CFG.hazardTransparency)
    Set("mapAttackOneColor", type(CustomMap.Color) == "string")
    Set("mapAttackColor", Hex(CustomMap.Color, CFG.mapAttackColor))
    Set("colorFloor", Hex(Visuals.SafeColor, CFG.colorFloor))
    Set("colorSoon", Hex(Visuals.SoonColor, CFG.colorSoon))
    Set("colorLive", Hex(Visuals.DangerColor, CFG.colorLive))
    Set("colorTarget", Hex(Visuals.TargetColor, CFG.colorTarget))
    Set("colorAbility", Hex(Visuals.AbilityColor, CFG.colorAbility))

    local Rarities = type(Autosell.KeepRarities) == "table" and Autosell.KeepRarities or {}
    for Name, Key in pairs({
        Common = "sellCommon",
        Uncommon = "sellUncommon",
        Rare = "sellRare",
        Epic = "sellEpic",
        Legendary = "sellLegendary",
        Ultimate = "sellUltimate",
    }) do
        if Rarities[Name] ~= nil then
            CFG[Key] = Rarities[Name] ~= true
        end
    end

    WriteLog("loaded " .. ConfigPath)
    if Context.log then
        Context.log("Config", "headless config " .. ConfigPath)
    end
end