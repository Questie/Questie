-- Run from the repository root. API responses are synthetic; source comes from pinned Git revisions.
local function Run(label, revision)
    local modules = {}
    QuestieLoader = {
        ImportModule = function(_, name) modules[name] = modules[name] or {}; return modules[name] end,
        CreateModule = function(_, name) modules[name] = modules[name] or {}; return modules[name] end,
    }
    Questie = {Debug = function() end, Warning = function() end}
    local count, missingB = 5, false
    HaveQuestData = function(id) return id ~= 102 or not missingB end
    C_QuestLog = {GetQuestObjectives = function(id)
        local fulfilled = id == 101 and count or 0
        return {{text = "Item: " .. fulfilled .. "/10", type = "item", finished = false,
            numRequired = 10, numFulfilled = fulfilled}}
    end}
    QuestieLoader:ImportModule("QuestieCompat").GetQuestLogTitle = function(index)
        if index > 2 then return end
        return "Quest", 1, nil, false, false, nil, nil, 100 + index
    end
    QuestieLoader:ImportModule("QuestieLib").TrimObjectiveText = function() return "Item" end
    local sounds = QuestieLoader:ImportModule("Sounds")
    sounds.PlayObjectiveComplete = function() end
    sounds.PlayObjectiveProgress = function() end
    sounds.PlayQuestComplete = function() end
    local path = revision .. ":Modules/Quest/QuestLogCache.lua"
    local pipe = assert(io.popen("git show " .. path, "r"))
    local source = pipe:read("*a")
    pipe:close()
    assert(source and #source > 0, "Could not read " .. path .. "; run from the repository with both commits available")
    assert(loadstring(source, "@" .. path))()
    local cache = modules.QuestLogCache
    cache.CheckForChanges()
    cache.OnLoadingScreenEnabled()
    missingB = true
    cache.CheckForChanges()
    count = 4
    missingB = false
    for i = 1, 3 do
        local miss = cache.CheckForChanges()
        print(label, "retry=" .. i, "cacheMiss=" .. tostring(miss),
            "count=" .. cache.questLog_DO_NOT_MODIFY[101].objectives[1].numFulfilled)
    end
end
Run("master", "04ba519340847f47ee6a305e7ff413fb0ff8ba0b")
Run("HEAD", "545d17fd5cc03fd13534784a086b6b35f2aee3c5")
