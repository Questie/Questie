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
        [78611] = {
            [questKeys.name] = "A Waylaid Shipment",
            [questKeys.startedBy] = {{214101}},
            [questKeys.finishedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 8,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [78612] = {
            [questKeys.name] = "A Full Shipment",
            [questKeys.startedBy] = {{214101}},
            [questKeys.finishedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 9,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [78872] = {
            [questKeys.name] = "A Full Shipment",
            [questKeys.startedBy] = {{214101}},
            [questKeys.finishedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 12,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [79100] = {
            [questKeys.name] = "A Waylaid Shipment",
            [questKeys.startedBy] = {{214101}},
            [questKeys.finishedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 15,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [79101] = {
            [questKeys.name] = "A Full Shipment",
            [questKeys.startedBy] = {{214101}},
            [questKeys.finishedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 18,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [79102] = {
            [questKeys.name] = "A Full Shipment",
            [questKeys.startedBy] = {{214101}},
            [questKeys.finishedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 22,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [79103] = {
            [questKeys.name] = "A Full Shipment",
            [questKeys.startedBy] = {{214101}},
            [questKeys.finishedBy] = {{213077,214070,214098,214101,}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 25,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
        },
    }
end
