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

_G.GetInventoryItemID = function()
    return 123
end

_G.GetInventoryItemTexture = function()
    return 11111
end

describe("TrackerItemButton", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type TrackerItemButton
    local TrackerItemButton

    before_each(function()
        Questie.db.profile = {}
        CreateFrame.resetMockedFrames()

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        dofile("Modules/Tracker/LinePool/TrackerItemButton.lua")
        TrackerItemButton = QuestieLoader:ImportModule("TrackerItemButton")
    end)

    it("should return an item button", function()
        local trackerItemButton = TrackerItemButton.New("TestButton")

        assert.is_not_nil(trackerItemButton)
        assert.is_equal("Button", trackerItemButton:GetObjectType())
        assert.is_equal("TestButton", trackerItemButton:GetName())
        assert.is_equal("Cooldown", CreateFrame.mockedFrames[2]:GetObjectType())

        assert.is_equal(1, trackerItemButton:GetAlpha())

        assert.is_equal(0, table.getn(trackerItemButton.scripts))
        assert.is_equal(0, table.getn(trackerItemButton.attributes))
    end)

    it("should set alpha to 0 when trackerFadeQuestItemButtons is true", function()
        Questie.db.profile.trackerFadeQuestItemButtons = true
        local trackerItemButton = TrackerItemButton.New("TestButton")

        assert.is_equal(0, trackerItemButton:GetAlpha())
    end)

    describe("SetItem", function()
        it("should set itemId", function()
            QuestieDB.QueryItemSingle = function()
                return QuestieDB.itemClasses.QUEST
            end

            local trackerItemButton = TrackerItemButton.New("TestButton")

            local isValid = trackerItemButton:SetItem(123, 1, 15)

            assert.is_true(isValid)
            assert.is_true(trackerItemButton:IsVisible())
            assert.is_equal(123, trackerItemButton.itemId)
            assert.is_equal(1, trackerItemButton.questID)
            assert.is_equal(0, trackerItemButton.charges)
            assert.is_equal(-1, trackerItemButton.rangeTimer)

            assert.is_equal(11111, trackerItemButton:GetNormalTexture():GetTexture())
            assert.is_equal(11111, trackerItemButton:GetPushedTexture():GetTexture())
            assert.is_equal("Interface\\Buttons\\ButtonHilight-Square", trackerItemButton:GetHighlightTexture():GetTexture())

            local width, height = trackerItemButton:GetSize()
            assert.is_equal(15, width)
            assert.is_equal(15, height)

            assert.is_not_nil(trackerItemButton.scripts["OnEvent"])
            assert.is_not_nil(trackerItemButton.scripts["OnShow"])
            assert.is_not_nil(trackerItemButton.scripts["OnHide"])
            assert.is_not_nil(trackerItemButton.scripts["OnEnter"])
            assert.is_not_nil(trackerItemButton.scripts["OnLeave"])

            assert.is_equal("item", trackerItemButton.attributes["type1"])
            assert.is_equal("item:123", trackerItemButton.attributes["item1"])
        end)

        it("should set itemId when item is equipped", function()
            _G.QuestieCompat = {
                GetContainerNumSlots = function()
                    return 0
                end,
            }
            QuestieDB.QueryItemSingle = function()
                return QuestieDB.itemClasses.QUEST
            end

            local trackerItemButton = TrackerItemButton.New("TestButton")

            local isValid = trackerItemButton:SetItem(123, 1, 15)

            assert.is_true(isValid)
            assert.is_true(trackerItemButton:IsVisible())
            assert.is_equal(123, trackerItemButton.itemId)
            assert.is_equal(1, trackerItemButton.questID)
        end)

        it("should return false when item is not found", function()
            _G.GetInventoryItemID = function()
                return 0
            end
            QuestieDB.QueryItemSingle = function()
                return 0
            end

            local trackerItemButton = TrackerItemButton.New("TestButton")

            local isValid = trackerItemButton:SetItem(123, 1, 15)

            assert.is_false(isValid)
            assert.is_false(trackerItemButton:IsVisible())
            assert.is_equal(0, table.getn(trackerItemButton.scripts))
            assert.is_equal(0, table.getn(trackerItemButton.attributes))
        end)
    end)
end)
