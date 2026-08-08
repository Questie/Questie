---@class QuestieProfilerUI
local QuestieProfilerUI = QuestieLoader:CreateModule("ProfilerUI")
local _QuestieProfilerUI = QuestieProfilerUI.private

-------------------------
--Import modules.
-------------------------
-- The profiler engine is the only Questie module this file may touch. Every other module is wrapped by the
-- profiler, so calling into one from here would measure the diagnostic tool instead of the addon.
-- For the same reason this file has no localization: l10n is a profiled module.
---@type QuestieProfiler
local QuestieProfiler = QuestieLoader:ImportModule("Profiler")

-- Performance: alias frequently used functions
local tinsert = table.insert
local tsort = table.sort
local sfind = string.find
local sformat = string.format
local slower = string.lower
local smatch = string.match
local ssub = string.sub
local mfloor = math.floor
local mmax = math.max
local mmin = math.min

-------------------------
-- Layout and presentation constants
-------------------------
local WINDOW_DEFAULT_WIDTH = 680
local WINDOW_DEFAULT_HEIGHT = 440
local WINDOW_MIN_WIDTH = 480
local WINDOW_MIN_HEIGHT = 260
local WINDOW_MAX_WIDTH = 1600
local WINDOW_MAX_HEIGHT = 1200

local ROW_HEIGHT = 14
local TITLE_BAR_HEIGHT = 22
local CONTROL_ROW_HEIGHT = 26
local FILTER_ROW_HEIGHT = 26
local COLUMN_HEADER_HEIGHT = 16
local DETAIL_STRIP_HEIGHT = 16
local STATUS_BAR_HEIGHT = 16
local SCROLL_TRACK_WIDTH = 8
local EDGE_PADDING = 8
local ACCENT_STRIPE_WIDTH = 2

local COLUMN_TOTAL_WIDTH = 70
local COLUMN_SELF_WIDTH = 70
local COLUMN_CALLS_WIDTH = 58
local COLUMN_AVERAGE_WIDTH = 62
local COLUMN_GAP = 6

local REFRESH_INTERVAL = 0.5
local WHEEL_SCROLL_ROWS = 3
local INDICATOR_POLL_INTERVAL = 0.5
local INDICATOR_LABEL = "Questie profiler running"
local INDICATOR_COLOR = {r = 1.00, g = 0.72, b = 0.20}

local SORT_NAME = "name"
local SORT_TOTAL = "total"
local SORT_SELF = "self"
local SORT_CALLS = "calls"
local SORT_AVERAGE = "average"

local MAX_CALLERS_IN_TOOLTIP = 8

local THREAD_JOB_PREFIX = "ThreadLib job: "
local THREAD_JOB_PREFIX_LENGTH = string.len(THREAD_JOB_PREFIX)
-- Segments that carry no identity of their own. Only `private` qualifies: it is an indirection table every
-- module reaches its own internals through. Numeric segments were dropped here once, on the theory that an
-- index like packets.1.read is noise - but the same rule folded QuestieInit.Stages.1/2/3 into one row, where
-- the index *is* the identity. Measured on a live session, dropping numbers merged three groups and lost
-- that distinction; keeping them merges nothing at all. The packet rows it was meant to tidy are never
-- called, so the idle filter already hides them.
local GROUPING_NOISE_SEGMENTS = {private = true}
local MAX_MERGED_PATHS_IN_TOOLTIP = 10

-- Rows are shaded by their share of the largest value in the *currently visible* set, so the scale stays
-- meaningful after filtering instead of collapsing against one global outlier.
-- Alpha falls off with the band so the long tail stays legible without competing with the real outliers.
local HEAT_BANDS = {
    {share = 0.5, r = 0.85, g = 0.18, b = 0.18, a = 0.38},
    {share = 0.2, r = 0.90, g = 0.50, b = 0.15, a = 0.28},
    {share = 0.05, r = 0.85, g = 0.78, b = 0.25, a = 0.18},
    {share = 0, r = 0.30, g = 0.42, b = 0.58, a = 0.12},
}

local COLOR_TEXT = {r = 0.88, g = 0.88, b = 0.88}
local COLOR_THREAD_JOB = {r = 0.45, g = 0.80, b = 1.00}
local COLOR_UNTIMED = {r = 0.55, g = 0.55, b = 0.55}
local COLOR_SORTED_VALUE = {r = 1.00, g = 0.82, b = 0.00}
local COLOR_SELF_DOMINANT = {r = 0.95, g = 0.60, b = 0.45}

-- Self time at or above this share of a row's total means the row itself is the cost, not its children.
local SELF_DOMINANT_SHARE = 0.5

-------------------------
-- Report building (pure, frame free)
-------------------------
-- Everything below this banner is a pure transformation of profiler tables into display rows. It never reads
-- or writes a frame, which is what lets the behaviour be tested without a UI and guarantees that sorting,
-- filtering and grouping cannot touch a measurement.

---@class ProfilerReportRow
---@field lookupKey string @Identity used for display and tie-breaking
---@field displayName string @Identity with the ThreadLib prefix removed
---@field totalTime number @Inclusive: this call and everything profiled beneath it
---@field selfTime number @Inclusive minus the measured time of profiled children
---@field hasSelfTime boolean @False for ThreadLib jobs, which are not call frames and have no self time
---@field memoryKilobytes number? @Allocation attributed to this row; only addon-load rows carry one
---@field calls number
---@field averageTime number
---@field isThreadJob boolean
---@field isFileLoad boolean @True for an addon file load, which is not a call and has no caller or average
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
---@field sortKey string?
---@field descending boolean?

---@class ProfilerReport
---@field rows ProfilerReportRow[]
---@field matchedCount number @Rows the user can actually see
---@field totalCount number @Entries the profiler holds
---@field idleHiddenCount number @Entries withheld by the idle filter alone
---@field maxTotalTime number
---@field maxSelfTime number
---@field maxCalls number
---@field maxAverageTime number

---@param lookupKey string
---@return boolean
local function IsThreadJobKey(lookupKey)
    return ssub(lookupKey, 1, THREAD_JOB_PREFIX_LENGTH) == THREAD_JOB_PREFIX
end


