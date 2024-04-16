---@class CataObjectFixes
local CataObjectFixes = QuestieLoader:CreateModule("CataObjectFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")


function CataObjectFixes.Load()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [126158] = { -- Tallonkai's Dresser
            [objectKeys.spawns] = {
                [zoneIDs.TELDRASSIL] = {{66.1,52}}
            }
        },
        [201974] = { -- Raptor Trap
            [objectKeys.spawns] = {},
        },
        [201977] = { -- The Biggest Egg Ever
            [objectKeys.spawns] = {},
        },
    }
end
