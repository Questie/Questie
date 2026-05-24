---@meta _
---@class AceGUIFrame : AceGUIContainer
---@field protected localstatus AceGUIFrameStatus
---@field protected status? AceGUIFrameStatus
---@field protected titletext FontString
---@field protected statustext FontString
---@field protected titlebg Texture
---@field protected sizer_se Frame
---@field protected sizer_s Frame
---@field protected sizer_e Frame
---@field protected frame Frame|BackdropTemplate
local AceGUIFrame = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-2-1)
---@param text string
function AceGUIFrame:SetTitle(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-2-1)
---@param text string
function AceGUIFrame:SetStatusText(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-2-1)
---@param table table
function AceGUIFrame:SetStatusTable(table) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-4-2-1)
function AceGUIFrame:ApplyStatus() end

function AceGUIFrame:Show() end

function AceGUIFrame:Hide() end

---@param state boolean
function AceGUIFrame:EnableResize(state) end

---@protected
---@param width integer
function AceGUIFrame:OnWidthSet(width) end

---@protected
---@param height integer
function AceGUIFrame:OnHeightSet(height) end

---@class AceGUIFrameStatus
---@field top? number
---@field left? number
---@field width? number
---@field height? number
