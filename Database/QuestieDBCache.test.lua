dofile("setupTests.lua")

describe("QuestieDBCache", function()
    ---@type QuestieDBCache
    local QuestieDBCache

    before_each(function()
        Questie.IsSoD = false
        Questie.IsTitanReforged = false
        Questie.db.global.sod = {name = "sod", dbIsCompiled = true}
        Questie.db.global.titanReforged = {name = "titan", dbIsCompiled = true}
        Questie.db.global.name = "standard"
        Questie.db.global.dbIsCompiled = true

        dofile("Database/QuestieDBCache.lua")
        QuestieDBCache = QuestieLoader:ImportModule("QuestieDBCache")
    end)

    it("uses the standard database for normal clients", function()
        assert.are_same(Questie.db.global, QuestieDBCache.GetActiveStorage())
    end)

    it("uses the SoD database for Season of Discovery", function()
        Questie.IsSoD = true

        assert.are_same(Questie.db.global.sod, QuestieDBCache.GetActiveStorage())
    end)

    it("uses the Titan database for Titan Reforged", function()
        Questie.IsTitanReforged = true

        assert.are_same(Questie.db.global.titanReforged, QuestieDBCache.GetActiveStorage())
    end)

    it("keeps SoD selection ahead of Titan selection", function()
        Questie.IsSoD = true
        Questie.IsTitanReforged = true

        assert.are_same(Questie.db.global.sod, QuestieDBCache.GetActiveStorage())
    end)

    it("invalidates only the active database", function()
        Questie.IsTitanReforged = true

        QuestieDBCache.InvalidateActiveStorage()

        assert.is_false(Questie.db.global.titanReforged.dbIsCompiled)
        assert.is_true(Questie.db.global.sod.dbIsCompiled)
        assert.is_true(Questie.db.global.dbIsCompiled)
    end)
end)
