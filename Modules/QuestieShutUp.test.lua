dofile("setupTests.lua")
local stub = require("luassert.stub")

describe("QuestieShutUp", function()
    ---@type QuestieShutUp
    local QuestieShutUp
    local addFilterMock, removeFilterMock

    before_each(function()
        local compat = QuestieLoader:ImportModule("QuestieCompat")
        addFilterMock = stub(compat, "AddMessageEventFilter")
        removeFilterMock = stub(compat, "RemoveMessageEventFilter")

        dofile("Modules/QuestieShutUp.lua")
        QuestieShutUp = QuestieLoader:ImportModule("QuestieShutUp")
        QuestieShutUp:ToggleFilters(true)
    end)

    after_each(function()
        addFilterMock:revert()
        removeFilterMock:revert()
    end)

    it("registers and removes the same group-chat filter", function()
        assert.spy(addFilterMock).was.called(6)
        assert.spy(addFilterMock).was.called_with("CHAT_MSG_PARTY", QuestieShutUp.FilterFunc)
        assert.spy(addFilterMock).was.called_with("CHAT_MSG_INSTANCE_CHAT_LEADER", QuestieShutUp.FilterFunc)

        QuestieShutUp:ToggleFilters(false)

        assert.spy(removeFilterMock).was.called(6)
        assert.spy(removeFilterMock).was.called_with("CHAT_MSG_PARTY", QuestieShutUp.FilterFunc)
        assert.spy(removeFilterMock).was.called_with("CHAT_MSG_INSTANCE_CHAT_LEADER", QuestieShutUp.FilterFunc)
    end)

    describe("FilterFunc", function()
        it("should filter Questie messages prefixed with the star raid icon", function()
            local result = QuestieShutUp.FilterFunc(nil, "CHAT_MSG_PARTY", "{rt1} Questie: Some quest update", "SomePlayer")

            assert.is_true(result)
        end)

        it("should filter Russian Questie messages prefixed with the star raid icon", function()
            local result = QuestieShutUp.FilterFunc(nil, "CHAT_MSG_PARTY", "{звезда} Questie: Some quest update", "SomePlayer")

            assert.is_true(result)
        end)

        it("should filter messages starting with the questie logo texture", function()
            local result = QuestieShutUp.FilterFunc(nil, "CHAT_MSG_PARTY", "|TInterface\\Addons\\Questie\\Icons\\questie.png:0|t Some quest update", "SomePlayer")

            assert.is_true(result)
        end)

        it("should filter messages with French spacing before the colon", function()
            local result = QuestieShutUp.FilterFunc(nil, "CHAT_MSG_PARTY", "{rt1} Questie : Some quest update", "SomePlayer")

            assert.is_true(result)
        end)

        it("should not filter a regular chat message", function()
            local result = QuestieShutUp.FilterFunc(nil, "CHAT_MSG_PARTY", "Hello everyone!", "SomePlayer")

            assert.is_nil(result)
        end)

        it("should not filter a regular chat message about Questie", function()
            local result = QuestieShutUp.FilterFunc(nil, "CHAT_MSG_PARTY", "Questie: great addon", "SomePlayer")

            assert.is_nil(result)
        end)
    end)
end)
