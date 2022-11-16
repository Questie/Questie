---@class RelationDataProcessor
local RelationDataProcessor = QuestieLoader:CreateModule("RelationDataProcessor")

--- Questie Imports ---
---@type ZoneDB
local ZoneDB = QuestieLoader("ZoneDB")
---@type MapCoordinates
local MapCoodinates = QuestieLoader("MapCoordinates")

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

-- Contains processed waypoints
-- This is a weak table so references to the table will be removed when the table is no longer used
-- The references are being kept and calculated in ProcessAvailableQuests and ProcessCompletedQuests
local ProcessedWaypoints = setmetatable({}, { __mode = "kv" })
RelationDataProcessor.ProcessedWaypoints = ProcessedWaypoints

-- Contains processed spawns
-- This is a weak table so references to the table will be removed when the table is no longer used
-- The references are being kept and calculated in ProcessAvailableQuests and ProcessCompletedQuests
local ProcessedSpawns = setmetatable({}, { __mode = "kv" })
RelationDataProcessor.ProcessedSpawns = ProcessedSpawns

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
---@param QuerySingleFunction fun(id: NpcId|ObjectId|ItemId, query: "spawns"): table<AreaId, {[1]: MapX, [2]: MapY}[]>>
---@param itemId ItemId? -- This is used to override the ID which is added into starterIcons
---@return boolean? ProcessedSpawns @ This is true if we run the really expensive operations
function RelationDataProcessor.GetSpawns(starterIcons, id, data, idType, QuerySingleFunction, itemId)
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
    elseif QuerySingleFunction == nil or type(QuerySingleFunction) ~= "function" then
        error("GetSpawns called with invalid QuerySingleFunction")
        return
    elseif itemId ~= nil and type(itemId) ~= "number" and idType == "item" then
        error("GetSpawns called with invalid itemId")
        return
    end
    local processedSpawns = true
    local spawns = ProcessedSpawns[id] or QuerySingleFunction(id, "spawns")
    if spawns ~= nil then
        ---@type table<AreaId, {x: MapX[], y: MapY[]}>>
        local starter
        if not ProcessedSpawns[id] then
            starter = {}
            for SpawnAreaId, coords in pairs(spawns) do

                local dungeonLocation = DungeonLocations[SpawnAreaId]

                if starter[SpawnAreaId] == nil and not dungeonLocation then
                    starter[SpawnAreaId] = { x = {}, y = {} }
                end

                if not dungeonLocation then
                    for coordIndex = 1, #coords do
                        local coord = coords[coordIndex]
                        local index = #starter[SpawnAreaId].x + 1
                        -- Add the coordinates to the table
                        starter[SpawnAreaId].x[index] = coord[1]
                        starter[SpawnAreaId].y[index] = coord[2]
                    end
                else
                    for areaId, dungeonCoords in pairs(dungeonLocation) do
                        if starter[areaId] == nil then
                            starter[areaId] = { x = {}, y = {} } --, areaId = areaId
                        end
                        for coordIndex = 1, #dungeonCoords.x do
                            local x = dungeonCoords.x[coordIndex]
                            local y = dungeonCoords.y[coordIndex]
                            local index = #starter[areaId].x + 1
                            -- Add the coordinates to the table
                            starter[areaId].x[index] = x
                            starter[areaId].y[index] = y
                        end
                    end
                end
            end
            --* Set the processed spawns
            ProcessedSpawns[id] = starter
        else
            --* Use the previously processed spawns
            starter = spawns
            processedSpawns = false
        end
        for areaId, coords in pairs(starter) do
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
    return processedSpawns
end

