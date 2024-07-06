dofile("setupTests.lua")

_G.QuestieCompat = {
    GetContainerNumSlots = function(bag)
        if bag == -2 then
            return 1
        end
        return 0
    end,
    GetContainerItemInfo = function()
        return 11111, nil, nil, nil, nil, nil, nil, nil, nil, 123
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

        assert.is_nil(trackerItemButton:GetAlpha())

        assert.equals(0, table.getn(trackerItemButton.scripts))
        assert.equals(0, table.getn(trackerItemButton.attributes))
    end)

    it("should set alpha to 0 when trackerFadeQuestItemButtons is true", function()
        Questie.db.profile.trackerFadeQuestItemButtons = true
        local trackerItemButton = TrackerItemButton.New("TestButton")

        assert.equals(0, trackerItemButton:GetAlpha())
    end)

    describe("SetItem", function()
        it("should set itemId to sourceItemId for primary button", function()
            local quest = {
                Id = 1,
                sourceItemId = 123
            }
            QuestieDB.QueryItemSingle = function()
                return QuestieDB.itemClasses.QUEST
            end

            local trackerItemButton = TrackerItemButton.New("TestButton")

            local isValid = trackerItemButton:SetItem(quest, "primary", 15)

            assert.is_true(isValid)
            assert.is_true(trackerItemButton:IsVisible())
            assert.equals(123, trackerItemButton.itemId)
            assert.equals(1, trackerItemButton.questID)
            assert.equals(0, trackerItemButton.charges)
            assert.equals(-1, trackerItemButton.rangeTimer)

            assert.equals(11111, trackerItemButton:GetNormalTexture():GetTexture())
            assert.equals(11111, trackerItemButton:GetPushedTexture():GetTexture())
            assert.equals("Interface\\Buttons\\ButtonHilight-Square", trackerItemButton:GetHighlightTexture():GetTexture())

            local width, height = trackerItemButton:GetSize()
            assert.equals(15, width)
            assert.equals(15, height)

            assert.is_not_nil(trackerItemButton.scripts["OnEvent"])
            assert.is_not_nil(trackerItemButton.scripts["OnShow"])
            assert.is_not_nil(trackerItemButton.scripts["OnHide"])
            assert.is_not_nil(trackerItemButton.scripts["OnEnter"])
            assert.is_not_nil(trackerItemButton.scripts["OnLeave"])

            assert.equals("item", trackerItemButton.attributes["type1"])
            assert.equals("item:123", trackerItemButton.attributes["item1"])
        end)

        it("should return false when item is not found", function()
            _G.GetInventoryItemID = function()
                return 0
            end
            local quest = {
                Id = 1,
                sourceItemId = 123
            }
            QuestieDB.QueryItemSingle = function()
                return 0
            end

            local trackerItemButton = TrackerItemButton.New("TestButton")

            local isValid = trackerItemButton:SetItem(quest, "primary", 15)

            assert.is_false(isValid)
            assert.is_false(trackerItemButton:IsVisible())
            assert.equals(0, table.getn(trackerItemButton.scripts))
            assert.equals(0, table.getn(trackerItemButton.attributes))
        end)
    end)
end)
