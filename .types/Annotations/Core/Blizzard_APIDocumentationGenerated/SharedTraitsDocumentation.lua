---@meta _
C_Traits = {}

---Returns whether the player can make changes to the specified talent config.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.CanEditConfig)
---@param configID number
---@return boolean canEdit
---@return string errorMessage
function C_Traits.CanEditConfig(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.CanPurchaseRank)
---@param configID number
---@param nodeID number
---@param nodeEntryID number
---@return boolean canPurchase
function C_Traits.CanPurchaseRank(configID, nodeID, nodeEntryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.CanRefundRank)
---@param configID number
---@param nodeID number
---@return boolean canRefund
function C_Traits.CanRefundRank(configID, nodeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.CascadeRepurchaseRanks)
---@param configID number
---@param nodeID number
---@param entryID? number
---@return boolean success
function C_Traits.CascadeRepurchaseRanks(configID, nodeID, entryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.ClearCascadeRepurchaseHistory)
---@param configID number
function C_Traits.ClearCascadeRepurchaseHistory(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.CloseTraitSystemInteraction)
function C_Traits.CloseTraitSystemInteraction() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.CommitConfig)
---@param configID number
---@return boolean success
function C_Traits.CommitConfig(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.ConfigHasStagedChanges)
---@param configID number
---@return boolean hasChanges
function C_Traits.ConfigHasStagedChanges(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GenerateImportString)
---@param configID number
---@return string importString
function C_Traits.GenerateImportString(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GenerateInspectImportString)
---@param target string
---@return string importString
function C_Traits.GenerateInspectImportString(target) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetConditionInfo)
---@param configID number
---@param condID number
---@return TraitCondInfo condInfo
function C_Traits.GetConditionInfo(configID, condID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetConfigIDBySystemID)
---@param systemID number
---@return number configID
function C_Traits.GetConfigIDBySystemID(systemID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetConfigIDByTreeID)
---@param treeID number
---@return number configID
function C_Traits.GetConfigIDByTreeID(treeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetConfigInfo)
---@param configID number
---@return TraitConfigInfo configInfo
function C_Traits.GetConfigInfo(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetConfigsByType)
---@param configType Enum.TraitConfigType
---@return number[] configIDs
function C_Traits.GetConfigsByType(configType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetDefinitionInfo)
---@param definitionID number
---@return TraitDefinitionInfo definitionInfo
function C_Traits.GetDefinitionInfo(definitionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetEntryInfo)
---@param configID number
---@param entryID number
---@return TraitEntryInfo entryInfo
function C_Traits.GetEntryInfo(configID, entryID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetLoadoutSerializationVersion)
---@return number serializationVersion
function C_Traits.GetLoadoutSerializationVersion() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetNodeCost)
---@param configID number
---@param nodeID number
---@return TraitCurrencyCost[] costs
function C_Traits.GetNodeCost(configID, nodeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetNodeInfo)
---@param configID number
---@param nodeID number
---@return TraitNodeInfo nodeInfo
function C_Traits.GetNodeInfo(configID, nodeID) end

---Returns IDs of Trait Nodes with pending changes, grouped by the type of change; Returns nothing if there are no pending changes
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetStagedChanges)
---@param configID number
---@return number[] nodeIDsWithPurchases
---@return number[] nodeIDsWithRefunds
---@return number[] nodeIDsWithSelectionSwaps
function C_Traits.GetStagedChanges(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetStagedChangesCost)
---@param configID number
---@return TraitCurrencyCost[] costs
function C_Traits.GetStagedChangesCost(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetSubTreeInfo)
---@param configID number
---@param subTreeID number
---@return TraitSubTreeInfo subTreeInfo
function C_Traits.GetSubTreeInfo(configID, subTreeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetSystemIDByTreeID)
---@param treeID number
---@return number systemID
function C_Traits.GetSystemIDByTreeID(treeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetTraitCurrencyInfo)
---@param traitCurrencyID number
---@return number flags
---@return number type
---@return number? currencyTypesID
---@return number? icon
function C_Traits.GetTraitCurrencyInfo(traitCurrencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetTraitDescription)
---@param entryID number
---@param rank number
---@return string description
function C_Traits.GetTraitDescription(entryID, rank) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetTraitSystemFlags)
---@param configID number
---@return number flags
function C_Traits.GetTraitSystemFlags(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetTraitSystemWidgetSetID)
---@param configID number
---@return number uiWidgetSetID
function C_Traits.GetTraitSystemWidgetSetID(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetTreeCurrencyInfo)
---@param configID number
---@param treeID number
---@param excludeStagedChanges boolean
---@return TreeCurrencyInfo[] treeCurrencyInfo
function C_Traits.GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetTreeHash)
---@param treeID number
---@return number[] result
function C_Traits.GetTreeHash(treeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetTreeInfo)
---@param configID number
---@param treeID number
---@return TraitTreeInfo treeInfo
function C_Traits.GetTreeInfo(configID, treeID) end

