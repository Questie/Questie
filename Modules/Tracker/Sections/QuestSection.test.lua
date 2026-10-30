dofile("setupTests.lua")

describe("QuestSection", function()
    ---@type QuestSection
    local QuestSection
    local TrackerLinePool, TrackerLayout, TrackerUtils, TrackerData, TrackerQuestTimers

    local texts, availableLines, drawnLines

    local function _FakeLine()
        local label = {
            SetText = function(_, text) texts[#texts + 1] = text end,
            GetUnboundedStringWidth = function() return 10 end,
            GetWidth = function() return 300 end,
            GetHeight = function() return 10 end,
        }
        setmetatable(label, {__index = function() return function() end end})
        local button = {}
        setmetatable(button, {__index = function() return function() end end})
        local line = {label = label, expandZone = button, expandQuest = button, playButton = button, questFocus = button}
        setmetatable(line, {__index = function() return function() end end})
        return line
    end

    local function _GetLine()
        if availableLines == 0 then
            return nil
        end
        availableLines = availableLines - 1
        local line = _FakeLine()
        drawnLines[#drawnLines + 1] = line
        return line
    end

    local function _Quest(id, complete, objectives)
        return {
            Id = id,
            Objectives = objectives or {},
            IsComplete = function() return complete end,
        }
    end

    local function _Details(quests)
        local sortedQuestIds, questDetails = {}, {}
        for _, entry in ipairs(quests) do
            sortedQuestIds[#sortedQuestIds + 1] = entry.quest.Id
            questDetails[entry.quest.Id] = {quest = entry.quest, zoneName = entry.zoneName}
        end
        return sortedQuestIds, questDetails
    end

    before_each(function()
        texts = {}
        drawnLines = {}
        availableLines = 100

        Questie.db.char.collapsedZones = {}
        Questie.db.char.collapsedQuests = {}
        Questie.db.char.minAllQuestsInZone = {}
        Questie.db.char.AutoUntrackedQuests = {}
        Questie.db.char.TrackedQuests = {}
        Questie.db.profile.autoTrackQuests = true
        Questie.db.profile.trackerShowCompleteQuests = true
        Questie.db.profile.hideCompletedQuestObjectives = false
        Questie.db.profile.collapseCompletedQuests = false
        Questie.db.profile.hideBlizzardCompletionText = false
        Questie.db.profile.trackerColorObjectives = "white"
        Questie.db.profile.trackerQuestPadding = 2

        Questie.Colorize = function(_, text) return text end

        TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
        TrackerLayout.GetMargins = function() return {left = 14, right = 30, quest = 20, objective = 30, itemButtonSize = 24} end
        TrackerLayout.UpdateWidth = function() end
        TrackerLayout.GetBaseFrame = function() return {} end
        TrackerLayout.GetBaseFrameWidth = function() return 400 end
        TrackerLayout.TrackLineWidth = function() end
        TrackerLayout.UpdateLineWidth = function() end

        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        TrackerLinePool.GetZoneLine = spy.new(_GetLine)
        TrackerLinePool.GetQuestTitleLine = spy.new(_GetLine)
        TrackerLinePool.GetQuestObjectiveLine = spy.new(_GetLine)
        TrackerLinePool.GetLastLine = _FakeLine

        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.GetCompletionText = function() return nil end
        TrackerUtils.AddQuestItemButtons = spy.new(function() return true end)

        TrackerData = QuestieLoader:ImportModule("TrackerData")
        TrackerData.GetColoredQuestName = function(quest) return "Quest " .. quest.Id end
        TrackerData.GetObjectiveText = function(objective) return objective.Description end

        TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
        TrackerQuestTimers.UpdateAndGetRemainingTime = function() end

        dofile("Localization/l10n.lua")
        dofile("Modules/Tracker/Sections/QuestSection.lua")
        QuestSection = QuestieLoader:ImportModule("QuestSection")
    end)

    it("should draw the zone header, the quest and its objectives", function()
        local quest = _Quest(1, 0, {{Description = "Wolf slain: 1/5", Completed = false}})

        QuestSection.Draw(_Details({{quest = quest, zoneName = "Elwynn Forest"}}))

        assert.are_same({"|cFFC0C0C0Elwynn Forest|r", "Quest 1", "Wolf slain: 1/5"}, texts)
        assert.spy(TrackerUtils.AddQuestItemButtons).was.called(1)
    end)

    it("should indent the objectives of a quest with a secondary item button", function()
        local withButtons = _Quest(1, 0, {{Description = "Wolf slain: 1/5", Completed = false}})
        local withoutButtons = _Quest(2, 0, {{Description = "Bear slain: 1/5", Completed = false}})
        TrackerUtils.AddQuestItemButtons = spy.new(function(quest, _, _, _, _, _, rePositionLine)
            if quest.Id == 1 then
                rePositionLine(1)
            end
            return true
        end)

        QuestSection.Draw(_Details({
            {quest = withButtons, zoneName = "Elwynn Forest"},
            {quest = withoutButtons, zoneName = "Elwynn Forest"},
        }))

        assert.spy(TrackerLinePool.GetQuestObjectiveLine).was.called_with(withButtons, withButtons.Objectives[1], 54)
        assert.spy(TrackerLinePool.GetQuestObjectiveLine).was.called_with(withoutButtons, withoutButtons.Objectives[1], 30)
        assert.is_true(drawnLines[3].questHasSecondaryQIB)
        assert.is_false(drawnLines[5].questHasSecondaryQIB)
    end)

    it("should draw one zone header per zone", function()
        local first = _Quest(1, 0)
        local second = _Quest(2, 0)
        local third = _Quest(3, 0)

        QuestSection.Draw(_Details({
            {quest = first, zoneName = "Elwynn Forest"},
            {quest = second, zoneName = "Elwynn Forest"},
            {quest = third, zoneName = "Westfall"},
        }))

        assert.spy(TrackerLinePool.GetZoneLine).was.called(2)
        assert.spy(TrackerLinePool.GetZoneLine).was.called_with("Elwynn Forest")
        assert.spy(TrackerLinePool.GetZoneLine).was.called_with("Westfall")
    end)

    it("should skip quests that are not tracked", function()
        Questie.db.char.AutoUntrackedQuests = {[1] = true}

        QuestSection.Draw(_Details({{quest = _Quest(1, 0), zoneName = "Elwynn Forest"}}))

        assert.are_same({}, texts)
    end)

    it("should only draw the zone header when the zone is collapsed", function()
        Questie.db.char.collapsedZones = {["Elwynn Forest"] = true}

        QuestSection.Draw(_Details({{quest = _Quest(1, 0), zoneName = "Elwynn Forest"}}))

        assert.are_same({"|cFFC0C0C0Elwynn Forest +|r"}, texts)
    end)

    it("should hide completed objectives when configured", function()
        Questie.db.profile.hideCompletedQuestObjectives = true
        local quest = _Quest(1, 0, {
            {Description = "Wolf slain: 5/5", Completed = true},
            {Description = "Bear slain: 0/5", Completed = false},
        })

        QuestSection.Draw(_Details({{quest = quest, zoneName = "Elwynn Forest"}}))

        assert.are_same({"|cFFC0C0C0Elwynn Forest|r", "Quest 1", "Bear slain: 0/5"}, texts)
    end)

    it("should show complete quests as complete", function()
        QuestSection.Draw(_Details({{quest = _Quest(1, 1), zoneName = "Elwynn Forest"}}))

        assert.is_truthy(texts[3]:find("Quest Complete!", 1, true))
    end)

    it("should stop drawing when the line pool is exhausted", function()
        availableLines = 0

        QuestSection.Draw(_Details({{quest = _Quest(1, 0), zoneName = "Elwynn Forest"}}))

        assert.are_same({}, texts)
        assert.spy(TrackerLinePool.GetQuestTitleLine).was.not_called()
    end)

    it("should stop drawing when the item button pool is exhausted", function()
        TrackerUtils.AddQuestItemButtons = spy.new(function() return false end)

        QuestSection.Draw(_Details({
            {quest = _Quest(1, 0), zoneName = "Elwynn Forest"},
            {quest = _Quest(2, 0), zoneName = "Elwynn Forest"},
        }))

        assert.spy(TrackerLinePool.GetQuestTitleLine).was.called(1)
    end)
end)
