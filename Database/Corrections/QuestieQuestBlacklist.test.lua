dofile("setupTests.lua")

dofile("Database/Corrections/ContentPhases/Anniversary.lua")
dofile("Database/Corrections/ContentPhases/SeasonOfMastery.lua")
dofile("Database/Corrections/ContentPhases/SeasonOfDiscovery.lua")

dofile("Database/Corrections/ContentPhases/ContentPhases.lua")
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")
dofile("Database/Corrections/QuestieQuestBlacklist.lua")
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")

describe("QuestieQuestBlacklist", function()
    before_each(function()
        _G.GetLocale = function() return "enUS" end
        Questie.IsSoD = false
        Questie.IsTBC = false
        Questie.IsMoP = false
        Questie.IsTitanReforged = false
    end)

    it("does not use the general blacklist to isolate Titan-only quests", function()
        local titanQuestIds = {
            93950, 93975, 94376, 94576, 94577, 94579, 95037, 95072, 95074, 95075, 95076, 95077,
            95078, 95079, 95080, 95081, 95082, 95083, 95084, 95085, 95088, 95089, 95090, 95092,
            95093, 95094, 95095, 95096, 95097, 95098, 95099, 95100, 95101, 95102, 95103, 95104,
            95105, 95106, 95205, 95705, 95706, 95844, 95845, 96211, 96312, 96315, 96318, 98183,
        }

        local generalBlacklist = QuestieQuestBlacklist:Load()

        for _, questId in ipairs(titanQuestIds) do
            assert.is_nil(generalBlacklist[questId], "Titan quest unexpectedly remains in the general blacklist: " .. questId)
        end
    end)

    it("keeps unreleased Titan raid weeklies in the Titan blacklist", function()
        local titanBlacklist = QuestieQuestBlacklist.LoadAutoBlacklistIsTitanReforged()

        assert.is_true(titanBlacklist[96315])
        assert.is_true(titanBlacklist[96318])
    end)

    it("should blacklist SoD quests which are never available", function()
        Questie.IsSoD = true

        local questToBlacklist = QuestieQuestBlacklist:Load()

        assert.is_true(questToBlacklist[971]) -- Blackfathom Deeps
        assert.is_true(questToBlacklist[2841]) -- Gnomeregan
        assert.is_true(questToBlacklist[1446]) -- Sunken Temple
        assert.is_true(questToBlacklist[1203]) -- Jarl Needs a Blade - Replaced by 81570
        assert.is_true(questToBlacklist[1878]) -- Water Pouch Bounty - Replaced by 82209
    end)

    it("should blacklist Classic Anniversary quests", function()
        Questie.IsSoM = false
        Questie.IsSoD = false
        Questie.IsAnniversaryEra = true
        ContentPhases.activePhases.Anniversary = 3

        local questToBlacklist = QuestieQuestBlacklist:Load()

        assert.is_false(questToBlacklist[7877]) -- Phase 2
        assert.is_nil(questToBlacklist[7761]) -- Phase 3
        assert.is_true(questToBlacklist[8056]) -- Phase 4
        assert.is_true(questToBlacklist[8277]) -- Phase 5
        assert.is_true(questToBlacklist[9085]) -- Phase 6
    end)

    it("should blacklist Classic Anniversary quests", function()
        Questie.IsSoM = false
        Questie.IsSoD = false
        Questie.IsAnniversaryEra = false
        Questie.IsAnniversaryHardcore = true
        ContentPhases.activePhases.Anniversary = 3

        local questToBlacklist = QuestieQuestBlacklist:Load()

        assert.is_false(questToBlacklist[7877]) -- Phase 2
        assert.is_nil(questToBlacklist[7761]) -- Phase 3
        assert.is_true(questToBlacklist[8056]) -- Phase 4
        assert.is_true(questToBlacklist[8277]) -- Phase 5
        assert.is_true(questToBlacklist[9085]) -- Phase 6
    end)

    it("should blacklist SoM quests", function()
        Questie.IsSoM = true
        Questie.IsSoD = false
        Questie.IsAnniversaryEra = false
        ContentPhases.activePhases.SoM = 3

        local questToBlacklist = QuestieQuestBlacklist:Load()

        assert.is_nil(questToBlacklist[7761]) -- Phase 3
        assert.is_true(questToBlacklist[8056]) -- Phase 4
        assert.is_true(questToBlacklist[8277]) -- Phase 5
        assert.is_true(questToBlacklist[9085]) -- Phase 6
    end)
end)
