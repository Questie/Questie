---@diagnostic disable: param-type-mismatch
dofile("setupTests.lua")

describe("RegisterOnReady", function()
    ---@type QuestieAPI
    local QuestieAPI

    local originalErrorHandler

    before_each(function()
        originalErrorHandler = _G.CallErrorHandler
        dofile("Public/Enums.lua")
        _G.Questie.API.isReady = true

        dofile("Public/RegisterOnReady.lua")
        QuestieAPI = QuestieLoader:ImportModule("QuestieAPI")
    end)

    after_each(function()
        _G.CallErrorHandler = originalErrorHandler
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

        QuestieAPI.PropagateOnReady()
        assert.spy(callbackSpy).was.called(1)
    end)

    it("should call the callback immediately if the Questie API is already ready", function()
        _G.Questie.API.isReady = true
        local callbackSpy = spy.new(function() end)

        _G.Questie.API.RegisterOnReady(function() callbackSpy() end)

        QuestieAPI.PropagateOnReady()
        assert.spy(callbackSpy).was.called(1)
    end)

    it("should not call the callback when not ready yet", function()
        _G.Questie.API.isReady = false
        local callbackSpy = spy.new(function() end)

        _G.Questie.API.RegisterOnReady(function() callbackSpy() end)
        QuestieAPI.PropagateOnReady()

        assert.spy(callbackSpy).was.not_called()
    end)

    it("reports a failing deferred callback without blocking healthy subscribers or replaying either", function()
        Questie.API.isReady = false
        local errors = spy.new(function() end)
        _G.CallErrorHandler = function(err) errors(err) end
        local failing = spy.new(function() error("ready failure", 0) end)
        local healthy = spy.new(function() end)
        Questie.API.RegisterOnReady(function() failing() end)
        Questie.API.RegisterOnReady(function() healthy() end)

        Questie.API.isReady = true
        QuestieAPI.PropagateOnReady()
        QuestieAPI.PropagateOnReady()

        assert.spy(failing).was.called(1)
        assert.spy(healthy).was.called(1)
        assert.spy(errors).was.called(1)
        assert.spy(errors).was.called_with("ready failure")
    end)

    it("reports an immediately invoked callback error", function()
        local errors = spy.new(function() end)
        _G.CallErrorHandler = function(err) errors(err) end

        Questie.API.RegisterOnReady(function() error("immediate failure", 0) end)

        assert.spy(errors).was.called_with("immediate failure")
    end)
end)
