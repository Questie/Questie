---@class DarkmoonFaireFixes
local DarkmoonFaireFixes = QuestieLoader:CreateModule("DarkmoonFaireFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

local npcKeys = QuestieDB.npcKeys
local zoneIDs = ZoneDB.zoneIDs

---@type table<DMFLocation, table<NpcId, table>>
local npcFixesByLocation = {
    MULGORE = {
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
    },
    ELWYNN_FOREST = {
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
    },
    TEROKKAR_FOREST = {
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
    },
}

---Returns NPC spawn corrections for a detected location, or nil when the location has no correction data.
---@param eventLocation DMFLocation
---@return table<NpcId, table>?
function DarkmoonFaireFixes.GetNpcFixes(eventLocation)
    return npcFixesByLocation[eventLocation]
end

return DarkmoonFaireFixes
