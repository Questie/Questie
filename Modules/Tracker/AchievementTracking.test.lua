dofile("setupTests.lua")

describe("AchievementTracking", function()
    ---@type AchievementTracking
    local AchievementTracking
    ---@type Expansions
    local Expansions

    local globalNames = {"GetTrackedAchievements", "AddTrackedAchievement", "RemoveTrackedAchievement", "IsTrackedAchievement", "C_ContentTracking", "Enum", "Constants",
        "ToggleLegacySystemUI", "LegacySystemFrame", "LegacySystemFrame_LoadUI", "AchievementFrame", "AchievementFrame_LoadUI",
        "AchievementFrameAchievements", "AchievementFrame_ToggleAchievementFrame", "AchievementFrame_SelectAchievement",
        "AchievementFrameAchievements_ForceUpdate"}
    local originals, originalExpansion

    local function _UseLegacyApi()
        _G.GetTrackedAchievements = function() return 5, 6, 7 end
        _G.AddTrackedAchievement = spy.new(function() end)
        _G.RemoveTrackedAchievement = spy.new(function() end)
        _G.IsTrackedAchievement = function(id) return id == 5 end
    end

    local function _UseContentTrackingApi()
        _G.Enum = {
            ContentTrackingType = {Achievement = 2},
            ContentTrackingStopType = {Manual = 1},
        }
        _G.C_ContentTracking = {
            GetTrackedIDs = spy.new(function() return {8, 9} end),
            IsTracking = spy.new(function(_, id) return id == 8 end),
            StartTracking = spy.new(function() end),
            StopTracking = spy.new(function() end),
        }
    end

    before_each(function()
        originals = {}
        for _, name in ipairs(globalNames) do
            originals[name] = _G[name]
            _G[name] = nil
        end

        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        Expansions.Current = Expansions.Wotlk

        dofile("Modules/Tracker/AchievementTracking.lua")
        AchievementTracking = QuestieLoader:ImportModule("AchievementTracking")
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = originals[name]
        end
        Expansions.Current = originalExpansion
    end)

    describe("IsSupported", function()
        it("should return true when the legacy API exists", function()
            _UseLegacyApi()

            assert.is_true(AchievementTracking.IsSupported())
        end)

        it("should return false for the legacy API stubs of Era and TBC", function()
            _UseLegacyApi()

            for _, expansion in ipairs({Expansions.Era, Expansions.Tbc}) do
                Expansions.Current = expansion

                assert.is_false(AchievementTracking.IsSupported())
            end
        end)

        it("should return true when C_ContentTracking exists on Forever", function()
            Expansions.Current = Expansions.Era
            _UseContentTrackingApi()

            assert.is_true(AchievementTracking.IsSupported())
        end)

        it("should return true when C_ContentTracking exists", function()
            _UseContentTrackingApi()

            assert.is_true(AchievementTracking.IsSupported())
        end)

        it("should return false when C_ContentTracking is only partly available", function()
            _UseContentTrackingApi()
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

        it("should return an empty list for the legacy API stubs of Era and TBC", function()
            Expansions.Current = Expansions.Tbc
            _UseLegacyApi()
            _G.GetTrackedAchievements = spy.new(function() return nil end)

            assert.are_same({}, AchievementTracking.GetTrackedIds())
            assert.spy(GetTrackedAchievements).was.not_called()
        end)

        it("should return an empty list when the legacy API tracks nothing", function()
            _UseLegacyApi()
            _G.GetTrackedAchievements = function() end

            assert.are_same({}, AchievementTracking.GetTrackedIds())
        end)

        it("should read the achievement ids from C_ContentTracking", function()
            _UseContentTrackingApi()

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

    describe("IsTracked", function()
        it("should ask the legacy API", function()
            _UseLegacyApi()

            assert.is_true(AchievementTracking.IsTracked(5))
            assert.is_false(AchievementTracking.IsTracked(6))
        end)

        it("should ask C_ContentTracking", function()
            _UseContentTrackingApi()

            assert.is_true(AchievementTracking.IsTracked(8))
            assert.is_false(AchievementTracking.IsTracked(9))
            assert.spy(C_ContentTracking.IsTracking).was.called_with(2, 8)
        end)

        it("should return false when no API exists", function()
            assert.is_false(AchievementTracking.IsTracked(5))
        end)
    end)

    describe("Track", function()
        it("should call AddTrackedAchievement on the legacy API", function()
            _UseLegacyApi()

            AchievementTracking.Track(123)

            assert.spy(AddTrackedAchievement).was.called_with(123)
        end)

        it("should start tracking through C_ContentTracking", function()
            _UseContentTrackingApi()

            AchievementTracking.Track(123)

            assert.spy(C_ContentTracking.StartTracking).was.called_with(2, 123)
        end)

        it("should not call the legacy API stub on Era", function()
            Expansions.Current = Expansions.Era
            _UseLegacyApi()

            AchievementTracking.Track(123)

            assert.spy(AddTrackedAchievement).was.not_called()
        end)

        it("should do nothing when no API exists", function()
            assert.has_no.errors(function() AchievementTracking.Track(123) end)
        end)
    end)

    describe("Untrack", function()
        it("should call RemoveTrackedAchievement on the legacy API", function()
            _UseLegacyApi()

            AchievementTracking.Untrack(123)

            assert.spy(RemoveTrackedAchievement).was.called_with(123)
        end)

        it("should prefer the legacy API when both APIs exist", function()
            _UseLegacyApi()
            _UseContentTrackingApi()

            AchievementTracking.Untrack(123)

            assert.spy(RemoveTrackedAchievement).was.called(1)
            assert.spy(C_ContentTracking.StopTracking).was.not_called()
        end)

        it("should stop tracking through C_ContentTracking", function()
            _UseContentTrackingApi()

            AchievementTracking.Untrack(123)

            assert.spy(C_ContentTracking.StopTracking).was.called_with(2, 123, 1)
        end)

        it("should not call the legacy API stub on Era", function()
            Expansions.Current = Expansions.Era
            _UseLegacyApi()

            AchievementTracking.Untrack(123)

            assert.spy(RemoveTrackedAchievement).was.not_called()
        end)

        it("should do nothing when no API exists", function()
            assert.has_no.errors(function() AchievementTracking.Untrack(123) end)
        end)
    end)

    describe("HasTrackedAchievements", function()
        it("should return true when achievements are tracked", function()
            _UseLegacyApi()

            assert.is_true(AchievementTracking.HasTrackedAchievements())
        end)

        it("should return false when no achievement is tracked", function()
            _UseContentTrackingApi()
            C_ContentTracking.GetTrackedIDs = function() return {} end

            assert.is_false(AchievementTracking.HasTrackedAchievements())
        end)
    end)

    describe("UsesContentTracking", function()
        it("should return true on Forever", function()
            Expansions.Current = Expansions.Era
            _UseContentTrackingApi()

            assert.is_true(AchievementTracking.UsesContentTracking())
        end)

        it("should return false when the legacy API is used", function()
            _UseLegacyApi()
            _UseContentTrackingApi()

            assert.is_false(AchievementTracking.UsesContentTracking())
        end)
    end)

    describe("IsAchievementContentType", function()
        it("should only accept the achievement type of C_ContentTracking", function()
            _UseContentTrackingApi()

            assert.is_true(AchievementTracking.IsAchievementContentType(2))
            assert.is_false(AchievementTracking.IsAchievementContentType(1))
        end)

        it("should return false without C_ContentTracking", function()
            _UseLegacyApi()

            assert.is_false(AchievementTracking.IsAchievementContentType(2))
        end)
    end)

    describe("OpenAchievement", function()
        it("should open the Legacy System window and select the achievement on Forever", function()
            local frame = {shown = false}
            function frame:IsShown() return self.shown end
            _G.ToggleLegacySystemUI = spy.new(function() frame.shown = true end)
            _G.LegacySystemFrame_LoadUI = spy.new(function() _G.LegacySystemFrame = frame end)
            _G.AchievementFrame_SelectAchievement = spy.new(function() end)

            AchievementTracking.OpenAchievement(42)

            assert.spy(LegacySystemFrame_LoadUI).was.called(1)
            assert.spy(ToggleLegacySystemUI).was.called(1)
            assert.spy(AchievementFrame_SelectAchievement).was.called_with(42)
        end)

        it("should not toggle an open Legacy System window", function()
            _G.LegacySystemFrame = {IsShown = function() return true end}
            _G.ToggleLegacySystemUI = spy.new(function() end)
            _G.AchievementFrame_SelectAchievement = spy.new(function() end)

            AchievementTracking.OpenAchievement(42)

            assert.spy(ToggleLegacySystemUI).was.not_called()
            assert.spy(AchievementFrame_SelectAchievement).was.called_with(42)
        end)

        it("should load and open the achievement window and select the achievement", function()
            local frame = {IsShown = function() return false end}
            _G.AchievementFrame_LoadUI = spy.new(function() _G.AchievementFrame = frame end)
            _G.AchievementFrame_ToggleAchievementFrame = spy.new(function() end)
            _G.AchievementFrame_SelectAchievement = spy.new(function() end)

            AchievementTracking.OpenAchievement(42)

            assert.spy(AchievementFrame_LoadUI).was.called(1)
            assert.spy(AchievementFrame_ToggleAchievementFrame).was.called(1)
            assert.spy(AchievementFrame_SelectAchievement).was.called_with(42)
        end)

        it("should only select the achievement in an open achievement window", function()
            _G.AchievementFrame = {IsShown = function() return true end}
            _G.AchievementFrameAchievements = {selection = 7}
            _G.AchievementFrame_ToggleAchievementFrame = spy.new(function() end)
            _G.AchievementFrame_SelectAchievement = spy.new(function() end)

            AchievementTracking.OpenAchievement(42)

            assert.spy(AchievementFrame_ToggleAchievementFrame).was.not_called()
            assert.spy(AchievementFrame_SelectAchievement).was.called_with(42)
        end)

        it("should keep an already selected achievement", function()
            _G.AchievementFrame = {IsShown = function() return true end}
            _G.AchievementFrameAchievements = {selection = 42}
            _G.AchievementFrame_SelectAchievement = spy.new(function() end)

            AchievementTracking.OpenAchievement(42)

            assert.spy(AchievementFrame_SelectAchievement).was.not_called()
        end)
    end)

    describe("RefreshAchievementWindow", function()
        it("should update a loaded achievement window", function()
            _G.AchievementFrameAchievements_ForceUpdate = spy.new(function() end)

            AchievementTracking.RefreshAchievementWindow()

            assert.spy(AchievementFrameAchievements_ForceUpdate).was.called(1)
        end)

        it("should do nothing when the achievement window is not loaded", function()
            assert.has_no.errors(function() AchievementTracking.RefreshAchievementWindow() end)
        end)
    end)
end)
