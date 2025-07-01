local lfs = require("lfs")
local pairsByKeys = dofile("../pairsByKeys.lua")

local function printObjective(objectives)
    local printString = "{"
    for i, creature in ipairs(objectives) do
        if objectives[1][i+1] then
            printString = printString .. "{" .. creature[1]
            if creature[2] then
                printString = printString .. ",\"" .. creature[2]:gsub("\"", "\\\"") .. "\""
            end
            printString = printString .. "},"
        else
            printString = printString .. "{" .. creature[1]
            if creature[2] then
                printString = printString .. ",\"" .. creature[2]:gsub("\"", "\\\"") .. "\""
            end
            printString = printString .. "},"
        end
    end
    printString = printString:sub(1, -2) -- remove trailing comma
    printString = printString .. "},"
    return printString
end

local function printToFile(questData, questKeys)
    lfs.mkdir("output")

    local file = io.open("output/merged-file.lua", "w")
    print("writing to output/merged-file.lua")

    for questId, data in pairsByKeys(questData) do
        --print("questId: " .. questId)
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
            elseif starter[3] then
                printString = printString .. "nil,"
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
                        printString = printString .. "," .. "\"" .. entry[3]:gsub("\"", "\\\"") .. "\""
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
        printString = printString .. (data[questKeys.breadcrumbForQuestId] or "nil")..","
        if data[questKeys.breadcrumbs] then
            printString = printString .. "{"
            for i, questID in ipairs(data[questKeys.breadcrumbs]) do
                printString = printString .. questID .. ","
            end
            printString = printString .. "},"
        else
            printString = printString .. "nil,"
        end
        printString = printString .. "nil,"
        printString = printString .. (data[questKeys.requiredSpell] or "nil") .. ","
        printString = printString .. (data[questKeys.requiredSpecialization] or "nil") .. ","
        printString = printString .. (data[questKeys.requiredMaxLevel] or "nil")
        printString = printString .. "},"
        -- TODO: replace ,} and ,nil} and so on with }
        -- Do we really want this?
        --while printString:sub(-6) == ",nil}," do
        --    printString = printString:sub(1, -7) .. "},"
        --end

        file:write(printString .. "\n")
    end
    print("Done")
end

return printToFile
