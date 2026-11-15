---@type Tutorial
local Tutorial = QuestieLoader:ImportModule("Tutorial")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")

local function _LinkPreviewToButton(preview, button)
    preview:RegisterForClicks("LeftButtonUp")
    preview:SetScript("OnClick", button:GetScript("OnClick"))

    local border = CreateFrame("Frame", nil, preview, "BackdropTemplate")
    border:SetPoint("TOPLEFT", -4, 4)
    border:SetPoint("BOTTOMRIGHT", 4, -4)
    border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
    border:SetBackdropBorderColor(0.65, 0.65, 0.65, 1)

    local function Highlight()
        border:SetBackdropBorderColor(1, 0.82, 0, 1)
        button:LockHighlight()
    end

    local function ClearHighlight()
        border:SetBackdropBorderColor(0.65, 0.65, 0.65, 1)
        button:UnlockHighlight()
    end

    preview:SetScript("OnEnter", Highlight)
    preview:SetScript("OnLeave", ClearHighlight)
    preview:SetScript("OnHide", ClearHighlight)
    button:SetScript("OnEnter", Highlight)
    button:SetScript("OnLeave", ClearHighlight)
end

function Tutorial.CreateChooseObjectiveTypeFrame()
    local baseFrame = CreateFrame("Frame", "QuestieTutorialChooseObjectiveType", UIParent)
    baseFrame:SetSize(760, 400)
    baseFrame:SetPoint("CENTER", 0, 50)
    baseFrame:SetFrameStrata("HIGH")
    baseFrame:EnableMouse(true)
    baseFrame:SetMovable(true)
    baseFrame:RegisterForDrag("LeftButton")
    baseFrame:SetScript("OnDragStart", baseFrame.StartMoving)
    baseFrame:SetScript("OnDragStop", baseFrame.StopMovingOrSizing)
    CreateFrame("Frame", nil, baseFrame, "DialogBorderDarkTemplate")

    local titleText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetText(l10n("Welcome to Questie"))
    titleText:SetPoint("TOP", 0, -24)

    local customText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    if Questie.IsForever then
        customText:SetText(l10n("With WoW Forever Blizzard introduced their own quest objective system.\n\nPlease choose the objective style you want to use:"))
    else
        customText:SetText(l10n("With WotLK Phase 4 Blizzard introduced their own quest objective system.\n\nPlease choose the objective style you want to use:"))
    end
    customText:SetWidth(700)
    customText:SetPoint("TOP", 0, -54)

    local onlyQuestieImage = CreateFrame("Button", nil, baseFrame)
    onlyQuestieImage:SetNormalTexture("Interface\\Addons\\Questie\\Modules\\Tutorial\\onlyQuestie.blp")
    onlyQuestieImage:SetSize(220, 220)
    onlyQuestieImage:SetPoint("TOPLEFT", 30, -112)

    local pdfQuestImage = CreateFrame("Button", nil, baseFrame)
    pdfQuestImage:SetNormalTexture("Interface\\Addons\\Questie\\Modules\\Tutorial\\pfQuest.blp")
    pdfQuestImage:SetSize(220, 220)
    pdfQuestImage:SetPoint("TOP", 0, -112)

    local onlyBlizzardImage = CreateFrame("Button", nil, baseFrame)
    onlyBlizzardImage:SetNormalTexture("Interface\\Addons\\Questie\\Modules\\Tutorial\\onlyBlizzard.blp")
    onlyBlizzardImage:SetSize(220, 220)
    onlyBlizzardImage:SetPoint("TOPRIGHT", -30, -112)

    local acceptOnlyQuestieButton = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
    acceptOnlyQuestieButton:SetText(l10n("Questie Objectives"))
    acceptOnlyQuestieButton:SetSize(180, 28)
    acceptOnlyQuestieButton:SetPoint("TOP", onlyQuestieImage, "BOTTOM", 0, -16)
    acceptOnlyQuestieButton:SetScript("OnClick", function()
        Questie.db.global.tutorialObjectiveTypeChosen = true
        QuestieOptionsUtils.ExecuteTheme(nil, 'questie')
        baseFrame:Hide()
    end)

    local acceptPfQuestButton = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
    acceptPfQuestButton:SetText(l10n("pfQuest Objectives"))
    acceptPfQuestButton:SetSize(180, 28)
    acceptPfQuestButton:SetPoint("TOP", pdfQuestImage, "BOTTOM", 0, -16)
    acceptPfQuestButton:SetScript("OnClick", function()
        Questie.db.global.tutorialObjectiveTypeChosen = true
        QuestieOptionsUtils.ExecuteTheme(nil, 'pfquest')
        baseFrame:Hide()
    end)

    local acceptOnlyBlizzardButton = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
    acceptOnlyBlizzardButton:SetText(l10n("Blizzard Objectives"))
    acceptOnlyBlizzardButton:SetSize(180, 28)
    acceptOnlyBlizzardButton:SetPoint("TOP", onlyBlizzardImage, "BOTTOM", 0, -16)
    acceptOnlyBlizzardButton:SetScript("OnClick", function()
        Questie.db.global.tutorialObjectiveTypeChosen = true
        QuestieOptionsUtils.ExecuteTheme(nil, 'blizzard')
        baseFrame:Hide()
    end)

    _LinkPreviewToButton(onlyQuestieImage, acceptOnlyQuestieButton)
    _LinkPreviewToButton(pdfQuestImage, acceptPfQuestButton)
    _LinkPreviewToButton(onlyBlizzardImage, acceptOnlyBlizzardButton)
end
