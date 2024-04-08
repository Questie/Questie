dofile("setupTests.lua")

---@type QuestiePlayer
local QuestiePlayer = require("Modules.QuestiePlayer")

QuestiePlayer.numberOfGroupMembers = 0

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
