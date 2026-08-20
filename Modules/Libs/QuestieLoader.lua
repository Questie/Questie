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
-- Off unless the profiler is enabled. A player who never profiles pays this false boolean plus the nil
-- observer test below on each Create/Import call; neither path allocates. QuestieProfilerEnabled is a plain
-- saved variable and every TOC sets LoadSavedVariablesFirst,
-- so it is already populated when this file runs - which it does first, ahead of every other Questie file.
--
-- Also off if the client has no GetTimePreciseSec, which is checked here rather than assumed. This file runs
-- before anything that could report an error - Questie:Error does not exist yet - so the only safe response is
-- to record nothing. Timing an addon that will not load is worthless anyway, and calling a missing global here
-- would abort the whole addon over an opt-in diagnostic. The profiler engine makes the same check later and
-- can say so out loud.
--
-- Read these numbers as intervals, not as pure parse cost. Anything the client does between two calls lands
-- on the file that opened the interval, garbage collection included, so a small file can report a large
-- figure because a collection happened to run while it loaded. Compare repeated startups before acting on a
-- single row. A file that makes no loader call at all is charged to its predecessor for the same reason.
local trackLoadTimings = QuestieProfilerEnabled == true and type(GetTimePreciseSec) == "function"

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
---@param sourceOverride string? @Addon-relative identity for the interval opened by this stamp
local function StampLoad(stackLevel, sourceOverride)
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
    local source = sourceOverride
    if not source then
        source = string.match(stack, "%[([^%]]+%.lua)%]:%d+")
            or string.match(stack, "%[([^%]]+%.xml):<Scripts>%]:%d+")
        if source then
            source = string.gsub(source, "^.*[Qq]uestie/", "")
        end
    end

    lastStampedAt = now
    lastMemoryKilobytes = nowKilobytes
    lastSource = source or "(unknown source)"
end

---Attributes everything loaded since the last module call, then stops timing.
---Called once by the profiler from the final line of Questie.lua - the last entry in the TOC - because that
---line runs before any ADDON_LOADED handler and is therefore the earliest point that can close out the last
---file without absorbing handler work that is not file loading.
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

-- Called at the top of every file that registers or imports a module, which is the only moment between two
-- files that any Questie code runs. QuestieProfilerPreHook uses it to install its indirections as soon as the
-- module defining them exists, rather than depending on where it sits in the TOC - a dependency that is
-- silent when it is wrong.
--
-- The module name is passed on, because an observer that has to re-examine every module on every call does
-- roughly a thousand times more work than the one it is looking for: measured over a Classic load, 986 calls
-- inspecting 571,720 slots to install 626 wrappers. Knowing which module was named lets it look at that one.
--
-- Nil unless something registers, so an ordinary load pays one comparison per loader call. The observer is
-- expected to clear itself once it has nothing left to do.
---@type fun(moduleName: string)?
local moduleCallObserver

---Registers a function to run at each module registration or import. Intended for profiling installation that
---must happen before a later file captures a function into a file-scope local; nothing else should use it.
---@param observer fun(moduleName: string)? @Receives the name being registered or imported; nil to detach
function QuestieLoader:SetModuleCallObserver(observer)
    moduleCallObserver = observer
end

---@generic T : QuestieModule
---@param name `T` @Module name
---@return T @Module reference
function QuestieLoader:CreateModule(name)
    if trackLoadTimings then
        StampLoad(3)
    end
    if moduleCallObserver then
        moduleCallObserver(name)
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
    if moduleCallObserver then
        moduleCallObserver(name)
    end
    if (not modules[name]) then
        modules[name] = { private = {} }
        return modules[name]
    else
        return modules[name]
    end
end

---Closes the preceding load interval and opens one for a file or XML group that has no module call.
---
---Call without an argument when this main chunk should name the following interval. The identity is read
---from `debugstack`, so a Lua file names itself and an inline XML Script names its containing XML file:
---  QuestieLoader:StampLoadBoundary()
---
---Pass an addon-relative identity when a wrapper announces the file loaded immediately after it. The
---override is used verbatim instead of the wrapper's `debugstack` source:
---  QuestieLoader:StampLoadBoundary("Libs/HereBeDragons/HereBeDragons-2.0.lua")
---
---Only main-chunk calls take effect. Locale lookup XML uses the first form because most of its child files
---return before reaching a module call; a wrapper can use the second form to keep those child intervals distinct.
---@param sourceOverride string? @Identity for the interval opened after this boundary; inferred when omitted
---@return nil
function QuestieLoader:StampLoadBoundary(sourceOverride)
    if trackLoadTimings then
        StampLoad(3, sourceOverride)
    end
end

function QuestieLoader:PopulateGlobals() -- called when debugging is enabled
    for name, module in pairs(modules) do
        _G[name] = module
    end
end
