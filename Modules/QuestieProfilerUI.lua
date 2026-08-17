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
-- Sized to the content rather than to a round number: the widest identity in a normal session
-- (QuestieJourney.private.questsByFaction.InitializeFactionQuestData) fits beside the tree pane and five
-- numeric columns without truncation, and the height stops short of covering the middle of the screen.
local WINDOW_DEFAULT_WIDTH = 1000
local WINDOW_DEFAULT_HEIGHT = 520
local WINDOW_MIN_WIDTH = 494
local WINDOW_MIN_HEIGHT = 269
local WINDOW_MAX_WIDTH = 1600
local WINDOW_MAX_HEIGHT = 1200

local ROW_HEIGHT = 14
local TITLE_BAR_HEIGHT = 22
-- The header band is the footer band turned upside down: identity and session state are chrome in exactly the
-- way the totals row is, so they get the same floor-and-rule treatment rather than floating on the content.
local HEADER_BAND_HEIGHT = 6 + TITLE_BAR_HEIGHT
-- Everything below the band measures from here, leaving the same clearance under the rule that the selection
-- row keeps above its own.
local CONTENT_TOP = HEADER_BAND_HEIGHT + 5
local CONTROL_ROW_HEIGHT = 26
local FILTER_ROW_HEIGHT = 26

-- Every control button is the same size with the same gaps. Sizing each one to its own label is most of what
-- made the old row look thrown together: five buttons at five widths, with two different gaps between them.
local CONTROL_BUTTON_WIDTH = 70
local CONTROL_BUTTON_HEIGHT = 20
local CONTROL_BUTTON_GAP = 4
-- Wider than the gap between buttons, so the session group and the view group read as two things.
local CONTROL_GROUP_GAP = 14
local COLUMN_HEADER_HEIGHT = 16
local DETAIL_STRIP_HEIGHT = 16
-- The relations panel only exists while a row is selected, so it costs nothing until it is asked for.
-- Five entries a side covers every real case measured: the widest fan-in in a live session was four callers.
local RELATION_PANEL_ROWS = 5
-- Gap between the two relation columns, and the least of the panel either may be reduced to. The floor is
-- what stops a lopsided pair - one caller against a dozen callees - from squeezing a column to nothing.
local RELATION_ROW_HEIGHT = 13
local RELATION_HEADER_HEIGHT = 15
local RELATION_PANEL_HEIGHT = RELATION_HEADER_HEIGHT + (RELATION_PANEL_ROWS * RELATION_ROW_HEIGHT) + 4
-- Tall enough to hold the session row plus the rule that closes it off from the selection row above.
local STATUS_BAR_HEIGHT = 20
-- How far the selection row floats above that rule. Sitting on it made the two rows look like one block.
local SELECTION_ROW_LIFT = 7
local SCROLL_TRACK_WIDTH = 8
local EDGE_PADDING = 8
local ACCENT_STRIPE_WIDTH = 2
local ROW_ICON_SIZE = 12
-- Clearance between a control and the tooltip that opens above it.
local CONTROL_TOOLTIP_GAP = 4

-- One icon per species, but the function icon is worn only in the filter row. A glyph repeated down the
-- majority of rows marks nothing, and functions are the majority by design - they are the species the list is
-- mostly made of, so they are the one that gains from staying unmarked. Jobs and files keep theirs: both are
-- rare enough for the icon to be a mark rather than wallpaper, a job keyed by call site reads exactly like a
-- file path without one, and green against neutral grey is the pair red-green colour blindness collapses.
-- The slot stays reserved on every row so names keep one left edge.
-- Blizzard's pre-greyed variants are dimmed as well as desaturated, so they wash out at row height;
-- desaturating a full-brightness texture keeps the contrast and still reads as neutral.
local ICON_FILE_LOAD = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up"
local ICON_FUNCTION = "Interface\\Buttons\\UI-OptionsButton"
local ICON_THREAD_JOB = "Interface\\Buttons\\UI-RefreshButton"

-- Keyed by sort key, so a column's width, its header and its sort are all reachable from one name. Grouped
-- rather than kept as six locals because this file sits against Lua 5.1's 200-local ceiling for a main chunk.
local COLUMN_WIDTHS = {
    total = 70,
    self = 70,
    calls = 58,
    average = 62,
    memory = 72,
}
local TREE_PANE_WIDTH = 210
-- Everything right of the tree shares this left edge, and the divider sits in the middle of the gutter so the
-- pane and the content get equal clearance. The old 10 put the divider 4px off the tree and the content 6px
-- off the divider, which read as the two columns touching rather than being separated by one.
local TREE_PANE_GUTTER = 24
local TREE_ROW_HEIGHT = 14
local TREE_INDENT = 10
-- A hairline, not a control. It only has to say "there is more below", so it is a quarter the width of the
-- list's real scrollbar and faint enough that nobody reaches for it: a widget that invites a drag it cannot
-- accept is worse than no indicator at all. Both colours below are free to tune.
local TREE_SCROLL_WIDTH = 1
-- Structure, not decoration: a divider marks where one pane stops and the next begins, so it has to survive
-- being read at a glance. A 1px line reads far fainter than a filled row at the same alpha, which is why this
-- sits above the selection fill below and still looks lighter.
local DIVIDER_COLOR = {r = 1, g = 1, b = 1, a = 0.22}

-- Hover, then selection. Both lists are clickable but neither said so; the relations panel has had a hover
-- highlight since it was built, which is why it never needed explaining. Hover stays below selection so a
-- pinned row still wins when the mouse is over it.
local HOVER_HIGHLIGHT_COLOR = {r = 1, g = 1, b = 1, a = 0.10}
local SELECTION_HIGHLIGHT_COLOR = {r = 1, g = 1, b = 1, a = 0.18}

-- Alternating row tint. The heat bar only covers the numeric columns, so the name side - the long ragged half
-- where the eye actually loses its place - has no background at all. Far below hover, which is what keeps a
-- banded row from looking like it is already under the mouse.
local ROW_STRIPE_COLOR = {r = 1, g = 1, b = 1, a = 0.025}

-- Worn by both the header and the footer band. The bottom two rows answer different questions - one describes
-- the row you clicked, the other describes the session and never changes with selection - and at nearly equal
-- brightness they read as one four-part sentence. Darkening a row into a band separates it by kind rather
-- than by wording: a band is chrome, and chrome is exactly what a title and a session readout are.
local CHROME_BAND_COLOR = {r = 0, g = 0, b = 0, a = 0.30}

-- A hint recedes; an active filter does not. Brightness is what tells the two apart now that neither is
-- labelled, so an unnoticed scope cannot quietly explain why the list looks short.
local SCOPE_HINT_COLOR = {r = 0.6, g = 0.6, b = 0.68}
local SCOPE_ACTIVE_COLOR = {r = 0.86, g = 0.88, b = 0.95}

local TREE_SCROLL_TRACK_COLOR = {r = 1, g = 1, b = 1, a = 0.02}
local TREE_SCROLL_THUMB_COLOR = {r = 0.78, g = 0.78, b = 0.86, a = 0.16}
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
local SORT_MEMORY = "memory"

local MAX_CALLERS_IN_TOOLTIP = 8

-- Names already carry a hierarchy the flat list throws away: files are directory paths, functions are module
-- paths. Rebuilding it is what lets the window answer "what does all of Database/ cost", which no per-row
-- view can. Jobs have no path of their own, so they collect under one synthetic node rather than vanishing.
local THREAD_JOB_TREE_LABEL = "ThreadLib jobs"

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

-- Row colour, worn by both the name and the left accent stripe. Questie's own functions are the baseline and
-- stay neutral on purpose: colouring the majority would spend the colour without buying a distinction.
-- Everything else is marked, so a glance down the stripe separates measured work from addon load, scheduling
-- from calls, and our code from a dependency's, without reading a single name. Kept clear of the heat bands
-- (red, orange, yellow) so a row's kind never reads as its cost.
local COLOR_TEXT = {r = 0.88, g = 0.88, b = 0.88}
local COLOR_THREAD_JOB = {r = 0.45, g = 0.80, b = 1.00}
local COLOR_FILE_LOAD = {r = 0.55, g = 0.85, b = 0.55}
-- A bundled-library function is not a fourth species: it is a called function like any other, with callers,
-- self time and an average, and it gets no visibility checkbox because there is nothing categorically
-- different to switch off. What differs is ownership - a Questie row is code we can edit, a library row is a
-- dependency we can only call less or differently - and that is worth one glance rather than a read of the
-- path. It earns the colour on the same rule the baseline is neutral by: measured over a normal session it
-- was 26 rows of 341, a minority, so colouring it buys a distinction instead of spending one.
local COLOR_LIBRARY = {r = 0.72, g = 0.62, b = 0.95}

-- Brightness is a second channel, independent of hue: the colour says what kind of row this is, the
-- brightness says whether it ran. A never-called entry is real - it was hooked - but contributed nothing, so
-- it recedes instead of shouting. It gets no accent stripe: the stripe answers "which species", and dimming
-- an entry is not a species. Files are exempt, having no call count that could be zero.
local NEVER_CALLED_DIM = 0.55
local COLOR_UNTIMED = {r = 0.55, g = 0.55, b = 0.55}
local COLOR_SORTED_VALUE = {r = 1.00, g = 0.82, b = 0.00}
local COLOR_SELF_DOMINANT = {r = 0.95, g = 0.60, b = 0.45}

-- Heading for a panel section. Neutral on purpose: gold already means "this is the active sort" one row up,
-- so a gold heading claims a meaning it does not have. The faint cool cast and the extra brightness over the
-- 0.7 column headers are what make it read as a heading instead of another label.
local COLOR_SECTION_HEADING = {r = 0.80, g = 0.83, b = 0.90}

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
---@field memoryKilobytes number?
---@field share number? @0-1 of what this row's own species accounts for; nil when there is no denominator
---@field shareDenominator number? @The species total the share was taken against @Allocation attributed to this row; only addon-load rows carry one
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
    -- Counted regardless of the filter, so the control that hides them can say how many that is even while
    -- they are being shown.
    local idleCount = 0

    for lookupKey, calls in pairs(callCounts) do
        totalCount = totalCount + 1

        -- Grouped rows are matched through their original paths, so a filter on a folded-away prefix still
        -- resolves to the aggregate that contains it.
        local haystack = lowerCaseLookup[lookupKey] or slower(lookupKey)
        local matchesFilter = lowerFilter == "" or sfind(haystack, lowerFilter, 1, true) ~= nil

        if matchesFilter then
            if calls == 0 then
                idleCount = idleCount + 1
            end
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
function _QuestieProfilerUI.BuildCalleeList(source, reportRow, grouped)
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
function _QuestieProfilerUI.BuildSessionTotals(source)
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
function _QuestieProfilerUI.FormatDuration(value)
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
function _QuestieProfilerUI.BuildTree(rows)
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
function _QuestieProfilerUI.FlattenTree(root, expandedPrefixes)
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

