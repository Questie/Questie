dofile("setupTests.lua")

describe("QuestieShutUp", function()
    ---@type QuestieShutUp
    local QuestieShutUp

    before_each(function()
        _G.ChatFrameUtil = {
            AddMessageEventFilter = function() end,
            RemoveMessageEventFilter = function() end,
        }

        QuestieShutUp = require("Modules.QuestieShutUp")
        QuestieShutUp:ToggleFilters(true)
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
