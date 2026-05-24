---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_ClearCursor)
function ClearCursor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ClearCursorHoveredItem)
function ClearCursorHoveredItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CursorHasItem)
---@return boolean result
function CursorHasItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CursorHasMacro)
---@return boolean result
function CursorHasMacro() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CursorHasMoney)
---@return boolean result
function CursorHasMoney() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CursorHasSpell)
---@return boolean result
function CursorHasSpell() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DeleteCursorItem)
function DeleteCursorItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_DropCursorMoney)
function DropCursorMoney() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_EquipCursorItem)
---@param slot number
function EquipCursorItem(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCursorInfo)
function GetCursorInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCursorMoney)
---@return number amount
function GetCursorMoney() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_PickupPlayerMoney)
---@param amount WOWMONEY
function PickupPlayerMoney(amount) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ResetCursor)
function ResetCursor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SellCursorItem)
function SellCursorItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetCursor)
---@param name? string
---@return boolean result
function SetCursor(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetCursorHoveredItem)
---@param item ItemLocation
function SetCursorHoveredItem(item) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetCursorHoveredItemTradeItem)
---@param enabled boolean
function SetCursorHoveredItemTradeItem(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetCursorVirtualItem)
---@param itemInfo ItemInfo
---@param cursorType Enum.UICursorType
function SetCursorVirtualItem(itemInfo, cursorType) end
