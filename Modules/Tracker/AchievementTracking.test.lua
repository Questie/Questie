dofile("setupTests.lua")

describe("AchievementTracking", function()
    ---@type AchievementTracking
    local AchievementTracking

    local globalNames = {"GetTrackedAchievements", "RemoveTrackedAchievement", "C_ContentTracking", "Enum", "C_GameRules", "Constants"}
    local originals

    local function _UseLegacyApi()
        _G.GetTrackedAchievements = function() return 5, 6, 7 end
        _G.RemoveTrackedAchievement = spy.new(function() end)
    end

    local function _UseContentTrackingApi(gameRuleActive)
        _G.Enum = {
            ContentTrackingType = {Achievement = 2},
            ContentTrackingStopType = {Manual = 1},
            GameRule = {TrackAchievementsDisabled = 99},
        }
        _G.C_ContentTracking = {
            GetTrackedIDs = spy.new(function() return {8, 9} end),
            StopTracking = spy.new(function() end),
        }
        _G.C_GameRules = {IsGameRuleActive = function(rule) return gameRuleActive and rule == 99 end}
    end

    before_each(function()
        originals = {}
        for _, name in ipairs(globalNames) do
            originals[name] = _G[name]
            _G[name] = nil
        end

        dofile("Modules/Tracker/AchievementTracking.lua")
        AchievementTracking = QuestieLoader:ImportModule("AchievementTracking")
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = originals[name]
        end
    end)

    describe("IsSupported", function()
        it("should return true when the legacy API exists", function()
            _UseLegacyApi()

            assert.is_true(AchievementTracking.IsSupported())
        end)

        it("should return true when C_ContentTracking exists", function()
            _UseContentTrackingApi(false)

            assert.is_true(AchievementTracking.IsSupported())
        end)

        it("should return false when achievement tracking is disabled by a game rule", function()
            _UseContentTrackingApi(true)

            assert.is_false(AchievementTracking.IsSupported())
        end)

        it("should return false when C_ContentTracking is only partly available", function()
            _UseContentTrackingApi(false)
            _G.Enum.ContentTrackingStopType = nil

            assert.is_false(AchievementTracking.IsSupported())
        end)

        it("should return false when no API exists", function()
            assert.is_false(AchievementTracking.IsSupported())
        end)
    end)

    describe("GetTrackedIds", function()
        it("should collect the ids of the legacy API", function()
            _UseLegacyApi()

            assert.are_same({5, 6, 7}, AchievementTracking.GetTrackedIds())
        end)

        it("should return an empty list when the legacy API tracks nothing", function()
            _G.GetTrackedAchievements = function() end

            assert.are_same({}, AchievementTracking.GetTrackedIds())
        end)

        it("should read the achievement ids from C_ContentTracking", function()
            _UseContentTrackingApi(false)

            assert.are_same({8, 9}, AchievementTracking.GetTrackedIds())
            assert.spy(C_ContentTracking.GetTrackedIDs).was.called_with(2)
        end)

        it("should return an empty list when no API exists", function()
            assert.are_same({}, AchievementTracking.GetTrackedIds())
        end)
    end)

    describe("GetMaxTracked", function()
        it("should return the limit of the game", function()
            _G.Constants = {ContentTrackingConsts = {MaxTrackedAchievements = 12}}

            assert.are_same(12, AchievementTracking.GetMaxTracked())
        end)

        it("should default to 10", function()
            assert.are_same(10, AchievementTracking.GetMaxTracked())
        end)
    end)

    describe("Untrack", function()
        it("should call RemoveTrackedAchievement with the Questie flag on the legacy API", function()
            _UseLegacyApi()

            AchievementTracking.Untrack(123, true)

            assert.spy(RemoveTrackedAchievement).was.called_with(123, true)
        end)

        it("should stop tracking through C_ContentTracking", function()
            _UseContentTrackingApi(false)

            AchievementTracking.Untrack(123)

            assert.spy(C_ContentTracking.StopTracking).was.called_with(2, 123, 1)
        end)

        it("should do nothing when no API exists", function()
            assert.has_no.errors(function() AchievementTracking.Untrack(123) end)
        end)
    end)
end)
