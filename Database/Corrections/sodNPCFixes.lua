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
        [202060] = {
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{76.8, 51.4}},
                [zoneIDs.TIRISFAL_GLADES] = {{66.4, 40.2}},
            },
        },
        [208275] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUROTAR] = {{58.6, 45.6}},
            },
        },
        [208752] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUN_MOROGH] = {{69.2, 58.2}},
            },
        },
        [211022] = {
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{73.4,33}},
            },
            [npcKeys.friendlyToFaction] = "H",
        },
        [211033] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{37.8,80.2}},
            },
            [npcKeys.friendlyToFaction] = "A",
        },
        [213077] = {
            [npcKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{54.5,61.2}},
            },
        },
        [214070] = {
            [npcKeys.spawns] = {
                [zoneIDs.ORGRIMMAR] = {{51.6,64.6}},
            },
        },
        [214096] = {
            [npcKeys.spawns] = {
                [zoneIDs.THUNDER_BLUFF] = {{39.8,53.4}},
            },
        },
        [214098] = {
            [npcKeys.spawns] = {
                [zoneIDs.UNDERCITY] = {{64.6,38.2}},
            },
        },
        [214099] = {
            [npcKeys.spawns] = {
                [zoneIDs.IRONFORGE] = {{24.3,67.2}},
            },
        },
        [214101] = {
            [npcKeys.spawns] = {
                [zoneIDs.DARNASSUS] = {{60,56.4}},
            },
        },
        [212261] = {
            [npcKeys.spawns] = {
                [zoneIDs.DUSKWOOD] = {{17,37.6}},
            },
        },
    }
end
