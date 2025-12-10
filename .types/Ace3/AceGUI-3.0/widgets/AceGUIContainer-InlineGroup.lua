---@meta _
---@class AceGUIInlineGroup : AceGUIContainer
---@field protected titletext FontString
local AceGUIInlineGroup = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-3-1)
---@param text string
function AceGUIInlineGroup:SetTitle(text) end

---@protected
---@param width integer
function AceGUIInlineGroup:OnWidthSet(width) end

---@protected
---@param height integer
function AceGUIInlineGroup:OnHeightSet(height) end

---@protected
---@param width integer
---@param height integer
function AceGUIInlineGroup:LayoutFinished(width, height) end
