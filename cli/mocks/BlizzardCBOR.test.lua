dofile("setupTests.lua")

local format = string.format
local byte = string.byte
local char = string.char
local concat = table.concat

---Converts binary data to lowercase hex for byte-for-byte CBOR assertions.
---@param bytes string Binary byte string.
---@return string hex Lowercase hexadecimal representation.
local function _BytesToHex(bytes)
    local hex = {}

    for index = 1, #bytes do
        hex[#hex + 1] = format("%02x", byte(bytes, index))
    end

    return concat(hex)
end

---Converts fixture hex to binary data.
---@param hex string Hexadecimal string, whitespace allowed.
---@return string bytes Binary byte string.
local function _HexToBytes(hex)
    local bytes = {}
    hex = hex:gsub("%s+", "")

    for index = 1, #hex, 2 do
        bytes[#bytes + 1] = char(tonumber(hex:sub(index, index + 1), 16))
    end

    return concat(bytes)
end

---Creates a chain of one-element arrays with the requested table depth.
---@param depth number Number of nested tables to create.
---@return table root Root table in the chain.
local function _NestedArray(depth)
    local root = {}
    local current = root

    for _ = 2, depth do
        current[1] = {}
        current = current[1]
    end

    current[1] = true
    return root
end

---Creates CBOR bytes for nested one-element arrays ending in true.
---@param depth number Number of nested CBOR arrays.
---@return string bytes CBOR byte string.
local function _NestedArrayCBOR(depth)
    return _HexToBytes(string.rep("81", depth) .. "f5")
end

describe("BlizzardCBOR", function()
    ---@type BlizzardCBORMock
    local BlizzardCBOR

    before_each(function()
        BlizzardCBOR = dofile("cli/mocks/BlizzardCBOR.lua")
    end)

    describe("SerializeCBOR", function()
        it("encodes nil and booleans as CBOR simple values", function()
            assert.are_same("f6", _BytesToHex(BlizzardCBOR.SerializeCBOR(nil)))
            assert.are_same("f4", _BytesToHex(BlizzardCBOR.SerializeCBOR(false)))
            assert.are_same("f5", _BytesToHex(BlizzardCBOR.SerializeCBOR(true)))
        end)

        it("encodes integers with preferred widths", function()
            local cases = {
                ["00"] = 0,
                ["17"] = 23,
                ["1818"] = 24,
                ["18ff"] = 255,
                ["190100"] = 256,
                ["19ffff"] = 65535,
                ["1a00010000"] = 65536,
                ["1b0000000100000000"] = 4294967296,
                ["20"] = -1,
                ["37"] = -24,
                ["3818"] = -25,
                ["38ff"] = -256,
                ["390100"] = -257,
            }

            for expectedHex, value in pairs(cases) do
                assert.are_same(expectedHex, _BytesToHex(BlizzardCBOR.SerializeCBOR(value)))
            end
        end)

        it("encodes strings as CBOR byte strings, not text strings", function()
            assert.are_same("40", _BytesToHex(BlizzardCBOR.SerializeCBOR("")))
            assert.are_same("4568656c6c6f", _BytesToHex(BlizzardCBOR.SerializeCBOR("hello")))
            assert.are_same("4400ff807f", _BytesToHex(BlizzardCBOR.SerializeCBOR(char(0, 255, 128, 127))))
        end)

        it("encodes dense positive integer keys as arrays", function()
            assert.are_same("80", _BytesToHex(BlizzardCBOR.SerializeCBOR({})))
            assert.are_same("83010203", _BytesToHex(BlizzardCBOR.SerializeCBOR({1, 2, 3})))
        end)

        it("encodes non-dense or non-array keys as maps", function()
            assert.are_same("a100447a65726f", _BytesToHex(BlizzardCBOR.SerializeCBOR({[0] = "zero"})))
            assert.are_same("a143666f6f43626172", _BytesToHex(BlizzardCBOR.SerializeCBOR({foo = "bar"})))

            local sparseMap = BlizzardCBOR.SerializeCBOR({[1] = "a", [3] = "c"})
            assert.are_same("a2", _BytesToHex(sparseMap):sub(1, 2))
            assert.are_same({[1] = "a", [3] = "c"}, BlizzardCBOR.DeserializeCBOR(sparseMap))

            local twoKeyMap = BlizzardCBOR.SerializeCBOR({foo = "bar", baz = "qux"})
            assert.are_same("a2", _BytesToHex(twoKeyMap):sub(1, 2))
            assert.are_same({foo = "bar", baz = "qux"}, BlizzardCBOR.DeserializeCBOR(twoKeyMap))
        end)

        it("encodes floats, infinities, NaN, and negative zero", function()
            assert.are_same("f93800", _BytesToHex(BlizzardCBOR.SerializeCBOR(0.5)))
            assert.are_same("fb3ff199999999999a", _BytesToHex(BlizzardCBOR.SerializeCBOR(1.1)))
            assert.are_same("f97c00", _BytesToHex(BlizzardCBOR.SerializeCBOR(math.huge)))
            assert.are_same("f9fc00", _BytesToHex(BlizzardCBOR.SerializeCBOR(-math.huge)))
            assert.are_same("f97e00", _BytesToHex(BlizzardCBOR.SerializeCBOR(0 / 0)))
            assert.are_same("f98000", _BytesToHex(BlizzardCBOR.SerializeCBOR(-1 / math.huge)))
        end)

        it("replaces unsupported values with undefined only when requested", function()
            assert.has_error(function()
                BlizzardCBOR.SerializeCBOR(function() end)
            end)

            assert.are_same("f7", _BytesToHex(BlizzardCBOR.SerializeCBOR(function() end, {ignoreSerializationErrors = true})))
            assert.are_same("81f7", _BytesToHex(BlizzardCBOR.SerializeCBOR({function() end}, {ignoreSerializationErrors = true})))
            assert.are_same("a14b756e737570706f72746564f7", _BytesToHex(BlizzardCBOR.SerializeCBOR({
                unsupported = function() end,
            }, {ignoreSerializationErrors = true})))
        end)

        it("rejects unsupported map keys even when serialization errors are ignored", function()
            local unsupportedKey = function() end

            assert.has_error(function()
                BlizzardCBOR.SerializeCBOR({[unsupportedKey] = "value"}, {ignoreSerializationErrors = true})
            end)
        end)

        it("rejects recursive tables", function()
            local recursive = {}
            recursive.self = recursive

            assert.has_error(function()
                BlizzardCBOR.SerializeCBOR(recursive)
            end)
        end)

        it("rejects table nesting deeper than 100 levels", function()
            assert.is_string(BlizzardCBOR.SerializeCBOR(_NestedArray(100)))

            assert.has_error(function()
                BlizzardCBOR.SerializeCBOR(_NestedArray(101))
            end)
        end)
    end)

    describe("DeserializeCBOR", function()
        it("decodes primitive CBOR values", function()
            assert.is_nil(BlizzardCBOR.DeserializeCBOR(_HexToBytes("f6")))
            assert.is_nil(BlizzardCBOR.DeserializeCBOR(_HexToBytes("f7")))
            assert.is_false(BlizzardCBOR.DeserializeCBOR(_HexToBytes("f4")))
            assert.is_true(BlizzardCBOR.DeserializeCBOR(_HexToBytes("f5")))
        end)

        it("decodes integers", function()
            assert.are_same(0, BlizzardCBOR.DeserializeCBOR(_HexToBytes("00")))
            assert.are_same(23, BlizzardCBOR.DeserializeCBOR(_HexToBytes("17")))
            assert.are_same(24, BlizzardCBOR.DeserializeCBOR(_HexToBytes("1818")))
            assert.are_same(4294967296, BlizzardCBOR.DeserializeCBOR(_HexToBytes("1b0000000100000000")))
            assert.are_same(-1, BlizzardCBOR.DeserializeCBOR(_HexToBytes("20")))
            assert.are_same(-257, BlizzardCBOR.DeserializeCBOR(_HexToBytes("390100")))
        end)

        it("decodes byte and text strings as Lua strings without UTF-8 validation", function()
            assert.are_same("hello", BlizzardCBOR.DeserializeCBOR(_HexToBytes("4568656c6c6f")))
            assert.are_same("foo", BlizzardCBOR.DeserializeCBOR(_HexToBytes("63666f6f")))
            assert.are_same(char(255, 254), BlizzardCBOR.DeserializeCBOR(_HexToBytes("62fffe")))
        end)

        it("decodes arrays and maps", function()
            assert.are_same({1, 2, 3}, BlizzardCBOR.DeserializeCBOR(_HexToBytes("83010203")))
            assert.are_same({foo = "bar"}, BlizzardCBOR.DeserializeCBOR(_HexToBytes("a143666f6f43626172")))
        end)

        it("decodes half, single, and double floats", function()
            assert.are_same(0.5, BlizzardCBOR.DeserializeCBOR(_HexToBytes("f93800")))
            assert.are_same(1.5, BlizzardCBOR.DeserializeCBOR(_HexToBytes("fa3fc00000")))

            local pi = BlizzardCBOR.DeserializeCBOR(_HexToBytes("fb400921fb54442d18"))
            assert.is_true(math.abs(pi - 3.141592653589793) < 0.000000000000001)

            assert.are_same(math.huge, BlizzardCBOR.DeserializeCBOR(_HexToBytes("f97c00")))
            assert.are_same(-math.huge, BlizzardCBOR.DeserializeCBOR(_HexToBytes("f9fc00")))
            assert.is_true(BlizzardCBOR.DeserializeCBOR(_HexToBytes("f97e00")) ~= BlizzardCBOR.DeserializeCBOR(_HexToBytes("f97e00")))
            assert.are_same(-math.huge, 1 / BlizzardCBOR.DeserializeCBOR(_HexToBytes("f98000")))
        end)

        it("round-trips representative supported values", function()
            local cases = {
                {name = "nil"},
                {name = "false", value = false},
                {name = "true", value = true},
                {name = "zero", value = 0},
                {name = "negative integer", value = -1},
                {name = "one-byte integer", value = 24},
                {name = "four-byte integer", value = 65536},
                {name = "half float", value = 0.5},
                {name = "double float", value = 1.1},
                {name = "byte string", value = "hello"},
                {name = "array", value = {1, 2, "three"}},
                {name = "map", value = {foo = "bar"}},
            }

            for _, roundTripCase in ipairs(cases) do
                local decoded = BlizzardCBOR.DeserializeCBOR(BlizzardCBOR.SerializeCBOR(roundTripCase.value))
                assert.are_same(roundTripCase.value, decoded, roundTripCase.name)
            end
        end)

        it("rejects unsupported CBOR forms and malformed input", function()
            assert.has_error(function()
                BlizzardCBOR.DeserializeCBOR(_HexToBytes("c0f6"))
            end)

            assert.has_error(function()
                BlizzardCBOR.DeserializeCBOR(_HexToBytes("5fff"))
            end)

            assert.has_error(function()
                BlizzardCBOR.DeserializeCBOR(_HexToBytes("9fff"))
            end)

            assert.has_error(function()
                BlizzardCBOR.DeserializeCBOR(_HexToBytes("1a00"))
            end)

            assert.has_error(function()
                BlizzardCBOR.DeserializeCBOR(_HexToBytes("f8ff"))
            end)

            assert.has_error(function()
                BlizzardCBOR.DeserializeCBOR(_HexToBytes("f6f6"))
            end)
        end)

        it("rejects table nesting deeper than 100 levels", function()
            assert.is_table(BlizzardCBOR.DeserializeCBOR(_NestedArrayCBOR(100)))

            assert.has_error(function()
                BlizzardCBOR.DeserializeCBOR(_NestedArrayCBOR(101))
            end)
        end)
    end)
end)
