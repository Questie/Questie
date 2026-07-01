---@class BlizzardCBORCompatibilityCase
---@field id string Stable fixture key used by tests, SavedVariables, and docs.
---@field category string Human-readable grouping for reports.
---@field description string Short explanation shown in capture output.
---@field argumentCount integer Number of arguments to pass to SerializeCBOR.
---@field buildArguments fun(): any, table? Builds fresh arguments for one serialization attempt.
---@field expectSerializeError boolean? True when Blizzard is expected to reject the value.
---@field mapOrderUnstable boolean? True when unsorted map key order can make local byte comparison brittle.
---@field notes string? Durable compatibility caveat for this case.

---@class BlizzardCBORCompatibilityCases
local BlizzardCBORCompatibilityCases = {}

local char = string.char
local huge = math.huge

---@return nil
local function _BuildNoArguments()
end

---@return nil
local function _BuildNil()
    return nil
end

---@return number
local function _BuildNaN()
    return 0 / 0
end

---@return number
local function _BuildNegativeZero()
    return -0.0
end

---@param depth integer Number of table levels to build.
---@return table root Fresh nested table.
local function _BuildNestedArray(depth)
    local root = {}
    local current = root

    for _ = 2, depth do
        local child = {}
        current[1] = child
        current = child
    end

    return root
end

---@return table root Table containing a recursive reference.
local function _BuildRecursiveTable()
    local root = {}
    root[1] = "before-cycle"
    root[2] = root
    return root
end

---@return table root Map with a table key.
local function _BuildTableKeyMap()
    local key = {"table-key"}

    return {
        [key] = "table-key-value",
    }
end

---@return table root Map with an unsupported function key.
local function _BuildFunctionKeyMap()
    local key = function() end

    return {
        [key] = "function-key-value",
    }
end

---@return function value Unsupported root function value.
local function _BuildFunctionValue()
    return function() end
end

---@return function value Unsupported root function value.
---@return table options Serialization options enabling undefined fallback.
local function _BuildIgnoredFunctionValue()
    return function() end, {ignoreSerializationErrors = true}
end

---@return table value Table containing an unsupported value.
local function _BuildTableWithFunctionValue()
    return {
        ok = "before-function",
        unsupported = function() end,
    }
end

---@return table value Table containing an unsupported value.
---@return table options Serialization options enabling undefined fallback.
local function _BuildIgnoredTableWithFunctionValue()
    return {
        ok = "before-function",
        unsupported = function() end,
    }, {ignoreSerializationErrors = true}
end

---@return table value Table containing an unsupported map key.
---@return table options Serialization options enabling undefined fallback.
local function _BuildIgnoredFunctionKeyMap()
    return _BuildFunctionKeyMap(), {ignoreSerializationErrors = true}
end

