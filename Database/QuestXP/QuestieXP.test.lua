dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("QuestXP support data", function()
    local QuestXP, mock, playerLevel

    before_each(function()
        mock = LoadQuestieTDBMock()
        mock.supportModules.QuestXP.db = {[101] = {20, 1000}, [102] = {-1, 1000}, [103] = {20, 0}}
        playerLevel = 20
        _G.UnitLevel = function() return playerLevel end
        _G.GetMaxPlayerLevel = function() return 60 end
        _G.UnitAura = function() return nil end
        _G.IsSpellKnown = function() return false end
        _G.floor = math.floor
        Questie.IsSoD = false
        local Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Current = Expansions.Era
        dofile("Database/QuestXP/QuestieXP.lua")
        QuestXP = QuestieLoader:ImportModule("QuestXP")
    end)

    it("adjusts the published XP for player level without changing the shared row", function()
        assert.are_equal(mock.supportModules.QuestXP.db, QuestXP.db)
        assert.are_equal(1000, QuestXP:GetQuestLogRewardXP(101))
        playerLevel = 27
        assert.are_equal(600, QuestXP:GetQuestLogRewardXP(101))
        assert.are_same({20, 1000}, mock.supportModules.QuestXP.db[101])
    end)

    it("preserves max-level suppression and the ignorePlayerLevel option", function()
        playerLevel = 60
        assert.are_equal(0, QuestXP:GetQuestLogRewardXP(101))
        assert.are_equal(100, QuestXP:GetQuestLogRewardXP(101, true))
    end)

    it("returns zero for unknown quests, event levels and zero XP", function()
        assert.are_equal(0, QuestXP:GetQuestLogRewardXP(999))
        assert.are_equal(0, QuestXP:GetQuestLogRewardXP(102))
        assert.are_equal(0, QuestXP:GetQuestLogRewardXP(103))
    end)

    it("still applies the guild perk to provider XP", function()
        local Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Current = Expansions.Wotlk
        _G.IsSpellKnown = function(spellId) return spellId == 78632 end
        QuestXP.Init()
        assert.are_equal(1100, QuestXP:GetQuestLogRewardXP(101))
        assert.are_same({20, 1000}, mock.supportModules.QuestXP.db[101])
    end)
end)
