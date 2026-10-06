dofile("setupTests.lua")

describe("HereBeDragons optional world-map child presentation", function()
    local library, pin, icon, savedGlobals, oldversion
    local globalNames = {"LibStub", "CreateFrame", "CreateFramePool", "CreateUnsecuredRegionPoolInstance", "CreateFromMixins",
        "MapCanvasDataProviderMixin", "MapCanvasPinMixin", "WorldMapFrame", "Minimap", "GetCVar", "UIParent", "Mixin",
        "HBD_PINS_WORLDMAP_SHOW_CURRENT", "HBD_PINS_WORLDMAP_SHOW_PARENT", "HBD_PINS_WORLDMAP_SHOW_CONTINENT", "HBD_PINS_WORLDMAP_SHOW_WORLD"}

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do savedGlobals[name] = _G[name] end
        library, oldversion = {}, nil
        local hbd = {RegisterCallback = function() end}
        _G.LibStub = setmetatable({NewLibrary = function() return library, oldversion end}, {__call = function() return hbd end})
        _G.CreateFrame = function()
            return {SetScript = function() end, UnregisterAllEvents = function() end, RegisterEvent = function() end}
        end
        _G.CreateFramePool = function() return {} end
        _G.CreateUnsecuredRegionPoolInstance = nil
        _G.CreateFromMixins = function(base)
            local result = {}
            for key, value in pairs(base) do result[key] = value end
            return result
        end
        _G.Mixin = function(frame, base)
            for key, value in pairs(base) do frame[key] = value end
            return frame
        end
        _G.UIParent = {GetEffectiveScale = function() return 1 end}
        _G.MapCanvasDataProviderMixin = {}
        _G.MapCanvasPinMixin = {
            effectiveScale = 1,
            GetEffectiveScale = function(self) return self.effectiveScale end,
            UseFrameLevelType = function(self, level) self.level = level end,
            SetPosition = function(self, x, y) self.x, self.y = x, y end,
            OnCanvasScaleChanged = function(self)
                -- Native pin scaling is inherited by its child before HBD notifies presentation code.
                self.effectiveScale = self.zoomScale
                self.icon.effectiveScale = self.effectiveScale
            end,
        }
        _G.WorldMapFrame = {pinPools = {}, GetCanvas = function() return {} end, AddDataProvider = function() end,
            IsShown = function() return false end}
        _G.Minimap = {GetZoom = function() return 0 end}
        _G.GetCVar = function() return "0" end
        dofile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")
        pin = CreateFromMixins(library.worldmapProviderPin)
        pin.pinTemplate = "HereBeDragonsPinsTemplateQuestie"
        icon = {data = {ObjectiveIndex = 1, IconScale = 1}, UiMapID = 1426, x = 50, y = 50, effectiveScale = 1, width = 16,
            SetParent = function(self, parent) self.parent = parent end,
            GetParent = function(self) return self.parent end,
            GetEffectiveScale = function(self) return self.effectiveScale end,
            GetWidth = function(self) return self.width end,
            ClearAllPoints = function(self) self.point = nil end,
            GetPoint = function(self) return unpack(self.point or {}) end,
            SetPoint = function(self, ...) self.point = {...} end,
            Show = spy.new(function() end)}
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do _G[name] = savedGlobals[name] end
    end)

    describe("upgrading cached version-16 wrappers", function()
        local pool, activePin, inactivePin, oldAcquired, oldScaleChanged

        before_each(function()
            -- Version 16 copied the mixin into every wrapper. Loading a new library
            -- updates the shared table, not those already-created frame methods.
            oldAcquired = function(self, child, x, y)
                self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
                self:SetPosition(x, y)
                self.icon = child
                child:SetParent(self)
                child:ClearAllPoints()
                child:SetPoint("CENTER", self, "CENTER")
                child:Show()
            end
            oldScaleChanged = MapCanvasPinMixin.OnCanvasScaleChanged
            library.worldmapProviderPin.OnAcquired = oldAcquired
            library.worldmapProviderPin.OnCanvasScaleChanged = oldScaleChanged
            activePin = CreateFromMixins(library.worldmapProviderPin)
            inactivePin = CreateFromMixins(library.worldmapProviderPin)
            activePin.pinTemplate, inactivePin.pinTemplate = "HereBeDragonsPinsTemplateQuestie", "HereBeDragonsPinsTemplateQuestie"
            pool = {
                activeObjects = {[activePin] = true}, inactiveObjects = {inactivePin},
                EnumerateActive = function(self) return pairs(self.activeObjects) end,
                Acquire = function(self)
                    local cached = table.remove(self.inactiveObjects)
                    self.activeObjects[cached] = true
                    return cached
                end,
            }
            library.worldmapPinsPool = pool
            oldversion = 16
        end)

        -- Same assertions across the two actual pool contracts; neither upgrade
        -- should replace native frames or overwrite unrelated copied methods.
        local function CheckUpgradedWrappers()
            local released = activePin.OnReleased
            dofile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")

            assert.are.equal(pool, library.worldmapPinsPool)
            assert.are.equal(released, activePin.OnReleased)
            assert.are.equal(library.worldmapProviderPin.OnAcquired, activePin.OnAcquired)
            assert.are.equal(library.worldmapProviderPin.OnCanvasScaleChanged, activePin.OnCanvasScaleChanged)
            assert.are.equal(library.worldmapProviderPin.OnAcquired, inactivePin.OnAcquired)
            assert.are.equal(library.worldmapProviderPin.OnCanvasScaleChanged, inactivePin.OnCanvasScaleChanged)
            assert.are.equal(1, #pool.inactiveObjects)

            icon.OnWorldMapPinUpdated = spy.new(function(frame, wrapper)
                assert.are.equal(icon, frame)
                assert.are.equal(wrapper, icon:GetParent())
                assert.are.same({"CENTER", wrapper, "CENTER"}, icon.point)
            end)
            activePin:OnAcquired(icon, 0.25, 0.75)
            activePin.zoomScale = 2
            activePin:OnCanvasScaleChanged()
            assert.are.equal(2, icon.effectiveScale)
            assert.spy(icon.OnWorldMapPinUpdated).was.called(2)

            local reused = pool:Acquire()
            assert.are.equal(inactivePin, reused)
            reused:OnAcquired(icon, 0.5, 0.5)
            reused.zoomScale = 3
            reused:OnCanvasScaleChanged()
            assert.are.equal(3, icon.effectiveScale)
            assert.spy(icon.OnWorldMapPinUpdated).was.called(4)
        end

        it("refreshes active and inactive wrappers in the legacy frame pool", function()
            pool.EnumerateInactive = function(self) return ipairs(self.inactiveObjects) end
            _G.CreateFramePool = spy.new(function() error("An upgrade must retain its existing pool") end)

            CheckUpgradedWrappers()

            assert.spy(_G.CreateFramePool).was.not_called()
        end)

        it("refreshes the unsecured pool's cached inactive array without requiring the removed iterator", function()
            _G.CreateUnsecuredRegionPoolInstance = spy.new(function() error("An upgrade must retain its existing pool") end)

            CheckUpgradedWrappers()

            assert.spy(_G.CreateUnsecuredRegionPoolInstance).was.not_called()
        end)
    end)

    it("keeps ordinary icons centered without a presentation callback", function()
        pin:OnAcquired(icon, 0.25, 0.75)
        assert.are.same({"CENTER", pin, "CENTER"}, icon.point)
        assert.are.same({0.25, 0.75}, {pin.x, pin.y})
        assert.are.equal(icon, pin.icon)
        assert.spy(icon.Show).was.called(1)
    end)

    it("notifies only after assigning the geographic position, parent and final child anchor", function()
        icon.OnWorldMapPinUpdated = spy.new(function(frame, wrapper)
            assert.are.equal(icon, frame)
            assert.are.equal(pin, wrapper)
            assert.are.equal(pin, icon.parent)
            assert.are.same({0.25, 0.75}, {pin.x, pin.y})
            assert.are.same({"CENTER", pin, "CENTER"}, icon.point)
        end)
        pin:OnAcquired(icon, 0.25, 0.75)
        assert.spy(icon.OnWorldMapPinUpdated).was.called_with(icon, pin)
    end)

    it("keeps fixed slots proportional to displayed icon width through acquisition, zoom and reacquisition", function()
        dofile("Polygon/PolygonNudging.lua")
        local layout = QuestieLoader:ImportModule("PolygonNudging").New()
        local otherIcon = CreateFromMixins(icon)
        otherIcon.Show = spy.new(function() end)
        local otherPin = CreateFromMixins(library.worldmapProviderPin)
        otherPin.pinTemplate = "HereBeDragonsPinsTemplateQuestie"
        local marker = {frame = icon, entry = {quest = {Id = 317}}}
        local other = {frame = otherIcon, entry = {quest = {Id = 384}}}
        icon.polygonMarker, otherIcon.polygonMarker = marker, other
        layout:Update({marker, other}, 1)
        local slots, signature = layout.offsets, layout.signature

        pin:OnAcquired(icon, 0.5, 0.5)
        otherPin:OnAcquired(otherIcon, 0.5, 0.5)
        local separation = otherIcon.point[4] * otherIcon:GetEffectiveScale() - icon.point[4] * icon:GetEffectiveScale()
        assert.are_near(-5.6, icon.point[4], 0.000001)
        assert.are_near(11.2, separation, 0.000001)
        assert.are_near(0.7, separation / (icon:GetWidth() * icon:GetEffectiveScale()), 0.000001)

        -- HBD's normal presentation scale grows both icons by 20%, not their configured width.
        pin.zoomScale, otherPin.zoomScale = 1.2, 1.2
        pin:OnCanvasScaleChanged()
        otherPin:OnCanvasScaleChanged()
        separation = otherIcon.point[4] * otherIcon:GetEffectiveScale() - icon.point[4] * icon:GetEffectiveScale()
        assert.are_near(1.2, pin:GetEffectiveScale(), 0.000001)
        assert.are_near(1.2, icon:GetEffectiveScale(), 0.000001)
        assert.are_near(-5.6, icon.point[4], 0.000001)
        assert.are_near(5.6, otherIcon.point[4], 0.000001)
        assert.are_near(-6.72, icon.point[4] * icon:GetEffectiveScale(), 0.000001)
        assert.are_near(13.44, separation, 0.000001)
        assert.are_near(19.2, icon:GetWidth() * icon:GetEffectiveScale(), 0.000001)
        assert.are_near(0.7, separation / (icon:GetWidth() * icon:GetEffectiveScale()), 0.000001)

        pin:OnAcquired(icon, 0.5, 0.5)
        assert.are_near(-5.6, icon.point[4], 0.000001)
        assert.are_near(-6.72, icon.point[4] * icon:GetEffectiveScale(), 0.000001)
        assert.are.equal(0, icon.point[5])
        assert.spy(icon.Show).was.called(2)
        assert.are.equal(slots, layout.offsets)
        assert.are.equal(signature, layout.signature)
        assert.are.same({0.5, 0.5, 0.5, 0.5}, {pin.x, pin.y, otherPin.x, otherPin.y})
        assert.are.same({50, 50, 1426}, {icon.x, icon.y, icon.UiMapID})
        assert.are.same({50, 50, 1426}, {otherIcon.x, otherIcon.y, otherIcon.UiMapID})
    end)
end)
