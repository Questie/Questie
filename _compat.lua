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

