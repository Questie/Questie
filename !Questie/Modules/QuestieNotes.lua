---------------------------------------------------------------------------------------------------
-- Name: QuestieNotes
-- Description: Handles all the quest map notes
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
-- Global Vars
---------------------------------------------------------------------------------------------------
local Astrolabe = DongleStub("Astrolabe-0.4")
NOTES_DEBUG = true; --Set to nil to not get debug shit
--Contains all the frames ever created, this is not to orphan any frames by mistake...
local AllFrames = {};
--Contains frames that are created but currently not used (Frames can't be deleted so we pool them to save space);
local FramePool = {};
QUESTIE_NOTES_MAP_ICON_SCALE = 1.2;-- Zone
QUESTIE_NOTES_WORLD_MAP_ICON_SCALE = 0.75;--Full world shown
QUESTIE_NOTES_CONTINENT_ICON_SCALE = 1;--Continent Shown
QUESTIE_NOTES_MINIMAP_ICON_SCALE = 1.0;
QuestieUsedNoteFrames = {};
QuestieHandledQuests = {};
QuestieCachedMonstersAndObjects = {};
---------------------------------------------------------------------------------------------------
-- WoW Functions --PERFORMANCE CHANGE--
---------------------------------------------------------------------------------------------------
local QGet_QuestLogTitle = GetQuestLogTitle;
local QGet_NumQuestLeaderBoards = GetNumQuestLeaderBoards;
local QSelect_QuestLogEntry = SelectQuestLogEntry;
local QGet_QuestLogLeaderBoard = GetQuestLogLeaderBoard;
local QGet_QuestLogQuestText = GetQuestLogQuestText;
local QGet_TitleText = GetTitleText;

---------------------------------------------------------------------------------------------------
-- Updates all icons' scale
---------------------------------------------------------------------------------------------------
function Questie:UpdateIconScale()
	QUESTIE_NOTES_MAP_ICON_SCALE =  1.2 * QuestieConfig.iconScale;
	QUESTIE_NOTES_WORLD_MAP_ICON_SCALE = 0.75 * QuestieConfig.iconScale;
	QUESTIE_NOTES_CONTINENT_ICON_SCALE = 1 * QuestieConfig.iconScale;
	QUESTIE_NOTES_MINIMAP_ICON_SCALE = 1.0 * QuestieConfig.iconScale;
end

---------------------------------------------------------------------------------------------------
-- Adds quest notes to map
---------------------------------------------------------------------------------------------------
function Questie:AddQuestToMap(questHash, redraw)
	if(Active == false) then
		return;
	end
	Questie:RemoveQuestFromMap(questHash);
	Objectives = Questie:AstroGetQuestObjectives(questHash);
	--Cache code
	local ques = {};
	ques["noteHandles"] = {};
	UsedContinents = {};
	UsedZones = {};
	local Quest = Questie:IsQuestFinished(questHash);
	if not (Quest) then
		for name, locations in pairs(Objectives['objectives']) do
			for k, location in pairs(locations) do
				--This checks if just THIS objective is done (Data is not super efficient but it's nil unless set so...)
				if not location.done then
					local MapInfo = Questie:GetMapInfoFromID(location.mapid);
					if MapInfo then
						local notehandle = {};
						notehandle.c = MapInfo[4];
						notehandle.z = MapInfo[5];
						Questie:AddNoteToMap(MapInfo[4], MapInfo[5], location.x, location.y, location.type, questHash, location.objectiveid);
						if not UsedContinents[MapInfo[4]] and not UsedZones[MapInfo[5]] then
							UsedContinents[MapInfo[4]] = true;
							UsedZones[MapInfo[5]] = true;
							table.insert(ques["noteHandles"], notehandle);
						end
					end
				end
			end
		end
	else
		local finisher = nil;
		if( Questie_Meta[Quest["questHash"]] ) then
			finisher = Questie_Meta[Quest["questHash"]][4][4];
			if(Questie_Meta[Quest["questHash"]][4][3] == 1) then
				finisher = Questie_NPCSpawns[finisher];
			else
				finisher = Questie_ObjSpawns[finisher];
			end
		end
		if (finisher and finisher[2][1]) then
			local MapInfo = Questie:GetMapInfoFromID(finisher[2][1][3]);--Map id is at ID 1, i then convert this to a useful continent and zone
			if MapInfo then
				local c, z, x, y = MapInfo[4], MapInfo[5], finisher[2][1][1],finisher[2][1][2]-- You just have to know about this, 2 is x 3 is y
				--The 1 is just the first locations as finisher only have one location
				--Questie:debug_Print("Quest finished",MapInfo[4], MapInfo[5]);
				Questie:AddNoteToMap(c,z, x, y, "complete", questHash, 0);
				local notehandle = {};
				notehandle.c = MapInfo[4];
				notehandle.z = MapInfo[5];
				table.insert(ques["noteHandles"], notehandle);
			end
		else
			Questie:debug_Print("[AddQuestToMap] ERROR Quest broken! ", Quest["name"], questHash, "report on github!");
		end
	end
	--Cache code
	ques["objectives"] = Objectives;
	QuestieHandledQuests[questHash] = ques;
	if(redraw) then
		Questie:RedrawNotes();
	end
end
---------------------------------------------------------------------------------------------------
-- Updates quest notes on map
---------------------------------------------------------------------------------------------------
function Questie:UpdateQuestNotes(questHash, redraw)
	if not QuestieHandledQuests[questHash] then
		Questie:debug_Print("[UpdateQuestNotes] ERROR: Tried updating a quest not handled. ", questHash);
		return;
	end
	local QuestLogID = Questie:GetQuestIdFromHash(questHash);
	QSelect_QuestLogEntry(QuestLogID);
	local questName, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = QGet_QuestLogTitle(QuestLogID);
	local count =  QGet_NumQuestLeaderBoards();
	local questText, objectiveText = QGet_QuestLogQuestText();
	for k, noteInfo in pairs(QuestieHandledQuests[questHash]["noteHandles"]) do
		for id, note in pairs(QuestieMapNotes[noteInfo.c][noteInfo.z]) do
			if(note.questHash == questHash) then
				local desc, typ, done = QGet_QuestLogLeaderBoard(note.objectiveid);
				Questie:debug_Print("[UpdateQuestNotes] ", tostring(desc),tostring(typ),tostring(done));
			end
		end
	end
	if(redraw) then
		Questie:RedrawNotes();
	end
end
---------------------------------------------------------------------------------------------------
-- Remove quest note from map
---------------------------------------------------------------------------------------------------
function Questie:RemoveQuestFromMap(questHash, redraw)
	local removed = false;
	for continent, zoneTable in pairs(QuestieMapNotes) do
		for index, zone in pairs(zoneTable) do
			for i, note in pairs(zone) do
				if(note.questHash == questHash) then
					QuestieMapNotes[continent][index][i] = nil;
					removed = true;
				end
			end
		end
	end
	if(redraw) then
		Questie:RedrawNotes();
	end
	if(QuestieHandledQuests[questHash]) then
		QuestieHandledQuests[questHash] = nil;
	end
end

function Questie:GetMapInfoFromID(id)
	local r = QuestieZoneIDLookup[id];
	--if not r then
		--DEFAULT_CHAT_FRAME:AddMessage("(MoreQuestieSpam) MapInfo not found for ID " .. id .. "??? TELL AERO!!");
	--end
	return r;
end
---------------------------------------------------------------------------------------------------
-- Add quest note to map
---------------------------------------------------------------------------------------------------
QuestieMapNotes = {};--Usage Questie[Continent][Zone][index]
MiniQuestieMapNotes = {};
function Questie:AddNoteToMap(continent, zoneid, posx, posy, type, questHash, objectiveid)
	--This is to set up the variables
	if(QuestieMapNotes[continent] == nil) then
		QuestieMapNotes[continent] = {};
	end
	if(QuestieMapNotes[continent][zoneid] == nil) then
		QuestieMapNotes[continent][zoneid] = {};
	end
	--Sets values that i want to use for the notes THIS IS WIP MORE INFO MAY BE NEDED BOTH IN PARAMETERS AND NOTES!!!
	Note = {};
	Note.x = posx;
	Note.y = posy;
	Note.zoneid = zoneid;
	Note.continent = continent;
	Note.icontype = type;
	Note.questHash = questHash;
	Note.objectiveid = objectiveid;
	--Inserts it into the right zone and continent for later use.
	table.insert(QuestieMapNotes[continent][zoneid], Note);
end
---------------------------------------------------------------------------------------------------
-- Add available quest note to map
---------------------------------------------------------------------------------------------------
QuestieAvailableMapNotes = {};
function Questie:AddAvailableNoteToMap(continent, zoneid, posx, posy, type, questHash, objectiveid)
	--This is to set up the variables
	if(QuestieAvailableMapNotes[continent] == nil) then
		QuestieAvailableMapNotes[continent] = {};
	end
	if(QuestieAvailableMapNotes[continent][zoneid] == nil) then
		QuestieAvailableMapNotes[continent][zoneid] = {};
	end
	--Sets values that i want to use for the notes THIS IS WIP MORE INFO MAY BE NEDED BOTH IN PARAMETERS AND NOTES!!!
	Note = {};
	Note.x = posx;
	Note.y = posy;
	Note.zoneid = zoneid;
	Note.continent = continent;
	Note.icontype = type;
	Note.questHash = questHash;
	Note.objectiveid = objectiveid;
	--Inserts it into the right zone and continent for later use.
	table.insert(QuestieAvailableMapNotes[continent][zoneid], Note);
end
---------------------------------------------------------------------------------------------------
-- Gets a blank frame either from Pool or creates a new one!
---------------------------------------------------------------------------------------------------
function Questie:GetBlankNoteFrame()
	if(table.getn(FramePool)==0) then
		Questie:CreateBlankFrameNote();
	end
	f = FramePool[1];
	table.remove(FramePool, 1);
	return f;
end
---------------------------------------------------------------------------------------------------
-- Tooltip code for quest objects
---------------------------------------------------------------------------------------------------
function Questie:hookTooltip()
	local _GameTooltipOnShow = GameTooltip:GetScript("OnShow") -- APPARENTLY this is always null, and doesnt need to be called for things to function correctly...?
	GameTooltip:SetScript("OnShow", function(self, arg)
		Questie:Tooltip(self);
		this:Show();
	end)
end
---------------------------------------------------------------------------------------------------
Questie_LastTooltip = GetTime();
QUESTIE_DEBUG_TOOLTIP = nil;
function Questie:Tooltip(this, forceShow, bag, slot)
	local monster = UnitName("mouseover")
	local objective = GameTooltipTextLeft1:GetText();
	if monster and GetTime() - Questie_LastTooltip > 0.1 then
		for k,v in pairs(QuestieHandledQuests) do
			local obj = v['objectives']['objectives'];
			if (obj) then
				for name,m in pairs(obj) do
					if m[1] and (m[1]['type'] == "monster" or m[1]['type'] == "slay") then
						if (monster .. " slain") == name or monster == name or monster == string.find(monster, string.len(monster)-6) then
							local logid = Questie:GetQuestIdFromHash(k);
							if logid then
								QSelect_QuestLogEntry(logid);
								local desc, typ, done = QGet_QuestLogLeaderBoard(m[1]['objectiveid']);
								local indx = findLast(desc, ":");
								local countstr = string.sub(desc, indx+2);
								GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3);
								GameTooltip:AddLine("   " .. monster .. ": " .. countstr, 1, 1, 0.2);
							end
						end
					elseif m[1] and (m[1]['type'] == "item" or m[1]['type'] == "loot") then
						local monroot = Questie_NPCLookup[monster];
						if monroot then
							monroot = Questie_NPCSpawns[monroot];
						else
							--DEFAULT_CHAT_FRAME:AddMessage("QuestData not found for NPC??? " .. monster);
						end
						if monroot then
							local mondat = monroot['drops'];
							if mondat and mondat[name] then
								if mondat[name] then
									local logid = Questie:GetQuestIdFromHash(k);
									if logid then
										QSelect_QuestLogEntry(logid);
										local desc, typ, done = QGet_QuestLogLeaderBoard(m[1]['objectiveid']);
										local indx = findLast(desc, ":");
										local countstr = string.sub(desc, indx+2);
										GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3);
										GameTooltip:AddLine("   " .. name .. ": " .. countstr, 1, 1, 0.2);
									end
								end
							else
								--Use the cache not to run unessecary objectives
								local p = nil;
								for dropper, value in pairs(QuestieCachedMonstersAndObjects[k]) do
									if(string.find(dropper, monster)) then
										local logid = Questie:GetQuestIdFromHash(k);
										if logid then
											QSelect_QuestLogEntry(logid);
											local count =  QGet_NumQuestLeaderBoards();
											for obj = 1, count do
												local desc, typ, done = QGet_QuestLogLeaderBoard(obj);
												local indx = findLast(desc, ":");
												local countstr = string.sub(desc, indx+2);
												local namestr = string.sub(desc, 1, indx-1);
												if(string.find(name, monster) and Questie_DropLookup[namestr]) then -- Added Find to fix zapped giants (THIS IS NOT TESTED IF YOU FIND ERRORS REPORT!)
													for h,c in pairs(Questie_Drops[Questie_DropLookup[namestr]][3]) do
														local dropperr = Questie_NPCSpawns[c];
														if dropperr then 
															dropperr = dropperr[1];
														end
														if dropperr and (name == dropperr or (string.find(name, dropperr) and name == dropperr) and not p) then-- Added Find to fix zapped giants (THIS IS NOT TESTED IF YOU FIND ERRORS REPORT!)
															GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
															GameTooltip:AddLine("   " .. namestr .. ": " .. countstr, 1, 1, 0.2)
															p = true;
															return;
														end
													end
												end
											end
										end
									end
									if(p)then
										break;
									end
								end
							end
						end
					end
				end
			end
		end
	elseif objective and GetTime() - Questie_LastTooltip > 0.05 then
		for k,v in pairs(QuestieHandledQuests) do
			local obj = v['objectives']['objectives'];
			if ( obj ) then
				for name,m in pairs(obj) do
					if (m[1] and m[1]['type'] == "object") then
						-- Search for Objective (tooltip contents) in Name, to see if the hovered item/NPC tooltip is related to any of our quests.
						-- Name = A quest objective name, such as "Strange Object examined".
						-- Objective = The first line of text from the current game-tooltip, such as an NPC-name, item-name ("Strange Object"), etc.
						local i, j = string.find(name, objective);
						if(i and j and QuestieObjects[m["name"]]) then
							GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
							GameTooltip:AddLine("   " .. name, 1, 1, 0.2)
						end
					elseif (m[1] and (m[1]['type'] == "item" or m[1]['type'] == "loot") and name == objective) then
						if(Questie_DropLookup[objective]) then
							GameTooltip:AddLine(v['objectives']['QuestName'], 0.2, 1, 0.3)
							local logid = Questie:GetQuestIdFromHash(k);
							if logid then
								QSelect_QuestLogEntry(logid);
								local desc, typ, done = QGet_QuestLogLeaderBoard(m[1]['objectiveid']);
								local indx = findLast(desc, ":");
								local countstr = string.sub(desc, indx+2);
								GameTooltip:AddLine("   " .. name .. ": " .. countstr, 1, 1, 0.2)
							end
						end
					end
				end
			end
		end
	end
	if(QUESTIE_DEBUG_TOOLTIP) then
		GameTooltip:AddLine("--Questie hook--")
	end
	if(forceShow) then
		GameTooltip:Show();
	end
	Questie_LastTooltip = GetTime();
