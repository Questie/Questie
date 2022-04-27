---@class QuestEventHandler
local QuestEventHandler = QuestieLoader:CreateModule("QuestEventHandler")
local _QuestEventHandler = {}
local _QuestLogUpdateQueue = {} -- Helper module
local questLogUpdateQueue = {} -- The actual queue

---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieHash
local QuestieHash = QuestieLoader:ImportModule("QuestieHash")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")

local stringSub = string.sub
local tableRemove = table.remove

-- 3 * (Max possible number of quests in game quest log)
-- This is a safe value, even smaller would be enough. Too large won't effect performance
local MAX_QUEST_LOG_INDEX = 75

local QUEST_LOG_STATES = {
    QUEST_ACCEPTED = "QUEST_ACCEPTED",
    QUEST_TURNED_IN = "QUEST_TURNED_IN",
    QUEST_REMOVED = "QUEST_REMOVED",
    QUEST_ABANDONED = "QUEST_ABANDONED"
}

local eventFrame = CreateFrame("Frame", "QuestieQuestEventFrame")
local questLog = {}
local questLogUpdateQueueSize = 1
local skipNextUQLCEvent = false
local doFullQuestLogScan = false


--- Registers all events that are required for questing (accepting, removing, objective updates, ...)
function QuestEventHandler:RegisterEvents()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] RegisterEvents")
    eventFrame:RegisterEvent("QUEST_ACCEPTED")
    eventFrame:RegisterEvent("QUEST_TURNED_IN")
    eventFrame:RegisterEvent("QUEST_REMOVED")
    eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
    eventFrame:RegisterEvent("QUEST_WATCH_UPDATE")
    eventFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
    eventFrame:RegisterEvent("BANKFRAME_CLOSED")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    eventFrame:SetScript("OnEvent", _QuestEventHandler.OnEvent)

    _QuestEventHandler:InitQuestLog()
end

--- On Login mark all quests in the quest log with QUEST_ACCEPTED state
function _QuestEventHandler:InitQuestLog()
    for i = 1, MAX_QUEST_LOG_INDEX do
        local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(i)
        if (not title) then
            break -- We exceeded the valid quest log entries
        end
        if (not isHeader) then
            questLog[questId] = {
                state = QUEST_LOG_STATES.QUEST_ACCEPTED
            }
            QuestieLib:CacheItemNames(questId)
        end
    end

    QuestieHash:InitQuestLogHashes()
end

