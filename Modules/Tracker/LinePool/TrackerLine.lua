---@class TrackerLine
local TrackerLine = QuestieLoader:CreateModule("TrackerLine")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker") -- TODO: Remove this explicit dependency
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type TrackerMenu
local TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
---@type VoiceOverPlayButton
local VoiceOverPlayButton = QuestieLoader:ImportModule("VoiceOverPlayButton")
---@type AchievementCriteriaCheckmark
local AchievementCriteriaCheckmark = QuestieLoader:ImportModule("AchievementCriteriaCheckmark")
---@type ExpandQuestButton
local ExpandQuestButton = QuestieLoader:ImportModule("ExpandQuestButton")
---@type ExpandZoneButton
local ExpandZoneButton = QuestieLoader:ImportModule("ExpandZoneButton")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type DistanceUtils
local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

local LSM30 = LibStub("LibSharedMedia-3.0")
local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

local _SetMode, _OnClickQuest, _OnClickAchieve

local lineMarginLeft = 10

---@param index number
---@param parent ScrollFrame
---@param previousLine TrackerLine?
---@param OnEnter fun(self: TrackerLine) @Callback function for OnEnter
---@param OnLeave fun(self: TrackerLine) @Callback function for OnLeave
---@param OnQuestAdded fun(questId: number, line: TrackerLine) @Callback function for SetQuest
---@param OnScenarioCriteriaAdded fun(criteriaIndex: number, line: TrackerLine) @Callback function for SetScenarioCriteria
---@return TrackerLine
function TrackerLine.New(index, parent, previousLine, OnEnter, OnLeave, OnQuestAdded, OnScenarioCriteriaAdded)
    local timeElapsed = 0
    ---@class TrackerLine : Button
    local line = CreateFrame("Button", "linePool" .. index, parent)
    line:SetWidth(1)
    line:SetHeight(1)
    ---@type SimpleFontString|{ activeTimer: TimerCallback? }
    line.label = line:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    line.label:SetJustifyH("LEFT")
    line.label:SetJustifyV("TOP")
    line.label:SetPoint("TOPLEFT", line)
    line.label:Hide()

    --- Initialize variables
    line.label.activeTimer = nil

    ---@type "zone"|"quest"|"achieve"|nil
    line.mode = nil

    --- Extra SubFrames?
    ---@type TrackerItemButton?
    line.altButton = nil
    ---@type nil -- I don't think this is in use at all?
    line.Button = nil


    if previousLine then
        line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", 0, 0)
    else
        line:SetPoint("TOPLEFT", parent, "TOPLEFT", lineMarginLeft, 0)
    end

    line.SetMode = _SetMode

    ---@param zoneId AreaId @ I think this is a AreaId
    function line:SetZone(zoneId)
        if type(zoneId) == "string" then
            self.expandZone.zoneId = zoneId
        elseif type(zoneId) == "number" then
            self.ZoneId = TrackerUtils:GetZoneNameByID(zoneId)
            self.expandZone.zoneId = zoneId
        end
    end

    ---@param quest Quest @ I think this is actually correct...
    function line:SetQuest(quest)
        if type(quest) == "number" then
            -- ? If this is an actual Quest - Object it is missing a fuckton of fields
            ---@diagnostic disable-next-line: missing-fields
            quest = {
                Id = quest,
            }
            self.Quest = quest
            self.expandQuest.questId = quest.Id
        else
            self.Quest = quest
            self.expandQuest.questId = quest.Id
        end

        OnQuestAdded(quest.Id, self)

        -- Set Timed Quest Flag
        if quest.trackTimedQuest then
            self.trackTimedQuest = quest.trackTimedQuest
        end
    end

    ---@param objective ScenarioObjective
    function line:SetObjective(objective)
        self.Objective = objective
    end

    ---@param objective ScenarioObjective
    function line:SetScenarioCriteria(objective)
        self.Objective = objective
        ---@see TrackerLinePool.AddScenarioLine
        OnScenarioCriteriaAdded(objective.Id, self)
    end

    ---@param elapsed number
    function line:OnUpdate(elapsed)
        if Expansions.Current >= Expansions.Wotlk then
            timeElapsed = timeElapsed + elapsed

            if timeElapsed > 1 and self.trackTimedQuest and self.label.activeTimer then
                local _, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(self.Quest.Id)

                if timeRemaining ~= nil then
                    if timeRemaining > 1 then
                        TrackerQuestTimers:UpdateTimerFrame()
                    end

                    if timeRemaining == 1 then
                        TrackerQuestTimers:UpdateTimerFrame()
                    end

                    timeElapsed = 0
                else
                    timeElapsed = 0
                    return
                end
            end
        else
            return
        end
    end
    ---@param amount number
    function line:SetVerticalPadding(amount)
        if self.mode == "zone" then
            self:SetHeight(Questie.db.profile.trackerFontSizeZone + amount)
        elseif self.mode == "quest" or self.mode == "achieve" then
            self:SetHeight(Questie.db.profile.trackerFontSizeQuest + amount)
        else
            self:SetHeight(Questie.db.profile.trackerFontSizeObjective + amount)
        end
    end

    line:EnableMouse(true)
    line:RegisterForDrag("LeftButton")
    line:RegisterForClicks("RightButtonUp", "LeftButtonUp")

    function line:SetOnClick(onClickMode)
        if onClickMode == "quest" then
            self:SetScript("OnClick", _OnClickQuest)
        elseif onClickMode == "achieve" then
            self:SetScript("OnClick", _OnClickAchieve)
        end
    end

    line:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
    line:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)

    ---@see TrackerLinePool.OnHighlightEnter
    line:SetScript("OnEnter",
    ---@param self TrackerLine
    function(self)
        OnEnter(self)
        TrackerFadeTicker.Unfade()
    end)

    ---@see TrackerLinePool.OnHighlightLeave
    line:SetScript("OnLeave",
    ---@param self TrackerLine
    function(self)
        OnLeave(self)
        TrackerFadeTicker.Fade()
    end)

    line.criteriaMark = AchievementCriteriaCheckmark.New(index, line)
    line.expandZone = ExpandZoneButton.New(index, line, OnEnter, OnLeave)
    line.playButton = VoiceOverPlayButton.New(index, line)
    line.expandQuest = ExpandQuestButton.New(index, line)

    return line
