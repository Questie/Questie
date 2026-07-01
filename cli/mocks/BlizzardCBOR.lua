-- luacheck: globals QuestieBlizzardCBORMock

---@class BlizzardCBORMock
---@field SerializeCBOR fun(value: any, options?: CBORSerializationOptions): string
---@field DeserializeCBOR fun(source: string): any
---@field InstallEncodingUtilMock fun(targetGlobal?: table): table
local BlizzardCBOR = {}

---@class CBORSerializationOptions
---@field ignoreSerializationErrors boolean? Replaces unsupported Lua values with CBOR undefined items when true.

---@class BlizzardCBOREncodeState
---@field ignoreSerializationErrors boolean
---@field activeTables table<table, boolean>

local char = string.char
local byte = string.byte
local sub = string.sub
local concat = table.concat
local floor = math.floor
local frexp = math.frexp
local ldexp = math.ldexp
local huge = math.huge

local MAX_NESTING_DEPTH = 100
local MAX_SAFE_INTEGER = 9007199254740992

local TWO_8 = 256
local TWO_10 = 1024
local TWO_16 = 65536
local TWO_20 = 1048576
local TWO_23 = 8388608
local TWO_31 = 2147483648
local TWO_32 = 4294967296
local TWO_52 = 4503599627370496

local MAJOR_UNSIGNED = 0
local MAJOR_NEGATIVE = 1
local MAJOR_BYTE_STRING = 2
local MAJOR_TEXT_STRING = 3
local MAJOR_ARRAY = 4
local MAJOR_MAP = 5
local MAJOR_TAG = 6
local MAJOR_SIMPLE = 7

local CBOR_FALSE = char(0xF4)
local CBOR_TRUE = char(0xF5)
local CBOR_NULL = char(0xF6)
local CBOR_UNDEFINED = char(0xF7)

-- Numeric encoding mechanics: pure Lua 5.1 arithmetic, no bit libraries or string.pack.
---Reports whether a Lua number carries the negative-zero sign bit.
---@param value number Number to inspect.
---@return boolean isNegativeZero True when the value is exactly -0.0.
local function _IsNegativeZero(value)
    return value == 0 and 1 / value == -huge
end

---Compares numbers while preserving NaN and signed-zero semantics.
---@param left number First number.
---@param right number Second number.
---@return boolean isSame True when the CBOR numeric representation round-trips exactly enough for preferred sizing.
local function _NumbersEncodeSame(left, right)
    if left ~= left and right ~= right then
        return true
    end

    if left == 0 and right == 0 then
        return _IsNegativeZero(left) == _IsNegativeZero(right)
    end

    return left == right
end

---Reports whether a Lua number is finite.
---@param value number Number to inspect.
---@return boolean isFinite True when the value is neither NaN nor infinite.
local function _IsFinite(value)
    return value == value and value ~= huge and value ~= -huge
end

---Reports whether a Lua 5.1 number is safe to encode as a CBOR integer.
---@param value number Number to inspect.
---@return boolean isInteger True when the value is integral and within the exact double-integer range.
local function _IsSafeInteger(value)
    return _IsFinite(value)
        and not _IsNegativeZero(value)
        and value >= -MAX_SAFE_INTEGER
        and value <= MAX_SAFE_INTEGER
        and value % 1 == 0
end

---Encodes an unsigned integer as big-endian bytes.
---@param value number Non-negative integer value.
---@param byteCount number Number of bytes to emit.
---@return string bytes Big-endian byte string.
local function _EncodeUnsignedIntegerBytes(value, byteCount)
    local bytes = {}

    for index = byteCount, 1, -1 do
        bytes[index] = char(value % TWO_8)
        value = floor(value / TWO_8)
    end

    return concat(bytes)
end

