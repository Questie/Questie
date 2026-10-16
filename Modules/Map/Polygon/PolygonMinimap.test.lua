dofile("setupTests.lua")

describe("PolygonMinimap", function()
    local PolygonMinimap, Pins, savedGlobals, savedError, hooks, lineDraws, player, minimap, cluster, rotateCVar, atlases
    local root, renderer, cursor, focus, QuestieCompat, savedCompat
    local GLOBALS = {"CreateFrame", "DrawLine", "LibStub", "hooksecurefunc", "Minimap", "GetPlayerFacing", "GetMinimapShape",
        "C_Texture", "C_Minimap", "issecretvalue", "GetCVar", "WorldMapFrame", "CreateFramePool", "CreateFromMixins", "GetCursorPosition",
        "CreateUnsecuredRegionPoolInstance", "MapCanvasDataProviderMixin", "MapCanvasPinMixin",
        "UPPER_LEFT_VERTEX", "UPPER_RIGHT_VERTEX", "LOWER_LEFT_VERTEX", "LOWER_RIGHT_VERTEX"}
    -- Map 10 is not drawn at the canvas's 3:2 shape, so each axis needs its own scale.
    local MAPS = {[10] = {width = 3000, height = 1800, left = 5000, top = 4000}}

    local function Region()
        local region = {shown = true}
        function region:SetParent(parent) self.parent = parent end
        function region:SetAllPoints(target) self.allPoints = target end
        function region:SetPoint(...) self.anchor = {...} end
        function region:ClearAllPoints() self.anchor, self.allPoints = nil, nil end
        function region:SetSize(width, height) self.width, self.height = width, height end
        -- Like the client, showing or hiding a frame runs its script on a change.
        function region:Show()
            if not self.shown and self.scripts and self.scripts.OnShow then self.shown = true; self.scripts.OnShow(self) end
            self.shown = true
        end
        function region:Hide()
            if self.shown and self.scripts and self.scripts.OnHide then self.shown = false; self.scripts.OnHide(self) end
            self.shown = false
        end
        function region:IsShown() return self.shown end
        function region:SetTexture(asset, ...) self.texture, self.atlas, self.wrap = asset, nil, {...} end
        function region:SetAtlas(asset, ...) self.atlas, self.texture, self.wrap = asset, nil, {select(4, ...)} end
        return region
    end

    local function Frame(_kind, _name, parent)
        local frame = Region()
        frame.parent, frame.level = parent, (parent and parent.level or 0) + 1
        -- The canvas's root is the first frame created on the minimap.
        if parent ~= nil and parent == minimap and not root then root = frame end
        function frame:SetScript(name, handler)
            self.scripts = self.scripts or {}
            self.scripts[name] = handler
        end
        frame.RegisterEvent, frame.UnregisterAllEvents = function() end, function() end
        function frame:SetClipsChildren(clips) self.clips = clips end
        function frame:GetFrameLevel() return self.level end
        function frame:SetFrameLevel(level) self.level = level end
        function frame:CreateMaskTexture() return Region() end
        function frame:CreateTexture()
            local texture = Region()
            texture.SetSnapToPixelGrid, texture.SetTexelSnappingBias = function() end, function() end
            texture.SetVertexOffset, texture.SetTexCoord = function() end, function() end
            function texture:SetVertexColor(...) self.color = {...} end
            function texture:AddMaskTexture(mask)
                self.masks = self.masks or {}
                self.masks[#self.masks + 1] = mask
            end
            return texture
        end
        return frame
    end

    -- HereBeDragons' own zone-to-world conversion: each axis has its own extent in yards.
    local function World(uiMapId, x, y)
        local map = MAPS[uiMapId]
        return map.left - map.width * x / 100, map.top - map.height * y / 100
    end

    -- One frame for HereBeDragons-Pins' minimap icons, then one for the canvas.
    local function Tick()
        Pins.updateFrame.scripts.OnUpdate(Pins.updateFrame, 2)
        root.scripts.OnUpdate(root)
    end

    local function Area(outline, color)
        return {key = {}, cluster = {uiMapId = 10, instanceId = 0, outline = outline or cluster.outline},
            color = color or {1, 0, 0}, alpha = 1}
    end

    ---Starts the areas layer on the canvas with the areas collect returns, as QuestiePolygon does.
    local function Start(collect, onHover)
        local layer = PolygonMinimap.New(collect, onHover or function() end)
        layer.Invalidate()
        return layer
    end

    ---Each border starts at its outline vertex. Its position is the container's offset from the
    ---minimap center, plus the polygon frame's offset in the container, plus the vertex in the
    ---frame. HereBeDragons places a minimap icon on each vertex for comparison.
    local function AssertOutlineOnIcons(frame, outline)
        local container = renderer.canvas.anchor
        assert.are.same({"TOPLEFT", minimap, "CENTER"}, {container[1], container[2], container[3]})
        assert.are.equal(renderer.canvas, frame.anchor[2])
        for i, point in ipairs(outline) do
            local line = frame.borders[i].line
            local icon = Region()
            Pins:AddMinimapIconWorld("test", icon, 0, World(10, point.x, point.y))
            Pins.updateFrame.scripts.OnUpdate(Pins.updateFrame, 2)
            assert.is_true(icon.shown, "vertex " .. i .. " must be inside the minimap for a placed icon")
            assert.are.same({"CENTER", minimap, "CENTER"}, {icon.anchor[1], icon.anchor[2], icon.anchor[3]})
            assert.are_near(icon.anchor[4], container[4] + frame.anchor[4] + line[2], 1e-9)
            assert.are_near(icon.anchor[5], container[5] + frame.anchor[5] + line[3], 1e-9)
            Pins:RemoveMinimapIcon("test", icon)
        end
    end

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(GLOBALS) do savedGlobals[name] = _G[name] end
        savedError = Questie.Error
        hooks, lineDraws, atlases, root = {}, 0, {}, nil
        player = {instance = 0, facing = 0.3, zone = 10}
        player.x, player.y = World(10, 41, 42)
        rotateCVar = "1"
        minimap = Frame()
        minimap.zoom, minimap.size = 0, {140, 120}
        function minimap:GetZoom() return self.zoom end
        function minimap:GetWidth() return self.size[1] end
        function minimap:GetHeight() return self.size[2] end
        minimap.GetScale, minimap.IsVisible = function() return 1 end, function() return true end
        -- The cursor: nowhere until a case places it.
        cursor, focus = nil, nil
        function minimap:GetCenter() return 500, 500 end
        function minimap:GetEffectiveScale() return 1 end
        function minimap:IsMouseOver() return cursor ~= nil end
        _G.GetCursorPosition = function() return cursor[1], cursor[2] end
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        savedCompat = {GetMouseFocus = QuestieCompat.GetMouseFocus, IsGamepadUIEnabled = QuestieCompat.IsGamepadUIEnabled}
        QuestieCompat.GetMouseFocus = function() return focus end
        QuestieCompat.IsGamepadUIEnabled = function() return false end
        cluster = {outline = {{x = 40, y = 40}, {x = 44, y = 40}, {x = 42, y = 44}}}

        local HBD = {
            GetWorldCoordinatesFromZone = function(_, x, y, uiMapId)
                if MAPS[uiMapId] then return World(uiMapId, x * 100, y * 100) end
            end,
            GetPlayerWorldPosition = function() return player.x, player.y, player.instance end,
            GetPlayerZone = function() return player.zone end,
            RegisterCallback = function() end,
        }
        -- The real HereBeDragons-Pins: its minimap icons are the alignment reference, and its
        -- GetMinimapView supplies the layer's radius from the zoom table.
        Pins = {}
        _G.LibStub = setmetatable({NewLibrary = function() return Pins end},
            {__call = function(_, name) return name:find("Pins") and Pins or HBD end})
        _G.CreateFrame = Frame
        _G.CreateFramePool = function() return {} end
        _G.CreateUnsecuredRegionPoolInstance = nil
        _G.CreateFromMixins = function(base)
            local result = {}
            for key, value in pairs(base) do result[key] = value end
            return result
        end
        _G.MapCanvasDataProviderMixin, _G.MapCanvasPinMixin = {}, {}
        _G.WorldMapFrame = {pinPools = {}, GetCanvas = function() return {} end, AddDataProvider = function() end,
            IsShown = function() return false end}
        _G.GetCVar = function(name) return name == "rotateMinimap" and rotateCVar or "0" end
        _G.C_Minimap = nil
        _G.DrawLine = function(texture, parent, startX, startY, endX, endY, thickness)
            lineDraws = lineDraws + 1
            texture.line = {parent, startX, startY, endX, endY, thickness}
        end
        _G.hooksecurefunc = function(object, method, hook) hooks[#hooks + 1] = {object, method, hook} end
        _G.Minimap = minimap
        _G.GetPlayerFacing = function() return player.facing end
        _G.GetMinimapShape = nil
        _G.C_Texture = {GetAtlasInfo = function(atlas) return atlases[atlas] end}
        _G.issecretvalue = nil
        _G.UPPER_LEFT_VERTEX, _G.UPPER_RIGHT_VERTEX, _G.LOWER_LEFT_VERTEX, _G.LOWER_RIGHT_VERTEX = 1, 2, 3, 4
        dofile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")
        dofile("Modules/Map/Polygon/PolygonRenderer.lua")
        -- The areas layer's renderer, to read the frames it drew.
        local PolygonRenderer = QuestieLoader:ImportModule("PolygonRenderer")
        local newRenderer = PolygonRenderer.New
        PolygonRenderer.New = function(...)
            renderer = newRenderer(...)
            return renderer
        end
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Map/MinimapCanvas.lua")
        dofile("Modules/Map/Polygon/PolygonMinimap.lua")
        PolygonMinimap = QuestieLoader:ImportModule("PolygonMinimap")
    end)

    after_each(function()
        -- The explicit list also restores globals that started out nil.
        for _, name in ipairs(GLOBALS) do _G[name] = savedGlobals[name] end
        Questie.Error = savedError
        QuestieCompat.GetMouseFocus, QuestieCompat.IsGamepadUIEnabled = savedCompat.GetMouseFocus, savedCompat.IsGamepadUIEnabled
    end)

    ---Places the cursor over the bare minimap where HereBeDragons places a minimap icon for a world point.
    local function CursorAt(x, y)
        local icon = Region()
        Pins:AddMinimapIconWorld("cursor", icon, 0, x, y)
        Pins.updateFrame.scripts.OnUpdate(Pins.updateFrame, 2)
        Pins:RemoveMinimapIcon("cursor", icon)
        cursor, focus = {500 + icon.anchor[4], 500 + icon.anchor[5]}, minimap
    end

    it("draws outlines exactly where HereBeDragons places minimap icons, walking on a rotating minimap", function()
        local area = Area()
        Start(function() return {area} end)
        Tick()
        local frame = renderer.activeFrames[1]
        assert.is_true(frame:IsShown())
        AssertOutlineOnIcons(frame, cluster.outline)

        -- Walking only moves the container; the outline keeps its projection.
        local draws = lineDraws
        player.x, player.y = World(10, 43, 41)
        Tick()
        assert.are.equal(draws, lineDraws)
        AssertOutlineOnIcons(frame, cluster.outline)
    end)

    it("highlights a previewed area's border and restores it, keeping the outline in place", function()
        local area = Area()
        local areas = {area}
        local layer = Start(function() return areas end)
        Tick()
        local frame = renderer.activeFrames[1]
        assert.are.equal(1.5, frame.borders[1].line[6])

        areas = {{key = area.key, cluster = area.cluster, color = area.color, alpha = 1, highlighted = true}}
        layer.Invalidate()
        Tick()
        assert.are.equal(frame, renderer.activeFrames[1])
        assert.are.equal(1.8, frame.borders[1].line[6])
        AssertOutlineOnIcons(frame, cluster.outline)

        areas[1].highlighted = false
        layer.Invalidate()
        Tick()
        assert.are.equal(1.5, frame.borders[1].line[6])
    end)

    it("keeps a large area whose center is out of view while its edge reaches the minimap", function()
        -- About 930 yards wide; its center is some 480 yards west of the player, past 1.5 view radii.
        local area = Area({{x = 10, y = 30}, {x = 41, y = 30}, {x = 41, y = 50}, {x = 10, y = 50}})
        player.x, player.y = World(10, 41.5, 42)
        Start(function() return {area} end)
        Tick()
        assert.is_true(renderer.activeFrames[1]:IsShown())
    end)

    it("skips areas on another instance, without world data, or out of reach", function()
        local near = Area()
        local otherInstance = Area()
        otherInstance.cluster = {uiMapId = 10, instanceId = 1, outline = cluster.outline}
        local noWorld = {key = {}, cluster = {uiMapId = 99, instanceId = 0, outline = cluster.outline},
            color = {0, 1, 0}, alpha = 1}
        -- Far east of the player, beyond 2 view radii of the 233-yard zoom.
        local far = Area({{x = 1, y = 40}, {x = 2, y = 40}, {x = 1, y = 41}})
        Start(function() return {near, otherInstance, noWorld, far} end)
        Tick()

        assert.are.equal(1, #renderer.activeFrames)
        AssertOutlineOnIcons(renderer.activeFrames[1], cluster.outline)
    end)

    it("releases only areas no longer collected, and restyles a changed fade without reprojecting", function()
        local kept, removed = Area(), Area({{x = 41, y = 41}, {x = 42, y = 41}, {x = 41, y = 42}}, {0, 0, 1})
        local areas = {kept, removed}
        local layer = Start(function() return areas end)
        Tick()
        local keptFrame, removedFrame = renderer.activeFrames[1], renderer.activeFrames[2]

        local draws = lineDraws
        areas = {{key = kept.key, cluster = kept.cluster, color = kept.color, alpha = 0.4}}
        layer.Invalidate()
        Tick()
        assert.is_false(removedFrame:IsShown())
        assert.is_nil(renderer.ownedFrames[removedFrame])
        assert.are.same({keptFrame}, renderer.activeFrames)
        assert.is_true(keptFrame:IsShown())
        assert.are.equal(draws, lineDraws)
        assert.are_near(0.25 * 0.4, keptFrame.fills[1].color[4], 1e-9)
    end)

    it("finds the drawn areas at a spot in world yards, such as a minimap icon's", function()
        local area, other = Area(), Area({{x = 41, y = 41}, {x = 42, y = 41}, {x = 41, y = 42}})
        local layer = Start(function() return {area, other} end)
        local x, y = World(10, 43, 41)
        assert.are.same({}, layer.AreasAt(x, y, 0)) -- Nothing drawn yet.
        Tick()

        local found = layer.AreasAt(x, y, 0)
        assert.are.equal(1, #found)
        assert.are.equal(area.key, found[1])
        -- Overlapping areas both count; another instance has none.
        x, y = World(10, 41.2, 41.2)
        assert.are.equal(2, #layer.AreasAt(x, y, 0))
        assert.are.same({}, layer.AreasAt(x, y, 1))
        -- On a rotating minimap after a turn too, since the outlines and the spot share the projection.
        player.facing = 2
        Tick()
        assert.are.equal(2, #layer.AreasAt(x, y, 0))
        layer.Clear()
        assert.are.same({}, layer.AreasAt(x, y, 0))
    end)

    it("hovers the drawn areas under the cursor, highlighting them, with their keys and the cursor in world yards", function()
        local heard = {}
        local area, other = Area(), Area({{x = 41, y = 41}, {x = 42, y = 41}, {x = 41, y = 42}})
        Start(function() return {area, other} end, function(keys, x, y) heard[#heard + 1] = {keys = keys, x = x, y = y} end)
        Tick()
        local x, y = World(10, 43, 41)
        CursorAt(x, y)
        Tick()

        local last = heard[#heard]
        assert.are.equal(1, #last.keys)
        assert.are.equal(area.key, last.keys[1])
        assert.are_near(x, last.x, 1e-6)
        assert.are_near(y, last.y, 1e-6)
        local frame = renderer.activeFrames[1]
        assert.are.equal(1.8, frame.borders[1].line[6])

        -- Overlapping areas both hover.
        CursorAt(World(10, 41.2, 41.2))
        Tick()
        assert.are.equal(2, #heard[#heard].keys)

        -- Off the minimap, the hover ends.
        cursor = nil
        Tick()
        assert.are.same({}, heard[#heard].keys)
        assert.is_nil(heard[#heard].x)
        assert.are.equal(1.5, frame.borders[1].line[6])
    end)

    it("clears its drawings, and lets the canvas idle once nothing is collected again", function()
        local areas = {Area()}
        local layer = Start(function() return areas end)
        Tick()
        local frame = renderer.activeFrames[1]

        areas = {}
        layer.Clear()
        assert.is_nil(renderer.ownedFrames[frame])
        Tick()
        assert.is_false(root:IsShown())
    end)
end)
