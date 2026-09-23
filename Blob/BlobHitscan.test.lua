dofile("setupTests.lua")

describe("BlobHitscan", function()
    local BlobHitscan, originalClock, now, queries
    local probe

    before_each(function()
        originalClock = _G.GetTimePreciseSec
        now, queries = 0, {}
        _G.GetTimePreciseSec = function() return now end
        dofile("Blob/BlobHitscan.lua")
        BlobHitscan = QuestieLoader:ImportModule("BlobHitscan")
        probe = {
            UpdateMouseOverTooltip = function(_, x, y)
                now = now + 0.0004
                queries[#queries + 1] = {x, y}
                return 7, 2
            end,
            GetTooltipIndex = function(_, i) return ({0, 3})[i] end,
        }
    end)

    after_each(function() _G.GetTimePreciseSec = originalClock end)

    it("uses native index zero and reads every matched index before the next query", function()
        local job = assert(BlobHitscan.New(probe, {questID = 7, objectiveIndex = 0, cells = 10}))
        job:Step()
        assert.are.equal(3, job.samples)
        assert.are.equal(3, job.matchedSamples)
        assert.are.same({x = 0, y = 0, objectiveIndices = {0, 3}}, job.hits[1])
        assert.are.same({[0] = true, [3] = true}, job.objectiveIndices)
        assert.is_true(job.activeSeconds > 0)
        assert.are.equal("running", job.status)
    end)

    it("does not convert a one-based selection into a native objective index", function()
        local job = assert(BlobHitscan.New(probe, {questID = 7, objectiveIndex = 1, cells = 10}))
        job:Step()
        assert.are.equal(3, job.questSamples)
        assert.are.equal(0, job.matchedSamples)
        assert.are.same({}, job.hits)
    end)

    it("ignores a different quest even when objective indices would match", function()
        probe.UpdateMouseOverTooltip = function() return 33, 1 end
        probe.GetTooltipIndex = function() error("Must not inspect the other quest") end
        local job = assert(BlobHitscan.New(probe, {questID = 7, cells = 10}))
        job:Step()
        assert.are.equal("complete", job.status)
        assert.are.equal(0, job.matchedSamples)
    end)

    it("includes both ends of the requested bounds and preserves completion timing", function()
        local job = assert(BlobHitscan.New(probe, {
            questID = 7, cells = 10, bounds = {minX = 0.2, minY = 0.3, maxX = 0.4, maxY = 0.6},
        }))
        while job.status == "running" do job:Step() end
        assert.are.equal(121, job.samples)
        assert.are.same({0.2, 0.3}, queries[1])
        assert.are.same({0.4, 0.6}, queries[#queries])
        local elapsed = job.wallSeconds
        now = now + 1
        job:Step()
        assert.are.equal(elapsed, job.wallSeconds)
        assert.is_nil(job.probe)
    end)

    it("cancels without executing later slices", function()
        local job = assert(BlobHitscan.New(probe, {questID = 7, cells = 10}))
        job:Step()
        job:Cancel("Closed")
        local samples = job.samples
        job:Step()
        assert.are.equal(samples, job.samples)
        assert.are.equal("cancelled", job.status)
        assert.are.equal("Closed", job.reason)
        assert.is_nil(job.probe)
    end)

    it("caps native calls per slice even when the clock does not advance", function()
        probe.UpdateMouseOverTooltip = function() return nil end
        local job = assert(BlobHitscan.New(probe, {questID = 7, cells = 500}))
        job:Step()
        assert.are.equal(512, job.samples)
        assert.are.equal("running", job.status)
    end)

    it("rejects oversized grids and invalid normalized bounds before sampling", function()
        local job, err = BlobHitscan.New(probe, {questID = 7, cells = 501})
        assert.is_nil(job)
        assert.is_string(err)
        job, err = BlobHitscan.New(probe, {questID = 7, bounds = {minX = 0.5, maxX = 0.4, minY = 0, maxY = 1}})
        assert.is_nil(job)
        assert.is_string(err)
        assert.are.same({}, queries)
    end)
end)
