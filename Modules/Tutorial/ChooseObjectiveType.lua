---@type Tutorial
local Tutorial = QuestieLoader:ImportModule("Tutorial")

---@return Frame
function Tutorial.CreateChooseObjectiveTypeFrame()
    local baseFrame = CreateFrame("Frame", "QuestieTutorialChooseObjectiveType", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    baseFrame:SetSize(600, 400)
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
    titleText:SetText("Welcome to Questie")
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 16)
    titleText:SetPoint("TOP", 0, -10)

    local customText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customText:SetText("With Wotlk Phase 4 Blizzard introduced their own quest objective system.\n\nPlease choose the objective type you want to use:")
    customText:SetPoint("TOP", 0, -35)

    local onlyQuestieImage = baseFrame:CreateTexture(nil, "OVERLAY")
    onlyQuestieImage:SetTexture("Interface\\Addons\\Questie\\Modules\\Tutorial\\onlyQuestie.blp")
    onlyQuestieImage:SetSize(256, 256)
    onlyQuestieImage:SetPoint("TOPLEFT", 30, -90)

    local onlyBlizzardImage = baseFrame:CreateTexture(nil, "OVERLAY")
    onlyBlizzardImage:SetTexture("Interface\\Addons\\Questie\\Modules\\Tutorial\\onlyBlizzard.blp")
    onlyBlizzardImage:SetSize(256, 256)
    onlyBlizzardImage:SetPoint("TOPRIGHT", -30, -90)

    local acceptOnlyQuestieButton = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
    acceptOnlyQuestieButton:SetText("Questie Objectives")
    acceptOnlyQuestieButton:SetSize(140, 24)
    acceptOnlyQuestieButton:SetPoint("BOTTOMLEFT", 85, 20)
    acceptOnlyQuestieButton:SetScript("OnClick", function()
        if GetCVar("questPOI") ~= nil then
            SetCVar("questPOI", "0") -- Disable the the new Blizzard quest objectives
            if WorldMapQuestShowObjectives then
                WorldMapQuestShowObjectives:SetChecked(false) -- Disable the checkbox added for it
            end
        end
        baseFrame:Hide()
        Questie.db.char.tutorialObjectiveTypeChosen = true
    end)

    local acceptOnlyBlizzardButton = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
    acceptOnlyBlizzardButton:SetText("Blizzard Objectives")
    acceptOnlyBlizzardButton:SetSize(140, 24)
    acceptOnlyBlizzardButton:SetPoint("BOTTOMRIGHT", -85, 20)
    acceptOnlyBlizzardButton:SetScript("OnClick", function()
        if GetCVar("questPOI") ~= nil then
            SetCVar("questPOI", "1") -- Enable the the new Blizzard quest objectives
            if WorldMapQuestShowObjectives then
                WorldMapQuestShowObjectives:SetChecked(true) -- Enable the checkbox added for it
            end
        end
        Questie.db.global.enableObjectives = false
        baseFrame:Hide()
        Questie.db.char.tutorialObjectiveTypeChosen = true
    end)
end
