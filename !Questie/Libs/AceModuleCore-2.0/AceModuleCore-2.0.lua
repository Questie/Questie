--[[
Name: AceModuleCore-2.0
Revision: $Rev: 12441 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceModuleCore-2.0
SVN: http://svn.wowace.com/root/trunk/Ace2/AceModuleCore-2.0
Description: Mixin to provide a module system so that modules or plugins can
             use an addon as its core.
Dependencies: AceLibrary, AceOO-2.0, AceAddon-2.0, Compost-2.0 (optional)
]]

local MAJOR_VERSION = "AceModuleCore-2.0"
local MINOR_VERSION = "$Revision: 12441 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end

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

local new, del
do
	local list = setmetatable({}, {__mode = 'k'})
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
		table_setn(t, 0)
		list[t] = true
		return nil
	end
end

local AceOO = AceLibrary:GetInstance("AceOO-2.0")
local AceModuleCore = AceOO.Mixin {
									"NewModule",
									"HasModule",
									"GetModule",
									"IsModule",
									"IterateModules",
									"SetModuleMixins", 
									"SetModuleClass",
									"IsModuleActive",
									"ToggleModuleActive"
								  }

local Compost = AceLibrary:HasInstance("Compost-2.0") and AceLibrary("Compost-2.0")

local function getlibrary(lib)
	if type(lib) == "string" then
		return AceLibrary(lib)
	else
		return lib
	end
end

