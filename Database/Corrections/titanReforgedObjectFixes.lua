---@class TitanReforgedObjectFixes
local TitanReforgedObjectFixes = QuestieLoader:CreateModule("TitanReforgedObjectFixes")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

---Returns Titan-only object corrections applied before database compilation.
---@return table<ObjectId, table>
function TitanReforgedObjectFixes.LoadObjects()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [420002] = { -- Blood Ritual Altar
            [objectKeys.name] = "Blood Ritual Altar",
            [objectKeys.spawns] = {[zoneIDs.ZUL_GURUB] = {{-1,-1}}},
            [objectKeys.zoneID] = zoneIDs.ZUL_GURUB,
        },
    }
end
