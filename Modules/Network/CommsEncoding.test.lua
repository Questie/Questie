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

    before_each(function()
        loadRealLibDeflate()

        l10n = QuestieLoader:ImportModule("l10n")
        setmetatable(l10n, {__call = function(_, key, ...) return key end})

        dofile("Modules/Network/CommsEncoding.lua")
        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")

        -- Simulate a successful Init so the encode/decode guards pass.
        CommsEncoding.hasCodecSupport = true

        _G.Enum.CompressionMethod = {Deflate = 0}
        _G.Enum.CompressionLevel = {Default = 0}
    end)

    it("should report unavailable codec support and raise an error on Init", function()
        _G.LibStub = nil
        _G.Questie.Error = spy.new(function() end)
        dofile("Libs/LibStub/LibStub.lua")

        dofile("Modules/Network/CommsEncoding.lua")
        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")

        assert.is_false(CommsEncoding:HasCodecSupport())
        CommsEncoding.Init()

        assert.spy(Questie.Error).was.called()
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
                SerializeCBOR = spy.new(function(payload)
                    calls[#calls + 1] = "serialize"
                    assert.are_same({QuestieV1 = true}, payload)
                    return "cbor"
                end),
                CompressString = spy.new(function(payload, method, level)
                    calls[#calls + 1] = "compress"
                    assert.are_equal("cbor", payload)
                    assert.are_equal(Enum.CompressionMethod.Deflate, method)
                    assert.are_equal(Enum.CompressionLevel.Default, level)
                    return "compressed\000payload"
                end),
                DecompressString = spy.new(function(payload, method)
                    calls[#calls + 1] = "decompress"
                    assert.are_equal("compressed\000payload", payload)
                    assert.are_equal(Enum.CompressionMethod.Deflate, method)
                    return "cbor"
                end),
                DeserializeCBOR = spy.new(function(payload)
                    calls[#calls + 1] = "deserialize"
                    assert.are_equal("cbor", payload)
                    return decodedPayload
                end),
            }

            LibDeflate.EncodeForWoWAddonChannel = spy.new(function(libDeflate, payload)
                calls[#calls + 1] = "addonEncode"
                assert.are_equal(LibDeflate, libDeflate)
                assert.are_equal("compressed\000payload", payload)
                return originalEncodeForAddonChannel(libDeflate, payload)
            end)
            LibDeflate.DecodeForWoWAddonChannel = spy.new(function(libDeflate, payload)
                calls[#calls + 1] = "addonDecode"
                assert.are_equal(LibDeflate, libDeflate)
                return originalDecodeForAddonChannel(libDeflate, payload)
            end)
        end

        before_each(function()
            setupBlizzardCodec()
        end)

        it("encodes payload tables through CBOR, Blizzard Deflate, and LibDeflate addon-safe encoding", function()
            local wire = CommsEncoding:EncodePayload({QuestieV1 = true})

            assert.are_same({"serialize", "compress", "addonEncode"}, calls)
            assert.are_equal("compressed\000payload", originalDecodeForAddonChannel(LibDeflate, wire))
            assert.is_nil(wire:find("\000", 1, true))
        end)

        it("decodes payload tables through LibDeflate addon-safe decoding, Blizzard Deflate, and CBOR", function()
            local wire = originalEncodeForAddonChannel(LibDeflate, "compressed\000payload")

            local payload = CommsEncoding:DecodePayload(wire)

            assert.are_same({"addonDecode", "decompress", "deserialize"}, calls)
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
            LibDeflate.DecodeForWoWAddonChannel = spy.new(function(libDeflate, payload)
                calls[#calls + 1] = "addonDecode"
                assert.are_equal(LibDeflate, libDeflate)
                assert.are_equal(maxPayloadBytes, #payload)
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

            assert.is_nil(CommsEncoding:EncodePayload({}))
            assert.is_nil(CommsEncoding:DecodePayload("wire"))
        end)

        it("returns nil when LibDeflate support is unavailable", function()
            LibDeflate.EncodeForWoWAddonChannel = nil

            assert.is_nil(CommsEncoding:EncodePayload({}))
            assert.is_nil(CommsEncoding:DecodePayload("wire"))
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
