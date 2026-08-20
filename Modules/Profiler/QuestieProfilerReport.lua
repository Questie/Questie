---@class QuestieProfilerReport
local QuestieProfilerReport = QuestieLoader:CreateModule("ProfilerReport")

-------------------------
-- Report building (pure, frame free)
-------------------------
-- A pure transformation of profiler tables into display rows. Nothing here reads or writes a frame, which is
-- what lets sorting, filtering, grouping and every number the window prints be tested without standing up a
-- UI - and guarantees that browsing a report cannot touch a measurement.
--
-- It is its own file for that reason rather than for length. The window half is 2,500 lines of frames, anchors
-- and scripts that can only be exercised against a live client; this half is tables in, tables out. Keeping
-- the seam physical stops the two from growing into each other, and the profiler engine is not imported here
-- at all - a report is built from whatever table it is handed, which is what makes a frozen snapshot possible.

-- Performance: alias frequently used functions
local tinsert = table.insert
local tsort = table.sort
local sfind = string.find
local sformat = string.format
local slower = string.lower
local smatch = string.match
local ssub = string.sub

-- Sort keys are the report's vocabulary rather than the window's: they name the metrics a row carries, and the
-- window picks one of them. Exported so there is a single spelling of each.

local SORT_NAME = "name"
local SORT_TOTAL = "total"
local SORT_SELF = "self"
local SORT_CALLS = "calls"
local SORT_AVERAGE = "average"
local SORT_MEMORY = "memory"

QuestieProfilerReport.SORT_NAME = SORT_NAME
QuestieProfilerReport.SORT_TOTAL = SORT_TOTAL
QuestieProfilerReport.SORT_SELF = SORT_SELF
QuestieProfilerReport.SORT_CALLS = SORT_CALLS
QuestieProfilerReport.SORT_AVERAGE = SORT_AVERAGE
QuestieProfilerReport.SORT_MEMORY = SORT_MEMORY

-- Names already carry a hierarchy the flat list throws away: files are directory paths, functions are module
-- paths. Rebuilding it is what lets the window answer "what does all of Database/ cost", which no per-row
-- view can. Jobs have no path of their own, so they collect under one synthetic node rather than vanishing.
local THREAD_JOB_TREE_LABEL = "ThreadLib jobs"
QuestieProfilerReport.THREAD_JOB_TREE_LABEL = THREAD_JOB_TREE_LABEL

local THREAD_JOB_PREFIX = "ThreadLib job: "
local THREAD_JOB_PREFIX_LENGTH = string.len(THREAD_JOB_PREFIX)

-- The root the profiler files bundled-library functions under, spelled for the folder the code sits in.
-- Dotted like any other path, so the hierarchy panel folds every library into one node and its total can be
-- read against Questie's own without expanding anything - which is the whole reason this is a path segment
-- rather than a bare tag, and why it stayed a prefix when it was shortened.
local LIBRARY_PREFIX = "Libs."
local LIBRARY_PREFIX_LENGTH = string.len(LIBRARY_PREFIX)
-- Segments that carry no identity of their own. Only `private` qualifies: it is an indirection table every
-- module reaches its own internals through. Numeric segments were dropped here once, on the theory that an
-- index like packets.1.read is noise - but the same rule folded QuestieInit.Stages.1/2/3 into one row, where
-- the index *is* the identity. Measured on a live session, dropping numbers merged three groups and lost
-- that distinction; keeping them merges nothing at all. The packet rows it was meant to tidy are never
-- called, so the idle filter already hides them.
local GROUPING_NOISE_SEGMENTS = {private = true}

---@class ProfilerReportRow
---@field lookupKey string @Identity used for display and tie-breaking
---@field displayName string @Identity with the ThreadLib prefix removed
---@field totalTime number @Inclusive: this call and everything profiled beneath it
---@field selfTime number @Inclusive minus the measured time of profiled children
---@field hasSelfTime boolean @False for ThreadLib jobs, which are not call frames and have no self time
---@field memoryKilobytes number? @Allocation attributed to this row; only addon-load rows carry one
---@field share number? @0-1 of what this row's own species accounts for; nil when there is no denominator
---@field shareDenominator number? @The species total the share was taken against
---@field calls number
---@field averageTime number
---@field isThreadJob boolean
---@field isFileLoad boolean @True for an addon file load, which is not a call and has no caller or average
---@field isLibrary boolean @True for a bundled-library function: an ordinary call, but not Questie's code
---@field hasCalls boolean @False for addon-load rows, where a call count would be meaningless
---@field hasTiming boolean @False when the entry was counted but never produced a timed slice
---@field jobCalls number? @Submitted ThreadLib jobs
---@field resumeCount number? @Coroutine resumes across all submitted jobs
---@field mergedPaths string[]? @Full paths folded into this row in grouped view

