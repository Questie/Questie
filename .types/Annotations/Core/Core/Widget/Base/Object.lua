---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Object)
---@class Object : FrameScriptObject
local Object = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_ClearParentKey)
function Object:ClearParentKey() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_GetDebugName)
---@param preferParentKey? boolean Default = false
---@return string debugName
function Object:GetDebugName(preferParentKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_GetParent)
---@return CScriptObject parent
function Object:GetParent() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_GetParentKey)
---@return string parentKey
function Object:GetParentKey() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Object_SetParentKey)
---@param parentKey string
function Object:SetParentKey(parentKey) end
