QuestieDB = {}
QuestieLoader = {}
function QuestieLoader:ImportModule() return QuestieDB end
dofile('data/trinity/cataQuestDB.lua')
local trinity = loadstring(QuestieDB.questData)()
QuestieDB = {}
dofile('data/mangos/cataQuestDB.lua')
local mangos = loadstring(QuestieDB.questData)()
QuestieDB = {}
dofile('data/cmangos/tbcQuestDB.lua')
local tbc = loadstring(QuestieDB.questData)()
QuestieDB = {}
dofile('data/cmangos/wotlkQuestDB.lua')
local wotlk = loadstring(QuestieDB.questData)()

local printToFile = require('printToFile')

local questKeys = QuestieDB.questKeys

for questId, data in pairs(trinity) do
    local quest = mangos[questId]

    -- get spawns from trinity and add them to mangos
    if quest and quest[questKeys.questLevel] then
        if not data[questKeys.startedBy] then
            data[questKeys.startedBy] = quest[questKeys.startedBy]
        --TODO: add items to startedBy once that is really required. Questie doesn't use it yet.
        --elseif (not data[questKeys.startedBy][3]) and quest[questKeys.startedBy] and quest[questKeys.startedBy][3] then
        --    data[questKeys.startedBy][3] = quest[questKeys.startedBy][3]
        end
        if not data[questKeys.finishedBy] then
            data[questKeys.finishedBy] = quest[questKeys.finishedBy]
        end
        data[questKeys.name] = quest[questKeys.name]
        data[questKeys.objectivesText] = quest[questKeys.objectivesText]
        data[questKeys.requiredLevel] = quest[questKeys.requiredLevel]
        data[questKeys.questLevel] = quest[questKeys.questLevel]
        data[questKeys.preQuestSingle] = quest[questKeys.preQuestSingle]
        data[questKeys.preQuestGroup] = quest[questKeys.preQuestGroup]
        data[questKeys.questFlags] = quest[questKeys.questFlags]
        data[questKeys.childQuests] = quest[questKeys.childQuests]
        data[questKeys.parentQuest] = quest[questKeys.parentQuest]
    end
end

for questId, data in pairs(tbc) do
    local quest = trinity[questId]

    if quest then
        if not quest[questKeys.objectives] and data[questKeys.objectives] then
            print("Adding TBC objectives to quest " .. questId)
            quest[questKeys.objectives] = data[questKeys.objectives]
        end
    end
end

for questId, data in pairs(wotlk) do
    local quest = trinity[questId]

    if quest then
        if not quest[questKeys.objectives] and data[questKeys.objectives] then
            print("Adding WotLK objectives to quest " .. questId)
            quest[questKeys.objectives] = data[questKeys.objectives]
        end
        if not quest[questKeys.preQuestSingle] and data[questKeys.preQuestSingle] then
            print("Adding WotLK preQuestSingle to quest " .. questId)
            quest[questKeys.preQuestSingle] = data[questKeys.preQuestSingle]
        end
        if not quest[questKeys.preQuestGroup] and data[questKeys.preQuestGroup] then
            print("Adding WotLK preQuestGroup to quest " .. questId)
            quest[questKeys.preQuestGroup] = data[questKeys.preQuestGroup]
        end
        if not quest[questKeys.requiredSourceItems] and data[questKeys.requiredSourceItems] then
            print("Adding WotLK requiredSourceItems to quest " .. questId)
            quest[questKeys.requiredSourceItems] = data[questKeys.requiredSourceItems]
        end
        if (not quest[questKeys.nextQuestInChain] or quest[questKeys.nextQuestInChain] == 0) and data[questKeys.nextQuestInChain] then
            print("Adding WotLK nextQuestInChain to quest " .. questId)
            quest[questKeys.nextQuestInChain] = data[questKeys.nextQuestInChain]
        end
        if not quest[questKeys.childQuests] and data[questKeys.childQuests] then
            print("Adding WotLK childQuests to quest " .. questId)
            quest[questKeys.childQuests] = data[questKeys.childQuests]
        end
        if (not quest[questKeys.parentQuest] or quest[questKeys.parentQuest] == 0) and data[questKeys.parentQuest] then
            print("Adding WotLK parentQuest to quest " .. questId)
            quest[questKeys.parentQuest] = data[questKeys.parentQuest]
        end
    end
end

printToFile(trinity, questKeys)