---@class ProfilerReportSource
---@field hookCallCount table<string, number>
---@field hookTimeCount table<string, number>
---@field hookSelfTime table<string, number>
---@field fileLoadTime table<string, number>
---@field fileLoadMemory table<string, number>
---@field callerCallCount table<string, table<string, number>>
---@field callerTimeCount table<string, table<string, number>>
---@field lowerCaseLookup table<string, string>
---@field threadJobCallCount table<string, number>
---@field threadJobResumeCount table<string, number>

---@class ProfilerReportOptions
---@field filter string?
---@field grouped boolean?
---@field hideIdle boolean? @Drop entries that were never called during this session
---@field showFunctions boolean?
---@field showJobs boolean?
---@field showFiles boolean?
---@field scopePrefix string? @Only rows whose identity starts with this are kept
---@field sortKey string?
---@field descending boolean?

---@class ProfilerReport
---@field rows ProfilerReportRow[]
---@field matchedCount number @Rows the user can actually see
---@field totalCount number @Entries the profiler holds
---@field idleHiddenCount number @Entries withheld by the idle filter alone
---@field idleCount number @Entries never called, counted whether or not they are currently hidden
---@field speciesCounts table<string, number> @Rows each species would contribute, whether shown or not
---@field maxTotalTime number
---@field maxSelfTime number
---@field maxCalls number
---@field maxAverageTime number
---@field maxMemoryKilobytes number

---@param lookupKey string
---@return boolean
local function IsThreadJobKey(lookupKey)
    return ssub(lookupKey, 1, THREAD_JOB_PREFIX_LENGTH) == THREAD_JOB_PREFIX
end

---@param lookupKey string
---@return boolean
local function IsLibraryKey(lookupKey)
    return ssub(lookupKey, 1, LIBRARY_PREFIX_LENGTH) == LIBRARY_PREFIX
end


---Shortens a full profiler path by dropping only the segments that do not identify the function.
---Every other segment is kept, so two different functions can never collapse into one row: an earlier rule
---folded everything between the first and last segment, which merged eight distinct tab initialisers into a
---single QuestieOptions.Initialize and hid which one was slow. Grouped view therefore shortens identities
---rather than aggregating them; entries still combine when two paths genuinely shorten to the same name.
---A ThreadLib job named after a file keeps its whole identity: its call site is what distinguishes it, and a
---path's segments are not module segments to drop. A job named after a function is shortened by the same rule
---as the function itself, so the pair does not appear on one screen spelled two ways - the job row reading
---QuestieInit.private.StartStageCoroutine directly above the function row reading QuestieInit.
---StartStageCoroutine looked like two unrelated entries.
---Addon-load rows never reach here: files are not module paths and live in their own table.
---@param lookupKey string
---@return string groupedIdentity
local function GroupedIdentity(lookupKey)
    if IsThreadJobKey(lookupKey) then
        local jobName = ssub(lookupKey, THREAD_JOB_PREFIX_LENGTH + 1)
        if sfind(jobName, "/", 1, true) or sfind(jobName, ".lua:", 1, true) then
            return lookupKey
        end
        return THREAD_JOB_PREFIX .. GroupedIdentity(jobName)
    end

    -- Drop the disambiguation suffix HookFunction appends when two paths produce the same key.
    local baseKey = smatch(lookupKey, "^(.-)%s*%[%a+ #%d+%]$") or lookupKey

    local keptSegments = {}
    for segment in string.gmatch(baseKey, "[^.]+") do
        if not GROUPING_NOISE_SEGMENTS[segment] then
            tinsert(keptSegments, segment)
        end
    end

    if #keptSegments == 0 then
        return baseKey
    end
    return table.concat(keptSegments, ".")
end

---@param lookupKey string
---@return string displayName
local function DisplayNameFor(lookupKey)
    if IsThreadJobKey(lookupKey) then
        return ssub(lookupKey, THREAD_JOB_PREFIX_LENGTH + 1)
    end
    return lookupKey
