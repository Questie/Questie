dofile("setupTests.lua")

describe("CommsEncoding", function()
    ---@type CommsEncoding
    local CommsEncoding

    before_each(function()
        dofile("Modules/Network/CommsEncoding.lua")
        CommsEncoding = QuestieLoader:ImportModule("CommsEncoding")

        _G.Enum.CompressionMethod = {Deflate = 0}
        _G.Enum.CompressionLevel = {Default = 0}
    end)

    describe("addon-channel byte codec", function()
        it("round-trips binary data and removes null bytes", function()
            local original = "Questie\000\001binary" .. string.char(128) .. string.char(255)

            local encoded = CommsEncoding:EncodeForAddonChannel(original)
            local decoded = CommsEncoding:DecodeForAddonChannel(encoded)

            assert.are_equal(original, decoded)
            assert.is_nil(encoded:find("\000", 1, true))
        end)

        it("rejects encoded input containing reserved null bytes", function()
            assert.is_nil(CommsEncoding:DecodeForAddonChannel("bad\000wire"))
        end)

        it("errors clearly for non-string addon-channel input", function()
            assert.has_error(function()
                CommsEncoding:EncodeForAddonChannel({})
            end, "Usage: CommsEncoding:EncodeForAddonChannel(str): 'str' - string expected got 'table'.")

            assert.has_error(function()
                CommsEncoding:DecodeForAddonChannel(false)
            end, "Usage: CommsEncoding:DecodeForAddonChannel(str): 'str' - string expected got 'boolean'.")
        end)
    end)

    describe("payload codec", function()
        local calls
        local decodedPayload

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
        end

        before_each(function()
            setupBlizzardCodec()
        end)

        it("encodes payload tables through CBOR, Blizzard Deflate, and addon-safe encoding", function()
            local wire = CommsEncoding:EncodePayload({QuestieV1 = true})

            assert.are_same({"serialize", "compress"}, calls)
            assert.is_not_nil(wire)
            assert.is_nil(wire:find("\000", 1, true))
        end)

        it("decodes payload tables through addon-safe decoding, Blizzard Deflate, and CBOR", function()
            local wire = CommsEncoding:EncodePayload({QuestieV1 = true})
            calls = {}

            local payload = CommsEncoding:DecodePayload(wire)

            assert.are_same({"decompress", "deserialize"}, calls)
            assert.are_equal(decodedPayload, payload)
        end)

        it("returns nil when Blizzard codec support is unavailable", function()
            _G.C_EncodingUtil = nil

            assert.is_nil(CommsEncoding:EncodePayload({}))
            assert.is_nil(CommsEncoding:DecodePayload("wire"))
        end)

        it("returns nil when decode fails or CBOR does not produce a table", function()
            assert.is_nil(CommsEncoding:DecodePayload("bad\000wire"))

            local wire = CommsEncoding:EncodePayload({QuestieV1 = true})
            _G.C_EncodingUtil.DecompressString = spy.new(function() return nil end)
            assert.is_nil(CommsEncoding:DecodePayload(wire))

            _G.C_EncodingUtil.DecompressString = spy.new(function() return "cbor" end)
            _G.C_EncodingUtil.DeserializeCBOR = spy.new(function() return "not a table" end)
            assert.is_nil(CommsEncoding:DecodePayload(wire))
        end)
    end)
end)
