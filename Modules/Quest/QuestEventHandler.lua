---@class QuestEventHandler
local QuestEventHandler = QuestieLoader:CreateModule("QuestEventHandler")
local _QuestEventHandler = {}

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


local eventFrame = CreateFrame("Frame", "QuestieQuestEventFrame")
local questLog = {}
local QUEST_LOG_STATES = {
    QUEST_ACCEPTED = "QUEST_ACCEPTED",
    QUEST_TURNED_IN = "QUEST_TURNED_IN",
    QUEST_REMOVED = "QUEST_REMOVED",
    QUEST_ABANDONED = "QUEST_ABANDONED"
}
local skipNextUQLCEvent = false;
local questLogUpdateQueue = {}


-- TODO: Move PLAYER_LOGIN handling somewhere else and call the code in here from that handler
function _QuestEventHandler:PlayerLogin()
    print("[Event] PLAYER_LOGIN")

    table.insert(questLogUpdateQueue, function()
        return _QuestEventHandler:InitQuestLog()
    end)
end

local initTries = 0
--- On Login mark all quests in the quest log with QUEST_ACCEPTED state
---@return boolean true if the function was successful, false otherwise
function _QuestEventHandler:InitQuestLog()
    local numEntries, numQuests = GetNumQuestLogEntries()
    print("numEntries:", numEntries, "numQuests:", numQuests)

    -- Without cached information the first QLU does not have any quest log entries. After 5 tries we stop trying
    if numEntries == 0 and initTries < 5 then
        initTries = initTries + 1
        table.insert(questLogUpdateQueue, function()
            return _QuestEventHandler:InitQuestLog()
        end)
        return false
    end

    for i = 1, numEntries + numQuests do
        local title, _, _, isHeader, _, _, _, questId, _ = GetQuestLogTitle(i)
        if (not title) then
            -- We exceeded the valid quest log entries
            break
        end
        if (not isHeader) then
            questLog[questId] = {
                state = QUEST_LOG_STATES.QUEST_ACCEPTED
            }
        end
    end

    return true
end

--- Fires when a quest is accepted in anyway.
---@param questLogIndex number
---@param questId number
function _QuestEventHandler:QuestAccepted(questLogIndex, questId)
    print("[Quest Event] QUEST_ACCEPTED", questLogIndex, questId)

    if questLog[questId] and questLog[questId].timer then
        -- We had a QUEST_REMOVED event which started this timer and now it was accepted again.
        -- So the quest was abandoned before, because QUEST_TURNED_IN would have run before QUEST_ACCEPTED.
        questLog[questId].timer:Cancel()
        questLog[questId].timer = nil
        _QuestEventHandler:MarkQuestAsAbandoned(questId)
    end

    questLog[questId] = {
        state = QUEST_LOG_STATES.QUEST_ACCEPTED
    }
    skipNextUQLCEvent = true
    QuestieLib:CacheItemNames(questId)
    _QuestEventHandler:AcceptQuest(questId)
end

---@param questId number
---@return boolean true if the function was successful, false otherwise
function _QuestEventHandler:AcceptQuest(questId)
    -- We first check the quest objectives and retry in the next QLU event if they are not correct yet
    local questObjectives = C_QuestLog.GetQuestObjectives(questId)
    for _, objective in pairs(questObjectives) do
        -- When the objective text is not cached yet it looks similar to " slain 0/1"
        if (not objective.text) or string.sub(objective.text, 1, 1) == " " then
            print("Objective texts are not correct yet")
            table.insert(questLogUpdateQueue, function()
                return _QuestEventHandler:AcceptQuest(questId)
            end)
            -- No need to check other objectives since we have to check them all again already
            return false
        end
    end

    print("Objectives are correct. Calling accept logic")
    QuestieQuest:AcceptQuest(questId)
    QuestieJourney:AcceptQuest(questId)

    return true
end

--- Fires when a quest is turned in
---@param questId number
---@param xpReward number
---@param moneyReward number
function _QuestEventHandler:QuestTurnedIn(questId, xpReward, moneyReward)
    print("[Quest Event] QUEST_TURNED_IN", xpReward, moneyReward, questId)

    if questLog[questId] and questLog[questId].timer then
        -- Cancel the timer so the quest is not marked as abandoned
        questLog[questId].timer:Cancel()
        questLog[questId].timer = nil
    end

    print("Quest", questId, "was turned in and is completed")
    if questLog[questId] then
        -- There are quests which you just turn in so there is no preceding QUEST_ACCEPTED event and questLog[questId]
        -- is empty
        questLog[questId].state = QUEST_LOG_STATES.QUEST_TURNED_IN
    end

    skipNextUQLCEvent = true
    QuestieQuest:CompleteQuest(questId)
    QuestieJourney:CompleteQuest(questId)
end

--- Fires when a quest is removed from the quest log. This includes turning it in and abandoning it.
---@param questId number
function _QuestEventHandler:QuestRemoved(questId)
    print("[Quest Event] QUEST_REMOVED", questId)

    if (not questLog[questId]) then
        print("questLog[questId] was nil")
        questLog[questId] = {}
    end

    -- QUEST_TURNED_IN was called before QUEST_REMOVED --> quest was turned in
    if questLog[questId].state == QUEST_LOG_STATES.QUEST_TURNED_IN then
        print("Quest", questId, "was turned in before. Nothing do to.")
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
        print("Quest", questId, "was abandoned")
        questLog[questId].state = QUEST_LOG_STATES.QUEST_ABANDONED

        QuestieQuest:AbandonedQuest(questId)
        QuestieJourney:AbandonQuest(questId)
    end