end

---@param row ProfilerReportRow
---@param sortKey string
---@return number|string
local function SortValue(row, sortKey)
    if sortKey == SORT_CALLS then
        return row.calls
    elseif sortKey == SORT_AVERAGE then
        return row.averageTime
    elseif sortKey == SORT_SELF then
        return row.hasSelfTime and row.selfTime or 0
    elseif sortKey == SORT_MEMORY then
        return row.memoryKilobytes or 0
    elseif sortKey == SORT_NAME then
        return slower(row.displayName)
    end
    return row.totalTime
end

---@param sortKey string
---@param descending boolean
---@return fun(left: ProfilerReportRow, right: ProfilerReportRow): boolean
local function BuildComparator(sortKey, descending)
    return function(left, right)
        local leftValue = SortValue(left, sortKey)
        local rightValue = SortValue(right, sortKey)
        if leftValue == rightValue then
            -- Equal values always fall back to the same ascending identity order so refreshes do not reshuffle rows.
            return left.lookupKey < right.lookupKey
        end
        if descending then
            return leftValue > rightValue
        end
        return leftValue < rightValue
    end
end

---Builds the displayable result set from a profiler snapshot.
---@param source ProfilerReportSource
---@param options ProfilerReportOptions
---@return ProfilerReport
function QuestieProfilerReport.BuildReport(source, options)
    source = source or {}
    options = options or {}

    local callCounts = source.hookCallCount or {}
    local timeCounts = source.hookTimeCount or {}
    local selfTimes = source.hookSelfTime or {}
    local lowerCaseLookup = source.lowerCaseLookup or {}
    local jobCallCounts = source.threadJobCallCount or {}
    local jobResumeCounts = source.threadJobResumeCount or {}

    local lowerFilter = options.filter and slower(options.filter) or ""
    local grouped = options.grouped == true
    local hideIdle = options.hideIdle == true
    -- A species is shown unless explicitly switched off, so an options table that omits them behaves as
    -- it always did.
    local scopePrefix = options.scopePrefix
    local showFunctions = options.showFunctions ~= false
    local showJobs = options.showJobs ~= false
    local showFiles = options.showFiles ~= false
    local speciesCounts = {functions = 0, jobs = 0, files = 0}

    local rows = {}
    local rowsByIdentity = {}
    local totalCount = 0
    local idleHiddenCount = 0
    -- Counted before any filter, the text filter included, so the control that hides idle entries can say
    -- how many there are even while they are being shown or a filter conceals them.
    local idleCount = 0

    for lookupKey, calls in pairs(callCounts) do
        totalCount = totalCount + 1
        if calls == 0 then
            idleCount = idleCount + 1
        end

        -- Grouped rows are matched through their original paths, so a filter on a folded-away prefix still
        -- resolves to the aggregate that contains it.
        local haystack = lowerCaseLookup[lookupKey] or slower(lookupKey)
        local matchesFilter = lowerFilter == "" or sfind(haystack, lowerFilter, 1, true) ~= nil

        if matchesFilter then
            -- Unlike idleCount this stays behind the text filter: it feeds "N idle hidden", which promises
            -- that lifting the toggle brings N rows back, and an idle entry the filter already excludes
            -- would not return.
            if hideIdle and calls == 0 then
                idleHiddenCount = idleHiddenCount + 1
            else
                local isThreadJob = jobCallCounts[lookupKey] ~= nil or IsThreadJobKey(lookupKey)
                local identity = grouped and GroupedIdentity(lookupKey) or lookupKey
                local existingRow = grouped and rowsByIdentity[identity] or nil

                if existingRow then
                    existingRow.totalTime = existingRow.totalTime + (timeCounts[lookupKey] or 0)
                    existingRow.selfTime = existingRow.selfTime + (selfTimes[lookupKey] or 0)
                    existingRow.calls = existingRow.calls + calls
                    if isThreadJob then
                        existingRow.jobCalls = (existingRow.jobCalls or 0) + (jobCallCounts[lookupKey] or 0)
                        existingRow.resumeCount = (existingRow.resumeCount or 0) + (jobResumeCounts[lookupKey] or 0)
                    end
                    tinsert(existingRow.mergedPaths, lookupKey)
                else
                    local row = {
                        lookupKey = identity,
                        displayName = DisplayNameFor(identity),
                        totalTime = timeCounts[lookupKey] or 0,
                        selfTime = selfTimes[lookupKey] or 0,
                        calls = calls,
                        averageTime = 0,
                        isThreadJob = isThreadJob,
                        isFileLoad = false,
                        isLibrary = IsLibraryKey(identity),
                        hasCalls = true,
                        hasTiming = false,
                        -- A job is a scheduling unit, not a frame on the call stack, so nothing ever
                        -- attributes child time to it. Reporting 0 would read as "spends nothing itself".
                        hasSelfTime = not isThreadJob,
                        jobCalls = isThreadJob and (jobCallCounts[lookupKey] or 0) or nil,
                        resumeCount = isThreadJob and (jobResumeCounts[lookupKey] or 0) or nil,
                        mergedPaths = grouped and {lookupKey} or nil,
                    }
                    tinsert(rows, row)
                    if grouped then
                        rowsByIdentity[identity] = row
                    end
                end
            end
        end
    end

    -- Addon-load rows are a separate species: one duration and one allocation per file, no calls beneath.
    -- The idle filter does not apply, because "never called" is not a meaningful state for a loaded file.
    --
    -- No self time, and the reason is worth recording so it does not read as an oversight. A file's interval
    -- covers everything that ran during it, profiled calls included, so a file row and a function row can in
    -- principle bill the same milliseconds twice. That overlap was built and measured rather than argued
    -- about: over a full startup it came to 3.9 ms out of roughly 1200, all of it on Questie.lua, because
    -- QuestieProfiler.lua sits near the end of the TOC and almost nothing is hooked while the other 240-odd
    -- files load. Producing the number needs a running counter in the profiler, a sample at every loader
    -- interval, and a getter the loader reaches back for - and the column it yields reads self == total on
    -- 243 of 244 rows. Revisit only if a file that does real work at file scope is ever added below the
    -- profiler in the TOC, which is the one thing that would make the overlap grow.
    local fileLoadTime = source.fileLoadTime or {}
    local fileLoadMemory = source.fileLoadMemory or {}
    for filePath, elapsed in pairs(fileLoadTime) do
        totalCount = totalCount + 1
        if lowerFilter == "" or sfind(slower(filePath), lowerFilter, 1, true) ~= nil then
            tinsert(rows, {
                lookupKey = filePath,
                displayName = filePath,
                totalTime = elapsed,
                selfTime = elapsed,
                calls = 0,
                averageTime = 0,
                isThreadJob = false,
                isFileLoad = true,
                isLibrary = false,
                hasCalls = false,
                hasTiming = elapsed > 0,
                hasSelfTime = false,
                memoryKilobytes = fileLoadMemory[filePath],
            })
        end
    end

    -- Counted from finished rows rather than source paths, so grouped view reports what is actually listed.
    local visibleRows = {}
    for i = 1, #rows do
        local row = rows[i]
        local species = row.isFileLoad and "files" or (row.isThreadJob and "jobs" or "functions")
        speciesCounts[species] = speciesCounts[species] + 1

        local speciesShown = (species == "files" and showFiles)
            or (species == "jobs" and showJobs)
            or (species == "functions" and showFunctions)

        -- A tree node scopes by prefix. Jobs sit under a synthetic node, so they match on that label
        -- rather than on their own identity, which has no path in it.
        local inScope = true
        if scopePrefix and scopePrefix ~= "" then
            local scopeTarget = row.isThreadJob and (THREAD_JOB_TREE_LABEL .. " " .. row.displayName)
                or row.lookupKey
            inScope = ssub(scopeTarget, 1, string.len(scopePrefix)) == scopePrefix
        end

        if speciesShown and inScope then
            tinsert(visibleRows, row)
        end
    end
    rows = visibleRows

    -- Maxima come from the visible rows, so the heat scale answers the question actually on screen rather
    -- than being flattened by a species the user just switched off.
    local maxTotalTime = 0
    local maxSelfTime = 0
    local maxCalls = 0
    local maxAverageTime = 0
    local maxMemoryKilobytes = 0
    for i = 1, #rows do
        local row = rows[i]
        -- A ThreadLib job's useful average is per submitted job; a function's is per call.
        if not row.isFileLoad then
            local averageDivisor = row.isThreadJob and row.jobCalls or row.calls
            if averageDivisor and averageDivisor > 0 then
                row.averageTime = row.totalTime / averageDivisor
            end
            row.hasTiming = row.totalTime > 0
        end
        if row.totalTime > maxTotalTime then
            maxTotalTime = row.totalTime
        end
        if row.hasSelfTime and row.selfTime > maxSelfTime then
            maxSelfTime = row.selfTime
        end
        if row.calls > maxCalls then
            maxCalls = row.calls
        end
        if row.averageTime > maxAverageTime then
            maxAverageTime = row.averageTime
        end
        if row.memoryKilobytes and row.memoryKilobytes > maxMemoryKilobytes then
            maxMemoryKilobytes = row.memoryKilobytes
        end
    end

    -- Share of the cost this row's own kind accounts for, against the denominators the status bar prints.
    -- Deliberately tooltip-only rather than a column: it was tried as one and pulled. In a column the number
    -- floats free of its basis, and only the file denominator is a real total - `fileLoadTime` covers every
    -- TOC entry, so 20.4% genuinely is a fifth of addon load. The function denominator is the summed self
    -- time of the functions that happen to be hooked and listed, and PROFILING_DISALLOWED_PATHS excludes
    -- whole subsystems on purpose, so a bare "8.2%" claims a share of Questie's CPU that it does not have.
    -- The tooltip has room to name the basis in words, which keeps that caveat attached to the number.
    --
    -- Functions are measured on self time, not total. Inclusive totals nest: a caller's total contains its
    -- callees', so summing them across the list runs well past the wall clock and every percentage would be
    -- fiction. Self times partition the measured work, so they are the only function figure that can carry a
    -- denominator. Files and jobs have no such nesting and use their totals.
    local shareDenominators = {file = 0, job = 0, ["function"] = 0}
    for i = 1, #rows do
        local row = rows[i]
        if row.isFileLoad then
            shareDenominators.file = shareDenominators.file + row.totalTime
        elseif row.isThreadJob then
            shareDenominators.job = shareDenominators.job + row.totalTime
        else
            shareDenominators["function"] = shareDenominators["function"] + row.selfTime
        end
    end
    for i = 1, #rows do
        local row = rows[i]
        local denominator, value
        if row.isFileLoad then
            denominator, value = shareDenominators.file, row.totalTime
        elseif row.isThreadJob then
            denominator, value = shareDenominators.job, row.totalTime
        else
            denominator, value = shareDenominators["function"], row.selfTime
        end
        row.shareDenominator = denominator
        -- Left nil rather than zeroed when there is nothing to divide by, so the column can print a dash
        -- instead of claiming the row accounts for none of a total that does not exist.
        row.share = denominator > 0 and (value / denominator) or nil
    end

    tsort(rows, BuildComparator(options.sortKey or SORT_TOTAL, options.descending ~= false))

    return {
        rows = rows,
        matchedCount = #rows,
        totalCount = totalCount,
        idleHiddenCount = idleHiddenCount,
        idleCount = idleCount,
        speciesCounts = speciesCounts,
        maxTotalTime = maxTotalTime,
        maxSelfTime = maxSelfTime,
        maxCalls = maxCalls,
        maxAverageTime = maxAverageTime,
        maxMemoryKilobytes = maxMemoryKilobytes,
    }
