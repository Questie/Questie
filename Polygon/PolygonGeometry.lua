---@class PolygonGeometry
local PolygonGeometry = QuestieLoader:CreateModule("PolygonGeometry")

---@class PolygonSpawnPoint
---@field x number Zone percentage, not normalized map coordinates.
---@field y number
---@field worldX number World units used for clustering distances.
---@field worldY number
---@field uiMapId number
---@field instanceId number Unrelated coordinate spaces never share a cluster.
-- Extra fields are opaque to geometry. Representatives retain the caller's original point.

---@class PolygonCluster
---@field uiMapId number
---@field x number Marker position in zone percentages.
---@field y number
---@field outline table[]? Ordered convex percentage-space outline; nil retains a point-only marker.
---@field representative PolygonSpawnPoint

---@class PolygonWork
---@field count number Operations since this job started; only its modulo matters.
---@field isCancelled (fun(): boolean)?
---@field clock (fun(): number)? Precise seconds; nil leaves only the operation ceiling.

---@class PolygonGeometryOptions
---@field radius number? World units, default 180.
---@field areaCutoff number? Squared zone percentages, default 0.9.
---@field tolerance number? Percentage-space reduction distance, default 0.03.

local CHECK_INTERVAL = 256
local MAX_OPERATIONS_PER_SLICE = 32768
local SLICE_SECONDS = 0.002
local huge, abs = math.huge, math.abs

local function _IsFinite(value)
    return type(value) == "number" and value > -huge and value < huge
end

-- Every objective update runs in its own ThreadLib ticker, and each ticker resumes once per
-- frame. All polygon jobs therefore share one slice per frame rather than spending 2 ms each.
-- GetTime() is fixed for a whole frame, so it only identifies the frame; the precise clock
-- measures work inside it. The operation ceiling also bounds work without a precise clock.
local slice = {frame = nil, startedAt = 0, operations = 0}

---Starts cooperative work that shares this frame's polygon budget with every other job.
---@param isCancelled (fun(): boolean)?
---@return PolygonWork
function PolygonGeometry.NewWork(isCancelled)
    local clock = type(GetTimePreciseSec) == "function" and GetTimePreciseSec or nil
    return {count = 0, isCancelled = isCancelled, clock = clock}
end

-- The first job to check in during a new frame starts that frame's shared slice.
local function _SyncSlice(work)
    local frame = GetTime()
    if frame ~= slice.frame then
        slice.frame, slice.startedAt, slice.operations = frame, work.clock and work.clock() or 0, 0
    end
end

local function _IsSliceSpent(work)
    local elapsed = work.clock and work.clock() - slice.startedAt or 0
    return elapsed >= SLICE_SECONDS or slice.operations >= MAX_OPERATIONS_PER_SLICE
end

---Counts one operation. Every 256 operations it checks cancellation and the shared slice,
---yielding while this frame's 2 ms or operation ceiling is spent. Callers must be coroutines
---resumed at most once per frame, as ThreadLib does; a same-frame drain loop never finishes.
---@async
---@param work PolygonWork
---@return boolean continue False when the job was cancelled.
function PolygonGeometry.Checkpoint(work)
    work.count = work.count + 1
    if work.count % CHECK_INTERVAL ~= 0 then return true end
    if work.isCancelled and work.isCancelled() then return false end
    _SyncSlice(work)
    slice.operations = slice.operations + CHECK_INTERVAL

    -- A job can resume in a frame another job has already spent. Recheck before working,
    -- so each waiting job does not add another 256 operations past the shared budget.
    while _IsSliceSpent(work) do
        coroutine.yield()
        if work.isCancelled and work.isCancelled() then return false end
        _SyncSlice(work)
    end
    return true
end
local _Checkpoint = PolygonGeometry.Checkpoint

