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
    local specialFlags = QuestieDB.specialFlags
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
        [78611] = {
            [questKeys.startedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [78612] = {
            [questKeys.startedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [78872] = {
            [questKeys.startedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [79100] = {
            [questKeys.startedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [79101] = {
            [questKeys.startedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [79102] = {
            [questKeys.startedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [79103] = {
            [questKeys.startedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.finishedBy] = {{213077,214070,214096,214098,214099,214101,}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
    }
end
