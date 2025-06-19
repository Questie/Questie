---@meta _
---@class AceGUILabel : AceGUIWidget
---@field protected label FontString
---@field protected image Texture
local AceGUILabel = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-10-1)
---@param text string
function AceGUILabel:SetText(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-10-1)
---@param r number
---@param g number
---@param b number
function AceGUILabel:SetColor(r, g, b) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-10-1)
---@param font FontFile
---@param height number
---@param flags string?
function AceGUILabel:SetFont(font, height, flags) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-10-1)
---@param font? FontObject
function AceGUILabel:SetFontObject(font) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-10-1)
---@param image string|number
---@param ... unknown
function AceGUILabel:SetImage(image, ...) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-10-1)
---@param width number
---@param height number
function AceGUILabel:SetImageSize(width, height) end

---@param justifyH JustifyHorizontal
function AceGUILabel:SetJustifyH(justifyH) end

---@param justifyV JustifyVertical
function AceGUILabel:SetJustifyV(justifyV) end
