---@class MopNpcFixes
local MopNpcFixes = QuestieLoader:CreateModule("MopNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function MopNpcFixes.Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
    }
end
