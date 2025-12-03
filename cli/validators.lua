local Validators = {}

local lfs = require("lfs")

local projectDir = os.getenv("PWD")
local outputDir = projectDir .. "/cli/output"
lfs.mkdir(outputDir)

---@param t1 table<number, number>
---@param t2 table<number, number>
---@return boolean
local function tableContainsAll(t1, t2)
    local t1Set = {}
    for _, v in ipairs(t1) do
        t1Set[v] = true
    end
    for _, v in ipairs(t2) do
        if not t1Set[v] then
            return false
        end
    end
    return true
end

---@param t table<number, any>
---@param f? fun(a: any, b: any): boolean
---@return fun(): number, any
local function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@return table<QuestId, string>
function Validators.checkRequiredSourceItems(quests, questKeys)
    print("\n\27[36mSearching for sourceItemId and itemObjectiveId entries in quest.requiredSourceItems...\27[0m")
    local matchingQuests = {}
    for questId, questData in pairs(quests) do
        local sourceItemId = questData[questKeys.sourceItemId]
        local requiredSourceItems = questData[questKeys.requiredSourceItems]
        if sourceItemId and requiredSourceItems then
            for index = 1, #requiredSourceItems do
                if requiredSourceItems[index] == sourceItemId then
                    matchingQuests[questId] = "sourceItemId in requiredSourceItems: " .. sourceItemId
                    break
                end
            end
        end

        local objectives = questData[questKeys.objectives]
        if requiredSourceItems and objectives and objectives[3] then
            for _, itemObjective in pairs(objectives[3]) do
                for index = 1, #requiredSourceItems do
                    if requiredSourceItems[index] == itemObjective[1] then
                        matchingQuests[questId] = "itemObjectiveId in requiredSourceItems: " .. itemObjective[1]
                        break
                    end
                end
            end
        end
    end

    local count = 0
    for _ in pairs(matchingQuests) do count = count + 1 end

    if count > 0 then
        print("\27[31mFound " .. count .. " quests with sourceItemId or itemObjectiveId in requiredSourceItems:\27[0m")
        for questId, reason in pairs(matchingQuests) do
            print("\27[31m- Quest " .. questId .. " (" .. reason .. ")\27[0m")
        end

        os.exit(1)
        return matchingQuests
    else
        print("\27[32mNo quests found with sourceItemId or itemObjectiveId in requiredSourceItems\27[0m")
        return nil
    end
end

local preQuestExclusions = {
    [30235] = true,
    [30236] = true,
    [30239] = true,
    [30277] = true,
    [30280] = true,
    [30296] = true,
    [30297] = true,
}

---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@return table<QuestId, string>
function Validators.checkPreQuestExclusiveness(quests, questKeys)
    print("\n\27[36mSearching for quests with preQuestSingle and preQuestGroup entries...\27[0m")
    local invalidQuests = {}
    for questId, questData in pairs(quests) do
        local preQuestSingle = questData[questKeys.preQuestSingle]
        local preQuestGroup = questData[questKeys.preQuestGroup]
        if preQuestSingle and next(preQuestSingle) and preQuestGroup and next(preQuestGroup) and (not preQuestExclusions[questId]) then
            invalidQuests[questId] = true
        end
    end

    local count = 0
    for _ in pairs(invalidQuests) do count = count + 1 end

    if count > 0 then
        print("\27[31mFound " .. count .. " quests with both preQuestSingle and preQuestGroup entries:\27[0m")
        for questId, _ in pairs(invalidQuests) do
            print("\27[31m- Quest " .. questId .. "\27[0m")
        end

        os.exit(1)
        return invalidQuests
    else
        print("\27[32mNo quests found with both preQuestSingle and preQuestGroup entries\27[0m")
        return nil
    end
end