---Shortens a full profiler path by dropping only the segments that do not identify the function.
---Every other segment is kept, so two different functions can never collapse into one row: an earlier rule
---folded everything between the first and last segment, which merged eight distinct tab initialisers into a
---single QuestieOptions.Initialize and hid which one was slow. Grouped view therefore shortens identities
---rather than aggregating them; entries still combine when two paths genuinely shorten to the same name.
---ThreadLib jobs keep their whole identity because their call sites are what distinguishes scheduling units.
---Addon-load rows never reach here: files are not module paths and live in their own table.
---@param lookupKey string
---@return string groupedIdentity
local function GroupedIdentity(lookupKey)
    if IsThreadJobKey(lookupKey) then
        return lookupKey
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
function _QuestieProfilerUI.BuildReport(source, options)
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

    local rows = {}
    local rowsByIdentity = {}
    local totalCount = 0
    local idleHiddenCount = 0

    for lookupKey, calls in pairs(callCounts) do
        totalCount = totalCount + 1

        -- Grouped rows are matched through their original paths, so a filter on a folded-away prefix still
        -- resolves to the aggregate that contains it.
        local haystack = lowerCaseLookup[lookupKey] or slower(lookupKey)
        local matchesFilter = lowerFilter == "" or sfind(haystack, lowerFilter, 1, true) ~= nil

        if matchesFilter then
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
                hasCalls = false,
                hasTiming = elapsed > 0,
                hasSelfTime = true,
                memoryKilobytes = fileLoadMemory[filePath],
            })
        end
    end

    local maxTotalTime = 0
    local maxSelfTime = 0
    local maxCalls = 0
    local maxAverageTime = 0
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
    end

    tsort(rows, BuildComparator(options.sortKey or SORT_TOTAL, options.descending ~= false))

    return {
        rows = rows,
        matchedCount = #rows,
        totalCount = totalCount,
        idleHiddenCount = idleHiddenCount,
        maxTotalTime = maxTotalTime,
        maxSelfTime = maxSelfTime,
        maxCalls = maxCalls,
        maxAverageTime = maxAverageTime,
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
function _QuestieProfilerUI.BuildCallerList(source, reportRow, grouped)
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
_QuestieProfilerUI.FormatCount = FormatCount
_QuestieProfilerUI.FormatKilobytes = FormatKilobytes
_QuestieProfilerUI.FormatMilliseconds = FormatMilliseconds

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
    else
        -- Sorting by name still benefits from a cost scale, so fall back to total time.
        value, maximum = row.totalTime, report.maxTotalTime
    end
    if not maximum or maximum <= 0 then
        return 0
    end
    return value / maximum
end
_QuestieProfilerUI.HeatShare = HeatShare

---@param share number
---@return table band
local function HeatBand(share)
    for i = 1, #HEAT_BANDS do
        if share >= HEAT_BANDS[i].share then
            return HEAT_BANDS[i]
        end
    end
    return HEAT_BANDS[#HEAT_BANDS]
end

-------------------------
-- Display state
-------------------------
-- Frames are deliberately kept in file locals. Nothing here may be reachable from another Questie module
-- table, or the profiler's traversal would find it.
local baseFrame
local listFrame
local scrollTrack
local scrollThumb
local rowPool = {}
local columnHeaders = {}
local sessionButton, resetButton, freezeButton, refreshButton, viewButton, idleButton
local searchBox, searchClearButton
local sessionChip, displayChip, statusText, detailText
local eventFrame
local indicatorButton

local refreshTicker
local currentReport
local userVisible = false
local hasEnteredWorld = false

local displayState = {
    filter = "",
    grouped = false,
    hideIdle = true,
    sortKey = SORT_TOTAL,
    descending = true,
    frozen = false,
    selectedKey = nil,
    scrollOffset = 0,
}

local Layout, RenderRows, UpdateControls, UpdateColumnHeaders, UpdateTickerState

-------------------------
-- Client capability fallbacks
-------------------------
---@param frame table
---@param minWidth number
---@param minHeight number
---@param maxWidth number
---@param maxHeight number
local function ApplyResizeBounds(frame, minWidth, minHeight, maxWidth, maxHeight)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
        return
    end
    if frame.SetMinResize then
        frame:SetMinResize(minWidth, minHeight)
    end
    if frame.SetMaxResize then
        frame:SetMaxResize(maxWidth, maxHeight)
    end
end

---@param fontString table
local function DisableWrapping(fontString)
    if fontString.SetWordWrap then
        fontString:SetWordWrap(false)
    end
    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end
end

-------------------------
-- Row rendering
-------------------------
---@param row table @Pooled row button
---@param reportRow ProfilerReportRow
local function ShowRowTooltip(row, reportRow)
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(reportRow.lookupKey, 1, 0.82, 0, true)
    GameTooltip:AddDoubleLine("Total (inclusive)", sformat("%.3f ms", reportRow.totalTime), 0.7, 0.7, 0.7, 1, 1, 1)
    if reportRow.hasSelfTime then
        GameTooltip:AddDoubleLine("Self (excluding children)", sformat("%.3f ms", reportRow.selfTime), 0.7, 0.7, 0.7, 1, 1, 1)
    end
    if reportRow.hasCalls then
        GameTooltip:AddDoubleLine("Calls", tostring(reportRow.calls), 0.7, 0.7, 0.7, 1, 1, 1)
    end
    if reportRow.memoryKilobytes then
        GameTooltip:AddDoubleLine("Allocated", FormatKilobytes(reportRow.memoryKilobytes), 0.7, 0.7, 0.7, 1, 1, 1)
        if reportRow.memoryKilobytes < 0 then
            GameTooltip:AddLine("Negative means the garbage collector ran while this file loaded, so the time "
                .. "here is a collection pause rather than work the file did.", 0.55, 0.55, 0.55, true)
        end
    end

    if reportRow.isThreadJob then
        GameTooltip:AddDoubleLine("Submitted jobs", tostring(reportRow.jobCalls or 0), 0.7, 0.7, 0.7, 1, 1, 1)
        GameTooltip:AddDoubleLine("Coroutine resumes", tostring(reportRow.resumeCount or 0), 0.7, 0.7, 0.7, 1, 1, 1)
        GameTooltip:AddDoubleLine("Average per job", sformat("%.3f ms", reportRow.averageTime), 0.7, 0.7, 0.7, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Job time covers active resume slices only. Time spent suspended between resumes is excluded.",
            0.45, 0.8, 1, true)
        GameTooltip:AddLine("This row is the authoritative total for work spanning multiple resumes.", 0.45, 0.8, 1, true)
    else
        GameTooltip:AddDoubleLine("Average per call", sformat("%.3f ms", reportRow.averageTime), 0.7, 0.7, 0.7, 1, 1, 1)
    end

    if reportRow.calls > 0 and not reportRow.hasTiming then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Counted but never timed: these calls spanned a coroutine yield, so no elapsed time "
            .. "could be attributed. Use the matching ThreadLib job row for the real cost.", 0.55, 0.55, 0.55, true)
    end

    local mergedPaths = reportRow.mergedPaths
    if mergedPaths and #mergedPaths > 1 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(sformat("Merged %d paths:", #mergedPaths), 0.7, 0.7, 0.7)
        for i = 1, mmin(#mergedPaths, MAX_MERGED_PATHS_IN_TOOLTIP) do
            GameTooltip:AddLine("  " .. mergedPaths[i], 0.6, 0.6, 0.6, true)
        end
        if #mergedPaths > MAX_MERGED_PATHS_IN_TOOLTIP then
            GameTooltip:AddLine(sformat("  ... and %d more", #mergedPaths - MAX_MERGED_PATHS_IN_TOOLTIP), 0.6, 0.6, 0.6)
        end
    end

    local callers = _QuestieProfilerUI.BuildCallerList(QuestieProfiler, reportRow, displayState.grouped)
    if #callers > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Called by:", 0.7, 0.7, 0.7)
        for i = 1, mmin(#callers, MAX_CALLERS_IN_TOOLTIP) do
            local caller = callers[i]
            GameTooltip:AddDoubleLine("  " .. caller.callerKey,
                sformat("%d x  %.1f ms", caller.calls, caller.totalTime), 0.6, 0.6, 0.6, 0.85, 0.85, 0.85)
        end
        if #callers > MAX_CALLERS_IN_TOOLTIP then
            GameTooltip:AddLine(sformat("  ... and %d more", #callers - MAX_CALLERS_IN_TOOLTIP), 0.6, 0.6, 0.6)
        end
    end

    GameTooltip:Show()
end

---@param reportRow ProfilerReportRow
---@return string
local function DetailLineFor(reportRow)
    local selfDetail = reportRow.hasSelfTime and sformat("%.3f ms self", reportRow.selfTime) or "no self time"
    local detail = sformat("%s  |  %.3f ms total  |  %s  |  %d calls  |  %.3f ms avg",
        reportRow.lookupKey, reportRow.totalTime, selfDetail, reportRow.calls, reportRow.averageTime)
    if reportRow.isThreadJob then
        detail = detail .. sformat("  |  %d jobs  |  %d resumes", reportRow.jobCalls or 0, reportRow.resumeCount or 0)
    end
    if reportRow.calls > 0 and not reportRow.hasTiming then
        detail = detail .. "  |  no timed slices"
    end
    return detail
end

---@param index number
---@return table row
local function AcquireRow(index)
    local row = rowPool[index]
    if row then
        return row
    end

    row = CreateFrame("Button", nil, listFrame)
    row:SetHeight(ROW_HEIGHT)

    row.heat = row:CreateTexture(nil, "BACKGROUND")
    row.heat:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.heat:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.heat:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)

    row.stripe = row:CreateTexture(nil, "ARTWORK")
    row.stripe:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.stripe:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.stripe:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    row.stripe:SetWidth(ACCENT_STRIPE_WIDTH)

    row.selection = row:CreateTexture(nil, "BORDER")
    row.selection:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.selection:SetAllPoints(row)
    if row.selection.SetColorTexture then
        row.selection:SetColorTexture(1, 1, 1, 0.12)
    else
        row.selection:SetVertexColor(1, 1, 1, 0.12)
    end
    row.selection:Hide()

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.nameText:SetPoint("LEFT", row, "LEFT", ACCENT_STRIPE_WIDTH + 4, 0)
    row.nameText:SetJustifyH("LEFT")
    DisableWrapping(row.nameText)

    row.total = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.total:SetJustifyH("RIGHT")
    row.total:SetWidth(COLUMN_TOTAL_WIDTH)

    row.selfTime = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.selfTime:SetJustifyH("RIGHT")
    row.selfTime:SetWidth(COLUMN_SELF_WIDTH)

    row.calls = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.calls:SetJustifyH("RIGHT")
    row.calls:SetWidth(COLUMN_CALLS_WIDTH)

    row.average = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.average:SetJustifyH("RIGHT")
    row.average:SetWidth(COLUMN_AVERAGE_WIDTH)

    row:SetScript("OnEnter", function(self)
        if self.reportRow then
            ShowRowTooltip(self, self.reportRow)
        end
    end)
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        if not self.reportRow then
            return
        end
        if displayState.selectedKey == self.reportRow.lookupKey then
            displayState.selectedKey = nil
        else
            displayState.selectedKey = self.reportRow.lookupKey
        end
        RenderRows()
    end)

    rowPool[index] = row
    return row
end

---@return number visibleRowCount
local function VisibleRowCount()
    if not listFrame then
        return 0
    end
    local height = listFrame:GetHeight() or 0
    return mmax(0, mfloor(height / ROW_HEIGHT))
end

---Positions the numeric columns for the current window width.
---@param row table
---@param listWidth number
local function LayoutRowColumns(row, listWidth)
    row:SetWidth(listWidth)
    row.heat:SetWidth(1)

    local averageRight = -COLUMN_GAP
    row.average:ClearAllPoints()
    row.average:SetPoint("RIGHT", row, "RIGHT", averageRight, 0)

    row.calls:ClearAllPoints()
    row.calls:SetPoint("RIGHT", row.average, "LEFT", -COLUMN_GAP, 0)

    row.selfTime:ClearAllPoints()
    row.selfTime:SetPoint("RIGHT", row.calls, "LEFT", -COLUMN_GAP, 0)

    row.total:ClearAllPoints()
    row.total:SetPoint("RIGHT", row.selfTime, "LEFT", -COLUMN_GAP, 0)

    local numericWidth = COLUMN_TOTAL_WIDTH + COLUMN_SELF_WIDTH + COLUMN_CALLS_WIDTH
        + COLUMN_AVERAGE_WIDTH + COLUMN_GAP * 5
    row.nameText:SetWidth(mmax(40, listWidth - numericWidth - ACCENT_STRIPE_WIDTH - 4))
end

function RenderRows()
    if not listFrame or not currentReport then
        return
    end

    local rows = currentReport.rows
    local visibleRowCount = VisibleRowCount()
    local maxOffset = mmax(0, #rows - visibleRowCount)
    if displayState.scrollOffset > maxOffset then
        displayState.scrollOffset = maxOffset
    end

    local listWidth = (listFrame:GetWidth() or 0) - SCROLL_TRACK_WIDTH - 2
    local selectedRow

    for index = 1, visibleRowCount do
        local row = AcquireRow(index)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT)
        LayoutRowColumns(row, listWidth)

        local reportRow = rows[index + displayState.scrollOffset]
        row.reportRow = reportRow
        if not reportRow then
            row:Hide()
        else
            row:Show()

            local share = HeatShare(reportRow, currentReport, displayState.sortKey)
            local band = HeatBand(share)
            row.heat:SetWidth(mmax(1, share * listWidth))
            if row.heat.SetColorTexture then
                row.heat:SetColorTexture(band.r, band.g, band.b, band.a)
            else
                row.heat:SetVertexColor(band.r, band.g, band.b, band.a)
            end

            if reportRow.isThreadJob then
                if row.stripe.SetColorTexture then
                    row.stripe:SetColorTexture(COLOR_THREAD_JOB.r, COLOR_THREAD_JOB.g, COLOR_THREAD_JOB.b, 0.9)
                else
                    row.stripe:SetVertexColor(COLOR_THREAD_JOB.r, COLOR_THREAD_JOB.g, COLOR_THREAD_JOB.b, 0.9)
                end
                row.stripe:Show()
            else
                row.stripe:Hide()
            end

            local nameColor = reportRow.isThreadJob and COLOR_THREAD_JOB or COLOR_TEXT
            row.nameText:SetText(reportRow.displayName)
            row.nameText:SetTextColor(nameColor.r, nameColor.g, nameColor.b)

            -- Counted-but-never-timed entries must not read as free work, so they show a dash instead of 0.00.
            if reportRow.hasTiming then
                row.total:SetText(FormatMilliseconds(reportRow.totalTime))
                row.average:SetText(FormatMilliseconds(reportRow.averageTime))
                row.total:SetTextColor(COLOR_TEXT.r, COLOR_TEXT.g, COLOR_TEXT.b)
                row.average:SetTextColor(COLOR_TEXT.r, COLOR_TEXT.g, COLOR_TEXT.b)
                if not reportRow.hasSelfTime then
                    row.selfTime:SetText("-")
                    row.selfTime:SetTextColor(COLOR_UNTIMED.r, COLOR_UNTIMED.g, COLOR_UNTIMED.b)
                else
                    row.selfTime:SetText(FormatMilliseconds(reportRow.selfTime))
                    -- Self time is the number that says "the cost is here, not in something I called".
                    if reportRow.selfTime >= reportRow.totalTime * SELF_DOMINANT_SHARE then
                        row.selfTime:SetTextColor(COLOR_SELF_DOMINANT.r, COLOR_SELF_DOMINANT.g, COLOR_SELF_DOMINANT.b)
                    else
                        row.selfTime:SetTextColor(COLOR_UNTIMED.r, COLOR_UNTIMED.g, COLOR_UNTIMED.b)
                    end
                end
            else
                row.total:SetText("-")
                row.selfTime:SetText("-")
                row.average:SetText("-")
                row.total:SetTextColor(COLOR_UNTIMED.r, COLOR_UNTIMED.g, COLOR_UNTIMED.b)
                row.selfTime:SetTextColor(COLOR_UNTIMED.r, COLOR_UNTIMED.g, COLOR_UNTIMED.b)
                row.average:SetTextColor(COLOR_UNTIMED.r, COLOR_UNTIMED.g, COLOR_UNTIMED.b)
            end
            if reportRow.hasCalls then
                row.calls:SetText(FormatCount(reportRow.calls))
                row.calls:SetTextColor(COLOR_TEXT.r, COLOR_TEXT.g, COLOR_TEXT.b)
            else
                row.calls:SetText("-")
                row.calls:SetTextColor(COLOR_UNTIMED.r, COLOR_UNTIMED.g, COLOR_UNTIMED.b)
            end

            -- Highlight the column the list is ordered by so the active question stays obvious.
            local sortedColumn = (displayState.sortKey == SORT_CALLS and row.calls)
                or (displayState.sortKey == SORT_AVERAGE and row.average)
                or (displayState.sortKey == SORT_SELF and row.selfTime)
                or (displayState.sortKey == SORT_TOTAL and row.total)
                or nil
            if sortedColumn then
                sortedColumn:SetTextColor(COLOR_SORTED_VALUE.r, COLOR_SORTED_VALUE.g, COLOR_SORTED_VALUE.b)
            end

            if displayState.selectedKey == reportRow.lookupKey then
                row.selection:Show()
                selectedRow = reportRow
            else
                row.selection:Hide()
            end
        end
    end

    for index = visibleRowCount + 1, #rowPool do
        rowPool[index]:Hide()
        rowPool[index].reportRow = nil
    end

    -- A selection scrolled out of view keeps its detail line; the pinned entry is what the user is reading.
    if not selectedRow and displayState.selectedKey then
        for i = 1, #rows do
            if rows[i].lookupKey == displayState.selectedKey then
                selectedRow = rows[i]
                break
            end
        end
    end
    if detailText then
        detailText:SetText(selectedRow and DetailLineFor(selectedRow) or "Click a row to pin its full identity here.")
    end

    -- Scroll indicator
    if scrollTrack and scrollThumb then
        local trackHeight = scrollTrack:GetHeight() or 0
        if #rows <= visibleRowCount or trackHeight <= 0 then
            scrollThumb:Hide()
        else
            scrollThumb:Show()
            local thumbHeight = mmax(16, trackHeight * (visibleRowCount / #rows))
            local travel = trackHeight - thumbHeight
            local progress = maxOffset > 0 and (displayState.scrollOffset / maxOffset) or 0
            scrollThumb:SetHeight(thumbHeight)
            scrollThumb:ClearAllPoints()
            scrollThumb:SetPoint("TOP", scrollTrack, "TOP", 0, -progress * travel)
        end
    end
end

---@param offset number
local function SetScrollOffset(offset)
    local visibleRowCount = VisibleRowCount()
    local rowCount = currentReport and #currentReport.rows or 0
    local maxOffset = mmax(0, rowCount - visibleRowCount)
    offset = mmax(0, mmin(maxOffset, mfloor(offset + 0.5)))
    if offset ~= displayState.scrollOffset then
        displayState.scrollOffset = offset
        RenderRows()
    end
end

-------------------------
-- Status and controls
-------------------------
---@return string
local function SortLabel()
    local labels = {
        [SORT_NAME] = "name",
        [SORT_TOTAL] = "total",
        [SORT_SELF] = "self",
        [SORT_CALLS] = "calls",
        [SORT_AVERAGE] = "avg",
    }
    return (labels[displayState.sortKey] or displayState.sortKey) .. (displayState.descending and " desc" or " asc")
end

---Re-applies the sort arrow and the sorted-column colour.
---Also called on hover, because a button re-applies its font object - and with it that font's colour - on
---every state change, which would otherwise wash the gold marker off the active column until the next refresh.
function UpdateColumnHeaders()
    for _, header in pairs(columnHeaders) do
        local isSorted = header.sortKey == displayState.sortKey
        local arrow = ""
        if isSorted then
            arrow = displayState.descending and " v" or " ^"
        end
        header:SetText(header.label .. arrow)

        local fontString = header:GetFontString()
        if fontString then
            if isSorted then
                fontString:SetTextColor(COLOR_SORTED_VALUE.r, COLOR_SORTED_VALUE.g, COLOR_SORTED_VALUE.b)
            else
                fontString:SetTextColor(0.7, 0.7, 0.7)
            end
        end
    end
end

local function UpdateStatus()
    if not statusText or not currentReport then
        return
    end

    local sessionState = QuestieProfiler.active and "ACTIVE" or "STOPPED"
    local displayStateLabel = displayState.frozen and "FROZEN" or (QuestieProfiler.active and "LIVE" or "STATIC")
    local status = sformat("%s | %s | %d hooked | %d/%d shown | peak %s ms | peak %s calls | sort %s",
        sessionState,
        displayStateLabel,
        QuestieProfiler.hookedFunctionCount or 0,
        currentReport.matchedCount,
        currentReport.totalCount,
        FormatMilliseconds(QuestieProfiler.highestMS or 0),
        FormatCount(QuestieProfiler.highestCalls or 0),
        SortLabel())

    if displayState.hideIdle and currentReport.idleHiddenCount > 0 then
        status = status .. sformat(" | %d idle hidden", currentReport.idleHiddenCount)
    end
    statusText:SetText(status)
end

function UpdateControls()
    if not baseFrame then
        return
    end

    local isActive = QuestieProfiler.active
    sessionButton:SetText(isActive and "Stop" or "Start")
    -- Enable/Disable rather than SetEnabled: it is the spelling present on every supported client.
    if isActive then
        resetButton:Enable()
    else
        resetButton:Disable()
    end
    freezeButton:SetText(displayState.frozen and "Unfreeze" or "Freeze")
    viewButton:SetText(displayState.grouped and "Grouped" or "Full path")
    -- Label the state of the list, not the state of the toggle: "off" alone reads ambiguously.
    idleButton:SetText(displayState.hideIdle and "Idle: hidden" or "Idle: shown")

    if isActive then
        sessionChip:SetText("|cff40dd40ACTIVE|r")
    else
        sessionChip:SetText("|cffdd4040STOPPED|r")
    end
    if displayState.frozen then
        displayChip:SetText("|cffffcc00FROZEN|r")
    elseif isActive then
        displayChip:SetText("|cff40dd40LIVE|r")
    else
        displayChip:SetText("|cff888888STATIC|r")
    end

    UpdateColumnHeaders()
end

-------------------------
-- Refresh lifecycle
-------------------------
-- Refresh is display work only. It never mutates a profiler table, so freezing, sorting and browsing cannot
-- change what is being measured.
function QuestieProfilerUI:Refresh()
    ---@type ProfilerReportSource
    local source = QuestieProfiler
    currentReport = _QuestieProfilerUI.BuildReport(source, {
        filter = displayState.filter,
        grouped = displayState.grouped,
        hideIdle = displayState.hideIdle,
        sortKey = displayState.sortKey,
        descending = displayState.descending,
    })
    RenderRows()
    UpdateStatus()
    UpdateControls()
    -- Re-evaluated on every refresh so a session stopped or frozen from outside this window - a /run call, or
    -- the engine itself - cannot leave a pointless ticker running.
    UpdateTickerState()
end

function UpdateTickerState()
    -- Automatic refresh is pointless when nothing can change or nobody can see it.
    local shouldTick = userVisible
        and baseFrame ~= nil
        and baseFrame:IsShown()
        and (not displayState.frozen)
        and QuestieProfiler.active == true

    if shouldTick and not refreshTicker then
        refreshTicker = C_Timer.NewTicker(REFRESH_INTERVAL, function()
            QuestieProfilerUI:Refresh()
        end)
    elseif (not shouldTick) and refreshTicker then
        refreshTicker:Cancel()
        refreshTicker = nil
    end
end

---@param sortKey string
local function ApplySort(sortKey)
    if displayState.sortKey == sortKey then
        displayState.descending = not displayState.descending
    else
        displayState.sortKey = sortKey
        -- Cost columns are most useful worst-first; identity reads better alphabetically.
        displayState.descending = sortKey ~= SORT_NAME
    end
    displayState.scrollOffset = 0
    QuestieProfilerUI:Refresh()
end

-------------------------
-- Frame construction
-------------------------
---@param parent table
---@param text string
---@param width number
---@return table button
local function CreateControlButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 20)
    -- Set the button's font objects, not the font string's. A button re-applies its stored normal/highlight/
    -- disabled font object on every state change, so styling the font string directly is undone by the first
    -- mouseover and the template's full-size highlight font sticks.
    button:SetNormalFontObject("GameFontNormalSmall")
    button:SetHighlightFontObject("GameFontHighlightSmall")
    button:SetDisabledFontObject("GameFontDisableSmall")
    button:SetText(text)
    return button
end

---@param parent table
---@param label string
---@param sortKey string
---@return table header
local function CreateColumnHeader(parent, label, sortKey)
    local header = CreateFrame("Button", nil, parent)
    header:SetHeight(COLUMN_HEADER_HEIGHT)
    header:SetNormalFontObject("GameFontNormalSmall")
    header:SetHighlightFontObject("GameFontNormalSmall")
    header:SetText(label)
    header.label = label
    header.sortKey = sortKey
    header:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight", "ADD")
    header:SetScript("OnClick", function(self)
        ApplySort(self.sortKey)
    end)
    header:SetScript("OnEnter", UpdateColumnHeaders)
    header:SetScript("OnLeave", UpdateColumnHeaders)
    tinsert(columnHeaders, header)
    return header
end

local function BuildTitleBar()
    local titleBar = CreateFrame("Frame", nil, baseFrame)
    titleBar:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", EDGE_PADDING, -6)
    titleBar:SetPoint("TOPRIGHT", baseFrame, "TOPRIGHT", -EDGE_PADDING, -6)
    titleBar:SetHeight(TITLE_BAR_HEIGHT)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        baseFrame:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        baseFrame:StopMovingOrSizing()
    end)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleBar, "LEFT", 0, 0)
    title:SetText("Questie Profiler")

    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", 4, 0)
    closeButton:SetScript("OnClick", function()
        QuestieProfilerUI:Hide()
    end)

    displayChip = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    displayChip:SetPoint("RIGHT", closeButton, "LEFT", -6, 0)

    sessionChip = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sessionChip:SetPoint("RIGHT", displayChip, "LEFT", -8, 0)
end

local function BuildControlRow()
    sessionButton = CreateControlButton(baseFrame, "Stop", 62)
    sessionButton:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", EDGE_PADDING, -(6 + TITLE_BAR_HEIGHT))
    sessionButton:SetScript("OnClick", function()
        if QuestieProfiler.active then
            QuestieProfiler:Stop()
        else
            -- Start(true) keeps this window on screen; the engine re-asserts visibility through ShowUI.
            displayState.frozen = false
            displayState.scrollOffset = 0
            QuestieProfiler:Start(true)
        end
        UpdateTickerState()
        QuestieProfilerUI:Refresh()
    end)

    resetButton = CreateControlButton(baseFrame, "Reset", 58)
    resetButton:SetPoint("LEFT", sessionButton, "RIGHT", 4, 0)
    resetButton:SetScript("OnClick", function()
        QuestieProfiler:ResetMeasurements()
        displayState.scrollOffset = 0
        QuestieProfilerUI:Refresh()
    end)

    freezeButton = CreateControlButton(baseFrame, "Freeze", 70)
    freezeButton:SetPoint("LEFT", resetButton, "RIGHT", 12, 0)
    freezeButton:SetScript("OnClick", function()
        displayState.frozen = not displayState.frozen
        UpdateTickerState()
        QuestieProfilerUI:Refresh()
    end)

    refreshButton = CreateControlButton(baseFrame, "Refresh", 64)
    refreshButton:SetPoint("LEFT", freezeButton, "RIGHT", 4, 0)
    refreshButton:SetScript("OnClick", function()
        QuestieProfilerUI:Refresh()
    end)
end

local function BuildFilterRow()
    local filterTop = -(6 + TITLE_BAR_HEIGHT + CONTROL_ROW_HEIGHT)

    viewButton = CreateControlButton(baseFrame, "Full path", 76)
    viewButton:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", EDGE_PADDING, filterTop)
    viewButton:SetScript("OnClick", function()
        displayState.grouped = not displayState.grouped
        displayState.selectedKey = nil
        displayState.scrollOffset = 0
        QuestieProfilerUI:Refresh()
    end)

    idleButton = CreateControlButton(baseFrame, "Idle: hidden", 82)
    idleButton:SetPoint("LEFT", viewButton, "RIGHT", 4, 0)
    idleButton:SetScript("OnClick", function()
        displayState.hideIdle = not displayState.hideIdle
        displayState.scrollOffset = 0
        QuestieProfilerUI:Refresh()
    end)

    local searchLabel = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetPoint("LEFT", idleButton, "RIGHT", 12, 0)
    searchLabel:SetText("Search")

    searchBox = CreateFrame("EditBox", nil, baseFrame, "InputBoxTemplate")
    searchBox:SetHeight(18)
    searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 10, 0)
    searchBox:SetPoint("RIGHT", baseFrame, "RIGHT", -(EDGE_PADDING + 22), 0)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject("GameFontHighlightSmall")
    searchBox:SetScript("OnTextChanged", function(self)
        displayState.filter = self:GetText() or ""
        displayState.scrollOffset = 0
        QuestieProfilerUI:Refresh()
    end)
    searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    searchClearButton = CreateFrame("Button", nil, baseFrame, "UIPanelCloseButton")
    searchClearButton:SetSize(20, 20)
    searchClearButton:SetPoint("LEFT", searchBox, "RIGHT", 2, 0)
    searchClearButton:SetScript("OnClick", function()
        searchBox:SetText("")
        searchBox:ClearFocus()
    end)
end

local function BuildColumnHeaders()
    local headerTop = -(6 + TITLE_BAR_HEIGHT + CONTROL_ROW_HEIGHT + FILTER_ROW_HEIGHT)

    local averageHeader = CreateColumnHeader(baseFrame, "Avg ms", SORT_AVERAGE)
    averageHeader:SetWidth(COLUMN_AVERAGE_WIDTH)
    averageHeader:SetPoint("TOPRIGHT", baseFrame, "TOPRIGHT", -(EDGE_PADDING + SCROLL_TRACK_WIDTH + COLUMN_GAP), headerTop)

    local callsHeader = CreateColumnHeader(baseFrame, "Calls", SORT_CALLS)
    callsHeader:SetWidth(COLUMN_CALLS_WIDTH)
    callsHeader:SetPoint("TOPRIGHT", averageHeader, "TOPLEFT", -COLUMN_GAP, 0)

    local selfHeader = CreateColumnHeader(baseFrame, "Self ms", SORT_SELF)
    selfHeader:SetWidth(COLUMN_SELF_WIDTH)
    selfHeader:SetPoint("TOPRIGHT", callsHeader, "TOPLEFT", -COLUMN_GAP, 0)

    local totalHeader = CreateColumnHeader(baseFrame, "Total ms", SORT_TOTAL)
    totalHeader:SetWidth(COLUMN_TOTAL_WIDTH)
    totalHeader:SetPoint("TOPRIGHT", selfHeader, "TOPLEFT", -COLUMN_GAP, 0)

    local nameHeader = CreateColumnHeader(baseFrame, "Function / Job", SORT_NAME)
    nameHeader:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", EDGE_PADDING, headerTop)
    nameHeader:SetPoint("TOPRIGHT", totalHeader, "TOPLEFT", -COLUMN_GAP, 0)
    if nameHeader:GetFontString() then
        nameHeader:GetFontString():SetJustifyH("LEFT")
        nameHeader:GetFontString():ClearAllPoints()
        nameHeader:GetFontString():SetPoint("LEFT", nameHeader, "LEFT", ACCENT_STRIPE_WIDTH + 4, 0)
    end
    for _, header in ipairs({averageHeader, callsHeader, selfHeader, totalHeader}) do
        if header:GetFontString() then
            header:GetFontString():SetJustifyH("RIGHT")
        end
    end
end

local function BuildScrollTrack()
    scrollTrack = CreateFrame("Frame", nil, baseFrame)
    scrollTrack:SetWidth(SCROLL_TRACK_WIDTH)
    scrollTrack:SetPoint("TOPRIGHT", listFrame, "TOPRIGHT", 0, 0)
    scrollTrack:SetPoint("BOTTOMRIGHT", listFrame, "BOTTOMRIGHT", 0, 0)

    local trackTexture = scrollTrack:CreateTexture(nil, "BACKGROUND")
    trackTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
    trackTexture:SetAllPoints(scrollTrack)
    if trackTexture.SetColorTexture then
        trackTexture:SetColorTexture(1, 1, 1, 0.06)
    else
        trackTexture:SetVertexColor(1, 1, 1, 0.06)
    end

    scrollThumb = CreateFrame("Frame", nil, scrollTrack)
    scrollThumb:SetWidth(SCROLL_TRACK_WIDTH)
    scrollThumb:SetPoint("TOP", scrollTrack, "TOP", 0, 0)
    scrollThumb:EnableMouse(true)

    local thumbTexture = scrollThumb:CreateTexture(nil, "ARTWORK")
    thumbTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
    thumbTexture:SetAllPoints(scrollThumb)
    if thumbTexture.SetColorTexture then
        thumbTexture:SetColorTexture(0.6, 0.6, 0.65, 0.7)
    else
        thumbTexture:SetVertexColor(0.6, 0.6, 0.65, 0.7)
    end

    -- Blizzard's scroll templates differ across the supported clients, so the thumb is driven directly from
    -- the cursor instead. That keeps behaviour identical on Era through Mists with no per-client fallbacks.
    local function OnThumbUpdate()
        local _, cursorY = GetCursorPosition()
        local effectiveScale = scrollTrack:GetEffectiveScale()
        if not effectiveScale or effectiveScale == 0 then
            return
        end
        cursorY = cursorY / effectiveScale

        local trackTop = scrollTrack:GetTop()
        local trackHeight = scrollTrack:GetHeight()
        local thumbHeight = scrollThumb:GetHeight()
        if not trackTop or not trackHeight or not thumbHeight then
            return
        end
        local travel = trackHeight - thumbHeight
        if travel <= 0 then
            return
        end

        local rowCount = currentReport and #currentReport.rows or 0
        local maxOffset = mmax(0, rowCount - VisibleRowCount())
        local progress = ((trackTop - cursorY) - thumbHeight / 2) / travel
        SetScrollOffset(mmax(0, mmin(1, progress)) * maxOffset)
    end

    scrollThumb:SetScript("OnMouseDown", function(self)
        self:SetScript("OnUpdate", OnThumbUpdate)
    end)
    scrollThumb:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)
end

local function BuildListArea()
    local listTop = -(6 + TITLE_BAR_HEIGHT + CONTROL_ROW_HEIGHT + FILTER_ROW_HEIGHT + COLUMN_HEADER_HEIGHT)

    listFrame = CreateFrame("Frame", nil, baseFrame)
    listFrame:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", EDGE_PADDING, listTop)
    listFrame:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT",
        -EDGE_PADDING, DETAIL_STRIP_HEIGHT + STATUS_BAR_HEIGHT + EDGE_PADDING)
    listFrame:EnableMouseWheel(true)
    listFrame:SetScript("OnMouseWheel", function(_, delta)
        SetScrollOffset(displayState.scrollOffset - delta * WHEEL_SCROLL_ROWS)
    end)

    BuildScrollTrack()
end

local function BuildFooter()
    detailText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detailText:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT", EDGE_PADDING, STATUS_BAR_HEIGHT + 2)
    detailText:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -EDGE_PADDING, STATUS_BAR_HEIGHT + 2)
    detailText:SetJustifyH("LEFT")
    detailText:SetTextColor(0.75, 0.75, 0.8)
    DisableWrapping(detailText)

    statusText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT", EDGE_PADDING, 6)
    statusText:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -(EDGE_PADDING + 16), 6)
    statusText:SetJustifyH("LEFT")
    statusText:SetTextColor(0.65, 0.65, 0.7)
    DisableWrapping(statusText)
