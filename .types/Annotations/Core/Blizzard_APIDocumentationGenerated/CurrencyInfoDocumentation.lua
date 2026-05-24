---@meta _
C_CurrencyInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.CanTransferCurrency)
---@param currencyID number
---@return boolean canTransferCurrency
---@return Enum.AccountCurrencyTransferResult? failureReason
function C_CurrencyInfo.CanTransferCurrency(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.DoesCurrentFilterRequireAccountCurrencyData)
---@return boolean doesCurrentFilterRequireAccountCurrencyData
function C_CurrencyInfo.DoesCurrentFilterRequireAccountCurrencyData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.DoesWarModeBonusApply)
---@param currencyID number
---@return boolean? warModeApplies
---@return boolean? limitOncePerTooltip
function C_CurrencyInfo.DoesWarModeBonusApply(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.ExpandCurrencyList)
---@param index number
---@param expand boolean
function C_CurrencyInfo.ExpandCurrencyList(index, expand) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters)
---@param currencyID number
---@return CharacterCurrencyData[] accountCurrencyData
function C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.FetchCurrencyTransferTransactions)
---@return CurrencyTransferTransaction[] currencyTransferTransactions
function C_CurrencyInfo.FetchCurrencyTransferTransactions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetAzeriteCurrencyID)
---@return number azeriteCurrencyID
function C_CurrencyInfo.GetAzeriteCurrencyID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetBackpackCurrencyInfo)
---@param index number
---@return BackpackCurrencyInfo info
function C_CurrencyInfo.GetBackpackCurrencyInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetBasicCurrencyInfo)
---@param currencyType number
---@param quantity? number
---@return CurrencyDisplayInfo info
function C_CurrencyInfo.GetBasicCurrencyInfo(currencyType, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCoinIcon)
---@param amount WOWMONEY
---@return fileID result
function C_CurrencyInfo.GetCoinIcon(amount) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCoinText)
---@param amount WOWMONEY
---@param separator? string Default = , 
---@return string result
function C_CurrencyInfo.GetCoinText(amount, separator) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCoinTextureString)
---@param amount WOWMONEY
---@param fontHeight? number Default = 14
---@return string result
function C_CurrencyInfo.GetCoinTextureString(amount, fontHeight) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCostToTransferCurrency)
---@param currencyID number
---@param quantity number
---@return number? totalQuantityConsumed
function C_CurrencyInfo.GetCostToTransferCurrency(currencyID, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyContainerInfo)
---@param currencyType number
---@param quantity number
---@return CurrencyDisplayInfo info
function C_CurrencyInfo.GetCurrencyContainerInfo(currencyType, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyDescription)
---@param type number
---@return string description
function C_CurrencyInfo.GetCurrencyDescription(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyFilter)
---@return Enum.CurrencyFilterType filterType
function C_CurrencyInfo.GetCurrencyFilter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyIDFromLink)
---@param currencyLink string
---@return number currencyID
function C_CurrencyInfo.GetCurrencyIDFromLink(currencyLink) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyInfo)
---@param type number
---@return CurrencyInfo info
function C_CurrencyInfo.GetCurrencyInfo(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyInfoFromLink)
---@param link string
---@return CurrencyInfo info
function C_CurrencyInfo.GetCurrencyInfoFromLink(link) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyLink)
---@param type number
---@param amount? number
---@return string link
function C_CurrencyInfo.GetCurrencyLink(type, amount) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyListInfo)
---@param index number
---@return CurrencyInfo info
function C_CurrencyInfo.GetCurrencyListInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyListLink)
---@param index number
---@return string link
function C_CurrencyInfo.GetCurrencyListLink(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCurrencyListSize)
---@return number currencyListSize
function C_CurrencyInfo.GetCurrencyListSize() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetDragonIslesSuppliesCurrencyID)
---@return number dragonIslesSuppliesCurrencyID
function C_CurrencyInfo.GetDragonIslesSuppliesCurrencyID() end