_QuestieProfilerUI.FormatCount = FormatCount
_QuestieProfilerUI.FormatShare = FormatShare
_QuestieProfilerUI.FormatKilobytes = FormatKilobytes
_QuestieProfilerUI.FormatMilliseconds = FormatMilliseconds

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
-- Which header the mouse is over, so it can show the sort it would apply rather than staying silent until
-- clicked. Nil whenever the mouse is elsewhere.
local hoveredColumnKey
local sessionButton, resetButton, freezeButton, refreshButton, neverCalledCheckButton
local reloadButton, startupCheckButton
local speciesCheckButtons = {}
local treeFrame, treeScopeButton, treeScopeText
local treeScrollTrack, treeScrollThumb
local treeRowPool = {}
local currentTree
local columnHeadersByKey = {}
local searchBox, searchClearButton
local sessionChip, displayChip, statusText, detailText
local detailBox, detailBoxMeasure
local relationPanel, relationCallerRows, relationCalleeRows
local currentUnscopedRows = {}
local relationCallerHeader, relationCalleeHeader
local summaryText
local eventFrame
local indicatorButton

local refreshTicker
local currentReport
local userVisible = false
local hasEnteredWorld = false

local displayState = {
    filter = "",
    -- No longer a toggle. Grouping only strips the `private` indirection segment, measured at zero merged
    -- rows on a live session, so a "full path" mode would differ by a word in the name and nothing else.
    grouped = true,
    hideIdle = true,
    sortKey = SORT_TOTAL,
    descending = true,
    showFunctions = true,
    showJobs = true,
    showFiles = true,
    scopePrefix = "",
    scopeLabel = "",
    treeVisible = true,
    treeScrollOffset = 0,
    expandedPrefixes = {},
    frozen = false,
    selectedKey = nil,
    scrollOffset = 0,
}

local Layout, RenderRows, UpdateControls, UpdateColumnHeaders, UpdateTickerState
local LayoutContentArea, RenderRelations, ApplySelection
local LayoutColumnHeaders, RenderTree
local SetControlTooltip, UpdateDetailStrip

---A column is shown when at least one visible species has something to put in it. Selecting Files alone
---therefore drops Self, Calls and Average - which are all dashes for a file - and reveals Allocated, which
---only a file has. The mixed default keeps everything, because that is what mixing costs.
---@return table<string, boolean> visibleColumns
local function VisibleColumns()
    local functions = displayState.showFunctions
    local jobs = displayState.showJobs
    local files = displayState.showFiles
    -- With nothing selected the list is empty; keep the default header set rather than collapsing it.
    if not functions and not jobs and not files then
        functions, jobs, files = true, true, true
    end

    return {
        [SORT_NAME] = true,
        [SORT_TOTAL] = true,
        [SORT_SELF] = functions,
        [SORT_CALLS] = functions or jobs,
        [SORT_AVERAGE] = functions or jobs,
        [SORT_MEMORY] = files,
    }
end

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

---Gives a clickable row the hover fill every other clickable thing in the window has.
---Deliberately a texture rather than a font change: the rows are fixed height, so growing the label on hover
---would reflow the line, and a colour set here would be overwritten by the next refresh a moment later.
---@param button table
local function AddHoverHighlight(button)
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
    local highlight = button:GetHighlightTexture()
    if highlight and highlight.SetColorTexture then
        highlight:SetColorTexture(HOVER_HIGHLIGHT_COLOR.r, HOVER_HIGHLIGHT_COLOR.g,
            HOVER_HIGHLIGHT_COLOR.b, HOVER_HIGHLIGHT_COLOR.a)
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
---@param reportRow ProfilerReportRow
---@return table? speciesColor @nil for one of Questie's own functions, the uncoloured baseline
local function SpeciesColor(reportRow)
    if reportRow.isFileLoad then
        return COLOR_FILE_LOAD
    elseif reportRow.isThreadJob then
        return COLOR_THREAD_JOB
    elseif reportRow.isLibrary then
        return COLOR_LIBRARY
    end
    return nil
end

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
        GameTooltip:AddDoubleLine("Average per job", _QuestieProfilerUI.FormatDuration(reportRow.averageTime),
            0.7, 0.7, 0.7, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Job time covers active resume slices only. Time spent suspended between resumes is excluded.",
            0.45, 0.8, 1, true)
        GameTooltip:AddLine("This row is the authoritative total for work spanning multiple resumes.", 0.45, 0.8, 1, true)
    elseif reportRow.hasCalls then
        GameTooltip:AddDoubleLine("Average per call", _QuestieProfilerUI.FormatDuration(reportRow.averageTime),
            0.7, 0.7, 0.7, 1, 1, 1)
    end

    -- The Share column is one number with no units, so the tooltip is where its denominator gets named. A
    -- percentage nobody can trace the bottom half of is worse than no percentage.
    if reportRow.share then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Share", FormatShare(reportRow.share), 0.7, 0.7, 0.7, 1, 1, 1)
        local basis
        if reportRow.isFileLoad then
            basis = sformat("of the %s ms of file load currently listed", FormatMilliseconds(reportRow.shareDenominator))
        elseif reportRow.isThreadJob then
            basis = sformat("of the %s ms of job time currently listed", FormatMilliseconds(reportRow.shareDenominator))
        else
            basis = sformat("of the %s ms of self time across the functions currently listed",
                FormatMilliseconds(reportRow.shareDenominator))
        end
        GameTooltip:AddLine(basis, 0.55, 0.55, 0.55, true)
    end

    if reportRow.calls > 0 and not reportRow.hasTiming then
        GameTooltip:AddLine(" ")
        -- Calls spanning ThreadLib yields are timed since cross-slice accumulation landed; what stays
        -- untimed is everything that never finishes inside a measured window.
        GameTooltip:AddLine("Counted but never timed: no call completed inside a measured window. A raw "
            .. "coroutine outside ThreadLib, an error unwinding past the wrapper, or a session boundary "
            .. "mid-call all leave a count with no elapsed time.", 0.55, 0.55, 0.55, true)
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

    -- Last, so it never pushes the measurements down the tooltip. Naming what the click produces beats a
    -- generic "more info": the payoff is the relations panel, which is not visible until you click.
    GameTooltip:AddLine("")
    GameTooltip:AddLine("Click for callers and callees.", 0.6, 0.6, 0.68, true)

    GameTooltip:Show()
end

---@param reportRow ProfilerReportRow
---@return string
local function DetailLineFor(reportRow)
    -- Calls and averages are function ideas; a file has one load and one allocation, and printing
    -- "0 calls | 0.000 ms avg" for it reads as a measurement of nothing.
    if reportRow.isFileLoad then
        return sformat("|  %.3f ms load  |  %s allocated",
            reportRow.totalTime, FormatKilobytes(reportRow.memoryKilobytes or 0))
    end

    local selfDetail = reportRow.hasSelfTime and sformat("%.3f ms self", reportRow.selfTime) or "no self time"
    -- The identity moved into the copy box beside this, so the line starts at the measurements. It keeps a
    -- leading separator so the strip still reads as one sentence across the seam between the two widgets.
    local detail = sformat("|  %.3f ms total  |  %s  |  %d calls  |  %s avg",
        reportRow.totalTime, selfDetail, reportRow.calls, _QuestieProfilerUI.FormatDuration(reportRow.averageTime))
    if reportRow.isThreadJob then
        detail = detail .. sformat("  |  %d jobs  |  %d resumes", reportRow.jobCalls or 0, reportRow.resumeCount or 0)
    end
    if reportRow.calls > 0 and not reportRow.hasTiming then
        detail = detail .. "  |  no timed slices"
    end
    return detail
end

-- The copy box may take at most this share of the strip, so a long identity cannot squeeze the measurements
-- out of the line. Past it the identity scrolls inside the box, and copying still yields the whole string.
local DETAIL_BOX_MAX_SHARE = 0.55

