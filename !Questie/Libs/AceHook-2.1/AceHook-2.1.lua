--[[
Name: AceHook-2.1
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceHook-2.1
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceHook-2.1
Description: Mixin to allow for safe hooking of functions, methods, and scripts.
Dependencies: AceLibrary, AceOO-2.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "AceHook-2.1"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

-- This ensures the code is only executed if the libary doesn't already exist, or is a newer version
if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end

--[[---------------------------------------------------------------------------------
  Create the library object
----------------------------------------------------------------------------------]]

local AceOO = AceLibrary:GetInstance("AceOO-2.0")
local AceHook = AceOO.Mixin {
								"Hook",
								"HookScript",
								"SecureHook",
								"SecureHookScript",
								"Unhook",
								"UnhookAll",
								"HookReport",
								"IsHooked",
							}

--[[---------------------------------------------------------------------------------
  Library Definitions
----------------------------------------------------------------------------------]]

local protectedScripts = {
	OnClick = true,
}

local _G = getfenv(0)

local handlers, scripts, actives, registry, onceSecure

--[[---------------------------------------------------------------------------------
  Private definitions (Not exposed)
----------------------------------------------------------------------------------]]

local new, del
do
	local list = setmetatable({}, {__mode = "k"})
	function new()
		local t = next(list)
		if not t then
			return {}
		end
		list[t] = nil
		return t
	end
	
	function del(t)
		setmetatable(t, nil)
		for k in pairs(t) do
			t[k] = nil
		end
		list[t] = true
	end
end

local function createFunctionHook(self, func, handler, orig, secure)
	if not secure then
		if type(handler) == "string" then
			-- The handler is a method, need to self it
			local uid
			uid = function(...)
				if actives[uid] then
					return self[handler](self, ...)
				else
					return orig(...)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(...)
				if actives[uid] then
					return handler(...)
				else
					return orig(...)
				end
			end
			return uid
		end
	else
		-- secure hooks don't call the original method
		if type(handler) == "string" then
			-- The handler is a method, need to self it
			local uid
			uid = function(...)
				if actives[uid] then
					return self[handler](self, ...)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(...)
				if actives[uid] then
					return handler(...)
				end
			end
			return uid
		end
	end
end

local function createMethodHook(self, object, method, handler, orig, secure)
	if not secure then
		if type(handler) == "string" then
			local uid
			uid = function(...)
				if actives[uid] then
					return self[handler](self, ...)
				else
					return orig(...)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(...)
				if actives[uid] then
					return handler(...)
				else
					return orig(...)
				end
			end
			return uid
		end
	else
		-- secure hooks don't call the original method
		if type(handler) == "string" then
			local uid
			uid = function(...)
				if actives[uid] then
					return self[handler](self, ...)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(...)
				if actives[uid] then
					return handler(...)
				end
			end
			return uid
		end
	end
end

local function hookFunction(self, func, handler, secure)
	local orig = _G[func]
	
	if not orig or type(orig) ~= "function" then
		AceHook:error("Attempt to hook a non-existant function %q", func)
	end
	
	if not handler then
		handler = func
	end

	local uid = registry[self][func]
	if uid then
		if actives[uid] then
			-- We have an active hook from this source.  Don't multi-hook
			AceHook:error("%q already has an active hook from this source.", func)
		end
		
		if handlers[uid] == handler then
			-- The hook is inactive, so reactivate it
			actives[uid] = true
			return
		else
			self.hooks[func] = nil
			registry[self][func] = nil
			handlers[uid] = nil
			uid = nil
		end
	end
	
	if type(handler) == "string" then
		if type(self[handler]) ~= "function" then
			AceHook:error("Could not find the the handler %q when hooking function %q", handler, func)
		end
	elseif type(handler) ~= "function" then
		AceHook:error("Could not find the handler you supplied when hooking %q", func)
	end
	
	uid = createFunctionHook(self, func, handler, orig, secure)
	registry[self][func] = uid
	actives[uid] = true
	handlers[uid] = handler
	
	if not secure then
		_G[func] = uid
		self.hooks[func] = orig
	else
		hooksecurefunc(func, uid)
	end
end

local function unhookFunction(self, func)
	if not registry[self][func] then
		AceHook:error("Tried to unhook %q which is not currently hooked.", func)
	end
	
	local uid = registry[self][func]
	
	if actives[uid] then
		-- See if we own the global function
		if self.hooks[func] and _G[func] == uid then
			_G[func] = self.hooks[func]
			self.hooks[func] = nil
			registry[self][func] = nil
			handlers[uid] = nil
			actives[uid] = nil
			-- Magically all-done
		else
			actives[uid] = nil
		end
	end
end

local donothing = function() end

local function hookMethod(self, obj, method, handler, script, secure)
	if not handler then
		handler = method
	end
	
	if not obj or type(obj) ~= "table" then
		AceHook:error("The object you supplied could not be found, or isn't a table.")
	end
	
	local uid = registry[self][obj] and registry[self][obj][method]
	if uid then
		if actives[uid] then
			-- We have an active hook from this source.  Don't multi-hook
			AceHook:error("%q already has an active hook from this source.", method)
		end
		
		if handlers[uid] == handler then
			-- The hook is inactive, reactivate it.
			actives[uid] = true
			return
		else
			if self.hooks[obj] then
				self.hooks[obj][method] = nil
			end
			registry[self][obj][method] = nil
			handlers[uid] = nil
			actives[uid] = nil
			scripts[uid] = nil
			uid = nil
		end
	end
	
	if type(handler) == "string" then
		if type(self[handler]) ~= "function" then
			AceHook:error("Could not find the handler %q you supplied when hooking method %q", handler, method)
		end
	elseif type(handler) ~= "function" then
		AceHook:error("Could not find the handler you supplied when hooking method %q", method)
	end
	
	local orig
	if script then
		if not obj.GetScript then
			AceHook:error("The object you supplied does not have a GetScript method.")
		end
		if not obj:HasScript(method) then
			AceHook:error("The object you supplied doesn't allow the %q method.", method)
		end
		
		orig = obj:GetScript(method)
		if type(orig) ~= "function" then
			-- Sometimes there is not a original function for a script.
			orig = donothing
		end
	else
		orig = obj[method]
	end
	if not orig then
		AceHook:error("Could not find the method or script %q you are trying to hook.", method)
	end
	
	if not self.hooks[obj] then
		self.hooks[obj] = new()
	end
	if not registry[self][obj] then
		registry[self][obj] = new()
	end
	
	local uid = createMethodHook(self, obj, method, handler, orig, secure)
	registry[self][obj][method] = uid
	actives[uid] = true
	handlers[uid] = handler
	scripts[uid] = script and true or nil
	
	if script then
		if not secure then
			obj:SetScript(method, uid)
			self.hooks[obj][method] = orig
		else
			obj:HookScript(method, uid)
		end
	else
		if not secure then
			obj[method] = uid
			self.hooks[obj][method] = orig
		else
			hooksecurefunc(obj, method, uid)
		end
	end
end

local function unhookMethod(self, obj, method)
	if not registry[self][obj] or not registry[self][obj][method] then
		AceHook:error("Attempt to unhook a method %q that is not currently hooked.", method)
		return
	end
	
	local uid = registry[self][obj][method]
	
	if actives[uid] then
		if scripts[uid] then -- If this is a script
			if obj:GetScript(method) == uid then
				-- We own the script.  Revert to normal.
				if self.hooks[obj][method] == donothing then
					obj:SetScript(method, nil)
				else
					obj:SetScript(method, self.hooks[obj][method])
				end
				self.hooks[obj][method] = nil
				registry[self][obj][method] = nil
				handlers[uid] = nil
				scripts[uid] = nil
				actives[uid] = nil
			else
				actives[uid] = nil
			end
		else
			if self.hooks[obj] and self.hooks[obj][method] and obj[method] == uid then
				-- We own the method.  Revert to normal.
				obj[method] = self.hooks[obj][method]
				self.hooks[obj][method] = nil
				registry[self][obj][method] = nil
				handlers[uid] = nil
				actives[uid] = nil
			else
				actives[uid] = nil
			end
		end
	end
	if self.hooks[obj] and not next(self.hooks[obj]) then
		self.hooks[obj] = del(self.hooks[obj])
	end
	if not next(registry[self][obj]) then
		registry[self][obj] = del(registry[self][obj])
	end
end

-- ("function" [, handler] [, hookSecure]) or (object, "method" [, handler] [, hookSecure])
function AceHook:Hook(object, method, handler, hookSecure)
	if type(object) == "string" then
		method, handler, hookSecure = object, method, handler
		if handler == true then
			handler, hookSecure = nil, true
		end
		AceHook:argCheck(handler, 3, "function", "string", "nil")
		AceHook:argCheck(hookSecure, 4, "boolean", "nil")
		if issecurevariable(method) or onceSecure[method] then
			if hookSecure then
				onceSecure[method] = true
			else
				AceHook:error("Attempt to hook secure function %q. Use `SecureHook' or add `true' to the argument list to override.", method)
			end
		end
		hookFunction(self, method, handler, false)
	else
		if handler == true then
			handler, hookSecure = nil, true
		end
		AceHook:argCheck(object, 2, "table")
		AceHook:argCheck(method, 3, "string")
		AceHook:argCheck(handler, 4, "function", "string", "nil")
		AceHook:argCheck(hookSecure, 5, "boolean", "nil")
		if not object[method] then
			AceHook:error("Attempt to hook method %q failed, it does not exist in the given object %q.", method, object)
		end
		if not hookSecure and issecurevariable(object, method) then
			AceHook:error("Attempt to hook secure method %q. Use `SecureHook' or add `true' to the argument list to override.", method)
		end
		hookMethod(self, object, method, handler, false, false)
	end
end

-- ("function", handler) or (object, "method", handler)
function AceHook:SecureHook(object, method, handler)
	if type(object) == "string" then
		method, handler = object, method
		AceHook:argCheck(handler, 3, "function", "string", "nil")
		hookFunction(self, method, handler, true)
	else
		AceHook:argCheck(object, 2, "table")
		AceHook:argCheck(method, 3, "string")
		AceHook:argCheck(handler, 4, "function", "string", "nil")
		if not object[method] then
			AceHook:error("Attempt to hook method %q failed, it does not exist in the given object %q.", method, object)
		end
		hookMethod(self, object, method, handler, false, true)
	end
end

function AceHook:HookScript(frame, script, handler)
	AceHook:argCheck(frame, 2, "table")
	if not frame[0] or type(frame.IsProtected) ~= "function" then
		AceHook:error("Bad argument #2 to `HookScript'. Expected frame.")
	end
	AceHook:argCheck(script, 3, "string")
	AceHook:argCheck(handler, 4, "function", "string", "nil")
	if frame:IsProtected() and protectedScripts[script] then
		AceHook:error("Cannot hook secure script %q.", script)
	end
	hookMethod(self, frame, script, handler, true, false)
end

function AceHook:SecureHookScript(frame, script, handler)
	AceHook:argCheck(frame, 2, "table")
	if not frame[0] or type(frame.IsProtected) ~= "function" then
		AceHook:error("Bad argument #2 to `HookScript'. Expected frame.")
	end
	AceHook:argCheck(script, 3, "string")
	AceHook:argCheck(handler, 4, "function", "string", "nil")
	hookMethod(self, frame, script, handler, true, true)
end

-- ("function") or (object, "method")
function AceHook:IsHooked(obj, method)
	if type(obj) == "string" then
		if registry[self][obj] and actives[registry[self][obj]] then
			return true, handlers[registry[self][obj]]
		end
	else
		AceHook:argCheck(obj, 2, "string", "table")
		AceHook:argCheck(method, 3, "string")
		if registry[self][obj] and registry[self][obj][method] and actives[registry[self][obj][method]] then
			return true, handlers[registry[self][obj][method]]
		end
	end
	
	return false, nil
end

-- ("function") or (object, "method")
function AceHook:Unhook(obj, method)
	if type(obj) == "string" then
		unhookFunction(self, obj)
	else
		AceHook:argCheck(obj, 2, "string", "table")
		AceHook:argCheck(method, 3, "string")
		unhookMethod(self, obj, method)
	end
end

function AceHook:UnhookAll()
	if type(registry[self]) ~= "table" then return end
	for key, value in pairs(registry[self]) do
		if type(key) == "table" then
			for method in pairs(value) do
				self:Unhook(key, method)
			end
		else
			self:Unhook(key)
		end
	end
end

function AceHook:HookReport()
	DEFAULT_CHAT_FRAME:AddMessage("This is a list of all active hooks for this object:")
	if not next(registry[self]) then
		DEFAULT_CHAT_FRAME:AddMessage("No hooks")
	end
	
	for key, value in pairs(registry[self]) do
		if type(value) == "table" then
			for method, uid in pairs(value) do
				DEFAULT_CHAT_FRAME:AddMessage(("object: %s method: %q |cff%s|r%s"):format(tostring(key), method, actives[uid] and "00ff00Active" or "ffff00Inactive", not self.hooks[key][method] and " |cff7f7fff-Secure-|r" or ""))
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(("function: %q |cff%s|r%s"):format(tostring(key), actives[value] and "00ff00Active" or "ffff00Inactive", not self.hooks[key] and " |cff7f7fff-Secure-|r" or ""))
		end
	end
end

function AceHook:OnInstanceInit(object)
	if not object.hooks then
		object.hooks = new()
	end
	if not registry[object] then
		registry[object] = new()
	end
end

AceHook.OnManualEmbed = AceHook.OnInstanceInit

function AceHook:OnEmbedDisable(target)
	self.UnhookAll(target)
end

local function activate(self, oldLib, oldDeactivate)
	AceHook = self
	
	self.handlers = oldLib and oldLib.handlers or {}
	self.registry = oldLib and oldLib.registry or {}
	self.scripts = oldLib and oldLib.scripts or {}
	self.actives = oldLib and oldLib.actives or {}
	self.onceSecure = oldLib and oldLib.onceSecure or {}
	
	handlers = self.handlers
	registry = self.registry
	scripts = self.scripts
	actives = self.actives
	onceSecure = self.onceSecure
	
	self:activate(oldLib, oldDeactivate)
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceHook, MAJOR_VERSION, MINOR_VERSION, activate)
