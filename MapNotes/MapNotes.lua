--[[
	MapNotes: Adds a note system to the WorldMap and other AddOns that use the Plugins facility provided

	See the README file for more information.
]]


MapNotes_Details = {
	name = MAPNOTES_NAME,
	description = MAPNOTES_ADDON_DESCRIPTION,
	version = MAPNOTES_VERSION,
	releaseDate = "24 November 2006",
	author = "Telic",
	email = "telic@hotmail.co.uk",
	website = MAPNOTES_DOWNLOAD_SITES,
	category = MYADDONS_CATEGORY_MAP,
	frame = "MapNotesOptionsFrame",
	optionsframe = "MapNotesOptionsFrame",
};

MapNotes_Options = {};
MapNotes_Data_Notes = {};
MapNotes_Data_Lines = {};
MapNotes_MiniNote_Data = {};

MapNotes_MiniNote_IsInCity = false;
MapNotes_MiniNote_MapzoomInit = false;
MapNotes_SetNextAsMiniNote = 0;
MapNotes_AllowOneNote = 0;
MapNotes_LastReceivedNote_xPos = 0;
MapNotes_LastReceivedNote_yPos = 0;
MapNotes_ZoneNames = {};
MapNotes_LastLineClick = {};
MapNotes_LastLineClick.time = 0;

MapNotes_TempData_Id = "";
MapNotes_TempData_Creator = "";
MapNotes_TempData_xPos = "";
MapNotes_TempData_yPos = "";
MapNotes_TempData_Icon = "";
MapNotes_TempData_TextColor = "";
MapNotes_TempData_Info1Color = "";
MapNotes_TempData_Info2Color = "";

MapNotes_PartyNoteData = {};
MapNotes_tloc_xPos = nil;
MapNotes_tloc_yPos = nil;
MapNotes_tloc_key = nil;

MapNotes_Started = nil;

MapNotes_HighlightedNote = "";

--[[
		Hooked Functions
--]]
local orig_MapNotes_WorldMapButton_OnClick; -- MapNotes hides WorldMapButton_OnClick on right-clicks
local orig_ToggleWorldMap;
local orig_CloseDropDownMenus;
local orig_ToggleDropDownMenu;
local orig_ChatFrame_OnEvent;

local MN_DefaultCoordsX = 60;
local MN_DefaultCoordsY = 532;
local MN_MOFFSET_X = 0.0022;
local MN_MOFFSET_Y = 0.0;
local MN_cUpdate = 0.0;
local MN_cUpdateLimit = 0.05;

function MapNotes_Hooker()

	-- WorldMapButton_OnClick
	orig_MapNotes_WorldMapButton_OnClick = WorldMapButton_OnClick;
	WorldMapButton_OnClick = MapNotes_WorldMapButton_OnClick;

	-- ToggleWorldMap
	function MapNotes_ToggleWorldMapHook()
		orig_ToggleWorldMap();
		MapNotes_ToggleWorldMap();
	end
	orig_ToggleWorldMap = ToggleWorldMap;
	ToggleWorldMap = MapNotes_ToggleWorldMapHook;

	-- CloseDropDownMenus
	function MapNotes_CloseDropDownMenusHook(level)
		orig_CloseDropDownMenus(level);
		MapNotes_CloseDropDownMenus(level);
	end
	orig_CloseDropDownMenus = CloseDropDownMenus;
	CloseDropDownMenus = MapNotes_CloseDropDownMenusHook;

	-- ToggleDropDownMenu
	function MapNotes_ToggleDropDownMenuHook(level, value, dropDownFrame, anchorName, xOffset, yOffset)
		MapNotes_CloseDropDownMenus(level, value, dropDownFrame, anchorName, xOffset, yOffset);
		orig_ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset);
	end
	orig_ToggleDropDownMenu = ToggleDropDownMenu;
	ToggleDropDownMenu = MapNotes_ToggleDropDownMenuHook;

	-- ChatFrame_OnEvent
	orig_ChatFrame_OnEvent = ChatFrame_OnEvent;
	ChatFrame_OnEvent = MapNotes_ChatFrame_OnEvent;
end

function MapNotes_OnLoad()

	MapNotes_RegisterDropDownButton(MAPNOTES_SHOWNOTES, "MapNotes_Options.shownotes", "MapNotesDropDownSubMenu");
	MiniNotePOI.TimeSinceLastUpdate = 0;
	WorldMapMagnifyingGlassButton:SetText(MAPNOTES_WORLDMAP_HELP_1.."\n"..MAPNOTES_WORLDMAP_HELP_2.."\n"..MAPNOTES_WORLDMAP_HELP_3);

	SlashCmdList["MAPNOTES"] = MapNotes_GetNoteBySlashCommand;
	for i = 1, table.getn(MAPNOTES_ENABLE_COMMANDS) do
		setglobal("SLASH_MAPNOTES"..i, MAPNOTES_ENABLE_COMMANDS[i]);
	end

	SlashCmdList["MN_ONENOTE"] = MapNotes_OneNote;
	for i = 1, table.getn(MAPNOTES_ONENOTE_COMMANDS) do
		setglobal("SLASH_MN_ONENOTE"..i, MAPNOTES_ONENOTE_COMMANDS[i]);
	end

	SlashCmdList["MN_MININOTE"] = MapNotes_NextMiniNote;
	for i = 1, table.getn(MAPNOTES_MININOTE_COMMANDS) do
		setglobal("SLASH_MN_MININOTE"..i, MAPNOTES_MININOTE_COMMANDS[i]);
	end

	SlashCmdList["MN_MININOTEONLY"] = MapNotes_NextMiniNoteOnly;
	for i = 1, table.getn(MAPNOTES_MININOTEONLY_COMMANDS) do
		setglobal("SLASH_MN_MININOTEONLY"..i, MAPNOTES_MININOTEONLY_COMMANDS[i]);
	end

	SlashCmdList["MN_MININOTEOFF"] = MapNotes_ClearMiniNote;
	for i = 1, table.getn(MAPNOTES_MININOTEOFF_COMMANDS) do
		setglobal("SLASH_MN_MININOTEOFF"..i, MAPNOTES_MININOTEOFF_COMMANDS[i]);
	end

	SlashCmdList["MN_TLOC"] = MapNotes_mntloc;
	for i = 1, table.getn(MAPNOTES_MNTLOC_COMMANDS) do
		setglobal("SLASH_MN_TLOC"..i, MAPNOTES_MNTLOC_COMMANDS[i]);
	end

	SlashCmdList["MN_QUICKNOTE"] = MapNotes_Quicknote;
	for i = 1, table.getn(MAPNOTES_QUICKNOTE_COMMANDS) do
		setglobal("SLASH_MN_QUICKNOTE"..i, MAPNOTES_QUICKNOTE_COMMANDS[i]);
	end

	SlashCmdList["MN_QUICKTLOC"] = MapNotes_Quicktloc;
	for i = 1, table.getn(MAPNOTES_QUICKTLOC_COMMANDS) do
		setglobal("SLASH_MN_QUICKTLOC"..i, MAPNOTES_QUICKTLOC_COMMANDS[i]);
	end

	SlashCmdList["MN_SEARCH"] = MapNotes_Search;
	for i = 1, table.getn(MAPNOTES_SEARCH_COMMANDS) do
		setglobal("SLASH_MN_SEARCH"..i, MAPNOTES_SEARCH_COMMANDS[i]);
	end

	SlashCmdList["MN_HIGHLIGHT"] = MapNotes_Highlight;
	for i = 1, table.getn(MAPNOTES_HLIGHT_COMMANDS) do
		setglobal("SLASH_MN_HIGHLIGHT"..i, MAPNOTES_HLIGHT_COMMANDS[i]);
	end

	SlashCmdList["MN_MINICOORDS"] = MapNotes_MiniCToggle;
	for i = 1, table.getn(MAPNOTES_MINICOORDS_COMMANDS) do
		setglobal("SLASH_MN_MINICOORDS"..i, MAPNOTES_MINICOORDS_COMMANDS[i]);
	end

	SlashCmdList["MN_MAPCOORDS"] = MapNotes_MapCToggle;
	for i = 1, table.getn(MAPNOTES_MAPCOORDS_COMMANDS) do
		setglobal("SLASH_MN_MAPCOORDS"..i, MAPNOTES_MAPCOORDS_COMMANDS[i]);
	end

	SlashCmdList["MN_TARGETNOTE"] = MapNotes_TargetNote;
	for i = 1, table.getn(MAPNOTES_NTARGET_COMMANDS) do
		setglobal("SLASH_MN_TARGETNOTE"..i, MAPNOTES_NTARGET_COMMANDS[i]);
	end

	SlashCmdList["MN_TARGETMERGE"] = MapNotes_MergeNote;
	for i = 1, table.getn(MAPNOTES_MTARGET_COMMANDS) do
		setglobal("SLASH_MN_TARGETMERGE"..i, MAPNOTES_MTARGET_COMMANDS[i]);
	end


	SlashCmdList["IMPORTMETAMAP"] = MapNotes_ImportMetaMap;					--Telic_4
	for i = 1, table.getn(MAPNOTES_IMPORT_METAMAP) do					--Telic_4
		setglobal("SLASH_IMPORTMETAMAP"..i, MAPNOTES_IMPORT_METAMAP[i]);		--Telic_4
	end											--Telic_4

	SlashCmdList["IMPORTALPHAMAP"] = MapNotes_ImportAlphaMap;				--Telic_4
	for i = 1, table.getn(MAPNOTES_IMPORT_ALPHAMAP) do					--Telic_4
		setglobal("SLASH_IMPORTALPHAMAP"..i, MAPNOTES_IMPORT_ALPHAMAP[i]);		--Telic_4
	end											--Telic_4

	SlashCmdList["IMPORTALPHABGMAP"] = MapNotes_ImportAlphaMapBG;				--Telic_4
	for i = 1, table.getn(MAPNOTES_IMPORT_ALPHAMAPBG) do					--Telic_4
		setglobal("SLASH_IMPORTALPHABGMAP"..i, MAPNOTES_IMPORT_ALPHAMAPBG[i]);		--Telic_4
	end											--Telic_4

	SlashCmdList["IMPORTCTMAP"] = MapNotes_ImportCTMap;					--Telic_4
	for i = 1, table.getn(MAPNOTES_IMPORT_CTMAPMOD) do					--Telic_4
		setglobal("SLASH_IMPORTCTMAP"..i, MAPNOTES_IMPORT_CTMAPMOD[i]);			--Telic_4
	end											--Telic_4

end



function MapNotes_VariablesLoaded()
	if ( MapNotes_MiniNote_Data.icon == "party" ) then
		MapNotes_ClearMiniNote(true);
	end

	if ( MapNotes_MiniNote_Data.icon ~= nil ) then
		MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..MapNotes_MiniNote_Data.icon);
	end

	if myAddOnsFrame_Register then
		myAddOnsFrame_Register(MapNotes_Details);
	end

	MapNotes_Hooker();
	MapNotes_LoadMapData();		-- (Also upgrades from previous MapNotes versions
	if ( MapNotes_Data ) then
		MapNotes_Data = {};		-- {} ?
	end
	if ( MapNotes_Lines ) then
		MapNotes_Lines = {};		-- {} ?
	end
	MapNotes_LoadPlugIns();		--Telic_2

	if ( MapNotes_Options.miniC ) then
		MN_MinimapCoordsFrame:Show();
	end

	if ( not MapNotes_Options.coordsLocX ) then
		MapNotes_Options.coordsLocX = MN_DefaultCoordsX;
	end
	if ( not MapNotes_Options.coordsLocY ) then
		MapNotes_Options.coordsLocY = MN_DefaultCoordsY;
	end
	MN_SetCoordsPos();

	local msg = "MapNotes(Fan's Update) |c0000FF00"..MAPNOTES_VERSION.."|r";
	DEFAULT_CHAT_FRAME:AddMessage(msg, 0.64, 0.21, 0.93);
end



function MapNotes_CheckNearNotes(key, xPos, yPos)
	local i = 1;

	for j, value in ipairs(MapNotes_Data_Notes[key]) do
		local deltax = abs(MapNotes_Data_Notes[key][i].xPos - xPos);
		local deltay = abs(MapNotes_Data_Notes[key][i].yPos - yPos);
		if ( ( deltax <= (0.0009765625 * MapNotes_MinDiff) ) and ( deltay <= (0.0013020833 * MapNotes_MinDiff) ) ) then
			return i;
		end
		i = i + 1;
	end

	return false;
end

function MapNotes_StatusPrint(msg)
	msg = "<"..MAPNOTES_NAME..">: "..msg;
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.5, 0.25);
	end
end

