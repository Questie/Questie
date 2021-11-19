WOW_PROJECT_ID = 2
WOW_PROJECT_CLASSIC = 2
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
WOW_PROJECT_MAINLINE = 1

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
UnitFactionGroup = function()
    return arg[1] or "Horde"
end
UnitClass = function()
    return "Druid", "DRUID", 11
end
GetLocale = function()
    return "enUS"
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

local function loadTOC(file)
    local rfile = io.open(file, "r")
    for line in rfile:lines() do
        if string.len(line) > 1 and string.byte(line, 1) ~= 35 then
            line = line:gsub("\\", "/")
            local r
            local chunck = loadfile(line)
            if chunck then
                r = pcall(chunck, addonName, addonTable)
            end
            if r then
                --print("Loaded " .. line)
            else
                --print("Error loading " .. line .. ": " .. e)
            end
        end
    end
end

local function _CheckClassicDatabase()
    print("Compiling Classic database...")

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

    print("Classic database compiled successfully")
end
_CheckClassicDatabase()

Questie = nil -- Reset for second test

local function _CheckTBCDatabase()
    print("Compiling TBC database...")
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

    print("Classic database compiled successfully")
end
_CheckTBCDatabase()
