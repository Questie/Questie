--[[
Name: AceOO-2.0
Revision: $Rev: 11577 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceOO-2.0
SVN: http://svn.wowace.com/root/trunk/Ace2/AceOO-2.0
Description: Library to provide an object-orientation framework.
Dependencies: AceLibrary
]]

local MAJOR_VERSION = "AceOO-2.0"
local MINOR_VERSION = "$Revision: 11577 $"

-- This ensures the code is only executed if the libary doesn't already exist, or is a newer version
if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local table_setn
do
	local version = GetBuildInfo()
	if string.find(version, "^2%.") then
		-- 2.0.0
		table_setn = function() end
	else
		table_setn = table.setn
	end
end

local AceOO = {
	error = AceLibrary.error,
	argCheck = AceLibrary.argCheck
}

-- @function	getuid
-- @brief		Obtain a unique string identifier for the object in question.
-- @param t		The object to obtain the uid for.
-- @return		The uid string.
local function pad(cap)
	return string.rep('0', 8 - string.len(cap)) .. cap
end
local function getuid(t)
	local mt = getmetatable(t)
	setmetatable(t, nil)
	local str = tostring(t)
	setmetatable(t, mt)
	local _,_,cap = string.find(str, '[^:]*: 0x(.*)$')
	if cap then return pad(cap) end
	_,_,cap = string.find(str, '[^:]*: (.*)$')
	if cap then return pad(cap) end
end

local function getlibrary(o)
	if type(o) == "table" then
		return o
	elseif type(o) == "string" then
		if not AceLibrary:HasInstance(o) then
			AceOO:error("Library %q does not exist.", o)
		end
		return AceLibrary(o)
	end
end

-- @function		Factory
-- @brief			Construct a factory for the creation of objects.
-- @param obj		The object whose init method will be called on the new factory
--					object.
-- @param newobj	The object whose init method will be called on the new
--					objects that the Factory creates, to initialize them.
-- @param (a1..a20) Arguments which will be passed to obj.init() in addition
--					to the Factory object.
-- @return			The new factory which creates a newobj when its new method is called,
--					or when it is called directly (__call metamethod).
local Factory
do
	local function new(obj, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12,
							a13, a14, a15, a16, a17, a18, a19, a20)
		local t = {}
		local uid = getuid(t)
		local l = getlibrary
		obj:init(t, l(a1), l(a2), l(a3), l(a4), l(a5), l(a6), l(a7),
					l(a8), l(a9), l(a10), l(a11), l(a12), l(a13),
					l(a14), l(a15), l(a16), l(a17), l(a18), l(a19),
					l(a20))
		t.uid = uid
		return t
	end
	
	local function createnew(self, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10,
									a11, a12, a13, a14, a15, a16, a17, a18,
									a19, a20)
		local o = self.prototype
		local l = getlibrary
		return new(o, l(a1), l(a2), l(a3), l(a4), l(a5), l(a6), l(a7),
						l(a8), l(a9), l(a10), l(a11), l(a12), l(a13),
						l(a14), l(a15), l(a16), l(a17), l(a18), l(a19),
						l(a20))
	end

	function Factory(obj, newobj, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10,
									a11, a12, a13, a14, a15, a16, a17, a18,
									a19, a20)
		local t = new(obj, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12,
							a13, a14, a15, a16, a17, a18, a19, a20)
		t.prototype = newobj
		t.new = createnew
		getmetatable(t).__call = t.new
		return t
	end
end


