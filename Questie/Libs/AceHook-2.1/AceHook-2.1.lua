--[[
Name: AceHook-2.1
Revision: $Rev: 15814 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceHook-2.1
SVN: http://svn.wowace.com/root/trunk/Ace2/AceHook-2.1
Description: Mixin to allow for safe hooking of functions, methods, and scripts.
Dependencies: AceLibrary, AceOO-2.0
]]

local MAJOR_VERSION = "AceHook-2.1"
local MINOR_VERSION = "$Revision: 15814 $"

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
								"Unhook",
								"UnhookAll",
								"HookReport",
								"IsHooked",
							}

--[[---------------------------------------------------------------------------------
  Library Definitions
----------------------------------------------------------------------------------]]

local protFuncs = {
	CameraOrSelectOrMoveStart = true, 	CameraOrSelectOrMoveStop = true,
	TurnOrActionStart = true,			TurnOrActionStop = true,
	PitchUpStart = true,				PitchUpStop = true,
	PitchDownStart = true,				PitchDownStop = true,
	MoveBackwardStart = true,			MoveBackwardStop = true,
	MoveForwardStart = true,			MoveForwardStop = true,
	Jump = true,						StrafeLeftStart = true,
	StrafeLeftStop = true,				StrafeRightStart = true,
	StrafeRightStop = true,				ToggleMouseMove = true,
	ToggleRun = true,					TurnLeftStart = true,
	TurnLeftStop = true,				TurnRightStart = true,
	TurnRightStop = true,
}

local function issecurevariable(x)
	if protFuncs[x] then
		return 1
	else
		return nil
	end
end

local _G = getfenv(0)

local function hooksecurefunc(arg1, arg2, arg3)
	if type(arg1) == "string" then
		arg1, arg2, arg3 = _G, arg1, arg2
	end
	local orig = arg1[arg2]
	arg1[arg2] = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		local x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20 = orig(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		
		arg3(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		
		return x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20
	end
end

local protectedScripts = {
	OnClick = true,
}


local handlers, scripts, actives, registry

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
			uid = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if actives[uid] then
					return self[handler](self, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				else
					return orig(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if actives[uid] then
					return handler(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				else
					return orig(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				end
			end
			return uid
		end
	else
		-- secure hooks don't call the original method
		if type(handler) == "string" then
			-- The handler is a method, need to self it
			local uid
			uid = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if actives[uid] then
					return self[handler](self, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if actives[uid] then
					return handler(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				end
			end
			return uid
		end
	end
end

local function createMethodHook(self, object, method, handler, orig, secure, script)
	if script then
		if type(handler) == "string" then
			local uid
			uid = function()
				if actives[uid] then
					return self[handler](self, object)
				else
					return orig()
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function()
				if actives[uid] then
					return handler(object)
				else
					return orig()
				end
			end
			return uid
		end
	elseif not secure then
		if type(handler) == "string" then
			local uid
			uid = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if actives[uid] then
					return self[handler](self, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				else
					return orig(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if actives[uid] then
					return handler(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				else
					return orig(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				end
			end
			return uid
		end
	else
		-- secure hooks don't call the original method
		if type(handler) == "string" then
			local uid
			uid = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if actives[uid] then
					return self[handler](self, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if actives[uid] then
					return handler(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
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

	if registry[self][func] then
		local uid = registry[self][func]
		
		if actives[uid] then
			-- We have an active hook from this source.  Don't multi-hook
			AceHook:error("%q already has an active hook from this source.", func)
		end
		
		if handlers[uid] == handler then
			-- The hook is inactive, so reactivate it
			actives[uid] = true
			return
		else
			AceHook:error("There is a stale hook for %q can't hook or reactivate.", func)
		end
	end
	
	if type(handler) == "string" then
		if type(self[handler]) ~= "function" then
			AceHook:error("Could not find the the handler %q when hooking function %q", handler, func)
		end
	elseif type(handler) ~= "function" then
		AceHook:error("Could not find the handler you supplied when hooking %q", func)
	end
	
	local uid = createFunctionHook(self, func, handler, orig, secure)
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
			scripts[uid] = nil
			actives[uid] = nil
			-- Magically all-done
		else
			actives[uid] = nil
		end
	end
end

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
			AceHook:error("There is a stale hook for %q can't hook or reactivate.", method)
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
			orig = function() end
		end
	else
		orig = obj[method]
	end
	if not orig then
		AceHook:error("Could not find the method or script %q you are trying to hook.", method)
	end
	
	if not registry[self][obj] then
		registry[self][obj] = new()
	end
	
	if not self.hooks[obj] then
		self.hooks[obj] = new()
	end
	
	local uid = createMethodHook(self, obj, method, handler, orig, secure, script)
	registry[self][obj][method] = uid
	actives[uid] = true
	handlers[uid] = handler
	scripts[uid] = script and true or nil
	
	if script then
		obj:SetScript(method, uid)
		self.hooks[obj][method] = orig
	elseif not secure then
		obj[method] = uid
		self.hooks[obj][method] = orig
	else
		hooksecurefunc(obj, method, uid)
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
				obj:SetScript(method, self.hooks[obj][method])
				self.hooks[obj][method] = nil
				registry[self][obj][method] = nil
				handlers[uid] = nil
				scripts[uid] = nil
				actives[uid] = nil
			else
				actives[uid] = nil
			end
		else
			if self.hooks[obj][method] and obj[method] == uid then
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
	if not next(self.hooks[obj]) then
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
		if not hookSecure and issecurevariable(method) then
			AceHook:error("Attempt to hook secure function %q. Use `SecureHook' or add `true' to the argument list to override.", method)
		end
		AceHook:argCheck(handler, 3, "function", "string", "nil")
		AceHook:argCheck(hookSecure, 4, "boolean", "nil")
		hookFunction(self, method, handler, false)
	else
		if handler == true then
			handler, hookSecure = nil, true
		end
		if not hookSecure and issecurevariable(object, method) then
			AceHook:error("Attempt to hook secure method %q. Use `SecureHook' or add `true' to the argument list to override.", method)
		end
		AceHook:argCheck(object, 2, "table")
		AceHook:argCheck(method, 3, "string")
		AceHook:argCheck(handler, 4, "function", "string", "nil")
		AceHook:argCheck(hookSecure, 5, "boolean", "nil")
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
		hookMethod(self, object, method, handler, false, true)
	end
end

function AceHook:HookScript(frame, script, handler)
	AceHook:argCheck(frame, 2, "table")
	if not frame[0] or type(frame.IsFrameType) ~= "function" then
		AceHook:error("Bad argument #2 to `HookScript'. Expected frame.")
	end
	AceHook:argCheck(script, 3, "string")
	AceHook:argCheck(handler, 4, "function", "string", "nil")
	hookMethod(self, frame, script, handler, true, false)
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
				DEFAULT_CHAT_FRAME:AddMessage(string.format("object: %s method: %q |cff%s|r%s", tostring(key), method, actives[uid] and "00ff00Active" or "ffff00Inactive", not self.hooks[key][method] and " |cff7f7fff-Secure-|r" or ""))
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(string.format("function: %q |cff%s|r%s", tostring(key), actives[value] and "00ff00Active" or "ffff00Inactive", not self.hooks[key] and " |cff7f7fff-Secure-|r" or ""))
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
	
	handlers = self.handlers
	registry = self.registry
	scripts = self.scripts
	actives = self.actives
	
	AceHook.super.activate(self, oldLib, oldDeactivate)
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceHook, MAJOR_VERSION, MINOR_VERSION, activate)
