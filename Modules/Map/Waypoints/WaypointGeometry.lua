---Pure geometry for NPC patrol paths. BuildPolylines turns one zone's waypoint data into
---polylines once per icon, in map percent and world yards. Every redraw then runs Smooth, Trim and
---Quads in the units the caller draws in (WaypointRenderer), and Nearest finds the path under the
---cursor (WaypointMap, WaypointMinimap).
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

-- Line outlines
-- Consecutive segments meet on the line halving their angle (a miter join): the outer edges extend
-- and the inner edges shorten to the same two points, so joins neither gap nor overlap.
-- At a sharp turn the miter would spike far past its point. There the inner edges still meet as a
-- miter, but the outer edges end square at the point and a round cap covers the outside:
-- - Each segment then ends on the line from its inner corner to its outer one, which misses the
--   point. A fill, the triangle between those two corners and the point, completes the segment.
-- - The cap holds the outside's sector of a disc around the point, between the two outer ends.
-- Open ends are square, and a half disc caps each beyond its point.

-- A turn whose miter would reach further than this many half widths from its point is sharp: 2
-- makes every turn past 120 degrees sharp.
WaypointGeometry.MITER_LIMIT = 2
-- A cap's corners lie this many half widths from its point, so its kite holds up to a half disc.
local CAP_REACH = math.sqrt(2)
-- Turning back on itself has no bisector to join on; such segments keep square ends, and a cap
-- rounds them.
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

---The cap of a sharp turn at p: a kite from p out along both outer ends and the outward direction.
---Its sides along the outer ends meet the segments there, so it covers only the outside of the turn.
---@param aOuterX number Unit normal of segment a towards the outside, then b's, and the outward
---direction between them. A turn back or an open end gives one normal both ways, and the
---direction out past p.
---@return number[] cap p as start left, then start right, end left and end right, going around the
---same way as a segment quad's start left, end left, end right and start right.
local function _Cap(p, aOuterX, aOuterY, bOuterX, bOuterY, outwardX, outwardY, halfWidth)
    if aOuterX * outwardY - aOuterY * outwardX > 0 then
        aOuterX, aOuterY, bOuterX, bOuterY = bOuterX, bOuterY, aOuterX, aOuterY
    end
    local reach = CAP_REACH * halfWidth
    return {p.x, p.y, p.x + bOuterX * reach, p.y + bOuterY * reach, p.x + aOuterX * reach, p.y + aOuterY * reach,
        p.x + outwardX * reach, p.y + outwardY * reach}
end

