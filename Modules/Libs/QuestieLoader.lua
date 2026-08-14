-- The only public class except for Questie
---@class QuestieLoader
QuestieLoader = {}

---@class QuestieModule
---@field public private table -- TODO: We need to re-think the "private" module part

---@type table<string, QuestieModule>
local modules = {}

QuestieLoader._modules = modules -- store reference so modules can be iterated for profiling

-------------------------
-- Load timing
-------------------------
-- Addon file load is a large part of startup that the profiler cannot otherwise see: wrapping measures calls,
-- and a file's cost is mostly table construction at file scope. Every Questie file opens with a Create/Import
-- call though, so the gap between two consecutive calls is the body of the file that made the earlier one.
-- That makes this the one place in the addon where per-file load cost is observable.
--
-- Off unless the profiler is enabled, so a player who never profiles pays one boolean test per call and
-- nothing else. QuestieProfilerEnabled is a plain saved variable and every TOC sets LoadSavedVariablesFirst,
-- so it is already populated when this file runs - which it does first, ahead of every other Questie file.
--
-- Read these numbers as intervals, not as pure parse cost. Anything the client does between two calls lands
-- on the file that opened the interval, garbage collection included, so a small file can report a large
-- figure because a collection happened to run while it loaded. Compare repeated startups before acting on a
-- single row. A file that makes no loader call at all is charged to its predecessor for the same reason.
local trackLoadTimings = QuestieProfilerEnabled == true

---@type table<string, number>? @Milliseconds spent loading each file, keyed by addon-relative path
local loadTimings
---@type table<string, number>? @Kilobytes allocated while loading each file, same keys
local loadMemory
local lastStampedAt
local lastMemoryKilobytes
local lastSource

if trackLoadTimings then
    loadTimings = {}
    loadMemory = {}
    QuestieLoader.loadTimings = loadTimings
    QuestieLoader.loadMemory = loadMemory
    lastStampedAt = GetTimePreciseSec()
    lastMemoryKilobytes = collectgarbage("count")
    -- The opening interval covers only the remainder of this file: embeds.xml is the next TOC entry and
    -- its boundary stamp closes the interval before the first library loads, the same way every other
    -- silent XML group announces itself.
    lastSource = "Modules/Libs/QuestieLoader.lua"
end

---Closes the interval opened by the previous call and opens a new one for the current caller.
---Level 3 is StampLoad -> Create/ImportModule -> the calling file. If that chain ever gains a frame the
---level is wrong, but the result is loud rather than subtly skewed: the main-chunk test starts rejecting
---almost everything and every file collapses into one bucket named after this file. Measured, not assumed.
---@param stackLevel integer @Frames to skip to reach the file that called into QuestieLoader
local function StampLoad(stackLevel)
    local stack = debugstack(stackLevel, 1, 0)

    -- Only a file's own main chunk may open or close an interval. A call made from inside a function is
    -- runtime work - an init routine, a lazy import - and stamping there would close the loading file's
    -- interval and charge everything that ran next to the caller instead. That is not hypothetical: it is how
    -- installing the profiler's hooks came to be reported as QuestieProfiler.lua's load cost. Skipping leaves
    -- the interval open on the file that is actually loading, so runtime imports cannot distort the result.
    if not stack or not string.find(stack, "in main chunk", 1, true) then
        return
    end

    local now = GetTimePreciseSec()
    local nowKilobytes = collectgarbage("count")

    -- Charge the elapsed time to whoever opened the interval, not to the caller closing it.
    local elapsedMilliseconds = (now - lastStampedAt) * 1000
    loadTimings[lastSource] = (loadTimings[lastSource] or 0) + elapsedMilliseconds
    -- Allocation separates real work from a collection pause: a file that costs time without allocating was
    -- not building anything, and a negative figure means the collector ran and freed memory during it.
    loadMemory[lastSource] = (loadMemory[lastSource] or 0) + (nowKilobytes - lastMemoryKilobytes)

    -- WoW renders the path bracketed: "[Interface/AddOns/Questie/Modules/Foo.lua]:3: in main chunk".
    -- An inline XML Script chunk carries the XML's own path instead:
    -- "[Interface/AddOns/Questie/.../lookupItems.xml:<Scripts>]:1: in main chunk".
    local source = string.match(stack, "%[([^%]]+%.lua)%]:%d+")
        or string.match(stack, "%[([^%]]+%.xml):<Scripts>%]:%d+")
    if source then
        source = string.gsub(source, "^.*[Qq]uestie/", "")
    end

    lastStampedAt = now
    lastMemoryKilobytes = nowKilobytes
    lastSource = source or "(unknown source)"
end

---Attributes everything loaded since the last module call, then stops timing.
---Called once by the profiler on ADDON_LOADED, which is the only point at which the final file - the last
---entry in the TOC - has finished running and can be closed out.
function QuestieLoader:FinishLoadTimings()
    if not trackLoadTimings then
        return
    end

    trackLoadTimings = false
    local elapsedMilliseconds = (GetTimePreciseSec() - lastStampedAt) * 1000
    loadTimings[lastSource] = (loadTimings[lastSource] or 0) + elapsedMilliseconds
    loadMemory[lastSource] = (loadMemory[lastSource] or 0) + (collectgarbage("count") - lastMemoryKilobytes)
end

------------------------------
--- Module creation and import
------------------------------

---@generic T : QuestieModule
---@param name `T` @Module name
---@return T @Module reference
function QuestieLoader:CreateModule(name)
    if trackLoadTimings then
        StampLoad(3)
    end
    if (not modules[name]) then
        modules[name] = { private = {} }
        return modules[name]
    else
        return modules[name]
    end
end

---@generic T : QuestieModule
---@param name `T` @Module name
---@return T @Module reference
function QuestieLoader:ImportModule(name)
    if trackLoadTimings then
        StampLoad(3)
    end
    if (not modules[name]) then
        modules[name] = { private = {} }
        return modules[name]
    else
        return modules[name]
    end
end

---Stamps a load-interval boundary from a file that has no module to create or import.
---
---An XML script group whose listed files never reach a loader call - the locale lookup tables, which
---early-return on every locale but the client's - is invisible to the stamps above, so its entire parse
---cost lands on whichever file stamped last. Called from an inline Script tag as the XML's first element;
---that chunk runs "in main chunk" carrying the XML's own path, so the interval it opens is named after
---the group itself, through the same debugstack extraction every Lua file goes through.
function QuestieLoader:StampLoadBoundary()
    if trackLoadTimings then
        StampLoad(3)
    end
end

function QuestieLoader:PopulateGlobals() -- called when debugging is enabled
    for name, module in pairs(modules) do
        _G[name] = module
    end
end
