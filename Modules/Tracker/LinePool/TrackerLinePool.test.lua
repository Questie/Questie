dofile("setupTests.lua")

describe("TrackerLinePool", function()

    ---@type TrackerLinePool
    local TrackerLinePool
    ---@type QuestieLib
    local QuestieLib

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")

        dofile("Modules/Tracker/LinePool/TrackerLinePool.lua")
        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
    end)

    describe("SetAllPlayButtonAlpha", function()
        local originalVoiceOver
        local originalIsShiftKeyDown
        local originalGetMaxNumQuestsCanAccept
        local originalIsVoiceOverLoaded
        local originalNewLine
        local TrackerUtils
        local TrackerLine

        before_each(function()
            originalVoiceOver = _G.VoiceOver
            originalIsShiftKeyDown = _G.IsShiftKeyDown
            originalGetMaxNumQuestsCanAccept = C_QuestLog.GetMaxNumQuestsCanAccept
            TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
            TrackerLine = QuestieLoader:ImportModule("TrackerLine")
            originalIsVoiceOverLoaded = TrackerUtils.IsVoiceOverLoaded
            originalNewLine = TrackerLine.New

            TrackerUtils.IsVoiceOverLoaded = function() return true end
            _G.IsShiftKeyDown = function() return true end
            C_QuestLog.GetMaxNumQuestsCanAccept = function() return 0 end
            TrackerLine.New = function()
                local button = CreateFrame("Button")
                button.SetFrameLevel = function() end
                return {playButton = button}
            end
            _G.VoiceOver = {
                QuestOverlayUI = {questPlayButtons = {}},
                DataModules = {PrepareSound = spy.new(function() return false end)},
            }

            local thread = coroutine.create(function() TrackerLinePool.Initialize({}) end)
            while coroutine.status(thread) ~= "dead" do
                assert.is_true(coroutine.resume(thread))
            end
        end)

        after_each(function()
            _G.VoiceOver = originalVoiceOver
            _G.IsShiftKeyDown = originalIsShiftKeyDown
            C_QuestLog.GetMaxNumQuestsCanAccept = originalGetMaxNumQuestsCanAccept
            TrackerUtils.IsVoiceOverLoaded = originalIsVoiceOverLoaded
            TrackerLine.New = originalNewLine
            CreateFrame.resetMockedFrames()
        end)

        it("should only request audio for lines with a quest play button", function()
            TrackerLinePool.GetNextLine() -- Zone header with no quest ID.
            local questLine = TrackerLinePool.GetNextLine()
            questLine.playButton.mode = 123

            TrackerLinePool.SetAllPlayButtonAlpha(1)

            assert.spy(VoiceOver.DataModules.PrepareSound).was.called(1)
            assert.spy(VoiceOver.DataModules.PrepareSound).was.called_with(VoiceOver.DataModules, {event = 1, questID = 123})
        end)

        it("should refresh audio availability after deferred packs load without rebuilding lines", function()
            local line = TrackerLinePool.GetNextLine()
            line.playButton.mode = 123

            TrackerLinePool.SetAllPlayButtonAlpha(1)
            assert.are_equal(0.33, line.playButton:GetAlpha())

            VoiceOver.DataModules.PrepareSound = function() return true end
            TrackerLinePool.SetAllPlayButtonAlpha(1)
            assert.are_equal(1, line.playButton:GetAlpha())
        end)
    end)

    describe("UpdateQuestLines", function()
        it("should set new objectives text", function()
            QuestieLib.GetRGBForObjective = function() return "|cFFEEEEEE" end
            local firstLine = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Collected = 0,
                    Needed = 1,
                    Description = "Test Objective",
                }
            }
            local secondLine = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Collected = 5,
                    Needed = 10,
                    Description = "Another Test Objective",
                }
            }

            TrackerLinePool.AddQuestLine(123, firstLine)
            TrackerLinePool.AddQuestLine(123, secondLine)

            TrackerLinePool.UpdateQuestLines(123)

            assert.spy(firstLine.label.SetText).was.called_with(_, "|cFFEEEEEETest Objective: 0/1")
            assert.spy(secondLine.label.SetText).was.called_with(_, "|cFFEEEEEEAnother Test Objective: 5/10")
        end)

        it("should do nothing when questId was not added", function()
            local line = {
                label = {SetText = spy.new(function() end)},
                Objective = {
                    Collected = 0,
                    Needed = 1,
                    Description = "Test Objective",
                }
            }

            TrackerLinePool.AddQuestLine(123, line)

            TrackerLinePool.UpdateQuestLines(456)

            assert.spy(line.label.SetText).was.not_called()
        end)
    end)
end)
