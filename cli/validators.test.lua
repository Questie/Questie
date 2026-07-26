local Validators = require("cli.validators")
local exitMock

local questKeys = {
    startedBy = "startedBy",
    finishedBy = "finishedBy",
    requiredRaces = "requiredRaces",
    sourceItemId = "sourceItemId",
    requiredSourceItems = "requiredSourceItems",
    objectives = "objectives",
    preQuestSingle = "preQuestSingle",
    preQuestGroup = "preQuestGroup",
    parentQuest = "parentQuest",
    childQuests = "childQuests",
    extraObjectives = "extraObjectives",
    triggerEnd = "triggerEnd",
}
local npcKeys = {
    name = "name",
    spawns = "spawns",
    questStarts = "questStarts",
    questEnds = "questEnds",
}
local objectKeys = {
    name = "name",
    spawns = "spawns",
    questStarts = "questStarts",
    questEnds = "questEnds",
    zoneID = "zoneID",
    factionID = "factionID",
    waypoints = "waypoints",
}
local itemKeys = {
    name = "name",
    npcDrops = "npcDrops",
    objectDrops = "objectDrops",
    itemDrops = "itemDrops",
    startQuest = "startQuest",
    questRewards = "questRewards",
    flags = "flags",
    foodType = "foodType",
    itemLevel = "itemLevel",
    requiredLevel = "requiredLevel",
    ammoType = "ammoType",
    class = "class",
    subClass = "subClass",
    vendors = "vendors",
    relatedQuests = "relatedQuests",
    teachesSpell = "teachesSpell",
}
local raceKeys = {
    ALL_ALLIANCE = 18875469,
    ALL_HORDE = 33555378,
    PANDAREN_ALLIANCE = 16777216,
    PANDAREN_HORDE = 33554432,
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

            assert.are_same(matchingQuests, {
                [1] = "sourceItemId in requiredSourceItems: 1",
                [3] = "itemObjectiveId in requiredSourceItems: 3"
            })
            assert.spy(exitMock).was.called_with(1)
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

            assert.are_same(matchingQuests, nil)
            assert.spy(exitMock).was.not_called()
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

            assert.are_same({[1] = true}, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
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

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report anything for quest 30277", function()
            local quests = {
                [30277] = {
                    preQuestSingle = {1},
                    preQuestGroup = {2,3},
                },
            }

            local invalidQuests = Validators.checkPreQuestExclusiveness(quests, questKeys)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report anything for quest 30280", function()
            local quests = {
                [30280] = {
                    preQuestSingle = {1},
                    preQuestGroup = {2,3},
                },
            }

            local invalidQuests = Validators.checkPreQuestExclusiveness(quests, questKeys)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
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

            assert.are_same({
                [3] = "quest has no childQuests. 4 is listing it as parent quest",
                [5] = "quest 7 is missing in childQuests list",
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
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

            assert.are_same({
                [3] = "parent quest 4 is missing/hidden in the database"
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
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

            assert.are_same({
                [4] = "quest has no parentQuest. 3 is listing it as child quest"
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should ignore parent quests which were corrected to be 0", function()
            local quests = {
                [1] = {
                    parentQuest = 0,
                },
            }

            local invalidQuests = Validators.checkParentChildQuestRelations(quests, questKeys)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
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

            assert.are_same({
                [4] = "quest is missing/hidden in the database. parentQuest is 3",
                [5] = "quest is missing/hidden in the database. parentQuest is 3",
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
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

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, npcKeys, objects, items)

            assert.are_same({
                [1] = "NPC starter 2 is missing in the database"
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find quests with NPC starters that don't have a name", function()
            local quests = {
                [1] = {
                    startedBy = {{2}},
                },
            }
            local npcs = {[2]={}}
            local objects = {[2]={}}
            local items = {[2]={}}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, npcKeys, objects, items)

            assert.are_same({
                [1] = "NPC starter 2 has no name"
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find quests with non-existing object starters", function()
            local quests = {
                [1] = {
                    startedBy = {nil,{2}},
                },
            }
            local npcs = {[2]={name="second NPC"}}
            local objects = {}
            local items = {[2]={}}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, npcKeys, objects, items)

            assert.are_same({
                [1] = "Object starter 2 is missing in the database"
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find quests with non-existing item starters", function()
            local quests = {
                [1] = {
                    startedBy = {nil,nil,{2}},
                },
            }
            local npcs = {[2]={name="second NPC"}}
            local objects = {[2]={}}
            local items = {}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, npcKeys, objects, items)

            assert.are_same({
                [1] = "Item starter 2 is missing in the database"
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
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
            local npcs = {[1]={name="first NPC"}}
            local objects = {[2]={}}
            local items = {[3]={}}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, npcKeys, objects, items)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)
    end)

    describe("checkQuestFinishers", function()
        it("should find quests with non-existing NPC finisher", function()
            local quests = {
                [1] = {
                    finishedBy = {{2}},
                },
            }
            local npcs = {}
            local objects = {[2]={}}

            local invalidQuests = Validators.checkQuestFinishers(quests, questKeys, npcs, objects)

            assert.are_same({
                [1] = "NPC finisher 2 is missing in the database"
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find quests with non-existing object finisher", function()
            local quests = {
                [1] = {
                    finishedBy = {nil,{2}},
                },
            }
            local npcs = {[2]={}}
            local objects = {}

            local invalidQuests = Validators.checkQuestFinishers(quests, questKeys, npcs, objects)

            assert.are_same({
                [1] = "Object finisher 2 is missing in the database"
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should not report anything when all quest finisher are valid", function()
            local quests = {
                [1] = {
                    finishedBy = {{1}},
                },
                [2] = {
                    finishedBy = {nil,{2}},
                },
                [3] = {
                    finishedBy = {nil,nil,{3}},
                },
            }
            local npcs = {[1]={}}
            local objects = {[2]={}}
            local items = {[3]={}}

            local invalidQuests = Validators.checkQuestStarters(quests, questKeys, npcs, objects, items)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
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

            assert.are_same({
                [2] = {
                    "NPC objective 4 is missing in the database",
                    "NPC objective 5 is missing in the database"
                }
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
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

            assert.are_same({
                [2] = {
                    "Object objective 4 is missing in the database",
                    "Object objective 5 is missing in the database"
                }
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
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

            assert.are_same({
                [2] = {
                    "Item objective 4 is missing in the database",
                    "Item objective 5 is missing in the database"
                }
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find quests which have killCredit objectives that do not exist in the DB", function()
            local quests = {
                [1] = {
                    objectives = {{{3}}},
                },
                [2] = {
                    objectives = {nil,nil,nil,nil,{{{4,5},4}}},
                },
            }
            local npcs = {[3]={}}

            local invalidQuests = Validators.checkObjectives(quests, questKeys, npcs, {}, {})

            assert.are_same({
                [2] = {
                    "NPC 4 for killCredit objective is missing in the database",
                    "NPC 5 for killCredit objective is missing in the database",
                }
            }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
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

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)
    end)

    describe("checkNpcQuestStarts", function()
        it("should find NPCs which have invalid questStarts entries", function()
            local npcs = {
                [1] = {
                    name = "First NPC",
                    questStarts = {2, 3},
                },
                [2] = {
                    name = "Second NPC",
                    questStarts = {4},
                },
                [3] = {
                    name = "Third NPC",
                    questStarts = {5, 6},
                },
                [4] = {
                    name = "Fourth NPC",
                    questStarts = {7,9},
                },
            }
            local quests = {
                [2] = {startedBy = {{1}}},
                [4] = {startedBy = {{2}}},
                [7] = {startedBy = {nil,{8}}},
                [9] = {startedBy = {{4}}},
            }

            local invalidQuests, targetQuestStarts = Validators.checkNpcQuestStarts(npcs, npcKeys, quests, questKeys)

            assert.are_same({
                [1] = {"questStart 3 is not in the database"},
                [3] = {
                    "questStart 5 is not in the database",
                    "questStart 6 is not in the database"
                },
                [4] = {"quest 7 is not started by this NPC"},
            }, invalidQuests)

            assert.are_same({
                [1] = {2},
                [3] = {},
                [4] = {9},
            }, targetQuestStarts)
        end)

        it("should find NPCs which have missing questStarts entries", function()
            local npcs = {
                [1] = {
                    name = "First NPC",
                    questStarts = {3},
                },
                [2] = {
                    name = "Second NPC",
                    questStarts = {4},
                },
                [3] = {
                    name = "Third NPC",
                    questStarts = {5},
                },
            }
            local quests = {
                [2] = {
                    startedBy = {{1}},
                },
                [4] = {
                    startedBy = {{2}},
                },
                [5] = {
                    startedBy = {{3}},
                },
                [6] = {
                    startedBy = {{3}},
                },
            }

            local invalidQuests, targetQuestStarts = Validators.checkNpcQuestStarts(npcs, npcKeys, quests, questKeys)

            assert.are_same({
                [1] = {
                    "quest 2 is missing in questStarts",
                    "questStart 3 is not in the database",
                },
                [3] = {"quest 6 is missing in questStarts"},
            }, invalidQuests)

            assert.are_same({
                [1] = {2},
                [3] = {5,6},
            }, targetQuestStarts)
        end)

        it("should not report anything when all questStarts and questEnds are valid", function()
            local npcs = {
                [1] = {
                    questStarts = {2},
                },
                [2] = {
                    questStarts = {4},
                },
            }
            local quests = {
                [2] = {},
                [4] = {},
            }

            local invalidQuests, targetQuestStarts = Validators.checkNpcQuestStarts(npcs, npcKeys, quests, questKeys)

            assert.are_same(nil, invalidQuests)
            assert.are_same(nil, targetQuestStarts)
        end)
    end)

    describe("checkNpcQuestEnds", function()
        it("should find NPCs which have invalid questEnds entries", function()
            local npcs = {
                [1] = {
                    name = "First NPC",
                    questEnds = {2, 3},
                },
                [2] = {
                    name = "Second NPC",
                    questEnds = {4},
                },
                [3] = {
                    name = "Third NPC",
                    questEnds = {5, 6},
                },
                [4] = {
                    name = "Fourth NPC",
                    questEnds = {7,9},
                },
            }
            local quests = {
                [2] = {finishedBy = {{1}}},
                [4] = {finishedBy = {{2}}},
                [7] = {finishedBy = {nil,{8}}},
                [9] = {finishedBy = {{4}}},
            }

            local invalidQuests, targetQuestEnds = Validators.checkNpcQuestEnds(npcs, npcKeys, quests, questKeys)

            assert.are_same({
                [1] = {"questEnd 3 is not in the database"},
                [3] = {
                    "questEnd 5 is not in the database",
                    "questEnd 6 is not in the database",
                },
                [4] = {"quest 7 is not finished by this NPC"},
            }, invalidQuests)

            assert.are_same({
                [1] = {2},
                [3] = {},
                [4] = {9},
            }, targetQuestEnds)
        end)

        it("should find NPCs which have missing questEnds entries", function()
            local npcs = {
                [1] = {
                    name = "First NPC",
                    questEnds = {3},
                },
                [2] = {
                    name = "Second NPC",
                    questEnds = {4},
                },
                [3] = {
                    name = "Third NPC",
                    questEnds = {5},
                },
            }
            local quests = {
                [2] = {
                    finishedBy = {{1}},
                },
                [4] = {
                    finishedBy = {{2}},
                },
                [5] = {
                    finishedBy = {{3}},
                },
                [6] = {
                    finishedBy = {{3}},
                },
            }

            local invalidQuests, targetQuestEnds = Validators.checkNpcQuestEnds(npcs, npcKeys, quests, questKeys)

            assert.are_same({
                [1] = {
                    "quest 2 is missing in questEnds",
                    "questEnd 3 is not in the database",
                },
                [3] = {"quest 6 is missing in questEnds"},
            }, invalidQuests)

            assert.are_same({
                [1] = {2},
                [3] = {5,6},
            }, targetQuestEnds)
        end)

        it("should skip finishedBy entries of quests", function()
            local npcs = {
                [1] = {
                    name = "First NPC",
                    questEnds = {2},
                },
            }
            local quests = {
                [2] = {finishedBy={{1}}},
                [4] = {finishedBy={{3}}},
            }

            local invalidQuests = Validators.checkNpcQuestEnds(npcs, npcKeys, quests, questKeys)

            assert.are_same(nil, invalidQuests)
        end)

        it("should not report anything when all questEnds are valid", function()
            local npcs = {
                [1] = {
                    questEnds = {3},
                },
                [2] = {
                    questEnds = {4},
                },
            }
            local quests = {
                [3] = {},
                [4] = {},
            }

            local invalidQuests, targetQuestEnds = Validators.checkNpcQuestEnds(npcs, npcKeys, quests, questKeys)

            assert.are_same(nil, invalidQuests)
            assert.are_same(nil, targetQuestEnds)
        end)
    end)

    describe("checkObjectQuestStarts", function()
        it("should find objects which have invalid questStarts entries", function()
            local objects = {
                [1] = {
                    name = "First Object",
                    questStarts = {2, 3},
                },
                [2] = {
                    name = "Second Object",
                    questStarts = {4},
                },
                [3] = {
                    name = "Third Object",
                    questStarts = {5, 6},
                },
                [4] = {
                    name = "Fourth Object",
                    questStarts = {7,9},
                },
            }
            local quests = {
                [2] = {startedBy = {nil,{1}}},
                [4] = {startedBy = {nil,{2}}},
                [7] = {startedBy = {{8}}},
                [9] = {startedBy = {nil,{4}}},
            }

            local invalidQuests, targetQuestStarts = Validators.checkObjectQuestStarts(objects, objectKeys, quests, questKeys)

            assert.are_same({
                [1] = {"questStart 3 is not in the database"},
                [3] = {
                    "questStart 5 is not in the database",
                    "questStart 6 is not in the database"
                },
                [4] = {"quest 7 is not started by this object"},
            }, invalidQuests)

            assert.are_same({
                [1] = {2},
                [3] = {},
                [4] = {9},
            }, targetQuestStarts)
        end)

        it("should find objects which have missing questStarts entries", function()
            local objects = {
                [1] = {
                    name = "First Object",
                    questStarts = {3},
                },
                [2] = {
                    name = "Second Object",
                    questStarts = {4},
                },
                [3] = {
                    name = "Third Object",
                    questStarts = {5},
                },
            }
            local quests = {
                [2] = {
                    startedBy = {nil,{1}},
                },
                [4] = {
                    startedBy = {nil,{2}},
                },
                [5] = {
                    startedBy = {nil,{3}},
                },
                [6] = {
                    startedBy = {nil,{3}},
                },
            }

            local invalidQuests, targetQuestStarts = Validators.checkObjectQuestStarts(objects, objectKeys, quests, questKeys)

            assert.are_same({
                [1] = {
                    "quest 2 is missing in questStarts",
                    "questStart 3 is not in the database",
                },
                [3] = {"quest 6 is missing in questStarts"},
            }, invalidQuests)

            assert.are_same({
                [1] = {2},
                [3] = {5,6},
            }, targetQuestStarts)
        end)

        it("should not report anything when all questStarts and questEnds are valid", function()
            local objects = {
                [1] = {
                    questStarts = {2},
                },
                [2] = {
                    questStarts = {4},
                },
            }
            local quests = {
                [2] = {},
                [4] = {},
            }

            local invalidQuests, targetQuestStarts = Validators.checkObjectQuestStarts(objects, objectKeys, quests, questKeys)

            assert.are_same(nil, invalidQuests)
            assert.are_same(nil, targetQuestStarts)
        end)
    end)

    describe("checkObjectQuestEnds", function()
        it("should find objects which have invalid questEnds entries", function()
            local objects = {
                [1] = {
                    name = "First Object",
                    questEnds = {2, 3},
                },
                [2] = {
                    name = "Second Object",
                    questEnds = {4},
                },
                [3] = {
                    name = "Third Object",
                    questEnds = {5, 6},
                },
                [4] = {
                    name = "Fourth Object",
                    questEnds = {7,9},
                },
            }
            local quests = {
                [2] = {finishedBy = {nil,{1}}},
                [4] = {finishedBy = {nil,{2}}},
                [7] = {finishedBy = {{8}}},
                [9] = {finishedBy = {nil,{4}}},
            }

            local invalidQuests, targetQuestEnds = Validators.checkObjectQuestEnds(objects, objectKeys, quests, questKeys)

            assert.are_same({
                [1] = {"questEnd 3 is not in the database"},
                [3] = {
                    "questEnd 5 is not in the database",
                    "questEnd 6 is not in the database",
                },
                [4] = {"quest 7 is not finished by this object"},
            }, invalidQuests)

            assert.are_same({
                [1] = {2},
                [3] = {},
                [4] = {9},
            }, targetQuestEnds)
        end)

        it("should find objects which have missing questEnds entries", function()
            local objects = {
                [1] = {
                    name = "First Object",
                    questEnds = {3},
                },
                [2] = {
                    name = "Second Object",
                    questEnds = {4},
                },
                [3] = {
                    name = "Third Object",
                    questEnds = {5},
                },
            }
            local quests = {
                [2] = {
                    finishedBy = {nil,{1}},
                },
                [4] = {
                    finishedBy = {nil,{2}},
                },
                [5] = {
                    finishedBy = {nil,{3}},
                },
                [6] = {
                    finishedBy = {nil,{3}},
                },
            }

            local invalidQuests, targetQuestEnds = Validators.checkObjectQuestEnds(objects, objectKeys, quests, questKeys)

            assert.are_same({
                [1] = {
                    "quest 2 is missing in questEnds",
                    "questEnd 3 is not in the database",
                },
                [3] = {"quest 6 is missing in questEnds"},
            }, invalidQuests)

            assert.are_same({
                [1] = {2},
                [3] = {5,6},
            }, targetQuestEnds)
        end)

        it("should not report anything when all questEnds are valid", function()
            local objects = {
                [1] = {
                    questEnds = {3},
                },
                [2] = {
                    questEnds = {4},
                },
            }
            local quests = {
                [3] = {},
                [4] = {},
            }

            local invalidQuests = Validators.checkObjectQuestEnds(objects, objectKeys, quests, questKeys)

            assert.are_same(nil, invalidQuests)
        end)
    end)

    describe("checkRequiredRaces", function()
        it("should find quests with too high requiredRaces", function()
            local quests = {
                [1] = {
                    requiredRaces = 54043195541028864
                },
                [2] = {
                    requiredRaces = 16777216 + 33554432
                },
                [3] = {
                    requiredRaces = 4294967295
                }
            }

            local invalidQuests = Validators.checkRequiredRaces(quests, questKeys, raceKeys)

            assert.are_same({
                [1] = "requiredRaces is too high",
                [3] = "requiredRaces is too high"
            }, invalidQuests)
        end)

        it("should find quests with missing requiredRaces", function()
            local quests = {
                [1] = {}
            }

            local invalidQuests = Validators.checkRequiredRaces(quests, questKeys, raceKeys)

            assert.are_same({
                [1] = "no requiredRaces entry"
            }, invalidQuests)
        end)

        it("should not report anything when requiredRaces is fine", function()
            local quests = {
                [1] = {
                    requiredRaces = 18875469
                },
                [2] = {
                    requiredRaces = 0
                },
                [3] = {
                    requiredRaces = 33555378
                }
            }

            local invalidQuests = Validators.checkRequiredRaces(quests, questKeys, raceKeys)

            assert.are_same(nil, invalidQuests)
        end)
    end)

    describe("checkNpcSpawnAreaIds", function()
        local getUiMapIdByAreaId

        before_each(function()
            getUiMapIdByAreaId = function(areaId)
                local known = { [1519] = 84, [12] = 37 }
                return known[areaId]
            end
        end)

        it("should report NPCs with spawn areaIds not handled by GetUiMapIdByAreaId", function()
            local npcs = {
                [100] = { name = "Guard", spawns = { [1519] = {{51, 27}}, [9999] = {{10, 20}} } },
                [200] = { name = "Vendor", spawns = { [12] = {{32, 49}} } },
            }

            local invalidNpcs = Validators.checkNpcSpawnAreaIds(npcs, npcKeys, getUiMapIdByAreaId)

            assert.are_same({ [100] = { 9999 } }, invalidNpcs)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should not report anything when all spawn areaIds are handled", function()
            local npcs = {
                [100] = { name = "Guard", spawns = { [1519] = {{51, 27}}, [12] = {{32, 49}} } },
            }

            local invalidNpcs = Validators.checkNpcSpawnAreaIds(npcs, npcKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidNpcs)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report NPCs without spawns", function()
            local npcs = {
                [100] = { name = "Guard" },
            }

            local invalidNpcs = Validators.checkNpcSpawnAreaIds(npcs, npcKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidNpcs)
            assert.spy(exitMock).was.not_called()
        end)
    end)

    describe("checkObjectSpawnAreaIds", function()
        local getUiMapIdByAreaId

        before_each(function()
            getUiMapIdByAreaId = function(areaId)
                local known = { [1519] = 84, [12] = 37 }
                return known[areaId]
            end
        end)

        it("should report objects with spawn areaIds not handled by GetUiMapIdByAreaId", function()
            local objects = {
                [100] = { name = "Old Chest", spawns = { [1519] = {{51, 27}}, [9999] = {{10, 20}} } },
                [200] = { name = "Barrel", spawns = { [12] = {{32, 49}} } },
            }

            local invalidObjects = Validators.checkObjectSpawnAreaIds(objects, objectKeys, getUiMapIdByAreaId)

            assert.are_same({ [100] = { 9999 } }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should not report anything when all spawn areaIds are handled", function()
            local objects = {
                [100] = { name = "Old Chest", spawns = { [1519] = {{51, 27}}, [12] = {{32, 49}} } },
            }

            local invalidObjects = Validators.checkObjectSpawnAreaIds(objects, objectKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidObjects)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report objects without spawns", function()
            local objects = {
                [100] = { name = "Old Chest" },
            }

            local invalidObjects = Validators.checkObjectSpawnAreaIds(objects, objectKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidObjects)
            assert.spy(exitMock).was.not_called()
        end)
    end)

    describe("checkQuestExtraObjectiveSpawnAreaIds", function()
        local getUiMapIdByAreaId

        before_each(function()
            getUiMapIdByAreaId = function(areaId)
                local known = { [1519] = 84, [12] = 37 }
                return known[areaId]
            end
        end)

        it("should report quests with extraObjective spawnlist areaIds not handled by GetUiMapIdByAreaId", function()
            local quests = {
                [10] = { extraObjectives = {
                    { {[1519]={{51,27}}, [9999]={{10,20}}}, "icon", "text" },
                }},
                [20] = { extraObjectives = {
                    { {[12]={{32,49}}}, "icon", "text" },
                }},
            }

            local invalidQuests = Validators.checkQuestExtraObjectiveSpawnAreaIds(quests, questKeys, getUiMapIdByAreaId)

            assert.are_same({ [10] = { 9999 } }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should not report anything when all extraObjective spawnlist areaIds are handled", function()
            local quests = {
                [10] = { extraObjectives = {
                    { {[1519]={{51,27}}, [12]={{32,49}}}, "icon", "text" },
                }},
            }

            local invalidQuests = Validators.checkQuestExtraObjectiveSpawnAreaIds(quests, questKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report quests without extraObjectives", function()
            local quests = {
                [10] = { requiredRaces = 18875469 },
            }

            local invalidQuests = Validators.checkQuestExtraObjectiveSpawnAreaIds(quests, questKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report extraObjectives with nil spawnlist", function()
            local quests = {
                [10] = { extraObjectives = {
                    { nil, "icon", "text" },
                }},
            }

            local invalidQuests = Validators.checkQuestExtraObjectiveSpawnAreaIds(quests, questKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)
    end)

    describe("checkQuestTriggerEndSpawnAreaIds", function()
        local getUiMapIdByAreaId

        before_each(function()
            getUiMapIdByAreaId = function(areaId)
                local known = { [1519] = 84, [12] = 37 }
                return known[areaId]
            end
        end)

        it("should report quests with triggerEnd spawnlist areaIds not handled by GetUiMapIdByAreaId", function()
            local quests = {
                [10] = { triggerEnd = { "Some trigger", {[1519]={{51,27}}, [9999]={{10,20}}} } },
                [20] = { triggerEnd = { "Other trigger", {[12]={{32,49}}} } },
            }

            local invalidQuests = Validators.checkQuestTriggerEndSpawnAreaIds(quests, questKeys, getUiMapIdByAreaId)

            assert.are_same({ [10] = { 9999 } }, invalidQuests)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should not report anything when all triggerEnd spawnlist areaIds are handled", function()
            local quests = {
                [10] = { triggerEnd = { "Some trigger", {[1519]={{51,27}}, [12]={{32,49}}} } },
            }

            local invalidQuests = Validators.checkQuestTriggerEndSpawnAreaIds(quests, questKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report quests without triggerEnd", function()
            local quests = {
                [10] = { requiredRaces = 18875469 },
            }

            local invalidQuests = Validators.checkQuestTriggerEndSpawnAreaIds(quests, questKeys, getUiMapIdByAreaId)

            assert.are_same(nil, invalidQuests)
            assert.spy(exitMock).was.not_called()
        end)
    end)

    describe("checkObjectFieldTypes", function()
        it("should not report anything when all object fields have correct types", function()
            local objects = {
                [1] = {
                    name = "Treasure Chest",
                    questStarts = {10, 20},
                    questEnds = {30},
                    spawns = {[1519] = {{51.2, 27.4}}},
                    zoneID = 1519,
                    factionID = 0,
                    waypoints = {[1519] = {{{51.2, 27.4}, {52.0, 28.0}}}},
                },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same(nil, invalidObjects)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report anything when optional fields are nil", function()
            local objects = {
                [1] = { name = "Simple Object" },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same(nil, invalidObjects)
            assert.spy(exitMock).was.not_called()
        end)

        it("should find object with missing name", function()
            local objects = {
                [1] = {},
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "field 'name' is required but nil" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with name that is not a string", function()
            local objects = {
                [1] = { name = 42 },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "field 'name' expected string but got number" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with questStarts that is not a table", function()
            local objects = {
                [1] = { name = "Chest", questStarts = "invalid" },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "field 'questStarts' expected table but got string" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with questEnds that is not a table", function()
            local objects = {
                [1] = { name = "Chest", questEnds = 99 },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "field 'questEnds' expected table but got number" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with spawns that is not a table", function()
            local objects = {
                [1] = { name = "Chest", spawns = "not a table" },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "field 'spawns' expected table but got string" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with spawn coord pair that is not a table", function()
            local objects = {
                [1] = { name = "Chest", spawns = {[1519] = {51.2, 27.4}} },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "spawns[1519][1] expected table (coord pair) but got number" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with zoneID that is not a number", function()
            local objects = {
                [1] = { name = "Chest", zoneID = "Stormwind" },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "field 'zoneID' expected number but got string" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with factionID that is not a number", function()
            local objects = {
                [1] = { name = "Chest", factionID = true },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "field 'factionID' expected number but got boolean" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with waypoints that is not a table", function()
            local objects = {
                [1] = { name = "Chest", waypoints = 12345 },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "field 'waypoints' expected table but got number" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find object with waypoints coord pair that is not a table", function()
            local objects = {
                [1] = { name = "Chest", waypoints = {[1519] = {{51.2, 27.4}, {52.0, 28.0}}} },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({ [1] = "waypoints[1519][1][1] expected table (coord pair) but got number" }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find multiple objects with invalid field types", function()
            local objects = {
                [1] = { name = nil },
                [2] = { name = "Chest", zoneID = "wrong" },
            }

            local invalidObjects = Validators.checkObjectFieldTypes(objects, objectKeys)

            assert.are_same({
                [1] = "field 'name' is required but nil",
                [2] = "field 'zoneID' expected number but got string",
            }, invalidObjects)
            assert.spy(exitMock).was.called_with(1)
        end)
    end)

    describe("checkItemFieldTypes", function()
        it("should not report anything when all item fields have correct types", function()
            local items = {
                [1] = {
                    name = "Hearthstone",
                    npcDrops = {100, 200},
                    objectDrops = {10, 20},
                    itemDrops = {5, 6},
                    startQuest = 42,
                    questRewards = {1, 2, 3},
                    flags = 0,
                    foodType = 2,
                    itemLevel = 1,
                    requiredLevel = 1,
                    ammoType = 0,
                    class = 12,
                    subClass = 0,
                    vendors = {300, 400},
                    relatedQuests = {7, 8},
                    teachesSpell = 9999,
                },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same(nil, invalidItems)
            assert.spy(exitMock).was.not_called()
        end)

        it("should not report anything when optional fields are nil", function()
            local items = {
                [1] = { name = "Simple Item" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same(nil, invalidItems)
            assert.spy(exitMock).was.not_called()
        end)

        it("should find item with missing name", function()
            local items = {
                [1] = { name = nil},
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'name' is required but nil" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with name that is not a string", function()
            local items = {
                [1] = { name = 123 },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'name' expected string but got number" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with npcDrops that is not a table", function()
            local items = {
                [1] = { name = "Item", npcDrops = 5 },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'npcDrops' expected table but got number" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with objectDrops that is not a table", function()
            local items = {
                [1] = { name = "Item", objectDrops = "invalid" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'objectDrops' expected table but got string" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with itemDrops that is not a table", function()
            local items = {
                [1] = { name = "Item", itemDrops = true },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'itemDrops' expected table but got boolean" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with startQuest that is not a number", function()
            local items = {
                [1] = { name = "Item", startQuest = "42" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'startQuest' expected number but got string" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with questRewards that is not a table", function()
            local items = {
                [1] = { name = "Item", questRewards = 99 },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'questRewards' expected table but got number" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with flags that is not a number", function()
            local items = {
                [1] = { name = "Item", flags = {} },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'flags' expected number but got table" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with foodType that is not a number", function()
            local items = {
                [1] = { name = "Item", foodType = "bread" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'foodType' expected number but got string" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with itemLevel that is not a number", function()
            local items = {
                [1] = { name = "Item", itemLevel = "high" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'itemLevel' expected number but got string" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with requiredLevel that is not a number", function()
            local items = {
                [1] = { name = "Item", requiredLevel = true },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'requiredLevel' expected number but got boolean" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with ammoType that is not a number", function()
            local items = {
                [1] = { name = "Item", ammoType = "arrow" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'ammoType' expected number but got string" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with class that is not a number", function()
            local items = {
                [1] = { name = "Item", class = "weapon" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'class' expected number but got string" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with subClass that is not a number", function()
            local items = {
                [1] = { name = "Item", subClass = {} },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'subClass' expected number but got table" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with vendors that is not a table", function()
            local items = {
                [1] = { name = "Item", vendors = 500 },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'vendors' expected table but got number" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with relatedQuests that is not a table", function()
            local items = {
                [1] = { name = "Item", relatedQuests = "quest" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'relatedQuests' expected table but got string" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find item with teachesSpell that is not a number", function()
            local items = {
                [1] = { name = "Item", teachesSpell = "fireball" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({ [1] = "field 'teachesSpell' expected number but got string" }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)

        it("should find multiple items with invalid field types", function()
            local items = {
                [1] = {},
                [2] = { name = "Item", requiredLevel = "ten" },
            }

            local invalidItems = Validators.checkItemFieldTypes(items, itemKeys)

            assert.are_same({
                [1] = "field 'name' is required but nil",
                [2] = "field 'requiredLevel' expected number but got string",
            }, invalidItems)
            assert.spy(exitMock).was.called_with(1)
        end)
    end)
end)
