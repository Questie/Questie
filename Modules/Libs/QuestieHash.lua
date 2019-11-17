---@class QuestieHash
local QuestieHash = QuestieLoader:CreateModule("QuestieHash")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")

local libS = LibStub:GetLibrary("AceSerializer-3.0")
local libC = LibStub:GetLibrary("LibCompress")

local questLogHashes = {}

-- forward declaration
local _SafeUpdateQuest

function QuestieHash:LoadQuestLogHashes()
    ExpandQuestHeader(0) -- Expand all headers

    local numEntries, _ = GetNumQuestLogEntries()
    for questLogIndex=1, numEntries do
        local _, _, _, isHeader, isCollapsed, isComplete, _, questId = GetQuestLogTitle(questLogIndex)
        if not isHeader then
            local hash = QuestieHash:GetQuestHash(questId, isComplete)
            tinsert(questLogHashes, questId, hash)
        end
    end
end

function QuestieHash:GetQuestHash(questId, isComplete)
    local hash = libC:fcs32init()
    local data = {}
    data.questId = questId
    data.isComplete = isComplete
    data.questObjectives = QuestieLib:GetQuestObjectives(questId);

    hash = libC:fcs32update(hash, libS:Serialize(data))
    hash = libC:fcs32final(hash)
    return hash
end

function QuestieHash:AddNewQuestHash(questId)
    Questie:Debug(DEBUG_DEVELOP, "AddNewQuestHash:", questId)
    local hash = QuestieHash:GetQuestHash(questId, false)

    questLogHashes[questId] = hash
end

function QuestieHash:RemoveQuestHash(questId)
    Questie:Debug(DEBUG_DEVELOP, "RemoveQuestHash:", questId)
    questLogHashes[questId] = nil
end

function QuestieHash:CompareQuestHashes()
    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes")
    if questLogHashes == nil then
        return
    end
    ExpandQuestHeader(0) -- Expand all headers

    local numEntries, _ = GetNumQuestLogEntries()
    for questLogIndex=1, numEntries do
        local _, _, _, isHeader, isCollapsed, isComplete, _, questId = GetQuestLogTitle(questLogIndex)
        if not isHeader then
            local oldhash = questLogHashes[questId]
            if oldhash ~= nil then
                local newHash = QuestieHash:GetQuestHash(questId, isComplete)

                if oldhash ~= newHash then
                    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes: Hash changed for questId:", questId)
                    _SafeUpdateQuest(questId, newHash);
                end
            end
        end
    end
end

_SafeUpdateQuest = function(questId, hash, count)
    if(not count) then
        count = 0;
    end
    if(QuestieLib:IsResponseCorrect(questId)) then
        QuestieQuest:UpdateQuest(questId)
        questLogHashes[questId] = hash
        Questie:Debug(DEBUG_DEVELOP, "Accept seems correct, cancel timer");
    else
        if(count < 50) then
            Questie:Debug(DEBUG_CRITICAL, "Response is wrong for quest " .. questId .. ". Waiting with timer...");
            C_Timer.After(0.1, function()
                _SafeUpdateQuest(questId, hash, count + 1);
            end)
        else
            Questie:Debug(DEBUG_CRITICAL, "Didn't get a correct response after 50 tries, stopping");
        end
    end
end