local function objtostring(self)
	if self.ToString then
		return self:ToString()
	elseif self.GetLibraryVersion then
		return (self:GetLibraryVersion())
	elseif self.super then
		local s = "Sub-" .. tostring(self.super)
		local first = true
		if self.interfaces then
			for interface in pairs(self.interfaces) do
				if first then
					s = s .. "(" .. tostring(interface)
					first = false
				else
					s = s .. ", " .. tostring(interface)
				end
			end
		end
		if self.mixins then
			for mixin in pairs(self.mixins) do
				if first then
					s = s .. tostring(mixin)
					first = false
				else
					s = s .. ", " .. tostring(mixin)
				end
			end
		end
		if first then
			if self.uid then
				return s .. ":" .. self.uid
			else
				return s
			end
		else
			return s .. ")"
		end
	else
		return self.uid and 'Subclass:' .. self.uid or 'Subclass'
	end
end

-- @table			Object
-- @brief			Base of all objects, including Class.
--
-- @method			init
-- @brief			Initialize a new object.
-- @param newobject The object to initialize
-- @param class		The class to make newobject inherit from
local Object
do
	Object = {}
	function Object:init(newobject, class)
		local parent = class or self
		if not rawget(newobject, 'uid') then
			newobject.uid = getuid(newobject)
		end
		local mt = {
			__index = parent,
			__tostring = objtostring,
		}
		setmetatable(newobject, mt)
	end
	Object.uid = getuid(Object)
	setmetatable(Object, { __tostring = function() return 'Object' end })
end

local Interface

local function validateInterface(object, interface)
	if not object.class and object.prototype then
		object = object.prototype
	end
	for k,v in pairs(interface.interface) do
		if tostring(type(object[k])) ~= v then
			return false
		end
	end
	if interface.superinterfaces then
		for superinterface in pairs(interface.superinterfaces) do
			if not validateInterface(object, superinterface) then
				return false
			end
		end
	end
	if type(object.class) == "table" and rawequal(object.class.prototype, object) then
		if not object.class.interfaces then
			rawset(object.class, 'interfaces', {})
		end
		object.class.interfaces[interface] = true
	elseif type(object.class) == "table" and type(object.class.prototype) == "table" then
		validateInterface(object.class.prototype, interface)
		-- check if class is proper, thus preventing future checks.
	end
	return true
end

-- @function		inherits
-- @brief			Return whether an Object or Class inherits from a given
--					parent.
-- @param object	Object or Class to check
-- @param parent	Parent to test inheritance from
-- @return			whether an Object or Class inherits from a given
--					parent.
local function inherits(object, parent)
	object = getlibrary(object)
	if type(parent) == "string" then
		if not AceLibrary:HasInstance(parent) then
			return false
		else
			parent = AceLibrary(parent)
		end
	end
	AceOO:argCheck(parent, 2, "table")
	if type(object) ~= "table" then
		return false
	end
	local current
	if object.class then
		current = object.class
	else
		current = object
	end
	if type(current) ~= "table" then
		return false
	end
	if rawequal(current, parent) then
		return true
	end
	if parent.class then
		while true do
			if rawequal(current, Object) then
				break
			end
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if rawequal(mixin, parent) then
						return true
					end
				end
			end
			if current.interfaces then
				for interface in pairs(current.interfaces) do
					if rawequal(interface, parent) then
						return true
					end
				end
			end
			current = current.super
			if type(current) ~= "table" then
				break
			end
		end
		
		local isInterface = false
		local curr = parent.class
		while true do
			if rawequal(curr, Object) then
				break
			elseif rawequal(curr, Interface) then
				isInterface = true
				break
			end
			curr = curr.super
			if type(curr) ~= "table" then
				break
			end
		end
		return isInterface and validateInterface(object, parent)
	else
		while true do
			if rawequal(current, parent) then
				return true
			elseif rawequal(current, Object) then
				return false
			end
			current = current.super
			if type(current) ~= "table" then
				return false
			end
		end
	end
end

