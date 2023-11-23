---@class SpawnProcessor
local SpawnProcessor = QuestieLoader:CreateModule("SpawnProcessor")

---@type ZoneDB
local ZoneDB = QuestieLoader("ZoneDB")
---@type QuestieDB
local QuestieDB = QuestieLoader("QuestieDB")

---@type MapCoordinates
local MapCoodinates = QuestieLoader("MapCoordinates")
---@type Spline
local Spline = QuestieLoader:ImportModule("Spline")
---@type Bezier
local Bezier = QuestieLoader:ImportModule("Bezier")

local SplineLib = Spline:CreateCatmullRomSpline(2);
local BezierLib = Bezier:CreateBezier();

-- Math
local sqrt, floor = math.sqrt, math.floor
local type, unpack = type, unpack

--? This design pattern allows us to keep a temporary cache of the processed coordinate data
--? It keeps it until next collection unless the table is stored somewhere else,
--? then it will be kept until that reference is removed
-- Contains processed waypoints (Only NPCs for obvious reasons)
-- This is a weak table so references to the table will be removed when the table is no longer used
-- The references are being kept and calculated in ProcessAvailableQuests and ProcessCompletedQuests
local ProcessedWaypoints = setmetatable({}, { __mode = "kv" })
SpawnProcessor.ProcessedWaypoints = ProcessedWaypoints

-- Contains processed spawns (NPC and Object)
-- This is a weak table so references to the table will be removed when the table is no longer used
-- The references are being kept by the user e.g. ProcessAvailableQuests and ProcessCompletedQuests in RelationMapProcessor
---@type {["NPC"]: table<NpcId, Coordinates>, ["Object"]: table<ObjectId, Coordinates>}
local ProcessedSpawns = {
    NPC = setmetatable({}, { __mode = "kv" }),
    Object = setmetatable({}, { __mode = "kv" })
}
SpawnProcessor.ProcessedNpcSpawns = ProcessedSpawns.NPC
SpawnProcessor.ProcessedObjectSpawns = ProcessedSpawns.Object

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
---@param id NpcId|ObjectId
---@param spawnType "NPC" | "Object"
---@return boolean? expensiveOperation @ True = processed, False = cached, nil = no spawns exists
---@return table<AreaId, Coordinates>? Spawns @ The processed spawns
function SpawnProcessor.GetSpawns(id, spawnType)
    if (spawnType ~= "NPC" and spawnType ~= "Object") then
        error("Invalid type: " .. spawnType)
    end
    if (id == nil or type(id) ~= "number") then
        error("Invalid id: " .. id)
    end
    -- Try to fetch cached spawns
    local cachedSpawns = ProcessedSpawns[spawnType][id]
    if cachedSpawns == nil then
        -- Fetch spawns
        local rawSpawns = spawnType == "NPC" and QuestieDB.QueryNPCSingle(id, "spawns") or QuestieDB.QueryObjectSingle(id, "spawns")
        if rawSpawns ~= nil then
            -- Keeps track of the current length instead of relying on #table
            -- Starts at 0 because we increment it before using it to avoid having to add 1 to the length
            local spawnCoordLength = 0
            ---@type table<AreaId, Coordinates>
            local spawns = {}
            for SpawnAreaId, coords in pairs(rawSpawns) do

                local dungeonLocation = DungeonLocations[SpawnAreaId]

                if spawns[SpawnAreaId] == nil and not dungeonLocation then
                    spawns[SpawnAreaId] = { x = {}, y = {} }
                end

                if not dungeonLocation then
                    for coordIndex = 1, #coords do
                        local coord = coords[coordIndex]
                        -- Increment the length
                        spawnCoordLength = spawnCoordLength + 1
                        -- local index = #spawns[SpawnAreaId].x + 1

                        -- Add the coordinates to the table
                        spawns[SpawnAreaId].x[spawnCoordLength] = coord[1]
                        spawns[SpawnAreaId].y[spawnCoordLength] = coord[2]
                    end
                else
                    for areaId, dungeonCoords in pairs(dungeonLocation) do
                        if spawns[areaId] == nil then
                            spawns[areaId] = { x = {}, y = {} } --, areaId = areaId
                        end
                        for coordIndex = 1, #dungeonCoords.x do
                            -- local x = dungeonCoords.x[coordIndex]
                            -- local y = dungeonCoords.y[coordIndex]
                            -- Increment the length
                            spawnCoordLength = spawnCoordLength + 1
                            -- Add the coordinates to the table
                            spawns[areaId].x[spawnCoordLength] = dungeonCoords.x[coordIndex]
                            spawns[areaId].y[spawnCoordLength] = dungeonCoords.y[coordIndex]
                        end
                    end
                end
            end
            --* Set the processed spawns
            ProcessedSpawns[spawnType][id] = spawns
            return true, spawns
        end
    else
        --* Return cached spawn
        return false, cachedSpawns
    end
    --* No spawns exists
    return nil, nil
