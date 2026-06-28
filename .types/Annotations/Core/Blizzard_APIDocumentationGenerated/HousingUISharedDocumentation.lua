---@meta _
---@class HouseInfo
---@field plotID number
---@field houseName string?
---@field ownerName string?
---@field plotCost number?
---@field neighborhoodName string?
---@field moveOutTime time_t?
---@field plotReserved boolean?
---@field neighborhoodGUID WOWGUID?
---@field houseGUID WOWGUID?

---@class HouseLevelFavor
---@field houseGUID WOWGUID?
---@field houseLevel number
---@field houseFavor number

---@class HouseLevelInfo
---@field level number
---@field interiorDecorPlacementBudget number
---@field exteriorDecorPlacementBudget number
---@field roomPlacementBudget number
---@field exteriorFixtureBudget number

---@class HouseLevelReward
---@field type Enum.HouseLevelRewardType
---@field asset ModelAsset?
---@field iconTexture FileAsset?
---@field iconAtlas textureAtlas?
---@field objectName string?
---@field tooltipText string?
---@field valueType Enum.HouseLevelRewardValueType?
---@field oldValue number?
---@field newValue number?

---@class HouseOwnerCharacterInfo
---@field characterName string
---@field classID number
---@field error Enum.HouseOwnerError
---@field playerGUID WOWGUID

---@class HouseholdMemberInfo
---@field characterName string
---@field classID number

---@class NeighborhoodInfo
---@field neighborhoodType Enum.NeighborhoodType
---@field neighborhoodOwnerType Enum.NeighborhoodOwnerType? Default = None
---@field neighborhoodName string
---@field neighborhoodGUID WOWGUID
---@field ownerGUID WOWGUID
---@field suggestionReason Enum.HouseFinderSuggestionReason?
---@field ownerName string?
---@field locationName string?

---@class NeighborhoodPlotMapInfo
---@field mapPosition vector2
---@field plotDataID number
---@field plotID number
---@field ownerType Enum.HousingPlotOwnerType? Default = None
---@field plotCost number?
---@field ownerName string?

---@class NeighborhoodRosterMemberInfo
---@field playerGUID WOWGUID
---@field residentName string
---@field residentType Enum.ResidentType
---@field isOnline boolean
---@field plotID number
---@field subdivision number?

---@class NeighborhoodRosterMemberUpdateInfo
---@field playerGUID WOWGUID
---@field residentType Enum.ResidentType
---@field isOnline boolean
