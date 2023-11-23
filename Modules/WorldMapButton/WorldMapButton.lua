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

function WorldMapButton.UpdateText()
    --if Questie.db.char.enabled then
    --    mapButton:SetText(l10n("Hide Questie"))
    --else
    --    mapButton:SetText(l10n("Show Questie"))
    --end
end

---@param shouldShow boolean
function WorldMapButton.Toggle(shouldShow)
    if shouldShow then
        mapButton:Show();
    else
        mapButton:Hide();
    end
end

function WorldMapButton.UpdatePosition()
    --if (not WorldMapContinentDropDown:IsShown()) then
    --    mapButton:ClearAllPoints()
    --
    --    if IsAddOnLoaded("Leatrix_Maps") then
    --        if AtlasToggleFromWorldMap and AtlasToggleFromWorldMap:IsShown() then -- Atlas addon in Classic Era (see #1498)
    --            mapButton:SetPoint('RIGHT', AtlasToggleFromWorldMap, 'LEFT', -16, 0)
    --        elseif Krowi_WorldMapButtons1 and Krowi_WorldMapButtons1:IsShown() then -- Atlas addon in Wotlk
    --            mapButton:SetPoint('RIGHT', Krowi_WorldMapButtons1, 'LEFT', -16, 0)
    --        else
    --            mapButton:SetPoint('RIGHT', WorldMapFrame.MaximizeMinimizeFrame or WorldMapFrameCloseButton, 'LEFT', 4, 0)
    --        end
    --    else
    --        mapButton:SetPoint('RIGHT', WorldMapFrame.MaximizeMinimizeFrame or WorldMapFrameCloseButton, 'LEFT', 4, 0)
    --    end
    --end
end

QuestieWorldMapButtonMixin = {
    OnLoad = function() end,
    OnHide = function() end,
    OnMouseDown = function(_, button)
        if button == "LeftButton" then
            Questie.db.char.enabled = (not Questie.db.char.enabled)
            QuestieQuest:ToggleNotes(Questie.db.char.enabled)
        elseif button == "RightButton" then
            QuestieMenu:Show()
        end
    end,
    OnMouseUp = function() end,
    OnEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:AddLine("Questie ".. QuestieLib:GetAddonVersionString(), 1, 1, 1);
        GameTooltip:AddLine(Questie:Colorize(l10n('Left Click') , 'gray') .. ": ".. l10n('Toggle Questie'));
        GameTooltip:AddLine(Questie:Colorize(l10n('Right Click') , 'gray') .. ": ".. l10n('Toggle Menu'));
        GameTooltip:Show()
    end,
    OnLeave = function() end,
    OnClick = function() end, -- Only fires on left click
    Refresh = function() end,
}
