---------------------------------------------------------------------------------------------------
-- Minimap button creation is in a function so that it can be called upon the ADDON_LOADED event,
-- when SavedVariables (position) are available.
---------------------------------------------------------------------------------------------------
function Questie.CreateMinimapButton()
    Questie.minimapButton = CreateFrame('Button', 'QuestieMinimap', Minimap)
    if (QuestieMinimapPosition == nil) then
        QuestieMinimapPosition = -90
    end

    Questie.minimapButton:SetMovable(true)
    Questie.minimapButton:EnableMouse(true)
    Questie.minimapButton:SetFrameStrata('LOW')
    Questie.minimapButton:SetWidth(31)
    Questie.minimapButton:SetHeight(31)
    Questie.minimapButton:SetFrameLevel(9)
    Questie.minimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
    Questie.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(QuestieMinimapPosition)),(80*sin(QuestieMinimapPosition))-52)

    Questie.minimapButton:RegisterForDrag("LeftButton")
    Questie.minimapButton.draggingFrame = CreateFrame("Frame", "QuestieMinimapDragging", Questie.minimapButton)
    Questie.minimapButton.draggingFrame:Hide();
    Questie.minimapButton.draggingFrame:SetScript("OnUpdate", function()
        local xpos,ypos = GetCursorPosition()
        local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

        xpos = xmin-xpos/UIParent:GetScale()+70
        ypos = ypos/UIParent:GetScale()-ymin-70

        QuestieMinimapPosition = math.deg(math.atan2(ypos,xpos))
        Questie.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(QuestieMinimapPosition)),(80*sin(QuestieMinimapPosition))-52)
    end)
    Questie.minimapButton:SetScript("OnDragStart", function()
        this:LockHighlight();
        Questie.minimapButton.draggingFrame:Show();
    end)
    Questie.minimapButton:SetScript("OnDragStop", function()
        this:UnlockHighlight();
        Questie.minimapButton.draggingFrame:Hide();
    end)

    Questie.minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    Questie.minimapButton:SetScript("OnClick", function()
        if ( arg1 == "LeftButton" ) then
            if not QuestieOptionsForm:IsVisible() then
                Questie:OptionsForm_Display()
            else
                QuestieOptionsForm:Hide()
            end
        end
        if (arg1 == "RightButton") then
            Questie:Toggle()
        end
    end)
    Questie.minimapButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(Questie.minimapButton, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetText("Questie\n\n")
        GameTooltip:AddDoubleLine("<LeftClick>", "Opens Settings UI", 1,1,1, 1,1,0)
        GameTooltip:AddDoubleLine("<RightClick>", "Toggles all notes on/off", 1,1,1, 1,1,0)
        GameTooltip:Show()
    end)
    Questie.minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    Questie.minimapButton.overlay = Questie.minimapButton:CreateTexture(nil, 'OVERLAY')
    Questie.minimapButton.overlay:SetWidth(53)
    Questie.minimapButton.overlay:SetHeight(53)
    Questie.minimapButton.overlay:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
    Questie.minimapButton.overlay:SetPoint('TOPLEFT', 0,0)
    Questie.minimapButton.icon = Questie.minimapButton:CreateTexture(nil, 'BACKGROUND')
    Questie.minimapButton.icon:SetWidth(20)
    Questie.minimapButton.icon:SetHeight(20)
    Questie.minimapButton.icon:SetTexture('Interface\\AddOns\\!Questie\\Icons\\minimapIcon')
    Questie.minimapButton.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    Questie.minimapButton.icon:SetPoint('CENTER',1,1)
end
