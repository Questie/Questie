---@meta _

---@deprecated
---Deprecated by [C_Item.GetItemQualityColor](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemQualityColor)
---@param quality number
---@return number colorRGBR
---@return number colorRGBG
---@return number colorRGBB
---@return string qualityString
function GetItemQualityColor(quality) end

---@deprecated
---Deprecated by [C_Item.GetItemInfoInstant](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemInfoInstant)
---@param itemInfo ItemInfo
---@return number itemID
---@return string itemType
---@return string itemSubType
---@return string itemEquipLoc
---@return fileID icon
---@return number classID
---@return number subClassID
function GetItemInfoInstant(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetItemSetInfo](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemSetInfo)
---@param setID number
---@return string result
function GetItemSetInfo(setID) end

---@deprecated
---Deprecated by [C_Item.GetItemChildInfo](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemChildInfo)
---@param itemInfo ItemInfo
---@param slotID? number
---@return number[] result
function GetItemChildInfo(itemInfo, slotID) end

---@deprecated
---Deprecated by [C_Item.DoesItemContainSpec](https://warcraft.wiki.gg/wiki/API_C_Item.DoesItemContainSpec)
---@param itemInfo ItemInfo
---@param classID number
---@param specID? number Default = 0
---@return boolean result
function DoesItemContainSpec(itemInfo, classID, specID) end

---@deprecated
---Deprecated by [C_Item.GetItemGem](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemGem)
---@param hyperlink string
---@param index number
---@return string gemName
---@return string gemLink
function GetItemGem(hyperlink, index) end

---@deprecated
---Deprecated by [C_Item.GetItemCreationContext](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemCreationContext)
---@param itemInfo ItemInfo
---@return number itemID
---@return string creationContext
function GetItemCreationContext(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetItemIconByID](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemIconByID)
---@param itemInfo ItemInfo
---@return fileID? icon
function GetItemIcon(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetItemFamily](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemFamily)
---@param itemInfo ItemInfo
---@return number? result
function GetItemFamily(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetItemSpell](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemSpell)
---@param itemInfo ItemInfo
---@return string spellName
---@return number spellID
function GetItemSpell(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsArtifactPowerItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsArtifactPowerItem)
---@param itemInfo ItemInfo
---@return boolean result
function IsArtifactPowerItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsCurrentItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsCurrentItem)
---@param itemInfo ItemInfo
---@return boolean result
function IsCurrentItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsUsableItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsUsableItem)
---@param itemInfo ItemInfo
---@return boolean usable
---@return boolean noMana
function IsUsableItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsHelpfulItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsHelpfulItem)
---@param itemInfo ItemInfo
---@return boolean result
function IsHelpfulItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsHarmfulItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsHarmfulItem)
---@param itemInfo ItemInfo
---@return boolean result
function IsHarmfulItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsConsumableItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsConsumableItem)
---@param itemInfo ItemInfo
---@return boolean result
function IsConsumableItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsEquippableItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsEquippableItem)
---@param itemInfo ItemInfo
---@return boolean result
function IsEquippableItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsEquippedItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsEquippedItem)
---@param itemInfo ItemInfo
---@return boolean result
function IsEquippedItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsEquippedItemType](https://warcraft.wiki.gg/wiki/API_C_Item.IsEquippedItemType)
---@param type string
---@return boolean result
function IsEquippedItemType(type) end

---@deprecated
---Deprecated by [C_Item.ItemHasRange](https://warcraft.wiki.gg/wiki/API_C_Item.ItemHasRange)
---@param itemInfo ItemInfo
---@return boolean result
function ItemHasRange(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsItemInRange](https://warcraft.wiki.gg/wiki/API_C_Item.IsItemInRange)
---@param itemInfo ItemInfo
---@param targetToken string
---@return boolean? result
function IsItemInRange(itemInfo, targetToken) end

---@deprecated
---Deprecated by [C_Item.GetItemClassInfo](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemClassInfo)
---@param itemClassID number
---@return string result
function GetItemClassInfo(itemClassID) end

---@deprecated
---Deprecated by [C_Item.GetItemInventorySlotInfo](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemInventorySlotInfo)
---@param inventorySlot number|Enum.InventoryType
---@return string result
function GetItemInventorySlotInfo(inventorySlot) end

---@deprecated
---Deprecated by [C_Item.BindEnchant](https://warcraft.wiki.gg/wiki/API_C_Item.BindEnchant)
function BindEnchant() end

---@deprecated
---Deprecated by [C_Item.ActionBindsItem](https://warcraft.wiki.gg/wiki/API_C_Item.ActionBindsItem)
function ActionBindsItem() end

---@deprecated
---Deprecated by [C_Item.ReplaceEnchant](https://warcraft.wiki.gg/wiki/API_C_Item.ReplaceEnchant)
function ReplaceEnchant() end

---@deprecated
---Deprecated by [C_Item.ReplaceTradeEnchant](https://warcraft.wiki.gg/wiki/API_C_Item.ReplaceTradeEnchant)
function ReplaceTradeEnchant() end

---@deprecated
---Deprecated by [C_Item.ConfirmBindOnUse](https://warcraft.wiki.gg/wiki/API_C_Item.ConfirmBindOnUse)
function ConfirmBindOnUse() end

---@deprecated
---Deprecated by [C_Item.ConfirmOnUse](https://warcraft.wiki.gg/wiki/API_C_Item.ConfirmOnUse)
function ConfirmOnUse() end

---@deprecated
---Deprecated by [C_Item.ConfirmNoRefundOnUse](https://warcraft.wiki.gg/wiki/API_C_Item.ConfirmNoRefundOnUse)
function ConfirmNoRefundOnUse() end

---@deprecated
---Deprecated by [C_Item.DropItemOnUnit](https://warcraft.wiki.gg/wiki/API_C_Item.DropItemOnUnit)
---@param unitGUID UnitToken
function DropItemOnUnit(unitGUID) end

---@deprecated
---Deprecated by [C_Item.EndBoundTradeable](https://warcraft.wiki.gg/wiki/API_C_Item.EndBoundTradeable)
---@param type string
function EndBoundTradeable(type) end

---@deprecated
---Deprecated by [C_Item.EndRefund](https://warcraft.wiki.gg/wiki/API_C_Item.EndRefund)
---@param type number
function EndRefund(type) end

---@deprecated
---Deprecated by [C_Item.GetItemInfo](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemInfo)
---@param itemInfo ItemInfo
---@return string itemName
---@return string itemLink
---@return Enum.ItemQuality itemQuality
---@return number itemLevel
---@return number itemMinLevel
---@return string itemType
---@return string itemSubType
---@return number itemStackCount
---@return string itemEquipLoc
---@return fileID itemTexture
---@return number sellPrice
---@return number classID
---@return number subclassID
---@return number bindType
---@return number expansionID
---@return number? setID
---@return boolean isCraftingReagent
function GetItemInfo(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetDetailedItemLevelInfo](https://warcraft.wiki.gg/wiki/API_C_Item.GetDetailedItemLevelInfo)
---@param itemInfo ItemInfo
---@return number actualItemLevel
---@return boolean previewLevel
---@return number sparseItemLevel
function GetDetailedItemLevelInfo(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetItemSpecInfo](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemSpecInfo)
---@param itemInfo ItemInfo
---@return number[] specTable
function GetItemSpecInfo(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetItemUniqueness](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemUniqueness)
---@param itemInfo ItemInfo
---@return number limitCategory
---@return number limitMax
function GetItemUniqueness(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetItemCount](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemCount)
---@param itemInfo ItemInfo
---@param includeBank? boolean Default = false
---@param includeUses? boolean Default = false
---@param includeReagentBank? boolean Default = false
---@return number count
function GetItemCount(itemInfo, includeBank, includeUses, includeReagentBank) end

---@deprecated
---Deprecated by [C_Item.PickupItem](https://warcraft.wiki.gg/wiki/API_C_Item.PickupItem)
---@param itemInfo ItemInfo
function PickupItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.GetItemSubClassInfo](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemSubClassInfo)
---@param itemClassID number
---@param itemSubClassID number
---@return string subClassName
---@return boolean subClassUsesInvType
function GetItemSubClassInfo(itemClassID, itemSubClassID) end

---@deprecated
---Deprecated by [C_Item.UseItemByName](https://warcraft.wiki.gg/wiki/API_C_Item.UseItemByName)
---@param itemInfo ItemInfo
---@param target? string
function UseItemByName(itemInfo, target) end

---@deprecated
---Deprecated by [C_Item.EquipItemByName](https://warcraft.wiki.gg/wiki/API_C_Item.EquipItemByName)
---@param itemInfo ItemInfo
---@param dstSlot? number
function EquipItemByName(itemInfo, dstSlot) end

---@deprecated
---Deprecated by [C_Item.ReplaceTradeskillEnchant](https://warcraft.wiki.gg/wiki/API_C_Item.ReplaceTradeskillEnchant)
function ReplaceTradeskillEnchant() end

---@deprecated
---Deprecated by [C_Item.GetItemCooldown](https://warcraft.wiki.gg/wiki/API_C_Item.GetItemCooldown)
---@param itemInfo ItemInfo
---@return number startTimeSeconds
---@return number durationSeconds
---@return boolean enableCooldownTimer
function GetItemCooldown(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsCorruptedItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsCorruptedItem)
---@param itemInfo ItemInfo
---@return boolean? result
function IsCorruptedItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsCosmeticItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsCosmeticItem)
---@param itemInfo ItemInfo
---@return boolean? result
function IsCosmeticItem(itemInfo) end

---@deprecated
---Deprecated by [C_Item.IsDressableItem](https://warcraft.wiki.gg/wiki/API_C_Item.IsDressableItem)
---@param itemInfo ItemInfo
---@return boolean isDressableItem
function IsDressableItem(itemInfo) end
