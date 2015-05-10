

--THIS IS THE FUNCTION TO USE!
LastQuestLogHashes = nil;
LastQuestLogCount = 0;
LastCount = 0;
function Questie:CheckQuestLog()
	local numEntries, numQuests = GetNumQuestLogEntries();
	if(LastCount == numEntries) then
		Questie:debug_Print("[CheckLog] Checking questlog: Nothing changed");
	--return;
	end
	LastCount = numEntries;
	local t = GetTime();
	if(not LastQuestLogHashes) then
		LastQuestLogHashes = Questie:AstroGetAllCurrentQuestHashesAsMeta();
		Questie:debug_Print("[CheckLog] First check run, adding all quests");
		for k, v in pairs(LastQuestLogHashes) do
			Questie:AddQuestToMap(v["hash"]);
			if(not QuestieSeenQuests[v["hash"]]) then
				Questie:debug_Print("[CheckLog] Adding quest to seen quests:", v["name"],v["hash"]," setting as 0");
				QuestieSeenQuests[v["hash"]] = 0
			end
		end
		Questie:RedrawNotes();
		return;
	end
	local Quests, QuestsCount = Questie:AstroGetAllCurrentQuestHashesAsMeta();
	MapChanged = false;
	delta = {};
	if (QuestsCount > LastQuestLogCount) then
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
			Questie:debug_Print("[CheckLog] Check discovered a new quest,".. v["name"]);
			Questie:AddQuestToMap(v["hash"]);
			if(not QuestieSeenQuests[v["hash"]]) then
				QuestieSeenQuests[v["hash"]] = 0
			end
			MapChanged = true;
		elseif not Questie.collapsedThisRun then
			Questie:debug_Print("[CheckLog] Check discovered a missing quest, removing! ".. v["hash"].." "..v["name"])
			Questie:RemoveQuestFromMap(v["hash"]);
			QuestieTracker:removeQuestFromTracker(v["hash"]);
			if(not QuestieCompletedQuestMessages[v["name"]]) then
				QuestieCompletedQuestMessages[v["name"]] = 0;
			end
			if(not QuestieSeenQuests[v["hash"]]) then
				Questie:debug_Print("[CheckLog] Adding quest to seen quests:", v["name"],v["hash"]," setting as 0");
				QuestieSeenQuests[v["hash"]] = 0
			end
			if lastObjectives and lastObjectives[v["hash"]] then --- this throws nil error attempting to index "nil global lastObjectives"
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
		Questie:SetAvailableQuests();
		Questie:RedrawNotes();
	end
	LastQuestLogHashes = Quests;
	LastQuestLogCount = QuestsCount;
	Questie:debug_Print("[CheckLog] Checklog done: Time:",tostring((GetTime()-t)*1000).."ms");
	if(MapChanged == true) then
		return true;
	else
		return nil;
	end
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
				change = c;
				if(c and not force)then
					break;
				end
			end
		end
	else
	--Questie:debug_Print("Found change in current zone, good!");
	end
	Questie:debug_Print("[UpdateQuests] Updated quests: Time:", tostring((GetTime()-t)*1000).."ms","Zones:"..ZonesChecked)
	return change;
end

function Questie:UpdateQuestInZone(Zone, force)
	local numEntries, numQuests = GetNumQuestLogEntries();
	--DEFAULT_CHAT_FRAME:AddMessage("UpdateQuestInZone");
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
			if QuestieHashCache[q] == nil then QuestieHashCache[q] = {}; end
			QuestieHashCache[q][hash] = GetTime();
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
				Questie:debug_Print("[UpdateQuestInZone] Update: Something has changed, need to refresh:", hash);
				Questie:AddQuestToMap(hash, true);

				QuestieTracker:updateFrameOnTracker(hash, i, level)
				QuestieTracker:fillTrackingFrame()
			elseif foundChange then
				QuestieTracker:updateFrameOnTracker(hash, i, level)
				QuestieTracker:fillTrackingFrame()
			end
		end
		if(foundChange and not force) then
			Questie:debug_Print("[UpdateQuestInZone] Found a change!")
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

