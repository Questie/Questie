---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_TextureCoordTranslation)
---@class TextureCoordTranslation : Animation
local TextureCoordTranslation = {}
---@class textureCoordTranslation : TextureCoordTranslation
---@class TEXTURECOORDTRANSLATION : TextureCoordTranslation

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureCoordTranslation_GetOffset)
---@return number offsetU
---@return number offsetV
function TextureCoordTranslation:GetOffset() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureCoordTranslation_SetOffset)
---@param offsetU number
---@param offsetV number
function TextureCoordTranslation:SetOffset(offsetU, offsetV) end
