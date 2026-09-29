dofile("setupTests.lua")

describe("GamepadMapHover", function()
    ---@type GamepadMapHover
    local GamepadMapHover
    local _GamepadMapHover

    ---@type MapIconTooltip
    local MapIconTooltip
    ---@type QuestieFrame
    local QuestieFrame

    local originalCreateFrame, originalGetCVarBool
    local tooltip
    local tooltipShown
    local resetData
    local pins
    local cursorX, cursorY
    local gamepadUIEnabled, tooltipsDisabled, mapShown, softCursorShown

    local function CreatePin(x, y, alpha, hidden)
        local frameMethods = {
            GetCenter = function() return x, y end,
        }
        local pin = setmetatable({
            GetCenter = function() return nil end, -- overridden like HBDHooks does
        }, {__index = frameMethods})
        pin.icon = {
            hidden = hidden,
            data = {},
            texture = {GetVertexColor = function() return 1, 1, 1, alpha or 1 end},
            IsVisible = function() return true end,
        }
        return pin
    end

    before_each(function()
        tooltipShown = true
        tooltip = {
            IsShown = function() return tooltipShown end,
            SetAnchorType = spy.new(function() end),
            Show = spy.new(function() end),
            Hide = spy.new(function() end),
        }
        originalCreateFrame = _G.CreateFrame
        _G.CreateFrame = function(frameType)
            if frameType == "GameTooltip" then
                return tooltip
            end
            return {SetScript = function() end}
        end

        pins = {}
        cursorX, cursorY = 100, 100
        gamepadUIEnabled, tooltipsDisabled, mapShown, softCursorShown = true, false, true, true

        _G.WorldMapFrame = {
            IsShown = function() return mapShown end,
            ScrollContainer = {GetGamepadCursorPosition = function() return cursorX, cursorY end},
            EnumeratePinsByTemplate = function()
                local i = 0
                return function()
                    i = i + 1
                    return pins[i]
                end
            end,
        }
        _G.SoftCursor = {IsShown = function() return softCursorShown end}
        _G.InputUtil = {IsGamepadUIEnabled = function() return gamepadUIEnabled end}
        originalGetCVarBool = _G.GetCVarBool
        _G.GetCVarBool = function() return tooltipsDisabled end

        MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
        MapIconTooltip.ShowOnTooltip = spy.new(function() end)
        resetData = {}
        QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
        QuestieFrame.ResetHoverHighlights = function(icon)
            table.insert(resetData, icon.data)
        end

        dofile("Modules/Map/GamepadMapHover.lua")
        GamepadMapHover = QuestieLoader:ImportModule("GamepadMapHover")
        _GamepadMapHover = GamepadMapHover.private
        GamepadMapHover.Initialize()
    end)

    after_each(function()
        _G.CreateFrame = originalCreateFrame
        _G.GetCVarBool = originalGetCVarBool
        _G.WorldMapFrame = nil
        _G.SoftCursor = nil
        _G.InputUtil = nil
    end)

    it("should show the Questie tooltip on the private tooltip for the icon under the cursor", function()
        local pin = CreatePin(105, 100)
        pins = {pin}

        _GamepadMapHover.Update()

        assert.are.equal(pin.icon, GamepadMapHover.GetHoveredIcon())
        assert.spy(MapIconTooltip.ShowOnTooltip).was.called_with(pin.icon, tooltip)
        assert.spy(tooltip.SetAnchorType).was.called_with(tooltip, "ANCHOR_RIGHT")
    end)

    it("should not re-anchor when the tooltip was not shown", function()
        tooltipShown = false
        pins = {CreatePin(100, 100)}

        _GamepadMapHover.Update()

        assert.spy(tooltip.SetAnchorType).was.not_called()
    end)

    it("should pick the closest icon", function()
        local far = CreatePin(110, 100)
        local near = CreatePin(102, 100)
        pins = {far, near}

        _GamepadMapHover.Update()

        assert.are.equal(near.icon, GamepadMapHover.GetHoveredIcon())
    end)

    it("should ignore icons out of range, hidden, faded out or without data", function()
        local noData = CreatePin(100, 100)
        noData.icon.data = nil
        pins = {CreatePin(150, 100), CreatePin(100, 100, 1, true), CreatePin(100, 100, 0), noData}

        _GamepadMapHover.Update()

        assert.is_nil(GamepadMapHover.GetHoveredIcon())
        assert.spy(MapIconTooltip.ShowOnTooltip).was.not_called()
    end)

    it("should hide the tooltip and reset highlights when the cursor leaves the icon", function()
        local pin = CreatePin(100, 100)
        local data = pin.icon.data
        pins = {pin}
        _GamepadMapHover.Update()

        cursorX = 200
        _GamepadMapHover.Update()

        assert.is_nil(GamepadMapHover.GetHoveredIcon())
        assert.are_same({data}, resetData)
        assert.spy(tooltip.Hide).was.called()
    end)

    it("should reset the highlighted data when the hovered icon is reused for other data", function()
        local pin = CreatePin(100, 100)
        local oldData = pin.icon.data
        pins = {pin}
        _GamepadMapHover.Update()

        pin.icon.data = {}
        _GamepadMapHover.Update()

        assert.are.equal(oldData, resetData[1])
        assert.spy(MapIconTooltip.ShowOnTooltip).was.called(2)
    end)

    it("should hide the tooltip when the map closes", function()
        pins = {CreatePin(100, 100)}
        _GamepadMapHover.Update()

        mapShown = false
        _GamepadMapHover.Update()

        assert.is_nil(GamepadMapHover.GetHoveredIcon())
        assert.spy(tooltip.Hide).was.called()
    end)

    it("should respect Blizzard's gamepad tooltip toggle", function()
        tooltipsDisabled = true
        pins = {CreatePin(100, 100)}

        _GamepadMapHover.Update()

        assert.is_nil(GamepadMapHover.GetHoveredIcon())
    end)

    it("should do nothing while the soft cursor is hidden", function()
        softCursorShown = false
        cursorX, cursorY = 0, 0
        pins = {CreatePin(0, 0)}

        _GamepadMapHover.Update()

        assert.is_nil(GamepadMapHover.GetHoveredIcon())
    end)

    it("should do nothing without the gamepad UI", function()
        gamepadUIEnabled = false
        pins = {CreatePin(100, 100)}

        _GamepadMapHover.Update()

        assert.is_nil(GamepadMapHover.GetHoveredIcon())
    end)
end)
