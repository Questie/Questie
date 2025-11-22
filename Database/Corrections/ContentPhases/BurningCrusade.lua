---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")

-- This function blacklists any quests in phases LATER than the currentPhase value
-- so in Phase 1, quests in phases 2+ are blacklisted, in phase 2, phases 3+ are blacklisted, etc
-- Phase 1 is omitted, because everything not in this list is supposed to be available in Phase 1
local questsToBlacklistByPhase = {
    [1] = {}, -- Phase 1 - T4 (Kara, Gruul, Mag) (this is required for counting, but should stay empty)
    [2] = { -- Phase 2 - T5 (SSC, TK, Hyjal)
    },
    [3] = { -- Phase 3 - T6 (Hyjal, BT)
        [10445] = true,
        [10460] = true,
        [10461] = true,
        [10462] = true,
        [10463] = true,
        [10464] = true,
        [10465] = true,
        [10466] = true,
        [10467] = true,
        [10468] = true,
        [10469] = true,
        [10470] = true,
        [10471] = true,
        [10472] = true,
        [10473] = true,
        [10474] = true,
        [10475] = true,
        [10622] = true,
        [10628] = true,
        [10705] = true,
        [10706] = true,
        [10707] = true,
        [10708] = true,
        [10944] = true,
        [10946] = true,
        [10947] = true,
        [10948] = true,
        [10949] = true,
        [10957] = true,
        [10958] = true,
        [11103] = true,
        [11104] = true,
        [11105] = true,
        [11106] = true,
    },
    [4] = { -- Phase 3.5 - Zul'Aman
    },
    [5] = { -- Phase 4 - Sunwell, Isle of Quel'Danas
        [11481] = true,
        [11482] = true,
        [11488] = true,
        [11490] = true,
        [11492] = true,
        [11496] = true,
        [11499] = true,
        [11500] = true,
        [11513] = true,
        [11514] = true,
        [11515] = true,
        [11516] = true,
        [11517] = true,
        [11520] = true,
        [11521] = true,
        [11523] = true,
        [11524] = true,
        [11525] = true,
        [11526] = true,
        [11532] = true,
        [11533] = true,
        [11534] = true,
        [11535] = true,
        [11536] = true,
        [11537] = true,
        [11538] = true,
        [11539] = true,
        [11540] = true,
        [11541] = true,
        [11542] = true,
        [11543] = true,
        [11544] = true,
        [11545] = true,
        [11546] = true,
        [11547] = true,
        [11548] = true,
        [11549] = true,
        [11550] = true,
        [11554] = true,
        [11555] = true,
        [11556] = true,
        [11557] = true,
        [11877] = true,
        [11880] = true,
        [64997] = true,
        [64998] = true,
        [64999] = true,
    }
}

---@param questsToBlacklist table<QuestId, boolean>
---@param contentPhase number
---@return table<QuestId, boolean>
function ContentPhases.BlacklistTbcQuestsByPhase(questsToBlacklist, contentPhase)
    for phase = contentPhase + 1, #questsToBlacklistByPhase do
        for questId in pairs(questsToBlacklistByPhase[phase]) do
            questsToBlacklist[questId] = true
        end
    end

    return questsToBlacklist
end
