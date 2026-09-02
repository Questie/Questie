---@class EntityLocale
local EntityLocale = QuestieLoader:CreateModule("EntityLocale")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Entity localization is provider-owned. This seam forwards Questie's effective locale to
-- QuestieTDB and turns an external locale addon's entity lookups into Questie Policy Correction
-- rows. UI strings stay in l10n; QuestieCorrections applies the rows built here.

---Forwards Questie's effective locale to QuestieTDB's built-in entity localization. Login
---Initialization calls this after the Contract check and before any entity read.
---@param locale string Effective UI locale, e.g. "deDE".
---@return nil
function EntityLocale.ForwardProviderLocale(locale)
    LibQuestieDB.l10n.SetLocale(locale)
end

---Resolves one external lookup. The addon contract supplies a function returning a table, because
---generated lookups were loadstring functions; a plain table is accepted as well.
---@param lookup (fun(): table)|table|nil
---@return table rows
local function _LookupRows(lookup)
    if type(lookup) == "function" then
        return lookup() or {}
    end
    return lookup or {}
end

---An external name is usable only as a non-empty string: the provider keeps `""` distinct from nil,
---so an empty string would blank the composed name.
---@param value unknown
---@return boolean
local function _IsText(value)
    return type(value) == "string" and value ~= ""
end

---Objective lines are usable only as a non-empty table: `{}` is the Correction idiom that clears a
---field, which would erase the quest's objective text.
---@param value unknown
---@return boolean
local function _HasLines(value)
    return type(value) == "table" and next(value) ~= nil
end

---Builds the four external locale Policy Correction tables from `QUESTIE_LOCALES_OVERRIDE`.
---
---Rows are accepted only for IDs whose composed entity currently exists. QuestieTDB Corrections can
---create entities, so an unfiltered external lookup could add stale or wrong-flavor name-only
---entities to the composed view and to Questie's pointer maps. Build against a view the external
---layer has not contributed to: before the initial apply, or after
---`QuestieCorrections.WithdrawExternalLocaleCorrections`.
---
---Returns empty tables when no external addon is loaded or when it supplies a different locale
---than the effective one; external entity names only ever applied under their own locale.
---@param locale string Effective UI locale.
---@return ExternalLocaleCorrections
function EntityLocale.BuildExternalLocaleCorrections(locale)
    local corrections = {Item = {}, Quest = {}, Npc = {}, Object = {}}
    local override = QUESTIE_LOCALES_OVERRIDE
    if (not override) or override.locale ~= locale then
        return corrections
    end

    local itemKeys, questKeys, npcKeys, objectKeys = QuestieDB.itemKeys, QuestieDB.questKeys, QuestieDB.npcKeys, QuestieDB.objectKeys
    local itemExists, questExists = LibQuestieDB.Item.Exists, LibQuestieDB.Quest.Exists
    local npcExists, objectExists = LibQuestieDB.Npc.Exists, LibQuestieDB.Object.Exists

    -- Items: `[itemId] = name`
    for itemId, name in pairs(_LookupRows(override.itemLookup)) do
        if _IsText(name) and itemExists(itemId) then
            corrections.Item[itemId] = {[itemKeys.name] = name}
        end
    end

    -- Quests: `[questId] = {name?, {objectiveText, ...}?}`
    for questId, data in pairs(_LookupRows(override.questLookup)) do
        if type(data) == "table" and questExists(questId) then
            local row = {}
            if _IsText(data[1]) then
                row[questKeys.name] = data[1]
            end
            if _HasLines(data[2]) then
                row[questKeys.objectivesText] = data[2]
            end
            if next(row) then
                corrections.Quest[questId] = row
            end
        end
    end

    -- NPCs: `[npcId] = name` or `[npcId] = {name?, subName?}`
    for npcId, data in pairs(_LookupRows(override.npcNameLookup)) do
        if data and npcExists(npcId) then
            local row = {}
            if _IsText(data) then
                row[npcKeys.name] = data
            elseif type(data) == "table" then
                if _IsText(data[1]) then
                    row[npcKeys.name] = data[1]
                end
                if _IsText(data[2]) then
                    row[npcKeys.subName] = data[2]
                end
            end
            if next(row) then
                corrections.Npc[npcId] = row
            end
        end
    end

    -- Objects: `[objectId] = name`
    for objectId, name in pairs(_LookupRows(override.objectLookup)) do
        if _IsText(name) and objectExists(objectId) then
            corrections.Object[objectId] = {[objectKeys.name] = name}
        end
    end

    return corrections
end
