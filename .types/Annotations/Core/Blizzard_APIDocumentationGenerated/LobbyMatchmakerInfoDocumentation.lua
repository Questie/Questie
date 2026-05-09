---@meta _
C_LobbyMatchmakerInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LobbyMatchmakerInfo.AbandonQueue)
function C_LobbyMatchmakerInfo.AbandonQueue() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LobbyMatchmakerInfo.EnterQueue)
---@param playlistEntry Enum.PartyPlaylistEntry
function C_LobbyMatchmakerInfo.EnterQueue(playlistEntry) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LobbyMatchmakerInfo.GetCurrQueuePlaylistEntry)
---@return Enum.PartyPlaylistEntry playlistEntry
function C_LobbyMatchmakerInfo.GetCurrQueuePlaylistEntry() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LobbyMatchmakerInfo.GetCurrQueueState)
---@return Enum.PlunderstormQueueState queueState
function C_LobbyMatchmakerInfo.GetCurrQueueState() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LobbyMatchmakerInfo.GetQueueFromMainlineEnabled)
---@return boolean queueFromMainlineEnabled
function C_LobbyMatchmakerInfo.GetQueueFromMainlineEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LobbyMatchmakerInfo.GetQueueStartTime)
---@return number queueStartTime
function C_LobbyMatchmakerInfo.GetQueueStartTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LobbyMatchmakerInfo.IsInQueue)
---@return boolean isInQueue
function C_LobbyMatchmakerInfo.IsInQueue() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LobbyMatchmakerInfo.RespondToQueuePop)
---@param acceptQueue boolean
function C_LobbyMatchmakerInfo.RespondToQueuePop(acceptQueue) end

---@class LobbyMatchmakerQueueInfo
---@field isQueueActive boolean? Default = false
---@field playlistEntryID Enum.PartyPlaylistEntry
---@field queueState Enum.PlunderstormQueueState
---@field queueStartTime number
