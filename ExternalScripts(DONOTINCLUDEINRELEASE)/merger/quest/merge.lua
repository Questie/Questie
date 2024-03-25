local trinity =  require('cataQuestDB-trinity')
local mangos = require('cataQuestDB')

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

for npcId, data in pairs(trinity) do
    local quest = mangos[npcId]

    -- get spawns from trinity and add them to mangos
    if quest and quest[questKeys.questLevel] then
        if not data[questKeys.startedBy] then
            data[questKeys.startedBy] = quest[questKeys.startedBy]
        end
        if not data[questKeys.finishedBy] then
            data[questKeys.finishedBy] = quest[questKeys.finishedBy]
        end
        data[questKeys.requiredLevel] = quest[questKeys.requiredLevel]
        data[questKeys.questLevel] = quest[questKeys.questLevel]
        data[questKeys.questFlags] = quest[questKeys.questFlags]
    end
end

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

local function printObjective(objectives)
    local printString = "{"
    for i, creature in ipairs(objectives) do
        if objectives[1][i+1] then
            printString = printString .. "{" .. creature[1]
            if creature[2] then
                printString = printString .. ",'" .. creature[2]:gsub("\"", "\\\"")
            end
            printString = printString .. "},"
        else
            printString = printString .. "{" .. creature[1]
            if creature[2] then
                printString = printString .. ",'" .. creature[2]:gsub("\"", "\\\"")
            end
            printString = printString .. "},"
        end
    end
    printString = printString:sub(1, -2) -- remove trailing comma
    printString = printString .. "},"
    return printString
end

