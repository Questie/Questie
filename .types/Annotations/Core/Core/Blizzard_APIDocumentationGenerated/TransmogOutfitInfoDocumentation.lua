---@meta _
C_TransmogOutfitInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.AddNewOutfit)
---@param name string
---@param icon fileID
function C_TransmogOutfitInfo.AddNewOutfit(name, icon) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.ChangeDisplayedOutfit)
---@param outfitID number
---@param trigger Enum.TransmogSituationTrigger
---@param toggleLock boolean
---@param allowRemoveOutfit boolean
function C_TransmogOutfitInfo.ChangeDisplayedOutfit(outfitID, trigger, toggleLock, allowRemoveOutfit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.ChangeViewedOutfit)
---@param outfitID number
function C_TransmogOutfitInfo.ChangeViewedOutfit(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.ClearAllPendingSituations)
function C_TransmogOutfitInfo.ClearAllPendingSituations() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.ClearAllPendingTransmogs)
function C_TransmogOutfitInfo.ClearAllPendingTransmogs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.ClearDisplayedOutfit)
---@param trigger Enum.TransmogSituationTrigger
---@param toggleLock boolean
function C_TransmogOutfitInfo.ClearDisplayedOutfit(trigger, toggleLock) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.CommitAndApplyAllPending)
---@param useAvailableDiscount boolean
function C_TransmogOutfitInfo.CommitAndApplyAllPending(useAvailableDiscount) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.CommitOutfitInfo)
---@param outfitID number
---@param name string
---@param icon fileID
function C_TransmogOutfitInfo.CommitOutfitInfo(outfitID, name, icon) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.CommitPendingSituations)
function C_TransmogOutfitInfo.CommitPendingSituations() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetActiveOutfitID)
---@return number outfitID
function C_TransmogOutfitInfo.GetActiveOutfitID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetAllSlotLocationInfo)
---@return TransmogOutfitSlotInfo[] appearanceSlotInfo
---@return TransmogOutfitSlotInfo[] illusionSlotInfo
function C_TransmogOutfitInfo.GetAllSlotLocationInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetCollectionInfoForSlotAndOption)
---@param slot Enum.TransmogOutfitSlot
---@param weaponOption Enum.TransmogOutfitSlotOption
---@param collectionType Enum.TransmogCollectionType
---@return TransmogOutfitWeaponCollectionInfo collectionInfo
function C_TransmogOutfitInfo.GetCollectionInfoForSlotAndOption(slot, weaponOption, collectionType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID)
---@return number outfitID
function C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetEquippedSlotOptionFromTransmogSlot)
---@param slot Enum.TransmogOutfitSlot
---@return Enum.TransmogOutfitSlotOption weaponOption
function C_TransmogOutfitInfo.GetEquippedSlotOptionFromTransmogSlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetIllusionDefaultIMAIDForCollectionType)
---@param collectionType Enum.TransmogCollectionType
---@return number imaID
function C_TransmogOutfitInfo.GetIllusionDefaultIMAIDForCollectionType(collectionType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetItemModifiedAppearanceEffectiveCategory)
---@param imaID number
---@return Enum.TransmogCollectionType categoryID
function C_TransmogOutfitInfo.GetItemModifiedAppearanceEffectiveCategory(imaID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetLinkedSlotInfo)
---@param slot Enum.TransmogOutfitSlot
---@return TransmogOutfitLinkedSlotInfo linkedSlotInfo
function C_TransmogOutfitInfo.GetLinkedSlotInfo(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetMaxNumberOfTotalOutfitsForSource)
---@param source Enum.TransmogOutfitEntrySource
---@return number maxOutfitCount
function C_TransmogOutfitInfo.GetMaxNumberOfTotalOutfitsForSource(source) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetMaxNumberOfUsableOutfits)
---@return number maxOutfitCount
function C_TransmogOutfitInfo.GetMaxNumberOfUsableOutfits() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetNextOutfitCost)
---@return BigUInteger outfitCost
function C_TransmogOutfitInfo.GetNextOutfitCost() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetNumberOfOutfitsUnlockedForSource)
---@param source Enum.TransmogOutfitEntrySource
---@return number unlockedOutfitCount
function C_TransmogOutfitInfo.GetNumberOfOutfitsUnlockedForSource(source) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetOutfitInfo)
---@param outfitID number
---@return TransmogOutfitEntryInfo outfitsInfo
function C_TransmogOutfitInfo.GetOutfitInfo(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetOutfitSituation)
---@param option TransmogSituationOption
---@return boolean value
function C_TransmogOutfitInfo.GetOutfitSituation(option) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetOutfitSituationsEnabled)
---@return boolean enabled
function C_TransmogOutfitInfo.GetOutfitSituationsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetOutfitsInfo)
---@return TransmogOutfitEntryInfo[] outfitsInfo
function C_TransmogOutfitInfo.GetOutfitsInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetPendingTransmogCost)
---@return BigUInteger cost
function C_TransmogOutfitInfo.GetPendingTransmogCost() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetSecondarySlotState)
---@param slot Enum.TransmogOutfitSlot
---@return boolean state
function C_TransmogOutfitInfo.GetSecondarySlotState(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetSetSourcesForSlot)
---@param transmogSetID number
---@param slot Enum.TransmogOutfitSlot
---@return AppearanceSourceInfo[] sources
function C_TransmogOutfitInfo.GetSetSourcesForSlot(transmogSetID, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetSlotGroupInfo)
---@return TransmogOutfitSlotGroup[] slotGroups
function C_TransmogOutfitInfo.GetSlotGroupInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetSourceIDsForSlot)
---@param transmogSetID number
---@param slot Enum.TransmogOutfitSlot
---@return number[] sources
function C_TransmogOutfitInfo.GetSourceIDsForSlot(transmogSetID, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetTransmogOutfitSlotForInventoryType)
---@param inventoryType number
---@return Enum.TransmogOutfitSlot slot
function C_TransmogOutfitInfo.GetTransmogOutfitSlotForInventoryType(inventoryType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetTransmogOutfitSlotFromInventorySlot)
---@param inventorySlot InventorySlots
---@return Enum.TransmogOutfitSlot slot
function C_TransmogOutfitInfo.GetTransmogOutfitSlotFromInventorySlot(inventorySlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetUISituationCategoriesAndOptions)
---@return TransmogSituationCategory[] categoryData
function C_TransmogOutfitInfo.GetUISituationCategoriesAndOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetUnassignedAtlasForSlot)
---@param slot Enum.TransmogOutfitSlot
---@return textureAtlas atlas
function C_TransmogOutfitInfo.GetUnassignedAtlasForSlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetUnassignedDisplayAtlasForSlot)
---@param slot Enum.TransmogOutfitSlot
---@return textureAtlas atlas
function C_TransmogOutfitInfo.GetUnassignedDisplayAtlasForSlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetViewedOutfitSlotInfo)
---@param slot Enum.TransmogOutfitSlot
---@param type Enum.TransmogType
---@param option Enum.TransmogOutfitSlotOption
---@return ViewedTransmogOutfitSlotInfo slotInfo
function C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, type, option) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.GetWeaponOptionsForSlot)
---@param slot Enum.TransmogOutfitSlot
---@return TransmogOutfitWeaponOptionInfo[] weaponOptions
---@return TransmogOutfitWeaponOptionInfo[]? artifactOptions
function C_TransmogOutfitInfo.GetWeaponOptionsForSlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.HasPendingOutfitSituations)
---@return boolean hasPending
function C_TransmogOutfitInfo.HasPendingOutfitSituations() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.HasPendingOutfitTransmogs)
---@return boolean hasPending
function C_TransmogOutfitInfo.HasPendingOutfitTransmogs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.InTransmogEvent)
---@return boolean inTransmogEvent
function C_TransmogOutfitInfo.InTransmogEvent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.IsEquippedGearOutfitDisplayed)
---@return boolean isDisplayed
function C_TransmogOutfitInfo.IsEquippedGearOutfitDisplayed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.IsEquippedGearOutfitLocked)
---@return boolean isLocked
function C_TransmogOutfitInfo.IsEquippedGearOutfitLocked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.IsLockedOutfit)
---@param outfitID number
---@return boolean isLocked
function C_TransmogOutfitInfo.IsLockedOutfit(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.IsSlotWeaponSlot)
---@param slot Enum.TransmogOutfitSlot
---@return boolean isWeaponSlot
function C_TransmogOutfitInfo.IsSlotWeaponSlot(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.IsUsableDiscountAvailable)
---@return boolean isAvailable
function C_TransmogOutfitInfo.IsUsableDiscountAvailable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.IsValidTransmogOutfitName)
---@param name string
---@return boolean isApproved
function C_TransmogOutfitInfo.IsValidTransmogOutfitName(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.PickupOutfit)
---@param outfitID number
function C_TransmogOutfitInfo.PickupOutfit(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.ResetOutfitSituations)
function C_TransmogOutfitInfo.ResetOutfitSituations() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.RevertPendingTransmog)
---@param slot Enum.TransmogOutfitSlot
---@param type Enum.TransmogType
---@param option Enum.TransmogOutfitSlotOption
function C_TransmogOutfitInfo.RevertPendingTransmog(slot, type, option) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.SetOutfitSituationsEnabled)
---@param enabled boolean
function C_TransmogOutfitInfo.SetOutfitSituationsEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.SetOutfitToCustomSet)
---@param transmogCustomSetID number
function C_TransmogOutfitInfo.SetOutfitToCustomSet(transmogCustomSetID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.SetOutfitToOutfit)
---@param outfitID number
function C_TransmogOutfitInfo.SetOutfitToOutfit(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.SetOutfitToSet)
---@param transmogSetID number
function C_TransmogOutfitInfo.SetOutfitToSet(transmogSetID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.SetPendingTransmog)
---@param slot Enum.TransmogOutfitSlot
---@param type Enum.TransmogType
---@param option Enum.TransmogOutfitSlotOption
---@param transmogID number
---@param displayType Enum.TransmogOutfitDisplayType
function C_TransmogOutfitInfo.SetPendingTransmog(slot, type, option, transmogID, displayType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.SetSecondarySlotState)
---@param slot Enum.TransmogOutfitSlot
---@param state boolean
function C_TransmogOutfitInfo.SetSecondarySlotState(slot, state) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.SetViewedWeaponOptionForSlot)
---@param slot Enum.TransmogOutfitSlot
---@param weaponOption Enum.TransmogOutfitSlotOption
function C_TransmogOutfitInfo.SetViewedWeaponOptionForSlot(slot, weaponOption) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.SlotHasSecondary)
---@param slot Enum.TransmogOutfitSlot
---@return boolean hasSecondary
function C_TransmogOutfitInfo.SlotHasSecondary(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.TransmogEventActive)
---@return boolean transmogEventActive
function C_TransmogOutfitInfo.TransmogEventActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TransmogOutfitInfo.UpdatePendingSituation)
---@param option TransmogSituationOption
---@param value boolean
function C_TransmogOutfitInfo.UpdatePendingSituation(option, value) end

