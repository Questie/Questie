dofile("setupTests.lua")
local stub = require("luassert.stub")

local _GetMockedLine

describe("TrackerUtils", function()
    ---@type ZoneIDs
    local ZoneIDs
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type TrackerLinePool
    local TrackerLinePool
    ---@type TrackerUtils
    local TrackerUtils
    ---@type Expansions
    local Expansions
    ---@type QuestieTracker
    local QuestieTracker

    local TrackerData, trackerQuests
    local originalSpecialItemInfo
    local originalGlobals, originalExpansion, originalIsCata, originalIsWotlk
    local globalNames = {"C_Map", "GetNumQuestWatches", "GetNumTrackedAchievements", "GetQuestLogIndexByID",
        "IsQuestWatched", "GetQuestLogCompletionText"}
    local rePositionLineMock
    local match = require("luassert.match")
    local _ = match._ -- any match

    local getItemSpellMock, isEquippableItemMock, isAddOnLoadedMock
    local getItemCountMock

    before_each(function()
        originalGlobals = {}
        for _, name in ipairs(globalNames) do originalGlobals[name] = _G[name] end
        originalExpansion = QuestieLoader:ImportModule("Expansions").Current
        originalIsCata, originalIsWotlk = Questie.IsCata, Questie.IsWotlk
        Questie.db.profile = {
            trackerShowCompleteQuests = true
        }
        Questie.db.char = {
            collapsedQuests = {},
            collapsedZones = {},
        }
        CreateFrame.resetMockedFrames()
        local compat = QuestieLoader:ImportModule("QuestieCompat")
        getItemSpellMock = stub(compat, "GetItemSpell")
        isEquippableItemMock = stub(compat, "IsEquippableItem", function() return false end)
        isAddOnLoadedMock = stub(compat, "IsAddOnLoaded", function() return false end)
        getItemCountMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetItemCount", function() return 0 end)

        Expansions = QuestieLoader:ImportModule("Expansions")
        ZoneIDs = QuestieLoader:ImportModule("ZoneDB").zoneIDs
        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.GetNumTrackedQuests = function() return 0 end
        QuestieTracker.IsTrackedByQuestie = function() return false end
        trackerQuests = {}
        TrackerData = QuestieLoader:ImportModule("TrackerData")
        TrackerData.Refresh = spy.new(function() return trackerQuests end)
        TrackerData.GetQuests = function() return trackerQuests end
        TrackerData.GetQuest = function(id) return trackerQuests[id] end
        TrackerData.RefreshQuest = spy.new(function(id) return trackerQuests[id] end)
        dofile("Modules/Tracker/TrackerMapEligibility.lua")
        originalSpecialItemInfo = _G.GetQuestLogSpecialItemInfo
        _G.GetQuestLogSpecialItemInfo = nil
        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        QuestieLoader:ImportModule("TrackerItemButton")

        dofile("Modules/Tracker/TrackerUtils.lua")
        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")

        rePositionLineMock = spy.new(function() end)
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do _G[name] = originalGlobals[name] end
        Expansions.Current = originalExpansion
        Questie.IsCata, Questie.IsWotlk = originalIsCata, originalIsWotlk
        _G.GetQuestLogSpecialItemInfo = originalSpecialItemInfo
        getItemCountMock:revert()
        getItemSpellMock:revert()
        isEquippableItemMock:revert()
        isAddOnLoadedMock:revert()
    end)

    describe("ShowQuestLog", function()
        local originals, legacyFrame, scrollBar
        local getIndexMock, selectMock, detailsMock, updateMock
        local globalNames = {
            "QuestLogFrame", "QuestLogExFrame", "ClassicQuestLog", "QuestLogEx", "QuestLogListScrollFrame",
            "QuestLogListScrollFrameScrollBar", "QuestMapFrame_OpenToQuestDetails", "ShowUIPanel", "InCombatLockdown",
        }

        before_each(function()
            originals = {}
            for _, name in ipairs(globalNames) do
                originals[name] = _G[name]
                _G[name] = nil
            end
            legacyFrame = {IsShown = function() return false end}
            scrollBar = {GetValueStep = function() return 10 end, SetValue = spy.new(function() end)}
            _G.QuestLogFrame = legacyFrame
            _G.QuestLogListScrollFrame = {ScrollBar = scrollBar}
            _G.QuestMapFrame_OpenToQuestDetails = spy.new(function() end)
            _G.ShowUIPanel = spy.new(function() end)
            _G.InCombatLockdown = function() return false end
            local compat = QuestieLoader:ImportModule("QuestieCompat")
            getIndexMock = stub(compat, "GetQuestLogIndexByID", function() return 5 end)
            selectMock = stub(compat, "SelectQuestLogEntry")
            detailsMock = stub(compat, "QuestLog_UpdateQuestDetails")
            updateMock = stub(compat, "QuestLog_Update")
            dofile("Modules/Tracker/TrackerUtils.lua")
        end)

        after_each(function()
            getIndexMock:revert()
            selectMock:revert()
            detailsMock:revert()
            updateMock:revert()
            for _, name in ipairs(globalNames) do _G[name] = originals[name] end
        end)

        it("opens and selects the Classic quest log when the map-details helper also exists", function()
            TrackerUtils:ShowQuestLog({Id = 783})

            assert.spy(getIndexMock).was.called_with(783)
            assert.spy(selectMock).was.called_with(5)
            assert.spy(scrollBar.SetValue).was.called_with(scrollBar, 20)
            assert.spy(ShowUIPanel).was.called_with(legacyFrame)
            assert.spy(detailsMock).was.called(1)
            assert.spy(updateMock).was.called(1)
            assert.spy(_G.QuestMapFrame_OpenToQuestDetails).was.not_called()
        end)

        it("uses the modern quest ID route when no standalone quest log exists", function()
            _G.QuestLogFrame = nil
            _G.QuestLogListScrollFrame = nil
            dofile("Modules/Tracker/TrackerUtils.lua")

            TrackerUtils:ShowQuestLog({Id = 783})

            assert.spy(_G.QuestMapFrame_OpenToQuestDetails).was.called_with(783)
            assert.spy(getIndexMock).was.not_called()
            assert.spy(selectMock).was.not_called()
            assert.spy(scrollBar.SetValue).was.not_called()
            assert.spy(ShowUIPanel).was.not_called()
            assert.spy(detailsMock).was.not_called()
            assert.spy(updateMock).was.not_called()
        end)
    end)

    describe("IsQuestItemUsable", function()
        it("accepts equippable quest items without an associated spell", function()
            isEquippableItemMock.returns(true)

            assert.is_true(TrackerUtils:IsQuestItemUsable(123))
            assert.spy(getItemSpellMock).was.called_with(123)
            assert.spy(isEquippableItemMock).was.called_with(123)
        end)

        it("rejects items without either a spell or an equipment slot", function()
            assert.is_false(TrackerUtils:IsQuestItemUsable(123))
        end)
    end)

    describe("IsVoiceOverLoaded", function()
        it("requires both the addon and its Vanilla data", function()
            local loaded = {AI_VoiceOver = true}
            isAddOnLoadedMock:revert()
            isAddOnLoadedMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "IsAddOnLoaded", function(addon)
                return loaded[addon] == true
            end)
            dofile("Modules/Tracker/TrackerUtils.lua")

            assert.is_false(TrackerUtils:IsVoiceOverLoaded())
            loaded.AI_VoiceOverData_Vanilla = true
            assert.is_true(TrackerUtils:IsVoiceOverLoaded())
            assert.spy(isAddOnLoadedMock).was.called_with("AI_VoiceOver")
            assert.spy(isAddOnLoadedMock).was.called_with("AI_VoiceOverData_Vanilla")
        end)
    end)

    describe("GetQuestItemIds", function()
        it("does not select ordinary item objectives without a spell or equipment slot", function()
            getItemCountMock.returns(2)
            local quest = {Id = 1, ObjectiveData = {{Type = "item", Id = 123}}}

            assert.are.same({}, TrackerUtils.GetQuestItemIds(quest, 0))
        end)

        it("returns native-first deduplicated candidates without allocating buttons", function()
            local indexMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetQuestLogIndexByID", function() return 2 end)
            getItemCountMock.returns(1)
            getItemSpellMock.returns("Use Item")
            _G.GetQuestLogSpecialItemInfo = function() return "|Hitem:90001|h[Book]|h", nil, 1, false end
            TrackerLinePool.GetNextItemButton = spy.new(function() end)
            local quest = {Id = 91741, sourceItemId = 456, requiredSourceItems = {90001},
                ObjectiveData = {{Type = "item", Id = 456}}}

            local items, nativeItemId = TrackerUtils.GetQuestItemIds(quest, 0)
            indexMock:revert()

            assert.are.same({90001, 456}, items)
            assert.are.equal(90001, nativeItemId)
            assert.spy(TrackerLinePool.GetNextItemButton).was.not_called()
        end)
    end)

    describe("AddQuestItemButtons", function()
        it("should add sourceItemId as primary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
                sourceItemId = 123,
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(button.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.is_true(button:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should add single requiredSourceItems entry as primary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
            assert.spy(button.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(button:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should add single objective item entry as primary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
            assert.spy(button.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.is_true(button:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should add sourceItemId as primary button and single requiredSourceItems as secondary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
                sourceItemId = 123,
                requiredSourceItems = {456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(primaryButton.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.spy(secondaryButton.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(primaryButton:IsVisible())
            assert.is_true(secondaryButton:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.called_with(1)
        end)

        it("should add sourceItemId as primary button and single objective item as secondary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
                sourceItemId = 123,
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
            assert.spy(primaryButton.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.spy(secondaryButton.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(primaryButton:IsVisible())
            assert.is_true(secondaryButton:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.called_with(1)
        end)

        it("should add multiple requiredSourceItems entries as primary and secondary buttons", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
            assert.spy(primaryButton.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.spy(secondaryButton.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(primaryButton:IsVisible())
            assert.is_true(secondaryButton:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.called_with(1)
        end)

        it("should add second item of requiredSourceItems as primary button if first is not in the inventory", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock:revert()
            getItemCountMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetItemCount", function(itemId)
                return itemId == 456 and 1 or 0
            end)
            dofile("Modules/Tracker/TrackerUtils.lua")
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
            assert.spy(primaryButton.SetItem).was.called_with(_, 456, 1, 12, false)
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

            assert.spy(rePositionLineMock).was.not_called()
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

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should show expandQuest button and hide item buttons when quest is collapsed", function()
            Questie.db.char.collapsedQuests[1] = true
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
                sourceItemId = 123,
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
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
                sourceItemId = 123,
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
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
                sourceItemId = 123,
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
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
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
                sourceItemId = 123,
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

        describe("native quest items", function()
            local indexMock, button, quest

            before_each(function()
                indexMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetQuestLogIndexByID", function() return 2 end)
                button = CreateFrame("Button")
                button.SetItem = spy.new(function() return true end)
                TrackerLinePool.GetNextItemButton = spy.new(function() return button end)
                quest = {Id = 91741, Objectives = {}, ObjectiveData = {}}
                _G.GetQuestLogSpecialItemInfo = spy.new(function() return "|Hitem:90001|h[Book]|h", nil, 1, false end)
                getItemCountMock.returns(1)
            end)

            after_each(function()
                indexMock:revert()
            end)

            it("uses Blizzard's quest item without database metadata", function()
                TrackerUtils.AddQuestItemButtons(quest, 0, _GetMockedLine(), 12, {}, false, rePositionLineMock)

                assert.spy(_G.GetQuestLogSpecialItemInfo).was.called_with(2)
                assert.spy(button.SetItem).was.called_with(button, 90001, 91741, 12, true)
                assert.spy(getItemSpellMock).was.not_called()
            end)

            it("falls back to an owned database item when the native item is not in the inventory", function()
                getItemCountMock.invokes(function(itemId) return itemId == 456 and 1 or 0 end)
                getItemSpellMock.returns("Use Item")
                quest.sourceItemId = 456

                TrackerUtils.AddQuestItemButtons(quest, 0, _GetMockedLine(), 12, {}, false, rePositionLineMock)

                assert.spy(button.SetItem).was.called(1)
                assert.spy(button.SetItem).was.called_with(button, 456, 91741, 12, false)
            end)

            it("deduplicates a native item also listed as a source and objective item", function()
                getItemSpellMock.returns("Use Book")
                quest.sourceItemId = 90001
                quest.requiredSourceItems = {90001}
                quest.ObjectiveData = {{Type = "item", Id = 90001}}

                TrackerUtils.AddQuestItemButtons(quest, 0, _GetMockedLine(), 12, {}, false, rePositionLineMock)

                assert.spy(TrackerLinePool.GetNextItemButton).was.called(1)
                assert.spy(button.SetItem).was.called_with(button, 90001, 91741, 12, true)
            end)

            it("keeps a native action explicitly allowed after completion", function()
                _G.GetQuestLogSpecialItemInfo = function() return "|Hitem:90001|h[Book]|h", nil, 1, true end

                TrackerUtils.AddQuestItemButtons(quest, 1, _GetMockedLine(), 12, {}, true, rePositionLineMock)

                assert.spy(button.SetItem).was.called_with(button, 90001, 91741, 12, true)
            end)

            it("hides a native action on additional Questie completion unless Blizzard allows it", function()
                quest.isComplete = true

                TrackerUtils.AddQuestItemButtons(quest, 0, _GetMockedLine(), 12, {}, true, rePositionLineMock)

                assert.spy(TrackerLinePool.GetNextItemButton).was.not_called()
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
    end)

    describe("HasQuest", function()

        before_each(function()
            Questie.IsCata = false
            Questie.IsWotlk = false
        end)

        it("should return true when a quest is tracked", function()
            QuestieTracker.GetNumTrackedQuests = function() return 1 end

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when no quest is tracked but an achievement for Cata", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            _G.GetNumTrackedAchievements = function() return 1 end
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when no quest is tracked but an achievement for WotLK", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            _G.GetNumTrackedAchievements = function() return 1 end
            Questie.IsWotlk = true
            Expansions.Current = Expansions.Wotlk

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return false when no quest and achievement is tracked for Cata", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            _G.GetNumTrackedAchievements = function() return 0 end
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return false when no quest and achievement is tracked for WotLK", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            _G.GetNumTrackedAchievements = function() return 0 end
            Questie.IsWotlk = true
            Expansions.Current = Expansions.Wotlk

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return false when no quest is tracked", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return true when a single quest is tracked and it is not complete and complete quests should not show", function()
            QuestieTracker.GetNumTrackedQuests = function() return 1 end
            QuestieTracker.IsTrackedByQuestie = function() return true end
            Questie.db.profile.trackerShowCompleteQuests = false
            trackerQuests = {
                [1] = {
                    IsComplete = function() return 0 end
                }
            }

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when a single quest is tracked and it is not complete but another is and complete quests should not show", function()
            QuestieTracker.GetNumTrackedQuests = function() return 1 end
            QuestieTracker.IsTrackedByQuestie = function(questId)
                return questId == 1
            end
            Questie.db.profile.trackerShowCompleteQuests = false
            trackerQuests = {
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
            QuestieTracker.GetNumTrackedQuests = function() return 1 end
            QuestieTracker.IsTrackedByQuestie = function() return true end
            Questie.db.profile.trackerShowCompleteQuests = false
            trackerQuests = {
                [1] = {
                    IsComplete = function() return 1 end
                }
            }

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)
    end)

    describe("focus without verified enrichment", function()
        it("does not change existing focus when an unknown quest is selected", function()
            Questie.db.char.TrackerFocus = 11
            trackerQuests[91741] = {Id = 91741, Objectives = {}, SpecialObjectives = {}}

            assert.is_false(TrackerUtils:FocusQuest(91741))
            assert.are.equal(11, Questie.db.char.TrackerFocus)
        end)

        it("can focus a known finisher even when the completed quest has a new log objective", function()
            local original = {Id = 54, Objectives = {}, Finisher = {NPC = {240}}}
            QuestiePlayer.currentQuestlog[54] = original
            local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            QuestieDB.GetQuest = function() return original end
            trackerQuests[54] = {
                Id = 54, enrichment = original, Finisher = original.Finisher,
                Objectives = {{Index = 1, Type = "log"}}, IsComplete = function() return 1 end,
            }

            assert.is_true(TrackerUtils:FocusQuest(54))
            assert.are.equal(54, Questie.db.char.TrackerFocus)
            assert.is_nil(original.FadeIcons)
        end)

        it("does not focus an unmatched live objective", function()
            Questie.db.char.TrackerFocus = 11
            trackerQuests[91741] = {
                Id = 91741, enrichment = {}, Objectives = {{Index = 1}}, SpecialObjectives = {},
                IsComplete = function() return 0 end,
            }

            assert.is_false(TrackerUtils:FocusObjective(91741, 1))
            assert.are.equal(11, Questie.db.char.TrackerFocus)
        end)
    end)

    describe("map commands recheck current eligibility", function()
        it("does not focus an objective replaced at the same index while a menu was open", function()
            local oldObjective = {Index = 3, spawnList = {{}}}
            local newObjective = {Index = 3, spawnList = {{}}}
            local originalQuest = {Id = 100}
            trackerQuests[100] = {
                Id = 100, enrichment = originalQuest, Objectives = {{enrichment = newObjective}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            Questie.db.char.TrackerFocus = 11

            assert.is_false(TrackerUtils:FocusObjective(100, 3, oldObjective, originalQuest))
            assert.are.equal(11, Questie.db.char.TrackerFocus)
            assert.is_nil(newObjective.HideIcons)
            assert.spy(TrackerData.RefreshQuest).was.called_with(100)
        end)

        it("rejects whole-quest focus when only some live objectives are verified", function()
            trackerQuests[100] = {
                Id = 100, enrichment = {Id = 100},
                Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}, {Description = "Unknown step"}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            Questie.db.char.TrackerFocus = 11

            assert.is_false(TrackerUtils:FocusQuest(100))
            assert.are.equal(11, Questie.db.char.TrackerFocus)
        end)

        it("navigates using the refreshed display quest and its verified locations", function()
            local original = {Id = 100}
            local quest = {
                Id = 100, enrichment = original, Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            trackerQuests[100] = quest
            local distance = QuestieLoader:ImportModule("DistanceUtils")
            distance.GetNearestSpawnForQuest = spy.new(function() return {50, 60}, 12, "Wolf" end)
            TrackerUtils.SetTomTomTarget = spy.new(function() end)

            assert.is_true(TrackerUtils.SetQuestTomTomTarget(100, original))
            assert.spy(TrackerData.RefreshQuest).was.called_with(100)
            assert.spy(distance.GetNearestSpawnForQuest).was.called_with(quest)
            assert.spy(TrackerUtils.SetTomTomTarget).was.called_with(TrackerUtils, "Wolf", 12, 50, 60)
        end)

        it("does not navigate a quest whose original enrichment was replaced", function()
            trackerQuests[100] = {
                Id = 100, enrichment = {Id = 100}, Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            local distance = QuestieLoader:ImportModule("DistanceUtils")
            distance.GetNearestSpawnForQuest = spy.new(function() end)

            assert.is_false(TrackerUtils.SetQuestTomTomTarget(100, {Id = 100}))
            assert.spy(distance.GetNearestSpawnForQuest).was.not_called()
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

    describe("GetQuestGroupName", function()
        it("uses the native header when sorting by zone", function()
            Questie.db.profile.trackerSortObjectives = "byZone"

            assert.are.equal("Northshire Abbey", TrackerUtils.GetQuestGroupName({Id = 1, zoneName = "Northshire Abbey", zoneOrSort = 12}))
        end)

        it("uses the sort mode's single group instead of the zone in other sort modes", function()
            Questie.db.profile.trackerSortObjectives = "byLevel"

            assert.are.equal("Quests (By Level)", TrackerUtils.GetQuestGroupName({Id = 1, zoneName = "Northshire Abbey", zoneOrSort = 12}))
        end)
    end)

    describe("GetSortedQuestIds", function()
        before_each(function()
            trackerQuests = {}
            Questie.db.profile.trackerSortObjectives = "byZone"
            QuestieLib.GetQuestTypeSuffix = function() return "" end

            dofile("Modules/Tracker/Sorter/Sorter.lua")
            dofile("Modules/Tracker/Sorter/byComplete.lua")
            dofile("Modules/Tracker/Sorter/byLevel.lua")
            dofile("Modules/Tracker/Sorter/byZone.lua")

            _G.C_Map = {
                GetAreaInfo = function(zoneId)
                    local zoneNames = {
                        [ZoneIDs.DUN_MOROGH] = "Dun Morogh",
                        [ZoneIDs.DUROTAR] = "Durotar",
                        [ZoneIDs.ELWYNN_FOREST] = "Elwynn Forest",
                        [ZoneIDs.ZUL_DRAK] = "Zul'Drak",
                    }
                    return zoneNames[zoneId]
                end
            }
        end)

        it("uses native headers for quests absent from the database", function()
            trackerQuests = {
                [91741] = {Id = 91741, level = 2, zoneName = "Northshire Abbey", Objectives = {}, IsComplete = function() return 1 end},
            }

            local ids, details = TrackerUtils:GetSortedQuestIds()

            assert.are.same({91741}, ids)
            assert.spy(TrackerData.Refresh).was.not_called()
            assert.are.equal("Northshire Abbey", details[91741].zoneName)
            assert.are.equal(trackerQuests[91741], details[91741].quest)
            assert.is_nil(next(QuestiePlayer.currentQuestlog))
        end)

        it("does not treat pending or zero-total objectives as completed", function()
            trackerQuests = {
                [1] = {Id = 1, level = 2, zoneName = "Northshire Abbey", Objectives = {}, objectivesLoaded = false,
                    IsComplete = function() return 0 end},
                [2] = {Id = 2, level = 2, zoneName = "Northshire Abbey", Objectives = {{Collected = 0, Needed = 0, Completed = false}},
                    IsComplete = function() return 0 end},
                [3] = {Id = 3, level = 2, zoneName = "Northshire Abbey", Objectives = {{Collected = 0, Needed = 0, Completed = true}},
                    IsComplete = function() return 0 end},
            }

            local _, details = TrackerUtils:GetSortedQuestIds()

            assert.are.equal(0, details[1].questCompletePercent)
            assert.are.equal(0, details[2].questCompletePercent)
            assert.are.equal(1, details[3].questCompletePercent)
        end)

        it("should return quest IDs correctly sorted for 'byZone' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byZone"
            trackerQuests = {
                [1] = {Id = 1, level = 10, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [2] = {Id = 2, level = 5, zoneOrSort = ZoneIDs.ELWYNN_FOREST, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 80, zoneOrSort = ZoneIDs.ZUL_DRAK, IsComplete = function() return 1 end},
                [4] = {Id = 4, level = 15, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [5] = {Id = 5, level = 6, zoneOrSort = ZoneIDs.ELWYNN_FOREST, IsComplete = function() return 1 end},
                [6] = {Id = 6, level = 5, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [7] = {Id = 7, level = 79, zoneOrSort = ZoneIDs.ZUL_DRAK, IsComplete = function() return 1 end},
                [8] = {Id = 8, level = 10, zoneOrSort = ZoneIDs.DUN_MOROGH, IsComplete = function() return 1 end},
                [9] = {Id = 9, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [10] = {Id = 10, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [11] = {Id = 11, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [12] = {Id = 12, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [13] = {Id = 13, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [11] = "D",
                    [12] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({8, 6, 1, 9, 10, 13, 12, 11, 4, 2, 5, 7, 3}, sortedIds)
        end)

        it("should return quest IDs correctly sorted for 'byComplete' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byComplete"
            trackerQuests = {
                [1] = {Id = 1, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 0, Needed = 1}}},
                [2] = {Id = 2, level = 5, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [4] = {Id = 4, level = 15, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [5] = {Id = 5, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [6] = {Id = 6, level = 5, IsComplete = function() return 1 end},
                [7] = {Id = 7, level = 10, IsComplete = function() return 1 end},
                [8] = {Id = 8, level = 5, IsComplete = function() return 1 end},
                [9] = {Id = 9, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 9, Needed = 10}}},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [6] = "D",
                    [8] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({2, 8, 6, 7, 9, 3, 5, 4, 1}, sortedIds)
        end)

        it("should return quest IDs correctly sorted for 'byCompleteReversed' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byCompleteReversed"
            trackerQuests = {
                [1] = {Id = 1, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 0, Needed = 1}}},
                [2] = {Id = 2, level = 5, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [4] = {Id = 4, level = 15, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [5] = {Id = 5, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [6] = {Id = 6, level = 5, IsComplete = function() return 1 end},
                [7] = {Id = 7, level = 10, IsComplete = function() return 1 end},
                [8] = {Id = 8, level = 5, IsComplete = function() return 1 end},
                [9] = {Id = 9, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 9, Needed = 10}}},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [6] = "D",
                    [8] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({1, 3, 5, 4, 9, 2, 8, 6, 7}, sortedIds)
        end)

        it("should return quest IDs correctly sorted for 'byLevel' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byLevel"
            trackerQuests = {
                [1] = {Id = 1, level = 10, IsComplete = function() return 1 end},
                [2] = {Id = 2, level = 5, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 10, IsComplete = function() return 1 end},
                [4] = {Id = 4, level = 15, IsComplete = function() return 1 end},
                [5] = {Id = 5, level = 10, IsComplete = function() return 1 end},
                [6] = {Id = 6, level = 5, IsComplete = function() return 1 end},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [3] = "D",
                    [5] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({2, 6, 1, 5, 3, 4}, sortedIds)
        end)

        it("should return quest IDs correctly sorted for 'byLevelReversed' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byLevelReversed"
            trackerQuests = {
                [1] = {Id = 1, level = 10, IsComplete = function() return 1 end},
                [2] = {Id = 2, level = 5, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 10, IsComplete = function() return 1 end},
                [4] = {Id = 4, level = 15, IsComplete = function() return 1 end},
                [5] = {Id = 5, level = 10, IsComplete = function() return 1 end},
                [6] = {Id = 6, level = 5, IsComplete = function() return 1 end},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [3] = "D",
                    [5] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({4, 1, 5, 3, 2, 6}, sortedIds)
        end)
    end)
end)
