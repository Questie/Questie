---@meta _
---@class AceGUIBlizOptionsGroup : AceGUIContainer
---@field protected label FontString
local AceGUIBlizOptionsGroup = {}

---@param text string
function AceGUIBlizOptionsGroup:SetTitle(text) end

---@param name string
---@param parent unknown
function AceGUIBlizOptionsGroup:SetName(name, parent) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-1-1)
---@param key unknown
function AceGUIBlizOptionsGroup:SetGroup(key) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-1-1)
---@param width number
function AceGUIBlizOptionsGroup:SetDropdownWidth(width) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-1-1)
---@param table table
function AceGUIBlizOptionsGroup:SetStatusTable(table) end

---@protected
---@param width integer
function AceGUIBlizOptionsGroup:OnWidthSet(width) end

---@protected
---@param height integer
function AceGUIBlizOptionsGroup:OnHeightSet(height) end
