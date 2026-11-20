---Planar geometry shared by Questie's map overlays: NPC waypoint paths and objective areas.
---Pure functions over points with named x/y fields, in whatever units the caller uses. Nothing
---here reads the client, keeps state or yields. A function belongs here once two overlays use it;
---geometry one overlay needs stays in WaypointGeometry or PolygonGeometry.
---@class MapGeometry
local MapGeometry = QuestieLoader:CreateModule("MapGeometry")

---A point in the caller's units: map percent, canvas units, minimap units or world yards.
---@class MapPoint
---@field x number
---@field y number

---Drops the points of a polyline lying within tolerance of the segment between the points kept
---around them (Ramer-Douglas-Peucker). Distances are to that segment, not its infinite line, so a
---point where the line turns back along itself stays. Ends are kept, so a polyline returning to its
---first point stays closed; there the closing segment has no length, so the first point kept is the
---one farthest from the start. Distances are Euclidean in the points' units: where the tolerance
---must mean the same in every direction, pass units with one scale on both axes.
---@generic P : MapPoint
---@param polyline P[]
---@param tolerance number In the points' units.
---@return P[] points The polyline's own point tables that are kept, in order. Fewer than three points
---return the polyline itself.
function MapGeometry.Simplify(polyline, tolerance)
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
MapGeometry.MITER_LIMIT = 2
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
    if cosHalf * MapGeometry.MITER_LIMIT >= 1 then
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
function MapGeometry.Quads(polyline, halfWidth)
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
