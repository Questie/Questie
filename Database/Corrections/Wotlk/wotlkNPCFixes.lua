---@class QuestieWotlkNpcFixes
local QuestieWotlkNpcFixes = QuestieLoader:CreateModule("QuestieWotlkNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function QuestieWotlkNpcFixes:Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs
    local npcFlags = QuestieDB.npcFlags

    return {
        [24440] = {
            [npcKeys.spawns] = {
                [zoneIDs.HOWLING_FJORD] = {{30.2,26.4},{30.4,27},{30.6,24},{30.8,23.4},{30.8,26.6},{30.8,28.2},{30.8,28.6},{31,24.6},{31,26.4},{31.2,31},{31.6,27.2},{31.6,27.6},{31.8,26},},
            },
            [npcKeys.zoneID] = zoneIDs.HOWLING_FJORD,
        },
    }
end