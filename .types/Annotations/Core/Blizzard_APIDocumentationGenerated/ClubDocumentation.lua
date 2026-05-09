---@meta _
C_Club = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.AcceptInvitation)
---@param clubId ClubId
function C_Club.AcceptInvitation(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.AddClubStreamChatChannel)
---@param clubId ClubId
---@param streamId ClubStreamId
function C_Club.AddClubStreamChatChannel(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.AdvanceStreamViewMarker)
---@param clubId ClubId
---@param streamId ClubStreamId
function C_Club.AdvanceStreamViewMarker(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.AreMembersReady)
---@param clubId ClubId
---@return boolean membersReady
function C_Club.AreMembersReady(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.AssignMemberRole)
---@param clubId ClubId
---@param memberId number
---@param roleId Enum.ClubRoleIdentifier
function C_Club.AssignMemberRole(clubId, memberId, roleId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.CanResolvePlayerLocationFromClubMessageData)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param epoch BigUInteger
---@param position BigUInteger
---@return boolean canResolve
function C_Club.CanResolvePlayerLocationFromClubMessageData(clubId, streamId, epoch, position) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.ClearAutoAdvanceStreamViewMarker)
function C_Club.ClearAutoAdvanceStreamViewMarker() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.ClearClubPresenceSubscription)
function C_Club.ClearClubPresenceSubscription() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.CompareBattleNetDisplayName)
---@param clubId ClubId
---@param lhsMemberId number
---@param rhsMemberId number
---@return number comparison
function C_Club.CompareBattleNetDisplayName(clubId, lhsMemberId, rhsMemberId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.CreateClub)
---@param name string
---@param shortName? string
---@param description string
---@param clubType Enum.ClubType
---@param avatarId number
---@param isCrossFaction? boolean
function C_Club.CreateClub(name, shortName, description, clubType, avatarId, isCrossFaction) end

---Check the canCreateStream privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.CreateStream)
---@param clubId ClubId
---@param name string
---@param subject string
---@param leadersAndModeratorsOnly boolean
function C_Club.CreateStream(clubId, name, subject, leadersAndModeratorsOnly) end

---Check canCreateTicket privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.CreateTicket)
---@param clubId ClubId
---@param allowedRedeemCount? number
---@param duration? number
---@param defaultStreamId? ClubStreamId
---@param isCrossFaction? boolean
function C_Club.CreateTicket(clubId, allowedRedeemCount, duration, defaultStreamId, isCrossFaction) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.DeclineInvitation)
---@param clubId ClubId
function C_Club.DeclineInvitation(clubId) end

---Check the canDestroy privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.DestroyClub)
---@param clubId ClubId
function C_Club.DestroyClub(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.DestroyMessage)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param messageId ClubMessageIdentifier
function C_Club.DestroyMessage(clubId, streamId, messageId) end

---Check canDestroyStream privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.DestroyStream)
---@param clubId ClubId
---@param streamId ClubStreamId
function C_Club.DestroyStream(clubId, streamId) end

---Check canDestroyTicket privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.DestroyTicket)
---@param clubId ClubId
---@param ticketId string
function C_Club.DestroyTicket(clubId, ticketId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.DoesAnyCommunityHaveUnreadMessages)
---@return boolean hasUnreadMessages
function C_Club.DoesAnyCommunityHaveUnreadMessages() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.DoesCommunityHaveMembersOfTheOppositeFaction)
---@param clubId ClubId
---@return boolean hasMembersOfOppositeFaction
function C_Club.DoesCommunityHaveMembersOfTheOppositeFaction(clubId) end

---nil arguments will not change existing club data
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.EditClub)
---@param clubId ClubId
---@param name? string
---@param shortName? string
---@param description? string
---@param avatarId? number
---@param broadcast? string
---@param crossFaction? boolean
function C_Club.EditClub(clubId, name, shortName, description, avatarId, broadcast, crossFaction) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.EditMessage)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param messageId ClubMessageIdentifier
---@param message string
function C_Club.EditMessage(clubId, streamId, messageId, message) end

