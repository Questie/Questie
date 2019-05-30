function _hack_prime_log() -- this seems to make it update the data much quicker
  for i=1,GetNumQuestLogEntries()+1 do
    GetQuestLogTitle(i)
	QuestieQuest:GetRawLeaderBoardDetails(i)
  end
end

--- GLOBAL ---
--This is needed for functions around the addon, due to UnitLevel("player") not returning actual level PLAYER_LEVEL_UP unless this is used.
qPlayerLevel = -1

local QuestWatchTimers = {
    cancelTimer = nil,
    repeatTimer = nil
}
local lastState = {}

__UPDATEFIX_IDX = 1; -- temporary bad fix

function PLAYER_ENTERING_WORLD()
    _hack_prime_log()
    qPlayerLevel = UnitLevel("player")
    QuestieQuest:Initialize()
    QuestieDB:Initialize()
    QuestieQuest:GetAllQuestIdsNoObjectives()
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests()

    C_Timer.After(2, function ()
        Questie:Debug(DEBUG_ELEVATED, "Player entered world")
        QuestieQuest:GetAllQuestIds()
    end)

    C_Timer.After(5, function ()
        Questie:Debug(DEBUG_ELEVATED, "Player entered world (deferred update)")
        QuestieQuest:GetAllQuestIds()
    end)

    -- periodically update the objectives of quests, temporary hold-over until we can properly fix the event based logic
    Questie:ScheduleRepeatingTimer(function()
        if (GetNumQuestLogEntries()+1 == __UPDATEFIX_IDX) then
            __UPDATEFIX_IDX = 1;
        end

        title, level, _, isHeader, _, isComplete, _, _questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(__UPDATEFIX_IDX)
        if (not isHeader) and _questId ~= nil and _questId > 0 then
            QuestieQuest:UpdateQuest(_questId);
        end
        __UPDATEFIX_IDX = __UPDATEFIX_IDX + 1
    end, 3);

    --local Note = QuestieFramePool:GetFrame();
    --THIS WILL BE MOVED!!!
    --Note.data.QuestID = 1337
    --Note.data.data..NoteType = NoteType --MiniMapNote or WorldMapNote, Will be moved!
    --Note.data.IconType = type;
    --Note.data.questHash = questHash;
    --Note.data.objectiveid = objectiveid;
    --HBDPins:AddMinimapIconWorld(Questie, Note, 0, x, y, true)
    --HBDPins:AddWorldMapIconWorld(Questie, Note, 0, x, y, HBD_PINS_WORLDMAP_SHOW_WORLD)
end

--Fires when a quest is accepted in anyway.
function QUEST_ACCEPTED(Event, QuestLogIndex, QuestId)
    _hack_prime_log()
    C_Timer.After(2, function ()
        Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_ACCEPTED", "QLogIndex: "..QuestLogIndex,  "QuestID: "..QuestId);
        QuestieQuest:AcceptQuest(QuestId) -- is it safe to pass params to virtual functions like this?
    end)

    -- this needs to use a repeating timer maybe? Often times when quest is accepted, it has the same trouble as the other events
    C_Timer.After(5, function()
        QuestieQuest:UpdateQuest(QuestId);
    end)

end

--Fires when a quest is removed from the questlog, this includes turning it in!
function QUEST_REMOVED(Event, QuestId)
    _hack_prime_log()
    C_Timer.After(1, function ()
        Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_REMOVED", QuestId);
        QuestieQuest:AbandonedQuest(QuestId)
    end)
end

--Fires when a quest is turned in.
function QUEST_TURNED_IN(Event, questID, xpReward, moneyReward)
    _hack_prime_log()
    C_Timer.After(1, function ()
        Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_TURNED_IN", questID, xpReward, moneyReward);
        QuestieQuest:CompleteQuest(questID)
    end)
end

