---@class MapCoordinates
local MapCoordinates = QuestieLoader:CreateModule("MapCoordinates")

--- Returns a map object from UiMapId used to convert coordinates
---@type table<UiMapId, MapInfo>
local Maps = {}

--- Highest logical parent, Outlands for outlands and Azeroth for Kalimdor, EK and Northrend, use the Maps object first hand.
---@type table<UiMapId, MapInfo[]>
local WorldMaps = {}

--- Contains the API data from GetMapInfo for UiMapId
---@type table<UiMapId, UiMapDetails>
local MapInfo = {}

-- Expose the map objects
MapCoordinates.Maps = Maps
MapCoordinates.WorldMaps = WorldMaps
MapCoordinates.MapInfo = MapInfo


do
    --- Credit goes to elcius
    -- https://www.wowinterface.com/forums/showpost.php?p=328355&postcount=3
    local MapRects = {};
    local TempVec2D = CreateVector2D(0, 0);
    local UnitPosition = UnitPosition
    ---A Fast way to get Player Position
    ---@param mapID UiMapId
    ---@return MapX?
    ---@return MapY?
    function GetPlayerMapPosFast(mapID)
        if not mapID then
            return nil, nil
        end
        local R, P = MapRects[mapID], TempVec2D;
        if not R then
            R = {};
            _, R[1] = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0));
            _, R[2] = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1));
            R[2]:Subtract(R[1]);
            MapRects[mapID] = R;
        end
        --? X and Y are a bit strange here from blizzard API, but this is correct.
        P.x, P.y = UnitPosition("player");
        P:Subtract(R[1]);
        return (1 / R[2].y) * P.y--[[@as MapX]] , (1 / R[2].x) * P.x --[[@as MapY]]
    end

    ---A Fast way to get Player Position
    ---@param mapID UiMapId
    ---@return WorldX?
    ---@return WorldY?
    function GetPlayerWorldPosFast(mapID)
        if not mapID then
            return nil, nil
        end
        local R, P = MapRects[mapID], TempVec2D;
        if not R then
            R = {};
            _, R[1] = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0));
            _, R[2] = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1));
            R[2]:Subtract(R[1]);
            MapRects[mapID] = R;
        end
        --? X and Y are a bit strange here from blizzard API, but this is correct.
        P.x, P.y = UnitPosition("player");
        P:Subtract(R[1]);
        local mapX, mapY = ((1 / R[2].y) * P.y)*100, ((1 / R[2].x) * P.x)*100

        --? Convert to world coordinates
        local rectInfo = Maps[mapID].rectOnWorldMap
        if rectInfo then
            ---@type WorldX
            local worldX = rectInfo.minX + mapX * (rectInfo.maxX - rectInfo.minX) / 100 --[[@as WorldX]]
            ---@type WorldY
            local worldY = rectInfo.minY + mapY * (rectInfo.maxY - rectInfo.minY) / 100 --[[@as WorldY]]
            return worldX, worldY
        end
        return nil, nil
    end
end

-- Minimap world size scaling
local MinimapSizePerYard = {

}

-- Localized functions
local GetMapChildrenInfo = C_Map.GetMapChildrenInfo
local GetMapInfo = C_Map.GetMapInfo
local GetMapRectOnMap = C_Map.GetMapRectOnMap

