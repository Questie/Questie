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
    local function CreateFrameMock(frameType, frameName)
        local scripts = {}
        local registeredEvents = {}
        local isShown = true
        local text = ""
        local enabled = true

        local frame
        frame = {
            frameType = frameType,
            frameName = frameName,
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
            CreateFontString = function()
                return CreateFrameMock("FontString")
            end,
            CreateTexture = function()
                return CreateFrameMock("Texture")
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
        frame.fontString = frameType ~= "FontString" and CreateFrameMock("FontString") or nil

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
            end,
            ResetMeasurements = function() end,
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

    ---Registers one ThreadLib job measurement on the profiler stub.
    local function AddThreadJobEntry(lookupKey, totalTime, jobCalls, resumeCount)
        Profiler.hookCallCount[lookupKey] = jobCalls
        Profiler.hookTimeCount[lookupKey] = totalTime
        Profiler.hookSelfTime[lookupKey] = totalTime
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

            assert.are_same({"QuestieDB.GetQuest"}, RowKeys(BuildReport()))
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

            assert.are_same({"QuestieDB.GetQuest"}, RowKeys(BuildReport()))
        end)
    end)
end)