---If a quest has a parent quest, then the parent quest must have the child quest in its childQuests list.
---This also must hold vice versa: If a quest has child quests, then each child quest must have the parent quest set.
---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@return table<QuestId, string>
function Validators.checkParentChildQuestRelations(quests, questKeys)
    print("\n\27[36mSearching for parent and child quest relations...\27[0m")
    local invalidQuests = {}
    for questId, questData in pairs(quests) do
        local parentQuestId = questData[questKeys.parentQuest]
        if parentQuestId and parentQuestId > 0 then
            local parentQuest = quests[parentQuestId]

            if (not parentQuest) then
                invalidQuests[questId] = "parent quest " .. parentQuestId .. " is missing/hidden in the database"
            elseif (not parentQuest[questKeys.childQuests]) then
                invalidQuests[parentQuestId] = "quest has no childQuests. " .. questId .. " is listing it as parent quest"
            else
                local found = false
                for _, childQuestId in pairs(parentQuest[questKeys.childQuests]) do
                    if childQuestId == questId then
                        found = true
                        break
                    end
                end

                if (not found) then
                    invalidQuests[parentQuestId] = "quest " .. questId .. " is missing in childQuests list"
                end
            end
        end

        local childQuests = questData[questKeys.childQuests]
        if childQuests then
            for _, childQuestId in pairs(childQuests) do
                local childQuest = quests[childQuestId]
                if (not childQuest) then
                    invalidQuests[childQuestId] = "quest is missing/hidden in the database. parentQuest is " .. questId
                elseif (not childQuest[questKeys.parentQuest]) then
                    invalidQuests[childQuestId] = "quest has no parentQuest. " .. questId .. " is listing it as child quest"
                end
            end
        end
    end

    local count = 0
    for _ in pairs(invalidQuests) do count = count + 1 end

    if count > 0 then
        print("\27[31mFound " .. count .. " quests with invalid parent and child quest relations:\27[0m")
        for questId, reason in pairs(invalidQuests) do
            print("\27[31m- Quest " .. questId .. " (" .. reason .. ")\27[0m")
        end

        os.exit(1)
        return invalidQuests
    else
        print("\27[32mNo quests found with invalid parent and child quest relations\27[0m")
        return nil
    end
end

---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@param npcs table<NpcId, NPC>
---@param npcKeys DatabaseNpcKeys
---@param objects table<ObjectId, Object>
---@param items table<ItemId, Item>
---@return table<QuestId, string>
function Validators.checkQuestStarters(quests, questKeys, npcs, npcKeys, objects, items)
    print("\n\27[36mSearching for quest starters...\27[0m")
    local invalidQuests = {}
    for questId, questData in pairs(quests) do
        local startedBy = questData[questKeys.startedBy]
        if startedBy then
            for _, npcStarter in pairs(startedBy[1] or {}) do
                if not npcs[npcStarter] then
                    invalidQuests[questId] = "NPC starter " .. npcStarter .. " is missing in the database"
                elseif (not npcs[npcStarter][npcKeys.name]) then
                    invalidQuests[questId] = "NPC starter " .. npcStarter .. " has no name"
                end
            end
            for _, objectStarter in pairs(startedBy[2] or {}) do
                if not objects[objectStarter] then
                    invalidQuests[questId] = "Object starter " .. objectStarter .. " is missing in the database"
                end
            end
            for _, itemStarter in pairs(startedBy[3] or {}) do
                if not items[itemStarter] then
                    invalidQuests[questId] = "Item starter " .. itemStarter .. " is missing in the database"
                end
            end
        end
    end

    local count = 0
    for _ in pairs(invalidQuests) do count = count + 1 end

    if count > 0 then
        print("\27[31mFound " .. count .. " quests with invalid quest starters:\27[0m")
        for questId, reason in pairs(invalidQuests) do
            print("\27[31m- Quest " .. questId .. " (" .. reason .. ")\27[0m")
        end

        os.exit(1)
        return invalidQuests
    else
        print("\27[32mNo quests found with invalid quest starters\27[0m")
        return nil
    end
end

---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@param npcs table<NpcId, NPC>
---@param objects table<ObjectId, Object>
---@return table<QuestId, string>
function Validators.checkQuestFinishers(quests, questKeys, npcs, objects)
    print("\n\27[36mSearching for quest finishers...\27[0m")
    local invalidQuests = {}
    for questId, questData in pairs(quests) do
        local finishedBy = questData[questKeys.finishedBy]
        if finishedBy then
            for _, npcFinisher in pairs(finishedBy[1] or {}) do
                if not npcs[npcFinisher] then
                    invalidQuests[questId] = "NPC finisher " .. npcFinisher .. " is missing in the database"
                end
            end
            for _, objectFinisher in pairs(finishedBy[2] or {}) do
                if not objects[objectFinisher] then
                    invalidQuests[questId] = "Object finisher " .. objectFinisher .. " is missing in the database"
                end
            end
        end
    end

    local count = 0
    for _ in pairs(invalidQuests) do count = count + 1 end

    if count > 0 then
        print("\27[31mFound " .. count .. " quests with invalid quest finishers:\27[0m")
        for questId, reason in pairs(invalidQuests) do
            print("\27[31m- Quest " .. questId .. " (" .. reason .. ")\27[0m")
        end

        os.exit(1)
        return invalidQuests
    else
        print("\27[32mNo quests found with invalid quest finishers\27[0m")
        return nil
    end
