---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_TextureBase)
---@class TextureBase : Region
local TextureBase = {}

---Disable shader based nineslice texture rendering. Since SetAtlas will automatically load slice data for the atlas from the DB, can be useful if you want to disable nineslice after setting an atlas.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_ClearTextureSlice)
function TextureBase:ClearTextureSlice() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_ClearVertexOffsets)
function TextureBase:ClearVertexOffsets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetAtlas)
---@return textureAtlas atlas
function TextureBase:GetAtlas() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetBlendMode)
---@return BlendMode blendMode
function TextureBase:GetBlendMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetDesaturation)
---@return normalizedValue desaturation
function TextureBase:GetDesaturation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetHorizTile)
---@return boolean tiling
function TextureBase:GetHorizTile() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetRotation)
---@return number radians
---@return vector2 normalizedRotationPoint
function TextureBase:GetRotation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetTexCoord)
---@return number ULx
---@return number ULy
---@return number LLx
---@return number LLy
---@return number URx
---@return number URy
---@return number LRx
---@return number LRy 
function TextureBase:GetTexCoord() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetTexelSnappingBias)
---@return normalizedValue bias
function TextureBase:GetTexelSnappingBias() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetTexture)
---@return string? textureFile
function TextureBase:GetTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetTextureFileID)
---@return fileID textureFile
function TextureBase:GetTextureFileID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetTextureFilePath)
---@return string? textureFile
function TextureBase:GetTextureFilePath() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetTextureSliceMargins)
---@return number left
---@return number top
---@return number right
---@return number bottom
function TextureBase:GetTextureSliceMargins() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetTextureSliceMode)
---@return Enum.UITextureSliceMode sliceMode
function TextureBase:GetTextureSliceMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetVertTile)
---@return boolean tiling
function TextureBase:GetVertTile() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_GetVertexOffset)
---@param vertexIndex number
---@return uiUnit offsetX
---@return uiUnit offsetY
function TextureBase:GetVertexOffset(vertexIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_IsBlockingLoadRequested)
---@return boolean blocking
function TextureBase:IsBlockingLoadRequested() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_IsDesaturated)
---@return boolean desaturated
function TextureBase:IsDesaturated() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_IsSnappingToPixelGrid)
---@return boolean snap
function TextureBase:IsSnappingToPixelGrid() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetAtlas)
---@param atlas textureAtlas
---@param useAtlasSize? boolean Default = false
---@param filterMode? FilterMode
---@param resetTexCoords? boolean
function TextureBase:SetAtlas(atlas, useAtlasSize, filterMode, resetTexCoords) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetBlendMode)
---@param blendMode BlendMode
function TextureBase:SetBlendMode(blendMode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetBlockingLoadsRequested)
---@param blocking? boolean Default = false
function TextureBase:SetBlockingLoadsRequested(blocking) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetColorTexture)
---@param colorR number
---@param colorG number
---@param colorB number
---@param a? SingleColorValue
function TextureBase:SetColorTexture(colorR, colorG, colorB, a) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetDesaturated)
---@param desaturated? boolean Default = false
function TextureBase:SetDesaturated(desaturated) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetDesaturation)
---@param desaturation normalizedValue
function TextureBase:SetDesaturation(desaturation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetGradient)
---@param orientation Orientation
---@param minColor colorRGBA
---@param maxColor colorRGBA
function TextureBase:SetGradient(orientation, minColor, maxColor) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetHorizTile)
---@param tiling? boolean Default = false
function TextureBase:SetHorizTile(tiling) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetMask)
---@param file string
function TextureBase:SetMask(file) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetRotation)
---@param radians number
---@param normalizedRotationPoint? vector2
function TextureBase:SetRotation(radians, normalizedRotationPoint) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetSnapToPixelGrid)
---@param snap? boolean Default = false
function TextureBase:SetSnapToPixelGrid(snap) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetTexCoord)
---@param left number
---@param right number
---@param top number
---@param bottom number
---@overload fun(self, ULx:number, ULy:number, LLx:number, LLy:number, URx:number, URy:number, LRx:number, LRy:number)
function TextureBase:SetTexCoord(left, right, top, bottom) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetTexelSnappingBias)
---@param bias normalizedValue
function TextureBase:SetTexelSnappingBias(bias) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetTexture)
---@param textureAsset? string|number
---@param wrapModeHorizontal? WrapMode
---@param wrapModeVertical? WrapMode
---@param filterMode? FilterMode
---@return boolean success
function TextureBase:SetTexture(textureAsset, wrapModeHorizontal, wrapModeVertical, filterMode) end

---Enables nineslice texture rendering using the specified pixel margins. Preferred over legacy nineslice approach that uses 9 separate textures.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetTextureSliceMargins)
---@param left number
---@param top number
---@param right number
---@param bottom number
function TextureBase:SetTextureSliceMargins(left, top, right, bottom) end

---Controls whether the center and sides are Stretched or Tiled when using nineslice texture rendering. Defaults to Stretched.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetTextureSliceMode)
---@param sliceMode Enum.UITextureSliceMode
function TextureBase:SetTextureSliceMode(sliceMode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetVertTile)
---@param tiling? boolean Default = false
function TextureBase:SetVertTile(tiling) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TextureBase_SetVertexOffset)
---@param vertexIndex number
---@param offsetX uiUnit
---@param offsetY uiUnit
function TextureBase:SetVertexOffset(vertexIndex, offsetX, offsetY) end
