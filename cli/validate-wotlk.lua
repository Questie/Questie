require("cli.dump")
local Validators = require("cli.validators")

WOW_PROJECT_ID = 11

dofile("cli/apiMocks.lua")
local print = require("cli.print")
local loadTOC = require("cli.loadTOC")

GetBuildInfo = function()
    return "3.4.0", "44644", "Jun 12 2022", 30400
end
UnitLevel = function()
    return 80
end
GetMaxPlayerLevel = function()
    return 80
end

local function _Debug(_, ...)
    --print(...)
end

local function _ErrorOrWarning(_, text, ...)
    print(text)
end

local function _CheckWotlkDatabase()
    print("\n\27[36mCompiling Wotlk database...\27[0m")
    loadTOC("Questie-WOTLKC.toc")

    assert(Questie.IsWotlk, "Questie is not started for WotLK")

    Questie.Debug = _Debug
    Questie.Error = _ErrorOrWarning
    Questie.Warning = _ErrorOrWarning

    Questie.db = {
        char = {
            showEventQuests = false
        },
        global = {},
        profile = {}
    }
    QuestieConfig = {}

    ---@type QuestieDB
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    ---@type QuestieCorrections
    local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    ---@type l10n
    local l10n = QuestieLoader:ImportModule("l10n")
    ---@type ZoneDB
    local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. l10n("..."))

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

    print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. l10n("..."))

    Questie:SetIcons()
    ZoneDB:Initialize()

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

    print("\n\27[32mWotlk database compiled successfully\27[0m\n")

    -- We accept blacklisted quests as questStarts and questEnds for now
    Validators.checkNpcQuestStarts(QuestieDB.npcData, QuestieDB.npcKeys, QuestieDB.questData, QuestieDB.questKeys)
    Validators.checkNpcQuestEnds(QuestieDB.npcData, QuestieDB.npcKeys, QuestieDB.questData, QuestieDB.questKeys)
    Validators.checkObjectQuestStarts(QuestieDB.objectData, QuestieDB.objectKeys, QuestieDB.questData, QuestieDB.questKeys)
    Validators.checkObjectQuestEnds(QuestieDB.objectData, QuestieDB.objectKeys, QuestieDB.questData, QuestieDB.questKeys)

    -- Remove hidden quests from the database as we don't want to validate them
    for questId, _ in pairs(QuestieCorrections.hiddenQuests) do
        QuestieDB.questData[questId] = nil
    end

    Validators.checkRequiredRaces(QuestieDB.questData, QuestieDB.questKeys, QuestieDB.raceKeys)
    Validators.checkRequiredSourceItems(QuestieDB.questData, QuestieDB.questKeys)
    Validators.checkPreQuestExclusiveness(QuestieDB.questData, QuestieDB.questKeys)
    Validators.checkParentChildQuestRelations(QuestieDB.questData, QuestieDB.questKeys)
    Validators.checkQuestStarters(QuestieDB.questData, QuestieDB.questKeys, QuestieDB.npcData, QuestieDB.npcKeys, QuestieDB.objectData, QuestieDB.itemData)
    Validators.checkQuestFinishers(QuestieDB.questData, QuestieDB.questKeys, QuestieDB.npcData, QuestieDB.objectData)
    Validators.checkObjectives(QuestieDB.questData, QuestieDB.questKeys, QuestieDB.npcData, QuestieDB.objectData, QuestieDB.itemData)
    Validators.checkObjectiveOrderMoves(QuestieDB.questData, QuestieDB.questKeys, QuestieCorrections.objectiveOrderMoves)
    Validators.checkNpcSpawnAreaIds(QuestieDB.npcData, QuestieDB.npcKeys, function(areaId) return ZoneDB:GetUiMapIdByAreaId(areaId) end)
    Validators.checkObjectSpawnAreaIds(QuestieDB.objectData, QuestieDB.objectKeys, function(areaId) return ZoneDB:GetUiMapIdByAreaId(areaId) end)
    Validators.checkQuestExtraObjectiveSpawnAreaIds(QuestieDB.questData, QuestieDB.questKeys, function(areaId) return ZoneDB:GetUiMapIdByAreaId(areaId) end)
    Validators.checkQuestTriggerEndSpawnAreaIds(QuestieDB.questData, QuestieDB.questKeys, function(areaId) return ZoneDB:GetUiMapIdByAreaId(areaId) end)
end
--? It is REALLLY slow and designed to be run through docker otherwise you have to change the path.
-- local profiler = require("cli/profiler")
-- profiler.start()
_CheckWotlkDatabase()
-- profiler.stop()
-- profiler.report("/code/profiler.log")