end

---@class ProfilerCallerEntry
---@field callerKey string
---@field calls number
---@field totalTime number

---Resolves who called a row, folding the callers of every full path a grouped row merged.
---Computed on demand rather than during BuildReport: only the row the user is inspecting needs it.
---@param source ProfilerReportSource
---@param reportRow ProfilerReportRow
---@param grouped boolean
---@return ProfilerCallerEntry[] callers @Most expensive first
function QuestieProfilerReport.BuildCallerList(source, reportRow, grouped)
    source = source or {}
    local callerCallCount = source.callerCallCount or {}
    local callerTimeCount = source.callerTimeCount or {}
    local paths = reportRow.mergedPaths or {reportRow.lookupKey}

    local entriesByCaller = {}
    local entries = {}
    for i = 1, #paths do
        local calleeKey = paths[i]
        local callers = callerCallCount[calleeKey]
        if callers then
            local callerTimes = callerTimeCount[calleeKey]
            for callerKey, calls in pairs(callers) do
                -- A grouped row must name grouped callers too, or a path grouping just folded away would
                -- reappear here under its full name.
                local identity = grouped and GroupedIdentity(callerKey) or callerKey
                local entry = entriesByCaller[identity]
                if not entry then
                    entry = {callerKey = identity, calls = 0, totalTime = 0}
                    entriesByCaller[identity] = entry
                    tinsert(entries, entry)
                end
                entry.calls = entry.calls + calls
                entry.totalTime = entry.totalTime + (callerTimes and callerTimes[callerKey] or 0)
            end
        end
    end

    tsort(entries, function(left, right)
        if left.totalTime == right.totalTime then
            return left.callerKey < right.callerKey
        end
        return left.totalTime > right.totalTime
    end)
    return entries
