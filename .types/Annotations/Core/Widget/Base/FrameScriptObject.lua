---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_FrameScriptObject)
---@class FrameScriptObject
local FrameScriptObject = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_GetName)
---@return string name
function FrameScriptObject:GetName() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_GetObjectType)
---@return string objectType
function FrameScriptObject:GetObjectType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_HasAnySecretAspect)
---@return boolean hasSecretAspect
function FrameScriptObject:HasAnySecretAspect() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_HasSecretAspect)
---@param aspect Enum.SecretAspect
---@return boolean hasSecretAspect
function FrameScriptObject:HasSecretAspect(aspect) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_HasSecretValues)
---@return boolean hasSecretValues
function FrameScriptObject:HasSecretValues() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_IsForbidden)
---@return boolean isForbidden
function FrameScriptObject:IsForbidden() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_IsObjectType)
---@param objectType string
---@return boolean isType
function FrameScriptObject:IsObjectType(objectType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_IsPreventingSecretValues)
---@return boolean isPreventingSecretValues
function FrameScriptObject:IsPreventingSecretValues() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_SetForbidden)
function FrameScriptObject:SetForbidden() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_SetPreventSecretValues)
---@param preventSecretValues boolean
function FrameScriptObject:SetPreventSecretValues(preventSecretValues) end

---Reset all script accessible values to their default values.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_FrameScriptObject_SetToDefaults)
function FrameScriptObject:SetToDefaults() end