end

---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@param npcs table<NpcId, NPC>
---@param objects table<ObjectId, Object>
---@param items table<ItemId, Item>
---@return table<QuestId, string>
function Validators.checkObjectives(quests, questKeys, npcs, objects, items)
    print("\n\27[36mSearching for invalid quest objectives...\27[0m")
    local invalidQuests = {}
    for questId, questData in pairs(quests) do
        local objectives = questData[questKeys.objectives]
        if objectives then
            for _, npcObjective in pairs(objectives[1] or {}) do
                local npcId = npcObjective[1]
                if not npcs[npcId] then
                    if not invalidQuests[questId] then
                        invalidQuests[questId] = {}
                    end
                    table.insert(invalidQuests[questId], "NPC objective " .. npcId .. " is missing in the database")
                end
            end
            for _, objectObjective in pairs(objectives[2] or {}) do
                local objectId = objectObjective[1]
                if not objects[objectId] then
                    if not invalidQuests[questId] then
                        invalidQuests[questId] = {}
                    end
                    table.insert(invalidQuests[questId], "Object objective " .. objectId .. " is missing in the database")
                end
            end
            for _, itemObjective in pairs(objectives[3] or {}) do
                local itemId = itemObjective[1]
                if not items[itemId] then
                    if not invalidQuests[questId] then
                        invalidQuests[questId] = {}
                    end
                    table.insert(invalidQuests[questId], "Item objective " .. itemId .. " is missing in the database")
                end
            end
            for _, killCreditObjective in pairs(objectives[5] or {}) do
                for _, npcId in pairs(killCreditObjective[1]) do
                    if not npcs[npcId] then
                        if not invalidQuests[questId] then
                            invalidQuests[questId] = {}
                        end
                        table.insert(invalidQuests[questId], "NPC " .. npcId .. " for killCredit objective is missing in the database")
                    end
                end
            end
        end
    end

    local count = 0
    for _ in pairs(invalidQuests) do count = count + 1 end

    if count > 0 then
        print("\27[31mFound " .. count .. " quests with invalid objectives:\27[0m")
        for questId, reasons in pairs(invalidQuests) do
            print("\27[31m- Quest " .. questId .. ":")
            for _, reason in ipairs(reasons) do
                print("  - " .. reason)
            end
            print("\27[0m")
        end

        os.exit(1)
        return invalidQuests
    else
        print("\27[32mNo quests found with invalid objectives\27[0m")
        return nil
    end
end

