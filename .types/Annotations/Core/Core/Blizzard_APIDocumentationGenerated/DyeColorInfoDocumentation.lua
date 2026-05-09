---@meta _
C_DyeColor = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DyeColor.GetAllDyeColorCategories)
---@return number[] dyeColorCategoryIDs
function C_DyeColor.GetAllDyeColorCategories() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DyeColor.GetAllDyeColors)
---@param ownedColorsOnly? boolean Default = false
---@return number[] dyeColorIDs
function C_DyeColor.GetAllDyeColors(ownedColorsOnly) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DyeColor.GetDyeColorCategoryInfo)
---@param dyeColorCategoryID number
---@return DyeColorCategoryDisplayInfo? dyeColorCategoryInfo
function C_DyeColor.GetDyeColorCategoryInfo(dyeColorCategoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DyeColor.GetDyeColorForItem)
---@param itemLinkOrID ItemInfo
---@return number? dyeColorID
function C_DyeColor.GetDyeColorForItem(itemLinkOrID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DyeColor.GetDyeColorForItemLocation)
---@param itemLocation ItemLocation
---@return number? dyeColorID
function C_DyeColor.GetDyeColorForItemLocation(itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DyeColor.GetDyeColorInfo)
---@param dyeColorID number
---@return DyeColorDisplayInfo? dyeColorInfo
function C_DyeColor.GetDyeColorInfo(dyeColorID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DyeColor.GetDyeColorsInCategory)
---@param dyeColorCategory number
---@param ownedColorsOnly? boolean Default = false
---@return number[] dyeColorIDs
function C_DyeColor.GetDyeColorsInCategory(dyeColorCategory, ownedColorsOnly) end

---True if the player owns any of the consumable item used to apply the specified dye
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DyeColor.IsDyeColorOwned)
---@param dyeColorID number
---@return boolean isOwned
function C_DyeColor.IsDyeColorOwned(dyeColorID) end
