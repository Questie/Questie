Validators = {}

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

function Validators.checkPreQuestExclusiveness(quests, questKeys)
    print("\n\27[36mSearching for quests with preQuestSingle and preQuestGroup entries...\27[0m")
    local invalidQuests = {}
    for questId, questData in pairs(quests) do
        local preQuestSingle = questData[questKeys.preQuestSingle]
        local preQuestGroup = questData[questKeys.preQuestGroup]
        if preQuestSingle and next(preQuestSingle) and preQuestGroup and next(preQuestGroup) then
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

return Validators
