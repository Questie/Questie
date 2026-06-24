local lfs = require("lfs")
local LocalizationLookupValidator = require("cli.validators.localizationLookupValidator")

local fixtureRoot = "cli/output/localizationLookupValidator"
local originalExit = os.exit
local originalPrint = _G.print
local exitMock
local printedLines

local function _Mkdir(path)
    lfs.mkdir(path)
end

local function _WriteFile(path, content)
    local file = assert(io.open(path, "w"))
    file:write(content)
    file:close()
end

local function _CreateLookupFixture(content, overridesContent)
    _Mkdir("cli/output")
    _Mkdir(fixtureRoot)
    _Mkdir(fixtureRoot .. "/Classic")
    _Mkdir(fixtureRoot .. "/Classic/lookupItems")

    _WriteFile(fixtureRoot .. "/Classic/lookupItems/deDE.lua", content)
    _WriteFile(fixtureRoot .. "/lookupOverrides.lua", overridesContent or [=[
local l10n = QuestieLoader:ImportModule("l10n")
if GetLocale() == "deDE" then
    l10n.questLookupOverrides = loadstring([[return {
        [1] = {"Override"},
    }]])
end
]=])
end

local function _ValidateFixture(options)
    options = options or {}
    options.lookupRoot = fixtureRoot
    options.expansions = {"Classic"}
    options.locales = {"deDE"}
    options.lookupTypes = {
        {directory = "lookupItems", tableName = "itemLookup"},
    }

    return LocalizationLookupValidator.Validate(options)
end

local function _PrintedOutput()
    return table.concat(printedLines, "\n")
end

describe("LocalizationLookupValidator", function()
    before_each(function()
        printedLines = {}
        exitMock = spy.new(function() end)
        os.exit = exitMock
        _G.print = function(...)
            local parts = {...}
            for index, value in ipairs(parts) do
                parts[index] = tostring(value)
            end
            table.insert(printedLines, table.concat(parts, "\t"))
        end
    end)

    after_each(function()
        os.exit = originalExit
        _G.print = originalPrint
    end)

    it("should validate generated lookup files and lookup overrides", function()
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
l10n.itemLookup["deDE"] = loadstring([[return {
    [1] = "Test Item",
}]])
]=])

        local invalidLookups = _ValidateFixture()

        assert.are.same(nil, invalidLookups)
        assert.spy(exitMock).was_not_called()
    end)

    it("should report malformed generated lookup loadstrings", function()
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
l10n.itemLookup["deDE"] = loadstring([[return {
    [1] = "Test Item",
}}]])
]=])

        local invalidLookups = _ValidateFixture({includeOverrides = false})

        assert.is_not_nil(invalidLookups[fixtureRoot .. "/Classic/lookupItems/deDE.lua"])
        assert.spy(exitMock).was_called_with(1)
    end)

    it("should print readable context for malformed generated lookup loadstrings", function()
        local filePath = fixtureRoot .. "/Classic/lookupItems/deDE.lua"
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
l10n.itemLookup["deDE"] = loadstring([[return {
    [1] = "Test Item",
}}]])
]=])

        _ValidateFixture({includeOverrides = false})

        local output = _PrintedOutput()
        assert.is_not_nil(output:find("Localization lookup validation failed", 1, true))
        assert.is_not_nil(output:find("Expansion: Classic", 1, true))
        assert.is_not_nil(output:find("Locale: deDE", 1, true))
        assert.is_not_nil(output:find("Lookup: lookupItems", 1, true))
        assert.is_not_nil(output:find("File: " .. filePath, 1, true))
        assert.is_not_nil(output:find("Lua chunk line:", 1, true))
        assert.is_not_nil(output:find("Error:", 1, true))
        assert.is_not_nil(output:find("extra/missing brace, comma, or quote", 1, true))
        assert.spy(exitMock).was_called_with(1)
    end)

    it("should report generated lookup files that do not register a lookup function", function()
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
local unusedLookup = loadstring([[return {
    [1] = "Test Item",
}]])
]=])

        local invalidLookups = _ValidateFixture({includeOverrides = false})

        assert.is_not_nil(invalidLookups[fixtureRoot .. "/Classic/lookupItems/deDE.lua"])
        assert.spy(exitMock).was_called_with(1)
    end)

    it("should report generated lookup functions that return a non-table value", function()
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
l10n.itemLookup["deDE"] = loadstring([[return true]])
]=])

        local invalidLookups = _ValidateFixture({includeOverrides = false})

        assert.is_not_nil(invalidLookups[fixtureRoot .. "/Classic/lookupItems/deDE.lua"])
        assert.spy(exitMock).was_called_with(1)
    end)

    it("should report generated lookup functions that fail while executing", function()
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
l10n.itemLookup["deDE"] = loadstring([[error("boom")]])
]=])

        local invalidLookups = _ValidateFixture({includeOverrides = false})

        assert.is_not_nil(invalidLookups[fixtureRoot .. "/Classic/lookupItems/deDE.lua"])
        assert.spy(exitMock).was_called_with(1)
    end)

    it("should report malformed lookup override loadstrings", function()
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
l10n.itemLookup["deDE"] = loadstring([[return {
    [1] = "Test Item",
}]])
]=], [=[
local l10n = QuestieLoader:ImportModule("l10n")
if GetLocale() == "deDE" then
    l10n.questLookupOverrides = loadstring([[return {
        [1] = {"Override"},
        ]])
end
]=])

        local invalidLookups = _ValidateFixture()

        assert.is_not_nil(invalidLookups[fixtureRoot .. "/lookupOverrides.lua (deDE)"])
        assert.spy(exitMock).was_called_with(1)
    end)

    it("should report lookup override functions that return a non-table value", function()
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
l10n.itemLookup["deDE"] = loadstring([[return {
    [1] = "Test Item",
}]])
]=], [=[
local l10n = QuestieLoader:ImportModule("l10n")
if GetLocale() == "deDE" then
    l10n.questLookupOverrides = loadstring([[return true]])
end
]=])

        local invalidLookups = _ValidateFixture()

        assert.is_not_nil(invalidLookups[fixtureRoot .. "/lookupOverrides.lua (deDE)"])
        assert.spy(exitMock).was_called_with(1)
    end)

    it("should report lookup override functions that fail while executing", function()
        _CreateLookupFixture([=[
if GetLocale() ~= "deDE" then return end
local l10n = QuestieLoader:ImportModule("l10n")
l10n.itemLookup["deDE"] = loadstring([[return {
    [1] = "Test Item",
}]])
]=], [=[
local l10n = QuestieLoader:ImportModule("l10n")
if GetLocale() == "deDE" then
    l10n.questLookupOverrides = loadstring([[error("boom")]])
end
]=])

        local invalidLookups = _ValidateFixture()

        assert.is_not_nil(invalidLookups[fixtureRoot .. "/lookupOverrides.lua (deDE)"])
        assert.spy(exitMock).was_called_with(1)
    end)
end)
