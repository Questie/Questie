dofile("setupTests.lua")

describe("CommsHello", function()
    ---@type CommsHello
    local CommsHello

    ---@type QuestiePlayer
    local QuestiePlayer

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
        _G.C_Timer = nil

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetGroupType = function() return "party" end

        dofile("Modules/Network/CommsEncoding.lua")
        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
        setupCodec({QuestieH1 = true, QuestieV1 = true, questie = true, Questie = true, REPUTABLE = true})

        dofile("Modules/Network/CommsHello.lua")
        CommsHello = QuestieLoader:ImportModule("CommsHello")
        CommsHello:ResetAll()
    end)

    describe("Initialize", function()
        it("registers the QuestieH1 comm prefix when the codec is available", function()
            local initialized = CommsHello:Initialize()

            assert.is_true(initialized)
            assert.spy(Questie.RegisterComm).was.called_with(Questie, "QuestieH1", CommsHello.OnCommReceived)
            assert.is_true(CommsHello:GetLocalPrefixState("QuestieH1"))
        end)

        it("does not register when modern payload encoding is unavailable", function()
            CommsEncoding.HasCodecSupport = spy.new(function() return false end)
            dofile("Modules/Network/CommsHello.lua")
            CommsHello = QuestieLoader:ImportModule("CommsHello")

            local initialized = CommsHello:Initialize()

            assert.is_false(initialized)
            assert.spy(Questie.RegisterComm).was.not_called()
            assert.is_false(CommsHello:GetLocalPrefixState("QuestieH1"))
        end)
    end)

    describe("Local prefix states", function()
        it("defaults every known prefix to false until the owning receiver registers it", function()
            assert.is_false(CommsHello:GetLocalPrefixState("QuestieH1"))
            assert.is_false(CommsHello:GetLocalPrefixState("QuestieV1"))
            assert.is_false(CommsHello:GetLocalPrefixState("questie"))
            assert.is_false(CommsHello:GetLocalPrefixState("Questie"))
            assert.is_false(CommsHello:GetLocalPrefixState("REPUTABLE"))
        end)

        it("marks only known local prefixes active", function()
            assert.is_true(CommsHello:RegisterLocalPrefix("QuestieV1"))
            assert.is_true(CommsHello:RegisterLocalPrefix("Questie"))
            assert.is_true(CommsHello:RegisterLocalPrefix("questie"))
            assert.is_true(CommsHello:RegisterLocalPrefix("REPUTABLE"))

            assert.is_true(CommsHello:GetLocalPrefixState("QuestieV1"))
            assert.is_true(CommsHello:GetLocalPrefixState("Questie"))
            assert.is_true(CommsHello:GetLocalPrefixState("questie"))
            assert.is_true(CommsHello:GetLocalPrefixState("REPUTABLE"))
        end)

        it("reports undefined local prefixes once after a short delay", function()
            local scheduledDelay
            local scheduledCallback
            _G.C_Timer = {
                After = spy.new(function(delay, callback)
                    scheduledDelay = delay
                    scheduledCallback = callback
                end),
            }

            assert.is_false(CommsHello:RegisterLocalPrefix("QuestieZ9"))
            assert.is_false(CommsHello:RegisterLocalPrefix("QuestieZ9"))

            assert.is_nil(CommsHello:GetLocalPrefixState("QuestieZ9"))
            assert.spy(_G.C_Timer.After).was.called(1)
            assert.are_equal(5, scheduledDelay)
            assert.are_equal("function", type(scheduledCallback))
            assert.spy(Questie.Error).was.not_called()

            scheduledCallback()

            assert.spy(Questie.Error).was.called(1)
            assert.spy(Questie.Error).was.called_with(Questie, "[CommsHello] A module tried to register undefined Questie comm prefix 'QuestieZ9'. Add it to the QuestieH1 prefix manifest before registering support.")
        end)
    end)

    describe("SendHello", function()
        it("sends the registered local prefix map to party using the modern payload encoder", function()
            CommsHello:Initialize()
            CommsHello:RegisterLocalPrefix("Questie")
            CommsHello:RegisterLocalPrefix("REPUTABLE")

            local sent = CommsHello:SendHello()

            assert.is_true(sent)
            assert.are_same({QuestieH1 = true, QuestieV1 = false, questie = false, Questie = true, REPUTABLE = true}, serializedPayload)
            assert.spy(CommsEncoding.EncodePayload).was.called(1)
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "PARTY")
        end)

        it("uses raid and instance distributions based on the group type", function()
            QuestiePlayer.GetGroupType = function() return "raid" end
            CommsHello:SendHello()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "RAID")

            Questie.SendCommMessage:clear()
            QuestiePlayer.GetGroupType = function() return "instance" end
            CommsHello:SendHello()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieH1", "wire", "INSTANCE_CHAT")
        end)

        it("does not send outside a group", function()
            QuestiePlayer.GetGroupType = function() return nil end

            local sent = CommsHello:SendHello()

            assert.is_false(sent)
            assert.spy(Questie.SendCommMessage).was.not_called()
        end)
    end)

    describe("OnCommReceived", function()
        it("stores only known boolean prefixes from group members", function()
            setupCodec({QuestieH1 = true, QuestieV1 = false, questie = true, Questie = "yes", REPUTABLE = false, QuestieZ9 = true})
            _G.UnitInParty = function(unit) return unit == "Friend-Realm" end

            CommsHello.OnCommReceived("QuestieH1", "wire", "WHISPER", "Friend-Realm")

            assert.is_true(CommsHello:IsPeerListening("Friend-Realm", "QuestieH1"))
            assert.is_true(CommsHello:IsPeerListening("Friend-Realm", "questie"))
            assert.is_true(CommsHello:DoesPeerRejectPrefix("Friend-Realm", "QuestieV1"))
            assert.is_true(CommsHello:DoesPeerRejectPrefix("Friend-Realm", "REPUTABLE"))
            assert.is_nil(CommsHello:GetPeerPrefixState("Friend-Realm", "Questie"))
            assert.is_nil(CommsHello:GetPeerPrefixState("Friend-Realm", "QuestieZ9"))
            assert.are_equal(123, CommsHello.peerLastSeen["Friend-Realm"])
            assert.is_nil(CommsHello.peerPrefixes.Friend)
        end)

        it("ignores messages from self", function()
            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Player")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsHello.peerPrefixes.Player)
        end)

        it("ignores messages from the local full name", function()
            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Player-HomeRealm")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsHello.peerPrefixes["Player-HomeRealm"])
        end)

        it("uses UnitFullName instead of display realm for local full-name self checks", function()
            _G.UnitFullName = function(unit)
                if unit == "player" then
                    return "Player", "MyRealm"
                end
            end
            _G.GetNormalizedRealmName = function() return "WrongRealm" end
            _G.GetRealmName = function() return "My Realm" end

            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Player-MyRealm")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsHello.peerPrefixes["Player-MyRealm"])
        end)

        it("uses normalized realm fallback for local full-name self checks", function()
            _G.UnitFullName = nil
            _G.GetNormalizedRealmName = function() return "MyRealm" end
            _G.GetRealmName = function() return "My Realm" end

            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Player-MyRealm")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsHello.peerPrefixes["Player-MyRealm"])
        end)

        it("does not treat same-name cross-realm peers as self", function()
            _G.UnitInParty = function(unit) return unit == "Player-OtherRealm" end

            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Player-OtherRealm")

            assert.is_true(CommsHello:IsPeerListening("Player-OtherRealm", "QuestieH1"))
        end)

        it("keeps same-name peers from different realms separate", function()
            _G.UnitInParty = function(unit)
                return unit == "Friend-RealmOne" or unit == "Friend-RealmTwo"
            end

            setupCodec({QuestieH1 = true, questie = true})
            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend-RealmOne")
            setupCodec({QuestieH1 = false, questie = false})
            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend-RealmTwo")

            assert.is_true(CommsHello:IsPeerListening("Friend-RealmOne", "QuestieH1"))
            assert.is_true(CommsHello:IsPeerListening("Friend-RealmOne", "questie"))
            assert.is_true(CommsHello:DoesPeerRejectPrefix("Friend-RealmTwo", "QuestieH1"))
            assert.is_true(CommsHello:DoesPeerRejectPrefix("Friend-RealmTwo", "questie"))
            assert.is_nil(CommsHello.peerPrefixes.Friend)
        end)

        it("ignores whispers from non-group senders", function()
            CommsHello.OnCommReceived("QuestieH1", "wire", "WHISPER", "Stranger")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsHello.peerPrefixes.Stranger)
        end)

        it("ignores unsupported distributions", function()
            CommsHello.OnCommReceived("QuestieH1", "wire", "GUILD", "Friend")

            assert.spy(CommsEncoding.DecodePayload).was.not_called()
            assert.is_nil(CommsHello.peerPrefixes.Friend)
        end)

        it("ignores malformed payloads without throwing", function()
            CommsEncoding.DecodePayload = spy.new(function() return nil end)

            assert.has_no.errors(function()
                CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend")
            end)
            assert.is_nil(CommsHello.peerPrefixes.Friend)
        end)
    end)

    describe("ResetAll and PrunePeers", function()
        it("clears stored peer state", function()
            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend")

            CommsHello:ResetAll()

            assert.is_nil(CommsHello.peerPrefixes.Friend)
            assert.is_nil(CommsHello.peerLastSeen.Friend)
        end)

        it("removes peers no longer in the group", function()
            CommsHello.OnCommReceived("QuestieH1", "wire", "PARTY", "Friend")
            _G.UnitInParty = function() return false end

            CommsHello:PrunePeers()

            assert.is_nil(CommsHello.peerPrefixes.Friend)
            assert.is_nil(CommsHello.peerLastSeen.Friend)
        end)
    end)
end)