---Returns a list of nodeIDs, sorted ascending, for a given treeID. Contains nodes for all class specializations.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.GetTreeNodes)
---@param treeID number
---@return number[] nodeIDs
function C_Traits.GetTreeNodes(treeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.HasValidInspectData)
---@return boolean hasValidInspectData
function C_Traits.HasValidInspectData() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.IsReadyForCommit)
---@return boolean isReadyForCommit
function C_Traits.IsReadyForCommit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.PurchaseRank)
---@param configID number
---@param nodeID number
---@return boolean success
function C_Traits.PurchaseRank(configID, nodeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.RefundAllRanks)
---@param configID number
---@param nodeID number
---@return boolean success
function C_Traits.RefundAllRanks(configID, nodeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.RefundRank)
---@param configID number
---@param nodeID number
---@param clearEdges? boolean
---@return boolean success
function C_Traits.RefundRank(configID, nodeID, clearEdges) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.ResetTree)
---@param configID number
---@param treeID number
---@return boolean success
function C_Traits.ResetTree(configID, treeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.ResetTreeByCurrency)
---@param configID number
---@param treeID number
---@param traitCurrencyID number
---@return boolean success
function C_Traits.ResetTreeByCurrency(configID, treeID, traitCurrencyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.RollbackConfig)
---@param configID number
---@return boolean success
function C_Traits.RollbackConfig(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.SetSelection)
---@param configID number
---@param nodeID number
---@param nodeEntryID? number
---@param clearEdges? boolean
---@return boolean success
function C_Traits.SetSelection(configID, nodeID, nodeEntryID, clearEdges) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.StageConfig)
---@param configID number
---@return boolean success
function C_Traits.StageConfig(configID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Traits.TalentTestUnlearnSpells)
function C_Traits.TalentTestUnlearnSpells() end

---@class TraitCondInfo
---@field condID number
---@field ranksGranted number?
---@field isAlwaysMet boolean
---@field isMet boolean
---@field isGate boolean
---@field isSufficient boolean
---@field type number
---@field questID number?
---@field achievementID number?
---@field specSetID number?
---@field playerLevel number?
---@field traitCurrencyID number?
---@field spentAmountRequired number?
---@field tooltipFormat string?
---@field traitCondAccountElementID number?

---@class TraitConfigInfo
---@field ID number
---@field type Enum.TraitConfigType
---@field name string
---@field treeIDs number[]
---@field usesSharedActionBars boolean

---@class TraitCurrencyCost
---@field ID number
---@field amount number

---@class TraitDefinitionInfo
---@field spellID number?
---@field overrideName string?
---@field overrideSubtext string?
---@field overrideDescription string?
---@field overrideIcon number?
---@field overriddenSpellID number?
---@field subType Enum.TraitDefinitionSubType?

---@class TraitEntryInfo
---@field definitionID number?
---@field subTreeID number?
---@field type Enum.TraitNodeEntryType
---@field maxRanks number
---@field isAvailable boolean
---@field isDisplayError boolean
---@field conditionIDs number[]

---@class TraitEntryRankInfo
---@field entryID number
---@field rank number

---@class TraitGateInfo
---@field topLeftNodeID number
---@field conditionID number

---@class TraitNodeInfo
---@field ID number
---@field posX number
---@field posY number
---@field flags number
---@field entryIDs number[]
---@field entryIDsWithCommittedRanks number[]
---@field canPurchaseRank boolean
---@field canRefundRank boolean
---@field isAvailable boolean
---@field isVisible boolean
---@field isDisplayError boolean
---@field ranksPurchased number
---@field activeRank number
---@field currentRank number
---@field activeEntry TraitEntryRankInfo?
---@field nextEntry TraitEntryRankInfo?
---@field maxRanks number
---@field type Enum.TraitNodeType
---@field visibleEdges TraitOutEdgeInfo[]
---@field meetsEdgeRequirements boolean
---@field groupIDs number[]
---@field conditionIDs number[]
---@field isCascadeRepurchasable boolean
---@field cascadeRepurchaseEntryID number?
---@field subTreeID number?
---@field subTreeActive boolean?

---@class TraitNodeInfoPartial
---@field canPurchaseRank boolean?
---@field canRefundRank boolean?
---@field isAvailable boolean?
---@field isVisible boolean?
---@field ranksPurchased number?
---@field activeRank number?
---@field currentRank number?
---@field meetsEdgeRequirements boolean?
---@field isCascadeRepurchasable boolean?
---@field activeEntryID number?
---@field subTreeActive boolean?

---@class TraitOutEdgeInfo
---@field targetNode number
---@field type number
---@field visualStyle number
---@field isActive boolean

---@class TraitSubTreeInfo
---@field ID number
---@field name string?
---@field description string?
---@field iconElementID textureAtlas?
---@field traitCurrencyID number?
---@field isActive boolean
---@field subTreeSelectionNodeIDs number[]
---@field posX number
---@field posY number

---@class TraitTreeInfo
---@field ID number
---@field gates TraitGateInfo[]
---@field hideSingleRankNumbers boolean

---@class TreeCurrencyInfo
---@field traitCurrencyID number
---@field quantity number
---@field maxQuantity number?
---@field spent number
