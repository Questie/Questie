---@meta _
C_GuildInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.AreGuildEventsEnabled)
---@return boolean enabled
function C_GuildInfo.AreGuildEventsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.CanEditOfficerNote)
---@return boolean canEditOfficerNote
function C_GuildInfo.CanEditOfficerNote() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.CanSpeakInGuildChat)
---@return boolean canSpeakInGuildChat
function C_GuildInfo.CanSpeakInGuildChat() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.CanViewOfficerNote)
---@return boolean canViewOfficerNote
function C_GuildInfo.CanViewOfficerNote() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.Demote)
---@param name string
function C_GuildInfo.Demote(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.Disband)
function C_GuildInfo.Disband() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.GetGuildNewsInfo)
---@param index number
---@return GuildNewsInfo newsInfo
function C_GuildInfo.GetGuildNewsInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.GetGuildRankOrder)
---@param guid WOWGUID
---@return number rankOrder
function C_GuildInfo.GetGuildRankOrder(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.GetGuildTabardInfo)
---@param unit? UnitToken
---@return GuildTabardInfo? tabardInfo
function C_GuildInfo.GetGuildTabardInfo(unit) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.GuildControlGetRankFlags)
---@param rankOrder number
---@return boolean[] permissions
function C_GuildInfo.GuildControlGetRankFlags(rankOrder) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.GuildRoster)
function C_GuildInfo.GuildRoster() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.Invite)
---@param name string
function C_GuildInfo.Invite(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.IsEncounterGuildNewsEnabled)
---@return boolean enabled
function C_GuildInfo.IsEncounterGuildNewsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.IsGuildOfficer)
---@return boolean isOfficer
function C_GuildInfo.IsGuildOfficer() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.IsGuildRankAssignmentAllowed)
---@param guid WOWGUID
---@param rankOrder number
---@return boolean isGuildRankAssignmentAllowed
function C_GuildInfo.IsGuildRankAssignmentAllowed(guid, rankOrder) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.IsGuildReputationEnabled)
---@return boolean enabled
function C_GuildInfo.IsGuildReputationEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.Leave)
function C_GuildInfo.Leave() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.MemberExistsByName)
---@param name string
---@return boolean exists
function C_GuildInfo.MemberExistsByName(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.Promote)
---@param name string
function C_GuildInfo.Promote(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.QueryGuildMemberRecipes)
---@param guildMemberGUID WOWGUID
---@param skillLineID number
function C_GuildInfo.QueryGuildMemberRecipes(guildMemberGUID, skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.QueryGuildMembersForRecipe)
---@param skillLineID number
---@param recipeSpellID number
---@param recipeLevel? number
---@return number updatedRecipeSpellID
function C_GuildInfo.QueryGuildMembersForRecipe(skillLineID, recipeSpellID, recipeLevel) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.RemoveFromGuild)
---@param guid WOWGUID
function C_GuildInfo.RemoveFromGuild(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.RequestGuildRename)
---@param desiredName string
function C_GuildInfo.RequestGuildRename(desiredName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.RequestGuildRenameRefund)
function C_GuildInfo.RequestGuildRenameRefund() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.RequestRenameNameCheck)
---@param desiredName string
function C_GuildInfo.RequestRenameNameCheck(desiredName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.RequestRenameStatus)
---@return boolean ableToRequest
function C_GuildInfo.RequestRenameStatus() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.SetGuildRankOrder)
---@param guid WOWGUID
---@param rankOrder number
function C_GuildInfo.SetGuildRankOrder(guid, rankOrder) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.SetLeader)
---@param name string
function C_GuildInfo.SetLeader(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.SetMOTD)
---@param motd string
function C_GuildInfo.SetMOTD(motd) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.SetNote)
---@param guid WOWGUID
---@param note string
---@param isPublic boolean
function C_GuildInfo.SetNote(guid, note, isPublic) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GuildInfo.Uninvite)
---@param name string
function C_GuildInfo.Uninvite(name) end

---@class GuildNewsInfo
---@field isSticky boolean
---@field isHeader boolean
---@field newsType number
---@field whoText string?
---@field whatText string?
---@field newsDataID number
---@field data number[]
---@field weekday number
---@field day number
---@field month number
---@field year number
---@field guildMembersPresent number

---@class GuildRenameStatus
---@field isNameChangeEnabled boolean
---@field isPlayerGuildMaster boolean
---@field refundEligibleEndTime time_t
---@field nextRenameTime time_t
---@field renamePrice WOWMONEY
---@field refundAmount WOWMONEY
---@field currentGuildMoney WOWMONEY
---@field result Enum.GuildErrorType
---@field oldGuildName string
---@field reservedName string
---@field reservedNameExpirationTime time_t
