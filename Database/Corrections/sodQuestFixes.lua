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
        [77617] = {
            [questKeys.objectives] = {nil, nil, nil, nil, nil, {{410002, nil, 205420}}},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.requiredSpell] = -410002,
        },
        [77666] = {
            [questKeys.objectives] = {nil, nil, nil, nil, nil, {{403919, nil, 205230}}},
            [questKeys.zoneOrSort] = sortKeys.WARLOCK,
            [questKeys.requiredSpell] = -403919,
        },
    }
end
