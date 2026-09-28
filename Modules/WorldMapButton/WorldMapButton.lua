---@class WorldMapButton
---@field Initialize function
local WorldMapButton = QuestieLoader:CreateModule("WorldMapButton")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")

local KButtons = LibStub("Krowi_WorldMapButtons-1.4")
if Questie.IsForever then
    -- Krowi classifies version 1.x as the old Classic map. Forever has modern overlay buttons;
    -- its old-map workaround reparents them away from the map and breaks GetMapID/TriggerEvent.
    KButtons.HasNoOverlay = false
end

---@type AceConfigDialog-3.0
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local mapButton

-- Forever positions Blizzard's own map buttons itself: the Map Pin on the left side of the map
-- and the Map Filter in the navigation bar. Krowi's layout adds a TOPRIGHT anchor without
-- clearing existing points, which drags them out of place (the Map Pin gets stretched across
-- the whole map header, and its hit area covers other buttons). Keep them out of Krowi's layout.
local function ReleaseBlizzardMapButtons()
    local buttons = KButtons.Buttons
    if not buttons then
        return
    end
    local pinOnLoad = WorldMapTrackingPinButtonMixin and WorldMapTrackingPinButtonMixin.OnLoad
    local optionsOnLoad = WorldMapTrackingOptionsButtonMixin and WorldMapTrackingOptionsButtonMixin.OnLoad
    for i = #buttons, 1, -1 do
        local onLoad = buttons[i].OnLoad
        if onLoad and (onLoad == pinOnLoad or onLoad == optionsOnLoad) then
            table.remove(buttons, i)
        end
    end
end

function WorldMapButton.Initialize()
    mapButton = KButtons:Add("QuestieWorldMapButtonTemplate", "BUTTON")
    if Questie.IsForever then
        ReleaseBlizzardMapButtons()
    end

    Questie.WorldMap = {
        Button = mapButton
    }

    WorldMapButton.Toggle(Questie.db.profile.mapShowHideEnabled)
end

---@param shouldShow boolean
function WorldMapButton.Toggle(shouldShow)
    if shouldShow then
        mapButton:Show()
    else
        mapButton:Hide()
    end
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
    local toggleLabel = Questie.db.profile.enabled and l10n('Hide Questie') or l10n('Show Questie')
    tooltip:AddDoubleLine(Questie:Colorize(l10n('Left Click'), 'lightBlue'), Questie:Colorize(toggleLabel, 'white'))
    tooltip:AddDoubleLine(Questie:Colorize(l10n('Right Click'), 'lightBlue'), Questie:Colorize(l10n('Toggle Menu'), 'white'))
    tooltip:Show()
end

QuestieWorldMapButtonMixin = {
    OnLoad = function() end,
    OnHide = function() end,
    OnMouseDown = function(_, button)
        if button == "LeftButton" then
            Questie.db.profile.enabled = (not Questie.db.profile.enabled)
            QuestieQuest:ToggleNotes(Questie.db.profile.enabled)
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == mapButton then
                UpdateTooltip(mapButton)
            end
            -- Refresh options UI if open to reflect new state
            if _G.QuestieConfigFrame and _G.QuestieConfigFrame:IsShown() then
                AceConfigDialog:Open("Questie", _G.QuestieConfigFrame)
            end
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