end

local function BuildSizer()
    local sizer = CreateFrame("Button", nil, baseFrame)
    sizer:SetSize(16, 16)
    sizer:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -2, 2)
    sizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    sizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    sizer:SetScript("OnMouseDown", function()
        baseFrame:StartSizing("BOTTOMRIGHT")
    end)
    sizer:SetScript("OnMouseUp", function()
        baseFrame:StopMovingOrSizing()
        Layout()
    end)
end

function Layout()
    if not baseFrame then
        return
    end
    RenderRows()
end

-------------------------
-- Active-session indicator
-------------------------
-- A standing reminder that profiling is running - and therefore costing frame time - plus the way back to a
-- window the user closed. It polls the session rather than being told about it: the profiler can be stopped
-- or started from anywhere, and the window's refresh ticker does not run while the window is hidden.
local function UpdateIndicator()
    if not indicatorButton then
        return
    end
    if QuestieProfiler.active then
        indicatorButton:Show()
    else
        indicatorButton:Hide()
    end
end

local function CreateIndicator()
    if indicatorButton then
        return indicatorButton
    end

    indicatorButton = CreateFrame("Button", "QuestieProfilerIndicator", UIParent)
    indicatorButton:SetPoint("TOP", UIParent, "TOP", 0, -4)
    indicatorButton:SetFrameStrata("HIGH")

    local background = indicatorButton:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Buttons\\WHITE8X8")
    background:SetAllPoints(indicatorButton)
    if background.SetColorTexture then
        background:SetColorTexture(0, 0, 0, 0.5)
    else
        background:SetVertexColor(0, 0, 0, 0.5)
    end

    local label = indicatorButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", indicatorButton, "CENTER", 0, 0)
    label:SetText(INDICATOR_LABEL)
    label:SetTextColor(INDICATOR_COLOR.r, INDICATOR_COLOR.g, INDICATOR_COLOR.b)
    indicatorButton.label = label

    local labelWidth = label.GetStringWidth and label:GetStringWidth() or 120
    indicatorButton:SetSize(labelWidth + 12, 16)

    indicatorButton:SetScript("OnEnter", function(self)
        self.label:SetTextColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:AddLine("Questie profiler is running", 1, 0.82, 0)
        -- Resolved per hover so the hint always names what the click will actually do.
        if QuestieProfilerUI:IsShown() then
            GameTooltip:AddLine("Click to close the profiler window.", 0.8, 0.8, 0.8)
        else
            GameTooltip:AddLine("Click to open the profiler window.", 0.8, 0.8, 0.8)
        end
        GameTooltip:Show()
    end)
    indicatorButton:SetScript("OnLeave", function(self)
        self.label:SetTextColor(INDICATOR_COLOR.r, INDICATOR_COLOR.g, INDICATOR_COLOR.b)
        GameTooltip:Hide()
    end)
    indicatorButton:SetScript("OnClick", function()
        if QuestieProfilerUI:IsShown() then
            QuestieProfilerUI:Hide()
        else
            QuestieProfilerUI:Show()
        end
    end)

    indicatorButton:Hide()
    UpdateIndicator()
    -- Runs for the addon lifetime; there is no state in which the indicator should stop tracking the session.
    C_Timer.NewTicker(INDICATOR_POLL_INTERVAL, UpdateIndicator)
    return indicatorButton
