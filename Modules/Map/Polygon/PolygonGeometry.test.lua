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
        dofile("Modules/Map/MapGeometry.lua")
        dofile("Modules/Map/Polygon/PolygonGeometry.lua")
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

    it("lists one member of each kind its cluster holds, such as one spawn of each NPC", function()
        local wolf = {x = 1, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0, kind = "wolf"}
        local bear = {x = 2, y = 10, worldX = 50, worldY = 0, uiMapId = 1429, instanceId = 0, kind = "bear"}
        local secondWolf = {x = 3, y = 10, worldX = 100, worldY = 0, uiMapId = 1429, instanceId = 0, kind = "wolf"}
        local farBear = {x = 50, y = 10, worldX = 5000, worldY = 0, uiMapId = 1429, instanceId = 0, kind = "bear"}

        local result = _Build({secondWolf, farBear, bear, wolf})

        assert.are_equal(2, #result)
        assert.are_same({"wolf", "bear"}, {result[1].kinds[1].kind, result[1].kinds[2].kind})
        assert.are_equal(2, #result[1].kinds)
        assert.are_equal(farBear, result[2].kinds[1])
        assert.are_equal(1, #result[2].kinds)
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

    describe("reassignment", function()
        -- Percentages are world units / 10, plus 10 on y, so seeds go in world order.
        local function Spawn(worldX, worldY)
            worldY = worldY or 0
            return {x = worldX / 10, y = worldY / 10 + 10, worldX = worldX, worldY = worldY, uiMapId = 1429, instanceId = 0}
        end

        for _, axis in ipairs({"x", "y"}) do
            it("moves a spawn the greedy pass left with a farther center to the nearest one, along " .. axis, function()
                local function At(position)
                    if axis == "x" then return Spawn(position, 0) end
                    return Spawn(0, position)
                end
                local function Bounds(low, high)
                    if axis == "x" then return {minX = low, minY = 0, maxX = high, maxY = 0} end
                    return {minX = 0, minY = low, maxX = 0, maxY = high}
                end
                local offset = axis == "x" and 0 or 10
                -- Greedy: 0 takes 170 (center 85), then 260 (175 away; center 143.3). 350 seeds a second
                -- cluster and takes 400 (center 375). 260 is 116.7 from its own center but 115 from the
                -- second one, so it moves there.
                local a, b, c, d, e = At(0), At(170), At(260), At(350), At(400)

                local result = _Build({e, d, c, b, a})

                assert.are_equal(2, #result)
                assert.are_equal(a, result[1].representative)
                assert.are_same(Bounds(0, 170), result[1].worldBounds)
                assert.are_near(offset + 8.5, result[1][axis], 1e-9)
                assert.are_equal(d, result[2].representative)
                assert.are_same(Bounds(260, 400), result[2].worldBounds)
                assert.are_near(offset + (26 + 35 + 40) / 3, result[2][axis], 1e-9)
            end)
        end

        it("lets the member nearest the new center lead a cluster whose seed moved away", function()
            -- Greedy: 0 takes 50 to 120 (center 60) and rejects 240, exactly 180 away. 240 seeds a second
            -- cluster taking 380 to 540 (center 430). 240 is nearer the first center, 180 against 190, so
            -- it moves. The second cluster's new mean is 468: 460 is nearest it, though 450 is nearest
            -- the old center.
            local spawns = {}
            for i, worldX in ipairs({0, 50, 70, 120, 240, 380, 450, 460, 510, 540}) do spawns[i] = Spawn(worldX) end

            local result = _Build(spawns)

            assert.are_equal(2, #result)
            assert.are_equal(spawns[1], result[1].representative)
            assert.are_same({minX = 0, minY = 0, maxX = 240, maxY = 0}, result[1].worldBounds)
            assert.are_near(9.6, result[1].x, 1e-9)
            assert.are_equal(spawns[8], result[2].representative)
            assert.are_same({minX = 380, minY = 0, maxX = 540, maxY = 0}, result[2].worldBounds)
            assert.are_near(46.8, result[2].x, 1e-9)
        end)

        it("compares a spawn with clusters as far away as its own center drifted", function()
            -- Greedy: (-225, 0) takes the three spawns around (-205, 0). (0, 0) seeds a second cluster,
            -- which takes five spawns at (170, 0) and ten at (310, -9..9), so its center drifts to
            -- (246.9, 0). The seed is then 205 from the first center, nearer than its own, though the
            -- two clusters' spawns are 185 apart, farther than the radius.
            local spawns = {Spawn(-225, 0), Spawn(-205, -30), Spawn(-205, 30), Spawn(-185, 0), Spawn(0, 0)}
            for _ = 1, 5 do spawns[#spawns + 1] = Spawn(170, 0) end
            for y = -9, 9, 2 do spawns[#spawns + 1] = Spawn(310, y) end

            local result = _Build(spawns)

            assert.are_equal(2, #result)
            assert.are_same({minX = -225, minY = -30, maxX = 0, maxY = 30}, result[1].worldBounds)
            assert.are_same({minX = 170, minY = -9, maxX = 310, maxY = 9}, result[2].worldBounds)
        end)

        it("returns nothing, and does not fail, when cancelled at any check", function()
            -- 150 spawns spread over a zone, so the build forms, reassigns and outlines several clusters.
            local spawns = {}
            for i = 0, 149 do
                local worldX, worldY = (i * 73) % 1000 * 3, (i * 151) % 700 * 3
                spawns[#spawns + 1] = {x = worldX / 30, y = worldY / 30, worldX = worldX, worldY = worldY,
                    uiMapId = 1429, instanceId = 0}
            end
            local checks = 0
            assert.is_true(#_Build(spawns, nil, function() checks = checks + 1; return false end) > 1)

            for cancelAt = 1, checks do
                local count = 0
                local result = _Build(spawns, nil, function() count = count + 1; return count >= cancelAt end)
                assert.is_nil(result, string.format("cancelled at check %d of %d", cancelAt, checks))
            end
        end)

        -- Finding Warmth (quest 99159, Forever): its 34 Fallen Logs in Dun Morogh, as QuestieDB lists
        -- them (object 694934) with HereBeDragons' world positions. The greedy pass alone gives three
        -- areas, two of which both cover 3 logs around (56-57, 53.5).
        local FINDING_WARMTH_LOGS = {
            {49.8, 51.6, -650.567, -5571.283}, {50.8, 49.9, -699.817, -5515.467}, {51.3, 52, -724.442, -5584.417},
            {52.4, 50.4, -778.617, -5531.883}, {52.4, 50.5, -778.617, -5535.167}, {52.5, 50.4, -783.542, -5531.883},
            {54, 46.8, -857.417, -5413.683}, {54.2, 45.3, -867.267, -5364.433}, {55.4, 45.8, -926.367, -5380.850},
            {55.5, 45.8, -931.292, -5380.850}, {55.9, 48.6, -950.992, -5472.783}, {55.9, 53.4, -950.992, -5630.383},
            {56, 52.2, -955.917, -5590.983}, {56, 53.5, -955.917, -5633.667}, {56.4, 55.4, -975.617, -5696.050},
            {56.4, 55.5, -975.617, -5699.333}, {56.5, 55.6, -980.542, -5702.617}, {56.6, 50.9, -985.467, -5548.300},
            {57, 53.4, -1005.167, -5630.383}, {57, 53.5, -1005.167, -5633.667}, {57.2, 54.9, -1015.017, -5679.633},
            {57.4, 46.4, -1024.867, -5400.550}, {57.4, 46.5, -1024.867, -5403.833}, {57.5, 46.4, -1029.792, -5400.550},
            {57.6, 48.6, -1034.717, -5472.783}, {58.2, 52, -1064.267, -5584.417}, {58.3, 54.4, -1069.192, -5663.217},
            {58.3, 54.5, -1069.192, -5666.500}, {58.3, 56.2, -1069.192, -5722.317}, {58.4, 58.6, -1074.117, -5801.117},
            {58.5, 58.6, -1079.042, -5801.117}, {58.6, 57.1, -1083.967, -5751.867}, {59.8, 58.6, -1143.067, -5801.117},
            {60.1, 53, -1157.842, -5617.250},
        }

        ---Inside or on a convex outline, in either winding.
        local function Inside(outline, point)
            local side = 0
            for i, a in ipairs(outline) do
                local b = outline[i % #outline + 1]
                local cross = (b.x - a.x) * (point.y - a.y) - (b.y - a.y) * (point.x - a.x)
                if cross ~= 0 then
                    local sign = cross > 0 and 1 or -1
                    if side == 0 then side = sign elseif sign ~= side then return false end
                end
            end
            return true
        end

        it("never puts one of Finding Warmth's logs inside two of its areas", function()
            local logs = {}
            for i, log in ipairs(FINDING_WARMTH_LOGS) do
                logs[i] = {x = log[1], y = log[2], worldX = log[3], worldY = log[4], uiMapId = 1426, instanceId = 0,
                    isObject = true}
            end

            local result = _Build(logs)

            local areas = {}
            for _, cluster in ipairs(result) do
                if cluster.outline then areas[#areas + 1] = cluster.outline end
            end
            assert.is_true(#areas >= 2, "the logs should still need more than one area")
            for _, log in ipairs(logs) do
                local containing = 0
                for _, outline in ipairs(areas) do
                    if Inside(outline, log) then containing = containing + 1 end
                end
                assert.is_true(containing <= 1, string.format("log at %.1f, %.1f lies inside %d areas", log.x, log.y, containing))
            end
        end)
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

    it("smooths sharp corners without reaching into a neighboring area", function()
        -- The spawns on the hull corners of two neighboring Murloc Eye areas in Westfall (Westfall Stew,
        -- quest 38), with HereBeDragons' world positions. Their hulls are apart, but the second area's
        -- corner at (32.5, 26.25), where a long edge meets short ones, faces the first area's corner
        -- at (32.42, 26.63). Evenly timed smoothing overshoots such a corner, and the outlines overlapped.
        local function Area(corners)
            local points = {}
            for i, corner in ipairs(corners) do
                points[i] = {x = corner[1], y = corner[2], worldX = corner[3], worldY = corner[4], uiMapId = 1436,
                    instanceId = 0}
            end
            -- The radius is wider than either area, so each is one cluster.
            local result = _Build(points, {radius = 1000})
            assert.are_equal(1, #result)
            return result[1].outline
        end
        ---Whether some edge's normal separates the two convex outlines; touching counts as apart.
        local function Separated(a, b)
            for _, outline in ipairs({a, b}) do
                for i, p in ipairs(outline) do
                    local q = outline[i % #outline + 1]
                    local normalX, normalY = q.y - p.y, p.x - q.x
                    local minA, maxA, minB, maxB = math.huge, -math.huge, math.huge, -math.huge
                    for _, v in ipairs(a) do
                        local s = v.x * normalX + v.y * normalY
                        minA, maxA = math.min(minA, s), math.max(maxA, s)
                    end
                    for _, v in ipairs(b) do
                        local s = v.x * normalX + v.y * normalY
                        minB, maxB = math.min(minB, s), math.max(maxB, s)
                    end
                    if maxA <= minB or maxB <= minA then return true end
                end
            end
            return false
        end

        local first = Area({
            {26.52, 40.58, 2088.467, -10346.866}, {26.6, 36.51, 2085.667, -10251.899}, {28.26, 28.19, 2027.567, -10057.766},
            {28.73, 27.18, 2011.117, -10034.199}, {29.26, 26.43, 1992.567, -10016.699}, {30.26, 25.39, 1957.567, -9992.433},
            {31.76, 26.12, 1905.067, -10009.466}, {32.42, 26.63, 1881.967, -10021.366}, {30.8, 35.11, 1938.667, -10219.233},
            {27.58, 40.66, 2051.367, -10348.733},
        })
        local second = Area({
            {32.25, 25.4, 1887.917, -9992.666}, {32.92, 17.54, 1864.467, -9809.266}, {33.45, 15.14, 1845.917, -9753.266},
            {38.5, 14.29, 1669.167, -9733.433}, {38.87, 14.7, 1656.217, -9742.999}, {39.02, 15.41, 1650.967, -9759.566},
            {38.79, 16.19, 1659.017, -9777.766}, {36.12, 22.05, 1752.467, -9914.499}, {32.5, 26.25, 1879.167, -10012.499},
        })

        assert.is_true(Separated(first, second))
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

    it("keeps the full outline when the tolerance would leave fewer than three vertices", function()
        local points = {
            {x = 10, y = 10, worldX = 0, worldY = 0, uiMapId = 1429, instanceId = 0},
            {x = 30, y = 10, worldX = 20, worldY = 0, uiMapId = 1429, instanceId = 0},
            {x = 30, y = 30, worldX = 20, worldY = 20, uiMapId = 1429, instanceId = 0},
            {x = 10, y = 30, worldX = 0, worldY = 20, uiMapId = 1429, instanceId = 0},
        }
        -- The spline envelope has no collinear vertices, so tolerance 0 keeps every one.
        local full = _Build(points, {tolerance = 0})[1].outline

        assert.are.equal(#full, #_Build(points, {tolerance = 1000})[1].outline)
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