function MapNotes_mntloc(msg)
	if msg == "" then
		MapNotes_tloc_xPos = nil;
		MapNotes_tloc_yPos = nil;
		MapNotes_tloc_key = nil;
	else
		SetMapToCurrentZone();
		local i,j,x,y = string.find(msg,"(%d+),(%d+)");
		MapNotes_tloc_xPos = x / 100;
		MapNotes_tloc_yPos = y / 100;
		MapNotes_tloc_key = MapNotes_GetMapKey();
	end
	MapNotes_WorldMapButton_OnUpdate();						--Telic_7
end



function MapNotes_GetNoteFromChat(note, who)
	if who ~= UnitName("player") then
		if gsub(note,".*<M_N+>%s+%w+.*p<([^>]*)>.*","%1",1) == "1" then -- Party Note
			local key = gsub(note,".*<M_N+> k<([^>]*)>.*","%1",1);
			local xPos = gsub(note,".*<M_N+>%s+%w+.*x<([^>]*)>.*","%1",1) + 0;
			local yPos = gsub(note,".*<M_N+>%s+%w+.*y<([^>]*)>.*","%1",1) + 0;
			MapNotes_PartyNoteData.key = key;
			MapNotes_PartyNoteData.xPos = xPos;
			MapNotes_PartyNoteData.yPos = yPos;
			MapNotes_StatusPrint( format( MAPNOTES_PARTY_GET, who, MapNotes_GetMapDisplayName(key) ) );
			if MapNotes_MiniNote_Data.icon == "party" or MapNotes_Options[16] ~= "off" then
				MapNotes_MiniNote_Data.id = -1;
				MapNotes_MiniNote_Data.key = key;
				MapNotes_MiniNote_Data.xPos = xPos;
				MapNotes_MiniNote_Data.yPos = yPos;
				MapNotes_MiniNote_Data.name = MAPNOTES_PARTYNOTE;
				MapNotes_MiniNote_Data.color = 0;
				MapNotes_MiniNote_Data.icon = "party";
				MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..MapNotes_MiniNote_Data.icon);
				MiniNotePOI:Show();
			end

		else
			local key = gsub(note,".*<M_N+> k<([^>]*)>.*","%1",1);
			local xPos = gsub(note,".*<M_N+>%s+%w+.*x<([^>]*)>.*","%1",1) + 0;
			local yPos = gsub(note,".*<M_N+>%s+%w+.*y<([^>]*)>.*","%1",1) + 0;
			local title = gsub(note,".*<M_N+>%s+%w+.*t<([^>]*)>.*","%1",1);
			local info1 = gsub(note,".*<M_N+>%s+%w+.*i1<([^>]*)>.*","%1",1);
			local info2 = gsub(note,".*<M_N+>%s+%w+.*i2<([^>]*)>.*","%1",1);
			local creator = gsub(note,".*<M_N+>%s+%w+.*cr<([^>]*)>.*","%1",1);
			local icon = gsub(note,".*<M_N+>%s+%w+.*i<([^>]*)>.*","%1",1)+0;
			local tcolor = gsub(note,".*<M_N+>%s+%w+.*tf<([^>]*)>.*","%1",1)+0;
			local i1color = gsub(note,".*<M_N+>%s+%w+.*i1f<([^>]*)>.*","%1",1)+0;
			local i2color = gsub(note,".*<M_N+>%s+%w+.*i2f<([^>]*)>.*","%1",1)+0;

			if MapNotes_LastReceivedNote_xPos == xPos and MapNotes_LastReceivedNote_yPos == yPos then
				-- do nothing, because the previous note is exactly the same as the current note

			else
				if ( not MapNotes_Data_Notes[key] ) then
					MapNotes_Data_Notes[key] = {};
				end
				local checknote = MapNotes_CheckNearNotes(key, xPos, yPos);
				MapNotes_LastReceivedNote_xPos = xPos;
				MapNotes_LastReceivedNote_yPos = yPos;

				if checknote then
					MapNotes_StatusPrint(format(MAPNOTES_DECLINE_NOTETONEAR, who, MapNotes_GetMapDisplayName(key), MapNotes_Data_Notes[key][checknote].name ) );
					return;
				end
				local id = 0;
				local i = MapNotes_GetZoneTableSize(MapNotes_Data_Notes[key]);

				if MapNotes_SetNextAsMiniNote ~= 2 then
					if ( ( MapNotes_AllowOneNote == 1 ) or ( MapNotes_Options[14] ~= "off" ) ) then
						MapNotes_TempData_Id = i + 1;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id] = {};
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].name = title;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].ncol = tcolor;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].inf1 = info1;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].in1c = i1color;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].inf2 = info2;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].in2c = i2color;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].creator = creator;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].icon = icon;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].xPos = xPos;
						MapNotes_Data_Notes[key][MapNotes_TempData_Id].yPos = yPos;
						id = MapNotes_TempData_Id;
						MapNotes_StatusPrint(format(MAPNOTES_ACCEPT_GET, who, MapNotes_GetMapDisplayName(key) ) );

					else
						MapNotes_StatusPrint(format(MAPNOTES_DECLINE_GET, who, MapNotes_GetMapDisplayName(key) ) );
					end
				end

				if MapNotes_SetNextAsMiniNote ~= 0 then
					MapNotes_MiniNote_Data.xPos = xPos;
					MapNotes_MiniNote_Data.yPos = xPos;
					MapNotes_MiniNote_Data.key = key;
					MapNotes_MiniNote_Data.id = id; -- only shown if the note was written...
					MapNotes_MiniNote_Data.name = title;
					MapNotes_MiniNote_Data.color = tcolor;
					MapNotes_MiniNote_Data.icon = icon;
					MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..icon);
					MiniNotePOI:Show();
					MapNotes_SetNextAsMiniNote = 0;
					MapNotes_StatusPrint(MAPNOTES_SETMININOTE);
				end
				MapNotes_AllowOneNote = 0;
			end
		end
		MapNotes_MapUpdate();
	end
end

function MapNotes_GetNoteBySlashCommand(msg)
	local returnValue = false;

	if msg ~= "" and msg ~= nil then
		msg = "<M_N> "..msg;
		local key = gsub(msg,".*<M_N+> k<([^>]*)>.*","%1",1);
		local xPos = gsub(msg,".*<M_N+>%s+%w+.*x<([^>]*)>.*","%1",1) + 0;
		local yPos = gsub(msg,".*<M_N+>%s+%w+.*y<([^>]*)>.*","%1",1) + 0;
		local title = gsub(msg,".*<M_N+>%s+%w+.*t<([^>]*)>.*","%1",1);
		local info1 = gsub(msg,".*<M_N+>%s+%w+.*i1<([^>]*)>.*","%1",1);
		local info2 = gsub(msg,".*<M_N+>%s+%w+.*i2<([^>]*)>.*","%1",1);
		local creator = gsub(msg,".*<M_N+>%s+%w+.*cr<([^>]*)>.*","%1",1);
		local icon = gsub(msg,".*<M_N+>%s+%w+.*i<([^>]*)>.*","%1",1)+0;
		local tcolor = gsub(msg,".*<M_N+>%s+%w+.*tf<([^>]*)>.*","%1",1)+0;
		local i1color = gsub(msg,".*<M_N+>%s+%w+.*i1f<([^>]*)>.*","%1",1)+0;
		local i2color = gsub(msg,".*<M_N+>%s+%w+.*i2f<([^>]*)>.*","%1",1)+0;
		local checknote = MapNotes_CheckNearNotes(continent, zone, xPos, yPos);
		local id = 0;
		local i = MapNotes_GetZoneTableSize(MapNotes_Data_Notes[key]);

		if MapNotes_SetNextAsMiniNote ~= 2 then
			if ( not MapNotes_Data_Notes[key] ) then
				MapNotes_Data_Notes[key] = {};
			end
			local checknote = MapNotes_CheckNearNotes(key, xPos, yPos);
			if checknote then
				MapNotes_StatusPrint(format(MAPNOTES_DECLINE_SLASH_NEAR, MapNotes_Data_Notes[key][checknote].name, MapNotes_GetMapDisplayName(key) ) );
				returnValue = false;
			else
				MapNotes_TempData_Id = i + 1;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id] = {};
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].name = title;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].ncol = tcolor;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].inf1 = info1;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].in1c = i1color;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].inf2 = info2;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].in2c = i2color;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].creator = creator;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].icon = icon;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].xPos = xPos;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].yPos = yPos;
				id = MapNotes_TempData_Id;
				MapNotes_StatusPrint(format(MAPNOTES_ACCEPT_SLASH, MapNotes_GetMapDisplayName(key) ) );
				returnValue = true;
			end
		end
		if MapNotes_SetNextAsMiniNote ~= 0 then
			MapNotes_MiniNote_Data.xPos = xPos;
			MapNotes_MiniNote_Data.yPos = yPos;
			MapNotes_MiniNote_Data.key = key;
			MapNotes_MiniNote_Data.id = id; -- only shown if the note was written...
			MapNotes_MiniNote_Data.name = title;
			MapNotes_MiniNote_Data.color = tcolor;
			MapNotes_MiniNote_Data.icon = icon;
			MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..icon);
			MiniNotePOI:Show();
			MapNotes_SetNextAsMiniNote = 0;
			MapNotes_StatusPrint(MAPNOTES_SETMININOTE);
		end
	else
		MapNotes_StatusPrint(MAPNOTES_MAPNOTEHELP);
		returnValue = false;
	end

	return returnValue;
end

function MapNotes_Quicktloc(msg)
	if msg == "" then
		MapNotes_StatusPrint(MAPNOTES_QUICKTLOC_NOARGUMENT);

	else
		local data = strsub(msg, 1, 5);
		msg = strsub(msg, 7);
		local i,j,x,y = string.find(data,"(%d+),(%d+)");
		local key = MapNotes_GetMapKey();
		x = x / 100;
		y = y / 100;
		local checknote = MapNotes_CheckNearNotes(key, x, y);
		if checknote then
			MapNotes_StatusPrint(format(MAPNOTES_QUICKNOTE_NOTETONEAR,
						   MapNotes_Data_Notes[key][checknote].name ) );

		else
			local id = 0;
			local icon = 0;
			local name = MAPNOTES_THOTTBOTLOC;
			if msg ~= "" and msg ~= nil then
				local icheck = strsub(msg, 1, 2);
				if strlen(icheck) == 1 then
					icheck = icheck.." ";
				end
				if icheck == "0 " or icheck == "1 " or icheck == "2 " or icheck == "3 " or
						icheck == "4 " or icheck == "5 " or icheck == "6 " or icheck == "7 " or
						icheck == "8 " or icheck == "9 " then
					icon = strsub(msg, 1, 1)+0;
					msg = strsub(msg, 3);
				end
				if msg ~= "" and msg ~= nil then
					name = strsub(msg, 1, 80);
				end
			end

			if MapNotes_SetNextAsMiniNote ~= 2 then
				local i = MapNotes_GetZoneTableSize(MapNotes_Data_Notes[key]);
				MapNotes_TempData_Id = i + 1;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id] = {};
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].name = name;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].ncol = 0;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].inf1 = "";
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].in1c = 0;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].inf2 = "";
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].in2c = 0;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].creator = UnitName("player");
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].icon = icon;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].xPos = x;
				MapNotes_Data_Notes[key][MapNotes_TempData_Id].yPos = y;
				id = MapNotes_TempData_Id;
				MapNotes_StatusPrint(format(MAPNOTES_QUICKNOTE_OK, MapNotes_GetMapDisplayName(key) ) );
			end

			if MapNotes_SetNextAsMiniNote ~= 0 then
				MapNotes_MiniNote_Data.xPos = x;
				MapNotes_MiniNote_Data.yPos = y;
				MapNotes_MiniNote_Data.key = key;
				MapNotes_MiniNote_Data.id = id; -- only shown if the note was written...
				MapNotes_MiniNote_Data.name = name;
				MapNotes_MiniNote_Data.color = 0;
				MapNotes_MiniNote_Data.icon = icon;
				MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..icon);
				MiniNotePOI:Show();
				MapNotes_SetNextAsMiniNote = 0;
				MapNotes_StatusPrint(MAPNOTES_SETMININOTE);
			end
		end
	end
end

function MapNotes_Quicknote(msg)
	MapNotes_CreateQuickNote(msg);
end

