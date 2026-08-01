dofile("setupTests.lua")

describe("CommsBlacklist", function()
    ---@type CommsBlacklist
    local CommsBlacklist

    before_each(function()
        dofile("Modules/Network/CommsBlacklist.lua")
        CommsBlacklist = QuestieLoader:ImportModule("CommsBlacklist")
    end)

    describe("FilterQuestIds", function()
        it("should return questIds unchanged when not on SoD", function()
            Questie.IsSoD = false
            local questIds = {84348, 84349, 84360}

            local result = CommsBlacklist.FilterQuestIds(questIds)

            assert.are_same({84348, 84349, 84360}, result)
        end)

        it("should return all questIds when none are blacklisted", function()
            Questie.IsSoD = true
            local questIds = {5678, 91011}

            local result = CommsBlacklist.FilterQuestIds(questIds)

            assert.are_same({5678, 91011}, result)
        end)

        it("should remove blacklisted questIds from the list", function()
            Questie.IsSoD = true
            local questIds = {5678, 84348, 91011, 84360}

            local result = CommsBlacklist.FilterQuestIds(questIds)

            assert.are_same({5678, 91011}, result)
        end)

        it("should return an empty list when all questIds are blacklisted", function()
            Questie.IsSoD = true
            local questIds = {84348, 84349, 84360}

            local result = CommsBlacklist.FilterQuestIds(questIds)

            assert.are_same({}, result)
        end)

        it("should return an empty list when given an empty list", function()
            Questie.IsSoD = true
            local questIds = {}

            local result = CommsBlacklist.FilterQuestIds(questIds)

            assert.are_same({}, result)
        end)
    end)

    describe("IsBlacklisted", function()
        it("should return false when not on SoD", function()
            Questie.IsSoD = false

            assert.is_false(CommsBlacklist.IsBlacklisted(84348))
        end)

        it("should return false for a non-blacklisted questId", function()
            Questie.IsSoD = true

            assert.is_false(CommsBlacklist.IsBlacklisted(5678))
        end)

        it("should return true for a blacklisted questId", function()
            Questie.IsSoD = true

            assert.is_true(CommsBlacklist.IsBlacklisted(84348))
        end)
    end)
end)
