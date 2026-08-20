dofile("setupTests.lua")

describe("QuestieProfiler", function()
    ---@type QuestieProfiler
    local Profiler
    ---@type ThreadLib
    local ThreadLib
    ---@type QuestieProfilerUI
    local ProfilerUI
    local clock
    local tickerCallbacks
    local testModuleName
    local originalDebug
    local originalDebugProfileStop
    local originalGetTimePreciseSec
    local originalDebugStack
    local originalTimerAPI
    local originalQuestieTestFunction
    local originalQuestieDB
    local originalQuestieModules
    local originalQuestieOrderedModules
    local originalQuestieError
    local QuestieStreamLib
    local DBCompiler
    local QuestieSerializer
    local QuestieDB
    local originalStreamLoad
    local originalStreamHotRead
    local originalCompilerReaders
    local originalCompilerWriters
    local originalCompilerSkippers
    local originalSerializerReaders
    local originalSerializerWriters
    local originalSerialize
    local originalGetQuest
    local originalQuerySlots
    local originalLoadTimings
    local originalLoadMemory
    local querySlotNames = {
        "QueryNPC", "QueryQuest", "QueryObject", "QueryItem",
        "QueryNPCSingle", "QueryQuestSingle", "QueryObjectSingle", "QueryItemSingle",
        "_QueryNPC", "_QueryQuest", "_QueryObject", "_QueryItem",
        "_QueryNPCSingle", "_QueryQuestSingle", "_QueryObjectSingle", "_QueryItemSingle",
    }

    before_each(function()
        testModuleName = "ProfilerTestRoot"
        QuestieLoader._modules[testModuleName] = nil
        originalDebug = _G.debug
        originalDebugProfileStop = _G.debugprofilestop
        originalGetTimePreciseSec = _G.GetTimePreciseSec
        originalDebugStack = _G.debugstack
        originalTimerAPI = _G.C_Timer
        originalQuestieTestFunction = Questie.ProfilerTestFunction
        originalQuestieDB = Questie.db
        originalQuestieModules = Questie.modules
        originalQuestieOrderedModules = Questie.orderedModules
        originalQuestieError = Questie.Error
        QuestieStreamLib = QuestieLoader:ImportModule("QuestieStreamLib")
        DBCompiler = QuestieLoader:ImportModule("DBCompiler")
        QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        originalStreamLoad = QuestieStreamLib.Load
        originalStreamHotRead = QuestieStreamLib.HotRead
        originalCompilerReaders = DBCompiler.readers
        originalCompilerWriters = DBCompiler.writers
        originalCompilerSkippers = DBCompiler.skippers
        originalSerializerReaders = QuestieSerializer.ReaderTable
        originalSerializerWriters = QuestieSerializer.WriterTable
        originalSerialize = QuestieSerializer.Serialize
        originalGetQuest = QuestieDB.GetQuest
        originalLoadTimings = QuestieLoader.loadTimings
        originalLoadMemory = QuestieLoader.loadMemory
        originalQuerySlots = {}
        for _, slotName in ipairs(querySlotNames) do
            originalQuerySlots[slotName] = QuestieDB[slotName]
        end

        clock = 0
        tickerCallbacks = {}
        -- `clock` is milliseconds because that is what every assertion below reads; the profiler takes
        -- seconds and converts, so the stub divides. debugprofilestop is cleared rather than left alone:
        -- nothing may consult it, and a nil is a louder failure than a stale reading.
        _G.GetTimePreciseSec = function()
            return clock / 1000
        end
        _G.debugprofilestop = nil
        _G.C_Timer = {
            NewTicker = function(_, callback)
                local ticker = {
                    Cancel = function(self)
                        self.cancelled = true
                    end,
                }
                table.insert(tickerCallbacks, callback)
                return ticker
            end,
        }
        _G.debugstack = function() return "test stack" end

        dofile("Modules/Libs/ThreadLib.lua")
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        ProfilerUI = QuestieLoader:ImportModule("ProfilerUI")
        ProfilerUI.Create = function() end
        ProfilerUI.Show = function() end
        ProfilerUI.Hide = function() end
        dofile("Modules/Profiler/QuestieProfiler.lua")
        Profiler = QuestieLoader:ImportModule("Profiler")
    end)

    after_each(function()
        Profiler:Unhook()
        QuestieLoader._modules[testModuleName] = nil
        Questie.ProfilerTestFunction = originalQuestieTestFunction
        Questie.db = originalQuestieDB
        Questie.modules = originalQuestieModules
        Questie.orderedModules = originalQuestieOrderedModules
        Questie.Error = originalQuestieError
        QuestieStreamLib.Load = originalStreamLoad
        QuestieStreamLib.HotRead = originalStreamHotRead
        DBCompiler.readers = originalCompilerReaders
        DBCompiler.writers = originalCompilerWriters
        DBCompiler.skippers = originalCompilerSkippers
        QuestieSerializer.ReaderTable = originalSerializerReaders
        QuestieSerializer.WriterTable = originalSerializerWriters
        QuestieSerializer.Serialize = originalSerialize
        QuestieDB.GetQuest = originalGetQuest
        QuestieLoader.loadTimings = originalLoadTimings
        QuestieLoader.loadMemory = originalLoadMemory
        for _, slotName in ipairs(querySlotNames) do
            QuestieDB[slotName] = originalQuerySlots[slotName]
        end
        _G.debug = originalDebug
        _G.debugprofilestop = originalDebugProfileStop
        _G.GetTimePreciseSec = originalGetTimePreciseSec
        _G.debugstack = originalDebugStack
        _G.C_Timer = originalTimerAPI
    end)

    it("declines to arm, and says so, when the client has no GetTimePreciseSec", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local original = function() end
        testModule.Work = original

        -- GetTimePreciseSec is the only clock. debugprofilestop is deliberately left available to prove
        -- nothing falls back to it: a resettable clock can run backwards and poison a total permanently.
        _G.GetTimePreciseSec = nil
        _G.debugprofilestop = function() return clock end
        dofile("Modules/Profiler/QuestieProfiler.lua")
        Profiler = QuestieLoader:ImportModule("Profiler")

        local reported
        Questie.Error = function(message) reported = message end
        local armed, rejectionReported = Profiler:Start(false)

        assert.is_false(armed)
        assert.is_true(rejectionReported)
        -- Refusing quietly would read as "profiling is on but measures nothing".
        assert.is_not_nil(reported)
        assert.is_false(Profiler.active)
        assert.are_equal(original, testModule.Work)
        local callbackOwner = {}
        local callbackOwnerAccepted = ThreadLib.SetProfilingCallbacks(callbackOwner, {})
        assert.is_true(callbackOwnerAccepted)
        ThreadLib.ClearProfilingCallbacks(callbackOwner)
    end)

    describe("clock selection", function()
        it("measures with GetTimePreciseSec when the client provides it", function()
            local preciseSeconds = 0
            _G.GetTimePreciseSec = function()
                return preciseSeconds
            end
            -- debugprofilestop is resettable by any addon, so it must not be consulted when the monotonic
            -- clock exists. Erroring here makes any fallback read a hard test failure rather than a silent one.
            _G.debugprofilestop = function()
                error("debugprofilestop must not be read while GetTimePreciseSec is available")
            end
            dofile("Modules/Profiler/QuestieProfiler.lua")
            Profiler = QuestieLoader:ImportModule("Profiler")

            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Work = function()
                preciseSeconds = preciseSeconds + 0.25
            end

            assert.is_true(Profiler:Start(false))
            testModule.Work()

            -- Seconds are converted so everything downstream keeps reading milliseconds.
            assert.are_same(250, Profiler.hookTimeCount[testModuleName .. ".Work"])
        end)

        it("arms without debugprofilestop existing at all", function()
            _G.GetTimePreciseSec = function()
                return 0
            end
            _G.debugprofilestop = nil
            dofile("Modules/Profiler/QuestieProfiler.lua")
            Profiler = QuestieLoader:ImportModule("Profiler")

            assert.is_true(Profiler:Start(false))
            assert.is_true(Profiler.active)
        end)
    end)

    it("StartStartup(false) wraps ordinary functions without showing the UI", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local ordinaryFunction = function()
            clock = clock + 4
        end
        testModule.OrdinaryFunction = ordinaryFunction
        local showCalls = 0
        local hideCalls = 0
        Profiler.ShowUI = function()
            showCalls = showCalls + 1
        end
        Profiler.HideUI = function()
            hideCalls = hideCalls + 1
        end

        assert.is_true(Profiler:StartStartup(false))
        assert.are_same(0, showCalls)
        assert.are_same(1, hideCalls)
        assert.are_not_equal(ordinaryFunction, testModule.OrdinaryFunction)

        testModule.OrdinaryFunction()
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".OrdinaryFunction"])
        assert.are_same(4, Profiler.hookTimeCount[testModuleName .. ".OrdinaryFunction"])
    end)

    it("shows the UI before traversal and preserves the active session when Start is repeated", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Work = function()
            clock = clock + 3
        end
        local lifecycleOrder = {}
        local originalRefreshHooks = Profiler.RefreshHooks
        Profiler.ShowUI = function()
            table.insert(lifecycleOrder, "show UI")
        end
        Profiler.RefreshHooks = function(self)
            table.insert(lifecycleOrder, "traverse hooks")
            return originalRefreshHooks(self)
        end

        assert.is_true(Profiler:StartStartup(true))
        local firstWrapper = testModule.Work
        testModule.Work()
        assert.are_same({"show UI", "traverse hooks"}, lifecycleOrder)

        assert.is_true(Profiler:Start(true))
        assert.are_same({"show UI", "traverse hooks", "show UI"}, lifecycleOrder)
        assert.are_equal(firstWrapper, testModule.Work)
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".Work"])
        assert.are_same(3, Profiler.hookTimeCount[testModuleName .. ".Work"])
    end)

    it("reports a startup UI failure without blocking or duplicating hook traversal", function()
        local reportedErrors = {}
        Questie.Error = function(message, profilerError)
            table.insert(reportedErrors, {message, profilerError})
        end
        Profiler.ShowUI = function()
            error("expected ShowUI failure")
        end
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local original = function()
            clock = clock + 3
        end
        testModule.Work = original

        assert.is_true(Profiler:StartStartup(true))
        local wrapper = testModule.Work
        assert.are_not_equal(original, wrapper)
        testModule.Work()
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".Work"])
        assert.are_same(3, Profiler.hookTimeCount[testModuleName .. ".Work"])

        assert.is_true(Profiler:Start(true))
        assert.is_true(Profiler:StartStartup(true))
        assert.are_equal(wrapper, testModule.Work)
        assert.are_same(3, #reportedErrors)
        for _, reportedError in ipairs(reportedErrors) do
            assert.are_same("QuestieProfiler failed to show its UI", reportedError[1])
            assert.is_truthy(string.find(reportedError[2], "expected ShowUI failure", 1, true))
        end
    end)

    it("reopens a stopped session's results instead of resetting them", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Work = function()
            clock = clock + 3
        end
        local showCalls = 0
        Profiler.ShowUI = function()
            showCalls = showCalls + 1
        end

        assert.is_true(Profiler:Start(false))
        testModule.Work()
        Profiler:Stop()
        assert.is_false(Profiler.active)
        assert.is_true(Profiler:HasResults())

        Profiler:OpenUI()

        assert.are_same(1, showCalls)
        -- Still stopped, still holding the capture: opening must not have gone through Start.
        assert.is_false(Profiler.active)
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".Work"])
        assert.are_same(3, Profiler.hookTimeCount[testModuleName .. ".Work"])
    end)

    it("starts a session from OpenUI only when nothing was ever measured", function()
        assert.is_false(Profiler:HasResults())

        Profiler:OpenUI()

        assert.is_true(Profiler.active)
    end)

    it("rolls back partial hook installation and allows a clean retry", function()
        local reportedErrors = {}
        Questie.Error = function(message, profilerError)
            table.insert(reportedErrors, {message, profilerError})
        end
        local shown = 0
        local hidden = 0
        ProfilerUI.Show = function()
            shown = shown + 1
        end
        ProfilerUI.Hide = function()
            hidden = hidden + 1
        end
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local original = function()
            clock = clock + 2
        end
        testModule.Work = original
        local originalRefreshHooks = Profiler.RefreshHooks
        Profiler.RefreshHooks = function(self)
            self:HookFunction("Work", original, testModule, testModuleName)
            error("expected traversal failure")
        end

        local armed, rejectionReported = Profiler:Start(true)

        assert.is_false(armed)
        assert.is_true(rejectionReported)
        assert.are_same(1, shown)
        assert.are_same(0, hidden)
        assert.is_false(Profiler.active)
        assert.are_equal(original, testModule.Work)
        assert.are_same("QuestieProfiler failed to install hooks", reportedErrors[1][1])
        assert.is_truthy(string.find(reportedErrors[1][2], "expected traversal failure", 1, true))

        local temporaryOwner = {}
        assert.is_true(ThreadLib.SetProfilingCallbacks(temporaryOwner, {}))
        ThreadLib.ClearProfilingCallbacks(temporaryOwner)
        Profiler.RefreshHooks = originalRefreshHooks

        assert.is_true(Profiler:Start(false))
        assert.is_true(Profiler.active)
        assert.are_not_equal(original, testModule.Work)
        testModule.Work()
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".Work"])
        assert.are_same(2, Profiler.hookTimeCount[testModuleName .. ".Work"])
    end)

    it("gives Start(false) and StartStartup(false) the same hook scope", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local rootFunction = function() end
        local nestedFunction = function() end
        testModule.RootFunction = rootFunction
        testModule.namespace = {NestedFunction = nestedFunction}

        assert.is_true(Profiler:Start(false))
        assert.are_not_equal(rootFunction, testModule.RootFunction)
        assert.are_not_equal(nestedFunction, testModule.namespace.NestedFunction)
        assert.is_not_nil(Profiler.hookCallCount[testModuleName .. ".RootFunction"])
        assert.is_not_nil(Profiler.hookCallCount[testModuleName .. ".namespace.NestedFunction"])

        Profiler:Stop()
        assert.are_equal(rootFunction, testModule.RootFunction)
        assert.are_equal(nestedFunction, testModule.namespace.NestedFunction)

        assert.is_true(Profiler:StartStartup(false))
        assert.are_not_equal(rootFunction, testModule.RootFunction)
        assert.are_not_equal(nestedFunction, testModule.namespace.NestedFunction)
        assert.is_not_nil(Profiler.hookCallCount[testModuleName .. ".RootFunction"])
        assert.is_not_nil(Profiler.hookCallCount[testModuleName .. ".namespace.NestedFunction"])
    end)

    it("keeps disallowed modules, subtrees, and query slots unchanged", function()
        local streamLoad = function() end
        local streamRead = function(stream)
            stream.reads = (stream.reads or 0) + 1
            return stream.reads
        end
        local reader = function() return "read" end
        local writer = function() end
        local skipper = function() end
        local hotQuery = function() return "query" end
        local getQuest = function()
            clock = clock + 2
            return "quest"
        end
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.copiedStream = {
            _mode = "raw",
            Load = streamLoad,
            ReadByte = streamRead,
        }
        QuestieStreamLib.Load = streamLoad
        QuestieStreamLib.HotRead = streamRead
        DBCompiler.readers = {u8 = reader}
        DBCompiler.writers = {u8 = writer}
        DBCompiler.skippers = {u8 = skipper}
        QuestieDB.GetQuest = getQuest
        for _, slotName in ipairs(querySlotNames) do
            QuestieDB[slotName] = hotQuery
        end
        local queryTablePrimitive = function() return "primitive" end
        QuestieDB.QueryNPC = {Primitive = queryTablePrimitive}

        assert.is_true(Profiler:Start(false))

        assert.are_equal(streamLoad, QuestieStreamLib.Load)
        assert.are_equal(streamRead, QuestieStreamLib.HotRead)
        assert.are_equal(reader, DBCompiler.readers.u8)
        assert.are_equal(writer, DBCompiler.writers.u8)
        assert.are_equal(skipper, DBCompiler.skippers.u8)
        assert.are_equal(streamLoad, testModule.copiedStream.Load)
        assert.are_equal(streamRead, testModule.copiedStream.ReadByte)
        assert.are_equal(queryTablePrimitive, QuestieDB.QueryNPC.Primitive)
        for i = 2, #querySlotNames do
            assert.are_equal(hotQuery, QuestieDB[querySlotNames[i]])
        end

        assert.are_not_equal(getQuest, QuestieDB.GetQuest)
        assert.are_same("quest", QuestieDB.GetQuest())
        assert.are_same(1, Profiler.hookCallCount["QuestieDB.GetQuest"])
        assert.are_same(2, Profiler.hookTimeCount["QuestieDB.GetQuest"])
    end)

    it("leaves serializer dispatch primitives unmeasured while wrapping a high-level method", function()
        local readerCalls = 0
        local writerCalls = 0
        local reader = function()
            readerCalls = readerCalls + 1
        end
        local writer = function()
            writerCalls = writerCalls + 1
        end
        local serialize = function()
            clock = clock + 5
            return "serialized"
        end
        QuestieSerializer.ReaderTable = {custom = reader}
        QuestieSerializer.WriterTable = {custom = writer}
        QuestieSerializer.Serialize = serialize

        assert.is_true(Profiler:Start(false))

        assert.are_equal(reader, QuestieSerializer.ReaderTable.custom)
        assert.are_equal(writer, QuestieSerializer.WriterTable.custom)
        assert.are_not_equal(serialize, QuestieSerializer.Serialize)
        QuestieSerializer.ReaderTable.custom()
        QuestieSerializer.WriterTable.custom()
        assert.are_same("serialized", QuestieSerializer:Serialize({}))
        assert.are_same(1, readerCalls)
        assert.are_same(1, writerCalls)
        assert.is_nil(Profiler.hookCallCount["QuestieSerializer.ReaderTable.custom"])
        assert.is_nil(Profiler.hookCallCount["QuestieSerializer.WriterTable.custom"])
        assert.are_same(1, Profiler.hookCallCount["QuestieSerializer.Serialize"])
        assert.are_same(5, Profiler.hookTimeCount["QuestieSerializer.Serialize"])
    end)

    it("records only the high-level getter around thousands of primitive and query calls", function()
        local lowLevelCalls = 0
        local hotPrimitive = function()
            lowLevelCalls = lowLevelCalls + 1
        end
        local hotQuery = function()
            lowLevelCalls = lowLevelCalls + 1
        end
        QuestieStreamLib.HotRead = hotPrimitive
        DBCompiler.readers = {u8 = hotPrimitive}
        QuestieDB.QueryQuest = hotQuery
        QuestieDB.GetQuest = function()
            for _ = 1, 200 do
                DBCompiler.readers.u8()
                QuestieStreamLib.HotRead()
                QuestieDB.QueryQuest()
            end
        end

        assert.is_true(Profiler:Start(false))
        local getterWrapper = QuestieDB.GetQuest
        for _ = 1, 20 do
            QuestieDB.GetQuest()
        end

        assert.are_equal(getterWrapper, QuestieDB.GetQuest)
        assert.are_same(12000, lowLevelCalls)
        assert.are_same(20, Profiler.hookCallCount["QuestieDB.GetQuest"])
        assert.is_nil(Profiler.hookCallCount["DBCompiler.readers.u8"])
        assert.is_nil(Profiler.hookCallCount["QuestieStreamLib.HotRead"])
        assert.is_nil(Profiler.hookCallCount["QuestieDB.QueryQuest"])
    end)

    it("preserves leading, interior, and trailing nil return values", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.ReturnValues = function()
            clock = clock + 5
            return nil, "middle", nil, "last", nil
        end
        Profiler:Start(false)

        local returnCount = select("#", testModule.ReturnValues())
        local first, second, third, fourth, fifth = testModule.ReturnValues()

        assert.are_same(5, returnCount)
        assert.is_nil(first)
        assert.are_same("middle", second)
        assert.is_nil(third)
        assert.are_same("last", fourth)
        assert.is_nil(fifth)
        assert.are_same(2, Profiler.hookCallCount[testModuleName .. ".ReturnValues"])
        assert.are_same(10, Profiler.hookTimeCount[testModuleName .. ".ReturnValues"])
    end)

    it("propagates a main-thread error with its original message", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Boom = function()
            error("expected boom")
        end
        Profiler:Start(false)

        local success, raisedError = pcall(testModule.Boom)

        assert.is_false(success)
        assert.is_truthy(string.find(raisedError, "expected boom", 1, true))
    end)

    it("propagates a non-string error object unchanged", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local errorObject = {code = "expected"}
        testModule.Boom = function()
            error(errorObject)
        end
        Profiler:Start(false)

        local success, raisedError = pcall(testModule.Boom)

        assert.is_false(success)
        assert.are_equal(errorObject, raisedError)
    end)

    it("preserves coroutine yields and final return values", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.YieldingFunction = function()
            local resumedWith = coroutine.yield("first yield", nil, "third yield")
            return nil, resumedWith, nil
        end
        Profiler:Start(false)

        local function CaptureResume(...)
            return {n = select("#", ...), ...}
        end

        local thread = coroutine.create(testModule.YieldingFunction)
        local yielded = CaptureResume(coroutine.resume(thread))
        local finished = CaptureResume(coroutine.resume(thread, "resumed"))

        assert.are_same(4, yielded.n)
        assert.is_true(yielded[1])
        assert.are_same("first yield", yielded[2])
        assert.is_nil(yielded[3])
        assert.are_same("third yield", yielded[4])
        assert.are_same(4, finished.n)
        assert.is_true(finished[1])
        assert.is_nil(finished[2])
        assert.are_same("resumed", finished[3])
        assert.is_nil(finished[4])
    end)

    it("counts raw coroutine calls without timing suspended wall-clock time", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.RawCoroutineWork = function()
            clock = clock + 2
            coroutine.yield()
            clock = clock + 3
        end
        Profiler:Start(false)

        local thread = coroutine.create(testModule.RawCoroutineWork)
        assert.is_true(coroutine.resume(thread))
        clock = clock + 100
        assert.is_true(coroutine.resume(thread))

        local lookupKey = testModuleName .. ".RawCoroutineWork"
        assert.are_same(1, Profiler.hookCallCount[lookupKey])
        assert.are_same(1, Profiler.highestCalls)
        assert.are_same(0, Profiler.hookTimeCount[lookupKey])
    end)

    it("times work spanning resume slices, counting the slices and never the suspension", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.SlicedJob = function()
            clock = clock + 2
            coroutine.yield()
            clock = clock + 3
            coroutine.yield()
            clock = clock + 4
        end
        Profiler:Start(false)
        ThreadLib.ThreadSimple(testModule.SlicedJob, 0)

        tickerCallbacks[1]()
        clock = clock + 100
        tickerCallbacks[1]()
        clock = clock + 100
        tickerCallbacks[1]()

        -- 2 + 3 + 4 of work across three slices. The two 100ms gaps are suspension and must not appear.
        -- This reported 0 before slices were accumulated, which read as "free" for work that plainly ran.
        assert.are_same(9, Profiler.hookTimeCount[testModuleName .. ".SlicedJob"])
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".SlicedJob"])

        local jobLookupKey
        for lookupKey in pairs(Profiler.hookCallCount) do
            if string.find(lookupKey, "ThreadLib job:", 1, true) == 1 then
                jobLookupKey = lookupKey
            end
        end
        assert.is_truthy(jobLookupKey)
        -- The function is the entirety of the job, so the two measurements have to agree.
        assert.are_same(9, Profiler.hookTimeCount[jobLookupKey])
        assert.are_same(1, Profiler.hookCallCount[jobLookupKey])
        assert.are_same(1, Profiler.threadJobCallCount[jobLookupKey])
        assert.are_same(3, Profiler.threadJobResumeCount[jobLookupKey])
    end)

    it("discards a nested errored frame when its ThreadLib caller catches the error", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Inner = function()
            clock = clock + 3
            error("expected inner failure")
        end
        testModule.Outer = function()
            clock = clock + 1
            local success = pcall(testModule.Inner)
            assert.is_false(success)
            clock = clock + 2
        end
        Profiler:Start(false)
        ThreadLib.ThreadSimple(testModule.Outer, 0)

        tickerCallbacks[1]()

        assert.are_same(0, Profiler.hookTimeCount[testModuleName .. ".Inner"])
        assert.are_same(6, Profiler.hookTimeCount[testModuleName .. ".Outer"])
    end)

    it("credits a caller spanning resumes without crediting the frame its caught error left behind", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Inner = function()
            clock = clock + 2
            error("expected inner failure")
        end
        testModule.Outer = function()
            clock = clock + 1
            local success = pcall(testModule.Inner)
            assert.is_false(success)
            clock = clock + 3
            coroutine.yield()
            clock = clock + 4
        end
        Profiler:Start(false)
        ThreadLib.ThreadSimple(testModule.Outer, 0)

        tickerCallbacks[1]()
        clock = clock + 100
        tickerCallbacks[1]()

        -- Inner errored, so its wrapper never completed and it publishes nothing - the stale frame it left
        -- on the stack accrues time but can never report it, which is why accumulating is safe here.
        assert.are_same(0, Profiler.hookTimeCount[testModuleName .. ".Inner"])
        -- Outer really did spend 1 + 2 + 3 + 4, either side of a yield, with 100ms suspended in between.
        assert.are_same(10, Profiler.hookTimeCount[testModuleName .. ".Outer"])
    end)

    it("keeps self time right when a call spans a resume and its child does not", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Child = function()
            clock = clock + 5
        end
        testModule.Parent = function()
            clock = clock + 1
            coroutine.yield()
            clock = clock + 2
            testModule.Child()
            clock = clock + 3
        end
        Profiler:Start(false)
        ThreadLib.ThreadSimple(testModule.Parent, 0)

        tickerCallbacks[1]()
        clock = clock + 100
        tickerCallbacks[1]()

        -- The child ran wholly inside the second slice; the parent's total spans both.
        assert.are_same(5, Profiler.hookTimeCount[testModuleName .. ".Child"])
        assert.are_same(11, Profiler.hookTimeCount[testModuleName .. ".Parent"])
        -- Self time still subtracts the child, across the slice boundary.
        assert.are_same(6, Profiler.hookSelfTime[testModuleName .. ".Parent"])
    end)

    it("does not carry caught errors from an unwrapped job into a measurement reset", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.FailingWork = function()
            clock = clock + 2
            error("expected failure")
        end
        Profiler:Start(false)
        ThreadLib.ThreadSimple(function()
            for _ = 1, 2 do
                local success = pcall(testModule.FailingWork)
                assert.is_false(success)
                coroutine.yield()
            end
        end, 0)

        tickerCallbacks[1]()
        tickerCallbacks[1]()
        Profiler:ResetMeasurements()
        tickerCallbacks[1]()

        local lookupKey = testModuleName .. ".FailingWork"
        assert.are_same(0, Profiler.hookCallCount[lookupKey])
        assert.are_same(0, Profiler.hookTimeCount[lookupKey])
    end)

    it("keeps only the active job when measurements reset between resume slices", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.ResetWhileSuspended = function()
            clock = clock + 2
            coroutine.yield()
            clock = clock + 4
        end
        Profiler:Start(false)
        ThreadLib.ThreadSimple(testModule.ResetWhileSuspended, 0)

        tickerCallbacks[1]()
        Profiler:ResetMeasurements()

        local functionLookupKey = testModuleName .. ".ResetWhileSuspended"
        local jobLookupKey
        for lookupKey in pairs(Profiler.threadJobCallCount) do
            jobLookupKey = lookupKey
        end
        assert.are_same(0, Profiler.hookCallCount[functionLookupKey])
        assert.are_same(0, Profiler.hookTimeCount[functionLookupKey])
        assert.are_same(1, Profiler.hookCallCount[jobLookupKey])
        assert.are_same(1, Profiler.threadJobCallCount[jobLookupKey])
        assert.are_same(0, Profiler.hookTimeCount[jobLookupKey])

        clock = clock + 100
        tickerCallbacks[1]()

        assert.are_same(0, Profiler.hookCallCount[functionLookupKey])
        assert.are_same(0, Profiler.hookTimeCount[functionLookupKey])
        assert.are_same(1, Profiler.hookCallCount[jobLookupKey])
        assert.are_same(1, Profiler.threadJobCallCount[jobLookupKey])
        assert.are_same(1, Profiler.threadJobResumeCount[jobLookupKey])
        assert.are_same(4, Profiler.hookTimeCount[jobLookupKey])
    end)

    it("measures only the post-reset remainder of an active ThreadLib resume", function()
        Profiler:Start(false)
        ThreadLib.Thread(function()
            clock = clock + 2
            Profiler:ResetMeasurements()
            clock = clock + 7
        end, 0, nil, nil, nil, "reset during active resume")

        tickerCallbacks[1]()

        local jobLookupKey = "ThreadLib job: reset during active resume"
        assert.are_same(1, Profiler.hookCallCount[jobLookupKey])
        assert.are_same(1, Profiler.threadJobCallCount[jobLookupKey])
        assert.are_same(1, Profiler.threadJobResumeCount[jobLookupKey])
        assert.are_same(7, Profiler.hookTimeCount[jobLookupKey])
    end)

    it("does not publish a main-thread call across a measurement reset", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.ResetDuringCall = function()
            clock = clock + 2
            Profiler:ResetMeasurements()
            clock = clock + 7
        end
        Profiler:Start(false)

        testModule.ResetDuringCall()

        local lookupKey = testModuleName .. ".ResetDuringCall"
        assert.are_same(0, Profiler.hookCallCount[lookupKey])
        assert.are_same(0, Profiler.hookTimeCount[lookupKey])
    end)

    it("records nested function timings inclusively", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Inner = function()
            clock = clock + 3
        end
        testModule.Outer = function()
            clock = clock + 2
            testModule.Inner()
            clock = clock + 5
        end
        Profiler:Start(false)

        testModule.Outer()

        assert.are_same(3, Profiler.hookTimeCount[testModuleName .. ".Inner"])
        assert.are_same(10, Profiler.hookTimeCount[testModuleName .. ".Outer"])
    end)

    describe("addon load timings", function()
        it("publishes each file QuestieLoader timed as its own result row", function()
            QuestieLoader.loadTimings = {
                ["Localization/lookups/lookupZones.lua"] = 202.5,
                ["Database/Zones/zoneDB.lua"] = 19.6,
            }
            Profiler:Start(false)

            Profiler:ImportLoadTimings()

            assert.are_same(202.5, Profiler.fileLoadTime["Localization/lookups/lookupZones.lua"])
            assert.are_same(19.6, Profiler.fileLoadTime["Database/Zones/zoneDB.lua"])
        end)

        it("reports a loaded file as one call whose time is entirely its own", function()
            QuestieLoader.loadTimings = {["Database/Zones/zoneDB.lua"] = 19.6}
            Profiler:Start(false)

            Profiler:ImportLoadTimings()

            -- A loaded file is not a call, so it never enters the hook measurements at all.
            assert.is_nil(Profiler.hookCallCount["Database/Zones/zoneDB.lua"])
            assert.is_nil(Profiler.hookTimeCount["file load: Database/Zones/zoneDB.lua"])
            assert.are_same(19.6, Profiler.fileLoadTime["Database/Zones/zoneDB.lua"])
        end)

        it("does not let a file duration become the reported peak for functions", function()
            QuestieLoader.loadTimings = {["Localization/lookups/lookupZones.lua"] = 900}
            Profiler:Start(false)

            Profiler:ImportLoadTimings()

            assert.are_same(0, Profiler.highestMS)
        end)

        it("carries the allocation QuestieLoader recorded for each file", function()
            QuestieLoader.loadTimings = {["Database/Zones/zoneDB.lua"] = 19.6}
            QuestieLoader.loadMemory = {["Database/Zones/zoneDB.lua"] = 2140}
            Profiler:Start(false)

            Profiler:ImportLoadTimings()

            assert.are_same(2140, Profiler.fileLoadMemory["Database/Zones/zoneDB.lua"])
        end)

        it("does not reopen a load interval by resolving the UI at runtime", function()
            local importsDuringUse = 0
            local originalImportModule = QuestieLoader.ImportModule
            QuestieLoader.ImportModule = function(loader, name)
                if name == "ProfilerUI" then
                    importsDuringUse = importsDuringUse + 1
                end
                return originalImportModule(loader, name)
            end

            Profiler:ShowUI()
            Profiler:HideUI()

            QuestieLoader.ImportModule = originalImportModule
            -- A runtime import would re-stamp this file as the open load interval and charge it whatever
            -- ran next, which is how hook installation was once reported as this file's load cost.
            assert.are_same(0, importsDuringUse)
        end)

        it("does nothing when profiling is not active", function()
            QuestieLoader.loadTimings = {["Database/Zones/zoneDB.lua"] = 19.6}

            Profiler:ImportLoadTimings()

            assert.is_nil(Profiler.fileLoadTime["Database/Zones/zoneDB.lua"])
        end)

        it("republishes load rows when a fresh session starts", function()
            -- Addon load happened once for this client and cannot be measured again, so a restarted session
            -- must not be the only way to destroy the record of it. The UI hides the rows instead.
            QuestieLoader.loadTimings = {["Database/Zones/zoneDB.lua"] = 19.6}
            Profiler:Start(false)
            Profiler:ImportLoadTimings()
            Profiler:Stop()

            Profiler:Start(false)

            assert.are_same(19.6, Profiler.fileLoadTime["Database/Zones/zoneDB.lua"])
        end)

        it("still clears function measurements when a fresh session starts", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Work = function()
                clock = clock + 3
            end
            Profiler:Start(false)
            testModule.Work()
            Profiler:Stop()

            Profiler:Start(false)

            assert.are_same(0, Profiler.hookCallCount[testModuleName .. ".Work"])
        end)
    end)

    describe("self time", function()
        it("excludes time spent inside profiled children", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Inner = function()
                clock = clock + 3
            end
            testModule.Outer = function()
                clock = clock + 2
                testModule.Inner()
                clock = clock + 5
            end
            Profiler:Start(false)

            testModule.Outer()

            assert.are_same(7, Profiler.hookSelfTime[testModuleName .. ".Outer"])
        end)

        it("equals total time for a function with no profiled children", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Leaf = function()
                clock = clock + 4
            end
            Profiler:Start(false)

            testModule.Leaf()

            assert.are_same(4, Profiler.hookTimeCount[testModuleName .. ".Leaf"])
            assert.are_same(4, Profiler.hookSelfTime[testModuleName .. ".Leaf"])
        end)

        it("subtracts each of several children from one parent", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.First = function()
                clock = clock + 2
            end
            testModule.Second = function()
                clock = clock + 3
            end
            testModule.Parent = function()
                clock = clock + 1
                testModule.First()
                testModule.Second()
                clock = clock + 1
            end
            Profiler:Start(false)

            testModule.Parent()

            assert.are_same(7, Profiler.hookTimeCount[testModuleName .. ".Parent"])
            assert.are_same(2, Profiler.hookSelfTime[testModuleName .. ".Parent"])
        end)

        it("accumulates across repeated calls", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Work = function()
                clock = clock + 3
            end
            Profiler:Start(false)

            testModule.Work()
            testModule.Work()

            assert.are_same(6, Profiler.hookSelfTime[testModuleName .. ".Work"])
        end)

        it("charges a caught descendant error to the descendant, not to its caller", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Inner = function()
                clock = clock + 3
                error("expected inner failure")
            end
            testModule.Outer = function()
                clock = clock + 1
                local success = pcall(testModule.Inner)
                assert.is_false(success)
                clock = clock + 2
            end
            Profiler:Start(false)

            testModule.Outer()

            -- Inner ran for 3ms before failing, and that time belongs to Inner. Outer's own work is 1 + 2.
            assert.are_same(3, Profiler.hookTimeCount[testModuleName .. ".Inner"])
            assert.are_same(6, Profiler.hookTimeCount[testModuleName .. ".Outer"])
            assert.are_same(3, Profiler.hookSelfTime[testModuleName .. ".Outer"])
        end)
    end)

    describe("bundled library roots", function()
        local originalLibStub
        local libraries

        ---Stands in for LibStub's registry, so a test can control exactly which majors resolve.
        ---@param registry table<string, table>
        local function MockLibStub(registry)
            libraries = registry
            _G.LibStub = {
                GetLibrary = function(_, major, silent)
                    local library = libraries[major]
                    if not library and not silent then
                        error("Cannot find a library instance of " .. tostring(major))
                    end
                    return library
                end,
            }
        end

        before_each(function()
            originalLibStub = _G.LibStub
        end)

        after_each(function()
            _G.LibStub = originalLibStub
        end)

        it("profiles an allowlisted library under its Libraries name", function()
            local original = function() end
            MockLibStub({["HereBeDragonsQuestie-2.0"] = {GetZoneDistance = original}})

            Profiler:Start(false)

            assert.are_same(0, Profiler.hookCallCount["Libs.HBD.GetZoneDistance"])
            assert.are_not_equal(original, libraries["HereBeDragonsQuestie-2.0"].GetZoneDistance)
        end)

        it("measures a library call and names the Questie function that made it", function()
            MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {
                AddWorldMapIconMap = function() clock = clock + 4 end,
            }})
            local HBDPins = libraries["HereBeDragonsQuestie-Pins-2.0"]
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.DrawIcon = function()
                clock = clock + 1
                HBDPins.AddWorldMapIconMap()
            end

            Profiler:Start(false)
            testModule.DrawIcon()

            local libraryKey = "Libs.HBDPins.AddWorldMapIconMap"
            assert.are_same(1, Profiler.hookCallCount[libraryKey])
            assert.are_same(4, Profiler.hookTimeCount[libraryKey])
            -- The library time comes out of the caller's self time, which is the whole point.
            assert.are_same(5, Profiler.hookTimeCount[testModuleName .. ".DrawIcon"])
            assert.are_same(1, Profiler.hookSelfTime[testModuleName .. ".DrawIcon"])
            assert.are_same(1, Profiler.callerCallCount[libraryKey][testModuleName .. ".DrawIcon"])
        end)

        it("ignores a library the client does not provide", function()
            MockLibStub({})

            assert.is_true(Profiler:Start(false))
        end)

        it("leaves libraries that are not on the allowlist untouched", function()
            local original = function() end
            MockLibStub({
                ["AceAddon-3.0"] = {NewAddon = original},
                ["CallbackHandler-1.0"] = {New = original},
            })

            Profiler:Start(false)

            assert.are_equal(original, libraries["AceAddon-3.0"].NewAddon)
            assert.are_equal(original, libraries["CallbackHandler-1.0"].New)
            assert.is_nil(Profiler.hookCallCount["Libs.AceAddon.NewAddon"])
        end)

        it("never traverses a mixin that is copied onto frames", function()
            -- worldmapProviderPin is copied onto every pin as the pin is created, so a wrapper installed here
            -- rides along onto frames that Unhook cannot reach.
            local pinMethod = function() end
            local providerMethod = function() end
            MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {
                worldmapProviderPin = {OnAcquired = pinMethod},
                worldmapProvider = {RemovePinByIcon = providerMethod},
            }})
            local HBDPins = libraries["HereBeDragonsQuestie-Pins-2.0"]

            Profiler:Start(false)

            assert.are_equal(pinMethod, HBDPins.worldmapProviderPin.OnAcquired)
            assert.is_nil(Profiler.hookCallCount["Libs.HBDPins.worldmapProviderPin.OnAcquired"])
            -- The provider beside it is the one worth reaching.
            assert.are_not_equal(providerMethod, HBDPins.worldmapProvider.RemovePinByIcon)
            assert.are_same(0,
                Profiler.hookCallCount["Libs.HBDPins.worldmapProvider.RemovePinByIcon"])
        end)

        describe("frame scripts", function()
            ---A frame stands in for HBD's: a table whose script API lives on it, holding one handler.
            ---@param scripts table<string, function>
            local function MockFrame(scripts)
                return {
                    scripts = scripts,
                    GetScript = function(self, name) return self.scripts[name] end,
                    SetScript = function(self, name, handler) self.scripts[name] = handler end,
                }
            end

            it("measures the minimap updater, which no table traversal can reach", function()
                local ran = 0
                local handler = function()
                    ran = ran + 1
                    clock = clock + 6
                end
                local frame = MockFrame({OnUpdate = handler})
                MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {updateFrame = frame}})

                Profiler:Start(false)
                frame:GetScript("OnUpdate")(frame, 0.016)

                assert.are_same(1, ran)
                assert.are_same(1, Profiler.hookCallCount["Libs.HBDPins.updateFrame.OnUpdate"])
                assert.are_same(6, Profiler.hookTimeCount["Libs.HBDPins.updateFrame.OnUpdate"])
            end)

            it("passes the frame and elapsed through to the real handler", function()
                local seenFrame, seenElapsed
                local frame = MockFrame({OnUpdate = function(self, elapsed)
                    seenFrame, seenElapsed = self, elapsed
                end})
                MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {updateFrame = frame}})

                Profiler:Start(false)
                frame:GetScript("OnUpdate")(frame, 0.016)

                assert.are_equal(frame, seenFrame)
                assert.are_same(0.016, seenElapsed)
            end)

            it("hooks every named script on a frame", function()
                local frame = MockFrame({OnUpdate = function() end, OnEvent = function() end})
                MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {updateFrame = frame}})

                Profiler:Start(false)

                assert.are_same(0, Profiler.hookCallCount["Libs.HBDPins.updateFrame.OnUpdate"])
                assert.are_same(0, Profiler.hookCallCount["Libs.HBDPins.updateFrame.OnEvent"])
            end)

            it("restores the frame's own handler on Unhook", function()
                local handler = function() end
                local frame = MockFrame({OnUpdate = handler})
                MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {updateFrame = frame}})

                Profiler:Start(false)
                assert.are_not_equal(handler, frame:GetScript("OnUpdate"))
                Profiler:Unhook()

                assert.are_equal(handler, frame:GetScript("OnUpdate"))
            end)

            it("leaves a script another addon replaced mid-session alone", function()
                local frame = MockFrame({OnUpdate = function() end})
                MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {updateFrame = frame}})
                Profiler:Start(false)

                -- Someone else took the slot after the profiler installed its wrapper. It is theirs now.
                local foreign = function() end
                frame:SetScript("OnUpdate", foreign)
                Profiler:Unhook()

                assert.are_equal(foreign, frame:GetScript("OnUpdate"))
            end)

            it("does not stack wrappers when hooks are refreshed", function()
                local frame = MockFrame({OnUpdate = function() clock = clock + 3 end})
                MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {updateFrame = frame}})

                Profiler:Start(false)
                local afterFirst = frame:GetScript("OnUpdate")
                Profiler:RefreshHooks()

                assert.are_equal(afterFirst, frame:GetScript("OnUpdate"))
                frame:GetScript("OnUpdate")(frame, 0.016)
                assert.are_same(1, Profiler.hookCallCount["Libs.HBDPins.updateFrame.OnUpdate"])
                assert.are_same(3, Profiler.hookTimeCount["Libs.HBDPins.updateFrame.OnUpdate"])
            end)

            it("ignores a frame that has no such script", function()
                local frame = MockFrame({})
                MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {updateFrame = frame}})

                assert.is_true(Profiler:Start(false))
                assert.is_nil(Profiler.hookCallCount["Libs.HBDPins.updateFrame.OnUpdate"])
            end)

            it("ignores a library that does not expose the frame at all", function()
                MockLibStub({["HereBeDragonsQuestie-Pins-2.0"] = {}})

                assert.is_true(Profiler:Start(false))
                assert.is_nil(Profiler.hookCallCount["Libs.HBDPins.updateFrame.OnUpdate"])
            end)
        end)

        it("restores library functions on Unhook", function()
            local original = function() end
            MockLibStub({["HereBeDragonsQuestie-2.0"] = {GetZoneDistance = original}})
            local HBD = libraries["HereBeDragonsQuestie-2.0"]

            Profiler:Start(false)
            Profiler:Unhook()

            assert.are_equal(original, HBD.GetZoneDistance)
        end)

        it("does not stack wrappers when hooks are refreshed", function()
            MockLibStub({["HereBeDragonsQuestie-2.0"] = {GetZoneDistance = function() clock = clock + 2 end}})
            local HBD = libraries["HereBeDragonsQuestie-2.0"]

            Profiler:Start(false)
            local afterFirst = HBD.GetZoneDistance
            Profiler:RefreshHooks()

            assert.are_equal(afterFirst, HBD.GetZoneDistance)
            HBD.GetZoneDistance()
            assert.are_same(1, Profiler.hookCallCount["Libs.HBD.GetZoneDistance"])
            assert.are_same(2, Profiler.hookTimeCount["Libs.HBD.GetZoneDistance"])
        end)

        it("gives a table shared with a Questie module the library identity", function()
            local shared = {Convert = function() end}
            MockLibStub({["HereBeDragonsQuestie-2.0"] = {utils = shared}})
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.utils = shared

            Profiler:Start(false)

            assert.are_same(0, Profiler.hookCallCount["Libs.HBD.utils.Convert"])
            assert.is_nil(Profiler.hookCallCount[testModuleName .. ".utils.Convert"])
        end)
    end)

    describe("caller attribution", function()
        it("names the calling function of a nested call", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Inner = function()
                clock = clock + 3
            end
            testModule.Outer = function()
                testModule.Inner()
            end
            Profiler:Start(false)

            testModule.Outer()

            assert.are_same({[testModuleName .. ".Outer"] = 1},
                Profiler.callerCallCount[testModuleName .. ".Inner"])
        end)

        it("names the root for a call with no profiled function below it", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Work = function() end
            Profiler:Start(false)

            testModule.Work()

            assert.are_same({["(root)"] = 1}, Profiler.callerCallCount[testModuleName .. ".Work"])
        end)

        it("counts each caller of a shared function separately", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Shared = function()
                clock = clock + 1
            end
            testModule.FirstCaller = function()
                testModule.Shared()
            end
            testModule.SecondCaller = function()
                testModule.Shared()
                testModule.Shared()
            end
            Profiler:Start(false)

            testModule.FirstCaller()
            testModule.SecondCaller()

            assert.are_same({
                [testModuleName .. ".FirstCaller"] = 1,
                [testModuleName .. ".SecondCaller"] = 2,
            }, Profiler.callerCallCount[testModuleName .. ".Shared"])
        end)

        it("attributes elapsed time to the caller that spent it", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Shared = function()
                clock = clock + 2
            end
            testModule.FirstCaller = function()
                testModule.Shared()
            end
            testModule.SecondCaller = function()
                testModule.Shared()
                testModule.Shared()
            end
            Profiler:Start(false)

            testModule.FirstCaller()
            testModule.SecondCaller()

            assert.are_same({
                [testModuleName .. ".FirstCaller"] = 2,
                [testModuleName .. ".SecondCaller"] = 4,
            }, Profiler.callerTimeCount[testModuleName .. ".Shared"])
        end)

        it("resolves the caller of a call made after a caught descendant error", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Boom = function()
                error("expected failure")
            end
            testModule.Catcher = function()
                pcall(testModule.Boom)
            end
            testModule.After = function() end
            testModule.Root = function()
                testModule.Catcher()
                testModule.After()
            end
            Profiler:Start(false)

            testModule.Root()

            -- Boom's wrapper never ran its epilogue; After must still be attributed to Root, not to the
            -- frames that error stranded above it.
            assert.are_same({[testModuleName .. ".Root"] = 1},
                Profiler.callerCallCount[testModuleName .. ".After"])
        end)

        it("resolves the caller of a call made after a caught error, before the catcher returns", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Boom = function()
                error("expected failure")
            end
            testModule.Sibling = function() end
            testModule.Catcher = function()
                pcall(testModule.Boom)
                -- Still inside Catcher: the frame Boom left behind must not be read as Sibling's caller.
                testModule.Sibling()
            end
            Profiler:Start(false)

            testModule.Catcher()

            assert.are_same({[testModuleName .. ".Catcher"] = 1},
                Profiler.callerCallCount[testModuleName .. ".Sibling"])
        end)

        it("names the ThreadLib job as the caller of the work it scheduled", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Step = function()
                clock = clock + 2
            end
            testModule.Job = function()
                testModule.Step()
            end
            Profiler:Start(false)
            ThreadLib.Thread(testModule.Job, 0, nil, nil, nil, "DrawAvailableQuests")

            tickerCallbacks[1]()

            assert.are_same({["ThreadLib job: DrawAvailableQuests"] = 1},
                Profiler.callerCallCount[testModuleName .. ".Job"])
            assert.are_same({[testModuleName .. ".Job"] = 1},
                Profiler.callerCallCount[testModuleName .. ".Step"])
        end)

        it("clears edges when measurements are reset", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Work = function()
                clock = clock + 2
            end
            Profiler:Start(false)
            testModule.Work()

            Profiler:ResetMeasurements()

            assert.is_nil(Profiler.callerCallCount[testModuleName .. ".Work"])
            assert.is_nil(Profiler.callerTimeCount[testModuleName .. ".Work"])
            assert.are_same(0, Profiler.hookSelfTime[testModuleName .. ".Work"])
        end)

        it("preserves edges and self time after profiling stops", function()
            local testModule = QuestieLoader:CreateModule(testModuleName)
            testModule.Work = function()
                clock = clock + 2
            end
            Profiler:Start(false)
            testModule.Work()

            Profiler:Stop()

            assert.are_same({["(root)"] = 1}, Profiler.callerCallCount[testModuleName .. ".Work"])
            assert.are_same(2, Profiler.hookSelfTime[testModuleName .. ".Work"])
        end)
    end)

    it("terminates on cyclic and shared tables without probing frames or table-valued keys", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local shared = {
            Work = function() end,
        }
        local originalSharedWork = shared.Work
        shared.cycle = shared
        testModule.first = shared
        testModule.second = shared

        local getScriptCalls = 0
        local frame = {
            GetScript = function()
                getScriptCalls = getScriptCalls + 1
                error("GetScript must not be called")
            end,
            FrameMethod = function() end,
        }
        local originalGetScript = frame.GetScript
        local originalFrameMethod = frame.FrameMethod
        testModule.frame = frame

        local tableKey = {HiddenFunction = function() end}
        local originalHiddenFunction = tableKey.HiddenFunction
        testModule[tableKey] = "table key value"

        Profiler:Start(false)

        assert.are_equal(originalSharedWork, Profiler.lookupToHook[testModuleName .. ".first.Work"])
        assert.are_not_equal(originalSharedWork, shared.Work)
        assert.are_same(0, getScriptCalls)
        assert.are_equal(originalGetScript, frame.GetScript)
        assert.are_equal(originalFrameMethod, frame.FrameMethod)
        assert.are_equal(originalHiddenFunction, tableKey.HiddenFunction)
    end)

    it("hooks functions inside two bounded namespace levels", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local original = function()
            clock = clock + 6
        end
        testModule.tabs = {
            general = {
                Initialize = original,
            },
        }

        Profiler:Start(false)
        testModule.tabs.general.Initialize()

        local lookupKey = testModuleName .. ".tabs.general.Initialize"
        assert.are_not_equal(original, testModule.tabs.general.Initialize)
        assert.are_same(1, Profiler.hookCallCount[lookupKey])
        assert.are_same(6, Profiler.hookTimeCount[lookupKey])
    end)

    it("does not traverse large pure-data subtrees", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.RootWork = function() end
        local pureData = {}
        local descendantFunctions = {}
        for i = 1, 1000 do
            local descendant = {
                value = i,
                Work = function() end,
            }
            pureData[i] = descendant
            descendantFunctions[i] = descendant.Work
        end
        testModule.largeData = pureData

        Profiler:Start(false)

        assert.is_nil(Profiler.alreadyHooked[pureData])
        for i = 1, 1000 do
            assert.is_nil(Profiler.alreadyHooked[pureData[i]])
            assert.are_equal(descendantFunctions[i], pureData[i].Work)
        end
    end)

    it("does not traverse AceAddon and settings graphs from the Runtime Addon Object", function()
        local setProfile = function() end
        local profileFunction = function() end
        local testDB = {
            SetProfile = setProfile,
            profile = {
                ProfileFunction = profileFunction,
            },
        }
        local aceModuleWork = function() end
        Questie.db = testDB
        Questie.modules = {AceModule = {Work = aceModuleWork}}
        Questie.orderedModules = {Questie.modules.AceModule}

        Profiler:Start(false)
        assert.is_true(Profiler:RefreshHooks())

        assert.is_nil(Profiler.alreadyHooked[testDB])
        assert.is_nil(Profiler.alreadyHooked[testDB.profile])
        assert.is_nil(Profiler.alreadyHooked[Questie.modules])
        assert.is_nil(Profiler.alreadyHooked[Questie.orderedModules])
        assert.are_equal(setProfile, Questie.db.SetProfile)
        assert.are_equal(profileFunction, Questie.db.profile.ProfileFunction)
        assert.are_equal(aceModuleWork, Questie.modules.AceModule.Work)
        assert.is_nil(Profiler.lookupToHook["Questie.db.SetProfile"])
    end)

    it("uses an explicit ThreadLib job name before known function and stack metadata", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.KnownJob = function() end
        _G.debugstack = function()
            return "Modules/Quest/AvailableQuests/AvailableQuests.lua:123: in function 'original'"
        end
        Profiler:Start(false)

        ThreadLib.Thread(testModule.KnownJob, 0, nil, nil, nil, "AvailableQuests.CalculateAndDrawAll")

        local explicitLookupKey = "ThreadLib job: AvailableQuests.CalculateAndDrawAll"
        assert.are_same(1, Profiler.hookCallCount[explicitLookupKey])
        assert.are_same(1, Profiler.threadJobCallCount[explicitLookupKey])
        assert.is_nil(Profiler.hookCallCount["ThreadLib job: " .. testModuleName .. ".KnownJob"])
        assert.is_nil(Profiler.hookCallCount["ThreadLib job: Modules/Quest/AvailableQuests/AvailableQuests.lua:123"])
    end)

    it("names an anonymous job after the profiled function that submitted it", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Submitter = function()
            ThreadLib.ThreadSimple(function() end, 0)
        end
        -- A stack good enough to name the job by call site, so the assertion proves the shadow stack won.
        _G.debugstack = function()
            return "Modules/Quest/AvailableQuests/AvailableQuests.lua:123"
        end
        Profiler:Start(false)

        testModule.Submitter()

        local lookupKey = "ThreadLib job: " .. testModuleName .. ".Submitter"
        assert.are_same(1, Profiler.hookCallCount[lookupKey])
        assert.are_same(1, Profiler.threadJobCallCount[lookupKey])
        assert.is_nil(Profiler.hookCallCount
            ["ThreadLib job: Modules/Quest/AvailableQuests/AvailableQuests.lua:123"])
    end)

    it("registers a job submitted by another job's anonymous body under a single prefix", function()
        _G.debugstack = function()
            return "Modules/Quest/AvailableQuests/AvailableQuests.lua:123"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function()
            -- No profiled function on the coroutine's stack, so the nearest owner of this submission is the
            -- outer job itself - whose key already carries the "ThreadLib job: " prefix.
            ThreadLib.ThreadSimple(function() end, 0)
        end, 0)
        tickerCallbacks[1]()

        local singlePrefixKey = "ThreadLib job: Modules/Quest/AvailableQuests/AvailableQuests.lua:123"
        -- Parent and child share the name, exactly as several closures submitted by one function would.
        assert.are_same(2, Profiler.threadJobCallCount[singlePrefixKey])
        for lookupKey in pairs(Profiler.hookCallCount) do
            assert.is_nil(string.find(lookupKey, "ThreadLib job: ThreadLib job:", 1, true))
        end
    end)

    it("looks past ThreadLib's own frames to the function that submitted the job", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        -- ThreadSimple forwards to Thread, so the scheduler sits on the shadow stack above the submitter.
        -- Naming the job after it would label every job in the addon "ThreadLib.Thread".
        testModule.Submitter = function()
            ThreadLib.ThreadSimple(function() end, 0)
        end
        Profiler:Start(false)

        testModule.Submitter()

        assert.are_same(1, Profiler.threadJobCallCount["ThreadLib job: " .. testModuleName .. ".Submitter"])
        assert.is_nil(Profiler.threadJobCallCount["ThreadLib job: ThreadLib.Thread"])
        assert.is_nil(Profiler.threadJobCallCount["ThreadLib job: ThreadLib.ThreadSimple"])
    end)

    it("prefers an explicit name over the submitting function", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Submitter = function()
            ThreadLib.Thread(function() end, 0, nil, nil, nil, "Explicitly named work")
        end
        Profiler:Start(false)

        testModule.Submitter()

        assert.are_same(1, Profiler.threadJobCallCount["ThreadLib job: Explicitly named work"])
        assert.is_nil(Profiler.threadJobCallCount["ThreadLib job: " .. testModuleName .. ".Submitter"])
    end)

    it("keeps the addon prefix off a job name WoW truncated from the left", function()
        -- WoW renders a long path as "...erface/AddOns/Questie/...", which a match needing the whole word
        -- "Interface" would leave untouched, putting the ellipsis and full path in the job's name.
        _G.debugstack = function()
            return "...erface/AddOns/Questie/Modules/Quest/QuestieQuest.lua:105"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        assert.are_same(1,
            Profiler.threadJobCallCount["ThreadLib job: Modules/Quest/QuestieQuest.lua:105"])
    end)

    it("recovers a job name whose truncation cut landed inside the addon marker itself", function()
        -- The cut position depends on total path length, so for a window of lengths the ellipsis bisects
        -- "AddOns/Questie/" and a match needing the whole marker is a no-op.
        _G.debugstack = function()
            return "...Ons/Questie/Modules/Quest/QuestieQuest.lua:105"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        assert.are_same(1,
            Profiler.threadJobCallCount["ThreadLib job: Modules/Quest/QuestieQuest.lua:105"])
    end)

    it("recovers a job name whose truncation cut landed inside the Questie segment", function()
        _G.debugstack = function()
            return "...stie/Modules/Quest/QuestieQuest.lua:105"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        assert.are_same(1,
            Profiler.threadJobCallCount["ThreadLib job: Modules/Quest/QuestieQuest.lua:105"])
    end)

    it("leaves a foreign addon's truncated path alone even when it ends like the marker", function()
        _G.debugstack = function()
            return "...Ons/SomeOtherAddon/Core.lua:7"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        assert.are_same(1,
            Profiler.threadJobCallCount["ThreadLib job: ...Ons/SomeOtherAddon/Core.lua:7"])
    end)

    it("aggregates repeated ThreadLib jobs with the same explicit name", function()
        Profiler:Start(false)

        ThreadLib.Thread(function() end, 0, nil, nil, nil, "Shared operation")
        ThreadLib.Thread(function() end, 0, nil, nil, nil, "Shared operation")

        local lookupKey = "ThreadLib job: Shared operation"
        assert.are_same(2, Profiler.hookCallCount[lookupKey])
        assert.are_same(2, Profiler.threadJobCallCount[lookupKey])
    end)

    it("names an anonymous ThreadLib job from the first useful external stack frame", function()
        _G.debugstack = function()
            return "[tail call]: ?\n"
                .. "Modules/Libs/ThreadLib.lua:86: in function 'Thread'\n"
                .. "[C]: in function 'pcall'\n"
                .. "Modules/Profiler/QuestieProfiler.lua:115: in function 'override'\n"
                .. "?: ?\n"
                .. "Modules/Quest/AvailableQuests/AvailableQuests.lua:123: in function 'original'"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        local lookupKey = "ThreadLib job: Modules/Quest/AvailableQuests/AvailableQuests.lua:123"
        assert.are_same(1, Profiler.hookCallCount[lookupKey])
        assert.is_nil(string.find(lookupKey, "ThreadLib.lua", 1, true))
        assert.is_nil(string.find(lookupKey, "original", 1, true))
    end)

    it("names an anonymous job by its definition site, not the call site that repeats the path", function()
        _G.debugstack = function()
            return "Modules/Libs/ThreadLib.lua:86: in function 'Thread'\n"
                .. "[Interface/AddOns/Questie/Modules/QuestieInit.lua]:394: "
                .. "in function <Interface/AddOns/Questie/Modules/QuestieInit.lua:392>"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        -- Lua renders an anonymous function as "<file:line>" after the call site, repeating the whole path.
        local lookupKey = "ThreadLib job: Modules/QuestieInit.lua:392"
        assert.are_same(1, Profiler.hookCallCount[lookupKey])
    end)

    it("drops the addon path prefix and WoW's brackets from a call site", function()
        _G.debugstack = function()
            return "Modules/Libs/ThreadLib.lua:86: in function 'Thread'\n"
                .. "[Interface/AddOns/Questie/Modules/Quest/QuestieQuest.lua]:507"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        local lookupKey = "ThreadLib job: Modules/Quest/QuestieQuest.lua:507"
        assert.are_same(1, Profiler.hookCallCount[lookupKey])
    end)

    it("aggregates one closure submitted from several call sites into a single job", function()
        local callSiteLine = 100
        _G.debugstack = function()
            return "Modules/Libs/ThreadLib.lua:86: in function 'Thread'\n"
                .. "[Interface/AddOns/Questie/Modules/QuestieInit.lua]:" .. callSiteLine
                .. ": in function <Interface/AddOns/Questie/Modules/QuestieInit.lua:50>"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)
        callSiteLine = 200
        ThreadLib.ThreadSimple(function() end, 0)

        -- The closure is the scheduling unit; splitting it by call site would report one job as two.
        local lookupKey = "ThreadLib job: Modules/QuestieInit.lua:50"
        assert.are_same(2, Profiler.threadJobCallCount[lookupKey])
    end)

    it("leaves another addon's path alone, so nothing collapses into a Questie name", function()
        _G.debugstack = function()
            return "Modules/Libs/ThreadLib.lua:86: in function 'Thread'\n"
                .. "[Interface/AddOns/SomeOtherAddon/Modules/QuestieInit.lua]:100"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        local lookupKey = "ThreadLib job: Interface/AddOns/SomeOtherAddon/Modules/QuestieInit.lua:100"
        assert.are_same(1, Profiler.threadJobCallCount[lookupKey])
    end)

    it("spells a backslash path the way addon-load rows spell it", function()
        _G.debugstack = function()
            return "Modules/Libs/ThreadLib.lua:86: in function 'Thread'\n"
                .. "[Interface\\AddOns\\Questie\\Modules\\QuestieInit.lua]:100"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(function() end, 0)

        local lookupKey = "ThreadLib job: Modules/QuestieInit.lua:100"
        assert.are_same(1, Profiler.threadJobCallCount[lookupKey])
    end)

    it("uses the exact module path for a known submitted ThreadLib function", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.KnownJob = function() end
        _G.debugstack = function()
            return "Modules/Libs/ThreadLib.lua:86\nModules/Quest/AvailableQuests/AvailableQuests.lua:123"
        end
        Profiler:Start(false)

        ThreadLib.ThreadSimple(testModule.KnownJob, 0)

        local lookupKey = "ThreadLib job: " .. testModuleName .. ".KnownJob"
        assert.are_same(1, Profiler.hookCallCount[lookupKey])
        assert.are_same(1, Profiler.threadJobCallCount[lookupKey])
    end)

    it("falls back safely when an anonymous ThreadLib job has only unusable, internal, or missing stack frames", function()
        _G.debugstack = function()
            return "[tail call]: ?\n[C]: in function 'pcall'\n?: ?\nModules/Libs/ThreadLib.lua:86\n"
                .. "Modules/Profiler/QuestieProfiler.lua:115: in function 'wrapper'"
        end
        Profiler:Start(false)
        ThreadLib.ThreadSimple(function() end, 0)

        _G.debugstack = nil
        ThreadLib.ThreadSimple(function() end, 0)

        local lookupKey = "ThreadLib job: anonymous call site"
        assert.are_same(2, Profiler.hookCallCount[lookupKey])
        assert.are_same(2, Profiler.threadJobCallCount[lookupKey])
    end)

    it("aggregates fresh anonymous ThreadLib jobs by call site without retaining closures", function()
        _G.debug = nil
        _G.debugstack = function()
            return "Modules/Profiler/QuestieProfiler.test.lua:anonymous submission\ncaller"
        end
        local success, profileError = pcall(function()
            Profiler:Start(false)
            for _ = 1, 100 do
                ThreadLib.ThreadSimple(function() end, 0)
            end
        end)
        _G.debug = originalDebug

        assert.is_true(success, profileError)
        local lookupKey = "ThreadLib job: Modules/Profiler/QuestieProfiler.test.lua:anonymous submission"
        assert.are_same(100, Profiler.hookCallCount[lookupKey])
        assert.are_same(100, Profiler.threadJobCallCount[lookupKey])
        assert.is_nil(Profiler.lookupToHook[lookupKey])

        local jobMetricCount = 0
        for metricKey in pairs(Profiler.threadJobCallCount) do
            jobMetricCount = jobMetricCount + 1
            assert.are_same(lookupKey, metricKey)
        end
        assert.are_same(1, jobMetricCount)
    end)

    it("wraps and restores each alias slot independently", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local original = function()
            clock = clock + 1
        end
        testModule.FirstAlias = original
        testModule.SecondAlias = original
        Profiler:Start(false)

        local firstWrapper = testModule.FirstAlias
        local secondWrapper = testModule.SecondAlias
        testModule.FirstAlias()
        testModule.SecondAlias()

        assert.are_not_equal(firstWrapper, secondWrapper)
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".FirstAlias"])
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".SecondAlias"])

        Profiler:Unhook()
        assert.are_equal(original, testModule.FirstAlias)
        assert.are_equal(original, testModule.SecondAlias)
    end)

    it("wraps a late-bound module method once when hooks are refreshed", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Existing = function() end
        Profiler:Start(false)
        local lateOriginal = function()
            clock = clock + 4
        end
        testModule.LateWork = lateOriginal

        assert.is_true(Profiler:RefreshHooks())
        local lateWrapper = testModule.LateWork
        assert.are_not_equal(lateOriginal, lateWrapper)
        assert.are_equal(lateOriginal, Profiler.lookupToHook[testModuleName .. ".LateWork"])

        assert.is_true(Profiler:RefreshHooks())
        assert.are_equal(lateWrapper, testModule.LateWork)
        testModule.LateWork()
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".LateWork"])
        assert.are_same(4, Profiler.hookTimeCount[testModuleName .. ".LateWork"])
    end)

    it("leaves functions untouched when ThreadLib profiling callbacks have another owner", function()
        local foreignOwner = {}
        assert.is_true(ThreadLib.SetProfilingCallbacks(foreignOwner, {}))
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local original = function() end
        testModule.Work = original

        local armed = Profiler:Start(false)

        assert.is_false(armed)
        assert.is_false(Profiler.active)
        assert.are_equal(original, testModule.Work)
        ThreadLib.ClearProfilingCallbacks(foreignOwner)
    end)

    it("delegates UI entry points without mixing frame state into the engine", function()
        local created = 0
        local shown = 0
        local hidden = 0
        ProfilerUI.Create = function()
            created = created + 1
            return "created frame"
        end
        ProfilerUI.Show = function()
            shown = shown + 1
            return "shown frame"
        end
        ProfilerUI.Hide = function()
            hidden = hidden + 1
        end

        assert.are_same("created frame", Profiler:CreateUI())
        assert.are_same("shown frame", Profiler:ShowUI())
        Profiler:HideUI()

        assert.are_same(1, created)
        assert.are_same(1, shown)
        assert.are_same(1, hidden)
        assert.is_nil(Profiler.baseUI)
        assert.is_nil(Profiler.uiTicker)
    end)

    it("stops profiling without changing UI visibility", function()
        local hidden = 0
        ProfilerUI.Hide = function()
            hidden = hidden + 1
        end

        Profiler:Start(false)
        local hidesAfterStart = hidden
        Profiler:Stop()

        assert.are_same(hidesAfterStart, hidden)
        assert.is_false(Profiler.active)
    end)

    it("excludes profiler UI functions from hook traversal", function()
        local uiRefresh = function() end
        ProfilerUI.Refresh = uiRefresh

        Profiler:Start(false)

        assert.are_equal(uiRefresh, ProfilerUI.Refresh)
        assert.is_nil(Profiler.hookCallCount["ProfilerUI.Refresh"])
    end)

    it("does not stack wrappers when Start is repeated", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Work = function() end
        Profiler:Start(false)
        local firstWrapper = testModule.Work

        Profiler:Start(false)
        testModule.Work()

        assert.are_equal(firstWrapper, testModule.Work)
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".Work"])
    end)

    it("resets measurements without replacing installed wrappers", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Work = function()
            clock = clock + 3
        end
        Profiler:Start(false)
        local wrapper = testModule.Work
        testModule.Work()

        Profiler:ResetMeasurements()

        assert.are_equal(wrapper, testModule.Work)
        assert.is_true(Profiler.active)
        assert.are_same(0, Profiler.hookCallCount[testModuleName .. ".Work"])
        assert.are_same(0, Profiler.hookTimeCount[testModuleName .. ".Work"])
        testModule.Work()
        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".Work"])
        assert.are_same(3, Profiler.hookTimeCount[testModuleName .. ".Work"])
    end)

    it("releases wrappers on Stop while preserving completed measurements", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Work = function()
            clock = clock + 3
        end
        Profiler:Start(false)
        local weakWrapper = setmetatable({testModule.Work}, {__mode = "v"})
        testModule.Work()

        local hookedFunctionCount = Profiler.hookedFunctionCount
        Profiler:Stop()
        collectgarbage("collect")
        collectgarbage("collect")

        local lookupKey = testModuleName .. ".Work"
        assert.are_same(0, #Profiler.hooks)
        assert.are_same(hookedFunctionCount, Profiler.hookedFunctionCount)
        assert.is_nil(weakWrapper[1])
        assert.are_same(1, Profiler.hookCallCount[lookupKey])
        assert.are_same(3, Profiler.hookTimeCount[lookupKey])
    end)

    it("keeps a retained wrapper disabled after profiling restarts", function()
        local originalCalls = 0
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Work = function()
            originalCalls = originalCalls + 1
            clock = clock + 2
        end
        Profiler:Start(false)
        local retainedWrapper = testModule.Work

        Profiler:Stop()
        retainedWrapper()
        assert.are_same(1, originalCalls)

        Profiler:Start(false)
        retainedWrapper()

        assert.are_same(2, originalCalls)
        assert.are_same(0, Profiler.hookCallCount[testModuleName .. ".Work"])
        assert.are_same(0, Profiler.hookTimeCount[testModuleName .. ".Work"])
    end)

    it("does not double-count a replacement that delegates to a stale wrapper", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Work = function()
            clock = clock + 3
        end
        Profiler:Start(false)
        local staleWrapper = testModule.Work

        testModule.Work = function(...)
            return staleWrapper(...)
        end
        Profiler:Stop()
        Profiler:Start(false)
        testModule.Work()

        assert.are_same(1, Profiler.hookCallCount[testModuleName .. ".Work"])
        assert.are_same(3, Profiler.hookTimeCount[testModuleName .. ".Work"])
    end)

    it("does not publish a main-thread call across Stop and restart", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.RestartDuringCall = function()
            clock = clock + 2
            Profiler:Stop()
            assert.is_true(Profiler:Start(false))
            clock = clock + 7
        end
        Profiler:Start(false)
        local firstWrapper = testModule.RestartDuringCall

        testModule.RestartDuringCall()

        local lookupKey = testModuleName .. ".RestartDuringCall"
        assert.is_true(Profiler.active)
        assert.are_not_equal(firstWrapper, testModule.RestartDuringCall)
        assert.are_same(0, Profiler.hookCallCount[lookupKey])
        assert.are_same(0, Profiler.hookTimeCount[lookupKey])
    end)

    it("does not publish a suspended wrapper into a restarted session", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.SuspendedWork = function()
            clock = clock + 2
            coroutine.yield()
            clock = clock + 4
        end
        Profiler:Start(false)
        ThreadLib.ThreadSimple(testModule.SuspendedWork, 0)

        tickerCallbacks[1]()
        Profiler:Stop()
        Profiler:Start(false)
        tickerCallbacks[1]()

        local lookupKey = testModuleName .. ".SuspendedWork"
        assert.are_same(0, Profiler.hookCallCount[lookupKey])
        assert.are_same(0, Profiler.hookTimeCount[lookupKey])
    end)

    it("allows repeated teardown and starts a fresh session on restart", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        local original = function() end
        testModule.Work = original
        Profiler:Start(false)
        local firstWrapper = testModule.Work
        testModule.Work()

        Profiler:Unhook()
        Profiler:Unhook()
        assert.are_equal(original, testModule.Work)

        Profiler:Start(false)
        assert.are_not_equal(firstWrapper, testModule.Work)
        assert.are_same(0, Profiler.hookCallCount[testModuleName .. ".Work"])
    end)

    it("preserves a slot replaced by another owner after profiling starts", function()
        local testModule = QuestieLoader:CreateModule(testModuleName)
        testModule.Work = function() end
        Profiler:Start(false)
        local laterReplacement = function() return "replacement" end
        testModule.Work = laterReplacement

        Profiler:Unhook()

        assert.are_equal(laterReplacement, testModule.Work)
        assert.are_same("replacement", testModule.Work())
    end)

    it("hooks and restores functions on the global Questie addon object", function()
        local original = function()
            clock = clock + 7
        end
        Questie.ProfilerTestFunction = original
        Profiler:Start(false)

        Questie.ProfilerTestFunction()

        assert.are_not_equal(original, Questie.ProfilerTestFunction)
        assert.are_same(1, Profiler.hookCallCount["Questie.ProfilerTestFunction"])
        assert.are_same(7, Profiler.hookTimeCount["Questie.ProfilerTestFunction"])
        Profiler:Unhook()
        assert.are_equal(original, Questie.ProfilerTestFunction)
    end)
end)
