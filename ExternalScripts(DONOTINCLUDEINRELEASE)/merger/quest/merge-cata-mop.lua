local cata = require('data.cataQuestDB')
local mop = require('data.mopQuestDB')
local mopTrinity = require('data.mopQuestDB-trinity')

local printToFile = require('printToFile')

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

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
    ['extraObjectives'] = 27, -- table: {{spawnlist, iconFile, text, objectiveIndex (optional), {{dbReferenceType, id}, ...} (optional)},...}, a list of hidden special objectives for a quest. Similar to requiredSourceItems
    ['requiredSpell'] = 28, -- int: quest is only available if character has this spellID
    ['requiredSpecialization'] = 29, -- int: quest is only available if character meets the spec requirements. Use QuestieProfessions.specializationKeys for having a spec, or QuestieProfessions.professionKeys to indicate having the profession with no spec. See QuestieProfessions.lua for more info.
    ['requiredMaxLevel'] = 30, -- int: quest is only available up to a certain level
}

for questId, data in pairs(mop) do
    local cataQuest = cata[questId]
    local trinityQuest = mopTrinity[questId]

    if cataQuest then
        mop[questId] = cataQuest
        mop[questId][questKeys.requiredRaces] = data[questKeys.requiredRaces] -- Rollback requiredRaces change, because cata data is incorrect for sure.

        -- Only take race and class requirements from MoP for cata quests, because Pandaren and Monks were added.
        if mop[questId][questKeys.requiredRaces] == 0 and trinityQuest and trinityQuest[questKeys.requiredRaces] ~= 0 then
            mop[questId][questKeys.requiredRaces] = trinityQuest[questKeys.requiredRaces]
        end
        if data[questKeys.requiredClasses] then
            mop[questId][questKeys.requiredClasses] = data[questKeys.requiredClasses]
        end

        if trinityQuest and trinityQuest[questKeys.objectivesText] and next(trinityQuest[questKeys.objectivesText]) and starts_with(trinityQuest[questKeys.objectivesText][1], "Reach level 3") then
            -- The starting zone quests have been updates for MoP, but that is not reflected in the Skyfire DB. So we take the name and objectivesText from Trinity.
            mop[questId][questKeys.name] = trinityQuest[questKeys.name]
            mop[questId][questKeys.objectivesText] = trinityQuest[questKeys.objectivesText]
        end
    else
        if trinityQuest then
            mop[questId][questKeys.requiredRaces] = trinityQuest[questKeys.requiredRaces] -- Always take Trinity requiredRaces, because it has actual data.
            -- iterate questKeys and take the values from mopTrinity if mop doesn't have them
            for _, index in pairs(questKeys) do
                if not data[index] and trinityQuest[index] and index ~= questKeys.requiredRaces then
                    mop[questId][index] = trinityQuest[index]
                end
            end

            local nextQuestInChain = trinityQuest[questKeys.nextQuestInChain]
            if nextQuestInChain then
                local nextQuest = mop[nextQuestInChain]
                if nextQuest and (not nextQuest[questKeys.preQuestSingle]) and (not nextQuest[questKeys.preQuestGroup]) then
                    -- Quest does not have pre-quest, so we add the current quest as pre-quest.
                    -- This is not 100% correct, but it will be easier to manually fix invalid breadcrumb quests, than adding pre-quests to all quests.
                    mop[nextQuestInChain][questKeys.preQuestSingle] = {questId}
                end
            end
        end

        local nextQuestInChain = data[questKeys.nextQuestInChain]
        if nextQuestInChain then
            local nextQuest = mop[nextQuestInChain]
            local cataNextQuest = cata[nextQuestInChain]
            if nextQuest and (not cataNextQuest) and (not nextQuest[questKeys.preQuestSingle]) and (not nextQuest[questKeys.preQuestGroup]) then
                -- Quest does not have pre-quest, so we add the current quest as pre-quest.
                -- This is not 100% correct, but it will be easier to manually fix invalid breadcrumb quests, than adding pre-quests to all quests.
                mop[nextQuestInChain][questKeys.preQuestSingle] = {questId}
            end
        end
    end
end

-- add trinity quests that are not in Skyfire
for questId, data in pairs(mopTrinity) do
    if (not mop[questId]) then
        mop[questId] = data
    end
end

printToFile(mop, questKeys)
