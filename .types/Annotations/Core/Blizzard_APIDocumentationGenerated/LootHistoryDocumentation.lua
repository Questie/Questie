---@meta _
C_LootHistory = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LootHistory.GetAllEncounterInfos)
---@return EncounterLootInfo[] infos
function C_LootHistory.GetAllEncounterInfos() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LootHistory.GetInfoForEncounter)
---@param encounterID number
---@return EncounterLootInfo? info
function C_LootHistory.GetInfoForEncounter(encounterID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LootHistory.GetLootHistoryTime)
---@return number time
function C_LootHistory.GetLootHistoryTime() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LootHistory.GetSortedDropsForEncounter)
---@param encounterID number
---@return EncounterLootDropInfo[]? drops
function C_LootHistory.GetSortedDropsForEncounter(encounterID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LootHistory.GetSortedInfoForDrop)
---@param encounterID number
---@param lootListID number
---@return EncounterLootDropInfo? info
function C_LootHistory.GetSortedInfoForDrop(encounterID, lootListID) end

---@class EncounterLootDropInfo
---@field lootListID number
---@field itemHyperlink string
---@field playerRollState Enum.EncounterLootDropRollState
---@field currentLeader EncounterLootDropRollInfo?
---@field isTied boolean? Default = false
---@field winner EncounterLootDropRollInfo?
---@field allPassed boolean? Default = false
---@field rollInfos EncounterLootDropRollInfo[]
---@field startTime number
---@field duration number

---@class EncounterLootDropRollInfo
---@field playerName string
---@field playerGUID WOWGUID
---@field playerClass string
---@field isSelf boolean
---@field state Enum.EncounterLootDropRollState
---@field isWinner boolean? Default = false
---@field roll number?

---@class EncounterLootDrops
---@field encounterID number
---@field drops EncounterLootDropInfo[]

---@class EncounterLootInfo
---@field encounterName string
---@field encounterID number
---@field startTime number
---@field duration number
