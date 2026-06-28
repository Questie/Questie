describe("localization lookup overrides", function()
    local l10n
    local QuestieDB
    local originalGetLocale
    local originalQuestieLoader
    local originalQuestie
    local currentLookupFile
    local originalLoadstring

    local pairs = pairs
    local type = type
    local tostring = tostring
    local error = error

    local function _LoadRegisteredLookup(lookupFunction, lookupName, filePath)
        -- Override files register lookup-producing functions; load the generated table before schema validation.
        assert.are.same("function", type(lookupFunction), filePath .. " did not register " .. lookupName)

        local lookup = lookupFunction()
        assert.are.same("table", type(lookup), filePath .. " " .. lookupName .. " did not return a table")

        return lookup
    end

    local function _AssertObjectiveLines(value, filePath, id, fieldName)
        if value == nil then
            return
        end

        if type(value) ~= "table" then
            error(filePath .. " has invalid " .. fieldName .. " value type for ID " .. tostring(id) .. ": " .. type(value), 0)
        end
        for index, line in pairs(value) do
            if type(index) ~= "number" then
                error(filePath .. " has a non-number " .. fieldName .. " line key for ID " .. tostring(id) .. ": " .. tostring(index), 0)
            end
            if type(line) ~= "string" then
                error(filePath .. " has invalid " .. fieldName .. " line type for ID " .. tostring(id) .. ": " .. type(line), 0)
            end
        end
    end

    local function _AssertQuestOverrideShape(lookup, filePath)
        -- Current locale overrides use the same generated quest row contract as quest lookups: {title?, objectiveLines?}.
        -- The legacy format used {title?, descriptionLines?, objectiveLines?}; if that returns, l10n.lua and this
        -- schema validator must change together because field 3 is ignored today.
        for id, data in pairs(lookup) do
            if type(id) ~= "number" then
                error(filePath .. " has a non-number lookup override key: " .. tostring(id), 0)
            end
            if type(data) ~= "table" then
                error(filePath .. " has invalid lookup override value type for ID " .. tostring(id) .. ": " .. type(data), 0)
            end
            -- Only fields 1 and 2 are valid today: title and objective lines. Field 3 must not be generated now.
            for field in pairs(data) do
                if field ~= 1 and field ~= 2 then
                    error(filePath .. " has invalid lookup override field " .. tostring(field) .. " for ID " .. tostring(id), 0)
                end
            end
            if data[1] ~= nil and type(data[1]) ~= "string" then
                error(filePath .. " has invalid lookup override title value type for ID " .. tostring(id) .. ": " .. type(data[1]), 0)
            end
            _AssertObjectiveLines(data[2], filePath, id, "lookup override objective")
        end
    end

    local function _AssertTitanQuestOverrideShape(lookup, filePath)
        -- Titan quest overrides are correction-style rows keyed by QuestieDB questKeys, not generated lookup rows.
        for id, data in pairs(lookup) do
            if type(id) ~= "number" then
                error(filePath .. " has a non-number Titan override key: " .. tostring(id), 0)
            end
            if type(data) ~= "table" then
                error(filePath .. " has invalid Titan override value type for ID " .. tostring(id) .. ": " .. type(data), 0)
            end
            for field in pairs(data) do
                if field ~= QuestieDB.questKeys.name and field ~= QuestieDB.questKeys.objectivesText then
                    error(filePath .. " has invalid Titan override field " .. tostring(field) .. " for ID " .. tostring(id), 0)
                end
            end
            if data[QuestieDB.questKeys.name] ~= nil and type(data[QuestieDB.questKeys.name]) ~= "string" then
                error(filePath .. " has invalid Titan override name value type for ID " .. tostring(id) .. ": " .. type(data[QuestieDB.questKeys.name]), 0)
            end
            _AssertObjectiveLines(data[QuestieDB.questKeys.objectivesText], filePath, id, "Titan override objectivesText")
        end
    end

    before_each(function()
        l10n = {}
        QuestieDB = {
            questKeys = {
                name = 1,
                objectivesText = 2,
            },
        }
        originalGetLocale = _G.GetLocale
        originalQuestieLoader = _G.QuestieLoader
        originalQuestie = _G.Questie
        originalLoadstring = _G.loadstring

        _G.Questie = {}

        _G.loadstring = function(source, chunkName)
            local chunk, err = originalLoadstring(source, chunkName or ("@" .. currentLookupFile))
            if not chunk then
                -- Generated lookup data lives inside loadstring chunks. Lua reports syntax errors against the
                -- in-memory chunk line, not the physical .lua line.
                -- The loadstring caller line plus the chunk line maps back to the exact generated file line.
                local chunkLine = tonumber(tostring(err):match(":(%d+):"))
                local caller = debug.getinfo(2, "Sl")
                if chunkLine and caller and caller.currentline and caller.currentline > 0 then
                    local fileLine = caller.currentline + chunkLine - 1
                    error(
                        "Malformed localization lookup loadstring in " .. tostring(currentLookupFile) .. ":" .. fileLine .. ": " .. tostring(err),
                        2
                    )
                end

                error("Malformed localization lookup loadstring in " .. tostring(currentLookupFile) .. ": " .. tostring(err), 2)
            end

            return chunk
        end

        _G.QuestieLoader = {
            ImportModule = function(_, moduleName)
                if moduleName == "l10n" then
                    return l10n
                elseif moduleName == "QuestieDB" then
                    return QuestieDB
                end

                error("Unexpected module import: " .. tostring(moduleName))
            end,
        }
    end)

    after_each(function()
        _G.GetLocale = originalGetLocale
        _G.QuestieLoader = originalQuestieLoader
        _G.Questie = originalQuestie
        _G.loadstring = originalLoadstring
    end)

    describe("deDE", function()
        before_each(function()
            _G.GetLocale = function() return "deDE" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("esES", function()
        before_each(function()
            _G.GetLocale = function() return "esES" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("esMX", function()
        before_each(function()
            _G.GetLocale = function() return "esMX" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("frFR", function()
        before_each(function()
            _G.GetLocale = function() return "frFR" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("koKR", function()
        before_each(function()
            _G.GetLocale = function() return "koKR" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("ptBR", function()
        before_each(function()
            _G.GetLocale = function() return "ptBR" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("ruRU", function()
        before_each(function()
            _G.GetLocale = function() return "ruRU" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("zhCN", function()
        before_each(function()
            _G.GetLocale = function() return "zhCN" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("zhTW", function()
        before_each(function()
            _G.GetLocale = function() return "zhTW" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookupOverrides, "questLookupOverrides", currentLookupFile)
            _AssertQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)

    describe("Titan quest overrides", function()
        before_each(function()
            _G.GetLocale = function() return "enUS" end
        end)

        it("validates correction-style lookup overrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(Questie.LoadTitanQuestLookupOverrides, "LoadTitanQuestLookupOverrides", currentLookupFile)
            _AssertTitanQuestOverrideShape(lookup, currentLookupFile)
        end)
    end)
end)
