dofile("setupTests.lua")

describe("WaypointGeometry", function()
    ---@type WaypointGeometry
    local WaypointGeometry

    -- A 1000x1000-yard zone on instance 0; map fractions scale straight to yards.
    local function toWorld(x, y, uiMapId)
        if uiMapId == 99 then return nil end
        return x * 1000, y * 1000, 0
    end

    before_each(function()
        dofile("Modules/Map/Waypoints/WaypointGeometry.lua")
        WaypointGeometry = QuestieLoader:ImportModule("WaypointGeometry")
    end)

    describe("BuildPolylines", function()
        it("keeps each patrol as its own polyline in percentages and world yards", function()
            local polylines = WaypointGeometry.BuildPolylines({{{10, 20}, {30, 40}}, {{50, 50}, {60, 50}}}, 1, toWorld)

            assert.are.equal(2, #polylines)
            assert.are_same({{x = 10, y = 20}, {x = 30, y = 40}}, polylines[1].points)
            assert.are_same({{x = 100, y = 200}, {x = 300, y = 400}}, polylines[1].world)
            assert.are_same({100, 200, 300, 400}, polylines[1].worldBounds)
            assert.are.equal(1, polylines[1].uiMapId)
            assert.are.equal(0, polylines[1].instanceId)
        end)

        it("merges consecutive points closer than the merge distance", function()
            -- 0.01% of a 1000-yard zone is 0.1 yards.
            local polylines = WaypointGeometry.BuildPolylines({{{10, 10}, {10.01, 10}, {20, 10}}}, 1, toWorld)

            assert.are_same({{x = 10, y = 10}, {x = 20, y = 10}}, polylines[1].points)
        end)

        it("keeps a patrol closed when the data returns to its start", function()
            local polylines = WaypointGeometry.BuildPolylines({{{10, 10}, {20, 10}, {20, 20}, {10, 10}}}, 1, toWorld)

            assert.are.equal(4, #polylines[1].points)
        end)

        it("splits a patrol at a point without a world position instead of bridging it", function()
            local polylines = WaypointGeometry.BuildPolylines({{{10, 10}, {20, 10}, {-1, -1}, {30, 30}, {40, 30}}}, 1, toWorld)

            assert.are.equal(2, #polylines)
            assert.are_same({{x = 30, y = 30}, {x = 40, y = 30}}, polylines[2].points)
        end)

        it("drops patrols that collapse to a single point and maps without world data", function()
            assert.are_same({}, WaypointGeometry.BuildPolylines({{{10, 10}, {10.01, 10}}}, 1, toWorld))
            assert.are_same({}, WaypointGeometry.BuildPolylines({{{10, 10}, {20, 10}}}, 99, toWorld))
        end)
    end)

    describe("CanProject", function()
        it("projects between ordinary zones only", function()
            assert.is_true(WaypointGeometry.CanProject(1429, 1433))
            assert.is_false(WaypointGeometry.CanProject(1429, 1429))
        end)

        it("keeps capitals out of projection in both directions", function()
            -- Stormwind City and Elwynn Forest.
            assert.is_false(WaypointGeometry.CanProject(1453, 1429))
            assert.is_false(WaypointGeometry.CanProject(1429, 1453))
        end)
    end)

    describe("Project", function()
        local polyline
        before_each(function()
            polyline = WaypointGeometry.BuildPolylines({{{10, 10}, {90, 10}}}, 1, toWorld)[1]
        end)

        it("converts to destination percentages and keeps vertices outside the map", function()
            -- The destination map is the source shifted 500 yards east.
            local projected = WaypointGeometry.Project(polyline, 2, function(x, y) return (x - 500) / 1000, y / 1000 end)

            assert.are_same({{x = -40, y = 10}, {x = 40, y = 10}}, projected)
        end)

        it("returns nil when the polyline does not reach the map or a point has no position there", function()
            assert.is_nil(WaypointGeometry.Project(polyline, 2, function(x, y) return (x + 2000) / 1000, y / 1000 end))
            assert.is_nil(WaypointGeometry.Project(polyline, 2, function() return nil end))
        end)
    end)

    describe("Quads", function()
        -- Quads are start left, start right, end left, end right corners as x, y pairs.
        local function assertCorners(expected, actual)
            assert.are.equal(#expected, #actual)
            for i, value in ipairs(expected) do
                assert.are.near(value, actual[i], 1e-9)
            end
        end

        local function EndOf(quad) return {quad[5], quad[6], quad[7], quad[8]} end
        local function StartOf(quad) return {quad[1], quad[2], quad[3], quad[4]} end

        it("squares open ends and keeps straight joins square", function()
            -- Heading +x, whose left normal is +y.
            local quads = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 20, y = 0}}, 2)

            assertCorners({0, 2, 0, -2, 10, 2, 10, -2}, quads[1])
            assertCorners({10, 2, 10, -2, 20, 2, 20, -2}, quads[2])
        end)

        it("joins a right-angle turn on its bisector, lengthening the outer edges and shortening the inner", function()
            -- +x, then +y: the turn's inside is the left side.
            local quads = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2)

            assertCorners({8, 2, 12, -2}, EndOf(quads[1]))
            assertCorners(EndOf(quads[1]), StartOf(quads[2]))
        end)

        it("caps the outer corner of a sharp turn instead of spiking", function()
            local quads = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 0, y = 1}}, 2)

            local outerX, outerY = quads[1][7], quads[1][8]
            assert.are.near(WaypointGeometry.MITER_LIMIT * 2, math.sqrt((outerX - 10) ^ 2 + outerY ^ 2), 1e-9)
        end)

        it("never pulls an inner corner back past half the shorter segment", function()
            -- The same hairpin would pull the inner edges back about 38 units without the limit.
            local quads = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 0, y = 1}}, 2)

            assert.are.near(5, 10 - quads[1][5], 1e-9)
        end)

        it("keeps quads convex where a short segment meets a sharp turn", function()
            -- The client splits a quad into two triangles along a fixed diagonal; a concave quad
            -- would draw outside its outline. Corners in order: start left, end left, end right, start right.
            local function IsConvex(quad)
                local corners = {{quad[1], quad[2]}, {quad[5], quad[6]}, {quad[7], quad[8]}, {quad[3], quad[4]}}
                local sign
                for i = 1, 4 do
                    local a, b, c = corners[i], corners[i % 4 + 1], corners[(i + 1) % 4 + 1]
                    local cross = (b[1] - a[1]) * (c[2] - b[2]) - (b[2] - a[2]) * (c[1] - b[1])
                    if math.abs(cross) > 1e-9 then
                        if sign and (cross > 0) ~= sign then return false end
                        sign = cross > 0
                    end
                end
                return true
            end
            -- A 120-degree turn after a segment shorter than the full miter's pull-back, both ways.
            for _, turn in ipairs({1, -1}) do
                local quads = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 3, y = 0}, {x = 3 - 5, y = turn * 5 * math.sqrt(3)}}, 2)
                assert.is_true(IsConvex(quads[1]))
                assert.is_true(IsConvex(quads[2]))
            end
        end)

        it("skips repeated points", function()
            local expected = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2)

            assert.are_same(expected, WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2))
            assert.are_same({}, WaypointGeometry.Quads({{x = 1, y = 1}, {x = 1, y = 1}}, 2))
        end)

        it("joins a closed patrol where it returns to its start", function()
            local quads = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}, {x = 0, y = 10}, {x = 0, y = 0}}, 2)

            assertCorners({2, 2, -2, -2}, StartOf(quads[1]))
            assertCorners(StartOf(quads[1]), EndOf(quads[4]))
        end)
    end)

    describe("SegmentDistanceSq", function()
        it("measures to the segment, not its infinite line", function()
            assert.are.equal(9, WaypointGeometry.SegmentDistanceSq(5, 3, 0, 0, 10, 0))
            -- Beyond an end, the distance is to the endpoint: hover is round there.
            assert.are.equal(25, WaypointGeometry.SegmentDistanceSq(13, 4, 0, 0, 10, 0))
        end)

        it("treats a zero-length segment as a point", function()
            assert.are.equal(25, WaypointGeometry.SegmentDistanceSq(3, 4, 0, 0, 0, 0))
        end)
    end)

    describe("Nearest", function()
        local function target(points)
            return {points = points, bounds = WaypointGeometry.Bounds(points)}
        end

        it("covers the outside of a sharp turn, where rectangles per segment leave a gap", function()
            -- A narrow V pointing right; the cursor sits just beyond its tip.
            local v = target({{x = 0, y = 0}, {x = 100, y = 5}, {x = 0, y = 10}})

            assert.are.equal(v, WaypointGeometry.Nearest({v}, 105, 5, 6))
        end)

        it("hovers a very short polyline as a disc", function()
            local dot = target({{x = 50, y = 50}, {x = 50.1, y = 50}})

            assert.are.equal(dot, WaypointGeometry.Nearest({dot}, 50, 55, 6))
            assert.is_nil(WaypointGeometry.Nearest({dot}, 50, 57, 6))
        end)

        it("picks the nearest of overlapping polylines", function()
            local near = target({{x = 0, y = 2}, {x = 100, y = 2}})
            local far = target({{x = 0, y = -4}, {x = 100, y = -4}})

            assert.are.equal(near, WaypointGeometry.Nearest({far, near}, 50, 0, 6))
        end)
    end)
end)
