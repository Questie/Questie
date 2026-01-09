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

    local NPC_ID = 456

    before_each(function()
        ZoneDB = require("Database.Zones.zoneDB")
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieDB = require("Database.QuestieDB")
        QuestieTooltips = require("Modules.Tooltips.Tooltip")
        QuestieMap = require("Modules.Map.QuestieMap")

        Questie.db.profile.availableIconLimit = 10

        AvailableQuests = require("Modules.Quest.AvailableQuests.AvailableQuests")

        NPC_ID = NPC_ID + 1 -- We want to make sure `lastNpcGuid` is different between tests
    end)

    describe("Initialize", function()
        it("should correct initialize", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            QuestieDB.IsDailyQuest = function() return true end
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
            local questId = 123
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = spy.new(function() return {id = NPC_ID, name = "Test NPC"} end)
            QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = questId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)

            assert.spy(QuestieDB.GetNPC).was.called_with(QuestieDB, NPC_ID)
            assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was.called_with(QuestieTooltips, questId, "Test NPC", NPC_ID, "m_" .. NPC_ID)
        end)
    end)

    describe("HideNotAvailableQuestsFromNPC", function()
        it("should hide quests that are not available", function()
            local questId = 123
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
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
                Id = questId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromNPC(true)

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, questId)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, questId)
        end)

        it("should not hide available quests", function()
            local questId = 123
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
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
                Id = questId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromNPC(true)

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, questId)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, questId)
        end)

        it("should not hide active quests", function()
            local availableQuestId = 123
            local activeQuestId = 789
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
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
            AvailableQuests.HideNotAvailableQuestsFromNPC(true)

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.called_with(QuestieMap, availableQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, availableQuestId)
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, activeQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, activeQuestId)
        end)

        it("should not hide unavailable one-time quests", function()
            local questId = 123
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
                Id = questId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromNPC(true)

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, questId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, questId)
        end)

        it("should not hide any quest when re-talking to the same NPC", function()
            local questId = 123
            local npcId = 111
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. npcId .. "-0" end
            QuestieDB.GetNPC = function() return {id = npcId, name = "Test NPC"} end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {{questID = questId}} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = questId,
                Starts = {NPC = {npcId}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromNPC(true)

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, questId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, questId)

            _G.QuestieCompat = {
                GetAvailableQuests = spy.new(function() return {} end),
                GetActiveQuests = spy.new(function() return {} end),
            }
            AvailableQuests.HideNotAvailableQuestsFromNPC(true)

            assert.spy(_G.QuestieCompat.GetAvailableQuests).was.not_called()
            assert.spy(_G.QuestieCompat.GetActiveQuests).was.not_called()
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, questId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, questId)
        end)

        it("should not hide unavailable one-time quests", function()
            local oneTimeQuestId = 123
            local dailyQuestId = 789
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
            AvailableQuests.HideNotAvailableQuestsFromNPC(false)

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, oneTimeQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, oneTimeQuestId)
            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, dailyQuestId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, dailyQuestId)
        end)

        it("should not hide any quest when dialog was closed", function()
            local questId = 123
            _G.UnitGUID = function() return "Creature-0-0-0-0-" .. NPC_ID .. "-0" end
            QuestieDB.GetNPC = function() return {id = NPC_ID, name = "Test NPC"} end
            QuestieTooltips.RegisterQuestStartTooltip = function() end
            _G.GetQuestID = spy.new(function() return 0 end)
            QuestieTooltips.RemoveQuest = spy.new(function() end)
            QuestieMap.UnloadQuestFrames = spy.new(function() end)

            ---@type Quest
            ---@diagnostic disable-next-line: missing-fields
            local quest = {
                Id = questId,
                Starts = {NPC = {NPC_ID}}
            }

            AvailableQuests.DrawAvailableQuest(quest)
            AvailableQuests.HideNotAvailableQuestsFromNPC(false)

            assert.spy(QuestieMap.UnloadQuestFrames).was.not_called_with(QuestieMap, questId)
            assert.spy(QuestieTooltips.RemoveQuest).was.not_called_with(QuestieTooltips, questId)
        end)
    end)
end)