-- Scope these functions
do
    local UiMapType = {
        Cosmic = 0,
        World = 1,
        Continent = 2,
        Zone = 3,
        Dungeon = 4,
        Micro = 5,
        Orphan = 6,
    }

    --- Convert map coordinates to the world map of the zone (Azeroth or Outlands for example)
    ---@param self MapInfo
    ---@param mapX MapX @ Map X coordinate 0 - 100 (not 0-1)
    ---@param mapY MapY @ Map Y coordinate 0 - 100 (not 0-1)
    ---@return WorldX? WorldX @ World X coordinate 0 - 100
    ---@return WorldY? WorldY @ World Y coordinate 0 - 100
    local function toWorldCoordinate(self, mapX, mapY)
        --? This code is to show a more "readable" version, do not delete
        -- local worldX = map(x, localMin, localMax, self.rectOnWorldMap.minX, self.rectOnWorldMap.maxX)
        -- local worldY = map(y, localMin, localMax, self.rectOnWorldMap.minY, self.rectOnWorldMap.maxY)
        if mapX and mapY then
            if mapX < 0 or mapX > 100 or mapY < 0 or mapY > 100 then
                Questie:Error("test")
                return nil, nil
            end
            local rectInfo = self.rectOnWorldMap
            if rectInfo then
                ---@type WorldX
                local worldX = rectInfo.minX + mapX * (rectInfo.maxX - rectInfo.minX) / 100 --[[@as WorldX]]
                ---@type WorldY
                local worldY = rectInfo.minY + mapY * (rectInfo.maxY - rectInfo.minY) / 100 --[[@as WorldY]]
                return worldX, worldY
            end
        end
        return nil, nil
    end

    --- Convert map coordinates to the continent map (EK, Kalimdor, Northrend and Outlands).
    --- This is mostly used for minimap.
    ---@param self MapInfo
    ---@param mapX MapX @ Map X coordinate 0 - 100 (not 0-1)
    ---@param mapY MapY @ Map Y coordinate 0 - 100 (not 0-1)
    ---@return ContinentX? ContinentX @ 0 - 100 (not 0-1)
    ---@return ContinentY? ContinentY @ 0 - 100 (not 0-1)
    local function toContinentCoordinate(self, mapX, mapY)
        --? This code is to show a more "readable" version, do not delete
        -- local worldX = map(x, localMin, localMax, self.rectOnContinentMap.minX, self.rectOnContinentMap.maxX)
        -- local worldY = map(y, localMin, localMax, self.rectOnContinentMap.minY, self.rectOnContinentMap.maxY)
        if mapX and mapY then
            if Maps[self.parentMapID] and Maps[self.parentMapID].mapType == UiMapType.Continent then
                local worldX, worldY = self:ToWorldCoordinate(mapX, mapY)
                if worldX and worldY then
                    ---@diagnostic disable-next-line: return-type-mismatch
                    return Maps[self.parentMapID]:ToMapCoordinate(worldX, worldY)
                end
            elseif self.parentMapID == 1945 then -- A bit of a special case for outlands
                ---@diagnostic disable-next-line: return-type-mismatch
                return self:ToWorldCoordinate(mapX, mapY)
            end
        end
        return nil, nil
    end

    --- Convert world coordinates to the current map.
    ---@param self MapInfo
    ---@param worldX WorldX? @ World X coordinate 0 - 100 (not 0-1)
    ---@param worldY WorldY? @ World X coordinate 0 - 100 (not 0-1)
    ---@return MapX? MapX @ Map X coordinate 0 - 100
    ---@return MapY? MapY @ Map Y coordinate 0 - 100
    local function toMapCoordinate(self, worldX, worldY)
        if worldX and worldY then
            local WorldMap = WorldMaps[self.worldMapId]
            local rectInfo = WorldMap and WorldMap[self.mapID].rectOnWorldMap or nil
            if rectInfo then
                --? This code is to show a more "readable" version, do not delete
                -- local x = map(worldX, rectInfo.minX, rectInfo.maxX, localMin, localMax)
                -- local y = map(worldY, rectInfo.minY, rectInfo.maxY, localMin, localMax)
                ---@type MapX
                local x = (worldX - rectInfo.minX) * 100 / (rectInfo.maxX - rectInfo.minX) --[[@as MapX]]
                ---@type MapY
                local y = (worldY - rectInfo.minY) * 100 / (rectInfo.maxY - rectInfo.minY) --[[@as MapY]]
                return x, y
            end
        end
        return nil, nil
    end

    -- 946 is Cosmic with Outlands and Azeroth, 947 is only Azeroth
    -- Fetches all continents
    local info = GetMapChildrenInfo(946, UiMapType.Continent, true) or
        GetMapChildrenInfo(947, UiMapType.Continent, true)
    for mapIndex = 1, #info do
        local mapInfo = info[mapIndex]
        MapInfo[mapInfo.mapID] = mapInfo
        --? Only populate once
        if not WorldMaps[mapInfo.parentMapID] then
            --? If the parentId is a world type use the parent, else use the continent
            --? (Basically, Azeroth(EK, Kalimdor, Northrend) or Outlands)
            local worldMapId = GetMapInfo(mapInfo.parentMapID).mapType == UiMapType.World and mapInfo.parentMapID or mapInfo.mapID

            ---@type MapInfo[]
            local WorldMap = {}
            -- Fill the table with all Maps
            local allMaps = GetMapChildrenInfo(worldMapId, nil, true)
            if allMaps then
                for allMapIndex = 1, #allMaps do
                    ---@class MapInfo : UiMapDetails
                    local subMapInfo = allMaps[allMapIndex]
                    local minX, maxX, minY, maxY = GetMapRectOnMap(subMapInfo.mapID, worldMapId)
                    -- 0 means it's not part of the map
                    if minX ~= 0 and maxX ~= 0 and minY ~= 0 and maxY ~= 0 then
                        --* We just modify this object because we want all the data in it anyway.

                        -- We want to save the worldMapId because it's the mapId that the "WorldCoordinate" is based on.
                        subMapInfo.worldMapId = worldMapId
                        -- subMapInfo.continentMapId = GetMapInfo(subMapInfo.parentMapID).mapType == UIMapType.Continent and subMapInfo.parentMapID or

                        -- We want to save the rectOnWorldMap because it's the rect that we need to convert the coordinates.
                        -- times 100 because we want to work with 0-100 instead of 0-1
                        subMapInfo.rectOnWorldMap = {
                            minX = minX * 100,
                            maxX = maxX * 100,
                            minY = minY * 100,
                            maxY = maxY * 100,
                        }

                        -- Convertion functions
                        subMapInfo.ToWorldCoordinate = toWorldCoordinate
                        subMapInfo.ToContinentCoordinate = toContinentCoordinate
                        subMapInfo.ToMapCoordinate = toMapCoordinate

                        -- A table that contains all the nearbyZones
                        subMapInfo.nearbyZones = {}


                        WorldMap[subMapInfo.mapID] = subMapInfo
                        Maps[subMapInfo.mapID] = subMapInfo
                    end
                end
            end
            WorldMaps[worldMapId] = WorldMap

            --? This totally works, just not needed... (Do not remove)
            -- WorldMaps[worldMapId].FromWorldCoordinateToMapCoordinate = ToMapCoordinateWorld
        end
    end

    -- Calculate overlap of maps into a nearby zones table
    for _, worldMap in pairs(WorldMaps) do
        -- We only check zone that are on the same worldmap against eachother.
        for mapId, mapInfo in pairs(worldMap) do
            -- Do not run on the continents, the zones writes themselves into the continents
            if mapInfo.mapType ~= UiMapType.Continent then
                for otherMapId, otherMapInfo in pairs(worldMap) do
                    if mapId ~= otherMapId then
                        local otherRectInfo = otherMapInfo.rectOnWorldMap
                        local rectInfo = mapInfo.rectOnWorldMap
                        if otherRectInfo and rectInfo then
                            --/dump MapCoordinates.Maps[WorldMapFrame:GetMapID()]
                            -- Check if the rects overlap in any way, this is kind of black magic at this point. But it seems to work!
                            if (rectInfo.minX >= otherRectInfo.minX and rectInfo.minX <= otherRectInfo.maxX and
                                rectInfo.minY >= otherRectInfo.minY and rectInfo.minY <= otherRectInfo.maxY) or

                                (rectInfo.maxX >= otherRectInfo.minX and rectInfo.maxX <= otherRectInfo.maxX and
                                    rectInfo.minY >= otherRectInfo.minY and rectInfo.minY <= otherRectInfo.maxY) or

                                (rectInfo.minX >= otherRectInfo.minX and rectInfo.minX <= otherRectInfo.maxX and
                                    rectInfo.maxY >= otherRectInfo.minY and rectInfo.maxY <= otherRectInfo.maxY) or

                                (rectInfo.maxX >= otherRectInfo.minX and rectInfo.maxX <= otherRectInfo.maxX and
                                    rectInfo.maxY >= otherRectInfo.minY and rectInfo.maxY <= otherRectInfo.maxY) or

                                -- These check if it lives INSIDE of another zone, such as Stormwind being inside of Elwynn.
                                (otherRectInfo.minX >= rectInfo.minX and otherRectInfo.minX <= rectInfo.maxX and
                                    otherRectInfo.minY >= rectInfo.minY and otherRectInfo.minY <= rectInfo.maxY) or

                                (otherRectInfo.maxX >= rectInfo.minX and otherRectInfo.maxX <= rectInfo.maxX and
                                    otherRectInfo.minY >= rectInfo.minY and otherRectInfo.minY <= rectInfo.maxY) or

                                (otherRectInfo.minX >= rectInfo.minX and otherRectInfo.minX <= rectInfo.maxX and
                                    otherRectInfo.maxY >= rectInfo.minY and otherRectInfo.maxY <= rectInfo.maxY) or

                                (otherRectInfo.maxX >= rectInfo.minX and otherRectInfo.maxX <= rectInfo.maxX and
                                    otherRectInfo.maxY >= rectInfo.minY and otherRectInfo.maxY <= rectInfo.maxY)
                            then
                                --? Future person, this could probably be improved by running a few sanitiy checks.
                                --? To see if they just overlap on the worldmap or if they actually overlap.

                                -- Here we check that the continent is the same, otherwise we get stuff like Trisfal Glades overlap with Northrend.
                                if otherMapInfo.mapType == UiMapType.Continent and
                                    mapInfo.parentMapID == otherMapInfo.mapID then
                                    -- A good way to debug this is to set the name
                                    mapInfo.nearbyZones[otherMapId] = otherMapInfo.name
                                elseif (otherMapInfo.mapType ~= UiMapType.Continent) then
                                    mapInfo.nearbyZones[otherMapId] = otherMapInfo.name
                                end
                            end
                        end
                    end
                end
            end
            -- Add the zone to the parent (continent)
            if Maps[mapInfo.parentMapID] then
                Maps[mapInfo.parentMapID].nearbyZones[mapInfo.mapID] = mapInfo.name
            end
        end
    end

    -- If the map does not exist, we try to run the GetMapInfo and populate the table.
    MapCoordinates.MapInfo = setmetatable(MapCoordinates.MapInfo, {
        __index = function(self, k)
            local v = GetMapInfo(k);
            self[k] = v
            return v;
        end,
    })


    --* Kalimdor
    local xCoord = 20
    local instanceId, worldCoords = C_Map.GetWorldPosFromMapPos(947, { x = xCoord, y = 60 })
    local dist
    repeat
        local _, newCoord = C_Map.GetWorldPosFromMapPos(947, { x = xCoord, y = 60 })
        dist = worldCoords.y - newCoord.y
        xCoord = xCoord + 0.00001
    until dist >= 466 + 2 / 3
    print("Kalimdor", instanceId, xCoord, dist)
    MinimapSizePerYard[instanceId] = (dist - 20) * 100

    --* Eastern Kindom
    xCoord = 80
    instanceId, worldCoords = C_Map.GetWorldPosFromMapPos(947, { x = xCoord, y = 60 })
    repeat
        local _, newCoord = C_Map.GetWorldPosFromMapPos(947, { x = xCoord, y = 60 })
        dist = worldCoords.y - newCoord.y
        xCoord = xCoord + 0.00001
    until dist >= 466 + 2 / 3
    print("EK", instanceId, xCoord, dist)
    MinimapSizePerYard[instanceId] = (dist - 80) * 100

    --* Northrend
    xCoord = 50
    instanceId, worldCoords = C_Map.GetWorldPosFromMapPos(113, { x = xCoord, y = 16 })
    repeat
        local _, newCoord = C_Map.GetWorldPosFromMapPos(113, { x = xCoord, y = 16 })
        dist = worldCoords.y - newCoord.y
        xCoord = xCoord + 0.00001
    until dist >= 466 + 2 / 3
    print("Northrend", instanceId, xCoord, dist)
    MinimapSizePerYard[instanceId] = (dist - 50) * 100

    --* Outlands
    xCoord = 20
    instanceId, worldCoords = C_Map.GetWorldPosFromMapPos(1945, { x = xCoord, y = 60 })
    repeat
        local _, newCoord = C_Map.GetWorldPosFromMapPos(1945, { x = xCoord, y = 60 })
        dist = worldCoords.y - newCoord.y
        xCoord = xCoord + 0.00001
    until dist >= 466 + 2 / 3
    print("Outlands", instanceId, xCoord, dist)
    MinimapSizePerYard[instanceId] = (dist - 20) * 100

    DevTools_Dump(MinimapSizePerYard)
