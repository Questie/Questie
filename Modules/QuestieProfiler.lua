---@class QuestieProfiler
local QuestieProfiler = QuestieLoader:CreateModule("Profiler")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

local setThreadProfilingCallbacks = ThreadLib.SetProfilingCallbacks
local clearThreadProfilingCallbacks = ThreadLib.ClearProfilingCallbacks
local getTimePreciseSec = GetTimePreciseSec
local debugProfileStop = debugprofilestop
local tinsert = table.insert
local unpack = unpack

-- Both clocks resolve to roughly 100ns and cost the same per call, but debugprofilestop can be reset to zero
-- by any addon calling debugprofilestart. A reset landing between a wrapper's two reads yields a large
-- negative elapsed, and AddMeasurement accumulates it, permanently poisoning that function's total and
-- highestMS. GetTimePreciseSec is monotonic, so prefer it and keep debugprofilestop only as a fallback.
---@type (fun(): number)? @Current time in milliseconds; nil when the client offers no usable timer
local Now
if type(getTimePreciseSec) == "function" then
    Now = function()
        return getTimePreciseSec() * 1000
    end
elseif type(debugProfileStop) == "function" then
    Now = debugProfileStop
end

---@return table weakKeyTable
local function NewWeakKeyTable()
    return setmetatable({}, {__mode = "k"})
end

---@class ProfilerCoroutineFrame
---@field lookupKey string
---@field activeSince number @Start of this resume slice in milliseconds
---@field generation integer @Measurement window in which this call started
---@field discarded boolean @True when the call did not return within its starting resume slice
---@field childTime number @Measured time of completed profiled children, subtracted to yield self time

---@class ProfilerThreadJob
---@field lookupKey string
---@field activeSince number? Start of the current measured resume slice; nil while suspended or after a measurement reset.

---@type thread?
local currentThread
---@type table<thread, ProfilerCoroutineFrame[]>
local threadFrames = NewWeakKeyTable()
---@type table<thread, ProfilerThreadJob>
local threadJobs = NewWeakKeyTable()
local measurementGeneration = 0

-- Attribution shadow stack for main-thread calls. The wrapper brackets the real call, so the frame directly
-- below a call is its caller exactly - nothing is inferred. Frames are reused across calls, so tracking a
-- caller costs an array write rather than an allocation. Coroutine calls use threadFrames for the same job.
--
-- Known limitation. An error unwinds past a wrapper without running its epilogue, so between a caught error
-- and the return of the ancestor that caught it, the top frame is stale. Calls made inside that window are
-- attributed to the errored function instead of the real caller, and the catching ancestor's self time is
-- overstated by their elapsed. The window closes as soon as that ancestor returns, so it cannot outlive one
-- root call tree, and measurements of the calls themselves stay correct - only attribution drifts.
-- There is no cheap detection: Lua gives no notification when a call is aborted, WoW exposes no `debug`
-- library to inspect a stack, and pcall-wrapping every call to force the epilogue costs ~0.24us per call
-- (measured), which would roughly double this profiler's overhead and truncate error tracebacks.
---@type ProfilerCoroutineFrame[]
local mainStack = {}
local mainDepth = 0

-- Attributed to calls that had no profiled function below them on the stack.
local ROOT_CALLER = "(root)"

-- Wrapper ownership spans measurement sessions so retained old wrappers are not wrapped again.
-- Keep values independent of keys because Lua 5.1 weak-key tables are not ephemerons.
---@type table<function, true>
local ownedWrappers = NewWeakKeyTable()

---@class ProfilerPackedValues
---@field n integer
---@field [integer] any

-- Lua 5.1 has no table.pack; the explicit count preserves interior and trailing nil returns.
---@param ... any
---@return ProfilerPackedValues packedValues
local function Pack(...)
    return {n = select("#", ...), ...}
end

---@param lookupKey string
local function IncrementCallCount(lookupKey)
    local calls = QuestieProfiler.hookCallCount[lookupKey] + 1
    QuestieProfiler.hookCallCount[lookupKey] = calls
    if calls > QuestieProfiler.highestCalls then
        QuestieProfiler.highestCalls = calls
    end
end

---@param lookupKey string
---@param elapsed number @Active execution time in milliseconds
local function AddMeasurement(lookupKey, elapsed)
    local totalTime = QuestieProfiler.hookTimeCount[lookupKey] + elapsed
    QuestieProfiler.hookTimeCount[lookupKey] = totalTime

    if totalTime > QuestieProfiler.highestMS then
        QuestieProfiler.highestMS = totalTime
    end
end

