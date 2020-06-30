---@class QuestieCorrections
local QuestieCorrections = QuestieLoader:CreateModule("QuestieCorrections")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieQuestFixes
local QuestieQuestFixes = QuestieLoader:ImportModule("QuestieQuestFixes")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieItemFixes
local QuestieItemFixes = QuestieLoader:ImportModule("QuestieItemFixes")
---@type QuestieItemBlacklist
local QuestieItemBlacklist = QuestieLoader:ImportModule("QuestieItemBlacklist")
---@type QuestieNPCFixes
local QuestieNPCFixes = QuestieLoader:ImportModule("QuestieNPCFixes")
---@type QuestieObjectFixes
local QuestieObjectFixes = QuestieLoader:ImportModule("QuestieObjectFixes")

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
            if not QuestieDB.itemData[id] then
                QuestieDB.itemData[id] = {}
            end
            QuestieDB.itemData[id][key] = value
        end
    end

    for id, data in pairs(QuestieItemFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.itemDataOverrides[id] then
                QuestieDB.itemDataOverrides[id] = {}
            end
            QuestieDB.itemDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:Load()) do
        for key, value in pairs(data) do
            if not QuestieDB.npcData[id] then
                QuestieDB.npcData[id] = {}
            end
            QuestieDB.npcData[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.npcDataOverrides[id] then
                QuestieDB.npcDataOverrides[id] = {}
            end
            QuestieDB.npcDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieObjectFixes:Load()) do
        for key, value in pairs(data) do
            QuestieDB.objectData[id][key] = value
        end
    end

    for id, data in pairs(QuestieObjectFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.objectDataOverrides[id] then
                QuestieDB.objectDataOverrides[id] = {}
            end
            QuestieDB.objectDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieQuestFixes:Load()) do
        for key, value in pairs(data) do
            if QuestieDB.questData[id] then
                QuestieDB.questData[id][key] = value
            end
        end
    end

    for id, data in pairs(QuestieQuestFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
			if not QuestieDB.questDataOverrides[id] then
                QuestieDB.questDataOverrides[id] = {}
            end
            QuestieDB.questDataOverrides[id][key] = value
        end
    end

    QuestieCorrections.questItemBlacklist = QuestieItemBlacklist:Load()
    QuestieCorrections.hiddenQuests = QuestieQuestBlacklist:Load()

    if Questie.db.char.showEventQuests then
        C_Timer.After(1, function()
             -- This is done with a delay because on startup the Blizzard API seems to be
             -- very slow and therefore the date calculation in QuestieEvents isn't done
             -- correctly.
            QuestieEvent:Load()
        end)
    end
end