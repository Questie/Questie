---@class QuestFocusButton
local QuestFocusButton = QuestieLoader:CreateModule("QuestFocusButton")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerMapEligibility
local TrackerMapEligibility = QuestieLoader:ImportModule("TrackerMapEligibility")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

local ICON_PATH = "Interface\\AddOns\\Questie\\Icons\\"

QuestFocusButton.TEXTURES = {
    incomplete = ICON_PATH .. "poi_incomplete.png",
    incompleteFocused = ICON_PATH .. "poi_incomplete_focused.png",
    complete = ICON_PATH .. "poi_complete.png",
    completeFocused = ICON_PATH .. "poi_complete_focused.png",
}

---Same size as the quest focus button slot in TrackerLayout.
---@return number
local function _GetButtonSize()
    return Questie.db.profile.trackerFontSizeQuest + 3
end

---The quest this button super tracked itself, so it stays focused while following Blizzard is disabled.
---@type QuestId?
local buttonSuperTrackedQuestId

---Super tracked by Blizzard, but only counts when following is enabled or this button selected it.
---@param questId QuestId
---@return boolean
local function _IsSuperTracked(questId)
    local superTrackedQuestId = QuestieCompat.GetSuperTrackedQuestID()
    if buttonSuperTrackedQuestId and buttonSuperTrackedQuestId ~= superTrackedQuestId then
        -- Something else replaced the selection of this button.
        buttonSuperTrackedQuestId = nil
    end
    if superTrackedQuestId ~= questId then
        return false
    end
    return Questie.db.profile.trackerFollowSuperTracking or buttonSuperTrackedQuestId == questId
end

---Focused in Questie, or super tracked by Blizzard, which also covers quests missing from the Questie database.
---@param questId QuestId
---@return boolean
local function _IsFocused(questId)
    return Questie.db.char.TrackerFocus == questId or _IsSuperTracked(questId)
end

local function _OnClick(self)
    if Questie.db.char.TrackerFocus == self.questId then
        TrackerUtils:UnFocus()
        QuestieQuest.ToggleQuestNotes(true)
    elseif _IsSuperTracked(self.questId) then
        buttonSuperTrackedQuestId = nil
        QuestieCompat.ClearSuperTrackedQuest()
    elseif TrackerUtils:FocusQuest(self.questId, self.expectedQuest) then
        QuestieQuest.ToggleQuestNotes(false)
        if WorldMapFrame and WorldMapFrame:IsShown() then
            TrackerUtils.ShowQuestOnMap(self.questId, self.expectedQuest)
        end
    else
        -- Questie can not focus the quest, e.g. it is missing from the database; Blizzard super tracking still can.
        buttonSuperTrackedQuestId = self.questId
        QuestieCompat.SetSuperTrackedQuestID(self.questId)
        if WorldMapFrame and WorldMapFrame:IsShown() then
            -- Without Questie's map data, Blizzard's map of the quest is the best target. There are no Questie icons to flash.
            local uiMapId = QuestieCompat.GetQuestUiMapID(self.questId)
            if uiMapId then
                QuestieCompat.OpenWorldMap(uiMapId)
            end
        end
    end
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

local function _OnEnter()
    TrackerFadeTicker.Unfade()
end

local function _OnLeave()
    TrackerFadeTicker.Fade()
end

---@param index number
---@param parent TrackerLineFrame
---@return Button
function QuestFocusButton.New(index, parent)
    local button = CreateFrame("Button", "linePool.questFocus" .. index, parent)
    button:SetFrameLevel(100)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")

    ---@param quest TrackerQuest
    ---@param isComplete boolean
    function button:SetQuest(quest, isComplete)
        self.questId = quest.Id
        self.expectedQuest = quest.enrichment

        local isFocused = _IsFocused(quest.Id)
        local canFocus = QuestieCompat.IsSuperTrackingSupported() or C_CVar.GetCVar("questPOI") == "0" or TrackerMapEligibility.GetCapabilities(quest).canFocusQuest
        -- A focused quest keeps its button even when it lost eligibility, so it can still be unfocused.
        if (not Questie.db.profile.trackerShowQuestFocusButtons) or (GetCVar("questPOI") == "0") or (not (canFocus or isFocused)) then
            self:Hide()
            return
        end

        local size = _GetButtonSize()
        self:SetWidth(size)
        self:SetHeight(size)
        local texture
        if isComplete then
            texture = isFocused and QuestFocusButton.TEXTURES.completeFocused or QuestFocusButton.TEXTURES.complete
        else
            texture = isFocused and QuestFocusButton.TEXTURES.incompleteFocused or QuestFocusButton.TEXTURES.incomplete
        end
        self:SetNormalTexture(texture)
        -- The icon itself added on top brightens it while hovered
        self:SetHighlightTexture(texture, "ADD")
        self:Show()
    end

    button:SetScript("OnClick", _OnClick)
    button:SetScript("OnEnter", _OnEnter)
    button:SetScript("OnLeave", _OnLeave)

    if Questie.db.profile.trackerFadeQuestFocusButtons then
        button:SetAlpha(0)
    end

    button:Hide()

    return button
end
