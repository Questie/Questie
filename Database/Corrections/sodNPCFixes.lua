---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function SeasonOfDiscovery:LoadNPCs()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags
    local waypointPresets = QuestieDB.waypointPresets

    return {
        [15076] = { -- Zandalarian Emissary
            [npcKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{27.2, 77.0},{39.5, 5.0}},
            },
        },
        [202060] = { -- Frozen Murloc
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{76.8, 51.4}},
                [zoneIDs.TIRISFAL_GLADES] = {{66.4, 40.2}},
            },
        },
        [202699] = { -- Baron Aquanis
            [npcKeys.spawns] = {
                [zoneIDs.BLACKFATHOM_DEEPS] = {{-1, -1}},
            },
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [203079] = { -- Wandering Swordsman
            [npcKeys.spawns] = {
                [1] = {{53.5, 47.5}},
                [12] = {{24.6, 75.2},{38.6, 75.2}},
                [14] = {{36, 47.4},{41, 49.4},{55.8, 38.4},{56.6, 26.6}},
                [141] = {{39.6, 37.6},{39.8, 69.4},{43.8, 77},{54.8, 66},{62.6, 71.8}},
                [215] = {{40.4, 53.2},{45.6, 36.4},{60.2, 67.4}},
            },
        },
        [203226] = { -- Viktoria Woods
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{69.6, 50.6}},
            },
        },
        [203475] = { -- Liv Bradford
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{22.4, 64.4}},
            },
        },
        [203478] = { -- Stuart
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{22.6, 54.2}},
            },
        },
        [204068] = { -- Lady Sarevess
            [npcKeys.spawns] = {
                [zoneIDs.BLACKFATHOM_DEEPS] = {{-1, -1}},
            },
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [204070] = { -- Soboz
            [npcKeys.spawns] = {
                [1] = {{42, 36.6}},
                [14] = {{67.4, 89.2}},
                [1497] = {{24.6, 40.6}},
                [1519] = {{25, 77.6}},
            },
        },
        [204827] = { -- Adventurer's Remains
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{43, 49.4}},
                [zoneIDs.ELWYNN_FOREST] = {{52.2, 84.4}},
                [zoneIDs.DUROTAR] = {{48, 79.4}},
                [zoneIDs.TELDRASSIL] = {{33.6, 35.4}},
                [zoneIDs.MULGORE] = {{60.4, 33.4}},
            },
        },
        [204989] = { -- Wounded Adventurer
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{61.8, 47.6}},
            },
        },
        [204503] = { -- Dead Acolyte
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{56.4, 57.8}},
            },
        },
        [205153] = { -- Ada Gelhardt
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{4.4, 28.2}},
            },
        },
        [205278] = { -- Brother Romulus
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{38.4, 27.4}},
            },
        },
        [205382] = { -- Mokwa
            [npcKeys.spawns] = {
                [zoneIDs.MULGORE] = {{35.8, 57.2}},
            },
        },
        [206248] = { -- Wooden Effigy
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{66.8, 58}},
                [zoneIDs.MULGORE] = {{37.4, 49.6}},
            },
        },
        [207515] = { -- Lurkmane
            [npcKeys.spawns] = {
                [zoneIDs.MULGORE] = {{30.6, 61.2}},
            },
        },
        [207577] = { -- Lunar Stone
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{52.8, 79.8}},
                [zoneIDs.MULGORE] = {{35.2, 69.6}},
            },
        },
        [207743] = { -- Netali Proudwind
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{28.6, 18.2}},
            },
        },
        [207754] = { -- Mooart
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{26.6,19.8}},
            },
        },
        [207957] = { -- Vahi Bonesplitter
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{53, 43.4}},
            },
        },
        [208023] = { -- Gru'ark
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{58.8, 53.6}},
            },
        },
        [208124] = { -- Raluk
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{68.6, 71.6}},
            },
        },
        [208196] = { -- Gillgar
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{28.4, 46.8}},
            },
        },
        [208275] = { -- Frozen Makrura
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{58.6, 45.6}},
            },
        },
        [208619] = { -- Dorac Graves
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{47.2, 71.2}},
            },
        },
        [208638] = { -- Fyodi
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{35.4,37.4},{30.4,41.2}},
            },
        },
        [208652] = { -- Junni Steelpass
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{46.4, 53.2}},
            },
        },
        [208711] = { -- Toby
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{63.6, 50.2}},
            },
        },
        [208752] = { -- Frozen Trogg
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{69.2, 58.2}},
            },
        },
        [208802] = { -- Wounded Adventurer
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{25.4, 43.6}},
            },
        },
        [208812] = { -- Jorul
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{37.8, 42.4}},
            },
        },
        [208919] = { -- Blueheart
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{61.6, 51.4}},
            },
        },
        [208927] = { -- Dead Acolyte
            [npcKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{76.4, 44.8}},
            },
        },
        [209004] = { -- Bruart
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{71.2, 73.2}},
            },
        },
        [209524] = { -- Patrolling Cheetah
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{44.4, 55.4}},
            },
        },
        [209607] = { -- Lieutenant Stonebrew
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {},
            },
        },
        [209608] = { -- Delwynna
            [npcKeys.spawns] = {
                [zoneIDs.DARNASSUS] = {{63.4, 22}},
            },
        },
        [209678] = { -- Twilight Lord Kelris
            [npcKeys.spawns] = {
                [zoneIDs.BLACKFATHOM_DEEPS] = {{-1, -1}},
            },
            [npcKeys.zoneID] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [209742] = { -- Desert Mirage
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{57.6, 35.8}},
            },
        },
        [209797] = { -- Bruuz
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{64.8, 39.8}},
            },
        },
        [209872] = { -- Syllart
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{56.6, 57.8}},
            },
        },
        [209908] = { -- Heretic Idol
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{71.8, 27.0}},
            },
        },
        [209928] = { -- Mowgh
            [npcKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{48.0, 31.6}},
            },
        },
        [209948] = { -- Relaeron
            [npcKeys.spawns] = {
                [zoneIDs.DARNASSUS] = {{39.2, 9.0}},
            },
        },
        [209954] = { -- Demonic Remains
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{72.6, 68.8}},
            },
        },
        [209958] = { -- Graix
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{72.6, 68.8}},
            },
        },
        [210107] = { -- Kackle
            [npcKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{55.0, 55.4}},
            },
        },
        [210451] = { -- Lady Sedorax
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{55.4, 36.6}},
            },
        },
        [210482] = { -- Paxnozz
            [npcKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{47.8, 16.0}},
            },
        },
        [210483] = { -- Aggressive Squashling
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{51.2, 22.3},{54, 31.8},{44.6, 35.2},{38.4, 52.5},{62.5, 61.1}},
            },
        },
        [210533] = { -- Silverspur
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{35.6, 38.4}},
            },
        },
        [210537] = { -- Undying Laborer
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{44.9, 24},{31.5, 45}},
            },
        },
        [210549] = { -- Defias Scout
            [npcKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{51.2, 46.8},{51.6, 55.6}},
            },
        },
        [210845] = { -- Jixo Madrocket
            [npcKeys.spawns] = {
                [zoneIDs.STONETALON_MOUNTAINS] = {{59.2, 62.4}},
            },
        },
        [210995] = { -- Alonso
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{43.4, 70.4}},
            },
        },
        [211022] = { -- Owen Thadd
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{73.4, 33}},
            },
            [npcKeys.friendlyToFaction] = "H",
        },
        [211033] = { -- Garion Wendell
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{37.8, 80.2}},
            },
            [npcKeys.friendlyToFaction] = "A",
        },
        [211146] = { -- Lost Adventurer
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {},
            },
        },
        [211736] = { -- Grizzled Protector
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {},
            },
        },
        [211951] = { -- Koartul
            [npcKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{60.8, 31.8}},
            },
        },
        [211965] = { -- Carrodin
            [npcKeys.spawns] = {
                [zoneIDs.WETLANDS] = {{46.6, 65.6}},
            },
        },
        [211200] = { -- Agon
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{65.1, 23.7}},
            },
        },
        [212261] = { -- Awakened Lich
            [npcKeys.spawns] = {},
        },
        [212694] = { -- Hirzek
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{43.2, 78.6}},
            },
        },
        [212699] = { -- Silverwing Archer
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212703] = { -- Silverwing Dryad
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212706] = { -- Silverwing Druid
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.4},{51.2, 55.6},{59, 72.4},{73.6, 74.4}},
            },
        },
        [212707] = { -- Larodar
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{51.6, 54.6}},
            },
        },
        [212727] = { -- Warsong Grunt
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212728] = { -- Warsong Raider
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212729] = { -- Warsong Shaman
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.8, 38.6},{40.2, 65.2},{54, 54.6},{69.4, 62.4}},
            },
        },
        [212730] = { -- Tojara
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{53.6, 54.2}},
            },
        },
        [212801] = { -- Jubei
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{21.6, 36.4}},
            },
        },
        [212802] = { -- Moogul the Sly
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{70.2, 62.8}},
            },
        },
        [212803] = { -- Ceredwyn
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{73.4, 73.4}},
            },
        },
        [212804] = { -- Centrius
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{28.6, 27.8}},
            },
        },
        [212809] = { -- Wailing Spirit
            [npcKeys.spawns] = {
                [zoneIDs.SILVERPINE_FOREST] = {{59.6, 71.4}},
            },
        },
        [212837] = { -- Primordial Anomaly
            [npcKeys.spawns] = {
                [zoneIDs.STONETALON_MOUNTAINS] = {{32.6, 67.6}},
            },
        },
        [212969] = { -- Kazragore
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{39.4, 67.2}},
            },
        },
        [212970] = { -- Felore Moonray
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{59.8, 72.4}},
            },
        },
        [213077] = { -- Elaine Compton
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{54.4, 61.2}},
            },
            [npcKeys.friendlyToFaction] = "A",
        },
        [214070] = { -- Jornah
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{51.4, 63.8}},
            },
            [npcKeys.friendlyToFaction] = "H",
        },
        [214096] = { -- Dokimi
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{39.2, 53.4}},
            },
            [npcKeys.friendlyToFaction] = "H",
        },
        [214098] = { -- Gishah
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{64, 39.2}},
            },
            [npcKeys.friendlyToFaction] = "H",
        },
        [214099] = { -- Tamelyn Aldridge
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{24.4, 67.6}},
            },
            [npcKeys.friendlyToFaction] = "A",
        },
        [214101] = { -- Marcy Baker
            [npcKeys.spawns] = {
                [zoneIDs.DARNASSUS] = {{59.8, 56.4}},
            },
            [npcKeys.friendlyToFaction] = "A",
        },
        [214456] = { -- Dro'zem the Blasphemous
            [npcKeys.spawns] = {
                [zoneIDs.REDRIDGE_MOUNTAINS] = {{35.4, 8.6},{64.2, 45.8},{77.4, 69.4}},
            },
        },
        [214519] = { -- Incinerator Gar'im
            [npcKeys.spawns] = {
                [zoneIDs.REDRIDGE_MOUNTAINS] = {{77.6, 85.8}},
            },
        },
        [215850] = { -- Raszel Ander
            [npcKeys.friendlyToFaction] = "AH",
        },
        [216289] = { -- Orokai
            [npcKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{41.2, 43.6}},
            },
        },
        [216902] = { -- Wulmort Jinglepocket
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{33.7, 67.23}},
            },
            [npcKeys.friendlyToFaction] = "AH",
        },
        [216915] = { -- Strange Snowman
            [npcKeys.spawns] = {
                [zoneIDs.ALTERAC_MOUNTAINS]={{35.43, 72.45}},
            },
        },
        [216924] = { -- Kaymard Copperpinch
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{53.3, 66.47}},
            },
            [npcKeys.friendlyToFaction] = "AH",
        },
        [217392] = {
            [npcKeys.spawns] = {
                [zoneIDs.DESOLACE]={{56.4, 21.8}},
            },
        },
        [217669] = { -- Scorched Screeching Roguefeather
            [npcKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{26.4, 46.4}},
            },
        },
        [217683] = {
            [npcKeys.zoneID] = zoneIDs.THOUSAND_NEEDLES,
            [npcKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{39.4,42}},
            },
        },
        [217703] = { -- Singed Highperch Consort
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{10.4, 40.2}},
            },
        },
        [217706] = { -- Kazragore
            [npcKeys.friendlyToFaction] = "H",
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{74.0, 60.6}},
            },
        },
        [217707] = { -- Felore Moonray
            [npcKeys.friendlyToFaction] = "A",
        },
        [217711] = { -- Seared Needles Cougar
            [npcKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{23.4, 23.4}},
            },
        },
        [217412] = { -- Amaryllis Webb
            [npcKeys.spawns] = {
                [zoneIDs.SWAMP_OF_SORROWS] = {{25.2, 54.6}},
            },
        },
        [217588] = { -- Arbor Tarantula
            [npcKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{45.2, 19.6}},
            },
        },
        [217589] = { -- Hay Weevil
            [npcKeys.spawns] = {
                [zoneIDs.ARATHI_HIGHLANDS] = {{30.8, 28.6},{54.2, 38.6},{61.2, 55.4}},
            },
        },
        [217590] = { -- Flesh Picker
            [npcKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{51.4, 59.8}},
            },
        },
        [218115] = { -- Mai'zin
            [npcKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{31.2, 48.4}},
            },
        },
        [218160]  = { -- Aeonas the Vindicated
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{37.4, 31.8}},
            },
        },
        [218237] = { -- Wirdal Wondergear
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.zoneID] = zoneIDs.FERALAS,
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{84.2,43.8}},
            },
        },
        [218931] = { -- Dark Rider Deadwind Pass
            [npcKeys.zoneID] = zoneIDs.DEADWIND_PASS,
            [npcKeys.spawns] = {
                [zoneIDs.DEADWIND_PASS] = {{43,29}},
            },
        },
        [221259] = {
            [npcKeys.name] = "Wyrmkin Nightstalker",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{80.6, 49},{80.6, 50.6},{81, 48.2},{81.2, 49.6},{81.6, 48.4},{81.6, 49.4},{82.4, 50},{82.8, 49.6},{83, 48.8},{83.4, 48.2},{83.6, 48.2},{83.6, 48.6},{83.8, 45.2},{84.2, 44.4},{84.2, 46.6},{84.4, 45.8},{84.6, 46.2},{84.6, 46.6},{85.2, 44.6},{85.4, 44.4},{86, 46},{86.2, 42.8},{86.2, 44.8},{86.2, 50.2},{86.4, 41.2},{86.4, 42.4},{86.4, 44.4},{86.4, 47.2},{86.4, 47.6},{86.6, 42},{86.6, 43},{86.6, 47.6},{86.8, 44.6},{86.8, 46.2},{86.8, 48.8},{87, 40.4},{87, 46.6},{87, 50.4},{87.4, 41.2},{87.4, 43.8},{87.6, 41.2},{87.6, 43.4},{87.6, 43.6},{87.6, 45.2},{88, 50.2},{88.2, 41.6},{88.6, 41.4},{88.6, 42.4},{88.8, 43.6},{89, 45.4},{89.2, 42.8},{89.8, 40.2},{90.6, 40},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221260] = {
            [npcKeys.name] = "Terror Whelp",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{82.2, 49.8},{82.6, 50},{83, 48.6},{83.4, 48.2},{83.8, 47.6},{84, 47.2},{84.4, 45.4},{84.4, 46},{84.6, 46.6},{84.8, 46.2},{85.4, 44.4},{85.4, 45.2},{85.6, 45},{85.6, 45.8},{85.6, 50.8},{86.2, 44.4},{86.2, 47},{86.4, 41.2},{86.4, 41.6},{86.4, 43},{86.4, 47.8},{86.4, 49.8},{86.6, 41.8},{86.6, 43.4},{86.6, 48},{86.6, 49.2},{86.8, 43.8},{86.8, 46.2},{86.8, 46.6},{86.8, 50.6},{87, 40.6},{87, 44.6},{87, 50.4},{87.2, 40.4},{87.2, 51.6},{87.6, 49.8},{88, 50.8},{88.2, 41.4},{88.2, 41.6},{88.2, 42.6},{88.4, 43.6},{88.6, 41.4},{88.8, 43},{89, 40.4},{89.2, 42},{89.2, 44.2},{89.2, 45.2},{89.2, 45.6},{89.2, 48.2},{89.6, 43},{89.6, 44.2},{89.8, 40.2},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221261] = {
            [npcKeys.name] = "Dreamfire Betrayer",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{77.4, 46.2},{77.8, 49.2},{78.2, 44.4},{78.2, 44.6},{78.2, 50.2},{78.4, 43},{78.4, 45.8},{78.6, 45.8},{79, 45.4},{79, 50.2},{79.4, 46.8},{79.4, 50.6},{79.6, 44.8},{79.8, 47.2},{80, 46.2},{80, 47.8},{80, 49.2},{80.2, 50.4},{80.4, 50.6},{80.4, 51.6},{80.6, 45.4},{80.6, 46.4},{80.6, 48.8},{80.8, 46.6},{80.8, 49.8},{81, 51},{81, 54.6},{81.4, 48.4},{81.4, 51.6},{81.6, 48.4},{81.6, 48.6},{81.6, 51.4},{81.6, 51.8},{82.2, 52.6},{82.4, 50},{82.4, 54},{82.6, 50},{82.6, 52.2},{82.6, 52.6},{82.6, 54.4},{82.6, 54.6},{82.8, 45.6},{83, 49.4},{83.2, 55.6},{83.2, 56.6},{83.4, 58.4},{83.6, 50.2},{83.6, 58.2},{83.6, 58.6},{83.8, 45.6},{83.8, 48.8},{83.8, 56.2},{84, 45.2},{84.2, 51},{85.2, 50.4},{85.2, 50.8},{86.2, 50.4},{86.6, 50.2},{86.8, 52.8},{86.8, 58.8},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221262] = {
            [npcKeys.name] = "Dreamfire Hellcaller",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{77.4, 46.2},{77.8, 46},{78, 44.4},{78.2, 43.2},{78.2, 45},{78.2, 46.6},{78.4, 50.8},{79, 45.4},{79, 46.2},{79, 46.6},{79.4, 50.2},{80, 47.8},{80, 50.6},{80.2, 47.2},{80.2, 48.8},{80.2, 49.8},{80.4, 46.4},{80.6, 46.4},{80.6, 46.8},{80.8, 45.4},{81, 49.2},{81.2, 49.8},{81.2, 50.8},{81.4, 48.4},{81.4, 51.8},{81.6, 48.2},{81.6, 48.6},{81.6, 52},{81.8, 50},{81.8, 53.6},{82.2, 53.2},{82.8, 51},{83, 48.8},{83, 50.4},{83.6, 46.6},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221263] = {
            [npcKeys.name] = "Vengeful Ancient",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{79.4, 55.2},{80.4, 54.8},{80.6, 54.6},{81, 50.6},{81.2, 54.2},{81.4, 62},{81.8, 52.2},{82, 52.6},{82.2, 54.8},{82.2, 62.4},{82.4, 54},{82.4, 61.4},{82.4, 62.6},{82.6, 54.2},{82.6, 61.6},{82.6, 62.8},{82.8, 52.2},{82.8, 52.6},{82.8, 55.2},{82.8, 61},{83, 56.6},{83.2, 50},{83.2, 51},{83.2, 55.8},{83.4, 58},{83.4, 58.8},{83.4, 60},{83.4, 63.6},{83.6, 50.4},{83.6, 51.6},{83.6, 56},{83.6, 56.6},{83.6, 58.4},{83.6, 60.4},{83.6, 65.4},{83.8, 60.6},{83.8, 63},{83.8, 66},{84, 58.6},{84.2, 63.6},{84.4, 50.8},{84.4, 62.2},{84.6, 61.4},{84.6, 62.2},{84.8, 50.6},{84.8, 56.6},{85, 62.8},{85.2, 56.2},{85.4, 50.4},{85.4, 59.4},{85.4, 60.2},{85.4, 64.2},{85.4, 64.6},{85.4, 66.2},{85.4, 66.6},{85.6, 50.4},{85.6, 56.2},{85.6, 59.4},{85.6, 60},{85.6, 63.8},{85.6, 65.4},{85.6, 65.6},{85.8, 50.6},{85.8, 60.8},{86, 55.2},{86, 56.6},{86.2, 53.4},{86.2, 53.8},{86.4, 49.2},{86.4, 57.6},{86.4, 62.4},{86.4, 62.6},{86.6, 56.4},{86.6, 57.4},{86.6, 62.6},{86.8, 52},{86.8, 55},{86.8, 57.8},{86.8, 59.8},{86.8, 62.2},{87, 50.2},{87, 60.6},{87.2, 49.4},{87.2, 50.6},{87.2, 59},{87.4, 53},{87.4, 54},{87.6, 50.4},{87.6, 50.8},{87.6, 53.6},{87.8, 53.2},{88, 61.8},{88, 62.8},{88.2, 49},{88.2, 57.6},{88.2, 61.4},{88.4, 55.4},{88.4, 56.4},{88.4, 56.8},{88.4, 59.4},{88.4, 59.6},{88.6, 56.6},{88.6, 58.8},{88.6, 60.2},{88.6, 61},{88.6, 61.6},{88.8, 49.8},{88.8, 55.2},{88.8, 56.4},{89, 57.8},{89.2, 45.2},{89.2, 47},{89.2, 48.2},{89.2, 49},{89.4, 51.4},{89.4, 52},{89.4, 52.6},{89.4, 53.8},{89.6, 47.4},{89.6, 48.8},{89.6, 52.2},{89.6, 52.6},{89.6, 54},{89.6, 56.4},{89.6, 62.6},{89.8, 50.8},{89.8, 58},{90, 48.4},{90.2, 49.6},{90.6, 49.2},{90.6, 50.2},{90.6, 50.6},{90.6, 57.4},{90.8, 58.2},{91.2, 53.8},{91.4, 51.8},{91.4, 53.2},{91.8, 54},{92, 53.2},{93, 56.4},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221265] = {
            [npcKeys.name] = "Larsera",
            [npcKeys.minLevel] = 99,
            [npcKeys.maxLevel] = 99,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{80.6, 48.8},{81.6, 48.4},{83.6, 45.4},{84.2, 46},{84.2, 46.8},{84.6, 45.8},{85.4, 44.8},{85.8, 45.6},{86.2, 44.8},{86.4, 43},{86.4, 44.4},{86.6, 43.2},{86.6, 44.6},{86.8, 42},{86.8, 44.4},{86.8, 45.8},{86.8, 48.4},{87.8, 43.2},{88.2, 42.2},{88.6, 42.2},{88.8, 42.8},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221266] = {
            [npcKeys.name] = "Zalius",
            [npcKeys.minLevel] = 99,
            [npcKeys.maxLevel] = 99,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{80.4, 50.6},{80.8, 49.4},{80.8, 49.8},{81, 50.6},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221267] = {
            [npcKeys.name] = "Shredder 9000",
            [npcKeys.minLevel] = 99,
            [npcKeys.maxLevel] = 99,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{84.6, 66},{84.8, 59.4},{84.8, 62.4},{85.4, 60.4},{85.4, 63.2},{85.6, 65.2},{85.8, 62.8},{86.2, 59.2},{86.2, 60.2},{86.2, 60.8},{86.2, 63.6},{86.4, 61.8},{86.6, 58},{86.6, 61.2},{86.6, 64},{86.8, 59.8},{86.8, 62.4},{86.8, 62.8},{87, 59.2},{87.8, 62},{88, 63},{88.2, 57.2},{88.4, 58},{88.6, 56.2},{88.8, 57.8},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221268] = {
            [npcKeys.name] = "Doran Dreambough",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{87.23, 43.56}},
            },
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221269] = {
            [npcKeys.name] = "Maseara Autumnmoon",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{81.2, 50.5}},
            },
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221270] = {
            [npcKeys.name] = "Alyssian Windcaller",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{92, 54.0}},
            },
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221271] = {
            [npcKeys.name] = "Dreamwarden Ellodar",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{83.6, 45.4},},
            },
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221272] = {
            [npcKeys.name] = "Dreamwarden Mandoran",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{81.4, 48.4},{81.4, 48.6},{81.6, 48.4},{81.6, 48.6},},
            },
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221273] = {
            [npcKeys.name] = "Dreamwarden Lanaria",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{91.2, 58},},
            },
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221282] = {
            [npcKeys.name] = "Emberspark Dreamsworn",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{89.2, 40.8},{89.4, 40},{89.6, 40.8},{90, 40.2},{91, 39.4},{91.2, 39.6},{92, 35.4},{92, 39.2},{92.2, 36.8},{92.4, 35.8},{92.4, 38.4},{92.4, 40},{92.6, 38.2},{92.6, 38.8},{92.8, 36.2},{93.2, 40.4},{93.4, 37.2},{93.4, 40.6},{93.6, 38.2},{94, 37.2},{94, 39.4},{94.2, 35.2},{94.2, 35.8},{94.4, 40.4},{94.4, 40.6},{94.6, 39},{94.6, 40.6},{94.8, 36.4},{94.8, 37},{94.8, 38},{95, 39.8},{95.6, 39},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221283] = {
            [npcKeys.name] = "Dreampyre Imp",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{89, 41.4},{89.2, 41.6},{89.4, 40},{89.6, 40.6},{89.8, 40.4},{90.2, 39},{91, 38.4},{91, 39},{91, 39.6},{92, 39.6},{92.2, 39.4},{92.4, 36.2},{92.4, 36.8},{92.4, 38.4},{92.6, 36.2},{92.8, 36.6},{92.8, 39},{93, 38.4},{93.4, 39.6},{93.8, 38.6},{93.8, 39.8},{93.8, 40.6},{94, 36.4},{94, 36.8},{94, 38.4},{94.4, 35.4},{94.6, 36.4},{94.6, 39.4},{94.8, 37.4},{94.8, 37.6},{94.8, 40},{95, 40.6},{95.6, 37.4},{95.6, 37.6},{95.6, 39},{97, 38.6},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221292] = {
            [npcKeys.name] = "Dreamhunter Hound",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{89.4, 40.2},{89.4, 40.6},{89.6, 40.6},{90, 40},{90.4, 39.2},{90.8, 39.6},{91, 38},{91.4, 38.8},{92.2, 36.4},{92.2, 37.4},{92.4, 37.6},{92.4, 38.6},{92.4, 39.8},{92.6, 36.4},{92.6, 38.4},{92.8, 39.6},{93.4, 37},{93.4, 39},{93.4, 40.6},{93.6, 39},{93.8, 35.4},{93.8, 40.2},{93.8, 40.6},{94, 37.4},{94, 37.6},{94.2, 36.2},{94.6, 35.2},{94.6, 38.4},{94.6, 40.2},{94.8, 38.6},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
        [221477] = {
            [npcKeys.name] = "Field Captain Hannalah",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{89.4, 40.6},{89.6, 40.6},},
            },
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.questStarts] = {81727,82017},
            [npcKeys.questEnds] = {81727,81768,81769,81770,81771,81772,81773,81774,81775,81776,81777,81778,81779,81780,81781,81782,81783,81784,81785},
        },
        [221482] = {
            [npcKeys.name] = "Scout Gemeron",
            [npcKeys.minLevel] = 40,
            [npcKeys.maxLevel] = 40,
            [npcKeys.zoneID] = 331,
            [npcKeys.spawns] = {
                [331] = {{93.8, 35.2},},
            },
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },

        -- fake NPCs
        [900000] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.DUSKWOOD,
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{23,47}},
            },
        },
        [900001] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.ARATHI_HIGHLANDS,
            [npcKeys.spawns] = {
                [zoneIDs.ARATHI_HIGHLANDS] = {{60,40}},
            },
        },
        [900002] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.SWAMP_OF_SORROWS,
            [npcKeys.spawns] = {
                [zoneIDs.SWAMP_OF_SORROWS] = {{69,28}},
            },
        },
        [900003] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.THE_BARRENS,
            [npcKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{52,36}},
            },
        },
        [900004] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.DESOLACE,
            [npcKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{65,25}},
            },
        },
        [900005] = {
            [npcKeys.name] = "Dark Rider",
            [npcKeys.minLevel] = 41,
            [npcKeys.maxLevel] = 41,
            [npcKeys.zoneID] = zoneIDs.BADLANDS,
            [npcKeys.spawns] = {
                [zoneIDs.BADLANDS] = {{58,54}},
            },
        },
    }
end