-- @table			Class
-- @brief			An object factory which sets up inheritence and supports
--					'mixins'.
--
-- @metamethod		Class call
-- @brief			Call ClassFactory:new() to create a new class.
--
-- @method			Class new
-- @brief			Construct a new object.
-- @param (a1..a20) Arguments to pass to the object init function.
-- @return			The new object.
--
-- @method			Class init
-- @brief			Initialize a new class.
-- @param parent	Superclass.
-- @param (a1..a20) Mixins.
--
-- @method			Class ToString
-- @return			A string representing the object, in this case 'Class'.
local initStatus
local Class
local Mixin
local autoEmbed = false
local function traverseInterfaces(bit, total)
	if bit.superinterfaces then
		for interface in pairs(bit.superinterfaces) do
			if not total[interface] then
				total[interface] = true
				traverseInterfaces(interface, total)
			end
		end
	end
end
local class_new
do
	Class = Factory(Object, setmetatable({}, {__index = Object}), Object)
	Class.super = Object
	
	local function protostring(t)
		return '<' .. tostring(t.class) .. ' prototype>'
	end
	local function classobjectstring(t)
		if t.ToString then
			return t:ToString()
		elseif t.GetLibraryVersion then
			return (t:GetLibraryVersion())
		else
			return '<' .. tostring(t.class) .. ' instance>'
		end
	end
	local function classobjectequal(self, other)
		if type(self) == "table" and self.Equals then
			return self:Equals(other)
		elseif type(other) == "table" and other.Equals then
			return other:Equals(self)
		elseif type(self) == "table" and self.CompareTo then
			return self:CompareTo(other) == 0
		elseif type(other) == "table" and other.CompareTo then
			return other:CompareTo(self) == 0
		else
			return rawequal(self, other)
		end
	end
	local function classobjectlessthan(self, other)
		if type(self) == "table" and self.IsLessThan then
			return self:IsLessThan(other)
		elseif type(other) == "table" and other.IsLessThanOrEqualTo then
			return not other:IsLessThanOrEqualTo(self)
		elseif type(self) == "table" and self.CompareTo then
			return self:CompareTo(other) < 0
		elseif type(other) == "table" and other.CompareTo then
			return other:CompareTo(self) > 0
		elseif type(other) == "table" and other.IsLessThan and other.Equals then
			return other:Equals(self) or other:IsLessThan(self)
		else
			AceOO:error("cannot compare two objects")
		end
	end
	local function classobjectlessthanequal(self, other)
		if type(self) == "table" and self.IsLessThanOrEqualTo then
			return self:IsLessThanOrEqualTo(other)
		elseif type(other) == "table" and other.IsLessThan then
			return not other:IsLessThan(self)
		elseif type(self) == "table" and self.CompareTo then
			return self:CompareTo(other) <= 0
		elseif type(other) == "table" and other.CompareTo then
			return other:CompareTo(self) >= 0
		elseif type(self) == "table" and self.IsLessThan and self.Equals then
			return self:Equals(other) or self:IsLessThan(other)
		else
			AceOO:error("cannot compare two incompatible objects")
		end
	end
	local function classobjectadd(self, other)
		if type(self) == "table" and self.Add then
			return self:Add(other)
		else
			AceOO:error("cannot add two incompatible objects")
		end
	end
	local function classobjectsub(self, other)
		if type(self) == "table" and self.Subtract then
			return self:Subtract(other)
		else
			AceOO:error("cannot subtract two incompatible objects")
		end
	end
	local function classobjectunm(self, other)
		if type(self) == "table" and self.UnaryNegation then
			return self:UnaryNegation(other)
		else
			AceOO:error("attempt to negate an incompatible object")
		end
	end
	local function classobjectmul(self, other)
		if type(self) == "table" and self.Multiply then
			return self:Multiply(other)
		else
			AceOO:error("cannot multiply two incompatible objects")
		end
	end
	local function classobjectdiv(self, other)
		if type(self) == "table" and self.Divide then
			return self:Divide(other)
		else
			AceOO:error("cannot divide two incompatible objects")
		end
	end
	local function classobjectpow(self, other)
		if type(self) == "table" and self.Exponent then
			return self:Exponent(other)
		else
			AceOO:error("cannot exponentiate two incompatible objects")
		end
	end
	local function classobjectconcat(self, other)
		if type(self) == "table" and self.Concatenate then
			return self:Concatenate(other)
		else
			AceOO:error("cannot concatenate two incompatible objects")
		end
	end
	function class_new(self, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12,
						a13, a14, a15, a16, a17, a18, a19, a20)
		if self.virtual then
			AceOO:error("Cannot instantiate a virtual class.")
		end
		
		local o = self.prototype
		local newobj = {}
		if o.class and o.class.instancemeta then
			setmetatable(newobj, o.class.instancemeta)
		else
			Object:init(newobj, o)
		end
		
		if self.interfaces and not self.interfacesVerified then
			-- Verify the interfaces
			
			for interface in pairs(self.interfaces) do
				for field,kind in pairs(interface.interface) do
					if tostring(type(newobj[field])) ~= kind then
						AceOO:error("Class did not satisfy all interfaces. %q is required to be a %s. It is a %s", field, kind, tostring(type(newobj[field])))
					end
				end
			end
			self.interfacesVerified = true
		end
		local tmp = initStatus
		initStatus = newobj
		newobj:init(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12,
						a13, a14, a15, a16, a17, a18, a19, a20)
		if initStatus then
			initStatus = tmp
			AceOO:error("Initialization not completed, be sure to call the superclass's init method.")
			return
		end
		initStatus = tmp
		return newobj
	end
	local classmeta = {
		__tostring = objtostring,
		__call = function(self, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12,
						a13, a14, a15, a16, a17, a18, a19, a20)
			return self:new(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12,
						a13, a14, a15, a16, a17, a18, a19, a20)
		end,
	}
	function Class:init(newclass, parent, a1, a2, a3, a4, a5, a6, a7, a8, a9,
											a10, a11, a12, a13, a14, a15, a16,
											a17, a18, a19, a20)
		parent = parent or self
		
		local total
		
		if parent.class then
			total = {
				parent, a1, a2, a3, a4, a5, a6, a7, a8, a9,
						a10, a11, a12, a13, a14, a15, a16,
						a17, a18, a19, a20
			}
			parent = self
		else
			total = {
				a1, a2, a3, a4, a5, a6, a7, a8, a9,
				a10, a11, a12, a13, a14, a15, a16,
				a17, a18, a19, a20
			}
		end
		if not inherits(parent, Class) then
			AceOO:error("Classes must inherit from a proper class")
		end
		if parent.sealed then
			AceOO:error("Cannot inherit from a sealed class")
		end
		for i,v in ipairs(total) do
			if inherits(v, Mixin) and v.class then
				if not newclass.mixins then
					newclass.mixins = {}
				end
				if newclass.mixins[v] then
					AceOO:error("Cannot explicitly inherit from the same mixin twice")
				end
				newclass.mixins[v] = true
			elseif inherits(v, Interface) and v.class then
				if not newclass.interfaces then
					newclass.interfaces = {}
				end
				if newclass.interfaces[v] then
					AceOO:error("Cannot explicitly inherit from the same interface twice")
				end
				newclass.interfaces[v] = true
			else
				AceOO:error("Classes can only inherit from one or zero classes and any number of mixins or interfaces")
			end
		end
		if parent.interfaces then
			if newclass.interfaces then
				for interface in pairs(parent.interfaces) do
					newclass.interfaces[interface] = true
				end
			else
				newclass.interfaces = parent.interfaces
			end
		end
		for k in pairs(total) do
			total[k] = nil
		end
		table_setn(total, 0)
		
		newclass.super = parent
		
		newclass.prototype = setmetatable(total, {
			__index = parent.prototype,
			__tostring = protostring,
		})
		total = nil
		
		newclass.instancemeta = {
			__index = newclass.prototype,
			__tostring = classobjectstring,
			__eq = classobjectequal,
			__lt = classobjectlessthan,
			__le = classobjectlessthanequal,
			__add = classobjectadd,
			__sub = classobjectsub,
			__unm = classobjectunm,
			__mul = classobjectmul,
			__div = classobjectdiv,
			__pow = classobjectpow,
			__concat = classobjectconcat,
		}
		
		setmetatable(newclass, classmeta)
		
		newclass.new = class_new
		
		if newclass.mixins then
			-- Fold in the mixins
			local err, msg
			for mixin in pairs(newclass.mixins) do
				local ret
				autoEmbed = true
				ret, msg = pcall(mixin.embed, mixin, newclass.prototype)
				autoEmbed = false
				if not ret then
					err = true
					break
				end
			end
	
			if err then
				local pt = newclass.prototype
				for k,v in pairs(pt) do
					pt[k] = nil
				end
	
				-- method conflict
				AceOO:error(msg)
			end
		end
		
		newclass.prototype.class = newclass
		
		if newclass.interfaces then
			for interface in pairs(newclass.interfaces) do
				traverseInterfaces(interface, newclass.interfaces)
			end
		end
		if newclass.mixins then
			for mixin in pairs(newclass.mixins) do
				if mixin.interfaces then
					if not newclass.interfaces then
						newclass.interfaces = {}
					end
					for interface in pairs(mixin.interfaces) do
						newclass.interfaces[interface] = true
					end
				end
			end
		end
	end
	function Class:ToString()
		if type(self.GetLibraryVersion) == "function" then
			return (self:GetLibraryVersion())
		else
			return "Class"
		end
	end
	
	local tmp
	function Class.prototype:init()
		if rawequal(self, initStatus) then
			initStatus = nil
		else
			AceOO:error("Improper self passed to init. You must do MyClass.super.prototype.init(self, ...)", 2)
		end
		self.uid = getuid(self)
		local current = self.class
		while true do
			if current == Class then
				break
			end
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if type(mixin.OnInstanceInit) == "function" then
						mixin:OnInstanceInit(self)
					end
				end
			end
			current = current.super
		end
	end
