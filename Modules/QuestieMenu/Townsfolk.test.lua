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
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
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
        local objectFactions = {
            [1] = factionIds.NeutralFaction1,
            [2] = factionIds.NeutralFaction2,
            [3] = factionIds.NeutralFaction3,
            [4] = factionIds.HordeFaction1,
            [5] = factionIds.HordeFaction2,
            [6] = factionIds.NeutralFaction4,
            [7] = factionIds.NeutralFaction5,
            [8] = factionIds.AllianceFaction1,
            [9] = factionIds.AllianceFaction2,
        }
        QuestieDB.ObjectPointers = {}
        for objectId in pairs(objectFactions) do
            QuestieDB.ObjectPointers[objectId] = true
        end
        QuestieDB.QueryObjectSingle = function(objectId, field)
            if field == "factionID" then
                return objectFactions[objectId]
            end
        end

        dofile("Modules/QuestieMenu/Townsfolk.lua")
        Townsfolk = QuestieLoader:ImportModule("Townsfolk")
    end)

    describe("Townsfolk.GetFactionSpecificMailboxes", function()
        it("should correctly filter mailboxes by faction", function()
            Townsfolk.GetMailboxes = function()
                return {1, 2, 3, 4, 5, 6, 7, 8, 9}
            end

            local allianceMailboxes, hordeMailboxes = Townsfolk.GetFactionSpecificMailboxes()

            assert.are_same({1, 2, 3, 6, 7, 8, 9}, allianceMailboxes)
            assert.are_same({1, 2, 3, 4, 5, 6, 7}, hordeMailboxes)
        end)

        it("should not add mailbox if it is not in the DB", function()
            Townsfolk.GetMailboxes = function()
                return {10, 11, 12} -- Non-existent mailboxes
            end

            local allianceMailboxes, hordeMailboxes = Townsfolk.GetFactionSpecificMailboxes()

            assert.are_same({}, allianceMailboxes)
            assert.are_same({}, hordeMailboxes)
        end)
    end)
end)
