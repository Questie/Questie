---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Path)
---@class Path : Animation
local Path = {}
---@class path : Path
---@class PATH : Path

---[Documentation](https://warcraft.wiki.gg/wiki/API_Path_CreateControlPoint)
---@param name? string
---@param templateName? string
---@param order? number
---@return SimpleControlPoint point
function Path:CreateControlPoint(name, templateName, order) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Path_GetControlPoints)
---@return ControlPoint ... ScriptObject
function Path:GetControlPoints() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Path_GetCurveType)
---@return CurveType curveType
function Path:GetCurveType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Path_GetMaxControlPointOrder)
---@return number maxOrder
function Path:GetMaxControlPointOrder() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Path_SetCurveType)
---@param curveType CurveType
function Path:SetCurveType(curveType) end