---Encodes a CBOR major type and preferred-width unsigned argument.
---@param majorType number CBOR major type number, 0 through 7.
---@param value number Non-negative integer argument.
---@return string bytes Encoded header and argument bytes.
local function _EncodeMajorArgument(majorType, value)
    local majorByte = majorType * 32

    if value < 24 then
        return char(majorByte + value)
    elseif value < TWO_8 then
        return char(majorByte + 24) .. _EncodeUnsignedIntegerBytes(value, 1)
    elseif value < TWO_16 then
        return char(majorByte + 25) .. _EncodeUnsignedIntegerBytes(value, 2)
    elseif value < TWO_32 then
        return char(majorByte + 26) .. _EncodeUnsignedIntegerBytes(value, 4)
    else
        return char(majorByte + 27) .. _EncodeUnsignedIntegerBytes(value, 8)
    end
end

---Decodes IEEE-754 half-precision bits to a Lua number.
---@param bits number Unsigned 16-bit half-precision payload.
---@return number value Decoded Lua number.
local function _DecodeHalfBits(bits)
    local sign = 1
    if bits >= 0x8000 then
        sign = -1
        bits = bits - 0x8000
    end

    local exponent = floor(bits / TWO_10)
    local mantissa = bits % TWO_10

    if exponent == 0 then
        if mantissa == 0 then
            return sign * 0.0
        end

        return sign * ldexp(mantissa, -24)
    elseif exponent == 31 then
        if mantissa == 0 then
            return sign * huge
        end

        return 0.0 / 0.0
    end

    return sign * ldexp(1 + mantissa / TWO_10, exponent - 15)
end

---Encodes a Lua number as IEEE-754 half bits when the value is representable.
---@param value number Number to encode.
---@return number? bits Unsigned 16-bit payload, or nil when finite value is out of range.
local function _EncodeHalfBits(value)
    if value ~= value then
        return 0x7E00
    end

    local signBit = 0
    if value < 0 or _IsNegativeZero(value) then
        signBit = 0x8000
        value = -value
    end

    if value == huge then
        return signBit + 0x7C00
    elseif value == 0 then
        return signBit
    end

    local mantissa, exponent = frexp(value)
    local biasedExponent = exponent + 14

    if biasedExponent > 0 then
        if biasedExponent >= 31 then
            return nil
        end

        local encodedMantissa = floor((mantissa * 2 - 1) * TWO_10 + 0.5)
        if encodedMantissa == TWO_10 then
            biasedExponent = biasedExponent + 1
            encodedMantissa = 0
            if biasedExponent >= 31 then
                return nil
            end
        end

        return signBit + biasedExponent * TWO_10 + encodedMantissa
    end

    local encodedSubnormal = floor(ldexp(value, 24) + 0.5)
    if encodedSubnormal <= 0 or encodedSubnormal >= TWO_10 then
        return nil
    end

    return signBit + encodedSubnormal
end

---Decodes IEEE-754 single-precision bits to a Lua number.
---@param bits number Unsigned 32-bit single-precision payload.
---@return number value Decoded Lua number.
local function _DecodeSingleBits(bits)
    local sign = 1
    if bits >= TWO_31 then
        sign = -1
        bits = bits - TWO_31
    end

    local exponent = floor(bits / TWO_23)
    local mantissa = bits % TWO_23

    if exponent == 0 then
        if mantissa == 0 then
            return sign * 0.0
        end

        return sign * ldexp(mantissa, -149)
    elseif exponent == 255 then
        if mantissa == 0 then
            return sign * huge
        end

        return 0.0 / 0.0
    end

    return sign * ldexp(1 + mantissa / TWO_23, exponent - 127)
end