---Check the canSetStreamName, canSetStreamSubject, canSetStreamAccess privileges. nil arguments will not change existing stream data.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.EditStream)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param name? string
---@param subject? string
---@param leadersAndModeratorsOnly? boolean
function C_Club.EditStream(clubId, streamId, name, subject, leadersAndModeratorsOnly) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.Flush)
function C_Club.Flush() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.FocusCommunityStreams)
function C_Club.FocusCommunityStreams() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.FocusMembers)
---@param clubId ClubId
function C_Club.FocusMembers(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.FocusStream)
---@param clubId ClubId
---@param streamId ClubStreamId
---@return boolean focused
function C_Club.FocusStream(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetAssignableRoles)
---@param clubId ClubId
---@param memberId number
---@return Enum.ClubRoleIdentifier[] assignableRoles
function C_Club.GetAssignableRoles(clubId, memberId) end

---listen for AVATAR_LIST_UPDATED event. This can happen if we haven't downloaded the battle.net avatar list yet
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetAvatarIdList)
---@param clubType Enum.ClubType
---@return number[]? avatarIds
function C_Club.GetAvatarIdList(clubType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetClubCapacity)
---@return number capacity
function C_Club.GetClubCapacity() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetClubInfo)
---@param clubId ClubId
---@return ClubInfo? info
function C_Club.GetClubInfo(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetClubLimits)
---@param clubType Enum.ClubType
---@return ClubLimits clubLimits
function C_Club.GetClubLimits(clubType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetClubMembers)
---@param clubId ClubId
---@param streamId? ClubStreamId
---@return number[] members
function C_Club.GetClubMembers(clubId, streamId) end

---The privileges for the logged in user for this club
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetClubPrivileges)
---@param clubId ClubId
---@return ClubPrivilegeInfo privilegeInfo
function C_Club.GetClubPrivileges(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetClubStreamNotificationSettings)
---@param clubId ClubId
---@return ClubStreamNotificationSetting[] settings
function C_Club.GetClubStreamNotificationSettings(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetCommunityNameResultText)
---@param result Enum.ValidateNameResult
---@return string? errorCode
function C_Club.GetCommunityNameResultText(result) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetGuildClubId)
---@return ClubId? guildClubId
function C_Club.GetGuildClubId() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetInfoFromLastCommunityChatLine)
---@return ClubMessageInfo messageInfo
---@return ClubId clubId
---@return ClubStreamId streamId
---@return Enum.ClubType clubType
function C_Club.GetInfoFromLastCommunityChatLine() end

---Returns a list of players that you can send a request to a Battle.net club. Returns an empty list for Character based clubs
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetInvitationCandidates)
---@param filter? string
---@param maxResults? number
---@param cursorPosition? number
---@param allowFullMatch? boolean
---@param clubId ClubId
---@return ClubInvitationCandidateInfo[] candidates
function C_Club.GetInvitationCandidates(filter, maxResults, cursorPosition, allowFullMatch, clubId) end

---Get info about a specific club the active player has been invited to.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetInvitationInfo)
---@param clubId ClubId
---@return ClubSelfInvitationInfo? invitation
function C_Club.GetInvitationInfo(clubId) end

---Get the pending invitations for this club. Call RequestInvitationsForClub() to retrieve invitations from server.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetInvitationsForClub)
---@param clubId ClubId
---@return ClubInvitationInfo[] invitations
function C_Club.GetInvitationsForClub(clubId) end

---These are the clubs the active player has been invited to.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetInvitationsForSelf)
---@return ClubSelfInvitationInfo[] invitations
function C_Club.GetInvitationsForSelf() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetLastTicketResponse)
---@param ticket string
---@return Enum.ClubErrorType error
---@return ClubInfo? info
---@return boolean showError
function C_Club.GetLastTicketResponse(ticket) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetMemberInfo)
---@param clubId ClubId
---@param memberId number
---@return ClubMemberInfo? info
function C_Club.GetMemberInfo(clubId, memberId) end

