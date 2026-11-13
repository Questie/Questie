---Orders overlapping outlines smaller on top, so an area inside a larger one shows in its own color:
---with translucent fills, the one drawn last shows most, and the smaller area's border stays above the
---larger fill. Frame levels are the only draw order between frames, so each outline gets one. Which
---levels each map offers is in docs/map-frame-levels.md.
---
---Blend modes cannot do this. ADD and MOD look the same in either order, but they combine both colors,
---ADD brighter and MOD darker, so neither area shows its own; ALPHAKEY and DISABLE act only on a
---texture's own alpha, and fills are solid white.
---
---The renderer stacks every publication anew. Westfall with every accepted quest shown, 108 areas, took
---about half a millisecond and 6 levels, measured before grazes were left out.
---@class PolygonStacking
local PolygonStacking = QuestieLoader:CreateModule("PolygonStacking")

-- An overlap less deep than this share of the smaller outline's size, the square root of its area, is a
-- graze and doesn't stack: neighbours' smoothed outlines can bulge slightly into each other, and levels
-- spent on overlaps too thin to see would leave fewer for areas inside others. It is about a pixel for
-- an area a twentieth of the world map wide.
local GRAZE = 0.02

---@class PolygonStackingOutline
---@field points table[]
---@field bounds number[] {minX, minY, maxX, maxY}
---@field area number
---@field orientation number 1 or -1, the sign of the outline's area by the shoelace formula, which turns each edge's normal outward.
---@field index number Its place among the outlines given.

---@param points table[]
---@return PolygonStackingOutline
local function _Measure(points)
    local doubled, previous = 0, points[#points]
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    for _, point in ipairs(points) do
        doubled = doubled + previous.x * point.y - point.x * previous.y
        minX, minY = math.min(minX, point.x), math.min(minY, point.y)
        maxX, maxY = math.max(maxX, point.x), math.max(maxY, point.y)
        previous = point
    end
    return {points = points, bounds = {minX, minY, maxX, maxY}, area = math.abs(doubled) / 2,
        orientation = doubled < 0 and -1 or 1}
end

---Whether an edge of the outline has all of the other outline on its outer side, or less than the
---tolerance inside it.
---@param outline PolygonStackingOutline
---@param other PolygonStackingOutline
---@param tolerance number In the outlines' units.
---@return boolean
local function _EdgeSeparates(outline, other, tolerance)
    local points, orientation = outline.points, outline.orientation
    local previous = points[#points]
    for _, point in ipairs(points) do
        local normalX, normalY = (point.y - previous.y) * orientation, (previous.x - point.x) * orientation
        -- A repeated point has no edge.
        if normalX ~= 0 or normalY ~= 0 then
            -- The normal is as long as its edge, so the tolerance scales with it.
            local edge = point.x * normalX + point.y * normalY - tolerance * math.sqrt(normalX * normalX + normalY * normalY)
            local separated = true
            for _, vertex in ipairs(other.points) do
                if vertex.x * normalX + vertex.y * normalY < edge then
                    separated = false
                    break
                end
            end
            if separated then return true end
        end
        previous = point
    end
    return false
end

---Whether the smaller outline overlaps the larger more than it grazes it: convex outlines overlap
---unless an edge of one separates them.
---@param smaller PolygonStackingOutline
---@param larger PolygonStackingOutline
---@return boolean
local function _Overlap(smaller, larger)
    local bounds, largerBounds = smaller.bounds, larger.bounds
    if not (bounds[1] < largerBounds[3] and largerBounds[1] < bounds[3] and bounds[2] < largerBounds[4]
        and largerBounds[2] < bounds[4]) then
        return false
    end
    local tolerance = GRAZE * math.sqrt(smaller.area)
    return not _EdgeSeparates(smaller, larger, tolerance) and not _EdgeSeparates(larger, smaller, tolerance)
end

---Each outline's level in the range: one above the highest larger outline it overlaps, or firstLevel
---when it overlaps nothing larger. A stack deeper than the range shares lastLevel. Outlines of equal
---size never stack: neither is inside the other.
---@param outlines table[][] Convex outlines, each its ordered {x, y} points, in one unit for all.
---@param firstLevel number
---@param lastLevel number
---@return number[] levels By the outlines' order.
function PolygonStacking.Levels(outlines, firstLevel, lastLevel)
    local measured = {}
    for i, points in ipairs(outlines) do
        measured[i] = _Measure(points)
        measured[i].index = i
    end
    table.sort(measured, function(a, b) return a.area > b.area end)
    local levels = {}
    for i, outline in ipairs(measured) do
        local level = firstLevel
        for j = 1, i - 1 do
            local larger = measured[j]
            -- Cheap tests first: most outlines are no larger, already below the level found, or far away.
            local largerLevel = levels[larger.index]
            if larger.area > outline.area and largerLevel >= level and _Overlap(outline, larger) then
                level = largerLevel + 1
            end
        end
        levels[outline.index] = math.min(level, lastLevel)
    end
    return levels
end
