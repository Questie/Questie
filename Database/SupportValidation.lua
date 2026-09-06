---@class SupportValidation
local SupportValidation = QuestieLoader:CreateModule("SupportValidation")

-- Independently authored controls, not a copy or audit of the full provider data.
-- Every pass reads only the tables the consumer actually bound or decoded.
---@type table<number, string>
local flavors = {[1] = "Era", [2] = "TBC", [3] = "Wotlk", [4] = "Cata", [5] = "MoP"}

---@param value any
---@param path table
---@return any
local function _Value(value, path)
    for _, key in ipairs(path) do
        if type(value) ~= "table" then return nil end
        value = value[key]
    end
    return value
end

---@param failures string[]
---@param control string
---@param actual any
---@param expected any
---@return nil
local function _Check(failures, control, actual, expected)
    if actual ~= expected then
        failures[#failures + 1] = control .. ": expected " .. tostring(expected) .. ", actual " .. tostring(actual)
    end
end

---@param failures string[]
---@param control string
---@param data any
---@param path table
---@param expected any
---@return nil
local function _Probe(failures, control, data, path, expected)
    _Check(failures, control, _Value(data, path), expected)
end

---@param failures string[]
---@param dataset string
---@param expansion number
---@return boolean valid
---@return string? report
local function _Result(failures, dataset, expansion)
    if #failures == 0 then return true end
    local metadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    local questieVersion = metadata and metadata("Questie", "Version") or "unknown"
    local tdbVersion = metadata and metadata("QuestieTDB", "Version") or "unknown"
    return false, "Questie support-data validation failed. Initialization stopped.\n" ..
        "Dataset: " .. dataset .. "; consumer flavor: " .. (flavors[expansion] or tostring(expansion)) ..
        "; provider readMode: " .. tostring(LibQuestieDB and LibQuestieDB.readMode or "unknown") ..
        "; Questie version: " .. questieVersion .. "; QuestieTDB version: " .. tdbVersion .. "\n" ..
        table.concat(failures, "\n")
end

---@class SupportValidationTableInput
---@field [1] string @Diagnostic path.
---@field [2] any @Observed value, including nil.

-- Check merge inputs before callers iterate or assign into them. Empty tables are valid.
---@param inputs SupportValidationTableInput[]
---@param dataset string
---@param expansion number
---@return boolean valid
---@return string? report
function SupportValidation.ValidateTableShapes(inputs, dataset, expansion)
    local failures = {}
    for _, input in ipairs(inputs) do
        _Check(failures, input[1], type(input[2]), "table")
    end
    return _Result(failures, dataset, expansion)
end

---@class SupportValidationZones
---@field zoneIDs table
---@field instanceIdToAreaId table
---@field areaIdToUiMapId table
---@field areaIdToUiMapIdOverride table
---@field uiMapIdToAreaId table
---@field uiMapIdToAreaIdOverride table
---@field subZoneToParentZone table
---@field subZoneToParentZoneOverride table
---@field dungeons table

---@param zones SupportValidationZones
---@param expansion number
---@return boolean valid
---@return string? report
function SupportValidation.ValidateZones(zones, expansion)
    local failures = {}
    _Check(failures, "consumer expansion", flavors[expansion] ~= nil, true)
    for _, field in ipairs({"zoneIDs", "instanceIdToAreaId", "areaIdToUiMapId", "areaIdToUiMapIdOverride",
        "uiMapIdToAreaId", "uiMapIdToAreaIdOverride", "subZoneToParentZone", "subZoneToParentZoneOverride", "dungeons"}) do
        _Check(failures, field, type(_Value(zones, {field})), "table")
    end
    _Check(failures, "dungeons[206]", type(_Value(zones, {"dungeons", 206})), "table")
    _Check(failures, "dungeons[206].entrance", type(_Value(zones, {"dungeons", 206, 4})), "table")
    local elwynnMap = expansion == 5 and 37 or 1429
    local continentMap = expansion == 5 and 12 or 1414
    local reverseOverrideKey = expansion == 5 and 12 or 113
    local reverseOverrideValue = expansion == 5 and 10073 or 0
    _Probe(failures, "zoneIDs.ELWYNN_FOREST", zones, {"zoneIDs", "ELWYNN_FOREST"}, 12)
    _Probe(failures, "zoneIDs.STORMWIND_CITY", zones, {"zoneIDs", "STORMWIND_CITY"}, 1519)
    _Probe(failures, "zoneIDs.DUN_MOROGH", zones, {"zoneIDs", "DUN_MOROGH"}, 1)
    _Probe(failures, "instanceIdToAreaId[33]", zones, {"instanceIdToAreaId", 33}, 209)
    _Probe(failures, "areaIdToUiMapId[12]", zones, {"areaIdToUiMapId", 12}, elwynnMap)
    _Probe(failures, "uiMapIdToAreaId[" .. elwynnMap .. "]", zones, {"uiMapIdToAreaId", elwynnMap}, 12)
    _Probe(failures, "areaIdToUiMapIdOverride[10073]", zones, {"areaIdToUiMapIdOverride", 10073}, continentMap)
    _Probe(failures, "areaIdToUiMapId[10073]", zones, {"areaIdToUiMapId", 10073}, continentMap)
    _Probe(failures, "uiMapIdToAreaIdOverride[" .. reverseOverrideKey .. "]",
        zones, {"uiMapIdToAreaIdOverride", reverseOverrideKey}, reverseOverrideValue)
    _Probe(failures, "uiMapIdToAreaId[" .. reverseOverrideKey .. "]",
        zones, {"uiMapIdToAreaId", reverseOverrideKey}, reverseOverrideValue)
    _Probe(failures, "subZoneToParentZone[2]", zones, {"subZoneToParentZone", 2}, 40)
    _Probe(failures, "subZoneToParentZoneOverride[133]", zones, {"subZoneToParentZoneOverride", 133}, 1)
    _Probe(failures, "subZoneToParentZone[133]", zones, {"subZoneToParentZone", 133}, 1)

    -- Utgarde Keep has the same entrance for both factions in every supported flavor.
    _Check(failures, "dungeons[206].alternativeAreas type", type(_Value(zones, {"dungeons", 206, 2})), "table")
    _Check(failures, "dungeons[206].entrance type", type(_Value(zones, {"dungeons", 206, 4, 1})), "table")
    _Probe(failures, "dungeons[206].name", zones, {"dungeons", 206, 1}, "Utgarde Keep")
    _Probe(failures, "dungeons[206].alternativeAreas[1]", zones, {"dungeons", 206, 2, 1}, 10057)
    _Probe(failures, "dungeons[206].alternativeAreas[2]", zones, {"dungeons", 206, 2, 2}, 10058)
    _Probe(failures, "dungeons[206].alternativeAreas[3]", zones, {"dungeons", 206, 2, 3}, nil)
    _Probe(failures, "dungeons[206].parentArea", zones, {"dungeons", 206, 3}, 495)
    _Probe(failures, "dungeons[206].entrance.area", zones, {"dungeons", 206, 4, 1, 1}, 495)
    _Probe(failures, "dungeons[206].entrance.x", zones, {"dungeons", 206, 4, 1, 2}, 58.8)
    _Probe(failures, "dungeons[206].entrance.y", zones, {"dungeons", 206, 4, 1, 3}, 48.3)
    return _Result(failures, "Zones", expansion)
end

---@param factionTemplate any
---@param expansion number
---@return boolean valid
---@return string? report
function SupportValidation.ValidateFactionTemplates(factionTemplate, expansion)
    local failures = {}
    _Check(failures, "consumer expansion", flavors[expansion] ~= nil, true)
    _Check(failures, "factionTemplate", type(factionTemplate), "table")
    _Probe(failures, "factionTemplate[1]", factionTemplate, {1}, 12)
    _Probe(failures, "factionTemplate[2]", factionTemplate, {2}, 10)
    _Probe(failures, "factionTemplate[7]", factionTemplate, {7}, 0)
    return _Result(failures, "FactionTemplates", expansion)
end

---@type table<number, table<number, number[]>>
local xpControls = {
    [1] = {[2] = {30, 2450}},
    [2] = {[2] = {30, 2450}, [10289] = {61, 2400}},
    [3] = {[2] = {30, 2450}, [13068] = {80, 2200}},
    [4] = {[2] = {23, 1850}, [28757] = {3, 500}},
    [5] = {[2] = {23, 1850}, [29948] = {87, 129000}},
}

---@param db any @Raw XP rows, before player-level or buff adjustments.
---@param expansion number
---@return boolean valid
---@return string? report
function SupportValidation.ValidateQuestXP(db, expansion)
    local failures = {}
    _Check(failures, "consumer expansion", flavors[expansion] ~= nil, true)
    _Check(failures, "db", type(db), "table")
    for questId, expected in pairs(xpControls[expansion] or {}) do
        _Check(failures, "db[" .. questId .. "] type", type(_Value(db, {questId})), "table")
        _Probe(failures, "db[" .. questId .. "].level", db, {questId, 1}, expected[1])
        _Probe(failures, "db[" .. questId .. "].xp", db, {questId, 2}, expected[2])
        _Probe(failures, "db[" .. questId .. "][3]", db, {questId, 3}, nil)
    end
    return _Result(failures, "QuestXP", expansion)
end

---@param wowhead any
---@param pserver any
---@param corrections any @Effective merged rows, not unused expansion-specific sources.
---@param source string
---@param expansion number
---@return boolean valid
---@return string? report
function SupportValidation.ValidateDropTables(wowhead, pserver, corrections, source, expansion)
    local failures = {}
    _Check(failures, "consumer expansion", flavors[expansion] ~= nil, true)
    _Check(failures, "sourcePserver", source, expansion >= 4 and "mangos3" or "cmangos")
    -- Bounded parent probes preserve malformed table/row types that leaf lookups cannot show.
    _Check(failures, "Wowhead", type(wowhead), "table")
    _Check(failures, "Pserver", type(pserver), "table")
    _Check(failures, "Corrections", type(corrections), "table")
    if type(wowhead) == "table" then
        _Check(failures, "Wowhead[981]", type(wowhead[981]), "table")
    end
    if type(pserver) == "table" then
        _Check(failures, "Pserver[182]", type(pserver[182]), "table")
    end
    if type(corrections) == "table" then
        _Check(failures, "Corrections[725]", type(corrections[725]), "table")
        if expansion >= 2 then
            _Check(failures, "Corrections[2633]", type(corrections[2633]), "table")
        end
        if expansion == 5 then
            _Check(failures, "Corrections[97530]", type(corrections[97530]), "table")
        end
    end
    -- Crowdsourced rates change; the known item/NPC pair must remain a usable percentage.
    local rate = _Value(wowhead, {981, 327})
    if type(rate) ~= "number" or not (rate > 0 and rate <= 100) then
        failures[#failures + 1] = "Wowhead[981][327]: expected number > 0 and <= 100, actual " .. tostring(rate)
    end
    _Probe(failures, "Pserver[182][103]", pserver, {182, 103}, 100)
    _Probe(failures, "Corrections[725][98]", corrections, {725, 98}, -1)
    if expansion >= 2 then
        _Probe(failures, "Corrections[2633][937]", corrections, {2633, 937}, -1)
    end
    if expansion == 5 then
        _Probe(failures, "Corrections[97530][70997]", corrections, {97530, 70997}, 100)
    end
    return _Result(failures, "DropTables", expansion)
end
