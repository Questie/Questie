dofile("setupTests.lua")

describe("AvailableQuests", function()
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieTooltips
    local QuestieTooltips
    ---@type QuestieMap
    local QuestieMap

    ---@type AvailableQuests
    local AvailableQuests

    local QUEST_ID = 123
    local NPC_ID = 456

    before_each(function()
        ZoneDB = require("Database.Zones.zoneDB")
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieDB = require("Database.QuestieDB")
        QuestieDB.GetNPC = function() return nil end
        QuestieDB.GetQuest = function() return nil end
        QuestieDB.IsDailyQuest = function() return false end
        QuestieTooltips = require("Modules.Tooltips.Tooltip")
        QuestieMap = require("Modules.Map.QuestieMap")

        Questie.db.profile.availableIconLimit = 10

        AvailableQuests = require("Modules.Quest.AvailableQuests.AvailableQuests")

        QUEST_ID = QUEST_ID + 1 -- We want to make sure each test uses a different quest ID
        NPC_ID = NPC_ID + 1 -- We want to make sure `lastNpcGuid` is different between tests
        for i = 1, MAX_NUM_QUESTS do
            _G["QuestTitleButton" .. i] = nil
        end
    end)

    describe("Initialize", function()
        it("should correct initialize", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            Questie.db.global.unavailableQuestsDeterminedByTalking = {}

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
        end)

        it("should reset unavailableQuestsDeterminedByTalking when a daily reset happened", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            QuestieLib.DidDailyResetHappenSinceLastLogin = function() return true end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[1234] = true},
            }

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
        end)

        it("should not reset unavailableQuestsDeterminedByTalking when no daily reset happened", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            QuestieLib.DidDailyResetHappenSinceLastLogin = function() return false end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[1234] = true},
            }

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {[1234] = true}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
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
            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, QUEST_ID, "Test NPC", NPC_ID, "m_" .. NPC_ID)
        end)
    end)

    describe("HideNotAvailableQuestsFromGossipShow", function()
        it("should hide quests that are not available", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = QUEST_ID,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, QUEST_ID)
        end)

        it("should not hide available quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {{questID = 789}} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = QUEST_ID,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, QUEST_ID)
        end)

        it("should not hide active quests", function()
            local availableQuestId = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local activeQuestId = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {{questID = activeQuestId}} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = availableQuestId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, availableQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, availableQuestId)
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, activeQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, activeQuestId)
        end)

        it("should not hide unavailable one-time quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function() return false end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {{questID = 789}} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = QUEST_ID,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
        end)

        it("should not hide any quest when re-talking to the same NPC", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {{questID = QUEST_ID}} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = QUEST_ID,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)

            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            AvailableQuests.HideNotAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.not_called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
        end)

        it("should re-show quests that are incorrectly marked as unavailable", function()
            ZoneDB.GetDungeons = function() return {} end
            _G.UnitFactionGroup = function() return "Horde" end
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[QUEST_ID] = true},
            }

            AvailableQuests.Initialize()

            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.GetQuest = function() return {Id = QUEST_ID, Starts = {NPC = {NPC_ID}}} end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {{questID = QUEST_ID}} end),
                GetActiveQuests = spy.new(function() return {} end),
            }

            AvailableQuests.HideNotAvailableQuestsFromGossipShow()

            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, QUEST_ID, "Test NPC", NPC_ID, "m_" .. NPC_ID)
            assert.is_nil(Questie.db.global.unavailableQuestsDeterminedByTalking["Ook Ook"][QUEST_ID])
        end)

        it("should handle talking to an NPC without available quests", function()
            ZoneDB.GetDungeons = function() return {} end
            _G.UnitFactionGroup = function() return "Horde" end
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {}

            AvailableQuests.Initialize()

            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            AvailableQuests.HideNotAvailableQuestsFromGossipShow()

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called()
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called()
        end)
    end)

    describe("HideNotAvailableQuestsFromQuestDetail", function()
        it("should hide quests that are not available", function()
            local availableQuest = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local unavailableQuest = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            _G.GetQuestID = function() return availableQuest end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = availableQuest,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            quest.Id = unavailableQuest
            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, unavailableQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, unavailableQuest)

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, availableQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, availableQuest)
        end)

        it("should not hide unavailable one-time quests", function()
            local oneTimeQuestId = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local dailyQuestId = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function(questId)
                return questId == dailyQuestId
            end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            _G.GetQuestID = function() return dailyQuestId end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = oneTimeQuestId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            quest.Id = dailyQuestId
            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, oneTimeQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, oneTimeQuestId)

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, dailyQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, dailyQuestId)
        end)

        it("should not hide any quest when dialog was closed", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            _G.GetQuestID = spy.new(function() return 0 end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = QUEST_ID,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromQuestDetail()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, QUEST_ID)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, QUEST_ID)
        end)

        it("should re-show quests that are incorrectly marked as unavailable", function()
            ZoneDB.GetDungeons = function() return {} end
            _G.UnitFactionGroup = function() return "Horde" end
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[QUEST_ID] = true},
            }

            AvailableQuests.Initialize()

            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            _G.GetQuestID = function() return QUEST_ID end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.GetQuest = function() return {Id = QUEST_ID, Starts = {NPC = {NPC_ID}}} end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)

            AvailableQuests.HideNotAvailableQuestsFromQuestDetail()

            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, QUEST_ID, "Test NPC", NPC_ID, "m_" .. NPC_ID)
            assert.is_nil(Questie.db.global.unavailableQuestsDeterminedByTalking["Ook Ook"][QUEST_ID])
        end)

        it("should handle talking to an NPC without available quests", function()
            ZoneDB.GetDungeons = function() return {} end
            _G.UnitFactionGroup = function() return "Horde" end
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {}

            AvailableQuests.Initialize()

            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            _G.GetQuestID = function() return QUEST_ID end
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            AvailableQuests.HideNotAvailableQuestsFromQuestDetail()

            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called()
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called()
        end)
    end)

    describe("HideNotAvailableQuestsFromQuestGreeting", function()
        it("should hide quests that are not available", function()
            local availableQuestId = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local unavailableQuestId = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.GetQuestIDFromName = spy.new(function()
                return availableQuestId
            end)
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 0,
                GetID = function() return 1 end,
            }
            _G.GetAvailableTitle = spy.new(function() return "Available Quest" end)
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = availableQuestId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            quest.Id = unavailableQuestId
            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromQuestGreeting()

            assert.spy(_G.GetAvailableTitle).was.called_with(1)
            assert.spy(QuestieDB.GetQuestIDFromName).was.called_with("Available Quest", "Creature-0-0-0-0-" .. NPC_ID .. "-0", true)
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, availableQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, availableQuestId)

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, unavailableQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, unavailableQuestId)
        end)

        it("should not hide one-time quests that are not available", function()
            local dailyQuestId = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local oneTimeQuestId = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.IsDailyQuest = function(questId)
                return questId == dailyQuestId
            end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = dailyQuestId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            quest.Id = oneTimeQuestId
            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, oneTimeQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, oneTimeQuestId)

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, dailyQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, dailyQuestId)
        end)

        it("should not hide active quests", function()
            local nonAvailableQuest = QUEST_ID
            QUEST_ID = QUEST_ID + 1
            local activeQuest = QUEST_ID
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieDB.GetQuestIDFromName = spy.new(function()
                return activeQuest
            end)
            _G.QuestTitleButton1 = {
                IsVisible = function() return true end,
                isActive = 1,
                GetID = function() return 1 end,
            }
            _G.GetActiveTitle = spy.new(function() return "Active Quest" end)
            QuestieDB.IsDailyQuest = function() return true end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = nonAvailableQuest,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            quest.Id = activeQuest
            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, activeQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, activeQuest)

            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, nonAvailableQuest)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, nonAvailableQuest)
        end)

        it("should re-show quests that are incorrectly marked as unavailable", function()
            ZoneDB.GetDungeons = function() return {} end
            _G.UnitFactionGroup = function() return "Horde" end
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[QUEST_ID] = true},
            }

            AvailableQuests.Initialize()

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

            AvailableQuests.HideNotAvailableQuestsFromQuestGreeting()

            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, QUEST_ID, "Test NPC", NPC_ID, "m_" .. NPC_ID)
            assert.is_nil(Questie.db.global.unavailableQuestsDeterminedByTalking["Ook Ook"][QUEST_ID])
        end)

        it("should handle talking to an NPC without available quests", function()
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            _G.GetAvailableTitle = spy.new(function() end)
            QuestieDB.GetQuestIDFromName = spy.new(function() end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            AvailableQuests.HideNotAvailableQuestsFromQuestGreeting()

            assert.spy(_G.GetAvailableTitle).was.not_called()
            assert.spy(QuestieDB.GetQuestIDFromName).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called()
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called()
        end)
    end)
end)
