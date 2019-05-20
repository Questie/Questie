QuestieQuest = {...}
local _QuestieQuest = {...}


qAvailableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD

qCurrentQuestlog = {} --Gets populated by QuestieQuest:GetAllQuestIds(), this is either an object to the quest in question, or the ID if the object doesn't exist.

function QuestieQuest:Initialize()
  Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Getting all completed quests")
  GetQuestsCompleted(Questie.db.char.complete)
end

-- some plebs dont have beta, i need diz
function LOGONDEBUG_ADDQUEST(QuestId)
  --qCurrentQuestlog[QuestId] = QuestieDB:GetQuest(QuestId);
  Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]: Adding the quest ", QuestId, qCurrentQuestlog[QuestId])
  QuestieQuest:AcceptQuest(QuestId);
  --QuestieQuest:TrackQuest(QuestId)
end

function LOGONDEBUG_REMOVEQUEST(QuestId)
  QuestieQuest:AbandonedQuest(QuestId);
  Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]: Removed the quest ", QuestId, qCurrentQuestlog[QuestId])
end

--Use the category order to draw the quests and trust the database order.
--/dump QuestieQuest:GetAllQuestObjectives(24475)
--Use -> QuestieQuest:GetAllQuestObjectives(QuestId)
--170
function QuestieQuest:TrackQuest(QuestId)--Should probably be called from some kind of questlog or similar, will have to wait untill classic to find out how tracking really works...
  Quest = qCurrentQuestlog[QuestId]
  --Quest = QuestieDB:GetQuest(QuestId)

  ObjectiveID = 0
  if type(Quest) == "table" then
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]:", QuestId)
    if(Quest.Objectives["NPC"] ~= nil) then
      for index, ObjectiveData in pairs(Quest.Objectives["NPC"]) do
        for _, NPCID in pairs(ObjectiveData) do
          NPC = QuestieDB:GetNPC(NPCID)
          for Zone, Spawns in pairs(NPC.Spawns) do
            for _, coords in ipairs(Spawns) do
              Questie:Debug(DEBUG_INFO, "[QuestieQuest]:", Zone, coords[1], coords[2])
              data = {}
              data.Id = QuestId;
              data.Icon = ICON_TYPE_SLAY
              data.ObjectiveId = ObjectiveID
              data.NpcData = NPC;
              data.tooltip = {NPC.Name}
              --data.QuestData = Quest;
              QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
            end
          end
        end
        ObjectiveID = ObjectiveID + 1
      end
    end--
  end
end

function QuestieQuest:AcceptQuest(questId)
  Quest = QuestieDB:GetQuest(questId)
  if(Quest ~= nil) then
    qCurrentQuestlog[questId] = Quest
  else
    qCurrentQuestlog[questId] = questId
  end

  --Get all the Frames for the quest and unload them, the available quest icon for example.
  QuestieMap:UnloadQuestFrames(questId);

  --TODO: Insert call to drawing objective logic here!
  --QuestieQuest:TrackQuest(questId);

  Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Accept quest:", questId)
end

function QuestieQuest:CompleteQuest(QuestId)
  qCurrentQuestlog[QuestId] = nil;
  Questie.db.char.complete[QuestId] = true --can we use some other relevant info here?

  --Unload all the quest frames from the map.
  --QuestieMap:UnloadQuestFrames(QuestId); --We are currently redrawing everything so we might as well not use this now

  --TODO: This can probably be done better?
  QuestieQuest:CalculateAvailableQuests()
  QuestieQuest:DrawAllAvailableQuests();

  Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Completed quest:", QuestId)
end

function QuestieQuest:AbandonedQuest(QuestId)
  if(qCurrentQuestlog[QuestId]) then
    qCurrentQuestlog[QuestId] = nil

    --Unload all the quest frames from the map.
    QuestieMap:UnloadQuestFrames(QuestId);

    local quest = QuestieDB:GetQuest(QuestId);
    --The old data for notes are still there, we don't need to recalulate data.
    _QuestieQuest:DrawAvailableQuest(quest)

    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Abandoned Quest:", QuestId)
  end
end

--Run this if you want to update the entire table
function QuestieQuest:GetAllQuestIds()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]: Getting all quests")
  numEntries, numQuests = GetNumQuestLogEntries();
  qCurrentQuestlog = {}
  for index = 1, numEntries do
    title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
    if(not isHeader) then
      --Keep the object in the questlog to save searching
      Quest = qData[questId]
      if(Quest ~= nil) then
        qCurrentQuestlog[questId] = Quest
      else
        qCurrentQuestlog[questId] = questId
      end
      Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Added quest: "..questId)
    end
  end
end

--Use the category order to draw the quests and trust the database order.
--/dump QuestieQuest:GetAllQuestObjectives(24475)
function QuestieQuest:GetAllQuestObjectives(QuestId)
  local count = GetNumQuestLeaderBoards(GetQuestLogIndexByID(QuestId))
  objectives = {}
  for i = 1, count do
    objectiveType, objectiveDesc, numItems, numNeeded, isCompleted = _QuestieQuest:GetLeaderBoardDetails(i, QuestId)
    objectives[i] = {}
    objectives[i].Type = objectiveType
    objectives[i].Description = objectiveDesc
    objectives[i].Collected = numItems
    objectives[i].Needed = numNeeded
    objectives[i].Completed = isComplete
    objectives[i].Index = i
  end
  return objectives
