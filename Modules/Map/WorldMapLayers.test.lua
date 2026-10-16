dofile("setupTests.lua")

describe("WorldMapLayers", function()
    ---@type WorldMapLayers
    local WorldMapLayers
    local QuestieCompat
    local saved, savedError
    local poller, cursor, scale, overCanvas, focus, gamepadUI, blobLevel

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
        cursor, scale, overCanvas, gamepadUI, blobLevel = {0.5, 0.25}, 1, true, false, 2004
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
            GetPinFrameLevelsManager = function()
                return {GetValidFrameLevel = function(_, name)
                    assert.are.equal("PIN_FRAME_LEVEL_QUEST_BLOB", name)
                    return blobLevel
                end}
            end,
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
        Poll()

        -- Questie's icons, Blizzard's pins and other UI on top win over every layer.
        focus = {}
        cursor = {0.6, 0.25}
        Poll()
        assert.is_false(paths.calls[2])

        focus = WorldMapFrame.ScrollContainer
        overCanvas = false
        Poll()
        overCanvas = true
        gamepadUI = true
        cursor = {0.7, 0.25}
        Poll()
        -- The nil came once: the layer no longer had the cursor after the first.
        assert.are.equal(2, #paths.calls)
    end)

    it("ignores a secret cursor position without comparing it", function()
        local paths = Layer(true)
        WorldMapLayers.AddLayer("paths", paths)
        local secret = setmetatable({}, {__eq = function() error("compared a secret value") end})
        _G.issecretvalue = function(value) return value == nil and false or rawequal(value, secret) end
        cursor = {secret, secret}

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

        failing = false
        WorldMapLayers.Invalidate("paths")
        Poll()
        assert.are.equal(600, paths.calls[3].x)
        assert.spy(Questie.Error).was.called(1)
    end)

    it("draws each layer above the ones beneath it, on every client's quest area level", function()
        for _, level in ipairs({2004, 2007}) do
            blobLevel = level
            assert.is_true(WorldMapLayers.FrameLevel("areas") < WorldMapLayers.FrameLevel("paths"))
            -- Questie's icons start at 2016.
            assert.is_true(WorldMapLayers.FrameLevel("paths") < 2016)
        end
        assert.has_error(function() WorldMapLayers.FrameLevel("nope") end)
    end)
end)