end

---@param id NpcId
---@return boolean? expensiveOperation @ True = processed, False = cached, nil = no spawns exists
---@return table<AreaId, {x: MapX[], y: MapY[], waypointIndex: number[]}>? waypoints @ The processed spawns
function SpawnProcessor.GetWaypoints(id)
    if (id == nil or type(id) ~= "number") then
        error("Invalid id: " .. id)
    end
    -- Try to fetch cached spawns
    local cachedWaypoints = ProcessedWaypoints[id]
    if cachedWaypoints == nil then
        -- Fetch spawns
        local rawWaypoints = QuestieDB.QueryNPCSingle(id, "waypoints")
        if rawWaypoints ~= nil then
            ---@type table<AreaId, {x: MapX[], y: MapY[], waypointIndex: number[]}>
            local waypoints = {}
            for zoneId, waypointsList in pairs(rawWaypoints) do
                local UiMapId = ZoneDB:GetUiMapIdByAreaId(zoneId)
                local lastPos
                if waypoints[zoneId] == nil then
                    waypoints[zoneId] = { x = {}, y = {}, waypointIndex = {} }
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
                            waypoints[zoneId].x[#waypoints[zoneId].x + 1] = lastPos.x
                            waypoints[zoneId].y[#waypoints[zoneId].y + 1] = lastPos.y
                            waypoints[zoneId].x[#waypoints[zoneId].x + 1] = point.x
                            waypoints[zoneId].y[#waypoints[zoneId].y + 1] = point.y
                            waypoints[zoneId].waypointIndex[#waypoints[zoneId].waypointIndex + 1] = waypointListIndex
                            waypoints[zoneId].waypointIndex[#waypoints[zoneId].waypointIndex + 1] = waypointListIndex
                            lastPos = point;
                        end
                    end

                    if (lastPos and lastPos ~= points[1]) then
                        local firstPoint = points[1]
                        if MapCoodinates.Maps[UiMapId] then
                            local x1, y1 = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(lastPos.x, lastPos.y)
                            local x2, y2 = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(firstPoint.x, firstPoint.y)

                            local sqDistance = sqrt(SquaredDistanceBetweenPoints(x1, y1, x2, y2))
                            --We get TexCoords error if the disatnce is to low!
                            if (sqDistance > 0.05 and sqDistance < 0.2) then
                                waypoints[zoneId].x[#waypoints[zoneId].x + 1] = lastPos.x
                                waypoints[zoneId].y[#waypoints[zoneId].y + 1] = lastPos.y
                                waypoints[zoneId].x[#waypoints[zoneId].x + 1] = firstPoint.x
                                waypoints[zoneId].y[#waypoints[zoneId].y + 1] = firstPoint.y
                                waypoints[zoneId].waypointIndex[#waypoints[zoneId].waypointIndex + 1] = waypointListIndex
                                waypoints[zoneId].waypointIndex[#waypoints[zoneId].waypointIndex + 1] = waypointListIndex
                            end
                        end
                    end
                end
            end
            --* Set the processed waypoints
            ProcessedWaypoints[id] = waypoints
            return true, waypoints
        end
    else
        --* Return cached spawn
        return false, cachedWaypoints
    end
    --* No spawns exists
    return nil, nil
end
