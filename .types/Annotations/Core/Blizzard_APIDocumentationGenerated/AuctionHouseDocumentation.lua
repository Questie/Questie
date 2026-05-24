---@meta _
C_AuctionHouse = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.CalculateCommodityDeposit)
---@param itemID number
---@param duration number
---@param quantity number
---@return number? depositCost
function C_AuctionHouse.CalculateCommodityDeposit(itemID, duration, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.CalculateItemDeposit)
---@param item ItemLocation
---@param duration number
---@param quantity number
---@return number? depositCost
function C_AuctionHouse.CalculateItemDeposit(item, duration, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.CanCancelAuction)
---@param ownedAuctionID number
---@return boolean canCancelAuction
function C_AuctionHouse.CanCancelAuction(ownedAuctionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.CancelAuction)
---@param ownedAuctionID number
function C_AuctionHouse.CancelAuction(ownedAuctionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.CancelCommoditiesPurchase)
function C_AuctionHouse.CancelCommoditiesPurchase() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.CancelSell)
function C_AuctionHouse.CancelSell() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.CloseAuctionHouse)
function C_AuctionHouse.CloseAuctionHouse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.ConfirmCommoditiesPurchase)
---@param itemID number
---@param quantity number
function C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.ConfirmPostCommodity)
---@param item ItemLocation
---@param duration number
---@param quantity number
---@param unitPrice BigUInteger
function C_AuctionHouse.ConfirmPostCommodity(item, duration, quantity, unitPrice) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.ConfirmPostItem)
---@param item ItemLocation
---@param duration number
---@param quantity number
---@param bid? BigUInteger
---@param buyout? BigUInteger
function C_AuctionHouse.ConfirmPostItem(item, duration, quantity, bid, buyout) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.FavoritesAreAvailable)
---@return boolean favoritesAreAvailable
function C_AuctionHouse.FavoritesAreAvailable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetAuctionInfoByID)
---@param auctionID number
---@return AuctionInfo? priceInfo
function C_AuctionHouse.GetAuctionInfoByID(auctionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetAuctionItemSubClasses)
---@param classID number
---@return number[] subClasses
function C_AuctionHouse.GetAuctionItemSubClasses(classID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetAvailablePostCount)
---@param item ItemLocation
---@return number listCount
function C_AuctionHouse.GetAvailablePostCount(item) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetBidInfo)
---@param bidIndex number
---@return BidInfo? bid
function C_AuctionHouse.GetBidInfo(bidIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetBidType)
---@param bidTypeIndex number
---@return ItemKey? typeItemKey
function C_AuctionHouse.GetBidType(bidTypeIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetBids)
---@return BidInfo[] bids
function C_AuctionHouse.GetBids() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetBrowseResults)
---@return BrowseResultInfo[] browseResults
function C_AuctionHouse.GetBrowseResults() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetCancelCost)
---@param ownedAuctionID number
---@return BigUInteger cancelCost
function C_AuctionHouse.GetCancelCost(ownedAuctionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetCommoditySearchResultInfo)
---@param itemID number
---@param commoditySearchResultIndex number
---@return CommoditySearchResultInfo? result
function C_AuctionHouse.GetCommoditySearchResultInfo(itemID, commoditySearchResultIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetCommoditySearchResultsQuantity)
---@param itemID number
---@return number totalQuantity
function C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetExtraBrowseInfo)
---@param itemKey ItemKey
---@return number extraInfo
function C_AuctionHouse.GetExtraBrowseInfo(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetFilterGroups)
---@return AuctionHouseFilterGroup[] filterGroups
function C_AuctionHouse.GetFilterGroups() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetItemCommodityStatus)
---@param item ItemLocation
---@return Enum.ItemCommodityStatus isCommodity
function C_AuctionHouse.GetItemCommodityStatus(item) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetItemKeyFromItem)
---@param item ItemLocation
---@return ItemKey itemKey
function C_AuctionHouse.GetItemKeyFromItem(item) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetItemKeyInfo)
---@param itemKey ItemKey
---@param restrictQualityToFilter? boolean Default = false
---@return ItemKeyInfo? itemKeyInfo
function C_AuctionHouse.GetItemKeyInfo(itemKey, restrictQualityToFilter) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetItemKeyRequiredLevel)
---@param itemKey ItemKey
---@return number requiredLevel
function C_AuctionHouse.GetItemKeyRequiredLevel(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetItemSearchResultInfo)
---@param itemKey ItemKey
---@param itemSearchResultIndex number
---@return ItemSearchResultInfo? result
function C_AuctionHouse.GetItemSearchResultInfo(itemKey, itemSearchResultIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetItemSearchResultsQuantity)
---@param itemKey ItemKey
---@return number totalQuantity
function C_AuctionHouse.GetItemSearchResultsQuantity(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetMaxBidItemBid)
---@return BigUInteger? maxBid
function C_AuctionHouse.GetMaxBidItemBid() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetMaxBidItemBuyout)
---@return BigUInteger? maxBuyout
function C_AuctionHouse.GetMaxBidItemBuyout() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetMaxCommoditySearchResultPrice)
---@param itemID number
---@return BigUInteger? maxUnitPrice
function C_AuctionHouse.GetMaxCommoditySearchResultPrice(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetMaxItemSearchResultBid)
---@param itemKey ItemKey
---@return BigUInteger? maxBid
function C_AuctionHouse.GetMaxItemSearchResultBid(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetMaxItemSearchResultBuyout)
---@param itemKey ItemKey
---@return BigUInteger? maxBuyout
function C_AuctionHouse.GetMaxItemSearchResultBuyout(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetMaxOwnedAuctionBid)
---@return BigUInteger? maxBid
function C_AuctionHouse.GetMaxOwnedAuctionBid() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetMaxOwnedAuctionBuyout)
---@return BigUInteger? maxBuyout
function C_AuctionHouse.GetMaxOwnedAuctionBuyout() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetNumBidTypes)
---@return number numBidTypes
function C_AuctionHouse.GetNumBidTypes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetNumBids)
---@return number numBids
function C_AuctionHouse.GetNumBids() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetNumCommoditySearchResults)
---@param itemID number
---@return number numSearchResults
function C_AuctionHouse.GetNumCommoditySearchResults(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetNumItemSearchResults)
---@param itemKey ItemKey
---@return number numItemSearchResults
function C_AuctionHouse.GetNumItemSearchResults(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetNumOwnedAuctionTypes)
---@return number numOwnedAuctionTypes
function C_AuctionHouse.GetNumOwnedAuctionTypes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetNumOwnedAuctions)
---@return number numOwnedAuctions
function C_AuctionHouse.GetNumOwnedAuctions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetNumReplicateItems)
---@return number numReplicateItems
function C_AuctionHouse.GetNumReplicateItems() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetOwnedAuctionInfo)
---@param ownedAuctionIndex number
---@return OwnedAuctionInfo? ownedAuction
function C_AuctionHouse.GetOwnedAuctionInfo(ownedAuctionIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetOwnedAuctionType)
---@param ownedAuctionTypeIndex number
---@return ItemKey? typeItemKey
function C_AuctionHouse.GetOwnedAuctionType(ownedAuctionTypeIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetOwnedAuctions)
---@return OwnedAuctionInfo[] ownedAuctions
function C_AuctionHouse.GetOwnedAuctions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetQuoteDurationRemaining)
---@return number quoteDurationSeconds
function C_AuctionHouse.GetQuoteDurationRemaining() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetReplicateItemBattlePetInfo)
---@param index number
---@return number creatureID
---@return number displayID
function C_AuctionHouse.GetReplicateItemBattlePetInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetReplicateItemInfo)
---@param index number
---@return string? name
---@return fileID? texture
---@return number count
---@return number qualityID
---@return boolean? usable
---@return number level
---@return string? levelType
---@return BigUInteger minBid
---@return BigUInteger minIncrement
---@return BigUInteger buyoutPrice
---@return BigUInteger bidAmount
---@return string? highBidder
---@return string? bidderFullName
---@return string? owner
---@return string? ownerFullName
---@return number saleStatus
---@return number itemID
---@return boolean? hasAllInfo
function C_AuctionHouse.GetReplicateItemInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetReplicateItemLink)
---@param index number
---@return string? itemLink
function C_AuctionHouse.GetReplicateItemLink(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetReplicateItemTimeLeft)
---@param index number
---@return number timeLeft
function C_AuctionHouse.GetReplicateItemTimeLeft(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.GetTimeLeftBandInfo)
---@param timeLeftBand Enum.AuctionHouseTimeLeftBand
---@return number timeLeftMinSeconds
---@return number timeLeftMaxSeconds
function C_AuctionHouse.GetTimeLeftBandInfo(timeLeftBand) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.HasFavorites)
---@return boolean hasFavorites
function C_AuctionHouse.HasFavorites() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.HasFullBidResults)
---@return boolean hasFullBidResults
function C_AuctionHouse.HasFullBidResults() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.HasFullBrowseResults)
---@return boolean hasFullBrowseResults
function C_AuctionHouse.HasFullBrowseResults() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.HasFullCommoditySearchResults)
---@param itemID number
---@return boolean hasFullResults
function C_AuctionHouse.HasFullCommoditySearchResults(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.HasFullItemSearchResults)
---@param itemKey ItemKey
---@return boolean hasFullResults
function C_AuctionHouse.HasFullItemSearchResults(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.HasFullOwnedAuctionResults)
---@return boolean hasFullOwnedAuctionResults
function C_AuctionHouse.HasFullOwnedAuctionResults() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.HasMaxFavorites)
---@return boolean hasMaxFavorites
function C_AuctionHouse.HasMaxFavorites() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.HasSearchResults)
---@param itemKey ItemKey
---@return boolean hasSearchResults
function C_AuctionHouse.HasSearchResults(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.IsFavoriteItem)
---@param itemKey ItemKey
---@return boolean isFavorite
function C_AuctionHouse.IsFavoriteItem(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.IsSellItemValid)
---@param item ItemLocation
---@param displayError? boolean Default = true
---@return boolean valid
function C_AuctionHouse.IsSellItemValid(item, displayError) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.IsThrottledMessageSystemReady)
---@return boolean canSendThrottledMessage
function C_AuctionHouse.IsThrottledMessageSystemReady() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.MakeItemKey)
---@param itemID number
---@param itemLevel? number Default = 0
---@param itemSuffix? number Default = 0
---@param battlePetSpeciesID? number Default = 0
---@return ItemKey itemKey
function C_AuctionHouse.MakeItemKey(itemID, itemLevel, itemSuffix, battlePetSpeciesID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.PlaceBid)
---@param auctionID number
---@param bidAmount BigUInteger
function C_AuctionHouse.PlaceBid(auctionID, bidAmount) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.PostCommodity)
---@param item ItemLocation
---@param duration number
---@param quantity number
---@param unitPrice BigUInteger
---@return boolean needsConfirmation
function C_AuctionHouse.PostCommodity(item, duration, quantity, unitPrice) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.PostItem)
---@param item ItemLocation
---@param duration number
---@param quantity number
---@param bid? BigUInteger
---@param buyout? BigUInteger
---@return boolean needsConfirmation
function C_AuctionHouse.PostItem(item, duration, quantity, bid, buyout) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.QueryBids)
---@param sorts AuctionHouseSortType[]
---@param auctionIDs number[]
function C_AuctionHouse.QueryBids(sorts, auctionIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.QueryOwnedAuctions)
---@param sorts AuctionHouseSortType[]
function C_AuctionHouse.QueryOwnedAuctions(sorts) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.RefreshCommoditySearchResults)
---@param itemID number
function C_AuctionHouse.RefreshCommoditySearchResults(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.RefreshItemSearchResults)
---@param itemKey ItemKey
---@param minLevelFilter? number
---@param maxLevelFilter? number
function C_AuctionHouse.RefreshItemSearchResults(itemKey, minLevelFilter, maxLevelFilter) end

