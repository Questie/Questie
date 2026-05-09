---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_CancelLogout)
function CancelLogout() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ForceLogout)
function ForceLogout() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ForceQuit)
function ForceQuit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNativeRealmID)
---@return number nativeRealmID
function GetNativeRealmID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNetIpTypes)
---@return ConnectionIptype ... ipTypes
function GetNetIpTypes() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNetStats)
---@return number in
---@return number out
---@return number ... latencyList
function GetNetStats() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRealmID)
---@return number realmID
function GetRealmID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRealmName)
---@return string realmName
function GetRealmName() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsOnTournamentRealm)
---@return boolean result
function IsOnTournamentRealm() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Logout)
function Logout() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_Quit)
function Quit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SelectedRealmName)
---@return string selectedRealmName
function SelectedRealmName() end
