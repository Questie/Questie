dofile("setupTests.lua")

describe("QuestFinisher", function()

    ---@type QuestieDB
    local QuestieDB
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieTooltips
    local QuestieTooltips
    ---@type QuestieMap
    local QuestieMap

    ---@type QuestFinisher
    local QuestFinisher

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        Questie.db.char.complete = {}
        QuestieDB = require("Database.QuestieDB")
        ZoneDB = require("Database.Zones.zoneDB")
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestieTooltips = require("Modules.Tooltips.Tooltip")
        QuestieMap = require("Modules.Map.QuestieMap")

        _G.C_QuestLog.IsQuestFlaggedCompleted.mockedReturnValue = false
        QuestieTooltips.RegisterQuestStartTooltip = spy.new(function() end)
        QuestieDB.IsActiveEventQuest = function() return false end
        QuestieDB.IsPvPQuest = function() return false end
        ZoneDB.IsDungeonZone = function() return false end
        QuestieMap.DrawWorldIcon = spy.new(function() end)
        QuestieMap.DrawWaypoints = spy.new(function() end)
        QuestiePlayer.currentQuestlog = {}
        QuestieTooltips.lookupByKey = {}

        QuestFinisher = require("Modules.Quest.QuestFinisher")
    end)

    it("should add finisher", function()
        QuestiePlayer.currentQuestlog[1] = true
        QuestieDB.GetNPC = spy.new(function() return { id = 123, name = "Test Finisher", spawns = {[1]={{50,50}}} } end)
        local quest = {
            Id = 1,
            Finisher = {
                Type = "monster",
                Id = 123,
                Name = "Test Finisher"
            },
            IsComplete = function()
                return 1
            end,
            IsRepeatable = false
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher", 123, "m_123")
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 1, 50, 50, nil)
    end)

    it("should add finisher with waypoints", function()
        QuestiePlayer.currentQuestlog[1] = true
        QuestieDB.GetNPC = spy.new(function() return {
            id = 123,
            name = "Test Finisher",
            spawns = {[1]={{50,50}}},
            waypoints = {[1] = {{{10,10},{20,20}}}}
        } end)
        local quest = {
            Id = 1,
            Finisher = {
                Type = "monster",
                Id = 123,
                Name = "Test Finisher"
            },
            IsComplete = function()
                return 1
            end,
            IsRepeatable = false
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher", 123, "m_123")
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 1, 50, 50, nil)
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 1, 10, 10)
        assert.spy(QuestieMap.DrawWaypoints).was_called_with(QuestieMap, _, {{{10,10},{20,20}}}, 1)
    end)

    it("should add finisher for dungeon location", function()
        QuestiePlayer.currentQuestlog[1] = true
        QuestieDB.GetNPC = spy.new(function() return { id = 123, name = "Test Finisher", spawns = {[1]={{-1,-1}}}} end)
        ZoneDB.GetDungeonLocation = spy.new(function() return {{2,60,60}} end)
        local quest = {
            Id = 1,
            Finisher = {
                Type = "monster",
                Id = 123,
                Name = "Test Finisher"
            },
            IsComplete = function()
                return 1
            end,
            IsRepeatable = false
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher", 123, "m_123")
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 2, 60, 60)
        assert.spy(QuestieMap.DrawWaypoints).was_not_called()
    end)

    it("should not add finisher if quest is not in the players quest log", function()
        QuestiePlayer.currentQuestlog = {}
        local quest = {
            Id = 1,
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_not_called()
        assert.spy(QuestieMap.DrawWorldIcon).was_not_called()
        assert.spy(QuestieMap.DrawWaypoints).was_not_called()
    end)

    it("should not add finisher when IsQuestFlaggedCompleted is true", function()
        QuestiePlayer.currentQuestlog[1] = true
        _G.C_QuestLog.IsQuestFlaggedCompleted.mockedReturnValue = true
        local quest = {
            Id = 1,
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_not_called()
        assert.spy(QuestieMap.DrawWorldIcon).was_not_called()
        assert.spy(QuestieMap.DrawWaypoints).was_not_called()
    end)

    it("should not add finisher when quest is already complete", function()
        QuestiePlayer.currentQuestlog[1] = true
        Questie.db.char.complete[1] = true
        local quest = {
            Id = 1,
            IsComplete = function()
                return 1
            end,
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_not_called()
        assert.spy(QuestieMap.DrawWorldIcon).was_not_called()
        assert.spy(QuestieMap.DrawWaypoints).was_not_called()
    end)
end)