---@return BlizzardCBORCompatibilityCase[] cases Fresh compatibility cases.
local function _BuildCases()
    -- Keep the cases explicit and grouped. Fixture review is safer when a human
    -- can scan the representative values without chasing a generated matrix.
    return {
        {
            id = "omitted-value",
            category = "primitive",
            description = "SerializeCBOR called without a value argument",
            argumentCount = 0,
            buildArguments = _BuildNoArguments,
        },
        {
            id = "nil-value",
            category = "primitive",
            description = "Explicit nil value",
            argumentCount = 1,
            buildArguments = _BuildNil,
        },
        {
            id = "boolean-false",
            category = "primitive",
            description = "Boolean false",
            argumentCount = 1,
            buildArguments = function() return false end,
        },
        {
            id = "boolean-true",
            category = "primitive",
            description = "Boolean true",
            argumentCount = 1,
            buildArguments = function() return true end,
        },

        {
            id = "string-empty",
            category = "string",
            description = "Empty byte string",
            argumentCount = 1,
            buildArguments = function() return "" end,
        },
        {
            id = "string-ascii",
            category = "string",
            description = "ASCII byte string",
            argumentCount = 1,
            buildArguments = function() return "Questie CBOR" end,
        },
        {
            id = "string-null-byte",
            category = "string",
            description = "String containing embedded NUL bytes",
            argumentCount = 1,
            buildArguments = function() return "a" .. char(0) .. "b" .. char(0) end,
        },
        {
            id = "string-high-bytes",
            category = "string",
            description = "String containing bytes above ASCII range",
            argumentCount = 1,
            buildArguments = function() return char(0, 1, 127, 128, 255) end,
        },

        {
            id = "integer-zero",
            category = "integer",
            description = "Unsigned integer 0",
            argumentCount = 1,
            buildArguments = function() return 0 end,
        },
        {
            id = "integer-23",
            category = "integer",
            description = "Largest integer encoded directly in the CBOR additional info field",
            argumentCount = 1,
            buildArguments = function() return 23 end,
        },
        {
            id = "integer-24",
            category = "integer",
            description = "Smallest integer requiring one payload byte",
            argumentCount = 1,
            buildArguments = function() return 24 end,
        },
        {
            id = "integer-255",
            category = "integer",
            description = "Largest integer requiring one payload byte",
            argumentCount = 1,
            buildArguments = function() return 255 end,
        },
        {
            id = "integer-256",
            category = "integer",
            description = "Smallest integer requiring two payload bytes",
            argumentCount = 1,
            buildArguments = function() return 256 end,
        },
        {
            id = "integer-65535",
            category = "integer",
            description = "Largest integer requiring two payload bytes",
            argumentCount = 1,
            buildArguments = function() return 65535 end,
        },
        {
            id = "integer-65536",
            category = "integer",
            description = "Smallest integer requiring four payload bytes",
            argumentCount = 1,
            buildArguments = function() return 65536 end,
        },
        {
            id = "integer-uint32-max",
            category = "integer",
            description = "Largest 32-bit unsigned integer",
            argumentCount = 1,
            buildArguments = function() return 4294967295 end,
        },
        {
            id = "integer-uint32-plus-one",
            category = "integer",
            description = "Smallest integer requiring eight payload bytes",
            argumentCount = 1,
            buildArguments = function() return 4294967296 end,
        },
        {
            id = "integer-safe-max",
            category = "integer",
            description = "Largest exactly representable integer in a double-backed Lua 5.1 number",
            argumentCount = 1,
            buildArguments = function() return 9007199254740992 end,
            notes = "Lua 5.1 cannot represent every integer above this boundary exactly.",
        },
        {
            id = "negative-one",
            category = "integer",
            description = "Negative integer -1",
            argumentCount = 1,
            buildArguments = function() return -1 end,
        },
        {
            id = "negative-24",
            category = "integer",
            description = "Negative integer -24",
            argumentCount = 1,
            buildArguments = function() return -24 end,
        },
        {
            id = "negative-25",
            category = "integer",
            description = "Negative integer -25",
            argumentCount = 1,
            buildArguments = function() return -25 end,
        },
        {
            id = "negative-256",
            category = "integer",
            description = "Negative integer -256",
            argumentCount = 1,
            buildArguments = function() return -256 end,
        },
        {
            id = "negative-65536",
            category = "integer",
            description = "Negative integer -65536",
            argumentCount = 1,
            buildArguments = function() return -65536 end,
        },

        {
            id = "float-half-exact",
            category = "float",
            description = "Finite float exactly representable as half precision",
            argumentCount = 1,
            buildArguments = function() return 0.5 end,
        },
        {
            id = "float-double-typical",
            category = "float",
            description = "Finite float that usually requires double precision",
            argumentCount = 1,
            buildArguments = function() return 1.1 end,
        },
        {
            id = "float-positive-infinity",
            category = "float",
            description = "Positive infinity",
            argumentCount = 1,
            buildArguments = function() return huge end,
        },
        {
            id = "float-negative-infinity",
            category = "float",
            description = "Negative infinity",
            argumentCount = 1,
            buildArguments = function() return -huge end,
        },
        {
            id = "float-nan",
            category = "float",
            description = "NaN value",
            argumentCount = 1,
            buildArguments = _BuildNaN,
            notes = "NaN payload bits may be canonicalized differently by clients.",
        },
        {
            id = "float-negative-zero",
            category = "float",
            description = "Negative zero",
            argumentCount = 1,
            buildArguments = _BuildNegativeZero,
        },

        {
            id = "table-empty",
            category = "table",
            description = "Empty table; initial local policy treats this as an array",
            argumentCount = 1,
            buildArguments = function() return {} end,
        },
        {
            id = "table-dense-array",
            category = "table",
            description = "Dense positive integer keys",
            argumentCount = 1,
            buildArguments = function() return {"a", "b", "c"} end,
        },
        {
            id = "table-sparse-small-gap",
            category = "table",
            description = "Integral keys with a small nil gap",
            argumentCount = 1,
            buildArguments = function() return {[1] = "a", [3] = "c"} end,
            mapOrderUnstable = true,
            notes = "Blizzard may choose array or map based on a sparse-table heuristic.",
        },
        {
            id = "table-sparse-large-gap",
            category = "table",
            description = "Integral keys with a large nil gap",
            argumentCount = 1,
            buildArguments = function() return {[1] = "a", [100] = "z"} end,
            mapOrderUnstable = true,
            notes = "Blizzard sparse-table cutoff is intentionally left fixture-driven.",
        },
        {
            id = "table-zero-index",
            category = "table",
            description = "Numeric zero key forces map-like representation",
            argumentCount = 1,
            buildArguments = function() return {[0] = "zero", [1] = "one"} end,
            mapOrderUnstable = true,
        },
        {
            id = "table-string-key-map",
            category = "table",
            description = "String-keyed map",
            argumentCount = 1,
            buildArguments = function() return {name = "Questie", version = 1} end,
            mapOrderUnstable = true,
        },
        {
            id = "table-mixed-key-map",
            category = "table",
            description = "Mixed array and string keys",
            argumentCount = 1,
            buildArguments = function() return {[1] = "array-value", addon = "Questie"} end,
            mapOrderUnstable = true,
        },
        {
            id = "table-boolean-key-map",
            category = "table",
            description = "Boolean keys in a map",
            argumentCount = 1,
            buildArguments = function() return {[false] = "false-key", [true] = "true-key"} end,
            mapOrderUnstable = true,
        },
        {
            id = "table-table-key-map",
            category = "table",
            description = "Table key in a map",
            argumentCount = 1,
            buildArguments = _BuildTableKeyMap,
            mapOrderUnstable = true,
        },
        {
            id = "table-nested-depth-100",
            category = "table",
            description = "Nested table at the documented depth boundary",
            argumentCount = 1,
            buildArguments = function() return _BuildNestedArray(100) end,
            notes = "Boundary interpretation should be confirmed against Blizzard.",
        },
        {
            id = "table-nested-depth-101",
            category = "table",
            description = "Nested table beyond the documented depth boundary",
            argumentCount = 1,
            buildArguments = function() return _BuildNestedArray(101) end,
            expectSerializeError = true,
            notes = "Expected to exceed Blizzard's documented nesting limit.",
        },
        {
            id = "table-recursive",
            category = "error",
            description = "Recursive table reference",
            argumentCount = 1,
            buildArguments = _BuildRecursiveTable,
            expectSerializeError = true,
        },

        {
            id = "unsupported-function-root",
            category = "error",
            description = "Unsupported root function value",
            argumentCount = 1,
            buildArguments = _BuildFunctionValue,
            expectSerializeError = true,
        },
        {
            id = "unsupported-function-root-ignored",
            category = "error",
            description = "Unsupported root function value with ignoreSerializationErrors enabled",
            argumentCount = 2,
            buildArguments = _BuildIgnoredFunctionValue,
            notes = "Expected output should show whether Blizzard emits CBOR undefined at the root.",
        },
        {
            id = "unsupported-function-in-map",
            category = "error",
            description = "Unsupported function inside a map",
            argumentCount = 1,
            buildArguments = _BuildTableWithFunctionValue,
            expectSerializeError = true,
            mapOrderUnstable = true,
        },
        {
            id = "unsupported-function-in-map-ignored",
            category = "error",
            description = "Unsupported function inside a map with ignoreSerializationErrors enabled",
            argumentCount = 2,
            buildArguments = _BuildIgnoredTableWithFunctionValue,
            mapOrderUnstable = true,
            notes = "Expected output should show where Blizzard substitutes CBOR undefined.",
        },
        {
            id = "unsupported-function-map-key",
            category = "error",
            description = "Unsupported function used as a map key",
            argumentCount = 1,
            buildArguments = _BuildFunctionKeyMap,
            expectSerializeError = true,
        },
        {
            id = "unsupported-function-map-key-ignored",
            category = "error",
            description = "Unsupported function map key with ignoreSerializationErrors enabled",
            argumentCount = 2,
            buildArguments = _BuildIgnoredFunctionKeyMap,
            expectSerializeError = true,
            notes = "Local policy keeps unsupported map keys as errors because CBOR undefined decodes to nil.",
        },
    }
