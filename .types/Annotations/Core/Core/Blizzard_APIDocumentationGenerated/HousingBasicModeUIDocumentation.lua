---@meta _
C_HousingBasicMode = {}

---Cancels all in-progress editing of the selected target, which will reset any unsaved changes and deselect the active target; Un-placed decor will be returned to the house chest
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.CancelActiveEditing)
function C_HousingBasicMode.CancelActiveEditing() end

---Attempt to save the changes made to the currently selected decor instance
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.CommitDecorMovement)
function C_HousingBasicMode.CommitDecorMovement() end

---Attempt to save the changes made to the House Exterior's position within the plot
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.CommitHouseExteriorPosition)
function C_HousingBasicMode.CommitHouseExteriorPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.FinishPlacingNewDecor)
function C_HousingBasicMode.FinishPlacingNewDecor() end

---Returns info for the placed decor instance currently being hovered, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.GetHoveredDecorInfo)
---@return HousingDecorInstanceInfo? info
function C_HousingBasicMode.GetHoveredDecorInfo() end

---Returns info for the decor instance that's currently selected, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.GetSelectedDecorInfo)
---@return HousingDecorInstanceInfo? info
function C_HousingBasicMode.GetSelectedDecorInfo() end

---Returns true if a decor instance is currently selected and being dragged
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.IsDecorSelected)
---@return boolean hasSelectedDecor
function C_HousingBasicMode.IsDecorSelected() end

---When free place is enabled, collision checks while dragging decor/the house exterior are ignored
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.IsFreePlaceEnabled)
---@return boolean freePlaceEnabled
function C_HousingBasicMode.IsFreePlaceEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.IsGridSnapEnabled)
---@return boolean isGridSnapEnabled
function C_HousingBasicMode.IsGridSnapEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.IsGridVisible)
---@return boolean gridVisible
function C_HousingBasicMode.IsGridVisible() end

---Returns true if the house's exterior is currently being hovered
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.IsHouseExteriorHovered)
---@return boolean isHouseExteriorHovered
function C_HousingBasicMode.IsHouseExteriorHovered() end

---Returns true if the house's exterior is currently selected and being moved
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.IsHouseExteriorSelected)
---@return boolean isHouseExteriorSelected
function C_HousingBasicMode.IsHouseExteriorSelected() end

---Returns true if a placed decor instance is currently being hovered
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.IsHoveringDecor)
---@return boolean isHoveringDecor
function C_HousingBasicMode.IsHoveringDecor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.IsPlacingNewDecor)
---@return boolean hasPendingDecor
function C_HousingBasicMode.IsPlacingNewDecor() end

---Attempt to return the currently selected decor instance back to the house chest
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.RemoveSelectedDecor)
function C_HousingBasicMode.RemoveSelectedDecor() end

---Rotates the currently selected decor along a single axis; For wall decor, rotates such that the object stays flat against its current wall; For all other decor, rotates around the Z (vertical) axis
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.RotateDecor)
---@param rotDegrees number
function C_HousingBasicMode.RotateDecor(rotDegrees) end

---Rotates the House Exterior around the Z (vertical) axis
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.RotateHouseExterior)
---@param rotDegrees number
function C_HousingBasicMode.RotateHouseExterior(rotDegrees) end

---Set whether free place is enabled; When free place is enabled, collision checks while dragging decor/the house exterior are ignored
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.SetFreePlaceEnabled)
---@param freePlaceEnabled boolean
function C_HousingBasicMode.SetFreePlaceEnabled(freePlaceEnabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.SetGridSnapEnabled)
---@param isGridSnapEnabled boolean
function C_HousingBasicMode.SetGridSnapEnabled(isGridSnapEnabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.SetGridVisible)
---@param gridVisible boolean
function C_HousingBasicMode.SetGridVisible(gridVisible) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.StartPlacingNewDecor)
---@param catalogEntryID HousingCatalogEntryID
function C_HousingBasicMode.StartPlacingNewDecor(catalogEntryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingBasicMode.StartPlacingPreviewDecor)
---@param decorRecordID number
---@param bundleCatalogShopProductID? number
function C_HousingBasicMode.StartPlacingPreviewDecor(decorRecordID, bundleCatalogShopProductID) end
