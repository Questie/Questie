dofile("setupTests.lua")

describe("QuestieOptionsDefaults", function()
    ---@type QuestieOptionsDefaults
    local QuestieOptionsDefaults

    before_each(function()
        dofile("Modules/Options/QuestieOptionsDefaults.lua")
        QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
    end)

    describe("Load", function()
        -- AvailableQuests.Initialize and QuestieLib.DidDailyResetHappenSinceLastLogin index these by realm name on login,
        -- so AceDB must always create them, even when the migrations that used to create them did not run (#8545)
        it("should default the realm-keyed daily quest tables in global", function()
            local defaults = QuestieOptionsDefaults:Load()

            assert.are_same({}, defaults.global.unavailableQuestsDeterminedByTalking)
            assert.are_same({}, defaults.global.unavailableDailyQuestsByNpc)
            assert.are_same({}, defaults.global.lastKnownDailyReset)
        end)
    end)
end)
