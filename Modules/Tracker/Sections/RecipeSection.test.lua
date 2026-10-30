dofile("setupTests.lua")

describe("RecipeSection", function()
    ---@type RecipeSection
    local RecipeSection
    local TrackerLinePool, TrackerLayout, TrackerRecipes

    local recipes, texts

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
        setmetatable(line, {__index = function() return function() end end})
        return line
    end

    before_each(function()
        recipes = {}
        texts = {}
        Questie.db.char.collapsedZones = {}
        Questie.db.char.minAllQuestsInZone = {}
        Questie.db.profile.trackerQuestPadding = 2
        Questie.db.profile.trackerColorObjectives = "white"

        TrackerRecipes = QuestieLoader:ImportModule("TrackerRecipes")
        TrackerRecipes.GetTrackedRecipes = function() return recipes end

        TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
        TrackerLayout.GetMargins = function() return {left = 14, right = 30, quest = 20, objective = 30, itemButtonSize = 24} end
        TrackerLayout.UpdateWidth = function() end
        TrackerLayout.GetBaseFrameWidth = function() return 200 end
        TrackerLayout.TrackLineWidth = function() end
        TrackerLayout.UpdateLineWidth = spy.new(function() end)

        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        TrackerLinePool.GetNextLine = spy.new(_FakeLine)

        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/Tracker/LinePool/LineBuilder.lua")
        dofile("Modules/Tracker/Sections/RecipeSection.lua")
        RecipeSection = QuestieLoader:ImportModule("RecipeSection")
    end)

    it("should draw nothing when no recipe is tracked", function()
        RecipeSection.Draw()

        assert.spy(TrackerLinePool.GetNextLine).was.not_called()
    end)

    it("should draw tracked recipes with their reagents", function()
        recipes = {{Id = 2538, Name = "Charred Wolf Meat", Reagents = {
            {ItemId = 2672, Name = "Stringy Wolf Meat", Collected = 1, Needed = 2},
        }}}

        RecipeSection.Draw()

        assert.spy(TrackerLayout.UpdateLineWidth).was.called(1)
        assert.are_same("|cFFC0C0C0Recipes|r", texts[1])
        assert.are_same("|cFFFFFF00Charred Wolf Meat|r", texts[2])
        assert.is_truthy(texts[3]:find("Stringy Wolf Meat: 1/2", 1, true))
    end)

    it("should only draw the header when it is collapsed", function()
        recipes = {{Id = 2538, Name = "Charred Wolf Meat", Reagents = {}}}
        Questie.db.char.collapsedZones = {Recipes = true}

        RecipeSection.Draw()

        assert.are_same({"|cFFC0C0C0Recipes +|r"}, texts)
    end)

    it("should stop drawing when the line pool is exhausted", function()
        recipes = {{Id = 1, Name = "First", Reagents = {}}, {Id = 2, Name = "Second", Reagents = {}}}
        local lines = {_FakeLine(), _FakeLine(), nil}
        local index = 0
        TrackerLinePool.GetNextLine = function()
            index = index + 1
            return lines[index]
        end

        RecipeSection.Draw()

        assert.are_same(2, #texts)
        assert.are_same(3, index)
    end)
end)
