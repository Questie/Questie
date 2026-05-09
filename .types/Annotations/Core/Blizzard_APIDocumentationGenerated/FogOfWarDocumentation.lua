---@meta _
C_FogOfWar = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FogOfWar.GetFogOfWarForMap)
---@param uiMapID number
---@return number? fogOfWarID
function C_FogOfWar.GetFogOfWarForMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FogOfWar.GetFogOfWarInfo)
---@param fogOfWarID number
---@return FogOfWarInfo? fogOfWarInfo
function C_FogOfWar.GetFogOfWarInfo(fogOfWarID) end

---@class FogOfWarInfo
---@field fogOfWarID number
---@field backgroundAtlas textureAtlas
---@field maskAtlas textureAtlas
---@field maskScalar number
