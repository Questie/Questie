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
        [405633] = {
            [objectKeys.name] = "Rockjaw Footlocker",
            [objectKeys.zoneID] = 1,
            [objectKeys.spawns] = {
                [1] = {{26.8, 72.6},},
            },
        },
        [387477] = {
            [objectKeys.name] = "Defias Stashbox",
            [objectKeys.zoneID] = 12,
            [objectKeys.spawns] = {
                [12] = {{52.6, 51.8},},
            },
        },
        [406736] = {
            [objectKeys.name] = "Lost Stash",
            [objectKeys.zoneID] = 85,
            [objectKeys.spawns] = {
                [85] = {{24.6, 59.4},{24.6, 59.5},},
            },
        },
        [404695] = {
            [objectKeys.name] = "Waterlogged Stashbox",
            [objectKeys.zoneID] = 14,
            [objectKeys.spawns] = {
                [14] = {{43, 54.4},{43, 54.5},},
            },
        },
    }
end
