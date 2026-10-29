dofile("setupTests.lua")
local match = require("luassert.match")

describe("AchievementSection", function()
    ---@type AchievementSection
    local AchievementSection
    local TrackerLinePool, TrackerLayout, TrackerAchievements

    local texts, achievements, availableLines, objectiveLines, originals

    local function _FakeLine()
        local label = {
            SetText = function(_, text) texts[#texts + 1] = text end,
            GetUnboundedStringWidth = function() return 10 end,
            GetWidth = function() return 300 end,
            GetHeight = function() return 10 end,
        }
        setmetatable(label, {__index = function() return function() end end})
        local button = {mode = nil}
        setmetatable(button, {__index = function() return function() end end})
        local criteriaMark = {mode = true, SetCriteria = spy.new(function() end), Show = function() end}
        local line = {label = label, expandZone = button, expandQuest = button, criteriaMark = criteriaMark}
        setmetatable(line, {__index = function() return function() end end})
        return line
    end

    local function _GetLine()
        if availableLines == 0 then
            return nil
        end
        availableLines = availableLines - 1
        return _FakeLine()
    end

    local function _GetObjectiveLine(target)
        local line = _GetLine()
        objectiveLines[#objectiveLines + 1] = {target = target, line = line}
        return line
    end

    local function _Achievement(id, criteria)
        return {Id = id, Name = "Achievement " .. id, Description = "Description " .. id, Criteria = criteria or {}}
    end

    local function _Criteria(text, completed)
        return {Text = text, Completed = completed or false, Collected = completed and 1 or 0, Needed = 1, IsDescription = false}
    end

    before_each(function()
        texts = {}
        achievements = {}
        objectiveLines = {}
        availableLines = 100
        originals = {GetNumTrackedAchievements = _G.GetNumTrackedAchievements}
        _G.GetNumTrackedAchievements = function() return 1 end

        Questie.db.char.collapsedZones = {}
        Questie.db.char.collapsedQuests = {}
        Questie.db.char.minAllQuestsInZone = {}
        Questie.db.profile.trackerQuestPadding = 2
        Questie.db.profile.trackerColorObjectives = "white"
        Questie.db.profile.hideCompletedAchieveObjectives = false
        Questie.db.profile.enableTooltipsQuestID = false

        TrackerAchievements = QuestieLoader:ImportModule("TrackerAchievements")
        TrackerAchievements.GetAchievements = spy.new(function() return achievements end)

        TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
        TrackerLayout.GetMargins = function() return {left = 14, right = 30, quest = 20, objective = 30, itemButtonSize = 24} end
        TrackerLayout.UpdateWidth = function() end
        TrackerLayout.GetBaseFrameWidth = function() return 400 end
        TrackerLayout.TrackLineWidth = function() end
        TrackerLayout.GetLineWidth = function() return 1000 end
        TrackerLayout.UpdateLineWidth = function() end

        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        TrackerLinePool.GetZoneLine = spy.new(_GetLine)
        TrackerLinePool.GetAchievementTitleLine = spy.new(_GetLine)
        TrackerLinePool.GetAchievementObjectiveLine = spy.new(_GetObjectiveLine)
        TrackerLinePool.GetLastLine = _FakeLine

        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Tracker/AchievementTracking.lua")
        dofile("Modules/Tracker/Sections/AchievementSection.lua")
        AchievementSection = QuestieLoader:ImportModule("AchievementSection")
    end)

    after_each(function()
        _G.GetNumTrackedAchievements = originals.GetNumTrackedAchievements
    end)

    it("should read the tracked achievements", function()
        AchievementSection.Draw({[1] = true, [2] = false})

        assert.spy(TrackerAchievements.GetAchievements).was.called_with({1})
    end)

    it("should draw nothing when no achievement is shown", function()
        AchievementSection.Draw({})

        assert.spy(TrackerLinePool.GetZoneLine).was.not_called()
    end)

    it("should draw the header, the achievement and its criteria", function()
        achievements = {_Achievement(1, {_Criteria("Elwynn Forest", true), _Criteria("Westfall")})}

        AchievementSection.Draw({[1] = true})

        assert.spy(TrackerLinePool.GetZoneLine).was.called_with("Achievements")
        assert.are_same("|cFFC0C0C0Achievements: 1/10|r", texts[1])
        assert.are_same("|cFFFFFF00Achievement 1|r", texts[2])
        assert.is_truthy(texts[3]:find("Elwynn Forest", 1, true))
        assert.is_truthy(texts[4]:find("Westfall", 1, true))
        assert.are_same(4, #texts)
    end)

    it("should draw the header once for several achievements", function()
        achievements = {_Achievement(1), _Achievement(2)}

        AchievementSection.Draw({[1] = true, [2] = true})

        assert.spy(TrackerLinePool.GetZoneLine).was.called(1)
        assert.spy(TrackerLinePool.GetAchievementTitleLine).was.called(2)
    end)

    it("should draw the id in the title when quest ids are shown", function()
        Questie.db.profile.enableTooltipsQuestID = true
        achievements = {_Achievement(1)}

        AchievementSection.Draw({[1] = true})

        assert.are_same("|cFFFFFF00Achievement 1 (1)|r", texts[2])
    end)

    it("should draw criteria with the default objective margin", function()
        achievements = {_Achievement(1, {_Criteria("Westfall")})}

        AchievementSection.Draw({[1] = true})

        assert.spy(TrackerLinePool.GetAchievementTitleLine).was.called_with(match._, 20)
        assert.spy(TrackerLinePool.GetAchievementObjectiveLine).was.called_with(match._, 30)
    end)

    it("should draw the description of an achievement without criteria", function()
        achievements = {_Achievement(1, {{Text = "Reach level 10", Completed = false, Collected = 0, Needed = 1, IsDescription = true}})}

        AchievementSection.Draw({[1] = true})

        assert.is_truthy(texts[3]:find("Reach level 10", 1, true))
        assert.are_same(3, #texts)
    end)

    it("should set the criteria mark of single criteria", function()
        achievements = {_Achievement(1, {_Criteria("Elwynn Forest", true)})}

        AchievementSection.Draw({[1] = true})

        assert.spy(objectiveLines[1].line.criteriaMark.SetCriteria).was.called_with(match._, true)
    end)

    it("should not set the criteria mark when completed criteria are hidden", function()
        Questie.db.profile.hideCompletedAchieveObjectives = true
        achievements = {_Achievement(1, {_Criteria("Westfall")})}

        AchievementSection.Draw({[1] = true})

        assert.spy(objectiveLines[1].line.criteriaMark.SetCriteria).was.not_called()
    end)

    it("should not set the criteria mark for a description", function()
        achievements = {_Achievement(1, {{Text = "Reach level 10", Completed = false, Collected = 0, Needed = 1, IsDescription = true}})}

        AchievementSection.Draw({[1] = true})

        assert.spy(objectiveLines[1].line.criteriaMark.SetCriteria).was.not_called()
    end)

    it("should draw the progress of unfinished criteria", function()
        achievements = {_Achievement(1, {
            {Text = "Fish caught", Completed = false, Collected = 3, Needed = 10, Progress = "3/10", IsDescription = false},
        })}

        AchievementSection.Draw({[1] = true})

        assert.is_truthy(texts[3]:find("Fish caught: 3/10", 1, true))
    end)

    it("should target the linked achievement of a criteria", function()
        local criteria = _Criteria("Darnassus")
        criteria.LinkedAchievementId = 2
        achievements = {_Achievement(1, {criteria, _Criteria("Westfall")})}

        AchievementSection.Draw({[1] = true})

        assert.are_same({Id = 2}, objectiveLines[1].target)
        assert.are.equal(achievements[1], objectiveLines[2].target)
    end)

    it("should only draw the header when it is collapsed", function()
        Questie.db.char.collapsedZones = {Achievements = true}
        achievements = {_Achievement(1)}

        AchievementSection.Draw({[1] = true})

        assert.are_same({"|cFFC0C0C0Achievements +|r"}, texts)
    end)

    it("should not draw the criteria of a collapsed achievement", function()
        Questie.db.char.collapsedQuests = {[1] = true}
        achievements = {_Achievement(1, {_Criteria("Westfall")})}

        AchievementSection.Draw({[1] = true})

        assert.are_same(2, #texts)
        assert.spy(TrackerLinePool.GetAchievementObjectiveLine).was.not_called()
    end)

    it("should stop drawing when the line pool is exhausted", function()
        availableLines = 0
        achievements = {_Achievement(1)}

        AchievementSection.Draw({[1] = true})

        assert.are_same({}, texts)
        assert.spy(TrackerLinePool.GetAchievementTitleLine).was.not_called()
    end)
end)
