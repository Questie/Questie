--[[
CommsEncoding owns Questie's modern typed-prefix wire encoding:

    Lua payload table
        -> C_EncodingUtil.SerializeCBOR(payload)
        -> C_EncodingUtil.CompressString(cbor, Enum.CompressionMethod.Deflate)
        -> LibDeflate:EncodeForWoWAddonChannel(compressed)

Compression/CBOR are Blizzard-owned APIs. LibDeflate is used only for its proven
addon-channel-safe byte escaping so binary compressed payloads can travel through AceComm.
]]
---@class CommsEncoding : QuestieModule
---@field MAX_ENCODED_PAYLOAD_BYTES number
local CommsEncoding = QuestieLoader:CreateModule("CommsEncoding")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local type = type

-- AceComm reserves one byte per multipart message, leaving 254 bytes for payload.
-- All modern protocols share this ceiling so an unexpected size increase remains
-- survivable without adding per-prefix resource policy.
local ACE_COMM_MULTIPART_PAYLOAD_BYTES = 254
local MAX_ACE_COMM_MESSAGE_COUNT = 3
local MAX_ENCODED_PAYLOAD_BYTES = ACE_COMM_MULTIPART_PAYLOAD_BYTES * MAX_ACE_COMM_MESSAGE_COUNT

CommsEncoding.MAX_ENCODED_PAYLOAD_BYTES = MAX_ENCODED_PAYLOAD_BYTES

-- LibDeflate is embedded in production, but keep the modern comms optional when an
-- incomplete installation or test environment does not provide it.
local LibDeflate = LibStub("LibDeflate", true)

---Cached codec support result. Every supported WoW client has codec support, so this is checked once during Init and never re-evaluated.
---If a future client lacks it, Init raises an error so the user knows to contact us.
---@type boolean
CommsEncoding.hasCodecSupport = false

---Checks whether the client has the Blizzard CBOR/compression APIs, the compression enums and LibDeflate's addon-channel codec.
---@return boolean
local function _HasCodecSupport()
    local hasBlizzardEncoding = C_EncodingUtil ~= nil
        and C_EncodingUtil.SerializeCBOR ~= nil
        and C_EncodingUtil.DeserializeCBOR ~= nil
        and C_EncodingUtil.CompressString ~= nil
        and C_EncodingUtil.DecompressString ~= nil

    local hasDeflateEnums = Enum ~= nil
        and Enum.CompressionMethod ~= nil
        and Enum.CompressionMethod.Deflate ~= nil
        and Enum.CompressionLevel ~= nil
        and Enum.CompressionLevel.Default ~= nil

    local hasAddonChannelCodec = LibDeflate ~= nil
        and LibDeflate.EncodeForWoWAddonChannel ~= nil
        and LibDeflate.DecodeForWoWAddonChannel ~= nil

    return hasBlizzardEncoding and hasDeflateEnums and hasAddonChannelCodec
end

---Checks codec support once and caches the result.
---Every WoW client is expected to have codec support; if a future client does not, we want
---to fail loudly so the affected user reaches out to us.
function CommsEncoding.Init()
    CommsEncoding.hasCodecSupport = _HasCodecSupport()

    if (not CommsEncoding.hasCodecSupport) then
        Questie.Error("Client does not have Codec support", l10n("Please report this on Github or Discord!"))
    end
end

---@param payload table Plain Lua table accepted by Blizzard's CBOR serializer.
---@return string? encodedPayload Nil when serialization, compression, or channel encoding fails.
function CommsEncoding:EncodePayload(payload)
    if (not CommsEncoding.hasCodecSupport) then
        return nil
    end

    local ok, encoded = pcall(function()
        local cbor = C_EncodingUtil.SerializeCBOR(payload)
        local compressed = C_EncodingUtil.CompressString(cbor, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.Default)
        return LibDeflate:EncodeForWoWAddonChannel(compressed)
    end)

    if ok and type(encoded) == "string" and #encoded <= MAX_ENCODED_PAYLOAD_BYTES then
        return encoded
    end

    return nil
end

---@param message string Addon-channel-safe wire payload.
---@return table? payload Nil when any decode stage fails or the decoded value is not a table.
function CommsEncoding:DecodePayload(message)
    if type(message) ~= "string" or #message > MAX_ENCODED_PAYLOAD_BYTES then
        return nil
    end

    if (not CommsEncoding.hasCodecSupport) then
        return nil
    end

    local ok, decoded = pcall(function()
        local compressed = LibDeflate:DecodeForWoWAddonChannel(message)
        if not compressed then
            return nil
        end

        local cbor = C_EncodingUtil.DecompressString(compressed, Enum.CompressionMethod.Deflate)
        if not cbor then
            return nil
        end

        return C_EncodingUtil.DeserializeCBOR(cbor)
    end)

    if ok and type(decoded) == "table" then
        return decoded
    end

    return nil
end
