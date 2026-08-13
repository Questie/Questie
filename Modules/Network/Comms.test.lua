dofile("setupTests.lua")

describe("Comms", function()
    ---@type AvailableQuests
    local AvailableQuests

    ---@type Comms
    local Comms

    before_each(function()
        Questie.RegisterComm = function() end
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
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

        it("should reject messages from disallowed distributions", function()
            Questie.Deserialize = spy.new(function() end)

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "WHISPER", "SomeSender")

            assert.spy(Questie.Deserialize).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject messages from SAY distribution", function()
            Questie.Deserialize = spy.new(function() end)

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "SAY", "SomeSender")

            assert.spy(Questie.Deserialize).was.not_called()
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
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "RAID", "SomeSender")

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
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "PARTY", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(npcId, questIds)
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

        it("should broadcast unavailable quests when the response timer fires", function()
            local npcId = 111
            local questIds = {222, 333}
            AvailableQuests.GetUnavailableDailyQuests = function() return {[npcId] = questIds} end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end
            _G.IsInGuild = function() return true end

            -- Use instant timer so the callback fires immediately
            _G.C_Timer.NewTimer = function(_, callback)
                callback()
                return {Cancel = function() end}
            end

            local event = {eventName = "RequestUnavailableDailyQuests"}
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "GUILD")
        end)

        it("should not broadcast when GetUnavailableDailyQuests returns empty", function()
            AvailableQuests.GetUnavailableDailyQuests = function() return {} end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = spy.new(function() return "eventAsSerializedString" end)
            _G.IsInGuild = function() return true end

            _G.C_Timer.NewTimer = function(_, callback)
                callback()
                return {Cancel = function() end}
            end

            local event = {eventName = "RequestUnavailableDailyQuests"}
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("should cancel pending response timer when HideDailyQuests is received from a peer", function()
            -- First, schedule a response by receiving a request
            local timer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            local timerMock = spy.new(function() return timer end)
            _G.C_Timer.NewTimer = timerMock

            local requestEvent = {eventName = "RequestUnavailableDailyQuests"}
            Questie.Deserialize = function() return true, requestEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(timerMock).was.called()
            assert.is_false(timer.cancelled)

            -- Now receive a HideDailyQuests from a peer — should cancel the pending timer
            local hideEvent = {
                eventName = "HideDailyQuests",
                data = {npcId = 1234, questIds = {5678}}
            }
            Questie.Deserialize = function() return true, hideEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "AnotherSender")

            assert.is_true(timer.cancelled)
        end)

        it("should replace existing pending timer when a second RequestUnavailableDailyQuests arrives", function()
            local firstTimer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            local firstTimerMock = spy.new(function() return firstTimer end)
            local secondTimer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            local secondTimerMock = spy.new(function() return secondTimer end)

            local event = {eventName = "RequestUnavailableDailyQuests"}
            Questie.Deserialize = function() return true, event end

            _G.C_Timer = {
                NewTimer = firstTimerMock
            }
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            _G.C_Timer = {
                NewTimer = secondTimerMock
            }
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "AnotherSender")

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

            local requestEvent = {eventName = "RequestUnavailableDailyQuests"}
            Questie.Deserialize = function() return true, requestEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.is_false(timer.cancelled)

            -- Peer broadcasts 3 quests (subset of our 5)
            local hideEvent = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = broadcastedQuestIds}
            }
            Questie.Deserialize = function() return true, hideEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "AnotherSender")

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

            local requestEvent = {eventName = "RequestUnavailableDailyQuests"}
            Questie.Deserialize = function() return true, requestEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.is_false(timer.cancelled)

            -- Peer broadcasts all 3 quests we know
            local hideEvent = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = broadcastedQuestIds}
            }
            Questie.Deserialize = function() return true, hideEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "AnotherSender")

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

            local requestEvent = {eventName = "RequestUnavailableDailyQuests"}
            Questie.Deserialize = function() return true, requestEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.is_false(timer.cancelled)

            -- Peer A broadcasts 3 quests
            local hideEvent1 = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = {1, 2, 3}}
            }
            Questie.Deserialize = function() return true, hideEvent1 end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "UserA")

            -- Timer should NOT be cancelled yet (we know of 4, 5)
            assert.is_false(timer.cancelled)

            -- Peer B broadcasts 2 more quests (4, 5)
            local hideEvent2 = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = {4, 5}}
            }
            Questie.Deserialize = function() return true, hideEvent2 end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "UserB")

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

            local requestEvent = {eventName = "RequestUnavailableDailyQuests"}
            Questie.Deserialize = function() return true, requestEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            -- Peer broadcasts 2 quests
            local hideEvent = {
                eventName = "HideDailyQuests",
                data = {npcId = npcId, questIds = {1, 2}}
            }
            Questie.Deserialize = function() return true, hideEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "AnotherSender")

            assert.is_false(timer1.cancelled)

            -- NEW request arrives (e.g., another user comes online)
            local timer2 = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            _G.C_Timer.NewTimer = function() return timer2 end

            Questie.Deserialize = function() return true, requestEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "ThirdSender")

            assert.is_true(timer1.cancelled)
            assert.is_false(timer2.cancelled)

            -- Peer broadcasts 2 quests again — tracking should be reset, so timer2 stays
            Questie.Deserialize = function() return true, hideEvent end
            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "AnotherSender")

            assert.is_false(timer2.cancelled)
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

    describe("RequestUnavailableDailyQuests", function()
        it("should send to guild when in a guild", function()
            _G.IsInGuild = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "GUILD")
        end)

        it("should send to party when in a party", function()
            _G.IsInGroup = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "PARTY")
        end)

        it("should send to raid when in a raid", function()
            _G.IsInRaid = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "RAID")
        end)

        it("should not send when not in a guild, raid or party", function()
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.RequestUnavailableDailyQuests()

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)
    end)
end)
