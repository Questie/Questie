---@class QuestieProfiler
local QuestieProfiler = QuestieLoader:CreateModule("Profiler")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type QuestieProfilerPreHook
local ProfilerPreHook = QuestieLoader:ImportModule("ProfilerPreHook")

local setThreadProfilingCallbacks = ThreadLib.SetProfilingCallbacks
local clearThreadProfilingCallbacks = ThreadLib.ClearProfilingCallbacks
local getTimePreciseSec = GetTimePreciseSec
local tinsert = table.insert
local unpack = unpack

-- One clock, deliberately. debugprofilestop resolves the same and costs the same, but any addon can reset it
-- to zero by calling debugprofilestart, and a reset landing between a wrapper's two reads yields a large
-- negative elapsed that AddMeasurement then accumulates - permanently poisoning that function's total and the
-- session's highestMS. It was carried as a fallback for a while and was worth neither the bug class nor the
-- code: measured on a live client, a reset mid-call published -99 ms, and the branch could never run anyway
-- because QuestieLoader calls GetTimePreciseSec directly and would have errored first.
--
-- GetTimePreciseSec is monotonic and present on every client Questie supports. If it is ever absent the
-- profiler declines to arm rather than measuring with something that can go backwards.
---@type (fun(): number)? @Current time in milliseconds; nil when the client offers no usable timer
local Now
if type(getTimePreciseSec) == "function" then
    Now = function()
        return getTimePreciseSec() * 1000
    end
end

---@return table weakKeyTable
local function NewWeakKeyTable()
    return setmetatable({}, {__mode = "k"})
end

---@class ProfilerCoroutineFrame
---@field lookupKey string
---@field activeSince number? @Start of the current resume slice; nil while the coroutine is suspended
---@field accumulated number @Active time banked from resume slices this call has already survived
---@field generation integer @Measurement window in which this call started
---@field discarded boolean @True when the frame is stale or belongs to a cleared measurement window
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
--
-- On a coroutine that window now spans yields: frames deliberately survive AfterResume since cross-slice
-- accumulation landed, so a frame left stale by a caught error keeps mis-parenting the ancestor's later
-- calls - wrong caller edges, elapsed banked into the stale frame's childTime - for as many resume slices
-- as the ancestor lives. The stale frame still never publishes anything itself (its own return never
-- comes), and measured over 97,894 profiled coroutine returns in a full session, zero stale frames
-- occurred: no profiled function in the addon today errors inside a pcall inside a job.
--
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

    -- Anchored on "AddOns/Questie/" rather than on "Interface", because WoW truncates a long path from the
    -- left with an ellipsis - "...erface/AddOns/Questie/Modules/..." - and a match that needs the whole word
    -- silently leaves the ellipsis and the full path in the job's name. Still specific enough that another
    -- addon's path cannot collapse into a Questie one.
    stackLine = string.gsub(stackLine, "[^%[%]]-[Aa]dd[Oo]ns[/\\]+[Qq]uestie[/\\]+", "", 1)

    -- The match above still needs "AddOns/Questie/" intact, and for a window of path lengths the ellipsis
    -- cut lands inside the marker itself - "...Ons/Questie/Modules/..." or "...stie/Modules/..." - keeping
    -- the exact ellipsis-and-path name this function exists to remove. What sits between the ellipsis and
    -- the first slash can then only be the tail of a marker directory, so it is judged as a suffix. A
    -- foreign addon whose truncated name merely ends like "AddOns" keeps its path: the strip needs the
    -- Questie segment after it, which no other addon's path carries.
    local ellipsisFragment, afterFragment = string.match(stackLine, "^%.%.%.([^/\\]*)[/\\]+(.*)$")
    if ellipsisFragment then
        local lowerFragment = string.lower(ellipsisFragment)
        if lowerFragment == "" or string.sub("addons", -string.len(lowerFragment)) == lowerFragment then
            local strippedPath, questieMatches = string.gsub(afterFragment, "^[Qq]uestie[/\\]+", "")
            if questieMatches > 0 then
                stackLine = strippedPath
            end
        elseif string.sub("questie", -string.len(lowerFragment)) == lowerFragment then
            stackLine = afterFragment
        end
    end

    stackLine = string.gsub(stackLine, "^%[(.-)%]", "%1")
    -- Addon-load rows spell the same file with forward slashes; a job naming it differently would read as a
    -- different file.
    stackLine = string.gsub(stackLine, "\\", "/")
    return stackLine
