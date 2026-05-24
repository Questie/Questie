---@meta _
C_CatalogShop = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.BulkPurchaseProducts)
---@param productIDs number[]
---@return boolean canPurchaseProducts
function C_CatalogShop.BulkPurchaseProducts(productIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.BulkRefundDecors)
---@param decorGUIDs WOWGUID[]
function C_CatalogShop.BulkRefundDecors(decorGUIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.CloseCatalogShopInteraction)
function C_CatalogShop.CloseCatalogShopInteraction() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.ConfirmHousingPurchase)
---@param productIDs number[]
function C_CatalogShop.ConfirmHousingPurchase(productIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.FindBestCurrencyProductForNeededAmount)
---@param vcCurrencyCode string
---@param amountNeeded number
---@return number? vcProductID
function C_CatalogShop.FindBestCurrencyProductForNeededAmount(vcCurrencyCode, amountNeeded) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetAvailableCategoryIDs)
---@return number[] categoryIDs
function C_CatalogShop.GetAvailableCategoryIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetAvailableTransmogRaceInfos)
---@return AvailableRaceInfo[] raceIDs
function C_CatalogShop.GetAvailableTransmogRaceInfos() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetCatalogShopProductDisplayInfo)
---@param catalogShopProductID number
---@return CatalogShopProductDisplayInfo item
function C_CatalogShop.GetCatalogShopProductDisplayInfo(catalogShopProductID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetCategoryInfo)
---@param categoryID number
---@return CatalogShopCategoryInfo categoryInfo
function C_CatalogShop.GetCategoryInfo(categoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetCategorySectionInfo)
---@param categoryID number
---@param sectionID number
---@return CatalogShopSectionInfo sectionInfo
function C_CatalogShop.GetCategorySectionInfo(categoryID, sectionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetFailureInfo)
---@return StoreError? errorResultEnum
---@return number? errorResultRaw
function C_CatalogShop.GetFailureInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetFirstCategoryByProductID)
---@param productID number
---@return CatalogShopCategoryInfo? categoryInfo
function C_CatalogShop.GetFirstCategoryByProductID(productID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetNewProducts)
---@return number[] newProducts
function C_CatalogShop.GetNewProducts() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetProductAvailabilityTimeRemainingSecs)
---@param catalogShopProductID number
---@return number? timeRemainingSecs
function C_CatalogShop.GetProductAvailabilityTimeRemainingSecs(catalogShopProductID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetProductIDsForBundle)
---@param bundleProductID number
---@return CatalogShopBundleChildInfo[] childIDs
function C_CatalogShop.GetProductIDsForBundle(bundleProductID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetProductIDsForCategory)
---@param categoryID number
---@return number[] productIDs
function C_CatalogShop.GetProductIDsForCategory(categoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetProductIDsForCategorySection)
---@param categoryID number
---@param sectionID number
---@return number[] productIDs
function C_CatalogShop.GetProductIDsForCategorySection(categoryID, sectionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetProductInfo)
---@param productID number
---@return CatalogShopProductInfo? productInfo
function C_CatalogShop.GetProductInfo(productID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetProductSortOrder)
---@param categoryID number
---@param sectionID number
---@param productID number
---@return number? sortOrder
function C_CatalogShop.GetProductSortOrder(categoryID, sectionID, productID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetRefundableDecors)
---@param productIdFilterOpt? number
---@return RefundableDecorInfo[] refundableDecorInfos
---@return time_t minTimeRemainingSeconds
function C_CatalogShop.GetRefundableDecors(productIdFilterOpt) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetSectionIDsForCategory)
---@param categoryID number
---@return number[] sectionIDs
function C_CatalogShop.GetSectionIDsForCategory(categoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetSpellVisualInfoForMount)
---@param spellVisualID number
---@return CatalogShopSpellVisualInfo spellVisualInfo
function C_CatalogShop.GetSpellVisualInfoForMount(spellVisualID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetVCProductInfos)
---@return CatalogShopVCProductInfo[] vcProductInfos
function C_CatalogShop.GetVCProductInfos() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.GetVirtualCurrencyBalance)
---@param currencyCode string
---@return string? balance
function C_CatalogShop.GetVirtualCurrencyBalance(currencyCode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.HasNewProducts)
---@return boolean hasNewProducts
function C_CatalogShop.HasNewProducts() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.IsShop2Enabled)
---@return boolean? value
function C_CatalogShop.IsShop2Enabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.OnLegalDisclaimerClicked)
---@param catalogShopProductID number
function C_CatalogShop.OnLegalDisclaimerClicked(catalogShopProductID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.OnLegalPersonalizedOptOutClicked)
function C_CatalogShop.OnLegalPersonalizedOptOutClicked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.OpenCatalogShopInteractionFromHouse)
---@return string shoppingSessionUUIDStr
function C_CatalogShop.OpenCatalogShopInteractionFromHouse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.OpenCatalogShopInteractionFromShop)
---@return string shoppingSessionUUIDStr
function C_CatalogShop.OpenCatalogShopInteractionFromShop() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.ProductDisplayedTelemetry)
---@param categoryId number
---@param sectionId number
---@param catalogShopProductID number
function C_CatalogShop.ProductDisplayedTelemetry(categoryId, sectionId, catalogShopProductID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.ProductSelectedTelemetry)
---@param categoryId number
---@param sectionId number
---@param catalogShopProductID number
---@param wasCodeSelection boolean
function C_CatalogShop.ProductSelectedTelemetry(categoryId, sectionId, catalogShopProductID, wasCodeSelection) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.PurchaseProduct)
---@param productID number
---@return boolean canPurchase
function C_CatalogShop.PurchaseProduct(productID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.RefreshRefundableDecors)
function C_CatalogShop.RefreshRefundableDecors() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.RefreshVirtualCurrencyBalance)
---@param currencyCode string
function C_CatalogShop.RefreshVirtualCurrencyBalance(currencyCode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.ShouldShowHousingWarning)
---@return boolean shouldShowHousingWarning
function C_CatalogShop.ShouldShowHousingWarning() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CatalogShop.StartHousingVCPurchaseConfirmation)
---@param productID number
function C_CatalogShop.StartHousingVCPurchaseConfirmation(productID) end

