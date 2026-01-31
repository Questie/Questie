---@diagnostic disable: param-type-mismatch
dofile("setupTests.lua")

describe("RegisterOnReady", function()
    ---@type QuestieAPI
    local QuestieAPI

    before_each(function()
        dofile("Public/Enums.lua")
        _G.Questie.API.isReady = true

        QuestieAPI = require("Public.RegisterOnReady")
    end)

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
