dofile("setupTests.lua")

describe("AchievementSection", function()
    ---@type AchievementSection
    local AchievementSection
    local TrackerLinePool, TrackerLayout

    local texts, achievements, availableLines, originals

    local function _FakeLine()
        local label = {
            text = nil,
            SetText = function(self, text)
                self.text = text
                texts[#texts + 1] = text
            end,
            GetUnboundedStringWidth = function() return 10 end,
            GetWidth = function() return 300 end,
            GetHeight = function() return 10 end,
        }
        setmetatable(label, {__index = function() return function() end end})
        local button = {mode = nil}
        setmetatable(button, {__index = function() return function() end end})
        local line = {label = label, expandZone = button, expandQuest = button, criteriaMark = button}
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

    before_each(function()
        texts = {}
        achievements = {}
        availableLines = 100
        originals = {
            GetAchievementInfo = _G.GetAchievementInfo,
            GetAchievementNumCriteria = _G.GetAchievementNumCriteria,
            GetAchievementCriteriaInfo = _G.GetAchievementCriteriaInfo,
            GetNumTrackedAchievements = _G.GetNumTrackedAchievements,
        }
        _G.GetAchievementInfo = function(id)
            local achievement = achievements[id]
            if not achievement then
                return nil
            end
            return id, achievement.name, nil, nil, nil, nil, nil, achievement.description, nil, nil, nil, nil, achievement.complete
        end
        _G.GetAchievementNumCriteria = function(id) return #achievements[id].criteria end
        _G.GetAchievementCriteriaInfo = function(id, index)
            local criteria = achievements[id].criteria[index]
            return criteria.text, nil, criteria.completed, criteria.progress, criteria.needed, nil, nil, 0, criteria.progress .. "/" .. criteria.needed
        end
        _G.GetNumTrackedAchievements = function() return 1 end

        Questie.db.char.collapsedZones = {}
        Questie.db.char.collapsedQuests = {}
        Questie.db.char.minAllQuestsInZone = {}
        Questie.db.profile.trackerQuestPadding = 2
        Questie.db.profile.trackerColorObjectives = "white"
        Questie.db.profile.hideCompletedAchieveObjectives = false
        Questie.db.profile.enableTooltipsQuestID = false

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
        TrackerLinePool.GetAchievementObjectiveLine = spy.new(_GetLine)
        TrackerLinePool.GetLastLine = _FakeLine

        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Tracker/Sections/AchievementSection.lua")
        AchievementSection = QuestieLoader:ImportModule("AchievementSection")
    end)

    after_each(function()
        for name, value in pairs(originals) do
            _G[name] = value
        end
    end)

    it("should draw nothing when no achievement is tracked", function()
        AchievementSection.Draw({})

        assert.spy(TrackerLinePool.GetZoneLine).was.not_called()
    end)

    it("should draw the header, the achievement and its criteria", function()
        achievements[1] = {name = "Explorer", description = "Explore.", criteria = {
            {text = "Elwynn Forest", completed = true, progress = 1, needed = 1},
            {text = "Westfall", completed = false, progress = 0, needed = 1},
        }}

        AchievementSection.Draw({[1] = true})

        assert.spy(TrackerLinePool.GetZoneLine).was.called_with("Achievements")
        assert.are_same("|cFFC0C0C0Achievements: 1/10|r", texts[1])
        assert.are_same("|cFFFFFF00Explorer|r", texts[2])
        assert.is_truthy(texts[3]:find("Elwynn Forest", 1, true))
        assert.is_truthy(texts[4]:find("Westfall", 1, true))
        assert.are_same(4, #texts)
    end)

    it("should hide completed criteria when configured", function()
        Questie.db.profile.hideCompletedAchieveObjectives = true
        achievements[1] = {name = "Explorer", description = "Explore.", criteria = {
            {text = "Elwynn Forest", completed = true, progress = 1, needed = 1},
            {text = "Westfall", completed = false, progress = 0, needed = 1},
        }}

        AchievementSection.Draw({[1] = true})

        assert.are_same(3, #texts)
        assert.is_truthy(texts[3]:find("Westfall", 1, true))
    end)

    it("should show the description of an achievement without criteria", function()
        achievements[1] = {name = "Level 10", description = "Reach level 10.", criteria = {}}

        AchievementSection.Draw({[1] = true})

        assert.is_truthy(texts[3]:find("Reach level 10", 1, true))
        assert.is_falsy(texts[3]:find("10.", 1, true))
    end)

    it("should show multi-quantity criteria with their progress", function()
        achievements[1] = {name = "Fisher", description = "Fish.", criteria = {
            {text = "Fish caught", completed = false, progress = 3, needed = 10},
        }}

        AchievementSection.Draw({[1] = true})

        assert.is_truthy(texts[3]:find("Fish caught: 3/10", 1, true))
    end)

    it("should skip completed achievements", function()
        achievements[1] = {name = "Done", description = "Done.", complete = true, criteria = {}}

        AchievementSection.Draw({[1] = true})

        assert.spy(TrackerLinePool.GetZoneLine).was.not_called()
    end)

    it("should only draw the header when it is collapsed", function()
        Questie.db.char.collapsedZones = {Achievements = true}
        achievements[1] = {name = "Explorer", description = "Explore.", criteria = {}}

        AchievementSection.Draw({[1] = true})

        assert.are_same({"|cFFC0C0C0Achievements +|r"}, texts)
    end)

    it("should not draw the criteria of a collapsed achievement", function()
        Questie.db.char.collapsedQuests = {[1] = true}
        achievements[1] = {name = "Explorer", description = "Explore.", criteria = {
            {text = "Westfall", completed = false, progress = 0, needed = 1},
        }}

        AchievementSection.Draw({[1] = true})

        assert.are_same(2, #texts)
        assert.spy(TrackerLinePool.GetAchievementObjectiveLine).was.not_called()
    end)

    it("should stop drawing when the line pool is exhausted", function()
        availableLines = 0
        achievements[1] = {name = "Explorer", description = "Explore.", criteria = {}}

        AchievementSection.Draw({[1] = true})

        assert.are_same({}, texts)
        assert.spy(TrackerLinePool.GetAchievementTitleLine).was.not_called()
    end)
end)
