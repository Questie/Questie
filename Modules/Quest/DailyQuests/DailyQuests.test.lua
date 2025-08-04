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
            }
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

        it("should return false when quest does not belong to a hub", function()
            local completedQuests = {
                [1] = true,
                [2] = true,
                [3] = true,
                [4] = true,
                [5] = true,
            }
            local questLog = {}

            local shouldBeHidden = DailyQuests.ShouldBeHidden(6, completedQuests, questLog)

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
    end)
end)
