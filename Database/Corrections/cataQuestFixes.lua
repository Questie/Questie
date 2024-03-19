---@class CataQuestFixes
local CataQuestFixes = QuestieLoader:CreateModule("CataQuestFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function CataQuestFixes.Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [579] = { -- Stormwind Library
            [questKeys.parentQuest] = 578,
        },
        [2438] = { -- The Emerald Dreamcatcher
            [questKeys.specialFlags] = 0,
        }
    }
end