---Fills the selection strip: the identity into the box that can be selected, the measurements beside it.
---@param reportRow ProfilerReportRow?
function UpdateDetailStrip(reportRow)
    if not detailBox or not detailText then
        return
    end

    if not reportRow then
        if detailBox.copyText ~= nil then
            detailBox.copyText = nil
            detailBox:SetText("")
            detailBox:ClearFocus()
        end
        detailBox:SetWidth(1)
        detailBox:Hide()
        detailText:SetText("Click a row to pin its full identity here.")
        detailText:SetWidth(0)
        return
    end

    -- The same trimming the list shows. For a job named by its submission site that is already file:line,
    -- which is the form worth pasting; nothing else in a WoW client can produce a definition line.
    local copyText = DisplayNameFor(reportRow.lookupKey)

    -- This strip is rewritten twice a second while the session is live, and SetText drops whatever the user
    -- had selected. Rewriting a value that has not changed would therefore make the box impossible to copy
    -- from - the selection would survive for less than one tick. Only a genuinely new identity touches it.
    if detailBox.copyText ~= copyText then
        detailBox.copyText = copyText
        detailBox:SetText(copyText)
        detailBox:SetCursorPosition(0)
    end
    detailBox:Show()

    -- Width is safe to set every time: unlike SetText it does not disturb the selection, and recomputing it
    -- unconditionally is what keeps a resize correct without tracking the old width.
    local stripWidth = mmax(1, (baseFrame:GetWidth() or 0)
        - (EDGE_PADDING * 2) - TREE_PANE_WIDTH - TREE_PANE_GUTTER)
    detailBoxMeasure:SetText(copyText)
    local boxWidth = mmax(1, mmin(detailBoxMeasure:GetStringWidth() + 4, stripWidth * DETAIL_BOX_MAX_SHARE))
    detailBox:SetWidth(boxWidth)

    detailText:SetText(DetailLineFor(reportRow))
    detailText:SetWidth(mmax(1, stripWidth - boxWidth - 6))
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

    -- Below the heat bar, so a banded row still shows its cost rather than washing it out. `zebra` and
    -- `stripe` are different things: this bands the row, `stripe` marks its species.
    row.zebra = row:CreateTexture(nil, "BACKGROUND")
    row.zebra:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.zebra:SetDrawLayer("BACKGROUND", -1)
    row.zebra:SetAllPoints(row)
    if row.zebra.SetColorTexture then
        row.zebra:SetColorTexture(ROW_STRIPE_COLOR.r, ROW_STRIPE_COLOR.g, ROW_STRIPE_COLOR.b,
            ROW_STRIPE_COLOR.a)
    else
        row.zebra:SetVertexColor(ROW_STRIPE_COLOR.r, ROW_STRIPE_COLOR.g, ROW_STRIPE_COLOR.b,
            ROW_STRIPE_COLOR.a)
    end
    row.zebra:Hide()

    row.heat = row:CreateTexture(nil, "BACKGROUND")
    row.heat:SetTexture("Interface\\Buttons\\WHITE8X8")

    row.stripe = row:CreateTexture(nil, "ARTWORK")
    row.stripe:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.stripe:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.stripe:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    row.stripe:SetWidth(ACCENT_STRIPE_WIDTH)

    row.selection = row:CreateTexture(nil, "BORDER")
    row.selection:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.selection:SetAllPoints(row)
    if row.selection.SetColorTexture then
        row.selection:SetColorTexture(SELECTION_HIGHLIGHT_COLOR.r, SELECTION_HIGHLIGHT_COLOR.g,
            SELECTION_HIGHLIGHT_COLOR.b, SELECTION_HIGHLIGHT_COLOR.a)
    else
        row.selection:SetVertexColor(SELECTION_HIGHLIGHT_COLOR.r, SELECTION_HIGHLIGHT_COLOR.g,
            SELECTION_HIGHLIGHT_COLOR.b, SELECTION_HIGHLIGHT_COLOR.a)
    end
    row.selection:Hide()

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(ROW_ICON_SIZE, ROW_ICON_SIZE)
    row.icon:SetPoint("LEFT", row, "LEFT", ACCENT_STRIPE_WIDTH + 3, 0)
    row.icon:SetDesaturated(true)

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.nameText:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    row.nameText:SetJustifyH("LEFT")
    DisableWrapping(row.nameText)

    row.total = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.total:SetJustifyH("RIGHT")
    row.total:SetWidth(COLUMN_WIDTHS.total)

    row.selfTime = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.selfTime:SetJustifyH("RIGHT")
    row.selfTime:SetWidth(COLUMN_WIDTHS.self)

    row.calls = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.calls:SetJustifyH("RIGHT")
    row.calls:SetWidth(COLUMN_WIDTHS.calls)

    row.average = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.average:SetJustifyH("RIGHT")
    row.average:SetWidth(COLUMN_WIDTHS.average)

    row.memory = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.memory:SetJustifyH("RIGHT")
    row.memory:SetWidth(COLUMN_WIDTHS.memory)

    AddHoverHighlight(row)
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
        ApplySelection()
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

    local visible = VisibleColumns()
    local columns = {
        {key = SORT_MEMORY, fontString = row.memory, width = COLUMN_WIDTHS.memory},
        {key = SORT_AVERAGE, fontString = row.average, width = COLUMN_WIDTHS.average},
        {key = SORT_CALLS, fontString = row.calls, width = COLUMN_WIDTHS.calls},
        {key = SORT_SELF, fontString = row.selfTime, width = COLUMN_WIDTHS.self},
        {key = SORT_TOTAL, fontString = row.total, width = COLUMN_WIDTHS.total},
    }

    -- Anchored right to left so a hidden column simply closes the gap instead of leaving a hole.
    local previous
    local numericWidth = 0
    for _, column in ipairs(columns) do
        column.fontString:ClearAllPoints()
        if visible[column.key] then
            if previous then
                column.fontString:SetPoint("RIGHT", previous, "LEFT", -COLUMN_GAP, 0)
            else
                column.fontString:SetPoint("RIGHT", row, "RIGHT", -COLUMN_GAP, 0)
            end
            column.fontString:Show()
            previous = column.fontString
            numericWidth = numericWidth + column.width + COLUMN_GAP
        else
            column.fontString:Hide()
        end
    end

    row.nameText:SetWidth(mmax(40,
        listWidth - numericWidth - COLUMN_GAP - ACCENT_STRIPE_WIDTH - ROW_ICON_SIZE - 7))

    -- The heat bar lives in the numeric band and never reaches the name. Anchored at the band's left edge so
    -- it grows rightward, which is the direction length is read in. The band is mostly whitespace - five
    -- right-aligned short numbers - so a tint there covers far less ink than it did behind a long name.
    row.heatBandWidth = numericWidth
    row.heat:ClearAllPoints()
    row.heat:SetPoint("TOPLEFT", row, "TOPLEFT", listWidth - numericWidth, 0)
    row.heat:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", listWidth - numericWidth, 0)
end

local function ClearHierarchyScope()
    displayState.scopePrefix = ""
    displayState.scopeLabel = ""
    displayState.scrollOffset = 0
end

