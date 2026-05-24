---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ScrollFrame)
---@class ScrollFrame : Frame
local ScrollFrame  = {}
---@class scrollframe : ScrollFrame
---@class SCROLLFRAME : ScrollFrame

---@param scriptType ScriptScrollFrame
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function ScrollFrame:GetScript(scriptType, bindingType) end

---@param scriptType ScriptScrollFrame
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function ScrollFrame:HasScript(scriptType) end

---@param scriptType ScriptScrollFrame
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function ScrollFrame:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptScrollFrame
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function ScrollFrame:SetScript(scriptType, handler) end


---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_GetHorizontalScroll)
---@return uiUnit offset
function ScrollFrame:GetHorizontalScroll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_GetHorizontalScrollRange)
---@return uiUnit range
function ScrollFrame:GetHorizontalScrollRange() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_GetScrollChild)
---@return SimpleFrame scrollChild
function ScrollFrame:GetScrollChild() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_GetVerticalScroll)
---@return uiUnit offset
function ScrollFrame:GetVerticalScroll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_GetVerticalScrollRange)
---@return uiUnit range
function ScrollFrame:GetVerticalScrollRange() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_SetHorizontalScroll)
---@param offset uiUnit
function ScrollFrame:SetHorizontalScroll(offset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_SetScrollChild)
---@param scrollChild SimpleFrame
function ScrollFrame:SetScrollChild(scrollChild) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_SetVerticalScroll)
---@param offset uiUnit
function ScrollFrame:SetVerticalScroll(offset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScrollFrame_UpdateScrollChildRect)
function ScrollFrame:UpdateScrollChildRect() end
