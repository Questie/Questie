---@class QuestieCorrections
local QuestieCorrections = QuestieLoader:CreateModule("QuestieCorrections")

---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieTBCPolicyCorrections
local QuestieTBCPolicyCorrections = QuestieLoader:ImportModule("QuestieTBCPolicyCorrections")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieNPCBlacklist
local QuestieNPCBlacklist = QuestieLoader:ImportModule("QuestieNPCBlacklist")
---@type QuestieItemBlacklist
local QuestieItemBlacklist = QuestieLoader:ImportModule("QuestieItemBlacklist")
---@type HardcoreBlacklist
local HardcoreBlacklist = QuestieLoader:ImportModule("HardcoreBlacklist")
---@type BlacklistFilter
local BlacklistFilter = QuestieLoader:ImportModule("BlacklistFilter")
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")

---@type table<ItemId, boolean>
QuestieCorrections.questItemBlacklist = {}
---@type table<NpcId, boolean>
QuestieCorrections.questNPCBlacklist = {}
---@type table<QuestId, boolean|string>
QuestieCorrections.hiddenQuests = {}

---------------------------------------------------------------------------------------------------
-- Questie Policy Corrections
--
-- QuestieTDB composes provider-owned entity corrections cumulatively: Classic on every flavor,
-- followed by TBC, WotLK, Cata, and MoP where applicable. SoD applies only during its active
-- season; Titan applies only on the WotLK client during season 109. Those layers exist before
-- Questie registers, so Questie registers no faction, class, race, expansion, SoD, or Titan copies.
--
-- Questie owns a Correction only when choosing it depends on Questie state or policy. Every such
-- Correction is registered once under owner "Questie" and applied through one shared path. The
-- initial apply happens before QuestieDB initialization; later Darkmoon, Content Phase, runtime
-- Item, and external locale changes reapply the owner and refresh Questie's composed views.
---------------------------------------------------------------------------------------------------

local QUESTIE_OWNER = "Questie"

-- Load order only sequences entries of one datatype within owner "Questie"; later wins.
local DARKMOON_LOAD_ORDER = 100
local GATHERING_NODE_LOAD_ORDER = 200
local CONTENT_PHASE_LOAD_ORDER = 300
local RUNTIME_ITEM_LOAD_ORDER = 400
local EXTERNAL_LOCALE_ITEM_LOAD_ORDER = 500
local EXTERNAL_LOCALE_QUEST_LOAD_ORDER = 501
local EXTERNAL_LOCALE_NPC_LOAD_ORDER = 502
local EXTERNAL_LOCALE_OBJECT_LOAD_ORDER = 503

---@alias PolicyCorrectionRows table<number, table<integer, unknown>> Entity ID to Database Key Enum index to value.

---@class ExternalLocaleCorrections Rows supplied by an external locale addon, one table per datatype.
---@field Item PolicyCorrectionRows
---@field Quest PolicyCorrectionRows
---@field Npc PolicyCorrectionRows
---@field Object PolicyCorrectionRows

-- Owner-scoped registrar; nil until the first InitializePolicyCorrections call registers the providers.
local questieRegistrar

-- Captured Policy Correction state. The providers below return these tables on every apply, so a
-- setter only has to replace a table and reapply. Replacing with `{}` withdraws that layer.
---@type PolicyCorrectionRows
local activeDarkmoonNpcCorrections = {}
---@type PolicyCorrectionRows
local activeRuntimeItemCorrections = {}
---@type ExternalLocaleCorrections
local activeExternalLocaleCorrections = {Item = {}, Quest = {}, Npc = {}, Object = {}}

-- Gathering nodes have thousands of spawns that Questie never displays. Exactly these 24 Objects.
---@type ObjectId[]
local GATHERING_NODE_OBJECT_IDS = {
    1617, 1618, 1619, 1620, 1621, 1622, 1623, 1624, 1628,
    1731, 1732, 1733, 1734, 1735, 123848, 150082, 175404, 176643,
    177388, 324, 150079, 176645, 2040, 123310,
}

-- Providers: each returns the current rows for one registered Policy Correction. --------------

---Darkmoon Faire NPC spawns for the location QuestieEvent selected; `{}` while no faire is up.
---@return PolicyCorrectionRows
local function _DarkmoonFaireCorrections()
    return activeDarkmoonNpcCorrections
end

