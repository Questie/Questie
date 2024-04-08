dofile("setupTests.lua")

---@type ZoneDB
local ZoneDB = require("Database.Zones.zoneDB")
ZoneDB.zoneIDs = {ICECROWN = 210}

---@type QuestiePlayer
local QuestiePlayer = require("Modules.QuestiePlayer")

require("Modules.Network.QuestieComms")

describe("Tooltip", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieLib
    local QuestieLib
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
        QuestieTooltips = require("Modules.Tooltips.Tooltip")
    end)

    describe("GetTooltip", function()
        it("should return quest name when tooltip has name set and showQuestsInNpcTooltip is active", function()
            Questie.db.profile.showQuestsInNpcTooltip = true
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            local tooltip = QuestieTooltips:GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name"}, tooltip)
        end)

        it("should return empty tooltip when tooltip has name set but showQuestsInNpcTooltip is not active", function()
            Questie.db.profile.showQuestsInNpcTooltip = false
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            local tooltip = QuestieTooltips:GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_not_called()
            assert.are.same({}, tooltip)
        end)

        it("should return quest name and objective when tooltip has spell objective", function()
            QuestieDB.QueryItemSingle = spy.new(function()
                return "Item Name"
            end)
            QuestieTooltips.lookupByKey = {["m_123"] = {["1 test 2"] = {
                questId = 1,
                starterId = 2,
                objective = {
                    Index = 1,
                    Type = "spell",
                    Update = function() end,
                    spawnList = {[123] = {ItemId = 5}}
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips:GetTooltip("m_123")

            assert.spy(QuestieDB.QueryItemSingle).was_called_with(5, "name")
            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name", "   goldItem Name"}, tooltip)
        end)

        it("should return quest name and objective when tooltip has objective and Needed", function()
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {
                questId = 1,
                starterId = 2,
                objective = {
                    Index = 1,
                    Needed = 5,
                    Collected = 3,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips:GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was_called_with(QuestieLib, 1, nil, true, true)
            assert.are.same({"Quest Name", "   gold3/5 do it"}, tooltip)
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
