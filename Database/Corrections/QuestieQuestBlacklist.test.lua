dofile("setupTests.lua")

dofile("Database/Corrections/QuestieCorrections.lua")
dofile("Database/Corrections/ContentPhases/Anniversary.lua")
dofile("Database/Corrections/ContentPhases/SeasonOfMastery.lua")
dofile("Database/Corrections/ContentPhases/SeasonOfDiscovery.lua")

local QuestieQuestBlacklist = require("Database.Corrections.QuestieQuestBlacklist")
local ContentPhases = require("Database.Corrections.ContentPhases.ContentPhases")

describe("QuestieQuestBlacklist", function()
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
        Questie.IsAnniversary = true
        ContentPhases.activePhases.Anniversary = 3

        local questToBlacklist = QuestieQuestBlacklist:Load()

        assert.is_nil( questToBlacklist[7877]) -- Phase 2
        assert.is_nil(questToBlacklist[7761]) -- Phase 3
        assert.is_true(questToBlacklist[8411]) -- Phase 4
        assert.is_true(questToBlacklist[8277]) -- Phase 5
        assert.is_true(questToBlacklist[9085]) -- Phase 6
    end)

    it("should blacklist SoM quests", function()
        Questie.IsSoM = true
        Questie.IsSoD = false
        Questie.IsAnniversary = false
        ContentPhases.activePhases.SoM = 3

        local questToBlacklist = QuestieQuestBlacklist:Load()

        assert.is_nil(questToBlacklist[7761]) -- Phase 3
        assert.is_true(questToBlacklist[8411]) -- Phase 4
        assert.is_true(questToBlacklist[8277]) -- Phase 5
        assert.is_true(questToBlacklist[9085]) -- Phase 6
    end)
end)