---Clears the spawns of the 24 gathering-node Objects; `{}` as a field value clears it.
---@return PolicyCorrectionRows
local function _GatheringNodeDisplayPolicy()
    local spawnsKey = QuestieDB.objectKeys.spawns
    local rows = {}
    for _, objectId in ipairs(GATHERING_NODE_OBJECT_IDS) do
        rows[objectId] = {[spawnsKey] = {}}
    end
    return rows
end

---TBC attunement prerequisites that follow Questie's Content Phase. The Era gate is required:
---without it the overlay would create malformed rows for Quests 10944 and 11007 on Era.
---The producer reads the active phase on every apply, so a phase change only needs a reapply.
---@return PolicyCorrectionRows
local function _ContentPhasePolicy()
    if Expansions.Current < Expansions.Tbc then
        return {}
    end
    return QuestieTBCPolicyCorrections:LoadContentPhaseFixes()
end

---Name-only rows for Items the client loaded asynchronously because the database lacked them.
---@return PolicyCorrectionRows
local function _RuntimeItemRepair()
    return activeRuntimeItemCorrections
end

---@return PolicyCorrectionRows
local function _ExternalLocaleItem()
    return activeExternalLocaleCorrections.Item
end

---@return PolicyCorrectionRows
local function _ExternalLocaleQuest()
    return activeExternalLocaleCorrections.Quest
end

---@return PolicyCorrectionRows
local function _ExternalLocaleNpc()
    return activeExternalLocaleCorrections.Npc
end

---@return PolicyCorrectionRows
local function _ExternalLocaleObject()
    return activeExternalLocaleCorrections.Object
end

-- Shared apply path ---------------------------------------------------------------------------

---Reapplies owner "Questie". QuestieTDB rebuilds the layer from the providers and invalidates its
---own caches; Questie's pointer maps and semantic caches only need a refresh once QuestieDB has
---bound them.
---@return nil
local function _ApplyQuestieCorrections()
    questieRegistrar.Apply()

    if QuestieDB.IsInitialized then
        QuestieDB.RefreshAfterCorrectionApply()
    end
end

---Registers the eight Questie Policy Corrections exactly once, captures the initial external
---locale rows, and applies owner "Questie" for the first time. Login Initialization calls this
---after the provider locale is forwarded and before QuestieDB.Initialize, so the first apply also
---fixes Questie's owner precedence.
---@param externalLocaleCorrections ExternalLocaleCorrections Existence-filtered rows built against the clean composed view.
---@return nil
function QuestieCorrections.InitializePolicyCorrections(externalLocaleCorrections)
    if not questieRegistrar then
        -- Registration is append-only in QuestieTDB; registering twice would duplicate every entry.
        questieRegistrar = LibQuestieDB.GetRegistrar(QUESTIE_OWNER)
        questieRegistrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", _DarkmoonFaireCorrections, DARKMOON_LOAD_ORDER)
        questieRegistrar.RegisterRuntimeCorrection("Object", "GatheringNodeDisplayPolicy", _GatheringNodeDisplayPolicy, GATHERING_NODE_LOAD_ORDER)
        questieRegistrar.RegisterRuntimeCorrection("Quest", "ContentPhasePolicy", _ContentPhasePolicy, CONTENT_PHASE_LOAD_ORDER)
        questieRegistrar.RegisterRuntimeCorrection("Item", "RuntimeItemRepair", _RuntimeItemRepair, RUNTIME_ITEM_LOAD_ORDER)
        questieRegistrar.RegisterRuntimeCorrection("Item", "ExternalLocaleItem", _ExternalLocaleItem, EXTERNAL_LOCALE_ITEM_LOAD_ORDER)
        questieRegistrar.RegisterRuntimeCorrection("Quest", "ExternalLocaleQuest", _ExternalLocaleQuest, EXTERNAL_LOCALE_QUEST_LOAD_ORDER)
        questieRegistrar.RegisterRuntimeCorrection("Npc", "ExternalLocaleNpc", _ExternalLocaleNpc, EXTERNAL_LOCALE_NPC_LOAD_ORDER)
        questieRegistrar.RegisterRuntimeCorrection("Object", "ExternalLocaleObject", _ExternalLocaleObject, EXTERNAL_LOCALE_OBJECT_LOAD_ORDER)
    end

    activeExternalLocaleCorrections = externalLocaleCorrections
    _ApplyQuestieCorrections()
end

---Reapplies owner "Questie" after Questie state that a provider reads has changed, such as the
---active Content Phase. Setters below call the same path after replacing their captured table.
---@return nil
function QuestieCorrections.ReapplyPolicyCorrections()
    _ApplyQuestieCorrections()
end

-- Setters: one per Questie-owned runtime input ------------------------------------------------