---@param lookupKey string
---@param elapsed number @Time in this call that was not spent inside profiled children
local function AddSelfMeasurement(lookupKey, elapsed)
    local selfTime = QuestieProfiler.hookSelfTime[lookupKey]
    if selfTime == nil then
        return
    end

    -- A child measured in a window its parent did not share can exceed the parent's own elapsed.
    -- Self time is a share of the parent's cost, so clamp rather than publish a negative.
    if elapsed < 0 then
        elapsed = 0
    end
    QuestieProfiler.hookSelfTime[lookupKey] = selfTime + elapsed
end

---Records that `callerKey` invoked `calleeKey`. Counted on entry so edge counts reconcile with call counts
---even for calls that never return through their wrapper.
---@param calleeKey string
---@param callerKey string
local function RecordCallerCall(calleeKey, callerKey)
    local callers = QuestieProfiler.callerCallCount[calleeKey]
    if not callers then
        callers = {}
        QuestieProfiler.callerCallCount[calleeKey] = callers
    end
    callers[callerKey] = (callers[callerKey] or 0) + 1
end

---Attributes a completed call's elapsed time to the caller that made it.
---@param calleeKey string
---@param callerKey string
---@param elapsed number
local function RecordCallerTime(calleeKey, callerKey, elapsed)
    local callers = QuestieProfiler.callerTimeCount[calleeKey]
    if not callers then
        callers = {}
        QuestieProfiler.callerTimeCount[calleeKey] = callers
    end
    callers[callerKey] = (callers[callerKey] or 0) + elapsed
end

---Trims what every frame here has in common. The addon prefix is on all of them, WoW's brackets around the
---path carry nothing, and Lua repeats the whole path when it renders an anonymous function as "<file:line>"
---after the call site. What is left is the part that actually differs between jobs.
---
---Naming an anonymous job by where it is defined rather than where it was submitted means one closure
---submitted from several call sites aggregates into a single job row. That is the intent: the closure is the
---scheduling unit, and splitting it by call site would report the same work as several unrelated jobs.
---A path from another addon is left untouched, so nothing can collapse into a Questie name by accident.
---@param stackLine string
---@return string description
local function ShortenStackFrame(stackLine)
    -- The definition site identifies the closure, so keep it and drop the call site it duplicates.
    local definitionFile, definitionLine = string.match(stackLine, "in function <([^:>]+):(%d+)>%s*$")
    if definitionFile then
        stackLine = definitionFile .. ":" .. definitionLine
    end

    stackLine = string.gsub(stackLine, "[Ii]nterface[/\\]+[Aa]dd[Oo]ns[/\\]+[Qq]uestie[/\\]+", "")
    stackLine = string.gsub(stackLine, "^%[(.-)%]", "%1")
    -- Addon-load rows spell the same file with forward slashes; a job naming it differently would read as a
    -- different file.
    stackLine = string.gsub(stackLine, "\\", "/")
    return stackLine
end

---@param submittedFunction function
---@param callSiteStack string?
---@param threadName string?
---@return string description
local function DescribeThreadJob(submittedFunction, callSiteStack, threadName)
    if threadName and threadName ~= "" then
        return threadName
    end

    local knownName = QuestieProfiler.shortestName[submittedFunction]
    if knownName then
        return knownName
    end

    if type(callSiteStack) == "string" then
        for stackLine in string.gmatch(callSiteStack, "[^\r\n]+") do
            local trimmedLine = string.match(stackLine, "^%s*(.-)%s*$")
            local isInternalFrame = string.find(trimmedLine, "ThreadLib.lua", 1, true)
                or string.find(trimmedLine, "QuestieProfiler.lua", 1, true)
            local isUnusableFrame = string.find(trimmedLine, "[tail call]", 1, true) == 1
                or string.find(trimmedLine, "[C]", 1, true) == 1
                or string.match(trimmedLine, "^[%?:%s]+$") ~= nil
            if trimmedLine ~= "" and not isInternalFrame and not isUnusableFrame then
                local lineWithoutFunction, functionName = string.match(trimmedLine,
                    "^(.-)%s*:?[ \t]*in function ['\"]([^'\"]+)['\"]%s*$")
                if functionName == "original" or functionName == "override" or functionName == "wrapper" then
                    trimmedLine = string.match(lineWithoutFunction, "^%s*(.-)%s*$")
                end

                trimmedLine = ShortenStackFrame(trimmedLine)
                if trimmedLine ~= "" then
                    return string.sub(trimmedLine, 1, 160)
                end
            end
        end
    end

    return "anonymous call site"
end

