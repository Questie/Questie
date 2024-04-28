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
        [215062] = { -- Supplicant
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{39.50,29.37}},
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
        [221210] = { -- Kroll Mountainshade
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{66.11, 69.28}},
            },
        },
        [221215] = { -- Alara Grovemender
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{49.15, 77.55}},
            },
        },
        [221216] = { -- Elenora Marshwalker
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{32.39, 69.48}},
            },
        },
        [221268] = { -- Doran Dreambough
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{87.23, 43.56}},
            },
        },
        [221269] = { -- Maseara Autumnmoon
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{81.2, 50.5}},
            },
        },
        [221270] = { -- Alyssian Windcaller
            [npcKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{92, 54.0}},
            },
        },
        [221335] = { -- Elianar Shadowdrinker
            [npcKeys.spawns] = {
                [zoneIDs.THE_HINTERLANDS] = {{53.47, 39.05}},
            },
        },
        [221336] = { -- Serlina Starbright
            [npcKeys.spawns] = {
                [zoneIDs.THE_HINTERLANDS] = {{71.11, 47.98}},
            },
        },
        [221337] = { -- Veanna Cloudsleeper
            [npcKeys.spawns] = {
                [zoneIDs.THE_HINTERLANDS] = {{57.29, 42.80}},
            },
        },
        [221395] = { -- Mellias Earthtender
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{49.65, 15.35}},
            },
        },
        [221398] = { -- Nerene Brooksinger
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{46.00, 16.50}},
            },
        },
        [221399] = { -- Jamniss Treemender
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{40.62, 8.08}},
            },
        },
        [221484] = { -- Scout Thandros
            [npcKeys.spawns] = {
                [zoneIDs.FERALAS] = {{51.06,10.54}},
            },
        },
        [222188] = { -- Shadowy Figure
            [npcKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{52.12,40.89}},
            },
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
