dofile("setupTests.lua")

describe("QuestieLoader", function()
    local originalProfilerEnabled
    local originalGetTimePreciseSec
    local originalDebugStack
    local originalCollectGarbage
    local clockSeconds
    local currentSourceFile

    ---Loads QuestieLoader with the current mocks in place. It reads QuestieProfilerEnabled at load time,
    ---so the flag has to be set before this runs.
    local function LoadQuestieLoader()
        dofile("Modules/Libs/QuestieLoader.lua")
    end

    ---@param milliseconds number
    local function AdvanceClock(milliseconds)
        clockSeconds = clockSeconds + (milliseconds / 1000)
    end

    before_each(function()
        originalProfilerEnabled = _G.QuestieProfilerEnabled
        originalGetTimePreciseSec = _G.GetTimePreciseSec
        originalDebugStack = _G.debugstack
        originalCollectGarbage = _G.collectgarbage

        clockSeconds = 0
        currentSourceFile = "Modules/Unknown.lua"
        _G.GetTimePreciseSec = function()
            return clockSeconds
        end
        -- WoW renders the path bracketed, which is what the loader parses.
        _G.debugstack = function()
            return "[Interface/AddOns/Questie/" .. currentSourceFile .. "]:3: in main chunk\n"
        end
    end)

    after_each(function()
        _G.QuestieProfilerEnabled = originalProfilerEnabled
        _G.GetTimePreciseSec = originalGetTimePreciseSec
        _G.debugstack = originalDebugStack
        _G.collectgarbage = originalCollectGarbage
        -- Leave a clean, uninstrumented loader behind for any test file that runs after this one.
        LoadQuestieLoader()
    end)

    describe("module registration", function()
        before_each(function()
            _G.QuestieProfilerEnabled = nil
            LoadQuestieLoader()
        end)

        it("returns the same table for repeated CreateModule calls", function()
            assert.are_equal(QuestieLoader:CreateModule("Repeated"), QuestieLoader:CreateModule("Repeated"))
        end)

        it("returns the same table from ImportModule as from CreateModule", function()
            assert.are_equal(QuestieLoader:CreateModule("Shared"), QuestieLoader:ImportModule("Shared"))
        end)

        it("gives every module a private table", function()
            assert.are_same("table", type(QuestieLoader:CreateModule("WithPrivate").private))
        end)
    end)

    describe("load timing when the profiler is disabled", function()
        before_each(function()
            _G.QuestieProfilerEnabled = nil
            LoadQuestieLoader()
        end)

        it("records nothing", function()
            QuestieLoader:CreateModule("First")
            AdvanceClock(50)
            QuestieLoader:CreateModule("Second")

            assert.is_nil(QuestieLoader.loadTimings)
        end)

        it("does not read the clock", function()
            local clockReads = 0
            _G.GetTimePreciseSec = function()
                clockReads = clockReads + 1
                return clockSeconds
            end

            QuestieLoader:CreateModule("First")
            QuestieLoader:ImportModule("Second")
            QuestieLoader:StampLoadBoundary()

            assert.are_same(0, clockReads)
        end)
    end)

    describe("load timing when the profiler is enabled", function()
        before_each(function()
            _G.QuestieProfilerEnabled = true
            LoadQuestieLoader()
        end)

        it("charges elapsed time to the file that opened the interval", function()
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:CreateModule("Alpha")
            AdvanceClock(50)

            currentSourceFile = "Modules/Beta.lua"
            QuestieLoader:CreateModule("Beta")

            assert.are_same(50, QuestieLoader.loadTimings["Modules/Alpha.lua"])
        end)

        it("attributes time before the first stamp to the loader file that started timing", function()
            AdvanceClock(12)
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:CreateModule("Alpha")

            assert.are_same(12, QuestieLoader.loadTimings["Modules/Libs/QuestieLoader.lua"])
        end)

        it("names the embedded-library interval from the boundary stamp in embeds.xml", function()
            -- The real startup sequence: the loader's own remainder, then the embeds boundary, then the
            -- libraries, closed by the first Lua file's module call.
            AdvanceClock(2)
            currentSourceFile = "embeds.xml:<Scripts>"
            QuestieLoader:StampLoadBoundary()
            AdvanceClock(400)

            currentSourceFile = "Questie.lua"
            QuestieLoader:CreateModule("Questie")

            assert.are_same(2, QuestieLoader.loadTimings["Modules/Libs/QuestieLoader.lua"])
            assert.are_same(400, QuestieLoader.loadTimings["embeds.xml"])
        end)

        it("opens an interval named after an XML group at a boundary stamp", function()
            currentSourceFile = "Localization/lookups/lookupZones.lua"
            QuestieLoader:ImportModule("l10n")
            AdvanceClock(3)

            -- An inline Script chunk reports the XML's own path, ":<Scripts>" suffixed, in main chunk.
            currentSourceFile = "Localization/lookups/Classic/lookupItems/lookupItems.xml:<Scripts>"
            QuestieLoader:StampLoadBoundary()
            AdvanceClock(200)

            currentSourceFile = "Modules/Libs/DistanceUtils.lua"
            QuestieLoader:CreateModule("DistanceUtils")

            -- Without the boundary, the group's whole parse cost lands on lookupZones.lua.
            assert.are_same(3, QuestieLoader.loadTimings["Localization/lookups/lookupZones.lua"])
            assert.are_same(200,
                QuestieLoader.loadTimings["Localization/lookups/Classic/lookupItems/lookupItems.xml"])
        end)

        it("ignores a boundary stamp that does not come from a main chunk", function()
            currentSourceFile = "Localization/lookups/lookupZones.lua"
            QuestieLoader:ImportModule("l10n")
            AdvanceClock(3)

            _G.debugstack = function()
                return "[Interface/AddOns/Questie/Modules/Foo.lua]:10: in function DoWork\n"
            end
            QuestieLoader:StampLoadBoundary()
            AdvanceClock(4)

            _G.debugstack = function()
                return "[Interface/AddOns/Questie/Modules/Beta.lua]:3: in main chunk\n"
            end
            QuestieLoader:CreateModule("Beta")

            -- The runtime stamp neither closed the interval nor opened one of its own.
            assert.are_same(7, QuestieLoader.loadTimings["Localization/lookups/lookupZones.lua"])
        end)

        it("accumulates repeated intervals for the same file", function()
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:CreateModule("Alpha")
            AdvanceClock(10)
            QuestieLoader:ImportModule("Something")
            AdvanceClock(5)
            currentSourceFile = "Modules/Beta.lua"
            QuestieLoader:CreateModule("Beta")

            assert.are_same(15, QuestieLoader.loadTimings["Modules/Alpha.lua"])
        end)

        it("times ImportModule as well as CreateModule", function()
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:ImportModule("Alpha")
            AdvanceClock(7)
            currentSourceFile = "Modules/Beta.lua"
            QuestieLoader:ImportModule("Beta")

            assert.are_same(7, QuestieLoader.loadTimings["Modules/Alpha.lua"])
        end)

        it("falls back to a named bucket when a main chunk yields no usable path", function()
            _G.debugstack = function()
                return "[string \"a loaded chunk\"]:1: in main chunk\n"
            end
            QuestieLoader:CreateModule("Alpha")
            AdvanceClock(3)
            QuestieLoader:CreateModule("Beta")

            assert.are_same(3, QuestieLoader.loadTimings["(unknown source)"])
        end)

        it("closes the final file's interval on FinishLoadTimings", function()
            currentSourceFile = "Questie.lua"
            QuestieLoader:CreateModule("Last")
            AdvanceClock(25)

            QuestieLoader:FinishLoadTimings()

            assert.are_same(25, QuestieLoader.loadTimings["Questie.lua"])
        end)

        it("stops timing after FinishLoadTimings", function()
            currentSourceFile = "Questie.lua"
            QuestieLoader:CreateModule("Last")
            QuestieLoader:FinishLoadTimings()
            local closedTotal = QuestieLoader.loadTimings["Questie.lua"]

            AdvanceClock(100)
            QuestieLoader:ImportModule("AfterLoad")

            assert.are_same(closedTotal, QuestieLoader.loadTimings["Questie.lua"])
        end)

        it("records allocation alongside elapsed time", function()
            local allocatedKilobytes = 0
            _G.collectgarbage = function(option)
                if option == "count" then return allocatedKilobytes end
                return 0
            end
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:CreateModule("Alpha")
            allocatedKilobytes = 2048

            currentSourceFile = "Modules/Beta.lua"
            QuestieLoader:CreateModule("Beta")

            assert.are_same(2048, QuestieLoader.loadMemory["Modules/Alpha.lua"])
        end)

        it("reports a negative allocation when the collector freed memory", function()
            local allocatedKilobytes = 5000
            _G.collectgarbage = function(option)
                if option == "count" then return allocatedKilobytes end
                return 0
            end
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:CreateModule("Alpha")
            allocatedKilobytes = 1000

            currentSourceFile = "Modules/Beta.lua"
            QuestieLoader:CreateModule("Beta")

            assert.are_same(-4000, QuestieLoader.loadMemory["Modules/Alpha.lua"])
        end)

        it("ignores a call made from inside a function", function()
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:CreateModule("Alpha")
            AdvanceClock(40)

            -- An init routine or lazy import resolving a module at runtime, rather than a file registering
            -- itself. Stamping here would close Alpha's interval and charge what follows to the caller.
            _G.debugstack = function()
                return "[Interface/AddOns/Questie/Modules/Beta.lua]:120: in function 'Initialize'\n"
            end
            QuestieLoader:ImportModule("Beta")

            assert.is_nil(QuestieLoader.loadTimings["Modules/Beta.lua"])
        end)

        it("leaves the loading file's interval open across a runtime import", function()
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:CreateModule("Alpha")
            AdvanceClock(40)
            _G.debugstack = function()
                return "[Interface/AddOns/Questie/Modules/Beta.lua]:120: in function 'Initialize'\n"
            end
            QuestieLoader:ImportModule("Beta")
            AdvanceClock(10)

            QuestieLoader:FinishLoadTimings()

            -- All 50ms belongs to the file that was loading, not split with the runtime caller.
            assert.are_same(50, QuestieLoader.loadTimings["Modules/Alpha.lua"])
        end)

        it("ignores a tail call, whose frame the interpreter has already discarded", function()
            currentSourceFile = "Modules/Alpha.lua"
            QuestieLoader:CreateModule("Alpha")
            AdvanceClock(30)
            _G.debugstack = function()
                return "[tail call]: ?\n"
            end
            QuestieLoader:ImportModule("Beta")
            QuestieLoader:FinishLoadTimings()

            assert.are_same(30, QuestieLoader.loadTimings["Modules/Alpha.lua"])
        end)

        it("still registers modules normally while timing", function()
            local module = QuestieLoader:CreateModule("Timed")

            assert.are_equal(module, QuestieLoader:ImportModule("Timed"))
            assert.are_same("table", type(module.private))
        end)
    end)
end)
