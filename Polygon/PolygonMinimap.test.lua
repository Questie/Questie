dofile("setupTests.lua")

describe("PolygonMinimap", function()
    local PolygonMinimap, Pins, savedGlobals, savedError, hooks, lineDraws, player, minimap, cluster, rotateCVar, atlases
    local GLOBALS = {"CreateFrame", "DrawLine", "LibStub", "hooksecurefunc", "Minimap", "GetPlayerFacing", "GetMinimapShape",
        "C_Texture", "C_Minimap", "issecretvalue", "GetCVar", "WorldMapFrame", "CreateFramePool", "CreateFromMixins",
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
        function region:Show() self.shown = true end
        function region:Hide() self.shown = false end
        function region:IsShown() return self.shown end
        function region:SetTexture(asset, ...) self.texture, self.atlas, self.wrap = asset, nil, {...} end
        function region:SetAtlas(asset, ...) self.atlas, self.texture, self.wrap = asset, nil, {select(4, ...)} end
        return region
    end

    local function Frame(_kind, _name, parent)
        local frame = Region()
        frame.parent, frame.level = parent, (parent and parent.level or 0) + 1
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

    -- One frame for HereBeDragons-Pins' minimap icons, then one for the area layer.
    local function Tick(layer)
        Pins.updateFrame.scripts.OnUpdate(Pins.updateFrame, 2)
        layer.root.scripts.OnUpdate(layer.root)
    end

    local function Area(outline, color)
        return {key = {}, cluster = {uiMapId = 10, instanceId = 0, outline = outline or cluster.outline},
            color = color or {1, 0, 0}, alpha = 1}
    end

    ---Each border starts at its outline vertex. Its position is the container's offset from the
    ---minimap center, plus the polygon frame's offset in the container, plus the vertex in the
    ---frame. HereBeDragons places a minimap icon on each vertex for comparison.
    local function AssertOutlineOnIcons(layer, frame, outline)
        local container = layer.container.anchor
        assert.are.same({"TOPLEFT", minimap, "CENTER"}, {container[1], container[2], container[3]})
        assert.are.equal(layer.container, frame.anchor[2])
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
        hooks, lineDraws, atlases = {}, 0, {}
        player = {instance = 0, facing = 0.3, zone = 10}
        player.x, player.y = World(10, 41, 42)
        rotateCVar = "1"
        minimap = Frame()
        minimap.zoom, minimap.size = 0, {140, 120}
        function minimap:GetZoom() return self.zoom end
        function minimap:GetWidth() return self.size[1] end
        function minimap:GetHeight() return self.size[2] end
        minimap.GetScale, minimap.IsVisible = function() return 1 end, function() return true end
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
        _G.DrawLine = function(texture, parent, startX, startY, endX, endY)
            lineDraws = lineDraws + 1
            texture.line = {parent, startX, startY, endX, endY}
        end
        _G.hooksecurefunc = function(object, method, hook) hooks[#hooks + 1] = {object, method, hook} end
        _G.Minimap = minimap
        _G.GetPlayerFacing = function() return player.facing end
        _G.GetMinimapShape = nil
        _G.C_Texture = {GetAtlasInfo = function(atlas) return atlases[atlas] end}
        _G.issecretvalue = nil
        _G.UPPER_LEFT_VERTEX, _G.UPPER_RIGHT_VERTEX, _G.LOWER_LEFT_VERTEX, _G.LOWER_RIGHT_VERTEX = 1, 2, 3, 4
        dofile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")
        dofile("Polygon/PolygonRenderer.lua")
        dofile("Polygon/PolygonMinimap.lua")
        PolygonMinimap = QuestieLoader:ImportModule("PolygonMinimap")
    end)

    after_each(function()
        -- The explicit list also restores globals that started out nil.
        for _, name in ipairs(GLOBALS) do _G[name] = savedGlobals[name] end
        Questie.Error = savedError
    end)

    it("draws outlines exactly where HereBeDragons places minimap icons, while walking, turning and zooming", function()
        local area = Area()
        local layer = PolygonMinimap.New(minimap, function() return {area} end)
        layer:Invalidate()
        Tick(layer)
        local frame = layer.views[area.key].frame
        assert.is_true(frame:IsShown())
        AssertOutlineOnIcons(layer, frame, cluster.outline)

        -- Walking only moves the container; the outline keeps its projection.
        local draws = lineDraws
        player.x, player.y = World(10, 43, 41)
        Tick(layer)
        assert.are.equal(draws, lineDraws)
        AssertOutlineOnIcons(layer, frame, cluster.outline)

        -- Turning a rotating minimap, zooming, and resizing the minimap each project it again.
        player.facing = 1.2
        Tick(layer)
        assert.is_true(lineDraws > draws)
        AssertOutlineOnIcons(layer, frame, cluster.outline)
        draws = lineDraws
        minimap.zoom = 1
        Tick(layer)
        assert.is_true(lineDraws > draws)
        AssertOutlineOnIcons(layer, frame, cluster.outline)
        draws = lineDraws
        minimap.size = {180, 160}
        Tick(layer)
        assert.is_true(lineDraws > draws)
        AssertOutlineOnIcons(layer, frame, cluster.outline)

        -- A minimap that keeps north up ignores the facing.
        Pins.updateFrame.scripts.OnEvent(Pins.updateFrame, "CVAR_UPDATE", "rotateMinimap", "0")
        Tick(layer)
        AssertOutlineOnIcons(layer, frame, cluster.outline)

        -- Standing still draws nothing again.
        draws = lineDraws
        Tick(layer)
        assert.are.equal(draws, lineDraws)
    end)

    it("keeps a large area whose center is out of view while its edge reaches the minimap", function()
        -- About 930 yards wide; its center is some 480 yards west of the player, past 1.5 view radii.
        local area = Area({{x = 10, y = 30}, {x = 41, y = 30}, {x = 41, y = 50}, {x = 10, y = 50}})
        player.x, player.y = World(10, 41.5, 42)
        local layer = PolygonMinimap.New(minimap, function() return {area} end)
        layer:Invalidate()
        Tick(layer)
        assert.is_true(layer.views[area.key].frame:IsShown())
    end)

    it("draws nothing without a position or size, on another instance, or out of view, then idles", function()
        local areas = {Area(), {key = {}, cluster = {uiMapId = 99, instanceId = 0, outline = cluster.outline},
            color = {0, 1, 0}, alpha = 1}}
        local layer = PolygonMinimap.New(minimap, function() return areas end)
        layer:Invalidate()
        Tick(layer)
        local frame = layer.views[areas[1].key].frame
        -- A map without world data has nothing to place.
        assert.is_nil(layer.views[areas[2].key])
        assert.is_true(frame:IsShown())

        local x, y = player.x, player.y
        player.x, player.y = nil, nil
        Tick(layer)
        assert.is_false(frame:IsShown())
        player.x, player.y, player.instance = x, y, 1
        Tick(layer)
        assert.is_false(frame:IsShown())
        player.instance = 0
        minimap.size = {0, 0}
        Tick(layer)
        assert.is_false(frame:IsShown())
        minimap.size = {140, 120}
        Tick(layer)
        assert.is_true(frame:IsShown())
        -- 400 yards east of the area's bounds, beyond 1.5 view radii of the 233-yard zoom.
        player.x = World(10, 44, 42) - 400
        Tick(layer)
        assert.is_false(frame:IsShown())

        areas = {}
        layer:Invalidate()
        Tick(layer)
        assert.are.same({}, layer.views)
        assert.is_false(layer.root:IsShown())
    end)

    it("releases only areas no longer collected, and restyles a changed fade without reprojecting", function()
        local kept, removed = Area(), Area({{x = 41, y = 41}, {x = 42, y = 41}, {x = 41, y = 42}}, {0, 0, 1})
        local areas = {kept, removed}
        local layer = PolygonMinimap.New(minimap, function() return areas end)
        layer:Invalidate()
        Tick(layer)
        local keptFrame, removedFrame = layer.views[kept.key].frame, layer.views[removed.key].frame

        local draws = lineDraws
        areas = {{key = kept.key, cluster = kept.cluster, color = kept.color, alpha = 0.4}}
        layer:Invalidate()
        Tick(layer)
        assert.is_nil(layer.views[removed.key])
        assert.is_false(removedFrame:IsShown())
        assert.is_nil(layer.renderer.ownedFrames[removedFrame])
        assert.are.equal(keptFrame, layer.views[kept.key].frame)
        assert.is_true(keptFrame:IsShown())
        assert.are.equal(draws, lineDraws)
        assert.are_near(0.25 * 0.4, keptFrame.fills[1].color[4], 1e-9)
    end)

    it("stops after a failed update, reports it, and draws again on the next change", function()
        Questie.Error = spy.new(function() end)
        local fail = true
        local area = Area()
        local layer = PolygonMinimap.New(minimap, function()
            if fail then error("collection failed") end
            return {area}
        end)
        layer:Invalidate()
        Tick(layer)
        assert.spy(Questie.Error).was.called(1)
        assert.is_false(layer.root:IsShown())

        fail = false
        layer:Invalidate()
        Tick(layer)
        assert.is_true(layer.views[area.key].frame:IsShown())
    end)

    describe("shape mask", function()
        local function ShapeMask(layer)
            local mask = layer.renderer.maskTextures[1]
            return mask.atlas or mask.texture, mask.wrap
        end

        it("assumes a round minimap unless GetMinimapShape reports a square one", function()
            assert.are.same({"Interface\\CharacterFrame\\TempPortraitAlphaMask", false}, {PolygonMinimap.ShapeMask()})
            atlases["ui-hud-minimap-frame-generic-mask"] = {}
            assert.are.same({"ui-hud-minimap-frame-generic-mask", true}, {PolygonMinimap.ShapeMask()})

            for shape, expected in pairs({SQUARE = "Interface\\BUTTONS\\WHITE8X8",
                ["CORNER-TOPLEFT"] = "Interface\\BUTTONS\\WHITE8X8", ["SIDE-LEFT"] = "ui-hud-minimap-frame-generic-mask"}) do
                _G.GetMinimapShape = function() return shape end
                assert.are.equal(expected, (PolygonMinimap.ShapeMask()))
            end
        end)

        it("follows the asset minimap addons pass to Minimap:SetMaskTexture", function()
            _G.GetMinimapShape = function() return "SQUARE" end
            atlases["ui-hud-minimap-frame-generic-mask"] = {}
            local layer = PolygonMinimap.New(minimap, function() return {} end)
            -- Outside the minimap's rectangle stays masked out.
            assert.are.same({"Interface\\BUTTONS\\WHITE8X8", {"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE"}}, {ShapeMask(layer)})

            local hook = hooks[#hooks]
            assert.are.same({minimap, "SetMaskTexture"}, {hook[1], hook[2]})
            hook[3](minimap, "Interface\\AddOns\\SexyMap\\shapes\\heart")
            assert.are.same({"Interface\\AddOns\\SexyMap\\shapes\\heart", {"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE"}},
                {ShapeMask(layer)})
            hook[3](minimap, "ui-hud-minimap-frame-generic-mask")
            assert.are.equal("ui-hud-minimap-frame-generic-mask", layer.renderer.maskTextures[1].atlas)

            -- The player mask clamps its opaque edges outward, so only its middle is cut out.
            local playerMask = layer.renderer.maskTextures[2]
            assert.are.same({"Interface\\Addons\\Questie\\Icons\\polygon-minimap-player-mask.tga", {"CLAMP", "CLAMP"}},
                {playerMask.texture, playerMask.wrap})
            assert.are.same({"CENTER", minimap, "CENTER"}, playerMask.anchor)
        end)

        it("never lets a failing mask update break the caller of Minimap:SetMaskTexture", function()
            local layer = PolygonMinimap.New(minimap, function() return {} end)
            layer.renderer.maskTextures[1].SetTexture = function() error("mask update failed") end
            assert.has_no.errors(function() hooks[#hooks][3](minimap, "Interface\\AddOns\\SexyMap\\shapes\\heart") end)
        end)
    end)
end)