end

---Returns fresh case records so callers never share mutable test values.
---@return BlizzardCBORCompatibilityCase[] cases Compatibility cases.
function BlizzardCBORCompatibilityCases.GetCases()
    return _BuildCases()
end

---@param caseId string Stable fixture key.
---@return BlizzardCBORCompatibilityCase? compatibilityCase Matching case, if present.
function BlizzardCBORCompatibilityCases.GetCaseById(caseId)
    for _, compatibilityCase in ipairs(_BuildCases()) do
        if compatibilityCase.id == caseId then
            return compatibilityCase
        end
    end

    return nil
end

---Calls a SerializeCBOR-compatible function with the exact argument count for a case.
---@param serializeCBOR fun(value?: any, options?: table): string Serializer under test.
---@param compatibilityCase BlizzardCBORCompatibilityCase Case returned by GetCases.
---@return boolean ok True when serialization succeeded.
---@return any outputOrError Serialized bytes on success, error object/string on failure.
function BlizzardCBORCompatibilityCases.CallSerialize(serializeCBOR, compatibilityCase)
    if type(serializeCBOR) ~= "function" then
        error("serializeCBOR must be a function", 2)
    end

    local value, options = compatibilityCase.buildArguments()
    local argumentCount = compatibilityCase.argumentCount

    if argumentCount == 0 then
        return pcall(serializeCBOR)
    elseif argumentCount == 1 then
        return pcall(serializeCBOR, value)
    elseif argumentCount == 2 then
        return pcall(serializeCBOR, value, options)
    end

    error("unsupported compatibility argument count for " .. tostring(compatibilityCase.id), 2)
end

_G.QuestieBlizzardCBORCompatibilityCases = BlizzardCBORCompatibilityCases

return BlizzardCBORCompatibilityCases
