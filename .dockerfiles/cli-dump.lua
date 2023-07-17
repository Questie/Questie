#!/usr/bin/lua5.1

--[[
This script dumps the files from Database directory including their corrections
into a single file per datatype and expansion in the .dockerfiles/Database
directory.

To run this script locally bit32 and argparse libraries are required:

luarocks install --lua-version 5.1 --local bit32
luarocks install --lua-version 5.1 --local argparse

You might need to point Lua to the correct libraries for 5.1:

eval "$(luarocks --lua-version=5.1 path)"

Then you can run the script from the repository root:

lua5.1 .dockerfiles/cli-dump.lua

Run this to reset your dependencies to the default Lua version after:

eval "$(luarocks path)"
--]]

require("cli.dump")
require("cli.dumpData")
local argparse = require("argparse")

local parser = argparse("cli-dump", "test")
parser:option("-e --expansion", "Expansion")
parser:option("-d --data", "Type of data All, Quest, Item, Object or Item")
local args = parser:parse()

-- We don't want to print anything from within the addon really, so we override print
-- PrintL = print
-- print = function(...)
--     return
-- end


WOW_PROJECT_ID = 2
WOW_PROJECT_CLASSIC = 2
WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
WOW_PROJECT_WRATH_CLASSIC = 11
WOW_PROJECT_MAINLINE = 1

QUEST_MONSTERS_KILLED = "QUEST_MONSTERS_KILLED"
QUEST_ITEMS_NEEDED = "QUEST_ITEMS_NEEDED"
QUEST_OBJECTS_FOUND = "QUEST_OBJECTS_FOUND"
ERR_QUEST_ACCEPTED_S = "ERR_QUEST_ACCEPTED_S"
ERR_QUEST_COMPLETE_S = "ERR_QUEST_COMPLETE_S"

tremove = table.remove
tinsert = table.insert

local _EmptyDummyFunction = function()
end
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
    return "Horde"
end
UnitClass = function()
    return "Druid", "DRUID", 11
end
UnitLevel = function()
    return 60
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
setmetatable(LibStub, {
    __call = function(_, ...)
        return { NewAddon = _TableDummyFunction, New = _TableDummyFunction }
    end
})
StaticPopupDialogs = {}

CreateFrame = function()
    return {
        Show = _EmptyDummyFunction,
        SetScript = _EmptyDummyFunction,
        RegisterEvent = _EmptyDummyFunction,
    }
end
GetNumQuestWatches = function()
    return 0
end

GetTrackedAchievements = function()
    return nil
end