--- Fires when a quest is accepted in anyway.
---@param questLogIndex number
---@param questId number
function _QuestEventHandler:QuestAccepted(questLogIndex, questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_ACCEPTED", questLogIndex, questId)

    if questLog[questId] and questLog[questId].timer then
        -- We had a QUEST_REMOVED event which started this timer and now it was accepted again.
        -- So the quest was abandoned before, because QUEST_TURNED_IN would have run before QUEST_ACCEPTED.
        questLog[questId].timer:Cancel()
        questLog[questId].timer = nil
        _QuestEventHandler:MarkQuestAsAbandoned(questId)
    end

    questLog[questId] = {}
    skipNextUQLCEvent = true
    QuestieLib:CacheItemNames(questId)
    _QuestEventHandler:HandleQuestAccepted(questId)
end

---@param questId number
---@return boolean true @if the function was successful, false otherwise
function _QuestEventHandler:HandleQuestAccepted(questId)
    -- We first check the quest objectives and retry in the next QLU event if they are not correct yet
    local questObjectives = C_QuestLog.GetQuestObjectives(questId)
    for _, objective in pairs(questObjectives) do
        -- When the objective text is not cached yet it looks similar to " slain 0/1"
        if (not objective.text) or stringSub(objective.text, 1, 1) == " " then
            Questie:Debug(Questie.DEBUG_SPAM, "Objective texts are not correct yet")
            _QuestLogUpdateQueue:Insert(function()
                return _QuestEventHandler:HandleQuestAccepted(questId)
            end)

            -- No need to check other objectives since we have to check them all again already
            return false
        end
    end

    Questie:Debug(Questie.DEBUG_SPAM, "Objectives are correct. Calling accept logic. quest:", questId)
    questLog[questId].state = QUEST_LOG_STATES.QUEST_ACCEPTED
    QuestieHash:AddNewQuestHash(questId)
    QuestieQuest:AcceptQuest(questId)
    QuestieJourney:AcceptQuest(questId)
    QuestieAnnounce:AcceptedQuest(questId)

    return true
end

--- Fires when a quest is turned in
---@param questId number
---@param xpReward number
---@param moneyReward number
function _QuestEventHandler:QuestTurnedIn(questId, xpReward, moneyReward)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_TURNED_IN", xpReward, moneyReward, questId)

    if questLog[questId] and questLog[questId].timer then
        -- Cancel the timer so the quest is not marked as abandoned
        questLog[questId].timer:Cancel()
        questLog[questId].timer = nil
    end

    Questie:Debug(Questie.DEBUG_SPAM, "Quest:", questId, "was turned in and is completed")
    if questLog[questId] then
        -- There are quests which you just turn in so there is no preceding QUEST_ACCEPTED event and questLog[questId]
        -- is empty
        questLog[questId].state = QUEST_LOG_STATES.QUEST_TURNED_IN
    end

    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuest then
        -- Quests like "The Warsong Reports" have child quests which are just turned in. These child quests only
        -- fire QUEST_TURNED_IN + QUEST_LOG_UPDATE
        doFullQuestLogScan = true
    end

    skipNextUQLCEvent = true
    QuestieHash:RemoveQuestHash(questId)
    QuestieQuest:CompleteQuest(questId)
    QuestieJourney:CompleteQuest(questId)
    QuestieAnnounce:CompletedQuest(questId)
end

--- Fires when a quest is removed from the quest log. This includes turning it in and abandoning it.
---@param questId number
function _QuestEventHandler:QuestRemoved(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_REMOVED", questId)
    doFullQuestLogScan = false

    if (not questLog[questId]) then
        questLog[questId] = {}
    end

    -- QUEST_TURNED_IN was called before QUEST_REMOVED --> quest was turned in
    if questLog[questId].state == QUEST_LOG_STATES.QUEST_TURNED_IN then
        Questie:Debug(Questie.DEBUG_SPAM, "Quest:", questId, "was turned in before. Nothing do to.")
        questLog[questId] = nil
        return
    end

    -- QUEST_REMOVED can fire before QUEST_TURNED_IN. If QUEST_TURNED_IN is not called after X seconds the quest
    -- was abandoned
    questLog[questId] = {
        state = QUEST_LOG_STATES.QUEST_REMOVED,
        timer = C_Timer.NewTicker(1, function()
            _QuestEventHandler:MarkQuestAsAbandoned(questId)
        end, 1)
    }
    skipNextUQLCEvent = true
end

---@param questId number
function _QuestEventHandler:MarkQuestAsAbandoned(questId)
    if questLog[questId].state == QUEST_LOG_STATES.QUEST_REMOVED then
        Questie:Debug(Questie.DEBUG_SPAM, "Quest:", questId, "was abandoned")
        questLog[questId].state = QUEST_LOG_STATES.QUEST_ABANDONED

        QuestieHash:RemoveQuestHash(questId)
        QuestieQuest:AbandonedQuest(questId)
        QuestieJourney:AbandonQuest(questId)
        QuestieAnnounce:AbandonedQuest(questId)
        questLog[questId] = nil
    end
end

---Fires when the quest log changed in any way. This event fires very often!
function _QuestEventHandler:QuestLogUpdate()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_LOG_UPDATE")

    local continueQueuing = true
    -- Some of the other quest event didn't have the required information and ordered to wait for the next QLU.
    -- We are now calling the function which the event added.
    while continueQueuing and next(questLogUpdateQueue) do
        continueQueuing = _QuestLogUpdateQueue:GetFirst()()
    end

    if doFullQuestLogScan then
        _QuestEventHandler:UpdateAllQuests()
        doFullQuestLogScan = false
    end
end

--- Fires whenever a quest objective progressed
---@param questId number
function _QuestEventHandler:QuestWatchUpdate(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] QUEST_WATCH_UPDATE", questId)

    -- We do a full scan even though we have the questId because many QUEST_WATCH_UPDATE can fire before
    -- a QUEST_LOG_UPDATE. Also not every QUEST_WATCH_UPDATE gets a single QUEST_LOG_UPDATE and doing a full
    -- scan is less error prone
    doFullQuestLogScan = true
end

local _UnitQuestLogChangedCallback = function()
    -- We also check in here because UNIT_QUEST_LOG_CHANGED is fired before the relevant events
    -- (Accept, removed, ...)
    if (not skipNextUQLCEvent) then
        doFullQuestLogScan = true
    else
        doFullQuestLogScan = false
        skipNextUQLCEvent = false
        Questie:Debug(Questie.DEBUG_SPAM, "Skipping UnitQuestLogChanged")
    end
    return true
end

--- Fires when an objective changed in the quest log of the unitTarget. The required data is not available yet though
---@param unitTarget string
function _QuestEventHandler:UnitQuestLogChanged(unitTarget)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] UNIT_QUEST_LOG_CHANGED", unitTarget)

    -- There seem to be quests which don't trigger a QUEST_WATCH_UPDATE.
    -- We don't add a full check to the queue if skipNextUQLCEvent == true (from QUEST_WATCH_UPDATE or QUEST_TURNED_IN)
    if (not skipNextUQLCEvent) then
        doFullQuestLogScan = true
        _QuestLogUpdateQueue:Insert(_UnitQuestLogChangedCallback)
    else
        Questie:Debug(Questie.DEBUG_SPAM, "Skipping UnitQuestLogChanged")
    end
    skipNextUQLCEvent = false
end

--- Does a full scan of the quest log and updates every quest that is in the QUEST_ACCEPTED state and which hash changed
--- since the last check
function _QuestEventHandler:UpdateAllQuests()
    Questie:Debug(Questie.DEBUG_SPAM, "Running full questlog check")
    local questIdsToCheck = {}
    local questIdsToCheckSize = 1

    for questLogIndex = 1, MAX_QUEST_LOG_INDEX do
        local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(questLogIndex)
        if (not title) then
            -- We exceeded the valid quest log entries
            break
        end
        if (not isHeader) and questLog[questId] and questLog[questId].state == QUEST_LOG_STATES.QUEST_ACCEPTED then
            questIdsToCheck[questIdsToCheckSize] = questId
            questIdsToCheckSize = questIdsToCheckSize + 1
        end
    end

    local questIdsToUpdate = QuestieHash:CompareHashesOfQuestIdList(questIdsToCheck)

    if next(questIdsToUpdate) then
        for _, questId in pairs(questIdsToUpdate) do
            Questie:Debug(Questie.DEBUG_SPAM, "Quest:", questId, "will be updated")
            QuestieNameplate:UpdateNameplate()
            QuestieQuest:UpdateQuest(questId)
        end
    else
        Questie:Debug(Questie.DEBUG_SPAM, "Nothing to update")
    end
end

local lastTimeBankFrameClosedEvent = -1
--- Blizzard does not fire any event when quest items are stored in the bank or retrieved from it.
--- So we hook the BANKFRAME_CLOSED event which fires once or twice after closing the bank frame and do a full quest log check.
function _QuestEventHandler:BankFrameClosed()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] BANKFRAME_CLOSED")

    local now = GetTime()
    -- Don't do update if event fired twice
    if lastTimeBankFrameClosedEvent ~= now then
        lastTimeBankFrameClosedEvent = now
        _QuestEventHandler:UpdateAllQuests()
    end
