---@meta _
C_TransmogCollection = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.AccountCanCollectSource)
---@param sourceID number
---@return boolean hasItemData
---@return boolean canCollect
function C_TransmogCollection.AccountCanCollectSource(sourceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.AreAllCollectionTypeFiltersChecked)
---@return boolean areAllCollectionTypeFiltersChecked
function C_TransmogCollection.AreAllCollectionTypeFiltersChecked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.AreAllSourceTypeFiltersChecked)
---@return boolean areAllSourceTypeFiltersChecked
function C_TransmogCollection.AreAllSourceTypeFiltersChecked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.CanAppearanceHaveIllusion)
---@param appearanceID number
---@return boolean canHaveIllusion
function C_TransmogCollection.CanAppearanceHaveIllusion(appearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.ClearNewAppearance)
---@param visualID number
function C_TransmogCollection.ClearNewAppearance(visualID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.ClearSearch)
---@param searchType Enum.TransmogSearchType
---@return boolean completed
function C_TransmogCollection.ClearSearch(searchType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.DeleteOutfit)
---@param outfitID number
function C_TransmogCollection.DeleteOutfit(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.EndSearch)
function C_TransmogCollection.EndSearch() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAllAppearanceSources)
---@param itemAppearanceID number
---@return number[] itemModifiedAppearanceIDs
function C_TransmogCollection.GetAllAppearanceSources(itemAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAllFactionsShown)
---@return boolean shown
function C_TransmogCollection.GetAllFactionsShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAllRacesShown)
---@return boolean shown
function C_TransmogCollection.GetAllRacesShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAppearanceCameraID)
---@param itemAppearanceID number
---@param variation? Enum.TransmogCameraVariation
---@return number cameraID
function C_TransmogCollection.GetAppearanceCameraID(itemAppearanceID, variation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAppearanceCameraIDBySource)
---@param itemModifiedAppearanceID number
---@param variation? Enum.TransmogCameraVariation
---@return number cameraID
function C_TransmogCollection.GetAppearanceCameraIDBySource(itemModifiedAppearanceID, variation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAppearanceInfoBySource)
---@param itemModifiedAppearanceID number
---@return TransmogAppearanceInfoBySourceData info
function C_TransmogCollection.GetAppearanceInfoBySource(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAppearanceSourceDrops)
---@param itemModifiedAppearanceID number
---@return TransmogAppearanceJournalEncounterInfo[] encounterInfo
function C_TransmogCollection.GetAppearanceSourceDrops(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAppearanceSourceInfo)
---@param itemModifiedAppearanceID number
---@return Enum.TransmogCollectionType category
---@return number itemAppearanceID
---@return boolean canHaveIllusion
---@return fileID icon
---@return boolean isCollected
---@return string itemLink
---@return string transmoglink
---@return number? sourceType
---@return number itemSubClass
function C_TransmogCollection.GetAppearanceSourceInfo(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetAppearanceSources)
---@param appearanceID number
---@param categoryType? Enum.TransmogCollectionType
---@param transmogLocation? TransmogLocation
---@return AppearanceSourceInfo[] sources
function C_TransmogCollection.GetAppearanceSources(appearanceID, categoryType, transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetArtifactAppearanceStrings)
---@param appearanceID number
---@return string name
---@return string hyperlink
function C_TransmogCollection.GetArtifactAppearanceStrings(appearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetCategoryAppearances)
---@param category Enum.TransmogCollectionType
---@param transmogLocation? TransmogLocation
---@return TransmogCategoryAppearanceInfo[] appearances
function C_TransmogCollection.GetCategoryAppearances(category, transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetCategoryCollectedCount)
---@param category Enum.TransmogCollectionType
---@return number count
function C_TransmogCollection.GetCategoryCollectedCount(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetCategoryForItem)
---@param itemModifiedAppearanceID number
---@return Enum.TransmogCollectionType collectionCategory
function C_TransmogCollection.GetCategoryForItem(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetCategoryInfo)
---@param category Enum.TransmogCollectionType
---@return string name
---@return boolean? isWeapon Default = false
---@return boolean? canHaveIllusions Default = false
---@return boolean? canMainHand Default = false
---@return boolean? canOffHand Default = false
---@return boolean? canRanged Default = false
function C_TransmogCollection.GetCategoryInfo(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetCategoryTotal)
---@param category Enum.TransmogCollectionType
---@return number total
function C_TransmogCollection.GetCategoryTotal(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetClassFilter)
---@return number classID
function C_TransmogCollection.GetClassFilter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetCollectedShown)
---@return boolean shown
function C_TransmogCollection.GetCollectedShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetFallbackWeaponAppearance)
---@return number? appearanceID
function C_TransmogCollection.GetFallbackWeaponAppearance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetFilteredCategoryCollectedCount)
---@param category Enum.TransmogCollectionType
---@return number count
function C_TransmogCollection.GetFilteredCategoryCollectedCount(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetFilteredCategoryTotal)
---@param category Enum.TransmogCollectionType
---@return number total
function C_TransmogCollection.GetFilteredCategoryTotal(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetIllusionInfo)
---@param illusionID number
---@return TransmogIllusionInfo info
function C_TransmogCollection.GetIllusionInfo(illusionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetIllusionStrings)
---@param illusionID number
---@return string name
---@return string hyperlink
---@return string? sourceText
function C_TransmogCollection.GetIllusionStrings(illusionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetIllusions)
---@return TransmogIllusionInfo[] illusions
function C_TransmogCollection.GetIllusions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetInspectItemTransmogInfoList)
---@return ItemTransmogInfo[] list
function C_TransmogCollection.GetInspectItemTransmogInfoList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetIsAppearanceFavorite)
---@param itemAppearanceID number
---@return boolean isFavorite
function C_TransmogCollection.GetIsAppearanceFavorite(itemAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetItemInfo)
---@param itemInfo ItemInfo
---@return number itemAppearanceID
---@return number itemModifiedAppearanceID
function C_TransmogCollection.GetItemInfo(itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetItemTransmogInfoListFromOutfitHyperlink)
---@param hyperlink string
---@return ItemTransmogInfo[] list
function C_TransmogCollection.GetItemTransmogInfoListFromOutfitHyperlink(hyperlink) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetLatestAppearance)
---@return number visualID
---@return Enum.TransmogCollectionType category
function C_TransmogCollection.GetLatestAppearance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetNumMaxOutfits)
---@return number maxOutfits
function C_TransmogCollection.GetNumMaxOutfits() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetNumTransmogSources)
---@return number count
function C_TransmogCollection.GetNumTransmogSources() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetOutfitHyperlinkFromItemTransmogInfoList)
---@param itemTransmogInfoList ItemTransmogInfo[]
---@return string hyperlink
function C_TransmogCollection.GetOutfitHyperlinkFromItemTransmogInfoList(itemTransmogInfoList) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetOutfitInfo)
---@param outfitID number
---@return string name
---@return fileID icon
function C_TransmogCollection.GetOutfitInfo(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetOutfitItemTransmogInfoList)
---@param outfitID number
---@return ItemTransmogInfo[] list
function C_TransmogCollection.GetOutfitItemTransmogInfoList(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetOutfits)
---@return number[] outfitID
function C_TransmogCollection.GetOutfits() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetPairedArtifactAppearance)
---@param itemModifiedAppearanceID number
---@return number pairedItemModifiedAppearanceID
function C_TransmogCollection.GetPairedArtifactAppearance(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetSourceIcon)
---@param itemModifiedAppearanceID number
---@return fileID icon
function C_TransmogCollection.GetSourceIcon(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetSourceInfo)
---@param sourceID number
---@return AppearanceSourceInfo sourceInfo
function C_TransmogCollection.GetSourceInfo(sourceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetSourceItemID)
---@param itemModifiedAppearanceID number
---@return number itemID
function C_TransmogCollection.GetSourceItemID(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetSourceRequiredHoliday)
---@param itemModifiedAppearanceID number
---@return string holidayName
function C_TransmogCollection.GetSourceRequiredHoliday(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetUncollectedShown)
---@return boolean shown
function C_TransmogCollection.GetUncollectedShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.GetValidAppearanceSourcesForClass)
---@param appearanceID number
---@param classID number
---@param categoryType? Enum.TransmogCollectionType
---@param transmogLocation? TransmogLocation
---@return AppearanceSourceInfo[] sources
function C_TransmogCollection.GetValidAppearanceSourcesForClass(appearanceID, classID, categoryType, transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.HasFavorites)
---@return boolean hasFavorites
function C_TransmogCollection.HasFavorites() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.IsAppearanceHiddenVisual)
---@param appearanceID number
---@return boolean isHiddenVisual
function C_TransmogCollection.IsAppearanceHiddenVisual(appearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.IsCategoryValidForItem)
---@param category Enum.TransmogCollectionType
---@param itemInfo ItemInfo
---@return boolean isValid
function C_TransmogCollection.IsCategoryValidForItem(category, itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.IsNewAppearance)
---@param visualID number
---@return boolean isNew
function C_TransmogCollection.IsNewAppearance(visualID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.IsSearchDBLoading)
---@return boolean isLoading
function C_TransmogCollection.IsSearchDBLoading() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.IsSearchInProgress)
---@param searchType Enum.TransmogSearchType
---@return boolean inProgress
function C_TransmogCollection.IsSearchInProgress(searchType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.IsSourceTypeFilterChecked)
---@param index number
---@return boolean checked
function C_TransmogCollection.IsSourceTypeFilterChecked(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.IsUsingDefaultFilters)
---@return boolean isUsingDefaultFilters
function C_TransmogCollection.IsUsingDefaultFilters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.ModifyOutfit)
---@param outfitID number
---@param itemTransmogInfoList ItemTransmogInfo[]
function C_TransmogCollection.ModifyOutfit(outfitID, itemTransmogInfoList) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.NewOutfit)
---@param name string
---@param icon fileID
---@param itemTransmogInfoList ItemTransmogInfo[]
---@return number? outfitID
function C_TransmogCollection.NewOutfit(name, icon, itemTransmogInfoList) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.PlayerCanCollectSource)
---@param sourceID number
---@return boolean hasItemData
---@return boolean canCollect
function C_TransmogCollection.PlayerCanCollectSource(sourceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.PlayerHasTransmog)
---@param itemID number
---@param itemAppearanceModID? number Default = 0
---@return boolean hasTransmog
function C_TransmogCollection.PlayerHasTransmog(itemID, itemAppearanceModID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.PlayerHasTransmogByItemInfo)
---@param itemInfo ItemInfo
---@return boolean hasTransmog
function C_TransmogCollection.PlayerHasTransmogByItemInfo(itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance)
---@param itemModifiedAppearanceID number
---@return boolean hasTransmog
function C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.PlayerKnowsSource)
---@param sourceID number
---@return boolean isKnown
function C_TransmogCollection.PlayerKnowsSource(sourceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.RenameOutfit)
---@param outfitID number
---@param name string
function C_TransmogCollection.RenameOutfit(outfitID, name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SearchProgress)
---@param searchType Enum.TransmogSearchType
---@return number progress
function C_TransmogCollection.SearchProgress(searchType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SearchSize)
---@param searchType Enum.TransmogSearchType
---@return number size
function C_TransmogCollection.SearchSize(searchType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetAllCollectionTypeFilters)
---@param checked boolean
function C_TransmogCollection.SetAllCollectionTypeFilters(checked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetAllFactionsShown)
---@param shown boolean
function C_TransmogCollection.SetAllFactionsShown(shown) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetAllRacesShown)
---@param shown boolean
function C_TransmogCollection.SetAllRacesShown(shown) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetAllSourceTypeFilters)
---@param checked boolean
function C_TransmogCollection.SetAllSourceTypeFilters(checked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetClassFilter)
---@param classID number
function C_TransmogCollection.SetClassFilter(classID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetCollectedShown)
---@param shown boolean
function C_TransmogCollection.SetCollectedShown(shown) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetDefaultFilters)
function C_TransmogCollection.SetDefaultFilters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetIsAppearanceFavorite)
---@param itemAppearanceID number
---@param isFavorite boolean
function C_TransmogCollection.SetIsAppearanceFavorite(itemAppearanceID, isFavorite) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetSearch)
---@param searchType Enum.TransmogSearchType
---@param searchText string
---@return boolean completed
function C_TransmogCollection.SetSearch(searchType, searchText) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetSearchAndFilterCategory)
---@param category Enum.TransmogCollectionType
function C_TransmogCollection.SetSearchAndFilterCategory(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetSourceTypeFilter)
---@param index number
---@param checked boolean
function C_TransmogCollection.SetSourceTypeFilter(index, checked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.SetUncollectedShown)
---@param shown boolean
function C_TransmogCollection.SetUncollectedShown(shown) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogCollection.UpdateUsableAppearances)
function C_TransmogCollection.UpdateUsableAppearances() end

