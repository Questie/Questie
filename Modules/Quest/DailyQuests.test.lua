dofile("setupTests.lua")

describe("DailyQuests", function()
    
    ---@type DailyQuests
    local DailyQuests
    
    before_each(function()
        _G["Questie"] = {db = {char = {complete = {}}}}

        DailyQuests = require("Modules.Quest.DailyQuests")

        DailyQuests.hubs = {
            TEST_HUB = {
                quests = { 1, 2, 3, 4, 5 },
                limit = 3,
            }
        }
    end)
    
    describe("ShouldBeHidden", function()
        it("should return true when quest is registered and limit of quests is reached by completed quests", function()
            local completedQuests = {
                [2] = true,
                [3] = true,
                [4] = true,
            }

            local shouldBeHidden = DailyQuests.ShouldBeHidden(1, completedQuests)

            assert.is_true(shouldBeHidden)
        end)

        it("should return true when quest is registered and limit of quests is reached by quests in quest log", function()

        end)

        it("should return true when quest is registered and limit of quests is reached by completed quests and quests in quest log", function()

        end)

        it("should return false when quest is not registered", function()

        end)

        it("should return false when quest is registered and limit is not reached", function()

        end)
    end)
end)