---Info for the logged in user for this club
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetMemberInfoForSelf)
---@param clubId ClubId
---@return ClubMemberInfo? info
function C_Club.GetMemberInfoForSelf(clubId) end

---Get info about a particular message.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetMessageInfo)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param messageId ClubMessageIdentifier
---@return ClubMessageInfo? message
function C_Club.GetMessageInfo(clubId, streamId, messageId) end

---Get the ranges of the messages currently downloaded.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetMessageRanges)
---@param clubId ClubId
---@param streamId ClubStreamId
---@return ClubMessageRange[] ranges
function C_Club.GetMessageRanges(clubId, streamId) end

---Get downloaded messages before (and including) the specified messageId limited by count. These are filtered by ignored players
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetMessagesBefore)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param newest ClubMessageIdentifier
---@param count number
---@return ClubMessageInfo[] messages
function C_Club.GetMessagesBefore(clubId, streamId, newest, count) end

---Get downloaded messages in the given range. These are filtered by ignored players
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetMessagesInRange)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param oldest ClubMessageIdentifier
---@param newest ClubMessageIdentifier
---@return ClubMessageInfo[] messages
function C_Club.GetMessagesInRange(clubId, streamId, oldest, newest) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetStreamInfo)
---@param clubId ClubId
---@param streamId ClubStreamId
---@return ClubStreamInfo? streamInfo
function C_Club.GetStreamInfo(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetStreamViewMarker)
---@param clubId ClubId
---@param streamId ClubStreamId
---@return BigUInteger? lastReadTime
function C_Club.GetStreamViewMarker(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetStreams)
---@param clubId ClubId
---@return ClubStreamInfo[] streams
function C_Club.GetStreams(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetSubscribedClubs)
---@return ClubInfo[] clubs
function C_Club.GetSubscribedClubs() end

---Get the existing tickets for this club. Call RequestTickets() to retrieve tickets from server.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.GetTickets)
---@param clubId ClubId
---@return ClubTicketInfo[] tickets
function C_Club.GetTickets(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.IsAccountMuted)
---@param clubId ClubId
---@return boolean accountMuted
function C_Club.IsAccountMuted(clubId) end

---Returns whether the given message is the first message in the stream, taking into account ignored messages
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.IsBeginningOfStream)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param messageId ClubMessageIdentifier
---@return boolean isBeginningOfStream
function C_Club.IsBeginningOfStream(clubId, streamId, messageId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.IsEnabled)
---@return boolean clubsEnabled
function C_Club.IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.IsRestricted)
---@return Enum.ClubRestrictionReason restrictionReason
function C_Club.IsRestricted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.IsSubscribedToStream)
---@param clubId ClubId
---@param streamId ClubStreamId
---@return boolean subscribed
function C_Club.IsSubscribedToStream(clubId, streamId) end

---Check kickableRoleIds privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.KickMember)
---@param clubId ClubId
---@param memberId number
function C_Club.KickMember(clubId, memberId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.LeaveClub)
---@param clubId ClubId
function C_Club.LeaveClub(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.RedeemTicket)
---@param ticketId string
function C_Club.RedeemTicket(ticketId) end

---Request invitations for this club from server. Check canGetInvitation privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.RequestInvitationsForClub)
---@param clubId ClubId
function C_Club.RequestInvitationsForClub(clubId) end

---Call this when the user scrolls near the top of the message view, and more need to be displayed. The history will be downloaded backwards (newest to oldest).
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.RequestMoreMessagesBefore)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param messageId? ClubMessageIdentifier
---@param count? number
---@return boolean alreadyHasMessages
function C_Club.RequestMoreMessagesBefore(clubId, streamId, messageId, count) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.RequestTicket)
---@param ticketId string
function C_Club.RequestTicket(ticketId) end

---Request tickets from server. Check canGetTicket privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.RequestTickets)
---@param clubId ClubId
function C_Club.RequestTickets(clubId) end

