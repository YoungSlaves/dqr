-- Extracted verbatim from harvardd.lua lines 116432-118105; presentation owned elsewhere.
return function(context)
    local config = context.CFG
    local sharedValue, inventoryAutomation =
        context.ReplicatedStorage or getService("ReplicatedStorage"),
        { lastSold = 0, totalSold = 0, note = "no sale yet", at = 0 }
    context.AS = inventoryAutomation
    local dungeons, sharedValue2, sharedValue3, sharedValue4, sharedValue5 =
        {
            "Abyssal Void",
            "Aquatic Temple",
            "Boss Raids (Legacy)",
            "Desert Temple",
            "Desert Temple (Legacy)",
            "Egg Island",
            "Enchanted Forest",
            "Ghastly Harbor",
            "Gilded Skies",
            "King's Castle",
            "Northern Lands",
            "Orbital Outpost",
            "Pirate Island",
            "Ready Player Two",
            "Samurai Palace",
            "Steampunk Sewers",
            "The Canals",
            "The Underworld",
            "Volcanic Chambers",
            "Winter Outpost",
            "Winter Outpost (Legacy)",
            "Yokai Peak",
        }, { w = "weapon", a = "ability", h = "helmet", c = "chest" }, { n = "", c = "common", u = "uncommon", r = "rare", e = "epic", l = "legendary", x = "ultimate" }, {
            p = "physical",
            s = "spell",
            m = "mage",
            w = "warrior",
            g = "guardian",
            d = "damaging",
            v = "speed",
            h = "healing",
            b = "boosting",
            f = "buffing",
        }, {
            "Abyssal Skewers|w|n|1|s",
            "Abyssal Spellscythe|w|n|1|s",
            "Abyssal Talons|w|n|1|p",
            "Abyssal Warhammers|w|n|1|p",
            "Adventurer's Staff|w|n|0|s",
            "Adventurer's Sword|w|n|0|p",
            "Agony Orbs|a|e|7|d",
            "Akuma Guardian Armor|c|n|22|g",
            "Akuma Guardian Helmet|h|n|22|g",
            "Akuma Mage Cloak|h|n|22|m",
            "Akuma Mage Robes|c|n|22|m",
            "Akuma Warrior Armor|c|n|22|w",
            "Akuma Warrior Helmet|h|n|22|w",
            "Akuma's Soulreaver|w|l|22|s",
            "Akuma's Wraithbringer|w|l|22|p",
            "Alien Guardian Armor|c|n|12|g",
            "Alien Guardian Helmet|h|n|12|g",
            "Alien Mage Armor|c|n|12|m",
            "Alien Mage Helmet|h|n|12|m",
            "Alien Warrior Armor|c|n|12|w",
            "Alien Warrior Helmet|h|n|12|w",
            "Amethyst Beams|a|e|9|d",
            "Amethyst Blast|a|e|19|d",
            "Amethyst Crescent Spellblade|w|n|15|s",
            "Amethyst Spelldagger|w|n|15|s",
            "Amethyst Spellscythe|w|n|17|s",
            "Ancestral Guardian Armor|c|n|15|g",
            "Ancestral Guardian Helmet|h|n|15|g",
            "Ancestral Mage Armor|c|n|15|m",
            "Ancestral Mage Hood|h|n|15|m",
            "Ancestral Warrior Armor|c|n|15|w",
            "Ancestral Warrior Helmet|h|n|15|w",
            "Ancient Elder Staff|w|n|18|s",
            "Ancient Lava Axe|w|n|19|s",
            "Ancient Plate Armor|c|n|21|g",
            "Ancient Plate Helmet|h|n|21|g",
            "Ancient Ruins Greatsword|w|n|3|p",
            "Angelic Plate Armor|c|n|13|m",
            "Angelic Plate Helmet|h|n|13|m",
            "Angelic Staff|w|n|13|s",
            "Apothecary Staff|w|n|10|s",
            "Apprentice Staff|w|n|5|s",
            "Aquatic Defender|w|n|2|s",
            "Aquatic Executioner|w|n|2|p",
            "Aquatic Guardian Armor|c|n|2|g",
            "Aquatic Guardian Helmet|h|n|2|g",
            "Aquatic Mage Armor|c|n|2|m",
            "Aquatic Mage Helmet|h|n|2|m",
            "Aquatic Scimitars|w|n|2|p",
            "Aquatic Smite|a|e|2|d",
            "Aquatic Spear|w|n|2|p",
            "Aquatic Warrior Armor|c|n|2|w",
            "Aquatic Warrior Helmet|h|n|2|w",
            "Arc Blast|a|e|0|d",
            "Arc Wave|a|e|0|d",
            "Arcane Amplifier|a|e|1|f",
            "Arcane Barrage|a|u|20|d",
            "Arcane Greatstaff|w|n|20|s",
            "Arcane Orb Staff|w|n|13|s",
            "Arcane Spray|a|u|4|d",
            "Arch-Mage_Crown|h|n|10|m",
            "Arch-Mage_Robes|c|n|10|m",
            "Arclight Battlestaff|w|n|10|s",
            "Arrow Barrage|a|e|16|d",
            "Arrow Rain|a|r|16|d",
            "Aura of Life|a|u|20|h",
            "Azerite Greatstaff|w|n|20|s",
            "Banished Greatsword|w|n|3|p",
            "Barbaric_Guardian_Armor|c|n|10|g",
            "Barbaric_Guardian_Helmet|h|n|10|g",
            "Barbaric_Mage_Crown|h|n|10|m",
            "Barbaric_Mage_Robes|c|n|10|m",
            "Barbaric_Warrior_Armor|c|n|10|w",
            "Barbaric_Warrior_Helmet|h|n|10|w",
            "Battle Shout|a|u|4|b",
            "Beast Cleaver|w|n|10|p",
            "Beastly_Guardian_Armor|c|n|10|g",
            "Beastly_Guardian_Helmet|h|n|10|g",
            "Beastly_Warrior_Armor|c|n|10|w",
            "Beastly_Warrior_Helmet|h|n|10|w",
            "Beastmaster Spell Scythe|w|l|10|s",
            "Beastmaster War Scythe|w|l|10|p",
            "Berserk|a|e|15|d",
            "Bioforged Cog Spellblade|w|n|3|s",
            "Bioforged Greataxe|w|n|16|p",
            "Bioforged Greatsword|w|n|16|p",
            "Bioforged Quickblade|w|n|3|p",
            "Bioforged Reinforced Slicer|w|n|16|p",
            "Blacksteel Greatsword|w|n|18|p",
            "Blade Barrage|a|e|9|d",
            "Blade Fall|a|e|19|d",
            "Blade Revolver|a|e|17|d",
            "Blade Storm|a|e|17|d",
            "Blade Throw|a|e|10|d",
            "Blazing Star|w|n|12|p",
            "Blessed Lightpost|w|n|3|s",
            "Blood Pact|a|e|1|g",
            "Bloodthirster|w|n|17|p",
            "Blue Fireball|a|c|4|d",
            "Blue Wizard Hat|h|n|5|m",
            "Blue Wizard Robes|c|n|5|m",
            "Bluefire Staff|w|n|20|s",
            "Bone Scythe|w|n|15|p",
            "Bronze Dagger|w|n|5|p",
            "Bronze Longsword|w|n|5|p",
            "Burned Guardian Armor|c|n|19|g",
            "Burned Guardian Helmet|h|n|19|g",
            "Burned Mage Armor|c|n|19|m",
            "Burned Mage Helmet|h|n|19|m",
            "Burned Warrior Armor|c|n|19|w",
            "Burned Warrior Helmet|h|n|19|w",
            "Captain's Anchor|w|n|8|p",
            "Carrot Barrage|a|r|6|d",
            "Celestial Fire Staff|w|n|10|s",
            "Chain Heal|a|r|10|h",
            "Chain Lightning|a|e|16|d",
            "Chain Phase Shock|a|n|14|d",
            "Chain Storm|a|e|22|d",
            "Chained Energy Blasts|a|r|16|d",
            "Champion's Destiny|w|l|0|p",
            "Champion's Fury|w|l|0|p",
            "Champion's Judgement|w|l|0|p",
            "Champion's Oath|w|l|0|p",
            "Chromatic Rain|a|e|16|d",
            "Cleansing Beam|a|e|1|",
            "Coldstone Axes|w|n|20|p",
            "Coldstone Blades|w|n|20|s",
            "Coldstone Cleaver|w|n|20|p",
            "Coldstone Glaive|w|n|20|p",
            "Coldstone Greatstaff|w|n|20|s",
            "Coldstone Spellscythe|w|n|20|s",
            "Coldstone Sword|w|n|20|p",
            "Commander's Guardian Armor|c|n|12|g",
            "Commander's Guardian Helmet|h|n|12|g",
            "Commander's Mage Armor|c|n|12|m",
            "Commander's Mage Helmet|h|n|12|m",
            "Commander's Warrior Armor|c|n|12|w",
            "Commander's Warrior Helmet|h|n|12|w",
            "Cracked Tooth Cleaver|w|n|8|p",
            "Crimson Kris|w|n|15|p",
            "Crimson Spellblade|w|n|20|s",
            "Crusader Armor|c|n|5|g",
            "Crusader Helmet|h|n|5|g",
            "Crystalized Greatsword|w|l|20|p",
            "Crystalline Cannon|a|e|7|d",
            "Crystalline Guardian Armor|c|n|7|g",
            "Crystalline Guardian Helmet|h|n|7|g",
            "Crystalline Mage Armor|c|n|7|m",
            "Crystalline Mage Helmet|h|n|7|m",
            "Crystalline Shard Staff|w|n|7|s",
            "Crystalline Warrior Armor|c|n|7|w",
            "Crystalline Warrior Helmet|h|n|7|w",
            "Cultist Blade|w|n|13|p",
            "Dark Ice Blades|w|n|17|p",
            "Dark Priest Staff|w|n|13|s",
            "Darkstone Greatsword|w|n|19|p",
            "Daybreak And Gildensong|w|l|9|s",
            "Demon Lord's Greatstaff|w|n|18|s",
            "Demonic Curse|a|e|12|d",
            "Demonic Greatsword|w|n|20|p",
            "Demonic Spellblade|w|n|20|s",
            "Demonic Spikes|a|r|18|d",
            "Demonic Strike|a|r|13|d",
            "Desert Fury|w|l|5|p",
            "Desert Mirage|w|l|4|s",
            "Desert Wrath|w|l|4|p",
            "Devilish Greataxe|w|n|13|p",
            "Diamond Encrusted Blade|w|n|20|p",
            "Dracani Flanged Mace|w|n|9|p",
            "Dracani Gilded Lance|w|n|9|s",
            "Dracani Gilded Staff|w|n|9|s",
            "Dracani Gilded Sword|w|n|9|p",
            "Dracani Guardian Armor|c|n|9|g",
            "Dracani Guardian Helmet|h|n|9|g",
            "Dracani Mage Armor|c|n|9|m",
            "Dracani Mage Helmet|h|n|9|m",
            "Dracani Royal Glaive|w|n|9|p",
            "Dracani Spellclaws|w|n|9|s",
            "Dracani Warrior Armor|c|n|9|w",
            "Dracani Warrior Helmet|h|n|9|w",
            "Dragon Slayer Blade|w|n|20|p",
            "Dragon's Claw Scythe|w|n|18|s",
            "Dual Ancient Daggers|w|n|18|p",
            "Dual Arcane Slicers|w|n|17|s",
            "Dual Arcane Spelldaggers|w|n|18|s",
            "Dual Bioforged Drills|w|l|3|p",
            "Dual Bioforged Spelldaggers|w|n|16|s",
            "Dual Bladed Mage Daggers|w|n|8|s",
            "Dual Crimson Daggers|w|n|17|p",
            "Dual Crystalized Knives|w|n|12|p",
            "Dual Cutlasses|w|n|10|p",
            "Dual Elegant Mage Fans|w|n|15|s",
            "Dual Fist Blades|w|n|19|p",
            "Dual Flatblade Slicers|w|n|18|p",
            "Dual Frozen Blades|w|n|10|p",
            "Dual Fusion Blades|w|n|16|p",
            "Dual Godforged Blades|w|l|3|p",
            "Dual Hellfire Blades|w|n|19|s",
            "Dual Hextech Spelldaggers|w|n|16|s",
            "Dual Infernal Daggers|w|n|15|p",
            "Dual Infernal Scimitars|w|n|17|p",
            "Dual Inferno Slicers|w|n|10|p",
            "Dual Jade Daggers|w|n|10|p",
            "Dual Magma Fangs|w|n|17|p",
            "Dual Magma Shields|w|n|19|s",
            "Dual Nature Vines|w|n|3|s",
            "Dual Ocean Fists|w|n|8|s",
            "Dual Phantom Axes|w|n|8|p",
            "Dual Phantom Daggers|w|n|8|p",
            "Dual Phantom Defenders|w|n|8|s",
            "Dual Phoenix Daggers|w|l|18|p",
            "Dual Pirate Cutlasses|w|n|8|p",
            "Dual Razor Slicers|w|n|17|p",
            "Dual Royal Axes|w|n|10|p",
            "Dual Samurai Sickles|w|n|15|p",
            "Dual Samurai Stars|w|n|15|p",
            "Dual Sapphire Slicers|w|n|18|p",
            "Dual Serrated Knives|w|n|8|p",
            "Dual Sinister Blades|w|n|3|p",
            "Dual Solar Blades|w|n|12|p",
            "Dual Toxic Daggers|w|n|8|s",
            "Eagle Staff|w|n|10|s",
            "Earth Clap|a|r|15|d",
            "Earth Kick|a|u|17|d",
            "Earth Maul|w|n|3|p",
            "Earth Spikes|a|u|8|d",
            "Earth Staff|w|n|3|s",
            "Earth Wand|w|n|13|s",
            "Easter Guardian Armor|c|e|6|g",
            "Easter Guardian Helmet|h|e|6|g",
            "Easter Mage Armor|c|e|6|m",
            "Easter Mage Helmet|h|e|6|m",
            "Easter Warrior Armor|c|e|6|w",
            "Easter Warrior Helmet|h|e|6|w",
            "Egg Bomb|a|r|6|d",
            "Egg Maul|w|e|6|p",
            "Egg Staff|w|e|6|s",
            "Eldenbark Greatstaff|w|l|7|s",
            "Eldenbark Greatsword|w|l|7|p",
            "Eldenbark Guardian Armor|c|n|7|g",
            "Eldenbark Guardian Helmet|h|n|7|g",
            "Eldenbark Mage Armor|c|n|7|m",
            "Eldenbark Mage Helmet|h|n|7|m",
            "Eldenbark Warrior Armor|c|n|7|w",
            "Eldenbark Warrior Helmet|h|n|7|w",
            "Elder Void Wand|w|n|20|s",
            "Eldritch Cleavers|w|n|1|p",
            "Eldritch Guardian Armor|c|n|1|g",
            "Eldritch Guardian Helmet|h|n|1|g",
            "Eldritch Mace|w|n|1|s",
            "Eldritch Mage Armor|c|n|1|m",
            "Eldritch Mage Helmet|h|n|1|m",
            "Eldritch Trident|w|n|1|s",
            "Eldritch War Lance|w|n|1|p",
            "Eldritch Warrior Armor|c|n|1|w",
            "Eldritch Warrior Helmet|h|n|1|w",
            "Electric Boom|a|e|10|d",
            "Electric Field|a|e|12|d",
            "Electric Grinder|a|e|12|d",
            "Electric Slash|a|r|17|d",
            "Electron Spell Dagger|w|n|12|s",
            "Elementalist Hood|h|n|5|m",
            "Elementalist Robes|c|n|5|m",
            "Elementalist Staff|w|n|17|s",
            "Elite Ancient Plate Armor|c|n|21|g",
            "Elite Ancient Plate Helmet|h|n|21|g",
            "Elite Mage Plate Armor|c|n|21|m",
            "Elite Mage Plate Helmet|h|n|21|m",
            "Elite Warlord Plate Armor|c|n|21|w",
            "Elite Warlord Plate Helmet|h|n|21|w",
            "Elven Staff|w|n|10|s",
            "Empowered Crystal Blade|w|n|13|p",
            "Enchanted Demonic Greataxe|w|n|18|p",
            "Enchanted Sea Axes|w|n|2|s",
            "Enchanted Sea Daggers|w|n|2|s",
            "Enchanted Serpent Daggers|w|n|2|s",
            "Enchanted Shard Dual Blade|w|n|7|p",
            "Enchanted Shard Spelldagger|w|n|7|s",
            "Enchanted Shard Staff|w|n|7|s",
            "Enchanted Shard War Axe|w|n|7|p",
            "Enchanted Shuriken|a|e|15|d",
            "Enchanted Spinning Blades|a|e|13|d",
            "Enchanted Sword|w|n|5|p",
            "Energized Spell Dagger|w|n|12|s",
            "Energy Orb|a|e|12|d",
            "Enhanced Inner Focus|a|l|2|b",
            "Enhanced Inner Rage|a|l|2|b",
            "Ethereal Greataxe|w|n|10|p",
            "Explosive Mine|a|e|12|d",
            "Explosive Punch|a|e|16|d",
            "Fallen Guardian Armor|c|n|1|g",
            "Fallen Guardian Helmet|h|n|1|g",
            "Fallen Mage Armor|c|n|1|m",
            "Fallen Mage Helmet|h|n|1|m",
            "Fallen Warrior Armor|c|n|1|w",
            "Fallen Warrior Helmet|h|n|1|w",
            "Fallen's Battlestaff|w|n|1|s",
            "Fallen's Blade|w|n|1|p",
            "Fallen's Halberd|w|n|1|p",
            "Fallen's Spellblades|w|n|1|s",
            "File:Fungal Guardian Armor|c|n|7|g",
            "Fire and Ice Staff|w|n|10|s",
            "Fire Bomb|a|u|20|d",
            "Fireball|a|c|4|d",
            "Flame Cyclone|a|e|15|d",
            "Flame Shuriken|a|e|11|d",
            "Flame Staff|w|n|5|s",
            "Flame Step|a|c|0|d",
            "Flame Strike|a|r|11|d",
            "Focus Beam|a|e|12|d",
            "Forest Vine Hatchet|w|n|7|p",
            "Forest Vine Spellblade|w|n|7|s",
            "Forgotten Army|a|e|17|d",
            "Forgotten Guardian Armor|c|n|21|g",
            "Forgotten Guardian Helmet|h|n|21|g",
            "Forgotten Mage Hood|h|n|21|m",
            "Forgotten Mage Robes|c|n|21|m",
            "Forgotten Warrior Armor|c|n|21|w",
            "Forgotten Warrior Helmet|h|n|21|w",
            "Frost Cone|a|r|11|d",
            "Frost Giant Greataxe|w|n|11|p",
            "Frost Maul|w|n|20|p",
            "Frostbound Guardian Armor|c|n|20|g",
            "Frostbound Guardian Helmet|h|n|20|g",
            "Frostbound Mage Cloak|h|n|20|m",
            "Frostbound Mage Robes|c|n|20|m",
            "Frostbound Warrior Armor|c|n|20|w",
            "Frostbound Warrior Helmet|h|n|20|w",
            "Frostshard Battle Axe|w|n|20|p",
            "Frostshard Greatstaff|w|n|20|s",
            "Frostshard Hammer|w|n|20|p",
            "Frostshard Lance|w|n|20|s",
            "Frostshard Trident|w|n|20|s",
            "Frostshard Twinblades|w|n|20|p",
            "Frostwarden|w|l|20|s",
            "Frosty Staff|w|n|20|s",
            "Frozen Greatsword|w|n|20|p",
            "Frozen Lord's Greatsword|w|n|20|p",
            "Frozen Spelldaggers|w|n|20|s",
            "Fungal Guardian Helmet|h|n|7|g",
            "Fungal Lance|w|n|7|p",
            "Fungal Mage Armor|c|n|7|m",
            "Fungal Mage Helmet|h|n|7|m",
            "Fungal Pike|w|n|7|s",
            "Fungal Poison|a|r|7|d",
            "Fungal Staff|w|n|7|s",
            "Fungal Warhammer|w|n|7|p",
            "Fungal Warrior Armor|c|n|7|w",
            "Fungal Warrior Helmet|h|n|7|w",
            "Fusion Greatsword|w|n|16|p",
            "Fusion Magic Keyblade|w|n|3|s",
            "Galactic Dual Blades|w|l|12|p",
            "Galactic Pike|w|l|12|s",
            "Gale Barrage|a|e|11|d",
            "Gale Slice|a|u|20|d",
            "Geyser|a|e|11|d",
            "Ghostly Cannon Barrage|a|u|13|d",
            "Ghostly Greataxe|w|n|5|p",
            "Ghostly Rampage|a|r|15|d",
            "Ghoul Slayer|w|n|5|p",
            "Giant Royal Axe|w|n|17|p",
            "Gildenscale Guardian Armor|c|n|9|g",
            "Gildenscale Guardian Helmet|h|n|9|g",
            "Gildenscale Mage Armor|c|n|9|m",
            "Gildenscale Mage Helmet|h|n|9|m",
            "Gildenscale Oath And Aegis|w|l|9|p",
            "Gildenscale Warrior Armor|c|n|9|w",
            "Gildenscale Warrior Helmet|h|n|9|w",
            "Glacial Blows|a|r|10|d",
            "Glacial Greatsword|w|n|20|p",
            "Glorious Guardian Armor|c|n|18|g",
            "Glorious Guardian Helmet|h|n|18|g",
            "Glorious Mage Armor|c|n|18|m",
            "Glorious Mage Helmet|h|n|18|m",
            "Glorious Warrior Armor|c|n|18|w",
            "Glorious Warrior Helmet|h|n|18|w",
            "Goblin Cleaver|w|n|10|p",
            "God Spear|a|e|9|d",
            "Godforged Greatstaff|w|l|3|s",
            "Godly Guardian Armor|c|n|13|g",
            "Godly Guardian Helmet|h|n|13|g",
            "Godly Mage Helmet|h|n|13|m",
            "Godly Mage Robes|c|n|13|m",
            "Godly Warrior Armor|c|n|13|w",
            "Godly Warrior Helmet|h|n|13|w",
            "Godsword|w|n|20|p",
            "Golden Kopesh|w|n|4|p",
            "Grand Claymore|w|n|5|p",
            "Granite Maul|w|n|5|p",
            "Gravity Leap|a|l|1|",
            "Greater Dark Scythe|w|n|13|s",
            "Greater Prophet Staff|w|n|13|s",
            "Ground Slam|a|u|20|d",
            "Ground Stomp|a|e|16|d",
            "Guardian Armor|c|n|5|g",
            "Guardian Call|a|e|13|g",
            "Guardian Helmet|h|n|5|g",
            "Guardian Roar|a|r|6|g",
            "Guardian's Blessing|a|r|10|g",
            "Gungnir|w|l|11|s",
            "Hand Cannon|a|u|15|d",
            "Hands Of Death|a|e|22|d",
            "Hardened Ice Sword|w|n|20|p",
            "Heavenly Greatsword|w|n|10|p",
            "Heavenly Guardian Armor|c|n|3|g",
            "Heavenly Guardian Helmet|h|n|3|g",
            "Heavenly Mage Armor|c|n|3|m",
            "Heavenly Mage Helmet|h|n|3|m",
            "Heavenly Warrior Armor|c|n|3|w",
            "Heavenly Warrior Helmet|h|n|3|w",
            "Hellstone Greataxe|w|n|19|p",
            "Hextech Greataxe|w|n|16|p",
            "Hextech Katana|w|n|16|p",
            "Hextech Overloaded Staff|w|l|3|s",
            "Hextech Polearm|w|n|16|s",
            "Hextech Wired Spellblade|w|n|16|s",
            "High Priest Battleaxe|w|n|10|p",
            "Hofund|w|x|11|p",
            "Holy Barrier|a|r|4|g",
            "Holy Circle|a|e|4|h",
            "Holy Grail|w|n|20|s",
            "Holy Staff|w|n|5|s",
            "Holy Sun Staff|w|n|4|s",
            "Holy Wand|w|n|13|s",
            "Honorable Greatsword|w|n|15|p",
            "Hope's Triumph|w|n|18|s",
            "Hunter's Guardian Armor|c|n|8|g",
            "Hunter's Guardian Helmet|h|n|8|g",
            "Hunter's Mage Armor|c|n|8|m",
            "Hunter's Mage Helmet|h|n|8|m",
            "Hunter's Warrior Armor|c|n|8|w",
            "Hunter's Warrior Helmet|h|n|8|w",
            "Ice Barrage|a|e|2|d",
            "Ice Crash|a|e|2|d",
            "Ice Enhanced Sword|w|n|20|p",
            "Ice Greatspear|w|n|11|p",
            "Ice Guardian Armor|c|n|21|g",
            "Ice Guardian Helmet|h|n|21|g",
            "Ice Infused Slicer|w|n|20|p",
            "Ice King's Guardian Armor|c|n|21|g",
            "Ice King's Guardian Helmet|h|n|21|g",
            "Ice King's Mage Hood|h|n|21|m",
            "Ice King's Mage Robes|c|n|21|m",
            "Ice King's Warrior Armor|c|n|21|w",
            "Ice King's Warrior Helmet|h|n|21|w",
            "Ice Mage Hood|h|n|21|m",
            "Ice Mage Robes|c|n|21|m",
            "Ice Needles|a|u|20|d",
            "Ice Nova|a|r|18|d",
            "Ice Queen's Wand|w|n|20|s",
            "Ice Reaver|w|n|20|s",
            "Ice Sickles|w|n|20|p",
            "Ice Spellblade|w|n|11|s",
            "Ice Spikes|a|e|2|d",
            "Ice Totem|a|e|18|d",
            "Ice Wand|w|n|20|s",
            "Ice Warrior Armor|c|n|21|w",
            "Ice Warrior Helmet|h|n|21|w",
            "Iceblade|w|n|20|p",
            "Icicle Barrage|a|r|17|d",
            "Illusion Blast|a|e|15|d",
            "Industrial Guardian Armor|c|n|16|g",
            "Industrial Guardian Helmet|h|n|16|g",
            "Industrial Mage Armor|c|n|16|m",
            "Industrial Mage Helmet|h|n|16|m",
            "Industrial Spellscythe|w|n|15|s",
            "Industrial Warrior Armor|c|n|16|w",
            "Industrial Warrior Helmet|h|n|16|w",
            "Infernal Blast|a|e|16|d",
            "Infernal Elemental Sword|w|n|20|p",
            "Infernal Guardian Armor|c|n|15|g",
            "Infernal Guardian Helmet|h|n|15|g",
            "Infernal Mage Hood|h|n|15|m",
            "Infernal Mage Robes|c|n|15|m",
            "Infernal Orbs|a|u|18|d",
            "Infernal Strike|a|e|18|d",
            "Infernal Sun Staff|w|n|10|s",
            "Infernal Warrior Armor|c|n|15|w",
            "Infernal Warrior Helmet|h|n|15|w",
            "Inferno Plate Armor|c|n|13|w",
            "Inferno Plate Helmet|h|n|13|w",
            "Inner Focus|a|e|19|b",
            "Inner Rage|a|e|19|b",
            "Innervate|a|e|4|b",
            "Inventor's Greatsword|w|l|16|p",
            "Inventor's Guardian Armor|c|n|3|g",
            "Inventor's Guardian Helmet|h|n|3|g",
            "Inventor's Mage Armor|c|n|3|m",
            "Inventor's Mage Helmet|h|n|3|m",
            "Inventor's Spellblade|w|l|16|s",
            "Inventor's Warrior Armor|c|n|3|w",
            "Inventor's Warrior Helmet|h|n|3|w",
            "Iron Armor|c|n|5|g",
            "Iron Helmet|h|n|5|g",
            "Iron Longsword|w|n|5|p",
            "Jade Rain|a|e|9|d",
            "Jade Roller|a|e|9|d",
            "Jade Spelldagger|w|n|15|s",
            "Jigoku Club And Shield|w|n|22|p",
            "Jigoku Shuriblade|w|n|22|s",
            "Jigoku Twin Katanas|w|n|22|p",
            "Jigoku Twin Warfans|w|n|22|s",
            "Jotunn Guardian Armor|c|n|11|g",
            "Jotunn Guardian Helmet|h|n|11|g",
            "Jotunn Mage Armor|c|n|11|m",
            "Jotunn Mage Helmet|h|n|11|m",
            "Jotunn Warrior Armor|c|n|11|w",
            "Jotunn Warrior Helmet|h|n|11|w",
            "King's Greatsword|w|n|20|p",
            "King's Spellblade|w|n|20|s",
            "Kraken Slayer|w|l|8|p",
            "Kunai Knives|a|e|22|d",
            "Laevateinn|w|x|11|s",
            "Lava Barrage|a|e|19|d",
            "Lava Beam Orb|a|e|19|d",
            "Lava Cage|a|e|19|d",
            "Lava King's Guardian Armor|c|n|19|g",
            "Lava King's Guardian Helmet|h|n|19|g",
            "Lava King's Mage Armor|c|n|19|m",
            "Lava King's Mage Helmet|h|n|19|m",
            "Lava King's Spell Daggers|w|l|19|s",
            "Lava King's Warrior Armor|c|n|19|w",
            "Lava King's Warrior Helmet|h|n|19|w",
            "Lava King's Warscythe|w|l|19|p",
            "Lava Lash|a|e|15|d",
            "Lava Shard Staff|w|n|19|s",
            "Lava Spellblade|w|n|19|s",
            "Lava Tendril Pike|w|n|19|s",
            "Leaping Strike|a|c|0|d",
            "Life Dash|a|r|16|h",
            "Life Pulse|a|r|6|h",
            "Lightning Beam|a|u|20|d",
            "Lightning Burst|a|e|7|d",
            "Lightning Strikes|a|r|4|d",
            "Luminous Greatstaff|w|n|18|s",
            "Mage Plate Armor|c|n|21|m",
            "Mage Plate Helmet|h|n|21|m",
            "Mage's Spellbook|w|n|5|s",
            "Magic Mallet|w|n|5|s",
            "Magic Trident|w|n|8|s",
            "Magma Infused Staff|w|n|20|s",
            "Magma Infused Waraxe|w|n|19|p",
            "Mana Infused Spellblade|w|n|17|s",
            "Mercenary Armor|c|n|5|w",
            "Mercenary Helmet|h|n|5|w",
            "Midgardian Guardian Armor|c|n|11|g",
            "Midgardian Guardian Helmet|h|n|11|g",
            "Midgardian Mage Armor|c|n|11|m",
            "Midgardian Mage Helmet|h|n|11|m",
            "Midgardian Warrior Armor|c|n|11|w",
            "Midgardian Warrior Helmet|h|n|11|w",
            "Mighty Cleave|a|e|1|",
            "Mighty Flatblade|w|n|13|p",
            "Mighty Frozen Greatsword|w|n|20|p",
            "Mighty Fusion Maul|w|n|16|p",
            "Mighty Fusion Spellblade|w|n|16|s",
            "Mighty Leap|a|r|8|d",
            "Mjolnir|w|l|11|p",
            "Molten Ball|a|e|12|d",
            "Molten Blade|w|n|13|p",
            "Molten Forged Guardian Armor|c|n|19|g",
            "Molten Forged Guardian Helmet|h|n|19|g",
            "Molten Forged Mage Armor|c|n|19|m",
            "Molten Forged Mage Helmet|h|n|19|m",
            "Molten Forged Warrior Armor|c|n|19|w",
            "Molten Forged Warrior Helmet|h|n|19|w",
            "Molten Greataxe|w|n|13|p",
            "Molten Maul|w|n|0|p",
            "Molten Shards|a|e|19|d",
            "Moon Crystal Spell Blade|w|n|12|s",
            "Moonlight Staff|w|n|10|s",
            "Mossy Greatsword|w|n|20|p",
            "Mystery Matter|a|e|12|d",
            "Mythical Guardian Armor|c|n|8|g",
            "Mythical Guardian Helmet|h|n|8|g",
            "Mythical Mage Armor|c|n|8|m",
            "Mythical Mage Helmet|h|n|8|m",
            "Mythical Warrior Armor|c|n|8|w",
            "Mythical Warrior Helmet|h|n|8|w",
            "Nature Guardian Armor|c|n|3|g",
            "Nature Guardian Helmet|h|n|3|g",
            "Nature Mage Armor|c|n|3|m",
            "Nature Mage Helmet|h|n|3|m",
            "Nature Scythe|w|n|18|p",
            "Nature Spellblade|w|n|3|s",
            "Nature Warrior Armor|c|n|3|w",
            "Nature Warrior Helmet|h|n|3|w",
            "Norse Blade|w|n|11|p",
            "Norse Greataxe|w|n|11|p",
            "Northern Runic Blade|w|n|11|p",
            "Northern Spellstaff|w|n|11|s",
            "Novice Armor|c|n|5|w",
            "Novice Helmet|h|n|5|w",
            "Novice Wand|w|n|5|s",
            "Oathsworn Guardian Armor|c|n|9|g",
            "Oathsworn Guardian Helmet|h|n|9|g",
            "Oathsworn Halberd|w|n|9|p",
            "Oathsworn Hammer|w|n|9|p",
            "Oathsworn Mage Armor|c|n|9|m",
            "Oathsworn Mage Helmet|h|n|9|m",
            "Oathsworn Spellblade|w|n|9|s",
            "Oathsworn Spellscythe|w|n|9|s",
            "Oathsworn Staff And Tome|w|n|9|s",
            "Oathsworn Sword And Shield|w|n|9|p",
            "Oathsworn Warrior Armor|c|n|9|w",
            "Oathsworn Warrior Helmet|h|n|9|w",
            "Ocean Dweller's Mageblade|w|n|8|s",
            "Ocean Pearl Staff|w|n|2|s",
            "Ocean Splitter|w|n|13|p",
            "Oceanic Greatsword|w|n|2|p",
            "Oni Guardian Armor|c|n|22|g",
            "Oni Guardian Helmet|h|n|22|g",
            "Oni Mage Cloak|h|n|22|m",
            "Oni Mage Robes|c|n|22|m",
            "Oni Warrior Armor|c|n|22|w",
            "Oni Warrior Helmet|h|n|22|w",
            "Oni's Bell Staff|w|n|22|s",
            "Oni's Dadao|w|n|22|p",
            "Oni's Kanabo|w|n|22|p",
            "Oni's Naginata|w|n|22|s",
            "Onyx Empowered Greatsword|w|n|13|p",
            "Onyx Hammer|w|n|20|p",
            "Onyx Spell Scythe|w|n|20|s",
            "Onyx Staff|w|n|5|s",
            "Oracle's Ascendance|w|l|0|s",
            "Oracle's Gaze|w|l|0|s",
            "Oracle's Revelation|w|l|0|s",
            "Oracle's Wisdom|w|l|0|s",
            "Orb Of Destruction|a|e|16|d",
            "Overcharge|a|r|16|d",
            "Overgrown War Scythe|w|n|7|p",
            "Overlord's Guardian Armor|c|n|17|g",
            "Overlord's Guardian Hat|h|n|17|g",
            "Overlord's Mage Hat|h|n|17|m",
            "Overlord's Mage Robes|c|n|17|m",
            "Overlord's Manablade|w|l|17|s",
            "Overlord's Rageblade|w|l|17|p",
            "Overlord's Warrior Armor|c|n|17|w",
            "Overlord's Warrior Hat|h|n|17|w",
            "Phantom Blades|a|e|8|d",
            "Phantom Flames|a|e|13|d",
            "Phantom Striker|a|e|8|d",
            "Phase Barrage|a|n|14|d",
            "Phoenix Greatstaff|w|l|18|s",
            "Piercing Rain|a|u|20|d",
            "Piercing Roots|a|r|7|d",
            "Pink Pearl Spellscythe|w|n|15|s",
            "Pirate King's Guardian Armor|c|n|13|g",
            "Pirate King's Guardian Helmet|h|n|13|g",
            "Pirate King's Mage Halo|h|n|13|m",
            "Pirate King's Mage Robes|c|n|13|m",
            "Pirate King's Warrior Armor|c|n|13|w",
            "Pirate King's Warrior Helmet|h|n|13|w",
            "Plasma Infused Cutlass|w|n|16|s",
            "Plasma Spellblade|w|n|16|s",
            "Plasma Twin Spellblade|w|n|16|s",
            "Poison Cloud|a|r|4|d",
            "Poison Spear|w|n|8|s",
            "Pulse Beam|a|r|8|d",
            "Pulse Waves|a|r|16|d",
            "Pulsefire|a|r|13|d",
            "Pulverizer|w|n|5|p",
            "Raider's Guardian Armor|c|n|8|g",
            "Raider's Guardian Helmet|h|n|8|g",
            "Raider's Mage Armor|c|n|8|m",
            "Raider's Mage Helmet|h|n|8|m",
            "Raider's Warrior Armor|c|n|8|w",
            "Raider's Warrior Helmet|h|n|8|w",
            "Red Knight Armor|c|n|5|w",
            "Red Knight Helmet|h|n|5|w",
            "Redemption|a|u|4|h",
            "Reinforced Guardian Armor|c|n|18|g",
            "Reinforced Guardian Helmet|h|n|18|g",
            "Reinforced Ice Blade|w|n|20|p",
            "Reinforced Steel Sword|w|n|20|p",
            "Rejuvenating Spray|a|u|20|h",
            "Rending Slice|a|r|18|d",
            "Revitalize|a|e|7|h",
            "Rift Beam|a|e|22|d",
            "Riptide Guardian Armor|c|n|2|g",
            "Riptide Guardian Helmet|h|n|2|g",
            "Riptide Mage Armor|c|n|2|m",
            "Riptide Mage Helmet|h|n|2|m",
            "Riptide Warrior Armor|c|n|2|w",
            "Riptide Warrior Helmet|h|n|2|w",
            "Rogue Guardian Armor|c|n|17|g",
            "Rogue Guardian Hood|h|n|17|g",
            "Rogue Mage Hood|h|n|17|m",
            "Rogue Mage Robes|c|n|17|m",
            "Rogue Warrior Armor|c|n|17|w",
            "Rogue Warrior Hood|h|n|17|w",
            "Rogue's Rapier|w|n|5|p",
            "Royal Crimson Greatsword|w|n|18|p",
            "Royal Katana|w|n|15|p",
            "Royal Slicer|w|n|20|p",
            "Ruby Greatsword|w|n|15|p",
            "Ruby Staff|w|n|13|s",
            "Runic Hammer|w|n|20|p",
            "Runic Mace|w|n|11|s",
            "Runic Pike|w|n|17|s",
            "Runic Spellscythe|w|n|17|s",
            "Runic Strike|a|u|17|d",
            "Sacrificial Orbs|a|e|1|",
            "Sakura Greatstaff|w|l|15|s",
            "Sakura Katana|w|l|15|p",
            "Salvaged Guardian Armor|c|n|17|g",
            "Salvaged Guardian Helmet|h|n|17|g",
            "Salvaged Mage Hat|h|n|17|m",
            "Salvaged Mage Robes|c|n|17|m",
            "Salvaged Warrior Armor|c|n|17|w",
            "Salvaged Warrior Helmet|h|n|17|w",
            "Samurai Guardian Armor|c|n|15|g",
            "Samurai Guardian Helmet|h|n|15|g",
            "Samurai Mage Helmet|h|n|15|m",
            "Samurai Mage Robes|c|n|15|m",
            "Samurai Warrior Armor|c|n|15|w",
            "Samurai Warrior Hairband|h|n|15|w",
            "Sandstone Guardian Armor|c|n|4|g",
            "Sandstone Guardian Helmet|h|n|4|g",
            "Sandstone Mage Cloak|h|n|4|m",
            "Sandstone Mage Robes|c|n|4|m",
            "Sandstone Warrior Armor|c|n|4|w",
            "Sandstone Warrior Helmet|h|n|4|w",
            "Sapphire Greatstaff|w|n|18|s",
            "Sapphire Spell Dagger|w|n|20|s",
            "Sapphire Spellspear|w|n|15|s",
            "Sapphire Stone Wand|w|n|17|s",
            "Sea King's Greatstaff|w|l|2|s",
            "Sea King's Trident|w|l|2|p",
            "Sea Serpent's Wings|w|l|8|s",
            "Sea Staff|w|n|2|s",
            "Seafarer's Lost Blade|w|n|8|p",
            "Seafarer's Magic Device|w|n|8|s",
            "Searing Beam|a|u|20|d",
            "Seishin Cleaver|w|n|22|p",
            "Seishin Club|w|n|22|s",
            "Seishin Crescent|w|n|22|p",
            "Seishin Guardian Armor|c|n|22|g",
            "Seishin Guardian Helmet|h|n|22|g",
            "Seishin Mage Cloak|h|n|22|m",
            "Seishin Mage Robes|c|n|22|m",
            "Seishin Staff|w|n|22|s",
            "Seishin Warrior Armor|c|n|22|w",
            "Seishin Warrior Helmet|h|n|22|w",
            "Serpent Pike|w|n|2|p",
            "Serpent Scimitars|w|n|2|p",
            "Sharktooth Blade|w|n|8|p",
            "Shattered Magma Blade|w|n|19|p",
            "Shatterstrike|a|e|1|",
            "Shock Blast|a|r|0|d",
            "Shock Wave|a|r|0|d",
            "Skull Flames|a|e|13|d",
            "Slam|a|u|4|d",
            "Smite|a|r|8|d",
            "Snow Elemental Staff|w|n|20|s",
            "Snowy Greatstaff|w|n|20|s",
            "Solar Beam|a|e|9|d",
            "Solar Essence Staff|w|n|12|s",
            "Solar Greatsword|w|n|12|p",
            "Solar Katana|w|n|12|p",
            "Solar Staff|w|n|13|s",
            "Soul Drain|a|e|11|d",
            "Soulstealer Greatsword|w|l|13|p",
            "Space Guardian Armor|c|n|12|g",
            "Space Guardian Helmet|h|n|12|g",
            "Space Mage Armor|c|n|12|m",
            "Space Mage Helmet|h|n|12|m",
            "Space Warrior Armor|c|n|12|w",
            "Space Warrior Helmet|h|n|12|w",
            "Spear Strike|a|r|2|d",
            "Spiked Club|w|n|5|p",
            "Spinning Blade Smash|a|e|22|d",
            "Spirit Bomb|a|u|8|d",
            "Spirit Link|a|e|22|h",
            "Staff of Heat|w|n|15|s",
            "Staff of the Gods|w|l|13|s",
            "Staff of the North|w|n|11|s",
            "Star Barrage|a|r|16|d",
            "Starfall|a|r|16|d",
            "Starter Wand|w|c|0|s",
            "Steel Serrated Sword|w|n|5|p",
            "Steel Strongsword|w|n|20|p",
            "Stone Scythe|w|n|17|p",
            "Stone Strongsword|w|n|13|p",
            "Storm Blast|a|e|0|d",
            "Storm Wave|a|e|0|d",
            "Sunken Blade|w|n|3|p",
            "Sunlight Staff|w|n|10|s",
            "Taunt|a|c|5|g",
            "Taunting Aura|a|u|20|g",
            "Templar Blade|w|n|13|p",
            "Templar Hood|h|n|5|m",
            "Templar Robes|c|n|5|m",
            "Thunderous Blast|a|u|10|d",
            "Timelost Greatsword|w|n|18|p",
            "Timelost Guardian Armor|c|n|18|g",
            "Timelost Guardian Helmet|h|n|18|g",
            "Timelost Mage Armor|c|n|18|m",
            "Timelost Mage Helmet|h|n|18|m",
            "Timelost Spellbook|w|n|18|s",
            "Timelost Warhammer|w|n|18|p",
            "Timelost Warrior Armor|c|n|18|w",
            "Timelost Warrior Helmet|h|n|18|w",
            "Titan's Greataxe|w|n|13|p",
            "Titan-forged_Guardian_Armor|c|n|10|g",
            "Titan-forged_Guardian_Helmet|h|n|10|g",
            "Titan-forged_Mage_Armor|c|n|10|m",
            "Titan-forged_Mage_Helmet|h|n|10|m",
            "Titan-forged_Warrior_Armor|c|n|10|w",
            "Titan-forged_Warrior_Helmet|h|n|10|w",
            "Titanium Guardian Armor|c|n|16|g",
            "Titanium Guardian Helmet|h|n|16|g",
            "Titanium Mage Armor|c|n|16|m",
            "Titanium Mage Helmet|h|n|16|m",
            "Titanium Warrior Armor|c|n|16|w",
            "Titanium Warrior Helmet|h|n|16|w",
            "Toxic Spellscythe|w|n|17|s",
            "Toxic Warspear|w|n|15|p",
            "Tribal Mage Armor|c|n|18|m",
            "Tribal Mage Hood|h|n|18|m",
            "Tribal Staff|w|n|10|s",
            "Tribal Warrior Helmet|h|n|18|w",
            "Tribal_Warrior_Armor|c|n|18|w",
            "Triple Blade Throw|a|e|16|d",
            "Triple Quake|a|e|22|d",
            "Triton Guardian Armor|c|n|2|g",
            "Triton Guardian Helmet|h|n|2|g",
            "Triton Mage Armor|c|n|2|m",
            "Triton Mage Helmet|h|n|2|m",
            "Triton Warrior Armor|c|n|2|w",
            "Triton Warrior Helmet|h|n|2|w",
            "Tsunami|a|u|17|d",
            "Tundra Guardian Armor|c|n|20|g",
            "Tundra Guardian Helmet|h|n|20|g",
            "Tundra Mage Cloak|h|n|20|m",
            "Tundra Mage Robes|c|n|20|m",
            "Tundra Warrior Armor|c|n|20|w",
            "Tundra Warrior Helmet|h|n|20|w",
            "Twin Bladed Slicer|w|n|20|p",
            "Twin Slash|a|e|12|d",
            "Twisted Wood Greatstaff|w|l|3|s",
            "Twisted Wood Greatsword|w|l|3|p",
            "Universal Heal|a|e|13|h",
            "Unstable Warp|a|l|1|",
            "Valhalla Guardian Armor|c|n|11|g",
            "Valhalla Guardian Helmet|h|n|11|g",
            "Valhalla Mage Armor|c|n|11|m",
            "Valhalla Mage Helmet|h|n|11|m",
            "Valhalla Warrior Armor|c|n|11|w",
            "Valhalla Warrior Helmet|h|n|11|w",
            "Vampiric Greatstaff|w|n|18|s",
            "Vengeful Taunt|a|e|1|",
            "Viking Hatchets|w|n|11|p",
            "Viking Sceptre|w|n|11|s",
            "Viking Shield|w|n|11|s",
            "Violet Spellblade|w|n|15|s",
            "Void Beam|a|r|10|d",
            "Void Dragon|a|e|22|d",
            "Void Greatsword|w|n|12|p",
            "Void Plate Armor|c|n|13|g",
            "Void Plate Helmet|h|n|13|g",
            "Void Spell Blade|w|n|12|s",
            "Void Spell Dagger|w|n|12|s",
            "Void Spheres|a|r|8|d",
            "Voidborn Guardian Armor|c|n|1|g",
            "Voidborn Guardian Helmet|h|n|1|g",
            "Voidborn Mage Armor|c|n|1|m",
            "Voidborn Mage Helmet|h|n|1|m",
            "Voidborn Warrior Armor|c|n|1|w",
            "Voidborn Warrior Helmet|h|n|1|w",
            "Voidborn's Embrace|w|l|1|s",
            "Voidborn's Malice|w|l|1|p",
            "Voidfallen's Effigy & Edict|w|x|1|s",
            "Voidflames|a|e|1|",
            "Voidspire & Abyssal Veil|w|x|1|p",
            "Volcanic Greatsword|w|n|19|p",
            "Vortex|a|e|17|d",
            "Vortex Grenade|a|e|12|d",
            "War-forged Guardian Armor|c|n|16|g",
            "War-forged Guardian Helmet|h|n|16|g",
            "War-forged Mage Armor|c|n|16|m",
            "War-forged Mage Helmet|h|n|16|m",
            "War-forged Warrior Armor|c|n|16|w",
            "War-forged Warrior Helmet|h|n|16|w",
            "Warlord Plate Armor|c|n|21|w",
            "Warlord Plate Helmet|h|n|21|w",
            "Water Elemental Spellblade|w|n|20|s",
            "Water Orb|a|r|2|d",
            "Whirlwind|a|u|4|d",
            "Wind Blast|a|e|7|d",
            "Winter Lord's Guardian Armor|c|n|20|g",
            "Winter Lord's Guardian Helmet|h|n|20|g",
            "Winter Lord's Mage Cloak|h|n|20|m",
            "Winter Lord's Mage Robes|c|n|20|m",
            "Winter Lord's Warrior Armor|c|n|20|w",
            "Winter Lord's Warrior Helmet|h|n|20|w",
            "Winterborne|w|l|20|p",
            "Yokai Transformation|a|e|22|d",
        }
    local function nameKey(argument)
        local value = string.lower(tostring(argument or ""))
        value = string.gsub(value, "[^a-z0-9]", "")
        return (string.gsub(value, "armour", "armor"))
    end
    inventoryAutomation.nameKey = nameKey
    inventoryAutomation.items = {}
    inventoryAutomation.dungeons = dungeons
    for index = 1, #sharedValue5, 1 do
        local name2, sharedValue6, sharedValue7, sharedValue8, sharedValue9 =
            string.match(sharedValue5[index], "^(.-)|(%a)|(%a)|(%d+)|(%a*)$")
        if name2 then
            index = #inventoryAutomation.items + 1
            inventoryAutomation.items[index] = {
                name = name2,
                key = nameKey(name2),
                kind = sharedValue2[sharedValue6] or "weapon",
                tier = sharedValue3[sharedValue7] or "",
                dung = dungeons[tonumber(sharedValue8)] or "",
                sub = sharedValue4[sharedValue9] or "",
            }
        end
    end
    local cfg = {
        common = "sellCommon",
        uncommon = "sellUncommon",
        rare = "sellRare",
        epic = "sellEpic",
        legendary = "sellLegendary",
        ultimate = "sellUltimate",
    }
    inventoryAutomation.TIER_CFG = cfg
    local order = { "common", "uncommon", "rare", "epic", "legendary", "ultimate" }
    inventoryAutomation.TIER_ORDER = order
    local long, sharedValue10 =
        {
            common = "Common",
            uncommon = "Uncommon",
            rare = "Rare",
            epic = "Epic",
            legendary = "Legendary",
            ultimate = "Ultimate",
        }, { common = "Com", uncommon = "Unc", rare = "Rare", epic = "Epic", legendary = "Leg", ultimate = "Ult" }
    inventoryAutomation.TIER_LONG = long
    local function helper(argument)
        if argument == true then
            return true
        end
        if type(argument) == "table" then
            for index2, entry in ipairs(order) do
                if argument[entry] == true then
                    return argument
                end
            end
        end
        return nil
    end
    inventoryAutomation.keptRule = function(argument)
        local sellKeep = config.sellKeep
        if type(sellKeep) ~= "table" then
            return nil
        end
        return helper(sellKeep[nameKey(argument)])
    end
    inventoryAutomation.isKept = function(argument, argument2)
        local value = inventoryAutomation.keptRule(argument)
        if value == nil then
            return false
        end
        if value == true then
            return true
        elseif argument2 == nil then
            return true
        end
        return value[string.lower(tostring(argument2))] == true
    end
    inventoryAutomation.setKept = function(argument, argument2)
        if type(config.sellKeep) ~= "table" then
            config.sellKeep = {}
        end
        local value = nameKey(argument)
        if type(argument2) ~= "table" then
            config.sellKeep[value] = argument2 and true or nil
            return
        end
        local value2, value3 = {}, 0
        for index2, entry in ipairs(order) do
            if argument2[entry] == true then
                value3 += 1
                value2[entry] = true
            end
        end
        if value3 == #order then
            config.sellKeep[value] = true
        elseif value3 > 0 then
            config.sellKeep[value] = value2
        else
            config.sellKeep[value] = nil
        end
    end
    inventoryAutomation.ruleText = function(argument, argument2)
        if type(argument) ~= "table" then
            return ""
        end
        local value = {}
        for index2, entry in ipairs(order) do
            if argument[entry] == true then
                value[#value + 1] = (argument2 and sharedValue10 or long)[entry]
            end
        end
        return table.concat(value, ", ")
    end
    inventoryAutomation.keptCount = function()
        local value = 0
        if type(config.sellKeep) == "table" then
            for key, entry in pairs(config.sellKeep) do
                value = if helper(entry) ~= nil then value + 1 else value
            end
        end
        return value
    end
    inventoryAutomation.worn = nil
    inventoryAutomation.wornKey = function(argument)
        local uniqueItemId = argument.UniqueItemID
        if type(uniqueItemId) == "string" then
            if uniqueItemId ~= "" then
                if uniqueItemId ~= "none" then
                    return "uid:" .. uniqueItemId
                end
            end
        end
        return "name:" .. string.lower(tostring(argument.name))
    end
    inventoryAutomation.wornFile = function()
        local localPlayer = getService("Players").LocalPlayer
        return "HarvardLabs/data/worn_"
            .. string.lower(localPlayer and localPlayer.Name or "unknown")
            .. ".json"
    end
    inventoryAutomation.wornLoad = function()
        if inventoryAutomation.worn then
            return inventoryAutomation.worn
        end
        inventoryAutomation.worn = {}
        pcall(function()
            if isfile and isfile(inventoryAutomation.wornFile()) then
                local value = getService("HttpService"):JSONDecode(readfile(inventoryAutomation.wornFile()))
                if type(value) == "table" then
                    for key, entry in pairs(value) do
                        if type(key) == "string" then
                            if tonumber(entry) then
                                inventoryAutomation.worn[key] = tonumber(entry)
                            end
                        end
                    end
                end
            end
        end)
        return inventoryAutomation.worn
    end
    inventoryAutomation.noteWorn = function(argument)
        if type(argument) ~= "table" then
            return
        end
        local value = inventoryAutomation.wornLoad()
        local timestamp, value2 = os.time(), false
        for key, entry in pairs(argument.abilities or {}) do
            if type(entry) == "table" then
                if type(entry.equipped) == "table" then
                    if type(entry.name) == "string" then
                        key = false
                        for key2, entry2 in pairs(entry.equipped) do
                            key = if entry2 == true then true else key
                        end
                        local value3 = inventoryAutomation.wornKey(entry)
                        if key then
                            if value[value3] == nil then
                                value[value3] = timestamp
                                value2 = true
                            else
                                if timestamp - value[value3] > 600 then
                                    value[value3] = timestamp
                                    value2 = true
                                end
                            end
                        end
                    end
                end
            end
        end
        if value2 then
            argument = 2 * (tonumber(config.sellWornHours) or 24) * 3600
            for key3, entry3 in pairs(value) do
                if timestamp - entry3 > argument then
                    value[key3] = nil
                end
            end
            pcall(function()
                writefile(inventoryAutomation.wornFile(), getService("HttpService"):JSONEncode(value))
            end)
        end
    end
    inventoryAutomation.wasWorn = function(argument)
        local value = inventoryAutomation.wornLoad()[inventoryAutomation.wornKey(argument)]
        return value ~= nil and os.time() - value <= (tonumber(config.sellWornHours) or 24) * 3600
    end
    inventoryAutomation.abilityFree = function(argument)
        if type(argument) ~= "table" then
            return false
        elseif type(argument.equipped) ~= "table" then
            return false
        elseif type(argument.name) ~= "string" then
            return false
        elseif tonumber(argument.levelReq) == nil then
            return false
        end
        for key, entry in pairs(argument.equipped) do
            if entry == true then
                return false
            end
        end
        return not inventoryAutomation.wasWorn(argument)
    end
    inventoryAutomation.shouldSell = function(argument)
        if type(argument) ~= "table" then
            return false
        end
        local value = cfg[string.lower(tostring(argument.rarity or ""))]
        if value then
            if config[value] ~= true then
                return false
            end
        else
            return false
        end
        if inventoryAutomation.isKept(argument.name, argument.rarity) then
            return false
        end
        local value2, value3 = tonumber(argument.levelReq), tonumber(config.sellKeepLevel) or 0
        if value3 > 0 then
            if value2 then
                if value2 >= value3 then
                    return false
                end
            end
        end
        return true
    end
    local sharedValue11 = {
        { inv = "weapons", out = "weapon", pre = 8 },
        { inv = "helmets", out = "helmet", pre = 8 },
        { inv = "chests", out = "chest", pre = 7 },
        { inv = "abilities", out = "ability", pre = 9 },
    }
    inventoryAutomation.plan = function(argument, argument2)
        local value, value2, value3, value4 =
            { helmet = {}, ability = {}, chest = {}, weapon = {} }, {}, {}, {}
        pcall(function()
            if context.BG then
                if context.BG.keepers then
                    value4 = context.BG.keepers(argument) or {}
                end
            end
        end)
        pcall(inventoryAutomation.noteWorn, argument)
        local value5 = 0
        for index2, entry in ipairs(sharedValue11) do
            local iteratePairs, value6 = pairs, argument[entry.inv] or {}
            for key, entry2 in iteratePairs(value6) do
                index2 = entry.out == "ability" and inventoryAutomation.abilityFree(entry2)
                    or entry.out ~= "ability" and type(entry2) == "table" and entry2.equipped == false
                if index2 then
                    if inventoryAutomation.shouldSell(entry2) then
                        local value7 = entry.inv .. ":" .. tostring(key)
                        if not value4[value7] then
                            local value8 = tonumber(string.sub(tostring(key), entry.pre))
                                or tonumber(string.match(tostring(key), "(%d+)$"))
                            if value8 then
                                local value9 = value[entry.out]
                                if argument2 then
                                    value9[#value9 + 1] = value8
                                else
                                    local value10 = type(entry2.UniqueItemID) == "string"
                                            and entry2.UniqueItemID ~= ""
                                            and entry2.UniqueItemID
                                        or "none"
                                    value9[#value9 + 1] = tostring(value8) .. ":" .. value10
                                end
                                value9 = value5 + 1
                                if type(entry2.UniqueItemID) == "string" then
                                    if entry2.UniqueItemID ~= "" then
                                        value2[entry2.UniqueItemID] = true
                                    end
                                end
                                value3[#value3 + 1] = {
                                    cat = entry.inv,
                                    key = tostring(key),
                                    id = value8,
                                    name = tostring(entry2.name),
                                    rarity = tostring(entry2.rarity),
                                    req = tonumber(entry2.levelReq),
                                    price = tonumber(entry2.sellPrice),
                                    uid = entry2.UniqueItemID,
                                }
                                value5 = value9
                            end
                        end
                    end
                end
            end
        end
        return value, value5, value2, value3
    end
    inventoryAutomation.planList = function(argument)
        local value, value2 = {}, {}
        pcall(function()
            if context.BG then
                if context.BG.keepers then
                    value2 = context.BG.keepers(argument) or {}
                end
            end
        end)
        for index2, entry in ipairs(sharedValue11) do
            local iteratePairs, value3 = pairs, argument[entry.inv] or {}
            for key, entry2 in iteratePairs(value3) do
                index2 = entry.out == "ability" and inventoryAutomation.abilityFree(entry2)
                    or entry.out ~= "ability" and type(entry2) == "table" and entry2.equipped == false
                if index2 then
                    if inventoryAutomation.shouldSell(entry2) then
                        local value4 = entry.inv .. ":" .. tostring(key)
                        if not value2[value4] then
                            local value5 = tonumber(string.match(tostring(key), "%d+"))
                            if value5 then
                                value[#value + 1] = {
                                    inv = entry.inv,
                                    out = entry.out,
                                    key = key,
                                    id = value5,
                                    name = tostring(entry2.name or "?"),
                                    uid = type(entry2.UniqueItemID) == "string"
                                            and entry2.UniqueItemID ~= ""
                                            and entry2.UniqueItemID
                                        or nil,
                                }
                            end
                        end
                    end
                end
            end
        end
        return value
    end
    inventoryAutomation.logSale = function(argument)
        local localPlayer = getService("Players").LocalPlayer
        argument.t, argument.time, argument.job, argument.place =
            os.time(), os.date("%m/%d %I:%M:%S %p"), game.JobId, game.PlaceId
        local value, value2 =
            getService("HttpService"):JSONEncode(argument) .. "\10",
            "HarvardLabs/logs/sales_"
                .. string.lower(localPlayer and localPlayer.Name or "unknown")
                .. ".jsonl"
        if appendfile then
            if isfile then
                if isfile(value2) then
                    appendfile(value2, value)
                else
                    writefile(value2, value)
                end
            else
                writefile(value2, value)
            end
        else
            writefile(value2, value)
        end
    end
    local function helper2()
        local remotes = sharedValue:FindFirstChild("remotes")
        if not remotes then
            return nil, nil
        end
        return remotes:FindFirstChild("sellItemEvent"), remotes:FindFirstChild("reloadInvy")
    end
    inventoryAutomation.inLobby = function()
        return game.PlaceId == 77649408247578
    end
    inventoryAutomation.sellNow = function()
        if context.isEvent then
            if context.isEvent() then
                inventoryAutomation.note = "not in an event run - its bag is the event's class kits"
                return 0, false
            end
        end
        local value = os.clock()
        while true do
            local value2 = context.BG and context.BG.keepers
            if not (if value2 then not value2 else os.clock() - value < 20) then
                break
            end
            task.wait(0.25)
        end
        if context.BG then
            if not context.BG.keepers then
                inventoryAutomation.note = "waiting for Gear, Spells & Stats (the menu is still loading)"
                return 0, false
            end
        else
            inventoryAutomation.note = "waiting for Gear, Spells & Stats (the menu is still loading)"
            return 0, false
        end
        pcall(function()
            if context.BG then
                if context.BG.beforeSale then
                    context.BG.beforeSale()
                end
            end
        end)
        local value3, value4 = helper2()
        if not value3 or not value4 then
            inventoryAutomation.note = "sell remotes are missing"
            return 0, false
        end
        local success, value5 = pcall(function()
            return value4:InvokeServer()
        end)
        if success then
            if type(value5) ~= "table" then
                inventoryAutomation.note = "the inventory would not open"
                return 0, false
            end
        else
            inventoryAutomation.note = "the inventory would not open"
            return 0, false
        end
        value = inventoryAutomation.inLobby()
        success = not value
        local value6, asked, value7, items = inventoryAutomation.plan(value5, success)
        inventoryAutomation.at = os.clock()
        if asked == 0 then
            inventoryAutomation.note = "nothing matched the rules"
            return 0, true
        end
        local value8, value9, success2 =
            pcall, inventoryAutomation.logSale, {
                phase = "selling",
                where = (if value then success else "dungeon") or "lobby",
                asked = asked,
                items = items,
            }
        success2.bestGear = context.BG
                and context.BG.lastMoves
                and os.time() - (context.BG.lastMoves.at or 0) < 120
                and context.BG.lastMoves.list
            or nil
        value8(value9, success2)
        if value then
            if not (pcall(function()
                value3:FireServer(value6)
            end)) then
                inventoryAutomation.note = "the sell remote refused"
                return 0, false
            end
        else
            inventoryAutomation.note = ("selling %d item%s in the dungeon"):format(
                asked,
                asked == 1 and "" or "s"
            )
            for key, entry in pairs(value6) do
                if context.RT then
                    if context.RT.destroyed then
                        break
                    end
                end
                for index2, entry2 in ipairs(entry) do
                    if context.RT then
                        if context.RT.destroyed then
                            break
                        end
                    end
                    local value10 = { helmet = {}, ability = {}, chest = {}, weapon = {} }
                    value10[key] = { entry2 }
                    pcall(function()
                        value3:FireServer(value10)
                    end)
                    task.wait(tonumber(config.sellDelay) or 1)
                end
            end
        end
        task.wait(tonumber(config.sellCheckAfter) or 2)
        value8 = nil
        success2, value = pcall(function()
            return value4:InvokeServer()
        end)
        if success2 then
            if type(value) == "table" then
                success = 0
                for entry3 in pairs(value7) do
                    success += 1
                end
                if success == asked then
                    value9, items = { "weapons", "helmets", "chests", "abilities" }, 0
                    for index3, entry4 in ipairs(value9) do
                        for key2, entry5 in pairs(value[entry4] or {}) do
                            items = if type(entry5) == "table"
                                then if value7[entry5.UniqueItemID] then items + 1 else items
                                else items
                        end
                    end
                    value8 = asked - items
                else
                    local X, value11 = inventoryAutomation.plan(value)
                    value8 = math.max(0, asked - value11)
                end
            end
        end
        if value8 == nil then
            inventoryAutomation.note = ("asked to sell %d; the bag would not open to check"):format(asked)
            return 0, true
        end
        inventoryAutomation.lastSold, inventoryAutomation.totalSold =
            value8, inventoryAutomation.totalSold + value8
        pcall(inventoryAutomation.logSale, { phase = "sold", gone = value8, asked = asked })
        if value8 == 0 then
            inventoryAutomation.note = ("the game sold nothing (%d asked)"):format(asked)
            if context.log then
                context.log("AutoSell", inventoryAutomation.note)
            end
            if context.notify then
                context.notify("warning", "Auto sell", ("The game sold nothing (%d asked)."):format(asked))
            end
            return 0, true
        end
        inventoryAutomation.note = ("sold %d item%s"):format(value8, value8 == 1 and "" or "s")
            .. (value8 < asked and (" of %d asked"):format(asked) or "")
            .. (inventoryAutomation.inLobby() and " in the lobby" or " in the dungeon")
        if context.log then
            context.log("AutoSell", inventoryAutomation.note)
        end
        if context.notify then
            context.notify("sell", "Auto sell", ("Sold %d item%s."):format(value8, value8 == 1 and "" or "s"))
        end
        return value8, true
    end
    local sharedValue12 = getService("HttpService")
    local function helper3()
        local localPlayer = getService("Players").LocalPlayer
        return "HarvardLabs/data/sellgames_" .. (localPlayer and localPlayer.Name or "unknown") .. ".json"
    end
    local sharedValue13
    local function helper4()
        if sharedValue13 then
            local value = sharedValue13
            return value
        end
        sharedValue13 = { games = 0, job = "" }
        pcall(function()
            if isfile then
                if isfile(helper3()) then
                    local value2 = sharedValue12:JSONDecode(readfile(helper3()))
                    if type(value2) == "table" then
                        local value3, value4, games, job =
                            sharedValue13,
                            sharedValue13,
                            tonumber(value2.games) or 0,
                            tostring(value2.job or "")
                        value3.games = games
                        value4.job = job
                    end
                end
            end
        end)
        local value5 = sharedValue13
        return value5
    end
    local function helper5()
        pcall(function()
            writefile(helper3(), sharedValue12:JSONEncode(helper4()))
        end)
    end
    inventoryAutomation.games = function()
        return helper4().games
    end
    inventoryAutomation.sellAfter = function()
        return math.clamp(math.floor(tonumber(config.sellAfterGames) or 10), 1, 50)
    end
    inventoryAutomation.sellDue = function()
        return config.autoSell == true and helper4().games >= inventoryAutomation.sellAfter()
    end
    inventoryAutomation.lobbyJob = nil
    inventoryAutomation.busy = false
    inventoryAutomation.holdStart = function()
        if config.autoSell ~= true then
            return false
        elseif inventoryAutomation.inLobby() then
            if context.RT then
                if context.RT.modHalt then
                    return false
                end
            end
        else
            return false
        end
        if not inventoryAutomation.busy then
            if not (inventoryAutomation.lobbyJob ~= game.JobId) then
                return false
            end
        end
        if inventoryAutomation.holdJob ~= game.JobId then
            inventoryAutomation.holdJob, inventoryAutomation.holdSince = game.JobId, os.clock()
        end
        if os.clock() - inventoryAutomation.holdSince > (tonumber(config.sellHoldMax) or 45) then
            inventoryAutomation.note = "the sale took too long - the run starts anyway"
            return false
        end
        return true
    end
    task.spawn(function()
        local value
        while not (context.RT and context.RT.destroyed) do
            task.wait(1)
            pcall(function()
                if inventoryAutomation.inLobby() then
                    if inventoryAutomation.lobbyJob == game.JobId then
                        return
                    end
                    if config.autoSell ~= true then
                        inventoryAutomation.note = "off"
                        inventoryAutomation.lobbyJob = game.JobId
                        return
                    end
                    if context.RT then
                        if context.RT.modHalt then
                            inventoryAutomation.note = "held by mod detection"
                            return
                        end
                    end
                    value = value or os.clock()
                    if os.clock() - value < (tonumber(config.sellLobbySettle) or 2) then
                        return
                    end
                    local value2 = getService("Players").LocalPlayer
                    if os.clock() - value < (tonumber(config.sellLobbyMin) or 10) then
                        return
                    end
                    local value3 = value2 and (value2:FindFirstChild("leaderstats"))
                    value2 = value3 and (value3:FindFirstChild("Level"))
                    if not (value2 and (tonumber(value2.Value) or 0) > 1) then
                        if os.clock() - value < (tonumber(config.sellLoadWait) or 30) then
                            return
                        end
                        inventoryAutomation.note =
                            "this lobby never showed the account's level - no sale here"
                        inventoryAutomation.lobbyJob = game.JobId
                        return
                    end
                    if inventoryAutomation.busy then
                        return
                    end
                    inventoryAutomation.busy = true
                    local success, D, value4 = pcall(inventoryAutomation.sellNow)
                    inventoryAutomation.busy = false
                    inventoryAutomation.lobbyJob = game.JobId
                    if success then
                        if value4 then
                            helper4().games = 0
                            helper5()
                        end
                    end
                else
                    value = nil
                    if context.isEvent then
                        if context.isEvent() then
                            if config.autoSell == true then
                                inventoryAutomation.note =
                                    "not in an event run - its bag is the event's class kits"
                            end
                            return
                        end
                    end
                    local dungeonName, dungeonStarted =
                        workspace:FindFirstChild("dungeonName"), workspace:FindFirstChild("dungeonStarted")
                    if dungeonName then
                        if tostring(dungeonName.Value) ~= "" then
                            if dungeonStarted then
                                if dungeonStarted.Value == true then
                                    if helper4().job ~= game.JobId then
                                        helper4().job = game.JobId
                                        helper4().games = helper4().games + 1
                                        helper5()
                                        if config.autoSell == true then
                                            inventoryAutomation.note = ("%d of %d games played"):format(
                                                helper4().games,
                                                inventoryAutomation.sellAfter()
                                            )
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if config.autoSell == true then
                        if dungeonName then
                            if tostring(dungeonName.Value) ~= "" then
                                if dungeonStarted then
                                    if dungeonStarted.Value == true then
                                        if helper4().games >= inventoryAutomation.sellAfter() then
                                            if inventoryAutomation.soldJob ~= game.JobId then
                                                if not inventoryAutomation.busy then
                                                    if not (context.RT and context.RT.modHalt) then
                                                        inventoryAutomation.soldJob = game.JobId
                                                        inventoryAutomation.busy = true
                                                        local success2, e, value5 =
                                                            pcall(inventoryAutomation.sellNow)
                                                        inventoryAutomation.busy = false
                                                        if success2 then
                                                            if value5 then
                                                                helper4().games = 0
                                                                helper5()
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
            end)
        end
    end)
end
