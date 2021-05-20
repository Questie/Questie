
tremove = table.remove
tinsert = table.insert
unpack = table.unpack
loadstring = load
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
    return "6.3.9"
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
    After = function(time, f)
        f()
    end,
    NewTicker = function(time, f, times)
        if times then
            for i=1,times do
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

local function loadTOC(file)
    local rfile = io.open(file, "r")
    for line in rfile:lines() do
        if string.len(line) > 1 and string.byte(line, 1) ~= 35 then
            line = line:gsub("\\", "/")
            local r, e = pcall(dofile, line)
            if r then
                --print("Loaded " .. line)
            else
                --print("Error loading " .. line .. ": " .. e)
            end
        end
    end
end

loadTOC("Questie.toc")

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
    global = {

    }
}
QuestieConfig = {}

print("Running compiler...")
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
local QuestieDatabaseUnification = QuestieLoader:ImportModule("QuestieDatabaseUnification")
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
local l10n = QuestieLoader:ImportModule("l10n")

-- taken from QuestieEventHandler
print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")
QuestieDB.npcData = loadstring(QuestieDB.npcData)
QuestieDB.npcDataTBC = QuestieDB.npcDataTBC and loadstring(QuestieDB.npcDataTBC) or nil
QuestieDB.npcData = QuestieDB.npcData()
QuestieDB.npcDataTBC = QuestieDB.npcDataTBC and QuestieDB.npcDataTBC() or nil
QuestieDB.objectData = loadstring(QuestieDB.objectData)
QuestieDB.objectDataTBC = QuestieDB.objectDataTBC and loadstring(QuestieDB.objectDataTBC) or nil
QuestieDB.objectData = QuestieDB.objectData()
QuestieDB.objectDataTBC = QuestieDB.objectDataTBC and QuestieDB.objectDataTBC() or nil
QuestieDB.questData = loadstring(QuestieDB.questData)
QuestieDB.questDataTBC = QuestieDB.questDataTBC and loadstring(QuestieDB.questDataTBC) or nil
QuestieDB.questData = QuestieDB.questData()
QuestieDB.questDataTBC = QuestieDB.questDataTBC and QuestieDB.questDataTBC() or nil
QuestieDB.itemData = loadstring(QuestieDB.itemData)
QuestieDB.itemDataTBC = QuestieDB.itemDataTBC and loadstring(QuestieDB.itemDataTBC) or nil
QuestieDB.itemData = QuestieDB.itemData()
QuestieDB.itemDataTBC = QuestieDB.itemDataTBC and QuestieDB.itemDataTBC() or nil
print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. "...")
if false and QuestieDB.questDataTBC then
    QuestieDB.questData = QuestieDatabaseUnification:CombineQuests(QuestieDB.questData, QuestieDB.questDataTBC)
    QuestieDB.objectData = QuestieDatabaseUnification:CombineObjects(QuestieDB.objectData, QuestieDB.objectDataTBC)
    QuestieDB.npcData = QuestieDatabaseUnification:CombineNPCs(QuestieDB.npcData, QuestieDB.npcDataTBC)
    QuestieDB.itemData = QuestieDatabaseUnification:CombineItems(QuestieDB.itemData, QuestieDB.itemDataTBC)
end


QuestieLoader:ImportModule("QuestieFramePool"):SetIcons()
QuestieLoader:ImportModule("ZoneDB"):Initialize()

QuestieCorrections:Initialize({
    ["npcData"] = QuestieDB.npcDataTBC,
    ["objectData"] = QuestieDB.objectDataTBC,
    ["itemData"] = QuestieDB.itemDataTBC,
    ["questData"] = QuestieDB.questDataTBC
})

QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")

QuestieDBCompiler:Compile(function() end)
print("Validating objects...")
QuestieDBCompiler:ValidateObjects()
print("Validating items...")
QuestieDBCompiler:ValidateItems()
print("Validating NPCs...")
QuestieDBCompiler:ValidateNPCs()
print("Validating quests...")
QuestieDBCompiler:ValidateQuests()