---@param npcs table<NpcId, NPC>
---@param npcKeys DatabaseNpcKeys
---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@return table<NpcId, string>, table<NpcId, QuestId[]>
function Validators.checkNpcQuestStarts(npcs, npcKeys, quests, questKeys)
    print("\n\27[36mSearching for invalid questStarts in NPCs...\27[0m")

    local invalidQuestStarts = {}
    local targetQuestStarts = {}
    for questId, questData in pairs(quests) do
        local startedBy = questData[questKeys.startedBy]
        if startedBy then
            for _, npcStarterId in pairs(startedBy[1] or {}) do
                if not targetQuestStarts[npcStarterId] then
                    targetQuestStarts[npcStarterId] = {}
                end
                table.insert(targetQuestStarts[npcStarterId], questId)

                local npcQuestStarters = npcs[npcStarterId][npcKeys.questStarts]

                local starterFound = false
                for _, starterQuestId in pairs(npcQuestStarters or {}) do
                    if starterQuestId == questId then
                        starterFound = true
                        break
                    end
                end

                if (not starterFound) then
                    if not invalidQuestStarts[npcStarterId] then
                        invalidQuestStarts[npcStarterId] = {}
                    end
                    table.insert(invalidQuestStarts[npcStarterId], "quest " .. questId .. " is missing in questStarts")
                end
            end
        end
    end

    for npcId, npcData in pairs(npcs) do
        local questStarts = npcData[npcKeys.questStarts]
        if questStarts then
            for _, questId in ipairs(questStarts) do
                if not quests[questId] then
                    if not invalidQuestStarts[npcId] then
                        invalidQuestStarts[npcId] = {}
                    end
                    table.insert(invalidQuestStarts[npcId], "questStart " .. questId .. " is not in the database")
                    if not targetQuestStarts[npcId] then
                        targetQuestStarts[npcId] = {}
                    end
                else
                    local startedBy = quests[questId][questKeys.startedBy]
                    if startedBy then
                        local startEntryCorrect = false
                        for _, npcStarterId in pairs(startedBy[1] or {}) do
                            if npcStarterId == npcId then
                                startEntryCorrect = true
                                break
                            end
                        end

                        if not startEntryCorrect then
                            if not invalidQuestStarts[npcId] then
                                invalidQuestStarts[npcId] = {}
                            end
                            table.insert(invalidQuestStarts[npcId], "quest " .. questId .. " is not started by this NPC")
                        end
                    end
                end
            end

            -- Check if the NPCs questStarts match with the targetQuestStarts given by the quests.
            -- If they do match, then remove the NPC from targetQuestStarts, otherwise do nothing.
            if targetQuestStarts[npcId] then
                -- TODO: Fix tableContainsAll to correctly compare tables.
                if tableContainsAll(questStarts, targetQuestStarts[npcId]) and tableContainsAll(targetQuestStarts[npcId], questStarts) then
                    -- Remove the NPC from targetQuestStarts, because it matches the questStarts.
                    targetQuestStarts[npcId] = nil
                end
            end
        end
    end

    local count = 0
    for _ in pairs(invalidQuestStarts) do count = count + 1 end

    if count > 0 then
        local correctionFile = io.open(outputDir .. "/npcQuestStartsCorrections.lua", "w")
        if correctionFile then
            correctionFile:write("return {\n")

            print("\27[31mFound " .. count .. " NPCs with invalid questStarts:\27[0m")
            for npcId, reasons in pairsByKeys(invalidQuestStarts) do
                print("\27[31m- NPC " .. npcId .. ":")
                for _, reason in ipairs(reasons) do
                    print("  - " .. reason)
                end
                print("\27[0m")

                table.sort(targetQuestStarts[npcId] or {})
                local correctionString = "[" .. npcId .. "] = { -- " .. npcs[npcId][npcKeys.name] .. "\n            [npcKeys.questStarts] = {" .. table.concat(targetQuestStarts[npcId] or {}, ",") .. "},\n        },"
                correctionFile:write("        " .. correctionString .. "\n")
            end
            correctionFile:write("}\n")
            correctionFile:close()
        end

        os.exit(1)
        return invalidQuestStarts, targetQuestStarts
    else
        print("\27[32mNo NPCs found with invalid questStarts\27[0m")
        return nil, nil
    end
end

