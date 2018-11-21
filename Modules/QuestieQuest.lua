QuestieQuest = {...}
local _QuestieQuest = {...}


qAvailableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD

qCurrentQuestlog = {} --Gets populated by QuestieQuest:GetAllQuestIds(), this is either an object to the quest in question, or the ID if the object doesn't exist.

function QuestieQuest:Initialize()
  Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Getting all completed quests")
  GetQuestsCompleted(Questie.db.char.complete)
end

--170
function QuestieQuest:TrackQuest(QuestId)--Should probably be called from some kind of questlog or similar, will have to wait untill classic to find out how tracking really works...
  Quest = qCurrentQuestlog[QuestId]
  Quest = QuestieDB:GetQuest(QuestId)
  
  ObjectiveID = 0
  if type(Quest) == "table" then
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]:", QuestId)
    for
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
--/dump QuestieQuest:GetLeaderBoardDetails (1,1)
function QuestieQuest:GetLeaderBoardDetails(BoardIndex,QuestId)
  Index = GetQuestLogIndexByID(QuestId)
  if(Index == 0) then
    Index = QuestId;
  end
  local description, objectiveType, isCompleted = GetQuestLogLeaderBoard (BoardIndex, Index);
  local numItems, numNeeded, itemName = string.match(description, "(%d+)\/(%d+)(.*)")
  --local itemName = "tet";
  --local itemName, numItems, numNeeded = string.match(description, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
  return objectiveType, strtrim(itemName), numItems, numNeeded, isCompleted;
end -- returns eg. "monster", "Young Nightsaber slain", 1, 7, nil


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
                data.IconType = ICON_TYPE_AVAILABLE
                data.ObjectiveId = -1
                data.QuestData = Quest;
                data.Starter = NPC
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




--TODO Check that this function does what it is supposed to...
local ShowAllQuestsDebug = false
function QuestieQuest:CalculateAvailableQuests()
  local MinLevel = UnitLevel("player") - Questie.db.global.minLevelFilter
  local MaxLevel = UnitLevel("player") + Questie.db.global.maxLevelFilter
  for id, data in pairs(qAvailableQuests) do

  end
  qAvailableQuests = {}
  for i, v in pairs(qData) do
    if(ShowAllQuestsDebug == true) then
      qAvailableQuests[i] = i
    else
      if(MinLevel >= v[DB_MIN_LEVEL]) then
        qAvailableQuests[i] = i
      elseif(MaxLevel >= v[DB_MIN_LEVEL] and MaxLevel >= v[DB_LEVEL]) then --MaxLevel >= v[DB_LEVEL] Hides lvl 60 quests if you are not close, some are pretty stupid to show such as 1-60 range quests
        qAvailableQuests[i] = i
      elseif(MaxLevel >= v[DB_MIN_LEVEL] and Questie.db.char.lowlevel) then
        qAvailableQuests[i] = i
      end
    end
  end
end
