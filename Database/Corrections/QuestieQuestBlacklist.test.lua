dofile("setupTests.lua")

dofile("Database/Corrections/QuestieCorrections.lua")
dofile("Database/Corrections/SeasonOfDiscovery.lua")

local QuestieQuestBlacklist = require("Database.Corrections.QuestieQuestBlacklist")

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
end)
