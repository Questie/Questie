---@meta _
---@class AceGUITabGroup : AceGUIContainer
---@field protected num integer
---@field protected localstatus AceGUITabGroupStatus
---@field protected status? AceGUITabGroupStatus
---@field protected alignoffset number
---@field protected titletext FontString
---@field protected border Frame|BackdropTemplate
---@field protected borderoffset number
---@field protected tabs Button[]
---@field protected tablist AceGUITabGroupTab[]
local AceGUITabGroup = {}

---@class AceGUITabGroupTab
---@field value unknown
---@field text string
---@field disabled? boolean

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-6-1)
---@param text string
function AceGUITabGroup:SetTitle(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-6-1)
---@param table AceGUITabGroupTab[]
function AceGUITabGroup:SetTabs(table) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-6-1)
---@param key string
function AceGUITabGroup:SelectTab(key) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-6-1)
---@param table table
function AceGUITabGroup:SetStatusTable(table) end

---@protected
function AceGUITabGroup:BuildTabs() end

---@protected
---@param id integer
---@return Button
function AceGUITabGroup:CreateTab(id) end

---@protected
---@param width integer
function AceGUITabGroup:OnWidthSet(width) end

---@protected
---@param height integer
function AceGUITabGroup:OnHeightSet(height) end

---@protected
---@param width integer
---@param height integer
function AceGUITabGroup:LayoutFinished(width, height) end

---@class AceGUITabGroupStatus
---@field selected? string
