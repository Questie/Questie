require("cli.dump")
require("cli.common")

WOW_PROJECT_ID = 2
GetBuildInfo = function() return "1.14.3", "44403", "Jun 27 2022", 11403 end
UnitLevel = function() return 60 end

local function _GetClassicDatabase()
    print("\n\27[36mCompiling Classic database...\27[0m")
    loadTOC("Questie-Classic.toc")

    assert(Questie.IsEra, "Questie is not started for Era/HC/Anniversary")

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

return _GetClassicDatabase()
