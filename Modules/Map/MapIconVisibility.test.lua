dofile("setupTests.lua")

describe("MapIconVisibility", function()
    ---@type MapIconVisibility
    local MapIconVisibility
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieMap
    local QuestieMap
    ---@type ThreadLib
    local ThreadLib

    before_each(function()
        Questie.db.profile = {
            enabled = true,
            enableMapIcons = true,
            enableMiniMapIcons = true,
        }

        Questie.db.char = {}

        QuestieMap = QuestieLoader:ImportModule("QuestieMap")

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.private.ShowManualIcons = spy.new(function() end)
        QuestieQuest.private.HideManualIcons = spy.new(function() end)

        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        ThreadLib.ThreadInstant = function(callback) callback() end

        dofile("Modules/Map/MapIconVisibility.lua")
        MapIconVisibility = QuestieLoader:ImportModule("MapIconVisibility")
    end)

    describe("ShowQuestIcons", function()
        it("should hide icons that should be hidden and show the others", function()
            local function newIcon(hidden, shouldHide)
                return {
                    data = {Type = "monster", QuestData = {}},
                    hidden = hidden,
                    ShouldBeHidden = function() return shouldHide end,
                    FakeShow = spy.new(function(self) self.hidden = false end),
                    FakeHide = spy.new(function(self) self.hidden = true end),
                    FadeIn = function() end,
                    FadeOut = function() end,
                }
            end
            local toHide, toShow = newIcon(false, true), newIcon(true, false)
            _G.FocusTestHide, _G.FocusTestShow = toHide, toShow
            QuestieMap.questIdFrames = {[1] = {"FocusTestHide"}, [2] = {"FocusTestShow"}}
            Questie.db.char.TrackerHiddenQuests = nil
            Questie.db.char.TrackerHiddenObjectives = nil

            for _, fn in ipairs({"ShowQuestIcons", "HideQuestIcons"}) do
                toHide.hidden, toShow.hidden = false, true
                local co = coroutine.create(function() MapIconVisibility[fn]() end)
                assert.is_true(coroutine.resume(co))
                assert.is_true(toHide.hidden)
                assert.is_false(toShow.hidden)
            end
            _G.FocusTestHide, _G.FocusTestShow = nil, nil
        end)

        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames = {}

            local co = coroutine.create(function()
                MapIconVisibility.ShowQuestIcons()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                MapIconVisibility.ShowQuestIcons()
            end, "ShowQuestIcons must be called from a coroutine")
        end)
    end)

    describe("HideQuestIcons", function()
        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames = {}

            local co = coroutine.create(function()
                MapIconVisibility.HideQuestIcons()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                MapIconVisibility.HideQuestIcons()
            end, "HideQuestIcons must be called from a coroutine")
        end)
    end)

    describe("ToggleQuestNotes", function()
        local ThreadLib, originalThreadInstant, originalThreadCallback

        before_each(function()
            ThreadLib = QuestieLoader:ImportModule("ThreadLib")
            originalThreadInstant, originalThreadCallback = ThreadLib.ThreadInstant, ThreadLib.ThreadCallbackInstant
            ThreadLib.ThreadInstant = function(work) coroutine.wrap(work)() end
            ThreadLib.ThreadCallbackInstant = spy.new(function() end)
            MapIconVisibility.ShowQuestIcons = spy.new(function() end)
            MapIconVisibility.HideQuestIcons = spy.new(function() end)
        end)

        after_each(function()
            ThreadLib.ThreadInstant, ThreadLib.ThreadCallbackInstant = originalThreadInstant, originalThreadCallback
        end)

        it("should show the quest icons without rebuilding the quest log", function()
            MapIconVisibility.ToggleQuestNotes(true)

            assert.spy(MapIconVisibility.ShowQuestIcons).was.called()
            assert.spy(ThreadLib.ThreadCallbackInstant).was.not_called()
        end)

        it("should hide the quest icons without rebuilding the quest log", function()
            MapIconVisibility.ToggleQuestNotes(false)

            assert.spy(MapIconVisibility.HideQuestIcons).was.called()
            assert.spy(ThreadLib.ThreadCallbackInstant).was.not_called()
        end)

        it("should keep townsfolk icons visible when hiding quest icons", function()
            local townsfolkIcon = {FakeHide = spy.new(function() end)}
            _G.QuestieTownsfolkTestIcon = townsfolkIcon
            QuestieMap.manualFrames = {Vendor = {[1] = {"QuestieTownsfolkTestIcon"}}}

            MapIconVisibility.ToggleQuestNotes(false)
            _G.QuestieTownsfolkTestIcon = nil

            assert.spy(townsfolkIcon.FakeHide).was.not_called()
        end)
    end)

    describe("IsWorldMapShown", function()
        it("should be true when Questie and the world map icons are enabled", function()
            assert.is_true(MapIconVisibility.IsWorldMapShown())
        end)

        it("should be false when the world map icons are disabled", function()
            Questie.db.profile.enableMapIcons = false

            assert.is_false(MapIconVisibility.IsWorldMapShown())
        end)

        it("should be false when Questie is disabled", function()
            Questie.db.profile.enabled = false

            assert.is_false(MapIconVisibility.IsWorldMapShown())
        end)
    end)

    describe("IsMinimapShown", function()
        it("should be true when Questie and the minimap icons are enabled", function()
            assert.is_true(MapIconVisibility.IsMinimapShown())
        end)

        it("should be false when the minimap icons are disabled", function()
            Questie.db.profile.enableMiniMapIcons = false

            assert.is_false(MapIconVisibility.IsMinimapShown())
        end)

        it("should be false when Questie is disabled", function()
            Questie.db.profile.enabled = false

            assert.is_false(MapIconVisibility.IsMinimapShown())
        end)
    end)

    describe("Refresh", function()
        before_each(function()
            MapIconVisibility.ShowQuestIcons = spy.new(function() end)
        end)

        it("should reapply the visibility of quest and manual icons", function()
            MapIconVisibility.Refresh()

            assert.spy(MapIconVisibility.ShowQuestIcons).was.called()
            assert.spy(QuestieQuest.private.ShowManualIcons).was.called()
            assert.spy(QuestieQuest.private.HideManualIcons).was.called()
        end)
    end)

    describe("ToggleMinimap", function()
        before_each(function()
            MapIconVisibility.ShowQuestIcons = spy.new(function() end)
        end)

        it("should hide only the minimap icons", function()
            MapIconVisibility.ToggleMinimap()

            assert.is_false(Questie.db.profile.enableMiniMapIcons)
            assert.is_true(Questie.db.profile.enableMapIcons)
            assert.is_true(Questie.db.profile.enabled)
            assert.spy(MapIconVisibility.ShowQuestIcons).was.called()
        end)

        it("should show only the minimap icons", function()
            Questie.db.profile.enableMiniMapIcons = false

            MapIconVisibility.ToggleMinimap()

            assert.is_true(Questie.db.profile.enableMiniMapIcons)
            assert.is_true(Questie.db.profile.enableMapIcons)
            assert.is_true(Questie.db.profile.enabled)
        end)

        it("should enable Questie and show only the minimap icons when Questie is disabled", function()
            Questie.db.profile.enabled = false

            MapIconVisibility.ToggleMinimap()

            assert.is_true(Questie.db.profile.enabled)
            assert.is_true(Questie.db.profile.enableMiniMapIcons)
            assert.is_false(Questie.db.profile.enableMapIcons)
            assert.spy(MapIconVisibility.ShowQuestIcons).was.called()
        end)
    end)

    describe("ToggleWorldMap", function()
        before_each(function()
            MapIconVisibility.ShowQuestIcons = spy.new(function() end)
        end)

        it("should hide only the world map icons", function()
            MapIconVisibility.ToggleWorldMap()

            assert.is_false(Questie.db.profile.enableMapIcons)
            assert.is_true(Questie.db.profile.enableMiniMapIcons)
            assert.is_true(Questie.db.profile.enabled)
            assert.spy(MapIconVisibility.ShowQuestIcons).was.called()
        end)

        it("should show only the world map icons", function()
            Questie.db.profile.enableMapIcons = false

            MapIconVisibility.ToggleWorldMap()

            assert.is_true(Questie.db.profile.enableMapIcons)
            assert.is_true(Questie.db.profile.enableMiniMapIcons)
            assert.is_true(Questie.db.profile.enabled)
        end)

        it("should enable Questie and show only the world map icons when Questie is disabled", function()
            Questie.db.profile.enabled = false

            MapIconVisibility.ToggleWorldMap()

            assert.is_true(Questie.db.profile.enabled)
            assert.is_true(Questie.db.profile.enableMapIcons)
            assert.is_false(Questie.db.profile.enableMiniMapIcons)
            assert.spy(MapIconVisibility.ShowQuestIcons).was.called()
        end)
    end)
end)
