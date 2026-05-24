---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ControlPoint)
---@class ControlPoint : Object
local ControlPoint = {}
---@class controlpoint : ControlPoint
---@class CONTROLPOINT : ControlPoint

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_GetParent)
---@return Path parent
function ControlPoint:GetParent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ControlPoint_GetOffset)
---@return uiUnit offsetX
---@return uiUnit offsetY
function ControlPoint:GetOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ControlPoint_GetOrder)
---@return number order
function ControlPoint:GetOrder() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ControlPoint_SetOffset)
---@param offsetX uiUnit
---@param offsetY uiUnit
function ControlPoint:SetOffset(offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ControlPoint_SetOrder)
---@param order number
function ControlPoint:SetOrder(order) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ControlPoint_SetParent)
---@param parent SimplePathAnim
---@param order? number
function ControlPoint:SetParent(parent, order) end
