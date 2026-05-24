---@meta _
C_FriendList = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.AddFriend)
---@param name string
---@param notes? string
function C_FriendList.AddFriend(name, notes) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.AddIgnore)
---@param name string
---@return boolean added
function C_FriendList.AddIgnore(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.AddOrDelIgnore)
---@param name string
function C_FriendList.AddOrDelIgnore(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.AddOrRemoveFriend)
---@param name string
---@param notes string
function C_FriendList.AddOrRemoveFriend(name, notes) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.DelIgnore)
---@param name string
---@return boolean removed
function C_FriendList.DelIgnore(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.DelIgnoreByIndex)
---@param index number
function C_FriendList.DelIgnoreByIndex(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetFriendInfo)
---@param name string
---@return FriendInfo info
function C_FriendList.GetFriendInfo(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetFriendInfoByIndex)
---@param index number
---@return FriendInfo info
function C_FriendList.GetFriendInfoByIndex(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetIgnoreName)
---@param index number
---@return string? name
function C_FriendList.GetIgnoreName(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetNumFriends)
---@return number numFriends
function C_FriendList.GetNumFriends() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetNumIgnores)
---@return number numIgnores
function C_FriendList.GetNumIgnores() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetNumOnlineFriends)
---@return number numOnline
function C_FriendList.GetNumOnlineFriends() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetNumWhoResults)
---@return number numWhos
---@return number totalNumWhos
function C_FriendList.GetNumWhoResults() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetSelectedFriend)
---@return number? index
function C_FriendList.GetSelectedFriend() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetSelectedIgnore)
---@return number? index
function C_FriendList.GetSelectedIgnore() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.GetWhoInfo)
---@param index number
---@return WhoInfo info
function C_FriendList.GetWhoInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.IsFriend)
---@param guid WOWGUID
---@return boolean isFriend
function C_FriendList.IsFriend(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.IsIgnored)
---@param token string
---@return boolean isIgnored
function C_FriendList.IsIgnored(token) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.IsIgnoredByGuid)
---@param guid WOWGUID
---@return boolean isIgnored
function C_FriendList.IsIgnoredByGuid(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.IsOnIgnoredList)
---@param token string
---@return boolean isIgnored
function C_FriendList.IsOnIgnoredList(token) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.RemoveFriend)
---@param name string
---@return boolean removed
function C_FriendList.RemoveFriend(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.RemoveFriendByIndex)
---@param index number
function C_FriendList.RemoveFriendByIndex(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.SendWho)
---@param filter string
---@param origin? number
function C_FriendList.SendWho(filter, origin) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.SetFriendNotes)
---@param name string
---@param notes string
---@return boolean found
function C_FriendList.SetFriendNotes(name, notes) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.SetFriendNotesByIndex)
---@param index number
---@param notes string
function C_FriendList.SetFriendNotesByIndex(index, notes) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.SetSelectedFriend)
---@param index number
function C_FriendList.SetSelectedFriend(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.SetSelectedIgnore)
---@param index number
function C_FriendList.SetSelectedIgnore(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.SetWhoToUi)
---@param whoToUi boolean
function C_FriendList.SetWhoToUi(whoToUi) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.ShowFriends)
function C_FriendList.ShowFriends() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_FriendList.SortWho)
---@param sorting string
function C_FriendList.SortWho(sorting) end

---@class FriendInfo
---@field connected boolean
---@field name string
---@field className string?
---@field area string?
---@field notes string?
---@field guid WOWGUID
---@field level number
---@field dnd boolean
---@field afk boolean
---@field rafLinkType Enum.RafLinkType

---@class WhoInfo
---@field fullName string
---@field fullGuildName string
---@field level number
---@field raceStr string
---@field classStr string
---@field area string
---@field filename string?
---@field gender number
---@field timerunningSeasonID number?
