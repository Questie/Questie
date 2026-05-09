---@meta _
C_HeirloomInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HeirloomInfo.AreAllCollectionFiltersChecked)
---@return boolean areAllCollectionFiltersChecked
function C_HeirloomInfo.AreAllCollectionFiltersChecked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HeirloomInfo.AreAllSourceFiltersChecked)
---@return boolean areAllSourceFiltersChecked
function C_HeirloomInfo.AreAllSourceFiltersChecked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HeirloomInfo.IsHeirloomSourceValid)
---@param source number
---@return boolean isHeirloomSourceValid
function C_HeirloomInfo.IsHeirloomSourceValid(source) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HeirloomInfo.IsUsingDefaultFilters)
---@return boolean isUsingDefaultFilters
function C_HeirloomInfo.IsUsingDefaultFilters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HeirloomInfo.SetAllCollectionFilters)
---@param checked boolean
function C_HeirloomInfo.SetAllCollectionFilters(checked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HeirloomInfo.SetAllSourceFilters)
---@param checked boolean
function C_HeirloomInfo.SetAllSourceFilters(checked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HeirloomInfo.SetDefaultFilters)
function C_HeirloomInfo.SetDefaultFilters() end
