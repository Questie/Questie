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
        [386691] = {
            [objectKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{76, 10.4}},
            },
        },
        [403718] = {
            [objectKeys.zoneID] = zoneIDs.MULGORE,
            [objectKeys.spawns] = {
                [zoneIDs.MULGORE] = {{37.81, 65.45},{38.17, 57.14},{39.85, 51.63},{41.39, 63.2},{45.01, 46.77},{50.97, 46.03},{51.77, 67.3},{53.29, 63.13},{54.31, 58.05},{58.41, 66.64},{58.85, 51.32}},
            },
        },
        [406736] = {
            [objectKeys.spawns] = {
                [zoneIDs.TIRISFAL_GLADES] = {{24.7, 59.4}},
            },
        },
        [407247] = {
            [objectKeys.zoneID] = zoneIDs.TELDRASSIL,
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{57.06, 65.57},{58.05, 73.19},{59.63, 60.05},{61.09, 54.02},{63.88, 64.90},{64.89, 54.77},{65.64, 59.22},{66.56, 51.55},{67.36, 64.15},{69.56, 55.75}},
            },
        },
        [407454] = {
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{61.78,45.8}},
            },
        },
        [407505] = {
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{45,79}},
            },
        },
        [407734] = {
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{44.1, 61.2}},
            },
        },
        [408718] = {
            [objectKeys.zoneID] = zoneIDs.WESTFALL,
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{40.8,80.24}},
            },
        },
        [409289] = {
            [objectKeys.spawns] = {
                [zoneIDs.DARKSHORE] = {{56.2, 26.4},},
            },
        },
        [409562] = {
            [objectKeys.spawns] = {
                [zoneIDs.WESTFALL] = {{45.4, 70.4}},
            },
        },
        [409692] = {
            [objectKeys.zoneID] = zoneIDs.THE_BARRENS,
            [objectKeys.spawns] = {
                [zoneIDs.THE_BARRENS] = {{49.3,33.5}},
            },
        },
        [409731] = {
            [objectKeys.spawns] = {
                [zoneIDs.LOCH_MODAN] = {{77.4, 14}},
            },
        },
        [409735] = {
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{16.7, 28.4}},
            },
        },
        [409942] = {
            [objectKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{36.9, 76.1}},
            },
        },
        [409949] = {
            [objectKeys.spawns] = {
                [zoneIDs.HILLSBRAD_FOOTHILLS] = {{54.0, 83.0}},
            },
        },
        [410020] = {
            [objectKeys.spawns] = {
                [zoneIDs.ASHENVALE] = {{87.0, 43.2}},
            },
        },
        [410089] = {
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{49.5, 33.8}},
            },
        },
        [411328] = {
            [objectKeys.zoneID] = zoneIDs.DUSKWOOD,
            [objectKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{17,37.6}},
            },
        },
        [414658] = {
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
    }
end
