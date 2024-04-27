---@class CataNpcFixes
local CataNpcFixes = QuestieLoader:CreateModule("CataNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type Phasing
local Phasing = QuestieLoader:ImportModule("Phasing")

function CataNpcFixes.Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local phases = Phasing.phases

    return {
        [34872] = { -- Foreman Dampwick
            [npcKeys.spawns] = {
                [zoneIDs.KEZAN] = {
                    {60.22,74.56,phases.KEZAN_CHAPTER_1},
                    {63.03,77.81,phases.KEZAN_CHAPTER_5},
                    {63.03,77.81,phases.KEZAN_CHAPTER_6},
                    {21.63,13.47,phases.KEZAN_CHAPTER_7},
                },
            },
        },
        [34874] = { -- Megs Dreadshredder
            [npcKeys.spawns] = {
                [zoneIDs.KEZAN] = {
                    {58.23,76.45,phases.KEZAN_CHAPTER_1},
                    {60.08,78.23,phases.KEZAN_CHAPTER_5},
                    {60.08,78.23,phases.KEZAN_CHAPTER_6},
                    {21.62,12.91,phases.KEZAN_CHAPTER_7},
                },
            },
        },
        [35222] = { -- Trade Prince Gallywix
            [npcKeys.spawns] = {
                [zoneIDs.KEZAN] = {
                    {50.48,59.89,phases.KEZAN_CHAPTER_1},
                    {56.7,76.9,phases.KEZAN_CHAPTER_2},
                    {16.7,26.06,phases.KEZAN_CHAPTER_5},
                    {20.84,13.69,phases.KEZAN_CHAPTER_7},
                },
            },
        },
        [35875] = { -- Aggra
            [npcKeys.spawns] = {
                [zoneIDs.THE_LOST_ISLES] = {
                    {37.63,78.03,phases.LOST_ISLES_OR_GILNEAS_CHAPTER_1},
                    {37.63,78.03,phases.LOST_ISLES_CHAPTER_2},
                },
            },
        },
        [37602] = { -- Claims Adjuster
            [npcKeys.spawns] = {
                [zoneIDs.KEZAN] = {
                    {59.6,76.48,phases.KEZAN_CHAPTER_6},
                },
            },
        },
        [38387] = { -- Sassy Hardwrench
            [npcKeys.spawns] = {
                [zoneIDs.THE_LOST_ISLES] = {
                    {45.18,64.9,phases.LOST_ISLES_CHAPTER_5},
                    {45.18,64.9,phases.LOST_ISLES_CHAPTER_6},
                    {45.18,64.9,phases.LOST_ISLES_CHAPTER_7},
                    {37.3,41.9,phases.LOST_ISLES_CHAPTER_8},
                    {43.63,25.32,phases.LOST_ISLES_CHAPTER_9},
                    {42.57,16.38,phases.LOST_ISLES_CHAPTER_10},
                },
            },
        },
        [38935] = { -- Thrall
            [npcKeys.spawns] = {
                [zoneIDs.THE_LOST_ISLES] = {
                    {36.79,43.13,phases.LOST_ISLES_CHAPTER_5},
                    {36.79,43.13,phases.LOST_ISLES_CHAPTER_8},
                    {42.16,17.37,phases.LOST_ISLES_CHAPTER_10},
                },
            },
        },
        [39065] = { -- Aggra
            [npcKeys.spawns] = {
                [zoneIDs.THE_LOST_ISLES] = {
                    {36.26,43.37,phases.LOST_ISLES_CHAPTER_5},
                    {36.26,43.37,phases.LOST_ISLES_CHAPTER_8},
                    {42.55,18.22,phases.LOST_ISLES_CHAPTER_9},
                    {42.19,17.4,phases.LOST_ISLES_CHAPTER_10},
                },
            },
        },
        [41600] = { -- Erunak Stonespeaker
            [npcKeys.spawns] = {
                [zoneIDs.ABYSSAL_DEPTHS] = {{51.57,60.9}},
            },
        },
        [41636] = { -- Legionnaire Nazgrim
            [npcKeys.spawns] = {
                [zoneIDs.ABYSSAL_DEPTHS] = {{42.66,37.82}},
            },
        },
        [42644] = { -- Smoot
            [npcKeys.waypoints] = {[zoneIDs.AZSHARA]={{56.89,49.26},{56.84,49.43},{56.73,49.64},{56.65,49.86},{56.60,50.03},{56.58,50.19},{56.65,49.94},{56.72,49.70},{56.80,49.46},{56.89,49.26},{56.98,49.33},{57.12,49.49},{57.28,49.60},{57.45,49.67},{57.50,49.69},{57.58,49.85},{57.71,49.96},{57.85,49.79},{58.00,49.65},{58.13,49.77},{58.13,49.89},{58.17,49.70},{58.21,49.45},{58.06,49.42},{57.89,49.49},{57.73,49.60},{57.56,49.61},{57.51,49.57},{57.36,49.53},{57.19,49.47},{57.02,49.38},{56.90,49.20},{56.81,48.97},{56.70,48.75},{56.58,48.56},{56.45,48.37},{56.31,48.22},{56.27,48.18},{56.26,48.20},{56.13,48.38},{56.00,48.57},{55.87,48.75},{55.75,48.94},{55.63,49.14},{55.56,49.25},{55.51,49.32},{55.39,49.51},{55.27,49.71},{55.23,49.78},{55.22,49.92},{55.24,50.18},{55.36,50.32},{55.46,50.12},{55.37,49.90},{55.29,49.89},{55.22,50.09},{55.26,50.35},{55.33,50.60},{55.40,50.84},{55.50,51.06},{55.62,51.24},{55.76,51.41},{55.90,51.58},{56.07,51.64},{56.24,51.74},{56.33,51.86},{56.35,51.71},{56.40,51.45},{56.46,51.20},{56.54,50.96},{56.60,50.71},{56.61,50.45},{56.61,50.18},{56.47,50.20},{56.43,50.24},{56.51,50.46},{56.58,50.69},{56.53,50.95},{56.45,51.19},{56.35,51.41},{56.27,51.64},{56.25,51.72},{56.36,51.93},{56.38,52.02},{56.30,51.87},{56.17,51.70},{56.01,51.58},{55.95,51.54},{55.80,51.40},{55.66,51.24},{55.53,51.07},{55.41,50.87},{55.37,50.70},{55.36,50.67},{55.32,50.41},{55.22,50.20},{55.17,49.94},{55.29,49.81},{55.30,49.81},{55.35,49.89},{55.48,50.06},{55.62,50.22},{55.79,50.31},{55.94,50.19},{55.94,50.18},{55.95,50.15},{56.00,49.94},{56.15,50.09},{56.31,50.21},{56.47,50.23},{56.58,50.42},{56.60,50.68},{56.54,50.93},{56.52,51.04},{56.46,51.29},{56.47,51.30},{56.64,51.34},{56.82,51.36},{57.00,51.39},{57.17,51.41},{57.35,51.39},{57.48,51.23},{57.53,51.07},{57.61,50.88},{57.69,50.80},{57.83,50.93},{57.84,51.18},{57.72,51.36},{57.64,51.37},{57.46,51.38},{57.28,51.36},{57.22,51.36},{57.09,51.39},{56.91,51.38},{56.74,51.39},{56.56,51.36},{56.46,51.27},{56.50,51.15},{56.56,50.90},{56.63,50.65},{56.64,50.52},{56.60,50.36},{56.56,50.21},{56.56,50.20},{56.63,49.95},{56.72,49.73},{56.81,49.49},{56.89,49.36},{57.01,49.42},{57.17,49.54},{57.35,49.58},{57.42,49.60},{57.55,49.79},{57.66,49.99},{57.69,50.03},{57.69,50.05},{57.71,50.31},{57.67,50.56},{57.57,50.78},{57.52,50.94},{57.46,51.03},{57.32,51.19},{57.17,51.31},{56.99,51.36},{56.82,51.34},{56.64,51.30},{56.51,51.27},{56.51,51.16},{56.55,50.90},{56.61,50.65},{56.59,50.38},{56.57,50.19},{56.43,50.18},{56.25,50.18},{56.07,50.17},{55.90,50.22},{55.72,50.26},{55.59,50.21},{55.53,50.12},{55.39,49.95},{55.31,49.88},{55.32,49.89},{55.41,49.98},{55.42,49.99},{55.56,50.15},{55.71,50.29},{55.87,50.23},{56.03,50.16},{56.21,50.17},{56.39,50.20},{56.56,50.21},{56.58,50.21},{56.60,50.05},{56.66,49.80},{56.75,49.57},{56.86,49.36},{56.89,49.29}}},
        },
        [43792] = { -- Therazane
            [npcKeys.questStarts] = {26709,28824},
        },
        [44025] = {
            [npcKeys.spawns] = {
                [zoneIDs.DEEPHOLM] = {
                    {63.33,24.95,phases.THE_STONE_MARCH},
                    {63.33,24.95,phases.TEMPLE_OF_EARTH_CHAPTER_1},
                },
            },
        },
        [47838] = { -- Shrine 1 Cleansed
            [npcKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{34.18,35.74}}},
            [npcKeys.zoneID] = zoneIDs.TWILIGHT_HIGHLANDS,
        },
        [47839] = { -- Shrine 1 Cleansed
            [npcKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{33.59,37.76}}},
            [npcKeys.zoneID] = zoneIDs.TWILIGHT_HIGHLANDS,
        },
        [47840] = { -- Shrine 1 Cleansed
            [npcKeys.spawns] = {[zoneIDs.TWILIGHT_HIGHLANDS]={{34.33,37.75}}},
            [npcKeys.zoneID] = zoneIDs.TWILIGHT_HIGHLANDS,
        },
        [49456] = { -- Finkle\'s Mole Machine
            [npcKeys.spawns] = {
                [zoneIDs.MOUNT_HYJAL] = {{42.7,28.8}}
            },
            [npcKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        },
        [49476] = { -- Finkle Einhorn
            [npcKeys.questStarts] = {28735,28737,28738,28740,28741},
        },
    }
end
