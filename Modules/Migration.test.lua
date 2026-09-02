dofile("setupTests.lua")

describe("Migration", function()
    ---@type Migration
    local Migration
    local originalQuestieDB

    before_each(function()
        originalQuestieDB = Questie.db
        Questie.db = {
            profile = {
                migrationVersion = 37,
                disableDatabaseWarnings = true,
            },
            global = {},
            char = {
                townsfolkVersion = 42,
            },
        }

        dofile("Modules/Migration.lua")
        Migration = QuestieLoader:ImportModule("Migration")
    end)

    after_each(function()
        Questie.db = originalQuestieDB
    end)

    it("clears compiler payloads from ordinary, SoD, and Titan scopes", function()
        local compilerPayload = {
            dbIsCompiled = true,
            dbCompiledOnVersion = "v1",
            dbCompiledLang = "deDE",
            dbCompiledExpansion = 1,
            dbCompiledCount = 2,
            npcBin = "npc",
            npcPtrs = {1},
            questBin = "quest",
            questPtrs = {2},
            objBin = "object",
            objPtrs = {3},
            itemBin = "item",
            itemPtrs = {4},
            retained = "keep",
        }
        Questie.db.global = {}
        Questie.db.global.sod = {}
        Questie.db.global.titanReforged = {}
        for key, value in pairs(compilerPayload) do
            Questie.db.global[key] = value
            Questie.db.global.sod[key] = value
            Questie.db.global.titanReforged[key] = value
        end

        Migration:Migrate()

        local expectedScope = {retained = "keep"}
        assert.are_same(expectedScope, Questie.db.global.sod)
        assert.are_same(expectedScope, Questie.db.global.titanReforged)
        Questie.db.global.sod = nil
        Questie.db.global.titanReforged = nil
        assert.are_same(expectedScope, Questie.db.global)
        assert.is_nil(Questie.db.profile.disableDatabaseWarnings)
        assert.is_nil(Questie.db.char.townsfolkVersion)
        assert.are_same(38, Questie.db.profile.migrationVersion)
    end)

    it("handles Saved Variables without former seasonal compiler scopes", function()
        Questie.db.global.retained = true

        Migration:Migrate()

        assert.is_true(Questie.db.global.retained)
        assert.are_same(38, Questie.db.profile.migrationVersion)
    end)
end)
