---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_Texture)
---@class Texture : TextureBase
local Texture = {}
---@class texture : Texture
---@class TEXTURE : Texture

---[Documentation](https://warcraft.wiki.gg/wiki/API_Texture_AddMaskTexture)
---@param mask SimpleMaskTexture
function Texture:AddMaskTexture(mask) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Texture_GetMaskTexture)
---@param index number
---@return SimpleMaskTexture mask
function Texture:GetMaskTexture(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Texture_GetNumMaskTextures)
---@return size count
function Texture:GetNumMaskTextures() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Texture_RemoveMaskTexture)
---@param mask SimpleMaskTexture
function Texture:RemoveMaskTexture(mask) end

---@class MaskTexture : TextureBase
local MaskTexture = {}
---@class masktexture : MaskTexture
---@class MASKTEXTURE : MaskTexture