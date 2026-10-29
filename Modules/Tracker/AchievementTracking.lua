-- The only module that knows which game API is used to read and change the game's tracked achievements:
-- the legacy globals (WotLK, Cata, MoP) or C_ContentTracking (Forever). The API is chosen per call, by checking what exists.
---@class AchievementTracking
local AchievementTracking = QuestieLoader:CreateModule("AchievementTracking")

local DEFAULT_MAX_TRACKED = 10

---@return boolean
local function _IsContentTrackingAvailable()
    return C_ContentTracking ~= nil and C_ContentTracking.GetTrackedIDs ~= nil and C_ContentTracking.StopTracking ~= nil
        and Enum ~= nil and Enum.ContentTrackingType ~= nil and Enum.ContentTrackingStopType ~= nil
end

---@return boolean
local function _IsTrackingDisabledByGameRule()
    return C_GameRules ~= nil and C_GameRules.IsGameRuleActive ~= nil and Enum ~= nil and Enum.GameRule ~= nil
        and Enum.GameRule.TrackAchievementsDisabled ~= nil and C_GameRules.IsGameRuleActive(Enum.GameRule.TrackAchievementsDisabled)
end

---@return boolean
function AchievementTracking.IsSupported()
    if GetTrackedAchievements then
        return true
    end

    return _IsContentTrackingAvailable() and (not _IsTrackingDisabledByGameRule())
end

--- The achievement IDs tracked by the game, in the game's order.
---@return number[]
function AchievementTracking.GetTrackedIds()
    if GetTrackedAchievements then
        return {GetTrackedAchievements()}
    end

    if _IsContentTrackingAvailable() then
        return C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)
    end

    return {}
end

---@return number
function AchievementTracking.GetMaxTracked()
    if Constants and Constants.ContentTrackingConsts and Constants.ContentTrackingConsts.MaxTrackedAchievements then
        return Constants.ContentTrackingConsts.MaxTrackedAchievements
    end

    return DEFAULT_MAX_TRACKED
end

---@param achievementId number
---@param isQuestie boolean? Only used by the legacy API: handed to the removal hook so Questie ignores its own removal
function AchievementTracking.Untrack(achievementId, isQuestie)
    if RemoveTrackedAchievement then
        RemoveTrackedAchievement(achievementId, isQuestie)
    elseif _IsContentTrackingAvailable() then
        C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementId, Enum.ContentTrackingStopType.Manual)
    end
end
