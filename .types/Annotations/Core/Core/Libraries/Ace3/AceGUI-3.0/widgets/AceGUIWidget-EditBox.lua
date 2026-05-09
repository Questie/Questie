---@meta _
---@class AceGUIEditBox : AceGUIWidget
---@field protected alignoffset number
---@field protected editbox EditBox
---@field protected label FontString
---@field protected button Button
local AceGUIEditBox = {}
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-5-1)
---@param text string
function AceGUIEditBox:SetText(text) end

--- ---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-5-1)
---@return string
function AceGUIEditBox:GetText() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-5-1)
---@param text string
function AceGUIEditBox:SetLabel(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-5-1)
---@param flag boolean
function AceGUIEditBox:SetDisabled(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-5-1)
---@param flag boolean
function AceGUIEditBox:DisableButton(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-5-1)
---@param num number
function AceGUIEditBox:SetMaxLetters(num) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-5-1)
function AceGUIEditBox:SetFocus() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-5-1)
---@param from? number
---@param to? number
function AceGUIEditBox:HighlightText(from, to) end

function AceGUIEditBox:ClearFocus() end