end


--! Test code, do not remove!
--* tostring because of floating point errors
local barrensMapId = 1413
local kalimdorMapId = 1414
local center = 50
---@cast center -integer
local centerX, centerY = Maps[barrensMapId]:ToWorldCoordinate(center, center)
assert(centerX and centerY, "Failed to convert to world coordinate")
if centerX and centerY then
    -- print("Center of barrens in World Coords")
    -- DevTools_Dump({ centerX, centerY })
    assert(tostring(centerX) == "22.952741757035" and tostring(centerY) == "63.35768699646", "Incorrect convertion to world coordinate")

    -- print("Center of barrens from World coords")
    local mCenterX, mCenterY = Maps[barrensMapId]:ToMapCoordinate(centerX, centerY)
    -- DevTools_Dump({ mCenterX, mCenterY })
    assert(tostring(mCenterX) == "50" and tostring(mCenterY) == "50", "Incorrect convertion to map coordinate")

    -- print("Center of barrens on Kalimdor from Maps object")
    mCenterX, mCenterY = Maps[kalimdorMapId]:ToMapCoordinate(centerX, centerY)
    -- DevTools_Dump({ mCenterX, mCenterY })
    assert(tostring(mCenterX) == "53.017528574595" and tostring(mCenterY) == "59.370666022994", "Incorrect convertion to Kalimdor coordinate")

    -- print("Center of Kalimdor in World Coords")
    centerX, centerY = Maps[kalimdorMapId]:ToWorldCoordinate(center, center)
    -- DevTools_Dump({ centerX, centerY })
    assert(tostring(centerX) == "20.634907484055" and tostring(centerY) == "56.158988922834", "Incorrect convertion to Kalimdor World Coords")

    -- print("Center of Kalimdor from Maps object")
    assert(centerX and centerY, "Incorrect convertion for kalimdor world cords")
    if centerX and centerY then
        mCenterX, mCenterY = Maps[kalimdorMapId]:ToMapCoordinate(centerX, centerY)
        -- DevTools_Dump({ mCenterX, mCenterY })
        assert(tostring(mCenterX) == "50" and tostring(mCenterY) == "50", "Incorrect convertion to Kalimdor map coordinate")
    end
