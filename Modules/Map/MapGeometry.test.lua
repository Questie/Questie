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
end)
