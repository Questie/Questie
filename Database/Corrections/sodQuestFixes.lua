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
    local questFlags = QuestieDB.questFlags
    local specialFlags = QuestieDB.specialFlags
    local profKeys = QuestieProfessions.professionKeys
    local specKeys = QuestieProfessions.specializationKeys

    -- TODO: reputation once data is more reliably confirmed
    -- TODO: ZoneIDs, sort keys

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
        [78916] = { -- The Heart of the Void
            [questKeys.startedBy] = {nil, nil, {209693}},
            [questKeys.finishedBy] = {{4783}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.sourceItemId] = 209693,
            [questKeys.zoneOrSort] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [78917] = { -- The Heart of the Void
            [questKeys.startedBy] = {nil, nil, {211452}},
            [questKeys.finishedBy] = {{9087}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.sourceItemId] = 211452,
            [questKeys.zoneOrSort] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [78920] = { -- Baron Aquanis
            [questKeys.startedBy] = {nil, nil, {211454}},
            [questKeys.finishedBy] = {{12736}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = zoneIDs.ASHENVALE,
        },
        [78921] = { -- Blackfathom Villainy
            [questKeys.startedBy] = {{4787}},
            [questKeys.finishedBy] = {{4783}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{5881}}},
            [questKeys.zoneOrSort] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [78922] = { -- Blackfathom Villainy
            [questKeys.startedBy] = {{4787}},
            [questKeys.finishedBy] = {{9087}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {nil,nil,{{5881}}},
            [questKeys.zoneOrSort] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [78923] = { -- Knowledge in the Deeps
            [questKeys.startedBy] = {{2786}},
            [questKeys.finishedBy] = {{2786}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{5359}}},
            [questKeys.zoneOrSort] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [78925] = { -- Twilight Falls
            [questKeys.startedBy] = {{4784}},
            [questKeys.finishedBy] = {{4784}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{5879}}},
            [questKeys.zoneOrSort] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [78926] = { -- Researching the Corruption
            [questKeys.startedBy] = {{8997}},
            [questKeys.finishedBy] = {{8997}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{5952}}},
            [questKeys.zoneOrSort] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [78927] = { -- Allegiance to the Old Gods
            [questKeys.startedBy] = {{12736}},
            [questKeys.finishedBy] = {{12736}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{207356}},nil,nil},
            [questKeys.zoneOrSort] = zoneIDs.BLACKFATHOM_DEEPS,
        },
        [79090] = {
            [questKeys.startedBy] = {{212727,212728,212729,212730,212801,212802}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [79098] = {
            [questKeys.startedBy] = {{212699,212703,212706,212707,212803,212804}},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [79099] = { -- Baron Aquanis
            [questKeys.startedBy] = {{214876}},
            [questKeys.finishedBy] = {{214876}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{211818}}},
            [questKeys.zoneOrSort] = zoneIDs.AUBERDINE,
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
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [79482] = {
            [questKeys.startedBy] = {{13433}},
            [questKeys.startedBy] = {{13636}},
            [questKeys.questFlags] = questFlags.RAID,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [79482] = {
            [questKeys.startedBy] = {{13418}},
            [questKeys.startedBy] = {{13636}},
            [questKeys.questFlags] = questFlags.RAID,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [79492] = {
            [questKeys.startedBy] = {{13433}},
            [questKeys.finishedBy] = {{13433}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {{{15664,"Find Metzen the Reindeer and rescue him"}},nil,{21211}},
            [questKeys.questFlags] = questFlags.RAID,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [79495] = {
            [questKeys.startedBy] = {{13418}},
            [questKeys.finishedBy] = {{13418}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{15664,"Find Metzen the Reindeer and rescue him"}},nil,{21211}},
            [questKeys.questFlags] = questFlags.RAID,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
    }
end