end

-- ThreadLib is itself profiled, so at submission time its own scheduling functions are the top of the shadow
-- stack. They are never the answer to "who scheduled this job" - they are how it was scheduled.
local SCHEDULER_KEY_PREFIX = "ThreadLib."
local SCHEDULER_KEY_PREFIX_LENGTH = string.len(SCHEDULER_KEY_PREFIX)

---Walks down a shadow stack past the scheduler's own frames to the function that actually submitted the job.
---@param frames ProfilerCoroutineFrame[]?
---@param depth number
---@return string? lookupKey
local function NearestSubmitter(frames, depth)
    if not frames then
        return nil
    end
    for index = depth, 1, -1 do
        local lookupKey = frames[index] and frames[index].lookupKey
        if lookupKey and string.sub(lookupKey, 1, SCHEDULER_KEY_PREFIX_LENGTH) ~= SCHEDULER_KEY_PREFIX then
            return lookupKey
        end
    end
    return nil
end

---The profiled function currently executing, taken from the same shadow stack that attributes callers.
---
---This is what makes a submitted closure nameable without anyone writing a name down. `debugstack` cannot do
---it: Lua infers a function's name from the expression that called it, and every profiled function is invoked
---indirectly through this file's wrapper, so the frame carrying the real file reports `in function <file:line>`
---and the frame carrying the name reports `QuestieProfiler.lua`. The shadow stack has neither problem - it
---holds the fully qualified lookup key, is already maintained for caller attribution, and costs a table read.
---
---It inherits that mechanism's one documented flaw: after an error is caught, the top frame is stale until the
---catching ancestor returns, so a job submitted inside that window is named after the errored function.
---@return string? callerKey
local function CurrentProfiledCaller()
    if currentThread then
        local frames = threadFrames[currentThread]
        local submitter = NearestSubmitter(frames, frames and #frames or 0)
        if submitter then
            return submitter
        end
        -- Submitted by a job rather than by a call inside one: the job is the nearest thing that owns it.
        local job = threadJobs[currentThread]
        return job and job.lookupKey or nil
    end

    return NearestSubmitter(mainStack, mainDepth)
end

---@param submittedFunction function
---@param callSiteStack string?
---@param threadName string?
---@return string description
local function DescribeThreadJob(submittedFunction, callSiteStack, threadName)
    if threadName and threadName ~= "" then
        return threadName
    end

    -- The submitted function itself, when it is one this profiler already knows by name. Better than naming
    -- the job after whoever scheduled it, because it describes the work rather than the trigger.
    local knownName = QuestieProfiler.shortestName[submittedFunction]
    if knownName then
        return knownName
    end

    -- Otherwise the closure is anonymous, and the most useful stable identity available is the profiled
    -- function that submitted it. Several closures scheduled by one function share a name; that is the cost
    -- of not having to write names down, and Thread's threadName parameter is the way to split them.
    local submittingCaller = CurrentProfiledCaller()
    if submittingCaller then
        -- A job submitted from inside another job's anonymous body falls through to the parent job itself,
        -- whose key already carries the prefix this description gets wrapped in. Strip it rather than
        -- registering the child under "ThreadLib job: ThreadLib job: X".
        return (string.gsub(submittingCaller, "^ThreadLib job: ", ""))
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

        -- Calls this resume continues start a new slice; everything before now was suspended, not spent.
        local frames = threadFrames[thread]
        if frames then
            for i = 1, #frames do
                frames[i].activeSince = now
            end
        end

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
            -- Bank what each still-running call spent in this slice and stop its clock. Suspended time never
            -- falls between a stamp and a bank, so it cannot be counted. The frames stay: the coroutine's
            -- call stack really is still those functions, and the next resume continues them.
            for i = 1, #frames do
                local frame = frames[i]
                if frame.activeSince then
                    frame.accumulated = frame.accumulated + (now - frame.activeSince)
                    frame.activeSince = nil
                end
            end
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

-- Exposed for the pre-hook cross-check below and for tests; nothing reads it at runtime.
QuestieProfiler.__disallowedPaths = PROFILING_DISALLOWED_PATHS

---Every path this file refuses to measure must also be refused by QuestieProfilerPreHook, which wraps module
---functions as the addon loads. If it is not, the pre-hook installs a permanent indirection on a slot whose
---whole reason for exclusion is that it runs thousands of times inside one useful measurement - so the cost
---lands with none of the benefit, and nothing would say so. The two lists cannot be shared: the pre-hook runs
---long before this file exists. This is what keeps them from drifting apart quietly.
---@return string[] mismatches @Disallowed paths the pre-hook would still wrap
function QuestieProfiler.FindPreHookExclusionMismatches()
    local isExcluded = ProfilerPreHook.IsExcluded
    if type(isExcluded) ~= "function" then
        return {}
    end

    local mismatches = {}
    for path in pairs(PROFILING_DISALLOWED_PATHS) do
        local moduleName, memberName = string.match(path, "^([^.]+)%.(.+)$")
        -- A bare module name means the whole module is refused, so ask about any member of it.
        if not moduleName then
            moduleName, memberName = path, "AnyFunction"
        end
        if not isExcluded(moduleName, memberName) then
            mismatches[#mismatches + 1] = path
        end
    end
    return mismatches
end

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
                accumulated = 0,
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
                -- Every slice this call survived, plus the one it returned in. A call that never yielded has
                -- banked nothing, so this is the same arithmetic it always was.
                local elapsed = frame.accumulated + (frame.activeSince and (Now() - frame.activeSince) or 0)
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

-------------------------
-- Bundled library roots
-------------------------
-- A library method called by Questie is already being paid for - it sits inside the self time of whichever
-- Questie function called it, unnamed. Profiling these roots does not add cost to the addon, it moves cost
-- that is already there onto a row that says where it went. Measured on Era: a full icon redraw spent 774 ms
-- inside HereBeDragons-Pins public methods against 1419 ms in every Questie function combined, 643 ms of it in
-- RemoveWorldMapIcon alone, and none of it was visible in the report.
--
-- Questie-suffixed majors only. The other 22 libraries LibStub holds here are generic - Ace3, CallbackHandler,
-- LibSharedMedia, LibDBIcon, Krowi - and registration is not ownership: the loaded copy may belong to another
-- addon, so wrapping those tables would count other addons' calls, add overhead to them, and let this report
-- claim work that is not Questie's. An explicit list rather than a name pattern, because "Questie" in a major
-- is a naming convention rather than a guarantee, and four entries are cheap to keep honest.
-- Named for the folder the code sits in and for whatever Questie's own files call the library - HBD, HBDPins
-- and LibDropDown are the aliases used at 11 call sites across the addon, while the LibStub major is a string
-- nobody types. It reads as the same thing the reader already has in their own file, and it leaves room in the
-- narrow relation columns, where "Libraries.HereBeDragonsPins.worldmapProvider.HandlePin" lost the function
-- name to an ellipsis and this does not.
local PROFILED_LIBRARIES = {
    {
        major = "HereBeDragonsQuestie-2.0",
        name = "Libs.HBD",
        frameScripts = {{field = "eventFrame", scripts = {"OnEvent"}}},
    },
    {
        major = "HereBeDragonsQuestie-Pins-2.0",
        name = "Libs.HBDPins",
        -- The minimap updater, and the reason frame scripts are worth reaching at all. Measured on Era while
        -- running 659 yards: 6.68 ms per second here against 0.11 ms per second across every Questie function
        -- combined, because UpdateMinimapIconPosition redraws every active pin on every frame the player moves.
        -- Standing still it costs 0.36 ms per second, the loop being guarded on the position having changed,
        -- which is why every stationary measurement taken before this said there was nothing here.
        frameScripts = {{field = "updateFrame", scripts = {"OnUpdate", "OnEvent"}}},
        -- worldmapProviderPin is a pin mixin, and `Mixin(frame, worldmapProviderPin)` copies it onto every pin
        -- frame as that frame is created. A wrapper installed on this table is therefore copied onto every pin
        -- created afterwards, and Unhook restores this table rather than those copies - so the wrappers would
        -- outlive the session on every live pin, with no way to take them back. Never traverse it.
        --
        -- worldmapProvider next to it is safe and worth having: CreateFromMixins copied it once, nothing copies
        -- it again, and it owns RemovePinByIcon - the function that makes RemoveWorldMapIcon cost 109us.
        excludedFields = {"worldmapProviderPin"},
    },
    {major = "HereBeDragonsQuestie-Migrate", name = "Libs.HBDMigrate"},
    {major = "LibUIDropDownMenuQuestie-4.0", name = "Libs.LibDropDown"},
}

---Installs measured wrappers on the frame scripts of an allowlisted library.
---
---A frame script is the one binding a table traversal cannot reach. HBD Pins assigns its handler with
---`SetScript` and keeps the function in a file-local, so nothing on the library table refers to it, and no
---amount of walking that table will find it. Replacing the script slot is the only way in.
---
---Explicitly named frames only, and this must stay that way. Frames are runtime objects with protected
---behaviour and enormous graphs, and probing an arbitrary one is how a profiler starts breaking the UI it
---is measuring. These two belong to Questie's own embedded copies of HBD and are ordinary unprotected frames.
---@param library table
---@param target table @An entry of PROFILED_LIBRARIES
local function HookLibraryFrameScripts(library, target)
    for _, frameTarget in ipairs(target.frameScripts or {}) do
        local frame = rawget(library, frameTarget.field)
        -- A frame is a table with the script API on its metatable, so this asks the frame rather than raw-reading it.
        if type(frame) == "table" and type(frame.GetScript) == "function" and type(frame.SetScript) == "function" then
            -- A script slot is not a table slot, so hand HookFunction one that reads and writes through the
            -- frame. Everything downstream then works unchanged - in particular Unhook's ownership check,
            -- which compares the frame's current script against the wrapper and restores only its own.
            local scriptSlot = setmetatable({}, {
                __index = function(_, scriptName)
                    return frame:GetScript(scriptName)
                end,
                __newindex = function(_, scriptName, handler)
                    frame:SetScript(scriptName, handler)
                end,
            })

            for _, scriptName in ipairs(frameTarget.scripts) do
                local original = frame:GetScript(scriptName)
                -- ownedWrappers is what keeps a repeated RefreshHooks from wrapping the wrapper: HookTable
                -- checks it for table slots, and nothing else checks it for these.
                if type(original) == "function" and not ownedWrappers[original] then
                    QuestieProfiler:HookFunction(scriptName, original, scriptSlot,
                        target.name .. "." .. frameTarget.field)
                end
            end
        end
    end
end

---Traverses the allowlisted libraries as profiler roots.
---
---Runs before the Questie modules so that a table reachable from both is named for the library that owns it
---rather than for whichever module happened to reach it first.
---@param excludedTables table<table, boolean>
---@param visitedTables table<table, boolean>
---@param namespaceShapeCache table<integer, table<table, boolean>>
---@param questieStreamLib table?
local function HookProfiledLibraries(excludedTables, visitedTables, namespaceShapeCache, questieStreamLib)
    if type(LibStub) ~= "table" or type(LibStub.GetLibrary) ~= "function" then
        return
    end

    for _, target in ipairs(PROFILED_LIBRARIES) do
        -- Silent lookup: a library absent on this client flavor is an ordinary outcome, not an error.
        local resolved, library = pcall(LibStub.GetLibrary, LibStub, target.major, true)
        if resolved and type(library) == "table" then
            for _, fieldName in ipairs(target.excludedFields or {}) do
                local field = rawget(library, fieldName)
                if type(field) == "table" then
                    excludedTables[field] = true
                end
            end

            QuestieProfiler:HookTable(library, target.name, excludedTables, visitedTables,
                namespaceShapeCache, true, questieStreamLib)
            HookLibraryFrameScripts(library, target)
        end
    end
end

---Hooks the indirections QuestieProfilerPreHook installed while the addon loaded.
---
---Those slots hold a stable wrapper that files below them in the TOC captured into file-scope locals. The
---wrapper cannot be replaced - an alias already has it - so what gets hooked is the indirection behind it,
---through a stand-in table that reads and writes the wrapper's target. Unhook then restores it by the same
---ownership check it uses everywhere else, and a later session can hook it again, which a plain hook on the
---module slot could not survive.
local function HookPreInstalledIndirections()
    local preHooked = ProfilerPreHook.targets
    if type(preHooked) ~= "table" then
        return
    end

    for index = 1, #preHooked do
        local target = preHooked[index]
        -- The module slot holds the stable wrapper, and the traversal is about to walk that table. Marking it
        -- owned is what stops the wrapper being wrapped again and every call measured twice.
        ownedWrappers[target.wrapper] = true
        if not ownedWrappers[target.slot[target.functionName]] then
            QuestieProfiler:HookFunction(target.functionName, target.original, target.slot, target.moduleName)
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
        -- ProfilerReport is the window's other half. Wrapping it would measure the diagnostic tool
        -- while it builds the very report the measurements are displayed in.
        if module ~= QuestieProfiler and moduleName ~= "ProfilerUI" and moduleName ~= "ProfilerReport"
            and moduleName ~= "ProfilerPreHook" then
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
    HookPreInstalledIndirections()
    HookProfiledLibraries(excludedTables, visitedTables, namespaceShapeCache, questieStreamLib)
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
-- session's wrappers existed, so they are published rather than measured. The loader retains its closed
-- readings, and each later Start republishes them after clearing the previous session's result tables.
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

---True once a session has measured anything, whether or not it is still running: a stopped session's
---results stay readable until the next Start resets them.
---@return boolean
function QuestieProfiler:HasResults()
    return QuestieProfiler.active == true or next(QuestieProfiler.hookCallCount) ~= nil
end

---Opens the window on whatever exists - the running session, or a stopped session's retained results.
---Only when there is nothing to show does this start a session, because Start resets retained measurements
---and must not be the price of reopening a closed window.
function QuestieProfiler:OpenUI()
    if QuestieProfiler:HasResults() then
        return QuestieProfiler:ShowUI()
    end
    return QuestieProfiler:Start()
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
---@return boolean? rejectionReported @True when the profiler already named the rejection reason in chat
local function StartProfilingSession(showUI)
    if QuestieProfiler.active then
        if showUI ~= false then
            local uiShown, showError = pcall(QuestieProfiler.ShowUI, QuestieProfiler)
            if not uiShown then
                Questie.Error("QuestieProfiler failed to show its UI", showError)
            end
        else
            local uiHidden, hideError = pcall(QuestieProfiler.HideUI, QuestieProfiler)
            if not uiHidden then
                Questie.Error("QuestieProfiler failed to hide its UI", hideError)
            end
        end
        return true
    end

    -- Said out loud rather than failing quietly: the player asked for a profiling session, and "nothing
    -- happened" is a worse answer than a line in chat naming the reason.
    if not Now then
        Questie.Error("QuestieProfiler cannot run: this client has no GetTimePreciseSec")
        return false, true
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
    -- ResetSessionState cleared the published copy, but QuestieLoader still holds the readings. Addon load
    -- happened once for this client and cannot be measured again, so a restarted session republishes rather
    -- than destroying the only record of it. The UI hides the rows instead, which is reversible.
    local imported, importError = pcall(QuestieProfiler.ImportLoadTimings, QuestieProfiler)
    if not imported then
        Questie.Error("QuestieProfiler failed to import load timings", importError)
    end

    -- Showing first gives immediate feedback while the bounded module traversal installs the function wrappers.
    if showUI ~= false then
        local uiShown, showError = pcall(QuestieProfiler.ShowUI, QuestieProfiler)
        if not uiShown then
            Questie.Error("QuestieProfiler failed to show its UI", showError)
        end
    else
        local uiHidden, hideError = pcall(QuestieProfiler.HideUI, QuestieProfiler)
        if not uiHidden then
            Questie.Error("QuestieProfiler failed to hide its UI", hideError)
        end
    end

    -- Cheap and once per session: roughly twenty string matches, against a class of drift whose only symptom
    -- would be a low-level path quietly dominating every report.
    local mismatches = QuestieProfiler.FindPreHookExclusionMismatches()
    if #mismatches > 0 then
        Questie.Error("QuestieProfilerPreHook is missing exclusions the profiler requires:",
            table.concat(mismatches, ", "))
    end

    local hooksRefreshed, refreshError = pcall(QuestieProfiler.RefreshHooks, QuestieProfiler)
    if not hooksRefreshed then
        QuestieProfiler:Unhook()
        Questie.Error("QuestieProfiler failed to install hooks", refreshError)
        return false, true
    end
    return true
end

---Arms profiling during Addon Load using the same hook scope as Start.
---@param showUI boolean
---@return boolean armed @False when timing support, ThreadLib callback ownership, or hook installation is unavailable
---@return boolean? rejectionReported @True when the profiler already named the rejection reason in chat
function QuestieProfiler:StartStartup(showUI)
    return StartProfilingSession(showUI)
end

---Arms profiling and optionally shows the profiler UI.
---@param showUI boolean? @Defaults to true for the Advanced option and /run usage
---@return boolean armed @False when timing support, ThreadLib callback ownership, or hook installation is unavailable
---@return boolean? rejectionReported @True when the profiler already named the rejection reason in chat
function QuestieProfiler:Start(showUI)
    return StartProfilingSession(showUI)
end
