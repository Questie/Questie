local trinity =  require('data.cataQuestDB-trinity')
local mangos = require('data.cataQuestDB')
local tbc = require('data.tbcQuestDB')
local wotlk = require('data.wotlkQuestDB')

local printToFile = require('printToFile')

local questKeys = {
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
    ['breadcrumbForQuestId'] = 27, -- int: quest ID for the quest this optional breadcrumb quest leads to
    ['breadcrumbs'] = 28, -- table: {questID(int), ...} quest IDs of the breadcrumbs that lead to this quest
    ['extraObjectives'] = 29, -- table: {{spawnlist, iconFile, text, objectiveIndex (optional), {{dbReferenceType, id}, ...} (optional)},...}, a list of hidden special objectives for a quest. Similar to requiredSourceItems
    ['requiredSpell'] = 30, -- int: quest is only available if character has this spellID
    ['requiredSpecialization'] = 31, -- int: quest is only available if character meets the spec requirements. Use QuestieProfessions.specializationKeys for having a spec, or QuestieProfessions.professionKeys to indicate having the profession with no spec. See QuestieProfessions.lua for more info.
    ['requiredMaxLevel'] = 32, -- int: quest is only available up to a certain level
}

for questId, data in pairs(trinity) do
    local quest = mangos[questId]

    -- get spawns from trinity and add them to mangos
    if quest and quest[questKeys.questLevel] then
        if not data[questKeys.startedBy] then
            data[questKeys.startedBy] = quest[questKeys.startedBy]
        --TODO: add items to startedBy once that is really required. Questie doesn't use it yet.
        --elseif (not data[questKeys.startedBy][3]) and quest[questKeys.startedBy] and quest[questKeys.startedBy][3] then
        --    data[questKeys.startedBy][3] = quest[questKeys.startedBy][3]
        end
        if not data[questKeys.finishedBy] then
            data[questKeys.finishedBy] = quest[questKeys.finishedBy]
        end
        data[questKeys.name] = quest[questKeys.name]
        data[questKeys.objectivesText] = quest[questKeys.objectivesText]
        data[questKeys.requiredLevel] = quest[questKeys.requiredLevel]
        data[questKeys.questLevel] = quest[questKeys.questLevel]
        data[questKeys.preQuestSingle] = quest[questKeys.preQuestSingle]
        data[questKeys.preQuestGroup] = quest[questKeys.preQuestGroup]
        data[questKeys.questFlags] = quest[questKeys.questFlags]
        data[questKeys.childQuests] = quest[questKeys.childQuests]
        data[questKeys.parentQuest] = quest[questKeys.parentQuest]
    end
end

for questId, data in pairs(tbc) do
    local quest = trinity[questId]

    if quest then
        if not quest[questKeys.objectives] and data[questKeys.objectives] then
            print("Adding TBC objectives to quest " .. questId)
            quest[questKeys.objectives] = data[questKeys.objectives]
        end
    end
end

for questId, data in pairs(wotlk) do
    local quest = trinity[questId]

    if quest then
        if not quest[questKeys.objectives] and data[questKeys.objectives] then
            print("Adding WotLK objectives to quest " .. questId)
            quest[questKeys.objectives] = data[questKeys.objectives]
        end
        if not quest[questKeys.preQuestSingle] and data[questKeys.preQuestSingle] then
            print("Adding WotLK preQuestSingle to quest " .. questId)
            quest[questKeys.preQuestSingle] = data[questKeys.preQuestSingle]
        end
        if not quest[questKeys.preQuestGroup] and data[questKeys.preQuestGroup] then
            print("Adding WotLK preQuestGroup to quest " .. questId)
            quest[questKeys.preQuestGroup] = data[questKeys.preQuestGroup]
        end
        if not quest[questKeys.requiredSourceItems] and data[questKeys.requiredSourceItems] then
            print("Adding WotLK requiredSourceItems to quest " .. questId)
            quest[questKeys.requiredSourceItems] = data[questKeys.requiredSourceItems]
        end
        if (not quest[questKeys.nextQuestInChain] or quest[questKeys.nextQuestInChain] == 0) and data[questKeys.nextQuestInChain] then
            print("Adding WotLK nextQuestInChain to quest " .. questId)
            quest[questKeys.nextQuestInChain] = data[questKeys.nextQuestInChain]
        end
        if not quest[questKeys.childQuests] and data[questKeys.childQuests] then
            print("Adding WotLK childQuests to quest " .. questId)
            quest[questKeys.childQuests] = data[questKeys.childQuests]
        end
        if (not quest[questKeys.parentQuest] or quest[questKeys.parentQuest] == 0) and data[questKeys.parentQuest] then
            print("Adding WotLK parentQuest to quest " .. questId)
            quest[questKeys.parentQuest] = data[questKeys.parentQuest]
        end
    end
end

printToFile(trinity, questKeys)
