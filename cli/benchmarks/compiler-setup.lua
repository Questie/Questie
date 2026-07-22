-- Benchmark: CompileTableCoroutine setup loops
--
-- Measures the two pre-compile loops in CompileTableCoroutine that run without
-- any coroutine.yield() calls. These are the root cause of "script ran too long"
-- errors on WoW Classic Era 1.15.9+ which tightened the script watchdog budget.
--
-- Metrics reported per DB table:
--   - Wall-clock time of each loop (os.clock)
--   - Number of coYield() calls (currently 0 before fix, N after fix)
--   - Longest uninterrupted run between yields (the actual watchdog risk)
--
-- Usage: lua cli/benchmarks/compiler-setup.lua

WOW_PROJECT_ID = 2

dofile("cli/apiMocks.lua")
local loadTOC = require("cli.loadTOC")

GetBuildInfo = function()
    return "1.14.3", "44403", "Jun 27 2022", 11403
end
UnitLevel = function()
    return 60
end
GetMaxPlayerLevel = function()
    return 60
end

loadTOC("Questie-Classic.toc")

local function _Silent() end
Questie.Debug = _Silent
Questie.Error = _Silent
Questie.Warning = _Silent

Questie.db = {
    char = { showEventQuests = false },
    global = {},
    profile = { debugEnabled = false }
}
QuestieConfig = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

-- Load and apply the real database so table sizes match production
io.write("Loading Era database (this takes a moment)...\n")
QuestieDB.npcData = loadstring(QuestieDB.npcData)()
QuestieDB.objectData = loadstring(QuestieDB.objectData)()
QuestieDB.questData = loadstring(QuestieDB.questData)()
QuestieDB.itemData = loadstring(QuestieDB.itemData)()

Questie:SetIcons()
ZoneDB:Initialize()
QuestieCorrections:Initialize({
    ["npcData"]    = QuestieDB.npcData,
    ["objectData"] = QuestieDB.objectData,
    ["itemData"]   = QuestieDB.itemData,
    ["questData"]  = QuestieDB.questData,
})
io.write("Database loaded.\n\n")

-- ---------------------------------------------------------------------------
-- Instrumentation helpers
-- ---------------------------------------------------------------------------

local yieldCount = 0
local currentRunLength = 0
local maxRunLength = 0

local function _resetInstrumentation()
    yieldCount = 0
    currentRunLength = 0
    maxRunLength = 0
end

-- Injected in place of coYield during measurement. Records every yield and
-- tracks the longest uninterrupted streak of iterations before a yield.
local function _instrumentedYield()
    if currentRunLength > maxRunLength then
        maxRunLength = currentRunLength
    end
    currentRunLength = 0
    yieldCount = yieldCount + 1
end

local function _tick()
    currentRunLength = currentRunLength + 1
end

-- ---------------------------------------------------------------------------
-- Core measurement: directly replicate the two setup loops from
-- CompileTableCoroutine (compiler.lua ~958-971) so we can instrument them
-- without modifying the production module.
-- ---------------------------------------------------------------------------

---@param label string
---@param tbl table  The raw DB table (npcData, questData, etc.)
---@return table results  { pairsScan, indexBuild }  each: { time, yields, maxRun, entryCount, maxId }
local function _measureSetupLoops(tbl)
    -- ---- Loop 1: pairs() scan to find max_id ----
    _resetInstrumentation()
    local t0 = os.clock()

    local max_id = 0
    local entryCount = 0
    for id in pairs(tbl) do
        assert(type(id) == "number", "CompileTableCoroutine: tbl id is not a number")
        if id > max_id then
            max_id = id
        end
        entryCount = entryCount + 1
        _tick()
        -- NOTE: there is currently NO yield here — that is the bug.
        -- After the fix a coYield() call will appear here every N iterations,
        -- which will call _instrumentedYield() and reset currentRunLength.
    end
    -- Account for iterations after the last yield (or the full run if no yields)
    if currentRunLength > maxRunLength then
        maxRunLength = currentRunLength
    end

    local pairsScan = {
        time       = os.clock() - t0,
        yields     = yieldCount,
        maxRun     = maxRunLength,
        entryCount = entryCount,
        maxId      = max_id,
    }

    -- ---- Loop 2: sequential id=0,max_id scan to build indexLookup ----
    _resetInstrumentation()
    t0 = os.clock()

    local count = 0
    local indexLookup = {}
    for id = 0, max_id do
        if tbl[id] then
            count = count + 1
            indexLookup[count] = id
        end
        _tick()
        -- NOTE: there is currently NO yield here — that is the bug.
    end
    if currentRunLength > maxRunLength then
        maxRunLength = currentRunLength
    end

    local indexBuild = {
        time       = os.clock() - t0,
        yields     = yieldCount,
        maxRun     = maxRunLength,
        entryCount = count,
        maxId      = max_id,
    }

    return { pairsScan = pairsScan, indexBuild = indexBuild }
