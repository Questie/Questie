---Pure geometry for NPC patrol paths. BuildPolylines turns one zone's waypoint data into
---polylines once per icon, in map percent and world yards. Every redraw then runs Smooth,
---MapGeometry.Simplify and MapGeometry.Quads in the units the caller draws in (WaypointRenderer), and Nearest
---finds the path under the cursor (WaypointMap, WaypointMinimap).
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

-- Patrols

-- Consecutive points closer than this are one point. Patrol data repeats positions, and a segment
-- needs a length well above zero for a stable direction to outline and join it by.
WaypointGeometry.MERGE_YARDS = 0.5

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

-- A patrol running on within this angle at a point runs straight there.
local STRAIGHT_COS = math.cos(math.rad(0.1))

---Drops the points a polyline runs straight on through, keeping its percentages and yards in step.
---QuestieDB splits long segments into evenly spaced points, which line frames once needed for
---their clickable area. Dropping them leaves only real corners, so curves can span whole segments.
---@param points table[] Percentages.
---@param world table[] The same points in yards.
---@return table[] points, table[] world
local function _DropStraightPoints(points, world)
    local keptPoints, keptWorld = {points[1]}, {world[1]}
    for i = 2, #world - 1 do
        local last, point, nextPoint = keptWorld[#keptWorld], world[i], world[i + 1]
        local inX, inY = point.x - last.x, point.y - last.y
        local outX, outY = nextPoint.x - point.x, nextPoint.y - point.y
        local lengths = math.sqrt((inX * inX + inY * inY) * (outX * outX + outY * outY))
        if inX * outX + inY * outY < STRAIGHT_COS * lengths then
            keptPoints[#keptPoints + 1], keptWorld[#keptWorld + 1] = points[i], point
        end
    end
    keptPoints[#keptPoints + 1], keptWorld[#keptWorld + 1] = points[#points], world[#world]
    return keptPoints, keptWorld
end

---Builds the drawable polylines of one zone's waypoint data. Each patrol keeps its own
---polyline and is drawn as given: open unless the data repeats its first point. Points it runs
---straight on through are dropped.
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
            points, world = _DropStraightPoints(points, world)
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

-- Smoothing
-- Each corner becomes a quadratic Bezier curve from a point on its incoming segment, with the corner
-- as control point, to a point on its outgoing one. The curve is tangent to both segments, so the
-- path turns without a kink. NPCs walk through their patrol points, so a curve may pass only so far
-- from its corner: with unit directions in and out, the curve's middle lies cut * |out - in| / 4
-- from the corner, where cut is how far back along each segment it starts. One tolerance gives
-- gentle bends long curves and sharper turns tighter ones, until a curve is too tight for the line
-- to follow: past about 90 degrees at a tolerance of half the half width.

-- A curve is split into an even number of pieces, so its middle, nearest the corner, is drawn.
-- With n pieces the chords stray at most 1 / n² of the curve's distance from its corner.
local MAX_CURVE_PIECES = 8

---The points replacing corner p between a and b, or nil to keep it sharp.
---@return table[]?
local function _Curve(a, p, b, tolerance, halfWidth)
    local inX, inY = p.x - a.x, p.y - a.y
    local outX, outY = b.x - p.x, b.y - p.y
    local inLength = math.sqrt(inX * inX + inY * inY)
    local outLength = math.sqrt(outX * outX + outY * outY)
    inX, inY, outX, outY = inX / inLength, inY / inLength, outX / outLength, outY / outLength
    -- |out - in| is 2 sin(turn / 2): zero running straight on.
    local bend = math.sqrt((outX - inX) ^ 2 + (outY - inY) ^ 2)
    if bend < 1e-9 then return nil end
    -- Taking at most half of each segment leaves the other half to the next corner's curve.
    local cut = math.min(4 * tolerance / bend, inLength / 2, outLength / 2)
    -- A curve this short hides inside the line's own join.
    if cut < halfWidth / 2 then return nil end
    -- The curve is tightest in its middle, with radius cut * cos²(turn / 2) / sin(turn / 2). A line
    -- cannot follow a curve tighter than its half width: its inner edge folds over itself, and the
    -- pieces overlap and draw darker. The miter join draws such a corner cleanly.
    if cut * (1 + inX * outX + inY * outY) / bend < halfWidth then return nil end

    local startX, startY = p.x - inX * cut, p.y - inY * cut
    local endX, endY = p.x + outX * cut, p.y + outY * cut
    -- The fewest pieces whose chords stay within an eighth of the half width of the curve: 2 while it
    -- passes within half the half width of its corner. Two chords for every curve saved a quarter of
    -- the segments zoomed in, but drew gentle curves visibly jaggier.
    local deviation = cut * bend / 4
    local pieces = 2 * math.max(1, math.min(MAX_CURVE_PIECES / 2, math.ceil(math.sqrt(2 * deviation / halfWidth) - 1e-9)))
    local curve = {}
    for i = 0, pieces do
        local s = i / pieces
        local startWeight, controlWeight, endWeight = (1 - s) * (1 - s), 2 * s * (1 - s), s * s
        curve[i + 1] = {x = startWeight * startX + controlWeight * p.x + endWeight * endX,
            y = startWeight * startY + controlWeight * p.y + endWeight * endY}
    end
    return curve
end

---Rounds a polyline's corners for drawing, passing each corner at most tolerance away. Ends stay
---where they are, and a closed polyline stays closed: its curve where it returns to its start is
---drawn last, and drawing starts where that curve ends. Repeated points are skipped.
---@param polyline table[] Points with named x/y fields.
---@param tolerance number
---@param halfWidth number Half the width the line is drawn at, soft edges included. A corner whose
---curve is tighter than this, or would hide inside the line's join, stays sharp.
---@return table[] points The polyline's own points where it stays sharp, new ones along curves.
function WaypointGeometry.Smooth(polyline, tolerance, halfWidth)
    local points = {}
    for _, point in ipairs(polyline) do
        local last = points[#points]
        if not last or last.x ~= point.x or last.y ~= point.y then points[#points + 1] = point end
    end
    local count = #points
    if count < 3 then return points end
    local closed = count >= 4 and points[1].x == points[count].x and points[1].y == points[count].y

    -- Curves meeting in a segment's middle each end there, up to rounding. Points this close are one
    -- point, so no sliver segment, whose direction rounding decides, joins them.
    local sameSq = (halfWidth * 1e-3) ^ 2
    local smoothed = {}
    local function _Add(point)
        local last = smoothed[#smoothed]
        if not last or (point.x - last.x) ^ 2 + (point.y - last.y) ^ 2 > sameSq then smoothed[#smoothed + 1] = point end
    end
    local function _AddCorner(curve, point)
        if not curve then return _Add(point) end
        for _, curvePoint in ipairs(curve) do _Add(curvePoint) end
    end

    local seam = closed and _Curve(points[count - 1], points[1], points[2], tolerance, halfWidth)
    _Add(seam and seam[#seam] or points[1])
    for i = 2, count - 1 do
        _AddCorner(_Curve(points[i - 1], points[i], points[i + 1], tolerance, halfWidth), points[i])
    end
    _AddCorner(seam, points[count])
    return smoothed
end

-- Hover

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
