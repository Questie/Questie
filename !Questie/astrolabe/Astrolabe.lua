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
WorldMapSize, MinimapSize = {}, {}
local initSizes
--------------------------------------------------------------------------------------------------------------
-- Working Tables and Config Constants
--------------------------------------------------------------------------------------------------------------
Astrolabe.LastPlayerPosition = {};
Astrolabe.MinimapIcons = {};
Astrolabe.MinimapUpdateTime = 0.1;
Astrolabe.UpdateTimer = 0;
Astrolabe.ForceNextUpdate = false;
Astrolabe.minimapOutside = false;
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
        if ( nZ ~= 0) then
            zoneData = WorldMapSize[C][nZ];
            xPos = xPos - zoneData.xOffset;
            yPos = yPos - zoneData.yOffset;
        end
    elseif (C and nC) and (WorldMapSize[C].parentContinent == WorldMapSize[nC].parentContinent) then
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
            if ( nZ ~= 0 and zoneData[nZ] ~= nil) then
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
    local x, y = GetPlayerMapPosition("player")
    if (x <= 0 and y <= 0) then
        if (not WorldMapFrame:IsVisible() == nil) then
            return
        else
            return Astrolabe_LastC, Astrolabe_LastZ, Astrolabe_LastX, Astrolabe_LastY
        end
		      if (WorldMapFrame:IsVisible() == nil) then
            SetMapToCurrentZone()
			         x, y = GetPlayerMapPosition("player")
			         if (x <= 0 and y <= 0) then
				            SetMapZoom(GetCurrentMapContinent())
				            x, y = GetPlayerMapPosition("player")
				            if (x <= 0 and y <= 0) then
                    return;
				            end
			         end
		      else
            return Astrolabe_LastC, Astrolabe_LastZ, Astrolabe_LastX, Astrolabe_LastY
		      end
	   end
    local C, Z = GetCurrentMapContinent(), GetCurrentMapZone()
    local playerCont, playerZone = C, Z
    if (playerZone == 0) then
        playerZone = Astrolabe_LastZ
	   end
	   if (playerCont == 0) then
		      playerCont = Astrolabe_LastC
	   end
	   if (not WorldMapSize[playerCont]) then
		      playerCont, playerZone = 0, 0
	   end
	   if (playerCont > 0 and not WorldMapSize[playerCont][playerZone]) then
		      playerZone = 0
	   end
	   local nX, nY = self:TranslateWorldMapPosition(C, Z, x, y, playerCont, playerZone)
	   Astrolabe_LastX = nX
	   Astrolabe_LastY = nY
	   Astrolabe_LastC = playerCont
	   Astrolabe_LastZ = playerZone
	   return Astrolabe_LastC, Astrolabe_LastZ, Astrolabe_LastX, Astrolabe_LastY;
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
    if (not lC) or (not lZ) or (not lx) or (not ly) then
      self.LastPlayerPosition = {};
      self.LastPlayerPosition[1], self.LastPlayerPosition[2], self.LastPlayerPosition[3], self.LastPlayerPosition[4] = Astrolabe:GetCurrentPlayerPosition();
      lC, lZ, lx, ly = unpack(self.LastPlayerPosition);
    end
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

function Astrolabe:isMinimapInCity()
    local tempzoom = 0;
    self.minimapOutside = true;
    if (GetCVar("minimapZoom") == GetCVar("minimapInsideZoom")) then
        if (GetCVar("minimapInsideZoom")+0 >= 3) then
            Minimap:SetZoom(Minimap:GetZoom() - 1);
            tempzoom = 1;
        else
            Minimap:SetZoom(Minimap:GetZoom() + 1);
            tempzoom = -1;
        end
    end
    if (GetCVar("minimapInsideZoom")+0 == Minimap:GetZoom()) then self.minimapOutside = false; end
    Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
