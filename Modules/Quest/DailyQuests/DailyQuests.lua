---@class DailyQuests
---@field hubs table<HubId, Hub>
local DailyQuests = QuestieLoader:CreateModule("DailyQuests");

---@type table<QuestId, Hub[]>
local hubQuestLookup = {}

function DailyQuests.Initialize()
    for _, hub in pairs(DailyQuests.hubs) do
        for _, hubQuestId in pairs(hub.quests) do
            if (not hubQuestLookup[hubQuestId]) then
                hubQuestLookup[hubQuestId] = {}
            end
            table.insert(hubQuestLookup[hubQuestId], hub)
        end
    end
end

---@param hub Hub
---@param completedQuests table<QuestId, boolean> A table of completed quests
---@param questLog table<QuestId, Quest> A table of quests in the quest log
---@return boolean true if the quest should be hidden, false otherwise
local function _ShouldBeHidden(hub, completedQuests, questLog)
    if hub.IsActive and (not hub.IsActive(completedQuests, questLog)) then
        return true
    end

    local completedCount = 0
    for _, hubQuestId in pairs(hub.quests) do
        if completedQuests[hubQuestId] or questLog[hubQuestId] then
            completedCount = completedCount + 1
        end
    end

    for hubId, _ in pairs(hub.exclusiveHubs) do
        local exclusiveHub = DailyQuests.hubs[hubId]
        for _, exclusiveHubQuestId in pairs(exclusiveHub.quests) do
            if completedQuests[exclusiveHubQuestId] or questLog[exclusiveHubQuestId] then
                return true
            end
        end
    end

    if completedCount >= hub.limit then
        return true
    end

    local singlePreQuestHubComplete = (not next(hub.preQuestHubsSingle))
    for hubId, _ in pairs(hub.preQuestHubsSingle) do
        local preHub = DailyQuests.hubs[hubId]
        local preHubCompletedCount = 0
        for _, preHubQuestId in pairs(preHub.quests) do
            if completedQuests[preHubQuestId] then
                preHubCompletedCount = preHubCompletedCount + 1
            end
        end

        if preHubCompletedCount >= preHub.limit then
            singlePreQuestHubComplete = true
        end
    end

    if (not singlePreQuestHubComplete) then
        return true
    end

    local groupPreQuestHubComplete = true
    for hubId, _ in pairs(hub.preQuestHubsGroup) do
        local preHub = DailyQuests.hubs[hubId]
        local preHubCompletedCount = 0
        for _, preHubQuestId in pairs(preHub.quests) do
            if completedQuests[preHubQuestId] then
                preHubCompletedCount = preHubCompletedCount + 1
            end
        end

        if preHubCompletedCount < preHub.limit then
            groupPreQuestHubComplete = false
            break
        end
    end

    if (not groupPreQuestHubComplete) then
        return true
    end

    return false
end

---@param questId QuestId
---@param completedQuests table<QuestId, boolean> A table of completed quests
---@param questLog table<QuestId, Quest> A table of quests in the quest log
---@return boolean true if the quest should be hidden, false otherwise
function DailyQuests.ShouldBeHidden(questId, completedQuests, questLog)
    if (not hubQuestLookup[questId]) then
        return false
    end

    local hubs = hubQuestLookup[questId]
    for _, hub in pairs(hubs) do
        local shouldBeHidden = _ShouldBeHidden(hub, completedQuests, questLog)
        if (not shouldBeHidden) then
            return false
        end
    end

    return true
end
