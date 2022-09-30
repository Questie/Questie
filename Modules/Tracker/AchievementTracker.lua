---@class AchievementTracker
local AchievementTracker = QuestieLoader:CreateModule("AchievementTracker")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type LinePool
local LinePool = QuestieLoader:ImportModule("LinePool")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LSM30 = LibStub("LibSharedMedia-3.0", true)

local isStarted = false
local baseFrame
local trackerLineWidth = 0
local lastCreatedLine
local trackedAchievementIds

local EMPTY_CRITERIA = {Collected=0, Needed=1}

local _TrackAchievement, _Untrack, _UpdateTracker

local headerMarginLeft = 10
local achievementHeaderMarginLeft = headerMarginLeft + 15
local objectiveMarginLeft = headerMarginLeft + achievementHeaderMarginLeft + 5

---@param trackerBaseFrame Frame
function AchievementTracker.Initialize(trackerBaseFrame, UpdateTracker)
    _UpdateTracker = UpdateTracker

    baseFrame = CreateFrame("Frame", "Questie_TrackedAchievements", trackerBaseFrame)
    baseFrame:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -15)
    baseFrame:SetSize(trackerBaseFrame:GetWidth(), trackerBaseFrame:GetHeight())

    trackedAchievementIds = {GetTrackedAchievements()}

    local header = CreateFrame("Button", nil, trackerBaseFrame);
    header:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", headerMarginLeft, -12)
    header:SetScript("OnClick", function()
        Questie.db.char.isAchievementsExpanded = (not Questie.db.char.isAchievementsExpanded)
        AchievementTracker.Update()
    end)

    local headerLabel = header:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    headerLabel:SetText(l10n("Achievements"))
    headerLabel:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
    headerLabel:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeHeader)

    header:SetSize(headerLabel:GetUnboundedStringWidth(), Questie.db.global.trackerFontSizeHeader)
    header.label = headerLabel
    baseFrame.header = header
    lastCreatedLine = header

    baseFrame:Hide()
    isStarted = true
    return baseFrame
end

function AchievementTracker.LoadAchievements()
    if (not next(trackedAchievementIds)) or (not Questie.db.char.isAchievementsExpanded) or (not Questie.db.char.isTrackerExpanded) then
        -- No achievements are currently tracked
        LinePool.HideUnusedAchievementLines()
        lastCreatedLine = baseFrame.header
        if (not next(trackedAchievementIds)) then
            baseFrame:SetHeight(1)
            baseFrame.header:Hide()
        else
            baseFrame:SetHeight(baseFrame.header:GetHeight() + 3)
        end
        baseFrame:Hide()
        return
    end

    -- TODO: Add sorting for the trackedAchievementIds
    for i=1, #trackedAchievementIds do
        _TrackAchievement(trackedAchievementIds[i])
    end

    LinePool.HideUnusedAchievementLines()

    baseFrame:SetWidth(trackerLineWidth)
    baseFrame:SetHeight(baseFrame:GetTop() - lastCreatedLine:GetBottom())
    baseFrame.header:Show()
    baseFrame:Show()
end

function AchievementTracker.Update()
    if not isStarted then
        return
    end

    trackedAchievementIds = {GetTrackedAchievements()}
    LinePool.ResetAchievementLinesForChange()
    AchievementTracker.LoadAchievements()

    _UpdateTracker()
end

function AchievementTracker.Hide()
    baseFrame.header:Hide()
    baseFrame:Hide()
end

function AchievementTracker.Show()
    trackedAchievementIds = {GetTrackedAchievements()}
    if next(trackedAchievementIds) then
        baseFrame.header:Show()
        baseFrame:Show()
    end
end

