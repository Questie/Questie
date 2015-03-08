--[[
	MapNotes: Adds a note system to the WorldMap and other AddOns that use the Plugins facility provided

	See the README file for more information.
]]


-- Telic_1 Functions

function MapNotes_GetAdjustedMapXY(lclFrame, x, y)
	local width = lclFrame:GetWidth();
	local height = lclFrame:GetHeight();
	local adjustedX, adjustedY = x, y;

	if ( not x ) then
		adjustedX, adjustedY = MapNotes_GetMouseXY(lclFrame);
	end

	local xOff, yOff;
	if ( adjustedX < 0.5 ) then
		xOff = 125;
	else
		xOff = -125;
	end
	if ( adjustedY < 0.5 ) then
		yOff = -60;
	else
		yOff = 60;
	end

	adjustedX = math.floor( width*adjustedX ) + xOff;
	adjustedY = -(height - math.floor( height - (height*adjustedY))) + yOff;

	return adjustedX, adjustedY;
end

function MapNotes_GetMouseXY(lclFrame)
	local width = lclFrame:GetWidth();
	local height = lclFrame:GetHeight();
	local x, y = GetCursorPosition();
	x = x / (lclFrame:GetEffectiveScale());
	y = y / (lclFrame:GetEffectiveScale());
	local centerX, centerY = lclFrame:GetCenter();
	x = (x - (centerX - (width/2))) / width;
	y = (centerY + (height/2) - y ) / height;

	return x, y;
end



-- Telic_2 Functions

-- Probably need the ability to create Note Buttons for each AddOn that wants them
--  as won't be able to show MapNotes on the World map and Alpha Map at the same time
--  if they are trying to display the exact same XML components...
-- If Plugin is left nil, then this function can be called to generate the default MapNotes POI buttons
--  Could therefore be used to create them dynamically as needed instead of having a fixed maximum...
function MapNotes_AssignPOI(index, Plugin)
	local POI;

	if ( Plugin ) then
		local lclFrame = getglobal(Plugin.frame);
		POI = getglobal( (Plugin.frame) .. "POI" .. index );

		if ( not POI ) then
			POI = CreateFrame("Button", (Plugin.frame) .. "POI" .. index, lclFrame, "MapNotesPOIButtonTemplate");
			POI:SetID(index);
		end

		POI.Plugin = Plugin;		-- Associate Plugin Data with each Note (nil for original WorldMap Notes)
						-- Useful for distinguishing between types of note; Also, useful for
						--  other AddOns that want to remain compatible (i.e. NotesUNeed)

	else
		local lclFrame = getglobal("WorldMapButton");
		POI = getglobal( "MapNotesPOI" .. index );

		if ( not POI ) then
			POI = CreateFrame("Button", "MapNotesPOI" .. index, WorldMapButton, "MapNotesPOIButtonTemplate");
			POI:SetID(index);
		end

		POI.Plugin = nil;		-- Just to be explicit
	end

	return POI;
end

function MapNotes_AssignLine(index, Plugin)
	local Line;

	if ( Plugin ) then
		local lclFrame = getglobal( (Plugin.frame) .. "_MNLinesFrame" );
		Line = getglobal( lclFrame:GetName() .. "Lines_" .. index );
		if ( not Line ) then
			Line = lclFrame:CreateTexture( (lclFrame:GetName() .. "Lines_" .. index), "ARTWORK" );
		end

	else
		Line = getglobal("MapNotesLines_"..index);
		if ( not Line ) then
			Line = MapNotesLinesFrame:CreateTexture( ("MapNotesLines_"..index), "ARTWORK");
		end
	end

	return Line;
end