end


--TODO Check that this resolves correctly in classic!
--/dump QuestieQuest:GetLeaderBoardDetails (1,1)
function _QuestieQuest:GetLeaderBoardDetails(BoardIndex,QuestId)
  Index = GetQuestLogIndexByID(QuestId)
  if(Index == 0) then
    Index = QuestId;
  end
  local description, objectiveType, isCompleted = GetQuestLogLeaderBoard (BoardIndex, Index);
  --Classic
  local itemName, numItems, numNeeded = string.match(description, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
  --Retail
  if(itemName == nil or string.len(itemName) < 5) then --Just a figure... check if its not 0
    numItems, numNeeded, itemName = string.match(description, "(%d+)\/(%d+)(.*)")
  end
  itemName = string.gsub(itemName, "slain", "")
  numItems, numNeeded = string.match(description, "(%d+)\/(%d+)")
  return objectiveType, strtrim(itemName), numItems, numNeeded, isCompleted;
end

--Draw a single available quest, it is used by the DrawAllAvailableQuests function.
function _QuestieQuest:DrawAvailableQuest(questObject)
  --If the object is nil we just return
  if(questObject == nil) then
    return false;
  end
  --TODO More logic here, currently only shows NPC quest givers.
  if(questObject.Starts["NPC"] ~= nil)then
    for index, NPCID in ipairs(questObject.Starts["NPC"]) do
      NPC = QuestieDB:GetNPC(NPCID)
      if(NPC ~= nil) then
        --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
        for Zone, Spawns in pairs(NPC.Spawns) do
          if(Zone ~= nil) then
            --Questie:Debug("Zone", Zone)
            --Questie:Debug("Qid:", questid)
            for _, coords in ipairs(Spawns) do
              --Questie:Debug("Coords", coords[1], coords[2])
              local data = {}
              data.Id = questObject.Id;
              data.Icon = ICON_TYPE_AVAILABLE;
              data.QuestData = questObject;
              data.tooltip = {"[" .. questObject.Level .. "] " .. questObject.Name, "Started by: " .. NPC.Name, "QuestId:"..questObject.Id}

              if(coords[1] == -1 or coords[2] == -1) then
                if(instanceData[Zone] ~= nil) then
                  for index, value in ipairs(instanceData[Zone]) do
                    --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
                    QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                  end
                end
              else
                --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
                --HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
                QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
              end
            end
          end
        end
      end
    end
  end
end

function QuestieQuest:DrawAllAvailableQuests()--All quests between
  --This should probably be called somewhere else!
  QuestieFramePool:UnloadAll()

  local count = 0
  for questid, qid in pairs(qAvailableQuests) do
    Quest = QuestieDB:GetQuest(questid)
    --Draw a specific quest through the function
    _QuestieQuest:DrawAvailableQuest(Quest)
    count = count + 1
  end
  Questie:Debug(DEBUG_INFO,"[QuestieQuest]", count, "available quests drawn.");
end




function _QuestieQuest:IsDoable(questObject)
  local allFinished=true
  --Run though the requiredQuests
  if questObject.RequiredQuest == nil or questObject.RequiredQuest == 0 then
    return true
  end
  for index, preQuestId in pairs(questObject.RequiredQuest) do

    local preQuest = QuestieDB:GetQuest(preQuestId);

    --If a quest is not complete not all are finished, we need to check group
    if not Questie.db.char.complete[preQuestId] then
      allFinished=false
    --If one of the quests in the group is done we return true
    elseif preQuest and preQuest.ExclusiveQuestGroup then
      return true
    end

    --If one of the quests are in the log, return false
    if preQuest and qCurrentQuestlog[preQuest.Id] then
      return false
    end
  end
  return allFinished
end

--TODO Check that this function does what it is supposed to...
function QuestieQuest:CalculateAvailableQuests()

  -- this should be renamed to levelsBelowPlayer / levelsAbovePlayer to be less confusing
  local PlayerLevel = UnitLevel("player");
  local MinLevel = UnitLevel("player") - Questie.db.global.minLevelFilter
  local MaxLevel = UnitLevel("player") + Questie.db.global.maxLevelFilter

  DEFAULT_CHAT_FRAME:AddMessage(" minlevel/maxlevel: " .. MinLevel .. "/" .. MaxLevel);

  qAvailableQuests = {}

  for i, v in pairs(qData) do
    local QuestID = i;
    --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.
    if(not Questie.db.char.complete[QuestID] and not qHide[QuestID] and not qCurrentQuestlog[QuestID]) then --Should be not qCurrentQuestlog[QuestID]
      local Quest = QuestieDB:GetQuest(QuestID);
      if Quest.Level > MinLevel and Quest.Level < MaxLevel and Quest.MinLevel <= PlayerLevel then
        if _QuestieQuest:IsDoable(Quest) then
          qAvailableQuests[QuestID] = QuestID
        end
      end
    end
  end
end