Questie.lastCollapsedCount = 0;
Questie.collapsedThisRun = false;

function Questie:AstroGetAllCurrentQuestHashesAsMeta(print)
	local startTime = GetTime();
	local hashes = {};
	local Count = 0;
	local numEntries, numQuests = GetNumQuestLogEntries();
	local collapsedCount = 0;
	Questie.collapsedThisRun = false;
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if isCollapsed then collapsedCount = collapsedCount + 1; end
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
	if not (collapsedCount == Questie.lastCollapsedCount) then
		Questie.lastCollapsedCount = collapsedCount;
		Questie.collapsedThisRun = true;
	end
	Questie:debug_Print("[AllCurrentHashes] Getting all hashes took: ",(GetTime()-startTime)*1000, "ms");
	return hashes, numQuests;
end


--Cache information for the function below
LastNrOfEntries = 0;
CachedIds = {};
function Questie:GetQuestIdFromHash(questHash)
	local numEntries, numQuests = GetNumQuestLogEntries();
	if(numEntries ~= LastNrOfEntries or not CachedIds[questHash]) then
		CachedIds = {};
		LastNrOfEntries = numEntries;


		Questie:UpdateQuestIds();

		--Questie:debug_Print("Got QuestID from Hash - Time: " .. (GetTime()-startTime)*1000 .. "ms");
		if CachedIds[questHash] then
			return CachedIds[questHash];
		end
	else
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(CachedIds[questHash]);
		SelectQuestLogEntry(CachedIds[questHash]);
		local questText, objectiveText = _GetQuestLogQuestText();
		if(q and level and objectiveText) then
			if(Questie:getQuestHash(q, level, objectiveText) == questHash) then
				return CachedIds[questHash];
			else
				Questie:debug_Print("[GetQuestIdFromHash] Something went wrong Error1");
			end
		else
			Questie:debug_Print("[GetQuestIdFromHash] Something went wrong, Error2", tostring(CachedIds[questHash]), tostring(q), tostring(level));
		end
	end
end

function Questie:UpdateQuestIds()
	local startTime = GetTime()
	local numEntries, numQuests = GetNumQuestLogEntries();
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
			SelectQuestLogEntry(i);
			local questText, objectiveText = _GetQuestLogQuestText();
			local hash = Questie:getQuestHash(q, level, objectiveText);
			if(not q or not level or not objective) then
				Questie:debug_Print("[UpdateQuestID] ERROR!!!!  Error1",tostring(name), tostring(level), tostring(i), tostring(hash))
			end
			CachedIds[hash] = i;
		end
	end
	Questie:debug_Print("[UpdateQuestID] Had to update UpdateQuestIds",(GetTime() - startTime)*1000,"ms")
end

QuestieHashCache = {};

function Questie:GetHashFromName(name)
	if QuestieHashCache[name] then
		local hashtable = QuestieHashCache[name];
		local bestValue = 0;
		local bestHash = -1;
		for k,v in pairs(hashtable) do
			if v > bestValue then
				bestValue = v;
				bestHash = k;
			end
		end
		if not (bestHash == -1) then return bestHash; end
	end

	--- I don't like the idea of it falling back to this but I dont think theres any option
	Questie:debug_Print("NO KNOWN HASH FOR ", name, " FALLING BACK TO LEGACY (DANGEROUS)");
	return Questie:getQuestHash(name, nil, nil);
end


