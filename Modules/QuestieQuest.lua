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
  --Get all the Frames for the quest and unload them, the available quest icon for example.
  QuestieMap:UnloadQuestFrames(questId);

  Quest = QuestieDB:GetQuest(questId)
  if(Quest ~= nil) then
    QuestieQuest:PopulateQuestLogInfo(Quest)
	QuestieQuest:PopulateObjectiveNotes(Quest)
    qCurrentQuestlog[questId] = Quest
  else
    qCurrentQuestlog[questId] = questId
  end


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

function QuestieQuest:UpdateQuest(QuestId)
  local quest = QuestieDB:GetQuest(QuestId);
  if quest ~= nil then
    QuestieQuest:GetAllQuestObjectives(quest) -- update quest log values in quest object
	QuestieQuest:UpdateObjectiveNotes(quest)
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
      Quest = QuestieDB:GetQuest(questId)
      if(Quest ~= nil) then
	    QuestieQuest:PopulateQuestLogInfo(Quest)
		QuestieQuest:PopulateObjectiveNotes(Quest)
        qCurrentQuestlog[questId] = Quest
      else
        qCurrentQuestlog[questId] = questId
      end
      Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Added quest: "..questId)
    end
  end
end

function QuestieQuest:ShouldQuestShowObjectives(QuestId)
	return true -- todo: implement tracker logic here, to hide non-tracked quest optionally (1.12 questie does this optionally)
end


local function counthack(tab) -- according to stack overflow, # and table.getn arent reliable (I've experienced this? not sure whats up)
   local count = 0
   for k,v in pairs(tab) do count = count + 1; end
   return count
end
function QuestieQuest:IsComplete(Quest)
   return Quest.Objectives == nil or counthack(Quest.Objectives) == 0 or Quest.isComplete;
end
-- iterate all notes, update / remove as needed
function QuestieQuest:UpdateObjectiveNotes(Quest)
  Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes:", Quest.Id)
  if 1 then
    if Quest.Objectives ~= nil then
	  for k,v in pairs(Quest.Objectives) do
	    if v.NoteRefs ~= nil then -- update tooltip value
		  for k2,v2 in pairs(v.NoteRefs) do
		                                                         -- the reason why we do +1 here is the classic beta api is bugged atm. it is *always* 1 behind right after an update
		    v2.tooltip[2] = "|cFF22FF22" .. v.Description .. " " .. (v.Collected+1) .. "/" .. v.Needed;
			Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes: Updated tooltip:", v2.tooltip[2])
			-- HACK: for some reason, notes arent being removed on complete, this is a temporary fix
			if (v.Collected+1) >= tonumber(v.Needed) then
			  Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes: Removing tooltip:", v2.refWorldMap, v2.refMiniMap)
        v2.refMiniMap.Unload(v2.refMiniMap);
        v2.refWorldMap.Unload(v2.refWorldMap);
			  --QuestieMap:RemoveIcon(v2.ref)
			end

		  end
		else
		  Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes: attempt to update objective with no noterefs")
		end
	  end
	else
	  Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes: attempt to update quest with no objective data")
	end
  else
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes: attempt to update completed quest")
		for k,v in pairs(Quest.Objectives) do
			if v.NoteRefs ~= nil then
				for k2,v2 in pairs(v.NoteRefs) do
          v2.refMiniMap.Unload(v2.refMiniMap);
          v2.refWorldMap.Unload(v2.refWorldMap);
					--QuestieMap:RemoveIcon(v2.ref)
				end
			end
		end
  end
	--if QuestieQuest:IsComplete(Quest) then
	--	for k,v in pairs(Quest.Objectives) do
	--		if v.NoteRefs ~= nil then
	--			for k2,v2 in pairs(v.NoteRefs) do
	--				QuestieMap:RemoveIcon(v2.ref)
	--			end
	--		end
	--	end
    --    return
	--end
