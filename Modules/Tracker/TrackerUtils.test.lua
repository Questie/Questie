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
            collapsedQuests = {},
            collapsedZones = {},
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
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {})

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(TrackerLinePool.GetNextItemButton).was_called()
        assert.spy(button.SetItem).was_called_with(button, 123, "primary", 12)
        assert.is_true(button:IsVisible())

        assert.equals(line, button.line)
        assert.is_false(line.expandQuest:IsVisible())
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
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {})

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(TrackerLinePool.GetNextItemButton).was_called()
        assert.spy(button.SetItem).was_called_with(button, 456, "primary", 12)
        assert.is_true(button:IsVisible())

        assert.equals(line, button.line)
        assert.is_false(line.expandQuest:IsVisible())
    end)

    it("should add sourceItemId as primary button and single requiredSourceItems as secondary button", function()
        _G.GetItemSpell = function() return 111 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = spy.new(function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                return secondaryButton
            end
        end)
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {})

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(TrackerLinePool.GetNextItemButton).was_called()
        assert.spy(primaryButton.SetItem).was_called_with(primaryButton, 123, "primary", 12)
        assert.spy(secondaryButton.SetItem).was_called_with(secondaryButton, 456, "secondary", 12)
        assert.is_true(primaryButton:IsVisible())
        assert.is_true(secondaryButton:IsVisible())

        assert.equals(line, primaryButton.line)
        assert.equals(line, secondaryButton.line)
        assert.is_false(line.expandQuest:IsVisible())
    end)

    it("should add multiple requiredSourceItems entries as primary and secondary buttons", function()
        _G.GetItemSpell = function() return 111 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return nil
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = spy.new(function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                return secondaryButton
            end
        end)
        local quest = {
            Id = 1,
            requiredSourceItems = {123,456},
            Objectives = {},
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {})

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(TrackerLinePool.GetNextItemButton).was_called()
        assert.spy(primaryButton.SetItem).was_called_with(primaryButton, 123, "primary", 12)
        assert.spy(secondaryButton.SetItem).was_called_with(secondaryButton, 456, "secondary", 12)
        assert.is_true(primaryButton:IsVisible())
        assert.is_true(secondaryButton:IsVisible())

        assert.equals(line, primaryButton.line)
        assert.equals(line, secondaryButton.line)
        assert.is_false(line.expandQuest:IsVisible())
    end)

    it("should show expandQuest button and hide item buttons when quest is collapsed", function()
        Questie.db.char.collapsedQuests[1] = true
        _G.GetItemSpell = function() return 111 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = spy.new(function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                return secondaryButton
            end
        end)
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
        }
        local line = _GetMockedLine()

        TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {})

        assert.is_false(primaryButton:IsVisible())
        assert.is_false(secondaryButton:IsVisible())
        assert.is_true(line.expandQuest:IsVisible())
    end)


    it("should hide item buttons when zone is collapsed", function()
        Questie.db.char.collapsedZones["Durotar"] = true
        _G.GetItemSpell = function() return 111 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = spy.new(function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                return secondaryButton
            end
        end)
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
        }
        local line = _GetMockedLine()

        TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {})

        assert.is_false(primaryButton:IsVisible())
        assert.is_false(secondaryButton:IsVisible())
        assert.is_false(line.expandQuest:IsVisible())
    end)
end)

function _GetMockedLine()
    local line = CreateFrame("Frame")
    line:SetPoint("TOPLEFT", 0, 0)
    line:SetSize(1, 1)
    line.expandQuest = CreateFrame("Button")
    line.expandZone = {zoneId = "Durotar"}
    return line
end
