dofile("setupTests.lua")

describe("QuestieProfilerPreHook", function()
    ---@type QuestieProfilerPreHook
    local PreHook
    ---@type QuestieProfiler
    local Profiler
    local originalProfilerEnabled
    local originalCreateFrame
    local originalTimerAPI
    local originalGetTimePreciseSec

    ---Loads the pre-hook against whatever modules exist right now. It reads QuestieProfilerEnabled at load
    ---time and installs a loader observer, so both have to be arranged before this runs.
    ---@param enabled boolean?
    local function LoadPreHook(enabled)
        _G.QuestieProfilerEnabled = enabled
        dofile("Modules/Profiler/QuestieProfilerPreHook.lua")
        PreHook = QuestieLoader:ImportModule("ProfilerPreHook")
    end

    ---@param moduleName string
    ---@param functions table<string, function>
    local function GivenModule(moduleName, functions)
        local module = QuestieLoader:CreateModule(moduleName)
        for name, fn in pairs(functions) do
            module[name] = fn
        end
        return module
    end

    ---@param moduleName string
    ---@param functionName string
    ---@return table? target
    local function TargetFor(moduleName, functionName)
        for _, target in ipairs(PreHook.targets) do
            if target.moduleName == moduleName and target.functionName == functionName then
                return target
            end
        end
        return nil
    end

    ---Loads the profiler engine with just enough around it to exercise real pre-hook targets.
    ---@return QuestieProfiler
    local function LoadProfiler()
        _G.C_Timer = {NewTicker = function() return {Cancel = function() end} end}
        _G.GetTimePreciseSec = _G.GetTimePreciseSec or function() return 0 end
        dofile("Modules/Libs/ThreadLib.lua")
        local ProfilerUI = QuestieLoader:ImportModule("ProfilerUI")
        ProfilerUI.Create = function() end
        ProfilerUI.Show = function() end
        ProfilerUI.Hide = function() end
        dofile("Modules/Profiler/QuestieProfiler.lua")
        Profiler = QuestieLoader:ImportModule("Profiler")
        return Profiler
    end

    before_each(function()
        Profiler = nil
        originalProfilerEnabled = _G.QuestieProfilerEnabled
        originalCreateFrame = _G.CreateFrame
        originalTimerAPI = _G.C_Timer
        originalGetTimePreciseSec = _G.GetTimePreciseSec
        -- No frame: the ADDON_LOADED listener is optional and the tests drive Finish directly.
        _G.CreateFrame = nil
        -- A loader with only the modules each test creates, so a sweep has a knowable scope.
        dofile("Modules/Libs/QuestieLoader.lua")
    end)

    after_each(function()
        if Profiler then
            Profiler:Unhook()
        end
        QuestieLoader:SetModuleCallObserver(nil)
        _G.QuestieProfilerEnabled = originalProfilerEnabled
        _G.CreateFrame = originalCreateFrame
        _G.C_Timer = originalTimerAPI
        _G.GetTimePreciseSec = originalGetTimePreciseSec
        dofile("Modules/Libs/QuestieLoader.lua")
    end)

    describe("when profiling is not enabled at startup", function()
        it("installs nothing and attaches no observer", function()
            local original = function() end
            local module = GivenModule("PreHookOff", {Work = original})

            LoadPreHook(nil)
            QuestieLoader:CreateModule("PreHookLater")

            assert.is_false(PreHook.installed)
            assert.are_same(0, #PreHook.targets)
            assert.are_equal(original, module.Work)
        end)
    end)

    describe("installation", function()
        before_each(function()
            GivenModule("PreHookAlpha", {Work = function() return "worked" end})
            LoadPreHook(true)
            -- The sweep runs on the next module registration, which is any file's first loader call.
            QuestieLoader:CreateModule("PreHookTrigger")
        end)

        it("replaces a module function with an indirection", function()
            local target = TargetFor("PreHookAlpha", "Work")

            assert.is_not_nil(target)
            assert.are_not_equal(target.original, QuestieLoader._modules.PreHookAlpha.Work)
            assert.are_equal(target.wrapper, QuestieLoader._modules.PreHookAlpha.Work)
        end)

        it("passes straight through to the original while nothing is measuring", function()
            assert.are_same("worked", QuestieLoader._modules.PreHookAlpha.Work())
        end)

        it("is what a file-scope alias captures, which is the whole point", function()
            -- Exactly what a consumer does at its top: read the slot once and keep it.
            local aliased = QuestieLoader._modules.PreHookAlpha.Work
            local target = TargetFor("PreHookAlpha", "Work")

            -- A session redirects the indirection; the alias, holding the wrapper, follows.
            target.slot[target.functionName] = function() return "measured" end

            assert.are_same("measured", aliased())
        end)

        it("restores through the same slot, so a stopped session leaves the alias working", function()
            local aliased = QuestieLoader._modules.PreHookAlpha.Work
            local target = TargetFor("PreHookAlpha", "Work")
            target.slot[target.functionName] = function() return "measured" end

            target.slot[target.functionName] = target.original

            assert.are_same("worked", aliased())
        end)

        it("reports the current target through the slot, so ownership checks work", function()
            local target = TargetFor("PreHookAlpha", "Work")
            local override = function() end
            target.slot[target.functionName] = override

            assert.are_equal(override, target.slot[target.functionName])
        end)

        it("preserves arguments and nil-bearing returns exactly", function()
            GivenModule("PreHookTuple", {Echo = function(a, b, c) return a, b, c end})
            QuestieLoader:CreateModule("PreHookTupleTrigger")

            local values = {QuestieLoader._modules.PreHookTuple.Echo(nil, "middle", nil)}

            assert.are_same(3, select("#", QuestieLoader._modules.PreHookTuple.Echo(nil, "middle", nil)))
            assert.is_nil(values[1])
            assert.are_same("middle", values[2])
        end)

        it("wraps a module extended by a second file, which names it again", function()
            -- QuestieQuestPrivates.lua is the real shape of this: a later file imports a module and adds to
            -- it. Naming it is what marks it for another look, so the dirty set must not treat a module as
            -- finished once swept.
            GivenModule("PreHookExtended", {First = function() end})
            QuestieLoader:CreateModule("PreHookExtendedTrigger")
            assert.is_not_nil(TargetFor("PreHookExtended", "First"))

            QuestieLoader:ImportModule("PreHookExtended").Second = function() end
            QuestieLoader:CreateModule("PreHookExtendedSecondTrigger")

            assert.is_not_nil(TargetFor("PreHookExtended", "Second"))
        end)

        it("wraps functions a later file defines, not only what existed at load", function()
            GivenModule("PreHookLate", {Work = function() end})

            QuestieLoader:CreateModule("PreHookLateTrigger")

            assert.is_not_nil(TargetFor("PreHookLate", "Work"))
        end)

        it("never wraps its own wrapper, however many sweeps run", function()
            QuestieLoader:CreateModule("PreHookSweepTwo")
            QuestieLoader:CreateModule("PreHookSweepThree")

            local matches = 0
            for _, target in ipairs(PreHook.targets) do
                if target.moduleName == "PreHookAlpha" and target.functionName == "Work" then
                    matches = matches + 1
                end
            end
            assert.are_same(1, matches)
        end)
    end)

    describe("exclusions", function()
        it("leaves the profiler's own modules and the scheduler alone", function()
            local originals = {}
            for _, name in ipairs({"Profiler", "ProfilerUI", "ProfilerReport", "ThreadLib"}) do
                originals[name] = function() end
                GivenModule(name, {Work = originals[name]})
            end

            LoadPreHook(true)
            QuestieLoader:CreateModule("PreHookExclusionTrigger")

            for name, original in pairs(originals) do
                assert.are_equal(original, QuestieLoader._modules[name].Work,
                    name .. " must keep its real function")
            end
        end)

        it("leaves the low-level paths the profiler already refuses to measure", function()
            local originals = {}
            for _, name in ipairs({"QuestieStreamLib", "QuestieSerializer"}) do
                originals[name] = function() end
                GivenModule(name, {Work = originals[name]})
            end

            LoadPreHook(true)
            QuestieLoader:CreateModule("PreHookLowLevelTrigger")

            for name, original in pairs(originals) do
                assert.are_equal(original, QuestieLoader._modules[name].Work, name .. " must be excluded")
            end
        end)

        it("leaves QuestieDB's generated query primitives alone but wraps the rest of it", function()
            local query = function() end
            local ordinary = function() end
            GivenModule("QuestieDB", {QueryNPC = query, _QueryQuestSingle = query, IsDoable = ordinary})

            LoadPreHook(true)
            QuestieLoader:CreateModule("PreHookQueryTrigger")

            assert.are_equal(query, QuestieLoader._modules.QuestieDB.QueryNPC)
            assert.are_equal(query, QuestieLoader._modules.QuestieDB._QueryQuestSingle)
            assert.are_not_equal(ordinary, QuestieLoader._modules.QuestieDB.IsDoable)
        end)
    end)

    describe("profiler integration", function()
        it("measures a file-scope alias across stopped and restarted sessions", function()
            local clock = 0
            _G.GetTimePreciseSec = function() return clock / 1000 end
            local measuredModule = GivenModule("PreHookMeasured", {
                Work = function()
                    clock = clock + 2
                end,
            })
            LoadPreHook(true)
            QuestieLoader:CreateModule("PreHookMeasuredTrigger")
            local fileScopeAlias = measuredModule.Work
            local target = TargetFor("PreHookMeasured", "Work")
            assert.is_not_nil(target)
            local profiler = LoadProfiler()

            assert.is_true(profiler:Start(false))
            local firstSessionOverride = target.slot.Work
            assert.are_not_equal(target.original, firstSessionOverride)

            -- Questie.lua starts profiling while it loads; ADDON_LOADED ends the pre-hook sweep afterward.
            PreHook.Finish()
            assert.are_equal(target.wrapper, measuredModule.Work)

            fileScopeAlias()

            assert.are_same(1, profiler.hookCallCount["PreHookMeasured.Work"])
            assert.are_same(2, profiler.hookTimeCount["PreHookMeasured.Work"])
            assert.is_nil(profiler.hookCallCount["PreHookMeasured.Work [string #2]"])

            profiler:Stop()
            assert.are_equal(target.original, target.slot.Work)

            fileScopeAlias()

            assert.are_same(1, profiler.hookCallCount["PreHookMeasured.Work"])
            assert.are_same(2, profiler.hookTimeCount["PreHookMeasured.Work"])

            assert.is_true(profiler:Start(false))
            local secondSessionOverride = target.slot.Work
            assert.are_not_equal(target.original, secondSessionOverride)
            assert.are_not_equal(firstSessionOverride, secondSessionOverride)

            fileScopeAlias()

            assert.are_same(1, profiler.hookCallCount["PreHookMeasured.Work"])
            assert.are_same(2, profiler.hookTimeCount["PreHookMeasured.Work"])
        end)
    end)

    describe("agreement with the profiler's own exclusions", function()
        it("refuses everything QuestieProfiler refuses to measure", function()
            -- The two lists are separate because this file loads long before the profiler, so nothing can
            -- share them. This is the check that stops them drifting: a disallowed path the pre-hook would
            -- still wrap gets a permanent indirection on a slot whose whole reason for exclusion is that it
            -- runs thousands of times inside one measurement.
            LoadPreHook(true)
            local Profiler = LoadProfiler()

            local mismatches = Profiler.FindPreHookExclusionMismatches()

            assert.are_same({}, mismatches)
        end)

        it("names a disallowed path the pre-hook would wrap", function()
            -- Teeth: with the predicate stubbed to allow everything, every disallowed path must be reported.
            LoadPreHook(true)
            local Profiler = LoadProfiler()
            PreHook.IsExcluded = function() return false end

            local mismatches = Profiler.FindPreHookExclusionMismatches()

            assert.is_true(#mismatches > 0)
            local reported = {}
            for _, path in ipairs(mismatches) do reported[path] = true end
            assert.is_true(reported["QuestieStreamLib"])
            assert.is_true(reported["QuestieDB.QueryNPC"])
        end)
    end)

    describe("finishing", function()
        it("stops sweeping once addon load is over", function()
            GivenModule("PreHookBefore", {Work = function() end})
            LoadPreHook(true)
            QuestieLoader:CreateModule("PreHookFinishTrigger")

            PreHook.Finish()
            GivenModule("PreHookAfter", {Work = function() end})
            QuestieLoader:CreateModule("PreHookAfterTrigger")

            -- Anything defined after load cannot be captured by a file, so it is left to the ordinary hooks.
            assert.is_nil(TargetFor("PreHookAfter", "Work"))
        end)

        it("keeps everything it already installed", function()
            GivenModule("PreHookKept", {Work = function() return "kept" end})
            LoadPreHook(true)
            QuestieLoader:CreateModule("PreHookKeptTrigger")

            PreHook.Finish()

            assert.is_not_nil(TargetFor("PreHookKept", "Work"))
            assert.are_same("kept", QuestieLoader._modules.PreHookKept.Work())
        end)
    end)
end)
