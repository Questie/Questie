-- luacheck: globals QuestieBlizzardCBORCompatDB QuestieBlizzardCBORMock C_EncodingUtil
-- luacheck: globals GetBuildInfo GetLocale SlashCmdList SLASH_QUESTIEBLIZZARDCBORCOMPAT1 WOW_PROJECT_ID date

local ADDON_NAME = "BlizzardCBORCompat"
local SAVED_VARIABLE_FORMAT_VERSION = 1
local MAX_STORED_RUNS = 5

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

---@param id string Stable fixture key.
---@param category string Human-readable grouping.
---@param description string Short report text.
---@param argumentCount integer Number of SerializeCBOR arguments.
---@param buildArguments function Fresh argument builder.
---@param extra table? Optional flags copied into the case.
---@return table compatibilityCase Case consumed by the capture runner.
local function _Case(id, category, description, argumentCount, buildArguments, extra)
    local compatibilityCase = {
        id = id,
        category = category,
        description = description,
        argumentCount = argumentCount,
        buildArguments = buildArguments,
    }

    if extra then
        for key, value in pairs(extra) do
            compatibilityCase[key] = value
        end
    end

    return compatibilityCase
end

---@return table compatibilityCases Standalone case API mirroring cli/mocks/BlizzardCBORCompatibilityCases.lua.
local function _BuildEmbeddedCompatibilityCases()
    local compatibilityCases = {}

    ---@return table[] cases Fresh compatibility cases.
    function compatibilityCases.GetCases()
        -- This fallback mirrors cli/mocks/BlizzardCBORCompatibilityCases.lua.
        -- The helper first uses the shared global when available, but keeping a
        -- standalone copy lets this addon run without modifying Questie's TOCs.
        return {
            _Case("omitted-value", "primitive", "No value argument", 0, _BuildNoArguments, {
                expectSerializeError = true,
            }),
            _Case("nil-value", "primitive", "Explicit nil", 1, _BuildNil),
            _Case("boolean-false", "primitive", "False", 1, function() return false end),
            _Case("boolean-true", "primitive", "True", 1, function() return true end),

            _Case("string-empty", "string", "Empty string", 1, function() return "" end),
            _Case("string-ascii", "string", "ASCII string", 1, function() return "Questie CBOR" end),
            _Case("string-null-byte", "string", "Embedded NUL bytes", 1, function()
                return "a" .. char(0) .. "b" .. char(0)
            end),
            _Case("string-high-bytes", "string", "High bytes", 1, function()
                return char(0, 1, 127, 128, 255)
            end),

            _Case("integer-zero", "integer", "Integer 0", 1, function() return 0 end),
            _Case("integer-23", "integer", "Integer 23", 1, function() return 23 end),
            _Case("integer-24", "integer", "Integer 24", 1, function() return 24 end),
            _Case("integer-255", "integer", "Integer 255", 1, function() return 255 end),
            _Case("integer-256", "integer", "Integer 256", 1, function() return 256 end),
            _Case("integer-65535", "integer", "Integer 65535", 1, function() return 65535 end),
            _Case("integer-65536", "integer", "Integer 65536", 1, function() return 65536 end),
            _Case("integer-uint32-max", "integer", "UInt32 max", 1, function() return 4294967295 end),
            _Case("integer-uint32-plus-one", "integer", "UInt32 max plus one", 1, function()
                return 4294967296
            end),
            _Case("integer-safe-max", "integer", "Lua 5.1 safe integer max", 1, function()
                return 9007199254740992
            end),
            _Case("negative-one", "integer", "Integer -1", 1, function() return -1 end),
            _Case("negative-24", "integer", "Integer -24", 1, function() return -24 end),
            _Case("negative-25", "integer", "Integer -25", 1, function() return -25 end),
            _Case("negative-256", "integer", "Integer -256", 1, function() return -256 end),
            _Case("negative-65536", "integer", "Integer -65536", 1, function() return -65536 end),

            _Case("float-half-exact", "float", "Half-exact float", 1, function() return 0.5 end),
            _Case("float-double-typical", "float", "Typical double", 1, function() return 1.1 end),
            _Case("float-positive-infinity", "float", "Positive infinity", 1, function() return huge end),
            _Case("float-negative-infinity", "float", "Negative infinity", 1, function() return -huge end),
            _Case("float-nan", "float", "NaN", 1, _BuildNaN, {
                notes = "NaN payload bits may be canonicalized differently by clients.",
            }),
            _Case("float-negative-zero", "float", "Negative zero", 1, _BuildNegativeZero),

            _Case("table-empty", "table", "Empty table", 1, function() return {} end),
            _Case("table-dense-array", "table", "Dense array", 1, function()
                return {"a", "b", "c"}
            end),
            _Case("table-sparse-small-gap", "table", "Sparse small gap", 1, function()
                return {[1] = "a", [3] = "c"}
            end, {
                notes = "Live fixtures serialize this dense-enough sparse table as an array with a CBOR null gap.",
            }),
            _Case("table-sparse-large-gap", "table", "Sparse large gap", 1, function()
                return {[1] = "a", [100] = "z"}
            end, {mapOrderUnstable = true}),
            _Case("table-zero-index", "table", "Zero index map", 1, function()
                return {[0] = "zero", [1] = "one"}
            end, {mapOrderUnstable = true}),
            _Case("table-string-key-map", "table", "String-key map", 1, function()
                return {name = "Questie", version = 1}
            end, {mapOrderUnstable = true}),
            _Case("table-mixed-key-map", "table", "Mixed-key map", 1, function()
                return {[1] = "array-value", addon = "Questie"}
            end, {mapOrderUnstable = true}),
            _Case("table-boolean-key-map", "table", "Boolean-key map", 1, function()
                return {[false] = "false-key", [true] = "true-key"}
            end, {mapOrderUnstable = true}),
            _Case("table-table-key-map", "table", "Table-key map", 1, _BuildTableKeyMap, {
                mapOrderUnstable = true,
            }),
            _Case("table-nested-depth-100", "table", "Depth boundary", 1, function()
                return _BuildNestedArray(100)
            end),
            _Case("table-nested-depth-101", "table", "Depth overflow", 1, function()
                return _BuildNestedArray(101)
            end, {expectSerializeError = true}),
            _Case("table-recursive", "error", "Recursive table", 1, _BuildRecursiveTable, {
                expectSerializeError = true,
            }),

            _Case("unsupported-function-root", "error", "Function root", 1, _BuildFunctionValue, {
                expectSerializeError = true,
            }),
            _Case("unsupported-function-root-ignored", "error", "Ignored function root", 2, _BuildIgnoredFunctionValue),
            _Case("unsupported-function-in-map", "error", "Function in map", 1, _BuildTableWithFunctionValue, {
                expectSerializeError = true,
                mapOrderUnstable = true,
            }),
            _Case("unsupported-function-in-map-ignored", "error", "Ignored function in map", 2,
                _BuildIgnoredTableWithFunctionValue, {mapOrderUnstable = true}),
            _Case("unsupported-function-map-key", "error", "Function map key", 1, _BuildFunctionKeyMap, {
                expectSerializeError = true,
            }),
            _Case("unsupported-function-map-key-ignored", "error", "Ignored function map key", 2,
                _BuildIgnoredFunctionKeyMap, {
                    notes = "Blizzard emits CBOR undefined for the unsupported key; that payload may not deserialize back into a Lua table.",
                }),
        }
    end

    ---@param serializeCBOR function Serializer under test.
    ---@param compatibilityCase table Case returned by GetCases.
    ---@return boolean ok True when serialization succeeded.
    ---@return any outputOrError Serialized bytes on success, error object/string on failure.
    function compatibilityCases.CallSerialize(serializeCBOR, compatibilityCase)
        local value, options = compatibilityCase.buildArguments()

        if compatibilityCase.argumentCount == 0 then
            return pcall(serializeCBOR)
        elseif compatibilityCase.argumentCount == 1 then
            return pcall(serializeCBOR, value)
        elseif compatibilityCase.argumentCount == 2 then
            return pcall(serializeCBOR, value, options)
        end

        error("unsupported compatibility argument count for " .. tostring(compatibilityCase.id), 2)
    end

    return compatibilityCases
