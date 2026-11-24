dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyThread", function()
    ---@type JourneyThread
    local JourneyThread
    local ui
    local originalQuestie, errors

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, errors = _G.Questie, {}
        _G.Questie = {Error = function(message) table.insert(errors, message) end}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        dofile("Modules/Journey/JourneyThread.lua")
        JourneyThread = QuestieLoader:ImportModule("JourneyThread")
    end)

    after_each(function()
        _G.Questie = originalQuestie
        ui.Restore()
    end)

    it("should spread slow work over several frames", function()
        ui.clockStep = 0.003
        local done = 0
        JourneyThread.Start("JourneyTest", function()
            for _ = 1, 20 do
                JourneyThread.YieldIfNeeded()
                done = done + 1
            end
        end)

        ui.RunFrame()
        assert.is_true(done > 0 and done < 10)

        ui.RunUntilIdle()
        assert.are.equal(20, done)
    end)

    it("should be possible to stop", function()
        local hasRun = false
        local timer = JourneyThread.Start("JourneyTest", function() hasRun = true end)

        timer:Cancel()
        ui.RunUntilIdle()

        assert.is_false(hasRun)
    end)

    it("should say what went wrong where", function()
        JourneyThread.Start("JourneyTest", function() error("no such quest") end)

        ui.RunUntilIdle()

        assert.are_same({"Error in JourneyTest:"}, errors)
    end)
end)
