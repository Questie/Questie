---@meta _
C_ContentTracking = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetBestMapForTrackable)
---@param trackableType Enum.ContentTrackingType
---@param trackableID number
---@param ignoreWaypoint? boolean Default = false
---@return Enum.ContentTrackingResult result
---@return number? mapID
function C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID, ignoreWaypoint) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetCollectableSourceTrackingEnabled)
---@return boolean isEnabled
function C_ContentTracking.GetCollectableSourceTrackingEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetCollectableSourceTypes)
---@return Enum.ContentTrackingType[] collectableSourceTypes
function C_ContentTracking.GetCollectableSourceTypes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetCurrentTrackingTarget)
---@param type Enum.ContentTrackingType
---@param id number
---@return Enum.ContentTrackingTargetType targetType
---@return number targetID
function C_ContentTracking.GetCurrentTrackingTarget(type, id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetEncounterTrackingInfo)
---@param journalEncounterID number
---@return EncounterTrackingInfo trackingInfo
function C_ContentTracking.GetEncounterTrackingInfo(journalEncounterID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetNextWaypointForTrackable)
---@param trackableType Enum.ContentTrackingType
---@param trackableID number
---@param uiMapID number
---@return Enum.ContentTrackingResult result
---@return ContentTrackingMapInfo? mapInfo
function C_ContentTracking.GetNextWaypointForTrackable(trackableType, trackableID, uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetObjectiveText)
---@param targetType Enum.ContentTrackingTargetType
---@param targetID number
---@param includeHyperlinks? boolean Default = true
---@return string objectiveText
function C_ContentTracking.GetObjectiveText(targetType, targetID, includeHyperlinks) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetTitle)
---@param trackableType Enum.ContentTrackingType
---@param trackableID number
---@return string title
function C_ContentTracking.GetTitle(trackableType, trackableID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetTrackablesOnMap)
---@param trackableType Enum.ContentTrackingType
---@param uiMapID number
---@return Enum.ContentTrackingResult result
---@return ContentTrackingMapInfo[] trackableMapInfos
function C_ContentTracking.GetTrackablesOnMap(trackableType, uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetTrackedIDs)
---@param trackableType Enum.ContentTrackingType
---@return number[] entryIDs
function C_ContentTracking.GetTrackedIDs(trackableType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetVendorTrackingInfo)
---@param collectableEntryID number
---@return VendorTrackingInfo vendorTrackingInfo
function C_ContentTracking.GetVendorTrackingInfo(collectableEntryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.GetWaypointText)
---@param trackableType Enum.ContentTrackingType
---@param trackableID number
---@return string waypointText
function C_ContentTracking.GetWaypointText(trackableType, trackableID) end

---If successful, returns if the trackable is either on your current map, or if we're able to determine a route to that map from your location via waypoints.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.IsNavigable)
---@param trackableType Enum.ContentTrackingType
---@param trackableID number
---@return Enum.ContentTrackingResult result
---@return boolean isNavigable
function C_ContentTracking.IsNavigable(trackableType, trackableID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.IsTrackable)
---@param type Enum.ContentTrackingType
---@param id number
---@return boolean isTrackable
function C_ContentTracking.IsTrackable(type, id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.IsTracking)
---@param type Enum.ContentTrackingType
---@param id number
---@return boolean isTracking
function C_ContentTracking.IsTracking(type, id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.StartTracking)
---@param type Enum.ContentTrackingType
---@param id number
---@return Enum.ContentTrackingError? error
function C_ContentTracking.StartTracking(type, id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.StopTracking)
---@param type Enum.ContentTrackingType
---@param id number
---@param stopType Enum.ContentTrackingStopType
function C_ContentTracking.StopTracking(type, id, stopType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ContentTracking.ToggleTracking)
---@param type Enum.ContentTrackingType
---@param id number
---@param stopType Enum.ContentTrackingStopType
---@return Enum.ContentTrackingError? error
function C_ContentTracking.ToggleTracking(type, id, stopType) end
