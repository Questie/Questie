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

    describe("addShowHideObjectivesOption", function()
        it("should add 'Hide Icons' option and call ToggleQuestNotes(false) when icons are visible", function()
            local quest = { Id = 100 }
            local objective = { Index = 1, HideIcons = nil }
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
            local quest = { Id = 100 }
            local objective = { Index = 1, HideIcons = true }
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
            local quest = { Id = 200, HideIcons = nil }
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
            local quest = { Id = 200, HideIcons = true }
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
            local quest = { Id = 300, HideIcons = nil }
            local objective = { Index = 1, HideIcons = true }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.is_nil(objective.HideIcons)
            assert.spy(toggleSpy).was.called_with(true)
        end)

        it("should call ToggleQuestNotes(true) when quest has HideIcons set", function()
            local quest = { Id = 300, HideIcons = true }
            local objective = { Index = 1, HideIcons = nil }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.is_nil(quest.HideIcons)
            assert.spy(toggleSpy).was.called_with(true)
        end)

        it("should not call ToggleQuestNotes when nothing is hidden", function()
            local quest = { Id = 300, HideIcons = nil }
            local objective = { Index = 1, HideIcons = nil }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.spy(toggleSpy).was_not.called()
        end)
    end)
end)
