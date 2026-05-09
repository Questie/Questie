---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_POIFrame)
---@class Blob : Frame
local Blob = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_DrawAll)
function Blob:DrawAll() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_DrawBlob)
---@param questID number
---@param draw? boolean Default = false
function Blob:DrawBlob(questID, draw) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_DrawNone)
function Blob:DrawNone() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_EnableMerging)
---@param enable? boolean Default = false
function Blob:EnableMerging(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_EnableSmoothing)
---@param enable? boolean Default = false
function Blob:EnableSmoothing(enable) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_GetMapID)
---@return number uiMapID
function Blob:GetMapID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_SetBorderAlpha)
---@param alpha number
function Blob:SetBorderAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_SetBorderScalar)
---@param scalar number
function Blob:SetBorderScalar(scalar) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_SetBorderTexture)
---@param asset FileAsset
function Blob:SetBorderTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_SetFillAlpha)
---@param alpha number
function Blob:SetFillAlpha(alpha) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_SetFillTexture)
---@param asset FileAsset
function Blob:SetFillTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_SetMapID)
---@param uiMapID number
function Blob:SetMapID(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_SetMergeThreshold)
---@param threshold number
function Blob:SetMergeThreshold(threshold) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Blob_SetNumSplinePoints)
---@param numSplinePoints number
function Blob:SetNumSplinePoints(numSplinePoints) end
