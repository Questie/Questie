---@meta _
---@class AceGUISimpleGroup : AceGUIContainer
local AceGUISimpleGroup = {}

---@protected
---@param width integer
function AceGUISimpleGroup:OnWidthSet(width) end

---@protected
---@param height integer
function AceGUISimpleGroup:OnHeightSet(height) end

---@protected
---@param width integer
---@param height integer
function AceGUISimpleGroup:LayoutFinished(width, height) end
