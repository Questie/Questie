---@class ExpandQuestButton
local ExpandQuestButton = QuestieLoader:CreateModule("ExpandQuestButton")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker") -- TODO: Remove this explicit dependency
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---@param index number
---@param parent LineFrame
---@return LineFrame
function ExpandQuestButton.New(index, parent)
    local trackerFontSizeQuest = Questie.db.profile.trackerFontSizeQuest

    local expandQuest = CreateFrame("Button", "linePool.expandQuest" .. index, parent)
    expandQuest.texture = expandQuest:CreateTexture(nil, "OVERLAY", nil, 0)
    expandQuest.texture:SetWidth(trackerFontSizeQuest)
    expandQuest.texture:SetHeight(trackerFontSizeQuest)
    expandQuest.texture:SetAllPoints(expandQuest)

    expandQuest:SetWidth(trackerFontSizeQuest)
    expandQuest:SetHeight(trackerFontSizeQuest)
    expandQuest:SetPoint("RIGHT", parent, "LEFT", 0, 0)
    expandQuest:SetFrameLevel(100)

    function expandQuest:SetMode(mode)
        if mode ~= self.mode then
            self.mode = mode
            if mode == 1 then
                self.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
            else
                self.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
            end
            self:SetWidth(Questie.db.profile.trackerFontSizeQuest + 3)
            self:SetHeight(Questie.db.profile.trackerFontSizeQuest + 3)
        end
    end

    expandQuest:SetMode(1) -- maximized
    expandQuest:EnableMouse(true)
    expandQuest:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    expandQuest:SetScript("OnClick", function(self)
        if self.mode == 1 then
            self:SetMode(0)
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:expandQuest] - Minimize")
        else
            self:SetMode(1)
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:expandQuest] - Maximize")
        end
        if Questie.db.char.collapsedQuests[self.questId] then
            Questie.db.char.collapsedQuests[self.questId] = nil

            -- This keeps both tables in sync so we can use them to maintain Min/Max states.
            if Questie.db.char.minAllQuestsInZone[self.zoneId] and Questie.db.char.minAllQuestsInZone[self.zoneId][self.questId] then
                Questie.db.char.minAllQuestsInZone[self.zoneId][self.questId] = nil
            end
        else
            Questie.db.char.collapsedQuests[self.questId] = true

            -- This keeps both tables in sync so we can use them to maintain Min/Max states.
            if Questie.db.char.minAllQuestsInZone[self.zoneId] then
                Questie.db.char.minAllQuestsInZone[self.zoneId][self.questId] = true
            end
        end
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end)

    if Expansions.Current >= Expansions.Wotlk then
        parent:HookScript("OnUpdate", parent.OnUpdate)
    end

    if Questie.db.profile.trackerFadeMinMaxButtons then
        expandQuest:SetAlpha(0)
    end

    expandQuest:SetScript("OnEnter", function()
        TrackerFadeTicker.Unfade()
    end)

    expandQuest:SetScript("OnLeave", function()
        TrackerFadeTicker.Fade()
    end)

    expandQuest:Hide()

    return expandQuest
end