---Check canRevokeOwnInvitation or canRevokeOtherInvitation
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.RevokeInvitation)
---@param clubId ClubId
---@param memberId number
function C_Club.RevokeInvitation(clubId, memberId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SendBattleTagFriendRequest)
---@param guildClubId ClubId
---@param memberId number
function C_Club.SendBattleTagFriendRequest(guildClubId, memberId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SendCharacterInvitation)
---@param clubId ClubId
---@param character string
function C_Club.SendCharacterInvitation(clubId, character) end

---Check the canSendInvitation privilege.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SendInvitation)
---@param clubId ClubId
---@param memberId number
function C_Club.SendInvitation(clubId, memberId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SendMessage)
---@param clubId ClubId
---@param streamId ClubStreamId
---@param message string
function C_Club.SendMessage(clubId, streamId, message) end

---Only one stream can be set for auto-advance at a time. Focused streams will have their view times advanced automatically.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SetAutoAdvanceStreamViewMarker)
---@param clubId ClubId
---@param streamId ClubStreamId
function C_Club.SetAutoAdvanceStreamViewMarker(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SetAvatarTexture)
---@param texture SimpleTexture
---@param avatarId number
---@param clubType Enum.ClubType
function C_Club.SetAvatarTexture(texture, avatarId, clubType) end

---Check the canSetOwnMemberNote and canSetOtherMemberNote privileges.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SetClubMemberNote)
---@param clubId ClubId
---@param memberId number
---@param note string
function C_Club.SetClubMemberNote(clubId, memberId, note) end

---You can only be subscribed to 0 or 1 clubs for presence.  Subscribing to a new club automatically unsuscribes you to existing subscription.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SetClubPresenceSubscription)
---@param clubId ClubId
function C_Club.SetClubPresenceSubscription(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SetClubStreamNotificationSettings)
---@param clubId ClubId
---@param settings ClubStreamNotificationSetting[]
function C_Club.SetClubStreamNotificationSettings(clubId, settings) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SetCommunityID)
---@param communityID BigUInteger
function C_Club.SetCommunityID(communityID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SetFavorite)
---@param clubId ClubId
---@param isFavorite boolean
function C_Club.SetFavorite(clubId, isFavorite) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.SetSocialQueueingEnabled)
---@param clubId ClubId
---@param enabled boolean
function C_Club.SetSocialQueueingEnabled(clubId, enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.ShouldAllowClubType)
---@param clubType Enum.ClubType
---@return boolean clubTypeIsAllowed
function C_Club.ShouldAllowClubType(clubType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.UnfocusAllStreams)
---@param unsubscribe boolean
function C_Club.UnfocusAllStreams(unsubscribe) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.UnfocusMembers)
---@param clubId ClubId
function C_Club.UnfocusMembers(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.UnfocusStream)
---@param clubId ClubId
---@param streamId ClubStreamId
function C_Club.UnfocusStream(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Club.ValidateText)
---@param clubType Enum.ClubType
---@param text string
---@param clubFieldType Enum.ClubFieldType
---@return Enum.ValidateNameResult result
function C_Club.ValidateText(clubType, text, clubFieldType) end

---@class ClubInfo
---@field clubId ClubId
---@field name string
---@field shortName string?
---@field description string
---@field broadcast string
---@field clubType Enum.ClubType
---@field avatarId number
---@field memberCount number?
---@field favoriteTimeStamp BigUInteger?
---@field joinTime BigUInteger?
---@field socialQueueingEnabled boolean?
---@field crossFaction boolean?

---@class ClubInvitationCandidateInfo
---@field memberId number
---@field name string
---@field priority number
---@field status Enum.ClubInvitationCandidateStatus

---@class ClubInvitationInfo
---@field invitationId ClubInvitationId
---@field isMyInvitation boolean
---@field invitee ClubMemberInfo

---@class ClubLimits
---@field maximumNumberOfStreams number

