---@meta _
C_HousingInspectMode = {}

---Enters inspect mode, enabling decor inspection
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingInspectMode.EnterInspectMode)
function C_HousingInspectMode.EnterInspectMode() end

---Exits inspect mode, disabling decor inspection
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingInspectMode.ExitInspectMode)
function C_HousingInspectMode.ExitInspectMode() end

---Returns the GUID of the decor instance currently being hovered, if there is one
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingInspectMode.GetHoveredDecorGUID)
---@return WOWGUID decorGUID
function C_HousingInspectMode.GetHoveredDecorGUID() end

---Returns true if a decor instance is currently being hovered in inspect mode
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingInspectMode.IsHoveringDecor)
---@return boolean isHoveringDecor
function C_HousingInspectMode.IsHoveringDecor() end

---Returns true if the player is currently in inspect mode
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingInspectMode.IsInInspectMode)
---@return boolean isInInspectMode
function C_HousingInspectMode.IsInInspectMode() end
