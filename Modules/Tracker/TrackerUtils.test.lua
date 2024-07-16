dofile("setupTests.lua")

describe("TrackerUtils", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type TrackerLinePool
    local TrackerLinePool
    ---@type TrackerItemButton
    local TrackerItemButton
    ---@type TrackerUtils
    local TrackerUtils

    before_each(function()
        Questie.db.profile = {}
        Questie.db.char = {
            collapsedQuests = {}
        }
        CreateFrame.resetMockedFrames()

        QuestieDB = require("Database.QuestieDB")
        TrackerLinePool = require("Modules.Tracker.TrackerLinePool")
        TrackerItemButton = require("Modules.Tracker.TrackerItemButton")
        TrackerUtils = require("Modules.Tracker.TrackerUtils")
    end)

    it("should add sourceItemId as primary button", function()
        _G.GetItemSpell = function() return 111 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local button = CreateFrame("Button")
        TrackerLinePool.GetNextItemButton = spy.new(function()
            button.SetItem = spy.new(function()
                return true
            end)
            return button
        end)
        local quest = {
            Id = 1,
            Objectives = {},
        }
        local line = CreateFrame("Frame")
        line:SetPoint("TOPLEFT", 0, 0)
        line:SetSize(1, 1)
        line.expandQuest = CreateFrame("Button")

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {})

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(TrackerLinePool.GetNextItemButton).was_called()
        assert.spy(button.SetItem).was_called_with(button, 123, "primary", 12)
        assert.not_nil(button.line)
    end)

    it("should add single requiredSourceItems entry as primary button", function()
        _G.GetItemSpell = function() return 111 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return nil
        end)
        local button = CreateFrame("Button")
        TrackerLinePool.GetNextItemButton = spy.new(function()
            button.SetItem = spy.new(function()
                return true
            end)
            return button
        end)
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
        }
        local line = CreateFrame("Frame")
        line:SetPoint("TOPLEFT", 0, 0)
        line:SetSize(1, 1)
        line.expandQuest = CreateFrame("Button")

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {})

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(TrackerLinePool.GetNextItemButton).was_called()
        assert.spy(button.SetItem).was_called_with(button, 456, "primary", 12)
        assert.not_nil(button.line)
    end)

    --it("should add sourceItemId as primary button and single requiredSourceItems as secondary button", function()
    --
    --end)
    --
    --it("should add multiple requiredSourceItems entries as primary and secondary buttons", function()
    --
    --end)
end)
