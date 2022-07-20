WOW_PROJECT_ID = 2
WOW_PROJECT_CLASSIC = 2
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
WOW_PROJECT_MAINLINE = 1

QUEST_MONSTERS_KILLED = "QUEST_MONSTERS_KILLED"
QUEST_ITEMS_NEEDED = "QUEST_ITEMS_NEEDED"
QUEST_OBJECTS_FOUND = "QUEST_OBJECTS_FOUND"
ERR_QUEST_ACCEPTED_S = "ERR_QUEST_ACCEPTED_S"
ERR_QUEST_COMPLETE_S = "ERR_QUEST_COMPLETE_S"

tremove = table.remove
tinsert = table.insert

local _EmptyDummyFunction = function() end
local _TableDummyFunction = function() return {} end

coroutine.yield = _EmptyDummyFunction -- no need to yield in the cli (TODO: maybe find a less hacky fix)
mod = function(a, b)
    return a % b
end
bit = require("bit32")
hooksecurefunc = _EmptyDummyFunction
GetAddOnInfo = function()
    return "Questie", "|cFFFFFFFFQuestie|r|cFF00FF00 v6.3.9 (TBC B2)|r", "A standalone Classic QuestHelper", true, "INSECURE", false
end
GetAddOnMetadata = function()
    return "6.6.0"
end
GetTime = function()
    return os.time(os.date("!*t")) - 1616930000 -- convert unix time to wow time (actually accurate)
end
IsAddOnLoaded = function() return false, true end
UnitFactionGroup = function()
    return arg[1] or "Horde"
end
UnitClass = function()
    return "Druid", "DRUID", 11
end
GetLocale = function()
    return "enUS"
end
GetQuestGreenRange = function()
    return 10
end
UnitName = function()
    return "QuestieNPC"
end
LibStub = {
    NewLibrary = _EmptyDummyFunction,
    GetLibrary = _TableDummyFunction,
}
setmetatable(LibStub, { __call = function(_, ...)
    return {NewAddon = _TableDummyFunction, New = _TableDummyFunction }
end})
StaticPopupDialogs = {}

CreateFrame = function()
    return {
        Show = _EmptyDummyFunction,
        SetScript = _EmptyDummyFunction,
        RegisterEvent = _EmptyDummyFunction,
    }
end
C_QuestLog = {}
C_Timer = {
    After = function(_, f)
        f()
    end,
    NewTicker = function(_, f, times)
        if times then
            for _=1,times do
                f()
            end
        else
            -- hack
            local finished = false
            QuestieLoader:ImportModule("DBCompiler").ticker = {
                Cancel = function()
                    finished = true
                end
            }
            while not finished do
                f()
            end
        end
    end
}
C_Seasons = {
    HasActiveSeason = function() return false end,
}

ItemRefTooltip = {
    SetHyperlink = _EmptyDummyFunction,
    IsShown = _EmptyDummyFunction,
    SetOwner = _EmptyDummyFunction,
    Show = _EmptyDummyFunction,
    Hide = _EmptyDummyFunction,
    AddLine = _EmptyDummyFunction,
    HookScript = _EmptyDummyFunction,
}

C_Map = {}

-- WoW addon namespace
local addonName = "Questie"
local addonTable = {}

local function loadTOC(file)
    local rfile = io.open(file, "r")
    for line in rfile:lines() do
        if string.len(line) > 1 and string.byte(line, 1) ~= 35 and (not string.find(line, ".xml")) then
            line = line:gsub("\\", "/")
            local pcallResult, errorMessage
            local chunck = loadfile(line)
            if chunck then
                pcallResult, errorMessage = pcall(chunck, addonName, addonTable)
            end
            if pcallResult then
                --print("Loaded " .. line)
            else
                if errorMessage then
                    print("Error loading " .. line .. ": " .. errorMessage)
                else
                    print("Error loading " .. line .. " - No errorMessage")
                end
            end
        end
    end
end

local function _Debug(_, ...)
    --print(...)
end

local function _ErrorOrWarning(_, text, ...)
    io.stderr:write(tostring(text) .. "\n")
end

local function _CheckClassicDatabase()
    GetBuildInfo = function()
        return "1.14.3", "44403", "Jun 27 2022", 11403
    end

    print("Compiling Classic database...")

    loadTOC("Questie-Classic.toc")

    Questie.Debug = _Debug
    Questie.Error = _ErrorOrWarning
    Questie.Warning = _ErrorOrWarning

    Questie.db = {
        char = {
            showEventQuests = false
        },
        global = {}
    }
    QuestieConfig = {}
    Questie.IsWotlk = false -- TODO: Remove me once IsWotlk is correctly set

    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    local l10n = QuestieLoader:ImportModule("l10n")

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")
    QuestieDB.npcData = loadstring(QuestieDB.npcData)
    QuestieDB.npcData = QuestieDB.npcData()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)
    QuestieDB.objectData = QuestieDB.objectData()
    QuestieDB.questData = loadstring(QuestieDB.questData)
    QuestieDB.questData = QuestieDB.questData()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)
    QuestieDB.itemData = QuestieDB.itemData()
    print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. "...")

    QuestieLoader:ImportModule("QuestieFramePool"):SetIcons()
    QuestieLoader:ImportModule("ZoneDB"):Initialize()

    QuestieCorrections:Initialize({
        ["npcData"] = QuestieDB.npcData,
        ["objectData"] = QuestieDB.objectData,
        ["itemData"] = QuestieDB.itemData,
        ["questData"] = QuestieDB.questData
    })

    local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")

    QuestieDBCompiler:Compile(function() end)
    print("Validating objects...")
    QuestieDBCompiler:ValidateObjects()
    print("Validating items...")
    QuestieDBCompiler:ValidateItems()
    print("Validating NPCs...")
    QuestieDBCompiler:ValidateNPCs()
    print("Validating quests...")
    QuestieDBCompiler:ValidateQuests()

    print("Classic database compiled successfully\n")
