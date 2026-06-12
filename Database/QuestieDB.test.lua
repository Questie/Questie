dofile("setupTests.lua")
dofile("Database/questDB.lua")
dofile("Database/itemDB.lua")
dofile("Database/npcDB.lua")

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
        Questie.Error = function() end
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieCorrections = require("Database.Corrections.QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        QuestieCorrections.questItemBlacklist = {}
        QuestieCorrections.killCreditObjectiveFirst = {}
        QuestieCorrections.objectObjectiveFirst = {}
        QuestieCorrections.itemObjectiveFirst = {}
        QuestieCorrections.eventObjectiveFirst = {}
        QuestieCorrections.spellObjectiveFirst = {}
        QuestieCorrections.objectiveOrderMoves = {}
        require("Database.Corrections.ObjectiveOrderCorrections")
        QuestieDB = require("Database.QuestieDB")
        QuestieDB.QueryNPCSingle = function() return nil end
        QuestieDB.private.questCache = {}
        QuestieDB.private.itemCache = {}
        dofile("Localization/l10n.lua")
        dofile("Database/Corrections/questTagInfoCorrections.lua")
        QuestieDB.private.InitializeQuestTagInfoCorrections()

        local questKeys = QuestieDB.questKeys
        testQuest = {
            [questKeys.name] = "Test Quest",
            [questKeys.startedBy] = {{100, 200}},
            [questKeys.finishedBy] = {{300, 400}},
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

            assert.are.same({{Type = "monster", Id = 1000}}, quest.ObjectiveData)
        end)

        it("should return a spell objective once as structured objective data", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [6] = {{12345, "Cast the spell", 67890}}
            }
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({{
                Type = "spell",
                Id = 12345,
                Text = "Cast the spell",
                ItemSourceId = 67890,
            }}, quest.ObjectiveData)
        end)

        it("should move a structured spell objective first when corrected", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [1] = {{1000, "Slay the target"}},
                [6] = {{12345, "Cast the spell", 67890}}
            }
            QuestieCorrections.spellObjectiveFirst[123] = true
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({
                {
                    Type = "spell",
                    Id = 12345,
                    Text = "Cast the spell",
                    ItemSourceId = 67890,
                },
                {
                    Type = "monster",
                    Id = 1000,
                    Text = "Slay the target",
                },
            }, quest.ObjectiveData)
        end)

        it("should add required source items as special objectives when quest has no objectives", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = nil
            testQuest[questKeys.requiredSourceItems] = {67890}
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieDB.QueryItemSingle = spy.new(function() return "Required Item" end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({
                [67890] = {
                    Type = "item",
                    Id = 67890,
                    Description = "Required Item",
                },
            }, quest.SpecialObjectives)
        end)

        it("should move an objective to a target slot and stable-fill remaining objective data", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [3] = {
                    {123, "First item"},
                    {124, "Second item"},
                },
                [4] = {34, 9000},
            }
            QuestieCorrections.objectiveOrderMoves[123] = {
                {Type = "reputation", Id = 34, From = 3, To = 2},
            }
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({
                {Type = "item", Id = 123, Text = "First item"},
                {Type = "reputation", Id = 34, RequiredRepValue = 9000},
                {Type = "item", Id = 124, Text = "Second item"},
            }, quest.ObjectiveData)
        end)

        it("should support multiple objective moves against original positions", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [2] = {
                    {301, "First object"},
                    {302, "Second object"},
                },
                [3] = {
                    {101, "First item"},
                    {102, "Second item"},
                },
            }
            QuestieCorrections.objectiveOrderMoves[123] = {
                {Type = "object", Id = 301, From = 1, To = 4},
                {Type = "item", Id = 102, From = 4, To = 2},
            }
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({
                {Type = "object", Id = 302, Text = "Second object"},
                {Type = "item", Id = 102, Text = "Second item"},
                {Type = "item", Id = 101, Text = "First item"},
                {Type = "object", Id = 301, Text = "First object"},
            }, quest.ObjectiveData)
        end)

        it("should move kill credit objectives by root id", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [1] = {{1000, "Slay the target"}},
                [5] = {{{2001, 2002}, 3000, "Earn kill credit"}},
            }
            QuestieCorrections.objectiveOrderMoves[123] = {
                {Type = "killcredit", Id = 3000, From = 2, To = 1},
            }
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({
                {Type = "killcredit", IdList = {2001, 2002}, RootId = 3000, Text = "Earn kill credit"},
                {Type = "monster", Id = 1000, Text = "Slay the target"},
            }, quest.ObjectiveData)
        end)

        it("should move event objectives without an id", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [1] = {{1000, "Slay the target"}},
            }
            testQuest[questKeys.triggerEnd] = {"Reach the target", {[1] = {{12345, 67890}}}}
            QuestieCorrections.objectiveOrderMoves[123] = {
                {Type = "event", From = 2, To = 1},
            }
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({
                {Type = "event", Text = "Reach the target", Coordinates = {[1] = {{12345, 67890}}}},
                {Type = "monster", Id = 1000, Text = "Slay the target"},
            }, quest.ObjectiveData)
        end)

        it("should keep default objective order when an objective move does not match", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [3] = {
                    {123, "First item"},
                    {124, "Second item"},
                },
                [4] = {34, 9000},
            }
            QuestieCorrections.objectiveOrderMoves[123] = {
                {Type = "reputation", Id = 999, From = 3, To = 2},
            }
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({
                {Type = "item", Id = 123, Text = "First item"},
                {Type = "item", Id = 124, Text = "Second item"},
                {Type = "reputation", Id = 34, RequiredRepValue = 9000},
            }, quest.ObjectiveData)
        end)

        it("should apply legacy objective first corrections when an objective move does not match", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [1] = {{1000, "Slay the target"}},
                [6] = {{12345, "Cast the spell", 67890}}
            }
            QuestieCorrections.spellObjectiveFirst[123] = true
            QuestieCorrections.objectiveOrderMoves[123] = {
                {Type = "spell", Id = 999, From = 2, To = 1},
            }
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetTbcLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are.same({
                {
                    Type = "spell",
                    Id = 12345,
                    Text = "Cast the spell",
                    ItemSourceId = 67890,
                },
                {
                    Type = "monster",
                    Id = 1000,
                    Text = "Slay the target",
                },
            }, quest.ObjectiveData)
        end)
    end)

    describe("GetItem", function()
        it("should add vendors when they are friendly", function()
            QuestiePlayer.faction = "Alliance"
            local itemKeys = QuestieDB.itemKeys
            QuestieDB.QueryItem = spy.new(function() return {[itemKeys.name] = "Test NPC", [itemKeys.vendors] = {555}} end)
            QuestieDB.QueryNPCSingle = spy.new(function() return "A" end)

            local item = QuestieDB:GetItem(12345)

            assert.are_same(12345, item.Id)
            assert.is_nil(item.Hidden)
            assert.are_same({555}, item.vendors)
            assert.are_same("Test NPC", item.name)
            assert.are_same({{Id = 555, Type = "monster"}}, item.Sources)
        end)

        it("should not add vendors when they are hostile", function()
            QuestiePlayer.faction = "Alliance"
            local itemKeys = QuestieDB.itemKeys
            QuestieDB.QueryItem = spy.new(function() return {[itemKeys.name] = "Test NPC", [itemKeys.vendors] = {555}} end)
            QuestieDB.QueryNPCSingle = spy.new(function() return "H" end)

            local item = QuestieDB:GetItem(12345)

            assert.are_same(12345, item.Id)
            assert.is_nil(item.Hidden)
            assert.are_same({555}, item.vendors)
            assert.are_same("Test NPC", item.name)
            assert.are_same({}, item.Sources)
        end)
    end)

    describe("GetQuestTagInfo", function()
        it("should return the API value", function()
            _G.GetQuestTagInfo = spy.new(function() return 81, "Dungeon" end)

            local questTagId, questTagName = QuestieDB.GetQuestTagInfo(123)

            assert.are.same(81, questTagId)
            assert.are.same("Dungeon", questTagName)
            assert.spy(_G.GetQuestTagInfo).was_called_with(123)
        end)

        it("should return the corrected value", function()
            _G.GetQuestTagInfo = spy.new(function() return 81, "Dungeon" end)

            local questTagId, questTagName = QuestieDB.GetQuestTagInfo(6846)

            assert.are.same(41, questTagId)
            assert.are.same("PvP", questTagName)
            assert.spy(_G.GetQuestTagInfo).was_not_called()
        end)

        it("should cache", function()
            _G.GetQuestTagInfo = spy.new(function() return 81, "Dungeon" end)

            local questTagId, questTagName = QuestieDB.GetQuestTagInfo(600)
            local questTagId2, questTagName2 = QuestieDB.GetQuestTagInfo(600)

            assert.are.same(81, questTagId)
            assert.are.same("Dungeon", questTagName)
            assert.are.same(81, questTagId2)
            assert.are.same("Dungeon", questTagName2)
            assert.spy(_G.GetQuestTagInfo).was.called(1)
        end)

        it("should update cache", function()
            local callback
            _G.C_Timer = {
                After = function(_, cb) callback = cb end
            }
            local isFirstCall = true
            _G.GetQuestTagInfo = spy.new(function()
                if isFirstCall then
                    isFirstCall = false
                    return nil, nil
                end
                return 81, "Dungeon"
            end)

            local questTagId, questTagName = QuestieDB.GetQuestTagInfo(700)
            assert.is_nil(questTagId)
            assert.is_nil(questTagName)

            callback()

            local questTagId2, questTagName2 = QuestieDB.GetQuestTagInfo(700)
            assert.are.same(81, questTagId2)
            assert.are.same("Dungeon", questTagName2)

            assert.spy(_G.GetQuestTagInfo).was.called(2)
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
            Questie.db.char.complete = {[1] = true, [2] = true, [3] = true}
            assert.is_true(QuestieDB:IsPreQuestGroupFulfilled({1, 2, 3}))
        end)

        it("should return false for unfulfilled preQuestGroup without an exclusiveTo quest", function()
            Questie.db.char.complete = {[1] = true, [2] = true}
            QuestieDB.QueryQuestSingle = spy.new(function() return nil end)
            assert.is_false(QuestieDB:IsPreQuestGroupFulfilled({1, 2, 3}))
        end)

        it("should return true for unfulfilled preQuestGroup when an exclusiveTo quest is fulfilled", function()
            Questie.db.char.complete = {[1] = true, [2] = true, [4] = true}
            QuestieDB.QueryQuestSingle = spy.new(function() return {4} end)
            assert.is_true(QuestieDB:IsPreQuestGroupFulfilled({1, 2, 3}))
        end)

        it("should return false for unfulfilled preQuestGroup when ID is negative and exclusiveTo is not checked", function()
            Questie.db.char.complete = {[1] = true, [2] = true}
            assert.is_false(QuestieDB:IsPreQuestGroupFulfilled({1, -2, -3}))
        end)

        it("should return true for fulfilled preQuestGroup when ID is negative", function()
            Questie.db.char.complete = {[1] = true, [2] = true}
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
            Questie.db.char.complete = {[1] = true}
            assert.is_true(QuestieDB:IsPreQuestSingleFulfilled({1}))
        end)

        it("should return false for unfulfilled preQuestSingle", function()
            Questie.db.char.complete = {[2] = true}
            assert.is_false(QuestieDB:IsPreQuestSingleFulfilled({1}))
        end)
    end)
end)
