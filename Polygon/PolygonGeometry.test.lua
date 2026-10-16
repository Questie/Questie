dofile("setupTests.lua")

describe("PolygonGeometry", function()
    local PolygonGeometry
    local originalClock, originalFrameClock
    local frame

    -- The public geometry call is asynchronous. Tests drain it without depending on
    -- ThreadLib's timers, and preserve the nil result that signals cancellation.
    -- ThreadLib resumes a ticker at most once per frame, so every resume advances GetTime().
    local function _Build(points, options, isCancelled)
        local thread = coroutine.create(function() return PolygonGeometry.Build(points, options, isCancelled) end)
        local result
        local resumes = 0
        repeat
            local ok
            frame = frame + 1
            ok, result = coroutine.resume(thread)
            assert.is_true(ok, tostring(result))
            resumes = resumes + 1
            assert.is_true(resumes < 10000, "geometry did not finish")
        until coroutine.status(thread) == "dead"
        return result, resumes
    end

    before_each(function()
        originalClock, originalFrameClock = _G.GetTimePreciseSec, _G.GetTime
        _G.GetTimePreciseSec = nil -- Operation ceilings make scheduling assertions deterministic.
        frame = 0
        _G.GetTime = function() return frame end
        dofile("Polygon/PolygonGeometry.lua")
        PolygonGeometry = QuestieLoader:ImportModule("PolygonGeometry")
    end)

    after_each(function()
        _G.GetTimePreciseSec, _G.GetTime = originalClock, originalFrameClock
    end)

    it("returns no clusters for an empty objective", function()
        assert.are_same({}, _Build({}))
    end)

    it("retains an isolated spawn and its opaque representative metadata", function()
        local point = {x = 0.2, y = 0.3, worldX = 1000, worldY = -200, uiMapId = 1429, instanceId = 0,
            tooltipKey = "m_123", target = {id = 123}}
        local result = _Build({point})

        assert.are_equal(point, result[1].representative)
        assert.are_same({{uiMapId = 1429, instanceId = 0, x = 0.2, y = 0.3, representative = point,
            worldBounds = {minX = 1000, minY = -200, maxX = 1000, maxY = -200}}}, result)
        assert.is_nil(point.touched)
        assert.is_nil(point.keep)
    end)

    it("uses explicit world coordinates even near the zero-percent edges", function()
        local a = {x = 0.1, y = 0.2, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0}
        local b = {x = 0.3, y = 0.4, worldX = 100, worldY = 0, uiMapId = 1429, instanceId = 0}
        local result = _Build({a, b})

        assert.are_equal(1, #result)
        assert.are_near(0.2, result[1].x, 0.000001)
        assert.are_near(0.3, result[1].y, 0.000001)
        assert.is_nil(result[1].outline)
    end)

    it("never mixes maps or instance coordinate spaces", function()
        local a = {x = 10, y = 20, worldX = 50, worldY = 50, uiMapId = 1429, instanceId = 0}
        local b = {x = 10, y = 20, worldX = 50, worldY = 50, uiMapId = 1429, instanceId = 1}
        local c = {x = 10, y = 20, worldX = 50, worldY = 50, uiMapId = 1436, instanceId = 0}
        local bounds = {minX = 50, minY = 50, maxX = 50, maxY = 50}

        assert.are_same({
            {uiMapId = 1429, instanceId = 0, x = 10, y = 20, representative = a, worldBounds = bounds},
            {uiMapId = 1429, instanceId = 1, x = 10, y = 20, representative = b, worldBounds = bounds},
            {uiMapId = 1436, instanceId = 0, x = 10, y = 20, representative = c, worldBounds = bounds},
        }, _Build({c, b, a}))
    end)

    describe("object clusters", function()
        -- World units equal percentages here, so x/y are the same positions as worldX/worldY.
        local function Spawn(x, y, isObject)
            return {x = x, y = y, worldX = x, worldY = y, uiMapId = 1429, instanceId = 0, isObject = isObject}
        end

        it("keeps objects apart from creatures and marks an area's centroid, like creatures", function()
            local wolf = Spawn(50, 50)
            -- Crate D stands 3 units from crate B.
            local crateA, crateB, crateC, crateD = Spawn(50, 50, true), Spawn(56, 50, true), Spawn(53, 58, true),
                Spawn(56, 53, true)
            local result = _Build({crateD, wolf, crateC, crateA, crateB}, {objectSpacing = 5})

            assert.are.equal(2, #result)
            local creatures, objects = result[1], result[2]
            assert.are.same({wolf}, {creatures.representative})
            assert.is_nil(creatures.isObject)
            assert.is_nil(creatures.locations)

            -- The same spawns as creatures produce the same marker and area.
            local asCreatures = _Build({Spawn(56, 53), Spawn(53, 58), Spawn(50, 50), Spawn(56, 50)})[1]
            assert.is_true(objects.isObject)
            assert.is_not_nil(objects.outline)
            assert.are.same({asCreatures.x, asCreatures.y}, {objects.x, objects.y})
            assert.are.equal(crateA, objects.representative)
            -- Locations follow admission order from the seed, skipping crate D, under 5 units from crate B.
            assert.are.same({crateA, crateC, crateB}, objects.locations)
        end)

        it("marks an object cluster without an area on the object nearest its middle", function()
            -- Collinear crates have no area; their mean (54.3, 50) is open ground.
            local left, middle, right = Spawn(50, 50, true), Spawn(53, 50, true), Spawn(60, 50, true)
            local objects = _Build({right, left, middle}, {objectSpacing = 5})[1]

            assert.is_nil(objects.outline)
            assert.are.equal(middle, objects.representative)
            assert.are.same({53, 50}, {objects.x, objects.y})
            -- Locations start with that crate; the left one, 3 units from it, is skipped.
            assert.are.same({middle, right}, {objects.locations[1], objects.locations[2]})
            assert.are.equal(2, #objects.locations)
        end)
    end)

    it("moves the admission center instead of using a fixed seed radius", function()
        local a = {x = 1, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0}
        local b = {x = 2, y = 10, worldX = 100, worldY = 0, uiMapId = 1429, instanceId = 0}
        local c = {x = 3, y = 10, worldX = 200, worldY = 0, uiMapId = 1429, instanceId = 0}

        assert.are_same({{uiMapId = 1429, instanceId = 0, x = 2, y = 10, representative = a,
            worldBounds = {minX = 0, minY = 0, maxX = 200, maxY = 0}}}, _Build({c, a, b}))
    end)

    it("recovers candidates missed before the first-pass center moved", function()
        local a = {x = 1, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0}
        local b = {x = 2, y = 10, worldX = 190, worldY = 0, uiMapId = 1429, instanceId = 0}
        local c = {x = 3, y = 10, worldX = 160, worldY = 0, uiMapId = 1429, instanceId = 0}
        local d = {x = 4, y = 10, worldX = 210, worldY = 0, uiMapId = 1429, instanceId = 0}

        assert.are_same({{uiMapId = 1429, instanceId = 0, x = 2.5, y = 10, representative = a,
            worldBounds = {minX = 0, minY = 0, maxX = 210, maxY = 0}}}, _Build({a, b, c, d}))
    end)

    it("keeps points exactly at the radius in separate clusters", function()
        local a = {x = 1, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0}
        local b = {x = 2, y = 10, worldX = 180, worldY = 0, uiMapId = 1429, instanceId = 0}

        assert.are_equal(2, #_Build({a, b}))
    end)

    it("keeps the same outline when collinear edge points precede the farthest corners", function()
        local a = {x = 10, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0}
        local b = {x = 30, y = 10, worldX = 20, worldY = 0, uiMapId = 1429, instanceId = 0}
        local c = {x = 30, y = 30, worldX = 20, worldY = 20, uiMapId = 1429, instanceId = 0}
        local d = {x = 10, y = 30, worldX = 0, worldY = 20, uiMapId = 1429, instanceId = 0}
        local left = {x = 10, y = 20, worldX = 0, worldY = 10, uiMapId = 1429, instanceId = 0}
        local bottom = {x = 20, y = 10, worldX = 10, worldY = 0, uiMapId = 1429, instanceId = 0}
        local right = {x = 30, y = 20, worldX = 20, worldY = 10, uiMapId = 1429, instanceId = 0}
        local top = {x = 20, y = 30, worldX = 10, worldY = 20, uiMapId = 1429, instanceId = 0}

        local corners = _Build({a, b, c, d})
        local withEdgePoints = _Build({a, left, d, top, c, right, b, bottom})

        assert.are_same(corners, withEdgePoints)
        assert.are_equal(a, withEdgePoints[1].representative)
    end)

    it("smooths a convex outline and places its marker at the polygon centroid", function()
        local points = {
            {x = 10, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0},
            {x = 30, y = 10, worldX = 20, worldY = 0, uiMapId = 1429, instanceId = 0},
            {x = 30, y = 30, worldX = 20, worldY = 20, uiMapId = 1429, instanceId = 0},
            {x = 10, y = 30, worldX = 0, worldY = 20, uiMapId = 1429, instanceId = 0},
        }
        local result = _Build(points)
        local outline = result[1].outline

        assert.is_true(#outline > 4)
        assert.are_near(20, result[1].x, 0.000001)
        assert.are_near(20, result[1].y, 0.000001)
        assert.is_true(outline[1].x < 10)
        assert.are_same(points[1], result[1].representative)
        assert.are_not_same(outline[1], outline[#outline])
    end)

    it("reduces smooth boundary vertices with the requested distance tolerance", function()
        local points = {
            {x = 10, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0},
            {x = 30, y = 10, worldX = 20, worldY = 0, uiMapId = 1429, instanceId = 0},
            {x = 30, y = 30, worldX = 20, worldY = 20, uiMapId = 1429, instanceId = 0},
            {x = 10, y = 30, worldX = 0, worldY = 20, uiMapId = 1429, instanceId = 0},
        }
        local fine = _Build(points, {tolerance = 0})[1]
        local coarse = _Build(points, {tolerance = 1})[1]

        assert.is_true(#coarse.outline < #fine.outline)
        assert.is_true(#coarse.outline >= 3)
    end)

    it("produces the same geometry when input order changes and never mutates points", function()
        local a = {x = 10, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0}
        local b = {x = 30, y = 10, worldX = 20, worldY = 0, uiMapId = 1429, instanceId = 0}
        local c = {x = 30, y = 30, worldX = 20, worldY = 20, uiMapId = 1429, instanceId = 0}
        local d = {x = 10, y = 30, worldX = 0, worldY = 20, uiMapId = 1429, instanceId = 0}

        assert.are_same(_Build({a, b, c, d}), _Build({d, c, b, a}))
        assert.are_same({x = 10, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0}, a)
        assert.are_same({x = 30, y = 30, worldX = 20, worldY = 20, uiMapId = 1429, instanceId = 0}, c)
    end)

    it("retains collinear duplicate coordinates as one point-only cluster", function()
        local a = {x = 10, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0}
        local b = {x = 20, y = 20, worldX = 10, worldY = 10, uiMapId = 1429, instanceId = 0}
        local c = {x = 30, y = 30, worldX = 20, worldY = 20, uiMapId = 1429, instanceId = 0}

        assert.are_same({{uiMapId = 1429, instanceId = 0, x = 20, y = 20, representative = a,
            worldBounds = {minX = 0, minY = 0, maxX = 20, maxY = 20}}}, _Build({a, b, b, c}))
    end)

    it("retains tiny regions as point markers while allowing an explicit zero area cutoff", function()
        local points = {
            {x = 10, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0},
            {x = 10.1, y = 10, worldX = 1, worldY = 0, uiMapId = 1429, instanceId = 0},
            {x = 10.1, y = 10.1, worldX = 1, worldY = 1, uiMapId = 1429, instanceId = 0},
            {x = 10, y = 10.1, worldX = 0, worldY = 1, uiMapId = 1429, instanceId = 0},
        }

        assert.is_nil(_Build(points)[1].outline)
        assert.is_table(_Build(points, {areaCutoff = 0})[1].outline)
    end)

    it("yields when its time slice expires and discards cancelled generations on resume", function()
        local now = 0
        _G.GetTimePreciseSec = function()
            now = now + 0.003
            return now
        end
        local points = {}
        for i = 1, 100 do
            points[i] = {x = i / 10, y = 20, worldX = i * 200, worldY = 0, uiMapId = 1429, instanceId = 0}
        end
        local cancelled = false
        local thread = coroutine.create(function()
            return PolygonGeometry.Build(points, nil, function() return cancelled end)
        end)

        assert.is_true(coroutine.resume(thread))
        assert.are_equal("suspended", coroutine.status(thread))
        cancelled = true
        local ok, result = coroutine.resume(thread)
        assert.is_true(ok)
        assert.is_nil(result)
        assert.are_equal("dead", coroutine.status(thread))
        assert.is_nil(points[1].touched)
    end)

    it("finishes a 100-point convex boundary without scheduling thousands of frames", function()
        local points = {}
        for i = 1, 100 do
            local angle = 2 * math.pi * i / 100
            points[i] = {x = 50 + 20 * math.cos(angle), y = 50 + 20 * math.sin(angle),
                worldX = 100 + 50 * math.cos(angle), worldY = 100 + 50 * math.sin(angle),
                uiMapId = 1429, instanceId = 0}
        end

        local result, resumes = _Build(points)

        assert.are_equal(1, #result)
        assert.is_table(result[1].outline)
        assert.is_true(resumes <= 8, "convex-boundary workload took " .. resumes .. " resumes")
    end)

    it("uses bounded operation slices when no clock advances for 500 isolated spawns", function()
        _G.GetTimePreciseSec = function() return 0 end
        local points = {}
        for i = 1, 500 do
            points[i] = {x = i / 10, y = 20, worldX = i * 200, worldY = 0, uiMapId = 1429, instanceId = 0}
        end

        local result, resumes = _Build(points)

        assert.are_equal(500, #result)
        assert.is_true(resumes > 1, "the operation ceiling must yield even with a frozen clock")
        assert.is_true(resumes <= 20, "isolated-spawn workload took " .. resumes .. " resumes")
    end)

    it("shares one frame budget between concurrent builds", function()
        local function _IsolatedSpawns()
            local points = {}
            for i = 1, 500 do
                points[i] = {x = i / 10, y = 20, worldX = i * 200, worldY = 0, uiMapId = 1429, instanceId = 0}
            end
            return points
        end
        local secondChecks = 0
        local first = coroutine.create(function() return PolygonGeometry.Build(_IsolatedSpawns()) end)
        local second = coroutine.create(function()
            return PolygonGeometry.Build(_IsolatedSpawns(), nil, function()
                secondChecks = secondChecks + 1
                return false
            end)
        end)

        -- Both tickers resume in one frame; the first spends that frame's operation ceiling.
        frame = 1
        assert.is_true(coroutine.resume(first))
        assert.are_equal("suspended", coroutine.status(first))
        assert.is_true(coroutine.resume(second))
        assert.are_equal("suspended", coroutine.status(second))
        assert.are_equal(2, secondChecks) -- The initial check, then one checkpoint that yields.
        -- Resuming into the same spent frame yields again before doing more work.
        assert.is_true(coroutine.resume(second))
        assert.are_equal("suspended", coroutine.status(second))
        assert.are_equal(3, secondChecks)

        -- The next frame starts a fresh slice for whichever build checks in first.
        frame = 2
        assert.is_true(coroutine.resume(second))
        assert.is_true(secondChecks > 3)
    end)

    it("holds a new job at its first step while this frame's slice is spent", function()
        frame = 1
        local spender = coroutine.create(function()
            local work = PolygonGeometry.NewWork()
            for _ = 1, 40000 do PolygonGeometry.Checkpoint(work) end
        end)
        assert.is_true(coroutine.resume(spender))
        assert.are_equal("suspended", coroutine.status(spender))
        local steps = 0
        local job = coroutine.create(function()
            local work = PolygonGeometry.NewWork()
            for _ = 1, 10 do
                PolygonGeometry.Checkpoint(work)
                steps = steps + 1
            end
        end)

        assert.is_true(coroutine.resume(job))
        assert.are_equal(0, steps)

        frame = 2
        assert.is_true(coroutine.resume(job))
        assert.are_equal("dead", coroutine.status(job))
        assert.are_equal(10, steps)
    end)

    it("charges weighted steps to the shared slice", function()
        frame = 1
        local steps = 0
        local job = coroutine.create(function()
            local work = PolygonGeometry.NewWork()
            for _ = 1, 40 do
                PolygonGeometry.Checkpoint(work, 1024)
                steps = steps + 1
            end
        end)

        -- 32 steps of 1,024 spend the frame's 32,768-step ceiling: the 32nd waits inside its check.
        assert.is_true(coroutine.resume(job))
        assert.are_equal(31, steps)

        frame = 2
        assert.is_true(coroutine.resume(job))
        assert.are_equal("dead", coroutine.status(job))
        assert.are_equal(40, steps)
    end)

    it("checks cancellation before a time slice needs to yield", function()
        local points = {}
        for i = 1, 100 do
            points[i] = {x = i / 10, y = 20, worldX = i * 200, worldY = 0, uiMapId = 1429, instanceId = 0}
        end
        local checks = 0
        local result, resumes = _Build(points, nil, function()
            checks = checks + 1
            return checks == 2
        end)

        assert.is_nil(result)
        assert.are_equal(1, resumes)
        assert.are_equal(2, checks)
    end)

    it("returns nil without starting work when already cancelled", function()
        assert.is_nil(_Build({}, nil, function() return true end))
    end)
end)
