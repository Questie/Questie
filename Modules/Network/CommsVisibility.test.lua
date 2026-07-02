dofile("setupTests.lua")

local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")

--[[
CommsVisibility owns QuestieV1: local visibility snapshot policy, receive-side
sanitization, party-objective visibility state, V1 emulator round-trips, and V1
payload guardrails. Encoding helpers are used only to exercise the V1-owned
payload shape.
]]
describe("CommsVisibility", function()
    ---@type CommsVisibility
    local CommsVisibility

    ---@type QuestiePlayer
    local QuestiePlayer

    ---@type QuestLogCache
    local QuestLogCache

    ---@type QuestieQuest
    local QuestieQuest

    ---@type CommsPrefixRegistry
    local CommsPrefixRegistry

    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives

    ---@type QuestieComms
    local QuestieComms

    ---@type CommsEncoding
    local CommsEncoding

    local serializedPayload

    local function setupCodec(decodedPayload)
        CommsEncoding.HasCodecSupport = spy.new(function() return true end)
        CommsEncoding.EncodePayload = spy.new(function(_, payload)
            serializedPayload = payload
            return "wire"
        end)
        CommsEncoding.DecodePayload = spy.new(function()
            return decodedPayload
        end)
    end

    local function loadCommsVisibility(decodedPayload)
        serializedPayload = nil

        Questie.RegisterComm = spy.new(function() end)
        Questie.SendCommMessage = spy.new(function() end)
        Questie.Debug = function() end
        Questie.db.char = {hidden = {}}
        Questie.db.profile = {}

        _G.GetTime = function() return 123 end
        _G.wipe = function(t)
            for k in pairs(t) do
                t[k] = nil
            end
        end
        _G.UnitName = function() return "Player" end
        _G.UnitFullName = function(unit)
            if unit == "player" then
                return "Player", "HomeRealm"
            end
        end
        _G.GetNormalizedRealmName = function() return "HomeRealm" end
        _G.GetRealmName = function() return "HomeRealm" end
        _G.UnitInParty = function(unit) return unit == "Friend-Realm" end
        _G.UnitInRaid = function() return false end
        _G.GetNumGroupMembers = function() return 5 end
        _G.C_Timer = nil

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetGroupType = function() return "party" end

        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.IsQuestTracked = function(_, questId)
            return questId ~= 202
        end

        CommsPrefixRegistry = QuestieLoader:ImportModule("CommsPrefixRegistry")
        CommsPrefixRegistry.RegisterLocalPrefix = spy.new(function() return true end)

        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
        QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)

        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.remoteQuestLogs = {}

        dofile("Modules/Network/CommsEncoding.lua")
        dofile("Modules/Network/CommsRouting.lua")
        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
        setupCodec(decodedPayload or {[101] = true})

        dofile("Modules/Network/CommsVisibility.lua")
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility:ResetAll()
    end

    before_each(function()
        loadCommsVisibility({[101] = true})
    end)

    describe("Initialize", function()
        it("registers QuestieV1 and marks the local prefix active when the codec is available", function()
            local initialized = CommsVisibility:Initialize()

            assert.is_true(initialized)
            assert.spy(Questie.RegisterComm).was.called_with(Questie, "QuestieV1", CommsVisibility.OnCommReceived)
            assert.spy(CommsPrefixRegistry.RegisterLocalPrefix).was.called_with(CommsPrefixRegistry, "QuestieV1")
        end)

        it("does not register when modern payload encoding is unavailable", function()
            CommsEncoding.HasCodecSupport = spy.new(function() return false end)
            dofile("Modules/Network/CommsVisibility.lua")
            CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")

            local initialized = CommsVisibility:Initialize()

            assert.is_false(initialized)
            assert.spy(Questie.RegisterComm).was.not_called()
            assert.spy(CommsPrefixRegistry.RegisterLocalPrefix).was.not_called()
        end)
    end)

    describe("ScheduleSnapshot", function()
        local timers

        local function installTimerMock()
            timers = {}
            _G.C_Timer = {
                NewTimer = spy.new(function(_, callback)
                    local timer = {
                        canceled = false,
                        Cancel = spy.new(function(self)
                            self.canceled = true
                        end),
                    }
                    function timer:Fire()
                        if not self.canceled then
                            callback()
                        end
                    end
                    table.insert(timers, timer)
                    return timer
                end),
            }
        end

        before_each(function()
            installTimerMock()
        end)

        it("sends the full visibility map to party when the debounce timer fires", function()
            Questie.db.char.hidden = {[303] = true}
            QuestLogCache.questLog_DO_NOT_MODIFY = {
                [101] = true,
                [202] = true,
                [303] = true,
                notAQuestId = true,
            }

            CommsVisibility:ScheduleSnapshot("quest-state-changed")

            assert.spy(Questie.SendCommMessage).was.not_called()
            timers[1]:Fire()

            assert.are_same({[101] = true, [202] = false, [303] = false}, serializedPayload)
            assert.spy(CommsEncoding.EncodePayload).was.called(1)
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieV1", "wire", "PARTY")
        end)

        it("uses raid and instance distributions based on the group type", function()
            QuestiePlayer.GetGroupType = function() return "raid" end
            CommsVisibility:ScheduleSnapshot("raid")
            timers[1]:Fire()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieV1", "wire", "RAID")

            Questie.SendCommMessage:clear()
            QuestiePlayer.GetGroupType = function() return "instance" end
            CommsVisibility:ScheduleSnapshot("instance")
            timers[2]:Fire()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieV1", "wire", "INSTANCE_CHAT")
        end)

        it("debounces snapshots until the latest timer fires", function()
            CommsVisibility:ScheduleSnapshot("first")
            CommsVisibility:ScheduleSnapshot("second")

            assert.are_equal(2, #timers)
            assert.spy(timers[1].Cancel).was.called(1)
            timers[1]:Fire()
            assert.spy(Questie.SendCommMessage).was.not_called()

            timers[2]:Fire()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieV1", "wire", "PARTY")
        end)

        it("cancels a queued snapshot on ResetAll", function()
            CommsVisibility:ScheduleSnapshot("test")
            CommsVisibility:ResetAll()
            timers[1]:Fire()

            assert.spy(timers[1].Cancel).was.called(1)
            assert.spy(CommsEncoding.EncodePayload).was.not_called()
            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("clears the timer handle after sending so a later schedule can queue again", function()
            CommsVisibility:ScheduleSnapshot("first")
            timers[1]:Fire()

            CommsVisibility:ScheduleSnapshot("second")

            assert.are_equal(2, #timers)
            timers[2]:Fire()
            assert.spy(Questie.SendCommMessage).was.called(2)
        end)

        it("does not queue a timer in groups too large for party objective pins", function()
            _G.GetNumGroupMembers = function() return 6 end

            CommsVisibility:ScheduleSnapshot("raid")

            assert.are_equal(0, #timers)
            assert.spy(_G.C_Timer.NewTimer).was.not_called()
        end)

        it("does not send if the player is no longer grouped when the timer fires", function()
            CommsVisibility:ScheduleSnapshot("left-group")
            QuestiePlayer.GetGroupType = function() return nil end

            timers[1]:Fire()

            assert.spy(CommsEncoding.EncodePayload).was.not_called()
            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("re-checks the group size when the timer fires", function()
            CommsVisibility:ScheduleSnapshot("raid-conversion")
            _G.GetNumGroupMembers = function() return 6 end

            timers[1]:Fire()

            assert.spy(CommsEncoding.EncodePayload).was.not_called()
            assert.spy(Questie.SendCommMessage).was.not_called()
        end)
    end)

    describe("OnCommReceived", function()
        it("stores only positive integer quest IDs with boolean visibility from grouped senders", function()
            setupCodec({[101] = true, [202] = false, ["303"] = true, [404] = "false", [0] = true, [-1] = true, [1.5] = true})

            CommsVisibility.OnCommReceived("QuestieV1", "wire", "WHISPER", "Friend-Realm")

            assert.are_same({[101] = true, [202] = false}, CommsVisibility.remoteQuestVisibility["Friend-Realm"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called(1)
        end)

        it("caps accepted visibility entries", function()
            local payload = {}
            for questId = 1, 55 do
                payload[questId] = true
            end
            setupCodec(payload)

            CommsVisibility.OnCommReceived("QuestieV1", "wire", "WHISPER", "Friend-Realm")

            local count = 0
            for questId, visible in pairs(CommsVisibility.remoteQuestVisibility["Friend-Realm"]) do
                assert.is_true(questId > 0 and questId % 1 == 0)
                assert.are_equal("boolean", type(visible))
                count = count + 1
            end
            assert.are_equal(50, count)
        end)

        it("rejects messages from self before decoding", function()
            CommsVisibility.OnCommReceived("QuestieV1", "wire", "PARTY", "Player")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsVisibility.remoteQuestVisibility.Player)
        end)

        it("rejects non-group whispers before decoding", function()
            _G.UnitInParty = function() return false end
            _G.UnitInRaid = function() return false end

            CommsVisibility.OnCommReceived("QuestieV1", "wire", "WHISPER", "Stranger-Realm")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsVisibility.remoteQuestVisibility["Stranger-Realm"])
        end)

        it("ignores malformed payloads safely", function()
            CommsEncoding.DecodePayload = spy.new(function() return nil end)

            CommsVisibility.OnCommReceived("QuestieV1", "wire", "WHISPER", "Friend-Realm")

            assert.is_nil(CommsVisibility.remoteQuestVisibility["Friend-Realm"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("does not mutate remoteQuestLogs", function()
            local remoteQuestLogs = {
                [101] = {
                    ["Friend-Realm"] = {{finished = false}},
                },
            }
            QuestieComms.remoteQuestLogs = remoteQuestLogs
            setupCodec({[101] = false})

            CommsVisibility.OnCommReceived("QuestieV1", "wire", "WHISPER", "Friend-Realm")

            assert.are_equal(remoteQuestLogs, QuestieComms.remoteQuestLogs)
            assert.are_same({[101] = { ["Friend-Realm"] = {{finished = false}} }}, QuestieComms.remoteQuestLogs)
        end)
    end)

    describe("ShouldShowPartyObjective", function()
        it("defaults to showing when visibility is unknown", function()
            assert.is_true(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 101))
        end)

        it("returns explicit remote visibility", function()
            CommsVisibility.remoteQuestVisibility["Friend-Realm"] = {[101] = false, [202] = true}

            assert.is_false(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 101))
            assert.is_true(CommsVisibility:ShouldShowPartyObjective("Friend-Realm", 202))
        end)
    end)

    describe("ResetAll and PruneRemotePlayers", function()
        it("clears all remote visibility", function()
            CommsVisibility.remoteQuestVisibility["Friend-Realm"] = {[101] = true}

            CommsVisibility:ResetAll()

            assert.are_same({}, CommsVisibility.remoteQuestVisibility)
        end)

        it("drops remote players that are no longer in the group", function()
            CommsVisibility.remoteQuestVisibility["Friend-Realm"] = {[101] = true}
            CommsVisibility.remoteQuestVisibility["Gone-Realm"] = {[202] = false}
            _G.UnitInParty = function(unit) return unit == "Friend-Realm" end

            CommsVisibility:PruneRemotePlayers()

            assert.are_same({[101] = true}, CommsVisibility.remoteQuestVisibility["Friend-Realm"])
            assert.is_nil(CommsVisibility.remoteQuestVisibility["Gone-Realm"])
        end)
    end)

    describe("isolated QuestieV1 emulator and payload guardrails", function()
        local CONSERVATIVE_SINGLE_MESSAGE_BUDGET = 245
        local LARGEST_REAL_QUEST_IDS = {
            34062, 34061, 34060, 33634, 33603, 33602, 33385, 33379, 33378, 33377,
            33376, 33375, 33374, 33373, 33372, 33371, 33370, 33369, 33368, 33367,
            33366, 33365, 33364, 33363, 33362, 33361, 33360, 33358, 33354, 33348,
            33347, 33346, 33345, 33343, 33342, 33341, 33340, 33338, 33337, 33336,
            33335, 33334, 33333, 33332, 33322, 33321, 33319, 33318, 33317, 33316,
        }
        local LOW_REAL_QUEST_IDS = {
            1, 2, 5, 6, 7, 8, 9, 10, 11, 12,
            13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
            23, 24, 25, 26, 27,
        }

        ---Fails the test if the isolated network cannot settle all timers and AceComm traffic.
        ---@param network table Isolated comms network from AceCommTestHarness.
        local function assertIsolatedNetworkFlushes(network)
            assert.is_true(network:FlushUntilIdle())
        end

        ---Encodes a V1 snapshot through the local emulator codec and returns its final length.
        ---@param questIds number[] Real quest IDs used as snapshot keys.
        ---@return integer length Addon-channel-safe payload length.
        local function estimateVisibilityPayloadLength(questIds)
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            network:SetParty({alice})
            alice:LoadModernCommsStack()

            local snapshot = {}
            for index, questId in ipairs(questIds) do
                snapshot[questId] = index % 2 == 0
            end

            local encodedPayload = alice.CommsEncoding:EncodePayload(snapshot)
            assert.is_not_nil(encodedPayload)
            return string.len(encodedPayload)
        end

        -- Required guardrail: update these real IDs when the database gains larger V1-relevant cases.
        it("keeps a max QuestieV1 snapshot with the largest real quest IDs within the conservative single-message budget", function()
            local estimatedLength = estimateVisibilityPayloadLength(LARGEST_REAL_QUEST_IDS)

            assert.are_equal(50, #LARGEST_REAL_QUEST_IDS)
            assert.is_true(estimatedLength <= CONSERVATIVE_SINGLE_MESSAGE_BUDGET)
        end)

        it("keeps a max QuestieV1 snapshot with mixed real quest ID widths within the conservative single-message budget", function()
            local mixedQuestIds = {}
            for _, questId in ipairs(LOW_REAL_QUEST_IDS) do
                mixedQuestIds[#mixedQuestIds + 1] = questId
            end
            for index = 1, 25 do
                mixedQuestIds[#mixedQuestIds + 1] = LARGEST_REAL_QUEST_IDS[index]
            end

            local estimatedLength = estimateVisibilityPayloadLength(mixedQuestIds)

            assert.are_equal(50, #mixedQuestIds)
            assert.is_true(estimatedLength <= CONSERVATIVE_SINGLE_MESSAGE_BUDGET)
        end)

        it("round-trips QuestieV1 visibility between two isolated clients", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadModernCommsStack()
            bob:LoadModernCommsStack()

            alice.QuestLogCache.questLog_DO_NOT_MODIFY = {
                [101] = true,
                [202] = true,
                [303] = true,
            }
            alice.trackedQuests = {
                [101] = true,
                [202] = false,
                [303] = true,
            }
            alice.env.Questie.db.char.hidden = {[303] = true}

            alice.CommsVisibility:ScheduleSnapshot("integration-test")
            assertIsolatedNetworkFlushes(network)

            assert.is_true(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 101))
            assert.is_false(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 202))
            assert.is_false(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 303))
            assert.is_true(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 404))
            assert.are_equal(1, bob.QuestiePartyObjectives.scheduleUpdateCount)
            assert.is_nil(next(bob.QuestieComms.remoteQuestLogs))
        end)

        it("replaces isolated QuestieV1 visibility with each full snapshot", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadModernCommsStack()
            bob:LoadModernCommsStack()

            alice.QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true, [202] = true}
            alice.trackedQuests = {[101] = false, [202] = false}
            alice.CommsVisibility:ScheduleSnapshot("first snapshot")
            assertIsolatedNetworkFlushes(network)

            assert.is_false(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 101))
            assert.is_false(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 202))

            alice.QuestLogCache.questLog_DO_NOT_MODIFY = {[303] = true}
            alice.trackedQuests = {[303] = true}
            alice.CommsVisibility:ScheduleSnapshot("replacement snapshot")
            assertIsolatedNetworkFlushes(network)

            assert.is_true(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 101))
            assert.is_true(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 202))
            assert.is_true(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 303))
            assert.are_equal(2, bob.QuestiePartyObjectives.scheduleUpdateCount)
        end)

        it("ignores isolated QuestieV1 visibility from senders outside the group trust boundary", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            local stranger = network:CreateClient({playerName = "Stranger", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadModernCommsStack()
            bob:LoadModernCommsStack()
            stranger:LoadModernCommsStack()

            local encodedSnapshot = stranger.CommsEncoding:EncodePayload({[101] = false})
            stranger.env.Questie:SendCommMessage("QuestieV1", encodedSnapshot, "WHISPER", "Bob-TestRealm")
            assertIsolatedNetworkFlushes(network)

            -- WHISPER is a valid transport here, so this assertion protects Bob's
            -- receive-side trust check rather than the harness send validator.
            assert.is_true(bob.CommsVisibility:ShouldShowPartyObjective("Stranger-TestRealm", 101))
            assert.are_equal(0, bob.QuestiePartyObjectives.scheduleUpdateCount)
        end)

        it("does not send isolated QuestieV1 visibility in larger groups", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            local charlie = network:CreateClient({playerName = "Charlie", realmName = "TestRealm"})
            local dora = network:CreateClient({playerName = "Dora", realmName = "TestRealm"})
            local erin = network:CreateClient({playerName = "Erin", realmName = "TestRealm"})
            local finn = network:CreateClient({playerName = "Finn", realmName = "TestRealm"})
            network:SetParty({alice, bob, charlie, dora, erin, finn})

            alice:LoadModernCommsStack()
            bob:LoadModernCommsStack()

            alice.QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true}
            alice.CommsVisibility:ScheduleSnapshot("large group")
            assertIsolatedNetworkFlushes(network)

            for _, sentMessage in ipairs(network.trace) do
                assert.are_not_equal("QuestieV1", sentMessage.prefix)
            end
            assert.is_true(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 101))
        end)

        it("keeps isolated QuestieV1 visibility separate from legacy remoteQuestLogs", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadLegacyQuestieCommsStack()
            bob:LoadLegacyQuestieCommsStack()

            alice.trackedQuests = {[101] = false}
            alice.CommsVisibility:ScheduleSnapshot("legacy separation")
            assertIsolatedNetworkFlushes(network)

            assert.is_false(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 101))
            assert.is_nil(next(bob.QuestieComms.remoteQuestLogs))

            -- V1 and legacy packets intentionally update different state stores:
            -- visibility affects party-objective drawing, while questie packets own
            -- durable remote progress in QuestieComms.remoteQuestLogs.
            alice.QuestieComms.private:BroadcastQuestUpdate(101)
            assertIsolatedNetworkFlushes(network)

            assert.is_table(bob.QuestieComms.remoteQuestLogs[101]["Alice-TestRealm"])
            assert.is_false(bob.CommsVisibility:ShouldShowPartyObjective("Alice-TestRealm", 101))
        end)
    end)

end)
