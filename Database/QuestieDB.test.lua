local TestUtils = dofile("setupTests.lua")

dofile("Database/questDB.lua")
dofile("Database/itemDB.lua")
dofile("Database/npcDB.lua")
dofile("Database/objectDB.lua")

describe("QuestieDB", function()
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type QuestieDB
    local QuestieDB
    ---@type l10n
    local l10n

    ---@type Quest
    local testQuest

    local function _AssertSchemaRejectsIncompatibleContract(filePath)
        local compatibleDatabaseAddon = _G.LibQuestieDB
        _G.LibQuestieDB = {
            RequireContract = function()
                return false, "QuestieTDB test contract mismatch"
            end,
        }

        local loaded, loadError = pcall(dofile, filePath)
        _G.LibQuestieDB = compatibleDatabaseAddon

        assert.is_false(loaded)
        assert.is_truthy(string.find(tostring(loadError), "QuestieTDB test contract mismatch", 1, true))
    end

    before_each(function()
        TestUtils.QuestieTDB.Reset()
        Questie.db.char.complete = {}
        Questie.db.char.hidden = {}
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.TableMemoizeFunction = function(_, func) return func end
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        QuestieCorrections.questItemBlacklist = {}
        QuestieCorrections.killCreditObjectiveFirst = {}
        QuestieCorrections.objectObjectiveFirst = {}
        QuestieCorrections.itemObjectiveFirst = {}
        QuestieCorrections.eventObjectiveFirst = {}
        QuestieCorrections.spellObjectiveFirst = {}

        dofile("Database/QuestieDB.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryNPCSingle = function() return nil end
        QuestieDB.private.questCache = {}
        QuestieDB.private.itemCache = {}
        dofile("Localization/l10n.lua")
        l10n = QuestieLoader:ImportModule("l10n")
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

    describe("Initialize", function()
        it("rejects an incompatible Database Addon Contract Version during initialization", function()
            TestUtils.QuestieTDB.SetContractError("QuestieTDB test contract mismatch")

            assert.has_error(function()
                QuestieDB:Initialize()
            end, "QuestieTDB test contract mismatch")
        end)

        it("rejects an incompatible Database Addon before loading Quest schema metadata", function()
            _AssertSchemaRejectsIncompatibleContract("Database/questDB.lua")
        end)

        it("rejects an incompatible Database Addon before loading NPC schema metadata", function()
            _AssertSchemaRejectsIncompatibleContract("Database/npcDB.lua")
        end)

        it("rejects an incompatible Database Addon before loading Item schema metadata", function()
            _AssertSchemaRejectsIncompatibleContract("Database/itemDB.lua")
        end)

        it("rejects an incompatible Database Addon before loading Game Object schema metadata", function()
            _AssertSchemaRejectsIncompatibleContract("Database/objectDB.lua")
        end)

        it("uses the Database Key Enums from the Database Addon", function()
            assert.are.equal(LibQuestieDB.Meta.QuestMeta.questKeys, QuestieDB.questKeys)
            assert.are.equal(LibQuestieDB.Meta.NpcMeta.npcKeys, QuestieDB.npcKeys)
            assert.are.equal(LibQuestieDB.Meta.ItemMeta.itemKeys, QuestieDB.itemKeys)
            assert.are.equal(LibQuestieDB.Meta.ObjectMeta.objectKeys, QuestieDB.objectKeys)
        end)

        it("binds single-field queries to the Database Addon", function()
            TestUtils.QuestieTDB.AddEntity("Quest", 101, {[QuestieDB.questKeys.name] = "A Test Quest"})
            TestUtils.QuestieTDB.AddEntity("Npc", 102, {[QuestieDB.npcKeys.name] = "A Test NPC"})
            TestUtils.QuestieTDB.AddEntity("Item", 103, {[QuestieDB.itemKeys.name] = "A Test Item"})
            TestUtils.QuestieTDB.AddEntity("Object", 104, {[QuestieDB.objectKeys.name] = "A Test Game Object"})

            QuestieDB:Initialize()

            assert.are_same("A Test Quest", QuestieDB.QueryQuestSingle(101, "name"))
            assert.are_same("A Test NPC", QuestieDB.QueryNPCSingle(102, "name"))
            assert.are_same("A Test Item", QuestieDB.QueryItemSingle(103, "name"))
            assert.are_same("A Test Game Object", QuestieDB.QueryObjectSingle(104, "name"))
        end)

        it("returns fresh table fields through bound Database Addon queries", function()
            TestUtils.QuestieTDB.AddEntity("Quest", 101, {
                [QuestieDB.questKeys.startedBy] = {{102}, {103}},
            })
            QuestieDB:Initialize()

            local firstRead = QuestieDB.QueryQuestSingle(101, "startedBy")
            firstRead[1][1] = 999

            assert.are_same({{102}, {103}}, QuestieDB.QueryQuestSingle(101, "startedBy"))
        end)

        it("binds bulk queries to the Database Addon", function()
            TestUtils.QuestieTDB.AddEntity("Quest", 101, {
                [QuestieDB.questKeys.name] = "A Test Quest",
                [QuestieDB.questKeys.requiredLevel] = 42,
            })
            TestUtils.QuestieTDB.AddEntity("Npc", 102, {
                [QuestieDB.npcKeys.name] = "A Test NPC",
                [QuestieDB.npcKeys.rank] = 3,
            })
            TestUtils.QuestieTDB.AddEntity("Item", 103, {
                [QuestieDB.itemKeys.name] = "A Test Item",
                [QuestieDB.itemKeys.itemLevel] = 51,
            })
            TestUtils.QuestieTDB.AddEntity("Object", 104, {
                [QuestieDB.objectKeys.name] = "A Test Game Object",
                [QuestieDB.objectKeys.zoneID] = 12,
            })

            QuestieDB:Initialize()

            assert.are_same({[1] = "A Test Quest", [3] = 42, n = 3}, QuestieDB.QueryQuest(101, {"name", "triggerEnd", "requiredLevel"}))
            assert.are_same({"A Test NPC", 3, n = 2}, QuestieDB.QueryNPC(102, {"name", "rank"}))
            assert.are_same({"A Test Item", 51, n = 2}, QuestieDB.QueryItem(103, {"name", "itemLevel"}))
            assert.are_same({"A Test Game Object", 12, n = 2}, QuestieDB.QueryObject(104, {"name", "zoneID"}))
        end)

        it("binds Objective Order Corrections from the Database Addon", function()
            QuestieDB:Initialize()

            assert.are.equal(LibQuestieDB.ObjectiveFirst.killCreditObjectiveFirst, QuestieCorrections.killCreditObjectiveFirst)
            assert.are.equal(LibQuestieDB.ObjectiveFirst.objectObjectiveFirst, QuestieCorrections.objectObjectiveFirst)
            assert.are.equal(LibQuestieDB.ObjectiveFirst.itemObjectiveFirst, QuestieCorrections.itemObjectiveFirst)
            assert.are.equal(LibQuestieDB.ObjectiveFirst.eventObjectiveFirst, QuestieCorrections.eventObjectiveFirst)
            assert.are.equal(LibQuestieDB.ObjectiveFirst.spellObjectiveFirst, QuestieCorrections.spellObjectiveFirst)
        end)

        it("binds entity ID maps from the Database Addon", function()
            TestUtils.QuestieTDB.AddEntity("Quest", 101, {})
            TestUtils.QuestieTDB.AddEntity("Npc", 102, {})
            TestUtils.QuestieTDB.AddEntity("Item", 103, {})
            TestUtils.QuestieTDB.AddEntity("Object", 104, {})

            QuestieDB:Initialize()

            assert.are.equal(LibQuestieDB.Quest.GetAllIds(true), QuestieDB.QuestPointers)
            assert.are.equal(LibQuestieDB.Npc.GetAllIds(true), QuestieDB.NPCPointers)
            assert.are.equal(LibQuestieDB.Item.GetAllIds(true), QuestieDB.ItemPointers)
            assert.are.equal(LibQuestieDB.Object.GetAllIds(true), QuestieDB.ObjectPointers)
            assert.are_same({[101] = true}, QuestieDB.QuestPointers)
            assert.are_same({[102] = true}, QuestieDB.NPCPointers)
            assert.are_same({[103] = true}, QuestieDB.ItemPointers)
            assert.are_same({[104] = true}, QuestieDB.ObjectPointers)
        end)

        it("resets semantic caches after binding the Database Addon", function()
            QuestieDB.private.questCache[101] = {Id = 101}
            QuestieDB.private.npcCache[102] = {Id = 102}
            QuestieDB.private.itemCache[103] = {Id = 103}
            QuestieDB.private.objectCache[104] = {Id = 104}
            QuestieDB.private.zoneCache[105] = {Id = 105}
            QuestieDB._CreatureLevelCache[106] = {Id = 106}

            QuestieDB:Initialize()

            assert.is_nil(QuestieDB.private.questCache[101])
            assert.is_nil(QuestieDB.private.npcCache[102])
            assert.is_nil(QuestieDB.private.itemCache[103])
            assert.is_nil(QuestieDB.private.objectCache[104])
            assert.is_nil(QuestieDB.private.zoneCache[105])
            assert.is_nil(QuestieDB._CreatureLevelCache[106])
        end)
    end)

    describe("GetQuest", function()
        it("should return a quest", function()
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are_same(123, quest.Id)
            assert.are_same("Test Quest", quest.name)

            local starter = quest.Starts
            assert.are_same({100, 200}, starter.NPC)
            assert.is_nil(starter.GameObject)
            assert.is_nil(starter.Item)

            local finisher = quest.Finisher
            assert.are_same({300, 400}, finisher.NPC)
            assert.is_nil(finisher.GameObject)

            assert.are_same(60, quest.requiredLevel)
            assert.are_same(60, quest.questLevel)
            assert.are_same(QuestieDB.raceKeys.ALL_HORDE, quest.requiredRaces)
            assert.are_same(QuestieDB.classKeys.MAGE, quest.requiredClasses)
            assert.are_same("Finish him!", quest.Description)

            assert.are_same({{Type = "monster", Id = 1000}}, quest.ObjectiveData)
        end)

        it("should return a spell objective once as structured objective data", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [6] = {{12345, "Cast the spell", 67890}}
            }
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are_same({{
                Type = "spell",
                Id = 12345,
                Text = "Cast the spell",
                ItemSourceId = 67890,
            }}, quest.ObjectiveData)
        end)

        it("should move a structured spell objective first when the Database Addon requests it", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [1] = {{1000, "Slay the target"}},
                [6] = {{12345, "Cast the spell", 67890}}
            }
            TestUtils.QuestieTDB.SetObjectiveFirst("spellObjectiveFirst", 123)
            TestUtils.QuestieTDB.AddEntity("Quest", 123, testQuest)
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end
            QuestieDB:Initialize()

            local quest = QuestieDB.GetQuest(123)

            assert.are_same({
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
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are_same({
                [67890] = {
                    Type = "item",
                    Id = 67890,
                    Description = "Required Item",
                },
            }, quest.SpecialObjectives)
        end)

        it("should localize Special Objective descriptions and spawn names", function()
            testQuest[QuestieDB.questKeys.extraObjectives] = {
                {{[12] = {{45.6, 78.9}}}, 7, "Find the hidden cache"},
            }
            l10n.translations["Find the hidden cache"] = {
                enUS = true,
                deDE = "Finde das versteckte Versteck",
            }
            l10n:SetUILocale("deDE")
            QuestieDB.QueryQuest = function() return testQuest end
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are_same("Finde das versteckte Versteck", quest.SpecialObjectives[1].Description)
            assert.are_same("Finde das versteckte Versteck", quest.SpecialObjectives[1].spawnList[1].Name)
        end)

        it("should preserve a missing Special Objective description and custom-spawn name", function()
            testQuest[QuestieDB.questKeys.extraObjectives] = {
                {{[12] = {{45.6, 78.9}}}, 7},
            }
            QuestieDB.QueryQuest = function() return testQuest end
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.is_nil(quest.SpecialObjectives[1].Description)
            assert.is_nil(quest.SpecialObjectives[1].spawnList[1].Name)
        end)

        it("should use the English Special Objective text when no translation exists", function()
            testQuest[QuestieDB.questKeys.extraObjectives] = {
                {{[12] = {{45.6, 78.9}}}, 7, "Find the hidden cache"},
            }
            l10n:SetUILocale("deDE")
            QuestieDB.QueryQuest = function() return testQuest end
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end

            local quest = QuestieDB.GetQuest(123)

            assert.are_same("Find the hidden cache", quest.SpecialObjectives[1].Description)
            assert.are_same("Find the hidden cache", quest.SpecialObjectives[1].spawnList[1].Name)
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

            assert.are_same(81, questTagId)
            assert.are_same("Dungeon", questTagName)
            assert.spy(_G.GetQuestTagInfo).was.called_with(123)
        end)

        it("should return the corrected value", function()
            _G.GetQuestTagInfo = spy.new(function() return 81, "Dungeon" end)

            local questTagId, questTagName = QuestieDB.GetQuestTagInfo(6846)

            assert.are_same(41, questTagId)
            assert.are_same("PvP", questTagName)
            assert.spy(_G.GetQuestTagInfo).was.not_called()
        end)

        it("should cache", function()
            _G.GetQuestTagInfo = spy.new(function() return 81, "Dungeon" end)

            local questTagId, questTagName = QuestieDB.GetQuestTagInfo(600)
            local questTagId2, questTagName2 = QuestieDB.GetQuestTagInfo(600)

            assert.are_same(81, questTagId)
            assert.are_same("Dungeon", questTagName)
            assert.are_same(81, questTagId2)
            assert.are_same("Dungeon", questTagName2)
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
            assert.are_same(81, questTagId2)
            assert.are_same("Dungeon", questTagName2)

            assert.spy(_G.GetQuestTagInfo).was.called(2)
        end)
    end)

    describe("IsTrivial", function()
        it("should return false for scaling quests", function()
            QuestiePlayer.GetPlayerLevel = spy.new(function() return 60 end)

            assert.is_false(QuestieDB.IsTrivial(-1))
            assert.spy(QuestiePlayer.GetPlayerLevel).was.not_called()
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