end
function QuestieQuest:PopulateObjectiveNotes(Quest)
	if QuestieQuest:IsComplete(Quest) then
        return
	end
	local maxNotes = 256 -- max notes for 1 quest, this should be changed to clustering code later (prevent LAG on some quests)

	-- we've already checked the objectives table by doing IsComplete
	-- of that changes, check it here
	for k,v in pairs(Quest.Objectives) do
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateObjectiveNotes:", k, v.Type, v.Description, v.Collected, v.Needed, v.Id)
		if v.NoteRefs == nil then -- used for updating notes
		  v.NoteRefs = {};
		end
		if v.Type == "item" then
		   local item = QuestieDB:GetItem(v.Id);
		   if item ~= nil and item.Sources ~= nil then
		     Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: GotItem", v.Id, item.Id)
			 for k2,v2 in pairs(item.Sources) do
			   if v2.Type == "monster" then
				  NPC = QuestieDB:GetNPC(v2.Id)
				  if(NPC ~= nil and NPC.Spawns ~= nil) then
					--Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
					for Zone, Spawns in pairs(NPC.Spawns) do
					  if(Zone ~= nil and Spawns ~= nil) then
						--Questie:Debug("Zone", Zone)
						--Questie:Debug("Qid:", questid)
						for _, coords in ipairs(Spawns) do
					      maxNotes = maxNotes - 1
						  if maxNotes < 0 then
						     return
					      end
						  --Questie:Debug("Coords", coords[1], coords[2])
						  local data = {}
						  table.insert(v.NoteRefs, data);
						  data.Id = Quest.Id;
						  data.Icon = ICON_TYPE_LOOT;
						  data.IconScale = 0.5;
						  data.QuestData = Quest;
						  data.ObjectiveTargetId = v2.Id
						  data.tooltip = {NPC.Name, "|cFF22FF22" .. v.Description .. " " .. v.Collected .. "/" .. v.Needed, "|cFFFFFFFF" .. Quest.Name}
							--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn1", v.Id, item.Id, NPC.Name )
						  if(coords[1] == -1 or coords[2] == -1) then
							if(instanceData[Zone] ~= nil) then
							  for index, value in ipairs(instanceData[Zone]) do
								--Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
								--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn3", value[1], value[2], value[3])
								QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
							  end
							end
						  else
							--Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
							--HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
							--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn2", Zone, coords[1], coords[2])
							QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
						  end
						end
					  end
					end
				  end
			   elseif v2.Type == "object" then
				  local obj = QuestieDB:GetObject(v2.Id)
				  if(obj ~= nil and obj.Spawns ~= nil) then
					--Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
					for Zone, Spawns in pairs(obj.Spawns) do
					  if(Zone ~= nil and Spawns ~= nil) then
						--Questie:Debug("Zone", Zone)
						--Questie:Debug("Qid:", questid)
						for _, coords in ipairs(Spawns) do
					      maxNotes = maxNotes - 1
						  if maxNotes < 0 then
						     return
					      end
						  --Questie:Debug("Coords", coords[1], coords[2])
						  local data = {}
						  table.insert(v.NoteRefs, data);
						  data.Id = Quest.Id;
						  data.Icon = ICON_TYPE_LOOT;
						  data.IconScale = 0.5;
						  data.QuestData = Quest;
						  data.ObjectiveTargetId = v2.Id
						  data.tooltip = {obj.Name, "|cFF22FF22" .. v.Description .. " " .. v.Collected .. "/" .. v.Needed, "|cFFFFFFFF" .. Quest.Name}
							--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn1", v.Id, item.Id, obj.Name )
						  if(coords[1] == -1 or coords[2] == -1) then
							if(instanceData[Zone] ~= nil) then
							  for index, value in ipairs(instanceData[Zone]) do
								--Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
								--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn3", value[1], value[2], value[3])
								QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
							  end
							end
						  else
							--Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
							--HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
							--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn2", Zone, coords[1], coords[2])
							QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
						  end
						end
					  end
					end
				  end
			   else
			     Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Unhandled item source type ", v2.Id, v2.Type)
			   end
			 end
		   else
		     Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Error getting item ", v.Id)
		   end
		elseif v.Type == "monster" then
		  NPC = QuestieDB:GetNPC(v.Id)
		  if(NPC ~= nil and NPC.Spawns ~= nil) then
			--Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
			for Zone, Spawns in pairs(NPC.Spawns) do
			  if(Zone ~= nil and Spawns ~= nil) then
				--Questie:Debug("Zone", Zone)
				--Questie:Debug("Qid:", questid)
				for _, coords in ipairs(Spawns) do
				  maxNotes = maxNotes - 1
				  if maxNotes < 0 then
					 return
				  end
				  --Questie:Debug("Coords", coords[1], coords[2])
				  local data = {}
				  table.insert(v.NoteRefs, data);
				  data.Id = Quest.Id;
				  data.Icon = ICON_TYPE_SLAY;
				  data.IconScale = 0.5;
				  data.QuestData = Quest;
				  data.ObjectiveTargetId = v.Id
				  data.tooltip = {NPC.Name, "|cFF22FF22" .. v.Description .. " " .. v.Collected .. "/" .. v.Needed, "|cFFFFFFFF" .. Quest.Name}
				  --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn1", v.Id, NPC.Name )
				  if(coords[1] == -1 or coords[2] == -1) then
					if(instanceData[Zone] ~= nil) then
					  for index, value in ipairs(instanceData[Zone]) do
						--Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
						--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn3", value[1], value[2], value[3])
						QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
					  end
					end
				  else
					--Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
					--HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
					--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn2", Zone, coords[1], coords[2])
					QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
				  end
				end
			  end
			end
		  end
		elseif v.Type == "event" then

		end
	end
