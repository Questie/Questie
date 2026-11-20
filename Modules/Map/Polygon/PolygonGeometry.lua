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
---@field kinds PolygonSpawnPoint[]? The first member of each kind, in member order, the representative's kind first; nil when no member has a kind.

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
---@field tolerance number? Percentage-space reduction distance, default 0.06.
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

---The curve's point at time t between b and c: Barry and Goldman's pyramid of linear interpolations
---through a, b, c and d, which it reaches at times 0, toB, toC and toD.
---@return number x, number y
local function _CatmullRom(a, b, c, d, toB, toC, toD, t)
    local ab, bc, cd = t / toB, (t - toB) / (toC - toB), (t - toC) / (toD - toC)
    local abc, bcd = t / toC, (t - toB) / (toD - toB)
    local abX, bcX, cdX = a.x + (b.x - a.x) * ab, b.x + (c.x - b.x) * bc, c.x + (d.x - c.x) * cd
    local abY, bcY, cdY = a.y + (b.y - a.y) * ab, b.y + (c.y - b.y) * bc, c.y + (d.y - c.y) * cd
    local abcX, bcdX = abX + (bcX - abX) * abc, bcX + (cdX - bcX) * bcd
    local abcY, bcdY = abY + (bcY - abY) * abc, bcY + (cdY - bcY) * bcd
    return abcX + (bcdX - abcX) * bc, abcY + (bcdY - abcY) * bc
end

