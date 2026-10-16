---@class PolygonGeometry
local PolygonGeometry = QuestieLoader:CreateModule("PolygonGeometry")

---@type MapGeometry
local MapGeometry = QuestieLoader:ImportModule("MapGeometry")

---@class PolygonSpawnPoint
---@field x number Zone percentage, not normalized map coordinates.
---@field y number
---@field worldX number World units used for clustering distances.
---@field worldY number
---@field uiMapId number
---@field instanceId number Unrelated coordinate spaces never share a cluster.
---@field isObject boolean? A static game object; objects and creatures never share a cluster.
---@field kind any? What the spawn is of, such as one NPC: each cluster lists one member of every kind.
-- Extra fields are opaque to geometry. Representatives retain the caller's original point.

---@class PolygonCluster
---@field uiMapId number
---@field instanceId number
---@field x number Marker position in zone percentages.
---@field y number
---@field outline table[]? Ordered convex percentage-space outline; nil retains a point-only marker.
---@field worldBounds PolygonWorldBounds Member spawn extent, for coarse player-proximity checks.
---@field representative PolygonSpawnPoint For an object cluster without an area, the member the marker sits on.
---@field isObject boolean? A cluster of game objects, which list their own positions.
---@field locations PolygonSpawnPoint[]? Object members at least objectSpacing apart, starting with the representative.
---@field kinds PolygonSpawnPoint[]? The first member of each kind, in admission order; nil when no member has a kind.

---@class PolygonWorldBounds
---@field minX number World units, matching PolygonSpawnPoint.worldX.
---@field minY number
---@field maxX number
---@field maxY number

---@class PolygonWork
---@field pending number Cost charged since this job last checked the shared slice.
---@field started boolean? The job has checked the slice at least once.
---@field isCancelled (fun(): boolean)?
---@field clock (fun(): number)? Precise seconds; nil leaves only the operation ceiling.

---@class PolygonGeometryOptions
---@field radius number? World units, default 180.
---@field areaCutoff number? Squared zone percentages, default 0.9.
---@field tolerance number? Percentage-space reduction distance, default 0.03.
---@field objectSpacing number? World units between an object cluster's listed locations, default 10.

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
-- measures work inside it. Steps carry costs, and a job checks the slice before its first step,
-- so a job starting in a frame already spent waits. The operation ceiling also bounds work
-- without a precise clock.
local slice = {frame = nil, startedAt = 0, operations = 0}

---Starts cooperative work that shares this frame's polygon budget with every other job.
---@param isCancelled (fun(): boolean)?
---@return PolygonWork
function PolygonGeometry.NewWork(isCancelled)
    local clock = type(GetTimePreciseSec) == "function" and GetTimePreciseSec or nil
    return {pending = 0, isCancelled = isCancelled, clock = clock}
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

---Charges cost to this frame's shared polygon budget; 1 is one geometry step, about a third of a
---microsecond of Lua. A job checks cancellation and the slice before its first step, then whenever
---it has charged CHECK_INTERVAL since its last check, and yields while this frame's 2 ms or
---operation ceiling is spent. Charge a costly step, such as drawing an icon, roughly its cost in
---geometry steps, so the clock is read about as often whatever the job does.
---Callers must be coroutines resumed at most once per frame, as ThreadLib does; a same-frame drain
---loop never finishes.
---@async
---@param work PolygonWork
---@param cost number? Default 1.
---@return boolean continue False when the job was cancelled.
function PolygonGeometry.Checkpoint(work, cost)
    local pending = work.pending + (cost or 1)
    if work.started and pending < CHECK_INTERVAL then
        work.pending = pending
        return true
    end
    work.started, work.pending = true, 0
    if work.isCancelled and work.isCancelled() then return false end
    _SyncSlice(work)
    slice.operations = slice.operations + pending

    -- A job can resume in a frame another job has already spent. Recheck before working,
    -- so each waiting job does not add another CHECK_INTERVAL past the shared budget.
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
    if (a.isObject == true) ~= (b.isObject == true) then return b.isObject == true end
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

