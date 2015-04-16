NOTES_DEBUG = nil;--Set to nil to not get debug shit

--Contains all the frames ever created, this is not to orphan any frames by mistake...
local AllFrames = {};

--Contains frames that are created but currently not used (Frames can't be deleted so we pool them to save space);
local FramePool = {};

QuestieUsedNoteFrames = {};

MapNotes = {};--Usage Questie[Continent][Zone][index]
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
	Note.type = type;
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

--Creates a blank frame for use within the map system
function Questie:CreateBlankFrameNote()
	local f = CreateFrame("Button",nil,WorldMapFrame)
	f:SetFrameLevel(9);
	f:SetWidth(16)  -- Set These to whatever height/width is needed 
	f:SetHeight(16) -- for your Texture
	local t = f:CreateTexture(nil,"BACKGROUND")
	t:SetTexture("Interface\\AddOns\\Questie\\Icons\\complete")
	t:SetAllPoints(f)
	f.texture = t
	f:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_CURSOR");
			GameTooltip:AddLine("ICON! ");
			GameTooltip:Show();
	end ); --Script Toolip
	f:SetScript("OnLeave", function() if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip

	table.insert(FramePool, f);
	table.insert(AllFrames, f);
end

TICK_DELAY = 0.1;--0.1 Atm not to get spam while debugging should probably be a lot faster...
LAST_TICK = GetTime();
FORCE_REDRAW = false;--Use another method

local LastContinent = nil;
local LastZone = nil;


function Questie:NOTES_ON_UPDATE()
	if(GetTime() - LAST_TICK > TICK_DELAY) then
		--Gets current map to see if we need to redraw or not.
		local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
		if(c ~= LastContinent or LastZone ~= z or FORCE_REDRAW == true) then
			--Clears before redrawing
			Questie:CLEAR_NOTES();
			Questie:DRAW_NOTES();

			--Sets the last continent and zone to hinder spam.
			LastContinent = c;
			LastZone = z;
			FORCE_REDRAW = false;
		end
		LAST_TICK = GetTime();
	end
end

--Inital pool size (Not tested how much you can do before it lags like shit, from experiance 11 is good)
INIT_POOL_SIZE = 11;
function Questie:NOTES_LOADED()
	Questie:debug_Print("Loading QuestieNotes");
	for i = 1, INIT_POOL_SIZE do
		Questie:CreateBlankFrameNote();
	end
	Questie:debug_Print("Done Loading QuestieNotes");
end


--Clears the notes, goes through the usednoteframes and clears them. Then sets the QuestieUsedNotesFrame to new table;
function Questie:CLEAR_NOTES()
	Questie:debug_Print("CLEAR_NOTES");
	for k, v in pairs(QuestieUsedNoteFrames) do
		Questie:debug_Print("Hash:"..v.questHash);
		v:Hide();
		v.questHash = nil;
		table.insert(FramePool, v);
	end
	QuestieUsedNoteFrames = {};
end

--Checks first if there are any notes for the current zone, then draws the desired icon
function Questie:DRAW_NOTES()
	local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
	Questie:debug_Print("DRAW_NOTES");
	if(MapNotes[c] and MapNotes[c][z]) then
		for k, v in pairs(MapNotes[c][z]) do

			Icon = Questie:GetBlankNoteFrame();
			--Here more info should be set but i CBA at the time of writing
			Icon.questHash = v.questHash;
			Icon:SetPoint("CENTER",0,0)

			--Set the texture to the right type
			Icon.texture:SetTexture(QuestieIcons[v.type].path);
			Icon.texture:SetAllPoints(f)

			--Shows and then calls Astrolabe to place it on the map.
			Icon:Show();
			x, y = Astrolabe:PlaceIconOnWorldMap(WorldMapFrame,Icon,c,z,v.x, v.y); --WorldMapFrame is global
			table.insert(QuestieUsedNoteFrames, Icon);
		end
	end
end

--Debug print function
function Questie:debug_Print(msg)
	if(NOTES_DEBUG) then
		DEFAULT_CHAT_FRAME:AddMessage("[QN]:"..tostring(msg));
	end
end

--Sets the icons
QuestieIcons = {
	["Complete"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\complete"
	},
	["Available"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\available"
	},
	["Loot"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\loot"
	},
	["Event"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\event"
	},
	["Object"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\object"
	},
	["Slay"] = {
		text = "Complete",
		path = "Interface\\AddOns\\Questie\\Icons\\slay"
	}
}