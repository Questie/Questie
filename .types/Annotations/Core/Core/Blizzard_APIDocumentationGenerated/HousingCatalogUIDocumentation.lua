---@meta _
C_HousingCatalog = {}

---Creates a new instance of a HousingCatalog searcher; This can be used to asynchronously search/filter the HousingCatalog without affecting/being restricted by the filter state of other Housing Catalog UI displays
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.CreateCatalogSearcher)
---@return HousingCatalogSearcher searcher
function C_HousingCatalog.CreateCatalogSearcher() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.DeletePreviewCartDecor)
---@param decorGUID WOWGUID
function C_HousingCatalog.DeletePreviewCartDecor(decorGUID) end

---Attempt to delete the entry from storage
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.DestroyEntry)
---@param entryID HousingCatalogEntryID
---@param destroyAll boolean
function C_HousingCatalog.DestroyEntry(entryID, destroyAll) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetAllFilterTagGroups)
---@return HousingCatalogFilterTagGroupInfo[] filterTagGroups
function C_HousingCatalog.GetAllFilterTagGroups() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetBundleInfo)
---@param bundleCatalogShopProductID number
---@return HousingBundleInfo? bundleInfo
function C_HousingCatalog.GetBundleInfo(bundleCatalogShopProductID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetCartSizeLimit)
---@return number cartSizeLimit
function C_HousingCatalog.GetCartSizeLimit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetCatalogCategoryInfo)
---@param categoryID number
---@return HousingCatalogCategoryInfo? info
function C_HousingCatalog.GetCatalogCategoryInfo(categoryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetCatalogEntryInfo)
---@param entryID HousingCatalogEntryID
---@return HousingCatalogEntryInfo? info
function C_HousingCatalog.GetCatalogEntryInfo(entryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetCatalogEntryInfoByItem)
---@param itemInfo ItemInfo
---@param tryGetOwnedInfo boolean
---@return HousingCatalogEntryInfo? info
function C_HousingCatalog.GetCatalogEntryInfoByItem(itemInfo, tryGetOwnedInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetCatalogEntryInfoByRecordID)
---@param entryType Enum.HousingCatalogEntryType
---@param recordID number
---@param tryGetOwnedInfo boolean
---@return HousingCatalogEntryInfo? info
function C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, tryGetOwnedInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID)
---@param entryType Enum.HousingCatalogEntryType
---@param recordID number
---@return time_t? refundTimeStamp
function C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID(entryType, recordID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetCatalogSubcategoryInfo)
---@param subcategoryID number
---@return HousingCatalogSubcategoryInfo? info
function C_HousingCatalog.GetCatalogSubcategoryInfo(subcategoryID) end

---Returns the maximum total number of decor that can be in storage/in the house chest; Note that not all decor entries in storage count towards this limit (see GetDecorTotalOwnedCount)
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetDecorMaxOwnedCount)
---@return number maxOwnedCount
function C_HousingCatalog.GetDecorMaxOwnedCount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetDecorTotalOwnedCount)
---@return number totalOwnedCount
---@return number exemptDecorCount
function C_HousingCatalog.GetDecorTotalOwnedCount() end

---Returns the number of instances that can be to be destroyed in storage; These instances count towards the max storage limit
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetDestroyableInstanceCount)
---@param entryID HousingCatalogEntryID
---@return number destroyableInstanceCount
function C_HousingCatalog.GetDestroyableInstanceCount(entryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetFeaturedBundles)
---@return HousingBundleInfo[] bundleInfos
function C_HousingCatalog.GetFeaturedBundles() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetFeaturedDecor)
---@return HousingFeaturedDecorEntry[] entryInfos
function C_HousingCatalog.GetFeaturedDecor() end

---Returns market info for a specific decor. This is decor-only for now but should be extended to support entry type and recordID generically
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.GetMarketInfoForDecor)
---@param decorID number
---@return HousingMarketInfo? marketInfo
function C_HousingCatalog.GetMarketInfoForDecor(decorID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.HasFeaturedEntries)
---@return boolean hasEntries
function C_HousingCatalog.HasFeaturedEntries() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.IsPreviewCartItemShown)
---@param decorGUID WOWGUID
---@return boolean isShown
function C_HousingCatalog.IsPreviewCartItemShown(decorGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.PromotePreviewDecor)
---@param decorID number
---@param previewDecorGUID WOWGUID
---@return boolean success
function C_HousingCatalog.PromotePreviewDecor(decorID, previewDecorGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.RequestHousingMarketInfoRefresh)
function C_HousingCatalog.RequestHousingMarketInfoRefresh() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.RequestHousingMarketRefundInfo)
function C_HousingCatalog.RequestHousingMarketRefundInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.SearchCatalogCategories)
---@param searchParams HousingCategorySearchInfo
---@return number[] categoryIDs
function C_HousingCatalog.SearchCatalogCategories(searchParams) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.SearchCatalogSubcategories)
---@param searchParams HousingCategorySearchInfo
---@return number[] subcategoryIDs
function C_HousingCatalog.SearchCatalogSubcategories(searchParams) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingCatalog.SetPreviewCartItemShown)
---@param decorGUID WOWGUID
---@param shown boolean
function C_HousingCatalog.SetPreviewCartItemShown(decorGUID, shown) end

---@class HousingBundleDecorEntryInfo
---@field decorID number
---@field quantity number

---@class HousingBundleInfo
---@field price number
---@field originalPrice number?
---@field productID number
---@field decorEntries HousingBundleDecorEntryInfo[]
---@field canPreview boolean? Default = true

---@class HousingCatalogCategoryInfo
---@field ID number
---@field orderIndex number
---@field name string?
---@field icon textureAtlas?
---@field subcategoryIDs number[]
---@field anyOwnedEntries boolean

---@class HousingCatalogEntryInfo
---@field entryID HousingCatalogEntryID
---@field itemID number?
---@field name string
---@field asset ModelAsset?
---@field iconTexture FileAsset?
---@field iconAtlas textureAtlas?
---@field uiModelSceneID number?
---@field categoryIDs number[]
---@field subcategoryIDs number[]
---@field dataTagsByID LuaValueVariant
---@field size Enum.HousingCatalogEntrySize
---@field placementCost number
---@field showQuantity boolean
---@field quantity number
---@field remainingRedeemable number
---@field destroyableInstanceCount number
---@field numPlaced number
---@field isUniqueTrophy boolean
---@field isAllowedOutdoors boolean
---@field isAllowedIndoors boolean
---@field canCustomize boolean
---@field isPrefab boolean
---@field quality Enum.ItemQuality?
---@field customizations string[]
---@field dyeIDs number[]
---@field firstAcquisitionBonus number
---@field sourceText string

---@class HousingCatalogSubcategoryInfo
---@field ID number
---@field orderIndex number
---@field parentCategoryID number
---@field name string?
---@field icon textureAtlas?
---@field anyOwnedEntries boolean

---@class HousingCategorySearchInfo
---@field withOwnedEntriesOnly boolean? Default = false
---@field includeFeaturedCategory boolean? Default = false
---@field editorModeContext Enum.HouseEditorMode?

---@class HousingFeaturedDecorEntry
---@field entryID HousingCatalogEntryID
---@field productID number

---@class HousingMarketInfo
---@field price number
---@field productID number
---@field bundleIDs number[]

---@class HousingPreviewItemData
---@field decorGUID WOWGUID?
---@field productID number?
---@field bundleCatalogShopProductID number?
---@field isBundleParent boolean
---@field isBundleChild boolean
---@field id number
---@field decorID number
---@field name string
---@field icon number
---@field price number
---@field salePrice number?
