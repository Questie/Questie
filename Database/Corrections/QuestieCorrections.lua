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
-- Questie writes anything, so Questie publishes no faction, class, race, expansion, SoD, or
-- Titan copies.
--
-- Questie owns a Correction only when choosing it depends on Questie state or policy. Each one
-- is a named data slot written through `SetCorrection` below: the write publishes immediately
-- (the provider recomposes only the written datatype), writing again replaces the slot's rows,
-- and nil withdraws the slot so the layers underneath show through again. There is no separate
-- registration or apply step.
--
-- Slots and the modules that own their state:
--   Npc    DarkmoonFaire               QuestieEvent — calendar state selects the location
--   Object GatheringNodeDisplayPolicy  Initialize below — static display policy
--   Quest  ContentPhasePolicy          Initialize below — reads the active Content Phase
--   Item   RuntimeItemRepair           QuestieLib — asynchronous client Item loads, published once per frame
--
-- External translation addons do not go through here: `l10n` forwards their entity lookups to the
-- provider under the `QuestieLocalesOverride` owner while resolving the UI locale.
---------------------------------------------------------------------------------------------------

local QUESTIE_OWNER = "Questie"

---@alias PolicyCorrectionRows table<number, table<integer, unknown>> Entity ID to Database Key Enum index to value.

-- Entity IDs each slot last touched, so a replace or withdrawal evicts exactly the entities
-- whose composed rows can have changed.
---@type table<string, table<number, true>>
local lastCorrectionIds = {}

-- "datatype:name" -> "file:line" of the last writer, for debugging who published a slot.
---@type table<string, string>
QuestieCorrections.correctionSources = {}

---The caller two frames up: WoW's debugstack in the client, a placeholder under busted.
---@return string
local function _CallerSource()
    if type(debugstack) == "function" then
        return string.trim(debugstack(3, 1, 0) or "")
    end
    return "test"
end

---Publishes one Questie-owned Policy Correction slot and refreshes Questie's composed views.
---
---Write-through: the provider recomposes the written datatype immediately — no separate apply.
---Pass the slot's full replacement rows every time; nil (or `{}`, which normalizes to it)
---withdraws the slot. Withdrawing a slot that was never published is a no-op, so callers do not
---need their own "was anything active" bookkeeping.
---
---Slot names are plain strings: a typo on the withdrawal side creates a second slot and leaves the
---original published, so keep the name in one place at the owning module and use it at both ends.
---@param datatype "Quest"|"Npc"|"Item"|"Object"
---@param name string Slot name, unique per datatype within owner "Questie".
---@param rows PolicyCorrectionRows|nil
---@return nil
function QuestieCorrections.SetCorrection(datatype, name, rows)
    if rows ~= nil and next(rows) == nil then
        rows = nil
    end

    local slot = datatype .. ":" .. name
    local previousIds = lastCorrectionIds[slot]
    if rows == nil and previousIds == nil then
        return
    end

    LibQuestieDB.Corrections.Set(QUESTIE_OWNER, datatype, name, rows)
    QuestieCorrections.correctionSources[slot] = _CallerSource()

    -- The union of old and new row IDs is exactly the set of entities whose composed rows can
    -- have changed: everything outside it is untouched by construction, and an unchanged row
    -- inside it re-reads identically.
    local changedIds = {}
    for id in pairs(previousIds or {}) do
        changedIds[id] = true
    end
    local currentIds
    if rows ~= nil then
        currentIds = {}
        for id in pairs(rows) do
            currentIds[id] = true
            changedIds[id] = true
        end
    end
    lastCorrectionIds[slot] = currentIds

    QuestieDB.RefreshAfterCorrectionApply(datatype, changedIds)
end

-- Gathering nodes have thousands of spawns that Questie never displays. Exactly these 24 Objects.
---@type ObjectId[]
local GATHERING_NODE_OBJECT_IDS = {
    1617, 1618, 1619, 1620, 1621, 1622, 1623, 1624, 1628,
    1731, 1732, 1733, 1734, 1735, 123848, 150082, 175404, 176643,
    177388, 324, 150079, 176645, 2040, 123310,
}

---Rows clearing the spawns of the 24 gathering-node Objects; `{}` as a field value clears it.
---@return PolicyCorrectionRows
local function _GatheringNodeDisplayRows()
    local spawnsKey = QuestieDB.objectKeys.spawns
    local rows = {}
    for _, objectId in ipairs(GATHERING_NODE_OBJECT_IDS) do
        rows[objectId] = {[spawnsKey] = {}}
    end
    return rows
end

---------------------------------------------------------------------------------------------------
-- Blacklist policy plus the static Policy Correction slots. Both express what Questie shows:
-- blacklists by hiding quests Questie-side, Correction slots by changing composed entity rows.
---------------------------------------------------------------------------------------------------

---Builds Questie-owned blacklist policy for the active flavor, season, and Content Phase, and
---publishes the Policy Correction slots that need no runtime state beyond this point. Darkmoon,
---Item repair, and external locale slots are written later by the modules that own their state.
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

    QuestieCorrections.SetCorrection("Object", "GatheringNodeDisplayPolicy", _GatheringNodeDisplayRows())

    -- TBC attunement prerequisites that follow Questie's Content Phase. The Era gate is required:
    -- the rows reference Quests that only exist from TBC on. The active phases are constants
    -- today; a live phase switch would simply re-publish this slot with the producer's new rows.
    if Expansions.Current >= Expansions.Tbc then
        QuestieCorrections.SetCorrection("Quest", "ContentPhasePolicy", QuestieTBCPolicyCorrections:LoadContentPhaseFixes())
    end
end
