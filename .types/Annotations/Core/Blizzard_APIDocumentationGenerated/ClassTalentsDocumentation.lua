---@meta _
C_ClassTalents = {}

---Returns true only if the player has staged changes and can commit their talents in their current state.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.CanChangeTalents)
---@return boolean canChange
---@return boolean canAdd
---@return string? changeError
function C_ClassTalents.CanChangeTalents() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.CanCreateNewConfig)
---@return boolean canCreate
function C_ClassTalents.CanCreateNewConfig() end

---Returns true if the player could switch talents if they staged a proper loadout.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.CanEditTalents)
---@return boolean canEdit
---@return string changeError
function C_ClassTalents.CanEditTalents() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.CommitConfig)
---@param savedConfigID? number
---@return boolean success
function C_ClassTalents.CommitConfig(savedConfigID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.DeleteConfig)
---@param configID number
---@return boolean success
function C_ClassTalents.DeleteConfig(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetActiveConfigID)
---@return number? activeConfigID
function C_ClassTalents.GetActiveConfigID() end

---Returns the SubTreeID of the player's active Hero Talent Specialization SubTree.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetActiveHeroTalentSpec)
---@return number? heroSpecID
function C_ClassTalents.GetActiveHeroTalentSpec() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetConfigIDsBySpecID)
---@param specID? number
---@return number[] configIDs
function C_ClassTalents.GetConfigIDsBySpecID(specID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetHasStarterBuild)
---@return boolean hasStarterBuild
function C_ClassTalents.GetHasStarterBuild() end

---Returns the SubTreeIDs of the Hero Talent Specializations available to a Class Specialization and config; Returns nothing if none available
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetHeroTalentSpecsForClassSpec)
---@param configID? number
---@param classSpecID? number
---@return number[]? subTreeIDs
---@return number? requiredPlayerLevel
function C_ClassTalents.GetHeroTalentSpecsForClassSpec(configID, classSpecID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetLastSelectedSavedConfigID)
---@param specID number
---@return number? configID
function C_ClassTalents.GetLastSelectedSavedConfigID(specID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetNextStarterBuildPurchase)
---@return number? nodeID
---@return number? entryID
function C_ClassTalents.GetNextStarterBuildPurchase() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetStarterBuildActive)
---@return boolean isActive
function C_ClassTalents.GetStarterBuildActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetTraitTreeForSpec)
---@param specID number
---@return number? treeID
function C_ClassTalents.GetTraitTreeForSpec(specID) end

---Returns whether the player has any unspent talent points in their active hero talent tree. If hasUnspentPoints is true, numHeroPoints will be greater than zero.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.HasUnspentHeroTalentPoints)
---@return boolean hasUnspentPoints
---@return number numHeroPoints
function C_ClassTalents.HasUnspentHeroTalentPoints() end

---Returns whether the player has any unspent talent points in their class or spec talent trees. If hasUnspentPoints is true, the number of unspent points for at least one of the trees will be greater than zero. Hero talent points are not included by this function.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.HasUnspentTalentPoints)
---@return boolean hasUnspentPoints
---@return number numClassPoints
---@return number numSpecPoints
function C_ClassTalents.HasUnspentTalentPoints() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.ImportLoadout)
---@param configID number
---@param entries ImportLoadoutEntryInfo[]
---@param name string
---@return boolean success
---@return string importError
function C_ClassTalents.ImportLoadout(configID, entries, name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.InitializeViewLoadout)
---@param specID number
---@param level number
function C_ClassTalents.InitializeViewLoadout(specID, level) end

---New configs may or may not be populated and ready to load immediately after creation. Avoid calling for configs intentionally created empty.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.IsConfigPopulated)
---@param configID number
---@return boolean isPopulated
function C_ClassTalents.IsConfigPopulated(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.LoadConfig)
---@param configID number
---@param autoApply boolean
---@return Enum.LoadConfigResult result
---@return string? changeError
---@return number[] newLearnedNodeIDs
function C_ClassTalents.LoadConfig(configID, autoApply) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.RenameConfig)
---@param configID number
---@param name string
---@return boolean success
function C_ClassTalents.RenameConfig(configID, name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.RequestNewConfig)
---@param name string
---@return boolean success
function C_ClassTalents.RequestNewConfig(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.SaveConfig)
---@param configID number
---@return boolean success
function C_ClassTalents.SaveConfig(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.SetStarterBuildActive)
---@param active boolean
---@return Enum.LoadConfigResult result
function C_ClassTalents.SetStarterBuildActive(active) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.SetUsesSharedActionBars)
---@param configID number
---@param usesShared boolean
function C_ClassTalents.SetUsesSharedActionBars(configID, usesShared) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.UpdateLastSelectedSavedConfigID)
---@param specID number
---@param configID? number
function C_ClassTalents.UpdateLastSelectedSavedConfigID(specID, configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ClassTalents.ViewLoadout)
---@param entries ImportLoadoutEntryInfo[]
---@return boolean success
function C_ClassTalents.ViewLoadout(entries) end

---@class ImportLoadoutEntryInfo
---@field nodeID number
---@field ranksGranted number
---@field ranksPurchased number
---@field selectionEntryID number