---@param index integer
---@return table treeRow
local function AcquireTreeRow(index)
    local treeRow = treeRowPool[index]
    if treeRow then
        return treeRow
    end

    treeRow = CreateFrame("Button", nil, treeFrame)
    treeRow:SetHeight(TREE_ROW_HEIGHT)
    treeRow:SetPoint("LEFT", treeFrame, "LEFT", 0, 0)
    treeRow:SetPoint("RIGHT", treeFrame, "RIGHT", -(TREE_SCROLL_WIDTH + 2), 0)

    treeRow.highlight = treeRow:CreateTexture(nil, "BACKGROUND")
    treeRow.highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
    treeRow.highlight:SetAllPoints(treeRow)
    if treeRow.highlight.SetColorTexture then
        treeRow.highlight:SetColorTexture(SELECTION_HIGHLIGHT_COLOR.r, SELECTION_HIGHLIGHT_COLOR.g,
            SELECTION_HIGHLIGHT_COLOR.b, SELECTION_HIGHLIGHT_COLOR.a)
    end
    treeRow.highlight:Hide()

    -- Separate hit area: the arrow opens the node, the label scopes the list. Merging them would make
    -- browsing the hierarchy impossible without also changing what the list shows.
    treeRow.toggle = CreateFrame("Button", nil, treeRow)
    treeRow.toggle:SetSize(TREE_ROW_HEIGHT, TREE_ROW_HEIGHT)

    treeRow.arrow = treeRow.toggle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    treeRow.arrow:SetPoint("CENTER", treeRow.toggle, "CENTER", 0, 0)

    treeRow.label = treeRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    treeRow.label:SetJustifyH("LEFT")
    DisableWrapping(treeRow.label)

    treeRow.value = treeRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    treeRow.value:SetJustifyH("RIGHT")
    treeRow.value:SetPoint("RIGHT", treeRow, "RIGHT", -4, 0)
    treeRow.value:SetWidth(58)

    AddHoverHighlight(treeRow)
    treeRow:SetScript("OnEnter", function(self)
        if not self.prefix then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        -- The pane is narrow, so the label on screen is usually truncated. The full path is the point.
        GameTooltip:AddLine(self.prefix, 1, 0.82, 0, true)
        GameTooltip:AddLine("")
        GameTooltip:AddLine(self.rollupSummary, 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("")
        GameTooltip:AddLine("Click to filter the list to this.", 0.6, 0.6, 0.68, true)
        if self.hasChildren then
            GameTooltip:AddLine("Click the arrow to expand it instead.", 0.6, 0.6, 0.68, true)
        end
        GameTooltip:Show()
    end)
    treeRow:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    treeRow.toggle:SetScript("OnClick", function(self)
        local prefix = self:GetParent().prefix
        if not prefix then
            return
        end
        displayState.expandedPrefixes[prefix] = not displayState.expandedPrefixes[prefix] or nil
        RenderTree()
    end)

    treeRow:SetScript("OnClick", function(self)
        if not self.prefix then
            return
        end
        -- Clicking the node already in scope steps back out, so the control is its own undo.
        if displayState.scopePrefix == self.prefix then
            ClearHierarchyScope()
        else
            displayState.scopePrefix = self.prefix
            displayState.scopeLabel = self.prefix
            displayState.expandedPrefixes[self.prefix] = true
            displayState.scrollOffset = 0
        end
        QuestieProfilerUI:Refresh()
    end)

    treeRowPool[index] = treeRow
    return treeRow
end

function RenderTree()
    if not treeFrame or not currentTree then
        return
    end

    if not displayState.treeVisible then
        treeFrame:Hide()
        return
    end
    treeFrame:Show()

    local lines = _QuestieProfilerUI.FlattenTree(currentTree, displayState.expandedPrefixes)
    local visibleCount = mmax(0, mfloor((treeFrame:GetHeight() or 0) / TREE_ROW_HEIGHT))
    local maxOffset = mmax(0, #lines - visibleCount)
    if displayState.treeScrollOffset > maxOffset then
        displayState.treeScrollOffset = maxOffset
    end

    for index = 1, visibleCount do
        local treeRow = AcquireTreeRow(index)
        treeRow:ClearAllPoints()
        treeRow:SetPoint("TOPLEFT", treeFrame, "TOPLEFT", 0, -(index - 1) * TREE_ROW_HEIGHT)
        treeRow:SetPoint("TOPRIGHT", treeFrame, "TOPRIGHT",
            -(TREE_SCROLL_WIDTH + 2), -(index - 1) * TREE_ROW_HEIGHT)

        local line = lines[index + displayState.treeScrollOffset]
        if not line then
            treeRow:Hide()
        else
            treeRow:Show()
            treeRow.prefix = line.node.prefix
            treeRow.hasChildren = line.hasChildren
            treeRow.rollupSummary = sformat("%s ms rolled up from everything beneath it: "
                .. "function self time plus file and job totals.",
                FormatMilliseconds(line.node.cost))

            local indent = line.depth * TREE_INDENT
            treeRow.toggle:ClearAllPoints()
            treeRow.toggle:SetPoint("LEFT", treeRow, "LEFT", indent, 0)
            treeRow.arrow:SetText(line.hasChildren
                and (displayState.expandedPrefixes[line.node.prefix] and "-" or "+") or "")

            treeRow.label:ClearAllPoints()
            treeRow.label:SetPoint("LEFT", treeRow.toggle, "RIGHT", 0, 0)
            treeRow.label:SetPoint("RIGHT", treeRow.value, "LEFT", -4, 0)
            treeRow.label:SetText(line.node.label)

            treeRow.value:SetText(FormatMilliseconds(line.node.cost))

            local isScoped = displayState.scopePrefix == line.node.prefix
            if isScoped then
                treeRow.highlight:Show()
                treeRow.label:SetTextColor(COLOR_SORTED_VALUE.r, COLOR_SORTED_VALUE.g, COLOR_SORTED_VALUE.b)
            else
                treeRow.highlight:Hide()
                treeRow.label:SetTextColor(COLOR_TEXT.r, COLOR_TEXT.g, COLOR_TEXT.b)
            end
            treeRow.value:SetTextColor(0.65, 0.65, 0.7)
        end
    end

    for index = visibleCount + 1, #treeRowPool do
        treeRowPool[index]:Hide()
    end

    if treeScrollTrack and treeScrollThumb then
        local trackHeight = treeFrame:GetHeight() or 0
        if #lines <= visibleCount or trackHeight <= 0 then
            treeScrollTrack:Hide()
            treeScrollThumb:Hide()
        else
            treeScrollTrack:Show()
            treeScrollThumb:Show()
            local thumbHeight = mmax(12, trackHeight * (visibleCount / #lines))
            local progress = maxOffset > 0 and (displayState.treeScrollOffset / maxOffset) or 0
            treeScrollThumb:SetHeight(thumbHeight)
            treeScrollThumb:ClearAllPoints()
            treeScrollThumb:SetPoint("TOPRIGHT", treeFrame, "TOPRIGHT", 0, -progress * (trackHeight - thumbHeight))
        end
    end

    if treeScopeText then
        -- No "Scope:" label: the two states already read as different kinds of thing - an instruction when
        -- nothing is scoped, a path when something is - and brightness says which is live. Naming it cost the
        -- width the path itself needs, which is how a long scope ended up truncated.
        if displayState.scopePrefix ~= "" then
            treeScopeButton:Enable()
            treeScopeText:SetText(displayState.scopeLabel .. "   (click to clear)")
            treeScopeText:SetTextColor(SCOPE_ACTIVE_COLOR.r, SCOPE_ACTIVE_COLOR.g, SCOPE_ACTIVE_COLOR.b)
        else
            treeScopeButton:Disable()
            treeScopeText:SetText("Click a node to narrow the list")
            treeScopeText:SetTextColor(SCOPE_HINT_COLOR.r, SCOPE_HINT_COLOR.g, SCOPE_HINT_COLOR.b)
        end
    end
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

            -- Banded by position in the data, not in the pool, so the bands travel with the rows as the list
            -- scrolls instead of strobing under them.
            if (index + displayState.scrollOffset) % 2 == 0 then
                row.zebra:Show()
            else
                row.zebra:Hide()
            end

            local share = HeatShare(reportRow, currentReport, displayState.sortKey)
            local band = HeatBand(share)
            row.heat:SetWidth(mmax(1, share * (row.heatBandWidth or 0)))
            if row.heat.SetColorTexture then
                row.heat:SetColorTexture(band.r, band.g, band.b, band.a)
            else
                row.heat:SetVertexColor(band.r, band.g, band.b, band.a)
            end

            -- Hidden, not removed: the slot still holds the name's left edge, so the icon reads as a mark on
            -- the rows that carry one rather than as a column that is mostly empty.
            if reportRow.isFileLoad then
                row.icon:SetTexture(ICON_FILE_LOAD)
                row.icon:Show()
            elseif reportRow.isThreadJob then
                row.icon:SetTexture(ICON_THREAD_JOB)
                row.icon:Show()
            else
                row.icon:Hide()
            end

            local speciesColor = SpeciesColor(reportRow)
            if speciesColor then
                if row.stripe.SetColorTexture then
                    row.stripe:SetColorTexture(speciesColor.r, speciesColor.g, speciesColor.b, 0.9)
                else
                    row.stripe:SetVertexColor(speciesColor.r, speciesColor.g, speciesColor.b, 0.9)
                end
                row.stripe:Show()
            else
                row.stripe:Hide()
            end

            local nameColor = speciesColor or COLOR_TEXT
            local brightness = (reportRow.hasCalls and reportRow.calls == 0) and NEVER_CALLED_DIM or 1
            row.nameText:SetText(reportRow.displayName)
            row.nameText:SetTextColor(nameColor.r * brightness, nameColor.g * brightness, nameColor.b * brightness)

            -- Counted-but-never-timed entries must not read as free work, so they show a dash instead of 0.00.
            if reportRow.hasTiming then
                row.total:SetText(FormatMilliseconds(reportRow.totalTime))
                -- No calls means no per-call average; a loaded file would otherwise read as averaging zero.
                row.average:SetText(reportRow.hasCalls and _QuestieProfilerUI.FormatDuration(reportRow.averageTime) or "-")
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
            if reportRow.memoryKilobytes then
                row.memory:SetText(FormatKilobytes(reportRow.memoryKilobytes))
                row.memory:SetTextColor(COLOR_TEXT.r, COLOR_TEXT.g, COLOR_TEXT.b)
            else
                row.memory:SetText("-")
                row.memory:SetTextColor(COLOR_UNTIMED.r, COLOR_UNTIMED.g, COLOR_UNTIMED.b)
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
                or (displayState.sortKey == SORT_MEMORY and row.memory)
                or (displayState.sortKey == SORT_TOTAL and row.total)
                or nil
            if sortedColumn then
                sortedColumn:SetTextColor(COLOR_SORTED_VALUE.r, COLOR_SORTED_VALUE.g, COLOR_SORTED_VALUE.b)
            end

            if displayState.selectedKey == reportRow.lookupKey then
                row.selection:Show()
            else
                row.selection:Hide()
            end
        end
    end

    for index = visibleRowCount + 1, #rowPool do
        rowPool[index]:Hide()
        rowPool[index].reportRow = nil
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
        local isHovered = header.sortKey == hoveredColumnKey
        local arrow = ""
        if isSorted then
            arrow = displayState.descending and " v" or " ^"
        elseif isHovered then
            -- The sort a click would produce, not one that is in effect: a column the list is not sorted by
            -- goes descending, except the name, which reads better alphabetically. Showing it under the mouse
            -- is how a header admits it is sortable before anyone has risked a click to find out.
            arrow = header.sortKey ~= SORT_NAME and " v" or " ^"
        end
        header:SetText(header.label .. arrow)

        local fontString = header:GetFontString()
        if fontString then
            if isSorted then
                fontString:SetTextColor(COLOR_SORTED_VALUE.r, COLOR_SORTED_VALUE.g, COLOR_SORTED_VALUE.b)
            elseif isHovered then
                -- Brighter than resting, dimmer than sorted: the arrow is a preview, not a state.
                fontString:SetTextColor(COLOR_TEXT.r, COLOR_TEXT.g, COLOR_TEXT.b)
            else
                fontString:SetTextColor(0.7, 0.7, 0.7)
            end
        end
    end
end

---Groups the totals the way the control row groups its buttons: pipes inside a species, a wide gap between
---them. The old single run of pipes gave a session state, a view state and a measurement equal weight.
---@param totals ProfilerSessionTotals
---@return string
local function SummaryLine(totals)
    return sformat(
        "Files %d | %s ms | %s        Functions %d | %s calls | %s ms self        Jobs %d | %s ms",
        totals.fileCount,
        FormatMilliseconds(totals.fileTime),
        FormatKilobytes(totals.fileMemory),
        totals.functionCount,
        FormatCount(totals.functionCalls),
        FormatMilliseconds(totals.functionSelfTime),
        totals.jobCount,
        FormatMilliseconds(totals.jobTime))
end

local function UpdateStatus()
    if not statusText or not currentReport then
        return
    end

    if summaryText then
        summaryText:SetText(SummaryLine(_QuestieProfilerUI.BuildSessionTotals(QuestieProfiler)))
    end

    -- What is left here is state, not measurement: what the session is doing and what the view is showing.
    local sessionState = QuestieProfiler.active and "ACTIVE" or "STOPPED"
    local displayStateLabel = displayState.frozen and "FROZEN" or (QuestieProfiler.active and "LIVE" or "STATIC")
    local status = sformat("%s | %s | %d/%d shown | sort %s",
        sessionState,
        displayStateLabel,
        currentReport.matchedCount,
        currentReport.totalCount,
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
    if isActive then
        SetControlTooltip(sessionButton, "Stop profiling",
            "Stops collecting and removes the hooks.",
            "Questie runs at full speed again.",
            "",
            "Everything measured stays on screen and stays browsable.")
    else
        SetControlTooltip(sessionButton, "Start profiling",
            "Begins a fresh session and reinstalls the hooks.",
            "",
            "Function and job results are cleared - they belong to the session that just ended.",
            "Addon load rows are kept, but unticked.",
            "",
            "To measure one interaction without losing what is on screen, use Reset instead.")
    end

    -- Enable/Disable rather than SetEnabled: it is the spelling present on every supported client.
    if isActive then
        resetButton:Enable()
    else
        resetButton:Disable()
    end

    freezeButton:SetText(displayState.frozen and "Unfreeze" or "Freeze")
    if displayState.frozen then
        SetControlTooltip(freezeButton, "Unfreeze the view",
            "Resumes automatic updates twice a second.")
    else
        SetControlTooltip(freezeButton, "Freeze the view",
            "Holds the list still so it can be read.",
            "",
            "Profiling carries on underneath. Nothing is lost -",
            "only the display stops changing.")
    end

    -- Manual refresh only means anything while the automatic one is switched off.
    if displayState.frozen then
        refreshButton:Show()
    else
        refreshButton:Hide()
    end

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

    if startupCheckButton then
        startupCheckButton:SetChecked(QuestieProfilerEnabled == true)
    end

    local counts = currentReport and currentReport.speciesCounts or {}
    for _, checkButton in ipairs(speciesCheckButtons) do
        local spec = checkButton.spec
        checkButton:SetChecked(displayState[spec.key] == true)
        checkButton.label:SetText(sformat("%s (%s)", spec.label, FormatCount(counts[spec.countKey] or 0)))
        SetControlTooltip(checkButton, spec.label,
            spec.description,
            "",
            sformat("%s in this session.", FormatCount(counts[spec.countKey] or 0)))
    end

    if neverCalledCheckButton then
        neverCalledCheckButton:SetChecked(not displayState.hideIdle)
        neverCalledCheckButton.label:SetText(sformat("Never called (%s)",
            FormatCount(currentReport and currentReport.idleCount or 0)))
    end

    LayoutColumnHeaders()
    UpdateColumnHeaders()
end

-------------------------
-- Refresh lifecycle
-------------------------
-- Refresh is display work only. It never mutates a profiler table, so freezing, sorting and browsing cannot
-- change what is being measured.
function QuestieProfilerUI:Refresh()
    -- Tree prefixes use a species-specific separator. If that species disappears, keeping its scope would
    -- filter every remaining row while also removing the selected node that normally clears the scope.
    local scopePrefix = displayState.scopePrefix
    if scopePrefix ~= "" then
        local jobScopePrefix = THREAD_JOB_TREE_LABEL .. " "
        local scopeSpeciesIsVisible
        if ssub(scopePrefix, 1, string.len(jobScopePrefix)) == jobScopePrefix then
            scopeSpeciesIsVisible = displayState.showJobs
        elseif ssub(scopePrefix, -1) == "/" then
            scopeSpeciesIsVisible = displayState.showFiles
        else
            scopeSpeciesIsVisible = displayState.showFunctions
        end
        if not scopeSpeciesIsVisible then
            ClearHierarchyScope()
        end
    end

    -- A species filter can remove the column that owns the active sort. Do not retain an invisible metric
    -- that gives every remaining row the same value and quietly leaves the list ordered by name instead.
    if not VisibleColumns()[displayState.sortKey] then
        displayState.sortKey = SORT_TOTAL
        displayState.descending = true
    end

    ---@type ProfilerReportSource
    local source = QuestieProfiler
    currentReport = _QuestieProfilerUI.BuildReport(source, {
        filter = displayState.filter,
        grouped = displayState.grouped,
        hideIdle = displayState.hideIdle,
        scopePrefix = displayState.scopePrefix,
        showFunctions = displayState.showFunctions,
        showJobs = displayState.showJobs,
        showFiles = displayState.showFiles,
        sortKey = displayState.sortKey,
        descending = displayState.descending,
    })
    -- Built from the report before scoping would hide the rest of the hierarchy, so the tree stays a map of
    -- the whole session rather than collapsing to whatever is currently selected.
    ---@type ProfilerReportSource
    local treeSource = QuestieProfiler
    currentUnscopedRows = _QuestieProfilerUI.BuildReport(treeSource, {
        filter = displayState.filter,
        grouped = displayState.grouped,
        hideIdle = displayState.hideIdle,
        showFunctions = displayState.showFunctions,
        showJobs = displayState.showJobs,
        showFiles = displayState.showFiles,
    }).rows
    currentTree = _QuestieProfilerUI.BuildTree(currentUnscopedRows)

    ApplySelection()
    RenderRows()
    RenderTree()
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
---Gives a control a tooltip. Each argument after the title is its own line: one wrapped paragraph forces the
---reader to parse a sentence to find the one clause they care about, where separate lines can be scanned.
---An empty string is a spacer. Calling this again on the same control rewrites the text, which is how a
---control whose meaning changes with state keeps its tooltip honest.
---@param control table
---@param title string
---@param ... string
function SetControlTooltip(control, title, ...)
    control.tooltipTitle = title
    control.tooltipLines = {...}

    if control.tooltipHooked then
        return
    end
    control.tooltipHooked = true

    control:SetScript("OnEnter", function(self)
        -- Every control that carries a tooltip sits above the lists, so one that grows downwards covers the
        -- data it is explaining. Anchored by hand rather than with an ANCHOR_TOP* constant so the direction
        -- is not open to interpretation: the tooltip's bottom edge rests on the control's top edge.
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, CONTROL_TOOLTIP_GAP)
        GameTooltip:AddLine(self.tooltipTitle, 1, 0.82, 0)
        for _, line in ipairs(self.tooltipLines) do
            GameTooltip:AddLine(line, 0.8, 0.8, 0.8, true)
        end
        GameTooltip:Show()
    end)
    control:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

---@param parent table
---@param text string
---@param width number
---@return table button
local function CreateControlButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or CONTROL_BUTTON_WIDTH, CONTROL_BUTTON_HEIGHT)
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
    -- The last holdout of Blizzard's listbox glow, which every other clickable thing here stopped using.
    AddHoverHighlight(header)
    header:SetScript("OnClick", function(self)
        ApplySort(self.sortKey)
    end)
    header:SetScript("OnEnter", function(self)
        hoveredColumnKey = self.sortKey
        UpdateColumnHeaders()
    end)
    header:SetScript("OnLeave", function(self)
        -- Only the header that recorded itself may clear it. Sliding between two adjacent headers can deliver
        -- the new one's OnEnter before the old one's OnLeave, and an unconditional clear would then blank the
        -- arrow on the header the mouse is actually sitting on.
        if hoveredColumnKey == self.sortKey then
            hoveredColumnKey = nil
        end
        UpdateColumnHeaders()
    end)
    tinsert(columnHeaders, header)
    return header
end

local function BuildTitleBar()
    -- The footer band, mirrored. Rule on the bottom edge here rather than the top, so both bands close the
    -- window off towards the content between them.
    local headerBand = baseFrame:CreateTexture(nil, "BACKGROUND")
    headerBand:SetTexture("Interface\\Buttons\\WHITE8X8")
    headerBand:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", 1, -1)
    headerBand:SetPoint("TOPRIGHT", baseFrame, "TOPRIGHT", -1, -1)
    headerBand:SetHeight(HEADER_BAND_HEIGHT)
    if headerBand.SetColorTexture then
        headerBand:SetColorTexture(CHROME_BAND_COLOR.r, CHROME_BAND_COLOR.g, CHROME_BAND_COLOR.b,
            CHROME_BAND_COLOR.a)
    end

    local headerRule = baseFrame:CreateTexture(nil, "ARTWORK")
    headerRule:SetTexture("Interface\\Buttons\\WHITE8X8")
    headerRule:SetHeight(1)
    headerRule:SetPoint("TOPLEFT", headerBand, "BOTTOMLEFT", 0, 0)
    headerRule:SetPoint("TOPRIGHT", headerBand, "BOTTOMRIGHT", 0, 0)
    if headerRule.SetColorTexture then
        headerRule:SetColorTexture(DIVIDER_COLOR.r, DIVIDER_COLOR.g, DIVIDER_COLOR.b, DIVIDER_COLOR.a)
    end

    -- Spans the whole band, not just the space between the paddings: a strip that looks like a title bar
    -- should be draggable everywhere it looks draggable.
    local titleBar = CreateFrame("Frame", nil, baseFrame)
    titleBar:SetPoint("TOPLEFT", headerBand, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", headerBand, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(HEADER_BAND_HEIGHT)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        baseFrame:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        baseFrame:StopMovingOrSizing()
    end)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleBar, "LEFT", EDGE_PADDING - 1, 0)
    title:SetText("Questie Profiler")

    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetSize(24, 24)
    -- The template's art carries its own padding, so the button sits closer to the edge than its box does.
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -3, 0)
    closeButton:SetScript("OnClick", function()
        QuestieProfilerUI:Hide()
    end)

    displayChip = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    displayChip:SetPoint("RIGHT", closeButton, "LEFT", -6, 0)

    sessionChip = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sessionChip:SetPoint("RIGHT", displayChip, "LEFT", -8, 0)
end

---A fresh measurement puts every function and job back to zero while the addon-load rows keep their full
---cost, so leaving files listed buries what is being measured under 244 rows that did not change. The rows
---are kept and the checkbox still carries its count, so one click brings them back.
local function HideFilesAfterMeasurementReset()
    -- A files-only view is not about to become misleading, and emptying it would be worse than leaving it.
    if not displayState.showFunctions and not displayState.showJobs then
        return
    end
    displayState.showFiles = false
end

-- Two groups, named. Stop and Reset change what is being collected; Freeze changes only what is drawn. The
-- window already names those two domains in the title bar chips, so the captions label the controls with the
-- same words as the state they act on.
local function BuildControlRow()
    local controlTop = -(CONTENT_TOP)

    local sessionCaption = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sessionCaption:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", EDGE_PADDING, controlTop - 5)
    sessionCaption:SetText("Session")
    sessionCaption:SetTextColor(0.62, 0.62, 0.68)

    sessionButton = CreateControlButton(baseFrame, "Stop")
    sessionButton:SetPoint("LEFT", sessionCaption, "RIGHT", 6, 0)
    sessionButton:SetScript("OnClick", function()
        if QuestieProfiler.active then
            QuestieProfiler:Stop()
        else
            -- Start(true) keeps this window on screen; the engine re-asserts visibility through ShowUI.
            -- A rejected start retains the stopped report and its view exactly as the user left them.
            if QuestieProfiler:Start(true) then
                displayState.frozen = false
                displayState.scrollOffset = 0
                HideFilesAfterMeasurementReset()
            end
        end
        UpdateTickerState()
        QuestieProfilerUI:Refresh()
    end)
    SetControlTooltip(sessionButton, "Stop profiling", "")  -- rewritten by UpdateControls to match the state

    resetButton = CreateControlButton(baseFrame, "Reset")
    resetButton:SetPoint("LEFT", sessionButton, "RIGHT", CONTROL_BUTTON_GAP, 0)
    resetButton:SetScript("OnClick", function()
        QuestieProfiler:ResetMeasurements()
        HideFilesAfterMeasurementReset()
        displayState.scrollOffset = 0
        QuestieProfilerUI:Refresh()
    end)
    SetControlTooltip(resetButton, "Reset counters",
        "Zeroes every time and call count.",
        "Measuring continues from now.",
        "",
        "The session keeps running and no hooks are touched.",
        "",
        "Addon load rows are kept, but unticked - they would",
        "otherwise sit above everything you are about to measure.")

    local viewCaption = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    viewCaption:SetPoint("LEFT", resetButton, "RIGHT", CONTROL_GROUP_GAP, 0)
    viewCaption:SetText("View")
    viewCaption:SetTextColor(0.62, 0.62, 0.68)

    freezeButton = CreateControlButton(baseFrame, "Freeze")
    freezeButton:SetPoint("LEFT", viewCaption, "RIGHT", 6, 0)
    freezeButton:SetScript("OnClick", function()
        displayState.frozen = not displayState.frozen
        UpdateTickerState()
        QuestieProfilerUI:Refresh()
    end)
    SetControlTooltip(freezeButton, "Freeze the view", "")  -- rewritten by UpdateControls to match the state

    -- Only reachable while frozen: unfrozen, the ticker already redraws twice a second, so a manual refresh
    -- would do nothing a wait of half a second does not.
    refreshButton = CreateControlButton(baseFrame, "Refresh")
    refreshButton:SetPoint("LEFT", freezeButton, "RIGHT", CONTROL_BUTTON_GAP, 0)
    refreshButton:SetScript("OnClick", function()
        QuestieProfilerUI:Refresh()
    end)
    SetControlTooltip(refreshButton, "Refresh once",
        "Takes a fresh reading, then holds it again.",
        "",
        "Only shown while frozen: unfrozen, the view already",
        "redraws twice a second.")
    refreshButton:Hide()

    -- Anchored to the far edge, away from Stop and Reset: this is the one control in the window that throws
    -- the session away, and it sits beside the setting whose change it is needed to apply.
    reloadButton = CreateControlButton(baseFrame, "Reload UI")
    reloadButton:SetPoint("TOPRIGHT", baseFrame, "TOPRIGHT", -EDGE_PADDING, controlTop)
    reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
    SetControlTooltip(reloadButton, "Reload the interface",
        "Reloads immediately, with no confirmation.",
        "",
        "Discards the current session.",
        "Needed to apply the startup setting beside it.")

    startupCheckButton = CreateFrame("CheckButton", nil, baseFrame, "UICheckButtonTemplate")
    startupCheckButton:SetSize(20, 20)
    startupCheckButton:SetPoint("RIGHT", reloadButton, "LEFT", -6, 0)
    startupCheckButton:SetScript("OnClick", function(self)
        -- Read at load by Questie.lua, so the change lands on the next reload rather than now. Saying so
        -- beats letting the profiler look like it ignored the click.
        QuestieProfilerEnabled = self:GetChecked() and true or false
        Questie:Print(QuestieProfilerEnabled
            and "Questie profiler will start on |cff40dd40next reload|r."
            or "Questie profiler will |cffdd4040not|r start on next reload.")
    end)
    SetControlTooltip(startupCheckButton, "Profile on startup",
        "Arms the profiler while Questie loads.",
        "",
        "The only way to measure addon file load and initialisation.",
        "Costs a little speed on every startup while it is on.",
        "",
        "Takes effect on the next reload.")

    local startupLabel = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    startupLabel:SetPoint("RIGHT", startupCheckButton, "LEFT", -2, 0)
    startupLabel:SetText("Profile on startup")
    startupLabel:SetTextColor(0.75, 0.75, 0.8)
end

-- Checkboxes rather than tabs: the useful comparisons are across species, such as a job beside the work it
-- schedules, and an exclusive control would forbid exactly those.
local SPECIES_CHECKBOXES = {
    {key = "showFunctions", label = "Functions", countKey = "functions", icon = ICON_FUNCTION,
        color = COLOR_TEXT,
        description = "Hooked Questie functions, timed per call."},
    {key = "showJobs", label = "Jobs", countKey = "jobs", icon = ICON_THREAD_JOB,
        color = COLOR_THREAD_JOB,
        description = "ThreadLib coroutine jobs, timed across their resume slices."},
    {key = "showFiles", label = "Files", countKey = "files", icon = ICON_FILE_LOAD,
        color = COLOR_FILE_LOAD,
        description = "Addon files, timed while Questie loaded."},
}

---@param anchorTo table
---@param anchorGap number
---@return table checkButton
local function CreateVisibilityCheckButton(anchorTo, anchorGap, iconTexture)
    local checkButton = CreateFrame("CheckButton", nil, baseFrame, "UICheckButtonTemplate")
    checkButton:SetSize(18, 18)
    checkButton:SetPoint("LEFT", anchorTo, "RIGHT", anchorGap, 0)

    local label = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetTextColor(0.85, 0.85, 0.85)
    checkButton.label = label

    if iconTexture then
        local icon = baseFrame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(ROW_ICON_SIZE, ROW_ICON_SIZE)
        icon:SetPoint("LEFT", checkButton, "RIGHT", 2, 0)
        icon:SetTexture(iconTexture)
        icon:SetDesaturated(true)
        label:SetPoint("LEFT", icon, "RIGHT", 3, 0)
    else
        label:SetPoint("LEFT", checkButton, "RIGHT", 3, 0)
    end

    return checkButton
end

-- One row of visibility filters, all the same kind of control: which species to list, and whether to list the
-- entries that were never called. The idle filter used to be a lone text-toggle button, which made a filter
-- look like an action.
local function BuildShowRow()
    local showTop = -(CONTENT_TOP + CONTROL_ROW_HEIGHT)

    local showCaption = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    showCaption:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", EDGE_PADDING, showTop - 5)
    showCaption:SetText("Show")
    showCaption:SetTextColor(0.62, 0.62, 0.68)

    local previous = showCaption
    local previousGap = 6
    for _, spec in ipairs(SPECIES_CHECKBOXES) do
        local checkButton = CreateVisibilityCheckButton(previous, previousGap, spec.icon)
        checkButton.spec = spec
        -- Each label wears exactly what its rows wear, so the filter row doubles as the legend and the
        -- mapping is learned from the control rather than inferred from the list.
        checkButton.label:SetTextColor(spec.color.r, spec.color.g, spec.color.b)
        checkButton:SetScript("OnClick", function(self)
            displayState[spec.key] = self:GetChecked() and true or false
            displayState.scrollOffset = 0
            QuestieProfilerUI:Refresh()
        end)
        SetControlTooltip(checkButton, spec.label, "")  -- rewritten by UpdateControls with the live count

        speciesCheckButtons[#speciesCheckButtons + 1] = checkButton
        previous = checkButton.label
        previousGap = 12
    end

    neverCalledCheckButton = CreateVisibilityCheckButton(previous, previousGap, nil)
    -- Dimmed to match the rows it reveals, which is the whole of what it does.
    neverCalledCheckButton.label:SetTextColor(
        COLOR_TEXT.r * NEVER_CALLED_DIM, COLOR_TEXT.g * NEVER_CALLED_DIM, COLOR_TEXT.b * NEVER_CALLED_DIM)
    neverCalledCheckButton:SetScript("OnClick", function(self)
        displayState.hideIdle = not self:GetChecked()
        displayState.scrollOffset = 0
        QuestieProfilerUI:Refresh()
    end)
    SetControlTooltip(neverCalledCheckButton, "Never called",
        "Functions that were hooked but never ran this session.",
        "",
        "Hidden by default: they usually outnumber everything",
        "else and carry no measurement.")

    local searchLabel = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetPoint("LEFT", neverCalledCheckButton.label, "RIGHT", CONTROL_GROUP_GAP, 0)
    searchLabel:SetText("Search")

    searchBox = CreateFrame("EditBox", nil, baseFrame, "InputBoxTemplate")
    searchBox:SetHeight(18)
    -- Left-anchored to the filters and right-anchored to the frame, so a narrow window squeezes the box
    -- rather than letting the controls collide.
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
    local headerTop = -(CONTENT_TOP + CONTROL_ROW_HEIGHT + FILTER_ROW_HEIGHT)

    local specs = {
        {key = SORT_MEMORY, label = "Allocated", width = COLUMN_WIDTHS.memory},
        {key = SORT_AVERAGE, label = "Avg", width = COLUMN_WIDTHS.average},
        {key = SORT_CALLS, label = "Calls", width = COLUMN_WIDTHS.calls},
        {key = SORT_SELF, label = "Self ms", width = COLUMN_WIDTHS.self},
        {key = SORT_TOTAL, label = "Total ms", width = COLUMN_WIDTHS.total},
    }

    for _, spec in ipairs(specs) do
        local header = CreateColumnHeader(baseFrame, spec.label, spec.key)
        header:SetWidth(spec.width)
        header.headerTop = headerTop
        columnHeadersByKey[spec.key] = header
        if header:GetFontString() then
            header:GetFontString():SetJustifyH("RIGHT")
        end
    end

    local nameHeader = CreateColumnHeader(baseFrame, "Name", SORT_NAME)
    nameHeader.headerTop = headerTop
    columnHeadersByKey[SORT_NAME] = nameHeader
    if nameHeader:GetFontString() then
        nameHeader:GetFontString():SetJustifyH("LEFT")
        nameHeader:GetFontString():ClearAllPoints()
        nameHeader:GetFontString():SetPoint("LEFT", nameHeader, "LEFT", ACCENT_STRIPE_WIDTH + 4, 0)
    end
end

---Re-anchors the header row for the columns currently in use.
function LayoutColumnHeaders()
    local visible = VisibleColumns()
    local order = {SORT_MEMORY, SORT_AVERAGE, SORT_CALLS, SORT_SELF, SORT_TOTAL}
    local previous

    for _, key in ipairs(order) do
        local header = columnHeadersByKey[key]
        header:ClearAllPoints()
        if visible[key] then
            if previous then
                header:SetPoint("TOPRIGHT", previous, "TOPLEFT", -COLUMN_GAP, 0)
            else
                header:SetPoint("TOPRIGHT", baseFrame, "TOPRIGHT",
                    -(EDGE_PADDING + SCROLL_TRACK_WIDTH + COLUMN_GAP), header.headerTop)
            end
            header:Show()
            previous = header
        else
            header:Hide()
        end
    end

    local nameHeader = columnHeadersByKey[SORT_NAME]
    nameHeader:ClearAllPoints()
    nameHeader:SetPoint("TOPLEFT", baseFrame, "TOPLEFT",
        EDGE_PADDING + (displayState.treeVisible and (TREE_PANE_WIDTH + TREE_PANE_GUTTER) or 0),
        nameHeader.headerTop)
    nameHeader:SetPoint("TOPRIGHT", previous, "TOPLEFT", -COLUMN_GAP, 0)
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

local function BuildTreePane()
    local paneTop = -(CONTENT_TOP + CONTROL_ROW_HEIGHT + FILTER_ROW_HEIGHT
        + COLUMN_HEADER_HEIGHT)

    treeFrame = CreateFrame("Frame", nil, baseFrame)
    treeFrame:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", EDGE_PADDING, paneTop)
    treeFrame:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT",
        EDGE_PADDING, DETAIL_STRIP_HEIGHT + STATUS_BAR_HEIGHT + EDGE_PADDING)
    treeFrame:SetWidth(TREE_PANE_WIDTH)
    treeFrame:EnableMouseWheel(true)
    treeFrame:SetScript("OnMouseWheel", function(_, delta)
        displayState.treeScrollOffset = mmax(0, displayState.treeScrollOffset - delta * WHEEL_SCROLL_ROWS)
        RenderTree()
    end)

    local divider = baseFrame:CreateTexture(nil, "ARTWORK")
    divider:SetTexture("Interface\\Buttons\\WHITE8X8")
    divider:SetWidth(1)
    -- Runs past the tree's own bottom to the top of the status band, because the footer row below it is split
    -- by the same column: scope on the left, the pinned row's detail on the right. Stopping at the tree left
    -- those two to run together with nothing between them.
    divider:SetPoint("TOPLEFT", treeFrame, "TOPRIGHT", TREE_PANE_GUTTER / 2, 0)
    divider:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT",
        EDGE_PADDING + TREE_PANE_WIDTH + (TREE_PANE_GUTTER / 2), STATUS_BAR_HEIGHT + 1)
    if divider.SetColorTexture then
        divider:SetColorTexture(DIVIDER_COLOR.r, DIVIDER_COLOR.g, DIVIDER_COLOR.b, DIVIDER_COLOR.a)
    end

    treeScrollTrack = treeFrame:CreateTexture(nil, "BACKGROUND")
    treeScrollTrack:SetTexture("Interface\\Buttons\\WHITE8X8")
    treeScrollTrack:SetWidth(TREE_SCROLL_WIDTH)
    treeScrollTrack:SetPoint("TOPRIGHT", treeFrame, "TOPRIGHT", 0, 0)
    treeScrollTrack:SetPoint("BOTTOMRIGHT", treeFrame, "BOTTOMRIGHT", 0, 0)
    if treeScrollTrack.SetColorTexture then
        treeScrollTrack:SetColorTexture(TREE_SCROLL_TRACK_COLOR.r, TREE_SCROLL_TRACK_COLOR.g,
            TREE_SCROLL_TRACK_COLOR.b, TREE_SCROLL_TRACK_COLOR.a)
    end

    treeScrollThumb = treeFrame:CreateTexture(nil, "ARTWORK")
    treeScrollThumb:SetTexture("Interface\\Buttons\\WHITE8X8")
    treeScrollThumb:SetWidth(TREE_SCROLL_WIDTH)
    if treeScrollThumb.SetColorTexture then
        treeScrollThumb:SetColorTexture(TREE_SCROLL_THUMB_COLOR.r, TREE_SCROLL_THUMB_COLOR.g,
            TREE_SCROLL_THUMB_COLOR.b, TREE_SCROLL_THUMB_COLOR.a)
    end

    local treeHeader = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    treeHeader:SetPoint("BOTTOMLEFT", treeFrame, "TOPLEFT", 0, 2)
    treeHeader:SetText("Hierarchy")
    treeHeader:SetTextColor(0.7, 0.7, 0.7)
