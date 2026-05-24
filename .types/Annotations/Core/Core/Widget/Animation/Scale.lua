---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Scale)
---@class Scale : Animation
local Scale = {}
---@class scale : Scale
---@class SCALE : Scale
---@class LineScale : Scale

---[Documentation](https://warcraft.wiki.gg/wiki/API_Scale_GetOrigin)
---@return FramePoint point
---@return number originX
---@return number originY
function Scale:GetOrigin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Scale_GetScale)
---@return number scaleX
---@return number scaleY
function Scale:GetScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Scale_GetScaleFrom)
---@return number scaleX
---@return number scaleY
function Scale:GetScaleFrom() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Scale_GetScaleTo)
---@return number scaleX
---@return number scaleY
function Scale:GetScaleTo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Scale_SetOrigin)
---@param point FramePoint
---@param originX number
---@param originY number
function Scale:SetOrigin(point, originX, originY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Scale_SetScale)
---@param scaleX number
---@param scaleY number
function Scale:SetScale(scaleX, scaleY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Scale_SetScaleFrom)
---@param scaleX number
---@param scaleY number
function Scale:SetScaleFrom(scaleX, scaleY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Scale_SetScaleTo)
---@param scaleX number
---@param scaleY number
function Scale:SetScaleTo(scaleX, scaleY) end
