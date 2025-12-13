dofile("setupTests.lua")

describe("DailyQuests", function()
    ---@type DailyQuests
    local DailyQuests

    before_each(function()
        _G["Questie"] = {db = {char = {complete = {}}}}

        DailyQuests = require("Modules.Quest.DailyQuests.DailyQuests")

        DailyQuests.hubs = {
            TEST_HUB = {
                quests = {1, 2, 3, 4, 5},
                limit = 3,
                exclusiveHubs = {TEST_HUB_2 = true},
                preQuestHubsSingle = {},
                preQuestHubsGroup = {},
            },
            TEST_HUB_2 = {
                quests = {6, 7, 8},
                limit = 1,
                exclusiveHubs = {TEST_HUB = true},
                preQuestHubsSingle = {},
                preQuestHubsGroup = {},
            },
            TEST_HUB_3 = {
                quests = {9},
                limit = 1,
                exclusiveHubs = {},
                preQuestHubsSingle = {TEST_HUB_2 = true, TEST_HUB = true},
                preQuestHubsGroup = {},
            },
            TEST_HUB_4 = {
                quests = {10},
                limit = 1,
                exclusiveHubs = {},
                preQuestHubsSingle = {},
                preQuestHubsGroup = {TEST_HUB_2 = true, TEST_HUB_3 = true},
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

        it("should return true when quest is part of a hub for which the preQuestHubsSingle is not complete", function()
            local completedQuests = {}
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(9, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is part of a hub for which the preQuestHubsSingle is complete in the quest log", function()
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

        it("should return false when quest is part of a hub for which a single preQuestHubsSingle is complete", function()
            local completedQuests = {
                [6] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(9, completedQuests, questLog)

            assert.is_false(shouldBeHidden)
        end)

        it("should return false when quest is part of a hub for which all preQuestHubsSingle are complete", function()
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

        it("should return true when quest is part of a hub for which preQuestHubsGroup is not complete", function()
            local completedQuests = {}
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(10, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is part of a hub for which only a single hub of preQuestHubsGroup is complete", function()
            local completedQuests = {
                [6] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(10, completedQuests, questLog)

            assert.is_true(shouldBeHidden)
        end)

        it(
            "should return true when quest is part of a hub for which only a single hub of preQuestHubsGroup is complete and the other is complete in the quest log",
            function()
                local completedQuests = {
                    [6] = true,
                }
                local questLog = {
                    [9] = {},
                }

                local shouldBeHidden = DailyQuests.ShouldBeHidden(10, completedQuests, questLog)

                assert.is_true(shouldBeHidden)
            end)

        it("should return false when quest is part of a hub for which all hubs of preQuestHubsGroup are complete", function()
            local completedQuests = {
                [6] = true,
                [9] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(10, completedQuests, questLog)

            assert.is_false(shouldBeHidden)
        end)
    end)
end)
