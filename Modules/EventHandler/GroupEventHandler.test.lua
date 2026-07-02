dofile("setupTests.lua")

describe("GroupEventHandler", function()
    ---@type GroupEventHandler
    local GroupEventHandler

    ---@type QuestiePlayer
    local QuestiePlayer

    ---@type QuestieComms
    local QuestieComms

    ---@type CommsPrefixRegistry
    local CommsPrefixRegistry

    ---@type CommsVisibility
    local CommsVisibility

    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives

    local groupMembers

    local function loadGroupEventHandler()
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        CommsPrefixRegistry = QuestieLoader:ImportModule("CommsPrefixRegistry")
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")

        QuestiePlayer.numberOfGroupMembers = 2
        QuestieComms.remoteQuestLogs = {}
        CommsPrefixRegistry.PruneRemotePlayers = spy.new(function() end)
        CommsPrefixRegistry.ScheduleHello = spy.new(function() end)
        CommsPrefixRegistry.ResetAll = spy.new(function() end)
        CommsVisibility.PruneRemotePlayers = spy.new(function() end)
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)
        CommsVisibility.ResetAll = spy.new(function() end)
        QuestieComms.ResetAll = spy.new(function() end)
        QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)
        QuestiePartyObjectives.Clear = spy.new(function() end)

        dofile("Modules/EventHandler/GroupEventHandler.lua")
        GroupEventHandler = QuestieLoader:ImportModule("GroupEventHandler")
    end

    before_each(function()
        groupMembers = 2

        Questie.Debug = function() end
        Questie.SendMessage = spy.new(function() end)
        _G.GetNumGroupMembers = function() return groupMembers end
        _G.UnitIsConnected = function() return true end
        _G.UnitInRaid = function(unit) return unit == "raid1" end
        _G.UnitInParty = function(unit) return unit == "player" or unit == "party1" end
        _G.C_Timer = {
            groupJoinedTickerCallback = nil,
            NewTicker = function(_, callback)
                _G.C_Timer.groupJoinedTickerCallback = callback
                return { Cancel = spy.new(function() end) }
            end,
        }

        loadGroupEventHandler()
    end)

    describe("GroupRosterUpdate", function()
        it("prunes remote players and schedules hello when the group size changes", function()
            groupMembers = 3

            GroupEventHandler.GroupRosterUpdate()

            assert.spy(CommsPrefixRegistry.PruneRemotePlayers).was.called(1)
            assert.spy(CommsVisibility.PruneRemotePlayers).was.called(1)
            assert.spy(CommsPrefixRegistry.ScheduleHello).was.called_with(CommsPrefixRegistry, "GROUP_ROSTER_UPDATE")
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "GROUP_ROSTER_UPDATE")
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called(1)
        end)

        it("does not schedule hello when the group size is unchanged", function()
            GroupEventHandler.GroupRosterUpdate()

            assert.spy(CommsPrefixRegistry.PruneRemotePlayers).was.not_called()
            assert.spy(CommsVisibility.PruneRemotePlayers).was.not_called()
            assert.spy(CommsPrefixRegistry.ScheduleHello).was.not_called()
            assert.spy(CommsVisibility.ScheduleSnapshot).was.not_called()
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)
    end)

    describe("GroupJoined", function()
        it("schedules hello when the group join is confirmed", function()
            GroupEventHandler.GroupJoined()
            _G.C_Timer.groupJoinedTickerCallback()

            assert.spy(CommsPrefixRegistry.ScheduleHello).was.called_with(CommsPrefixRegistry, "GROUP_JOINED")
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "GROUP_JOINED")
            assert.spy(Questie.SendMessage).was.called_with(Questie, "QC_ID_REQUEST_FULL_QUESTLIST")
        end)
    end)

    describe("GroupLeft", function()
        it("resets hello state with the existing group cleanup", function()
            GroupEventHandler.GroupLeft()

            assert.spy(QuestieComms.ResetAll).was.called(1)
            assert.spy(CommsPrefixRegistry.ResetAll).was.called(1)
            assert.spy(CommsVisibility.ResetAll).was.called(1)
            assert.spy(QuestiePartyObjectives.Clear).was.called(1)
        end)
    end)
end)
