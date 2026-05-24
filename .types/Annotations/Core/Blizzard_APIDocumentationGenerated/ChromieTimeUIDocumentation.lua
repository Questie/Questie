---@meta _
C_ChromieTime = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ChromieTime.CloseUI)
function C_ChromieTime.CloseUI() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ChromieTime.GetChromieTimeExpansionOption)
---@param expansionRecID number
---@return ChromieTimeExpansionInfo? info
function C_ChromieTime.GetChromieTimeExpansionOption(expansionRecID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ChromieTime.GetChromieTimeExpansionOptions)
---@return ChromieTimeExpansionInfo[] expansionOptions
function C_ChromieTime.GetChromieTimeExpansionOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ChromieTime.SelectChromieTimeOption)
---@param chromieTimeExpansionInfoId number
function C_ChromieTime.SelectChromieTimeOption(chromieTimeExpansionInfoId) end

---@class ChromieTimeExpansionInfo
---@field id number
---@field name string
---@field description string
---@field mapAtlas textureAtlas
---@field previewAtlas textureAtlas
---@field completed boolean
---@field alreadyOn boolean
---@field recommended boolean
---@field sortPriority number
