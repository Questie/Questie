local Validators = require("cli.validators")
local exitMock

local questKeys = {
    startedBy = "startedBy",
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
    end)

    describe("checkQuestStarters", function()
        it("should find quests with non-existing NPC starters", function()
            local quests = {
                [1] = {
                    startedBy = {{2}},
                },
            }
            local npcs = {}
            local objects = {[2]={}}
            local items = {[2]={}}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, objects, items)

            assert.are.same({
                [1] = "NPC starter 2 is missing in the database"
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should find quests with non-existing object starters", function()
            local quests = {
                [1] = {
                    startedBy = {nil,{2}},
                },
            }
            local npcs = {[2]={}}
            local objects = {}
            local items = {[2]={}}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, objects, items)

            assert.are.same({
                [1] = "Object starter 2 is missing in the database"
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should find quests with non-existing item starters", function()
            local quests = {
                [1] = {
                    startedBy = {nil,nil,{2}},
                },
            }
            local npcs = {[2]={}}
            local objects = {[2]={}}
            local items = {}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, objects, items)

            assert.are.same({
                [1] = "Item starter 2 is missing in the database"
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should not report anything when all quest starters are valid", function()
            local quests = {
                [1] = {
                    startedBy = {{1}},
                },
                [2] = {
                    startedBy = {nil,{2}},
                },
                [3] = {
                    startedBy = {nil,nil,{3}},
                },
            }
            local npcs = {[1]={}}
            local objects = {[2]={}}
            local items = {[3]={}}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, objects, items)

            assert.are.same(nil, invalidQuests)
            assert.spy(exitMock).was_not_called()
        end)
    end)

    describe("checkObjectives", function()
        it("should find quests which have NPC objectives that do not exist in the DB", function()
            local quests = {
                [1] = {
                    objectives = {{{3}}},
                },
                [2] = {
                    objectives = {{{4},{5}}},
                },
            }
            local npcs = {[3]={}}

            local invalidQuests = Validators.checkObjectives(quests, questKeys, npcs, {}, {})

            assert.are.same({
                [2] = {
                    "NPC objective 4 is missing in the database",
                    "NPC objective 5 is missing in the database"
                }
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should find quests which have object objectives that do not exist in the DB", function()
            local quests = {
                [1] = {
                    objectives = {nil,{{3}}},
                },
                [2] = {
                    objectives = {nil,{{4},{5}}},
                },
            }
            local objects = {[3]={}}

            local invalidQuests = Validators.checkObjectives(quests, questKeys, {}, objects, {})

            assert.are.same({
                [2] = {
                    "Object objective 4 is missing in the database",
                    "Object objective 5 is missing in the database"
                }
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should find quests which have item objectives that do not exist in the DB", function()
            local quests = {
                [1] = {
                    objectives = {nil,nil,{{3}}},
                },
                [2] = {
                    objectives = {nil,nil,{{4},{5}}},
                },
            }
            local items = {[3]={}}

            local invalidQuests = Validators.checkObjectives(quests, questKeys, {}, {}, items)

            assert.are.same({
                [2] = {
                    "Item objective 4 is missing in the database",
                    "Item objective 5 is missing in the database"
                }
            }, invalidQuests)
            assert.spy(exitMock).was_called_with(1)
        end)

        it("should not report anything when all objectives are valid", function()
            local quests = {
                [1] = {
                    objectives = {{{1},{2}}},
                },
                [2] = {
                    objectives = {nil,{{1},{2}}},
                },
                [3] = {
                    objectives = {nil,nil,{{1},{2}}},
                },
            }
            local npcs = {[1]={},[2]={}}
            local objects = {[1]={},[2]={}}
            local items = {[1]={},[2]={}}

            local invalidQuests = Validators.checkObjectives(quests, questKeys, npcs, objects, items)

            assert.are.same(nil, invalidQuests)
            assert.spy(exitMock).was_not_called()
        end)
    end)
end)