end

---@return table compatibilityCases Case API to use.
---@return string source Description of where the case API came from.
local function _GetCompatibilityCases()
    local sharedCases = _G.QuestieBlizzardCBORCompatibilityCases

    if type(sharedCases) == "table"
        and type(sharedCases.GetCases) == "function"
        and type(sharedCases.CallSerialize) == "function" then
        return sharedCases, "QuestieBlizzardCBORCompatibilityCases global"
    end

    return _BuildEmbeddedCompatibilityCases(), "embedded helper copy"
end

---@param bytes string Binary bytes.
---@return string hex Lowercase hex.
local function _BytesToHex(bytes)
    local hex = {}

    for index = 1, string.len(bytes) do
        hex[index] = string.format("%02x", string.byte(bytes, index))
    end

    return table.concat(hex)
end

---@return table metadata Client/build metadata safe for SavedVariables.
local function _GetBuildMetadata()
    local version, build, buildDate, interfaceVersion

    if type(GetBuildInfo) == "function" then
        version, build, buildDate, interfaceVersion = GetBuildInfo()
    end

    return {
        version = version,
        build = build,
        buildDate = buildDate,
        interfaceVersion = interfaceVersion,
        locale = type(GetLocale) == "function" and GetLocale() or nil,
        projectId = WOW_PROJECT_ID,
        capturedAt = type(date) == "function" and date("%Y-%m-%d %H:%M:%S") or nil,
    }
