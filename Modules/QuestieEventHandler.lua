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
    QuestieJourney:AbandonQuest(questId)
end

--Fires when a quest is removed from the questlog, this includes turning it in!
function QuestieEventHandler:QUEST_REMOVED(QuestId)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_REMOVED", QuestId);
    _Hack_prime_log()

    QuestieQuest:AbandonedQuest(QuestId)
    QuestieJourney:AbandonQuest(QuestId)
end

--Fires when a quest is turned in.
function QuestieEventHandler:QUEST_TURNED_IN(questID, xpReward, moneyReward)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_TURNED_IN", questID, xpReward, moneyReward)
    _Hack_prime_log()

    QuestieQuest:CompleteQuest(questID)
    QuestieJourney:CompleteQuest(questID)
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