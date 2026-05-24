---@meta _
C_NewItems = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NewItems.ClearAll)
function C_NewItems.ClearAll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NewItems.IsNewItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return boolean isNew
function C_NewItems.IsNewItem(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NewItems.RemoveNewItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
function C_NewItems.RemoveNewItem(containerIndex, slotIndex) end
