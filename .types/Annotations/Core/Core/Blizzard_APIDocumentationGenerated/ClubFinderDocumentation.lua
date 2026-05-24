---@meta _
C_ClubFinder = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ApplicantAcceptClubInvite)
---@param clubFinderGUID WOWGUID
function C_ClubFinder.ApplicantAcceptClubInvite(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ApplicantDeclineClubInvite)
---@param clubFinderGUID WOWGUID
function C_ClubFinder.ApplicantDeclineClubInvite(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.CancelMembershipRequest)
---@param clubFinderGUID WOWGUID
function C_ClubFinder.CancelMembershipRequest(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.CheckAllPlayerApplicantSettings)
function C_ClubFinder.CheckAllPlayerApplicantSettings() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ClearAllFinderCache)
function C_ClubFinder.ClearAllFinderCache() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ClearClubApplicantsCache)
function C_ClubFinder.ClearClubApplicantsCache() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ClearClubFinderPostingsCache)
function C_ClubFinder.ClearClubFinderPostingsCache() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.DoesPlayerBelongToClubFromClubGUID)
---@param clubFinderGUID WOWGUID
---@return boolean belongsToClub
function C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetClubFinderDisableReason)
---@return Enum.ClubFinderDisableReason? disableReason
function C_ClubFinder.GetClubFinderDisableReason() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetClubRecruitmentSettings)
---@return ClubSettingsInfo settings
function C_ClubFinder.GetClubRecruitmentSettings() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetClubTypeFromFinderGUID)
---@param clubFinderGUID WOWGUID
---@return Enum.ClubFinderRequestType clubType
function C_ClubFinder.GetClubTypeFromFinderGUID(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetFocusIndexFromFlag)
---@param flags number
---@return number index
function C_ClubFinder.GetFocusIndexFromFlag(flags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetPlayerApplicantLocaleFlags)
---@return number localeFlags
function C_ClubFinder.GetPlayerApplicantLocaleFlags() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetPlayerApplicantSettings)
---@return ClubSettingsInfo settings
function C_ClubFinder.GetPlayerApplicantSettings() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetPlayerClubApplicationStatus)
---@param clubFinderGUID WOWGUID
---@return Enum.PlayerClubRequestStatus clubStatus
function C_ClubFinder.GetPlayerClubApplicationStatus(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetPlayerSettingsFocusFlagsSelectedCount)
---@return number focusCount
function C_ClubFinder.GetPlayerSettingsFocusFlagsSelectedCount() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetPostingIDFromClubFinderGUID)
---@param clubFinderGUID WOWGUID
---@return number? postingID
function C_ClubFinder.GetPostingIDFromClubFinderGUID(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetRecruitingClubInfoFromClubID)
---@param clubId ClubId
---@return RecruitingClubInfo? clubInfo
function C_ClubFinder.GetRecruitingClubInfoFromClubID(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetRecruitingClubInfoFromFinderGUID)
---@param clubFinderGUID WOWGUID
---@return RecruitingClubInfo clubInfo
function C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetStatusOfPostingFromClubId)
---@param postingID ClubId
---@return Enum.ClubFinderClubPostingStatusFlags[] postingFlags
function C_ClubFinder.GetStatusOfPostingFromClubId(postingID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetTotalMatchingCommunityListSize)
---@return number totalSize
function C_ClubFinder.GetTotalMatchingCommunityListSize() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.GetTotalMatchingGuildListSize)
---@return number totalSize
function C_ClubFinder.GetTotalMatchingGuildListSize() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.HasAlreadyAppliedToLinkedPosting)
---@param clubFinderGUID WOWGUID
---@return boolean hasAlreadyApplied
function C_ClubFinder.HasAlreadyAppliedToLinkedPosting(clubFinderGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.HasPostingBeenDelisted)
---@param postingID ClubId
---@return boolean postingDelisted
function C_ClubFinder.HasPostingBeenDelisted(postingID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.IsCommunityFinderEnabled)
---@return boolean isEnabled
function C_ClubFinder.IsCommunityFinderEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.IsEnabled)
---@return boolean isEnabled
function C_ClubFinder.IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.IsListingEnabledFromFlags)
---@param flags number
---@return boolean isListed
function C_ClubFinder.IsListingEnabledFromFlags(flags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.IsPostingBanned)
---@param postingID ClubId
---@return boolean postingBanned
function C_ClubFinder.IsPostingBanned(postingID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.IsValidSearchString)
---@param name string
---@return boolean isApproved
function C_ClubFinder.IsValidSearchString(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.LookupClubPostingFromClubFinderGUID)
---@param clubFinderGUID WOWGUID
---@param isLinkedPosting boolean
function C_ClubFinder.LookupClubPostingFromClubFinderGUID(clubFinderGUID, isLinkedPosting) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.PlayerGetClubInvitationList)
---@return RecruitingClubInfo[] inviteList
function C_ClubFinder.PlayerGetClubInvitationList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.PlayerRequestPendingClubsList)
---@param type Enum.ClubFinderRequestType
function C_ClubFinder.PlayerRequestPendingClubsList(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.PlayerReturnPendingCommunitiesList)
---@return RecruitingClubInfo[] info
function C_ClubFinder.PlayerReturnPendingCommunitiesList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.PlayerReturnPendingGuildsList)
---@return RecruitingClubInfo[] info
function C_ClubFinder.PlayerReturnPendingGuildsList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.PostClub)
---@param clubId ClubId
---@param itemLevelRequirement number
---@param name string
---@param description string
---@param avatarId number
---@param specs number[]
---@param type Enum.ClubFinderRequestType
---@param crossFaction? boolean Default = false
---@return boolean succesful
function C_ClubFinder.PostClub(clubId, itemLevelRequirement, name, description, avatarId, specs, type, crossFaction) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.RequestApplicantList)
---@param type Enum.ClubFinderRequestType
function C_ClubFinder.RequestApplicantList(type) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.RequestClubsList)
---@param guildListRequested boolean
---@param searchString string
---@param specIDs number[]
function C_ClubFinder.RequestClubsList(guildListRequested, searchString, specIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.RequestMembershipToClub)
---@param clubFinderGUID WOWGUID
---@param comment string
---@param specIDs number[]
function C_ClubFinder.RequestMembershipToClub(clubFinderGUID, comment, specIDs) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.RequestNextCommunityPage)
---@param startingIndex number
---@param pageSize number
function C_ClubFinder.RequestNextCommunityPage(startingIndex, pageSize) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.RequestNextGuildPage)
---@param startingIndex number
---@param pageSize number
function C_ClubFinder.RequestNextGuildPage(startingIndex, pageSize) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.RequestPostingInformationFromClubId)
---@param clubId ClubId
---@return boolean success
function C_ClubFinder.RequestPostingInformationFromClubId(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.RequestSubscribedClubPostingIDs)
function C_ClubFinder.RequestSubscribedClubPostingIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ResetClubPostingMapCache)
function C_ClubFinder.ResetClubPostingMapCache() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.RespondToApplicant)
---@param clubFinderGUID WOWGUID
---@param playerGUID WOWGUID
---@param shouldAccept boolean
---@param requestType Enum.ClubFinderRequestType
---@param playerName string
---@param forceAccept boolean
---@param reported? boolean
function C_ClubFinder.RespondToApplicant(clubFinderGUID, playerGUID, shouldAccept, requestType, playerName, forceAccept, reported) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ReturnClubApplicantList)
---@param clubId ClubId
---@return ClubFinderApplicantInfo[] info
function C_ClubFinder.ReturnClubApplicantList(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ReturnMatchingCommunityList)
---@return RecruitingClubInfo[] recruitingClubs
function C_ClubFinder.ReturnMatchingCommunityList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ReturnMatchingGuildList)
---@return RecruitingClubInfo[] recruitingClubs
function C_ClubFinder.ReturnMatchingGuildList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ReturnPendingClubApplicantList)
---@param clubId ClubId
---@return ClubFinderApplicantInfo[] info
function C_ClubFinder.ReturnPendingClubApplicantList(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.SendChatWhisper)
---@param clubFinderGUID WOWGUID
---@param playerGUID WOWGUID
---@param applicantType Enum.ClubFinderRequestType
---@param name string
function C_ClubFinder.SendChatWhisper(clubFinderGUID, playerGUID, applicantType, name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.SetAllRecruitmentSettings)
---@param value number
function C_ClubFinder.SetAllRecruitmentSettings(value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.SetPlayerApplicantLocaleFlags)
---@param localeFlags number
function C_ClubFinder.SetPlayerApplicantLocaleFlags(localeFlags) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.SetPlayerApplicantSettings)
---@param index number
---@param checked boolean
function C_ClubFinder.SetPlayerApplicantSettings(index, checked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.SetRecruitmentLocale)
---@param locale number
function C_ClubFinder.SetRecruitmentLocale(locale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.SetRecruitmentSettings)
---@param index number
---@param checked boolean
function C_ClubFinder.SetRecruitmentSettings(index, checked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClubFinder.ShouldShowClubFinder)
---@return boolean shouldShow
function C_ClubFinder.ShouldShowClubFinder() end

