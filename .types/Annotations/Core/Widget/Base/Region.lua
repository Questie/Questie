---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Region)
---@class Region : ScriptRegion, ScriptRegionResizing, AnimatableObject
local Region = {}

---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_GetAlpha)
---@return SingleColorValue alpha
function Region:GetAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_GetDrawLayer)
---@return DrawLayer layer
---@return number sublayer
function Region:GetDrawLayer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_GetEffectiveScale)
---@return number effectiveScale
function Region:GetEffectiveScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_GetScale)
---@return number scale
function Region:GetScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_GetVertexColor)
---@return number colorR
---@return number colorG
---@return number colorB
---@return number colorA
function Region:GetVertexColor() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_IsIgnoringParentAlpha)
---@return boolean isIgnoring
function Region:IsIgnoringParentAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_IsIgnoringParentScale)
---@return boolean isIgnoring
function Region:IsIgnoringParentScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_IsObjectLoaded)
---@return boolean isLoaded
function Region:IsObjectLoaded() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_SetAlpha)
---@param alpha SingleColorValue
function Region:SetAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_SetDrawLayer)
---@param layer DrawLayer
---@param sublevel? number Default = 0
function Region:SetDrawLayer(layer, sublevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_SetIgnoreParentAlpha)
---@param ignore boolean
function Region:SetIgnoreParentAlpha(ignore) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_SetIgnoreParentScale)
---@param ignore boolean
function Region:SetIgnoreParentScale(ignore) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_SetScale)
---@param scale number
function Region:SetScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_SetVertexColor)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function Region:SetVertexColor(colorR, colorG, colorB, a) end
