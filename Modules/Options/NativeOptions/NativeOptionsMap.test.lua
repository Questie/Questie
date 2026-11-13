dofile("setupTests.lua")

describe("native map options", function()
    local QuestieWaypoints, QuestiePolygon
    local items

    before_each(function()
        Questie.db.profile = {}
        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.Refresh = spy.new(function() end)
        QuestieWaypoints.Redraw = spy.new(function() end)
        QuestiePolygon = QuestieLoader:ImportModule("QuestiePolygon")
        QuestiePolygon.RefreshVisibility = spy.new(function() end)
        local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
        QuestieOptionsEngine.tabs = {}
        dofile("Modules/Options/QuestieOptionsDefaults.lua")
        dofile("Modules/Options/NativeOptions/NativeOptionsMap.lua")
        items = QuestieOptionsEngine.tabs.map:Initialize().items
    end)

    it("stores a picked color as a new table and redraws the paths", function()
        local stored = {1, 0.2, 0, 0.7}
        Questie.db.profile.waypointHostileColor = stored
        local option = items.waypoint_appearance_group.items.waypointHostileColor

        assert.are_same({1, 0.2, 0, 0.7}, {option.get()})

        option.set(0, 0, 1, 0.5)

        assert.are_same({0, 0, 1, 0.5}, Questie.db.profile.waypointHostileColor)
        -- AceDB's defaults and the reset dialog share their tables, so a stored color is never changed in place.
        assert.are_same({1, 0.2, 0, 0.7}, stored)
        assert.spy(QuestieWaypoints.Refresh).was.called(1)
    end)

    it("redraws the lines' geometry for a new smoothing", function()
        items.waypoint_advanced_group.items.waypointSmoothing.set(nil, 1)

        assert.are.equal(1, Questie.db.profile.waypointSmoothing)
        assert.spy(QuestieWaypoints.Redraw).was.called(1)
    end)

    describe("blobs", function()
        it("comes first, under a Blobs divider", function()
            local first
            for key, item in pairs(items) do
                if not first or item.order < items[first].order then first = key end
            end

            assert.are_equal("blobs_header", first)
            assert.are_same({type = "divider", order = 0.1, title = "Blobs"}, items.blobs_header)
        end)

        it("greys out the quest area settings unless icons are on and Questie blobs is chosen", function()
            Questie.db.profile.enabled, Questie.db.profile.enableQuestiePolygons = true, false
            assert.is_false(items.showPolygonsOnAcceptToggle.enabled())
            assert.is_false(items.polygonAreaTooltipsToggle.enabled())

            Questie.db.profile.enableQuestiePolygons = true
            assert.is_true(items.showPolygonsOnAcceptToggle.enabled())
            assert.is_true(items.polygonAreaTooltipsToggle.enabled())

            Questie.db.profile.enabled = false
            assert.is_false(items.showPolygonsOnAcceptToggle.enabled())
            assert.is_false(items.polygonAreaTooltipsToggle.enabled())
        end)

        it("refreshes area visibility when the accepted quest areas setting changes", function()
            items.showPolygonsOnAcceptToggle.set(nil, true)

            assert.is_true(Questie.db.profile.showPolygonsOnAccept)
            assert.spy(QuestiePolygon.RefreshVisibility).was.called(1)
        end)
    end)
end)
