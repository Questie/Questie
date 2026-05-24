---@meta _
---@class CraftingOrderBucketInfo
---@field itemID number
---@field spellID number
---@field skillLineAbilityID number
---@field tipAmountAvg WOWMONEY
---@field tipAmountMax WOWMONEY
---@field numAvailable number

---@class CraftingOrderClaimsRemainingInfo
---@field claimsRemaining number? Default = 0
---@field secondsToRecharge number?

---@class CraftingOrderCustomerCategory
---@field categoryName string
---@field categoryID number
---@field uiSortOrder number
---@field primaryCategorySortOrder number?
---@field secondaryCategorySortOrder number?
---@field type Enum.CraftingOrderCustomerCategoryType

---@class CraftingOrderCustomerCategoryFilters
---@field primaryCategoryID number?
---@field secondaryCategoryID number?
---@field tertiaryCategoryID number?

---@class CraftingOrderCustomerOptionInfo
---@field skillLineAbilityID number
---@field professionID number
---@field skillUpSkillLineID number
---@field spellID number
---@field itemID number
---@field itemName string
---@field primaryCategoryID number
---@field iLvlMin number
---@field iLvlMax number?
---@field canUse boolean
---@field bindOnPickup boolean
---@field qualityIlvlBonuses number[]?
---@field craftingQualityIDs number[]?
---@field quality Enum.ItemQuality?
---@field slots number?
---@field level number?
---@field skill number?
---@field secondaryCategoryID number?
---@field tertiaryCategoryID number?
---@field expansionID number?

---@class CraftingOrderCustomerSearchParams
---@field categoryFilters CraftingOrderCustomerCategoryFilters
---@field searchText string?
---@field minLevel number
---@field maxLevel number
---@field uncollectedOnly boolean
---@field usableOnly boolean
---@field upgradesOnly boolean
---@field currentExpansionOnly boolean
---@field includePoor boolean
---@field includeCommon boolean
---@field includeUncommon boolean
---@field includeRare boolean
---@field includeEpic boolean
---@field includeLegendary boolean
---@field includeArtifact boolean
---@field isFavoritesSearch boolean

---@class CraftingOrderCustomerSearchResults
---@field options CraftingOrderCustomerOptionInfo[]
---@field extraColumnType Enum.AuctionHouseExtraColumn?

---@class CraftingOrderInfo
---@field orderID BigUInteger
---@field itemID number
---@field spellID number
---@field skillLineAbilityID number
---@field orderType Enum.CraftingOrderType
---@field orderState Enum.CraftingOrderState
---@field expirationTime time_t
---@field claimEndTime time_t
---@field minQuality number
---@field tipAmount WOWMONEY
---@field consortiumCut WOWMONEY
---@field isRecraft boolean
---@field isFulfillable boolean
---@field reagentState Enum.CraftingOrderReagentsType
---@field customerGuid WOWGUID?
---@field customerName string?
---@field crafterGuid WOWGUID?
---@field crafterName string?
---@field npcCustomerCreatureID number?
---@field customerNotes string
---@field reagents CraftingOrderReagentInfo[]
---@field outputItemHyperlink string?
---@field outputItemGUID WOWGUID?
---@field recraftItemHyperlink string?
---@field npcOrderRewards CraftingOrderRewardInfo[]
---@field npcCraftingOrderSetID number
---@field npcTreasureID number

---@class CraftingOrderMailInfo
---@field reason Enum.RcoCloseReason
---@field recipeName string
---@field commissionPaid WOWMONEY?
---@field crafterNote string?
---@field crafterGUID WOWGUID?
---@field crafterName string?
---@field customerGUID WOWGUID?
---@field customerName string?

---@class CraftingOrderPersonalOrdersInfo
---@field profession Enum.Profession
---@field numPersonalOrders number
---@field professionName string

---@class CraftingOrderReagentInfo
---@field reagent CraftingReagentInfo
---@field slotIndex number
---@field source Enum.CraftingOrderReagentSource
---@field isBasicReagent boolean

---@class CraftingOrderRewardInfo
---@field itemLink string?
---@field currencyType number?
---@field count number

---@class CraftingOrderSortInfo
---@field sortType Enum.CraftingOrderSortType
---@field reversed boolean

---@class NewCraftingOrderInfo
---@field skillLineAbilityID number
---@field orderType Enum.CraftingOrderType
---@field orderDuration Enum.CraftingOrderDuration
---@field tipAmount WOWMONEY
---@field customerNotes string
---@field reagentItems RegularReagentInfo[]
---@field craftingReagentItems CraftingReagentInfo[]
---@field minCraftingQualityID number?
---@field orderTarget string?
---@field recraftItem WOWGUID?

---@alias CraftingOrderRequestCallback FunctionContainer|fun(result: Enum.CraftingOrderResult, orderType: Enum.CraftingOrderType, displayBuckets: boolean, expectMoreRows: boolean, offset: number, isSorted: boolean)

---@alias CraftingOrderRequestMyOrdersCallback FunctionContainer|fun(result: Enum.CraftingOrderResult, expectMoreRows: boolean, offset: number, isSorted: boolean)
