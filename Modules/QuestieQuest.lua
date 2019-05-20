QuestieQuest = {...}
local _QuestieQuest = {...}


qAvailableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD

qCurrentQuestlog = {} --Gets populated by QuestieQuest:GetAllQuestIds(), this is either an object to the quest in question, or the ID if the object doesn't exist.

function QuestieQuest:Initialize()
  Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Getting all completed quests")
  GetQuestsCompleted(Questie.db.char.complete)
end


--Use the category order to draw the quests and trust the database order.
--/dump QuestieQuest:GetAllQuestObjectives(24475)
--Use -> QuestieQuest:GetAllQuestObjectives(QuestId)
--170
function QuestieQuest:TrackQuest(QuestId)--Should probably be called from some kind of questlog or similar, will have to wait untill classic to find out how tracking really works...
  Quest = qCurrentQuestlog[QuestId]
  Quest = QuestieDB:GetQuest(QuestId)

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
              data.IconType = ICON_TYPE_SLAY
              data.ObjectiveId = ObjectiveID
              data.NpcData = NPC;
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

function QuestieQuest:AcceptQuest(QuestId)
  Quest = qData[questId]
  if(Quest ~= nil) then
    qCurrentQuestlog[QuestId] = Quest
  else
    qCurrentQuestlog[QuestId] = questId
  end
  Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Accept quest:", QuestId)
end

function QuestieQuest:CompleteQuest(QuestId)
  qCurrentQuestlog[QuestId] = nil;
  Questie.db.char.complete[QuestId] = true --can we use some other relevant info here?
  Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Completed quest:", QuestId)
end

function QuestieQuest:AbandonedQuest(QuestId)
  if(qCurrentQuestlog[QuestId]) then
    Questie:Debug(DEBUG_DEVELOP "[QuestieQuest]: Abandoned Quest:", QuestId)
    qCurrentQuestlog[QuestId] = nil
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
  if(itemName == nil or len(itemName) < 5) then --Just a figure... check if its not 0
    numItems, numNeeded, itemName = string.match(description, "(%d+)\/(%d+)(.*)")
  end
  itemName = string.gsub(itemName, "slain", "")
  numItems, numNeeded = string.match(description, "(%d+)\/(%d+)")
  return objectiveType, strtrim(itemName), numItems, numNeeded, isCompleted;
end


function QuestieQuest:DrawAvailableQuests()--All quests between

  --This should probably be called somewhere else!
  QuestieFramePool:UnloadAll()

  local count = 0
  for questid, qid in pairs(qAvailableQuests) do
    Quest = QuestieDB:GetQuest(questid)
    if(Quest.Starts["NPC"] ~= nil)then
      for index, NPCID in ipairs(Quest.Starts["NPC"]) do
        NPC = QuestieDB:GetNPC(NPCID)
        if(NPC ~= nil) then
          --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", Quest.Id, "StarterNPC:", NPC.Id)
          for Zone, Spawns in pairs(NPC.Spawns) do
            if(Zone ~= nil) then
              --Questie:Debug("Zone", Zone)
              --Questie:Debug("Qid:", questid)
              for _, coords in ipairs(Spawns) do
                --Questie:Debug("Coords", coords[1], coords[2])
                local data = {}
                data.Id = questid;
                data.Icon = "Interface\\Addons\\Questie\\Icons\\available.blp"
                data.QuestData = Quest;
				data.tooltip = {Quest.Name, "Started by: " .. NPC.Name}
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
                count = count + 1
              end
            end
          end
        end
      end
    end
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
local ShowAllQuestsDebug = false
function QuestieQuest:CalculateAvailableQuests()

  -- this should be renamed to levelsBelowPlayer / levelsAbovePlayer to be less confusing
  local MinLevel = UnitLevel("player") - Questie.db.global.minLevelFilter
  local MaxLevel = UnitLevel("player") + Questie.db.global.maxLevelFilter

  DEFAULT_CHAT_FRAME:AddMessage(" minlevel/maxlevel: " .. MinLevel .. "/" .. MaxLevel);

  qAvailableQuests = {}

  for i, v in pairs(qData) do
    local QuestID = i;
    if(ShowAllQuestsDebug == true) then
      qAvailableQuests[QuestID] = QuestID
    else
       --Check if we've already completed the quest and that it is not "manually" hidden.
      if(not Questie.db.char.complete[QuestID] and not qHide[QuestID]) then
        local Quest = QuestieDB:GetQuest(QuestID);
        if _QuestieQuest:IsDoable(Quest) and Quest.MinLevel > MinLevel and Quest.MinLevel <= MaxLevel then
          qAvailableQuests[QuestID] = QuestID
        end
      end
    end
  end
end
