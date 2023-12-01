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
        -- Example from corrections
        -- [185333] = {
        --     [npcKeys.name] = "Avelina Lilly",
        --     [npcKeys.minLevel] = 22,
        --     [npcKeys.maxLevel] = 22,
        --     [npcKeys.zoneID] = zoneIDs.SILVERPINE_FOREST,
        --     [npcKeys.spawns] = {[zoneIDs.SILVERPINE_FOREST] = {{63.5,65.3}}},
        -- },
    }
end
