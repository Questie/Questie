---@meta _
C_HouseExterior = {}

---Cancels all in-progress editing of house exterior fixtures, which will deselect any active targets
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.CancelActiveExteriorEditing)
function C_HouseExterior.CancelActiveExteriorEditing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.GetCoreFixtureOptionsInfo)
---@param coreFixtureType Enum.HousingFixtureType
---@return HousingCoreFixtureInfo? coreFixtureOptionsInfo
function C_HouseExterior.GetCoreFixtureOptionsInfo(coreFixtureType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.GetCurrentHouseExteriorSize)
---@return Enum.HousingFixtureSize? houseExteriorSize
function C_HouseExterior.GetCurrentHouseExteriorSize() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.GetCurrentHouseExteriorType)
---@return number? houseExteriorTypeID
---@return string? houseExteriorTypeName
function C_HouseExterior.GetCurrentHouseExteriorType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.GetHouseExteriorSizeOptions)
---@return HouseExteriorSizeOptionsInfo? options
function C_HouseExterior.GetHouseExteriorSizeOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.GetHouseExteriorTypeOptions)
---@return HouseExteriorTypeOptionsInfo? options
function C_HouseExterior.GetHouseExteriorTypeOptions() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.GetSelectedFixturePointInfo)
---@return HousingFixturePointInfo? fixturePointInfo
function C_HouseExterior.GetSelectedFixturePointInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.HasHoveredFixture)
---@return boolean anyHoveredFixture
function C_HouseExterior.HasHoveredFixture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.HasSelectedFixturePoint)
---@return boolean anySelectedFixturePoint
function C_HouseExterior.HasSelectedFixturePoint() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.RemoveFixtureFromSelectedPoint)
function C_HouseExterior.RemoveFixtureFromSelectedPoint() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.SelectCoreFixtureOption)
---@param fixtureID number
function C_HouseExterior.SelectCoreFixtureOption(fixtureID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.SelectFixtureOption)
---@param fixtureID number
function C_HouseExterior.SelectFixtureOption(fixtureID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.SetHouseExteriorSize)
---@param size Enum.HousingFixtureSize
function C_HouseExterior.SetHouseExteriorSize(size) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HouseExterior.SetHouseExteriorType)
---@param houseExteriorTypeID number
function C_HouseExterior.SetHouseExteriorType(houseExteriorTypeID) end
