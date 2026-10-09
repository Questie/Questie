---@class WaypointGeometry
local WaypointGeometry = QuestieLoader:CreateModule("WaypointGeometry")

---@class WaypointPoint
---@field x number Map percentage, 0-100.
---@field y number

---@class WaypointWorldPoint
---@field x number HereBeDragons world yards.
---@field y number

---One drawn polyline on its owning map: an NPC's patrol, or one part of it.
---@class WaypointPolyline
---@field uiMapId number
---@field instanceId number
---@field points WaypointPoint[] Owning-map percentages, at least two.
---@field world WaypointWorldPoint[] The same points in world yards.
---@field worldBounds number[] {minX, minY, maxX, maxY} in world yards.

---Converts map percentages to world yards; HereBeDragons' GetWorldCoordinatesFromZone in 0-1 units.
---@alias WaypointToWorld fun(x: number, y: number, uiMapId: number): number?, number?, number?

---Converts world yards to map fractions (0-1) of the destination map, out of bounds allowed.
---@alias WaypointToMap fun(worldX: number, worldY: number, uiMapId: number): number?, number?

-- Consecutive points closer than this are one point. Patrol data repeats positions, and
-- DrawLine needs a length well above zero to compute its texture coordinates.
WaypointGeometry.MERGE_YARDS = 0.5

-- Capitals keep their paths to themselves: their patrols are long and dense, and a city is a small
-- corner of its zone's map, so projected city paths would only clutter. Neighbouring zones' paths
-- are not drawn onto a capital either.
WaypointGeometry.CAPITAL_MAPS = {
    [1453] = true, -- Stormwind City
    [1454] = true, -- Orgrimmar
    [1455] = true, -- Ironforge
    [1456] = true, -- Thunder Bluff
    [1457] = true, -- Darnassus
    [1458] = true, -- Undercity
    [1947] = true, -- The Exodar
    [1954] = true, -- Silvermoon City
    [1955] = true, -- Shattrath City
    [125] = true, -- Dalaran
    [126] = true, -- Dalaran, The Underbelly
}

local function _IsFinite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

---@param points table[] Named x/y fields.
---@return number[] bounds {minX, minY, maxX, maxY}
function WaypointGeometry.Bounds(points)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    for _, point in ipairs(points) do
        minX, minY = math.min(minX, point.x), math.min(minY, point.y)
        maxX, maxY = math.max(maxX, point.x), math.max(maxY, point.y)
    end
    return {minX, minY, maxX, maxY}
end

---Builds the drawable polylines of one zone's waypoint data. Each patrol keeps its own
---polyline and is drawn as given: open unless the data repeats its first point.
---Points without a world position, such as the {-1, -1} instance marker, split a patrol where
---they occur, so no segment bridges a gap in the data.
---@param patrols CoordPair[][] One zone's waypoints, {{{x, y}, ...}, ...} in percentages.
---@param uiMapId number
---@param toWorld WaypointToWorld
---@return WaypointPolyline[]
function WaypointGeometry.BuildPolylines(patrols, uiMapId, toWorld)
    local polylines = {}
    local mergeSq = WaypointGeometry.MERGE_YARDS * WaypointGeometry.MERGE_YARDS
    local points, world, instanceId

    local function _Finish()
        if points and #points >= 2 then
            polylines[#polylines + 1] = {uiMapId = uiMapId, instanceId = instanceId, points = points, world = world,
                worldBounds = WaypointGeometry.Bounds(world)}
        end
        points, world, instanceId = nil, nil, nil
    end

    for _, patrol in ipairs(patrols) do
        for _, coords in ipairs(patrol) do
            local x, y = coords[1], coords[2]
            local worldX, worldY, instance
            if _IsFinite(x) and _IsFinite(y) and x >= 0 and y >= 0 then
                worldX, worldY, instance = toWorld(x / 100, y / 100, uiMapId)
            end
            if not (_IsFinite(worldX) and _IsFinite(worldY) and instance) or (instanceId and instance ~= instanceId) then
                _Finish()
            else
                local last = world and world[#world]
                if not last or (worldX - last.x) ^ 2 + (worldY - last.y) ^ 2 >= mergeSq then
                    if not points then points, world, instanceId = {}, {}, instance end
                    points[#points + 1] = {x = x, y = y}
                    world[#world + 1] = {x = worldX, y = worldY}
                end
            end
        end
        _Finish()
    end
    return polylines
end

---Whether a polyline owned by sourceMapId may be drawn on destinationMapId other than its own.
---@param sourceMapId number
---@param destinationMapId number
---@return boolean
function WaypointGeometry.CanProject(sourceMapId, destinationMapId)
    local capitals = WaypointGeometry.CAPITAL_MAPS
    return sourceMapId ~= destinationMapId and not capitals[sourceMapId] and not capitals[destinationMapId]
end

---Projects a polyline onto a neighbouring map. Vertices outside the destination stay intact for
---the canvas to clip; nil when any vertex has no position there or no part reaches the map.
---@param polyline WaypointPolyline
---@param destinationMapId number
---@param toMap WaypointToMap
---@return WaypointPoint[]?
function WaypointGeometry.Project(polyline, destinationMapId, toMap)
    local projected = {}
    for i, point in ipairs(polyline.world) do
        local x, y = toMap(point.x, point.y, destinationMapId)
        if not (_IsFinite(x) and _IsFinite(y)) then return nil end
        projected[i] = {x = x * 100, y = y * 100}
    end
    local bounds = WaypointGeometry.Bounds(projected)
    if bounds[3] < 0 or bounds[1] > 100 or bounds[4] < 0 or bounds[2] > 100 then return nil end
    return projected
end

---Squared distance from (px, py) to the segment (sx, sy)-(ex, ey). Zero-length segments are
---points, so the hover area of any polyline is round at its joins and ends.
---@return number
function WaypointGeometry.SegmentDistanceSq(px, py, sx, sy, ex, ey)
    local dx, dy = ex - sx, ey - sy
    local lengthSq = dx * dx + dy * dy
    local t = 0
    if lengthSq > 0 then
        t = math.max(0, math.min(1, ((px - sx) * dx + (py - sy) * dy) / lengthSq))
    end
    local qx, qy = sx + t * dx - px, sy + t * dy - py
    return qx * qx + qy * qy
end

---A hover candidate: a polyline in the caller's units, such as canvas pixels.
---@class WaypointHitTarget
---@field points table[] Named x/y fields.
---@field bounds number[] {minX, minY, maxX, maxY} of points.

---Finds the target nearest to the cursor among those within radius of it. The hover area is
---each polyline fattened by radius in every direction; the nearest wins where areas overlap.
---@generic T : WaypointHitTarget
---@param targets T[]
---@param x number Cursor, in the targets' units.
---@param y number
---@param radius number
---@return T?
function WaypointGeometry.Nearest(targets, x, y, radius)
    local nearest, nearestSq = nil, radius * radius
    for _, target in ipairs(targets) do
        local bounds = target.bounds
        -- The fattened bounding box rejects most targets before any segment is measured.
        if x >= bounds[1] - radius and x <= bounds[3] + radius and y >= bounds[2] - radius and y <= bounds[4] + radius then
            local points = target.points
            for i = 2, #points do
                local a, b = points[i - 1], points[i]
                local distanceSq = WaypointGeometry.SegmentDistanceSq(x, y, a.x, a.y, b.x, b.y)
                if distanceSq <= nearestSq then
                    nearest, nearestSq = target, distanceSq
                end
            end
        end
    end
    return nearest
end
