---@meta _
---@class AceGUIColorPicker : AceGUIWidget
---@field protected colorSwatch Texture
---@field protected text FontString
local AceGUIColorPicker = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-3-1)
---@param r number
---@param g number
---@param b number
---@param a number
function AceGUIColorPicker:SetColor(r, g, b, a) end

--- ---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-3-1)
---@param text string
function AceGUIColorPicker:SetLabel(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-3-1)
---@param flag boolean
function AceGUIColorPicker:SetHasAlpha(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-3-1)
---@param flag boolean
function AceGUIColorPicker:SetDisabled(flag) end
