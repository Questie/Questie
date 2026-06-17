dofile("setupTests.lua")

describe("TooltipLayout", function()
    ---@type TooltipLayout
    local TooltipLayout
    ---@type WrappedText
    local WrappedText

    local originalUIParent
    local originalCreateFrame
    local originalTextWrap
    local capturedTextWrap

    local function CreateFontStringMock()
        local text = ""
        local font = "GameTooltipFont"
        local size = 12
        local flags = ""

        return {
            GetFont = function() return font, size, flags end,
            SetFont = function(_, newFont, newSize, newFlags)
                font = newFont
                size = newSize
                flags = newFlags
            end,
            SetWordWrap = function() end,
            Hide = function() end,
            SetText = function(_, value) text = value or "" end,
            GetUnboundedStringWidth = function() return string.len(text) end,
        }
    end

    local function CreateTooltipMock(name)
        local calls = {}

        return {
            calls = calls,
            GetName = function() return name end,
            AddLine = function(_, text, ...)
                calls[#calls + 1] = {kind = "line", text = text, n = select("#", ...), args = {...}}
            end,
            AddDoubleLine = function(_, leftText, rightText, ...)
                calls[#calls + 1] = {kind = "doubleLine", leftText = leftText, rightText = rightText, n = select("#", ...), args = {...}}
            end,
        }
    end

    local function RequireTooltipLayout()
        package.loaded["Modules.Libs.WrappedText"] = nil
        WrappedText = require("Modules.Libs.WrappedText")
        originalTextWrap = WrappedText.TextWrap
        WrappedText.TextWrap = function(_, text, prefix, combineTrailing, desiredWidth, fontSource)
            capturedTextWrap = {
                text = text,
                prefix = prefix,
                combineTrailing = combineTrailing,
                desiredWidth = desiredWidth,
                fontSource = fontSource,
            }
            return {prefix .. "wrapped"}
        end

        package.loaded["Modules.Tooltips.TooltipLayout"] = nil
        TooltipLayout = require("Modules.Tooltips.TooltipLayout")
    end

    before_each(function()
        originalUIParent = _G.UIParent
        originalCreateFrame = _G.CreateFrame
        capturedTextWrap = nil

        _G.UIParent = {
            CreateFontString = function() return CreateFontStringMock() end,
        }
        _G.CreateFrame = function()
            return {
                SetOwner = function() end,
                SetPoint = function() end,
                SetAlpha = function() end,
                ClearLines = function() end,
                AddDoubleLine = function() end,
                Show = function() end,
                Hide = function() end,
            }
        end

        _G.TestTooltipTextLeft1 = CreateFontStringMock()
        _G.TestTooltipTextLeft2 = CreateFontStringMock()
        _G.TestTooltipTextRight1 = CreateFontStringMock()
        _G.QuestieTooltipLayoutGapMeasureTooltipTextLeft1 = {GetRight = function() return 100 end}
        _G.QuestieTooltipLayoutGapMeasureTooltipTextRight1 = {GetLeft = function() return 150 end}
        _G.QuestieTooltipLayoutGapMeasureTooltipTextLeft2 = {GetRight = function() return 100 end}
        _G.QuestieTooltipLayoutGapMeasureTooltipTextRight2 = {GetLeft = function() return 150 end}

        RequireTooltipLayout()
    end)

    after_each(function()
        _G.UIParent = originalUIParent
        _G.CreateFrame = originalCreateFrame
        _G.TestTooltipTextLeft1 = nil
        _G.TestTooltipTextLeft2 = nil
        _G.TestTooltipTextRight1 = nil
        _G.QuestieTooltipLayoutGapMeasureTooltipTextLeft1 = nil
        _G.QuestieTooltipLayoutGapMeasureTooltipTextRight1 = nil
        _G.QuestieTooltipLayoutGapMeasureTooltipTextLeft2 = nil
        _G.QuestieTooltipLayoutGapMeasureTooltipTextRight2 = nil
        if WrappedText then
            WrappedText.TextWrap = originalTextWrap
        end
        package.loaded["Modules.Libs.WrappedText"] = nil
        package.loaded["Modules.Tooltips.TooltipLayout"] = nil
    end)

    it("should preserve AddLine and AddDoubleLine order and packed args", function()
        local tooltip = CreateTooltipMock("TestTooltip")
        local rows = TooltipLayout:CreateRows()

        rows:AddLine("first", 1, nil, 3)
        rows:AddDoubleLine("left", "right", 4, 5, nil)
        rows:AddLine("last")
        TooltipLayout:Render(tooltip, rows)

        assert.are.same("line", tooltip.calls[1].kind)
        assert.are.same("first", tooltip.calls[1].text)
        assert.are.same(3, tooltip.calls[1].n)
        assert.are.same(1, tooltip.calls[1].args[1])
        assert.is_nil(tooltip.calls[1].args[2])
        assert.are.same(3, tooltip.calls[1].args[3])
        assert.are.same("doubleLine", tooltip.calls[2].kind)
        assert.are.same("left", tooltip.calls[2].leftText)
        assert.are.same("right", tooltip.calls[2].rightText)
        assert.are.same(3, tooltip.calls[2].n)
        assert.are.same("line", tooltip.calls[3].kind)
        assert.are.same("last", tooltip.calls[3].text)
    end)

    it("should wrap descriptions from non-description width minus prefix width", function()
        local tooltip = CreateTooltipMock("TestTooltip")
        local rows = TooltipLayout:CreateRows()
        local wideLine = string.rep("A", 500)

        rows:AddLine(wideLine)
        rows:AddDescription(string.rep("B", 900), "  ", 0.86, 0.86, 0.86)
        TooltipLayout:Render(tooltip, rows)

        assert.are.same(498, capturedTextWrap.desiredWidth)
        assert.are.same(string.rep("B", 900), capturedTextWrap.text)
        assert.are.same("  ", capturedTextWrap.prefix)
        assert.is_false(capturedTextWrap.combineTrailing)
        assert.are.same("  wrapped", tooltip.calls[2].text)
        assert.are.same(3, tooltip.calls[2].n)
    end)

    it("should include measured double-line gap when deriving description width", function()
        local tooltip = CreateTooltipMock("TestTooltip")
        local rows = TooltipLayout:CreateRows()

        rows:AddDoubleLine(string.rep("L", 300), string.rep("R", 100))
        rows:AddDescription("description", " ")
        TooltipLayout:Render(tooltip, rows)

        assert.are.same(449, capturedTextWrap.desiredWidth)
        assert.is_false(capturedTextWrap.combineTrailing)
    end)
end)
