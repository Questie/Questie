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
