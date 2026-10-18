---@type Tutorial
local Tutorial = QuestieLoader:ImportModule("Tutorial")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type ObjectivePreview
local ObjectivePreview = QuestieLoader:ImportModule("ObjectivePreview")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local PREVIEW_SIZE = ObjectivePreview.SIZE
local COLUMN_STEP = PREVIEW_SIZE + 20 -- A preview's width and the gap to the next.
local PICTURES = "Interface\\Addons\\Questie\\Modules\\Tutorial\\"

local function _LinkPreviewToButton(preview, button)
    preview:RegisterForClicks("LeftButtonUp")
    preview:SetScript("OnClick", button:GetScript("OnClick"))

    local border = CreateFrame("Frame", nil, preview, "BackdropTemplate")
    border:SetPoint("TOPLEFT", -4, 4)
    border:SetPoint("BOTTOMRIGHT", 4, -4)
    border:SetFrameLevel(preview:GetFrameLevel() + 10) -- Above a live preview's map.
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

---A live map of the style. Should building it fail, the error goes to the error handler with its stack and
---the popup still offers the choice, over the fallback picture if there is one.
---@param parent Frame
---@param style ObjectivePreviewStyle
---@param fallbackPicture string?
---@return Button
local function _CreatePreview(parent, style, fallbackPicture)
    local ok, preview = xpcall(function() return ObjectivePreview.Create(parent, style) end, CallErrorHandler)
    if ok then return preview end
    preview = CreateFrame("Button", nil, parent)
    preview:SetSize(PREVIEW_SIZE, PREVIEW_SIZE)
    if fallbackPicture then preview:SetNormalTexture(fallbackPicture) end
    return preview
end

function Tutorial.CreateChooseObjectiveTypeFrame()
    -- Blizzard's own quest objectives came with WotLK Phase 4, and Forever has them too.
    local hasBlizzardObjectives = ((Expansions.Current >= Expansions.Wotlk) or Questie.IsForever) and GetCVar("questPOI") ~= nil
    local choices = {
        {label = "Questie Objectives", preset = "questie", preview = function(parent)
            return _CreatePreview(parent, "icons", PICTURES .. "onlyQuestie.blp")
        end},
        {label = "Questie blobs", preset = "polygon", preview = function(parent)
            return _CreatePreview(parent, "blobs")
        end},
    }
    if hasBlizzardObjectives then
        choices[#choices + 1] = {label = "Blizzard Objectives", preset = "blizzard", preview = function(parent)
            local picture = CreateFrame("Button", nil, parent)
            picture:SetNormalTexture(PICTURES .. "onlyBlizzard.blp")
            picture:SetSize(PREVIEW_SIZE, PREVIEW_SIZE)
            return picture
        end}
    end
    local width = 40 + #choices * COLUMN_STEP

    local baseFrame = CreateFrame("Frame", "QuestieTutorialChooseObjectiveType", UIParent)
    baseFrame:SetSize(width, 400)
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
    elseif hasBlizzardObjectives then
        customText:SetText(l10n("With WotLK Phase 4 Blizzard introduced their own quest objective system.\n\nPlease choose the objective style you want to use:"))
    else
        customText:SetText(l10n("Questie can show quest objectives as icons or as areas.\n\nPlease choose the objective style you want to use:"))
    end
    customText:SetWidth(width - 60)
    customText:SetPoint("TOP", 0, -54)

    for index, choice in ipairs(choices) do
        local preview = choice.preview(baseFrame)
        preview:SetPoint("TOPLEFT", 30 + (index - 1) * COLUMN_STEP, -112)

        local button = CreateFrame("Button", nil, baseFrame, "UIPanelButtonTemplate")
        button:SetText(l10n(choice.label))
        button:SetSize(180, 28)
        button:SetPoint("TOP", preview, "BOTTOM", 0, -16)
        button:SetScript("OnClick", function()
            Questie.db.global.tutorialObjectiveStyleWithBlobsChosen = true
            QuestieOptionsUtils.ExecuteTheme(nil, choice.preset)
            baseFrame:Hide()
        end)
        _LinkPreviewToButton(preview, button)
    end
end