---Clears measurement tables and coroutine tracking for a new profiling session.
local function ResetSessionState()
    measurementGeneration = measurementGeneration + 1
    QuestieProfiler.hooks = {}
    QuestieProfiler.alreadyHooked = {}
    QuestieProfiler.hookCallCount = {}
    QuestieProfiler.hookTimeCount = {}
    QuestieProfiler.hookSelfTime = {}
    QuestieProfiler.callerCallCount = {}
    QuestieProfiler.callerTimeCount = {}
    QuestieProfiler.fileLoadTime = {}
    QuestieProfiler.fileLoadMemory = {}
    QuestieProfiler.lowerCaseLookup = {}
    QuestieProfiler.shortestName = {}
    QuestieProfiler.lookupToHook = {}
    QuestieProfiler.hookedFunctionCount = 0
    QuestieProfiler.highestMS = 0
    QuestieProfiler.highestCalls = 0
    QuestieProfiler.threadJobCallCount = {}
    QuestieProfiler.threadJobResumeCount = {}

    currentThread = nil
    mainDepth = 0
    threadFrames = NewWeakKeyTable()
    threadJobs = NewWeakKeyTable()
end

ResetSessionState()
QuestieProfiler.active = false

-------------------------
-- Coroutine active-slice timing
-------------------------
-- ThreadLib job rows measure every active resume slice and exclude suspended scheduler waits.
-- Function rows are measured only when their wrappers return within the resume slice in which they started.
---@type ThreadLibProfilingCallbacks
local profilingCallbacks = {
    OnThreadCreated = function(thread, submittedFunction, callSiteStack, threadName)
        local lookupKey = "ThreadLib job: " .. DescribeThreadJob(submittedFunction, callSiteStack, threadName)
        if QuestieProfiler.hookCallCount[lookupKey] == nil then
            QuestieProfiler.hookCallCount[lookupKey] = 0
            QuestieProfiler.hookTimeCount[lookupKey] = 0
            QuestieProfiler.hookSelfTime[lookupKey] = 0
            QuestieProfiler.threadJobCallCount[lookupKey] = 0
            QuestieProfiler.threadJobResumeCount[lookupKey] = 0
            QuestieProfiler.lowerCaseLookup[lookupKey] = string.lower(lookupKey)
        end

        IncrementCallCount(lookupKey)
        QuestieProfiler.threadJobCallCount[lookupKey] = QuestieProfiler.threadJobCallCount[lookupKey] + 1
        threadJobs[thread] = {lookupKey = lookupKey}
    end,
    BeforeResume = function(thread)
        local now = Now()
        currentThread = thread

        local job = threadJobs[thread]
        if job then
            job.activeSince = now
        end
    end,
    AfterResume = function(thread, success, status)
        -- Clear first so an observer failure cannot leak coroutine timing into later main-thread calls.
        currentThread = nil
        local now = Now()
        local frames = threadFrames[thread]
        if frames then
            -- Lua 5.1 cannot safely distinguish a yielding wrapper from one whose error was caught by unwrapped code.
            -- Discard both here; the ThreadLib job row remains the accurate aggregate for calls spanning yields.
            for i = 1, #frames do
                frames[i].discarded = true
            end
            threadFrames[thread] = nil
        end

        local job = threadJobs[thread]
        if job and job.activeSince then
            QuestieProfiler.threadJobResumeCount[job.lookupKey] = QuestieProfiler.threadJobResumeCount[job.lookupKey] + 1
            AddMeasurement(job.lookupKey, now - job.activeSince)
            job.activeSince = nil
        end

        if not success or status == "dead" then
            threadFrames[thread] = nil
            threadJobs[thread] = nil
        end
    end,
}

-------------------------
-- Hook traversal
-------------------------
-- Keep inclusive timing for high-level database operations while excluding generated query and stream primitives.
-- Those primitives can run thousands of times inside one useful high-level measurement and otherwise dominate the profiler.
local PROFILING_DISALLOWED_PATHS = {
    ["QuestieStreamLib"] = true,
    ["DBCompiler.readers"] = true,
    ["DBCompiler.writers"] = true,
    ["DBCompiler.skippers"] = true,
    ["QuestieSerializer.ReaderTable"] = true,
    ["QuestieSerializer.WriterTable"] = true,
    ["QuestieDB.QueryNPC"] = true,
    ["QuestieDB.QueryQuest"] = true,
    ["QuestieDB.QueryObject"] = true,
    ["QuestieDB.QueryItem"] = true,
    ["QuestieDB.QueryNPCSingle"] = true,
    ["QuestieDB.QueryQuestSingle"] = true,
    ["QuestieDB.QueryObjectSingle"] = true,
    ["QuestieDB.QueryItemSingle"] = true,
    ["QuestieDB._QueryNPC"] = true,
    ["QuestieDB._QueryQuest"] = true,
    ["QuestieDB._QueryObject"] = true,
    ["QuestieDB._QueryItem"] = true,
    ["QuestieDB._QueryNPCSingle"] = true,
    ["QuestieDB._QueryQuestSingle"] = true,
    ["QuestieDB._QueryObjectSingle"] = true,
    ["QuestieDB._QueryItemSingle"] = true,
}

