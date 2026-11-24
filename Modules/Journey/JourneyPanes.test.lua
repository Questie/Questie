dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyPanes", function()
    ---@type JourneyPanes
    local JourneyPanes
    local ui
    local canvas, panes

    before_each(function()
        ui = FakeUI.Install()
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/JourneyPanes.lua")
        JourneyPanes = QuestieLoader:ImportModule("JourneyPanes")

        canvas = CreateFrame("Frame", nil, UIParent)
        canvas:SetSize(1000, 500)
        panes = JourneyPanes.Create(canvas, "Quests", 64)
    end)

    after_each(function()
        ui.Restore()
    end)

    ---@return table divider
    local function Divider()
        return ui.FindAll(canvas, function(frame) return frame.scripts.OnMouseDown ~= nil end)[1]
    end

    ---Presses the mouse button on the divider and moves the mouse.
    ---@param from number
    ---@param to number
    ---@return table divider
    local function Drag(from, to)
        local divider = Divider()
        ui.cursorX = from
        _G.IsMouseButtonDown = function() return true end
        divider.scripts.OnMouseDown(divider)
        ui.cursorX = to
        divider.scripts.OnUpdate(divider)
        return divider
    end

    it("should leave the space above that is asked for, plus some for the title", function()
        local _, _, _, _, y = panes.list:GetPoint(1)

        assert.is_true(y < -64 and y > -100)
        assert.are.equal("Quests", panes.list.titleFrame.text)
    end)

    it("should make the list wider and narrower by dragging", function()
        local width = panes.list:GetWidth()

        Drag(500, 560)
        assert.are.equal(width + 60, panes.list:GetWidth())

        Drag(560, 460)
        assert.are.equal(width - 40, panes.list:GetWidth())
    end)

    it("should follow the mouse on a scaled UI", function()
        local width = panes.list:GetWidth()
        canvas.effectiveScale, Divider().effectiveScale = 0.5, 0.5

        Drag(250, 280)

        assert.are.equal(width + 60, panes.list:GetWidth())
    end)

    it("should stop when the button is released", function()
        local divider = Drag(500, 560)

        divider.scripts.OnMouseUp(divider)

        assert.is_nil(divider.scripts.OnUpdate)
    end)

    it("should stop when the button is released somewhere else, where the mouse-up doesn't arrive", function()
        local divider = Drag(500, 560)
        local width = panes.list:GetWidth()

        _G.IsMouseButtonDown = function() return false end
        ui.cursorX = 700
        divider.scripts.OnUpdate(divider)

        assert.are.equal(width, panes.list:GetWidth())
        assert.is_nil(divider.scripts.OnUpdate)
    end)

    it("should stop when the window is closed while dragging", function()
        local divider = Drag(500, 560)

        canvas:Hide()

        assert.is_nil(divider.scripts.OnUpdate)
    end)

    it("should show that it can be dragged with the cursor, only while the mouse is over it", function()
        Divider().scripts.OnEnter(Divider())
        assert.are.equal("UI_RESIZE_CURSOR", ui.cursor)

        Divider().scripts.OnLeave(Divider())
        assert.is_nil(ui.cursor)
    end)

    it("should leave room for the details and for the list", function()
        Drag(500, 5000)
        assert.is_true(panes.list:GetWidth() < 800)

        Drag(5000, -5000)
        assert.is_true(panes.list:GetWidth() >= 200)
    end)

    it("should shrink the list in a small window, and restore it when there is room again", function()
        local width = panes.list:GetWidth()

        canvas:SetWidth(550)
        local narrowWidth = panes.list:GetWidth()
        canvas:SetWidth(1000)

        assert.is_true(narrowWidth < width and narrowWidth >= 200)
        assert.are.equal(width, panes.list:GetWidth())
    end)

    it("should drag from where the divider is in a small window", function()
        canvas:SetWidth(550)
        local narrowWidth = panes.list:GetWidth()

        Drag(300, 290)

        assert.are.equal(narrowWidth - 10, panes.list:GetWidth())
    end)
end)
