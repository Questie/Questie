--[[
Name: Astrolabe
Revision: $Rev: 90 $
$Date: 2008-08-20 18:48:43 -0700 (Wed, 20 Aug 2008) $
Author(s): Esamynn (esamynn at wowinterface.com)
Inspired By: Gatherer by Norganna
             MapLibrary by Kristofer Karlsson (krka at kth.se)
Documentation: http://wiki.esamynn.org/Astrolabe
SVN: http://svn.esamynn.org/astrolabe/
Description:
	This is a library for the World of Warcraft UI system to place
	icons accurately on both the Minimap and on Worldmaps.  
	This library also manages and updates the position of Minimap icons 
	automatically.  

Copyright (C) 2006-2008 James Carrothers

License:
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

Note:
	This library's source code is specifically designed to work with
	World of Warcraft's interpreted AddOn system.  You have an implicit
	licence to use this library with these facilities since that is its
	designated purpose as per:
	http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

-- WARNING!!!
-- DO NOT MAKE CHANGES TO THIS LIBRARY WITHOUT FIRST CHANGING THE LIBRARY_VERSION_MAJOR
-- STRING (to something unique) OR ELSE YOU MAY BREAK OTHER ADDONS THAT USE THIS LIBRARY!!!
local LIBRARY_VERSION_MAJOR = "Astrolabe-0.4"
local LIBRARY_VERSION_MINOR = tonumber(string.match("$Revision: 90 $", "(%d+)") or 1)

if not DongleStub then error(LIBRARY_VERSION_MAJOR .. " requires DongleStub.") end
if not DongleStub:IsNewerVersion(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR) then return end

local Astrolabe = {};

-- define local variables for Data Tables (defined at the end of this file)
local WorldMapSize, MinimapSize, ValidMinimapShapes;

function Astrolabe:GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end


--------------------------------------------------------------------------------------------------------------
-- Config Constants
--------------------------------------------------------------------------------------------------------------

local configConstants = { 
	MinimapUpdateMultiplier = true, 
}

-- this constant is multiplied by the current framerate to determine
-- how many icons are updated each frame
Astrolabe.MinimapUpdateMultiplier = 1;


--------------------------------------------------------------------------------------------------------------
-- Working Tables
--------------------------------------------------------------------------------------------------------------

Astrolabe.LastPlayerPosition = { 0, 0, 0, 0 };
Astrolabe.MinimapIcons = {};
Astrolabe.IconsOnEdge = {};
Astrolabe.IconsOnEdge_GroupChangeCallbacks = {};

Astrolabe.MinimapIconCount = 0
Astrolabe.ForceNextUpdate = false;
Astrolabe.IconsOnEdgeChanged = false;

-- This variable indicates whether we know of a visible World Map or not.  
-- The state of this variable is controlled by the AstrolabeMapMonitor library.  
Astrolabe.WorldMapVisible = false;

local AddedOrUpdatedIcons = {}
local MinimapIconsMetatable = { __index = AddedOrUpdatedIcons }


--------------------------------------------------------------------------------------------------------------
-- Local Pointers for often used API functions
--------------------------------------------------------------------------------------------------------------

local twoPi = math.pi * 2;
local atan2 = math.atan2;
local sin = math.sin;
local cos = math.cos;
local abs = math.abs;
local sqrt = math.sqrt;
local min = math.min
local max = math.max
local yield = coroutine.yield
local GetFramerate = GetFramerate


--------------------------------------------------------------------------------------------------------------
-- Internal Utility Functions
--------------------------------------------------------------------------------------------------------------

local function assert(level,condition,message)
	if not condition then
		error(message,level)
	end
end

local function argcheck(value, num, ...)
	assert(1, type(num) == "number", "Bad argument #2 to 'argcheck' (number expected, got " .. type(level) .. ")")
	
	for i=1,select("#", ...) do
		if type(value) == select(i, ...) then return end
	end
	
	local types = strjoin(", ", ...)
	local name = string.match(debugstack(2,2,0), ": in function [`<](.-)['>]")
	error(string.format("Bad argument #%d to 'Astrolabe.%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end

local function getContPosition( zoneData, z, x, y )
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


--------------------------------------------------------------------------------------------------------------
-- General Utility Functions
--------------------------------------------------------------------------------------------------------------

function Astrolabe:ComputeDistance( c1, z1, x1, y1, c2, z2, x2, y2 )
	--[[
	argcheck(c1, 2, "number");
	assert(3, c1 >= 0, "ComputeDistance: Illegal continent index to c1: "..c1);
	argcheck(z1, 3, "number", "nil");
	argcheck(x1, 4, "number");
	argcheck(y1, 5, "number");
	argcheck(c2, 6, "number");
	assert(3, c2 >= 0, "ComputeDistance: Illegal continent index to c2: "..c2);
	argcheck(z2, 7, "number", "nil");
	argcheck(x2, 8, "number");
	argcheck(y2, 9, "number");
	--]]
	
	z1 = z1 or 0;
	z2 = z2 or 0;
	
	local dist, xDelta, yDelta;
	if ( c1 == c2 and z1 == z2 ) then
		-- points in the same zone
		local zoneData = WorldMapSize[c1];
		if ( z1 ~= 0 ) then
			zoneData = zoneData[z1];
		end
		xDelta = (x2 - x1) * zoneData.width;
		yDelta = (y2 - y1) * zoneData.height;
	
	elseif ( c1 == c2 ) then
		-- points on the same continent
		local zoneData = WorldMapSize[c1];
		x1, y1 = getContPosition(zoneData, z1, x1, y1);
		x2, y2 = getContPosition(zoneData, z2, x2, y2);
		xDelta = (x2 - x1);
		yDelta = (y2 - y1);
	
	elseif ( c1 and c2 ) then
		local cont1 = WorldMapSize[c1];
		local cont2 = WorldMapSize[c2];
		if ( cont1.parentContinent == cont2.parentContinent ) then
			x1, y1 = getContPosition(cont1, z1, x1, y1);
			x2, y2 = getContPosition(cont2, z2, x2, y2);
			if ( c1 ~= cont1.parentContinent ) then
				x1 = x1 + cont1.xOffset;
				y1 = y1 + cont1.yOffset;
			end
			if ( c2 ~= cont2.parentContinent ) then
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
	--[[
	argcheck(C, 2, "number");
	argcheck(Z, 3, "number", "nil");
	argcheck(xPos, 4, "number");
	argcheck(yPos, 5, "number");
	argcheck(nC, 6, "number");
	argcheck(nZ, 7, "number", "nil");
	--]]
	
	Z = Z or 0;
	nZ = nZ or 0;
	if ( nC < 0 ) then
		return;
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
			-- translate down to the new continent
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

--*****************************************************************************
-- This function will do its utmost to retrieve some sort of valid position 
-- for the specified unit, including changing the current map zoom (if needed).  
-- Map Zoom is returned to its previous setting before this function returns.  
--*****************************************************************************
function Astrolabe:GetUnitPosition( unit, noMapChange )
	local x, y = GetPlayerMapPosition(unit);
	if ( x <= 0 and y <= 0 ) then
		if ( noMapChange ) then
			-- no valid position on the current map, and we aren't allowed
			-- to change map zoom, so return
			return;
		end
		local lastCont, lastZone = GetCurrentMapContinent(), GetCurrentMapZone();
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition(unit);
		if ( x <= 0 and y <= 0 ) then
			SetMapZoom(GetCurrentMapContinent());
			x, y = GetPlayerMapPosition(unit);
			if ( x <= 0 and y <= 0 ) then
				-- we are in an instance or otherwise off the continent map
				return;
			end
		end
		local C, Z = GetCurrentMapContinent(), GetCurrentMapZone();
		if ( C ~= lastCont or Z ~= lastZone ) then
			SetMapZoom(lastCont, lastZone); -- set map zoom back to what it was before
		end
		return C, Z, x, y;
	end
	return GetCurrentMapContinent(), GetCurrentMapZone(), x, y;
end

--*****************************************************************************
-- This function will do its utmost to retrieve some sort of valid position 
-- for the specified unit, including changing the current map zoom (if needed).  
-- However, if a monitored WorldMapFrame (See AstrolabeMapMonitor.lua) is 
-- visible, then will simply return nil if the current zoom does not provide 
-- a valid position for the player unit.  Map Zoom is returned to its previous 
-- setting before this function returns, if it was changed.  
--*****************************************************************************
function Astrolabe:GetCurrentPlayerPosition()
	local x, y = GetPlayerMapPosition("player");
	if ( x <= 0 and y <= 0 ) then
		if ( self.WorldMapVisible ) then
			-- we know there is a visible world map, so don't cause 
			-- WORLD_MAP_UPDATE events by changing map zoom
			return;
		end
		local lastCont, lastZone = GetCurrentMapContinent(), GetCurrentMapZone();
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition("player");
		if ( x <= 0 and y <= 0 ) then
			SetMapZoom(GetCurrentMapContinent());
			x, y = GetPlayerMapPosition("player");
			if ( x <= 0 and y <= 0 ) then
				-- we are in an instance or otherwise off the continent map
				return;
			end
		end
		local C, Z = GetCurrentMapContinent(), GetCurrentMapZone();
		if ( C ~= lastCont or Z ~= lastZone ) then
			SetMapZoom(lastCont, lastZone); --set map zoom back to what it was before
		end
		return C, Z, x, y;
	end
	return GetCurrentMapContinent(), GetCurrentMapZone(), x, y;
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

--*****************************************************************************
-- local variables specifically for use in this section
--*****************************************************************************
local minimapRotationEnabled = false;
local minimapShape = false;

local MinimapCompassRing = MiniMapCompassRing;
local minimapRotationOffset = -MinimapCompassRing:GetFacing()


local function placeIconOnMinimap( minimap, minimapZoom, mapWidth, mapHeight, icon, dist, xDist, yDist )
	local mapDiameter;
	if ( Astrolabe.minimapOutside ) then
		mapDiameter = MinimapSize.outdoor[minimapZoom];
	else
		mapDiameter = MinimapSize.indoor[minimapZoom];
	end
	local mapRadius = mapDiameter / 2;
	local xScale = mapDiameter / mapWidth;
	local yScale = mapDiameter / mapHeight;
	local iconDiameter = ((icon:GetWidth() / 2) + 3) * xScale;
	local iconOnEdge = nil;
	local isRound = true;
	
	if ( minimapRotationEnabled ) then
		local sinTheta = sin(minimapRotationOffset)
		local cosTheta = cos(minimapRotationOffset)
		--[[
		Math Note
		The math that is acutally going on in the next 3 lines is:
			local dx, dy = xDist, -yDist
			xDist = (dx * cosTheta) + (dy * sinTheta)
			yDist = -((-dx * sinTheta) + (dy * cosTheta))
		
		This is because the origin for map coordinates is the top left corner
		of the map, not the bottom left, and so we have to reverse the vertical 
		distance when doing the our rotation, and then reverse the result vertical 
		distance because this rotation formula gives us a result with the origin based 
		in the bottom left corner (of the (+, +) quadrant).  
		The actual code is a simplification of the above.  
		]]
		local dx, dy = xDist, yDist
		xDist = (dx * cosTheta) - (dy * sinTheta)
		yDist = (dx * sinTheta) + (dy * cosTheta)
	end
	
	if ( minimapShape and not (xDist == 0 or yDist == 0) ) then
		isRound = (xDist < 0) and 1 or 3;
		if ( yDist < 0 ) then
			isRound = minimapShape[isRound];
		else
			isRound = minimapShape[isRound + 1];
		end
	end
	
	-- for non-circular portions of the Minimap edge
	if not ( isRound ) then
		dist = max(abs(xDist), abs(yDist))
	end

	if ( (dist + iconDiameter) > mapRadius ) then
		-- position along the outside of the Minimap
		iconOnEdge = true;
		local factor = (mapRadius - iconDiameter) / dist;
		xDist = xDist * factor;
		yDist = yDist * factor;
	end
	
	if ( Astrolabe.IconsOnEdge[icon] ~= iconOnEdge ) then
		Astrolabe.IconsOnEdge[icon] = iconOnEdge;
		Astrolabe.IconsOnEdgeChanged = true;
	end
	
	icon:ClearAllPoints();
	icon:SetPoint("CENTER", minimap, "CENTER", xDist/xScale, -yDist/yScale);
end

function Astrolabe:PlaceIconOnMinimap( icon, continent, zone, xPos, yPos )
	-- check argument types
	argcheck(icon, 2, "table");
	assert(3, icon.SetPoint and icon.ClearAllPoints, "Usage Message");
	argcheck(continent, 3, "number");
	argcheck(zone, 4, "number", "nil");
	argcheck(xPos, 5, "number");
	argcheck(yPos, 6, "number");
	
	local lC, lZ, lx, ly = unpack(self.LastPlayerPosition);
	local dist, xDist, yDist = self:ComputeDistance(lC, lZ, lx, ly, continent, zone, xPos, yPos);
	if not ( dist ) then
		--icon's position has no meaningful position relative to the player's current location
		return -1;
	end
	
	local iconData = GetWorkingTable(icon);
	if ( self.MinimapIcons[icon] ) then
		self.MinimapIcons[icon] = nil;
	else
		self.MinimapIconCount = self.MinimapIconCount + 1
	end
	
	-- We know this icon's position is valid, so we need to make sure the icon placement 
	-- system is active.  We call this here so that if this is the first icon being added to 
	-- an empty buffer, the full recalc will not completely redo the work done by this function 
	-- because the icon has not yet actually been placed in the buffer.  
	self.processingFrame:Show()
	
	AddedOrUpdatedIcons[icon] = iconData
	iconData.continent = continent;
	iconData.zone = zone;
	iconData.xPos = xPos;
	iconData.yPos = yPos;
	iconData.dist = dist;
	iconData.xDist = xDist;
	iconData.yDist = yDist;
	
	minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
	if ( minimapRotationEnabled ) then
		minimapRotationOffset = -MinimapCompassRing:GetFacing()
	end
	
	-- check Minimap Shape
	minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
	
	-- place the icon on the Minimap and :Show() it
	local map = Minimap
	placeIconOnMinimap(map, map:GetZoom(), map:GetWidth(), map:GetHeight(), icon, dist, xDist, yDist);
	icon:Show()
	
	return 0;
end

function Astrolabe:RemoveIconFromMinimap( icon )
	if not ( self.MinimapIcons[icon] ) then
		return 1;
	end
	AddedOrUpdatedIcons[icon] = nil
	self.MinimapIcons[icon] = nil;
	self.IconsOnEdge[icon] = nil;
	icon:Hide();
	
	local MinimapIconCount = self.MinimapIconCount - 1
	if ( MinimapIconCount <= 0 ) then
		-- no icons left to manage
		self.processingFrame:Hide()
		MinimapIconCount = 0 -- because I'm paranoid
	end
	self.MinimapIconCount = MinimapIconCount
	
	return 0;
end

function Astrolabe:RemoveAllMinimapIcons()
	self:DumpNewIconsCache()
	local MinimapIcons = self.MinimapIcons;
	local IconsOnEdge = self.IconsOnEdge;
	for k, v in pairs(MinimapIcons) do
		MinimapIcons[k] = nil;
		IconsOnEdge[k] = nil;
		k:Hide();
	end
	self.MinimapIconCount = 0
	self.processingFrame:Hide()
end

local lastZoom; -- to remember the last seen Minimap zoom level

-- local variables to track the status of the two update coroutines
local fullUpdateInProgress = true
local resetIncrementalUpdate = false
local resetFullUpdate = false

-- Incremental Update Code
do
	-- local variables to track the incremental update coroutine
	local incrementalUpdateCrashed = true
	local incrementalUpdateThread
	
	local function UpdateMinimapIconPositions( self )
		yield()
		
		while ( true ) do
			self:DumpNewIconsCache() -- put new/updated icons into the main datacache
			
			resetIncrementalUpdate = false -- by definition, the incremental update is reset if it is here
			
			local C, Z, x, y = self:GetCurrentPlayerPosition();
			if ( C and C >= 0 ) then
				local Minimap = Minimap;
				local lastPosition = self.LastPlayerPosition;
				local lC, lZ, lx, ly = unpack(lastPosition);
				
				minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
				if ( minimapRotationEnabled ) then
					minimapRotationOffset = -MinimapCompassRing:GetFacing()
				end
				
				-- check current frame rate
				local numPerCycle = min(50, GetFramerate() * (self.MinimapUpdateMultiplier or 1))
				
				-- check Minimap Shape
				minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
				
				if ( lC == C and lZ == Z and lx == x and ly == y ) then
					-- player has not moved since the last update
					if ( lastZoom ~= Minimap:GetZoom() or self.ForceNextUpdate or minimapRotationEnabled ) then
						local currentZoom = Minimap:GetZoom();
						lastZoom = currentZoom;
						local mapWidth = Minimap:GetWidth();
						local mapHeight = Minimap:GetHeight();
						numPerCycle = numPerCycle * 2
						local count = 0
						for icon, data in pairs(self.MinimapIcons) do
							placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, data.dist, data.xDist, data.yDist);
							
							count = count + 1
							if ( count > numPerCycle ) then
								count = 0
								yield()
								-- check if the incremental update cycle needs to be reset 
								-- because a full update has been run
								if ( resetIncrementalUpdate ) then
									break;
								end
							end
						end
						self.ForceNextUpdate = false;
					end
				else
					local dist, xDelta, yDelta = self:ComputeDistance(lC, lZ, lx, ly, C, Z, x, y);
					if ( dist ) then
						local currentZoom = Minimap:GetZoom();
						lastZoom = currentZoom;
						local mapWidth = Minimap:GetWidth();
						local mapHeight = Minimap:GetHeight();
						local count = 0
						for icon, data in pairs(self.MinimapIcons) do
							local xDist = data.xDist - xDelta;
							local yDist = data.yDist - yDelta;
							local dist = sqrt(xDist*xDist + yDist*yDist);
							placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, dist, xDist, yDist);
							
							data.dist = dist;
							data.xDist = xDist;
							data.yDist = yDist;
							
							count = count + 1
							if ( count >= numPerCycle ) then
								count = 0
								yield()
								-- check if the incremental update cycle needs to be reset 
								-- because a full update has been run
								if ( resetIncrementalUpdate ) then
									break;
								end
							end
						end
						if not ( resetIncrementalUpdate ) then
							lastPosition[1] = C;
							lastPosition[2] = Z;
							lastPosition[3] = x;
							lastPosition[4] = y;
						end
					else
						self:RemoveAllMinimapIcons()
						lastPosition[1] = C;
						lastPosition[2] = Z;
						lastPosition[3] = x;
						lastPosition[4] = y;
					end
				end
			else
				if not ( self.WorldMapVisible ) then
					self.processingFrame:Hide();
				end
			end
			
			-- if we've been reset, then we want to start the new cycle immediately
			if not ( resetIncrementalUpdate ) then
				yield()
			end
		end
	end
	
	function Astrolabe:UpdateMinimapIconPositions()
		if ( fullUpdateInProgress ) then
			-- if we're in the middle a a full update, we want to finish that first
			self:CalculateMinimapIconPositions()
		else
			if ( incrementalUpdateCrashed ) then
				incrementalUpdateThread = coroutine.wrap(UpdateMinimapIconPositions)
				incrementalUpdateThread(self) --initialize the thread
			end
			incrementalUpdateCrashed = true
			incrementalUpdateThread()
			incrementalUpdateCrashed = false
		end
	end
end

-- Full Update Code
do
	-- local variables to track the full update coroutine
	local fullUpdateCrashed = true
	local fullUpdateThread
	
	local function CalculateMinimapIconPositions( self )
		yield()
		
		while ( true ) do
			self:DumpNewIconsCache() -- put new/updated icons into the main datacache
			
			resetFullUpdate = false -- by definition, the full update is reset if it is here
			fullUpdateInProgress = true -- set the flag the says a full update is in progress
			
			local C, Z, x, y = self:GetCurrentPlayerPosition();
			if ( C and C >= 0 ) then
				minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
				if ( minimapRotationEnabled ) then
					minimapRotationOffset = -MinimapCompassRing:GetFacing()
				end
				
				-- check current frame rate
				local numPerCycle = GetFramerate() * (self.MinimapUpdateMultiplier or 1) * 2
				
				-- check Minimap Shape
				minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
				
				local currentZoom = Minimap:GetZoom();
				lastZoom = currentZoom;
				local Minimap = Minimap;
				local mapWidth = Minimap:GetWidth();
				local mapHeight = Minimap:GetHeight();
				local count = 0
				for icon, data in pairs(self.MinimapIcons) do
					local dist, xDist, yDist = self:ComputeDistance(C, Z, x, y, data.continent, data.zone, data.xPos, data.yPos);
					if ( dist ) then
						placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, dist, xDist, yDist);
						
						data.dist = dist;
						data.xDist = xDist;
						data.yDist = yDist;
					else
						self:RemoveIconFromMinimap(icon)
					end
					
					count = count + 1
					if ( count >= numPerCycle ) then
						count = 0
						yield()
						-- check if we need to restart due to the full update being reset
						if ( resetFullUpdate ) then
							break;
						end
					end
				end
				
				if not ( resetFullUpdate ) then
					local lastPosition = self.LastPlayerPosition;
					lastPosition[1] = C;
					lastPosition[2] = Z;
					lastPosition[3] = x;
					lastPosition[4] = y;
					
					resetIncrementalUpdate = true
				end
			else
				if not ( self.WorldMapVisible ) then
					self.processingFrame:Hide();
				end
			end
			
			-- if we've been reset, then we want to start the new cycle immediately
			if not ( resetFullUpdate ) then
				fullUpdateInProgress = false
				yield()
			end
		end
	end
	
	function Astrolabe:CalculateMinimapIconPositions( reset )
		if ( fullUpdateCrashed ) then
			fullUpdateThread = coroutine.wrap(CalculateMinimapIconPositions)
			fullUpdateThread(self) --initialize the thread
		elseif ( reset ) then
			resetFullUpdate = true
		end
		fullUpdateCrashed = true
		fullUpdateThread()
		fullUpdateCrashed = false
		
		-- return result flag
		if ( fullUpdateInProgress ) then
			return 1 -- full update started, but did not complete on this cycle
		
		else
			if ( resetIncrementalUpdate ) then
				return 0 -- update completed
			else
				return -1 -- full update did no occur for some reason
			end
		
		end
	end
end

function Astrolabe:GetDistanceToIcon( icon )
	local data = self.MinimapIcons[icon];
	if ( data ) then
		return data.dist, data.xDist, data.yDist;
	end
end

function Astrolabe:IsIconOnEdge( icon )
	return self.IconsOnEdge[icon];
end

function Astrolabe:GetDirectionToIcon( icon )
	local data = self.MinimapIcons[icon];
	if ( data ) then
		local dir = atan2(data.xDist, -(data.yDist))
		if ( dir > 0 ) then
			return twoPi - dir;
		else
			return -dir;
		end
	end
end

function Astrolabe:Register_OnEdgeChanged_Callback( func, ident )
	-- check argument types
	argcheck(func, 2, "function");
	
	self.IconsOnEdge_GroupChangeCallbacks[func] = ident;
end

--*****************************************************************************
-- INTERNAL USE ONLY PLEASE!!!
-- Calling this function at the wrong time can cause errors
--*****************************************************************************
function Astrolabe:DumpNewIconsCache()
	local MinimapIcons = self.MinimapIcons
	for icon, data in pairs(AddedOrUpdatedIcons) do
		MinimapIcons[icon] = data
		AddedOrUpdatedIcons[icon] = nil
	end
	-- we now need to restart any updates that were in progress
	resetIncrementalUpdate = true
	resetFullUpdate = true
end


--------------------------------------------------------------------------------------------------------------
-- World Map Icon Placement
--------------------------------------------------------------------------------------------------------------

function Astrolabe:PlaceIconOnWorldMap( worldMapFrame, icon, continent, zone, xPos, yPos )
	-- check argument types
	argcheck(worldMapFrame, 2, "table");
	assert(3, worldMapFrame.GetWidth and worldMapFrame.GetHeight, "Usage Message");
	argcheck(icon, 3, "table");
	assert(3, icon.SetPoint and icon.ClearAllPoints, "Usage Message");
	argcheck(continent, 4, "number");
	argcheck(zone, 5, "number", "nil");
	argcheck(xPos, 6, "number");
	argcheck(yPos, 7, "number");
	
	local C, Z = GetCurrentMapContinent(), GetCurrentMapZone();
	local nX, nY = self:TranslateWorldMapPosition(continent, zone, xPos, yPos, C, Z);
	
	-- anchor and :Show() the icon if it is within the boundry of the current map, :Hide() it otherwise
	if ( nX and nY and (0 < nX and nX <= 1) and (0 < nY and nY <= 1) ) then
		icon:ClearAllPoints();
		icon:SetPoint("CENTER", worldMapFrame, "TOPLEFT", nX * worldMapFrame:GetWidth(), -nY * worldMapFrame:GetHeight());
		icon:Show();
	else
		icon:Hide();
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
			self:CalculateMinimapIconPositions(true);
		end
	
	elseif ( event == "PLAYER_LEAVING_WORLD" ) then
		frame:Hide(); -- yes, I know this is redunant
		self:RemoveAllMinimapIcons(); --dump all minimap icons
	
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		frame:Show();
		if not ( frame:IsVisible() ) then
			-- do the minimap recalculation anyways if the OnShow script didn't execute
			-- this is done to ensure the accuracy of information about icons that were 
			-- inserted while the Player was in the process of zoning
			self:CalculateMinimapIconPositions(true);
		end
	
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		frame:Hide();
		frame:Show();
	
	end
end

function Astrolabe:OnUpdate( frame, elapsed )
	-- on-edge group changed call-backs
	if ( self.IconsOnEdgeChanged ) then
		self.IconsOnEdgeChanged = false;
		for func in pairs(self.IconsOnEdge_GroupChangeCallbacks) do
			pcall(func);
		end
	end
	
	self:UpdateMinimapIconPositions();
end

function Astrolabe:OnShow( frame )
	-- set the world map to a zoom with a valid player position
	if not ( self.WorldMapVisible ) then
		SetMapToCurrentZone();
	end
	local C, Z = Astrolabe:GetCurrentPlayerPosition();
	if ( C and C >= 0 ) then
		SetMapZoom(C, Z);
	else
		frame:Hide();
		return
	end
	
	-- re-calculate minimap icon positions
	self:CalculateMinimapIconPositions(true);
	
	if ( self.MinimapIconCount <= 0 ) then
		-- no icons left to manage
		self.processingFrame:Hide()
	end
end

-- called by AstrolabMapMonitor when all world maps are hidden
function Astrolabe:AllWorldMapsHidden()
	if ( IsLoggedIn() ) then
		self.processingFrame:Hide();
		self.processingFrame:Show();
	end
end


--------------------------------------------------------------------------------------------------------------
-- Library Registration
--------------------------------------------------------------------------------------------------------------

local function activate( newInstance, oldInstance )
	if ( oldInstance ) then -- this is an upgrade activate
		if ( oldInstance.DumpNewIconsCache ) then
			oldInstance:DumpNewIconsCache()
		end
		for k, v in pairs(oldInstance) do
			if ( type(v) ~= "function" and (not configConstants[k]) ) then
				newInstance[k] = v;
			end
		end
		-- sync up the current MinimapIconCount value
		local iconCount = 0
		for _ in pairs(newInstance.MinimapIcons) do
			iconCount = iconCount + 1
		end
		newInstance.MinimapIconCount = iconCount
		
		Astrolabe = oldInstance;
	else
		local frame = CreateFrame("Frame");
		newInstance.processingFrame = frame;
		
		newInstance.ContinentList = { GetMapContinents() };
		for C in pairs(newInstance.ContinentList) do
			local zones = { GetMapZones(C) };
			newInstance.ContinentList[C] = zones;
			for Z in ipairs(zones) do
				SetMapZoom(C, Z);
				zones[Z] = GetMapInfo();
			end
		end
	end
	configConstants = nil -- we don't need this anymore
	
	local frame = newInstance.processingFrame;
	frame:Hide();
	frame:SetParent("Minimap");
	frame:UnregisterAllEvents();
	frame:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	frame:RegisterEvent("PLAYER_LEAVING_WORLD");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	frame:SetScript("OnEvent",
		function( frame, event, ... )
			Astrolabe:OnEvent(frame, event, ...);
		end
	);
	frame:SetScript("OnUpdate",
		function( frame, elapsed )
			Astrolabe:OnUpdate(frame, elapsed);
		end
	);
	frame:SetScript("OnShow",
		function( frame )
			Astrolabe:OnShow(frame);
		end
	);
	
	setmetatable(Astrolabe.MinimapIcons, MinimapIconsMetatable)
end

DongleStub:Register(Astrolabe, activate)


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

ValidMinimapShapes = {
	-- { upper-left, lower-left, upper-right, lower-right }
	["SQUARE"]                = { false, false, false, false },
	["CORNER-TOPLEFT"]        = { true,  false, false, false },
	["CORNER-TOPRIGHT"]       = { false, false, true,  false },
	["CORNER-BOTTOMLEFT"]     = { false, true,  false, false },
	["CORNER-BOTTOMRIGHT"]    = { false, false, false, true },
	["SIDE-LEFT"]             = { true,  true,  false, false },
	["SIDE-RIGHT"]            = { false, false, true,  true },
	["SIDE-TOP"]              = { true,  false, true,  false },
	["SIDE-BOTTOM"]           = { false, true,  false, true },
	["TRICORNER-TOPLEFT"]     = { true,  true,  true,  false },
	["TRICORNER-TOPRIGHT"]    = { true,  false, true,  true },
	["TRICORNER-BOTTOMLEFT"]  = { true,  true,  false, true },
	["TRICORNER-BOTTOMRIGHT"] = { false, true,  true,  true },
}

-- distances across and offsets of the world maps
-- in game yards
WorldMapSize = {
	-- World Map of Azeroth
	[0] = {
		parentContinent = 0,
		height = 29688.932932224,
		width = 44537.340058402,
	},
	-- Kalimdor
	{ -- [1]
		parentContinent = 0,
		height = 24533.025279205,
		width = 36800.210572494,
		xOffset = -8311.793923510446,
		yOffset = 1815.215685280706,
		zoneData = {
			Ashenvale = {
				height = 3843.722811451077,
				width = 5766.728884700476,
				xOffset = 15366.76755576002,
				yOffset = 8126.925260781192,
			},
			Aszhara = {
				height = 3381.225696279877,
				width = 5070.888165752819,
				xOffset = 20343.90485013144,
				yOffset = 7458.180046130774,
			},
			AzuremystIsle = {
				height = 2714.561862167815,
				width = 4070.883253576282,
				xOffset = 9966.70736478994,
				yOffset = 5460.278138661794,
			},
			Barrens = {
				height = 6756.202067150937,
				width = 10133.44343943073,
				xOffset = 14443.84117394525,
				yOffset = 11187.32013604393,
			},
			BloodmystIsle = {
				height = 2174.984710698752,
				width = 3262.517428121028,
				xOffset = 9541.713418184554,
				yOffset = 3424.874558234072,
			},
			Darkshore = {
				height = 4366.636219106706,
				width = 6550.06962983463,
				xOffset = 14125.08809600818,
				yOffset = 4466.534412478246,
			},
			Darnassis = {
				height = 705.7248633938184,
				width = 1058.342927027606,
				xOffset = 14128.39258617903,
				yOffset = 2561.565012455802,
			},
			Desolace = {
				height = 2997.895174253872,
				width = 4495.882023201739,
				xOffset = 12833.40729836031,
				yOffset = 12347.72848626745,
			},
			Durotar = {
				height = 3524.975114832228,
				width = 5287.558038649864,
				xOffset = 19029.30699887344,
				yOffset = 10991.48801260963,
			},
			Dustwallow = {
				height = 3499.975146240067,
				width = 5250.057259791282,
				xOffset = 18041.79657043901,
				yOffset = 14833.12751666842,
			},
			Felwood = {
				height = 3833.305958270781,
				width = 5750.062034325837,
				xOffset = 15425.10163773161,
				yOffset = 5666.526367166872,
			},
			Feralas = {
				height = 4633.30011661694,
				width = 6950.075260353015,
				xOffset = 11625.06045254075,
				yOffset = 15166.45834829251,
			},
			Moonglade = {
				height = 1539.572509508711,
				width = 2308.356845256911,
				xOffset = 18448.05172159372,
				yOffset = 4308.20254319874,
			},
			Mulgore = {
				height = 3424.975945100366,
				width = 5137.555355060729,
				xOffset = 15018.84750987729,
				yOffset = 13072.72336630089,
			},
			Ogrimmar = {
				height = 935.4100697456119,
				width = 1402.621211455915,
				xOffset = 20747.42666130799,
				yOffset = 10525.94769396873,
			},
			Silithus = {
				height = 2322.899061688691,
				width = 3483.371975265956,
				xOffset = 14529.25864164056,
				yOffset = 18758.10068625832,
			},
			StonetalonMountains = {
				height = 3256.226691571251,
				width = 4883.385977951072,
				xOffset = 13820.91773479217,
				yOffset = 9883.162892509636,
			},
			Tanaris = {
				height = 4599.965662459992,
				width = 6900.073766103516,
				xOffset = 17285.539010128,
				yOffset = 18674.7673661939,
			},
			Teldrassil = {
				height = 3393.726923234355,
				width = 5091.720903621394,
				xOffset = 13252.16205313556,
				yOffset = 968.6418744503761,
			},
			TheExodar = {
				height = 704.6826864472878,
				width = 1056.781131437323,
				xOffset = 10533.08314172693,
				yOffset = 6276.205331713322,
			},
			ThousandNeedles = {
				height = 2933.312180524323,
				width = 4400.046681282484,
				xOffset = 17500.12437633161,
				yOffset = 16766.44698282704,
			},
			ThunderBluff = {
				height = 695.8282721105132,
				width = 1043.761263579803,
				xOffset = 16550.11410485969,
				yOffset = 13649.80260929285,
			},
			UngoroCrater = {
				height = 2466.647220780505,
				width = 3700.040077455555,
				xOffset = 16533.44712326324,
				yOffset = 18766.4334494793,
			},
			Winterspring = {
				height = 4733.299561046713,
				width = 7100.077599808275,
				xOffset = 17383.45606038691,
				yOffset = 4266.536453420381,
			},
		},
	},
	-- Eastern Kingdoms
	{ -- [2]
		parentContinent = 0,
		height = 27149.795290881,
		width = 40741.175327834,
		xOffset = 14407.1086092051,
		yOffset = 290.3230897653046,
		zoneData = {
			Alterac = {
				height = 1866.673586850316,
				width = 2800.000436369314,
				xOffset = 17388.63313899802,
				yOffset = 9676.382605411302,
			},
			Arathi = {
				height = 2400.0092446309,
				width = 3599.999380663208,
				xOffset = 19038.63328411639,
				yOffset = 11309.72201070757,
			},
			Badlands = {
				height = 1658.340965090961,
				width = 2487.498490907989,
				xOffset = 20251.1337564772,
				yOffset = 17065.99404487956,
			},
			BlastedLands = {
				height = 2233.343415116865,
				width = 3349.999381676505,
				xOffset = 19413.63362865575,
				yOffset = 21743.09582955139,
			},
			BurningSteppes = {
				height = 1952.091972408385,
				width = 2929.16694293186,
				xOffset = 18438.633261567,
				yOffset = 18207.66513379744,
			},
			DeadwindPass = {
				height = 1666.673818905317,
				width = 2499.999888210889,
				xOffset = 19005.29993968603,
				yOffset = 21043.0932328648,
			},
			DunMorogh = {
				height = 3283.345779814337,
				width = 4924.998791911572,
				xOffset = 16369.8840376619,
				yOffset = 15053.48695195484,
			},
			Duskwood = {
				height = 1800.007653419076,
				width = 2699.999669551933,
				xOffset = 17338.63354148773,
				yOffset = 20893.09259181909,
			},
			EasternPlaguelands = {
				height = 2581.259876367526,
				width = 3870.832396995169,
				xOffset = 20357.38356562001,
				yOffset = 7376.373692430854,
			},
			Elwynn = {
				height = 2314.591970284716,
				width = 3470.831971412848,
				xOffset = 16636.55099386465,
				yOffset = 19116.0027890283,
			},
			EversongWoods = {
				height = 3283.346366715794,
				width = 4924.998483501337,
				xOffset = 20259.46725884782,
				yOffset = 2534.687567863296,
			},
			Ghostlands = {
				height = 2200.008945183733,
				width = 3300.002855743766,
				xOffset = 21055.29786070095,
				yOffset = 5309.698546426793,
			},
			Hilsbrad = {
				height = 2133.341840477916,
				width = 3200.000391416799,
				xOffset = 17105.29968281043,
				yOffset = 10776.38652289269,
			},
			Hinterlands = {
				height = 2566.676323518885,
				width = 3849.998492380244,
				xOffset = 19746.96704279287,
				yOffset = 9709.715966757984,
			},
			Ironforge = {
				height = 527.6056771582851,
				width = 790.6252518322632,
				xOffset = 18885.55815177769,
				yOffset = 15745.64795436116,
			},
			LochModan = {
				height = 1839.590356444166,
				width = 2758.33360594204,
				xOffset = 20165.71623436714,
				yOffset = 15663.90573348468,
			},
			Redridge = {
				height = 1447.922213393415,
				width = 2170.833229570681,
				xOffset = 19742.79960560691,
				yOffset = 19751.42209395218,
			},
			SearingGorge = {
				height = 1487.505203229038,
				width = 2231.250200533406,
				xOffset = 18494.88325409831,
				yOffset = 17276.41231120941,
			},
			SilvermoonCity = {
				height = 806.7751969249011,
				width = 1211.458551923779,
				xOffset = 22172.71573747824,
				yOffset = 3422.647395021269,
			},
			Silverpine = {
				height = 2800.011187621704,
				width = 4200.000573479695,
				xOffset = 14721.96646274185,
				yOffset = 9509.714741967448,
			},
			Stormwind = {
				height = 896.3598437319051,
				width = 1344.270269919159,
				xOffset = 16790.9956264139,
				yOffset = 19455.27053790398,
			},
			Stranglethorn = {
				height = 4254.18312444072,
				width = 6381.248484543122,
				xOffset = 15951.13375783437,
				yOffset = 22345.18258706305,
			},
			Sunwell = {
				height = 2218.756638064149,
				width = 3327.084777999942,
				xOffset = 21074.0484502027,
				yOffset = 7.595267688679496,
			},
			SwampOfSorrows = {
				height = 1529.173695058727,
				width = 2293.753807610138,
				xOffset = 20394.88183258176,
				yOffset = 20797.25913588854,
			},
			Tirisfal = {
				height = 3012.510490816506,
				width = 4518.749381850256,
				xOffset = 15138.63417865412,
				yOffset = 7338.874503644808,
			},
			Undercity = {
				height = 640.1067253394195,
				width = 959.3752013853186,
				xOffset = 17298.77399735696,
				yOffset = 9298.435338905521,
			},
			WesternPlaguelands = {
				height = 2866.677213191588,
				width = 4299.998717025251,
				xOffset = 17755.30067544475,
				yOffset = 7809.708745090687,
			},
			Westfall = {
				height = 2333.342039971409,
				width = 3500.001170481545,
				xOffset = 15155.29922254704,
				yOffset = 20576.42557120998,
			},
			Wetlands = {
				height = 2756.260286844545,
				width = 4135.414389381328,
				xOffset = 18561.55091405621,
				yOffset = 13324.31339403164,
			},
		},
	},
	-- Outland
	{ -- [3]
		parentContinent = 3,
		height = 11642.355227091,
		width = 17463.987300595,
		zoneData = {
			BladesEdgeMountains = {
				height = 3616.553511321226,
				width = 5424.972055480694,
				xOffset = 4150.184214583454,
				yOffset = 1412.98225932006,
			},
			Hellfire = {
				height = 3443.642450656037,
				width = 5164.556104714847,
				xOffset = 7456.417230912641,
				yOffset = 4339.973750274888,
			},
			Nagrand = {
				height = 3683.218538167106,
				width = 5524.971495006054,
				xOffset = 2700.192018521809,
				yOffset = 5779.511974812862,
			},
			Netherstorm = {
				height = 3716.550608724641,
				width = 5574.970083688359,
				xOffset = 7512.667416095402,
				yOffset = 365.0979827402549,
			},
			ShadowmoonValley = {
				height = 3666.552070430093,
				width = 5499.971770418525,
				xOffset = 8770.993458280615,
				yOffset = 7769.033264592288,
			},
			ShattrathCity = {
				height = 870.8059516186869,
				width = 1306.242821388422,
				xOffset = 6860.744740098593,
				yOffset = 7295.086120456203,
			},
			TerokkarForest = {
				height = 3599.887783533737,
				width = 5399.971351016305,
				xOffset = 5912.675516998205,
				yOffset = 6821.146319031154,
			},
			Zangarmarsh = {
				height = 3351.978710181591,
				width = 5027.057650868489,
				xOffset = 3521.020638264577,
				yOffset = 3885.821278366336,
			},
		},
	},
}

local zeroData;
zeroData = { xOffset = 0, height = 0, yOffset = 0, width = 0, __index = function() return zeroData end };
setmetatable(zeroData, zeroData);
setmetatable(WorldMapSize, zeroData);

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


-- register this library with AstrolabeMapMonitor, this will cause a full update if PLAYER_LOGIN has already fired
local AstrolabeMapMonitor = DongleStub("AstrolabeMapMonitor");
AstrolabeMapMonitor:RegisterAstrolabeLibrary(Astrolabe, LIBRARY_VERSION_MAJOR);