---Gets the faction ID for currency that is immediately converted into reputation with that faction instead.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetFactionGrantedByCurrency)
---@param currencyID number
---@return number? factionID
function C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetMaxTransferableAmountFromQuantity)
---@param currencyID number
---@param requestedQuantity number
---@return number? maxTransferableAmount
function C_CurrencyInfo.GetMaxTransferableAmountFromQuantity(currencyID, requestedQuantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetWarResourcesCurrencyID)
---@return number warResourceCurrencyID
function C_CurrencyInfo.GetWarResourcesCurrencyID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.IsAccountCharacterCurrencyDataReady)
---@return boolean isReady
function C_CurrencyInfo.IsAccountCharacterCurrencyDataReady() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.IsAccountTransferableCurrency)
---@param currencyID number
---@return boolean isAccountTransferableCurrency
function C_CurrencyInfo.IsAccountTransferableCurrency(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.IsAccountWideCurrency)
---@param currencyID number
---@return boolean isAccountWideCurrency
function C_CurrencyInfo.IsAccountWideCurrency(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.IsCurrencyContainer)
---@param currencyID number
---@param quantity number
---@return boolean isCurrencyContainer
function C_CurrencyInfo.IsCurrencyContainer(currencyID, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.IsCurrencyTransferInProgress)
---@return boolean currencyTransferInProgress
function C_CurrencyInfo.IsCurrencyTransferInProgress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.IsCurrencyTransferTransactionDataReady)
---@return boolean isReady
function C_CurrencyInfo.IsCurrencyTransferTransactionDataReady() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.PickupCurrency)
---@param type number
function C_CurrencyInfo.PickupCurrency(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.PlayerHasMaxQuantity)
---@param currencyID number
---@return boolean hasMaxQuantity
function C_CurrencyInfo.PlayerHasMaxQuantity(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.PlayerHasMaxWeeklyQuantity)
---@param currencyID number
---@return boolean hasMaxWeeklyQuantity
function C_CurrencyInfo.PlayerHasMaxWeeklyQuantity(currencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.RequestCurrencyDataForAccountCharacters)
function C_CurrencyInfo.RequestCurrencyDataForAccountCharacters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.RequestCurrencyFromAccountCharacter)
---@param sourceCharacterGUID WOWGUID
---@param currencyID number
---@param quantity number
function C_CurrencyInfo.RequestCurrencyFromAccountCharacter(sourceCharacterGUID, currencyID, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.SetCurrencyBackpack)
---@param index number
---@param backpack boolean
function C_CurrencyInfo.SetCurrencyBackpack(index, backpack) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.SetCurrencyBackpackByID)
---@param currencyType number
---@param backpack boolean
function C_CurrencyInfo.SetCurrencyBackpackByID(currencyType, backpack) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.SetCurrencyFilter)
---@param filterType Enum.CurrencyFilterType
function C_CurrencyInfo.SetCurrencyFilter(filterType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.SetCurrencyUnused)
---@param index number
---@param unused boolean
function C_CurrencyInfo.SetCurrencyUnused(index, unused) end

---@class BackpackCurrencyInfo
---@field name string
---@field quantity number
---@field iconFileID fileID
---@field currencyTypesID number

---@class CharacterCurrencyData
---@field characterGUID WOWGUID
---@field characterName string
---@field fullCharacterName string
---@field currencyID number
---@field quantity number

---@class CurrencyDisplayInfo
---@field name string
---@field description string
---@field icon number
---@field quality number
---@field displayAmount number
---@field actualAmount number

---@class CurrencyInfo
---@field name string
---@field description string
---@field currencyID number
---@field isHeader boolean
---@field isHeaderExpanded boolean
---@field currencyListDepth number
---@field isTypeUnused boolean
---@field isShowInBackpack boolean
---@field quantity number
---@field trackedQuantity number
---@field iconFileID fileID
---@field maxQuantity number
---@field canEarnPerWeek boolean
---@field quantityEarnedThisWeek number
---@field isTradeable boolean
---@field quality Enum.ItemQuality
---@field maxWeeklyQuantity number
---@field totalEarned number
---@field discovered boolean
---@field useTotalEarnedForMaxQty boolean
---@field isAccountWide boolean
---@field isAccountTransferable boolean
---@field transferPercentage number?
---@field rechargingCycleDurationMS number
---@field rechargingAmountPerCycle number

---@class CurrencyTransferTransaction
---@field sourceCharacterGUID WOWGUID
---@field sourceCharacterName string? Default = 
---@field fullSourceCharacterName string? Default = 
---@field destinationCharacterGUID WOWGUID
---@field destinationCharacterName string? Default = 
---@field fullDestinationCharacterName string? Default = 
---@field currencyType number
---@field quantityTransferred number
---@field totalQuantityConsumed number
---@field timestamp time_t
