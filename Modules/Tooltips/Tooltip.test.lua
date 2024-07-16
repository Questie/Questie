dofile("setupTests.lua")

require("Modules.Network.QuestieComms")

describe("Tooltip", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieTooltips
    local QuestieTooltips

    local objective = {
        hasRegisteredTooltips = true,
        registeredItemTooltips = true,
    }
    local specialObjective = {
        hasRegisteredTooltips = true,
        registeredItemTooltips = true,
    }

    before_each(function()
        Questie.db.profile = {}

        QuestieDB = require("Database.QuestieDB")
        QuestieDB.GetQuest = spy.new(function(questId)
            return {
                Id = questId,
                Objectives = {
                    [1] = objective,
                },
                SpecialObjectives = {
                    [1] = specialObjective,
                },
            }
        end)
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieLib.GetColoredQuestName = spy.new(function()
            return "Quest Name"
        end)
        QuestieLib.GetRGBForObjective = spy.new(function()
            return "gold"
        end)
        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestieTooltips = require("Modules.Tooltips.Tooltip")
    end)

    describe("GetTooltip", function()
        it("should return quest name when tooltip has name set and showQuestsInNpcTooltip is active", function()
            Questie.db.profile.showQuestsInNpcTooltip = true
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name"}, tooltip)
        end)

        it("should return empty tooltip when tooltip has name set but showQuestsInNpcTooltip is not active", function()
            Questie.db.profile.showQuestsInNpcTooltip = false
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_not_called()
            assert.are.same({}, tooltip)
        end)

        it("should return quest name and objective when tooltip has spell objective", function()
            QuestieDB.QueryItemSingle = spy.new(function()
                return "Item Name"
            end)
            QuestieTooltips.lookupByKey = {["m_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Type = "spell",
                    Update = function() end,
                    spawnList = {[123] = {ItemId = 5}}
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips.GetTooltip("m_123")

            assert.spy(QuestieDB.QueryItemSingle).was_called_with(5, "name")
            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name", "   goldItem Name"}, tooltip)
        end)

        it("should return quest name and objective when tooltip has objective and Needed", function()
            QuestieTooltips.lookupByKey = {["key"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Needed = 5,
                    Collected = 3,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name", "   gold3/5 do it"}, tooltip)
        end)

        it("should return quest name and objective description when tooltip has objective without Needed", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestieDB.QueryObjectSingle = spy.new(function()
                return {[440]={{10,10}}}
            end)
            QuestiePlayer.GetCurrentZoneId = spy.new(function()
                return 440
            end)

            local tooltip = QuestieTooltips.GetTooltip("o_123")

            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name", "   golddo it"}, tooltip)
            assert.spy(QuestieDB.QueryObjectSingle).was_called_with(123, "spawns")
            assert.spy(QuestiePlayer.GetCurrentZoneId).was_called_with(QuestiePlayer)
        end)

        it("should return nil for objects which are not in the zone of the player", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {
                ["1 1"] = {questId = 1, name = "test", starterId = 2},
            }}
            QuestieDB.QueryObjectSingle = spy.new(function()
                return {[1]={{10,10}}}
            end)
            QuestiePlayer.GetCurrentZoneId = spy.new(function()
                return 440
            end)

            local tooltip = QuestieTooltips.GetTooltip("o_123")

            assert.is_nil(tooltip)
            assert.spy(QuestieDB.QueryObjectSingle).was_called_with(123, "spawns")
            assert.spy(QuestiePlayer.GetCurrentZoneId).was_called_with(QuestiePlayer)
        end)

        it("should only return quest name when tooltip has completed objective and showQuestsInNpcTooltip is true", function()
            Questie.db.profile.showQuestsInNpcTooltip = true
            QuestieTooltips.lookupByKey = {["key"] = {
                ["1 test 2"] = {
                    questId = 1,
                    name = "test",
                    starterId = 2
                },
                ["1 1"] = {
                    questId = 1,
                    objective = {
                        Index = 1,
                        Needed = 3,
                        Collected = 3,
                        Description = "do it",
                        Update = function() end,
                    }
                }
            }}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name"}, tooltip)
        end)

        it("should return quest name and objective description when tooltip has completed objective and showQuestsInNpcTooltip is false", function()
            Questie.db.profile.showQuestsInNpcTooltip = false
            QuestieTooltips.lookupByKey = {["key"] = {
                ["1 test 2"] = {
                    questId = 1,
                    name = "test",
                    starterId = 2
                },
                ["1 1"] = {
                    questId = 1,
                    objective = {
                        Index = 1,
                        Needed = 5,
                        Collected = 3,
                        Description = "do it",
                        Update = function() end,
                    }
                }
            }}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name", "   gold3/5 do it"}, tooltip)
        end)

        it("should return multiple objectives for same key", function()
            QuestieLib.GetColoredQuestName = spy.new(function(_, questId)
                 if questId == 1 then return "Quest Name" else return "Quest Name 2" end
            end)
            QuestieTooltips.lookupByKey = {["key"] = {
                ["1 1"] = {
                    questId = 1,
                    objective = {
                        Index = 1,
                        Needed = 5,
                        Collected = 3,
                        Description = "do it",
                        Update = function() end,
                    }
                },
                ["1 2"] = {
                    questId = 1,
                    objective = {
                        Index = 2,
                        Needed = 1,
                        Collected = 0,
                        Description = "do something else",
                        Update = function() end,
                    }
                },
                ["2 1"] = {
                    questId = 2,
                    objective = {
                        Index = 1,
                        Needed = 10,
                        Collected = 10,
                        Description = "do something",
                        Update = function() end,
                    }
                }
            }}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestiePlayer.currentQuestlog[2] = {}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 2, nil, true, true)
            assert.are.same({
                "Quest Name", "   gold0/1 do something else", "   gold3/5 do it",
                "Quest Name 2", "   gold10/10 do something"
            }, tooltip)
        end)

        it("should not Update objective for IsSourceItem", function()
            local updateSpy = spy.new(function() end)
            QuestieTooltips.lookupByKey = {["key"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Needed = 5,
                    Collected = 3,
                    Description = "do it",
                    IsSourceItem = true,
                    Update = updateSpy,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            QuestieTooltips.GetTooltip("key")

            assert.spy(updateSpy).was_not_called()
        end)

        it("should not Update objective for IsRequiredSourceItem", function()
            local updateSpy = spy.new(function() end)
            QuestieTooltips.lookupByKey = {["key"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Needed = 5,
                    Collected = 3,
                    Description = "do it",
                    IsRequiredSourceItem = true,
                    Update = updateSpy,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            QuestieTooltips.GetTooltip("key")

            assert.spy(updateSpy).was_not_called()
        end)
    end)

    describe("RemoveQuest", function()
        it("should reset tooltip flags", function()
            QuestieTooltips.lookupKeysByQuestId = {[1] = {"key"}}
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            QuestieTooltips:RemoveQuest(1)

            assert.spy(QuestieDB.GetQuest).was_called_with(1)

            assert.are.same(false, objective.hasRegisteredTooltips)
            assert.are.same(false, objective.registeredItemTooltips)
            assert.are.same({}, objective.AlreadySpawned)

            assert.are.same(false, specialObjective.hasRegisteredTooltips)
            assert.are.same(false, specialObjective.registeredItemTooltips)
            assert.are.same({}, specialObjective.AlreadySpawned)

            assert.are.same({}, QuestieTooltips.lookupByKey)
            assert.are.same({}, QuestieTooltips.lookupKeysByQuestId)
        end)

        it("should do nothing when tooltip is already removed", function()
            QuestieTooltips.lookupKeysByQuestId = {[1] = {"key"}}

            QuestieTooltips:RemoveQuest(2)

            assert.spy(QuestieDB.GetQuest).was_not_called()
            assert.are.same({[1] = {"key"}}, QuestieTooltips.lookupKeysByQuestId)
        end)
    end)
end)
