---@class DebugPinMixin : BasePinMixin, Button
---@field lineCornerPoints {[1]: XYPoint, [2]: XYPoint, [3]: XYPoint, [4]: XYPoint} @The points of the line corners, values between 0-1 is expected
local DebugPinMixin = QuestieLoader:CreateModule("DebugPinMixin")

----- System Imports -----
---@type MapEventBus
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")
---@type MapCoordinates
local MapCoordinates = QuestieLoader:ImportModule("MapCoordinates")

---@type FramePoolWaypoint
local FramePoolWaypoint = QuestieLoader:ImportModule("FramePoolWaypoint")

---@type PinTemplates
local PinTemplates = QuestieLoader:ImportModule("PinTemplates")

----- Imports -----
local QuestieQuest = QuestieLoader:ImportModule("QQuest")
local MapTooltip = QuestieLoader:ImportModule("MapTooltip")

local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
local l10n = QuestieLoader:ImportModule("l10n")
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
local QuestieEVent = QuestieLoader:ImportModule("QuestieEvent")


--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip
local wipe = wipe

function DebugPinMixin:GetType()
    return "DebugPin"
end

function DebugPinMixin:OnAcquired()
    local uiMapId = self.data and self.data.uiMapId and self.data.uiMapId or nil
    local normalScale = (self:GetIconScale(uiMapId) or 1)
    local zoomedScale = (normalScale * 1.2)

    self:SetScalingLimits(1, normalScale, zoomedScale)
end

---Get the IconScale for the pin, use UiMapId to get the scale for a specific map
---@param uiMapId UiMapId?
---@return number
function DebugPinMixin:GetIconScale(uiMapId)    --? Scale the icon based on what mapType it is
    local mapTypeScale = 1
    if uiMapId then
        local mapData = MapCoordinates.MapInfo[uiMapId]
        if mapData.mapType == 1 then -- World
            mapTypeScale = 0.8
        elseif mapData.mapType == 2 then -- Continent
            mapTypeScale = 0.9
        end
    end
    return ((1) * (Questie.db.global.globalScale or 0.6)) * mapTypeScale
end

function DebugPinMixin:OnReleased()

end

function DebugPinMixin:OnClick(button)
    -- Override in your mixin, called when this pin is clicked
end

function DebugPinMixin:OnMouseUp()

end

function DebugPinMixin:OnTooltip()

end

function DebugPinMixin:OnMouseEnter()
    print("OnMouseLeave")
end

function DebugPinMixin:OnMouseLeave()
    print("OnMouseLeave")
end
