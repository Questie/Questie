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
local CommsEncoding = QuestieLoader:CreateModule("CommsEncoding")

local type = type

local LibDeflate = LibStub("LibDeflate")

---@return boolean
function CommsEncoding:HasCodecSupport()
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

---@param payload table Plain Lua table accepted by Blizzard's CBOR serializer.
---@return string? encodedPayload Nil when serialization, compression, or channel encoding fails.
function CommsEncoding:EncodePayload(payload)
    if not CommsEncoding:HasCodecSupport() then
        return nil
    end

    local ok, encoded = pcall(function()
        local cbor = C_EncodingUtil.SerializeCBOR(payload)
        local compressed = C_EncodingUtil.CompressString(cbor, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.Default)
        return LibDeflate:EncodeForWoWAddonChannel(compressed)
    end)

    if ok then
        return encoded
    end

    return nil
end

---@param message string Addon-channel-safe wire payload.
---@return table? payload Nil when any decode stage fails or the decoded value is not a table.
function CommsEncoding:DecodePayload(message)
    if not CommsEncoding:HasCodecSupport() then
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
