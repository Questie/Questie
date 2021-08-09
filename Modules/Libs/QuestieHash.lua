--- COMPATIBILITY ---
local GetNumQuestLogEntries = GetNumQuestLogEntries or C_QuestLog.GetNumQuestLogEntries
local IsQuestComplete = IsQuestComplete or C_QuestLog.IsComplete


---@class QuestieHash
local QuestieHash = QuestieLoader:CreateModule("QuestieHash")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local libS = QuestieLoader:ImportModule("QuestieSerializer")
local libC = LibStub:GetLibrary("LibCompress")

local questLogHashes = {}


function QuestieHash:LoadQuestLogHashes()
    local numEntries, numQuests = GetNumQuestLogEntries()
    for questLogIndex = 1, numEntries + numQuests do
        local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(questLogIndex)
        if (not title) then
            -- We exceeded the valid quest log entries
            break
        end
        if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        elseif not isHeader then
            questLogHashes[questId] = QuestieHash:GetQuestHash(questId)
        end
    end
end

---@param questId number
---@return string a hash of the quest objectives + the state if the quest is complete
function QuestieHash:GetQuestHash(questId)
    local hash = libC:fcs32init()
    local data = {}
    data.questId = questId
    data.isComplete = IsQuestComplete(questId)
    data.questObjectives = QuestieLib:GetQuestObjectives(questId);

    hash = libC:fcs32update(hash, libS:Serialize(data))
    hash = libC:fcs32final(hash)
    return hash
end

function QuestieHash:AddNewQuestHash(questId)
    Questie:Debug(DEBUG_DEVELOP, "AddNewQuestHash:", questId)
    questLogHashes[questId] = QuestieHash:GetQuestHash(questId)
end

function QuestieHash:RemoveQuestHash(questId)
    Questie:Debug(DEBUG_DEVELOP, "RemoveQuestHash:", questId)
    questLogHashes[questId] = nil
end

---@param questIdList table<number, number> A list of questIds whose hash should to be checked
---@return table<number, number> A list questIds whose hash has changed
function QuestieHash:CompareHashesOfQuestIdList(questIdList)
    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes")
    local updatedQuestIds = {}

    if questLogHashes == nil then
        return nil
    end

    for _, questId in pairs(questIdList) do
        if (not QuestieDB.QuestPointers[questId]) then
            Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
            Questie._sessionWarnings[questId] = true
        else
            local oldHash = questLogHashes[questId]
            if oldHash ~= nil then
                local newHash = QuestieHash:GetQuestHash(questId)

                if oldHash ~= newHash then
                    Questie:Debug(DEBUG_DEVELOP, "Hash changed for questId:", questId)
                    table.insert(updatedQuestIds, questId)
                    questLogHashes[questId] = newHash
                end
            end
        end
    end

    return updatedQuestIds
end

---@param questId number
---@return boolean true if the hash of the questId changed, false otherwise
function QuestieHash:CompareQuestHash(questId)
    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHash")
    local hashChanged = false

    if questLogHashes == nil then
        return hashChanged
    end

    if (not QuestieDB.QuestPointers[questId]) then
        Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
        Questie._sessionWarnings[questId] = true
    else
        local oldHash = questLogHashes[questId]
        if oldHash ~= nil then
            local newHash = QuestieHash:GetQuestHash(questId, IsQuestComplete(questId))

            if oldHash ~= newHash then
                Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes: Hash changed for questId:", questId)
                questLogHashes[questId] = newHash
                hashChanged = true
            end
        end
    end

    return hashChanged
end