end

---@class ProfilerCalleeEntry
---@field calleeKey string
---@field calls number
---@field totalTime number

---Resolves what a row called, by reading the same edge map from the other side.
---The engine only stores callee -> caller, so this scans every callee and keeps the ones naming this row as
---a caller. That is a pass over the edge table rather than a lookup, which is why it runs on selection only.
---@param source ProfilerReportSource
---@param reportRow ProfilerReportRow
---@param grouped boolean
---@return ProfilerCalleeEntry[] callees @Most expensive first
function QuestieProfilerReport.BuildCalleeList(source, reportRow, grouped)
    source = source or {}
    local callerCallCount = source.callerCallCount or {}
    local callerTimeCount = source.callerTimeCount or {}

    -- Edges name callers by their full path, so a grouped row has to match every path it folded.
    local isThisRow = {}
    local paths = reportRow.mergedPaths or {reportRow.lookupKey}
    for i = 1, #paths do
        isThisRow[paths[i]] = true
    end

    local entriesByCallee = {}
    local entries = {}
    for calleeKey, callers in pairs(callerCallCount) do
        local calleeTimes = callerTimeCount[calleeKey]
        for callerKey, calls in pairs(callers) do
            if isThisRow[callerKey] then
                local identity = grouped and GroupedIdentity(calleeKey) or calleeKey
                local entry = entriesByCallee[identity]
                if not entry then
                    entry = {calleeKey = identity, calls = 0, totalTime = 0}
                    entriesByCallee[identity] = entry
                    tinsert(entries, entry)
                end
                entry.calls = entry.calls + calls
                entry.totalTime = entry.totalTime + (calleeTimes and calleeTimes[callerKey] or 0)
            end
        end
    end

    tsort(entries, function(left, right)
        if left.totalTime == right.totalTime then
            return left.calleeKey < right.calleeKey
        end
        return left.totalTime > right.totalTime
    end)
    return entries