---@param npcs table<NpcId, NPC>
---@param npcKeys DatabaseNpcKeys
---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@return table<NpcId, string>, table<NpcId, QuestId[]>
function Validators.checkNpcQuestEnds(npcs, npcKeys, quests, questKeys)
    print("\n\27[36mSearching for invalid questEnds in NPCs...\27[0m")

    local invalidQuestEnds = {}
    local targetQuestEnds = {}
    for questId, questData in pairs(quests) do
        local finishedBy = questData[questKeys.finishedBy]
        if finishedBy then
            for _, npcEnderId in pairs(finishedBy[1] or {}) do
                if not targetQuestEnds[npcEnderId] then
                    targetQuestEnds[npcEnderId] = {}
                end
                table.insert(targetQuestEnds[npcEnderId], questId)

                local npcEnder = npcs[npcEnderId]
                if npcEnder then
                    local npcQuestEnds = npcEnder[npcKeys.questEnds]

                    local enderFound = false
                    for _, enderQuestId in pairs(npcQuestEnds or {}) do
                        if enderQuestId == questId then
                            enderFound = true
                            break
                        end
                    end

                    if (not enderFound) then
                        if not invalidQuestEnds[npcEnderId] then
                            invalidQuestEnds[npcEnderId] = {}
                        end
                        table.insert(invalidQuestEnds[npcEnderId], "quest " .. questId .. " is missing in questEnds")
                    end
                end
            end
        end
    end

    for npcId, npcData in pairs(npcs) do
        local questEnds = npcData[npcKeys.questEnds]
        if questEnds then
            for _, questId in ipairs(questEnds) do
                if not quests[questId] then
                    if not invalidQuestEnds[npcId] then
                        invalidQuestEnds[npcId] = {}
                    end
                    table.insert(invalidQuestEnds[npcId], "questEnd " .. questId .. " is not in the database")
                    if not targetQuestEnds[npcId] then
                        targetQuestEnds[npcId] = {}
                    end
                else
                    local finishedBy = quests[questId][questKeys.finishedBy]
                    if finishedBy then
                        local endEntryCorrect = false
                        for _, npcFinisherId in pairs(finishedBy[1] or {}) do
                            if npcFinisherId == npcId then
                                endEntryCorrect = true
                                break
                            end
                        end

                        if not endEntryCorrect then
                            if not invalidQuestEnds[npcId] then
                                invalidQuestEnds[npcId] = {}
                            end
                            table.insert(invalidQuestEnds[npcId], "quest " .. questId .. " is not finished by this NPC")
                        end
                    end
                end
            end

            -- Check if the NPCs questStarts match with the targetQuestEnds given by the quests.
            -- If they do match, then remove the NPC from targetQuestEnds, otherwise do nothing.
            if targetQuestEnds[npcId] then
                -- TODO: Fix tableContainsAll to correctly compare tables.
                if tableContainsAll(questEnds, targetQuestEnds[npcId]) and tableContainsAll(targetQuestEnds[npcId], questEnds) then
                    -- Remove the NPC from targetQuestEnds, because it matches the questStarts.
                    targetQuestEnds[npcId] = nil
                end
            end
        end
    end

    local count = 0
    for _ in pairs(invalidQuestEnds) do count = count + 1 end

    if count > 0 then
        local correctionFile = io.open(outputDir .. "/npcQuestEndsCorrections.lua", "w")
        if correctionFile then
            correctionFile:write("return {\n")

            print("\27[31mFound " .. count .. " NPCs with invalid questEnds:\27[0m")
            for npcId, reasons in pairsByKeys(invalidQuestEnds) do
                print("\27[31m- NPC " .. npcId .. ":")
                for _, reason in ipairs(reasons) do
                    print("  - " .. reason)
                end
                print("\27[0m")

                table.sort(targetQuestEnds[npcId] or {})
                local correctionString = "[" .. npcId .. "] = { -- " .. npcs[npcId][npcKeys.name] .. "\n            [npcKeys.questEnds] = {" .. table.concat(targetQuestEnds[npcId] or {}, ",") .. "},\n        },"
                correctionFile:write("        " .. correctionString .. "\n")
            end
            correctionFile:write("}\n")
            correctionFile:close()
        else
            print("\27[31mFailed to open correction file for NPC quest ends\27[0m")
        end

        os.exit(1)
        return invalidQuestEnds, targetQuestEnds
    else
        print("\27[32mNo NPCs found with invalid questEnds\27[0m")
        return nil, nil
    end
end

