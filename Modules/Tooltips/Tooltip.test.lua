dofile("Modules/Libs/QuestieLoader.lua")

---@type ZoneDB
local ZoneDB = require("Database.Zones.zoneDB")

ZoneDB.zoneIDs = {ICECROWN = 210}
_G.bit = {band = function() return 0 end}
_G.C_QuestLog = {IsQuestFlaggedCompleted = function() return false end}
_G.Questie = {Debug = function() end}
_G.UnitFactionGroup = function() return "Horde" end

describe("Tooltip", function()
    describe("RemoveQuest", function()
        local QuestieDB, QuestieTooltips

        local objective = {
            hasRegisteredTooltips = true,
            registeredItemTooltips = true,
        }
        local specialObjective = {
            hasRegisteredTooltips = true,
            registeredItemTooltips = true,
        }

        before_each(function()
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
            QuestieTooltips = require("Modules.Tooltips.Tooltip")
        end)

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