end

local function BuildListArea()
    local listTop = -(CONTENT_TOP + CONTROL_ROW_HEIGHT + FILTER_ROW_HEIGHT
        + COLUMN_HEADER_HEIGHT)

    listFrame = CreateFrame("Frame", nil, baseFrame)
    listFrame:SetPoint("TOPLEFT", baseFrame, "TOPLEFT",
        EDGE_PADDING + TREE_PANE_WIDTH + TREE_PANE_GUTTER, listTop)
    listFrame:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT",
        -EDGE_PADDING, DETAIL_STRIP_HEIGHT + STATUS_BAR_HEIGHT + EDGE_PADDING)
    listFrame:EnableMouseWheel(true)
    listFrame:SetScript("OnMouseWheel", function(_, delta)
        SetScrollOffset(displayState.scrollOffset - delta * WHEEL_SCROLL_ROWS)
    end)

    BuildScrollTrack()
end

---@param parent table
---@param anchorSide string @"LEFT" for the callers column, "RIGHT" for the callees
---@return table[] entryButtons
local function CreateRelationColumn(parent, anchorSide)
    local entryButtons = {}
    for index = 1, RELATION_PANEL_ROWS do
        local entry = CreateFrame("Button", nil, parent)
        entry:SetHeight(RELATION_ROW_HEIGHT)
        entry:SetPoint("TOP" .. anchorSide, parent, "TOP" .. anchorSide,
            anchorSide == "LEFT" and 0 or 0, -(RELATION_HEADER_HEIGHT + (index - 1) * RELATION_ROW_HEIGHT))
        entry:SetWidth(10)

        -- No icon slot here. Only a file would earn one, and a relation is always a call edge, so a file
        -- never appears - the column would be blank on every row. Colour still separates job from function,
        -- and dropping "ThreadLib job: " for it is what freed the width this column was short of.
        entry.nameText = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        entry.nameText:SetPoint("LEFT", entry, "LEFT", 10, 0)
        entry.nameText:SetJustifyH("LEFT")
        DisableWrapping(entry.nameText)

        entry.valueText = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        entry.valueText:SetPoint("RIGHT", entry, "RIGHT", 0, 0)
        entry.valueText:SetJustifyH("RIGHT")
        entry.valueText:SetWidth(120)

        AddHoverHighlight(entry)
        entry:SetScript("OnClick", function(self)
            if not self.identity then
                return
            end
            -- Selecting the neighbour is what makes this a drill-down rather than a readout: follow a caller
            -- up to see what it in turn was called by, or a callee down into its own relations.
            displayState.selectedKey = self.identity
            ApplySelection()
            RenderRows()
        end)
        entry:SetScript("OnEnter", function(self)
            if not self.identity then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.identity, 1, 0.82, 0, true)
            GameTooltip:AddLine("")
            GameTooltip:AddLine(self.relationSummary, 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("")
            GameTooltip:AddLine("Click to inspect this entry's own callers and callees.", 0.6, 0.6, 0.68, true)
            GameTooltip:Show()
        end)
        entry:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        entryButtons[index] = entry
    end
    return entryButtons