---@param objects table<ObjectId, Object>
---@param objectKeys DatabaseObjectKeys
---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@return table<ObjectId, string>, table<ObjectId, QuestId[]>
function Validators.checkObjectQuestStarts(objects, objectKeys, quests, questKeys)
    print("\n\27[36mSearching for invalid questStarts in objects...\27[0m")

    local invalidQuestStarts = {}
    local targetQuestStarts = {}
    for questId, questData in pairs(quests) do
        local startedBy = questData[questKeys.startedBy]
        if startedBy then
            for _, objectStarterId in pairs(startedBy[2] or {}) do
                if not targetQuestStarts[objectStarterId] then
                    targetQuestStarts[objectStarterId] = {}
                end
                table.insert(targetQuestStarts[objectStarterId], questId)

                local objectQuestStarters = objects[objectStarterId][objectKeys.questStarts]

                local starterFound = false
                for _, starterQuestId in pairs(objectQuestStarters or {}) do
                    if starterQuestId == questId then
                        starterFound = true
                        break
                    end
                end

                if (not starterFound) then
                    if not invalidQuestStarts[objectStarterId] then
                        invalidQuestStarts[objectStarterId] = {}
                    end
                    table.insert(invalidQuestStarts[objectStarterId], "quest " .. questId .. " is missing in questStarts")
                end
            end
        end
    end

    for objectId, objectData in pairs(objects) do
        local questStarts = objectData[objectKeys.questStarts]
        if questStarts then
            for _, questId in ipairs(questStarts) do
                if not quests[questId] then
                    if not invalidQuestStarts[objectId] then
                        invalidQuestStarts[objectId] = {}
                    end
                    table.insert(invalidQuestStarts[objectId], "questStart " .. questId .. " is not in the database")
                    if not targetQuestStarts[objectId] then
                        targetQuestStarts[objectId] = {}
                    end
                else
                    local startedBy = quests[questId][questKeys.startedBy]
                    if startedBy then
                        local startEntryCorrect = false
                        for _, objectStarterId in pairs(startedBy[2] or {}) do
                            if objectStarterId == objectId then
                                startEntryCorrect = true
                                break
                            end
                        end

                        if not startEntryCorrect then
                            if not invalidQuestStarts[objectId] then
                                invalidQuestStarts[objectId] = {}
                            end
                            table.insert(invalidQuestStarts[objectId], "quest " .. questId .. " is not started by this object")
                        end
                    end
                end
            end

            -- Check if the objects questStarts match with the targetQuestStarts given by the quests.
            -- If they do match, then remove the object from targetQuestStarts, otherwise do nothing.
            if targetQuestStarts[objectId] then
                -- TODO: Fix tableContainsAll to correctly compare tables.
                if tableContainsAll(questStarts, targetQuestStarts[objectId]) and tableContainsAll(targetQuestStarts[objectId], questStarts) then
                    -- Remove the object from targetQuestStarts, because it matches the questStarts.
                    targetQuestStarts[objectId] = nil
                end
            end
        end
    end

    local count = 0
    for _ in pairs(invalidQuestStarts) do count = count + 1 end

    if count > 0 then
        local correctionFile = io.open(outputDir .. "/objectQuestStartsCorrections.lua", "w")
        if correctionFile then
            correctionFile:write("return {\n")

            print("\27[31mFound " .. count .. " objects with invalid questStarts:\27[0m")
            for objectId, reasons in pairsByKeys(invalidQuestStarts) do
                print("\27[31m- object " .. objectId .. ":")
                for _, reason in ipairs(reasons) do
                    print("  - " .. reason)
                end
                print("\27[0m")

                table.sort(targetQuestStarts[objectId] or {})
                local correctionString = "[" .. objectId .. "] = { -- " .. objects[objectId][objectKeys.name] .. "\n            [objectKeys.questStarts] = {" .. table.concat(targetQuestStarts[objectId] or {}, ",") .. "},\n        },"
                correctionFile:write("        " .. correctionString .. "\n")
            end
                correctionFile:write("}\n")
                correctionFile:close()
            else
            print("\27[31mFailed to open correction file for object quest starts\27[0m")
        end

        os.exit(1)
        return invalidQuestStarts, targetQuestStarts
    else
        print("\27[32mNo objects found with invalid questStarts\27[0m")
        return nil, nil
    end
end

