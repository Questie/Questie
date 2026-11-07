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
            SetPadding = spy.new(function() end),
        }
        _G.ShowUIPanel = function() end
        _G.UIParent = {}

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function(questId)
            return {Id = questId}
        end

        QuestieLink = QuestieLoader:ImportModule("QuestieLink")
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
    end)

    it("should delegate to the fallback handler when the quest is not in QuestieDB", function()
        local fallbackHandler = spy.new(function() end)
        local link = "questie:99999:GUID-0-1234"
        QuestieDB.GetQuest = function() return nil end

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.called_with(ItemRefTooltip, link)
    end)

    it("should build the quest tooltip for questie links without calling the fallback handler", function()
        local fallbackHandler = spy.new(function() end)
        local link = "questie:74:GUID-0-1234"

        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(fallbackHandler).was.not_called()
        assert.spy(QuestieLink.CreateQuestTooltip).was.called()
        assert.are_same(link, QuestieLink.CreateQuestTooltip.calls[1].vals[2])
        assert.spy(ItemRefTooltip.Show).was.called()
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

        -- First click: tooltip is closed, so it opens and tracks quest 74.
        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        -- Second click on the same link while the tooltip is still shown should close it.
        ItemRefTooltip.IsShown = function() return true end
        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, link)

        assert.spy(ItemRefTooltip.Hide).was.called()
    end)

    it("should not hide the tooltip when a different quest happens to render the same title", function()
        local fallbackHandler = spy.new(function() end)

        -- First click opens quest 74.
        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, "questie:74:GUID-0-1234")

        -- Second click on a different quest while the tooltip is still shown
        ItemRefTooltip.IsShown = function() return true end
        HandleSetHyperlink.Run(ItemRefTooltip, fallbackHandler, "questie:75:GUID-0-5678")

        assert.spy(ItemRefTooltip.Hide).was.not_called()
    end)

    describe("ProcessLink", function()
        before_each(function()
            _G.LinkProcessorResponse = {Unhandled = 1, Handled = 2}
            _G.IsModifiedClick = function() return false end
        end)

        it("should return Handled and show the quest tooltip for a known quest", function()
            local response = HandleSetHyperlink.ProcessLink("quest:74:28")

            assert.are_equal(LinkProcessorResponse.Handled, response)
            assert.spy(QuestieLink.CreateQuestTooltip).was.called()
        end)

        it("should return Handled and show the quest tooltip for a questie link", function()
            local response = HandleSetHyperlink.ProcessLink("questie:74:GUID-0-1234")

            assert.are_equal(LinkProcessorResponse.Handled, response)
            assert.spy(QuestieLink.CreateQuestTooltip).was.called()
        end)

        it("should pad the tooltip so the title does not overlap the close button", function()
            local match = require("luassert.match")
            HandleSetHyperlink.ProcessLink("quest:74:28")

            assert.spy(ItemRefTooltip.SetPadding).was.called_with(match.is_ref(ItemRefTooltip), 16, 0)
        end)

        it("should return Unhandled when the quest is not in QuestieDB", function()
            QuestieDB.GetQuest = function() return nil end

            local response = HandleSetHyperlink.ProcessLink("quest:99999:28")

            assert.are_equal(LinkProcessorResponse.Unhandled, response)
            assert.spy(QuestieLink.CreateQuestTooltip).was.not_called()
        end)

        it("should return Unhandled for modified clicks without showing the quest tooltip", function()
            _G.IsModifiedClick = function() return true end

            local response = HandleSetHyperlink.ProcessLink("questie:74:GUID-0-1234")

            assert.are_equal(LinkProcessorResponse.Unhandled, response)
            assert.spy(QuestieLink.CreateQuestTooltip).was.not_called()
        end)
    end)
end)
