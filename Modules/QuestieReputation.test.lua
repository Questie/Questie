dofile("setupTests.lua")

describe("QuestieReputation", function()
    ---@type QuestieReputation
    local QuestieReputation
    ---@type QuestieQuest
    local QuestieQuest

    before_each(function()
        _G.GetNumFactions = spy.new(function()
            return 1
        end)
        _G.GetFactionInfo = spy.new(function(index)
            return "Wintersaber Trainer", nil, 5, nil, nil, 4500, nil, nil, false, nil, nil, nil, nil, 589, nil, nil
        end)

        QuestieQuest = require("Modules.Quest.QuestieQuest")
        QuestieQuest.ResetAutoblacklistCategory = spy.new(function() end)

        QuestieReputation = require("Modules.QuestieReputation")
    end)

    describe("HasFactionAndReputationLevel", function()
        it("should detect if the player has reached the min required reputation value", function()
            QuestieReputation:Update()

            local requiredMinRep = { 589, 4500 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, nil)

            assert.is_true(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player has not reached the min required reputation value", function()
            QuestieReputation:Update()

            local requiredMinRep = { 589, 5000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, nil)

            assert.is_false(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player exceeds the max required reputation value", function()
            QuestieReputation:Update()

            local requiredMaxRep = { 589, 4500 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(nil, requiredMaxRep)

            assert.is_true(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_false(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player has not reached the max required reputation value", function()
            QuestieReputation:Update()

            local requiredMaxRep = { 589, 5000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(nil, requiredMaxRep)

            assert.is_true(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player has reached the min required reputation value and not the max required reputation value", function()
            QuestieReputation:Update()

            local requiredMinRep = { 589, 4500 }
            local requiredMaxRep = { 589, 5000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)

            assert.is_true(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player has not reached the min required reputation value and has not reached the max required reputation value", function()
            QuestieReputation:Update()

            local requiredMinRep = { 589, 5000 }
            local requiredMaxRep = { 589, 6000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)

            assert.is_false(aboveMinRep)
            assert.is_true(hasMinFaction)
            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)

        it("should detect if the player does not know the faction", function()
            QuestieReputation:Update()

            local requiredMinRep = { 1, 4500 }
            local requiredMaxRep = { 1, 5000 }

            local aboveMinRep, hasMinFaction, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, requiredMaxRep)

            assert.is_false(aboveMinRep)
            assert.is_false(hasMinFaction)
            assert.is_false(belowMaxRep)
            assert.is_false(hasMaxFaction)
        end)

        it("should detect if the player does not know the Darkmoon Faire faction", function()
            QuestieReputation:Update()

            local requiredMaxRep = { 909, 5000 }

            local _, _, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(nil, requiredMaxRep)

            assert.is_true(belowMaxRep)
            assert.is_true(hasMaxFaction)
        end)
    end)
end)
