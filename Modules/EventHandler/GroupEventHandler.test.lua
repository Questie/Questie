dofile("setupTests.lua")

describe("GroupEventHandler", function()
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieComms
    local QuestieComms
    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives
    ---@type GroupEventHandler
    local GroupEventHandler

    -- Seed the handler's internal snapshot (online status + group size) so the test can then make a
    -- single change and assert whether a redraw was scheduled. The spy is installed afterwards so the
    -- seeding call itself is not counted.
    local function seed(members, remoteQuestLogs)
        _G.GetNumGroupMembers = function() return members end
        QuestieComms.remoteQuestLogs = remoteQuestLogs or {}
        GroupEventHandler.GroupRosterUpdate()
        QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)
    end

    before_each(function()
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestiePlayer.numberOfGroupMembers = 0
        QuestieComms = require("Modules.Network.QuestieComms")
        QuestieComms.remoteQuestLogs = {}
        QuestiePartyObjectives = require("Modules.Network.QuestiePartyObjectives")
        -- ScheduleUpdate is what the assertions spy on, so stub it; the rest of the module is real.
        QuestiePartyObjectives.ScheduleUpdate = function() end
        GroupEventHandler = require("Modules.EventHandler.GroupEventHandler")

        _G.GetNumGroupMembers = function() return 0 end
        _G.UnitIsConnected = function() return true end
    end)

    it("should not redraw when only zones change (same size, same online status)", function()
        seed(3, {[100] = {["Bob"] = {}}})

        GroupEventHandler.GroupRosterUpdate()

        assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
    end)

    it("should redraw when a quest-sharing member changes online status", function()
        seed(3, {[100] = {["Bob"] = {}}})
        _G.UnitIsConnected = function() return false end

        GroupEventHandler.GroupRosterUpdate()

        assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called(1)
    end)

    it("should redraw when the group size changes", function()
        seed(3, {[100] = {["Bob"] = {}}})
        _G.GetNumGroupMembers = function() return 4 end

        GroupEventHandler.GroupRosterUpdate()

        assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called(1)
    end)

    it("should redraw when a member no longer shares quests", function()
        seed(3, {[100] = {["Bob"] = {}}})
        QuestieComms.remoteQuestLogs = {}

        GroupEventHandler.GroupRosterUpdate()

        assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called(1)
    end)
end)
