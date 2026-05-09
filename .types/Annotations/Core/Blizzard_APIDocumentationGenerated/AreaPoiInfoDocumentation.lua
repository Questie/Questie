---@meta _
C_AreaPoiInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetAreaPOIForMap)
---@param uiMapID number
---@return number[] areaPoiIDs
function C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetAreaPOIInfo)
---@param uiMapID? number
---@param areaPoiID number
---@return AreaPOIInfo poiInfo
function C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID) end

---Returns the number of seconds until the POI expires.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetAreaPOISecondsLeft)
---@param areaPoiID number
---@return number secondsLeft
function C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID) end

---Returns all area POIInfos flagged as delves for the given map.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetDelvesForMap)
---@param uiMapID number
---@return number[] areaPoiIDs
function C_AreaPoiInfo.GetDelvesForMap(uiMapID) end

---Returns all area POIInfos flagged as dragonriding races for the given map.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetDragonridingRacesForMap)
---@param uiMapID number
---@return number[] areaPoiIDs
function C_AreaPoiInfo.GetDragonridingRacesForMap(uiMapID) end

---Returns all area POIInfos flagged as events for the given map.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetEventsForMap)
---@param uiMapID number
---@return number[] areaPoiIDs
function C_AreaPoiInfo.GetEventsForMap(uiMapID) end

---Returns all area POIInfos flagged as quest hubs for the given map.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.GetQuestHubsForMap)
---@param uiMapID number
---@return number[] areaPoiIDs
function C_AreaPoiInfo.GetQuestHubsForMap(uiMapID) end

---This statically determines if the POI is timed, GetAreaPOITimeLeft retrieves the value from the server and may return nothing for long intervals
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AreaPoiInfo.IsAreaPOITimed)
---@param areaPoiID number
---@return boolean isTimed
---@return boolean? hideTimerInTooltip
function C_AreaPoiInfo.IsAreaPOITimed(areaPoiID) end

---@class AreaPOIInfo
---@field areaPoiID number
---@field position vector2
---@field name string
---@field description string?
---@field linkedUiMapID number?
---@field textureIndex number?
---@field tooltipWidgetSet number?
---@field iconWidgetSet number?
---@field atlasName string?
---@field uiTextureKit textureKit?
---@field shouldGlow boolean
---@field factionID number?
---@field isPrimaryMapForPOI boolean
---@field isAlwaysOnFlightmap boolean
---@field addPaddingAboveTooltipWidgets boolean?
---@field highlightWorldQuestsOnHover boolean
---@field highlightVignettesOnHover boolean
---@field isCurrentEvent boolean
