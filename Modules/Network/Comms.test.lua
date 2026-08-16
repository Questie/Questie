dofile("setupTests.lua")

describe("Comms", function()
    ---@type AvailableQuests
    local AvailableQuests
    ---@type CommsEncoding
    local CommsEncoding

    ---@type Comms
    local Comms

    before_each(function()
        Questie.RegisterComm = function() end
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
        CommsEncoding.hasCodecSupport = true
        CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end
        CommsEncoding.DecodePayload = function() return {} end
        AvailableQuests.RemoveQuestsForToday = spy.new(function() end)
        AvailableQuests.GetUnavailableDailyQuests = spy.new(function() return {} end)

        _G.IsInGuild = function() return false end
        _G.IsInRaid = function() return false end
        _G.IsInGroup = function() return false end

        _G.C_Timer = {
            NewTimer = function(_, callback)
                local timer = {cancelled = false, callback = callback}
                timer.Cancel = function(self)
                    self.cancelled = true
                end
                return timer
            end
        }

        _G.math.random = function() return 0 end

        dofile("Modules/Network/Comms.lua")
        Comms = QuestieLoader:ImportModule("Comms")
        Comms.Initialize()
    end)

    describe("Initialize", function()
        it("should not register comm when codec support is unavailable", function()
            Questie.RegisterComm = spy.new(function() end)
            CommsEncoding.hasCodecSupport = false

            Comms.Initialize()

            assert.spy(Questie.RegisterComm).was.not_called()
        end)

        it("should register comm when codec support is available", function()
            Questie.RegisterComm = spy.new(function() end)
            CommsEncoding.hasCodecSupport = true

            Comms.Initialize()

            assert.spy(Questie.RegisterComm).was.called_with(Questie, "QuestieDailies", Comms.OnCommReceived)
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
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(npcId, questIds)
        end)

        it("should reject unknown prefixes", function()
            CommsEncoding.DecodePayload = spy.new(function() end)

            Comms.OnCommReceived("Unknown", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject own HideDailyQuests events", function()
            CommsEncoding.DecodePayload = spy.new(function() end)

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", UnitName("player"))

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject own HideDailyQuests events when sender is in realm format", function()
            CommsEncoding.DecodePayload = spy.new(function() end)

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", UnitName("player") .. "-" .. GetRealmName())

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject messages from disallowed distributions", function()
            CommsEncoding.DecodePayload = spy.new(function() end)

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "WHISPER", "SomeSender")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject messages from SAY distribution", function()
            CommsEncoding.DecodePayload = spy.new(function() end)

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "SAY", "SomeSender")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should process messages from RAID distribution", function()
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
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "RAID", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(npcId, questIds)
        end)

        it("should process messages from PARTY distribution", function()
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
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "PARTY", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(npcId, questIds)
        end)

        it("should reject malformed HideDailyQuests events", function()
            CommsEncoding.DecodePayload = function() return nil end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events when they are not a table", function()
            CommsEncoding.DecodePayload = function() return 123 end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events without data", function()
            local event = {
                eventName = "HideDailyQuests"
            }
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events when data is not a table", function()
            local event = {
                eventName = "HideDailyQuests",
                data = 123,
            }
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

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
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

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
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

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
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should broadcast unavailable quests when the response timer fires", function()
            local npcId = 111
            local questIds = {222, 333}
            AvailableQuests.GetUnavailableDailyQuests = function() return {[npcId] = questIds} end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end
            _G.IsInGuild = function() return true end

            -- Use instant timer so the callback fires immediately
            _G.C_Timer.NewTimer = function(_, callback)
                callback()
                return {Cancel = function() end}
            end

            local event = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "GUILD")
        end)

        it("should not broadcast when GetUnavailableDailyQuests returns empty", function()
            AvailableQuests.GetUnavailableDailyQuests = function() return {} end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = spy.new(function() return "eventAsSerializedString" end)
            _G.IsInGuild = function() return true end

            _G.C_Timer.NewTimer = function(_, callback)
                callback()
                return {Cancel = function() end}
            end

            local event = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("should cancel pending response timer when HideDailyQuests is received from a peer", function()
            -- Setup: receiver has NPC 1234, sender doesn't — so timer will be scheduled
            AvailableQuests.GetUnavailableDailyQuests = function() return {[1234] = {5678, 91011}} end

            local timer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            local timerMock = spy.new(function() return timer end)
            _G.C_Timer.NewTimer = timerMock

            local requestEvent = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return requestEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(timerMock).was.called()
            assert.is_false(timer.cancelled)

            -- Peer covers all our quests — should cancel the pending timer
            local hideEvent = {
                eventName = "HideDailyQuests",
                data = {npcId = 1234, questIds = {5678, 91011}}
            }
            CommsEncoding.DecodePayload = function() return hideEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "AnotherSender")

            assert.is_true(timer.cancelled)
        end)

        it("should replace existing pending timer when a second RequestUnavailableDailyQuests arrives", function()
            -- Setup: receiver has NPC 1234 that senders don't — so both timers will be scheduled
            AvailableQuests.GetUnavailableDailyQuests = function() return {[1234] = {5678}} end

            local firstTimer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            local firstTimerMock = spy.new(function() return firstTimer end)
            local secondTimer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            local secondTimerMock = spy.new(function() return secondTimer end)

            local event = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return event end

            _G.C_Timer = {NewTimer = firstTimerMock}
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            _G.C_Timer = {NewTimer = secondTimerMock}
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "AnotherSender")

            assert.is_true(firstTimer.cancelled)
            assert.spy(firstTimerMock).was.called()
            assert.spy(secondTimerMock).was.called()
        end)

        it("should keep pending timer if local data has quests not yet broadcast", function()
            local npcId = 1234
            local localQuestIds = {1, 2, 3, 4, 5}
            local broadcastedQuestIds = {1, 2, 3}

            -- Setup: local knowledge includes 5 quests
            AvailableQuests.GetUnavailableDailyQuests = function()
                return {[npcId] = localQuestIds}
            end

            -- Schedule a response by receiving a request
            local timer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            _G.C_Timer.NewTimer = function() return timer end

            local requestEvent = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return requestEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.is_false(timer.cancelled)

            -- Peer broadcasts 3 quests (subset of our 5)
            local hideEvent = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = broadcastedQuestIds}
            }
            CommsEncoding.DecodePayload = function() return hideEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "AnotherSender")

            -- Timer should NOT be cancelled because we know of 2 additional quests (4, 5)
            assert.is_false(timer.cancelled)
        end)

        it("should cancel pending timer if local data has no new quests beyond what was broadcast", function()
            local npcId = 1234
            local localQuestIds = {1, 2, 3}
            local broadcastedQuestIds = {1, 2, 3}

            AvailableQuests.GetUnavailableDailyQuests = function()
                return {[npcId] = localQuestIds}
            end

            -- Schedule a response
            local timer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            _G.C_Timer.NewTimer = function() return timer end

            local requestEvent = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return requestEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.is_false(timer.cancelled)

            -- Peer broadcasts all 3 quests we know
            local hideEvent = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = broadcastedQuestIds}
            }
            CommsEncoding.DecodePayload = function() return hideEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "AnotherSender")

            -- Timer should be cancelled because peer covered all our knowledge
            assert.is_true(timer.cancelled)
        end)

        it("should accumulate quest IDs from multiple HideDailyQuests messages before deciding to cancel", function()
            local npcId = 1234
            local localQuestIds = {1, 2, 3, 4, 5}

            AvailableQuests.GetUnavailableDailyQuests = function()
                return {[npcId] = localQuestIds}
            end

            -- Schedule a response
            local timer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            _G.C_Timer.NewTimer = function() return timer end

            local requestEvent = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return requestEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.is_false(timer.cancelled)

            -- Peer A broadcasts 3 quests
            local hideEvent1 = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = {1, 2, 3}}
            }
            CommsEncoding.DecodePayload = function() return hideEvent1 end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "UserA")

            -- Timer should NOT be cancelled yet (we know of 4, 5)
            assert.is_false(timer.cancelled)

            -- Peer B broadcasts 2 more quests (4, 5)
            local hideEvent2 = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = {4, 5}}
            }
            CommsEncoding.DecodePayload = function() return hideEvent2 end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "UserB")

            -- Now timer should be cancelled (all 5 quests covered)
            assert.is_true(timer.cancelled)
        end)

        it("should reset tracked broadcasts when a new RequestUnavailableDailyQuests arrives", function()
            local npcId = 1234
            local localQuestIds = {1, 2, 3}

            AvailableQuests.GetUnavailableDailyQuests = function()
                return {[npcId] = localQuestIds}
            end

            -- First request cycle
            local timer1 = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            _G.C_Timer.NewTimer = function() return timer1 end

            local requestEvent = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return requestEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            -- Peer broadcasts 2 quests
            local hideEvent = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = {1, 2}}
            }
            CommsEncoding.DecodePayload = function() return hideEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "AnotherSender")

            assert.is_false(timer1.cancelled)

            -- NEW request arrives (e.g., another user comes online)
            local timer2 = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            _G.C_Timer.NewTimer = function() return timer2 end

            CommsEncoding.DecodePayload = function() return requestEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "ThirdSender")

            assert.is_true(timer1.cancelled)
            assert.is_false(timer2.cancelled)

            -- Peer broadcasts 2 quests again — tracking should be reset, so timer2 stays
            CommsEncoding.DecodePayload = function() return hideEvent end
            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "AnotherSender")

            assert.is_false(timer2.cancelled)
        end)

        it("should not schedule timer when receiver has no quests different from sender", function()
            local receiverData = {[1234] = {1, 2, 3}}
            local senderData = {[1234] = {1, 2, 3}}

            AvailableQuests.GetUnavailableDailyQuests = function() return receiverData end
            _G.C_Timer.NewTimer = spy.new(function() end)

            local event = {eventName = "RequestUnavailableDailyQuests", data = senderData}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(_G.C_Timer.NewTimer).was.not_called()
        end)

        it("should not schedule timer when both receiver and sender know nothing", function()
            local receiverData = {}
            local senderData = {}

            AvailableQuests.GetUnavailableDailyQuests = function() return receiverData end
            _G.C_Timer.NewTimer = spy.new(function() end)

            local event = {eventName = "RequestUnavailableDailyQuests", data = senderData}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(_G.C_Timer.NewTimer).was.not_called()
        end)

        it("should schedule timer when sender sent no data but receiver has something new", function()
            local receiverData = {[1234] = {1, 2, 3}}
            local senderData = {}

            AvailableQuests.GetUnavailableDailyQuests = function() return receiverData end
            _G.C_Timer.NewTimer = spy.new(function() end)

            -- Sender has no data, but receiver does — should still schedule timer
            local event = {eventName = "RequestUnavailableDailyQuests", data = senderData}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(_G.C_Timer.NewTimer).was.called()
        end)

        it("should schedule timer when receiver has NPCs sender doesn't know about", function()
            local receiverData = {[1234] = {1, 2, 3}, [5678] = {10, 11}}
            local senderData = {[1234] = {1, 2, 3}}

            AvailableQuests.GetUnavailableDailyQuests = function() return receiverData end
            _G.C_Timer.NewTimer = spy.new(function() return {Cancel = function() end} end)

            local event = {eventName = "RequestUnavailableDailyQuests", data = senderData}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(_G.C_Timer.NewTimer).was.called()
        end)

        it("should call RemoveQuestsForToday for NPCs in sender data that receiver doesn't know", function()
            local senderNpcId = 9999
            local senderQuestIds = {100, 200}

            AvailableQuests.GetUnavailableDailyQuests = function() return {} end

            local event = {eventName = "RequestUnavailableDailyQuests", data = {[senderNpcId] = senderQuestIds}}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(senderNpcId, senderQuestIds)
        end)

        it("should not call RemoveQuestsForToday for NPCs the receiver already knows", function()
            local knownNpcId = 1234
            local senderQuestIds = {100, 200}

            AvailableQuests.GetUnavailableDailyQuests = function() return {[knownNpcId] = {1, 2}} end

            local event = {eventName = "RequestUnavailableDailyQuests", data = {[knownNpcId] = senderQuestIds}}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should only integrate new NPCs when sender data has both known and unknown NPCs", function()
            local knownNpcId = 1234
            local newNpcId = 5678
            local newQuestIds = {300, 400}

            AvailableQuests.GetUnavailableDailyQuests = function() return {[knownNpcId] = {1, 2}} end

            local event = {
                eventName = "RequestUnavailableDailyQuests",
                data = {[knownNpcId] = {10, 20}, [newNpcId] = newQuestIds}
            }
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(newNpcId, newQuestIds)
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called(1)
        end)

        it("should not call RemoveQuestsForToday when sender data is empty", function()
            AvailableQuests.GetUnavailableDailyQuests = function() return {} end

            local event = {eventName = "RequestUnavailableDailyQuests", data = {}}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject RequestUnavailableDailyQuests when data is not a table", function()
            AvailableQuests.GetUnavailableDailyQuests = function() return {} end

            local event = {eventName = "RequestUnavailableDailyQuests", data = "not a table"}
            CommsEncoding.DecodePayload = function() return event end

            Comms.OnCommReceived("QuestieDailies", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)
    end)

    describe("BroadcastUnavailableDailyQuests", function()
        it("should broadcast to guild", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "GUILD")
        end)

        it("should broadcast only to party when in a party and not in a guild", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "PARTY")
        end)

        it("should broadcast only to raid when in a raid and not in a guild", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "RAID")
        end)

        it("should broadcast to guild and raid when in a raid", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "GUILD")
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "RAID")
        end)

        it("should broadcast to guild and party when in a party", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "GUILD")
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "PARTY")
        end)

        it("should not broadcast when not in a guild, raid or party", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("should not broadcast when EncodePayload returns nil", function()
            _G.IsInGuild = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return nil end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)
    end)

    describe("RequestUnavailableDailyQuests", function()
        it("should send to guild when in a guild", function()
            _G.IsInGuild = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "GUILD")
        end)

        it("should send to party when in a party", function()
            _G.IsInGroup = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "PARTY")
        end)

        it("should send to raid when in a raid", function()
            _G.IsInRaid = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieDailies", "eventAsSerializedString", "RAID")
        end)

        it("should not send when not in a guild, raid or party", function()
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return "eventAsSerializedString" end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("should not send when EncodePayload returns nil", function()
            _G.IsInGuild = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            CommsEncoding.EncodePayload = function() return nil end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("should include known unavailable quests in the event payload", function()
            local npcId = 1234
            local questIds = {5678, 91011}
            AvailableQuests.GetUnavailableDailyQuests = function()
                return {[npcId] = questIds}
            end
            _G.IsInGuild = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            local capturedEvent
            CommsEncoding.EncodePayload = function(_, event)
                capturedEvent = event
                return "eventAsSerializedString"
            end

            Comms.RequestUnavailableDailyQuests()

            assert.are_equal("RequestUnavailableDailyQuests", capturedEvent.eventName)
            assert.are_same({[npcId] = questIds}, capturedEvent.data)
        end)

        it("should include empty data when no quests are known", function()
            AvailableQuests.GetUnavailableDailyQuests = function()
                return {}
            end
            _G.IsInGuild = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            local capturedEvent
            CommsEncoding.EncodePayload = function(_, event)
                capturedEvent = event
                return "eventAsSerializedString"
            end

            Comms.RequestUnavailableDailyQuests()

            assert.are_equal("RequestUnavailableDailyQuests", capturedEvent.eventName)
            assert.are_same({}, capturedEvent.data)
        end)
    end)
end)
