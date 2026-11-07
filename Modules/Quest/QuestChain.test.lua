dofile("setupTests.lua")

describe("QuestChain", function()
    ---@type QuestChain
    local QuestChain
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieCorrections
    local QuestieCorrections

    local nextQuestInChain
    local doableStates

    before_each(function()
        nextQuestInChain = {}
        doableStates = {}

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.DoableStates = {
            AVAILABLE = 0,
            WRONG_RACE = 6,
            WRONG_CLASS = 8,
            PROFESSION_SPECIALIZATION = 17,
            LEVEL_TOO_LOW = 26,
            PROFESSION_MISSING = 29,
        }
        QuestieDB.QueryQuestSingle = function(questId, key)
            if key == "nextQuestInChain" then
                return nextQuestInChain[questId]
            end
        end
        QuestieDB.IsDoableVerbose = function(questId)
            return "", false, doableStates[questId] or QuestieDB.DoableStates.AVAILABLE
        end

        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}

        dofile("Modules/Quest/QuestChain.lua")
        QuestChain = QuestieLoader:ImportModule("QuestChain")
    end)

    describe("GetNextQuests", function()
        it("should return an empty list when the quest has no follow-up", function()
            nextQuestInChain[1] = 0

            assert.are_same({}, QuestChain.GetNextQuests(1))
            assert.are_same({}, QuestChain.GetNextQuests(2))
        end)

        it("should list the whole chain in order", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 4
            nextQuestInChain[4] = 0

            assert.are_same({2, 3, 4}, QuestChain.GetNextQuests(1))
        end)

        it("should start after the given quest when it is in the middle of a chain", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 0

            assert.are_same({3}, QuestChain.GetNextQuests(2))
        end)

        it("should stop before a quest hidden by Questie", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 4
            QuestieCorrections.hiddenQuests[3] = true

            assert.are_same({2}, QuestChain.GetNextQuests(1))
        end)

        for _, stateName in ipairs({"WRONG_RACE", "WRONG_CLASS", "PROFESSION_MISSING", "PROFESSION_SPECIALIZATION"}) do
            it("should stop before a quest the player cannot take because of " .. stateName, function()
                nextQuestInChain[1] = 2
                nextQuestInChain[2] = 3
                nextQuestInChain[3] = 4
                doableStates[3] = QuestieDB.DoableStates[stateName]

                assert.are_same({2}, QuestChain.GetNextQuests(1))
            end)
        end

        it("should keep quests the player can take later", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 0
            doableStates[2] = QuestieDB.DoableStates.LEVEL_TOO_LOW
            doableStates[3] = QuestieDB.DoableStates.LEVEL_TOO_LOW

            assert.are_same({2, 3}, QuestChain.GetNextQuests(1))
        end)

        it("should end a chain that loops back to a quest it already listed", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 3
            nextQuestInChain[3] = 2

            assert.are_same({2, 3}, QuestChain.GetNextQuests(1))
        end)

        it("should end a chain that loops back to the given quest", function()
            nextQuestInChain[1] = 2
            nextQuestInChain[2] = 1

            assert.are_same({2}, QuestChain.GetNextQuests(1))
        end)
    end)
end)
