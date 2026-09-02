---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Addon Load gate: schema metadata is read below, before Login Initialization re-checks the Contract.
local contractSupported, contractError = LibQuestieDB.RequireContract(1)
if not contractSupported then
    error(contractError, 0)
end

---Quest Database Key Enum owned by QuestieTDB. Values index provider rows and Correction rows.
---@class DatabaseQuestKeys
---@field name integer string
---@field startedBy integer table {creatureStart: NpcId[], objectStart: ObjectId[], itemStart: ItemId[]}
---@field finishedBy integer table {creatureEnd: NpcId[], objectEnd: ObjectId[]}
---@field requiredLevel integer int
---@field questLevel integer int
---@field requiredRaces integer bitmask
---@field requiredClasses integer bitmask
---@field objectivesText integer table {string, ...}
---@field triggerEnd integer table {text, {[zoneID] = {coordPair, ...}, ...}}
---@field objectives integer table {creatureObjective, objectObjective, itemObjective, reputationObjective, killCreditObjective, spellObjective}
---@field sourceItemId integer int, item provided by quest starter
---@field preQuestGroup integer table {QuestId, ...}, all required
---@field preQuestSingle integer table {QuestId, ...}, one required
---@field childQuests integer table {QuestId, ...}
---@field inGroupWith integer table {QuestId, ...}
---@field exclusiveTo integer table {QuestId, ...}
---@field zoneOrSort integer int, >0 AreaTable ID, <0 QuestSort ID
---@field requiredSkill integer table {skill, value}
---@field requiredMinRep integer table {faction, value}
---@field requiredMaxRep integer table {faction, value}
---@field requiredSourceItems integer table {ItemId, ...}
---@field nextQuestInChain integer int
---@field questFlags integer bitmask
---@field specialFlags integer bitmask, 1 = repeatable
---@field parentQuest integer int
---@field reputationReward integer table {{faction, value}, ...}
---@field breadcrumbForQuestId integer int
---@field breadcrumbs integer table {QuestId, ...}
---@field extraObjectives integer table {{spawnlist, iconFile, text, objectiveIndex?, {{dbReferenceType, id}, ...}?}, ...}
---@field requiredSpell integer int, negative means the spell must be unknown
---@field requiredSpecialization integer int
---@field requiredMaxLevel integer int
---@field availableUntilCompleted integer int
---@field availableStartingWith integer int
---@field requiredRanks integer table {{skill, value}, ...}
---@field disabledByQuest integer int
QuestieDB.questKeys = LibQuestieDB.Meta.QuestMeta.questKeys

-- Field names in Database Key Enum order. Rich projections request every field through
-- `QueryQuest(id, QuestieDB._questAdapterQueryOrder)`, so the packed result lines up with `questKeys`.
---@type string[]
QuestieDB._questAdapterQueryOrder = {}
for key, index in pairs(QuestieDB.questKeys) do
    QuestieDB._questAdapterQueryOrder[index] = key
end
