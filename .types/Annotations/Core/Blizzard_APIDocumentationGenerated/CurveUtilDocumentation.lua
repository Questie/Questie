---@meta _
C_CurveUtil = {}

---Returns a new color curve object with no assigned points.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurveUtil.CreateColorCurve)
---@return LuaColorCurveObject curve
function C_CurveUtil.CreateColorCurve() end

---Returns a new curve object with no assigned points.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurveUtil.CreateCurve)
---@return LuaCurveObject curve
function C_CurveUtil.CreateCurve() end

---Evaluates a potentially-secret boolean value and returns a color.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurveUtil.EvaluateColorFromBoolean)
---@param boolean boolean
---@param valueIfTrue colorRGBA
---@param valueIfFalse colorRGBA
---@return colorRGBA value
function C_CurveUtil.EvaluateColorFromBoolean(boolean, valueIfTrue, valueIfFalse) end

---Evaluates a potentially-secret boolean value and returns a single color component (eg. alpha).
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurveUtil.EvaluateColorValueFromBoolean)
---@param boolean boolean
---@param valueIfTrue SingleColorValue
---@param valueIfFalse SingleColorValue
---@return SingleColorValue value
function C_CurveUtil.EvaluateColorValueFromBoolean(boolean, valueIfTrue, valueIfFalse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CurveUtil.EvaluateGameCurve)
---@param curveID number
---@param x number
---@return number y
function C_CurveUtil.EvaluateGameCurve(curveID, x) end
