---@meta _
ItemLocation = {}

---@class ItemLocation : ItemLocationData, ItemLocationMixin

---@class ItemLocationData
---@field equipmentSlotIndex? number
---@field bagID? number
---@field slotIndex? number

---@class ItemLocationMixin
---[Documentation](https://warcraft.wiki.gg/wiki/ItemLocationMixin)
ItemLocationMixin = {}

---@return ItemLocation
function ItemLocation:CreateEmpty() end

---@param bagID number
---@param slotIndex number
---@return ItemLocation
function ItemLocation:CreateFromBagAndSlot(bagID, slotIndex) end

---@param equipmentSlotIndex number
---@return ItemLocation
function ItemLocation:CreateFromEquipmentSlot(equipmentSlotIndex) end

function ItemLocationMixin:Clear() end

---@param bagID number
---@param slotIndex number
function ItemLocationMixin:SetBagAndSlot(bagID, slotIndex) end

---@return number bagID
---@return number slotIndex
function ItemLocationMixin:GetBagAndSlot() end

---@param equipmentSlotIndex number
function ItemLocationMixin:SetEquipmentSlot(equipmentSlotIndex) end

---@return number
function ItemLocationMixin:GetEquipmentSlot() end

---@return boolean
function ItemLocationMixin:IsEquipmentSlot() end

---@return boolean
function ItemLocationMixin:IsBagAndSlot() end

---@return boolean
function ItemLocationMixin:HasAnyLocation() end

---@return boolean
function ItemLocationMixin:IsValid() end

---@param otherBagID number
---@param otherSlotIndex number
---@return boolean
function ItemLocationMixin:IsEqualToBagAndSlot(otherBagID, otherSlotIndex) end

---@param otherEquipmentSlotIndex number
---@return boolean
function ItemLocationMixin:IsEqualToEquipmentSlot(otherEquipmentSlotIndex) end

---@param otherItemLocation ItemLocation
---@return boolean
function ItemLocationMixin:IsEqualTo(otherItemLocation) end