---@param objects table<ObjectId, Object>
---@param objectKeys DatabaseObjectKeys
---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@return table<NpcId, string>, table<NpcId, QuestId[]>
function Validators.checkObjectQuestEnds(objects, objectKeys, quests, questKeys)
    print("\n\27[36mSearching for invalid questEnds in objects...\27[0m")

    local invalidQuestEnds = {}
    local targetQuestEnds = {}
    for questId, questData in pairs(quests) do
        local finishedBy = questData[questKeys.finishedBy]
        if finishedBy then
            for _, objectEnderId in pairs(finishedBy[2] or {}) do
                if not targetQuestEnds[objectEnderId] then
                    targetQuestEnds[objectEnderId] = {}
                end
                table.insert(targetQuestEnds[objectEnderId], questId)

                local objectEnder = objects[objectEnderId]
                if objectEnder then
                    local objectQuestEnds = objectEnder[objectKeys.questEnds]

                    local enderFound = false
                    for _, enderQuestId in pairs(objectQuestEnds or {}) do
                        if enderQuestId == questId then
                            enderFound = true
                            break
                        end
                    end

                    if (not enderFound) then
                        if not invalidQuestEnds[objectEnderId] then
                            invalidQuestEnds[objectEnderId] = {}
                        end
                        table.insert(invalidQuestEnds[objectEnderId], "quest " .. questId .. " is missing in questEnds")
                    end
                end
            end
        end
    end

    for objectId, objectData in pairs(objects) do
        local questEnds = objectData[objectKeys.questEnds]
        if questEnds then
            for _, questId in ipairs(questEnds) do
                if not quests[questId] then
                    if not invalidQuestEnds[objectId] then
                        invalidQuestEnds[objectId] = {}
                    end
                    table.insert(invalidQuestEnds[objectId], "questEnd " .. questId .. " is not in the database")
                    if not targetQuestEnds[objectId] then
                        targetQuestEnds[objectId] = {}
                    end
                else
                    local finishedBy = quests[questId][questKeys.finishedBy]
                    if finishedBy then
                        local endEntryCorrect = false
                        for _, objectFinisherId in pairs(finishedBy[2] or {}) do
                            if objectFinisherId == objectId then
                                endEntryCorrect = true
                                break
                            end
                        end

                        if not endEntryCorrect then
                            if not invalidQuestEnds[objectId] then
                                invalidQuestEnds[objectId] = {}
                            end
                            table.insert(invalidQuestEnds[objectId], "quest " .. questId .. " is not finished by this object")
                        end
                    end
                end
            end

            -- Check if the NPCs questStarts match with the targetQuestEnds given by the quests.
            -- If they do match, then remove the NPC from targetQuestEnds, otherwise do nothing.
            if targetQuestEnds[objectId] then
                -- TODO: Fix tableContainsAll to correctly compare tables.
                if tableContainsAll(questEnds, targetQuestEnds[objectId]) and tableContainsAll(targetQuestEnds[objectId], questEnds) then
                    -- Remove the NPC from targetQuestEnds, because it matches the questStarts.
                    targetQuestEnds[objectId] = nil
                end
            end
        end
    end

    local count = 0
    for _ in pairs(invalidQuestEnds) do count = count + 1 end

    if count > 0 then
        local correctionFile = io.open(outputDir .. "/objectQuestEndsCorrections.lua", "w")
        if correctionFile then
            correctionFile:write("return {\n")

            print("\27[31mFound " .. count .. " objects with invalid questEnds:\27[0m")
            for objectId, reasons in pairsByKeys(invalidQuestEnds) do
                print("\27[31m- object " .. objectId .. ":")
                for _, reason in ipairs(reasons) do
                    print("  - " .. reason)
                end
                print("\27[0m")

                table.sort(targetQuestEnds[objectId] or {})
                local correctionString = "[" .. objectId .. "] = { -- " .. objects[objectId][objectKeys.name] .. "\n            [objectKeys.questEnds] = {" .. table.concat(targetQuestEnds[objectId] or {}, ",") .. "},\n        },"
                correctionFile:write("        " .. correctionString .. "\n")
            end
            correctionFile:write("}\n")
            correctionFile:close()
        else
            print("\27[31mFailed to open correction file for object quest ends\27[0m")
        end

        os.exit(1)
        return invalidQuestEnds, targetQuestEnds
    else
        print("\27[32mNo objects found with invalid questEnds\27[0m")
        return nil, nil
    end
end

---@param quests table<QuestId, Quest>
---@param questKeys DatabaseQuestKeys
---@param raceKeys RaceKeys
---@return table<QuestId, string>
function Validators.checkRequiredRaces(quests, questKeys, raceKeys)
    print("\n\27[36mSearching for quests with invalid requiredRaces entries...\27[0m")
    local invalidQuests = {}

    -- sum of all race IDs which is theoretically the highest combination value that can be used
    local highestPossibleRaceCombination = 0
    for _, raceId in pairs(raceKeys) do
        highestPossibleRaceCombination = highestPossibleRaceCombination + raceId
    end

    for questId, questData in pairs(quests) do
        local requiredRaces = questData[questKeys.requiredRaces]
        if not requiredRaces then
            invalidQuests[questId] = "no requiredRaces entry"
        elseif requiredRaces > highestPossibleRaceCombination then
            invalidQuests[questId] = "requiredRaces is too high"
        end
    end

    local count = 0
    for _ in pairs(invalidQuests) do count = count + 1 end

    if count > 0 then
        print("\27[31mFound " .. count .. " quests with invalid requiredRaces entries:\27[0m")
        for questId, reason in pairs(invalidQuests) do
            print("\27[31m- Quest " .. questId .. " (" .. reason .. ")\27[0m")
        end

        os.exit(1)
        return invalidQuests
    else
        print("\27[32mNo quests found with invalid requiredRaces entries\27[0m")
        return nil
    end
end

return Validators