end

---@class ProfilerSessionTotals
---@field fileCount number
---@field fileTime number
---@field fileMemory number
---@field functionCount number
---@field functionCalls number
---@field functionSelfTime number
---@field jobCount number
---@field jobTime number

---Totals for the whole session, deliberately ignoring every filter: these are the denominators a single row
---is read against, so moving them with the view would make them circular.
---
---Functions are summed by self time, never inclusive. Inclusive time counts a caller and everything beneath
---it, so adding it across functions charges the same milliseconds once per level of nesting - measured at
---2517.9 ms inclusive against 1109.9 ms self in a live session, an inflation of well over double.
---
---The three species are reported side by side and never added together. A job's active slices contain the
---functions it ran, so job time and function self time overlap; only file load is a genuinely separate phase.
---@param source ProfilerReportSource
---@return ProfilerSessionTotals
function QuestieProfilerReport.BuildSessionTotals(source)
    source = source or {}
    local callCounts = source.hookCallCount or {}
    local timeCounts = source.hookTimeCount or {}
    local selfTimes = source.hookSelfTime or {}
    local jobCallCounts = source.threadJobCallCount or {}
    local fileLoadTime = source.fileLoadTime or {}
    local fileLoadMemory = source.fileLoadMemory or {}

    local totals = {
        fileCount = 0,
        fileTime = 0,
        fileMemory = 0,
        functionCount = 0,
        functionCalls = 0,
        functionSelfTime = 0,
        jobCount = 0,
        jobTime = 0,
    }

    for lookupKey, calls in pairs(callCounts) do
        if jobCallCounts[lookupKey] ~= nil or IsThreadJobKey(lookupKey) then
            totals.jobCount = totals.jobCount + 1
            totals.jobTime = totals.jobTime + (timeCounts[lookupKey] or 0)
        else
            totals.functionCount = totals.functionCount + 1
            totals.functionCalls = totals.functionCalls + calls
            totals.functionSelfTime = totals.functionSelfTime + (selfTimes[lookupKey] or 0)
        end
    end

    for filePath, elapsed in pairs(fileLoadTime) do
        totals.fileCount = totals.fileCount + 1
        totals.fileTime = totals.fileTime + elapsed
        totals.fileMemory = totals.fileMemory + (fileLoadMemory[filePath] or 0)
    end

    return totals
