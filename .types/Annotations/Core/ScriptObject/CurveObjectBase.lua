---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/ScriptObject_CurveObjectBase)
---@class CurveObjectBase
local CurveObjectBase = {}

---Returns the configured type of the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObjectBase_GetType)
---@return Enum.LuaCurveType curveType
function CurveObjectBase:GetType() end

---Returns true if the curve has been configured with any secret values. Curves with secret values always produce secret results when evaluated.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObjectBase_HasSecretValues)
---@return boolean hasSecretValues
function CurveObjectBase:HasSecretValues() end

---Changes the evaluation type of the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObjectBase_SetType)
---@param type Enum.LuaCurveType
function CurveObjectBase:SetType(type) end
