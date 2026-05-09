---@meta _
C_VoiceChat = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.ActivateChannel)
---@param channelID number
function C_VoiceChat.ActivateChannel(channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.ActivateChannelTranscription)
---@param channelID number
function C_VoiceChat.ActivateChannelTranscription(channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.BeginLocalCapture)
---@param listenToLocalUser boolean
function C_VoiceChat.BeginLocalCapture(listenToLocalUser) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.CanAccessSettings)
---@return boolean canAccess
function C_VoiceChat.CanAccessSettings() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.CanPlayerUseVoiceChat)
---@return boolean canUseVoiceChat
function C_VoiceChat.CanPlayerUseVoiceChat() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.CreateChannel)
---@param channelDisplayName string
---@return Enum.VoiceChatStatusCode status
function C_VoiceChat.CreateChannel(channelDisplayName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.DeactivateChannel)
---@param channelID number
function C_VoiceChat.DeactivateChannel(channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.DeactivateChannelTranscription)
---@param channelID number
function C_VoiceChat.DeactivateChannelTranscription(channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.EndLocalCapture)
function C_VoiceChat.EndLocalCapture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetActiveChannelID)
---@return number? channelID
function C_VoiceChat.GetActiveChannelID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetActiveChannelType)
---@return Enum.ChatChannelType? channelType
function C_VoiceChat.GetActiveChannelType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetAvailableInputDevices)
---@return VoiceAudioDevice[]? inputDevices
function C_VoiceChat.GetAvailableInputDevices() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetAvailableOutputDevices)
---@return VoiceAudioDevice[]? outputDevices
function C_VoiceChat.GetAvailableOutputDevices() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetChannel)
---@param channelID number
---@return VoiceChatChannel? channel
function C_VoiceChat.GetChannel(channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetChannelForChannelType)
---@param channelType Enum.ChatChannelType
---@return VoiceChatChannel? channel
function C_VoiceChat.GetChannelForChannelType(channelType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetChannelForCommunityStream)
---@param clubId ClubId
---@param streamId ClubStreamId
---@return VoiceChatChannel? channel
function C_VoiceChat.GetChannelForCommunityStream(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetCommunicationMode)
---@return Enum.CommunicationMode? communicationMode
function C_VoiceChat.GetCommunicationMode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetCurrentVoiceChatConnectionStatusCode)
---@return Enum.VoiceChatStatusCode? statusCode
function C_VoiceChat.GetCurrentVoiceChatConnectionStatusCode() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetInputVolume)
---@return number? volume
function C_VoiceChat.GetInputVolume() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetJoinClubVoiceChannelError)
---@param clubId ClubId
---@return Enum.VoiceChannelErrorReason? errorReason
function C_VoiceChat.GetJoinClubVoiceChannelError(clubId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetLocalPlayerActiveChannelMemberInfo)
---@return VoiceChatMember? memberInfo
function C_VoiceChat.GetLocalPlayerActiveChannelMemberInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetLocalPlayerMemberID)
---@param channelID number
---@return number? memberID
function C_VoiceChat.GetLocalPlayerMemberID(channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetMasterVolumeScale)
---@return number scale
function C_VoiceChat.GetMasterVolumeScale() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetMemberGUID)
---@param memberID number
---@param channelID number
---@return WOWGUID memberGUID
function C_VoiceChat.GetMemberGUID(memberID, channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetMemberID)
---@param channelID number
---@param memberGUID WOWGUID
---@return number? memberID
function C_VoiceChat.GetMemberID(channelID, memberGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetMemberInfo)
---@param memberID number
---@param channelID number
---@return VoiceChatMember? memberInfo
function C_VoiceChat.GetMemberInfo(memberID, channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetMemberName)
---@param memberID number
---@param channelID number
---@return string? memberName
function C_VoiceChat.GetMemberName(memberID, channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetMemberVolume)
---@param playerLocation PlayerLocation
---@return number? volume
function C_VoiceChat.GetMemberVolume(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetOutputVolume)
---@return number? volume
function C_VoiceChat.GetOutputVolume() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetPTTButtonPressedState)
---@return boolean? isPressed
function C_VoiceChat.GetPTTButtonPressedState() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetProcesses)
---@return VoiceChatProcess[] processes
function C_VoiceChat.GetProcesses() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetPushToTalkBinding)
---@return string[]? keys
function C_VoiceChat.GetPushToTalkBinding() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetRemoteTtsVoices)
---@return VoiceTtsVoiceType[] ttsVoices
function C_VoiceChat.GetRemoteTtsVoices() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetTtsVoices)
---@return VoiceTtsVoiceType[] ttsVoices
function C_VoiceChat.GetTtsVoices() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.GetVADSensitivity)
---@return number? sensitivity
function C_VoiceChat.GetVADSensitivity() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsChannelJoinPending)
---@param channelType Enum.ChatChannelType
---@param clubId? ClubId
---@param streamId? ClubStreamId
---@return boolean isPending
function C_VoiceChat.IsChannelJoinPending(channelType, clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsDeafened)
---@return boolean? isDeafened
function C_VoiceChat.IsDeafened() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsEnabled)
---@return boolean isEnabled
function C_VoiceChat.IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsLoggedIn)
---@return boolean isLoggedIn
function C_VoiceChat.IsLoggedIn() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsMemberLocalPlayer)
---@param memberID number
---@param channelID number
---@return boolean isLocalPlayer
function C_VoiceChat.IsMemberLocalPlayer(memberID, channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsMemberMuted)
---@param playerLocation PlayerLocation
---@return boolean? mutedForMe
function C_VoiceChat.IsMemberMuted(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsMemberMutedForAll)
---@param memberID number
---@param channelID number
---@return boolean? mutedForAll
function C_VoiceChat.IsMemberMutedForAll(memberID, channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsMemberSilenced)
---@param memberID number
---@param channelID number
---@return boolean? silenced
function C_VoiceChat.IsMemberSilenced(memberID, channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsMuted)
---@return boolean? isMuted
function C_VoiceChat.IsMuted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsParentalDisabled)
---@return boolean isParentalDisabled
function C_VoiceChat.IsParentalDisabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsParentalMuted)
---@return boolean isParentalMuted
function C_VoiceChat.IsParentalMuted() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsPlayerUsingVoice)
---@param playerLocation PlayerLocation
---@return boolean isUsingVoice
function C_VoiceChat.IsPlayerUsingVoice(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsSilenced)
---@return boolean? isSilenced
function C_VoiceChat.IsSilenced() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsSpeakForMeActive)
---@return boolean isActive
function C_VoiceChat.IsSpeakForMeActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsSpeakForMeAllowed)
---@return boolean isAllowed
function C_VoiceChat.IsSpeakForMeAllowed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsTranscribing)
---@return boolean isTranscribing
function C_VoiceChat.IsTranscribing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsTranscriptionAllowed)
---@return boolean isAllowed
function C_VoiceChat.IsTranscriptionAllowed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.IsVoiceChatConnected)
---@return boolean connected
function C_VoiceChat.IsVoiceChatConnected() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.LeaveChannel)
---@param channelID number
function C_VoiceChat.LeaveChannel(channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.Login)
---@return Enum.VoiceChatStatusCode status
function C_VoiceChat.Login() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.Logout)
---@return Enum.VoiceChatStatusCode status
function C_VoiceChat.Logout() end

