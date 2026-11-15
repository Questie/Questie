---@class ActiveQuests
local ActiveQuests = QuestieLoader:CreateModule("ActiveQuests")

local pairs = pairs

---One acceptance of a quest in the player's quest log. Deferred work captures it and runs only while it is current, so
---work started for a quest that was turned in, abandoned or accepted again in the meantime is dropped.
---@class Acceptance
---@field questId QuestId
---@field quest Quest? @nil when Questie's database lacks the quest

---@type table<QuestId, Acceptance>
local acceptances = {}
---Acceptances from before the last Reset. Restore hands them back to quests still logged, so work pending from before
---the rebuild stays current: an unload pending from before can remove the icons the rebuild drew, and only the pending
---work draws them again.
---@type table<QuestId, Acceptance>
local previous = {}

---@param questId QuestId
---@param quest Quest?
---@return Acceptance
local function _Create(questId, quest)
    return {questId = questId, quest = quest}
end

---@param acceptance Acceptance
local function _Store(acceptance)
    acceptances[acceptance.questId] = acceptance
end

---Whether the acceptance is still the quest's acceptance: the quest was neither turned in, abandoned nor accepted
---again since.
---@param acceptance Acceptance?
---@return boolean
function ActiveQuests.IsCurrent(acceptance)
    return acceptance ~= nil and acceptances[acceptance.questId] == acceptance
end

---Logs a new acceptance of the quest. Any earlier acceptance of it is no longer current.
---@param questId QuestId
---@param quest Quest?
---@return Acceptance
function ActiveQuests.Add(questId, quest)
    previous[questId] = nil
    local acceptance = _Create(questId, quest)
    _Store(acceptance)
    return acceptance
end

---Logs a quest that is still in the quest log, keeping its acceptance from before a Reset if it had one.
---@param questId QuestId
---@param quest Quest?
---@return Acceptance
function ActiveQuests.Restore(questId, quest)
    local acceptance = acceptances[questId] or previous[questId] or _Create(questId, quest)
    previous[questId] = nil
    acceptance.quest = quest
    _Store(acceptance)
    return acceptance
end

---Removes the quest from the log. Its acceptance is no longer current.
---@param questId QuestId
---@return Acceptance? @The removed acceptance, nil when the quest was not logged
function ActiveQuests.Remove(questId)
    local acceptance = acceptances[questId]
    acceptances[questId] = nil
    previous[questId] = nil
    return acceptance
end

---Empties the log before it is rebuilt from the game's quest log. Restore brings back the acceptance of each quest.
function ActiveQuests.Reset()
    for questId, acceptance in pairs(acceptances) do
        previous[questId] = acceptance
    end
    acceptances = {}
end

---@param questId QuestId
---@return Acceptance? @nil when the quest is not logged
function ActiveQuests.Get(questId)
    return acceptances[questId]
end

---Iterates the logged quests as they were when the iteration started, so the loop may yield or change the log.
---@return fun(table: table<QuestId, Acceptance>, index?: QuestId):QuestId, Acceptance
---@return table<QuestId, Acceptance>
function ActiveQuests.Iterate()
    local snapshot = {}
    for questId, acceptance in pairs(acceptances) do
        snapshot[questId] = acceptance
    end
    return pairs(snapshot)
end

---The logged quests for lookups in hot loops, where a call per quest costs too much. Fetch it again for every pass:
---Reset replaces the table.
---@return table<QuestId, Acceptance> @NEVER MODIFY THE RETURNED TABLE
function ActiveQuests.GetAll()
    return acceptances
end