---Creates the required frames to display an Achievement name and its criteria
---@param achievementId integer
_TrackAchievement = function(achievementId)
    Questie:Debug(Questie.DEBUG_SPAM, "Creating frames for achievement:", achievementId)
    local achievementName = select(2, GetAchievementInfo(achievementId))

    local line = LinePool.GetNextAchievementLine()
    if not line then return end -- stop populating the tracker
    lastCreatedLine = line

    line:SetMode("achievement")
    line:SetAchievement(achievementId)

    line.label:SetText("|cFFFFFF00" .. achievementName .. "|r")

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", achievementHeaderMarginLeft, 0)
    line.expand:SetPoint("RIGHT", line, "LEFT", achievementHeaderMarginLeft - 8, 0)
    line.label:SetWidth(baseFrame:GetWidth() - achievementHeaderMarginLeft + 40)
    line.label:SetHeight(Questie.db.global.trackerFontSizeQuest)
    line:SetWidth(line.label:GetWidth())

    line:SetVerticalPadding(2)
    line:Show()
    line.label:Show()
    line.expand:Show()

    trackerLineWidth = math.max(trackerLineWidth, line.label:GetWidth())

    if Questie.db.char.collapsedAchievements[achievementId] then
        -- The Achievement is collapsed
        return
    end

    local numCriteria = GetAchievementNumCriteria(achievementId)

    if numCriteria == 0 then
        line = LinePool.GetNextAchievementLine()
        if not line then return end -- stop populating the tracker
        lastCreatedLine = line

        line:SetMode("objective")

        local description = select(8, GetAchievementInfo(achievementId)):gsub("%.", "") -- Remove description ending dot
        line.label:SetText(QuestieLib:GetRGBForObjective(EMPTY_CRITERIA) .. description .. ": 0/1|r")

        line.label:ClearAllPoints()
        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)
        local lineWidth = baseFrame:GetWidth() - objectiveMarginLeft
        line.label:SetWidth(lineWidth)
        line:SetWidth(lineWidth)
        line:SetVerticalPadding(1)

        line:Show()
        line.expand:Hide()
        line.label:Show()
        return
    end

    for i=1, numCriteria do
        local criteriaString, _, completed, quantityProgress, quantityNeeded = GetAchievementCriteriaInfo(achievementId, i)

        -- TODO: Add an option to also show completed criteria
        if (not completed) then
            -- Add objectives
            line = LinePool.GetNextAchievementLine()
            if not line then break end -- stop populating the tracker
            lastCreatedLine = line

            line:SetMode("objective")
            line.label:SetText(QuestieLib:GetRGBForObjective({Collected=quantityProgress, Needed=quantityNeeded}) .. criteriaString .. ": " .. quantityProgress .. "/" .. quantityNeeded .. "|r")

            line.label:ClearAllPoints()
            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)
            local lineWidth = baseFrame:GetWidth() - objectiveMarginLeft
            line.label:SetWidth(lineWidth)
            line:SetWidth(lineWidth)
            line:SetVerticalPadding(1)

            line:Show()
            line.expand:Hide()
            line.label:Show()
        end
    end
end

---The corresponding TRACKED_ACHIEVEMENT_LIST_CHANGED event is fired whenever a user tracks or untracks an achievement
---@param achievementId integer
---@param shouldTrack boolean
function AchievementTracker:TrackedAchievementListChanged(achievementId, shouldTrack)
    if not isStarted then
        return
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "TRACKED_ACHIEVEMENT_LIST_CHANGED", achievementId, shouldTrack)

    AchievementTracker.Update()
end

function AchievementTracker.OnClick(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[LinePool:_OnAchievementClick]")

    local achievementId = self.expand.achievementId
    if (not achievementId) then
        return
    end

    if TrackerUtils:IsBindTrue(Questie.db.global.trackerbindUntrack, button) then
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            ChatEdit_InsertLink(GetAchievementLink(achievementId))
        else
            _Untrack(achievementId)
        end

    --elseif TrackerUtils:IsBindTrue(Questie.db.global.trackerbindOpenQuestLog, button) then
        -- TODO: Open Achievement in UI
        --TrackerUtils:ShowQuestLog(self.Quest)

    -- TODO: Add right click menu
    --elseif button == "RightButton" then
    --    local menu = TrackerMenu:GetMenuForQuest(self.Quest)
    --    LibDropDown:EasyMenu(menu, TrackerMenu.menuFrame, "cursor", 0 , 0, "MENU")
    end
end

---Removes an achievement from the tracked list
---@param achievementId number
_Untrack = function(achievementId)
    RemoveTrackedAchievement(achievementId)
    AchievementTracker.Update()
end