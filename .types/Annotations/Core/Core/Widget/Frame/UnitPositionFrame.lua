---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_UnitPositionFrame)
---@class UnitPositionFrame : Frame
local UnitPositionFrame = {}
---@class unitpositionframe : UnitPositionFrame
---@class UNITPOSITIONFRAME : UnitPositionFrame

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_AddUnit)
---@param unitTokenString string
---@param asset TextureAssetDisk
---@param width? uiUnit
---@param height? uiUnit
---@param r? number
---@param g? number
---@param b? number
---@param a? number
---@param sublayer? number
---@param showFacing? boolean
function UnitPositionFrame:AddUnit(unitTokenString, asset, width, height, r, g, b, a, sublayer, showFacing) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_ClearUnits)
function UnitPositionFrame:ClearUnits() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_FinalizeUnits)
function UnitPositionFrame:FinalizeUnits() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_GetMouseOverUnits)
---@return string units
function UnitPositionFrame:GetMouseOverUnits() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_GetPlayerPingScale)
---@return number scale
function UnitPositionFrame:GetPlayerPingScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_GetUiMapID)
---@return number mapID
function UnitPositionFrame:GetUiMapID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_SetPlayerPingScale)
---@param scale number
function UnitPositionFrame:SetPlayerPingScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_SetPlayerPingTexture)
---@param textureType number|Enum.PingTextureType
---@param asset FileAsset
---@param width? uiUnit Default = 0
---@param height? uiUnit Default = 0
function UnitPositionFrame:SetPlayerPingTexture(textureType, asset, width, height) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_SetUiMapID)
---@param mapID number
function UnitPositionFrame:SetUiMapID(mapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_SetUnitColor)
---@param unit string
---@param colorR number
---@param colorG number
---@param colorB number
---@param colorA number
function UnitPositionFrame:SetUnitColor(unit, colorR, colorG, colorB, colorA) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_StartPlayerPing)
---@param duration? number Default = 0
---@param fadeDuration? number Default = 0
function UnitPositionFrame:StartPlayerPing(duration, fadeDuration) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitPositionFrame_StopPlayerPing)
function UnitPositionFrame:StopPlayerPing() end
