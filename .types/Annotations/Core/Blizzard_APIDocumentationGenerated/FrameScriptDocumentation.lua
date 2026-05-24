---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_CreateFromMixins)
---@param ... LuaValueVariant mixins
---@return LuaValueVariant object
function CreateFromMixins(...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CreateWindow)
---@param popupStyle? boolean Default = true
---@param topMost? boolean Default = false
---@return SimpleWindow? window
function CreateWindow(popupStyle, topMost) end

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

---[Documentation](https://warcraft.wiki.gg/wiki/API_Mixin)
---@param object LuaValueVariant
---@param ... LuaValueVariant mixins
---@return LuaValueVariant outObject
function Mixin(object, ...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RunScript)
---@param text string
function RunScript(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetErrorCallstackHeight)
---@param height? number
function SetErrorCallstackHeight(height) end

---Starts a timer for profiling. The final time can be obtained by calling debugprofilestop.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_debugprofilestart)
function debugprofilestart() end

---Returns the time in milliseconds since the last debugprofilestart call.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_debugprofilestop)
---@return number elapsedMilliseconds
function debugprofilestop() end