---@class ClubMemberInfo
---@field isSelf boolean
---@field memberId number
---@field name string?
---@field role Enum.ClubRoleIdentifier?
---@field presence Enum.ClubMemberPresence
---@field clubType Enum.ClubType?
---@field guid WOWGUID?
---@field bnetAccountId number?
---@field memberNote string?
---@field officerNote string?
---@field classID number?
---@field race number?
---@field level number?
---@field zone string?
---@field achievementPoints number?
---@field profession1ID number?
---@field profession1Rank number?
---@field profession1Name string?
---@field profession2ID number?
---@field profession2Rank number?
---@field profession2Name string?
---@field lastOnlineYear number?
---@field lastOnlineMonth number?
---@field lastOnlineDay number?
---@field lastOnlineHour number?
---@field guildRank string?
---@field guildRankOrder number?
---@field isRemoteChat boolean?
---@field overallDungeonScore number?
---@field faction Enum.PvPFaction?
---@field timerunningSeasonID number?

---@class ClubMessageIdentifier
---@field epoch BigUInteger
---@field position BigUInteger

---@class ClubMessageInfo
---@field messageId ClubMessageIdentifier
---@field content kstringClubMessage
---@field author ClubMemberInfo
---@field destroyer ClubMemberInfo?
---@field destroyed boolean
---@field edited boolean

---@class ClubMessageRange
---@field oldestMessageId ClubMessageIdentifier
---@field newestMessageId ClubMessageIdentifier

---@class ClubPrivilegeInfo
---@field canDestroy boolean
---@field canSetAttribute boolean
---@field canSetName boolean
---@field canSetDescription boolean
---@field canSetAvatar boolean
---@field canSetBroadcast boolean
---@field canSetPrivacyLevel boolean
---@field canSetOwnMemberAttribute boolean
---@field canSetOtherMemberAttribute boolean
---@field canSetOwnMemberNote boolean
---@field canSetOtherMemberNote boolean
---@field canSetOwnVoiceState boolean
---@field canSetOwnPresenceLevel boolean
---@field canUseVoice boolean
---@field canVoiceMuteMemberForAll boolean
---@field canGetInvitation boolean
---@field canSendInvitation boolean
---@field canSendGuestInvitation boolean
---@field canRevokeOwnInvitation boolean
---@field canRevokeOtherInvitation boolean
---@field canGetBan boolean
---@field canGetSuggestion boolean
---@field canSuggestMember boolean
---@field canGetTicket boolean
---@field canCreateTicket boolean
---@field canDestroyTicket boolean
---@field canAddBan boolean
---@field canRemoveBan boolean
---@field canCreateStream boolean
---@field canDestroyStream boolean
---@field canSetStreamPosition boolean
---@field canSetStreamAttribute boolean
---@field canSetStreamName boolean
---@field canSetStreamSubject boolean
---@field canSetStreamAccess boolean
---@field canSetStreamVoiceLevel boolean
---@field canCreateMessage boolean
---@field canDestroyOwnMessage boolean
---@field canDestroyOtherMessage boolean
---@field canEditOwnMessage boolean
---@field canPinMessage boolean
---@field kickableRoleIds number[]

---@class ClubRoleInfo
---@field roleId number
---@field name string
---@field required boolean
---@field unique boolean

---@class ClubSelfInvitationInfo
---@field invitationId ClubInvitationId
---@field club ClubInfo
---@field inviter ClubMemberInfo
---@field leaders ClubMemberInfo[]

---@class ClubStreamInfo
---@field streamId ClubStreamId
---@field name string
---@field subject string
---@field leadersAndModeratorsOnly boolean
---@field streamType Enum.ClubStreamType
---@field creationTime BigUInteger

---@class ClubStreamNotificationSetting
---@field streamId ClubStreamId
---@field filter Enum.ClubStreamNotificationFilter

---@class ClubTicketInfo
---@field ticketId string
---@field allowedRedeemCount number
---@field currentRedeemCount number
---@field creationTime BigUInteger
---@field expirationTime BigUInteger
---@field defaultStreamId ClubStreamId?
---@field creator ClubMemberInfo
