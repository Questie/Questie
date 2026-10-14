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

        it("drops points a patrol runs straight on through, but keeps where it turns back", function()
            -- QuestieDB splits long segments into evenly spaced points.
            local polylines = WaypointGeometry.BuildPolylines({{{10, 10}, {12, 10}, {14, 10}, {20, 10}, {20, 15}, {20, 20}}}, 1, toWorld)

            assert.are_same({{x = 10, y = 10}, {x = 20, y = 10}, {x = 20, y = 20}}, polylines[1].points)
            assert.are_same({{x = 100, y = 100}, {x = 200, y = 100}, {x = 200, y = 200}}, polylines[1].world)

            local backAndForth = WaypointGeometry.BuildPolylines({{{10, 10}, {20, 10}, {15, 10}}}, 1, toWorld)
            assert.are.equal(3, #backAndForth[1].points)
        end)

        it("keeps a slow arc's shape, though it turns too little at each point to count", function()
            -- Each 10-yard step turns 0.05 degrees, 3 in all: a straight line would miss its middle by 4 yards.
            local patrol, x, y = {}, 10, 20
            for i = 0, 60 do
                patrol[#patrol + 1] = {x, y}
                local heading = math.rad(0.05 * i)
                x, y = x + math.cos(heading), y + math.sin(heading)
            end

            local kept = WaypointGeometry.BuildPolylines({patrol}, 1, toWorld)[1].world

            for _, coords in ipairs(patrol) do
                local nearestSq = math.huge
                for i = 2, #kept do
                    local a, b = kept[i - 1], kept[i]
                    nearestSq = math.min(nearestSq, WaypointGeometry.SegmentDistanceSq(coords[1] * 10, coords[2] * 10, a.x, a.y, b.x, b.y))
                end
                assert.is_true(nearestSq < 0.1 * 0.1)
            end
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
            local quads, fills, caps = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2)

            assertCorners({8, 2, 12, -2}, EndOf(quads[1]))
            assertCorners(EndOf(quads[1]), StartOf(quads[2]))
            assert.are_same({}, fills)
            assert.are_same({}, caps)
        end)

        it("ends a sharp turn's outer edges square at its point, fills each segment to it and caps the outside", function()
            -- A 150-degree turn to the left. The inner edges cross 2 * tan(75 degrees) = 2 + 2 * sqrt(3)
            -- before the turn, at (16 - 2 * sqrt(3), 2).
            local root3 = math.sqrt(3)
            local quads, fills, caps = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 20, y = 0}, {x = 20 - 10 * root3, y = 10}}, 2)

            local innerX, innerY = 16 - 2 * root3, 2
            -- The first segment's outer corner is square at the turn; the second's lies off its own
            -- normal there, at 2 * (sin 30, cos 30) = (1, sqrt(3)).
            assertCorners({innerX, innerY, 20, -2}, EndOf(quads[1]))
            assertCorners({innerX, innerY, 21, root3}, StartOf(quads[2]))
            -- Each fill runs from its segment's corners at the turn to the turn's point.
            assert.are.equal(2, #fills)
            assertCorners({innerX, innerY, 20, -2, 20, 0, 20, 0}, fills[1])
            assertCorners({21, root3, innerX, innerY, 20, 0, 20, 0}, fills[2])
            -- The cap's kite: the point, then 2 * sqrt(2) out along each outer normal and along the
            -- outward bisector, at -15 degrees: 2 * sqrt(2) * (cos 15, -sin 15) = (sqrt(3) + 1, 1 - sqrt(3)).
            assert.are.equal(1, #caps)
            local reach = 2 * math.sqrt(2)
            assertCorners({20, 0, 20, -reach, 20 + reach / 2, reach * root3 / 2, 21 + root3, 1 - root3}, caps[1])
        end)

        it("rounds a turn back on itself with a cap beyond its point", function()
            local quads, fills, caps = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 0, y = 0}}, 2)

            assertCorners({10, 2, 10, -2}, EndOf(quads[1]))
            assertCorners({10, -2, 10, 2}, StartOf(quads[2]))
            assert.are_same({}, fills)
            local reach = 2 * math.sqrt(2)
            assertCorners({10, 0, 10, -reach, 10, reach, 10 + reach, 0}, caps[1])
        end)

        it("never pulls an inner corner back past half the shorter segment", function()
            -- The same hairpin would pull the inner edges back about 38 units without the limit.
            local quads = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 0, y = 1}}, 2)

            assert.are.near(5, 10 - quads[1][5], 1e-9)
        end)

        it("keeps every quad, fill and cap convex and wound the same way, where a short segment meets a sharp turn", function()
            -- The client splits a quad into two triangles along a fixed diagonal; a concave quad
            -- would draw outside its outline. Corners in order: start left, end left, end right, start right.
            -- Returns whether the quad is convex, and which way its corners go around.
            local function Winding(quad)
                local corners = {{quad[1], quad[2]}, {quad[5], quad[6]}, {quad[7], quad[8]}, {quad[3], quad[4]}}
                local sign
                for i = 1, 4 do
                    local a, b, c = corners[i], corners[i % 4 + 1], corners[(i + 1) % 4 + 1]
                    local cross = (b[1] - a[1]) * (c[2] - b[2]) - (b[2] - a[2]) * (c[1] - b[1])
                    if math.abs(cross) > 1e-9 then
                        if sign ~= nil and (cross > 0) ~= sign then return false end
                        sign = cross > 0
                    end
                end
                return true, sign
            end
            -- Turns past 120 degrees after a segment shorter than the full miter's pull-back, both ways,
            -- and turning back: 179.95 degrees falls within the turn-back's tolerance.
            for _, degrees in ipairs({120.5, 150, 179, 179.95, 180}) do
                for _, side in ipairs({1, -1}) do
                    local angle = math.rad(180 - degrees)
                    local quads, fills, caps = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 3, y = 0},
                        {x = 3 - 10 * math.cos(angle), y = side * 10 * math.sin(angle)}}, 2)
                    assert.are.equal(1, #caps)
                    local pieces = {quads[1], quads[2], caps[1]}
                    for _, fill in ipairs(fills) do pieces[#pieces + 1] = fill end
                    local _, expected = Winding(quads[1])
                    for _, quad in ipairs(pieces) do
                        local convex, sign = Winding(quad)
                        assert.is_true(convex)
                        assert.are.equal(expected, sign)
                    end
                    -- Each fill starts at its own segment's corners at the turn, which differ here:
                    -- the pull-back stops short of where the inner edges cross.
                    if fills[1] then
                        assertCorners(EndOf(quads[1]), StartOf(fills[1]))
                        local start = StartOf(quads[2])
                        assertCorners({start[3], start[4], start[1], start[2]}, StartOf(fills[2]))
                    end
                end
            end
        end)

        it("skips repeated points", function()
            local expected = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2)

            assert.are_same(expected, (WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2)))
            assert.are_same({}, (WaypointGeometry.Quads({{x = 1, y = 1}, {x = 1, y = 1}}, 2)))
        end)

        it("joins a closed patrol where it returns to its start", function()
            local quads = WaypointGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}, {x = 0, y = 10}, {x = 0, y = 0}}, 2)

            assertCorners({2, 2, -2, -2}, StartOf(quads[1]))
            assertCorners(StartOf(quads[1]), EndOf(quads[4]))
        end)
    end)

    describe("Smooth", function()
        -- Smoothed with a tolerance of 1 for a line 4 wide.
        local function Smooth(polyline)
            return WaypointGeometry.Smooth(polyline, 1, 2)
        end

        local function DistanceTo(polyline, x, y)
            local nearest = math.huge
            for i = 2, #polyline do
                local a, b = polyline[i - 1], polyline[i]
                nearest = math.min(nearest, WaypointGeometry.SegmentDistanceSq(x, y, a.x, a.y, b.x, b.y))
            end
            return math.sqrt(nearest)
        end

        -- Segments of the given length meeting at the origin, turning by degrees.
        local function Turn(degrees, length)
            length = length or 100
            local turn = math.rad(degrees)
            return {{x = -length, y = 0}, {x = 0, y = 0}, {x = length * math.cos(turn), y = length * math.sin(turn)}}
        end

        it("rounds a corner, passing it at the tolerance, and keeps both ends", function()
            local bend = Turn(60)

            local smoothed = Smooth(bend)

            assert.are.equal(bend[1], smoothed[1])
            assert.are.equal(bend[3], smoothed[#smoothed])
            assert.are.near(1, DistanceTo(smoothed, 0, 0), 1e-9)
        end)

        it("stays within the tolerance of the patrol, and uses it where segments allow", function()
            for degrees = 10, 80, 10 do
                for _, length in ipairs({3, 10, 100}) do
                    local polyline = Turn(degrees, length)

                    local smoothed = Smooth(polyline)

                    for _, point in ipairs(smoothed) do
                        assert.is_true(DistanceTo(polyline, point.x, point.y) <= 1 + 1e-9)
                    end
                    local passes = DistanceTo(smoothed, 0, 0)
                    assert.is_true(passes <= 1 + 1e-9)
                    -- Short segments limit the curve to half of each.
                    if length == 100 then assert.are.near(1, passes, 1e-9) end
                end
            end
        end)

        it("keeps corners sharp where the line cannot follow the curve, so no two pieces overlap, trimmed or not", function()
            -- A join pulls its inner edges back halfWidth * tan(join / 2). Within half of each
            -- segment, neighbouring quads meet without overlapping.
            for _, tolerance in ipairs({0.5, 1, 2, 4}) do
                for degrees = 10, 170, 10 do
                    local smoothed = WaypointGeometry.Smooth(Turn(degrees), tolerance, 2)
                    for _, points in ipairs({smoothed, WaypointGeometry.Trim(smoothed, 0.25)}) do
                        for i = 2, #points - 1 do
                            local a, p, b = points[i - 1], points[i], points[i + 1]
                            local inX, inY, outX, outY = p.x - a.x, p.y - a.y, b.x - p.x, b.y - p.y
                            local inLength, outLength = math.sqrt(inX * inX + inY * inY), math.sqrt(outX * outX + outY * outY)
                            local join = math.acos(math.min(1, (inX * outX + inY * outY) / (inLength * outLength)))
                            assert.is_true(2 * math.tan(join / 2) <= math.min(inLength, outLength) / 2 + 1e-9)
                        end
                    end
                end
            end
            assert.are_same(Turn(120), Smooth(Turn(120)))
        end)

        it("leaves straight runs and corners hidden in the line's join sharp", function()
            local straight = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 20, y = 0}}

            assert.are_same(straight, Smooth(straight))
            assert.are_same(Turn(10, 0.5), Smooth(Turn(10, 0.5)))
        end)

        it("joins curves meeting in a segment's middle at one point", function()
            -- Both turns take half of the segment between them. Here, their computed ends differ by rounding.
            local turn = math.rad(30)
            local p = {x = 471.19, y = 471.19 / 3}
            local q = {x = p.x + 3.7 * math.cos(turn), y = p.y + 3.7 * math.sin(turn)}
            local polyline = {{x = p.x - 10, y = p.y}, p, q, {x = q.x + 10 * math.cos(2 * turn), y = q.y + 10 * math.sin(2 * turn)}}

            local smoothed = Smooth(polyline)

            local middleX, middleY = (p.x + q.x) / 2, (p.y + q.y) / 2
            local middles = 0
            for i, point in ipairs(smoothed) do
                if math.abs(point.x - middleX) < 1e-6 and math.abs(point.y - middleY) < 1e-6 then middles = middles + 1 end
                if i > 1 then
                    assert.is_true(math.abs(point.x - smoothed[i - 1].x) + math.abs(point.y - smoothed[i - 1].y) > 1e-6)
                end
            end
            assert.are.equal(1, middles)
        end)

        it("keeps a closed polyline closed, whether its start is rounded or stays sharp", function()
            -- A hexagon turns 60 degrees at each corner, a triangle more than the line can follow.
            local hexagon = {}
            for i = 0, 6 do
                local angle = math.rad(60 * (i % 6))
                hexagon[i + 1] = {x = 10 * math.cos(angle), y = 10 * math.sin(angle)}
            end
            local triangle = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 5, y = 8}, {x = 0, y = 0}}

            local smoothed = Smooth(hexagon)

            assert.are.equal(smoothed[1], smoothed[#smoothed])
            assert.are.near(1, DistanceTo(smoothed, hexagon[1].x, hexagon[1].y), 1e-9)
            assert.are_same(triangle, Smooth(triangle))
        end)
    end)

    describe("Trim", function()
        it("drops points within the tolerance of the line kept around them", function()
            local slight = {{x = 0, y = 0}, {x = 5, y = 0.2}, {x = 10, y = 0}}
            local bent = {{x = 0, y = 0}, {x = 5, y = 0.3}, {x = 10, y = 0}}

            assert.are_same({slight[1], slight[3]}, WaypointGeometry.Trim(slight, 0.25))
            assert.are_same(bent, WaypointGeometry.Trim(bent, 0.25))
        end)

        it("keeps a patrol's turning point where it walks back along itself", function()
            -- The turning point lies on the line through its neighbours, but 5 past their segment.
            local backAndForth = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 5, y = 0}}

            assert.are_same(backAndForth, WaypointGeometry.Trim(backAndForth, 0.25))
        end)

        it("keeps both ends, so a closed polyline stays closed", function()
            local square = {{x = 0, y = 0}, {x = 5, y = 0.1}, {x = 10, y = 0}, {x = 10, y = 10}, {x = 0, y = 10}, {x = 0, y = 0}}

            local trimmed = WaypointGeometry.Trim(square, 0.25)

            assert.are_same({square[1], square[3], square[4], square[5], square[6]}, trimmed)
            assert.are.equal(square[1], trimmed[1])
            assert.are.equal(square[6], trimmed[#trimmed])
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
