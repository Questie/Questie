---@class SourceModeStatus
local SourceModeStatus = QuestieLoader:CreateModule("SourceModeStatus")
---@type QuestieStatus
local QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local SOURCE_ICON = {texture = "Interface\\AddOns\\Questie\\Icons\\green_plus.png"}
local PROJECT_NAMES = {
    "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC", "WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
    "WOW_PROJECT_WRATH_CLASSIC", "WOW_PROJECT_CATACLYSM_CLASSIC", "WOW_PROJECT_MISTS_CLASSIC",
}
local EXPANSION_NAMES = {"Era", "Tbc", "Wotlk", "Cata", "MoP"}
local REGION_NAMES = {[1] = "US", [2] = "KR", [3] = "EU", [4] = "TW", [5] = "CN"}
local CLIENT_FLAGS = {"IsForever", "IsClassic", "IsEra", "IsTBC", "IsWotlk", "IsCata", "IsMoP"}
local REALM_FLAGS = {
    "IsSoM", "IsSoD", "IsTitanReforged", "IsAnniversaryEra", "IsAnniversaryTBC", "IsAnniversaryHardcore", "IsHardcore",
}

-- Source diagnostics use %s placeholders, so value-only color markup survives localization.
-- Labels and separators retain the tooltip's grey; missing values must not create argument holes.
local function _Value(value)
    local text = value == nil and "unavailable" or tostring(value)
    local color = "|cffffd100"
    if value == true then
        color = "|cff40ff40"
    elseif value == false then
        color = "|cffff8080"
    elseif text == "unknown" or text == "unavailable" then
        color = "|cff909090"
    end
    return color .. text .. "|r"
end

local function _ConstantName(value, constants, names)
    if value == nil then return "unavailable" end
    for _, name in ipairs(names) do
        if constants[name] == value then return name end
    end
    return "unknown"
end

local function _SeasonName(seasonId)
    if seasonId == nil then return "unavailable" end
    if seasonId == 0 then return "None" end
    -- VersionCheck recognizes Titan's ID explicitly; Blizzard has no SeasonID entry for it.
    if seasonId == 109 then return "TitanReforged" end
    local names = {}
    for name, id in pairs(Enum and Enum.SeasonID or {}) do
        if id == seasonId then names[#names + 1] = name end
    end
    table.sort(names)
    return names[1] or "unknown"
end

local function _Flags(names)
    local values = {}
    for _, name in ipairs(names) do
        values[#values + 1] = name .. ": " .. _Value(Questie[name])
    end
    return table.concat(values, ", ")
end

local function _ClientDetails()
    local version, build, buildDate, interfaceVersion = GetBuildInfo()
    local region = GetCurrentRegion()
    local seasonId, hasSeason
    if C_Seasons then
        if type(C_Seasons.GetActiveSeason) == "function" then seasonId = C_Seasons.GetActiveSeason() end
        if type(C_Seasons.HasActiveSeason) == "function" then hasSeason = C_Seasons.HasActiveSeason() end
    end
    local locale = type(GetLocale) == "function" and GetLocale() or nil

    -- Raw project identity and Questie's content expansion are different namespaces on Forever.
    -- Names and boolean flag values are technical identifiers, not translated display labels.
    return {
        {message = "Client: %s (build %s, %s)", args = {_Value(version), _Value(build), _Value(buildDate)}},
        {message = "Interface: %s", args = {_Value(interfaceVersion)}},
        {message = "Project: %s (%s)", args = {
            _Value(_ConstantName(WOW_PROJECT_ID, _G, PROJECT_NAMES)), _Value(WOW_PROJECT_ID),
        }},
        {message = "Questie expansion: %s (%s)", args = {
            _Value(_ConstantName(Expansions.Current, Expansions, EXPANSION_NAMES)), _Value(Expansions.Current),
        }},
        {message = "Season: %s (%s), active: %s", args = {_Value(_SeasonName(seasonId)), _Value(seasonId), _Value(hasSeason)}},
        {message = "Region: %s (%s), locale: %s", args = {_Value(REGION_NAMES[region] or "unknown"), _Value(region), _Value(locale)}},
        {message = "Client flags: %s", args = {_Flags(CLIENT_FLAGS)}},
        {message = "Realm flags: %s", args = {_Flags(REALM_FLAGS)}},
        {message = "Region flags: %s", args = {_Flags({"IsChinaRegion", "IsEURegion"})}},
    }
end

local function _ProviderDetails(provider)
    local expansion, statusError
    local indicator = provider.ModeIndicator
    if indicator and type(indicator.GetStatus) == "function" then
        -- Optional diagnostics must not prevent the real provider compatibility check from running.
        local ok, status = pcall(indicator.GetStatus)
        if ok and type(status) == "table" then
            expansion = status.expansion
        elseif not ok then
            statusError = tostring(status)
        end
    end

    local details = {
        {message = "Provider version: %s", args = {_Value(QuestieCompat.GetAddOnMetadata("QuestieDB", "Version"))}},
        {message = "Data expansion: %s", args = {_Value(expansion)}},
        {message = "Read mode: %s", args = {_Value(provider.readMode)}},
        {message = "Provider contracts: %s to %s; Questie requires %s", args = {
            _Value(provider.minSupportedContract), _Value(provider.contractVersion),
            _Value(QuestieCompat.GetAddOnMetadata("Questie", "X-QuestieDB-Contract")),
        }},
    }
    if statusError then
        details[#details + 1] = {message = "Provider diagnostics unavailable: %s", args = {statusError}}
    end
    return details
end

-- Diagnostic APIs can be absent or broken on a client. Their failure must not stop startup
-- before the status UI and the real compatibility checks have had a chance to run.
local function _CollectDetails(collect, failureMessage, ...)
    local ok, details = pcall(collect, ...)
    if ok then return details end
    return {{message = failureMessage, args = {tostring(details)}}}
end

---Captures load-time diagnostics before startup can fail; performs no entity reads or timing inference.
---Only these two notices are owned here. Both use the custom Source badge so an info default cannot replace it.
---@return boolean sourceMode
function SourceModeStatus.Update()
    local provider = LibQuestieDB
    if not provider or provider.readMode ~= "source" then
        QuestieStatus.Clear("questiedb.source-mode")
        QuestieStatus.Clear("questiedb.source-load")
        return false
    end

    QuestieStatus.Set("questiedb.source-mode", {
        severity = QuestieStatus.Severity.Info,
        message = "QuestieDB is running in Source mode.",
        details = _CollectDetails(_ClientDetails, "Client diagnostics unavailable: %s"),
        icon = SOURCE_ICON,
    })
    QuestieStatus.Set("questiedb.source-load", {
        severity = QuestieStatus.Severity.Info,
        message = "QuestieDB Source load information.",
        details = _CollectDetails(_ProviderDetails, "Provider diagnostics unavailable: %s", provider),
        icon = SOURCE_ICON,
    })
    return true
end
