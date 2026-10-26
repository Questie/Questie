---@class TrackerSuperTrack
local TrackerSuperTrack = QuestieLoader:CreateModule("TrackerSuperTrack")

---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

---Follows super tracking changes made outside Questie, e.g. on the Blizzard map or quest log.
---Changes Questie made itself already match its focus and are skipped.
function TrackerSuperTrack.OnSuperTrackingChanged()
    local questId = QuestieCompat.GetSuperTrackedQuestID()
    local focus = Questie.db.char.TrackerFocus

    if questId then
        if focus == questId then
            return
        end
        if TrackerUtils:FocusQuest(questId) then
            QuestieQuest:ToggleNotes(false)
        elseif type(focus) == "number" then
            -- Questie can not focus the new quest, so drop the old quest focus instead of showing it as focused.
            TrackerUtils:UnFocus()
            QuestieQuest:ToggleNotes(true)
        else
            return
        end
    else
        -- An objective focus has no super tracking equivalent, so only a quest focus follows the clear.
        if type(focus) ~= "number" then
            return
        end
        TrackerUtils:UnFocus()
        QuestieQuest:ToggleNotes(true)
    end

    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end
