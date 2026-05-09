---@meta _
C_MountJournal = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.ApplyMountEquipment)
---@param itemLocation ItemLocation
---@return boolean canContinue
function C_MountJournal.ApplyMountEquipment(itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.AreMountEquipmentEffectsSuppressed)
---@return boolean areEffectsSuppressed
function C_MountJournal.AreMountEquipmentEffectsSuppressed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.ClearFanfare)
---@param mountID number
function C_MountJournal.ClearFanfare(mountID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.ClearRecentFanfares)
function C_MountJournal.ClearRecentFanfares() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.Dismiss)
function C_MountJournal.Dismiss() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetAllCreatureDisplayIDsForMountID)
---@param mountID number
---@return number[] creatureDisplayIDs
function C_MountJournal.GetAllCreatureDisplayIDsForMountID(mountID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetAppliedMountEquipmentID)
---@return number? itemID
function C_MountJournal.GetAppliedMountEquipmentID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetCollectedDragonridingMounts)
---@return number[] mountIDs
function C_MountJournal.GetCollectedDragonridingMounts() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetCollectedFilterSetting)
---@param filterIndex number
---@return boolean isChecked
function C_MountJournal.GetCollectedFilterSetting(filterIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetDisplayedMountAllCreatureDisplayInfo)
---@param mountIndex number
---@return MountCreatureDisplayInfo[] allDisplayInfo
function C_MountJournal.GetDisplayedMountAllCreatureDisplayInfo(mountIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetDisplayedMountID)
---@param displayIndex number
---@return number mountID
function C_MountJournal.GetDisplayedMountID(displayIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetDisplayedMountInfo)
---@param displayIndex number
---@return string name
---@return number spellID
---@return fileID icon
---@return boolean isActive
---@return boolean isUsable
---@return number sourceType
---@return boolean isFavorite
---@return boolean isFactionSpecific
---@return Enum.PvPFaction? faction
---@return boolean shouldHideOnChar
---@return boolean isCollected
---@return number mountID
---@return boolean isSteadyFlight
function C_MountJournal.GetDisplayedMountInfo(displayIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetDisplayedMountInfoExtra)
---@param mountIndex number
---@return number? creatureDisplayInfoID
---@return string description
---@return string source
---@return boolean isSelfMount
---@return number mountTypeID
---@return number uiModelSceneID
---@return number animID
---@return number spellVisualKitID
---@return boolean disablePlayerMountPreview
function C_MountJournal.GetDisplayedMountInfoExtra(mountIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetDynamicFlightModeSpellID)
---@return number spellID
function C_MountJournal.GetDynamicFlightModeSpellID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetIsFavorite)
---@param mountIndex number
---@return boolean isFavorite
---@return boolean canSetFavorite
function C_MountJournal.GetIsFavorite(mountIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountAllCreatureDisplayInfoByID)
---@param mountID number
---@return MountCreatureDisplayInfo[] allDisplayInfo
function C_MountJournal.GetMountAllCreatureDisplayInfoByID(mountID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountEquipmentUnlockLevel)
---@return number level
function C_MountJournal.GetMountEquipmentUnlockLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountFromItem)
---@param itemID number
---@return number? mountID
function C_MountJournal.GetMountFromItem(itemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountFromSpell)
---@param spellID number
---@return number? mountID
function C_MountJournal.GetMountFromSpell(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountIDs)
---@return number[] mountIDs
function C_MountJournal.GetMountIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountInfoByID)
---@param mountID number
---@return string name
---@return number spellID
---@return fileID icon
---@return boolean isActive
---@return boolean isUsable
---@return number sourceType
---@return boolean isFavorite
---@return boolean isFactionSpecific
---@return Enum.PvPFaction? faction
---@return boolean shouldHideOnChar
---@return boolean isCollected
---@return number mountID
---@return boolean isSteadyFlight
function C_MountJournal.GetMountInfoByID(mountID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountInfoExtraByID)
---@param mountID number
---@return number? creatureDisplayInfoID
---@return string description
---@return string source
---@return boolean isSelfMount
---@return number mountTypeID
---@return number uiModelSceneID
---@return number animID
---@return number spellVisualKitID
---@return boolean disablePlayerMountPreview
function C_MountJournal.GetMountInfoExtraByID(mountID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountLink)
---@param spellID number
---@return string? mountCreatureDisplayInfoLink
function C_MountJournal.GetMountLink(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountUsabilityByID)
---@param mountID number
---@param checkIndoors boolean
---@return boolean isUsable
---@return string? useError
function C_MountJournal.GetMountUsabilityByID(mountID, checkIndoors) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetNumDisplayedMounts)
---@return number numMounts
function C_MountJournal.GetNumDisplayedMounts() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetNumMounts)
---@return number numMounts
function C_MountJournal.GetNumMounts() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetNumMountsNeedingFanfare)
---@return number numMountsNeedingFanfare
function C_MountJournal.GetNumMountsNeedingFanfare() end

