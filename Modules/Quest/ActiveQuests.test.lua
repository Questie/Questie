dofile("setupTests.lua")

describe("ActiveQuests", function()
    ---@type ActiveQuests
    local ActiveQuests
    ---@type QuestiePlayer
    local QuestiePlayer

    before_each(function()
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        dofile("Modules/Quest/ActiveQuests.lua")
        ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
    end)

    describe("Add", function()
        it("should log the quest with a current acceptance", function()
            local quest = {Id = 1}

            local acceptance = ActiveQuests.Add(1, quest)

            assert.is_true(ActiveQuests.IsCurrent(acceptance))
            assert.are.equal(acceptance, ActiveQuests.Get(1))
            assert.are.equal(quest, acceptance.quest)
            assert.are.equal(quest, QuestiePlayer.currentQuestlog[1])
        end)

        it("should log a quest the database lacks by its ID", function()
            local acceptance = ActiveQuests.Add(1)

            assert.is_nil(acceptance.quest)
            assert.are.equal(1, QuestiePlayer.currentQuestlog[1])
        end)

        it("should replace the acceptance of a quest accepted again", function()
            local first = ActiveQuests.Add(1, {})

            local second = ActiveQuests.Add(1, {})

            assert.is_false(ActiveQuests.IsCurrent(first))
            assert.is_true(ActiveQuests.IsCurrent(second))
        end)
    end)

    describe("Remove", function()
        it("should end the acceptance and unlog the quest", function()
            local acceptance = ActiveQuests.Add(1, {})

            assert.are.equal(acceptance, ActiveQuests.Remove(1))

            assert.is_false(ActiveQuests.IsCurrent(acceptance))
            assert.is_nil(ActiveQuests.Get(1))
            assert.is_nil(QuestiePlayer.currentQuestlog[1])
        end)

        it("should return nil for a quest that is not logged", function()
            assert.is_nil(ActiveQuests.Remove(1))
        end)
    end)

    describe("IsCurrent", function()
        it("should treat a missing acceptance as not current", function()
            assert.is_false(ActiveQuests.IsCurrent(nil))
        end)
    end)

    describe("Reset and Restore", function()
        it("should not let Restore bring back an acceptance removed after a Reset", function()
            local acceptance = ActiveQuests.Add(1, {})
            ActiveQuests.Reset()
            ActiveQuests.Remove(1)

            assert.are_not.equal(acceptance, ActiveQuests.Restore(1, {}))
        end)

        it("should unlog every quest on Reset", function()
            local acceptance = ActiveQuests.Add(1, {})

            ActiveQuests.Reset()

            assert.is_false(ActiveQuests.IsCurrent(acceptance))
            assert.is_nil(ActiveQuests.Get(1))
            assert.are.same({}, QuestiePlayer.currentQuestlog)
        end)

        it("should keep the acceptance of a quest restored after a Reset", function()
            local acceptance = ActiveQuests.Add(1, {})
            ActiveQuests.Reset()
            local quest = {}

            assert.are.equal(acceptance, ActiveQuests.Restore(1, quest))

            assert.is_true(ActiveQuests.IsCurrent(acceptance))
            assert.are.equal(quest, acceptance.quest)
            assert.are.equal(quest, QuestiePlayer.currentQuestlog[1])
        end)

        it("should keep the current acceptance when restoring a logged quest", function()
            local acceptance = ActiveQuests.Add(1, {})

            assert.are.equal(acceptance, ActiveQuests.Restore(1, {}))
        end)

        it("should create an acceptance when restoring a quest that was not logged", function()
            local acceptance = ActiveQuests.Restore(1, {})

            assert.is_true(ActiveQuests.IsCurrent(acceptance))
        end)

        it("should not let Restore bring back an acceptance replaced after a Reset", function()
            local first = ActiveQuests.Add(1, {})
            ActiveQuests.Reset()
            local second = ActiveQuests.Add(1, {})

            assert.are.equal(second, ActiveQuests.Restore(1, {}))
            assert.is_false(ActiveQuests.IsCurrent(first))
        end)
    end)
end)