end

local function BuildRelationPanel()
    relationPanel = CreateFrame("Frame", nil, baseFrame)
    relationPanel:SetHeight(RELATION_PANEL_HEIGHT)
    relationPanel:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT",
        EDGE_PADDING + TREE_PANE_WIDTH + TREE_PANE_GUTTER,
        DETAIL_STRIP_HEIGHT + STATUS_BAR_HEIGHT + EDGE_PADDING)
    relationPanel:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT",
        -EDGE_PADDING, DETAIL_STRIP_HEIGHT + STATUS_BAR_HEIGHT + EDGE_PADDING)

    local topRule = relationPanel:CreateTexture(nil, "ARTWORK")
    topRule:SetTexture("Interface\\Buttons\\WHITE8X8")
    topRule:SetHeight(1)
    topRule:SetPoint("TOPLEFT", relationPanel, "TOPLEFT", 0, 0)
    topRule:SetPoint("TOPRIGHT", relationPanel, "TOPRIGHT", 0, 0)
    if topRule.SetColorTexture then
        topRule:SetColorTexture(DIVIDER_COLOR.r, DIVIDER_COLOR.g, DIVIDER_COLOR.b, DIVIDER_COLOR.a)
    end

    relationCallerHeader = relationPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    relationCallerHeader:SetPoint("TOPLEFT", relationPanel, "TOPLEFT", 10, -3)
    relationCallerHeader:SetJustifyH("LEFT")
    relationCallerHeader:SetTextColor(COLOR_SECTION_HEADING.r, COLOR_SECTION_HEADING.g, COLOR_SECTION_HEADING.b)

    relationCalleeHeader = relationPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    -- One anchor, like the caller header above: the previous TOP + LEFT->CENTER pair over-constrained the
    -- rect on paper and happened to render correctly only because the client resolves the conflict leniently.
    relationCalleeHeader:SetPoint("TOPLEFT", relationPanel, "TOP", 10, -3)
    relationCalleeHeader:SetJustifyH("LEFT")
    relationCalleeHeader:SetTextColor(COLOR_SECTION_HEADING.r, COLOR_SECTION_HEADING.g, COLOR_SECTION_HEADING.b)

    relationCallerRows = CreateRelationColumn(relationPanel, "LEFT")
    relationCalleeRows = CreateRelationColumn(relationPanel, "RIGHT")
    relationPanel:Hide()
