---@meta _
C_AchievementInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AchievementInfo.AreGuildAchievementsEnabled)
---@return boolean enabled
function C_AchievementInfo.AreGuildAchievementsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AchievementInfo.GetRewardItemID)
---@param achievementID number
---@return number? rewardItemID
function C_AchievementInfo.GetRewardItemID(achievementID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AchievementInfo.GetSupercedingAchievements)
---@param achievementID number
---@return number[] supercedingAchievements
function C_AchievementInfo.GetSupercedingAchievements(achievementID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AchievementInfo.IsGuildAchievement)
---@param achievementId number
---@return boolean isGuild
function C_AchievementInfo.IsGuildAchievement(achievementId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AchievementInfo.IsValidAchievement)
---@param achievementId number
---@return boolean isValidAchievement
function C_AchievementInfo.IsValidAchievement(achievementId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AchievementInfo.SetPortraitTexture)
---@param textureObject SimpleTexture
function C_AchievementInfo.SetPortraitTexture(textureObject) end