---Encodes a Lua number as IEEE-754 single bits when the value is representable.
---@param value number Number to encode.
---@return number? bits Unsigned 32-bit payload, or nil when finite value is out of range.
local function _EncodeSingleBits(value)
    if value ~= value then
        return 0x7FC00000
    end

    local signBit = 0
    if value < 0 or _IsNegativeZero(value) then
        signBit = TWO_31
        value = -value
    end

    if value == huge then
        return signBit + 0x7F800000
    elseif value == 0 then
        return signBit
    end

    local mantissa, exponent = frexp(value)
    local biasedExponent = exponent + 126

    if biasedExponent > 0 then
        if biasedExponent >= 255 then
            return nil
        end

        local encodedMantissa = floor((mantissa * 2 - 1) * TWO_23 + 0.5)
        if encodedMantissa == TWO_23 then
            biasedExponent = biasedExponent + 1
            encodedMantissa = 0
            if biasedExponent >= 255 then
                return nil
            end
        end

        return signBit + biasedExponent * TWO_23 + encodedMantissa
    end

    local encodedSubnormal = floor(ldexp(value, 149) + 0.5)
    if encodedSubnormal <= 0 or encodedSubnormal >= TWO_23 then
        return nil
    end

    return signBit + encodedSubnormal
end

---Decodes IEEE-754 double-precision words to a Lua number.
---@param highWord number Most-significant 32 bits.
---@param lowWord number Least-significant 32 bits.
---@return number value Decoded Lua number.
local function _DecodeDoubleWords(highWord, lowWord)
    local sign = 1
    if highWord >= TWO_31 then
        sign = -1
        highWord = highWord - TWO_31
    end

    local exponent = floor(highWord / TWO_20)
    local mantissa = (highWord % TWO_20) * TWO_32 + lowWord

    if exponent == 0 then
        if mantissa == 0 then
            return sign * 0.0
        end

        return sign * ldexp(mantissa, -1074)
    elseif exponent == 2047 then
        if mantissa == 0 then
            return sign * huge
        end

        return 0.0 / 0.0
    end

    return sign * ldexp(1 + mantissa / TWO_52, exponent - 1023)
end

---Encodes a Lua number as eight IEEE-754 double bytes.
---@param value number Number to encode.
---@return string bytes Big-endian double-precision payload.
local function _EncodeDoubleBytes(value)
    local highWord
    local lowWord

    if value ~= value then
        highWord = 0x7FF80000
        lowWord = 0
    else
        local signBit = 0
        if value < 0 or _IsNegativeZero(value) then
            signBit = TWO_31
            value = -value
        end

        if value == huge then
            highWord = signBit + 0x7FF00000
            lowWord = 0
        elseif value == 0 then
            highWord = signBit
            lowWord = 0
        else
            local mantissa, exponent = frexp(value)
            local biasedExponent = exponent + 1022
            local encodedMantissa

            if biasedExponent > 0 then
                encodedMantissa = floor((mantissa * 2 - 1) * TWO_52 + 0.5)
                if encodedMantissa == TWO_52 then
                    biasedExponent = biasedExponent + 1
                    encodedMantissa = 0
                end

                highWord = signBit + biasedExponent * TWO_20 + floor(encodedMantissa / TWO_32)
                lowWord = encodedMantissa % TWO_32
            else
                encodedMantissa = floor(ldexp(value, 1074) + 0.5)
                highWord = signBit + floor(encodedMantissa / TWO_32)
                lowWord = encodedMantissa % TWO_32
            end
        end
    end

    return _EncodeUnsignedIntegerBytes(highWord, 4) .. _EncodeUnsignedIntegerBytes(lowWord, 4)
end

---Encodes a Lua float using the shortest exact IEEE-754 CBOR float width.
---@param value number Number to encode.
---@return string bytes Encoded CBOR float item.
local function _EncodePreferredFloat(value)
    local halfBits = _EncodeHalfBits(value)
    if halfBits and _NumbersEncodeSame(_DecodeHalfBits(halfBits), value) then
        return char(0xF9) .. _EncodeUnsignedIntegerBytes(halfBits, 2)
    end

    local singleBits = _EncodeSingleBits(value)
    if singleBits and _NumbersEncodeSame(_DecodeSingleBits(singleBits), value) then
        return char(0xFA) .. _EncodeUnsignedIntegerBytes(singleBits, 4)
    end

    return char(0xFB) .. _EncodeDoubleBytes(value)
end

