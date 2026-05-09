---@meta _
C_EncounterJournal = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetDungeonEntrancesForMap)
---@param uiMapID number
---@return DungeonEntranceMapInfo[] dungeonEntrances
function C_EncounterJournal.GetDungeonEntrancesForMap(uiMapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetEncounterJournalLink)
---@param linkType Enum.JournalLinkTypes
---@param ID number
---@param displayText string
---@param difficultyID number
---@return string link
function C_EncounterJournal.GetEncounterJournalLink(linkType, ID, displayText, difficultyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetEncountersOnMap)
---@param uiMapID number
---@return EncounterJournalMapEncounterInfo[] encounters
function C_EncounterJournal.GetEncountersOnMap(uiMapID) end

---GameMap as opposed to UIMap since we use a mapID not a uiMapID.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetInstanceForGameMap)
---@param mapID number
---@return number? journalInstanceID
function C_EncounterJournal.GetInstanceForGameMap(mapID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetLootInfo)
---@param id number
---@return EncounterJournalItemInfo itemInfo
function C_EncounterJournal.GetLootInfo(id) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetLootInfoByIndex)
---@param index number
---@param encounterIndex? number
---@return EncounterJournalItemInfo itemInfo
function C_EncounterJournal.GetLootInfoByIndex(index, encounterIndex) end

---Represents the icon indices for this EJ section.  An icon index can be used to arrive at texture coordinates for specific encounter types, e.g.: EncounterJournal_SetFlagIcon
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetSectionIconFlags)
---@param sectionID number
---@return number[]? iconFlags
function C_EncounterJournal.GetSectionIconFlags(sectionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetSectionInfo)
---@param sectionID number
---@return EncounterJournalSectionInfo info
function C_EncounterJournal.GetSectionInfo(sectionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.GetSlotFilter)
---@return Enum.ItemSlotFilterType filter
function C_EncounterJournal.GetSlotFilter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.InitalizeSelectedTier)
function C_EncounterJournal.InitalizeSelectedTier() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.InstanceHasLoot)
---@param instanceID? number
---@return boolean hasLoot
function C_EncounterJournal.InstanceHasLoot(instanceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.IsEncounterComplete)
---@param journalEncounterID number
---@return boolean isEncounterComplete
function C_EncounterJournal.IsEncounterComplete(journalEncounterID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.OnClose)
function C_EncounterJournal.OnClose() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.OnOpen)
function C_EncounterJournal.OnOpen() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.ResetSlotFilter)
function C_EncounterJournal.ResetSlotFilter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.SetPreviewMythicPlusLevel)
---@param level number
function C_EncounterJournal.SetPreviewMythicPlusLevel(level) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.SetPreviewPvpTier)
---@param tier number
function C_EncounterJournal.SetPreviewPvpTier(tier) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.SetSlotFilter)
---@param filterSlot Enum.ItemSlotFilterType
function C_EncounterJournal.SetSlotFilter(filterSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterJournal.SetTab)
---@param tabIdx number
function C_EncounterJournal.SetTab(tabIdx) end

---@class DungeonEntranceMapInfo
---@field areaPoiID number
---@field position vector2
---@field name string
---@field description string
---@field atlasName string
---@field journalInstanceID number

---@class EncounterJournalItemInfo
---@field itemID number
---@field encounterID number?
---@field name string?
---@field itemQuality string?
---@field filterType Enum.ItemSlotFilterType?
---@field icon fileID?
---@field slot string?
---@field armorType string?
---@field link string?
---@field handError boolean?
---@field weaponTypeError boolean?
---@field displayAsPerPlayerLoot boolean?
---@field displayAsVeryRare boolean?
---@field displayAsExtremelyRare boolean?
---@field displaySeasonID number?

---@class EncounterJournalMapEncounterInfo
---@field encounterID number
---@field mapX number
---@field mapY number

---@class EncounterJournalSectionInfo
---@field spellID number
---@field title string
---@field description string?
---@field headerType number
---@field abilityIcon fileID
---@field creatureDisplayID number
---@field uiModelSceneID number
---@field siblingSectionID number?
---@field firstChildSectionID number?
---@field filteredByDifficulty boolean
---@field link string
---@field startsOpen boolean
