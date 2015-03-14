DEFAULT_CHAT_FRAME:AddMessage("load", 0.95, 0.95, 0.5);
local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

Questie = CreateFrame("Frame", "QuestieLua", UIParent, "ActionButtonTemplate")
Questie.TimeSinceLastUpdate = 0
Questie.lastMinimapUpdate = 0
Questie.needsUpdate = false;
currentQuests = {};
selectedNotes = {};

function Questie:OnEvent() -- functions created in "object:method"-style have an implicit first parameter of "this", which points to object || in 1.12 parsing arguments as ... doesn't work
	Questie[event](arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- route event parameters to Questie:event methods
end
Questie:SetScript("OnEvent", Questie.OnEvent)

local _GetQuestLogQuestText;
local objectives = {};
local throttle = 0;
local throttleOverride = false;

function nql()
	--DEFAULT_CHAT_FRAME:AddMessage("QUESTTEXT", 0.95, 0.95, 0.5);
	Questie.needsUpdate = true;
	return _GetQuestLogQuestText();
end


function Questie:OnUpdate(elapsed)
	this = Questie
	if Questie.needsUpdate then
		Questie.needsUpdate = false;
		Questie.throttleOverride = true;
		Questie:QUEST_LOG_UPDATE();
	end
	local ttl = GetTime() - Questie.lastMinimapUpdate;
	if ttl > 3 then -- 3 seconds
		Questie:pickNearestPOI();
		Questie.lastMinimapUpdate = GetTime();
	end	
end

function Questie:PLAYER_LOGIN()
	--log(this:GetName())
	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("UNIT_AURA")
end

function Questie:UNIT_AURA(unitId)
	--log("UnitID: "..unitId)
end

function Questie:PLAYER_ENTERING_WORLD()
	currentQuests = {};
	this:fillQuestList();
	_GetQuestLogQuestText = GetQuestLogQuestText;
	GetQuestLogQuestText = nql;
	this:clearAllNotes();
end

function Questie:createQuestNote(name, progress, questName, x, y, icon, selected)
	--local id, key = MapNotes_CreateQuestNote(name, lin, olin, x, y, icon, selected)
	--DEFAULT_CHAT_FRAME:AddMessage(icon)
	local zone = Cartographer:GetCurrentEnglishZoneName();
	local _, id, key = Cartographer_Notes:SetNote(zone, x, y, icon, "Questie", "info", progress, "info2", questName, "title", name)
	if selected and not (icon == 4) then
		table.insert(selectedNotes, {
			['name'] = name,
			['x'] = x,
			['y'] = y,
			['id'] = id,
			['icon'] = icon,
			['key'] = key
		});
	end
	if (questName == "") then 
		questName = progress; 
	end
	if(currentQuests[questName] ~= nil) then
		if(type(currentQuests[questName]["notes"]) ~= "table") then
			currentQuests[questName]["notes"] = {}
		end
		--log("adding notes to quest list for quest "..questName)
		currentQuests[questName]["notes"][id] = {
			['name'] = name,
			['x'] = x,
			['y'] = y,
			['id'] = id,
			['icon'] = icon,
			['key'] = key,
			['zone'] = zone
		};
	end
end

function distance(x, y, px, py)
	return math.abs(x-px) + math.abs(y-py);
end

function Questie:addMonsterToMap(monsterName, info, quest, icon, mapid, selected)
	local monsterdata = QuestieMonsters[monsterName];
	if not (monsterdata == nil) then
		for b=1,monsterdata['locationCount'] do -- this should be made more efficient (monsterdata[mapid][locations] etc
			local loc = monsterdata['locations'][b];
			if loc[1] == mapid then
				this:createQuestNote(monsterName, info, quest, loc[2], loc[3], icon, selected);
			end
		end
	end
end

function Questie:pickNearestPOI()
	local fx, fy = GetPlayerMapPosition("player");
	local least = 8; -- biggest distance possible is 2.0 but oh well
	local best;
	for k,v in pairs(selectedNotes) do 
		local dist = distance(fx, fy, v['x'], v['y']);
		if dist < least then
			least = dist;
			best = v;
		end
		--DEFAULT_CHAT_FRAME:AddMessage("pickNearestPOI" .. v['name'], 0.95, 0.95, 0.5);
	end
	if not (best == nil) then
		--MapNotes_setMiniPoint(best['id'], best['x'], best['y'], best['key'], best['name'], best['icon']);
	end
	--DEFAULT_CHAT_FRAME:AddMessage("pickNearestPOI", 0.95, 0.95, 0.5);
end

function Questie:clearAllNotes()
	selectedNotes = {}
	Cartographer_Notes:ClearMap();
end

function getCurrentMapID()

	-- thanks to mapnotes for this "bug fix"
	local fx, fy = GetPlayerMapPosition("player");
	if ( ( ( fx ) and ( fx == 0 ) ) and ( ( fy ) and ( fy == 0 ) ) ) then
		SetMapToCurrentZone();
	end
	-- thanks mapnotes


	local file = GetMapInfo()
	
	if file == nil then -- thanks optim for finding a null bug here
		return -1
	end
	
	local zid = QuestieZones[file];
	if zid == nil then
		DEFAULT_CHAT_FRAME:AddMessage("ERROR: We are in unknown zone " .. file, 0.95, 0.2, 0.2);
		return -1
	else
		return zid[1];
	end
end

objectiveProcessors = {
	['item'] = function(quest, name, amount, selected, mid)
		--DEFAULT_CHAT_FRAME:AddMessage("derp", 0.95, 0.95, 0.5);
		local itemdata = QuestieItems[name];
		if itemdata == nil then
			--DEFAULT_CHAT_FRAME:AddMessage("ERROR PROCESSING " .. name, 0.95, 0.2, 0.2);
		else
			for k,v in pairs(itemdata) do
				--DEFAULT_CHAT_FRAME:AddMessage(k, 0.95, 0.95, 0.5);
				--DEFAULT_CHAT_FRAME:AddMessage(v, 0.95, 0.95, 0.5);
				if k == "locationCount" then
					for b=1,itemdata['locationCount'] do
						local loc = itemdata['locations'][b];
						if loc[1] == mid then
							Questie:createQuestNote(name, quest, "", loc[2], loc[3], "Star", selected);
						end
					end
				elseif k == "drop" then
					for e,r in pairs(v) do
						--DEFAULT_CHAT_FRAME:AddMessage(e .. " drops " .. name .. " for " .. quest, 0.95, 0.95, 0.5);
						--local monsterdata = QuestRoot['QuestHelper_StaticData']['enUS']['objective']['monster'][e];
						--addMonsterToMap(monsterName, info, quest, selected)
						Questie:addMonsterToMap(e, name .. " (" .. amount .. ")", quest, "Skull", mid, selected);
					end
				end
			end
		end
	end,
	['event'] = function(quest, name, amount, selected, mid)
		local evtdata = QuestieEvents[name]
		if evtdata == nil then
			--DEFAULT_CHAT_FRAME:AddMessage("ERROR: UNKNOWN EVENT: " .. name, 0.95, 0.2, 0.2);
		else
			--DEFAULT_CHAT_FRAME:AddMessage("VALIDEVT: " .. name, 0.2, 0.95, 0.2);
			for b=1,evtdata['locationCount'] do
				local loc = evtdata['locations'][b];
				if loc[1] == mid then
					Questie:createQuestNote(name, quest, "", loc[2], loc[3], "Star", selected);
				end
			end
		end
	end,
	['monster'] = function(quest, name, amount, selected, mid)
		--DEFAULT_CHAT_FRAME:AddMessage("   MONMON: " .. quest .. ", " .. name .. ", " .. amount, 0.95, 0.2, 0.2);
		Questie:addMonsterToMap(name, amount, quest, "Skull", mid, selected);
	end,
	['object'] = function(quest, name, amount, selected, mid)
		local objdata = QuestieObjects[name];
		if objdata == nil then
			-- error message 
		else
			for b=1,objdata['locationCount'] do
				local loc = objdata['locations'][b];
				if loc[1] == mid then
					Questie:createQuestNote(name, quest, "", loc[2], loc[3], "Star", selected);
				end
			end
		end
	end

}

function Questie:getQuestFinisherByName(name)

end

function findLast(haystack, needle)
    local i=string.gfind(haystack, ".*"..needle.."()")()
    if i==nil then return nil else return i-1 end
end

function processObjective(quest, desc, typ, selected, mid)
	--DEFAULT_CHAT_FRAME:AddMessage(desc, 0.95, 0.95, 0.5);
	local ref = objectiveProcessors[typ];
	
	if not (ref == nil) then
		--DEFAULT_CHAT_FRAME:AddMessage("HANDLED TYPE: " .. typ .. " for quest " .. quest, 0.2, 0.95, 0.95);
		if typ == "item" or typ == "monster" then
			local indx = findLast(desc, ":");
			--DEFAULT_CHAT_FRAME:AddMessage(indx, 0.95, 0.95, 0.5);
			local countstr = string.sub(desc, indx+2);
			local namestr = string.sub(desc, 1, indx-1);
			ref(quest, namestr, countstr, selected, mid);
		else
			ref(quest, desc, "", selected, mid);
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("ERROR: UNHALDNED TYPE: " .. typ .. " \"" .. desc .. "\" for quest " .. quest, 0.95, 0.2, 0.2);
	end
end

function getQuestHashByName(name)
	return QuestieHashes[name];
end

function fank()
	DEFAULT_CHAT_FRAME:AddMessage("fank", 0.95, 0.55, 0.2);
end

function Questie:QUEST_LOG_UPDATE()
	this:deleteNoteAfterQuestRemoved()
		
	local sind = GetQuestLogSelection();
	local mid = getCurrentMapID();
	if not throttleOverride then
		if throttle == math.floor(GetTime()) then
			return
		else
			throttle = math.floor(GetTime())
		end
	else
		throttleOverride = false;
	end
	
	--DEFAULT_CHAT_FRAME:AddMessage(throttle, 0.95, 0.95, 0.5);
	this:clearAllNotes();
	local numEntries, numQuests = GetNumQuestLogEntries()
	--DEFAULT_CHAT_FRAME:AddMessage(numEntries .. " entries containing " .. numQuests .. " quests in your quest log.");
	for v=1,numEntries do
		local q = GetQuestLogTitle(v);
		if not (getQuestHashByName(q) == nil) then
				SelectQuestLogEntry(v);
			local count =  GetNumQuestLeaderBoards();
			
			local selected = v == sind;
			
			local finisher = QuestieFinishers[q];
			
			local questComplete = true; -- there might be something in the api for this
					
			if not (finisher == nil) and (count == 0) then
				Questie:addMonsterToMap(finisher, "Quest Finisher", q, "Skull", mid, selected);
				questComplete = false; -- questComplete is used to add the finisher, this avoids adding it twice
			end
			--DEFAULT_CHAT_FRAME:AddMessage(q);
			for r=1,count do
				local desc, typ, done = GetQuestLogLeaderBoard(r);
				--DEFAULT_CHAT_FRAME:AddMessage(desc, 0.95, 0.95, 0.5);
				
				
				if not done then
					questComplete = false;
					if selected then
						--DEFAULT_CHAT_FRAME:AddMessage("SELECTED " .. q, 0.95, 0.1, 0.95);
					else
						--DEFAULT_CHAT_FRAME:AddMessage("NOTSELECTEd " .. q .. " " .. in, 0.95, 0.1, 0.95);
					end
					processObjective(q, desc, typ, selected, mid)
				end
				---DEFAULT_CHAT_FRAME:AddMessage(typ, 0.95, 0.95, 0.5);
				---DEFAULT_CHAT_FRAME:AddMessage(done, 0.95, 0.95, 0.5);
				
			end
			if not (finisher == nil) and questComplete then
				Questie:addMonsterToMap(finisher, "Quest Finisher", q, "Skull", mid, selected);
			end
			--DEFAULT_CHAT_FRAME:AddMessage(hash);
		else
			--DEFAULT_CHAT_FRAME:AddMessage("ERROR: UNKNOWN QUEST: " .. q, 0.95, 0.55, 0.2);
		end
	end
	SelectQuestLogEntry(sind);
end

function Questie:deleteNoteAfterQuestRemoved()
	local finishedQuest = this:getFinishedQuest();
	if (finishedQuest ~= nil) then
		--log("finished or abandoned quest " .. finishedQuest)
		for k,v in pairs(currentQuests[finishedQuest]["notes"]) do
			--log(v["zone"] .. "  " .. v["x"] .. "  " .. v["y"])
			Cartographer_Notes:DeleteNote(v["zone"], v["x"], v["y"]);
		end
		--log("Deleting notes for quest:" .. finishedQuest);
		currentQuests[finishedQuest] = nil;
	end
end

function Questie:getFinishedQuest()
	this:validateQuestList();
	for k,v in pairs(currentQuests) do
		if (v['status'] == false) then
			return k;
		end
	end
end

function Questie:fillQuestList()
	for i=1, GetNumQuestLogEntries() do
		local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i);
		if not (isHeader) then
			if(type(currentQuests[questLogTitleText]) ~= "table") then
				currentQuests[questLogTitleText] = {}
			end
			currentQuests[questLogTitleText]['status'] = true;
			--log("setting " .. GetQuestLogTitle(i) .. " true");
		end
	end
end

function Questie:validateQuestList()
	for k,v in pairs(currentQuests) do
		v['status'] = false;
		--log("setting "..k.." to false");
	end
	
	this:fillQuestList();
end