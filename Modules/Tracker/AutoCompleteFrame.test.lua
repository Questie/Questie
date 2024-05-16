dofile("setupTests.lua")

local screenWidth = 1920
_G.GetScreenWidth = function() return screenWidth end

---@type AutoCompleteFrame
local AutoCompleteFrame = require("Modules.Tracker.AutoCompleteFrame")

describe("AutoCompleteFrame", function()
    before_each(function()
        CreateFrame.resetMockedFrames()
    end)

    describe("ShowAutoComplete", function()
        it("should set quest data and show frame", function()
            AutoCompleteFrame.Initialize({
                GetPoint = function()
                    return "BOTTOMLEFT", nil, nil, screenWidth
                end
            })
            local frame = CreateFrame.mockedFrames[1]
            frame.Show = spy.new(frame.Show)
            frame.questTitle.SetText = spy.new(frame.questTitle.SetText)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.questTitle.SetText).was_called_with(frame.questTitle, "Test Quest")
            assert.equals(1, frame.questId)
            assert.spy(frame.Show).was_called()
        end)

        it("should show pop up on the left if Tracker is on the right side of the screen and anchored BOTTOMLEFT", function()
            local baseFrame = {
                GetPoint = function()
                    return "BOTTOMLEFT", nil, nil, screenWidth
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was_called_with(frame, "TOPLEFT", baseFrame, -200, 0)
        end)

        it("should show pop up on the right if Tracker is on the left side of the screen and anchored BOTTOMLEFT", function()
            local baseFrame = {
                GetPoint = function()
                    return "BOTTOMLEFT", nil, nil, 0
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was_called_with(frame, "TOPRIGHT", baseFrame, 200, 0)
        end)

        it("should show pop up on the left if Tracker is on the right side of the screen and anchored TOPLEFT", function()
            local baseFrame = {
                GetPoint = function()
                    return "TOPLEFT", nil, nil, screenWidth
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was_called_with(frame, "TOPLEFT", baseFrame, -200, 0)
        end)

        it("should show pop up on the right if Tracker is on the left side of the screen and anchored TOPLEFT", function()
            local baseFrame = {
                GetPoint = function()
                    return "TOPLEFT", nil, nil, 0
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was_called_with(frame, "TOPRIGHT", baseFrame, 200, 0)
        end)

        it("should show pop up on the left if Tracker is on the right side of the screen and anchored BOTTOMRIGHT", function()
            local baseFrame = {
                GetPoint = function()
                    return "BOTTOMRIGHT", nil, nil, 0
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was_called_with(frame, "TOPLEFT", baseFrame, -200, 0)
        end)

        it("should show pop up on the right if Tracker is on the left side of the screen and anchored BOTTOMRIGHT", function()
            local baseFrame = {
                GetPoint = function()
                    return "BOTTOMRIGHT", nil, nil, -screenWidth
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was_called_with(frame, "TOPRIGHT", baseFrame, 200, 0)
        end)

        it("should show pop up on the left if Tracker is on the right side of the screen and anchored TOPRIGHT", function()
            local baseFrame = {
                GetPoint = function()
                    return "TOPRIGHT", nil, nil, 0
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was_called_with(frame, "TOPLEFT", baseFrame, -200, 0)
        end)

        it("should show pop up on the right if Tracker is on the left side of the screen and anchored TOPRIGHT", function()
            local baseFrame = {
                GetPoint = function()
                    return "TOPRIGHT", nil, nil, -screenWidth
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was_called_with(frame, "TOPRIGHT", baseFrame, 200, 0)
        end)
    end)
end)
