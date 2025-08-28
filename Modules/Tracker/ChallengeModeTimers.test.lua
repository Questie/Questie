dofile("setupTests.lua")

describe("ChallengeModeTimer", function()
    
    ---@type ChallengeModeTimer
    local ChallengeModeTimer
    
    before_each(function()
        Questie.Colorize = spy.new(function(_, text, color)
            return text
        end)
        _G.C_ChallengeMode = {
            GetChallengeModeMapTimes = spy.new(function() return {400, 300, 200} end)
        }

        ChallengeModeTimer = require("Modules.Tracker.ChallengeModeTimer")
    end)
    
    describe("GetTimerString", function()
        it("should return placeholder timer when not in Challenge Mode", function()
            _G.GetWorldElapsedTime = function() return nil, 0 end
            _G.GetInstanceInfo = function() return nil, nil, nil, "10 Player", nil, nil, nil, 123 end
    
            local timer = ChallengeModeTimer.GetTimerString()
    
            assert.is_equal("00:00 / 00:00", timer)
            assert.spy(_G.C_ChallengeMode.GetChallengeModeMapTimes).was_not_called()
            assert.spy(Questie.Colorize).was_called_with(Questie, "00:00 / 00:00", "white")
        end)
    
        it("should return correct timer when within gold range", function()
            _G.GetWorldElapsedTime = function() return nil, 100 end
            _G.GetInstanceInfo = function() return nil, nil, nil, "Challenge Mode", nil, nil, nil, 123 end
    
            local timer = ChallengeModeTimer.GetTimerString()
    
            assert.is_equal("01:40 / 03:20", timer)
            assert.spy(_G.C_ChallengeMode.GetChallengeModeMapTimes).was.called_with(123)
            assert.spy(Questie.Colorize).was_called_with(Questie, "01:40 / ", "white")
            assert.spy(Questie.Colorize).was_called_with(Questie, "03:20", "F1E156")
        end)
    
        it("should return correct timer when within silver range", function()
            _G.GetWorldElapsedTime = function() return nil, 201 end
            _G.GetInstanceInfo = function() return nil, nil, nil, "Challenge Mode", nil, nil, nil, 123 end
    
            local timer = ChallengeModeTimer.GetTimerString()
    
            assert.is_equal("03:21 / 05:00", timer)
            assert.spy(_G.C_ChallengeMode.GetChallengeModeMapTimes).was.called_with(123)
            assert.spy(Questie.Colorize).was_called_with(Questie, "03:21 / ", "white")
            assert.spy(Questie.Colorize).was_called_with(Questie, "05:00", "C7B8BD")
        end)
    
        it("should return correct timer when within bronze range", function()
            _G.GetWorldElapsedTime = function() return nil, 301 end
            _G.GetInstanceInfo = function() return nil, nil, nil, "Challenge Mode", nil, nil, nil, 123 end
    
            local timer = ChallengeModeTimer.GetTimerString()
    
            assert.is_equal("05:01 / 06:40", timer)
            assert.spy(_G.C_ChallengeMode.GetChallengeModeMapTimes).was.called_with(123)
            assert.spy(Questie.Colorize).was_called_with(Questie, "05:01 / ", "white")
            assert.spy(Questie.Colorize).was_called_with(Questie, "06:40", "DB8B34")
        end)
    
        it("should return correct timer when below bronze range", function()
            _G.GetWorldElapsedTime = function() return nil, 401 end
            _G.GetInstanceInfo = function() return nil, nil, nil, "Challenge Mode", nil, nil, nil, 123 end
    
            local timer = ChallengeModeTimer.GetTimerString()
    
            assert.is_equal("06:41 / 00:00", timer)
            assert.spy(_G.C_ChallengeMode.GetChallengeModeMapTimes).was.called_with(123)
            assert.spy(Questie.Colorize).was_called_with(Questie, "06:41 / ", "white")
            assert.spy(Questie.Colorize).was_called_with(Questie, "00:00", "845321")
        end)
    end)
end)