function MapNotes_CreateQuestNote(name, lin, olin, x, y, icon, selected)
	local fx, fy = GetPlayerMapPosition("player");
	--if selected then
	--	DEFAULT_CHAT_FRAME:AddMessage("Selected marker " .. name, 0.95, 0.95, 0.5);
	--end
	if ( ( ( fx ) and ( fx == 0 ) ) and ( ( fy ) and ( fy == 0 ) ) ) then
		SetMapToCurrentZone();
	end

	local key = MapNotes_GetMapKey();
	local currentZone = MapNotes_Data_Notes[key];
	local checknote = MapNotes_CheckNearNotes(key, x, y);

	--if ( ( checknote ) and ( shouldMerge ) ) then
	--	MapNotes_Merge(key, checknote, msg, msg2);
	--	return;
	--end

	--if ( checknote ) then
	--	MapNotes_StatusPrint(format(MAPNOTES_QUICKNOTE_NOTETONEAR,
	--				   MapNotes_Data_Notes[key][checknote].name ) );

	--elseif ( ( x == 0 ) and ( y == 0 ) ) then
	--	MapNotes_StatusPrint(MAPNOTES_QUICKNOTE_NOPOSITION);

	--else
		local id = 0;
		--local icon = 0;
		if msg ~= "" and msg ~= nil then
			local icheck = strsub(msg, 1, 2);
			if icheck == "0 " or icheck == "1 " or icheck == "2 " or icheck == "3 " or
					icheck == "4 " or icheck == "5 " or icheck == "6 " or icheck == "7 " or
					icheck == "8 " or icheck == "9 " then
				icon = strsub(msg, 1, 1)+0;
				msg = strsub(msg, 3);
			end

			if msg ~= "" and msg ~= nil then
				name = strsub(msg, 1, 80);
			end
		end

		if ( not msg2 ) then
			msg2 = "";
		end

		if MapNotes_SetNextAsMiniNote ~= 2 then
			local i = MapNotes_GetZoneTableSize(currentZone);
			MapNotes_TempData_Id = i + 1;
			currentZone[MapNotes_TempData_Id] = {};
			currentZone[MapNotes_TempData_Id].name = name;
			currentZone[MapNotes_TempData_Id].ncol = 8;
			currentZone[MapNotes_TempData_Id].inf1 = lin;
			currentZone[MapNotes_TempData_Id].in1c = 4;
			currentZone[MapNotes_TempData_Id].inf2 = olin;
			currentZone[MapNotes_TempData_Id].in2c = 0;
			currentZone[MapNotes_TempData_Id].creator = "Questie";
			currentZone[MapNotes_TempData_Id].icon = icon;
			currentZone[MapNotes_TempData_Id].xPos = x;
			currentZone[MapNotes_TempData_Id].yPos = y;
			id = MapNotes_TempData_Id;
			--MapNotes_StatusPrint(format(MAPNOTES_QUICKNOTE_OK, GetRealZoneText()));
		end
		if (MapNotes_SetNextAsMiniNote ~= 0) or selected then
			MapNotes_MiniNote_Data.xPos = x;
			MapNotes_MiniNote_Data.yPos = y;
			MapNotes_MiniNote_Data.key = key;
			MapNotes_MiniNote_Data.id = id; -- only shown if the note was written...
			MapNotes_MiniNote_Data.name = name;
			MapNotes_MiniNote_Data.color = 0;
			MapNotes_MiniNote_Data.icon = icon;
			MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..icon);
			MiniNotePOI:Show();
			MapNotes_SetNextAsMiniNote = 0;
			--MapNotes_StatusPrint(MAPNOTES_SETMININOTE);
		end
	--end
end

function MapNotes_CreateQuickNote(msg, msg2, shouldMerge)
	local x, y = GetPlayerMapPosition("player");

	if ( ( ( x ) and ( x == 0 ) ) and ( ( y ) and ( y == 0 ) ) ) then
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition("player");
	end
	
	DEFAULT_CHAT_FRAME:AddMessage("   X: " .. x, 0.2, 0.9, 0.2);
	DEFAULT_CHAT_FRAME:AddMessage("   Y: " .. y, 0.2, 0.9, 0.2);

	local key = MapNotes_GetMapKey();
	local currentZone = MapNotes_Data_Notes[key];
	local checknote = MapNotes_CheckNearNotes(key, x, y);

	if ( ( checknote ) and ( shouldMerge ) ) then
		MapNotes_Merge(key, checknote, msg, msg2);
		return;
	end

	if ( checknote ) then
		MapNotes_StatusPrint(format(MAPNOTES_QUICKNOTE_NOTETONEAR,
					   MapNotes_Data_Notes[key][checknote].name ) );

	elseif ( ( x == 0 ) and ( y == 0 ) ) then
		MapNotes_StatusPrint(MAPNOTES_QUICKNOTE_NOPOSITION);

	else
		local id = 0;
		local icon = 0;
		local name = MAPNOTES_QUICKNOTE_DEFAULTNAME;
		if msg ~= "" and msg ~= nil then
			local icheck = strsub(msg, 1, 2);
			if icheck == "0 " or icheck == "1 " or icheck == "2 " or icheck == "3 " or
					icheck == "4 " or icheck == "5 " or icheck == "6 " or icheck == "7 " or
					icheck == "8 " or icheck == "9 " then
				icon = strsub(msg, 1, 1)+0;
				msg = strsub(msg, 3);
			end

			if msg ~= "" and msg ~= nil then
				name = strsub(msg, 1, 80);
			end
		end

		if ( not msg2 ) then
			msg2 = "";
		end

		if MapNotes_SetNextAsMiniNote ~= 2 then
			local i = MapNotes_GetZoneTableSize(currentZone);
			MapNotes_TempData_Id = i + 1;
			currentZone[MapNotes_TempData_Id] = {};
			currentZone[MapNotes_TempData_Id].name = name;
			currentZone[MapNotes_TempData_Id].ncol = 0;
			currentZone[MapNotes_TempData_Id].inf1 = msg2;
			currentZone[MapNotes_TempData_Id].in1c = 0;
			currentZone[MapNotes_TempData_Id].inf2 = "";
			currentZone[MapNotes_TempData_Id].in2c = 0;
			currentZone[MapNotes_TempData_Id].creator = UnitName("player");
			currentZone[MapNotes_TempData_Id].icon = icon;
			currentZone[MapNotes_TempData_Id].xPos = x;
			currentZone[MapNotes_TempData_Id].yPos = y;
			id = MapNotes_TempData_Id;
			MapNotes_StatusPrint(format(MAPNOTES_QUICKNOTE_OK, GetRealZoneText()));
		end
		if MapNotes_SetNextAsMiniNote ~= 0 then
			MapNotes_MiniNote_Data.xPos = x;
			MapNotes_MiniNote_Data.yPos = y;
			MapNotes_MiniNote_Data.key = key;
			MapNotes_MiniNote_Data.id = id; -- only shown if the note was written...
			MapNotes_MiniNote_Data.name = name;
			MapNotes_MiniNote_Data.color = 0;
			MapNotes_MiniNote_Data.icon = icon;
			MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..icon);
			MiniNotePOI:Show();
			MapNotes_SetNextAsMiniNote = 0;
			MapNotes_StatusPrint(MAPNOTES_SETMININOTE);
		end
	end
end



function MapNotes_Misc_OnClick(button, lclFrame)
	CloseDropDownMenus();

	if not MapNotes_FramesHidden() then
		return;
	elseif not MapNotes_MenusHidden() then
		MapNotes_HideMenus();
	end

	local key = MapNotes_GetMapKey();

	if ( not lclFrame ) then				--Telic_1
		lclFrame = WorldMapButton;			--Telic_1
		MAPNOTES_ACTIVE_PLUGIN = nil;			--Telic_2
	end							--Telic_1
	local ax, ay = MapNotes_GetMouseXY(lclFrame);		--Telic_1

	if button == "LeftButton" then
		if this:GetID() == 0 then
			MapNotesButtonNewNote:Enable();
			MapNotes_ShowNewFrame(MapNotes_tloc_xPos, MapNotes_tloc_yPos);
			if MapNotes_FramesHidden() then
				MapNotes_TempData_Id = 0;
			end
		elseif this:GetID() == 1 then
			MapNotesButtonNewNote:Disable();
			MapNotes_ShowNewFrame(ax, ay);
			if MapNotes_FramesHidden() then
				MapNotes_TempData_Id = -1;
			end
		end

	elseif button == "RightButton" then

		if ( IsShiftKeyDown() ) then
			if ( this == MapNotesPOIparty ) then						--Telic_7
				MapNotes_PartyNoteData.xPos = nil;					--Telic_7
				MapNotes_PartyNoteData.yPos = nil;					--Telic_7
				MapNotes_PartyNoteData.key = nil;					--Telic_7
				MapNotesPOIparty:Hide();						--Telic_7
				if ( MapNotes_MiniNote_Data.icon == "party" ) then
					MapNotes_ClearMiniNote(true);
				end
				return;									--Telic_7
			end										--Telic_7
		end											--Telic_7

		local xOffset, yOffset = MapNotes_GetAdjustedMapXY(lclFrame, ax, ay);			--Telic_1
		MapNotesPOIMenuFrame:ClearAllPoints();							--Telic_1
		MapNotesPOIMenuFrame:SetPoint("CENTER", lclFrame, "TOPLEFT", xOffset, yOffset);		--Telic_1
		MapNotesNewMenuFrame:Hide();
		MapNotesButtonEditNote:Disable();
		MapNotesButtonSendNote:Disable();
		WorldMapTooltip:Hide();
		MapNotesPOIMenuFrame:Show();

		if this:GetID() == 0 then
			MapNotes_TempData_Id = 0;
		elseif this:GetID() == 1 then
			MapNotes_TempData_Id = -1;
		end
	end
end

function MapNotes_NextMiniNote(msg)
	msg = string.lower(msg);
	if msg == "on" then
		MapNotes_SetNextAsMiniNote = 1;
		MapNotes_StatusPrint(MAPNOTES_MININOTE_SHOW_1);
	elseif msg == "off" then
		MapNotes_SetNextAsMiniNote = 0;
		MapNotes_StatusPrint(MAPNOTES_MININOTE_SHOW_0);
	elseif MapNotes_SetNextAsMiniNote == 1 then
		MapNotes_SetNextAsMiniNote = 0;
		MapNotes_StatusPrint(MAPNOTES_MININOTE_SHOW_0);
	else
		MapNotes_SetNextAsMiniNote = 1;
		MapNotes_StatusPrint(MAPNOTES_MININOTE_SHOW_1);
	end
end

function MapNotes_NextMiniNoteOnly(msg)
	msg = string.lower(msg);
	if msg == "on" then
		MapNotes_SetNextAsMiniNote = 2;
		MapNotes_StatusPrint(MAPNOTES_MININOTE_SHOW_2);
	elseif msg == "off" then
		MapNotes_SetNextAsMiniNote = 0;
		MapNotes_StatusPrint(MAPNOTES_MININOTE_SHOW_0);
	elseif MapNotes_SetNextAsMiniNote == 2 then
		MapNotes_SetNextAsMiniNote = 0;
		MapNotes_StatusPrint(MAPNOTES_MININOTE_SHOW_0);
	else
		MapNotes_SetNextAsMiniNote = 2;
		MapNotes_StatusPrint(MAPNOTES_MININOTE_SHOW_2);
	end
end

function MapNotes_OneNote(msg)
	msg = string.lower(msg);
	if msg == "on" then
		MapNotes_AllowOneNote = 1;
		MapNotes_StatusPrint(MAPNOTES_ONENOTE_ON);
	elseif msg == "off" then
		MapNotes_AllowOneNote = 0;
		MapNotes_StatusPrint(MAPNOTES_ONENOTE_OFF);
	elseif MapNotes_AllowOneNote == 1 then
		MapNotes_AllowOneNote = 0;
		MapNotes_StatusPrint(MAPNOTES_ONENOTE_OFF);
	else
		MapNotes_AllowOneNote = 1;
		MapNotes_StatusPrint(MAPNOTES_ONENOTE_ON);
	end
end

function MapNotes_OnEvent()
	if ( event == "MINIMAP_UPDATE_ZOOM" ) then
		MapNotes_MinimapUpdateZoom();

	elseif ( event == "VARIABLES_LOADED" ) then
		MapNotes_VariablesLoaded();
		MapNotes_Started = true;

	elseif ( event == "WORLD_MAP_UPDATE" ) then
		if ( ( MapNotes_Options.landMarks ) and ( MapNotes_Started ) ) then
			MapNotes_IterateLandMarks(false);
		end
		MapNotes_WorldMapButton_OnUpdate();

	elseif ( event == "CHAT_MSG_ADDON" ) then
		if ( arg1 == "MapNotes_FU" ) then
			MapNotes_GetNoteFromChat(arg2, arg4);
		end
	end
end

function MapNotes_MinimapUpdateZoom()
	if MapNotes_MiniNote_MapzoomInit then
		if MapNotes_MiniNote_IsInCity then
			MapNotes_MiniNote_IsInCity = false;
		else
			MapNotes_MiniNote_IsInCity = true;
		end
	else
		local tempzoom = 0;
		if GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") then
			if GetCVar("minimapInsideZoom")+0 >= 3 then
				Minimap:SetZoom(Minimap:GetZoom() - 1);
				tempzoom = 1;
			else
				Minimap:SetZoom(Minimap:GetZoom() + 1);
				tempzoom = -1;
			end
		end

		if GetCVar("minimapInsideZoom")+0 == Minimap:GetZoom() then
			MapNotes_MiniNote_IsInCity = true;
		else
			MapNotes_MiniNote_IsInCity = false;
		end

		Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
		MapNotes_MiniNote_MapzoomInit = true;
	end
end

