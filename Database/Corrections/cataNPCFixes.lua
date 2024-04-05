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
        [49456] = {
            [npcKeys.spawns] = {
                [zoneIDs.MOUNT_HYJAL] = {{42.7,28.8}}
            },
            [npcKeys.zoneID] = zoneIDs.MOUNT_HYJAL,
        }
    }
end