---Returns whether the player has unlocked the ability to switch between Skyriding and steady flight styles for flying mounts .
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.IsDragonridingUnlocked)
---@return boolean isUnlocked
function C_MountJournal.IsDragonridingUnlocked() end

---Determines if the item is mount equipment based on its class and subclass.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.IsItemMountEquipment)
---@param itemLocation ItemLocation
---@return boolean isMountEquipment
function C_MountJournal.IsItemMountEquipment(itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.IsMountEquipmentApplied)
---@return boolean isApplied
function C_MountJournal.IsMountEquipmentApplied() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.IsSourceChecked)
---@param filterIndex number
---@return boolean isChecked
function C_MountJournal.IsSourceChecked(filterIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.IsTypeChecked)
---@param filterIndex number
---@return boolean isChecked
function C_MountJournal.IsTypeChecked(filterIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.IsUsingDefaultFilters)
---@return boolean isUsingDefaultFilters
function C_MountJournal.IsUsingDefaultFilters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.IsValidSourceFilter)
---@param filterIndex number
---@return boolean isValid
function C_MountJournal.IsValidSourceFilter(filterIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.IsValidTypeFilter)
---@param filterIndex number
---@return boolean isValid
function C_MountJournal.IsValidTypeFilter(filterIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.NeedsFanfare)
---@param mountID number
---@return boolean needsFanfare
function C_MountJournal.NeedsFanfare(mountID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.Pickup)
---@param displayIndex number
function C_MountJournal.Pickup(displayIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.PickupDynamicFlightMode)
function C_MountJournal.PickupDynamicFlightMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SetAllSourceFilters)
---@param isChecked boolean
function C_MountJournal.SetAllSourceFilters(isChecked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SetAllTypeFilters)
---@param isChecked boolean
function C_MountJournal.SetAllTypeFilters(isChecked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SetCollectedFilterSetting)
---@param filterIndex number
---@param isChecked boolean
function C_MountJournal.SetCollectedFilterSetting(filterIndex, isChecked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SetDefaultFilters)
function C_MountJournal.SetDefaultFilters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SetIsFavorite)
---@param mountIndex number
---@param isFavorite boolean
function C_MountJournal.SetIsFavorite(mountIndex, isFavorite) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SetSearch)
---@param searchValue string
function C_MountJournal.SetSearch(searchValue) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SetSourceFilter)
---@param filterIndex number
---@param isChecked boolean
function C_MountJournal.SetSourceFilter(filterIndex, isChecked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SetTypeFilter)
---@param filterIndex number
---@param isChecked boolean
function C_MountJournal.SetTypeFilter(filterIndex, isChecked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SummonByID)
---@param mountID number
function C_MountJournal.SummonByID(mountID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_MountJournal.SwapDynamicFlightMode)
function C_MountJournal.SwapDynamicFlightMode() end

---@class MountCreatureDisplayInfo
---@field creatureDisplayID number
---@field isVisible boolean

---@class MountInfo
---@field name string
---@field spellID number
---@field icon fileID
---@field isActive boolean
---@field isUsable boolean
---@field sourceType number
---@field isFavorite boolean
---@field isFactionSpecific boolean
---@field faction Enum.PvPFaction?
---@field shouldHideOnChar boolean
---@field isCollected boolean
---@field mountID number
---@field isSteadyFlight boolean

---@class MountInfoExtra
---@field creatureDisplayInfoID number?
---@field description string
---@field source string
---@field isSelfMount boolean
---@field mountTypeID number
---@field uiModelSceneID number
---@field animID number
---@field spellVisualKitID number
---@field disablePlayerMountPreview boolean
