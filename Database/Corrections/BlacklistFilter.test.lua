dofile("setupTests.lua")

---@type BlacklistFilter
local BlacklistFilter

describe("BlacklistFilter", function()

    before_each(function()
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
    end)

    it("should remove blacklists", function()
        _G.Questie = {IsClassic = false, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
            [7] = BlacklistFilter.ERA_HIDE,
            [8] = BlacklistFilter.ANNIVERSARY_HIDE,
            [9] = false,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_nil(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
        assert.is_nil(result[7])
        assert.is_nil(result[8])
        assert.is_nil(result[9])
    end)

    it("should set true for Classic client and CLASSIC_HIDE", function()
        _G.Questie = {IsClassic = true, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
            [7] = BlacklistFilter.ERA_HIDE,
            [8] = BlacklistFilter.ANNIVERSARY_HIDE,
            [9] = false,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
        assert.is_nil(result[7])
        assert.is_nil(result[8])
        assert.is_nil(result[9])
    end)

    it("should set true for Era client and ERA_HIDE", function()
        _G.Questie = {IsClassic = true, IsEra = true, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
            [7] = BlacklistFilter.ERA_HIDE,
            [8] = BlacklistFilter.ANNIVERSARY_HIDE,
            [9] = false,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
        assert.is_true(result[7])
        assert.is_nil(result[8])
        assert.is_nil(result[9])
    end)

    it("should set true for TBC client and TBC_HIDE", function()
        _G.Questie = {IsClassic = false, IsEra = false, IsTBC = true, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
            [7] = BlacklistFilter.ERA_HIDE,
            [8] = BlacklistFilter.ANNIVERSARY_HIDE,
            [9] = false,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_nil(result[1])
        assert.is_true(result[2])
        assert.is_true(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
        assert.is_nil(result[7])
        assert.is_nil(result[8])
        assert.is_nil(result[9])
    end)

    it("should set true for Wotlk client and WOTLK_HIDE", function()
        _G.Questie = {IsClassic = false, IsEra = false, IsTBC = false, IsWotlk = true, IsSoD = false, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
            [7] = BlacklistFilter.ERA_HIDE,
            [8] = BlacklistFilter.ANNIVERSARY_HIDE,
            [9] = false,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_nil(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_true(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
        assert.is_nil(result[7])
        assert.is_nil(result[8])
        assert.is_nil(result[9])
    end)

    it("should set true for Cata client and CATA_HIDE", function()
        _G.Questie = {IsClassic = false, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = true, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
            [7] = BlacklistFilter.ERA_HIDE,
            [8] = BlacklistFilter.ANNIVERSARY_HIDE,
            [9] = false,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_nil(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_true(result[5])
        assert.is_nil(result[6])
        assert.is_nil(result[7])
        assert.is_nil(result[8])
        assert.is_nil(result[9])
    end)

    it("should set true for SoD client and SOD_HIDE", function()
        _G.Questie = {IsClassic = true, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = true, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
            [7] = BlacklistFilter.ERA_HIDE,
            [8] = BlacklistFilter.ANNIVERSARY_HIDE,
            [9] = false,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_true(result[6])
        assert.is_nil(result[7])
        assert.is_nil(result[8])
        assert.is_nil(result[9])
    end)

    it("should set true for Anniversary client and ANNIVERSARY_HIDE", function()
        _G.Questie = {IsClassic = true, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = true}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
            [7] = BlacklistFilter.ERA_HIDE,
            [8] = BlacklistFilter.ANNIVERSARY_HIDE,
            [9] = false,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
        assert.is_nil(result[7])
        assert.is_true(result[8])
        assert.is_nil(result[9])
    end)

    it("should set true for Classic client and CLASSIC_HIDE + SOD_HIDE", function()
        _G.Questie = {IsClassic = true, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE + BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
    end)

    it("should set true for SoD client and CLASSIC_HIDE + SOD_HIDE", function()
        _G.Questie = {IsClassic = true, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = true, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE + BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
    end)

    it("should set true for Classic client and CLASSIC_HIDE + TBC_HIDE", function()
        _G.Questie = {IsClassic = true, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE + BlacklistFilter.TBC_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
    end)

    it("should set true for Cata client and CLASSIC_HIDE + TBC_HIDE + WOTLK_HIDE + CATA_HIDE", function()
        _G.Questie = {IsClassic = false, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = true, IsAnniversary = false}
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE + BlacklistFilter.TBC_HIDE + BlacklistFilter.WOTLK_HIDE + BlacklistFilter.CATA_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
    end)

    describe("IsFlagged", function()
        it("should return false when flag is a boolean", function()
            _G.Questie = {IsClassic = false, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
            local flag = true

            local result = BlacklistFilter.IsFlagged(flag)

            assert.is_false(result)
        end)

        it("should return false when not matching client", function()
            _G.Questie = {IsClassic = false, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}

            local flag = BlacklistFilter.CLASSIC_HIDE
            local result = BlacklistFilter.IsFlagged(flag)
            assert.is_false(result)

            flag = BlacklistFilter.TBC_HIDE
            result = BlacklistFilter.IsFlagged(flag)
            assert.is_false(result)

            flag = BlacklistFilter.WOTLK_HIDE
            result = BlacklistFilter.IsFlagged(flag)
            assert.is_false(result)

            flag = BlacklistFilter.CATA_HIDE
            result = BlacklistFilter.IsFlagged(flag)
            assert.is_false(result)

            flag = BlacklistFilter.SOD_HIDE
            result = BlacklistFilter.IsFlagged(flag)
            assert.is_false(result)
        end)

        it("should return true when flagged for Classic client and CLASSIC_HIDE", function()
            _G.Questie = {IsClassic = true, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
            local flag = BlacklistFilter.CLASSIC_HIDE

            local result = BlacklistFilter.IsFlagged(flag)

            assert.is_true(result)
        end)

        it("should return true when flagged for TBC client and TBC_HIDE", function()
            _G.Questie = {IsClassic = false, IsEra = false, IsTBC = true, IsWotlk = false, IsSoD = false, IsCata = false, IsAnniversary = false}
            local flag = BlacklistFilter.TBC_HIDE

            local result = BlacklistFilter.IsFlagged(flag)

            assert.is_true(result)
        end)

        it("should return true when flagged for Wotlk client and WOTLK_HIDE", function()
            _G.Questie = {IsClassic = false, IsEra = false, IsTBC = false, IsWotlk = true, IsSoD = false, IsCata = false, IsAnniversary = false}
            local flag = BlacklistFilter.WOTLK_HIDE

            local result = BlacklistFilter.IsFlagged(flag)

            assert.is_true(result)
        end)

        it("should return true when flagged for Cata client and CATA_HIDE", function()
            _G.Questie = {IsClassic = false, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = true, IsAnniversary = false}
            local flag = BlacklistFilter.CATA_HIDE

            local result = BlacklistFilter.IsFlagged(flag)

            assert.is_true(result)
        end)

        it("should return true when flagged for SoD client and SOD_HIDE", function()
            _G.Questie = {IsClassic = true, IsEra = false, IsTBC = false, IsWotlk = false, IsSoD = true, IsCata = false, IsAnniversary = false}
            local flag = BlacklistFilter.SOD_HIDE

            local result = BlacklistFilter.IsFlagged(flag)

            assert.is_true(result)
        end)
    end)
end)
