dofile("setupTests.lua")

local _GetMockedLine

describe("TrackerUtils", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type TrackerLinePool
    local TrackerLinePool
    ---@type TrackerUtils
    local TrackerUtils
    ---@type Expansions
    local Expansions

    local rePositionLineMock
    local match = require("luassert.match")
    local mock = require("luassert.mock")
    local _ = match._ -- any match

    local C_ItemMock

    before_each(function()
        Questie.db.profile = {
            trackerShowCompleteQuests = true
        }
        Questie.db.char = {
            collapsedQuests = {},
            collapsedZones = {},
        }
        CreateFrame.resetMockedFrames()
        C_ItemMock = mock(_G.C_Item, true)

        Expansions = require("Modules.Expansions")
        QuestieDB = require("Database.QuestieDB")
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        TrackerLinePool = require("Modules.Tracker.LinePool.TrackerLinePool")
        require("Modules.Tracker.LinePool.TrackerItemButton")
        TrackerUtils = require("Modules.Tracker.TrackerUtils")

        rePositionLineMock = spy.new(function() end)
    end)

    describe("AddQuestItemButtons", function()
        it("should add sourceItemId as primary button", function()
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
            C_ItemMock.GetItemSpell.returns(111)
            C_ItemMock.GetItemCount.returns(1)
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
    end)

    describe("HasQuest", function()

        before_each(function()
            Questie.IsCata = false
            Questie.IsWotlk = false
        end)

        it("should return true when a quest is tracked", function()
            _G.GetNumQuestWatches = function() return 1 end

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when no quest is tracked but an achievement for Cata", function()
            _G.GetNumQuestWatches = function() return 0 end
            _G.GetNumTrackedAchievements = function() return 1 end
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when no quest is tracked but an achievement for WotLK", function()
            _G.GetNumQuestWatches = function() return 0 end
            _G.GetNumTrackedAchievements = function() return 1 end
            Questie.IsWotlk = true
            Expansions.Current = Expansions.Wotlk

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return false when no quest and achievement is tracked for Cata", function()
            _G.GetNumQuestWatches = function() return 0 end
            _G.GetNumTrackedAchievements = function() return 0 end
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return false when no quest and achievement is tracked for WotLK", function()
            _G.GetNumQuestWatches = function() return 0 end
            _G.GetNumTrackedAchievements = function() return 0 end
            Questie.IsWotlk = true
            Expansions.Current = Expansions.Wotlk

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return false when no quest is tracked", function()
            _G.GetNumQuestWatches = function() return 0 end

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return true when a single quest is tracked and it is not complete and complete quests should not show", function()
            _G.GetNumQuestWatches = function() return 1 end
            _G.GetQuestLogIndexByID = function()
                return 1
            end
            _G.IsQuestWatched = function() return true end
            Questie.db.profile.trackerShowCompleteQuests = false
            QuestiePlayer.currentQuestlog = {
                [1] = {
                    IsComplete = function() return 0 end
                }
            }

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when a single quest is tracked and it is not complete but another is and complete quests should not show", function()
            _G.GetNumQuestWatches = function() return 1 end
            _G.GetQuestLogIndexByID = function(questId)
                return questId -- This is enough for the test case
            end
            _G.IsQuestWatched = function(index)
                if index == 1 then
                    return true
                end
                return false
            end
            Questie.db.profile.trackerShowCompleteQuests = false
            QuestiePlayer.currentQuestlog = {
                [1] = {
                    Id = 1,
                    IsComplete = function() return 0 end
                },
                [2] = {
                    Id = 2,
                    IsComplete = function() return 1 end
                }
            }

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return false when a quest is tracked and it is complete and complete quests should not show", function()
            _G.GetNumQuestWatches = function() return 1 end
            _G.GetQuestLogIndexByID = function()
                return 1
            end
            _G.IsQuestWatched = function() return true end
            Questie.db.profile.trackerShowCompleteQuests = false
            QuestiePlayer.currentQuestlog = {
                [1] = {
                    IsComplete = function() return 1 end
                }
            }

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)
    end)

    describe("GetCompletionText", function()
        it("should return API completion text", function()
            _G.GetQuestLogCompletionText = function() return "Return to that NPC" end
            _G.GetQuestLogIndexByID = function() return 1 end
            local quest = {Id = 1}

            local text = TrackerUtils:GetCompletionText(quest)

            assert.is_equal("Return to that NPC", text)
        end)

        it("should return quest description when GetQuestLogCompletionText API is not available", function()
            _G.GetQuestLogCompletionText = nil
            local quest = {Id = 1, Description = {"Return to that other NPC"}}

            local text = TrackerUtils:GetCompletionText(quest)

            assert.is_equal("Return to that other NPC", text)
        end)

        it("should return quest description when API does not return a completion text", function()
            _G.GetQuestLogCompletionText = function() return nil end
            _G.GetQuestLogIndexByID = function() return 1 end
            local quest = {Id = 1, Description = {"Return to that other NPC"}}

            local text = TrackerUtils:GetCompletionText(quest)

            assert.is_equal("Return to that other NPC", text)
        end)

        it("should return nil when API does not return a completion text and quest also has no description", function()
            _G.GetQuestLogCompletionText = nil
            local quest = {Id = 1}

            local text = TrackerUtils:GetCompletionText(quest)

            assert.is_equal(nil, text)
        end)
    end)
end)
