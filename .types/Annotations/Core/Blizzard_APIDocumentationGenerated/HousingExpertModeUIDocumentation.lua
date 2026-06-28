---@meta _
C_HousingExpertMode = {}

---Cancels all in-progress editing of the selected target, which will reset any unsaved changes and deselect the active target; Will not reset any already-applied changes
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.CancelActiveEditing)
function C_HousingExpertMode.CancelActiveEditing() end

---Attempt to save the changes made to the currently selected decor instance
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.CommitDecorMovement)
function C_HousingExpertMode.CommitDecorMovement() end

---Attempt to save the changes made to the House Exterior's position within the plot
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.CommitHouseExteriorPosition)
function C_HousingExpertMode.CommitHouseExteriorPosition() end

---Returns info for the placed decor instance currently being hovered, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.GetHoveredDecorInfo)
---@return HousingDecorInstanceInfo? info
function C_HousingExpertMode.GetHoveredDecorInfo() end

---Returns the currently active Expert submode, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.GetPrecisionSubmode)
---@return Enum.HousingPrecisionSubmode? activeSubMode
function C_HousingExpertMode.GetPrecisionSubmode() end

---Returns the type of restriction currently active on the submode; Will return HousingExpertSubmodeRestriction:None if submode is not currently restricted
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.GetPrecisionSubmodeRestriction)
---@param subMode Enum.HousingPrecisionSubmode
---@return Enum.HousingExpertSubmodeRestriction restriction
function C_HousingExpertMode.GetPrecisionSubmodeRestriction(subMode) end

---Returns info for the placed decor instance that's currently selected, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.GetSelectedDecorInfo)
---@return HousingDecorInstanceInfo? info
function C_HousingExpertMode.GetSelectedDecorInfo() end

---Returns true if a placed decor instance is currently selected
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.IsDecorSelected)
---@return boolean hasSelectedDecor
function C_HousingExpertMode.IsDecorSelected() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.IsGridVisible)
---@return boolean gridVisible
function C_HousingExpertMode.IsGridVisible() end

---Returns true if the house's exterior is currently being hovered
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.IsHouseExteriorHovered)
---@return boolean isHouseExteriorHovered
function C_HousingExpertMode.IsHouseExteriorHovered() end

---Returns true if the house's exterior is currently selected
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.IsHouseExteriorSelected)
---@return boolean isHouseExteriorSelected
function C_HousingExpertMode.IsHouseExteriorSelected() end

---Returns true if a placed decor instance is currently being hovered
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.IsHoveringDecor)
---@return boolean isHoveringDecor
function C_HousingExpertMode.IsHoveringDecor() end

---Attempt to return the currently selected decor instance back to the house chest
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.RemoveSelectedDecor)
function C_HousingExpertMode.RemoveSelectedDecor() end

---Reset the selected target's transform back to default values; This is NOT an undo, meaning it will completely reset the transform value to default, NOT just recently-made changes
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.ResetPrecisionChanges)
---@param activeSubmodeOnly boolean
function C_HousingExpertMode.ResetPrecisionChanges(activeSubmodeOnly) end

---In the rotation submode, swaps the selected axis to the next available one, in order of X -> Y -> Z (wrapping back around to X again, etc); If no axis is selected, selects the first available one, also in that order
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.SelectNextRotationAxis)
function C_HousingExpertMode.SelectNextRotationAxis() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.SetGridVisible)
---@param gridVisible boolean
function C_HousingExpertMode.SetGridVisible(gridVisible) end

---Sets a specific type of incremental change active or inactive; Whilever that type is active and target stays selected, incremental changes of that type will continue to be made every frame
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.SetPrecisionIncrementingActive)
---@param incrementType Enum.HousingIncrementType
---@param active boolean
function C_HousingExpertMode.SetPrecisionIncrementingActive(incrementType, active) end

---Activate a specific Expert submode
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingExpertMode.SetPrecisionSubmode)
---@param subMode Enum.HousingPrecisionSubmode
function C_HousingExpertMode.SetPrecisionSubmode(subMode) end
