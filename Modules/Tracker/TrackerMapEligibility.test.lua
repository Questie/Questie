dofile("setupTests.lua")

describe("TrackerMapEligibility", function()
    local TrackerMapEligibility, quest, original, objective

    before_each(function()
        dofile("Modules/Tracker/TrackerMapEligibility.lua")
        TrackerMapEligibility = QuestieLoader:ImportModule("TrackerMapEligibility")
        objective = {Index = 3, spawnList = {{Name = "Wolf", Spawns = {[12] = {{50, 50}}}}}}
        original = {Id = 100, Objectives = {[3] = objective}, Finisher = {NPC = {240}}}
        quest = {
            Id = 100, enrichment = original, Objectives = {{Index = 1, enrichment = objective}},
            SpecialObjectives = {}, IsComplete = function() return 0 end,
        }
    end)

    it("offers no map actions for missing or Blizzard-only quests", function()
        assert.is_false(TrackerMapEligibility.GetCapabilities(nil).canFocusQuest)
        quest.enrichment = nil
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_false(capabilities.canFocusQuest)
        assert.is_false(capabilities.canNavigateQuest)
        assert.are.same({}, capabilities.objectives)
    end)

    it("uses original objective indices and objects rather than display indices", function()
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_true(capabilities.canFocusQuest)
        assert.is_true(capabilities.canNavigateQuest)
        assert.is_true(capabilities.objectives[objective])
        assert.are.equal(objective, capabilities.focusObjectives[3])
        assert.is_nil(capabilities.focusObjectives[1])
        assert.are.equal(original, capabilities.quest)
    end)

    it("allows navigation to a verified objective without whole-quest focus on unmatched objectives", function()
        quest.Objectives[2] = {Index = 2, Description = "New live objective"}
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_false(capabilities.canFocusQuest)
        assert.is_true(capabilities.canNavigateQuest)
        assert.are.equal(objective, capabilities.focusObjectives[3])
    end)

    it("does not focus or navigate objectives with no locations", function()
        objective.spawnList = {}
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_false(capabilities.canFocusQuest)
        assert.is_false(capabilities.canNavigateQuest)
        assert.are.same({}, capabilities.objectives)
    end)

    it("uses a known finisher on numeric completion even with unmatched log objectives", function()
        quest.IsComplete = function() return 1 end
        quest.Objectives = {{Type = "log"}}
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_true(capabilities.canFocusQuest)
        assert.is_true(capabilities.canNavigateQuest)
        assert.is_true(capabilities.canShowFinisher)
        assert.are.same({}, capabilities.objectives)
    end)

    it("uses the additional completion boolean for finisher actions", function()
        quest.isComplete = true
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_true(capabilities.canFocusQuest)
        assert.is_true(capabilities.canShowFinisher)
        assert.are.same({}, capabilities.focusObjectives)
    end)

    it("does not offer finisher actions from a stale completion boolean on a failed quest", function()
        quest.IsComplete = function() return -1 end
        quest.isComplete = true
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_false(capabilities.canShowFinisher)
    end)

    it("does not offer completed quest actions when the finisher is unknown", function()
        quest.IsComplete = function() return 1 end
        original.Finisher = {}
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_false(capabilities.canFocusQuest)
        assert.is_false(capabilities.canNavigateQuest)
        assert.is_false(capabilities.canShowFinisher)
    end)

    it("does not invent an original index for a synthetic source-item objective", function()
        objective.Index = nil
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_true(capabilities.objectives[objective])
        assert.are.same({}, capabilities.focusObjectives)
        assert.is_nil(objective.Index)
    end)

    it("includes exposed special objectives with their original index", function()
        quest.Objectives = {}
        local special = {Index = 65, spawnList = {{Spawns = {[12] = {{50, 50}}}}}}
        quest.SpecialObjectives = {special}
        local capabilities = TrackerMapEligibility.GetCapabilities(quest)
        assert.is_true(capabilities.canFocusQuest)
        assert.is_true(capabilities.objectives[special])
        assert.are.equal(special, capabilities.focusObjectives[65])
    end)

    describe("RefreshAndGetCapabilities", function()
        local TrackerData

        before_each(function()
            TrackerData = QuestieLoader:ImportModule("TrackerData")
            TrackerData.RefreshQuest = spy.new(function() return quest end)
        end)

        it("refreshes the quest before evaluating it", function()
            local current, capabilities = TrackerMapEligibility.RefreshAndGetCapabilities(100, original)

            assert.spy(TrackerData.RefreshQuest).was.called_with(100)
            assert.are.equal(quest, current)
            assert.is_true(capabilities.canFocusQuest)
        end)

        it("returns nothing when the quest's original changed since the menu captured it", function()
            quest.enrichment = {Id = 100, Objectives = {}}

            local current, capabilities = TrackerMapEligibility.RefreshAndGetCapabilities(100, original)

            assert.is_nil(current)
            assert.is_nil(capabilities)
        end)

        it("still returns capabilities without a captured original, even after the quest left the log", function()
            TrackerData.RefreshQuest = function() return nil end

            local current, capabilities = TrackerMapEligibility.RefreshAndGetCapabilities(100)

            assert.is_nil(current)
            assert.is_false(capabilities.canFocusQuest)
        end)
    end)
end)
