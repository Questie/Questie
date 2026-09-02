dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("QuestieDB", function()
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieTDBMock
    local mock

    ---@type Quest
    local testQuest

    before_each(function()
        mock = LoadQuestieTDBMock()
        Questie.db.char.complete = {}
        Questie.IsTitanReforged = false
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        QuestieCorrections.questItemBlacklist = {}

        dofile("Database/QuestieDB.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.killCreditObjectiveFirst = {}
        QuestieDB.objectObjectiveFirst = {}
        QuestieDB.itemObjectiveFirst = {}
        QuestieDB.eventObjectiveFirst = {}
        QuestieDB.spellObjectiveFirst = {}
        QuestieDB.QueryNPCSingle = function() return nil end
        QuestieDB.private.questCache = {}
        QuestieDB.private.itemCache = {}
        dofile("Localization/l10n.lua")
        dofile("Database/Corrections/titanReforgedQuestTags.lua")
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

        it("should move a structured spell objective first when corrected", function()
            local questKeys = QuestieDB.questKeys
            testQuest[questKeys.objectives] = {
                [1] = {{1000, "Slay the target"}},
                [6] = {{12345, "Cast the spell", 67890}}
            }
            QuestieDB.spellObjectiveFirst[123] = true
            QuestieDB.QueryQuest = spy.new(function() return testQuest end)
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end

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

        it("uses the API for Titan quest IDs outside Titan Reforged", function()
            _G.GetQuestTagInfo = spy.new(function() return 41, "PvP" end)

            local questTagId, questTagName = QuestieDB.GetQuestTagInfo(93975)

            assert.are_same(41, questTagId)
            assert.are_same("PvP", questTagName)
            assert.spy(_G.GetQuestTagInfo).was.called_with(93975)
        end)

        it("uses Titan quest tag corrections on Titan Reforged", function()
            Questie.IsTitanReforged = true
            QuestieDB.private.InitializeQuestTagInfoCorrections()
            _G.GetQuestTagInfo = spy.new(function() return 41, "PvP" end)

            local questTagId, questTagName = QuestieDB.GetQuestTagInfo(93975)

            assert.are_same(62, questTagId)
            assert.are_same("Raid", questTagName)
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

    describe("Initialize", function()
        local LibQuestieDB

        before_each(function()
            LibQuestieDB = mock.lib
            QuestieLib.TableMemoizeFunction = function() return {} end
            Questie.db.char.hidden = {}

            local questKeys, npcKeys, itemKeys, objectKeys = QuestieDB.questKeys, QuestieDB.npcKeys, QuestieDB.itemKeys, QuestieDB.objectKeys
            mock.SetBaseRow("Quest", 2, {
                [questKeys.name] = "Sharptalon's Claw",
                [questKeys.startedBy] = {{100}},
                [questKeys.finishedBy] = {{200}},
                [questKeys.requiredLevel] = 20,
            })
            mock.SetBaseRow("Npc", 30, {
                [npcKeys.name] = "Forest Spider",
                [npcKeys.zoneID] = 12,
                [npcKeys.friendlyToFaction] = "H",
            })
            mock.SetBaseRow("Item", 5, {
                [itemKeys.name] = "Sharptalon's Claw",
                [itemKeys.npcDrops] = {30},
            })
            mock.SetBaseRow("Object", 31, {
                [objectKeys.name] = "Old Lion Statue",
                [objectKeys.zoneID] = 1519,
            })
        end)

        it("binds the provider schema, query functions, and Objective Order tables at file load", function()
            LibQuestieDB.ObjectiveFirst.spellObjectiveFirst[2] = true
            -- The outer before_each stubs some of these after loading; a fresh load shows the bindings.
            dofile("Database/QuestieDB.lua")
            QuestieDB = QuestieLoader:ImportModule("QuestieDB")

            assert.are_equal(LibQuestieDB.Meta.QuestMeta.questKeys, QuestieDB.questKeys)
            assert.are_equal(LibQuestieDB.Meta.NpcMeta.npcKeys, QuestieDB.npcKeys)
            assert.are_equal(LibQuestieDB.Meta.ItemMeta.itemKeys, QuestieDB.itemKeys)
            assert.are_equal(LibQuestieDB.Meta.ObjectMeta.objectKeys, QuestieDB.objectKeys)
            assert.are_same("name", QuestieDB._npcAdapterQueryOrder[QuestieDB.npcKeys.name])
            assert.are_same("zoneID", QuestieDB._objectAdapterQueryOrder[QuestieDB.objectKeys.zoneID])

            assert.are_equal(LibQuestieDB.Quest.Get, QuestieDB.QueryQuestSingle)
            assert.are_equal(LibQuestieDB.Npc.Get, QuestieDB.QueryNPCSingle)
            assert.are_equal(LibQuestieDB.Item.Get, QuestieDB.QueryItemSingle)
            assert.are_equal(LibQuestieDB.Object.Get, QuestieDB.QueryObjectSingle)
            assert.are_equal(LibQuestieDB.Quest.GetAll, QuestieDB.QueryQuest)
            assert.are_equal(LibQuestieDB.Npc.GetAll, QuestieDB.QueryNPC)
            assert.are_equal(LibQuestieDB.Item.GetAll, QuestieDB.QueryItem)
            assert.are_equal(LibQuestieDB.Object.GetAll, QuestieDB.QueryObject)

            assert.are_equal(LibQuestieDB.ObjectiveFirst.killCreditObjectiveFirst, QuestieDB.killCreditObjectiveFirst)
            assert.are_equal(LibQuestieDB.ObjectiveFirst.objectObjectiveFirst, QuestieDB.objectObjectiveFirst)
            assert.are_equal(LibQuestieDB.ObjectiveFirst.itemObjectiveFirst, QuestieDB.itemObjectiveFirst)
            assert.are_equal(LibQuestieDB.ObjectiveFirst.eventObjectiveFirst, QuestieDB.eventObjectiveFirst)
            assert.are_equal(LibQuestieDB.ObjectiveFirst.spellObjectiveFirst, QuestieDB.spellObjectiveFirst)
            assert.is_true(QuestieDB.spellObjectiveFirst[2])
        end)

        it("binds the composed ID maps", function()
            QuestieDB.Initialize()

            assert.are_equal(LibQuestieDB.Quest.GetAllIds(true), QuestieDB.QuestPointers)
            assert.are_equal(LibQuestieDB.Npc.GetAllIds(true), QuestieDB.NPCPointers)
            assert.are_equal(LibQuestieDB.Item.GetAllIds(true), QuestieDB.ItemPointers)
            assert.are_equal(LibQuestieDB.Object.GetAllIds(true), QuestieDB.ObjectPointers)
            assert.is_true(QuestieDB.QuestPointers[2])
            assert.is_true(QuestieDB.NPCPointers[30])
            assert.is_true(QuestieDB.ItemPointers[5])
            assert.is_true(QuestieDB.ObjectPointers[31])
        end)

        it("projects composed rows through the adapter query orders", function()
            QuestieLib.GetEffectiveQuestLevel = function() return 20, 20 end
            QuestiePlayer.faction = "Horde"

            QuestieDB.Initialize()

            local quest = QuestieDB.GetQuest(2)
            assert.are_same("Sharptalon's Claw", quest.name)
            assert.are_same({100}, quest.Starts.NPC)
            assert.are_same({200}, quest.Finisher.NPC)
            assert.are_same({}, quest.ObjectiveData)

            local npc = QuestieDB:GetNPC(30)
            assert.are_same("Forest Spider", npc.name)
            assert.are_same(12, npc.zoneID)
            assert.is_true(npc.friendly)

            local item = QuestieDB:GetItem(5)
            assert.are_same("Sharptalon's Claw", item.name)
            assert.are_same({{Id = 30, Type = "monster"}}, item.Sources)

            local object = QuestieDB:GetObject(31)
            assert.are_same("Old Lion Statue", object.name)
            assert.are_same(1519, object.zoneID)
        end)

        it("clears semantic caches filled before initialization", function()
            QuestieDB.private.questCache[2] = {}
            QuestieDB.private.itemCache[5] = {}
            QuestieDB.private.npcCache[30] = {}
            QuestieDB.private.zoneCache[1] = {}
            QuestieDB._CreatureLevelCache[2] = {}

            QuestieDB.Initialize()

            assert.are_same({}, QuestieDB.private.questCache)
            assert.are_same({}, QuestieDB.private.itemCache)
            assert.are_same({}, QuestieDB.private.npcCache)
            assert.are_same({}, QuestieDB.private.zoneCache)
            assert.are_same({}, QuestieDB._CreatureLevelCache)
        end)
    end)

    describe("RefreshAfterCorrectionApply", function()
        local LibQuestieDB

        before_each(function()
            LibQuestieDB = mock.lib
            QuestieLib.TableMemoizeFunction = function() return {} end
            Questie.db.char.hidden = {}
            QuestieDB.Initialize()
        end)

        it("rebinds only the written datatype's ID map", function()
            LibQuestieDB.Corrections.Set("Questie", "Item", "RuntimeItemRepair", {[999] = {[QuestieDB.itemKeys.name] = "Repaired Item"}})
            assert.are_not_equal(LibQuestieDB.Item.GetAllIds(true), QuestieDB.ItemPointers)
            -- A sentinel carries the "only": a rebind-all implementation would overwrite it with
            -- the provider's Quest map, which a kept map identity could not distinguish.
            local questPointersSentinel = {}
            QuestieDB.QuestPointers = questPointersSentinel

            QuestieDB.RefreshAfterCorrectionApply("Item", {[999] = true})

            assert.are_equal(LibQuestieDB.Item.GetAllIds(true), QuestieDB.ItemPointers)
            assert.are_equal(questPointersSentinel, QuestieDB.QuestPointers)
        end)

        it("makes a slot-added Item visible and a withdrawn Item disappear", function()
            LibQuestieDB.Corrections.Set("Questie", "Item", "RuntimeItemRepair", {[999] = {[QuestieDB.itemKeys.name] = "Repaired Item"}})
            QuestieDB.RefreshAfterCorrectionApply("Item", {[999] = true})

            assert.is_true(QuestieDB.ItemPointers[999])
            assert.are_same("Repaired Item", QuestieDB:GetItem(999).name)

            LibQuestieDB.Corrections.Set("Questie", "Item", "RuntimeItemRepair", nil)
            QuestieDB.RefreshAfterCorrectionApply("Item", {[999] = true})

            assert.is_nil(QuestieDB.ItemPointers[999])
            assert.is_nil(QuestieDB:GetItem(999))
        end)

        it("evicts exactly the changed Quests and their derived creature levels", function()
            local changedQuest = {Id = 2}
            local untouchedQuest = {Id = 3}
            QuestieDB.private.questCache[2] = changedQuest
            QuestieDB.private.questCache[3] = untouchedQuest
            QuestieDB.private.itemCache[5] = {}
            QuestieDB._CreatureLevelCache[2] = {}
            QuestieDB._CreatureLevelCache[3] = {}

            QuestieDB.RefreshAfterCorrectionApply("Quest", {[2] = true})

            assert.is_nil(QuestieDB.private.questCache[2])
            assert.are_equal(untouchedQuest, QuestieDB.private.questCache[3])
            assert.is_nil(QuestieDB._CreatureLevelCache[2])
            assert.is_not_nil(QuestieDB._CreatureLevelCache[3])
            assert.is_not_nil(QuestieDB.private.itemCache[5])

            -- The documented caveat, concretely: a lifecycle holder keeps the old object while a
            -- fresh read builds a replacement. A post-initialization Quest writer must reconcile
            -- the two through the quest lifecycle.
            mock.SetBaseRow("Quest", 2, {
                [QuestieDB.questKeys.name] = "Changed Quest",
                [QuestieDB.questKeys.startedBy] = {{100}},
            })
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60 end
            local rebuilt = QuestieDB.GetQuest(2)
            assert.are_not_equal(changedQuest, rebuilt)
            assert.are_same("Changed Quest", rebuilt.name)
        end)

        it("evicts changed NPCs and the whole derived creature-level cache on an NPC write", function()
            QuestieDB.private.npcCache[30] = {}
            QuestieDB.private.npcCache[31] = {}
            QuestieDB._CreatureLevelCache[2] = {}
            QuestieDB.private.questCache[2] = {Id = 2}

            QuestieDB.RefreshAfterCorrectionApply("Npc", {[30] = true})

            assert.is_nil(QuestieDB.private.npcCache[30])
            assert.is_not_nil(QuestieDB.private.npcCache[31])
            assert.are_same({}, QuestieDB._CreatureLevelCache)
            assert.is_not_nil(QuestieDB.private.questCache[2])
        end)

        it("wipes the derived creature-level cache on an Item write, since levels derive from npcDrops", function()
            QuestieDB._CreatureLevelCache[2] = {}

            QuestieDB.RefreshAfterCorrectionApply("Item", {[999] = true})

            assert.are_same({}, QuestieDB._CreatureLevelCache)
        end)

        it("fails fast on an unknown datatype instead of silently skipping the refresh", function()
            assert.has_error(function()
                QuestieDB.RefreshAfterCorrectionApply("npc", {[30] = true})
            end, "RefreshAfterCorrectionApply: unknown datatype npc")
        end)
    end)
end)
