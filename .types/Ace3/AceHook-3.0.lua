---@meta _

-- ----------------------------------------------------------------------------
-- AceHook-3.0
-- ----------------------------------------------------------------------------

---@class AceHook-3.0
---@field hooks { [table]: { [string]: function } } | { [string]: function }
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0)
local AceHook = {}

-- ----------------------------------------------------------------------------
-- AceHook-3.0 Methods
-- ----------------------------------------------------------------------------

-- Hook a function or a method on an object.
--
-- The hook created will be a "safe hook", that means that your handler will be called before the hooked function ("Pre-Hook"), and you don't have to call the original function yourself, however you cannot stop the execution of the function, or modify any of the arguments/return values.
--
-- This type of hook is typically used if you need to know if some function got called, and don't want to modify it.
---@param object table The object to hook a method from
---@param method string The name of the object method to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
---@param hookSecure? boolean If true, AceHook will allow hooking of secure functions.
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-1)
function AceHook:Hook(object, method, handler, hookSecure) end

-- Hook a function or a method on an object.
--
-- The hook created will be a "safe hook", that means that your handler will be called before the hooked function ("Pre-Hook"), and you don't have to call the original function yourself, however you cannot stop the execution of the function, or modify any of the arguments/return values.
--
-- This type of hook is typically used if you need to know if some function got called, and don't want to modify it.
---@param method string The name of the function to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
---@param hookSecure? boolean If true, AceHook will allow hooking of secure functions.
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-1)
function AceHook:Hook(method, handler, hookSecure) end

-- Hook a script handler on a frame.
--
-- The hook created will be a "safe hook", that means that your handler will be called before the hooked script ("Pre-Hook"), and you don't have to call the original function yourself, however you cannot stop the execution of the function, or modify any of the arguments/return values.
--
-- This is the frame script equivalent of the :Hook safe-hook. It would typically be used to be notified when a certain event happens to a frame.
---@param frame Frame The Frame to hook the script on
---@param script ScriptFrame The script to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked script)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-2)
function AceHook:HookScript(frame, script, handler) end

-- Check if the specific function, method or script is already hooked.
---@param obj table The object or frame to unhook from
---@param method string The name of the method, function or script to unhook from.
---@return boolean isHooked
---@return function|nil hookedFunction
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-3)
function AceHook:IsHooked(obj, method) end

-- Check if the specific function, method or script is already hooked.
---@param method string The name of the method, function or script to unhook from.
---@return boolean isHooked
---@return function|nil hookedFunction
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-3)
function AceHook:IsHooked(method) end

-- RawHook a function or a method on an object.
--
-- The hook created will be a "raw hook", that means that your handler will completly replace the original function, and your handler has to call the original function (or not, depending on your intentions).
--
-- The original function will be stored in `self.hooks[object][method]` or `self.hooks[functionName]` respectively.
--
-- This type of hook can be used for all purposes, and is usually the most common case when you need to modify arguments or want to control execution of the original function.
---@param object table The object to hook a method from
---@param method string The name of the object method to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
---@param hookSecure? boolean If true, AceHook will allow hooking of secure functions.
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-4)
function AceHook:RawHook(object, method, handler, hookSecure) end

-- RawHook a function or a method on an object.
--
-- The hook created will be a "raw hook", that means that your handler will completly replace the original function, and your handler has to call the original function (or not, depending on your intentions).
--
-- The original function will be stored in `self.hooks[object][method]` or `self.hooks[functionName]` respectively.
--
-- This type of hook can be used for all purposes, and is usually the most common case when you need to modify arguments or want to control execution of the original function.
---@param method string The name of the function to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
---@param hookSecure? boolean If true, AceHook will allow hooking of secure functions.
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-4)
function AceHook:RawHook(method, handler, hookSecure) end

-- RawHook a script handler on a frame.
--
-- The hook created will be a "raw hook", that means that your handler will completly replace the original script, and your handler has to call the original script (or not, depending on your intentions).
--
-- The original script will be stored in `self.hooks[frame][script]`.
--
-- This type of hook can be used for all purposes, and is usually the most common case when you need to modify arguments or want to control execution of the original script.
---@param frame Frame The Frame to hook the script on
---@param script ScriptFrame The script to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked script)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-5)
function AceHook:RawHookScript(frame, script, handler) end

-- SecureHook a function or a method on an object.
--
-- This function is a wrapper around the `hooksecurefunc` function in the WoW API. Using AceHook extends the functionality of secure hooks, and adds the ability to unhook once the hook isn't required anymore, or the addon is being disabled.
--
-- Secure Hooks should be used if the secure-status of the function is vital to its function, and taint would block execution. Secure Hooks are always called after the original function was called ("Post Hook"), and you cannot modify the arguments, return values or control the execution.
---@param object table The object to hook a method from
---@param method string The name of the object method to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-6)
function AceHook:SecureHook(object, method, handler) end

-- SecureHook a function or a method on an object.
--
-- This function is a wrapper around the `hooksecurefunc` function in the WoW API. Using AceHook extends the functionality of secure hooks, and adds the ability to unhook once the hook isn't required anymore, or the addon is being disabled.
--
-- Secure Hooks should be used if the secure-status of the function is vital to its function, and taint would block execution. Secure Hooks are always called after the original function was called ("Post Hook"), and you cannot modify the arguments, return values or control the execution.
---@param method string The name of the function to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-6)
function AceHook:SecureHook(method, handler) end

-- SecureHook a script handler on a frame.
--
-- This function is a wrapper around the `frame:HookScript` function in the WoW API. Using AceHook extends the functionality of secure hooks, and adds the ability to unhook once the hook isn't required anymore, or the addon is being disabled.
--
-- Secure Hooks should be used if the secure-status of the function is vital to its function, and taint would block execution. Secure Hooks are always called after the original function was called ("Post Hook"), and you cannot modify the arguments, return values or control the execution.
---@param frame Frame The Frame to hook the script on
---@param script ScriptFrame The script to hook
---@param handler? function|string The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked script)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-7)
function AceHook:SecureHookScript(frame, script, handler) end

-- Unhook from the specified function, method or script.
---@param obj table The object or frame to unhook from
---@param method string The name of the method, function or script to unhook from.
---@return boolean success Whether or not the operation was successful
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-8)
function AceHook:Unhook(obj, method) end

-- Unhook from the specified function, method or script.
---@param method string The name of the method, function or script to unhook from.
---@return boolean success Whether or not the operation was successful
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-8)
function AceHook:Unhook(method) end

-- Unhook all existing hooks for this addon.
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-hook-3-0#title-9)
function AceHook:UnhookAll() end