-- print to "merged-file.lua"
local file = io.open("merged-file.lua", "w")
print("writing to merged-file.lua")
for questId, data in pairsByKeys(trinity) do
    print("questId: " .. questId)
    -- build print string with npcId and data
    local printString = "[" .. questId .. "] = {"
    printString = printString .. "\"" .. data[questKeys.name]:gsub("\"", "\\\"") .. "\","
    if data[questKeys.startedBy] then
        printString = printString .. "{"
        local starter = data[questKeys.startedBy]
        if starter[1] then
            printString = printString .. "{"
            for i, npcId in ipairs(starter[1]) do
                printString = printString .. npcId .. ","
            end
            printString = printString:sub(1, -2) -- remove trailing comma
            printString = printString .. "},"
        else
            printString = printString .. "nil,"
        end
        if starter[2] then
            printString = printString .. "{"
            for i, objId in ipairs(starter[2]) do
                printString = printString .. objId .. ","
            end
            printString = printString:sub(1, -2) -- remove trailing comma
            printString = printString .. "},"
        end
        if starter[3] then
            printString = printString .. "{"
            for i, itemId in ipairs(starter[3]) do
                printString = printString .. itemId .. ","
            end
            printString = printString:sub(1, -2) -- remove trailing comma
            printString = printString .. "},"
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.finishedBy] then
        printString = printString .. "{"
        local finisher = data[questKeys.finishedBy]
        if finisher[1] then
            printString = printString .. "{"
            for i, npcId in ipairs(finisher[1]) do
                printString = printString .. npcId .. ","
            end
            printString = printString:sub(1, -2) -- remove trailing comma
            printString = printString .. "},"
        else
            printString = printString .. "nil,"
        end
        if finisher[2] then
            printString = printString .. "{"
            for i, objId in ipairs(finisher[2]) do
                printString = printString .. objId .. ","
            end
            printString = printString:sub(1, -2) -- remove trailing comma
            printString = printString .. "},"
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    printString = printString .. data[questKeys.requiredLevel] .. ","
    printString = printString .. data[questKeys.questLevel] .. ","
    printString = printString .. data[questKeys.requiredRaces] .. ","
    printString = printString .. (data[questKeys.requiredClasses]  or "nil") .. ","
    if data[questKeys.objectivesText] then
        printString = printString .. "{"
        for i, text in ipairs(data[questKeys.objectivesText]) do
            printString = printString .. "\"" .. text:gsub("\"", "\\\""):gsub("\n\n", "") .. "\","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.triggerEnd] then
        printString = printString .. "{\"" .. data[questKeys.triggerEnd][1]:gsub("\"", "\\\""):gsub("\n\n", " ") .. "\","
        if data[questKeys.triggerEnd][2] then
            printString = printString .. "{"
            for zoneID, coords in pairs(data[questKeys.triggerEnd][2]) do
                printString = printString .. "[" .. zoneID .. "]={"
                for i, coord in ipairs(coords) do
                    if coords[i+1] then
                        if coord[3] then
                            printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "," .. coord[3] .. "},"
                        else
                            printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "},"
                        end
                    else
                        if coord[3] then
                            printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "," .. coord[3] .. "}"
                        else
                            printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "}"
                        end
                    end
                end
                printString = printString .. "},"
            end
            printString = printString:sub(1, -2) -- remove trailing comma
            printString = printString .. "},"
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.objectives] then
        printString = printString .. "{"
        local objectives = data[questKeys.objectives]
        if objectives[1] then
            printString = printString .. printObjective(objectives[1])
        else
            printString = printString .. "nil,"
        end
        if objectives[2] then
            printString = printString .. printObjective(objectives[2])
        else
            printString = printString .. "nil,"
        end
        if objectives[3] then
            printString = printString .. printObjective(objectives[3])
        else
            printString = printString .. "nil,"
        end
        if objectives[4] then
            printString = printString .. "{" .. objectives[4][1] .. "," .. objectives[4][2] .. "},"
        else
            printString = printString .. "nil,"
        end
        if objectives[5] then
            printString = printString .. "{"
            local killCreditObjective = objectives[5]
            for _, entry in ipairs(killCreditObjective) do
                printString = printString .. "{{"
                for i, creature in ipairs(entry[1]) do
                    if i == #entry[1] then
                        printString = printString .. creature
                    else
                        printString = printString .. creature .. ","
                    end
                end
                printString = printString .. "},"
                printString = printString .. entry[2]
                if entry[3] then
                    printString = printString .. "," .. entry[3]
                end
                printString = printString .. "},"
            end
            printString = printString .. "},"
        end
        if objectives[6] then
            printString = printString .. printObjective(objectives[6])
        end
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    printString = printString .. (data[questKeys.sourceItemId] or "nil") .. ","
    if data[questKeys.preQuestGroup] then
        printString = printString .. "{"
        for i, questID in ipairs(data[questKeys.preQuestGroup]) do
            printString = printString .. questID .. ","
        end
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.preQuestSingle] then
        printString = printString .. "{"
        for i, questID in ipairs(data[questKeys.preQuestSingle]) do
            printString = printString .. questID .. ","
        end
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.childQuests] then
        printString = printString .. "{"
        for i, questID in ipairs(data[questKeys.childQuests]) do
            printString = printString .. questID .. ","
        end
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.inGroupWith] then
        printString = printString .. "{"
        for i, questID in ipairs(data[questKeys.inGroupWith]) do
            printString = printString .. questID .. ","
        end
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.exclusiveTo] then
        printString = printString .. "{"
        for i, questID in ipairs(data[questKeys.exclusiveTo]) do
            printString = printString .. questID .. ","
        end
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    printString = printString .. (data[questKeys.zoneOrSort] or "0") .. ","
    if data[questKeys.requiredSkill] then
        printString = printString .. "{" .. data[questKeys.requiredSkill][1] .. "," .. data[questKeys.requiredSkill][2] .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.requiredMinRep] then
        printString = printString .. "{" .. data[questKeys.requiredMinRep][1] .. "," .. data[questKeys.requiredMinRep][2] .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.requiredMaxRep] then
        printString = printString .. "{" .. data[questKeys.requiredMaxRep][1] .. "," .. data[questKeys.requiredMaxRep][2] .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[questKeys.requiredSourceItems] then
        printString = printString .. "{"
        for i, itemID in ipairs(data[questKeys.requiredSourceItems]) do
            printString = printString .. itemID .. ","
        end
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    printString = printString .. (data[questKeys.nextQuestInChain] or "nil") .. ","
    printString = printString .. (data[questKeys.questFlags] or "nil") .. ","
    printString = printString .. (data[questKeys.specialFlags] or "nil") .. ","
    printString = printString .. (data[questKeys.parentQuest] or "nil") .. ","
    if data[questKeys.reputationReward] then
        printString = printString .. "{"
        for i, rep in ipairs(data[questKeys.reputationReward]) do
            printString = printString .. "{" .. rep[1] .. "," .. rep[2] .. "},"
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    printString = printString .. "nil,"
    printString = printString .. (data[questKeys.requiredSpell] or "nil") .. ","
    printString = printString .. (data[questKeys.requiredSpecialization] or "nil") .. ","
    printString = printString .. (data[questKeys.requiredMaxLevel] or "nil")
    printString = printString .. "},"
    file:write(printString .. "\n")
end
print("Done")