---@param starterWaypoints table<UiMapId, AvailableWaypointPoints>
---@param id NpcId|ObjectId|ItemId
---@param data table
---@param idType RelationPointType
---@param QuerySingleFunction fun(id: NpcId|ObjectId|ItemId, query: "waypoints"): table<AreaId, {[1]: MapX, [2]: MapY}[]>>
---@param itemId ItemId? -- This is used to override the ID which is added into starterWaypoints
---@return boolean? ProcessedWaypoints @ This is true if we run the really expensive operations
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
    elseif QuerySingleFunction == nil or type(QuerySingleFunction) ~= "function" then
        error("GetSpawns called with invalid QuerySingleFunction")
        return
    elseif itemId ~= nil and type(itemId) ~= "number" and idType == "item" then
        error("GetSpawns called with invalid itemId")
        return
    end
    local processedWaypoints = true
    local waypoints = ProcessedWaypoints[id] or QuerySingleFunction(id, "waypoints")
    if waypoints ~= nil then
        ---@type table<AreaId, {x: MapX[], y: MapY[], waypointIndex: number[]}>>
        local starter
        if not ProcessedWaypoints[id] then
            starter = {}
            for zoneId, waypointsList in pairs(waypoints) do
                local UiMapId = ZoneDB:GetUiMapIdByAreaId(zoneId)
                local lastPos
                if starter[zoneId] == nil then
                    starter[zoneId] = { x = {}, y = {}, waypointIndex = {} }
                end
                for waypointListIndex, rawWaypoints in pairs(waypointsList or {}) do
                    SplineLib:ClearPoints()
                    for waypointIndex = 1, #rawWaypoints do
                        local waypoint = rawWaypoints[waypointIndex]
                        SplineLib:AddPoint(waypoint[1], waypoint[2])
                    end
                    local newLines = {}
                    local percentageBetweenPoints = 0.10
                    for i = 2, SplineLib.numPoints do -- Same as SplineLib:GetNumPoints()
                        for subPoint = 1, floor(1 / percentageBetweenPoints) do
                            --print(subPoint*percentageBetweenPoints)
                            --It should never be 0 or 1, but due to us starting on 1 we only need to check for 1
                            if (subPoint * percentageBetweenPoints ~= 1) then
                                -- local x, y = SplineLib:CalculatePointOnLocalCurveSegment(i, subPoint * percentageBetweenPoints)
                                local x, y = SplineLib.calculateFunction(subPoint * percentageBetweenPoints,
                                                                         unpack(SplineLib.pointData, (i - 2) * SplineLib.numDimensions + 1,
                                                                                (i + 2) * SplineLib.numDimensions));
                                -- print((i - 2) * SplineLib.numDimensions + 1, (i + 2) * SplineLib.numDimensions)
                                -- local index = (i - 2) * SplineLib.numDimensions + 1
                                -- local x, y = SplineLib.calculateFunction(subPoint * percentageBetweenPoints,
                                -- SplineLib.pointData[index], SplineLib.pointData[index + 1], SplineLib.pointData[index + 2],
                                -- SplineLib.pointData[index + 3], SplineLib.pointData[index + 4], SplineLib.pointData[index + 5],
                                -- SplineLib.pointData[index + 6], SplineLib.pointData[index + 7]
                                -- );
                                local point = { x = x, y = y }
                                newLines[#newLines + 1] = point
                            end
                        end
                    end
                    local pReduce = 0.03
                    BezierLib.points = newLines -- BezierLib:setPoints(newLines)
                    --BezierLib:setAutoStepScale(1)
                    BezierLib:reduce(pReduce)

                    local points = BezierLib.points --BezierLib:getPoints()
                    lastPos = nil
                    for pointIndex = 1, #points do
                        local point = points[pointIndex]
                        if (lastPos == nil) then
                            lastPos = point;
                        else
                            starter[zoneId].x[#starter[zoneId].x + 1] = lastPos.x
                            starter[zoneId].y[#starter[zoneId].y + 1] = lastPos.y
                            starter[zoneId].x[#starter[zoneId].x + 1] = point.x
                            starter[zoneId].y[#starter[zoneId].y + 1] = point.y
                            starter[zoneId].waypointIndex[#starter[zoneId].waypointIndex + 1] = waypointListIndex
                            starter[zoneId].waypointIndex[#starter[zoneId].waypointIndex + 1] = waypointListIndex
                            lastPos = point;
                        end
                    end

                    --TODO: Fix
                    if (lastPos and lastPos ~= points[1]) then
                        local firstPoint = points[1]
                        if MapCoodinates.Maps[UiMapId] then
                            local x1, y1 = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(lastPos.x, lastPos.y)
                            local x2, y2 = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(firstPoint.x, firstPoint.y)

                            local sqDistance = sqrt(SquaredDistanceBetweenPoints(x1, y1, x2, y2))
                            --We get TexCoords error if the disatnce is to low!
                            if (sqDistance > 0.05 and sqDistance < 0.2) then
                                starter[zoneId].x[#starter[zoneId].x + 1] = lastPos.x
                                starter[zoneId].y[#starter[zoneId].y + 1] = lastPos.y
                                starter[zoneId].x[#starter[zoneId].x + 1] = firstPoint.x
                                starter[zoneId].y[#starter[zoneId].y + 1] = firstPoint.y
                                starter[zoneId].waypointIndex[#starter[zoneId].waypointIndex + 1] = waypointListIndex
                                starter[zoneId].waypointIndex[#starter[zoneId].waypointIndex + 1] = waypointListIndex
                            end
                        end
                    end
                end
            end
            --* Set the processed waypoints
            ProcessedWaypoints[id] = starter
        else
            --* Use the previously processed waypoints
            starter = waypoints
            processedWaypoints = false
        end
        for areaId, coords in pairs(starter) do
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
    return processedWaypoints
end
