dofile("setupTests.lua")

describe("CommsVisibility", function()
    ---@type CommsVisibility
    local CommsVisibility

    ---@type CommsEncoding
    local CommsEncoding

    ---@type CommsRouting
    local CommsRouting

    ---@type QuestLogCache
    local QuestLogCache

    ---@type QuestieQuest
    local QuestieQuest

    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives

    ---@type QuestiePlayer
    local QuestiePlayer

    -- Fires the timer immediately, simulating C_Timer with zero delay.
    local function _createInstantTimerMock()
        return {
            NewTimer = function(_, callback)
                callback()
                return {Cancel = function() end}
            end
        }
    end

    before_each(function()
        _G.wipe = function(t)
            for k in pairs(t) do
                t[k] = nil
            end
            return t
        end
        _G.math.random = function() return 0 end

        _G.C_Timer = {
            NewTimer = function(_, callback)
                local timer = {cancelled = false}
                timer.callback = callback
                timer.Cancel = function(self)
                    self.cancelled = true
                end
                return timer
            end
        }

        Questie.RegisterComm = function() end
        Questie.db = {char = {}}

        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
        CommsEncoding.HasCodecSupport = function() return true end
        CommsEncoding.EncodePayload = function() return "encodedPayload" end
        CommsEncoding.DecodePayload = function() return {} end

        CommsRouting = QuestieLoader:ImportModule("CommsRouting")
        CommsRouting.IsSelf = function() return false end
        CommsRouting.IsMessageFromGroupMember = function() return true end
        CommsRouting.GetGroupBroadcastDistribution = function() return "" end

        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.IsQuestTracked = function() return true end

        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
        QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetGroupType = function() return "party" end

        _G.GetNumGroupMembers = function() return 2 end

        dofile("Modules/Network/CommsVisibility.lua")
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        -- ResetAll resets the initialized guard so Initialize can be exercised per-test.
        CommsVisibility:ResetAll()
        CommsVisibility:Initialize()
    end)

    describe("Initialize", function()
        it("should not register comm when codec support is unavailable", function()
            CommsEncoding.HasCodecSupport = function() return false end
            Questie.RegisterComm = spy.new(function() end)

            -- Reload to reset the module-level initialized guard.
            dofile("Modules/Network/CommsVisibility.lua")
            local freshCommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
            freshCommsVisibility:ResetAll()

            freshCommsVisibility:Initialize()

            assert.spy(Questie.RegisterComm).was.not_called()
        end)

        it("should register comm when codec support is available", function()
            Questie.RegisterComm = spy.new(function() end)

            -- Reload to reset the module-level initialized guard.
            dofile("Modules/Network/CommsVisibility.lua")
            local freshCommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
            freshCommsVisibility:ResetAll()

            freshCommsVisibility:Initialize()

            assert.spy(Questie.RegisterComm).was.called_with(Questie, "QuestieV1", freshCommsVisibility.OnCommReceived)
        end)

        it("should not re-register comm when already initialized", function()
            Questie.RegisterComm = spy.new(function() end)

            -- Reload fresh and initialize once.
            dofile("Modules/Network/CommsVisibility.lua")
            local freshCommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
            freshCommsVisibility:ResetAll()
            freshCommsVisibility:Initialize()

            freshCommsVisibility:Initialize()

            assert.spy(Questie.RegisterComm).was.called(1)
        end)
    end)

    describe("ScheduleSnapshot", function()
        it("should not create a timer when group is too large", function()
            _G.GetNumGroupMembers = function() return 6 end
            _G.C_Timer = {
                NewTimer = spy.new(function() end)
            }

            CommsVisibility:ScheduleSnapshot("test")

            assert.spy(_G.C_Timer.NewTimer).was.not_called()
        end)

        it("should not send when group grows too large before the timer fires", function()
            -- Group is small when scheduling...
            _G.GetNumGroupMembers = function() return 2 end
            Questie.SendCommMessage = spy.new(function() end)

            local capturedCallback
            _G.C_Timer = {
                NewTimer = function(_, callback)
                    capturedCallback = callback
                    return {Cancel = function() end}
                end
            }
            CommsVisibility:ScheduleSnapshot("test")

            -- ...but grows too large before the timer fires.
            _G.GetNumGroupMembers = function() return 6 end
            capturedCallback()

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("should not send when no broadcast distribution is available", function()
            CommsRouting.GetGroupBroadcastDistribution = function() return nil end
            Questie.SendCommMessage = spy.new(function() end)
            _G.C_Timer = _createInstantTimerMock()

            CommsVisibility:ScheduleSnapshot("test")

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("should not send when encoding fails", function()
            CommsEncoding.EncodePayload = function() return nil end
            Questie.SendCommMessage = spy.new(function() end)
            _G.C_Timer = _createInstantTimerMock()

            CommsVisibility:ScheduleSnapshot("test")

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("should send encoded snapshot to the broadcast distribution", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[100] = true}
            QuestieQuest.IsQuestTracked = function() return true end
            CommsEncoding.EncodePayload = function() return "encodedPayload" end
            CommsRouting.GetGroupBroadcastDistribution = function() return "PARTY" end
            Questie.SendCommMessage = spy.new(function() end)
            _G.C_Timer = _createInstantTimerMock()

            CommsVisibility:ScheduleSnapshot("test")

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieV1", "encodedPayload", "PARTY")
        end)

        it("should mark hidden quests as false in snapshot", function()
            Questie.db.char.hidden = {[100] = true}
            QuestLogCache.questLog_DO_NOT_MODIFY = {[100] = true}
            local capturedPayload
            CommsEncoding.EncodePayload = function(_, payload)
                capturedPayload = payload
                return "encodedPayload"
            end
            _G.C_Timer = _createInstantTimerMock()

            CommsVisibility:ScheduleSnapshot("test")

            assert.is_false(capturedPayload[100])
        end)

        it("should mark tracked quests as true in snapshot", function()
            Questie.db.char.hidden = {}
            QuestLogCache.questLog_DO_NOT_MODIFY = {[100] = true}
            QuestieQuest.IsQuestTracked = function() return true end
            local capturedPayload
            CommsEncoding.EncodePayload = function(_, payload)
                capturedPayload = payload
                return "encodedPayload"
            end
            _G.C_Timer = _createInstantTimerMock()

            CommsVisibility:ScheduleSnapshot("test")

            assert.is_true(capturedPayload[100])
        end)

        it("should skip non-number keys in quest log when building snapshot", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[100] = true, ["notAQuestId"] = true}
            local capturedPayload
            CommsEncoding.EncodePayload = function(_, payload)
                capturedPayload = payload
                return "encodedPayload"
            end
            _G.C_Timer = _createInstantTimerMock()

            CommsVisibility:ScheduleSnapshot("test")

            assert.is_nil(capturedPayload["notAQuestId"])
            assert.is_not_nil(capturedPayload[100])
        end)

        it("should cancel the previous timer when scheduling a new snapshot", function()
            local firstTimer = {cancelled = false, Cancel = function(self) self.cancelled = true end}
            local secondTimer = {cancelled = false, Cancel = function(self) self.cancelled = true end}

            _G.C_Timer = {
                NewTimer = function() return firstTimer end
            }
            CommsVisibility:ScheduleSnapshot("first")

            _G.C_Timer = {
                NewTimer = function() return secondTimer end
            }
            CommsVisibility:ScheduleSnapshot("second")

            assert.is_true(firstTimer.cancelled)
        end)
    end)

    describe("OnCommReceived", function()
        it("should store snapshot for valid message from group member", function()
            local snapshot = {[100] = true, [200] = false}
            CommsEncoding.DecodePayload = function() return snapshot end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.are_same(snapshot, CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called()
        end)

        it("should reject messages with wrong prefix", function()
            CommsEncoding.DecodePayload = spy.new(function() return {[100] = true} end)

            CommsVisibility.OnCommReceived("WrongPrefix", "msg", "PARTY", "FriendName")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsVisibility.remoteQuestVisibility["FriendName"])
        end)

        it("should reject messages from self", function()
            CommsRouting.IsSelf = function() return true end
            CommsEncoding.DecodePayload = spy.new(function() return {[100] = true} end)

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "PlayerName")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
        end)

        it("should reject messages not from group members", function()
            CommsRouting.IsMessageFromGroupMember = function() return false end
            CommsEncoding.DecodePayload = spy.new(function() return {[100] = true} end)

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "WHISPER", "SomeSender")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
        end)

        it("should reject nil payload", function()
            CommsEncoding.DecodePayload = function() return nil end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.is_nil(CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("should reject non-table payload", function()
            CommsEncoding.DecodePayload = function() return "notATable" end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.is_nil(CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("should reject payload with non-number quest id", function()
            CommsEncoding.DecodePayload = function() return {["notANumber"] = true} end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.is_nil(CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("should reject payload with non-boolean visibility value", function()
            CommsEncoding.DecodePayload = function() return {[100] = "yes"} end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.is_nil(CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("should reject payload with zero quest id", function()
            CommsEncoding.DecodePayload = function() return {[0] = true} end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.is_nil(CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("should reject payload with negative quest id", function()
            CommsEncoding.DecodePayload = function() return {[-1] = true} end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.is_nil(CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("should reject payload with fractional quest id", function()
            CommsEncoding.DecodePayload = function() return {[1.5] = true} end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.is_nil(CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("should accept empty snapshot and clear prior state for sender", function()
            CommsVisibility.remoteQuestVisibility["FriendName"] = {[100] = true}
            CommsEncoding.DecodePayload = function() return {} end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.are_same({}, CommsVisibility.remoteQuestVisibility["FriendName"])
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called()
        end)

        it("should atomically replace prior snapshot for sender", function()
            CommsVisibility.remoteQuestVisibility["FriendName"] = {[100] = true, [200] = true}
            local newSnapshot = {[300] = true}
            CommsEncoding.DecodePayload = function() return newSnapshot end

            CommsVisibility.OnCommReceived("QuestieV1", "msg", "PARTY", "FriendName")

            assert.are_same(newSnapshot, CommsVisibility.remoteQuestVisibility["FriendName"])
        end)
    end)

    describe("ShouldShowPartyObjective", function()
        it("should return true when no snapshot exists for player", function()
            local result = CommsVisibility:ShouldShowPartyObjective("UnknownPlayer", 100)

            assert.is_true(result)
        end)

        it("should return true when quest is explicitly marked true in snapshot", function()
            CommsVisibility.remoteQuestVisibility["FriendName"] = {[100] = true}

            local result = CommsVisibility:ShouldShowPartyObjective("FriendName", 100)

            assert.is_true(result)
        end)

        it("should return false when quest is explicitly marked false in snapshot", function()
            CommsVisibility.remoteQuestVisibility["FriendName"] = {[100] = false}

            local result = CommsVisibility:ShouldShowPartyObjective("FriendName", 100)

            assert.is_false(result)
        end)

        it("should return false when quest is omitted from snapshot (suppressed by omission)", function()
            CommsVisibility.remoteQuestVisibility["FriendName"] = {[200] = true}

            local result = CommsVisibility:ShouldShowPartyObjective("FriendName", 100)

            assert.is_false(result)
        end)
    end)

    describe("ResetAll", function()
        it("should clear all remote visibility data", function()
            CommsVisibility.remoteQuestVisibility["FriendName"] = {[100] = true}

            CommsVisibility:ResetAll()

            assert.are_same({}, CommsVisibility.remoteQuestVisibility)
        end)

        it("should cancel an in-flight snapshot timer", function()
            local pendingTimer = nil
            _G.C_Timer = {
                NewTimer = function()
                    pendingTimer = {cancelled = false}
                    pendingTimer.Cancel = function(self) self.cancelled = true end
                    return pendingTimer
                end
            }
            CommsVisibility:ScheduleSnapshot("setup")

            CommsVisibility:ResetAll()

            assert.is_true(pendingTimer.cancelled)
        end)
    end)

    describe("PruneRemotePlayers", function()
        it("should remove players who are no longer in the group", function()
            CommsVisibility.remoteQuestVisibility["GoneSolo"] = {[100] = true}
            CommsVisibility.remoteQuestVisibility["PartyMember"] = {[100] = true}
            _G.UnitInParty = function(name) return name == "PartyMember" end
            _G.UnitInRaid = function() return false end

            CommsVisibility:PruneRemotePlayers()

            assert.is_nil(CommsVisibility.remoteQuestVisibility["GoneSolo"])
            assert.is_not_nil(CommsVisibility.remoteQuestVisibility["PartyMember"])
        end)

        it("should keep players who are in the raid", function()
            CommsVisibility.remoteQuestVisibility["GoneSolo"] = {[100] = true}
            CommsVisibility.remoteQuestVisibility["RaidMember"] = {[100] = true}
            _G.UnitInParty = function(name) return false end
            _G.UnitInRaid = function(name) return name == "RaidMember" end

            CommsVisibility:PruneRemotePlayers()

            assert.is_nil(CommsVisibility.remoteQuestVisibility["GoneSolo"])
            assert.is_not_nil(CommsVisibility.remoteQuestVisibility["RaidMember"])
        end)

        it("should handle empty remoteQuestVisibility without error", function()
            CommsVisibility.remoteQuestVisibility = {}
            _G.UnitInParty = spy.new(function() return false end)
            _G.UnitInRaid = spy.new(function() return false end)

            assert.has_no_error(function()
                CommsVisibility:PruneRemotePlayers()
            end)
            assert.spy(_G.UnitInParty).was.not_called()
            assert.spy(_G.UnitInRaid).was.not_called()
        end)
    end)
end)
