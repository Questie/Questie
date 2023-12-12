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
    }
end
