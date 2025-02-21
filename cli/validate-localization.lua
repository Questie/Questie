require("cli.dump")
local Validators = require("cli.validators")
require("cli.common")

WOW_PROJECT_ID = 2
GetBuildInfo = function() return "1.14.3", "44403", "Jun 27 2022", 11403 end
UnitLevel = function() return 60 end
GetLocale = function() return "deDE" end

local function _CheckGermanClassicDatabase()
    print("\n\27[36mCompiling Classic database...\27[0m")
    loadTOC("Questie-Classic.toc")
    dofile("Localization/lookups/Classic/lookupItems/deDE.lua")
    dofile("Localization/lookups/Classic/lookupNpcs/deDE.lua")
    dofile("Localization/lookups/Classic/lookupObjects/deDE.lua")
    dofile("Localization/lookups/Classic/lookupQuests/deDE.lua")

    assert(Questie.IsEra, "Questie is not started for Era/HC/Anniversary")

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
    l10n.InitializeUILocale()
    l10n:Initialize()

    local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")

    Questie.db.global.debugEnabled = true
    QuestieDBCompiler:Compile(function() end)

    QuestieDB:Initialize()

    assert(QuestieDB.GetQuest(2).name == "Klaue von Scharfkralle")
    assert(QuestieDB:GetNPC(3).name == "Fleischfresser")
    assert(QuestieDB:GetObject(31).name == "Alte Löwenstatue")
    assert(QuestieDB:GetItem(159).name == "Erfrischendes Quellwasser")
end

_CheckGermanClassicDatabase()
