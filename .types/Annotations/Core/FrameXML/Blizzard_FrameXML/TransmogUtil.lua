---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/TransmogLocationMixin)
---@class TransmogPendingInfoMixin
TransmogPendingInfoMixin = {}

--- See [CreateAndInitFromMixin](https://www.townlong-yak.com/framexml/go/CreateAndInitFromMixin)
---@param pendingType Enum.TransmogPendingType
---@param transmogID number
---@param category number
function TransmogPendingInfoMixin:Init(pendingType, transmogID, category) end

---@class TransmogLocationType
---@field slotID? InventorySlots
---@field type? Enum.TransmogType
---@field modification? Enum.TransmogModification

---[Documentation](https://warcraft.wiki.gg/wiki/TransmogLocationMixin)
---@class TransmogLocationMixin : TransmogLocationType
TransmogLocationMixin = {}

---@param slotID number
---@param transmogType Enum.TransmogType
---@param modification Enum.TransmogModification
function TransmogLocationMixin:Set(slotID, transmogType, modification) end

---@return boolean
function TransmogLocationMixin:IsAppearance() end

---@return boolean
function TransmogLocationMixin:IsIllusion() end

---@return number slotID
function TransmogLocationMixin:GetSlotID() end

---@return string slotName
function TransmogLocationMixin:GetSlotName() end

---@return boolean
function TransmogLocationMixin:IsEitherHand() end

---@return boolean
function TransmogLocationMixin:IsMainHand() end

---@return boolean
function TransmogLocationMixin:IsOffHand() end

---@param transmogLocation TransmogLocationMixin
---@return boolean
function TransmogLocationMixin:IsEqual(transmogLocation) end

---@return number armorCategoryID
function TransmogLocationMixin:GetArmorCategoryID() end

---@return number lookupKey
function TransmogLocationMixin:GetLookupKey() end

---@return boolean
function TransmogLocationMixin:IsSecondary() end
