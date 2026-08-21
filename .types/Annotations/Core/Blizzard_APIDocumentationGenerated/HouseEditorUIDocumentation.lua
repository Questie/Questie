---@meta _
C_HouseEditor = {}

---Attempts switch the House Editor to a specific House Editor mode
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.ActivateHouseEditorMode)
---@param editMode Enum.HouseEditorMode
---@return Enum.HousingResult result
function C_HouseEditor.ActivateHouseEditorMode(editMode) end

---Attempts to open the House Editor to the default House Editor mode
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.EnterHouseEditor)
---@return Enum.HousingResult result
function C_HouseEditor.EnterHouseEditor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.GetActiveHouseEditorMode)
---@return Enum.HouseEditorMode editMode
function C_HouseEditor.GetActiveHouseEditorMode() end

---Returns the availability state of the House Editor overall
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.GetHouseEditorAvailability)
---@return Enum.HousingResult result
function C_HouseEditor.GetHouseEditorAvailability() end

---Returns the availability of a specific House Editor mode
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.GetHouseEditorModeAvailability)
---@param editMode Enum.HouseEditorMode
---@return Enum.HousingResult result
function C_HouseEditor.GetHouseEditorModeAvailability(editMode) end

---Returns whether the House Editor is active, in any mode
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.IsHouseEditorActive)
---@return boolean isEditorActive
function C_HouseEditor.IsHouseEditorActive() end

---Returns whether the specific House Editor mode is active
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.IsHouseEditorModeActive)
---@param editMode Enum.HouseEditorMode
---@return boolean isModeActive
function C_HouseEditor.IsHouseEditorModeActive(editMode) end

---Returns true if the HouseEditor currently able process mode availability and switching; May be false if not in a house or plot, or while waiting to get house settings back from the server
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.IsHouseEditorStatusAvailable)
---@return boolean editorStatusAvailable
function C_HouseEditor.IsHouseEditorStatusAvailable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseEditor.LeaveHouseEditor)
function C_HouseEditor.LeaveHouseEditor() end
