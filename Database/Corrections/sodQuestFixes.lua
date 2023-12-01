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
        -- [65610] = {
        --     [questKeys.name] = "Wish You Were Here",
        --     [questKeys.startedBy] = { { 3363 }, nil, nil },
        --     [questKeys.finishedBy] = { { 5875 }, nil },
        --     [questKeys.requiredLevel] = 20,
        --     [questKeys.questLevel] = -1,
        --     [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        --     [questKeys.requiredClasses] = classIDs.WARLOCK,
        --     [questKeys.objectivesText] = { "Investigate Fallen Sky Lake in Ashenvale and report your findings to Gan'rul Bloodeye in Orgrimmar." },
        --     [questKeys.preQuestSingle] = { 65601 },
        --     [questKeys.objectives] = { nil, nil, { { 190232 } }, nil, nil },
        --     [questKeys.exclusiveTo] = { 65593 },
        --     [questKeys.zoneOrSort] = sortKeys.WARLOCK,
        -- },

        --[88] = {
        --    [questKeys.name] = "this is a test"
        --}
    }
end
