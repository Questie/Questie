---@class BlobExtractor
local BlobExtractor = QuestieLoader:CreateModule("BlobExtractor")
---@class BlobExtractionOptions
---@field discoveryCells? integer Coarse subdivisions per axis; defaults to 32.
---@field boundaryCells? integer Tracing subdivisions per axis; defaults to 512.
---@field edgeTolerance? number Normalized crossing precision; defaults to 1/32768.
---@field budgetSeconds? number Cooperative Step budget, 0.0001-0.002; defaults to 0.001.
---@field clock? fun():number Defaults to GetTimePreciseSec; inject a clock for offline use.
---@field profilePhases? boolean Enable detailed per-resume timing; defaults to false. Overall timing is always collected.

---@class BlobExtractionJob
---@field status "running"|"complete"|"cancelled"|"error"
---@field phase string
---@field reason? string Cancellation or extraction failure; no partial output is published.
---@field contours? number[][][] Cyclic normalized {x,y} rings, with even-odd fill semantics.
---@field queries integer Membership-oracle calls, including edge refinement.
---@field vertices integer Output vertex count after straight-run removal.
---@field rawVertices integer Vertex count before straight-run removal.
---@field activeSeconds number Total time inside Step, including bookkeeping.
---@field wallSeconds number Elapsed time since New.
---@field maxSliceSeconds number Largest measured Step duration.
---@field phaseSeconds table<string,number> Empty unless profilePhases=true; resumed phase time excludes Step bookkeeping.
---@field phaseQueries table<string,integer>
local Job = {}
Job.__index = Job
local yield = coroutine.yield

local function _Release(job)
    job.contains, job.thread = nil, nil
end

