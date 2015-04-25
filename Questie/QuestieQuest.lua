

--THIS IS THE FUNCTION TO USE!
LastQuestLogHashes = nil;
LastCount = 0;
function Questie:CheckQuestLog()
  	local numEntries, numQuests = GetNumQuestLogEntries();
	if(LastCount == numEntries) then
		--Questie:debug_Print("Checking questlog: Nothing changed");
		return;
	end
	LastCount = numEntries;
	local t = GetTime();
	if(not LastQuestLogHashes) then
		LastQuestLogHashes = Questie:AstroGetAllCurrentQuestHashesAsMeta();
		Questie:debug_Print("First check run, adding all quests");
		for k, v in pairs(LastQuestLogHashes) do
			Questie:AddQuestToMap(v["hash"]);
			if(not QuestieSeenQuests[v["hash"]]) then
				Questie:debug_Print("Adding quest to seen quests:", v["name"],v["hash"]," setting as 0");
				QuestieSeenQuests[v["hash"]] = 0
			end
		end
		Questie:RedrawNotes();
		return;
	end
	local Quests = Questie:AstroGetAllCurrentQuestHashesAsMeta();
	MapChanged = false;

	delta = {};
	if (table.getn(Quests) > table.getn(LastQuestLogHashes)) then
		for k, v in pairs(Quests) do
			if(Quests[k] and LastQuestLogHashes[k]) then

			else
				if(Quests[k]) then
					v["deltaType"] = 1;
					table.insert(delta, v);
				else
					v["deltaType"] = 0;
					table.insert(delta, v);
				end
			end
		end
	else
		for k, v in pairs(LastQuestLogHashes) do
			if(Quests[k] and LastQuestLogHashes[k]) then

			else
				if(Quests[k]) then
					v["deltaType"] = 1;
					table.insert(delta, v);
				else
					v["deltaType"] = 0;
					table.insert(delta, v);
				end
			end
		end
	end

	for k, v in pairs(delta) do
		Questie:debug_Print(v["name"],v["hash"], v["deltaType"]);
		if(v["deltaType"] == 1) then
			Questie:debug_Print("Check discovered a new quest,", v["name"]);
			Questie:AddQuestToMap(v["hash"]);
			if(not QuestieSeenQuests[v["hash"]]) then
				QuestieSeenQuests[v["hash"]] = 0
			end
			MapChanged = true;
		else				
			Questie:debug_Print("Check discovered a missing quest, removing!", v["hash"], v["name"])
			Questie:RemoveQuestFromMap(v["hash"]);
			if(not QuestieCompletedQuestMessages[v["name"]]) then
				QuestieCompletedQuestMessages[v["name"]] = 0;
			end
			if(not QuestieSeenQuests[v["hash"]]) then
				Questie:debug_Print("Adding quest to seen quests:", v["name"],v["hash"]," setting as 0");
				QuestieSeenQuests[v["hash"]] = 0
			end
			if lastObjectives[v["hash"]] then
				lastObjectives = nil;
			end
			MapChanged = true;
		end
	end

	--Questie:debug_Print(table.getn(delta));
	newcheckArray = nil;
	checkArray = nil;
	BiggestTable = nil;
	delta = nil;

	if(MapChanged == true) then
		Questie:RedrawNotes();
	end
	LastQuestLogHashes = Quests;
	Questie:debug_Print("Checklog done: Time:",tostring((GetTime()-t)*1000).."ms");
end

ASDFF = nil;

--QuestieHandledQuests is set inside questienotes (not set) This currently will "leak" quests are never removed.
lastObjectives = nil
function Questie:UpdateQuests(force)
	if(lastObjectives == nil) then
		lastObjectives = {};
		Questie:UpdateQuestsInit();
		return;
	end
	local ZonesChecked = 0;
	local t = GetTime();
	local CurrentZone = GetZoneText();
  	local numEntries, numQuests = GetNumQuestLogEntries();
  	local foundChange = false;
  	local ZonesWithQuests = {};
  	local change = Questie:UpdateQuestInZone(CurrentZone);
  	ZonesChecked = ZonesChecked+1;
  	if(not change) then
  		change = Questie:UpdateQuestInZone(GetMinimapZoneText());
  		ZonesChecked = ZonesChecked+1;
  	end
	if(not change or force) then
		--Questie:debug_Print("No change in current zone, checking all other zones!");
		for i = 1, numEntries do
			local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
			if(isHeader and q ~= CurrentZone) then
				local c = Questie:UpdateQuestInZone(q, force);
				ZonesChecked = ZonesChecked +1;
				if(c and not force)then
					break;
				end
			end
		end
	else
		--Questie:debug_Print("Found change in current zone, good!");
	end
	Questie:debug_Print("Updated quests: Time:", tostring((GetTime()-t)*1000).."ms","Zones:"..ZonesChecked)
