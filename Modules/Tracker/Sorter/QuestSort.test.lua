dofile("setupTests.lua")

describe("QuestSort", function()
    ---@type QuestSort
    local QuestSort

    local typePriorities

    ---@param fields table? Sort details besides the quest itself.
    local function _Details(questId, level, fields)
        local details = fields or {}
        details.quest = {Id = questId, level = level}
        return details
    end

    ---@return QuestId[] questIds In the order the named quest sort lists the given quests.
    local function _SortedIds(sortName, reversed, detailsList)
        table.sort(detailsList, QuestSort.Get(sortName, reversed).compare)

        local questIds = {}
        for index, details in ipairs(detailsList) do
            questIds[index] = details.quest.Id
        end
        return questIds
    end

    before_each(function()
        typePriorities = {}
        QuestieLoader:ImportModule("QuestieLib").GetQuestTypeSuffixPriority = function(questId)
            return typePriorities[questId] or 0
        end

        dofile("Modules/Tracker/Sorter/QuestSort.lua")
        QuestSort = QuestieLoader:ImportModule("QuestSort")
    end)

    it("has no sort for a name it does not know", function()
        assert.is_nil(QuestSort.Get("somethingNewer", false))
    end)

    describe("level", function()
        local function _Quests()
            typePriorities[2] = 7
            return {_Details(5, 10), _Details(2, 10), _Details(9, 3), _Details(4, 10)}
        end

        it("lists lower levels first, then by quest type priority, then by quest ID", function()
            assert.are.same({9, 4, 5, 2}, _SortedIds("level", false, _Quests()))
        end)

        it("lists higher levels first when reversed, keeping type and ID order within a level", function()
            assert.are.same({4, 5, 2, 9}, _SortedIds("level", true, _Quests()))
        end)
    end)

    describe("complete", function()
        local function _Quests()
            return {
                _Details(1, 20, {questCompletePercent = 1}),
                _Details(2, 10, {questCompletePercent = 0.5}),
                _Details(3, 5, {questCompletePercent = 0.5}),
                _Details(4, 1, {questCompletePercent = 0}),
            }
        end

        it("lists the most complete quests first, lowest level first among equals", function()
            assert.are.same({1, 3, 2, 4}, _SortedIds("complete", false, _Quests()))
        end)

        it("lists the least complete quests first when reversed, still lowest level first among equals", function()
            assert.are.same({4, 3, 2, 1}, _SortedIds("complete", true, _Quests()))
        end)
    end)

    describe("proximity", function()
        local function _Quests()
            return {
                _Details(1, 10, {distance = 30, isOnPlayerContinent = true}),
                _Details(2, 10, {distance = 10, isOnPlayerContinent = true}),
                _Details(3, 10, {isOnPlayerContinent = false}),
                _Details(4, 10, {distance = 1, isOnPlayerContinent = false}),
                _Details(5, 5, {distance = 30, isOnPlayerContinent = true}),
                _Details(6, 10, {distance = 30, isOnPlayerContinent = true}),
            }
        end

        it("lists the player's continent first, nearest first, with unknown locations last and level order among equals", function()
            assert.are.same({2, 5, 1, 6, 4, 3}, _SortedIds("proximity", false, _Quests()))
        end)

        it("lists the exact opposite order when reversed", function()
            assert.are.same({3, 4, 6, 1, 5, 2}, _SortedIds("proximity", true, _Quests()))
        end)
    end)
end)
