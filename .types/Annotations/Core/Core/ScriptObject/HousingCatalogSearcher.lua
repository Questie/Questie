---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/ScriptObject_HousingCatalogSearcher)
---@class HousingCatalogSearcher
local HousingCatalogSearcher = {}

---Returns all catalog entries being searched (note these are NOT search results, this is the source collection of what's being searched)
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetAllSearchItems)
---@return HousingCatalogEntryID[] matchingEntryIDs
function HousingCatalogSearcher:GetAllSearchItems() end

---Returns the most recent search result entries
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetCatalogSearchResults)
---@return HousingCatalogEntryID[] matchingEntryIDs
function HousingCatalogSearcher:GetCatalogSearchResults() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetEditorModeContext)
---@return Enum.HouseEditorMode? editorModeContext
function HousingCatalogSearcher:GetEditorModeContext() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetFilterTagStatus)
---@param groupID number
---@param tagID number
---@return boolean active
function HousingCatalogSearcher:GetFilterTagStatus(groupID, tagID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetFilteredCategoryID)
---@return number? categoryID
function HousingCatalogSearcher:GetFilteredCategoryID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetFilteredSubcategoryID)
---@return number? subcategoryID
function HousingCatalogSearcher:GetFilteredSubcategoryID() end

---Returns the total number of entries being searched through
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetNumSearchItems)
---@return number numSearchItems
function HousingCatalogSearcher:GetNumSearchItems() end

---Returns the total number of owned instances across all most recent search result entries
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetSearchCount)
---@return number searchCount
function HousingCatalogSearcher:GetSearchCount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetSearchText)
---@return string? searchText
function HousingCatalogSearcher:GetSearchText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_GetSortType)
---@return Enum.HousingCatalogSortType sortType
function HousingCatalogSearcher:GetSortType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsAllowedIndoorsActive)
---@return boolean isActive
function HousingCatalogSearcher:IsAllowedIndoorsActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsAllowedOutdoorsActive)
---@return boolean isActive
function HousingCatalogSearcher:IsAllowedOutdoorsActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsCollectedActive)
---@return boolean isActive
function HousingCatalogSearcher:IsCollectedActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsCustomizableOnlyActive)
---@return boolean isActive
function HousingCatalogSearcher:IsCustomizableOnlyActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsDistinctPerRecordIDActive)
---@return boolean isActive
function HousingCatalogSearcher:IsDistinctPerRecordIDActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsFirstAcquisitionBonusOnlyActive)
---@return boolean isActive
function HousingCatalogSearcher:IsFirstAcquisitionBonusOnlyActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsOwnedOnlyActive)
---@return boolean isActive
function HousingCatalogSearcher:IsOwnedOnlyActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsSearchInProgress)
---@return boolean isSearchInProgress
function HousingCatalogSearcher:IsSearchInProgress() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_IsUncollectedActive)
---@return boolean isActive
function HousingCatalogSearcher:IsUncollectedActive() end

---Run search with all current param values
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_RunSearch)
function HousingCatalogSearcher:RunSearch() end

---Set the toggle state of all filter tags within a specific group; If active, only entries that match Any of the tags in the group will be included in search results
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetAllInFilterTagGroup)
---@param groupID number
---@param active boolean
function HousingCatalogSearcher:SetAllInFilterTagGroup(groupID, active) end

---Search parameter; If true, entries that can be placed in house interiors will be included in the search; Note many decor objects can be placed both indoors and outdoors, so having only this toggled on may still include decor that can also be placed outdoors
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetAllowedIndoors)
---@param isActive boolean
function HousingCatalogSearcher:SetAllowedIndoors(isActive) end

---Search parameter; If true, entries that can be placed outside in plots will be included in the search; Note many decor objects can be placed both indoors and outdoors, so having only this toggled on may still include decor that can also be placed indoors
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetAllowedOutdoors)
---@param isActive boolean
function HousingCatalogSearcher:SetAllowedOutdoors(isActive) end

