---@class AchievementTracker
local AchievementTracker = QuestieLoader:CreateModule("AchievementTracker")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local LSM30 = LibStub("LibSharedMedia-3.0", true)

-- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
-- GetAchievementCriteriaInfo(achievementID, criteriaNum)
-- GetAchievementInfo(achievementID or categoryID, index)
-- AddTrackedAchievement(achievementId)

local trackedAchievements = {}

local baseFrame
local lastCreatedLine

local _TrackAchievement

---@param trackerBaseFrame Frame
function AchievementTracker.Initialize(trackerBaseFrame)
    baseFrame = CreateFrame("Frame", "Questie_TrackedAchievements", trackerBaseFrame)
    baseFrame:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -15)
    baseFrame:SetSize(1, 1)

    local header = baseFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetText("Achievements")
    header:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", 20, -12)
    header:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeHeader)
    baseFrame.header = header
    lastCreatedLine = header

    local trackedAchievementIds = {GetTrackedAchievements()}

    for i=1, #trackedAchievementIds do
        _TrackAchievement(trackedAchievementIds[i])
    end

    return lastCreatedLine
end

---Creates the required frames to display an Achievement name and its criteria
---@param achievementId integer
_TrackAchievement = function(achievementId)
    Questie:Debug(Questie.DEBUG_SPAM, "Creating frames for achievement:", achievementId)
    local achievementName = select(2, GetAchievementInfo(achievementId))

    local line = CreateFrame("Button", nil, baseFrame)
    line:SetPoint("TOP", lastCreatedLine, "BOTTOM", -35, -5)
    line:SetSize(1, 1)

    local label = line:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetJustifyH("LEFT")
    label:SetPoint("TOPLEFT", line)
    label:SetText("|cFFFFFF00" .. achievementName .. "|r")
    label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontQuest) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeQuest)
    label:SetHeight(Questie.db.global.trackerFontSizeQuest)
    line.label = label

    local numCriteria = GetAchievementNumCriteria(achievementId)
    for i=1, numCriteria do
        local _, _, _, quantityProgress, quantityNeeded, _, _, _, quantityString = GetAchievementCriteriaInfo(achievementId, i)

        local criteriaLine = line:CreateFontString(nil, "ARTWORK", "GameTooltipText")
        criteriaLine:SetJustifyH("LEFT")

        criteriaLine:SetText(QuestieLib:GetRGBForObjective({Collected=quantityProgress, Needed=quantityNeeded}) .. "- " .. quantityString .. "|r")
        criteriaLine:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeObjective)
        criteriaLine:SetHeight(Questie.db.global.trackerFontSizeObjective)
        if i > 1 then
            criteriaLine:SetPoint("TOP", line, "BOTTOM", 0, 0)
        else
            -- First criteria
            criteriaLine:SetPoint("TOP", 35, -15)
        end
        lastCreatedLine = criteriaLine
    end
    trackedAchievements[achievementId] = line
end

---The corresponding TRACKED_ACHIEVEMENT_LIST_CHANGED event is fired whenever a user tracks or untracks an achievemnt
---@param achievementId integer
---@param shouldTrack boolean
function AchievementTracker:TrackedArchievementListChanged(achievementId, shouldTrack)
    Questie:Debug(Questie.DEBUG_DEVELOP, "TRACKED_ACHIEVEMENT_LIST_CHANGED", achievementId, shouldTrack)

    print("achievementId", achievementId)
    print("shouldTrack", shouldTrack)

    if shouldTrack then
        -- Create Tracker line and add Achievement information
        _TrackAchievement(achievementId)
    else
        -- remove from tracker
        if trackedAchievements[achievementId] then
            trackedAchievements[achievementId]:Hide()
            trackedAchievements[achievementId] = nil
        end
    end
end
