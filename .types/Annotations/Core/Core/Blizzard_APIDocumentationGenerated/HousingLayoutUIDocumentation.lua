---@meta _
C_HousingLayout = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.AnyRoomsOnFloor)
---@param floor number
---@return boolean anyRooms
function C_HousingLayout.AnyRoomsOnFloor(floor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.CancelActiveLayoutEditing)
function C_HousingLayout.CancelActiveLayoutEditing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.ConfirmStairChoice)
---@param choice? Enum.HousingLayoutStairDirection
function C_HousingLayout.ConfirmStairChoice(choice) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.DeselectFloorplan)
function C_HousingLayout.DeselectFloorplan() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.DeselectRoomOrDoor)
function C_HousingLayout.DeselectRoomOrDoor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetNumActiveRooms)
---@return number numRooms
function C_HousingLayout.GetNumActiveRooms() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetNumFloors)
---@return number numFloors
function C_HousingLayout.GetNumFloors() end

---Returns the max room placement budget for the current house interior; Can be increased via house level
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetRoomPlacementBudget)
---@return number placementBudget
function C_HousingLayout.GetRoomPlacementBudget() end

---If a door is selected, returns its component id and the guid of the room it belongs to; Otherwise returns nothing
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetSelectedDoor)
---@return number selectedDoorComponentID
---@return WOWGUID roomGUID
function C_HousingLayout.GetSelectedDoor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetSelectedFloorplan)
---@return number? roomID
function C_HousingLayout.GetSelectedFloorplan() end

---If a Room is selected, returns the room's guid; Otherwise returns nothing
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetSelectedRoom)
---@return WOWGUID roomGUID
function C_HousingLayout.GetSelectedRoom() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetSelectedStairwellRoomCount)
---@return number stairwellRoomCount
function C_HousingLayout.GetSelectedStairwellRoomCount() end

---Returns how much of the current house's room placement budget has been spent; Different kinds of rooms take up different budget amounts, so this value isn't an individual room count, see GetNumActiveRooms for that
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetSpentPlacementBudget)
---@return number spentPlacementBudget
function C_HousingLayout.GetSpentPlacementBudget() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.GetViewedFloor)
---@return number floor
function C_HousingLayout.GetViewedFloor() end

---Returns true if any room, door, or floorplan is currently selected or being dragged
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.HasAnySelections)
---@return boolean hasAnySelections
function C_HousingLayout.HasAnySelections() end

---Returns whether there's a max room placement budget available and active for the current player, in the current house interior
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.HasRoomPlacementBudget)
---@return boolean hasBudget
function C_HousingLayout.HasRoomPlacementBudget() end

---Returns true if a door component is currently selected
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.HasSelectedDoor)
---@return boolean hasSelectedDoor
function C_HousingLayout.HasSelectedDoor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.HasSelectedFloorplan)
---@return boolean hasSelectedFloorplan
function C_HousingLayout.HasSelectedFloorplan() end

---Returns true if a room is selected, will NOT return true if a door is selected
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.HasSelectedRoom)
---@return boolean hasSelectedRoom
function C_HousingLayout.HasSelectedRoom() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.HasStairs)
---@param roomRecordID number
---@return boolean hasStairs
function C_HousingLayout.HasStairs(roomRecordID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.HasValidConnection)
---@param roomGUID WOWGUID
---@param componentID number
---@param roomId number
---@return boolean canPlace
function C_HousingLayout.HasValidConnection(roomGUID, componentID, roomId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.IsBaseRoom)
---@param roomGUID WOWGUID
---@return boolean isBaseRoom
function C_HousingLayout.IsBaseRoom(roomGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.IsDraggingRoom)
---@return boolean isDragging
---@return boolean isAccessibleDrag
function C_HousingLayout.IsDraggingRoom() end

---Attempt to move the room currently being dragged to a specific connection point on a specific other room
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.MoveDraggedRoom)
---@param sourceDoorIndex number
---@param destRoom WOWGUID
---@param destDoorIndex number
function C_HousingLayout.MoveDraggedRoom(sourceDoorIndex, destRoom, destDoorIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.MoveLayoutCamera)
---@param direction Enum.HousingLayoutCameraDirection
---@param isPressed boolean
function C_HousingLayout.MoveLayoutCamera(direction, isPressed) end

---Attempt to return a previously placed room to the House Chest
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.RemoveRoom)
---@param roomGUID WOWGUID
function C_HousingLayout.RemoveRoom(roomGUID) end

---Rotates either the currently dragged or currently selected room, if either exist
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.RotateFocusedRoom)
---@param isLeft boolean
function C_HousingLayout.RotateFocusedRoom(isLeft) end

---Attempt to rotate an already placed room
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.RotateRoom)
---@param roomGUID WOWGUID
---@param isLeft boolean
function C_HousingLayout.RotateRoom(roomGUID, isLeft) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.SelectFloorplan)
---@param roomID number
function C_HousingLayout.SelectFloorplan(roomID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.SetViewedFloor)
---@param floor number
function C_HousingLayout.SetViewedFloor(floor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.StartDrag)
function C_HousingLayout.StartDrag() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.StopDrag)
function C_HousingLayout.StopDrag() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.StopDraggingRoom)
function C_HousingLayout.StopDraggingRoom() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingLayout.ZoomLayoutCamera)
---@param zoomIn boolean
---@return boolean zoomChanged
function C_HousingLayout.ZoomLayoutCamera(zoomIn) end
