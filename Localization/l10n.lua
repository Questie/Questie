---@class l10n
---@field continentLookup table
---@field zoneLookup table
---@field zoneCategoryLookup table
---@field questCategoryLookup table
---@field translations table<string, table<string, string|boolean>>
local l10n = QuestieLoader:CreateModule("l10n")
local _l10n = {}
l10n.translations = {}

-- Questie owns UI strings and UI locale selection. QuestieTDB owns entity localization.
-- An external translation addon therefore splits in two: its UI strings arrive through the
-- `QUESTIE_LOCALES_OVERRIDE` global read below (`locale`, `localeName`, `translations`), and its
-- entity names go straight to QuestieTDB under the addon's own Correction owner. The old entity
-- lookup fields on the global (`itemLookup`, `questLookup`, `npcNameLookup`, `objectLookup`) are
-- not read anymore.

---@type fun(): nil
local _InitializeLocaleOverride

---@type string
local locale = "enUS"
---@type table<string, boolean>
local supportedLocals = {
    ["enUS"] = true,
    ["deDE"] = true,
    ["esES"] = true,
    ["esMX"] = true,
    ["frFR"] = true,
    ["koKR"] = true,
    ["ptBR"] = true,
    ["ruRU"] = true,
    ["zhCN"] = true,
    ["zhTW"] = true,
}

---Resolves Questie's UI locale after Saved Variables and external UI translations are available.
---@return nil
function l10n.InitializeUILocale()
    if QUESTIE_LOCALES_OVERRIDE ~= nil then
        _InitializeLocaleOverride()
    end

    if Questie.db.global.questieLocaleDiff then
        l10n:SetUILocale(Questie.db.global.questieLocale)
    elseif QUESTIE_LOCALES_OVERRIDE ~= nil then
        l10n:SetUILocale(QUESTIE_LOCALES_OVERRIDE.locale)
    else
        l10n:SetUILocale(GetLocale())
    end
end

---Registers UI translations supplied by another addon.
---@return nil
_InitializeLocaleOverride = function()
    local overridingLocale = QUESTIE_LOCALES_OVERRIDE.locale
    supportedLocals[overridingLocale] = true

    for id in pairs(l10n.translations) do
        if QUESTIE_LOCALES_OVERRIDE.translations[id] ~= nil then
            l10n.translations[id][overridingLocale] = QUESTIE_LOCALES_OVERRIDE.translations[id]
        else
            l10n.translations[id][overridingLocale] = false
        end
    end
end

local format, unpack, tostring = string.format, unpack, tostring

---Translates one Questie-owned UI string for the active UI locale.
---@param key string English translation key and fallback format string.
---@param ... unknown Format arguments.
---@return string translatedText
function _l10n:translate(key, ...)
    local args = {...}

    for i, value in ipairs(args) do
        args[i] = tostring(value)
    end

    local translationEntry = l10n.translations[key]
    if not translationEntry then
        if Questie.db.profile.debugEnabled then
            Questie.Debug(Questie.DEBUG_ELEVATED, "ERROR: Translations for '" .. tostring(key) .. "' are missing completely!")
        end
        return format(key, unpack(args))
    end

    local translationValue = translationEntry[locale]
    if not translationValue then
        if Questie.db.profile.debugEnabled then
            Questie.Debug(Questie.DEBUG_ELEVATED, "ERROR: Translations for '" .. tostring(key) .. "' are missing the entry for language", locale, "!")
        end
        return format(key, unpack(args))
    end

    if translationValue == true then
        return format(key, unpack(args))
    end

    return format(translationValue, unpack(args))
end

setmetatable(l10n, {__call = function(_, ...) return _l10n:translate(...) end})

---Returns a supported UI locale or the English fallback.
---@param lang string|nil Requested locale.
---@return string locale
function l10n:GetFallbackLocale(lang)
    if not lang then
        return "enUS"
    end

    if supportedLocals[lang] then
        return lang
    end

    return "enUS"
end

---Selects the active locale for Questie-owned UI strings.
---@param lang string|nil Requested locale, or the client locale when nil.
---@return nil
function l10n:SetUILocale(lang)
    if lang then
        locale = l10n:GetFallbackLocale(lang)
    else
        locale = l10n:GetFallbackLocale(GetLocale())
    end
end

---Returns the active locale for Questie-owned UI strings.
---@return string locale
function l10n:GetUILocale()
    return locale
end