end


-- @object	ClassFactory
-- @brief	A factory for creating classes.	Rarely used directly.
local ClassFactory = Factory(Object, Class, Object)

function Class:new(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11,
					a12, a13, a14, a15, a16, a17, a18, a19, a20)
	local x = ClassFactory:new(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11,
							a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if AceOO.classes then
		AceOO.classes[x] = true
	end
	return x
end
getmetatable(Class).__call = Class.new

-- @class	Mixin
-- @brief	A class to create mixin objects, which contain methods that get
-- "mixed in" to class prototypes.
--
-- @object	Mixin prototype
-- @brief	The prototype that mixin objects inherit their methods from.
--
-- @method	Mixin prototype embed
-- @brief	Mix in the methods of our object which are listed in our interface
--		 to the supplied target table.
--
-- @method	Mixin prototype init
-- @brief	Initialize the mixin object.
-- @param	newobj	 The new object we're initializing.
-- @param	interface	The interface we implement (the list of methods our
--					prototype provides which should be mixed into the target
--					table by embed).
do
	Mixin = Class()
	function Mixin:ToString()
		if self.GetLibraryVersion then
			return (self:GetLibraryVersion())
		else
			return 'Mixin'
		end
	end
	local function _Embed(state, field, target)
		field = next(state.export, field)
		if field == nil then
			return
		end

		if rawget(target, field) or (target[field] and target[field] ~= state[field]) then
			AceOO:error("Method conflict in attempt to mixin. Field %q", field)
		end

		target[field] = state[field]

		local ret,msg = pcall(_Embed, state, field, target)
		if not ret then
			-- Mix in the next method according to the defined interface.	If that
			-- fails due to a conflict, re-raise to back out the previous mixed
			-- methods.

			target[field] = nil
			AceOO:error(msg)
		end
	end
	function Mixin.prototype:embed(target)
		local mt = getmetatable(target)
		setmetatable(target, nil)
		local err, msg = pcall(_Embed, self, nil, target)
		if not err then
			setmetatable(target, mt)
			AceOO:error(msg)
			return
		end
		if type(self.embedList) == "table" then
			self.embedList[target] = true
		end
		if type(target.class) ~= "table" then
			target[self] = true
		end
		if not autoEmbed and type(self.OnManualEmbed) == "function" then
			self:OnManualEmbed(target)
		end
		setmetatable(target, mt)
	end
	
	function Mixin.prototype:activate(oldLib, oldDeactivate)
		if oldLib and oldLib.embedList then
			for target in pairs(oldLib.embedList) do
				local mt = getmetatable(target)
				setmetatable(target, nil)
				for field in pairs(oldLib.export) do
					target[field] = nil
				end
				setmetatable(target, mt)
			end
			self.embedList = oldLib.embedList
			for target in pairs(self.embedList) do
				self:embed(target)
			end
		else
			self.embedList = setmetatable({}, {__mode="k"})
		end
	end
	
	function Mixin.prototype:init(export, a1, a2, a3, a4, a5, a6, a7, a8, a9,
											a10, a11, a12, a13, a14, a15, a16,
											a17, a18, a19, a20)
		AceOO:argCheck(export, 2, "table")
		for k,v in pairs(export) do
			if type(k) ~= "number" then
				AceOO:error("All keys to argument #2 must be numbers.")
			elseif type(v) ~= "string" then
				AceOO:error("All values to argument #2 must be strings.")
			end
		end
		local num = table.getn(export)
		for i = 1, num do
			local v = export[i]
			export[i] = nil
			export[v] = true
		end
		table_setn(export, 0)
		local interfaces
		if a1 then
			local l = getlibrary
			interfaces = { l(a1), l(a2), l(a3), l(a4), l(a5), l(a6), l(a7), l(a8),
				l(a9), l(a10), l(a11), l(a12), l(a13), l(a14), l(a15), l(a16),
				l(a17), l(a18), l(a19), l(a20) }
			for _,v in ipairs(interfaces) do
				if not v.class or not inherits(v, Interface) then
					AceOO:error("Mixins can inherit only from interfaces")
				end
			end
			local num = table.getn(interfaces)
			for i = 1, num do
				local v = interfaces[i]
				interfaces[i] = nil
				interfaces[v] = true
			end
			table_setn(interfaces, 0)
			for interface in pairs(interfaces) do
				traverseInterfaces(interface, interfaces)
			end
			for interface in pairs(interfaces) do
				for field,kind in pairs(interface.interface) do
					if kind ~= "nil" then
						local good = false
						for bit in pairs(export) do
							if bit == field then
								good = true
								break
							end
						end
						if not good then
							AceOO:error("Mixin does not fully accommodate field %q", field)
						end
					end
				end
			end
		end
		self.super = Mixin.prototype
		Mixin.super.prototype.init(self)
		self.export = export
		self.interfaces = interfaces
	end
end

-- @class Interface
-- @brief A class to create interfaces, which contain contracts that classes
--			which inherit from this must comply with.
--
-- @object Interface prototype
-- @brief	The prototype that interface objects must adhere to.
--
-- @method Interface prototype init
-- @brief	Initialize the mixin object.
-- @param	interface	The interface we contract (the hash of fields forced).
-- @param	(a1..a20)	Superinterfaces
do
	Interface = Class()
	function Interface:ToString()
		if self.GetLibraryVersion then
			return (self:GetLibraryVersion())
		else
			return 'Instance'
		end
	end
	function Interface.prototype:init(interface, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
		Interface.super.prototype.init(self)
		AceOO:argCheck(interface, 2, "table")
		for k,v in pairs(interface) do
			if type(k) ~= "string" then
				AceOO:error("All keys to argument #2 must be numbers.")
			elseif type(v) ~= "string" then
				AceOO:error("All values to argument #2 must be strings.")
			elseif v ~= "nil" and v ~= "string" and v ~= "number" and v ~= "table" and v ~= "function" then
				AceOO:error('All values to argument #2 must either be "nil", "string", "number", "table", or "function".')
			end
		end
		local l = getlibrary
		a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20 = l(a1), l(a2), l(a3), l(a4), l(a5), l(a6), l(a7), l(a8), l(a9), l(a10), l(a11), l(a12), l(a13), l(a14), l(a15), l(a16), l(a17), l(a18), l(a19), l(a20)
		if a1 then
			self.superinterfaces = {a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20}
			for k,v in ipairs(self.superinterfaces) do
				if not inherits(v, Interface) or not v.class then
					AceOO:error('Cannot provide a non-Interface to inherit from')
				end
			end
			local num = table.getn(self.superinterfaces)
			for i = 1, num do
				local v = self.superinterfaces[i]
				self.superinterfaces[i] = nil
				self.superinterfaces[v] = true
			end
			table_setn(self.superinterfaces, 0)
		end
		self.interface = interface
	end
end

-- @function Classpool
-- @brief	Obtain a read only class from our pool of classes, indexed by the
--		 superclass and mixins.
-- @param	sc		 The superclass of the class we want.
-- @param	(m1..m20)	Mixins of the class we want's objects.
-- @return A read only class from the class pool.
local Classpool
do
	local pool = setmetatable({}, {__mode = 'v'})
	local function newindex(k, v)
		AceOO:error('Attempt to modify a read-only class.')
	end
	local function protonewindex(k, v)
		AceOO:error('Attempt to modify a read-only class prototype.')
	end
	local function ts(bit)
		if type(bit) ~= "table" then
			return tostring(bit)
		elseif getmetatable(bit) and bit.__tostring then
			return tostring(bit)
		elseif type(bit.GetLibraryVersion) == "function" then
			return bit:GetLibraryVersion()
		else
			return tostring(bit)
		end
	end
	local t
	local function getcomplexuid(sc, m1, m2, m3, m4, m5, m6, m7, m8, m9,
		m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20)
		if not t then t = {} end
		if sc then if sc.uid then table.insert(t, sc.uid) else AceOO:error("%s is not an appropriate class/mixin", ts(sc)) end
		if m1 then if m1.uid then table.insert(t, m1.uid) else AceOO:error("%s is not an appropriate mixin", ts(m1)) end
		if m2 then if m2.uid then table.insert(t, m2.uid) else AceOO:error("%s is not an appropriate mixin", ts(m2)) end
		if m3 then if m3.uid then table.insert(t, m3.uid) else AceOO:error("%s is not an appropriate mixin", ts(m3)) end
		if m4 then if m4.uid then table.insert(t, m4.uid) else AceOO:error("%s is not an appropriate mixin", ts(m4)) end
		if m5 then if m5.uid then table.insert(t, m5.uid) else AceOO:error("%s is not an appropriate mixin", ts(m5)) end
		if m6 then if m6.uid then table.insert(t, m6.uid) else AceOO:error("%s is not an appropriate mixin", ts(m6)) end
		if m7 then if m7.uid then table.insert(t, m7.uid) else AceOO:error("%s is not an appropriate mixin", ts(m7)) end
		if m8 then if m8.uid then table.insert(t, m8.uid) else AceOO:error("%s is not an appropriate mixin", ts(m8)) end
		if m9 then if m9.uid then table.insert(t, m9.uid) else AceOO:error("%s is not an appropriate mixin", ts(m9)) end
		if m10 then if m10.uid then table.insert(t, m10.uid) else AceOO:error("%s is not an appropriate mixin", ts(m10)) end
		if m11 then if m11.uid then table.insert(t, m11.uid) else AceOO:error("%s is not an appropriate mixin", ts(m11)) end
		if m12 then if m12.uid then table.insert(t, m12.uid) else AceOO:error("%s is not an appropriate mixin", ts(m12)) end
		if m13 then if m13.uid then table.insert(t, m13.uid) else AceOO:error("%s is not an appropriate mixin", ts(m13)) end
		if m14 then if m14.uid then table.insert(t, m14.uid) else AceOO:error("%s is not an appropriate mixin", ts(m14)) end
		if m15 then if m15.uid then table.insert(t, m15.uid) else AceOO:error("%s is not an appropriate mixin", ts(m15)) end
		if m16 then if m16.uid then table.insert(t, m16.uid) else AceOO:error("%s is not an appropriate mixin", ts(m16)) end
		if m17 then if m17.uid then table.insert(t, m17.uid) else AceOO:error("%s is not an appropriate mixin", ts(m17)) end
		if m18 then if m18.uid then table.insert(t, m18.uid) else AceOO:error("%s is not an appropriate mixin", ts(m18)) end
		if m19 then if m19.uid then table.insert(t, m19.uid) else AceOO:error("%s is not an appropriate mixin", ts(m19)) end
		if m20 then if m20.uid then table.insert(t, m20.uid) else AceOO:error("%s is not an appropriate mixin", ts(m20)) end
		end end end end end end end end end end end end end end end end end end end end end
		table.sort(t)
		local uid = table.concat(t, '')
		for k in pairs(t) do t[k] = nil end
		table_setn(t, 0)
		return uid
	end
	local classmeta
	function Classpool(sc, m1, m2, m3, m4, m5, m6, m7, m8, m9,
		m10, m11, m12, m13, m14, m15, m16,
		m17, m18, m19, m20)
		local l = getlibrary
		sc, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20 = l(sc), l(m1), l(m2), l(m3), l(m4), l(m5), l(m6), l(m7), l(m8), l(m9), l(m10), l(m11), l(m12), l(m13), l(m14), l(m15), l(m16), l(m17), l(m18), l(m19), l(m20)
		if sc and sc.class then
			sc, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20 = Class, sc, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19
		end
		sc = sc or Class
		local key = getcomplexuid(sc, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20)
		if not pool[key] then
			local class = Class(sc, m1, m2, m3, m4, m5, m6, m7, m8, m9,
			m10, m11, m12, m13, m14, m15, m16, m17,
			m18, m19, m20)
			if not classmeta then
				classmeta = {}
				local mt = getmetatable(class)
				for k,v in pairs(mt) do
					classmeta[k] = v
				end
				classmeta.__newindex = newindex
			end
			-- Prevent the user from adding methods to this class.
			-- NOTE: I'm not preventing modifications of existing class members,
			-- but it's likely that only a truly malicious user will be doing so.
			class.sealed = true
			setmetatable(class, classmeta)
			getmetatable(class.prototype).__newindex = protonewindex
			pool[key] = class
		end
		return pool[key]
	end
end

AceOO.Factory = Factory
AceOO.Object = Object
AceOO.Class = Class
AceOO.Mixin = Mixin
AceOO.Interface = Interface
AceOO.Classpool = Classpool
AceOO.inherits = inherits

-- Library handling bits

local function activate(self, oldLib, oldDeactivate)
	AceOO = self
	Factory = self.Factory
	Object = self.Object
	Class = self.Class
	ClassFactory.prototype = Class
	Mixin = self.Mixin
	Interface = self.Interface
	Classpool = self.Classpool
	
	if oldLib then
		self.classes = oldLib.classes
	end
	if not self.classes then
		self.classes = setmetatable({}, {__mode="k"})
	else
		for class in pairs(self.classes) do
			class.new = class_new
		end
	end
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceOO, MAJOR_VERSION, MINOR_VERSION, activate)
AceOO = AceLibrary(MAJOR_VERSION)
