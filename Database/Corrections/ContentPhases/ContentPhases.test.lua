dofile("setupTests.lua")
dofile("Database/Corrections/ContentPhases/Classic.lua")

describe("ContentPhases", function()

    ---@type ContentPhases
    local ContentPhases

    before_each(function()
        ContentPhases = require("Database.Corrections.ContentPhases.ContentPhases")
    end)

    describe("BlacklistClassicQuestsByPhase", function()
        it("should blacklist correct quests for phase 1", function()
            local questToBlacklist = ContentPhases.BlacklistClassicQuestsByPhase({}, 1)

            assert.is_true(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 2", function()
            local questToBlacklist = ContentPhases.BlacklistClassicQuestsByPhase({}, 2)

            assert.is_true(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 3", function()
            local questToBlacklist = ContentPhases.BlacklistClassicQuestsByPhase({}, 3)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 4", function()
            local questToBlacklist = ContentPhases.BlacklistClassicQuestsByPhase({}, 4)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_nil(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 5", function()
            local questToBlacklist = ContentPhases.BlacklistClassicQuestsByPhase({}, 5)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_nil(questToBlacklist[8411]) -- Phase 4
            assert.is_nil(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 6", function()
            local questToBlacklist = ContentPhases.BlacklistClassicQuestsByPhase({}, 6)

            assert.same({}, questToBlacklist)
        end)
    end)
end)
