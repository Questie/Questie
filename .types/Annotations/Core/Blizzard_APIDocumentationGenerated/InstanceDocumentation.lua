---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_CanChangePlayerDifficulty)
---@return boolean canChange
---@return boolean notOnCooldown
function CanChangePlayerDifficulty() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CanMapChangeDifficulty)
---@param mapID? number
---@return boolean canChange
function CanMapChangeDifficulty(mapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CanShowResetInstances)
---@return boolean result
function CanShowResetInstances() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetDifficultyInfo)
---@param difficultyID number
---@return string name
---@return string instanceType
---@return boolean isHeroic
---@return boolean isChallengeMode
---@return boolean displayHeroic
---@return boolean displayMythic
---@return number? toggleDifficultyID
---@return boolean isLFR
---@return number? minPlayers
---@return number? maxPlayers
function GetDifficultyInfo(difficultyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetDungeonDifficultyID)
---@return number result
function GetDungeonDifficultyID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetInstanceBootTimeRemaining)
---@return number result
function GetInstanceBootTimeRemaining() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetInstanceInfo)
---@return string name
---@return string instanceType
---@return number difficultyID
---@return string difficultyName
---@return number maxPlayers
---@return number dynamicDifficulty
---@return boolean? isDynamic
---@return number instanceID
---@return number instanceGroupSize
---@return number? lfgDungeonID
function GetInstanceInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetInstanceLockTimeRemaining)
---@return number timeLeft
---@return boolean extending
---@return number encountersTotal
---@return number encountersCompleted
function GetInstanceLockTimeRemaining() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetInstanceLockTimeRemainingEncounter)
---@param encounterIndex number
---@return string encounterName
---@return string texture
---@return boolean isKilled
---@return boolean ineligible
function GetInstanceLockTimeRemainingEncounter(encounterIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetLegacyRaidDifficultyID)
---@return number? result
function GetLegacyRaidDifficultyID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetRaidDifficultyID)
---@return number? result
function GetRaidDifficultyID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsInInstance)
---@return boolean isInInstance
---@return string instanceType
function IsInInstance() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsLegacyDifficulty)
---@param difficultyID number
---@return boolean? result
function IsLegacyDifficulty(difficultyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ResetInstances)
function ResetInstances() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetDungeonDifficultyID)
---@param difficultyID number
function SetDungeonDifficultyID(difficultyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetLegacyRaidDifficultyID)
---@param difficultyID number
---@param force? boolean Default = false
function SetLegacyRaidDifficultyID(difficultyID, force) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetRaidDifficultyID)
---@param difficultyID number
---@param force? boolean Default = false
function SetRaidDifficultyID(difficultyID, force) end

---@class DifficultyInfo
---@field name string
---@field instanceType string
---@field isHeroic boolean
---@field isChallengeMode boolean
---@field displayHeroic boolean
---@field displayMythic boolean
---@field toggleDifficultyID number?
---@field isLFR boolean
---@field minPlayers number?
---@field maxPlayers number?

---@class DungeonEncounterInfo
---@field encounterName string
---@field texture string
---@field isKilled boolean
---@field ineligible boolean

---@class InstanceInfo
---@field name string
---@field instanceType string
---@field difficultyID number
---@field difficultyName string
---@field maxPlayers number
---@field dynamicDifficulty number
---@field isDynamic boolean?
---@field instanceID number
---@field instanceGroupSize number
---@field lfgDungeonID number?
