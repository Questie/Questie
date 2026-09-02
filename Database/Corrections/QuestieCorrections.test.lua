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

    describe("SetCorrection", function()
        local npcKeys

        before_each(function()
            npcKeys = QuestieDB.npcKeys
            mock.SetBaseRow("Npc", 14828, {
                [npcKeys.name] = "Gelvas Grimegate",
                [npcKeys.spawns] = {[1519] = {{60, 60}}},
                [npcKeys.zoneID] = 1519,
            })
        end)

        after_each(function()
            -- The caller-source test stubs WoW's debugstack; busted has none of its own.
            _G.debugstack = nil
        end)

        it("publishes rows under owner Questie immediately, leaving GetRaw untouched", function()
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {[14828] = {[npcKeys.zoneID] = 215}})

            assert.are_same(215, LibQuestieDB.Npc.Get(14828, "zoneID"))
            assert.are_same(1519, LibQuestieDB.Npc.GetRaw(14828, "zoneID"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Npc", 14828, "zoneID"))
            assert.are_same({"QuestieTDB", "Questie"}, LibQuestieDB.GetOwners())
        end)

        it("replaces the slot's rows on the next write", function()
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {
                [14828] = {[npcKeys.spawns] = {[215] = {{37.24, 37.67}}}, [npcKeys.zoneID] = 215},
            })

            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {
                [14828] = {[npcKeys.spawns] = {[12] = {{41.5, 68.87}}}, [npcKeys.zoneID] = 12},
            })

            assert.are_same({[12] = {{41.5, 68.87}}}, LibQuestieDB.Npc.Get(14828, "spawns"))
            assert.are_same(12, LibQuestieDB.Npc.Get(14828, "zoneID"))
        end)

        it("withdraws the slot with nil so the provider rows show through again", function()
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {[14828] = {[npcKeys.zoneID] = 215}})

            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", nil)

            assert.are_same(1519, LibQuestieDB.Npc.Get(14828, "zoneID"))
            assert.are_same("QuestieTDB", LibQuestieDB.Corrections.GetProvenance("Npc", 14828, "zoneID"))
        end)

        it("normalizes empty rows to a withdrawal", function()
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {[14828] = {[npcKeys.zoneID] = 215}})

            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {})

            assert.are_same(1519, LibQuestieDB.Npc.Get(14828, "zoneID"))
        end)

        it("skips the provider entirely when withdrawing a slot that was never published", function()
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", nil)
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {})

            assert.are_same(0, mock.publishCounts.Npc)
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.not_called()
        end)

        it("refreshes exactly the union of the old and new row IDs for the written datatype", function()
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {[14828] = {[npcKeys.zoneID] = 215}})
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.called_with("Npc", {[14828] = true})

            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {[14829] = {[npcKeys.zoneID] = 12}})
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.called_with("Npc", {[14828] = true, [14829] = true})

            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", nil)

            -- Withdrawal must evict what the withdrawn rows had published.
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.called(3)
            assert.spy(QuestieDB.RefreshAfterCorrectionApply).was.called_with("Npc", {[14829] = true})
        end)

        it("keeps independent slots independent", function()
            local objectKeys = QuestieDB.objectKeys
            mock.SetBaseRow("Object", 1617, {[objectKeys.name] = "Silverleaf", [objectKeys.spawns] = {[1] = {{10, 10}}}})
            QuestieCorrections.SetCorrection("Object", "GatheringNodeDisplayPolicy", {[1617] = {[objectKeys.spawns] = {}}})
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {[14828] = {[npcKeys.zoneID] = 215}})

            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", nil)

            assert.is_nil(LibQuestieDB.Object.Get(1617, "spawns"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Object", 1617, "spawns"))
        end)

        it("records where each slot was last written", function()
            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {[14828] = {[npcKeys.zoneID] = 215}})

            assert.are_same("string", type(QuestieCorrections.correctionSources["Npc:DarkmoonFaire"]))
        end)

        it("records the writer's frame, not the pcall, profiler wrapper, or tail-call slot between them", function()
            -- The profiler's hook wrapper tail-calls the module function, which Lua reports as "(tail call)".
            local frames = {
                [3] = "[C]: in function 'pcall'",
                [4] = "Modules/Profiler/QuestieProfiler.lua:544: in function <...>",
                [5] = "(tail call): ?",
                [6] = "Database/Corrections/Holidays/QuestieEvent.lua:395: in function 'Load'",
                [7] = "Modules/QuestieInit.lua:150: in function <...>",
            }
            _G.debugstack = function(level)
                return frames[level]
            end

            QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", {[14828] = {[npcKeys.zoneID] = 215}})

            assert.are_same(frames[6], QuestieCorrections.correctionSources["Npc:DarkmoonFaire"])
        end)
    end)

    describe("Initialize policy slots", function()
        local GATHERING_NODE_OBJECT_IDS = {
            1617, 1618, 1619, 1620, 1621, 1622, 1623, 1624, 1628,
            1731, 1732, 1733, 1734, 1735, 123848, 150082, 175404, 176643,
            177388, 324, 150079, 176645, 2040, 123310,
        }

        ---Seeds both attunement quests with a provider prerequisite the phase policy must replace or clear.
        ---@return nil
        local function _SeedAttunementQuests()
            local questKeys = QuestieDB.questKeys
            mock.SetBaseRow("Quest", 10944, {[questKeys.name] = "The Secret Compromised", [questKeys.preQuestSingle] = {1}})
            mock.SetBaseRow("Quest", 11007, {[questKeys.name] = "Kael'thas and the Verdant Sphere", [questKeys.preQuestSingle] = {1}})
        end

        it("clears composed spawns for all 24 gathering-node Objects while GetRaw keeps provider spawns", function()
            local objectKeys = QuestieDB.objectKeys
            for _, objectId in ipairs(GATHERING_NODE_OBJECT_IDS) do
                mock.SetBaseRow("Object", objectId, {
                    [objectKeys.name] = "Node " .. objectId,
                    [objectKeys.spawns] = {[1] = {{10, 10}}},
                })
            end
            mock.SetBaseRow("Object", 31, {[objectKeys.name] = "Old Lion Statue", [objectKeys.spawns] = {[1519] = {{50, 50}}}})

            QuestieCorrections.Initialize()

            for _, objectId in ipairs(GATHERING_NODE_OBJECT_IDS) do
                assert.is_nil(LibQuestieDB.Object.Get(objectId, "spawns"), "spawns visible for " .. objectId)
                assert.are_same({[1] = {{10, 10}}}, LibQuestieDB.Object.GetRaw(objectId, "spawns"))
                assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Object", objectId, "spawns"))
                assert.are_same("Node " .. objectId, LibQuestieDB.Object.Get(objectId, "name"))
            end
            assert.are_same({[1519] = {{50, 50}}}, LibQuestieDB.Object.Get(31, "spawns"))
        end)

        it("publishes only the gathering-node slot on Era", function()
            Expansions.Current = Expansions.Era

            QuestieCorrections.Initialize()

            local slots = {}
            for index, registration in ipairs(mock.registrations.Questie) do
                slots[index] = registration.datatype .. ":" .. registration.name
            end
            assert.are_same({"Object:GatheringNodeDisplayPolicy"}, slots)
            assert.is_false(LibQuestieDB.Quest.Exists(10944))
            assert.is_false(LibQuestieDB.Quest.Exists(11007))
        end)

        it("applies the phase two prerequisites on TBC before phase three, clearing the provider single prerequisite", function()
            Expansions.Current = Expansions.Tbc
            ContentPhases.activePhases.TBC = 2
            _SeedAttunementQuests()

            QuestieCorrections.Initialize()

            assert.are_same({10901, 11052}, LibQuestieDB.Quest.Get(10944, "preQuestGroup"))
            assert.is_nil(LibQuestieDB.Quest.Get(10944, "preQuestSingle"))
            assert.are_same({10888}, LibQuestieDB.Quest.Get(11007, "preQuestSingle"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Quest", 10944, "preQuestGroup"))
            assert.are_same({1}, LibQuestieDB.Quest.GetRaw(10944, "preQuestSingle"))
        end)

        it("replaces the prerequisites when a phase switch re-publishes the ContentPhasePolicy slot", function()
            Expansions.Current = Expansions.Tbc
            ContentPhases.activePhases.TBC = 2
            _SeedAttunementQuests()
            QuestieCorrections.Initialize()

            -- The live-switch pattern: whoever advances the phase re-publishes the slot. A real
            -- post-initialization switch must also invalidate the affected quests through the
            -- quest lifecycle; see the Quest caveat on QuestieDB.RefreshAfterCorrectionApply.
            ContentPhases.activePhases.TBC = 3
            local QuestieTBCPolicyCorrections = QuestieLoader:ImportModule("QuestieTBCPolicyCorrections")
            QuestieCorrections.SetCorrection("Quest", "ContentPhasePolicy", QuestieTBCPolicyCorrections:LoadContentPhaseFixes())

            assert.is_nil(LibQuestieDB.Quest.Get(10944, "preQuestGroup"))
            assert.are_same({10708, 11052}, LibQuestieDB.Quest.Get(10944, "preQuestSingle"))
            assert.is_nil(LibQuestieDB.Quest.Get(11007, "preQuestSingle"))
        end)
    end)

    describe("blacklists", function()
        it("builds Quest, NPC, and Item blacklists from filtered module results", function()
            QuestieCorrections.Initialize()

            assert.are_same({[101] = true}, QuestieCorrections.questItemBlacklist)
            assert.are_same({[201] = true}, QuestieCorrections.questNPCBlacklist)
            assert.are_same({[301] = true}, QuestieCorrections.hiddenQuests)
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
