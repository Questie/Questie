dofile("setupTests.lua")

describe("QuestieDB", function()
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieDB
    local QuestieDB

    before_each(function()
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestieDB = require("Database.QuestieDB")
    end)

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

    describe("IsTrivial", function()
        it("should return false for scaling quests", function()
            QuestiePlayer.GetPlayerLevel = spy.new(function() return 60 end)

            assert.is_false(QuestieDB.IsTrivial(-1))
            assert.spy(QuestiePlayer.GetPlayerLevel).was_not_called()
        end)

        it("should return false for red quests", function()
            QuestiePlayer.GetPlayerLevel = spy.new(function() return 60 end)

            assert.is_false(QuestieDB.IsTrivial(66))
            assert.is_false(QuestieDB.IsTrivial(65))
        end)

        it("should return false for orange quests", function()
            QuestiePlayer.GetPlayerLevel = spy.new(function() return 60 end)

            assert.is_false(QuestieDB.IsTrivial(64))
            assert.is_false(QuestieDB.IsTrivial(63))
        end)

        it("should return false for green quests", function()
            QuestiePlayer.GetPlayerLevel = spy.new(function() return 60 end)
            _G.GetQuestGreenRange = spy.new(function() return 12 end)

            assert.is_false(QuestieDB.IsTrivial(48))
            assert.is_false(QuestieDB.IsTrivial(49))
        end)

        it("should return true for grey quests", function()
            QuestiePlayer.GetPlayerLevel = spy.new(function() return 60 end)
            _G.GetQuestGreenRange = spy.new(function() return 12 end)

            assert.is_true(QuestieDB.IsTrivial(47))
            assert.is_true(QuestieDB.IsTrivial(46))
        end)
    end)

    describe("IsFriendlyToPlayer", function()
        it("should return true for unset friendlyToFaction and Alliance players", function()
            QuestiePlayer.faction = "Alliance"
            assert.is_true(QuestieDB.IsFriendlyToPlayer(nil))
        end)

        it("should return true for unset friendlyToFaction and Horde players", function()
            QuestiePlayer.faction = "Horde"
            assert.is_true(QuestieDB.IsFriendlyToPlayer(nil))
        end)

        it("should return true for neutral NPCs and Alliance players", function()
            QuestiePlayer.faction = "Alliance"
            assert.is_true(QuestieDB.IsFriendlyToPlayer("AH"))
        end)

        it("should return true for neutral NPCs and Horde players", function()
            QuestiePlayer.faction = "Horde"
            assert.is_true(QuestieDB.IsFriendlyToPlayer("AH"))
        end)

        it("should return true for NPCs friendly to Alliance and Alliance players", function()
            QuestiePlayer.faction = "Alliance"
            assert.is_true(QuestieDB.IsFriendlyToPlayer("A"))
        end)

        it("should return false for NPCs friendly to Alliance and Horde players", function()
            QuestiePlayer.faction = "Horde"
            assert.is_false(QuestieDB.IsFriendlyToPlayer("A"))
        end)

        it("should return true for NPCs friendly to Horde and Horde players", function()
            QuestiePlayer.faction = "Horde"
            assert.is_true(QuestieDB.IsFriendlyToPlayer("H"))
        end)

        it("should return false for NPCs friendly to Horde and Alliance players", function()
            QuestiePlayer.faction = "Alliance"
            assert.is_false(QuestieDB.IsFriendlyToPlayer("H"))
        end)

        it("should return false for invalid DB entry", function()
            QuestiePlayer.faction = "Alliance"
            assert.is_false(QuestieDB.IsFriendlyToPlayer("X"))
        end)
    end)
end)
