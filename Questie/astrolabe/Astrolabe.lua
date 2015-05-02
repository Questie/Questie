--[[
Name: Astrolabe
Revision: $Rev: 17 $
$Date: 2006-11-26 09:36:31 +0100 (So, 26 Nov 2006) $
Author(s): Esamynn (jcarrothers@gmail.com)
Inspired By: Gatherer by Norganna
             MapLibrary by Kristofer Karlsson (krka@kth.se)
Website: http://esamynn.wowinterface.com/
Documentation: 
SVN: 
Description:
	This is a library for the World of Warcraft UI system to place
	icons accurately on both the Minimap and the Worldmaps accurately
	and maintain the accuracy of those positions.  

License:

Copyright (C) 2006  James Carrothers

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
]]

local LIBRARY_VERSION_MAJOR = "Astrolabe-0.2"
local LIBRARY_VERSION_MINOR = "$Revision: 17 $"

if not AceLibrary then error(LIBRARY_VERSION_MAJOR .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR) then return end

Astrolabe = {};

-- define local variables for Data Tables (defined at the end of this file)
local WorldMapSize, MinimapSize;

--------------------------------------------------------------------------------------------------------------
-- Working Tables and Config Constants
--------------------------------------------------------------------------------------------------------------

Astrolabe.LastPlayerPosition = {};
Astrolabe.MinimapIcons = {};


Astrolabe.MinimapUpdateTime = 0.2;
Astrolabe.UpdateTimer = 0;
Astrolabe.ForceNextUpdate = false;

local twoPi = math.pi * 2;


--------------------------------------------------------------------------------------------------------------
-- General Uility Functions
--------------------------------------------------------------------------------------------------------------

local function getContPosition( zoneData, z, x, y )
	--Fixes nil error
	if z < 0 then
		z = 1;
	end
	if ( z ~= 0 ) then
		zoneData = zoneData[z];
		x = x * zoneData.width + zoneData.xOffset;
		y = y * zoneData.height + zoneData.yOffset;
	else
		x = x * zoneData.width;
		y = y * zoneData.height;
	end
	return x, y;
end

function Astrolabe:ComputeDistance( c1, z1, x1, y1, c2, z2, x2, y2 )
	z1 = z1 or 0;
	z2 = z2 or 0;
	
	local dist, xDelta, yDelta;
	if ( c1 == c2 and z1 == z2 ) then
		-- points in the same zone
		local zoneData = WorldMapSize[c1];
		if ( z1 ~= 0 ) then
			zoneData = zoneData[z1];
		end
		if zoneData == nil then
			return 0, 0, 0; -- temporary fix, todo: log this
		end
		xDelta = (x2 - x1) * zoneData.width;
		yDelta = (y2 - y1) * zoneData.height;
	
	elseif ( c1 == c2 ) then
		-- points on the same continent
		local zoneData = WorldMapSize[c1];
		if zoneData == nil then
			return 0, 0, 0; -- temporary fix, todo: log this
		end
		x1, y1 = getContPosition(zoneData, z1, x1, y1);
		x2, y2 = getContPosition(zoneData, z2, x2, y2);
		xDelta = (x2 - x1);
		yDelta = (y2 - y1);
	
	elseif ( c1 and c2 ) then
		local cont1 = WorldMapSize[c1];
		local cont2 = WorldMapSize[c2];
		if cont1 == nil or cont2 == nil then
			return 0, 0, 0; -- temporary fix, todo: log this
		end
		if ( cont1.parentContinent == cont2.parentContinent ) then
			if ( c1 ~= cont1.parentContinent ) then
				x1, y1 = getContPosition(cont1, z1, x1, y1);
				x1 = x1 + cont1.xOffset;
				y1 = y1 + cont1.yOffset;
			end
			if ( c2 ~= cont2.parentContinent ) then
				x2, y2 = getContPosition(cont2, z2, x2, y2);
				x2 = x2 + cont2.xOffset;
				y2 = y2 + cont2.yOffset;
			end
			
			xDelta = x2 - x1;
			yDelta = y2 - y1;
		end
	
	end
	if ( xDelta and yDelta ) then
		dist = sqrt(xDelta*xDelta + yDelta*yDelta);
	end
	return dist, xDelta, yDelta;
