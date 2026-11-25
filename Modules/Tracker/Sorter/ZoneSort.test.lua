dofile("setupTests.lua")

describe("ZoneSort", function()
    ---@type ZoneSort
    local ZoneSort

    local groups, questDetails

    ---@return string[] names Group names in the order the named zone sort lists them.
    local function _OrderedNames(sortName, reversed)
        ZoneSort.Get(sortName, reversed).order(groups, questDetails)

        local names = {}
        for index, group in ipairs(groups) do
            names[index] = group.name
        end
        return names
    end

    before_each(function()
        dofile("Modules/Tracker/Sorter/ZoneSort.lua")
        ZoneSort = QuestieLoader:ImportModule("ZoneSort")

        groups = {
            {name = "Zulu", questIds = {1, 3}},
            {name = "Alpha", questIds = {2}},
            {name = "Mike", questIds = {4, 5}},
            {name = "Echo", questIds = {6}},
            {name = "Bravo", questIds = {7}},
        }
        questDetails = {
            [1] = {isShown = true, distance = 30},
            [2] = {isShown = true, distance = 100},
            [3] = {isShown = true, distance = 10},
            [4] = {isShown = true, distance = 50},
            [5] = {isShown = false, distance = 1},
            [6] = {isShown = true},
            [7] = {isShown = true},
        }
    end)

    it("has no sort for \"none\" or for a name it does not know", function()
        assert.is_nil(ZoneSort.Get("none", false))
        assert.is_nil(ZoneSort.Get("somethingNewer", false))
    end)

    it("orders groups by name", function()
        assert.are.same({"Alpha", "Bravo", "Echo", "Mike", "Zulu"}, _OrderedNames("alphabetical", false))
    end)

    it("orders groups by name from Z to A when reversed", function()
        assert.are.same({"Zulu", "Mike", "Echo", "Bravo", "Alpha"}, _OrderedNames("alphabetical", true))
    end)

    it("orders groups by their nearest shown quest, with unknown locations last by name", function()
        assert.are.same({"Zulu", "Mike", "Alpha", "Bravo", "Echo"}, _OrderedNames("proximity", false))
    end)

    it("orders the farthest group first when reversed, still with unknown locations last by name", function()
        assert.are.same({"Alpha", "Mike", "Zulu", "Bravo", "Echo"}, _OrderedNames("proximity", true))
    end)

    it("orders groups at the same distance by name", function()
        questDetails[2].distance = 10

        assert.are.same({"Alpha", "Zulu", "Mike", "Bravo", "Echo"}, _OrderedNames("proximity", false))
    end)
end)
