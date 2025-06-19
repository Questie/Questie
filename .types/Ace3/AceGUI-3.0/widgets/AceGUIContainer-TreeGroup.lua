---@meta _
---@class AceGUITreeGroup : AceGUIContainer
---@field protected lines AceGUITreeGroupLine[]
---@field protected buttons Button[]
---@field protected localstatus AceGUITreeGroupStatus
---@field protected status? AceGUITreeGroupStatus
---@field protected filter boolean
---@field protected treeframe Frame|BackdropTemplate
---@field protected dragger Frame|BackdropTemplate
---@field protected scrollbar Slider
---@field protected border Frame|BackdropTemplate
---@field protected enabletooltips boolean
local AceGUITreeGroup = {}

---@protected
---@return Button
function AceGUITreeGroup:CreateButton() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-7-1)
---@param tree table
---@param filter? boolean
function AceGUITreeGroup:SetTree(tree, filter) end

---@param value string
function AceGUITreeGroup:SetSelected(value) end

---@param uniquevalue string
---@param ... string
function AceGUITreeGroup:Select(uniquevalue, ...) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-7-1)
---@param ... string
function AceGUITreeGroup:SelectByPath(...) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-7-1)
---@param uniquevalue string
function AceGUITreeGroup:SelectByValue(uniquevalue) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-7-1)
---@param flag boolean
function AceGUITreeGroup:EnableButtonTooltips(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-7-1)
---@param table table
function AceGUITreeGroup:SetStatusTable(table) end

---@param show boolean
function AceGUITreeGroup:ShowScroll(show) end

---@param treewidth integer
---@param resizable boolean
function AceGUITreeGroup:SetTreeWidth(treewidth, resizable) end

---@return integer
function AceGUITreeGroup:GetTreeWidth() end

---@protected
---@param tree table
---@param level? integer
---@param parent? AceGUITreeGroupLine
function AceGUITreeGroup:BuildLevel(tree, level, parent) end

---@protected
---@param scrollToSelection? boolean
---@param fromOnUpdate? boolean
function AceGUITreeGroup:RefreshTree(scrollToSelection, fromOnUpdate) end

---@protected
---@param width integer
function AceGUITreeGroup:OnWidthSet(width) end

---@protected
---@param height integer
function AceGUITreeGroup:OnHeightSet(height) end

---@protected
---@param width integer
---@param height integer
function AceGUITreeGroup:LayoutFinished(width, height) end

---@class AceGUITreeGroupStatus
---@field groups table
---@field scrollvalue number
---@field scrollToSelection? boolean
---@field fullwidth? boolean
---@field treewidth? integer
---@field treesizable? boolean
---@field selected? string

---@class AceGUITreeGroupLine
---@field value any
---@field text string
---@field icon? string|integer
---@field iconCoords? number[]
---@field disabled? boolean
---@field tree table
---@field level integer
---@field parent? AceGUITreeGroupLine
---@field visible? boolean
---@field uniquevalue string
---@field hasChildren? boolean
