---@meta _
C_AccountStore = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.BeginPurchase)
---@param itemID number
---@return boolean purchaseStarted
function C_AccountStore.BeginPurchase(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.GetCategories)
---@param storeFrontID number
---@return number[] categories
function C_AccountStore.GetCategories(storeFrontID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.GetCategoryInfo)
---@param categoryID number
---@return AccountStoreCategoryInfo info
function C_AccountStore.GetCategoryInfo(categoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.GetCategoryItems)
---@param categoryID number
---@return number[] itemIDs
function C_AccountStore.GetCategoryItems(categoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.GetCurrencyAvailable)
---@param currencyID number
---@return number amount
function C_AccountStore.GetCurrencyAvailable(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.GetCurrencyIDForStore)
---@param storeFrontID number
---@return number? currencyID
function C_AccountStore.GetCurrencyIDForStore(storeFrontID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.GetCurrencyInfo)
---@param currencyID number
---@return AccountStoreCurrencyInfo info
function C_AccountStore.GetCurrencyInfo(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.GetItemInfo)
---@param itemID number
---@return AccountStoreItemInfo? info
function C_AccountStore.GetItemInfo(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.GetStoreFrontState)
---@param storeFrontID number
---@return Enum.AccountStoreState state
function C_AccountStore.GetStoreFrontState(storeFrontID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.RefundItem)
---@param itemID number
---@return boolean refundStarted
function C_AccountStore.RefundItem(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AccountStore.RequestStoreFrontInfoUpdate)
---@param storeFrontID number
function C_AccountStore.RequestStoreFrontInfoUpdate(storeFrontID) end

---@class AccountStoreCategoryInfo
---@field id number
---@field name string
---@field type Enum.AccountStoreCategoryType
---@field icon fileID

---@class AccountStoreCurrencyInfo
---@field id number
---@field amount number
---@field maxQuantity number?
---@field name string
---@field icon fileID

---@class AccountStoreItemInfo
---@field id number
---@field status Enum.AccountStoreItemStatus
---@field currencyID number
---@field flags Enum.AccountStoreItemFlag
---@field customUIModelSceneID number?
---@field name string
---@field description string?
---@field price number
---@field nonrefundable boolean
---@field creatureDisplayID number?
---@field transmogSetID number?
---@field displayIcon fileID?
---@field refundSecondsRemaining time_t?
