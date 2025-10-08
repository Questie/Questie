---@type Tutorial
local Tutorial = QuestieLoader:ImportModule("Tutorial")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

function Tutorial.ShowRunes()
    local baseFrame = CreateFrame("Frame", "QuestieTutorialShowRunes", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    baseFrame:SetSize(525, 240)
    baseFrame:SetPoint("CENTER", 0, 50)
    baseFrame:SetFrameStrata("HIGH")
    baseFrame:EnableMouse(true)
    baseFrame:SetMovable(true)
    baseFrame:RegisterForDrag("LeftButton")
    baseFrame:SetScript("OnDragStart", baseFrame.StartMoving)
    baseFrame:SetScript("OnDragStop", baseFrame.StopMovingOrSizing)
    baseFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    baseFrame:SetBackdropColor(0, 0, 0, 1)
    baseFrame:SetBackdropBorderColor(1, 1, 1, 1)

    local titleText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    titleText:SetText(l10n("Welcome to Questie"))
    titleText:SetFont(STANDARD_TEXT_FONT, 16)
    titleText:SetPoint("TOP", 0, -10)

    local customText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customText:SetText(
        l10n("Questie can show you the locations of runes for your class from previous SoD Phases.\n\n") ..
        l10n("Rune locations are marked with the following symbol:")
    )
    customText:SetPoint("TOP", 0, -35)

    local showRunesIcon = baseFrame:CreateTexture(nil, "OVERLAY")
    showRunesIcon:SetTexture("Interface\\Addons\\Questie\\Icons\\sod_rune.blp")
    showRunesIcon:SetSize(30, 30)
    showRunesIcon:SetPoint("TOP", 0, -85)

    local chooseText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    chooseText:SetText(
        l10n("Please choose if you want to see them or not\n") ..
        l10n("(This can always be changed in the Icons tab of the settings)")
    )
    chooseText:SetPoint("TOP", 0, -125)

    local showPhase1RunesButton = CreateFrame("CheckButton", nil, baseFrame, "ChatConfigCheckButtonTemplate")
    showPhase1RunesButton.Text:SetText(" " .. l10n("Phase 1"))
    showPhase1RunesButton.Text:SetTextColor(1, 0.82, 0)
    showPhase1RunesButton:SetChecked(true)
    showPhase1RunesButton:SetPoint("BOTTOM", -110, 60)

    local showPhase2RunesButton = CreateFrame("CheckButton", nil, baseFrame, "ChatConfigCheckButtonTemplate")
    showPhase2RunesButton.Text:SetText(" " .. l10n("Phase 2"))
    showPhase2RunesButton.Text:SetTextColor(1, 0.82, 0)
    showPhase2RunesButton:SetChecked(true)
    showPhase2RunesButton:SetPoint("BOTTOM", 70, 60)

    local showPhase3RunesButton = CreateFrame("CheckButton", nil, baseFrame, "ChatConfigCheckButtonTemplate")
    showPhase3RunesButton.Text:SetText(" " .. l10n("Phase 3"))
    showPhase3RunesButton.Text:SetTextColor(1, 0.82, 0)
    showPhase3RunesButton:SetChecked(true)
    showPhase3RunesButton:SetPoint("BOTTOM", -110, 40)

    local showPhase4RunesButton = CreateFrame("CheckButton", nil, baseFrame, "ChatConfigCheckButtonTemplate")
    showPhase4RunesButton.Text:SetText(" " .. l10n("Phase 4"))
    showPhase4RunesButton.Text:SetTextColor(1, 0.82, 0)
    showPhase4RunesButton:SetChecked(true)
    showPhase4RunesButton:SetPoint("BOTTOM", 70, 40)

    local confirmButton = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
    confirmButton:SetText(DONE)
    confirmButton:SetSize(80, 24)
    confirmButton:SetPoint("BOTTOM", 0, 15)
    confirmButton:SetScript("OnClick", function()
        local showPhase1Runes = showPhase1RunesButton:GetChecked()
        local showPhase2Runes = showPhase2RunesButton:GetChecked()
        local showPhase3Runes = showPhase3RunesButton:GetChecked()
        local showPhase4Runes = showPhase3RunesButton:GetChecked()

        Questie.db.profile.showSoDRunes = showPhase1Runes or showPhase2Runes or showPhase3Runes or showPhase4Runes
        Questie.db.profile.tutorialShowRunesDone = true

        Questie.db.profile.showRunesOfPhase = {
            phase1 = showPhase1Runes,
            phase2 = showPhase2Runes,
            phase3 = showPhase3Runes,
            phase4 = showPhase4Runes,
            phase5 = false,
        }

        AvailableQuests.CalculateAndDrawAll()
        baseFrame:Hide()
    end)
end
