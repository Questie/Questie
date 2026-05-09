---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Line)
---@class Line : TextureBase
local Line = {}
---@class line : Line
---@class LINE : Line

---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_ClearAllPoints)
function Line:ClearAllPoints() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_GetEndPoint)
---@return FramePoint relativePoint
---@return ScriptRegion relativeTo
---@return uiUnit offsetX
---@return uiUnit offsetY
function Line:GetEndPoint() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_GetHitRectThickness)
---@return uiUnit thickness
function Line:GetHitRectThickness() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_GetStartPoint)
---@return FramePoint relativePoint
---@return ScriptRegion relativeTo
---@return uiUnit offsetX
---@return uiUnit offsetY
function Line:GetStartPoint() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_GetThickness)
---@return uiUnit thickness
function Line:GetThickness() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_SetEndPoint)
---@param relativePoint FramePoint
---@param relativeTo ScriptRegion
---@param offsetX? uiUnit Default = 0
---@param offsetY? uiUnit Default = 0
function Line:SetEndPoint(relativePoint, relativeTo, offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_SetHitRectThickness)
---@param thickness uiUnit
function Line:SetHitRectThickness(thickness) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_SetStartPoint)
---@param relativePoint FramePoint
---@param relativeTo ScriptRegion
---@param offsetX? uiUnit Default = 0
---@param offsetY? uiUnit Default = 0
function Line:SetStartPoint(relativePoint, relativeTo, offsetX, offsetY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Line_SetThickness)
---@param thickness uiUnit
function Line:SetThickness(thickness) end
