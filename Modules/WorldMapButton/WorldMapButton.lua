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

local mapButton

function WorldMapButton.Initialize()
    mapButton = KButtons:Add("QuestieWorldMapButtonTemplate", "BUTTON")

    Questie.WorldMap = {
        Button = mapButton
    }
end

---@param shouldShow boolean
function WorldMapButton.Toggle(shouldShow)
    if shouldShow then
        mapButton:Show()
    else
        mapButton:Hide()
    end
end

QuestieWorldMapButtonMixin = {
    OnLoad = function() end,
    OnHide = function() end,
    OnMouseDown = function(_, button)
        if button == "LeftButton" then
            Questie.db.profile.enabled = (not Questie.db.profile.enabled)
            QuestieQuest:ToggleNotes(Questie.db.profile.enabled)
        elseif button == "RightButton" then
            QuestieMenu:Show()
        end
    end,
    OnMouseUp = function() end,
    OnEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE");
        GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);
        GameTooltip:AddLine("Questie ".. QuestieLib:GetAddonVersionString(), 1, 1, 1)
        GameTooltip:AddLine(Questie:Colorize(l10n('Left Click') , 'gray') .. ": ".. l10n('Toggle Questie'))
        GameTooltip:AddLine(Questie:Colorize(l10n('Right Click') , 'gray') .. ": ".. l10n('Toggle Menu'))
        GameTooltip:Show()
    end,
    OnLeave = function() end,
    OnClick = function() end, -- Only fires on left click
    Refresh = function() end,
}