---@class TransmogAppearanceInfoBySourceData
---@field appearanceID number
---@field appearanceIsCollected boolean
---@field sourceIsCollected boolean
---@field sourceIsCollectedPermanent boolean
---@field sourceIsCollectedConditional boolean
---@field meetsTransmogPlayerCondition boolean
---@field appearanceHasAnyNonLevelRequirements boolean
---@field appearanceMeetsNonLevelRequirements boolean
---@field appearanceIsUsable boolean
---@field appearanceNumSources number
---@field sourceIsKnown boolean
---@field canDisplayOnPlayer boolean
---@field isAnySourceValidForPlayer boolean

---@class TransmogAppearanceJournalEncounterInfo
---@field instance string
---@field instanceType number
---@field tiers string[]
---@field encounter string
---@field difficulties string[]

---@class TransmogAppearanceSourceInfoData
---@field category Enum.TransmogCollectionType
---@field itemAppearanceID number
---@field canHaveIllusion boolean
---@field icon fileID
---@field isCollected boolean
---@field itemLink string
---@field transmoglink string
---@field sourceType number?
---@field itemSubClass number

---@class TransmogCategoryAppearanceInfo
---@field visualID number
---@field isCollected boolean
---@field isFavorite boolean
---@field isHideVisual boolean
---@field canDisplayOnPlayer boolean
---@field uiOrder number
---@field exclusions number
---@field isUsable boolean
---@field hasRequiredHoliday boolean
---@field hasActiveRequiredHoliday boolean
---@field alwaysShowItem boolean?

---@class TransmogCategoryInfo
---@field name string
---@field isWeapon boolean? Default = false
---@field canHaveIllusions boolean? Default = false
---@field canMainHand boolean? Default = false
---@field canOffHand boolean? Default = false

---@class TransmogIllusionInfo
---@field visualID number
---@field sourceID number
---@field icon fileID
---@field isCollected boolean
---@field isUsable boolean
---@field isHideVisual boolean

---@class TransmogOutfitInfo
---@field name string
---@field icon fileID
