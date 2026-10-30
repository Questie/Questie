-- The only module that knows which game API is used to read and change the game's tracked achievements:
-- the legacy globals (WotLK, Cata, MoP) or C_ContentTracking (Forever). The API is chosen per call, by checking what exists.
---@class AchievementTracking
local AchievementTracking = QuestieLoader:CreateModule("AchievementTracking")

---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

local DEFAULT_MAX_TRACKED = 10

-- Era and TBC have the legacy globals as stubs without achievements, so their existence alone is not enough.
---@return boolean
local function _IsLegacyApiAvailable()
    return GetTrackedAchievements ~= nil and RemoveTrackedAchievement ~= nil and IsTrackedAchievement ~= nil
        and Expansions.Current >= Expansions.Wotlk
end

---@return boolean
local function _IsContentTrackingAvailable()
    return C_ContentTracking ~= nil and C_ContentTracking.GetTrackedIDs ~= nil and C_ContentTracking.IsTracking ~= nil
        and C_ContentTracking.StopTracking ~= nil and Enum ~= nil and Enum.ContentTrackingType ~= nil and Enum.ContentTrackingStopType ~= nil
end

---@return boolean
function AchievementTracking.IsSupported()
    if _IsLegacyApiAvailable() then
        return true
    end

    return _IsContentTrackingAvailable()
end

--- The achievement IDs tracked by the game, in the game's order.
---@return number[]
function AchievementTracking.GetTrackedIds()
    if _IsLegacyApiAvailable() then
        return {GetTrackedAchievements()}
    end

    if _IsContentTrackingAvailable() then
        return C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)
    end

    return {}
end

---@return boolean
function AchievementTracking.HasTrackedAchievements()
    return next(AchievementTracking.GetTrackedIds()) ~= nil
end

--- True when the tracked list is changed through C_ContentTracking, which reports changes with CONTENT_TRACKING_UPDATE.
---@return boolean
function AchievementTracking.UsesContentTracking()
    return (not _IsLegacyApiAvailable()) and _IsContentTrackingAvailable()
end

--- For CONTENT_TRACKING_UPDATE, which reports all kinds of tracked content.
---@param trackableType number
---@return boolean
function AchievementTracking.IsAchievementContentType(trackableType)
    return AchievementTracking.UsesContentTracking() and trackableType == Enum.ContentTrackingType.Achievement
end

---@return number
function AchievementTracking.GetMaxTracked()
    if Constants and Constants.ContentTrackingConsts and Constants.ContentTrackingConsts.MaxTrackedAchievements then
        return Constants.ContentTrackingConsts.MaxTrackedAchievements
    end

    return DEFAULT_MAX_TRACKED
end

---@param achievementId number
---@return boolean
function AchievementTracking.IsTracked(achievementId)
    if _IsLegacyApiAvailable() then
        return IsTrackedAchievement(achievementId) and true or false
    elseif _IsContentTrackingAvailable() then
        return C_ContentTracking.IsTracking(Enum.ContentTrackingType.Achievement, achievementId)
    end

    return false
end

---@param achievementId number
function AchievementTracking.Untrack(achievementId)
    if _IsLegacyApiAvailable() then
        RemoveTrackedAchievement(achievementId)
    elseif _IsContentTrackingAvailable() then
        C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementId, Enum.ContentTrackingStopType.Manual)
    end
end

--- Shows the achievement in the game's achievement window. Legacy Challenges on Forever are shown in the Legacy System window.
---@param achievementId number
function AchievementTracking.OpenAchievement(achievementId)
    if ToggleLegacySystemUI then
        if (not LegacySystemFrame) then
            LegacySystemFrame_LoadUI()
        end
        if LegacySystemFrame and (not LegacySystemFrame:IsShown()) then
            ToggleLegacySystemUI()
        end
        QuestieCompat.AchievementFrame_SelectAchievement(achievementId)
        return
    end

    if (not AchievementFrame) then
        AchievementFrame_LoadUI()
    end

    if (not AchievementFrame:IsShown()) then
        QuestieCompat.AchievementFrame_ToggleAchievementFrame()
        QuestieCompat.AchievementFrame_SelectAchievement(achievementId)
    elseif AchievementFrameAchievements.selection ~= achievementId then
        QuestieCompat.AchievementFrame_SelectAchievement(achievementId)
    end
end

--- Updates the tracked checkmarks of the achievement window, if it is loaded.
function AchievementTracking.RefreshAchievementWindow()
    QuestieCompat.AchievementFrameAchievements_ForceUpdate()
end