-- Periodic centripetal Catmull-Rom samples, ten per hull edge. Each edge takes parameter time in
-- proportion to the square root of its length. Even timing makes a short edge beside a long one
-- overshoot: a sharp corner then grows a spike past its spawns, which can reach into a neighboring
-- cluster's area. Each edge's first sample is its hull vertex, copied exactly, so the second hull,
-- which discards inward excursions and leaves a convex fan to render, contains every spawn. Lengths
-- are in percent, which stretches x and y differently; it only shifts the timing a little.
local function _SampleSpline(hull, work)
    local samples, count, spans = {}, #hull, {}
    for i = 1, count do
        local a, b = hull[i], hull[i % count + 1]
        spans[i] = math.sqrt(math.sqrt((b.x - a.x)^2 + (b.y - a.y)^2))
    end
    for i = 1, count do
        local previous, nextIndex = (i - 2) % count + 1, i % count + 1
        local a, b, c, d = hull[previous], hull[i], hull[nextIndex], hull[nextIndex % count + 1]
        -- Parameter time from a: at b, c and d.
        local toB = spans[previous]
        local toC = toB + spans[i]
        local toD = toC + spans[nextIndex]
        samples[#samples + 1] = {x = b.x, y = b.y}
        for step = 1, 9 do
            local x, y = _CatmullRom(a, b, c, d, toB, toC, toD, toB + (toC - toB) * step / 10)
            samples[#samples + 1] = {x = x, y = y}
            if not _Checkpoint(work) then return end
        end
    end
    return samples
end

-- Outlines are rings without a repeated closing vertex. Closing the ring for Simplify keeps its start
-- and splits it first at the vertex farthest from the start. Percent space stretches x and y
-- differently, but the 0.06 default is well under a canvas unit on either axis.
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
---@param members PolygonSpawnPoint[] The representative first, in a deterministic order.
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

-- Reassignment
-- The greedy pass never guarantees separate clusters: a cluster's center drifts while it grows, so it
-- can take part of a row of spawns and leave the rest to the next cluster, and both outlines then
-- cover the row. One round fixes that: every spawn moves to the cluster whose center, the mean of its
-- spawns, is nearest. Each spawn then sits on its own center's side of the line halfway between any
-- two centers, so the convex hulls of a partition's clusters cannot overlap; outlines smooth those
-- hulls and can still bulge slightly past that line. Objects and creatures are separate partitions.
-- A cluster's reach is the farthest any of its spawns lies from its center; it can exceed the radius,
-- as the center drifts. A cluster whose spawn bounds are farther from another's than either one's reach
-- cannot win any of its spawns, which lie nearer their own center, so only nearer clusters are compared.
-- Further rounds would only make clusters rounder, at several times the cost.

---@param groups PolygonSpawnPoint[][] One partition's greedy clusters, each in admission order, seed first.
---@return PolygonSpawnPoint[][]? groups The non-empty clusters in the same order: spawns that stayed, in
---admission order, then the ones that moved in, in theirs. The seed leads while it stays; otherwise the
---member nearest the new center does. nil on cancellation.
local function _Reassign(groups, work)
    if #groups < 2 then return groups end
    local centerX, centerY, bounds, reachSquared = {}, {}, {}, {}
    for g, members in ipairs(groups) do
        local sumX, sumY, minX, minY, maxX, maxY = 0, 0, huge, huge, -huge, -huge
        for _, member in ipairs(members) do
            local x, y = member.worldX, member.worldY
            sumX, sumY = sumX + x, sumY + y
            minX, maxX, minY, maxY = math.min(minX, x), math.max(maxX, x), math.min(minY, y), math.max(maxY, y)
            if not _Checkpoint(work) then return end
        end
        local x, y, farthest = sumX / #members, sumY / #members, 0
        for _, member in ipairs(members) do
            farthest = math.max(farthest, (member.worldX - x)^2 + (member.worldY - y)^2)
            if not _Checkpoint(work) then return end
        end
        centerX[g], centerY[g], bounds[g], reachSquared[g] = x, y, {minX, minY, maxX, maxY}, farthest
    end

    -- Neighbors in ascending order, so ties between them resolve the same way every time.
    local neighbors = {}
    for g = 1, #groups do neighbors[g] = {} end
    for g = 1, #groups - 1 do
        local a = bounds[g]
        for h = g + 1, #groups do
            local b = bounds[h]
            local gapX, gapY = math.max(0, b[1] - a[3], a[1] - b[3]), math.max(0, b[2] - a[4], a[2] - b[4])
            if gapX * gapX + gapY * gapY <= math.max(reachSquared[g], reachSquared[h]) then
                neighbors[g][#neighbors[g] + 1] = h
                neighbors[h][#neighbors[h] + 1] = g
            end
            if not _Checkpoint(work) then return end
        end
    end

    -- Centers are the greedy clusters' means, fixed for the round, so the order spawns are visited in
    -- changes nothing. A tie stays put.
    local stayed, movedIn = {}, {}
    for g = 1, #groups do stayed[g], movedIn[g] = {}, {} end
    for g, members in ipairs(groups) do
        for _, member in ipairs(members) do
            local x, y = member.worldX, member.worldY
            local nearest, nearestDistance = g, (x - centerX[g])^2 + (y - centerY[g])^2
            for _, h in ipairs(neighbors[g]) do
                local distance = (x - centerX[h])^2 + (y - centerY[h])^2
                if distance < nearestDistance then nearest, nearestDistance = h, distance end
            end
            local into = nearest == g and stayed[g] or movedIn[nearest]
            into[#into + 1] = member
            if not _Checkpoint(work, 1 + #neighbors[g]) then return end
        end
    end

    local result = {}
    for g, members in ipairs(stayed) do
        for _, member in ipairs(movedIn[g]) do members[#members + 1] = member end
        if members[1] and members[1] ~= groups[g][1] then
            local sumX, sumY = 0, 0
            for _, member in ipairs(members) do sumX, sumY = sumX + member.worldX, sumY + member.worldY end
            local meanX, meanY = sumX / #members, sumY / #members
            local nearest, nearestDistance = 1, huge
            for i, member in ipairs(members) do
                local distance = (member.worldX - meanX)^2 + (member.worldY - meanY)^2
                if distance < nearestDistance then nearest, nearestDistance = i, distance end
            end
            table.insert(members, 1, table.remove(members, nearest))
            if not _Checkpoint(work, 2 * #members) then return end
        end
        if members[1] then result[#result + 1] = members end
    end
    return result
end

---Builds one cluster's record and outline.
---@param members PolygonSpawnPoint[] The first is the cluster's representative.
---@return PolygonCluster? cluster nil on cancellation.
local function _BuildCluster(members, areaCutoff, tolerance, objectSpacing, work)
    local first = members[1]
    local sumX, sumY, worldSumX, worldSumY = 0, 0, 0, 0
    local minX, minY, maxX, maxY = huge, huge, -huge, -huge
    local kinds, seenKinds = {}, {}
    for _, member in ipairs(members) do
        sumX, sumY = sumX + member.x, sumY + member.y
        worldSumX, worldSumY = worldSumX + member.worldX, worldSumY + member.worldY
        minX, maxX = math.min(minX, member.worldX), math.max(maxX, member.worldX)
        minY, maxY = math.min(minY, member.worldY), math.max(maxY, member.worldY)
        local kind = member.kind
        if kind ~= nil and not seenKinds[kind] then
            seenKinds[kind] = true
            kinds[#kinds + 1] = member
        end
        if not _Checkpoint(work) then return end
    end
    local cluster = {uiMapId = first.uiMapId, instanceId = first.instanceId,
        x = sumX / #members, y = sumY / #members, representative = first, kinds = kinds[1] and kinds or nil,
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
    if first.isObject and not _ListObjects(cluster, members, worldSumX / #members, worldSumY / #members,
        objectSpacing, work) then return end
    return cluster
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
    local tolerance = options.tolerance or 0.06
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
        local groups = {}
        for seedIndex = partitionFirst, partitionLast do
            local seed = sorted[seedIndex]
            if not touched[seedIndex] then
                local members = {seed}
                touched[seedIndex] = true
                local worldSumX, worldSumY = seed.worldX, seed.worldY
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
                groups[#groups + 1] = members
            end
            if not _Checkpoint(work) then return end
        end

        groups = _Reassign(groups, work)
        if not groups then return end
        for _, members in ipairs(groups) do
            local cluster = _BuildCluster(members, areaCutoff, tolerance, objectSpacing, work)
            if not cluster then return end
            clusters[#clusters + 1] = cluster
        end
        partitionFirst = partitionLast + 1
    end
    if isCancelled and isCancelled() then return end
    return clusters
end