end

function Astrolabe:TranslateWorldMapPosition( C, Z, xPos, yPos, nC, nZ )
	Z = Z or 0;
	nZ = nZ or 0;
	if ( nC < 0 ) then
		return;
	end
	
	--Fixes nil error.
	if(C < 0) then
		C=2;
	end
	if(nC < 0) then
		nC = 2;
	end

	local zoneData;
	if ( C == nC and Z == nZ ) then
		return xPos, yPos;
	
	elseif ( C == nC ) then
		-- points on the same continent
		zoneData = WorldMapSize[C];
		xPos, yPos = getContPosition(zoneData, Z, xPos, yPos);
		if ( nZ ~= 0 ) then
			zoneData = WorldMapSize[C][nZ];
			xPos = xPos - zoneData.xOffset;
			yPos = yPos - zoneData.yOffset;
		end
	
	elseif ( C and nC ) and ( WorldMapSize[C].parentContinent == WorldMapSize[nC].parentContinent ) then
		-- different continents, same world
		zoneData = WorldMapSize[C];
		local parentContinent = zoneData.parentContinent;
		xPos, yPos = getContPosition(zoneData, Z, xPos, yPos);
		if ( C ~= parentContinent ) then
			-- translate up to world map if we aren't there already
			xPos = xPos + zoneData.xOffset;
			yPos = yPos + zoneData.yOffset;
			zoneData = WorldMapSize[parentContinent];
		end
		if ( nC ~= parentContinent ) then
			--translate down to the new continent
			zoneData = WorldMapSize[nC];
			xPos = xPos - zoneData.xOffset;
			yPos = yPos - zoneData.yOffset;
			if ( nZ ~= 0 ) then
				zoneData = zoneData[nZ];
				xPos = xPos - zoneData.xOffset;
				yPos = yPos - zoneData.yOffset;
			end
		end
	
	else
		return;
	end
	
	return (xPos / zoneData.width), (yPos / zoneData.height);
end

Astrolabe_LastX = 0;
Astrolabe_LastY = 0;
Astrolabe_LastZ = 0;
Astrolabe_LastC = 0;
function Astrolabe:GetCurrentPlayerPosition()
	Z = GetCurrentMapZone();
	C = GetCurrentMapContinent();
	local x, y = GetPlayerMapPosition("player");
	if(WorldMapFrame:IsVisible() == nil or (Astrolabe_LastZ == Z and Astrolabe_LastC == C)) then
		if ( x <= 0 and y <= 0 ) then
			SetMapToCurrentZone();
			x, y = GetPlayerMapPosition("player");
			Astrolabe_LastX = x;
			Astrolabe_LastY = y;
			if ( x <= 0 and y <= 0 ) then
				SetMapZoom(GetCurrentMapContinent());
				x, y = GetPlayerMapPosition("player");
				Astrolabe_LastX = x;
				Astrolabe_LastY = y;
				if ( x <= 0 and y <= 0 ) then
					-- we are in an instance or otherwise off the continent map
					return;
				end
			end
		end
		Astrolabe_LastZ = GetCurrentMapZone();
		Astrolabe_LastC = GetCurrentMapContinent();
		return Astrolabe_LastC, Astrolabe_LastZ, x, y;
	else
		return Astrolabe_LastC, Astrolabe_LastZ, Astrolabe_LastX, Astrolabe_LastY;
	end
end

--------------------------------------------------------------------------------------------------------------
-- Working Table Cache System
--------------------------------------------------------------------------------------------------------------

local tableCache = {};
tableCache["__mode"] = "v";
setmetatable(tableCache, tableCache);

local function GetWorkingTable( icon )
	if ( tableCache[icon] ) then
		return tableCache[icon];
	else
		local T = {};
		tableCache[icon] = T;
		return T;
	end
end


--------------------------------------------------------------------------------------------------------------
-- Minimap Icon Placement
--------------------------------------------------------------------------------------------------------------

