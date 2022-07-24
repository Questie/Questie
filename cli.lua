WOW_PROJECT_ID = 2
WOW_PROJECT_CLASSIC = 2
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
WOW_PROJECT_MAINLINE = 1

QUEST_MONSTERS_KILLED = "QUEST_MONSTERS_KILLED"
QUEST_ITEMS_NEEDED = "QUEST_ITEMS_NEEDED"
QUEST_OBJECTS_FOUND = "QUEST_OBJECTS_FOUND"

tremove = table.remove
tinsert = table.insert
coroutine.yield = function() end -- no need to yield in the cli (TODO: maybe find a less hacky fix)
mod = function(a, b)
    return a % b
end
bit = require("bit32")

GetBuildInfo = function()
    return "2.5.1", "38644", "May 11 2021", "20501"
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
GetLocale = function()
    return "enUS"
end
GetQuestGreenRange = function()
    return 10
end
UnitName = function()
    return "QuestieNPC"
end
LibStub = function()
    return {["NewAddon"] = function() return {} end}
end
CreateFrame = function()
    return {}
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

-- WoW addon namespace
local addonName = "Questie"
local addonTable = {}

local function print(text)
    io.stderr:write(tostring(text) .. "\n")
end

local function loadTOC(file)
    local rfile = io.open(file, "r")
    for line in rfile:lines() do
        if string.len(line) > 1 and string.byte(line, 1) ~= 35 then
            line = line:gsub("\\", "/")
            line = line:gsub("%s+", "")
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

local function _CheckClassicDatabase()
    print("\n\27[36mCompiling Classic database...\27[0m")

    loadTOC("Questie-Classic.toc")

    function Questie:Debug(...)
        --print(...)
    end

    function Questie:Error(text, ...)
        io.stderr:write(tostring(text) .. "\n")
    end

    function Questie:Warning(text, ...)
        io.stderr:write(tostring(text) .. "\n")
    end

    Questie.db = {
        char = {
            showEventQuests = false
        },
        global = {}
    }
    QuestieConfig = {}

    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    local l10n = QuestieLoader:ImportModule("l10n")

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

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
    print("\n\27[36mValidating objects...\27[0m")
    QuestieDBCompiler:ValidateObjects()
    print("\n\27[36mValidating items...\27[0m")
    QuestieDBCompiler:ValidateItems()
    print("\n\27[36mValidating NPCs...\27[0m")
    QuestieDBCompiler:ValidateNPCs()
    print("\n\27[36mValidating quests...\27[0m")
    QuestieDBCompiler:ValidateQuests()

    print("\n\27[32mClassic database compiled successfully\27[0m")
end
_CheckClassicDatabase()

Questie = nil -- Reset for second test

local function _CheckTBCDatabase()
    print("\n\27[36mCompiling TBC database...\27[0m")

    WOW_PROJECT_ID = 5

    loadTOC("Questie-BCC.toc")

    function Questie:Debug(...)
        --print(...)
    end

    function Questie:Error(text, ...)
        io.stderr:write(tostring(text) .. "\n")
    end

    function Questie:Warning(text, ...)
        io.stderr:write(tostring(text) .. "\n")
    end

    Questie.db = {
        char = {
            showEventQuests = false
        },
        global = {}
    }
    QuestieConfig = {}

    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    local l10n = QuestieLoader:ImportModule("l10n")

    print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

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
    print("\n\27[36mValidating objects...\27[0m")
    QuestieDBCompiler:ValidateObjects()
    print("\n\27[36mValidating items...\27[0m")
    QuestieDBCompiler:ValidateItems()
    print("\n\27[36mValidating NPCs...\27[0m")
    QuestieDBCompiler:ValidateNPCs()
    print("\n\27[36mValidating quests...\27[0m")
    QuestieDBCompiler:ValidateQuests()

    print("\n\27[32mTBC database compiled successfully\27[0m\n")
end
_CheckTBCDatabase()
