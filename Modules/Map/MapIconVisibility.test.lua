dofile("setupTests.lua")

describe("MapIconVisibility", function()
    ---@type MapIconVisibility
    local MapIconVisibility
    ---@type QuestieQuest
    local QuestieQuest
    ---@type ThreadLib
    local ThreadLib

    before_each(function()
        Questie.db.profile = {
            enabled = true,
            enableMapIcons = true,
            enableMiniMapIcons = true,
        }

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ShowQuestIcons = spy.new(function() end)
        QuestieQuest.private.ShowManualIcons = spy.new(function() end)
        QuestieQuest.private.HideManualIcons = spy.new(function() end)

        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        ThreadLib.ThreadInstant = function(callback) callback() end

        dofile("Modules/Map/MapIconVisibility.lua")
        MapIconVisibility = QuestieLoader:ImportModule("MapIconVisibility")
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
        it("should reapply the visibility of quest and manual icons", function()
            MapIconVisibility.Refresh()

            assert.spy(QuestieQuest.ShowQuestIcons).was.called()
            assert.spy(QuestieQuest.private.ShowManualIcons).was.called()
            assert.spy(QuestieQuest.private.HideManualIcons).was.called()
        end)
    end)

    describe("ToggleMinimap", function()
        it("should hide only the minimap icons", function()
            MapIconVisibility.ToggleMinimap()

            assert.is_false(Questie.db.profile.enableMiniMapIcons)
            assert.is_true(Questie.db.profile.enableMapIcons)
            assert.is_true(Questie.db.profile.enabled)
            assert.spy(QuestieQuest.ShowQuestIcons).was.called()
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
            assert.spy(QuestieQuest.ShowQuestIcons).was.called()
        end)
    end)

    describe("ToggleWorldMap", function()
        it("should hide only the world map icons", function()
            MapIconVisibility.ToggleWorldMap()

            assert.is_false(Questie.db.profile.enableMapIcons)
            assert.is_true(Questie.db.profile.enableMiniMapIcons)
            assert.is_true(Questie.db.profile.enabled)
            assert.spy(QuestieQuest.ShowQuestIcons).was.called()
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
            assert.spy(QuestieQuest.ShowQuestIcons).was.called()
        end)
    end)
end)
