---@type Tutorial
local Tutorial = QuestieLoader:ImportModule("Tutorial")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

---@return Frame
function Tutorial.ShowRunes()
    local baseFrame = CreateFrame("Frame", "QuestieTutorialShowRunes", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    baseFrame:SetSize(500, 200)
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
        l10n("Questie can show you the locations of Phase 1 runes for your class.\n\n") ..
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

    local showRunesButton = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
    showRunesButton:SetText(l10n("Yes, show runes"))
    showRunesButton:SetSize(140, 24)
    showRunesButton:SetPoint("BOTTOMLEFT", 60, 15)
    showRunesButton:SetScript("OnClick", function()
        Questie.db.profile.tutorialShowRunesDone = true
        Questie.db.profile.showSoDRunes = true
        AvailableQuests.CalculateAndDrawAll()
        baseFrame:Hide()
    end)

    local hideRunesButton = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
    hideRunesButton:SetText(l10n("No, hide runes"))
    hideRunesButton:SetSize(140, 24)
    hideRunesButton:SetPoint("BOTTOMRIGHT", -60, 15)
    hideRunesButton:SetScript("OnClick", function()
        Questie.db.profile.tutorialShowRunesDone = true
        Questie.db.profile.showSoDRunes = false
        AvailableQuests.CalculateAndDrawAll()
        baseFrame:Hide()
    end)
end
