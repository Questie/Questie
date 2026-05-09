---@meta _
C_ModifiedInstance = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ModifiedInstance.GetModifiedInstanceInfoFromMapID)
---@param mapID number
---@return ModifiedInstanceInfo info
function C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(mapID) end

---@class ModifiedInstanceInfo
---@field lfrItemLevel number?
---@field normalItemLevel number?
---@field heroicItemLevel number?
---@field mythicItemLevel number?
---@field uiTextureKit textureKit
---@field description string
