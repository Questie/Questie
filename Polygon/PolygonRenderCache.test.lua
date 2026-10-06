dofile("setupTests.lua")
local match = require("luassert.match")

describe("PolygonRenderCache", function()
    local PolygonRenderCache, cache, renderer, createdFrames, owner, key, source, shape

    before_each(function()
        dofile("Polygon/PolygonRenderCache.lua")
        PolygonRenderCache = QuestieLoader:ImportModule("PolygonRenderCache")
        createdFrames = {}
        -- The renderer mock owns opaque handles and models only visibility/lifetime.
        -- Geometry math and native input behavior belong to PolygonRenderer's tests.
        renderer = {owned = {}, visible = {}, released = {}}
        renderer.Create = spy.new(function(self)
            local frame = {id = #createdFrames + 1, shown = false}
            createdFrames[#createdFrames + 1] = frame
            self.owned[frame] = true
            return frame
        end)
        renderer.Configure = spy.new(function() end)
        renderer.Style = spy.new(function() end)
        renderer.SetVisibleFrames = spy.new(function(self, frames)
            for frame in pairs(self.owned) do frame.shown = false end
            self.visible = frames
            for _, frame in ipairs(frames) do frame.shown = true end
        end)
        renderer.Release = spy.new(function(self, frame)
            self.owned[frame] = nil
            self.released[frame] = true
            frame.shown = false
        end)
        renderer.Clear = spy.new(function(self)
            for frame in pairs(self.owned) do frame.shown = false end
            self.owned, self.visible = {}, {}
        end)
        owner, key = {}, {}
        source = {{x = 10, y = 10}, {x = 20, y = 10}, {x = 10, y = 20}}
        shape = {owner = owner, key = key, source = source, sourceMapId = 10,
            points = source, color = {0.2, 0.5, 1, 0.25}, borderAlpha = 0.75, highlighted = false}
        cache = PolygonRenderCache.New(renderer)
    end)

    it("allocates no rendered views before they are presented", function()
        assert.spy(renderer.Create).was.not_called()
        assert.spy(renderer.SetVisibleFrames).was.not_called()
        assert.spy(renderer.Clear).was.not_called()
    end)

    it("creates and publishes a new view only once", function()
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))

        assert.spy(renderer.Create).was.called_with(match._, shape, 1000, 500, 8)
        assert.spy(renderer.Configure).was.not_called()
        assert.spy(renderer.Style).was.not_called()
        assert.spy(renderer.SetVisibleFrames).was.called(1)
        assert.are_same({createdFrames[1]}, renderer.visible)
        assert.is_true(createdFrames[1].shown)
    end)

    it("reuses geometry when callers recreate identical appearance records", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        local nextShape = {owner = owner, key = key, source = source, sourceMapId = 10,
            points = source, color = {0.2, 0.5, 1, 0.25}, borderAlpha = 0.75, highlighted = false}

        assert.is_true(cache:Present(10, {nextShape}, 1000, 500, 8))

        assert.spy(renderer.Create).was.called(1)
        assert.spy(renderer.Configure).was.not_called()
        assert.spy(renderer.Release).was.not_called()
        assert.spy(renderer.Style).was.called_with(match._, createdFrames[1], nextShape, 8)
        assert.are_same({createdFrames[1]}, renderer.visible)
    end)

    it("delegates highlight changes to style without rebuilding geometry", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        shape.highlighted = true

        cache:Present(10, {shape}, 1000, 500, 8)

        assert.spy(renderer.Create).was.called(1)
        assert.spy(renderer.Configure).was.not_called()
        assert.spy(renderer.Release).was.not_called()
        assert.spy(renderer.Style).was.called_with(match._, createdFrames[1], shape, 8)
        assert.is_true(createdFrames[1].shown)
    end)

    it("updates color, opacity, and frame level through style only", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        shape.color, shape.borderAlpha = {1, 0.5, 0.2, 0.1}, 0.3

        cache:Present(10, {shape}, 1000, 500, 12)

        assert.spy(renderer.Create).was.called(1)
        assert.spy(renderer.Configure).was.not_called()
        assert.spy(renderer.Style).was.called_with(match._, createdFrames[1], shape, 12)
    end)

    it("retains all visited map views and shows the original handle on a return visit", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        local sourceFrame = createdFrames[1]
        local projection = {{x = -5, y = 40}, {x = 5, y = 40}, {x = -5, y = 50}}
        shape.points = projection
        cache:Present(20, {shape}, 800, 400, 8)
        local projectedFrame = createdFrames[2]
        assert.is_false(sourceFrame.shown)
        assert.is_true(projectedFrame.shown)
        shape.points = source

        cache:Present(10, {shape}, 1000, 500, 8)

        assert.is_true(sourceFrame.shown)
        assert.is_false(projectedFrame.shown)
        assert.is_true(renderer.owned[sourceFrame])
        assert.is_true(renderer.owned[projectedFrame])
        assert.spy(renderer.Create).was.called(2)
        assert.spy(renderer.Configure).was.not_called()
        assert.spy(renderer.Release).was.not_called()
        assert.are_same({sourceFrame}, renderer.visible)
    end)

    it("hides and reopens without releasing or reconfiguring a cached view", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        cache:Hide()
        cache:Hide()
        assert.is_false(createdFrames[1].shown)
        assert.are_same({}, renderer.visible)

        cache:Present(10, {shape}, 1000, 500, 8)

        assert.is_true(createdFrames[1].shown)
        assert.spy(renderer.Create).was.called(1)
        assert.spy(renderer.Configure).was.not_called()
        assert.spy(renderer.Release).was.not_called()
        assert.spy(renderer.Clear).was.not_called()
    end)

    it("hides absent previews without dropping their cached geometry", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        cache:Present(10, {}, 1000, 500, 8)
        assert.is_false(createdFrames[1].shown)
        assert.is_true(renderer.owned[createdFrames[1]])

        cache:Present(10, {shape}, 1000, 500, 8)

        assert.is_true(createdFrames[1].shown)
        assert.spy(renderer.Create).was.called(1)
        assert.spy(renderer.Configure).was.not_called()
        assert.spy(renderer.Release).was.not_called()
    end)

    it("reconfigures a changed destination projection without releasing other maps", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        shape.points = {{x = 30, y = 30}, {x = 40, y = 30}, {x = 30, y = 40}}
        cache:Present(20, {shape}, 1000, 500, 8)
        shape.points = {{x = 50, y = 50}, {x = 60, y = 50}, {x = 50, y = 60}}

        cache:Present(20, {shape}, 1000, 500, 8)
        cache:Present(20, {shape}, 1000, 500, 8)

        assert.spy(renderer.Create).was.called(2)
        assert.spy(renderer.Configure).was.called(1)
        assert.spy(renderer.Configure).was.called_with(match._, createdFrames[2], shape, 1000, 500, 8)
        assert.spy(renderer.Release).was.not_called()
        assert.is_true(renderer.owned[createdFrames[1]])
    end)

    it("reconfigures one retained handle after resize and remembers its new dimensions", function()
        cache:Present(10, {shape}, 1000, 500, 8)

        cache:Present(10, {shape}, 800, 400, 8)
        cache:Present(10, {shape}, 800, 400, 8)
        cache:Present(10, {shape}, 1000, 500, 8)

        assert.spy(renderer.Create).was.called(1)
        assert.spy(renderer.Configure).was.called(2)
        assert.spy(renderer.Configure).was.called_with(match._, createdFrames[1], shape, 800, 400, 8)
        assert.spy(renderer.Configure).was.called_with(match._, createdFrames[1], shape, 1000, 500, 8)
        assert.spy(renderer.Release).was.not_called()
    end)

    it("invalidates all destinations when the original source outline changes", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        cache:Present(20, {shape}, 1000, 500, 8)
        shape.source = {{x = 70, y = 70}, {x = 80, y = 70}, {x = 70, y = 80}}
        shape.points = shape.source

        cache:Present(20, {shape}, 1000, 500, 8)

        assert.spy(renderer.Release).was.called(2)
        assert.is_true(renderer.released[createdFrames[1]])
        assert.is_true(renderer.released[createdFrames[2]])
        assert.is_nil(renderer.owned[createdFrames[1]])
        assert.is_nil(renderer.owned[createdFrames[2]])
        assert.are_same({createdFrames[3]}, renderer.visible)
        cache:Present(10, {shape}, 1000, 500, 8)
        assert.spy(renderer.Create).was.called(4)
    end)

    it("invalidates every destination when source map identity changes", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        cache:Present(20, {shape}, 1000, 500, 8)
        shape.sourceMapId = 30

        cache:Present(10, {shape}, 1000, 500, 8)

        assert.spy(renderer.Release).was.called(2)
        assert.spy(renderer.Create).was.called(3)
        assert.are_same({createdFrames[3]}, renderer.visible)
    end)

    it("releases only the specified polygon across maps and keeps its sibling", function()
        local sibling = {owner = owner, key = {}, source = source, sourceMapId = 10,
            points = source, color = {1, 0, 0}}
        cache:Present(10, {shape, sibling}, 1000, 500, 8)
        cache:Present(20, {shape}, 1000, 500, 8)

        cache:Release(owner, key)
        cache:Release(owner, key)
        cache:Present(10, {sibling}, 1000, 500, 8)

        assert.spy(renderer.Release).was.called(2)
        assert.is_true(renderer.released[createdFrames[1]])
        assert.is_true(renderer.released[createdFrames[3]])
        assert.is_true(renderer.owned[createdFrames[2]])
        assert.is_true(createdFrames[2].shown)
        assert.spy(renderer.Create).was.called(3)
        assert.spy(renderer.Configure).was.not_called()
    end)

    it("releases all of one owner's hidden and visible views without releasing another owner", function()
        local other = {owner = {}, key = key, source = source, sourceMapId = 10,
            points = source, color = {1, 0, 0}}
        cache:Present(10, {shape, other}, 1000, 500, 8)
        cache:Present(20, {shape}, 1000, 500, 8)
        cache:Hide()

        cache:Release(owner)
        cache:Release(owner)
        cache:Release({})
        cache:Present(10, {other}, 1000, 500, 8)

        assert.spy(renderer.Release).was.called(2)
        assert.is_nil(renderer.owned[createdFrames[1]])
        assert.is_nil(renderer.owned[createdFrames[3]])
        assert.is_true(renderer.owned[createdFrames[2]])
        assert.spy(renderer.Create).was.called(3)
        assert.are_same({createdFrames[2]}, renderer.visible)
    end)

    it("creates a fresh handle when a previously released logical identity is reused", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        cache:Release(owner)

        cache:Present(10, {shape}, 1000, 500, 8)

        assert.spy(renderer.Create).was.called(2)
        assert.is_nil(renderer.owned[createdFrames[1]])
        assert.are_same({createdFrames[2]}, renderer.visible)
    end)

    it("clears visible and hidden map views and starts a new cache while keeping its renderer", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        cache:Present(20, {shape}, 1000, 500, 8)
        cache:Hide()

        cache:Clear()
        cache:Clear()

        assert.spy(renderer.Clear).was.called(2)
        assert.are_same({}, renderer.owned)
        assert.are_same({}, renderer.visible)
        cache:Present(10, {shape}, 1000, 500, 8)
        assert.spy(renderer.Create).was.called(3)
        assert.are_same({createdFrames[3]}, renderer.visible)
    end)

    it("cleans partial allocations after Create throws before returning a handle", function()
        local create = renderer.Create
        renderer.Create = spy.new(function(...)
            create(...)
            error("creation failed")
        end)

        local success, err = cache:Present(10, {shape}, 1000, 500, 8)

        assert.is_nil(success)
        assert.matches("creation failed", err)
        assert.are_equal(1, #createdFrames)
        assert.are_same({}, renderer.owned)
        assert.are_same({}, renderer.visible)
        assert.spy(renderer.Clear).was.called(1)
        renderer.Create = create
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        assert.are_same({createdFrames[2]}, renderer.visible)
    end)

    it("clears retained views on a Configure failure and retries without stale cache entries", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        cache:Present(20, {shape}, 1000, 500, 8)
        renderer.Configure = spy.new(function() error("configuration failed") end)

        local success, err = cache:Present(20, {shape}, 800, 400, 8)

        assert.is_nil(success)
        assert.matches("configuration failed", err)
        assert.are_same({}, renderer.owned)
        assert.are_same({}, renderer.visible)
        assert.spy(renderer.Clear).was.called(1)
        renderer.Configure = spy.new(function() end)
        assert.is_true(cache:Present(20, {shape}, 800, 400, 8))
        assert.are_same({createdFrames[3]}, renderer.visible)
        assert.spy(renderer.Configure).was.not_called()
    end)

    it("clears all ownership if style application fails", function()
        cache:Present(10, {shape}, 1000, 500, 8)
        renderer.Style = spy.new(function() error("styling failed") end)

        local success, err = cache:Present(10, {shape}, 1000, 500, 8)

        assert.is_nil(success)
        assert.matches("styling failed", err)
        assert.are_same({}, renderer.owned)
        assert.spy(renderer.Clear).was.called(1)
    end)

    it("clears a batch if publishing visibility fails", function()
        renderer.SetVisibleFrames = spy.new(function() error("visibility failed") end)

        local success, err = cache:Present(10, {shape}, 1000, 500, 8)

        assert.is_nil(success)
        assert.matches("visibility failed", err)
        assert.are_same({}, renderer.owned)
        assert.spy(renderer.Clear).was.called(1)
        renderer.SetVisibleFrames = spy.new(function() end)
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        assert.spy(renderer.Create).was.called(2)
    end)

    it("clears earlier views when a later shape has no lifecycle identity", function()
        local invalid = {source = source, sourceMapId = 10, points = source, color = {1, 0, 0}}

        local success, err = cache:Present(10, {shape, invalid}, 1000, 500, 8)

        assert.is_nil(success)
        assert.matches("owner and key identities", err)
        assert.spy(renderer.Create).was.called(1)
        assert.spy(renderer.SetVisibleFrames).was.not_called()
        assert.are_same({}, renderer.owned)
    end)

    it("rejects invalid canvas dimensions even for an already configured or empty view", function()
        cache:Present(10, {shape}, 1000, 500, 8)

        local success, err = cache:Present(10, {}, 0, 500, 8)

        assert.is_nil(success)
        assert.matches("Invalid polygon canvas extent", err)
        assert.are_same({}, renderer.owned)
        assert.spy(renderer.Clear).was.called(1)
    end)
end)

-- Exercise real cache/renderer composition. Only native frame/texture operations
-- are mocked, so ownership and skipped geometry work cannot be supplied by spies.
describe("PolygonRenderCache with PolygonRenderer", function()
    local cache, renderer, nativeFrames, saved, calls, failMotionFrame
    local owner, key, source, shape

    local function Count(values)
        local count = 0
        for _ in pairs(values) do count = count + 1 end
        return count
    end

    local function CreateFrameMock()
        local frame = {id = #nativeFrames + 1, scripts = {}}
        nativeFrames[#nativeFrames + 1] = frame
        function frame:Show()
            local wasShown = self.shown
            self.shown = true
            if not wasShown and self.scripts.OnShow then self.scripts.OnShow(self) end
        end
        function frame:Hide()
            local wasShown = self.shown
            self.shown = false
            if wasShown and self.scripts.OnHide then self.scripts.OnHide(self) end
        end
        function frame:IsShown() return self.shown end
        function frame:SetScript(event, callback) self.scripts[event] = callback end
        function frame:EnableMouse(enabled) self.mouse = enabled end
        function frame:EnableMouseMotion(enabled)
            if self.id == failMotionFrame then error("native motion failed") end
            self.motion = enabled
        end
        function frame:SetPropagateMouseMotion(enabled) self.propagate = enabled end
        function frame:ClearAllPoints() self.anchor = nil end
        function frame:SetPoint(...) self.anchor = {...} end
        function frame:SetSize(width, height) self.width, self.height = width, height end
        function frame:SetFrameLevel(level) self.level = level end
        function frame:CreateTexture(_name, _layer, _template, sublevel)
            local texture = {}
            function texture:SetParent(parent) self.parent = parent end
            function texture:SetSnapToPixelGrid() end
            function texture:SetTexelSnappingBias() end
            function texture:SetTexture() calls.textureSetup = calls.textureSetup + 1 end
            function texture:SetAllPoints() end
            function texture:ClearAllPoints() end
            function texture:SetVertexOffset() calls.vertexSetup = calls.vertexSetup + 1 end
            function texture:SetTexCoord() calls.uvSetup = calls.uvSetup + 1 end
            function texture:SetVertexColor(...)
                self.color = {...}
                if sublevel == 0 then calls.fillStyle = calls.fillStyle + 1 end
            end
            function texture:Show() self.shown = true end
            function texture:Hide() self.shown = false end
            return texture
        end
        return frame
    end

    before_each(function()
        saved = {CreateFrame = _G.CreateFrame, DrawLine = _G.DrawLine, random = math.random,
            UPPER_LEFT_VERTEX = _G.UPPER_LEFT_VERTEX, LOWER_LEFT_VERTEX = _G.LOWER_LEFT_VERTEX,
            UPPER_RIGHT_VERTEX = _G.UPPER_RIGHT_VERTEX, LOWER_RIGHT_VERTEX = _G.LOWER_RIGHT_VERTEX}
        nativeFrames, calls, failMotionFrame = {}, {textureSetup = 0, vertexSetup = 0, uvSetup = 0, fillStyle = 0, random = 0}, nil
        _G.CreateFrame = CreateFrameMock
        _G.DrawLine = function(texture, _, _, _, _, _, thickness) texture.thickness = thickness end
        _G.UPPER_LEFT_VERTEX, _G.LOWER_LEFT_VERTEX = "UL", "LL"
        _G.UPPER_RIGHT_VERTEX, _G.LOWER_RIGHT_VERTEX = "UR", "LR"
        math.random = function() calls.random = calls.random + 1; return calls.random / 100 end
        dofile("Polygon/PolygonRenderer.lua")
        dofile("Polygon/PolygonRenderCache.lua")
        local Renderer = QuestieLoader:ImportModule("PolygonRenderer")
        Renderer.debugRandomColors = true
        renderer = Renderer.New({}, {getCursorPosition = function() return nil end, getMouseFoci = function() return {} end})
        cache = QuestieLoader:ImportModule("PolygonRenderCache").New(renderer)
        owner, key = {}, {}
        source = {{x = 10, y = 10}, {x = 20, y = 10}, {x = 10, y = 20}}
        shape = {owner = owner, key = key, source = source, sourceMapId = 10,
            points = source, color = {0.2, 0.5, 1, 0.25}}
    end)

    after_each(function()
        failMotionFrame = nil
        cache:Clear()
        math.random = saved.random
        _G.CreateFrame, _G.DrawLine = saved.CreateFrame, saved.DrawLine
        _G.UPPER_LEFT_VERTEX, _G.LOWER_LEFT_VERTEX = saved.UPPER_LEFT_VERTEX, saved.LOWER_LEFT_VERTEX
        _G.UPPER_RIGHT_VERTEX, _G.LOWER_RIGHT_VERTEX = saved.UPPER_RIGHT_VERTEX, saved.LOWER_RIGHT_VERTEX
    end)

    it("retains actual native configuration through hover, previews, reopen, and A/B/A navigation", function()
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        local firstView = renderer.activeFrames[1]
        local fill, border = firstView.fills[1], firstView.borders[1]
        local tint = fill.color
        local hoverUpdate = renderer.hoverDriver.scripts.OnUpdate
        shape.highlighted = true
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        assert.are_equal(1.8, border.thickness)
        assert.are_equal(tint, fill.color)
        assert.are_equal(hoverUpdate, renderer.hoverDriver.scripts.OnUpdate)
        shape.highlighted = false
        assert.is_true(cache:Present(10, {}, 1000, 500, 8))
        assert.is_false(firstView.shown)
        assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        cache:Hide()
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        assert.are_equal(firstView, renderer.activeFrames[1])
        assert.are_equal(fill, firstView.fills[1])
        assert.are_equal(tint, fill.color)
        assert.are_same({textureSetup = 5, vertexSetup = 8, uvSetup = 2, fillStyle = 2, random = 15}, calls)

        shape.points = {{x = 50, y = 50}, {x = 60, y = 50}, {x = 50, y = 60}}
        assert.is_true(cache:Present(20, {shape}, 1000, 500, 8))
        local secondView = renderer.activeFrames[1]
        assert.are_not.equal(firstView, secondView)
        assert.is_false(firstView.shown)
        shape.points = source
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        assert.are_equal(firstView, renderer.activeFrames[1])
        assert.is_false(secondView.shown)
        assert.are_equal(tint, fill.color)
        assert.are_same({textureSetup = 10, vertexSetup = 16, uvSetup = 4, fillStyle = 4, random = 30}, calls)
    end)

    it("reconfigures a resized view without new primitives and releases all maps with their owner", function()
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        local firstView = renderer.activeFrames[1]
        local tint = firstView.fills[1].polygonDebugColor
        assert.is_true(cache:Present(10, {shape}, 800, 400, 8))
        assert.are_equal(firstView, renderer.activeFrames[1])
        assert.are_equal(tint, firstView.fills[1].polygonDebugColor)
        assert.are_equal(5, calls.textureSetup)
        assert.are_equal(16, calls.vertexSetup)
        assert.are_equal(15, calls.random)
        assert.is_true(cache:Present(20, {shape}, 800, 400, 8))
        cache:Hide()
        assert.are_equal(2, Count(renderer.ownedFrames))

        cache:Release(owner)
        cache:Release(owner)

        assert.are_equal(0, Count(renderer.ownedFrames))
        assert.are_equal(2, #renderer.freeFrames)
        assert.are_equal(4, #renderer.freeFills)
        assert.are_equal(6, #renderer.freeBorders)
        assert.are_same({}, renderer.hoverFrames)
        assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)
    end)

    it("attempts every owner's view and retains only failed mappings for a release retry", function()
        local sibling = {owner = owner, key = {}, source = source, sourceMapId = 10, points = source, color = {1, 0, 0}}
        assert.is_true(cache:Present(10, {shape, sibling}, 1000, 500, 8))
        assert.is_true(cache:Present(20, {shape, sibling}, 1000, 500, 8))
        local failedView, siblingView = renderer.activeFrames[1], renderer.activeFrames[2]
        failMotionFrame = failedView.id

        assert.has_error(function() cache:Release(owner) end, "native motion failed")

        assert.is_false(failedView.shown)
        assert.is_false(siblingView.shown)
        assert.are_equal(1, Count(renderer.ownedFrames))
        assert.is_true(renderer.ownedFrames[failedView])
        assert.are_equal(1, Count(cache.owners[owner]))
        assert.are_equal(1, Count(cache.owners[owner][key].maps))
        assert.are_equal(failedView, cache.owners[owner][key].maps[20].frame)
        assert.is_nil(cache.owners[owner][key].maps[10])
        assert.is_nil(cache.owners[owner][sibling.key])
        assert.are_equal(3, #renderer.freeFrames)
        assert.are_same({}, renderer.activeFrames)
        assert.are_same({}, renderer.hoverFrames)
        assert.is_nil(renderer.hoverDriver.scripts.OnUpdate)

        failMotionFrame = nil
        cache:Release(owner)
        cache:Release(owner)

        assert.is_nil(cache.owners[owner])
        assert.are_equal(0, Count(renderer.ownedFrames))
        assert.are_equal(4, #renderer.freeFrames)
        assert.are_equal(8, #renderer.freeFills)
        assert.are_equal(12, #renderer.freeBorders)
    end)

    it("retries a failed polygon release across maps without touching its visible sibling", function()
        local sibling = {owner = owner, key = {}, source = source, sourceMapId = 10, points = source, color = {1, 0, 0}}
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        assert.is_true(cache:Present(20, {shape, sibling}, 1000, 500, 8))
        local failedView, siblingView = renderer.activeFrames[1], renderer.activeFrames[2]
        failMotionFrame = failedView.id

        assert.has_error(function() cache:Release(owner, key) end, "native motion failed")

        assert.is_false(failedView.shown)
        assert.is_true(siblingView.shown)
        assert.are_equal(2, Count(renderer.ownedFrames))
        assert.are_equal(1, Count(cache.owners[owner][key].maps))
        assert.are_equal(failedView, cache.owners[owner][key].maps[20].frame)
        assert.are_equal(siblingView, cache.owners[owner][sibling.key].maps[20].frame)
        assert.are_equal(1, #renderer.freeFrames)

        failMotionFrame = nil
        cache:Release(owner, key)
        cache:Release(owner, key)

        assert.is_nil(cache.owners[owner][key])
        assert.is_true(siblingView.shown)
        assert.are_equal(1, Count(renderer.ownedFrames))
        assert.are_equal(2, #renderer.freeFrames)
        assert.are_equal(4, #renderer.freeFills)
        assert.are_equal(6, #renderer.freeBorders)
        assert.are_same({siblingView}, renderer.activeFrames)
    end)

    it("attempts all old destinations on failed source invalidation and keeps native cleanup retryable", function()
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        local failedView = renderer.activeFrames[1]
        assert.is_true(cache:Present(20, {shape}, 1000, 500, 8))
        local projectedView = renderer.activeFrames[1]
        failMotionFrame = failedView.id
        shape.source = {{x = 30, y = 30}, {x = 40, y = 30}, {x = 30, y = 40}}
        shape.points = shape.source

        local success, err = cache:Present(20, {shape}, 1000, 500, 8)

        assert.is_nil(success)
        assert.matches("native motion failed", err)
        assert.matches("cleanup failed", err)
        assert.are_same({}, cache.owners)
        assert.is_false(failedView.shown)
        assert.is_false(projectedView.shown)
        assert.are_equal(1, Count(renderer.ownedFrames))
        assert.is_true(renderer.ownedFrames[failedView])
        assert.are_equal(1, #renderer.freeFrames)

        failMotionFrame = nil
        cache:Clear()
        cache:Clear()

        assert.are_equal(0, Count(renderer.ownedFrames))
        assert.are_equal(2, #renderer.freeFrames)
        assert.is_true(cache:Present(20, {shape}, 1000, 500, 8))
    end)

    it("reports creation and cleanup failures without losing native ownership, then retries cleanup", function()
        local sibling = {owner = owner, key = {}, source = source, sourceMapId = 10, points = source, color = {1, 0, 0}}
        failMotionFrame = 2 -- The second view fails before the batch creates a hover driver.

        local success, err = cache:Present(10, {shape, sibling}, 1000, 500, 8)

        assert.is_nil(success)
        assert.matches("native motion failed", err)
        assert.matches("cleanup failed", err)
        assert.are_same({}, cache.owners)
        assert.are_equal(1, Count(renderer.ownedFrames))
        assert.is_true(renderer.ownedFrames[nativeFrames[2]])
        assert.is_false(nativeFrames[2].shown)
        assert.are_equal(1, #renderer.freeFrames)
        failMotionFrame = nil
        cache:Clear()
        assert.are_equal(0, Count(renderer.ownedFrames))
        assert.are_equal(2, #renderer.freeFrames)
        assert.is_true(cache:Present(10, {shape}, 1000, 500, 8))
        assert.are_equal(1, #renderer.activeFrames)
    end)
end)
