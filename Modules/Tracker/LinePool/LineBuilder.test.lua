dofile("setupTests.lua")
local match = require("luassert.match")

describe("LineBuilder", function()
    ---@type LineBuilder
    local LineBuilder
    local TrackerLinePool, TrackerLayout

    local nextLine, trackedWidths, updatedWidths

    local function _Button()
        return {
            SetMode = spy.new(function() end),
            Hide = spy.new(function() end),
            Show = spy.new(function() end),
            ClearAllPoints = spy.new(function() end),
            SetPoint = spy.new(function() end),
            SetWidth = spy.new(function() end),
            SetHeight = spy.new(function() end),
            SetAlpha = spy.new(function() end),
            SetCriteria = spy.new(function() end),
        }
    end

    local function _Line()
        local label = {
            SetText = spy.new(function() end),
            ClearAllPoints = spy.new(function() end),
            SetPoint = spy.new(function() end),
            SetWidth = spy.new(function() end),
            Show = spy.new(function() end),
            GetUnboundedStringWidth = function() return 100 end,
            GetWidth = function() return 250 end,
            GetHeight = function() return 12 end,
        }
        return {
            label = label,
            expandZone = _Button(),
            expandQuest = _Button(),
            criteriaMark = _Button(),
            playButton = _Button(),
            SetMode = spy.new(function() end),
            SetZone = spy.new(function() end),
            SetOnClick = spy.new(function() end),
            SetQuest = spy.new(function() end),
            SetRecipe = spy.new(function() end),
            SetObjective = spy.new(function() end),
            SetWidth = spy.new(function() end),
            SetHeight = spy.new(function() end),
            Show = spy.new(function() end),
        }
    end

    before_each(function()
        nextLine = _Line()
        trackedWidths = {}
        updatedWidths = {}

        Questie.db.char.collapsedZones = {}
        Questie.db.char.collapsedQuests = {}
        Questie.db.char.minAllQuestsInZone = {}
        Questie.db.profile.trackerQuestPadding = 2

        TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
        TrackerLayout.GetMargins = function() return {left = 14, right = 30, quest = 20, objective = 30, itemButtonSize = 24} end
        TrackerLayout.GetBaseFrameWidth = function() return 400 end
        TrackerLayout.UpdateWidth = function(width) updatedWidths[#updatedWidths + 1] = width end
        TrackerLayout.TrackLineWidth = function(width) trackedWidths[#trackedWidths + 1] = width end
        TrackerLayout.UpdateLineWidth = spy.new(function() end)

        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        TrackerLinePool.GetNextLine = spy.new(function() return nextLine end)

        dofile("Modules/Tracker/LinePool/LineBuilder.lua")
        LineBuilder = QuestieLoader:ImportModule("LineBuilder")
    end)

    describe("AddHeader", function()
        it("should return nil when the line pool is exhausted", function()
            TrackerLinePool.GetNextLine = function() return nil end

            local line, collapsed = LineBuilder.AddHeader({key = "Elwynn Forest", text = "Elwynn Forest"})

            assert.is_nil(line)
            assert.is_false(collapsed)
        end)

        it("should set up the zone line", function()
            local line, collapsed = LineBuilder.AddHeader({key = "Elwynn Forest", text = "Elwynn Forest"})

            assert.are.equal(nextLine, line)
            assert.is_false(collapsed)
            assert.spy(line.SetMode).was.called_with(line, "zone")
            assert.spy(line.SetZone).was.called_with(line, "Elwynn Forest")
            assert.spy(line.expandQuest.Hide).was.called()
            assert.spy(line.criteriaMark.Hide).was.called()
            assert.spy(line.playButton.Hide).was.called()
            assert.spy(line.expandZone.SetMode).was.called_with(line.expandZone, 1)
            assert.spy(line.label.SetText).was.called_with(line.label, "|cFFC0C0C0Elwynn Forest|r")
        end)

        it("should show the collapsed text of a collapsed zone", function()
            Questie.db.char.collapsedZones = {Achievements = true}

            local line, collapsed = LineBuilder.AddHeader({key = "Achievements", text = "Achievements: 3/10", collapsedText = "Achievements +"})

            assert.is_true(collapsed)
            assert.spy(line.expandZone.SetMode).was.called_with(line.expandZone, 0)
            assert.spy(line.label.SetText).was.called_with(line.label, "|cFFC0C0C0Achievements +|r")
        end)

        it("should default the collapsed text to the text with a plus", function()
            Questie.db.char.collapsedZones = {Recipes = true}

            local line = LineBuilder.AddHeader({key = "Recipes", text = "Recipes"})

            assert.spy(line.label.SetText).was.called_with(line.label, "|cFFC0C0C0Recipes +|r")
        end)

        it("should size the line and the tracker to the text", function()
            local line = LineBuilder.AddHeader({key = "Recipes", text = "Recipes"})

            assert.are_same({144}, updatedWidths)
            assert.are_same({114}, trackedWidths)
            assert.spy(line.label.SetWidth).was.called_with(line.label, 356)
            assert.spy(line.SetWidth).was.called_with(line, 250)
            assert.spy(line.expandZone.SetWidth).was.called_with(line.expandZone, 250)
            assert.spy(line.expandZone.SetHeight).was.called_with(line.expandZone, 12)
            assert.spy(line.expandZone.Show).was.called()
        end)

        it("should add 4 pixels below the header", function()
            local line = LineBuilder.AddHeader({key = "Recipes", text = "Recipes"})

            assert.spy(line.SetHeight).was.called_with(line, 16)
            assert.spy(line.Show).was.called()
            assert.spy(line.label.Show).was.called()
        end)

        it("should clear the targets of the line", function()
            nextLine.Quest = {}
            nextLine.Objective = {}
            nextLine.Recipe = {}

            local line = LineBuilder.AddHeader({key = "Recipes", text = "Recipes"})

            assert.is_nil(line.Quest)
            assert.is_nil(line.Objective)
            assert.is_nil(line.Recipe)
        end)

        it("should zero out minAllQuestsInZone when it holds no quest ids", function()
            Questie.db.char.minAllQuestsInZone = {Westfall = {isTrue = false}}

            LineBuilder.AddHeader({key = "Westfall", text = "Westfall"})

            assert.is_nil(Questie.db.char.minAllQuestsInZone.Westfall)
        end)

        it("should keep minAllQuestsInZone when it holds quest ids", function()
            Questie.db.char.minAllQuestsInZone = {Westfall = {[123] = true}}

            LineBuilder.AddHeader({key = "Westfall", text = "Westfall"})

            assert.is_not_nil(Questie.db.char.minAllQuestsInZone.Westfall)
        end)

        it("should keep minAllQuestsInZone while all quests of the zone are minimized", function()
            Questie.db.char.minAllQuestsInZone = {Westfall = {isTrue = true}}

            LineBuilder.AddHeader({key = "Westfall", text = "Westfall"})

            assert.is_not_nil(Questie.db.char.minAllQuestsInZone.Westfall)
        end)
    end)

    describe("AddTitle", function()
        local achievement

        before_each(function()
            achievement = {Id = 4}
        end)

        it("should return nil when the line pool is exhausted", function()
            TrackerLinePool.GetNextLine = function() return nil end

            local line, collapsed = LineBuilder.AddTitle({text = "Title", clickMode = "achieve", target = achievement})

            assert.is_nil(line)
            assert.is_false(collapsed)
        end)

        it("should set up an achievement title", function()
            local line = LineBuilder.AddTitle({text = "Title", clickMode = "achieve", target = achievement, collapseId = 4, zoneKey = "Achievements"})

            assert.spy(line.SetMode).was.called_with(match._, "achieve")
            assert.spy(line.SetOnClick).was.called_with(match._, "achieve")
            assert.spy(line.SetQuest).was.called_with(match._, achievement)
            assert.spy(line.SetObjective).was.called()
            assert.spy(line.SetRecipe).was.not_called()
            assert.spy(line.expandZone.Hide).was.called()
            assert.spy(line.criteriaMark.Hide).was.called()
            assert.spy(line.playButton.Hide).was.called()
            assert.spy(line.label.SetPoint).was.called_with(match._, "TOPLEFT", match._, "TOPLEFT", 20, 0)
            assert.spy(line.label.SetText).was.called_with(match._, "|cFFFFFF00Title|r")
        end)

        it("should set up a recipe title without an expand button", function()
            local recipe = {Id = 2538}

            local line = LineBuilder.AddTitle({text = "Recipe", clickMode = "recipe", target = recipe})

            assert.spy(line.SetMode).was.called_with(match._, "quest")
            assert.spy(line.SetOnClick).was.called_with(match._, "recipe")
            assert.spy(line.SetRecipe).was.called_with(match._, recipe)
            assert.spy(line.SetQuest).was.not_called()
            assert.spy(line.expandQuest.Hide).was.called()
            assert.spy(line.expandQuest.Show).was.not_called()
        end)

        it("should show the expand button of an expanded title", function()
            local line, collapsed = LineBuilder.AddTitle({text = "Title", clickMode = "achieve", target = achievement, collapseId = 4, zoneKey = "Achievements"})

            assert.is_false(collapsed)
            assert.spy(line.expandQuest.Show).was.called()
            assert.spy(line.expandQuest.SetPoint).was.called_with(match._, "TOPRIGHT", match._, "TOPLEFT", 12, 1)
            assert.are.equal("Achievements", line.expandQuest.zoneId)
            assert.spy(line.expandQuest.SetMode).was.called_with(match._, 1)
        end)

        it("should show the expand button of a collapsed title as collapsed", function()
            Questie.db.char.collapsedQuests = {[4] = true}

            local line, collapsed = LineBuilder.AddTitle({text = "Title", clickMode = "achieve", target = achievement, collapseId = 4, zoneKey = "Achievements"})

            assert.is_true(collapsed)
            assert.spy(line.expandQuest.SetMode).was.called_with(match._, 0)
        end)

        it("should add the id to minAllQuestsInZone while all titles of the zone are minimized", function()
            Questie.db.char.minAllQuestsInZone = {Achievements = {isTrue = true}}

            LineBuilder.AddTitle({text = "Title", clickMode = "achieve", target = achievement, collapseId = 4, zoneKey = "Achievements"})

            assert.is_true(Questie.db.char.minAllQuestsInZone.Achievements[4])
        end)

        it("should not touch minAllQuestsInZone when it is not set for the zone", function()
            LineBuilder.AddTitle({text = "Title", clickMode = "achieve", target = achievement, collapseId = 4, zoneKey = "Achievements"})

            assert.is_nil(Questie.db.char.minAllQuestsInZone.Achievements)
        end)

        it("should size the line and the tracker to the text", function()
            local line = LineBuilder.AddTitle({text = "Title", clickMode = "achieve", target = achievement})

            assert.are_same({150}, updatedWidths)
            assert.are_same({120}, trackedWidths)
            assert.spy(line.label.SetWidth).was.called_with(match._, 350)
            assert.spy(line.SetWidth).was.called_with(match._, 270)
        end)

        it("should add 4 pixels below the title", function()
            local line = LineBuilder.AddTitle({text = "Title", clickMode = "achieve", target = achievement})

            assert.spy(line.SetHeight).was.called_with(match._, 16)
            assert.spy(line.Show).was.called()
            assert.spy(line.label.Show).was.called()
        end)
    end)

    describe("AddObjective", function()
        local recipe

        before_each(function()
            recipe = {Id = 2538}
        end)

        it("should return nil when the line pool is exhausted", function()
            TrackerLinePool.GetNextLine = function() return nil end

            assert.is_nil(LineBuilder.AddObjective({text = "Text", clickMode = "recipe", target = recipe}))
        end)

        it("should set up a recipe objective", function()
            local line = LineBuilder.AddObjective({text = "Text", clickMode = "recipe", target = recipe})

            assert.spy(line.SetMode).was.called_with(match._, "objective")
            assert.spy(line.SetOnClick).was.called_with(match._, "recipe")
            assert.spy(line.SetRecipe).was.called_with(match._, recipe)
            assert.spy(line.SetQuest).was.not_called()
            assert.spy(line.expandZone.Hide).was.called()
            assert.spy(line.expandQuest.Hide).was.called()
            assert.spy(line.criteriaMark.Hide).was.called()
            assert.spy(line.playButton.Hide).was.called()
            assert.spy(line.label.SetText).was.called_with(match._, "Text")
        end)

        it("should store the quest and its objective", function()
            local quest = {Id = 1}
            local objective = {Index = 1}

            local line = LineBuilder.AddObjective({text = "Text", clickMode = "quest", target = quest, objective = objective})

            assert.spy(line.SetOnClick).was.called_with(match._, "quest")
            assert.spy(line.SetQuest).was.called_with(match._, quest)
            assert.spy(line.SetObjective).was.called_with(match._, objective)
        end)

        it("should use the objective margin by default", function()
            local line = LineBuilder.AddObjective({text = "Text", clickMode = "recipe", target = recipe})

            assert.spy(line.label.SetPoint).was.called_with(match._, "TOPLEFT", match._, "TOPLEFT", 30, 0)
            assert.spy(TrackerLayout.UpdateLineWidth).was.called_with(line, 30)
        end)

        it("should use the given margin", function()
            local line = LineBuilder.AddObjective({text = "Text", clickMode = "recipe", target = recipe, marginLeft = 54})

            assert.spy(line.label.SetPoint).was.called_with(match._, "TOPLEFT", match._, "TOPLEFT", 54, 0)
            assert.spy(TrackerLayout.UpdateLineWidth).was.called_with(line, 54)
        end)

        it("should add 1 pixel below the objective", function()
            local line = LineBuilder.AddObjective({text = "Text", clickMode = "recipe", target = recipe})

            assert.spy(line.SetHeight).was.called_with(match._, 13)
            assert.spy(line.Show).was.called()
            assert.spy(line.label.Show).was.called()
        end)
    end)

    describe("FinishEntry", function()
        it("should add the padding between quests below the last line", function()
            Questie.db.profile.trackerQuestPadding = 5
            local line = _Line()

            LineBuilder.FinishEntry(line)

            assert.spy(line.SetHeight).was.called_with(match._, 19)
        end)

        it("should use the last line of the pool when no line is given", function()
            local lastLine = _Line()
            TrackerLinePool.GetLastLine = function() return lastLine end

            LineBuilder.FinishEntry(nil)

            assert.spy(lastLine.SetHeight).was.called_with(match._, 16)
        end)
    end)
end)
