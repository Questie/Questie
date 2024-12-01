dofile("setupTests.lua")
dofile("Database/Corrections/ContentPhases/Anniversary.lua")
dofile("Database/Corrections/ContentPhases/SeasonOfMastery.lua")
dofile("Database/Corrections/ContentPhases/SeasonOfDiscovery.lua")

describe("ContentPhases", function()

    ---@type ContentPhases
    local ContentPhases

    before_each(function()
        ContentPhases = require("Database.Corrections.ContentPhases.ContentPhases")
    end)

    describe("BlacklistAnniversaryQuestsByPhase", function()
        it("should blacklist correct quests for phase 1", function()
            local questToBlacklist = ContentPhases.BlacklistAnniversaryQuestsByPhase({}, 1)

            assert.is_true(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8905]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 2", function()
            local questToBlacklist = ContentPhases.BlacklistAnniversaryQuestsByPhase({}, 2)

            assert.is_true(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8905]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 3", function()
            local questToBlacklist = ContentPhases.BlacklistAnniversaryQuestsByPhase({}, 3)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8905]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 4", function()
            local questToBlacklist = ContentPhases.BlacklistAnniversaryQuestsByPhase({}, 4)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_nil(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8905]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 5", function()
            local questToBlacklist = ContentPhases.BlacklistAnniversaryQuestsByPhase({}, 5)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_nil(questToBlacklist[8411]) -- Phase 4
            assert.is_nil(questToBlacklist[8905]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 6", function()
            local questToBlacklist = ContentPhases.BlacklistAnniversaryQuestsByPhase({}, 6)

            assert.same({}, questToBlacklist)
        end)
    end)

    describe("BlacklistSoMQuestsByPhase", function()
        it("should blacklist correct quests for phase 1", function()
            local questToBlacklist = ContentPhases.BlacklistSoMQuestsByPhase({}, 1)

            assert.is_true(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 2", function()
            local questToBlacklist = ContentPhases.BlacklistSoMQuestsByPhase({}, 2)

            assert.is_true(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 3", function()
            local questToBlacklist = ContentPhases.BlacklistSoMQuestsByPhase({}, 3)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_true(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 4", function()
            local questToBlacklist = ContentPhases.BlacklistSoMQuestsByPhase({}, 4)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_nil(questToBlacklist[8411]) -- Phase 4
            assert.is_true(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 5", function()
            local questToBlacklist = ContentPhases.BlacklistSoMQuestsByPhase({}, 5)

            assert.is_nil(questToBlacklist[7761]) -- Phase 3
            assert.is_nil(questToBlacklist[8411]) -- Phase 4
            assert.is_nil(questToBlacklist[8277]) -- Phase 5
            assert.is_true(questToBlacklist[9085]) -- Phase 6
        end)

        it("should blacklist correct quests for phase 6", function()
            local questToBlacklist = ContentPhases.BlacklistSoMQuestsByPhase({}, 6)

            assert.same({}, questToBlacklist)
        end)
    end)

    describe("BlacklistSoDQuestsByPhase", function()
        it("should blacklist correct quests for phase 1", function()
            local questToBlacklist = ContentPhases.BlacklistSoDQuestsByPhase({}, 1)

            assert.is_true(questToBlacklist[1152]) -- Phase 2
            assert.is_true(questToBlacklist[2847]) -- Phase 3
            assert.is_true(questToBlacklist[4788]) -- Phase 5
            assert.is_true(questToBlacklist[8286]) -- Phase 6
            assert.is_true(questToBlacklist[9085]) -- Phase 7
            assert.is_true(questToBlacklist[1203]) -- Never available
        end)

        it("should blacklist correct quests for phase 2", function()
            local questToBlacklist = ContentPhases.BlacklistSoDQuestsByPhase({}, 2)

            assert.is_nil(questToBlacklist[1152]) -- Phase 2
            assert.is_true(questToBlacklist[2847]) -- Phase 3
            assert.is_true(questToBlacklist[4788]) -- Phase 5
            assert.is_true(questToBlacklist[8286]) -- Phase 6
            assert.is_true(questToBlacklist[9085]) -- Phase 7
            assert.is_true(questToBlacklist[1203]) -- Never available
        end)

        it("should blacklist correct quests for phase 3", function()
            local questToBlacklist = ContentPhases.BlacklistSoDQuestsByPhase({}, 3)

            assert.is_nil(questToBlacklist[1152]) -- Phase 2
            assert.is_nil(questToBlacklist[2847]) -- Phase 3
            assert.is_true(questToBlacklist[4788]) -- Phase 5
            assert.is_true(questToBlacklist[8286]) -- Phase 6
            assert.is_true(questToBlacklist[9085]) -- Phase 7
            assert.is_true(questToBlacklist[1203]) -- Never available
        end)

        it("should blacklist correct quests for phase 4", function()
            local questToBlacklist = ContentPhases.BlacklistSoDQuestsByPhase({}, 4)

            assert.is_nil(questToBlacklist[1152]) -- Phase 2
            assert.is_nil(questToBlacklist[2847]) -- Phase 3
            assert.is_true(questToBlacklist[4788]) -- Phase 5
            assert.is_true(questToBlacklist[8286]) -- Phase 6
            assert.is_true(questToBlacklist[9085]) -- Phase 7
            assert.is_true(questToBlacklist[1203]) -- Never available
        end)

        it("should blacklist correct quests for phase 5", function()
            local questToBlacklist = ContentPhases.BlacklistSoDQuestsByPhase({}, 5)

            assert.is_nil(questToBlacklist[1152]) -- Phase 2
            assert.is_nil(questToBlacklist[2847]) -- Phase 3
            assert.is_nil(questToBlacklist[4788]) -- Phase 5
            assert.is_true(questToBlacklist[8286]) -- Phase 6
            assert.is_true(questToBlacklist[9085]) -- Phase 7
            assert.is_true(questToBlacklist[1203]) -- Never available
        end)

        it("should blacklist correct quests for phase 6", function()
            local questToBlacklist = ContentPhases.BlacklistSoDQuestsByPhase({}, 6)

            assert.is_nil(questToBlacklist[1152]) -- Phase 2
            assert.is_nil(questToBlacklist[2847]) -- Phase 3
            assert.is_nil(questToBlacklist[4788]) -- Phase 5
            assert.is_nil(questToBlacklist[8286]) -- Phase 6
            assert.is_true(questToBlacklist[9085]) -- Phase 7
            assert.is_true(questToBlacklist[1203]) -- Never available
        end)

        it("should blacklist correct quests for phase 7", function()
            local questToBlacklist = ContentPhases.BlacklistSoDQuestsByPhase({}, 7)

            assert.is_nil(questToBlacklist[1152]) -- Phase 2
            assert.is_nil(questToBlacklist[2847]) -- Phase 3
            assert.is_nil(questToBlacklist[4788]) -- Phase 5
            assert.is_nil(questToBlacklist[8286]) -- Phase 6
            assert.is_nil(questToBlacklist[9085]) -- Phase 7
            assert.is_true(questToBlacklist[1203]) -- Never available
        end)
    end)
end)