end

---@param value number @Milliseconds
---@return string
local function FormatMilliseconds(value)
    if value >= 10000 then
        return sformat("%.0f", value)
    elseif value >= 100 then
        return sformat("%.1f", value)
    end
    return sformat("%.2f", value)
end

---Renders one duration whose scale is not known in advance, carrying its own unit.
---
---A per-call cost spans five orders of magnitude in this addon: compiling the database is seconds, and a
---coordinate conversion is under a microsecond. Milliseconds to two places - which is right for the totals
---beside it, where anything under 0.01 ms genuinely is nothing - cannot show the small end at all. Measured on
---a normal session it rendered 18 of 50 called rows as "0.00", and gave the same "0.01" to a 6.8us call and an
---8.1us one, which is the comparison the column exists to make.
---
---So the unit travels with the value, and the precision follows the magnitude rather than the unit: three
---significant figures at every scale. Sorting is unaffected, being done on the number rather than this string.
---Spelled "us" rather than the Greek letter, which is what every measurement in this addon's comments uses and
---avoids depending on the client font having the glyph.
---Defined on the private table rather than as a file local: this chunk already sits at Lua 5.1's ceiling of
---200 locals per function, and one more is a load-time error rather than a warning.
---@param value number @Milliseconds
---@return string
function QuestieProfilerReport.FormatDuration(value)
    if value >= 1 then
        return FormatMilliseconds(value) .. " ms"
    end

    local microseconds = value * 1000
    if microseconds >= 100 then
        return sformat("%.0f us", microseconds)
    elseif microseconds >= 10 then
        return sformat("%.1f us", microseconds)
    elseif microseconds > 0 then
        return sformat("%.2f us", microseconds)
    end
    return "0"
end

---@class ProfilerTreeNode
---@field label string @The segment this node adds
---@field prefix string @Full identity prefix, including the trailing separator
---@field cost number @Rolled up from every row beneath it: function self time, file and job totals
---@field rowCount number
---@field children ProfilerTreeNode[]

---@param row ProfilerReportRow
---@return string separator
---@return string[] segments @Containers first, leaf last
local function TreeSegments(row)
    if row.isThreadJob then
        return " ", {THREAD_JOB_TREE_LABEL, row.displayName}
    end

    local separator = row.isFileLoad and "/" or "."
    local segments = {}
    for segment in string.gmatch(row.lookupKey, "[^" .. separator .. "]+") do
        tinsert(segments, segment)
    end
    return separator, segments
end

---@param node ProfilerTreeNode
local function SortTreeNode(node)
    tsort(node.children, function(left, right)
        if left.cost == right.cost then
            return left.label < right.label
        end
        return left.cost > right.cost
    end)
    for _, child in ipairs(node.children) do
        SortTreeNode(child)
    end
end

---Builds the container hierarchy for a set of rows, rolling each row's cost into every ancestor.
---
---Functions contribute self time, never inclusive: a caller's total already contains its callees', so
---summing totals across a module charges the same milliseconds once per level of nesting - the rule
---BuildSessionTotals states with a measurement. Files and jobs do not nest and contribute their totals.
---@param rows ProfilerReportRow[]
---@return ProfilerTreeNode root
function QuestieProfilerReport.BuildTree(rows)
    local root = {label = "", prefix = "", cost = 0, rowCount = 0, children = {}, childrenByPrefix = {}}

    for _, row in ipairs(rows) do
        local separator, segments = TreeSegments(row)
        local rowCost = (row.isFileLoad or row.isThreadJob) and row.totalTime or row.selfTime
        root.cost = root.cost + rowCost
        root.rowCount = root.rowCount + 1

        -- The leaf is the row itself and never becomes a node; only its containers do.
        local node = root
        local prefix = ""
        for i = 1, #segments - 1 do
            prefix = prefix .. segments[i] .. separator
            local child = node.childrenByPrefix[prefix]
            if not child then
                child = {
                    label = segments[i],
                    prefix = prefix,
                    cost = 0,
                    rowCount = 0,
                    children = {},
                    childrenByPrefix = {},
                }
                node.childrenByPrefix[prefix] = child
                tinsert(node.children, child)
            end
            child.cost = child.cost + rowCost
            child.rowCount = child.rowCount + 1
            node = child
        end
    end

    SortTreeNode(root)
    return root
