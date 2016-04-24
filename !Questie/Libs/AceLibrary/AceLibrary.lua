--[[
Name: AceLibrary
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Iriel (iriel@vigilance-committee.org)
             Tekkub (tekkub@gmail.com)
             Revision: $Rev: 1091 $
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceLibrary
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceLibrary
Description: Versioning library to handle other library instances, upgrading,
             and proper access.
             It also provides a base for libraries to work off of, providing
             proper error tools. It is handy because all the errors occur in the
             file that called it, not in the library file itself.
Dependencies: None
License: LGPL v2.1
]]

local ACELIBRARY_MAJOR = "AceLibrary"
local ACELIBRARY_MINOR = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

local _G = getfenv(0)
local previous = _G[ACELIBRARY_MAJOR]
if previous and not previous:IsNewVersion(ACELIBRARY_MAJOR, ACELIBRARY_MINOR) then return end

do
	-- LibStub is a simple versioning stub meant for use in Libraries.  http://www.wowace.com/wiki/LibStub for more info
	-- LibStub is hereby placed in the Public Domain -- Credits: Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke
	local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2  -- NEVER MAKE THIS AN SVN REVISION! IT NEEDS TO BE USABLE IN ALL REPOS!
	local LibStub = _G[LIBSTUB_MAJOR]

	if not LibStub or LibStub.minor < LIBSTUB_MINOR then
		LibStub = LibStub or {libs = {}, minors = {} }
		_G[LIBSTUB_MAJOR] = LibStub
		LibStub.minor = LIBSTUB_MINOR
		
		function LibStub:NewLibrary(major, minor)
			assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
			minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")
			local oldminor = self.minors[major]
			if oldminor and oldminor >= minor then return nil end
			self.minors[major], self.libs[major] = minor, self.libs[major] or {}
			return self.libs[major], oldminor
		end
		
		function LibStub:GetLibrary(major, silent)
			if not self.libs[major] and not silent then
				error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
			end
			return self.libs[major], self.minors[major]
		end
		
		function LibStub:IterateLibraries() return pairs(self.libs) end
		setmetatable(LibStub, { __call = LibStub.GetLibrary })
	end
end
local LibStub = _G.LibStub

-- If you don't want AceLibrary to enable libraries that are LoadOnDemand but
-- disabled in the addon screen, set this to true.
local DONT_ENABLE_LIBRARIES = nil

local function safecall(func,...)
    local success, err = pcall(func,...)
    if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("\n(.-: )in.-\n") or "") .. err) end
end

-- @table AceLibrary
-- @brief System to handle all versioning of libraries.
local AceLibrary = {}
local AceLibrary_mt = {}
setmetatable(AceLibrary, AceLibrary_mt)

local function error(self, message, ...)
	if type(self) ~= "table" then
		return _G.error(("Bad argument #1 to `error' (table expected, got %s)"):format(type(self)), 2)
	end
	
	local stack = debugstack()
	if not message then
		local second = stack:match("\n(.-)\n")
		message = "error raised! " .. second
	else
		local arg = { ... } -- not worried about table creation, as errors don't happen often
		
		for i = 1, #arg do
			arg[i] = tostring(arg[i])
		end
		for i = 1, 10 do
			table.insert(arg, "nil")
		end
		message = message:format(unpack(arg))
	end
	
	if getmetatable(self) and getmetatable(self).__tostring then
		message = ("%s: %s"):format(tostring(self), message)
	elseif type(rawget(self, 'GetLibraryVersion')) == "function" and AceLibrary:HasInstance(self:GetLibraryVersion()) then
		message = ("%s: %s"):format(self:GetLibraryVersion(), message)
	elseif type(rawget(self, 'class')) == "table" and type(rawget(self.class, 'GetLibraryVersion')) == "function" and AceLibrary:HasInstance(self.class:GetLibraryVersion()) then
		message = ("%s: %s"):format(self.class:GetLibraryVersion(), message)
	end
	
	local first = stack:gsub("\n.*", "")
	local file = first:gsub(".*\\(.*).lua:%d+: .*", "%1")
	file = file:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
	
	
	local i = 0
	for s in stack:gmatch("\n([^\n]*)") do
		i = i + 1
		if not s:find(file .. "%.lua:%d+:") and not s:find("%(tail call%)") then
			file = s:gsub("^.*\\(.*).lua:%d+: .*", "%1")
			file = file:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
			break
		end
	end
	local j = 0
	for s in stack:gmatch("\n([^\n]*)") do
		j = j + 1
		if j > i and not s:find(file .. "%.lua:%d+:") and not s:find("%(tail call%)") then
			return _G.error(message, j+1)
		end
	end
	return _G.error(message, 2)
