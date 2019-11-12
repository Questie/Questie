QuestieCorrections = {...}
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

--[[
    This file load the corrections of the database files.

    It is a separate file so we can upstream those changes easier to cmangos and can still
    update the database files with a script.

    Most of the corrections can be done by accessing a specific key instead of copying the
    whole object over and change it.
    You can find the keys at the beginning of each file (e.g. 'questKeys' are at the beginning of 'questDB.lua').

    Further information on how to use this can be found at the wiki
    https://github.com/AeroScripts/QuestieDev/wiki/Corrections
--]]

function QuestieCorrections:Initialize()
    for id, data in pairs(QuestieItemFixes:Load()) do
        for key, value in pairs(data) do
            QuestieDB.itemData[id][key] = value
        end
    end

    for id, data in pairs(QuestieItemFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            QuestieDB.itemData[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:Load()) do
        for key, value in pairs(data) do
            QuestieDB.npcData[id][key] = value
        end
    end

    for id, data in pairs(QuestieObjectFixes:Load()) do
        for key, value in pairs(data) do
            QuestieDB.objectData[id][key] = value
        end
    end

    for id, data in pairs(QuestieObjectFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            QuestieDB.objectData[id][key] = value
        end
    end

    for id, data in pairs(QuestieQuestFixes:Load()) do
        for key, value in pairs(data) do
            QuestieDB.questData[id][key] = value
        end
    end

    QuestieCorrections.questItemBlacklist = QuestieItemBlacklist:Load()
    QuestieCorrections.hiddenQuests = QuestieQuestBlacklist:Load()

    if QuestieEvent then
        QuestieEvent:Load()
    end
end