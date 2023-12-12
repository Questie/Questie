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
        [77617] = {
            [questKeys.name] = "Relics of the Light",
            [questKeys.startedBy] = {{925}},
            [questKeys.finishedBy] = {{925,}},
            [questKeys.requiredLevel] = 2,
            [questKeys.questLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Recover the libram and follow its guidance to learn a new ability, then return to Brother Sammuel in Northshire."},
            [questKeys.objectives] = {{nil,nil,nil,nil,nil,{410002}}},
        },
        [77666] = {
            [questKeys.name] = "Stolen Power",
            [questKeys.startedBy] = {{460}},
            [questKeys.finishedBy] = {{460,}},
            [questKeys.requiredLevel] = 2,
            [questKeys.questLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.GNOME,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Recover the rune from the group of Troggs, southwest of Anvilmar, and use it to learn a new ability. Then, return to Alamar Grimm in Anvilmar."},
            [questKeys.objectives] = nil,
        },
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
