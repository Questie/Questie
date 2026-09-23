---@class BlobHitscan
local BlobHitscan = QuestieLoader:CreateModule("BlobHitscan")

local Job = {}
Job.__index = Job

---Samples a prepared, quest-isolated native QuestPOIFrame. The caller owns rendering/readiness and calls Step each frame.
---@param probe QuestPOIFrame
---@param options table @questID; objectiveIndex=nil for all; cells=200; bounds={minX,minY,maxX,maxY}; budgetSeconds=0.001
---@return table? job
---@return string? error
function BlobHitscan.New(probe, options)
    local questID = options.questID
    local objectiveIndex = options.objectiveIndex
    local cells = options.cells or 200
    local budget = options.budgetSeconds or 0.001
    local bounds = options.bounds or {minX = 0, minY = 0, maxX = 1, maxY = 1}
    if type(questID) ~= "number" or questID < 1 or questID == math.huge or questID % 1 ~= 0 then
        return nil, "Quest ID must be a positive integer."
    end
    if objectiveIndex ~= nil and (type(objectiveIndex) ~= "number" or objectiveIndex < 0
        or objectiveIndex == math.huge or objectiveIndex % 1 ~= 0) then
        return nil, "Objective index must be a native nonnegative integer, or blank for all."
    end
    if type(cells) ~= "number" or cells < 10 or cells > 500 or cells % 1 ~= 0 then
        return nil, "Grid cells must be an integer from 10 to 500."
    end
    if type(budget) ~= "number" or not (budget >= 0.0001 and budget <= 0.002) then
        return nil, "Scan budget must be between 0.0001 and 0.002 seconds."
    end
    for _, key in ipairs({"minX", "minY", "maxX", "maxY"}) do
        local value = bounds[key]
        if type(value) ~= "number" or not (value >= 0 and value <= 1) then
            return nil, "Bounds must be normalized map coordinates."
        end
    end
    if bounds.minX >= bounds.maxX or bounds.minY >= bounds.maxY then
        return nil, "Bounds must have positive width and height."
    end

    local clock = GetTimePreciseSec
    return setmetatable({
        probe = probe, questID = questID, objectiveIndex = objectiveIndex, cells = cells,
        bounds = {minX = bounds.minX, minY = bounds.minY, maxX = bounds.maxX, maxY = bounds.maxY},
        budgetSeconds = budget, clock = clock, startedAt = clock(), status = "running",
        samples = 0, totalSamples = (cells + 1) * (cells + 1), hits = {}, matchedSamples = 0,
        questSamples = 0, objectiveIndices = {}, activeSeconds = 0, wallSeconds = 0,
        maxSliceSeconds = 0, slices = 0, truncatedHits = false,
    }, Job)
end

---Stops future sampling; completed/cancelled jobs are inert.
---@param reason string?
function Job:Cancel(reason)
    if self.status == "running" then
        self.status = "cancelled"
        self.reason = reason or "Cancelled"
        self.wallSeconds = self.clock() - self.startedAt
        self.probe = nil
    end
end

---Per-frame work is bounded by both elapsed precise seconds and a 512-query ceiling.
---The budget cannot preempt an individual native call. Metrics include Lua sampling/recording work, not GPU rendering.
function Job:Step()
    if self.status ~= "running" then return end
    local start = self.clock()
    local queries = 0
    local side = self.cells + 1
    local bounds = self.bounds
    while self.samples < self.totalSamples and queries < 512 and self.clock() - start < self.budgetSeconds do
        local xi = self.samples % side
        local yi = math.floor(self.samples / side)
        local x = bounds.minX + xi / self.cells * (bounds.maxX - bounds.minX)
        local y = bounds.minY + yi / self.cells * (bounds.maxY - bounds.minY)
        local id, count = self.probe:UpdateMouseOverTooltip(x, y)
        if id == self.questID then
            self.questSamples = self.questSamples + 1
            local indices = {}
            local matches = self.objectiveIndex == nil
            -- Read these immediately: the next hit-test replaces the native tooltip-index buffer.
            for i = 1, count or 0 do
                local index = self.probe:GetTooltipIndex(i)
                indices[#indices + 1] = index
                self.objectiveIndices[index] = true
                if index == self.objectiveIndex then matches = true end
            end
            if matches then
                self.matchedSamples = self.matchedSamples + 1
                if not self.hitBounds then
                    self.hitBounds = {minX = x, maxX = x, minY = y, maxY = y}
                else
                    local hitBounds = self.hitBounds
                    hitBounds.minX = math.min(hitBounds.minX, x)
                    hitBounds.maxX = math.max(hitBounds.maxX, x)
                    hitBounds.minY = math.min(hitBounds.minY, y)
                    hitBounds.maxY = math.max(hitBounds.maxY, y)
                end
                -- Keep memory bounded even for a quest covering most of the map.
                if #self.hits < 20000 then
                    self.hits[#self.hits + 1] = {x = x, y = y, objectiveIndices = indices}
                else
                    self.truncatedHits = true
                end
            end
        end
        self.samples = self.samples + 1
        queries = queries + 1
    end
    local finish = self.clock()
    local elapsed = finish - start
    self.activeSeconds = self.activeSeconds + elapsed
    self.maxSliceSeconds = math.max(self.maxSliceSeconds, elapsed)
    self.wallSeconds = finish - self.startedAt
    self.slices = self.slices + 1
    if self.samples == self.totalSamples then
        self.status = "complete"
        self.probe = nil
    end
end
