---@class AchievementTracker
local AchievementTracker = QuestieLoader:CreateModule("AchievementTracker")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type LinePool
local LinePool = QuestieLoader:ImportModule("LinePool")

local LSM30 = LibStub("LibSharedMedia-3.0", true)

local baseFrame
local trackerLineWidth = 0
local lastCreatedLine
local trackedAchievementIds

local _TrackAchievement, _Untrack

local headerMarginLeft = 10
local achievementHeaderMarginLeft = headerMarginLeft + 15
local objectiveMarginLeft = headerMarginLeft + achievementHeaderMarginLeft + 5

---@param trackerBaseFrame Frame
function AchievementTracker.Initialize(trackerBaseFrame)
    baseFrame = CreateFrame("Frame", "Questie_TrackedAchievements", trackerBaseFrame)
    baseFrame:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -15)
    baseFrame:SetSize(trackerBaseFrame:GetWidth(), trackerBaseFrame:GetHeight())

    trackedAchievementIds = {GetTrackedAchievements()}

    if (not next(trackedAchievementIds)) then
        -- No achievements are currently tracked
        return baseFrame
    end

    local header = baseFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetText("Achievements")
    header:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", headerMarginLeft, -12)
    header:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeHeader)
    baseFrame.header = header
    lastCreatedLine = header

    return baseFrame
end

function AchievementTracker.LoadAchievements()
    if (not next(trackedAchievementIds)) then
        -- No achievements are currently tracked
        LinePool.HideUnusedAchievementLines()
        lastCreatedLine = baseFrame.header
        baseFrame:SetWidth(trackerLineWidth)
        baseFrame:SetHeight(18)
        baseFrame:Hide()
        return
    end

    -- TODO: Add sorting for the trackedAchievementIds
    for i=1, #trackedAchievementIds do
        _TrackAchievement(trackedAchievementIds[i])
    end

    LinePool.HideUnusedAchievementLines()

    baseFrame:SetWidth(trackerLineWidth)
    baseFrame:SetHeight(baseFrame:GetTop() - lastCreatedLine:GetBottom() + 10)
    baseFrame:Show()
end

function AchievementTracker.Update()
    trackedAchievementIds = {GetTrackedAchievements()}
    LinePool.ResetAchievementLinesForChange()
    AchievementTracker.LoadAchievements()

    baseFrame:GetParent().AutoResize() -- Update trackerBaseFrame window size
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

    local numCriteria = GetAchievementNumCriteria(achievementId)

    if numCriteria == 0 then
        line = LinePool.GetNextAchievementLine()
        if not line then return end -- stop populating the tracker
        lastCreatedLine = line

        line:SetMode("objective")

        local description = select(8, GetAchievementInfo(achievementId)):gsub("%.", "") -- Remove description ending dot
        line.label:SetText(QuestieLib:GetRGBForObjective({Collected=0, Needed=1}) .. description .. ": 0/1|r")

        line.label:ClearAllPoints()
        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)
        local lineWidth = baseFrame:GetWidth() - objectiveMarginLeft
        line.label:SetWidth(lineWidth)
        line:SetWidth(lineWidth)
        line:SetVerticalPadding(1)

        line:Show()
        line.label:Show()
        return
    end

    for i=1, numCriteria do
        -- Add objectives
        line = LinePool.GetNextAchievementLine()
        if not line then break end -- stop populating the tracker
        lastCreatedLine = line

        line:SetMode("objective")

        local criteriaString, _, _, quantityProgress, quantityNeeded = GetAchievementCriteriaInfo(achievementId, i)
        line.label:SetText(QuestieLib:GetRGBForObjective({Collected=quantityProgress, Needed=quantityNeeded}) .. criteriaString .. ": " .. quantityProgress .. "/" .. quantityNeeded .. "|r")

        line.label:ClearAllPoints()
        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)
        local lineWidth = baseFrame:GetWidth() - objectiveMarginLeft
        line.label:SetWidth(lineWidth)
        line:SetWidth(lineWidth)
        line:SetVerticalPadding(1)

        line:Show()
        line.label:Show()
    end
end

---The corresponding TRACKED_ACHIEVEMENT_LIST_CHANGED event is fired whenever a user tracks or untracks an achievement
---@param achievementId integer
---@param shouldTrack boolean
function AchievementTracker:TrackedAchievementListChanged(achievementId, shouldTrack)
    Questie:Debug(Questie.DEBUG_DEVELOP, "TRACKED_ACHIEVEMENT_LIST_CHANGED", achievementId, shouldTrack)

    AchievementTracker.Update()
end

function AchievementTracker.OnClick(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[LinePool:_OnAchievementClick]")
    if (not self.achievementId) then
        return
    end

    if TrackerUtils:IsBindTrue(Questie.db.global.trackerbindUntrack, button) then
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            ChatEdit_InsertLink(GetAchievementLink(self.achievementId))
        else
            _Untrack(self.achievementId)
        end

    elseif TrackerUtils:IsBindTrue(Questie.db.global.trackerbindOpenQuestLog, button) then
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