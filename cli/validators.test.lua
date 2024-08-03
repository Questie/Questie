local Validators = require("cli.validators")
local exitMock

local questKeys = {
    sourceItemId = "sourceItemId",
    requiredSourceItems = "requiredSourceItems",
    objectives = "objectives",
    preQuestSingle = "preQuestSingle",
    preQuestGroup = "preQuestGroup",
    parentQuest = "parentQuest",
    childQuests = "childQuests",
}

describe("Validators", function()
    before_each(function()
        exitMock = spy.new(function() end)
        _G.os = {
            exit = exitMock
        }
        _G.print = function() end -- disable print
    end)

    describe("checkRequiredSourceItems", function()
        it("should find and report requiredSourceItems which are also a sourceItemId or itemObjective", function()
            local quests = {
                [1] = {
                    sourceItemId = 1,
                    requiredSourceItems = {1, 2, 3},
                },
                [2] = {
                    sourceItemId = 2,
                    requiredSourceItems = {4, 5, 6},
                },
                [3] = {
                    objectives = {nil,nil,{{3}}},
                    requiredSourceItems = {7, 8, 3},
                }
            }

            local matchingQuests = Validators.checkRequiredSourceItems(quests, questKeys)

            assert.are.same(matchingQuests, {
                [1] = "sourceItemId in requiredSourceItems: 1",
                [3] = "itemObjectiveId in requiredSourceItems: 3"
            })
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should not report anything when requiredSourceItems are fine", function()
            local quests = {
                [1] = {
                    sourceItemId = 1,
                    requiredSourceItems = {2, 3, 4},
                },
                [2] = {
                    sourceItemId = 2,
                    requiredSourceItems = {5, 6, 7},
                },
                [3] = {
                    requiredSourceItems = {8, 9, 10},
                    objectives = {nil,nil,{{3}}},
                }
            }

            local matchingQuests = Validators.checkRequiredSourceItems(quests, questKeys)

            assert.are.same(matchingQuests, nil)
            assert.spy(exitMock).was_not_called()
        end)
    end)

    describe("checkPreQuestExclusiveness", function()
        it("should find quests which have both a preQuestSingle and a preQuestGroup entry", function()
            local quests = {
                [1] = {
                    preQuestSingle = {1},
                    preQuestGroup = {2,3},
                },
                [2] = {
                    preQuestSingle = {4},
                },
                [3] = {
                    preQuestGroup = {5},
                }
            }

            local invalidQuests = Validators.checkPreQuestExclusiveness(quests, questKeys)

            assert.are.same({[1] = true}, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should not report anything when preQuestSingle and preQuestGroup are fine", function()
            local quests = {
                [1] = {
                    preQuestSingle = {1},
                },
                [2] = {
                    preQuestSingle = {},
                    preQuestGroup = {2,3},
                },
            }

            local invalidQuests = Validators.checkPreQuestExclusiveness(quests, questKeys)

            assert.are.same(nil, invalidQuests)
            assert.spy(exitMock).was_not_called()
        end)
    end)

    describe("checkParentChildQuestRelations", function()
        it("should find quests which parent is missing their child quest entry", function()
            local quests = {
                [1] = {
                    childQuests = {2},
                },
                [2] = {
                    parentQuest = 1,
                },
                [3] = {},
                [4] = {
                    parentQuest = 3,
                },
                [5] = {
                    childQuests = {6},
                },
                [6] = {
                    parentQuest = 5,
                },
                [7] = {
                    parentQuest = 5,
                },
            }

            local invalidQuests = Validators.checkParentChildQuestRelations(quests, questKeys)

            assert.are.same({
                [3] = "quest has no childQuests. 4 is listing it as parent quest",
                [5] = "quest 7 is missing in childQuests list",
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should find quests which parent is missing in the database (e.g. blacklisted)", function()
            local quests = {
                [1] = {
                    childQuests = {2},
                },
                [2] = {
                    parentQuest = 1,
                },
                [3] = {
                    parentQuest = 4,
                },
            }

            local invalidQuests = Validators.checkParentChildQuestRelations(quests, questKeys)

            assert.are.same({
                [3] = "parent quest 4 is missing/hidden in the database"
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should find quests which child quests are missing their parent entry", function()
            local quests = {
                [1] = {
                    childQuests = {2},
                },
                [2] = {
                    parentQuest = 1,
                },
                [3] = {
                    childQuests = {4},
                },
                [4] = {},
            }

            local invalidQuests = Validators.checkParentChildQuestRelations(quests, questKeys)

            assert.are.same({
                [4] = "quest has no parentQuest. 3 is listing it as child quest"
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should ignore parent quests which were corrected to be 0", function()
            local quests = {
                [1] = {
                    parentQuest = 0,
                },
            }

            local invalidQuests = Validators.checkParentChildQuestRelations(quests, questKeys)

            assert.are.same(nil, invalidQuests)
            assert.spy(exitMock).was_not_called()
        end)

        it("should find quests which child quests are missing in the database (e.g. blacklisted)", function()
            local quests = {
                [1] = {
                    childQuests = {2},
                },
                [2] = {
                    parentQuest = 1,
                },
                [3] = {
                    childQuests = {4,5},
                },
            }

            local invalidQuests = Validators.checkParentChildQuestRelations(quests, questKeys)

            assert.are.same({
                [4] = "quest is missing/hidden in the database. parentQuest is 3",
                [5] = "quest is missing/hidden in the database. parentQuest is 3",
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should find quests which child quests list a different parent", function()
            local quests = {
                [1] = {
                    childQuests = {2},
                },
                [2] = {
                    parentQuest = 3,
                },
                [3] = {
                    childQuests = {2},
                },
            }

            local invalidQuests = Validators.checkParentChildQuestRelations(quests, questKeys)

            assert.are.same({
                [2] = "quest has a different parentQuest. 1 is listing it as child quest"
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)
    end)
end)
