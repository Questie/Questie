---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_AddSourceLocationExclude)
---@param fileName string
function AddSourceLocationExclude(fileName) end

---Returns true if the immediate calling function has appropriate permissions to access and operate on all supplied values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_canaccessallvalues)
---@param ... LuaValueReference values
---@return boolean canAccessAllValues
function canaccessallvalues(...) end

---Returns true if the immediate calling function has appropriate permissions to access or operate on secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_canaccesssecrets)
---@return boolean canAccessSecrets
function canaccesssecrets() end

---Returns true if the immediate calling function has appropriate permissions to index secret tables. This will return false if the caller cannot access the table value itself, or if access to the table contents is disallowed by taint.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_canaccesstable)
---@param table LuaValueReference
---@return boolean canAccessTable
function canaccesstable(table) end

---Returns true if the immediate calling function has appropriate permissions to access and operate on a specific value.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_canaccessvalue)
---@param value LuaValueReference
---@return boolean canAccessValue
function canaccessvalue(value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CreateFromMixins)
---@param ... LuaValueVariant mixins
---@return LuaValueVariant object
function CreateFromMixins(...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CreateSecureDelegate)
---@param luaFunction LuaValueReference
---@return LuaValueReference secureDelegateFunction
function CreateSecureDelegate(luaFunction) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CreateWindow)
---@param popupStyle? boolean Default = true
---@param topMost? boolean Default = false
---@return SimpleWindow? window
function CreateWindow(popupStyle, topMost) end

---Removes the ability for the immediate calling function to access secret values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_dropsecretaccess)
function dropsecretaccess() end

---Invokes the '__dump' metamethod on any value (if present), returning its result.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_dumpobject)
---@param value? LuaValueReference
---@return LuaValueReference? result
function dumpobject(value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCallstackHeight)
---@return number height
function GetCallstackHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetCurrentEventID)
---@return number? eventID
function GetCurrentEventID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetErrorCallstackHeight)
---@return number? height
function GetErrorCallstackHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetEventTime)
---@param eventProfileIndex number
---@return number totalElapsedTime
---@return number numExecutedHandlers
---@return string slowestHandlerName
---@return number slowestHandlerTime
function GetEventTime(eventProfileIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSourceLocation)
---@return string location
function GetSourceLocation() end

---Returns true if a supplied value is a secret value.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_hasanysecretvalues)
---@param ... LuaValueReference values
---@return boolean isAnyValueSecret
function hasanysecretvalues(...) end

---Returns true if a supplied value is a secret table. This function will return true if the table value itself is secret, or if flags on the table are set such that accesses of the table would produce secrets.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_issecrettable)
---@param table LuaValueReference
---@return boolean isSecretOrContentsSecret
function issecrettable(table) end

---Returns true if a supplied value is a secret value.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_issecretvalue)
---@param value LuaValueReference
---@return boolean isSecret
function issecretvalue(value) end

---Applies a given function over all supplied values individually, replacing the value with the result of the call.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_mapvalues)
---@param func LuaValueReference
---@param ... LuaValueReference values
---@return LuaValueReference ... mapped
function mapvalues(func, ...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Mixin)
---@param object LuaValueVariant
---@param ... LuaValueVariant mixins
---@return LuaValueVariant outObject
function Mixin(object, ...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RegisterEventCallback)
---@param eventName string
---@param callback EventCallbackType
function RegisterEventCallback(eventName, callback) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RegisterUnitEventCallback)
---@param eventName string
---@param callback EventCallbackType
---@param unit UnitToken
function RegisterUnitEventCallback(eventName, callback, unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RunScript)
---@param text string
function RunScript(text) end

---Returns a transformed list of values with inputs that are secret values replaced by nil values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_scrubsecretvalues)
---@param ... LuaValueReference values
---@return LuaValueReference ... scrubbed
function scrubsecretvalues(...) end

---Returns a transformed list of values with inputs that are either secret or are not string, number, or boolean type replaced by nil values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_scrub)
---@param ... LuaValueReference values
---@return LuaValueReference ... scrubbed
function scrub(...) end

---Unwraps all supplied secrets, converting them back to regular values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_secretunwrap)
---@param ... LuaValueReference values
---@return LuaValueReference ... unwrapped
function secretunwrap(...) end

---Converts all supplied values to secret values, preventing most operations on them from occurring on tainted code paths.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_secretwrap)
---@param ... LuaValueReference values
---@return LuaValueReference ... wrapped
function secretwrap(...) end

---Invokes a named method on an object with a secure call barrier that prevents errors or taint from function lookup and execution from propagating to the caller.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_securecallmethod)
---@param object LuaValueReference
---@param method string
---@param ... LuaValueReference arguments
---@return LuaValueReference ... results
function securecallmethod(object, method, ...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetErrorCallstackHeight)
---@param height? number
function SetErrorCallstackHeight(height) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetTableSecurityOption)
---@param table LuaValueVariant
---@param option Enum.TableSecurityOption
function SetTableSecurityOption(table, option) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnregisterEventCallback)
---@param eventName string
---@param callback EventCallbackType
function UnregisterEventCallback(eventName, callback) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnregisterUnitEventCallback)
---@param eventName string
---@param callback EventCallbackType
---@param unit UnitToken
function UnregisterUnitEventCallback(eventName, callback, unit) end

---Starts a timer for profiling. The final time can be obtained by calling debugprofilestop.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_debugprofilestart)
function debugprofilestart() end

---Returns the time in milliseconds since the last debugprofilestart call.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_debugprofilestop)
---@return number elapsedMilliseconds
function debugprofilestop() end

---@alias EventCallbackType FunctionContainer|fun()
