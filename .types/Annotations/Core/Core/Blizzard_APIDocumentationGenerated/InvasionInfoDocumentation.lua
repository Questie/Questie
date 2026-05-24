---@meta _
C_InvasionInfo = {}

---Returns true if invasions are active in the same physical area as the player.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_InvasionInfo.AreInvasionsAvailable)
---@return boolean areInvasionsAvailable
function C_InvasionInfo.AreInvasionsAvailable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_InvasionInfo.GetInvasionForUiMapID)
---@param uiMapID number
---@return number? invasionID
function C_InvasionInfo.GetInvasionForUiMapID(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_InvasionInfo.GetInvasionInfo)
---@param invasionID number
---@return InvasionMapInfo invasionInfo
function C_InvasionInfo.GetInvasionInfo(invasionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_InvasionInfo.GetInvasionTimeLeft)
---@param invasionID number
---@return number? timeLeftMinutes
function C_InvasionInfo.GetInvasionTimeLeft(invasionID) end

---@class InvasionMapInfo
---@field invasionID number
---@field name string
---@field position vector2
---@field atlasName textureAtlas
---@field rewardQuestID number?
