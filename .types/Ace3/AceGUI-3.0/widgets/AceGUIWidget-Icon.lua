---@meta _
---@class AceGUIIcon : AceGUIWidget
---@field protected label FontString
---@field protected image Texture
local AceGUIIcon = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-7-1)
---@param image string|number
---@param ...? unknown
function AceGUIIcon:SetImage(image, ...) end

--- ---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-7-1)
---@param width number
---@param height number
function AceGUIIcon:SetImageSize(width, height) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-7-1)
---@param text string
function AceGUIIcon:SetLabel(text) end

---@param disabled boolean
function AceGUIIcon:SetDisabled(disabled) end
