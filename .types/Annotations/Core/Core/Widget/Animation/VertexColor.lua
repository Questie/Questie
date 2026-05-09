---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_VertexColor)
---@class VertexColor : Animation
local VertexColor = {}
---@class vertexcolor : VertexColor
---@class VERTEXCOLOR : VertexColor

---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_VertexColor_GetEndColor)
---@return colorRGBA color
function VertexColor:GetEndColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_VertexColor_GetStartColor)
---@return colorRGBA color
function VertexColor:GetStartColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_VertexColor_SetEndColor)
---@param color colorRGBA
function VertexColor:SetEndColor(color) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_VertexColor_SetStartColor)
---@param color colorRGBA
function VertexColor:SetStartColor(color) end
