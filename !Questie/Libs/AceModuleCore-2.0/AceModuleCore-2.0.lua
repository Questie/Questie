--[[
Name: AceModuleCore-2.0
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceModuleCore-2.0
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceModuleCore-2.0
Description: Mixin to provide a module system so that modules or plugins can
             use an addon as its core.
Dependencies: AceLibrary, AceOO-2.0, AceAddon-2.0, AceEvent-2.0 (optional)
License: LGPL v2.1
]]

local MAJOR_VERSION = "AceModuleCore-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end

local function safecall(func, ...)
	local success, err = pcall(func, ...)
	if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("\n(.-: )in.-\n") or "") .. err) end
end

local AceEvent
local AceOO = AceLibrary:GetInstance("AceOO-2.0")
local AceModuleCore = AceOO.Mixin {
									"NewModule",
									"HasModule",
									"GetModule",
									"IsModule",
									"IterateModules",
									"IterateModulesWithMethod",
									"CallMethodOnAllModules",
									"SetModuleMixins",
									"SetModuleClass",
									"IsModuleActive",
									"ToggleModuleActive",
									"SetModuleDefaultState",
								  }
local AceAddon

local function getlibrary(lib)
	if type(lib) == "string" then
		return AceLibrary(lib)
	else
		return lib
	end
end

local new, del
do
	local list = setmetatable({}, {__mode='k'})
	function new()
		local t = next(list)
		if t then
			list[t] = nil
			return t
		else
			return {}
		end
	end
	function del(t)
		for k in pairs(t) do
			t[k] = nil
		end
		list[t] = true
		return nil
	end
end

