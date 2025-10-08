dofile("setupTests.lua")

---@type BlacklistFilter
local BlacklistFilter

describe("BlacklistFilter", function()

    before_each(function()
        BlacklistFilter = require("Database.Corrections.BlacklistFilter")
    end)

    it("should correctly filter blacklists", function()
        local blacklist = {
            [1] = true,
            [2] = false,
            [3] = "invalid",
            [4] = 0,
        }

        local result = BlacklistFilter.filterExpansion(blacklist)

        assert.is_true(result[1])
        assert.is_nil(result[2])
        assert.is_nil(result[3])
        assert.is_nil(result[4])
    end)
end)
