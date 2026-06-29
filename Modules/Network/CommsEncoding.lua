--[[
CommsEncoding owns Questie's modern typed-prefix wire encoding:

    Lua payload table
        -> C_EncodingUtil.SerializeCBOR(payload)
        -> C_EncodingUtil.CompressString(cbor, Enum.CompressionMethod.Deflate)
        -> addon-channel-safe byte escaping

The addon-channel-safe byte codec below is an altered, trimmed subset of LibDeflate
1.0.2-release by Haoqian He (Github: SafeteeWoW; World of Warcraft:
Safetyy-Illidan(US)). The source project is https://github.com/safeteeWow/LibDeflate;
this subset was imported from the 1.0.2-release package with project hash
c19f978f053ebd22950eb6f1df4445677a4b0160.

Only the addon-channel codec path was retained: CreateCodec plus the behavior of
LibDeflate:EncodeForWoWAddonChannel and LibDeflate:DecodeForWoWAddonChannel. Questie
removed LibDeflate's Deflate/Zlib/Gzip compression/decompression implementation and uses
Blizzard's C_EncodingUtil for compression instead.

The retained codec is the LibCompress-derived custom codec machinery from LibDeflate.
LibDeflate credits LibCompress by jjsheets and Galmok of European Stormrage (Horde):
https://www.wowace.com/projects/libcompress, licensed under GPLv2:
https://www.gnu.org/licenses/old-licenses/gpl-2.0.html. The code was modified by
LibDeflate's author and further trimmed here for Questie's addon-channel use only.

Original LibDeflate license notice:

zlib License

(C) 2018-2020 Haoqian He

This software is provided 'as-is', without any express or implied warranty. In no event
will the authors be held liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose, including commercial
applications, and to alter it and redistribute it freely, subject to the following
restrictions:

1. The origin of this software must not be misrepresented; you must not claim that you
   wrote the original software. If you use this software in a product, an acknowledgment
   in the product documentation would be appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be misrepresented
   as being the original software.
3. This notice may not be removed or altered from any source distribution.

]]
---@class CommsEncoding : QuestieModule
local CommsEncoding = QuestieLoader:CreateModule("CommsEncoding")

local error = error
local string_byte = string.byte
local string_char = string.char
local string_find = string.find
local string_gsub = string.gsub
local string_sub = string.sub
local table_concat = table.concat
local type = type

local _byte_to_char = {}
for i = 0, 255 do
    _byte_to_char[i] = string_char(i)
end

local _gsub_escape_table = {
    ["\000"] = "%z", ["("] = "%(", [")"] = "%)", ["."] = "%.",
    ["%"] = "%%", ["+"] = "%+", ["-"] = "%-", ["*"] = "%*",
    ["?"] = "%?", ["["] = "%[", ["]"] = "%]", ["^"] = "%^",
    ["$"] = "%$",
}

local function _EscapeForGsub(str)
    return string_gsub(str, "([%z%(%)%.%%%+%-%*%?%[%]%^%$])", _gsub_escape_table)
end

