---@class QuestieCorrections
local QuestieCorrections = QuestieLoader:CreateModule("QuestieCorrections")

---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
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

-- QuestieTDB composes provider-owned entity corrections cumulatively: Classic on every flavor,
-- followed by TBC, WotLK, Cata, and MoP where applicable. SoD applies only during its active
-- season; Titan applies only on the WotLK client during season 109. These layers are available
-- before Questie registers its Policy Corrections, so Questie must not register duplicate copies.

-- Questie-owned Policy Corrections register and apply in this order:
-- 100 DarkmoonFaire; 200 GatheringNodeDisplayPolicy; 300 ContentPhasePolicy;
-- 400 RuntimeItemRepair; 500 ExternalLocaleItem; 501 ExternalLocaleQuest;
-- 502 ExternalLocaleNpc; 503 ExternalLocaleObject.
-- The initial owner apply happens before QuestieDB initialization. Later Darkmoon, Content Phase,
-- runtime Item, and external locale changes reapply the owner and refresh Questie's composed views.

-- GatheringNodeDisplayPolicy clears Object spawns for exactly these 24 IDs:
-- 1617, 1618, 1619, 1620, 1621, 1622, 1623, 1624, 1628,
-- 1731, 1732, 1733, 1734, 1735, 123848, 150082, 175404, 176643,
-- 177388, 324, 150079, 176645, 2040, 123310.

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
