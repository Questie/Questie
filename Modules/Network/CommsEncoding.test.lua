dofile("setupTests.lua")

--[[
CommsEncoding tests stay at the codec boundary: CBOR/compression/addon-channel
mechanics, the shared transport ceiling, error handling, and support detection.
Stricter feature-specific output budgets live with each payload owner.
]]
describe("CommsEncoding", function()
    ---@type CommsEncoding
    local CommsEncoding

    ---@type l10n
    local l10n

    local LibDeflate
    local originalEncodeForAddonChannel
    local originalDecodeForAddonChannel

    ---Loads real LibDeflate and remembers the addon-channel codec functions under test.
    local function loadRealLibDeflate()
        _G.LibStub = nil
        dofile("Libs/LibStub/LibStub.lua")
        dofile("Libs/LibDeflate/LibDeflate.lua")
        LibDeflate = LibStub("LibDeflate")
        originalEncodeForAddonChannel = LibDeflate.EncodeForWoWAddonChannel
        originalDecodeForAddonChannel = LibDeflate.DecodeForWoWAddonChannel
    end

    local originalLibStub, originalEncoding, originalEnums, originalError
    local originalL10nMetatable

    before_each(function()
        originalLibStub = _G.LibStub
        originalEncoding = _G.C_EncodingUtil
        originalEnums = _G.Enum
        originalError = Questie.Error
        originalL10nMetatable = getmetatable(QuestieLoader:ImportModule("l10n"))
        _G.Enum = {CompressionMethod = {Deflate = 0}, CompressionLevel = {Default = 0}}
        Questie.Error = spy.new(function() end)
        loadRealLibDeflate()

        l10n = QuestieLoader:ImportModule("l10n")
        setmetatable(l10n, {__call = function(_, key, ...) return key end})

        dofile("Modules/Network/CommsEncoding.lua")
        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")
    end)

    after_each(function()
        _G.LibStub = originalLibStub
        _G.C_EncodingUtil = originalEncoding
        _G.Enum = originalEnums
        Questie.Error = originalError
        setmetatable(l10n, originalL10nMetatable)
    end)

    describe("real LibDeflate addon-channel codec", function()
        it("round-trips binary data and removes null bytes", function()
            local original = "Questie\000\001binary" .. string.char(128) .. string.char(255)

            local encoded = LibDeflate:EncodeForWoWAddonChannel(original)
            local decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)

            assert.are_equal(original, decoded)
            assert.is_nil(encoded:find("\000", 1, true))
        end)

        it("rejects encoded input containing reserved null bytes", function()
            assert.is_nil(LibDeflate:DecodeForWoWAddonChannel("bad\000wire"))
        end)
    end)

    describe("payload codec", function()
        local calls
        local decodedPayload

        ---Installs spies around the production encode/decode phases CommsEncoding orchestrates.
        local function setupBlizzardCodec()
            calls = {}
            decodedPayload = {QuestieH1 = true}
            _G.C_EncodingUtil = {
                SerializeCBOR = spy.new(function()
                    calls[#calls + 1] = "serialize"
                    return "cbor"
                end),
                CompressString = spy.new(function()
                    calls[#calls + 1] = "compress"
                    return "compressed\000payload"
                end),
                DecompressString = spy.new(function()
                    calls[#calls + 1] = "decompress"
                    return "cbor"
                end),
                DeserializeCBOR = spy.new(function()
                    calls[#calls + 1] = "deserialize"
                    return decodedPayload
                end),
            }

            LibDeflate.EncodeForWoWAddonChannel = spy.new(function(libDeflate, payload)
                calls[#calls + 1] = "addonEncode"
                return originalEncodeForAddonChannel(libDeflate, payload)
            end)
            LibDeflate.DecodeForWoWAddonChannel = spy.new(function(libDeflate, payload)
                calls[#calls + 1] = "addonDecode"
                return originalDecodeForAddonChannel(libDeflate, payload)
            end)
        end

        before_each(function()
            setupBlizzardCodec()
            CommsEncoding.Init()
        end)

        it("encodes payload tables through CBOR, Blizzard Deflate, and LibDeflate addon-safe encoding", function()
            local wire = CommsEncoding:EncodePayload({QuestieV1 = true})

            assert.is_true(CommsEncoding.hasCodecSupport)
            assert.spy(Questie.Error).was.not_called()
            assert.are_same({"serialize", "compress", "addonEncode"}, calls)
            assert.spy(C_EncodingUtil.SerializeCBOR).was.called_with({QuestieV1 = true})
            assert.spy(C_EncodingUtil.CompressString).was.called_with("cbor", 0, 0)
            assert.spy(LibDeflate.EncodeForWoWAddonChannel).was.called_with(LibDeflate, "compressed\000payload")
            assert.are_equal("compressed\000payload", originalDecodeForAddonChannel(LibDeflate, wire))
            assert.is_nil(wire:find("\000", 1, true))
        end)

        it("decodes payload tables through LibDeflate addon-safe decoding, Blizzard Deflate, and CBOR", function()
            local wire = originalEncodeForAddonChannel(LibDeflate, "compressed\000payload")

            local payload = CommsEncoding:DecodePayload(wire)

            assert.are_same({"addonDecode", "decompress", "deserialize"}, calls)
            assert.spy(LibDeflate.DecodeForWoWAddonChannel).was.called_with(LibDeflate, wire)
            assert.spy(C_EncodingUtil.DecompressString).was.called_with("compressed\000payload", 0)
            assert.spy(C_EncodingUtil.DeserializeCBOR).was.called_with("cbor")
            assert.are_equal(decodedPayload, payload)
        end)

        it("sets the shared ceiling to three 254-byte AceComm multipart payloads", function()
            assert.are_equal(762, CommsEncoding.MAX_ENCODED_PAYLOAD_BYTES)
        end)

        it("accepts an encoded payload that fits exactly three AceComm messages", function()
            local maxPayloadBytes = CommsEncoding.MAX_ENCODED_PAYLOAD_BYTES
            LibDeflate.EncodeForWoWAddonChannel = spy.new(function()
                return string.rep("x", maxPayloadBytes)
            end)

            local wire = CommsEncoding:EncodePayload({QuestieV1 = true})

            assert.are_equal(maxPayloadBytes, #wire)
        end)

        it("rejects an encoded payload that would require a fourth AceComm message", function()
            local oversizedPayloadBytes = CommsEncoding.MAX_ENCODED_PAYLOAD_BYTES + 1
            LibDeflate.EncodeForWoWAddonChannel = spy.new(function()
                return string.rep("x", oversizedPayloadBytes)
            end)

            assert.is_nil(CommsEncoding:EncodePayload({QuestieV1 = true}))
        end)

        it("decodes a wire payload that fits exactly three AceComm messages", function()
            local maxPayloadBytes = CommsEncoding.MAX_ENCODED_PAYLOAD_BYTES
            LibDeflate.DecodeForWoWAddonChannel = spy.new(function()
                calls[#calls + 1] = "addonDecode"
                return "compressed\000payload"
            end)

            local payload = CommsEncoding:DecodePayload(string.rep("x", maxPayloadBytes))

            assert.are_same({"addonDecode", "decompress", "deserialize"}, calls)
            assert.are_equal(decodedPayload, payload)
        end)

        it("rejects oversized and non-string wire payloads before decode work", function()
            local oversizedPayload = string.rep("x", CommsEncoding.MAX_ENCODED_PAYLOAD_BYTES + 1)

            assert.is_nil(CommsEncoding:DecodePayload(oversizedPayload))
            assert.is_nil(CommsEncoding:DecodePayload({}))
            assert.are_same({}, calls)
            assert.spy(LibDeflate.DecodeForWoWAddonChannel).was.not_called()
            assert.spy(C_EncodingUtil.DecompressString).was.not_called()
            assert.spy(C_EncodingUtil.DeserializeCBOR).was.not_called()
        end)

        it("returns nil when Blizzard codec support is unavailable", function()
            _G.C_EncodingUtil = nil
            CommsEncoding.Init()

            assert.is_false(CommsEncoding.hasCodecSupport)
            assert.spy(Questie.Error).was.called(1)
            assert.is_nil(CommsEncoding:EncodePayload({}))
            assert.is_nil(CommsEncoding:DecodePayload("wire"))
        end)

        it("reports unavailable support when LibDeflate is not installed", function()
            _G.LibStub = nil
            dofile("Libs/LibStub/LibStub.lua")
            dofile("Modules/Network/CommsEncoding.lua")
            CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")

            CommsEncoding.Init()

            assert.is_false(CommsEncoding.hasCodecSupport)
            assert.spy(Questie.Error).was.called(1)
        end)

        it("disables both directions on Init when the addon encoder is missing", function()
            local wire = originalEncodeForAddonChannel(LibDeflate, "compressed\000payload")
            LibDeflate.EncodeForWoWAddonChannel = nil
            CommsEncoding.Init()

            assert.is_false(CommsEncoding.hasCodecSupport)
            assert.is_nil(CommsEncoding:EncodePayload({QuestieV1 = true}))
            assert.is_nil(CommsEncoding:DecodePayload(wire))
            assert.are_same({}, calls)
            assert.spy(Questie.Error).was.called(1)
        end)

        it("disables both directions on Init when the addon decoder is missing", function()
            local wire = originalEncodeForAddonChannel(LibDeflate, "compressed\000payload")
            LibDeflate.DecodeForWoWAddonChannel = nil
            CommsEncoding.Init()

            assert.is_false(CommsEncoding.hasCodecSupport)
            assert.is_nil(CommsEncoding:EncodePayload({QuestieV1 = true}))
            assert.is_nil(CommsEncoding:DecodePayload(wire))
            assert.are_same({}, calls)
            assert.spy(Questie.Error).was.called(1)
        end)

        it("requires the compression enums during Init", function()
            Enum.CompressionMethod.Deflate = nil
            CommsEncoding.Init()

            assert.is_false(CommsEncoding.hasCodecSupport)
            assert.spy(Questie.Error).was.called(1)
        end)

        it("returns nil when decode fails or CBOR does not produce a table", function()
            assert.is_nil(CommsEncoding:DecodePayload("bad\000wire"))

            local wire = originalEncodeForAddonChannel(LibDeflate, "compressed\000payload")
            _G.C_EncodingUtil.DecompressString = spy.new(function() return nil end)
            assert.is_nil(CommsEncoding:DecodePayload(wire))

            _G.C_EncodingUtil.DecompressString = spy.new(function() return "cbor" end)
            _G.C_EncodingUtil.DeserializeCBOR = spy.new(function() return "not a table" end)
            assert.is_nil(CommsEncoding:DecodePayload(wire))
        end)
    end)
end)
