-- Originally extracted verbatim from Database/Corrections/tbcNPCFixes.lua and
-- Database/Corrections/tbcQuestFixes.lua at Questie commit ba0f5acd63cbeb8e5affc5d1990b0d1ee276cd57.
-- Questie keeps this data because Darkmoon location selection and Content Phase prerequisites are Questie runtime policy.

---@class QuestieTBCPolicyCorrections
local QuestieTBCPolicyCorrections = QuestieLoader:CreateModule("QuestieTBCPolicyCorrections")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---Updates the NPC spawns to be in Elwynn Forest, Mulgore, or Terokkar Forest
---@param isInMulgore boolean
---@param isInTerokkar boolean
---@return table<number, any>
function QuestieTBCPolicyCorrections:LoadDarkmoonFixes(isInMulgore, isInTerokkar)
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    if isInTerokkar then
        return {
            [14828] = { -- Gelvas Grimegate <Darkmoon Faire Ticket Redemption>
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{34.68,34.36}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14829] = { -- Yebb Neblegear
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{34.33,35.73}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14832] = { -- Kerri Hicks <The Strongest Woman Alive!>
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{34.84,35.15}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14833] = { -- Chronos <He Who Never Forgets!>
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{33.82,35.96}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14841] = { -- Rinling
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{34.04,34.82}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
            [14871] = { -- Morja
                [npcKeys.spawns] = {[zoneIDs.TEROKKAR_FOREST] = {{33.67,35.93}}},
                [npcKeys.zoneID] = zoneIDs.TEROKKAR_FOREST,
            },
        }
    elseif isInMulgore then
        return {
            [14828] = { -- Gelvas Grimegate <Darkmoon Faire Ticket Redemption>
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{37.24,37.67}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14829] = { -- Yebb Neblegear
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{37.47,39.56}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14832] = { -- Kerri Hicks <The Strongest Woman Alive!>
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{37.82,39.81}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14833] = { -- Chronos <He Who Never Forgets!> (might be 37.2,37.7)
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{36.17,35.15}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14841] = { -- Rinling
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{37.09,37.17}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
            [14871] = { -- Morja
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{35.92,35.27}}},
                [npcKeys.zoneID] = zoneIDs.MULGORE,
            },
        }
    else
        return {
            [14828] = { -- Gelvas Grimegate <Darkmoon Faire Ticket Redemption>
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{41.5,68.87}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14829] = { -- Yebb Neblegear
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{40.17,69.53}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14832] = { -- Kerri Hicks <The Strongest Woman Alive!>
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{40.49,69.93}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14833] = { -- Chronos <He Who Never Forgets!> (might be 41.5,68.9)
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{43.61,70.84}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14841] = { -- Rinling
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{41.71,70.72}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
            [14871] = { -- Morja
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{43.34,70.28}}},
                [npcKeys.zoneID] = zoneIDs.ELWYNN_FOREST,
            },
        }
    end
end

-- Use ContentPhases to apply corrections specific to the current content phase
function QuestieTBCPolicyCorrections:LoadContentPhaseFixes()
    local questKeys = QuestieDB.questKeys
    return {
        [10944] = { -- The Secret Compromised
            [questKeys.preQuestGroup] = Expansions.Current == Expansions.Tbc and ContentPhases.activePhases.TBC < 3 and {10901,11052} or {}, -- SSC + TK attunements removed in P3
            [questKeys.preQuestSingle] = Expansions.Current == Expansions.Tbc and ContentPhases.activePhases.TBC < 3 and {} or {10708,11052}, -- SSC + TK attunements removed in P3
        },
        [11007] = { -- Kael'thas and the Verdant Sphere
            [questKeys.preQuestSingle] = Expansions.Current == Expansions.Tbc and ContentPhases.activePhases.TBC < 3 and {10888} or {}, -- SSC + TK attunements removed in P3
        },
    }
end
