dofile("setupTests.lua")
local stub = require("luassert.stub")
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("TrackerItemButton", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type TrackerItemButton
    local TrackerItemButton
    local getItemCountMock
    local originalCreateFrame, originalInventoryId, originalInventoryTexture
    local originalSlots, originalItemInfo

    before_each(function()
        originalCreateFrame = _G.CreateFrame
        originalInventoryId = _G.GetInventoryItemID
        originalInventoryTexture = _G.GetInventoryItemTexture
        originalSlots = QuestieCompat.GetContainerNumSlots
        originalItemInfo = QuestieCompat.GetContainerItemInfo
        QuestieCompat.GetContainerNumSlots = function(bag) return bag == -2 and 1 or 0 end
        QuestieCompat.GetContainerItemInfo = function()
            return 11111, nil, nil, nil, nil, nil, nil, nil, nil, 123
        end
        _G.GetInventoryItemID = function() return 123 end
        _G.GetInventoryItemTexture = function() return 11111 end
        Questie.db.profile = {}
        CreateFrame.resetMockedFrames()
        _G.CreateFrame = function(...)
            local frame = originalCreateFrame(...)
            frame.HookScript = function(self, event, callback)
                local previous = self.scripts[event]
                self.scripts[event] = function(...)
                    if previous then previous(...) end
                    callback(...)
                end
            end
            return frame
        end
        getItemCountMock = stub(QuestieCompat, "GetItemCount", function() return 3 end)

        -- QuestieDB binds the provider schema and queries at file load.
        LoadQuestieDBMock()
        dofile("Database/QuestieDB.lua")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        dofile("Modules/Tracker/LinePool/TrackerItemButton.lua")
        TrackerItemButton = QuestieLoader:ImportModule("TrackerItemButton")
    end)

    after_each(function()
        getItemCountMock:revert()
        _G.CreateFrame = originalCreateFrame
        _G.GetInventoryItemID = originalInventoryId
        _G.GetInventoryItemTexture = originalInventoryTexture
        QuestieCompat.GetContainerNumSlots = originalSlots
        QuestieCompat.GetContainerItemInfo = originalItemInfo
    end)

    it("should return an item button", function()
        local trackerItemButton = TrackerItemButton.New("TestButton")

        assert.is_not_nil(trackerItemButton)
        assert.is_equal("Button", trackerItemButton:GetObjectType())
        assert.is_equal("TestButton", trackerItemButton:GetName())
        assert.is_equal("Cooldown", originalCreateFrame.mockedFrames[2]:GetObjectType())

        assert.is_equal(1, trackerItemButton:GetAlpha())

        assert.is_function(trackerItemButton.scripts.OnUpdate)
        assert.are.same({}, trackerItemButton.attributes)
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
            QuestieCompat.GetContainerNumSlots = function() return 0 end
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
            assert.is_function(trackerItemButton.scripts.OnUpdate)
            assert.are.same({}, trackerItemButton.attributes)
        end)
    end)
end)
