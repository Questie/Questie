dofile("setupTests.lua")

describe("MinimapCanvas", function()
    ---@type MinimapCanvas
    local MinimapCanvas
    local QuestieCompat
    local Pins, savedGlobals, savedCompat, savedError, hooks, player, minimap, root, rotateCVar, atlases
    local cursor, focus, uiScale, gamepadUI
    local GLOBALS = {"CreateFrame", "LibStub", "hooksecurefunc", "Minimap", "GetPlayerFacing", "GetMinimapShape",
        "C_Texture", "C_Minimap", "issecretvalue", "GetCVar", "GetCursorPosition", "WorldMapFrame", "CreateFramePool",
        "CreateFromMixins", "CreateUnsecuredRegionPoolInstance", "MapCanvasDataProviderMixin", "MapCanvasPinMixin"}

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
        function frame:SetScript(name, handler)
            self.scripts = self.scripts or {}
            self.scripts[name] = handler
        end
        frame.RegisterEvent, frame.UnregisterAllEvents = function() end, function() end
        function frame:SetClipsChildren(clips) self.clips = clips end
        function frame:GetFrameLevel() return self.level end
        function frame:SetFrameLevel(level) self.level = level end
        function frame:CreateMaskTexture() return Region() end
        -- The canvas's root is the first frame created on the minimap.
        if parent ~= nil and parent == minimap and not root then root = frame end
        return frame
    end

    -- One frame for HereBeDragons-Pins' minimap icons, then one for the canvas.
    local function Tick()
        Pins.updateFrame.scripts.OnUpdate(Pins.updateFrame, 2)
        root.scripts.OnUpdate(root)
    end

    ---A layer recording what the canvas asks of it. It finds something to show while `found`, and,
    ---given `claims`, hovers and claims the cursor while that is true.
    local function FakeLayer(name, claims)
        local fake = {calls = {}, found = true, claims = claims}
        fake.layer = {
            Collect = function()
                fake.calls[#fake.calls + 1] = {"Collect"}
                return fake.found
            end,
            Draw = function(projection)
                fake.calls[#fake.calls + 1] = {"Draw", projection}
                fake.projection = projection
            end,
            Clear = function() fake.calls[#fake.calls + 1] = {"Clear"} end,
        }
        if claims ~= nil then
            fake.layer.Hover = function(x, y)
                fake.calls[#fake.calls + 1] = {"Hover", x, y}
                return x ~= nil and fake.claims
            end
        end
        fake.container, fake.masks = MinimapCanvas.AddLayer(name, fake.layer)
        MinimapCanvas.Invalidate(name)
        return fake
    end

    ---The calls a fake layer got of one kind, since the last Forget.
    local function Calls(fake, method)
        local found = {}
        for _, call in ipairs(fake.calls) do
            if call[1] == method then found[#found + 1] = call end
        end
        return found
    end

    local function Forget(...)
        for _, fake in ipairs({...}) do fake.calls = {} end
    end

    ---Places the cursor at minimap units from the minimap's center, x right and y down. The center
    ---is at 500, 500; the cursor is in pixels, at the UI scale.
    local function CursorAt(x, y)
        cursor = {(500 + x) * uiScale, (500 - y) * uiScale}
    end

    ---Places the cursor on a world point, where the layers draw it.
    local function CursorOn(fake, worldX, worldY)
        local x, y = MinimapCanvas.Project(fake.projection, worldX, worldY)
        local anchor = fake.container.anchor
        CursorAt(anchor[4] + x, -anchor[5] + y)
    end

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(GLOBALS) do savedGlobals[name] = _G[name] end
        savedError = Questie.Error
        Questie.Error = spy.new(function() end)
        hooks, atlases, root = {}, {}, nil
        player = {x = 1000, y = 1000, instance = 0, facing = 0.3}
        rotateCVar = "1"
        cursor, focus, uiScale, gamepadUI = nil, nil, 1, false
        minimap = Frame()
        minimap.zoom, minimap.size = 0, {140, 120}
        function minimap:GetZoom() return self.zoom end
        function minimap:GetWidth() return self.size[1] end
        function minimap:GetHeight() return self.size[2] end
        function minimap:GetCenter() return 500, 500 end
        function minimap:GetEffectiveScale() return uiScale end
        function minimap:IsMouseOver() return cursor ~= nil end
        minimap.GetScale, minimap.IsVisible = function() return 1 end, function() return true end
        focus = minimap

        local HBD = {
            GetPlayerWorldPosition = spy.new(function() return player.x, player.y, player.instance end),
            GetPlayerZone = function() return 10 end,
            RegisterCallback = function() end,
        }
        -- The real HereBeDragons-Pins: its minimap icons are the alignment reference, and its
        -- GetMinimapView supplies the radius from the zoom table.
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
        _G.hooksecurefunc = function(object, method, hook) hooks[#hooks + 1] = {object, method, hook} end
        _G.Minimap = minimap
        _G.GetPlayerFacing = function() return player.facing end
        _G.GetMinimapShape = nil
        _G.C_Texture = {GetAtlasInfo = function(atlas) return atlases[atlas] end}
        _G.issecretvalue = nil
        _G.GetCursorPosition = function() return cursor[1], cursor[2] end
        QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        savedCompat = {GetMouseFocus = QuestieCompat.GetMouseFocus, IsGamepadUIEnabled = QuestieCompat.IsGamepadUIEnabled}
        QuestieCompat.GetMouseFocus = function() return focus end
        QuestieCompat.IsGamepadUIEnabled = function() return gamepadUI end
        dofile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Map/MinimapCanvas.lua")
        MinimapCanvas = QuestieLoader:ImportModule("MinimapCanvas")
    end)

    after_each(function()
        -- The explicit list also restores globals that started out nil.
        for _, name in ipairs(GLOBALS) do _G[name] = savedGlobals[name] end
        QuestieCompat.GetMouseFocus, QuestieCompat.IsGamepadUIEnabled = savedCompat.GetMouseFocus, savedCompat.IsGamepadUIEnabled
        Questie.Error = savedError
    end)

    describe("projection", function()
        ---Asserts each world point is drawn where HereBeDragons-Pins places a minimap icon for it: the
        ---container's offset from the minimap's center, plus the point in the container, y down.
        local function AssertOnIcons(fake, points)
            local container = fake.container.anchor
            assert.are.same({"TOPLEFT", minimap, "CENTER"}, {container[1], container[2], container[3]})
            for i, point in ipairs(points) do
                local icon = Region()
                Pins:AddMinimapIconWorld("test", icon, 0, point[1], point[2])
                Pins.updateFrame.scripts.OnUpdate(Pins.updateFrame, 2)
                assert.is_true(icon.shown, "point " .. i .. " must be inside the minimap for a placed icon")
                local x, y = MinimapCanvas.Project(fake.projection, point[1], point[2])
                assert.are_near(icon.anchor[4], container[4] + x, 1e-9)
                assert.are_near(icon.anchor[5], container[5] - y, 1e-9)
                Pins:RemoveMinimapIcon("test", icon)
            end
        end

        local POINTS = {{1020, 990}, {960, 1030}, {1000, 1050}}

        it("places drawings exactly where HereBeDragons-Pins places minimap icons, walking, turning, zooming and resizing", function()
            local paths = FakeLayer("paths")
            Tick()
            AssertOnIcons(paths, POINTS)

            player.x, player.y = 1010, 985
            Tick()
            AssertOnIcons(paths, POINTS)
            player.facing = 1.2
            Tick()
            AssertOnIcons(paths, POINTS)
            minimap.zoom = 1
            Tick()
            AssertOnIcons(paths, POINTS)
            minimap.size = {180, 160}
            Tick()
            AssertOnIcons(paths, POINTS)
            -- A minimap that keeps north up ignores the facing.
            Pins.updateFrame.scripts.OnEvent(Pins.updateFrame, "CVAR_UPDATE", "rotateMinimap", "0")
            Tick()
            assert.is_nil(paths.projection.facing)
            AssertOnIcons(paths, POINTS)
        end)

        it("only moves the containers while walking, and projects again for a new view or past half a radius", function()
            local paths = FakeLayer("paths")
            Tick()
            local radius = paths.projection.radius
            Forget(paths)

            -- Standing still, then walking within half a view radius, draws nothing again.
            Tick()
            player.x = 1000 + radius * 0.4
            Tick()
            assert.are.same({}, Calls(paths, "Draw"))
            -- Past it, everything is projected again around the player.
            player.x = 1000 + radius * 0.6
            Tick()
            assert.are.equal(1, #Calls(paths, "Draw"))
            assert.are.equal(player.x, paths.projection.originX)

            -- So do a turn of a rotating minimap, a zoom, a resize and another instance.
            for _, change in ipairs({
                function() player.facing = 2 end,
                function() minimap.zoom = 2 end,
                function() minimap.size = {200, 200} end,
                function() player.instance = 1 end,
            }) do
                Forget(paths)
                change()
                Tick()
                assert.are.equal(1, #Calls(paths, "Draw"))
            end
        end)

        it("samples the player once per frame and hands every layer the same projection", function()
            local areas, paths = FakeLayer("areas"), FakeLayer("paths")
            local HBD = LibStub("HereBeDragonsQuestie-2.0")

            root.scripts.OnUpdate(root)

            assert.spy(HBD.GetPlayerWorldPosition).was.called(1)
            assert.is_table(paths.projection)
            assert.are.equal(areas.projection, paths.projection)
            assert.are.equal(areas.container.anchor[4], paths.container.anchor[4])
        end)

        it("tells what comes within reach of the projection's origin, on its instance", function()
            local paths = FakeLayer("paths")
            Tick()
            local projection = paths.projection
            local reach = projection.reach
            -- Everything visible lies within √2 radii of the player, who drifts at most half a radius
            -- before the next projection.
            assert.are.equal(2 * projection.radius, reach)

            assert.is_true(MinimapCanvas.InReach(projection, 0, {990, 990, 1010, 1010}))
            -- A large area reaching in by its edge only.
            assert.is_true(MinimapCanvas.InReach(projection, 0, {0, 0, 1000 - reach, 2000}))
            assert.is_false(MinimapCanvas.InReach(projection, 0, {0, 0, 1000 - reach - 1, 2000}))
            assert.is_false(MinimapCanvas.InReach(projection, 1, {990, 990, 1010, 1010}))
        end)

        it("turns minimap units back into the world yards they show, on a turned, non-square minimap", function()
            local angle = 0.7
            local projection = {originX = 1000, originY = 2000, scaleX = 0.5, scaleY = 0.4, sin = math.sin(angle),
                cos = math.cos(angle)}
            for _, point in ipairs({{1000, 2000}, {1030, 1990}, {870, 2150}}) do
                local x, y = MinimapCanvas.Unproject(projection, MinimapCanvas.Project(projection, point[1], point[2]))
                assert.are_near(point[1], x, 1e-9)
                assert.are_near(point[2], y, 1e-9)
            end
        end)
    end)

    describe("lifecycle", function()
        it("hides drawings without a position, radius or size, or while one is secret, and draws them when back", function()
            local paths = FakeLayer("paths", true)
            Tick()
            CursorOn(paths, 1000, 1020)
            Tick()
            Forget(paths)

            for _, lose in ipairs({
                function() player.x = nil end,
                function() minimap.size = {0, 0} end,
                -- A rotating minimap without the player's facing.
                function() player.facing = nil end,
                function() _G.issecretvalue = function(value) return value == player.y end end,
                function() _G.issecretvalue = function(value) return value == minimap.size[1] end end,
            }) do
                lose()
                Tick()
                Tick()
                -- The hover ends once, and the drawings hide once.
                assert.are.same({{"Hover", nil, nil}, {"Draw", nil}}, paths.calls)
                player.x, player.facing, minimap.size, _G.issecretvalue = 1000, 0.3, {140, 120}, nil
                Tick()
                assert.is_table(paths.projection)
                Forget(paths)
                -- The returning position hovers again, so the next loss ends it again.
                Tick()
                Forget(paths)
            end
        end)

        it("stops a layer left with nothing to show: its hover ends, its drawings hide, and the canvas idles", function()
            local paths = FakeLayer("paths", true)
            Tick()
            CursorAt(10, 10)
            Tick()
            Forget(paths)

            paths.found = false
            MinimapCanvas.Invalidate("paths")
            Tick()

            assert.are.same({{"Collect"}, {"Hover", nil, nil}, {"Draw", nil}}, paths.calls)
            assert.is_false(root:IsShown())
        end)

        it("idles without anything to draw until a layer is invalidated", function()
            local paths = FakeLayer("paths")
            paths.found = false
            Tick()
            assert.is_false(root:IsShown())
            assert.are.same({}, Calls(paths, "Draw"))

            paths.found = true
            MinimapCanvas.Invalidate("paths")
            assert.is_true(root:IsShown())
            Tick()
            assert.are.equal(1, #Calls(paths, "Draw"))
        end)

        it("stops after its own failure, clearing every layer, until a layer is invalidated", function()
            local paths = FakeLayer("paths", true)
            local cleared = 0
            -- Clearing ends a hover, which invalidates the layer again; the canvas still stops.
            paths.layer.Clear = function()
                cleared = cleared + 1
                MinimapCanvas.Invalidate("paths")
            end
            local HBD = LibStub("HereBeDragonsQuestie-2.0")
            local position = HBD.GetPlayerWorldPosition
            HBD.GetPlayerWorldPosition = function() error("position failed") end

            root.scripts.OnUpdate(root)

            assert.spy(Questie.Error).was.called(1)
            assert.are.equal(1, cleared)
            assert.is_false(root:IsShown())
            HBD.GetPlayerWorldPosition = position
            MinimapCanvas.Invalidate("paths")
            Tick()
            assert.is_table(paths.projection)
        end)

        it("stacks areas beneath paths, above the minimap and far below Questie's minimap icons", function()
            local areas, paths = FakeLayer("areas"), FakeLayer("paths")

            assert.are.equal(minimap:GetFrameLevel() + 1, areas.container:GetFrameLevel())
            assert.are.equal(areas.container:GetFrameLevel() + 1, paths.container:GetFrameLevel())
            assert.is_true(paths.container:GetFrameLevel() < 2016)
            assert.has_error(function() MinimapCanvas.AddLayer("nope", {}) end)
        end)

        it("isolates a failing layer: reports it once, clears it, and resumes it on its next Invalidate", function()
            local areas, paths = FakeLayer("areas", true), FakeLayer("paths", false)
            local failing, attempts = true, 0
            paths.layer.Draw = function(projection)
                attempts = attempts + 1
                if failing then error("drawing failed") end
                paths.projection = projection
            end
            -- Ending a hover changes a highlight, which invalidates the layer; it stays off anyway.
            paths.layer.Clear = function() MinimapCanvas.Invalidate("paths") end
            Tick()
            assert.spy(Questie.Error).was.called(1)
            assert.is_table(areas.projection)
            Tick()
            assert.are.equal(1, attempts)

            -- Invalidated while still failing, it fails again quietly; fixed, it draws on its next one.
            MinimapCanvas.Invalidate("paths")
            Tick()
            assert.are.equal(2, attempts)
            failing = false
            MinimapCanvas.Invalidate("paths")
            Tick()
            assert.is_table(paths.projection)
            assert.spy(Questie.Error).was.called(1)

            -- A layer whose Hover fails claims nothing: the layer beneath gets the cursor in the same offer.
            paths.layer.Hover = function(x) if x then error("hover failed") end end
            Forget(areas)
            CursorOn(areas, 1000, 1020)
            Tick()
            assert.are.equal(1, #Calls(areas, "Hover"))
            assert.is_number(Calls(areas, "Hover")[1][2])
        end)
    end)

    describe("hover", function()
        it("offers the cursor in projected units at the minimap's scale, also as the player walks or a layer draws", function()
            uiScale = 2
            local paths = FakeLayer("paths", true)
            Tick()
            local wx, wy = MinimapCanvas.Project(paths.projection, 1000, 1020)
            CursorOn(paths, 1000, 1020)
            Tick()
            local hover = Calls(paths, "Hover")[1]
            assert.are_near(wx, hover[2], 1e-9)
            assert.are_near(wy, hover[3], 1e-9)

            -- The player walks under a still cursor: it lies elsewhere against the drawings.
            Forget(paths)
            player.x = 1010
            Tick()
            assert.are.equal(1, #Calls(paths, "Hover"))
            assert.are_not.near(wx, Calls(paths, "Hover")[1][2], 1e-6)

            -- Standing still offers nothing again; drawing again does.
            Forget(paths)
            Tick()
            assert.are.same({}, Calls(paths, "Hover"))
            MinimapCanvas.Invalidate("paths")
            Tick()
            assert.are.equal(1, #Calls(paths, "Hover"))
        end)

        it("offers no cursor in the gamepad UI, while other UI covers the minimap, or outside its shape", function()
            local paths = FakeLayer("paths", true)
            Tick()
            for _, case in ipairs({
                {cover = function() gamepadUI = true end, x = 11, y = 10},
                {cover = function() focus = {} end, x = 11, y = 10},
                {cover = function() _G.issecretvalue = function(value) return value == true end end, x = 11, y = 10},
                {cover = function() _G.issecretvalue = function(value) return value == uiScale end end, x = 11, y = 10},
                -- In a round minimap's corner: 60 units right of and 50 above its center.
                {cover = function() end, x = 60, y = -50},
            }) do
                CursorAt(10, 10)
                Tick()
                Forget(paths)
                case.cover()
                CursorAt(case.x, case.y)
                Tick()
                assert.are.same({{"Hover", nil, nil}}, paths.calls)
                gamepadUI, focus, _G.issecretvalue = false, minimap, nil
            end
        end)

        it("hovers a square minimap's corners, also when its addon sets its own mask", function()
            local paths = FakeLayer("paths", true)
            Tick()
            CursorAt(60, -50)
            Tick()
            assert.are.same({}, Calls(paths, "Hover"))

            -- The square mask set through Minimap:SetMaskTexture, without GetMinimapShape.
            hooks[1][3](minimap, "Interface\\BUTTONS\\WHITE8X8")
            CursorAt(61, -50)
            Tick()
            assert.is_number(Calls(paths, "Hover")[1][2])

            -- A minimap addon's own square texture, by FileDataID, which GetMinimapShape reports square.
            Forget(paths)
            hooks[1][3](minimap, 130871)
            CursorAt(62, -50)
            Tick()
            assert.are.same({{"Hover", nil, nil}}, paths.calls)
            _G.GetMinimapShape = function() return "SQUARE" end
            CursorAt(61, -50)
            Tick()
            assert.is_number(Calls(paths, "Hover")[2][2])
        end)

        it("offers the cursor top down: a claim gives the layer beneath nil once", function()
            local areas, paths = FakeLayer("areas", true), FakeLayer("paths", false)
            Tick()
            CursorAt(10, 10)
            Tick()
            assert.are.equal(1, #Calls(areas, "Hover"))

            -- The paths claim it: the areas get nil once, then nothing while the paths keep it.
            paths.claims = true
            Forget(areas)
            CursorAt(11, 10)
            Tick()
            CursorAt(12, 10)
            Tick()
            assert.are.same({{"Hover", nil, nil}}, Calls(areas, "Hover"))

            -- Off the paths, the areas get the cursor again in the same offer.
            paths.claims = false
            Forget(areas)
            CursorAt(13, 10)
            Tick()
            assert.is_number(Calls(areas, "Hover")[1][2])
        end)

        it("ends the hover when the minimap hides, keeping the drawings", function()
            local paths = FakeLayer("paths", true)
            Tick()
            CursorAt(10, 10)
            Tick()
            Forget(paths)

            root.scripts.OnHide(root)

            assert.are.same({{"Hover", nil, nil}}, paths.calls)
        end)
    end)

    describe("shape mask", function()
        local ROUND, SQUARE = "Interface\\CharacterFrame\\TempPortraitAlphaMask", "Interface\\BUTTONS\\WHITE8X8"

        it("follows the asset minimap addons pass to Minimap:SetMaskTexture, never breaking that call", function()
            local paths = FakeLayer("paths")
            local shapeMask = paths.masks[1]
            -- Outside the minimap's rectangle stays masked out.
            assert.are.same({ROUND, {"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE"}}, {shapeMask.texture, shapeMask.wrap})

            local hook = hooks[1]
            assert.are.same({minimap, "SetMaskTexture"}, {hook[1], hook[2]})
            hook[3](minimap, "Interface\\AddOns\\SexyMap\\shapes\\heart")
            assert.are.equal("Interface\\AddOns\\SexyMap\\shapes\\heart", shapeMask.texture)
            atlases["ui-hud-minimap-frame-generic-mask"] = {}
            hook[3](minimap, "ui-hud-minimap-frame-generic-mask")
            assert.are.equal("ui-hud-minimap-frame-generic-mask", shapeMask.atlas)

            shapeMask.SetTexture = function() error("mask update failed") end
            assert.has_no.errors(function() hook[3](minimap, "Interface\\AddOns\\SexyMap\\shapes\\heart") end)
        end)

        it("falls back to GetMinimapShape: square only for a square minimap, round for any round quarter", function()
            assert.are.same({ROUND, false}, {MinimapCanvas.ShapeMask()})
            for shape, expected in pairs({SQUARE = SQUARE, ["CORNER-TOPLEFT"] = ROUND, ["SIDE-LEFT"] = ROUND,
                ["TRICORNER-TOPLEFT"] = ROUND}) do
                _G.GetMinimapShape = function() return shape end
                assert.are.equal(expected, (MinimapCanvas.ShapeMask()))
            end
            -- Forever's own round mask where the client has it.
            _G.GetMinimapShape = nil
            atlases["ui-hud-minimap-frame-generic-mask"] = {}
            assert.are.same({"ui-hud-minimap-frame-generic-mask", true}, {MinimapCanvas.ShapeMask()})
        end)

        it("leaves a soft hole over the player arrow", function()
            local paths = FakeLayer("paths")
            local playerMask = paths.masks[2]

            assert.are.same({QuestieLoader:ImportModule("QuestieLib").AddonPath .. "Icons\\minimap-player-mask.tga",
                {"CLAMP", "CLAMP"}}, {playerMask.texture, playerMask.wrap})
            assert.are.same({"CENTER", minimap, "CENTER"}, playerMask.anchor)
            assert.are.same({38, 38}, {playerMask.width, playerMask.height})
        end)
    end)
end)
