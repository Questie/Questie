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

-- Line outlines
-- Consecutive segments meet on the line halving their angle (a miter join): the outer edges extend
-- and the inner edges shorten to the same two points, so joins neither gap nor overlap.

-- A sharp turn's outer corner stays within this many half widths of its point, so the outline
-- tapers there instead of spiking. 2 keeps turns up to 120 degrees exact.
WaypointGeometry.MITER_LIMIT = 2
-- Turning back on itself has no bisector to join on; such segments keep square ends.
local MIN_JOIN_COS = 1e-3

---Unit directions and lengths of a polyline's segments, which all have a length.
---@param points table[]
---@return number[] dirX, number[] dirY, number[] lengths
local function _Directions(points)
    local dirX, dirY, lengths = {}, {}, {}
    for i = 1, #points - 1 do
        local dx, dy = points[i + 1].x - points[i].x, points[i + 1].y - points[i].y
        local length = math.sqrt(dx * dx + dy * dy)
        dirX[i], dirY[i], lengths[i] = dx / length, dy / length, length
    end
    return dirX, dirY, lengths
end

---Left and right outline corners where segment a ends and segment b starts, at point p. Left is
---the side of a segment's normal (-dy, dx).
---The outer corner is shared on the bisector. Each inner corner stays on its own segment's inner
---edge, pulled back from p to where the two inner edges cross. Keeping every corner on its edge or
---past its end keeps each quad convex, which the client's fixed split into two triangles needs.
---@return number aLeftX, number aLeftY, number aRightX, number aRightY, number bLeftX, number bLeftY, number bRightX, number bRightY
local function _Join(p, a, b, dirX, dirY, lengths, halfWidth)
    local aNormalX, aNormalY = -dirY[a], dirX[a]
    local bNormalX, bNormalY = -dirY[b], dirX[b]
    local bisectorX, bisectorY = aNormalX + bNormalX, aNormalY + bNormalY
    -- Two unit normals at angle t add up to a length of 2 cos(t / 2).
    local bisectorLength = math.sqrt(bisectorX * bisectorX + bisectorY * bisectorY)
    local cosHalf = bisectorLength / 2
    if cosHalf < MIN_JOIN_COS then
        local ax, ay, bx, by = aNormalX * halfWidth, aNormalY * halfWidth, bNormalX * halfWidth, bNormalY * halfWidth
        return p.x + ax, p.y + ay, p.x - ax, p.y - ay, p.x + bx, p.y + by, p.x - bx, p.y - by
    end
    bisectorX, bisectorY = bisectorX / bisectorLength, bisectorY / bisectorLength
    local sinHalf = math.sqrt(math.max(0, 1 - cosHalf * cosHalf))
    -- The polyline turns towards its inner side: where the outgoing direction leaves the incoming one.
    local turnsLeft = bisectorX * (dirX[b] - dirX[a]) + bisectorY * (dirY[b] - dirY[a]) > 0
    local outerSide = turnsLeft and -1 or 1

    local outer = outerSide * math.min(halfWidth / cosHalf, WaypointGeometry.MITER_LIMIT * halfWidth)
    local outerX, outerY = p.x + bisectorX * outer, p.y + bisectorY * outer
    -- The inner edges cross halfWidth * tan(t / 2) before p. Past half the shorter segment, the other
    -- end's join could need the same stretch of edge; there the segments overlap a little instead.
    local pullBack = math.min(halfWidth * sinHalf / cosHalf, math.min(lengths[a], lengths[b]) / 2)
    local inner = -outerSide * halfWidth
    local aInnerX, aInnerY = p.x - dirX[a] * pullBack + aNormalX * inner, p.y - dirY[a] * pullBack + aNormalY * inner
    local bInnerX, bInnerY = p.x + dirX[b] * pullBack + bNormalX * inner, p.y + dirY[b] * pullBack + bNormalY * inner
    if turnsLeft then
        return aInnerX, aInnerY, outerX, outerY, bInnerX, bInnerY, outerX, outerY
    end
    return outerX, outerY, aInnerX, aInnerY, outerX, outerY, bInnerX, bInnerY
end

---Outline quads of a polyline drawn halfWidth to each side, mitered where segments meet. A
---polyline returning to its first point is closed and joins there too. Repeated points are
---skipped; a polyline without length has no quads.
---@param polyline table[] Points with named x/y fields.
---@param halfWidth number
---@return number[][] quads One per segment: start left x/y, start right x/y, end left x/y, end right x/y.
function WaypointGeometry.Quads(polyline, halfWidth)
    local points = {}
    for _, point in ipairs(polyline) do
        local last = points[#points]
        if not last or last.x ~= point.x or last.y ~= point.y then points[#points + 1] = point end
    end
    local count = #points - 1
    if count < 1 then return {} end
    local dirX, dirY, lengths = _Directions(points)
    local first, last = points[1], points[#points]
    local closed = count >= 3 and first.x == last.x and first.y == last.y
    local quads = {}
    for k = 1, count do quads[k] = {} end

    for i = 1, #points do
        local quadIn, quadOut = quads[i - 1], quads[i]
        local a, b = i - 1, i
        if i == 1 and closed then
            a, quadIn = count, quads[count]
        end
        if a >= 1 and b <= count then
            quadIn[5], quadIn[6], quadIn[7], quadIn[8], quadOut[1], quadOut[2], quadOut[3], quadOut[4] =
                _Join(points[i], a, b, dirX, dirY, lengths, halfWidth)
        elseif not (i == #points and closed) then
            -- Open ends are square.
            local k = quadOut and b or a
            local normalX, normalY = -dirY[k] * halfWidth, dirX[k] * halfWidth
            local p, quad, offset = points[i], quads[k], quadOut and 0 or 4
            quad[offset + 1], quad[offset + 2] = p.x + normalX, p.y + normalY
            quad[offset + 3], quad[offset + 4] = p.x - normalX, p.y - normalY
        end
    end
    return quads
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
