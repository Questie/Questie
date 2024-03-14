---@class CataNpcFixes
local CataNpcFixes = QuestieLoader:CreateModule("CataNpcFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function CataNpcFixes.Load()
    local npcKeys = QuestieDB.npcKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {}
end