function Astrolabe:PlaceIconOnMinimap( icon, continent, zone, xPos, yPos )
	-- check argument types
	self:argCheck(icon, 2, "table");
	self:assert(icon.SetPoint and icon.ClearAllPoints, "Usage Message");
	self:argCheck(continent, 3, "number");
	self:argCheck(zone, 4, "number", "nil");
	self:argCheck(xPos, 5, "number");
	self:argCheck(yPos, 6, "number");
	
	local lC, lZ, lx, ly = unpack(self.LastPlayerPosition);
	local dist, xDist, yDist = self:ComputeDistance(lC, lZ, lx, ly, continent, zone, xPos, yPos);
	if not ( dist ) then
		--icon's position has no meaningful position relative to the player's current location
		return -1;
	end
	local iconData = self.MinimapIcons[icon];
	if not ( iconData ) then
		iconData = GetWorkingTable(icon);
		self.MinimapIcons[icon] = iconData;
	end
	iconData.continent = continent;
	iconData.zone = zone;
	iconData.xPos = xPos;
	iconData.yPos = yPos;
	iconData.dist = dist;
	iconData.xDist = xDist;
	iconData.yDist = yDist;
	
	--show the new icon and force a placement update on the next screen draw
	icon:Show()
	self.UpdateTimer = 0;
	Astrolabe.ForceNextUpdate = true;
	
	return 0;
end

function Astrolabe:RemoveIconFromMinimap( icon )
	if not ( self.MinimapIcons[icon] ) then
		return 1;
	end
	self.MinimapIcons[icon] = nil;
	icon:Hide();
	return 0;
end

function Astrolabe:RemoveAllMinimapIcons()
	local minimapIcons = self.MinimapIcons
	for k, v in pairs(minimapIcons) do
		minimapIcons[k] = nil;
		k:Hide();
	end
end

local function placeIconOnMinimap( minimap, minimapZoom, mapWidth, mapHeight, icon, dist, xDist, yDist )
	--TODO: add support for non-circular minimaps
	local mapDiameter;
	if ( Astrolabe.minimapOutside or true) then -- cheeky bastard
		mapDiameter = MinimapSize.outdoor[minimapZoom];
	else
		mapDiameter = MinimapSize.indoor[minimapZoom];
	end
	local mapRadius = mapDiameter / 2;
	local xScale = mapDiameter / mapWidth;
	local yScale = mapDiameter / mapHeight;
	local iconDiameter = ((icon:GetWidth() / 2) + 3) * xScale;
	
	icon:ClearAllPoints();
	if ( (dist + iconDiameter) > mapRadius ) then
		-- position along the outside of the Minimap
		local factor = (mapRadius - iconDiameter) / dist;
		xDist = xDist * factor;
		yDist = yDist * factor;
	end
	icon:SetPoint("CENTER", minimap, "CENTER", xDist/xScale, -yDist/yScale);
end

local lastZoom;
function Astrolabe:UpdateMinimapIconPositions()
	local C, Z, x, y = self:GetCurrentPlayerPosition();
	if not ( C and Z and x and y ) then
		self.processingFrame:Hide();
	end
	local Minimap = Minimap;
	local lastPosition = self.LastPlayerPosition;
	local lC, lZ, lx, ly = unpack(lastPosition);
	
	if ( (lC == C and lZ == Z and lx == x and ly == y)) then--Added or WorldMapFrame:IsVisible() to fix the jumping around minimap icons when the map is opened -- Removed it not needed?
		-- player has not moved since the last update
		if ( lastZoom ~= Minimap:GetZoom() or self.ForceNextUpdate ) then
			local currentZoom = Minimap:GetZoom();
			lastZoom = currentZoom;
			local mapWidth = Minimap:GetWidth();
			local mapHeight = Minimap:GetHeight();
			for icon, data in pairs(self.MinimapIcons) do
				placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, data.dist, data.xDist, data.yDist);
			end
			self.ForceNextUpdate = false;
		end
	else
		local dist, xDelta, yDelta = self:ComputeDistance(lC, lZ, lx, ly, C, Z, x, y);
		local currentZoom = Minimap:GetZoom();
		lastZoom = currentZoom;
		local mapWidth = Minimap:GetWidth();
		local mapHeight = Minimap:GetHeight();
		for icon, data in pairs(self.MinimapIcons) do
			local xDist = data.xDist - xDelta;
			local yDist = data.yDist - yDelta;
			local dist = sqrt(xDist*xDist + yDist*yDist);

			placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, dist, xDist, yDist);
			
			data.dist = dist;
			data.xDist = xDist;
			data.yDist = yDist;
		end
		
		lastPosition[1] = C;
		lastPosition[2] = Z;
		lastPosition[3] = x;
		lastPosition[4] = y;
		--self.LastPlayerPosition = lastPosition;--It did not set before? Wonder why...
	end