---Encodes a Lua number according to the Blizzard-compatible preferred-number policy.
---@param value number Number to encode.
---@return string bytes Encoded CBOR number item.
local function _EncodeNumber(value)
    if _IsSafeInteger(value) then
        if value >= 0 then
            return _EncodeMajorArgument(MAJOR_UNSIGNED, value)
        end

        return _EncodeMajorArgument(MAJOR_NEGATIVE, -1 - value)
    end

    return _EncodePreferredFloat(value)
end

-- Serialization policy: table shape and unsupported-value behavior live here for fixture tuning.
---Reports whether a table key belongs to a dense one-based Lua array.
---@param key any Candidate table key.
---@return boolean isArrayKey True when the key is a positive integer Lua number.
local function _IsPositiveArrayKey(key)
    return type(key) == "number" and _IsFinite(key) and key >= 1 and key % 1 == 0
end

---Classifies tables for Blizzard compatibility; tune this when sparse fixtures are captured.
---@param tableValue table Lua table to classify.
---@return "array"|"map" shape CBOR container shape.
---@return number entryCount Array length or map pair count.
local function _ClassifyTableShape(tableValue)
    local entryCount = 0
    local maxArrayKey = 0
    local hasOnlyArrayKeys = true

    for key in pairs(tableValue) do
        entryCount = entryCount + 1

        if _IsPositiveArrayKey(key) then
            if key > maxArrayKey then
                maxArrayKey = key
            end
        else
            hasOnlyArrayKeys = false
        end
    end

    if entryCount == 0 then
        return "array", 0
    elseif hasOnlyArrayKeys and entryCount == maxArrayKey then
        return "array", maxArrayKey
    end

    return "map", entryCount
end

---@class BlizzardCBOREncodeMechanics
---@field MapKey fun(key: any, encodeState: BlizzardCBOREncodeState, tableDepth: number): string
---@field Table fun(tableValue: table, encodeState: BlizzardCBOREncodeState, tableDepth: number): string
---@field UnsupportedValue fun(valueType: string, encodeState: BlizzardCBOREncodeState): string
---@field Value fun(value: any, encodeState: BlizzardCBOREncodeState, tableDepth: number): string
local Encode = {}

---Encodes a CBOR map key.
---Unsupported keys remain hard errors even when value errors are ignored: CBOR
---undefined deserializes to nil, which cannot be used as a Lua table key.
---@param key any Lua table key to encode.
---@param encodeState BlizzardCBOREncodeState Active serializer state.
---@param tableDepth number Current table nesting depth, with the root table counted as 1.
---@return string bytes Encoded CBOR key item.
function Encode.MapKey(key, encodeState, tableDepth)
    local keyType = type(key)

    if keyType ~= "boolean" and keyType ~= "number" and keyType ~= "string" and keyType ~= "table" then
        error("CBOR serialization does not support " .. keyType .. " map keys")
    end

    return Encode.Value(key, encodeState, tableDepth)
end

