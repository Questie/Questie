require("cli.dump")
require("cli.common")

WOW_PROJECT_ID = 14
GetBuildInfo = function() return "4.4.0", "53863", "Mar 28 2024", 40400 end
UnitLevel = function() return 60 end

local function _GetCataDatabase()
    print("\n\27[36mCompiling Cata database...\27[0m")
    loadTOC("Questie-Cata.toc")

    assert(Questie.IsCata, "Questie is not started for Cataclysm")
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

return _GetCataDatabase()
