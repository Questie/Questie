---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")

local currentPhase = 1 -- TODO: Use API function which hopefully will come in the future

-- Phase 1 is omitted, because everything not in this list is supposed to be available in Phase 1
local questsToBlacklistBySoMPhase = {
    [1] = {}, -- This is required for counting, but should stay empty
    [2] = {
        [2161] = true,
    },
    [3] = {
        [456] = true,
    },
    [4] = {
        [789] = true,
    },
    [5] = {
        [1111] = true,
    },
}

---@return table<number, table<number, boolean>> @All quests that should be blacklisted separated by phase
function QuestieQuestBlacklist:GetSoMQuestsToBlacklist()
    for phase = 1, currentPhase do
        questsToBlacklistBySoMPhase[phase] = {} -- empty table instead of nil to keep table size
    end
    return questsToBlacklistBySoMPhase
end
