---@meta _
C_AzeriteEmpoweredItem = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.CanSelectPower)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
---@param powerID number
---@return boolean canSelect
function C_AzeriteEmpoweredItem.CanSelectPower(azeriteEmpoweredItemLocation, powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.ConfirmAzeriteEmpoweredItemRespec)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
function C_AzeriteEmpoweredItem.ConfirmAzeriteEmpoweredItemRespec(azeriteEmpoweredItemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.GetAllTierInfo)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
---@return AzeriteEmpoweredItemTierInfo[] tierInfo
function C_AzeriteEmpoweredItem.GetAllTierInfo(azeriteEmpoweredItemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.GetAllTierInfoByItemID)
---@param itemInfo ItemInfo
---@param classID? number
---@return AzeriteEmpoweredItemTierInfo[] tierInfo
function C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(itemInfo, classID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.GetAzeriteEmpoweredItemRespecCost)
---@return number cost
function C_AzeriteEmpoweredItem.GetAzeriteEmpoweredItemRespecCost() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.GetPowerInfo)
---@param powerID number
---@return AzeriteEmpoweredItemPowerInfo powerInfo
function C_AzeriteEmpoweredItem.GetPowerInfo(powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.GetPowerText)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
---@param powerID number
---@param level Enum.AzeritePowerLevel
---@return AzeriteEmpoweredItemPowerText powerText
function C_AzeriteEmpoweredItem.GetPowerText(azeriteEmpoweredItemLocation, powerID, level) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.GetSpecsForPower)
---@param powerID number
---@return AzeriteSpecInfo[] specInfo
function C_AzeriteEmpoweredItem.GetSpecsForPower(powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.HasAnyUnselectedPowers)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
---@return boolean hasAnyUnselectedPowers
function C_AzeriteEmpoweredItem.HasAnyUnselectedPowers(azeriteEmpoweredItemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.HasBeenViewed)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
---@return boolean hasBeenViewed
function C_AzeriteEmpoweredItem.HasBeenViewed(azeriteEmpoweredItemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem)
---@param itemLocation ItemLocation
---@return boolean isAzeriteEmpoweredItem
function C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID)
---@param itemInfo ItemInfo
---@return boolean isAzeriteEmpoweredItem
function C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.IsAzeritePreviewSourceDisplayable)
---@param itemInfo ItemInfo
---@param classID? number
---@return boolean isAzeritePreviewSourceDisplayable
function C_AzeriteEmpoweredItem.IsAzeritePreviewSourceDisplayable(itemInfo, classID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped)
---@return boolean isHeartOfAzerothEquipped
function C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.IsPowerAvailableForSpec)
---@param powerID number
---@param specID number
---@return boolean isPowerAvailableForSpec
function C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(powerID, specID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.IsPowerSelected)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
---@param powerID number
---@return boolean isSelected
function C_AzeriteEmpoweredItem.IsPowerSelected(azeriteEmpoweredItemLocation, powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.SelectPower)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
---@param powerID number
---@return boolean success
function C_AzeriteEmpoweredItem.SelectPower(azeriteEmpoweredItemLocation, powerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AzeriteEmpoweredItem.SetHasBeenViewed)
---@param azeriteEmpoweredItemLocation AzeriteEmpoweredItemLocation
function C_AzeriteEmpoweredItem.SetHasBeenViewed(azeriteEmpoweredItemLocation) end

---@class AzeriteEmpoweredItemPowerInfo
---@field azeritePowerID number
---@field spellID number

---@class AzeriteEmpoweredItemPowerText
---@field name string
---@field description string

---@class AzeriteEmpoweredItemTierInfo
---@field azeritePowerIDs number[]
---@field unlockLevel number

---@class AzeriteSpecInfo
---@field classID number
---@field specID number
