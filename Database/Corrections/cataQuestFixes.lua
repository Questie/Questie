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
        [28762] = {
            [questKeys.name] = "Beating Them Back!",
            [questKeys.startedBy] = {{197}},
            [questKeys.finishedBy] = {{197,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Kill 6 Blackrock Worgs."},
            [questKeys.objectives] = {{{49871}}},
            [questKeys.zoneOrSort] = zoneIDs.ELWYNN_FOREST, -- TODO: This is actually "Northshire"
        },
    }
end
