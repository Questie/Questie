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

    it("should add NPC finisher", function()
        QuestiePlayer.currentQuestlog[1] = true
        QuestieDB.GetNPC = spy.new(function(_, id)
            if id == 123 then
                return { id = 123, name = "Test Finisher", spawns = {[1]={{50,50}}} }
            else
                return { id = 456, name = "Test Finisher 2", spawns = {[2]={{60,60}}} }
            end
        end)
        QuestieDB.GetObject = spy.new(function() end)
        local quest = {
            Id = 1,
            Finisher = {
                NPC = {123,456},
            },
            IsComplete = function()
                return 1
            end,
            IsRepeatable = false
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher", 123, "m_123")
        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher 2", 456, "m_456")
        assert.spy(QuestieDB.GetObject).was_not_called()
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 1, 50, 50, nil)
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 2, 60, 60, nil)
    end)

    it("should add object finisher", function()
        QuestiePlayer.currentQuestlog[1] = true
        QuestieDB.GetObject = spy.new(function(_, id)
            if id == 123 then
                return { id = 123, name = "Test Finisher", spawns = {[1]={{50,50}}} }
            else
                return { id = 456, name = "Test Finisher 2", spawns = {[2]={{60,60}}} }
            end
        end)
        QuestieDB.GetNPC = spy.new(function() end)
        local quest = {
            Id = 1,
            Finisher = {
                GameObject = {123,456},
            },
            IsComplete = function()
                return 1
            end,
            IsRepeatable = false
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher", 123, "o_123")
        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher 2", 456, "o_456")
        assert.spy(QuestieDB.GetNPC).was_not_called()
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 1, 50, 50, nil)
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 2, 60, 60, nil)
    end)

    it("should add mixed finisher", function()
        QuestiePlayer.currentQuestlog[1] = true
        QuestieDB.GetNPC = spy.new(function(_, id)
            if id == 123 then
                return { id = 123, name = "Test Finisher", spawns = {[1]={{50,50}}} }
            else
                return { id = 456, name = "Test Finisher 2", spawns = {[2]={{60,60}}} }
            end
        end)
        QuestieDB.GetObject = spy.new(function(_, id)
            if id == 789 then
                return { id = 789, name = "Test Finisher 3", spawns = {[3]={{70,70}}} }
            else
                return { id = 987, name = "Test Finisher 4", spawns = {[4]={{80,80}}} }
            end
        end)
        local quest = {
            Id = 1,
            Finisher = {
                NPC = {123,456},
                GameObject = {789,987}
            },
            IsComplete = function()
                return 1
            end,
            IsRepeatable = false
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher", 123, "m_123")
        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher 2", 456, "m_456")
        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher 3", 789, "o_789")
        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_called_with(QuestieTooltips, 1, "Test Finisher 4", 987, "o_987")
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 1, 50, 50, nil)
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 2, 60, 60, nil)
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 3, 70, 70, nil)
        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 4, 80, 80, nil)
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
                NPC = {123},
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
                NPC = {123},
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

    it("should not add finisher when quest has no finisher", function()
        QuestiePlayer.currentQuestlog[1] = true
        Questie.db.char.complete[1] = true
        QuestieDB.GetNPC = spy.new(function() end)
        QuestieDB.GetObject = spy.new(function() end)
        local quest = {
            Id = 1,
            Finisher = {},
            IsComplete = function()
                return 1
            end,
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieTooltips.RegisterQuestStartTooltip).was_not_called()
        assert.spy(QuestieDB.GetNPC).was_not_called()
        assert.spy(QuestieDB.GetObject).was_not_called()
        assert.spy(QuestieMap.DrawWorldIcon).was_not_called()
        assert.spy(QuestieMap.DrawWaypoints).was_not_called()
    end)
end)
