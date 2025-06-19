---@meta _
---@class AceGUIKeybinding : AceGUIWidget
---@field protected button Button
---@field protected label FontString
---@field protected msgframe Frame|BackdropTemplate
---@field protected alignoffset number
local AceGUIKeybinding = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-9-1)
---@param key string
function AceGUIKeybinding:SetKey(key) end

--- ---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-9-1)
---@return string
function AceGUIKeybinding:GetKey() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-9-1)
---@param text string
function AceGUIKeybinding:SetLabel(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-9-1)
---@param flag boolean
function AceGUIKeybinding:SetDisabled(flag) end