---@param lookupPath string
---@return boolean
local function IsProfilingPathDisallowed(lookupPath)
    for disallowedPath in pairs(PROFILING_DISALLOWED_PATHS) do
        if lookupPath == disallowedPath
            or string.sub(lookupPath, 1, string.len(disallowedPath) + 1) == disallowedPath .. "." then
            return true
        end
    end
    return false
end

---@param key any
---@param original function
---@param parent table
---@param parentName string
function QuestieProfiler:HookFunction(key, original, parent, parentName)
    local baseLookupKey = parentName .. "." .. tostring(key)
    if IsProfilingPathDisallowed(baseLookupKey) then
        return
    end

    local lookupKey = baseLookupKey
    local duplicateNumber = 2
    while QuestieProfiler.lookupToHook[lookupKey] do
        lookupKey = baseLookupKey .. " [" .. type(key) .. " #" .. duplicateNumber .. "]"
        duplicateNumber = duplicateNumber + 1
    end

    local hook = {
        original = original,
        originalKey = key,
        originalParent = parent,
        lookupKey = lookupKey,
    }

    hook.enabled = true
    hook.override = function(...)
        if not hook.enabled or not QuestieProfiler.active or QuestieProfiler.hookCallCount[lookupKey] == nil then
            return hook.original(...)
        end

        IncrementCallCount(lookupKey)

        -- Calls that finish within this ThreadLib resume slice can be timed without including scheduler waits.
        if currentThread then
            local frames = threadFrames[currentThread]
            if not frames then
                frames = {}
                threadFrames[currentThread] = frames
            end

            local frameIndex = #frames + 1
            local parentFrame = frames[frameIndex - 1]
            -- The ThreadLib job owns the coroutine's outermost call, so work it scheduled reads as called by it
            -- rather than by nothing.
            local callerKey
            if parentFrame then
                callerKey = parentFrame.lookupKey
            else
                local job = threadJobs[currentThread]
                callerKey = job and job.lookupKey or ROOT_CALLER
            end
            RecordCallerCall(lookupKey, callerKey)

            local frame = {
                lookupKey = lookupKey,
                activeSince = Now(),
                generation = measurementGeneration,
                discarded = false,
                childTime = 0,
            }
            tinsert(frames, frame)
            local results = Pack(hook.original(...))
            if not frame.discarded
                and frame.generation == measurementGeneration
                and QuestieProfiler.active
                and QuestieProfiler.hookTimeCount[lookupKey] ~= nil then
                local elapsed = Now() - frame.activeSince
                AddMeasurement(lookupKey, elapsed)
                AddSelfMeasurement(lookupKey, elapsed - frame.childTime)
                RecordCallerTime(lookupKey, callerKey, elapsed)
                if parentFrame and not parentFrame.discarded then
                    parentFrame.childTime = parentFrame.childTime + elapsed
                end
            end

            -- A caught descendant error bypasses its wrapper cleanup. Returning ancestors discard those stale frames here.
            for i = #frames, frameIndex, -1 do
                frames[i].discarded = true
                frames[i] = nil
            end
            return unpack(results, 1, results.n)
        end

        -- Raw coroutines have no scheduler boundary callbacks, so elapsed timing would include time spent suspended.
        -- Count these calls, but only time main-thread calls and ThreadLib-managed coroutine slices.
        if coroutine.running() then
            return hook.original(...)
        end

        local generation = measurementGeneration
        local frameIndex = mainDepth + 1
        local parentFrame = frameIndex > 1 and mainStack[frameIndex - 1] or nil
        local callerKey = parentFrame and parentFrame.lookupKey or ROOT_CALLER
        RecordCallerCall(lookupKey, callerKey)

        local frame = mainStack[frameIndex]
        if not frame then
            frame = {}
            mainStack[frameIndex] = frame
        end
        frame.lookupKey = lookupKey
        frame.childTime = 0
        frame.activeSince = Now()
        mainDepth = frameIndex

        -- pcall so an error can never skip this epilogue, which keeps the shadow stack exact and lets a failed
        -- call still report the time it spent before failing. Safe here and only here: this branch is reached
        -- only when no coroutine is running, so nothing below can yield, and Lua 5.1 cannot yield across a
        -- pcall boundary. The ThreadLib branch above must never do this - it would kill every yielding job.
        local results = Pack(pcall(hook.original, ...))
        local elapsed = Now() - frame.activeSince

        -- Restoring the depth absolutely rather than decrementing also covers a descendant that was aborted
        -- by an error the profiler never saw, such as one raised inside an unwrapped callback.
        mainDepth = frameIndex - 1

        if generation == measurementGeneration
            and QuestieProfiler.active
            and QuestieProfiler.hookTimeCount[lookupKey] ~= nil then
            AddMeasurement(lookupKey, elapsed)
            AddSelfMeasurement(lookupKey, elapsed - frame.childTime)
            RecordCallerTime(lookupKey, callerKey, elapsed)
            if parentFrame then
                parentFrame.childTime = parentFrame.childTime + elapsed
            end
        end

        if not results[1] then
            -- Re-raise the original error object. Level 0 keeps this file out of the message; the position of
            -- the original error is already baked into it.
            error(results[2], 0)
        end
        -- Index 1 is pcall's success flag, so the real return values start at 2.
        return unpack(results, 2, results.n)
    end

    QuestieProfiler.hookCallCount[lookupKey] = 0
    QuestieProfiler.hookTimeCount[lookupKey] = 0
    QuestieProfiler.hookSelfTime[lookupKey] = 0
    QuestieProfiler.lowerCaseLookup[lookupKey] = string.lower(lookupKey)
    QuestieProfiler.lookupToHook[lookupKey] = original
    QuestieProfiler.shortestName[hook.override] = lookupKey
    local previousName = QuestieProfiler.shortestName[original]
    if not previousName or string.len(lookupKey) < string.len(previousName) then
        QuestieProfiler.shortestName[original] = lookupKey
    end

    tinsert(QuestieProfiler.hooks, hook)
    ownedWrappers[hook.override] = true
    parent[key] = hook.override
    QuestieProfiler.hookedFunctionCount = QuestieProfiler.hookedFunctionCount + 1
