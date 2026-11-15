dofile("setupTests.lua")

describe("ScenarioSection", function()
    ---@type ScenarioSection
    local ScenarioSection
    local TrackerLinePool, TrackerLayout, ChallengeModeTimer

    local texts, criteria, availableLines, originals

    local function _FakeLine()
        local label = {
            SetText = function(_, text) texts[#texts + 1] = text end,
            GetUnboundedStringWidth = function() return 10 end,
            GetWidth = function() return 10 end,
            GetHeight = function() return 10 end,
        }
        setmetatable(label, {__index = function() return function() end end})
        local button = {}
        setmetatable(button, {__index = function() return function() end end})
        local line = {label = label, expandZone = button, expandQuest = button, criteriaMark = button, playButton = button}
        line.SetScenarioCriteria = spy.new(function() end)
        setmetatable(line, {__index = function() return function() end end})
        return line
    end

    before_each(function()
        texts = {}
        criteria = {}
        availableLines = 100
        originals = {
            GetInstanceInfo = _G.GetInstanceInfo,
            C_Scenario = _G.C_Scenario,
            C_ScenarioInfo = _G.C_ScenarioInfo,
        }
        _G.GetInstanceInfo = function() return "Temple of the Jade Serpent" end
        _G.C_Scenario = {GetStepInfo = function() return nil, nil, #criteria end}
        _G.C_ScenarioInfo = {GetCriteriaInfo = function(index) return criteria[index] end}
        Questie.db.profile.trackerColorObjectives = "white"
        Questie.db.profile.trackerFontSizeZone = 12
        Questie.db.profile.trackerFontSizeQuest = 12
        Questie.db.profile.trackerFontSizeObjective = 12

        TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
        TrackerLayout.GetBaseFrameWidth = function() return 200 end
        TrackerLayout.TrackLineWidth = function() end
        TrackerLayout.GetLineWidth = function() return 10 end
        TrackerLayout.UpdateWidth = spy.new(function() end)
        TrackerLayout.UpdateHeight = spy.new(function() end)

        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        TrackerLinePool.GetNextLine = spy.new(function()
            if availableLines == 0 then
                return nil
            end
            availableLines = availableLines - 1
            return _FakeLine()
        end)

        ChallengeModeTimer = QuestieLoader:ImportModule("ChallengeModeTimer")
        ChallengeModeTimer.GetTimerString = function() return "12:34" end
        ChallengeModeTimer.SetTimerLabel = spy.new(function() end)

        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Tracker/Sections/ScenarioSection.lua")
        ScenarioSection = QuestieLoader:ImportModule("ScenarioSection")
    end)

    after_each(function()
        _G.GetInstanceInfo = originals.GetInstanceInfo
        _G.C_Scenario = originals.C_Scenario
        _G.C_ScenarioInfo = originals.C_ScenarioInfo
    end)

    it("should draw the dungeon name and the scenario criteria", function()
        criteria = {{criteriaID = 1, description = "Defeat the boss", quantity = 0, totalQuantity = 1, completed = false}}

        ScenarioSection.Draw(false)

        assert.are_same("|cFFC0C0C0Temple of the Jade Serpent|r", texts[1])
        assert.is_truthy(texts[2]:find("Defeat the boss: 0/1", 1, true))
        assert.are_same(2, #texts)
        assert.spy(ChallengeModeTimer.SetTimerLabel).was.not_called()
        assert.spy(TrackerLayout.UpdateWidth).was.called_with(10)
        assert.spy(TrackerLayout.UpdateHeight).was.called(1)
    end)

    it("should draw the Challenge Mode header and timer", function()
        criteria = {{criteriaID = 1, description = "Enemies", quantity = 5, totalQuantity = 10, completed = false}}

        ScenarioSection.Draw(true)

        assert.are_same("|cFFC0C0C0Temple of the Jade Serpent (Challenge Mode)|r", texts[1])
        assert.are_same("12:34", texts[2])
        assert.is_truthy(texts[3]:find("Enemies: 5/10", 1, true))
        assert.spy(ChallengeModeTimer.SetTimerLabel).was.called(1)
    end)

    it("should stop drawing when the line pool is exhausted", function()
        criteria = {
            {criteriaID = 1, description = "First", quantity = 0, totalQuantity = 1, completed = false},
            {criteriaID = 2, description = "Second", quantity = 0, totalQuantity = 1, completed = false},
        }
        availableLines = 2

        ScenarioSection.Draw(false)

        assert.are_same(2, #texts)
        assert.spy(TrackerLayout.UpdateWidth).was.called(1)
    end)

    it("should draw nothing when no line is available", function()
        availableLines = 0

        ScenarioSection.Draw(true)

        assert.are_same({}, texts)
        assert.spy(TrackerLayout.UpdateWidth).was.not_called()
    end)
end)