function MapNotes_ChatFrame_OnEvent(event)
	if ( ( strsub(event, 1, 16) == "CHAT_MSG_WHISPER" ) and ( strsub(arg1, 1, 5) == "<M_N>" ) ) then
		if strsub(event, 17) == "_INFORM" then
			-- do nothing
		else
			MapNotes_GetNoteFromChat(arg1, arg2);
		end

	else
		orig_ChatFrame_OnEvent(event);
	end
end

function MapNotes_MiniNote_OnUpdate(elapsed)
	if ( MapNotes_MiniNote_Data.xPos ~= nil ) then
		MiniNotePOI.TimeSinceLastUpdate = MiniNotePOI.TimeSinceLastUpdate + elapsed;

		if ( MiniNotePOI.TimeSinceLastUpdate > MapNotes_Mininote_UpdateRate ) then
			local zoneText = GetRealZoneText();
			local map = GetMapInfo();
			local key = MapNotes_GetMapKey();

			if ( MapNotes_MiniNote_Data.key ~= key ) then
				return;
			end

			local x, y = GetPlayerMapPosition("player");

			if x == 0 and y == 0 then
				MiniNotePOI:Hide();
				return;
			end

			if ( ( MapNotes_Keys[key] ) and ( MapNotes_Keys[key].miniData ) ) then
				local currentConst = MapNotes_Keys[key].miniData;

				local currentZoom = Minimap:GetZoom();

				if ( ( currentConst ) and ( currentConst.scale ~= 0 ) ) then
					local xscale,yscale;
					if GetCurrentMapZone() > 0 then
						xscale = MapNotes_MiniConst[GetCurrentMapContinent()][currentZoom].xscale;
						yscale = MapNotes_MiniConst[GetCurrentMapContinent()][currentZoom].yscale;
					else
						xscale = MapNotes_MiniConst[2][currentZoom].xscale;
						yscale = MapNotes_MiniConst[2][currentZoom].yscale;
					end

					if MapNotes_MiniNote_IsInCity then
						xscale = xscale * MapNotes_CityConst[currentZoom].cityscale;
						yscale = yscale * MapNotes_CityConst[currentZoom].cityscale;
					end

					local xpos = MapNotes_MiniNote_Data.xPos * currentConst.scale + currentConst.xoffset;
					local ypos = MapNotes_MiniNote_Data.yPos * currentConst.scale + currentConst.yoffset;

					x = x * currentConst.scale + currentConst.xoffset;
					y = y * currentConst.scale + currentConst.yoffset;

					local deltax = (xpos - x) * xscale;
					local deltay = (ypos - y) * yscale;
					if sqrt( (deltax * deltax) + (deltay * deltay) ) > 56.5 then
						local adjust = 1;
						if deltax == 0 then
							deltax = deltax + 0.0000000001;
						elseif deltax < 0 then
							adjust = -1;
						end
						local m = math.atan(deltay / deltax);
						deltax = math.cos(m) * 57 * adjust;
						deltay = math.sin(m) * 57 * adjust;
					end

					MiniNotePOI:SetPoint("CENTER", "MinimapCluster", "TOPLEFT", 105 + deltax, -93 - deltay);
					MiniNotePOI:Show();
				else
					MiniNotePOI:Hide();
				end
			end
		end

		MiniNotePOI.TimeSinceLastUpdate = 0;
	else
		MiniNotePOI:Hide();
	end
end

function MapNotes_ShowNewFrame(ax, ay, lclFrame)
	if MapNotes_FramesHidden() then
		if ( not lclFrame ) then						--Telic_1
			lclFrame = WorldMapButton;					--Telic_1
			MAPNOTES_ACTIVE_PLUGIN = nil;					--Telic_2
		end									--Telic_1

		MapNotes_TempData_xPos = ax;
		MapNotes_TempData_yPos = ay;
		MapNotes_TempData_Id = nil;

		local xOffset, yOffset = MapNotes_GetAdjustedMapXY(lclFrame, ax, ay);				--Telic_1	(New Utilities function)
		MapNotesNewMenuFrame:SetParent(lclFrame);							--Telic_2
		MapNotesNewMenuFrame:ClearAllPoints();								--Telic_1
		MapNotesNewMenuFrame:SetPoint("CENTER", lclFrame, "TOPLEFT", xOffset, yOffset);			--Telic_1

		if ( not MapNotes_MiniNote_Data.xPos ) then
			MapNotesButtonMiniNoteOff:Disable();
		else
			MapNotesButtonMiniNoteOff:Enable();
		end
		MapNotesPOIMenuFrame:Hide();
		MapNotesSpecialActionMenuFrame:Hide();

		MapNotesNewMenuFrame:Show();
	end
end

function MapNotes_ShowSpecialActionsFrame()

	MapNotesPOIMenuFrame:Hide();

	MapNotesSpecialActionMenuFrame:ClearAllPoints();							--Telic_1
	MapNotesSpecialActionMenuFrame:SetPoint("CENTER", MapNotesPOIMenuFrame, "CENTER");
	MapNotesSpecialActionMenuFrame:SetParent( MapNotesPOIMenuFrame:GetParent() );				--Telic_2

	if ( MapNotes_TempData_Id < 1 ) then
		MapNotesButtonToggleLine:Disable()
--	elseif 	( MapNotesSpecialActionMenuFrame:GetParent() ~= WorldMapFrame ) and				--Telic_2
--		( MapNotesSpecialActionMenuFrame:GetParent() ~= WorldMapButton ) then				--Telic_2
--		MapNotesButtonToggleLine:Disable();								--Telic_2
	else
		MapNotesButtonToggleLine:Enable();
	end
	MapNotesSpecialActionMenuFrame:Show();
end

function MapNotes_Edit_SetIcon(icon)
	MapNotes_TempData_Icon = icon;
	IconOverlay:SetPoint("TOPLEFT", "EditIcon"..icon, "TOPLEFT", -3, 3);
end

function MapNotes_Edit_SetTextColor(color)
	MapNotes_TempData_TextColor = color;
	TextColorOverlay:SetPoint("TOPLEFT", "TextColor"..color, "TOPLEFT", -3, 3);
end

function MapNotes_Edit_SetInfo1Color(color)
	MapNotes_TempData_Info1Color = color;
	Info1ColorOverlay:SetPoint("TOPLEFT", "Info1Color"..color, "TOPLEFT", -3, 3);
end

function MapNotes_Edit_SetInfo2Color(color)
	MapNotes_TempData_Info2Color = color;
	Info2ColorOverlay:SetPoint("TOPLEFT", "Info2Color"..color, "TOPLEFT", -3, 3);
end

function MapNotes_OpenEditForExistingNote(id)
	MapNotes_HideAll();

	local currentZone;
	local lclFrame = WorldMapButton;						--Telic_2

	if ( MAPNOTES_ACTIVE_PLUGIN ) then						--Telic_2
		local key = MapNotes_PlugInsGetKey(MAPNOTES_ACTIVE_PLUGIN);		--Telic_2
		currentZone = MapNotes_Data_Notes[key];					--Telic_2
		lclFrame = getglobal( MAPNOTES_ACTIVE_PLUGIN.frame );

	else										--Telic_2
		currentZone =  MapNotes_Data_Notes[ MapNotes_GetMapKey() ];
	end										--Telic_2

	MapNotes_TempData_Id = id;
	MapNotes_TempData_Creator = currentZone[MapNotes_TempData_Id].creator;
	MapNotes_TempData_xPos = currentZone[MapNotes_TempData_Id].xPos;
	MapNotes_TempData_yPos = currentZone[MapNotes_TempData_Id].yPos;
	MapNotes_Edit_SetIcon(currentZone[MapNotes_TempData_Id].icon);
	MapNotes_Edit_SetTextColor(currentZone[MapNotes_TempData_Id].ncol);
	MapNotes_Edit_SetInfo1Color(currentZone[MapNotes_TempData_Id].in1c);
	MapNotes_Edit_SetInfo2Color(currentZone[MapNotes_TempData_Id].in2c);
	TitleWideEditBox:SetText(currentZone[MapNotes_TempData_Id].name);
	Info1WideEditBox:SetText(currentZone[MapNotes_TempData_Id].inf1);
	Info2WideEditBox:SetText(currentZone[MapNotes_TempData_Id].inf2);
	CreatorWideEditBox:SetText(currentZone[MapNotes_TempData_Id].creator);
	MapNotesEditFrame:SetParent(lclFrame);
	MapNotesEditFrame:Show();
end

function MapNotes_ShowSendFrame(number)
	local lclFrame = WorldMapButton;

	if ( MAPNOTES_ACTIVE_PLUGIN ) then
		local key = MapNotes_PlugInsGetKey(MAPNOTES_ACTIVE_PLUGIN);
		lclFrame = getglobal( MAPNOTES_ACTIVE_PLUGIN.frame );
	end

	if ( number == 1 ) then
		MapNotesSendPlayer:Enable();

		MapNotesSendParty:Enable();

		MapNotesChangeSendFrame:SetText(MAPNOTES_SLASHCOMMAND);
		SendWideEditBox:SetText("");
		if UnitCanCooperate("player", "target") then
			SendWideEditBox:SetText(UnitName("target"));
		end
		MapNotes_SendFrame_Title:SetText(MAPNOTES_SEND_TITLE);
		MapNotes_SendFrame_Tip:SetText(MAPNOTES_SEND_TIP);
		MapNotes_SendFrame_Player:SetText(MAPNOTES_SEND_PLAYER);
		MapNotes_ToggleSendValue = 2;
	elseif ( number == 2 ) then
		MapNotesSendPlayer:Disable();
		MapNotesSendParty:Disable();
		MapNotesChangeSendFrame:SetText(MAPNOTES_SHOWSEND);
		SendWideEditBox:SetText("/mapnote"..MapNotes_GenerateSendString(2));
		MapNotes_SendFrame_Title:SetText(MAPNOTES_SEND_SLASHTITLE);
		MapNotes_SendFrame_Tip:SetText(MAPNOTES_SEND_SLASHTIP);
		MapNotes_SendFrame_Player:SetText(MAPNOTES_SEND_SLASHCOMMAND);
		MapNotes_ToggleSendValue = 1;
	end
	if not MapNotesSendFrame:IsVisible() then
		MapNotes_HideAll();
		MapNotesSendFrame:SetParent(lclFrame);
		MapNotesSendFrame:Show();
	end
end

function MapNotes_GenerateSendString(version)
-- <M_N> k<1> x<0.123123> y<0.123123> t<> i1<> i2<> cr<> i<8> tf<3> i1f<5> i2f<6>
	local text = "";
	local upperLimit = 177;

	if version == 1 then
		text = "<M_N> ";
	end

	local key;

	if ( MAPNOTES_ACTIVE_PLUGIN ) then
		key = MapNotes_PlugInsGetKey(MAPNOTES_ACTIVE_PLUGIN);
	else
		key = MapNotes_GetMapKey();
	end
	local currentZone = MapNotes_Data_Notes[key];

	local keyLen = string.len(key);
	upperLimit = upperLimit - keyLen;
	local t1 = MapNotes_EliminateUsedChars(currentZone[MapNotes_TempData_Id].name);
	local t2 = MapNotes_EliminateUsedChars(currentZone[MapNotes_TempData_Id].inf1);
	local t3 = MapNotes_EliminateUsedChars(currentZone[MapNotes_TempData_Id].inf2);
	local cr = MapNotes_EliminateUsedChars(currentZone[MapNotes_TempData_Id].creator);
	local truncated;
	t1, t2, t3, cr, truncated = MapNotes_CheckLength(t1, t2, t3, cr, upperLimit);

	text = text.."k<"..key..">"
	local xPos = floor(currentZone[MapNotes_TempData_Id].xPos * 1000000)/1000000; --cut to six digits behind the 0
	local yPos = floor(currentZone[MapNotes_TempData_Id].yPos * 1000000)/1000000;
	text = text.." x<"..xPos.."> y<"..yPos..">";
	text = text.." t<".. t1 ..">";
	text = text.." i1<".. t2 ..">";
	text = text.." i2<".. t3 ..">";
	if not currentZone[MapNotes_TempData_Id].creator then
		currentZone[MapNotes_TempData_Id].creator = UnitName("player");
	end
	text = text.." cr<"..cr..">";
	text = text.." i<"..currentZone[MapNotes_TempData_Id].icon..">";
	text = text.." tf<"..currentZone[MapNotes_TempData_Id].ncol..">";
	text = text.." i1f<"..currentZone[MapNotes_TempData_Id].in1c..">";
	text = text.." i2f<"..currentZone[MapNotes_TempData_Id].in2c..">";

	if ( ( version == 1 ) and ( truncated ) ) then
		MapNotes_StatusPrint(MAPNOTES_TRUNCATION_WARNING);
	end

	return text;
end

