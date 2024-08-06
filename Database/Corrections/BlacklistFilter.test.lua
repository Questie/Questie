dofile("Modules/Libs/QuestieLoader.lua")
_G.bit = {band = function(a, b)
    return a & b
end}

local BlacklistFilter

describe("BlacklistFilter", function()
    it("should remove blacklists", function()
        _G.Questie = {IsClassic = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_nil(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
    end)

    it("should set true for Classic client and CLASSIC_HIDE", function()
        _G.Questie = {IsClassic = true, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
    end)

    it("should set true for TBC client and TBC_HIDE", function()
        _G.Questie = {IsClassic = false, IsTBC = true, IsWotlk = false, IsSoD = false, IsCata = false}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_nil(result[1])
        assert.is_true(result[2])
        assert.is_true(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
    end)

    it("should set true for Wotlk client and WOTLK_HIDE", function()
        _G.Questie = {IsClassic = false, IsTBC = false, IsWotlk = true, IsSoD = false, IsCata = false}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_nil(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_true(result[4])
        assert.is_nil(result[5])
        assert.is_nil(result[6])
    end)

    it("should set true for Cata client and CATA_HIDE", function()
        _G.Questie = {IsClassic = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = true}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_nil(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_true(result[5])
        assert.is_nil(result[6])
    end)

    it("should set true for SoD client and SOD_HIDE", function()
        _G.Questie = {IsClassic = true, IsTBC = false, IsWotlk = false, IsSoD = true, IsCata = false}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE,
            [2] = true,
            [3] = BlacklistFilter.TBC_HIDE,
            [4] = BlacklistFilter.WOTLK_HIDE,
            [5] = BlacklistFilter.CATA_HIDE,
            [6] = BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
        assert.is_true(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
        assert.is_nil(result[5])
        assert.is_true(result[6])
    end)

    it("should set true for Classic client and CLASSIC_HIDE + SOD_HIDE", function()
        _G.Questie = {IsClassic = true, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE + BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
    end)

    it("should set true for SoD client and CLASSIC_HIDE + SOD_HIDE", function()
        _G.Questie = {IsClassic = true, IsTBC = false, IsWotlk = false, IsSoD = true, IsCata = false}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE + BlacklistFilter.SOD_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
    end)

    it("should set true for Classic client and CLASSIC_HIDE + TBC_HIDE", function()
        _G.Questie = {IsClassic = true, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = false}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE + BlacklistFilter.TBC_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
    end)

    it("should set true for Cata client and CLASSIC_HIDE + TBC_HIDE + WOTLK_HIDE + CATA_HIDE", function()
        _G.Questie = {IsClassic = false, IsTBC = false, IsWotlk = false, IsSoD = false, IsCata = true}
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
        local blacklist = {
            [1] = BlacklistFilter.CLASSIC_HIDE + BlacklistFilter.TBC_HIDE + BlacklistFilter.WOTLK_HIDE + BlacklistFilter.CATA_HIDE,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
    end)
end)
