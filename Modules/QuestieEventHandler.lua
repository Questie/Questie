local function _Hack_prime_log() -- this seems to make it update the data much quicker
  for i=1,GetNumQuestLogEntries()+1 do
    GetQuestLogTitle(i)
    QuestieQuest:GetRawLeaderBoardDetails(i)
  end
end

--- GLOBAL ---
QuestieEventHandler = {}
__UPDATEFIX_IDX = 1; -- temporary bad fix

--- LOCAL ---
--False -> true -> nil
local playerEntered = false;
local hasFirstQLU = false;
local runQLU = false

function QuestieEventHandler:PLAYER_ENTERING_WORLD()
    C_Timer.After(1, function()
        QuestieDB:Initialize()
    end)
    C_Timer.After(4, function()
        -- We want the framerate to be HIGH!!!
        QuestieMap:InitializeQueue();
        _Hack_prime_log()
        QuestiePlayer:Initialize();
        QuestieQuest:Initialize()
        QuestieQuest:GetAllQuestIdsNoObjectives()
        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()
        QuestieNameplate:Initialize();
        Questie:Debug(DEBUG_ELEVATED, "PLAYER_ENTERED_WORLD")
        playerEntered = true
        -- manually fire QLU since enter has been delayed past the first QLU
        if hasFirstQLU then
            QuestieEventHandler:QUEST_LOG_UPDATE()
        end
    end)
end

--Fires when a quest is accepted in anyway.
function QuestieEventHandler:QUEST_ACCEPTED(questLogIndex, questId)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_ACCEPTED", "QLogIndex: "..questLogIndex,  "QuestID: "..questId);
    _Hack_prime_log()

    QuestieQuest:AcceptQuest(questId)
    QuestieJourney:AcceptQuest(questId)
end

--Fires when a quest is removed from the questlog, this includes turning it in!
function QuestieEventHandler:QUEST_REMOVED(QuestId)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_REMOVED", QuestId);
    _Hack_prime_log()

    QuestieQuest:AbandonedQuest(QuestId)
    QuestieJourney:AbandonQuest(QuestId)
end

--For debugging!
completeData = {};

--Fires when a quest is turned in.
function QuestieEventHandler:QUEST_TURNED_IN(questID, xpReward, moneyReward)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_TURNED_IN", questID, xpReward, moneyReward)
    _Hack_prime_log()


    -- Test code!
    completeData = {};

    local questLogIndex = GetQuestLogIndexByID(questID);
    local _, _, _, _, _, isComplete, _, _, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(questLogIndex)
    completeData["GetQuestLogTitle"] = isComplete;
    completeData["IsQuestComplete"] = IsQuestComplete(questID);
    local objectiveData = C_QuestLog.GetQuestObjectives(questID);
    completeData["CQuestLogGetQuestObjectives"] = {}
    for qIndex, objective in pairs(objectiveData) do
        completeData["CQuestLogGetQuestObjectives"][qIndex] = objective;
    end
    completeData["CanAbandonQuest"] = not CanAbandonQuest(questID); -- Reverse, we want to know if we CAN'T abandon to see if it is done (keep it in line with isComplete)
    completeData["IsUnitOnQuest"] = not IsUnitOnQuest(questLogIndex, "player"); --Reverse, we want to keep true / false the same if isComplete is true, this should be true.
    completeData["IsUnitOnQuestByQuestID"] = not IsUnitOnQuestByQuestID(questID, "player"); --Reverse, we want to keep true / false the same if isComplete is true, this should be true.
    --What is this? HaveQuestData(questId);
    --We should also use IsQuestCompletable
    if(HaveQuestData) then
        Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "----EVENT: QUEST_TURNED_IN HaveQuestData");
        Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "value:" , tostring(HaveQuestData(questID)));
        Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "----");
    end

    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "EVENT: QUEST_TURNED_IN - API responses:");
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "GetQuestLogTitle:", tostring(completeData["GetQuestLogTitle"]));
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "IsQuestComplete:", tostring(completeData["IsQuestComplete"]));
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "reversed CanAbandonQuest:", tostring(completeData["CanAbandonQuest"]));
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "reversed IsUnitOnQuest", tostring(completeData["IsUnitOnQuest"]));
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "reversed IsUnitOnQuestByQuestID  ", tostring(completeData["IsUnitOnQuestByQuestID"]));
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "----C_QuestLog.GetQuestObjectives")
    for qIndex, objective in pairs(completeData["CQuestLogGetQuestObjectives"]) do
        if(objective) then
            Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "-- i:", qIndex, "finished:", tostring(objective.finished));
        end
    end
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "----")
    local total = 0;
    local complete = 0;
    for api, value in pairs(completeData) do
        if(type(value) ~= "table") then
            if(value) then
                complete = complete + 1;
            end
            total = total + 1;
        end
    end
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "The functions show complete/total :", complete, "/", total, " resolve isComplete:", tostring((total-complete) < complete));
    Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "IsQuestFlaggedCompleted:", tostring(IsQuestFlaggedCompleted(questID)));
    -- These functions should be more afterwards.
    --completeData["IsQuestFlaggedCompleted"] = IsQuestFlaggedCompleted(questID);

    --end of test code

    --This is all test code! We should probably not use a timer!
    --As with everything else this should probably happen on the next QLU
    --The timer is very expensive, but complete quest is a function not used often so i think i would be fine.
    local timer = nil;
    timer = C_Timer.NewTicker(0.5, function() 
        local isComp = IsQuestFlaggedCompleted(questID);
        Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "IsQuestFlaggedCompleted:", isComp, "HaveQuestData:", tostring(HaveQuestData(questID)));
        if(isComp) then
            QuestieQuest:CompleteQuest(questID)
            QuestieJourney:CompleteQuest(questID)
            timer:Cancel();
        end
    end);