end


---@param mode string
_SetMode = function(self, mode)
    if mode ~= self.mode then
        self.mode = mode
        if mode == "zone" then
            local trackerFontSizeZone = Questie.db.profile.trackerFontSizeZone
            self.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontZone), trackerFontSizeZone, Questie.db.profile.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeZone)
        elseif mode == "quest" or mode == "achieve" then
            local trackerFontSizeQuest = Questie.db.profile.trackerFontSizeQuest
            self.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontQuest), trackerFontSizeQuest, Questie.db.profile.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeQuest)
        elseif mode == "objective" then
            local trackerFontSizeObjective = Questie.db.profile.trackerFontSizeObjective
            self.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontObjective), trackerFontSizeObjective, Questie.db.profile.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeObjective)
        end
    end
end

---@param self TrackerLine
---@param button string
_OnClickQuest = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:_OnClickQuest]")
    if (not self.Quest) then
        return
    end

    if TrackerMenu.menuFrame:IsShown() then
        LibDropDown:CloseDropDownMenus()
    end

    if TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindSetTomTom, button) then
        local spawn, zone, name = DistanceUtils.GetNearestSpawnForQuest(self.Quest)
        if spawn then
            TrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
    elseif TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindUntrack, button) then
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            if Questie.db.profile.trackerShowQuestLevel then
                ChatEdit_InsertLink(QuestieLink:GetQuestLinkString(self.Quest.level, self.Quest.name, self.Quest.Id))
            else
                ChatEdit_InsertLink("[" .. self.Quest.name .. " (" .. self.Quest.Id .. ")]")
            end
        else
            QuestieTracker:UntrackQuestId(self.Quest.Id)
            local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame
            if questLogFrame:IsShown() then
                QuestLog_Update()
            end
        end
    elseif TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindOpenQuestLog, button) then
        TrackerUtils:ShowQuestLog(self.Quest)
    elseif button == "RightButton" then
        local menu = TrackerMenu:GetMenuForQuest(self.Quest)
        LibDropDown:EasyMenu(menu, TrackerMenu.menuFrame, "cursor", 0, 0, "MENU")
    end
end

---@param self TrackerLine
---@param button string
_OnClickAchieve = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:_OnClickAchieve]")
    if (not self.Quest) then
        return
    end

    if TrackerMenu.menuFrame:IsShown() then
        LibDropDown:CloseDropDownMenus()
    end

    if TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindUntrack, button) then
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            ChatEdit_InsertLink(GetAchievementLink(self.Quest.Id))
        else
            if Questie.db.char.trackedAchievementIds[self.Quest.Id] then
                QuestieTracker:UntrackAchieveId(self.Quest.Id)
                QuestieTracker:UpdateAchieveTrackerCache(self.Quest.Id)

                if (not AchievementFrame) then
                    AchievementFrame_LoadUI()
                end

                AchievementFrameAchievements_ForceUpdate()

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Update()
                end)
            else
                -- Assume this is an Objective of an Achievement
                UIErrorsFrame:AddMessage(format(l10n("You can't untrack an objective of an achievement.")), 1.0, 0.1, 0.1, 1.0)
            end
        end
    elseif TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindOpenQuestLog, button) then
        if (not AchievementFrame) then
            AchievementFrame_LoadUI()
        end

        if (not AchievementFrame:IsShown()) then
            AchievementFrame_ToggleAchievementFrame()
            AchievementFrame_SelectAchievement(self.Quest.Id)
        else
            if (AchievementFrameAchievements.selection ~= self.Quest.Id) then
                AchievementFrame_SelectAchievement(self.Quest.Id)
            end
        end
    elseif button == "RightButton" then
        local menu = TrackerMenu:GetMenuForAchievement(self.Quest)
        LibDropDown:EasyMenu(menu, TrackerMenu.menuFrame, "cursor", 0, 0, "MENU")
    end
end

return TrackerLine
