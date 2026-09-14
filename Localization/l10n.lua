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
-- An external translation addon supplies both through the `QUESTIE_LOCALES_OVERRIDE` global, the
-- same contract upstream Questie reads: `locale`, `localeName`, and `translations` for UI strings,
-- plus the optional `itemLookup`, `questLookup`, `npcNameLookup`, and `objectLookup` entity
-- lookups. UI strings stay in this module; the entity lookups are forwarded to QuestieTDB as
-- locale-scoped translation slots under their own owner, so one addon build serves both Questie variants.

---@type fun(): nil
local _InitializeLocaleOverride
---@type string|nil
local publishedLocale

---Correction owner for the external addon's entity names, so provenance names the source.
local LOCALE_OVERRIDE_OWNER = "QuestieLocalesOverride"

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

---Publishes external entity translations after the provider contract gate.
---
---Runs at login before QuestieDB binds anything, so the rows go straight to the provider with
---nothing to evict. Rows are kept only for IDs the composed database already has, as upstream's
---`if QuestieDB.itemData[id]` did, so stale locale data cannot create name-only entities.
---@return nil
function l10n.PublishLocaleOverrideEntityNames()
    ---Resolves one external lookup. Generated lookups are loadstring functions returning a table; a
    ---plain table is accepted as well.
    ---@param lookup (fun(): table)|table|nil
    ---@return table rows
    local function _LookupRows(lookup)
        if type(lookup) == "function" then
            lookup = lookup()
        end
        return type(lookup) == "table" and lookup or {}
    end

    ---A usable name is a non-empty string: the provider keeps `""` as a real value, so forwarding
    ---it would blank the composed name.
    ---@param value unknown
    ---@return string|nil
    local function _Text(value)
        if type(value) == "string" and value ~= "" then
            return value
        end
        return nil
    end

    local override = QUESTIE_LOCALES_OVERRIDE
    local Meta, Set = LibQuestieDB.Meta, LibQuestieDB.l10n.SetCorrection
    local overridingLocale = override and override.locale
    if overridingLocale == "enUS" then
        overridingLocale = nil
    end

    -- Withdraw only this adapter's slots when the addon disappears or changes locale.
    if publishedLocale and publishedLocale ~= overridingLocale then
        for _, datatype in ipairs({"Item", "Quest", "Npc", "Object"}) do
            Set(LOCALE_OVERRIDE_OWNER, publishedLocale, datatype, "EntityNames", nil)
        end
        publishedLocale = nil
    end
    if not overridingLocale then
        return
    end

    -- Items: `[itemId] = name`
    local itemKeys, itemExists = Meta.ItemMeta.itemKeys, LibQuestieDB.Item.Exists
    local items = {}
    for itemId, name in pairs(_LookupRows(override.itemLookup)) do
        if _Text(name) and itemExists(itemId) then
            items[itemId] = {[itemKeys.name] = name}
        end
    end

    -- Quests: `[questId] = {name, {objective, ...}}`. Generators built before Questie dropped the
    -- description element emit `{name, {description, ...}, {objective, ...}}`, so a third element
    -- is the objectives when present.
    local questKeys, questExists = Meta.QuestMeta.questKeys, LibQuestieDB.Quest.Exists
    local quests = {}
    for questId, data in pairs(_LookupRows(override.questLookup)) do
        if type(data) == "table" and questExists(questId) then
            -- A present legacy third slot wins even when empty or malformed. Never use its description as objectives.
            local lines = data[2]
            if data[3] ~= nil then
                lines = data[3]
            end
            local objectives
            if type(lines) == "table" and next(lines) ~= nil then
                local count, valid = 0, true
                for index, text in pairs(lines) do
                    count = count + 1
                    if type(index) ~= "number" or index < 1 or index == math.huge or index % 1 ~= 0
                        or type(text) ~= "string" or text == "" then
                        valid = false
                    end
                end
                local copy = {}
                for index = 1, count do
                    copy[index] = lines[index]
                    if lines[index] == nil then
                        valid = false
                    end
                end
                if valid then
                    objectives = copy
                end
            end
            local row = {
                [questKeys.name] = _Text(data[1]),
                [questKeys.objectivesText] = objectives,
            }
            if next(row) then
                quests[questId] = row
            end
        end
    end

    -- NPCs: `[npcId] = name` or `[npcId] = {name, subName}`
    local npcKeys, npcExists = Meta.NpcMeta.npcKeys, LibQuestieDB.Npc.Exists
    local npcs = {}
    for npcId, data in pairs(_LookupRows(override.npcNameLookup)) do
        if npcExists(npcId) then
            local row = {}
            if type(data) == "table" then
                row[npcKeys.name] = _Text(data[1])
                row[npcKeys.subName] = _Text(data[2])
            else
                row[npcKeys.name] = _Text(data)
            end
            if next(row) then
                npcs[npcId] = row
            end
        end
    end

    -- Objects: `[objectId] = name`
    local objectKeys, objectExists = Meta.ObjectMeta.objectKeys, LibQuestieDB.Object.Exists
    local objects = {}
    for objectId, name in pairs(_LookupRows(override.objectLookup)) do
        if _Text(name) and objectExists(objectId) then
            objects[objectId] = {[objectKeys.name] = name}
        end
    end

    -- Stable names replace removed rows too; nil withdraws empty slots without touching other owners.
    for datatype, rows in pairs({Item = items, Quest = quests, Npc = npcs, Object = objects}) do
        Set(LOCALE_OVERRIDE_OWNER, overridingLocale, datatype, "EntityNames", next(rows) and rows or nil)
    end
    publishedLocale = overridingLocale
end
