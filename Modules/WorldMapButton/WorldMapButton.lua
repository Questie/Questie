---@class WorldMapButton
---@field Initialize function
local WorldMapButton = QuestieLoader:CreateModule("WorldMapButton")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type MapIconVisibility
local MapIconVisibility = QuestieLoader:ImportModule("MapIconVisibility")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type JourneyPlaces
local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")

local KButtons = LibStub("Krowi_WorldMapButtons-1.4")
if Questie.IsForever then
    -- Krowi classifies version 1.x as the old Classic map. Forever has modern overlay buttons;
    -- its old-map workaround reparents them away from the map and breaks GetMapID/TriggerEvent.
    KButtons.HasNoOverlay = false
end

local mapButton, journeyButton

function WorldMapButton.Initialize()
    mapButton = KButtons:Add("QuestieWorldMapButtonTemplate", "BUTTON")
    journeyButton = KButtons:Add("QuestieJourneyMapButtonTemplate", "BUTTON")

    Questie.WorldMap = {
        Button = mapButton
    }

    WorldMapButton.Toggle(Questie.db.profile.mapShowHideEnabled)
end

---@param shouldShow boolean
function WorldMapButton.Toggle(shouldShow)
    mapButton:SetShown(shouldShow)
    journeyButton:SetShown(shouldShow)
end

---@param self Frame
---@return nil
local function UpdateTooltip(self)
    local tooltip = GameTooltip
    tooltip:SetOwner(self, "ANCHOR_NONE");
    tooltip:ClearLines()
    tooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);
    tooltip:AddDoubleLine(Questie:Colorize("Questie", 'gold'), Questie:Colorize(QuestieLib:GetAddonVersionString(), 'gray'))
    tooltip:AddLine(" ")
    local toggleLabel = MapIconVisibility.IsWorldMapShown() and l10n("Hide Map Icons") or l10n("Show Map Icons")
    tooltip:AddDoubleLine(Questie:Colorize(l10n('Left Click'), 'lightBlue'), Questie:Colorize(toggleLabel, 'white'))
    tooltip:AddDoubleLine(Questie:Colorize(l10n('Right Click'), 'lightBlue'), Questie:Colorize(l10n('Toggle Menu'), 'white'))
    tooltip:Show()
end

QuestieWorldMapButtonMixin = {
    OnLoad = function() end,
    OnHide = function() end,
    OnMouseDown = function(_, button)
        if button == "LeftButton" then
            MapIconVisibility.ToggleWorldMap()
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == mapButton then
                UpdateTooltip(mapButton)
            end
            -- Refresh options UI if open to reflect new state
            QuestieOptionsEngine:RefreshStates()
        elseif button == "RightButton" then
            if QuestieMenu.IsOpen() then
                QuestieMenu:Hide()
            else
                QuestieMenu:Show()
            end
        end
    end,
    OnMouseUp = function() end,
    OnEnter = function(self)
        UpdateTooltip(self)
    end,
    OnLeave = function() end,
    OnClick = function() end, -- Only fires on left click
    Refresh = function() end,
}

-------------------------
-- My Journey
-------------------------

---What the Journey can list for the map that is shown, or for the closest map around it.
---@return JourneyPlace?
---@return string? source
local function GetShownPlace()
    local uiMapId = WorldMapFrame:GetMapID()
    while uiMapId and uiMapId > 0 do
        local zone, continent = JourneyPlaces.GetZoneOfMap(uiMapId), JourneyPlaces.GetContinentOfMap(uiMapId)
        if zone then
            return zone, "zone:" .. zone.id
        elseif continent then
            return continent, "overview:" .. continent.id
        end
        local info = C_Map.GetMapInfo(uiMapId)
        uiMapId = info and info.parentMapID
    end
end

QuestieJourneyMapButtonMixin = {
    OnLoad = function(self)
        self.Icon:SetTexture(JourneyWindow.ICON)
        local crop = JourneyWindow.ICON_CROP
        self.Icon:SetTexCoord(crop, 1 - crop, crop, 1 - crop)
    end,
    OnMouseDown = function()
        GameTooltip:Hide()
        local _, source = GetShownPlace()
        QuestieJourney.OpenSource(source)
    end,
    OnEnter = function(self)
        local place = Questie.started and GetShownPlace()
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0)
        GameTooltip:SetText(l10n("My Journey"), 1, 0.82, 0)
        if place then
            GameTooltip:AddLine(place.name, 1, 1, 1)
        end
        GameTooltip:Show()
    end,
}
