---@class HBDHooks
local HBDHooks = QuestieLoader:CreateModule("HBDHooks");
local _HBDHooks = {}

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")


function HBDHooks:Init()
    --Override OnMapChanged from MapCanvasDataProviderMixin
    -- (https://www.townlong-yak.com/framexml/27101/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua#74)
    --This could in theory be skipped by instead using our own MapCanvasDataProviderMixin
    --The reason i don't is because i want the scaling to happen AFTER HBD has processed all the icons.
    _HBDHooks.ORG_OnMapChanged = HBDPins.worldmapProvider.OnMapChanged;
    HBDPins.worldmapProvider.OnMapChanged = _HBDHooks.OnMapChanged

    if Questie.IsForever then
        HBDHooks.HideWorldMapPinsFromGamepadCursor()
    end
end

local function _ReturnNoCenter()
    return nil
end

-- Blizzard's gamepad map cursor uses the pins it finds outside of secure code, so Questie pins taint the map
-- and block the gamepad UI. It skips pins without a center.
function HBDHooks.HideWorldMapPinsFromGamepadCursor()
    -- New pins copy their fields from this mixin
    HBDPins.worldmapProviderPin.GetCenter = _ReturnNoCenter

    for pin in HBDPins.worldmapProvider:GetMap():EnumeratePinsByTemplate("HereBeDragonsPinsTemplateQuestie") do
        pin.GetCenter = _ReturnNoCenter
    end
end

function _HBDHooks:OnMapChanged()
    --Call original one : https://www.townlong-yak.com/framexml/27101/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua#74
    _HBDHooks.ORG_OnMapChanged(HBDPins.worldmapProvider)

    local mapScale = QuestieMap.GetScaleValue()
    for pin in HBDPins.worldmapProvider:GetMap():EnumeratePinsByTemplate("HereBeDragonsPinsTemplateQuestie") do
        QuestieMap.utils.RescaleIcon(pin.icon, mapScale)
    end
end
