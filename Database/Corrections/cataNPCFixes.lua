---@class CataNpcFixes
local CataNpcFixes = QuestieLoader:CreateModule("CataNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function CataNpcFixes.Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [49871] = {
            [npcKeys.name] = "Blackrock Worg",
            [npcKeys.minLevel] = 1,
            [npcKeys.maxLevel] = 59,
            [npcKeys.zoneID] = 12,
            [npcKeys.spawns] = {
                [zoneIDs.ELWYNN_FOREST] = {{46, 42.6},{46.2, 41},{46.2, 42},{46.4, 38},{46.4, 38.6},{46.6, 40.6},{47, 38},{47.4, 38.8},{47.4, 40},{47.6, 40},{48.6, 37.6},},
                --[6170] = {{24, 58},{24.8, 61.6},{25.2, 37.6},{25.6, 36.8},{27.2, 37.4},{27.6, 59.4},{28.4, 49.8},{28.8, 36.6},{28.8, 45.2},{28.8, 49.2},{28.8, 53.6},{29.2, 46},{29.8, 45},{30.8, 37.6},{30.8, 44.2},{31.2, 47.4},{31.4, 47.8},{31.6, 46.6},{31.6, 48.6},{31.8, 47.8},{33, 40.2},{33.8, 39},{33.8, 40.2},{34.6, 37.2},{45.6, 57.8},},
            },
            [npcKeys.friendlyToFaction] = nil,
            [npcKeys.questStarts] = nil,
            [npcKeys.questEnds] = nil,
        },
    }
end
