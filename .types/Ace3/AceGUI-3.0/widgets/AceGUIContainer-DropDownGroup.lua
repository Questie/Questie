---@meta _
---@class AceGUIDropdownGroup : AceGUIContainer
---@field protected localstatus table
---@field protected status? table
---@field protected titletext FontString
---@field protected dropdown AceGUIDropdown
---@field protected border Frame|BackdropTemplate
local AceGUIDropdownGroup = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-1-1)
---@param text string
function AceGUIDropdownGroup:SetTitle(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-1-1)
---@param groupList table<unknown, string>
---@param order? unknown[]
function AceGUIDropdownGroup:SetGroupList(groupList, order) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-1-1)
---@param key unknown
function AceGUIDropdownGroup:SetGroup(key) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-1-1)
---@param width number
function AceGUIDropdownGroup:SetDropdownWidth(width) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-1-1)
---@param statusTable table
function AceGUIDropdownGroup:SetStatusTable(statusTable) end

---@protected
---@param width integer
function AceGUIDropdownGroup:OnWidthSet(width) end

---@protected
---@param height integer
function AceGUIDropdownGroup:OnHeightSet(height) end

---@protected
---@param width integer
---@param height integer
function AceGUIDropdownGroup:LayoutFinished(width, height) end

---@class AceGUIDropdownGroupStatus
---@field selected? unknown
---@field left? number
---@field width? number
---@field height? number