end

---Flattens the tree into the lines a list can render, honouring which nodes are open.
---@param root ProfilerTreeNode
---@param expandedPrefixes table<string, boolean>
---@return table[] lines @Each {node = node, depth = n, hasChildren = boolean}
function QuestieProfilerReport.FlattenTree(root, expandedPrefixes)
    local lines = {}

    local function Visit(node, depth)
        for _, child in ipairs(node.children) do
            tinsert(lines, {node = child, depth = depth, hasChildren = #child.children > 0})
            if expandedPrefixes[child.prefix] then
                Visit(child, depth + 1)
            end
        end
    end

    Visit(root, 0)
    return lines
end

---@param value number @Kilobytes; negative when the collector freed memory during the interval
---@return string
local function FormatKilobytes(value)
    local magnitude = value < 0 and -value or value
    if magnitude >= 1024 then
        return sformat("%.1f MB", value / 1024)
    end
    return sformat("%.0f KB", value)
end

---@param value number
---@return string
local function FormatCount(value)
    if value >= 1000000 then
        return sformat("%.1fm", value / 1000000)
    elseif value >= 10000 then
        return sformat("%.1fk", value / 1000)
    end
    return tostring(value)
end
---One decimal, because the rows worth noticing sit between 1% and 20% and whole numbers collapse the tail
---into a wall of identical zeroes. Below a tenth of a percent it says so rather than rounding to 0.0%, which
---would read as "free" for a row that did measurable work.
---@param share number @0-1
---@return string
local function FormatShare(share)
    if share > 0 and share < 0.001 then
        return "<0.1%"
    end
    return sformat("%.1f%%", share * 100)
end

QuestieProfilerReport.FormatCount = FormatCount
QuestieProfilerReport.FormatShare = FormatShare
QuestieProfilerReport.FormatKilobytes = FormatKilobytes
QuestieProfilerReport.FormatMilliseconds = FormatMilliseconds

-- One scale for every visible row, deliberately, even though a single expensive file does compress the
-- function bars below it. Scaling each species against its own maximum was tried and reverted: sorted
-- descending, a shared scale makes bar length agree with row order - the staircase - and per-species bars
-- contradict it, drawing a 76 ms file longer than the 62 ms function above it. A bar that disagrees with the
-- sort reads as a bug. The species checkboxes are the answer to the flattening: switch Files off and the
-- maxima, which come from the visible rows, rescale to what is left.
---@param row ProfilerReportRow
---@param report ProfilerReport
---@param sortKey string
---@return number share @0-1 share of the largest visible value for the active sort metric
local function HeatShare(row, report, sortKey)
    local value, maximum
    if sortKey == SORT_CALLS then
        value, maximum = row.calls, report.maxCalls
    elseif sortKey == SORT_AVERAGE then
        value, maximum = row.averageTime, report.maxAverageTime
    elseif sortKey == SORT_SELF then
        value, maximum = row.hasSelfTime and row.selfTime or 0, report.maxSelfTime
    elseif sortKey == SORT_MEMORY then
        -- Clamped at zero: an interval in which the collector freed more than it allocated carries no heat.
        value = row.memoryKilobytes or 0
        if value < 0 then
            value = 0
        end
        maximum = report.maxMemoryKilobytes
    else
        -- Sorting by name still benefits from a cost scale, so fall back to total time.
        value, maximum = row.totalTime, report.maxTotalTime
    end
    if not maximum or maximum <= 0 then
        return 0
    end
    return value / maximum
end
QuestieProfilerReport.HeatShare = HeatShare

-- Exported below rather than declared as module functions, so the calls between them stay local lookups.
QuestieProfilerReport.GroupedIdentity = GroupedIdentity
QuestieProfilerReport.DisplayNameFor = DisplayNameFor
QuestieProfilerReport.IsThreadJobKey = IsThreadJobKey
