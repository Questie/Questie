---@meta _
---@class AceGUIDropdown : AceGUIWidget
---@field protected dropdown Frame
---@field protected count number
---@field protected button Button
---@field protected button_cover Button
---@field protected text FontString
---@field protected label FontString
local AceGUIDropdown = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param key unknown
function AceGUIDropdown:SetValue(key) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param table table<unknown, string>
---@param order? unknown[]
function AceGUIDropdown:SetList(table, order) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param text string
function AceGUIDropdown:SetText(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param text string
function AceGUIDropdown:SetLabel(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param key unknown
---@param value string
function AceGUIDropdown:AddItem(key, value) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param flag boolean
function AceGUIDropdown:SetMultiselect(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@return boolean
function AceGUIDropdown:GetMultiselect() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param key unknown
---@param value string
function AceGUIDropdown:SetItemValue(key, value) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param key unknown
---@param flag boolean
function AceGUIDropdown:SetItemDisabled(key, flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-4-1)
---@param flag boolean
function AceGUIDropdown:SetDisabled(flag) end

function AceGUIDropdown:ClearFocus() end

---@return unknown
function AceGUIDropdown:GetValue() end

---@param width number
function AceGUIDropdown:SetPulloutWidth(width) end
