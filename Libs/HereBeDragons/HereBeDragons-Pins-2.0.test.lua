dofile("setupTests.lua")

describe("HereBeDragons-Pins world-map icon removal", function()
    local globalNames = {"CreateFrame", "CreateFromMixins", "MapCanvasDataProviderMixin", "MapCanvasPinMixin",
        "CreateUnsecuredRegionPoolInstance", "CreateFramePool", "Minimap", "GetCVar", "WorldMapFrame", "C_Minimap"}
    local savedGlobals
    local pins
    local map

    local function CreateIcon()
        return {
            SetParent = function() end,
            ClearAllPoints = function() end,
            SetPoint = function() end,
            Show = function() end,
            Hide = function() end,
        }
    end

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end

        map = {
            activePins = {},
            enumerateCount = 0,
        }
        function map:AcquirePin(_, icon, x, y, frameLevelType)
            local pin = setmetatable({
                UseFrameLevelType = function() end,
                SetPosition = function() end,
            }, {__index = pins.worldmapProviderPin})
            pin:OnAcquired(icon, x, y, frameLevelType)
            self.activePins[pin] = true
            return pin
        end
        function map:RemovePin(pin)
            self.activePins[pin] = nil
            pin:OnReleased()
        end
        function map:EnumeratePinsByTemplate()
            self.enumerateCount = self.enumerateCount + 1
            return pairs(self.activePins)
        end

        local frame = {SetScript = function() end, UnregisterAllEvents = function() end, RegisterEvent = function() end}
        QuestieLoader:ImportModule("HBD").RegisterCallback = function() end
        _G.CreateFrame = function() return frame end
        _G.CreateFromMixins = function(mixin)
            local copy = {}
            for k, v in pairs(mixin) do
                copy[k] = v
            end
            return copy
        end
        _G.MapCanvasDataProviderMixin = {GetMap = function() return map end}
        _G.MapCanvasPinMixin = {}
        _G.CreateUnsecuredRegionPoolInstance = nil
        _G.CreateFramePool = function() return {} end
        _G.C_Minimap = nil
        _G.Minimap = {GetZoom = function() return 0 end}
        _G.GetCVar = function() return "0" end
        _G.WorldMapFrame = {
            GetCanvas = function() return {} end,
            pinPools = {},
            AddDataProvider = function() end,
        }

        dofile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")
        pins = QuestieLoader:ImportModule("HBDPins")
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
    end)

    -- Another addon that copied this file kept Questie's template name, so both shared one pool and
    -- Questie's tooltip walked the other addon's pins.
    it("should name its world map pin pool after the addon that loads it", function()
        loadfile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")("OtherAddon")

        assert.are.equal("HereBeDragonsPins-OtherAddon-WorldMapPin", pins.worldmapPinTemplate)
        assert.are.equal(pins.worldmapPinsPool, WorldMapFrame.pinPools["HereBeDragonsPins-OtherAddon-WorldMapPin"])
    end)

    it("should remove only the pin of the given icon without scanning all pins", function()
        local ref = {}
        local removedIcon = CreateIcon()
        local keptIcon = CreateIcon()
        pins.worldmapPinRegistry[ref] = {[removedIcon] = true, [keptIcon] = true}
        local removedPin = map:AcquirePin(pins.worldmapPinTemplate, removedIcon, 0.1, 0.1)
        local keptPin = map:AcquirePin(pins.worldmapPinTemplate, keptIcon, 0.2, 0.2)

        pins:RemoveWorldMapIcon(ref, removedIcon)

        assert.is_nil(map.activePins[removedPin])
        assert.is_true(map.activePins[keptPin])
        assert.are.equal(keptIcon, keptPin.icon)
        assert.are.equal(0, map.enumerateCount)
    end)

    it("should not remove a reused pin when its former icon is removed", function()
        local ref = {}
        local oldIcon = CreateIcon()
        local newIcon = CreateIcon()
        pins.worldmapPinRegistry[ref] = {[oldIcon] = true, [newIcon] = true}
        local pin = map:AcquirePin(pins.worldmapPinTemplate, oldIcon, 0.1, 0.1)
        map:RemovePin(pin)
        map.activePins[pin] = true
        pin:OnAcquired(newIcon, 0.2, 0.2)

        pins:RemoveWorldMapIcon(ref, oldIcon)

        assert.is_true(map.activePins[pin])
        assert.are.equal(newIcon, pin.icon)
    end)

    it("should release the previous pin when an icon is handled again", function()
        local icon = CreateIcon()
        local oldPin = map:AcquirePin(pins.worldmapPinTemplate, icon, 0.1, 0.1)
        map.GetMapID = function() return nil end
        pins.worldmapProvider.GetMap = function() return map end

        pins.worldmapProvider:HandlePin(icon, {})

        assert.is_nil(map.activePins[oldPin])
    end)
end)

describe("HereBeDragons optional world-map child presentation", function()
    local library, pin, icon, savedGlobals
    local globalNames = {"CreateFrame", "CreateFramePool", "CreateUnsecuredRegionPoolInstance", "CreateFromMixins",
        "MapCanvasDataProviderMixin", "MapCanvasPinMixin", "WorldMapFrame", "Minimap", "GetCVar", "UIParent", "Mixin", "C_Minimap",
        "HBD_PINS_WORLDMAP_SHOW_CURRENT", "HBD_PINS_WORLDMAP_SHOW_PARENT", "HBD_PINS_WORLDMAP_SHOW_CONTINENT", "HBD_PINS_WORLDMAP_SHOW_WORLD"}

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do savedGlobals[name] = _G[name] end
        QuestieLoader:ImportModule("HBD").RegisterCallback = function() end
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
        _G.C_Minimap = nil
        dofile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")
        library = QuestieLoader:ImportModule("HBDPins")
        pin = CreateFromMixins(library.worldmapProviderPin)
        pin.pinTemplate = library.worldmapPinTemplate
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
        otherPin.pinTemplate = library.worldmapPinTemplate
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

    it("reports the minimap view icons are placed with, with and without the radius API", function()
        -- Loaded without C_Minimap.GetViewRadius: the outdoor zoom table, halved to a radius.
        _G.Minimap.GetZoom = function() return 3 end
        assert.are.same({(266 + 2/6) / 2, false}, {library:GetMinimapView()})
        _G.Minimap.GetZoom = function() return 9 end
        assert.is_nil((library:GetMinimapView()))

        _G.C_Minimap = {GetViewRadius = function() return 150 end}
        dofile("Libs/HereBeDragons/HereBeDragons-Pins-2.0.lua")
        assert.are.same({150, false}, {library:GetMinimapView()})
    end)
end)
