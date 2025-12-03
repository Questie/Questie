---@meta _
---@class AceGUISlider : AceGUIWidget
---@field protected label FontString
---@field protected slider Slider|BackdropTemplate
---@field protected lowtext FontString
---@field protected hightext FontString
---@field protected editbox EditBox|BackdropTemplate
---@field protected alignoffset number
local AceGUISlider = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-12-1)
---@param value number
function AceGUISlider:SetValue(value) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-12-1)
---@return number
function AceGUISlider:GetValue() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-12-1)
---@param min? number
---@param max? number
---@param step? number
function AceGUISlider:SetSliderValues(min, max, step) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-12-1)
---@param flag boolean
function AceGUISlider:SetIsPercent(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-12-1)
---@param text string
function AceGUISlider:SetLabel(text) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-2-12-1)
---@param flag boolean
function AceGUISlider:SetDisabled(flag) end
