--[[
Name: AceLibrary
Revision: $Rev: 14130 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Iriel (iriel@vigilance-committee.org)
             Tekkub (tekkub@gmail.com)
             Revision: $Rev: 14130 $
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceLibrary
SVN: http://svn.wowace.com/root/trunk/Ace2/AceLibrary
Description: Versioning library to handle other library instances, upgrading,
             and proper access.
             It also provides a base for libraries to work off of, providing
             proper error tools. It is handy because all the errors occur in the
             file that called it, not in the library file itself.
Dependencies: None
]]

local ACELIBRARY_MAJOR = "AceLibrary"
local ACELIBRARY_MINOR = "$Revision: 14130 $"

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

local string_gfind = string.gmatch or string.gfind

local _G = getfenv(0)
local previous = _G[ACELIBRARY_MAJOR]
if previous and not previous:IsNewVersion(ACELIBRARY_MAJOR, ACELIBRARY_MINOR) then return end

-- @table AceLibrary
-- @brief System to handle all versioning of libraries.
local AceLibrary = {}
local AceLibrary_mt = {}
setmetatable(AceLibrary, AceLibrary_mt)

local tmp
local function error(self, message, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if type(self) ~= "table" then
		_G.error(string.format("Bad argument #1 to `error' (table expected, got %s)", type(self)), 2)
	end
	if not tmp then
		tmp = {}
	else
		for k in pairs(tmp) do tmp[k] = nil end
		table_setn(tmp, 0)
	end

	table.insert(tmp, a1)
	table.insert(tmp, a2)
	table.insert(tmp, a3)
	table.insert(tmp, a4)
	table.insert(tmp, a5)
	table.insert(tmp, a6)
	table.insert(tmp, a7)
	table.insert(tmp, a8)
	table.insert(tmp, a9)
	table.insert(tmp, a10)
	table.insert(tmp, a11)
	table.insert(tmp, a12)
	table.insert(tmp, a13)
	table.insert(tmp, a14)
	table.insert(tmp, a15)
	table.insert(tmp, a16)
	table.insert(tmp, a17)
	table.insert(tmp, a18)
	table.insert(tmp, a19)
	table.insert(tmp, a20)

	local stack = debugstack()
	if not message then
		local _,_,second = string.find(stack, "\n(.-)\n")
		message = "error raised! " .. second
	else
		for i = 1,table.getn(tmp) do
			tmp[i] = tostring(tmp[i])
		end
		for i = 1,10 do
			table.insert(tmp, "nil")
		end
		message = string.format(message, unpack(tmp))
	end

	if getmetatable(self) and getmetatable(self).__tostring then
		message = string.format("%s: %s", tostring(self), message)
	elseif type(rawget(self, 'GetLibraryVersion')) == "function" and AceLibrary:HasInstance(self:GetLibraryVersion()) then
		message = string.format("%s: %s", self:GetLibraryVersion(), message)
	elseif type(rawget(self, 'class')) == "table" and type(rawget(self.class, 'GetLibraryVersion')) == "function" and AceLibrary:HasInstance(self.class:GetLibraryVersion()) then
		message = string.format("%s: %s", self.class:GetLibraryVersion(), message)
	end

	local first = string.gsub(stack, "\n.*", "")
	local file = string.gsub(first, ".*\\(.*).lua:%d+: .*", "%1")
	file = string.gsub(file, "([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")

	local i = 0
	for s in string_gfind(stack, "\n([^\n]*)") do
		i = i + 1
		if not string.find(s, file .. "%.lua:%d+:") then
			file = string.gsub(s, "^.*\\(.*).lua:%d+: .*", "%1")
			file = string.gsub(file, "([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
			break
		end
	end
	local j = 0
	for s in string_gfind(stack, "\n([^\n]*)") do
		j = j + 1
		if j > i and not string.find(s, file .. "%.lua:%d+:") then
			_G.error(message, j + 1)
			return
		end
	end
	_G.error(message, 2)
	return
end

local function assert(self, condition, message, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if not condition then
		if not message then
			local stack = debugstack()
			local _,_,second = string.find(stack, "\n(.-)\n")
			message = "assertion failed! " .. second
		end
		error(self, message, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
		return
	end
	return condition
end

local function argCheck(self, arg, num, kind, kind2, kind3, kind4, kind5)
	if type(num) ~= "number" then
		error(self, "Bad argument #3 to `argCheck' (number expected, got %s)", type(num))
	elseif type(kind) ~= "string" then
		error(self, "Bad argument #4 to `argCheck' (string expected, got %s)", type(kind))
	end
	local errored = false
	arg = type(arg)
	if arg ~= kind and arg ~= kind2 and arg ~= kind3 and arg ~= kind4 and arg ~= kind5 then
		local _,_,func = string.find(debugstack(), "`argCheck'.-([`<].-['>])")
		if not func then
			_,_,func = string.find(debugstack(), "([`<].-['>])")
		end
		if kind5 then
			error(self, "Bad argument #%s to %s (%s, %s, %s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, kind4, kind5, arg)
		elseif kind4 then
			error(self, "Bad argument #%s to %s (%s, %s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, kind4, arg)
		elseif kind3 then
			error(self, "Bad argument #%s to %s (%s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, arg)
		elseif kind2 then
			error(self, "Bad argument #%s to %s (%s or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, arg)
		else
			error(self, "Bad argument #%s to %s (%s expected, got %s)", tonumber(num) or 0/0, func, kind, arg)
		end
	end
end

local function pcall(self, func, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20 = _G.pcall(func, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if not a1 then
		error(self, string.gsub(a2, ".-%.lua:%d-: ", ""))
	else
		return a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20
	end
end

local recurse = {}
local function addToPositions(t, major)
	if not AceLibrary.positions[t] or AceLibrary.positions[t] == major then
		rawset(t, recurse, true)
		AceLibrary.positions[t] = major
		for k,v in pairs(t) do
			if type(v) == "table" and not rawget(v, recurse) then
				addToPositions(v, major)
			end
			if type(k) == "table" and not rawget(k, recurse) then
				addToPositions(k, major)
			end
		end
		local mt = getmetatable(t)
		if mt and not rawget(mt, recurse) then
			addToPositions(mt, major)
		end
		rawset(t, recurse, nil)
	end
end

local function svnRevisionToNumber(text)
	if type(text) == "string" then
		if string.find(text, "^%$Revision: (%d+) %$$") then
			return tonumber((string.gsub(text, "^%$Revision: (%d+) %$$", "%1")))
		elseif string.find(text, "^%$Rev: (%d+) %$$") then
			return tonumber((string.gsub(text, "^%$Rev: (%d+) %$$", "%1")))
		elseif string.find(text, "^%$LastChangedRevision: (%d+) %$$") then
			return tonumber((string.gsub(text, "^%$LastChangedRevision: (%d+) %$$", "%1")))
		end
	elseif type(text) == "number" then
		return text
	end
	return nil
end

local crawlReplace
do
	local recurse = {}
	local function func(t, to, from)
		if recurse[t] then
			return
		end
		recurse[t] = true
		local mt = getmetatable(t)
		setmetatable(t, nil)
		rawset(t, to, rawget(t, from))
		rawset(t, from, nil)
		for k,v in pairs(t) do
			if v == from then
				t[k] = to
			elseif type(v) == "table" then
				if not recurse[v] then
					func(v, to, from)
				end
			end

			if type(k) == "table" then
				if not recurse[k] then
					func(k, to, from)
				end
			end
		end
		setmetatable(t, mt)
		if mt then
			if mt == from then
				setmetatable(t, to)
			elseif not recurse[mt] then
				func(mt, to, from)
			end
		end
	end
	function crawlReplace(t, to, from)
		func(t, to, from)
		for k in pairs(recurse) do
			recurse[k] = nil
		end
	end
end

-- @function destroyTable
-- @brief    remove all the contents of a table
-- @param t  table to destroy
local function destroyTable(t)
	setmetatable(t, nil)
	for k,v in pairs(t) do t[k] = nil end
	table_setn(t, 0)
end

local function isFrame(frame)
	return type(frame) == "table" and type(rawget(frame, 0)) == "userdata" and type(rawget(frame, 'IsFrameType')) == "function" and getmetatable(frame) and type(rawget(getmetatable(frame), '__index')) == "function"
end

local new, del
do
	local tables = setmetatable({}, {__mode = "k"})

	function new()
		local t = next(tables)
		if t then
			tables[t] = nil
			return t
		else
			return {}
		end
	end

	function del(t, depth)
		if depth and depth > 0 then
			for k,v in pairs(t) do
				if type(v) == "table" and not isFrame(v) then
					del(v, depth - 1)
				end
			end
		end
		destroyTable(t)
		tables[t] = true
	end
end

-- @function   copyTable
-- @brief      Create a shallow copy of a table and return it.
-- @param from The table to copy from
-- @return     A shallow copy of the table
local function copyTable(from)
	local to = new()
	for k,v in pairs(from) do to[k] = v end
	table_setn(to, table.getn(from))
	setmetatable(to, getmetatable(from))
	return to
end

-- @function         deepTransfer
-- @brief            Fully transfer all data, keeping proper previous table
--                   backreferences stable.
-- @param to         The table with which data is to be injected into
-- @param from       The table whose data will be injected into the first
-- @param saveFields If available, a shallow copy of the basic data is saved
--                   in here.
-- @param list       The account of table references
-- @param list2      The current status on which tables have been traversed.
local deepTransfer
do
	-- @function   examine
	-- @brief      Take account of all the table references to be shared
	--             between the to and from tables.
	-- @param to   The table with which data is to be injected into
	-- @param from The table whose data will be injected into the first
	-- @param list An account of the table references
	local function examine(to, from, list, major)
		list[from] = to
		for k,v in pairs(from) do
			if rawget(to, k) and type(from[k]) == "table" and type(to[k]) == "table" and not list[from[k]] then
				if from[k] == to[k] then
					list[from[k]] = to[k]
				elseif AceLibrary.positions[from[v]] ~= major and AceLibrary.positions[from[v]] then
					list[from[k]] = from[k]
				elseif not list[from[k]] then
					examine(to[k], from[k], list, major)
				end
			end
		end
		return list
	end

	function deepTransfer(to, from, saveFields, major, list, list2)
		setmetatable(to, nil)
		local createdList
		if not list then
			createdList = true
			list = new()
			list2 = new()
			examine(to, from, list, major)
		end
		list2[to] = to
		for k,v in pairs(to) do
			if type(rawget(from, k)) ~= "table" or type(v) ~= "table" or isFrame(v) then
				if saveFields then
					saveFields[k] = v
				end
				to[k] = nil
			elseif v ~= _G then
				if saveFields then
					saveFields[k] = copyTable(v)
				end
			end
		end
		for k in pairs(from) do
			if rawget(to, k) and to[k] ~= from[k] and AceLibrary.positions[to[k]] == major and from[k] ~= _G then
				if not list2[to[k]] then
					deepTransfer(to[k], from[k], nil, major, list, list2)
				end
				to[k] = list[to[k]] or list2[to[k]]
			else
				rawset(to, k, from[k])
			end
		end
		table_setn(to, table.getn(from))
		setmetatable(to, getmetatable(from))
		local mt = getmetatable(to)
		if mt then
			if list[mt] then
				setmetatable(to, list[mt])
			elseif mt.__index and list[mt.__index] then
				mt.__index = list[mt.__index]
			end
		end
		destroyTable(from)
		if createdList then
			del(list)
			del(list2)
		end
	end
end

-- @method      TryToLoadStandalone
-- @brief       Attempt to find and load a standalone version of the requested library
-- @param major A string representing the major version
-- @return      If library is found, return values from the call to LoadAddOn are returned
--              If the library has been requested previously, nil is returned.
local function TryToLoadStandalone(major)
	if not AceLibrary.scannedlibs then AceLibrary.scannedlibs = {} end
	if AceLibrary.scannedlibs[major] then return end

	AceLibrary.scannedlibs[major] = true

	local name, _, _, enabled, loadable = GetAddOnInfo(major)
	if loadable then
		return LoadAddOn(name)
	end

	for i=1,GetNumAddOns() do
		if GetAddOnMetadata(i, "X-AceLibrary-"..major) then
			local name, _, _, enabled, loadable = GetAddOnInfo(i)
			if loadable then
				return LoadAddOn(name)
			end
		end
	end
end

-- @method      IsNewVersion
-- @brief       Obtain whether the supplied version would be an upgrade to the
--              current version. This allows for bypass code in library
--              declaration.
-- @param major A string representing the major version
-- @param minor An integer or an svn revision string representing the minor version
-- @return      whether the supplied version would be newer than what is
--              currently available.
function AceLibrary:IsNewVersion(major, minor)
	argCheck(self, major, 2, "string")
	TryToLoadStandalone(major)

	if type(minor) == "string" then
		local m = svnRevisionToNumber(minor)
		if m then
			minor = m
		else
			_G.error(string.format("Bad argument #3 to  `IsNewVersion'. Must be a number or SVN revision string. %q is not appropriate", minor), 2)
		end
	end
	argCheck(self, minor, 3, "number")
	local data = self.libs[major]
	if not data then
		return true
	end
	return data.minor < minor
end

-- @method      HasInstance
-- @brief       Returns whether an instance exists. This allows for optional support of a library.
-- @param major A string representing the major version.
-- @param minor (optional) An integer or an svn revision string representing the minor version.
-- @return      Whether an instance exists.
function AceLibrary:HasInstance(major, minor)
	argCheck(self, major, 2, "string")
	TryToLoadStandalone(major)

	if minor then
		if type(minor) == "string" then
			local m = svnRevisionToNumber(minor)
			if m then
				minor = m
			else
				_G.error(string.format("Bad argument #3 to  `HasInstance'. Must be a number or SVN revision string. %q is not appropriate", minor), 2)
			end
		end
		argCheck(self, minor, 3, "number")
		if not self.libs[major] then
			return
		end
		return self.libs[major].minor == minor
	end
	return self.libs[major] and true
end

-- @method      GetInstance
-- @brief       Returns the library with the given major/minor version.
-- @param major A string representing the major version.
-- @param minor (optional) An integer or an svn revision string representing the minor version.
-- @return      The library with the given major/minor version.
function AceLibrary:GetInstance(major, minor)
	argCheck(self, major, 2, "string")
	TryToLoadStandalone(major)

	local data = self.libs[major]
	if not data then
		_G.error(string.format("Cannot find a library instance of %s.", major), 2)
		return
	end
	if minor then
		if type(minor) == "string" then
			local m = svnRevisionToNumber(minor)
			if m then
				minor = m
			else
				_G.error(string.format("Bad argument #3 to  `GetInstance'. Must be a number or SVN revision string. %q is not appropriate", minor), 2)
			end
		end
		argCheck(self, minor, 2, "number")
		if data.minor ~= minor then
			_G.error(string.format("Cannot find a library instance of %s, minor version %d.", major, minor), 2)
			return
		end
	end
	return data.instance
end

-- Syntax sugar.  AceLibrary("FooBar-1.0")
AceLibrary_mt.__call = AceLibrary.GetInstance

local donothing

local AceEvent

-- @method               Register
-- @brief                Registers a new version of a given library.
-- @param newInstance    the library to register
-- @param major          the major version of the library
-- @param minor          the minor version of the library
-- @param activateFunc   (optional) A function to be called when the library is
--                       fully activated. Takes the arguments
--                       (newInstance [, oldInstance, oldDeactivateFunc]). If
--                       oldInstance is given, you should probably call
--                       oldDeactivateFunc(oldInstance).
-- @param deactivateFunc (optional) A function to be called by a newer library's
--                       activateFunc.
-- @param externalFunc   (optional) A function to be called whenever a new
--                       library is registered.
function AceLibrary:Register(newInstance, major, minor, activateFunc, deactivateFunc, externalFunc)
	argCheck(self, newInstance, 2, "table")
	argCheck(self, major, 3, "string")
	if type(minor) == "string" then
		local m = svnRevisionToNumber(minor)
		if m then
			minor = m
		else
			_G.error(string.format("Bad argument #4 to  `Register'. Must be a number or SVN revision string. %q is not appropriate", minor), 2)
		end
	end
	argCheck(self, minor, 4, "number")
	if math.floor(minor) ~= minor or minor < 0 then
		error(self, "Bad argument #4 to `Register' (integer >= 0 expected, got %s)", minor)
	end
	argCheck(self, activateFunc, 5, "function", "nil")
	argCheck(self, deactivateFunc, 6, "function", "nil")
	argCheck(self, externalFunc, 7, "function", "nil")
	if not deactivateFunc then
		if not donothing then
			donothing = function() end
		end
		deactivateFunc = donothing
	end
	local data = self.libs[major]
	if not data then
		-- This is new
		local instance = copyTable(newInstance)
		crawlReplace(instance, instance, newInstance)
		destroyTable(newInstance)
		if AceLibrary == newInstance then
			self = instance
			AceLibrary = instance
		end
		self.libs[major] = {
			instance = instance,
			minor = minor,
			deactivateFunc = deactivateFunc,
			externalFunc = externalFunc,
		}
		rawset(instance, 'GetLibraryVersion', function(self)
			return major, minor
		end)
		if not rawget(instance, 'error') then
			rawset(instance, 'error', error)
		end
		if not rawget(instance, 'assert') then
			rawset(instance, 'assert', assert)
		end
		if not rawget(instance, 'argCheck') then
			rawset(instance, 'argCheck', argCheck)
		end
		if not rawget(instance, 'pcall') then
			rawset(instance, 'pcall', pcall)
		end
		addToPositions(instance, major)
		if activateFunc then
			activateFunc(instance, nil, nil) -- no old version, so explicit nil
		end

		if externalFunc then
			for k,data in pairs(self.libs) do
				if k ~= major then
					externalFunc(instance, k, data.instance)
				end
			end
		end

		for k,data in pairs(self.libs) do
			if k ~= major and data.externalFunc then
				data.externalFunc(data.instance, major, instance)
			end
		end
		if major == "AceEvent-2.0" then
			AceEvent = instance
		end
		if AceEvent then
			AceEvent.TriggerEvent(self, "AceLibrary_Register", major, instance)
		end

		return instance
	end
	local instance = data.instance
	if minor <= data.minor then
		-- This one is already obsolete, raise an error.
		_G.error(string.format("Obsolete library registered. %s is already registered at version %d. You are trying to register version %d. Hint: if not AceLibrary:IsNewVersion(%q, %d) then return end", major, data.minor, minor, major, minor), 2)
		return
	end
	-- This is an update
	local oldInstance = new()

	addToPositions(newInstance, major)
	local isAceLibrary = (AceLibrary == newInstance)
	local old_error, old_assert, old_argCheck, old_pcall
	if isAceLibrary then
		self = instance
		AceLibrary = instance

		old_error = instance.error
		old_assert = instance.assert
		old_argCheck = instance.argCheck
		old_pcall = instance.pcall

		self.error = error
		self.assert = assert
		self.argCheck = argCheck
		self.pcall = pcall
	end
	deepTransfer(instance, newInstance, oldInstance, major)
	crawlReplace(instance, instance, newInstance)
	local oldDeactivateFunc = data.deactivateFunc
	data.minor = minor
	data.deactivateFunc = deactivateFunc
	data.externalFunc = externalFunc
	rawset(instance, 'GetLibraryVersion', function(self)
		return major, minor
	end)
	if not rawget(instance, 'error') then
		rawset(instance, 'error', error)
	end
	if not rawget(instance, 'assert') then
		rawset(instance, 'assert', assert)
	end
	if not rawget(instance, 'argCheck') then
		rawset(instance, 'argCheck', argCheck)
	end
	if not rawget(instance, 'pcall') then
		rawset(instance, 'pcall', pcall)
	end
	if isAceLibrary then
		for _,v in pairs(self.libs) do
			local i = type(v) == "table" and v.instance
			if type(i) == "table" then
				if not rawget(i, 'error') or i.error == old_error then
					rawset(i, 'error', error)
				end
				if not rawget(i, 'assert') or i.assert == old_assert then
					rawset(i, 'assert', assert)
				end
				if not rawget(i, 'argCheck') or i.argCheck == old_argCheck then
					rawset(i, 'argCheck', argCheck)
				end
				if not rawget(i, 'pcall') or i.pcall == old_pcall then
					rawset(i, 'pcall', pcall)
				end
			end
		end
	end
	if activateFunc then
		activateFunc(instance, oldInstance, oldDeactivateFunc)
	else
		oldDeactivateFunc(oldInstance)
	end
	del(oldInstance)

	if externalFunc then
		for k,data in pairs(self.libs) do
			if k ~= major then
				externalFunc(instance, k, data.instance)
			end
		end
	end

	return instance
end

local iter
function AceLibrary:IterateLibraries()
	if not iter then
		local function iter(t, k)
			k = next(t, k)
			if not k then
				return nil
			else
				return k, t[k].instance
			end
		end
	end
	return iter, self.libs, nil
end

-- @function            Activate
-- @brief               The activateFunc for AceLibrary itself. Called when
--                      AceLibrary properly registers.
-- @param self          Reference to AceLibrary
-- @param oldLib        (optional) Reference to an old version of AceLibrary
-- @param oldDeactivate (optional) Function to deactivate the old lib
local function activate(self, oldLib, oldDeactivate)
	if not self.libs then
		if oldLib then
			self.libs = oldLib.libs
			self.scannedlibs = oldLib.scannedlibs
		end
		if not self.libs then
			self.libs = {}
		end
		if not self.scannedlibs then
			self.scannedlibs = {}
		end
	end
	if not self.positions then
		if oldLib then
			self.positions = oldLib.positions
		end
		if not self.positions then
			self.positions = setmetatable({}, { __mode = "k" })
		end
	end

	-- Expose the library in the global environment
	_G[ACELIBRARY_MAJOR] = self

	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

if not previous then
	previous = AceLibrary
end
if not previous.libs then
	previous.libs = {}
end
AceLibrary.libs = previous.libs
if not previous.positions then
	previous.positions = setmetatable({}, { __mode = "k" })
end
AceLibrary.positions = previous.positions
AceLibrary:Register(AceLibrary, ACELIBRARY_MAJOR, ACELIBRARY_MINOR, activate)