function MapNotes_CheckLength(t1, t2, t3, cr, upperLimit)
	local l1 = string.len(t1);
	local l2 = string.len(t2);
	local l3 = string.len(t3);
	local l4 = string.len(cr);
	local truncated;

	if ( l1 > upperLimit ) then
		t1 = string.sub(t1, 1, upperLimit);
		t2 = "";
		t3 = "";
		cr = "";
		truncated = true;

	elseif ( (l1+l2) > upperLimit ) then
		t2 = string.sub(t2, 1, (upperLimit-l1));
		t3 = "";
		cr = "";
		truncated = true;

	elseif ( (l1+l2+l3) > upperLimit ) then
		t3 = string.sub(t3, 1, (upperLimit-l1-l2));
		cr = "";
		truncated = true;

	elseif ( (l1+l2+l3+l4) > upperLimit ) then
		cr = string.sub(cr, 1, (upperLimit-l1-l2-l3));
		truncated = true;

	end

	return t1, t2, t3, cr, truncated;
end

function MapNotes_EliminateUsedChars(text)
	text = string.gsub(text, "<", "");
	text = string.gsub(text, ">", "");
	return text;
end

function MapNotes_SendNote(type)
	if type == 1 then
		SendChatMessage(MapNotes_GenerateSendString(1), "WHISPER", this.language, SendWideEditBox:GetText());
		MapNotes_HideAll();

	elseif ( type == 2 ) then									--Telic_6
		local msg = MapNotes_GenerateSendString(1);						--Telic_6
		SendAddonMessage( "MapNotes_FU", msg, "PARTY" );					--Telic_6
	end
end

function MapNotes_OpenOptionsFrame()
	for i=0, 16, 1 do
		if MapNotes_Options[i] ~= "off" then
			getglobal("MapNotesOptionsCheckbox"..i):SetChecked(1);
		else
			getglobal("MapNotesOptionsCheckbox"..i):SetChecked(0);
		end
	end
	if ( MapNotes_Options.mapC ) then
		MapNotesOptionsCheckboxMapC:SetChecked(1);
	else
		MapNotesOptionsCheckboxMapC:SetChecked(0);
	end
	if ( MapNotes_Options.miniC ) then
		MapNotesOptionsCheckboxMiniC:SetChecked(1);
	else
		MapNotesOptionsCheckboxMiniC:SetChecked(0);
	end
	if ( MapNotes_Options.landMarks ) then
		MapNotesOptionsCheckboxLM:SetChecked(1);
	else
		MapNotesOptionsCheckboxLM:SetChecked(0);
	end
end

function MapNotes_WriteOptions()
	for i=0, 16, 1 do
		if getglobal("MapNotesOptionsCheckbox"..i):GetChecked() then
			MapNotes_Options[i] = nil;
		else
			MapNotes_Options[i] = "off";
		end
	end
--	MapNotesOptionsFrame:Hide();
	MapNotes_PlugInsRefresh();							--Telic_2
	MapNotes_MapUpdate();								--Telic_2
end

function MapNotes_SetAsMiniNote(id)
	local key = MapNotes_GetMapKey();
	local currentZone = MapNotes_Data_Notes[key];

	MapNotes_MiniNote_Data.key = key;

	MapNotes_MiniNote_Data.id = id -- able to show, because there wasn't a delete and its not received for showing on Minimap only
	if id == 0 then
		MapNotes_MiniNote_Data.xPos = MapNotes_tloc_xPos;
		MapNotes_MiniNote_Data.yPos = MapNotes_tloc_yPos;
		MapNotes_MiniNote_Data.name = MAPNOTES_THOTTBOTLOC;
		MapNotes_MiniNote_Data.color = 0;
		MapNotes_MiniNote_Data.icon = "tloc";
		MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..MapNotes_MiniNote_Data.icon);
		MiniNotePOI:Show();

	elseif id == -1 then
		MapNotes_MiniNote_Data.xPos = MapNotes_PartyNoteData.xPos;
		MapNotes_MiniNote_Data.yPos = MapNotes_PartyNoteData.yPos;
		MapNotes_MiniNote_Data.name = MAPNOTES_PARTYNOTE;
		MapNotes_MiniNote_Data.color = 0;
		MapNotes_MiniNote_Data.icon = "party";
		MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..MapNotes_MiniNote_Data.icon);
		MiniNotePOI:Show();

	else
		MapNotes_MiniNote_Data.xPos = currentZone[id].xPos;
		MapNotes_MiniNote_Data.yPos = currentZone[id].yPos;
		MapNotes_MiniNote_Data.name = currentZone[id].name;
		MapNotes_MiniNote_Data.color = currentZone[id].ncol;
		MapNotes_MiniNote_Data.icon = currentZone[id].icon;
		MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..MapNotes_MiniNote_Data.icon);
		MiniNotePOI:Show();
	end

	MapNotes_MapUpdate();
end

function MapNotes_ClearMiniNote(skipMapUpdate)
	MapNotes_MiniNote_Data.xPos = nil;
	MapNotes_MiniNote_Data.yPos = nil;
	MapNotes_MiniNote_Data.key = nil;
	MapNotes_MiniNote_Data.id = 0; -- nothing to show on the zone map
	MapNotes_MiniNote_Data.name = nil;
	MapNotes_MiniNote_Data.color = nil;
	MapNotes_MiniNote_Data.icon = nil;
	MiniNotePOI:Hide();

	if not skipMapUpdate then
		MapNotes_MapUpdate();
	end
end



function MapNotes_WriteNote()
	MapNotes_HideAll();

	local currentZone;
	local continent, zone = "nil", "nil";								--Telic_2 (Deliberately string nils)

	if ( MAPNOTES_ACTIVE_PLUGIN ) then								--Telic_2
		local key = MapNotes_PlugInsGetKey(MAPNOTES_ACTIVE_PLUGIN);				--Telic_2
		if ( key ) then										--Telic_2
			currentZone = MapNotes_Data_Notes[key];						--Telic_2
		else											--Telic_2

			return;										--Telic_2
		end											--Telic_2

	else												--Telic_2
		currentZone = MapNotes_Data_Notes[ MapNotes_GetMapKey() ];
	end												--Telic_2

	currentZone[MapNotes_TempData_Id] = {};
	currentZone[MapNotes_TempData_Id].name = TitleWideEditBox:GetText();
	currentZone[MapNotes_TempData_Id].ncol = MapNotes_TempData_TextColor;
	currentZone[MapNotes_TempData_Id].inf1 = Info1WideEditBox:GetText();
	currentZone[MapNotes_TempData_Id].in1c = MapNotes_TempData_Info1Color;
	currentZone[MapNotes_TempData_Id].inf2 = Info2WideEditBox:GetText();
	currentZone[MapNotes_TempData_Id].in2c = MapNotes_TempData_Info2Color;
	currentZone[MapNotes_TempData_Id].creator = CreatorWideEditBox:GetText();
	currentZone[MapNotes_TempData_Id].icon = MapNotes_TempData_Icon;
	currentZone[MapNotes_TempData_Id].xPos = MapNotes_TempData_xPos;
	currentZone[MapNotes_TempData_Id].yPos = MapNotes_TempData_yPos;

	if ( ( key == MapNotes_MiniNote_Data.key ) and ( MapNotes_MiniNote_Data.id == MapNotes_TempData_Id ) ) then
		MapNotes_MiniNote_Data.name = TitleWideEditBox:GetText();
		MapNotes_MiniNote_Data.icon = MapNotes_TempData_Icon;
		MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..MapNotes_MiniNote_Data.icon);
		MapNotes_MiniNote_Data.color = MapNotes_TempData_TextColor;
	end

	if ( MAPNOTES_ACTIVE_PLUGIN ) then								--Telic_2
		MapNotes_PlugInsDrawNotes(MAPNOTES_ACTIVE_PLUGIN);					--Telic_2
		MAPNOTES_ACTIVE_PLUGIN = nil;								--Telic_2 Reset after saving/drawing
	else												--Telic_2
		MapNotes_MapUpdate();
	end												--Telic_2
end

function MapNotes_MapUpdate()
	if WorldMapButton:IsVisible() then
		MapNotes_WorldMapButton_OnUpdate();
	end
	if Minimap:IsVisible() then
		Minimap_OnUpdate(0.0);					--Telic_* (Lack of argument can cause error in Minimap.lua)
	end
end

function MapNotes_HideAll()
	-- menus
	MapNotesNewMenuFrame:Hide();
	MapNotesPOIMenuFrame:Hide();
	MapNotesSpecialActionMenuFrame:Hide();

	-- dialogs
	MapNotesEditFrame:Hide();
	MapNotesOptionsFrame:Hide();
	MapNotesSendFrame:Hide();

	MapNotes_ClearGUI();
end

function MapNotes_HideMenus()
	MapNotesNewMenuFrame:Hide();
	MapNotesPOIMenuFrame:Hide();
	MapNotesSpecialActionMenuFrame:Hide();
	MapNotes_ClearGUI();
end

function MapNotes_HideFrames()
	MapNotesEditFrame:Hide();
	MapNotesOptionsFrame:Hide();
	MapNotesSendFrame:Hide();
	MapNotes_ClearGUI();
end

function MapNotes_MenusHidden()
	if MapNotesNewMenuFrame:IsVisible() or
			MapNotesSpecialActionMenuFrame:IsVisible() or
			MapNotesPOIMenuFrame:IsVisible() then
		return false;
	else
		return true;
	end
end

function MapNotes_FramesHidden()
	if MapNotesEditFrame:IsVisible() or
			MapNotesSendFrame:IsVisible() or
			MapNotesOptionsFrame:IsVisible() then
		return false;
	else
		return true;
	end
end

function MapNotes_DeleteNote(id, key)

	if id == 0 then
		MapNotes_tloc_xPos = nil;
		MapNotes_tloc_yPox = nil;
		MapNotes_tloc_key = nil;
		if ( MapNotes_MiniNote_Data.icon == "tloc") then
			MapNotes_ClearMiniNote(true);
		end
		MapNotes_MapUpdate();
		return

	elseif id == -1 then
		MapNotes_PartyNoteData.xPos = nil;
		MapNotes_PartyNoteData.yPos = nil;
		MapNotes_PartyNoteData.continent = nil;
		MapNotes_PartyNoteData.zone = nil;
		MapNotes_PartyNoteData.key = nil;
		if ( MapNotes_MiniNote_Data.icon == "party" ) then
			MapNotes_ClearMiniNote(true);
		end
		MapNotes_MapUpdate();
		return;
	end

	local currentZone, lastEntry, key, Plugin;

	if ( ( key ) and ( key.frame ) ) then					--Telic_2
		key = MapNotes_PlugInsGetKey(key);				--Telic_2
		Plugin = true;

	elseif ( MAPNOTES_ACTIVE_PLUGIN ) then					--Telic_2
		key = MapNotes_PlugInsGetKey(MAPNOTES_ACTIVE_PLUGIN);		--Telic_2
		Plugin = true;

	else									--Telic_2
		if ( not key ) then
			key = MapNotes_GetMapKey();
		end
	end									--Telic_2

	currentZone = MapNotes_Data_Notes[key];

	lastEntry = MapNotes_GetZoneTableSize(currentZone);

	MapNotes_DeleteLines(key, currentZone[id].xPos, currentZone[id].yPos);

	if lastEntry ~= 0 and id <= lastEntry then
		currentZone[id].name = currentZone[lastEntry].name;
		currentZone[lastEntry].name = nil;
		currentZone[id].ncol = currentZone[lastEntry].ncol;
		currentZone[lastEntry].ncol = nil;
		currentZone[id].inf1 = currentZone[lastEntry].inf1;
		currentZone[lastEntry].inf1 = nil;
		currentZone[id].in1c = currentZone[lastEntry].in1c;
		currentZone[lastEntry].in1c = nil;
		currentZone[id].inf2 = currentZone[lastEntry].inf2;
		currentZone[lastEntry].inf2 = nil;
		currentZone[id].in2c = currentZone[lastEntry].in2c;
		currentZone[lastEntry].in2c = nil;
		currentZone[id].creator = currentZone[lastEntry].creator;
		currentZone[lastEntry].creator = nil;
		currentZone[id].icon = currentZone[lastEntry].icon;
		currentZone[lastEntry].icon = nil;
		currentZone[id].xPos = currentZone[lastEntry].xPos;
		currentZone[lastEntry].xPos = nil;
		currentZone[id].yPos = currentZone[lastEntry].yPos;
		currentZone[lastEntry].yPos = nil;
		currentZone[lastEntry] = nil;
	end

	if ( key == MapNotes_MiniNote_Data.key ) then
		if MapNotes_MiniNote_Data.id > id then
			MapNotes_MiniNote_Data.id = MapNotes_MiniNote_Data.id - 1;
		elseif MapNotes_MiniNote_Data.id == id then
			MapNotes_ClearMiniNote(true);
		end
	end

	if ( MAPNOTES_ACTIVE_PLUGIN ) then					--Telic_2
		MapNotes_PlugInsDrawNotes(MAPNOTES_ACTIVE_PLUGIN);		--Telic_2
		MAPNOTES_ACTIVE_PLUGIN = nil;					--Telic_2 Reset after saving/drawing
	else									--Telic_2
		MapNotes_MapUpdate();
	end									--Telic_2
