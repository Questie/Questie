dofile("setupTests.lua")

describe("TrackerMenu", function()
    ---@type TrackerMenu
    local TrackerMenu
    ---@type QuestieQuest
    local QuestieQuest
    ---@type TrackerUtils
    local TrackerUtils

    before_each(function()
        QuestieLoader:ImportModule("QuestieTracker")
        QuestieLoader:ImportModule("TrackerBaseFrame")

        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.UnFocus = function() end
        TrackerUtils.ShowObjectiveOnMap = function() end

        QuestieLoader:ImportModule("QuestieLink")
        QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieLoader:ImportModule("QuestieLib")
        QuestieLoader:ImportModule("QuestieDB")
        QuestieLoader:ImportModule("DistanceUtils")

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleQuestNotes = function() end

        _G.StaticPopupDialogs = {}
        _G.LibStub = {
            GetLibrary = function(_, _)
                return {
                    Create_UIDropDownMenu = function() end,
                    CloseDropDownMenus = function() end,
                }
            end
        }

        Questie.db = {
            char = {
                TrackerHiddenObjectives = {},
                TrackerHiddenQuests = {},
            },
            profile = {
                debugEnabled = false,
            }
        }

        dofile("Localization/l10n.lua")

        dofile("Modules/Tracker/LinePool/TrackerMenu.lua")
        TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
    end)

    describe("quest actions without a legacy quest log", function()
        local originals
        local compat
        local tracker

        before_each(function()
            originals = {
                QuestLogExFrame = _G.QuestLogExFrame,
                ClassicQuestLog = _G.ClassicQuestLog,
                QuestLogFrame = _G.QuestLogFrame,
                QuestMapFrame = _G.QuestMapFrame,
                StaticPopup_Show = _G.StaticPopup_Show,
                StaticPopup_Hide = _G.StaticPopup_Hide,
            }
            _G.QuestLogExFrame = nil
            _G.ClassicQuestLog = nil
            _G.QuestLogFrame = nil
            _G.QuestMapFrame = {IsShown = function() return true end}
            _G.StaticPopup_Show = spy.new(function() end)
            _G.StaticPopup_Hide = function() end
            compat = QuestieLoader:ImportModule("QuestieCompat")
            compat.QuestLog_Update = spy.new(function() end)
            tracker = QuestieLoader:ImportModule("QuestieTracker")
            tracker.UntrackQuestId = spy.new(function() end)
        end)

        after_each(function()
            _G.QuestLogExFrame = originals.QuestLogExFrame
            _G.ClassicQuestLog = originals.ClassicQuestLog
            _G.QuestLogFrame = originals.QuestLogFrame
            _G.QuestMapFrame = originals.QuestMapFrame
            _G.StaticPopup_Show = originals.StaticPopup_Show
            _G.StaticPopup_Hide = originals.StaticPopup_Hide
        end)

        it("untracks a quest without trying to refresh the missing legacy frame", function()
            local menu = {}
            TrackerMenu.addUntrackOption(menu, {Id = 783})
            menu[1].func()
            assert.spy(tracker.UntrackQuestId).was.called_with(tracker, 783)
            assert.spy(compat.QuestLog_Update).was.not_called()
        end)

        it("opens abandonment confirmation and restores selection on the modern client", function()
            compat.GetQuestLogSelection = function() return 3 end
            compat.GetQuestLogIndexByID = function() return 2 end
            compat.SelectQuestLogEntry = spy.new(function() end)
            compat.SetAbandonQuest = spy.new(function() end)
            compat.GetAbandonQuestItems = function() return nil end
            compat.GetAbandonQuestName = function() return "A Threat Within" end
            local menu = {}
            TrackerMenu.addAbandonedQuest(menu, {Id = 783})
            menu[1].func()
            assert.spy(StaticPopup_Show).was.called_with("ABANDON_QUEST", "A Threat Within")
            assert.spy(compat.SelectQuestLogEntry).was.called_with(2)
            assert.spy(compat.SelectQuestLogEntry).was.called_with(3)
            assert.spy(compat.QuestLog_Update).was.not_called()
        end)

        it("still refreshes a visible third-party quest log", function()
            _G.QuestLogExFrame = {IsShown = function() return true end}
            local menu = {}
            TrackerMenu.addUntrackOption(menu, {Id = 783})
            menu[1].func()
            assert.spy(compat.QuestLog_Update).was.called(1)
        end)
    end)

    describe("addShowHideObjectivesOption", function()
        it("should add 'Hide Icons' option and call ToggleQuestNotes(false) when icons are visible", function()
            local quest = {Id = 100}
            local objective = {Index = 1, HideIcons = nil}
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowHideObjectivesOption(menu, quest, objective)

            assert.are_same(1, #menu)
            assert.are_same("Hide Icons", menu[1].text)

            menu[1].func()

            assert.is_true(objective.HideIcons)
            assert.is_true(Questie.db.char.TrackerHiddenObjectives["100 1"])
            assert.spy(toggleSpy).was.called_with(false)
        end)

        it("should add 'Show Icons' option and call ToggleQuestNotes(true) when icons are hidden", function()
            local quest = {Id = 100}
            local objective = {Index = 1, HideIcons = true}
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowHideObjectivesOption(menu, quest, objective)

            assert.are_same(1, #menu)
            assert.are_same("Show Icons", menu[1].text)

            menu[1].func()

            assert.is_nil(objective.HideIcons)
            assert.is_nil(Questie.db.char.TrackerHiddenObjectives["100 1"])
            assert.spy(toggleSpy).was.called_with(true)
        end)
    end)

    describe("addShowHideQuestsOption", function()
        it("should add 'Hide Icons' option and call ToggleQuestNotes(false) when icons are visible", function()
            local quest = {Id = 200, HideIcons = nil}
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowHideQuestsOption(menu, quest)

            assert.are_same(1, #menu)
            assert.are_same("Hide Icons", menu[1].text)

            menu[1].func()

            assert.is_true(quest.HideIcons)
            assert.is_true(Questie.db.char.TrackerHiddenQuests[200])
            assert.spy(toggleSpy).was.called_with(false)
        end)

        it("should add 'Show Icons' option and call ToggleQuestNotes(true) when icons are hidden", function()
            local quest = {Id = 200, HideIcons = true}
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowHideQuestsOption(menu, quest)

            assert.are_same(1, #menu)
            assert.are_same("Show Icons", menu[1].text)

            menu[1].func()

            assert.is_nil(quest.HideIcons)
            assert.is_nil(Questie.db.char.TrackerHiddenQuests[200])
            assert.spy(toggleSpy).was.called_with(true)
        end)
    end)

    describe("addShowObjectivesOnMapOption", function()
        it("should call ToggleQuestNotes(true) when objective has HideIcons set", function()
            local quest = {Id = 300, HideIcons = nil}
            local objective = {Index = 1, HideIcons = true}
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.is_nil(objective.HideIcons)
            assert.spy(toggleSpy).was.called_with(true)
        end)

        it("should call ToggleQuestNotes(true) when quest has HideIcons set", function()
            local quest = {Id = 300, HideIcons = true}
            local objective = {Index = 1, HideIcons = nil}
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.is_nil(quest.HideIcons)
            assert.spy(toggleSpy).was.called_with(true)
        end)

        it("should not call ToggleQuestNotes when nothing is hidden", function()
            local quest = {Id = 300, HideIcons = nil}
            local objective = {Index = 1, HideIcons = nil}
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.spy(toggleSpy).was_not.called()
        end)
    end)
end)
