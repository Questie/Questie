---@class CataQuestFixes
local CataQuestFixes = QuestieLoader:CreateModule("CataQuestFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

function CataQuestFixes.Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local profKeys = QuestieProfessions.professionKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [578] = { -- The Stone of the Tides
            [questKeys.childQuests] = {579},
        },
        [579] = { -- Stormwind Library
            [questKeys.parentQuest] = 578,
        },
        [2438] = { -- The Emerald Dreamcatcher
            [questKeys.specialFlags] = 0,
        },
        [14071] = { -- Rolling with my Homies
            [questKeys.childQuests] = {28607},
        },
        [24960] = { -- The Wakening
            [questKeys.preQuestSingle] = {28608},
        },
        [25473] = { -- Kaja'Cola
            [questKeys.startedBy] = {{34872}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {14075,14069},
        },
        [28607] = { -- The Keys to the Hot Rod
            [questKeys.parentQuest] = 14071,
        },
        [29481] = { -- Elixir Master
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
        [29482] = { -- Transmutation Master
            [questKeys.requiredSkill] = {profKeys.ALCHEMY,475},
        },
    }
end

function CataQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys

    local questFixesHorde = {
        [29481] = { -- Elixir Master
            [questKeys.startedBy] = {{3347}}
        },
        [29482] = { -- Transmutation Master
            [questKeys.startedBy] = {{3347}}
        },
    }

    local questFixesAlliance = {
        [29481] = { -- Elixir Master
            [questKeys.startedBy] = {{5499}}
        },
        [29482] = { -- Transmutation Master
            [questKeys.startedBy] = {{5499}}
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end
