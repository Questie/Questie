---@meta _
C_CovenantPreview = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantPreview.CloseFromUI)
function C_CovenantPreview.CloseFromUI() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CovenantPreview.GetCovenantInfoForPlayerChoiceResponseID)
---@param playerChoiceResponseID number
---@return CovenantPreviewInfo previewInfo
function C_CovenantPreview.GetCovenantInfoForPlayerChoiceResponseID(playerChoiceResponseID) end

---@class CovenantAbilityInfo
---@field spellID number
---@field type Enum.CovenantAbilityType

---@class CovenantFeatureInfo
---@field name string
---@field description string
---@field texture number

---@class CovenantPreviewInfo
---@field textureKit textureKit
---@field transmogSetID number
---@field mountID number
---@field covenantName string
---@field covenantZone string
---@field description string
---@field covenantCrest textureAtlas
---@field covenantAbilities CovenantAbilityInfo[]
---@field fromPlayerChoice boolean
---@field covenantSoulbinds CovenantSoulbindInfo[]
---@field featureInfo CovenantFeatureInfo

---@class CovenantSoulbindInfo
---@field spellID number
---@field uiTextureKit textureKit
---@field name string
---@field description string
---@field sortOrder number