end
-- Just a simple loop through
for mapId in pairs(Maps) do
    centerX, centerY = Maps[mapId]:ToWorldCoordinate(center, center)
    assert(centerX and centerY, "Failed to convert to world coordinate")
    if centerX and centerY then
        local mCenterX, mCenterY = Maps[mapId]:ToMapCoordinate(centerX, centerY)
        assert(mCenterX and mCenterY, "Failed to convert to map coordinate")
        assert(tostring(mCenterX) == "50" and tostring(mCenterY) == "50", "Incorrect coordinate when converting to map coordinate")
    end
end



--? Please do not remove
--? This totally works, it's just not really needed...
--? I keep this here to show how the map function works, due to performance i copy this function into the code
-- local localMin = 0
-- local localMax = 100

-- local function map(x, in_min, in_max, out_min, out_max)
--     return out_min + (x - in_min)*(out_max - out_min)/(in_max - in_min)
-- end

-- ---@param self MapInfo[]
-- ---@param worldX WorldX
-- ---@param worldY WorldY
-- ---@param toUiMapId UiMapId
-- ---@return number?
-- ---@return number?
-- local ToMapCoordinateWorld = function(self, worldX, worldY, toUiMapId)
--     local rectInfo = self[toUiMapId] and self[toUiMapId].rectOnWorldMap
--     if rectInfo then
--         local y = map(worldY, rectInfo.minY, rectInfo.maxY, localMin, localMax)
--         local x = map(worldX, rectInfo.minX, rectInfo.maxX, localMin, localMax)
--         return x, y
--     end
--     return nil, nil
-- end
