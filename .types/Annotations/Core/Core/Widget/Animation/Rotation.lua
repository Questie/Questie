---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Rotation)
---@class Rotation : Animation
local Rotation = {}
---@class rotation : Rotation
---@class ROTATION : Rotation

---[Documentation](https://warcraft.wiki.gg/wiki/API_Rotation_GetDegrees)
---@return number angle
function Rotation:GetDegrees() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Rotation_GetOrigin)
---@return FramePoint point
---@return number originX
---@return number originY
function Rotation:GetOrigin() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Rotation_GetRadians)
---@return number angle
function Rotation:GetRadians() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Rotation_SetDegrees)
---@param angle number
function Rotation:SetDegrees(angle) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Rotation_SetOrigin)
---@param point FramePoint
---@param originX number
---@param originY number
function Rotation:SetOrigin(point, originX, originY) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Rotation_SetRadians)
---@param angle number
function Rotation:SetRadians(angle) end
