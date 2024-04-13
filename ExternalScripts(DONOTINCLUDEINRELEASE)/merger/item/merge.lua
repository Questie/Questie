local mangos =  require('cataItemDB')
local trinity =  require('cataItemDB-trinity')
local wotlkQuestDB =  require('wotlkQuestDB')
local wotlkItemDB =  require('wotlkItemDB')

local itemKeys = {
    ['name'] = 1, -- string
    ['npcDrops'] = 2, -- table or nil, NPC IDs
    ['objectDrops'] = 3, -- table or nil, object IDs
    ['itemDrops'] = 4, -- table or nil, item IDs
    ['startQuest'] = 5, -- int or nil, ID of the quest started by this item
    ['questRewards'] = 6, -- table or nil, quest IDs
    ['flags'] = 7, -- int or nil, see: https://github.com/cmangos/issues/wiki/Item_template#flags
    ['foodType'] = 8, -- int or nil, see https://github.com/cmangos/issues/wiki/Item_template#foodtype
    ['itemLevel'] = 9, -- int, the level of this item
    ['requiredLevel'] = 10, -- int, the level required to equip/use this item
    ['ammoType'] = 11, -- int,
    ['class'] = 12, -- int,
    ['subClass'] = 13, -- int,
    ['vendors'] = 14, -- table or nil, NPC IDs
    ['relatedQuests'] = 15, -- table or nil, IDs of quests that are related to this item
}
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
    --['spellObjective'] = 6, -- table: {{spell(int), text(string), item(int)},...}
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

local function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

--for questId, questData in pairsByKeys(wotlkQuestDB) do
--    local objectives = questData[questKeys.objectives]
--    if objectives and objectives[3] then
--        for _, itemObjective in ipairs(objectives[3]) do
--            local itemId = itemObjective[1]
--            if trinity[itemId] then
--                if wotlkItemDB[itemId][itemKeys.npcDrops] then
--                    trinity[itemId][itemKeys.npcDrops] = wotlkItemDB[itemId][itemKeys.npcDrops]
--                end
--                if wotlkItemDB[itemId][itemKeys.objectDrops] then
--                    trinity[itemId][itemKeys.objectDrops] = wotlkItemDB[itemId][itemKeys.objectDrops]
--                end
--                if wotlkItemDB[itemId][itemKeys.itemDrops] then
--                    trinity[itemId][itemKeys.itemDrops] = wotlkItemDB[itemId][itemKeys.itemDrops]
--                end
--                if wotlkItemDB[itemId][itemKeys.vendors] then
--                    trinity[itemId][itemKeys.vendors] = wotlkItemDB[itemId][itemKeys.vendors]
--                end
--            end
--        end
--    end
--end

for itemId, data in pairsByKeys(mangos) do
    if mangos[itemId] then
        if trinity[itemId][itemKeys.npcDrops] then
            mangos[itemId][itemKeys.npcDrops] = trinity[itemId][itemKeys.npcDrops]
        end
        if trinity[itemId][itemKeys.objectDrops] then
            mangos[itemId][itemKeys.objectDrops] = trinity[itemId][itemKeys.objectDrops]
        end
        if trinity[itemId][itemKeys.itemDrops] then
            mangos[itemId][itemKeys.itemDrops] = trinity[itemId][itemKeys.itemDrops]
        end
        if trinity[itemId][itemKeys.vendors] then
            mangos[itemId][itemKeys.vendors] = trinity[itemId][itemKeys.vendors]
        end
    end
end


-- print to "merged-file.lua"
local file = io.open("merged-file.lua", "w")
print("writing to merged-file.lua")
for itemId, data in pairsByKeys(mangos) do
    -- build print string with npcId and data
    local printString = "[" .. itemId .. "] = {"
    printString = printString .. "'" .. data[itemKeys.name]:gsub("'", "\\'") .. "',"
    if data[itemKeys.npcDrops] then
        printString = printString .. "{"
        for _, npcId in ipairs(data[itemKeys.npcDrops]) do
            printString = printString .. npcId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.objectDrops] then
        printString = printString .. "{"
        for _, objectId in ipairs(data[itemKeys.objectDrops]) do
            printString = printString .. objectId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.itemDrops] then
        printString = printString .. "{"
        for _, itemId in ipairs(data[itemKeys.itemDrops]) do
            printString = printString .. itemId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.startQuest] then
        printString = printString .. data[itemKeys.startQuest] .. ","
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.questRewards] then
        printString = printString .. "{"
        for _, questId in ipairs(data[itemKeys.questRewards]) do
            printString = printString .. questId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.flags] then
        printString = printString .. data[itemKeys.flags] .. ","
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.foodType] then
        printString = printString .. data[itemKeys.foodType] .. ","
    else
        printString = printString .. "nil,"
    end
    printString = printString .. data[itemKeys.itemLevel] .. ","
    printString = printString .. data[itemKeys.requiredLevel] .. ","
    printString = printString .. data[itemKeys.ammoType] .. ","
    printString = printString .. data[itemKeys.class] .. ","
    printString = printString .. data[itemKeys.subClass] .. ","
    if data[itemKeys.vendors] then
        printString = printString .. "{"
        for _, npcId in ipairs(data[itemKeys.vendors]) do
            printString = printString .. npcId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.relatedQuests] then
        printString = printString .. "{"
        for _, questId in ipairs(data[itemKeys.relatedQuests]) do
            printString = printString .. questId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    -- remove trailing 'nil,' from relatedQuests
    if printString:sub(-4) == "nil," then
        printString = printString:sub(1, -5)
    end
    -- remove trailing 'nil,' from vendors
    if printString:sub(-4) == "nil," then
        printString = printString:sub(1, -5)
    end
    -- remove trailing comma
    printString = printString:sub(1, -2)
    printString = printString .. "},"

    file:write(printString .. "\n")
end
print("Done")
