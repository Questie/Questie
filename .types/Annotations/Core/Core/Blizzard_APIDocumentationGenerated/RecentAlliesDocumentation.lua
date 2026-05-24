---@meta _
C_RecentAllies = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.CanSetRecentAllyNote)
---@param characterGUID WOWGUID
---@return boolean canSetNote
function C_RecentAllies.CanSetRecentAllyNote(characterGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.GetRecentAllies)
---@return RecentAllyData[] recentAlliesData
function C_RecentAllies.GetRecentAllies() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.GetRecentAllyByFullName)
---@param fullCharacterName string
---@return RecentAllyData? recentAllyData
function C_RecentAllies.GetRecentAllyByFullName(fullCharacterName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.GetRecentAllyByGUID)
---@param characterGUID WOWGUID
---@return RecentAllyData? recentAllyData
function C_RecentAllies.GetRecentAllyByGUID(characterGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.IsRecentAllyByFullName)
---@param fullCharacterName string
---@return boolean isRecentAlly
function C_RecentAllies.IsRecentAllyByFullName(fullCharacterName) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.IsRecentAllyByGUID)
---@param characterGUID WOWGUID
---@return boolean isRecentAlly
function C_RecentAllies.IsRecentAllyByGUID(characterGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.IsRecentAllyDataReady)
---@return boolean isReady
function C_RecentAllies.IsRecentAllyDataReady() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.IsRecentAllyPinned)
---@param characterGUID WOWGUID
---@return boolean isPinned
function C_RecentAllies.IsRecentAllyPinned(characterGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.IsSystemEnabled)
---@return boolean isRecentAllySystemEnabled
function C_RecentAllies.IsSystemEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.IsSystemSupported)
---@return boolean isRecentAllySystemSupported
function C_RecentAllies.IsSystemSupported() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.SetRecentAllyNote)
---@param characterGUID WOWGUID
---@param note string
function C_RecentAllies.SetRecentAllyNote(characterGUID, note) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.SetRecentAllyPinned)
---@param characterGUID WOWGUID
---@param isPinned boolean
function C_RecentAllies.SetRecentAllyPinned(characterGUID, isPinned) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RecentAllies.TryRequestRecentAlliesData)
function C_RecentAllies.TryRequestRecentAlliesData() end

---@class RecentAllyCharacterData
---@field guid WOWGUID
---@field name string
---@field fullName string
---@field realmName string
---@field level number
---@field classID number
---@field raceID number
---@field sex Enum.UnitSex

---@class RecentAllyData
---@field stateData RecentAllyStateData
---@field characterData RecentAllyCharacterData
---@field interactionData RecentAllyInteractionData

---@class RecentAllyInteraction
---@field type Enum.RolodexType
---@field description string
---@field timestamp time_t
---@field contextData RecentAllyInteractionContextData

---@class RecentAllyInteractionContextData
---@field itemID number?
---@field locationName string?
---@field activityDifficultyID number?
---@field activityDifficultyLevel number?

---@class RecentAllyInteractionData
---@field interactions RecentAllyInteraction[]
---@field note string?

---@class RecentAllyStateData
---@field isOnline boolean
---@field isDND boolean
---@field isAFK boolean
---@field pinExpirationDate time_t?
---@field hasFriendRequestPending boolean
---@field currentLocation string?
