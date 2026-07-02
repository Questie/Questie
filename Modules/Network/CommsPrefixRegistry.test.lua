dofile("setupTests.lua")

describe("CommsPrefixRegistry", function()
    ---@type CommsPrefixRegistry
    local CommsPrefixRegistry

    ---@type QuestiePlayer
    local QuestiePlayer

    ---@type CommsEncoding
    local CommsEncoding

    local serializedPayload
    local timers

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

    local function scheduleAndFireHello()
        installTimerMock()
        CommsPrefixRegistry:ScheduleHello("test")
        timers[1]:Fire()
    end

    before_each(function()
        Questie.RegisterComm = spy.new(function() end)
        Questie.SendCommMessage = spy.new(function() end)
        Questie.Debug = function() end
        Questie.Error = spy.new(function() end)

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
        _G.UnitInParty = function(unit) return unit == "Friend" end
        _G.UnitInRaid = function() return false end
        _G.GetNumGroupMembers = function() return 2 end
        _G.C_Timer = nil

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetGroupType = function() return "party" end

        dofile("Modules/Network/CommsEncoding.lua")
        dofile("Modules/Network/CommsRouting.lua")
        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
        setupCodec({QuestieH1 = true, QuestieV1 = true, questie = true, Questie = true, REPUTABLE = true})

        dofile("Modules/Network/CommsPrefixRegistry.lua")
        CommsPrefixRegistry = QuestieLoader:ImportModule("CommsPrefixRegistry")
        CommsPrefixRegistry:ResetAll()
    end)

    describe("Initialize", function()
        it("registers the QuestieH1 comm prefix when the codec is available", function()
            local initialized = CommsPrefixRegistry:Initialize()

            assert.is_true(initialized)
            assert.spy(Questie.RegisterComm).was.called_with(Questie, "QuestieH1", CommsPrefixRegistry.OnCommReceived)

            scheduleAndFireHello()
            assert.is_true(serializedPayload.QuestieH1)
        end)

        it("does not register when modern payload encoding is unavailable", function()
            CommsEncoding.HasCodecSupport = spy.new(function() return false end)
            dofile("Modules/Network/CommsPrefixRegistry.lua")
            CommsPrefixRegistry = QuestieLoader:ImportModule("CommsPrefixRegistry")

            local initialized = CommsPrefixRegistry:Initialize()

            assert.is_false(initialized)
            assert.spy(Questie.RegisterComm).was.not_called()
        end)
    end)

    describe("Local prefix states", function()
        it("defaults every known prefix to false until the owning receiver registers it", function()
            scheduleAndFireHello()

            assert.are_same({QuestieH1 = false, QuestieV1 = false, questie = false, Questie = false, REPUTABLE = false}, serializedPayload)
        end)

        it("marks only known local prefixes active", function()
            assert.is_true(CommsPrefixRegistry:RegisterLocalPrefix("QuestieV1"))
            assert.is_true(CommsPrefixRegistry:RegisterLocalPrefix("Questie"))
            assert.is_true(CommsPrefixRegistry:RegisterLocalPrefix("questie"))
            assert.is_true(CommsPrefixRegistry:RegisterLocalPrefix("REPUTABLE"))

            scheduleAndFireHello()
            assert.are_same({QuestieH1 = false, QuestieV1 = true, questie = true, Questie = true, REPUTABLE = true}, serializedPayload)
        end)

        it("reports undefined local prefixes once after a short delay", function()
            local scheduledDelay
            local scheduledCallback
            installTimerMock()
            _G.C_Timer.After = spy.new(function(delay, callback)
                scheduledDelay = delay
                scheduledCallback = callback
            end)

            assert.is_false(CommsPrefixRegistry:RegisterLocalPrefix("QuestieZ9"))
            assert.is_false(CommsPrefixRegistry:RegisterLocalPrefix("QuestieZ9"))

            CommsPrefixRegistry:ScheduleHello("test")
            timers[1]:Fire()
            assert.is_nil(serializedPayload.QuestieZ9)
            assert.spy(_G.C_Timer.After).was.called(1)
            assert.are_equal(5, scheduledDelay)
            assert.are_equal("function", type(scheduledCallback))
            assert.spy(Questie.Error).was.not_called()

            scheduledCallback()

            assert.spy(Questie.Error).was.called(1)
            assert.spy(Questie.Error).was.called_with(Questie, "[CommsPrefixRegistry] A module tried to register undefined Questie comm prefix 'QuestieZ9'. Add it to the QuestieH1 prefix manifest before registering support.")
        end)
    end)

    describe("ScheduleHello", function()
        before_each(function()
            installTimerMock()
        end)

        it("debounces hello sends until the latest timer fires", function()
            CommsPrefixRegistry:ScheduleHello("first")
            CommsPrefixRegistry:ScheduleHello("second")

            assert.are_equal(2, #timers)
            assert.spy(timers[1].Cancel).was.called(1)
            timers[1]:Fire()
            assert.spy(Questie.SendCommMessage).was.not_called()

            timers[2]:Fire()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "PARTY")
        end)

        it("uses raid and instance distributions based on the group type", function()
            QuestiePlayer.GetGroupType = function() return "raid" end
            CommsPrefixRegistry:ScheduleHello("raid")
            timers[1]:Fire()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "RAID")

            Questie.SendCommMessage:clear()
            QuestiePlayer.GetGroupType = function() return "instance" end
            CommsPrefixRegistry:ScheduleHello("instance")
            timers[2]:Fire()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "INSTANCE_CHAT")
        end)

        it("does not send outside a group", function()
            QuestiePlayer.GetGroupType = function() return nil end

            CommsPrefixRegistry:ScheduleHello("solo")
            timers[1]:Fire()

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("cancels a queued hello on ResetAll", function()
            CommsPrefixRegistry:ScheduleHello("test")
            CommsPrefixRegistry:ResetAll()
            timers[1]:Fire()

            assert.spy(timers[1].Cancel).was.called(1)
            assert.spy(CommsEncoding.EncodePayload).was.not_called()
            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("clears the timer handle after sending so a later schedule can queue again", function()
            CommsPrefixRegistry:ScheduleHello("first")
            timers[1]:Fire()

            CommsPrefixRegistry:ScheduleHello("second")

            assert.are_equal(2, #timers)
            timers[2]:Fire()
            assert.spy(Questie.SendCommMessage).was.called(2)
        end)
    end)

    describe("OnCommReceived", function()
        it("stores only known boolean prefixes from group members", function()
            setupCodec({QuestieH1 = true, QuestieV1 = false, questie = true, Questie = "yes", REPUTABLE = false, QuestieZ9 = true})
            _G.UnitInParty = function(unit) return unit == "Friend-Realm" end

            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "WHISPER", "Friend-Realm")

            assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieH1"))
            assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "questie"))
            assert.is_true(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "QuestieV1"))
            assert.is_true(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "REPUTABLE"))
            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes["Friend-Realm"].Questie)
            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes["Friend-Realm"].QuestieZ9)
            assert.are_equal(123, CommsPrefixRegistry.remotePlayerLastSeen["Friend-Realm"])
            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes.Friend)
        end)

        it("whispers a direct reply for a player's small-group broadcast hello", function()
            _G.UnitInParty = function(unit) return unit == "Friend-Realm" end
            _G.GetNumGroupMembers = function() return 5 end

            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend-Realm")

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "WHISPER", "Friend-Realm")
        end)

        it("whispers a direct reply for a player's large-group broadcast hello", function()
            _G.UnitInRaid = function(unit) return unit == "Friend-Realm" end
            _G.GetNumGroupMembers = function() return 40 end

            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "RAID", "Friend-Realm")

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "WHISPER", "Friend-Realm")
        end)

        it("whispers a direct reply to known players because broadcasts can mean reload", function()
            _G.UnitInParty = function(unit) return unit == "Friend-Realm" end
            CommsPrefixRegistry.remotePlayerPrefixes["Friend-Realm"] = {QuestieH1 = true}

            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend-Realm")

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "WHISPER", "Friend-Realm")
        end)

        it("stores unknown whisper hellos without replying", function()
            _G.UnitInParty = function(unit) return unit == "Friend-Realm" end

            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "WHISPER", "Friend-Realm")

            assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieH1"))
            assert.spy(Questie.SendCommMessage).was.not_called()
        end)

        it("ignores messages from self", function()
            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "PARTY", "Player")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes.Player)
        end)

        it("does not treat same-name cross-realm players as self", function()
            installTimerMock()
            _G.UnitInParty = function(unit) return unit == "Player-OtherRealm" end

            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "PARTY", "Player-OtherRealm")

            assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Player-OtherRealm", "QuestieH1"))
        end)

        it("keeps same-name players from different realms separate", function()
            installTimerMock()
            _G.UnitInParty = function(unit)
                return unit == "Friend-RealmOne" or unit == "Friend-RealmTwo"
            end

            setupCodec({QuestieH1 = true, questie = true})
            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend-RealmOne")
            setupCodec({QuestieH1 = false, questie = false})
            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend-RealmTwo")

            assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-RealmOne", "QuestieH1"))
            assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-RealmOne", "questie"))
            assert.is_true(CommsPrefixRegistry:RejectsPrefix("Friend-RealmTwo", "QuestieH1"))
            assert.is_true(CommsPrefixRegistry:RejectsPrefix("Friend-RealmTwo", "questie"))
            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes.Friend)
        end)

        it("ignores whispers from non-group senders", function()
            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "WHISPER", "Stranger")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes.Stranger)
        end)

        it("ignores unsupported distributions", function()
            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "GUILD", "Friend")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes.Friend)
        end)

        it("ignores malformed payloads without throwing", function()
            CommsEncoding.DecodePayload = spy.new(function() return nil end)

            assert.has_no.errors(function()
                CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend")
            end)
            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes.Friend)
        end)
    end)

    describe("Prefix queries", function()
        it("distinguishes accepted, rejected, and unknown prefix states", function()
            CommsPrefixRegistry.remotePlayerPrefixes["Friend-Realm"] = {
                QuestieV1 = true,
                questie = false,
            }

            assert.is_true(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "QuestieV1"))
            assert.is_false(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "QuestieV1"))
            assert.is_false(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "questie"))
            assert.is_true(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "questie"))
            assert.is_false(CommsPrefixRegistry:AcceptsPrefix("Friend-Realm", "REPUTABLE"))
            assert.is_false(CommsPrefixRegistry:RejectsPrefix("Friend-Realm", "REPUTABLE"))
            assert.is_false(CommsPrefixRegistry:AcceptsPrefix("Unknown-Realm", "QuestieV1"))
            assert.is_false(CommsPrefixRegistry:RejectsPrefix("Unknown-Realm", "QuestieV1"))
        end)

    end)

    describe("ResetAll and PruneRemotePlayers", function()
        it("clears stored remote player state", function()
            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "WHISPER", "Friend")

            CommsPrefixRegistry:ResetAll()

            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes.Friend)
            assert.is_nil(CommsPrefixRegistry.remotePlayerLastSeen.Friend)
        end)

        it("removes remote players no longer in the group", function()
            CommsPrefixRegistry.OnCommReceived("QuestieH1", "wire", "WHISPER", "Friend")
            _G.UnitInParty = function() return false end

            CommsPrefixRegistry:PruneRemotePlayers()

            assert.is_nil(CommsPrefixRegistry.remotePlayerPrefixes.Friend)
            assert.is_nil(CommsPrefixRegistry.remotePlayerLastSeen.Friend)
        end)
    end)
end)
