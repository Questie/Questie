function PLAYER_ENTERING_WORLD()
    C_Timer.After(3, function ()
	  Questie:Debug(DEBUG_ELEVATED, "Player entered world")
      QuestieQuest:Initialize()
	  QuestieDB:Initialize()
      QuestieQuest:GetAllQuestIds()
	  QuestieQuest:CalculateAvailableQuests()
	  QuestieQuest:DrawAllAvailableQuests()
	end)



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
  C_Timer.After(2, function ()
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_ACCEPTED", "QLogIndex: "..QuestLogIndex,  "QuestID: "..QuestId);
    QuestieQuest:AcceptQuest(QuestId) -- is it safe to pass params to virtual functions like this?
  end)
end

--Fires when a quest is removed from the questlog, this includes turning it in!
function QUEST_REMOVED(Event, QuestId)
  C_Timer.After(2, function ()
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_REMOVED", QuestId);
    QuestieQuest:AbandonedQuest(QuestId)
  end)
end

--Fires when a quest is turned in.
function QUEST_TURNED_IN(Event, questID, xpReward, moneyReward)
  C_Timer.After(2, function ()
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_TURNED_IN", questID, xpReward, moneyReward);
    QuestieQuest:CompleteQuest(questID)
  end)
end

function QUEST_WATCH_UPDATE(Event, QuestLogIndex)
  C_Timer.After(2, function ()
    title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(QuestLogIndex)
    Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_WATCH_UPDATE", "QLogIndex: "..QuestLogIndex,  "QuestID: "..questId);
    QuestieQuest:UpdateQuest(questId);
  end)
end

function QUEST_LOG_CRITERIA_UPDATE(Event, questID, specificTreeID, description, numFulfilled, numRequired)
  Questie:Debug(DEBUG_DEVELOP, "EVENT: QUEST_LOG_CRITERIA_UPDATE", questID, specificTreeID, description, numFulfilled, numRequired);
end

function CUSTOM_QUEST_COMPLETE()
  numEntries, numQuests = GetNumQuestLogEntries();
  --Questie:Debug(DEBUG_CRITICAL, "CUSTOM_QUEST_COMPLETE", "Quests: "..numQuests);
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
