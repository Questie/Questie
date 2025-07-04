---@meta _
---@class AceGUIInteractiveLabel : AceGUIWidget
---@field protected highlight Texture
local AceGUIInteractiveLabel = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-8-1)
---@param text string
function AceGUIInteractiveLabel:SetText(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-8-1)
---@param r number
---@param g number
---@param b number
function AceGUIInteractiveLabel:SetColor(r, g, b) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-8-1)
---@param font FontFile
---@param height number
---@param flags string?
function AceGUIInteractiveLabel:SetFont(font, height, flags) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-8-1)
---@param font? FontObject
function AceGUIInteractiveLabel:SetFontObject(font) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-8-1)
---@param image string|number
---@param ...? unknown
function AceGUIInteractiveLabel:SetImage(image, ...) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-8-1)
---@param width number
---@param height number
function AceGUIInteractiveLabel:SetImageSize(width, height) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-8-1)
---@param ... unknown
function AceGUIInteractiveLabel:SetHighlight(...) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-8-1)
---@param ... unknown
function AceGUIInteractiveLabel:SetHighlightTexCoord(...) end

---@param disabled boolean
function AceGUIInteractiveLabel:SetDisabled(disabled) end

---@param justifyH JustifyHorizontal
function AceGUIInteractiveLabel:SetJustifyH(justifyH) end

---@param justifyV JustifyVertical
function AceGUIInteractiveLabel:SetJustifyV(justifyV) end
