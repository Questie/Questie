describe("Classic localization lookup loadstrings", function()
    local l10n
    local originalGetLocale
    local originalQuestieLoader
    local currentLookupFile
    local originalLoadstring

    before_each(function()
        l10n = {
            itemLookup = {},
            npcNameLookup = {},
            objectLookup = {},
            questLookup = {},
        }
        originalGetLocale = _G.GetLocale
        originalQuestieLoader = _G.QuestieLoader
        originalLoadstring = _G.loadstring

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
            ImportModule = function()
                return l10n
            end,
        }
    end)

    after_each(function()
        _G.GetLocale = originalGetLocale
        _G.QuestieLoader = originalQuestieLoader
        _G.loadstring = originalLoadstring
    end)

    describe("deDE", function()
        before_each(function()
            _G.GetLocale = function() return "deDE" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/deDE.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["deDE"]))
            assert.are.same("table", type(l10n.itemLookup["deDE"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/deDE.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["deDE"]))
            assert.are.same("table", type(l10n.npcNameLookup["deDE"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/deDE.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["deDE"]))
            assert.are.same("table", type(l10n.objectLookup["deDE"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/deDE.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["deDE"]))
            assert.are.same("table", type(l10n.questLookup["deDE"]()))
        end)
    end)

    describe("esES", function()
        before_each(function()
            _G.GetLocale = function() return "esES" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/esES.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["esES"]))
            assert.are.same("table", type(l10n.itemLookup["esES"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/esES.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["esES"]))
            assert.are.same("table", type(l10n.npcNameLookup["esES"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/esES.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["esES"]))
            assert.are.same("table", type(l10n.objectLookup["esES"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/esES.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["esES"]))
            assert.are.same("table", type(l10n.questLookup["esES"]()))
        end)
    end)

    describe("esMX", function()
        before_each(function()
            _G.GetLocale = function() return "esMX" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/esMX.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["esMX"]))
            assert.are.same("table", type(l10n.itemLookup["esMX"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/esMX.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["esMX"]))
            assert.are.same("table", type(l10n.npcNameLookup["esMX"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/esMX.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["esMX"]))
            assert.are.same("table", type(l10n.objectLookup["esMX"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/esMX.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["esMX"]))
            assert.are.same("table", type(l10n.questLookup["esMX"]()))
        end)
    end)

    describe("frFR", function()
        before_each(function()
            _G.GetLocale = function() return "frFR" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/frFR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["frFR"]))
            assert.are.same("table", type(l10n.itemLookup["frFR"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/frFR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["frFR"]))
            assert.are.same("table", type(l10n.npcNameLookup["frFR"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/frFR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["frFR"]))
            assert.are.same("table", type(l10n.objectLookup["frFR"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/frFR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["frFR"]))
            assert.are.same("table", type(l10n.questLookup["frFR"]()))
        end)
    end)

    describe("koKR", function()
        before_each(function()
            _G.GetLocale = function() return "koKR" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/koKR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["koKR"]))
            assert.are.same("table", type(l10n.itemLookup["koKR"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/koKR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["koKR"]))
            assert.are.same("table", type(l10n.npcNameLookup["koKR"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/koKR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["koKR"]))
            assert.are.same("table", type(l10n.objectLookup["koKR"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/koKR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["koKR"]))
            assert.are.same("table", type(l10n.questLookup["koKR"]()))
        end)
    end)

    describe("ptBR", function()
        before_each(function()
            _G.GetLocale = function() return "ptBR" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/ptBR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["ptBR"]))
            assert.are.same("table", type(l10n.itemLookup["ptBR"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/ptBR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["ptBR"]))
            assert.are.same("table", type(l10n.npcNameLookup["ptBR"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/ptBR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["ptBR"]))
            assert.are.same("table", type(l10n.objectLookup["ptBR"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/ptBR.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["ptBR"]))
            assert.are.same("table", type(l10n.questLookup["ptBR"]()))
        end)
    end)

    describe("ruRU", function()
        before_each(function()
            _G.GetLocale = function() return "ruRU" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/ruRU.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["ruRU"]))
            assert.are.same("table", type(l10n.itemLookup["ruRU"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/ruRU.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["ruRU"]))
            assert.are.same("table", type(l10n.npcNameLookup["ruRU"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/ruRU.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["ruRU"]))
            assert.are.same("table", type(l10n.objectLookup["ruRU"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/ruRU.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["ruRU"]))
            assert.are.same("table", type(l10n.questLookup["ruRU"]()))
        end)
    end)

    describe("zhCN", function()
        before_each(function()
            _G.GetLocale = function() return "zhCN" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/zhCN.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["zhCN"]))
            assert.are.same("table", type(l10n.itemLookup["zhCN"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/zhCN.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["zhCN"]))
            assert.are.same("table", type(l10n.npcNameLookup["zhCN"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/zhCN.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["zhCN"]))
            assert.are.same("table", type(l10n.objectLookup["zhCN"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/zhCN.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["zhCN"]))
            assert.are.same("table", type(l10n.questLookup["zhCN"]()))
        end)
    end)

    describe("zhTW", function()
        before_each(function()
            _G.GetLocale = function() return "zhTW" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Classic/lookupItems/zhTW.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.itemLookup["zhTW"]))
            assert.are.same("table", type(l10n.itemLookup["zhTW"]()))
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Classic/lookupNpcs/zhTW.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.npcNameLookup["zhTW"]))
            assert.are.same("table", type(l10n.npcNameLookup["zhTW"]()))
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Classic/lookupObjects/zhTW.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.objectLookup["zhTW"]))
            assert.are.same("table", type(l10n.objectLookup["zhTW"]()))
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Classic/lookupQuests/zhTW.lua"
            assert(loadfile(currentLookupFile))()
            assert.are.same("function", type(l10n.questLookup["zhTW"]))
            assert.are.same("table", type(l10n.questLookup["zhTW"]()))
        end)
    end)
end)
