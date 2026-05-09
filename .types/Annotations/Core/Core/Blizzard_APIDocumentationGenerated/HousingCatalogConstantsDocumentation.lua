---@meta _
---@class HousingCatalogEntryID
---@field recordID number
---@field entryType Enum.HousingCatalogEntryType
---@field entrySubtype Enum.HousingCatalogEntrySubtype
---@field subtypeIdentifier number

---@class HousingCatalogFilterTagGroupInfo
---@field groupID number
---@field groupName string
---@field tags HousingCatalogFilterTagInfo[]

---@class HousingCatalogFilterTagInfo
---@field tagID number
---@field tagName string
---@field orderIndex number
---@field anyAssociatedEntries boolean
