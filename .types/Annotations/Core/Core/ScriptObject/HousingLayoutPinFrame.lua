---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/ScriptObject_HousingLayoutPinFrame)
---@class HousingLayoutPinFrame
local HousingLayoutPinFrame = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_CanMove)
---@return Enum.HousingLayoutRestriction moveRestriction
function HousingLayoutPinFrame:CanMove() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_CanRemove)
---@return Enum.HousingLayoutRestriction removalRestriction
function HousingLayoutPinFrame:CanRemove() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_CanRotate)
---@return Enum.HousingLayoutRestriction rotateRestriction
function HousingLayoutPinFrame:CanRotate() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_Drag)
---@param isAccessible boolean
function HousingLayoutPinFrame:Drag(isAccessible) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_GetDoorConnectionInfo)
---@return DoorConnectionInfo? connectionInfo
function HousingLayoutPinFrame:GetDoorConnectionInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_GetPinType)
---@return Enum.HousingLayoutPinType type
function HousingLayoutPinFrame:GetPinType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_GetRoomGUID)
---@return WOWGUID roomGUID
function HousingLayoutPinFrame:GetRoomGUID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_GetRoomName)
---@return string? name
function HousingLayoutPinFrame:GetRoomName() end

---Returns true if this pin's associated room, or anything attached to it, is selected. Ex: If pin is for a door, returns true if its room, or any other doors on that room, are selected
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_IsAnyPartOfRoomSelected)
---@return boolean isSelected
function HousingLayoutPinFrame:IsAnyPartOfRoomSelected() end

---Will be nil if pin is not a Door
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_IsOccupiedDoor)
---@return boolean? isOccupied
function HousingLayoutPinFrame:IsOccupiedDoor() end

---Returns true if this pin's object is itself selected; See IsAnyPartOfRoomSelected for a broader Selected check
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_IsSelected)
---@return boolean isSelected
function HousingLayoutPinFrame:IsSelected() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_IsValid)
---@return boolean isValid
function HousingLayoutPinFrame:IsValid() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_IsValidForSelectedFloorplan)
---@return boolean isValid
function HousingLayoutPinFrame:IsValidForSelectedFloorplan() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_Select)
function HousingLayoutPinFrame:Select() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HousingLayoutPinFrame_SetUpdateCallback)
---@param cb PinUpdatedCallback
function HousingLayoutPinFrame:SetUpdateCallback(cb) end
