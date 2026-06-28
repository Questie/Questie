---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/ScriptObject_ColorCurveObject)
---@class ColorCurveObject : CurveObjectBase
local ColorCurveObject = {}

---Adds a single point to the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_AddPoint)
---@param x number
---@param y colorRGBA
function ColorCurveObject:AddPoint(x, y) end

---Removes all points from the curve. Evaluating an empty curve always yields a zero value.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_ClearPoints)
function ColorCurveObject:ClearPoints() end

---Returns a new copy of this curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_Copy)
---@return ColorCurveObject curve
function ColorCurveObject:Copy() end

---Returns a calculated color value from the configured curve points.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_Evaluate)
---@param x number
---@return colorRGBA y
function ColorCurveObject:Evaluate(x) end

---Returns an unpacked calculated color value from the configured curve points.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_EvaluateUnpacked)
---@param x number
---@return number yR
---@return number yG
---@return number yB
---@return number yA
function ColorCurveObject:EvaluateUnpacked(x) end

---Returns the vector for an individual point index on the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_GetPoint)
---@param index number
---@return LuaColorCurvePoint? point
function ColorCurveObject:GetPoint(index) end

---Returns the total number of points on the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_GetPointCount)
---@return size count
function ColorCurveObject:GetPointCount() end

---Returns the vectors for all points on the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_GetPoints)
---@return LuaColorCurvePoint[] point
function ColorCurveObject:GetPoints() end

---Removes a single point from the curve. Raises an error if the supplied point index is out of range.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_RemovePoint)
---@param index number
function ColorCurveObject:RemovePoint(index) end

---Replaces all points on the curve.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_SetPoints)
---@param point LuaColorCurvePoint[]
function ColorCurveObject:SetPoints(point) end

---Resets all state on the curve, and clears the secret values flag.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_ColorCurveObject_SetToDefaults)
function ColorCurveObject:SetToDefaults() end

---@class LuaColorCurvePoint
---@field x number
---@field y colorRGBA
