---@meta _
C_SocialQueue = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SocialQueue.GetAllGroups)
---@param allowNonJoinable? boolean Default = false
---@param allowNonQueuedGroups? boolean Default = false
---@return WOWGUID[] groupGUIDs
function C_SocialQueue.GetAllGroups(allowNonJoinable, allowNonQueuedGroups) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SocialQueue.GetConfig)
---@return SocialQueueConfig config
function C_SocialQueue.GetConfig() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SocialQueue.GetGroupForPlayer)
---@param playerGUID WOWGUID
---@return WOWGUID groupGUID
---@return boolean isSoloQueueParty
function C_SocialQueue.GetGroupForPlayer(playerGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SocialQueue.GetGroupInfo)
---@param groupGUID WOWGUID
---@return boolean canJoin
---@return number numQueues
---@return boolean needTank
---@return boolean needHealer
---@return boolean needDamage
---@return boolean isSoloQueueParty
---@return boolean questSessionActive
---@return WOWGUID leaderGUID
function C_SocialQueue.GetGroupInfo(groupGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SocialQueue.GetGroupMembers)
---@param groupGUID WOWGUID
---@return SocialQueuePlayerInfo[] groupMembers
function C_SocialQueue.GetGroupMembers(groupGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SocialQueue.GetGroupQueues)
---@param groupGUID WOWGUID
---@return SocialQueueGroupQueueInfo[] queues
function C_SocialQueue.GetGroupQueues(groupGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SocialQueue.RequestToJoin)
---@param groupGUID WOWGUID
---@param applyAsTank? boolean Default = false
---@param applyAsHealer? boolean Default = false
---@param applyAsDamage? boolean Default = false
---@return boolean requestSuccessful
function C_SocialQueue.RequestToJoin(groupGUID, applyAsTank, applyAsHealer, applyAsDamage) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SocialQueue.SignalToastDisplayed)
---@param groupGUID WOWGUID
---@param priority number
function C_SocialQueue.SignalToastDisplayed(groupGUID, priority) end

---@class SocialQueueConfig
---@field TOASTS_DISABLED boolean
---@field TOAST_DURATION number
---@field DELAY_DURATION number
---@field QUEUE_MULTIPLIER number
---@field PLAYER_MULTIPLIER number
---@field PLAYER_FRIEND_VALUE number
---@field PLAYER_GUILD_VALUE number
---@field THROTTLE_INITIAL_THRESHOLD number
---@field THROTTLE_DECAY_TIME number
---@field THROTTLE_PRIORITY_SPIKE number
---@field THROTTLE_MIN_THRESHOLD number
---@field THROTTLE_PVP_PRIORITY_NORMAL number
---@field THROTTLE_PVP_PRIORITY_LOW number
---@field THROTTLE_PVP_HONOR_THRESHOLD number
---@field THROTTLE_LFGLIST_PRIORITY_DEFAULT number
---@field THROTTLE_LFGLIST_PRIORITY_ABOVE number
---@field THROTTLE_LFGLIST_PRIORITY_BELOW number
---@field THROTTLE_LFGLIST_ILVL_SCALING_ABOVE number
---@field THROTTLE_LFGLIST_ILVL_SCALING_BELOW number
---@field THROTTLE_RF_PRIORITY_ABOVE number
---@field THROTTLE_RF_ILVL_SCALING_ABOVE number
---@field THROTTLE_DF_MAX_ITEM_LEVEL number
---@field THROTTLE_DF_BEST_PRIORITY number

---@class SocialQueueGroupInfo
---@field canJoin boolean
---@field numQueues number
---@field needTank boolean
---@field needHealer boolean
---@field needDamage boolean
---@field isSoloQueueParty boolean
---@field questSessionActive boolean
---@field leaderGUID WOWGUID

---@class SocialQueueGroupQueueInfo
---@field clientID number
---@field eligible boolean
---@field needTank boolean
---@field needHealer boolean
---@field needDamage boolean
---@field isAutoAccept boolean
---@field queueData QueueSpecificInfo

---@class SocialQueuePlayerInfo
---@field guid WOWGUID
---@field clubId ClubId?