-- Integer/doubled-lattice samples are shared; crossing coordinates are shared by edge identity.
local function _Extract(job)
    local r, coarse = job.boundaryCells, job.discoveryCells
    local cache, queued, queue, nodes, nodeOrder = {}, {}, {}, {}, {}
    local pitch, verticalBase = r + 1, (r + 1) * (r + 1)
    local function query(x, y)
        if job.queries >= job.maxQueries then error("Query limit reached", 0) end
        local inside = not not job.contains(x, y)
        job.queries = job.queries + 1
        job.phaseQueries[job.phase] = (job.phaseQueries[job.phase] or 0) + 1
        if inside and (x == 0 or x == 1 or y == 0 or y == 1) then
            error("Geometry touches the map bounds; closed extraction is incomplete", 0)
        end
        yield()
        return inside
    end
    local function sample(x, y)
        local key = (y * 2) * (r * 2 + 1) + x * 2
        local value = cache[key]
        if value == nil then value = query(x / r, y / r); cache[key] = value end
        return value
    end
    local function enqueue(x, y)
        if x < 0 or y < 0 or x >= r or y >= r then error("Open boundary at map edge", 0) end
        local key = y * r + x
        if not queued[key] then
            if #queue >= job.maxCells then error("Boundary cell limit reached", 0) end
            queued[key] = true
            queue[#queue + 1] = {x, y}
        end
    end
    local function discover(x, y, size, root)
        job.discoveryVisited = job.discoveryVisited + 1
        if job.discoveryVisited > job.maxCells then error("Discovery cell limit reached", 0) end
        local a, b = sample(x, y), sample(x + size, y)
        local c, d = sample(x + size, y + size), sample(x, y + size)
        local mixed = a ~= b or a ~= c or a ~= d
        if root and not mixed then mixed = sample(x + size / 2, y + size / 2) ~= a end
        yield()
        if mixed then
            if size == 1 then enqueue(x, y)
            else
                local half = size / 2
                discover(x, y, half, false)
                discover(x + half, y, half, false)
                discover(x, y + half, half, false)
                discover(x + half, y + half, half, false)
            end
        end
    end

    job.phase = "discovery"
    local size = r / coarse
    for y = 0, r - size, size do
        for x = 0, r - size, size do discover(x, y, size, true) end
    end

    local function crossing(edge)
        local id = edge[1]
        if nodes[id] then return id end
        local ax, ay, bx, by = edge[2] / r, edge[3] / r, edge[4] / r, edge[5] / r
        local aInside = sample(edge[2], edge[3])
        job.phase = "refinement"
        while math.max(math.abs(bx - ax), math.abs(by - ay)) > job.edgeTolerance do
            local mx, my = (ax + bx) / 2, (ay + by) / 2
            if query(mx, my) == aInside then ax, ay = mx, my else bx, by = mx, my end
        end
        nodes[id] = {point = {(ax + bx) / 2, (ay + by) / 2}}
        nodeOrder[#nodeOrder + 1] = id
        job.crossings = job.crossings + 1
        job.phase = "tracing"
        return id
    end
    local function connect(a, b)
        local first, second = nodes[a], nodes[b]
        if #first >= 2 or #second >= 2 then error("Non-manifold boundary", 0) end
        first[#first + 1], second[#second + 1] = b, a
    end

    -- Follow crossed edges into neighbors on one fixed lattice, including neighbors discovery skipped.
    job.phase = "tracing"
    local head = 1
    while head <= #queue do
        local cell = queue[head]
        head = head + 1
        local x, y = cell[1], cell[2]
        local a, b, c, d = sample(x, y), sample(x + 1, y), sample(x + 1, y + 1), sample(x, y + 1)
        local edges = {
            {y * pitch + x + 1, x, y, x + 1, y, x, y - 1},
            {verticalBase + y * pitch + x + 2, x + 1, y, x + 1, y + 1, x + 1, y},
            {(y + 1) * pitch + x + 1, x, y + 1, x + 1, y + 1, x, y + 1},
            {verticalBase + y * pitch + x + 1, x, y, x, y + 1, x - 1, y},
        }
        local changes = {a ~= b, b ~= c, c ~= d, d ~= a}
        local crossed = {}
        for i = 1, 4 do
            if changes[i] then
                local edge = edges[i]
                crossed[#crossed + 1] = crossing(edge)
                enqueue(edge[6], edge[7])
            end
        end
        if #crossed == 2 then connect(crossed[1], crossed[2])
        elseif #crossed == 4 then
            -- Pair edges around the corners opposite the center's classification.
            if sample(x + 0.5, y + 0.5) == a then
                connect(crossed[1], crossed[2]); connect(crossed[3], crossed[4])
            else
                connect(crossed[1], crossed[4]); connect(crossed[2], crossed[3])
            end
        elseif #crossed ~= 0 then error("Unresolved marching cell", 0) end
        job.boundaryVisited = job.boundaryVisited + 1
        yield()
    end

    job.phase = "assembly"
    local visited, contours = {}, {}
    for _, start in ipairs(nodeOrder) do
        if not visited[start] then
            local ring, previous, current = {}, nil, start
            repeat
                local node = nodes[current]
                if not node or #node ~= 2 or visited[current] then error("Open or inconsistent boundary graph", 0) end
                visited[current] = true
                ring[#ring + 1] = node.point
                local nextID = node[1] == previous and node[2] or node[1]
                previous, current = current, nextID
                yield()
            until current == start
            if #ring < 3 then error("Degenerate boundary ring", 0) end
            job.rawVertices = job.rawVertices + #ring
            contours[#contours + 1] = ring
        end
        yield()
    end

    -- Remove only exactly collinear forward runs; an absolute area tolerance can erase tiny valid rings.
    job.phase = "simplification"
    for i, ring in ipairs(contours) do
        local simplified = {}
        for j, b in ipairs(ring) do
            local a, c = ring[(j - 2) % #ring + 1], ring[j % #ring + 1]
            local ux, uy, vx, vy = b[1] - a[1], b[2] - a[2], c[1] - b[1], c[2] - b[2]
            if ux * vy - uy * vx ~= 0 or ux * vx + uy * vy <= 0 then
                simplified[#simplified + 1] = b
            end
            yield()
        end
        if #simplified < 3 then error("Simplification collapsed a ring", 0) end
        contours[i] = simplified
        job.vertices = job.vertices + #simplified
    end
    job.contours = contours
end

---Creates a pure membership-oracle job. Caller owns native frame readiness and objective filtering.
---Contours are cyclic normalized point pairs (last connects to first), using even-odd fill for holes.
---Finite discovery can miss features between samples; options are coverage/precision tradeoffs, not an exhaustive guarantee.
---@param contains fun(x:number,y:number):boolean
---@param options BlobExtractionOptions?
---@return BlobExtractionJob? job
---@return string? error
function BlobExtractor.New(contains, options)
    options = options or {}
    local coarse, fine = options.discoveryCells or 32, options.boundaryCells or 512
    local tolerance, budget = options.edgeTolerance or 1 / 32768, options.budgetSeconds or 0.001
    local clock = options.clock or GetTimePreciseSec
    if type(contains) ~= "function" or type(clock) ~= "function" then return nil, "A membership function and clock are required" end
    if options.profilePhases ~= nil and type(options.profilePhases) ~= "boolean" then
        return nil, "profilePhases must be a boolean"
    end
    if type(coarse) ~= "number" or coarse < 2 or coarse > 128 or coarse % 1 ~= 0
        or type(fine) ~= "number" or fine < coarse * 2 or fine > 4096 or fine % coarse ~= 0 then
        return nil, "Use integer discovery cells 2-128 and a boundary grid up to 4096 with a power-of-two ratio"
    end
    local ratio = fine / coarse
    while ratio > 1 do
        if ratio % 2 ~= 0 then return nil, "Boundary/discovery ratio must be a power of two" end
        ratio = ratio / 2
    end
    if type(tolerance) ~= "number" or not (tolerance >= 1 / 16777216 and tolerance <= 1 / fine)
        or type(budget) ~= "number" or not (budget >= 0.0001 and budget <= 0.002) then
        return nil, "Invalid edge tolerance or time budget"
    end
    local job = setmetatable({contains = contains, clock = clock, discoveryCells = coarse, boundaryCells = fine,
        edgeTolerance = tolerance, budgetSeconds = budget, maxQueries = 250000, maxCells = 250000,
        phase = "discovery", status = "running", queries = 0, crossings = 0, discoveryVisited = 0, boundaryVisited = 0,
        rawVertices = 0, vertices = 0, activeSeconds = 0, wallSeconds = 0, maxSliceSeconds = 0, slices = 0,
        phaseSeconds = {}, phaseQueries = {}, profilePhases = options.profilePhases == true, startedAt = clock()}, Job)
    job.thread = coroutine.create(function() _Extract(job) end)
    return job
end

function Job:Cancel(reason)
    if self.status ~= "running" then return end
    self.status, self.reason = "cancelled", reason or "Cancelled"
    self.wallSeconds = self.clock() - self.startedAt
    _Release(self)
end

---Bounds queries AND graph/simplification work; one native callback cannot be preempted.
function Job:Step()
    if self.status ~= "running" then return end
    local start, units = self.clock(), 0
    while self.status == "running" and units < 512 and self.clock() - start < self.budgetSeconds do
        -- Detailed profiling adds two timer reads per resume; normal jobs only time the slice and its budget.
        local before = self.profilePhases and self.clock()
        local ok, err = coroutine.resume(self.thread)
        -- The oracle may cancel and release the thread before returning or throwing.
        if self.status ~= "running" then break end
        if before then
            local elapsed = self.clock() - before
            self.phaseSeconds[self.phase] = (self.phaseSeconds[self.phase] or 0) + elapsed
        end
        units = units + 1
        if not ok then
            self.status, self.reason, self.contours = "error", tostring(err), nil
            _Release(self)
        elseif coroutine.status(self.thread) == "dead" then
            self.status = "complete"
            _Release(self)
        end
    end
    local finish = self.clock()
    self.activeSeconds = self.activeSeconds + finish - start
    self.wallSeconds = finish - self.startedAt
    self.maxSliceSeconds = math.max(self.maxSliceSeconds, finish - start)
    self.slices = self.slices + 1
end
