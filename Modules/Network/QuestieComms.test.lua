dofile("setupTests.lua")

local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")

--[[
QuestieComms owns the legacy `questie` packet protocol. The emulator block loads
real QuestieStream, QuestieSerializer, and QuestieComms behind narrow DB/tooltip
fixtures so legacy packet behavior and worst-case chunking stay local to this file.
]]
describe("QuestieComms", function()
    ---@type QuestieComms
    local QuestieComms

    ---@type CommsPrefixRegistry
    local CommsPrefixRegistry

    ---@type CommsVisibility
    local CommsVisibility

    before_each(function()
        Questie.RegisterComm = spy.new(function() end)
        Questie.RegisterMessage = spy.new(function() end)
        Questie.RegisterBucketMessage = spy.new(function() end)

        dofile("Modules/Network/CommsPrefixRegistry.lua")
        CommsPrefixRegistry = QuestieLoader:ImportModule("CommsPrefixRegistry")
        CommsPrefixRegistry.RegisterLocalPrefix = spy.new(function() return true end)

        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)

        dofile("Modules/Network/QuestieComms.lua")
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
    end)

    describe("Initialize", function()
        it("advertises legacy quest sharing while keeping the old REPUTABLE receiver unadvertised", function()
            QuestieComms:Initialize()

            assert.spy(Questie.RegisterComm).was.called_with(Questie, "questie", QuestieComms.private.OnCommReceived)
            assert.spy(Questie.RegisterComm).was.called_with(Questie, "REPUTABLE", QuestieLoader:ImportModule("DailyQuests").FilterDailies)
            assert.spy(CommsPrefixRegistry.RegisterLocalPrefix).was.called(1)
            assert.spy(CommsPrefixRegistry.RegisterLocalPrefix).was.called_with(CommsPrefixRegistry, "questie")
        end)
    end)

    describe("full quest-list requests", function()
        it("schedules a visibility snapshot when responding to another player's full quest-list request", function()
            _G.UnitName = function() return "Player" end
            _G.strsplit = function(_, value) return value:match("^(%d+)%.(%d+)%.(%d+)$") end
            QuestieComms.private.BroadcastQuestLogV2 = spy.new(function() end)

            QuestieComms.private.packets[11].read({
                playerName = "Friend-Realm",
                ver = "6.0.0",
            })

            assert.spy(QuestieComms.private.BroadcastQuestLogV2).was.called_with(QuestieComms.private, "QC_ID_BROADCAST_FULL_QUESTLIST", "WHISPER", "Friend-Realm")
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "QC_ID_REQUEST_FULL_QUESTLIST")
        end)

        it("does not schedule a visibility snapshot for our own full quest-list request echo", function()
            _G.UnitName = function() return "Player" end

            QuestieComms.private.packets[11].read({
                playerName = "Player",
                ver = "6.0.0",
            })

            assert.spy(CommsVisibility.ScheduleSnapshot).was.not_called()
        end)
    end)

    describe("isolated legacy questie emulator", function()
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

        ---Counts map entries without assuming array-like quest IDs.
        ---@param tableToCount table Table whose keys should be counted.
        ---@return integer count Number of keys in the table.
        local function countTableKeys(tableToCount)
            local count = 0
            for _ in pairs(tableToCount) do
                count = count + 1
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

        ---Installs a DB-derived 25-quest log that stresses legacy full-log packets.
        ---The quests/objective IDs are real current Questie data with high objective counts;
        ---the progress values are synthetic because packet size depends on shape, not live progress.
        ---@param client table Isolated legacy client whose quest fixtures should be replaced.
        ---@return table<number, number[]> questObjectiveIds QuestId -> real objective IDs used by the fixture.
        local function installRealisticWorstCaseQuestLog(client)
            local questObjectiveIds = {
                [14106] = {721, 2442, 33935, 13703, 3509, 19222},
                [9246] = {22682, 15408, 7080, 15407, 529, 42000},
                [9243] = {22682, 12810, 7080, 15407, 529, 42000},
                [9236] = {22682, 12359, 12360, 7080, 529, 42000},
                [32317] = {68782, 92494, 92495, 92496, 92497},
                [33161] = {73577, 73576, 73579, 73578},
                [33100] = {71955, 71952, 71953, 71954},
                [32872] = {97530, 97544, 97545, 97543},
                [32862] = {97530, 97544, 97545, 97543},
                [32819] = {97530, 97544, 97545, 97543},
                [32816] = {70981, 71162, 71171, 71194},
                [32811] = {97530, 97543, 97544, 97545},
                [32809] = {71362, 98002, 98003, 98004},
                [32805] = {70924, 70926, 70927, 70928},
                [32588] = {69751, 69752, 69754, 69326},
                [32586] = {69316, 69319, 69320, 69326},
                [32537] = {69693, 69688, 69695, 69697},
                [32492] = {69407, 69408, 69409, 69410},
                [32418] = {68752, 68754, 68753, 68755},
                [32411] = {68711, 68714, 68715, 68716},
                [32330] = {68430, 68086, 68085, 68259},
                [32255] = {69287, 69288, 69290, 69289},
                [32209] = {69357, 69356, 69355, 69326},
                [32208] = {69316, 69319, 69320, 69326},
                [31776] = {65882, 65883, 65880, 65881},
            }

            client.legacyQuestDefinitions = {}
            client.legacyQuestObjectives = {}
            client.QuestieDB.QuestPointers = {}
            client.QuestLogCache.questLog_DO_NOT_MODIFY = {}

            for questId, objectiveIds in pairs(questObjectiveIds) do
                client.QuestieDB.QuestPointers[questId] = true
                client.QuestLogCache.questLog_DO_NOT_MODIFY[questId] = {questTag = "Group"}
                client.legacyQuestDefinitions[questId] = {Objectives = {}}
                client.legacyQuestObjectives[questId] = {}

                for objectiveIndex, objectiveId in ipairs(objectiveIds) do
                    client.legacyQuestDefinitions[questId].Objectives[objectiveIndex] = {Id = objectiveId}
                    client.legacyQuestObjectives[questId][objectiveIndex] = {
                        type = "monster",
                        finished = false,
                        numFulfilled = objectiveIndex,
                        numRequired = objectiveIndex + 5,
                    }
                end
            end

            return questObjectiveIds
        end

        it("initializes the legacy quest-log prefix and advertises it through QuestieH1", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadLegacyQuestieCommsStack()
            bob:LoadLegacyQuestieCommsStack()

            assert.is_true(alice.registeredAddonPrefixes.questie)

            -- QuestieComms:Initialize marks the legacy quest-log receiver active in the
            -- H1 manifest; the hello proves remote clients can discover the packet path.
            alice.CommsPrefixRegistry:ScheduleHello("legacy prefix advertisement")
            assertIsolatedNetworkFlushes(network)

            assert.is_true(bob.CommsPrefixRegistry:AcceptsPrefix("Alice", "questie"))
            assert.is_true(bob.CommsPrefixRegistry:AcceptsPrefix("Alice", "QuestieV1"))
        end)

        it("answers a legacy full quest-list request and stores remote progress", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadLegacyQuestieCommsStack()
            bob:LoadLegacyQuestieCommsStack()

            bob.env.Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
            assertIsolatedNetworkFlushes(network)

            assert.is_true(countIsolatedSentAddonMessages(alice, "questie", "WHISPER", "Bob") >= 1)
            -- The legacy serializer omits false-valued fields, so unfinished quests
            -- arrive with progress counts but no explicit `finished = false` key.
            assert.are_same({
                [1] = {
                    index = 1,
                    id = 9001,
                    type = "m",
                    fulfilled = 1,
                    required = 5,
                },
            }, bob.QuestieComms.remoteQuestLogs[101]["Alice"])
            assert.are_equal(1, #bob.legacyTooltipRegistrations)
            assert.are_equal(101, bob.legacyTooltipRegistrations[1].questId)
            assert.are_equal("Alice", bob.legacyTooltipRegistrations[1].playerName)
        end)

        -- Required guardrail: this DB-derived 25-quest log should move forward
        -- when future data adds a larger realistic legacy quest-log shape.
        it("keeps a realistic worst-case full quest log within AceComm chunk limits", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadLegacyQuestieCommsStack()
            bob:LoadLegacyQuestieCommsStack()
            local questObjectiveIds = installRealisticWorstCaseQuestLog(alice)

            bob.env.Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
            assertIsolatedNetworkFlushes(network)

            local maxChunkLength, questieMessageCount = findMaxSentMessageLength(alice, "questie")
            assert.are_equal(25, countTableKeys(questObjectiveIds))
            assert.are_equal(25, countTableKeys(bob.QuestieComms.remoteQuestLogs))
            for questId in pairs(questObjectiveIds) do
                assert.is_table(bob.QuestieComms.remoteQuestLogs[questId]["Alice"])
            end
            assert.is_true(questieMessageCount > 1)
            -- Upper bound protects addon-channel correctness. Lower bound protects
            -- the test fixture: this DB-derived log should stay a near-limit stress
            -- case unless a deliberate serializer/compression improvement changes it.
            assert.is_true(maxChunkLength >= 240)
            assert.is_true(maxChunkLength <= 255)
        end)

        it("broadcasts legacy quest updates into remoteQuestLogs", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadLegacyQuestieCommsStack()
            bob:LoadLegacyQuestieCommsStack()

            alice.QuestieComms.private:BroadcastQuestUpdate(101)
            assertIsolatedNetworkFlushes(network)

            assert.are_same({
                [1] = {
                    index = 1,
                    id = 9001,
                    type = "m",
                    fulfilled = 1,
                    required = 5,
                },
            }, bob.QuestieComms.remoteQuestLogs[101]["Alice"])
            assert.are_equal(1, #bob.legacyTooltipRegistrations)
        end)

        it("broadcasts legacy quest removes and clears tooltip data", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadLegacyQuestieCommsStack()
            bob:LoadLegacyQuestieCommsStack()

            alice.QuestieComms.private:BroadcastQuestUpdate(101)
            assertIsolatedNetworkFlushes(network)

            assert.is_table(bob.QuestieComms.remoteQuestLogs[101]["Alice"])

            alice.QuestieComms.private:BroadcastQuestRemove(101)
            assertIsolatedNetworkFlushes(network)

            assert.is_nil(bob.QuestieComms.remoteQuestLogs[101]["Alice"])
            assert.are_equal(1, #bob.legacyTooltipRemovals)
            assert.are_same({questId = 101, playerName = "Alice"}, bob.legacyTooltipRemovals[1])
        end)

        it("ignores malformed and incompatible legacy questie payloads", function()
            local network = AceCommTestHarness.NewIsolatedNetwork()
            local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
            local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
            network:SetParty({alice, bob})

            alice:LoadLegacyQuestieCommsStack()
            bob:LoadLegacyQuestieCommsStack()

            alice.env.Questie:SendCommMessage("questie", "not a QuestieSerializer packet", "PARTY")
            assertIsolatedNetworkFlushes(network)

            local incompatiblePacket = alice.QuestieSerializer:Serialize({
                ver = "6.0.0",
                msgVer = 6.0,
                msgId = 1,
                quest = {
                    id = 101,
                    objectives = {},
                },
            })
            alice.env.Questie:SendCommMessage("questie", incompatiblePacket, "PARTY")
            assertIsolatedNetworkFlushes(network)

            assert.is_nil(next(bob.QuestieComms.remoteQuestLogs))
            assert.are_equal(0, #bob.legacyTooltipRegistrations)
        end)
    end)

end)