end
_CheckClassicDatabase()

Questie = nil -- Reset for second test

local function _CheckTBCDatabase()
    GetBuildInfo = function()
        return "2.5.1", "38644", "May 11 2021", 20501
    end

    print("Compiling TBC database...")
    WOW_PROJECT_ID = 5

    loadTOC("Questie-BCC.toc")

    Questie.Debug = _Debug
    Questie.Error = _ErrorOrWarning
    Questie.Warning = _ErrorOrWarning

    Questie.db = {
        char = {
            showEventQuests = false
        },
        global = {}
    }
    QuestieConfig = {}
    Questie.IsWotlk = false -- TODO: Remove me once IsWotlk is correctly set

    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    local l10n = QuestieLoader:ImportModule("l10n")

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")
    -- Classic fields need to be filled, because we only load the database and not all Questie files
    QuestieDB.npcData = {}
    QuestieDB.objectData = {}
    QuestieDB.questData = {}
    QuestieDB.itemData = {}
    QuestieDB.npcDataTBC = loadstring(QuestieDB.npcDataTBC)
    QuestieDB.npcDataTBC = QuestieDB.npcDataTBC()
    QuestieDB.objectDataTBC = loadstring(QuestieDB.objectDataTBC)
    QuestieDB.objectDataTBC = QuestieDB.objectDataTBC()
    QuestieDB.questDataTBC = loadstring(QuestieDB.questDataTBC)
    QuestieDB.questDataTBC = QuestieDB.questDataTBC()
    QuestieDB.itemDataTBC = loadstring(QuestieDB.itemDataTBC)
    QuestieDB.itemDataTBC = QuestieDB.itemDataTBC()
    print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. "...")

    QuestieLoader:ImportModule("QuestieFramePool"):SetIcons()
    QuestieLoader:ImportModule("ZoneDB"):Initialize()

    QuestieCorrections:Initialize({
        ["npcData"] = QuestieDB.npcDataTBC,
        ["objectData"] = QuestieDB.objectDataTBC,
        ["itemData"] = QuestieDB.itemDataTBC,
        ["questData"] = QuestieDB.questDataTBC
    })

    local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")

    QuestieDBCompiler:Compile(function() end)
    print("Validating objects...")
    QuestieDBCompiler:ValidateObjects()
    print("Validating items...")
    QuestieDBCompiler:ValidateItems()
    print("Validating NPCs...")
    QuestieDBCompiler:ValidateNPCs()
    print("Validating quests...")
    QuestieDBCompiler:ValidateQuests()

    print("TBC database compiled successfully")
end
_CheckTBCDatabase()

Questie = nil -- Reset for thrid test

local function _CheckWotlkDatabase()
    GetBuildInfo = function()
        return "3.4.0", "44644", "Jun 12 2022", 30400
    end

    print("Compiling Wotlk database...")
    WOW_PROJECT_ID = 5

    loadTOC("Questie-WOTLKC.toc")

    Questie.Debug = _Debug
    Questie.Error = _ErrorOrWarning
    Questie.Warning = _ErrorOrWarning

    Questie.db = {
        char = {
            showEventQuests = false
        },
        global = {}
    }
    QuestieConfig = {}
    Questie.IsWotlk = true

    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    local l10n = QuestieLoader:ImportModule("l10n")

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")
    -- Classic fields need to be filled, because we only load the database and not all Questie files
    QuestieDB.npcData = {}
    QuestieDB.objectData = {}
    QuestieDB.questData = {}
    QuestieDB.itemData = {}
    QuestieDB.npcDataWotlk = loadstring(QuestieDB.npcDataWotlk)
    QuestieDB.npcDataWotlk = QuestieDB.npcDataWotlk()
    QuestieDB.objectDataWotlk = loadstring(QuestieDB.objectDataWotlk)
    QuestieDB.objectDataWotlk = QuestieDB.objectDataWotlk()
    QuestieDB.questDataWotlk = loadstring(QuestieDB.questDataWotlk)
    QuestieDB.questDataWotlk = QuestieDB.questDataWotlk()
    QuestieDB.itemDataWotlk = loadstring(QuestieDB.itemDataWotlk)
    QuestieDB.itemDataWotlk = QuestieDB.itemDataWotlk()
    print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. "...")

    QuestieLoader:ImportModule("QuestieFramePool"):SetIcons()
    QuestieLoader:ImportModule("ZoneDB"):Initialize()

    QuestieCorrections:Initialize({
        ["npcData"] = QuestieDB.npcDataWotlk,
        ["objectData"] = QuestieDB.objectDataWotlk,
        ["itemData"] = QuestieDB.itemDataWotlk,
        ["questData"] = QuestieDB.questDataWotlk
    })

    local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")

    QuestieDBCompiler:Compile(function() end)
    print("Validating objects...")
    QuestieDBCompiler:ValidateObjects()
    print("Validating items...")
    QuestieDBCompiler:ValidateItems()
    print("Validating NPCs...")
    QuestieDBCompiler:ValidateNPCs()
    print("Validating quests...")
    QuestieDBCompiler:ValidateQuests()

    print("Wotlk database compiled successfully")
end
_CheckWotlkDatabase()
