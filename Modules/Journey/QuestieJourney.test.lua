dofile("setupTests.lua")

describe("QuestieJourney", function()
    ---@type QuestieJourney
    local QuestieJourney
    local _QuestieJourney
    ---@type CompletedQuests
    local CompletedQuests
    local originals

    before_each(function()
        originals = {Questie = _G.Questie, LibStub = _G.LibStub, PlaySound = _G.PlaySound, frame = _G.QuestieJourneyFrame}
        _G.Questie = {started = true, db = {char = {}}}
        _G.LibStub = function() return {} end
        _G.PlaySound = function() end

        CompletedQuests = QuestieLoader:ImportModule("CompletedQuests")
        CompletedQuests.Update = spy.new(function() end)

        dofile("Localization/l10n.lua")
        dofile("Modules/Journey/QuestieJourney.lua")
        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        _QuestieJourney = QuestieJourney.private
        _QuestieJourney.HandleTabChange = spy.new(function() end)
        _G.QuestieJourneyFrame = {Show = function() end, Hide = function() end}
    end)

    after_each(function()
        _G.Questie, _G.LibStub, _G.PlaySound, _G.QuestieJourneyFrame = originals.Questie, originals.LibStub, originals.PlaySound, originals.frame
    end)

    describe("ToggleJourneyWindow", function()
        it("should look for quests the game completed before it draws the window", function()
            local wasUpdatedBeforeDrawing
            _QuestieJourney.HandleTabChange = function()
                wasUpdatedBeforeDrawing = #CompletedQuests.Update.calls == 1
            end

            QuestieJourney:ToggleJourneyWindow()

            assert.is_true(wasUpdatedBeforeDrawing)
        end)

        it("should not look for them when it closes the window", function()
            QuestieJourney:ToggleJourneyWindow()
            QuestieJourney:ToggleJourneyWindow()

            assert.spy(CompletedQuests.Update).was.called(1)
        end)
    end)
end)