end

function _QuestEventHandler:ReputationChange()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Quest Event] CHAT_MSG_COMBAT_FACTION_CHANGE")

    -- Reputational quest progression doesn't fire UNIT_QUEST_LOG_CHANGED event, only QUEST_LOG_UPDATE event.
    doFullQuestLogScan = true
end

--- Helper function to insert a callback to the questLogUpdateQueue and increase the index
function _QuestLogUpdateQueue:Insert(callback)
    questLogUpdateQueue[questLogUpdateQueueSize] = callback
    questLogUpdateQueueSize = questLogUpdateQueueSize + 1
end

--- Helper function to retrieve the first element of questLogUpdateQueue
---@return function @The callback that was inserted first into questLogUpdateQueue
function _QuestLogUpdateQueue:GetFirst()
    questLogUpdateQueueSize = questLogUpdateQueueSize - 1
    return tableRemove(questLogUpdateQueue, 1)
end

--- Is executed whenever an event is fired and triggers relevant event handling.
---@param event string
function _QuestEventHandler:OnEvent(event, ...)
    if event == "QUEST_ACCEPTED" then
        _QuestEventHandler:QuestAccepted(...)
    elseif event == "QUEST_TURNED_IN" then
        _QuestEventHandler:QuestTurnedIn(...)
    elseif event == "QUEST_REMOVED" then
        _QuestEventHandler:QuestRemoved(...)
    elseif event == "QUEST_LOG_UPDATE" then
        _QuestEventHandler:QuestLogUpdate()
    elseif event == "QUEST_WATCH_UPDATE" then
        _QuestEventHandler:QuestWatchUpdate(...)
    elseif event == "UNIT_QUEST_LOG_CHANGED" and select(1, ...) == "player" then
        _QuestEventHandler:UnitQuestLogChanged(...)
    elseif event == "BANKFRAME_CLOSED" then
        _QuestEventHandler:BankFrameClosed()
    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        _QuestEventHandler:ReputationChange()
    end
end
