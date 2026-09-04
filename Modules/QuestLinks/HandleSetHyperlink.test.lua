dofile("setupTests.lua")

describe("HandleSetHyperlink", function()
    ---@type HandleSetHyperlink
    local HandleSetHyperlink
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieLink
    local QuestieLink

    before_each(function()
        Questie.started = true

        _G.ItemRefTooltip = {
            IsShown = function() return false end,
            SetOwner = function() end,
            ClearLines = function() end,
            Show = spy.new(function() end),
            Hide = spy.new(function() end),
        }
        _G.ShowUIPanel = function() end
        _G.UIParent = {}

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function(questId)
            return {Id = questId}
        end

        QuestieLink = QuestieLoader:ImportModule("QuestieLink")
        QuestieLink.lastItemRefTooltip = nil
        QuestieLink.CreateQuestTooltip = spy.new(function() end)

        dofile("Modules/QuestLinks/HandleSetHyperlink.lua")
        HandleSetHyperlink = QuestieLoader:ImportModule("HandleSetHyperlink")
    end)

    it("should delegate to the fallback handler when Questie is not started", function()
        local fallbackHandler = spy.new(function() end)
        local link = "questie:99999:GUID-0-1234"
        Questie.started = false

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.called_with(ItemRefTooltip, link)
        assert.spy(QuestieLink.CreateQuestTooltip).was.not_called()
    end)

    it("should delegate to the fallback handler when the link is not a quest link", function()
        local fallbackHandler = spy.new(function() end)
        local link = "item:12345:0:0:0"

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.called_with(ItemRefTooltip, link)
        assert.is_nil(QuestieLink.lastItemRefTooltip)
    end)

    it("should delegate to the fallback handler when the quest is not in QuestieDB", function()
        local fallbackHandler = spy.new(function() end)
        local link = "questie:99999:GUID-0-1234"
        QuestieDB.GetQuest = function() return nil end

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.called_with(ItemRefTooltip, link)
        assert.is_nil(QuestieLink.lastItemRefTooltip)
    end)

    it("should build the quest tooltip for questie links without calling the fallback handler", function()
        local fallbackHandler = spy.new(function() end)
        local link = "questie:74:GUID-0-1234"

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.not_called()
        assert.spy(QuestieLink.CreateQuestTooltip).was.called()
        assert.are_same(link, QuestieLink.CreateQuestTooltip.calls[1].vals[2])
        assert.spy(ItemRefTooltip.Show).was.called()
        assert.is_equal(74, QuestieLink.lastItemRefTooltip)
    end)

    it("should build the quest tooltip for native quest links without calling the fallback handler", function()
        local fallbackHandler = spy.new(function() end)
        local link = "quest:74:28"

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.not_called()
        assert.spy(QuestieLink.CreateQuestTooltip).was.called()
        assert.are_same("questie:74:0", QuestieLink.CreateQuestTooltip.calls[1].vals[2])
        assert.spy(ItemRefTooltip.Show).was.called()
    end)

    it("should hide the tooltip on a repeated click of the same quest", function()
        local fallbackHandler = spy.new(function() end)
        local link = "questie:74:GUID-0-1234"
        ItemRefTooltip.IsShown = function() return true end
        QuestieLink.lastItemRefTooltip = 74

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(ItemRefTooltip.Hide).was.called()
        assert.is_nil(QuestieLink.lastItemRefTooltip)
    end)

    it("should not hide the tooltip when a different quest happens to render the same title", function()
        local fallbackHandler = spy.new(function() end)
        -- Quest 74 is already shown (title irrelevant: identity is tracked by questId, not by
        -- the rendered tooltip text, since unrelated quests can share the same display name).
        ItemRefTooltip.IsShown = function() return true end
        QuestieLink.lastItemRefTooltip = 74

        local link = "questie:75:GUID-0-5678"
        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(ItemRefTooltip.Hide).was.not_called()
        assert.is_equal(75, QuestieLink.lastItemRefTooltip)
    end)
end)
