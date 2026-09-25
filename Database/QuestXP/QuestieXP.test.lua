dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("QuestXP support data", function()
    local QuestXP, mock, playerLevel

    before_each(function()
        QuestieLoader:ImportModule("SupportValidation").ValidateQuestXP = function() return true end
        mock = LoadQuestieDBMock()
        mock.supportModules.QuestXP.db = {[101] = {20, 1000}, [102] = {-1, 1000}, [103] = {20, 0}}
        playerLevel = 20
        _G.UnitLevel = function() return playerLevel end
        _G.GetMaxPlayerLevel = function() return 60 end
        _G.UnitAura = function() return nil end
        _G.IsSpellKnown = function() return false end
        _G.IsInInstance = function() return false end
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

    describe("temporary reward buffs", function()
        local originalInCombatLockdown, originalRewardMoney, originalUnitAura, originalIsForever

        before_each(function()
            originalInCombatLockdown = _G.InCombatLockdown
            originalRewardMoney = _G.GetQuestLogRewardMoney
            originalUnitAura = _G.UnitAura
            originalIsForever = Questie.IsForever
            Questie.IsForever = true
            _G.InCombatLockdown = function() return false end
            _G.UnitAura = spy.new(function(_, index)
                if index == 1 then return nil, nil, nil, nil, nil, nil, nil, nil, nil, 46668 end
            end)
        end)

        after_each(function()
            _G.InCombatLockdown = originalInCombatLockdown
            _G.GetQuestLogRewardMoney = originalRewardMoney
            _G.UnitAura = originalUnitAura
            Questie.IsForever = originalIsForever
        end)

        it("omits XP buff bonuses during Forever combat and reads buffs again afterward", function()
            assert.are.equal(1100, QuestXP:GetQuestLogRewardXP(101))
            _G.UnitAura:clear()
            _G.InCombatLockdown = function() return true end

            assert.are.equal(1000, QuestXP:GetQuestLogRewardXP(101))
            assert.spy(UnitAura).was.not_called()

            _G.InCombatLockdown = function() return false end
            assert.are.equal(1100, QuestXP:GetQuestLogRewardXP(101))
            assert.spy(UnitAura).was.called_with("player", 1, "HELPFUL")
        end)

        it("keeps Classic XP buff calculations active during combat", function()
            Questie.IsForever = false
            _G.InCombatLockdown = function() return true end

            assert.are.equal(1100, QuestXP:GetQuestLogRewardXP(101))
            assert.spy(UnitAura).was.called_with("player", 1, "HELPFUL")
        end)

        it("preserves SoD combat bonuses and quest exclusions", function()
            Questie.IsForever = false
            Questie.IsSoD = true
            _G.InCombatLockdown = function() return true end
            _G.GetQuestLogRewardMoney = function() return 100 end
            _G.UnitAura = function(_, index)
                if index == 1 then return nil, nil, nil, nil, nil, nil, nil, nil, nil, 436412 end
            end

            assert.are.equal(2500, QuestXP:GetQuestLogRewardXP(101))
            assert.are.equal(300, QuestXP.GetQuestRewardMoney(101))
            assert.are.equal(100, QuestXP.GetQuestRewardMoney(78612))
        end)
    end)

    it("reports missing support during initialization instead of failing to load", function()
        mock.supportModules.QuestXP = nil
        local validator = spy.new(function() return false, "Missing QuestXP support" end)
        QuestieLoader:ImportModule("SupportValidation").ValidateQuestXP = validator

        dofile("Database/QuestXP/QuestieXP.lua")
        local valid, report = QuestXP.Init()

        assert.is_nil(QuestXP.db)
        assert.is_false(valid)
        assert.are_equal("Missing QuestXP support", report)
        assert.spy(validator).was.called_with(nil, QuestieLoader:ImportModule("Expansions").Era)
    end)

    it("reports non-table support during initialization instead of failing to load", function()
        mock.supportModules.QuestXP = 42
        local validator = spy.new(function() return false, "Invalid QuestXP support" end)
        QuestieLoader:ImportModule("SupportValidation").ValidateQuestXP = validator

        dofile("Database/QuestXP/QuestieXP.lua")
        local valid, report = QuestXP.Init()

        assert.is_nil(QuestXP.db)
        assert.is_false(valid)
        assert.are_equal("Invalid QuestXP support", report)
        assert.spy(validator).was.called_with(nil, QuestieLoader:ImportModule("Expansions").Era)
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
    it("validates the bound raw XP even when debug is disabled and before reading player perks", function()
        Questie.db.profile.debugEnabled = false
        local bound = {[999] = {1, 2}}
        QuestXP.db = bound
        local validator = spy.new(function() return false, "XP report" end)
        QuestieLoader:ImportModule("SupportValidation").ValidateQuestXP = validator
        local perks = spy.new(function() return true end)
        _G.IsSpellKnown = perks
        QuestieLoader:ImportModule("Expansions").Current = 3
        local valid, report = QuestXP.Init()
        assert.is_false(valid)
        assert.are_equal("XP report", report)
        assert.spy(validator).was.called_with(bound, 3)
        assert.spy(perks).was.not_called()
        assert.are_same({[999] = {1, 2}}, bound)
        assert.are_not_equal(bound, mock.supportModules.QuestXP.db)
    end)

end)
