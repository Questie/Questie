---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCursorDelta)
---@return number deltaX
---@return number deltaY
function GetCursorDelta() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCursorPosition)
---@return number posX
---@return number posY
function GetCursorPosition() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMouseButtonClicked)
---@return string buttonName
function GetMouseButtonClicked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMouseButtonName)
---@param button mouseButton
---@return string buttonName
function GetMouseButtonName(button) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetMouseFoci)
---@return ScriptRegion[] region
function GetMouseFoci() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsAltKeyDown)
---@return boolean down
function IsAltKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsControlKeyDown)
---@return boolean down
function IsControlKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsKeyDown)
---@param keyOrMouseName string
---@param excludeBindingState? boolean Default = false
---@return boolean? down
function IsKeyDown(keyOrMouseName, excludeBindingState) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsLeftAltKeyDown)
---@return boolean down
function IsLeftAltKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsLeftControlKeyDown)
---@return boolean down
function IsLeftControlKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsLeftMetaKeyDown)
---@return boolean down
function IsLeftMetaKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsLeftShiftKeyDown)
---@return boolean down
function IsLeftShiftKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsMetaKeyDown)
---@return boolean down
function IsMetaKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsModifierKeyDown)
---@return boolean down
function IsModifierKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsMouseButtonDown)
---@param button? mouseButton
---@return boolean down
function IsMouseButtonDown(button) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsRightAltKeyDown)
---@return boolean down
function IsRightAltKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsRightControlKeyDown)
---@return boolean down
function IsRightControlKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsRightMetaKeyDown)
---@return boolean down
function IsRightMetaKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsRightShiftKeyDown)
---@return boolean down
function IsRightShiftKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsShiftKeyDown)
---@return boolean down
function IsShiftKeyDown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsUsingGamepad)
---@return boolean down
function IsUsingGamepad() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsUsingMouse)
---@return boolean down
function IsUsingMouse() end
