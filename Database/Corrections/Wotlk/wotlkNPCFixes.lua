---@class QuestieWotlkNpcFixes
local QuestieWotlkNpcFixes = QuestieLoader:CreateModule("QuestieWotlkNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieWotlkNpcFixes:Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags

    return {
        [15351] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{24.55,55.42}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
            },
        },
        [16281] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{75.16,54.39}}},
        },
        [16361] = {
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{75.16,54.45}}},
        },
        [17977] = {
            [npcKeys.spawns] = {[zoneIDs.THE_BOTANICA]={{-1,-1}}},
        },
        [19220] = {
            [npcKeys.spawns] = {[zoneIDs.THE_MECHANAR]={{-1,-1}}},
        },
        [19481] = {
            [npcKeys.spawns] = {[zoneIDs.NETHERSTORM]={{58.34,86.4}}},
        },
        [23763] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{50.2,29.2},{50.4,26.4},{50.4,27},{50.6,26.6},{51,26.2},{51,27.6},{51.2,25.4},{51.2,28.8},{51.6,25.4},{51.8,27.6},{52,29.6},{52.2,26.4},{52.2,26.6},{52.4,28.6},{52.6,28.6},{52.8,26.4},{52.8,27},{52.8,27.8}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [23954] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_KEEP]={{-1,-1},}},
            [npcKeys.zoneID] = zoneIDs.UTGARDE_KEEP,
        },
        [24028] = { --"Talu Frosthoof", "Bowyer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24031] = { --"Camp Winterhoof Brave"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24032] = { --"Celea Frozenmane", "Wind Rider Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24033] = { --"Bori Wintertotem", "Innkeeper"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24060] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{45.2,27.3}}},
        },
        [24067] = { --"Mahana Frosthoof", "Stable Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24120] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{86.7,59.2}}},
        },
        [24123] = { --"Nokoma Snowseer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24127] = { --"Ahota Whitefrost"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24129] = { --"Chieftain Ashtotem"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24130] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{45.2,27.3}}},
        },
        [24135] = { --"Greatmother Ankha"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24137] = {
            [npcKeys.spawns] = {[zoneIDs.UTGARDE_KEEP]={{-1,-1},}},
            [npcKeys.zoneID] = zoneIDs.UTGARDE_KEEP,
        },
        [24142] = { --"Camp Winterhoof Wind Rider"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24170] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{39.2,50.2},}},
        },
        [24173] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{52.4,3.9},}},
        },
        [24186] = { --"Sage Mistwalker"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24195] = { --"Winterhoof Longrunner"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24209] = { --"Longrunner Skycloud"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24211] = { --"Freed Winterhoof Longrunner"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24213] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{55.00,57.43}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24214] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{55.00,57.43}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24215] = {
            [npcKeys.spawns] = {[zoneIDs.HOWLING_FJORD]={{55.00,57.43}}},
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24234] = { --"Junat the Wanderer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24236] = { --"Wind Tamer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24256] = { --"Wind Tamer Kagan"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24329] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{72,26.4},{70.3,27.3},{68.7,28.1},{66.5,24.9},{69.7,21.5},{72.6,19.9},{73.6,23.1}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24362] = { --"Longrunner Pembe"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24390] = { --"Sage Edan"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24440] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{30.2,26.4},{30.4,27},{30.6,24},{30.8,23.4},{30.8,26.6},{30.8,28.2},{30.8,28.6},{31,24.6},{31,26.4},{31.2,31},{31.6,27.2},{31.6,27.6},{31.8,26},},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [24657] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR]={{45.01,17.41}}},
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [24702] = { --"Greatfather Mahan"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24703] = { --"Chieftain Wintergale"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24706] = { --"Durm Icehide"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24709] = { --"Sage Aeire"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24730] = { --"Wind Tamer Barah"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24733] = { --"Snow Tracker Junek"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [24910] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{38.1, 74.8}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [25335] = { --"Longrunner Proudhoof"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25455] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{50.25,9.66},},},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [25516] = { --"Snow Tracker Grumm"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25602] = { --"Greatmother Taiga"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25604] = { --"Sage Highmesa"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25658] = { --"Longrunner Bristlehorn"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25794] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{70.3,36.7},},},
            [npcKeys.zoneID] = zoneIDs.BOREAN_TUNDRA,
        },
        [25978] = { --"Ambassador Talonga"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25982] = { --"Sage Earth and Sky"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [25983] = { --"Dorain Frosthoof", "Apprentice Wind Tamer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26104] = { --"Iron Eyes"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26156] = { --"Wartook Iceborn"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26157] = { --"Taunka'le Brave"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26158] = { --"Mother Tauranook"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26159] = { --"Taunka'le Evacuee"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26170] = {
            [npcKeys.spawns] = {[zoneIDs.BOREAN_TUNDRA] = {{84.8,41.68},},},
        },
        [26179] = { --"Taunka'le Refugee"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26184] = { --"Taunka'le Refugee"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26488] = { --"Taunka Pack Kodo"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26584] = { --"Sage Paluna"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26633] = {
            [npcKeys.spawns] = {
                [zoneIDs.GRIZZLY_HILLS] = {{51.8,18.2}},
            },
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [26647] = {
            [npcKeys.spawns] = {
                [zoneIDs.DRAGONBLIGHT] = {{54.50,23.62}},
            },
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [26680] = { --"Aiyan Coldwind", "Innkeeper"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26697] = { --"Tewah Chillmane", "Leather Armor Merchant"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26707] = { --"Litoko Icetotem", "Armor Merchant"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26709] = { --"Pahu Frosthoof", "Innkeeper"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26718] = { --"Trader Alorn", "General Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26720] = { --"Danook Stormwhisper", "Trade Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26721] = { --"Halona Stormwhisper", "Stable Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26723] = {
            [npcKeys.spawns] = {[zoneIDs.THE_NEXUS] = {{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.THE_NEXUS,
        },
        [26725] = { --"Wind Tamer Oril"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26766] = { --"Brave Storming Sky"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26790] = { --"Taunka'le Longrunner"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26810] = { --"Roanauk Icemist", "High Chieftain of the Taunka"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26847] = { --"Omu Spiritbreeze", "Wind Rider Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26853] = { --"Makki Wintergale", "Wind Rider Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26935] = {
            [npcKeys.waypoints] = {},
        },
        [26936] = { --"Chaska Frosthoof", "General Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26939] = { --"Koro the Wanderer", "Trade Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26944] = { --"Soulok Stormfury", "Stable Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26950] = { --"Sanut Swiftspear", "Reagents and Poisons"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26986] = { --"Tiponi Stormwhisper", "Grand Master Skinning Trainer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [26996] = { --"Awan Iceborn", "Grand Master Leatherworker"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [27126] = { --"Camp Oneqwah Brave"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [27199] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{71.41,23.78}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27216] = {
            [npcKeys.spawns] = {[zoneIDs.DUROTAR]={{45.25,17.33}}},
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [27221] = { --"Tormak the Scarred", "Camp Oneqwah Chieftain"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [27315] = {
            [npcKeys.spawns] = {
                [zoneIDs.DRAGONBLIGHT] = {{77.2,49.8},{78.2,50.6},{78.8,50.8},{79.8,49.6},{80,49.4},{80,51},{81.8,50.6},{82.2,50.4},{83,49.2},{83,50.2},{83.4,51},{84.2,50.4},{84.6,51.6},{84.8,50.4},}
            },
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [27328] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{52.62,24.06}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27627] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{62.18,42.41}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27715] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27716] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27717] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27718] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27727] = {
            [npcKeys.spawns] = {[zoneIDs.GRIZZLY_HILLS]={{23.32,64.84}}},
            [npcKeys.zoneID] = zoneIDs.GRIZZLY_HILLS,
        },
        [27959] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{61.1,2}},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
        [28013] = {
            [npcKeys.spawns] = {[zoneIDs.DRAGONBLIGHT]={{71.81,82.70}}},
            [npcKeys.zoneID] = zoneIDs.DRAGONBLIGHT,
        },
        [28026] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{35.21,64.79},{37.15,64.77},{36.51,64.55},{37.99,65.5},},},
        },
        [28070] = {
            [npcKeys.spawns] = {[zoneIDs.HALLS_OF_STONE]={{-1,-1},{67.43,49.53}},},
            [npcKeys.zoneID] = zoneIDs.HALLS_OF_STONE,
        },
        [28083] = {
            [npcKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{49.8,85},{51.6,86.2},{58,83.8},{58.8,85.6},},},
        },
        [28136] = {
            [npcKeys.spawns] = {},
        },
        [28142] = {
            [npcKeys.spawns] = {},
        },
        [28148] = {
            [npcKeys.spawns] = {},
        },
        [28314] = { --"Longrunner Nanik"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [28358] = {
            [npcKeys.spawns] = {[zoneIDs.SHOLAZAR_BASIN]={{57.4,52.2},{58.4,53.8},},},
        },
        [28912] = {
            [npcKeys.waypoints] = {},
        },
        [29173] = {
            [npcKeys.waypoints] = {},
        },
        [29301] = { --"Camp Winterhoof Wayfarer"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29456] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{19.74,47.93},},},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{20.03,47.56},{20.26,47.70},{20.32,47.93},{20.26,48.16},{20.03,48.30},{19.80,48.16},{19.74,47.93},{19.80,47.70},{20.03,47.56}}}},
        },
        [29595] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{63.24,62.52},{61.48,61.4},{63.0,60.41},{63.84,58.29},{62.76,60.93},{65.35,62.54},{59.82,60.46},{61.29,59.34},{57.85,61.98},{59.23,59.01},{58.58,60.81},},},
        },
        [29597] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{60.55,60.22},{57.78,62.32},{60.8,58.67},{60.74,61.13},{59.01,61.85},{59.66,60.87},{58.57,62.99},{59.88,59.07},{58.15,63.85},{58.58,59.45},{56.69,64.95},{56.85,63.18},},},
        },
        [29762] = { --"Hyeyoung Parka", "Wind Rider Master"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29795] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{68.5,52.9},{69.8,49.4},{69.8,43.8},{69.6,37.8},{68.8,28.2},{67,26.4},{64.8,28.4},{61.6,31},{60.3,34.4},{62.6,41.4},{66.6,51},{68.5,52.9}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [29799] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [29821] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{32.50,63.37},},},
        },
        [29840] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{42.56,20.81},},},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{42.56,20.81},{42.80,20.02},{43.36,19.23},{44.32,18.80},{45.28,19.23},{45.84,20.02},{46.08,20.81},{46.15,21.54},{46.08,22.27},{45.84,23.06},{45.28,23.85},{44.32,24.28},{43.36,23.85},{42.80,23.06}}}},
        },
        [29872] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{28.38,44.85},},},
            [npcKeys.waypoints] = {[zoneIDs.ZUL_DRAK]={{{28.38,46.85},{29.79,46.26},{30.38,44.85},{29.79,43.44},{28.38,42.85},{26.97,43.44},{26.38,44.85},{26.97,46.26},{28.38,46.85}}}},
        },
        [29875] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{43.4,74.2},{44.4,73.8},{45.2,74},{45.4,74.8},{45.8,73},{45.8,75.4},{46.4,74},{46.4,76.2},{46.4,78.4},{46.4,78.8},{46.6,74},{46.6,78.8},{46.8,74.6},{46.8,77.4},{46.8,77.6},{47,72.4},{47,72.6},{47.4,76.2},{47.6,78.8},{48.2,74},{48.2,76.6},{48.4,75},{48.4,75.6},{48.6,77.2},{48.8,79.4},{48.8,79.8},{49,76.4},}},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [29895] = {
            [npcKeys.spawns] = {[zoneIDs.ZUL_DRAK]={{16.43,66.79}}},
            [npcKeys.waypoints] = {[zoneIDs.ZUL_DRAK]={{{16.69,66.78},{18.68,66.8},{20.72,66.61},{21.98,66.82},{23.67,66.65},{25.18,66.75},{26.62,66.96},{28.6,66.48},{31.82,66.66},{30.45,66.6},{28.49,66.53},{25.93,66.93},{24.48,66.73},{22.76,66.75},{21.01,66.6},{18.55,66.86},{16.7,66.75},{16.31,66.75},{13.9,67.32},{13.45,67.33},{12.76,66.96},{13.45,66.28},{13.87,66.26},{16.07,66.7}}}},
        },
        [29968] = { --"Hapanu Coldwind", "Poisons & Reagents"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29969] = { --"Ontak", "Blacksmithing Supplies"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29970] = { --"Danho Farcloud", "General Goods"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29971] = { --"Wabada Whiteflower", "Innkeeper"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29973] = { --"Tunka'lo Brave"
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.factionID] = 1064,
        },
        [29999] = {
            [npcKeys.spawns] = {},
        },
        [30222] = {
            [npcKeys.spawns] = {},
        },
        [30082] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{38.2,61.6},},},
        },
        [30210] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{64.21,59.21},},},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30295] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{56.3,51.4},},},
            [npcKeys.zoneID] = zoneIDs.STORM_PEAKS,
        },
        [30300] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30302] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30315] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{45,49}}},
        },
        [30316] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{64,47}}},
        },
        [30317] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{52,56}}},
        },
        [30318] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{53,42}}},
        },
        [30344] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30345] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.4,55.6}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{64.4,55.6},{61.2,46.8},{58.8,41},{57.6,37.4},{55.8,37.8},{56.6,43.4},{58.6,47.2},{61.2,53.6},{62.8,57.4},{64.4,55.6}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30382] = {
            [npcKeys.spawns] = {[zoneIDs.STORM_PEAKS] = {{39.4,56.4},},},
        },
        [30696] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{29.4,61.4},{29.6,61.6},{30.4,60.8},{30.8,61.8},{31.2,60.2},{31.2,61.2},{31.2,63.2},{31.2,65},{31.2,66.8},{31.4,58.4},{31.4,58.6},{31.4,63.6},{31.4,66.4},{31.4,67.6},{31.4,69.4},{31.4,70},{31.6,58.4},{31.6,58.8},{31.6,60.4},{31.6,60.6},{31.6,66.4},{31.6,67.2},{31.6,68},{31.8,68.8},{32,64.4},{32,64.6},{32,70},{32,70.6},{32.6,69.2},{32.8,70.2},{33.2,70.6},{33.4,65.8},{33.4,67.6},{33.8,69.6},{34,68.4},{34.2,69},{34.8,69.2},{34.8,70.4},{35,70.6},{35.2,71.8},{35.4,66.2},{35.4,66.6},{35.6,72},{35.8,70.2},{36.2,66},{36.2,67.6},{36.2,71},{36.4,65.4},{36.4,66.8},{36.6,65.4},{36.6,65.8},{36.6,67},{36.8,67.8},{37,71.2},{37.2,71.6},{37.4,70.4},{37.6,70.4},{37.6,70.8}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30698] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{29.8,61.6}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30750] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{26.16,62.28}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30824] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{68.5,52.9},{69.8,49.4},{69.8,43.8},{69.6,37.8},{68.8,28.2},{67,26.4},{64.8,28.4},{61.6,31},{60.3,34.4},{62.6,41.4},{66.6,51},{68.5,52.9}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30825] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{68.5,52.9},{69.8,49.4},{69.8,43.8},{69.6,37.8},{68.8,28.2},{67,26.4},{64.8,28.4},{61.6,31},{60.3,34.4},{62.6,41.4},{66.6,51},{68.5,52.9}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [30944] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54.15,71.18}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31134] = {
            [npcKeys.spawns] = {[zoneIDs.VIOLET_HOLD] = {{-1,-1},},},
            [npcKeys.zoneID] = zoneIDs.VIOLET_HOLD,
        },
        [31205] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN] = {{65.6,67},{66,62.6},{66,65.4},{66.4,59.6},{66.4,60.6},{66.4,62},{66.4,64},{66.4,66.2},{66.6,59.6},{66.6,65.6},{66.8,65},{67,69},{67.2,61.4},{67.2,63},{67.2,66.6},{67.4,59.4},{67.4,62.2},{67.4,64},{67.4,68.2},{67.4,70},{67.6,69.4},{67.6,70},{67.8,60.4},{67.8,63.4},{67.8,65.8},{68,62.4},{68,63.8},{68,67.4},{68.2,59.2},{68.2,61.4},{68.2,68},{68.4,65.4},{68.6,59.8},{68.8,58.4},{68.8,59.2},{68.8,62.2},{68.8,64.4},{69,65.4},{69,66},{69,66.6},{69,67.8},{69.2,63.2},{69.4,61.2},{69.6,59.8},{69.6,61.8},{69.6,66},{69.8,59.4},{69.8,61.4},{70,63},{70,64.4},{70,65},{70.4,67.4},{70.6,60.4},{70.6,60.6},{70.6,65},{70.6,68.6},{70.8,63.4},{70.8,67.2},{70.8,68.4},{71,62.2},{71.6,68},}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31261] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{68.5,52.9},{69.8,49.4},{69.8,43.8},{69.6,37.8},{68.8,28.2},{67,26.4},{64.8,28.4},{61.6,31},{60.3,34.4},{62.6,41.4},{66.6,51},{68.5,52.9}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31306] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{29.8,61.2}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31440] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54.5,84.2}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31648] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,43}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31839] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,36.6}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31191] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31222] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31242] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31271] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [31277] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{30.9,29.3}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32195] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,44}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32196] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,40}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32197] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,34}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32199] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{51,33}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32301] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{64.78,28.41}}},
            [npcKeys.waypoints] = {[zoneIDs.ICECROWN]={{{68.5,52.9},{69.8,49.4},{69.8,43.8},{69.6,37.8},{68.8,28.2},{67,26.4},{64.8,28.4},{61.6,31},{60.3,34.4},{62.6,41.4},{66.6,51},{68.5,52.9}}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32370] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{68.05,51.83}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32408] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{68.02,51.59}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [32430] = {
            [npcKeys.spawns] = {[zoneIDs.ICECROWN]={{54,36.9}}},
            [npcKeys.zoneID] = zoneIDs.ICECROWN,
        },
        [38042] = {
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{52.8,76.8}},},
        },
        [38043] = {
            [npcKeys.spawns] = {[zoneIDs.SILVERMOON_CITY] = {{64.6,66.2}},},
        },
        [38044] = {
            [npcKeys.spawns] = {[zoneIDs.THUNDER_BLUFF] = {{44,52.8}},},
        },
        [38045] = {
            [npcKeys.spawns] = {[zoneIDs.UNDERCITY] = {{66.6,38.6}},},
        },
        [38294] = {
            [npcKeys.spawns] = {[zoneIDs.DALARAN] = {{52.5,66.5}},},
            [npcKeys.zoneID] = zoneIDs.DALARAN,
        },
    }
