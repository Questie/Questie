dofile("setupTests.lua")

describe("TrackerItemButton", function()
    ---@type TrackerItemButton
    local TrackerItemButton = require("Modules.Tracker.TrackerItemButton")

    before_each(function()
        CreateFrame.resetMockedFrames()
    end)

    it("should return an item button", function()
        local trackerItemButton = TrackerItemButton.New("TestButton")

        assert.is_not_nil(trackerItemButton)
        assert.equals("Button", trackerItemButton:GetObjectType())
        assert.equals("TestButton", trackerItemButton:GetName())
        assert.equals("Cooldown", CreateFrame.mockedFrames[2]:GetObjectType())
    end)
end)