---This function should be used in place of an 'allItem' QueryAuctionItems call to query the entire auction house.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.ReplicateItems)
function C_AuctionHouse.ReplicateItems() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.RequestMoreBrowseResults)
function C_AuctionHouse.RequestMoreBrowseResults() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.RequestMoreCommoditySearchResults)
---@param itemID number
---@return boolean hasFullResults
function C_AuctionHouse.RequestMoreCommoditySearchResults(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.RequestMoreItemSearchResults)
---@param itemKey ItemKey
---@return boolean hasFullResults
function C_AuctionHouse.RequestMoreItemSearchResults(itemKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.RequestOwnedAuctionBidderInfo)
---@param auctionID number
---@return string bidderName
function C_AuctionHouse.RequestOwnedAuctionBidderInfo(auctionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.SearchForFavorites)
---@param sorts AuctionHouseSortType[]
function C_AuctionHouse.SearchForFavorites(sorts) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.SearchForItemKeys)
---@param itemKeys ItemKey[]
---@param sorts AuctionHouseSortType[]
function C_AuctionHouse.SearchForItemKeys(itemKeys, sorts) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.SendBrowseQuery)
---@param query AuctionHouseBrowseQuery
function C_AuctionHouse.SendBrowseQuery(query) end

---Search queries are restricted to 100 calls per minute. These should not be used to query the entire auction house. See ReplicateItems
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.SendSearchQuery)
---@param itemKey ItemKey
---@param sorts AuctionHouseSortType[]
---@param separateOwnerItems boolean
---@param minLevelFilter? number Default = 0
---@param maxLevelFilter? number Default = 0
function C_AuctionHouse.SendSearchQuery(itemKey, sorts, separateOwnerItems, minLevelFilter, maxLevelFilter) end

