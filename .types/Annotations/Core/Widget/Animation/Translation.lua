---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Translation)
---@class Translation : Animation
local Translation = {}
---@class translation : Translation
---@class TRANSLATION : Translation
---@class LineTranslation : Translation

---[Documentation](https://warcraft.wiki.gg/wiki/API_Translation_GetOffset)
---@return uiUnit offsetX
---@return uiUnit offsetY
function Translation:GetOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Translation_SetOffset)
---@param offsetX uiUnit
---@param offsetY uiUnit
function Translation:SetOffset(offsetX, offsetY) end

---@class LineTranslation : Translation
local LineTranslation = {}
