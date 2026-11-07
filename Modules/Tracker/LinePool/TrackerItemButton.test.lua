dofile("setupTests.lua")
local stub = require("luassert.stub")
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

QuestieCompat.GetContainerNumSlots = function(bag)
        if bag == -2 then
            return 1
        end
        return 0
    end
QuestieCompat.GetContainerItemInfo = function()
        return 11111, nil, nil, nil, nil, nil, nil, nil, nil, 123
    end

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
    local getItemCountMock, getItemCooldownMock, itemCount

    before_each(function()
        Questie.db.profile = {}
        QuestieCompat.GetContainerNumSlots = function(bag) return bag == -2 and 1 or 0 end
        QuestieCompat.GetContainerItemInfo = function() return 11111, nil, nil, nil, nil, nil, nil, nil, nil, 123 end
        _G.GetInventoryItemID = function() return 123 end
        CreateFrame.resetMockedFrames()
        itemCount = 3
        getItemCountMock = stub(QuestieCompat, "GetItemCount", function() return itemCount end)
        getItemCooldownMock = stub(QuestieCompat, "GetItemCooldown", function() return 0, 0, 1 end)

        -- QuestieDB binds the provider schema and queries at file load.
        LoadQuestieDBMock()
        dofile("Database/QuestieDB.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        dofile("Modules/Tracker/LinePool/TrackerItemButton.lua")
        TrackerItemButton = QuestieLoader:ImportModule("TrackerItemButton")
    end)

    after_each(function()
        getItemCountMock:revert()
        getItemCooldownMock:revert()
    end)

    describe("hover", function()
        local TrackerFadeTicker, originals, onHighlightEnter, onHighlightLeave

        before_each(function()
            TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
            originals = {
                Unfade = TrackerFadeTicker.Unfade,
                Fade = TrackerFadeTicker.Fade,
                GameTooltip = _G.GameTooltip,
                GetScreenWidth = _G.GetScreenWidth,
            }
            onHighlightEnter = spy.new(function() end)
            onHighlightLeave = spy.new(function() end)
            TrackerFadeTicker.Unfade = function() end
            TrackerFadeTicker.Fade = function() end
            _G.GameTooltip = {SetOwner = function() end, SetHyperlink = function() end, Show = function() end, Hide = function() end}
            _G.GetScreenWidth = function() return 1000 end
        end)

        after_each(function()
            TrackerFadeTicker.Unfade = originals.Unfade
            TrackerFadeTicker.Fade = originals.Fade
            _G.GameTooltip = originals.GameTooltip
            _G.GetScreenWidth = originals.GetScreenWidth
        end)

        local function _ButtonOn(parent)
            local button = TrackerItemButton.New("TestButton", onHighlightEnter, onHighlightLeave)
            button.GetCenter = function() return 0 end
            button.GetParent = function() return parent end
            return button
        end

        it("should highlight the quest of its line while hovered", function()
            local line = {Quest = {Id = 1}}
            local button = _ButtonOn(line)

            button.OnEnter(button)
            button.OnLeave(button)

            assert.spy(onHighlightEnter).was.called_with(line)
            assert.spy(onHighlightLeave).was.called()
        end)

        it("should not highlight anything while it is not attached to a quest line", function()
            local button = _ButtonOn({})

            button.OnEnter(button)

            assert.spy(onHighlightEnter).was.not_called()
        end)
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

    describe("cooldown and charges", function()
        local button, cooldown

        before_each(function()
            button = TrackerItemButton.New("TestButton")
            cooldown = CreateFrame.mockedFrames[2]
            cooldown.SetCooldown = spy.new(function() end)
            button:SetItem(123, 1, 15, true)
            getItemCooldownMock:clear()
            getItemCountMock:clear()
        end)

        it("should not query cooldown or charges every frame", function()
            local originalUnitExists = _G.UnitExists
            _G.UnitExists = function() return false end

            button:OnUpdate(0.1)

            _G.UnitExists = originalUnitExists
            assert.stub(getItemCooldownMock).was.not_called()
            assert.stub(getItemCountMock).was.not_called()
        end)

        it("should update the cooldown when BAG_UPDATE_COOLDOWN fires", function()
            getItemCooldownMock:revert()
            getItemCooldownMock = stub(QuestieCompat, "GetItemCooldown", function() return 10, 30, 1 end)

            button:OnEvent("BAG_UPDATE_COOLDOWN")

            assert.stub(getItemCooldownMock).was.called_with(123)
            assert.spy(cooldown.SetCooldown).was.called_with(cooldown, 10, 30, 1)
        end)

        it("should update the charges when BAG_UPDATE fires", function()
            itemCount = 5

            button:OnEvent("BAG_UPDATE")

            assert.is_equal(5, button.charges)
        end)
    end)

    describe("SetItem", function()
        it("accepts a Blizzard-designated quest item missing from the database", function()
            QuestieDB.QueryItemSingle = spy.new(function() return nil end)
            local button = TrackerItemButton.New("NativeQuestItem")
            assert.is_true(button:SetItem(123, 91741, 15, true))
            assert.are.equal("item:123", button.attributes.item1)
            assert.spy(QuestieDB.QueryItemSingle).was.not_called()
        end)

        it("still requires database classification for non-native candidates", function()
            QuestieDB.QueryItemSingle = function() return nil end
            local button = TrackerItemButton.New("UnverifiedItem")
            assert.is_false(button:SetItem(123, 91741, 15))
            assert.is_nil(button.attributes.item1)
        end)

        it("clears pooled identity when its next item is absent", function()
            local button = TrackerItemButton.New("ReusedItem")
            assert.is_true(button:SetItem(123, 91741, 15, true))
            assert.is_false(button:SetItem(456, 100, 15, true))
            assert.is_nil(button.itemId)
            assert.is_nil(button.questID)
            assert.is_nil(button.attributes.item1)
            assert.is_nil(button.attributes.type1)
            assert.is_false(button:IsVisible())
        end)

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
            assert.is_equal(3, trackerItemButton.charges)
            assert.spy(getItemCountMock).was.called_with(123, nil, true)
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
            QuestieCompat.GetContainerNumSlots = function()
                    return 0
                end
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
