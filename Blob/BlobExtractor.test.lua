dofile("setupTests.lua")

describe("BlobExtractor", function()
    local Extractor
    local function finish(job)
        while job.status == "running" do job:Step() end
        assert.are.equal("complete", job.status, job.reason)
        return job
    end
    local function inside(contours, x, y)
        local hit = false
        for _, ring in ipairs(contours) do
            for i, a in ipairs(ring) do
                local b = ring[i % #ring + 1]
                if (a[2] > y) ~= (b[2] > y) and x < a[1] + (b[1] - a[1]) * (y - a[2]) / (b[2] - a[2]) then
                    hit = not hit
                end
            end
        end
        return hit
    end
    local function new(query, options)
        options = options or {}
        options.clock = options.clock or os.clock
        options.discoveryCells = options.discoveryCells or 8
        options.boundaryCells = options.boundaryCells or 64
        return assert(Extractor.New(query, options))
    end
    before_each(function()
        dofile("Blob/BlobExtractor.lua")
        Extractor = QuestieLoader:ImportModule("BlobExtractor")
    end)

    it("extracts a concave L without filling its missing corner", function()
        local job = finish(new(function(x, y)
            return x > 0.2 and x < 0.8 and y > 0.2 and y < 0.8 and (x < 0.4 or y > 0.6)
        end))
        assert.are.equal(1, #job.contours)
        assert.is_true(inside(job.contours, 0.3, 0.3))
        assert.is_true(inside(job.contours, 0.7, 0.7))
        assert.is_false(inside(job.contours, 0.7, 0.3))
        assert.is_false(inside(job.contours, 0.1, 0.1))
        assert.is_true(job.vertices < job.rawVertices)
    end)

    it("retains disconnected regions", function()
        local job = finish(new(function(x, y)
            return y > 0.2 and y < 0.4 and ((x > 0.15 and x < 0.3) or (x > 0.6 and x < 0.8))
        end))
        assert.are.equal(2, #job.contours)
        assert.is_true(inside(job.contours, 0.2, 0.3))
        assert.is_true(inside(job.contours, 0.7, 0.3))
        assert.is_false(inside(job.contours, 0.45, 0.3))
    end)

    it("finds an island seen by a coarse center but not its corners", function()
        local job = finish(new(function(x, y)
            return (x - 0.4375)^2 + (y - 0.4375)^2 < 0.0004
        end))
        assert.are.equal(1, #job.contours)
        assert.is_true(inside(job.contours, 0.4375, 0.4375))
        assert.is_false(inside(job.contours, 0.48, 0.48))
    end)

    it("preserves a discovered hole with even-odd rings", function()
        local job = finish(new(function(x, y)
            local d = (x - 0.5)^2 + (y - 0.5)^2
            return d < 0.09 and d > 0.01
        end))
        assert.are.equal(2, #job.contours)
        assert.is_true(inside(job.contours, 0.7, 0.5))
        assert.is_false(inside(job.contours, 0.5, 0.5))
        assert.is_false(inside(job.contours, 0.9, 0.5))
    end)

    it("resolves diagonal saddle corners without joining disconnected interiors", function()
        local job = finish(new(function(x, y)
            return (x > 0.21 and x < 0.490 and y > 0.21 and y < 0.490)
                or (x > 0.494 and x < 0.79 and y > 0.494 and y < 0.79)
        end))
        assert.are.equal(2, #job.contours)
        assert.is_true(inside(job.contours, 0.3, 0.3))
        assert.is_true(inside(job.contours, 0.7, 0.7))
        assert.is_false(inside(job.contours, 0.492, 0.492))
    end)

    it("samples each shared crossing once and releases the oracle on completion", function()
        local seen = {}
        local job = finish(new(function(x, y)
            local key = string.format("%.12f,%.12f", x, y)
            assert.is_nil(seen[key], "duplicate query " .. key)
            seen[key] = true
            return (x - 0.5)^2 + (y - 0.5)^2 < 0.04
        end))
        assert.are.equal(job.rawVertices, job.crossings)
        assert.is_nil(job.contains)
        assert.is_nil(job.thread)
        local queries, elapsed = job.queries, job.activeSeconds
        job:Step()
        assert.are.equal(queries, job.queries)
        assert.are.equal(elapsed, job.activeSeconds)
    end)

    it("bounds work even when the supplied clock does not advance", function()
        local calls = 0
        local job = new(function() calls = calls + 1; return false end, {
            clock = function() return 0 end, discoveryCells = 32, boundaryCells = 128,
        })
        job:Step()
        assert.is_true(calls <= 512)
        assert.are.equal("running", job.status)
        job:Cancel()
        job:Step()
        assert.are.equal(calls, job.queries)
    end)

    for _, phase in ipairs({"discovery", "refinement", "assembly", "simplification"}) do
        it("cancels during " .. phase .. " without retaining partial contours or work", function()
            local time = 0
            local job = new(function(x, y) return (x - 0.5)^2 + (y - 0.5)^2 < 0.04 end, {
                budgetSeconds = 0.0001, clock = function() time = time + 0.00004; return time end,
            })
            while job.status == "running" and job.phase ~= phase do job:Step() end
            assert.are.equal("running", job.status)
            job:Cancel("test")
            local calls = job.queries
            job:Step()
            assert.are.equal("cancelled", job.status)
            assert.are.equal(calls, job.queries)
            assert.is_nil(job.contours)
            assert.is_nil(job.thread)
            assert.is_nil(job.contains)
        end)
    end

    it("reports bounds-truncated geometry rather than returning a partial ring", function()
        local job = new(function(x, y) return x < 0.5 and y > 0.2 and y < 0.8 end)
        while job.status == "running" do job:Step() end
        assert.are.equal("error", job.status)
        assert.matches("bounds", job.reason)
        assert.is_nil(job.contours)
        assert.is_nil(job.thread)
    end)

    it("permits cancellation from the membership callback", function()
        local job
        job = new(function() job:Cancel("oracle cancelled"); return false end)
        job:Step()
        assert.are.equal("cancelled", job.status)
        assert.is_nil(job.contains)
        assert.is_nil(job.thread)
    end)

    it("preserves callback cancellation when its boundary result would otherwise error", function()
        local job, calls
        calls = 0
        job = new(function()
            calls = calls + 1
            job:Cancel("oracle cancelled")
            return true
        end)
        job:Step()
        assert.are.equal("cancelled", job.status)
        assert.are.equal("oracle cancelled", job.reason)
        assert.is_nil(job.contains)
        assert.is_nil(job.thread)
        assert.is_nil(job.contours)
        local elapsed = job.activeSeconds
        job:Step()
        assert.are.equal(1, calls)
        assert.are.equal(elapsed, job.activeSeconds)
    end)

    it("preserves callback cancellation when the oracle subsequently throws", function()
        local job, calls
        calls = 0
        job = new(function()
            calls = calls + 1
            job:Cancel("oracle cancelled")
            error("failure after cancellation")
        end)
        job:Step()
        assert.are.equal("cancelled", job.status)
        assert.are.equal("oracle cancelled", job.reason)
        assert.is_nil(job.contains)
        assert.is_nil(job.thread)
        assert.is_nil(job.contours)
        local elapsed = job.activeSeconds
        job:Step()
        assert.are.equal(1, calls)
        assert.are.equal(elapsed, job.activeSeconds)
    end)

    it("retains a tiny noncollinear ring at the minimum supported edge tolerance", function()
        local job = finish(new(function(x, y)
            return ((x - 0.5) / 4e-8)^2 + ((y - 0.5) / 1e-7)^2 < 1
        end, {edgeTolerance = 1 / 16777216}))
        assert.are.equal(1, #job.contours)
        assert.are.equal(4, job.rawVertices)
        assert.are.equal(4, job.vertices)
        assert.are.equal(4, #job.contours[1])
        assert.is_true(inside(job.contours, 0.5, 0.5))
        assert.is_false(inside(job.contours, 0.500001, 0.5))
    end)

    it("contains oracle errors and releases all work", function()
        local job = new(function() error("native failure") end)
        job:Step()
        assert.are.equal("error", job.status)
        assert.matches("native failure", job.reason)
        assert.is_nil(job.contains)
        assert.is_nil(job.thread)
    end)

    it("rejects a non-dyadic lattice before starting", function()
        local job, err = Extractor.New(function() return false end, {clock = os.clock, discoveryCells = 8, boundaryCells = 80})
        assert.is_nil(job)
        assert.is_string(err)
    end)
end)
