dofile("setupTests.lua")

describe("Townsfolk", function()

    ---@type Townsfolk
    local Townsfolk

    ---@type QuestieDB
    local QuestieDB

    local factionIds = {
        InvalidFaction = 0,
        NeutralFaction1 = 1,
        NeutralFaction2 = 2,
        NeutralFaction3 = 3,
        HordeFaction1 = 4,
        HordeFaction2 = 5,
        NeutralFaction4 = 6,
        NeutralFaction5 = 7,
        AllianceFaction1 = 8,
        AllianceFaction2 = 9,
    }

    before_each(function()
        _G["Questie"] = {db={profile={}},IsClassic=true, Debug = function() end}
        QuestieDB = require("Database.QuestieDB")
        QuestieDB.objectKeys = {factionID = "factionID"}
        QuestieDB.factionTemplate = {
            [factionIds.NeutralFaction1] = 1,
            [factionIds.HordeFaction1] = 2,
            [factionIds.HordeFaction2] = 3,
            [factionIds.AllianceFaction1] = 4,
            [factionIds.AllianceFaction2] = 5,
            [factionIds.NeutralFaction4] = 6,
            [factionIds.NeutralFaction5] = 12,
            [factionIds.NeutralFaction3] = 16,
        }
        QuestieDB.objectData = {
            [1] = {factionID = factionIds.NeutralFaction1},
            [2] = {factionID = factionIds.NeutralFaction2},
            [3] = {factionID = factionIds.NeutralFaction3},
            [4] = {factionID = factionIds.HordeFaction1},
            [5] = {factionID = factionIds.HordeFaction2},
            [6] = {factionID = factionIds.NeutralFaction4},
            [7] = {factionID = factionIds.NeutralFaction5},
            [8] = {factionID = factionIds.AllianceFaction1},
            [9] = {factionID = factionIds.AllianceFaction2},
        }

        Townsfolk = require("Modules.QuestieMenu.Townsfolk")
    end)

    describe("Townsfolk.GetFactionSpecificMailboxes", function()
        it("should correctly filter mailboxes by faction", function()
            Townsfolk.GetMailboxes = function()
                return {1, 2, 3, 4, 5, 6, 7, 8, 9}
            end

            local allianceMailboxes, hordeMailboxes = Townsfolk.GetFactionSpecificMailboxes()

            assert.are.same({1, 2, 3, 6, 7, 8, 9}, allianceMailboxes)
            assert.are.same({1, 2, 3, 4, 5, 6, 7}, hordeMailboxes)
        end)

        it("should not add mailbox if it is not in the DB", function()
            Townsfolk.GetMailboxes = function()
                return {10, 11, 12} -- Non-existent mailboxes
            end

            local allianceMailboxes, hordeMailboxes = Townsfolk.GetFactionSpecificMailboxes()

            assert.are.same({}, allianceMailboxes)
            assert.are.same({}, hordeMailboxes)
        end)
    end)
end)