end

function Questie:UpdateQuestInZone(Zone, force)
 	local numEntries, numQuests = GetNumQuestLogEntries();
  	local foundChange = nil;
  	local ZoneFound = nil;
  	local QuestsChecked = 0;
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if(ZoneFound and isHeader) then
			--Questie:debug_Print("Update: End: ", Zone,"Quests checked", QuestsChecked);
			break;
		end
		if(isHeader and q == Zone) then
			--Questie:debug_Print("Update: Start: ", Zone, "index:", i);
			ZoneFound = true;
		end 
		if not isHeader and ZoneFound then
			--Questie:debug_Print(q);
			QuestsChecked = QuestsChecked+1;
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();
		    local hash = Questie:getQuestHash(q, level, objectiveText);
		    if not lastObjectives[hash] then
		    	lastObjectives[hash] = {};
		    end
		    local Refresh = nil;
		    for obj = 1, count do
		    	if (not lastObjectives[hash][obj]) then
		    		lastObjectives[hash][obj] = {};
		    	end
		   		local desc, typ, done = GetQuestLogLeaderBoard(obj);
		   		if(lastObjectives[hash][obj].desc == desc and lastObjectives[hash][obj].typ == typ and lastObjectives[hash][obj].done == done) then
		   			--All objectives are the same, Dont really do anything (But have this here for future)
		   		elseif(lastObjectives[hash][obj].done ~= done) then
		   			--This objective has flipped from, not done to done
		   			Refresh = true;
		   			foundChange = true;
		   		else
		   			--Something has changed.
		   			--Questie:debug_Print("Type or desc changed");
		   			foundChange = true;
		   		end
		   		lastObjectives[hash][obj].desc = desc;
		   		lastObjectives[hash][obj].typ = typ;
		   		lastObjectives[hash][obj].done = done;
			end

			if(Refresh) then --If it's the same it means everything is done
				Questie:debug_Print("Update: Something has changed, need to refresh:", hash);
				Questie:AddQuestToMap(hash, true);
			end
		end
		if(foundChange and not force) then
			Questie:debug_Print("Found a change!")
			break;
		end
	end
	--Questie:debug_Print("Checked zone", Zone);
	return foundChange;
end

function Questie:UpdateQuestsInit()
 	local numEntries, numQuests = GetNumQuestLogEntries();
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();
		    local hash = Questie:getQuestHash(q, level, objectiveText);
		    if not lastObjectives[hash] then
		    	lastObjectives[hash] = {};
		    end
		    for obj = 1, count do
		    	if (not lastObjectives[hash][obj]) then
		    		lastObjectives[hash][obj] = {};
		    	end
		   		lastObjectives[hash][obj].desc = desc;
		   		lastObjectives[hash][obj].typ = typ;
		   		lastObjectives[hash][obj].done = done;
			end
		end
	end
end

function Questie:AstroGetAllCurrentQuestHashes(print)
	local hashes = {};
  	local numEntries, numQuests = GetNumQuestLogEntries();
	if(print) then
		Questie:debug_Print("--Listing all current quests--");
	end
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();
		    local quest = {};
		    quest["name"] = q;
		    quest["level"] = level;
		    local hash = Questie:getQuestHash(q, level, objectiveText)
		    quest["hash"] = hash;

		    --This uses the addon URLCopy to easily be able to copy the questHashes from the debuglog.
		  	if(IsAddOnLoaded("URLCopy") and print)then
		  		Questie:debug_Print("        "..q,URLCopy_Link(quest["hash"]));
			elseif(print) then
		  		Questie:debug_Print("        "..q,quest["hash"]);
			end


		    table.insert(hashes, quest);
		else
			if(print) then
				Questie:debug_Print("    Zone:", q);
			end
		end
	end
	if(print) then
		Questie:debug_Print("--End of all current quests--");
	end
	return hashes;
end

