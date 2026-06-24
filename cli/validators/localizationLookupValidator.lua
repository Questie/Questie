local LocalizationLookupValidator = {}

local projectDir = os.getenv("PWD") or "."

-- Keep these defaults in sync with generated lookup folders; adding a value here extends CI coverage.
local DEFAULT_EXPANSIONS = {"Classic", "TBC", "Wotlk", "Cata", "MoP"}
local DEFAULT_LOCALES = {"deDE", "esES", "esMX", "frFR", "koKR", "ptBR", "ruRU", "zhCN", "zhTW"}
local DEFAULT_LOOKUP_TYPES = {
    {directory = "lookupItems", tableName = "itemLookup"},
    {directory = "lookupNpcs", tableName = "npcNameLookup"},
    {directory = "lookupObjects", tableName = "objectLookup"},
    {directory = "lookupQuests", tableName = "questLookup"},
}

local function _CountEntries(entries)
    local count = 0
    for _ in pairs(entries) do
        count = count + 1
    end
    return count
end

local function _JoinPath(...)
    local parts = {...}
    return table.concat(parts, "/")
end

local function _CreateL10nStub()
    return {
        itemLookup = {},
        npcNameLookup = {},
        objectLookup = {},
        questLookup = {},
    }
end

local function _CreateQuestieDBStub()
    return {
        questKeys = {
            name = 1,
            objectivesText = 2,
        },
    }
end

local function _WithLookupEnvironment(locale, filePath, callback)
    local originalGetLocale = _G.GetLocale
    local originalQuestieLoader = _G.QuestieLoader
    local originalQuestie = _G.Questie
    local originalLoadstring = _G.loadstring

    local l10n = _CreateL10nStub()
    local questieDB = _CreateQuestieDBStub()

    _G.GetLocale = function()
        return locale
    end
    _G.Questie = {}
    _G.QuestieLoader = {
        ImportModule = function(_, moduleName)
            if moduleName == "l10n" then
                return l10n
            elseif moduleName == "QuestieDB" then
                return questieDB
            end

            error("Unexpected module import while validating " .. filePath .. ": " .. tostring(moduleName))
        end,
    }
    _G.loadstring = function(source, chunkName)
        local chunk, err = originalLoadstring(source, chunkName or ("@" .. filePath))
        if not chunk then
            error(filePath .. ": " .. tostring(err), 2)
        end

        return chunk
    end

    local ok, result = pcall(callback, l10n)

    _G.GetLocale = originalGetLocale
    _G.QuestieLoader = originalQuestieLoader
    _G.Questie = originalQuestie
    _G.loadstring = originalLoadstring

    if not ok then
        error(result, 0)
    end

    return result
end

local function _AssertLookupFunctionReturnsTable(filePath, description, lookupFunction)
    local ok, result = pcall(lookupFunction)
    if not ok then
        error(filePath .. ": " .. description .. " failed while executing: " .. tostring(result), 0)
    end

    if type(result) ~= "table" then
        error(filePath .. ": " .. description .. " returned " .. type(result) .. " instead of table", 0)
    end
end

local function _LoadLookupFile(filePath, locale, expectedTableName)
    return _WithLookupEnvironment(locale, filePath, function(l10n)
        local chunk, loadError = loadfile(filePath)
        if not chunk then
            error(filePath .. ": " .. tostring(loadError), 0)
        end

        local ok, runtimeError = pcall(chunk)
        if not ok then
            error(tostring(runtimeError), 0)
        end

        local lookupFunction = l10n[expectedTableName][locale]
        local lookupDescription = "l10n." .. expectedTableName .. "[\"" .. locale .. "\"]"
        if type(lookupFunction) ~= "function" then
            error(filePath .. ": did not register " .. lookupDescription .. " as a function", 0)
        end

        _AssertLookupFunctionReturnsTable(filePath, lookupDescription, lookupFunction)
    end)
end

local function _LoadLookupOverridesFile(filePath, locale)
    return _WithLookupEnvironment(locale, filePath, function(l10n)
        local chunk, loadError = loadfile(filePath)
        if not chunk then
            error(filePath .. ": " .. tostring(loadError), 0)
        end

        local ok, runtimeError = pcall(chunk)
        if not ok then
            error(tostring(runtimeError), 0)
        end

        if type(l10n.questLookupOverrides) ~= "function" then
            error(filePath .. " (" .. locale .. "): did not register l10n.questLookupOverrides as a function", 0)
        end

        _AssertLookupFunctionReturnsTable(filePath .. " (" .. locale .. ")", "l10n.questLookupOverrides", l10n.questLookupOverrides)
    end)
end

function LocalizationLookupValidator.Validate(options)
    options = options or {}

    -- Lookup files hide generated tables inside loadstring([[return {...}]]), so luac/loadfile only parse the wrapper.
    -- This validator compiles and executes each registered lookup function to catch malformed generated payloads.

    local lookupRoot = options.lookupRoot or _JoinPath(projectDir, "Localization", "lookups")
    local expansions = options.expansions or DEFAULT_EXPANSIONS
    local locales = options.locales or DEFAULT_LOCALES
    local lookupTypes = options.lookupTypes or DEFAULT_LOOKUP_TYPES
    local includeOverrides = options.includeOverrides ~= false

    print("\n\27[36mValidating localization lookup loadstrings...\27[0m")

    local invalidLookups = {}
    local checkedCount = 0

    for _, expansion in ipairs(expansions) do
        for _, lookupType in ipairs(lookupTypes) do
            for _, locale in ipairs(locales) do
                local filePath = _JoinPath(lookupRoot, expansion, lookupType.directory, locale .. ".lua")
                checkedCount = checkedCount + 1

                local ok, err = pcall(_LoadLookupFile, filePath, locale, lookupType.tableName)
                if not ok then
                    invalidLookups[filePath] = tostring(err)
                end
            end
        end
    end

    if includeOverrides then
        local overridesPath = _JoinPath(lookupRoot, "lookupOverrides.lua")
        for _, locale in ipairs(locales) do
            local key = overridesPath .. " (" .. locale .. ")"
            checkedCount = checkedCount + 1

            local ok, err = pcall(_LoadLookupOverridesFile, overridesPath, locale)
            if not ok then
                invalidLookups[key] = tostring(err)
            end
        end
    end

    local invalidCount = _CountEntries(invalidLookups)
    if invalidCount > 0 then
        print("\27[31mFound " .. invalidCount .. " invalid localization lookup loadstrings:\27[0m")
        for filePath, reason in pairs(invalidLookups) do
            print("\27[31m- " .. filePath .. ": " .. reason .. "\27[0m")
        end

        os.exit(1)
        return invalidLookups
    end

    print("\27[32mValidated " .. checkedCount .. " localization lookup loadstrings\27[0m")
    return nil
end

return LocalizationLookupValidator
