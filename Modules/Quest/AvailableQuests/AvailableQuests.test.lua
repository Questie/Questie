local TestUtils = dofile("setupTests.lua")

local match = require("luassert.match")
local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("AvailableQuests", function()
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieTooltips
    local QuestieTooltips
    ---@type QuestieMap
    local QuestieMap
    ---@type DailyQuestComms
    local DailyQuestComms
    ---@type ThreadLib
    local ThreadLib
    ---@type DailyQuestCommsBlacklist
    local DailyQuestCommsBlacklist
    ---@type IsleOfQuelDanas
    local IsleOfQuelDanas

    ---@type AvailableQuests
    local AvailableQuests

    local originalThread
    local originalThreadCallbackInstant
    local originalGetPlayerLevel
    local originalGetQuestGreenRange
    local originalIsleOfQuelDanasQuests
    local originalQuestPointers
    local originalQuestIdFrames
    local QUEST_ID = 123
    local NPC_ID = 456

    before_each(function()
        _G.C_Timer = {
            After = function() end
        }

        Questie.db.global.lastKnownDailyReset = {}
        Questie.db.global.unavailableQuestsDeterminedByTalking = {}
        Questie.db.global.unavailableDailyQuestsByNpc = {}
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeons = function() return {} end
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetPlayerLevel = function() return 20 end
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.DidDailyResetHappenSinceLastLogin = function() return false end
        -- Level-capable by default so existing hide-behaviour tests are unaffected.
        -- Tests for the level-range guard override this.
        QuestieLib.GetEffectiveQuestLevel = function() return 1, 1, 0 end
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetNPC = function() return nil end
        QuestieDB.GetQuest = function() return nil end
        QuestieDB.IsDailyQuest = function() return false end
        QuestieDB.IsWeeklyQuest = function() return false end
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        originalGetPlayerLevel = QuestiePlayer.GetPlayerLevel
        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        DailyQuestComms = QuestieLoader:ImportModule("DailyQuestComms")
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        originalThreadCallbackInstant = ThreadLib.ThreadCallbackInstant
        ThreadLib.ThreadCallbackInstant = function(fun, callback)
            fun()
            callback()
        end
        DailyQuestCommsBlacklist = QuestieLoader:ImportModule("DailyQuestCommsBlacklist")
        DailyQuestCommsBlacklist.IsBlacklisted = function() return false end
        IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
        originalThread = ThreadLib.Thread
        originalIsleOfQuelDanasQuests = IsleOfQuelDanas.quests
        originalQuestPointers = QuestieDB.QuestPointers
        originalQuestIdFrames = QuestieMap.questIdFrames
        originalGetQuestGreenRange = _G.GetQuestGreenRange
        _G.GetQuestGreenRange = function() return 5 end

        Questie.db.profile.availableIconLimit = 10

        dofile("Modules/Quest/AvailableQuests/AvailableQuests.lua")
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.Initialize()
        TestUtils.clearTable(AvailableQuests.__availableQuests)
        TestUtils.clearTable(AvailableQuests.__availableQuestsByNpc)
        TestUtils.clearTable(AvailableQuests.__unavailableQuestsDeterminedByTalking)

        NPC_ID = NPC_ID + 1 -- We want to make sure `lastNpcGuid` is different between tests
        for i = 1, MAX_NUM_QUESTS do
            _G["QuestTitleButton" .. i] = nil
        end
    end)

    after_each(function()
        ThreadLib.Thread = originalThread
        ThreadLib.ThreadCallbackInstant = originalThreadCallbackInstant
        QuestiePlayer.GetPlayerLevel = originalGetPlayerLevel
        QuestieDB.QuestPointers = originalQuestPointers
        IsleOfQuelDanas.quests = originalIsleOfQuelDanasQuests
        _G.GetQuestGreenRange = originalGetQuestGreenRange
        QuestieMap.questIdFrames = originalQuestIdFrames
    end)

    describe("Initialize", function()
        it("should correct initialize", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            Questie.db.global.unavailableQuestsDeterminedByTalking = {}
            Questie.db.global.unavailableDailyQuestsByNpc = {}

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
            assert.are_same({["Ook Ook"] = {}}, Questie.db.global.unavailableDailyQuestsByNpc)
        end)

        it("should reset unavailableQuestsDeterminedByTalking when a daily reset happened", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            QuestieLib.DidDailyResetHappenSinceLastLogin = function() return true end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[1234] = true},
            }
            Questie.db.global.unavailableDailyQuestsByNpc = {
                ["Ook Ook"] = {[9999] = {[1234] = true}},
            }

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
            assert.are_same({["Ook Ook"] = {}}, Questie.db.global.unavailableDailyQuestsByNpc)
        end)

        it("should not reset unavailableQuestsDeterminedByTalking when no daily reset happened", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            QuestieLib.DidDailyResetHappenSinceLastLogin = function() return false end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[1234] = true},
            }
            Questie.db.global.unavailableDailyQuestsByNpc = {
                ["Ook Ook"] = {[9999] = {[1234] = true}},
            }

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {[1234] = true}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
            assert.are_same({["Ook Ook"] = {[9999] = {[1234] = true}}}, Questie.db.global.unavailableDailyQuestsByNpc)
        end)
    end)

    describe("GetUnavailableDailyQuests", function()
        it("should return empty table when no quests are unavailable", function()
            local result = AvailableQuests.GetUnavailableDailyQuests()

            assert.are_same({}, result)
        end)

        it("should return quests grouped by NPC as arrays", function()
            AvailableQuests.__unavailableDailyQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            local result = AvailableQuests.GetUnavailableDailyQuests()

            assert.are_same({[NPC_ID] = {QUEST_ID}}, result)
        end)

        it("should return multiple quests per NPC as an array", function()
            local questId2 = QUEST_ID + 1
            AvailableQuests.__unavailableDailyQuestsByNpc[NPC_ID] = {[QUEST_ID] = true, [questId2] = true}

            local result = AvailableQuests.GetUnavailableDailyQuests()

            assert.is_not_nil(result[NPC_ID])
            assert.are_equal(2, #result[NPC_ID])
            assert.is_true(result[NPC_ID][1] == QUEST_ID or result[NPC_ID][1] == questId2)
            assert.is_true(result[NPC_ID][2] == QUEST_ID or result[NPC_ID][2] == questId2)
        end)

        it("should return quests for multiple NPCs", function()
            local npcId2 = NPC_ID + 1
            local questId2 = QUEST_ID + 1
            AvailableQuests.__unavailableDailyQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}
            AvailableQuests.__unavailableDailyQuestsByNpc[npcId2] = {[questId2] = true}

            local result = AvailableQuests.GetUnavailableDailyQuests()

            assert.are_same({[NPC_ID] = {QUEST_ID}}, {[NPC_ID] = result[NPC_ID]})
            assert.are_same({[npcId2] = {questId2}}, {[npcId2] = result[npcId2]})
        end)

        it("should not include NPCs whose quest set is empty", function()
            AvailableQuests.__unavailableDailyQuestsByNpc[NPC_ID] = {}

            local result = AvailableQuests.GetUnavailableDailyQuests()

            assert.are_same({}, result)
        end)
    end)

    describe("ClearUnavailableDailyQuests", function()
        it("should clear unavailable quest tables for the current realm", function()
            local realmName = "TestRealm"
            _G.GetRealmName = function() return realmName end
            Questie.db.global.unavailableQuestsDeterminedByTalking[realmName] = {[QUEST_ID] = true}
            Questie.db.global.unavailableDailyQuestsByNpc[realmName] = {[NPC_ID] = {[QUEST_ID] = true}}

            AvailableQuests.ClearUnavailableDailyQuests()

            assert.are_same({}, Questie.db.global.unavailableQuestsDeterminedByTalking[realmName])
            assert.are_same({}, Questie.db.global.unavailableDailyQuestsByNpc[realmName])
            assert.are_same({}, AvailableQuests.__unavailableQuestsDeterminedByTalking)
            assert.are_same({}, AvailableQuests.__unavailableDailyQuestsByNpc)
        end)
    end)

    describe("_ScheduleDailyResetTimer (via Initialize)", function()
        it("should schedule a timer when not Questie.IsClassic", function()
            local realmName = "TestRealm"
            _G.GetRealmName = function() return realmName end
            _G.GetServerTime = function() return 1000 end
            _G.GetQuestResetTime = function() return 86400 end
            _G.C_Timer = {After = spy.new(function() end)}
            Questie.IsClassic = false
            Questie.db.global.lastKnownDailyReset[realmName] = 90000

            AvailableQuests.Initialize()

            assert.spy(_G.C_Timer.After).was.called()
        end)

        it("should not schedule a timer when Questie.IsClassic is true", function()
            local realmName = "TestRealm"
            _G.GetRealmName = function() return realmName end
            _G.GetServerTime = function() return 1000 end
            _G.GetQuestResetTime = function() return 86400 end
            _G.C_Timer = {After = spy.new(function() end)}
            Questie.IsClassic = true
            Questie.db.global.lastKnownDailyReset[realmName] = 90000

            AvailableQuests.Initialize()

            assert.spy(_G.C_Timer.After).was.not_called()
        end)

        it("should calculate correct delay when reset is in future", function()
            local realmName = "TestRealm"
            local now = 1000
            local resetTime = now + 86400
            _G.GetRealmName = function() return realmName end
            _G.GetServerTime = function() return now end
            _G.GetQuestResetTime = function() return 86400 end
            local afterMock = spy.new(function() end)
            _G.C_Timer = {After = afterMock}
            Questie.IsClassic = false
            Questie.db.global.lastKnownDailyReset[realmName] = resetTime

            AvailableQuests.Initialize()

            -- Delay should be (resetTime - now + 5) = 86400 + 5 = 86405
            assert.spy(afterMock).was.called_with(86405, match.is_function())
        end)

        it("should use delay of 1 when reset time has already passed", function()
            local realmName = "TestRealm"
            _G.GetRealmName = function() return realmName end
            _G.GetServerTime = function() return 2000 end
            _G.GetQuestResetTime = function() return 86400 end
            local afterMock = spy.new(function() end)
            _G.C_Timer = {After = afterMock}
            Questie.IsClassic = false
            Questie.db.global.lastKnownDailyReset[realmName] = 1000 -- Already passed

            AvailableQuests.Initialize()

            assert.spy(afterMock).was.called_with(1, match.is_function())
        end)

        it("should schedule timer with GetQuestResetTime delay when lastKnownDailyReset is not set", function()
            local realmName = "TestRealm"
            _G.GetRealmName = function() return realmName end
            _G.GetServerTime = function() return 1000 end
            _G.GetQuestResetTime = function() return 86400 end
            local afterMock = spy.new(function() end)
            _G.C_Timer = {After = afterMock}
            Questie.IsClassic = false
            Questie.db.global.lastKnownDailyReset = {[realmName] = nil}

            AvailableQuests.Initialize()

            -- Delay should be GetQuestResetTime() + 5 = 86400 + 5 = 86405
            assert.spy(afterMock).was.called_with(86405, match.is_function())
        end)

        it("timer callback should clear unavailable quests and reschedule", function()
            local realmName = "TestRealm"
            _G.GetRealmName = function() return realmName end
            _G.GetServerTime = function() return 1000 end
            _G.GetQuestResetTime = function() return 86400 end
            Questie.IsClassic = false
            Questie.db.global.lastKnownDailyReset[realmName] = 90000
            Questie.db.global.unavailableQuestsDeterminedByTalking[realmName] = {[QUEST_ID] = true}
            Questie.db.global.unavailableDailyQuestsByNpc[realmName] = {[NPC_ID] = {[QUEST_ID] = true}}
            QuestieLib.UpdateLastKnownDailyReset = spy.new(function() end)
            AvailableQuests.CalculateAndDrawAll = spy.new(function() end)
            QuestieDB.QuestPointers = {}

            local capturedCallback
            _G.C_Timer = {
                After = spy.new(function(_, callback)
                    capturedCallback = callback
                end)
            }

            AvailableQuests.Initialize()

            assert.is_not_nil(capturedCallback)
            capturedCallback()

            assert.are_same({}, Questie.db.global.unavailableQuestsDeterminedByTalking[realmName])
            assert.are_same({}, Questie.db.global.unavailableDailyQuestsByNpc[realmName])
            assert.spy(QuestieLib.UpdateLastKnownDailyReset).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called()
        end)

        it("timer callback should not calculate available quests before composed Quest IDs are bound", function()
            local realmName = "TestRealm"
            _G.GetRealmName = function() return realmName end
            _G.GetServerTime = function() return 1000 end
            _G.GetQuestResetTime = function() return 86400 end
            Questie.IsClassic = false
            Questie.db.global.lastKnownDailyReset[realmName] = 90000
            QuestieLib.UpdateLastKnownDailyReset = spy.new(function() end)
            AvailableQuests.CalculateAndDrawAll = spy.new(function() end)
            QuestieDB.QuestPointers = nil

            local capturedCallback
            _G.C_Timer = {
                After = spy.new(function(_, callback)
                    capturedCallback = callback
                end)
            }

            AvailableQuests.Initialize()

            assert.is_not_nil(capturedCallback)
            capturedCallback()

            assert.spy(QuestieLib.UpdateLastKnownDailyReset).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
        end)
    end)

    describe("CalculateAndDrawAll", function()
        it("should name its calculation and draw jobs for profiling", function()
            local submittedJobs = {}
            ThreadLib.Thread = function(threadFunction, delay, errorMessage, callbackFunction, errorCallback, threadName)
                table.insert(submittedJobs, {
                    threadFunction = threadFunction,
                    delay = delay,
                    errorMessage = errorMessage,
                    callbackFunction = callbackFunction,
                    errorCallback = errorCallback,
                    threadName = threadName,
                })
                return {Cancel = function() end}
            end
            QuestieDB.QuestPointers = {}
            QuestiePlayer.GetPlayerLevel = function() return 60 end
            IsleOfQuelDanas.quests = {}
            QuestieMap.questIdFrames = {}
            AvailableQuests.__availableQuests[QUEST_ID] = true

            AvailableQuests.CalculateAndDrawAll()
            submittedJobs[1].threadFunction()

            assert.are_same("AvailableQuests.CalculateAndDrawAll", submittedJobs[1].threadName)
            assert.are_same("_DrawAvailableQuest", submittedJobs[2].threadName)
        end)
    end)

    describe("DrawAvailableQuest", function()
        it("should add a quest started by an NPC", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = spy.new(function() return {id = NPC_ID, name = "Test NPC"} end)
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = QUEST_ID,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)

            assert.spy(QuestieDB.GetNPC).was.called_with(QuestieDB, NPC_ID)
            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, QUEST_ID, "Test NPC", NPC_ID, "m_" .. NPC_ID, "NPC")
        end)
    end)

    describe("ValidateAvailableQuestsFromGossipShow", function()
        it("should hide daily quests that are not available", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, QUEST_ID)
            assert.is_nil(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_nil(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])

            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.called_with(NPC_ID, {QUEST_ID})
        end)

        it("should hide weekly quests that are not available", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsWeeklyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, QUEST_ID)
            assert.is_nil(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_nil(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])

            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.called_with(NPC_ID, {QUEST_ID})
        end)

        it("should not hide available quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {{questID = QUEST_ID}} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide active quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {{questID = QUEST_ID}} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide unavailable one-time quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return false end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide any quest when re-talking to the same NPC", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {{questID = QUEST_ID}} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])

            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.not_called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should re-show quests that are incorrectly marked as unavailable", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.GetQuest = function() return {Id = QUEST_ID, Starts = {NPC = {NPC_ID}}} end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {{questID = QUEST_ID}} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID] = true

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, QUEST_ID, "Test NPC", NPC_ID, "m_" .. NPC_ID, "NPC")
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should handle talking to an NPC without available quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called()
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called()
            assert.are_same(AvailableQuests.__availableQuests, {})
            assert.are_same(AvailableQuests.__availableQuestsByNpc, {})
            assert.are_same(AvailableQuests.__unavailableQuestsDeterminedByTalking, {})
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide blacklisted daily quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            DailyQuestCommsBlacklist.IsBlacklisted = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
        end)

        it("should not hide daily quests outside the player's level range", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            QuestiePlayer.GetPlayerLevel = function() return 20 end
            QuestieLib.GetEffectiveQuestLevel = function() return 60, 60, 0 end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide daily quests the player's level exceeds the maximum allowed level", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            QuestiePlayer.GetPlayerLevel = function() return 40 end
            QuestieLib.GetEffectiveQuestLevel = function() return 1, 1, 30 end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromGossipShow()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)
    end)

    describe("ValidateAvailableQuestsFromQuestDetail", function()
        it("should hide daily quests that are not available", function()
            local availableQuest = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local unavailableQuest = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            _G.GetQuestID = function() return availableQuest end
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            AvailableQuests.__availableQuests[availableQuest] = true
            AvailableQuests.__availableQuests[unavailableQuest] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[availableQuest] = true, [unavailableQuest] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, unavailableQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, unavailableQuest)
            assert.is_nil(AvailableQuests.__availableQuests[unavailableQuest])
            assert.is_nil(AvailableQuests.__availableQuestsByNpc[NPC_ID][unavailableQuest])
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[unavailableQuest])

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, availableQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, availableQuest)
            assert.is_true(AvailableQuests.__availableQuests[availableQuest])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][availableQuest])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[availableQuest])

            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.called_with(NPC_ID, {unavailableQuest})
        end)

        it("should hide weekly quests that are not available", function()
            local availableQuest = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local unavailableQuest = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsWeeklyQuest = function() return true end
            _G.GetQuestID = function() return availableQuest end
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            AvailableQuests.__availableQuests[availableQuest] = true
            AvailableQuests.__availableQuests[unavailableQuest] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[availableQuest] = true, [unavailableQuest] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, unavailableQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, unavailableQuest)
            assert.is_nil(AvailableQuests.__availableQuests[unavailableQuest])
            assert.is_nil(AvailableQuests.__availableQuestsByNpc[NPC_ID][unavailableQuest])
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[unavailableQuest])

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, availableQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, availableQuest)
            assert.is_true(AvailableQuests.__availableQuests[availableQuest])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][availableQuest])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[availableQuest])

            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.called_with(NPC_ID, {unavailableQuest})
        end)

        it("should not hide unavailable one-time quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return false end
            _G.GetQuestID = function() return QUEST_ID + 1 end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)

            AvailableQuests.ValidateAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide any quest when dialog was closed", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            _G.GetQuestID = spy.new(function() return 0 end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)

            AvailableQuests.ValidateAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should re-show quests that are incorrectly marked as unavailable", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            _G.GetQuestID = function() return QUEST_ID end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.GetQuest = function() return {Id = QUEST_ID, Starts = {NPC = {NPC_ID}}} end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID] = true

            AvailableQuests.ValidateAvailableQuestsFromQuestDetail()

            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, QUEST_ID, "Test NPC", NPC_ID, "m_" .. NPC_ID, "NPC")
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should handle talking to an NPC without available quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            _G.GetQuestID = function() return QUEST_ID end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)

            AvailableQuests.ValidateAvailableQuestsFromQuestDetail()

            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called()
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called()
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide blacklisted daily quests", function()
            local availableQuest = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local blacklistedQuest = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            _G.GetQuestID = function() return availableQuest end
            DailyQuestCommsBlacklist.IsBlacklisted = function(questId) return questId == blacklistedQuest end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[availableQuest] = true
            AvailableQuests.__availableQuests[blacklistedQuest] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[availableQuest] = true, [blacklistedQuest] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, blacklistedQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, blacklistedQuest)
            assert.is_true(AvailableQuests.__availableQuests[blacklistedQuest])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][blacklistedQuest])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[blacklistedQuest])
        end)

        it("should not hide daily quests outside the player's level range", function()
            local availableQuest = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local outOfLevelQuest = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.IsDailyQuest = function() return true end
            _G.GetQuestID = function() return availableQuest end
            QuestiePlayer.GetPlayerLevel = function() return 20 end
            QuestieLib.GetEffectiveQuestLevel = function(questId)
                if questId == outOfLevelQuest then return 60, 60, 0 end
                return 1, 1, 0
            end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[availableQuest] = true
            AvailableQuests.__availableQuests[outOfLevelQuest] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[availableQuest] = true, [outOfLevelQuest] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, outOfLevelQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, outOfLevelQuest)
            assert.is_true(AvailableQuests.__availableQuests[outOfLevelQuest])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][outOfLevelQuest])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[outOfLevelQuest])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)
    end)

    describe("ValidateAvailableQuestsFromQuestGreeting", function()
        it("should hide daily quests that are not available", function()
            local availableQuestId = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local unavailableQuestId = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetQuestIDFromName = spy.new(function() return availableQuestId end)
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 0,
                GetID = function() return 1 end,
            }
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            _G.GetAvailableTitle = spy.new(function() return "Available Quest" end)
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            AvailableQuests.__availableQuests[availableQuestId] = true
            AvailableQuests.__availableQuests[unavailableQuestId] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[availableQuestId] = true, [unavailableQuestId] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(_G.GetAvailableTitle).was.called_with(1)
            assert.spy(QuestieDB.GetQuestIDFromName).was.called_with("Available Quest", "Creature-0-0-0-0-" .. NPC_ID .. "-0", true)
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, availableQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, availableQuestId)
            assert.is_true(AvailableQuests.__availableQuests[availableQuestId])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][availableQuestId])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[availableQuestId])

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, unavailableQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, unavailableQuestId)
            assert.is_nil(AvailableQuests.__availableQuests[unavailableQuestId])
            assert.is_nil(AvailableQuests.__availableQuestsByNpc[NPC_ID][unavailableQuestId])
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[unavailableQuestId])

            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.called_with(NPC_ID, {unavailableQuestId})
        end)

        it("should hide weekly quests that are not available", function()
            local availableQuestId = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local unavailableQuestId = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetQuestIDFromName = spy.new(function() return availableQuestId end)
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 0,
                GetID = function() return 1 end,
            }
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            _G.GetAvailableTitle = spy.new(function() return "Available Quest" end)
            QuestieDB.IsWeeklyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            AvailableQuests.__availableQuests[availableQuestId] = true
            AvailableQuests.__availableQuests[unavailableQuestId] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[availableQuestId] = true, [unavailableQuestId] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(_G.GetAvailableTitle).was.called_with(1)
            assert.spy(QuestieDB.GetQuestIDFromName).was.called_with("Available Quest", "Creature-0-0-0-0-" .. NPC_ID .. "-0", true)
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, availableQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, availableQuestId)
            assert.is_true(AvailableQuests.__availableQuests[availableQuestId])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][availableQuestId])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[availableQuestId])

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, unavailableQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, unavailableQuestId)
            assert.is_nil(AvailableQuests.__availableQuests[unavailableQuestId])
            assert.is_nil(AvailableQuests.__availableQuestsByNpc[NPC_ID][unavailableQuestId])
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[unavailableQuestId])

            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.called_with(NPC_ID, {unavailableQuestId})
        end)

        it("should not hide one-time quests that are not available", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function() return false end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide active quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetQuestIDFromName = spy.new(function() return QUEST_ID end)
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 1,
                GetID = function() return 1 end,
            }
            _G.GetActiveTitle = spy.new(function() return "Active Quest" end)
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide quests when a visible quest title cannot be resolved to an ID", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetQuestIDFromName = spy.new(function() return 0 end)
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 0,
                GetID = function() return 1 end,
            }
            _G.GetAvailableTitle = spy.new(function() return "Unknown Quest" end)
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieDB.GetQuestIDFromName).was.called_with("Unknown Quest", "Creature-0-0-0-0-" .. NPC_ID .. "-0", true)
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should re-show quests that are incorrectly marked as unavailable", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.GetQuestIDFromName = function() return QUEST_ID end
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 0,
                GetID = function() return 1 end,
            }
            _G.GetAvailableTitle = function() return "Available Quest" end
            QuestieDB.GetQuest = function() return {Id = QUEST_ID, Starts = {NPC = {NPC_ID}}} end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID] = true

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, QUEST_ID, "Test NPC", NPC_ID, "m_" .. NPC_ID, "NPC")
            assert.is_true(AvailableQuests.__availableQuests[QUEST_ID])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][QUEST_ID])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should handle talking to an NPC without available quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            _G.GetAvailableTitle = spy.new(function() end)
            QuestieDB.GetQuestIDFromName = spy.new(function() end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(_G.GetAvailableTitle).was.not_called()
            assert.spy(QuestieDB.GetQuestIDFromName).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called()
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called()
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)

        it("should not hide blacklisted daily quests", function()
            local availableQuestId = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local blacklistedQuestId = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetQuestIDFromName = spy.new(function() return availableQuestId end)
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 0,
                GetID = function() return 1 end,
            }
            _G.GetAvailableTitle = spy.new(function() return "Available Quest" end)
            QuestieDB.IsDailyQuest = function() return true end
            DailyQuestCommsBlacklist.IsBlacklisted = function(questId) return questId == blacklistedQuestId end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[availableQuestId] = true
            AvailableQuests.__availableQuests[blacklistedQuestId] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[availableQuestId] = true, [blacklistedQuestId] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, blacklistedQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, blacklistedQuestId)
            assert.is_true(AvailableQuests.__availableQuests[blacklistedQuestId])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][blacklistedQuestId])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[blacklistedQuestId])
        end)

        it("should not hide daily quests outside the player's level range", function()
            local availableQuestId = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local outOfLevelQuestId = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetQuestIDFromName = spy.new(function() return availableQuestId end)
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 0,
                GetID = function() return 1 end,
            }
            _G.GetAvailableTitle = spy.new(function() return "Available Quest" end)
            QuestieDB.IsDailyQuest = function() return true end
            QuestiePlayer.GetPlayerLevel = function() return 20 end
            QuestieLib.GetEffectiveQuestLevel = function(questId)
                if questId == outOfLevelQuestId then return 60, 60, 0 end
                return 1, 1, 0
            end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[availableQuestId] = true
            AvailableQuests.__availableQuests[outOfLevelQuestId] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[availableQuestId] = true, [outOfLevelQuestId] = true}

            AvailableQuests.ValidateAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, outOfLevelQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, outOfLevelQuestId)
            assert.is_true(AvailableQuests.__availableQuests[outOfLevelQuestId])
            assert.is_true(AvailableQuests.__availableQuestsByNpc[NPC_ID][outOfLevelQuestId])
            assert.is_nil(AvailableQuests.__unavailableQuestsDeterminedByTalking[outOfLevelQuestId])
            assert.spy(DailyQuestComms.BroadcastUnavailableDailyQuests).was.not_called()
        end)
    end)

    describe("RecreateFailedQuest", function()
        it("should reset lastNpcGuid so the same NPC can be validated again", function()
            local npcGuid = "Creature-0-0-0-0-" .. NPC_ID .. "-0"
            _G.UnitGUID = function() return npcGuid end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            DailyQuestComms.BroadcastUnavailableDailyQuests = spy.new(function() end)
            AvailableQuests.__availableQuests[QUEST_ID] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}

            -- First validation caches lastNpcGuid
            AvailableQuests.ValidateAvailableQuestsFromGossipShow()
            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called(1)

            -- RecreateFailedQuest should reset lastNpcGuid
            ---@diagnostic disable-next-line: missing-fields
            AvailableQuests.RecreateFailedQuest({Id = QUEST_ID, Starts = {}})

            -- Second validation with the same NPC GUID should now run again
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[QUEST_ID] = true}
            AvailableQuests.ValidateAvailableQuestsFromGossipShow()
            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called(2)
        end)
    end)

    describe("RemoveQuestsForToday", function()
        it("should remove quests", function()
            local firstQuest = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local secondQuest = QUEST_ID
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)
            AvailableQuests.__availableQuests[firstQuest] = true
            AvailableQuests.__availableQuests[secondQuest] = true
            AvailableQuests.__availableQuestsByNpc[NPC_ID] = {[firstQuest] = true, [secondQuest] = true}

            AvailableQuests.RemoveQuestsForToday(NPC_ID, {firstQuest, secondQuest})

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, firstQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, firstQuest)
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, secondQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, secondQuest)
            assert.is_nil(AvailableQuests.__availableQuests[firstQuest])
            assert.is_nil(AvailableQuests.__availableQuests[secondQuest])
            assert.is_nil(AvailableQuests.__availableQuestsByNpc[NPC_ID][firstQuest])
            assert.is_nil(AvailableQuests.__availableQuestsByNpc[NPC_ID][secondQuest])
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[firstQuest])
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[secondQuest])
        end)

        it("should mark quests as unavailable even when they are not yet available", function()
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            AvailableQuests.RemoveQuestsForToday(NPC_ID, {QUEST_ID})

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
            assert.are_same(AvailableQuests.__availableQuests, {})
            assert.are_same(AvailableQuests.__availableQuestsByNpc, {})
            assert.is_true(AvailableQuests.__unavailableQuestsDeterminedByTalking[QUEST_ID])
        end)
    end)

    describe("CalculateAndDrawAll", function()
        it("should start a pass immediately when none is running", function()
            local passCount = 0
            ThreadLib.Thread = function()
                passCount = passCount + 1
            end

            AvailableQuests.CalculateAndDrawAll()

            assert.are_equal(1, passCount)
        end)

        it("should queue a second call instead of starting a new pass while one is running", function()
            local passCount = 0
            ThreadLib.Thread = function()
                passCount = passCount + 1
            end

            AvailableQuests.CalculateAndDrawAll()
            AvailableQuests.CalculateAndDrawAll()
            AvailableQuests.CalculateAndDrawAll()

            -- Only one pass started; the other two are coalesced into a single queued follow-up
            assert.are_equal(1, passCount)
            local _, queued = AvailableQuests.__getPassState()
            assert.is_true(queued)
        end)

        it("should start the queued pass once the running pass completes", function()
            local passCount = 0
            local firstCallback

            -- First call: capture callback without running the body
            ThreadLib.Thread = function(_, _, _, cb)
                passCount = passCount + 1
                firstCallback = cb
            end
            AvailableQuests.CalculateAndDrawAll()

            -- Second call while first is in flight — should queue, not start
            AvailableQuests.CalculateAndDrawAll()
            assert.are_equal(1, passCount)

            -- Complete the first pass — the queued pass should auto-start
            firstCallback()

            -- The queued pass was consumed (no longer queued) and a new pass has started
            assert.are_equal(2, passCount)
            local _, queued = AvailableQuests.__getPassState()
            assert.is_false(queued)
        end)

        it("should fire a callback after the pass it was registered with completes", function()
            local result = 0
            local firstCallback

            ThreadLib.Thread = function(_, _, _, cb)
                firstCallback = cb
            end

            AvailableQuests.CalculateAndDrawAll(function() result = result + 1 end)

            -- Callback has not fired yet (pass still running)
            assert.are_equal(0, result)

            firstCallback()

            assert.are_equal(1, result)
        end)

        it("should fire callbacks from concurrent calls each after their respective pass", function()
            local results = {}
            local firstCallback, secondCallback

            ThreadLib.Thread = function(_, _, _, cb)
                if (not firstCallback) then
                    firstCallback = cb
                else
                    secondCallback = cb
                end
            end

            -- Both calls arrive while no pass is running — first starts immediately, second queues
            AvailableQuests.CalculateAndDrawAll(function() results[#results + 1] = "first" end)
            AvailableQuests.CalculateAndDrawAll(function() results[#results + 1] = "second" end)

            assert.are_equal(0, #results)

            -- Complete the first pass; the queued pass starts and "first" callback fires
            firstCallback()
            assert.are_same({"first"}, results)

            -- Complete the second pass; "second" callback fires
            secondCallback()
            assert.are_same({"first", "second"}, results)
        end)

        it("should reset passRunning when the pass coroutine errors", function()
            local capturedErrorCallback
            ThreadLib.Thread = function(_, _, _, _, errorCb)
                capturedErrorCallback = errorCb
            end

            AvailableQuests.CalculateAndDrawAll()

            local running = AvailableQuests.__getPassState()
            assert.is_true(running)

            capturedErrorCallback()

            running = AvailableQuests.__getPassState()
            assert.is_false(running)
        end)

        it("should start queued pass after a coroutine error", function()
            local passCount = 0
            local capturedErrorCallback

            ThreadLib.Thread = function(_, _, _, _, errorCb)
                passCount = passCount + 1
                capturedErrorCallback = errorCb
            end

            AvailableQuests.CalculateAndDrawAll()
            AvailableQuests.CalculateAndDrawAll() -- queued

            assert.are_equal(1, passCount)

            capturedErrorCallback() -- first pass errors; queued pass should start

            assert.are_equal(2, passCount)
            local _, queued = AvailableQuests.__getPassState()
            assert.is_false(queued)
        end)

        it("should not fire pending callbacks when the pass errors", function()
            local callbackFired = false
            local capturedErrorCallback

            ThreadLib.Thread = function(_, _, _, _, errorCb)
                capturedErrorCallback = errorCb
            end

            AvailableQuests.CalculateAndDrawAll(function() callbackFired = true end)

            capturedErrorCallback()

            assert.is_false(callbackFired)
        end)

        it("should handle callback errors without breaking pass cleanup", function()
            local successCallback = spy.new(function() error("callback error") end)
            local capturedSuccessCallback

            Questie.Error = spy.new(function() end)

            ThreadLib.Thread = function(_, _, _, cb)
                capturedSuccessCallback = cb
            end

            AvailableQuests.CalculateAndDrawAll(successCallback)

            capturedSuccessCallback()

            -- Callback was called despite the error
            assert.spy(successCallback).was.called()
            assert.spy(Questie.Error).was.called()

            local running = AvailableQuests.__getPassState()
            assert.is_false(running)
        end)

        it("should start queued pass even if callback errors", function()
            local passCount = 0

            Questie.Error = function() end

            ThreadLib.Thread = function(_, _, _, cb)
                passCount = passCount + 1
                if passCount == 1 then
                    cb() -- first pass completes, callback errors
                end
            end

            AvailableQuests.CalculateAndDrawAll(function() error("callback error") end)
            AvailableQuests.CalculateAndDrawAll() -- queued

            assert.are_equal(2, passCount)
        end)
    end)
    describe("composed Quest enumeration", function()
        local originalIsClassic
        local originalIsSoD
        local submittedJobs

        before_each(function()
            originalIsClassic = Questie.IsClassic
            originalIsSoD = Questie.IsSoD

            -- The availability pass captures these at load, so this describe loads AvailableQuests again.
            QuestieDB.IsDoable = function() return true end
            QuestieDB.IsComplete = function() return 0 end
            QuestieLoader:ImportModule("AvailableQuests").IsLevelRequirementsFulfilled = function() return true end
            dofile("Modules/Quest/AvailableQuests/AvailableQuests.lua")
            AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
            AvailableQuests.Initialize()
            TestUtils.clearTable(AvailableQuests.__availableQuests)
            TestUtils.clearTable(AvailableQuests.__availableQuestsByNpc)
            TestUtils.clearTable(AvailableQuests.__unavailableQuestsDeterminedByTalking)

            local mock = LoadQuestieTDBMock()
            local questKeys = mock.lib.Meta.QuestMeta.questKeys
            mock.SetBaseRow("Quest", 2, {[questKeys.name] = "Sharptalon's Claw"})
            mock.SetBaseRow("Quest", 3, {[questKeys.name] = "Webwood Venom"})
            mock.SetBaseRow("Quest", 4, {[questKeys.name] = "Already Complete"})
            mock.SetBaseRow("Quest", 5, {[questKeys.name] = "Blacklisted"})
            QuestieDB.QuestPointers = mock.lib.Quest.GetAllIds(true)
            QuestieDB.autoBlacklist = {}
            QuestieDB.IsRepeatable = function() return false end
            QuestieDB.IsPvPQuest = function() return false end
            QuestieDB.IsDungeonQuest = function() return false end
            QuestieDB.IsRaidQuest = function() return false end
            QuestieLoader:ImportModule("QuestieCorrections").hiddenQuests = {[5] = true}
            QuestieLoader:ImportModule("QuestieQuestBlacklist").AQWarEffortQuests = {}
            Questie.db.char.complete = {[4] = true}
            Questie.db.char.hidden = {}
            Questie.IsClassic = false
            Questie.IsSoD = false
            IsleOfQuelDanas.quests = {}
            QuestiePlayer.currentQuestlog = {}
            QuestiePlayer.GetPlayerLevel = function() return 60 end
            QuestieMap.questIdFrames = {}

            submittedJobs = {}
            ThreadLib.Thread = function(threadFunction, _, _, _, _, threadName)
                table.insert(submittedJobs, {threadFunction = threadFunction, threadName = threadName})
                return {Cancel = function() end}
            end
        end)

        after_each(function()
            Questie.IsClassic = originalIsClassic
            Questie.IsSoD = originalIsSoD
        end)

        it("marks every doable Quest from the provider-backed QuestPointers as available", function()
            AvailableQuests.CalculateAndDrawAll()
            -- The first job is the calculation pass; it submits one draw job per available quest.
            assert.are_same("AvailableQuests.CalculateAndDrawAll", submittedJobs[1].threadName)
            submittedJobs[1].threadFunction()

            assert.are_same({[2] = true, [3] = true}, AvailableQuests.__availableQuests)
            assert.are_same("_DrawAvailableQuest", submittedJobs[2].threadName)
            assert.are_same("_DrawAvailableQuest", submittedJobs[3].threadName)
            assert.is_nil(submittedJobs[4])
        end)
    end)
end)
