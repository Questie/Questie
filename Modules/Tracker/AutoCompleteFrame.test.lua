dofile("setupTests.lua")

local screenWidth = 1920
local stub = require("luassert.stub")

---@type AutoCompleteFrame
dofile("Modules/Tracker/AutoCompleteFrame.lua")
local AutoCompleteFrame = QuestieLoader:ImportModule("AutoCompleteFrame")

describe("AutoCompleteFrame", function()
    local screenMock, indexMock, titleMock

    before_each(function()
        screenMock = stub(_G, "GetScreenWidth", function() return screenWidth end)
        local compat = QuestieLoader:ImportModule("QuestieCompat")
        indexMock = stub(compat, "GetQuestLogIndexByID", function() return 7 end)
        titleMock = stub(compat, "GetQuestLogTitle", function() return "Test Quest" end)
        CreateFrame.resetMockedFrames()

        Questie.db.profile.trackerBackdropColor = {r = 0, g = 0, b = 0, a = 1}
    end)

    after_each(function()
        screenMock:revert()
        indexMock:revert()
        titleMock:revert()
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

            assert.spy(indexMock).was.called_with(1)
            assert.spy(titleMock).was.called_with(7)
            assert.spy(frame.questTitle.SetText).was.called_with(frame.questTitle, "Test Quest")
            assert.is_equal(1, frame.questId)
            assert.spy(frame.Show).was.called()
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

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPLEFT", baseFrame, -250, 0)
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

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPRIGHT", baseFrame, 250, 0)
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

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPLEFT", baseFrame, -250, 0)
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

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPRIGHT", baseFrame, 250, 0)
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

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPLEFT", baseFrame, -250, 0)
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

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPRIGHT", baseFrame, 250, 0)
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

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPLEFT", baseFrame, -250, 0)
        end)

        it("should show pop up on the left if Tracker is on the right side of the screen and anchored TOP", function()
            local baseFrame = {
                GetPoint = function()
                    return "TOP", nil, nil, 0
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPLEFT", baseFrame, -250, 0)
        end)

        it("should show pop up on the left if Tracker is on the right side of the screen and anchored BOTTOM", function()
            local baseFrame = {
                GetPoint = function()
                    return "BOTTOM", nil, nil, 0
                end
            }
            AutoCompleteFrame.Initialize(baseFrame)
            local frame = CreateFrame.mockedFrames[1]
            frame.SetPoint = spy.new(frame.SetPoint)

            AutoCompleteFrame.ShowAutoComplete(1)

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPLEFT", baseFrame, -250, 0)
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

            assert.spy(frame.SetPoint).was.called_with(frame, "TOPRIGHT", baseFrame, 250, 0)
        end)
    end)
end)
