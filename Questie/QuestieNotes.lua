NOTES_DEBUG = true;--Set to nil to not get debug shit

--Contains all the frames ever created, this is not to orphan any frames by mistake...
local AllFrames = {};

--Contains frames that are created but currently not used (Frames can't be deleted so we pool them to save space);
local FramePool = {};

QuestieUsedNoteFrames = {};

function Questie:AddQuestToMap(questHash)
	Questie:RemoveQuestFromMap(questHash);
	Objectives = Questie:AstroGetQuestObjectives(questHash);
	Questie:debug_Print("Adding quest", questHash);
	for name, locations in pairs(Objectives['objectives']) do
		for k, location in pairs(locations) do
			local MapInfo = Questie:GetMapInfoFromID(location.mapid);
			--Questie:debug_Print("Adding note to map",tostring(name), tostring(location.mapid),
			--	tostring(location.x), tostring(location.y),tostring(MapInfo[4]), tostring(MapInfo[5]), tostring(location.type));
			--getCurrentMapID()
			Questie:AddNoteToMap(MapInfo[4], MapInfo[5], location.x, location.y, location.type, questHash);
		end
	end
	Questie:RedrawNotes();
end

function Questie:RemoveQuestFromMap(questHash, redraw)
	local removed = false;
	for continent, zoneTable in pairs(MapNotes) do
		for index, zone in pairs(zoneTable) do
			for i, note in pairs(zone) do
				if(note.questHash == questHash) then
					MapNotes[continent][index][i] = nil;
					removed = true;
				end
			end
		end
	end
	if(redraw) then
		Questie:RedrawNotes();
	end
end


function Questie:GetMapInfoFromID(id)
	return QuestieZoneIDLookup[id];
end

MapNotes = {};--Usage Questie[Continent][Zone][index]
MinimapNotes = {};
function Questie:AddNoteToMap(continent, zoneid, posx, posy, type, questHash)
	--This is to set up the variables
	if(MapNotes[continent] == nil) then
		MapNotes[continent] = {};
	end
	if(MapNotes[continent][zoneid] == nil) then
		MapNotes[continent][zoneid] = {};
	end

	--Sets values that i want to use for the notes THIS IS WIP MORE INFO MAY BE NEDED BOTH IN PARAMETERS AND NOTES!!!
	Note = {};
	Note.x = posx;
	Note.y = posy;
	Note.zoneid = zoneid;
	Note.continent = continent;
	Note.icontype = type;
	Note.questHash = questHash;
	--Inserts it into the right zone and continent for later use.
	table.insert(MapNotes[continent][zoneid], Note);
end

--Gets a blank frame either from Pool or creates a new one!
function Questie:GetBlankNoteFrame()
	if(table.getn(FramePool)==0) then
		Questie:CreateBlankFrameNote();
	end
	f = FramePool[1];
	table.remove(FramePool, 1);
	return f;
end


function Questie_Tooltip_OnEnter()
	if(this.questHash) then--If this is not set we have nothing to show...
		local Tooltip = GameTooltip;
		if(this.type == "WorldMapNote") then
			Tooltip = WorldMapTooltip;
		else
			Tooltip = GameTooltip;
		end

		Tooltip:SetOwner(this, this); --"ANCHOR_CURSOR"
		Tooltip:AddLine("ThisIsATestHeader ",1,1,1);
		Tooltip:AddLine("LowerText");
		if(NOTES_DEBUG) then
			Tooltip:AddLine("questHash: "..this.questHash);
		end
		Tooltip:SetFrameLevel(10);
		Tooltip:Show();
	end
end


CREATED_NOTE_FRAMES = 1;
--Creates a blank frame for use within the map system
function Questie:CreateBlankFrameNote()
	local f = CreateFrame("Button","QuestieNoteFrame"..CREATED_NOTE_FRAMES,WorldMapFrame)
	f:SetFrameLevel(9);
	f:SetWidth(16)  -- Set These to whatever height/width is needed 
	f:SetHeight(16) -- for your Texture
	local t = f:CreateTexture(nil,"BACKGROUND")
	t:SetTexture("Interface\\AddOns\\Questie\\Icons\\complete")
	t:SetAllPoints(f)
	f.texture = t
	f:SetScript("OnEnter", Questie_Tooltip_OnEnter); --Script Toolip
	f:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
	CREATED_NOTE_FRAMES = CREATED_NOTE_FRAMES+1;
	table.insert(FramePool, f);
	table.insert(AllFrames, f);
end

TICK_DELAY = 0.05;--0.1 Atm not to get spam while debugging should probably be a lot faster...
LAST_TICK = GetTime();

local LastContinent = nil;
local LastZone = nil;

UIOpen = false;

function Questie:NOTES_ON_UPDATE(elapsed)
	--NOT NEEDED BUT KEEPING FOR AWHILE
	if(WorldMapFrame:IsVisible() and UIOpen == false) then
		Questie:debug_Print("UI Opened redrawing");
		Questie:debug_Print(CREATED_NOTE_FRAMES, table.getn(QuestieUsedNoteFrames), table.getn(FramePool));
		--Questie:RedrawNotes();
		UIOpen = true;
	elseif(WorldMapFrame:IsVisible() == nil and UIOpen == true) then
		Questie:debug_Print("UI Closed redrawing");
		Questie:debug_Print(CREATED_NOTE_FRAMES, table.getn(QuestieUsedNoteFrames), table.getn(FramePool));
		--Questie:RedrawNotes();
		UIOpen = false;
	end


	if(GetTime() - LAST_TICK > TICK_DELAY) then
		--Gets current map to see if we need to redraw or not.
		local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
		if(c ~= LastContinent or LastZone ~= z) then
			--Clears before redrawing
			Questie:RedrawNotes();
			--Sets the last continent and zone to hinder spam.
			LastContinent = c;
			LastZone = z;
		end
		LAST_TICK = GetTime();
	end
end

--Inital pool size (Not tested how much you can do before it lags like shit, from experiance 11 is good)
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

--Reason this exists is to be able to call both clearnotes and drawnotes without doing 2 function calls, and to be able to force a redraw
function Questie:RedrawNotes()
	Questie:CLEAR_ALL_NOTES();
	Questie:DRAW_NOTES();
end

function Questie:Clear_Note(v)
	v:SetParent(nil);
	v:Hide();
	v:SetFrameLevel(9);
	v:SetHighlightTexture(nil, "ADD");
	v.questHash = nil;
	table.insert(FramePool, v);
end

--Clears the notes, goes through the usednoteframes and clears them. Then sets the QuestieUsedNotesFrame to new table;
function Questie:CLEAR_ALL_NOTES()
	Questie:debug_Print("CLEAR_NOTES");
	Astrolabe:RemoveAllMinimapIcons();
	for k, v in pairs(QuestieUsedNoteFrames) do
		--Questie:debug_Print("Hash:"..v.questHash,"Type:"..v.type);
		Questie:Clear_Note(v);
	end
	QuestieUsedNoteFrames = {};
end

--Checks first if there are any notes for the current zone, then draws the desired icon
function Questie:DRAW_NOTES()
	local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
	Questie:debug_Print("DRAW_NOTES");
	if(MapNotes[c] and MapNotes[c][z]) then
		for k, v in pairs(MapNotes[c][z]) do
			if(MMLastX ~= 0 and MMLastY ~= 0) then--Don't draw the minimap icons if the player isn't within the zone.
				MMIcon = Questie:GetBlankNoteFrame();
				--Here more info should be set but i CBA at the time of writing
				MMIcon.questHash = v.questHash;
				MMIcon:SetParent(Minimap);
				MMIcon:SetFrameLevel(9);
				MMIcon:SetPoint("CENTER",0,0)
				MMIcon.type = "MiniMapNote";
				--Sets highlight texture (Nothing stops us from doing this on the worldmap aswell)
				MMIcon:SetHighlightTexture(QuestieIcons[v.icontype].path, "ADD");
				--Set the texture to the right type
				MMIcon.texture:SetTexture(QuestieIcons[v.icontype].path);
				MMIcon.texture:SetAllPoints(MMIcon)
				--Shows and then calls Astrolabe to place it on the map.
				--MMIcon:Show();
				--Questie:debug_Print(v.continent,v.zoneid,v.x,v.y);
				Astrolabe:PlaceIconOnMinimap(MMIcon, v.continent, v.zoneid, v.x, v.y);
				--Questie:debug_Print(MMIcon:GetFrameLevel());
				table.insert(QuestieUsedNoteFrames, MMIcon);
			end
		end
	end

	for k, Continent in pairs(MapNotes) do
		for zone, noteHeap in pairs(Continent) do
			for k, v in pairs(noteHeap) do
				local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
				Icon = Questie:GetBlankNoteFrame();
				--Here more info should be set but i CBA at the time of writing
				Icon.questHash = v.questHash;
				Icon:SetParent(WorldMapFrame);
				Icon:SetFrameLevel(9);
				Icon:SetPoint("CENTER",0,0)
				Icon.type = "WorldMapNote";
				Icon:SetScript("OnEnter", Questie_Tooltip_OnEnter); --Script Toolip
				Icon:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip


				--Set the texture to the right type
				Icon.texture:SetTexture(QuestieIcons[v.icontype].path);
				Icon.texture:SetAllPoints(Icon)

				--Shows and then calls Astrolabe to place it on the map.
				Icon:Show();
				
				--Questie:debug_Print(x.." : "..y);
				xx, yy = Astrolabe:PlaceIconOnWorldMap(WorldMapButton,Icon,v.continent ,v.zoneid ,v.x, v.y); --WorldMapFrame is global
				if(xx > 0 and xx < 1 and yy > 0 and yy < 1) then
					--Questie:debug_Print(Icon:GetFrameLevel());
					table.insert(QuestieUsedNoteFrames, Icon);			
				else
					--Questie:debug_Print("Outside map, reseting icon to pool");
					Questie:Clear_Note(Icon);
				end
			end
		end
	end
end

--Debug print function
function Questie:debug_Print(...)
	local debugWin = 0;
	local name, shown;
	for i=1, NUM_CHAT_WINDOWS do
		name,_,_,_,_,_,shown = GetChatWindowInfo(i);
		if (string.lower(name) == "questiedebug") then debugWin = i; break; end
	end
	if (debugWin == 0) then return end

	local out = "";
	for i = 1, arg.n, 1 do
		if (i > 1) then out = out .. ", "; end
		local t = type(arg[i]);
		if (t == "string") then
			out = out .. '"'..arg[i]..'"';
		elseif (t == "number") then
			out = out .. arg[i];
		else
			out = out .. dump(arg[i]);
		end
	end
	getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
end











--Sets the icons
QuestieIcons = {
	["complete"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\complete"
	},
	["available"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\available"
	},
	["loot"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\loot"
	},
	["item"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\loot"
	},
	["event"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\event"
	},
	["object"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\object"
	},
	["slay"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\slay"
	}
}




--	if(MapNotes[c] and MapNotes[c][z] and true == false) then
--		for k, v in pairs(MapNotes[c][z]) do
--
--			Icon = Questie:GetBlankNoteFrame();
--			--Here more info should be set but i CBA at the time of writing
--			Icon.questHash = v.questHash;
--			Icon:SetParent(WorldMapFrame);
--			Icon:SetFrameLevel(9);
--			Icon:SetPoint("CENTER",0,0)
--			Icon.type = "WorldMapNote";
--
--			--Set the texture to the right type
--			Icon.texture:SetTexture(QuestieIcons[v.type].path);
--			Icon.texture:SetAllPoints(f)
--
--			--Shows and then calls Astrolabe to place it on the map.
--			Icon:Show();
--
--			x, y = Astrolabe:PlaceIconOnWorldMap(WorldMapFrame,Icon,c,z,v.x, v.y); --WorldMapFrame is global
--			if(x > 0 and x < 1 and y > 0 and y < 1) then
--				table.insert(QuestieUsedNoteFrames, Icon);
--			else
--				Questie:debug_Print("Outside map, reseting icon to pool");
--				table.insert(FramePool, Icon);
--			end
--
--		end
--	end