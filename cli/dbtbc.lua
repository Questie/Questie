require("cli.dump")
require("cli.common")

WOW_PROJECT_ID = 5
GetBuildInfo = function() return "2.5.1", "38644", "May 11 2021", 20501 end
UnitLevel = function() return 60 end

local function _GetTBCDatabase()
    print("\n\27[36mCompiling TBC database...\27[0m")
    loadTOC("Questie-BCC.toc")

    assert(Questie.IsTBC, "Questie is not started for TBC")

    ---@type QuestieDB
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    ---@type l10n
    local l10n = QuestieLoader:ImportModule("l10n")

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

    return QuestieDB
end

return _GetTBCDatabase()
