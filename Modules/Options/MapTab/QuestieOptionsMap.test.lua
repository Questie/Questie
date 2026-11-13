dofile("setupTests.lua")

describe("map options", function()
    local QuestieWaypoints, QuestiePolygon
    local args

    before_each(function()
        Questie.db.profile = {}
        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.Refresh = spy.new(function() end)
        QuestieWaypoints.Redraw = spy.new(function() end)
        QuestiePolygon = QuestieLoader:ImportModule("QuestiePolygon")
        QuestiePolygon.RefreshVisibility = spy.new(function() end)
        dofile("Modules/Options/QuestieOptionsDefaults.lua")
        dofile("Modules/Options/QuestieOptions.lua")
        dofile("Modules/Options/MapTab/QuestieOptionsMap.lua")
        args = QuestieLoader:ImportModule("QuestieOptions").tabs.map:Initialize().args
    end)

    it("stores a picked color as a new table and redraws the paths", function()
        local stored = {1, 0.2, 0, 0.7}
        Questie.db.profile.waypointHostileColor = stored
        local info = {"waypointHostileColor"}
        local option = args.waypoint_appearance_group.args.waypointHostileColor

        assert.are_same({1, 0.2, 0, 0.7}, {option.get(info)})

        option.set(info, 0, 0, 1, 0.5)

        assert.are_same({0, 0, 1, 0.5}, Questie.db.profile.waypointHostileColor)
        -- AceDB's defaults and the reset dialog share their tables, so a stored color is never changed in place.
        assert.are_same({1, 0.2, 0, 0.7}, stored)
        assert.spy(QuestieWaypoints.Refresh).was.called(1)
    end)

    it("redraws the lines' geometry for a new smoothing", function()
        args.waypoint_advanced_group.args.waypointSmoothing.set({"waypointSmoothing"}, 1)

        assert.are.equal(1, Questie.db.profile.waypointSmoothing)
        assert.spy(QuestieWaypoints.Redraw).was.called(1)
    end)

    describe("blobs", function()
        it("comes first, under its own header", function()
            local first
            for key, option in pairs(args) do
                if not first or option.order < args[first].order then first = key end
            end

            assert.are_equal("blobs_header", first)
            assert.are_equal("header", args.blobs_header.type)
        end)

        it("greys out the quest area settings unless icons are on and Questie blobs is chosen", function()
            Questie.db.profile.enabled, Questie.db.profile.enableQuestiePolygons = true, false
            assert.is_true(args.showPolygonsOnAcceptToggle.disabled())
            assert.is_true(args.polygonAreaTooltipsToggle.disabled())

            Questie.db.profile.enableQuestiePolygons = true
            assert.is_false(args.showPolygonsOnAcceptToggle.disabled())
            assert.is_false(args.polygonAreaTooltipsToggle.disabled())

            Questie.db.profile.enabled = false
            assert.is_true(args.showPolygonsOnAcceptToggle.disabled())
            assert.is_true(args.polygonAreaTooltipsToggle.disabled())
        end)

        it("refreshes area visibility when the accepted quest areas setting changes", function()
            args.showPolygonsOnAcceptToggle.set(nil, true)

            assert.is_true(Questie.db.profile.showPolygonsOnAccept)
            assert.spy(QuestiePolygon.RefreshVisibility).was.called(1)
        end)
    end)
end)
