dofile("setupTests.lua")

describe("QuestieProfilerUI", function()
    ---@type QuestieProfilerUI
    local ProfilerUI
    ---@type QuestieProfiler
    local Profiler
    ---@type QuestieProfilerReport
    local ProfilerReport
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
        return ProfilerReport.BuildCallerList(Profiler, reportRow, grouped == true)
    end

    ---@return ProfilerCalleeEntry[]
    local function BuildCalleeList(reportRow, grouped)
        return ProfilerReport.BuildCalleeList(Profiler, reportRow, grouped == true)
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
        return ProfilerReport.BuildReport(Profiler, options or {})
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

        -- The window aliases the report's formatters at file scope, so the report has to exist first.
        QuestieLoader._modules.ProfilerReport = nil
        dofile("Modules/Profiler/QuestieProfilerReport.lua")
        ProfilerReport = QuestieLoader:ImportModule("ProfilerReport")

        QuestieLoader._modules.ProfilerUI = nil
        dofile("Modules/Profiler/QuestieProfilerUI.lua")
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
        QuestieLoader._modules.ProfilerReport = nil
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

        it("falls back to total time when Reset hides the active Allocated sort", function()
            AddFunctionEntry("Alpha.Fast", 10, 1)
            AddFunctionEntry("Zulu.Slow", 100, 1)
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 50
            Profiler.fileLoadMemory["Database/Zones/zoneDB.lua"] = 1000
            ProfilerUI:Show()
            ProfilerUI.private.displayState.sortKey = "memory"
            ProfilerUI.private.displayState.descending = false
            ProfilerUI:Refresh()

            local resetButton = FindFrameByText("Reset")
            resetButton.scripts.OnClick(resetButton)

            -- Simulate the interaction measured after the reset.
            AddFunctionEntry("Alpha.Fast", 10, 1)
            AddFunctionEntry("Zulu.Slow", 100, 1)
            ProfilerUI:Refresh()

            assert.are_same("total", ProfilerUI.private.displayState.sortKey)
            assert.are_same({"Zulu.Slow", "Alpha.Fast"}, RenderedRowKeys())
        end)
    end)

    describe("sort availability lifecycle", function()
        it("keeps the always-visible Name sort", function()
            AddFunctionEntry("Zulu.Slow", 100, 1)
            AddFunctionEntry("Alpha.Fast", 10, 1)
            ProfilerUI.private.displayState.sortKey = "name"
            ProfilerUI.private.displayState.descending = false

            ProfilerUI:Show()

            assert.are_same("name", ProfilerUI.private.displayState.sortKey)
            assert.are_same({"Alpha.Fast", "Zulu.Slow"}, RenderedRowKeys())
        end)

        it("falls back to total time when Functions are hidden during a Self sort", function()
            AddFunctionEntry("QuestieDB.GetQuest", 50, 1)
            AddThreadJobEntry("ThreadLib job: Alpha.Fast", 10, 1, 1)
            AddThreadJobEntry("ThreadLib job: Zulu.Slow", 100, 1, 1)
            ProfilerUI.private.displayState.sortKey = "self"
            ProfilerUI.private.displayState.showFunctions = false
            ProfilerUI.private.displayState.showFiles = false

            ProfilerUI:Show()

            assert.are_same("total", ProfilerUI.private.displayState.sortKey)
            assert.are_same({"ThreadLib job: Zulu.Slow", "ThreadLib job: Alpha.Fast"}, RenderedRowKeys())
        end)

        it("falls back to total time when only Files remain during a Calls sort", function()
            Profiler.fileLoadTime["Alpha/Fast.lua"] = 10
            Profiler.fileLoadTime["Zulu/Slow.lua"] = 100
            ProfilerUI.private.displayState.sortKey = "calls"
            ProfilerUI.private.displayState.showFunctions = false
            ProfilerUI.private.displayState.showJobs = false

            ProfilerUI:Show()

            assert.are_same("total", ProfilerUI.private.displayState.sortKey)
            assert.are_same({"Zulu/Slow.lua", "Alpha/Fast.lua"}, RenderedRowKeys())
        end)

        it("falls back to total time when only Files remain during an Average sort", function()
            Profiler.fileLoadTime["Alpha/Fast.lua"] = 10
            Profiler.fileLoadTime["Zulu/Slow.lua"] = 100
            ProfilerUI.private.displayState.sortKey = "average"
            ProfilerUI.private.displayState.showFunctions = false
            ProfilerUI.private.displayState.showJobs = false

            ProfilerUI:Show()

            assert.are_same("total", ProfilerUI.private.displayState.sortKey)
            assert.are_same({"Zulu/Slow.lua", "Alpha/Fast.lua"}, RenderedRowKeys())
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
