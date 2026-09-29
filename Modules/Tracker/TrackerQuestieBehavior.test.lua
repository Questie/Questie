dofile("setupTests.lua")

describe("TrackerQuestieBehavior", function()
    local Behavior, QuestieDB, QuestiePlayer, QuestieEvent
    local displayQuest, cached, originalQuestieQuest, originalObjective

    before_each(function()
        Questie.db.profile = {trimObjectiveText = true}
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        QuestieDB.IsComplete = spy.new(function() return 0 end)
        QuestieDB.QueryNPCSingle = function() return "Wolf" end
        QuestieDB.IsPvPQuest = spy.new(function() return true end)
        QuestieEvent.IsEventQuest = spy.new(function() return false end)
        originalObjective = {Id = 10, Index = 3, Description = "Database wording", spawnList = {{Name = "Wolf"}}}
        originalQuestieQuest = {
            Id = 91741, name = "Database title", sourceItemId = 44, requiredSourceItems = {45},
            Finisher = {NPC = {240}}, Objectives = {[3] = originalObjective},
            ObjectiveData = {[3] = {Id = 10, Type = "monster"}}, SpecialObjectives = {{Index = 65}},
        }
        QuestiePlayer.currentQuestlog = {[91741] = originalQuestieQuest}
        displayQuest = {
            Id = 91741, name = "Blizzard title", zoneName = "Northshire Abbey", level = 2,
            Objectives = {{Index = 1, NativeIndex = 3, questId = 91741, Type = "monster", Description = "Wolf",
                Collected = 2, Needed = 5, Completed = false}},
        }
        cached = {isComplete = 0, objectives = {
            [3] = {text = "Wolf", raw_text = "Wolf slain: 2/5", type = "monster", numFulfilled = 2, numRequired = 5},
        }}
        dofile("Modules/Tracker/TrackerQuestieBehavior.lua")
        Behavior = QuestieLoader:ImportModule("TrackerQuestieBehavior")
    end)

    it("attaches original-index map data without replacing live title, wording or progress", function()
        Behavior.Apply(displayQuest, cached)

        assert.are.equal(originalQuestieQuest, displayQuest.enrichment)
        assert.are.equal(originalObjective, displayQuest.Objectives[1].enrichment)
        assert.are.equal(originalObjective.spawnList, displayQuest.Objectives[1].spawnList)
        assert.are.equal(originalQuestieQuest.SpecialObjectives, displayQuest.SpecialObjectives)
        assert.are.equal(originalQuestieQuest.Finisher, displayQuest.Finisher)
        assert.are.equal("Blizzard title", displayQuest.name)
        assert.are.equal("Northshire Abbey", displayQuest.zoneName)
        assert.are.equal("Wolf", displayQuest.Objectives[1].Description)
        assert.are.equal(2, displayQuest.Objectives[1].Collected)
        assert.are.equal(5, displayQuest.Objectives[1].Needed)
        assert.is_nil(originalObjective.Collected)
        assert.are.equal(2, cached.objectives[3].numFulfilled)
    end)

    it("clears old optional data when enrichment is absent, while retaining live progress", function()
        Behavior.Apply(displayQuest, cached)
        QuestiePlayer.currentQuestlog[91741] = 91741 -- The shared model can contain a bare ID.

        Behavior.Apply(displayQuest, cached)

        assert.is_nil(displayQuest.enrichment)
        assert.is_nil(displayQuest.Objectives[1].Id)
        assert.is_nil(displayQuest.Objectives[1].enrichment)
        assert.are.same({}, displayQuest.Objectives[1].spawnList)
        assert.are.same({}, displayQuest.SpecialObjectives)
        assert.are.same({}, displayQuest.Finisher)
        assert.are.same({}, displayQuest.requiredSourceItems)
        assert.are.equal(0, displayQuest.sourceItemId)
        assert.are.equal(2, displayQuest.Objectives[1].Collected)
    end)

    it("resolves native failure without querying cached completion or adding synthetic steps", function()
        displayQuest.Objectives = {}
        originalQuestieQuest.isComplete = true

        Behavior.Apply(displayQuest, nil, -1)

        assert.spy(QuestieDB.IsComplete).was.not_called()
        assert.are.equal(-1, displayQuest.completionState)
        assert.is_false(displayQuest.isComplete)
        assert.are.same({}, displayQuest.Objectives)
        assert.are.equal(originalQuestieQuest.Finisher, displayQuest.Finisher)
    end)

    it("clears stale completion during a cache miss even if the native log reports completion", function()
        displayQuest.Objectives = {}
        displayQuest.completionState = 1
        displayQuest.isComplete = true
        originalQuestieQuest.isComplete = true

        Behavior.Apply(displayQuest, nil, 1)

        assert.are.equal(0, displayQuest.completionState)
        assert.is_false(displayQuest.isComplete)
        assert.spy(QuestieDB.IsComplete).was.not_called()
    end)

    it("does not let an unmatched objective inherit a stale completion flag or special objectives", function()
        originalQuestieQuest.isComplete = true
        cached.objectives[3].raw_text = "Boar slain: 2/5"
        displayQuest.Objectives[1].Description = "Boar"

        Behavior.Apply(displayQuest, cached)

        assert.is_nil(displayQuest.Objectives[1].enrichment)
        assert.are.same({}, displayQuest.ObjectiveData)
        assert.are.same({}, displayQuest.SpecialObjectives)
        assert.is_false(displayQuest.isComplete)
        assert.are.equal("Boar", displayQuest.Objectives[1].Description)
    end)

    it("keeps the source-item exception explicit and separate from an empty native objective list", function()
        displayQuest.Objectives = {}
        cached.objectives = {}
        local note = {Id = 44, Type = "item", Description = "Note", Needed = 1, Collected = 0, Completed = false,
            HideIcons = true, AlreadySpawned = {}, Update = function() end}
        originalQuestieQuest.Objectives = {note}
        originalQuestieQuest.isComplete = true

        Behavior.Apply(displayQuest, cached)

        assert.are.equal(1, #displayQuest.Objectives)
        assert.are.equal("Note", displayQuest.Objectives[1].Description)
        assert.are.equal(1, displayQuest.Objectives[1].Index)
        assert.are.equal(note, displayQuest.Objectives[1].enrichment)
        assert.is_nil(displayQuest.Objectives[1].HideIcons)
        assert.is_nil(displayQuest.Objectives[1].AlreadySpawned)
        assert.is_nil(displayQuest.Objectives[1].Update)
        assert.is_false(displayQuest.isComplete)
        assert.spy(QuestieDB.IsComplete).was.called_with(91741)
    end)

    it("gives the existing numeric failure state precedence over additional completion", function()
        originalQuestieQuest.isComplete = true
        QuestieDB.IsComplete = function() return -1 end

        Behavior.Apply(displayQuest, cached)

        assert.are.equal(-1, displayQuest.completionState)
        assert.is_false(displayQuest.isComplete)
    end)

    it("reads title flags from known Questie data when formatting is requested", function()
        originalQuestieQuest.IsRepeatable = true
        Behavior.Apply(displayQuest, cached)
        assert.spy(QuestieDB.IsPvPQuest).was.not_called()
        assert.spy(QuestieEvent.IsEventQuest).was.not_called()

        local repeatable, event, pvp = Behavior.GetTitleFlags(displayQuest)

        assert.is_true(repeatable)
        assert.is_false(event)
        assert.is_true(pvp)
        assert.spy(QuestieDB.IsPvPQuest).was.called_with(91741)
        assert.spy(QuestieEvent.IsEventQuest).was.called_with(91741)
    end)

    it("does not query database title flags for a Blizzard-only quest", function()
        QuestiePlayer.currentQuestlog[91741] = nil
        Behavior.Apply(displayQuest, cached)

        local repeatable, event, pvp = Behavior.GetTitleFlags(displayQuest)

        assert.is_nil(repeatable)
        assert.is_nil(event)
        assert.is_nil(pvp)
        assert.spy(QuestieDB.IsPvPQuest).was.not_called()
        assert.spy(QuestieEvent.IsEventQuest).was.not_called()
    end)
end)
