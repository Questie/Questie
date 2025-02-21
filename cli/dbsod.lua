require("cli.dump")
require("cli.common")

WOW_PROJECT_ID = 2
GetBuildInfo = function() return "1.15.0", "52409", "Dev 1 2023", 11500 end
UnitLevel = function() return 25 end

GetMaxPlayerLevel = function() return 25 end
Enum = {
    SeasonID = {
        SeasonOfMastery = 1,
        SeasonOfDiscovery = 2,
        Hardcore = 3
    }
}
C_Seasons = {
    HasActiveSeason = function() return true end,
    GetActiveSeason = function() return Enum.SeasonID.SeasonOfDiscovery end,
}

local function _GetSoDDatabase()
    print("\n\27[36mCompiling SoD database...\27[0m")
    loadTOC("Questie-Classic.toc")

    assert(Questie.IsSoD, "Questie is not started for Season of Discovery")

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

return _GetSoDDatabase()
