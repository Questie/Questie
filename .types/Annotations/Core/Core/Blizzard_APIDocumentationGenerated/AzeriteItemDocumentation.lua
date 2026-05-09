---@meta _
C_AzeriteItem = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.FindActiveAzeriteItem)
---@return AzeriteItemLocation activeAzeriteItemLocation
function C_AzeriteItem.FindActiveAzeriteItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.GetAzeriteItemXPInfo)
---@param azeriteItemLocation AzeriteItemLocation
---@return number xp
---@return number totalLevelXP
function C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.GetPowerLevel)
---@param azeriteItemLocation AzeriteItemLocation
---@return number powerLevel
function C_AzeriteItem.GetPowerLevel(azeriteItemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.GetUnlimitedPowerLevel)
---@param azeriteItemLocation AzeriteItemLocation
---@return number powerLevel
function C_AzeriteItem.GetUnlimitedPowerLevel(azeriteItemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.HasActiveAzeriteItem)
---@return boolean hasActiveAzeriteItem
function C_AzeriteItem.HasActiveAzeriteItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.IsAzeriteItem)
---@param itemLocation ItemLocation
---@return boolean isAzeriteItem
function C_AzeriteItem.IsAzeriteItem(itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.IsAzeriteItemAtMaxLevel)
---@return boolean isAtMax
function C_AzeriteItem.IsAzeriteItemAtMaxLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.IsAzeriteItemByID)
---@param itemInfo ItemInfo
---@return boolean isAzeriteItem
function C_AzeriteItem.IsAzeriteItemByID(itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.IsAzeriteItemEnabled)
---@param azeriteItemLocation AzeriteItemLocation
---@return boolean isEnabled
function C_AzeriteItem.IsAzeriteItemEnabled(azeriteItemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteItem.IsUnlimitedLevelingUnlocked)
---@return boolean isUnlimitedLevelingUnlocked
function C_AzeriteItem.IsUnlimitedLevelingUnlocked() end

---@class UnlockedAzeriteEmpoweredItems
---@field unlockedItem AzeriteEmpoweredItemLocation
---@field tierIndex number