end

function MapNotes_GetZoneTableSize(zoneTable)
	local i = 0;
	if not (zoneTable == nil) then
		for index, records in ipairs(zoneTable) do
			i = i + 1;
		end
	end

	return i;
end

function MapNotes_DeleteNotesByCreatorAndName(creator, name)		--Telic_2 Cant see where this is called from ?????
	if ( not creator ) then
		return;
	end

	for key, records in pairs(MapNotes_Data_Notes) do
		for id=MapNotes_GetZoneTableSize(records), 1, -1 do
			if ( ( creator == zoneTable[id].creator ) and ( name == zoneTable[id].name or name == nil ) ) then
				MapNotes_DeleteNote(id, key);
			end
		end
	end

	if name ~= nil then
		MapNotes_StatusPrint(format(TEXT(MAPNOTES_DELETED_BY_NAME), creator, name));
	else
		MapNotes_StatusPrint(format(TEXT(MAPNOTES_DELETED_BY_CREATOR), creator));
	end
end

function MapNotes_OnEnter(id)
	if MapNotes_FramesHidden() and MapNotes_MenusHidden() then
		local x, y = this:GetCenter();
		local x2, y2 = WorldMapButton:GetCenter();
		local anchor = "";
		if x > x2 then
			anchor = "ANCHOR_LEFT";
		else
			anchor = "ANCHOR_RIGHT";
		end

		local currentZone = MapNotes_Data_Notes[ MapNotes_GetMapKey() ];

		local cNr = currentZone[id].ncol;
		WorldMapTooltip:SetOwner(this, anchor);
		WorldMapTooltip:SetText(currentZone[id].name, MapNotes_Colors[cNr].r, MapNotes_Colors[cNr].g, MapNotes_Colors[cNr].b);
		if currentZone[id].inf1 ~= nil and currentZone[id].inf1 ~= "" then
			cNr = currentZone[id].in1c;
			WorldMapTooltip:AddLine(currentZone[id].inf1, MapNotes_Colors[cNr].r, MapNotes_Colors[cNr].g, MapNotes_Colors[cNr].b);
		end
		if currentZone[id].inf2 ~= nil and currentZone[id].inf2 ~= "" then
			cNr = currentZone[id].in2c;
			WorldMapTooltip:AddLine(currentZone[id].inf2, MapNotes_Colors[cNr].r, MapNotes_Colors[cNr].g, MapNotes_Colors[cNr].b);
		end
		WorldMapTooltip:AddDoubleLine(MAPNOTES_CREATEDBY, currentZone[id].creator, 0.79, 0.69, 0.0, 0.79, 0.69, 0.0);
		WorldMapTooltip:Show();
	else
		WorldMapTooltip:Hide();
		GameTooltip:Hide();			--Telic_2 Covers all bases for GameTooltips displayed over other AddOn notes
	end
end

function MapNotes_OnLeave(id)
	WorldMapTooltip:Hide();
	GameTooltip:Hide();			--Telic_2 Covers all bases for GameTooltips displayed over other AddOn notes
end

function MapNotes_Note_OnClick(button, id)
	local lclFrame = this:GetParent();					--Telic_2
	local plugInNote = nil;							--Telic_2

	if ( MapNotes_PlugInFrames[lclFrame] ) then				--Telic_2
		plugInNote = MapNotes_PlugInFrames[lclFrame];			--Telic_2
		MAPNOTES_ACTIVE_PLUGIN = plugInNote;
	end									--Telic_2

	CloseDropDownMenus();

	if not MapNotes_FramesHidden() then
		return;
	elseif not MapNotes_MenusHidden() then
		MapNotes_HideMenus();
	end

	local currentZone, key;

	if ( plugInNote ) then						--Telic_2
		key = MapNotes_PlugInsGetKey(plugInNote);		--Telic_2
	else								--Telic_2
		key = MapNotes_GetMapKey();
	end								--Telic_2
	currentZone = MapNotes_Data_Notes[key];				--Telic_2

	if ( MapNotes_LastLineClick.GUIactive ) then			--Telic_2 (Added cont/zone test)
		id = id + 0;
		local ax = currentZone[id].xPos;
		local ay = currentZone[id].yPos;
		if ( ( MapNotes_LastLineClick.x ~= ax or MapNotes_LastLineClick.y ~= ay) and ( MapNotes_LastLineClick.key == key ) ) then
			MapNotes_ToggleLine(key, ax, ay, MapNotes_LastLineClick.x, MapNotes_LastLineClick.y, plugInNote);
		end
		MapNotes_ClearGUI();

	elseif ( button == "RightButton" ) then
		id = id + 0;
		MapNotes_TempData_Id = id;

		local xOffset, yOffset = MapNotes_GetAdjustedMapXY(lclFrame);					--Telic_1
		MapNotesPOIMenuFrame:ClearAllPoints();								--Telic_1
		MapNotesPOIMenuFrame:SetPoint("CENTER", lclFrame, "TOPLEFT", xOffset, yOffset);			--Telic_1
		MapNotesNewMenuFrame:Hide();
		MapNotesSpecialActionMenuFrame:Hide();
		MapNotesButtonEditNote:Enable();
		MapNotesButtonSendNote:Enable();
		WorldMapTooltip:Hide();
		MapNotesPOIMenuFrame:SetParent(lclFrame);							--Telic_2
		MapNotesPOIMenuFrame:Show();

	elseif ( ( button == "LeftButton" ) and ( IsAltKeyDown() ) and ( not IsControlKeyDown() ) ) then	--Telic_2 (Added cont/zone test)
		id = id + 0;
		local ax = currentZone[id].xPos;
		local ay = currentZone[id].yPos;							--Telic_*
		if (MapNotes_LastLineClick.x ~= ax or MapNotes_LastLineClick.y ~= ay) and MapNotes_LastLineClick.key == key and MapNotes_LastLineClick.time > GetTime() - 4 then
			MapNotes_ToggleLine(key, ax, ay, MapNotes_LastLineClick.x, MapNotes_LastLineClick.y, plugInNote);
		else
			MapNotes_LastLineClick.x = ax;
			MapNotes_LastLineClick.y = ay;
			MapNotes_LastLineClick.key = key;
			MapNotes_LastLineClick.time = GetTime();
		end

	elseif ( ( button == "LeftButton" ) and ( not IsControlKeyDown() ) ) then
		local ax = currentZone[id].xPos;
		local ay = currentZone[id].yPos;
		MapNotesButtonNewNote:Disable();
		WorldMapTooltip:Hide();
		MapNotes_ShowNewFrame(ax, ay, lclFrame);						--Telic_2 (Added lclFrame)
	end
end

function MapNotes_StartGUIToggleLine()
	local key;

	if ( MAPNOTES_ACTIVE_PLUGIN ) then
		key = MapNotes_PlugInsGetKey(MAPNOTES_ACTIVE_PLUGIN);
	else
		WorldMapMagnifyingGlassButton:SetText(MAPNOTES_WORLDMAP_HELP_1.."\n"..MAPNOTES_WORLDMAP_HELP_2.."\n"..MAPNOTES_WORLDMAP_HELP_3.."\n"..MAPNOTES_CLICK_ON_SECOND_NOTE);
		key = MapNotes_GetMapKey();
	end

	local currentZone = MapNotes_Data_Notes[key];						--Telic_*

	MapNotes_LastLineClick.GUIactive = true;
	MapNotes_LastLineClick.x = currentZone[MapNotes_TempData_Id].xPos;			--Telic_* (changed to use currentZone)
	MapNotes_LastLineClick.y = currentZone[MapNotes_TempData_Id].yPos;			--Telic_* (changed to use cuurentZone)
	MapNotes_LastLineClick.key = key;
end

function MapNotes_ClearGUI()
	WorldMapMagnifyingGlassButton:SetText(MAPNOTES_WORLDMAP_HELP_1.."\n"..MAPNOTES_WORLDMAP_HELP_2.."\n"..MAPNOTES_WORLDMAP_HELP_3);
	MapNotes_LastLineClick.GUIactive = false;
end

function MapNotes_DrawLine(id, x1, y1, x2, y2, Plugin)					--Telic_2 (Added Plugin parameter)
	if ( ( not x1 ) or ( not x2 ) or ( not y1 ) or ( not y2 ) ) then
		return;
	end

	local scaleAdjustment = 1.0;
	local MapNotesLine = MapNotes_AssignLine(id, Plugin);

	local lineFrame = WorldMapDetailFrame;
	if ( Plugin ) then
		lineFrame = getglobal( Plugin.frame .. "_MNLinesFrame" );
		scaleAdjustment = lineFrame:GetEffectiveScale();
	end

	local positiveSlopeTexture = MN_MISC_GFX_PATH.."\\LineTemplatePositive256";
	local negativeSlopeTexture = MN_MISC_GFX_PATH.."\\LineTemplateNegative256";
	local width = lineFrame:GetWidth();
	local height = lineFrame:GetHeight();

	local deltax = ( math.abs((x1 - x2) * width)  )/scaleAdjustment;
	local deltay = ( math.abs((y1 - y2) * height) )/scaleAdjustment;

	local xOffset = ( (math.min(x1,x2) * width ) ) /scaleAdjustment;
	local yOffset = (-(math.min(y1,y2) * height) ) /scaleAdjustment;
	local lowerpixel = math.min(deltax, deltay);
	lowerpixel = lowerpixel / 256;
	if lowerpixel > 1 then
		lowerpixel = 1;
	end

	if deltax == 0 then
		deltax = 2;
		MapNotesLine:SetTexture(0, 0, 0);
		MapNotesLine:SetTexCoord(0, 1, 0, 1);
	elseif deltay == 0 then
		deltay = 2;
		MapNotesLine:SetTexture(0, 0, 0);
		MapNotesLine:SetTexCoord(0, 1, 0, 1);
	elseif x1 - x2 < 0 then
		if y1 - y2 < 0 then
			MapNotesLine:SetTexture(negativeSlopeTexture);
			MapNotesLine:SetTexCoord(0, lowerpixel, 0, lowerpixel);
		else
			MapNotesLine:SetTexture(positiveSlopeTexture);
			MapNotesLine:SetTexCoord(0, lowerpixel, 1-lowerpixel, 1);
		end
	else
		if y1 - y2 < 0 then
			MapNotesLine:SetTexture(positiveSlopeTexture);
			MapNotesLine:SetTexCoord(0, lowerpixel, 1-lowerpixel, 1);
		else
			MapNotesLine:SetTexture(negativeSlopeTexture);
			MapNotesLine:SetTexCoord(0, lowerpixel, 0, lowerpixel);
		end
	end

	MapNotesLine:SetPoint("TOPLEFT", lineFrame, "TOPLEFT", xOffset, yOffset);
	MapNotesLine:SetWidth(deltax);
	MapNotesLine:SetHeight(deltay);
	MapNotesLine:Show();
end

function MapNotes_DeleteLines(key, x, y)
	local zoneTable = MapNotes_Data_Lines[key];
	local lineCount = MapNotes_GetZoneTableSize(zoneTable);
	local offset = 0;

	for i = 1, lineCount, 1 do
		if (zoneTable[i-offset].x1 == x and zoneTable[i-offset].y1 == y) or (zoneTable[i-offset].x2 == x and zoneTable[i-offset].y2 == y) then
			for j = i, lineCount-1, 1 do
				zoneTable[j-offset].x1 = zoneTable[j+1-offset].x1;
				zoneTable[j-offset].x2 = zoneTable[j+1-offset].x2;
				zoneTable[j-offset].y1 = zoneTable[j+1-offset].y1;
				zoneTable[j-offset].y2 = zoneTable[j+1-offset].y2;
			end
			zoneTable[lineCount-offset] = nil;
			offset = offset + 1;
		end
	end
	MapNotes_LastLineClick.key = "nil";
end



function MapNotes_ToggleLine(key, x1, y1, x2, y2, Plugin)
	local zoneTable = MapNotes_Data_Lines[key];
	local newline = true;

	local lineCount = MapNotes_GetZoneTableSize(zoneTable);

	for i = 1, lineCount, 1 do
		if i <= lineCount then
			if (zoneTable[i].x1 == x1 and zoneTable[i].y1 == y1 and zoneTable[i].x2 == x2 and zoneTable[i].y2 == y2) or
					(zoneTable[i].x1 == x2 and zoneTable[i].y1 == y2 and zoneTable[i].x2 == x1 and zoneTable[i].y2 == y1) then
				for j = i, lineCount-1, 1 do
					zoneTable[j].x1 = zoneTable[j+1].x1;
					zoneTable[j].x2 = zoneTable[j+1].x2;
					zoneTable[j].y1 = zoneTable[j+1].y1;
					zoneTable[j].y2 = zoneTable[j+1].y2;
				end
				zoneTable[lineCount] = nil;
				PlaySound("igMainMenuOption");
				newline = false;
				lineCount = lineCount - 1;
			end
		end
	end
	if ( newline ) then
		zoneTable[lineCount+1] = {};
		zoneTable[lineCount+1].x1 = x1;
		zoneTable[lineCount+1].x2 = x2;
		zoneTable[lineCount+1].y1 = y1;
		zoneTable[lineCount+1].y2 = y2;
	end
	MapNotes_LastLineClick.key = "nil";

	if ( Plugin ) then
		MapNotes_PlugInsDrawNotes(Plugin);
	else
		MapNotes_MapUpdate();
	end