end

function Astrolabe:CalculateMinimapIconPositions()
	local C, Z, x, y = self:GetCurrentPlayerPosition();
	if not ( C and Z and x and y ) then
		self.processingFrame:Hide();
	end
	
	local currentZoom = Minimap:GetZoom();
	lastZoom = currentZoom;
	local Minimap = Minimap;
	local mapWidth = Minimap:GetWidth();
	local mapHeight = Minimap:GetHeight();
	for icon, data in pairs(self.MinimapIcons) do
		local dist, xDist, yDist = self:ComputeDistance(C, Z, x, y, data.continent, data.zone, data.xPos, data.yPos);
		placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, dist, xDist, yDist);
		
		data.dist = dist;
		data.xDist = xDist;
		data.yDist = yDist;
	end
	
	local lastPosition = self.LastPlayerPosition;
	lastPosition[1] = C;
	lastPosition[2] = Z;
	lastPosition[3] = x;
	lastPosition[4] = y;
	--self.LastPlayerPosition = lastPosition;--It did not set before? Wonder why...
end

function Astrolabe:GetDistanceToIcon( icon )
	local data = Astrolabe.MinimapIcons[icon];
	if ( data ) then
		return data.dist, data.xDist, data.yDist;
	end
end

function Astrolabe:GetDirectionToIcon( icon )
	local data = Astrolabe.MinimapIcons[icon];
	if ( data ) then
		local dir = atan2(data.xDist, -(data.yDist))
		if ( dir > 0 ) then
			return twoPi - dir;
		else
			return -dir;
		end
	end
end

--------------------------------------------------------------------------------------------------------------
-- World Map Icon Placement
--------------------------------------------------------------------------------------------------------------

function Astrolabe:PlaceIconOnWorldMap( worldMapFrame, icon, continent, zone, xPos, yPos )
	-- check argument types
	self:argCheck(worldMapFrame, 2, "table");
	self:assert(worldMapFrame.GetWidth and worldMapFrame.GetHeight, "Usage Message");
	self:argCheck(icon, 3, "table");
	self:assert(icon.SetPoint and icon.ClearAllPoints, "Usage Message");
	self:argCheck(continent, 4, "number");
	self:argCheck(zone, 5, "number", "nil");
	self:argCheck(xPos, 6, "number");
	self:argCheck(yPos, 7, "number");
	
	local C, Z = GetCurrentMapContinent(), GetCurrentMapZone();
	local nX, nY = self:TranslateWorldMapPosition(continent, zone, xPos, yPos, C, Z);
	if ( nX and nY and (0 < nX and nX <= 1) and (0 < nY and nY <= 1) ) then
		icon:ClearAllPoints();
		icon:SetPoint("CENTER", worldMapFrame, "TOPLEFT", nX * worldMapFrame:GetWidth(), -nY * worldMapFrame:GetHeight());
	end
	return nX, nY;
end


--------------------------------------------------------------------------------------------------------------
-- Handler Scripts
--------------------------------------------------------------------------------------------------------------

