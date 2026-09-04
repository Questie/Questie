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
            Hide = function() end,
        }
        _G.ItemRefTooltipTextLeft1 = {
            GetText = function() return "Test Quest" end,
        }
        _G.ShowUIPanel = function() end
        _G.UIParent = {}

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function(questId)
            return {Id = questId}
        end

        QuestieLink = QuestieLoader:ImportModule("QuestieLink")
        QuestieLink.lastItemRefTooltip = ""
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
        assert.is_equal("", QuestieLink.lastItemRefTooltip)
    end)

    it("should delegate to the fallback handler when the quest is not in QuestieDB", function()
        local fallbackHandler = spy.new(function() end)
        local link = "questie:99999:GUID-0-1234"
        QuestieDB.GetQuest = function() return nil end

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.called_with(ItemRefTooltip, link)
        assert.is_equal("", QuestieLink.lastItemRefTooltip)
    end)

    it("should build the quest tooltip for questie links without calling the fallback handler", function()
        local fallbackHandler = spy.new(function() end)
        local link = "questie:74:GUID-0-1234"

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.not_called()
        assert.spy(QuestieLink.CreateQuestTooltip).was.called()
        assert.are_same(link, QuestieLink.CreateQuestTooltip.calls[1].vals[2])
        assert.spy(ItemRefTooltip.Show).was.called()
        assert.is_equal("Test Quest", QuestieLink.lastItemRefTooltip)
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
end)
