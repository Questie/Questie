dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("QuestieCorrections", function()
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type Expansions
    local Expansions
    ---@type ContentPhases
    local ContentPhases
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieTDBMock
    local mock
    local LibQuestieDB

    local originalExpansion
    local originalIsHardcore
    local originalIsTitanReforged
    local originalTBCPhase

    ---@return ExternalLocaleCorrections
    local function _EmptyExternalLocaleCorrections()
        return {Item = {}, Quest = {}, Npc = {}, Object = {}}
    end

    before_each(function()
        mock = LoadQuestieTDBMock()
        LibQuestieDB = mock.lib

        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        originalIsHardcore = Questie.IsHardcore
        originalIsTitanReforged = Questie.IsTitanReforged

        Expansions.Current = Expansions.Era
        Questie.IsHardcore = false
        Questie.IsTitanReforged = false
        Questie.db.global.isleOfQuelDanasPhase = 1

        dofile("Database/Corrections/ContentPhases/ContentPhases.lua")
        ContentPhases = QuestieLoader:ImportModule("ContentPhases")
        originalTBCPhase = ContentPhases.activePhases.TBC
        dofile("Database/Corrections/QuestiePolicy/tbcPolicyCorrections.lua")

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.IsInitialized = false
        QuestieDB.RefreshAfterCorrectionApply = spy.new(function() end)

        local BlacklistFilter = QuestieLoader:ImportModule("BlacklistFilter")
        BlacklistFilter.filterExpansion = function(blacklist)
            for id, hide in pairs(blacklist) do
                if hide == false then
                    blacklist[id] = nil
                end
            end
            return blacklist
        end

        local QuestieItemBlacklist = QuestieLoader:ImportModule("QuestieItemBlacklist")
        QuestieItemBlacklist.Load = function() return {[101] = true, [102] = false} end

        local QuestieNPCBlacklist = QuestieLoader:ImportModule("QuestieNPCBlacklist")
        QuestieNPCBlacklist.Load = function() return {[201] = true, [202] = false} end

        local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
        QuestieQuestBlacklist.Load = function() return {[301] = true, [302] = false} end
        QuestieQuestBlacklist.LoadAutoBlacklistWotlk = function() return {} end
        QuestieQuestBlacklist.LoadAutoBlacklistIsTitanReforged = function() return {} end

        local HardcoreBlacklist = QuestieLoader:ImportModule("HardcoreBlacklist")
        HardcoreBlacklist.Load = function() return {} end

        local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
        IsleOfQuelDanas.MAX_ISLE_OF_QUEL_DANAS_PHASES = 9
        IsleOfQuelDanas.quests = {
            [9] = {},
        }

        dofile("Database/Corrections/QuestieCorrections.lua")
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    end)

    after_each(function()
        Expansions.Current = originalExpansion
        Questie.IsHardcore = originalIsHardcore
        Questie.IsTitanReforged = originalIsTitanReforged
        ContentPhases.activePhases.TBC = originalTBCPhase
    end)

    describe("Policy Correction registration", function()
        it("registers exactly the eight Questie Policy Corrections once under owner Questie", function()
            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())
            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())

            local registered = {}
            for index, registration in ipairs(mock.registrations.Questie) do
                registered[index] = {registration.datatype, registration.name, registration.loadOrder}
            end
            assert.are_same({
                {"Npc", "DarkmoonFaire", 100},
                {"Object", "GatheringNodeDisplayPolicy", 200},
                {"Quest", "ContentPhasePolicy", 300},
                {"Item", "RuntimeItemRepair", 400},
                {"Item", "ExternalLocaleItem", 500},
                {"Quest", "ExternalLocaleQuest", 501},
                {"Npc", "ExternalLocaleNpc", 502},
                {"Object", "ExternalLocaleObject", 503},
            }, registered)
            assert.are_same({"QuestieTDB", "Questie"}, LibQuestieDB.GetOwners())
            assert.is_nil(mock.registrations.Questie[9])
        end)

        it("applies owner Questie once during initialization without refreshing an uninitialized QuestieDB", function()
            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())

            assert.are_same(1, mock.applyCount.Questie)
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.not_called()
        end)

        it("refreshes QuestieDB after every apply once QuestieDB is initialized", function()
            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())
            QuestieDB.IsInitialized = true

            QuestieCorrections.SetDarkmoonNpcCorrections({})
            QuestieCorrections.ReapplyPolicyCorrections()

            assert.are_same(3, mock.applyCount.Questie)
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.called(2)
        end)
    end)

    describe("GatheringNodeDisplayPolicy", function()
        local GATHERING_NODE_OBJECT_IDS = {
            1617, 1618, 1619, 1620, 1621, 1622, 1623, 1624, 1628,
            1731, 1732, 1733, 1734, 1735, 123848, 150082, 175404, 176643,
            177388, 324, 150079, 176645, 2040, 123310,
        }

        it("clears composed spawns for all 24 gathering-node Objects while GetRaw keeps provider spawns", function()
            local objectKeys = QuestieDB.objectKeys
            for _, objectId in ipairs(GATHERING_NODE_OBJECT_IDS) do
                mock.SetBaseRow("Object", objectId, {
                    [objectKeys.name] = "Node " .. objectId,
                    [objectKeys.spawns] = {[1] = {{10, 10}}},
                })
            end
            mock.SetBaseRow("Object", 31, {[objectKeys.name] = "Old Lion Statue", [objectKeys.spawns] = {[1519] = {{50, 50}}}})

            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())

            for _, objectId in ipairs(GATHERING_NODE_OBJECT_IDS) do
                assert.is_nil(LibQuestieDB.Object.Get(objectId, "spawns"), "spawns visible for " .. objectId)
                assert.are_same({[1] = {{10, 10}}}, LibQuestieDB.Object.GetRaw(objectId, "spawns"))
                assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Object", objectId, "spawns"))
                assert.are_same("Node " .. objectId, LibQuestieDB.Object.Get(objectId, "name"))
            end
            assert.are_same({[1519] = {{50, 50}}}, LibQuestieDB.Object.Get(31, "spawns"))
        end)
    end)

    describe("ContentPhasePolicy", function()
        local questKeys

        before_each(function()
            questKeys = QuestieDB.questKeys
            mock.SetBaseRow("Quest", 10944, {[questKeys.name] = "The Secret Compromised"})
            mock.SetBaseRow("Quest", 11007, {[questKeys.name] = "Kael'thas and the Verdant Sphere"})
        end)

        it("does not introduce the TBC prerequisite rows on Era", function()
            Expansions.Current = Expansions.Era
            mock.base.Quest[10944] = nil
            mock.base.Quest[11007] = nil

            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())

            assert.is_false(LibQuestieDB.Quest.Exists(10944))
            assert.is_false(LibQuestieDB.Quest.Exists(11007))
        end)

        it("applies the phase two prerequisites on TBC before phase three", function()
            Expansions.Current = Expansions.Tbc
            ContentPhases.activePhases.TBC = 2

            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())

            assert.are_same({10901, 11052}, LibQuestieDB.Quest.Get(10944, "preQuestGroup"))
            assert.is_nil(LibQuestieDB.Quest.Get(10944, "preQuestSingle"))
            assert.are_same({10888}, LibQuestieDB.Quest.Get(11007, "preQuestSingle"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Quest", 10944, "preQuestGroup"))
        end)

        it("replaces the prerequisites when the phase advances and the owner reapplies", function()
            Expansions.Current = Expansions.Tbc
            ContentPhases.activePhases.TBC = 2
            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())

            ContentPhases.activePhases.TBC = 3
            QuestieCorrections.ReapplyPolicyCorrections()

            assert.is_nil(LibQuestieDB.Quest.Get(10944, "preQuestGroup"))
            assert.are_same({10708, 11052}, LibQuestieDB.Quest.Get(10944, "preQuestSingle"))
            assert.is_nil(LibQuestieDB.Quest.Get(11007, "preQuestSingle"))
        end)
    end)

    describe("SetDarkmoonNpcCorrections", function()
        local npcKeys
        local mulgoreCorrections
        local elwynnCorrections

        before_each(function()
            npcKeys = QuestieDB.npcKeys
            mock.SetBaseRow("Npc", 14828, {
                [npcKeys.name] = "Gelvas Grimegate",
                [npcKeys.spawns] = {[1519] = {{60, 60}}},
                [npcKeys.zoneID] = 1519,
            })
            mulgoreCorrections = {
                [14828] = {[npcKeys.spawns] = {[215] = {{37.24, 37.67}}}, [npcKeys.zoneID] = 215},
            }
            elwynnCorrections = {
                [14828] = {[npcKeys.spawns] = {[12] = {{41.5, 68.87}}}, [npcKeys.zoneID] = 12},
            }
            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())
        end)

        it("publishes the selected location and replaces it on the next selection", function()
            QuestieCorrections.SetDarkmoonNpcCorrections(mulgoreCorrections)

            assert.are_same({[215] = {{37.24, 37.67}}}, LibQuestieDB.Npc.Get(14828, "spawns"))
            assert.are_same(215, LibQuestieDB.Npc.Get(14828, "zoneID"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Npc", 14828, "spawns"))

            QuestieCorrections.SetDarkmoonNpcCorrections(elwynnCorrections)

            assert.are_same({[12] = {{41.5, 68.87}}}, LibQuestieDB.Npc.Get(14828, "spawns"))
            assert.are_same(12, LibQuestieDB.Npc.Get(14828, "zoneID"))
        end)

        it("withdraws the location through an empty table", function()
            QuestieCorrections.SetDarkmoonNpcCorrections(mulgoreCorrections)

            QuestieCorrections.SetDarkmoonNpcCorrections({})

            assert.are_same({[1519] = {{60, 60}}}, LibQuestieDB.Npc.Get(14828, "spawns"))
            assert.are_same(1519, LibQuestieDB.Npc.Get(14828, "zoneID"))
            assert.are_same("QuestieTDB", LibQuestieDB.Corrections.GetProvenance("Npc", 14828, "spawns"))
        end)

        it("applies exactly once per selection, keeps GetRaw unchanged, and is idempotent", function()
            local applyCountBefore = mock.applyCount.Questie

            QuestieCorrections.SetDarkmoonNpcCorrections(mulgoreCorrections)
            QuestieCorrections.SetDarkmoonNpcCorrections(mulgoreCorrections)

            assert.are_same(applyCountBefore + 2, mock.applyCount.Questie)
            assert.are_same({[215] = {{37.24, 37.67}}}, LibQuestieDB.Npc.Get(14828, "spawns"))
            assert.are_same({[1519] = {{60, 60}}}, LibQuestieDB.Npc.GetRaw(14828, "spawns"))
            assert.are_same("Gelvas Grimegate", LibQuestieDB.Npc.Get(14828, "name"))
        end)
    end)

    describe("RepairMissingItem", function()
        before_each(function()
            QuestieCorrections.InitializePolicyCorrections(_EmptyExternalLocaleCorrections())
            QuestieDB.IsInitialized = true
        end)

        it("adds a name-only Item Correction for a missing Item and refreshes QuestieDB", function()
            QuestieCorrections.RepairMissingItem(999, "Repaired Item")

            assert.is_true(LibQuestieDB.Item.Exists(999))
            assert.are_same("Repaired Item", LibQuestieDB.Item.Get(999, "name"))
            assert.is_nil(LibQuestieDB.Item.Get(999, "npcDrops"))
            assert.is_nil(LibQuestieDB.Item.GetRaw(999, "name"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Item", 999, "name"))
            assert.is_true(LibQuestieDB.Item.GetAllIds(true)[999])
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.called(1)
        end)

        it("preserves earlier repairs when another Item loads", function()
            QuestieCorrections.RepairMissingItem(999, "Repaired Item")

            QuestieCorrections.RepairMissingItem(1000, "Second Item")

            assert.are_same("Repaired Item", LibQuestieDB.Item.Get(999, "name"))
            assert.are_same("Second Item", LibQuestieDB.Item.Get(1000, "name"))
        end)

        it("treats a repeated callback for one Item as a no-op", function()
            QuestieCorrections.RepairMissingItem(999, "Repaired Item")
            local applyCountAfterFirst = mock.applyCount.Questie

            QuestieCorrections.RepairMissingItem(999, "Repaired Item")

            assert.are_same(applyCountAfterFirst, mock.applyCount.Questie)
            assert.are_same("Repaired Item", LibQuestieDB.Item.Get(999, "name"))
        end)

        it("ignores a nil Item name", function()
            local applyCountBefore = mock.applyCount.Questie

            QuestieCorrections.RepairMissingItem(999, nil)

            assert.are_same(applyCountBefore, mock.applyCount.Questie)
            assert.is_false(LibQuestieDB.Item.Exists(999))
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.not_called()
        end)

    end)

    describe("external locale Corrections", function()
        local itemKeys, questKeys, npcKeys, objectKeys
        local externalRows

        before_each(function()
            itemKeys, questKeys, npcKeys, objectKeys = QuestieDB.itemKeys, QuestieDB.questKeys, QuestieDB.npcKeys, QuestieDB.objectKeys
            mock.SetBaseRow("Item", 5, {[itemKeys.name] = "Sharptalon's Claw"})
            mock.SetBaseRow("Quest", 2, {[questKeys.name] = "Sharptalon's Claw", [questKeys.objectivesText] = {"Bring the claw."}})
            mock.SetBaseRow("Npc", 30, {[npcKeys.name] = "Forest Spider", [npcKeys.subName] = "Spider"})
            mock.SetBaseRow("Object", 31, {[objectKeys.name] = "Old Lion Statue"})
            externalRows = {
                Item = {[5] = {[itemKeys.name] = "Klaue von Scharfkralle"}},
                Quest = {[2] = {[questKeys.name] = "Klaue von Scharfkralle", [questKeys.objectivesText] = {"Bringt die Klaue."}}},
                Npc = {[30] = {[npcKeys.name] = "Waldspinne", [npcKeys.subName] = "Spinne"}},
                Object = {[31] = {[objectKeys.name] = "Alte Löwenstatue"}},
            }
        end)

        it("applies the initial external rows under owner Questie for all four datatypes", function()
            QuestieCorrections.InitializePolicyCorrections(externalRows)

            assert.are_same("Klaue von Scharfkralle", LibQuestieDB.Item.Get(5, "name"))
            assert.are_same("Klaue von Scharfkralle", LibQuestieDB.Quest.Get(2, "name"))
            assert.are_same({"Bringt die Klaue."}, LibQuestieDB.Quest.Get(2, "objectivesText"))
            assert.are_same("Waldspinne", LibQuestieDB.Npc.Get(30, "name"))
            assert.are_same("Spinne", LibQuestieDB.Npc.Get(30, "subName"))
            assert.are_same("Alte Löwenstatue", LibQuestieDB.Object.Get(31, "name"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Npc", 30, "subName"))
            assert.are_same("Sharptalon's Claw", LibQuestieDB.Item.GetRaw(5, "name"))
        end)

        it("withdraws all four external layers", function()
            QuestieCorrections.InitializePolicyCorrections(externalRows)

            QuestieCorrections.WithdrawExternalLocaleCorrections()

            assert.are_same("Sharptalon's Claw", LibQuestieDB.Item.Get(5, "name"))
            assert.are_same("Sharptalon's Claw", LibQuestieDB.Quest.Get(2, "name"))
            assert.are_same("Forest Spider", LibQuestieDB.Npc.Get(30, "name"))
            assert.are_same("Old Lion Statue", LibQuestieDB.Object.Get(31, "name"))
            assert.are_same("QuestieTDB", LibQuestieDB.Corrections.GetProvenance("Object", 31, "name"))
        end)

        it("switches withdrawal-first so an entity created only by the old external layer cannot validate itself", function()
            externalRows.Item[999] = {[itemKeys.name] = "Only in the old locale"}
            QuestieCorrections.InitializePolicyCorrections(externalRows)
            assert.is_true(LibQuestieDB.Item.Exists(999))
            QuestieDB.IsInitialized = true
            local applyCountBefore = mock.applyCount.Questie

            local existedWhileBuilding
            QuestieCorrections.SetExternalLocaleCorrections(function()
                existedWhileBuilding = LibQuestieDB.Item.Exists(999)
                return {
                    Item = existedWhileBuilding and {[999] = {[itemKeys.name] = "Stale"}} or {},
                    Quest = {},
                    Npc = {[30] = {[npcKeys.name] = "Araignée des bois"}},
                    Object = {},
                }
            end)

            assert.is_false(existedWhileBuilding)
            assert.is_false(LibQuestieDB.Item.Exists(999))
            assert.are_same("Araignée des bois", LibQuestieDB.Npc.Get(30, "name"))
            assert.are_same("Sharptalon's Claw", LibQuestieDB.Item.Get(5, "name"))
            assert.are_same(applyCountBefore + 2, mock.applyCount.Questie)
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.called(2)
        end)
    end)

    describe("blacklists", function()
        it("builds Quest, NPC, and Item blacklists from filtered module results", function()
            QuestieCorrections.Initialize()

            assert.are_same({[101] = true}, QuestieCorrections.questItemBlacklist)
            assert.are_same({[201] = true}, QuestieCorrections.questNPCBlacklist)
            assert.are_same({[301] = true}, QuestieCorrections.hiddenQuests)
        end)

        it("keeps blacklist construction separate from registrar state", function()
            QuestieCorrections.Initialize()

            assert.is_nil(mock.registrations.Questie)
            assert.is_nil(mock.applyCount.Questie)
        end)

        it("merges the completed Isle of Quel'Danas phase without overriding existing policy", function()
            local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
            QuestieQuestBlacklist.Load = function() return {[401] = "HIDE_ON_MAP"} end
            local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
            IsleOfQuelDanas.quests[9] = {
                [401] = true,
                [402] = false,
            }
            Questie.db.global.isleOfQuelDanasPhase = 9

            QuestieCorrections.Initialize()

            assert.are_same("HIDE_ON_MAP", QuestieCorrections.hiddenQuests[401])
            assert.is_false(QuestieCorrections.hiddenQuests[402])
        end)

        it("adds WotLK and Titan blacklists without overriding existing policy", function()
            Expansions.Current = Expansions.Wotlk
            Questie.IsTitanReforged = true
            local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
            QuestieQuestBlacklist.Load = function() return {[501] = "HIDE_ON_MAP"} end
            QuestieQuestBlacklist.LoadAutoBlacklistWotlk = function()
                return {[501] = true, [502] = true}
            end
            QuestieQuestBlacklist.LoadAutoBlacklistIsTitanReforged = function()
                return {[502] = false, [503] = true}
            end

            QuestieCorrections.Initialize()

            assert.are_same("HIDE_ON_MAP", QuestieCorrections.hiddenQuests[501])
            assert.is_true(QuestieCorrections.hiddenQuests[502])
            assert.is_true(QuestieCorrections.hiddenQuests[503])
        end)

        it("lets Hardcore policy hide quests regardless of earlier visibility policy", function()
            Questie.IsHardcore = true
            local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
            QuestieQuestBlacklist.Load = function() return {[601] = "HIDE_ON_MAP"} end
            local HardcoreBlacklist = QuestieLoader:ImportModule("HardcoreBlacklist")
            HardcoreBlacklist.Load = function() return {[601] = true, [602] = true} end

            QuestieCorrections.Initialize()

            assert.is_true(QuestieCorrections.hiddenQuests[601])
            assert.is_true(QuestieCorrections.hiddenQuests[602])
        end)
    end)
end)
