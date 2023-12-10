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

    -- TODO: reputation once data is more reliably confirmed
    -- TODO: ZoneIDs, sort keys

    return {
        [78916] = { -- The Heart of the Void
            [questKeys.startedBy] = {nil, nil, {209693}},
            [questKeys.finishedBy] = {4783},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.sourceItemId] = {209693},
        },
        [78917] = { -- The Heart of the Void
            [questKeys.startedBy] = {nil, nil, {211452}},
            [questKeys.finishedBy] = {9087},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.sourceItemId] = {211452},
        },
        [78920] = { -- Baron Aquanis
            [questKeys.startedBy] = {nil, nil, {211454}},
            [questKeys.finishedBy] = {{12736}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [78921] = { -- Blackfathom Villainy
            [questKeys.startedBy] = {{4787}},
            [questKeys.finishedBy] = {{4783}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{5881}}},
        },
        [78922] = { -- Blackfathom Villainy
            [questKeys.startedBy] = {{4787}},
            [questKeys.finishedBy] = {{9087}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {nil,nil,{{5881}}},
        },
        [78923] = { -- Knowledge in the Deeps
            [questKeys.startedBy] = {{2786}},
            [questKeys.finishedBy] = {{2786}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{5881}}},
        },
        [78925] = { -- Twilight Falls
            [questKeys.startedBy] = {{4784}},
            [questKeys.finishedBy] = {{4784}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{5879}}},
        },
        [78926] = { -- Researching the Corruption
            [questKeys.startedBy] = {{8997}},
            [questKeys.finishedBy] = {{8997}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{5952}}},
        },
        [78927] = { -- Allegiance to the Old Gods
            [questKeys.startedBy] = {{12736}},
            [questKeys.finishedBy] = {{12736}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectives] = {{{207356}},nil,nil},
        },
        [79099] = { -- Baron Aquanis
            [questKeys.startedBy] = {{214876}},
            [questKeys.finishedBy] = {{214876}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectives] = {nil,nil,{{211818}}},
        },
    }
end
