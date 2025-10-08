dofile("setupTests.lua")

describe("DailyQuests", function()
    
    ---@type DailyQuests
    local DailyQuests
    
    before_each(function()
        _G["Questie"] = {db = {char = {complete = {}}}}

        DailyQuests = require("Modules.Quest.DailyQuests.DailyQuests")

        DailyQuests.hubs = {
            TEST_HUB = {
                quests = { 1, 2, 3, 4, 5 },
                limit = 3,
                exclusiveHubs = { TEST_HUB_2 = true },
                preQuestHubs = {},
            },
            TEST_HUB_2 = {
                quests = { 6, 7, 8 },
                limit = 1,
                exclusiveHubs = { TEST_HUB = true },
                preQuestHubs = {},
            },
            TEST_HUB_3 = {
                quests = { 9 },
                limit = 1,
                exclusiveHubs = {},
                preQuestHubs = { TEST_HUB_2 = true, TEST_HUB = true },
            },
        }
        DailyQuests.Initialize()
    end)
    
    describe("ShouldBeHidden", function()
        it("should return true when quest is registered and limit of quests is reached by completed quests", function()
            local completedQuests = {
                [2] = true,
                [3] = true,
                [4] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is registered and limit of quests is reached by quests in quest log", function()
            local completedQuests = {}
            local questLog = {
                [2] = {},
                [3] = {},
                [4] = {},
            }

            local shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is registered and limit of quests is reached by completed quests and quests in quest log", function()
            local completedQuests = {
                [2] = true,
                [3] = true,
            }
            local questLog = {
                [4] = {},
            }

            local shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is part of a hub that is exclusive to a quest in the quest log", function()
            local completedQuests = {}
            local questLog = {
                [6] = {},
            }

            local shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is part of a hub that is exclusive to a completed quest", function()
            local completedQuests = {
                [6] = {},
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is part of a hub for which the preQuestHub is not complete", function()
            local completedQuests = {}
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(9, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is part of a hub for which the preQuestHub is complete in the quest log", function()
            local completedQuests = {}
            local questLog = {
                [6] = {},
            }

            local shouldBeHidden = DailyQuests.ShouldBeHidden(9, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return false when quest does not belong to a hub", function()
            local completedQuests = {
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(100, completedQuests, questLog)

            assert.is_false(shouldBeHidden)
        end)

        it("should return false when quest is registered and limit is not reached", function()
            local completedQuests = {
                [2] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)
            assert.is_false(shouldBeHidden)

            completedQuests[3] = true
            shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)
            assert.is_false(shouldBeHidden)

            completedQuests = {}
            questLog = {
                [2] = {},
            }
            shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)
            assert.is_false(shouldBeHidden)

            questLog[3] = {}
            shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests, questLog)
            assert.is_false(shouldBeHidden)
        end)

        it("should return false when quest is part of a hub for which a single preQuestHub is complete", function()
            local completedQuests = {
                [6] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(9, completedQuests, questLog)

            assert.is_false(shouldBeHidden)
        end)

        it("should return false when quest is part of a hub for which all preQuestHubs are complete", function()
            local completedQuests = {
                [1] = true,
                [2] = true,
                [3] = true,
                [6] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(9, completedQuests, questLog)

            assert.is_false(shouldBeHidden)
        end)
    end)
end)