---Left and right outline corners where segment a ends and segment b starts, at point p. Left is
---the side of a segment's normal (-dy, dx).
---Each inner corner stays on its own segment's inner edge, pulled back from p to where the two
---inner edges cross. The outer corner is shared on the bisector, or at a sharp turn each outer edge
---ends square at p, and the turn's fills and cap are added. Keeping every corner on its edge or
---past its end keeps each quad convex, which the client's fixed split into two triangles needs.
---@param fills number[][] Gets a sharp turn's fills: start left, start right, then p twice.
---@param caps number[][] Gets the cap of a sharp turn or of a turn back.
---@return number aLeftX, number aLeftY, number aRightX, number aRightY, number bLeftX, number bLeftY, number bRightX, number bRightY
local function _Join(p, a, b, dirX, dirY, lengths, halfWidth, fills, caps)
    local aNormalX, aNormalY = -dirY[a], dirX[a]
    local bNormalX, bNormalY = -dirY[b], dirX[b]
    local bisectorX, bisectorY = aNormalX + bNormalX, aNormalY + bNormalY
    -- Two unit normals at angle t add up to a length of 2 cos(t / 2).
    local bisectorLength = math.sqrt(bisectorX * bisectorX + bisectorY * bisectorY)
    local cosHalf = bisectorLength / 2
    if cosHalf < MIN_JOIN_COS then
        local ax, ay, bx, by = aNormalX * halfWidth, aNormalY * halfWidth, bNormalX * halfWidth, bNormalY * halfWidth
        -- An exact half disc. b's own normal can be a fraction of a degree off a's opposite, which
        -- would bend the kite past straight at p.
        caps[#caps + 1] = _Cap(p, aNormalX, aNormalY, -aNormalX, -aNormalY, dirX[a], dirY[a], halfWidth)
        return p.x + ax, p.y + ay, p.x - ax, p.y - ay, p.x + bx, p.y + by, p.x - bx, p.y - by
    end
    bisectorX, bisectorY = bisectorX / bisectorLength, bisectorY / bisectorLength
    local sinHalf = math.sqrt(math.max(0, 1 - cosHalf * cosHalf))
    -- The polyline turns towards its inner side: where the outgoing direction leaves the incoming one.
    local turnsLeft = bisectorX * (dirX[b] - dirX[a]) + bisectorY * (dirY[b] - dirY[a]) > 0
    local outerSide = turnsLeft and -1 or 1

    -- The inner edges cross halfWidth * tan(t / 2) before p. Past half the shorter segment, the other
    -- end's join could need the same stretch of edge; there the segments overlap a little instead.
    local pullBack = math.min(halfWidth * sinHalf / cosHalf, math.min(lengths[a], lengths[b]) / 2)
    local inner = -outerSide * halfWidth
    local aInnerX, aInnerY = p.x - dirX[a] * pullBack + aNormalX * inner, p.y - dirY[a] * pullBack + aNormalY * inner
    local bInnerX, bInnerY = p.x + dirX[b] * pullBack + bNormalX * inner, p.y + dirY[b] * pullBack + bNormalY * inner
    if cosHalf * WaypointGeometry.MITER_LIMIT >= 1 then
        local outer = outerSide * halfWidth / cosHalf
        local outerX, outerY = p.x + bisectorX * outer, p.y + bisectorY * outer
        if turnsLeft then
            return aInnerX, aInnerY, outerX, outerY, bInnerX, bInnerY, outerX, outerY
        end
        return outerX, outerY, aInnerX, aInnerY, outerX, outerY, bInnerX, bInnerY
    end

    local aOuterX, aOuterY = p.x - aNormalX * inner, p.y - aNormalY * inner
    local bOuterX, bOuterY = p.x - bNormalX * inner, p.y - bNormalY * inner
    caps[#caps + 1] = _Cap(p, aNormalX * outerSide, aNormalY * outerSide, bNormalX * outerSide, bNormalY * outerSide,
        bisectorX * outerSide, bisectorY * outerSide, halfWidth)
    -- Fills run from a segment's end corners to p; segment b's runs backwards, so its sides swap.
    if turnsLeft then
        fills[#fills + 1] = {aInnerX, aInnerY, aOuterX, aOuterY, p.x, p.y, p.x, p.y}
        fills[#fills + 1] = {bOuterX, bOuterY, bInnerX, bInnerY, p.x, p.y, p.x, p.y}
        return aInnerX, aInnerY, aOuterX, aOuterY, bInnerX, bInnerY, bOuterX, bOuterY
    end
    fills[#fills + 1] = {aOuterX, aOuterY, aInnerX, aInnerY, p.x, p.y, p.x, p.y}
    fills[#fills + 1] = {bInnerX, bInnerY, bOuterX, bOuterY, p.x, p.y, p.x, p.y}
    return aOuterX, aOuterY, aInnerX, aInnerY, bOuterX, bOuterY, bInnerX, bInnerY
end

---Outline quads of a polyline drawn halfWidth to each side, mitered where segments meet. A
---polyline returning to its first point is closed and joins there too. Repeated points are
---skipped; a polyline without length has no quads.
---@param polyline table[] Points with named x/y fields.
---@param halfWidth number
---@return number[][] quads One per segment: start left x/y, start right x/y, end left x/y, end right x/y.
---@return number[][] fills Two per sharp turn, in the same layout: the triangle from a segment's end
---corners at the turn to its point, whose end corners are both the point. Drawn with the line's rows.
---@return number[][] caps One per sharp turn, turn back or open end, in the same layout: a kite whose
---start left corner is the point and whose others lie √2 half widths from it. Drawn with a disc of
---halfWidth radius around the point.
function WaypointGeometry.Quads(polyline, halfWidth)
    local points = {}
    for _, point in ipairs(polyline) do
        local last = points[#points]
        if not last or last.x ~= point.x or last.y ~= point.y then points[#points + 1] = point end
    end
    local count = #points - 1
    if count < 1 then return {}, {}, {} end
    local dirX, dirY, lengths = _Directions(points)
    local first, last = points[1], points[#points]
    local closed = count >= 3 and first.x == last.x and first.y == last.y
    local quads, fills, caps = {}, {}, {}
    for k = 1, count do quads[k] = {} end

    for i = 1, #points do
        local quadIn, quadOut = quads[i - 1], quads[i]
        local a, b = i - 1, i
        if i == 1 and closed then
            a, quadIn = count, quads[count]
        end
        if a >= 1 and b <= count then
            quadIn[5], quadIn[6], quadIn[7], quadIn[8], quadOut[1], quadOut[2], quadOut[3], quadOut[4] =
                _Join(points[i], a, b, dirX, dirY, lengths, halfWidth, fills, caps)
        elseif not (i == #points and closed) then
            -- Open ends are square, with a half disc beyond: out past the start, or on past the end.
            local k = quadOut and b or a
            local unitX, unitY = -dirY[k], dirX[k]
            local normalX, normalY = unitX * halfWidth, unitY * halfWidth
            local outward = quadOut and -1 or 1
            local p, quad, offset = points[i], quads[k], quadOut and 0 or 4
            quad[offset + 1], quad[offset + 2] = p.x + normalX, p.y + normalY
            quad[offset + 3], quad[offset + 4] = p.x - normalX, p.y - normalY
            caps[#caps + 1] = _Cap(p, unitX, unitY, -unitX, -unitY, dirX[k] * outward, dirY[k] * outward, halfWidth)
        end
    end
    return quads, fills, caps
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

-- Trimming

---Drops the points of a polyline lying within tolerance of the segment between the points kept
---around them (Ramer-Douglas-Peucker). Distances are to that segment, not its infinite line, so a
---patrol's turning point stays even where it walks back along itself. Ends are kept, so a closed
---polyline stays closed.
---@param polyline table[] Points with named x/y fields.
---@param tolerance number
---@return table[] points The polyline's own points that are kept.
function WaypointGeometry.Trim(polyline, tolerance)
    local count = #polyline
    if count < 3 then return polyline end
    local toleranceSq = tolerance * tolerance
    local keep = {[1] = true, [count] = true}
    -- Pairs of kept points whose points between are still to check.
    local pending, top = {1, count}, 2
    while top > 0 do
        local first, last = pending[top - 1], pending[top]
        top = top - 2
        local a, b = polyline[first], polyline[last]
        local ax, ay = a.x, a.y
        local dx, dy = b.x - ax, b.y - ay
        local lengthSq = dx * dx + dy * dy
        local farthest, farthestSq = nil, toleranceSq
        -- SegmentDistanceSq, inlined: this is the hottest loop of drawing a path.
        for i = first + 1, last - 1 do
            local point = polyline[i]
            local px, py = point.x - ax, point.y - ay
            local t = 0
            if lengthSq > 0 then
                t = (px * dx + py * dy) / lengthSq
                if t < 0 then t = 0 elseif t > 1 then t = 1 end
            end
            local qx, qy = px - t * dx, py - t * dy
            local distanceSq = qx * qx + qy * qy
            if distanceSq > farthestSq then farthest, farthestSq = i, distanceSq end
        end
        if farthest then
            keep[farthest] = true
            pending[top + 1], pending[top + 2], pending[top + 3], pending[top + 4] = first, farthest, farthest, last
            top = top + 4
        end
    end
    local trimmed = {}
    for i = 1, count do
        if keep[i] then trimmed[#trimmed + 1] = polyline[i] end
    end
    return trimmed
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
