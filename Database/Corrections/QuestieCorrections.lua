QuestieCorrections = {...}

--[[
    This file load the corrections of the database files.

    It is a separate file so we can upstream those changes easier to cmangos and can still
    update the database files with a script.

    Most of the corrections can be done by accessing a specific key instead of copying the
    whole object over and change it.
    You can find the keys at the beginning of each file (e.g. 'questKeys' are at the beginning of 'questDB.lua').
--]]

function QuestieCorrections:Initialize()
    QuestieCorrections.itemFixes = QuestieItemFixes:Load()
    QuestieItemFixes:LoadFactionFixes()
    QuestieCorrections.questItemBlacklist = QuestieItemBlacklist:Load()
    QuestieCorrections.npcFixes = QuestieNPCFixes:Load()
    QuestieCorrections.objectFixes = QuestieObjectFixes:Load()
    QuestieObjectFixes:LoadFactionFixes()
    QuestieCorrections.questFixes = QuestieQuestFixes:Load()
    QuestieCorrections.hiddenQuests = QuestieQuestBlacklist:Load()
    if(QuestieEvent) then
        QuestieEvent:Load();
    end
end