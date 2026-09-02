-- Originally extracted verbatim from Database/Corrections/classicNPCFixes.lua
-- at Questie commit ba0f5acd63cbeb8e5affc5d1990b0d1ee276cd57.
-- Questie keeps this data because Darkmoon location selection is Questie runtime policy.

---@class QuestieClassicPolicyCorrections
local QuestieClassicPolicyCorrections = QuestieLoader:CreateModule("QuestieClassicPolicyCorrections")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

---Updates the NPC spawns to be either in Elwynn Forest or Mulgore
---@param isInMulgore boolean
---@return table<number, any>
function QuestieClassicPolicyCorrections:LoadDarkmoonFixes(isInMulgore)
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    if isInMulgore then
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
                [npcKeys.spawns] = {[zoneIDs.MULGORE] = {{36.17,35.15}}}, -- might be 37.2,37.7
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
                [npcKeys.spawns] = {[zoneIDs.ELWYNN_FOREST] = {{43.61,70.84}}}, -- might be 41.5,68.9
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