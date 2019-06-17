function _hack_prime_log() -- this seems to make it update the data much quicker
  for i=1,GetNumQuestLogEntries()+1 do
    GetQuestLogTitle(i)
    QuestieQuest:GetRawLeaderBoardDetails(i)
  end
end

--- GLOBAL ---
--This is needed for functions around the addon, due to UnitLevel("player") not returning actual level PLAYER_LEVEL_UP unless this is used.
QuestieEventHandler = {}
qPlayerLevel = -1

__UPDATEFIX_IDX = 1; -- temporary bad fix

--- LOCAL ---
local QuestWatchTimers = {
    cancelTimer = nil,
    repeatTimer = nil
}
local lastState = {}
--False -> true -> nil
local playerEntered = false;


local questWatchFrames = {}
for i = 1, 35 do
    questWatchFrames[i] = CreateFrame("Frame", "QuestWatchFrame"..i)
    questWatchFrames[i].questLogIndex = i;
    questWatchFrames[i].refresh = false;
    questWatchFrames[i].accept = false;
    questWatchFrames[i].objectives = {}
    questWatchFrames[i]:RegisterEvent("QUEST_LOG_UPDATE")--, QUEST_LOG_UPDATE
    questWatchFrames[i]:SetScript("OnEvent", function(self, event, ...)
        if (event == "QUEST_LOG_UPDATE") then
            if(self.refresh) then
                --Get quest info
                local QuestInfo = QuestieQuest:GetRawLeaderBoardDetails(self.questLogIndex)

                --No need to run this unless we have to.
                if(Questie.db.global.debugEnabled) then
                    Questie:Debug(DEBUG_DEVELOP, event, "Updating index", self.questLogIndex, "Title:", QuestInfo.title, "Id:", QuestInfo.Id)
                    for index, objective in pairs(QuestInfo.Objectives) do
                        Questie:Debug(DEBUG_DEVELOP, "-------->", objective.description);
                    end
                end
                --Update the quest
                QuestieQuest:UpdateQuest(QuestInfo.Id);
                self.refresh = false;
            end
            if(self.accept) then
                local QuestInfo = QuestieQuest:GetRawLeaderBoardDetails(self.questLogIndex)
                Questie:Debug(DEBUG_DEVELOP, event, "Accepted quest", self.questLogIndex, "Title:", QuestInfo.title, "Id:", QuestInfo.Id)

                --Accept the quest.
                QuestieQuest:AcceptQuest(QuestInfo.Id)
                --Delay the update by 1 second to let everything propagate, should not be needed...
                C_Timer.After(1, function ()
                    Questie:Debug(DEBUG_DEVELOP, event, "Updated quest", self.questLogIndex, "Title:", QuestInfo.title, "Id:", QuestInfo.Id)
                    QuestieQuest:UpdateQuest(QuestInfo.Id)
                end)
                self.accept = false;
            end
        end
    end)
end

function QuestieEventHandler:PLAYER_ENTERING_WORLD()
    _hack_prime_log()
    qPlayerLevel = UnitLevel("player")
    QuestieQuest:Initialize()
    QuestieDB:Initialize()
    QuestieQuest:GetAllQuestIdsNoObjectives()
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests()
    QuestieNameplate:Initialize();
    Questie:Debug(DEBUG_ELEVATED, "PLAYER_ENTERED_WORLD")
    playerEntered = true


    --[[C_Timer.After(2, function ()
        Questie:Debug(DEBUG_ELEVATED, "Player entered world")
        QuestieQuest:GetAllQuestIds()
    end)

    C_Timer.After(5, function ()
        Questie:Debug(DEBUG_ELEVATED, "Player entered world (deferred update)")
        QuestieQuest:GetAllQuestIds()
    end)]]--

    -- periodically update the objectives of quests, temporary hold-over until we can properly fix the event based logic
    --[[Questie:ScheduleRepeatingTimer(function()
        if (GetNumQuestLogEntries()+1 == __UPDATEFIX_IDX) then
            __UPDATEFIX_IDX = 1;
        end

        title, level, _, isHeader, _, isComplete, _, _questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(__UPDATEFIX_IDX)
        if (not isHeader) and _questId ~= nil and _questId > 0 then
            QuestieQuest:UpdateQuest(_questId);
        end
        __UPDATEFIX_IDX = __UPDATEFIX_IDX + 1
    end, 3);]]--

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
function QuestieEventHandler:QUEST_ACCEPTED(QuestLogIndex, QuestId)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_ACCEPTED", "QLogIndex: "..QuestLogIndex,  "QuestID: "..QuestId);
    _hack_prime_log()

    --Update the information on next QUEST_LOG_UPDATE
    questWatchFrames[QuestLogIndex].accept = true;


    --[[C_Timer.After(2, function ()
        QuestieQuest:AcceptQuest(QuestId) -- is it safe to pass params to virtual functions like this?
    end)

    -- this needs to use a repeating timer maybe? Often times when quest is accepted, it has the same trouble as the other events
    C_Timer.After(5, function()
        QuestieQuest:UpdateQuest(QuestId);
    end)]]--

    -- Add quest accept journey note.
    local data = {};
    data.Event = "Quest";
    data.SubType = "Accept";
    data.Quest = QuestId;
    data.Level = UnitLevel("player");
    data.Timestamp = time();
    data.Party = {};

    if GetHomePartyInfo() then
        data.Party = {};
        local p = {};
        for i, v in pairs(GetHomePartyInfo()) do
            p.Name = v;
            p.Class,_ ,_ = UnitClass(v);
            p.Level = UnitLevel(v);
            table.insert(data.Party, p);
        end
    end
    
    table.insert(Questie.db.char.journey, data);

