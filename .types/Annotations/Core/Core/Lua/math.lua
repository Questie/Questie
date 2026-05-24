---@meta math_wow
---@diagnostic disable: duplicate-doc-field
--- added: fastrandom
--- removed: math.randomseed, math.tointeger, math.type, math.ult

---
---
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math"])
---
---@class mathlib
---
---A value larger than any other numeric value.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.huge"])
---
---@field huge       number
---
---The value of *π*.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.pi"])
---
---@field pi         number
math = {}

---
---Returns the absolute value of `x`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.abs"])
---
---@generic Number: number
---@param x Number
---@return Number
---@nodiscard
function math.abs(x) end

---
---Returns the arc cosine of `x` (in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.acos"])
---
---@param x number
---@return number
---@nodiscard
function math.acos(x) end

---
---Returns the arc sine of `x` (in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.asin"])
---
---@param x number
---@return number
---@nodiscard
function math.asin(x) end

---
---Returns the arc tangent of `x` (in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.atan"])
---
---@param y number
---@return number
---@nodiscard
function math.atan(y) end

---Returns the arc tangent of `y/x` (in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.atan2"])
---
---@param y number
---@param x number
---@return number
---@nodiscard
function math.atan2(y, x) end

---
---Returns the smallest integral value larger than or equal to `x`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.ceil"])
---
---@param x number
---@return integer
---@nodiscard
function math.ceil(x) end

---
---Returns the cosine of `x` (assumed to be in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.cos"])
---
---@param x number
---@return number
---@nodiscard
function math.cos(x) end

---Returns the hyperbolic cosine of `x` (assumed to be in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.cosh"])
---
---@param x number
---@return number
---@nodiscard
function math.cosh(x) end

---
---Converts the angle `x` from radians to degrees.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.deg"])
---
---@param x number
---@return number
---@nodiscard
function math.deg(x) end

---
---Returns the value `e^x` (where `e` is the base of natural logarithms).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.exp"])
---
---@param x number
---@return number
---@nodiscard
function math.exp(x) end

---
---Returns the largest integral value smaller than or equal to `x`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.floor"])
---
---@param x number
---@return integer
---@nodiscard
function math.floor(x) end

---
---Returns the remainder of the division of `x` by `y` that rounds the quotient towards zero.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.fmod"])
---
---@param x number
---@param y number
---@return number
---@nodiscard
function math.fmod(x, y) end

---Decompose `x` into tails and exponents. Returns `m` and `e` such that `x = m * (2 ^ e)`, `e` is an integer and the absolute value of `m` is in the range [0.5, 1) (or zero when `x` is zero).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.frexp"])
---
---@param x number
---@return number m
---@return number e
---@nodiscard
function math.frexp(x) end

---Returns `m * (2 ^ e)` .
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.ldexp"])
---
---@param m number
---@param e number
---@return number
---@nodiscard
function math.ldexp(m, e) end

---
---Returns the natural logarithm of `x` .
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.log"])
---
---@param x     number
---@return number
---@nodiscard
function math.log(x) end

---Returns the base-10 logarithm of x.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.log10"])
---
---@param x number
---@return number
---@nodiscard
function math.log10(x) end

---
---Returns the argument with the maximum value, according to the Lua operator `<`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.max"])
---
---@generic Number: number
---@param x Number
---@param ... Number
---@return Number
---@nodiscard
function math.max(x, ...) end

---
---Returns the argument with the minimum value, according to the Lua operator `<`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.min"])
---
---@generic Number: number
---@param x Number
---@param ... Number
---@return Number
---@nodiscard
function math.min(x, ...) end

---
---Returns the integral part of `x` and the fractional part of `x`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.modf"])
---
---@param x number
---@return integer
---@return number
---@nodiscard
function math.modf(x) end

---Returns `x ^ y` .
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.pow"])
---
---@param x number
---@param y number
---@return number
---@nodiscard
function math.pow(x, y) end

---
---Converts the angle `x` from degrees to radians.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.rad"])
---
---@param x number
---@return number
---@nodiscard
function math.rad(x) end

---
---* `math.random()`: Returns a float in the range [0,1).
---* `math.random(n)`: Returns a integer in the range [1, n].
---* `math.random(m, n)`: Returns a integer in the range [m, n].
---
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.random"])
---
---@overload fun():number
---@overload fun(m: integer):integer
---@param m integer
---@param n integer
---@return integer
---@nodiscard
function math.random(m, n) end

---
---Returns the sine of `x` (assumed to be in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.sin"])
---
---@param x number
---@return number
---@nodiscard
function math.sin(x) end

---Returns the hyperbolic sine of `x` (assumed to be in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.sinh"])
---
---@param x number
---@return number
---@nodiscard
function math.sinh(x) end

---
---Returns the square root of `x`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.sqrt"])
---
---@param x number
---@return number
---@nodiscard
function math.sqrt(x) end

---
---Returns the tangent of `x` (assumed to be in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.tan"])
---
---@param x number
---@return number
---@nodiscard
function math.tan(x) end

---Returns the hyperbolic tangent of `x` (assumed to be in radians).
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-math.tanh"])
---
---@param x number
---@return number
---@nodiscard
function math.tanh(x) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_fastrandom)
---@param lower? number
---@param upper? number
---@return number
---@nodiscard
function fastrandom(lower, upper) end

return math
