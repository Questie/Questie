dofile("setupTests.lua")

describe("MapGeometry", function()
    ---@type MapGeometry
    local MapGeometry

    before_each(function()
        dofile("Modules/Map/MapGeometry.lua")
        MapGeometry = QuestieLoader:ImportModule("MapGeometry")
    end)

    describe("Simplify", function()
        it("drops points within the tolerance of the line kept around them", function()
            local slight = {{x = 0, y = 0}, {x = 5, y = 0.2}, {x = 10, y = 0}}
            local bent = {{x = 0, y = 0}, {x = 5, y = 0.3}, {x = 10, y = 0}}

            assert.are_same({slight[1], slight[3]}, MapGeometry.Simplify(slight, 0.25))
            assert.are_same(bent, MapGeometry.Simplify(bent, 0.25))
        end)

        it("keeps a point where the line turns back along itself", function()
            -- The turning point lies on the line through its neighbours, but 5 past their segment.
            local backAndForth = {{x = 0, y = 0}, {x = 10, y = 0}, {x = 5, y = 0}}

            assert.are_same(backAndForth, MapGeometry.Simplify(backAndForth, 0.25))
        end)

        it("keeps both ends, so a closed polyline stays closed", function()
            local square = {{x = 0, y = 0}, {x = 5, y = 0.1}, {x = 10, y = 0}, {x = 10, y = 10}, {x = 0, y = 10}, {x = 0, y = 0}}

            local simplified = MapGeometry.Simplify(square, 0.25)

            assert.are_same({square[1], square[3], square[4], square[5], square[6]}, simplified)
            assert.are.equal(square[1], simplified[1])
            assert.are.equal(square[6], simplified[#simplified])
        end)

        it("treats the zero-length closing segment of a ring as a point, keeping its far vertices", function()
            local a = {x = 0, y = 0}
            local ring = {a, {x = 10, y = 0}, {x = 10, y = 10}, a}

            local simplified = MapGeometry.Simplify(ring, 0.25)

            assert.are.equal(4, #simplified)
            for i, point in ipairs(ring) do assert.are.equal(point, simplified[i]) end
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
            local quads = MapGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 20, y = 0}}, 2)

            assertCorners({0, 2, 0, -2, 10, 2, 10, -2}, quads[1])
            assertCorners({10, 2, 10, -2, 20, 2, 20, -2}, quads[2])
        end)

        it("caps each open end with a half disc beyond its point", function()
            local _, fills, caps = MapGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}}, 2)

            -- Kites from the end's point, 2 * sqrt(2) out along both normals and away from the segment.
            local reach = 2 * math.sqrt(2)
            assert.are.equal(2, #caps)
            assertCorners({0, 0, 0, reach, 0, -reach, -reach, 0}, caps[1])
            assertCorners({10, 0, 10, -reach, 10, reach, 10 + reach, 0}, caps[2])
            assert.are_same({}, fills)
        end)

        it("joins a right-angle turn on its bisector, lengthening the outer edges and shortening the inner", function()
            -- +x, then +y: the turn's inside is the left side.
            local quads, fills, caps = MapGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2)

            assertCorners({8, 2, 12, -2}, EndOf(quads[1]))
            assertCorners(EndOf(quads[1]), StartOf(quads[2]))
            assert.are_same({}, fills)
            -- Only the open ends have caps.
            assert.are.equal(2, #caps)
            assertCorners({0, 0}, {caps[1][1], caps[1][2]})
            assertCorners({10, 10}, {caps[2][1], caps[2][2]})
        end)

        it("ends a sharp turn's outer edges square at its point, fills each segment to it and caps the outside", function()
            -- A 150-degree turn to the left. The inner edges cross 2 * tan(75 degrees) = 2 + 2 * sqrt(3)
            -- before the turn, at (16 - 2 * sqrt(3), 2).
            local root3 = math.sqrt(3)
            local quads, fills, caps = MapGeometry.Quads({{x = 0, y = 0}, {x = 20, y = 0}, {x = 20 - 10 * root3, y = 10}}, 2)

            local innerX, innerY = 16 - 2 * root3, 2
            -- The first segment's outer corner is square at the turn; the second's lies off its own
            -- normal there, at 2 * (sin 30, cos 30) = (1, sqrt(3)).
            assertCorners({innerX, innerY, 20, -2}, EndOf(quads[1]))
            assertCorners({innerX, innerY, 21, root3}, StartOf(quads[2]))
            -- Each fill runs from its segment's corners at the turn to the turn's point.
            assert.are.equal(2, #fills)
            assertCorners({innerX, innerY, 20, -2, 20, 0, 20, 0}, fills[1])
            assertCorners({21, root3, innerX, innerY, 20, 0, 20, 0}, fills[2])
            -- The cap's kite, between the open ends' caps: the point, then 2 * sqrt(2) out along each outer
            -- normal and along the outward bisector, at -15 degrees: 2 * sqrt(2) * (cos 15, -sin 15) = (sqrt(3) + 1, 1 - sqrt(3)).
            assert.are.equal(3, #caps)
            local reach = 2 * math.sqrt(2)
            assertCorners({20, 0, 20, -reach, 20 + reach / 2, reach * root3 / 2, 21 + root3, 1 - root3}, caps[2])
        end)

        it("rounds a turn back on itself with a cap beyond its point", function()
            local quads, fills, caps = MapGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 0, y = 0}}, 2)

            assertCorners({10, 2, 10, -2}, EndOf(quads[1]))
            assertCorners({10, -2, 10, 2}, StartOf(quads[2]))
            assert.are_same({}, fills)
            local reach = 2 * math.sqrt(2)
            assertCorners({10, 0, 10, -reach, 10, reach, 10 + reach, 0}, caps[2])
        end)

        it("never pulls an inner corner back past half the shorter segment", function()
            -- The same hairpin would pull the inner edges back about 38 units without the limit.
            local quads = MapGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 0, y = 1}}, 2)

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
                    local quads, fills, caps = MapGeometry.Quads({{x = 0, y = 0}, {x = 3, y = 0},
                        {x = 3 - 10 * math.cos(angle), y = side * 10 * math.sin(angle)}}, 2)
                    assert.are.equal(3, #caps)
                    local pieces = {quads[1], quads[2]}
                    for _, list in ipairs({fills, caps}) do
                        for _, piece in ipairs(list) do pieces[#pieces + 1] = piece end
                    end
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
            local expected = {MapGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2)}

            assert.are_same(expected, {MapGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}}, 2)})
            assert.are_same({{}, {}, {}}, {MapGeometry.Quads({{x = 1, y = 1}, {x = 1, y = 1}}, 2)})
        end)

        it("joins a closed polyline where it returns to its start", function()
            local quads, _, caps = MapGeometry.Quads({{x = 0, y = 0}, {x = 10, y = 0}, {x = 10, y = 10}, {x = 0, y = 10}, {x = 0, y = 0}}, 2)

            assertCorners({2, 2, -2, -2}, StartOf(quads[1]))
            assertCorners(StartOf(quads[1]), EndOf(quads[4]))
            -- No open ends to cap.
            assert.are_same({}, caps)
        end)
    end)
end)