end

---Creates the profiler window. Safe to call repeatedly and safe to call before hooks are installed.
---@return table baseFrame
function QuestieProfilerUI:Create()
    if baseFrame then
        return baseFrame
    end

    baseFrame = CreateFrame("Frame", "QuestieProfilerFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    baseFrame:SetSize(WINDOW_DEFAULT_WIDTH, WINDOW_DEFAULT_HEIGHT)
    baseFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    baseFrame:SetFrameStrata("DIALOG")
    baseFrame:SetClampedToScreen(true)
    baseFrame:EnableMouse(true)
    baseFrame:SetMovable(true)
    baseFrame:SetResizable(true)
    ApplyResizeBounds(baseFrame, WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT, WINDOW_MAX_WIDTH, WINDOW_MAX_HEIGHT)

    if baseFrame.SetBackdrop then
        baseFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 14,
            insets = {left = 3, right = 3, top = 3, bottom = 3},
        })
        baseFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.94)
        baseFrame:SetBackdropBorderColor(0.4, 0.4, 0.45, 1)
    end

    BuildTitleBar()
    BuildControlRow()
    BuildFilterRow()
    BuildColumnHeaders()
    BuildListArea()
    BuildFooter()
    BuildSizer()

    baseFrame:SetScript("OnSizeChanged", function()
        Layout()
    end)
    -- Hiding is always a display decision: it stops the refresh ticker and never touches the session.
    -- Before the world exists a bare Hide is startup interference, so the show intent survives it and the
    -- PLAYER_ENTERING_WORLD handler below puts the window back. Afterwards a bare Hide is the user pressing
    -- Escape and does clear the intent. An explicit Hide() clears it in either phase.
    baseFrame:SetScript("OnHide", function()
        if hasEnteredWorld then
            userVisible = false
        end
        UpdateTickerState()
    end)
    baseFrame:SetScript("OnShow", function()
        UpdateTickerState()
    end)

    if type(UISpecialFrames) == "table" then
        local alreadyRegistered = false
        for _, frameName in ipairs(UISpecialFrames) do
            if frameName == "QuestieProfilerFrame" then
                alreadyRegistered = true
                break
            end
        end
        if not alreadyRegistered then
            tinsert(UISpecialFrames, "QuestieProfilerFrame")
        end
    end

    -- Own event frame rather than Questie:RegisterEvent, which is a profiled function.
    eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function()
        hasEnteredWorld = true
        -- Startup runs before the world exists. Re-assert the window the user asked for, but never undo an
        -- explicit close: userVisible is cleared by every hide path, including Escape.
        if userVisible and baseFrame and not baseFrame:IsShown() then
            baseFrame:Show()
        end
        UpdateTickerState()
    end)

    baseFrame:Hide()
    return baseFrame
