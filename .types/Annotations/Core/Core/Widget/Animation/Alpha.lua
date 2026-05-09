---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Alpha)
---@class Alpha : Animation
local Alpha = {}
---@class alpha : Alpha
---@class ALPHA : Alpha

---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_Alpha_GetFromAlpha)
---@return number normalizedAlpha
function Alpha:GetFromAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Alpha_GetToAlpha)
---@return number normalizedAlpha
function Alpha:GetToAlpha() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Alpha_SetFromAlpha)
---@param normalizedAlpha number
function Alpha:SetFromAlpha(normalizedAlpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Alpha_SetToAlpha)
---@param normalizedAlpha number
function Alpha:SetToAlpha(normalizedAlpha) end
