QuestieDebugModule = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")

local _UnitFactionGroup, _UnitLevel, _UnitRace, _UnitClass

local fakedQuestLogIds = {}
local fakedCompletedQuestIds = {}

function QuestieDebugModule:ResetFakes()
    UnitFactionGroup = _UnitFactionGroup
    UnitLevel = _UnitLevel
    UnitRace = _UnitRace
    UnitClass = _UnitClass

    for questId, _ in pairs(fakedQuestLogIds) do
        QuestiePlayer.currentQuestlog[questId] = nil
    end
end

function QuestieDebugModule:FakeFaction(targetFaction)
    if targetFaction ~= "Horde" and targetFaction ~= "Alliance" then
        print("Invalid faction to fake:", targetFaction)
        return
    end

    _UnitFactionGroup = UnitFactionGroup
    UnitFactionGroup = function() return targetFaction end
end

function QuestieDebugModule:FakeLevel(targetLevel)
    if targetLevel < 0 then
        print("Invalid level to fake:", targetLevel)
        return
    end

    _UnitLevel = UnitLevel
    UnitLevel = function() return targetLevel end
end

function QuestieDebugModule:FakeRace(targetRaceIndex, targetRaceName, targetRaceFile)
    if (not targetRaceName) then
        targetRaceName = ""
    end
    if (not targetRaceFile) then
        targetRaceFile = ""
    end

    _UnitRace = UnitRace
    UnitRace = function() return targetRaceName, targetRaceFile, targetRaceIndex end
end

function QuestieDebugModule:FakeClass(targetClassIndex, targetClassName, targetClassFile)
    if (not targetClassName) then
        targetClassName = ""
    end
    if (not targetClassFile) then
        targetClassFile = ""
    end

    _UnitClass = UnitClass
    UnitClass = function() return targetClassName, targetClassFile, targetClassIndex end
end

function QuestieDebugModule:AddQuestToCurrentQuestlog(questId)
    fakedQuestLogIds[questId] = true

    QuestiePlayer.currentQuestlog[questId] = QuestieDB:GetQuest(questId)
end

function QuestieDebugModule:FakeCompleteQuest(questId)
    fakedCompletedQuestIds[questId] = true

    Questie.db.char.complete[questId] = true
end
