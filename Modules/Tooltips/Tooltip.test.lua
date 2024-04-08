dofile("Modules/Libs/QuestieLoader.lua")

---@type ZoneDB
local ZoneDB = require("Database.Zones.zoneDB")
---@type QuestiePlayer
local QuestiePlayer = require("Modules.QuestiePlayer")

ZoneDB.zoneIDs = {ICECROWN = 210}
QuestiePlayer.numberOfGroupMembers = 0

_G.bit = {band = function() return 0 end}

_G.QUEST_MONSTERS_KILLED = ""
_G.QUEST_ITEMS_NEEDED = ""
_G.QUEST_OBJECTS_FOUND = ""
_G.C_QuestLog = {IsQuestFlaggedCompleted = function() return false end}
_G.IsInGroup = function() return false end
_G.UnitFactionGroup = function() return "Horde" end
_G.UnitName = function() return "Testi" end

describe("Tooltip", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieTooltips
    local QuestieTooltips
    ---@type QuestieLib
    local QuestieLib

    local objective = {
        hasRegisteredTooltips = true,
        registeredItemTooltips = true,
    }
    local specialObjective = {
        hasRegisteredTooltips = true,
        registeredItemTooltips = true,
    }

    before_each(function()
        -- Accessing _G["Questie"] is required
        _G["Questie"] = {db = {profile = {}}, Debug = function() end}
        Questie = _G["Questie"]

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
        it("should return tooltip lines if showQuestsInNpcTooltip is active", function()
            Questie.db.profile.showQuestsInNpcTooltip = true
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            local tooltip = QuestieTooltips:GetTooltip("key")

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