--The reason IsQuestFinished and getFinished quest basiclly have the same code is because they return different things... i need both!
--Astrolabe functions DO NOT USE UNLESS YOU KNOW WHAT YOU ARE DOING!!
function Questie:IsQuestFinished(questHash)
	local i = Questie:GetQuestIdFromHash(questHash);
	local FinishedQuests = {};
	local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
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
				local hash = Questie:getQuestHash(q, level, objectiveText);
				Questie:debug_Print("[AstroGetFinishedQuests] Finished returned:", hash, q ,level);
				table.insert(FinishedQuests, hash);
			end
		end
	end
	return FinishedQuests;
end
--Questie:AstroGetQuestObjectives(1431546316)
function Questie:AstroGetQuestObjectives(questHash)
	--[[local hashData = QuestieHashMap[questHash];

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

	end]]--

	QuestLogID = Questie:GetQuestIdFromHash(questHash);
	local mapid = getCurrentMapID();
	--Gets Quest information
	local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(QuestLogID);
	SelectQuestLogEntry(QuestLogID);
	local count =  GetNumQuestLeaderBoards();
	local questText, objectiveText = _GetQuestLogQuestText();
	local AllObjectives = {};
	AllObjectives["QuestName"] = q;
	AllObjectives["objectives"] = {};
	--DEFAULT_CHAT_FRAME:AddMessage("C:"..count.." Q:"..q.." L:"..level);  --NotWORKING debug
	for i = 1, count do
		--This returns a quests objectives.
		local desc, typ, done = GetQuestLogLeaderBoard(i);
		--Gets the type
		local typeFunction = AstroobjectiveProcessors[typ];
		--DEFAULT_CHAT_FRAME:AddMessage("Func:"..tostring(typeFunction)); --NotWORKING debug
		if typ == "item" or typ == "monster" or not (typeFunction == nil) then
			local indx = findLast(desc, ":");
			local countless = indx == nil;
			--DEFAULT_CHAT_FRAME:AddMessage(indx, 0.95, 0.95, 0.5);
			local countstr = "";
			local namestr = desc;
			--if countless then DEFAULT_CHAT_FRAME:AddMessage("lol" .. namestr); else DEFAULT_CHAT_FRAME:AddMessage("olo" .. namestr); end
			if not countless then
				countstr = string.sub(desc, indx+2);
				namestr = string.sub(desc, 1, indx-1);
			end
			--AllObjectives["type"] = typ;
			--Questie:debug_Print("[AstroGetQuestObjectives]", tostring(q), tostring(namestr), tostring(countstr), tostring(selected), tostring(mapid))
			local objectives = typeFunction(q, namestr, countstr, selected, mapid);
			--DEFAULT_CHAT_FRAME:AddMessage("Count:"..table.getn(objectives)); --NotWORKING debug

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
					--DEFAULT_CHAT_FRAME:AddMessage("Adding Objective!"); --NotWORKING debug
					table.insert(AllObjectives["objectives"][v["name"]], obj);
				end
			end
		else

		end
	end
	--for name, locations in pairs(AllObjectives['objectives']) do
	--	for k, location in pairs(locations) do
	--Questie:debug_Print(name,location.mapid, location.x, location.y);
	--	end
	--end
	--Questie:debug_Print(AllObjectives['type'], AllObjectives['objectives'][1].name)
	--DEFAULT_CHAT_FRAME:AddMessage("Size: "..table.getn(AllObjectives)); --NotWORKING debug
	return AllObjectives;
