dofile("setupTests.lua")

local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")

--[[
Harness-level integration coverage for Questie's addon comms emulator.

Protocol behavior lives beside the owning module tests: H1 in
CommsPrefixRegistry.test.lua, V1 in CommsVisibility.test.lua, legacy quest-log
packets in QuestieComms.test.lua, daily `Questie` prefix messages in
Comms.test.lua, and group lifecycle in GroupEventHandler.test.lua.

This file stays focused on the shared fake WoW/AceComm mechanics that those
module-local tests trust.
]]
describe("Comms integration harness", function()
    ---Fails the test if the isolated network cannot settle all timers and AceComm traffic.
    ---@param network table Isolated comms network from AceCommTestHarness.
    local function assertIsolatedNetworkFlushes(network)
        -- Isolated tests should fail loudly if timers/AceComm traffic never
        -- settle; otherwise assertions might pass after only partial delivery.
        assert.is_true(network:FlushUntilIdle())
    end

    it("boots the single-runtime harness path and restores captured state", function()
        local singleHarness = AceCommTestHarness.New()
        singleHarness:InstallWoWClient({
            playerName = "Player",
            realmName = "HomeRealm",
            groupMemberCount = 2,
            partyMembers = {["Friend-Realm"] = true},
        })
        singleHarness:LoadRealAceCommInto(Questie)

        local receivedMessages = {}
        Questie:RegisterComm("SingleT", function(prefix, message, distribution, sender)
            receivedMessages[#receivedMessages + 1] = {
                prefix = prefix,
                message = message,
                distribution = distribution,
                sender = sender,
            }
        end)

        Questie:SendCommMessage("SingleT", "hello party", "PARTY")
        singleHarness:FlushAddonTraffic()
        singleHarness:DeliverAddonMessage({prefix = "SingleT", message = "hello player", distribution = "PARTY"}, "Friend-Realm", "PARTY")

        assert.is_table(singleHarness:FindSentAddonMessage("SingleT", "PARTY"))
        assert.are_same({
            prefix = "SingleT",
            message = "hello player",
            distribution = "PARTY",
            sender = "Friend-Realm",
        }, receivedMessages[1])

        singleHarness:Restore()
    end)

    it("does not share isolated AceComm or Questie module state between clients", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        network:SetParty({alice, bob})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()

        assert.are_not_equal(alice.CommsPrefixRegistry, bob.CommsPrefixRegistry)
        assert.are_not_equal(alice.env.LibStub("AceComm-3.0"), bob.env.LibStub("AceComm-3.0"))
    end)

    it("advances isolated timers deterministically without real waiting", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        network:SetParty({alice})

        alice:LoadModernHelloStack()

        local firedEvents = {}
        alice.env.C_Timer.NewTimer(1, function()
            firedEvents[#firedEvents + 1] = "timer"
        end)
        alice.env.C_Timer.After(2, function()
            firedEvents[#firedEvents + 1] = "after"
        end)
        alice.env.C_Timer.NewTicker(1, function()
            firedEvents[#firedEvents + 1] = "ticker"
        end, 2)

        network:AdvanceTime(0.5)
        assert.are_same({}, firedEvents)

        network:AdvanceTime(0.5)
        assert.are_same({"timer", "ticker"}, firedEvents)

        network:AdvanceTime(1)
        assert.are_same({"timer", "ticker", "after", "ticker"}, firedEvents)
    end)

    it("does not deliver a PARTY broadcast back to the isolated sender", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        local charlie = network:CreateClient({playerName = "Charlie", realmName = "TestRealm"})
        network:SetParty({alice, bob, charlie})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()
        charlie:LoadModernHelloStack()

        local aliceReceivedCount = 0
        local bobReceivedCount = 0
        local charlieReceivedCount = 0
        alice.env.Questie:RegisterComm("NoEcho", function()
            aliceReceivedCount = aliceReceivedCount + 1
        end)
        bob.env.Questie:RegisterComm("NoEcho", function()
            bobReceivedCount = bobReceivedCount + 1
        end)
        charlie.env.Questie:RegisterComm("NoEcho", function()
            charlieReceivedCount = charlieReceivedCount + 1
        end)

        alice.env.Questie:SendCommMessage("NoEcho", "party broadcast", "PARTY")
        assertIsolatedNetworkFlushes(network)

        assert.are_equal(0, aliceReceivedCount)
        assert.are_equal(1, bobReceivedCount)
        assert.are_equal(1, charlieReceivedCount)
    end)

    it("routes an isolated WHISPER to a same-realm short-name target", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        network:SetParty({alice, bob})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()

        local bobReceivedCount = 0
        bob.env.Questie:RegisterComm("ShortWh", function(prefix, message, distribution, sender)
            bobReceivedCount = bobReceivedCount + 1
            assert.are_equal("ShortWh", prefix)
            assert.are_equal("short-name whisper", message)
            assert.are_equal("WHISPER", distribution)
            assert.are_equal("Alice-TestRealm", sender)
        end)

        alice.env.Questie:SendCommMessage("ShortWh", "short-name whisper", "WHISPER", "Bob")
        assertIsolatedNetworkFlushes(network)

        assert.are_equal(1, bobReceivedCount)
    end)

    it("routes an isolated WHISPER only to the exact target", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        local charlie = network:CreateClient({playerName = "Charlie", realmName = "TestRealm"})
        network:SetParty({alice, bob, charlie})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()
        charlie:LoadModernHelloStack()

        local aliceReceivedCount = 0
        local bobReceivedCount = 0
        local charlieReceivedCount = 0
        alice.env.Questie:RegisterComm("WhisperT", function()
            aliceReceivedCount = aliceReceivedCount + 1
        end)
        bob.env.Questie:RegisterComm("WhisperT", function(prefix, message, distribution, sender)
            bobReceivedCount = bobReceivedCount + 1
            assert.are_equal("WhisperT", prefix)
            assert.are_equal("hello bob", message)
            assert.are_equal("WHISPER", distribution)
            assert.are_equal("Alice-TestRealm", sender)
        end)
        charlie.env.Questie:RegisterComm("WhisperT", function()
            charlieReceivedCount = charlieReceivedCount + 1
        end)

        alice.env.Questie:SendCommMessage("WhisperT", "hello bob", "WHISPER", "Bob-TestRealm")
        assertIsolatedNetworkFlushes(network)

        assert.are_equal(0, aliceReceivedCount)
        assert.are_equal(1, bobReceivedCount)
        assert.are_equal(0, charlieReceivedCount)
    end)

    it("drops isolated addon messages when the target did not register the prefix", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        network:SetParty({alice, bob})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()

        local bobRegisteredPrefixCount = 0
        bob.env.Questie:RegisterComm("Expected", function()
            bobRegisteredPrefixCount = bobRegisteredPrefixCount + 1
        end)

        alice.env.Questie:SendCommMessage("Dropped", "bob has no Dropped receiver", "PARTY")
        assertIsolatedNetworkFlushes(network)

        -- The network records the send, but the fake WoW boundary must drop it
        -- before Bob's AceComm callback because Bob never registered the prefix.
        assert.are_equal(0, bobRegisteredPrefixCount)
        assert.are_equal("Dropped", network.trace[1].prefix)
    end)

    it("rejects isolated PARTY sends from clients outside the party topology", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        local stranger = network:CreateClient({playerName = "Stranger", realmName = "TestRealm"})
        network:SetParty({alice, bob})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()
        stranger:LoadModernHelloStack()

        local bobReceivedCount = 0
        bob.env.Questie:RegisterComm("PartyOnly", function()
            bobReceivedCount = bobReceivedCount + 1
        end)

        local sendResult = stranger.env.C_ChatInfo.SendAddonMessage("PartyOnly", "not really party", "PARTY")
        assertIsolatedNetworkFlushes(network)

        assert.are_equal(stranger.env.Enum.SendAddonMessageResult.NotInGroup, sendResult)
        assert.are_equal(0, #network.trace)
        assert.are_equal(0, bobReceivedCount)
    end)

    it("does not deliver isolated addon messages to disconnected targets", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        network:SetParty({alice, bob})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()

        local bobReceivedCount = 0
        bob.env.Questie:RegisterComm("ConnectedOnly", function()
            bobReceivedCount = bobReceivedCount + 1
        end)
        network:SetConnected(bob, false)

        local sendResult = alice.env.C_ChatInfo.SendAddonMessage("ConnectedOnly", "bob is offline", "PARTY")
        assertIsolatedNetworkFlushes(network)

        assert.are_equal(alice.env.Enum.SendAddonMessageResult.Success, sendResult)
        assert.are_equal(1, #network.trace)
        assert.are_equal(0, bobReceivedCount)
    end)

    it("rejects invalid isolated addon prefix and payload values before queueing", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        network:SetParty({alice})

        alice:LoadModernHelloStack()

        assert.is_false(alice.env.C_ChatInfo.RegisterAddonMessagePrefix(""))
        assert.are_equal(alice.env.Enum.SendAddonMessageResult.InvalidPrefix, alice.env.C_ChatInfo.SendAddonMessage(nil, "message", "PARTY"))
        assert.are_equal(alice.env.Enum.SendAddonMessageResult.InvalidPrefix, alice.env.C_ChatInfo.SendAddonMessage("", "message", "PARTY"))
        assert.are_equal(alice.env.Enum.SendAddonMessageResult.InvalidPrefix, alice.env.C_ChatInfo.SendAddonMessage("PrefixLongerThan16", "message", "PARTY"))
        assert.are_equal(alice.env.Enum.SendAddonMessageResult.InvalidMessage, alice.env.C_ChatInfo.SendAddonMessage("Valid", nil, "PARTY"))
        assert.are_equal(alice.env.Enum.SendAddonMessageResult.InvalidMessage, alice.env.C_ChatInfo.SendAddonMessage("Valid", string.rep("x", 256), "PARTY"))
        assertIsolatedNetworkFlushes(network)

        assert.are_equal(0, #network.trace)
    end)

    it("rejects isolated WHISPER sends without a target", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        network:SetParty({alice})

        alice:LoadModernHelloStack()

        local sendResult = alice.env.C_ChatInfo.SendAddonMessage("NeedsTarget", "missing target", "WHISPER")
        assertIsolatedNetworkFlushes(network)

        assert.are_equal(alice.env.Enum.SendAddonMessageResult.TargetRequired, sendResult)
        assert.are_equal(0, #network.trace)
    end)

    it("waits for ChatThrottleLib queues before reporting isolated traffic idle", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        network:SetParty({alice, bob})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()

        local hugeMessage = string.rep("Questie throttled multipart payload ", 650)
        local receivedMessages = {}
        bob.env.Questie:RegisterComm("HugeMsg", function(_, message)
            receivedMessages[#receivedMessages + 1] = message
        end)

        alice.env.Questie:SendCommMessage("HugeMsg", hugeMessage, "PARTY")
        assertIsolatedNetworkFlushes(network)

        assert.are_equal(1, #receivedMessages)
        assert.are_equal(hugeMessage, receivedMessages[1])
        assert.is_true(#network.trace > 10)
        assert.is_false(network:HasPendingAddonTraffic())
    end)

    it("routes and reassembles an isolated multipart AceComm message once", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        network:SetParty({alice, bob})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()

        local longMessage = string.rep("Questie multipart payload ", 40)
        local receivedMessages = {}
        bob.env.Questie:RegisterComm("LongMsg", function(prefix, message, distribution, sender)
            receivedMessages[#receivedMessages + 1] = {
                prefix = prefix,
                message = message,
                distribution = distribution,
                sender = sender,
            }
        end)

        alice.env.Questie:SendCommMessage("LongMsg", longMessage, "PARTY")
        assertIsolatedNetworkFlushes(network)

        -- More than one low-level send proves AceComm chunked the payload; one
        -- receive proves the emulator delivered the chunks through reassembly.
        assert.is_true(#network.trace > 1)
        assert.are_equal(1, #receivedMessages)
        assert.are_same({
            prefix = "LongMsg",
            message = longMessage,
            distribution = "PARTY",
            sender = "Alice-TestRealm",
        }, receivedMessages[1])
    end)
end)
