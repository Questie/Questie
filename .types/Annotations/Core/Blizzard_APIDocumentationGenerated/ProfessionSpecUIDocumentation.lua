---@meta _
C_ProfSpecs = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.CanRefundPath)
---@param pathID number
---@param configID number
---@return boolean canRefund
function C_ProfSpecs.CanRefundPath(pathID, configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.CanUnlockTab)
---@param tabTreeID number
---@param configID number
---@return boolean canUnlock
function C_ProfSpecs.CanUnlockTab(tabTreeID, configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetChildrenForPath)
---@param pathID number
---@return number[] childIDs
function C_ProfSpecs.GetChildrenForPath(pathID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetConfigIDForSkillLine)
---@param skillLineID number
---@return number configID
function C_ProfSpecs.GetConfigIDForSkillLine(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetCurrencyInfoForSkillLine)
---@param skillLineID number
---@return SpecializationCurrencyInfo info
function C_ProfSpecs.GetCurrencyInfoForSkillLine(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetDefaultSpecSkillLine)
---@return number? defaultSpecSkillLine
function C_ProfSpecs.GetDefaultSpecSkillLine() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetDescriptionForPath)
---@param pathID number
---@return string description
function C_ProfSpecs.GetDescriptionForPath(pathID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetDescriptionForPerk)
---@param perkID number
---@return string description
function C_ProfSpecs.GetDescriptionForPerk(perkID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetEntryIDForPerk)
---@param perkID number
---@return number entryID
function C_ProfSpecs.GetEntryIDForPerk(perkID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetNewSpecReminderProfName)
---@return string? profName
function C_ProfSpecs.GetNewSpecReminderProfName() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetPerksForPath)
---@param pathID number
---@return SpecPerkInfo[] perkInfos
function C_ProfSpecs.GetPerksForPath(pathID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetRootPathForTab)
---@param tabTreeID number
---@return number? rootPathID
function C_ProfSpecs.GetRootPathForTab(tabTreeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetSourceTextForPath)
---@param pathID number
---@param configID number
---@return string sourceText
function C_ProfSpecs.GetSourceTextForPath(pathID, configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetSpecTabIDsForSkillLine)
---@param skillLineID number
---@return number[] specTabIDs
function C_ProfSpecs.GetSpecTabIDsForSkillLine(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetSpecTabInfo)
---@return SpecializationTabInfo specTabInfo
function C_ProfSpecs.GetSpecTabInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetSpendCurrencyForPath)
---@param pathID number
---@return number? currencyID
function C_ProfSpecs.GetSpendCurrencyForPath(pathID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetSpendEntryForPath)
---@param pathID number
---@return number entryID
function C_ProfSpecs.GetSpendEntryForPath(pathID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetStateForPath)
---@param pathID number
---@param configID number
---@return Enum.ProfessionsSpecPathState state
function C_ProfSpecs.GetStateForPath(pathID, configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetStateForPerk)
---@param perkID number
---@param configID number
---@return Enum.ProfessionsSpecPerkState state
function C_ProfSpecs.GetStateForPerk(perkID, configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetStateForTab)
---@param tabTreeID number
---@param configID number
---@return Enum.ProfessionsSpecTabState tabInfo
function C_ProfSpecs.GetStateForTab(tabTreeID, configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetTabInfo)
---@param tabTreeID number
---@return ProfTabInfo? tabInfo
function C_ProfSpecs.GetTabInfo(tabTreeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetUnlockEntryForPath)
---@param pathID number
---@return number entryID
function C_ProfSpecs.GetUnlockEntryForPath(pathID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.GetUnlockRankForPerk)
---@param perkID number
---@return number? unlockRank
function C_ProfSpecs.GetUnlockRankForPerk(perkID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.ShouldShowPointsReminder)
---@return boolean showReminder
function C_ProfSpecs.ShouldShowPointsReminder() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.ShouldShowPointsReminderForSkillLine)
---@param skillLineID number
---@return boolean showReminder
function C_ProfSpecs.ShouldShowPointsReminderForSkillLine(skillLineID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.ShouldShowSpecTab)
---@return boolean showSpecTab
function C_ProfSpecs.ShouldShowSpecTab() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ProfSpecs.SkillLineHasSpecialization)
---@param skillLineID number
---@return boolean hasSpecialization
function C_ProfSpecs.SkillLineHasSpecialization(skillLineID) end
