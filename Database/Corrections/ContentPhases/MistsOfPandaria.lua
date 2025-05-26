---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")

-- This function blacklists any quests in phases LATER than the currentPhase value
-- so in Phase 1, quests in phases 2+ are blacklisted, in phase 2, phases 3+ are blacklisted, etc
-- Phase 1 is omitted, because everything not in this list is supposed to be available in Phase 1
local questsToBlacklistByPhase = {
    [1] = {}, -- Phase 1 (this is required for counting, but should stay empty)
    [2] = { -- Phase 2 (Patch 5.1 Landfall (Brawlers Guild, New Scenarios)
    },
    [3] = { -- Phase 3 (Patch 5.2 The Thunder King (Isle of Thunder, Throne of Thunder))
    },
    [4] = { -- Phase 4 (Patch 5.3 Escalation (Deepwind Gorge, New Scenarios, Heroic Scenarios))
        [32806] = true, -- The King and the Council
        [32807] = true, -- The Warchief and the Darkness
        [32816] = true, -- Path of the Last Emperor
        [32863] = true, -- What We've Been Training For
        [32868] = true, -- Beasts of Fable Book II
        [32869] = true, -- Beasts of Fable Book III
        [32900] = true, -- Heroic Deeds
        [32901] = true, -- Heroic Deeds
    },
    [5] = { -- Phase 5 (Patch 5.4 Siege of Orgrimmar (Raid, Timeless Isle, Proving Grounds)
    },
}

---@param questsToBlacklist table<QuestId, boolean>
---@param contentPhase number
---@return table<QuestId, boolean>
function ContentPhases.BlacklistMoPQuestsByPhase(questsToBlacklist, contentPhase)
    for phase = contentPhase + 1, #questsToBlacklistByPhase do
        for questId in pairs(questsToBlacklistByPhase[phase]) do
            questsToBlacklist[questId] = true
        end
    end

    return questsToBlacklist
end
