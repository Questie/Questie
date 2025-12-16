dofile("setupTests.lua")

describe("AvailableQuests", function()
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestieLib
    local QuestieLib

    ---@type AvailableQuests
    local AvailableQuests

    before_each(function()
        ZoneDB = require("Database.Zones.zoneDB")
        QuestieLib = require("Modules.Libs.QuestieLib")

        AvailableQuests = require("Modules.Quest.AvailableQuests.AvailableQuests")
    end)

    describe("Initialize", function()
        it("should correct initialize", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            Questie.db.global.unavailableQuestsDeterminedByTalking = {}

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
        end)

        it("should reset unavailableQuestsDeterminedByTalking when a daily reset happened", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            QuestieLib.DidDailyResetHappenSinceLastLogin = function() return true end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[1234] = true},
            }

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
        end)

        it("should not reset unavailableQuestsDeterminedByTalking when no daily reset happened", function()
            ZoneDB.GetDungeons = spy.new(function() return {} end)
            _G.UnitFactionGroup = spy.new(function() return "Horde" end)
            _G.GetRealmName = spy.new(function() return "Ook Ook" end)
            QuestieLib.DidDailyResetHappenSinceLastLogin = function() return false end
            Questie.db.global.unavailableQuestsDeterminedByTalking = {
                ["Ook Ook"] = {[1234] = true},
            }

            AvailableQuests.Initialize()

            assert.spy(ZoneDB.GetDungeons).was.called()
            assert.spy(_G.UnitFactionGroup).was.called()
            assert.spy(_G.GetRealmName).was.called()
            assert.are_same({["Ook Ook"] = {[1234] = true}}, Questie.db.global.unavailableQuestsDeterminedByTalking)
        end)
    end)
end)
