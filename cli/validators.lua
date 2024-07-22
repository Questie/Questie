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
                    matchingQuests[questId] = "sourceItemId in requiredSourceItems: " .. requiredSourceItems[index] .. " == " .. sourceItemId
                    break
                end
            end
        end

        local objectives = questData[questKeys.objectives]
        if requiredSourceItems and objectives and objectives[3] then
            for _, itemObjective in pairs(objectives[3]) do
                for index = 1, #requiredSourceItems do
                    if requiredSourceItems[index] == itemObjective[1] then
                        matchingQuests[questId] = "itemObjectiveId in requiredSourceItems: " .. requiredSourceItems[index] .. " == " .. itemObjective[1]
                        break
                    end
                end
            end
        end
    end

    if table.getn(matchingQuests) > 0 then
        print("\27[31mFound " .. #matchingQuests .. " quests with sourceItemId or itemObjectiveId in requiredSourceItems:\27[0m")
        for questId, reason in pairs(matchingQuests) do
            print("\27[31m- Quest " .. questId .. " (" .. reason .. ")\27[0m")
        end

        os.exit(1)
    else
        print("\27[32mNo quests found with sourceItemId or itemObjectiveId in requiredSourceItems\27[0m")
    end
end