end

local type = type
local function argCheck(self, arg, num, kind, kind2, kind3, kind4, kind5)
	if type(num) ~= "number" then
		return error(self, "Bad argument #3 to `argCheck' (number expected, got %s)", type(num))
	elseif type(kind) ~= "string" then
		return error(self, "Bad argument #4 to `argCheck' (string expected, got %s)", type(kind))
	end
	arg = type(arg)
	if arg ~= kind and arg ~= kind2 and arg ~= kind3 and arg ~= kind4 and arg ~= kind5 then
		local stack = debugstack()
		local func = stack:match("`argCheck'.-([`<].-['>])")
		if not func then
			func = stack:match("([`<].-['>])")
		end
		if kind5 then
			return error(self, "Bad argument #%s to %s (%s, %s, %s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, kind4, kind5, arg)
		elseif kind4 then
			return error(self, "Bad argument #%s to %s (%s, %s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, kind4, arg)
		elseif kind3 then
			return error(self, "Bad argument #%s to %s (%s, %s, or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, kind3, arg)
		elseif kind2 then
			return error(self, "Bad argument #%s to %s (%s or %s expected, got %s)", tonumber(num) or 0/0, func, kind, kind2, arg)
		else
			return error(self, "Bad argument #%s to %s (%s expected, got %s)", tonumber(num) or 0/0, func, kind, arg)
		end
	end
end

local pcall
do
	local function check(self, ret, ...)
		if not ret then
			local s = ...
			return error(self, (s:gsub(".-%.lua:%d-: ", "")))
		else
			return ...
		end
	end

	function pcall(self, func, ...)
		return check(self, _G.pcall(func, ...))
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
	local kind = type(text)
	if kind == "number" or tonumber(text) then
		return tonumber(text)
	elseif kind == "string" then
		if text:find("^%$Revision: (%d+) %$$") then
			return tonumber((text:match("^%$Revision: (%d+) %$$")))
		elseif text:find("^%$Rev: (%d+) %$$") then
			return tonumber((text:match("^%$Rev: (%d+) %$$")))
		elseif text:find("^%$LastChangedRevision: (%d+) %$$") then
			return tonumber((text:match("^%$LastChangedRevision: (%d+) %$$")))
		end
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
	for k,v in pairs(t) do
		t[k] = nil 
	end
end

local function isFrame(frame)
	return type(frame) == "table" and type(rawget(frame, 0)) == "userdata" and type(rawget(frame, 'IsFrameType')) == "function" and getmetatable(frame) and type(rawget(getmetatable(frame), '__index')) == "function"
end

-- @function   copyTable
-- @brief      Create a shallow copy of a table and return it.
-- @param from The table to copy from
-- @return     A shallow copy of the table
local function copyTable(from, to)
	if not to then
		to = {}
	end
	for k,v in pairs(from) do
		to[k] = v
	end
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
		if not list then
			list = {}
			list2 = {}
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
	end
end

local function TryToEnable(addon)
	if DONT_ENABLE_LIBRARIES then return end
	local isondemand = IsAddOnLoadOnDemand(addon)
	if isondemand then
		local _, _, _, enabled = GetAddOnInfo(addon)
		EnableAddOn(addon)
		local _, _, _, _, loadable = GetAddOnInfo(addon)
		if not loadable and not enabled then
			DisableAddOn(addon)
		end

		return loadable
	end
end

-- @method      TryToLoadStandalone
-- @brief       Attempt to find and load a standalone version of the requested library
-- @param major A string representing the major version
-- @return      If library is found and loaded, true is return. If not loadable, false is returned.
--              If the library has been requested previously, nil is returned.
local function TryToLoadStandalone(major)
	if not AceLibrary.scannedlibs then AceLibrary.scannedlibs = {} end
	if AceLibrary.scannedlibs[major] then return end

	AceLibrary.scannedlibs[major] = true

	local name, _, _, enabled, loadable = GetAddOnInfo(major)
	
	loadable = (enabled and loadable) or TryToEnable(name)
	
	local loaded = false
	if loadable then
		loaded = true
		LoadAddOn(name)
	end
	
	local field = "X-AceLibrary-" .. major 
	for i = 1, GetNumAddOns() do
		if GetAddOnMetadata(i, field) then
			name, _, _, enabled, loadable = GetAddOnInfo(i)
			
			loadable = (enabled and loadable) or TryToEnable(name)
			if loadable then
				loaded = true
				LoadAddOn(name)
			end
		end
	end
	return loaded
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
			_G.error(("Bad argument #3 to  `IsNewVersion'. Must be a number or SVN revision string. %q is not appropriate"):format(minor), 2)
		end
	end
	argCheck(self, minor, 3, "number")
	local lib, oldMinor = LibStub:GetLibrary(major, true)
	if lib then
		return oldMinor < minor
	end
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
	if minor ~= false then
		TryToLoadStandalone(major)
	end
	
	local lib, ver = LibStub:GetLibrary(major, true)
	if not lib and self.libs[major] then
		lib, ver = self.libs[major].instance, self.libs[major].minor
	end
	if minor then
		if type(minor) == "string" then
			local m = svnRevisionToNumber(minor)
			if m then
				minor = m
			else
				_G.error(("Bad argument #3 to  `HasInstance'. Must be a number or SVN revision string. %q is not appropriate"):format(minor), 2)
			end
		end
		argCheck(self, minor, 3, "number")
		if not lib then
			return false
		end
		return ver == minor
	end
	return not not lib
end

-- @method      GetInstance
-- @brief       Returns the library with the given major/minor version.
-- @param major A string representing the major version.
-- @param minor (optional) An integer or an svn revision string representing the minor version.
-- @return      The library with the given major/minor version.
function AceLibrary:GetInstance(major, minor)
	argCheck(self, major, 2, "string")
	if minor ~= false then
		TryToLoadStandalone(major)
	end

	local data, ver = LibStub:GetLibrary(major, true)
	if not data then
		if self.libs[major] then
			data, ver = self.libs[major].instance, self.libs[major].minor
		else
			_G.error(("Cannot find a library instance of %s."):format(major), 2)
			return
		end
	end
	if minor then
		if type(minor) == "string" then
			local m = svnRevisionToNumber(minor)
			if m then
				minor = m
			else
				_G.error(("Bad argument #3 to  `GetInstance'. Must be a number or SVN revision string. %q is not appropriate"):format(minor), 2)
			end
		end
		argCheck(self, minor, 2, "number")
		if ver ~= minor then
			_G.error(("Cannot find a library instance of %s, minor version %d."):format(major, minor), 2)
		end
	end
	return data
end

-- Syntax sugar.  AceLibrary("FooBar-1.0")
AceLibrary_mt.__call = AceLibrary.GetInstance

local donothing = function() end

local AceEvent

local tmp = {}

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
	if major ~= ACELIBRARY_MAJOR then
		for k,v in pairs(_G) do
			if v == newInstance then
				geterrorhandler()((debugstack():match("(.-: )in.-\n") or "") .. ("Cannot register library %q. It is part of the global table in _G[%q]."):format(major, k))
			end
		end
	end
	if major ~= ACELIBRARY_MAJOR and not major:find("^[%a%-][%a%d%-]*%-%d+%.%d+$") then
		_G.error(string.format("Bad argument #3 to `Register'. Must be in the form of \"Name-1.0\". %q is not appropriate", major), 2)
	end
	if type(minor) == "string" then
		local m = svnRevisionToNumber(minor)
		if m then
			minor = m
		else
			_G.error(("Bad argument #4 to `Register'. Must be a number or SVN revision string. %q is not appropriate"):format(minor), 2)
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
		deactivateFunc = donothing
	end
	local data = self.libs[major]
	if not data then
		-- This is new
		if LibStub:GetLibrary(major, true) then
			error(self, "Cannot register library %q. It is already registered with LibStub.", major)
		end
		local instance = LibStub:NewLibrary(major, minor)
		copyTable(newInstance, instance)
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
		if not rawget(instance, 'argCheck') then
			rawset(instance, 'argCheck', argCheck)
		end
		if not rawget(instance, 'pcall') then
			rawset(instance, 'pcall', pcall)
		end
		addToPositions(instance, major)
		if activateFunc then
			safecall(activateFunc, instance, nil, nil) -- no old version, so explicit nil
		end
		
		if externalFunc then
			for k, data_instance in LibStub:IterateLibraries() do -- all libraries
				tmp[k] = data_instance
			end
			for k, data in pairs(self.libs) do -- Ace libraries which may not have been registered with LibStub
				tmp[k] = data.instance
			end
			for k, data_instance in pairs(tmp) do
				if k ~= major then
					safecall(externalFunc, instance, k, data_instance)
				end
				tmp[k] = nil
			end
		end
		
		for k,data in pairs(self.libs) do -- only Ace libraries
			if k ~= major and data.externalFunc then
				safecall(data.externalFunc, data.instance, major, instance)
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
	if minor <= data.minor then
		-- This one is already obsolete, raise an error.
		_G.error(("Obsolete library registered. %s is already registered at version %d. You are trying to register version %d. Hint: if not AceLibrary:IsNewVersion(%q, %d) then return end"):format(major, data.minor, minor, major, minor), 2)
		return
	end
	local instance = data.instance
	-- This is an update
	local oldInstance = {}
	
	local libStubInstance = LibStub:GetLibrary(major, true)
	if not libStubInstance then -- non-LibStub AceLibrary registered the library
		-- pass
	elseif libStubInstance ~= instance then	
		error(self, "Cannot register library %q. It is already registered with LibStub.", major)
	else
		LibStub:NewLibrary(major, minor) -- upgrade the minor version
	end
	
	addToPositions(newInstance, major)
	local isAceLibrary = (AceLibrary == newInstance)
	local old_error, old_argCheck, old_pcall
	if isAceLibrary then
		self = instance
		AceLibrary = instance
		
		old_error = instance.error
		old_argCheck = instance.argCheck
		old_pcall = instance.pcall
		
		self.error = error
		self.argCheck = argCheck
		self.pcall = pcall
	end
	deepTransfer(instance, newInstance, oldInstance, major)
	crawlReplace(instance, instance, newInstance)
	local oldDeactivateFunc = data.deactivateFunc
	data.minor = minor
	data.deactivateFunc = deactivateFunc
	data.externalFunc = externalFunc
	rawset(instance, 'GetLibraryVersion', function()
		return major, minor
	end)
	if not rawget(instance, 'error') then
		rawset(instance, 'error', error)
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
		safecall(activateFunc, instance, oldInstance, oldDeactivateFunc)
	else
		safecall(oldDeactivateFunc, oldInstance)
	end
	oldInstance = nil
	
	if externalFunc then
		for k, data_instance in LibStub:IterateLibraries() do -- all libraries
			tmp[k] = data_instance
		end
		for k, data in pairs(self.libs) do -- Ace libraries which may not have been registered with LibStub
			tmp[k] = data.instance
		end
		for k, data_instance in pairs(tmp) do
			if k ~= major then
				safecall(externalFunc, instance, k, data_instance)
			end
			tmp[k] = nil
		end
	end
	
	return instance
end

function AceLibrary:IterateLibraries()
	local t = {}
	for major, instance in LibStub:IterateLibraries() do
		t[major] = instance
	end
	for major, data in pairs(self.libs) do
		t[major] = data.instance
	end
	return pairs(t)
end

local function manuallyFinalize(major, instance)
	if AceLibrary.libs[major] then
		-- don't work on Ace libraries
		return
	end
	local finalizedExternalLibs = AceLibrary.finalizedExternalLibs
	if finalizedExternalLibs[major] then
		return
	end
	finalizedExternalLibs[major] = true
	
	for k,data in pairs(AceLibrary.libs) do -- only Ace libraries
		if k ~= major and data.externalFunc then
			safecall(data.externalFunc, data.instance, major, instance)
		end
	end
end

-- @function            Activate
-- @brief               The activateFunc for AceLibrary itself. Called when
--                      AceLibrary properly registers.
-- @param self          Reference to AceLibrary
-- @param oldLib        (optional) Reference to an old version of AceLibrary
-- @param oldDeactivate (optional) Function to deactivate the old lib
local function activate(self, oldLib, oldDeactivate)
	AceLibrary = self
	if not self.libs then
		self.libs = oldLib and oldLib.libs or {}
		self.scannedlibs = oldLib and oldLib.scannedlibs or {}
	end
	if not self.positions then
		self.positions = oldLib and oldLib.positions or setmetatable({}, { __mode = "k" })
	end
	self.finalizedExternalLibs = oldLib and oldLib.finalizedExternalLibs or {}
	self.frame = oldLib and oldLib.frame or CreateFrame("Frame")
	self.frame:UnregisterAllEvents()
	self.frame:RegisterEvent("ADDON_LOADED")
	self.frame:SetScript("OnEvent", function()
		for major, instance in LibStub:IterateLibraries() do
			manuallyFinalize(major, instance)
		end
	end)
	for major, instance in LibStub:IterateLibraries() do
		manuallyFinalize(major, instance)
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
AceLibrary:Register(AceLibrary, ACELIBRARY_MAJOR, ACELIBRARY_MINOR, activate, nil)