---Create a custom codec that escapes bytes disallowed by the target channel.
---Trimmed from LibDeflate's LibCompress-derived CreateCodec implementation.
---@param reservedChars string
---@param escapeChars string
---@param mapChars string
---@return table? codec
---@return string? errorMessage
local function _CreateCodec(reservedChars, escapeChars, mapChars)
    if type(reservedChars) ~= "string" or type(escapeChars) ~= "string" or type(mapChars) ~= "string" then
        error("Usage: CommsEncoding CreateCodec(reservedChars, escapeChars, mapChars): All arguments must be string.", 2)
    end

    if escapeChars == "" then
        return nil, "No escape characters supplied."
    end
    if #reservedChars < #mapChars then
        return nil, "The number of reserved characters must be at least as many as the number of mapped chars."
    end
    if reservedChars == "" then
        return nil, "No characters to encode."
    end

    local encodeBytes = reservedChars .. escapeChars .. mapChars
    local taken = {}
    for i = 1, #encodeBytes do
        local byte = string_byte(encodeBytes, i, i)
        if taken[byte] then
            return nil, "There must be no duplicate characters in the concatenation of reservedChars, escapeChars and mapChars."
        end
        taken[byte] = true
    end

    local decodePatterns = {}
    local decodeRepls = {}
    local encodeSearch = {}
    local encodeTranslate = {}

    if #mapChars > 0 then
        local decodeSearch = {}
        local decodeTranslate = {}
        for i = 1, #mapChars do
            local from = string_sub(reservedChars, i, i)
            local to = string_sub(mapChars, i, i)
            encodeTranslate[from] = to
            encodeSearch[#encodeSearch + 1] = from
            decodeTranslate[to] = from
            decodeSearch[#decodeSearch + 1] = to
        end
        decodePatterns[#decodePatterns + 1] = "([" .. _EscapeForGsub(table_concat(decodeSearch)) .. "])"
        decodeRepls[#decodeRepls + 1] = decodeTranslate
    end

    local escapeCharIndex = 1
    local escapeChar = string_sub(escapeChars, escapeCharIndex, escapeCharIndex)
    local r = 0
    local decodeSearch = {}
    local decodeTranslate = {}
    for i = 1, #encodeBytes do
        local c = string_sub(encodeBytes, i, i)
        if not encodeTranslate[c] then
            while r >= 256 or taken[r] do
                r = r + 1
                if r > 255 then
                    decodePatterns[#decodePatterns + 1] = _EscapeForGsub(escapeChar) .. "([" .. _EscapeForGsub(table_concat(decodeSearch)) .. "])"
                    decodeRepls[#decodeRepls + 1] = decodeTranslate

                    escapeCharIndex = escapeCharIndex + 1
                    escapeChar = string_sub(escapeChars, escapeCharIndex, escapeCharIndex)
                    r = 0
                    decodeSearch = {}
                    decodeTranslate = {}

                    if not escapeChar or escapeChar == "" then
                        return nil, "Out of escape characters."
                    end
                end
            end

            local charR = _byte_to_char[r]
            encodeTranslate[c] = escapeChar .. charR
            encodeSearch[#encodeSearch + 1] = c
            decodeTranslate[charR] = c
            decodeSearch[#decodeSearch + 1] = charR
            r = r + 1
        end
        if i == #encodeBytes then
            decodePatterns[#decodePatterns + 1] = _EscapeForGsub(escapeChar) .. "([" .. _EscapeForGsub(table_concat(decodeSearch)) .. "])"
            decodeRepls[#decodeRepls + 1] = decodeTranslate
        end
    end

    local codec = {}
    local encodePattern = "([" .. _EscapeForGsub(table_concat(encodeSearch)) .. "])"
    local encodeRepl = encodeTranslate

    function codec:Encode(str)
        if type(str) ~= "string" then
            error(("Usage: codec:Encode(str): 'str' - string expected got '%s'."):format(type(str)), 2)
        end
        return string_gsub(str, encodePattern, encodeRepl)
    end

    local decodeTableSize = #decodePatterns
    local decodeFailPattern = "([" .. _EscapeForGsub(reservedChars) .. "])"

    function codec:Decode(str)
        if type(str) ~= "string" then
            error(("Usage: codec:Decode(str): 'str' - string expected got '%s'."):format(type(str)), 2)
        end
        if string_find(str, decodeFailPattern) then
            return nil
        end
        for i = 1, decodeTableSize do
            str = string_gsub(str, decodePatterns[i], decodeRepls[i])
        end
        return str
    end

    return codec
end

local addonChannelCodec

local function _GetAddonChannelCodec()
    if not addonChannelCodec then
        addonChannelCodec = _CreateCodec("\000", "\001", "")
    end

    return addonChannelCodec
end

---@return boolean
function CommsEncoding:HasCodecSupport()
    return C_EncodingUtil
        and C_EncodingUtil.SerializeCBOR
        and C_EncodingUtil.DeserializeCBOR
        and C_EncodingUtil.CompressString
        and C_EncodingUtil.DecompressString
        and Enum
        and Enum.CompressionMethod
        and Enum.CompressionMethod.Deflate ~= nil
        and Enum.CompressionLevel
        and Enum.CompressionLevel.Default ~= nil
end

---Encode arbitrary binary into a string safe for WoW addon channels.
---@param str string
---@return string
function CommsEncoding:EncodeForAddonChannel(str)
    if type(str) ~= "string" then
        error(("Usage: CommsEncoding:EncodeForAddonChannel(str): 'str' - string expected got '%s'."):format(type(str)), 2)
    end

    return _GetAddonChannelCodec():Encode(str)
end

---Decode a string produced by EncodeForAddonChannel.
---@param str string
---@return string?
function CommsEncoding:DecodeForAddonChannel(str)
    if type(str) ~= "string" then
        error(("Usage: CommsEncoding:DecodeForAddonChannel(str): 'str' - string expected got '%s'."):format(type(str)), 2)
    end

    return _GetAddonChannelCodec():Decode(str)
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
        return CommsEncoding:EncodeForAddonChannel(compressed)
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
        local compressed = CommsEncoding:DecodeForAddonChannel(message)
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