---Encodes a Lua table as either a CBOR array or map.
---@param tableValue table Lua table to encode.
---@param encodeState BlizzardCBOREncodeState Active serializer state.
---@param tableDepth number Current table nesting depth, with the root table counted as 1.
---@return string bytes Encoded CBOR table item.
function Encode.Table(tableValue, encodeState, tableDepth)
    if tableDepth > MAX_NESTING_DEPTH then
        error("CBOR serialization exceeded maximum table depth of " .. MAX_NESTING_DEPTH)
    end

    if encodeState.activeTables[tableValue] then
        error("CBOR serialization does not support recursive tables")
    end

    encodeState.activeTables[tableValue] = true

    -- Array-vs-map is intentionally isolated so captured Blizzard fixtures can tune sparse-table behavior.
    local shape, entryCount = _ClassifyTableShape(tableValue)
    local parts = {}

    if shape == "array" then
        parts[1] = _EncodeMajorArgument(MAJOR_ARRAY, entryCount)
        for index = 1, entryCount do
            parts[#parts + 1] = Encode.Value(tableValue[index], encodeState, tableDepth + 1)
        end
    else
        parts[1] = _EncodeMajorArgument(MAJOR_MAP, entryCount)
        for key, value in pairs(tableValue) do
            -- Unsupported values may become CBOR undefined, but unsupported keys cannot.
            parts[#parts + 1] = Encode.MapKey(key, encodeState, tableDepth + 1)
            parts[#parts + 1] = Encode.Value(value, encodeState, tableDepth + 1)
        end
    end

    encodeState.activeTables[tableValue] = nil
    return concat(parts)
end

---Encodes unsupported Lua values, optionally replacing them with CBOR undefined.
---@param valueType string Lua type name.
---@param encodeState BlizzardCBOREncodeState Active serializer state.
---@return string bytes Encoded CBOR undefined item when errors are ignored.
function Encode.UnsupportedValue(valueType, encodeState)
    if encodeState.ignoreSerializationErrors then
        return CBOR_UNDEFINED
    end

    error("CBOR serialization does not support " .. valueType .. " values")
end

---Encodes any supported Lua value to one CBOR data item.
---@param value any Lua value to encode.
---@param encodeState BlizzardCBOREncodeState Active serializer state.
---@param tableDepth number Current table nesting depth, with the root table counted as 1.
---@return string bytes Encoded CBOR item.
function Encode.Value(value, encodeState, tableDepth)
    local valueType = type(value)

    if valueType == "nil" then
        return CBOR_NULL
    elseif valueType == "boolean" then
        return value and CBOR_TRUE or CBOR_FALSE
    elseif valueType == "number" then
        return _EncodeNumber(value)
    elseif valueType == "string" then
        return _EncodeMajorArgument(MAJOR_BYTE_STRING, #value) .. value
    elseif valueType == "table" then
        return Encode.Table(value, encodeState, tableDepth)
    end

    return Encode.UnsupportedValue(valueType, encodeState)
end

-- Deserialization mechanics: accepts only definite-length, untagged CBOR subset items.
---Reads an unsigned big-endian integer from the CBOR source.
---@param source string CBOR byte string.
---@param position number One-based read position.
---@param byteCount number Number of bytes to consume.
---@return number value Decoded unsigned value.
---@return number nextPosition First unread byte position.
local function _ReadUnsignedInteger(source, position, byteCount)
    if position + byteCount - 1 > #source then
        error("truncated CBOR data")
    end

    local value = 0
    for offset = 0, byteCount - 1 do
        value = value * TWO_8 + byte(source, position + offset)
    end

    return value, position + byteCount
end

---Reads a CBOR additional-information argument.
---@param source string CBOR byte string.
---@param position number Position after the initial CBOR byte.
---@param additionalInfo number CBOR additional information field.
---@return number value Decoded argument value.
---@return number nextPosition First unread byte position.
local function _ReadArgument(source, position, additionalInfo)
    if additionalInfo < 24 then
        return additionalInfo, position
    elseif additionalInfo == 24 then
        return _ReadUnsignedInteger(source, position, 1)
    elseif additionalInfo == 25 then
        return _ReadUnsignedInteger(source, position, 2)
    elseif additionalInfo == 26 then
        return _ReadUnsignedInteger(source, position, 4)
    elseif additionalInfo == 27 then
        return _ReadUnsignedInteger(source, position, 8)
    elseif additionalInfo == 31 then
        error("indefinite-length CBOR items are not supported")
    end

    error("invalid CBOR additional information")
end

---Reads one CBOR initial byte.
---@param source string CBOR byte string.
---@param position number One-based read position.
---@return number majorType CBOR major type number.
---@return number additionalInfo CBOR additional information field.
---@return number nextPosition First byte after the initial byte.
local function _ReadInitialByte(source, position)
    local initialByte = byte(source, position)
    if initialByte == nil then
        error("truncated CBOR data")
    end

    return floor(initialByte / 32), initialByte % 32, position + 1
end

---@class BlizzardCBORDecodeMechanics
---@field String fun(source: string, position: number, additionalInfo: number): string, number
---@field Array fun(source: string, position: number, additionalInfo: number, tableDepth: number): table, number
---@field Map fun(source: string, position: number, additionalInfo: number, tableDepth: number): table, number
---@field SimpleOrFloat fun(source: string, position: number, additionalInfo: number): any, number
---@field Value fun(source: string, position: number, tableDepth: number): any, number
local Decode = {}

---Decodes a definite-length CBOR byte or text string.
---@param source string CBOR byte string.
---@param position number Position after the initial CBOR byte.
---@param additionalInfo number CBOR additional information field.
---@return string value Decoded Lua string.
---@return number nextPosition First unread byte position.
function Decode.String(source, position, additionalInfo)
    local stringLength
    stringLength, position = _ReadArgument(source, position, additionalInfo)

    if position + stringLength - 1 > #source then
        error("truncated CBOR data")
    end

    return sub(source, position, position + stringLength - 1), position + stringLength
end

---Decodes a definite-length CBOR array.
---@param source string CBOR byte string.
---@param position number Position after the initial CBOR byte.
---@param additionalInfo number CBOR additional information field.
---@param tableDepth number Current table nesting depth, with the root table counted as 1.
---@return table value Decoded Lua array table.
---@return number nextPosition First unread byte position.
function Decode.Array(source, position, additionalInfo, tableDepth)
    if tableDepth > MAX_NESTING_DEPTH then
        error("CBOR deserialization exceeded maximum table depth of " .. MAX_NESTING_DEPTH)
    end

    local arrayLength
    arrayLength, position = _ReadArgument(source, position, additionalInfo)

    local items = {}
    for index = 1, arrayLength do
        items[index], position = Decode.Value(source, position, tableDepth + 1)
    end

    return items, position
end

---Decodes a definite-length CBOR map.
---@param source string CBOR byte string.
---@param position number Position after the initial CBOR byte.
---@param additionalInfo number CBOR additional information field.
---@param tableDepth number Current table nesting depth, with the root table counted as 1.
---@return table value Decoded Lua map table.
---@return number nextPosition First unread byte position.
function Decode.Map(source, position, additionalInfo, tableDepth)
    if tableDepth > MAX_NESTING_DEPTH then
        error("CBOR deserialization exceeded maximum table depth of " .. MAX_NESTING_DEPTH)
    end

    local mapLength
    mapLength, position = _ReadArgument(source, position, additionalInfo)

    local map = {}
    for _ = 1, mapLength do
        local key
        local value

        key, position = Decode.Value(source, position, tableDepth + 1)
        if key == nil then
            error("CBOR map keys that decode to nil are not supported")
        end

        value, position = Decode.Value(source, position, tableDepth + 1)
        map[key] = value
    end

    return map, position
end

---Decodes CBOR simple values and IEEE-754 floats.
---@param source string CBOR byte string.
---@param position number Position after the initial CBOR byte.
---@param additionalInfo number CBOR additional information field.
---@return any value Decoded Lua value.
---@return number nextPosition First unread byte position.
function Decode.SimpleOrFloat(source, position, additionalInfo)
    if additionalInfo == 20 then
        return false, position
    elseif additionalInfo == 21 then
        return true, position
    elseif additionalInfo == 22 or additionalInfo == 23 then
        return nil, position
    elseif additionalInfo == 24 then
        local simpleValue = _ReadUnsignedInteger(source, position, 1)
        error("unsupported CBOR simple value " .. simpleValue)
    elseif additionalInfo == 25 then
        local halfBits
        halfBits, position = _ReadUnsignedInteger(source, position, 2)
        return _DecodeHalfBits(halfBits), position
    elseif additionalInfo == 26 then
        local singleBits
        singleBits, position = _ReadUnsignedInteger(source, position, 4)
        return _DecodeSingleBits(singleBits), position
    elseif additionalInfo == 27 then
        local highWord
        local lowWord

        highWord, position = _ReadUnsignedInteger(source, position, 4)
        lowWord, position = _ReadUnsignedInteger(source, position, 4)
        return _DecodeDoubleWords(highWord, lowWord), position
    elseif additionalInfo == 31 then
        error("CBOR break values are not supported")
    end

    error("unsupported CBOR simple value " .. additionalInfo)
end

---Decodes one CBOR data item from the source string.
---@param source string CBOR byte string.
---@param position number One-based read position.
---@param tableDepth number Current table nesting depth, with the root table counted as 1.
---@return any value Decoded Lua value.
---@return number nextPosition First unread byte position.
function Decode.Value(source, position, tableDepth)
    local majorType
    local additionalInfo

    majorType, additionalInfo, position = _ReadInitialByte(source, position)

    if majorType == MAJOR_UNSIGNED then
        return _ReadArgument(source, position, additionalInfo)
    elseif majorType == MAJOR_NEGATIVE then
        local value
        value, position = _ReadArgument(source, position, additionalInfo)
        return -1 - value, position
    elseif majorType == MAJOR_BYTE_STRING or majorType == MAJOR_TEXT_STRING then
        return Decode.String(source, position, additionalInfo)
    elseif majorType == MAJOR_ARRAY then
        return Decode.Array(source, position, additionalInfo, tableDepth)
    elseif majorType == MAJOR_MAP then
        return Decode.Map(source, position, additionalInfo, tableDepth)
    elseif majorType == MAJOR_TAG then
        error("CBOR tags are not supported")
    elseif majorType == MAJOR_SIMPLE then
        return Decode.SimpleOrFloat(source, position, additionalInfo)
    end

    error("invalid CBOR major type")
end

-- Public API: mirrors C_EncodingUtil's CBOR function names for tests and manual comparison.
---Serializes one Lua value to Blizzard-compatible CBOR subset bytes.
---@param value any Lua value to serialize.
---@param options CBORSerializationOptions? Serialization options.
---@return string output CBOR byte string.
function BlizzardCBOR.SerializeCBOR(value, options)
    if options ~= nil and type(options) ~= "table" then
        error("CBOR serialization options must be a table")
    end

    ---@type BlizzardCBOREncodeState
    local encodeState = {
        ignoreSerializationErrors = options ~= nil and options.ignoreSerializationErrors == true,
        activeTables = {},
    }

    return Encode.Value(value, encodeState, 1)
end

---Deserializes one Blizzard-compatible CBOR subset item from a byte string.
---@param source string CBOR byte string.
---@return any value Decoded Lua value.
function BlizzardCBOR.DeserializeCBOR(source)
    if type(source) ~= "string" then
        error("CBOR deserialization source must be a string")
    end

    local value
    local position

    value, position = Decode.Value(source, 1, 1)
    if position <= #source then
        error("trailing data after CBOR item")
    end

    return value
end

---Installs only the CBOR methods that setupTests can safely mock.
---Compression stays absent so production code still detects incomplete Blizzard
---codec support unless a test deliberately provides compression functions.
---@param targetGlobal table? Global environment to receive C_EncodingUtil.
---@return table encodingUtil The installed or updated C_EncodingUtil table.
function BlizzardCBOR.InstallEncodingUtilMock(targetGlobal)
    targetGlobal = targetGlobal or _G
    targetGlobal.C_EncodingUtil = targetGlobal.C_EncodingUtil or {}
    targetGlobal.C_EncodingUtil.SerializeCBOR = BlizzardCBOR.SerializeCBOR
    targetGlobal.C_EncodingUtil.DeserializeCBOR = BlizzardCBOR.DeserializeCBOR

    return targetGlobal.C_EncodingUtil
end

-- Manual TOC inclusion hook for the external byte-compatibility helper. This is
-- intentionally not a QuestieLoader module and is not loaded by Questie TOCs.
_G.QuestieBlizzardCBORMock = BlizzardCBOR

return BlizzardCBOR