end

---@return table db SavedVariables root.
local function _EnsureDB()
    QuestieBlizzardCBORCompatDB = QuestieBlizzardCBORCompatDB or {}
    QuestieBlizzardCBORCompatDB.runs = QuestieBlizzardCBORCompatDB.runs or {}

    return QuestieBlizzardCBORCompatDB
end

---@return function? serializeCBOR Pure Lua mock serializer, if manually loaded.
---@return string? reason Unavailability reason.
local function _FindMockSerializer()
    local mock = QuestieBlizzardCBORMock

    if type(mock) ~= "table" or type(mock.SerializeCBOR) ~= "function" then
        return nil, "QuestieBlizzardCBORMock is not loaded"
    end

    return mock.SerializeCBOR, nil
end

---@param compatibilityCases table Case API.
---@param serializeCBOR function Serializer under test.
---@param compatibilityCase table Case to capture.
---@return table capture SavedVariables-safe result.
local function _CaptureSerializerResult(compatibilityCases, serializeCBOR, compatibilityCase)
    local ok, outputOrError = compatibilityCases.CallSerialize(serializeCBOR, compatibilityCase)

    if not ok then
        return {
            ok = false,
            error = tostring(outputOrError),
        }
    end

    if type(outputOrError) ~= "string" then
        return {
            ok = false,
            error = "serializer returned " .. type(outputOrError) .. " instead of string",
        }
    end

    return {
        ok = true,
        byteLength = string.len(outputOrError),
        hex = _BytesToHex(outputOrError),
    }
end

---@param run table Completed run.
---@return table summary Human-readable counters.
local function _SummarizeRun(run)
    local summary = {
        total = 0,
        blizzardSuccess = 0,
        blizzardErrors = 0,
        mockCompared = 0,
        mockMatches = 0,
        mockMismatches = 0,
    }

    for _, caseId in ipairs(run.resultOrder) do
        local result = run.results[caseId]
        summary.total = summary.total + 1

        if result.blizzard and result.blizzard.ok then
            summary.blizzardSuccess = summary.blizzardSuccess + 1
        else
            summary.blizzardErrors = summary.blizzardErrors + 1
        end

        if result.mock then
            summary.mockCompared = summary.mockCompared + 1
            if result.mockMatchesBlizzard then
                summary.mockMatches = summary.mockMatches + 1
            else
                summary.mockMismatches = summary.mockMismatches + 1
            end
        end
    end

    return summary
end

