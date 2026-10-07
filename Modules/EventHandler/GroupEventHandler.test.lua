dofile("setupTests.lua")

describe("GroupEventHandler", function()
    ---@type GroupEventHandler
    local GroupEventHandler
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieComms
    local QuestieComms
    ---@type CommsVisibility
    local CommsVisibility
    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives

    before_each(function()
        _G.GetNumGroupMembers = function() return 2 end

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.numberOfGroupMembers = 2

        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.remoteQuestLogs = {}
        QuestieComms.PruneRemotePlayers = spy.new(function() return false end)
        QuestieComms.RemoveAllRemoteGroupPlayers = spy.new(function() end)
        QuestieComms.ResetAll = spy.new(function() end)

        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.PruneRemotePlayers = spy.new(function() end)
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)
        CommsVisibility.ResetAll = spy.new(function() end)

        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
        QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)
        QuestiePartyObjectives.Clear = spy.new(function() end)

        dofile("Modules/EventHandler/GroupEventHandler.lua")
        GroupEventHandler = QuestieLoader:ImportModule("GroupEventHandler")
    end)

    it("should redraw after a same-size roster replacement prunes a former member", function()
        QuestieComms.PruneRemotePlayers = spy.new(function() return true end)

        GroupEventHandler.GroupRosterUpdate()

        assert.spy(QuestieComms.PruneRemotePlayers).was.called_with(QuestieComms)
        assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "GROUP_ROSTER_UPDATE")
        assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called_with(QuestiePartyObjectives)
    end)

    it("should not redraw for an unchanged roster", function()
        GroupEventHandler.GroupRosterUpdate()

        assert.spy(QuestieComms.PruneRemotePlayers).was.called_with(QuestieComms)
        assert.spy(CommsVisibility.ScheduleSnapshot).was.not_called()
        assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
    end)

    it("should remove only group quest data when the local player leaves", function()
        GroupEventHandler.GroupLeft()

        assert.spy(QuestieComms.RemoveAllRemoteGroupPlayers).was.called_with(QuestieComms)
        assert.spy(QuestieComms.ResetAll).was.not_called()
        assert.spy(CommsVisibility.ResetAll).was.called_with(CommsVisibility)
        assert.spy(QuestiePartyObjectives.Clear).was.called_with(QuestiePartyObjectives)
    end)
end)