local tmp
function AceModuleCore:NewModule(name, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if not self.modules then
		AceModuleCore:error("CreatePrototype() must be called before attempting to create a new module.", 2)
	end
	AceModuleCore:argCheck(name, 2, "string")
	if string.len(name) == 0 then
		AceModuleCore:error("Bad argument #2 to `NewModule`, string must not be empty")
	end
	if self.modules[name] then
		AceModuleCore:error("The module %q has already been registered", name)
	end

	if not tmp then
		tmp = {}
	end
	if a1 then table.insert(tmp, a1)
	if a2 then table.insert(tmp, a2)
	if a3 then table.insert(tmp, a3)
	if a4 then table.insert(tmp, a4)
	if a5 then table.insert(tmp, a5)
	if a6 then table.insert(tmp, a6)
	if a7 then table.insert(tmp, a7)
	if a8 then table.insert(tmp, a8)
	if a9 then table.insert(tmp, a9)
	if a10 then table.insert(tmp, a10)
	if a11 then table.insert(tmp, a11)
	if a12 then table.insert(tmp, a12)
	if a13 then table.insert(tmp, a13)
	if a14 then table.insert(tmp, a14)
	if a15 then table.insert(tmp, a15)
	if a16 then table.insert(tmp, a16)
	if a17 then table.insert(tmp, a17)
	if a18 then table.insert(tmp, a18)
	if a19 then table.insert(tmp, a19)
	if a20 then table.insert(tmp, a20)
	end end end end end end end end end end end end end end end end end end end end
	for k,v in ipairs(tmp) do
		tmp[k] = getlibrary(v)
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
				table.insert(tmp, mixin)
			end
		end
	end

	local module = AceOO.Classpool(self.moduleClass, unpack(tmp)):new(name)
	self.modules[name] = module
	module.name = name
	module.title = name

	AceModuleCore.totalModules[module] = self

	for k in pairs(tmp) do
		tmp[k] = nil
	end
	table_setn(tmp, 0)
	return module
end

function AceModuleCore:HasModule(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if a1 then if not self.modules[a1] then return false end
	if a2 then if not self.modules[a2] then return false end
	if a3 then if not self.modules[a3] then return false end
	if a4 then if not self.modules[a4] then return false end
	if a5 then if not self.modules[a5] then return false end
	if a6 then if not self.modules[a6] then return false end
	if a7 then if not self.modules[a7] then return false end
	if a8 then if not self.modules[a8] then return false end
	if a9 then if not self.modules[a9] then return false end
	if a10 then if not self.modules[a10] then return false end
	if a11 then if not self.modules[a11] then return false end
	if a12 then if not self.modules[a12] then return false end
	if a13 then if not self.modules[a13] then return false end
	if a14 then if not self.modules[a14] then return false end
	if a15 then if not self.modules[a15] then return false end
	if a16 then if not self.modules[a16] then return false end
	if a17 then if not self.modules[a17] then return false end
	if a18 then if not self.modules[a18] then return false end
	if a19 then if not self.modules[a19] then return false end
	if a20 then if not self.modules[a20] then return false end
	end end end end end end end end end end end end end end end end end end end end

	return true
end

function AceModuleCore:GetModule(name)
	if not self.modules then
		AceModuleCore:error("Error initializing class.  Please report error.")
	end
	if not self.modules[name] then
		AceModuleCore:error("Cannot find module %q.", name)
	end
	return self.modules[name]
end

function AceModuleCore:IsModule(module)
	if self == AceModuleCore then
		return AceModuleCore.totalModules[module]
	else
		for k,v in pairs(self.modules) do
			if v == module then
				return true
			end
		end
		return false
	end
end

function AceModuleCore:IterateModules()
	local t = new()
	for k in pairs(self.modules) do
		table.insert(t, k)
	end
	table.sort(t)
	local i = 0
	return function()
		i = i + 1
		local x = t[i]
		if x then
			return x, self.modules[x]
		else
			t = del(t)
			return nil
		end
	end, nil, nil
end

function AceModuleCore:SetModuleMixins(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if self.moduleMixins then
		AceModuleCore:error('Cannot call "SetModuleMixins" twice')
	elseif not self.modules then
		AceModuleCore:error("Error initializing class.  Please report error.")
	elseif next(self.modules) then
		AceModuleCore:error('Cannot call "SetModuleMixins" after "NewModule" has been called.')
	end

	self.moduleMixins = Compost and Compost:Acquire(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20) or {a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20}
	for k,v in ipairs(self.moduleMixins) do
		self.moduleMixins[k] = getlibrary(v)
	end
end

function AceModuleCore:SetModuleClass(class)
	class = getlibrary(class)
	AceModuleCore:assert(AceOO.inherits(class, AceOO.Class), "Bad argument #2 to `SetModuleClass' (Class expected)")
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

function AceModuleCore:ToggleModuleActive(module, state)
	AceModuleCore:argCheck(module, 2, "table", "string")
	AceModuleCore:argCheck(state, 3, "nil", "boolean")

	if type(module) == "string" then
		if not self:HasModule(module) then
			AceModuleCore:error("Cannot find module %q", module)
		end
		module = self:GetModule(module)
	else
		if not self:IsModule(module) then
			AceModuleCore:error("%q is not a module", module)
		end
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
			AceModuleCore:error("Cannot toggle a module until `RegisterDB' has been called and `ADDON_LOADED' has been fireed.")
		end
		if type(self.db.raw.disabledModules) ~= "table" then
			self.db.raw.disabledModules = Compost and Compost:Acquire() or {}
		end
		local _,profile = self:GetProfile()
		if type(self.db.raw.disabledModules[profile]) ~= "table" then
			self.db.raw.disabledModules[profile] = Compost and Compost:Acquire() or {}
		end
		if type(self.db.raw.disabledModules[profile][module.name]) ~= "table" then
			self.db.raw.disabledModules[profile][module.name] = disable or nil
		end
		if not disable then
			if not next(self.db.raw.disabledModules[profile]) then
				if Compost then
					Compost:Reclaim(self.db.raw.disabledModules[profile])
				end
				self.db.raw.disabledModules[profile] = nil
			end
			if not next(self.db.raw.disabledModules) then
				if Compost then
					Compost:Reclaim(self.db.raw.disabledModules)
				end
				self.db.raw.disabledModules = nil
			end
		end
	else
		if type(self.disabledModules) ~= "table" then
			self.disabledModules = Compost and Compost:Acquire() or {}
		end
		self.disabledModules[module.name] = disable or nil
	end
	if AceOO.inherits(module, "AceAddon-2.0") then
		local AceAddon = AceLibrary("AceAddon-2.0")
		if not AceAddon.addonsStarted[module] then
			return
		end
	end
	if not disable then
		if type(module.OnEnable) == "function" then
			module:OnEnable()
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
						mixin:OnEmbedDisable(module)
					end
				end
			end
			current = current.super
		end
		if type(module.OnDisable) == "function" then
			module:OnDisable()
		end
	end
	return not disable
end

function AceModuleCore:IsModuleActive(module)
	AceModuleCore:argCheck(module, 2, "table", "string")
	
	if AceModuleCore == self then
		self:argCheck(module, 2, "table")
		
		local core = AceModuleCore.totalModules[module]
		if not core then
			self:error("Bad argument #2 to `IsModuleActive'. Not a module")
		end
		return core:IsModuleActive(module)
	end
	
	if type(module) == "string" then
		if not self:HasModule(module) then
			AceModuleCore:error("Cannot find module %q", module)
		end
		module = self:GetModule(module)
	else
		if not self:IsModule(module) then
			AceModuleCore:error("%q is not a module", module)
		end
	end

	if type(module.IsActive) == "function" then
		return module:IsActive()
	elseif AceOO.inherits(self, "AceDB-2.0") then
		local _,profile = self:GetProfile()
		return not self.db or not self.db.raw or not self.db.raw.disabledModules or not self.db.raw.disabledModules[profile] or not self.db.raw.disabledModules[profile][module.name]
	else
		return not self.disabledModules or not self.disabledModules[module.name]
	end
end

function AceModuleCore:OnInstanceInit(target)
	if target.modules then
		AceModuleCore:error("OnInstanceInit cannot be called twice")
	end
	target.modules = Compost and Compost:Acquire() or {}

	target.moduleClass = AceOO.Class("AceAddon-2.0")
	target.modulePrototype = target.moduleClass.prototype
end

AceModuleCore.OnManualEmbed = AceModuleCore.OnInstanceInit

local function activate(self, oldLib, oldDeactivate)
	AceModuleCore = self

	self.super.activate(self, oldLib, oldDeactivate)

	if oldLib then
		self.totalModules = oldLib.totalModules
	end
	if not self.totalModules then
		self.totalModules = {}
	end
end

local function external(self, major, instance)
	if major == "Compost-2.0" then
		Compost = instance
	end
end

AceLibrary:Register(AceModuleCore, MAJOR_VERSION, MINOR_VERSION, activate)
AceModuleCore = AceLibrary(MAJOR_VERSION)
