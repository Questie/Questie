dofile("setupTests.lua")

describe("QuestieProfilerUI", function()
    ---@type QuestieProfilerUI
    local ProfilerUI
    ---@type QuestieProfiler
    local Profiler
    local originalCreateFrame
    local originalGameTooltip
    local originalUISpecialFrames
    local originalBackdropTemplateMixin
    local originalGetCursorPosition
    local originalTimerAPI
    local frameRegistry

    -- The profiler UI touches far more of the frame API than setupTests.lua mocks, and none of the assertions
    -- below care about geometry. This mock tracks only the state the behaviour depends on - visibility, text,
    -- scripts and registered events - and auto-stubs every other frame method.
    local function CreateFrameMock(frameType, frameName, parent)
        local scripts = {}
        local registeredEvents = {}
        local isShown = true
        local text = ""
        local enabled = true

        local frame
        frame = {
            frameType = frameType,
            frameName = frameName,
            parent = parent,
            scripts = scripts,
            registeredEvents = registeredEvents,
            SetScript = function(_, scriptName, callback)
                scripts[scriptName] = callback
            end,
            GetScript = function(_, scriptName)
                return scripts[scriptName]
            end,
            HookScript = function(_, scriptName, callback)
                scripts[scriptName] = callback
            end,
            RegisterEvent = function(_, eventName)
                registeredEvents[eventName] = true
            end,
            UnregisterEvent = function(_, eventName)
                registeredEvents[eventName] = nil
            end,
            Show = function(self)
                if not isShown then
                    isShown = true
                    if scripts.OnShow then
                        scripts.OnShow(self)
                    end
                end
            end,
            Hide = function(self)
                if isShown then
                    isShown = false
                    if scripts.OnHide then
                        scripts.OnHide(self)
                    end
                end
            end,
            IsShown = function()
                return isShown
            end,
            IsVisible = function()
                return isShown
            end,
            SetText = function(_, value)
                text = value
            end,
            GetText = function()
                return text
            end,
            GetStringWidth = function()
                return string.len(text or "") * 6
            end,
            Enable = function()
                enabled = true
            end,
            Disable = function()
                enabled = false
            end,
            IsEnabled = function()
                return enabled
            end,
            GetFontString = function()
                return frame.fontString
            end,
            CreateFontString = function(self)
                return CreateFrameMock("FontString", nil, self)
            end,
            CreateTexture = function(self)
                return CreateFrameMock("Texture", nil, self)
            end,
            GetWidth = function()
                return 680
            end,
            GetHeight = function()
                return 200
            end,
            GetTop = function()
                return 400
            end,
            GetEffectiveScale = function()
                return 1
            end,
            GetName = function()
                return frameName
            end,
            GetObjectType = function()
                return frameType
            end,
        }
        frame.fontString = frameType ~= "FontString" and CreateFrameMock("FontString", nil, frame) or nil

        -- Any frame method the UI calls that this mock does not model is a no-op; the tests assert behaviour,
        -- not layout, so silently accepting those keeps the mock honest about what it actually verifies.
        setmetatable(frame, {
            __index = function(_, key)
                if type(key) == "string" then
                    return function() end
                end
                return nil
            end,
        })

        table.insert(frameRegistry, frame)
        return frame
    end

    ---@return table? frame
    local function FindFrameByName(frameName)
        for _, frame in ipairs(frameRegistry) do
            if frame.frameName == frameName then
                return frame
            end
        end
        return nil
    end

    local function FindFrameByText(text)
        for _, frame in ipairs(frameRegistry) do
            if frame.GetText and frame:GetText() == text then
                return frame
            end
        end
        return nil
    end

    local function FireEvent(eventName)
        for _, frame in ipairs(frameRegistry) do
            if frame.registeredEvents[eventName] and frame.scripts.OnEvent then
                frame.scripts.OnEvent(frame, eventName)
            end
        end
    end

    ---@return table profilerStub
    local function NewProfilerStub()
        return {
            active = true,
            hookedFunctionCount = 0,
            highestMS = 0,
            highestCalls = 0,
            hookCallCount = {},
            hookTimeCount = {},
            hookSelfTime = {},
            fileLoadTime = {},
            fileLoadMemory = {},
            callerCallCount = {},
            callerTimeCount = {},
            lowerCaseLookup = {},
            threadJobCallCount = {},
            threadJobResumeCount = {},
            Stop = function(self)
                self.active = false
            end,
            Start = function(self)
                self.active = true
                return true
            end,
            HasResults = function(self)
                return self.active == true or next(self.hookCallCount) ~= nil
            end,
            ResetMeasurements = function(self)
                for lookupKey in pairs(self.hookCallCount) do
                    self.hookCallCount[lookupKey] = 0
                    self.hookTimeCount[lookupKey] = 0
                    self.hookSelfTime[lookupKey] = 0
                end
                for lookupKey in pairs(self.threadJobCallCount) do
                    self.threadJobCallCount[lookupKey] = 0
                    self.threadJobResumeCount[lookupKey] = 0
                end
                self.callerCallCount = {}
                self.callerTimeCount = {}
            end,
        }
    end

    ---Registers one ordinary function measurement on the profiler stub.
    ---Self time defaults to the total, which is what a function with no profiled children reports.
    local function AddFunctionEntry(lookupKey, totalTime, calls, selfTime)
        Profiler.hookCallCount[lookupKey] = calls
        Profiler.hookTimeCount[lookupKey] = totalTime
        Profiler.hookSelfTime[lookupKey] = selfTime or totalTime
        Profiler.lowerCaseLookup[lookupKey] = string.lower(lookupKey)
    end

    ---Registers that `callerKey` invoked `calleeKey`.
    local function AddCallerEntry(calleeKey, callerKey, calls, totalTime)
        Profiler.callerCallCount[calleeKey] = Profiler.callerCallCount[calleeKey] or {}
        Profiler.callerTimeCount[calleeKey] = Profiler.callerTimeCount[calleeKey] or {}
        Profiler.callerCallCount[calleeKey][callerKey] = calls
        Profiler.callerTimeCount[calleeKey][callerKey] = totalTime
    end

    ---@return ProfilerCallerEntry[]
    local function BuildCallerList(reportRow, grouped)
        return ProfilerUI.private.BuildCallerList(Profiler, reportRow, grouped == true)
    end

    ---@return ProfilerCalleeEntry[]
    local function BuildCalleeList(reportRow, grouped)
        return ProfilerUI.private.BuildCalleeList(Profiler, reportRow, grouped == true)
    end

    ---Registers one ThreadLib job measurement on the profiler stub.
    ---Self time stays zero as in production: only function epilogues add to a key's self slot, and a job is
    ---a scheduling unit with no epilogue of its own.
    local function AddThreadJobEntry(lookupKey, totalTime, jobCalls, resumeCount)
        Profiler.hookCallCount[lookupKey] = jobCalls
        Profiler.hookTimeCount[lookupKey] = totalTime
        Profiler.hookSelfTime[lookupKey] = 0
        Profiler.lowerCaseLookup[lookupKey] = string.lower(lookupKey)
        Profiler.threadJobCallCount[lookupKey] = jobCalls
        Profiler.threadJobResumeCount[lookupKey] = resumeCount
    end

    ---@return ProfilerReport
    local function BuildReport(options)
        return ProfilerUI.private.BuildReport(Profiler, options or {})
    end

    ---@return string[] lookupKeys
    local function RowKeys(report)
        local keys = {}
        for _, row in ipairs(report.rows) do
            table.insert(keys, row.lookupKey)
        end
        return keys
    end

    ---Reads the list rows the window is actually displaying, unlike RowKeys(BuildReport()) which reads the
    ---profiler stub and would report the same thing whether or not Refresh ever ran. RenderRows stamps each
    ---pooled row frame with the report row it shows, so this observes retained UI state through the mock.
    ---@return string[] lookupKeys @Top to bottom, as rendered
    local function RenderedRowKeys()
        local keys = {}
        for _, frame in ipairs(frameRegistry) do
            -- rawget: the mock auto-stubs every unknown key with a function, which reads as truthy.
            local reportRow = rawget(frame, "reportRow")
            if reportRow and frame.IsShown() then
                table.insert(keys, reportRow.lookupKey)
            end
        end
        return keys
    end

    ---@return ProfilerReportRow?
    local function FindRow(report, lookupKey)
        for _, row in ipairs(report.rows) do
            if row.lookupKey == lookupKey then
                return row
            end
        end
        return nil
    end

    before_each(function()
        frameRegistry = {}
        originalCreateFrame = _G.CreateFrame
        originalGameTooltip = _G.GameTooltip
        originalUISpecialFrames = _G.UISpecialFrames
        originalBackdropTemplateMixin = _G.BackdropTemplateMixin
        originalGetCursorPosition = _G.GetCursorPosition
        originalTimerAPI = _G.C_Timer

        _G.CreateFrame = CreateFrameMock
        _G.GameTooltip = setmetatable({}, {__index = function() return function() end end})
        _G.UISpecialFrames = {}
        _G.BackdropTemplateMixin = {}
        _G.GetCursorPosition = function() return 0, 0 end
        _G.C_Timer = {
            NewTicker = function(interval, callback)
                return {
                    interval = interval,
                    callback = callback,
                    Cancel = function(self)
                        self.cancelled = true
                    end,
                }
            end,
        }

        -- Replace the profiler engine before load: the UI captures the module reference at file scope.
        QuestieLoader._modules.Profiler = NewProfilerStub()
        Profiler = QuestieLoader:ImportModule("Profiler")

        QuestieLoader._modules.ProfilerUI = nil
        dofile("Modules/QuestieProfilerUI.lua")
        ProfilerUI = QuestieLoader:ImportModule("ProfilerUI")
    end)

    after_each(function()
        _G.CreateFrame = originalCreateFrame
        _G.GameTooltip = originalGameTooltip
        _G.UISpecialFrames = originalUISpecialFrames
        _G.BackdropTemplateMixin = originalBackdropTemplateMixin
        _G.GetCursorPosition = originalGetCursorPosition
        _G.C_Timer = originalTimerAPI
        QuestieLoader._modules.Profiler = nil
        QuestieLoader._modules.ProfilerUI = nil
    end)

    describe("profiler entry points", function()
        it("exposes the functions the profiler engine calls", function()
            assert.are_same("function", type(ProfilerUI.Create))
            assert.are_same("function", type(ProfilerUI.Show))
            assert.are_same("function", type(ProfilerUI.Hide))
            assert.are_same("function", type(ProfilerUI.Refresh))
        end)

        it("registers under the module name the profiler excludes from hooking", function()
            assert.are_equal(ProfilerUI, QuestieLoader._modules.ProfilerUI)
        end)
    end)

    describe("BuildReport", function()
        it("reports total time, calls and average for a function entry", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)

            local row = FindRow(BuildReport(), "QuestieDB.GetQuest")

            assert.are_same(200, row.totalTime)
            assert.are_same(4, row.calls)
            assert.are_same(50, row.averageTime)
            assert.is_false(row.isThreadJob)
            assert.is_true(row.hasTiming)
        end)

        it("marks entries that were counted but never timed", function()
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 0, 12)

            local row = FindRow(BuildReport(), "QuestieMap.DrawWorldIcon")

            assert.are_same(12, row.calls)
            assert.are_same(0, row.totalTime)
            assert.is_false(row.hasTiming)
        end)

        it("reports job and resume counts for a ThreadLib job", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)

            local row = FindRow(BuildReport(), "ThreadLib job: _DrawAvailableQuest")

            assert.is_true(row.isThreadJob)
            assert.are_same(600, row.totalTime)
            assert.are_same(3, row.jobCalls)
            assert.are_same(40, row.resumeCount)
        end)

        it("averages a ThreadLib job over its submitted jobs", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)

            local row = FindRow(BuildReport(), "ThreadLib job: _DrawAvailableQuest")

            assert.are_same(200, row.averageTime)
        end)

        it("strips the ThreadLib prefix from the display name but keeps the full identity", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)

            local row = FindRow(BuildReport(), "ThreadLib job: _DrawAvailableQuest")

            assert.are_same("_DrawAvailableQuest", row.displayName)
            assert.are_same("ThreadLib job: _DrawAvailableQuest", row.lookupKey)
        end)

        it("counts every profiler entry regardless of the active filter", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 100, 2)

            local report = BuildReport({filter = "getquest"})

            assert.are_same(2, report.totalCount)
            assert.are_same(1, report.matchedCount)
        end)

        it("leaves the profiler tables untouched", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddThreadJobEntry("ThreadLib job: Draw", 600, 3, 40)

            BuildReport({filter = "questie", grouped = true, sortKey = "calls", descending = false})

            assert.are_same({["QuestieDB.GetQuest"] = 4, ["ThreadLib job: Draw"] = 3}, Profiler.hookCallCount)
            assert.are_same({["QuestieDB.GetQuest"] = 200, ["ThreadLib job: Draw"] = 600}, Profiler.hookTimeCount)
            assert.are_same({["ThreadLib job: Draw"] = 3}, Profiler.threadJobCallCount)
            assert.are_same({["ThreadLib job: Draw"] = 40}, Profiler.threadJobResumeCount)
        end)
    end)

    describe("the selection detail line", function()
        it("starts at the measurements, because the identity lives in the copy box beside it", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)

            local detail = ProfilerUI.private.DetailLineFor(FindRow(BuildReport(), "QuestieDB.GetQuest"))

            assert.are_same(nil, string.find(detail, "QuestieDB.GetQuest", 1, true))
            assert.are_same(1, string.find(detail, "|  200.000 ms total", 1, true))
        end)

        it("describes a file by its load and allocation, not by calls it cannot have", function()
            Profiler.fileLoadTime["Questie.lua"] = 50
            Profiler.fileLoadMemory["Questie.lua"] = 2140

            local detail = ProfilerUI.private.DetailLineFor(FindRow(BuildReport(), "Questie.lua"))

            assert.are_same(1, string.find(detail, "|  50.000 ms load", 1, true))
            assert.is_true(string.find(detail, "2.1 MB allocated", 1, true) ~= nil)
            -- "0 calls | 0.000 ms avg" on a loaded file read as a measurement of nothing.
            assert.is_nil(string.find(detail, "calls", 1, true))
            assert.is_nil(string.find(detail, "self", 1, true))
        end)

        it("adds jobs and resumes for a ThreadLib job", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)

            local detail = ProfilerUI.private.DetailLineFor(
                FindRow(BuildReport(), "ThreadLib job: _DrawAvailableQuest"))

            assert.is_true(string.find(detail, "3 jobs", 1, true) ~= nil)
            assert.is_true(string.find(detail, "40 resumes", 1, true) ~= nil)
        end)

        it("flags an entry that was counted but never timed", function()
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 0, 12)

            local detail = ProfilerUI.private.DetailLineFor(
                FindRow(BuildReport(), "QuestieMap.DrawWorldIcon"))

            assert.is_true(string.find(detail, "no timed slices", 1, true) ~= nil)
        end)
    end)

    describe("self time", function()
        it("reports the self time the profiler recorded", function()
            AddFunctionEntry("QuestieInit.StartStage", 345, 1, 12)

            local row = FindRow(BuildReport(), "QuestieInit.StartStage")

            assert.are_same(345, row.totalTime)
            assert.are_same(12, row.selfTime)
        end)

        it("sums self time across folded paths in grouped view", function()
            AddFunctionEntry("QuestieDB.private.GetQuest", 40, 2, 30)
            AddFunctionEntry("QuestieDB.GetQuest", 60, 3, 25)

            local row = FindRow(BuildReport({grouped = true}), "QuestieDB.GetQuest")

            assert.are_same(100, row.totalTime)
            assert.are_same(55, row.selfTime)
        end)

        it("reports no self time for a ThreadLib job", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)

            local row = FindRow(BuildReport(), "ThreadLib job: _DrawAvailableQuest")

            assert.is_false(row.hasSelfTime)
        end)

        it("leaves a ThreadLib job out of the self time maximum", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4, 150)

            assert.are_same(150, BuildReport().maxSelfTime)
        end)

        it("orders by self time", function()
            AddFunctionEntry("Alpha.MostlyChildren", 300, 1, 10)
            AddFunctionEntry("Beta.MostlyItself", 200, 1, 190)

            local report = BuildReport({sortKey = "self", descending = true})

            assert.are_same({"Beta.MostlyItself", "Alpha.MostlyChildren"}, RowKeys(report))
        end)

        it("reports the largest self time for heat scaling", function()
            AddFunctionEntry("Alpha.Work", 300, 1, 10)
            AddFunctionEntry("Beta.Work", 200, 1, 190)

            assert.are_same(190, BuildReport().maxSelfTime)
        end)
    end)

    describe("heat scaling", function()
        ---@return number share @0-1 of the row's own species maximum for the active sort metric
        local function HeatShare(report, lookupKey, sortKey)
            return ProfilerUI.private.HeatShare(FindRow(report, lookupKey), report, sortKey or "total")
        end

        it("never draws a bar longer than the row above it, whatever the species mix", function()
            -- The staircase: sorted by cost, bar length has to agree with row order. A per-species scale was
            -- tried and broke exactly this, drawing a mid-sized file longer than a larger function above it.
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 200
            Profiler.fileLoadTime["Questie.lua"] = 76
            AddFunctionEntry("QuestieDB.GetQuest", 90, 1)
            AddFunctionEntry("QuestieDB.GetNPC", 62, 1)
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 300, 3, 40)

            local report = BuildReport({sortKey = "total", descending = true})

            local previous = 1
            for _, row in ipairs(report.rows) do
                local share = ProfilerUI.private.HeatShare(row, report, "total")
                assert.is_true(share <= previous)
                previous = share
            end
        end)

        it("gives the most expensive visible row a full bar and scales the rest against it", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 1)
            AddFunctionEntry("QuestieDB.GetNPC", 50, 1)

            local report = BuildReport()

            assert.are_same(1, HeatShare(report, "QuestieDB.GetQuest"))
            assert.are_same(0.25, HeatShare(report, "QuestieDB.GetNPC"))
        end)

        it("rescales when a species is filtered out, so the flattening is the user's to fix", function()
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 200
            AddFunctionEntry("QuestieDB.GetQuest", 50, 1)

            -- With the file shown, the function is a quarter-length bar. Unticking Files is what rescales it.
            assert.are_same(0.25, HeatShare(BuildReport(), "QuestieDB.GetQuest"))
            assert.are_same(1, HeatShare(BuildReport({showFiles = false}), "QuestieDB.GetQuest"))
        end)

        it("scales memory bars against the largest visible allocation, not against time", function()
            -- Live data from the session that exposed this: the 5500 KB file loaded in a tenth of the time
            -- of the 2944 KB one, and time-based bars drew the smaller allocation nearly ten times longer.
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 659
            Profiler.fileLoadMemory["Localization/lookups/lookupZones.lua"] = 18092
            Profiler.fileLoadTime["Questie.lua"] = 66
            Profiler.fileLoadMemory["Questie.lua"] = 5500
            Profiler.fileLoadTime["embeds.xml"] = 635
            Profiler.fileLoadMemory["embeds.xml"] = 2944

            local report = BuildReport({sortKey = "memory", descending = true})

            assert.are_same(1, HeatShare(report, "Localization/lookups/lookupZones.lua", "memory"))
            assert.is_true(HeatShare(report, "Questie.lua", "memory")
                > HeatShare(report, "embeds.xml", "memory"))
        end)

        it("draws no heat for an interval in which the collector freed memory", function()
            Profiler.fileLoadTime["Questie.lua"] = 10
            Profiler.fileLoadMemory["Questie.lua"] = -50
            Profiler.fileLoadTime["embeds.xml"] = 10
            Profiler.fileLoadMemory["embeds.xml"] = 100

            local report = BuildReport({sortKey = "memory", descending = true})

            assert.are_same(0, HeatShare(report, "Questie.lua", "memory"))
        end)

        it("scales calls against the largest visible call count", function()
            AddFunctionEntry("QuestieDB.GetQuest", 10, 100)
            AddFunctionEntry("QuestieDB.GetNPC", 10, 25)

            local report = BuildReport({sortKey = "calls"})

            assert.are_same(0.25, HeatShare(report, "QuestieDB.GetNPC", "calls"))
        end)
    end)

    describe("share of visible cost", function()
        it("measures a function against the self time of the functions listed, not their totals", function()
            -- Inclusive totals nest, so summing them would run past the wall clock. Alpha's 300 ms total
            -- contains Beta's; only the self times partition the work.
            AddFunctionEntry("Alpha.Caller", 300, 1, 100)
            AddFunctionEntry("Beta.Callee", 200, 1, 200)

            local report = BuildReport()

            assert.are_same(300, FindRow(report, "Alpha.Caller").shareDenominator)
            assert.are_same(100 / 300, FindRow(report, "Alpha.Caller").share)
            assert.are_same(200 / 300, FindRow(report, "Beta.Callee").share)
        end)

        it("measures a file against the file load listed", function()
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 150
            Profiler.fileLoadTime["Questie.lua"] = 50

            local report = BuildReport()

            assert.are_same(0.75, FindRow(report, "Localization/lookups/lookupZones.lua").share)
        end)

        it("keeps each species on its own denominator", function()
            Profiler.fileLoadTime["Questie.lua"] = 40
            AddFunctionEntry("Alpha.Work", 10, 1, 10)
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)

            local report = BuildReport()

            -- Each is the only row of its kind, so each accounts for all of it.
            assert.are_same(1, FindRow(report, "Questie.lua").share)
            assert.are_same(1, FindRow(report, "Alpha.Work").share)
            assert.are_same(1, FindRow(report, "ThreadLib job: _DrawAvailableQuest").share)
        end)

        it("recomputes against what is left when a species is filtered out", function()
            AddFunctionEntry("Alpha.Work", 100, 1, 100)
            AddFunctionEntry("Beta.Work", 100, 1, 100)

            assert.are_same(0.5, FindRow(BuildReport(), "Alpha.Work").share)

            local filtered = BuildReport({filter = "alpha"})

            assert.are_same(1, FindRow(filtered, "Alpha.Work").share)
        end)

        it("reports no share rather than zero when there is nothing to divide by", function()
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 0, 12, 0)

            local row = FindRow(BuildReport(), "QuestieMap.DrawWorldIcon")

            assert.are_same(nil, row.share)
        end)

        describe("formatting", function()
            local cases = {
                {name = "prints one decimal", share = 0.194, expected = "19.4%"},
                {name = "prints a whole share", share = 1, expected = "100.0%"},
                {name = "prints an exact zero plainly", share = 0, expected = "0.0%"},
                {name = "does not round measurable work down to nothing", share = 0.0004, expected = "<0.1%"},
            }

            for _, case in ipairs(cases) do
                it(case.name, function()
                    assert.are_same(case.expected, ProfilerUI.private.FormatShare(case.share))
                end)
            end
        end)
    end)

    describe("relation panel layout", function()
        describe("header counts", function()
            it("reports the count plainly when everything fits", function()
                assert.are_same("Calls (3)", ProfilerUI.private.RelationHeaderText("Calls", 3))
            end)

            it("says how many of them are shown when they do not", function()
                assert.are_same("Calls (15, top 5)", ProfilerUI.private.RelationHeaderText("Calls", 15))
            end)
        end)
    end)

    describe("caller attribution", function()
        it("lists the callers of a row", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddCallerEntry("QuestieDB.GetQuest", "AvailableQuests.Draw", 3, 150)
            AddCallerEntry("QuestieDB.GetQuest", "QuestieTracker.Update", 1, 50)

            local callers = BuildCallerList(FindRow(BuildReport(), "QuestieDB.GetQuest"))

            assert.are_same({
                {callerKey = "AvailableQuests.Draw", calls = 3, totalTime = 150},
                {callerKey = "QuestieTracker.Update", calls = 1, totalTime = 50},
            }, callers)
        end)

        it("orders callers by the time they spent", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddCallerEntry("QuestieDB.GetQuest", "Cheap.Caller", 3, 10)
            AddCallerEntry("QuestieDB.GetQuest", "Expensive.Caller", 1, 190)

            local callers = BuildCallerList(FindRow(BuildReport(), "QuestieDB.GetQuest"))

            assert.are_same("Expensive.Caller", callers[1].callerKey)
        end)

        it("returns nothing for a row with no recorded callers", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)

            assert.are_same({}, BuildCallerList(FindRow(BuildReport(), "QuestieDB.GetQuest")))
        end)

        it("folds the callers of every path a grouped row merged", function()
            AddFunctionEntry("QuestieDB.private.GetQuest", 40, 2)
            AddFunctionEntry("QuestieDB.GetQuest", 60, 3)
            AddCallerEntry("QuestieDB.private.GetQuest", "AvailableQuests.Draw", 2, 40)
            AddCallerEntry("QuestieDB.GetQuest", "AvailableQuests.Draw", 3, 60)

            local callers = BuildCallerList(FindRow(BuildReport({grouped = true}), "QuestieDB.GetQuest"), true)

            assert.are_same({
                {callerKey = "AvailableQuests.Draw", calls = 5, totalTime = 100},
            }, callers)
        end)

        it("names grouped callers by their grouped identity", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddCallerEntry("QuestieDB.GetQuest", "AvailableQuests.private.Draw", 4, 200)

            local callers = BuildCallerList(FindRow(BuildReport({grouped = true}), "QuestieDB.GetQuest"), true)

            assert.are_same("AvailableQuests.Draw", callers[1].callerKey)
        end)

        it("keeps the root caller intact under grouping", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddCallerEntry("QuestieDB.GetQuest", "(root)", 4, 200)

            local callers = BuildCallerList(FindRow(BuildReport({grouped = true}), "QuestieDB.GetQuest"), true)

            assert.are_same("(root)", callers[1].callerKey)
        end)
    end)

    describe("callee lists", function()
        it("lists what a row called", function()
            AddFunctionEntry("AvailableQuests.Draw", 200, 4)
            AddFunctionEntry("QuestieDB.GetQuest", 150, 3)
            AddCallerEntry("QuestieDB.GetQuest", "AvailableQuests.Draw", 3, 150)

            local callees = BuildCalleeList(FindRow(BuildReport(), "AvailableQuests.Draw"))

            assert.are_same({{calleeKey = "QuestieDB.GetQuest", calls = 3, totalTime = 150}}, callees)
        end)

        it("orders callees by the time they cost", function()
            AddFunctionEntry("AvailableQuests.Draw", 200, 4)
            AddFunctionEntry("Cheap.Work", 10, 5)
            AddFunctionEntry("Expensive.Work", 190, 1)
            AddCallerEntry("Cheap.Work", "AvailableQuests.Draw", 5, 10)
            AddCallerEntry("Expensive.Work", "AvailableQuests.Draw", 1, 190)

            local callees = BuildCalleeList(FindRow(BuildReport(), "AvailableQuests.Draw"))

            assert.are_same("Expensive.Work", callees[1].calleeKey)
        end)

        it("returns nothing for a row that called nothing profiled", function()
            AddFunctionEntry("QuestieDB.GetQuest", 150, 3)
            AddCallerEntry("QuestieDB.GetQuest", "AvailableQuests.Draw", 3, 150)

            assert.are_same({}, BuildCalleeList(FindRow(BuildReport(), "QuestieDB.GetQuest")))
        end)

        it("does not mistake a caller for a callee", function()
            AddFunctionEntry("AvailableQuests.Draw", 200, 4)
            AddFunctionEntry("QuestieDB.GetQuest", 150, 3)
            AddCallerEntry("QuestieDB.GetQuest", "AvailableQuests.Draw", 3, 150)

            local callers = BuildCallerList(FindRow(BuildReport(), "AvailableQuests.Draw"))

            assert.are_same({}, callers)
        end)

        it("lists what a ThreadLib job scheduled", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)
            AddFunctionEntry("AvailableQuests.Draw", 500, 697)
            AddCallerEntry("AvailableQuests.Draw", "ThreadLib job: _DrawAvailableQuest", 697, 500)

            local callees = BuildCalleeList(FindRow(BuildReport(), "ThreadLib job: _DrawAvailableQuest"))

            assert.are_same("AvailableQuests.Draw", callees[1].calleeKey)
            assert.are_same(697, callees[1].calls)
        end)

        it("folds the callees of every path a grouped row merged", function()
            AddFunctionEntry("QuestieDB.private.GetQuest", 40, 2)
            AddFunctionEntry("QuestieDB.GetQuest", 60, 3)
            AddFunctionEntry("QuestieLib.Trim", 20, 5)
            AddCallerEntry("QuestieLib.Trim", "QuestieDB.private.GetQuest", 2, 8)
            AddCallerEntry("QuestieLib.Trim", "QuestieDB.GetQuest", 3, 12)

            local callees = BuildCalleeList(FindRow(BuildReport({grouped = true}), "QuestieDB.GetQuest"), true)

            assert.are_same({{calleeKey = "QuestieLib.Trim", calls = 5, totalTime = 20}}, callees)
        end)

        it("names grouped callees by their grouped identity", function()
            AddFunctionEntry("AvailableQuests.Draw", 200, 4)
            AddFunctionEntry("QuestieDB.private.GetQuest", 150, 3)
            AddCallerEntry("QuestieDB.private.GetQuest", "AvailableQuests.Draw", 3, 150)

            local callees = BuildCalleeList(FindRow(BuildReport({grouped = true}), "AvailableQuests.Draw"), true)

            assert.are_same("QuestieDB.GetQuest", callees[1].calleeKey)
        end)

        it("returns nothing for a loaded file, which calls nothing", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 19.6

            assert.are_same({}, BuildCalleeList(FindRow(BuildReport(), "Database/Zones/zoneDB.lua")))
        end)
    end)

    describe("resolving a followed relation", function()
        it("finds a row the scope filter excluded, so following a caller does not go blank", function()
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 200, 4)
            AddFunctionEntry("Cleanup.Run", 50, 1)

            -- The list is scoped to QuestieMap, but a relation can point anywhere.
            local scoped = BuildReport({scopePrefix = "QuestieMap"})
            local unscoped = BuildReport()

            assert.is_nil(FindRow(scoped, "Cleanup.Run"))
            assert.is_not_nil(FindRow(unscoped, "Cleanup.Run"))
        end)
    end)

    describe("sorting", function()
        before_each(function()
            AddFunctionEntry("Alpha.Slow", 300, 2)
            AddFunctionEntry("Beta.Frequent", 100, 50)
            AddFunctionEntry("Gamma.Expensive", 200, 1)
        end)

        it("orders by total time descending by default", function()
            assert.are_same({"Alpha.Slow", "Gamma.Expensive", "Beta.Frequent"}, RowKeys(BuildReport()))
        end)

        it("orders by total time ascending when the direction is reversed", function()
            local report = BuildReport({sortKey = "total", descending = false})

            assert.are_same({"Beta.Frequent", "Gamma.Expensive", "Alpha.Slow"}, RowKeys(report))
        end)

        it("orders by call count", function()
            local report = BuildReport({sortKey = "calls", descending = true})

            assert.are_same({"Beta.Frequent", "Alpha.Slow", "Gamma.Expensive"}, RowKeys(report))
        end)

        it("orders by average time", function()
            local report = BuildReport({sortKey = "average", descending = true})

            assert.are_same({"Gamma.Expensive", "Alpha.Slow", "Beta.Frequent"}, RowKeys(report))
        end)

        it("orders by identity", function()
            local report = BuildReport({sortKey = "name", descending = false})

            assert.are_same({"Alpha.Slow", "Beta.Frequent", "Gamma.Expensive"}, RowKeys(report))
        end)

        it("breaks equal values by identity so refreshes keep a stable order", function()
            Profiler.hookCallCount = {}
            Profiler.hookTimeCount = {}
            Profiler.lowerCaseLookup = {}
            AddFunctionEntry("Zulu.Work", 100, 1)
            AddFunctionEntry("Alpha.Work", 100, 1)
            AddFunctionEntry("Mike.Work", 100, 1)

            local report = BuildReport({sortKey = "total", descending = true})

            assert.are_same({"Alpha.Work", "Mike.Work", "Zulu.Work"}, RowKeys(report))
        end)
    end)

    describe("filtering", function()
        it("matches case-insensitively", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 100, 2)

            assert.are_same({"QuestieDB.GetQuest"}, RowKeys(BuildReport({filter = "GETQUEST"})))
        end)

        it("matches anywhere in the path", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)

            assert.are_same({"QuestieDB.GetQuest"}, RowKeys(BuildReport({filter = "iedb"})))
        end)

        it("returns every row when the filter is cleared", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 100, 2)

            assert.are_same(2, BuildReport({filter = ""}).matchedCount)
        end)

        it("matches a folded-away path prefix in grouped view", function()
            AddFunctionEntry("QuestieDB.private.GetQuest", 40, 2)

            -- "private" is folded out of the identity, so only the original path can match it.
            local report = BuildReport({filter = "private", grouped = true})

            assert.are_same({"QuestieDB.GetQuest"}, RowKeys(report))
        end)
    end)

    describe("grouped view", function()
        it("shortens a job named after a function the same way it shortens the function", function()
            AddFunctionEntry("QuestieInit.private.StartStageCoroutine", 0, 1)
            AddThreadJobEntry("ThreadLib job: QuestieInit.private.StartStageCoroutine", 392, 1, 6)

            local report = BuildReport({grouped = true})

            -- Both rows describe the same function; spelling them differently made them read as unrelated.
            assert.are_same("QuestieInit.StartStageCoroutine",
                FindRow(report, "QuestieInit.StartStageCoroutine").displayName)
            assert.are_same("QuestieInit.StartStageCoroutine",
                FindRow(report, "ThreadLib job: QuestieInit.StartStageCoroutine").displayName)
        end)

        it("leaves a job named after a call site whole, because a path has no module segments", function()
            AddThreadJobEntry("ThreadLib job: Modules/Quest/QuestieQuest.lua:105", 12, 1, 1)

            local report = BuildReport({grouped = true})

            assert.are_same("Modules/Quest/QuestieQuest.lua:105",
                FindRow(report, "ThreadLib job: Modules/Quest/QuestieQuest.lua:105").displayName)
        end)

        it("sums totals and calls across folded paths", function()
            AddFunctionEntry("QuestieDB.private.GetQuest", 40, 2)
            AddFunctionEntry("QuestieDB.GetQuest", 60, 3)

            local row = FindRow(BuildReport({grouped = true}), "QuestieDB.GetQuest")

            assert.are_same(100, row.totalTime)
            assert.are_same(5, row.calls)
        end)

        it("recalculates the average from the aggregated totals", function()
            AddFunctionEntry("QuestieDB.private.GetQuest", 40, 2)
            AddFunctionEntry("QuestieDB.GetQuest", 60, 3)

            local row = FindRow(BuildReport({grouped = true}), "QuestieDB.GetQuest")

            assert.are_same(20, row.averageTime)
        end)

        it("records the full paths that were merged", function()
            AddFunctionEntry("QuestieDB.private.GetQuest", 40, 2)
            AddFunctionEntry("QuestieDB.GetQuest", 60, 3)

            local row = FindRow(BuildReport({grouped = true}), "QuestieDB.GetQuest")
            table.sort(row.mergedPaths)

            assert.are_same({"QuestieDB.GetQuest", "QuestieDB.private.GetQuest"},
                row.mergedPaths)
        end)

        it("keeps distinct functions apart that share a module and a leaf name", function()
            -- The earlier rule folded these into one QuestieOptions.Initialize row, hiding which tab was slow.
            AddFunctionEntry("QuestieOptions.tabs.advanced.Initialize", 30, 1)
            AddFunctionEntry("QuestieOptions.tabs.icons.Initialize", 20, 1)

            local report = BuildReport({grouped = true})
            local keys = RowKeys(report)
            table.sort(keys)

            assert.are_same({"QuestieOptions.tabs.advanced.Initialize", "QuestieOptions.tabs.icons.Initialize"}, keys)
        end)

        it("keeps a numeric segment, which can be the identity itself", function()
            -- QuestieInit.Stages.1/2/3 are different startup phases; folding the index hides which is slow.
            AddFunctionEntry("QuestieInit.Stages.1", 10, 1)
            AddFunctionEntry("QuestieInit.Stages.2", 20, 1)

            local keys = RowKeys(BuildReport({grouped = true}))
            table.sort(keys)

            assert.are_same({"QuestieInit.Stages.1", "QuestieInit.Stages.2"}, keys)
        end)

        it("leaves an addon-load path alone, since a file is not a module path", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 19.6

            assert.are_same({"Database/Zones/zoneDB.lua"}, RowKeys(BuildReport({grouped = true})))
        end)

        it("drops the private indirection segment", function()
            AddFunctionEntry("QuestieDB.private.CheckAchievementRequirements", 10, 1)

            assert.are_same({"QuestieDB.CheckAchievementRequirements"}, RowKeys(BuildReport({grouped = true})))
        end)

        it("leaves a two-segment path unchanged", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)

            assert.are_same({"QuestieDB.GetQuest"}, RowKeys(BuildReport({grouped = true})))
        end)

        it("keeps ThreadLib job identities intact", function()
            AddThreadJobEntry("ThreadLib job: [Interface/AddOns/Questie/Modules/QuestieInit.lua]:395", 600, 3, 40)

            local report = BuildReport({grouped = true})

            assert.are_same({"ThreadLib job: [Interface/AddOns/Questie/Modules/QuestieInit.lua]:395"}, RowKeys(report))
        end)

        it("keeps ThreadLib job and resume counts when folding", function()
            AddThreadJobEntry("ThreadLib job: Draw", 600, 3, 40)

            local row = FindRow(BuildReport({grouped = true}), "ThreadLib job: Draw")

            assert.are_same(3, row.jobCalls)
            assert.are_same(40, row.resumeCount)
        end)
    end)

    describe("addon load rows", function()
        it("reports a loaded file with its duration and allocation", function()
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 202.5
            Profiler.fileLoadMemory["Localization/lookups/lookupZones.lua"] = 18092

            local row = FindRow(BuildReport(), "Localization/lookups/lookupZones.lua")

            assert.are_same(202.5, row.totalTime)
            assert.are_same(18092, row.memoryKilobytes)
            assert.is_true(row.isFileLoad)
        end)

        it("has no call count, because a loaded file is not a call", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 19.6

            local row = FindRow(BuildReport(), "Database/Zones/zoneDB.lua")

            assert.is_false(row.hasCalls)
            assert.is_false(row.isThreadJob)
        end)

        it("reports no self time, which for a file is its total to within a rounding error", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 19.6

            local row = FindRow(BuildReport(), "Database/Zones/zoneDB.lua")

            assert.is_false(row.hasSelfTime)
        end)

        it("survives the idle filter, which has no meaning for a file", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 19.6

            assert.are_same({"Database/Zones/zoneDB.lua"}, RowKeys(BuildReport({hideIdle = true})))
        end)

        it("is filterable by path", function()
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 202.5
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 19.6

            assert.are_same({"Localization/lookups/lookupZones.lua"}, RowKeys(BuildReport({filter = "LOOKUPS"})))
        end)

        it("sorts alongside functions by total time", function()
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 202.5
            AddFunctionEntry("QuestieDB.GetQuest", 50, 4)

            assert.are_same({"Localization/lookups/lookupZones.lua", "QuestieDB.GetQuest"}, RowKeys(BuildReport()))
        end)
    end)

    describe("session totals", function()
        local function SessionTotals()
            return ProfilerUI.private.BuildSessionTotals(Profiler)
        end

        it("counts and sums loaded files", function()
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 200
            Profiler.fileLoadMemory["Localization/lookups/lookupZones.lua"] = 18092
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 20
            Profiler.fileLoadMemory["Database/Zones/zoneDB.lua"] = 2140

            local totals = SessionTotals()

            assert.are_same(2, totals.fileCount)
            assert.are_same(220, totals.fileTime)
            assert.are_same(20232, totals.fileMemory)
        end)

        it("sums functions by self time, not inclusive time", function()
            -- Outer's 100ms contains Inner's 40ms. Adding the inclusive figures would report 140ms of work
            -- for 100ms of elapsed time, charging Inner's milliseconds twice.
            AddFunctionEntry("Module.Outer", 100, 1, 60)
            AddFunctionEntry("Module.Inner", 40, 1, 40)

            local totals = SessionTotals()

            assert.are_same(100, totals.functionSelfTime)
        end)

        it("counts every function and its calls, including never-called ones", function()
            AddFunctionEntry("Module.Called", 10, 4, 10)
            AddFunctionEntry("Module.NeverCalled", 0, 0, 0)

            local totals = SessionTotals()

            assert.are_same(2, totals.functionCount)
            assert.are_same(4, totals.functionCalls)
        end)

        it("keeps jobs out of the function totals", function()
            AddFunctionEntry("Module.Work", 10, 2, 10)
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)

            local totals = SessionTotals()

            assert.are_same(1, totals.functionCount)
            assert.are_same(1, totals.jobCount)
            assert.are_same(600, totals.jobTime)
        end)

        it("ignores the view filters, since a denominator that moves is circular", function()
            AddFunctionEntry("Module.Work", 10, 2, 10)
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 20

            -- Whatever the report is currently showing, the totals describe the session.
            BuildReport({showFiles = false, showFunctions = false, filter = "nothing matches this"})
            local totals = SessionTotals()

            assert.are_same(1, totals.functionCount)
            assert.are_same(1, totals.fileCount)
        end)

        it("reports zeroes for an empty session", function()
            local totals = SessionTotals()

            assert.are_same(0, totals.fileCount)
            assert.are_same(0, totals.functionCount)
            assert.are_same(0, totals.jobCount)
            assert.are_same(0, totals.functionSelfTime)
        end)
    end)

    describe("species filtering", function()
        local function AddOneOfEach()
            AddFunctionEntry("QuestieDB.GetQuest", 50, 4)
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 19.6
        end

        it("shows every species by default", function()
            AddOneOfEach()

            assert.are_same(3, BuildReport().matchedCount)
        end)

        it("hides functions when they are switched off", function()
            AddOneOfEach()

            local report = BuildReport({showFunctions = false})

            assert.are_same({"ThreadLib job: _DrawAvailableQuest", "Database/Zones/zoneDB.lua"},
                RowKeys(BuildReport({showFunctions = false, sortKey = "total", descending = true})))
            assert.are_same(2, report.matchedCount)
        end)

        it("hides files when they are switched off", function()
            AddOneOfEach()

            local keys = RowKeys(BuildReport({showFiles = false, sortKey = "total", descending = true}))

            assert.are_same({"ThreadLib job: _DrawAvailableQuest", "QuestieDB.GetQuest"}, keys)
        end)

        it("shows one species alone", function()
            AddOneOfEach()

            local report = BuildReport({showFunctions = false, showJobs = false})

            assert.are_same({"Database/Zones/zoneDB.lua"}, RowKeys(report))
        end)

        it("returns nothing when every species is switched off", function()
            AddOneOfEach()

            local report = BuildReport({showFunctions = false, showJobs = false, showFiles = false})

            assert.are_same({}, RowKeys(report))
        end)

        it("counts a hidden species, so the control can say what it hides", function()
            AddOneOfEach()

            local report = BuildReport({showFunctions = false, showFiles = false})

            assert.are_same(1, report.speciesCounts.functions)
            assert.are_same(1, report.speciesCounts.jobs)
            assert.are_same(1, report.speciesCounts.files)
        end)

        it("counts grouped rows rather than the paths behind them", function()
            AddFunctionEntry("QuestieDB.private.GetQuest", 40, 2)
            AddFunctionEntry("QuestieDB.GetQuest", 60, 3)

            local report = BuildReport({grouped = true})

            assert.are_same(1, report.speciesCounts.functions)
        end)

        it("counts only what the text filter matched", function()
            AddOneOfEach()

            local report = BuildReport({filter = "zonedb"})

            assert.are_same(0, report.speciesCounts.functions)
            assert.are_same(1, report.speciesCounts.files)
        end)

        it("scales the heat maximum to the visible species", function()
            AddOneOfEach()

            -- The 600ms job would otherwise flatten every function bar.
            assert.are_same(50, BuildReport({showJobs = false, showFiles = false}).maxTotalTime)
        end)

        it("sorts by allocation", function()
            Profiler.fileLoadTime["big.lua"] = 10
            Profiler.fileLoadMemory["big.lua"] = 18092
            Profiler.fileLoadTime["small.lua"] = 90
            Profiler.fileLoadMemory["small.lua"] = 12

            local keys = RowKeys(BuildReport({sortKey = "memory", descending = true}))

            assert.are_same({"big.lua", "small.lua"}, keys)
        end)
    end)

    describe("hierarchy tree", function()
        local function BuildTree(options)
            return ProfilerUI.private.BuildTree(BuildReport(options).rows)
        end

        ---@return ProfilerTreeNode?
        local function FindChild(node, label)
            for _, child in ipairs(node.children) do
                if child.label == label then
                    return child
                end
            end
            return nil
        end

        it("groups files by directory", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 20
            Profiler.fileLoadTime["Database/Classic/classicItemDB.lua"] = 30

            local database = FindChild(BuildTree(), "Database")

            assert.are_same(50, database.cost)
            assert.are_same(2, database.rowCount)
        end)

        it("rolls a subtree's time into every ancestor", function()
            Profiler.fileLoadTime["Database/Corrections/Automatic/one.lua"] = 10
            Profiler.fileLoadTime["Database/Corrections/Automatic/two.lua"] = 15

            local database = FindChild(BuildTree(), "Database")
            local corrections = FindChild(database, "Corrections")
            local automatic = FindChild(corrections, "Automatic")

            assert.are_same(25, database.cost)
            assert.are_same(25, corrections.cost)
            assert.are_same(25, automatic.cost)
        end)

        it("groups functions by module path", function()
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 40, 2)
            AddFunctionEntry("QuestieMap.DrawWaypoints", 60, 3)
            AddFunctionEntry("QuestieDB.GetQuest", 5, 1)

            local questieMap = FindChild(BuildTree(), "QuestieMap")

            assert.are_same(100, questieMap.cost)
            assert.are_same(2, questieMap.rowCount)
        end)

        it("rolls up function self time, so a caller and its callee are not counted twice", function()
            -- DrawWorldIcon's 10 ms includes the 3 ms it spent inside DrawWaypoints. Rolling up inclusive
            -- totals would report 13 ms for a module that only ever spent 10.
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 10, 1, 7)
            AddFunctionEntry("QuestieMap.DrawWaypoints", 3, 1)

            local questieMap = FindChild(BuildTree(), "QuestieMap")

            assert.are_same(10, questieMap.cost)
        end)

        it("rolls up job and file totals, which have no nesting to double count", function()
            AddThreadJobEntry("ThreadLib job: Draw", 600, 3, 40)
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 20

            local tree = BuildTree()

            assert.are_same(600, FindChild(tree, "ThreadLib jobs").cost)
            assert.are_same(20, FindChild(tree, "Database").cost)
        end)

        it("collects jobs under one node, since a job has no path", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)

            local jobs = FindChild(BuildTree(), "ThreadLib jobs")

            assert.are_same(600, jobs.cost)
        end)

        it("orders siblings by cost", function()
            AddFunctionEntry("Alpha.Cheap", 5, 1)
            AddFunctionEntry("Zulu.Expensive", 500, 1)

            local root = BuildTree()

            assert.are_same("Zulu", root.children[1].label)
        end)

        it("carries a prefix that scopes the list to that subtree", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 20
            Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"] = 200

            local database = FindChild(BuildTree(), "Database")
            local scoped = BuildReport({scopePrefix = database.prefix})

            assert.are_same({"Database/Zones/zoneDB.lua"}, RowKeys(scoped))
        end)

        it("scopes functions by module prefix", function()
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 40, 2)
            AddFunctionEntry("QuestieDB.GetQuest", 5, 1)

            assert.are_same({"QuestieMap.DrawWorldIcon"}, RowKeys(BuildReport({scopePrefix = "QuestieMap."})))
        end)

        it("scopes jobs through their synthetic node", function()
            AddThreadJobEntry("ThreadLib job: _DrawAvailableQuest", 600, 3, 40)
            AddFunctionEntry("QuestieDB.GetQuest", 5, 1)

            local keys = RowKeys(BuildReport({scopePrefix = "ThreadLib jobs "}))

            assert.are_same({"ThreadLib job: _DrawAvailableQuest"}, keys)
        end)

        it("shows only the top level until a node is expanded", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 20

            local lines = ProfilerUI.private.FlattenTree(BuildTree(), {})

            assert.are_same(1, #lines)
            assert.are_same("Database", lines[1].node.label)
            assert.is_true(lines[1].hasChildren)
        end)

        it("reveals children of an expanded node", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 20

            local lines = ProfilerUI.private.FlattenTree(BuildTree(), {["Database/"] = true})

            assert.are_same(2, #lines)
            assert.are_same("Zones", lines[2].node.label)
            assert.are_same(1, lines[2].depth)
        end)
    end)

    describe("hiding files after a measurement reset", function()
        local function HideFiles()
            ProfilerUI.private.HideFilesAfterMeasurementReset()
        end

        it("unticks files, because a reset leaves them above everything being measured", function()
            ProfilerUI.private.displayState.showFiles = true

            HideFiles()

            assert.is_false(ProfilerUI.private.displayState.showFiles)
        end)

        it("leaves functions and jobs alone", function()
            ProfilerUI.private.displayState.showFunctions = true
            ProfilerUI.private.displayState.showJobs = true

            HideFiles()

            assert.is_true(ProfilerUI.private.displayState.showFunctions)
            assert.is_true(ProfilerUI.private.displayState.showJobs)
        end)

        it("leaves a files-only view alone, rather than emptying the list", function()
            ProfilerUI.private.displayState.showFunctions = false
            ProfilerUI.private.displayState.showJobs = false
            ProfilerUI.private.displayState.showFiles = true

            HideFiles()

            assert.is_true(ProfilerUI.private.displayState.showFiles)
        end)
    end)

    describe("hierarchy scope lifecycle", function()
        it("clears a file scope when Reset hides file rows", function()
            AddFunctionEntry("QuestieDB.GetQuest", 20, 1)
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 100
            ProfilerUI:Show()
            ProfilerUI.private.displayState.scopePrefix = "Database/"
            ProfilerUI.private.displayState.scopeLabel = "Database/"
            ProfilerUI:Refresh()

            local resetButton = FindFrameByText("Reset")
            resetButton.scripts.OnClick(resetButton)

            assert.are_same("", ProfilerUI.private.displayState.scopePrefix)

            AddFunctionEntry("QuestieDB.GetQuest", 30, 1)
            ProfilerUI:Refresh()

            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
        end)

        it("clears a function scope when function rows are hidden", function()
            AddThreadJobEntry("ThreadLib job: Draw", 20, 1, 1)
            ProfilerUI.private.displayState.scopePrefix = "QuestieDB."
            ProfilerUI.private.displayState.scopeLabel = "QuestieDB."
            ProfilerUI.private.displayState.showFunctions = false

            ProfilerUI:Show()

            assert.are_same("", ProfilerUI.private.displayState.scopePrefix)
            assert.are_same({"ThreadLib job: Draw"}, RenderedRowKeys())
        end)

        it("clears a job scope when job rows are hidden", function()
            AddFunctionEntry("QuestieDB.GetQuest", 20, 1)
            ProfilerUI.private.displayState.scopePrefix = "ThreadLib jobs "
            ProfilerUI.private.displayState.scopeLabel = "ThreadLib jobs "
            ProfilerUI.private.displayState.showJobs = false

            ProfilerUI:Show()

            assert.are_same("", ProfilerUI.private.displayState.scopePrefix)
            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
        end)

        it("clears an active scope when its footer control is clicked", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 100
            ProfilerUI:Show()

            local scopeText = FindFrameByText("Click a node to narrow the list")
            assert.is_not_nil(scopeText)
            local scopeButton = scopeText.parent
            assert.are_same("Button", scopeButton.frameType)
            assert.is_false(scopeButton:IsEnabled())

            ProfilerUI.private.displayState.scopePrefix = "Database/"
            ProfilerUI.private.displayState.scopeLabel = "Database/"
            ProfilerUI:Refresh()
            assert.is_true(scopeButton:IsEnabled())

            scopeButton.scripts.OnClick(scopeButton)

            assert.are_same("", ProfilerUI.private.displayState.scopePrefix)
            assert.is_false(scopeButton:IsEnabled())
        end)
    end)

    describe("idle filtering", function()
        it("hides entries that were never called and reports how many", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddFunctionEntry("QuestieDB.NeverCalled", 0, 0)

            local report = BuildReport({hideIdle = true})

            assert.are_same({"QuestieDB.GetQuest"}, RowKeys(report))
            assert.are_same(1, report.idleHiddenCount)
            assert.are_same(2, report.totalCount)
        end)

        it("shows never-called entries when the filter is off", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddFunctionEntry("QuestieDB.NeverCalled", 0, 0)

            local report = BuildReport({hideIdle = false})

            assert.are_same(2, report.matchedCount)
            assert.are_same(0, report.idleHiddenCount)
        end)
    end)

    describe("window lifecycle", function()
        it("creates the window hidden", function()
            ProfilerUI:Create()

            assert.is_false(ProfilerUI:IsShown())
        end)

        it("returns the same window when created twice", function()
            assert.are_equal(ProfilerUI:Create(), ProfilerUI:Create())
        end)

        it("shows the window", function()
            ProfilerUI:Show()

            assert.is_true(ProfilerUI:IsShown())
        end)

        it("hides the window without stopping the session", function()
            ProfilerUI:Show()

            ProfilerUI:Hide()

            assert.is_false(ProfilerUI:IsShown())
            assert.is_true(Profiler.active)
        end)

        it("hides without creating a window when none exists", function()
            ProfilerUI:Hide()

            assert.is_nil(FindFrameByName("QuestieProfilerFrame"))
        end)

        it("can be reopened after being closed", function()
            ProfilerUI:Show()
            ProfilerUI:Hide()

            ProfilerUI:Show()

            assert.is_true(ProfilerUI:IsShown())
        end)

        it("registers the window as a special frame exactly once", function()
            ProfilerUI:Create()
            ProfilerUI:Create()

            assert.are_same({"QuestieProfilerFrame"}, _G.UISpecialFrames)
        end)

        it("retains the stopped report view when a new session cannot start", function()
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 100
            ProfilerUI:Show()
            Profiler.active = false
            Profiler.Start = function()
                return false
            end
            ProfilerUI.private.displayState.scopePrefix = "Database/"
            ProfilerUI.private.displayState.scopeLabel = "Database/"
            ProfilerUI.private.displayState.frozen = true
            ProfilerUI:Refresh()

            local startButton = FindFrameByText("Start")
            startButton.scripts.OnClick(startButton)

            assert.is_true(ProfilerUI.private.displayState.frozen)
            assert.is_true(ProfilerUI.private.displayState.showFiles)
            assert.are_same("Database/", ProfilerUI.private.displayState.scopePrefix)
            assert.are_same({"Database/Zones/zoneDB.lua"}, RenderedRowKeys())
        end)
    end)

    describe("active session indicator", function()
        it("is not created on a client that never profiles", function()
            assert.is_nil(FindFrameByName("QuestieProfilerIndicator"))
        end)

        it("exists without the window ever being opened", function()
            -- StartStartup(showUI = false) arms a session and calls Hide; no window is ever built.
            ProfilerUI:Hide()

            assert.is_not_nil(FindFrameByName("QuestieProfilerIndicator"))
            assert.is_nil(FindFrameByName("QuestieProfilerFrame"))
        end)

        it("is shown while the session is active", function()
            ProfilerUI:Hide()

            ProfilerUI.private.UpdateIndicator()

            assert.is_true(ProfilerUI.private.IsIndicatorShown())
        end)

        it("is hidden once the session stops", function()
            ProfilerUI:Hide()
            Profiler.active = false

            ProfilerUI.private.UpdateIndicator()

            assert.is_false(ProfilerUI.private.IsIndicatorShown())
        end)

        it("returns when a stopped session is started again", function()
            ProfilerUI:Hide()
            Profiler.active = false
            ProfilerUI.private.UpdateIndicator()

            Profiler.active = true
            ProfilerUI.private.UpdateIndicator()

            assert.is_true(ProfilerUI.private.IsIndicatorShown())
        end)

        it("tracks a session stopped while the window is closed", function()
            ProfilerUI:Show()
            ProfilerUI:Hide()

            Profiler.active = false
            ProfilerUI.private.UpdateIndicator()

            assert.is_false(ProfilerUI.private.IsIndicatorShown())
        end)

        it("opens a closed window when clicked", function()
            ProfilerUI:Hide()
            local indicator = FindFrameByName("QuestieProfilerIndicator")

            indicator.scripts.OnClick(indicator)

            assert.is_true(ProfilerUI:IsShown())
        end)

        it("closes an open window when clicked", function()
            ProfilerUI:Show()
            local indicator = FindFrameByName("QuestieProfilerIndicator")

            indicator.scripts.OnClick(indicator)

            assert.is_false(ProfilerUI:IsShown())
        end)

        it("toggles the window back open on a second click", function()
            ProfilerUI:Show()
            local indicator = FindFrameByName("QuestieProfilerIndicator")

            indicator.scripts.OnClick(indicator)
            indicator.scripts.OnClick(indicator)

            assert.is_true(ProfilerUI:IsShown())
        end)

        it("stays visible while toggling the window", function()
            ProfilerUI:Hide()
            local indicator = FindFrameByName("QuestieProfilerIndicator")

            indicator.scripts.OnClick(indicator)
            indicator.scripts.OnClick(indicator)

            assert.is_true(ProfilerUI.private.IsIndicatorShown())
        end)
    end)

    describe("deferred startup visibility", function()
        it("restores the window when entering the world with the show intent standing", function()
            local frame = ProfilerUI:Show()
            frame:Hide()

            FireEvent("PLAYER_ENTERING_WORLD")

            assert.is_true(ProfilerUI:IsShown())
        end)

        it("does not undo an explicit hide when entering the world", function()
            ProfilerUI:Show()
            ProfilerUI:Hide()

            FireEvent("PLAYER_ENTERING_WORLD")

            assert.is_false(ProfilerUI:IsShown())
        end)

        it("does not open a window the user never asked for", function()
            ProfilerUI:Create()

            FireEvent("PLAYER_ENTERING_WORLD")

            assert.is_false(ProfilerUI:IsShown())
        end)
    end)

    describe("refresh activity", function()
        it("refreshes automatically while shown and active", function()
            ProfilerUI:Show()

            assert.is_true(ProfilerUI.private.IsRefreshTickerActive())
        end)

        it("stops refreshing when hidden", function()
            ProfilerUI:Show()

            ProfilerUI:Hide()

            assert.is_false(ProfilerUI.private.IsRefreshTickerActive())
        end)

        it("stops refreshing when the session is stopped", function()
            ProfilerUI:Show()

            Profiler.active = false
            ProfilerUI:Refresh()

            assert.is_false(ProfilerUI.private.IsRefreshTickerActive())
        end)

        it("keeps results available after the session stops", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            ProfilerUI:Show()

            Profiler.active = false
            ProfilerUI:Refresh()

            -- Asserted on the rendered list, not on BuildReport: a refresh that cleared the display on an
            -- inactive session would leave these frames empty while BuildReport still returned the row.
            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
            assert.is_true(ProfilerUI:IsShown())
        end)
    end)

    describe("freezing the display", function()
        it("stops automatic refresh without stopping the session", function()
            ProfilerUI:Show()

            ProfilerUI.private.displayState.frozen = true
            ProfilerUI:Refresh()

            assert.is_false(ProfilerUI.private.IsRefreshTickerActive())
            assert.is_true(Profiler.active)
        end)

        it("resumes automatic refresh when unfrozen", function()
            ProfilerUI:Show()
            ProfilerUI.private.displayState.frozen = true
            ProfilerUI:Refresh()

            ProfilerUI.private.displayState.frozen = false
            ProfilerUI:Refresh()

            assert.is_true(ProfilerUI.private.IsRefreshTickerActive())
        end)

        it("still refreshes manually while frozen", function()
            ProfilerUI:Show()
            ProfilerUI.private.displayState.frozen = true
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)

            ProfilerUI:Refresh()

            -- The measurement arrived after Show's render, so only the manual refresh can have put this row
            -- on screen - the assertion fails if Refresh is a no-op while frozen.
            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
        end)
    end)

    describe("relation navigation", function()
        ---Concatenates every non-empty text the window currently shows, so assertions can look for the
        ---detail strip's measurements without knowing which pooled frame carries them.
        local function ShownTexts()
            local texts = {}
            for _, frame in ipairs(frameRegistry) do
                local value = frame.GetText and frame:GetText()
                if type(value) == "string" and value ~= "" then
                    table.insert(texts, value)
                end
            end
            return table.concat(texts, "\n")
        end

        it("resolves a selection the active filters exclude, so a relation click cannot clear the panel", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddThreadJobEntry("ThreadLib job: Draw", 600, 3, 40)
            ProfilerUI:Show()

            -- The search excludes the job, as if the user filtered while inspecting the function and then
            -- clicked the job in its relations panel.
            ProfilerUI.private.displayState.filter = "GetQuest"
            ProfilerUI.private.displayState.selectedKey = "ThreadLib job: Draw"
            ProfilerUI:Refresh()

            assert.is_truthy(string.find(ShownTexts(), "600.000 ms total", 1, true))
        end)

        it("shows the (root) caller as context, not as a drill-down target", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddCallerEntry("QuestieDB.GetQuest", "(root)", 3, 150)
            AddCallerEntry("QuestieDB.GetQuest", "QuestieMap.DrawWorldIcon", 1, 50)
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 50, 1)
            ProfilerUI:Show()

            ProfilerUI.private.displayState.selectedKey = "QuestieDB.GetQuest"
            ProfilerUI:Refresh()

            local rootEntry, callerEntry
            for _, frame in ipairs(frameRegistry) do
                -- Only relation entries carry a relationSummary; the list rows share the same names.
                local nameText = rawget(frame, "nameText")
                if nameText and rawget(frame, "relationSummary") then
                    if nameText:GetText() == "(root)" then
                        rootEntry = frame
                    elseif nameText:GetText() == "QuestieMap.DrawWorldIcon" then
                        callerEntry = frame
                    end
                end
            end
            -- No report row answers to "(root)", so clicking it could only clear the selection.
            assert.is_truthy(rootEntry)
            assert.is_nil(rawget(rootEntry, "identity"))
            -- A real caller in the same list keeps its drill-down.
            assert.is_truthy(callerEntry)
            assert.are_same("QuestieMap.DrawWorldIcon", rawget(callerEntry, "identity"))
        end)
    end)

    describe("slash command", function()
        it("reopens a stopped session's retained results without resetting them", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            ProfilerUI:Show()
            Profiler.active = false
            ProfilerUI:Refresh()
            ProfilerUI:Hide()

            _G.SlashCmdList["QUESTIEPROFILER"]("show")

            assert.is_true(ProfilerUI:IsShown())
            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
        end)

        it("does not open a window when nothing was ever measured", function()
            Profiler.active = false

            _G.SlashCmdList["QUESTIEPROFILER"]("show")

            assert.is_false(ProfilerUI:IsShown())
        end)
    end)
end)
