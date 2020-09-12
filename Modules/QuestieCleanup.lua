---@class Cleanup
local QuestieCleanup = QuestieLoader:CreateModule("Cleanup")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@tyle QuestieDBCompiler
local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")

function QuestieCleanup:Run()

    if Questie.db.global.debugEnabled then
        print("Validating objects...")
        QuestieDBCompiler:Validate()
        print("Validating items...")
        QuestieDBCompiler:ValidateItems()
        print("Validating quests...")
        QuestieDBCompiler:ValidateQuests()
    end

    -- clean up raw db
    QuestieDB.npcData = nil
    QuestieDB.questData = nil
    QuestieDB.objectData = nil
    QuestieDB.itemData = nil

    -- clean up lang
    LangItemLookup = nil
    LangNameLookup = nil
    LangObjectLookup = nil
    LangQuestLookup = nil

    -- we call this here to make sure there isn't a lag spike later on
    collectgarbage()
end