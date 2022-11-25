---@class RelationDataProcessor
local RelationDataProcessor = QuestieLoader:CreateModule("RelationDataProcessor")

--- Questie Imports ---
---@type ZoneDB
local ZoneDB = QuestieLoader("ZoneDB")
---@type MapCoordinates
local MapCoodinates = QuestieLoader("MapCoordinates")
---@type SpawnProcessor
local SpawnProcessor = QuestieLoader("SpawnProcessor")

--- Lib Imports ---

---@type Spline
local Spline = QuestieLoader:ImportModule("Spline")
---@type Bezier
local Bezier = QuestieLoader:ImportModule("Bezier")

local SplineLib = Spline:CreateCatmullRomSpline(2);
local BezierLib = Bezier:CreateBezier();
--* These are set here to show up in the profiler
RelationDataProcessor.SplineLib = SplineLib
RelationDataProcessor.BezierLib = BezierLib

-- Math
local sqrt, floor = math.sqrt, math.floor

---Get the dungeon locations in the correct format or false(because we can't save nil)
---@param AreaId AreaId
---@return false|Coordinates[]
local function getDungeonLocations(AreaId)
    local dungeonLocation = ZoneDB:GetDungeonLocation(AreaId)

    ---@type table<AreaId, Coordinates>
    local locations = {}
    if dungeonLocation ~= nil then
        for _, dungeonCoords in ipairs(dungeonLocation) do
            ---@type AreaId, MapX, MapY
            local areaId, x, y = dungeonCoords[1], dungeonCoords[2], dungeonCoords[3]

            if (not locations[areaId]) then
                locations[areaId] = { x = {}, y = {} } --, areaId = areaId
            end
            -- Add the coordinates to the table
            locations[areaId].x[#locations[areaId].x + 1] = x
            locations[areaId].y[#locations[areaId].y + 1] = y
        end
        return locations
    else
        return false
    end
end

--- A memoized version of the getDungeonLocations function
--- Just use it as a regular table
---@type table<AreaId, Coordinates[]>>
local DungeonLocations = setmetatable({}, {
    __index = function(self, k)
        local v = getDungeonLocations(k);
        self[k] = v
        return v;
    end,
})

---comment
---@param starterIcons table<UiMapId, AvailablePoints>
---@param id NpcId|ObjectId|ItemId
---@param data table
---@param idType RelationPointType
---@param spawnType "NPC"| "Object"
----@param QuerySingleFunction fun(id: NpcId|ObjectId|ItemId, query: "spawns"): table<AreaId, {[1]: MapX, [2]: MapY}[]>>
---@param itemId ItemId? -- This is used to override the ID which is added into starterIcons
---@return boolean? expensiveOperation @ True = processed, False = cached, nil = no spawns exists
---@return table<AreaId, Coordinates>? Spawns @ The processed spawns
function RelationDataProcessor.GetSpawns(starterIcons, id, data, idType, spawnType, itemId)
    if starterIcons == nil or type(starterIcons) ~= "table" then
        error("GetSpawns called with invalid starterIcons")
        return
    elseif id == nil or type(id) ~= "number" then
        error("GetSpawns called with invalid id")
        return
    elseif data == nil or type(data) ~= "table" then
        error("GetSpawns called with invalid data")
        return
    elseif idType ~= "npc" and idType ~= "object" and idType ~= "item" and idType ~= "npcFinisher" and idType ~= "objectFinisher" then
        error("GetSpawns called with invalid type")
        return
    elseif spawnType == nil or type(spawnType) ~= "string" then
        error("GetSpawns called with invalid spawnType")
        return
    elseif itemId ~= nil and type(itemId) ~= "number" and idType == "item" then
        error("GetSpawns called with invalid itemId")
        return
    end
    local processedSpawns, spawns = SpawnProcessor.GetSpawns(id, spawnType)
    if spawns ~= nil then
        for areaId, coords in pairs(spawns) do
            if coords.x and coords.y then
                for i = 1, #coords.x do


                    local UiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
                    local x = coords.x[i]
                    local y = coords.y[i]

                    -- We only want to handle Maps that are on the worldmap
                    if MapCoodinates.Maps[UiMapId] then
                        if starterIcons[UiMapId] == nil then
                            starterIcons[UiMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {} }
                        end
                        local worldX, worldY = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(x, y)
                        local index = #starterIcons[UiMapId].x + 1
                        starterIcons[UiMapId].x[index] = x
                        starterIcons[UiMapId].y[index] = y
                        starterIcons[UiMapId].iconData[index] = data
                        starterIcons[UiMapId].id[index] = itemId or id
                        starterIcons[UiMapId].type[index] = idType

                        -- All nearby zones but also continents.
                        for NearByUiMapId, _ in pairs(MapCoodinates.Maps[UiMapId].nearbyZones) do
                            if MapCoodinates.Maps[NearByUiMapId] then
                                local mapX, mapY = MapCoodinates.Maps[NearByUiMapId]:ToMapCoordinate(worldX, worldY)
                                if mapX > 0 and mapX < 100 and mapY > 0 and mapY < 100 then
                                    if starterIcons[NearByUiMapId] == nil then
                                        starterIcons[NearByUiMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {} }
                                    end
                                    index = #starterIcons[NearByUiMapId].x + 1
                                    starterIcons[NearByUiMapId].x[index] = mapX
                                    starterIcons[NearByUiMapId].y[index] = mapY
                                    starterIcons[NearByUiMapId].iconData[index] = data
                                    starterIcons[NearByUiMapId].id[index] = itemId or id
                                    starterIcons[NearByUiMapId].type[index] = idType
                                end
                            end
                        end

                        -- Add to world map
                        local worldMapId = MapCoodinates.Maps[UiMapId].worldMapId
                        if not MapCoodinates.Maps[worldMapId] then
                            if starterIcons[worldMapId] == nil then
                                starterIcons[worldMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {} }
                            end
                            index = #starterIcons[worldMapId].x + 1
                            -- This is a bit of a special case WorldX/Y is basicall MapX/Y for the worldMapId
                            starterIcons[worldMapId].x[index] = worldX --[[@as MapX]]
                            starterIcons[worldMapId].y[index] = worldY --[[@as MapY]]
                            starterIcons[worldMapId].iconData[index] = data
                            starterIcons[worldMapId].id[index] = itemId or id
                            starterIcons[worldMapId].type[index] = idType
                        end
                    end
                end
            end
        end
    end
    return processedSpawns, spawns
end

---@param starterWaypoints table<UiMapId, AvailableWaypointPoints>
---@param id NpcId|ObjectId|ItemId
---@param data table
---@param idType RelationPointType
---@param itemId ItemId? -- This is used to override the ID which is added into starterWaypoints
---@return boolean? ProcessedWaypoints @ This is true if we run the really expensive operations
---@return table<AreaId, {x: MapX[], y: MapY[], waypointIndex: number[]}>? Waypoints @ The processed spawns
function RelationDataProcessor.GetWaypoints(starterWaypoints, id, data, idType, QuerySingleFunction, itemId)
    if starterWaypoints == nil or type(starterWaypoints) ~= "table" then
        error("GetSpawns called with invalid starterWaypoints")
        return
    elseif id == nil or type(id) ~= "number" then
        error("GetSpawns called with invalid id")
        return
    elseif data == nil or type(data) ~= "table" then
        error("GetSpawns called with invalid data")
        return
    elseif idType ~= "npc" and idType ~= "object" and idType ~= "item" and idType ~= "npcFinisher" and idType ~= "objectFinisher" then
        error("GetSpawns called with invalid type")
        return
    elseif itemId ~= nil and type(itemId) ~= "number" and idType == "item" then
        error("GetSpawns called with invalid itemId")
        return
    end
    -- local processedWaypoints = true
    -- local waypoints = ProcessedWaypoints[id] or QuerySingleFunction(id, "waypoints")
    local processedWaypoints, waypoints = SpawnProcessor.GetWaypoints(id)
    if waypoints ~= nil then
        for areaId, coords in pairs(waypoints) do
            if coords.x and coords.y then
                local UiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
                for i = 1, #coords.x do
                    local x = coords.x[i]
                    local y = coords.y[i]
                    local waypointIndex = coords.waypointIndex[i]

                    -- We only want to handle Maps that are on the worldmap
                    if MapCoodinates.Maps[UiMapId] then
                        if starterWaypoints[UiMapId] == nil then
                            starterWaypoints[UiMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {}, waypointIndex = {} }
                        end
                        local index = #starterWaypoints[UiMapId].x + 1
                        starterWaypoints[UiMapId].x[index] = x
                        starterWaypoints[UiMapId].y[index] = y
                        starterWaypoints[UiMapId].iconData[index] = data
                        starterWaypoints[UiMapId].id[index] = itemId or id
                        starterWaypoints[UiMapId].type[index] = idType
                        starterWaypoints[UiMapId].waypointIndex[index] = waypointIndex


                        --? If we ever want to nearby zones for waypoints, here's the code, do not delete!
                        -- All nearby zones.
                        --[[
                        local worldX, worldY = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(x, y)
                        for NearByUiMapId, _ in pairs(MapCoodinates.Maps[UiMapId].nearbyZones) do
                            if MapCoodinates.Maps[NearByUiMapId] and MapCoodinates.MapInfo[NearByUiMapId].mapType >= 3 then
                                local mapX, mapY = MapCoodinates.Maps[NearByUiMapId]:ToMapCoordinate(worldX, worldY)
                                if mapX > 0 and mapX < 100 and mapY > 0 and mapY < 100 then
                                    if starterWaypoints[NearByUiMapId] == nil then
                                        starterWaypoints[NearByUiMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {}, waypointIndex = {} }
                                    end
                                    index = #starterWaypoints[NearByUiMapId].x + 1
                                    starterWaypoints[NearByUiMapId].x[index] = mapX
                                    starterWaypoints[NearByUiMapId].y[index] = mapY
                                    starterWaypoints[NearByUiMapId].iconData[index] = data
                                    starterWaypoints[NearByUiMapId].id[index] = itemId or id
                                    starterWaypoints[NearByUiMapId].type[index] = idType
                                    starterWaypoints[NearByUiMapId].waypointIndex[index] = waypointIndex
                                end
                            end
                        end

                        Add to world map
                        local worldMapId = MapCoodinates.Maps[UiMapId].worldMapId
                        if not MapCoodinates.Maps[worldMapId] then
                            if starterWaypoints[worldMapId] == nil then
                                starterWaypoints[worldMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {} }
                            end
                            index = #starterWaypoints[worldMapId].x + 1
                            -- This is a bit of a special case WorldX/Y is basicall MapX/Y for the worldMapId
                            starterWaypoints[worldMapId].x[index] = worldX --[ [@as MapX] ]
                            starterWaypoints[worldMapId].y[index] = worldY --[ [@as MapY] ]
                            starterWaypoints[worldMapId].iconData[index] = data
                            starterWaypoints[worldMapId].id[index] = itemId or id
                            starterWaypoints[worldMapId].type[index] = idType
                        end
                        ]] --
                    end
                end
            end
        end
    end
    return processedWaypoints, waypoints
end
