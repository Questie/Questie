describe("localization lookup overrides", function()
    local l10n
    local QuestieDB
    local originalGetLocale
    local originalQuestieLoader
    local originalQuestie
    local currentLookupFile
    local originalLoadstring

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
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)

    describe("esES", function()
        before_each(function()
            _G.GetLocale = function() return "esES" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)

    describe("esMX", function()
        before_each(function()
            _G.GetLocale = function() return "esMX" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)

    describe("frFR", function()
        before_each(function()
            _G.GetLocale = function() return "frFR" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)

    describe("koKR", function()
        before_each(function()
            _G.GetLocale = function() return "koKR" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)

    describe("ptBR", function()
        before_each(function()
            _G.GetLocale = function() return "ptBR" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)

    describe("ruRU", function()
        before_each(function()
            _G.GetLocale = function() return "ruRU" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)

    describe("zhCN", function()
        before_each(function()
            _G.GetLocale = function() return "zhCN" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)

    describe("zhTW", function()
        before_each(function()
            _G.GetLocale = function() return "zhTW" end
        end)

        it("validates lookupOverrides", function()
            currentLookupFile = "Localization/lookups/lookupOverrides.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookupOverrides))
            assert.are.same("table", type(l10n.questLookupOverrides()))
        end)
    end)
end)
