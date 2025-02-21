require("cli.dump")
require("cli.common")

WOW_PROJECT_ID = 11
GetBuildInfo = function() return "3.4.0", "44644", "Jun 12 2022", 30400 end
UnitLevel = function() return 80 end

local function _GetWotlkDatabase()
    print("\n\27[36mCompiling Wotlk database...\27[0m")
    loadTOC("Questie-WOTLKC.toc")

    assert(Questie.IsWotlk, "Questie is not started for WotLK")

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

return _GetWotlkDatabase()
