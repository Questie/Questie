dofile("setupTests.lua")

local loadTOC = require("cli.loadTOC")

describe("loadTOC", function()
    after_each(function()
        _G.LOAD_TOC_TEST_ORDER = nil
    end)

    it("loads Lua files, XML scripts, and nested XML includes in manifest order", function()
        _G.LOAD_TOC_TEST_ORDER = {}

        loadTOC("cli/testData/loadTOC/addon.toc")

        assert.are_same({
            "Questie: first Lua",
            "inline XML script",
            "XML Lua file",
            "included XML Lua file",
            "last Lua",
        }, _G.LOAD_TOC_TEST_ORDER)
    end)
end)
