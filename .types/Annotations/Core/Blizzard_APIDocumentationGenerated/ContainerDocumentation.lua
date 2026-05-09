---@meta _
C_Container = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.ContainerIDToInventoryID)
---@param containerID Enum.BagIndex
---@return number inventoryID
function C_Container.ContainerIDToInventoryID(containerID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.ContainerRefundItemPurchase)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@param isEquipped? boolean Default = false
function C_Container.ContainerRefundItemPurchase(containerIndex, slotIndex, isEquipped) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetBackpackAutosortDisabled)
---@return boolean isDisabled
function C_Container.GetBackpackAutosortDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetBackpackSellJunkDisabled)
---@return boolean isDisabled
function C_Container.GetBackpackSellJunkDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetBagName)
---@param bagIndex Enum.BagIndex
---@return string name
function C_Container.GetBagName(bagIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetBagSlotFlag)
---@param bagIndex Enum.BagIndex
---@param flag Enum.BagSlotFlags
---@return boolean isSet
function C_Container.GetBagSlotFlag(bagIndex, flag) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetBankAutosortDisabled)
---@return boolean isDisabled
function C_Container.GetBankAutosortDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerFreeSlots)
---@param containerIndex Enum.BagIndex
---@return number[] freeSlots
function C_Container.GetContainerFreeSlots(containerIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemCooldown)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return number startTime
---@return number duration
---@return number enable
function C_Container.GetContainerItemCooldown(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemDurability)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return number durability
---@return number maxDurability
function C_Container.GetContainerItemDurability(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemEquipmentSetInfo)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return boolean inSet
---@return string setList
function C_Container.GetContainerItemEquipmentSetInfo(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemID)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return number containerID
function C_Container.GetContainerItemID(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemInfo)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return ContainerItemInfo containerInfo
function C_Container.GetContainerItemInfo(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemLink)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return string itemLink
function C_Container.GetContainerItemLink(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemPurchaseCurrency)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@param itemIndex number
---@param isEquipped boolean
---@return ItemPurchaseCurrency currencyInfo
function C_Container.GetContainerItemPurchaseCurrency(containerIndex, slotIndex, itemIndex, isEquipped) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemPurchaseInfo)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@param isEquipped boolean
---@return ItemPurchaseInfo info
function C_Container.GetContainerItemPurchaseInfo(containerIndex, slotIndex, isEquipped) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemPurchaseItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@param itemIndex number
---@param isEquipped boolean
---@return ItemPurchaseItem itemInfo
function C_Container.GetContainerItemPurchaseItem(containerIndex, slotIndex, itemIndex, isEquipped) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerItemQuestInfo)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return ItemQuestInfo questInfo
function C_Container.GetContainerItemQuestInfo(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerNumFreeSlots)
---@param bagIndex Enum.BagIndex
---@return number numFreeSlots
---@return number? bagFamily
function C_Container.GetContainerNumFreeSlots(bagIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetContainerNumSlots)
---@param containerIndex Enum.BagIndex
---@return number numSlots
function C_Container.GetContainerNumSlots(containerIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetInsertItemsLeftToRight)
---@return boolean isEnabled
function C_Container.GetInsertItemsLeftToRight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetItemCooldown)
---@param itemID number
---@return number startTime
---@return number duration
---@return number enable
function C_Container.GetItemCooldown(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetMaxArenaCurrency)
---@return number maxCurrency
function C_Container.GetMaxArenaCurrency() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.GetSortBagsRightToLeft)
---@return boolean isEnabled
function C_Container.GetSortBagsRightToLeft() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.HasContainerItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return boolean hasItem
function C_Container.HasContainerItem(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.IsBattlePayItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return boolean isBattlePayItem
function C_Container.IsBattlePayItem(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.IsContainerFiltered)
---@param containerIndex Enum.BagIndex
---@return boolean isFiltered
function C_Container.IsContainerFiltered(containerIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.PickupContainerItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
function C_Container.PickupContainerItem(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.PlayerHasHearthstone)
---@return number? itemID
function C_Container.PlayerHasHearthstone() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SetBackpackAutosortDisabled)
---@param disable boolean
function C_Container.SetBackpackAutosortDisabled(disable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SetBackpackSellJunkDisabled)
---@param disable boolean
function C_Container.SetBackpackSellJunkDisabled(disable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SetBagPortraitTexture)
---@param texture SimpleTexture
---@param bagIndex Enum.BagIndex
function C_Container.SetBagPortraitTexture(texture, bagIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SetBagSlotFlag)
---@param bagIndex Enum.BagIndex
---@param flag Enum.BagSlotFlags
---@param isSet boolean
function C_Container.SetBagSlotFlag(bagIndex, flag, isSet) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SetBankAutosortDisabled)
---@param disable boolean
function C_Container.SetBankAutosortDisabled(disable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SetInsertItemsLeftToRight)
---@param enable boolean
function C_Container.SetInsertItemsLeftToRight(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SetItemSearch)
---@param searchString string
function C_Container.SetItemSearch(searchString) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SetSortBagsRightToLeft)
---@param enable boolean
function C_Container.SetSortBagsRightToLeft(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.ShowContainerSellCursor)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
function C_Container.ShowContainerSellCursor(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SocketContainerItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@return boolean success
function C_Container.SocketContainerItem(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SortAccountBankBags)
function C_Container.SortAccountBankBags() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SortBags)
function C_Container.SortBags() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SortBank)
---@param bankType Enum.BankType
function C_Container.SortBank(bankType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SortBankBags)
function C_Container.SortBankBags() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.SplitContainerItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@param amount number
function C_Container.SplitContainerItem(containerIndex, slotIndex, amount) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.UseContainerItem)
---@param containerIndex Enum.BagIndex
---@param slotIndex number
---@param unitToken? UnitToken
---@param bankType? Enum.BankType
---@param reagentBankOpen? boolean Default = false
function C_Container.UseContainerItem(containerIndex, slotIndex, unitToken, bankType, reagentBankOpen) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Container.UseHearthstone)
---@return boolean used
function C_Container.UseHearthstone() end

---@class ContainerItemInfo
---@field iconFileID fileID
---@field stackCount number
---@field isLocked boolean
---@field quality Enum.ItemQuality?
---@field isReadable boolean
---@field hasLoot boolean
---@field hyperlink string
---@field isFiltered boolean
---@field hasNoValue boolean
---@field itemID number
---@field isBound boolean
---@field itemName string

---@class ItemPurchaseCurrency
---@field iconFileID number?
---@field currencyCount number
---@field name string

---@class ItemPurchaseInfo
---@field money WOWMONEY
---@field itemCount number
---@field refundSeconds time_t
---@field currencyCount number
---@field hasEnchants boolean

---@class ItemPurchaseItem
---@field iconFileID number?
---@field itemCount number
---@field hyperlink string

---@class ItemQuestInfo
---@field isQuestItem boolean
---@field questID number?
---@field isActive boolean
