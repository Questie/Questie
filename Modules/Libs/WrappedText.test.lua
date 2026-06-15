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
                GetUnboundedStringWidth = function() return utf8.strlen(text) end,
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

            require("Modules.Libs.utf8")
            require("Modules.Libs.FontMeasure")
            utf8 = QuestieLoader:ImportModule("utf8")
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