end

---@param left table
---@param right table
---@return boolean
local function SortSnapshotEntries(left, right)
    local leftType = type(left.key)
    local rightType = type(right.key)
    if leftType ~= rightType then
        return leftType < rightType
    end
    return tostring(left.key) < tostring(right.key)
end

local MAX_NAMESPACE_ENTRIES = 64
local MAX_NAMESPACE_LOOKAHEAD = 2

-- Search at most two descendant levels, rejecting each candidate table once it exceeds 64 entries.
-- Table-valued keys, WoW frames, nested direct globals, and explicit runtime-data exclusions are never followed.
---@param tableValue table
---@param remainingDepth integer
---@param excludedTables table<table, boolean>
---@param namespaceShapeCache table<integer, table<table, boolean>>
---@param inspectingTables table<table, boolean>
---@return boolean
local function ContainsBoundedFunction(tableValue, remainingDepth, excludedTables, namespaceShapeCache, inspectingTables)
    if excludedTables[tableValue]
        or type(rawget(tableValue, 0)) == "userdata"
        or type(rawget(tableValue, "GetObjectType")) == "function"
        or type(rawget(tableValue, "GetScript")) == "function" then
        return false
    end

    local depthCache = namespaceShapeCache[remainingDepth]
    local cachedResult = depthCache[tableValue]
    if cachedResult ~= nil then
        return cachedResult
    end
    if inspectingTables[tableValue] then
        return false
    end

    inspectingTables[tableValue] = true
    local descendantTables = {}
    local entryCount = 0
    local containsFunction = false
    for key, value in pairs(tableValue) do
        entryCount = entryCount + 1
        if entryCount > MAX_NAMESPACE_ENTRIES then
            inspectingTables[tableValue] = nil
            depthCache[tableValue] = false
            return false
        end
        if type(key) ~= "table" then
            if type(value) == "function" then
                containsFunction = true
            elseif remainingDepth > 0 and type(value) == "table" then
                tinsert(descendantTables, value)
            end
        end
    end

    if not containsFunction and remainingDepth > 0 then
        for _, descendantTable in ipairs(descendantTables) do
            if ContainsBoundedFunction(descendantTable, remainingDepth - 1, excludedTables, namespaceShapeCache, inspectingTables) then
                containsFunction = true
                break
            end
        end
    end

    inspectingTables[tableValue] = nil
    depthCache[tableValue] = containsFunction
    return containsFunction
end

