dofile("setupTests.lua")

describe("Sorter", function()
    ---@type Sorter
    local Sorter
    ---@type QuestSort
    local QuestSort
    ---@type ZoneSort
    local ZoneSort

    local function _Details(questId, zoneName, level)
        return {quest = {Id = questId, level = level}, zoneName = zoneName}
    end

    before_each(function()
        QuestieLoader:ImportModule("QuestieLib").GetQuestTypeSuffixPriority = function() return 0 end

        dofile("Modules/Tracker/Sorter/Sorter.lua")
        dofile("Modules/Tracker/Sorter/QuestSort.lua")
        dofile("Modules/Tracker/Sorter/ZoneSort.lua")
        Sorter = QuestieLoader:ImportModule("Sorter")
        QuestSort = QuestieLoader:ImportModule("QuestSort")
        ZoneSort = QuestieLoader:ImportModule("ZoneSort")
    end)

    describe("GetSorts", function()
        it("returns no sorts for a setting value it does not know", function()
            local questSort, zoneSort = Sorter.GetSorts("bySomethingNewer")

            assert.is_nil(questSort)
            assert.is_nil(zoneSort)
        end)
    end)

    describe("Sort", function()
        local questDetails

        before_each(function()
            questDetails = {
                [1] = _Details(1, "Zulu", 10),
                [2] = _Details(2, "Alpha", 5),
                [3] = _Details(3, "Zulu", 2),
                [4] = _Details(4, "Alpha", 1),
            }
        end)

        it("orders the groups by the zone sort and the quests of each group by the quest sort", function()
            local groups = Sorter.Sort(questDetails, QuestSort.sorts.level, ZoneSort.sorts.alphabetical)

            assert.are.same({
                {name = "Alpha", questIds = {4, 2}},
                {name = "Zulu", questIds = {3, 1}},
            }, groups)
        end)

        it("combines a zone sort and a quest sort that no setting pairs", function()
            questDetails[1].distance, questDetails[1].isShown = 5, true
            questDetails[2].distance, questDetails[2].isShown = 50, true

            local groups = Sorter.Sort(questDetails, QuestSort.sorts.levelReversed, ZoneSort.sorts.proximity)

            assert.are.same({
                {name = "Zulu", questIds = {1, 3}},
                {name = "Alpha", questIds = {2, 4}},
            }, groups)
        end)

        it("lists quests that share a group name under one group without a zone sort", function()
            for _, details in pairs(questDetails) do
                details.zoneName = "Quests"
            end

            local groups = Sorter.Sort(questDetails, QuestSort.sorts.level, nil)

            assert.are.same({{name = "Quests", questIds = {4, 3, 2, 1}}}, groups)
        end)
    end)
end)
