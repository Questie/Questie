require("cli.dump")
local Validators = require("cli.validators")

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

local function _CheckSoDDatabase()
    print("\n\27[36mCompiling SoD database...\27[0m")
    loadTOC("Questie-Classic.toc")

    assert(Questie.IsSoD, "Questie is not started for Season of Discovery")

    ---@type QuestieDB
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    ---@type QuestieCorrections
    local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    ---@type l10n
    local l10n = QuestieLoader:ImportModule("l10n")

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

    print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. "...")

    QuestieCorrections:Initialize({
        ["npcData"] = QuestieDB.npcData,
        ["objectData"] = QuestieDB.objectData,
        ["itemData"] = QuestieDB.itemData,
        ["questData"] = QuestieDB.questData
    })

    local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")

    Questie.db.global.debugEnabled = true
    QuestieDBCompiler:Compile(function() end)

    QuestieDB:Initialize()

    print("\n\27[36mValidating objects...\27[0m")
    QuestieDBCompiler:ValidateObjects()
    print("\n\27[36mValidating items...\27[0m")
    QuestieDBCompiler:ValidateItems()
    print("\n\27[36mValidating NPCs...\27[0m")
    QuestieDBCompiler:ValidateNPCs()
    print("\n\27[36mValidating quests...\27[0m")
    QuestieDBCompiler:ValidateQuests()

    print("\n\27[32mSoD database compiled successfully\27[0m")

    -- Remove hidden quests from the database as we don't want to validate them
    for questId, _ in pairs(QuestieCorrections.hiddenQuests) do
        QuestieDB.questData[questId] = nil
    end

    Validators.checkRequiredSourceItems(QuestieDB.questData, QuestieDB.questKeys)
    Validators.checkPreQuestExclusiveness(QuestieDB.questData, QuestieDB.questKeys)
    Validators.checkParentChildQuestRelations(QuestieDB.questData, QuestieDB.questKeys)
end

_CheckSoDDatabase()
