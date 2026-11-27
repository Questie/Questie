dofile("setupTests.lua")

describe("JourneySummary", function()
    ---@type JourneySummary
    local JourneySummary
    local originalUnitLevel
    ---@type table<QuestId, JourneyQuestCategory> What the quests are, tested with JourneyQuestCategories
    local categories
    local unlisted, completeQuests, levels

    before_each(function()
        originalUnitLevel = _G.UnitLevel
        _G.UnitLevel = function() return 10 end
        categories, unlisted, completeQuests, levels = {}, {}, {}, {}

        QuestieLoader:ImportModule("JourneyThread").YieldIfNeeded = function() end
        -- Its rule of which categories count towards the total is used as it is
        dofile("Modules/Journey/Data/JourneyQuestCategories.lua")
        local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
        JourneyQuestCategories.IsListed = function(questId) return not unlisted[questId] end
        JourneyQuestCategories.Get = function(questId) return categories[questId] end
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.IsComplete = function(questId) return completeQuests[questId] and 1 or 0 end
        QuestieDB.IsTrivial = function(level) return level < 6 end -- Too low for the player
        QuestieLoader:ImportModule("QuestieLib").GetEffectiveQuestLevel = function(questId) return levels[questId] or 10 end

        dofile("Modules/Journey/Data/JourneySummary.lua")
        JourneySummary = QuestieLoader:ImportModule("JourneySummary")
    end)

    after_each(function()
        _G.UnitLevel = originalUnitLevel
    end)

    ---@return table<QuestId, boolean> questIds All quests that have a category, or are unlisted
    local function AllQuests()
        local questIds = {}
        for questId in pairs(categories) do questIds[questId] = true end
        for questId in pairs(unlisted) do questIds[questId] = true end
        return questIds
    end

    it("should count the quests of each category, and those in the log that are complete", function()
        categories = {"log", "log", "available", "repeatable", "later", "completed", "completed", "unobtainable"}
        completeQuests[2] = true
        -- Neither counts: one isn't listed, the other has no category, like one for another race
        unlisted[9], categories[9] = true, "available"
        local questIds = AllQuests()
        questIds[10] = true

        local summary = JourneySummary.Count("zone:12", questIds)

        assert.are_same(
            {log = 2, complete = 1, available = 1, later = 1, completed = 2, total = 6},
            {
                log = summary.log, complete = summary.complete, available = summary.available, later = summary.later,
                completed = summary.completed, total = summary.total,
            }
        )
    end)

    it("should count the quests in the log or available that are right for the player's level", function()
        categories = {"available", "available", "available", "log", "later"}
        levels[1] = 13 -- Three levels higher than the player is still fine
        levels[2] = 14
        levels[3] = 5 -- Too low
        levels[4] = 10
        levels[5] = 10 -- Can't be done yet

        assert.are.equal(2, JourneySummary.Count("zone:12", AllQuests()).suited)
    end)

    it("should keep the last count of each source until it is counted again", function()
        assert.is_nil(JourneySummary.Get("zone:12"))
        categories = {"available"}
        JourneySummary.Count("zone:12", AllQuests())
        categories = {"completed", "completed"}
        JourneySummary.Count("faction:72", AllQuests())

        assert.are.equal(1, JourneySummary.Get("zone:12").available)
        assert.are.equal(2, JourneySummary.Get("faction:72").completed)

        categories = {"completed"}
        JourneySummary.Count("zone:12", AllQuests())

        assert.are_same({0, 1}, {JourneySummary.Get("zone:12").available, JourneySummary.Get("zone:12").completed})
    end)

    describe("IsFinished", function()
        it("should be finished when the quests that aren't completed can't be done any more, or again", function()
            categories = {"completed", "completed", "unobtainable", "repeatable"}

            assert.is_true(JourneySummary.IsFinished(JourneySummary.Count("zone:12", AllQuests())))
        end)

        it("should not be finished while a quest can still be done once", function()
            for _, category in ipairs({"log", "available", "later"}) do
                categories = {"completed", category}

                assert.is_false(JourneySummary.IsFinished(JourneySummary.Count("zone:12", AllQuests())), category)
            end
        end)

        it("should not be finished without anything to do, or before it is counted", function()
            categories = {"repeatable", "unobtainable"}

            assert.is_false(JourneySummary.IsFinished(JourneySummary.Count("zone:12", AllQuests())))
            assert.is_false(JourneySummary.IsFinished(JourneySummary.EMPTY))
        end)
    end)
end)
