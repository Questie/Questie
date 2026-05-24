---@meta _
C_SuperTrack = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.ClearAllSuperTracked)
function C_SuperTrack.ClearAllSuperTracked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.ClearSuperTrackedContent)
function C_SuperTrack.ClearSuperTrackedContent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.ClearSuperTrackedMapPin)
function C_SuperTrack.ClearSuperTrackedMapPin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.GetHighestPrioritySuperTrackingType)
---@return Enum.SuperTrackingType? type
function C_SuperTrack.GetHighestPrioritySuperTrackingType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.GetNextWaypointForMap)
---@param uiMapID number
---@return number x
---@return number y
---@return string waypointDescription
function C_SuperTrack.GetNextWaypointForMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.GetSuperTrackedContent)
---@return Enum.ContentTrackingType trackableType
---@return number trackableID
function C_SuperTrack.GetSuperTrackedContent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.GetSuperTrackedItemName)
---@return string name
---@return string description
function C_SuperTrack.GetSuperTrackedItemName() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.GetSuperTrackedMapPin)
---@return Enum.SuperTrackingMapPinType type
---@return number typeID
function C_SuperTrack.GetSuperTrackedMapPin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.GetSuperTrackedQuestID)
---@return number? questID
function C_SuperTrack.GetSuperTrackedQuestID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.GetSuperTrackedVignette)
---@return WOWGUID? vignetteGUID
function C_SuperTrack.GetSuperTrackedVignette() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.IsSuperTrackingAnything)
---@return boolean isSuperTracking
function C_SuperTrack.IsSuperTrackingAnything() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.IsSuperTrackingContent)
---@return boolean isSuperTracking
function C_SuperTrack.IsSuperTrackingContent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.IsSuperTrackingCorpse)
---@return boolean isSuperTracking
function C_SuperTrack.IsSuperTrackingCorpse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.IsSuperTrackingMapPin)
---@return boolean isSuperTracking
function C_SuperTrack.IsSuperTrackingMapPin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.IsSuperTrackingQuest)
---@return boolean isSuperTracking
function C_SuperTrack.IsSuperTrackingQuest() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.IsSuperTrackingUserWaypoint)
---@return boolean isSuperTracking
function C_SuperTrack.IsSuperTrackingUserWaypoint() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.SetSuperTrackedContent)
---@param trackableType Enum.ContentTrackingType
---@param trackableID number
function C_SuperTrack.SetSuperTrackedContent(trackableType, trackableID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.SetSuperTrackedMapPin)
---@param type Enum.SuperTrackingMapPinType
---@param typeID number
function C_SuperTrack.SetSuperTrackedMapPin(type, typeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.SetSuperTrackedQuestID)
---@param questID number
function C_SuperTrack.SetSuperTrackedQuestID(questID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.SetSuperTrackedUserWaypoint)
---@param superTracked boolean
function C_SuperTrack.SetSuperTrackedUserWaypoint(superTracked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SuperTrack.SetSuperTrackedVignette)
---@param vignetteGUID WOWGUID
function C_SuperTrack.SetSuperTrackedVignette(vignetteGUID) end
