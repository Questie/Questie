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