---@param tableValue table
---@param name string
---@param excludedTables table<table, boolean>
---@param visitedTables table<table, boolean>
---@param namespaceShapeCache table<integer, table<table, boolean>>
---@param isRoot boolean
---@param questieStreamLib table?
function QuestieProfiler:HookTable(tableValue, name, excludedTables, visitedTables, namespaceShapeCache, isRoot, questieStreamLib)
    if IsProfilingPathDisallowed(name)
        or visitedTables[tableValue]
        or tableValue == QuestieProfiler
        or tableValue == _G then
        return
    end

    -- WoW frames are opaque. In particular, never inspect their contents or probe GetScript.
    local hasFrameStorage = type(rawget(tableValue, 0)) == "userdata"
    local hasFrameAPI = type(rawget(tableValue, "GetObjectType")) == "function" or type(rawget(tableValue, "GetScript")) == "function"
    if hasFrameStorage or hasFrameAPI then
        return
    end
    if not isRoot and (excludedTables[tableValue]
        or not ContainsBoundedFunction(tableValue, MAX_NAMESPACE_LOOKAHEAD, excludedTables, namespaceShapeCache, {})) then
        return
    end

    visitedTables[tableValue] = true

    -- Snapshot before replacing functions; sorting makes the chosen path deterministic for shared namespaces.
    local entries = {}
    for key, value in pairs(tableValue) do
        if type(key) ~= "table" then
            tinsert(entries, {key = key, value = value})
        end
    end
    table.sort(entries, SortSnapshotEntries)

    for _, entry in ipairs(entries) do
        local key = entry.key
        local value = entry.value
        local valueType = type(value)
        if valueType == "function" and value ~= LibStub and not ownedWrappers[value] and tableValue[key] == value then
            QuestieProfiler:HookFunction(key, value, tableValue, name)
        elseif valueType == "table" then
            -- QuestieStreamLib copies its primitives into each stream. Treat those runtime streams as the same
            -- low-level implementation surface instead of turning every byte read into a profiler measurement.
            local isQuestieStream = questieStreamLib
                and rawget(value, "_mode") ~= nil
                and rawget(value, "Load") == rawget(questieStreamLib, "Load")
            if not isQuestieStream then
                QuestieProfiler:HookTable(value, name .. "." .. tostring(key), excludedTables, visitedTables,
                    namespaceShapeCache, false, questieStreamLib)
            end
        end
    end
end

---Hooks newly available Questie module functions without stacking wrappers.
---@return boolean refreshed
function QuestieProfiler:RefreshHooks()
    if not QuestieProfiler.active then
        return false
    end

    -- Treat direct global tables as external boundaries when they are encountered beneath a Questie module.
    local excludedTables = {}
    for _, globalValue in pairs(_G) do
        if type(globalValue) == "table" then
            excludedTables[globalValue] = true
        end
    end

    -- AceAddon and AceDB attach non-Questie internals and saved/profile data to the Runtime Addon Object.
    if Questie.db then
        excludedTables[Questie.db] = true
    end
    if Questie.modules then
        excludedTables[Questie.modules] = true
    end
    if Questie.orderedModules then
        excludedTables[Questie.orderedModules] = true
    end

    local questieStreamLib = QuestieLoader._modules.QuestieStreamLib

    local moduleNames = {}
    for moduleName, module in pairs(QuestieLoader._modules) do
        if module ~= QuestieProfiler and moduleName ~= "ProfilerUI" then
            tinsert(moduleNames, moduleName)
        end
    end
    table.sort(moduleNames)

    local visitedTables = {}
    local namespaceShapeCache = {
        [0] = NewWeakKeyTable(),
        [1] = NewWeakKeyTable(),
        [2] = NewWeakKeyTable(),
    }
    QuestieProfiler.alreadyHooked = visitedTables
    for _, moduleName in ipairs(moduleNames) do
        QuestieProfiler:HookTable(QuestieLoader._modules[moduleName], moduleName, excludedTables, visitedTables,
            namespaceShapeCache, true, questieStreamLib)
    end

    QuestieProfiler:HookTable(Questie, "Questie", excludedTables, visitedTables, namespaceShapeCache, true, questieStreamLib)
    return true
end

-------------------------
-- Addon file load
-------------------------
-- QuestieLoader records how long each file took to load. Those rows describe work that finished before this
-- session's wrappers existed, so they are published once rather than measured, and a later Start clears them
-- along with everything else - a fresh session did not include the addon load and must not claim it did.
--
-- Kept in their own tables rather than mixed into the hook measurements. A loaded file is not a called
-- function: it has no call count, no caller, and no average, and letting it share hookTimeCount would let a
-- file's duration become the reported peak for functions and force every consumer to sniff a name prefix to
-- tell the two apart.

---Publishes QuestieLoader's per-file load timings.
function QuestieProfiler:ImportLoadTimings()
    local loadTimings = QuestieLoader.loadTimings
    local loadMemory = QuestieLoader.loadMemory or {}
    if not QuestieProfiler.active or type(loadTimings) ~= "table" then
        return
    end

    for source, elapsed in pairs(loadTimings) do
        QuestieProfiler.fileLoadTime[source] = elapsed
        QuestieProfiler.fileLoadMemory[source] = loadMemory[source] or 0
    end
end

local loadEventFrame