end

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
    local iconDiameter = ((icon:GetWidth() / 2) -3) * xScale; -- LaYt +3
    icon:ClearAllPoints();
    local signx,signy =1,1;
    -- Adding square map support by LaYt
    if (Squeenix or (simpleMinimap_Skins and simpleMinimap_Skins:GetShape() == "square")) then
        if (xDist<0) then signx=-1; end
        if (yDist<0) then signy=-1; end
        if (math.abs(xDist) > (mapWidth/2*xScale)) then
            xDist = (mapWidth/2*xScale - iconDiameter/2)*signx;
        end
        if (math.abs(yDist) > (mapHeight/2*yScale)) then
            yDist = (mapHeight/2*yScale - iconDiameter/2)*signy;
        end
    elseif ( (dist + iconDiameter) > mapRadius ) then
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
    local currentZoom = Minimap:GetZoom();
	   local zoomChanged = lastZoom ~= Minimap:GetZoom()
	   lastZoom = currentZoom;
	   if zoomChanged then
		      Astrolabe.MinimapUpdateTime = (6 - Minimap:GetZoom()) * 0.05
	   end
    if ( (lC == C and lZ == Z and lx == x and ly == y)) then
		      -- player has not moved since the last update
		      if (zoomChanged or self.ForceNextUpdate ) then
			         local mapWidth = Minimap:GetWidth();
			         local mapHeight = Minimap:GetHeight();
			         for icon, data in pairs(self.MinimapIcons) do
				            placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, data.dist, data.xDist, data.yDist);
			         end
			         self.ForceNextUpdate = false;
        end
    else
      local dist, xDelta, yDelta = self:ComputeDistance(lC, lZ, lx, ly, C, Z, x, y);
      if not dist or not xDelta or not yDelta then return; end
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
        Astrolabe:isMinimapInCity()
        -- re-calculate all Minimap Icon positions
        if ( frame:IsVisible() ) then
            self:CalculateMinimapIconPositions();
        end
    elseif ( event == "PLAYER_LEAVING_WORLD" ) then
        frame:Hide();
        self:RemoveAllMinimapIcons(); --dump all minimap icons
    elseif ( event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" ) then
        Astrolabe:isMinimapInCity()
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
    frame:SetScript("OnEvent", function()
            self:OnEvent(this, event);
        end
    );
    frame:SetScript("OnUpdate",
        function( frame, elapsed )
            self:OnUpdate(frame, 1/GetFramerate());
        end
    );
    frame:SetScript("OnShow",
        function( frame )
            self:OnShow(frame);
        end
    );
    if not ( self.ContinentList ) then
        self.ContinentList = { GetMapContinents() };
        for C in pairs(self.ContinentList) do
            local zones = { GetMapZones(C) };
            self.ContinentList[C] = zones;
            for Z in ipairs(zones) do
                SetMapZoom(C, Z);
                zones[Z] = {mapFile = GetMapInfo(), mapName = N}
            end
        end
    end
    initSizes()
    frame:Show();
end
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
-- from classic client data, except for values commented on
local initDone = false
function initSizes()
    if initDone then return end
    initDone = true
    WorldMapSize = {
        -- World Map of Azeroth
        [0] = {
            parentContinent = 0,
            height = 29687.90575403711, -- as in Questie
            width = 44531.82907938571, -- as in Questie
        },
        -- Kalimdor
        [1] = {
            parentContinent = 0,
            height = 24533.2001953125,
            width = 36799.810546875,
            xOffset = -8310.0, -- as in Questie
            yOffset = 1815.0, -- as in Questie
            zoneData = {
                Ashenvale = {
                    height = 3843.749877929687,
                    width = 5766.66638183594,
                    xOffset = 15366.59973144531,
                    yOffset = 8126.98388671875,
                },
                Aszhara = {
                    height = 3381.2498779296902,
                    width = 5070.8327636718695,
                    xOffset = 20343.68286132813,
                    yOffset = 7458.23388671875,
                },
                Barrens = {
                    height = 6756.24987792969,
                    width = 10133.3330078125,
                    xOffset = 14443.68310546875,
                    yOffset = 11187.40051269531,
                },
                Darkshore = {
                    height = 4366.66650390625,
                    width = 6549.9997558593805,
                    xOffset = 14124.93310546875,
                    yOffset = 4466.5673828125,
                },
                Darnassis = {
                    height = 705.7294921875,
                    width = 1058.33325195312,
                    xOffset = 14128.23681640625,
                    yOffset = 2561.583984375,
                },
                Desolace = {
                    height = 2997.916564941411,
                    width = 4495.8330078125,
                    xOffset = 12833.2666015625,
                    yOffset = 12347.817077636719,
                },
                Durotar = {
                    height = 3524.9998779296902,
                    width = 5287.49963378906,
                    xOffset = 19029.09948730469,
                    yOffset = 10991.56713867187,
                },
                Dustwallow = {
                    height = 3499.99975585937,
                    width = 5250.000061035156,
                    xOffset = 18041.599548339844,
                    yOffset = 14833.23364257813,
                },
                Felwood = {
                    height = 3833.33325195312,
                    width = 5749.99963378906,
                    xOffset = 15424.93298339844,
                    yOffset = 5666.5673828125,
                },
                Feralas = {
                    height = 4633.3330078125,
                    width = 6949.9997558593805,
                    xOffset = 11624.93310546875,
                    yOffset = 15166.56689453125,
                },
                Moonglade = {
                    height = 1539.5830078125,
                    width = 2308.33325195313,
                    xOffset = 18447.849609375,
                    yOffset = 4308.234375,
                },
                Mulgore = {
                    height = 3424.999847412109,
                    width = 5137.49987792969,
                    xOffset = 15018.68298339844,
                    yOffset = 13072.81704711914,
                },
                Ogrimmar = {
                    height = 935.41662597657,
                    width = 1402.6044921875,
                    xOffset = 20747.20068359375,
                    yOffset = 10526.02319335937,
                },
                Silithus = {
                    height = 2322.916015625,
                    width = 3483.333984375,
                    xOffset = 14529.099609375,
                    yOffset = 18758.234375,
                },
                StonetalonMountains = {
                    height = 3256.2498168945312,
                    width = 4883.33312988282,
                    xOffset = 13820.76635742187,
                    yOffset = 9883.23388671875,
                },
                Tanaris = {
                    height = 4600.0,
                    width = 6899.999526977539,
                    xOffset = 17285.34959411621,
                    yOffset = 18674.900390625,
                },
                Teldrassil = {
                    height = 3393.75,
                    width = 5091.66650390626,
                    xOffset = 13252.01635742187,
                    yOffset = 968.650390625,
                },
                ThousandNeedles = {
                    height = 2933.3330078125,
                    width = 4399.999694824219,
                    xOffset = 17499.93292236328,
                    yOffset = 16766.56689453125,
                },
                ThunderBluff = {
                    height = 695.833312988286,
                    width = 1043.749938964844,
                    xOffset = 16549.932983398438,
                    yOffset = 13649.900329589844,
                },
                UngoroCrater = {
                    height = 2466.66650390625,
                    width = 3699.9998168945312,
                    xOffset = 16533.26629638672,
                    yOffset = 18766.56689453125,
                },
                Winterspring = {
                    height = 4733.3332519531195,
                    width = 7099.999847412109,
                    xOffset = 17383.26626586914,
                    yOffset = 4266.5673828125,
                },
            },
        },
        -- Eastern Kingdoms
        [2] = {
            parentContinent = 0,
            height = 23466.60009765625,
            width = 35199.900390625,
            xOffset = 16625.0, -- guessed
            yOffset = 2470.0, -- guessed
            zoneData = {
                Alterac = {
                    height = 1866.666656494141,
                    width = 2799.999938964841,
                    xOffset = 15216.666687011719,
                    yOffset = 5966.60009765625,
                },
                Arathi = {
                    height = 2399.99992370606,
                    width = 3599.999877929687,
                    xOffset = 16866.666625976562,
                    yOffset = 7599.93342590332,
                },
                Badlands = {
                    height = 1658.33349609375,
                    width = 2487.5,
                    xOffset = 18079.16650390625,
                    yOffset = 13356.18310546875,
                },
                BlastedLands = {
                    height = 2233.333984375,
                    width = 3349.9998779296902,
                    xOffset = 17241.66662597656,
                    yOffset = 18033.26611328125,
                },
                BurningSteppes = {
                    height = 1952.08349609375,
                    width = 2929.166595458989,
                    xOffset = 16266.66665649414,
                    yOffset = 14497.849609375,
                },
                DeadwindPass = {
                    height = 1666.6669921875,
                    width = 2499.999938964849,
                    xOffset = 16833.33331298828,
                    yOffset = 17333.26611328125,
                },
                DunMorogh = {
                    height = 3283.33325195312,
                    width = 4924.9997558593805,
                    xOffset = 14197.91674804687,
                    yOffset = 11343.68334960938,
                },
                Duskwood = {
                    height = 1800.0,
                    width = 2699.999938964841,
                    xOffset = 15166.666687011719,
                    yOffset = 17183.26611328125,
                },
                EasternPlaguelands = {
                    height = 2581.24975585938,
                    width = 3870.83349609375,
                    xOffset = 18185.41650390625,
                    yOffset = 3666.60034179687,
                },
                Elwynn = {
                    height = 2314.5830078125,
                    width = 3470.83325195312,
                    xOffset = 14464.58337402344,
                    yOffset = 15406.18310546875,
                },
                Hilsbrad = {
                    height = 2133.33325195313,
                    width = 3199.9998779296902,
                    xOffset = 14933.33337402344,
                    yOffset = 7066.60009765625,
                },
                Hinterlands = {
                    height = 2566.6666259765598,
                    width = 3850.0,
                    xOffset = 17575.0,
                    yOffset = 5999.93347167969,
                },
                Ironforge = {
                    height = 527.6044921875,
                    width = 790.625061035154,
                    xOffset = 16713.591369628906,
                    yOffset = 12035.84130859375,
                },
                LochModan = {
                    height = 1839.5830078125,
                    width = 2758.3331298828098,
                    xOffset = 17993.74987792969,
                    yOffset = 11954.10009765625,
                },
                Redridge = {
                    height = 1447.916015625,
                    width = 2170.83325195312,
                    xOffset = 17570.83325195313,
                    yOffset = 16041.60009765625,
                },
                SearingGorge = {
                    height = 1487.49951171875,
                    width = 2231.249847412109,
                    xOffset = 16322.91665649414,
                    yOffset = 13566.60009765625,
                },
                Silverpine = {
                    height = 2799.9998779296902,
                    width = 4199.9997558593805,
                    xOffset = 12550.00024414062,
                    yOffset = 5799.93347167969,
                },
                Stormwind = {
                    height = 896.3544921875,
                    width = 1344.2708053588917,
                    xOffset = 14619.02856445312,
                    yOffset = 15745.45068359375,
                },
                Stranglethorn = {
                    height = 4254.166015625,
                    width = 6381.2497558593805,
                    xOffset = 13779.16674804687,
                    yOffset = 18635.35009765625,
                },
                SwampOfSorrows = {
                    height = 1529.1669921875,
                    width = 2293.75,
                    xOffset = 18222.91650390625,
                    yOffset = 17087.43310546875,
                },
                Tirisfal = {
                    height = 3012.499816894536,
                    width = 4518.74987792969,
                    xOffset = 12966.66674804687,
                    yOffset = 3629.10034179687,
                },
                Undercity = {
                    height = 640.10412597656,
                    width = 959.3750305175781,
                    xOffset = 15126.807373046875,
                    yOffset = 5588.65478515625,
                },
                WesternPlaguelands = {
                    height = 2866.666534423828,
                    width = 4299.999908447271,
                    xOffset = 15583.33334350586,
                    yOffset = 4099.93359375,
                },
                Westfall = {
                    height = 2333.3330078125,
                    width = 3499.9998168945312,
                    xOffset = 12983.33349609375,
                    yOffset = 16866.60009765625,
                },
                Wetlands = {
                    height = 2756.25,
                    width = 4135.416687011719,
                    xOffset = 16389.58331298828,
                    yOffset = 9614.5166015625,
                },
            },
        },
    }
    local zeroData = { xOffset = 0, height = 0, yOffset = 0, width = 0 };
    for continent, zones in pairs(Astrolabe.ContinentList) do
        local mapData = WorldMapSize[continent];
        for index, zData in pairs(zones) do
            if not ( mapData.zoneData[zData.mapFile] ) then
            --WE HAVE A PROBLEM!!!
            -- Disabled because TBC zones were removed
            --ChatFrame1:AddMessage("Astrolabe is missing data for "..select(index, GetMapZones(continent))..".");
                mapData.zoneData[zData.mapFile] = zeroData;
            end
            mapData[index] = mapData.zoneData[zData.mapFile];
            mapData[index].mapName = zData.mapName
            mapData.zoneData[zData.mapFile] = nil;
        end
    end
end

AceLibrary:Register(Astrolabe, LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR, activate)
