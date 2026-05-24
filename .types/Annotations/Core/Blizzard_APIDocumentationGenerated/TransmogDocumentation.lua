---@meta _
C_Transmog = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.ApplyAllPending)
---@param currentSpecOnly? boolean Default = false
---@return boolean requestSent
function C_Transmog.ApplyAllPending(currentSpecOnly) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.CanHaveSecondaryAppearanceForSlotID)
---@param slotID number
---@return boolean canHaveSecondaryAppearance
function C_Transmog.CanHaveSecondaryAppearanceForSlotID(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.CanTransmogItem)
---@param itemInfo ItemInfo
---@return boolean canBeTransmogged
---@return string? selfFailureReason
---@return boolean canTransmogOthers
---@return string? othersFailureReason
function C_Transmog.CanTransmogItem(itemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.CanTransmogItemWithItem)
---@param targetItemInfo ItemInfo
---@param sourceItemInfo ItemInfo
---@return boolean canTransmog
---@return string? failureReason
function C_Transmog.CanTransmogItemWithItem(targetItemInfo, sourceItemInfo) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.ClearAllPending)
function C_Transmog.ClearAllPending() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.ClearPending)
---@param transmogLocation TransmogLocation
function C_Transmog.ClearPending(transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.Close)
function C_Transmog.Close() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.ExtractTransmogIDList)
---@param input string
---@return number[] transmogIDList
function C_Transmog.ExtractTransmogIDList(input) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetAllSetAppearancesByID)
---@param setID number
---@return TransmogSetItemInfo[]? setItems
function C_Transmog.GetAllSetAppearancesByID(setID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetApplyCost)
---@return number? cost
function C_Transmog.GetApplyCost() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetApplyWarnings)
---@return TransmogApplyWarningInfo[] warnings
function C_Transmog.GetApplyWarnings() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetBaseCategory)
---@param transmogID number
---@return Enum.TransmogCollectionType categoryID
function C_Transmog.GetBaseCategory(transmogID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetCreatureDisplayIDForSource)
---@param itemModifiedAppearanceID number
---@return number? creatureDisplayID
function C_Transmog.GetCreatureDisplayIDForSource(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetItemIDForSource)
---@param itemModifiedAppearanceID number
---@return number? itemID
function C_Transmog.GetItemIDForSource(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetPending)
---@param transmogLocation TransmogLocation
---@return TransmogPendingInfo pendingInfo
function C_Transmog.GetPending(transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetSlotEffectiveCategory)
---@param transmogLocation TransmogLocation
---@return Enum.TransmogCollectionType categoryID
function C_Transmog.GetSlotEffectiveCategory(transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetSlotForInventoryType)
---@param inventoryType number
---@return number slot
function C_Transmog.GetSlotForInventoryType(inventoryType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetSlotInfo)
---@param transmogLocation TransmogLocation
---@return boolean isTransmogrified
---@return boolean hasPending
---@return boolean isPendingCollected
---@return boolean canTransmogrify
---@return number cannotTransmogrifyReason
---@return boolean hasUndo
---@return boolean isHideVisual
---@return fileID? texture
function C_Transmog.GetSlotInfo(transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetSlotUseError)
---@param transmogLocation TransmogLocation
---@return number errorCode
---@return string errorString
function C_Transmog.GetSlotUseError(transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetSlotVisualInfo)
---@param transmogLocation TransmogLocation
---@return number baseSourceID
---@return number baseVisualID
---@return number appliedSourceID
---@return number appliedVisualID
---@return number pendingSourceID
---@return number pendingVisualID
---@return boolean hasUndo
---@return boolean isHideVisual
---@return number itemSubclass
function C_Transmog.GetSlotVisualInfo(transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.IsAtTransmogNPC)
---@return boolean isAtNPC
function C_Transmog.IsAtTransmogNPC() end

---Returns true if the only pending for the location's slot is a ToggleOff for the secondary appearance.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.IsSlotBeingCollapsed)
---@param transmogLocation TransmogLocation
---@return boolean isBeingCollapsed
function C_Transmog.IsSlotBeingCollapsed(transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.IsTransmogEnabled)
---@return boolean isTransmogEnabled
function C_Transmog.IsTransmogEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.LoadOutfit)
---@param outfitID number
function C_Transmog.LoadOutfit(outfitID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.SetPending)
---@param transmogLocation TransmogLocation
---@param pendingInfo TransmogPendingInfo
function C_Transmog.SetPending(transmogLocation, pendingInfo) end

---@class TransmogApplyWarningInfo
---@field itemLink string
---@field text string

---@class TransmogSetItemInfo
---@field itemID number
---@field itemModifiedAppearanceID number
---@field invSlot number
---@field invType string

---@class TransmogSlotInfo
---@field isTransmogrified boolean
---@field hasPending boolean
---@field isPendingCollected boolean
---@field canTransmogrify boolean
---@field cannotTransmogrifyReason number
---@field hasUndo boolean
---@field isHideVisual boolean
---@field texture fileID?

---@class TransmogSlotVisualInfo
---@field baseSourceID number
---@field baseVisualID number
---@field appliedSourceID number
---@field appliedVisualID number
---@field pendingSourceID number
---@field pendingVisualID number
---@field hasUndo boolean
---@field isHideVisual boolean
---@field itemSubclass number
