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
        assert.are_same(40, Questie.db.profile.migrationVersion)
    end)

    it("preserves tracker preferences when upgrading from version 37", function()
        Questie.db.profile.minimizeTrackerInDungeons = true
        Questie.db.profile.hideTrackerInDungeons = false

        Migration:Migrate()

        assert.is_true(Questie.db.profile.minimizeTrackerInInstances)
        assert.is_false(Questie.db.profile.hideTrackerInInstances)
        assert.is_nil(Questie.db.profile.minimizeTrackerInDungeons)
        assert.is_nil(Questie.db.profile.hideTrackerInDungeons)
        assert.are_same(40, Questie.db.profile.migrationVersion)
    end)

    it("clears compiler state without rerunning tracker migration from version 38", function()
        Questie.db.profile.migrationVersion = 38
        Questie.db.profile.minimizeTrackerInInstances = false
        Questie.db.profile.hideTrackerInInstances = true
        Questie.db.global.dbIsCompiled = true
        Questie.db.global.questBin = "quest"

        Migration:Migrate()

        assert.is_nil(Questie.db.global.dbIsCompiled)
        assert.is_nil(Questie.db.global.questBin)
        assert.is_nil(Questie.db.profile.disableDatabaseWarnings)
        assert.is_nil(Questie.db.char.townsfolkVersion)
        assert.is_false(Questie.db.profile.minimizeTrackerInInstances)
        assert.is_true(Questie.db.profile.hideTrackerInInstances)
        assert.are_same(40, Questie.db.profile.migrationVersion)
    end)

    it("clears Titan compiler payloads when the SoD scope is absent", function()
        Questie.db.profile.migrationVersion = 38
        Questie.db.global.titanReforged = {
            dbIsCompiled = true,
            questBin = "quest",
            retained = "keep",
        }

        Migration:Migrate()

        assert.are_same({retained = "keep"}, Questie.db.global.titanReforged)
        assert.is_nil(Questie.db.global.sod)
        assert.are_same(40, Questie.db.profile.migrationVersion)
    end)

    it("removes the Townsfolk lookups when upgrading from version 39", function()
        Questie.db.profile.migrationVersion = 39
        Questie.db.global.townsfolk = {Repair = {1001}}
        Questie.db.global.professionTrainers = {[1] = {2001}}
        Questie.db.global.classSpecificTownsfolk = {WARRIOR = {}}
        Questie.db.global.factionSpecificTownsfolk = {Horde = {}}
        Questie.db.global.petFoodVendorTypes = {Meat = {7001}}
        Questie.db.global.retained = "keep"

        Migration:Migrate()

        assert.are_same({retained = "keep"}, Questie.db.global)
        assert.are_same(40, Questie.db.profile.migrationVersion)
    end)

    it("handles Saved Variables without former seasonal compiler scopes", function()
        Questie.db.global.retained = true

        Migration:Migrate()

        assert.is_true(Questie.db.global.retained)
        assert.are_same(40, Questie.db.profile.migrationVersion)
    end)
end)