---@param run table Completed run to persist.
---@return nil
local function _StoreRun(run)
    local db = _EnsureDB()

    db.latestRun = run
    table.insert(db.runs, 1, run)

    while #db.runs > MAX_STORED_RUNS do
        table.remove(db.runs)
    end
end

---@return nil
local function _RunCapture()
    local compatibilityCases, casesSource = _GetCompatibilityCases()
    local buildMetadata = _GetBuildMetadata()
    local blizzardSerialize = C_EncodingUtil and C_EncodingUtil.SerializeCBOR
    local mockSerialize, mockUnavailableReason = _FindMockSerializer()

    local run = {
        formatVersion = SAVED_VARIABLE_FORMAT_VERSION,
        addonName = ADDON_NAME,
        casesSource = casesSource,
        build = buildMetadata,
        mockSerializerStatus = mockSerialize and "available" or mockUnavailableReason,
        resultOrder = {},
        results = {},
    }

    if type(blizzardSerialize) ~= "function" then
        run.fatalError = "C_EncodingUtil.SerializeCBOR is not available in this client"
        _StoreRun(run)
        print("[" .. ADDON_NAME .. "] " .. run.fatalError)
        return
    end

    for _, compatibilityCase in ipairs(compatibilityCases.GetCases()) do
        local result = {
            id = compatibilityCase.id,
            category = compatibilityCase.category,
            description = compatibilityCase.description,
            expectSerializeError = compatibilityCase.expectSerializeError or nil,
            mapOrderUnstable = compatibilityCase.mapOrderUnstable or nil,
            notes = compatibilityCase.notes,
            blizzard = _CaptureSerializerResult(compatibilityCases, blizzardSerialize, compatibilityCase),
        }

        if mockSerialize then
            result.mock = _CaptureSerializerResult(compatibilityCases, mockSerialize, compatibilityCase)
            result.mockMatchesBlizzard = result.blizzard.ok == result.mock.ok
                and result.blizzard.hex == result.mock.hex
                and (result.blizzard.ok or result.mock.error ~= nil)
        end

        table.insert(run.resultOrder, compatibilityCase.id)
        run.results[compatibilityCase.id] = result
    end

    run.summary = _SummarizeRun(run)
    _StoreRun(run)

    print("[" .. ADDON_NAME .. "] Captured " .. run.summary.total .. " CBOR cases from " .. casesSource .. ".")
    print("[" .. ADDON_NAME .. "] Blizzard: "
        .. run.summary.blizzardSuccess .. " success, "
        .. run.summary.blizzardErrors .. " error.")

    if mockSerialize then
        print("[" .. ADDON_NAME .. "] Mock compare: "
            .. run.summary.mockMatches .. " match, "
            .. run.summary.mockMismatches .. " mismatch.")
    else
        print("[" .. ADDON_NAME .. "] Mock compare skipped: " .. tostring(mockUnavailableReason))
    end

    print("[" .. ADDON_NAME .. "] Reload or log out, then copy "
        .. "QuestieBlizzardCBORCompatDB.latestRun from SavedVariables.")
end

---@return nil
local function _PrintCases()
    local compatibilityCases, casesSource = _GetCompatibilityCases()

    print("[" .. ADDON_NAME .. "] Cases from " .. casesSource .. ":")
    for _, compatibilityCase in ipairs(compatibilityCases.GetCases()) do
        print("  " .. compatibilityCase.id .. " (" .. compatibilityCase.category .. ")")
    end
end

---@param message string? Slash command arguments.
---@return nil
local function _SlashCommand(message)
    message = string.lower(message or "")

    if message == "clear" then
        QuestieBlizzardCBORCompatDB = {runs = {}}
        print("[" .. ADDON_NAME .. "] Cleared captured runs.")
    elseif message == "cases" then
        _PrintCases()
    else
        _RunCapture()
    end
end

SLASH_QUESTIEBLIZZARDCBORCOMPAT1 = "/qcborcompat"
SlashCmdList.QUESTIEBLIZZARDCBORCOMPAT = _SlashCommand

print("[" .. ADDON_NAME .. "] Loaded. Run /qcborcompat to capture Blizzard CBOR fixtures.")
