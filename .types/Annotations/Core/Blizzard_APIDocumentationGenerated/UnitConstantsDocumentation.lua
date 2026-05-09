---@meta _
---@class AddPrivateAuraAnchorArgs
---@field unitToken string
---@field auraIndex number
---@field parent SimpleFrame
---@field showCountdownFrame boolean
---@field showCountdownNumbers boolean
---@field iconInfo PrivateAuraIconInfo?
---@field durationAnchor AnchorBinding?

---@class PrivateAuraIconInfo
---@field iconAnchor AnchorBinding
---@field iconWidth uiUnit
---@field iconHeight uiUnit

---@class UnitAuraUpdateInfo
---@field isFullUpdate boolean? Default = false
---@field removedAuraInstanceIDs number[]?
---@field addedAuras AuraData[]?
---@field updatedAuraInstanceIDs number[]?

---@class UnitPrivateAuraAnchorInfo
---@field anchorID number
---@field unitToken string
---@field auraIndex number
---@field showCountdownFrame boolean
---@field showCountdownNumbers boolean
---@field iconWidth uiUnit?
---@field iconHeight uiUnit?

---@class UnitPrivateAuraAppliedSoundInfo
---@field unitToken string
---@field spellID number
---@field soundFileName string?
---@field soundFileID number?
---@field outputChannel string?