function Astrolabe:OnEvent( frame, event )
	if ( event == "MINIMAP_UPDATE_ZOOM" ) then
		-- update minimap zoom scale
		local Minimap = Minimap;
		local curZoom = Minimap:GetZoom();
		if ( GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") ) then
			if ( curZoom < 2 ) then
				Minimap:SetZoom(curZoom + 1);
			else
				Minimap:SetZoom(curZoom - 1);
			end
		end
		if ( GetCVar("minimapZoom")+0 == Minimap:GetZoom() ) then
			self.minimapOutside = true;
		else
			self.minimapOutside = false;
		end
		Minimap:SetZoom(curZoom);
		
		-- re-calculate all Minimap Icon positions
		if ( frame:IsVisible() ) then
			self:CalculateMinimapIconPositions();
		end
	
	elseif ( event == "PLAYER_LEAVING_WORLD" ) then
		frame:Hide();
		self:RemoveAllMinimapIcons(); --dump all minimap icons
	
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		frame:Show();
	
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		frame:Show();
	
	end
end

function Astrolabe:OnUpdate( frame, elapsed )
	local updateTimer = self.UpdateTimer - elapsed;
	if ( updateTimer > 0 ) then
		self.UpdateTimer = updateTimer;
		return;
	end
	self.UpdateTimer = self.MinimapUpdateTime;
	self:UpdateMinimapIconPositions();
end

function Astrolabe:OnShow( frame )
	self:CalculateMinimapIconPositions();
end


--------------------------------------------------------------------------------------------------------------
-- Library Registration
--------------------------------------------------------------------------------------------------------------

local function activate( self, oldLib, oldDeactivate )
	Astrolabe = self;
	local frame = self.processingFrame;
	if not ( frame ) then
		frame = CreateFrame("Frame");
		self.processingFrame = frame;
	end
	frame:SetParent("Minimap");
	frame:Hide();
	frame:UnregisterAllEvents();
	frame:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	frame:RegisterEvent("PLAYER_LEAVING_WORLD");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	frame:SetScript("OnEvent",
		function( frame, event)
			self:OnEvent(frame, event);
		end
	);
	frame:SetScript("OnUpdate",
		function( frame, elapsed )
			-- elapsed doesn't work in Lua created frames, however it is equal to the time passed between each frame. So calulcate from FPS ;)
			self:OnUpdate(frame, 1/GetFramerate());
		end
	);
	frame:SetScript("OnShow",
		function( frame )
			self:OnShow(frame);
		end
	);
	frame:Show();
	
	if not ( self.ContinentList ) then
		self.ContinentList = { GetMapContinents() };
		for C in pairs(self.ContinentList) do
			local zones = { GetMapZones(C) };
			self.ContinentList[C] = zones;
			for Z in ipairs(zones) do
				SetMapZoom(C, Z);
				zones[Z] = GetMapInfo();
			end
		end
	end
end

AceLibrary:Register(Astrolabe, LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR, activate)


--------------------------------------------------------------------------------------------------------------
-- Data
--------------------------------------------------------------------------------------------------------------

-- diameter of the Minimap in game yards at
-- the various possible zoom levels
MinimapSize = {
	indoor = {
		[0] = 300, -- scale
		[1] = 240, -- 1.25
		[2] = 180, -- 5/3
		[3] = 120, -- 2.5
		[4] = 80,  -- 3.75
		[5] = 50,  -- 6
	},
	outdoor = {
		[0] = 466 + 2/3, -- scale
		[1] = 400,       -- 7/6
		[2] = 333 + 1/3, -- 1.4
		[3] = 266 + 2/6, -- 1.75
		[4] = 200,       -- 7/3
		[5] = 133 + 1/3, -- 3.5
	},
}

-- distances across and offsets of the world maps
-- in game yards
WorldMapSize = {
	-- World Map of Azeroth
	[0] = {
		parentContinent = 0,
		height = 29687.90575403711,
		width = 44531.82907938571,
	},
	-- Kalimdor
	[1] = {
		parentContinent = 0,
		height = 24532.39670836129,
		width = 36798.56388065484,
		xOffset = -8310.762035321373,
		yOffset = 1815.149000954498,
		zoneData = {
			Ashenvale = {
				height = 3843.627450950699,
				width = 5766.471113365881,
				xOffset = 15366.08027406009,
				yOffset = 8126.716152815561,
			},
			Aszhara = {
				height = 3381.153764845262,
				width = 5070.669448432522,
				xOffset = 20342.99178351035,
				yOffset = 7457.974565554941,
			},
			AzuremystIsle = {
				height = 2714.490705490833,
				width = 4070.691916244019,
				xOffset = 9966.264785353642,
				yOffset = 5460.139378090237,
			},
			Barrens = {
				height = 6756.028094350823,
				width = 10132.98626357964,
				xOffset = 14443.19633043607,
				yOffset = 11187.03406016663,
			},
			BloodmystIsle = {
				height = 2174.923922716305,
				width = 3262.385067990556,
				xOffset = 9541.280691875327,
				yOffset = 3424.790637352245,
			},
			Darkshore = {
				height = 4366.52571734943,
				width = 6549.780280774227,
				xOffset = 14124.4534386827,
				yOffset = 4466.419105960455,
			},
			Darnassis = {
				height = 705.7102838625474,
				width = 1058.300884213672,
				xOffset = 14127.75729935019,
				yOffset = 2561.497770365213,
			},
			Desolace = {
				height = 2997.808472061639,
				width = 4495.726850591814,
				xOffset = 12832.80723200791,
				yOffset = 12347.420176847,
			},
			Durotar = {
				height = 3524.884894927208,
				width = 5287.285801274457,
				xOffset = 19028.47465485265,
				yOffset = 10991.20642822035,
			},
			Dustwallow = {
				height = 3499.922239823486,
				width = 5249.824712249077,
				xOffset = 18040.98829886713,
				yOffset = 14832.74650226312,
			},
			Felwood = {
				height = 3833.206376333298,
				width = 5749.8046476606,
				xOffset = 15424.4116748014,
				yOffset = 5666.381311442202,
			},
			Feralas = {
				height = 4633.182754891688,
				width = 6949.760203962193,
				xOffset = 11624.54217828119,
				yOffset = 15166.06954533647,
			},
			Moonglade = {
				height = 1539.548478194226,
				width = 2308.253559286662,
				xOffset = 18447.22668103606,
				yOffset = 4308.084192710569,
			},
			Mulgore = {
				height = 3424.88834791471,
				width = 5137.32138887616,
				xOffset = 15018.17633401988,
				yOffset = 13072.38917227894,
			},
			Ogrimmar = {
				height = 935.3750279485016,
				width = 1402.563051365538,
				xOffset = 20746.49533101771,
				yOffset = 10525.68532631853,
			},
			Silithus = {
				height = 2322.839629859208,
				width = 3483.224287356748,
				xOffset = 14528.60591761034,
				yOffset = 18757.61998086822,
			},
			StonetalonMountains = {
				height = 3256.141917023559,
				width = 4883.173287670144,
				xOffset = 13820.29750397374,
				yOffset = 9882.909063258192,
			},
			Tanaris = {
				height = 4599.847335452488,
				width = 6899.765399158026,
				xOffset = 17284.7655865671,
				yOffset = 18674.28905369955,
			},
			Teldrassil = {
				height = 3393.632169760774,
				width = 5091.467863261982,
				xOffset = 13251.58449896318,
				yOffset = 968.6223632831094,
			},
			TheExodar = {
				height = 704.6641703983866,
				width = 1056.732317707213,
				xOffset = 10532.61275516805,
				yOffset = 6276.045028807911,
			},
			ThousandNeedles = {
				height = 2933.241274801781,
				width = 4399.86408093722,
				xOffset = 17499.32929341832,
				yOffset = 16766.0151133423,
			},
			ThunderBluff = {
				height = 695.8116150081206,
				width = 1043.762849319158,
				xOffset = 16549.32009877855,
				yOffset = 13649.45129927044,
			},
			UngoroCrater = {
				height = 2466.588521980952,
				width = 3699.872808671186,
				xOffset = 16532.70803775362,
				yOffset = 18765.95157787033,
			},
			Winterspring = {
				height = 4733.190938744951,
				width = 7099.756078049357,
				xOffset = 17382.67868933954,
				yOffset = 4266.421320915686,
			},
		},
	},
	-- Eastern Kingdoms
	[2] = {
		parentContinent = 0,
		height = 25098.84390074281,-- added 500 (seems about right total guess) to "remove" the blood elf start zones You need to logout each time you change these values
		width = 37649.15159852673,
		xOffset = 15425.32200715066,--old 15525
		yOffset = 1272.3934326738229,--Old 670 
		zoneData = {
			Alterac = {
				height = 1866.508741236576,
				width = 2799.820894040741,
				xOffset = 16267.51182664554,--old 16267
				yOffset = 7000.598754637632,--old 7693
			},
			Arathi = {
				height = 2399.784956908336,
				width = 3599.78645678886,
				xOffset = 18317.40598190062,--17917.40598190062, Switched to more sane values!18317
				yOffset = 8826.804744097401,--9326.804744097401, 8826
			},
			Badlands = {
				height = 1658.195027852759,
				width = 2487.343589680943,
				xOffset = 19129.83542887301,
				yOffset = 15082.55526717644,
			},
			BlastedLands = {
				height = 2233.146573433955,
				width = 3349.808966078055,
				xOffset = 18292.37876312771,
				yOffset = 19759.24272564734,
			},
			BurningSteppes = {
				height = 1951.911155356982,
				width = 2928.988452241535,
				xOffset = 17317.44291506163,
				yOffset = 16224.12640057407,
			},
			DeadwindPass = {
				height = 1666.528298197048,
				width = 2499.848163715574,
				xOffset = 17884.07519016362,
				yOffset = 19059.30117481421,
			},
			DunMorogh = {
				height = 3283.064682642022,
				width = 4924.664537147015,
				xOffset = 15248.84370721237,
				yOffset = 13070.22369811241,
			},
			Duskwood = {
				height = 1799.84874595001,
				width = 2699.837284973949,
				xOffset = 16217.51007473156,
				yOffset = 18909.31475362112,
			},
			EasternPlaguelands = {
				height = 2581.024511737268,
				width = 3870.596078314358,
				xOffset = 19836.07699848783,--old 19636
				yOffset = 4593.799386328108,--Old 5393
			},
			Elwynn = {
				height = 2314.38613060264,
				width = 3470.62593362794,
				xOffset = 15515.46777926721,
				yOffset = 17132.38313881497,
			},
			EversongWoods = {
				height = 3283.057803444214,
				width = 4924.70470173181,
				xOffset = 19138.16325760612,
				yOffset = 552.5351270080572,
			},
			Ghostlands = {
				height = 2199.788221727843,
				width = 3299.755735439147,
				xOffset = 19933.969945598,
				yOffset = 3327.317139912411,
			},
			Hilsbrad = {
				height = 2133.153088717906,
				width = 3199.802496078764,
				xOffset = 15984.19170342619,
				yOffset = 8793.505832296016,
			},
			Hinterlands = {
				height = 2566.448674847725,
				width = 3849.77134323942,
				xOffset = 18625.69536724846,
				yOffset = 7226.929725104341, --Old 7726
			},
			Ironforge = {
				height = 527.5626661642974,
				width = 790.5745810546713,
				xOffset = 17764.34206355846,
				yOffset = 13762.32403658607,
			},
			LochModan = {
				height = 1839.436067817912,
				width = 2758.158752877019,
				xOffset = 19400.42466174755,--19044
				yOffset = 13500.58746225864,--13680
			},
			Redridge = {
				height = 1447.811817383856,
				width = 2170.704876735185,
				xOffset = 18621.52904187992,
				yOffset = 17767.73128664901,
			},
			SearingGorge = {
				height = 1487.371558351205,
				width = 2231.119799153945,
				xOffset = 17373.68649889545,
				yOffset = 15292.9566475719,
			},
			SilvermoonCity = {
				height = 806.6680775210333,
				width = 1211.384457945605,
				xOffset = 21051.29911245071,
				yOffset = 1440.439646345552,
			},
			Silverpine = {
				height = 2799.763349841058,
				width = 4199.739879721531,
				xOffset = 13601.00798540562,
				yOffset = 6800.945768538925,--old 7526
			},
			Stormwind = {
				height = 896.2784132739149,
				width = 1344.138055148283,
				xOffset = 15669.93346231942,
				yOffset = 17471.62163820253,
			},
			Stranglethorn = {
				height = 4253.796738213571,
				width = 6380.866711475876,
				xOffset = 14830.09122763351,
				yOffset = 20361.27611706414,
			},
			SwampOfSorrows = {
				height = 1529.04028583782,
				width = 2293.606089974149,
				xOffset = 19273.57577346738,
				yOffset = 18813.48829580375,
			},
			Tirisfal = {
				height = 3012.244783356771,
				width = 4518.469744413802,
				xOffset = 14017.64852522109,--old
				yOffset = 4556.296558943325,--old
			},
			Undercity = {
				height = 640.0492683780853,
				width = 959.3140238076666,
				xOffset = 16177.65630384973,--16177
				yOffset = 6415.685533181013,--7315
			},
			WesternPlaguelands = {
				height = 2866.410476553068,
				width = 4299.7374000546,
				xOffset = 16950.14908983872,--old 16634
				yOffset = 5000.092974820261,--old 5827
			},
			Westfall = {
				height = 2333.132106534445,
				width = 3499.786489780177,
				xOffset = 14034.31142029944,
				yOffset = 18592.67765947875,
			},
			Wetlands = {
				height = 2756.004767589141,
				width = 4135.166184805389,
				xOffset = 17680.35277057554,--17440
				yOffset = 11100.20698670613,--11341
			},
		},
	},
	-- Outland
	[3] = {
		parentContinent = 3,
		height = 11642.3552270912,
		width = 17463.5328406368,
		zoneData = {
			BladesEdgeMountains = {
				height = 3616.553353533977,
				width = 5424.84803598309,
				xOffset = 4150.068157139826,
				yOffset = 1412.982266241851,
			},
			Hellfire = {
				height = 3443.642890402687,
				width = 5164.421615455519,
				xOffset = 7456.223236253186,
				yOffset = 4339.973528794677,
			},
			Nagrand = {
				height = 3683.218386203915,
				width = 5524.827295176373,
				xOffset = 2700.121400200201,
				yOffset = 5779.512212073806,
			},
			Netherstorm = {
				height = 3716.547708910237,
				width = 5574.82788866266,
				xOffset = 7512.470386633603,
				yOffset = 365.0992858464317,
			},
			ShadowmoonValley = {
				height = 3666.547917042888,
				width = 5499.827432644566,
				xOffset = 8770.765422136874,
				yOffset = 7769.034259125071,
			},
			ShattrathCity = {
				height = 870.8063021892297,
				width = 1306.210386847456,
				xOffset = 6860.565394341991,
				yOffset = 7295.086145447915,
			},
			TerokkarForest = {
				height = 3599.889712038368,
				width = 5399.832305361811,
				xOffset = 5912.521284664757,
				yOffset = 6821.146112637057,
			},
			Zangarmarsh = {
				height = 3351.978685113859,
				width = 5026.925554043871,
				xOffset = 3520.930685571132,
				yOffset = 3885.821388791224,
			},
		},
	},
}

for c, v in pairs(WorldMapSize[2]["zoneData"]) do
	v.yOffset = v.yOffset-500;
end

local zeroData = { xOffset = 0, height = 0, yOffset = 0, width = 0 };
for continent, zones in pairs(Astrolabe.ContinentList) do
	local mapData = WorldMapSize[continent];
	for index, mapName in pairs(zones) do
		if not ( mapData.zoneData[mapName] ) then
			--WE HAVE A PROBLEM!!!
			ChatFrame1:AddMessage("Astrolabe is missing data for "..select(index, GetMapZones(continent))..".");
			mapData.zoneData[mapName] = zeroData;
		end
		mapData[index] = mapData.zoneData[mapName];
		mapData.zoneData[mapName] = nil;
	end
end
