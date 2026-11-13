dofile("setupTests.lua")

describe("WorldMapLayers", function()
    ---@type WorldMapLayers
    local WorldMapLayers
    local QuestieCompat
    local saved, savedError
    local poller, cursor, scale, overCanvas, focus, gamepadUI, levelTypes

    -- The level types below the first pins each client draws over its maps, {start, range}, as
    -- Blizzard_WorldMap registers them on the client's flavor.
    local CLIENT_LEVELS = {
        era = {PIN_FRAME_LEVEL_QUEST_BLOB = {2004, 1}, PIN_FRAME_LEVEL_SCENARIO_BLOB = {2005, 1},
            PIN_FRAME_LEVEL_MAP_HIGHLIGHT = {2006, 1}, PIN_FRAME_LEVEL_DEBUG = {2007, 4}, PIN_FRAME_LEVEL_DIG_SITE = {2011, 1}},
        forever = {PIN_FRAME_LEVEL_QUEST_BLOB = {2007, 1}, PIN_FRAME_LEVEL_SCENARIO_BLOB = {2008, 1},
            PIN_FRAME_LEVEL_MAP_HIGHLIGHT = {2009, 1}, PIN_FRAME_LEVEL_DEBUG = {2010, 4}, PIN_FRAME_LEVEL_DIG_SITE = {2014, 1}},
        wrath = {PIN_FRAME_LEVEL_QUEST_BLOB = {2002, 1}, PIN_FRAME_LEVEL_MAP_HIGHLIGHT = {2003, 1},
            PIN_FRAME_LEVEL_DEBUG = {2004, 4}, PIN_FRAME_LEVEL_GOSSIP = {2008, 1}},
        mists = {PIN_FRAME_LEVEL_QUEST_BLOB = {2002, 1}, PIN_FRAME_LEVEL_SCENARIO_BLOB = {2003, 1},
            PIN_FRAME_LEVEL_MAP_HIGHLIGHT = {2004, 1}, PIN_FRAME_LEVEL_DEBUG = {2005, 4}, PIN_FRAME_LEVEL_DIG_SITE = {2009, 1}},
    }

    ---Blizzard's level manager: a level type the client lacks answers PIN_FRAME_LEVEL_DEFAULT's level.
    -- It offers no way to add a level type: Questie only reads them.
    local function LevelsManager()
        local function Definition(name) return levelTypes[name] or {2000, 1} end
        return {
            GetValidFrameLevel = function(_, name, index)
                local start, range = unpack(Definition(name))
                return start + math.min(math.max(index or 1, 1), range) - 1
            end,
            GetFrameLevelStart = function(_, name) return Definition(name)[1] end,
            GetFrameLevelRange = function(_, name) return Definition(name)[2] end,
        }
    end

    -- A layer recording what it was offered; it claims the cursor while claims is true.
    local function Layer(claims)
        local layer = {calls = {}, claims = claims or false}
        layer.Hover = function(offered)
            layer.calls[#layer.calls + 1] = offered or false
            return offered ~= nil and layer.claims
        end
        return layer
    end

    local function Poll()
        poller.scripts.OnUpdate()
    end

    before_each(function()
        saved = {WorldMapFrame = _G.WorldMapFrame, CreateFrame = _G.CreateFrame, issecretvalue = _G.issecretvalue}
        cursor, scale, overCanvas, gamepadUI, levelTypes = {0.5, 0.25}, 1, true, false, CLIENT_LEVELS.era
        local canvas = {GetWidth = function() return 1000 end, GetHeight = function() return 500 end,
            IsMouseOver = function() return overCanvas end}
        local scrollContainer = {
            GetCanvasScale = function() return scale end,
            GetNormalizedCursorPosition = function() return cursor[1], cursor[2] end,
        }
        _G.WorldMapFrame = {
            GetMapID = function() return 1 end,
            GetCanvas = function() return canvas end,
            ScrollContainer = scrollContainer,
            GetPinFrameLevelsManager = LevelsManager,
        }
        _G.CreateFrame = function()
            poller = {scripts = {}}
            function poller:SetScript(name, script) self.scripts[name] = script end
            return poller
        end
        _G.issecretvalue = nil
        focus = scrollContainer
        savedError = Questie.Error
        Questie.Error = spy.new(function() end)

        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.GetMouseFocus = function() return focus end
        QuestieCompat.IsGamepadUIEnabled = function() return gamepadUI end

        dofile("Modules/Map/WorldMapLayers.lua")
        WorldMapLayers = QuestieLoader:ImportModule("WorldMapLayers")
    end)

    after_each(function()
        for name, value in pairs(saved) do _G[name] = value end
        Questie.Error = savedError
    end)

    it("offers the cursor top down in canvas units, and gives a layer beneath a claim nil once", function()
        local areas, paths = Layer(true), Layer(false)
        WorldMapLayers.AddLayer("areas", areas)
        WorldMapLayers.AddLayer("paths", paths)

        Poll()
        assert.are.same({{mapId = 1, x = 500, y = 125, width = 1000, height = 500, scale = 1}}, paths.calls)
        assert.are.equal(1, #areas.calls)

        -- The paths claim the cursor: the areas beneath get nil once, then nothing while the paths keep it.
        paths.claims = true
        cursor = {0.6, 0.25}
        Poll()
        cursor = {0.7, 0.25}
        Poll()
        assert.are.same({false}, {areas.calls[2]})
        assert.are.equal(2, #areas.calls)
        assert.are.equal(3, #paths.calls)

        -- Off the paths, the areas get the cursor back.
        paths.claims = false
        cursor = {0.8, 0.25}
        Poll()
        assert.are.equal(800, areas.calls[3].x)
    end)

    it("offers it again only when the cursor moved, the zoom changed, or a layer drew anew", function()
        local paths = Layer(true)
        WorldMapLayers.AddLayer("paths", paths)
        Poll()
        Poll()
        assert.are.equal(1, #paths.calls)

        scale = 2
        Poll()
        assert.are.equal(2, #paths.calls)
        assert.are.equal(2, paths.calls[2].scale)

        WorldMapLayers.Invalidate("paths")
        Poll()
        Poll()
        assert.are.equal(3, #paths.calls)
    end)

    it("hovers nothing drawn while anything covers the map, off the canvas, or in the gamepad UI", function()
        local paths = Layer(true)
        WorldMapLayers.AddLayer("paths", paths)
        -- Each rule ends a hover the layer had, so it gets nil once.
        local function OverBareMap(x)
            focus, overCanvas, gamepadUI, cursor = WorldMapFrame.ScrollContainer, true, false, {x, 0.25}
            Poll()
        end

        OverBareMap(0.5)
        -- Questie's icons, Blizzard's pins and other UI on top win over every layer.
        focus, cursor = {}, {0.55, 0.25}
        Poll()
        OverBareMap(0.6)
        overCanvas, cursor = false, {0.65, 0.25}
        Poll()
        OverBareMap(0.7)
        gamepadUI, cursor = true, {0.75, 0.25}
        Poll()

        local offered = {}
        for i, call in ipairs(paths.calls) do offered[i] = call and call.x end
        assert.are.same({500, false, 600, false, 700, false}, offered)
    end)

    it("ignores a cursor position the client marks secret", function()
        local paths = Layer(true)
        WorldMapLayers.AddLayer("paths", paths)
        _G.issecretvalue = function(value) return value == 0.6 end
        cursor = {0.6, 0.25}

        Poll()
        Poll()

        assert.are.same({}, paths.calls)
    end)

    it("hovers nothing where a canvas not laid out yet places the cursor at NaN or infinity", function()
        local paths = Layer(true)
        WorldMapLayers.AddLayer("paths", paths)
        Poll()

        cursor = {0 / 0, 0.25}
        Poll()
        cursor = {0.6, 0.25}
        Poll()
        cursor = {0.6, math.huge}
        Poll()

        assert.are.same({false, 600, false}, {paths.calls[2], paths.calls[3].x, paths.calls[4]})
    end)

    it("ends every hover when the map closes, and offers the cursor again when it reopens", function()
        local areas, paths = Layer(true), Layer(false)
        WorldMapLayers.AddLayer("areas", areas)
        WorldMapLayers.AddLayer("paths", paths)
        Poll()

        poller.scripts.OnHide()
        assert.is_false(areas.calls[2])
        assert.is_false(paths.calls[2])

        poller.scripts.OnShow()
        Poll()
        assert.are.equal(500, areas.calls[3].x)
    end)

    it("reports a failing layer, ends its hover and skips it until it is invalidated", function()
        local areas = Layer(true)
        local failing = true
        local paths = {calls = {}}
        paths.Hover = function(offered)
            paths.calls[#paths.calls + 1] = offered or false
            if offered and failing then error("broken") end
            return false
        end
        WorldMapLayers.AddLayer("areas", areas)
        WorldMapLayers.AddLayer("paths", paths)

        Poll()
        assert.spy(Questie.Error).was.called(1)
        -- Its hover ended, and the layer beneath still hovers.
        assert.is_false(paths.calls[2])
        assert.are.equal(500, areas.calls[1].x)

        cursor = {0.6, 0.25}
        Poll()
        assert.are.equal(2, #paths.calls)

        -- Drawing anew tries it again; failing again on every redraw is reported only the first time.
        WorldMapLayers.Invalidate("paths")
        Poll()
        assert.are.equal(4, #paths.calls)
        assert.spy(Questie.Error).was.called(1)

        failing = false
        WorldMapLayers.Invalidate("paths")
        Poll()
        assert.are.equal(600, paths.calls[5].x)
        assert.spy(Questie.Error).was.called(1)
    end)

    it("stops polling after an error, ending every hover, until the map opens again", function()
        local paths = Layer(true)
        WorldMapLayers.AddLayer("paths", paths)
        Poll()
        local canvas = WorldMapFrame:GetCanvas()
        local isMouseOver = canvas.IsMouseOver
        canvas.IsMouseOver = function() error("broken canvas") end

        Poll()
        assert.spy(Questie.Error).was.called(1)
        assert.is_false(paths.calls[2])
        assert.is_nil(poller.scripts.OnUpdate)

        canvas.IsMouseOver = isMouseOver
        poller.scripts.OnShow()
        Poll()
        assert.are.equal(500, paths.calls[3].x)
    end)

    it("draws each layer above the ones beneath it, on every client's levels", function()
        for _, client in ipairs({"era", "forever", "wrath", "mists"}) do
            levelTypes = CLIENT_LEVELS[client]
            local _, areasLast = WorldMapLayers.FrameLevels("areas")
            local pathsFirst, pathsLast = WorldMapLayers.FrameLevels("paths")
            assert.is_true(areasLast < pathsFirst, client)
            -- Questie's icons start at 2016.
            assert.is_true(pathsLast < 2016, client)
        end
        assert.has_error(function() WorldMapLayers.FrameLevels("nope") end)
        assert.has_error(function() WorldMapLayers.Invalidate("nope") end)
    end)

    it("stacks areas from Blizzard's quest area level to the end of its debug pins' levels, reading them only", function()
        local expected = {era = {2004, 2010}, forever = {2007, 2013}, wrath = {2002, 2007}, mists = {2002, 2008}}
        for client, range in pairs(expected) do
            levelTypes = CLIENT_LEVELS[client]
            assert.are.same(range, {WorldMapLayers.FrameLevels("areas")}, client)
        end

        -- Without debug levels, areas keep the quest area level alone.
        levelTypes = {PIN_FRAME_LEVEL_QUEST_BLOB = {2004, 1}}
        assert.are.same({2004, 2004}, {WorldMapLayers.FrameLevels("areas")})

        -- Levels another addon moved up never reach the paths.
        levelTypes = {PIN_FRAME_LEVEL_QUEST_BLOB = {2012, 1}, PIN_FRAME_LEVEL_DEBUG = {2015, 4}}
        assert.are.same({2012, 2014}, {WorldMapLayers.FrameLevels("areas")})
    end)
end)