end

function QuestieWotlkNpcFixes:LoadAutomatics()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags

  --! This file is automatically generated from wowhead data by looking at mobs with no spawns, but drops questiems or are objectives of quests.
  return {
    --! 3.0.1
    --* Halfdan the Ice-Hearted https://www.wowhead.com/wotlk/npc=23671
    [23671] = {
      [npcKeys.spawns] = {
        [495]={{44.9,34.9},},
      },
    },
    --* Scarlet Ivy https://www.wowhead.com/wotlk/npc=23763
    [23763] = {
      [npcKeys.spawns] = {
        [495]={{51.6,25.3},{52.5,26.4},{50.9,27.1},{52.4,27.8},{52.7,29.1},},
      },
    },
    --* Fallen Combatant https://www.wowhead.com/wotlk/npc=24008
    [24008] = {
      [npcKeys.spawns] = {
        [495]={{74.9,32.0},{75.5,34.1},},
      },
    },
    --* Plaguehound Tracker https://www.wowhead.com/wotlk/npc=24156
    [24156] = {
      [npcKeys.spawns] = {
        [495]={{77.6,22.0},{78.5,26.9},},
      },
    },
    --* Plagued Proto-Whelp https://www.wowhead.com/wotlk/npc=24160
    [24160] = {
      [npcKeys.spawns] = {
        [495]={{37.9,52.5},{40.0,50.3},{42.4,53.1},},
      },
    },
    --* Frostgore https://www.wowhead.com/wotlk/npc=24173
    [24173] = {
      [npcKeys.spawns] = {
        [495]={{52.4,3.9},{53.6,6.6},},
      },
    },
    --* Prowling Worg https://www.wowhead.com/wotlk/npc=24206
    [24206] = {
      [npcKeys.spawns] = {
        [495]={{51.4,20.2},{59.6,22.3},},
      },
    },
    --* Northern Barbfish https://www.wowhead.com/wotlk/npc=24285
    [24285] = {
      [npcKeys.spawns] = {
        [495]={{62.8,18.5},{64.6,20.2},},
      },
    },
    --* Image of Megalith https://www.wowhead.com/wotlk/npc=24381
    [24381] = {
      [npcKeys.spawns] = {
        [495]={{71.7,17.6},},
      },
    },
    --* Gjalerbron Gargoyle https://www.wowhead.com/wotlk/npc=24440
    [24440] = {
      [npcKeys.spawns] = {
        [495]={{31.4,22.8},{31.0,26.0},{31.6,26.8},{30.8,27.2},{31.4,27.8},},
      },
    },
    --* Frostfin https://www.wowhead.com/wotlk/npc=24500
    [24500] = {
      [npcKeys.spawns] = {
        [495]={{63.7,19.4},},
      },
    },
    --* Black Conrad's Ghost https://www.wowhead.com/wotlk/npc=24790
    [24790] = {
      [npcKeys.spawns] = {
        [495]={{32.5,60.1},},
      },
    },
    --* Mutinous Sea Dog https://www.wowhead.com/wotlk/npc=25026
    [25026] = {
      [npcKeys.spawns] = {
        [495]={{37.8,75.5},{39.1,73.3},{40.5,75.5},},
      },
    },
    --* Warsong Peon https://www.wowhead.com/wotlk/npc=25270
    [25270] = {
      [npcKeys.spawns] = {
        [3537]={{40.8,58.5},{44.0,58.6},},
      },
    },
    --* Arcane Prisoner https://www.wowhead.com/wotlk/npc=25318
    [25318] = {
      [npcKeys.spawns] = {
        [3537]={{42.5,36.8},},
      },
    },
    --* Alluvius https://www.wowhead.com/wotlk/npc=25742
    [25742] = {
      [npcKeys.spawns] = {
        [3537]={{70.2,36.2},{75.5,35.5},},
      },
    },
    --* Nedar, Lord of Rhinos https://www.wowhead.com/wotlk/npc=25801
    [25801] = {
      [npcKeys.spawns] = {
        [3537]={{48.5,40.1},{46.1,40.6},{47.4,41.1},{47.1,42.5},{45.6,44.9},},
      },
    },
    --* Twonky https://www.wowhead.com/wotlk/npc=25830
    [25830] = {
      [npcKeys.spawns] = {
        [3537]={{60.2,20.4},},
      },
    },
    --* ED-210 https://www.wowhead.com/wotlk/npc=25831
    [25831] = {
      [npcKeys.spawns] = {
        [3537]={{65.5,17.6},},
      },
    },
    --* Max Blasto https://www.wowhead.com/wotlk/npc=25832
    [25832] = {
      [npcKeys.spawns] = {
        [3537]={{63.6,22.4},},
      },
    },
    --* The Grinder https://www.wowhead.com/wotlk/npc=25833
    [25833] = {
      [npcKeys.spawns] = {
        [3537]={{65.0,28.8},},
      },
    },
    --* Nesingwary Trapper https://www.wowhead.com/wotlk/npc=25835
    [25835] = {
      [npcKeys.spawns] = {
        [3537]={{57.5,46.3},},
      },
    },
    --* Storm Tempest https://www.wowhead.com/wotlk/npc=26045
    [26045] = {
      [npcKeys.spawns] = {
        [3537]={{77.0,38.6},},
      },
    },
    --* Keristrasza https://www.wowhead.com/wotlk/npc=26206
    [26206] = {
      [npcKeys.spawns] = {
        [3537]={{21.6,22.5},{30.8,33.2},{33.4,34.0},},
      },
    },
    --* Saragosa https://www.wowhead.com/wotlk/npc=26232
    [26232] = {
      [npcKeys.spawns] = {
        [3537]={{21.9,22.5},},
      },
    },
    --* Keristrasza https://www.wowhead.com/wotlk/npc=26237
    [26237] = {
      [npcKeys.spawns] = {
        [3537]={{25.6,22.0},},
      },
    },
    --* Tu'u'gwar https://www.wowhead.com/wotlk/npc=26510
    [26510] = {
      [npcKeys.spawns] = {
        [65]={{46.6,78.0},},
      },
    },
    --* Iron Rune Avenger https://www.wowhead.com/wotlk/npc=26786
    [26786] = {
      [npcKeys.spawns] = {
        [394]={{69.9,5.1},{70.6,7.8},{69.3,9.5},{67.5,10.4},},
      },
    },
    --* Kor'kron War Rider https://www.wowhead.com/wotlk/npc=26813
    [26813] = {
      [npcKeys.spawns] = {
        [65]={{23.6,41.4},{25.8,42.2},{26.0,40.2},},
      },
    },
    --* Overseer Durval https://www.wowhead.com/wotlk/npc=26920
    [26920] = {
      [npcKeys.spawns] = {
        [394]={{67.6,29.3},},
      },
    },
    --* Overseer Korgan https://www.wowhead.com/wotlk/npc=26921
    [26921] = {
      [npcKeys.spawns] = {
        [394]={{72.0,34.2},},
      },
    },
    --* Overseer Lochli https://www.wowhead.com/wotlk/npc=26922
    [26922] = {
      [npcKeys.spawns] = {
        [394]={{74.9,37.5},},
      },
    },
    --* Overseer Brunon https://www.wowhead.com/wotlk/npc=26923
    [26923] = {
      [npcKeys.spawns] = {
        [394]={{78.6,43.8},},
      },
    },
    --* Grom'thar the Thunderbringer https://www.wowhead.com/wotlk/npc=27002
    [27002] = {
      [npcKeys.spawns] = {
        [65]={{57.1,75.6},},
      },
    },
    --* Xink's Shredder https://www.wowhead.com/wotlk/npc=27061
    [27061] = {
      [npcKeys.spawns] = {
        [65]={{52.6,19.3},},
      },
    },
    --* Onslaught Knight https://www.wowhead.com/wotlk/npc=27206
    [27206] = {
      [npcKeys.spawns] = {
        [65]={{74.5,65.5},{72.6,67.3},{72.5,69.7},{73.1,71.3},{71.5,71.5},{69.4,74.2},{72.6,74.4},{67.4,75.4},{72.8,76.4},{69.2,79.5},{71.3,81.5},},
      },
    },
    --* Foreman Kaleiki https://www.wowhead.com/wotlk/npc=27238
    [27238] = {
      [npcKeys.spawns] = {
        [65]={{68.4,74.1},},
      },
    },
    --* Wintergarde Gryphon https://www.wowhead.com/wotlk/npc=27258
    [27258] = {
      [npcKeys.spawns] = {
        [65]={{77.2,50.0},{78.2,48.8},{78.4,48.0},{80.8,48.8},{83.2,51.0},},
      },
    },
    --* Frigid Ghoul Attacker https://www.wowhead.com/wotlk/npc=27685
    [27685] = {
      [npcKeys.spawns] = {
        [65]={{42.8,51.4},{49.8,51.4},{52.1,49.6},},
      },
    },
    --* Frigid Geist Attacker https://www.wowhead.com/wotlk/npc=27686
    [27686] = {
      [npcKeys.spawns] = {
        [65]={{43.0,51.2},{49.5,51.2},{51.2,52.8},{52.6,46.3},},
      },
    },
    --* Injured 7th Legion Soldier https://www.wowhead.com/wotlk/npc=27788
    [27788] = {
      [npcKeys.spawns] = {
        [65]={{86.2,51.0},},
      },
    },
    --* Hourglass of Eternity https://www.wowhead.com/wotlk/npc=27840
    [27840] = {
      [npcKeys.spawns] = {
        [65]={{71.4,39.3},},
      },
    },
    --* Your Inner Turmoil https://www.wowhead.com/wotlk/npc=27959
    [27959] = {
      [npcKeys.spawns] = {
        [495]={{61.0,2.0},},
      },
    },
    --* Wyrmrest Vanquisher https://www.wowhead.com/wotlk/npc=27996
    [27996] = {
      [npcKeys.spawns] = {
        [65]={{59.6,54.5},},
      },
    },
    --* Warlord Tartek https://www.wowhead.com/wotlk/npc=28105
    [28105] = {
      [npcKeys.spawns] = {
        [3711]={{41.5,19.7},},
      },
    },
    --* Watery Lord https://www.wowhead.com/wotlk/npc=28118
    [28118] = {
      [npcKeys.spawns] = {
        [66]={{41.6,74.3},{39.5,76.2},{42.5,82.6},},
      },
    },
    --* Crusader Jonathan https://www.wowhead.com/wotlk/npc=28136
    [28136] = {
      [npcKeys.spawns] = {
        [66]={{50.6,69.8},{54.0,73.8},},
      },
    },
    --* Crusader Lamoof https://www.wowhead.com/wotlk/npc=28142
    [28142] = {
      [npcKeys.spawns] = {
        [66]={{51.4,75.0},{53.6,75.0},{58.0,72.2},},
      },
    },
    --* Crusader Josephine https://www.wowhead.com/wotlk/npc=28148
    [28148] = {
      [npcKeys.spawns] = {
        [66]={{49.4,74.8},{57.8,72.6},},
      },
    },
    --* Bushwhacker https://www.wowhead.com/wotlk/npc=28317
    [28317] = {
      [npcKeys.spawns] = {
        [3711]={{46.5,63.5},},
      },
    },
    --* Drakkari Captive https://www.wowhead.com/wotlk/npc=28414
    [28414] = {
      [npcKeys.spawns] = {
        [66]={{53.9,67.7},{55.5,70.4},},
      },
    },
    --* Captive Footman https://www.wowhead.com/wotlk/npc=28415
    [28415] = {
      [npcKeys.spawns] = {
        [66]={{55.8,71.0},},
      },
    },
    --* Scarlet Ghost https://www.wowhead.com/wotlk/npc=28846
    [28846] = {
      [npcKeys.spawns] = {
        [4298]={{60.9,26.8},{61.6,28.8},{60.0,29.7},{58.8,30.6},{60.2,31.5},{58.6,33.9},},
      },
    },
    --* Drakkari Chieftain https://www.wowhead.com/wotlk/npc=28873
    [28873] = {
      [npcKeys.spawns] = {
        [66]={{33.7,38.3},},
      },
    },
    --* High Inquisitor Valroth https://www.wowhead.com/wotlk/npc=29001
    [29001] = {
      [npcKeys.spawns] = {
        [4298]={{63.0,68.0},},
      },
    },
    --* Prophet of Akali https://www.wowhead.com/wotlk/npc=29028
    [29028] = {
      [npcKeys.spawns] = {
        [66]={{77.5,36.3},},
      },
    },
    --* Scarlet Courier https://www.wowhead.com/wotlk/npc=29076
    [29076] = {
      [npcKeys.spawns] = {
        [4298]={{63.4,72.5},{61.1,75.7},{64.3,76.7},{59.5,78.5},{62.2,79.3},},
      },
    },
    --* Drakuru Raptor Rider https://www.wowhead.com/wotlk/npc=29699
    [29699] = {
      [npcKeys.spawns] = {
        [66]={{22.9,82.7},{26.4,82.8},{29.9,82.8},},
      },
    },
    --* Prince Navarius https://www.wowhead.com/wotlk/npc=29821
    [29821] = {
      [npcKeys.spawns] = {
        [66]={{30.2,63.0},{32.6,64.0},},
      },
    },
    --* Algar the Chosen https://www.wowhead.com/wotlk/npc=29872
    [29872] = {
      [npcKeys.spawns] = {
        [66]={{27.8,47.3},{32.2,51.4},},
      },
    },
    --! 3.0.2
    --* Tormar Frostgut https://www.wowhead.com/wotlk/npc=29626
    [29626] = {
      [npcKeys.spawns] = {
        [67]={{50.4,78.4},},
      },
    },
    --* General Lightsbane https://www.wowhead.com/wotlk/npc=29851
    [29851] = {
      [npcKeys.spawns] = {
        [210]={{44.6,20.0},},
      },
    },
    --* Stormforged Eradicator https://www.wowhead.com/wotlk/npc=29861
    [29861] = {
      [npcKeys.spawns] = {
        [67]={{26.9,66.7},{24.8,69.4},},
      },
    },
    --* Stormforged Monitor https://www.wowhead.com/wotlk/npc=29862
    [29862] = {
      [npcKeys.spawns] = {
        [67]={{26.9,66.7},{24.8,69.2},},
      },
    },
    --* Reanimated Crusader https://www.wowhead.com/wotlk/npc=30202
    [30202] = {
      [npcKeys.spawns] = {
        [210]={{76.5,66.4},{76.5,68.6},{78.2,67.6},{78.5,69.5},{79.2,65.5},{82.8,71.5},},
      },
    },
    --* Stormforged Ambusher https://www.wowhead.com/wotlk/npc=30208
    [30208] = {
      [npcKeys.spawns] = {
        [67]={{70.3,59.1},},
      },
    },
    --* Freed Crusader https://www.wowhead.com/wotlk/npc=30274
    [30274] = {
      [npcKeys.spawns] = {
        [210]={{83.1,71.8},{83.6,74.0},},
      },
    },
    --* Overseer Narvir https://www.wowhead.com/wotlk/npc=30299
    [30299] = {
      [npcKeys.spawns] = {
        [67]={{36.0,60.8},},
      },
    },
    --* Dr. Terrible https://www.wowhead.com/wotlk/npc=30404
    [30404] = {
      [npcKeys.spawns] = {
        [210]={{33.4,33.2},},
      },
    },
    --* Veranus https://www.wowhead.com/wotlk/npc=30461
    [30461] = {
      [npcKeys.spawns] = {
        [67]={{38.7,65.5},},
      },
    },
    --* Forgotten Depths Underking https://www.wowhead.com/wotlk/npc=30541
    [30541] = {
      [npcKeys.spawns] = {
        [210]={{78.6,64.3},{77.5,64.7},{80.9,65.3},{79.2,67.5},{79.5,68.6},},
      },
    },
    --* Forgotten Depths High Priest https://www.wowhead.com/wotlk/npc=30543
    [30543] = {
      [npcKeys.spawns] = {
        [210]={{78.7,57.3},{79.5,60.7},{77.6,62.2},{77.6,65.4},},
      },
    },
    --* Salranax the Flesh Render https://www.wowhead.com/wotlk/npc=30829
    [30829] = {
      [npcKeys.spawns] = {
        [210]={{77.5,62.1},},
      },
    },
    --* Underking Talonox https://www.wowhead.com/wotlk/npc=30830
    [30830] = {
      [npcKeys.spawns] = {
        [210]={{76.4,53.8},},
      },
    },
    --* High Priest Yath'amon https://www.wowhead.com/wotlk/npc=30831
    [30831] = {
      [npcKeys.spawns] = {
        [210]={{79.8,61.0},},
      },
    },
    --* Possessed Iskalder https://www.wowhead.com/wotlk/npc=30924
    [30924] = {
      [npcKeys.spawns] = {
        [210]={{28.8,52.2},},
      },
    },
    --* Overthane Balargarde https://www.wowhead.com/wotlk/npc=31016
    [31016] = {
      [npcKeys.spawns] = {
        [210]={{17.2,56.0},},
      },
    },
    --* Hulking Horror https://www.wowhead.com/wotlk/npc=31413
    [31413] = {
      [npcKeys.spawns] = {
        [210]={{55.3,87.3},},
      },
    },
    --* Armored Decoy https://www.wowhead.com/wotlk/npc=31578
    [31578] = {
      [npcKeys.spawns] = {
        [210]={{70.6,63.0},{69.2,64.6},},
      },
    },
    --* Brann Bronzebeard https://www.wowhead.com/wotlk/npc=31810
    [31810] = {
      [npcKeys.spawns] = {
        [67]={{45.4,49.4},},
      },
    },
    --* Grimkor the Wicked https://www.wowhead.com/wotlk/npc=32162
    [32162] = {
      [npcKeys.spawns] = {
        [210]={{45.4,46.0},},
      },
    },
    --* Alumeth the Ascended https://www.wowhead.com/wotlk/npc=32300
    [32300] = {
      [npcKeys.spawns] = {
        [210]={{51.8,28.6},},
      },
    },
    --* Hourglass of Eternity https://www.wowhead.com/wotlk/npc=32327
    [32327] = {
      [npcKeys.spawns] = {
        [65]={{72.2,38.2},},
      },
    },
    --* Orabus the Helmsman https://www.wowhead.com/wotlk/npc=32576
    [32576] = {
      [npcKeys.spawns] = {
        [3537]={{26.3,54.5},},
      },
    },
  }
  end