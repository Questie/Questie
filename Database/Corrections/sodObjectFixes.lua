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
        -- Example from corrections
        -- [500005] = {
        --     [objectKeys.name] = "Ironforge City Fishing Location",
        --     [objectKeys.questStarts] = {},
        --     [objectKeys.questEnds] = {},
        --     [objectKeys.spawns] = {[zoneIDs.IRONFORGE]={{46.9,14.5}}},
        --     [objectKeys.zoneID] = zoneIDs.IRONFORGE
        -- },
    }
end
