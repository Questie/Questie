---@meta _
C_PlayerInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GUIDIsPlayer)
---@param guid WOWGUID
---@return boolean isPlayer
function C_PlayerInfo.GUIDIsPlayer(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetClass)
---@param playerLocation PlayerLocation
---@return string? className
---@return string? classFilename
---@return number? classID
function C_PlayerInfo.GetClass(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetName)
---@param playerLocation PlayerLocation
---@return string? name
function C_PlayerInfo.GetName(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetRace)
---@param playerLocation PlayerLocation
---@return number? raceID
function C_PlayerInfo.GetRace(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.GetSex)
---@param playerLocation PlayerLocation
---@return Enum.UnitSex? sex
function C_PlayerInfo.GetSex(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.IsConnected)
---@param playerLocation? PlayerLocation
---@return boolean? isConnected
function C_PlayerInfo.IsConnected(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PlayerInfo.UnitIsSameServer)
---@param playerLocation PlayerLocation
---@return boolean unitIsSameServer
function C_PlayerInfo.UnitIsSameServer(playerLocation) end
