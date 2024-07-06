dofile("setupTests.lua")

describe("TrackerItemButton", function()
    ---@type TrackerItemButton
    local TrackerItemButton = require("Modules.Tracker.TrackerItemButton")

    before_each(function()
        Questie.db.profile = {}
        CreateFrame.resetMockedFrames()
    end)

    it("should return an item button", function()
        local trackerItemButton = TrackerItemButton.New("TestButton")

        assert.is_not_nil(trackerItemButton)
        assert.equals("Button", trackerItemButton:GetObjectType())
        assert.equals("TestButton", trackerItemButton:GetName())
        assert.equals("Cooldown", CreateFrame.mockedFrames[2]:GetObjectType())

        assert.equals(nil, trackerItemButton:GetAlpha())
    end)

    it("should set alpha to 0 when trackerFadeQuestItemButtons is true", function()
        Questie.db.profile.trackerFadeQuestItemButtons = true
        local trackerItemButton = TrackerItemButton.New("TestButton")

        assert.equals(0, trackerItemButton:GetAlpha())
    end)
end)