---If true, searcher automatically updates results whenever search param values are changed
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetAutoUpdateOnParamChanges)
---@param autoUpdateActive boolean
function HousingCatalogSearcher:SetAutoUpdateOnParamChanges(autoUpdateActive) end

---Search parameter; If true, includes all owned entries, including those that are in storage OR placed in an owned house or plot; See IsOwnedOnlyActive for a more exclusive toggle
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetCollected)
---@param isActive boolean
function HousingCatalogSearcher:SetCollected(isActive) end

---Search parameter; If true, catalog entries that cannot be customized (ie dyed) will be excluded from the search
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetCustomizableOnly)
---@param isActive boolean
function HousingCatalogSearcher:SetCustomizableOnly(isActive) end

---Search parameter; If true, only the first entry per recordID will be included
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetDistinctPerRecordID)
---@param isActive boolean
function HousingCatalogSearcher:SetDistinctPerRecordID(isActive) end

---Search parameter; If set, limits search results to only entries that are used/valid in the specified editor mode
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetEditorModeContext)
---@param editorModeContext? Enum.HouseEditorMode
function HousingCatalogSearcher:SetEditorModeContext(editorModeContext) end

---Set the toggle state of a single filter tag within a specific group
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetFilterTagStatus)
---@param groupID number
---@param tagID number
---@param active boolean
function HousingCatalogSearcher:SetFilterTagStatus(groupID, tagID, active) end

---Search parameter; If set, limits search results to only those within the specified category
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetFilteredCategoryID)
---@param categoryID? number
function HousingCatalogSearcher:SetFilteredCategoryID(categoryID) end

---Search parameter; If set, limits search results to only those within the specified subcategory
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetFilteredSubcategoryID)
---@param subcategoryID? number
function HousingCatalogSearcher:SetFilteredSubcategoryID(subcategoryID) end

---Search parameter; If true, excludes any entries that do not reward house xp when acquired for the first time
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetFirstAcquisitionBonusOnly)
---@param isActive boolean
function HousingCatalogSearcher:SetFirstAcquisitionBonusOnly(isActive) end

---Search parameter; If true, only entries that you own, and have instances of available in storage, will be included; This does not include entries that you own but have all been placed in a house; See IsCollectedActive for param that includes placed entries
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetOwnedOnly)
---@param isActive boolean
function HousingCatalogSearcher:SetOwnedOnly(isActive) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetResultsUpdatedCallback)
---@param callback HousingCatalogSearchResultsUpdatedCallback
function HousingCatalogSearcher:SetResultsUpdatedCallback(callback) end

---Search parameter; If set, multiple text fields are checked for instances of the text, including name, category, subcategory, and data tags
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetSearchText)
---@param searchText? string
function HousingCatalogSearcher:SetSearchText(searchText) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetSortType)
---@param sortType Enum.HousingCatalogSortType
function HousingCatalogSearcher:SetSortType(sortType) end

---Search parameter; If true, includes entries that are not owned, meaning not available in storage nor placed in any owned houses or plots
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_SetUncollected)
---@param isActive boolean
function HousingCatalogSearcher:SetUncollected(isActive) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleAllowedIndoors)
function HousingCatalogSearcher:ToggleAllowedIndoors() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleAllowedOutdoors)
function HousingCatalogSearcher:ToggleAllowedOutdoors() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleCollected)
function HousingCatalogSearcher:ToggleCollected() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleCustomizableOnly)
function HousingCatalogSearcher:ToggleCustomizableOnly() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleDistinctPerRecordID)
function HousingCatalogSearcher:ToggleDistinctPerRecordID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleFilterTag)
---@param groupID number
---@param tagID number
function HousingCatalogSearcher:ToggleFilterTag(groupID, tagID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleFirstAcquisitionBonusOnly)
function HousingCatalogSearcher:ToggleFirstAcquisitionBonusOnly() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleOwnedOnly)
function HousingCatalogSearcher:ToggleOwnedOnly() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingCatalogSearcher_ToggleUncollected)
function HousingCatalogSearcher:ToggleUncollected() end

---@alias HousingCatalogSearchResultsUpdatedCallback FunctionContainer|fun()
