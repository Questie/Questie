---@class AchievementEventHandler
local AchievementEventHandler = QuestieLoader:CreateModule("AchievementEventHandler")

---@type AchievementTracking
local AchievementTracking = QuestieLoader:ImportModule("AchievementTracking")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")

-- Earned Achievement update. The game removes an earned achievement from its tracked list itself
function AchievementEventHandler.AchievementEarned()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[EVENT] ACHIEVEMENT_EARNED")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

-- Track/Untrack Achievement updates
---@param achievementId number?
function AchievementEventHandler.TrackedAchievementListChanged(achievementId)
    Questie.Debug(Questie.DEBUG_DEVELOP, "[EVENT] TRACKED_ACHIEVEMENT_LIST_CHANGED")

    if achievementId and achievementId ~= 0 and AchievementTracking.IsTracked(achievementId) then
        -- Forces a newly tracked achievement and the Achievements zone out of a minimized state
        Questie.db.char.collapsedQuests[achievementId] = nil
        Questie.db.char.collapsedZones["Achievements"] = nil
    end

    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

-- Timed based Achievement updates
-- TODO: Fired when a timed event for an achievement begins or ends. The achievement does not have to be actively tracked for this to trigger.
function AchievementEventHandler.TrackedAchievementUpdate()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[EVENT] TRACKED_ACHIEVEMENT_UPDATE")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

function AchievementEventHandler.CriteriaUpdate()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[EVENT] CRITERIA_UPDATE")

    if next(AchievementTracking.GetTrackedIds()) then
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end
end

-- Money based Achievement updates
function AchievementEventHandler.ChatMsgMoney()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[EVENT] CHAT_MSG_MONEY")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

-- Emote based Achievement updates
function AchievementEventHandler.ChatMsgTextEmote()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[EVENT] CHAT_MSG_TEXT_EMOTE")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

-- Player equipment changed based Achievement updates
function AchievementEventHandler.PlayerEquipmentChanged()
    Questie.Debug(Questie.DEBUG_DEVELOP, "[EVENT] PLAYER_EQUIPMENT_CHANGED")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end
