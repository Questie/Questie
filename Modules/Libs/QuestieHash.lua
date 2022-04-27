---@class QuestieHash
local QuestieHash = QuestieLoader:CreateModule("QuestieHash")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieSerializer
local libS = QuestieLoader:ImportModule("QuestieSerializer")

local libC = LibStub:GetLibrary("LibCompress")

--- questLogHashes[questId] = hash
---@type table<number, number>
local questLogHashes = {}

-- 3 * (Max possible number of quests in game quest log)
-- This is a safe value, even smaller would be enough. Too large won't effect performance
local MAX_QUEST_LOG_INDEX = 75


function QuestieHash:InitQuestLogHashes()
    questLogHashes = {}
    for questLogIndex = 1, MAX_QUEST_LOG_INDEX do
        local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(questLogIndex)
        if (not title) then
            -- We exceeded the valid quest log entries
            break
        end
        if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", questId))
                Questie._sessionWarnings[questId] = true
            end
        elseif (not isHeader) then
            questLogHashes[questId] = QuestieHash:GetQuestHash(questId)
        end
    end
end

---@param questId number
---@return number @a hash of the quest objectives + the state if the quest is complete
function QuestieHash:GetQuestHash(questId)
    local hash = libC:fcs32init()
    local data = {
        questId = questId,
        isComplete = QuestieDB:IsComplete(questId),
        questObjectives = C_QuestLog.GetQuestObjectives(questId),
    }

    hash = libC:fcs32update(hash, libS:Serialize(data))
    hash = libC:fcs32final(hash)
    return hash
end

function QuestieHash:AddNewQuestHash(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieHash] AddNewQuestHash:", questId)
    questLogHashes[questId] = QuestieHash:GetQuestHash(questId)
    QuestieQuest:SetObjectivesDirty(questId)
end

function QuestieHash:RemoveQuestHash(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieHash] RemoveQuestHash:", questId)
    questLogHashes[questId] = nil
    QuestieQuest:SetObjectivesDirty(questId)
end

---@param questIdList table<number, number> @A list of questIds whose hash should to be checked
---@return table<number, number> @A list questIds whose hash has changed
function QuestieHash:CompareHashesOfQuestIdList(questIdList)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieHash] CompareQuestHashes")
    local updatedQuestIds = {}
    local updatedQuestIdsSize = 0

    for _, questId in pairs(questIdList) do
        if (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", questId))
                Questie._sessionWarnings[questId] = true
            end
        else
            local oldHash = questLogHashes[questId]
            if oldHash then
                local newHash = QuestieHash:GetQuestHash(questId)
                if oldHash ~= newHash then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieHash] Hash changed for questId:", questId)
                    questLogHashes[questId] = newHash
                    updatedQuestIdsSize = updatedQuestIdsSize + 1
                    updatedQuestIds[updatedQuestIdsSize] = questId
                    QuestieQuest:SetObjectivesDirty(questId)
                end
            else
                -- Quest isn't accepted yet or has been already removed. Not sure what to do.
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieHash] Old hash is missing for questId:", questId)
                updatedQuestIdsSize = updatedQuestIdsSize + 1
                updatedQuestIds[updatedQuestIdsSize] = questId
            end
        end
    end

    return updatedQuestIds
end

---@param questId number
---@return boolean true @if the hash of the questId changed, false otherwise
function QuestieHash:CompareQuestHash(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieHash] CompareQuestHash")
    local hashChanged = false

    if (not QuestieDB.QuestPointers[questId]) then
        if not Questie._sessionWarnings[questId] then
            Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", questId))
            Questie._sessionWarnings[questId] = true
        end
    else
        local oldHash = questLogHashes[questId]
        if oldHash then
            local newHash = QuestieHash:GetQuestHash(questId)

            if oldHash ~= newHash then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieHash] Hash changed for questId:", questId)
                questLogHashes[questId] = newHash
                hashChanged = true
                QuestieQuest:SetObjectivesDirty(questId)
            end
        else
            -- Quest isn't accepted yet or has been already removed. Not sure what to do.
            Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieHash] Old hash is missing for questId:", questId)
            hashChanged = true
        end
    end

    return hashChanged
end
