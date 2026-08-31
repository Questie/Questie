dofile("setupTests.lua")

describe("QuestieDBStorage", function()
    ---@type QuestieDBStorage
    local QuestieDBStorage

    before_each(function()
        Questie.IsSoD = false
        Questie.IsTitanReforged = false
        Questie.db.global.sod = {name = "sod", dbIsCompiled = true}
        Questie.db.global.titanReforged = {name = "titan", dbIsCompiled = true}
        Questie.db.global.name = "standard"
        Questie.db.global.dbIsCompiled = true

        dofile("Database/QuestieDBStorage.lua")
        QuestieDBStorage = QuestieLoader:ImportModule("QuestieDBStorage")
    end)

    it("uses the standard database for normal clients", function()
        assert.are_same(Questie.db.global, QuestieDBStorage.GetActiveStorage())
    end)

    it("uses the SoD database for Season of Discovery", function()
        Questie.IsSoD = true

        assert.are_same(Questie.db.global.sod, QuestieDBStorage.GetActiveStorage())
    end)

    it("uses the Titan database for Titan Reforged", function()
        Questie.IsTitanReforged = true

        assert.are_same(Questie.db.global.titanReforged, QuestieDBStorage.GetActiveStorage())
    end)

    it("keeps SoD selection ahead of Titan selection", function()
        Questie.IsSoD = true
        Questie.IsTitanReforged = true

        assert.are_same(Questie.db.global.sod, QuestieDBStorage.GetActiveStorage())
    end)

    it("invalidates only the active database", function()
        Questie.IsTitanReforged = true

        QuestieDBStorage.InvalidateActiveStorage()

        assert.is_false(Questie.db.global.titanReforged.dbIsCompiled)
        assert.is_true(Questie.db.global.sod.dbIsCompiled)
        assert.is_true(Questie.db.global.dbIsCompiled)
    end)
end)
