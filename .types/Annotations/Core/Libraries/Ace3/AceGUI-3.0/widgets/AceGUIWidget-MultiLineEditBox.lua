---@meta _
---@class AceGUIMultiLineEditBox : AceGUIWidget
---@field protected button Button
---@field protected editBox EditBox
---@field protected label FontString
---@field protected labelHeight number
---@field protected numlines number
---@field protected scrollBar Frame
---@field protected scrollBG Frame|BackdropTemplate
---@field protected scrollFrame ScrollFrame
local AceGUIMultiLineEditBox = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
---@param text string
function AceGUIMultiLineEditBox:SetText(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
---@return string
function AceGUIMultiLineEditBox:GetText() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
---@param text string
function AceGUIMultiLineEditBox:SetLabel(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
---@param num number
function AceGUIMultiLineEditBox:SetNumLines(num) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
---@param flag boolean
function AceGUIMultiLineEditBox:SetDisabled(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
---@param num number
function AceGUIMultiLineEditBox:SetMaxLetters(num) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
---@param flag boolean
function AceGUIMultiLineEditBox:DisableButton(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
function AceGUIMultiLineEditBox:SetFocus() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-11-1)
---@param from? number
---@param to? number
function AceGUIMultiLineEditBox:HighlightText(from, to) end

function AceGUIMultiLineEditBox:ClearFocus() end

---@return number
function AceGUIMultiLineEditBox:GetCursorPosition() end

---@param position number
function AceGUIMultiLineEditBox:SetCursorPosition(position) end