end

---Fills one column of the panel and returns how many entries it showed.
---@param entryButtons table[]
---@param entries table[]
---@param identityField string
---@param columnWidth number
---@param emptyMessage string
local function RenderRelationColumn(entryButtons, entries, identityField, columnWidth, emptyMessage)
    for index = 1, RELATION_PANEL_ROWS do
        local entry = entryButtons[index]
        local data = entries[index]
        entry:SetWidth(columnWidth)
        entry.nameText:SetWidth(mmax(40, columnWidth - 130))

        if data then
            local identity = data[identityField]
            local isThreadJob = IsThreadJobKey(identity)
            -- "(root)" is a basis label, not an identity: no report row answers to it, so a click could only
            -- clear the selection. Keeping it in the list but not clickable preserves the count it carries.
            local isRootLabel = identity == "(root)"
            entry.identity = not isRootLabel and identity or nil
            entry.relationSummary = sformat("%s calls, %s ms",
                FormatCount(data.calls), FormatMilliseconds(data.totalTime))
            -- Colour carries the species here, the way it does in the list. Nothing is lost: the tooltip
            -- still shows the untrimmed key.
            entry.nameText:SetText(DisplayNameFor(identity))
            local nameColor = (isThreadJob and COLOR_THREAD_JOB)
                or (isRootLabel and COLOR_UNTIMED)
                or COLOR_TEXT
            entry.nameText:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
            entry.valueText:SetText(sformat("%s x   %s ms",
                FormatCount(data.calls), FormatMilliseconds(data.totalTime)))
            entry:Show()
        elseif index == 1 then
            -- An empty direction is a finding, not a blank: a leaf calls nothing, a root is called by nothing.
            entry.identity = nil
            entry.nameText:SetText(emptyMessage)
            entry.nameText:SetTextColor(COLOR_UNTIMED.r, COLOR_UNTIMED.g, COLOR_UNTIMED.b)
            entry.valueText:SetText("")
            entry:Show()
        else
            entry.identity = nil
            entry:Hide()
        end
    end
