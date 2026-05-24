---@meta _
C_ArdenwealdGardening = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArdenwealdGardening.GetGardenData)
---@return ArdenwealdGardenData data
function C_ArdenwealdGardening.GetGardenData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ArdenwealdGardening.IsGardenAccessible)
---@return boolean accessible
function C_ArdenwealdGardening.IsGardenAccessible() end

---@class ArdenwealdGardenData
---@field active number
---@field ready number
---@field remainingSeconds time_t
