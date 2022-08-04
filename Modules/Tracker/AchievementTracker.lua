---@class AchievementTracker
local AchievementTracker = QuestieLoader:CreateModule("AchievementTracker")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")


-- https://wowpedia.fandom.com/wiki/World_of_Warcraft_API
-- GetAchievementCriteriaInfo(achievementID, criteriaNum)
-- GetAchievementInfo(achievementID or categoryID, index)
-- AddTrackedAchievement(achievementId)

local trackedAchievements = {}

local baseFrame

---@param trackerBaseFrame Frame
function AchievementTracker.Initialize(trackerBaseFrame)
    baseFrame = CreateFrame("Frame", "Questie_TrackedAchievements", trackerBaseFrame)
    baseFrame:SetPoint("CENTER")
    baseFrame:SetSize(200, 40)

    local header = baseFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetText("Tracked Achievements")
    baseFrame.header = header
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

        local achievementName = select(2, GetAchievementInfo(achievementId))
        print("achievementName", achievementName)

        local line = CreateFrame("Button", nil, baseFrame)
        line:SetPoint("CENTER")
        line:SetSize(1, 1)

        local label = line:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetJustifyH("LEFT")
        label:SetPoint("TOPLEFT", line)
        label:SetText(achievementName)
        line.label = label

        local numCriteria = GetAchievementNumCriteria(achievementId)

        for i=1, numCriteria do
            local quantityString = select(9, GetAchievementCriteriaInfo(achievementId, i))

            local criteriaLine = line:CreateFontString(nil, "ARTWORK", "GameTooltipText")
            criteriaLine:SetJustifyH("LEFT")
            criteriaLine:SetText("- " .. quantityString)
            if i > 1 then
                criteriaLine:SetPoint("TOP", line, "BOTTOM", 0, 0)
            else
                -- First criteria
                criteriaLine:SetPoint("TOP", 40, -13)
            end
        end

        trackedAchievements[achievementId] = line
    else
        -- remove from tracker
        if trackedAchievements[achievementId] then
            trackedAchievements[achievementId]:Hide()
            trackedAchievements[achievementId] = nil
        end
    end
end
