---@diagnostic disable: param-type-mismatch
dofile("setupTests.lua")

describe("API", function()
    ---@type QuestieNameplate
    local QuestieNameplate

    ---@type QuestieAPI
    local QuestieAPI

    before_each(function()
        _G.Questie.API.isReady = true

        QuestieNameplate = require("Modules.QuestieNameplate")
        ---@diagnostic disable-next-line: assign-type-mismatch
        QuestieNameplate.GetIcon = spy.new(function()
            return "Interface\\Addons\\Questie\\Icons\\slay.blp"
        end)

        QuestieAPI = require("Modules.API")
    end)

    describe("RegisterOnReady", function()
        it("should error when callback is not a function", function()
            assert.has_error(function()
                _G.Questie.API.RegisterOnReady(nil)
            end)
            assert.has_error(function()
                _G.Questie.API.RegisterOnReady(123)
            end)
            assert.has_error(function()
                _G.Questie.API.RegisterOnReady("not-a-function")
            end)
            assert.has_error(function()
                _G.Questie.API.RegisterOnReady(true)
            end)
            assert.has_error(function()
                _G.Questie.API.RegisterOnReady({})
            end)
        end)

        it("should register and call the callback once the Questie API is ready", function()
            _G.Questie.API.isReady = false
            local callbackSpy = spy.new(function() end)

            _G.Questie.API.RegisterOnReady(function() callbackSpy() end)
            assert.spy(callbackSpy).was.not_called()

            _G.Questie.API.isReady = true
            QuestieAPI.PropagateOnReady()

            assert.spy(callbackSpy).was.called()
        end)

        it("should call the callback immediately if the Questie API is already ready", function()
            _G.Questie.API.isReady = true
            local callbackSpy = spy.new(function() end)

            _G.Questie.API.RegisterOnReady(function() callbackSpy() end)

            assert.spy(callbackSpy).was.called()
        end)

        it("should not call the callback when not ready yet", function()
            _G.Questie.API.isReady = false
            local callbackSpy = spy.new(function() end)

            _G.Questie.API.RegisterOnReady(function() callbackSpy() end)
            QuestieAPI.PropagateOnReady()

            assert.spy(callbackSpy).was.not_called()
        end)
    end)

    describe("GetQuestObjectiveIconForUnit", function()
        it("should return nil when Questie API is not ready", function()
            _G.Questie.API.isReady = false

            local result = _G.Questie.API.GetQuestObjectiveIconForUnit("some-guid")

            assert.is_nil(result)
        end)

        it("should return icon path when Questie API is ready", function()
            local result = _G.Questie.API.GetQuestObjectiveIconForUnit("some-guid")

            assert.is_equal("Interface\\Addons\\Questie\\Icons\\slay.blp", result)
            assert.spy(QuestieNameplate.GetIcon).was.called_with("some-guid")
        end)
    end)

    describe("RegisterForQuestUpdates", function()
        it("should error when callback is not a function", function()
            assert.has_error(function()
                _G.Questie.API.RegisterForQuestUpdates(nil)
            end)
            assert.has_error(function()
                _G.Questie.API.RegisterForQuestUpdates(123)
            end)
            assert.has_error(function()
                _G.Questie.API.RegisterForQuestUpdates("not-a-function")
            end)
            assert.has_error(function()
                _G.Questie.API.RegisterForQuestUpdates(true)
            end)
            assert.has_error(function()
                _G.Questie.API.RegisterForQuestUpdates({})
            end)
        end)

        it("should register and call the callback on quest update", function()
            local callbackSpy = spy.new(function() end)

            _G.Questie.API.RegisterForQuestUpdates(function(...) callbackSpy(...) end)
            QuestieAPI.PropagateQuestUpdate(1234, {1, 2}, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_UPDATED)

            assert.spy(callbackSpy).was.called(2)
            assert.spy(callbackSpy).was.called_with(1234, 1, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_UPDATED)
            assert.spy(callbackSpy).was.called_with(1234, 2, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_UPDATED)
        end)

        it("should call the callback with nil objective index when no indices are provided", function()
            local callbackSpy = spy.new(function() end)

            _G.Questie.API.RegisterForQuestUpdates(function(...) callbackSpy(...) end)
            QuestieAPI.PropagateQuestUpdate(5678, {}, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_ACCEPTED)

            assert.spy(callbackSpy).was.called(1)
            assert.spy(callbackSpy).was.called_with(5678, nil, QuestieAPI.Enums.QuestUpdateTriggerReason.QUEST_ACCEPTED)
        end)
    end)
end)
