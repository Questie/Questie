---@meta _
C_BattleNet = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_BattleNet.GetAccountInfoByGUID)
---@param guid WOWGUID
---@return BNetAccountInfo? accountInfo
function C_BattleNet.GetAccountInfoByGUID(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_BattleNet.GetAccountInfoByID)
---@param id number
---@param wowAccountGUID? WOWGUID
---@return BNetAccountInfo? accountInfo
function C_BattleNet.GetAccountInfoByID(id, wowAccountGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_BattleNet.GetFriendAccountInfo)
---@param friendIndex number
---@param wowAccountGUID? WOWGUID
---@return BNetAccountInfo? accountInfo
function C_BattleNet.GetFriendAccountInfo(friendIndex, wowAccountGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_BattleNet.GetFriendGameAccountInfo)
---@param friendIndex number
---@param accountIndex number
---@return BNetGameAccountInfo? gameAccountInfo
function C_BattleNet.GetFriendGameAccountInfo(friendIndex, accountIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_BattleNet.GetFriendNumGameAccounts)
---@param friendIndex number
---@return number numGameAccounts
function C_BattleNet.GetFriendNumGameAccounts(friendIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_BattleNet.GetGameAccountInfoByGUID)
---@param guid WOWGUID
---@return BNetGameAccountInfo? gameAccountInfo
function C_BattleNet.GetGameAccountInfoByGUID(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_BattleNet.GetGameAccountInfoByID)
---@param id number
---@return BNetGameAccountInfo? gameAccountInfo
function C_BattleNet.GetGameAccountInfoByID(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_BattleNet.InstallHighResTextures)
function C_BattleNet.InstallHighResTextures() end

---@class BNetAccountInfo
---@field bnetAccountID number
---@field accountName string
---@field battleTag string
---@field isFriend boolean
---@field isBattleTagFriend boolean
---@field lastOnlineTime number
---@field isAFK boolean
---@field isDND boolean
---@field isFavorite boolean
---@field appearOffline boolean
---@field customMessage string
---@field customMessageTime number
---@field note string
---@field rafLinkType Enum.RafLinkType
---@field gameAccountInfo BNetGameAccountInfo

---@class BNetGameAccountInfo
---@field gameAccountID number
---@field clientProgram string
---@field isOnline boolean
---@field isGameBusy boolean
---@field isGameAFK boolean
---@field wowProjectID number?
---@field characterName string?
---@field realmName string?
---@field realmDisplayName string?
---@field realmID number?
---@field factionName string?
---@field raceName string?
---@field className string?
---@field areaName string?
---@field characterLevel number?
---@field richPresence string?
---@field playerGuid WOWGUID?
---@field canSummon boolean
---@field hasFocus boolean
---@field regionID number
---@field isInCurrentRegion boolean
---@field timerunningSeasonID number?
