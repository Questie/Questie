dofile("setupTests.lua")

describe("QuestieDB", function()
    ---@type QuestieDB
    local QuestieDB = require("Database.QuestieDB")

    describe("GetQuestTagInfo", function()
        it("should return the API value", function()
            _G.GetQuestTagInfo = spy.new(function() return 81, "Dungeon" end)

            local questType, questTag = QuestieDB.GetQuestTagInfo(123)

            assert.are.same(81, questType)
            assert.are.same("Dungeon", questTag)
            assert.spy(_G.GetQuestTagInfo).was_called_with(123)
        end)

        it("should return the corrected value", function()
            _G.GetQuestTagInfo = spy.new(function() return 81, "Dungeon" end)

            local questType, questTag = QuestieDB.GetQuestTagInfo(6846)

            assert.are.same(41, questType)
            assert.are.same("PvP", questTag)
            assert.spy(_G.GetQuestTagInfo).was_not_called()
        end)

        it("should cache", function()
            _G.GetQuestTagInfo = spy.new(function() return 81, "Dungeon" end)

            local questType, questTag = QuestieDB.GetQuestTagInfo(600)
            local questType2, questTag2 = QuestieDB.GetQuestTagInfo(600)

            assert.are.same(81, questType)
            assert.are.same("Dungeon", questTag)
            assert.are.same(81, questType2)
            assert.are.same("Dungeon", questTag2)
            assert.spy(_G.GetQuestTagInfo).was_called(1)
        end)
    end)
end)
