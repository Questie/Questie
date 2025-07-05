---@class AutoCompleteFrame
local AutoCompleteFrame = QuestieLoader:CreateModule("AutoCompleteFrame")

local LSM30 = LibStub("LibSharedMedia-3.0")

local MARGIN = 200

local autoCompleteFrame
local trackerBaseFrame

---@param baseFrame table @The Tracker base frame
function AutoCompleteFrame.Initialize(baseFrame)
    trackerBaseFrame = baseFrame
    autoCompleteFrame = CreateFrame("Button", "Questie_AutoComplete_Frame", baseFrame, BackdropTemplateMixin and "BackdropTemplate")

    autoCompleteFrame:SetWidth(200)
    autoCompleteFrame:SetHeight(45)
    autoCompleteFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    -- TODO: Make this configurable
    autoCompleteFrame:SetBackdropColor(0, 0, 0, 1)
    autoCompleteFrame:SetBackdropBorderColor(1, 1, 1, 0)

    local icon = CreateFrame("Button", nil, autoCompleteFrame)
    icon:SetPoint("LEFT", 4, 0)
    icon:SetSize(25, 25);
    icon:SetAlpha(1)
    icon.texture = icon:CreateTexture(nil, "BACKGROUND", nil, 0)
    icon.texture:SetTexture(Questie.icons["complete"])
    icon.texture:SetSize(25, 25);
    icon.texture:SetPoint("LEFT", 4, 0)

    local trackerFontSizeZone = Questie.db.profile.trackerFontSizeZone
    local font = LSM30:Fetch("font", Questie.db.profile.trackerFontZone)

    autoCompleteFrame.questTitle = autoCompleteFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    autoCompleteFrame.questTitle:SetFont(font, trackerFontSizeZone, Questie.db.profile.trackerFontOutline)
    autoCompleteFrame.questTitle:SetPoint("TOP", 0, -10)

    autoCompleteFrame.hintText = autoCompleteFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    autoCompleteFrame.hintText:SetFont(font, 10, Questie.db.profile.trackerFontOutline)
    autoCompleteFrame.hintText:SetText(QUEST_WATCH_POPUP_CLICK_TO_COMPLETE) -- "Click to complete quest"
    autoCompleteFrame.hintText:SetPoint("TOP", 0, -25)

    autoCompleteFrame:SetScript("OnClick", function()
        ShowQuestComplete(GetQuestLogIndexByID(autoCompleteFrame.questId))
        autoCompleteFrame:Hide()
    end)

    AutoCompleteFrame.CheckAutoCompleteQuests()
end

-- /run QuestieLoader:ImportModule("AutoCompleteFrame"):ShowAutoComplete(123)

---@param questId number @The questId to show the auto complete frame for
function AutoCompleteFrame.ShowAutoComplete(questId)
    local questTitle = GetQuestLogTitle(GetQuestLogIndexByID(questId))
    autoCompleteFrame.questTitle:SetText(questTitle)
    autoCompleteFrame.questId = questId

    local anchor, _, _, xOfs, _ = trackerBaseFrame:GetPoint()
    local screenCenter = (GetScreenWidth() * UIParent:GetEffectiveScale()) / 2

    local isTrackerOnTheRight = xOfs > screenCenter
    if anchor == "BOTTOMRIGHT" or anchor == "TOPRIGHT" or anchor == "TOP" or anchor == "BOTTOM" then
        isTrackerOnTheRight = xOfs > -screenCenter
    end

    autoCompleteFrame:ClearAllPoints()
    if isTrackerOnTheRight then
        autoCompleteFrame:SetPoint("TOPLEFT", trackerBaseFrame, -MARGIN, 0)
    else
        autoCompleteFrame:SetPoint("TOPRIGHT", trackerBaseFrame, MARGIN, 0)
    end

    autoCompleteFrame:Show()
end

function AutoCompleteFrame.CheckAutoCompleteQuests()
    if (not Questie.db.profile.trackerEnabled) then
        return
    end

    if GetNumAutoQuestPopUps() > 0 then -- returns the number of quests that can be completed automatically
        -- TODO: Handle multiple quests
        local questId = GetAutoQuestPopUp(1)
        AutoCompleteFrame.ShowAutoComplete(questId)
    elseif autoCompleteFrame then -- The QUEST_REMOVED event might fire before the auto quest pop up is initialized
        autoCompleteFrame:Hide()
    end
end

return AutoCompleteFrame
