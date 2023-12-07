---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

--- Load the base quests for Season of Discovery
--- These are generated, do NOT EDIT the data entries here.
--- If you want to edit a quest, do so in sodQuestFixes.lua
function SeasonOfDiscovery:LoadBaseQuests()
    local questKeys = QuestieDB.questKeys
    local zoneIDs = ZoneDB.zoneIDs
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local sortKeys = QuestieDB.sortKeys

    return {
        [78265] = {
            [questKeys.name] = "Fish Oil",
            [questKeys.startedBy] = {{211653}},
            [questKeys.finishedBy] = {{211653,}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [78266] = {
            [questKeys.name] = "Dark Iron Ordinance",
            [questKeys.startedBy] = {{211653}},
            [questKeys.finishedBy] = {{211653,}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [78267] = {
            [questKeys.name] = "Shredder Turbochargers",
            [questKeys.startedBy] = {{211653}},
            [questKeys.finishedBy] = {{211653,}},
            [questKeys.requiredLevel] = 20,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
    }
end