end
---------------------------------------------------------------------------------------------------
-- Tooltip code for quest starters and finishers
---------------------------------------------------------------------------------------------------
function Questie_Tooltip_OnEnter()
	if(this.data.questHash) then
		local Tooltip = GameTooltip;
		if(this.type == "WorldMapNote") then
			Tooltip = WorldMapTooltip;
		else
			Tooltip = GameTooltip;
		end
		Tooltip:SetOwner(this, this); --"ANCHOR_CURSOR"
		if(not Questie_Meta[this.data.questHash]) then --Debug for missing quests that somehow end up on the world map anyway (ie via known "finisher" NPCs).
			Tooltip:AddLine("<Unknown Quest>",1,1,1);
			local QuestLogID = Questie:GetQuestIdFromHash(this.data.questHash);
			if QuestLogID then
				local questName, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = QGet_QuestLogTitle(QuestLogID);
				Tooltip:AddLine(questName,1,0,0);
			end
			Tooltip:AddLine("QuestID: "..this.data.questHash, 1, 0, 0);
		elseif(this.data.icontype ~= "available") then
			local Quest = Questie:IsQuestFinished(this.data.questHash);
			if not Quest then
				local QuestLogID = Questie:GetQuestIdFromHash(this.data.questHash);
				if QuestLogID then
					QSelect_QuestLogEntry(QuestLogID);
					local questName, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = QGet_QuestLogTitle(QuestLogID);
					local count =  QGet_NumQuestLeaderBoards();
					local questText, objectiveText = QGet_QuestLogQuestText();
					local desc, typ, done = QGet_QuestLogLeaderBoard(this.data.objectiveid);
					Tooltip:AddLine(questName ,1,1,1);
					Tooltip:AddLine(desc);
				end
			else
				Tooltip:AddLine("["..Questie_Meta[this.data.questHash][3][1].."] "..Quest["name"].." |cFF33FF00(complete)|r");
				local nameVal = Questie_Meta[this.data.questHash][4][4];
				if(Questie_Meta[this.data.questHash][4][3] == 1) then
					nameVal = Questie_NPCSpawns[nameVal][1];
				else
					nameVal = Questie_ObjSpawns[nameVal][1];
				end
				Tooltip:AddLine("Finished by: |cFFa6a6a6"..nameVal.."|r",1,1,1);
			end
		else
			questOb = nil
			local QuestName = tostring(Questie_Meta[this.data.questHash][1])
			if QuestName then
				local index = 0
				for k,v in pairs(Questie_Lookup[QuestName]) do
					index = index + 1
					if (index == 1) and (v[2] == this.data.questHash) and (k ~= "") then
						questOb = k
					elseif (index > 0) and(v[2] == this.data.questHash) and (k ~= "") then
						questOb = k
					elseif (index == 1) and (v[2] ~= this.data.questHash) and (k ~= "") then
						questOb = k
					end
				end
			end
			Tooltip:AddLine("["..Questie_Meta[this.data.questHash][3][1].."] "..Questie_Meta[this.data.questHash][1].." |cFF33FF00(available)|r");
			local nameVal = Questie_Meta[this.data.questHash][4][2];
			if(Questie_Meta[this.data.questHash][4][1] == 1) then
				nameVal = Questie_NPCSpawns[nameVal][1];
			else
				nameVal = Questie_ObjSpawns[nameVal][1];
			end
			Tooltip:AddLine("Started by: |cFFa6a6a6"..nameVal.."|r",1,1,1);
			if questOb ~= nil then
				Tooltip:AddLine("Description: |cFFa6a6a6"..questOb.."|r",1,1,1,true);
			end
			Tooltip:AddLine("Shift+Click: |cFFa6a6a6Manually complete quest!|r",1,1,1);
		end
		if(NOTES_DEBUG and IsAltKeyDown()) then
			Tooltip:AddLine("!DEBUG!", 1, 0, 0);
			Tooltip:AddLine("QuestID: "..this.data.questHash, 1, 0, 0);
		end
		Tooltip:SetFrameLevel(11);
		Tooltip:Show();
	end
