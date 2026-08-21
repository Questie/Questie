---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/ScriptObject_CurveObject)
---@class CurveObject : CurveObjectBase
local CurveObject = {}

---Adds a single point to the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_AddPoint)
---@param pointX number
---@param pointY number
function CurveObject:AddPoint(pointX, pointY) end

---Removes all points from the curve. Evaluating an empty curve always yields a zero value.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_ClearPoints)
function CurveObject:ClearPoints() end

---Returns a new copy of this curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_Copy)
---@return CurveObject curve
function CurveObject:Copy() end

---Returns a calculated 'y' value from the configured curve points.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_Evaluate)
---@param x number
---@return number y
function CurveObject:Evaluate(x) end

---Returns the vector for an individual point index on the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_GetPoint)
---@param index number
---@return vector2? point
function CurveObject:GetPoint(index) end

---Returns the total number of points on the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_GetPointCount)
---@return size count
function CurveObject:GetPointCount() end

---Returns the vectors for all points on the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_GetPoints)
---@return vector2[] point
function CurveObject:GetPoints() end

---Removes a single point from the curve. Raises an error if the supplied point index is out of range.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_RemovePoint)
---@param index number
function CurveObject:RemovePoint(index) end

---Replaces all points on the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_SetPoints)
---@param point vector2[]
function CurveObject:SetPoints(point) end

---Resets all state on the curve, and clears the secret values flag.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_CurveObject_SetToDefaults)
function CurveObject:SetToDefaults() end