end

---Fires when the quest log changed in any way. This event fires very often!
function _QuestEventHandler:QuestLogUpdate()
    print("[Quest Event] QUEST_LOG_UPDATE")

    local continueQueuing = true
    -- Some of the other quest event didn't have the required information and ordered to wait for the next QLU.
    -- We are now calling the function which the event added.
    while continueQueuing and next(questLogUpdateQueue) do
        continueQueuing = table.remove(questLogUpdateQueue, 1)()
    end
end

--- Fires whenever a quest objective progressed
---@param questId number
function _QuestEventHandler:QuestWatchUpdate(questId)
    print("[Quest Event] QUEST_WATCH_UPDATE", questId)

    table.insert(questLogUpdateQueue, function()
        return _QuestEventHandler:UpdateQuest(questId)
    end)
    skipNextUQLCEvent = true
end

----- Fires when an objective changed in the quest log of the unitTarget. The required data is not available yet though
-----@param unitTarget string
function _QuestEventHandler:UnitQuestLogChanged(unitTarget)
    print("[Quest Event] UNIT_QUEST_LOG_CHANGED", unitTarget)

    if unitTarget ~= "player" then
        -- The quest log of some other unit changed, which we don't care about
        return
    end

    -- There seem to be quests which don't trigger a QUEST_WATCH_UPDATE.
    -- We don't add a full check to the queue if skipNextUQLCEvent == true (from QUEST_WATCH_UPDATE or QUEST_TURNED_IN)
    if (not skipNextUQLCEvent) then
        table.insert(questLogUpdateQueue, function()
            -- We also check in here because UNIT_QUEST_LOG_CHANGED is fired before the relevant events
            -- (Accept, removed, ...)
            if (not skipNextUQLCEvent) then
                _QuestEventHandler:UpdateQuests()
            else
                print("Skipping full check")
            end
            skipNextUQLCEvent = false
        end)
    else
        print("Skipping full check")
    end
    skipNextUQLCEvent = false
end

function _QuestEventHandler:UpdateQuests()
    local questIdsToCheck = {}

    local numEntries, numQuests = GetNumQuestLogEntries()
    for questLogIndex = 1, numEntries + numQuests do
        local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(questLogIndex)
        if (not title) then
            -- We exceeded the valid quest log entries
            break
        end
        if (not isHeader) and questLog[questId] and questLog[questId].state == QUEST_LOG_STATES.QUEST_ACCEPTED then
            table.insert(questIdsToCheck, questId)
        end
    end

    local questIdToUpdate = QuestieHash:CompareHashesOfQuestIdList(questIdsToCheck)

    if next(questIdToUpdate) then
        for _, questId in pairs(questIdToUpdate) do
            print("questIdToUpdate:", questId)
            QuestieNameplate:UpdateNameplate()
            QuestieQuest:UpdateQuest(questId)
        end
    else
        print("Nothing to update")
    end
end

---@param questId number
---@return boolean true if the function was successful, false otherwise
function _QuestEventHandler:UpdateQuest(questId)
    local hashChanged = QuestieHash:CompareQuestHash(questId)
    print("hashChanged:", hashChanged)

    if hashChanged then
        QuestieNameplate:UpdateNameplate()
        QuestieQuest:UpdateQuest(questId)
        return true
    else
        table.insert(questLogUpdateQueue, function()
            return _QuestEventHandler:UpdateQuest(questId)
        end)
        return false
    end
end

local isFirstBankFrameClosedEvent = true
--- Blizzard does not fire any event when quest items are stored in the bank or retrieved from it.
--- So we hook the BANKFRAME_CLOSED event which fires twice after closing the bank frame and do a full quest log check.
function _QuestEventHandler:BankFrameClosed()
    print("[Event] BANKFRAME_CLOSED")

    if isFirstBankFrameClosedEvent then
        _QuestEventHandler:UpdateQuests()
        isFirstBankFrameClosedEvent = false
    else
        isFirstBankFrameClosedEvent = true
    end
end

--- Is executed whenever an event is fired and triggers relevant event handling.
---@param event string
function _QuestEventHandler:OnEvent(event, ...)
    if event == "PLAYER_LOGIN" then
        _QuestEventHandler:PlayerLogin(...)
    elseif event == "QUEST_ACCEPTED" then
        _QuestEventHandler:QuestAccepted(...)
    elseif event == "QUEST_TURNED_IN" then
        _QuestEventHandler:QuestTurnedIn(...)
    elseif event == "QUEST_REMOVED" then
        _QuestEventHandler:QuestRemoved(...)
    elseif event == "QUEST_LOG_UPDATE" then
        _QuestEventHandler:QuestLogUpdate()
    elseif event == "QUEST_WATCH_UPDATE" then
        _QuestEventHandler:QuestWatchUpdate(...)
    elseif event == "UNIT_QUEST_LOG_CHANGED" then
        _QuestEventHandler:UnitQuestLogChanged(...)
    elseif event == "BANKFRAME_CLOSED" then
        _QuestEventHandler:BankFrameClosed()
    end
end

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("QUEST_TURNED_IN")
eventFrame:RegisterEvent("QUEST_REMOVED")
eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
eventFrame:RegisterEvent("QUEST_WATCH_UPDATE")
eventFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
eventFrame:RegisterEvent("BANKFRAME_CLOSED")
eventFrame:SetScript("OnEvent", _QuestEventHandler.OnEvent)
