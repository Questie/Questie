describe("Cata localization lookup loadstrings", function()
    local l10n
    local originalGetLocale
    local originalQuestieLoader
    local currentLookupFile
    local originalLoadstring

    local pairs = pairs
    local type = type
    local tostring = tostring
    local error = error

    local function _LoadRegisteredLookup(lookupTable, locale, filePath)
        -- Lookup files register one locale-specific function; load its generated table before schema validation.
        assert.are.same("function", type(lookupTable[locale]), filePath .. " did not register lookup for " .. locale)

        local lookup = lookupTable[locale]()
        assert.are.same("table", type(lookup), filePath .. " lookup for " .. locale .. " did not return a table")

        return lookup
    end

    local function _AssertItemLookupShape(lookup, filePath)
        -- Item lookups map numeric item IDs to localized item names.
        for id, name in pairs(lookup) do
            if type(id) ~= "number" then
                error(filePath .. " has a non-number lookup key: " .. tostring(id), 0)
            end
            if type(name) ~= "string" then
                error(filePath .. " has invalid item name type for ID " .. tostring(id) .. ": " .. type(name), 0)
            end
        end
    end

    local function _AssertNpcLookupShape(lookup, filePath)
        -- NPC lookups map numeric NPC IDs to {name?, subName?}; {nil, nil} collapses to an empty table.
        for id, data in pairs(lookup) do
            if type(id) ~= "number" then
                error(filePath .. " has a non-number lookup key: " .. tostring(id), 0)
            end
            if type(data) ~= "table" then
                error(filePath .. " has invalid NPC value type for ID " .. tostring(id) .. ": " .. type(data), 0)
            end
            -- Only fields 1 and 2 are valid: localized name and optional subname.
            for field in pairs(data) do
                if field ~= 1 and field ~= 2 then
                    error(filePath .. " has invalid NPC field " .. tostring(field) .. " for ID " .. tostring(id), 0)
                end
            end
            if data[1] ~= nil and type(data[1]) ~= "string" then
                error(filePath .. " has invalid NPC name value type: " .. type(data[1]), 0)
            end
            if data[2] ~= nil and type(data[2]) ~= "string" then
                error(filePath .. " has invalid NPC subname value type: " .. type(data[2]), 0)
            end
        end
    end

    local function _AssertObjectLookupShape(lookup, filePath)
        -- Object lookups map numeric object IDs to localized object names.
        for id, name in pairs(lookup) do
            if type(id) ~= "number" then
                error(filePath .. " has a non-number lookup key: " .. tostring(id), 0)
            end
            if type(name) ~= "string" then
                error(filePath .. " has invalid object name type for ID " .. tostring(id) .. ": " .. type(name), 0)
            end
        end
    end

    local function _AssertQuestLookupShape(lookup, filePath)
        -- Quest lookups map numeric quest IDs to {title?, descriptionLines?, objectiveLines?}.
        for id, data in pairs(lookup) do
            if type(id) ~= "number" then
                error(filePath .. " has a non-number lookup key: " .. tostring(id), 0)
            end
            if type(data) ~= "table" then
                error(filePath .. " has invalid quest value type for ID " .. tostring(id) .. ": " .. type(data), 0)
            end
            -- Only fields 1, 2, and 3 are valid: title, description lines, and objective lines.
            for field in pairs(data) do
                if field ~= 1 and field ~= 2 and field ~= 3 then
                    error(filePath .. " has invalid quest field " .. tostring(field) .. " for ID " .. tostring(id), 0)
                end
            end
            if data[1] ~= nil and type(data[1]) ~= "string" then
                error(filePath .. " has invalid quest name value type: " .. type(data[1]), 0)
            end
            -- Objective lines must be a numeric-indexed string array when present.
            if data[2] ~= nil then
                if type(data[2]) ~= "table" then
                    error(filePath .. " has invalid quest description value type for ID " .. tostring(id) .. ": " .. type(data[2]), 0)
                end
                for index, line in pairs(data[2]) do
                    if type(index) ~= "number" then
                        error(filePath .. " has a non-number quest description line key for ID " .. tostring(id) .. ": " .. tostring(index), 0)
                    end
                    if type(line) ~= "string" then
                        error(filePath .. " has invalid quest description line type for ID " .. tostring(id) .. ": " .. type(line), 0)
                    end
                end
            end
            -- -- Description lines must be a numeric-indexed string array when present.
            -- [...] Cheeq removed Description lines from l10n, this is the "old" full structure
            -- -- Objective lines must be a numeric-indexed string array when present.
            -- if data[3] ~= nil then
            --     if type(data[3]) ~= "table" then
            --         error(filePath .. " has invalid quest objective value type for ID " .. tostring(id) .. ": " .. type(data[3]), 0)
            --     end
            --     for index, line in pairs(data[3]) do
            --         if type(index) ~= "number" then
            --             error(filePath .. " has a non-number quest objective line key for ID " .. tostring(id) .. ": " .. tostring(index), 0)
            --         end
            --         if type(line) ~= "string" then
            --             error(filePath .. " has invalid quest objective line type for ID " .. tostring(id) .. ": " .. type(line), 0)
            --         end
            --     end
            -- end
        end
    end

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
            currentLookupFile = "Localization/lookups/Cata/lookupItems/deDE.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "deDE", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/deDE.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "deDE", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/deDE.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "deDE", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/deDE.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "deDE", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)

    describe("esES", function()
        before_each(function()
            _G.GetLocale = function() return "esES" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Cata/lookupItems/esES.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "esES", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/esES.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "esES", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/esES.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "esES", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/esES.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "esES", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)

    describe("esMX", function()
        before_each(function()
            _G.GetLocale = function() return "esMX" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Cata/lookupItems/esMX.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "esMX", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/esMX.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "esMX", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/esMX.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "esMX", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/esMX.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "esMX", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)

    describe("frFR", function()
        before_each(function()
            _G.GetLocale = function() return "frFR" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Cata/lookupItems/frFR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "frFR", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/frFR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "frFR", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/frFR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "frFR", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/frFR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "frFR", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)

    describe("koKR", function()
        before_each(function()
            _G.GetLocale = function() return "koKR" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Cata/lookupItems/koKR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "koKR", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/koKR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "koKR", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/koKR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "koKR", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/koKR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "koKR", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)

    describe("ptBR", function()
        before_each(function()
            _G.GetLocale = function() return "ptBR" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Cata/lookupItems/ptBR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "ptBR", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/ptBR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "ptBR", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/ptBR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "ptBR", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/ptBR.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "ptBR", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)

    describe("ruRU", function()
        before_each(function()
            _G.GetLocale = function() return "ruRU" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Cata/lookupItems/ruRU.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "ruRU", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/ruRU.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "ruRU", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/ruRU.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "ruRU", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/ruRU.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "ruRU", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)

    describe("zhCN", function()
        before_each(function()
            _G.GetLocale = function() return "zhCN" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Cata/lookupItems/zhCN.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "zhCN", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/zhCN.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "zhCN", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/zhCN.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "zhCN", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/zhCN.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "zhCN", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)

    describe("zhTW", function()
        before_each(function()
            _G.GetLocale = function() return "zhTW" end
        end)

        it("validates lookupItems", function()
            currentLookupFile = "Localization/lookups/Cata/lookupItems/zhTW.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.itemLookup, "zhTW", currentLookupFile)
            _AssertItemLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupNpcs", function()
            currentLookupFile = "Localization/lookups/Cata/lookupNpcs/zhTW.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.npcNameLookup, "zhTW", currentLookupFile)
            _AssertNpcLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupObjects", function()
            currentLookupFile = "Localization/lookups/Cata/lookupObjects/zhTW.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.objectLookup, "zhTW", currentLookupFile)
            _AssertObjectLookupShape(lookup, currentLookupFile)
        end)

        it("validates lookupQuests", function()
            currentLookupFile = "Localization/lookups/Cata/lookupQuests/zhTW.lua"
            assert(loadfile(currentLookupFile))()
            local lookup = _LoadRegisteredLookup(l10n.questLookup, "zhTW", currentLookupFile)
            _AssertQuestLookupShape(lookup, currentLookupFile)
        end)
    end)
end)