-- table.sort cannot yield from its comparator on Lua 5.1. Merge sorting also keeps
-- equal-coordinate representatives stable without writing ordering fields into caller data.
local function _Sort(points, before, work)
    local sorted, buffer = {}, {}
    for i, point in ipairs(points) do
        sorted[i] = point
        if not _Checkpoint(work) then return end
    end
    local span = 1
    while span < #sorted do
        for first = 1, #sorted, span * 2 do
            local middle, last = math.min(first + span, #sorted + 1), math.min(first + span * 2 - 1, #sorted)
            local left, right = first, middle
            for output = first, last do
                if left < middle and (right > last or not before(sorted[right], sorted[left])) then
                    buffer[output], left = sorted[left], left + 1
                else
                    buffer[output], right = sorted[right], right + 1
                end
                if not _Checkpoint(work) then return end
            end
        end
        sorted, buffer = buffer, sorted
        span = span * 2
    end
    return sorted
end

local function _CoordinateBefore(a, b)
    return a.x < b.x or (a.x == b.x and a.y < b.y)
end

local function _SpawnBefore(a, b)
    if a.uiMapId ~= b.uiMapId then return a.uiMapId < b.uiMapId end
    if a.instanceId ~= b.instanceId then return a.instanceId < b.instanceId end
    if a.x ~= b.x then return a.x < b.x end
    if a.y ~= b.y then return a.y < b.y end
    if a.worldX ~= b.worldX then return a.worldX < b.worldX end
    return a.worldY < b.worldY
end

local function _UniqueCoordinates(points, work)
    local sorted = _Sort(points, _CoordinateBefore, work)
    if not sorted then return end
    local unique = {}
    for _, point in ipairs(sorted) do
        local previous = unique[#unique]
        if not previous or point.x ~= previous.x or point.y ~= previous.y then
            unique[#unique + 1] = {x = point.x, y = point.y}
        end
        if not _Checkpoint(work) then return end
    end
    return unique
end

-- Jarvis gift wrapping preserves the original spawn-outline algorithm, with exact
-- deduplication and farthest collinear ties. The unsafe extreme-point prefilter is absent.
local function _GiftWrap(points, work)
    local unique = _UniqueCoordinates(points, work)
    if not unique then return end
    if #unique < 3 then return {} end

    local hull, current = {}, 1
    repeat
        local nextIndex = current % #unique + 1
        local a = unique[current]
        for i, b in ipairs(unique) do
            local c = unique[nextIndex]
            local cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
            if cross < 0 then
                nextIndex = i
            elseif cross == 0 then
                -- Distances only decide collinear ties; keep the farthest endpoint.
                local distance = (b.x - a.x)^2 + (b.y - a.y)^2
                local nextDistance = (c.x - a.x)^2 + (c.y - a.y)^2
                if distance > nextDistance then nextIndex = i end
            end
            if not _Checkpoint(work) then return end
        end
        hull[#hull + 1] = a
        current = nextIndex
        if #hull > #unique then error("Polygon hull did not close") end
    until current == 1
    if #hull < 3 then return {} end
    return hull
end

-- Spline sampling multiplies boundary vertices by ten. Monotone-chain construction
-- gives the same convex envelope without wrapping that larger cloud quadratically.
local function _SplineEnvelope(points, work)
    local unique = _UniqueCoordinates(points, work)
    if not unique then return end
    if #unique < 3 then return {} end
    local hull = {}

    -- Lower chain, from the leftmost point to the rightmost.
    for _, point in ipairs(unique) do
        while #hull >= 2 do
            local a, b = hull[#hull - 1], hull[#hull]
            local cross = (b.x - a.x) * (point.y - a.y) - (b.y - a.y) * (point.x - a.x)
            if cross > 0 then break end
            hull[#hull] = nil
            if not _Checkpoint(work) then return end
        end
        hull[#hull + 1] = point
        if not _Checkpoint(work) then return end
    end

    -- Upper chain, preserving the lower chain's shared rightmost endpoint.
    local upperStart = #hull + 1
    for i = #unique - 1, 1, -1 do
        local point = unique[i]
        while #hull >= upperStart do
            local a, b = hull[#hull - 1], hull[#hull]
            local cross = (b.x - a.x) * (point.y - a.y) - (b.y - a.y) * (point.x - a.x)
            if cross > 0 then break end
            hull[#hull] = nil
            if not _Checkpoint(work) then return end
        end
        hull[#hull + 1] = point
        if not _Checkpoint(work) then return end
    end
    hull[#hull] = nil -- The renderer closes the ring; do not repeat its first vertex.
    if #hull < 3 then return {} end
    return hull
end

-- Periodic Catmull-Rom samples. Including t=0 preserves the original hull vertices;
-- the second hull discards inward spline excursions and leaves a convex fan to render.
local function _SampleSpline(hull, work)
    local samples, count = {}, #hull
    for i = 1, count do
        local a, b = hull[(i - 2) % count + 1], hull[i]
        local c, d = hull[i % count + 1], hull[(i + 1) % count + 1]
        for step = 0, 9 do
            local t = step / 10
            local t2, t3 = t * t, t * t * t
            samples[#samples + 1] = {
                x = 0.5 * (2 * b.x + (c.x - a.x) * t
                    + (2 * a.x - 5 * b.x + 4 * c.x - d.x) * t2
                    + (3 * b.x - a.x - 3 * c.x + d.x) * t3),
                y = 0.5 * (2 * b.y + (c.y - a.y) * t
                    + (2 * a.y - 5 * b.y + 4 * c.y - d.y) * t2
                    + (3 * b.y - a.y - 3 * c.y + d.y) * t3),
            }
            if not _Checkpoint(work) then return end
        end
    end
    return samples
end

local function _SegmentDistanceSquared(point, a, b)
    local dx, dy = b.x - a.x, b.y - a.y
    local length = dx * dx + dy * dy
    local t = length > 0 and ((point.x - a.x) * dx + (point.y - a.y) * dy) / length or 0
    t = math.max(0, math.min(1, t))
    return (point.x - a.x - t * dx)^2 + (point.y - a.y - t * dy)^2
end

-- Reduction reworks the legacy Nathan Shafer Bezier helper's RDP implementation.
-- Copyright (c) 2013 Nathan Shafer. MIT License:
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-- Closed-ring RDP uses two arcs with distinct endpoints. Its explicit stack is bounded
-- by the point count, and distance is to the segment, not half the infinite-line distance.
local function _ReduceOutline(points, tolerance, work)
    local split, farthest = 2, -1
    for i = 2, #points do
        local distance = (points[i].x - points[1].x)^2 + (points[i].y - points[1].y)^2
        if distance > farthest then split, farthest = i, distance end
        if not _Checkpoint(work) then return end
    end
    local closed = {}
    for i, point in ipairs(points) do
        closed[i] = point
        if not _Checkpoint(work) then return end
    end
    closed[#points + 1] = points[1]
    local keep, stack = {[1] = true, [split] = true}, {{1, split}, {split, #closed}}
    local threshold = tolerance * tolerance
    while #stack > 0 do
        local arc = table.remove(stack)
        local first, last, index, maximum = arc[1], arc[2], nil, threshold
        for i = first + 1, last - 1 do
            local distance = _SegmentDistanceSquared(closed[i], closed[first], closed[last])
            if distance > maximum then index, maximum = i, distance end
            if not _Checkpoint(work) then return end
        end
        if index then
            keep[index] = true
            stack[#stack + 1], stack[#stack + 2] = {first, index}, {index, last}
        end
        if not _Checkpoint(work) then return end
    end
    local reduced = {}
    for i, point in ipairs(points) do
        if keep[i] then reduced[#reduced + 1] = point end
        if not _Checkpoint(work) then return end
    end
    -- An excessively large tolerance must not turn a valid area into a two-vertex line.
    return #reduced >= 3 and reduced or points
end

-- Offset by one vertex before the signed-area sums to reduce cancellation from
-- large absolute coordinates; translate the resulting centroid back afterward.
local function _AreaAndCentroid(points, work)
    local origin, twiceArea, sumX, sumY = points[1], 0, 0, 0
    for i, a in ipairs(points) do
        local b = points[i % #points + 1]
        local ax, ay, bx, by = a.x - origin.x, a.y - origin.y, b.x - origin.x, b.y - origin.y
        local cross = ax * by - bx * ay
        twiceArea = twiceArea + cross
        sumX, sumY = sumX + (ax + bx) * cross, sumY + (ay + by) * cross
        if not _Checkpoint(work) then return end
    end
    if twiceArea == 0 then return 0 end
    return abs(twiceArea) / 2, origin.x + sumX / (3 * twiceArea), origin.y + sumY / (3 * twiceArea)
end

---Builds complete cluster geometry without mutating inputs. The caller must run in a
---coroutine, including when the input is small. Cancellation returns nil, never partial data.
---@async
---@param points PolygonSpawnPoint[]
---@param options PolygonGeometryOptions?
---@param isCancelled (fun(): boolean)?
---@return PolygonCluster[]? clusters
function PolygonGeometry.Build(points, options, isCancelled)
    options = options or {}
    local radius = options.radius or 180
    local areaCutoff = options.areaCutoff or 0.9
    local tolerance = options.tolerance or 0.03
    assert(_IsFinite(radius) and radius > 0, "Polygon radius must be positive and finite")
    assert(_IsFinite(areaCutoff) and areaCutoff >= 0, "Polygon area cutoff must be nonnegative and finite")
    assert(_IsFinite(tolerance) and tolerance >= 0, "Polygon tolerance must be nonnegative and finite")
    local work = PolygonGeometry.NewWork(isCancelled)
    if isCancelled and isCancelled() then return end
    for _, point in ipairs(points) do
        assert(_IsFinite(point.x) and _IsFinite(point.y) and _IsFinite(point.worldX) and _IsFinite(point.worldY)
            and _IsFinite(point.uiMapId) and _IsFinite(point.instanceId), "Polygon points require finite coordinates and map identities")
        if not _Checkpoint(work) then return end
    end
    -- Stable seed/admission order is part of the moving-center clustering behavior.
    local sorted = _Sort(points, _SpawnBefore, work)
    if not sorted then return end
    local clusters, touched, radiusSquared = {}, {}, radius * radius

    -- Work within contiguous map/instance partitions. Candidate scans never visit an
    -- unrelated coordinate space, even when many objectives span multiple maps.
    local partitionFirst = 1
    while partitionFirst <= #sorted do
        local partitionLast = partitionFirst
        local firstPoint = sorted[partitionFirst]
        while sorted[partitionLast + 1] and sorted[partitionLast + 1].uiMapId == firstPoint.uiMapId
            and sorted[partitionLast + 1].instanceId == firstPoint.instanceId do
            partitionLast = partitionLast + 1
            if not _Checkpoint(work) then return end
        end

        -- Greedy clustering keeps the historical two passes: mean-centered admission
        -- first, then drift recovery using the mean and bounding-box centers.
        for seedIndex = partitionFirst, partitionLast do
            local seed = sorted[seedIndex]
            if not touched[seedIndex] then
                local members = {seed}
                touched[seedIndex] = true
                local sumX, sumY, worldSumX, worldSumY = seed.x, seed.y, seed.worldX, seed.worldY
                local minX, maxX, minY, maxY = seed.worldX, seed.worldX, seed.worldY, seed.worldY
                local centerX, centerY = seed.worldX, seed.worldY
                for pass = 1, 2 do
                    for index = partitionFirst, partitionLast do
                        local candidate = sorted[index]
                        if not touched[index] then
                            -- Preserve exponentiation: x*x can round differently at the strict radius boundary.
                            local distance = (candidate.worldX - centerX)^2 + (candidate.worldY - centerY)^2
                            if distance < radiusSquared then
                                touched[index] = true
                                members[#members + 1] = candidate
                                sumX, sumY = sumX + candidate.x, sumY + candidate.y
                                worldSumX, worldSumY = worldSumX + candidate.worldX, worldSumY + candidate.worldY
                                minX, maxX = math.min(minX, candidate.worldX), math.max(maxX, candidate.worldX)
                                minY, maxY = math.min(minY, candidate.worldY), math.max(maxY, candidate.worldY)
                                centerX, centerY = worldSumX / #members, worldSumY / #members
                                if pass == 2 then
                                    centerX, centerY = (centerX + (minX + maxX) / 2) / 2, (centerY + (minY + maxY) / 2) / 2
                                end
                            end
                        end
                        if not _Checkpoint(work) then return end
                    end
                end

                local cluster = {uiMapId = seed.uiMapId, x = sumX / #members, y = sumY / #members, representative = seed}
                -- Outlines and markers share clustering, but isolated/collinear/tiny regions
                -- remain useful point markers instead of being discarded by the area cutoff.
                local hull = _GiftWrap(members, work)
                if not hull then return end
                if #hull >= 3 then
                    local samples = _SampleSpline(hull, work)
                    if not samples then return end
                    local envelope = _SplineEnvelope(samples, work)
                    if not envelope then return end
                    local outline = _ReduceOutline(envelope, tolerance, work)
                    if not outline then return end
                    local area, x, y = _AreaAndCentroid(outline, work)
                    if area == nil then return end
                    if x and y then cluster.x, cluster.y = x, y end
                    if area > areaCutoff then cluster.outline = outline end
                end
                clusters[#clusters + 1] = cluster
            end
            if not _Checkpoint(work) then return end
        end
        partitionFirst = partitionLast + 1
    end
    if isCancelled and isCancelled() then return end
    return clusters
end
