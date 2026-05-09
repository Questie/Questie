---@meta _
C_DeathInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathInfo.GetCorpseMapPosition)
---@param uiMapID number
---@return vector2? position
function C_DeathInfo.GetCorpseMapPosition(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathInfo.GetDeathReleasePosition)
---@param uiMapID number
---@return vector2? position
function C_DeathInfo.GetDeathReleasePosition(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathInfo.GetGraveyardsForMap)
---@param uiMapID number
---@return GraveyardMapInfo[] graveyards
function C_DeathInfo.GetGraveyardsForMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathInfo.GetSelfResurrectOptions)
---@return SelfResurrectOption[] options
function C_DeathInfo.GetSelfResurrectOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DeathInfo.UseSelfResurrectOption)
---@param optionType Enum.SelfResurrectOptionType
---@param id number
function C_DeathInfo.UseSelfResurrectOption(optionType, id) end

---@class GraveyardMapInfo
---@field areaPoiID number
---@field position vector2
---@field name string
---@field textureIndex number
---@field graveyardID number
---@field isGraveyardSelectable boolean

---@class SelfResurrectOption
---@field name string
---@field optionType Enum.SelfResurrectOptionType
---@field id number
---@field canUse boolean
---@field isLimited boolean
---@field priority number
