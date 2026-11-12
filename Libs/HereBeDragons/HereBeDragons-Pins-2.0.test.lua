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