---Once the UI has enumerated all channels, use this to reset the channel discovery state, it will be updated again if appropriate
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.MarkChannelsDiscovered)
function C_VoiceChat.MarkChannelsDiscovered() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.RequestJoinAndActivateCommunityStreamChannel)
---@param clubId ClubId
---@param streamId ClubStreamId
function C_VoiceChat.RequestJoinAndActivateCommunityStreamChannel(clubId, streamId) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.RequestJoinChannelByChannelType)
---@param channelType Enum.ChatChannelType
---@param autoActivate? boolean
function C_VoiceChat.RequestJoinChannelByChannelType(channelType, autoActivate) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetCommunicationMode)
---@param communicationMode Enum.CommunicationMode
function C_VoiceChat.SetCommunicationMode(communicationMode) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetDeafened)
---@param isDeafened boolean
function C_VoiceChat.SetDeafened(isDeafened) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetInputDevice)
---@param deviceID string
function C_VoiceChat.SetInputDevice(deviceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetInputVolume)
---@param volume number
function C_VoiceChat.SetInputVolume(volume) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetMasterVolumeScale)
---@param scale number
function C_VoiceChat.SetMasterVolumeScale(scale) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetMemberMuted)
---@param playerLocation PlayerLocation
---@param muted boolean
function C_VoiceChat.SetMemberMuted(playerLocation, muted) end

---Adjusts member volume across all channels
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetMemberVolume)
---@param playerLocation PlayerLocation
---@param volume number
function C_VoiceChat.SetMemberVolume(playerLocation, volume) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetMuted)
---@param isMuted boolean
function C_VoiceChat.SetMuted(isMuted) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetOutputDevice)
---@param deviceID string
function C_VoiceChat.SetOutputDevice(deviceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetOutputVolume)
---@param volume number
function C_VoiceChat.SetOutputVolume(volume) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetPortraitTexture)
---@param textureObject SimpleTexture
---@param memberID number
---@param channelID number
function C_VoiceChat.SetPortraitTexture(textureObject, memberID, channelID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetPushToTalkBinding)
---@param keys string[]
function C_VoiceChat.SetPushToTalkBinding(keys) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SetVADSensitivity)
---@param sensitivity number
function C_VoiceChat.SetVADSensitivity(sensitivity) end

---Use this while loading to determine if the UI should attempt to rediscover the previously joined/active voice channels
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.ShouldDiscoverChannels)
---@return boolean shouldDiscoverChannels
function C_VoiceChat.ShouldDiscoverChannels() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SpeakRemoteTextSample)
---@param text string
function C_VoiceChat.SpeakRemoteTextSample(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.SpeakText)
---@param voiceID number
---@param text string
---@param destination Enum.VoiceTtsDestination
---@param rate number
---@param volume number
function C_VoiceChat.SpeakText(voiceID, text, destination, rate, volume) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.StopSpeakingText)
function C_VoiceChat.StopSpeakingText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.ToggleDeafened)
function C_VoiceChat.ToggleDeafened() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.ToggleMemberMuted)
---@param playerLocation PlayerLocation
function C_VoiceChat.ToggleMemberMuted(playerLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_VoiceChat.ToggleMuted)
function C_VoiceChat.ToggleMuted() end

---@class VoiceAudioDevice
---@field deviceID string
---@field displayName string
---@field isActive boolean
---@field isSystemDefault boolean
---@field isCommsDefault boolean

---@class VoiceChatChannel
---@field name string
---@field channelID number
---@field channelType Enum.ChatChannelType
---@field clubId ClubId
---@field streamId ClubStreamId
---@field volume number
---@field isActive boolean
---@field isMuted boolean
---@field isTransmitting boolean
---@field isTranscribing boolean
---@field members VoiceChatMember[]

---@class VoiceChatMember
---@field energy number
---@field memberID number
---@field isActive boolean
---@field isSpeaking boolean
---@field isMutedForAll boolean
---@field isSilenced boolean

---@class VoiceChatProcess
---@field name string
---@field channels VoiceChatChannel[]

---@class VoiceTtsVoiceType
---@field voiceID number
---@field name string
