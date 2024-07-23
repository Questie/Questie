dofile("setupTests.lua")

local _GetMockedLine

describe("TrackerUtils", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type TrackerLinePool
    local TrackerLinePool
    ---@type TrackerUtils
    local TrackerUtils

    local rePositionLineMock
    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        Questie.db.profile = {}
        Questie.db.char = {
            collapsedQuests = {},
            collapsedZones = {},
        }
        CreateFrame.resetMockedFrames()

        QuestieDB = require("Database.QuestieDB")
        TrackerLinePool = require("Modules.Tracker.TrackerLinePool")
        require("Modules.Tracker.TrackerItemButton")
        TrackerUtils = require("Modules.Tracker.TrackerUtils")
        
        rePositionLineMock = spy.new(function() end)
    end)

    it("should add sourceItemId as primary button", function()
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local button = CreateFrame("Button")
        TrackerLinePool.GetNextItemButton = function()
            button.SetItem = spy.new(function()
                return true
            end)
            button:Hide() -- initially item buttons are hidden
            return button
        end
        local quest = {
            Id = 1,
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(button.SetItem).was_called_with(_, 123, 1, 12)
        assert.is_true(button:IsVisible())

        assert.is_false(line.expandQuest:IsVisible())

        assert.spy(rePositionLineMock).was_not_called()
    end)

    it("should add single requiredSourceItems entry as primary button", function()
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return nil
        end)
        local button = CreateFrame("Button")
        TrackerLinePool.GetNextItemButton = function()
            button.SetItem = spy.new(function()
                return true
            end)
            button:Hide() -- initially item buttons are hidden
            return button
        end
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(button.SetItem).was_called_with(_, 456, 1, 12)
        assert.is_true(button:IsVisible())

        assert.is_false(line.expandQuest:IsVisible())

        assert.spy(rePositionLineMock).was_not_called()
    end)

    it("should add single objective item entry as primary button", function()
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return nil
        end)
        local button = CreateFrame("Button")
        TrackerLinePool.GetNextItemButton = function()
            button.SetItem = spy.new(function()
                return true
            end)
            button:Hide() -- initially item buttons are hidden
            return button
        end
        local quest = {
            Id = 1,
            Objectives = {},
            ObjectiveData = {
                [1] = {
                    Id = 123,
                    Type = "item",
                },
            },
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(button.SetItem).was_called_with(_, 123, 1, 12)
        assert.is_true(button:IsVisible())

        assert.is_false(line.expandQuest:IsVisible())

        assert.spy(rePositionLineMock).was_not_called()
    end)

    it("should add sourceItemId as primary button and single requiredSourceItems as secondary button", function()
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                primaryButton:Hide() -- initially item buttons are hidden
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                secondaryButton:Hide() -- initially item buttons are hidden
                return secondaryButton
            end
        end
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(primaryButton.SetItem).was_called_with(_, 123, 1, 12)
        assert.spy(secondaryButton.SetItem).was_called_with(_, 456, 1, 12)
        assert.is_true(primaryButton:IsVisible())
        assert.is_true(secondaryButton:IsVisible())

        assert.is_false(line.expandQuest:IsVisible())

        assert.spy(rePositionLineMock).was_called_with(1)
    end)

    it("should add sourceItemId as primary button and single objective item as secondary button", function()
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                primaryButton:Hide() -- initially item buttons are hidden
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                secondaryButton:Hide() -- initially item buttons are hidden
                return secondaryButton
            end
        end
        local quest = {
            Id = 1,
            Objectives = {},
            ObjectiveData = {
                [1] = {
                    Id = 456,
                    Type = "item",
                },
            },
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(primaryButton.SetItem).was_called_with(_, 123, 1, 12)
        assert.spy(secondaryButton.SetItem).was_called_with(_, 456, 1, 12)
        assert.is_true(primaryButton:IsVisible())
        assert.is_true(secondaryButton:IsVisible())

        assert.is_false(line.expandQuest:IsVisible())

        assert.spy(rePositionLineMock).was_called_with(1)
    end)

    it("should add multiple requiredSourceItems entries as primary and secondary buttons", function()
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return nil
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                primaryButton:Hide() -- initially item buttons are hidden
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                secondaryButton:Hide() -- initially item buttons are hidden
                return secondaryButton
            end
        end
        local quest = {
            Id = 1,
            requiredSourceItems = {123,456},
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(primaryButton.SetItem).was_called_with(_, 123, 1, 12)
        assert.spy(secondaryButton.SetItem).was_called_with(_, 456, 1, 12)
        assert.is_true(primaryButton:IsVisible())
        assert.is_true(secondaryButton:IsVisible())

        assert.is_false(line.expandQuest:IsVisible())

        assert.spy(rePositionLineMock).was_called_with(1)
    end)

    it("should add second item of requiredSourceItems as primary button if first is not in the inventory", function()
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function(itemId) return itemId == 456 and 1 or 0 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return nil
        end)
        local primaryButton = CreateFrame("Button")

        TrackerLinePool.GetNextItemButton = function()
            primaryButton.SetItem = spy.new(function()
                return true
            end)
            primaryButton:Hide() -- initially item buttons are hidden
            return primaryButton
        end
        local quest = {
            Id = 1,
            requiredSourceItems = {123,456},
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_true(shouldContinue)
        assert.spy(QuestieDB.QueryQuestSingle).was_called_with(1, "sourceItemId")
        assert.spy(primaryButton.SetItem).was_called_with(_, 456, 1, 12)
        assert.is_true(primaryButton:IsVisible())

        assert.is_false(line.expandQuest:IsVisible())
    end)

    it("should show expandQuest button without quest item", function()
        local quest = {
            Id = 1,
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_true(line.expandQuest:IsVisible())

        assert.spy(rePositionLineMock).was_not_called()
    end)

    it("should hide expandQuest button for complete quests without quest item and collapseCompletedQuests is true", function()
        Questie.db.profile.collapseCompletedQuests = true
        local quest = {
            Id = 1,
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        TrackerUtils.AddQuestItemButtons(quest, 1, line, 12, {}, true, rePositionLineMock)

        assert.is_false(line.expandQuest:IsVisible())

        assert.spy(rePositionLineMock).was_not_called()
    end)

    it("should show expandQuest button and hide item buttons when quest is collapsed", function()
        Questie.db.char.collapsedQuests[1] = true
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                primaryButton:Hide() -- initially item buttons are hidden
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                secondaryButton:Hide() -- initially item buttons are hidden
                return secondaryButton
            end
        end
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_false(primaryButton:IsVisible())
        assert.is_false(secondaryButton:IsVisible())
        assert.is_true(line.expandQuest:IsVisible())
    end)

    it("should show expandQuest button when no primary button is added", function()
        Questie.db.char.collapsedQuests[1] = true
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton = CreateFrame("Button")

        TrackerLinePool.GetNextItemButton = function()
            primaryButton.SetItem = spy.new(function()
                return false
            end)
            primaryButton:Hide() -- initially item buttons are hidden
            return primaryButton
        end
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_false(primaryButton:IsVisible())
        assert.is_true(line.expandQuest:IsVisible())
    end)

    it("should hide expandQuest button and hide item buttons when quest is collapsed and collapseCompletedQuests is true", function()
        Questie.db.char.collapsedQuests[1] = true
        Questie.db.profile.collapseCompletedQuests = true
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                primaryButton:Hide() -- initially item buttons are hidden
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                secondaryButton:Hide() -- initially item buttons are hidden
                return secondaryButton
            end
        end
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, true, rePositionLineMock)

        assert.is_false(primaryButton:IsVisible())
        assert.is_false(secondaryButton:IsVisible())
        assert.is_false(line.expandQuest:IsVisible())
    end)

    it("should hide item buttons when zone is collapsed", function()
        Questie.db.char.collapsedZones["Durotar"] = true
        _G.GetItemSpell = function() return 111 end
        _G.GetItemCount = function() return 1 end
        QuestieDB.QueryQuestSingle = spy.new(function()
            return 123
        end)
        local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
        local buttonIndex = 0

        TrackerLinePool.GetNextItemButton = function()
            if buttonIndex == 0 then
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                primaryButton:Hide() -- initially item buttons are hidden
                buttonIndex = buttonIndex + 1
                return primaryButton
            else
                secondaryButton.SetItem = spy.new(function()
                    return true
                end)
                secondaryButton:Hide() -- initially item buttons are hidden
                return secondaryButton
            end
        end
        local quest = {
            Id = 1,
            requiredSourceItems = {456},
            Objectives = {},
            ObjectiveData = {},
        }
        local line = _GetMockedLine()

        TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

        assert.is_false(primaryButton:IsVisible())
        assert.is_false(secondaryButton:IsVisible())
        assert.is_false(line.expandQuest:IsVisible())
    end)
end)

_GetMockedLine = function()
    local line = CreateFrame("Frame")
    line:SetPoint("TOPLEFT", 0, 0)
    line:SetSize(1, 1)
    line.label = CreateFrame("Button")
    line.expandQuest = CreateFrame("Button")
    line.expandQuest:Hide()
    line.expandZone = {zoneId = "Durotar"}
    return line
end
