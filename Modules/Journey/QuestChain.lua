---@class QuestChain
local QuestChain = QuestieLoader:CreateModule("QuestChain")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

local indexedPointers, predecessors, successors

local function BuildIndex()
    predecessors, successors = {}, {}
    local function AddEdge(before, after)
        if not before or not after or before == 0 or after == 0 then return end
        before, after = math.abs(before), math.abs(after)
        if before == after or not QuestieDB.QuestPointers[before] or not QuestieDB.QuestPointers[after] then return end
        successors[before] = successors[before] or {}
        predecessors[after] = predecessors[after] or {}
        successors[before][after] = true
        predecessors[after][before] = true
    end

    for id in pairs(QuestieDB.QuestPointers) do
        for _, field in ipairs({"preQuestSingle", "preQuestGroup"}) do
            for _, previous in ipairs(QuestieDB.QueryQuestSingle(id, field) or {}) do
                AddEdge(previous, id)
            end
        end
        AddEdge(id, QuestieDB.QueryQuestSingle(id, "nextQuestInChain"))
        AddEdge(id, QuestieDB.QueryQuestSingle(id, "breadcrumbForQuestId"))
    end
    indexedPointers = QuestieDB.QuestPointers
end

---Returns the connected chain in prerequisite order, including branches and the selected quest.
---Unrelated branches use quest ID order. Hidden steps connect the chain but are not returned.
---@param questId QuestId
---@return QuestId[]
function QuestChain.GetQuestIds(questId)
    if indexedPointers ~= QuestieDB.QuestPointers or not predecessors then
        BuildIndex()
    end

    -- Find all quests connected to the given quest ID
    local members, pending = {[questId] = true}, {questId}
    local cursor = 1
    while cursor <= #pending do
        local id = pending[cursor]
        for _, edges in ipairs({predecessors[id] or {}, successors[id] or {}}) do
            for neighbor in pairs(edges) do
                if not members[neighbor] then
                    members[neighbor] = true
                    pending[#pending + 1] = neighbor
                end
            end
        end
        cursor = cursor + 1
    end

    -- Perform a topological sort to order the quests
    local remaining, ready, result = {}, {}, {}
    for id in pairs(members) do
        local count = 0
        for _ in pairs(predecessors[id] or {}) do count = count + 1 end
        remaining[id] = count
        -- If a quest has no prerequisites, it is ready to be added to the result
        if count == 0 then ready[#ready + 1] = id end
    end

    -- Process the remaining quests until all have been added to the result
    while next(remaining) do
        -- If there are no ready quests, pick the smallest remaining quest ID to continue
        if #ready == 0 then
            local smallest
            for id in pairs(remaining) do
                if not smallest or id < smallest then smallest = id end
            end
            ready[1] = smallest
        end
        -- Sort the ready quests to ensure a consistent order for unrelated branches then add the first one to the result
        table.sort(ready)
        local id = table.remove(ready, 1)
        remaining[id] = nil
        -- Only add the quest to the result if it is not hidden and has a valid name
        if not QuestieCorrections.hiddenQuests[id] and QuestieDB.QueryQuestSingle(id, "name") then
            result[#result + 1] = id
        end
        -- Update the remaining prerequisites for the quests that follow the current quest
        for following in pairs(successors[id] or {}) do
            if remaining[following] then
                remaining[following] = remaining[following] - 1
                if remaining[following] == 0 then ready[#ready + 1] = following end
            end
        end
    end
    return result
end
