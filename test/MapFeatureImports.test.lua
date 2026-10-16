dofile("setupTests.lua")

-- Keeps Questie's drawing features black boxes. A drawing feature is a folder of its own under
-- Modules/Map/; Polygon/ counts too until it moves there. Features never import each other, and core
-- imports a feature only at the entry points below. Everything else goes through QuestieFrame's icon
-- events or the shared seams directly in Modules/Map/, such as WorldMapLayers.

local LoaderUsage = dofile("cli/loaderUsage.lua")

local TOC_PATHS = {
    "Questie_Vanilla.toc", "Questie_TBC.toc", "Questie_Wrath.toc", "Questie_Cata.toc", "Questie_Mists.toc", "Questie_Camelot.toc",
}

-- Core reaches a drawing feature only here, and only through the feature's adapter. One line per core
-- file and adapter; a new one is a reviewed decision.
local ENTRY_POINTS = {
    ["Modules/Map/QuestieMap.lua"] = {
        QuestieWaypoints = "DrawWaypoints registers an icon's patrol paths",
        QuestiePolygon = "UnloadQuestFrames removes a quest's areas",
    },
    ["Modules/Quest/QuestieQuest.lua"] = {QuestiePolygon = "blob mode draws, removes and resets objective areas"},
    ["Modules/Tracker/TrackerUtils.lua"] = {
        QuestieWaypoints = "Show on Map shows only the flashed objective's paths",
        QuestiePolygon = "Show on Map flashes the objective's markers",
    },
    ["Modules/Tracker/LinePool/TrackerLine.lua"] = {QuestiePolygon = "hovering an objective previews its areas"},
    ["Modules/Options/MapTab/QuestieOptionsMap.lua"] = {QuestieWaypoints = "Map > Waypoints settings"},
    ["Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua"] = {QuestieWaypoints = "Show waypoint hover area"},
    ["Modules/Options/IconsTab/QuestieOptionsIcons.lua"] = {QuestiePolygon = "Questie blobs preset and quest area settings"},
    ["Questie.lua"] = {
        QuestieWaypoints = "a profile switch redraws paths",
        QuestiePolygon = "disabling Questie resets areas",
    },
}

---A drawing feature is a folder of its own under Modules/Map/; Polygon/ until it moves there.
---@param path string Addon-relative, forward slashes.
---@return string? feature
local function _FeatureOf(path)
    return path:match("^Modules/Map/([^/]+)/") or (path:match("^Polygon/") and "Polygon") or nil
end

---Every import of a feature's module from another feature, from core outside the entry points, and
---every entry point no longer used. Comments are skipped; colon and dot calls both count.
---@param sources table<string, string> Source text by addon-relative path.
---@param entryPoints table<string, table<string, string>>
---@return string[] violations
local function _Violations(sources, entryPoints)
    local owners, imports = {}, {}
    for path, text in pairs(sources) do
        local lineNumber = 0
        for line in (text .. "\n"):gmatch("(.-)\n") do
            lineNumber = lineNumber + 1
            local code = line:gsub("%-%-.*$", "")
            for name in code:gmatch('CreateModule%s*%(%s*"([%w_]+)"') do owners[name] = _FeatureOf(path) or false end
            for args in code:gmatch("ImportModule%s*(%b())") do
                local name = args:match('"([%w_]+)"%s*%)$')
                if name then imports[#imports + 1] = {path = path, line = lineNumber, module = name} end
            end
        end
    end
    local violations, used = {}, {}
    for _, import in ipairs(imports) do
        local from, to = _FeatureOf(import.path), owners[import.module]
        if to and from ~= to then
            if not from and entryPoints[import.path] and entryPoints[import.path][import.module] then
                used[import.path .. " > " .. import.module] = true
            else
                violations[#violations + 1] = string.format("%s:%d imports %s of %s", import.path, import.line,
                    import.module, to)
            end
        end
    end
    for path, modules in pairs(entryPoints) do
        for module in pairs(modules) do
            if not used[path .. " > " .. module] then
                violations[#violations + 1] = "unused entry point " .. path .. " > " .. module
            end
        end
    end
    table.sort(violations)
    return violations
end

describe("Map feature imports", function()
    it("finds a feature importing another feature, and core importing one outside its entry points", function()
        local sources = {
            ["Polygon/QuestiePolygon.lua"] = 'local QuestiePolygon = QuestieLoader:CreateModule("QuestiePolygon")\n'
                .. 'local WorldMapLayers = QuestieLoader:ImportModule("WorldMapLayers")',
            ["Modules/Map/WorldMapLayers.lua"] = 'local WorldMapLayers = QuestieLoader:CreateModule("WorldMapLayers")',
            ["Modules/Map/Routes/Routes.lua"] = 'local Routes = QuestieLoader:CreateModule("Routes")\n'
                .. 'local QuestiePolygon = QuestieLoader:ImportModule("QuestiePolygon")',
            ["Modules/Quest/QuestieQuest.lua"] = '-- local Routes = QuestieLoader:ImportModule("Routes")\n'
                .. 'local QuestiePolygon = QuestieLoader:ImportModule("QuestiePolygon")',
            ["Modules/Tracker/TrackerUtils.lua"] = 'local QuestiePolygon = QuestieLoader.ImportModule(QuestieLoader, "QuestiePolygon")',
        }
        local entryPoints = {
            ["Modules/Quest/QuestieQuest.lua"] = {QuestiePolygon = "an entry point in use"},
            ["Questie.lua"] = {Routes = "an entry point no longer used"},
        }

        assert.are.same({
            "Modules/Map/Routes/Routes.lua:2 imports QuestiePolygon of Polygon",
            "Modules/Tracker/TrackerUtils.lua:1 imports QuestiePolygon of Polygon",
            "unused entry point Questie.lua > Routes",
        }, _Violations(sources, entryPoints))
    end)

    it("keeps Questie's drawing features apart, reached from core only at their entry points", function()
        local sources = {}
        for _, tocPath in ipairs(TOC_PATHS) do
            for _, path in ipairs(LoaderUsage.ReadTocLuaPaths(tocPath)) do
                -- Blob/ is a local prototype area, not part of Questie.
                if not sources[path] and not path:match("^Blob/") then
                    local file = assert(io.open(path, "r"), tocPath .. " lists a missing file: " .. path)
                    sources[path] = file:read("*a")
                    file:close()
                end
            end
        end

        assert.are.same({}, _Violations(sources, ENTRY_POINTS))
    end)
end)