---@class TransmogOutfitEntryInfo
---@field outfitID number
---@field name string
---@field situationCategories string[]
---@field icon fileID
---@field isEventOutfit boolean
---@field isDisabled boolean

---@class TransmogOutfitLinkedSlotInfo
---@field primarySlotInfo TransmogOutfitSlotInfo
---@field secondarySlotInfo TransmogOutfitSlotInfo

---@class TransmogOutfitSlotGroup
---@field position Enum.TransmogOutfitSlotPosition
---@field appearanceSlotInfo TransmogOutfitSlotInfo[]
---@field illusionSlotInfo TransmogOutfitSlotInfo[]

---@class TransmogOutfitSlotInfo
---@field slot Enum.TransmogOutfitSlot
---@field type Enum.TransmogType
---@field collectionType Enum.TransmogCollectionType
---@field slotName string
---@field isSecondary boolean

---@class TransmogOutfitWeaponCollectionInfo
---@field name string
---@field isWeapon boolean
---@field canHaveIllusions boolean

---@class TransmogOutfitWeaponOptionInfo
---@field weaponOption Enum.TransmogOutfitSlotOption
---@field name string
---@field enabled boolean

---@class TransmogSituationCategory
---@field triggerID number
---@field name string
---@field description string
---@field isRadioButton boolean
---@field groupData TransmogSituationGroup[]

---@class TransmogSituationGroup
---@field groupID number
---@field secondaryID number
---@field optionData TransmogSituationOptionData[]

---@class TransmogSituationOption
---@field situationID number
---@field specID number
---@field loadoutID number
---@field equipmentSetID number

---@class TransmogSituationOptionData
---@field name string
---@field value boolean
---@field option TransmogSituationOption

---@class ViewedTransmogOutfitSlotInfo
---@field transmogID number
---@field displayType Enum.TransmogOutfitDisplayType
---@field isTransmogrified boolean
---@field hasPending boolean
---@field isPendingCollected boolean
---@field canTransmogrify boolean
---@field warning Enum.TransmogOutfitSlotWarning
---@field warningText string
---@field error Enum.TransmogOutfitSlotError
---@field errorText string
---@field texture fileID?
