dofile("setupTests.lua")
dofile("Database/questDB.lua")

describe("QuestieDB", function()
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type QuestieDB
    local QuestieDB

    ---@type Quest
    local testQuest

    before_each(function()
        Questie.db.char.complete = {}
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieCorrections = require("Database.Corrections.QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        QuestieDB = require("Database.QuestieDB")
        QuestieDB.private.questCache = {}
        QuestieDB.QueryNPCSingle = function() return nil end

        local questKeys = QuestieDB.questKeys
        testQuest = {
            [questKeys.name] = "Test Quest",
            [questKeys.startedBy] = {{100, 200}},
            [questKeys.finishedBy] =  {{300, 400}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = QuestieDB.raceKeys.ALL_HORDE,
            [questKeys.requiredClasses] = QuestieDB.classKeys.MAGE,
            [questKeys.objectivesText] = "Finish him!",
            [questKeys.objectives] = {{{1000}}}
        }
    end)

    describe("GetQuest", function()
        it("should return a quest", function()
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same(123, quest.Id)
            assert.are.same("Test Quest", quest.name)

            local starter = quest.Starts
            assert.are.same({100, 200}, starter.NPC)
            assert.is_nil(starter.GameObject)
            assert.is_nil(starter.Item)

            local finisher = quest.Finisher
            assert.are.same({300, 400}, finisher.NPC)
            assert.is_nil(finisher.GameObject)

            assert.are.same(60, quest.requiredLevel)
            assert.are.same(60, quest.questLevel)
            assert.are.same(QuestieDB.raceKeys.ALL_HORDE, quest.requiredRaces)
            assert.are.same(QuestieDB.classKeys.MAGE, quest.requiredClasses)
            assert.are.same("Finish him!", quest.Description)

            assert.are.same({{Type="monster",Id=1000}}, quest.ObjectiveData)
        end)
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

    describe("IsPreQuestGroupFulfilled", function()
        it("should return true for no preQuestGroup", function()
            assert.is_true(QuestieDB:IsPreQuestGroupFulfilled(nil))
        end)

        it("should return true for empty preQuestGroup", function()
            assert.is_true(QuestieDB:IsPreQuestGroupFulfilled({}))
        end)

        it("should return true for fulfilled preQuestGroup", function()
            Questie.db.char.complete = {[1]=true, [2]=true, [3]=true}
            assert.is_true(QuestieDB:IsPreQuestGroupFulfilled({1, 2, 3}))
        end)

        it("should return false for unfulfilled preQuestGroup without an exclusiveTo quest", function()
            Questie.db.char.complete = {[1]=true, [2]=true}
            QuestieDB.QueryQuestSingle = spy.new(function() return nil end)
            assert.is_false(QuestieDB:IsPreQuestGroupFulfilled({1, 2, 3}))
        end)

        it("should return true for unfulfilled preQuestGroup when an exclusiveTo quest is fulfilled", function()
            Questie.db.char.complete = {[1]=true, [2]=true, [4]=true}
            QuestieDB.QueryQuestSingle = spy.new(function() return {4} end)
            assert.is_true(QuestieDB:IsPreQuestGroupFulfilled({1, 2, 3}))
        end)

        it("should return false for unfulfilled preQuestGroup when ID is negative and exclusiveTo is not checked", function()
            Questie.db.char.complete = {[1]=true, [2]=true}
            assert.is_false(QuestieDB:IsPreQuestGroupFulfilled({1, -2, -3}))
        end)

        it("should return true for fulfilled preQuestGroup when ID is negative", function()
            Questie.db.char.complete = {[1]=true, [2]=true}
            assert.is_true(QuestieDB:IsPreQuestGroupFulfilled({1, -2}))
        end)
    end)

    describe("IsPreQuestSingleFulfilled", function()
        it("should return true for no preQuestSingle", function()
            assert.is_true(QuestieDB:IsPreQuestSingleFulfilled(nil))
        end)

        it("should return true for empty preQuestSingle", function()
            assert.is_true(QuestieDB:IsPreQuestSingleFulfilled({}))
        end)

        it("should return true for fulfilled preQuestSingle", function()
            Questie.db.char.complete = {[1]=true}
            assert.is_true(QuestieDB:IsPreQuestSingleFulfilled({1}))
        end)

        it("should return false for unfulfilled preQuestSingle", function()
            Questie.db.char.complete = {[2]=true}
            assert.is_false(QuestieDB:IsPreQuestSingleFulfilled({1}))
        end)
    end)
end)
