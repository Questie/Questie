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
        [16786] = { -- Argent Quartermaster
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY]={{54.8,62.13},{54.55,62.22}},
                [zoneIDs.IRONFORGE]={{29.59,61.44},{29.37,60.04}},
                [zoneIDs.DARNASSUS]={{39.11,45.43},{39.55,46.88}},
                [zoneIDs.EASTERN_PLAGUELANDS]={{81.04,59.74},{80.74,59.9}},
            },
            [npcKeys.questStarts] = {9321,9337,9341,87434,87436,87438,87440,88746,88883},
            [npcKeys.questEnds] = {9321,9337,9341,87434,87436,87438,87440,88746,88883},
        },
        [16787] = { -- Argent Outfitter
            [npcKeys.questStarts] = {9320,9336,9343,87433,87435,87437,87439,88747,88882},
            [npcKeys.questEnds] = {9320,9336,9343,87433,87435,87437,87439,88747,88882},
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
        [212252] = { -- Harvest Golem V000-A
            [npcKeys.spawns] = {},
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
        [216666] = { -- Techbot
            [npcKeys.zoneID] = zoneIDs.GNOMEREGAN,
            [npcKeys.spawns] = {[zoneIDs.GNOMEREGAN]={{-1,-1}}},
        },
        [216668] = { -- Irradiated Invader
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {[zoneIDs.DUN_MOROGH]={{20.9,36.02},{22.09,34.14},{19.68,36.71},{19.32,38.8},{21.81,32.2}}},
        },
        [216669] = { -- Caverndeep Pillager
            [npcKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [npcKeys.spawns] = {[zoneIDs.DUN_MOROGH]={{21.79,33.69},{20.61,36.96},{18.76,39.16}}},
        },
        [216670] = { -- Caverndeep Looter
            [npcKeys.zoneID] = zoneIDs.GNOMEREGAN,
            [npcKeys.spawns] = {[zoneIDs.GNOMEREGAN]={{-1,-1}}},
        },
        [216671] = { -- Caverndeep Invader
            [npcKeys.zoneID] = zoneIDs.GNOMEREGAN,
            [npcKeys.spawns] = {[zoneIDs.GNOMEREGAN]={{-1,-1}}},
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
        [218920] = {
            [npcKeys.spawns] = {
                [zoneIDs.DEADWIND_PASS] = {{52.1,34.12}},
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
        [223591] = { -- Echo of a Lost Soul
            [npcKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{30.0,73.0}},
                [zoneIDs.THE_HINTERLANDS] = {{72.8,68.6}},
                [zoneIDs.SWAMP_OF_SORROWS] = {{50.2,62.0}},
                [zoneIDs.TANARIS] = {{53.8,29.0}},
            },
        },
        [227464] = { -- Squire Cuthbert
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.8,50.4}},
            },
            [npcKeys.questStarts] = {84008},
        },
        [227672] = { -- Squire Cuthbert
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.8,50.4}},
            },
            [npcKeys.questStarts] = {83823},
        },
        [227673] = { -- Squire Cuthbert
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.8,50.4}},
            },
            [npcKeys.questStarts] = {83823},
        },
        [227674] = { -- Squire Cuthbert
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.8,50.4}},
            },
        },
        [227755] = { -- Estelenn
            [npcKeys.zoneID] = zoneIDs.BURNING_STEPPES,
            [npcKeys.spawns] = {
                -- TODO: Is there a better way? The NPC ID is correct, but the locations are needed for different quests
                [zoneIDs.BURNING_STEPPES] = {{17.03,46.32}},
                [zoneIDs.WINTERSPRING] = {{58,21}},
            },
        },
        [228818] = { -- Shrine of Cooperation
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{47,58}}},
        },
        [229897] = { -- Wild Windtwister
            [npcKeys.zoneID] = zoneIDs.MOONGLADE,
            [npcKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{39,68}},
            },
        },
        [230302] = { -- Lord Kazzak
            [npcKeys.zoneID] = zoneIDs.THE_TAINTED_SCAR,
            [npcKeys.spawns] = {[zoneIDs.THE_TAINTED_SCAR]={{-1,-1}}},
        },
        [230481] = { -- Earth Elemental Fragment
            [npcKeys.zoneID] = zoneIDs.MOONGLADE,
            [npcKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{72.4,62.2}},
            },
        },
        [230319] = { -- Deliana
            [npcKeys.spawns] = {[zoneIDs.IRONFORGE]={{43.53,52.64}}},
        },
        [230775] = { -- Rage Talon Quartermaster
            [npcKeys.zoneID] = zoneIDs.LOWER_BLACKROCK_SPIRE,
            [npcKeys.spawns] = {[zoneIDs.LOWER_BLACKROCK_SPIRE] = {{-1, -1}}},
        },
        [231050] = { -- Syndicate Infiltrator
            [npcKeys.zoneID] = zoneIDs.LOWER_BLACKROCK_SPIRE,
            [npcKeys.spawns] = {[zoneIDs.LOWER_BLACKROCK_SPIRE] = {{-1, -1}}},
        },
        [231430] = { -- Caius Blackwood
            [npcKeys.zoneID] = zoneIDs.FELWOOD,
            [npcKeys.spawns] = {[zoneIDs.FELWOOD] = {{35.4,57.8}}},
        },
        [231485] = { -- Procrastimond (actuall this NPC is in "elsewhere", but to get to him you need to use an item in Tanaris)
            [npcKeys.zoneID] = zoneIDs.TANARIS,
            [npcKeys.spawns] = {[zoneIDs.TANARIS] = {{50,28}}},
        },
        [232398] = { -- Primordial Flame
            [npcKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{15.6,56.6}}},
        },
        [232399] = { -- Outcast Cryomancer
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{63.2,68.9}}},
        },
        [232429] = { -- Magical Stone
            [npcKeys.spawns] = {[zoneIDs.BURNING_STEPPES] = {{14.8,56.7}}},
        },
        [232466] = { -- Magical Stone
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{63.2,68.4}}},
        },
        [232529] = { -- Nandieb
            [npcKeys.zoneID] = zoneIDs.WINTERSPRING,
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{50.7,27.9}}},
        },
        [232532] = { -- Fel Interloper
            [npcKeys.spawns] = {}, -- Spawned when closing a Growing Fel Rift (232538)
        },
        [232755] = { -- Van Amburgh
            [npcKeys.zoneID] = zoneIDs.UN_GORO_CRATER,
            [npcKeys.spawns] = {
                [zoneIDs.UN_GORO_CRATER] = {{23.64,33.23}},
            },
        },
        [232929] = { -- Gregory
            [npcKeys.zoneID] = zoneIDs.WINTERSPRING,
            [npcKeys.spawns] = {[zoneIDs.WINTERSPRING] = {{53.36,83.59}}},
        },
        [233084] = { -- Estelenn
            [npcKeys.zoneID] = zoneIDs.UN_GORO_CRATER,
            [npcKeys.spawns] = {
                [zoneIDs.UN_GORO_CRATER] = {{23.64,33.23}},
            },
        },
        [233158] = { -- Azgaloth
            [npcKeys.zoneID] = zoneIDs.DEMON_FALL_CANYON,
            [npcKeys.spawns] = {[zoneIDs.DEMON_FALL_CANYON] = {{-1,-1}}},
        },
        [233335] = { -- Rune Broker (Alliance)
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{57.4,26.8}},
                [zoneIDs.IRONFORGE] = {{53.8,14.1}},
                [zoneIDs.DARNASSUS] = {{28.6,38.6}},
                [zoneIDs.ELWYNN_FOREST] = {{48.2,41.5}},
                [zoneIDs.DUN_MOROGH] = {{29.5,72.1}},
                [zoneIDs.TELDRASSIL] = {{58.9,43.7}},
            },
        },
        [233428] = { -- Rune Broker (Horde)
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{49.5,46}},
                [zoneIDs.THUNDER_BLUFF] = {{22.8,13.8}},
                [zoneIDs.UNDERCITY] = {{79.4,19.8}},
                [zoneIDs.DUROTAR] = {{42.7,68}},
                [zoneIDs.MULGORE] = {{44.3,76.7}},
                [zoneIDs.TIRISFAL_GLADES] = {{31.3,66.4}},
            },
        },
        [237818] = { -- Harrison Jones
            [npcKeys.spawns] = {[zoneIDs.DEADWIND_PASS] = {{52.3,34.08}}},
        },
        [237819] = { -- Injured Adventurer
            [npcKeys.spawns] = {[zoneIDs.DEADWIND_PASS] = {{65.43,78.64}}},
        },
        [237820] = { -- Deceased Adventurer
            [npcKeys.spawns] = {[zoneIDs.DEADWIND_PASS] = {{39.99,74.16}}},
        },
        [237957] = { -- Archmage Kir-Moldir
            [npcKeys.minLevel] = 60,
            [npcKeys.maxLevel] = 60,
            [npcKeys.zoneID] = zoneIDs.NAXXRAMAS,
            [npcKeys.spawns] = {[zoneIDs.NAXXRAMAS] = {{-1,-1}}},
            [npcKeys.questEnds] = {87283},
        },
        [238376] = { -- Brother Luctus
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{80.56,65.46}},
                [zoneIDs.AZSHARA] = {{32,54}},
                [zoneIDs.BURNING_STEPPES] = {{65.43,55.13}},
                [zoneIDs.SWAMP_OF_SORROWS] = {{32,54}},
                [zoneIDs.WINTERSPRING] = {{58.41,35.97}},
                [zoneIDs.TANARIS] = {{53.9,28.6}},
            },
        },
        [239031] = { -- Scarlet Inquisitor Caldoran
            [npcKeys.name] = "Scarlet Inquisitor Caldoran",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{68.3,82.7}}},
            [npcKeys.questStarts] = {87502,87506},
            [npcKeys.questEnds] = {87502},
        },
        [239032] = { -- Commander Beatrix
            [npcKeys.name] = "Commander Beatrix",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{67.8,83.3}}},
            [npcKeys.questStarts] = {87497,87516},
            [npcKeys.questEnds] = {87493,87498,87506,87509,87516},
        },
        [239047] = { -- Scarlet Siege Commander
            [npcKeys.name] = "Scarlet Siege Commander",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{78.4,79.6},{78.4,83.1},{81.1,80.9},{83.2,87.8},{84.4,81.9},{84.9,85.2}}},
        },
        [239054] = { -- Argent Emissary
            [npcKeys.name] = "Argent Emissary",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{67.79,83.27}}},
            [npcKeys.questStarts] = {87508},
            [npcKeys.questEnds] = nil,
        },
        [239152] = { -- Scout the Mage Tower in New Avalon - Bunny
            [npcKeys.name] = "New Avalon Mage Tower",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{98.3,88.4}}},
        },
        [239153] = { -- Scout the Keep in New Avalon - Bunny
            [npcKeys.name] = "New Avalon Keep",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{97.6,83.2}}},
        },
        [239154] = { -- Scout the Cathedral in Tyr's Hand - Bunny
            [npcKeys.name] = "Tyr's Hand Cathedral",
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{85.3,84.0}}},
        },
        [240248] = { -- Bryon Steelblade
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{98.48, 84.14}}},
            [npcKeys.npcFlags] = npcFlags.REPAIR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Repair",
        },
        [240604] = { -- Carrie Hearthfire
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{95.3,78.38}}},
        },
        [240607] = { -- Devon Woods
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{95.31,80.24}}},
        },
        [240631] = { -- Taylor Stitchings
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{94.69, 83.54}}},
            [npcKeys.npcFlags] = npcFlags.VENDOR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Tailoring Supplies",
        },
        [240632] = { -- Tanya Hyde
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{94.24,93.38}}},
            [npcKeys.npcFlags] = npcFlags.VENDOR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Leatherworking Supplies",
        },
        [240654] = { -- Fizzlefuse
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_KINGDOMS] = {{62.77,24.31}}},
        },
        [240978] = { -- Apple
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [241006] = { -- Grand Crusader Caldoran
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE] = {{-1,-1}}},
        },
        [241019] = { -- Johnny
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{94.911,91.356}}},
            [npcKeys.npcFlags] = npcFlags.VENDOR,
            [npcKeys.minLevel] = 60,
            [npcKeys.maxLevel] = 60,
        },
        [241032] = { -- Fish Barrel
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_KINGDOMS] = {{63.08,26.35}}},
        },
        [241408] = { -- Scarlet Courier
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_KINGDOMS] = {{99.02,89.07}}},
        },
        [241613] = { -- Kyndra Swiftarrow
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{93.81,90.07}}},
        },
        [241664] = { -- Malorie
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{95.29,78.80}}},
            [npcKeys.npcFlags] = npcFlags.VENDOR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Food & Drink",
        },
        [241768] = { -- Herod
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [241769] = { -- Arcanist Doan
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [241770] = { -- Interrogator Vishas
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [241772] = { -- Grand Crusader Caldoran
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [241862] = { -- Scarlet Stash
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{98.75,82.25},{98.51,82.57}}},
            [npcKeys.npcFlags] = npcFlags.BANKER,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Banker",
        },
        [241877] = { -- Mayor Quimby
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{90.87,85.69}}},
        },
        [242019] = { -- Leonid Barthalomew the Revered, scarlet caravan
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{33.54,27.42}}},
            [npcKeys.questStarts] = {89234,89568,89574},
            [npcKeys.questEnds] = {89567,89568,89574},
        },
        [242827] = { -- Captain Bloodcoin
            [npcKeys.zoneID] = zoneIDs.EASTERN_KINGDOMS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_KINGDOMS] = {{62.8376,26.2241}}},
            [npcKeys.npcFlags] = npcFlags.AUCTIONEER,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Seafaring Auctioneer",
        },
        [242954] = { -- Anvil (New Avalon)
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{99.57,77.84}}},
            [npcKeys.npcFlags] = npcFlags.REPAIR,
            [npcKeys.friendlyToFaction] = "AH",
            [npcKeys.subName] = "Repair",
        },
        [243021] = { -- Lillian Voss
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [243023] = { -- Inquisitor Jociphine
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{68.2,82.4}}},
            [npcKeys.questStarts] = {90510},
            [npcKeys.questEnds] = {90510},
        },
        [243269] = { -- Solistrasza
            [npcKeys.zoneID] = zoneIDs.SCARLET_ENCLAVE,
            [npcKeys.spawns] = {[zoneIDs.SCARLET_ENCLAVE]={{-1,-1}}},
        },
        [243386] = { -- Leonid Barthalomew the Revered, terrordale
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS] = {{16.54,31.21}}},
            [npcKeys.questStarts] = {89229,89328,89329},
            [npcKeys.questEnds] = {89310,89328,89329},
        },
        [243393] = { -- Leonid Barthalomew the Revered, service entrance gate, also inside stratholme
            [npcKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [npcKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{47.94,21.90}},
                [zoneIDs.STRATHOLME] = {{-1,-1}}
            },
            [npcKeys.questStarts] = {89235,89310},
            [npcKeys.questEnds] = {89234,89235},
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
