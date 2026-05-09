---@meta _
C_PaperDollInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.CanAutoEquipCursorItem)
---@return boolean canAutoEquip
function C_PaperDollInfo.CanAutoEquipCursorItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.CanCursorCanGoInSlot)
---@param slotIndex number
---@return boolean canOccupySlot
function C_PaperDollInfo.CanCursorCanGoInSlot(slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetArmorEffectiveness)
---@param armor number
---@param attackerLevel number
---@return number effectiveness
function C_PaperDollInfo.GetArmorEffectiveness(armor, attackerLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetArmorEffectivenessAgainstTarget)
---@param armor number
---@return number? effectiveness
function C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(armor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetInspectAzeriteItemEmpoweredChoices)
---@param unit UnitToken
---@param equipmentSlotIndex number
---@return number[] azeritePowerIDs
function C_PaperDollInfo.GetInspectAzeriteItemEmpoweredChoices(unit, equipmentSlotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetInspectGuildInfo)
---@param unitString string
---@return number achievementPoints
---@return number numMembers
---@return string guildName
---@return string realmName
function C_PaperDollInfo.GetInspectGuildInfo(unitString) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetInspectItemLevel)
---@param unit UnitToken
---@return number equippedItemLevel
function C_PaperDollInfo.GetInspectItemLevel(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetInspectRatedBGBlitzData)
---@return InspectPVPData ratedBGBlitzData
function C_PaperDollInfo.GetInspectRatedBGBlitzData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetInspectRatedBGData)
---@return InspectRatedBGData ratedBGData
function C_PaperDollInfo.GetInspectRatedBGData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetInspectRatedSoloShuffleData)
---@return InspectPVPData ratedSoloShuffleData
function C_PaperDollInfo.GetInspectRatedSoloShuffleData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetMinItemLevel)
---@return number? minItemLevel
function C_PaperDollInfo.GetMinItemLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.GetStaggerPercentage)
---@param unit UnitToken
---@return number stagger
---@return number? staggerAgainstTarget
function C_PaperDollInfo.GetStaggerPercentage(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.IsInventorySlotEnabled)
---@param slotName stringView
---@return boolean isEnabled
function C_PaperDollInfo.IsInventorySlotEnabled(slotName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.OffhandHasShield)
---@return boolean offhandHasShield
function C_PaperDollInfo.OffhandHasShield() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PaperDollInfo.OffhandHasWeapon)
---@return boolean offhandHasWeapon
function C_PaperDollInfo.OffhandHasWeapon() end

---@class InspectGuildInfo
---@field achievementPoints number
---@field numMembers number
---@field guildName string
---@field realmName string

---@class InspectPVPData
---@field rating number
---@field gamesWon number
---@field gamesPlayed number
---@field roundsWon number
---@field roundsPlayed number

---@class InspectRatedBGData
---@field rating number
---@field played number
---@field won number
