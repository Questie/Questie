---@meta _
C_Transmog = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.CanHaveSecondaryAppearanceForSlotID)
---@param slotID number
---@return boolean canHaveSecondaryAppearance
function C_Transmog.CanHaveSecondaryAppearanceForSlotID(slotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.ExtractTransmogIDList)
---@param input string
---@return number[] transmogIDList
function C_Transmog.ExtractTransmogIDList(input) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetAllSetAppearancesByID)
---@param setID number
---@return TransmogSetItemInfo[]? setItems
function C_Transmog.GetAllSetAppearancesByID(setID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetItemIDForSource)
---@param itemModifiedAppearanceID number
---@return number? itemID
function C_Transmog.GetItemIDForSource(itemModifiedAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetSlotForInventoryType)
---@param inventoryType number
---@return number slot
function C_Transmog.GetSlotForInventoryType(inventoryType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.GetSlotVisualInfo)
---@param transmogLocation TransmogLocation
---@return TransmogSlotVisualInfo slotVisualInfo
function C_Transmog.GetSlotVisualInfo(transmogLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Transmog.IsAtTransmogNPC)
---@return boolean isAtNPC
function C_Transmog.IsAtTransmogNPC() end

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