end
---------------------------------------------------------------------------------------------------
-- Force a quest to be finished via the Minimap or Worldmap (Shift-Click icon - NO confirmation)
---------------------------------------------------------------------------------------------------
function Questie_AvailableQuestClick()
	local Tooltip = GameTooltip
	if(this.type == "WorldMapNote") then
		Tooltip = WorldMapTooltip
	else
		Tooltip = GameTooltip
	end
	if (QuestieConfig.arrowEnabled == true) and (arg1 == "LeftButton") and (QuestieSeenQuests[this.data.questHash] == 0) and (QuestieTrackedQuests[this.data.questHash] ~= false) and (not IsControlKeyDown()) and (not IsShiftKeyDown()) then
		SetArrowObjective(this.data.questHash)
	end
	if ( IsShiftKeyDown() and Tooltip and Questie_Meta[this.data.questHash] ) then
		local QuestName = tostring(Questie_Meta[this.data.questHash][1])
		if QuestName then
			for k,v in pairs(Questie_Lookup) do
				if strlower(k) == strlower(QuestName) then
					Questie:Toggle()
					local hash = (this.data.questHash)
					Questie:finishAndRecurse(this.data.questHash)
					DEFAULT_CHAT_FRAME:AddMessage("Completing quest |cFF00FF00\"" .. Questie_Meta[this.data.questHash][1] .. "\"|r and parent quest: "..this.data.questHash);
				end
			end
		end
		Questie:Toggle()
	end
