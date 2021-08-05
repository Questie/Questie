---@class QuestEventHandler
local QuestEventHandler = QuestieLoader:CreateModule("QuestEventHandler")
local _QuestEventHandler = {}

local eventFrame = CreateFrame("Frame", "QuestieQuestEventFrame", UIParent)

local questLog = {}
local QUEST_LOG_STATES = {
    QUEST_ACCEPTED = "QUEST_ACCEPTED",
    QUEST_TURNED_IN = "QUEST_TURNED_IN",
    QUEST_REMOVED = "QUEST_REMOVED",
    QUEST_COMPLETED = "QUEST_COMPLETED",
    QUEST_ABANDONED = "QUEST_ABANDONED"
}

-- This is used just for debugging purpose
local questLogEventTrace = {}
function QuestEventHandler:GetEventTrace()
    return questLogEventTrace
end

-- TODO: Move PLAYER_LOGIN handling somewhere else and call the code in here from that handler
function _QuestEventHandler:PlayerLogin()
    print("[Event] PLAYER_LOGIN")

    -- On Login mark all quests in the quest log with QUEST_ACCEPTED state
    local numEntries, _ = GetNumQuestLogEntries()
    for i=1, numEntries do
        local _, _, _, isHeader, _, _, _, questId, _ = GetQuestLogTitle(i)
        if (not isHeader) then
            questLog[questId] = QUEST_LOG_STATES.QUEST_ACCEPTED

            if (not questLogEventTrace[questId]) then
                questLogEventTrace[questId] = {}
            end

            table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_ACCEPTED)
        end
    end
end

--- Fires when a quest is accepted in anyway.
---@param questLogIndex number
---@param questId number
function _QuestEventHandler:QuestAccepted(questLogIndex, questId)
    print("[Quest Event] QUEST_ACCEPTED", questId)

    if (not questLogEventTrace[questId]) then
        questLogEventTrace[questId] = {}
    end

    questLog[questId] = QUEST_LOG_STATES.QUEST_ACCEPTED
    table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_ACCEPTED)

    --TODO: Call quest accepted logic
end

--- Fires when a quest is turned in
---@param questId number
---@param xpReward number
---@param moneyReward number
function _QuestEventHandler:QuestTurnedIn(questId, xpReward, moneyReward)
    print("[Quest Event] QUEST_TURNED_IN", questId)
    table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_TURNED_IN)

    -- QUEST_REMOVED fired before QUEST_TURNED_IN --> quest was still turned in
    if questLog[questId] == QUEST_LOG_STATES.QUEST_REMOVED then
        print("Quest", questId, "was turned in. Marking it as completed")
        questLog[questId] = QUEST_LOG_STATES.QUEST_COMPLETED
        table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_COMPLETED)

        -- TODO: Call quest completed logic
        return
    end

    questLog[questId] = QUEST_LOG_STATES.QUEST_TURNED_IN
end

--- Fires when a quest is removed from the quest log. This includes turning it in and abandoning it.
---@param questId number
function _QuestEventHandler:QuestRemoved(questId)
    print("[Quest Event] QUEST_REMOVED", questId)
    table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_REMOVED)

    -- QUEST_TURNED_IN was called before QUEST_REMOVED --> quest was turned in
    if questLog[questId] == QUEST_LOG_STATES.QUEST_TURNED_IN then
        print("Quest", questId, "was turned in. Marking it as completed")
        questLog[questId] = QUEST_LOG_STATES.QUEST_COMPLETED
        table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_COMPLETED)

        -- TODO: Call quest completed logic
        return
    end

    -- QUEST_REMOVED can fire before QUEST_TURNED_IN. If QUEST_TURNED_IN is not called after X seconds the quest
    -- was abandoned
    C_Timer.After(1, function()
        if questLog[questId] == QUEST_LOG_STATES.QUEST_REMOVED then
            print("Quest", questId, "was removed before. Marking it as abandoned")
            questLog[questId] = QUEST_LOG_STATES.QUEST_ABANDONED
            table.insert(questLogEventTrace[questId], QUEST_LOG_STATES.QUEST_ABANDONED)

            -- TODO: Call quest abandoned logic
        end
    end)

    questLog[questId] = QUEST_LOG_STATES.QUEST_REMOVED
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
    end
end

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("QUEST_TURNED_IN")
eventFrame:RegisterEvent("QUEST_REMOVED")
eventFrame:SetScript("OnEvent", _QuestEventHandler.OnEvent)
