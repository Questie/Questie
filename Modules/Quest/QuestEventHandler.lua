---@class QuestEventHandler
local QuestEventHandler = QuestieLoader:CreateModule("QuestEventHandler")
local _QuestEventHandler = {}

local eventFrame = CreateFrame("Frame", "QuestieQuestEventFrame", UIParent)

local questLog = {}
local QUEST_LOG_STATES = {
    QUEST_ACCEPTED = "QUEST_ACCEPTED",
    QUEST_TURNED_IN = "QUEST_TURNED_IN",
    QUEST_REMOVED = "QUEST_REMOVED",
    QUEST_ABANDONED = "QUEST_ABANDONED"
}
local playerJustLoggedIn = false
local qluTaskQueue = {}


-- This is used just for debugging purpose
local questLogEventTrace = {}
function QuestEventHandler:GetEventTrace()
    return questLogEventTrace
end

-- TODO: Move PLAYER_LOGIN handling somewhere else and call the code in here from that handler
function _QuestEventHandler:PlayerLogin()
    print("[Event] PLAYER_LOGIN")

    playerJustLoggedIn = true
end

--- Fires when a quest is accepted in anyway.
---@param questLogIndex number
---@param questId number
function _QuestEventHandler:QuestAccepted(questLogIndex, questId)
    print("[Quest Event] QUEST_ACCEPTED", questId)

    if questLog[questId] and questLog[questId].timer then
        -- We had a QUEST_REMOVED event which started this timer and now it was accepted again.
        -- So the quest was abandoned before, because QUEST_TURNED_IN would have run before QUEST_ACCEPTED.
        questLog[questId].timer:Cancel()
        questLog[questId].timer = nil
        _QuestEventHandler:MarkQuestAsAbandoned(questId)
    end

    if (not questLogEventTrace[questId]) then
        questLogEventTrace[questId] = {}
    end

    questLog[questId] = {
        state = QUEST_LOG_STATES.QUEST_ACCEPTED
    }
    table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_ACCEPTED)
    _QuestEventHandler:AcceptQuest(questId)
end

function _QuestEventHandler:AcceptQuest(questId)
    local questObjectivesCorrect = _QuestEventHandler:AreQuestObjectivesCorrect(questId)
    if questObjectivesCorrect then
        print("Objectives are correct")
        --TODO: Call quest accepted logic
    end
end

---@return boolean true if the quest has no objectives or all are loaded correctly, false otherwise
function _QuestEventHandler:AreQuestObjectivesCorrect(questId)
    local questObjectives = C_QuestLog.GetQuestObjectives(questId)
    for _, objective in pairs(questObjectives) do
        print("Objective type:", objective.type)
        print("Objective text:", objective.text)

        -- When the objective text is not cached yet it looks similar to " slain 0/1"
        if (not objective.text) or string.sub(objective.text, 1, 1) == " " then
            print("Objective text is not correct yet")
            table.insert(qluTaskQueue, function()
                _QuestEventHandler:AcceptQuest(questId)
            end)
            -- No need to check other objectives since we have to check them all again already
            return false
        end
    end

    return true
end

--- Fires when a quest is turned in
---@param questId number
---@param xpReward number
---@param moneyReward number
function _QuestEventHandler:QuestTurnedIn(questId, xpReward, moneyReward)
    print("[Quest Event] QUEST_TURNED_IN", questId)
    table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_TURNED_IN)

    if questLog[questId] and questLog[questId].timer then
        -- Cancel the timer so the quest is not marked as abandoned
        questLog[questId].timer:Cancel()
        questLog[questId].timer = nil
    end

    print("Quest", questId, "was turned in and is completed")
    questLog[questId].state = QUEST_LOG_STATES.QUEST_TURNED_IN

    -- TODO: Call quest completed logic
end

--- Fires when a quest is removed from the quest log. This includes turning it in and abandoning it.
---@param questId number
function _QuestEventHandler:QuestRemoved(questId)
    print("[Quest Event] QUEST_REMOVED", questId)
    table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_REMOVED)

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
end

function _QuestEventHandler:MarkQuestAsAbandoned(questId)
    if questLog[questId].state == QUEST_LOG_STATES.QUEST_REMOVED then
        print("Quest", questId, "was abandoned")
        questLog[questId].state = QUEST_LOG_STATES.QUEST_ABANDONED
        table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_ABANDONED)

        -- TODO: Call quest abandoned logic
    end
end

---Fires when the quest log changed in any way. This event fires very often!
function _QuestEventHandler:QuestLogUpdate()
    print("[Quest Event] QUEST_LOG_UPDATE")
    if playerJustLoggedIn then
        _QuestEventHandler:InitQuestLog()
    end

    -- Some of the other quest event didn't have the required information and ordered to wait for the next QLU.
    -- We are now calling the function which the event added.
    if next(qluTaskQueue) then
        table.remove(qluTaskQueue, 1)()
    end
end

local initTries = 0
-- On Login mark all quests in the quest log with QUEST_ACCEPTED state
function _QuestEventHandler:InitQuestLog()
    local numEntries, _ = GetNumQuestLogEntries()

    -- Without cached information the first QLU does not have any quest log entries. After 5 tries we continue
    -- and disable playerJustLoggedIn
    if numEntries == 0 and initTries < 5 then
        initTries = initTries + 1
        return
    end

    for i = 1, numEntries do
        local _, _, _, isHeader, _, _, _, questId, _ = GetQuestLogTitle(i)
        if (not isHeader) then
            questLog[questId] = {
                state = QUEST_LOG_STATES.QUEST_ACCEPTED
            }

            if (not questLogEventTrace[questId]) then
                questLogEventTrace[questId] = {}
            end

            table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_ACCEPTED)
        end
    end

    playerJustLoggedIn = false
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
    end
end

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("QUEST_TURNED_IN")
eventFrame:RegisterEvent("QUEST_REMOVED")
eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
eventFrame:SetScript("OnEvent", _QuestEventHandler.OnEvent)
