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
        [196472] = { -- Grandma's Good Clothes
            [objectKeys.spawns] = {[zoneIDs.GILNEAS]={{32.03,75.45}}},
        },
        [197196] = { -- Waters of Farseeing
            [objectKeys.spawns] = {
                [zoneIDs.STORMWIND_CITY] = {{41.71,47.5}},
                [zoneIDs.ORGRIMMAR] = {{50.9,37.9}},
            }
        },
        [201974] = { -- Raptor Trap
            [objectKeys.spawns] = {},
        },
        [201977] = { -- The Biggest Egg Ever
            [objectKeys.spawns] = {},
        },
        [204281] = { -- Worm Mound
            [objectKeys.spawns] = {[1519]={{49.24,18.03},{52.53,14.86},{64.01,16.59},{63.39,5.73},{64.93,8.47},{56.45,22.58},{55.73,16.51},{53.73,19.56},{60.51,6.85},{58.05,10.49},{62.12,17.65},{59.07,20.64}}},
        },
    }
end
