dofile("setupTests.lua")

describe("QuestFinisher", function()

    ---@type QuestieDB
    local QuestieDB
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
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestieTooltips = require("Modules.Tooltips.Tooltip")
        QuestieMap = require("Modules.Map.QuestieMap")

        QuestieDB.IsActiveEventQuest = function() return false end
        QuestieDB.IsPvPQuest = function() return false end
        QuestiePlayer.currentQuestlog = {}
        QuestieTooltips.lookupByKey = {}

        QuestFinisher = require("Modules.Quest.QuestFinisher")
    end)

    it("should add finisher", function()
        QuestiePlayer.currentQuestlog[1] = true
        QuestieDB.GetNPC = spy.new(function() return { id = 1, name = "Test Finisher", spawns = {[1]={{50,50}}} } end)
        QuestieMap.DrawWorldIcon = spy.new(function() end)
        local quest = {
            Id = 1,
            Finisher = {
                Type = "monster",
                Id = 1,
                Name = "Test Finisher"
            },
            IsComplete = function()
                return 1
            end,
            IsRepeatable = false
        }

        QuestFinisher.AddFinisher(quest)

        assert.spy(QuestieMap.DrawWorldIcon).was_called_with(QuestieMap, _, 1, 50, 50, nil)
    end)
end)
