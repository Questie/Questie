---@meta _
---@class AceGUIButton : AceGUIWidget
---@field protected text FontString
local AceGUIButton = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-1-1)
---@param text string
function AceGUIButton:SetText(text) end

---@param autoWidth boolean
function AceGUIButton:SetAutoWidth(autoWidth) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-1-1)
---@param flag boolean
function AceGUIButton:SetDisabled(flag) end