---Closes the load-timing window and publishes it. ADDON_LOADED is the first point at which the last file in
---the TOC has finished running, so nothing earlier can capture it.
local function RegisterLoadTimingImport()
    if loadEventFrame or not CreateFrame then
        return
    end

    loadEventFrame = CreateFrame("Frame")
    loadEventFrame:RegisterEvent("ADDON_LOADED")
    loadEventFrame:SetScript("OnEvent", function(self, _, addonName)
        if addonName ~= "Questie" then
            return
        end
        self:UnregisterEvent("ADDON_LOADED")

        if type(QuestieLoader.FinishLoadTimings) == "function" then
            QuestieLoader:FinishLoadTimings()
        end
        local imported, importError = pcall(QuestieProfiler.ImportLoadTimings, QuestieProfiler)
        if not imported then
            Questie:Error("QuestieProfiler failed to import load timings", importError)
        end
    end)
end

-------------------------
-- UI entry points
-------------------------
-- The UI module owns all frame and refresh state. These facades keep profiler lifecycle callers independent of its implementation.
-- Resolved once at file scope rather than per call. ImportModule is what QuestieLoader stamps load timings on,
-- so calling it at runtime would reopen an interval under this file's name and charge it whatever ran next -
-- which is how hook installation, the most expensive thing startup does, ended up reported as this file's
-- load cost. QuestieProfilerUI.lua loads after this one, but ImportModule hands back the table it will fill.
---@type QuestieProfilerUI
local ProfilerUI = QuestieLoader:ImportModule("ProfilerUI")

---@return QuestieProfilerUI
local function ImportProfilerUI()
    -- ImportModule always returns a table, so an absent file shows up as an unpopulated one.
    if type(ProfilerUI.Create) ~= "function" then
        error("QuestieProfilerUI.lua was not loaded")
    end
    return ProfilerUI
end

function QuestieProfiler:CreateUI()
    return ImportProfilerUI():Create()
end

function QuestieProfiler:ShowUI()
    return ImportProfilerUI():Show()
end

function QuestieProfiler:HideUI()
    return ImportProfilerUI():Hide()
end

-------------------------
-- Profiling session lifecycle
-------------------------
-- An error escaping every wrapper leaves the main stack dirty with no ancestor left to trim it, and every
-- later root call would then read a stale caller. Lua code always runs to completion within a frame, so
-- nothing legitimate is ever in flight at a frame boundary: clearing the depth once per frame bounds that
-- residue to the frame it happened in and costs nothing per call.
-- OnUpdate rather than a zero-duration ticker: it is the same once-per-frame cadence without adding an entry
-- to the timer stream that ThreadLib schedules its coroutine pumps on.
local frameBoundaryDriver

local function ClearMainDepth()
    mainDepth = 0
end

local function StartFrameBoundaryReset()
    if not frameBoundaryDriver then
        if not CreateFrame then
            return
        end
        frameBoundaryDriver = CreateFrame("Frame")
    end
    frameBoundaryDriver:SetScript("OnUpdate", ClearMainDepth)
end

local function StopFrameBoundaryReset()
    if frameBoundaryDriver then
        frameBoundaryDriver:SetScript("OnUpdate", nil)
    end
end

-- The profiler is armed for the addon lifetime by default. UI visibility owns only the display ticker;
-- Stop/Unhook owns callback registration and wrapper restoration.
---Starts a fresh measurement window without replacing installed wrappers.
function QuestieProfiler:ResetMeasurements()
    measurementGeneration = measurementGeneration + 1
    for lookupKey in pairs(QuestieProfiler.hookCallCount) do
        QuestieProfiler.hookCallCount[lookupKey] = 0
        QuestieProfiler.hookTimeCount[lookupKey] = 0
        QuestieProfiler.hookSelfTime[lookupKey] = 0
    end
    for lookupKey in pairs(QuestieProfiler.threadJobCallCount) do
        QuestieProfiler.threadJobCallCount[lookupKey] = 0
        QuestieProfiler.threadJobResumeCount[lookupKey] = 0
    end
    -- Edges name callers that may not be called again, so clearing beats zeroing every pair.
    QuestieProfiler.callerCallCount = {}
    QuestieProfiler.callerTimeCount = {}

    -- Calls that started before this measurement window must never publish into it.
    for _, frames in pairs(threadFrames) do
        for _, frame in ipairs(frames) do
            frame.discarded = true
        end
    end
    threadFrames = NewWeakKeyTable()

    -- Main-thread calls still in flight belong to the cleared window; the generation guard already stops them
    -- publishing, and dropping the depth keeps their stale frames from being read as callers.
    mainDepth = 0

    -- Active ThreadLib jobs continue into the new window as one job call.
    for _, job in pairs(threadJobs) do
        if QuestieProfiler.hookCallCount[job.lookupKey] ~= nil then
            QuestieProfiler.hookCallCount[job.lookupKey] = QuestieProfiler.hookCallCount[job.lookupKey] + 1
            QuestieProfiler.threadJobCallCount[job.lookupKey] = QuestieProfiler.threadJobCallCount[job.lookupKey] + 1
        end
        if job.activeSince then
            -- The elapsed portion before ResetMeasurements belongs to the cleared window.
            -- Continue timing the remainder of this currently executing resume in the new window.
            job.activeSince = Now()
        end
    end

    QuestieProfiler.highestMS = 0
    QuestieProfiler.highestCalls = 0
    for _, callCount in pairs(QuestieProfiler.hookCallCount) do
        if callCount > QuestieProfiler.highestCalls then
            QuestieProfiler.highestCalls = callCount
        end
    end
