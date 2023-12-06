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
    }
end
