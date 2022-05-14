---@class IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:CreateModule("IsleOfQuelDanas")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")



IsleOfQuelDanas.MAX_ISLE_OF_QUEL_DANAS_PHASES = 9
local phases = {
    [1] = l10n("Phase 1 - Sun's Reach Sanctum"),
    [2] = l10n("Phase 2 - Activating the Sunwell Portal"),
    [3] = l10n("Phase 2.1 - Sun's Reach Armory"),
    [4] = l10n("Phase 3 - Rebuilding the Anvil and Forge"),
    [5] = l10n("Phase 3.1 - Sun's Reach Harbor"),
    [6] = l10n("Phase 4 - Creating the Alchemy Lab"),
    [7] = l10n("Phase 4.1 - Building the Monument to the Fallen"),
    [8] = l10n("Phase 4.2 - Sun's Reach"),
    [9] = l10n("Phase 5"),
}

IsleOfQuelDanas.GetPhases = function()
    return phases
end

---@param questId number
---@return boolean
function IsleOfQuelDanas:CheckForActivePhase(questId)
    local isleQuests = IsleOfQuelDanas.quests
    if isleQuests[1][questId] and isleQuests[Questie.db.global.isleOfQuelDanasPhase][questId] then
        -- The accepted quest is one from the Isle Of Quel'Danas
        local phaseToSwitchTo = 1
        for i= 2, #isleQuests do
            if (not isleQuests[i][questId]) then
                -- This is the phase that unlocked this quest
                phaseToSwitchTo = i
                break
            end
        end

        Questie:Print(l10n("You picked up a quest from '%s'. Automatically switching to this phase...", phases[phaseToSwitchTo]))
        Questie.db.global.isleOfQuelDanasPhase = phaseToSwitchTo
        return true
    end
    return false
end

-- These quests are the blacklisted ones for each phase
IsleOfQuelDanas.quests = {
    [1] = { -- Phase 1
        [11513] = true,
        [11514] = true,
        [11517] = true,
        [11520] = true,
        [11521] = true,
        [11523] = true,
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
    },
    [2] = { -- Phase 2
        -- temp quests from previous phase
        [11496] = true,
        [11514] = true,
        [11524] = true,
        --
        [11520] = true,
        [11521] = true,
        [11533] = true,
        [11535] = true,
        [11536] = true,
        [11537] = true,
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
    },
    [3] = { -- Phase 2.1 Shatt Portal done
        -- temp quests from previous phases
        [11496] = true,
        [11513] = true,
        [11524] = true,
        --
        [11520] = true,
        [11521] = true,
        [11533] = true,
        [11535] = true,
        [11536] = true,
        [11537] = true,
        [11539] = true,
        [11540] = true,
        [11541] = true,
        [11542] = true,
        [11543] = true,
        [11544] = true,
        [11545] = true,
        [11546] = true,
        [11548] = true,
        [11549] = true,
    },
    [4] = { -- Phase 3
        -- temp quests from previous phases
        [11496] = true,
        [11513] = true,
        [11524] = true,
        [11532] = true,
        [11538] = true,
        --
        [11520] = true,
        [11521] = true,
        [11536] = true,
        [11540] = true,
        [11541] = true,
        [11543] = true,
        [11544] = true,
        [11545] = true,
        [11546] = true,
        [11548] = true,
        [11549] = true,
    },
    [5] = { -- Phase 3.1 Anvil and Forge done
        -- temp quests from previous phases
        [11496] = true,
        [11513] = true,
        [11524] = true,
        [11532] = true,
        [11535] = true,
        [11538] = true,
        --
        [11520] = true,
        [11521] = true,
        [11536] = true,
        [11540] = true,
        [11541] = true,
        [11543] = true,
        [11544] = true,
        [11545] = true,
        [11546] = true,
        [11548] = true,
        [11549] = true,
    },
    [6] = { -- Phase 4
        -- temp quests from previous phases
        [11496] = true,
        [11513] = true,
        [11524] = true,
        [11532] = true,
        [11535] = true,
        [11538] = true,
        [11539] = true,
        [11542] = true,
        --
        [11521] = true,
        [11546] = true,
        [11548] = true,
    },
    [7] = { -- Phase 4.1 - Alchemy Lab done
        -- temp quests from previous phases
        [11496] = true,
        [11513] = true,
        [11520] = true,
        [11524] = true,
        [11532] = true,
        [11535] = true,
        [11538] = true,
        [11539] = true,
        [11542] = true,
        --
        [11548] = true,
    },
    [8] = { -- Phase 4.2 - Monument of the Fallen done
        -- temp quests from previous phases
        [11496] = true,
        [11513] = true,
        [11524] = true,
        [11532] = true,
        [11535] = true,
        [11538] = true,
        [11539] = true,
        [11542] = true,
        [11545] = true,
        --
        [11521] = true,
        [11546] = true,
    },
    [9] = { -- Phase 5 - Both buildings done
        -- temp quests from previous phases
        [11496] = true,
        [11513] = true,
        [11520] = true,
        [11524] = true,
        [11532] = true,
        [11535] = true,
        [11538] = true,
        [11539] = true,
        [11542] = true,
        [11545] = true,
        --
    }
}