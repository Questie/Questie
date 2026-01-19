QuestieDB = {}
QuestieLoader = {}
function QuestieLoader:ImportModule() return QuestieDB end

dofile("data/tbcQuestDB.lua")
local tbc = require("data.tbcQuestDB")
local corrections = require("data.tbc_corrections")

local printToFile = require("printToFile")

local questKeys = {
    ["name"] = 1, -- string
    ["startedBy"] = 2, -- table
    --['creatureStart'] = 1, -- table {creature(int),...}
    --['objectStart'] = 2, -- table {object(int),...}
    --['itemStart'] = 3, -- table {item(int),...}
    ["finishedBy"] = 3, -- table
    --['creatureEnd'] = 1, -- table {creature(int),...}
    --['objectEnd'] = 2, -- table {object(int),...}
    ["requiredLevel"] = 4, -- int
    ["questLevel"] = 5, -- int
    ["requiredRaces"] = 6, -- bitmask
    ["requiredClasses"] = 7, -- bitmask
    ["objectivesText"] = 8, -- table: {string,...}, Description of the quest. Auto-complete if nil.
    ["triggerEnd"] = 9, -- table: {text, {[zoneID] = {coordPair,...},...}}
    ["objectives"] = 10, -- table
    --['creatureObjective'] = 1, -- table {{creature(int), text(string)},...}, If text is nil the default "<Name> slain x/y" is used
    --['objectObjective'] = 2, -- table {{object(int), text(string)},...}
    --['itemObjective'] = 3, -- table {{item(int), text(string)},...}
    --['reputationObjective'] = 4, -- table: {faction(int), value(int)}
    --['killCreditObjective'] = 5, -- table: {{creature(int), ...}, baseCreatureID, baseCreatureText}
    --['spellObjective'] = 6, -- table: {{spell(int), text(string)},...}
    ["sourceItemId"] = 11, -- int, item provided by quest starter
    ["preQuestGroup"] = 12, -- table: {quest(int)}
    ["preQuestSingle"] = 13, -- table: {quest(int)}
    ["childQuests"] = 14, -- table: {quest(int)}
    ["inGroupWith"] = 15, -- table: {quest(int)}
    ["exclusiveTo"] = 16, -- table: {quest(int)}
    ["zoneOrSort"] = 17, -- int, >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
    ["requiredSkill"] = 18, -- table: {skill(int), value(int)}
    ["requiredMinRep"] = 19, -- table: {faction(int), value(int)}
    ["requiredMaxRep"] = 20, -- table: {faction(int), value(int)}
    ["requiredSourceItems"] = 21, -- table: {item(int), ...} Items that are not an objective but still needed for the quest.
    ["nextQuestInChain"] = 22, -- int: if this quest is active/finished, the current quest is not available anymore
    ["questFlags"] = 23, -- bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
    ["specialFlags"] = 24, -- bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
    ["parentQuest"] = 25, -- int, the ID of the parent quest that needs to be active for the current one to be available. See also 'childQuests' (field 14)
    ["reputationReward"] = 26, -- table: {{FACTION,VALUE}, ...}, A list of reputation reward for factions
    ["extraObjectives"] = 27, -- table: {{spawnlist, iconFile, text, objectiveIndex (optional), {{dbReferenceType, id}, ...} (optional)},...}, a list of hidden special objectives for a quest. Similar to requiredSourceItems
    ["requiredSpell"] = 28, -- int: quest is only available if character has this spellID
    ["requiredSpecialization"] = 29, -- int: quest is only available if character meets the spec requirements. Use QuestieProfessions.specializationKeys for having a spec, or QuestieProfessions.professionKeys to indicate having the profession with no spec. See QuestieProfessions.lua for more info.
    ["requiredMaxLevel"] = 30, -- int: quest is only available up to a certain level
}

for questId, data in pairs(tbc) do
    local quest = corrections[questId]

    if quest then
        if not data[questKeys.startedBy] then
            data[questKeys.startedBy] = quest[questKeys.startedBy]
        end
        if not data[questKeys.finishedBy] then
            data[questKeys.finishedBy] = quest[questKeys.finishedBy]
        end
        if (not data[questKeys.requiredLevel]) or data[questKeys.requiredLevel] == 0 then
            data[questKeys.requiredLevel] = quest[questKeys.requiredLevel]
        end
        if (not data[questKeys.questLevel]) or data[questKeys.questLevel] == 0 then
            data[questKeys.questLevel] = quest[questKeys.questLevel]
        end
        if ((not data[questKeys.requiredRaces]) or data[questKeys.requiredRaces] == 0) and quest[questKeys.requiredRaces] ~= 0 then
            data[questKeys.requiredRaces] = quest[questKeys.requiredRaces]
        end
        if ((not data[questKeys.requiredClasses]) or data[questKeys.requiredClasses] == 0) and quest[questKeys.requiredClasses] ~= 0 then
            data[questKeys.requiredClasses] = quest[questKeys.requiredClasses]
        end
    end
end

printToFile(tbc, questKeys)
