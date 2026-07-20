dofile("setupTests.lua")

local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")

--[[
GroupEventHandler owns party lifecycle convergence. Unit tests cover direct event
policy; the isolated emulator block proves those same events drive H1, V1, and
legacy full-log request signals through real AceEvent/AceBucket timing.
]]
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
        it("prunes remote players and resends visibility without broadcasting H1 when the group size changes", function()
            groupMembers = 3

            GroupEventHandler.GroupRosterUpdate()

            assert.spy(CommsPrefixRegistry.PruneRemotePlayers).was.called(1)
            assert.spy(CommsVisibility.PruneRemotePlayers).was.called(1)
            assert.spy(CommsPrefixRegistry.ScheduleHello).was.not_called()
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "GROUP_ROSTER_UPDATE")
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called(1)
        end)

        it("prunes modern caches without scheduling comms or a redraw when the roster is unchanged", function()
            GroupEventHandler.GroupRosterUpdate()

            assert.spy(CommsPrefixRegistry.PruneRemotePlayers).was.called(1)
            assert.spy(CommsVisibility.PruneRemotePlayers).was.called(1)
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

    describe("isolated comm lifecycle", function()
        ---Fails the test if the isolated network cannot settle all timers and AceComm traffic.
        ---@param network table Isolated comms network from AceCommTestHarness.
        local function assertIsolatedNetworkFlushes(network)
            assert.is_true(network:FlushUntilIdle())
        end

        ---Counts low-level sends from one isolated client matching the requested envelope fields.
        ---@param client table Isolated client under inspection.
        ---@param prefix string Addon prefix to count.
        ---@param distribution string? Optional AceComm distribution filter.
        ---@param target string? Optional whisper target filter.
        ---@return integer count Matching sent message count.
        local function countIsolatedSentAddonMessages(client, prefix, distribution, target)
            local count = 0
            for _, message in ipairs(client.sentAddonMessages) do
                if message.prefix == prefix
                    and (not distribution or message.distribution == distribution)
                    and (target == nil or message.target == target)
                then
                    count = count + 1
                end
            end

            return count
        end

        it("uses GROUP_JOINED to converge H1, V1, and full quest-log requests", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadModernGroupStack()
            bob:LoadModernGroupStack()

            alice.QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
            alice.trackedQuests = {[101] = false}
            bob.QuestLogCache.questLog_DO_NOT_MODIFY = {[202] = true}
            bob.trackedQuests = {[202] = true}

            network:FireAll("GROUP_JOINED")
            assertIsolatedNetworkFlushes(network)

            -- GROUP_JOINED fans out through the production handler: H1 discovers peers,
            -- V1 shares visibility, and the legacy full-log request is counted but not answered.
            assert.is_true(alice.CommsPrefixRegistry:AcceptsPrefix("Bob-TestRealm", "QuestieH1"))
            assert.is_true(bob.CommsPrefixRegistry:AcceptsPrefix("Alice-TestRealm", "QuestieH1"))
            assert.is_false(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 101))
            assert.is_true(alice.CommsVisibility:ShouldShowPartyObjective("Bob-TestRealm", 202))
            assert.are_equal(1, alice.fullQuestLogRequestCount)
            assert.are_equal(1, bob.fullQuestLogRequestCount)
        end)

        it("uses GROUP_ROSTER_UPDATE to resync V1 without broadcasting H1 when group size changes", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadModernGroupStack()
            bob:LoadModernGroupStack()

            alice.QuestiePlayer.numberOfGroupMembers = 1
            alice.QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}

            alice:FireWoWEvent("GROUP_ROSTER_UPDATE")
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(0, countIsolatedSentAddonMessages(alice, "QuestieH1", "PARTY"))
            assert.are_equal(1, countIsolatedSentAddonMessages(alice, "QuestieV1", "PARTY"))
            assert.are_equal(1, alice.QuestiePartyObjectives.scheduleUpdateCount)
            assert.are_equal(2, alice.QuestiePlayer.numberOfGroupMembers)
        end)

        it("prunes H1/V1-only state after a same-size member replacement without resyncing or redrawing", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            local charlie = network:CreateClient({playerName = "Charlie", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadModernGroupStack()
            bob:LoadModernGroupStack()

            bob.QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
            bob.trackedQuests = {[101] = false}
            bob.CommsPrefixRegistry:ScheduleHello("seed H1-only state")
            bob.CommsVisibility:ScheduleSnapshot("seed V1-only state")
            assertIsolatedNetworkFlushes(network)

            assert.is_true(alice.CommsPrefixRegistry:AcceptsPrefix("Bob-TestRealm", "QuestieH1"))
            assert.is_false(alice.CommsVisibility:ShouldShowPartyObjective("Bob-TestRealm", 101))
            assert.is_nil(next(alice.QuestieComms.remoteQuestLogs))

            alice.QuestiePlayer.numberOfGroupMembers = 2
            local helloMessagesBeforeReplacement = countIsolatedSentAddonMessages(alice, "QuestieH1")
            local visibilityMessagesBeforeReplacement = countIsolatedSentAddonMessages(alice, "QuestieV1")
            local redrawsBeforeReplacement = alice.QuestiePartyObjectives.scheduleUpdateCount
            network:SetParty({alice, charlie})

            alice:FireWoWEvent("GROUP_ROSTER_UPDATE")
            assertIsolatedNetworkFlushes(network)

            assert.is_false(alice.CommsPrefixRegistry:AcceptsPrefix("Bob-TestRealm", "QuestieH1"))
            assert.is_true(alice.CommsVisibility:ShouldShowPartyObjective("Bob-TestRealm", 101))
            assert.are_equal(helloMessagesBeforeReplacement, countIsolatedSentAddonMessages(alice, "QuestieH1"))
            assert.are_equal(visibilityMessagesBeforeReplacement, countIsolatedSentAddonMessages(alice, "QuestieV1"))
            assert.are_equal(redrawsBeforeReplacement, alice.QuestiePartyObjectives.scheduleUpdateCount)
        end)

        it("resyncs V1 on online-status changes without broadcasting H1", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})
            network:SetConnected(bob, true)

            alice:LoadModernGroupStack()
            bob:LoadModernGroupStack()

            alice.QuestieComms.remoteQuestLogs = {[101] = { ["Bob-TestRealm"] = {} }}
            alice.QuestiePlayer.numberOfGroupMembers = 2
            alice.QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}

            alice:FireWoWEvent("GROUP_ROSTER_UPDATE")
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(0, countIsolatedSentAddonMessages(alice, "QuestieH1", "PARTY"))
            assert.are_equal(1, countIsolatedSentAddonMessages(alice, "QuestieV1", "PARTY"))
            assert.are_equal(1, alice.QuestiePartyObjectives.scheduleUpdateCount)

            -- Same size and same online state models a zone-change-like roster event:
            -- Ace fires, but comms and party-objective redraws should stay quiet.
            alice:FireWoWEvent("GROUP_ROSTER_UPDATE")
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(0, countIsolatedSentAddonMessages(alice, "QuestieH1", "PARTY"))
            assert.are_equal(1, countIsolatedSentAddonMessages(alice, "QuestieV1", "PARTY"))
            assert.are_equal(1, alice.QuestiePartyObjectives.scheduleUpdateCount)

            network:SetConnected(bob, false)
            alice:FireWoWEvent("GROUP_ROSTER_UPDATE")
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(0, countIsolatedSentAddonMessages(alice, "QuestieH1", "PARTY"))
            assert.are_equal(2, countIsolatedSentAddonMessages(alice, "QuestieV1", "PARTY"))
            assert.are_equal(2, alice.QuestiePartyObjectives.scheduleUpdateCount)
        end)

        it("uses GROUP_LEFT to reset comm state and cancel pending modern sends", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadModernGroupStack()
            bob:LoadModernGroupStack()

            bob.QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
            bob.trackedQuests = {[101] = false}
            bob.CommsPrefixRegistry:ScheduleHello("seed remote state")
            bob.CommsVisibility:ScheduleSnapshot("seed remote state")
            assertIsolatedNetworkFlushes(network)

            assert.is_true(alice.CommsPrefixRegistry:AcceptsPrefix("Bob-TestRealm", "QuestieH1"))
            assert.is_false(alice.CommsVisibility:ShouldShowPartyObjective("Bob-TestRealm", 101))

            local aliceHelloMessagesBeforeLeave = countIsolatedSentAddonMessages(alice, "QuestieH1")
            local aliceVisibilityMessagesBeforeLeave = countIsolatedSentAddonMessages(alice, "QuestieV1")
            alice.CommsPrefixRegistry:ScheduleHello("pending leave cancellation")
            alice.CommsVisibility:ScheduleSnapshot("pending leave cancellation")

            alice:FireWoWEvent("GROUP_LEFT")
            assertIsolatedNetworkFlushes(network)

            -- GROUP_LEFT must cancel queued H1/V1 timers before FlushUntilIdle advances
            -- fake time far enough for those stale messages to escape.
            assert.are_equal(1, alice.QuestieComms.resetAllCount)
            assert.are_equal(1, alice.QuestiePartyObjectives.clearCount)
            assert.is_false(alice.CommsPrefixRegistry:AcceptsPrefix("Bob-TestRealm", "QuestieH1"))
            assert.is_true(alice.CommsVisibility:ShouldShowPartyObjective("Bob-TestRealm", 101))
            assert.are_equal(aliceHelloMessagesBeforeLeave, countIsolatedSentAddonMessages(alice, "QuestieH1"))
            assert.are_equal(aliceVisibilityMessagesBeforeLeave, countIsolatedSentAddonMessages(alice, "QuestieV1"))
        end)
    end)

end)