end

-- ---------------------------------------------------------------------------
-- Report formatting
-- ---------------------------------------------------------------------------

local WATCHDOG_THRESHOLD = 5000  -- iterations — anything above this is risky
local LOG_FILE = "cli/output/compiler-setup-benchmark.log"

-- Column widths (must match between header and data rows)
local COL_LOOP    = -14   -- loop name,  left-aligned
local COL_TIME    =   9   -- time (s),   right-aligned
local COL_YIELDS  =   6   -- yield count, right-aligned
local COL_MAXRUN  =   7   -- max-run,    right-aligned
local COL_ENTRIES =   7   -- entries,    right-aligned
local COL_MAXID   =   7   -- max_id,     right-aligned
local COL_STATUS  = -12   -- status inside brackets, left-aligned (fits "RISK (>5000)")

local ROW_FMT    = "    %" .. COL_LOOP .. "s  %"  .. COL_TIME   .. ".4fs  %"
                          .. COL_YIELDS .. "d  %"  .. COL_MAXRUN .. "d  %"
                          .. COL_ENTRIES .. "d  %"  .. COL_MAXID  .. "d  [%"
                          .. COL_STATUS .. "s]\n"

local HEADER_FMT = "    %" .. COL_LOOP .. "s  %" .. COL_TIME   .. "s   %"
                          .. COL_YIELDS .. "s  %"  .. COL_MAXRUN .. "s  %"
                          .. COL_ENTRIES .. "s  %"  .. COL_MAXID  .. "s  [%-"
                          .. math.abs(COL_STATUS) .. "s]\n"

local DIVIDER = string.rep("-", 80)

local function _status(maxRun)
    if maxRun > WATCHDOG_THRESHOLD then
        return string.format("RISK (>%d)", WATCHDOG_THRESHOLD)
    end
    return "OK"
end

local function _formatResult(name, r)
    return string.format(ROW_FMT, name, r.time, r.yields, r.maxRun, r.entryCount, r.maxId, _status(r.maxRun))
end

-- ---------------------------------------------------------------------------
-- Run benchmarks and collect output lines
-- ---------------------------------------------------------------------------

local tables = {
    { label = "NPCs",    tbl = QuestieDB.npcData    },
    { label = "Objects", tbl = QuestieDB.objectData },
    { label = "Quests",  tbl = QuestieDB.questData  },
    { label = "Items",   tbl = QuestieDB.itemData   },
}

local lines = {}
local function _emit(s)
    io.write(s)
    lines[#lines + 1] = s
end

_emit("=== CompileTableCoroutine Setup Loop Benchmark (Era) ===\n\n")
_emit(string.format(HEADER_FMT, "loop", "time (s)", "yields", "max-run", "entries", "max_id", "status"))
_emit(DIVIDER .. "\n")

local allOk = true
for _, entry in ipairs(tables) do
    _emit(string.format("  [%s]\n", entry.label))
    local results = _measureSetupLoops(entry.tbl)
    _emit(_formatResult("pairs() scan", results.pairsScan))
    _emit(_formatResult("index build",  results.indexBuild))
    _emit("\n")

    if results.pairsScan.maxRun > WATCHDOG_THRESHOLD or results.indexBuild.maxRun > WATCHDOG_THRESHOLD then
        allOk = false
    end
end

_emit(DIVIDER .. "\n")
if allOk then
    _emit("Result: ALL OK — no setup loop exceeds the watchdog threshold.\n")
else
    _emit(string.format(
        "Result: RISK DETECTED — one or more loops exceed %d uninterrupted iterations.\n",
        WATCHDOG_THRESHOLD
    ))
end

-- ---------------------------------------------------------------------------
-- Append results to history log
-- ---------------------------------------------------------------------------

local gitHash = "unknown"
local handle = io.popen("git rev-parse --short HEAD 2>/dev/null")
if handle then
    local result = handle:read("*l")
    handle:close()
    if result and #result > 0 then
        gitHash = result
    end
end

local timestamp = os.date("%Y-%m-%d %H:%M:%S")
local header = string.format(
    "\n%s\n%s  git:%s\n%s\n",
    string.rep("=", 80),
    timestamp,
    gitHash,
    string.rep("=", 80)
)

local logFile = io.open(LOG_FILE, "a")
if logFile then
    logFile:write(header)
    for _, line in ipairs(lines) do
        logFile:write(line)
    end
    logFile:close()
    io.write(string.format("\nResults appended to %s\n", LOG_FILE))
else
    io.write(string.format("\nWarning: could not write to %s\n", LOG_FILE))
end
