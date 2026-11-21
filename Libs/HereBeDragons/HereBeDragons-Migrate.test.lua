dofile("setupTests.lua")

describe("HereBeDragons-Migrate", function()
    it("registers as a Questie module and maps an old map area ID to its uiMapID", function()
        dofile("Libs/HereBeDragons/HereBeDragons-Migrate.lua")
        local HBDMigrate = QuestieLoader:ImportModule("HBDMigrate")

        -- Azeroth was map area 14 before uiMapIDs; it is uiMapID 13.
        assert.are_same(13, HBDMigrate:GetUIMapIDFromMapAreaId(14))
    end)
end)
