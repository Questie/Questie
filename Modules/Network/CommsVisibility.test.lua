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

    ---@type LibDeflate
    local LibDeflate

    local serializedPayload

    local function setupCodec(decodedPayload)
        _G.Enum.CompressionMethod = {Deflate = 0}
        _G.Enum.CompressionLevel = {Default = 0}

        _G.C_EncodingUtil = {
            SerializeCBOR = spy.new(function(payload)
                serializedPayload = payload
                return "cbor"
            end),
            CompressString = spy.new(function(payload, method, level)
                return "compressed:" .. payload .. ":" .. method .. ":" .. level
            end),
            DecompressString = spy.new(function(payload, method)
                if payload == "compressed" and method == Enum.CompressionMethod.Deflate then
                    return "cbor"
                end

                return nil
            end),
            DeserializeCBOR = spy.new(function(payload)
                if payload == "cbor" then
                    return decodedPayload
                end

                return nil
            end),
        }

        LibDeflate.EncodeForWoWAddonChannel = spy.new(function(_, payload)
            return "wire:" .. payload
        end)
        LibDeflate.DecodeForWoWAddonChannel = spy.new(function(_, payload)
            if payload == "wire" then
                return "compressed"
            end

            return nil
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

        LibDeflate = QuestieLoader:ImportModule("LibDeflate")
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

        it("does not register when Blizzard encoding is unavailable", function()
            _G.C_EncodingUtil = nil
            dofile("Modules/Network/CommsVisibility.lua")
            CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")

            local initialized = CommsVisibility:Initialize()

            assert.is_false(initialized)
            assert.spy(Questie.RegisterComm).was.not_called()
            assert.spy(CommsHello.RegisterLocalPrefix).was.not_called()
        end)
    end)

    describe("BuildLocalSnapshot", function()
        it("builds a visibility map from the current quest log only", function()
            Questie.db.char.hidden = {[303] = true}
            QuestLogCache.questLog_DO_NOT_MODIFY = {
                [101] = true,
                [202] = true,
                [303] = true,
                notAQuestId = true,
            }

            local snapshot = CommsVisibility:BuildLocalSnapshot()

            assert.are_same({
                [101] = true,
                [202] = false,
                [303] = false,
            }, snapshot)
        end)
    end)

    describe("SendSnapshot", function()
        it("sends the full visibility map to party using CBOR, Blizzard deflate, and addon-channel encoding", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {[101] = true, [202] = true}

            local sent = CommsVisibility:SendSnapshot()

            assert.is_true(sent)
            assert.are_same({[101] = true, [202] = false}, serializedPayload)
            assert.spy(_G.C_EncodingUtil.SerializeCBOR).was.called(1)
            assert.spy(_G.C_EncodingUtil.CompressString).was.called_with("cbor", Enum.CompressionMethod.Deflate, Enum.CompressionLevel.Default)
            assert.spy(LibDeflate.EncodeForWoWAddonChannel).was.called(1)
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieV1", "wire:compressed:cbor:0:0", "PARTY")
        end)

        it("uses raid and instance distributions based on the group type", function()
            QuestiePlayer.GetGroupType = function() return "raid" end
            CommsVisibility:SendSnapshot()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieV1", "wire:compressed:cbor:0:0", "RAID")

            Questie.SendCommMessage:clear()
            QuestiePlayer.GetGroupType = function() return "instance" end
            CommsVisibility:SendSnapshot()
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "QuestieV1", "wire:compressed:cbor:0:0", "INSTANCE_CHAT")
        end)

        it("does not send outside a group", function()
            QuestiePlayer.GetGroupType = function() return nil end

            local sent = CommsVisibility:SendSnapshot()

            assert.is_false(sent)
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

            assert.spy(LibDeflate.DecodeForWoWAddonChannel).was.not_called()
            assert.is_nil(CommsVisibility.remoteQuestVisibility.Player)
        end)

        it("rejects non-group whispers before decoding", function()
            _G.UnitInParty = function() return false end
            _G.UnitInRaid = function() return false end

            CommsVisibility.OnCommReceived("QuestieV1", "wire", "WHISPER", "Stranger-Realm")

            assert.spy(LibDeflate.DecodeForWoWAddonChannel).was.not_called()
            assert.is_nil(CommsVisibility.remoteQuestVisibility["Stranger-Realm"])
        end)

        it("ignores malformed payloads safely", function()
            LibDeflate.DecodeForWoWAddonChannel = spy.new(function() return nil end)

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

    describe("ResetAll and PrunePeers", function()
        it("clears all remote visibility", function()
            CommsVisibility.remoteQuestVisibility["Friend-Realm"] = {[101] = true}

            CommsVisibility:ResetAll()

            assert.are_same({}, CommsVisibility.remoteQuestVisibility)
        end)

        it("drops peers that are no longer in the group", function()
            CommsVisibility.remoteQuestVisibility["Friend-Realm"] = {[101] = true}
            CommsVisibility.remoteQuestVisibility["Gone-Realm"] = {[202] = false}
            _G.UnitInParty = function(unit) return unit == "Friend-Realm" end

            CommsVisibility:PrunePeers()

            assert.are_same({[101] = true}, CommsVisibility.remoteQuestVisibility["Friend-Realm"])
            assert.is_nil(CommsVisibility.remoteQuestVisibility["Gone-Realm"])
        end)
    end)
end)
