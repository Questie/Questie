---@diagnostic disable: param-type-mismatch
dofile("setupTests.lua")

describe("RegisterForQuestUpdates", function()
    ---@type QuestieNameplate
    local QuestieNameplate

    ---@type QuestieAPI
    local QuestieAPI

    before_each(function()
        dofile("Public/Enums.lua")
        _G.Questie.API.isReady = true

        QuestieNameplate = require("Modules.QuestieNameplate")
        ---@diagnostic disable-next-line: assign-type-mismatch
        QuestieNameplate.GetIcon = spy.new(function()
            return "Interface\\Addons\\Questie\\Icons\\slay.blp"
        end)

        QuestieAPI = require("Public.RegisterForQuestUpdates")
    end)

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
