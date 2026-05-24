---@meta _
C_HousingNeighborhood = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.CanReturnAfterVisitingHouse)
---@return boolean canReturn
function C_HousingNeighborhood.CanReturnAfterVisitingHouse() end

---Only available when interacting with a bulletin board game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.CancelInviteToNeighborhood)
---@param playerName string
function C_HousingNeighborhood.CancelInviteToNeighborhood(playerName) end

---Only available when interacting with a bulletin board game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.DemoteToResident)
---@param playerGUID WOWGUID
function C_HousingNeighborhood.DemoteToResident(playerGUID) end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetCornerstoneHouseInfo)
---@return HouseInfo houseInfo
function C_HousingNeighborhood.GetCornerstoneHouseInfo() end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetCornerstoneNeighborhoodInfo)
---@return NeighborhoodInfo neighborhoodInfo
function C_HousingNeighborhood.GetCornerstoneNeighborhoodInfo() end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetCornerstonePurchaseMode)
---@return Enum.CornerstonePurchaseMode purchaseMode
function C_HousingNeighborhood.GetCornerstonePurchaseMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetCurrentNeighborhoodTextureSuffix)
---@return string neighborhoodTextureSuffix
function C_HousingNeighborhood.GetCurrentNeighborhoodTextureSuffix() end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetDiscountedMovePrice)
---@return number movePrice
function C_HousingNeighborhood.GetDiscountedMovePrice() end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetMoveCooldownTime)
---@return number movecooldownTime
function C_HousingNeighborhood.GetMoveCooldownTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetNeighborhoodMapData)
---@return NeighborhoodPlotMapInfo[] neighborhoodPlots
function C_HousingNeighborhood.GetNeighborhoodMapData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetNeighborhoodName)
---@return string neighborhoodName
function C_HousingNeighborhood.GetNeighborhoodName() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetNeighborhoodPlotName)
---@param plotIndex number
---@return string neighborhoodName
function C_HousingNeighborhood.GetNeighborhoodPlotName(plotIndex) end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.GetPreviousHouseIdentifier)
---@return string previousHouseIdentifier
function C_HousingNeighborhood.GetPreviousHouseIdentifier() end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.HasPermissionToPurchase)
---@return Enum.PurchaseHouseDisabledReason cantPurchaseReason
function C_HousingNeighborhood.HasPermissionToPurchase() end

---Only available when interacting with a bulletin board game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.InvitePlayerToNeighborhood)
---@param playerName string
function C_HousingNeighborhood.InvitePlayerToNeighborhood(playerName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.IsNeighborhoodManager)
---@return boolean isManager
function C_HousingNeighborhood.IsNeighborhoodManager() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.IsNeighborhoodOwner)
---@return boolean isOwner
function C_HousingNeighborhood.IsNeighborhoodOwner() end

---This returns true if the player is in a plot that is owned by another player
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.IsPlayerInOtherPlayersPlot)
---@return boolean isInUnownedPlot
function C_HousingNeighborhood.IsPlayerInOtherPlayersPlot() end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.IsPlotAvailableForPurchase)
---@return boolean isAvailable
function C_HousingNeighborhood.IsPlotAvailableForPurchase() end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.IsPlotOwnedByPlayer)
---@return boolean isPlayerOwned
function C_HousingNeighborhood.IsPlotOwnedByPlayer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.OnBulletinBoardClosed)
function C_HousingNeighborhood.OnBulletinBoardClosed() end

---Only available when interacting with a bulletin board game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.PromoteToManager)
---@param playerGUID WOWGUID
function C_HousingNeighborhood.PromoteToManager(playerGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.RequestNeighborhoodInfo)
function C_HousingNeighborhood.RequestNeighborhoodInfo() end

---Only available when interacting with a bulletin board game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.RequestNeighborhoodRoster)
function C_HousingNeighborhood.RequestNeighborhoodRoster() end

---Only available when interacting with a bulletin board game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.RequestPendingNeighborhoodInvites)
function C_HousingNeighborhood.RequestPendingNeighborhoodInvites() end

---Only available when interacting with a bulletin board game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.TransferNeighborhoodOwnership)
---@param playerGUID WOWGUID
function C_HousingNeighborhood.TransferNeighborhoodOwnership(playerGUID) end

---Only available when interacting with a bulletin board game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.TryEvictPlayer)
---@param plotID number
function C_HousingNeighborhood.TryEvictPlayer(plotID) end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.TryMoveHouse)
function C_HousingNeighborhood.TryMoveHouse() end

---Only available when interacting with a cornerstone game object
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingNeighborhood.TryPurchasePlot)
function C_HousingNeighborhood.TryPurchasePlot() end
