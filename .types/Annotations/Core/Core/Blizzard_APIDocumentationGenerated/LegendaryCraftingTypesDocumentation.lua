---@meta _
---@class CurrencyCost
---@field currencyID number
---@field amount number

---@class RuneforgeItemPreviewInfo
---@field itemGUID WOWGUID
---@field itemLevel number
---@field itemName string

---@class RuneforgeLegendaryComponentInfo
---@field powerID number
---@field modifiers number[]

---@class RuneforgeLegendaryCraftDescription
---@field baseItem ItemLocation
---@field runeforgePowerID number
---@field modifiers number[]

---@class RuneforgePower
---@field runeforgePowerID number
---@field state Enum.RuneforgePowerState
---@field name string
---@field descriptionSpellID number
---@field description string
---@field source string?
---@field iconFileID fileID
---@field specName string?
---@field matchesSpec boolean
---@field matchesCovenant boolean
---@field covenantID number?
---@field slots string[]