end
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
			Questie:debug_Print("[AstroobjectiveProcessors] ERROR1 PROCESSING '" .. quest .. "''  objective:'" .. name .. "'' no itemdata".. " ID:0");
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
					Questie:debug_Print("[AstroobjectiveProcessors] ERROR2 " .. quest .. "  objective:" .. name.. " ID:1");
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
			Questie:debug_Print("[AstroobjectiveProcessors] ERROR3 UNKNOWN EVENT " .. quest .. "  objective:" .. name.. " ID:2");
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
					local loc = evtdata['locations'][b];
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


		local list = {};
		local objdata = QuestieObjects[name];
		if objdata == nil then
			Questie:debug_Print("[AstroobjectiveProcessors] ERROR4 UNKNOWN OBJECT " .. quest .. "  objective:" .. name);

		else
			--DEFAULT_CHAT_FRAME:AddMessage("VALIDEVT: " .. name, 0.2, 0.95, 0.2);
			for b=1,objdata['locationCount'] do
				--Old Code
				--local loc = evtdata['locations'][b];
				--if loc[1] == mapid then
				--Questie:createQuestNote(name, quest, "", loc[2], loc[3], "Event", selected);
				--end
				local monster = {};
				monster["name"] = name;
				monster["locations"] = {};
				monster["type"] = "object";
				for b=1,objdata['locationCount'] do
					local loc = objdata['locations'][b];
					table.insert(monster["locations"], loc);
				end
				table.insert(list, monster);
			end
		end
		return list;
	end

}


--End of Astrolabe functions









RaceBitIndexTable = { -- addressing the indexes directly to make it more clear
	['human'] = 1,
	['orc'] = 2,
	['dwarf'] = 3,
	['nightelf'] = 4,
	['night elf'] = 4,
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
	-- assume 16 bit
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
function checkRequirements(class, race, dbClass, dbRace)
	local valid = true;
	--DEFAULT_CHAT_FRAME:AddMessage("CHCK" .. race .. class);
	--if dbClass then DEFAULT_CHAT_FRAME:AddMessage("CHCKR" .. dbClass); end
	--if dbRace then DEFAULT_CHAT_FRAME:AddMessage("CHCKR" .. dbRace); end
	if race and dbRace and not (dbRace == 0) then
		--DEFAULT_CHAT_FRAME:AddMessage("CHCKR");
		local racemap = unpackBinary(dbRace);

		valid = racemap[RaceBitIndexTable[strlower(race)]];

	end

	if class and dbClass and valid and not (dbRace == 0)then
		--DEFAULT_CHAT_FRAME:AddMessage("CHCKC");
		local classmap = unpackBinary(dbClass);
		valid = classmap[ClassBitIndexTable[strlower(class)]];
	end

	return valid;
end

function Questie:GetAvailableQuestHashes(mapFileName, levelFrom, levelTo)
	--Questie:debug_Print("GetAvailableQuests")
	local mapid =  -1
	if(QuestieZones[mapFileName]) then
		mapid = QuestieZones[mapFileName][1];
	end
	--QuestieZoneLevelMap
	local class = UnitClass("Player"); -- should be set globally
	local race = UnitRace("Player"); -- should be set globally
	--Questie:debug_Print(mapid, level);
	local hashes = {};
	for l=levelFrom,levelTo do
		if QuestieZoneLevelMap[mapid] then
			local content = QuestieZoneLevelMap[mapid][l];
			if content then
				for k,v in pairs(content) do
					--Questie:debug_Print("content", tostring(k),tostring(v));
					local qdata = QuestieHashMap[v];
					--table.insert(hashes, v);
					if(qdata) then

						local requiredQuest = qdata['rq'];
						local requiredRaces = qdata['rr'];
						local requiredClasses = qdata['rc'];
						local requiredSkill = qdata['rs'];
						local valid = not QuestieSeenQuests[requiredQuest];-- THIS IS LIKELY INCORRECT NOT SURE HOW QUESTIESEENQUESTS WORKS NOW

						if(requiredQuest) then valid = QuestieSeenQuests[requiredQuest]; end-- THIS IS LIKELY INCORRECT NOT SURE HOW QUESTIESEENQUESTS WORKS NOW

						valid = valid and requiredSkill == nil;

						--(class, race, dbClass, dbRace)
						if valid then valid = valid and checkRequirements(class, race, requiredClasses,requiredRaces); end

						if valid and not QuestieHandledQuests[requiredQuest] and not QuestieSeenQuests[v] then
							table.insert(hashes, v);
						end
					end
				end
			end
		end
	end
	return hashes;
end
