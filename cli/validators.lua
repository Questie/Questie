Validators = {}

function Validators.checkRequiredSourceItems(quests, questKeys)
    print("\n\27[36mSearching for sourceItemId entries in quest.requiredSourceItems...\27[0m")
    local matchingQuests = {}
    for questId, questData in pairs(quests) do
        local sourceItemId = questData[questKeys.sourceItemId]
        local requiredSourceItems = questData[questKeys.requiredSourceItems]
        if sourceItemId and requiredSourceItems then
            for _, itemId in ipairs(requiredSourceItems) do
                if itemId == sourceItemId then
                    table.insert(matchingQuests, questId)
                    break
                end
            end
        end
    end

    if #matchingQuests > 0 then
        print("\27[31mFound " .. #matchingQuests .. " quests with sourceItemId in requiredSourceItems:\27[0m")
        for _, questId in ipairs(matchingQuests) do
            print("\27[31m- Quest " .. questId .. "\27[0m")
        end

        os.exit(1)
    else
        print("\27[32mNo quests found with sourceItemId in requiredSourceItems\27[0m")
    end
end
