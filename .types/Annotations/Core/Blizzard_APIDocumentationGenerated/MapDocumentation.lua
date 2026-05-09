---@meta _
C_Map = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.CanSetUserWaypointOnMap)
---@param uiMapID number
---@return boolean canSet
function C_Map.CanSetUserWaypointOnMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.ClearUserWaypoint)
function C_Map.ClearUserWaypoint() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.CloseWorldMapInteraction)
function C_Map.CloseWorldMapInteraction() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetAreaInfo)
---@param areaID number
---@return string name
function C_Map.GetAreaInfo(areaID) end

---Only works for the player and party members.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetBestMapForUnit)
---@param unitToken UnitToken
---@return number? uiMapID
function C_Map.GetBestMapForUnit(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetBountySetMaps)
---@param bountySetID number
---@return number[] mapIDs
function C_Map.GetBountySetMaps(bountySetID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetFallbackWorldMapID)
---@return number uiMapID
function C_Map.GetFallbackWorldMapID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapArtBackgroundAtlas)
---@param uiMapID number
---@return textureAtlas atlasName
function C_Map.GetMapArtBackgroundAtlas(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapArtHelpTextPosition)
---@param uiMapID number
---@return Enum.MapCanvasPosition position
function C_Map.GetMapArtHelpTextPosition(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapArtID)
---@param uiMapID number
---@return number uiMapArtID
function C_Map.GetMapArtID(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapArtLayerTextures)
---@param uiMapID number
---@param layerIndex number
---@return fileID[] textures
function C_Map.GetMapArtLayerTextures(uiMapID, layerIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapArtLayers)
---@param uiMapID number
---@return UiMapLayerInfo[] layerInfo
function C_Map.GetMapArtLayers(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapArtZoneTextPosition)
---@param uiMapID number
---@return Enum.MapCanvasPosition position
function C_Map.GetMapArtZoneTextPosition(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapBannersForMap)
---@param uiMapID number
---@return MapBannerInfo[] mapBanners
function C_Map.GetMapBannersForMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapChildrenInfo)
---@param uiMapID number
---@param mapType? Enum.UIMapType
---@param allDescendants? boolean
---@return UiMapDetails[] info
function C_Map.GetMapChildrenInfo(uiMapID, mapType, allDescendants) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapDisplayInfo)
---@param uiMapID number
---@return boolean hideIcons
function C_Map.GetMapDisplayInfo(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapGroupID)
---@param uiMapID number
---@return number uiMapGroupID
function C_Map.GetMapGroupID(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapGroupMembersInfo)
---@param uiMapGroupID number
---@return UiMapGroupMemberInfo[] info
function C_Map.GetMapGroupMembersInfo(uiMapGroupID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapHighlightInfoAtPosition)
---@param uiMapID number
---@param x number
---@param y number
---@return fileID fileDataID
---@return textureAtlas atlasID
---@return number texturePercentageX
---@return number texturePercentageY
---@return number textureX
---@return number textureY
---@return number scrollChildX
---@return number scrollChildY
function C_Map.GetMapHighlightInfoAtPosition(uiMapID, x, y) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapHighlightPulseInfo)
---@param uiMapID number
---@return fileID fileDataID
---@return textureAtlas atlasID
---@return number texturePercentageX
---@return number texturePercentageY
---@return number textureX
---@return number textureY
---@return number scrollChildX
---@return number scrollChildY
function C_Map.GetMapHighlightPulseInfo(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapInfo)
---@param uiMapID number
---@return UiMapDetails info
function C_Map.GetMapInfo(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapInfoAtPosition)
---@param uiMapID number
---@param x number
---@param y number
---@param ignoreZoneMapPositionData? boolean
---@return UiMapDetails info
function C_Map.GetMapInfoAtPosition(uiMapID, x, y, ignoreZoneMapPositionData) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapLevels)
---@param uiMapID number
---@return number playerMinLevel
---@return number playerMaxLevel
---@return number? petMinLevel Default = 0
---@return number? petMaxLevel Default = 0
function C_Map.GetMapLevels(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapLinksForMap)
---@param uiMapID number
---@return MapLinkInfo[] mapLinks
function C_Map.GetMapLinksForMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapPosFromWorldPos)
---@param continentID number
---@param worldPosition vector2
---@param overrideUiMapID? number
---@return number uiMapID
---@return vector2 mapPosition
function C_Map.GetMapPosFromWorldPos(continentID, worldPosition, overrideUiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapRectOnMap)
---@param uiMapID number
---@param topUiMapID number
---@return number minX
---@return number maxX
---@return number minY
---@return number maxY
function C_Map.GetMapRectOnMap(uiMapID, topUiMapID) end

---Returns the size in yards of the area represented by the map.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetMapWorldSize)
---@param uiMapID number
---@return number width
---@return number height
function C_Map.GetMapWorldSize(uiMapID) end

---Only works for the player and party members.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetPlayerMapPosition)
---@param uiMapID number
---@param unitToken UnitToken
---@return vector2? position
function C_Map.GetPlayerMapPosition(uiMapID, unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetUserWaypoint)
---@return UiMapPoint point
function C_Map.GetUserWaypoint() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetUserWaypointFromHyperlink)
---@param hyperlink string
---@return UiMapPoint point
function C_Map.GetUserWaypointFromHyperlink(hyperlink) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetUserWaypointHyperlink)
---@return string hyperlink
function C_Map.GetUserWaypointHyperlink() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetUserWaypointPositionForMap)
---@param uiMapID number
---@return vector2 mapPosition
function C_Map.GetUserWaypointPositionForMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.GetWorldPosFromMapPos)
---@param uiMapID number
---@param mapPosition vector2
---@return number continentID
---@return vector2 worldPosition
function C_Map.GetWorldPosFromMapPos(uiMapID, mapPosition) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.HasUserWaypoint)
---@return boolean hasUserWaypoint
function C_Map.HasUserWaypoint() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.IsCityMap)
---@param uiMapID number
---@return boolean isCityMap
function C_Map.IsCityMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.IsMapValidForNavBarDropdown)
---@param uiMapID number
---@return boolean isValid
function C_Map.IsMapValidForNavBarDropdown(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.MapHasArt)
---@param uiMapID number
---@return boolean hasArt
function C_Map.MapHasArt(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.OpenWorldMap)
---@param uiMapID? number
function C_Map.OpenWorldMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.RequestPreloadMap)
---@param uiMapID number
function C_Map.RequestPreloadMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Map.SetUserWaypoint)
---@param point UiMapPoint
function C_Map.SetUserWaypoint(point) end

---@class MapBannerInfo
---@field areaPoiID number
---@field name string
---@field atlasName string
---@field uiTextureKit textureKit?

---@class MapLinkInfo
---@field areaPoiID number
---@field position vector2
---@field name string
---@field atlasName string
---@field linkedUiMapID number

---@class UiMapDetails
---@field mapID number
---@field name string
---@field mapType Enum.UIMapType
---@field parentMapID number
---@field flags Enum.UIMapFlag

---@class UiMapGroupMemberInfo
---@field mapID number
---@field relativeHeightIndex number
---@field name string

---@class UiMapHighlightInfo
---@field fileDataID fileID
---@field atlasID textureAtlas
---@field texturePercentageX number
---@field texturePercentageY number
---@field textureX number
---@field textureY number
---@field scrollChildX number
---@field scrollChildY number

---@class UiMapLayerInfo
---@field layerWidth number
---@field layerHeight number
---@field tileWidth number
---@field tileHeight number
---@field minScale number
---@field maxScale number
---@field additionalZoomSteps number
