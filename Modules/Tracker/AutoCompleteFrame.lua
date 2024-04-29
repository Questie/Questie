---@class AutoCompleteFrame
local AutoCompleteFrame = QuestieLoader:CreateModule("AutoCompleteFrame")

local LSM30 = LibStub("LibSharedMedia-3.0")

local autoCompleteFrame

---@param baseFrame table @The Tracker base frame
function AutoCompleteFrame.Initialize(baseFrame)
    autoCompleteFrame = CreateFrame("Button", "Questie_AutoComplete_Frame", baseFrame, BackdropTemplateMixin and "BackdropTemplate")

    autoCompleteFrame:SetWidth(200)
    autoCompleteFrame:SetHeight(45)
    autoCompleteFrame:SetPoint("TOPLEFT", "Questie_BaseFrame", -200, 0)
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

---@param questId number @The questId to show the auto complete frame for
function AutoCompleteFrame.ShowAutoComplete(questId)
    local questTitle = GetQuestLogTitle(GetQuestLogIndexByID(questId))
    autoCompleteFrame.questTitle:SetText(questTitle)
    autoCompleteFrame.questId = questId
    autoCompleteFrame:Show()
end

function AutoCompleteFrame.CheckAutoCompleteQuests()
    if GetNumAutoQuestPopUps() > 0 then -- returns the number of quests that can be completed automatically
        -- TODO: Handle multiple quests
        local questId = GetAutoQuestPopUp(1)
        AutoCompleteFrame.ShowAutoComplete(questId)
    else
        autoCompleteFrame:Hide()
    end
end
