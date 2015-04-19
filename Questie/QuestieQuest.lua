

function Questie:AstroGetAllCurrentQuestHashes()
	local hashes = {};
  	local numEntries, numQuests = GetNumQuestLogEntries();
	Questie:debug_Print("--Listing all current quests--");
	for i = 1, numEntries do
		local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not isHeader then
		  	SelectQuestLogEntry(i);
		    local count =  GetNumQuestLeaderBoards();
		    local questText, objectiveText = _GetQuestLogQuestText();
		    local quest = {};
		    quest["name"] = q;
		    quest["level"] = level;
		    quest["hash"] = Questie:getQuestHash(q, level, objectiveText);

		    --This uses the addon URLCopy to easily be able to copy the questHashes from the debuglog.
		  	if(IsAddOnLoaded("URLCopy"))then
		  		Questie:debug_Print("        "..q,URLCopy_Link(quest["hash"]));
			else
		  		Questie:debug_Print("        "..q,quest["hash"]);
			end


		    table.insert(hashes, quest);
		else
		  	Questie:debug_Print("    Zone:", q);
		end
	end
	Questie:debug_Print("--End of all current quests--");
	return hashes;
end

--Astrolabe functions DO NOT USE UNLESS YOU KNOW WHAT YOU ARE DOING!!
function Questie:AstroGetFinishedQuests()
  	numEntries, numQuests = GetNumQuestLogEntries();

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
				Questie:debug_Print("Finished returned:", Questie:getQuestHash(q, level, questText))
				return Questie:getQuestHash(q, level, questText);
			end
		end
	end
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
	Questie:debug_Print("ID:", QuestLogID);
	local mapid = getCurrentMapID();
	--Gets Quest information
	local q, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(QuestLogID);
	SelectQuestLogEntry(QuestLogID);
	local count =  GetNumQuestLeaderBoards();
	local questText, objectiveText = _GetQuestLogQuestText();
	for i = 1, count do
		--This returns a quests objectives.
		local desc, typ, done = GetQuestLogLeaderBoard(i);
		--Gets the type
		local typeFunction = AstroobjectiveProcessors[typ];

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
			typeFunction(quest, desc, "", selected, mapid);
		end
	end

end

--Take fron questie! Selected seems not to be used
AstroobjectiveProcessors = {
	['item'] = function(quest, name, amount, selected, mapid)
		--DEFAULT_CHAT_FRAME:AddMessage("derp", 0.95, 0.95, 0.5);
		local list = {};
		local itemdata = QuestieItems[name];
		if itemdata == nil then
			debug("ERROR PROCESSING " .. quest .. "  objective:" .. name);
		else
			for k,v in pairs(itemdata) do
				if k == "locationCount" then
					for b=1,itemdata['locationCount'] do
						local loc = itemdata['locations'][b];
						if loc[1] == mapid then
							--Questie:createQuestNote(name, quest, "", loc[2], loc[3], "Loot", selected);
						end
					end
				elseif k == "drop" then
					for e,r in pairs(v) do
						local monster = {};
						monster["name"] = e;
						monster["locations"] = {};
						for k, pos in pairs(QuestieMonsters[e]['locations']) do
							table.insert(monster["locations"], pos);
						end
						--local monsterdata = QuestRoot['QuestHelper_StaticData']['enUS']['objective']['monster'][e];
						--addMonsterToMap(monsterName, info, quest, selected)

						table.insert(list, monster)
						--Questie:addMonsterToMap(e, name .. " (" .. amount .. ")", quest, "Loot", mapid, selected);
					end
				else
					debug("ERROR PROCESSING " .. quest .. "  objective:" .. name);
				end
			end
		end
		return list;
	end,
	['event'] = function(quest, name, amount, selected, mapid)
		local evtdata = QuestieEvents[name]
		if evtdata == nil then
			debug("ERROR UNKNOWN EVENT " .. quest .. "  objective:" .. name);
		else
			--DEFAULT_CHAT_FRAME:AddMessage("VALIDEVT: " .. name, 0.2, 0.95, 0.2);
			for b=1,evtdata['locationCount'] do
				local loc = evtdata['locations'][b];
				if loc[1] == mapid then
					--Questie:createQuestNote(name, quest, "", loc[2], loc[3], "Event", selected);
				end
			end
		end
	end,
	['monster'] = function(quest, name, amount, selected, mapid)
		--DEFAULT_CHAT_FRAME:AddMessage("   MONMON: " .. quest .. ", " .. name .. ", " .. amount, 0.95, 0.2, 0.2);
		--Questie:addMonsterToMap(name, amount, quest, "Slay", mapid, selected);
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