end

---Ends the profiling session and restores only function slots still owned by the profiler.
function QuestieProfiler:Unhook()
    if not QuestieProfiler.active then
        return
    end

    QuestieProfiler.active = false
    clearThreadProfilingCallbacks(QuestieProfiler)

    for i = #QuestieProfiler.hooks, 1, -1 do
        local hook = QuestieProfiler.hooks[i]
        hook.enabled = false
        if hook.originalParent[hook.originalKey] == hook.override then
            hook.originalParent[hook.originalKey] = hook.original
        end
    end

    StopFrameBoundaryReset()
    currentThread = nil
    mainDepth = 0
    threadFrames = NewWeakKeyTable()
    threadJobs = NewWeakKeyTable()

    -- Release original functions and wrapper closures while retaining string-keyed measurements and summary counts for the stopped UI.
    QuestieProfiler.hooks = {}
    QuestieProfiler.alreadyHooked = {}
    QuestieProfiler.lookupToHook = {}
    QuestieProfiler.shortestName = {}

end

function QuestieProfiler:Stop()
    QuestieProfiler:Unhook()
end

---Starts the single profiling mode and applies its requested UI visibility before installing broad hooks.
---@param showUI boolean? @Defaults to true
---@return boolean armed @False when timing support, ThreadLib callback ownership, or hook installation is unavailable
local function StartProfilingSession(showUI)
    if QuestieProfiler.active then
        if showUI ~= false then
            local uiShown, showError = pcall(QuestieProfiler.ShowUI, QuestieProfiler)
            if not uiShown then
                Questie:Error("QuestieProfiler failed to show its UI", showError)
            end
        else
            local uiHidden, hideError = pcall(QuestieProfiler.HideUI, QuestieProfiler)
            if not uiHidden then
                Questie:Error("QuestieProfiler failed to hide its UI", hideError)
            end
        end
        return true
    end

    if not Now then
        return false
    end
    -- Claim callback ownership before resetting prior results, then install active callbacks only after state is ready.
    if not setThreadProfilingCallbacks(QuestieProfiler, nil) then
        return false
    end

    ResetSessionState()
    QuestieProfiler.active = true
    if not setThreadProfilingCallbacks(QuestieProfiler, profilingCallbacks) then
        QuestieProfiler.active = false
        clearThreadProfilingCallbacks(QuestieProfiler)
        return false
    end
    StartFrameBoundaryReset()
    RegisterLoadTimingImport()

    -- Showing first gives immediate feedback while the bounded module traversal installs the function wrappers.
    if showUI ~= false then
        local uiShown, showError = pcall(QuestieProfiler.ShowUI, QuestieProfiler)
        if not uiShown then
            Questie:Error("QuestieProfiler failed to show its UI", showError)
        end
    else
        local uiHidden, hideError = pcall(QuestieProfiler.HideUI, QuestieProfiler)
        if not uiHidden then
            Questie:Error("QuestieProfiler failed to hide its UI", hideError)
        end
    end

    local hooksRefreshed, refreshError = pcall(QuestieProfiler.RefreshHooks, QuestieProfiler)
    if not hooksRefreshed then
        QuestieProfiler:Unhook()
        Questie:Error("QuestieProfiler failed to install hooks", refreshError)
        return false
    end
    return true
end

---Arms profiling during Addon Load using the same hook scope as Start.
---@param showUI boolean
---@return boolean armed @False when timing support, ThreadLib callback ownership, or hook installation is unavailable
function QuestieProfiler:StartStartup(showUI)
    return StartProfilingSession(showUI)
end

---Arms profiling and optionally shows the profiler UI.
---@param showUI boolean? @Defaults to true for the Advanced option and /run usage
---@return boolean armed @False when timing support, ThreadLib callback ownership, or hook installation is unavailable
function QuestieProfiler:Start(showUI)
    return StartProfilingSession(showUI)
end
