-- The active quest is the quest the game super tracks: the one highlighted in the Quest Log.
---@class TrackerActiveQuest
local TrackerActiveQuest = QuestieLoader:CreateModule("TrackerActiveQuest")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

-- Group key used in place of a zone name. Collapsing this group is saved under this key like any zone.
TrackerActiveQuest.GROUP_KEY = "QuestieActiveQuest"

local tinsert = table.insert

local UPDATE_DELAY = 0.2 -- seconds

---@return boolean available True when the game client has an active quest, i.e. can super track quests
function TrackerActiveQuest.IsAvailable()
    return C_SuperTrack ~= nil and C_SuperTrack.GetSuperTrackedQuestID ~= nil and C_SuperTrack.SetSuperTrackedQuestID ~= nil
end

---@return QuestId? questId The active quest, nil when there is none
function TrackerActiveQuest.GetActiveQuestId()
    if not TrackerActiveQuest.IsAvailable() then
        return nil
    end

    local questId = C_SuperTrack.GetSuperTrackedQuestID()
    if questId and questId > 0 then
        return questId
    end

    return nil
end

---Makes the quest the active quest like a click in the quest log does, or clears the active quest when it already is.
---@param questId QuestId
function TrackerActiveQuest.ToggleQuest(questId)
    if not TrackerActiveQuest.IsAvailable() then
        return
    end

    if TrackerActiveQuest.GetActiveQuestId() == questId then
        C_SuperTrack.SetSuperTrackedQuestID(0)
    else
        C_SuperTrack.SetSuperTrackedQuestID(questId)
    end

    -- The game reports the change with SUPER_TRACKING_CHANGED, but not every client has that event
    TrackerActiveQuest.OnActiveQuestChanged()
end

---@param questDetails table<QuestId, QuestSortDetails> The quests the tracker lists
---@return QuestId? questId The active quest when the tracker lists it and shows it on top
function TrackerActiveQuest.GetQuestIdOnTop(questDetails)
    if not Questie.db.profile.trackerShowActiveQuestOnTop then
        return nil
    end

    local activeQuestId = TrackerActiveQuest.GetActiveQuestId()
    if activeQuestId and questDetails[activeQuestId] then
        return activeQuestId
    end

    return nil
end

---Removes the quest shown on top from the sorted quests, unless it is also kept in its zone.
---@param sortedQuestIds QuestId[]
---@param questIdOnTop QuestId?
---@return QuestId[] questIds The quests listed below the active quest group
function TrackerActiveQuest.GetQuestIdsBelowTop(sortedQuestIds, questIdOnTop)
    if (not questIdOnTop) or Questie.db.profile.trackerKeepActiveQuestInZone then
        return sortedQuestIds
    end

    local questIds = {}
    for _, questId in ipairs(sortedQuestIds) do
        if questId ~= questIdOnTop then
            tinsert(questIds, questId)
        end
    end

    return questIds
end

---Redraws the tracker after the active quest changed, when the tracker shows it on top.
function TrackerActiveQuest.OnActiveQuestChanged()
    if not Questie.db.profile.trackerShowActiveQuestOnTop then
        return
    end

    -- Delayed past QuestieTracker:Update's 0.1s throttle. An update that ran right before the change
    -- would otherwise drop this one and leave the previous active quest on top.
    C_Timer.After(UPDATE_DELAY, function()
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end)
end

---Follows changes of the active quest in the game, on clients that can super track quests.
function TrackerActiveQuest.Initialize()
    if not TrackerActiveQuest.IsAvailable() then
        return
    end

    local eventFrame = CreateFrame("Frame")
    -- Not every client knows this event, registering an unknown one raises an error
    if pcall(eventFrame.RegisterEvent, eventFrame, "SUPER_TRACKING_CHANGED") then
        eventFrame:SetScript("OnEvent", TrackerActiveQuest.OnActiveQuestChanged)
    end
end
