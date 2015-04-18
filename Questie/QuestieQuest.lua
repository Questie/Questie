



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
--Questie:AstroGetQuestObjectives(1607748502)
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
	--SelectQuestLogEntry(QuestLogID);
	--local count =  GetNumQuestLeaderBoards();
	--local questText, objectiveText = _GetQuestLogQuestText();
	--for i = 1, count do
	--	local desc, typ, done = GetQuestLogLeaderBoard(i);
	--	Questie:debug_Print(desc,typ,done);
	--end

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