---Search queries are restricted to 100 calls per minute. These should not be used to query the entire auction house. See ReplicateItems. ItemKey should have its iLVL and suffix cleared before calling.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.SendSellSearchQuery)
---@param itemKey ItemKey
---@param sorts AuctionHouseSortType[]
---@param separateOwnerItems boolean
function C_AuctionHouse.SendSellSearchQuery(itemKey, sorts, separateOwnerItems) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.SetFavoriteItem)
---@param itemKey ItemKey
---@param setFavorite boolean
function C_AuctionHouse.SetFavoriteItem(itemKey, setFavorite) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.ShouldAutoPopulatePrice)
---@return boolean shouldAutoPopulatePrice
function C_AuctionHouse.ShouldAutoPopulatePrice() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.StartCommoditiesPurchase)
---@param itemID number
---@param quantity number
function C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AuctionHouse.SupportsCopperValues)
---@return boolean supportsCopperValues
function C_AuctionHouse.SupportsCopperValues() end

---@class AuctionHouseBrowseQuery
---@field searchString string
---@field sorts AuctionHouseSortType[]
---@field minLevel number?
---@field maxLevel number?
---@field filters Enum.AuctionHouseFilter[]?
---@field itemClassFilters AuctionHouseItemClassFilter[]?

---@class AuctionHouseFilterGroup
---@field category Enum.AuctionHouseFilterCategory
---@field filters Enum.AuctionHouseFilter[]