local iterList = setmetatable({}, {__mode='v'})
local modulesWithMethod = setmetatable({}, {__mode='kv'})
do
	local function func(t)
		local i = t.i + 1
		local l = t.l
		local k = l[i]
		if k then
			t.i = i
			return k, l.m[k]
		else
			t = del(t)
		end
	end
	function AceModuleCore:IterateModules()
		local list = iterList[self]
		if not list then
			list = new()
			for k in pairs(self.modules) do
				list[#list+1] = k
			end
			table.sort(list)
			list.m = self.modules
			iterList[self] = list
		end
		local t = new()
		t.i = 0
		t.l = list
		return func, t, nil
	end
	
	function AceModuleCore:IterateModulesWithMethod(method)
		local masterList = modulesWithMethod[self]
		if not masterList then
			masterList = new()
			modulesWithMethod[self] = masterList
		end
		local list = masterList[method]
		if not list then
			list = new()
			for k, v in pairs(self.modules) do
				if self:IsModuleActive(k) and type(v[method]) == "function" then
					list[#list+1] = k
				end
			end
			table.sort(list)
			list.m = self.modules
			masterList[method] = list
		end
		local t = new()
		t.i = 0
		t.l = list
		return func, t, nil
	end
	
--[[----------------------------------------------------------------------------------
Notes:
	Safely calls the given method on all active modules if it exists on said modules. This will automatically subvert any errors that occur in the modules.
Arguments:
	string - the name of the method.
	tuple - the list of arguments to call the method with.
Example:
	core:CallMethodOnAllModules("OnSomething")
	core:CallMethodOnAllModules("OnSomethingElse", 1, 2, 3, 4)
------------------------------------------------------------------------------------]]
	function AceModuleCore:CallMethodOnAllModules(method, ...)
		for name, module in self:IterateModulesWithMethod(method) do
			local success, ret = pcall(module[method], module, ...)
			if not success then
				geterrorhandler(ret)
			end
		end
	end
end

--[[----------------------------------------------------------------------------
Notes: 
	Create a new module, parented to self.
	The module created does, in fact, inherit from AceAddon-2.0.
Arguments: 
	string - name/title of the Module.
	list of mixins the module is to inherit from.
Example:
	MyModule = core:NewModule('MyModule', "AceEvent-2.0", "AceHook-2.1")
------------------------------------------------------------------------------]]
local tmp = {}
function AceModuleCore:NewModule(name, ...)
	if not self.modules then
		AceModuleCore:error("CreatePrototype() must be called before attempting to create a new module.", 2)
	end
	AceModuleCore:argCheck(name, 2, "string")
	if name:len() == 0 then
		AceModuleCore:error("Bad argument #2 to `NewModule`, string must not be empty")
	end
	if self.modules[name] then
		AceModuleCore:error("The module %q has already been registered", name)
	end
	
	if iterList[self] then
		iterList[self] = del(iterList[self])
	end

	for i = 1, select('#', ...) do
		tmp[i] = getlibrary((select(i, ...)))
	end
	
	if self.moduleMixins then
		for _,mixin in ipairs(self.moduleMixins) do
			local exists = false
			for _,v in ipairs(tmp) do
				if mixin == v then
					exists = true
					break
				end
			end
			if not exists then
				tmp[#tmp+1] = mixin
			end
		end
	end

	local module = AceOO.Classpool(self.moduleClass, unpack(tmp)):new(name)
	self.modules[name] = module
	module.name = name
	module.title = name

	AceModuleCore.totalModules[module] = self
	
	if modulesWithMethod[self] then
		for k,v in pairs(modulesWithMethod[self]) do
			modulesWithMethod[self] = del(v)
		end
	end
	
	if type(self.OnModuleCreated) == "function" then
		safecall(self.OnModuleCreated, self, name, module)
	end
	if AceEvent then
		AceEvent:TriggerEvent("Ace2_ModuleCreated", module)
	end

	local num = #tmp
	for i = 1, num do
		tmp[i] = nil
	end
	return module
end
--[[----------------------------------------------------------------------------------
Notes:
	Return whether the module names given are all available in the core.
Arguments:
	list of strings that are the names of the modules. (typically you'd only check for one)
Returns:
	* boolean - Whether all the modules are available in the core.
Example:
	if core:HasModule('Bank') then
		-- do banking
	end
------------------------------------------------------------------------------------]]
function AceModuleCore:HasModule(...)
	for i = 1, select('#', ...) do
		if not self.modules[select(i, ...)] then
			return false
		end
	end
	
	return true
end

--[[------------------------------------------------------------------------------------
Notes:
	Return the module "name" if it exists.
	If the module doesnot exist, an error is thrown.
Arguments:
	string - the name of the module.
Returns:
	The module requested, if it exists.
Example:
	local bank = core:GetModule('Bank')
------------------------------------------------------------------------------------]]
function AceModuleCore:GetModule(name)
	if not self.modules then
		AceModuleCore:error("Error initializing class.  Please report error.")
	end
	if not self.modules[name] then
		AceModuleCore:error("Cannot find module %q.", name)
	end
	return self.modules[name]
end

--[[----------------------------------------------------------------------------------
Notes:
	Return whether the given module is actually a module.
Arguments:
	reference to the module
Returns:
	* boolean - whether the given module is actually a module.
Example:
	if core:IsModule(module) then
		-- do something
	end
	-- alternatively
	if AceModuleCore:IsModule(module) then
		-- checks all modules, no matter the parent
	end
------------------------------------------------------------------------------------]]
function AceModuleCore:IsModule(module)
	if self == AceModuleCore then
		return AceModuleCore.totalModules[module]
	elseif type(module) == "table" then
		if module.name and self.modules[module.name] and self.modules[module.name].name == module.name then
			return true
		end
		for k,v in pairs(self.modules) do
			if v == module then
				return true
			end
		end
		return false
	end
end

--[[----------------------------------------------------------------------------------
Notes:
 * Sets the default mixins for a given module.
 * This cannot be called after :NewModule() has been called.
 * This should really only be called if you use the mixins in your prototype.
Arguments:
	list of mixins (up to 20)
Example:
	core:SetModuleMixins("AceEvent-2.0", "AceHook-2.0")
------------------------------------------------------------------------------------]]
function AceModuleCore:SetModuleMixins(...)
	if self.moduleMixins then
		AceModuleCore:error('Cannot call "SetModuleMixins" twice')
	elseif not self.modules then
		AceModuleCore:error("Error initializing class.  Please report error.")
	elseif next(self.modules) then
		AceModuleCore:error('Cannot call "SetModuleMixins" after "NewModule" has been called.')
	end

	self.moduleMixins =  { ... }
	for i,v in ipairs(self.moduleMixins) do
		self.moduleMixins[i] = getlibrary(v)
	end
end

-- #NODOC
function AceModuleCore:SetModuleClass(class)
	class = getlibrary(class)
	if not AceOO.inherits(class, AceOO.Class) then
		AceModuleCore:error("Bad argument #2 to `SetModuleClass' (Class expected)")
	end
	if not self.modules then
		AceModuleCore:error("Error initializing class.  Please report error.")
	end
	if self.customModuleClass then
		AceModuleCore:error("Cannot call `SetModuleClass' twice.")
	end
	self.customModuleClass = true
	self.moduleClass = class
	self.modulePrototype = class.prototype
end

local mt = {__index=function(self, key)
	self[key] = false
	return false
end}
local defaultState = setmetatable({}, {__index=function(self, key)
	local t = setmetatable({}, mt)
	self[key] = t
	return t
end})

local function isDisabled(core, module)
	local moduleName
	if type(module) == "table" then
		moduleName = module.name
	else
		moduleName = module
	end
	local disabled
	if type(module) == "table" and type(module.IsActive) == "function" then
		return not module:IsActive()
	elseif AceOO.inherits(core, "AceDB-2.0") then
		local _,profile = core:GetProfile()
		disabled = core.db and core.db.raw and core.db.raw.disabledModules and core.db.raw.disabledModules[profile] and core.db.raw.disabledModules[profile][moduleName]
	else
		disabled = core.disabledModules and core.disabledModules[moduleName]
	end
	if disabled == nil then
		return defaultState[core][moduleName]
	else
		return disabled
	end
end

--[[----------------------------------------------------------------------------------
Notes:
	Sets the default active state of a module. This should be called before the ADDON_LOADED of the module.
Arguments:
	string - name of the module.
	table - reference to the module.
	boolean - new state. false means disabled by default, true means enabled by default (true is the default).
Example:
	self:SetModuleDefaultState('bank', false)
------------------------------------------------------------------------------------]]
function AceModuleCore:SetModuleDefaultState(module, state)
	AceModuleCore:argCheck(module, 2, "table", "string")
	AceModuleCore:argCheck(state, 3, "boolean")
	
	if type(module) == "table" then
		if not self:IsModule(module) then
			AceModuleCore:error("%q is not a module", module)
		end
		module = module.name
	end
	
	defaultState[self][module] = not state
end

--[[----------------------------------------------------------------------------------
Notes: 
Toggles the active state of a module.

This calls module:ToggleActive([state]) if available.

If suspending, This will call :OnDisable() on the module if it is available. Also, it will iterate through the addon's mixins and call :OnEmbedDisable(module) if available. - this in turn will, through AceEvent and others, unregister events/hooks/etc. depending on the mixin. Also, it will call :OnModuleDisable(module) on the core if it is available.

If resuming, This will call :OnEnable(first) on the module if it is available. Also, it will iterate through the addon's mixins and call :OnEmbedEnable(module) if available. - this in turn will, through AceEvent and others, unregister events/hooks/etc. depending on the mixin. Also, it will call :OnModuleEnable(module) on the core if it is available.

If you call :ToggleModuleActive("name or module, true) and it is already active, it silently returns, same if you pass false and it is inactive.

Arguments:
	string/table - name of the module or a reference to the module
	[optional] boolean - new state. (default not :IsModuleActive("name" or module))
Returns:
	* boolean - Whether the module is now in an active (enabled) state.
Example:
	self:ToggleModuleActive('bank')
------------------------------------------------------------------------------------]]
function AceModuleCore:ToggleModuleActive(module, state)
	AceModuleCore:argCheck(module, 2, "table", "string")
	AceModuleCore:argCheck(state, 3, "nil", "boolean")
	
	if type(module) == "string" then
		if not self:HasModule(module) then
			AceModuleCore:error("Cannot find module %q", module)
		end
		module = self:GetModule(module)
	elseif not self:IsModule(module) then
		AceModuleCore:error("%q is not a module", module)
	end

	local disable
	if state == nil then
		disable = self:IsModuleActive(module)
	else
		disable = not state
		if disable ~= self:IsModuleActive(module) then
			return
		end
	end

	if type(module.ToggleActive) == "function" then
		return module:ToggleActive(not disable)
	elseif AceOO.inherits(self, "AceDB-2.0") then
		if not self.db or not self.db.raw then
			AceModuleCore:error("Cannot toggle a module until `RegisterDB' has been called and `ADDON_LOADED' has been fired.")
		end
		if type(self.db.raw.disabledModules) ~= "table" then
			self.db.raw.disabledModules = {}
		end
		local _,profile = self:GetProfile()
		if type(self.db.raw.disabledModules[profile]) ~= "table" then
			self.db.raw.disabledModules[profile] = {}
		end
		if type(self.db.raw.disabledModules[profile][module.name]) ~= "table" then
			local value = nil
			if disable ~= defaultState[self][module.name] then
				value = disable
			end
			self.db.raw.disabledModules[profile][module.name] = value
		end
		if not disable then
			if not next(self.db.raw.disabledModules[profile]) then
				self.db.raw.disabledModules[profile] = nil
			end
			if not next(self.db.raw.disabledModules) then
				self.db.raw.disabledModules = nil
			end
		end
	else
		if type(self.disabledModules) ~= "table" then
			self.disabledModules = {}
		end
		local value = nil
		if disable ~= defaultState[self][module.name] then
			value = disable
		end
		self.disabledModules[module.name] = value
	end
	if AceOO.inherits(module, "AceAddon-2.0") then
		if not AceAddon.addonsStarted[module] then
			return
		end
	end
	if not disable then
		local first = nil
		if AceOO.inherits(module, "AceAddon-2.0") then
			if AceAddon.addonsEnabled and not AceAddon.addonsEnabled[module] then
				AceAddon.addonsEnabled[module] = true
				first = true
			end
		end
		local current = module.class
		while true do
			if current == AceOO.Class then
				break
			end
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if type(mixin.OnEmbedEnable) == "function" then
						safecall(mixin.OnEmbedEnable, mixin, module, first)
					end
				end
			end
			current = current.super
		end
		if type(module.OnEnable) == "function" then
			safecall(module.OnEnable, module, first)
		end
		if AceEvent then
			AceEvent:TriggerEvent("Ace2_AddonEnabled", module, first)
		end
	else
		local current = module.class
		while true do
			if current == AceOO.Class then
				break
			end
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if type(mixin.OnEmbedDisable) == "function" then
						safecall(mixin.OnEmbedDisable, mixin, module)
					end
				end
			end
			current = current.super
		end
		if type(module.OnDisable) == "function" then
			safecall(module.OnDisable, module)
		end
		if AceEvent then
			AceEvent:TriggerEvent("Ace2_AddonDisabled", module)
		end
	end
	return not disable
end

--[[-----------------------------------------------------------------------
Notes:
	Returns whether the module is in an active (enabled) state. This calls module:IsActive() if available. if notLoaded is set, then "name" must be a string.
Arguments:
	string/table - name of the module or a reference to the module
	[optional] - boolean - if set, this will check modules that are not loaded as well. (default: false)
Returns:
	* boolean - Whether the module is in an active (enabled) state.
Example:
	assert(self:IsModuleActive('bank'))
------------------------------------------------------------------------]]
function AceModuleCore:IsModuleActive(module, notLoaded)
	AceModuleCore:argCheck(module, 2, "table", "string")
	AceModuleCore:argCheck(notLoaded, 3, "nil", "boolean")
	if notLoaded then
		AceModuleCore:argCheck(module, 2, "string")
	end
	
	if AceModuleCore == self then
		self:argCheck(module, 2, "table")
		
		local core = AceModuleCore.totalModules[module]
		if not core then
			self:error("Bad argument #2 to `IsModuleActive'. Not a module")
		end
		return core:IsModuleActive(module)
	end

	if type(module) == "string" then
		if not notLoaded and not self:HasModule(module) then
			AceModuleCore:error("Cannot find module %q", module)
		end
		if not notLoaded then
			module = self:GetModule(module)
		else
			module = self:HasModule(module) and self:GetModule(module) or module
		end
	else
		if not self:IsModule(module) then
			AceModuleCore:error("%q is not a module", module)
		end
	end
	
	return not isDisabled(self, module)
end

-- #NODOC
function AceModuleCore:OnInstanceInit(target)
	if target.modules then
		do return end
		AceModuleCore:error("OnInstanceInit cannot be called twice")
	end
	
	if not AceAddon then
		if AceLibrary:HasInstance("AceAddon-2.0") then
			AceAddon = AceLibrary("AceAddon-2.0")
		else
			self:error(MAJOR_VERSION .. " requires AceAddon-2.0")
		end
	end
	target.modules = {}

	target.moduleClass = AceOO.Class("AceAddon-2.0")
	target.modulePrototype = target.moduleClass.prototype
end

AceModuleCore.OnManualEmbed = AceModuleCore.OnInstanceInit

function AceModuleCore.OnEmbedProfileDisable(AceModuleCore, self, newProfile)
	if not AceOO.inherits(self, "AceDB-2.0") then
		return
	end
	local _,currentProfile = self:GetProfile()
	for k, module in pairs(self.modules) do
		if type(module.IsActive) == "function" or type(module.ToggleActive) == "function" then
			-- continue
		else
			local currentActive =  not self.db or not self.db.raw or not self.db.raw.disabledModules or not self.db.raw.disabledModules[currentProfile] or not self.db.raw.disabledModules[currentProfile][module.name]
			local newActive =  not self.db or not self.db.raw or not self.db.raw.disabledModules or not self.db.raw.disabledModules[newProfile] or not self.db.raw.disabledModules[newProfile][module.name]
			if currentActive ~= newActive then
				self:ToggleModuleActive(module)
				if not self.db.raw.disabledModules then
					self.db.raw.disabledModules = {}
				end
				if not self.db.raw.disabledModules[currentProfile] then
					self.db.raw.disabledModules[currentProfile] = {}
				end
				self.db.raw.disabledModules[currentProfile][module.name] = not currentActive or nil
			end
		end
	end
end

-- #NODOC
function AceModuleCore:Ace2_AddonEnabled(module, first)
	local addon = self.totalModules[module]
	if not addon then
		return
	end
	
	if modulesWithMethod[addon] then
		for k,v in pairs(modulesWithMethod[addon]) do
			modulesWithMethod[addon] = del(v)
		end
	end
	if type(addon.OnModuleEnable) == "function" then
		safecall(addon.OnModuleEnable, addon, module, first)
	end
end

-- #NODOC
function AceModuleCore:Ace2_AddonDisabled(module)
	local addon = self.totalModules[module]
	if not addon then
		return
	end
	
	if modulesWithMethod[addon] then
		for k,v in pairs(modulesWithMethod[addon]) do
			modulesWithMethod[addon] = del(v)
		end
	end
	if type(addon.OnModuleDisable) == "function" then
		safecall(addon.OnModuleDisable, addon, module)
	end
end

local function activate(self, oldLib, oldDeactivate)
	AceModuleCore = self

	self.totalModules = oldLib and oldLib.totalModules or {}
	
	self:activate(oldLib, oldDeactivate)
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		AceEvent = instance
		AceEvent:embed(self)
		
		self:UnregisterAllEvents()
		self:RegisterEvent("Ace2_AddonEnabled")
		self:RegisterEvent("Ace2_AddonDisabled")
	elseif major == "AceAddon-2.0" then
		AceAddon = instance
	end
end

AceLibrary:Register(AceModuleCore, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
AceModuleCore = AceLibrary(MAJOR_VERSION)
