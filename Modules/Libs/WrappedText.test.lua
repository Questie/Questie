dofile("setupTests.lua")

describe("WrappedText", function()
    ---@type WrappedText
    local WrappedText

    describe("TextWrap", function()
        local originalUIParent
        local originalQuestLogObjectivesText
        ---@type utf8
        local utf8

        ---Creates a FontString mock where one UTF-8 character equals one width unit.
        ---@return table fontStringMock Mocked FontString API used by WrappedText:TextWrap.
        local function CreateTextWrapFontStringMock()
            local text = ""
            local width = 275
            local visible = false
            local font = "Font"
            local size = 12
            local flags = ""
            local fontWidthMultipliers = {
                DoubleWidthFont = 2,
            }

            ---@param index number UTF-8 character index.
            ---@return number row Visual row for the mocked fixed-width FontString.
            local function GetRow(index)
                return math.floor((index - 1) / width) + 1
            end

            return {
                SetWidth = function(_, value) width = value end,
                SetHeight = function() end,
                SetPoint = function() end,
                SetJustifyH = function() end,
                SetWordWrap = function() end,
                SetVertexColor = function() end,
                SetFont = function(_, newFont, newSize, newFlags)
                    font = newFont
                    size = newSize
                    flags = newFlags
                end,
                GetFont = function() return font, size, flags end,
                SetText = function(_, value) text = value end,
                Show = function() visible = true end,
                Hide = function() visible = false end,
                IsVisible = function() return visible end,
                GetWrappedWidth = function() return width end,
                GetUnboundedStringWidth = function() return utf8.strlen(text) * (fontWidthMultipliers[font] or 1) end,
                CalculateScreenAreaFromCharacterSpan = function(_, leftIndex, rightIndex)
                    ---@type table[]
                    local areas = {}
                    for row = GetRow(leftIndex), GetRow(rightIndex) do
                        areas[#areas + 1] = {left = 0, bottom = 0, width = width, height = 1}
                    end

                    return areas
                end,
            }
        end

        before_each(function()
            originalUIParent = _G.UIParent
            originalQuestLogObjectivesText = _G["QuestLogObjectivesText"]

            utf8 = require("Modules.Libs.utf8")
            _G["QuestLogObjectivesText"] = {
                GetWidth = function() return 275 end,
                GetFont = function() return "Font", 12, "" end,
            }
            _G.UIParent = {
                CreateFontString = function() return CreateTextWrapFontStringMock() end,
            }

            package.loaded["Modules.Libs.WrappedText"] = nil
            WrappedText = require("Modules.Libs.WrappedText")
        end)

        after_each(function()
            _G.UIParent = originalUIParent
            _G["QuestLogObjectivesText"] = originalQuestLogObjectivesText
            package.loaded["Modules.Libs.WrappedText"] = nil
        end)

        it("should add the prefix to each wrapped line", function()
            local lines = WrappedText:TextWrap("abcd", ">>", false, 2)

            assert.are_same({">>ab", ">>cd"}, lines)
        end)

        it("should add the prefix to unwrapped text", function()
            local lines = WrappedText:TextWrap("abc", ">>", false, 10)

            assert.are_same({">>abc"}, lines)
        end)

        it("should carry active color escapes across wrapped lines", function()
            local lines = WrappedText:TextWrap("|cFFFF0000abcdef|r", "", false, 3)

            assert.are_same({"|cFFFF0000abc|r", "|cFFFF0000def|r"}, lines)
        end)

        it("should reopen carried colors after the line prefix", function()
            local lines = WrappedText:TextWrap("|cFFFF0000abcdef|r", ">>", false, 3)

            assert.are_same({">>|cFFFF0000abc|r", ">>|cFFFF0000def|r"}, lines)
        end)

        it("should not close unbounded color escapes across wrapped lines", function()
            local lines = WrappedText:TextWrap("|cFFFF0000abcdef", "", false, 3)

            assert.are_same({"|cFFFF0000abc", "|cFFFF0000def"}, lines)
        end)

        it("should reopen unbounded color escapes after the line prefix", function()
            local lines = WrappedText:TextWrap("|cFFFF0000abcdef", ">>", false, 3)

            assert.are_same({">>|cFFFF0000abc", ">>|cFFFF0000def"}, lines)
        end)

        it("should not close unbounded inline colors split across wrapped lines", function()
            local lines = WrappedText:TextWrap("aa|cFFFF0000bbcc", "", false, 4)

            assert.are_same({"aa|cFFFF0000bb", "|cFFFF0000cc"}, lines)
        end)

        it("should not close an unbounded color before the next color opens", function()
            local lines = WrappedText:TextWrap("|cFFFF0000abcdef|cFF00FF00ghij|rkl", "", false, 3)

            assert.are_same({"|cFFFF0000abc", "|cFFFF0000def", "|cFF00FF00ghi|r", "|cFF00FF00j|rkl"}, lines)
        end)

        it("should close and reopen inline colors split across wrapped lines", function()
            local lines = WrappedText:TextWrap("aa|cFFFF0000bbcc|rdd", "", false, 4)

            assert.are_same({"aa|cFFFF0000bb|r", "|cFFFF0000cc|rdd"}, lines)
        end)

        it("should not bleed reset colors into later normal text", function()
            local lines = WrappedText:TextWrap("|cFFFF0000red|rnorm|cFF00FF00green|rdone", "", false, 7)

            assert.are_same({"|cFFFF0000red|rnorm", "|cFF00FF00green|rdo", "ne"}, lines)
        end)

        it("should support uppercase color open and reset escapes", function()
            local lines = WrappedText:TextWrap("|CFFFF0000abcdef|R", "", false, 3)

            assert.are_same({"|CFFFF0000abc|r", "|CFFFF0000def|R"}, lines)
        end)

        it("should not carry empty color spans into following text", function()
            local lines = WrappedText:TextWrap("|cFFFF0000|rabcdef", "", false, 3)

            assert.are_same({"abc", "def"}, lines)
        end)

        it("should not emit resets for empty color spans at wrap boundaries", function()
            local lines = WrappedText:TextWrap("abc|cFFFF0000|rdef", "", false, 3)

            assert.are_same({"abc", "def"}, lines)
        end)

        it("should not emit resets for empty color spans between one-character lines", function()
            local lines = WrappedText:TextWrap("a|cFFFF0000|rb", "", false, 1)

            assert.are_same({"a", "b"}, lines)
        end)

        it("should treat escaped literal pipe color-like text as normal text", function()
            local text = "||cFFFF0000abc"
            local lines = WrappedText:TextWrap(text, "", false, 3)

            assert.are_same(text, table.concat(lines, ""))
            for _, line in ipairs(lines) do
                assert.is_nil(string.find(line, "|r", 1, true))
            end
        end)

        it("should preserve escaped literal pipes when real color escapes are present", function()
            local lines = WrappedText:TextWrap("a||b|cFFFF0000cd|r", "", false, 3)

            assert.are_same({"a||b", "|cFFFF0000cd|r"}, lines)
        end)

        it("should treat malformed color-like text as normal text", function()
            local text = "|cFFbad"
            local lines = WrappedText:TextWrap(text, "", false, 3)

            assert.are_same({"|cF", "Fba", "d"}, lines)
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should use the quest objective width by default", function()
            local lines = WrappedText:TextWrap(string.rep("A", 276), "", false)

            assert.are_same(string.rep("A", 275), lines[1])
            assert.are_same("A", lines[2])
        end)

        it("should fall back to the quest font when fontSource is invalid", function()
            local lines = WrappedText:TextWrap("abcd", "", false, 4, {})

            assert.are_same({"abcd"}, lines)
        end)

        it("should measure with the provided font source", function()
            local fontSource = {
                GetFont = function() return "DoubleWidthFont", 12, "" end,
            }
            local lines = WrappedText:TextWrap("abcd", "", false, 4, fontSource)

            assert.are_same({"ab", "cd"}, lines)
        end)

        it("should not split inside ASCII numbers", function()
            local text = "杀死50个狂心狼獾人"
            local lines = WrappedText:TextWrap(text, "", false, 3)

            assert.are_same("杀死50", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should not split inside full-width numbers", function()
            local text = "杀死５０个狂心狼獾人"
            local lines = WrappedText:TextWrap(text, "", false, 3)

            assert.are_same("杀死５０", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should not split comma separated numbers", function()
            local text = "1,050经验后返回"
            local lines = WrappedText:TextWrap(text, "", false, 1)

            assert.are_same("1,050", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should not split percent values", function()
            local text = "达到50%完成"
            local lines = WrappedText:TextWrap(text, "", false, 3)

            assert.are_same("达到50%", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should not split decimal percent values", function()
            local text = "3.14%完成"
            local lines = WrappedText:TextWrap(text, "", false, 1)

            assert.are_same("3.14%", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should not split full-width numeric separators", function()
            local text = "1，050经验后返回"
            local lines = WrappedText:TextWrap(text, "", false, 1)

            assert.are_same("1，050", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should not split full-width percent values", function()
            local text = "达到５０％完成"
            local lines = WrappedText:TextWrap(text, "", false, 3)

            assert.are_same("达到５０％", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should not split full-width decimal percent values", function()
            local text = "３．１４％完成"
            local lines = WrappedText:TextWrap(text, "", false, 1)

            assert.are_same("３．１４％", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should not treat normal punctuation as a numeric separator", function()
            local text = "1. Next"
            local lines = WrappedText:TextWrap(text, "", false, 1)

            assert.are_same("1", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should allow numeric suffixes to wrap independently", function()
            local text = "15分钟后返回"
            local lines = WrappedText:TextWrap(text, "", false, 2)

            assert.are_same("15", lines[1])
            assert.are_same(text, table.concat(lines, ""))
        end)

        it("should allow localized count and range units to wrap independently", function()
            local countText = "殺死8隻狗頭人"
            local rangeText = "最远20码以外"
            local countLines = WrappedText:TextWrap(countText, "", false, 3)
            local rangeLines = WrappedText:TextWrap(rangeText, "", false, 4)

            assert.are_same("殺死8", countLines[1])
            assert.are_same(countText, table.concat(countLines, ""))
            assert.are_same("最远20", rangeLines[1])
            assert.are_same(rangeText, table.concat(rangeLines, ""))
        end)

        it("should combine a single trailing English word with the previous line", function()
            local lines = WrappedText:TextWrap("alpha beta", "", true, 5)

            assert.are_same({"alpha beta"}, lines)
        end)

        it("should preserve color escapes when combining a single trailing English word", function()
            local lines = WrappedText:TextWrap("|cFFFF0000alpha beta|r", "", true, 5)

            assert.are_same({"|cFFFF0000alpha beta|r"}, lines)
        end)

        it("should combine a single trailing Chinese glyph with the previous line", function()
            local lines = WrappedText:TextWrap("一二三四", "", true, 3)

            assert.are_same({"一二三四"}, lines)
        end)

        it("should not combine a single trailing ASCII character from an unbroken word", function()
            local lines = WrappedText:TextWrap("abcdef", "", true, 5)

            assert.are_same({"abcde", "f"}, lines)
        end)

        it("should keep a single trailing Chinese glyph when combining is disabled", function()
            local lines = WrappedText:TextWrap("一二三四", "", false, 3)

            assert.are_same({"一二三", "四"}, lines)
        end)

        it("should not prefer Chinese punctuation as a wrap point", function()
            local text = "一二，三四五"
            local lines = WrappedText:TextWrap(text, "", false, 4)

            assert.are_same({"一二，三", "四五"}, lines)
            assert.are_same(text, table.concat(lines, ""))
        end)
    end)
end)
