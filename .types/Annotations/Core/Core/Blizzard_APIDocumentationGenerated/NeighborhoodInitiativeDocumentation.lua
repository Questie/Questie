---@meta _
C_NeighborhoodInitiative = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.AddTrackedInitiativeTask)
---@param initiativeTaskID number
function C_NeighborhoodInitiative.AddTrackedInitiativeTask(initiativeTaskID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.GetActiveNeighborhood)
---@return WOWGUID neighborhoodGUID
function C_NeighborhoodInitiative.GetActiveNeighborhood() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.GetInitiativeActivityLogInfo)
---@return InitiativeActivityLogInfo? info
function C_NeighborhoodInitiative.GetInitiativeActivityLogInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.GetInitiativeTaskChatLink)
---@param initiativeTaskID number
---@return string link
function C_NeighborhoodInitiative.GetInitiativeTaskChatLink(initiativeTaskID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.GetInitiativeTaskInfo)
---@param initiativeTaskID number
---@return InitiativeTaskInfo? info
function C_NeighborhoodInitiative.GetInitiativeTaskInfo(initiativeTaskID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo)
---@return NeighborhoodInitiativeInfo? info
function C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.GetRequiredLevel)
---@return number reqLevel
function C_NeighborhoodInitiative.GetRequiredLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.GetTrackedInitiativeTasks)
---@return InitiativeTasksTracked trackedInitiativeTasks
function C_NeighborhoodInitiative.GetTrackedInitiativeTasks() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.IsInitiativeEnabled)
---@return boolean enabled
function C_NeighborhoodInitiative.IsInitiativeEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.IsPlayerInNeighborhoodGroup)
---@return boolean inValidGroup
function C_NeighborhoodInitiative.IsPlayerInNeighborhoodGroup() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.IsViewingActiveNeighborhood)
---@return boolean isViewingActiveNeighborhood
function C_NeighborhoodInitiative.IsViewingActiveNeighborhood() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.PlayerHasInitiativeAccess)
---@return boolean success
function C_NeighborhoodInitiative.PlayerHasInitiativeAccess() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.PlayerMeetsRequiredLevel)
---@return boolean success
function C_NeighborhoodInitiative.PlayerMeetsRequiredLevel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.RemoveTrackedInitiativeTask)
---@param initiativeTaskID number
function C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(initiativeTaskID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.RequestInitiativeActivityLog)
function C_NeighborhoodInitiative.RequestInitiativeActivityLog() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo)
function C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.SetActiveNeighborhood)
---@param neighborhoodGUID WOWGUID
function C_NeighborhoodInitiative.SetActiveNeighborhood(neighborhoodGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_NeighborhoodInitiative.SetViewingNeighborhood)
---@param neighborhoodGUID WOWGUID
function C_NeighborhoodInitiative.SetViewingNeighborhood(neighborhoodGUID) end

---@class InitiativeActivityLogEntry
---@field taskID number
---@field playerName string
---@field taskName string
---@field completionTime time_t
---@field amount number

---@class InitiativeActivityLogInfo
---@field isLoaded boolean
---@field neighborhoodGUID WOWGUID
---@field nextUpdateTime time_t
---@field taskActivity InitiativeActivityLogEntry[]

---@class InitiativeMilestoneInfo
---@field milestoneOrderIndex number
---@field requiredContributionAmount number
---@field rewards InitiativeMilestoneRewardInfo[]

---@class InitiativeMilestoneRewardInfo
---@field title string
---@field description string
---@field decorID number
---@field decorQuantity number
---@field favor number
---@field money WOWMONEY
---@field rewardQuestID number

---@class InitiativeTaskInfo
---@field ID number
---@field taskName string
---@field description string
---@field progressContributionAmount number
---@field tracked boolean
---@field supersedes number
---@field timesCompleted number
---@field completed boolean
---@field inProgress boolean
---@field taskType Enum.NeighborhoodInitiativeTaskType
---@field sortOrder number
---@field rewardQuestID number
---@field requirementsList CriteriaRequirement[]
---@field criteriaList CriteriaRequiredValue[]

---@class InitiativeTasksTracked
---@field trackedIDs number[]

---@class NeighborhoodInitiativeInfo
---@field isLoaded boolean
---@field neighborhoodGUID WOWGUID
---@field initiativeID number
---@field currentCycleID number
---@field progressRequired number
---@field currentProgress number
---@field playerTotalContribution number
---@field duration time_t
---@field tasks InitiativeTaskInfo[]
---@field milestones InitiativeMilestoneInfo[]
---@field title string
---@field description string
