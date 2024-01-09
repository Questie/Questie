---@class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");


QuestieDB.questKeys = {
    ['name'] = 1, -- string
    ['startedBy'] = 2, -- table
        --['creatureStart'] = 1, -- table {creature(int),...}
        --['objectStart'] = 2, -- table {object(int),...}
        --['itemStart'] = 3, -- table {item(int),...}
    ['finishedBy'] = 3, -- table
        --['creatureEnd'] = 1, -- table {creature(int),...}
        --['objectEnd'] = 2, -- table {object(int),...}
    ['requiredLevel'] = 4, -- int
    ['questLevel'] = 5, -- int
    ['requiredRaces'] = 6, -- bitmask
    ['requiredClasses'] = 7, -- bitmask
    ['objectivesText'] = 8, -- table: {string,...}, Description of the quest. Auto-complete if nil.
    ['triggerEnd'] = 9, -- table: {text, {[zoneID] = {coordPair,...},...}}
    ['objectives'] = 10, -- table
        --['creatureObjective'] = 1, -- table {{creature(int), text(string)},...}, If text is nil the default "<Name> slain x/y" is used
        --['objectObjective'] = 2, -- table {{object(int), text(string)},...}
        --['itemObjective'] = 3, -- table {{item(int), text(string)},...}
        --['reputationObjective'] = 4, -- table: {faction(int), value(int)}
        --['killCreditObjective'] = 5, -- table: {{creature(int), ...}, baseCreatureID, baseCreatureText}
        --['spellObjective'] = 6, -- table: {{spell(int), text(string)},...}
    ['sourceItemId'] = 11, -- int, item provided by quest starter
    ['preQuestGroup'] = 12, -- table: {quest(int)}
    ['preQuestSingle'] = 13, -- table: {quest(int)}
    ['childQuests'] = 14, -- table: {quest(int)}
    ['inGroupWith'] = 15, -- table: {quest(int)}
    ['exclusiveTo'] = 16, -- table: {quest(int)}
    ['zoneOrSort'] = 17, -- int, >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
    ['requiredSkill'] = 18, -- table: {skill(int), value(int)}
    ['requiredMinRep'] = 19, -- table: {faction(int), value(int)}
    ['requiredMaxRep'] = 20, -- table: {faction(int), value(int)}
    ['requiredSourceItems'] = 21, -- table: {item(int), ...} Items that are not an objective but still needed for the quest.
    ['nextQuestInChain'] = 22, -- int: if this quest is active/finished, the current quest is not available anymore
    ['questFlags'] = 23, -- bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
    ['specialFlags'] = 24, -- bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
    ['parentQuest'] = 25, -- int, the ID of the parent quest that needs to be active for the current one to be available. See also 'childQuests' (field 14)
    ['reputationReward'] = 26, -- table: {{FACTION,VALUE}, ...}, A list of reputation reward for factions
    ['extraObjectives'] = 27, -- table: {{spawnlist, iconFile, text, objectiveIndex (optional), {{dbReferenceType, id}, ...} (optional)},...}, a list of hidden special objectives for a quest. Similar to requiredSourceItems
    ['requiredSpell'] = 28, -- int: quest is only available if character has this spellID
    ['requiredSpecialization'] = 29, -- int: quest is only available if character meets the spec requirements. Use QuestieProfessions.specializationKeys for having a spec, or QuestieProfessions.professionKeys to indicate having the profession with no spec. See QuestieProfessions.lua for more info.
    ['requiredMaxLevel'] = 30, -- int: quest is only available up to a certain level
}

QuestieDB.questKeysReversed = {}
for key, id in pairs(QuestieDB.questKeys) do
    QuestieDB.questKeysReversed[id] = key
end

QuestieDB.questCompilerTypes = {
    ['name'] = "u8string", -- string
    ['startedBy'] = "questgivers", -- table
    ['finishedBy'] = "questgivers", -- table
    ['requiredLevel'] = "u8", -- int
    ['questLevel'] = "s16", -- int
    ['requiredRaces'] = "u16", -- bitmask
    ['requiredClasses'] = "u16", -- bitmask
    ['objectivesText'] = "u8u16stringarray", -- table: {string,...}, Description of the quest. Auto-complete if nil.
    ['triggerEnd'] = "trigger", -- table: {text, {[zoneID] = {coordPair,...},...}}
    ['objectives'] = "objectives", -- table
    ['sourceItemId'] = "u24", -- int, item provided by quest starter
    ['preQuestGroup'] = "u8u24array", -- table: {quest(int)}
    ['preQuestSingle'] = "u8u24array", -- table: {quest(int)}
    ['childQuests'] = "u8u24array", -- table: {quest(int)}
    ['inGroupWith'] = "u8u24array", -- table: {quest(int)}
    ['exclusiveTo'] = "u8u24array", -- table: {quest(int)}
    ['zoneOrSort'] = "s16", -- int, >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
    ['requiredSkill'] = "u12pair", -- table: {skill(int), value(int)}
    ['requiredMinRep'] = "s24pair", -- table: {faction(int), value(int)}
    ['requiredMaxRep'] = "s24pair", -- table: {faction(int), value(int)}
    ['requiredSourceItems'] = "u8u24array", -- table: {item(int), ...} Items that are not an objective but still needed for the quest.
    ['nextQuestInChain'] = "u24", -- int: if this quest is active/finished, the current quest is not available anymore
    ['questFlags'] = "u24", -- bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
    ['specialFlags'] = "u16", -- bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
    ['parentQuest'] = "u24", -- int, the ID of the parent quest that needs to be active for the current one to be available. See also 'childQuests' (field 14)
    ['reputationReward'] = "u8s24pairs",
    ['extraObjectives'] = "extraobjectives",
    ['requiredSpell'] = "s24",
    ['requiredSpecialization'] = "u24",
    ['requiredMaxLevel'] = "u8",
}

QuestieDB.questCompilerOrder = { -- order easily skipable data first for efficiency
    --static size
    'requiredLevel', 'questLevel', 'requiredRaces', 'requiredClasses', 'sourceItemId', 'zoneOrSort', 'requiredSkill',
    'requiredMinRep', 'requiredMaxRep', 'nextQuestInChain', 'questFlags', 'specialFlags', 'parentQuest', 'requiredSpell',
    'requiredSpecialization', 'requiredMaxLevel',

    -- variable size
    'name', 'preQuestGroup', 'preQuestSingle', 'childQuests', 'inGroupWith', 'exclusiveTo', 'requiredSourceItems',
    'objectivesText', 'triggerEnd', 'startedBy', 'finishedBy', 'objectives', 'reputationReward', 'extraObjectives'
}

QuestieDB.questFlags = {
    NONE = 0,
    STAY_ALIVE = 1,
    PARTY_ACCEPT = 2,
    EXPLORATION = 4,
    SHARABLE = 8,
    UNUSED1 = 16,
    EPIC = 32,
    RAID = 64,
    UNUSED2 = 128,
    UNKNOWN = 256,
    HIDDEN_REWARDS = 512,
    AUTO_REWARDED = 1024,
    DAILY = 4096,
    WEEKLY = 32768,
}

QuestieDB.factionIDs = {
    UNDERCITY = 68,
    DARNASSUS = 69,
    DARKMOON_FAIRE = 909,
    EXODAR = 930,
    THE_KALUAK = 1073,
    KIRIN_TOR = 1090,
}

-- temporary, until we remove the old db funcitons
QuestieDB._questAdapterQueryOrder = {}
for key, id in pairs(QuestieDB.questKeys) do
    QuestieDB._questAdapterQueryOrder[id] = key
end
