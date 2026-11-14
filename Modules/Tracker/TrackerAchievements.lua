-- Turns the game's tracked achievements into the display data used by the tracker's achievement section.
---@class TrackerAchievements
local TrackerAchievements = QuestieLoader:CreateModule("TrackerAchievements")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@class TrackerAchievementCriteria
---@field Text string
---@field Completed boolean
---@field Collected number Used for the text color
---@field Needed number Used for the text color
---@field Progress string|nil Progress text like "3/10". Only set for unfinished criteria that need more than one of something
---@field LinkedAchievementId number|nil Set when the criteria is an achievement of its own, e.g. "Champion of the Horde"
---@field IsDescription boolean True for the achievement description shown for achievements without criteria

---@class TrackerAchievement
---@field Id number
---@field Name string
---@field Description string
---@field Criteria TrackerAchievementCriteria[]

---@param text string
---@return string
local function _StripTrailingDot(text)
    return (text:gsub("%.$", ""))
end

---@param achievementId number
---@param criteriaIndex number
---@param description string
---@return TrackerAchievementCriteria
local function _GetCriteria(achievementId, criteriaIndex, description)
    local criteriaString, _, completed, quantityProgress, quantityNeeded, _, _, refId, quantityString = GetAchievementCriteriaInfo(
        achievementId, criteriaIndex)

    local linkedAchievementId
    if refId and select(2, GetAchievementInfo(refId)) == criteriaString
        and ((GetAchievementInfo(refId) and refId ~= 0) or (refId > 0 and (not QuestieDB.GetQuest(refId)))) then
        -- Sometimes stand alone trackable Achievements are part of a group of Achievements under a parent Achievement.
        -- E.g. "Champion of the Horde" from the Argent Tournament
        linkedAchievementId = refId
    end

    if (criteriaString == "") then
        criteriaString = _StripTrailingDot(description)
    end

    local criteria = {
        Text = _StripTrailingDot(criteriaString),
        Completed = completed,
        Collected = completed and 1 or 0,
        Needed = 1,
        LinkedAchievementId = linkedAchievementId,
        IsDescription = false,
    }

    -- Criteria with more than one required quantity show their progress
    if (not (completed or quantityNeeded == 1 or quantityProgress == quantityNeeded)) then
        criteria.Collected = quantityProgress
        criteria.Needed = quantityNeeded

        if string.find(quantityString, "|") then
            criteria.Progress = (quantityString:gsub("/%s?", "/"))
        else
            criteria.Progress = quantityProgress .. "/" .. quantityNeeded
        end
    end

    return criteria
end

---@param achievementId number
---@param description string
---@return TrackerAchievementCriteria[]
local function _GetCriteriaList(achievementId, description)
    local numCriteria = GetAchievementNumCriteria(achievementId)
    if numCriteria == 0 then
        return {{
            Text = _StripTrailingDot(description),
            Completed = false,
            Collected = 0,
            Needed = 1,
            IsDescription = true,
        }}
    end

    local criteriaList = {}
    for criteriaIndex = 1, numCriteria do
        local criteria = _GetCriteria(achievementId, criteriaIndex, description)
        if (not Questie.db.profile.hideCompletedAchieveObjectives) or (not criteria.Completed) then
            criteriaList[#criteriaList + 1] = criteria
        end
    end
    return criteriaList
end

--- Achievements that are already earned or unknown are skipped.
---@param achievementIds number[]
---@return TrackerAchievement[]
function TrackerAchievements.GetAchievements(achievementIds)
    local achievements = {}

    for _, trackedId in ipairs(achievementIds) do
        local achievementId, name, _, _, _, _, _, description, _, _, _, _, completed = GetAchievementInfo(trackedId)
        if achievementId and (not completed) then
            achievements[#achievements + 1] = {
                Id = achievementId,
                Name = name,
                Description = description,
                Criteria = _GetCriteriaList(achievementId, description),
            }
        end
    end

    return achievements
end
