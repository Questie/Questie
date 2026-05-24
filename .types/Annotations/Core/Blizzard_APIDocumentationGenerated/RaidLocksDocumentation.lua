---@meta _
C_RaidLocks = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RaidLocks.GetRedirectedDifficultyID)
---@param mapID number
---@param difficultyID number
---@return number redirectedDifficultyID
function C_RaidLocks.GetRedirectedDifficultyID(mapID, difficultyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_RaidLocks.IsEncounterComplete)
---@param mapID number
---@param encounterID number
---@param difficultyID? number
---@return boolean encounterIsComplete
function C_RaidLocks.IsEncounterComplete(mapID, encounterID, difficultyID) end
