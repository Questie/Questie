---@meta _
C_RemixArtifactUI = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RemixArtifactUI.ClearRemixArtifactItem)
function C_RemixArtifactUI.ClearRemixArtifactItem() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RemixArtifactUI.GetAppearanceInfoByID)
---@param artifactAppearanceID number
---@return number uiCameraID
---@return number? altHandUICameraID
function C_RemixArtifactUI.GetAppearanceInfoByID(artifactAppearanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RemixArtifactUI.GetArtifactArtInfo)
---@return RemixArtifactArtInfo artifactArtInfo
function C_RemixArtifactUI.GetArtifactArtInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RemixArtifactUI.GetArtifactItemInfo)
---@return number itemID
---@return number? altItemID
---@return number artifactAppearanceID
---@return number appearanceModID
---@return number? itemAppearanceID
---@return number? altItemAppearanceID
---@return boolean altOnTop
function C_RemixArtifactUI.GetArtifactItemInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RemixArtifactUI.GetCurrArtifactItemID)
---@return number? reqitemID
function C_RemixArtifactUI.GetCurrArtifactItemID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RemixArtifactUI.GetCurrItemSpecIndex)
---@return number? specIndex
function C_RemixArtifactUI.GetCurrItemSpecIndex() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RemixArtifactUI.GetCurrTraitTreeID)
---@return number? traitTreeID
function C_RemixArtifactUI.GetCurrTraitTreeID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RemixArtifactUI.ItemInSlotIsRemixArtifact)
---@param invSlot number
---@return boolean isRemixArtifact
function C_RemixArtifactUI.ItemInSlotIsRemixArtifact(invSlot) end

---@class RemixArtifactAppearanceInfo
---@field uiCameraID number
---@field altHandUICameraID number?

---@class RemixArtifactArtInfo
---@field textureKit textureKit
---@field titleName string
---@field uiModelSceneID number
---@field spellVisualKitID number

---@class RemixArtifactInfo
---@field itemID number
---@field altItemID number?
---@field artifactAppearanceID number
---@field appearanceModID number
---@field itemAppearanceID number?
---@field altItemAppearanceID number?
---@field altOnTop boolean