---Publishes the NPC rows for the active Darkmoon Faire location. QuestieEvent calls this once per
---load with the Classic or TBC producer result, or with `{}` to withdraw an inactive faire.
---@param npcCorrections PolicyCorrectionRows
---@return nil
function QuestieCorrections.SetDarkmoonNpcCorrections(npcCorrections)
    -- Nothing published and nothing to withdraw: skip the recomposition and Questie's cache refresh
    -- that every login without an active faire would otherwise pay.
    if next(npcCorrections) == nil and next(activeDarkmoonNpcCorrections) == nil then
        return
    end

    activeDarkmoonNpcCorrections = npcCorrections
    _ApplyQuestieCorrections()
end

---Records the client-loaded name of an Item the database lacked and reapplies so the Item becomes
---readable and enumerable. Repairs accumulate; a repeated callback with the same name is a no-op
---and a nil name is ignored. Name only: no relationship field is inferred.
---@param itemId ItemId
---@param itemName string|nil
---@return nil
function QuestieCorrections.RepairMissingItem(itemId, itemName)
    if not itemName then
        return
    end

    local nameKey = QuestieDB.itemKeys.name
    local existingRepair = activeRuntimeItemCorrections[itemId]
    if existingRepair and existingRepair[nameKey] == itemName then
        return
    end

    activeRuntimeItemCorrections[itemId] = {[nameKey] = itemName}
    _ApplyQuestieCorrections()
end

---Withdraws all four external locale layers by applying empty tables.
---@return nil
function QuestieCorrections.WithdrawExternalLocaleCorrections()
    activeExternalLocaleCorrections = {Item = {}, Quest = {}, Npc = {}, Object = {}}
    _ApplyQuestieCorrections()
end

---Replaces the external locale layers withdrawal-first: the old layer is withdrawn and applied
---before `buildCorrections` runs, so an entity that existed only through the previous external
---locale cannot pass the builder's existence filter and validate itself.
---@param buildCorrections fun(): ExternalLocaleCorrections Builds the new rows against the now-clean composed view.
---@return nil
function QuestieCorrections.SetExternalLocaleCorrections(buildCorrections)
    QuestieCorrections.WithdrawExternalLocaleCorrections()
    activeExternalLocaleCorrections = buildCorrections()
    _ApplyQuestieCorrections()
end

---------------------------------------------------------------------------------------------------
-- Blacklist policy: what Questie shows, independent of entity facts and registrar state.
---------------------------------------------------------------------------------------------------

---Builds Questie-owned blacklist policy for the active flavor, season, and Content Phase.
---@return nil
function QuestieCorrections.Initialize()
    QuestieCorrections.questItemBlacklist = BlacklistFilter.filterExpansion(QuestieItemBlacklist:Load())
    QuestieCorrections.questNPCBlacklist = BlacklistFilter.filterExpansion(QuestieNPCBlacklist:Load())
    QuestieCorrections.hiddenQuests = BlacklistFilter.filterExpansion(QuestieQuestBlacklist:Load())

    -- At the completed Isle state, merge its final quest visibility without overriding explicit policy.
    if Questie.db.global.isleOfQuelDanasPhase == IsleOfQuelDanas.MAX_ISLE_OF_QUEL_DANAS_PHASES then
        for questId, hide in pairs(IsleOfQuelDanas.quests[Questie.db.global.isleOfQuelDanasPhase]) do
            if QuestieCorrections.hiddenQuests[questId] == nil then
                QuestieCorrections.hiddenQuests[questId] = hide
            end
        end
    end

    -- WotLK and Titan add policy blacklists after the shared expansion-filtered list.
    if Expansions.Current >= Expansions.Wotlk then
        for questId, hide in pairs(QuestieQuestBlacklist.LoadAutoBlacklistWotlk()) do
            if QuestieCorrections.hiddenQuests[questId] == nil then
                QuestieCorrections.hiddenQuests[questId] = hide
            end
        end

        if Questie.IsTitanReforged then
            for questId, hide in pairs(QuestieQuestBlacklist.LoadAutoBlacklistIsTitanReforged()) do
                if QuestieCorrections.hiddenQuests[questId] == nil then
                    QuestieCorrections.hiddenQuests[questId] = hide
                end
            end
        end
    end

    -- Hardcore hides battleground and other unavailable quests regardless of earlier policy.
    if Questie.IsHardcore then
        for questId in pairs(HardcoreBlacklist:Load()) do
            QuestieCorrections.hiddenQuests[questId] = true
        end
    end
end
