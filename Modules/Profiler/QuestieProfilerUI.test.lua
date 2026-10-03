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
    local tickers
    local originalSlashCommand
    local originalSlashAlias
    local originalPreHookInstalled
    local originalModules

    -- Only presentation methods are no-ops. Unknown fields must remain nil.
    local presentationMethods = {}
    for _, name in ipairs({
        "SetPoint", "ClearAllPoints", "SetAllPoints", "SetTextColor", "SetFontObject", "SetJustifyH",
        "SetWordWrap", "SetNonSpaceWrap", "SetTexture", "SetColorTexture", "SetVertexColor",
        "SetDesaturated", "SetDrawLayer", "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor",
        "SetNormalTexture", "SetNormalFontObject", "SetHighlightFontObject", "SetDisabledFontObject",
        "SetFrameStrata", "SetClampedToScreen", "SetMovable", "SetResizable", "SetResizeBounds",
        "SetMinResize", "SetMaxResize", "EnableMouse", "EnableMouseWheel", "RegisterForDrag",
        "StartMoving", "StartSizing", "StopMovingOrSizing", "SetAutoFocus", "SetCursorPosition",
        "ClearFocus", "HighlightText",
    }) do
        presentationMethods[name] = function() end
    end

    -- Local native-control seam: visibility, scripts, text and checkbox state, not a WoW emulator.
    local function CreateFrameMock(frameType, frameName, parent)
        local scripts = {}
        local registeredEvents = {}
        local isShown = true
        local text = ""
        local enabled = true
        local height = 200
        local width = 680
        local checked = false

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
                local previous = scripts[scriptName]
                scripts[scriptName] = function(...)
                    if previous then previous(...) end
                    callback(...)
                end
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
                return isShown and (not parent or not parent.IsVisible or parent:IsVisible())
            end,
            Click = function(self)
                if not enabled then return end
                if frameType == "CheckButton" then checked = not checked end
                if scripts.OnClick then scripts.OnClick(self, "LeftButton") end
            end,
            SetChecked = function(_, value) checked = value == true end,
            GetChecked = function() return checked end,
            SetText = function(self, value)
                text = value
                if scripts.OnTextChanged then scripts.OnTextChanged(self, false) end
            end,
            GetParent = function() return parent end,
            SetHighlightTexture = function(self)
                self.highlightTexture = CreateFrameMock("Texture", nil, self)
            end,
            GetHighlightTexture = function(self) return self.highlightTexture end,
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
                return width
            end,
            SetWidth = function(_, value) width = value end,
            SetSize = function(_, w, h) width, height = w, h end,
            SetHeight = function(_, value)
                height = value
            end,
            GetHeight = function()
                return height
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

        setmetatable(frame, {__index = presentationMethods})

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

    local function FindControl(field, value)
        for _, frame in ipairs(frameRegistry) do
            if frame[field] == value then return frame end
        end
        error("Missing control: " .. field .. " = " .. value)
    end

    local function FindRenderedRow(lookupKey)
        for _, frame in ipairs(frameRegistry) do
            if frame.reportRow and frame.reportRow.lookupKey == lookupKey and frame:IsVisible() then
                return frame
            end
        end
        error("Missing rendered row: " .. lookupKey)
    end

    local function FindRelation(identity)
        for _, frame in ipairs(frameRegistry) do
            if frame.relationSummary and frame.nameText:GetText() == identity and frame:IsVisible() then
                return frame
            end
        end
        error("Missing relation: " .. identity)
    end

    local function FindCheckbox(label)
        for _, frame in ipairs(frameRegistry) do
            if frame.frameType == "CheckButton" and frame.label and frame.label:GetText():find(label, 1, true) == 1 then
                return frame
            end
        end
        error("Missing checkbox: " .. label)
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

    ---Reads retained rendered rows, rather than rebuilding a report from the fixture.
    ---@return string[] lookupKeys @Top to bottom, as rendered
    local function RenderedRowKeys()
        local keys = {}
        for _, frame in ipairs(frameRegistry) do
            local reportRow = frame.reportRow
            if reportRow and frame:IsVisible() then
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
        tickers = {}
        originalSlashCommand = _G.SlashCmdList.QUESTIEPROFILER
        originalSlashAlias = _G.SLASH_QUESTIEPROFILER1
        originalPreHookInstalled = QuestieLoader:ImportModule("ProfilerPreHook").installed
        originalModules = {
            Profiler = QuestieLoader._modules.Profiler,
            ProfilerUI = QuestieLoader._modules.ProfilerUI,
            ProfilerReport = QuestieLoader._modules.ProfilerReport,
        }
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
                local ticker = {
                    interval = interval,
                    callback = callback,
                    Cancel = spy.new(function(self)
                        self.cancelled = true
                    end),
                }
                table.insert(tickers, ticker)
                return ticker
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
        _G.SlashCmdList.QUESTIEPROFILER = originalSlashCommand
        _G.SLASH_QUESTIEPROFILER1 = originalSlashAlias
        QuestieLoader:ImportModule("ProfilerPreHook").installed = originalPreHookInstalled
        QuestieLoader._modules.Profiler = originalModules.Profiler
        QuestieLoader._modules.ProfilerUI = originalModules.ProfilerUI
        QuestieLoader._modules.ProfilerReport = originalModules.ProfilerReport
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
        it("unticks files, because a reset leaves them above everything being measured", function()
            ProfilerUI.private.displayState.showFiles = true

            ProfilerUI.private.HideFilesAfterMeasurementReset()

            assert.is_false(ProfilerUI.private.displayState.showFiles)
        end)

        it("leaves functions and jobs alone", function()
            ProfilerUI.private.displayState.showFunctions = true
            ProfilerUI.private.displayState.showJobs = true

            ProfilerUI.private.HideFilesAfterMeasurementReset()

            assert.is_true(ProfilerUI.private.displayState.showFunctions)
            assert.is_true(ProfilerUI.private.displayState.showJobs)
        end)

        it("leaves a files-only view alone, rather than emptying the list", function()
            ProfilerUI.private.displayState.showFunctions = false
            ProfilerUI.private.displayState.showJobs = false
            ProfilerUI.private.displayState.showFiles = true

            ProfilerUI.private.HideFilesAfterMeasurementReset()

            assert.is_true(ProfilerUI.private.displayState.showFiles)
        end)

        it("falls back to total time when Reset hides the active Allocated sort", function()
            AddFunctionEntry("Alpha.Fast", 10, 1)
            AddFunctionEntry("Zulu.Slow", 100, 1)
            Profiler.fileLoadTime["Database/Zones/zoneDB.lua"] = 50
            Profiler.fileLoadMemory["Database/Zones/zoneDB.lua"] = 1000
            ProfilerUI:Show()
            FindControl("sortKey", "memory"):Click()
            FindControl("sortKey", "memory"):Click()

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
            ProfilerUI:Show()
            FindControl("sortKey", "name"):Click()

            assert.are_same("name", ProfilerUI.private.displayState.sortKey)
            assert.are_same({"Alpha.Fast", "Zulu.Slow"}, RenderedRowKeys())
        end)

        it("falls back to total time when Functions are hidden during a Self sort", function()
            AddFunctionEntry("QuestieDB.GetQuest", 50, 1)
            AddThreadJobEntry("ThreadLib job: Alpha.Fast", 10, 1, 1)
            AddThreadJobEntry("ThreadLib job: Zulu.Slow", 100, 1, 1)
            ProfilerUI:Show()
            FindControl("sortKey", "self"):Click()
            FindCheckbox("Functions"):Click()
            FindCheckbox("Files"):Click()

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

    describe("what Stop honestly claims", function()
        ---@type QuestieProfilerPreHook
        local PreHook

        ---@return string[] lines
        local function StopTooltipLines()
            Profiler.active = true
            ProfilerUI:Create()
            ProfilerUI:Refresh()
            local stopButton = FindFrameByText("Stop")
            assert.is_not_nil(stopButton, "the session button should read Stop while a session is active")
            local lines = {}
            _G.GameTooltip.AddLine = function(_, line) table.insert(lines, line) end
            stopButton.scripts.OnEnter(stopButton)
            return lines
        end

        ---@param lines string[]
        ---@param fragment string
        ---@return boolean
        local function Mentions(lines, fragment)
            for _, line in ipairs(lines) do
                if string.find(line, fragment, 1, true) then
                    return true
                end
            end
            return false
        end

        before_each(function()
            PreHook = QuestieLoader:ImportModule("ProfilerPreHook")
        end)

        it("promises full speed when nothing was installed before it loaded", function()
            PreHook.installed = false

            local lines = StopTooltipLines()

            assert.is_true(Mentions(lines, "full speed again"))
            assert.is_false(Mentions(lines, "Reload"))
        end)

        it("says a reload is required when startup profiling left indirections behind", function()
            -- Those wrappers were copied into file-scope locals as the addon loaded. A copy cannot be handed
            -- back, so Stop genuinely cannot remove them and the tooltip must not claim otherwise.
            PreHook.installed = true

            local lines = StopTooltipLines()

            assert.is_true(Mentions(lines, "Reload to remove it"))
            assert.is_false(Mentions(lines, "full speed again"))
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

            tickers[1].callback()

            assert.is_true(ProfilerUI.private.IsIndicatorShown())
        end)

        it("is hidden once the session stops", function()
            ProfilerUI:Hide()
            Profiler.active = false

            tickers[1].callback()

            assert.is_false(FindFrameByName("QuestieProfilerIndicator"):IsShown())
            assert.spy(tickers[1].Cancel).was.not_called()
        end)

        it("returns when a stopped session is started again", function()
            ProfilerUI:Hide()
            Profiler.active = false
            tickers[1].callback()

            Profiler.active = true
            tickers[1].callback()

            assert.is_true(ProfilerUI.private.IsIndicatorShown())
        end)

        it("tracks a session stopped while the window is closed", function()
            ProfilerUI:Show()
            ProfilerUI:Hide()

            Profiler.active = false
            tickers[1].callback()

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
        it("renders new measurements from the automatic ticker", function()
            ProfilerUI:Show()
            assert.are_equal(2, #tickers) -- indicator poll, then window refresh
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            assert.are_same({}, RenderedRowKeys())

            tickers[2].callback()

            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
        end)

        it("cancels refresh on hide and creates a working replacement on reopen", function()
            ProfilerUI:Show()
            local refreshTicker = tickers[2]

            ProfilerUI:Hide()

            assert.spy(refreshTicker.Cancel).was.called(1)
            assert.is_true(refreshTicker.cancelled)
            assert.spy(tickers[1].Cancel).was.not_called()
            ProfilerUI:Show()
            assert.are_equal(3, #tickers)
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            tickers[3].callback()
            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
        end)

        it("cancels refresh on Stop and resumes on Start", function()
            ProfilerUI:Show()
            local refreshTicker = tickers[2]

            FindFrameByText("Stop"):Click()

            assert.is_false(Profiler.active)
            assert.spy(refreshTicker.Cancel).was.called(1)
            assert.is_true(refreshTicker.cancelled)
            FindFrameByText("Start"):Click()
            assert.is_true(Profiler.active)
            assert.are_equal(3, #tickers)
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            tickers[3].callback()
            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
        end)

        it("cancels refresh when polling discovers an externally stopped session", function()
            ProfilerUI:Show()
            Profiler.active = false

            tickers[2].callback()

            assert.spy(tickers[2].Cancel).was.called(1)
            assert.is_true(tickers[2].cancelled)
            assert.are_equal("Start", FindFrameByText("Start"):GetText())
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
        it("cancels automatic refresh on Freeze without stopping measurement", function()
            ProfilerUI:Show()

            FindFrameByText("Freeze"):Click()

            assert.spy(tickers[2].Cancel).was.called(1)
            assert.is_true(tickers[2].cancelled)
            assert.is_true(Profiler.active)
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            assert.are_same({}, RenderedRowKeys())
            assert.are_equal(2, #tickers)
        end)

        it("renders new measurements from the replacement ticker after Unfreeze", function()
            ProfilerUI:Show()
            FindFrameByText("Freeze"):Click()

            FindFrameByText("Unfreeze"):Click()

            assert.are_equal(3, #tickers)
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            tickers[3].callback()
            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
            assert.spy(tickers[3].Cancel).was.not_called()
        end)

        it("refreshes once through the manual control while frozen", function()
            ProfilerUI:Show()
            FindFrameByText("Freeze"):Click()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            assert.are_same({}, RenderedRowKeys())

            local refreshButton = FindFrameByText("Refresh")
            assert.is_true(refreshButton:IsVisible())
            refreshButton:Click()

            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())
            assert.are_equal(2, #tickers)
        end)

        it("rerenders hierarchy rows when the frozen window is resized", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            ProfilerUI:Show()
            FindFrameByText("Freeze"):Click()

            local treeRow
            local sizer
            for _, frame in ipairs(frameRegistry) do
                if not treeRow and rawget(frame, "prefix") and frame:IsShown() then
                    treeRow = frame
                end
                local parent = rawget(frame, "parent")
                if parent and parent.frameName == "QuestieProfilerFrame"
                    and frame.scripts.OnMouseDown and frame.scripts.OnMouseUp then
                    sizer = frame
                end
            end
            assert.is_truthy(treeRow)
            assert.is_truthy(sizer)

            -- The old row remains visible until Layout recalculates how many fit in the resized tree pane.
            treeRow.parent:SetHeight(0)
            assert.is_true(treeRow:IsShown())

            sizer.scripts.OnMouseUp(sizer)

            assert.is_false(treeRow:IsShown())
        end)
    end)

    describe("relation navigation", function()
        ---Concatenates every non-empty text the window currently shows, so assertions can look for the
        ---detail strip's measurements without knowing which pooled frame carries them.
        local function ShownTexts()
            local texts = {}
            for _, frame in ipairs(frameRegistry) do
                local value = frame.GetText and frame:GetText()
                if frame:IsVisible() and type(value) == "string" and value ~= "" then
                    table.insert(texts, value)
                end
            end
            return table.concat(texts, "\n")
        end

        it("resolves a selection the active filters exclude, so a relation click cannot clear the panel", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddThreadJobEntry("ThreadLib job: Draw", 600, 3, 40)
            ProfilerUI:Show()

            AddCallerEntry("QuestieDB.GetQuest", "ThreadLib job: Draw", 4, 200)
            FindRenderedRow("QuestieDB.GetQuest"):Click()
            -- The search edit box is the only edit control without a copy-text focus handler.
            local searchBox
            for _, frame in ipairs(frameRegistry) do
                if frame.frameType == "EditBox" and not frame.scripts.OnEditFocusGained then searchBox = frame end
            end
            searchBox:SetText("GetQuest")
            assert.are_same({"QuestieDB.GetQuest"}, RenderedRowKeys())

            FindRelation("Draw"):Click()

            assert.are_equal("ThreadLib job: Draw", ProfilerUI.private.displayState.selectedKey)
            assert.is_true(FindControl("copyText", "Draw"):IsVisible())

            assert.is_truthy(string.find(ShownTexts(), "600.000 ms total", 1, true))
        end)

        it("clears a selection no report can resolve", function()
            ProfilerUI:Show()
            ProfilerUI.private.displayState.selectedKey = "Removed.Module.Work"

            ProfilerUI:Refresh()

            assert.is_nil(ProfilerUI.private.displayState.selectedKey)
        end)

        it("shows the (root) caller as context, not as a drill-down target", function()
            AddFunctionEntry("QuestieDB.GetQuest", 200, 4)
            AddCallerEntry("QuestieDB.GetQuest", "(root)", 3, 150)
            AddCallerEntry("QuestieDB.GetQuest", "QuestieMap.DrawWorldIcon", 1, 50)
            AddFunctionEntry("QuestieMap.DrawWorldIcon", 50, 1)
            ProfilerUI:Show()

            FindRenderedRow("QuestieDB.GetQuest"):Click()

            local rootEntry = FindRelation("(root)")
            assert.is_nil(rootEntry.identity)
            rootEntry:Click()
            assert.are_equal("QuestieDB.GetQuest", ProfilerUI.private.displayState.selectedKey)
            assert.is_truthy(string.find(ShownTexts(), "200.000 ms total", 1, true))

            FindRelation("QuestieMap.DrawWorldIcon"):Click()

            assert.are_equal("QuestieMap.DrawWorldIcon", ProfilerUI.private.displayState.selectedKey)
            assert.is_truthy(string.find(ShownTexts(), "50.000 ms total", 1, true))
            assert.is_true(FindControl("copyText", "QuestieMap.DrawWorldIcon"):IsVisible())
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