end

function QuestieEventHandler:QUEST_LOG_UPDATE()
    Questie:Debug(DEBUG_DEVELOP, "QUEST_LOG_UPDATE")
    hasFirstQLU = true
    if playerEntered then
        Questie:Debug(DEBUG_DEVELOP, "---> Player entered world, START.")
        C_Timer.After(1, function ()
            Questie:Debug(DEBUG_DEVELOP, "---> Player entered world, DONE.")
            QuestieQuest:GetAllQuestIds()
            QuestieTracker:Initialize()
            QuestieTracker:Update()
        end)
        playerEntered = nil;
    end

    if runQLU then
        QuestieQuest:CompareQuestHashes()
        runQLU = false
    end
end

function QuestieEventHandler:UNIT_QUEST_LOG_CHANGED(unitTarget)
    if unitTarget == "player" then
        Questie:Debug(DEBUG_DEVELOP, "UNIT_QUEST_LOG_CHANGED: player")

        runQLU = true
    end
end

function QuestieEventHandler:PLAYER_LEVEL_UP(level, hitpoints, manapoints, talentpoints, ...)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: PLAYER_LEVEL_UP", level);

    QuestiePlayer:SetPlayerLevel(level);

    -- deferred update (possible desync fix?)
    C_Timer.After(3, function()
        QuestiePlayer:SetPlayerLevel(level);

        QuestieQuest:CalculateAvailableQuests();
        QuestieQuest:DrawAllAvailableQuests();
    end)
    QuestieJourney:PlayerLevelUp(level);
end

function QuestieEventHandler:MODIFIER_STATE_CHANGED(key, down)
    if GameTooltip and GameTooltip:IsShown() and GameTooltip._Rebuild then
        GameTooltip:Hide()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(GameTooltip._owner, "ANCHOR_CURSOR");
        GameTooltip:_Rebuild() -- rebuild the tooltip
        GameTooltip:SetFrameStrata("TOOLTIP");
        GameTooltip:Show()
    end
end

-- Fired when some chat messages about skills are displayed
function QuestieEventHandler:CHAT_MSG_SKILL()
    Questie:Debug(DEBUG_DEVELOP, "CHAT_MSG_SKILL")
    QuestieProfessions:Update()
end

local numOfMembers = -1;
function QuestieEventHandler:GROUP_ROSTER_UPDATE()
    local currentMembers = GetNumGroupMembers();
    -- Only want to do logic when number increases, not decreases.
    if(numOfMembers < currentMembers) then
        -- Tell comms to send information to members.
        Questie:SendMessage("QC_ID_BROADCAST_FULL_QUESTLIST");
        numOfMembers = currentMembers;
    else
        -- We do however always want the local to be the current number to allow up and down.
        numOfMembers = currentMembers;
    end
end


--Old unused code

--This is used to see if they acually completed the quest or just fucking with us...
local NumberOfQuestInLog = -1

function QuestieEventHandler:QUEST_COMPLETE()
    local numEntries, numQuests = GetNumQuestLogEntries();
    NumberOfQuestInLog = numQuests;
    --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_COMPLETE", "Quests: "..numQuests);
end

function QuestieEventHandler:QUEST_FINISHED()
    local numEntries, numQuests = GetNumQuestLogEntries();
    if (NumberOfQuestInLog ~= numQuests) then
        --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_FINISHED", "CHANGE");
        NumberOfQuestInLog = -1
    end
    --Questie:Debug(DEBUG_CRITICAL, "EVENT: QUEST_FINISHED", "NO CHANGE");
end

function QuestieEventHandler:QUEST_LOG_CRITERIA_UPDATE(questID, specificTreeID, description, numFulfilled, numRequired)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_LOG_CRITERIA_UPDATE", questID, specificTreeID, description, numFulfilled, numRequired);
end

function QuestieEventHandler:CUSTOM_QUEST_COMPLETE()
    local numEntries, numQuests = GetNumQuestLogEntries();
    --Questie:Debug(DEBUG_CRITICAL, "CUSTOM_QUEST_COMPLETE", "Quests: "..numQuests);
end

-- DO NOT PUT CODE UNDER HERE!!!!!