---@class WorldMapButton
---@field Initialize function
local WorldMapButton = QuestieLoader:CreateModule("WorldMapButton")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")

local mapButton

function WorldMapButton.Initialize()
    mapButton = CreateFrame("Button", "Questie_Toggle", WorldMapFrame, "UIPanelButtonTemplate")

    mapButton:SetSize(120, 20)
    mapButton:SetPoint("RIGHT", WorldMapFrame.MaximizeMinimizeFrame or WorldMapFrameCloseButton, "LEFT", 4, 0)
    mapButton:SetFrameLevel(10)
    mapButton:SetScript("OnClick", function()
        Questie.db.char.enabled = (not Questie.db.char.enabled)
        QuestieQuest:ToggleNotes(Questie.db.char.enabled)
    end)

    WorldMapButton.UpdateText()
    WorldMapButton.Toggle(Questie.db.global.mapShowHideEnabled)

    C_Timer.After(1, function()
        WorldMapButton.UpdatePosition()
    end)
end

function WorldMapButton.UpdateText()
    if Questie.db.char.enabled then
        mapButton:SetText(l10n("Hide Questie"))
    else
        mapButton:SetText(l10n("Show Questie"))
    end
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
    if (not WorldMapContinentDropDown:IsShown()) then
        mapButton:ClearAllPoints()

        if IsAddOnLoaded("Leatrix_Maps") then
            if AtlasToggleFromWorldMap and AtlasToggleFromWorldMap:IsShown() then -- Atlas addon in Classic Era (see #1498)
                mapButton:SetPoint('RIGHT', AtlasToggleFromWorldMap, 'LEFT', -16, 0)
            elseif Krowi_WorldMapButtons1 and Krowi_WorldMapButtons1:IsShown() then -- Atlas addon in Wotlk
                mapButton:SetPoint('RIGHT', Krowi_WorldMapButtons1, 'LEFT', -16, 0)
            else
                mapButton:SetPoint('RIGHT', WorldMapFrame.MaximizeMinimizeFrame or WorldMapFrameCloseButton, 'LEFT', 4, 0)
            end
        else
            mapButton:SetPoint('RIGHT', WorldMapFrame.MaximizeMinimizeFrame or WorldMapFrameCloseButton, 'LEFT', 4, 0)
        end
    end
end