end

--Fires when a quest is removed from the questlog, this includes turning it in!
function QuestieEventHandler:QUEST_REMOVED(QuestId)
    _hack_prime_log()
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_REMOVED", QuestId);
    QuestieQuest:AbandonedQuest(QuestId)

    -- Abandon Quest added to Journey
    -- first check to see if the quest has been completed already or not
    local skipAbandon = false;
    for i in ipairs(Questie.db.char.journey) do

        local entry = Questie.db.char.journey[i];
        if entry.Event == "Quest" then
            if entry.Quest == QuestId then
                if entry.SubType == "Complete" then
                    skipAbandon = true;
                end
            end
        end
    end

    if not skipAbandon then
        local data = {};
        data.Event = "Quest";
        data.SubType = "Abandon";
        data.Quest = QuestId;
        data.Level = UnitLevel("player");
        data.Timestamp = time()
        data.Party = {};

        if GetHomePartyInfo() then
            local p = {};
            for i, v in pairs(GetHomePartyInfo()) do
                p.Name = v;
                p.Class, _, _ = UnitClass(v);
                p.Level = UnitLevel(v);
                table.insert(data.Party, p);
            end
        end
        
        table.insert(Questie.db.char.journey, data);
    end
end

--Fires when a quest is turned in.
function QuestieEventHandler:QUEST_TURNED_IN(questID, xpReward, moneyReward)
    _hack_prime_log()
        Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_TURNED_IN", questID, xpReward, moneyReward);
        QuestieQuest:CompleteQuest(questID)


        -- Complete Quest added to Journey
        local data = {};
        data.Event = "Quest";
        data.SubType = "Complete";
        data.Quest = questID;
        data.Level = UnitLevel("player");
        data.Timestamp = time();
        data.Party = {};

        if GetHomePartyInfo() then
            local p = {};
            for i, v in pairs(GetHomePartyInfo()) do
                p.Name = v;
                p.Class, _, _ = UnitClass(v);
                p.Level = UnitLevel(v);
                table.insert(data.Party, p);
            end
        end
        
        table.insert(Questie.db.char.journey, data);
end

function QuestieEventHandler:QUEST_LOG_UPDATE()
    Questie:Debug(DEBUG_DEVELOP, "QUEST_LOG_UPDATE")
    if(playerEntered)then
        Questie:Debug(DEBUG_DEVELOP, "---> Player entered world, START.")
        C_Timer.After(1, function ()
            Questie:Debug(DEBUG_DEVELOP, "---> Player entered world, DONE.")
            QuestieQuest:GetAllQuestIds()
        end)
        playerEntered = nil;
    end
end

function QuestieEventHandler:QUEST_WATCH_UPDATE(QuestLogIndex)
    Questie:Debug(DEBUG_INFO, "QUEST_WATCH_UPDATE", QuestLogIndex)
    --When a quest gets updated, wait until next QUEST_LOG_UPDATE before updating.
    questWatchFrames[QuestLogIndex].refresh = true


    --[[_hack_prime_log()
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
    end)]]--
end

function QuestieEventHandler:QUEST_LOG_CRITERIA_UPDATE(questID, specificTreeID, description, numFulfilled, numRequired)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_LOG_CRITERIA_UPDATE", questID, specificTreeID, description, numFulfilled, numRequired);
end

function QuestieEventHandler:CUSTOM_QUEST_COMPLETE()
    numEntries, numQuests = GetNumQuestLogEntries();
    --Questie:Debug(DEBUG_CRITICAL, "CUSTOM_QUEST_COMPLETE", "Quests: "..numQuests);
end

function QuestieEventHandler:PLAYER_LEVEL_UP(level, hitpoints, manapoints, talentpoints, ...)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: PLAYER_LEVEL_UP", level);
    qPlayerLevel = level;
    QuestieQuest:CalculateAvailableQuests();
    QuestieQuest:DrawAllAvailableQuests();

    -- Complete Quest added to Journey
    local data = {};
    data.Event = "Level";
    data.NewLevel = level;
    data.Timestamp = time();
    data.Party = {};

   if GetHomePartyInfo() then
        data.Party = {};
        local p = {};
        for i, v in pairs(GetHomePartyInfo()) do
            p.Name = v;
            p.Class, _, _ = UnitClass(v);
            p.Level = UnitLevel(v);
            table.insert(data.Party, p);
        end
    end 
    
    table.insert(Questie.db.char.journey, data);
end

--Old stuff

--This is used to see if they acually completed the quest or just fucking with us...
local NumberOfQuestInLog = -1

function QuestieEventHandler:QUEST_COMPLETE()
    numEntries, numQuests = GetNumQuestLogEntries();
    NumberOfQuestInLog = numQuests;
    --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_COMPLETE", "Quests: "..numQuests);
end

function QuestieEventHandler:QUEST_FINISHED()
    numEntries, numQuests = GetNumQuestLogEntries();
    if (NumberOfQuestInLog ~= numQuests) then
        --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_FINISHED", "CHANGE");
        NumberOfQuestInLog = -1
    end
    --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_FINISHED", "NO CHANGE");
end

function QuestieEventHandler:MODIFIER_STATE_CHANGED(key, down)
    if GameTooltip and GameTooltip:IsShown() and GameTooltip._rebuild then
        GameTooltip:Hide()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(GameTooltip._owner, "ANCHOR_CURSOR");
        GameTooltip:_rebuild() -- rebuild the tooltip
        GameTooltip:SetFrameStrata("TOOLTIP");
        GameTooltip:Show()
    end
end