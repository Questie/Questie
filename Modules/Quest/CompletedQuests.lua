---@class CompletedQuests
local CompletedQuests = QuestieLoader:CreateModule("CompletedQuests")

---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

local UPDATE_DELAY = 1 -- seconds
local updateTimer

---@param questId QuestId
---@return boolean
local function _IsInQuestLog(questId)
    -- Questie doesn't have quests that are still loading or unknown to QuestieDB. The game no longer has a removed quest, of
    -- which Questie doesn't know yet whether it was turned in or abandoned.
    return ActiveQuests.Get(questId) ~= nil or C_QuestLog.IsOnQuest(questId)
end

---Adds the quests the game completed since Questie last read its list. The game completes some quests together with a
---turned in one, e.g. the other versions of "Call of Earth" (1517), and some without any turn-in.
---
---Quests are never removed, because the game's list can be empty for a moment, e.g. on logout.
function CompletedQuests.Update()
    local completedQuests = Questie.db.char.complete
    local hasNewQuest = false
    for questId in pairs(QuestieCompat.GetQuestsCompleted()) do
        -- false is a quest the player can do again, although the game counts it as completed, see QuestLifecycle
        if completedQuests[questId] == nil and (not _IsInQuestLog(questId)) then
            completedQuests[questId] = true
            hasNewQuest = true
            -- Calculating the available quests leaves the icons of completed ones to the turn-in, which this one didn't have
            AvailableQuests.RemoveQuest(questId)
        end
    end

    if hasNewQuest then
        AvailableQuests.CalculateAndDrawAll()
    end
end

---Updates once the game has caught up with a turn-in. It usually adds the quest with QUEST_REMOVED, a fraction of a second
---after QUEST_TURNED_IN, so each call starts the wait again.
function CompletedQuests.ScheduleUpdate()
    if updateTimer then
        updateTimer:Cancel()
    end
    updateTimer = C_Timer.NewTimer(UPDATE_DELAY, CompletedQuests.Update)
end
