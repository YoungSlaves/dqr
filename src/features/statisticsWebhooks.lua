-- Extracted verbatim from harvardd.lua lines 138689-142555; presentation owned elsewhere.
return function(context)
    local config = context.CFG
    local runtimeState = context.RT
    local sharedValue = context.HttpService or getService("HttpService")
    local sharedValue2 = getService("Players")
    local sharedValue3, webhooks =
        context.ReplicatedStorage or getService("ReplicatedStorage"),
        { wins = 0, losses = 0, run = nil, mobKills = 0, bossKills = 0 }
    webhooks.sessionStart = os.time()
    local sharedValue4 = "DQSession_"
        .. tostring(sharedValue2.LocalPlayer and sharedValue2.LocalPlayer.UserId or 0)
        .. ".json"
    local function helper()
        pcall(function()
            if not writefile then
                return
            end
            if webhooks.sessStart then
                pcall(webhooks.sessStart, true)
            end
            writefile(
                sharedValue4,
                sharedValue:JSONEncode({
                    wins = webhooks.wins,
                    losses = webhooks.losses,
                    mobKills = webhooks.mobKills,
                    bossKills = webhooks.bossKills,
                    at = os.time(),
                    start = webhooks.sessionStart,
                })
            )
        end)
    end
    (function()
        local sessionStart, value = pcall(function()
            if isfile then
                if readfile then
                    if not (isfile(sharedValue4)) then
                        return nil
                    end
                else
                    return nil
                end
            else
                return nil
            end
            local value2 = argumentHelpers[108](readfile(sharedValue4))
            return sharedValue:JSONDecode(argumentHelpers:unpackValues(value2))
        end)
        if sessionStart then
            if not (type(value) == "table") then
                return
            end
        else
            return
        end
        sessionStart = tonumber(config.whSessionGap) or 21600
        if type(value.at) == "number" then
            if os.time() - value.at > sessionStart then
                return
            end
        end
        sessionStart = tonumber(value.start) or tonumber(value.at)
        if sessionStart then
            if sessionStart <= os.time() then
                webhooks.sessionStart = sessionStart
            end
        end
        local value3, value4, value5 =
            tonumber(value.wins), tonumber(value.losses), tonumber(config.whSessionMax) or 5000
        if value3 == nil then
            return
        elseif value4 == nil then
            return
        elseif value3 ~= math.floor(value3) then
            return
        elseif value4 ~= math.floor(value4) then
            return
        elseif value3 < 0 then
            return
        elseif value4 < 0 then
            return
        elseif value3 > value5 then
            return
        elseif value4 > value5 then
            return
        end
        webhooks.wins = value3
        webhooks.losses = value4
        value4, value3 = tonumber(value.mobKills), tonumber(value.bossKills)
        if value4 then
            if value3 then
                if value4 >= 0 then
                    if value3 >= 0 then
                        if value4 == math.floor(value4) then
                            if value3 == math.floor(value3) then
                                webhooks.mobKills = value4
                                webhooks.bossKills = value3
                            end
                        end
                    end
                end
            end
        end
    end)()
    context.WH = webhooks
    local sharedValue5, sharedValue6 = "HarvardLabs/data/session_all.json", "HarvardLabs/data/sessionruns"
    local function helper2()
        return type(readfile) == "function"
            and type(writefile) == "function"
            and type(listfiles) == "function"
    end
    webhooks.sessStart = function(argument)
        if not (helper2()) then
            return webhooks.sessionStart
        end
        local start = os.time()
        local value
        pcall(function()
            value = sharedValue:JSONDecode(readfile(sharedValue5))
        end)
        if
            type(value) ~= "table"
            or not tonumber(value.start)
            or start - (tonumber(value.at) or 0) > (tonumber(config.whSessionGap) or 21600)
        then
            value = { start = start, at = start }
            pcall(context.ensureFolders)
            pcall(writefile, sharedValue5, sharedValue:JSONEncode(value))
            pcall(function()
                local value2 = tostring(start) .. "_"
                for index, entry in ipairs(listfiles(sharedValue6)) do
                    if (tostring(entry):match("([^/\\]+)$") or ""):sub(1, #value2) ~= value2 then
                        pcall(delfile, entry)
                    end
                end
            end)
        else
            if argument then
                if start - (tonumber(value.at) or 0) >= 30 then
                    value.at = start
                    pcall(writefile, sharedValue5, sharedValue:JSONEncode(value))
                end
            end
        end
        webhooks.sessionStart = math.floor(tonumber(value.start) or start)
        return webhooks.sessionStart
    end
    webhooks.sessCount = function()
        if not (helper2()) then
            return webhooks.wins, webhooks.losses
        end
        local value, value2 = tostring(webhooks.sessStart(false)) .. "_", {}
        pcall(function()
            for index, entry in ipairs(listfiles(sharedValue6)) do
                index = tostring(entry):match("([^/\\]+)$") or ""
                if index:sub(1, #value) == value then
                    local value3, value4 = index:sub(#value + 1):match("^(.+)%.([wl])$")
                    if value3 then
                        if value4 == "w" then
                            value2[value3] = "w"
                        elseif not value2[value3] then
                            value2[value3] = "l"
                        end
                    end
                end
            end
        end)
        local wins, losses = 0, 0
        for key, entry2 in pairs(value2) do
            if entry2 == "w" then
                wins = wins + 1
            else
                losses = losses + 1
            end
        end
        webhooks.wins = wins
        webhooks.losses = losses
        return wins, losses
    end
    webhooks.sessMark = function(argument)
        local success = false
        if helper2() then
            local value = webhooks.sessStart(true)
            pcall(context.ensureFolders)
            pcall(function()
                if isfolder then
                    if makefolder then
                        if not (isfolder(sharedValue6)) then
                            makefolder(sharedValue6)
                        end
                    end
                end
            end)
            local value2 = tostring(game.JobId or ""):gsub("[^%w%-]", "")
            value2 = if value2 == "" then "solo" .. tostring(os.time()) else value2
            success = pcall(
                writefile,
                ("%s/%d_%s.%s"):format(sharedValue6, value, value2, argument and "w" or "l"),
                "1"
            )
        end
        if not success then
            if argument then
                webhooks.wins = webhooks.wins + 1
            else
                webhooks.losses = webhooks.losses + 1
            end
            return
        end
        webhooks.sessCount()
    end
    pcall(webhooks.sessStart, true)
    pcall(webhooks.sessCount)
    task.spawn(function()
        while not (runtimeState and runtimeState.destroyed) do
            task.wait(300)
            pcall(webhooks.sessStart, true)
        end
    end)
    context.noteBossDeath = function(argument)
        if argument then
            webhooks.rodinDeathAt = os.clock()
        else
            webhooks.bossDeathAt = os.clock()
        end
    end
    webhooks.endAt = function(argument, argument2)
        local now = os.clock()
        if argument then
            if argument2 then
                if argument >= argument2 then
                    if argument <= now then
                        if now - argument <= (tonumber(config.whEndWithin) or 30) then
                            return argument
                        end
                    end
                end
            end
        end
        return now
    end
    context.runStopAt = function(argument)
        local run = webhooks.run
        if run then
            if run.endedAt then
                if run.at then
                    if argument then
                        if math.abs(run.at - argument) < 30 then
                            return run.endedAt
                        end
                    end
                end
            end
        end
        local value = false
        pcall(function()
            local value2 = workspace:FindFirstChild("dungeonProgress")
            if value2 then
                if tostring(value2.Value) == "bossKilled" then
                    value = true
                end
            end
            value2 = workspace:FindFirstChild("dungeon")
            local value3 = value2 and (value2:FindFirstChild("bossRoom"))
            value2 = value3 and (value3:FindFirstChild("dungeonFinished"))
            if value2 then
                if value2.Value == true then
                    value = true
                end
            end
        end)
        if not value then
            return nil
        end
        return webhooks.endAt(webhooks.bossDeathAt, argument)
    end
    webhooks.runSecs = function(argument)
        if not argument then
            return 0
        end
        local value = argument.endedAt or os.clock()
        if config.whTimeAsHud == false then
            return math.floor(value - (argument.at or value) + 0.5)
        end
        local value2 = argument.hudAt or argument.at or value
        return math.max(math.floor(value - value2 - (config.startCountdown or 5)), 0)
    end
    context.noteKillAll = function(argument)
        if context.ST then
            if context.ST.noteKill then
                pcall(context.ST.noteKill, argument)
            end
        end
        if argument then
            webhooks.bossKills = (webhooks.bossKills or 0) + 1
        else
            webhooks.mobKills = (webhooks.mobKills or 0) + 1
        end
        if not webhooks.killSavePending then
            webhooks.killSavePending = true
            task.delay(2, function()
                webhooks.killSavePending = false
                pcall(helper)
            end)
        end
    end
    -- DQR network policy: the one webhook POST, through core/net.lua.
    local function helper3(url, body)
        local ok, status, err, retry = context.net.postJson(url, body)
        if ok then
            return true
        end
        if status == 429 then
            return false, "rate limited", retry or 1
        end
        return false, err
    end
    local function name2()
        local value = tostring(config.webhookUser or "")
        if value:match("^%s*$") then
            return "Harvard Labs"
        end
        return value
    end
    webhooks.name = name2
    local function post(argument)
        local value = tostring(config.webhookUrl or "")
        if config.webhook == false then
            return
        elseif value == "" then
            return
        end
        local success, value2 = pcall(function()
            return sharedValue:JSONEncode(argument)
        end)
        if not success then
            return
        end
        task.spawn(function()
            for index = 1, 3, 1 do
                local value3, value4, value5 = helper3(value, value2)
                if value3 then
                    return
                end
                task.wait(value5 or index)
                if index == 3 then
                    if context.log then
                        context.log("Webhook", "gave up: " .. tostring(value4))
                    end
                end
            end
        end)
    end
    webhooks.post = post
    webhooks.partyPoster = function()
        local success, value = pcall(function()
            return context.AF and context.AF.role and context.AF.role()
        end)
        if success then
            if value ~= nil then
                local success2, value2 = pcall(function()
                    return context.AF.isHost()
                end)
                return success2 and value2 == true
            end
        end
        return true
    end
    local text, color, sharedValue7, color2, sharedValue8 =
        "2026" .. string.char(194, 169) .. " Harvard Labs", 16705372, 3909981, 15548997, {}
    sharedValue8.common = string.char(226, 154, 170)
    sharedValue8.uncommon = string.char(240, 159, 159, 162)
    sharedValue8.rare = string.char(240, 159, 148, 181)
    sharedValue8.epic = string.char(240, 159, 159, 163)
    sharedValue8.legendary = string.char(240, 159, 159, 160)
    sharedValue8.ultimate = string.char(240, 159, 148, 180)
    sharedValue8.unknown = string.char(226, 154, 171)
    local sharedValue9, sharedValue10, sharedValue11, sharedValue12, sharedValue13, sharedValue14, sharedValue15 =
        { common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5, ultimate = 6 },
        { "ultimate", "legendary", "epic", "rare", "uncommon", "common", "unknown" },
        {
            common = "Common",
            uncommon = "Uncommon",
            rare = "Rare",
            epic = "Epic",
            legendary = "Legendary",
            ultimate = "Ultimate",
            unknown = "Unsorted",
        },
        { weapons = "Weapon", helmets = "Helmet", abilities = "Spell", chests = "Armour", keys = "Key" },
        { off = 99, epic = 4, legendary = 5, ultimate = 6 },
        {
            einherjar = "9/92/Einherjar_cosmetic.png",
            einherjarcosmetic = "9/92/Einherjar_cosmetic.png",
            flameshuriken = "4/45/Flame_Shuriken.png",
            flamestrike = "e/e5/Flame_Strike.png",
            frostcone = "d/d5/Frost_Cone.png",
            frostgiantgreataxe = "b/b9/Frost_Giant_Greataxe.png",
            galebarrage = "6/6b/Gale_Barrage.png",
            geyser = "5/5a/Geyser.png",
            gungnir = "5/5a/Gungnir.png",
            hofund = "7/7b/Hofund.png",
            icegreatspear = "e/e0/Ice_Greatspear.png",
            icespellblade = "d/d4/Ice_Spellblade.png",
            innerfocus = "1/12/Inner_Focus.png",
            innerrage = "6/65/Inner_Rage.png",
            jotunnguardianarmor = "9/9d/Jotunn_Guardian_Armor.png",
            jotunnguardianhelmet = "5/5a/Jotunn_Guardian_Helmet.png",
            jotunnmagearmor = "8/85/Jotunn_Mage_Armor.png",
            jotunnmagehelmet = "c/cd/Jotunn_Mage_Helmet.png",
            jotunnwarriorarmor = "8/84/Jotunn_Warrior_Armor.png",
            jotunnwarriorhelmet = "8/8c/Jotunn_Warrior_Helmet.png",
            laevateinn = "7/77/Laevateinn.png",
            midgardianguardianarmor = "e/ed/Midgardian_Guardian_Armor.png",
            midgardianguardianhelmet = "a/a6/Midgardian_Guardian_Helmet.png",
            midgardianmagearmor = "f/f3/Midgardian_Mage_Armor.png",
            midgardianmagehelmet = "7/79/Midgardian_Mage_Helmet.png",
            midgardianwarriorarmor = "3/32/Midgardian_Warrior_Armor.png",
            midgardianwarriorhelmet = "a/aa/Midgardian_Warrior_Helmet.png",
            mjolnir = "2/25/Mjolnir.png",
            norseblade = "9/9a/Norse_Blade.png",
            norsegreataxe = "d/dd/Norse_Greataxe.png",
            northernrunicblade = "c/c4/Northern_Runic_Blade.png",
            northernspellstaff = "6/65/Northern_Spellstaff.png",
            obsidianchunk = "0/0a/Obsidian_Chunk.png",
            runicmace = "1/1a/Runic_Mace.png",
            souldrain = "6/60/Soul_Drain.png",
            staffofthenorth = "4/41/Staff_of_the_North.png",
            valhallaguardianarmor = "c/cc/Valhalla_Guardian_Armor.png",
            valhallaguardianhelmet = "b/b6/Valhalla_Guardian_Helmet.png",
            valhallamagearmor = "1/12/Valhalla_Mage_Armor.png",
            valhallamagehelmet = "4/44/Valhalla_Mage_Helmet.png",
            valhallawarriorarmor = "e/ed/Valhalla_Warrior_Armor.png",
            valhallawarriorhelmet = "6/67/Valhalla_Warrior_Helmet.png",
            vikinghatchets = "7/74/Viking_Hatchets.png",
            vikingsceptre = "2/29/Viking_Sceptre.png",
            vikingshield = "e/e9/Viking_Shield.png",
        },
        {
            current = "1/17/Northern_Lands_Preview_New.png",
            northernlands = "1/17/Northern_Lands_Preview_New.png",
        }
    local function helper4(argument)
        local value = string.lower(tostring(argument or ""))
        value = string.gsub(value, "[^a-z0-9]", "")
        return (string.gsub(value, "armour", "armor"))
    end
    local function helper5(argument)
        if config.whImages == false then
            return nil
        end
        local value = sharedValue14[helper4(argument)]
        if not value then
            return nil
        end
        return "https://static.wikia.nocookie.net/dungeonquestroblox/images/" .. value
    end
    local function helper6(argument)
        if config.whImages == false then
            return nil
        end
        local value = sharedValue15[helper4(argument)]
        if not value then
            return nil
        end
        return "https://static.wikia.nocookie.net/dungeonquestroblox/images/" .. value
    end
    local function helper7(argument)
        local value
        local value2, value3 = -1, -1
        for index, entry in ipairs(argument or {}) do
            if
                config.whBestSpells == true
                or entry.cat ~= "abilities"
                or (sharedValue9[entry.rarity] or 0)
                    >= (sharedValue9[config.whBestSpellMin or "legendary"] or 5)
            then
                local value4, value5 = sharedValue9[entry.rarity] or 0, tonumber(entry.sell) or 0
                if config.whBestLevel ~= false then
                    local value6, value7, value8, value9 =
                        tonumber(entry.level) or 0,
                        string.find(string.lower(tostring(entry.name or "")), "guardian", 1, true) and 0 or 1,
                        value and (tonumber(value.level) or 0) or -1,
                        value
                                and (string.find(
                                    string.lower(tostring(value.name or "")),
                                    "guardian",
                                    1,
                                    true
                                ) and 0 or 1)
                            or -1
                    if
                        value4 > value2
                        or value4 == value2
                            and (value6 > value8 or value6 == value8 and (value7 > value9 or value7 == value9 and value5 > value3))
                    then
                        value, value2, value3 = entry, value4, value5
                    end
                else
                    if value4 > value2 then
                        value, value2, value3 = entry, value4, value5
                    else
                        if value4 == value2 then
                            if value5 > value3 then
                                value, value2, value3 = entry, value4, value5
                            end
                        end
                    end
                end
            end
        end
        return value
    end
    local sharedValue16 = {
        common = 9741752,
        uncommon = 2278750,
        rare = 3899638,
        epic = 11032054,
        legendary = 16750848,
        ultimate = 16726843,
    }
    local function helper8(argument, argument2)
        if not argument then
            return color2
        end
        if config.whAccent ~= false then
            if argument2 then
                if (sharedValue9[argument2.rarity] or 0) >= (sharedValue9.rare or 3) then
                    return sharedValue16[argument2.rarity] or sharedValue7
                end
            end
        end
        return sharedValue7
    end
    local function helper9(argument, argument2)
        if not argument2 then
            return
        end
        local url = helper5(argument2.name)
        if not url then
            return
        end
        if (sharedValue9[argument2.rarity] or 0) >= (sharedValue9.legendary or 5) then
            argument.image = { url = url }
        else
            argument.thumbnail = { url = url }
        end
    end
    local function helper10()
        return config.streamer == true and config.streamerName ~= false
    end
    local function helper11()
        return config.whHideName == true or helper10()
    end
    local function helper12(argument, argument2)
        if helper11() or argument.hidden then
            return ("Account %d"):format(argument2 or 0)
        end
        return tostring(argument.display or argument.who)
    end
    local function helper13()
        local localPlayer = sharedValue2.LocalPlayer
        return {
            name = localPlayer and not helper11() and ("%s (@%s)"):format(
                localPlayer.DisplayName,
                localPlayer.Name
            ) or "Harvard Labs",
            icon_url = "https://media.discordapp.net/attachments/1019371259978588321/1547128059545526292/Untitled151_20260906053210.png?ex=6aa44509&is=6aa2f389&hm=c7664b6c0a7136a0d0f8dc498e391bbceb2e0ede6fd3d8ba68ae6a516ce86081&=&format=webp&quality=lossless&width=944&height=944",
        }
    end
    local function helper14()
        local success, value = pcall(function()
            return DateTime.fromUnixTimestamp(os.time()):ToIsoDate()
        end)
        return success and value or nil
    end
    webhooks.runStats = function()
        if game.PlaceId == 77649408247578 then
            return nil
        end
        local success, value = pcall(function()
            return getService("TeleportService"):GetLocalPlayerTeleportData()
        end)
        return success
                and type(value) == "table"
                and type(value.dungeonStats) == "table"
                and value.dungeonStats
            or nil
    end
    webhooks.liveDungeon = function()
        for index, child in ipairs(game:GetService("Workspace"):GetChildren()) do
            if child.Name == "dungeonName" then
                if child:IsA("StringValue") then
                    if child.Value ~= "" then
                        return child.Value
                    end
                end
            end
        end
        local value = config.tdDifficulty ~= false and webhooks.runStats()
        if value then
            if type(value.dungeonName) == "string" then
                if value.dungeonName ~= "" then
                    return value.dungeonName
                end
            end
        end
        return nil
    end
    local function liveDifficulty()
        local success, value = pcall(function()
            local value2 = sharedValue3:FindFirstChild("aGame")
            local value3 = value2 and (value2:FindFirstChild("mapName"))
            if not value3 then
                return nil
            end
            value2 = value3:FindFirstChild("difficulty")
            local value4 = value2 and tostring(value2.Value) or ""
            if value4 == "" then
                return nil
            end
            value2 = value3:FindFirstChild("hardcore")
            if value2 then
                if value2.Value == true then
                    return value4 .. " (Hardcore)"
                end
            end
            return value4
        end)
        if success then
            if value then
                if value ~= "" then
                    return value
                end
            end
        end
        if config.tdDifficulty ~= false then
            success, value = webhooks.runStats(), webhooks.liveDungeon()
            if success then
                if type(success.difficulty) == "string" then
                    if success.difficulty ~= "" then
                        if value then
                            if tostring(success.dungeonName) == value then
                                return success.difficulty
                                    .. (
                                        (success.isHardcore == true or success.hardcore == true)
                                            and " (Hardcore)"
                                        or ""
                                    )
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
    webhooks.liveDifficulty = liveDifficulty
    local function helper15(argument)
        argument = math.max(math.floor(argument + 0.5), 0)
        local value, value2, value3 =
            math.floor(argument / 3600), math.floor(argument / 60) % 60, argument % 60
        if value > 0 then
            return ("%d:%02d:%02d"):format(value, value2, value3)
        end
        return ("%d:%02d"):format(value2, value3)
    end
    context.upgradeKey = function(name3, argument, argument2, argument3, argument4)
        argument2, argument3, argument4 =
            tonumber(argument2) or 0, tonumber(argument3) or 0, tonumber(argument4) or 0
        local value = string.lower(tostring(name3 or ""))
        if value:find("guardian", 1, true) then
            if argument4 > 0 then
                return "hp"
            end
        end
        if value:find("mage", 1, true) then
            if argument3 > 0 then
                return "spell"
            end
        end
        if value:find("warrior", 1, true) then
            if argument2 > 0 then
                return "phys"
            end
        end
        if argument ~= "pet" then
            if context.GP then
                if context.GP.primaryKey then
                    local success, value2 = pcall(context.GP.primaryKey, {
                        name = name3,
                        physicalDamage = argument2 > 0 and argument2 or nil,
                        spellPower = argument3 > 0 and argument3 or nil,
                        health = argument4 > 0 and argument4 or nil,
                    }, argument)
                    if success then
                        if value2 then
                            return value2 == "health" and "hp" or value2 == "spellPower" and "spell" or "phys"
                        end
                    end
                end
            end
        end
        if argument2 > 0 then
            return argument2 >= argument3 and "phys" or "spell"
        elseif argument3 > 0 then
            return argument2 >= argument3 and "phys" or "spell"
        end
        return argument4 > 0 and "hp" or nil
    end
    context.upgradeStatAfter = function(argument, argument2)
        argument, argument2 = tonumber(argument) or 0, math.max(0, math.floor(tonumber(argument2) or 0))
        if context.GP then
            if context.GP.maxPotential then
                local success, value = pcall(context.GP.maxPotential, argument, argument2)
                if success then
                    if tonumber(value) then
                        return tonumber(value)
                    end
                end
            end
        end
        return argument + argument2 * (config.upgradeStatStep or 10)
    end
    local sharedValue17 = { weapons = "weapon", helmets = "helmet", chests = "armor", pets = "pet" }
    local function itemFinalStats(argument)
        if type(argument) ~= "table" then
            return nil
        elseif argument.upMax == nil then
            return nil
        end
        local value, value2 =
            {
                phys = tonumber(argument.phys) or 0,
                spell = tonumber(argument.spell) or 0,
                hp = tonumber(argument.hp) or 0,
            }, math.max(0, (tonumber(argument.upMax) or 0) - (tonumber(argument.cur) or 0))
        local value3 = context.upgradeKey(
            argument.name,
            sharedValue17[tostring(argument.cat or "")],
            value.phys,
            value.spell,
            value.hp
        )
        if value3 then
            if value2 > 0 then
                value[value3] = context.upgradeStatAfter(value[value3], value2)
            end
        end
        return value
    end
    context.itemFinalStats = itemFinalStats
    local helper16
    local sharedValue18 = { weapons = "weapon", helmets = "helmet", chests = "chest" }
    context.itemGodpot = function(argument)
        local gearProfiles = context.GP
        if gearProfiles then
            if gearProfiles.compute then
                if type(argument) ~= "table" then
                    return nil
                end
            else
                return nil
            end
        else
            return nil
        end
        local value = sharedValue18[tostring(argument.cat or "")]
        if not value then
            return nil
        end
        local value2, success, value3 =
            tonumber(argument.phys) or 0, tonumber(argument.spell) or 0, tonumber(argument.hp) or 0
        local value4 = {
            name = argument.name,
            rarity = argument.rarity,
            physicalDamage = value2 > 0 and value2 or nil,
            spellPower = success > 0 and success or nil,
            health = value3 > 0 and value3 or nil,
            currentUpgrade = tonumber(argument.cur) or 0,
            maxUpgrades = tonumber(argument.upMax) or 0,
        }
        success, value2 = pcall(gearProfiles.compute, value4, value)
        if success then
            if type(value2) == "number" then
                return value2
            end
        end
        return nil
    end
    local function helper17(argument)
        local value = itemFinalStats(argument)
        if value then
            if value.phys + value.spell + value.hp <= 0 then
                return ""
            end
        else
            return ""
        end
        local value2 = {}
        if value.phys > 0 then
            value2[#value2 + 1] = ("Phys `%s`"):format(helper16(value.phys))
        end
        if value.spell > 0 then
            value2[#value2 + 1] = ("Spell `%s`"):format(helper16(value.spell))
        end
        if value.hp > 0 then
            value2[#value2 + 1] = ("HP `%s`"):format(helper16(value.hp))
        end
        value = "\10" .. table.concat(value2, "  ") .. " at max"
        if config.whGodpot ~= false then
            value2 = context.itemGodpot(argument)
            value = if value2 then value .. ("  Godpot `%.1f%%`"):format(value2) else value
        end
        return value
    end
    local function sig3(argument)
        local value = math.abs(argument)
        if value >= 100 then
            return ("%.0f"):format(argument)
        end
        if value >= 10 then
            return ("%.1f"):format(argument)
        end
        return ("%.2f"):format(argument)
    end
    context.sig3 = sig3
    helper16 = function(argument)
        argument = tonumber(argument) or 0
        local value = math.abs(argument)
        if value >= 999500000000 then
            return sig3(argument / 1000000000000) .. "t"
        end
        if value >= 999500000 then
            return sig3(argument / 1000000000) .. "b"
        end
        if value >= 999500 then
            return sig3(argument / 1000000) .. "m"
        end
        if value >= 999.5 then
            return sig3(argument / 1000) .. "k"
        end
        return tostring(math.floor(argument + 0.5))
    end
    local function helper18(argument)
        argument = tonumber(argument) or 0
        if argument >= 0 then
            return "+" .. helper16(argument)
        end
        return "-" .. helper16(-argument)
    end
    local function helper19(argument)
        local value = sharedValue2.LocalPlayer
        local value2 = value and (value:FindFirstChild("leaderstats"))
        value = value2 and (value2:FindFirstChild(argument))
        if value then
            return tonumber(value.Value)
        end
        return nil
    end
    local function helper20(argument)
        local value = string.lower(tostring(argument.rarity or ""))
        if sharedValue9[value] then
            return value
        end
        value = string.lower(tostring(argument.name or ""))
        for index, entry in ipairs(sharedValue10) do
            if entry ~= "unknown" then
                if string.find(value, entry, 1, true) then
                    return entry
                end
            end
        end
        return "unknown"
    end
    local sharedValue19, sharedValue20, sharedValue21 = false, 0
    local function helper21()
        if sharedValue21 then
            local value = sharedValue21
            return value
        end
        sharedValue21 = tonumber(config.whBagCap) or 0
        if sharedValue21 <= 0 then
            pcall(function()
                local value2 = sharedValue3:FindFirstChild("modules")
                local value3 = value2 and (value2:FindFirstChild("inventoryHelperFunctions"))
                value2 = value3 and require(value3)
                if type(value2) == "table" then
                    if tonumber(value2.MAX_INVENTORY_ITEMS) then
                        sharedValue21 = tonumber(value2.MAX_INVENTORY_ITEMS)
                    end
                end
            end)
        end
        if sharedValue21 <= 0 then
            sharedValue21 = 300
        end
        local value4 = sharedValue21
        return value4
    end
    local function helper22()
        local remotes = sharedValue3:FindFirstChild("remotes")
        if remotes then
            return remotes:FindFirstChild("reloadInvy")
        end
        return nil
    end
    local function helper23()
        local value = helper22()
        if not value then
            return nil
        end
        local success, value2 = pcall(function()
            return value:InvokeServer()
        end)
        if success then
            if type(value2) ~= "table" then
                return nil
            end
        else
            return nil
        end
        local value3, value4 = {}, 0
        for key, entry in pairs(value2) do
            if type(entry) == "table" then
                for key2, entry2 in pairs(entry) do
                    if type(entry2) == "table" then
                        if type(entry2.name) == "string" then
                            if entry2.name ~= "" then
                                success = value4 + 1
                                value3[type(entry2.UniqueItemID) == "string" and entry2.UniqueItemID or tostring(
                                    key
                                ) .. "/" .. tostring(key2)] =
                                    {
                                        name = entry2.name,
                                        rarity = helper20(entry2),
                                        cat = tostring(key),
                                        sell = tonumber(entry2.sellPrice) or 0,
                                        level = tonumber(entry2.levelReq) or 0,
                                        phys = tonumber(entry2.physicalPower or entry2.physicalDamage) or 0,
                                        spell = tonumber(entry2.spellPower) or 0,
                                        hp = tonumber(entry2.health) or 0,
                                        upMax = tonumber(entry2.maxUpgrades) or 0,
                                        cur = tonumber(entry2.currentUpgrade) or 0,
                                    }
                                value4 = success
                            end
                        end
                    end
                end
            end
        end
        return value3, value4
    end
    local function helper24(argument)
        if sharedValue19 then
            if os.clock() - sharedValue20 < 15 then
                return nil
            end
        end
        local value
        value, sharedValue19 = os.clock(), true
        sharedValue20 = value
        local value2, value3
        local value4 = false
        task.spawn(function()
            value2, value3 = helper23()
            sharedValue19, value4 = false, true
        end)
        value = os.clock()
        while true do
            local value5 = not value4 and os.clock() - value < (argument or 12)
            if not value5 then
                break
            end
            task.wait(0.2)
        end
        value, argument = value2, value3
        return value, argument
    end
    local function helper25(argument, argument2)
        local value = {}
        if argument then
            if not argument2 then
                return value
            end
        else
            return value
        end
        for key, entry in pairs(argument2) do
            if not argument[key] then
                entry.uid = key
                value[#value + 1] = entry
            end
        end
        return value
    end
    webhooks.emojis = webhooks.emojis or {}
    -- DQR network policy: the old emoji poll fetched a non-user host. Removed.
    webhooks.emojis = webhooks.emojis or {}
    local function helper26(argument, argument2)
        if #argument == 0 then
            if argument2 then
                if argument2 > 0 then
                    return ("%d reward%s, but the inventory would not open - no names this run"):format(
                        argument2,
                        argument2 == 1 and "" or "s"
                    )
                end
            end
            return "nothing"
        end
        local value, value2 = {}, {}
        for index, entry in ipairs(argument) do
            index = sharedValue9[entry.rarity] and entry.rarity or "unknown"
            argument2 = index .. "|" .. tostring(entry.cat or "") .. "|" .. tostring(entry.name or "?")
            local value3 = value[argument2]
            if not value3 then
                value3 = { name = tostring(entry.name or "?"), rarity = index, cat = entry.cat, n = 0 }
                value[argument2] = value3
                value2[#value2 + 1] = value3
            end
            value3.n = value3.n + 1
        end
        table.sort(value2, function(argument3, argument4)
            local value4, value5 = sharedValue9[argument3.rarity] or 0, sharedValue9[argument4.rarity] or 0
            if value4 ~= value5 then
                return value4 > value5
            end
            if argument3.n ~= argument4.n then
                return argument3.n > argument4.n
            end
            return argument3.name < argument4.name
        end)
        argument2, argument = "", 0
        for index2, entry2 in ipairs(value2) do
            local value6, value7 =
                ("%s **%s** (%dx)"):format(
                    sharedValue8[entry2.rarity] or sharedValue8.unknown,
                    entry2.name,
                    entry2.n
                ),
                config.whIcons ~= false and webhooks.emojis and webhooks.emojis[helper4(entry2.name)] or nil
            value6 = if type(value7) == "string"
                then if value7:match("^<a?:[%w_]+:%d+>$")
                    then ("%s %s **%s** (%dx)"):format(
                        sharedValue8[entry2.rarity] or sharedValue8.unknown,
                        value7,
                        entry2.name,
                        entry2.n
                    )
                    else value6
                else value6
            if #argument2 + #value6 + 1 > 980 then
                argument = #value2 - index2 + 1
                break
            end
            argument2 = argument2 == "" and value6 or argument2 .. "\10" .. value6
        end
        return if argument > 0 then argument2 .. ("\10+%d more"):format(argument) else argument2
    end
    local function helper27(argument, argument2)
        if config.whTally ~= false then
            return helper26(argument, argument2)
        end
        if #argument == 0 then
            if argument2 then
                if argument2 > 0 then
                    return ("%d reward%s, but the inventory would not open - no names this run"):format(
                        argument2,
                        argument2 == 1 and "" or "s"
                    )
                end
            end
            return "nothing"
        end
        argument2 = {}
        for index, entry in ipairs(argument) do
            index = sharedValue9[entry.rarity] and entry.rarity or "unknown"
            if not argument2[index] then
                argument2[index] = {}
            end
            local value = argument2[index]
            value[#value + 1] = entry
        end
        argument = {}
        for index2, entry2 in ipairs(sharedValue10) do
            index2 = argument2[entry2]
            if index2 then
                table.sort(index2, function(argument3, argument4)
                    return argument3.name < argument4.name
                end)
                local value2, value3 = {}, {}
                for index3, entry3 in ipairs(index2) do
                    index3 = sharedValue12[entry3.cat]
                    local value4 = index3 and ("%s *(%s)*"):format(entry3.name, index3) or entry3.name
                    if value3[value4] then
                        value3[value4] = value3[value4] + 1
                    else
                        value3[value4] = 1
                        value2[#value2 + 1] = value4
                    end
                end
                for index4, entry4 in ipairs(value2) do
                    if value3[entry4] > 1 then
                        value2[index4] = entry4 .. " x" .. value3[entry4]
                    end
                end
                argument[#argument + 1] = ("%s **%s** - %s"):format(
                    sharedValue8[entry2] or sharedValue8.unknown,
                    sharedValue11[entry2] or entry2,
                    table.concat(value2, ", ")
                )
            end
        end
        local value5, value6 = "", 0
        for index5, entry5 in ipairs(argument) do
            if #value5 + #entry5 + 1 > 950 then
                value6 = #argument - index5 + 1
                break
            end
            value5 = value5 == "" and entry5 or value5 .. "\10" .. entry5
        end
        return if value6 > 0
            then value5 .. ("\10...and %d more line%s"):format(value6, value6 == 1 and "" or "s")
            else value5
    end
    local function helper28(argument)
        local value = 0
        for index, entry in ipairs(argument) do
            value += entry.sell or 0
        end
        return value
    end
    local function val3(argument)
        local value = sharedValue9[argument.rarity]
        if value then
            if value < 4 then
                return false
            end
        else
            return false
        end
        value = string.lower(tostring(argument.name or ""))
        return string.find(value, "gildenscale mage", 1, true) ~= nil
            or string.find(value, "gildenscale warrior", 1, true) ~= nil
    end
    webhooks.valT3 = val3
    webhooks.pingIds = function()
        local value, value2 = {}, {}
        for entry in tostring(config.whPingId or ""):gmatch("%d+") do
            if not value2[entry] then
                value2[entry] = true
                value[#value + 1] = entry
            end
        end
        return value
    end
    local function helper29(argument)
        local value, value2, value3 =
            sharedValue13[tostring(config.whPingMin or "off")] or 99,
            webhooks.pingIds(),
            config.whPingValT3 ~= false
        if value > 6 then
            if value3 then
                if #value2 == 0 then
                    return nil
                end
            else
                return nil
            end
        elseif #value2 == 0 then
            return nil
        end
        for index, entry in ipairs(argument) do
            if (sharedValue9[entry.rarity] or 0) >= value or value3 and val3(entry) then
                index = {}
                for index2, entry2 in ipairs(value2) do
                    index[index2] = "<@" .. entry2 .. ">"
                end
                return table.concat(index, " ")
            end
        end
        return nil
    end
    local function helper30()
        local localPlayer = sharedValue2.LocalPlayer
        local valueObject = localPlayer and (localPlayer:FindFirstChild("Candy"))
        return valueObject and tonumber(valueObject.Value) or nil
    end
    do
        local sharedValue22, sharedValue23 = { okbutnope = true }, {}
        local function watchAlert(player, how)
            if config.watchAlert == false then
                return
            elseif not player then
                return
            elseif player == sharedValue2.LocalPlayer then
                return
            end
            if context.RT then
                if context.RT.destroyed then
                    return
                end
            end
            if not sharedValue22[string.lower(tostring(player.Name))] then
                return
            end
            local value = tostring(player.UserId) .. "|" .. tostring(game.JobId)
            if sharedValue23[value] then
                return
            end
            sharedValue23[value] = true
            local value2 = "HarvardLabs/data/watch_"
                .. tostring(player.UserId)
                .. "_"
                .. string.sub(tostring(game.JobId), 1, 12)
                .. ".json"
            local success, dungeonName = pcall(function()
                return isfile(value2)
            end)
            if success then
                if dungeonName then
                    return
                end
            end
            pcall(writefile, value2, tostring(os.time()))
            dungeonName = workspace:FindFirstChild("dungeonName")
            local where = dungeonName and tostring(dungeonName.Value) ~= "" and tostring(dungeonName.Value)
                or "the lobby"
            local value3 = (context.ST and context.ST.url and context.ST.url() or ""):gsub("/v1/run.*$", "")
            local key = context.licenceKey and context.licenceKey() or nil
            if value3 == "" then
                return
            elseif not key then
                return
            end
            local success2, value4 = pcall(function()
                local value5 = {
                    key = key,
                    uid = player.UserId,
                    name = tostring(player.Name),
                    display = tostring(player.DisplayName),
                    how = how,
                    where = where,
                    seen = tostring(sharedValue2.LocalPlayer and sharedValue2.LocalPlayer.Name or "?"),
                    job = tostring(game.JobId),
                    place = game.PlaceId,
                }
                return sharedValue:JSONEncode(value5)
            end)
            if not success2 then
                return
            end
            task.spawn(function()
                for index = 1, 3, 1 do
                    local value5, o, value6 = helper3(value3 .. "/v1/watch", value4)
                    if value5 then
                        return
                    end
                    task.wait(value6 or index)
                end
            end)
        end
        task.spawn(function()
            task.wait(3)
            for index, entry in ipairs(sharedValue2:GetPlayers()) do
                pcall(watchAlert, entry, "is in the server")
            end
        end)
        local connection
        local function helper31(argument)
            if context.RT then
                if context.RT.destroyed then
                    pcall(function()
                        connection:Disconnect()
                    end)
                    return
                end
            end
            pcall(watchAlert, argument, "joined the server")
        end
        connection = sharedValue2.PlayerAdded:Connect(helper31)
        webhooks.watchAlert = watchAlert
    end
    webhooks.start = function(success, url)
        local run = {}
        run.dungeon = success or "Unknown"
        run.difficulty = url or "Unknown"
        run.at = os.clock()
        run.deaths = 0
        run.items = {}
        run.cards = 0
        run.gold = helper19("Gold") or 0
        run.gems = helper19("Gems") or 0
        run.level = helper19("Level") or 0
        run.killM = webhooks.mobKills or 0
        run.killB = webhooks.bossKills or 0
        run.candy = helper30()
        run.event = context.isEvent and context.isEvent() or nil
        webhooks.run = run
        webhooks.lastDungeon, webhooks.lastDifficulty = run.dungeon, run.difficulty
        task.spawn(function()
            local base = helper24(12)
            if webhooks.run == run then
                run.base = base
            end
        end)
        if config.whStarted == false then
            return
        end
        if context.whShared then
            if context.whShared("whStarted") == false then
                return
            elseif context.whShared("webhook") == false then
                return
            end
        end
        if context.AF and context.AF.role() ~= nil then
            if not (context.AF.isHost()) then
                return
            end
        elseif #getService("Players"):GetPlayers() > 1 then
            if context.isRunOwner then
                success, url = pcall(context.isRunOwner)
                if success then
                    if url == false then
                        return
                    end
                end
            end
        end
        success, url =
            {
                title = "Run started",
                description = ("**%s**   %s"):format(run.dungeon, run.difficulty),
                color = color,
                author = helper13(),
                footer = { text = text },
                timestamp = helper14(),
            }, helper6(run.dungeon)
        if url then
            success.thumbnail = { url = url }
        end
        if context.ST then
            if context.ST.status then
                local value, value2 = context.ST.status()
                success.footer = { text = text .. "  |  stats: " .. tostring(value2) }
                if not value then
                    success.color = 10181046
                end
            end
        end
        post({ username = name2(), embeds = { success } })
    end
    webhooks.death = function()
        if webhooks.run then
            webhooks.run.deaths = webhooks.run.deaths + 1
        end
    end
    webhooks.rodinBegin = function()
        local rodin = {}
        rodin.at = os.clock()
        rodin.deaths = 0
        rodin.cards = 0
        rodin.gold = helper19("Gold") or 0
        rodin.gems = helper19("Gems") or 0
        webhooks.rodin = rodin
        task.spawn(function()
            for index = 1, 5, 1 do
                if webhooks.rodin ~= rodin then
                    return
                end
                index = helper24(12)
                if index then
                    rodin.base = index
                    return
                end
                task.wait(3)
            end
        end)
    end
    webhooks.rodinFail = function(argument, argument2)
        if config.whRodin == false then
            return
        end
        local run, rodin = webhooks.run, webhooks.rodin
        if webhooks.rodin == rodin then
            webhooks.rodin = nil
        end
        webhooks.rodinFails = (webhooks.rodinFails or 0) + 1
        local value = {}
        if argument then
            value[#value + 1] = ("`fight %s`"):format(helper15(os.clock() - argument))
        end
        argument = rodin and rodin.deaths or run and (run.deaths or 0) - (argument2 or 0)
        if argument then
            if config.whDeaths ~= false then
                value[#value + 1] = ("`%d death%s`"):format(argument, argument == 1 and "" or "s")
            end
        end
        if run then
            value[#value + 1] = ("`run %s`"):format(helper15(os.clock() - run.at))
        end
        argument2 = helper19("Level")
        if argument2 then
            if config.whLevel ~= false then
                value[#value + 1] = ("`Lv %d`"):format(argument2)
            end
        end
        argument, argument2 =
            run and run.dungeon or webhooks.lastDungeon, run and run.difficulty or webhooks.lastDifficulty
        local title, fields, value2, value3 =
            if argument
                then ("%s   %s   %s"):format("Odin Reincarnation", argument, argument2 or "")
                else "Odin Reincarnation",
            {},
            {
                name = "Result",
                value = "The bonus boss was lost - the game ends the run as DUNGEON FAILED. The run's own drops were posted at the Odin kill.",
                inline = false,
            },
            { name = "Session" }
        value3.value, value3.inline =
            ("%d Rodin clear%s, %d failed"):format(
                webhooks.rodinClears or 0,
                (webhooks.rodinClears or 0) == 1 and "" or "s",
                webhooks.rodinFails
            ),
            true
        argumentHelpers:appendValues(fields, 0, value2, value3)
        if not (webhooks.partyPoster()) then
            return
        end
        post({
            username = name2(),
            embeds = {
                {
                    title = title,
                    description = "**RODIN FAILED**"
                        .. (#value > 0 and "   " .. table.concat(value, "   ") or ""),
                    color = color2,
                    fields = fields,
                    author = helper13(),
                    footer = { text = text },
                    timestamp = helper14(),
                },
            },
        })
    end
    webhooks.rodinClear = function(argument, argument2)
        local value = context.ST ~= nil and context.ST.noteRodinDrops ~= nil and config.statsEnabled ~= false
        if config.whRodin == false then
            if not value then
                return
            end
        end
        local run = webhooks.run
        local rodin = webhooks.rodin
        local endAt, rodinDeathAt, value2 = webhooks.endAt, webhooks.rodinDeathAt, argument or run and run.at
        local value3 = endAt(rodinDeathAt, value2)
        webhooks.rodinClears = (webhooks.rodinClears or 0) + 1
        local clears = webhooks.rodinClears
        task.spawn(function()
            local value4, bag = {}
            local value5 = false
            if rodin then
                if rodin.base then
                    task.wait(tonumber(config.whRodinGather) or 4)
                    local value6, value7 = helper24(12)
                    local value8, value9, value10
                    if value6 then
                        value8, value9, value10 = helper25(rodin.base, value6), value7, true
                    else
                        value8, value9, value10 = value4, bag, value5
                    end
                    if value10 then
                        if #value8 == 0 then
                            task.wait(tonumber(config.whRodinGatherMore) or 6)
                            value6, value7 = helper24(12)
                            if value6 then
                                local value11 = helper25(rodin.base, value6)
                                value4, bag = value11, value7
                            else
                                value4, bag = value8, value9
                            end
                        else
                            value4, bag = value8, value9
                        end
                    else
                        value4, bag = value8, value9
                    end
                    value5 = value10
                end
            end
            if webhooks.rodin == rodin then
                webhooks.rodin = nil
            end
            if value5 then
                if value then
                    pcall(context.ST.noteRodinDrops, value4)
                end
            end
            if config.whRodin == false then
                return
            end
            local value12, content = helper7(value4), {}
            if argument then
                content[#content + 1] = ("`fight %s`"):format(helper15(value3 - argument))
            end
            local deaths = rodin and rodin.deaths or run and (run.deaths or 0) - (argument2 or 0) or nil
            if deaths then
                if config.whDeaths ~= false then
                    content[#content + 1] = deaths <= 0 and "`no deaths`"
                        or ("`%d death%s`"):format(deaths, deaths == 1 and "" or "s")
                end
            end
            if run then
                content[#content + 1] = ("`run %s`"):format(helper15(value3 - run.at))
            end
            local level = helper19("Level")
            if level then
                if config.whLevel ~= false then
                    content[#content + 1] = ("`Lv %d`"):format(level)
                end
            end
            local fields = {}
            local function helper32(name3, argument3, argument4)
                if argument3 == nil then
                    return
                elseif argument3 == "" then
                    return
                end
                fields[#fields + 1] =
                    { name = name3, value = tostring(argument3), inline = argument4 ~= false }
            end
            if config.whBest ~= false then
                if value12 then
                    helper32(
                        "Best drop",
                        ("%s **%s**\10%s%s%s"):format(
                            sharedValue8[value12.rarity] or sharedValue8.unknown,
                            tostring(value12.name),
                            sharedValue11[value12.rarity] or "Unsorted",
                            sharedValue12[value12.cat] and " " .. sharedValue12[value12.cat] or "",
                            helper17(value12)
                        )
                    )
                end
            end
            if config.whWorth ~= false then
                if #value4 > 0 then
                    helper32("Haul value", "`" .. helper16(helper28(value4)) .. "` gold")
                end
            end
            if config.whItems ~= false then
                if value5 then
                    helper32(("Loot (%d)"):format(#value4), helper27(value4, rodin.cards or 0), false)
                else
                    local value13 = rodin and rodin.cards or 0
                    helper32(
                        "Loot",
                        ("%d reward%s - the bag could not be read, no names"):format(
                            value13,
                            value13 == 1 and "" or "s"
                        ),
                        false
                    )
                end
            end
            if config.whGold ~= false then
                if rodin then
                    local value14, value15 = helper19("Gold"), helper19("Gems")
                    if value14 or value15 then
                        helper32(
                            "Earned",
                            ("%s gold\10%s gems"):format(
                                helper18((value14 or rodin.gold) - rodin.gold),
                                helper18((value15 or rodin.gems) - rodin.gems)
                            )
                        )
                    end
                end
            end
            if config.whInv ~= false then
                if bag then
                    helper32("Bag", ("%d/%d"):format(bag, helper21()))
                end
            end
            helper32("Session", ("%d Rodin clear%s"):format(clears, clears == 1 and "" or "s"))
            local dungeon, difficulty =
                run and run.dungeon or webhooks.lastDungeon, run and run.difficulty or webhooks.lastDifficulty
            helper32 = {
                title = if dungeon
                    then ("%s   %s   %s"):format("Odin Reincarnation", dungeon, difficulty or "")
                    else "Odin Reincarnation",
                description = "**RODIN CLEARED**"
                    .. (#content > 0 and "   " .. table.concat(content, "   ") or ""),
                color = value12 and helper8(true, value12) or sharedValue7,
                fields = fields,
                author = helper13(),
                footer = { text = text },
                timestamp = helper14(),
            }
            helper9(helper32, value12)
            value12, content = { username = name2(), embeds = { helper32 } }, helper29(value4)
            if content then
                value12.content = content
            end
            content = {
                items = {},
                cards = rodin and rodin.cards or 0,
                deaths = deaths,
                clears = clears,
                bag = bag,
                fight = argument and value3 - argument or nil,
                run = run and value3 - run.at or nil,
                level = level,
                dungeon = dungeon,
                difficulty = difficulty,
            }
            for index = 1, #value4, 1 do
                dungeon = value4[index]
                content.items[index] = {
                    name = dungeon.name,
                    rarity = dungeon.rarity,
                    cat = dungeon.cat,
                    sell = dungeon.sell,
                    level = dungeon.level,
                    phys = dungeon.phys,
                    spell = dungeon.spell,
                    hp = dungeon.hp,
                    upMax = dungeon.upMax,
                    cur = dungeon.cur,
                }
            end
            if rodin then
                dungeon, helper32 = helper19("Gold"), helper19("Gems")
                content.gold, content.gems =
                    (dungeon or rodin.gold) - rodin.gold, (helper32 or rodin.gems) - rodin.gems
            end
            if webhooks.rodinMerge then
                if webhooks.rodinMerge(content) then
                    return
                end
            end
            post(value12)
        end)
    end
    webhooks.item = function(argument, argument2)
        local run = webhooks.run
        if not run then
            return
        end
        run.items[#run.items + 1] = argument2 and argument .. " - " .. argument2 or argument
    end
    task.spawn(function()
        local value = sharedValue2.LocalPlayer and sharedValue2.LocalPlayer:WaitForChild("PlayerGui", 30)
        local value2 = value and (value:WaitForChild("rewardGuiHolder", 120))
        value = value2 and (value2:WaitForChild("holder", 30))
        if not value then
            return
        end
        local function helper32(argument)
            if argument:IsA("GuiObject") then
                if webhooks.run then
                    webhooks.run.cards = webhooks.run.cards + 1
                end
            end
            if argument:IsA("GuiObject") then
                if webhooks.rodin then
                    webhooks.rodin.cards = (webhooks.rodin.cards or 0) + 1
                end
            end
        end
        value.ChildAdded:Connect(helper32)
        function webhooks.currency()
            local value3 = {}
            pcall(function()
                for index, child in ipairs(value2:GetChildren()) do
                    for index2, descendant in ipairs(child:GetDescendants()) do
                        if descendant:IsA("TextLabel") then
                            if descendant.Name == "amount" then
                                if descendant.Text ~= "" then
                                    index2, index =
                                        descendant.Parent and descendant.Parent.Name or "?",
                                        descendant.Visible and descendant.Parent and descendant.Parent.Visible
                                    local value4 = index2 == "?"
                                        or descendant.Text:lower():find(index2:lower():sub(1, 3), 1, true)
                                            ~= nil
                                    if index then
                                        if value4 then
                                            if not value3[index2] then
                                                value3[index2] = descendant.Text
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            return value3
        end
    end)
    local function helper33(argument, argument2, argument3)
        local fields = {}
        local function text2(name3, argument4, argument5)
            if argument4 == nil then
                return
            elseif argument4 == "" then
                return
            end
            fields[#fields + 1] = { name = name3, value = tostring(argument4), inline = argument5 ~= false }
        end
        local content, title = helper7(argument3), {}
        if config.whTime ~= false then
            title[#title + 1] = "`" .. helper15(webhooks.runSecs(argument)) .. "`"
        end
        if config.whDeaths ~= false then
            title[#title + 1] = argument.deaths == 0 and "`no deaths`"
                or ("`%d death%s`"):format(argument.deaths, argument.deaths == 1 and "" or "s")
        end
        if config.whLevel ~= false then
            local value = helper19("Level")
            if value then
                title[#title + 1] = ("`Lv %d`"):format(value)
            end
        end
        local description = ("**%s**"):format(argument2 and "VICTORY" or "DEFEAT")
        description = if #title > 0 then description .. "   " .. table.concat(title, "   ") else description
        if config.whBest ~= false then
            if content then
                text2(
                    "Best drop",
                    ("%s **%s**\10%s%s%s"):format(
                        sharedValue8[content.rarity] or sharedValue8.unknown,
                        tostring(content.name),
                        sharedValue11[content.rarity] or "Unsorted",
                        sharedValue12[content.cat] and " " .. sharedValue12[content.cat] or "",
                        helper17(content)
                    )
                )
            end
        end
        if config.whWorth ~= false then
            if #argument3 > 0 then
                text2("Haul value", "`" .. helper16(helper28(argument3)) .. "` gold")
            end
        end
        title = helper30()
        local value2 = argument.event and argument.candy and title
        if config.whItems ~= false then
            if not (value2 and #argument3 == 0) then
                text2(("Loot (%d)"):format(#argument3), helper27(argument3, argument.cards), false)
            end
        end
        if value2 then
            text2(
                "Candy",
                ("%s this run\10%s banked"):format(helper18(title - argument.candy), helper16(title))
            )
        end
        if config.whGold ~= false then
            value2, title = helper19("Gold"), helper19("Gems")
            if value2 or title then
                text2(
                    "Earned",
                    ("%s gold\10%s gems"):format(
                        helper18((value2 or argument.gold) - argument.gold),
                        helper18((title or argument.gems) - argument.gems)
                    )
                )
                text2("Banked", ("%s gold\10%s gems"):format(helper16(value2 or 0), helper16(title or 0)))
            end
        end
        if config.whInv ~= false then
            if argument.invTotal then
                text2("Bag", ("%d/%d"):format(argument.invTotal, helper21()))
            end
        end
        if config.whWins ~= false then
            title, value2 =
                webhooks.wins + webhooks.losses, ("%d W / %d L"):format(webhooks.wins, webhooks.losses)
            text2(
                "Session",
                if config.whRatio ~= false
                    then if title > 0
                        then value2 .. ("   %d%%"):format(math.floor(webhooks.wins / title * 100 + 0.5))
                        else value2
                    else value2
            )
        end
        title = argument.dungeon
        title = if config.whDungeon ~= false
            then if argument.difficulty
                then if argument.difficulty ~= ""
                    then ("%s   %s"):format(argument.dungeon, argument.difficulty)
                    else title
                else title
            else title
        text2 = nil
        if context.ST then
            text2 = text .. "  |  stats: " .. tostring(context.ST.note or "idle")
            value2 = context.ST.failed
            text2 = if value2
                then if value2 > 0 then text2 .. (" (%d failed)"):format(context.ST.failed) else text2
                else text2
        else
            text2 = text .. "  |  stats: module not loaded"
        end
        argument = {
            title = title,
            description = description,
            color = helper8(argument2, content),
            fields = fields,
            author = helper13(),
            footer = { text = text2 },
            timestamp = helper14(),
        }
        helper9(argument, content)
        title, content = { username = name2(), embeds = { argument } }, helper29(argument3)
        if content then
            title.content = content
        end
        post(title)
    end
    local function helper34(argument, argument2)
        local value, value2 = helper7(argument2), {}
        if config.whBest ~= false then
            if value then
                local value3, value4 = #value2 + 1, { name = "Best drop", inline = true }
                value4.value, value2[value3] =
                    ("%s **%s**\10%s%s%s"):format(
                        sharedValue8[value.rarity] or sharedValue8.unknown,
                        tostring(value.name),
                        sharedValue11[value.rarity] or "Unsorted",
                        sharedValue12[value.cat] and " " .. sharedValue12[value.cat] or "",
                        helper17(value)
                    ),
                    value4
            end
        end
        value2[#value2 + 1] =
            { name = ("Loot (%d)"):format(#argument2), value = helper27(argument2, 0), inline = false }
        local value5 = {
            title = "Late drops",
            description = ("**%s** handed these over after the run closed."):format(argument.dungeon),
            color = 10181046,
            fields = value2,
            author = helper13(),
            footer = { text = text },
            timestamp = helper14(),
        }
        helper9(value5, value)
        argument, value2 = { username = name2(), embeds = { value5 } }, helper29(argument2)
        if value2 then
            argument.content = value2
        end
        post(argument)
    end
    local function helper35()
        return config.whMerge ~= false
            and type(writefile) == "function"
            and type(readfile) == "function"
            and type(listfiles) == "function"
            and type(delfile) == "function"
            and type(isfile) == "function"
    end
    webhooks.copyId = webhooks.copyId or sharedValue:GenerateGUID(false)
    webhooks.claimRun = function(argument, argument2, argument3)
        if not (helper35()) then
            return true
        end
        local value = (tostring(argument2 or "") .. tostring(argument3 or "")):gsub("[^%w]", "")
        if value == "" then
            return true
        end
        local value2 = ("HarvardLabs/data/postmark_%s_%s.json"):format(
            tostring(argument),
            string.sub(value, 1, 48)
        )
        local function helper32()
            local success, value3 = pcall(function()
                local value4 = argumentHelpers[108](readfile(value2))
                return sharedValue:JSONDecode(argumentHelpers:unpackValues(value4))
            end)
            return success and type(value3) == "table" and value3 or nil
        end
        argument = helper32()
        if argument then
            if os.time() - (tonumber(argument.at) or 0) < 7200 then
                if argument.by ~= webhooks.copyId then
                    return false
                elseif argument.sent then
                    return false
                end
            end
        end
        pcall(writefile, value2, sharedValue:JSONEncode({ at = os.time(), by = webhooks.copyId }))
        task.wait(0.3)
        argument = helper32()
        if argument then
            if argument.by ~= webhooks.copyId then
                return false
            end
        end
        pcall(
            writefile,
            value2,
            sharedValue:JSONEncode({ at = os.time(), by = webhooks.copyId, sent = true })
        )
        if os.clock() - (webhooks.markPruneAt or -math.huge) > 600 then
            webhooks.markPruneAt = os.clock()
            pcall(function()
                for index, entry in ipairs(listfiles("HarvardLabs/data")) do
                    local value3 = tostring(entry)
                    if value3:find("postmark_", 1, true) then
                        index, entry = pcall(function()
                            local value4 = argumentHelpers[108](readfile(value3))
                            return sharedValue:JSONDecode(argumentHelpers:unpackValues(value4))
                        end)
                        if index then
                            if type(entry) ~= "table" then
                                pcall(delfile, value3)
                            elseif os.time() - (tonumber(entry.at) or 0) > 7200 then
                                pcall(delfile, value3)
                            end
                        else
                            pcall(delfile, value3)
                        end
                    end
                end
            end)
        end
        return true
    end
    webhooks.byAccount = function(argument, argument2)
        local value = {}
        for index = 1, #argument, 1 do
            local value2 = argument[index].d
            local value3, value4 =
                type(value2.items) == "table" and value2.items or {},
                argument2 and tonumber(value2.level) or nil
            local value5 = ("%s  -  %d drop%s%s"):format(
                helper12(value2, index),
                #value3,
                #value3 == 1 and "" or "s",
                value4 and ("  -  Lv %d"):format(value4) or ""
            )
            value5 = if #value3 == 0
                then if tonumber(value2.bag)
                    then if tonumber(value2.bag) >= helper21()
                        then value5 .. ("  -  bag full (%d/%d)"):format(tonumber(value2.bag), helper21())
                        else value5
                    else value5
                else value5
            value[#value + 1] = value5
        end
        argument2 = table.concat(value, "\10")
        return if #argument2 > 1000 then argument2:sub(1, 990) .. "..." else argument2
    end
    local function helper36(argument, content, argument2)
        local value2, value3, value4, value5 = {}, {}, 0, false
        for index = 1, #argument2, 1 do
            local value6 = argument2[index].d.event and tonumber(argument2[index].d.candy)
            if value6 then
                value4, value5 = value4 + value6, true
            end
        end
        for index2 = 1, #argument2, 1 do
            local value7 = argument2[index2].d
            local value8 = type(value7.items) == "table" and value7.items or {}
            for index3 = 1, #value8, 1 do
                value2[#value2 + 1] = value8[index3]
            end
            local value9, value10, value11 = #value3 + 1, {}, helper12(value7, index2)
            value10.name = ("%s  -  %d drop%s"):format(value11, #value8, #value8 == 1 and "" or "s")
            value10.value = helper27(value8, tonumber(value7.cards) or 0)
            value10.inline = false
            value3[value9] = value10
            if #value8 == 0 then
                if tonumber(value7.bag) then
                    if tonumber(value7.bag) >= helper21() then
                        value3[#value3].value = ("nothing - bag full (%d/%d), drops are lost"):format(
                            tonumber(value7.bag),
                            helper21()
                        )
                    end
                end
            end
            if value7.event then
                if tonumber(value7.candy) then
                    if #value8 == 0 then
                        local value12, value13, value14, value15 =
                            #value3,
                            {},
                            helper12(value7, index2),
                            argumentHelpers[108](helper18(tonumber(value7.candy)))
                        value13.name = ("%s  -  %s candy"):format(
                            value14,
                            argumentHelpers:unpackValues(value15)
                        )
                        value10 = argumentHelpers[108](helper16(tonumber(value7.candyTotal) or 0))
                        value13.value = ("%s banked"):format(argumentHelpers:unpackValues(value10))
                        value13.inline = true
                        value3[value12] = value13
                    end
                end
            end
        end
        local value16, fields = helper7(value2), {}
        if config.whBest ~= false then
            if value16 then
                local value17, value18 = #fields + 1, { name = "Best drop", inline = true }
                value18.value, fields[value17] =
                    ("%s **%s**\10%s%s%s"):format(
                        sharedValue8[value16.rarity] or sharedValue8.unknown,
                        tostring(value16.name),
                        sharedValue11[value16.rarity] or "Unsorted",
                        sharedValue12[value16.cat] and " " .. sharedValue12[value16.cat] or "",
                        helper17(value16)
                    ),
                    value18
            end
        end
        if config.whWorth ~= false then
            if #value2 > 0 then
                local value19, value20 = #fields + 1, { name = "Haul value" }
                value20.value, value20.inline, fields[value19] =
                    "`" .. helper16(helper28(value2)) .. "` gold", true, value20
            end
        end
        if config.whTally ~= false and not value5 then
            fields[#fields + 1] = {
                name = ("%d account%s  -  %d drop%s"):format(
                    #argument2,
                    #argument2 == 1 and "" or "s",
                    #value2,
                    #value2 == 1 and "" or "s"
                ),
                value = helper27(value2, 0),
                inline = false,
            }
        else
            for index4 = 1, #value3, 1 do
                fields[#fields + 1] = value3[index4]
            end
        end
        if value5 then
            fields[#fields + 1] = { name = "Candy, every account", value = helper18(value4), inline = false }
        end
        if config.whWins ~= false then
            local value21, value =
                (webhooks.wins or 0) + (webhooks.losses or 0),
                ("%d W / %d L"):format(webhooks.wins or 0, webhooks.losses or 0)
            value = if config.whRatio ~= false
                then if value21 > 0
                    then value .. ("   %d%%"):format(math.floor((webhooks.wins or 0) / value21 * 100 + 0.5))
                    else value
                else value
            fields[#fields + 1] = { name = "Session", value = value, inline = true }
        end
        value3 = argument.dungeon
        local value22 = {
            title = if config.whDungeon ~= false
                then if argument.difficulty
                    then if argument.difficulty ~= ""
                        then ("%s   %s"):format(argument.dungeon, argument.difficulty)
                        else value3
                    else value3
                else value3,
            description = ("**%s**%s   `%d account%s`   %s"):format(
                content and "VICTORY" or "DEFEAT",
                config.whTime ~= false and "   `" .. helper15(webhooks.runSecs(argument)) .. "`" or "",
                #argument2,
                #argument2 == 1 and "" or "s",
                value5 and ("`%s candy in all`"):format(helper18(value4))
                    or ("`%d drop%s`"):format(#value2, #value2 == 1 and "" or "s")
            ),
            color = helper8(content, value16),
            fields = fields,
            footer = { text = text },
            timestamp = helper14(),
        }
        helper9(value22, value16)
        value16, content = { username = name2(), embeds = { value22 } }, helper29(value2)
        if content then
            value16.content = content
        end
        post(value16)
    end
    local function helper37(argument, won, argument2)
        if not (helper35()) then
            return false
        end
        local value = sharedValue2.LocalPlayer
        local who = value and value.Name or nil
        if not who then
            return false
        end
        local items = {}
        for index = 1, #argument2, 1 do
            local value2 = argument2[index]
            items[index] = {
                name = value2.name,
                rarity = value2.rarity,
                cat = value2.cat,
                sell = value2.sell,
                level = value2.level,
                phys = value2.phys,
                spell = value2.spell,
                hp = value2.hp,
                upMax = value2.upMax,
                cur = value2.cur,
            }
        end
        local value3 = { who = who }
        value3.display = ("%s (@%s)"):format(value.DisplayName, who)
        value3.hidden = helper11() or nil
        value3.won = won
        value3.job = game.JobId
        value3.dungeon = argument.dungeon
        value3.difficulty = argument.difficulty
        value3.cards = argument.cards
        value3.at = os.time()
        value3.items = items
        value3.secs = webhooks.runSecs(argument)
        value3.deaths = argument.deaths or 0
        value3.bag = argument.invTotal
        value3.event = argument.event
        value3.candy = argument.candy and helper30() and helper30() - argument.candy or nil
        value3.candyTotal = helper30()
        items, argument2 = pcall(function()
            return sharedValue:JSONEncode(value3)
        end)
        if not items then
            return false
        end
        items = "HarvardLabs/data/haul_" .. who .. ".json"
        if not (pcall(writefile, items, argument2)) then
            return false
        end
        local value4, value5 = { [who] = true }, 1
        for index2, entry in ipairs(sharedValue2:GetPlayers()) do
            if entry ~= value then
                argument2 = context.AF and context.AF.presence and context.AF.presence(entry.Name, 60)
                if argument2 then
                    if argument2.job == game.JobId then
                        if not value4[entry.Name] then
                            value4[entry.Name] = true
                            value5 += 1
                        end
                    end
                end
            end
        end
        if value5 < 2 then
            return false
        end
        value = who
        for entry2 in pairs(value4) do
            value = if entry2 < value then entry2 else value
        end
        webhooks.pendingUntil = nil
        local value6 = tonumber(config.whMergeStale) or 240
        local function helper32()
            local value7, value8 = {}
            local value9, path, value10 = {}, pcall(listfiles, "HarvardLabs/data")
            if path then
                if type(value10) ~= "table" then
                    return value7, value8, value9
                end
            else
                return value7, value8, value9
            end
            for index3 = 1, #value10, 1 do
                path = tostring(value10[index3])
                if path:find("haul_", 1, true) and path:sub(-5) == ".json" then
                    local success, value11 = pcall(readfile, path)
                    index3 = nil
                    if success then
                        local success2, value12 = pcall(function()
                            return sharedValue:JSONDecode(value11)
                        end)
                        index3 = if success2
                            then if type(value12) == "table"
                                then if type(value12.who) == "string" then value12 else index3
                                else index3
                            else index3
                    end
                    if not (index3 and index3.job and index3.job ~= game.JobId) then
                        if index3 then
                            if os.time() - (tonumber(index3.at) or 0) <= value6 then
                                value7[#value7 + 1] = { path = path, d = index3 }
                                value9[index3.who] = true
                                value8 = if value8 == nil
                                    then index3.who
                                    else if index3.who < value8 then index3.who else value8
                            else
                                if index3 then
                                    pcall(delfile, path)
                                end
                            end
                        else
                            if index3 then
                                pcall(delfile, path)
                            end
                        end
                    end
                end
            end
            return value7, value8, value9
        end
        local function helper38(argument3)
            table.sort(argument3, function(argument4, argument5)
                return argument4.d.who < argument5.d.who
            end)
            if webhooks.claimRun("party", game.JobId, argument.dungeon) then
                pcall(helper36, argument, won, argument3)
            end
            for index3 = 1, #argument3, 1 do
                pcall(delfile, argument3[index3].path)
            end
        end
        argument2 = tonumber(config.whMergeMax) or 30
        if value ~= who then
            task.wait(argument2 + (tonumber(config.whMergeGrace) or 8))
            local success3, value13 = pcall(isfile, items)
            if success3 then
                if not value13 then
                    return true
                end
            end
            success3, value13 = helper32()
            if #success3 < 2 then
                pcall(delfile, items)
                return false
            end
            if value13 ~= who then
                return true
            end
            helper38(success3)
            return true
        end
        who, value = os.clock(), {}
        while true do
            task.wait(0.5)
            local success4, value14 = pcall(isfile, items)
            if success4 then
                if not value14 then
                    return true
                end
            end
            local value15, C, value16 = helper32()
            success4 = true
            for entry3 in pairs(value4) do
                if not value16[entry3] then
                    success4 = false
                    break
                end
            end
            if success4 then
                value = value15
                break
            elseif os.clock() - who >= argument2 then
                value = value15
                break
            end
            value = value15
        end
        if #value < 2 then
            pcall(delfile, items)
            return false
        end
        helper38(value)
        return true
    end
    local function helper39(argument)
        local value, value2, value3, value4, value5, value6, value7, value8 = {}, {}, 0, 0, 0, 0
        for index = 1, #argument, 1 do
            local value9 = argument[index].d
            local value10 = type(value9.items) == "table" and value9.items or {}
            for index2 = 1, #value10, 1 do
                value[#value + 1] = value10[index2]
            end
            local value11, value12, value13, value14 =
                tonumber(value9.level), #value2 + 1, {}, helper12(value9, index)
            value13.name = ("%s%s  -  %d drop%s"):format(
                value14,
                value11 and (("  -  Lv %d"):format(value11)) or "",
                #value10,
                #value10 == 1 and "" or "s"
            )
            value13.value = helper27(value10, tonumber(value9.cards) or 0)
            value13.inline = false
            value2[value12] = value13
            if #value10 == 0 then
                if tonumber(value9.bag) then
                    if tonumber(value9.bag) >= helper21() then
                        value2[#value2].value = ("nothing - bag full (%d/%d), drops are lost"):format(
                            tonumber(value9.bag),
                            helper21()
                        )
                    end
                end
            end
            value3 += tonumber(value9.deaths) or 0
            value4 = math.max(value4, tonumber(value9.clears) or 0)
            value5 += tonumber(value9.gold) or 0
            value6 += tonumber(value9.gems) or 0
            value14, value10 = tonumber(value9.fight), tonumber(value9.run)
            value7, value8 =
                if value14
                    then if value7 == nil then value14 else if value14 > value7 then value14 else value7
                    else value7,
                if value10
                    then if value8 == nil then value10 else if value10 > value8 then value10 else value8
                    else value8
        end
        local value15, value16 = helper7(value), {}
        if value7 then
            value16[#value16 + 1] = ("`fight %s`"):format(helper15(value7))
        end
        if config.whDeaths ~= false then
            value16[#value16 + 1] = value3 <= 0 and "`no deaths`"
                or ("`%d death%s`"):format(value3, value3 == 1 and "" or "s")
        end
        if value8 then
            value16[#value16 + 1] = ("`run %s`"):format(helper15(value8))
        end
        value16[#value16 + 1] = ("`%d account%s`"):format(#argument, #argument == 1 and "" or "s")
        value16[#value16 + 1] = ("`%d drop%s`"):format(#value, #value == 1 and "" or "s")
        local fields = {}
        if config.whBest ~= false then
            if value15 then
                local value17, value18 = #fields + 1, { name = "Best drop", inline = true }
                value18.value, fields[value17] =
                    ("%s **%s**\10%s%s%s"):format(
                        sharedValue8[value15.rarity] or sharedValue8.unknown,
                        tostring(value15.name),
                        sharedValue11[value15.rarity] or "Unsorted",
                        sharedValue12[value15.cat] and " " .. sharedValue12[value15.cat] or "",
                        helper17(value15)
                    ),
                    value18
            end
        end
        if config.whWorth ~= false then
            if #value > 0 then
                local value19, value20 = #fields + 1, { name = "Haul value" }
                value20.value, value20.inline, fields[value19] =
                    "`" .. helper16(helper28(value)) .. "` gold", true, value20
            end
        end
        if config.whGold ~= false and (value5 ~= 0 or value6 ~= 0) then
            local value21, value22 = #fields + 1, { name = "Earned" }
            value22.value, value22.inline, fields[value21] =
                ("%s gold\10%s gems"):format(helper18(value5), helper18(value6)), true, value22
        end
        if config.whTally ~= false then
            fields[#fields + 1] = {
                name = ("%d account%s  -  %d drop%s"):format(
                    #argument,
                    #argument == 1 and "" or "s",
                    #value,
                    #value == 1 and "" or "s"
                ),
                value = helper27(value, 0),
                inline = false,
            }
        else
            for index3 = 1, #value2, 1 do
                fields[#fields + 1] = value2[index3]
            end
        end
        local value23, content = #fields + 1, { name = "Session" }
        content.value, content.inline, fields[value23] =
            ("%d Rodin clear%s"):format(value4, value4 == 1 and "" or "s"), true, content
        value23 = argument[1].d
        argument = {
            title = if value23.dungeon
                then ("%s   %s   %s"):format(
                    "Odin Reincarnation",
                    tostring(value23.dungeon),
                    tostring(value23.difficulty or "")
                )
                else "Odin Reincarnation",
            description = "**RODIN CLEARED**"
                .. (#value16 > 0 and "   " .. table.concat(value16, "   ") or ""),
            color = value15 and helper8(true, value15) or sharedValue7,
            fields = fields,
            footer = { text = text },
            timestamp = helper14(),
        }
        helper9(argument, value15)
        value16, content = { username = name2(), embeds = { argument } }, helper29(value)
        if content then
            value16.content = content
        end
        post(value16)
    end
    webhooks.rodinMerge = function(argument)
        if not (helper35()) then
            return false
        end
        local value = sharedValue2.LocalPlayer
        local who = value and value.Name or nil
        if not who then
            return false
        end
        argument.who = who
        argument.display = ("%s (@%s)"):format(value.DisplayName, who)
        argument.hidden = helper11() or nil
        argument.at = os.time()
        argument.job = game.JobId
        local success, path = pcall(function()
            return sharedValue:JSONEncode(argument)
        end)
        if not success then
            return false
        end
        value = "HarvardLabs/data/rodin_" .. who .. ".json"
        if not (pcall(writefile, value, path)) then
            return false
        end
        task.wait(tonumber(config.whRodinMergeWait) or 4)
        path, success = pcall(isfile, value)
        if path then
            if not success then
                return true
            end
        end
        path, success = pcall(listfiles, "HarvardLabs/data")
        if path then
            if type(success) ~= "table" then
                pcall(delfile, value)
                return false
            end
        else
            pcall(delfile, value)
            return false
        end
        local value2, success2, value3 = {}, tonumber(config.whMergeStale) or 240
        for index = 1, #success, 1 do
            path = tostring(success[index])
            if path:find("rodin_", 1, true) and path:sub(-5) == ".json" then
                local success3, value4 = pcall(readfile, path)
                index = nil
                if success3 then
                    local success4, value5 = pcall(function()
                        return sharedValue:JSONDecode(value4)
                    end)
                    index = if success4
                        then if type(value5) == "table"
                            then if type(value5.who) == "string" then value5 else index
                            else index
                        else index
                end
                if not (index and index.job and index.job ~= game.JobId) then
                    if index then
                        if os.time() - (tonumber(index.at) or 0) <= success2 then
                            value2[#value2 + 1] = { path = path, d = index }
                            value3 = if value3 == nil
                                then index.who
                                else if index.who < value3 then index.who else value3
                        else
                            if index then
                                pcall(delfile, path)
                            end
                        end
                    else
                        if index then
                            pcall(delfile, path)
                        end
                    end
                end
            end
        end
        if #value2 < 2 then
            pcall(delfile, value)
            return false
        end
        if value3 ~= who then
            task.wait(tonumber(config.whMergeGrace) or 4)
            success2, path = pcall(isfile, value)
            if success2 then
                if not path then
                    return true
                end
            else
                return true
            end
            pcall(delfile, value)
            return false
        end
        table.sort(value2, function(argument2, argument3)
            return argument2.d.who < argument3.d.who
        end)
        for index2 = 1, #value2, 1 do
            pcall(delfile, value2[index2].path)
        end
        pcall(helper39, value2)
        return true
    end
    webhooks.rodinRecover = function()
        if helper35() then
            if config.whRodin == false then
                return
            end
        else
            return
        end
        local value = sharedValue2.LocalPlayer
        local value2 = value and value.Name or nil
        if not value2 then
            return
        end
        value = "HarvardLabs/data/rodin_" .. value2 .. ".json"
        local success, value3 = pcall(isfile, value)
        if success then
            if not value3 then
                return
            end
        else
            return
        end
        local function helper32()
            local value4, value5, value6 = {}
            local path, value7 = pcall(listfiles, "HarvardLabs/data")
            if path then
                if type(value7) ~= "table" then
                    return value4, value5, value6
                end
            else
                return value4, value5, value6
            end
            local value8, value9 =
                (tonumber(config.whRodinMergeWait) or 4) + (tonumber(config.whMergeGrace) or 4) + 3,
                tonumber(config.whRodinRecoverMax) or 3600
            for index = 1, #value7, 1 do
                path = tostring(value7[index])
                if path:find("rodin_", 1, true) and path:sub(-5) == ".json" then
                    local success2, value10 = pcall(readfile, path)
                    index = nil
                    if success2 then
                        local success3, value11 = pcall(function()
                            return sharedValue:JSONDecode(value10)
                        end)
                        index = if success3
                            then if type(value11) == "table"
                                then if type(value11.who) == "string" then value11 else index
                                else index
                            else index
                    end
                    success2 = index and os.time() - (tonumber(index.at) or 0) or nil
                    if index then
                        if (success2 or math.huge) > value9 then
                            pcall(delfile, path)
                        else
                            if success2 >= value8 then
                                value4[#value4 + 1] = { path = path, d = index }
                                value5, value6 =
                                    if value5 == nil
                                        then index.who
                                        else if index.who < value5 then index.who else value5,
                                    if index.who == value2 then index else value6
                            end
                        end
                    else
                        pcall(delfile, path)
                    end
                end
            end
            return value4, value5, value6
        end
        local value12, value13, value14 = helper32()
        if value14 then
            if #value12 == 0 then
                return
            end
        else
            return
        end
        if value14.job then
            value3 = {}
            value13 = nil
            for index2, entry in ipairs(value12) do
                if entry.d.job == nil or entry.d.job == value14.job then
                    value3[#value3 + 1] = entry
                    value13 = if value13 == nil
                        then entry.d.who
                        else if entry.d.who < value13 then entry.d.who else value13
                end
            end
            value12 = value3
        end
        if value13 ~= value2 then
            task.wait(tonumber(config.whMergeGrace) or 4)
            success, value14 = pcall(isfile, value)
            if success then
                if not value14 then
                    return
                end
            else
                return
            end
            local value15, value16
            value15, value16, value16 = helper32()
            if value16 then
                if #value15 == 0 then
                    return
                end
            else
                return
            end
            value12 = value15
        end
        table.sort(value12, function(argument, argument2)
            return argument.d.who < argument2.d.who
        end)
        for index3 = 1, #value12, 1 do
            pcall(delfile, value12[index3].path)
        end
        pcall(helper39, value12)
        if context.log then
            context.log(
                "Webhook",
                ("sent %d Rodin clear%s left unsent"):format(#value12, #value12 == 1 and "" or "s")
            )
        end
    end
    local function helper40(title, description, color3, argument, argument2)
        local value = { over = false, sent = false }
        local value2 = tostring(config.webhookUrl or "")
        if config.webhook == false or config.whModDetect == false and not argument2 then
            value.over = true
            return value
        elseif value2 == "" then
            value.over = true
            return value
        end
        local success, value3 = pcall(function()
            local value4 = {
                username = name2(),
                embeds = {
                    {
                        title = title,
                        description = description,
                        color = color3,
                        author = helper13(),
                        footer = { text = text },
                        timestamp = helper14(),
                    },
                },
            }
            return sharedValue:JSONEncode(value4)
        end)
        if not success then
            value.over = true
            return value
        end
        task.spawn(function()
            for index = 1, 3, 1 do
                local value4, value5, value6 = helper3(value2, value3)
                if value4 then
                    value.sent = true
                    break
                end
                if index == 3 then
                    if context.log then
                        context.log("Webhook", argument .. " alert gave up: " .. tostring(value5))
                    end
                    break
                end
                task.wait(math.min(value6 or index, 2))
            end
            value.over = true
        end)
        return value
    end
    webhooks.newSave = function(argument, argument2, argument3, argument4)
        local value = helper10() and "A leecher" or tostring(argument)
        return helper40(
            ("%s started a new save"):format(value),
            ("save %s at **Lv %d** -> fresh save in slot %s at Lv 1"):format(
                tostring(argument3 or "?"),
                tonumber(argument2) or 0,
                tostring(argument4 or "?")
            ),
            sharedValue7,
            "new save"
        )
    end
    webhooks.modDetected = function(argument, M, M, M)
        if not (webhooks.partyPoster()) then
            return { over = true, sent = false }
        end
        return helper40(
            "Non whitelisted player detected",
            ("**%s**, a non whitelisted player joined your dungeon mid round. We have taken preventative measures to ensure safety. Your account may potentially be tracked."):format(
                tostring(argument or "someone")
            ),
            color2,
            "mod detection"
        )
    end
    webhooks.dropRest = function(argument, argument2, argument3, argument4)
        local value = math.floor(tonumber(argument4) or os.time())
        argument4 = math.max(0, math.floor((value - os.time()) / 60 + 0.5))
        return helper40(
            "Mod detection: waiting after a good drop",
            ("**%s** (%s) dropped - left the run and waits %d min before queueing again: requeuing %s <t:%d:R>"):format(
                tostring(argument or "?"),
                tostring(argument2 or "?"),
                argument4,
                tostring(argument3 or "?"),
                value
            ),
            sharedValue7,
            "mod detection"
        )
    end
    local function helper41(argument)
        argument = math.max(0, math.floor(tonumber(argument) or 0))
        if argument >= 3600 then
            local value, value2 = math.floor(argument / 3600), math.floor(argument / 60) % 60
            return ("%dh %02dm"):format(value, value2)
        end
        if argument >= 60 then
            local value3 = argumentHelpers[108](math.floor(argument / 60 + 0.5))
            return ("%d min"):format(argumentHelpers:unpackValues(value3))
        end
        return ("%ds"):format(argument)
    end
    webhooks.breakRest = function(argument, argument2, argument3, argument4, argument5)
        local value = { over = false, sent = false }
        if argument5 then
            value.over = true
            return value
        elseif config.webhook == false then
            value.over = true
            return value
        elseif config.whBreaks == false then
            value.over = true
            return value
        elseif tostring(config.webhookUrl or "") == "" then
            value.over = true
            return value
        end
        local value2, value3 = sharedValue2.LocalPlayer and sharedValue2.LocalPlayer.Name or "?", "solo"
        pcall(function()
            local value4 = context.AF and context.AF.load and context.AF.load()
            if type(value4) == "table" then
                if value4.id then
                    value3 = string.sub(tostring(value4.id), 1, 8)
                end
            end
        end)
        local value5 = "HarvardLabs/data/breakpost_" .. value3 .. ".json"
        local function helper32()
            local success, value4 = pcall(function()
                local value6 = argumentHelpers[108](readfile(value5))
                return sharedValue:JSONDecode(argumentHelpers:unpackValues(value6))
            end)
            return success and type(value4) == "table" and value4 or nil
        end
        argument5 = helper32()
        if argument5 then
            if os.time() - (tonumber(argument5.at) or 0) < 90 then
                if argument5.by ~= value2 then
                    value.over = true
                    return value
                end
            end
        end
        local protectedCall, value7, value8 = pcall, writefile, {}
        value8.at, value8.by = os.time(), value2
        protectedCall(value7, value5, sharedValue:JSONEncode(value8))
        task.spawn(function()
            task.wait(0.8)
            local value4 = helper32()
            if value4 then
                if value4.by ~= value2 then
                    value.over = true
                    return
                end
            end
            value4 = math.floor(tonumber(argument2) or os.time())
            local value6, value9
            if argument4 then
                value6, value9 =
                    "Test break",
                    ("A **%s** test rest from Mod detection > Breaks - a normal break, not a detection. Back to farming <t:%d:R>."):format(
                        helper41(value4 - os.time()),
                        value4
                    )
            else
                value6, value9 =
                    "Taking a scheduled break",
                    ("Farmed **%s** - resting **%s** before queueing again: requeuing %s <t:%d:R>."):format(
                        helper41(argument),
                        helper41(value4 - os.time()),
                        tostring(argument3 or "?"),
                        value4
                    ) .. "\10A normal break from Mod detection > Breaks - not a detection."
            end
            local value10, now = helper40(value6, value9, 5793266, "break", true), os.clock()
            while true do
                value4 = value10.over
                if not (if value4 then not value4 else os.clock() - now < 12) then
                    break
                end
                task.wait(0.2)
            end
            value.sent = value10.sent
            value.over = true
        end)
        return value
    end
    local sharedValue24 = string.char(226, 150, 136)
    local sharedValue25 = string.char(226, 150, 145)
    local function helper42()
        local localPlayer, value = sharedValue2.LocalPlayer, helper19("Level") or 0
        local value2, value3 =
            localPlayer and (localPlayer:FindFirstChild("XP")),
            localPlayer and (localPlayer:FindFirstChild("XPNeeded"))
        local value4, value5 = value2 and tonumber(value2.Value) or 0, value3 and tonumber(value3.Value) or 0
        value3, value2 =
            value5 > 0 and math.clamp(value4 / value5, 0, 1) or 0, tonumber(config.levelGoal) or 186
        return value,
            value3,
            value >= value2 and 1 or math.clamp((value - 1 + value3) / (value2 - 1), 0, 1),
            value2
    end
    local function helper43(argument, argument2, argument3, argument4)
        argument2 = math.floor(argument3 * 18 + 0.5)
        local value = string.rep(sharedValue24, argument2) .. string.rep(sharedValue25, 18 - argument2)
        if argument >= argument4 then
            return ("`%s`  done   **Lv %d**"):format(value, argument)
        end
        argument2 = math.floor(argument3 * 100)
        return ("`%s`  %d%%   **Lv %d** -> %d"):format(value, argument2, argument, argument4)
    end
    local function helper44(argument)
        local value2 = argument[1].d
        local value3 = #argument
        for index = 1, value3, 1 do
            if tostring(argument[index].d.role) ~= "alt" then
                value2 = argument[index].d
                break
            end
        end
        local value4, fields = value2.won ~= false, {}
        local value5, value6, value7 = helper10(), 0, 0
        for index2 = 1, #argument, 1 do
            if tostring(argument[index2].d.role) == "alt" then
                value6 = value6 + 1
            else
                value7 = value7 + 1
            end
        end
        local value8, value9 = 0, 0
        for index3 = 1, #argument, 1 do
            local value10, name3 = argument[index3].d
            if value5 then
                if tostring(value10.role) == "alt" then
                    value8 += 1
                    name3 = (("Leech %d"):format(value8))
                else
                    value9 += 1
                    name3 = value7 > 1 and ("Carry %d"):format(value9) or "Carry"
                end
            else
                name3 = ("%s%s"):format(
                    tostring(value10.display or value10.who),
                    value10.role and "  -  " .. tostring(value10.role) or ""
                )
            end
            value3, index3 = #fields + 1, { name = name3 }
            index3.value, index3.inline, fields[value3] =
                helper43(
                    tonumber(value10.level) or 0,
                    tonumber(value10.frac) or 0,
                    tonumber(value10.p) or 0,
                    tonumber(value10.cap) or 186
                ),
                false,
                index3
        end
        value5 = {}
        if config.whTime ~= false then
            if tonumber(value2.secs) then
                value5[#value5 + 1] = "`" .. helper15(tonumber(value2.secs)) .. "`"
            end
        end
        if config.whDeaths ~= false then
            value3 = 0
            for index4 = 1, #argument, 1 do
                value3 = if tostring(argument[index4].d.role) ~= "alt"
                    then value3 + (tonumber(argument[index4].d.deaths) or 0)
                    else value3
            end
            value5[#value5 + 1] = value3 <= 0 and "`no deaths`"
                or ("`%d death%s`"):format(value3, value3 == 1 and "" or "s")
        end
        if config.whWins ~= false then
            local value11, value =
                (webhooks.wins or 0) + (webhooks.losses or 0),
                ("%d W / %d L"):format(webhooks.wins or 0, webhooks.losses or 0)
            value = if config.whRatio ~= false
                then if value11 > 0
                    then value .. ("   %d%%"):format(math.floor((webhooks.wins or 0) / value11 * 100 + 0.5))
                    else value
                else value
            fields[#fields + 1] = { name = "Session", value = value, inline = true }
        end
        if config.whSessionTime ~= false then
            if webhooks.sessionStart then
                local value12, value13 = #fields + 1, { name = "Session playtime" }
                value13.value, value13.inline, fields[value12] =
                    "`" .. helper15(math.max(0, os.time() - webhooks.sessionStart)) .. "`", true, value13
            end
        end
        value3 = string.char(226, 128, 139)
        fields[#fields + 1] = { name = value3, value = value3, inline = true }
        if config.whEta ~= false then
            pcall(function()
                local value14
                local pts = #argument
                local value15 = 186
                for index5 = 1, pts, 1 do
                    local value16 = argument[index5].d
                    if tostring(value16.role) == "alt" then
                        index5 = (tonumber(value16.level) or 0)
                            + math.clamp(tonumber(value16.frac) or 0, 0, 0.999)
                        if not value14 or index5 < value14 then
                            value14 = index5
                            value15 = tonumber(value16.cap) or 186
                        end
                    end
                end
                if not value14 then
                    return
                end
                pts = context.AF and context.AF.newSaveAt and context.AF.newSaveAt()
                if pts then
                    local value17 = false
                    for index6, entry in ipairs(context.AF.load().accounts or {}) do
                        if entry.enabled ~= false then
                            if entry.role == "leech" then
                                index6 = context.AF.presence(entry.name, 86400)
                                value17 = if index6
                                    then if tonumber(index6.slot)
                                        then if tonumber(index6.slot) > 1 then true else value17
                                        else value17
                                    else value17
                            end
                        end
                    end
                    pts = if value17 then nil else pts
                end
                value15 = if pts then if value14 < pts then pts else value15 else value15
                local value18, value19 =
                    context.AF and context.AF.partyFile and context.AF.partyFile("af_levelhist")
                        or "HarvardLabs/data/af_levelhist.json",
                    {}
                pcall(function()
                    value19 = sharedValue:JSONDecode(readfile(value18))
                end)
                if type(value19) ~= "table" or value19.session ~= webhooks.sessionStart then
                    value19 = {}
                    value19.session = webhooks.sessionStart
                    value19.pts = {}
                end
                local timestamp, pts2 = os.time(), value19.pts
                if #pts2 > 0 then
                    if value14 < pts2[#pts2].L - 0.5 then
                        pts = {}
                        value19.pts = pts
                        pts2 = pts
                    end
                end
                pts2[#pts2 + 1] = { t = timestamp, L = value14 }
                while #pts2 > 300 do
                    table.remove(pts2, 1)
                end
                pcall(function()
                    writefile(value18, sharedValue:JSONEncode(value19))
                end)
                pts = nil
                for index7 = #pts2 - 1, 1, -1 do
                    pts = pts2[index7]
                    if timestamp - pts.t >= 1800 then
                        if value14 - pts.L >= 5 then
                            break
                        end
                    end
                end
                local function helper32(argument2)
                    local value20 = argument2 < 3600 and 1 or 10
                    local value21 = math.floor(argument2 / 60 / value20 + 0.5) * value20
                    argument2 = math.floor(value21 / 60)
                    return ("~%d:%02d"):format(argument2, value21 % 60)
                end
                if value14 >= value15 then
                    fields[#fields + 1] =
                        { name = ("ETA to %d"):format(value15), value = "`reached`", inline = false }
                elseif (if pts then timestamp - pts.t < 600 else not pts) or value14 - pts.L < 1 then
                    fields[#fields + 1] =
                        { name = ("ETA to %d"):format(value15), value = "`gathering data`", inline = false }
                else
                    local value22 = config.etaRefCurve
                        or {
                            { 1, 0 },
                            { 6, 615 },
                            { 10, 754 },
                            { 13, 889 },
                            { 25, 1504 },
                            { 28, 1796 },
                            { 33, 2275 },
                            { 41, 2598 },
                            { 45, 2824 },
                            { 50, 3139 },
                            { 55, 3457 },
                            { 60, 3783 },
                            { 65, 4924 },
                            { 70, 6075 },
                            { 75, 7303 },
                            { 80, 8502 },
                            { 85, 9710 },
                            { 90, 11063 },
                            { 95, 12456 },
                        }
                    local value23, value24 = config.xpGrowth or 1.13, 175
                    pcall(function()
                        local value20 = context.AF and context.AF.load()
                        local value21 = value20 and context.AF.LEVELS[value20.cap]
                        if value21 then
                            value20 = 0
                            for key, entry2 in pairs(value21) do
                                value20 = if entry2 > value20 then entry2 else value20
                            end
                            if value20 > 0 then
                                value24 = value20
                            end
                        end
                    end)
                    if value24 < 175 then
                        value24 = 175
                    end
                    if value24 < value14 then
                        value24 = value14
                    end
                    local value25 = tonumber(config.etaPerLevelHigh) or 260
                    local function helper38(argument2)
                        if argument2 <= value22[1][1] then
                            return 0
                        end
                        for index8 = 2, #value22, 1 do
                            local value20, value21 = value22[index8 - 1], value22[index8]
                            if argument2 <= value21[1] then
                                return value20[2]
                                    + (value21[2] - value20[2])
                                        * (argument2 - value20[1])
                                        / (value21[1] - value20[1])
                            end
                        end
                        local value26 = value22[#value22]
                        local value27, value28 = value26[1], value26[2]
                        while value27 < argument2 do
                            local value29, value30 =
                                math.min(1, argument2 - value27),
                                value25 * (value27 > value24 and value23 ^ (value27 - value24) or 1)
                            value28 += value30 * value29
                            value27 = value27 + value29
                        end
                        return value28
                    end
                    local value31, value32 = (helper38(value14) - helper38(pts.L))
                        / math.max(timestamp - pts.t, 1)
                    if value31 < 0.2 then
                        value31 = 0.2
                        value32 = value31
                    else
                        if value31 > 5 then
                            value31 = 5
                        end
                        value32 = value31
                    end
                    local value33 = tonumber(config.newSaveBoost) or 1.4
                    local value34, value35 = tonumber(config.etaXpLimitedFrom) or 60
                    pcall(function()
                        local iterateArray, value20 = ipairs, context.AF.load().accounts or {}
                        for key, entry2 in iterateArray(value20) do
                            if entry2.enabled ~= false then
                                if entry2.role == "leech" then
                                    key = context.AF.presence(entry2.name, 86400)
                                    if key then
                                        if tonumber(key.slot) then
                                            if tonumber(key.slot) > 1 then
                                                if tonumber(key.xpBoost) then
                                                    local value21 = tonumber(key.xpBoost)
                                                    if value35 == nil then
                                                        value35 = value21
                                                    elseif value21 < value35 then
                                                        value35 = value21
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    local value36 = value35 and value14 < value34 and value33 or value32
                    local function helper45(argument2, argument3, argument4, argument5, argument6)
                        argument4 = argument4 or value32
                        local value20 = argument5 or value36
                        argument6 = if argument6 == nil then value35 else argument6
                        local value21, value26, value27, value28 = argument4, value20, argument2, 0
                        while value27 < argument3 do
                            argument2 = math.min(math.floor(value27) + 1, argument3)
                            value20 = value27 < value34 and value21 or value26
                            value20 = if argument6
                                then if value28 > argument6 then value20 / value33 else value20
                                else value20
                            value27, value28 =
                                argument2, value28 + (helper38(argument2) - helper38(value27)) / value20
                        end
                        return value28
                    end
                    local value37, value38
                    if value14 >= value34 and value15 >= 186 then
                        local value39, value40 = {}, pairs
                        local value41 = context.AF and context.AF.LEVELS or {}
                        for key2, entry3 in value40(value41) do
                            for key3, entry4 in pairs(entry3) do
                                if entry4 <= value24 then
                                    value39[#value39 + 1] = entry4
                                end
                            end
                        end
                        table.sort(value39)
                        local function helper46(argument2)
                            local value20 = 1
                            for index8, entry2 in ipairs(value39) do
                                value20 = if entry2 <= argument2 then entry2 else value20
                            end
                            return value20
                        end
                        local value42 = tonumber(config.xpBonusFrom) or 140
                        local value43 = tonumber(config.xpBonusMul) or 1.5
                        local function helper47(argument2)
                            local value20 = helper46(argument2)
                            return value23 ^ (argument2 - value20) / (value20 >= value42 and value43 or 1)
                        end
                        local function helper48(argument2, argument3)
                            local value20, value21 = argument2, 0
                            while value20 < argument3 do
                                argument2 = math.min(math.floor(value20) + 1, argument3)
                                value20, value21 =
                                    argument2, value21 + helper47(math.floor(value20)) * (argument2 - value20)
                            end
                            return value21
                        end
                        value41, value40 = 0, 0
                        for index9 = #pts2, 2, -1 do
                            local value44, value45 = pts2[index9 - 1], pts2[index9]
                            if timestamp - value45.t > (tonumber(config.etaWindow) or 2700) then
                                break
                            end
                            index9 = value45.t - value44.t
                            if index9 > 0 then
                                if index9 <= (tonumber(config.etaStallGap) or 420) then
                                    if value45.L > value44.L then
                                        if value44.L >= value34 then
                                            local value46, value47 =
                                                value41 + index9, value40 + helper48(value44.L, value45.L)
                                            value41, value40 = value46, value47
                                        end
                                    end
                                end
                            end
                        end
                        if value40 > 0 and value41 >= 300 then
                            local value48 = value41 / value40
                            helper45 = function(argument2, argument3)
                                local value20, value21 = argument2, 0
                                while value20 < argument3 do
                                    argument2 = math.min(math.floor(value20) + 1, argument3)
                                    value20, value21 =
                                        argument2,
                                        value21
                                            + helper47(math.floor(value20))
                                                * (argument2 - value20)
                                                * (value35 and value21 > value35 and value48 * value33 or value48)
                                end
                                return value21
                            end
                            value37 = helper47(math.floor(value14)) * value48 / 60
                        end
                        value38 = helper45
                    else
                        value38 = helper45
                    end
                    local value49 = value37
                        or (helper38(math.floor(value14) + 1) - helper38(math.floor(value14)))
                            / (value14 < value34 and value32 or value36)
                            / 60
                    local value50, value51, inline, value52, value53 =
                        ("  (%.1f min/level now, Lv %d)"):format(value49, math.floor(value14)),
                        value38(value14, value15),
                        value15 < 186,
                        #fields + 1,
                        { name = ("ETA to %d"):format(value15) }
                    value53.value, value53.inline, fields[value52] =
                        "`" .. helper32(value51) .. "`" .. value50, inline, value53
                    if value15 < 186 then
                        value50, value53, value52 =
                            value51 + value38(
                                1,
                                186,
                                value32 * (tonumber(config.newSaveLowK) or 1.4),
                                value32 * value33,
                                36000
                            ),
                            #fields + 1,
                            { name = "ETA to 186" }
                        value52.value, value52.inline, fields[value53] =
                            "`" .. helper32(value50) .. "`", true, value52
                    end
                    pcall(function()
                        local value20 = context.AF
                        if value20 then
                            if not value20.LEVELS then
                                return
                            end
                        else
                            return
                        end
                        local value21, value26, iteratePairs, value27 =
                            value20.bestFor(math.floor(value14), value20.load().cap),
                            math.huge,
                            pairs,
                            value20.LEVELS
                        value20 = nil
                        for key, entry2 in iteratePairs(value27) do
                            if key ~= value21 then
                                local value28 = math.huge
                                for key4, entry5 in pairs(entry2) do
                                    value28 = if entry5 < value28 then entry5 else value28
                                end
                                if value28 > value14 then
                                    if value28 <= value24 then
                                        if value28 < value26 then
                                            value26, value20 = value28, key
                                        end
                                    end
                                end
                            end
                        end
                        if value20 then
                            value27, value21 =
                                #fields + 1, { name = ("ETA to %s (Lv %d)"):format(value20, value26) }
                            value21.value, value21.inline, fields[value27] =
                                "`" .. helper32(value38(value14, value26)) .. "`", false, value21
                        end
                    end)
                end
            end)
        end
        local value54, url =
            {
                title = value4 and "Dungeon completed" or "Dungeon failed",
                description = ("**%s**   %s   %s"):format(tostring(value2.dungeon or "?"), tostring(value2.difficulty or ""), table.concat(value5, "   ")),
                color = value4 and sharedValue7 or color2,
                fields = fields,
                footer = { text = text .. "  |  1-186" },
                timestamp = (function()
                    local success, value14 = pcall(function()
                        return DateTime.fromUnixTimestamp(tonumber(value2.at) or os.time()):ToIsoDate()
                    end)
                    return success and value14 or helper14()
                end)(),
            }, helper6(tostring(value2.dungeon or ""))
        if url then
            value54.thumbnail = { url = url }
        end
        post({ username = name2(), embeds = { value54 } })
    end
    local function flush1186(argument)
        if not (helper35()) then
            return
        end
        task.wait(argument or 0)
        argument = sharedValue2.LocalPlayer
        local value, path, value2 = argument and argument.Name or "?", pcall(listfiles, "HarvardLabs/data")
        if path then
            if type(value2) ~= "table" then
                return
            end
        else
            return
        end
        argument = {}
        for index = 1, #value2, 1 do
            path = tostring(value2[index])
            if path:find("lvl_", 1, true) and path:sub(-5) == ".json" then
                local success, value3 = pcall(readfile, path)
                if success then
                    local success2, value4 = pcall(function()
                        return sharedValue:JSONDecode(value3)
                    end)
                    if success2 then
                        if type(value4) == "table" then
                            if type(value4.who) == "string" then
                                if
                                    os.time() - (tonumber(value4.at) or 0)
                                    <= (tonumber(config.wh1186Stale) or 900)
                                then
                                    argument[#argument + 1] = { path = path, d = value4 }
                                else
                                    pcall(delfile, path)
                                end
                            else
                                pcall(delfile, path)
                            end
                        else
                            pcall(delfile, path)
                        end
                    else
                        pcall(delfile, path)
                    end
                else
                    pcall(delfile, path)
                end
            end
        end
        table.sort(argument, function(argument2, argument3)
            return (tonumber(argument2.d.at) or 0) < (tonumber(argument3.d.at) or 0)
        end)
        value2, path = {}
        for index2, entry in ipairs(argument) do
            index2 = tonumber(entry.d.at) or 0
            if
                (if path then path.dungeon ~= tostring(entry.d.dungeon) else not path)
                or path.job ~= tostring(entry.d.job)
                or index2 - path.at0 > 30
            then
                path = {
                    dungeon = tostring(entry.d.dungeon),
                    job = tostring(entry.d.job),
                    at0 = index2,
                    recs = {},
                }
                value2[#value2 + 1] = path
            end
            table.insert(path.recs, entry)
        end
        for index3, entry2 in ipairs(value2) do
            value2[index3] = entry2.recs
        end
        for key, entry3 in pairs(value2) do
            table.sort(entry3, function(argument2, argument3)
                return argument2.d.who < argument3.d.who
            end)
            if entry3[1].d.who == value then
                if webhooks.claimRun("x186", entry3[1].d.job, entry3[1].d.dungeon) then
                    helper44(entry3)
                else
                    context.log(
                        "Webhook",
                        ("1-186: %d record(s) of a run that was already posted - not posted again"):format(
                            #entry3
                        )
                    )
                end
                for index4 = 1, #entry3, 1 do
                    pcall(delfile, entry3[index4].path)
                end
            end
        end
    end
    webhooks.flush1186 = flush1186
    local function finish1186(argument, argument2)
        local localPlayer = sharedValue2.LocalPlayer
        local who, level, frac, success, cap = localPlayer and localPlayer.Name or "?", helper42()
        local value = { who = who }
        value.display = ("%s (@%s)"):format(localPlayer and localPlayer.DisplayName or who, who)
        value.level = level
        value.frac = frac
        value.p = success
        value.cap = cap
        level, success =
            tostring,
            context.afRole and context.afRole() == "leech" and "alt" or context.afRole and context.afRole()
        value.role = level(success or config.role1186 or "carry")
        value.at = os.time()
        value.won = argument2 and true or false
        value.job = game.JobId
        value.dungeon = argument.dungeon
        value.difficulty = argument.difficulty
        value.deaths = argument.deaths or 0
        value.secs = webhooks.runSecs(argument)
        if not (helper35()) then
            helper44({ { d = value } })
            return
        end
        success, cap = pcall(function()
            return sharedValue:JSONEncode(value)
        end)
        if
            if success
                then not pcall(writefile, "HarvardLabs/data/lvl_" .. who .. ".json", cap)
                else not success
        then
            helper44({ { d = value } })
            return
        end
        flush1186(tonumber(config.wh1186Wait) or 1.5)
    end
    webhooks.finish1186 = finish1186
    local function flushHauls()
        if not (helper35()) then
            return
        end
        local value, value2, endedAt =
            sharedValue2.LocalPlayer and sharedValue2.LocalPlayer.Name or "?",
            pcall(listfiles, "HarvardLabs/data")
        if value2 then
            if type(endedAt) ~= "table" then
                return
            end
        else
            return
        end
        value2 = {}
        for index = 1, #endedAt, 1 do
            local path = tostring(endedAt[index])
            if path:find("haul_", 1, true) and path:sub(-5) == ".json" then
                local success, value3 = pcall(readfile, path)
                local success2, value4 = false
                if success then
                    success2, value4 = pcall(function()
                        return sharedValue:JSONDecode(value3)
                    end)
                end
                if
                    success2
                    and type(value4) == "table"
                    and type(value4.who) == "string"
                    and os.time() - (tonumber(value4.at) or 0) <= (tonumber(config.whFlushStale) or 1800)
                then
                    index = tostring(value4.dungeon) .. "|" .. tostring(value4.job)
                    value2[index] = value2[index] or {}
                    table.insert(value2[index], { path = path, d = value4 })
                elseif success2 then
                    if type(value4) == "table" then
                        pcall(delfile, path)
                    end
                end
            end
        end
        for key, entry in pairs(value2) do
            table.sort(entry, function(argument, argument2)
                return argument.d.who < argument2.d.who
            end)
            if entry[1].d.who == value then
                key, endedAt = entry[1].d, os.clock()
                local value5 = {
                    dungeon = key.dungeon,
                    difficulty = key.difficulty,
                    at = endedAt - (tonumber(key.secs) or 0),
                    endedAt = endedAt,
                    deaths = tonumber(key.deaths) or 0,
                    cards = tonumber(key.cards) or 0,
                    items = {},
                }
                if webhooks.claimRun("party", key.job, key.dungeon) then
                    if #entry >= 2 then
                        pcall(helper36, value5, key.won ~= false, entry)
                    else
                        pcall(
                            helper33,
                            value5,
                            key.won ~= false,
                            type(key.items) == "table" and key.items or {}
                        )
                    end
                end
                for index2 = 1, #entry, 1 do
                    pcall(delfile, entry[index2].path)
                end
            end
        end
    end
    webhooks.flushHauls = flushHauls
    task.spawn(function()
        task.wait(tonumber(config.whFlushWait) or 8)
        if context.is1186 then
            if not (context.is1186()) then
                pcall(flushHauls)
            end
        else
            pcall(flushHauls)
        end
    end)
    task.spawn(function()
        if context.is1186 then
            if context.is1186() then
                pcall(flush1186, tonumber(config.wh1186LoadWait) or 6)
            end
        end
    end)
    webhooks.finish = function(argument)
        local run = webhooks.run
        webhooks.run = nil
        if not argument and config.kitFailSwap ~= false then
            if context.afRole then
                if context.afRole() == "carry" then
                    if context.kitFailMark then
                        if not (context.skipFinalAt and os.clock() - context.skipFinalAt < 300) then
                            local dungeonName = workspace:FindFirstChild("dungeonName")
                            local value = run and run.dungeon
                                or dungeonName and tostring(dungeonName.Value)
                                or ""
                            if value ~= "" then
                                pcall(context.kitFailMark, value)
                            end
                        end
                    end
                end
            end
        end
        if not run then
            webhooks.pendingUntil = nil
            return
        end
        if context.is1186 then
            if context.is1186() then
                webhooks.sessMark(argument)
                helper()
                task.spawn(finish1186, run, argument)
                return
            end
        end
        webhooks.sessMark(argument)
        helper()
        task.spawn(function()
            task.wait(tonumber(config.whGatherFor) or 3)
            local value2, invTotal = helper24(12)
            local value3 = helper25(run.base, value2)
            if invTotal then
                run.invTotal = invTotal
            end
            if not (helper37(run, argument, value3)) then
                if webhooks.claimRun("party", game.JobId, run.dungeon) then
                    helper33(run, argument, value3)
                end
                task.wait(1)
                pcall(
                    delfile,
                    "HarvardLabs/data/haul_"
                        .. tostring(sharedValue2.LocalPlayer and sharedValue2.LocalPlayer.Name or "?")
                        .. ".json"
                )
            end
            task.wait(1)
            webhooks.pendingUntil = nil
            if context.ST then
                if context.ST.reportRun then
                    pcall(context.ST.reportRun, run, argument, value3)
                end
            end
            if config.whLate == false then
                return
            elseif value2 then
            else
                return
            end
            task.wait(tonumber(config.whLateAfter) or 30)
            value3, invTotal = helper24(12)
            if not value3 then
                return
            end
            if invTotal then
                run.invTotal = invTotal
            end
            invTotal = helper25(value2, value3)
            if #invTotal > 0 then
                helper34(run, invTotal)
            end
        end)
    end
    task.spawn(function()
        local value, health = false
        local value2, value3, value4, jobId, value5, value6 = false, false, 0
        local value7 = 0
        local function helper32()
            local value8 = value4 > 0 and os.clock() - value4 > (tonumber(config.whVerdictAfter) or 20)
            return value8
        end
        local function helper38()
            if not (helper32()) then
                return false
            end
            local value8 = workspace:FindFirstChild("dungeon")
            local value9 = value8 and (value8:FindFirstChild("bossRoom"))
            value8 = value9 and (value9:FindFirstChild("dungeonFinished"))
            if value8 then
                if value8.Value == true then
                    return true
                end
            end
            value8 = workspace:FindFirstChild("dungeonProgress")
            if value8 then
                if tostring(value8.Value) == "bossKilled" then
                    return true
                end
            end
            return false
        end
        local function helper45()
            local dungeonProgress = workspace:FindFirstChild("dungeonProgress")
            local value8 = dungeonProgress and tostring(dungeonProgress.Value) or ""
            return value8 == "noLivesLeft" or value8 == "outOfTime"
        end
        local function helper46()
            if not (helper32()) then
                return false
            end
            local value8 = sharedValue2.LocalPlayer and sharedValue2.LocalPlayer:FindFirstChild("PlayerGui")
            local value9 = value8 and (value8:FindFirstChild("timeLeftGui"))
            value8 = value9 and (value9:FindFirstChild("Frame"))
            value9 = value8 and (value8:FindFirstChild("time"))
            if value9 then
                if value9:IsA("TextLabel") then
                    if value9.Text == "00:00" then
                        return true
                    elseif value9.Text == "0:00" then
                        return true
                    end
                end
            end
            return false
        end
        while not (runtimeState and runtimeState.destroyed) do
            task.wait(0.5)
            if
                not (
                    pcall(function()
                        local dungeonName = workspace:FindFirstChild("dungeonName")
                        local value8, value9 =
                            workspace:FindFirstChild("dungeonStarted"),
                            dungeonName ~= nil and tostring(dungeonName.Value) ~= ""
                        local value10 = value8 ~= nil and value8.Value == true
                        if not value9 then
                            value2, value3 = false, false
                        end
                        local value11, value12 =
                            context.runComplete ~= nil and context.runComplete() == true,
                            workspace:FindFirstChild("dungeonProgress")
                        value11 = if value12
                            then if tostring(value12.Value) == "bossKilled" then true else value11
                            else value11
                        value12, value8 = value9 and value10 and not value and not value11
                        if value12 then
                            local jobId2 = jobId
                            value8 = jobId2 ~= game.JobId
                        else
                            value8 = value12
                        end
                        value12 = value8
                            and ((if value3 then not value3 else not value2) or value2 and not helper38())
                        if value12 then
                            value8 = nil
                            value8, value = os.clock(), true
                            value4, value2 = value8, false
                            local value13 = liveDifficulty()
                            if not value13 then
                                pcall(function()
                                    local value14 = sharedValue:JSONDecode(
                                        readfile(
                                            context.AF
                                                    and context.AF.partyFile
                                                    and context.AF.partyFile("af_party")
                                                or "HarvardLabs/data/af_party.json"
                                        )
                                    )
                                    if value14 then
                                        if value14.map == tostring(dungeonName.Value) then
                                            if os.time() - (tonumber(value14.at) or 0) < 3600 then
                                                value13 = value14.diff
                                            end
                                        end
                                    end
                                end)
                            end
                            if not value13 and context.queuePick then
                                local value15
                                value15, value13 = context.queuePick()
                            end
                            webhooks.start(
                                tostring(dungeonName.Value),
                                value13 or tostring(config.autoQueueDifficulty or "?")
                            )
                        elseif value then
                            if context.runComplete ~= nil and context.runComplete() == true or helper38() then
                                local jobId3
                                jobId3, value, value2 = game.JobId, false, true
                                jobId = jobId3
                                if webhooks.run then
                                    if not webhooks.run.endedAt then
                                        webhooks.run.endedAt =
                                            webhooks.endAt(webhooks.bossDeathAt, webhooks.run.at)
                                    end
                                end
                                if not (context.is1186 and context.is1186()) then
                                    if config.webhook ~= false then
                                        webhooks.pendingUntil = os.clock() + (config.whReplayHold or 25)
                                    end
                                end
                                task.spawn(function()
                                    local waitTask, value14 =
                                        task.wait,
                                        context.is1186 and context.is1186() and 0 or (config.whLootWait or 3)
                                    waitTask(value14)
                                    webhooks.finish(true)
                                end)
                            elseif helper46() or not value9 or not value10 or helper45() then
                                value, value2 = false, true
                                if helper46() then
                                    jobId = game.JobId
                                elseif helper45() then
                                    jobId = game.JobId
                                elseif context.runFailed then
                                    if context.runFailed() then
                                        jobId = game.JobId
                                    end
                                end
                                if webhooks.run then
                                    if not webhooks.run.endedAt then
                                        webhooks.run.endedAt = os.clock()
                                    end
                                end
                                webhooks.finish(false)
                            end
                        end
                        value3 = value10
                        value8 = workspace:FindFirstChild("bonusBossStatus")
                        value9 = value8 and tostring(value8.Value or "") or ""
                        if value9 ~= value5 then
                            if value9 == "active" then
                                value12, value10, value8 = os.clock(), webhooks.run
                                value8, value6 = value10 and webhooks.run.deaths or 0, value12
                                value7 = value8
                                pcall(webhooks.rodinBegin)
                            end
                            if value9 == "success" then
                                if value5 == "active" then
                                    pcall(webhooks.rodinClear, value6, value7)
                                end
                            end
                            if value9:lower():find("fail", 1, true) then
                                if value5 == "active" then
                                    pcall(webhooks.rodinFail, value6, value7)
                                end
                            end
                            value5 = value9
                        end
                        value12 = sharedValue2.LocalPlayer and sharedValue2.LocalPlayer.Character
                        value9, value8 =
                            value12 and (value12:FindFirstChildOfClass("Humanoid")),
                            webhooks.rodin ~= nil and value5 == "active"
                        if value or value8 then
                            if value9 then
                                if health ~= nil then
                                    if value9.Health <= 0 then
                                        if health > 0 then
                                            if
                                                runtimeState.selfResetAt ~= nil
                                                and os.clock() - runtimeState.selfResetAt
                                                    < (config.whResetGrace or 5)
                                            then
                                            elseif value8 then
                                                webhooks.rodin.deaths = webhooks.rodin.deaths + 1
                                            elseif value then
                                                webhooks.death()
                                            end
                                        end
                                    end
                                end
                                health = value9.Health
                            end
                        end
                    end)
                )
            then
                task.wait(2)
            end
        end
    end)
end
