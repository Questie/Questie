---@meta _
---@class HouseExteriorSizeOption
---@field size Enum.HousingFixtureSize
---@field name string
---@field isLocked boolean

---@class HouseExteriorSizeOptionsInfo
---@field selectedSize Enum.HousingFixtureSize
---@field options HouseExteriorSizeOption[]

---@class HouseExteriorTypeOption
---@field houseExteriorTypeID number
---@field name string
---@field isLocked boolean
---@field lockReasonString string

---@class HouseExteriorTypeOptionsInfo
---@field selectedExteriorType number
---@field options HouseExteriorTypeOption[]

---@class HousingCoreFixtureInfo
---@field selectedVariantFixtureID number
---@field selectedStyleFixtureID number
---@field currentStyleVariantOptions HousingFixtureOption[]
---@field styleOptions HousingFixtureOption[]

---@class HousingFixtureOption
---@field fixtureID number
---@field name string
---@field typeID number
---@field typeName string
---@field isLocked boolean
---@field lockReasonString string
---@field colorID number

---@class HousingFixturePointInfo
---@field ownerHash number
---@field selectedFixtureID number?
---@field fixtureOptions HousingFixtureOption[]
---@field canSelectionBeRemoved boolean
