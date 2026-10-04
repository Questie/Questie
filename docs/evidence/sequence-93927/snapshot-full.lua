local id = 93927
local cacheModule = QuestieLoader:ImportModule("QuestLogCache")
local player = QuestieLoader:ImportModule("QuestiePlayer")
local tracker = QuestieLoader:ImportModule("TrackerData")
local compat = QuestieLoader:ImportModule("QuestieCompat")
local db = QuestieLoader:ImportModule("QuestieDB")
local api = C_QuestLog or {}
local function value(v)
    if v == nil then return "<nil>" end
    return v
end
local function pack(...)
    local result = {count = select("#", ...), values = {}}
    for i = 1, result.count do result.values[i] = value(select(i, ...)) end
    return result
end
local function call(fn, ...)
    if type(fn) ~= "function" then return {available = false} end
    local result = pack(pcall(fn, ...))
    return {available = true, ok = result.values[1], result = result.values[2], returns = result}
end
local function scalars(source)
    if type(source) ~= "table" then return value(source) end
    local result = {}
    for key, entry in pairs(source) do
        if type(entry) ~= "table" and type(entry) ~= "function" and type(entry) ~= "userdata" then
            result[tostring(key)] = entry
        end
    end
    return result
end
local function objectives(source)
    if type(source) ~= "table" then return value(source) end
    local result = {}
    for index, objective in pairs(source) do
        local row = scalars(objective)
        if type(objective) == "table" then row.enrichment = scalars(objective.enrichment) end
        result[tostring(index)] = row
    end
    return result
end
local function quest(source)
    if type(source) ~= "table" then return value(source) end
    local result = scalars(source)
    result.isComplete = value(source.isComplete)
    result.completionState = value(source.completionState)
    result.Objectives = objectives(source.Objectives)
    result.objectives = objectives(source.objectives)
    result.SpecialObjectives = objectives(source.SpecialObjectives)
    result.ObjectiveData = source.ObjectiveData
    return result
end
local index = compat.GetQuestLogIndexByID(id)
local board = {}
local count = compat.GetNumQuestLeaderBoards(index)
if GetQuestLogLeaderBoard then
    for i = 1, count do
        local text, kind, finished = GetQuestLogLeaderBoard(i, index)
        board[i] = {text = value(text), type = value(kind), finished = value(finished)}
    end
end
local original = player.currentQuestlog[id]
local cached = cacheModule.questLog_DO_NOT_MODIFY[id]
local display = type(tracker.GetQuest) == "function" and tracker.GetQuest(id) or nil
local version, build, _, interface = GetBuildInfo()
local statuses = {}
for _, name in ipairs({"IsComplete", "IsFailed", "ReadyForTurnIn", "IsQuestFlaggedCompleted", "IsQuestFlaggedCompletedOnAccount", "GetQuestObjectives"}) do
    statuses["C_QuestLog." .. name] = call(api[name], id)
end
for _, name in ipairs({"IsQuestSequenced", "IsQuestComplete", "IsQuestFlaggedCompleted"}) do
    statuses[name] = call(_G[name], id)
end
statuses.GetQuestLogTitle = call(GetQuestLogTitle, index)
statuses.compatTitle = call(compat.GetQuestLogTitle, index)
statuses.GetInfo = call(api.GetInfo, index)
return {
    capturedAt = date("!%Y-%m-%dT%H:%M:%SZ"), uptime = GetTime(), questId = id, questLogIndex = index,
    client = {version = version, build = build, interface = interface},
    nativeAPIs = statuses,
    dialogOnly = {
        note = "NPC dialog only; compare GetQuestID.",
        ["GetQuestID"] = call(GetQuestID),
        ["IsQuestCompletable"] = call(IsQuestCompletable),
        ["IsCurrentQuestFailed"] = call(IsCurrentQuestFailed),
    },
    leaderboard = board,
    cache = quest(cached), enrichedQuest = quest(original), tracker = quest(display),
    questieResults = {
        ["QuestieDB.IsComplete"] = call(db.IsComplete, id),
        ["Quest.IsComplete"] = call(type(original) == "table" and original.IsComplete or nil, original),
        trackerAccessorAvailable = type(tracker.GetQuest) == "function",
    },
}
