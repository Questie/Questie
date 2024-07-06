dofile("setupTests.lua")

_G.QuestieCompat = {
    GetContainerNumSlots = function(bag)
        if bag == -2 then
            return 1
        end
        return 0
    end,
    GetContainerItemInfo = function()
        return "testTexture", nil, nil, nil, nil, nil, nil, nil, nil, 123
    end
}

describe("TrackerItemButton", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type TrackerItemButton
    local TrackerItemButton

    before_each(function()
        Questie.db.profile = {}
        CreateFrame.resetMockedFrames()

        QuestieDB = require("Database.QuestieDB")
        TrackerItemButton = require("Modules.Tracker.TrackerItemButton")
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

    describe("SetItem", function()
        it("should set itemId to sourceItemId for primary button", function()
            local quest = {
                sourceItemId = 123
            }
            QuestieDB.QueryItemSingle = spy.new(function()
                return QuestieDB.itemClasses.QUEST
            end)

            local trackerItemButton = TrackerItemButton.New("TestButton")

            trackerItemButton:SetItem(quest, "primary", 15)

            assert.equals(123, trackerItemButton.itemId)
        end)
    end)
end)
