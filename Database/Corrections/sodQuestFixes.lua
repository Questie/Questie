---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

function SeasonOfDiscovery:LoadQuests()
    local questKeys = QuestieDB.questKeys
    local zoneIDs = ZoneDB.zoneIDs
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local sortKeys = QuestieDB.sortKeys
    local profKeys = QuestieProfessions.professionKeys
    local specKeys = QuestieProfessions.specializationKeys

    return {
        -- Example from corrections
        [77617] = {
            [questKeys.name] = "Relics of the Light",
            [questKeys.startedBy] = {{925}},
            [questKeys.finishedBy] = {{925}},
            [questKeys.requiredLevel] = 2,
            [questKeys.questLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Recover the libram and follow its guidance to learn a new ability, then return to Brother Sammuel in Northshire."},
            [questKeys.objectives] = {nil, nil, nil, nil, nil, {{410002}}},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
        },
        [77666] = {
            [questKeys.name] = "Stolen Power",
            [questKeys.startedBy] = {{460}},
            [questKeys.finishedBy] = {{460}},
            [questKeys.requiredLevel] = 2,
            [questKeys.questLevel] = 2,
            [questKeys.requiredRaces] = raceIDs.GNOME,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectivesText] = {"Recover the rune from the group of Troggs, southwest of Anvilmar, and use it to learn a new ability. Then, return to Alamar Grimm in Anvilmar."},
            [questKeys.objectives] = {nil, nil, nil, nil, nil, {{403501}}},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
        },

        --[88] = {
        --    [questKeys.name] = "this is a test"
        --}
    }
end