function QUEST_WATCH_UPDATE(Event, QuestLogIndex)
    _hack_prime_log()
    title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(QuestLogIndex)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_WATCH_UPDATE", "QLogIndex: "..QuestLogIndex, "QuestID: "..questId);

    --If a timer exists from previous upda
    if(QuestWatchTimers.cancelTimer) then
        Questie:CancelTimer(QuestWatchTimers.cancelTimer)
        QuestWatchTimers.cancelTimer = nil;
        Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler] Cancel timer exists, canceled!")
    end
    if(QuestWatchTimers.repeatTimer) then
        Questie:CancelTimer(QuestWatchTimers.repeatTimer)
        QuestWatchTimers.repeatTimer = nil;
        Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler] Repeat timer exists, canceled!")
    end
    local _QuestLogIndexFinal = tonumber(QuestLogIndex)
    local _questIdFinal = tonumber(questId);
    QuestWatchTimers.cancelTimer = Questie:ScheduleTimer(function()
            if QuestWatchTimers.repeatTimer ~= nil then
            Questie:CancelTimer(QuestWatchTimers.repeatTimer)
            QuestWatchTimers.repeatTimer = nil;
            QuestWatchTimers.cancelTimer = nil;
            Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler] Repeat timer took to long, cancel it!")

            --if _questIdFinal ~= nil and _questIdFinal > 0 then
            --  QuestieQuest:UpdateQuest(_questIdFinal);
            --end
        end
        -- always double-update
        if _questIdFinal ~= nil and _questIdFinal > 0 then
            QuestieQuest:UpdateQuest(_questIdFinal);
        end
    end, 6)

    C_Timer.After(1, function() -- start repeating after 1 sec, first update was incorrectly being detected as a change because this bug is super annoying
            QuestWatchTimers.repeatTimer = Questie:ScheduleRepeatingTimer(function()
            local QuestInfo = QuestieQuest:GetRawLeaderBoardDetails(_QuestLogIndexFinal)
            if(lastState[QuestInfo.Id] == nil or lastState[QuestInfo.Id].compareString ~= QuestInfo.compareString) then
                Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler] QUEST_WATCH_UPDATE found a change!")
                lastState[QuestInfo.Id] = QuestInfo;
                Questie:CancelTimer(QuestWatchTimers.repeatTimer)
                Questie:CancelTimer(QuestWatchTimers.cancelTimer)
                QuestWatchTimers.cancelTimer = nil;
                QuestWatchTimers.repeatTimer = nil;
                QuestieQuest:UpdateQuest(QuestInfo.Id);
            end
        end, 1)
    end)
end

function QUEST_LOG_CRITERIA_UPDATE(Event, questID, specificTreeID, description, numFulfilled, numRequired)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_LOG_CRITERIA_UPDATE", questID, specificTreeID, description, numFulfilled, numRequired);
end

function CUSTOM_QUEST_COMPLETE()
    numEntries, numQuests = GetNumQuestLogEntries();
    --Questie:Debug(DEBUG_CRITICAL, "CUSTOM_QUEST_COMPLETE", "Quests: "..numQuests);
end

function PLAYER_LEVEL_UP(event, level, hitpoints, manapoints, talentpoints, ...)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: PLAYER_LEVEL_UP", level);
    qPlayerLevel = level;
    QuestieQuest:CalculateAvailableQuests();
    QuestieQuest:DrawAllAvailableQuests();
end

--Old stuff

--This is used to see if they acually completed the quest or just fucking with us...
local NumberOfQuestInLog = -1

function QUEST_COMPLETE()
    numEntries, numQuests = GetNumQuestLogEntries();
    NumberOfQuestInLog = numQuests;
    --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_COMPLETE", "Quests: "..numQuests);
end

function QUEST_FINISHED()
    numEntries, numQuests = GetNumQuestLogEntries();
    if (NumberOfQuestInLog ~= numQuests) then
        --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_FINISHED", "CHANGE");
        NumberOfQuestInLog = -1
    end
    --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_FINISHED", "NO CHANGE");
end