function Questie:AstroGetAllCurrentQuestHashesAsMeta(print)
	local hashes = {};
  	local numEntries, numQuests = GetNumQuestLogEntries();
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();
		    local hash = Questie:getQuestHash(q, level, objectiveText)
		    hashes[hash] = {};
		    hashes[hash]["hash"] = hash;
		    hashes[hash]["name"] = q;
		    hashes[hash]["level"] = level;

		    --This uses the addon URLCopy to easily be able to copy the questHashes from the debuglog.
		  	if(IsAddOnLoaded("URLCopy") and print)then
		  		Questie:debug_Print("        "..q,URLCopy_Link(quest["hash"]));
			elseif(print) then
		  		Questie:debug_Print("        "..q,quest["hash"]);
			end
		else
			if(print) then
				Questie:debug_Print("    Zone:", q);
			end
		end
	end
	if(print) then
		Questie:debug_Print("--End of all current quests--");
	end
	return hashes;
end


function Questie:GetQuestIdFromHash(questHash)
	local numEntries, numQuests = GetNumQuestLogEntries();
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();

		    if(Questie:getQuestHash(q, level, objectiveText) == questHash) then
		   	 	QuestLogID = i;
		    	break;
		    end
		end
	end
	if not QuestLogID then
		return;
	else
		return QuestLogID;
	end
end

function Questie:GetHashFromName(name)
	local numEntries, numQuests = GetNumQuestLogEntries();
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();

		    if(q == name) then
		   	 	return Questie:getQuestHash(q, level, objectiveText);
		    end
		end
	end
return nil;
end


--The reason IsQuestFinished and getFinished quest basiclly have the same code is because they return different things... i need both!
--Astrolabe functions DO NOT USE UNLESS YOU KNOW WHAT YOU ARE DOING!!
function Questie:IsQuestFinished(questHash)
  	numEntries, numQuests = GetNumQuestLogEntries();
  	local FinishedQuests = {};
  	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();
		    Done = true;
		    for obj = 1, count do
		   		local desc, typ, done = GetQuestLogLeaderBoard(obj);
		   		if not done then
		   			Done = nil;
		   		end
			end
			if(Done and Questie:getQuestHash(q, level, objectiveText) == questHash) then
				local ret = {};
				ret["questHash"] = questHash;
				ret["name"] = q;
				ret["level"] = level;
				return ret;
			end
		end
	end

	--TODO: Check SavedVariables!

	return nil;
end

--The reason IsQuestFinished and getFinished quest basiclly have the same code is because they return different things... i need both!
--Astrolabe functions DO NOT USE UNLESS YOU KNOW WHAT YOU ARE DOING!!
function Questie:AstroGetFinishedQuests()
  	numEntries, numQuests = GetNumQuestLogEntries();
  	local FinishedQuests = {};
  	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();
		    Done = true;
		    for obj = 1, count do
		   		local desc, typ, done = GetQuestLogLeaderBoard(obj);
		   		if not done then
		   			Done = nil;
		   		end
			end
			if(Done) then
				Questie:debug_Print("Finished returned:", Questie:getQuestHash(q, level, objectiveText),q,level)
				table.insert(FinishedQuests, Questie:getQuestHash(q, level, objectiveText));
			end
		end
	end
	return FinishedQuests;
end
--Questie:AstroGetQuestObjectives(1431546316)
function Questie:AstroGetQuestObjectives(questHash)
	local hashData = QuestieHashMap[questHash];
	local QuestLogID = nil;
  	local numEntries, numQuests = GetNumQuestLogEntries();
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();

		    if(Questie:getQuestHash(q, level, objectiveText) == questHash) then
		   	 	QuestLogID = i;
		    	break;
		    end
		end
	end
	if not QuestLogID then
		return;
	end
	local mapid = getCurrentMapID();
	--Gets Quest information
	local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(QuestLogID);
	SelectQuestLogEntry(QuestLogID);
	local count =  GetNumQuestLeaderBoards();
	local questText, objectiveText = _GetQuestLogQuestText();
	local AllObjectives = {};
	AllObjectives["QuestName"] = q;
	AllObjectives["objectives"] = {};
	for i = 1, count do
		--This returns a quests objectives.
		local desc, typ, done = GetQuestLogLeaderBoard(i);
		--Gets the type
		local typeFunction = AstroobjectiveProcessors[typ];
		if typ == "item" or typ == "monster" then
			local indx = findLast(desc, ":");
			--DEFAULT_CHAT_FRAME:AddMessage(indx, 0.95, 0.95, 0.5);
			local countstr = string.sub(desc, indx+2);
			local namestr = string.sub(desc, 1, indx-1);
			--AllObjectives["type"] = typ;
			local objectives = typeFunction(q, namestr, countstr, selected, mapid);
			
			Objective = {};
		    local hash = Questie:getQuestHash(q, level, objectiveText);
			for k, v in pairs(objectives) do
				if (AllObjectives["objectives"][v["name"]] == nil) then
					AllObjectives["objectives"][v["name"]] = {};
				end
				if(not QuestieCachedMonstersAndObjects[hash]) then
					QuestieCachedMonstersAndObjects[hash] = {};
				end
				if(not QuestieCachedMonstersAndObjects[hash][v["name"]]) then
					QuestieCachedMonstersAndObjects[hash][v["name"]] = {};
				end
				QuestieCachedMonstersAndObjects[hash][v["name"]].name = v["name"];
				for monster, info in pairs(v['locations']) do
					local obj = {};
					obj["mapid"] = info[1];
					obj["x"] = info[2];
					obj["y"] = info[3];
					obj["type"] = v["type"];
					obj["done"] = done;
					obj['objectiveid'] = i;
					table.insert(AllObjectives["objectives"][v["name"]], obj);
				end
			end
		else

		end
	end
	TEMPDUMP =AllObjectives;
	--for name, locations in pairs(AllObjectives['objectives']) do
	--	for k, location in pairs(locations) do
			--Questie:debug_Print(name,location.mapid, location.x, location.y);
	--	end
	--end
	--Questie:debug_Print(AllObjectives['type'], AllObjectives['objectives'][1].name)
	return AllObjectives;