end

---Says so when a direction holds more than the panel can show, rather than letting five of fifteen read as
---all of them.
---@param label string
---@param count number
---@return string
function _QuestieProfilerUI.RelationHeaderText(label, count)
    if count > RELATION_PANEL_ROWS then
        return sformat("%s (%d, top %d)", label, count, RELATION_PANEL_ROWS)
    end
    return sformat("%s (%d)", label, count)
end

---@param reportRow ProfilerReportRow?
function RenderRelations(reportRow)
    if not relationPanel then
        return
    end
    if not reportRow then
        relationPanel:Hide()
        return
    end

    ---@type ProfilerReportSource
    local source = QuestieProfiler
    local callers = _QuestieProfilerUI.BuildCallerList(source, reportRow, displayState.grouped)
    local callees = _QuestieProfilerUI.BuildCalleeList(source, reportRow, displayState.grouped)

    -- An even split, deliberately. Sizing the columns by how many entries each held was tried and reverted:
    -- row count does not predict width need, and it read backwards - five short caller names took 62% of the
    -- panel while three long callee names were truncated into the remaining 38%. Name length is the real
    -- constraint, and measuring it would move the divider on every selection, which is worse than a stable
    -- boundary that is never actively wrong.
    local panelWidth = relationPanel:GetWidth() or 0
    local columnWidth = mmax(80, (panelWidth / 2) - 10)

    relationCallerHeader:SetText(_QuestieProfilerUI.RelationHeaderText("Called by", #callers))
    relationCalleeHeader:SetText(_QuestieProfilerUI.RelationHeaderText("Calls", #callees))

    RenderRelationColumn(relationCallerRows, callers, "callerKey", columnWidth,
        reportRow.isFileLoad and "a loaded file has no caller" or "nothing profiled called this")
    RenderRelationColumn(relationCalleeRows, callees, "calleeKey", columnWidth,
        reportRow.isFileLoad and "a loaded file calls nothing" or "called nothing profiled")

    relationPanel:Show()
end

---Gives the list and tree the height the relations panel is not using.
---Resolves the pinned row, fills the detail line and relations panel, and re-anchors the content area.
---Runs before RenderRows because whether the panel is open changes how tall the list is: rendering first
---laid the rows out against the previous height, so the list visibly reflowed a frame or two later.
---@return ProfilerReportRow? selectedRow
function ApplySelection()
    local selectedRow
    if displayState.selectedKey then
        for i = 1, #(currentReport and currentReport.rows or {}) do
            if currentReport.rows[i].lookupKey == displayState.selectedKey then
                selectedRow = currentReport.rows[i]
                break
            end
        end

        -- Following a relation can land on something the current scope or species filter excludes. The panel
        -- is how you got there, so it keeps working: fall back to the unscoped rows rather than going blank.
        if not selectedRow then
            for i = 1, #currentUnscopedRows do
                if currentUnscopedRows[i].lookupKey == displayState.selectedKey then
                    selectedRow = currentUnscopedRows[i]
                    break
                end
            end
        end

        -- The unscoped rows still honour the search, species and idle filters, so a relation can name an
        -- identity neither list holds - the measurement tables it was read from know no filters. Resolve
        -- against a report built with none. Only a click that missed both lists pays for this build.
        if not selectedRow then
            ---@type ProfilerReportSource
            local source = QuestieProfiler
            local unfilteredRows = _QuestieProfilerUI.BuildReport(source, {grouped = displayState.grouped}).rows
            for i = 1, #unfilteredRows do
                if unfilteredRows[i].lookupKey == displayState.selectedKey then
                    selectedRow = unfilteredRows[i]
                    break
                end
            end
        end
    end

    UpdateDetailStrip(selectedRow)
    RenderRelations(selectedRow)
    LayoutContentArea()
    return selectedRow
end

---Gives the list the height the relations panel is not using.
---Only the list moves. The panel begins a gap to the right of the tree and never covers it, so shrinking the
---hierarchy alongside it cost six rows and a re-render for nothing.
function LayoutContentArea()
    if not listFrame then
        return
    end

    local bottomInset = DETAIL_STRIP_HEIGHT + STATUS_BAR_HEIGHT + EDGE_PADDING
    if relationPanel and relationPanel:IsShown() then
        bottomInset = bottomInset + RELATION_PANEL_HEIGHT + 4
    end

    listFrame:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -EDGE_PADDING, bottomInset)
end

local function BuildFooter()
    -- Band first, rule on its top edge: together they turn the session row into a floor the window sits on,
    -- which is what stops it being read as a continuation of the selection line above.
    local footerBand = baseFrame:CreateTexture(nil, "BACKGROUND")
    footerBand:SetTexture("Interface\\Buttons\\WHITE8X8")
    footerBand:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT", 1, 1)
    footerBand:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -1, 1)
    footerBand:SetHeight(STATUS_BAR_HEIGHT)
    if footerBand.SetColorTexture then
        footerBand:SetColorTexture(CHROME_BAND_COLOR.r, CHROME_BAND_COLOR.g, CHROME_BAND_COLOR.b,
            CHROME_BAND_COLOR.a)
    end

    local footerRule = baseFrame:CreateTexture(nil, "ARTWORK")
    footerRule:SetTexture("Interface\\Buttons\\WHITE8X8")
    footerRule:SetHeight(1)
    footerRule:SetPoint("BOTTOMLEFT", footerBand, "TOPLEFT", 0, 0)
    footerRule:SetPoint("BOTTOMRIGHT", footerBand, "TOPRIGHT", 0, 0)
    if footerRule.SetColorTexture then
        footerRule:SetColorTexture(DIVIDER_COLOR.r, DIVIDER_COLOR.g, DIVIDER_COLOR.b, DIVIDER_COLOR.a)
    end

    treeScopeButton = CreateFrame("Button", nil, baseFrame)
    treeScopeButton:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT",
        EDGE_PADDING, STATUS_BAR_HEIGHT + SELECTION_ROW_LIFT)
    treeScopeButton:SetSize(TREE_PANE_WIDTH, DETAIL_STRIP_HEIGHT)
    AddHoverHighlight(treeScopeButton)
    treeScopeButton:SetScript("OnClick", function()
        if displayState.scopePrefix == "" then
            return
        end
        ClearHierarchyScope()
        QuestieProfilerUI:Refresh()
    end)

    treeScopeText = treeScopeButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    treeScopeText:SetAllPoints(treeScopeButton)
    -- Stops at the pane edge rather than crossing the gutter, so a long scope never crowds the divider.
    treeScopeText:SetJustifyH("LEFT")
    treeScopeText:SetTextColor(SCOPE_HINT_COLOR.r, SCOPE_HINT_COLOR.g, SCOPE_HINT_COLOR.b)
    DisableWrapping(treeScopeText)

    -- A FontString cannot be selected, so the one thing worth copying gets an EditBox. No template, so it
    -- draws no border and reads as part of the line rather than as an input someone is meant to fill in.
    detailBox = CreateFrame("EditBox", nil, baseFrame)
    detailBox:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT",
        EDGE_PADDING + TREE_PANE_WIDTH + TREE_PANE_GUTTER, STATUS_BAR_HEIGHT + SELECTION_ROW_LIFT - 3)
    detailBox:SetHeight(DETAIL_STRIP_HEIGHT)
    detailBox:SetWidth(10)
    detailBox:SetAutoFocus(false)
    detailBox:SetFontObject("GameFontHighlightSmall")
    detailBox:SetTextColor(0.85, 0.85, 0.88)
    -- The widget has no read-only mode, so the value is put back the moment anything is typed. The flag is
    -- what keeps that from recursing: a programmatic SetText reports userInput false.
    detailBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            self:SetText(self.copyText or "")
            self:HighlightText()
        end
    end)
    -- Clicking selects the whole identity, so copying is click then Ctrl+C rather than a careful drag.
    detailBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    detailBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    detailBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    -- Off-screen twin used only to measure, because an EditBox cannot report the width of its own text.
    detailBoxMeasure = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detailBoxMeasure:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT", 0, 0)
    detailBoxMeasure:Hide()

    detailText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detailText:SetPoint("BOTTOMLEFT", detailBox, "BOTTOMRIGHT", 6, 3)
    detailText:SetJustifyH("LEFT")
    -- Brighter than the session row below: this line changes with every click, so it is the live one.
    detailText:SetTextColor(0.85, 0.85, 0.88)
    DisableWrapping(detailText)

    -- Denominators on the left, state on the right. Both live on the status row, so the strip costs no
    -- height: a profiler that spends another row of chrome on chrome is worse off than one that groups.
    summaryText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summaryText:SetPoint("BOTTOMLEFT", baseFrame, "BOTTOMLEFT", EDGE_PADDING, 6)
    summaryText:SetJustifyH("LEFT")
    summaryText:SetTextColor(0.66, 0.66, 0.72)
    DisableWrapping(summaryText)

    statusText = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusText:SetPoint("BOTTOMRIGHT", baseFrame, "BOTTOMRIGHT", -(EDGE_PADDING + 16), 6)
    statusText:SetPoint("LEFT", summaryText, "RIGHT", 12, 0)
    statusText:SetJustifyH("RIGHT")
    statusText:SetTextColor(0.62, 0.62, 0.68)
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
    -- The selection strip splits its width between the copy box and the measurements, so a resize has to
    -- re-split it. Waiting for the next refresh would leave it stale, and while frozen there is no next one.
    ApplySelection()
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
    BuildShowRow()
    BuildColumnHeaders()
    BuildTreePane()
    BuildListArea()
    BuildRelationPanel()
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
    elseif command == "show" and QuestieProfiler:HasResults() then
        -- A stopped session's results stay readable, so show opens on them too: requiring an active session
        -- here made a closed window's capture unreachable except by starting over, which erases it.
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
_QuestieProfilerUI.HideFilesAfterMeasurementReset = HideFilesAfterMeasurementReset
_QuestieProfilerUI.DetailLineFor = DetailLineFor
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
