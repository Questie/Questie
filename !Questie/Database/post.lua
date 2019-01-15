QuestieZoneLevelMap = {
}
Questie_DropLookup = {
}
Questie_NPCLookup = {
}
Questie_ObjectLookup = {
}
local start = GetTime();
-- [id] = 
--      {name, 
--          {requiredQuestID, followupQuestID,requiredRace,requiredClass,requiredSkill,requredSkillValue,requredRep,requredRepValue},
--          {minLevel, questLevel},
--          {startedType,startedId,endType,endID}
--          {rewardGold,rewardGoldNoExp}
--          {objective...} (objective = {type,id,quantity})
--          reward data
local goodCount = 0;
local badCount = 0;
local goodCount_npc = 0;
local badCount_npc = 0;
local goodCount_obj = 0;
local badCount_obj = 0;
--Questie_Drops={
--[12289]={"Sea Turtle Remains",{4681,4722,4727,4732},{},{12681,12681,12681,12681}},

for k,v in pairs(Questie_Drops) do
	Questie_DropLookup[v[1]] = k;
	for e,r in pairs(v[3]) do
		local npc = Questie_NPCSpawns[r];
		if npc then
			if not npc['drops'] then
				npc['drops'] = {};
			end
			npc['drops'][v[1]] = k;
			goodCount_npc = goodCount_npc + 1;
		else
			--DEFAULT_CHAT_FRAME:AddMessage("Npc not found! " .. r ..  " (drops " .. v[1] .. ")");
			badCount_npc = badCount_npc + 1;
		end
	end
	for e,r in pairs(v[4]) do
		local obj = Questie_ObjSpawns[r];
		if obj then
			if not obj['drops'] then
				obj['drops'] = {};
			end
			obj['drops'][v[1]] = k;
			goodCount_obj = goodCount_obj + 1;
		else
			badCount_obj = badCount_obj + 1;
			--DEFAULT_CHAT_FRAME:AddMessage("Obj not found! " .. r ..  " (drops " .. v[1] .. ")");
		end
	end
end

for k,v in pairs(Questie_ObjSpawns) do
	Questie_ObjectLookup[v[1]] = k;
end

for k,v in pairs(Questie_NPCSpawns) do
	Questie_NPCLookup[v[1]] = k;
end

for k,v in pairs(Questie_Meta) do
	local reqQ = v[2][1];
	local reqR = v[2][3];
	local reqC = v[2][4];
	
	local minLvl = v[3][1];
	
	local sType = v[4][1];
	local sID = v[4][2];
	
	local startSpawn = nil;
	
	local mapid = -1;
	
	-- some quests dont include requiredQuest properly in mangosDB, they are restricted by followupQuest, copy the data anyway because questie expects accuracy
	local foQ = v[2][2];
	if not(foQ == 0) then
		if(Questie_Meta[foQ][2][1] == 0) then
			Questie_Meta[foQ][2][1] = k;
		end
	end
	
	
	if(sType == 1) then
		local dat = Questie_NPCSpawns[sID];
		if not (dat == nil) then
			startSpawn = dat[2][1];
			mapid = startSpawn[3];
			goodCount = goodCount + 1;
		else
			--DEFAULT_CHAT_FRAME:AddMessage("Error getting starter data for quest " .. v[1] .. "  missing npc data for ID " .. sID);
			badCount = badCount + 1;
		end
	elseif(sType == 2) then
		local dat = Questie_ObjSpawns[sID];
		if not (dat == nil) then
			startSpawn = dat[2][1];
			mapid = startSpawn[3];
			goodCount = goodCount + 1;
		else
			--DEFAULT_CHAT_FRAME:AddMessage("Error getting starter data for quest " .. v[1] .. "  missing npc data for ID " .. sID);
			badCount = badCount + 1;
		end
	end
	
	if (not (mapid == -1)) and not (string.find(v[1], " the Elder")) then -- hack to remove elder quest spam
		if QuestieZoneLevelMap[mapid] == nil then
			QuestieZoneLevelMap[mapid] = {};
		end
		if QuestieZoneLevelMap[mapid][minLvl] == nil then
			QuestieZoneLevelMap[mapid][minLvl] = {};
		end
		table.insert(QuestieZoneLevelMap[mapid][minLvl], k);
	end
	
end

local ttl = GetTime() - start;
DEFAULT_CHAT_FRAME:AddMessage("Compiled QuestieDB in " .. math.floor(ttl*1000) .. "ms. " .. (goodCount+badCount+goodCount_npc+badCount_npc+goodCount_obj+badCount_obj) .. " total objects");
DEFAULT_CHAT_FRAME:AddMessage("Quests: (good=" .. goodCount .. ",bad=" .. badCount .. "),NPCs: (good="..goodCount_npc..",bad="..badCount_npc.."),Objs: (good="..goodCount_obj..",bad="..badCount_obj..")");