end
---------------------------------------------------------------------------------------------------
-- Creates a blank frame for use within the map system
---------------------------------------------------------------------------------------------------
CREATED_NOTE_FRAMES = 1;
function Questie:CreateBlankFrameNote()
	local f = CreateFrame("Button","QuestieNoteFrame"..CREATED_NOTE_FRAMES,WorldMapFrame)
	f:SetFrameLevel(9);
	f:SetWidth(16*QUESTIE_NOTES_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed
	f:SetHeight(16*QUESTIE_NOTES_MAP_ICON_SCALE) -- for your Texture
	local t = f:CreateTexture(nil,"BACKGROUND")
	t:SetTexture("Interface\\AddOns\\!Questie\\Icons\\complete")
	t:SetAllPoints(f)
	f.texture = t
	f:SetScript("OnEnter", Questie_Tooltip_OnEnter); --Script Toolip
	f:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
	f:SetScript("OnClick", Questie_AvailableQuestClick);
	f:RegisterForClicks("LeftButtonDown", "RightButtonDown");
	CREATED_NOTE_FRAMES = CREATED_NOTE_FRAMES+1;
	table.insert(FramePool, f);
	table.insert(AllFrames, f);
end

TICK_DELAY = 0.01;--0.1 Atm not to get spam while debugging should probably be a lot faster...
LAST_TICK = GetTime();
local LastContinent = nil;
local LastZone = nil;
UIOpen = false;
NATURAL_REFRESH = 60;
NATRUAL_REFRESH_SPACING = 2;
---------------------------------------------------------------------------------------------------
-- Updates notes for current zone only
---------------------------------------------------------------------------------------------------
function Questie:NOTES_ON_UPDATE(elapsed)
	--Test to remove the delay
	--Gets current map to see if we need to redraw or not.
	local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
	if(c ~= LastContinent or LastZone ~= z) then
		--Clears before redrawing
		Questie:SetAvailableQuests();
		Questie:RedrawNotes();
		--Sets the last continent and zone to hinder spam.
		LastContinent = c;
		LastZone = z;
	end
	--NOT NEEDED BUT KEEPING FOR AWHILE
	if(WorldMapFrame:IsVisible() and UIOpen == false) then
		Questie:debug_Print("Created Frames: "..CREATED_NOTE_FRAMES, "Used Frames: "..table.getn(QuestieUsedNoteFrames), "Free Frames: "..table.getn(FramePool));
		UIOpen = true;
	elseif(WorldMapFrame:IsVisible() == nil and UIOpen == true) then
		UIOpen = false;
	end
	if IsAddOnLoaded("MBB") then
		local MBB_ExcludeTemp = {}
		local count = CREATED_NOTE_FRAMES
		local tbsize = table.getn(MBB_Exclude)
		if tbsize == 0 then
			MBB_Exclude[1] = "QuestiePlaceHolderFrame";
		end
		if tbsize >= count + 1 then return end
		for i = 1, count do
			MBB_ExcludeTemp[i] = "QuestieNoteFrame"..i;
		end
		for i = 1, #MBB_ExcludeTemp do
			MBB_Exclude[#MBB_Exclude+1] = MBB_ExcludeTemp[i]
		end
		MBB_ExcludeTemp = {}
	end
end
---------------------------------------------------------------------------------------------------
-- Inital pool size (Not tested how much you can do before it lags like shit, from experiance 11
-- is good)
---------------------------------------------------------------------------------------------------
INIT_POOL_SIZE = 11;
function Questie:NOTES_LOADED()
	Questie:debug_Print("Loading QuestieNotes");
	if(table.getn(FramePool) < 10) then--For some reason loading gets done several times... added this in as safety
		for i = 1, INIT_POOL_SIZE do
			Questie:CreateBlankFrameNote();
		end
	end
	Questie:debug_Print("Done Loading QuestieNotes");
end
---------------------------------------------------------------------------------------------------
-- Sets up all available quests
---------------------------------------------------------------------------------------------------
function Questie:SetAvailableQuests()
	QuestieAvailableMapNotes = {};
	local t = GetTime();
	local level = UnitLevel("player");
	local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
	local mapFileName = GetMapInfo();
	local quests = nil;
	if QuestieConfig.minLevelFilter and not QuestieConfig.maxLevelFilter then
		quests = Questie:GetAvailableQuestHashes(mapFileName,level-(QuestieConfig.minShowLevel),level);
	elseif QuestieConfig.minLevelFilter and QuestieConfig.maxLevelFilter then
		quests = Questie:GetAvailableQuestHashes(mapFileName,level-(QuestieConfig.minShowLevel),level-(QuestieConfig.maxShowLevel));
	elseif not QuestieConfig.minLevelFilter and not QuestieConfig.maxLevelFilter then
		quests = Questie:GetAvailableQuestHashes(mapFileName,0,level);
	end
	if quests then
	for k, v in pairs(quests) do
		if(Questie_Meta[v]) then
			local meta = Questie_Meta[v];
			if(meta[4][1] == 1) then
				Monster = Questie_NPCSpawns[meta[4][2]];
			else
				Monster = Questie_ObjSpawns[meta[4][2]];
			end
			if Monster then
				Monster = Monster[2][1];
				local MapInfo = Questie:GetMapInfoFromID(Monster[3]);
				Questie:AddAvailableNoteToMap(c,z,Monster[1],Monster[2],"available",v,-1);
			end
		end
	end
	Questie:debug_Print("Added Available quests: Time:",tostring((GetTime()- t)*1000).."ms", "Count:"..table.getn(quests))
	end
end
---------------------------------------------------------------------------------------------------
-- Reason this exists is to be able to call both clearnotes and drawnotes without doing 2 function
-- calls, and to be able to force a redraw
---------------------------------------------------------------------------------------------------
function Questie:RedrawNotes()
	local time = GetTime();
	Questie:CLEAR_ALL_NOTES();
	Questie:DRAW_NOTES();
	Questie:debug_Print("Notes redrawn time:", tostring((GetTime()- time)*1000).."ms");
	time = nil;
end

function Questie:Clear_Note(v)
	v:SetParent(nil);
	v:Hide();
	v:SetAlpha(1);
	v:SetFrameLevel(9);
	v:SetHighlightTexture(nil, "ADD");
	v.questHash = nil;
	v.objId = nil;
	table.insert(FramePool, v);
end
---------------------------------------------------------------------------------------------------
-- Clears the notes, goes through the usednoteframes and clears them. Then sets the
-- QuestieUsedNotesFrame to new table;
---------------------------------------------------------------------------------------------------
function Questie:CLEAR_ALL_NOTES()
	Questie:debug_Print("CLEAR_NOTES");
	Astrolabe:RemoveAllMinimapIcons();
	for k, v in pairs(QuestieUsedNoteFrames) do
		--Questie:debug_Print("Hash:"..v.questHash,"Type:"..v.type);
		Questie:Clear_Note(v);
	end
	QuestieUsedNoteFrames = {};
end
---------------------------------------------------------------------------------------------------
-- Checks first if there are any notes for the current zone, then draws the desired icon
---------------------------------------------------------------------------------------------------
function Questie:DRAW_NOTES()
	local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
	Questie:debug_Print("DRAW_NOTES");
	if(QuestieMapNotes[c] and QuestieMapNotes[c][z]) then
		for k, v in pairs(QuestieMapNotes[c][z]) do
			local C,Z,X,Y = Astrolabe:GetCurrentPlayerPosition() -- continent, zone, x, y
			local dist, xDelta, yDelta = Astrolabe:ComputeDistance( C, Z, X, Y, v.continent, v.zoneid, v.x, v.y )
			if (dist == nil) or (dist <= 200) then
				--If an available quest isn't in the zone or we aren't tracking a quest on the QuestTracker then hide the objectives from the minimap
				if (QuestieConfig.alwaysShowQuests == false) and (MMLastX ~= 0 and MMLastY ~= 0) and (((QuestieTrackedQuests[v.questHash] ~= nil) and (QuestieTrackedQuests[v.questHash]["tracked"] ~= false)) or (v.icontype == "complete")) then
					MMIcon = Questie:GetBlankNoteFrame();
					MMIcon.data = v;
					MMIcon:SetParent(Minimap);
					MMIcon:SetFrameLevel(9);
					MMIcon:SetPoint("CENTER", 0, 0)
					if (v.icontype == "complete") then
						MMIcon:SetWidth(20*QUESTIE_NOTES_MINIMAP_ICON_SCALE)  -- Set These to whatever height/width is needed
						MMIcon:SetHeight(20*QUESTIE_NOTES_MINIMAP_ICON_SCALE) -- for your Texture
					else
						MMIcon:SetWidth(14*QUESTIE_NOTES_MINIMAP_ICON_SCALE)  -- Set These to whatever height/width is needed
						MMIcon:SetHeight(14*QUESTIE_NOTES_MINIMAP_ICON_SCALE) -- for your Texture
					end
					MMIcon.type = "MiniMapNote";
					--Sets highlight texture (Nothing stops us from doing this on the worldmap aswell)
					MMIcon:SetHighlightTexture(QuestieIcons[v.icontype].path, "ADD");
					--Set the texture to the right type
					MMIcon.texture:SetTexture(QuestieIcons[v.icontype].path);
					MMIcon.texture:SetAllPoints(MMIcon)
					Astrolabe:PlaceIconOnMinimap(MMIcon, v.continent, v.zoneid, v.x, v.y);
					table.insert(QuestieUsedNoteFrames, MMIcon);
				elseif (QuestieConfig.alwaysShowQuests == true) then
					MMIcon = Questie:GetBlankNoteFrame();
					MMIcon.data = v;
					MMIcon:SetParent(Minimap);
					MMIcon:SetFrameLevel(9);
					MMIcon:SetPoint("CENTER", 0, 0)
					if (v.icontype == "complete") then
						MMIcon:SetWidth(20*QUESTIE_NOTES_MINIMAP_ICON_SCALE)  -- Set These to whatever height/width is needed
						MMIcon:SetHeight(20*QUESTIE_NOTES_MINIMAP_ICON_SCALE) -- for your Texture
					else
						MMIcon:SetWidth(14*QUESTIE_NOTES_MINIMAP_ICON_SCALE)  -- Set These to whatever height/width is needed
						MMIcon:SetHeight(14*QUESTIE_NOTES_MINIMAP_ICON_SCALE) -- for your Texture
					end
					MMIcon.type = "MiniMapNote";
					--Sets highlight texture (Nothing stops us from doing this on the worldmap aswell)
					MMIcon:SetHighlightTexture(QuestieIcons[v.icontype].path, "ADD");
					--Set the texture to the right type
					MMIcon.texture:SetTexture(QuestieIcons[v.icontype].path);
					MMIcon.texture:SetAllPoints(MMIcon)
					Astrolabe:PlaceIconOnMinimap(MMIcon, v.continent, v.zoneid, v.x, v.y);
					table.insert(QuestieUsedNoteFrames, MMIcon);
				end
			end
		end
	end
	for k, Continent in pairs(QuestieMapNotes) do
		for zone, noteHeap in pairs(Continent) do
			for k, v in pairs(noteHeap) do
				if true then
					--If we aren't tracking a quest on the QuestTracker then hide the objectives from the worldmap
					if ( ( (QuestieTrackedQuests[v.questHash] ~= nil) and (QuestieTrackedQuests[v.questHash]["tracked"] ~= false) ) or (v.icontype == "complete") ) and (QuestieConfig.alwaysShowQuests == false) then
						local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
						Icon = Questie:GetBlankNoteFrame();
						Icon.data = v;
						Icon:SetParent(WorldMapFrame);
						--This is so that Complete quests are over everything else
						if(v.icontype == "complete") then
							Icon:SetFrameLevel(10);
						else
							Icon:SetFrameLevel(9);
						end
						Icon:SetPoint("CENTER", 0, 0)
						Icon.type = "WorldMapNote";
						Icon:SetScript("OnEnter", Questie_Tooltip_OnEnter); --Script Toolip
						Icon:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
						Icon:SetScript("OnClick", Questie_AvailableQuestClick);
						Icon:RegisterForClicks("LeftButtonDown", "RightButtonDown");
						if(z == 0 and c == 0) then--Both continents
							Icon:SetWidth(14*QUESTIE_NOTES_WORLD_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed
							Icon:SetHeight(14*QUESTIE_NOTES_WORLD_MAP_ICON_SCALE) -- for your Texture
						elseif(z == 0) then--Single continent
							Icon:SetWidth(14*QUESTIE_NOTES_CONTINENT_ICON_SCALE)  -- Set These to whatever height/width is needed
							Icon:SetHeight(14*QUESTIE_NOTES_CONTINENT_ICON_SCALE) -- for your Texture
						else
							Icon:SetWidth(14*QUESTIE_NOTES_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed
							Icon:SetHeight(14*QUESTIE_NOTES_MAP_ICON_SCALE) -- for your Texture
						end
						--Set the texture to the right type
						Icon.texture:SetTexture(QuestieIcons[v.icontype].path);
						Icon.texture:SetAllPoints(Icon)
						--Shows and then calls Astrolabe to place it on the map.
						Icon:Show();
						xx, yy = Astrolabe:PlaceIconOnWorldMap(WorldMapButton,Icon,v.continent ,v.zoneid ,v.x, v.y); --WorldMapFrame is global
						if(xx and yy and xx > 0 and xx < 1 and yy > 0 and yy < 1) then
							table.insert(QuestieUsedNoteFrames, Icon);
						else
							Questie:Clear_Note(Icon);
						end
					elseif (QuestieConfig.alwaysShowQuests == true) then
						local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
						Icon = Questie:GetBlankNoteFrame();
						Icon.data = v;
						Icon:SetParent(WorldMapFrame);
						--This is so that Complete quests are over everything else
						if(v.icontype == "complete") then
							Icon:SetFrameLevel(10);
						else
							Icon:SetFrameLevel(9);
						end
						Icon:SetPoint("CENTER",0,0)
						Icon.type = "WorldMapNote";
						Icon:SetScript("OnEnter", Questie_Tooltip_OnEnter); --Script Toolip
						Icon:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
						Icon:SetScript("OnClick", Questie_AvailableQuestClick);
						Icon:RegisterForClicks("LeftButtonDown", "RightButtonDown");
						if(z == 0 and c == 0) then--Both continents
							Icon:SetWidth(14*QUESTIE_NOTES_WORLD_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed
							Icon:SetHeight(14*QUESTIE_NOTES_WORLD_MAP_ICON_SCALE) -- for your Texture
						elseif(z == 0) then--Single continent
							Icon:SetWidth(14*QUESTIE_NOTES_CONTINENT_ICON_SCALE)  -- Set These to whatever height/width is needed
							Icon:SetHeight(14*QUESTIE_NOTES_CONTINENT_ICON_SCALE) -- for your Texture
						else
							Icon:SetWidth(14*QUESTIE_NOTES_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed
							Icon:SetHeight(14*QUESTIE_NOTES_MAP_ICON_SCALE) -- for your Texture
						end
						--Set the texture to the right type
						Icon.texture:SetTexture(QuestieIcons[v.icontype].path);
						Icon.texture:SetAllPoints(Icon)
						--Shows and then calls Astrolabe to place it on the map.
						Icon:Show();
						xx, yy = Astrolabe:PlaceIconOnWorldMap(WorldMapButton,Icon,v.continent ,v.zoneid ,v.x, v.y); --WorldMapFrame is global
						if(xx and yy and xx > 0 and xx < 1 and yy > 0 and yy < 1) then
							table.insert(QuestieUsedNoteFrames, Icon);
						else
							Questie:Clear_Note(Icon);
						end
					end
				end
			end
		end
	end
	if(QuestieAvailableMapNotes[c] and QuestieAvailableMapNotes[c][z]) then
		if Active == true then
			local con,zon,x,y = Astrolabe:GetCurrentPlayerPosition();
			for k, v in pairs(QuestieAvailableMapNotes[c][z]) do
				local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
				Icon = Questie:GetBlankNoteFrame();
				Icon.data = v;
				Icon:SetParent(WorldMapFrame);
				--This is so that Complete quests are over everything else
				Icon:SetFrameLevel(9);
				Icon:SetPoint("CENTER", 0, 0)
				Icon.type = "WorldMapNote";
				Icon:SetScript("OnEnter", Questie_Tooltip_OnEnter); --Script Toolip
				Icon:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
				Icon:SetWidth(14*QUESTIE_NOTES_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed
				Icon:SetHeight(14*QUESTIE_NOTES_MAP_ICON_SCALE) -- for your Texture
				Icon:SetScript("OnClick", Questie_AvailableQuestClick);
				Icon:RegisterForClicks("LeftButtonDown", "RightButtonDown");
				--Set the texture to the right type
				Icon.texture:SetTexture(QuestieIcons[v.icontype].path);
				Icon.texture:SetAllPoints(Icon)
				--Shows and then calls Astrolabe to place it on the map.
				Icon:Show();
				xx, yy = Astrolabe:PlaceIconOnWorldMap(WorldMapButton,Icon,v.continent ,v.zoneid ,v.x, v.y); --WorldMapFrame is global
				if(xx and yy and xx > 0 and xx < 1 and yy > 0 and yy < 1) then
					table.insert(QuestieUsedNoteFrames, Icon);
				else
					Questie:Clear_Note(Icon);
				end
				local dist, xDelta, yDelta = Astrolabe:ComputeDistance( con, zon, x, y, v.continent, v.zoneid, v.x, v.y )
				if (dist == nil) or (dist <= 200) then
					MMIcon = Questie:GetBlankNoteFrame();
					MMIcon.data = v;
					MMIcon:SetParent(Minimap);
					MMIcon:SetFrameLevel(7);
					MMIcon:SetPoint("CENTER", 0, 0)
					if (v.icontype == "available") then
						MMIcon:SetWidth(20*QUESTIE_NOTES_MINIMAP_ICON_SCALE)  -- Set These to whatever height/width is needed
						MMIcon:SetHeight(20*QUESTIE_NOTES_MINIMAP_ICON_SCALE) -- for your Texture
					else
						MMIcon:SetWidth(14*QUESTIE_NOTES_MINIMAP_ICON_SCALE)  -- Set These to whatever height/width is needed
						MMIcon:SetHeight(14*QUESTIE_NOTES_MINIMAP_ICON_SCALE) -- for your Texture
					end
					MMIcon.type = "MiniMapNote";
					--Sets highlight texture (Nothing stops us from doing this on the worldmap aswell)
					MMIcon:SetHighlightTexture(QuestieIcons[v.icontype].path, "ADD");
					--Set the texture to the right type
					MMIcon.texture:SetTexture(QuestieIcons[v.icontype].path);
					MMIcon.texture:SetAllPoints(MMIcon)
					Astrolabe:PlaceIconOnMinimap(MMIcon, v.continent, v.zoneid, v.x, v.y);
					table.insert(QuestieUsedNoteFrames, MMIcon);
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------
-- Debug print function
---------------------------------------------------------------------------------------------------
function Questie:debug_Print(...)
	local debugWin = 0;
	local name, shown;
	for i=1, NUM_CHAT_WINDOWS do
		name,_,_,_,_,_,shown = GetChatWindowInfo(i);
		if (string.lower(name) == "questiedebug") then debugWin = i; break; end
	end
	if (debugWin == 0) then return end
	local out = "";
	local n = select("#", ...);
	local v;
	for i=1, n do
		v = select(i, ...);
		if (i > 1) then out = out .. ", "; end
		local t = type(v);
		if (t == "string") then
			out = out .. '"'..v..'"';
		elseif (t == "number") then
			out = out .. v;
		else
			out = out .. dump(v);
		end
	end
	getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
end
---------------------------------------------------------------------------------------------------
-- Sets the icon type
---------------------------------------------------------------------------------------------------
QuestieIcons = {
	["complete"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\complete"
	},
	["available"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\available"
	},
	["loot"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\loot"
	},
	["item"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\loot"
	},
	["event"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\event"
	},
	["object"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\object"
	},
	["slay"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\slay"
	}
}
