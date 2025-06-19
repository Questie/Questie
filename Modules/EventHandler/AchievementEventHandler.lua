---@class AchievementEventHandler
local AchievementEventHandler = QuestieLoader:CreateModule("AchievementEventHandler")

---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")

-- Earned Achievement update
function AchievementEventHandler.AchievementEarned(achievementID)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] ACHIEVEMENT_EARNED")
    QuestieTracker:UntrackAchieveId(achievementID)
    QuestieTracker:UpdateAchieveTrackerCache(achievementID)

    if (not AchievementFrame) then
        AchievementFrame_LoadUI()
    end

    AchievementFrameAchievements_ForceUpdate()

    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

-- Track/Untrack Achievement updates
function AchievementEventHandler.TrackedAchievementListChanged(achievementID)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] TRACKED_ACHIEVEMENT_LIST_CHANGED")
    QuestieTracker:UpdateAchieveTrackerCache(achievementID)
end

-- Timed based Achievement updates
-- TODO: Fired when a timed event for an achievement begins or ends. The achievement does not have to be actively tracked for this to trigger.
function AchievementEventHandler.TrackedAchievementUpdate()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] TRACKED_ACHIEVEMENT_UPDATE")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

function AchievementEventHandler.CriteriaUpdate()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CRITERIA_UPDATE")

    if Questie.db.char.trackedAchievementIds and next(Questie.db.char.trackedAchievementIds) then
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end
end

-- Money based Achievement updates
function AchievementEventHandler.ChatMsgMoney()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CHAT_MSG_MONEY")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

-- Emote based Achievement updates
function AchievementEventHandler.ChatMsgTextEmote()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CHAT_MSG_TEXT_EMOTE")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

-- Player equipment changed based Achievement updates
function AchievementEventHandler.PlayerEquipmentChanged()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] PLAYER_EQUIPMENT_CHANGED")
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end