end



function MapNotes_OpenEditForNewNote()
	if MapNotes_TempData_Id == 0 then
		MapNotes_tloc_xPos = nil;
		MapNotes_tloc_yPos = nil;
		MapNotes_tloc_key = nil;
	end
	MapNotes_TempData_Id = MapNotes_NewNoteSlot();
	MapNotes_TempData_Creator = UnitName("player");
	MapNotes_Edit_SetIcon(0);
	MapNotes_Edit_SetTextColor(0);
	MapNotes_Edit_SetInfo1Color(0);
	MapNotes_Edit_SetInfo2Color(0);
	TitleWideEditBox:SetText("");
	Info1WideEditBox:SetText("");
	Info2WideEditBox:SetText("");
	CreatorWideEditBox:SetText(MapNotes_TempData_Creator);
	MapNotes_HideAll();
	MapNotesEditFrame:Show();
end

function MapNotes_NewNoteSlot()
	local currentZone, key;

	if ( MAPNOTES_ACTIVE_PLUGIN ) then					--Telic_2
		key = MapNotes_PlugInsGetKey(MAPNOTES_ACTIVE_PLUGIN);		--Telic_2

	else									--Telic_2
		key = MapNotes_GetMapKey();
	end									--Telic_2
	currentZone = MapNotes_Data_Notes[key];					--Telic_2

	return MapNotes_GetZoneTableSize(currentZone) + 1;
end

function MapNotes_SetPartyNote(xPos, yPos)
	if ( ( GetCurrentMapZone() == 0 ) or ( GetCurrentMapContinent() == 0 ) ) then
		return;
	end

	xPos = floor(xPos * 1000000) / 1000000;
	yPos = floor(yPos * 1000000) / 1000000;
	local key = MapNotes_GetMapKey();
	MapNotes_PartyNoteData.continent = GetCurrentMapContinent();
	MapNotes_PartyNoteData.zone = GetCurrentMapZone();
	MapNotes_PartyNoteData.key = key;
	MapNotes_PartyNoteData.xPos = xPos;
	MapNotes_PartyNoteData.yPos = yPos;

	local msg = "<M_N> k<"..key.."> x<"..xPos.."> y<"..yPos.."> p<1>";			--Telic_6
	SendAddonMessage( "MapNotes_FU", msg, "PARTY" );					--Telic_6

	if ( ( MapNotes_MiniNote_Data.icon == "party" ) or ( MapNotes_Options[16] ~= "off" ) ) then
		MapNotes_MiniNote_Data.id = -1;
		MapNotes_MiniNote_Data.key = key;
		MapNotes_MiniNote_Data.xPos = xPos;
		MapNotes_MiniNote_Data.yPos = yPos;
		MapNotes_MiniNote_Data.name = MAPNOTES_PARTYNOTE;
		MapNotes_MiniNote_Data.color = 0;
		MapNotes_MiniNote_Data.icon = "party";
		MiniNotePOITexture:SetTexture(MN_POI_ICONS_PATH.."\\Icon"..MapNotes_MiniNote_Data.icon);
		MiniNotePOI:Show();
	end
	MapNotes_MapUpdate();
end



function MapNotes_MiniNote_OnClick(...)
	local temp_Minimap_OnClick = Minimap_OnClick;
	Minimap_OnClick = nil;
	this = this:GetParent();
	Minimap_OnClick = temp_Minimap_OnClick;

	Minimap_OnClick( unpack(arg) );
end



function MapNotes_WorldMapButton_OnClick(mouseButton, button)
	CloseDropDownMenus();

	if not MapNotes_FramesHidden() then
		return;
	elseif not MapNotes_MenusHidden() then
		MapNotes_HideMenus();
	end

	local key = MapNotes_GetMapKey();

	-- if we are viewing a continent or continents or it was left-click call the original handler
	if ( ( mouseButton == "LeftButton" ) or ( ( mouseButton == "RightButton" ) and ( not IsControlKeyDown() ) and ( not IsShiftKeyDown() ) ) ) then --Telic_7
		orig_MapNotes_WorldMapButton_OnClick(mouseButton, button);
		return;
	end

	-- <control>+right-click is used to bring up the main menu when viewing a particular zone/city
	-- shift right-click is used to set the party note at the click location

	if not button then
		button = this;
	end

	local adjustedX, adjustedY = MapNotes_GetMouseXY(button);

	if ( IsShiftKeyDown() ) then
		MapNotes_SetPartyNote(adjustedX, adjustedY);

	elseif ( IsControlKeyDown() ) then
		MAPNOTES_ACTIVE_PLUGIN = nil;					--Telic_2
		MapNotesButtonNewNote:Enable();
		MapNotes_ShowNewFrame(adjustedX, adjustedY);
	end
end



function MapNotes_WorldMapButton_OnUpdate()
	if MapNotes_Drawing then
		return;
	end

	MapNotes_Drawing = true;

	local width = WorldMapButton:GetWidth();
	local height = WorldMapButton:GetHeight();
	local key = MapNotes_GetMapKey();
	local currentZone = MapNotes_Data_Notes[key];
	local currentLineZone = MapNotes_Data_Lines[key];
	local xOffset,yOffset = 0;
	local POI;
	local nNotes, nLines = 1, 1;

	if ( ( currentZone ) and ( MapNotes_Options.shownotes ) ) then
		for i, value in ipairs(currentZone) do
			POI = MapNotes_AssignPOI(i);
			local xOffset = currentZone[i].xPos * width;
			local yOffset = -currentZone[i].yPos * height;
			POI:SetUserPlaced(false);
			POI:ClearAllPoints();
			POI:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", xOffset, yOffset);
			getglobal(POI:GetName().."Texture"):SetTexture(MN_POI_ICONS_PATH.."\\Icon"..currentZone[i].icon);

			local POIHighlight = getglobal(POI:GetName().."Highlight");
			if ( value.name == MapNotes_HighlightedNote ) then
				POIHighlight:Show();
			else
				POIHighlight:Hide();
			end

			if MapNotes_Options[currentZone[i].icon] ~= "off" then
				if (MapNotes_Options[10] ~= "off" and currentZone[i].creator == UnitName("player")) or
					(MapNotes_Options[11] ~= "off" and currentZone[i].creator ~= UnitName("player")) then
					POI:Show();
				end
			else
				POI:Hide();
			end
			nNotes = nNotes + 1;
		end

		local lastnote = nNotes - 1;
		if ( ( MapNotes_Options[12] ~= "off" ) and ( POI ) ) then
			if ( POI:IsVisible() ) then
				getglobal( POI:GetName().."Texture"):SetTexture(MN_POI_ICONS_PATH.."\\Icon"..currentZone[lastnote].icon.."red");
			end
		end

		if ( ( MapNotes_Options[13] ~= "off" ) and ( MapNotes_MiniNote_Data.key == key ) and ( MapNotes_MiniNote_Data.id > 0 ) ) then
			getglobal("MapNotesPOI"..MapNotes_MiniNote_Data.id.."Texture"):SetTexture(MN_POI_ICONS_PATH.."\\Icon"..MapNotes_MiniNote_Data.icon.."blue");
		end

		if ( currentLineZone ) then
			for i, line in ipairs(currentLineZone) do
				MapNotes_DrawLine(i, line.x1, line.y1, line.x2, line.y2);
				nLines = nLines + 1;
			end
		end
	end

	local otherPOI = getglobal("MapNotesPOI"..nNotes);
	while ( otherPOI ) do
		otherPOI:Hide();
		nNotes = nNotes + 1;
		otherPOI = getglobal("MapNotesPOI"..nNotes);
	end

	local otherLines = getglobal("MapNotesLines_"..nLines);
	while ( otherLines ) do
		otherLines:Hide();
		nLines = nLines + 1;
		otherLines = getglobal("MapNotesLines_"..nLines);
	end

	if ( currentZone ) then
		-- tloc button
		if ( ( MapNotes_tloc_xPos ) and ( MapNotes_tloc_key == key ) ) then
			xOffset = MapNotes_tloc_xPos * width;
			yOffset = -MapNotes_tloc_yPos * height;
			MapNotesPOItloc:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", xOffset, yOffset);
			MapNotesPOItloc:Show();
		else
			MapNotesPOItloc:Hide();
		end

		-- party note
		if ( ( MapNotes_PartyNoteData.xPos ) and ( key == MapNotes_PartyNoteData.key ) ) then		--Telic_5
			if MapNotes_Options[13] ~= "off" and MapNotes_MiniNote_Data.icon == "party" then
				MapNotesPOIpartyTexture:SetTexture(MN_POI_ICONS_PATH.."\\Iconpartyblue");
			else
				MapNotesPOIpartyTexture:SetTexture(MN_POI_ICONS_PATH.."\\Iconparty");
			end
			xOffset = MapNotes_PartyNoteData.xPos * width;
			yOffset = -MapNotes_PartyNoteData.yPos * height;
			MapNotesPOIparty:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", xOffset, yOffset);
			MapNotesPOIparty:Show();
		else
			MapNotesPOIparty:Hide();
		end

	else							--Telic_5
		MapNotesPOItloc:Hide();				--Telic_5
		MapNotesPOIparty:Hide();			--Telic_5
	end

	MapNotes_Drawing = nil;
end

function MapNotes_ToggleWorldMap()
	if ( not WorldMapFrame:IsVisible() ) then
		SetMapToCurrentZone();
	end
	MapNotes_HideAll();
end



function MapNotes_RememberPosition(id)
	local Plugin = this.Plugin;
	local key;

	if ( Plugin ) then
		key = MapNotes_PlugInsGetKey(Plugin);
	else
		key = MapNotes_GetMapKey();
	end

	this.lastXPos = MapNotes_Data_Notes[key][id].xPos;
	this.lastYPos = MapNotes_Data_Notes[key][id].yPos;
end

function MapNotes_RepositionNote(id)
	local pFrame = this:GetParent();
	local Plugin = this.Plugin;

	if ( MouseIsOver(pFrame) ) then
		local x, y = MapNotes_GetMouseXY(pFrame);
		local key;

		if ( Plugin ) then
			key = MapNotes_PlugInsGetKey(Plugin);
		else
			key = MapNotes_GetMapKey();
		end

		MapNotes_Data_Notes[key][id].xPos = x;
		MapNotes_Data_Notes[key][id].yPos = y;

		-- Update Lines using this Note as a Vertex
		local lX = this.lastXPos;
		local lY = this.lastYPos;
		for i, line in ipairs(MapNotes_Data_Lines[key]) do
			if ( ( line.x1 == lX ) and ( line.y1 == lY ) ) then
				line.x1 = x;
				line.y1 = y;

			elseif ( ( line.x2 == lX ) and ( line.y2 == lY ) ) then
				line.x2 = x;
				line.y2 = y;
			end
		end
	end

	if ( Plugin ) then
		MapNotes_PlugInsDrawNotes(Plugin);
	else
		MapNotes_WorldMapButton_OnUpdate();
	end
end



function MapNotes_Search(fTxt)
	if ( ( fTxt ) and ( fTxt ~= "" ) ) then
		local foundArray = {};
		local iKey = 0;

		fTxt = string.lower(fTxt);
		for key, map in pairs(MapNotes_Data_Notes) do
			for index, note in ipairs(map) do
				local sTxt = string.lower( note.name .. note.inf1 .. note.inf2 .. note.creator );
				if ( string.find(sTxt, fTxt) ) then
					local name, lName, cat;
					if ( string.sub(key, 1, 3) == "WM " ) then
						name, lName, cat = MapNotes_GetMapDisplayName(key);

					else
						for index, Plugin in pairs(MAPNOTES_PLUGINS_LIST) do
							if ( string.find(key, Plugin.name) ) then
								name, lName, cat = MapNotes_GetMapDisplayName(key, Plugin);
								break;
							end
						end
					end
					if ( not foundArray[cat] ) then
						foundArray[cat] = {};
						foundArray[cat].counter = 1;
					end
					if ( not foundArray[cat][lName] ) then
						foundArray[cat][lName] = {};
						foundArray[cat][lName].counter = 1;
					else
						foundArray[cat][lName].counter = foundArray[cat][lName].counter + 1;
					end
				end
			end
		end

		local counter = 0;
		for type, noteTypes in pairs(foundArray) do
			MapNotes_StatusPrint("----------");
			MapNotes_StatusPrint(type);
			for key, note in pairs(noteTypes) do
				if ( key ~= "counter" ) then
					MapNotes_StatusPrint(key .. " : " .. note.counter .. MAPNOTES_NOTESFOUND);
					counter = counter + 1;
				end
			end
		end
		MapNotes_StatusPrint("----------");
		MapNotes_StatusPrint(counter.. " " .. ZONE);
	end
