---@class DebugFunctions
local DebugFunctions = QuestieLoader:CreateModule("DebugFunctions")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

-- This is a collection of functions that are useful for debugging purposes.
-- They are not intended to be used in production code.

---Adds a quest to the map as if it was in the quest log
---@param questId QuestId
function DebugFunctions.ShowQuestObjectives(questId)
    local quest = QuestieDB.GetQuest(questId)
    if not quest then
        Questie:Debug(Questie.DEBUG_CRITICAL, "ShowQuestObjectives: Quest not found in DB:", questId)
        return
    end
    if not quest.ObjectiveData or not next(quest.ObjectiveData) then
        Questie:Debug(Questie.DEBUG_CRITICAL, "ShowQuestObjectives: Quest has no ObjectiveData:", questId)
        return
    end

    local objectives = C_QuestLog.GetQuestObjectives(questId)
    ---@type table<string, any>
    local questCacheObjectives = {}

    for i, objective in pairs(objectives) do
        quest.Objectives[i] = {
            Id = quest.ObjectiveData[i].Id,
            Index = i,
            questId = quest.Id,
            _lastUpdate = 0,
            Description = objective.text,
            spawnList = {},
            AlreadySpawned = {},
            Update = QuestieQuest.private.ObjectiveUpdate,
            Coordinates = quest.ObjectiveData[i].Coordinates, -- Only for type "event"
            RequiredRepValue = quest.ObjectiveData[i].RequiredRepValue,
            Icon = quest.ObjectiveData[i].Icon,
            -- Values below where never set on init but will exist later
            QuestData = nil,
            Color = nil,
            Type = nil,
            isUpdated = nil,
            Completed = nil,
            fulfilled = nil,
            required = nil,
            Needed = nil,
            Collected = nil,
        }
        questCacheObjectives[i] = {
            raw_text = objective.text,
            text = QuestieLib.TrimObjectiveText(objective.text, objective.type),
            type = objective.type,
            raw_finished = objective.finished,
            finished = objective.finished,
            raw_numFulfilled = objective.numFulfilled,
            numFulfilled = objective.numFulfilled,
            numRequired = objective.numRequired,
        }
    end

    QuestLogCache.questLog_DO_NOT_MODIFY[questId] = {
        title = quest.name,
        isComplete = 0,
        objectives = questCacheObjectives,
        questTag = nil,
    }

    for i, objective in pairs(quest.Objectives) do
        print("Adding objective", i, objective.Description)
        QuestieQuest:PopulateObjective(quest, i, objective, false)
    end
end
