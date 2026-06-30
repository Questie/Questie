dofile("setupTests.lua")

describe("CommsVisibility", function()
    ---@type CommsVisibility
    local CommsVisibility

    ---@type QuestiePlayer
    local QuestiePlayer

    ---@type QuestLogCache
    local QuestLogCache

    ---@type QuestieQuest
    local QuestieQuest

    ---@type CommsHello
    local CommsHello

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

        CommsHello = QuestieLoader:ImportModule("CommsHello")
        CommsHello.RegisterLocalPrefix = spy.new(function() return true end)

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
            assert.spy(CommsHello.RegisterLocalPrefix).was.called_with(CommsHello, "QuestieV1")
        end)

        it("does not register when modern payload encoding is unavailable", function()
            CommsEncoding.HasCodecSupport = spy.new(function() return false end)
            dofile("Modules/Network/CommsVisibility.lua")
            CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")

            local initialized = CommsVisibility:Initialize()

            assert.is_false(initialized)
            assert.spy(Questie.RegisterComm).was.not_called()
            assert.spy(CommsHello.RegisterLocalPrefix).was.not_called()
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
end)