---@class AuctionHouseItemClassFilter
---@field classID number
---@field subClassID number?
---@field inventoryType Enum.InventoryType?

---@class AuctionHouseSortType
---@field sortOrder Enum.AuctionHouseSortOrder
---@field reverseSort boolean

---@class AuctionInfo
---@field itemKey ItemKey
---@field itemLink string?
---@field minBid WOWMONEY?
---@field bidAmount WOWMONEY?
---@field buyoutAmount WOWMONEY?
---@field bidder WOWGUID?

---@class BidInfo
---@field auctionID number
---@field itemKey ItemKey
---@field itemLink string?
---@field timeLeft Enum.AuctionHouseTimeLeftBand
---@field minBid BigUInteger?
---@field bidAmount BigUInteger?
---@field buyoutAmount BigUInteger?
---@field bidder WOWGUID?

---@class BrowseResultInfo
---@field itemKey ItemKey
---@field appearanceLink string?
---@field totalQuantity number
---@field minPrice BigUInteger
---@field containsOwnerItem boolean

---@class CommoditySearchResultInfo
---@field itemID number
---@field quantity number
---@field unitPrice BigUInteger
---@field auctionID number
---@field owners string[]
---@field totalNumberOfOwners number
---@field timeLeftSeconds number?
---@field numOwnerItems number
---@field containsOwnerItem boolean
---@field containsAccountItem boolean

---@class ItemKey
---@field itemID number
---@field itemLevel number? Default = 0
---@field itemSuffix number? Default = 0
---@field battlePetSpeciesID number? Default = 0

---@class ItemKeyInfo
---@field itemID number
---@field battlePetSpeciesID number
---@field itemName string
---@field battlePetLink string?
---@field appearanceLink string?
---@field quality Enum.ItemQuality
---@field iconFileID number
---@field isPet boolean
---@field isCommodity boolean
---@field isEquipment boolean

---@class ItemSearchResultInfo
---@field itemKey ItemKey
---@field owners string[]
---@field totalNumberOfOwners number
---@field timeLeft Enum.AuctionHouseTimeLeftBand
---@field auctionID number
---@field quantity number
---@field itemLink string?
---@field containsOwnerItem boolean
---@field containsAccountItem boolean
---@field containsSocketedItem boolean
---@field bidder WOWGUID?
---@field minBid BigUInteger?
---@field bidAmount BigUInteger?
---@field buyoutAmount BigUInteger?
---@field timeLeftSeconds number?

---@class OwnedAuctionInfo
---@field auctionID number
---@field itemKey ItemKey
---@field itemLink string?
---@field status Enum.AuctionStatus
---@field quantity number
---@field timeLeftSeconds number?
---@field timeLeft Enum.AuctionHouseTimeLeftBand?
---@field bidAmount BigUInteger?
---@field buyoutAmount BigUInteger?
---@field bidder string?

---@class ReplicateItemInfo
---@field name string?
---@field texture fileID?
---@field count number
---@field qualityID number
---@field usable boolean?
---@field level number
---@field levelType string?
---@field minBid BigUInteger
---@field minIncrement BigUInteger
---@field buyoutPrice BigUInteger
---@field bidAmount BigUInteger
---@field highBidder string?
---@field bidderFullName string?
---@field owner string?
---@field ownerFullName string?
---@field saleStatus number
---@field itemID number
---@field hasAllInfo boolean?
