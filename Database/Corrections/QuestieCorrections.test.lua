dofile("setupTests.lua")

describe("QuestieCorrections", function()
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type Expansions
    local Expansions

    local originalExpansion
    local originalIsHardcore
    local originalIsTitanReforged

    before_each(function()
        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        originalIsHardcore = Questie.IsHardcore
        originalIsTitanReforged = Questie.IsTitanReforged

        Expansions.Current = Expansions.Era
        Questie.IsHardcore = false
        Questie.IsTitanReforged = false
        Questie.db.global.isleOfQuelDanasPhase = 1

        local BlacklistFilter = QuestieLoader:ImportModule("BlacklistFilter")
        BlacklistFilter.filterExpansion = function(blacklist)
            for id, hide in pairs(blacklist) do
                if hide == false then
                    blacklist[id] = nil
                end
            end
            return blacklist
        end

        local QuestieItemBlacklist = QuestieLoader:ImportModule("QuestieItemBlacklist")
        QuestieItemBlacklist.Load = function() return {[101] = true, [102] = false} end

        local QuestieNPCBlacklist = QuestieLoader:ImportModule("QuestieNPCBlacklist")
        QuestieNPCBlacklist.Load = function() return {[201] = true, [202] = false} end

        local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
        QuestieQuestBlacklist.Load = function() return {[301] = true, [302] = false} end
        QuestieQuestBlacklist.LoadAutoBlacklistWotlk = function() return {} end
        QuestieQuestBlacklist.LoadAutoBlacklistIsTitanReforged = function() return {} end

        local HardcoreBlacklist = QuestieLoader:ImportModule("HardcoreBlacklist")
        HardcoreBlacklist.Load = function() return {} end

        local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
        IsleOfQuelDanas.MAX_ISLE_OF_QUEL_DANAS_PHASES = 9
        IsleOfQuelDanas.quests = {
            [9] = {},
        }

        dofile("Database/Corrections/QuestieCorrections.lua")
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
    end)

    after_each(function()
        Expansions.Current = originalExpansion
        Questie.IsHardcore = originalIsHardcore
        Questie.IsTitanReforged = originalIsTitanReforged
    end)

    it("builds expansion-filtered Quest, NPC, and Item blacklists", function()
        QuestieCorrections.Initialize()

        assert.are_same({[101] = true}, QuestieCorrections.questItemBlacklist)
        assert.are_same({[201] = true}, QuestieCorrections.questNPCBlacklist)
        assert.are_same({[301] = true}, QuestieCorrections.hiddenQuests)
    end)

    it("merges the completed Isle of Quel'Danas phase without overriding existing policy", function()
        local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
        QuestieQuestBlacklist.Load = function() return {[401] = "HIDE_ON_MAP"} end
        local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
        IsleOfQuelDanas.quests[9] = {
            [401] = true,
            [402] = false,
        }
        Questie.db.global.isleOfQuelDanasPhase = 9

        QuestieCorrections.Initialize()

        assert.are_same("HIDE_ON_MAP", QuestieCorrections.hiddenQuests[401])
        assert.is_false(QuestieCorrections.hiddenQuests[402])
    end)

    it("adds WotLK and Titan blacklists without overriding existing policy", function()
        Expansions.Current = Expansions.Wotlk
        Questie.IsTitanReforged = true
        local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
        QuestieQuestBlacklist.Load = function() return {[501] = "HIDE_ON_MAP"} end
        QuestieQuestBlacklist.LoadAutoBlacklistWotlk = function()
            return {[501] = true, [502] = true}
        end
        QuestieQuestBlacklist.LoadAutoBlacklistIsTitanReforged = function()
            return {[502] = false, [503] = true}
        end

        QuestieCorrections.Initialize()

        assert.are_same("HIDE_ON_MAP", QuestieCorrections.hiddenQuests[501])
        assert.is_true(QuestieCorrections.hiddenQuests[502])
        assert.is_true(QuestieCorrections.hiddenQuests[503])
    end)

    it("lets Hardcore policy hide quests regardless of earlier visibility policy", function()
        Questie.IsHardcore = true
        local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
        QuestieQuestBlacklist.Load = function() return {[601] = "HIDE_ON_MAP"} end
        local HardcoreBlacklist = QuestieLoader:ImportModule("HardcoreBlacklist")
        HardcoreBlacklist.Load = function() return {[601] = true, [602] = true} end

        QuestieCorrections.Initialize()

        assert.is_true(QuestieCorrections.hiddenQuests[601])
        assert.is_true(QuestieCorrections.hiddenQuests[602])
    end)
end)