-- Telic_10 Functions
-------------------------------------------------------------------------------------------------
-- Make MapNotes independant of Localisation (ZoneShifting) Errors
-- (i.e. future proofed. It doesn't fix errors already present in the notes when upgrading.)
-------------------------------------------------------------------------------------------------

MapNotes_Keys = {};		-- MapNotes Keys with Localised name details
MapNotes_OldKeys = {};		-- Mapping of old [Continent][Zone] to New Key values (for this localisation)

-- Basically adding Localised names to the the 'constants' now used as note keys
function MapNotes_LoadMapData()

	MapNotes_BuildKeyList();		-- Other Addons that want to use the same keys should look here

	if ( not MapNotes_Data_Notes ) then
		MapNotes_Data_Notes = {};
	end
	if ( not MapNotes_Data_Lines ) then
		MapNotes_Data_Lines = {};
	end

	for mapName, mapObject in pairs(MapNotes_Keys) do
		if ( not MapNotes_Data_Notes[ mapName ] ) then
			MapNotes_Data_Notes[ mapName ] = {};
		end
		if ( not MapNotes_Data_Lines[ mapName ] ) then
			MapNotes_Data_Lines[ mapName ] = {};
		end
	end

	if ( not MapNotes_Options.Edition ) then
		MapNotes_Options.Edition = MAPNOTES_EDITION;
		MapNotes_UpgradePreviousNotes();
	end
	MapNotes_Options.Version = MAPNOTES_VERSION;
end

--Other Addons that want to use the same keys should look here
--World Map Keys are basically  "WM "..GetMapInfo()
--Localised names are all fetched from game info, except for Battlegrounds - these need to be provided in the localisation files
function MapNotes_BuildKeyList()
	local continentNames = { GetMapContinents() };

	local key = "WM Cosmic";			-- Burning Crusade Support
	MapNotes_Keys[key] = {};
	MapNotes_Keys[key].name = MAPNOTES_COSMIC;
	MapNotes_Keys[key].longName = MAPNOTES_COSMIC;

	local key = "WM WorldMap";			-- Manually set when GetMapInfo() returns nil
	MapNotes_Keys[key] = {};
	MapNotes_Keys[key].name = WORLD_MAP;		-- Blizzard provided constant
	MapNotes_Keys[key].longName = WORLD_MAP;

	key = "WM AlteracValley";
	MapNotes_Keys[key] = {};
	MapNotes_Keys[key].miniData = MAPNOTES_BASEKEYS[key].miniData;
	MapNotes_Keys[key].name = MAPNOTES_ALTERACVALLEY;
	MapNotes_Keys[key].longName = MAPNOTES_ALTERACVALLEY;

	key = "WM ArathiBasin";
	MapNotes_Keys[key] = {};
	MapNotes_Keys[key].miniData = MAPNOTES_BASEKEYS[key].miniData;
	MapNotes_Keys[key].name = MAPNOTES_ARATHIBASIN;
	MapNotes_Keys[key].longName = MAPNOTES_ARATHIBASIN;

	key = "WM WarsongGulch";
	MapNotes_Keys[key] = {};
	MapNotes_Keys[key].miniData = MAPNOTES_BASEKEYS[key].miniData;
	MapNotes_Keys[key].name = MAPNOTES_WARSONGGULCH;
	MapNotes_Keys[key].longName = MAPNOTES_WARSONGGULCH;

	key = "WM Stormwind";
	MapNotes_Keys[key] = {};
	MapNotes_Keys[key].miniData = MAPNOTES_BASEKEYS[key].miniData;
	MapNotes_Keys[key].name = MAPNOTES_STORMWIND;
	MapNotes_Keys[key].longName = MAPNOTES_STORMWIND;

	for i in ipairs(continentNames) do
		SetMapZoom(i);
		local map = GetMapInfo();
		map = "WM "..map;
		if ( not MapNotes_Keys[map] ) then
			MapNotes_Keys[map] = {};
		end
		MapNotes_Keys[map].name = continentNames[i];
		MapNotes_Keys[map].longName = continentNames[i];

		if ( not MapNotes_OldKeys[i] ) then
			MapNotes_OldKeys[i] = {};
		end

		local zoneNames = { GetMapZones(i) };
		for j in ipairs(zoneNames) do
			SetMapZoom(i, j);
			map = GetMapInfo();
			map = "WM "..map;
			if ( not MapNotes_Keys[map] ) then
				MapNotes_Keys[map] = {};
			end
			if ( ( MAPNOTES_BASEKEYS[map] ) and ( MAPNOTES_BASEKEYS[map].miniData ) ) then
				MapNotes_Keys[map].miniData = MAPNOTES_BASEKEYS[map].miniData;
			else
				MapNotes_Keys[map].miniData = MAPNOTES_DEFAULT_MINIDATA;
			end
			MapNotes_Keys[map].name = zoneNames[j];
			MapNotes_Keys[map].longName = continentNames[i].." - "..zoneNames[j];

			if ( not MapNotes_OldKeys[i][j] ) then
				MapNotes_OldKeys[i][j] = map;
			end
		end
	end
end




function MapNotes_GetMapKey()
	local map = GetMapInfo();

	if ( not map ) then
		if ( GetCurrentMapContinent() == WORLDMAP_COSMIC_ID ) then
			map = "Cosmic";
		else
			map = "WorldMap";
		end
	end

	map = "WM "..map;

	return map;
end



function MapNotes_GetMapDisplayName(key, Plugin)
	if ( Plugin ) then
		if ( Plugin.lclFunc ) then
			local subber = Plugin.name .. " ";
			local basicKey, subbed = string.gsub(key, subber, "");
			if ( ( basicKey ) and ( subbed ) and ( subbed > 0 ) ) then
				local localiser = getglobal(Plugin.lclFunc);
				if ( ( localiser ) and ( type(localiser) == "function" ) ) then
					local name = localiser(basicKey);
					if ( name ) then
						lName = Plugin.name .. " - " .. name;
						return name, lName, Plugin.name;
					end
				end
			end
		end

	else
		if ( MapNotes_Keys[key] ) then
			return MapNotes_Keys[key].name, MapNotes_Keys[key].longName, WORLD_MAP;
		end
	end

	return tostring(key), tostring(key);	-- Allow for no Localised Name data (i.e. at least don't return nil and cause a crash)
end



function MapNotes_UpgradePreviousNotes()
	if ( MapNotes_Data ) then
		local imported = nil;
		for z=1, 3, 1 do
			if ( ( MapNotes_Data[z] ) and ( type(MapNotes_Data[z]) == "table" ) ) then
				for index, records in ipairs(MapNotes_Data[z]) do
					local newKey = MapNotes_OldKeys[z][index];
					if ( newKey ) then
						if ( not MapNotes_Data_Notes[newKey] ) then
							MapNotes_Data_Notes[newKey] = {};
						end
						MapNotes_Data_Notes[newKey] = records;
						if ( ( MapNotes_Lines[z] ) and ( MapNotes_Lines[z][index] ) ) then
							if ( not MapNotes_Data_Lines[newKey] ) then
								MapNotes_Data_Lines[newKey] = {};
							end
							MapNotes_Data_Lines[newKey] = MapNotes_Lines[z][index];
						end
						imported = true;
					end
				end
			end
		end
		if ( imported ) then
			MapNotes_StatusPrint(MAPNOTES_CONVERSION_COMPLETE);
		end
		MapNotes_MiniNote_Data = {};
	end
end





-- Telic_4 Functions
-------------------------------------------------------------------------------------------------
-- Import from other Noting AddOns
--  NOTE : Not Importing any "Lines" at the moment...
-------------------------------------------------------------------------------------------------

-- METAMAP IMPORT

local numberImported;

function MapNotes_ImportMetaMap()
	local key;

	numberImported = 0;
	if ( MetaMapNotes_Data ) then
		for index, record in pairs(MetaMapNotes_Data) do
			if ( index == METAMAPNOTES_WARSONGGULCH ) then
				key = "WarsongGulch";
				if ( not MapNotes_Data_Notes[key] ) then
					MapNotes_Data_Notes[key] = {};
					MapNotes_Data_Lines[key] = {};
				end
				MapNotes_ImportZoneNotes(record, MapNotes_Data_Notes[key]);

			elseif ( index == METAMAPNOTES_ALTERACVALLEY ) then
				key = "AlteracValley";
				if ( not MapNotes_Data_Notes[key] ) then
					MapNotes_Data_Notes[key] = {};
					MapNotes_Data_Lines[key] = {};
				end
				MapNotes_ImportZoneNotes(record, MapNotes_Data_Notes[key]);

			elseif ( index == METAMAPNOTES_ARATHIBASIN ) then
				key = "ArathiBasin";
				if ( not MapNotes_Data_Notes[key] ) then
					MapNotes_Data_Notes[key] = {};
					MapNotes_Data_Lines[key] = {};
				end
				MapNotes_ImportZoneNotes(record, MapNotes_Data_Notes[key]);

			elseif ( index == 0 ) then					-- MetaMap Instances
				-- Nowhere to display Instance notes in basic version of MapNotes
				-- (Can import AlphaMap's Instance notes and use alongside AlphaMap)

			else
				for subIndex, subRecord in ipairs(record) do
					if ( MapNotes_OldKeys[index][subIndex] ) then
						local key = MapNotes_OldKeys[index][subIndex];
						if ( not MapNotes_Data_Notes[key] ) then
							MapNotes_Data_Notes[key] = {};
							MapNotes_Data_Lines[key] = {};
						end
						MapNotes_ImportZoneNotes(subRecord, MapNotes_Data_Notes[key]);
					end
				end
			end
		end
	end

	MapNotes_StatusPrint(numberImported..MAPNOTES_IMPORT_REPORT);
end

function MapNotes_ImportZoneNotes(sourceData, targetData)
	for index, record in ipairs(sourceData) do
		targetData[index] = sourceData[index];
		numberImported = numberImported + 1;
	end
end




-- ALPHAMAP IMPORT

function MapNotes_ImportAlphaMap(bgOnly)
	local key;
	numberImported = 0;

	if ( AM_ALPHAMAP_LIST ) then
		for index, map in pairs(AM_ALPHAMAP_LIST) do
			if ( ( ( bgOnly == "OnlyBGs" ) and ( map.type == AM_TYP_BG ) ) or ( ( bgOnly ~= "OnlyBGs" ) and ( map.type ~= AM_TYP_BG ) ) ) then
				local key = "AlphaMap "..(map.filename);
				if ( not MapNotes_Data_Notes[key] ) then
					MapNotes_Data_Notes[key] = {};
					MapNotes_Data_Lines[key] = {};
				end
				local targetData = MapNotes_Data_Notes[key];
				local index = 0;

				table.sort(map);
				for detailName, details in pairs(map) do
					if ( ( type(details) == "table" ) and ( details.coords ) ) then
						for point, coordinates in ipairs(details.coords) do
							numberImported = numberImported + 1;
							index = index + 1;
							local imported = MapNotes_CreateAlphaNote(details, targetData, index, coordinates);
							if ( not imported ) then
								numberImported = numberImported - 1;
								index = index - 1;
							end
						end
					end
				end
			end
		end
	end

	MapNotes_StatusPrint(numberImported..MAPNOTES_IMPORT_REPORT);
end

function MapNotes_ImportAlphaMapBG()
	MapNotes_ImportAlphaMap("OnlyBGs");
end

function MapNotes_CreateAlphaNote(noteDetails, targetData, index, coords)
	if ( ( coords[1] == 0 ) and ( coords[2] == 0 ) ) then
		return nil;
	end

	targetData[index] = {};
	targetData[index].name = noteDetails.text;
	targetData[index].inf1 = noteDetails.tooltiptxt;
	if ( noteDetails.special ) then
		targetData[index].inf2 = noteDetails.special;
	else
		targetData[index].inf2 = "";
	end
	targetData[index].creator = "AlphaMap";
	targetData[index].xPos = coords[1] / 100;
	targetData[index].yPos = coords[2] / 100;
	targetData[index].in2c = 8;

	if ( noteDetails.colour == AM_RED ) then
		targetData[index].icon = 6;
		targetData[index].ncol = 2;
		targetData[index].in1c = 0;

	elseif ( noteDetails.colour == AM_GREEN ) then
		targetData[index].icon = 0;
		targetData[index].ncol = 4;
		targetData[index].in1c = 0;

	elseif ( noteDetails.colour == AM_BLUE ) then
		targetData[index].icon = 2;
		targetData[index].ncol = 6;
		targetData[index].in1c = 0;

	elseif ( noteDetails.colour == AM_GOLD ) then
		targetData[index].icon = 0;
		targetData[index].ncol = 0;
		targetData[index].in1c = 0;

	elseif ( noteDetails.colour == AM_PURPLE ) then
		targetData[index].icon = 7;
		targetData[index].ncol = 7;
		targetData[index].in1c = 7;

	elseif ( noteDetails.colour == AM_ORANGE ) then
		targetData[index].icon = 5;
		targetData[index].ncol = 1;
		targetData[index].in1c = 1;

	elseif ( noteDetails.colour == AM_YELLOW ) then
		targetData[index].icon = 5;
		targetData[index].ncol = 0;
		targetData[index].in1c = 0;
	end

	-- For possible Future Development
	if ( noteDetails.lootid ) then
		targetData[index].lootid = noteDetails.lootid;
	end

	return true;
end



-- CTMapMod

function MapNotes_ImportCTMap()
	numberImported = 0;

	if ( CT_UserMap_Notes ) then
		for mnKey, values in pairs(MapNotes_Keys) do
			local ctKey = values.name;
			local mnIndex = 0;

			if ( CT_UserMap_Notes[ctKey] ) then
				for ctNoteIndex, ctNote in ipairs(CT_UserMap_Notes[ctKey]) do
					if ( ctNote.set < 7 ) then
						mnIndex = mnIndex + 1;
						numberImported = numberImported + 1;
						local targetData = MapNotes_Data_Notes[mnKey];
						MapNotes_CreateCTNote(ctNote, targetData, mnIndex);
					end
				end
			end
		end
	end

	MapNotes_StatusPrint(numberImported..MAPNOTES_IMPORT_REPORT);
end

function MapNotes_CreateCTNote(noteDetails, targetData, index)
	targetData[index] = {};
	targetData[index].name = noteDetails.name;
	targetData[index].inf1 = noteDetails.descript;
	targetData[index].inf2 = "";
	targetData[index].creator = "CTMapMod";
	targetData[index].xPos = noteDetails.x;
	targetData[index].yPos = noteDetails.y;
	targetData[index].in2c = 0;

	if ( noteDetails.set == 1 ) then
		targetData[index].icon = 0;
		targetData[index].ncol = 0;
		targetData[index].in1c = 0;

	elseif ( noteDetails.set == 2 ) then
		targetData[index].icon = 2;
		targetData[index].ncol = 7;
		targetData[index].in1c = 7;

	elseif ( noteDetails.set == 3 ) then
		targetData[index].icon = 1;
		targetData[index].ncol = 2;
		targetData[index].in1c = 2;

	elseif ( noteDetails.set == 4 ) then
		targetData[index].icon = 4;
		targetData[index].ncol = 8;
		targetData[index].in1c = 8;

	elseif ( noteDetails.set == 5 ) then
		targetData[index].icon = 3;
		targetData[index].ncol = 4;
		targetData[index].in1c = 4;

	elseif ( noteDetails.set == 6 ) then
		targetData[index].icon = 6;
		targetData[index].ncol = 3;
		targetData[index].in1c = 3;
	end
end