end

---@return table baseFrame
function QuestieProfilerUI:Show()
    CreateIndicator()
    local frame = QuestieProfilerUI:Create()
    userVisible = true
    frame:Show()
    QuestieProfilerUI:Refresh()
    UpdateTickerState()
    return frame
end

---Hides the window without touching the profiling session.
function QuestieProfilerUI:Hide()
    -- Show and Hide are the profiler's only entry points here, and arming a session always calls one of them.
    -- Building the indicator from both means a client that never profiles creates no frame and no ticker,
    -- while StartStartup(showUI = false) - which never builds a window - still gets one.
    CreateIndicator()
    userVisible = false
    if baseFrame then
        baseFrame:Hide()
    end
    UpdateTickerState()
end

---@return boolean
function QuestieProfilerUI:IsShown()
    return baseFrame ~= nil and baseFrame:IsShown() == true
end

-------------------------
-- Enable toggle
-------------------------
-- Registered here rather than in QuestieSlash so that enabling the profiler touches no gameplay file, and so
-- the command exists even on a client where profiling never armed. The flag is read at load by Questie.lua,
-- so a change only takes effect on the next reload - which is stated plainly rather than implied.
---@param enabled boolean
local function ReportProfilerEnabled(enabled)
    if enabled then
        Questie:Print("Questie profiler |cff40dd40enabled|r. Reload the UI to start profiling.")
    else
        Questie:Print("Questie profiler |cffdd4040disabled|r. Reload the UI to stop profiling.")
    end
