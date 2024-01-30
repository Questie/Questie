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
        [386675] = { -- Buried Treasure
            [objectKeys.zoneID] = zoneIDs.DUN_MOROGH,
            [objectKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{46.96,43.73}},
            },
        },
        [386691] = { -- Library Book
            [objectKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{76, 10.4}},
            },
        },
        [386777] = { -- Dusty Chest Stormwind
            [objectKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{61.9, 29.3}},
            },
        },
        [402215] = { -- Charred Note
            [objectKeys.zoneID] = zoneIDs.STORMWIND_CITY,
            [objectKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{33,24.7}},
            },
        },
        [403041] = { -- Blasting Supplies
            [objectKeys.zoneID] = zoneIDs.MULGORE,
            [objectKeys.spawns] = {
                [zoneIDs.MULGORE] = {{63.8,44.1}},
            },
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
        },
        [405201] = { -- Shipwreck Cache Tirisfal Glades
            [objectKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{66.7, 24.6}},
            },
        },
        [405946] = { -- Dusty Chest
            [objectKeys.zoneID] = zoneIDs.IRONFORGE,
            [objectKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{52.0, 13.6}},
            },
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
        },
        [407120] = { -- Empty Snapjaw Nest
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{48,40}},
            },
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
        },
        [407291] = { -- Alliance Warbanner
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{62.55,56.31}},
            },
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
        },
        [407457] = { -- Stable Hand's Trunk
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{61.3, 54.1}},
            },
        },
        [407505] = { -- Etched Carving
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{45,79}},
            },
        },
        [407731] = { -- Stonemason's Toolbox
            [objectKeys.zoneID] = zoneIDs.LOCH_MODAN,
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{46.5, 12.7}},
            },
        },
        [407734] = { -- Gnarlpine Cache
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{44.1, 61.2}},
            },
        },
        [407844] = { -- Libram of Blessings
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{35.8, 49.5}},
            },
        },
        [407850] = { -- Sunken Reliquary
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{36.8, 91.4}},
            },
        },
        [407918] = { -- Empty Trophy Display
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{83.6, 65.5}},
            },
        },
        [408004] = { -- Tangled Blight Pile
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{71.7, 21.4}},
            },
        },
        [408718] = { -- Equipment Stash
            [objectKeys.zoneID] = zoneIDs.WESTFALL,
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{40.8,80.24}},
            },
        },
        [408799] = { -- Idol of the Deep
            [objectKeys.zoneID] = zoneIDs.WESTFALL,
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{26,69.5}},
            },
        },
        [409289] = { -- Strange Orb
            [objectKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{56.2, 26.4},},
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
                [zoneIDs.THE_BARRENS] = {{49.3,33.5}},
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
        },
        [409949] = { -- Twin Owl Statue
            [objectKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{54.0, 83.0}},
            },
        },
        [410020] = { -- Owl Statue
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{87.0, 43.2}},
            },
        },
        [410089] = { -- Owl Statue
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{49.5, 33.8}},
            },
        },
        [410847] = { -- Rusty Safe Western Plaguelands
            [objectKeys.zoneID] = zoneIDs.WESTERN_PLAGUELANDS,
            [objectKeys.spawns] = {
                [zoneIDs.WESTERN_PLAGUELANDS] = {{59.5, 84.5}},
            },
        },
        [411328] = { -- Slumbering Bones
            [objectKeys.zoneID] = zoneIDs.DUSKWOOD,
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{17,37.6}},
            },
        },
        [411674] = { -- Prophecy of a King's Demise
            [objectKeys.spawns] = {
                [130] = {{65.8, 23.4}},
            },
        },
        [414658] = { -- Rubble
            [objectKeys.zoneID] = zoneIDs.HILLSBRAD_FOOTHILLS,
            [objectKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{79.7, 40.9}},
            },
        },

        -- fake ID - no clue yet what the correct ones are
        [450000] = {
            [objectKeys.name] = "Arcane Shard",
            [objectKeys.zoneID] = zoneIDs.ASHENVALE,
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{13.1,24.8},{13,15},{14,19}},
            },
        },
        [450001] = {
            [objectKeys.name] = "The Lessons of Ta'zo",
            [objectKeys.zoneID] = zoneIDs.ORGRIMMAR,
            [objectKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{38.7,78.4}},
            },
        },
        [450002] = {
            [objectKeys.name] = "Medusa Statue",
            [objectKeys.zoneID] = zoneIDs.WESTFALL,
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{26,70}},
            },
        },
        [450003] = {
            [objectKeys.name] = "Thistlefur Dreamcatcher",
            [objectKeys.zoneID] = zoneIDs.ASHENVALE,
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{38,26}},
            },
        },
        [450004] = {
            [objectKeys.name] = "Wishing Well",
            [objectKeys.zoneID] = zoneIDs.LOCH_MODAN,
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{36.4,19.6}},
            },
        },
        [450005] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            [objectKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{80.3, 79.1}},
            },
        },
        [450006] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = zoneIDs.DUROTAR,
            [objectKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{62.1, 94.8}},
            },
        },
        [450007] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = zoneIDs.TIRISFAL_GLADES,
            [objectKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{52.9, 54}},
            },
        },
        [450008] = {
            [objectKeys.name] = "Buried Treasure",
            [objectKeys.zoneID] = zoneIDs.TELDRASSIL,
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{55.3, 90.8}},
            },
        },
        [450009] = {
            [objectKeys.name] = "Secluded Grave",
            [objectKeys.zoneID] = zoneIDs.DUSKWOOD,
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{90.9,30.5}},
            },
        },
        [450010] = {
            [objectKeys.name] = "Raven Hill Statue",
            [objectKeys.zoneID] = zoneIDs.DUSKWOOD,
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{19.9,45.5}},
            },
        },
        [450011] = {
            [objectKeys.name] = "Galvanic Icon",
            [objectKeys.zoneID] = zoneIDs.DUROTAR,
            [objectKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{38.01, 35.53},{53.36, 50.48},{51.78, 56.39},{36.95, 45.53},{56.53, 28.37},{39.43, 50.06}},
            },
        },
        [450012] = {
            [objectKeys.name] = "Galvanic Icon",
            [objectKeys.zoneID] = zoneIDs.MULGORE,
            [objectKeys.spawns] = {
                [zoneIDs.MULGORE] = {{54.07, 55.82},{36.3, 9.8},{37.5, 52.5},{41.65, 55.98},{37.99, 60.04}},
            },
        },
    }
end