---@class ClubFinderApplicantInfo
---@field clubFinderGUID WOWGUID
---@field playerGUID WOWGUID
---@field closed number
---@field name string
---@field message string
---@field level number
---@field classID number
---@field ilvl number
---@field specIds number[]
---@field requestStatus Enum.PlayerClubRequestStatus
---@field lookupSuccess boolean
---@field lastUpdatedTime BigInteger
---@field faction number

---@class ClubSettingsInfo
---@field playStyleDungeon boolean
---@field playStyleRaids boolean
---@field playStylePvp boolean
---@field playStyleRP boolean
---@field playStyleSocial boolean
---@field roleTank boolean
---@field roleHealer boolean
---@field roleDps boolean
---@field sizeSmall boolean
---@field sizeMedium boolean
---@field sizeLarge boolean
---@field maxLevelOnly boolean
---@field enableListing boolean
---@field sortRelevance boolean
---@field sortMembers boolean
---@field sortNewest boolean
---@field autoAccept boolean
---@field crossFaction boolean

---@class RecruitingClubInfo
---@field clubFinderGUID WOWGUID
---@field numActiveMembers number
---@field name string
---@field comment string
---@field guildLeader string
---@field isGuild boolean
---@field emblemInfo number
---@field tabardInfo GuildTabardInfo?
---@field recruitingSpecIds number[]
---@field recruitmentFlags number
---@field localeSet boolean
---@field recruitmentLocale number
---@field minILvl number
---@field cached number
---@field cacheRequested number
---@field lastPosterGUID WOWGUID
---@field clubId ClubId
---@field lastUpdatedTime BigInteger
---@field isCrossFaction boolean
---@field realmName string?