---@class AvailableRaceInfo
---@field raceID number
---@field displayName string

---@class BulkPurchaseIndividualProductResult
---@field recordId number
---@field parentProductId number?
---@field entitlementId string
---@field externalTransactionId string
---@field status Enum.SimpleOrderStatus

---@class CatalogShopBundleChildInfo
---@field childProductID number
---@field displayOrder number
---@field quantityInBundle number

---@class CatalogShopCategoryInfo
---@field ID number
---@field displayName string
---@field iconTexture string
---@field linkTag string
---@field isDisabled boolean
---@field showPersistentRefundButton boolean

---@class CatalogShopProductDisplayInfo
---@field defaultPreviewModelSceneID number
---@field defaultCardModelSceneID number
---@field defaultWideCardModelSceneID number
---@field itemID number
---@field overridePreviewModelSceneID number?
---@field overrideCardModelSceneID number?
---@field overrideWideCardModelSceneID number?
---@field creatureDisplayInfoIDs number[]
---@field spellVisualIDs number[]
---@field mainHandItemModifiedAppearanceID number?
---@field offHandItemModifiedAppearanceID number?
---@field itemModifiedAppearanceIDs number[]
---@field iconFileDataID number?
---@field iconTextureKit textureKit?
---@field productType string?
---@field itemDescription string?
---@field hasUnknownLicense boolean
---@field productPMTURL string?
---@field otherProductImageAtlasName string?
---@field otherProductGameTitleBaseTag string?
---@field otherProductGameType string?
---@field customLoopingSoundStart number?
---@field customLoopingSoundMiddle number?
---@field customLoopingSoundEnd number?
---@field specialActorID_1 string?
---@field specialActorID_2 string?
---@field specialActorID_3 string?
---@field specialActorID_4 string?
---@field specialActorID_5 string?
---@field gameFlavorID number?
---@field decorFileDataID number?
---@field quantity number?

---@class CatalogShopProductInfo
---@field catalogShopProductID number
---@field name string
---@field type string?
---@field description string
---@field iconTexture string
---@field isFullyOwned boolean
---@field isPurchasePending boolean
---@field refundable boolean
---@field price string
---@field originalPrice string
---@field discountPercentage number
---@field itemID number
---@field mountID number
---@field mountTypeName string
---@field speciesID number
---@field transmogSetID number
---@field itemModifiedAppearanceID number
---@field subItems CatalogShopSubItemInfo[]
---@field subItemsLoaded boolean
---@field backgroundTexture string
---@field foregroundTexture string?
---@field smallCardBGTexture string?
---@field smallCardFGTexture string?
---@field wideCardBGTexture string?
---@field wideCardFGTexture string?
---@field previewIconTexture string?
---@field optionalWideCardBackgroundTexture string?
---@field isBundle boolean
---@field bundleChildrenSize number
---@field licenseTermType number
---@field licenseTermDuration number
---@field virtualCurrencies CatalogShopVirtualCurrency[]
---@field isHidden boolean
---@field hasPendingOrders boolean
---@field numBundleDetailCards number
---@field isDynamicallyDiscounted boolean
---@field shouldShowOriginalPrice boolean
---@field wideCardBGOverrideProductURL string?
---@field consumableQuantity number?
---@field isVCProduct boolean
---@field containsHousingItem boolean

---@class CatalogShopSectionInfo
---@field ID number
---@field displayName string
---@field parentCatalogShopCategoryInfoID number?
---@field cardType string?
---@field scrollGridSize number?
---@field shouldShowRecommendationOptOutDisclaimer boolean

---@class CatalogShopSpellVisualInfo
---@field animID number?
---@field spellVisualKitID number?

---@class CatalogShopSubItemInfo
---@field name string
---@field itemID number
---@field itemAppearanceID number
---@field invType string
---@field quality Enum.ItemQuality

---@class CatalogShopVCProductInfo
---@field vcProductID number

---@class CatalogShopVirtualCurrency
---@field amount number
---@field currencyCode string

---@class RefundableDecorInfo
---@field decorGUID WOWGUID
---@field timeRemainingSeconds time_t
---@field name string
---@field price string