end

SLASH_QUESTIEPROFILER1 = "/qprofiler"
SlashCmdList["QUESTIEPROFILER"] = function(argument)
    local command = string.lower(string.match(argument or "", "^%s*(%S*)") or "")

    if command == "on" then
        QuestieProfilerEnabled = true
        ReportProfilerEnabled(true)
    elseif command == "off" then
        QuestieProfilerEnabled = false
        ReportProfilerEnabled(false)
    elseif command == "toggle" then
        QuestieProfilerEnabled = not QuestieProfilerEnabled
        ReportProfilerEnabled(QuestieProfilerEnabled == true)
    elseif command == "show" and QuestieProfiler.active then
        QuestieProfilerUI:Show()
    else
        local state = QuestieProfilerEnabled and "enabled" or "disabled"
        local session = QuestieProfiler.active and "running" or "not running"
        Questie:Print(string.format("Questie profiler: %s, currently %s.", state, session))
        Questie:Print("/qprofiler on | off | toggle | show")
    end
end

-- Exposed for behavioural tests; the window itself never reads these.
_QuestieProfilerUI.displayState = displayState
_QuestieProfilerUI.GroupedIdentity = GroupedIdentity
_QuestieProfilerUI.IsThreadJobKey = IsThreadJobKey
_QuestieProfilerUI.UpdateIndicator = UpdateIndicator

---@return boolean isIndicatorShown
function _QuestieProfilerUI.IsIndicatorShown()
    return indicatorButton ~= nil and indicatorButton:IsShown() == true
end

---@return boolean isRefreshing
function _QuestieProfilerUI.IsRefreshTickerActive()
    return refreshTicker ~= nil
end

---@return boolean hasEnteredWorld
function _QuestieProfilerUI.HasEnteredWorld()
    return hasEnteredWorld
end
