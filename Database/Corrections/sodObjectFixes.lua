---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function SeasonOfDiscovery:LoadObjects()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [3642] = { -- Kolkars' Booty
            [objectKeys.questStarts] = {90007,90131,90216},
        },
        [142487] = { -- The Sparklematic 5200
            [objectKeys.questStarts] = {2947,2949,2951,2952,2953,79987,80140,80155,80157,80158},
            [objectKeys.questEnds] = {2945,2951,2952,2953,79986,80155,80157,80158},
        },
        [148512] = { -- Essence Font
            [objectKeys.questEnds] = {3373,82102},
        },
        [148836] = { -- Altar of Hakkar
            [objectKeys.questEnds] = {3446,82096},
        },
        [152608] = { -- Kolkar's Booty
            [objectKeys.questStarts] = {90007,90131,90216},
        },
        [152618] = { -- Kolkar's Booty
            [objectKeys.questStarts] = {90007,90131,90216},
        },
        [175084] = { -- The Sparklematic 5200
            [objectKeys.questStarts] = {4601,4603,4605,80153,80160,80161},
            [objectKeys.questEnds] = {4601,4603,4605,80153,80160,80161},
        },
        [176213] = {
            [objectKeys.spawns] = {
                [zoneIDs.WESTERN_PLAGUELANDS]={{35.9,57.4},{35.9,57.5},{36.4,53.7},{36.5,53.6},{38.2,56.3},{39.7,69.4},{39.7,69.6},{40.6,73.1},{40.7,57.4},{40.8,57.5},{41.4,62.1},{41.5,62.1},{41.9,70.5},{42.2,54.9},{42.8,64.2},{43.3,68.3},{43.6,70.4},{43.7,70.5},{44.2,65},{44.4,71.6},{44.5,53.3},{44.5,71.7},{44.6,53.5},{45.8,71.5},{45.9,51.1},{45.9,71.4},{46.7,34.4},{46.8,34.5},{47,59.9},{47,67.1},{47.6,70},{47.9,53.1},{49.4,68.1},{49.8,33.3},{52.2,66.5},{52.3,55},{52.3,66.3},{53,64.2},{53.2,66.5},{53.3,65.1},{53.3,66.2},{53.4,63.4},{53.5,63.3},{53.5,63.5},{54.9,27.1},{55.2,69.4},{55.3,69.6},{56.7,34.7},{57.8,66.4},{57.8,66.5},{62,58.3},{62,58.5},{62.9,57.2},{62.9,57.9},{63.2,59.2},{63.6,75.4},{63.6,75.5},{64,48.7},{64.1,57.9},{64.9,74.4},{64.9,74.5},{65.8,76.8},{66.4,42.1},{66.5,42.2},{67,53.9},{67.8,84.6},{68,44.7},{68.3,81.4},{68.3,81.6},{68.4,77.1},{68.5,77.1},{68.7,49.2},{68.7,79.2},{68.9,73.8},{69.5,78.6},},
                [zoneIDs.EASTERN_PLAGUELANDS]={{7.1,50.7},{8,54.5},{14.2,64.7},{20,61},{20.5,66.9},{21.5,73.9},{22.1,85.1},{24.3,88.2},{26,74.7},{26.3,70.5},{26.7,69.5},{27.1,75.6},{27.3,64},{28.8,86},{29.2,78.8},{30.9,65.5},{32,71},{33.6,32.6},{34,80.2},{34.3,67.8},{34.4,76.9},{34.5,25.8},{35.6,73.3},{35.9,75.8},{36.7,38},{36.9,70.6},{37.1,65.7},{37.6,68.5},{38.4,31.1},{38.5,54},{38.8,26.7},{38.9,36.1},{40,49.9},{41.4,79.7},{41.5,65.7},{42.4,75.8},{44.9,32.9},{46.2,70.8},{46.3,64},{46.5,74.8},{47.5,40.8},{47.9,80},{48.9,67.2},{49.1,35.5},{50.3,45.5},{50.4,77.4},{51.8,70.3},{53.5,50.7},{55.5,58.7},{56.2,63.9},{56.5,76.1},{57.1,81.9},{57.4,71.9},{57.8,76.1},{58.1,79.7},{58.4,64.8},{58.6,79.6},{59.2,62.2},{59.3,80.9},{59.5,76},{59.9,67.5},{61.8,70.2},{63.6,67.7},{64.7,65.4},{64.7,81},{66.2,53},{67.6,66.8},{68.2,70.6},{68.3,74.6},{68.6,78.4},{68.8,80.8},{68.9,83.3},{69,71.5},{70.6,80.8},{70.7,69.5},{71.1,75.3},{72.2,78.4},{73.3,77.2},{73.4,69.8},{73.4,82.1},{73.6,76.8},{73.8,51.1},{74.1,83.8},{74.7,58.7},{75.6,55.3},{75.9,83.5},{76.1,78.2},{76.2,50.4},{76.7,72.4},{78.4,57.5},{78.7,67.3},{78.8,63.5},{80.4,59.8},{89.400,85.314},{90.899,86.875},{95.640,78.639},{92.677,95.731}},
                [zoneIDs.TIRISFAL_GLADES]={{82.8,72.7},{83,71.4},{83,71.5}},
            },
        },
        [179498] = { -- Scarlet Footlocker
            [objectKeys.questStarts] = {90345},
        },
        [179551] = { -- Hydraxis' Coffer
            [objectKeys.questEnds] = {7486,84545},
        },
        [180715] = { -- Holly Preserver
            [objectKeys.questEnds] = {8763,8799,79501,79502},
        },
        [386675] = { -- Buried Treasure
            [objectKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [objectKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{46.96,43.73}},
            },
            [objectKeys.questStarts] = {90133},
        },
        [386691] = { -- Library Book
            [objectKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{76, 10.4}},
            },
            [objectKeys.questStarts] = {79091},
        },
        [386759] = { -- Library Book
            [objectKeys.questStarts] = {79092},
        },
        [386777] = { -- Dusty Chest Stormwind
            [objectKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{61.9, 29.3}},
            },
            [objectKeys.questStarts] = {90194},
        },
        [387466] = { -- Rusty Lockbox
            [objectKeys.questStarts] = {90138},
        },
        [402215] = { -- Charred Note
            [objectKeys.zoneID] = zoneIDs.STORMWIND_CITY,
            [objectKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{33,24.7}},
            },
            [objectKeys.questStarts] = {90117},
        },
        [403105] = { -- Windfury Cone
            [objectKeys.zoneID] = zoneIDs.MULGORE,
            [objectKeys.spawns] = {
                [zoneIDs.MULGORE] = {{31.2,22.8},{31,26.4},{32.4,27.6},{35,13.6},{38.2,9},{39.6,7},{51,7.2},{55.2,12},{55.8,16}},
            },
        },
        [403718] = { -- Prairie Flower
            [objectKeys.zoneID] = zoneIDs.MULGORE,
            [objectKeys.spawns] = {
                [zoneIDs.MULGORE] = {{37.81, 65.45},{38.17, 57.14},{39.85, 51.63},{41.39, 63.2},{45.01, 46.77},{50.97, 46.03},{51.77, 67.3},{53.29, 63.13},{54.31, 58.05},{58.41, 66.64},{58.85, 51.32}},
            },
        },
        [404352] = { -- Artifact Storage Mulgore
            [objectKeys.zoneID] = zoneIDs.MULGORE,
            [objectKeys.spawns] = {
                [zoneIDs.MULGORE] = {{31.6, 49.4}},
            },
            [objectKeys.questStarts] = {90220},
        },
        [404433] = { -- Lunar Chest
            [objectKeys.questStarts] = {90057},
        },
        [404830] = { -- Dusty Chest
            [objectKeys.questStarts] = {90195},
        },
        [404941] = { -- Relic Coffer
            [objectKeys.questStarts] = {90138},
        },
        [405201] = { -- Shipwreck Cache Tirisfal Glades
            [objectKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{66.7, 24.6}},
            },
            [objectKeys.questStarts] = {90196},
        },
        [405879] = { -- Apothecary Society Primer
            [objectKeys.questStarts] = {79095},
        },
        [405946] = { -- Dusty Chest
            [objectKeys.zoneID] = zoneIDs.IRONFORGE,
            [objectKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{52.0, 13.6}},
            },
            [objectKeys.questStarts] = {90193},
        },
        [406736] = { -- Lost Stash
            [objectKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{24.7, 59.4}},
            },
        },
        [407117] = { -- Abandoned Snapjaw Nest
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{44,22}},
            },
            [objectKeys.questStarts] = {90129},
        },
        [407120] = { -- Empty Snapjaw Nest
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{48,40}},
            },
            [objectKeys.questStarts] = {90129},
        },
        [407247] = { -- Glade Flower
            [objectKeys.zoneID] = zoneIDs.TELDRASSIL,
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{57.06, 65.57},{58.05, 73.19},{59.63, 60.05},{61.09, 54.02},{63.88, 64.90},{64.89, 54.77},{65.64, 59.22},{66.56, 51.55},{67.36, 64.15},{69.56, 55.75}},
            },
        },
        [407289] = { -- Horde Warbanner
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{52.2,31.1}},
            },
            [objectKeys.questStarts] = {90115},
        },
        [407291] = { -- Alliance Warbanner
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{62.55,56.31}},
            },
            [objectKeys.questStarts] = {90115},
        },
        [407312] = { -- Hungry Idol
            [objectKeys.questStarts] = {90068},
        },
        [407347] = { -- Altar of Thorns
            [objectKeys.questStarts] = {90038},
        },
        [407352] = { -- Gnarlpine Stash
            [objectKeys.questStarts] = {90197},
        },
        [407453] = { -- Southsea Loot Stash
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{61.81,45.84}},
            },
        },
        [407454] = { -- Gunpowder Keg
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{61.78,45.8}},
            },
            [objectKeys.questStarts] = {90087},
        },
        [407457] = { -- Stable Hand's Trunk
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{61.3, 54.1}},
            },
            [objectKeys.questStarts] = {90212},
        },
        [407505] = { -- Etched Carving
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{45,79}},
            },
            [objectKeys.questStarts] = {90021},
        },
        [407731] = { -- Stonemason's Toolbox
            [objectKeys.zoneID] = zoneIDs.LOCH_MODAN,
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{46.5, 12.7}},
            },
            [objectKeys.questStarts] = {90210},
        },
        [407734] = { -- Gnarlpine Cache
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{44.1, 61.2}},
            },
            [objectKeys.questStarts] = {90093,90095,90138,90157},
        },
        [407844] = { -- Libram of Blessings
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{35.8, 49.5}},
            },
            [objectKeys.questStarts] = {90118},
            [objectKeys.questEnds] = {90118},
        },
        [407850] = { -- Sunken Reliquary
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{36.8, 91.4}},
            },
            [objectKeys.questStarts] = {90126},
            [objectKeys.questEnds] = {90126},
        },
        [407918] = { -- Empty Trophy Display
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{83.6, 65.5}},
            },
            [objectKeys.questStarts] = {90174},
        },
        [407983] = { -- Pile of Stolen Books
            [objectKeys.questStarts] = {90006},
        },
        [408004] = { -- Tangled Blight Pile
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{71.7, 21.4}},
            },
            [objectKeys.questStarts] = {90132},
        },
        [408014] = { -- Gnomish Tome
            [objectKeys.questStarts] = {79093},
        },
        [408718] = { -- Equipment Stash
            [objectKeys.zoneID] = zoneIDs.WESTFALL,
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{40.8,80.24}},
            },
            [objectKeys.questStarts] = {90086},
        },
        [408799] = { -- Idol of the Deep
            [objectKeys.zoneID] = zoneIDs.WESTFALL,
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{26,69.5}},
            },
            [objectKeys.questStarts] = {90140},
        },
        [408802] = { -- Gnarled Harpoon
            [objectKeys.questStarts] = {90141,90150},
        },
        [409131] = { -- Rusty Chest
            [objectKeys.questStarts] = {90213},
        },
        [409289] = { -- Strange Orb
            [objectKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{56.2, 26.4},},
            },
            [objectKeys.questStarts] = {90022},
        },
        [409311] = {
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{89.4, 77.1}},
            },
        },
        [409562] = { -- Spellbook
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{45.4, 70.4}},
            },
        },
        [409692] = { -- Scrolls
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{49.3,32.88}},
            },
        },
        [409731] = { -- Scrolls
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{77.4, 14}},
            },
        },
        [409735] = { -- Spellbook
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{16.7, 28.4}},
            },
        },
        [409942] = { -- Twin Owl Statue
            [objectKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{36.9, 76.1}},
            },
            [objectKeys.questStarts] = {90090},
        },
        [409949] = { -- Twin Owl Statue
            [objectKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{54.0, 83.0}},
            },
            [objectKeys.questStarts] = {90090},
        },
        [410020] = { -- Owl Statue
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{87.0, 43.2}},
            },
            [objectKeys.questStarts] = {90088},
        },
        [410089] = { -- Owl Statue
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{49.5, 33.8}},
            },
            [objectKeys.questStarts] = {90089},
        },
        [410299] = { -- Arcane Secrets
            [objectKeys.questStarts] = {79096},
        },
        [410369] = { -- Dead Drop
            [objectKeys.questStarts] = {78261,78307,78676,78699,80455},
        },
        [410847] = { -- Rusty Safe Western Plaguelands
            [objectKeys.zoneID] = zoneIDs.WESTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.WESTERN_PLAGUELANDS] = {{59.5, 84.5}},
            },
            [objectKeys.questStarts] = {90198},
        },
        [411328] = { -- Slumbering Bones
            [objectKeys.zoneID] = zoneIDs.DUSKWOOD,
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{17,37.6}},
            },
            [objectKeys.questStarts] = {90014,90091},
        },
        [411348] = { -- Dusty Coffer
            [objectKeys.questStarts] = {90014,90091},
        },
        [411674] = { -- Prophecy of a King's Demise
            [objectKeys.spawns] = {
                [130] = {{65.8, 23.4}},
            },
            [objectKeys.questStarts] = {90190},
        },
        [412147] = { -- Supply Locker
            [objectKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [objectKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{81.18,32.12}},
            },
        },
        [414532] = { -- Clliffspring Chest
            [objectKeys.questStarts] = {90084},
        },
        [414624] = { -- Lighthouse Stash
            [objectKeys.questStarts] = {90214},
        },
        [414646] = { -- Remnant
            [objectKeys.questStarts] = {90191},
        },
        [414658] = { -- Rubble
            [objectKeys.zoneID] = zoneIDs.HILLSBRAD_FOOTHILLS,
            [objectKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{79.7, 40.9}},
            },
            [objectKeys.questStarts] = {90033},
        },
        [414663] = { -- Shatterspear Idol
            [objectKeys.questStarts] = {90164},
        },
        [415107] = {
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{37.4, 50.7}},
            },
        },
        [417072] = { -- Nailed Plank
            [objectKeys.questStarts] = {},
        },
        [419741] = { -- Sacrificial Altar
            [objectKeys.zoneID] = zoneIDs.DESOLACE,
            [objectKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{81.4,79.8}},
            },
            [objectKeys.questStarts] = {90256},
        },
        [420055] = { -- Rowboat
            [objectKeys.zoneID] = zoneIDs.ARATHI_HIGHLANDS,
            [objectKeys.spawns] = {
                [zoneIDs.ARATHI_HIGHLANDS] = {{53.7,91.9}},
                [zoneIDs.WETLANDS] = {{58.31,6.94}},
            },
        },
        [421568] = { -- Weathered Cache
            [objectKeys.questStarts] = {90231},
        },
        [422483] = { -- The Salvagematic 9000
            [objectKeys.questStarts] = {79626,79704},
        },
        [422895] = { -- Tear of Theradras
            [objectKeys.zoneID] = zoneIDs.DESOLACE,
            [objectKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{39,57}},
            },
            [objectKeys.questStarts] = {90240},
        },
        [422896] = { -- Tear of Theradras
            [objectKeys.questStarts] = {90240},
        },
        [423695] = { -- Libram of Deliverance
            [objectKeys.questStarts] = {90229},
        },
        [423703] = { -- Broken Warhammer
            [objectKeys.questStarts] = {79939},
        },
        [423841] = { -- Frozen Remains
            [objectKeys.questStarts] = {90249},
        },
        [423898] = { -- Mysterious Book
            [objectKeys.zoneID] = zoneIDs.DESOLACE,
            [objectKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{55,26.2}},
            },
        },
        [423930] = { -- Sizable Stolen Strongbox
            [objectKeys.questStarts] = {90228},
        },
        [424003] = { -- Cage
            [objectKeys.zoneID] = zoneIDs.DEADWIND_PASS,
            [objectKeys.spawns] = {
                [zoneIDs.DEADWIND_PASS] = {{65.43,78.64}},
            },
        },
        [424010] = { -- Nailed Plank
            [objectKeys.questStarts] = {},
        },
        [424074] = { -- Quadrangulation Beacon 001
            [objectKeys.zoneID] = zoneIDs.DUSTWALLOW_MARSH,
            [objectKeys.spawns] = {
                [zoneIDs.DUSTWALLOW_MARSH] = {{58.6, 13.0}},
            },
        },
        [424075] = { -- Quadrangulation Beacon 002
            [objectKeys.zoneID] = zoneIDs.DESOLACE,
            [objectKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{32.0, 72.7}},
            },
        },
        [424076] = { -- Quadrangulation Beacon 003
            [objectKeys.zoneID] = zoneIDs.TANARIS,
            [objectKeys.spawns] = {
                [zoneIDs.TANARIS] = {{37.8, 27.3}},
            },
        },
        [424077] = { -- Quadrangulation Beacon 004
            [objectKeys.zoneID] = zoneIDs.FERALAS,
            [objectKeys.spawns] = {
                [zoneIDs.FERALAS] = {{29.3, 93.8}},
            },
        },
        [424082] = {
            [objectKeys.spawns] = {},
        },
        [424264] = { -- Grave
            [objectKeys.spawns] = {
                [zoneIDs.DUSTWALLOW_MARSH] = {{63.7, 42.4}},
            },
            [objectKeys.questStarts] = {90260},
        },
        [424265] = { -- Grave
            [objectKeys.zoneID] = zoneIDs.SWAMP_OF_SORROWS,
            [objectKeys.spawns] = {
                [zoneIDs.SWAMP_OF_SORROWS] = {{16.8,53.8}},
            },
            [objectKeys.questStarts] = {90261},
        },
        [424266] = { -- Grave
            [objectKeys.zoneID] = zoneIDs.SCARLET_MONASTERY,
            [objectKeys.spawns] = {
                [zoneIDs.SCARLET_MONASTERY] = {{-1,-1}},
            },
            [objectKeys.questStarts] = {90258},
        },
        [424267] = { -- Grave
            [objectKeys.zoneID] = zoneIDs.ARATHI_HIGHLANDS,
            [objectKeys.spawns] = {
                [zoneIDs.ARATHI_HIGHLANDS] = {{62,54}},
            },
            [objectKeys.questStarts] = {90259},
        },
        [425896] = { -- Archivists of the Monastery
            [objectKeys.questStarts] = {90262},
        },
        [428228] = { -- Conspicuous Cache
            [objectKeys.questStarts] = {90263},
        },
        [441247] = { -- Book
            [objectKeys.zoneID] = zoneIDs.SWAMP_OF_SORROWS,
            [objectKeys.spawns] = {
                [zoneIDs.SWAMP_OF_SORROWS] = {{70,51}},
            },
        },
        [441251] = { -- Book
            [objectKeys.zoneID] = zoneIDs.BURNING_STEPPES,
            [objectKeys.spawns] = {
                [zoneIDs.BURNING_STEPPES] = {{28.96,28.93}},
            },
        },
        [441848] = { -- Small Burrow
            [objectKeys.zoneID] = zoneIDs.STRANGLETHORN_VALE,
            [objectKeys.spawns] = {
                [zoneIDs.STRANGLETHORN_VALE] = {{40.75,85.72}},
            },
        },
        [441865] = { -- Traveller's Knapsack
            [objectKeys.questStarts] = {90299},
        },
        [441870] = { -- Satyrweed Bramble
            [objectKeys.questStarts] = {90299},
        },
        [441912] = { -- Giant Golem Foot
            [objectKeys.questStarts] = {90289},
        },
        [441913] = { -- Giant Golem Foot
            [objectKeys.questStarts] = {90289},
        },
        [441914] = { -- Giant Golem Arm
            [objectKeys.questStarts] = {90289},
        },
        [441915] = { -- Giant Golem Arm
            [objectKeys.questStarts] = {90289},
        },
        [442397] = { -- Treasure of the Bat
            [objectKeys.questStarts] = {90296},
        },
        [442404] = { -- Stormcrow Egg
            [objectKeys.questStarts] = {90291},
        },
        [442405] = { -- Abandoned Cache
            [objectKeys.zoneID] = zoneIDs.BLASTED_LANDS,
            [objectKeys.spawns] = {
                [zoneIDs.BLASTED_LANDS] = {{45.3,16.4}},
            },
            [objectKeys.questStarts] = {90295},
        },
        [442685] = { -- Old Chest
            [objectKeys.zoneID] = zoneIDs.FERALAS,
            [objectKeys.spawns] = {
                [zoneIDs.FERALAS] = {{79.2,49.4}},
            },
            [objectKeys.questStarts] = {90297},
        },
        [442688] = { -- Old Crate
            [objectKeys.questStarts] = {90297},
        },
        [443727] = { -- Grimtotem Chest
            [objectKeys.questStarts] = {90305},
        },
        [443728] = { -- Woodpaw Bag
            [objectKeys.questStarts] = {90305},
        },
        [445036] = { -- Extraplanar Eye
            [objectKeys.questStarts] = {90304},
        },
        [445037] = { -- Extraplanar Eye
            [objectKeys.questStarts] = {90304},
        },
        [445039] = { -- Extraplanar Eye
            [objectKeys.questStarts] = {90304},
        },
        [445040] = { -- Extraplanar Eye
            [objectKeys.questStarts] = {90304},
        },
        [445041] = { -- Extraplanar Eye
            [objectKeys.questStarts] = {90304},
        },
        [445042] = { -- Extraplanar Eye
            [objectKeys.questStarts] = {90304},
        },
        [445044] = { -- Extraplanar Eye
            [objectKeys.questStarts] = {90304},
        },

        -- fake ID - no clue yet what the correct ones are
        [450000] = {
            [objectKeys.name] = "Arcane Shard",
            [objectKeys.zoneID] = zoneIDs.ASHENVALE,
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{13.1,24.8},{13,15},{14,19}},
            },
            [objectKeys.questStarts] = {90000},
        },
        [450001] = {
            [objectKeys.name] = "The Lessons of Ta'zo",
            [objectKeys.zoneID] = zoneIDs.ORGRIMMAR,
            [objectKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{38.7,78.4}},
            },
            [objectKeys.questStarts] = {79094},
        },
        [450002] = {
            [objectKeys.name] = "Medusa Statue",
            [objectKeys.zoneID] = zoneIDs.WESTFALL,
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{26,70}},
            },
            [objectKeys.questStarts] = {90066},
        },
        [450003] = {
            [objectKeys.name] = "Thistlefur Dreamcatcher",
            [objectKeys.zoneID] = zoneIDs.ASHENVALE,
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{38,26}},
            },
            [objectKeys.questStarts] = {90161},
        },
        [450004] = {
            [objectKeys.name] = "Wishing Well",
            [objectKeys.zoneID] = zoneIDs.LOCH_MODAN,
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{36.4,19.6}},
            },
            [objectKeys.questStarts] = {90162},
        },
        [450005] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [objectKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{80.3, 79.1}},
            },
            [objectKeys.questStarts] = {90134},
        },
        [450006] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = zoneIDs.DUROTAR,
            [objectKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{62.1, 94.8}},
            },
            [objectKeys.questStarts] = {90136},
        },
        [450007] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [objectKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{52.9, 54}},
            },
            [objectKeys.questStarts] = {90137},
        },
        [450008] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = zoneIDs.TELDRASSIL,
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{55.3, 90.8}},
            },
            [objectKeys.questStarts] = {90135},
        },
        [450009] = {
            [objectKeys.name] = "Secluded Grave",
            [objectKeys.zoneID] = zoneIDs.DUSKWOOD,
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{90.9,30.5}},
            },
            [objectKeys.questStarts] = {90192},
        },
        [450010] = {
            [objectKeys.name] = "Raven Hill Statue",
            [objectKeys.zoneID] = zoneIDs.DUSKWOOD,
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{19.9,45.5}},
            },
            [objectKeys.questStarts] = {90201},
        },
        [450011] = {
            [objectKeys.name] = "Galvanic Icon",
            [objectKeys.zoneID] = zoneIDs.DUROTAR,
            [objectKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{38.01, 35.53},{53.36, 50.48},{51.78, 56.39},{36.95, 45.53},{56.53, 28.37},{39.43, 50.06}},
            },
            [objectKeys.questStarts] = {90217},
        },
        [450012] = {
            [objectKeys.name] = "Galvanic Icon",
            [objectKeys.zoneID] = zoneIDs.MULGORE,
            [objectKeys.spawns] = {
                [zoneIDs.MULGORE] = {{54.07, 55.82},{36.3, 9.8},{37.5, 52.5},{41.65, 55.98},{37.99, 60.04}},
            },
            [objectKeys.questStarts] = {90218},
        },
        [450013] = {
            [objectKeys.name] = "Beastly Effigy",
            [objectKeys.zoneID] = zoneIDs.THOUSAND_NEEDLES,
            [objectKeys.spawns] = {
                [zoneIDs.THOUSAND_NEEDLES] = {{69.0, 55.0}},
            },
            [objectKeys.questStarts] = {90221},
        },
        [450014] = {
            [objectKeys.name] = "Witherbark Gong",
            [objectKeys.zoneID] = zoneIDs.ARATHI_HIGHLANDS,
            [objectKeys.spawns] = {
                [zoneIDs.ARATHI_HIGHLANDS] = {{69.33, 81.50}},
            },
            [objectKeys.questStarts] = {90230},
        },
        [450015] = {
            [objectKeys.name] = "Satyrweed Bulb Location",
            [objectKeys.zoneID] = zoneIDs.DESOLACE,
            [objectKeys.spawns] = {
                [zoneIDs.DESOLACE] = {{70.0, 70.0}},
            },
            [objectKeys.questStarts] = {90222},
        },
        [450016] = {
            [objectKeys.name] = "Strahnbrad Bellows",
            [objectKeys.zoneID] = zoneIDs.ALTERAC_MOUNTAINS,
            [objectKeys.spawns] = {
                [zoneIDs.ALTERAC_MOUNTAINS] = {{60.0, 46.4}},
            },
            [objectKeys.questStarts] = {90234},
        },
        [450017] = {
            [objectKeys.name] = "Crate",
            [objectKeys.zoneID] = zoneIDs.MOONGLADE,
            [objectKeys.spawns] = {
                [zoneIDs.MOONGLADE] = {{55.6,66.5}},
            },
            [objectKeys.questStarts] = {90245},
        },
        [450018] = {
            [objectKeys.name] = "Soft Soil",
            [objectKeys.zoneID] = zoneIDs.ARATHI_HIGHLANDS,
            [objectKeys.spawns] = {
                [zoneIDs.ARATHI_HIGHLANDS] = {{34,44}},
            },
            [objectKeys.questStarts] = {90246},
        },
        [450019] = {
            [objectKeys.name] = "Cryptic Scroll of Summoning",
            [objectKeys.zoneID] = zoneIDs.TANARIS,
            [objectKeys.spawns] = {
                [zoneIDs.TANARIS] = {{58.0,36.0}},
            },
            [objectKeys.questStarts] = {90287,90288},
        },
        [450020] = {
            [objectKeys.name] = "Iodax Spawn",
            [objectKeys.zoneID] = zoneIDs.SEARING_GORGE,
            [objectKeys.spawns] = {
                [zoneIDs.SEARING_GORGE] = {{65.0,45.0}},
            },
            [objectKeys.questStarts] = {90289},
        },
        [456874] = { -- Sending Pillar
            [objectKeys.questStarts] = {90345},
        },
        [456876] = { -- Sending Pillar
            [objectKeys.questStarts] = {90345},
        },
        [456877] = { -- Sending Pillar
            [objectKeys.questStarts] = {90345},
        },
        [456879] = { -- Sending Pillar
            [objectKeys.questStarts] = {90345},
        },
        [456883] = { -- Adon's Trunk
            [objectKeys.questStarts] = {90345},
        },
        [456918] = { -- Console
            [objectKeys.zoneID] = zoneIDs.WESTFALL,
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{54.5,40.2}},
                [zoneIDs.TIRISFAL_GLADES] = {{53.56,57.21}},
            },
        },
        [457088] = { -- Advanced Swordplay
            [objectKeys.questStarts] = {90330},
        },
        [457089] = { -- The Shadow Connection
            [objectKeys.questStarts] = {90320},
        },
        [457090] = { -- Famous (and Infamous) Rangers of Azeroth
            [objectKeys.questStarts] = {90319},
        },
        [457091] = { -- Chen's Training Manual
            [objectKeys.questStarts] = {90329},
        },
        [457092] = { -- The Fury of Stormrage
            [objectKeys.questStarts] = {90318},
        },
        [457093] = { -- Blunt Justice: A Dwarf's Tale
            [objectKeys.questStarts] = {90328},
        },
        [457094] = { -- The True Nature of the Light
            [objectKeys.questStarts] = {90317},
        },
        [457095] = { -- Elements for Dummies Volume I: Frost
            [objectKeys.questStarts] = {90316},
        },
        [457096] = { -- Be First: A Brawler's Guide to Boxing
            [objectKeys.questStarts] = {90327},
        },
        [457097] = { -- Elements for Dummies Volume II: Fire
            [objectKeys.questStarts] = {90326},
        },
        [457098] = { -- Finding Your Inner Feline: A Guide to Modern Druidism
            [objectKeys.questStarts] = {90315},
        },
        [457099] = { -- Zirene's Guide to Getting Punched
            [objectKeys.questStarts] = {90314},
        },
        [457100] = { -- Renzik's Thoughts on "Fair" Fighting
            [objectKeys.questStarts] = {90325},
        },
        [457101] = { -- The Rites of Mak'Gora
            [objectKeys.questStarts] = {90310},
        },
        [457102] = { -- Elements for Dummies Volume III: Arcane
            [objectKeys.questStarts] = {90313},
        },
        [461632] = { -- Marked Crate
            [objectKeys.questStarts] = {90347},
        },
        [461633] = { -- Belavus' Safe Box
            [objectKeys.questStarts] = {90348,90349,90350},
        },
        [462201] = { -- Shards of Light
            [objectKeys.zoneID] = zoneIDs.DEADWIND_PASS,
            [objectKeys.spawns] = {
                [zoneIDs.DEADWIND_PASS] = {{40.6,78.4}},
            },
        },
        [462432] = { -- Wooden Chest
            [objectKeys.questStarts] = {90337},
        },
        [463206] = { -- Book
            [objectKeys.zoneID] = zoneIDs.BURNING_STEPPES,
            [objectKeys.spawns] = {
                [zoneIDs.BURNING_STEPPES] = {{26.4,24.45}},
            },
            [objectKeys.questStarts] = {84396},
        },
        [463207] = { -- Book
            [objectKeys.questStarts] = {84398},
        },
        [463208] = { -- Book
            [objectKeys.questStarts] = {84400},
        },
        [463209] = { -- Book
            [objectKeys.questStarts] = {84397},
        },
        [463211] = { -- Book
            [objectKeys.zoneID] = zoneIDs.WESTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.WESTERN_PLAGUELANDS] = {{69.41,72.84}},
            },
            [objectKeys.questStarts] = {84402},
        },
        [463212] = { -- Book
            [objectKeys.questStarts] = {84401},
        },
        [463213] = { -- Book
            [objectKeys.questStarts] = {84395},
        },
        [463214] = { -- Book
            [objectKeys.questStarts] = {84399},
        },
        [463540] = { -- Scarlet Toolbox
            [objectKeys.questStarts] = {90346},
        },
        [478062] = { -- Damaged Silver Hand Breastplate
            [objectKeys.zoneID] = zoneIDs.WESTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.WESTERN_PLAGUELANDS] = {{46.96,69.73}},
            },
        },
        [478075] = { -- Campsite
            [objectKeys.zoneID] = zoneIDs.BURNING_STEPPES,
            [objectKeys.spawns] = {
                [zoneIDs.BURNING_STEPPES] = {{17,46}},
            },
        },
        [499987] = { -- Spellbook
            [objectKeys.questStarts] = {90321},
        },
        [499988] = { -- Spellbook
            [objectKeys.questStarts] = {90322},
        },
        [518117] = { -- Skull
            [objectKeys.name] = "Skull",
            [objectKeys.zoneID] = zoneIDs.BURNING_STEPPES,
            [objectKeys.spawns] = {
                [zoneIDs.BURNING_STEPPES] = {{39.5,27.96}},
            },
        },
        [525416] = {
            [objectKeys.name] = "Heart of Doom",
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{70.96,57.53},{75.2,70.6},{66.56,72.11},{23.31,71.31},{16.3,77.3},{22.04,85.26}},
                [zoneIDs.BURNING_STEPPES]={{79.57,29.29},{67.15,35.92},{71.7,49.2},{36.2,70.6},{23.81,68.61},{23.5,48.7}},
                [zoneIDs.BLASTED_LANDS]={{60.1,43.4},{63,28.3},{56.9,29.2},{47.2,35.6},{51.2,26.5},{45.9,19}},
                [zoneIDs.WINTERSPRING]={{50.9,14.3},{42.3,37.8},{63.1,47.6}},
                [zoneIDs.AZSHARA]={{46.3,56.6},{22.1,60.5},{16.9,68.5},{17.1,52.5}},
                [zoneIDs.TANARIS]={{48.1,29.8},{54.2,29.9},{50.6,34.2},{51.9,50.3},{55.9,52},{53.8,54.4},{35.3,56.8},{33.5,66.6},{29.7,57.5}},
            },
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [526132] = { -- Leftovers (cheese)
            [objectKeys.name] = "Leftovers",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{95.021,79.799},{95.313,79.355},{95.276,79.219},{95.118,78.147},{94.347,83.765},{91.295,85.615},{99.446,84.071},{99.840,84.356},{98.705,83.936},{95.479,78.724}},
            },
        },
        [526143] = { -- Leftovers (soup)
            [objectKeys.name] = "Leftovers",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{95.058,79.006},{94.891,79.298},{95.584,79.687},{95.134,79.671},{95.671,79.304},{95.274,83.115},{95.490,83.161},{94.433,83.558},{94.533,84.173},{94.764,83.687},{94.370,83.485},{94.386,83.626},{94.588,83.570},{94.556,83.688},{93.371,83.340},{99.678,82.568},{99.747,82.554},{99.524,83.447},{98.166,79.937}},
            },
        },
        [526144] = { -- Leftovers (watermelon)
            [objectKeys.name] = "Leftovers",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{95.565,79.510},{95.505,79.230},{95.137,79.025},{95.495,83.137},{94.421,83.621},{93.003,93.781},{98.126,79.988}},
            },
        },
        [526217] = { -- Orchardist's Supply Chest
            [objectKeys.name] = "Orchardist's Supply Chest",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{93.876,89.045}},
            },
        },
        [526220] = { -- Rope
            [objectKeys.name] = "Rope",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{94.354,90.041}},
            },
        },
        [526809] = { -- Flopping Fish
            [objectKeys.name] = "Flopping Fish",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [526937] = {
            [objectKeys.name] = "Armor Crate",
            [objectKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS]={{98.54,84.12}}},
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [527513] = {
            [objectKeys.name] = "Holy Arrow",
            [objectKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS]={{93.33,91.08},{93.82,90.67},{94.97,90.99},{93.78,91.15},{93.48,91.44},{93.29,91.83},{93.46,92.15},{93.67,91,92},{94.12,91.23},{93.28,91.25}}},
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [527821] = {
            [objectKeys.name] = "Elegantly Painted House",
            [objectKeys.spawns] = {[zoneIDs.WESTERN_PLAGUELANDS]={{66.04,75.32}}},
            [objectKeys.zoneID] = zoneIDs.WESTERN_PLAGUELANDS,
        },
        [528481] = {
            [objectKeys.name] = "Crimson Bladeleaf",
            [objectKeys.spawns] = {[zoneIDs.AZSHARA]={{39.93,80.71},{40.55,81.42},{41.53,80.29},{40.45,78.64},{39.91,78.81}}},
            [objectKeys.zoneID] = zoneIDs.AZSHARA,
        },
        [529383] = { -- Unattended Pile of Mail, SoD New Avalon Mailbox
            [objectKeys.name] = "Unattended Pile of Mail",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{90.32,81.98}},
            },
        },
        [529720] = { -- Fallen World Tree Branch
            [objectKeys.name] = "Fallen World Tree Branch",
            [objectKeys.zoneID] = zoneIDs.KALIMDOR,
            [objectKeys.spawns] = {
                [zoneIDs.KALIMDOR] = {{55.9,30.5}},
            },
        },
        [529731] = { -- Pilfered Moonglade Supplies
            [objectKeys.name] = "Pilfered Moonglade Supplies",
            [objectKeys.zoneID] = zoneIDs.WINTERSPRING,
            [objectKeys.spawns] = {
                [zoneIDs.WINTERSPRING] = {{68.01,37.01}},
            },
        },
        [531545] = { -- Dented Chest
            [objectKeys.name] = "Dented Chest",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{33.52,27.30}},
            },
        },
        [531291] = { -- Potion Rack
            [objectKeys.name] = "Potion Rack",
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.EASTERN_PLAGUELANDS] = {{99.331,83.307}},
            },
            [objectKeys.questStarts] = {90560,90567},
        },
        [531301] = {
            [objectKeys.name] = "Bleeding Heart",
            [objectKeys.spawns] = {
                [zoneIDs.WESTERN_PLAGUELANDS] = {{50.956,42.955},{51.960,43.891},{51.796,46.345},{51.714,47.707},{50.419,51.713},{46.257,45.093},{47.427,40.252},{45.506,41.438},{44.629,38.478},{51.197,54.424},{50.116,56.166},{50.192,57.134},{50.840,59.398},{51.864,61.539},{51.575,63.547},{43.141,60.190},{46.158,64.934},{45.255,66.834},{46.193,70.598},{48.563,70.563},{51.479,68.174},{50.921,66.884},{51.575,63.547},{40.034,59.170},{39.943,55.510},{41.672,52.010},{41.656,50.381},{39.501,50.955},{39.262,52.845},{40.408,69.282},{39.105,70.062},{41.128,74.386},{45.458,74.328},{45.532,74.386},{44.756,52.018},{44.215,51.199}},
            },
            [objectKeys.zoneID] = zoneIDs.WESTERN_PLAGUELANDS,
        },

        -- Fake IDs
        [600000] = {
            [objectKeys.name] = "Bone Pile", -- For Soul of Mischief
            [objectKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS]={{69.2,29.4},{69.2,29.6},{69.8,29.4},{69.8,29.6},{70.4,31},{70.6,30},{71.2,29.2},{71.4,31.8}}},
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [600001] = {
            [objectKeys.name] = "Seeking Seasoned Adventurers!", -- For "For Gold and Glory!"
            [objectKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS]={{81.29,58.75}}},
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
            [objectKeys.questStarts] = {86964},
        },
        [600002] = {
            [objectKeys.name] = "Ball and chain", -- For "Scarlet Activities"
            [objectKeys.spawns] = {[zoneIDs.TIRISFAL_GLADES]={{81.76,58.04}}},
            [objectKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
        },
        [600003] = {
            [objectKeys.name] = "Crusader's Loom", -- For "Holy Threads"
            [objectKeys.spawns] = {[zoneIDs.EASTERN_PLAGUELANDS]={{94.65,83.57}}},
            [objectKeys.zoneID] = zoneIDs.EASTERN_PLAGUELANDS,
        },
    }
end
