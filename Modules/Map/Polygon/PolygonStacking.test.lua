dofile("setupTests.lua")

describe("PolygonStacking", function()
    ---@type PolygonStacking
    local PolygonStacking

    local function Outline(coordinates)
        local points = {}
        for i = 1, #coordinates, 2 do points[#points + 1] = {x = coordinates[i], y = coordinates[i + 1]} end
        return points
    end

    local function Square(minX, minY, maxX, maxY)
        return Outline({minX, minY, maxX, minY, maxX, maxY, minX, maxY})
    end

    before_each(function()
        dofile("Modules/Map/Polygon/PolygonStacking.lua")
        PolygonStacking = QuestieLoader:ImportModule("PolygonStacking")
    end)

    it("puts an outline one level above the highest larger outline it overlaps", function()
        local big = Square(0, 0, 60, 60)
        -- Turning the other way, as an outline projected onto a mirrored map does.
        local medium = Outline({10, 10, 10, 40, 40, 40, 40, 10})
        local inMedium = Square(20, 20, 30, 30)
        -- Smaller than the medium outline, but beside it: only the big outline lies beneath.
        local besideMedium = Square(45, 45, 55, 55)
        local apart = Square(80, 80, 90, 90)

        local levels = PolygonStacking.Levels({inMedium, apart, big, besideMedium, medium}, 10, 16)

        assert.are.same({12, 10, 10, 11, 11}, levels)
    end)

    it("stacks outlines only where they overlap, not where their bounds do", function()
        -- Their bounds overlap, but the line x + y = 45 runs between the triangles.
        local lowerLeft, upperRight = Outline({0, 0, 40, 0, 0, 40}), Outline({40, 10, 40, 40, 10, 40})

        assert.are.same({10, 10}, PolygonStacking.Levels({lowerLeft, upperRight}, 10, 16))
    end)

    it("stacks no outline that only grazes a larger one", function()
        -- 10 wide, so overlaps under 0.2, 2% of its size, are grazes.
        local grazing, overlapping = Square(59.9, 10, 69.9, 20), Square(59, 30, 69, 40)

        assert.are.same({10, 10, 11}, PolygonStacking.Levels({Square(0, 0, 60, 60), grazing, overlapping}, 10, 16))
    end)

    it("never stacks outlines of equal size, such as two objectives' identical areas", function()
        assert.are.same({10, 10}, PolygonStacking.Levels({Square(0, 0, 20, 20), Square(0, 0, 20, 20)}, 10, 16))
    end)

    it("lets a stack deeper than its levels share the last one", function()
        local nested = {Square(0, 0, 80, 80), Square(10, 10, 70, 70), Square(20, 20, 60, 60), Square(30, 30, 50, 50)}

        assert.are.same({10, 11, 11, 11}, PolygonStacking.Levels(nested, 10, 11))
    end)
end)