end
TEMPDUMP = nil;
--[[
		if typ == "item" or typ == "monster" then
			Questie:debug_Print(typ);
			local indx = findLast(desc, ":");
			--DEFAULT_CHAT_FRAME:AddMessage(indx, 0.95, 0.95, 0.5);
			local countstr = string.sub(desc, indx+2);
			local namestr = string.sub(desc, 1, indx-1);
			Questie:debug_Print(tostring(q), tostring(namestr), tostring(countstr), tostring(selected), tostring(mapid))
			local objectives = typeFunction(q, namestr, countstr, selected, mapid);
			Questie:debug_Print("Objectives:", table.getn(objectives));
			for k, v in pairs(objectives) do
				for monster, pos in pairs(v['locations']) do
					Questie:debug_Print("Monster Pos:",v["name"], pos[2],pos[3]);
				end
			end
		else
			Questie:debug_Print(typ);
			local objectives = typeFunction(quest, desc, "", selected, mapid);
			Questie:debug_Print(quest, desc);
			Questie:debug_Print(tostring(objectives));
		end
]]--



--Take fron questie! Selected seems not to be used
AstroobjectiveProcessors = {
	['item'] = function(quest, name, amount, selected, mapid)
				--DEFAULT_CHAT_FRAME:AddMessage("derp", 0.95, 0.95, 0.5);
		local list = {};
		local itemdata = QuestieItems[name];
		Questie:debug_Print(name);
		if itemdata == nil then
			Questie:debug_Print("ERROR PROCESSING '" .. quest .. "''  objective:'" .. name .. "'' no itemdata");
			itemdata = QuestieItems[name];
		end
		if itemdata then
			for k,v in pairs(itemdata) do
				if k == "locationCount" then
					--WARNING; THIS IS ALL TESTING QUEST TESTED (HANDFUL OF OATS)
					local monster = {};
					monster["name"] = name;
					monster["locations"] = {};
					monster["type"] = "loot";
					for b=1,itemdata['locationCount'] do
						local loc = itemdata['locations'][b];
						table.insert(monster["locations"], loc);
					end
					table.insert(list, monster);
				elseif k == "drop" then
					for e,r in pairs(v) do
						local monster = {};
						monster["name"] = e;
						monster["locations"] = {};
						monster["type"] = "loot";
						for k, pos in pairs(QuestieMonsters[e]['locations']) do
							table.insert(monster["locations"], pos);
						end
						--local monsterdata = QuestRoot['QuestHelper_StaticData']['enUS']['objective']['monster'][e];
						--addMonsterToMap(monsterName, info, quest, selected)

						table.insert(list, monster)
						--Questie:addMonsterToMap(e, name .. " (" .. amount .. ")", quest, "Loot", mapid, selected);
					end
				elseif k =="locations" then

				else
					Questie:debug_Print("ERROR PROCESSING " .. quest .. "  objective:" .. name);
					for s, r in pairs(itemdata) do
						Questie:debug_Print(s,tostring(r));
						
					end
				end
			end
		end
		return list;
	end,
	['event'] = function(quest, name, amount, selected, mapid)
		local evtdata = QuestieEvents[name]
		local list = {};
		if evtdata == nil then
			debug("ERROR UNKNOWN EVENT " .. quest .. "  objective:" .. name);
		else
			--DEFAULT_CHAT_FRAME:AddMessage("VALIDEVT: " .. name, 0.2, 0.95, 0.2);
			for b=1,evtdata['locationCount'] do
				--Old Code
				--local loc = evtdata['locations'][b];
				--if loc[1] == mapid then
					--Questie:createQuestNote(name, quest, "", loc[2], loc[3], "Event", selected);
				--end
				local monster = {};
				monster["name"] = name;
				monster["locations"] = {};
				monster["type"] = "event";
				for b=1,evtdata['locationCount'] do
					local loc = itemdata['locations'][b];
					table.insert(monster["locations"], loc);
				end
				table.insert(list, monster);
			end
		end
		return list;
	end,
	['monster'] = function(quest, name, amount, selected, mapid)
		--DEFAULT_CHAT_FRAME:AddMessage("   MONMON: " .. quest .. ", " .. name .. ", " .. amount, 0.95, 0.2, 0.2);
		--Questie:addMonsterToMap(name, amount, quest, "Slay", mapid, selected);
		--Todo check if both " slain" and without slain works
		local list = {};
		local monster = {};
		if(string.find(name, " slain")) then
			monster["name"] = name;
		else
			monster["name"] = string.sub(name, string.len(name)-6);
		end
		monster["type"] = "slay";
		monster["locations"] = {};
		if(QuestieMonsters[name] and QuestieMonsters[name]['locations']) then
			for k, pos in pairs(QuestieMonsters[name]['locations']) do
				table.insert(monster["locations"], pos);
			end
		end
		table.insert(list, monster);
		return list;
	end,
	['object'] = function(quest, name, amount, selected, mapid)
		local objdata = QuestieObjects[name];
		if objdata == nil then
			debug("ERROR UNKNOWN OBJECT " .. quest .. "  objective:" .. name);
		else
			for b=1,objdata['locationCount'] do
				local loc = objdata['locations'][b];
				if loc[1] == mapid then
					--Questie:createQuestNote(name, quest, "", loc[2], loc[3], "Object", selected);
				end
			end
		end
	end

}

