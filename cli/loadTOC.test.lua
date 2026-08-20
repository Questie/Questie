dofile("setupTests.lua")

local loadTOC = dofile("cli/loadTOC.lua")

local function _FinalExecutableEntry(tocPath)
    local finalEntry
    for line in io.lines(tocPath) do
        local entry = string.match(line, "^%s*(.-)%s*$")
        if entry ~= "" and not string.match(line, "^#") then
            finalEntry = entry
        end
    end
    return finalEntry
end

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

    it("keeps Questie.lua as the final executable entry in every production manifest", function()
        local tocPaths = {
            "Questie-BCC.toc",
            "Questie-Cata.toc",
            "Questie-Classic.toc",
            "Questie-Mists.toc",
            "Questie-WOTLKC.toc",
        }

        for _, tocPath in ipairs(tocPaths) do
            assert.are_same("Questie.lua", _FinalExecutableEntry(tocPath), tocPath)
        end
    end)

    it("treats leading whitespace before # as a file path, like the client does", function()
        -- The client only recognizes # as a comment in the first column, so this line names a file
        -- rather than a comment - one that does not exist, which the replay reports as a load error.
        local tocPath = "cli/testData/loadTOC/leadingWhitespaceComment.toc"
        local tocFile = assert(io.open(tocPath, "w"))
        tocFile:write("  # foo.lua\n")
        tocFile:close()

        local loaded, loadError = pcall(loadTOC, tocPath)
        os.remove(tocPath)

        assert.is_false(loaded)
        assert.matches("Error loading cli/testData/loadTOC/# foo.lua", loadError, 1, true)
    end)
end)
