dofile("setupTests.lua")

describe("Questie", function()
    before_each(function()
        local QuestieValidateGameCache = QuestieLoader:ImportModule("QuestieValidateGameCache")
        QuestieValidateGameCache.StartCheck = function() end

        dofile("Questie.lua")
    end)

    describe("Colorize", function()
        it("should preserve named color output", function()
            local expectedColors = {
                red = "|cFFff0000Text|r",
                gray = "|cFFa6a6a6Text|r",
                purple = "|cFFB900FFText|r",
                blue = "|cFF0000FFText|r",
                lightBlue = "|cFF00BBFFText|r",
                reputationBlue = "|cFF8080ffText|r",
                repeatableBlue = "|cFF21CCE7Text|r",
                yellow = "|cFFffff00Text|r",
                orange = "|cFFFF6F22Text|r",
                green = "|cFF00ff00Text|r",
                white = "|cFFffffffText|r",
                gold = "|cFFffd100Text|r",
                lime = "|cFF6ce314Text|r",
                pvpRed = "|cFFE35639Text|r",
            }

            for color, expected in pairs(expectedColors) do
                assert.are_same(expected, Questie:Colorize("Text", color))
            end
        end)

        it("should default to yellow", function()
            assert.are_same("|cFFffff00Text|r", Questie:Colorize("Text"))
        end)

        it("should preserve raw RGB hex color output", function()
            assert.are_same("|cFFD9D9D9Text|r", Questie:Colorize("Text", "D9D9D9"))
        end)

        it("should preserve raw color text without normalizing ARGB input", function()
            assert.are_same("|cFFFF7F00FEText|r", Questie:Colorize("Text", "FF7F00FE"))
        end)

        it("should ignore extra arguments", function()
            assert.are_same("|cFFff0000Text|r", Questie:Colorize("Text", "red", true))
        end)
    end)

    describe("ColorizeRGB", function()
        local expectedNamedColors = {
            red = {1, 0, 0},
            gray = {166 / 255, 166 / 255, 166 / 255},
            purple = {185 / 255, 0, 1},
            blue = {0, 0, 1},
            lightBlue = {0, 187 / 255, 1},
            reputationBlue = {128 / 255, 128 / 255, 1},
            repeatableBlue = {33 / 255, 204 / 255, 231 / 255},
            yellow = {1, 1, 0},
            orange = {1, 111 / 255, 34 / 255},
            green = {0, 1, 0},
            white = {1, 1, 1},
            gold = {1, 209 / 255, 0},
            lime = {108 / 255, 227 / 255, 20 / 255},
            pvpRed = {227 / 255, 86 / 255, 57 / 255},
        }

        local function _AssertRGB(expected, r, g, b)
            assert.are_same(expected[1], r)
            assert.are_same(expected[2], g)
            assert.are_same(expected[3], b)
        end

        it("should return normalized RGB values for all named colors", function()
            for color, expected in pairs(expectedNamedColors) do
                _AssertRGB(expected, Questie:ColorizeRGB(color))
            end
        end)

        it("should default to yellow", function()
            _AssertRGB({1, 1, 0}, Questie:ColorizeRGB())
        end)

        it("should return three values for valid colors", function()
            local count = select("#", Questie:ColorizeRGB("red"))

            assert.are_same(3, count)
        end)

        it("should return normalized RGB values for raw RGB hex colors", function()
            _AssertRGB({127 / 255, 0, 254 / 255}, Questie:ColorizeRGB("7F00FE"))
        end)

        it("should return normalized RGB values for raw ARGB hex colors", function()
            _AssertRGB({127 / 255, 0, 254 / 255}, Questie:ColorizeRGB("FF7F00FE"))
        end)

        it("should ignore alpha in raw ARGB hex colors", function()
            _AssertRGB({127 / 255, 0, 254 / 255}, Questie:ColorizeRGB("007F00FE"))
        end)

        it("should return normalized RGB values for WoW color strings", function()
            _AssertRGB({127 / 255, 0, 254 / 255}, Questie:ColorizeRGB("|cFF7F00FEText|r"))
        end)

        it("should return normalized RGB values for uppercase WoW color strings", function()
            _AssertRGB({127 / 255, 0, 254 / 255}, Questie:ColorizeRGB("|CFF7F00FEText|r"))
        end)

        it("should ignore alpha in WoW color strings", function()
            _AssertRGB({127 / 255, 0, 254 / 255}, Questie:ColorizeRGB("|c007F00FEText|r"))
        end)

        it("should return nil RGB output for malformed string colors", function()
            assert.is_nil(Questie:ColorizeRGB("XYZXYZ"))
            assert.is_nil(Questie:ColorizeRGB("12345"))
            assert.is_nil(Questie:ColorizeRGB("#7F00FE"))
            assert.is_nil(Questie:ColorizeRGB("|cFF7F00"))
        end)

        it("should return nil RGB output for non-string invalid colors", function()
            assert.is_nil(Questie:ColorizeRGB({}))
            assert.is_nil(Questie:ColorizeRGB(123456))
            assert.is_nil(Questie:ColorizeRGB(false))
        end)

        it("should assign nils for invalid colors", function()
            local r, g, b = Questie:ColorizeRGB({})

            assert.is_nil(r)
            assert.is_nil(g)
            assert.is_nil(b)
        end)

        it("should expand RGB values when used as final function arguments", function()
            local captured = {}
            local function _Capture(prefix, ...)
                captured.prefix = prefix
                captured.count = select("#", ...)
                captured.r, captured.g, captured.b = ...
            end

            _Capture("  ", Questie:ColorizeRGB("reputationBlue"))

            assert.are_same("  ", captured.prefix)
            assert.are_same(3, captured.count)
            assert.are_same(128 / 255, captured.r)
            assert.are_same(128 / 255, captured.g)
            assert.are_same(1, captured.b)
        end)

        it("should preserve RGB values through TooltipLayout description rows", function()
            local TooltipLayout = require("Modules.Tooltips.TooltipLayout")
            local rows = TooltipLayout:CreateRows()

            rows:AddDescription("rep", "  ", Questie:ColorizeRGB("reputationBlue"))

            assert.are_same("description", rows[1].kind)
            assert.are_same("rep", rows[1].text)
            assert.are_same("  ", rows[1].prefix)
            assert.are_same(3, rows[1].args.n)
            assert.are_same(128 / 255, rows[1].args[1])
            assert.are_same(128 / 255, rows[1].args[2])
            assert.are_same(1, rows[1].args[3])
        end)

        it("should not expand all RGB values from a non-final argument position", function()
            local count = select("#", Questie:ColorizeRGB("reputationBlue"), "tail")

            assert.are_same(2, count)
        end)
    end)
end)