C_QuestLog = {}
C_Timer = {
    After = function(_, f)
        f()
    end,
    NewTicker = function(_, f, times)
        if times then
            for _ = 1, times do
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

function printL(text)
    io.stderr:write(tostring(text) .. "\n")
end

local function loadTOC(file)
    local rfile = io.open(file, "r")
    for line in rfile:lines() do
        if string.len(line) > 1 and string.byte(line, 1) ~= 35 and (not string.find(line, ".xml")) then
            line = line:gsub("\\", "/")
            line = line:gsub("%s+", "")
            local pcallResult, errorMessage
            local chunck = loadfile(line)
            if chunck then
                pcallResult, errorMessage = pcall(chunck, addonName, addonTable)
            end
            if pcallResult then
                -- printL("Loaded " .. line)
            else
                if errorMessage then
                    printL("Error loading " .. line .. ": " .. errorMessage)
                else
                    printL("Error loading " .. line .. " - No errorMessage")
                end
            end
        end
    end
end

local function _Debug(_, ...)
    --printL(...)
end

local function _ErrorOrWarning(_, text, ...)
    io.stderr:write(tostring(text) .. "\n")
end

--Create the root directory
os.execute("mkdir -p ./.dockerfiles/Database")
os.execute("mkdir -p ./.dockerfiles/Database/Quest")
os.execute("mkdir -p ./.dockerfiles/Database/Npc")
os.execute("mkdir -p ./.dockerfiles/Database/Object")
os.execute("mkdir -p ./.dockerfiles/Database/Item")

---@param dataType "item"|"npc"|"object"|"quest"
local function _CheckClassicDatabase(dataType)
    GetBuildInfo = function()
        return "1.14.3", "44403", "Jun 27 2022", 11403
    end

    printL("\n\27[36mCompiling Classic database...\27[0m")
    loadTOC("Questie-Classic.toc")

    Questie.Debug = _Debug
    Questie.Error = _ErrorOrWarning
    Questie.Warning = _ErrorOrWarning
    Questie.Colorize = _EmptyDummyFunction

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

    printL("\27[33m  [1/4] " .. l10n("Loading database") .. "...\27[0m")

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

    printL("\27[33m  [2/4] " .. l10n("Applying database corrections") .. "...\27[0m")

    Questie:SetIcons()
    QuestieLoader:ImportModule("ZoneDB"):Initialize()

    QuestieCorrections:Initialize()

    -- printL("\27[33m  [3/4] " .. l10n("Deleting Gathering Nodes") .. "...\27[0m")
    -- QuestieDB.private:DeleteGatheringNodes()

    printL("\27[33m  [4/4] " .. l10n("Optimizing waypoints") .. "...\27[0m")
    QuestieCorrections:PreCompile()

    printL("\27[35m " .. "Creating Era folders" .. "...\27[0m")
    os.execute("mkdir -p ./.dockerfiles/Database/Quest/Era")
    os.execute("mkdir -p ./.dockerfiles/Database/Npc/Era")
    os.execute("mkdir -p ./.dockerfiles/Database/Object/Era")
    os.execute("mkdir -p ./.dockerfiles/Database/Item/Era")

    if dataType == "quest" then
        printL("\27[34m " .. "Dumping Era Quests" .. "...\27[0m")
        DumpQuests(QuestieDB.questData, "./.dockerfiles/Database/Quest/Era/QuestData.lua-table")
    elseif dataType == "npc" then
        printL("\27[34m " .. "Dumping Era Npcs" .. "...\27[0m")
        DumpNpcs(QuestieDB.npcData, "./.dockerfiles/Database/Npc/Era/NpcData.lua-table")
    elseif dataType == "object" then
        printL("\27[34m " .. "Dumping Era Objects" .. "...\27[0m")
        DumpObjects(QuestieDB.objectData, "./.dockerfiles/Database/Object/Era/ObjectData.lua-table")
    elseif dataType == "item" then
        printL("\27[34m " .. "Dumping Era Items" .. "...\27[0m")
        DumpItems(QuestieDB.itemData, "./.dockerfiles/Database/Item/Era/ItemData.lua-table")
    else
        printL("\27[34m " .. "Dumping Era Quests" .. "...\27[0m")
        DumpQuests(QuestieDB.questData, "./.dockerfiles/Database/Quest/Era/QuestData.lua-table")
        printL("\27[34m " .. "Dumping Era Npcs" .. "...\27[0m")
        DumpNpcs(QuestieDB.npcData, "./.dockerfiles/Database/Npc/Era/NpcData.lua-table")
        printL("\27[34m " .. "Dumping Era Objects" .. "...\27[0m")
        DumpObjects(QuestieDB.objectData, "./.dockerfiles/Database/Object/Era/ObjectData.lua-table")
        printL("\27[34m " .. "Dumping Era Items" .. "...\27[0m")
        DumpItems(QuestieDB.itemData, "./.dockerfiles/Database/Item/Era/ItemData.lua-table")
    end

    if dataType then
        printL("\n\27[32mClassic " .. dataType .. " database dumped successfully\27[0m\n")
    else
        printL("\n\27[32mClassic database dumped successfully\27[0m\n")
    end
end


Questie = nil -- Reset for second test

---@param dataType "item"|"npc"|"object"|"quest"
local function _CheckTBCDatabase(dataType)
    GetBuildInfo = function()
        return "2.5.1", "38644", "May 11 2021", 20501
    end
    WOW_PROJECT_ID = 5

    printL("\n\27[36mCompiling TBC database...\27[0m")
    loadTOC("Questie-BCC.toc")

    Questie.Debug = _Debug
    Questie.Error = _ErrorOrWarning
    Questie.Warning = _ErrorOrWarning
    Questie.Colorize = _EmptyDummyFunction

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

    printL("\27[33m  [1/4] " .. l10n("Loading database") .. "...\27[0m")

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

    printL("\27[33m  [2/4] " .. l10n("Applying database corrections") .. "...\27[0m")

    Questie:SetIcons()
    QuestieLoader:ImportModule("ZoneDB"):Initialize()

    QuestieCorrections:Initialize()

    -- printL("\27[33m  [3/4] " .. l10n("Deleting Gathering Nodes") .. "...\27[0m")
    -- QuestieDB.private:DeleteGatheringNodes()

    printL("\27[33m  [4/4] " .. l10n("Optimizing waypoints") .. "...\27[0m")
    QuestieCorrections:PreCompile()

    printL("\27[35m " .. "Creating TBC folders" .. "...\27[0m")

    os.execute("mkdir -p ./.dockerfiles/Database/Quest/Tbc")
    os.execute("mkdir -p ./.dockerfiles/Database/Npc/Tbc")
    os.execute("mkdir -p ./.dockerfiles/Database/Object/Tbc")
    os.execute("mkdir -p ./.dockerfiles/Database/Item/Tbc")

    if dataType == "quest" then
        printL("\27[34m " .. "Dumping Tbc Quests" .. "...\27[0m")
        DumpQuests(QuestieDB.questData, "./.dockerfiles/Database/Quest/Tbc/QuestData.lua-table")
    elseif dataType == "npc" then
        printL("\27[34m " .. "Dumping Tbc Npcs" .. "...\27[0m")
        DumpNpcs(QuestieDB.npcData, "./.dockerfiles/Database/Npc/Tbc/NpcData.lua-table")
    elseif dataType == "object" then
        printL("\27[34m " .. "Dumping Tbc Objects" .. "...\27[0m")
        DumpObjects(QuestieDB.objectData, "./.dockerfiles/Database/Object/Tbc/ObjectData.lua-table")
    elseif dataType == "item" then
        printL("\27[34m " .. "Dumping Tbc Items" .. "...\27[0m")
        DumpItems(QuestieDB.itemData, "./.dockerfiles/Database/Item/Tbc/ItemData.lua-table")
    else
        printL("\27[34m " .. "Dumping Tbc Quests" .. "...\27[0m")
        DumpQuests(QuestieDB.questData, "./.dockerfiles/Database/Quest/Tbc/QuestData.lua-table")
        printL("\27[34m " .. "Dumping Tbc Npcs" .. "...\27[0m")
        DumpNpcs(QuestieDB.npcData, "./.dockerfiles/Database/Npc/Tbc/NpcData.lua-table")
        printL("\27[34m " .. "Dumping Tbc Objects" .. "...\27[0m")
        DumpObjects(QuestieDB.objectData, "./.dockerfiles/Database/Object/Tbc/ObjectData.lua-table")
        printL("\27[34m " .. "Dumping Tbc Items" .. "...\27[0m")
        DumpItems(QuestieDB.itemData, "./.dockerfiles/Database/Item/Tbc/ItemData.lua-table")
    end

    if dataType then
        printL("\n\27[32mTBC " .. dataType .. " database dumped successfully\27[0m\n")
    else
        printL("\n\27[32mTBC database dumped successfully\27[0m\n")
    end
end


Questie = nil -- Reset for third test

---@param dataType "item"|"npc"|"object"|"quest"
local function _CheckWotlkDatabase(dataType)
    GetBuildInfo = function()
        return "3.4.0", "44644", "Jun 12 2022", 30400
    end
    WOW_PROJECT_ID = 11

    printL("\n\27[36mCompiling Wotlk database...\27[0m")
    loadTOC("Questie-WOTLKC.toc")

    Questie.Debug = _Debug
    Questie.Error = _ErrorOrWarning
    Questie.Warning = _ErrorOrWarning
    Questie.Colorize = _EmptyDummyFunction

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

    printL("\27[33m  [1/4] " .. l10n("Loading database") .. "...\27[0m")

    QuestieDB.npcData = loadstring(QuestieDB.npcData)()
    QuestieDB.objectData = loadstring(QuestieDB.objectData)()
    QuestieDB.questData = loadstring(QuestieDB.questData)()
    QuestieDB.itemData = loadstring(QuestieDB.itemData)()

    printL("\27[33m  [2/4] " .. l10n("Applying database corrections") .. "...\27[0m")

    Questie:SetIcons()
    QuestieLoader:ImportModule("ZoneDB"):Initialize()

    QuestieCorrections:Initialize()

    -- printL("\27[33m  [3/4] " .. l10n("Deleting Gathering Nodes") .. "...\27[0m")
    -- QuestieDB.private:DeleteGatheringNodes()

    printL("\27[33m  [4/4] " .. l10n("Optimizing waypoints") .. "...\27[0m")
    QuestieCorrections:PreCompile()

    printL("\27[35m  " .. "Creating Wotlk folders" .. "...\27[0m")

    os.execute("mkdir -p ./.dockerfiles/Database/Quest/Wotlk")
    os.execute("mkdir -p ./.dockerfiles/Database/Npc/Wotlk")
    os.execute("mkdir -p ./.dockerfiles/Database/Object/Wotlk")
    os.execute("mkdir -p ./.dockerfiles/Database/Item/Wotlk")

    if dataType == "quest" then
        printL("\27[34m " .. "Dumping Wotlk Quests" .. "...\27[0m")
        DumpQuests(QuestieDB.questData, "./.dockerfiles/Database/Quest/Wotlk/QuestData.lua-table")
    elseif dataType == "npc" then
        printL("\27[34m " .. "Dumping Wotlk Npcs" .. "...\27[0m")
        DumpNpcs(QuestieDB.npcData, "./.dockerfiles/Database/Npc/Wotlk/NpcData.lua-table")
    elseif dataType == "object" then
        printL("\27[34m " .. "Dumping Wotlk Objects" .. "...\27[0m")
        DumpObjects(QuestieDB.objectData, "./.dockerfiles/Database/Object/Wotlk/ObjectData.lua-table")
    elseif dataType == "item" then
        printL("\27[34m " .. "Dumping Wotlk Items" .. "...\27[0m")
        DumpItems(QuestieDB.itemData, "./.dockerfiles/Database/Item/Wotlk/ItemData.lua-table")
    else
        printL("\27[34m " .. "Dumping Wotlk Quests" .. "...\27[0m")
        DumpQuests(QuestieDB.questData, "./.dockerfiles/Database/Quest/Wotlk/QuestData.lua-table")
        printL("\27[34m " .. "Dumping Wotlk Npcs" .. "...\27[0m")
        DumpNpcs(QuestieDB.npcData, "./.dockerfiles/Database/Npc/Wotlk/NpcData.lua-table")
        printL("\27[34m " .. "Dumping Wotlk Objects" .. "...\27[0m")
        DumpObjects(QuestieDB.objectData, "./.dockerfiles/Database/Object/Wotlk/ObjectData.lua-table")
        printL("\27[34m " .. "Dumping Wotlk Items" .. "...\27[0m")
        DumpItems(QuestieDB.itemData, "./.dockerfiles/Database/Item/Wotlk/ItemData.lua-table")
    end
    if dataType then
        printL("\n\27[32mWotlk " .. dataType .. " database dumped successfully\27[0m\n")
    else
        printL("\n\27[32mWotlk database dumped successfully\27[0m\n")
    end
end


if args.expansion then
    local data = nil
    if args.data then
        data = args.data
    end
    printL("\n Dumping " .. args.expansion .. " type: " .. tostring(data) .. " database... \n")
    if args.expansion == "era" or args.expansion == "classic" then -- The toc file are named clasic
        _CheckClassicDatabase(data)
    elseif args.expansion == "tbc" or args.expansion == "bcc" then -- The toc file are named bcc
        _CheckTBCDatabase(data)
    elseif args.expansion == "wotlk" then
        _CheckWotlkDatabase(data)
    else
        printL("\n\27[31mInvalid expansion\27[0m\n")
    end
else
    Questie = nil
    _CheckClassicDatabase()
    Questie = nil
    _CheckTBCDatabase()
    Questie = nil
    _CheckWotlkDatabase()
end
