require("cli.dump")

WOW_PROJECT_ID = 2
WOW_PROJECT_CLASSIC = 2
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
WOW_PROJECT_WRATH_CLASSIC = 11
WOW_PROJECT_CATACLYSM_CLASSIC = 14
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
GetBuildInfo = function()
    return "1.14.3", "44403", "Jun 27 2022", 11403
end
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
UnitLevel = function()
    return 60
end
GetLocale = function()
    return "deDE"
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
            ---@diagnostic disable-next-line: inject-field
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

local function print(text)
    io.stderr:write(tostring(text) .. "\n")
end

local function loadTOC(file)
    local rfile = io.open(file, "r")
    assert(rfile, "Failed to open " .. file)
    for line in rfile:lines() do
        if string.len(line) > 1 and string.byte(line, 1) ~= 35 and (not string.find(line, ".xml")) then
            line = line:gsub("\\", "/")
            line = line:gsub("%s+", "")
            local pcallResult, errorMessage
            local chunck = loadfile(line)
            if chunck then
                pcallResult, errorMessage = pcall(chunck, addonName, addonTable)
            end
            if (not pcallResult) then
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

local function _CheckGermanClassicDatabase()
    print("\n\27[36mCompiling Classic database...\27[0m")
    loadTOC("Questie-Classic.toc")
    dofile("Localization/lookups/Classic/lookupItems/deDE.lua")
    dofile("Localization/lookups/Classic/lookupNpcs/deDE.lua")
    dofile("Localization/lookups/Classic/lookupObjects/deDE.lua")
    dofile("Localization/lookups/Classic/lookupQuests/deDE.lua")

    assert(Questie.IsEra, "Questie is not started for Era/HC/Anniversary")

    Questie.Debug = _Debug
    Questie.Error = _ErrorOrWarning
    Questie.Warning = _ErrorOrWarning

    ---@diagnostic disable-next-line: missing-fields -- Minimal setup does not need all fields
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

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

    print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. "...")

    Questie:SetIcons()
    QuestieLoader:ImportModule("ZoneDB"):Initialize()

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
    QuestieDBCompiler:Compile()

    QuestieDB:Initialize()

    assert(QuestieDB.GetQuest(2).name == "Klaue von Scharfkralle")
    assert(QuestieDB:GetNPC(3).name == "Fleischfresser")
    assert(QuestieDB:GetObject(31).name == "Alte Löwenstatue")
    assert(QuestieDB:GetItem(159).name == "Erfrischendes Quellwasser")
end

_CheckGermanClassicDatabase()
