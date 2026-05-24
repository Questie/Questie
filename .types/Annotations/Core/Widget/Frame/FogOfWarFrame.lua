---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_FogOfWarFrame)
---@class FogOfWarFrame : Frame
local FogOfWarFrame = {}
---@class fogofwarframe : FogOfWarFrame
---@class FOGOFWARFRAME : FogOfWarFrame

---@param scriptType ScriptFogOfWarFrame
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return function handler
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_GetScript)
function FogOfWarFrame:GetScript(scriptType, bindingType) end

---@param scriptType ScriptFogOfWarFrame
---@return boolean hasScript
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HasScript)
function FogOfWarFrame:HasScript(scriptType) end

---@param scriptType ScriptFogOfWarFrame
---@param handler function
---@param bindingType? LE_SCRIPT_BINDING_TYPE
---@return boolean success
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_HookScript)
function FogOfWarFrame:HookScript(scriptType, handler, bindingType) end

---@param scriptType ScriptFogOfWarFrame
---@param handler function|nil
---[Documentation](https://warcraft.wiki.gg/wiki/API_ScriptObject_SetScript)
function FogOfWarFrame:SetScript(scriptType, handler) end


---@return textureAtlas atlas
function FogOfWarFrame:GetFogOfWarBackgroundAtlas() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_GetFogOfWarBackgroundTexture)
---@return FileAsset? asset
function FogOfWarFrame:GetFogOfWarBackgroundTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_GetFogOfWarMaskAtlas)
---@return textureAtlas atlas
function FogOfWarFrame:GetFogOfWarMaskAtlas() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_GetFogOfWarMaskTexture)
---@return FileAsset? asset
function FogOfWarFrame:GetFogOfWarMaskTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_GetMaskScalar)
---@return number scalar
function FogOfWarFrame:GetMaskScalar() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_GetUiMapID)
---@return number uiMapID
function FogOfWarFrame:GetUiMapID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetFogOfWarBackgroundAtlas)
---@param atlas textureAtlas
function FogOfWarFrame:SetFogOfWarBackgroundAtlas(atlas) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetFogOfWarBackgroundTexture)
---@param asset FileAsset
---@param horizontalTile boolean
---@param verticalTile boolean
function FogOfWarFrame:SetFogOfWarBackgroundTexture(asset, horizontalTile, verticalTile) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetFogOfWarMaskAtlas)
---@param atlas textureAtlas
function FogOfWarFrame:SetFogOfWarMaskAtlas(atlas) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetFogOfWarMaskTexture)
---@param asset FileAsset
function FogOfWarFrame:SetFogOfWarMaskTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetMaskScalar)
---@param scalar number
function FogOfWarFrame:SetMaskScalar(scalar) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FogOfWarFrame_SetUiMapID)
---@param uiMapID number
function FogOfWarFrame:SetUiMapID(uiMapID) end