end



function MapNotes_Highlight(hName)
	if ( ( hName ) and ( hName ~= "" ) ) then
		MapNotes_HighlightedNote = hName;
	else
		MapNotes_HighlightedNote = "";
	end
	MapNotes_PlugInsRefresh();
	MapNotes_MapUpdate();
end



function MapNotes_MiniCToggle()
	if ( MN_MinimapCoordsFrame:IsVisible() ) then
		MN_MinimapCoordsFrame:Hide();
		MapNotesOptionsCheckboxMiniC:SetChecked(0);
		MapNotes_Options.miniC = nil;
	else
		MN_MinimapCoordsFrame:Show();
		MapNotesOptionsCheckboxMiniC:SetChecked(1);
		MapNotes_Options.miniC = true;
	end
end

function MapNotes_MapCToggle()
	if ( MN_MapCoords:IsVisible() ) then
		MapNotes_Options.mapC = nil;
		MapNotesOptionsCheckboxMapC:SetChecked(0);
		MN_SetCoordsPos();
	else
		MapNotes_Options.mapC = true;
		MapNotesOptionsCheckboxMapC:SetChecked(1);
		MN_SetCoordsPos();
	end
end

function MN_SetCoordsPos()
	local x, y = MapNotes_Options.coordsLocX, MapNotes_Options.coordsLocY;

	MN_MapCoords:ClearAllPoints();
	MN_MapCoords:SetUserPlaced(0);
	MN_MapCoords:SetParent(WorldMapFrame);
	MN_MapCoords:SetPoint("CENTER", "WorldMapButton", "BOTTOMLEFT", x, y);
	MN_MapCoords:SetFrameLevel( WorldMapButton:GetFrameLevel() + 3);
	MN_MapCoords:Show();
	if ( not MapNotes_Options.mapC ) then
		MN_MapCoords:Hide();
	end
end

function MN_RememberCoordsPos()
	if ( MN_MapCoords.isMoving ) then
		if ( MouseIsOver(WorldMapButton) ) then
			MN_MapCoords.startingX, MN_MapCoords.startingY = MN_GetRelativeCoords(WorldMapButton);
		else
			MN_MapCoords.startingX, MN_MapCoords.startingY = MN_DefaultCoordsX, MN_DefaultCoordsY;
		end
		return;

	else
		local x, y;
		if ( MouseIsOver(WorldMapButton) ) then
			x, y = MN_GetRelativeCoords(WorldMapButton);
		else
			x, y = MN_MapCoords.startingX, MN_MapCoords.startingY;
		end
		if ( x < 45 ) then
			x = x + 45;
		end
		MapNotes_Options.coordsLocX, MapNotes_Options.coordsLocY = x, y;
		MN_SetCoordsPos();
	end
end

function MN_GetRelativeCoords(rFrame)
		local x, y = GetCursorPosition();
		x = x / (rFrame:GetEffectiveScale());
		y = y / (rFrame:GetEffectiveScale());

		local centerX, centerY = rFrame:GetCenter();
		local width = rFrame:GetWidth();
		local height = rFrame:GetHeight();
		local adjustedX = (x - (centerX - (width/2))) / width;
		local adjustedY = (centerY + (height/2) - y ) / height;

		x = math.floor( width*adjustedX );
		y = math.floor( height - (height*adjustedY) );

		return x, y;
end



function MN_MinimapCoords_OnUpdate()
	local x,y = GetPlayerMapPosition("player");
	if ( ( x ) and ( y ) ) then
		x = x*100;
		y = y*100;
		MN_MinimapCoordsFrameText:SetText( format("%2d,%2d",x,y) );
	end
end

function MN_MapCoords_OnUpdate(elapsed)
	if ( IsControlKeyDown() ) then
		if ( not MN_MapCoordsMovementFrame:IsVisible() ) then
			MN_MapCoordsMovementFrame:Show();
		end
	else
		if ( MN_MapCoordsMovementFrame:IsVisible() ) then
			MN_MapCoordsMovementFrame:Hide();
		end
	end

	MN_cUpdate = MN_cUpdate + elapsed;
	if ( MN_cUpdate > MN_cUpdateLimit ) then
		local cLoc, pLoc = "", "";
		local x,y = GetPlayerMapPosition("player");
		local cX, cY = nil, nil;

		if ( ( x ) and ( y ) ) then
			x = x*100;
			y = y*100;
			pLoc = "|c0000FF00"..( format("%2d,%2d", x, y) ).."|r";
		end

		if ( MouseIsOver(WorldMapButton) ) then
		        local centerX, centerY = WorldMapButton:GetCenter();
		        local width = WorldMapButton:GetWidth();
		        local height = WorldMapButton:GetHeight();
		        cX, cY = GetCursorPosition();
		        cX = cX / WorldMapButton:GetEffectiveScale();
		        cY = cY / WorldMapButton:GetEffectiveScale();
		        local adjustedY = (centerY + height/2 - cY) / height;
		        local adjustedX = (cX - (centerX - width/2)) / width;
		        cX = 100 * ( adjustedX + MN_MOFFSET_X );
		        cY = 100 * ( adjustedY + MN_MOFFSET_Y );
		end
		if ( ( cX ) and ( cY ) ) then
			cLoc = "\n|c00FFFF00"..( format( "%d,%d", cX, cY ) ).."|r";
		end

		MN_MapCoordsText:SetText( pLoc .. cLoc );
		MN_cUpdate = 0;
	end
end



function MN_MinimapCoords_OnClick(mBttn)
	if ( IsAltKeyDown() ) then
		if ( mBttn == "LeftButton" ) then
			MapNotes_TargetNote();
		elseif ( mBttn == "RightButton" ) then
			MapNotes_MergeNote();
		end
	end
end



function MapNotes_TargetNote()
	local x, y = GetPlayerMapPosition("player");

	if ( ( ( x ) and ( x == 0 ) ) and ( ( y ) and ( y == 0 ) ) ) then
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition("player");
		if ( ( ( x ) and ( x == 0 ) ) and ( ( y ) and ( y == 0 ) ) ) then
			MapNotes_StatusPrint(MAPNOTES_QUICKNOTE_NOPOSITION);
			return;
		end
	end

	local name, inf1 = MapNotes_TargetInfo();
	MapNotes_CreateQuickNote(name, inf1);
end

function MapNotes_MergeNote()
	local x, y = GetPlayerMapPosition("player");

	if ( ( ( x ) and ( x == 0 ) ) and ( ( y ) and ( y == 0 ) ) ) then
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition("player");
		if ( ( ( x ) and ( x == 0 ) ) and ( ( y ) and ( y == 0 ) ) ) then
			MapNotes_StatusPrint(MAPNOTES_QUICKNOTE_NOPOSITION);
			return;
		end
	end

	if ( not UnitExists("target") ) then
		MapNotes_StatusPrint(MAPNOTES_MERGE_WARNING);
		return;
	end

	local name, inf1 = MapNotes_TargetInfo();
	MapNotes_CreateQuickNote(name, inf1, "true");
end

function MapNotes_TargetInfo()
	local icon = 8;
	local text = UnitName("target");
	local text2 = "";

	if ( ( text ) and ( text ~= "" ) ) then
		if (UnitReaction("player", "target") < 4) then
			-- hostile, get level, classification, type, and class
			text2 = text2.." "..MN_LEVEL.." "..UnitLevel("target");
			icon = 6;
			if (UnitClassification("target") ~= "normal") then
			text2 = text2.." "..UnitClassification("target");
			end
			text2 = text2.." "..UnitCreatureType("target").." "..UnitClass("target");
		elseif (UnitReaction("player", "target") == 4) then
			-- neutral, assume critter, use yellow icon
	        	icon = 5;
		else
			-- add profession
			GameTooltip:SetUnit("target")
			local profession = GameTooltipTextLeft2:GetText();
			-- set profession to nil if it's the target's level or empty
			if ( ( profession ) and ( ( string.find(profession, MN_LEVEL) ) or ( profession == "" ) ) ) then
				profession = nil;
			end
			if ( profession ) then
				text2 = text2.." <"..profession..">";
			end
		end

		text = icon.." "..text;
	else
		text = "";
	end

	return text, text2;
end

function MapNotes_Merge(key, id, name, inf1)
	name = string.sub(name, 3);
	if ( ( name ) and ( name ~= "" ) ) then
		if ( not inf1 ) then
			inf1 = "";
		end
		if ( string.find( MapNotes_Data_Notes[key][id].name, UnitName("target") ) ) then
			MapNotes_StatusPrint( MAPNOTES_MERGE_DUP..UnitName("target") );
		else
			MapNotes_Data_Notes[key][id].name = MapNotes_Data_Notes[key][id].name .." \124\124 ".. name;	-- " | "
			MapNotes_Data_Notes[key][id].inf1 = MapNotes_Data_Notes[key][id].inf1 .." \124\124 ".. inf1;	-- " | "
			MapNotes_StatusPrint( MAPNOTES_MERGED..UnitName("target") );
		end
	end
end


function MapNotes_CreateLandMarks()
	if ( WorldMapFrame:IsVisible() ) then
		ToggleWorldMap();
	end
	local continentNames = { GetMapContinents() };

	for i in ipairs(continentNames) do
		local zoneNames = { GetMapZones(i) };
		for j in ipairs(zoneNames) do
			SetMapZoom(i, j);
			MapNotes_IterateLandMarks(true);
		end
	end
end

function MapNotes_IterateLandMarks(report)
	local nCreated, nMerged, nSkipped = 0, 0, 0;

	local map = GetMapInfo();
	if ( ( not map ) or ( ( map ) and ( GetCurrentMapZone() == 0 ) ) ) then
		return;
	end

	for k=1, GetNumMapLandmarks(), 1 do
		name, desc, textureIndex, x, y = GetMapLandmarkInfo(k);
		local created = MapNotes_CreateLandMarkNote(name, desc, textureIndex, x, y);
		if ( created == "Created" ) then
			nCreated = nCreated + 1;
		elseif ( created == "Merged" ) then
			nMerged = nMerged + 1;
		else
			nSkipped = nSkipped + 1;
		end
	end

	local tot = nCreated + nMerged;
	if ( ( report ) or ( tot > 0 ) ) then
		local key = MapNotes_GetMapKey();
		MapNotes_StatusPrint( tot.." "..MAPNOTES_LANDMARKS_NOTIFY..(MapNotes_GetMapDisplayName(key)) );
	end
	MapNotes_MapUpdate();

	return;
end

function MapNotes_CreateLandMarkNote(name, desc, textureIndex, x, y)
	local key = MapNotes_GetMapKey();
	local currentZone = MapNotes_Data_Notes[key];
	local checknote = MapNotes_CheckNearNotes(key, x, y);

	if ( not desc ) then
		desc = "";
	end

	if ( checknote ) then
		if ( ( currentZone[checknote].name == name ) or ( string.find( currentZone[checknote].name, name ) ) ) then
			return "Duplicate";

		else
			currentZone[checknote].name = currentZone[checknote].name .." \124\124 ".. name;	-- " | "
			currentZone[checknote].inf1 = currentZone[checknote].inf1 .." \124\124 ".. desc;	-- " | "
			return "Merged";
		end

	else
		MapNotes_TempData_Id = MapNotes_GetZoneTableSize(currentZone) + 1;
		currentZone[MapNotes_TempData_Id] = {};
		currentZone[MapNotes_TempData_Id].name = name;
		currentZone[MapNotes_TempData_Id].ncol = 7;
		currentZone[MapNotes_TempData_Id].inf1 = "";
		currentZone[MapNotes_TempData_Id].in1c = 6;
		currentZone[MapNotes_TempData_Id].inf2 = "";
		currentZone[MapNotes_TempData_Id].in2c = 0;
		currentZone[MapNotes_TempData_Id].creator = "MapNotesLandMark";
		currentZone[MapNotes_TempData_Id].icon = 7;
		currentZone[MapNotes_TempData_Id].xPos = x;
		currentZone[MapNotes_TempData_Id].yPos = y;
		return "Created";
	end

	return nil;
end

function MapNotes_DeleteLandMarks()
	local key = MapNotes_GetMapKey();
	local currentZone = MapNotes_Data_Notes[key];

	for i=MapNotes_GetZoneTableSize(currentZone), 1, -1 do
		--if ( currentZone[i].creator == "MapNotesLandMark" ) then
			MapNotes_DeleteNote(i, nil);
		--end
	end
	MapNotes_MapUpdate();
end