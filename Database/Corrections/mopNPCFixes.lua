---@class MopNpcFixes
local MopNpcFixes = QuestieLoader:CreateModule("MopNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type Phasing
local Phasing = QuestieLoader:ImportModule("Phasing")

function MopNpcFixes.Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local phases = Phasing.phases

    return {
        [53566] = { -- Master Shang Xi
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {56.67,18.18,phases.SHANG_XI_BENCH},
                    {59.69,19.11,phases.SHANG_XI_DOORWAY},
                    {65.98,22.81,phases.SHANG_XI_BRIDGE},
                },
            },
        },
        [54135] = { -- Master Li Fei
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{38.81,25.51}}},
        },
        [54631] = { -- Living Air
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{48.02,31.39}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [54786] = { -- Master Shang Xi
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {51.41,46.39,phases.SHANG_XI_TEMPLE_NORTH},
                    {51.59,48.34,phases.SHANG_XI_TEMPLE_SOUTH},
                },
            },
        },
        [54787] = { -- Huo
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{39.42,29.55}}},
        },
        [54943] = { -- Merchant Lorvo
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {55.09,32.84,phases.DRIVER_NOT_RESCUED},
                    {55.11,32.39,phases.DRIVER_RESCUED},
                },
            },
        },
        [54975] = { -- Aysa Cloudsinger
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {65.59,42.61,phases.AYSA_LIANG_POOL_HOUSE},
                    {78.61,42.81,phases.AYSA_LIANG_BRIDGE},
                    {79.81,39.31,phases.AYSA_LIANG_LAKE},
                },
            },
        },
        [55020] = { -- Old Man Liang
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {70.62,38.73,phases.AYSA_LIANG_POOL_HOUSE},
                    {78.49,42.86,phases.AYSA_LIANG_BRIDGE},
                    {79.94,39.31,phases.AYSA_LIANG_LAKE},
                },
            },
        },
        [55205] = { -- Water Spirit Coaxed Credit
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{79.03,37.8}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [55583] = { -- Ji Firepaw
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{30.98,36.74}}},
        },
        [55586] = { -- Master Shang Xi
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{30,60.37}}},
        },
        [55595] = { -- Aysa Cloudsinger
            [npcKeys.spawns] = {
                [zoneIDs.THE_WANDERING_ISLE] = {
                    {32.95,35.61,phases.AYSA_ROPE},
                    {24.78,69.78,phases.AYSA_CAVE},
                },
            },
        },
        [55942] = { -- Ji Firepaw
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{36.36,72.53}}},
        },
        [55944] = { -- Delora Lionheart
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{42.22,86.54}}},
        },
        [56686] = { -- Master Shang Xi
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{19.46,51.22}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [57476] = { -- Crossing Rocks Credit
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{79.7,39.07}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [60488] = { -- Water Spout Bunny
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{78.54,37.08},{78.31,37.77},{78.77,37.52},{78.63,38.81},{78.72,37.2},{78.32,37.1},{79.46,37.99},{79.56,37.64},{78.33,37.75},{78.8,38.64},{79.41,36.63},{79.78,37.54},{79.22,37.4},{79.94,37.7},{79.2,36.68},{78.4,38.79},{79.07,37.03}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [60566] = { -- Aysa Cloudsinger
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{74.2,91.98}}},
            [npcKeys.zoneID] = zoneIDs.STORMWIND_CITY,
        },
        [60570] = { -- Ji Firepaw
            [npcKeys.spawns] = {[zoneIDs.DUROTAR] = {{45.58,12.61}}},
            [npcKeys.zoneID] = zoneIDs.DUROTAR,
        },
        [60727] = { -- Explosion Triggered Credit
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{36.43,87.53}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [60916] = { -- Wugou
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{68.84,64.88}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [61796] = { -- King Varian Wrynn
            [npcKeys.spawns] = {[zoneIDs.STORMWIND_CITY] = {{82.59,28.08}}},
            [npcKeys.zoneID] = zoneIDs.STORMWIND_CITY,
        },
        [62092] = { -- Garrosh Hellscream
            [npcKeys.spawns] = {[zoneIDs.ORGRIMMAR] = {{70.62,31.42}}},
            [npcKeys.zoneID] = zoneIDs.ORGRIMMAR,
        },
        [62209] = { -- Arena Credit
            [npcKeys.spawns] = {[zoneIDs.BRAWLGAR_ARENA] = {{51.6,49},{-1,-1}}},
            [npcKeys.zoneID] = zoneIDs.BRAWLGAR_ARENA,
        },
        -- Fake NPCs for Auto Accept and Auto Turn in
        [110000] = { -- Shu, the Spirit of Water
            [npcKeys.name] = "?",
            [npcKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{79.03,37.8}}},
            [npcKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
            [npcKeys.questEnds] = {29678},
        },
    }
end
