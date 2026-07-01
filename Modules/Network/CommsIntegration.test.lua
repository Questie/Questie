dofile("setupTests.lua")

local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")

--[[
Single-runtime integration coverage for Questie's modern addon comms layer.

This suite uses real AceComm/AceEvent/ChatThrottleLib through an opt-in fake WoW
client boundary. Keep QuestieH1/QuestieV1 behavior visible here; the shared
harness owns only reusable client/Ace mechanics.

Legacy Questie prefixes ("questie", "Questie", "REPUTABLE") are future extension
points for this harness; these tests focus on the newer typed-prefix protocols.
]]
describe("Comms integration", function()
    ---@type CommsPrefixRegistry
    local CommsPrefixRegistry

    ---@type CommsVisibility
    local CommsVisibility

    ---@type QuestiePlayer
    local QuestiePlayer

    ---@type QuestLogCache
    local QuestLogCache

    ---@type QuestieQuest
    local QuestieQuest

    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives

    ---@type QuestieComms
    local QuestieComms

    ---@type GroupEventHandler
    local GroupEventHandler

    local harness
    local fullQuestLogRequestCount

    local function installQuestieLoggingBoundary()
        Questie.Debug = function() end
        Questie.Error = function(_, message)
            error(message)
        end
    end

    local function installQuestStateBoundary()
        Questie.db.char = {hidden = {}}
        Questie.db.profile = {}

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetGroupType = function() return "party" end

        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.IsQuestTracked = function(_, questId)
            return questId ~= 202
        end

        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
        QuestiePartyObjectives.scheduleUpdateCount = 0
        QuestiePartyObjectives.clearCount = 0
        QuestiePartyObjectives.ScheduleUpdate = function()
            QuestiePartyObjectives.scheduleUpdateCount = QuestiePartyObjectives.scheduleUpdateCount + 1
        end
        QuestiePartyObjectives.Clear = function()
            QuestiePartyObjectives.clearCount = QuestiePartyObjectives.clearCount + 1
        end

        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.remoteQuestLogs = {}
        QuestieComms.resetAllCount = 0
        QuestieComms.ResetAll = function()
            QuestieComms.resetAllCount = QuestieComms.resetAllCount + 1
            QuestieComms.remoteQuestLogs = {}
        end

        fullQuestLogRequestCount = 0
        Questie:RegisterMessage("QC_ID_REQUEST_FULL_QUESTLIST", function()
            fullQuestLogRequestCount = fullQuestLogRequestCount + 1
        end)
    end

    local function loadModernCommsStack()
        dofile("Modules/Network/CommsEncoding.lua")
        dofile("Modules/Network/CommsRouting.lua")
        dofile("Modules/Network/CommsPrefixRegistry.lua")
        dofile("Modules/Network/CommsVisibility.lua")
        dofile("Modules/EventHandler/GroupEventHandler.lua")

        CommsPrefixRegistry = QuestieLoader:ImportModule("CommsPrefixRegistry")
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        GroupEventHandler = QuestieLoader:ImportModule("GroupEventHandler")

        CommsPrefixRegistry:Initialize()
        CommsVisibility:Initialize()
        CommsPrefixRegistry:ResetAll()
        CommsVisibility:ResetAll()

        Questie:RegisterEvent("GROUP_JOINED", GroupEventHandler.GroupJoined)
        Questie:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, GroupEventHandler.GroupRosterUpdate)
        Questie:RegisterEvent("GROUP_LEFT", GroupEventHandler.GroupLeft)
    end

    local function initializeHarness()
        harness = AceCommTestHarness.New()
        harness:InstallWoWClient({
            clock = 100,
            playerName = "Player",
            realmName = "HomeRealm",
            groupMemberCount = 2,
            partyMembers = {["Friend-Realm"] = true},
            raidMembers = {},
        })
        harness:LoadRealAceCommInto(Questie)
        harness:InstallBlizzardDeflateCompression()

        installQuestieLoggingBoundary()
        installQuestStateBoundary()
        loadModernCommsStack()
    end

    local function countSentAddonMessages(prefix, distribution, target)
        local count = 0
        for _, message in ipairs(harness.sentAddonMessages) do
            if message.prefix == prefix
                and (not distribution or message.distribution == distribution)
                and (target == nil or message.target == target)
            then
                count = count + 1
            end
        end

        return count
    end

    before_each(function()
        initializeHarness()
    end)

    after_each(function()
        harness:Restore()
    end)

    it("bootstraps the modern Questie comm prefixes through real AceComm", function()
        assert.is_true(harness.registeredAddonPrefixes.QuestieH1)
        assert.is_true(harness.registeredAddonPrefixes.QuestieV1)
    end)

    it("uses GROUP_JOINED as the first layer for modern comm convergence", function()
        QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
        harness:SetGroupRoster({
            groupMemberCount = 2,
            partyMembers = {
                ["player"] = true,
                ["party1"] = true,
                ["Friend-Realm"] = true,
            },
            raidMembers = {},
        })

        harness:FireWoWEvent("GROUP_JOINED")
        harness:RunTimers() -- GroupEventHandler's join ticker schedules the comm timers.
        harness:RunTimers() -- The scheduled QuestieH1/QuestieV1 timers build and send addon messages.
        harness:FlushAddonTraffic()

        assert.is_table(harness:FindSentAddonMessage("QuestieH1", "PARTY"))
        assert.is_table(harness:FindSentAddonMessage("QuestieV1", "PARTY"))
        assert.are_equal(1, fullQuestLogRequestCount)
    end)

    it("uses GROUP_ROSTER_UPDATE as the first layer for modern comm resync", function()
        QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
        QuestiePlayer.numberOfGroupMembers = 1
        harness:SetGroupRoster({
            groupMemberCount = 2,
            partyMembers = {["Friend-Realm"] = true},
            raidMembers = {},
        })

        harness:FireWoWEvent("GROUP_ROSTER_UPDATE")
        harness:RunTimers() -- AceBucket dispatches GroupEventHandler and schedules comm timers.
        harness:RunTimers() -- The scheduled QuestieH1/QuestieV1 timers build and send addon messages.
        harness:FlushAddonTraffic()

        assert.is_table(harness:FindSentAddonMessage("QuestieH1", "PARTY"))
        assert.is_table(harness:FindSentAddonMessage("QuestieV1", "PARTY"))
        assert.are_equal(1, QuestiePartyObjectives.scheduleUpdateCount)
        assert.are_equal(2, QuestiePlayer.numberOfGroupMembers)
    end)

    it("uses GROUP_ROSTER_UPDATE to resync when a quest-sharing member changes online status", function()
        QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
        QuestieComms.remoteQuestLogs = {[101] = {["Friend-Realm"] = {}}}
        QuestiePlayer.numberOfGroupMembers = 2
        harness:SetGroupRoster({
            groupMemberCount = 2,
            partyMembers = {["Friend-Realm"] = true},
            raidMembers = {},
            connectedMembers = {["Friend-Realm"] = true},
        })

        -- First roster event establishes GroupEventHandler's online-status snapshot.
        harness:FireWoWEvent("GROUP_ROSTER_UPDATE")
        harness:RunTimers() -- AceBucket dispatches GroupEventHandler and schedules comm timers.
        harness:RunTimers() -- The scheduled QuestieH1/QuestieV1 timers build and send addon messages.
        harness:FlushAddonTraffic()

        assert.are_equal(1, countSentAddonMessages("QuestieH1", "PARTY"))
        assert.are_equal(1, countSentAddonMessages("QuestieV1", "PARTY"))
        assert.are_equal(1, QuestiePartyObjectives.scheduleUpdateCount)

        -- Same group size and same online state should not resync. Zone changes can also fire
        -- GROUP_ROSTER_UPDATE, and those must not churn comms or party-objective redraws.
        harness:FireWoWEvent("GROUP_ROSTER_UPDATE")
        harness:RunTimers()
        harness:RunTimers()
        harness:FlushAddonTraffic()

        assert.are_equal(1, countSentAddonMessages("QuestieH1", "PARTY"))
        assert.are_equal(1, countSentAddonMessages("QuestieV1", "PARTY"))
        assert.are_equal(1, QuestiePartyObjectives.scheduleUpdateCount)

        harness:SetGroupRoster({
            groupMemberCount = 2,
            partyMembers = {["Friend-Realm"] = true},
            raidMembers = {},
            connectedMembers = {["Friend-Realm"] = false},
        })
        harness:FireWoWEvent("GROUP_ROSTER_UPDATE")
        harness:RunTimers() -- AceBucket dispatches GroupEventHandler and schedules comm timers.
        harness:RunTimers() -- The scheduled QuestieH1/QuestieV1 timers build and send addon messages.
        harness:FlushAddonTraffic()

        assert.are_equal(2, countSentAddonMessages("QuestieH1", "PARTY"))
        assert.are_equal(2, countSentAddonMessages("QuestieV1", "PARTY"))
        assert.are_equal(2, QuestiePartyObjectives.scheduleUpdateCount)
    end)

    it("uses GROUP_LEFT as the first layer for comm state cleanup", function()
        local craftedHello = harness:BuildEncodedAddonMessage("QuestieH1", {QuestieH1 = true, QuestieV1 = true})
        local hiddenSnapshot = harness:BuildEncodedAddonMessage("QuestieV1", {[101] = false})

        harness:DeliverAddonMessage(craftedHello, "Friend-Realm", "PARTY")
        harness:DeliverAddonMessage(hiddenSnapshot, "Friend-Realm", "PARTY")

        assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieH1"))
        assert.is_false(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 101))

        local helloMessagesBeforeLeave = countSentAddonMessages("QuestieH1")
        local visibilityMessagesBeforeLeave = countSentAddonMessages("QuestieV1")
        CommsPrefixRegistry:ScheduleHello("integration-test")
        CommsVisibility:ScheduleSnapshot("integration-test")

        harness:FireWoWEvent("GROUP_LEFT")
        harness:RunTimers()
        harness:FlushAddonTraffic()

        assert.are_equal(1, QuestieComms.resetAllCount)
        assert.are_equal(1, QuestiePartyObjectives.clearCount)
        assert.is_false(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieH1"))
        assert.is_true(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 101))
        assert.are_equal(helloMessagesBeforeLeave, countSentAddonMessages("QuestieH1"))
        assert.are_equal(visibilityMessagesBeforeLeave, countSentAddonMessages("QuestieV1"))
    end)

    it("round-trips a QuestieH1 hello through real AceComm and replies directly to the grouped sender", function()
        CommsPrefixRegistry:ScheduleHello("integration-test")
        harness:RunTimers()
        harness:FlushAddonTraffic()

        local broadcastHello = harness:FindSentAddonMessage("QuestieH1", "PARTY")
        assert.is_table(broadcastHello)

        harness:DeliverAddonMessage(broadcastHello, "Friend-Realm", "PARTY")

        assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieH1"))
        assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieV1"))
        assert.is_false(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "questie"))

        local reply = harness:FindSentAddonMessage("QuestieH1", "WHISPER", "Friend-Realm")
        assert.is_table(reply)
    end)

    it("round-trips a QuestieV1 visibility snapshot and updates party objective visibility", function()
        Questie.db.char.hidden = {[303] = true}
        QuestLogCache.questLog_DO_NOT_MODIFY = {
            [101] = true,
            [202] = true,
            [303] = true,
        }

        CommsVisibility:ScheduleSnapshot("integration-test")
        harness:RunTimers()
        harness:FlushAddonTraffic()

        local broadcastSnapshot = harness:FindSentAddonMessage("QuestieV1", "PARTY")
        assert.is_table(broadcastSnapshot)

        harness:DeliverAddonMessage(broadcastSnapshot, "Friend-Realm", "PARTY")

        assert.is_true(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 101))
        assert.is_false(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 202))
        assert.is_false(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 303))
        assert.is_true(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 404))
        assert.are_equal(1, QuestiePartyObjectives.scheduleUpdateCount)
    end)

    it("ignores QuestieV1 snapshots from senders outside the group trust boundary", function()
        QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
        QuestieQuest.IsQuestTracked = function() return false end

        CommsVisibility:ScheduleSnapshot("integration-test")
        harness:RunTimers()
        harness:FlushAddonTraffic()

        local broadcastSnapshot = harness:FindSentAddonMessage("QuestieV1", "PARTY")
        assert.is_table(broadcastSnapshot)

        harness:SetGroupRoster({
            groupMemberCount = 2,
            partyMembers = {},
            raidMembers = {},
        })
        harness:DeliverAddonMessage(broadcastSnapshot, "Stranger-Realm", "PARTY")

        assert.is_true(CommsVisibility:ShouldShowPartyObjective("Stranger-Realm", 101))
        assert.are_equal(0, QuestiePartyObjectives.scheduleUpdateCount)
    end)

    it("sanitizes crafted QuestieH1 payloads from grouped senders", function()
        local craftedHello = harness:BuildEncodedAddonMessage("QuestieH1", {
            QuestieH1 = true,
            QuestieV1 = false,
            questie = "yes",
            Questie = true,
            REPUTABLE = false,
            QuestieZ9 = true,
        })

        harness:DeliverAddonMessage(craftedHello, "Friend-Realm", "PARTY")

        assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieH1"))
        assert.is_true(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "QuestieV1"))
        assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "Questie"))
        assert.is_true(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "REPUTABLE"))
        assert.is_false(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "questie"))
        assert.is_false(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "questie"))
        assert.is_false(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieZ9"))
        assert.is_false(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "QuestieZ9"))
        assert.are_equal(1, countSentAddonMessages("QuestieH1", "WHISPER", "Friend-Realm"))
    end)

    it("stores whispered QuestieH1 payloads without replying", function()
        local craftedHello = harness:BuildEncodedAddonMessage("QuestieH1", {
            QuestieH1 = true,
            QuestieV1 = true,
        }, "WHISPER")

        harness:DeliverAddonMessage(craftedHello, "Friend-Realm", "WHISPER")

        assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieH1"))
        assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieV1"))
        assert.are_equal(0, countSentAddonMessages("QuestieH1", "WHISPER", "Friend-Realm"))
    end)

    it("ignores malformed QuestieH1 payloads", function()
        harness:DeliverAddonMessage({prefix = "QuestieH1", message = "not-addon-channel-data", distribution = "PARTY"}, "Friend-Realm", "PARTY")

        assert.is_false(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieH1"))
        assert.is_false(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "QuestieH1"))
        assert.are_equal(0, countSentAddonMessages("QuestieH1", "WHISPER", "Friend-Realm"))
    end)

    it("does not send QuestieV1 visibility snapshots in larger groups", function()
        QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
        harness:SetGroupRoster({groupMemberCount = 6})

        CommsVisibility:ScheduleSnapshot("integration-test")
        harness:RunTimers()
        harness:FlushAddonTraffic()

        assert.is_nil(harness:FindSentAddonMessage("QuestieV1", "PARTY"))
    end)

    it("replaces QuestieV1 visibility with each full remote snapshot", function()
        local hiddenSnapshot = harness:BuildEncodedAddonMessage("QuestieV1", {[101] = false})
        harness:DeliverAddonMessage(hiddenSnapshot, "Friend-Realm", "PARTY")

        assert.is_false(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 101))
        assert.are_equal(1, QuestiePartyObjectives.scheduleUpdateCount)

        local replacementSnapshot = harness:BuildEncodedAddonMessage("QuestieV1", {[202] = true})
        harness:DeliverAddonMessage(replacementSnapshot, "Friend-Realm", "PARTY")

        assert.is_true(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 101))
        assert.is_true(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 202))
        assert.are_equal(2, QuestiePartyObjectives.scheduleUpdateCount)
    end)

    it("ignores malformed QuestieV1 payloads", function()
        harness:DeliverAddonMessage({prefix = "QuestieV1", message = "not-addon-channel-data", distribution = "PARTY"}, "Friend-Realm", "PARTY")

        assert.is_true(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 101))
        assert.are_equal(0, QuestiePartyObjectives.scheduleUpdateCount)
    end)

    it("round-trips QuestieH1 between two isolated clients", function()
        local network = AceCommTestHarness.NewIsolatedNetwork()
        local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
        local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
        network:SetParty({alice, bob})

        alice:LoadModernHelloStack()
        bob:LoadModernHelloStack()

        assert.are_not_equal(alice.CommsPrefixRegistry, bob.CommsPrefixRegistry)
        assert.are_not_equal(alice.env.LibStub("AceComm-3.0"), bob.env.LibStub("AceComm-3.0"))

        alice.CommsPrefixRegistry:ScheduleHello("integration-test")
        network:Flush()

        assert.is_true(bob.CommsPrefixRegistry:AcceptsPrefix("Alice-TestRealm", "QuestieH1"))
        assert.is_true(alice.CommsPrefixRegistry:AcceptsPrefix("Bob-TestRealm", "QuestieH1"))
        assert.are_equal(2, #network.trace)
        assert.are_same({
            sender = "Alice-TestRealm",
            prefix = "QuestieH1",
            distribution = "PARTY",
        }, network.trace[1])
        assert.are_same({
            sender = "Bob-TestRealm",
            prefix = "QuestieH1",
            distribution = "WHISPER",
            target = "Alice-TestRealm",
        }, network.trace[2])
    end)
end)
