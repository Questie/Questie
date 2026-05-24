---@meta _
---@class AceGUIScrollFrame : AceGUIContainer
---@field protected localstatus AceGUIScrollFrameStatus
---@field protected status? AceGUIScrollFrameStatus
---@field protected scrollframe ScrollFrame
---@field protected scrollbar Slider
local AceGUIScrollFrame = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-4-1)
---@param value number
function AceGUIScrollFrame:SetScroll(value) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-4-1)
---@param table table
function AceGUIScrollFrame:SetStatusTable(table) end

---@param value number
function AceGUIScrollFrame:MoveScroll(value) end

---@protected
function AceGUIScrollFrame:FixScroll() end

---@protected
---@param width integer
function AceGUIScrollFrame:OnWidthSet(width) end

---@protected
---@param height integer
function AceGUIScrollFrame:OnHeightSet(height) end

---@protected
---@param width integer
---@param height integer
function AceGUIScrollFrame:LayoutFinished(width, height) end

---@class AceGUIScrollFrameStatus
---@field scrollvalue number
---@field offset? integer
