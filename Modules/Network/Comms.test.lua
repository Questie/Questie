dofile("setupTests.lua")

local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")

--[[
Comms owns the daily `Questie` prefix. Unit tests cover validation and routing
choices; the isolated emulator block uses real AceSerializer and fake group/guild
transport to prove the Questie-owned daily message path end to end.
]]
describe("Comms", function()
    ---@type AvailableQuests
    local AvailableQuests

    ---@type Comms
    local Comms

    ---@type CommsPrefixRegistry
    local CommsPrefixRegistry

    before_each(function()
        Questie.RegisterComm = function() end
        CommsPrefixRegistry = QuestieLoader:ImportModule("CommsPrefixRegistry")
        CommsPrefixRegistry.RegisterLocalPrefix = spy.new(function() return true end)
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.RemoveQuestsForToday = spy.new(function() end)

        dofile("Modules/Network/Comms.lua")
        Comms = QuestieLoader:ImportModule("Comms")
        Comms.Initialize()
    end)

    describe("Initialize", function()
        it("marks the daily quest comm prefix active for hello", function()
            assert.spy(CommsPrefixRegistry.RegisterLocalPrefix).was.called_with(CommsPrefixRegistry, "Questie")
        end)
    end)

    describe("OnCommReceived", function()
        it("should handle HideDailyQuests event", function()
            local npcId = 1234
            local questIds = {5678, 91011}

            ---@type CommEvent
            local event = {
                eventName = "HideDailyQuests",
                data = {
                    npcId = npcId,
                    questIds = questIds
                }
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(npcId, questIds)
        end)

        it("should reject unknown prefixes", function()
            Questie.Deserialize = spy.new(function() end)

            Comms.OnCommReceived("Unknown", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(Questie.Deserialize).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject own HideDailyQuests events", function()
            Questie.Deserialize = spy.new(function() end)

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", UnitName("player"))

            assert.spy(Questie.Deserialize).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject own HideDailyQuests events when sender is in realm format", function()
            Questie.Deserialize = spy.new(function() end)

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", UnitName("player") .. "-" .. GetRealmName())

            assert.spy(Questie.Deserialize).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject malformed HideDailyQuests events", function()
            Questie.Deserialize = function() return false, nil end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events when they are not a table", function()
            Questie.Deserialize = function() return true, 123 end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events without data", function()
            local event = {
                eventName = "HideDailyQuests"
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events when data is not a table", function()
            local event = {
                eventName = "HideDailyQuests",
                data = 123,
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events without npcId", function()
            local questIds = {5678, 91011}

            ---@type CommEvent
            local event = {
                eventName = "HideDailyQuests",
                data = {
                    questIds = questIds
                }
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events without questIds", function()
            local npcId = 1234

            ---@type CommEvent
            local event = {
                eventName = "HideDailyQuests",
                data = {
                    npcId = npcId
                }
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events when questIds is not a table", function()
            local npcId = 1234

            ---@type CommEvent
            local event = {
                eventName = "HideDailyQuests",
                data = {
                    npcId = npcId,
                    questIds = "notATable"
                }
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)
    end)

    describe("BroadcastUnavailableDailyQuests", function()
        it("should broadcast to guild", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "GUILD")
        end)

        it("should broadcast only to party when in a party and not in a guild", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "PARTY")
        end)

        it("should broadcast only to raid when in a raid and not in a guild", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "RAID")
        end)

        it("should broadcast to guild and raid when in a raid", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "GUILD")
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "RAID")
        end)

        it("should broadcast to guild and party when in a party", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "GUILD")
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "PARTY")
        end)

        it("should not broadcast when not in a guild, raid or party", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)
    end)

    describe("isolated daily Questie emulator", function()
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

        ---Finds the largest low-level AceComm payload sent for one prefix.
        ---@param client table Isolated client under inspection.
        ---@param prefix string Addon prefix to inspect.
        ---@return integer maxLength Longest sent message length.
        ---@return integer matchingMessageCount Number of matching sends.
        local function findMaxSentMessageLength(client, prefix)
            local maxLength = 0
            local matchingMessageCount = 0
            for _, message in ipairs(client.sentAddonMessages) do
                if message.prefix == prefix then
                    matchingMessageCount = matchingMessageCount + 1
                    maxLength = math.max(maxLength, string.len(message.message))
                end
            end

            return maxLength, matchingMessageCount
        end

        it("initializes daily Questie prefix and advertises it through QuestieH1", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadDailyCommsStack()
            bob:LoadDailyCommsStack()

            assert.is_true(alice.registeredAddonPrefixes.Questie)

            alice.CommsPrefixRegistry:ScheduleHello("daily prefix advertisement")
            assertIsolatedNetworkFlushes(network)

            assert.is_true(bob.CommsPrefixRegistry:AcceptsPrefix("Alice-TestRealm", "Questie"))
            assert.is_true(bob.CommsPrefixRegistry:AcceptsPrefix("Alice-TestRealm", "QuestieH1"))
        end)

        it("broadcasts unavailable daily quests to party members", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadDailyCommsStack()
            bob:LoadDailyCommsStack()

            alice.Comms.BroadcastUnavailableDailyQuests(7001, {8001, 8002})
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(1, countIsolatedSentAddonMessages(alice, "Questie", "PARTY"))
            assert.are_equal(1, #bob.dailyQuestRemovals)
            assert.are_same({npcId = 7001, questIds = {8001, 8002}}, bob.dailyQuestRemovals[1])
        end)

        it("broadcasts unavailable daily quests to raid members", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetRaid({alice, bob})

            alice:LoadDailyCommsStack()
            bob:LoadDailyCommsStack()

            alice.Comms.BroadcastUnavailableDailyQuests(7002, {8003})
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(1, countIsolatedSentAddonMessages(alice, "Questie", "RAID"))
            assert.are_equal(1, #bob.dailyQuestRemovals)
            assert.are_same({npcId = 7002, questIds = {8003}}, bob.dailyQuestRemovals[1])
        end)

        it("broadcasts unavailable daily quests to guild members", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetGuild({alice, bob})

            alice:LoadDailyCommsStack()
            bob:LoadDailyCommsStack()

            alice.Comms.BroadcastUnavailableDailyQuests(7003, {8004, 8005})
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(1, countIsolatedSentAddonMessages(alice, "Questie", "GUILD"))
            assert.are_equal(1, #bob.dailyQuestRemovals)
            assert.are_same({npcId = 7003, questIds = {8004, 8005}}, bob.dailyQuestRemovals[1])
        end)

        it("broadcasts unavailable daily quests to both guild and party when both apply", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetGuild({alice, bob})
            network:SetParty({alice, bob})

            alice:LoadDailyCommsStack()
            bob:LoadDailyCommsStack()

            alice.Comms.BroadcastUnavailableDailyQuests(7004, {8006})
            assertIsolatedNetworkFlushes(network)

            -- Production Comms.lua sends to guild first, then the current group.
            -- The emulator preserves that duplicate-delivery behavior instead of
            -- deduplicating it in the test harness.
            assert.are_equal(1, countIsolatedSentAddonMessages(alice, "Questie", "GUILD"))
            assert.are_equal(1, countIsolatedSentAddonMessages(alice, "Questie", "PARTY"))
            assert.are_equal(2, #bob.dailyQuestRemovals)
            assert.are_same({npcId = 7004, questIds = {8006}}, bob.dailyQuestRemovals[1])
            assert.are_same({npcId = 7004, questIds = {8006}}, bob.dailyQuestRemovals[2])
        end)

        -- Required guardrail: NPC 58646 currently gives a realistic high-count
        -- daily payload that should remain a single AceComm message.
        it("keeps a realistic high-count daily Questie payload within the single-message limit", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadDailyCommsStack()
            bob:LoadDailyCommsStack()

            local dailyQuestIds = {
                31943, 31942, 31941, 31675, 31674,
                31673, 31672, 31671, 31670, 31669,
                30337, 30336, 30335, 30334, 30333,
            }
            alice.Comms.BroadcastUnavailableDailyQuests(58646, dailyQuestIds)
            assertIsolatedNetworkFlushes(network)

            local maxMessageLength, questieMessageCount = findMaxSentMessageLength(alice, "Questie")
            assert.are_equal(1, questieMessageCount)
            -- Upper bound protects addon-channel correctness. Lower bound protects
            -- the test fixture: this DB-derived daily set should stay a near-limit
            -- stress case unless a deliberate serializer/compression improvement changes it.
            assert.is_true(maxMessageLength >= 200)
            assert.is_true(maxMessageLength <= 255)
            assert.are_equal(1, #bob.dailyQuestRemovals)
            assert.are_same({npcId = 58646, questIds = dailyQuestIds}, bob.dailyQuestRemovals[1])
        end)

        it("ignores daily Questie messages from self", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})

            bob:LoadDailyCommsStack()

            local serializedEvent = bob.env.Questie:Serialize({
                eventName = "HideDailyQuests",
                data = {
                    npcId = 7005,
                    questIds = {8007},
                },
            })
            bob.env.Questie:SendCommMessage("Questie", serializedEvent, "WHISPER", "Bob-TestRealm")
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(0, #bob.dailyQuestRemovals)
        end)

        it("ignores malformed daily Questie messages", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadDailyCommsStack()
            bob:LoadDailyCommsStack()

            alice.env.Questie:SendCommMessage("Questie", "not an AceSerializer event", "PARTY")
            assertIsolatedNetworkFlushes(network)

            assert.are_equal(0, #bob.dailyQuestRemovals)
        end)
    end)

end)
