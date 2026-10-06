--[[
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
--]]

-- Affine v1.01c

affineLib = {}

local mt

local __call = function (self,x,y)
	return 	self[1][1]*x + self[1][2]*y + self[1][3],
			self[2][1]*x + self[2][2]*y + self[2][3]
end

local __mul = function (a,b)
	local t = setmetatable({},mt)
	for i = 1,3 do
		t[i] = {}
		for j = 1,3 do
			t[i][j] = a[i][1]*b[1][j] + a[i][2]*b[2][j] + a[i][3]*b[3][j]
		end
	end
	return t
end

local __pow = function (a,b)
	if b == -1 then
		return affineLib.inverse(a)
	elseif b == 0 then
		return a/a
	else
		local c = a
		for i = 2,b do
			c = c*a
		end
		return c
	end
end

local __div = function (a,b)
	return a*affineLib.inverse(b)
end

mt = {__call = __call, __mul = __mul,__pow = __pow,__div = __div}

affineLib.trans = function (dx,dy)
	local t = setmetatable({},mt)
	t[1] = { 1, 0, dx}
	t[2] = { 0, 1, dy}
	t[3] = { 0, 0,  1}
	return t
end

affineLib.rotate = function(theta)
	local t = setmetatable({},mt)
	t[1] = {math.cos(theta),-math.sin(theta), 0}
	t[2] = {math.sin(theta), math.cos(theta), 0}
	t[3] = {0,            0,                  1}
	return t
end

affineLib.scale = function (sx,sy)
	local t = setmetatable({},mt)
	t[1] = { sx, 0, 0}
	t[2] = { 0, sy, 0}
	t[3] = { 0, 0,  1}
	return t
end

affineLib.shear = function (kx,ky)
	local t = setmetatable({},mt)
	t[1] = { 1, kx, 0}
	t[2] = { ky, 1, 0}
	t[3] = { 0, 0,  1}
	return t
end

affineLib.inverse = function (u)
	local t = setmetatable({},mt)
	local a = u[1][1]
	local b = u[1][2]
	local c = u[2][1]
	local d = u[2][2]
	
	local det = a*d - b*c
	assert(det ~= 0, 'transformation is not invertible!')
	local f1 = ( d * u[1][3] + (-b) * u[2][3])/det
	local f2 = (-c * u[1][3] +   a  * u[2][3])/det
	
	t[1] = { d/det, -b/det, -f1}
	t[2] = {-c/det,  a/det, -f2}
	t[3] = {     0,      0,   1}
	return t
end

affineLib.polar = function (x,y)
	local r     = (x^2 + y^2)^0.5
	local theta = math.atan2(y,x)
	return r,theta
end

affineLib.cart = function (r,theta)
	return r*math.cos(theta),r*math.sin(theta)
end