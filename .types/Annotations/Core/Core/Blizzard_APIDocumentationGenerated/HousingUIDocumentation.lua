---@meta _
C_Housing = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.AcceptNeighborhoodOwnership)
function C_Housing.AcceptNeighborhoodOwnership() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.CanEditCharter)
---@return boolean canEditCharter
function C_Housing.CanEditCharter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.CanTakeReportScreenshot)
---@param plotIndex number
---@return Enum.InvalidPlotScreenshotReason reason
function C_Housing.CanTakeReportScreenshot(plotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.CreateGuildNeighborhood)
---@param neighborhoodName string
function C_Housing.CreateGuildNeighborhood(neighborhoodName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.CreateNeighborhoodCharter)
---@param neighborhoodName string
function C_Housing.CreateNeighborhoodCharter(neighborhoodName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.DeclineNeighborhoodOwnership)
function C_Housing.DeclineNeighborhoodOwnership() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.DoesFactionMatchNeighborhood)
---@param neighborhoodGUID WOWGUID
---@return boolean factionMatches
function C_Housing.DoesFactionMatchNeighborhood(neighborhoodGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.EditNeighborhoodCharter)
---@param neighborhoodName string
function C_Housing.EditNeighborhoodCharter(neighborhoodName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetCurrentHouseInfo)
---@return HouseInfo? houseInfo
function C_Housing.GetCurrentHouseInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetCurrentHouseLevelFavor)
---@param houseGuid WOWGUID
function C_Housing.GetCurrentHouseLevelFavor(houseGuid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetCurrentHouseRefundAmount)
---@return number refundAmount
function C_Housing.GetCurrentHouseRefundAmount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetCurrentNeighborhoodGUID)
---@return WOWGUID? neighborhoodGUID
function C_Housing.GetCurrentNeighborhoodGUID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetHouseLevelFavorForLevel)
---@param level number
---@return number houseFavor
function C_Housing.GetHouseLevelFavorForLevel(level) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetHouseLevelRewardsForLevel)
---@param level number
function C_Housing.GetHouseLevelRewardsForLevel(level) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetHousingAccessFlags)
---@return Enum.HouseSettingFlags accessFlags
function C_Housing.GetHousingAccessFlags() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetMaxHouseLevel)
---@return number level
function C_Housing.GetMaxHouseLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetNeighborhoodTextureSuffix)
---@param neighborhoodGUID WOWGUID
---@return string neighborhoodTextureSuffix
function C_Housing.GetNeighborhoodTextureSuffix(neighborhoodGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetOthersOwnedHouses)
---@param playerGUID? WOWGUID
---@param bnetID? number
---@param isInPlayersGuild boolean
function C_Housing.GetOthersOwnedHouses(playerGUID, bnetID, isInPlayersGuild) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetPlayerOwnedHouses)
function C_Housing.GetPlayerOwnedHouses() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetTrackedHouseGuid)
---@return WOWGUID? trackedHouse
function C_Housing.GetTrackedHouseGuid() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetUIMapIDForNeighborhood)
---@param neighborhoodGuid WOWGUID
---@return number? uiMapID
function C_Housing.GetUIMapIDForNeighborhood(neighborhoodGuid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.GetVisitCooldownInfo)
---@return SpellCooldownInfo spellCooldownInfo
function C_Housing.GetVisitCooldownInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.HasHousingExpansionAccess)
---@return boolean hasAccess
function C_Housing.HasHousingExpansionAccess() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.HouseFinderDeclineNeighborhoodInvitation)
function C_Housing.HouseFinderDeclineNeighborhoodInvitation() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.HouseFinderRequestNeighborhoods)
function C_Housing.HouseFinderRequestNeighborhoods() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.HouseFinderRequestReservationAndPort)
---@param neighborhoodGuid WOWGUID
---@param plotID number
function C_Housing.HouseFinderRequestReservationAndPort(neighborhoodGuid, plotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsHousingMarketCartFullRemoveEnabled)
---@return boolean isHousingMarketCartFullRemoveEnabled
function C_Housing.IsHousingMarketCartFullRemoveEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsHousingMarketEnabled)
---@return boolean isHousingMarketEnabled
function C_Housing.IsHousingMarketEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsHousingMarketShopEnabled)
---@return boolean isHousingMarketShopEnabled
function C_Housing.IsHousingMarketShopEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsHousingServiceEnabled)
---@return boolean isAvailable
function C_Housing.IsHousingServiceEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsInsideHouse)
---@return boolean isInside
function C_Housing.IsInsideHouse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsInsideHouseOrPlot)
---@return boolean isInside
function C_Housing.IsInsideHouseOrPlot() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsInsideOwnHouse)
---@return boolean isInsideOwnHouse
function C_Housing.IsInsideOwnHouse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsInsidePlot)
---@return boolean isInside
function C_Housing.IsInsidePlot() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.IsOnNeighborhoodMap)
---@return boolean isOnNeighborhoodMap
function C_Housing.IsOnNeighborhoodMap() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.LeaveHouse)
function C_Housing.LeaveHouse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.OnCharterConfirmationAccepted)
function C_Housing.OnCharterConfirmationAccepted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.OnCharterConfirmationClosed)
function C_Housing.OnCharterConfirmationClosed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.OnCreateCharterNeighborhoodClosed)
function C_Housing.OnCreateCharterNeighborhoodClosed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.OnCreateGuildNeighborhoodClosed)
function C_Housing.OnCreateGuildNeighborhoodClosed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.OnHouseFinderClickPlot)
---@param plotID number
function C_Housing.OnHouseFinderClickPlot(plotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.OnRequestSignatureClicked)
function C_Housing.OnRequestSignatureClicked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.OnSignCharterClicked)
---@param charterOwnerGUID WOWGUID
function C_Housing.OnSignCharterClicked(charterOwnerGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.RelinquishHouse)
---@param houseGuid WOWGUID
function C_Housing.RelinquishHouse(houseGuid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.RequestCurrentHouseInfo)
function C_Housing.RequestCurrentHouseInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.RequestHouseFinderNeighborhoodData)
---@param neighborhoodGuid WOWGUID
---@param neighborhoodName string
function C_Housing.RequestHouseFinderNeighborhoodData(neighborhoodGuid, neighborhoodName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.RequestPlayerCharacterList)
function C_Housing.RequestPlayerCharacterList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.ReturnAfterVisitingHouse)
function C_Housing.ReturnAfterVisitingHouse() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.SaveHouseSettings)
---@param playerGUID WOWGUID
---@param accessFlags Enum.HouseSettingFlags
function C_Housing.SaveHouseSettings(playerGUID, accessFlags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.SearchBNetFriendNeighborhoods)
---@param bnetName string
---@return boolean isValidBnetFriend
function C_Housing.SearchBNetFriendNeighborhoods(bnetName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.SearchBNetFriendNeighborhoodsByID)
---@param bnetID number
---@return boolean isValidBnetFriend
function C_Housing.SearchBNetFriendNeighborhoodsByID(bnetID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.SetTrackedHouseGuid)
---@param trackedHouse? WOWGUID
function C_Housing.SetTrackedHouseGuid(trackedHouse) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.StartTutorial)
function C_Housing.StartTutorial() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.TeleportHome)
---@param neighborhoodGUID WOWGUID
---@param houseGUID WOWGUID
---@param plotID number
function C_Housing.TeleportHome(neighborhoodGUID, houseGUID, plotID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.TryRenameNeighborhood)
---@param neighborhoodName string
function C_Housing.TryRenameNeighborhood(neighborhoodName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.ValidateCreateGuildNeighborhoodSize)
function C_Housing.ValidateCreateGuildNeighborhoodSize() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.ValidateNeighborhoodName)
---@param neighborhoodName string
function C_Housing.ValidateNeighborhoodName(neighborhoodName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Housing.VisitHouse)
---@param neighborhoodGUID WOWGUID
---@param houseGUID WOWGUID
---@param plotID number
function C_Housing.VisitHouse(neighborhoodGUID, houseGUID, plotID) end
