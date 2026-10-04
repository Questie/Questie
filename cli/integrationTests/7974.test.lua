dofile("setupTests.lua")

-- https://github.com/Questie/Questie/pull/7974
-- Exercise the real marker and route visibility methods together. Native drawing is mocked;
-- Show/Hide calls below model HBD's map refresh and QuestieMap's delayed marker registration.

describe("PR 7974 - Manual map route visibility", function()
    ---@type QuestieFrame
    local QuestieFrame
    ---@type QuestieFramePool
    local QuestieFramePool
    local createFrame
    local mapIcon
    local minimapIcon
    local route

    ---@param data IconData
    ---@param miniMapIcon boolean
    ---@return IconFrame
    local function _CreateIcon(data, miniMapIcon)
        local icon = CreateFrame("Frame")
        icon.data = data
        icon.miniMapIcon = miniMapIcon
        icon.FakeHide = QuestieFrame.private.FakeHide
        icon.FakeShow = QuestieFrame.private.FakeShow
        return icon
    end

    before_each(function()
        createFrame = CreateFrame
        _G.CreateFrame = function(...)
            local frame = createFrame(...)
            frame.IsShown = frame.IsVisible
            frame.SetFrameLevel = function() end
            frame.CreateLine = function()
                return {
                    SetColorTexture = function() end,
                    SetDrawLayer = function() end,
                    SetStartPoint = function() end,
                    SetEndPoint = function() end,
                    SetThickness = function() end,
                }
            end
            return frame
        end
        _G.tinsert = table.insert
        _G.tremove = table.remove
        _G.abs = math.abs
        _G.max = math.max
        _G.min = math.min

        local canvas = CreateFrame("Frame")
        canvas:SetSize(1000, 600)
        _G.WorldMapFrame = {GetCanvas = function() return canvas end}
        ---@type QuestiePopup
        local Popup = QuestieLoader:ImportModule("QuestiePopup")
        Popup.Dialogs = {}

        dofile("Modules/FramePool/QuestieFrame.lua")
        dofile("Modules/FramePool/QuestieFramePool.lua")
        QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
        QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")

        local data = {Type = "manual", Id = 550}
        mapIcon = _CreateIcon(data, false)
        minimapIcon = _CreateIcon(data, true)
        route = QuestieFramePool:CreateLine(mapIcon, 45, 69, 44, 68, 1.5, {1, 0.72, 0, 0.5}, 40)
        route:Show()
    end)

    after_each(function()
        _G.CreateFrame = createFrame
    end)

    it("should keep the world-map route visible when hiding its minimap marker", function()
        minimapIcon:FakeHide()

        assert.is_false(minimapIcon:IsShown())
        assert.is_true(mapIcon:IsShown())
        assert.is_true(route:IsShown())
    end)

    it("should not restore a hidden world-map route when showing its minimap marker", function()
        mapIcon:FakeHide()
        minimapIcon:FakeHide()

        minimapIcon:FakeShow()

        assert.is_true(minimapIcon:IsShown())
        assert.is_false(mapIcon:IsShown())
        assert.is_false(route:IsShown())
    end)

    it("should hide and restore the route with its owning map icon", function()
        mapIcon:FakeHide()
        assert.is_false(mapIcon:IsShown())
        assert.is_false(route:IsShown())

        mapIcon:FakeShow()
        assert.is_true(mapIcon:IsShown())
        assert.is_true(route:IsShown())
    end)

    it("should keep a released route off the other map and restore it on return", function()
        mapIcon:FakeHide()
        -- HBD releases the marker and hides its separately registered route on the other map.
        mapIcon:Hide()
        route:Hide()

        mapIcon:FakeShow()

        assert.is_false(mapIcon:IsShown())
        assert.is_false(route:IsShown())

        -- Returning to the original map must work without another FakeShow call.
        mapIcon:Show()
        route:Show()
        assert.is_true(mapIcon:IsShown())
        assert.is_true(route:IsShown())
    end)

    it("should keep reacquired pins suppressed until their owner is restored", function()
        mapIcon:FakeHide()
        mapIcon:Hide()
        route:Hide()
        mapIcon:Show()
        route:Show()

        assert.is_false(mapIcon:IsShown())
        assert.is_false(route:IsShown())

        mapIcon:FakeShow()
        assert.is_true(mapIcon:IsShown())
        assert.is_true(route:IsShown())
    end)

    it("should preserve the route when icons are enabled before the marker queue drains", function()
        mapIcon = _CreateIcon({Type = "manual", Id = 550}, false)
        mapIcon:Hide()
        mapIcon:FakeHide()
        -- QuestieMap queues the marker but registers and suppresses its route immediately.
        route = QuestieFramePool:CreateLine(mapIcon, 45, 69, 44, 68, 1.5, {1, 0.72, 0, 0.5}, 40)
        route:Show()
        route:FakeHide()

        mapIcon:FakeShow()
        -- ProcessQueue later acquires only the marker; the route was already registered.
        mapIcon:Show()

        assert.is_true(mapIcon:IsShown())
        assert.is_true(route:IsShown())
    end)

    it("should not change a route owned by another map icon sharing its data", function()
        local otherMapIcon = _CreateIcon(mapIcon.data, false)
        otherMapIcon:FakeHide()
        assert.is_true(route:IsShown())

        mapIcon:FakeHide()
        otherMapIcon:FakeShow()
        assert.is_false(route:IsShown())
    end)
end)
