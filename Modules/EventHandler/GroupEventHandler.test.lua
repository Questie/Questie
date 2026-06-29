dofile("setupTests.lua")

describe("GroupEventHandler", function()
    ---@type GroupEventHandler
    local GroupEventHandler

    ---@type QuestiePlayer
    local QuestiePlayer

    ---@type QuestieComms
    local QuestieComms

    ---@type CommsHello
    local CommsHello

    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives

    local groupMembers

    local function loadGroupEventHandler()
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        CommsHello = QuestieLoader:ImportModule("CommsHello")
        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")

        QuestiePlayer.numberOfGroupMembers = 2
        QuestieComms.remoteQuestLogs = {}
        CommsHello.PrunePeers = spy.new(function() end)
        CommsHello.ScheduleHello = spy.new(function() end)
        CommsHello.ResetAll = spy.new(function() end)
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
        it("prunes peers and schedules hello when the group size changes", function()
            groupMembers = 3

            GroupEventHandler.GroupRosterUpdate()

            assert.spy(CommsHello.PrunePeers).was.called(1)
            assert.spy(CommsHello.ScheduleHello).was.called_with(CommsHello, "GROUP_ROSTER_UPDATE")
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called(1)
        end)

        it("does not schedule hello when the group size is unchanged", function()
            GroupEventHandler.GroupRosterUpdate()

            assert.spy(CommsHello.PrunePeers).was.not_called()
            assert.spy(CommsHello.ScheduleHello).was.not_called()
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)
    end)

    describe("GroupJoined", function()
        it("schedules hello when the group join is confirmed", function()
            GroupEventHandler.GroupJoined()
            _G.C_Timer.groupJoinedTickerCallback()

            assert.spy(CommsHello.ScheduleHello).was.called_with(CommsHello, "GROUP_JOINED")
            assert.spy(Questie.SendMessage).was.called_with(Questie, "QC_ID_REQUEST_FULL_QUESTLIST")
        end)
    end)

    describe("GroupLeft", function()
        it("resets hello state with the existing group cleanup", function()
            GroupEventHandler.GroupLeft()

            assert.spy(QuestieComms.ResetAll).was.called(1)
            assert.spy(CommsHello.ResetAll).was.called(1)
            assert.spy(QuestiePartyObjectives.Clear).was.called(1)
        end)
    end)
end)
