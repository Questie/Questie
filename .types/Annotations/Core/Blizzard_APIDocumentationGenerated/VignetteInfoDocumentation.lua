---@meta _
C_VignetteInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VignetteInfo.FindBestUniqueVignette)
---@param vignetteGUIDs WOWGUID[]
---@return number? bestUniqueVignetteIndex
function C_VignetteInfo.FindBestUniqueVignette(vignetteGUIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VignetteInfo.GetHealthPercent)
---@param vignetteGUID WOWGUID
---@return number? healthPct
function C_VignetteInfo.GetHealthPercent(vignetteGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VignetteInfo.GetRecommendedGroupSize)
---@param vignetteGUID WOWGUID
---@return number minGroupSize
---@return number maxGroupSize
function C_VignetteInfo.GetRecommendedGroupSize(vignetteGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VignetteInfo.GetVignetteInfo)
---@param vignetteGUID WOWGUID
---@return VignetteInfo? vignetteInfo
function C_VignetteInfo.GetVignetteInfo(vignetteGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VignetteInfo.GetVignettePosition)
---@param vignetteGUID WOWGUID
---@param uiMapID number
---@return vector2 vignettePosition
---@return number? vignetteFacing
function C_VignetteInfo.GetVignettePosition(vignetteGUID, uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VignetteInfo.GetVignettes)
---@return WOWGUID[] vignetteGUIDs
function C_VignetteInfo.GetVignettes() end

---@class VignetteInfo
---@field vignetteGUID WOWGUID
---@field objectGUID WOWGUID
---@field name string
---@field isDead boolean
---@field onWorldMap boolean
---@field zoneInfiniteAOI boolean
---@field onMinimap boolean
---@field isUnique boolean
---@field inFogOfWar boolean
---@field atlasName textureAtlas
---@field hasTooltip boolean
---@field vignetteID number
---@field type Enum.VignetteType
---@field rewardQuestID number
---@field tooltipWidgetSet number?
---@field iconWidgetSet number?
---@field addPaddingAboveTooltipWidgets boolean?
---@field mapPin UIMapPinInfo?
---@field objectiveType Enum.VignetteObjectiveType?
