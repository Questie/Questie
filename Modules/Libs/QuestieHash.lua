--- COMPATIBILITY ---
local GetNumQuestLogEntries = GetNumQuestLogEntries or C_QuestLog.GetNumQuestLogEntries
local IsQuestComplete = IsQuestComplete or C_QuestLog.IsComplete


---@class QuestieHash
local QuestieHash = QuestieLoader:CreateModule("QuestieHash")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local l10n = QuestieLoader:ImportModule("l10n")

local libS = QuestieLoader:ImportModule("QuestieSerializer")
local libC = LibStub:GetLibrary("LibCompress")

local questLogHashes = {}

-- forward declaration
local _SafeUpdateQuest

function QuestieHash:LoadQuestLogHashes()
    ExpandQuestHeader(0) -- Expand all headers

    local numEntries, _ = GetNumQuestLogEntries()
    for questLogIndex=1, numEntries do
        local _, _, _, isHeader, _, isComplete, _, questId = GetQuestLogTitle(questLogIndex)
        if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        elseif not isHeader then
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
    local hashChanged = false

    if questLogHashes == nil then
        return hashChanged
    end
    ExpandQuestHeader(0) -- Expand all headers

    local numEntries, _ = GetNumQuestLogEntries()
    for questLogIndex=1, numEntries do
        local _, _, _, isHeader, _, isComplete, _, questId = GetQuestLogTitle(questLogIndex)
        if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        elseif not isHeader then
            local oldhash = questLogHashes[questId]
            if oldhash ~= nil then
                local newHash = QuestieHash:GetQuestHash(questId, isComplete)

                if oldhash ~= newHash then
                    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes: Hash changed for questId:", questId)
                    _SafeUpdateQuest(questId, newHash);
                    hashChanged = true
                end
            else
                Questie:Debug(DEBUG_CRITICAL, "[QuestieHash:CompareQuestHashes] Quest hash is missing for", questId)
            end
        end
    end

    return hashChanged
end

--function QuestieHash:CompareAcceptedQuestHashes(questIdList)
--    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes")
--    local hashChanged = false
--
--    if questLogHashes == nil then
--        return hashChanged
--    end
--
--    for questId, isComplete in pairs(questIdList) do
--        if (not QuestieDB.QuestPointers[questId]) then
--            Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
--            Questie._sessionWarnings[questId] = true
--        else
--            local oldhash = questLogHashes[questId]
--            if oldhash ~= nil then
--                local newHash = QuestieHash:GetQuestHash(questId, isComplete)
--
--                if oldhash ~= newHash then
--                    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes: Hash changed for questId:", questId)
--                    _SafeUpdateQuest(questId, newHash);
--                    hashChanged = true
--                end
--            end
--        end
--    end
--
--    return hashChanged
--end

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
        local oldhash = questLogHashes[questId]
        if oldhash ~= nil then
            local newHash = QuestieHash:GetQuestHash(questId, IsQuestComplete(questId))

            if oldhash ~= newHash then
                Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes: Hash changed for questId:", questId)
                questLogHashes[questId] = newHash
                hashChanged = true
            end
        end
    end

    return hashChanged
end

_SafeUpdateQuest = function(questId, hash, count)
    if (not count) then
        count = 0;
    end
    if (QuestieLib:IsResponseCorrect(questId)) then
        QuestieQuest:UpdateQuest(questId)
        questLogHashes[questId] = hash
        Questie:Debug(DEBUG_DEVELOP, "Accept seems correct, cancel timer");
    else
        if (count < 50) then
            Questie:Debug(DEBUG_CRITICAL, "Response is wrong for quest " .. questId .. ". Waiting with timer...");
            C_Timer.After(0.1, function()
                _SafeUpdateQuest(questId, hash, count + 1);
            end)
        else
            Questie:Debug(DEBUG_CRITICAL, "Didn't get a correct response after 50 tries, stopping");
        end
    end
end