end
function QuestieQuest:PopulateQuestLogInfo(Quest)
	--Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateMeta1:", Quest.Id, Quest.Name)
	if Quest.Objectives == nil then
	  Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateQuestLogInfo: creating new objective table")
	  Quest.Objectives = {};
	end
	QuestieQuest:GetAllQuestObjectives(Quest)
	local logID = GetQuestLogIndexByID(Quest.Id);
	if logID ~= 0 then
	  _, _, _, _, _, Quest.isComplete, _, _, _, _, _, _, _, _, _, Quest.isHidden = GetQuestLogTitle(logID)
	  --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateMeta:", Quest.isComplete, Quest.Name)
	end
end

--Use the category order to draw the quests and trust the database order.
--/dump QuestieQuest:GetAllQuestObjectives(24475)
function QuestieQuest:GetAllQuestObjectives(Quest)
  local count = GetNumQuestLeaderBoards(GetQuestLogIndexByID(Quest.Id))


  for i = 1, count do
    objectiveType, objectiveDesc, numItems, numNeeded, isCompleted = _QuestieQuest:GetLeaderBoardDetails(i, Quest.Id)
    if Quest.Objectives[i] == nil then
	  Quest.Objectives[i] = {}
	end
    Quest.Objectives[i].Type = objectiveType
    Quest.Objectives[i].Description = objectiveDesc
    Quest.Objectives[i].Collected = numItems
    Quest.Objectives[i].Needed = numNeeded
    Quest.Objectives[i].Completed = isComplete
    Quest.Objectives[i].Index = i

	if count == 1 and counthack(Quest.ObjectiveData) == 1 then
	  Quest.Objectives[i].Id = Quest.ObjectiveData[1].Id
	elseif Quest.ObjectiveData ~= nil then
	  -- try to find npc/item/event ID
	  for k,v in pairs(Quest.ObjectiveData) do
	    if objectiveType == v.Type then
	      -- TODO: use string distance to find closest, dont rely on exact match
		  if string.lower(objectiveDesc) == v.Name or v.Name == nil then
		    Quest.Objectives[i].Id = v.Id
		  end
	    end
	  end
	end

	if Quest.Objectives[i].Id == nil then
	  Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Error finding entry ID for objective", objectiveType, objectiveDesc, Quest.ObjectiveData[1].Id)
	end

  end
  return Quest.Objectives
end


--TODO Check that this resolves correctly in classic!
--/dump QuestieQuest:GetLeaderBoardDetails (1,1)
function _QuestieQuest:GetLeaderBoardDetails(BoardIndex,QuestId)
  Index = GetQuestLogIndexByID(QuestId)
  if(Index == 0) then
    Index = QuestId;
  end
  local description, objectiveType, isCompleted = GetQuestLogLeaderBoard (BoardIndex, Index);
  --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Quest Details1:", description, objectiveType, isCompleted)
  --Classic
  local itemName, numItems, numNeeded = string.match(description, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
  --Retail
  if(itemName == nil or string.len(itemName) < 5) then --Just a figure... check if its not 0
    numItems, numNeeded, itemName = string.match(description, "(%d+)\/(%d+)(.*)")
  end
  Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Quest Details2:", QuestId, itemName, numItems, numNeeded)
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
      if(NPC ~= nil and NPC.Spawns ~= nil) then
        --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
        for Zone, Spawns in pairs(NPC.Spawns) do
          if(Zone ~= nil and Spawns ~= nil) then
            --Questie:Debug("Zone", Zone)
            --Questie:Debug("Qid:", questid)
            for _, coords in ipairs(Spawns) do
              --Questie:Debug("Coords", coords[1], coords[2])
              local data = {}
              data.Id = questObject.Id;
              data.Icon = ICON_TYPE_AVAILABLE;
              data.QuestData = questObject;
              data.tooltip = {QuestieTooltips:PrintDifficultyColor(questObject.Level, "[" .. questObject.Level .. "] " .. questObject.Name), "|cFFFFFFFFStarted by: |r|cFF22FF22" .. NPC.Name, "QuestId:"..questObject.Id}

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
  --QuestieFramePool:UnloadAll()

  local count = 0
  for questid, qid in pairs(qAvailableQuests) do
    --If the quest is not drawn draw the quest, otherwise skip.
    if(not qQuestIdFrames[questid]) then
      Quest = QuestieDB:GetQuest(questid)
      --Draw a specific quest through the function
      _QuestieQuest:DrawAvailableQuest(Quest)
    end
    count = count + 1
  end
  Questie:Debug(DEBUG_INFO,"[QuestieQuest]", count, "available quests drawn.");
end




function _QuestieQuest:IsDoable(questObject) -- we need to add profession/reputation checks here
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

  --DEFAULT_CHAT_FRAME:AddMessage(" minlevel/maxlevel: " .. MinLevel .. "/" .. MaxLevel);

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
      else
        --If the quests are not within level range we want to unload them
        --(This is for when people level up or change settings etc)
        QuestieMap:UnloadQuestFrames(QuestID);
      end
    end
  end
end
