-- The intent of this file is to provide a temporary bridge between newer blizzard API functions and older ones.
-- I have made everything backwards compatible where possible, but some functions need an additional wrapper to work on classic as well as the new TBC api.
-- When/if classic moves to the new API we should remove this and refactor the code that uses these functions.

-- this is the replacement for GetQuestLogTitle. Because the blizzard API returns a table with named keys now, it's not as simple as changing the function name.
function __REFACTORME_GetInfoProxy(logId)
    local data = C_QuestLog.GetInfo(logId)
    if data then
        return data.title, data.level, data.suggestedGroup, data.isHeader, data.isCollapsed, data.isComplete, data.frequency, data.questID, data.startEvent, data.displayQuestID, data.isOnMap
    end
end

-- the old DB function (GetQuestsCompleted) returns values in the format {[questid]=true, [questid]=true, ...}
-- the new function returns {questid, questid, questid}
function __REFACTORME_GetAllCompletedQuestIDsProxy()
    local completeTable = {}
    for _, id in pairs(C_QuestLog.GetAllCompletedQuestIDs()) do
        completeTable[id] = true
    end
    return completeTable
end

-- this one has the same problem, different return value formatting
function __REFACTORME_GetQuestTagInfoProxy(id)
    local info = C_QuestLog.GetQuestTagInfo(id)
    if info then
        return info.tagID, info.tagName, info.worldQuestType, info.quality, info.isElite, info.tradeskillLineID, info.displayExpiration
    end
end

_Questie_IsTBC = true -- REFACTOR THIS!
_QUESTIE_TBC_BETA_BUILD_VERSION_SHORTHAND = "|cFFFF0000(A4)|r"
