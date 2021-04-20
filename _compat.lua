-- how you gonna do me like that blizzard
local lastTime = GetTime()
local lastTable = nil
if not (IsQuestFlaggedCompleted or C_QuestLog.IsQuestFlaggedCompleted) then
    IsQuestFlaggedCompleted = function(id)
        local now = GetTime()
        if (not lastTable) or now - lastTime > 1 then
            lastTime = now
            lastTable = GetQuestsCompleted()
        end
        return lastTable[id]
    end
end