function GetAvailableQuests(levelFrom, levelTo)
	Questie:debug_Print("GetAvailableQuests")
	--QuestieZoneLevelMap
	local mapid = getCurrentMapID();
	local level = UnitLevel("player");
	Questie:debug_Print(mapid, level);
	for l=levelFrom,levelTo do
		if QuestieZoneLevelMap[mapid] then
			local content = QuestieZoneLevelMap[mapid][l];
			if content then
				for k,v in pairs(content) do
					--Questie:debug_Print("content", tostring(k),tostring(v));
					local qdata = QuestieHashMap[v];
					if(qdata) then
						if(qdata['rq'] and QuestieSeenQuests[qdata['rq']]) then
							Questie:debug_Print("level", k, "Name", qdata['name'], "rq:", tostring(QuestieSeenQuests[qdata['rq']]));
						else
							Questie:debug_Print("level", k, "Name", qdata['name']);
						end
					end
				end
			end
		end
	end
end

--End of Astrolabe functions









-- TODO move this into a utils.lua?
RaceBitIndexTable = { -- addressing the indexes directly to make it more clear
	['human'] = 1,
	['orc'] = 2,
	['dwarf'] = 3,
	['nightelf'] = 4,
	['scourge'] = 5,
	['undead'] = 5,
	['tauren'] = 6,
	['gnome'] = 7,
	['troll'] = 8,
	['goblin'] = 9
};

ClassBitIndexTable = {
	['warrior'] = 1,
	['paladin'] = 2,
	['hunter'] = 3,
	['rogue'] = 4,
	['priest'] = 5,
	['shaman'] = 7,
	['mage'] = 8,
	['warlock'] = 9,
	['druid'] = 11
}

function unpackBinary(val)
	-- assume 32 bit
	ret = {};
	for q=0,16 do
		if bit.band(bit.rshift(val,q), 1) == 1 then
			table.insert(ret, true);
		else
			table.insert(ret, false);
		end
	end
	return ret;
end

function checkQuestRequirements(class, dbClass, race, dbRace)
	local valid = nil;
	if class and dbClass then
		local racemap = unpackBinary(dbRace);
		valid = racemap[RaceBitIndexTable[tolower(race)]];
	end
	
	if race and dbRace and (valid == nil or valid == true) then
		local classmap = unpackBinary(dbClass);
		valid = classmap[ClassBitIndexTable[tolower(class)]];
	end
	
	return valid;
end