-- Outlines are rings without a repeated closing vertex. Closing the ring for Simplify keeps its start
-- and splits it first at the vertex farthest from the start. Percent space stretches x and y
-- differently, but the 0.03 default is well under a canvas unit on either axis.
---@param points table[] Convex outline in zone percent, not closed.
---@param tolerance number Percent.
---@return table[] reduced At least three of the outline's own points; the outline itself when fewer would remain.
local function _ReduceOutline(points, tolerance)
    local ring = {}
    for i, point in ipairs(points) do ring[i] = point end
    ring[#ring + 1] = points[1]
    local reduced = MapGeometry.Simplify(ring, tolerance)
    reduced[#reduced] = nil
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

---Objects stand exactly where their spawns say, unlike wandering creatures, so object clusters
---list their members at least `spacing` apart; closer ones would overlap as icons anyway. A
---cluster with an area keeps its area-centroid marker, like creatures: the drawn area explains
---where it points. Without an area, a centroid could stand in empty ground between objects, so
---the marker sits on the member nearest the members' mean instead.
---@param cluster PolygonCluster
---@param members PolygonSpawnPoint[] In admission order, which is deterministic.
---@return boolean? completed nil on cancellation.
local function _ListObjects(cluster, members, meanX, meanY, spacing, work)
    local first = members[1]
    if not cluster.outline then
        local nearestDistance = huge
        for _, member in ipairs(members) do
            local distance = (member.worldX - meanX)^2 + (member.worldY - meanY)^2
            if distance < nearestDistance then first, nearestDistance = member, distance end
            if not _Checkpoint(work) then return end
        end
        cluster.representative, cluster.x, cluster.y = first, first.x, first.y
    end
    local locations, spacingSquared = {first}, spacing * spacing
    for _, member in ipairs(members) do
        local separate = member ~= first
        for _, kept in ipairs(locations) do
            if not separate then break end
            separate = (member.worldX - kept.worldX)^2 + (member.worldY - kept.worldY)^2 >= spacingSquared
            if not _Checkpoint(work) then return end
        end
        if separate then locations[#locations + 1] = member end
    end
    cluster.isObject, cluster.locations = true, locations
    return true
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
    local objectSpacing = options.objectSpacing or 10
    assert(_IsFinite(radius) and radius > 0, "Polygon radius must be positive and finite")
    assert(_IsFinite(objectSpacing) and objectSpacing >= 0, "Polygon object spacing must be nonnegative and finite")
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

    -- Work within contiguous map/instance/kind partitions. Candidate scans never visit an
    -- unrelated coordinate space, even when many objectives span multiple maps, and objects
    -- never join creature clusters.
    local partitionFirst = 1
    while partitionFirst <= #sorted do
        local partitionLast = partitionFirst
        local firstPoint = sorted[partitionFirst]
        while sorted[partitionLast + 1] and sorted[partitionLast + 1].uiMapId == firstPoint.uiMapId
            and sorted[partitionLast + 1].instanceId == firstPoint.instanceId
            and (sorted[partitionLast + 1].isObject == true) == (firstPoint.isObject == true) do
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

                local kinds, seenKinds = {}, {}
                for _, member in ipairs(members) do
                    local kind = member.kind
                    if kind ~= nil and not seenKinds[kind] then
                        seenKinds[kind] = true
                        kinds[#kinds + 1] = member
                    end
                end
                local cluster = {uiMapId = seed.uiMapId, instanceId = seed.instanceId,
                    x = sumX / #members, y = sumY / #members, representative = seed, kinds = kinds[1] and kinds or nil,
                    worldBounds = {minX = minX, minY = minY, maxX = maxX, maxY = maxY}}
                -- Outlines and markers share clustering, but isolated/collinear/tiny regions
                -- remain useful point markers instead of being discarded by the area cutoff.
                local hull = _GiftWrap(members, work)
                if not hull then return end
                if #hull >= 3 then
                    local samples = _SampleSpline(hull, work)
                    if not samples then return end
                    local envelope = _SplineEnvelope(samples, work)
                    if not envelope then return end
                    local outline = _ReduceOutline(envelope, tolerance)
                    if not _Checkpoint(work, #envelope) then return end
                    local area, x, y = _AreaAndCentroid(outline, work)
                    if area == nil then return end
                    if x and y then cluster.x, cluster.y = x, y end
                    if area > areaCutoff then cluster.outline = outline end
                end
                if seed.isObject and not _ListObjects(cluster, members, worldSumX / #members, worldSumY / #members,
                    objectSpacing, work) then return end
                clusters[#clusters + 1] = cluster
            end
            if not _Checkpoint(work) then return end
        end
        partitionFirst = partitionLast + 1
    end
    if isCancelled and isCancelled() then return end
    return clusters
end
