dofile("setupTests.lua")

describe("map options", function()
    local QuestieWaypoints
    local args

    before_each(function()
        Questie.db.profile = {}
        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.Refresh = spy.new(function() end)
        QuestieWaypoints.Redraw = spy.new(function() end)
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
end)
