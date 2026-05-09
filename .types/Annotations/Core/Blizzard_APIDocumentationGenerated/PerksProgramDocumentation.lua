---@meta _
C_PerksProgram = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.ClearFrozenPerksVendorItem)
function C_PerksProgram.ClearFrozenPerksVendorItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.CloseInteraction)
function C_PerksProgram.CloseInteraction() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetAvailableCategoryIDs)
---@return number[] categoryIDs
function C_PerksProgram.GetAvailableCategoryIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetAvailableVendorItemIDs)
---@return number[] vendorItemIDs
function C_PerksProgram.GetAvailableVendorItemIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetCategoryInfo)
---@param categoryID number
---@return PerksVendorCategoryInfo categoryInfo
function C_PerksProgram.GetCategoryInfo(categoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetCurrencyAmount)
---@return number currencyAmount
function C_PerksProgram.GetCurrencyAmount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetDraggedPerksVendorItem)
---@return number perksVendorItemID
function C_PerksProgram.GetDraggedPerksVendorItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetFrozenPerksVendorItemInfo)
---@return PerksVendorItemInfo vendorItemInfo
function C_PerksProgram.GetFrozenPerksVendorItemInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetPendingChestRewards)
---@return PerksProgramPendingChestRewards[] pendingRewards
function C_PerksProgram.GetPendingChestRewards() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetPerksProgramItemDisplayInfo)
---@param id number
---@return PerksProgramItemDisplayInfo item
function C_PerksProgram.GetPerksProgramItemDisplayInfo(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetTimeRemaining)
---@param vendorItemID number
---@return time_t timeRemaining
function C_PerksProgram.GetTimeRemaining(vendorItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetVendorItemInfo)
---@param vendorItemID number
---@return PerksVendorItemInfo vendorItemInfo
function C_PerksProgram.GetVendorItemInfo(vendorItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.GetVendorItemInfoRefundTimeLeft)
---@param vendorItemID number
---@return time_t refundTimeRemaining
function C_PerksProgram.GetVendorItemInfoRefundTimeLeft(vendorItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.IsAttackAnimToggleEnabled)
---@return boolean isAttackAnimToggleEnabled
function C_PerksProgram.IsAttackAnimToggleEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.IsFrozenPerksVendorItem)
---@param perksVendorItemID number
---@return boolean isFrozen
function C_PerksProgram.IsFrozenPerksVendorItem(perksVendorItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.IsMountSpecialAnimToggleEnabled)
---@return boolean isMountSpecialAnimToggleEnabled
function C_PerksProgram.IsMountSpecialAnimToggleEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.ItemSelectedTelemetry)
---@param perksVendorItemID number
function C_PerksProgram.ItemSelectedTelemetry(perksVendorItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.PickupPerksVendorItem)
---@param perksVendorItemID number
function C_PerksProgram.PickupPerksVendorItem(perksVendorItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.RequestCartCheckout)
---@param perksVendorItemIDs number[]
function C_PerksProgram.RequestCartCheckout(perksVendorItemIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.RequestPendingChestRewards)
function C_PerksProgram.RequestPendingChestRewards() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.RequestPurchase)
---@param perksVendorItemID number
function C_PerksProgram.RequestPurchase(perksVendorItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.RequestRefund)
---@param perksVendorItemID number
function C_PerksProgram.RequestRefund(perksVendorItemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.ResetHeldItemDragAndDrop)
function C_PerksProgram.ResetHeldItemDragAndDrop() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PerksProgram.SetFrozenPerksVendorItem)
function C_PerksProgram.SetFrozenPerksVendorItem() end

---@class PerksProgramItemDisplayInfo
---@field overrideModelSceneID number?
---@field creatureDisplayInfoID number?
---@field mainHandItemModifiedAppearanceID number?
---@field offHandItemModifiedAppearanceID number?

---@class PerksProgramPendingChestRewards
---@field rewardTypeID number
---@field perksVendorItemID number?
---@field rewardAmount number
---@field monthRewarded string?
---@field activityMonthID number
---@field thresholdOrderIndex number

---@class PerksVendorCategoryInfo
---@field ID number
---@field displayName string
---@field defaultUIModelSceneID number

---@class PerksVendorItemInfo
---@field name string
---@field perksVendorCategoryID number
---@field description string
---@field timeRemaining time_t
---@field purchased boolean
---@field refundable boolean
---@field subItemsLoaded boolean
---@field isPurchasePending boolean
---@field doesNotExpire boolean
---@field price number
---@field originalPrice number?
---@field showSaleBanner boolean
---@field perksVendorItemID number
---@field itemID number
---@field iconTexture string
---@field mountID number
---@field mountTypeName string
---@field speciesID number
---@field transmogSetID number
---@field itemModifiedAppearanceID number
---@field subItems PerksVendorSubItemInfo[]
---@field uiGroupInfo PerksVendorItemUIGroupInfo?
---@field invType string
---@field quality Enum.ItemQuality

---@class PerksVendorItemUIGroupInfo
---@field ID number
---@field name string
---@field priority number

---@class PerksVendorSubItemInfo
---@field name string
---@field itemID number
---@field itemModifiedAppearanceID number
---@field invType string
---@field quality Enum.ItemQuality
