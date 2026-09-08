dofile("setupTests.lua")

describe("QuestieCompat", function()
    ---@type QuestieDB
    local QuestieDB

    ---@type QuestieCompat
    local QuestieCompat

    before_each(function()
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        _G.C_GossipInfo = nil
        _G.GetGossipAvailableQuests = nil
        _G.GetGossipActiveQuests = nil

        dofile("Modules/QuestieCompat.lua")
        QuestieCompat = _G.QuestieCompat
    end)

    describe("GetAvailableQuests", function()
        it("should error when no function is available", function()
            _G.C_GossipInfo = nil
            _G.GetGossipAvailableQuests = nil

            assert.has_error(function()
                QuestieCompat.GetAvailableQuests()
            end)
        end)

        it("should return an empty table when C_GossipInfo.GetAvailableQuests returns an empty table", function()
            _G.C_GossipInfo = {
                GetAvailableQuests = spy.new(function() return {} end)
            }

            local availableQuests = QuestieCompat.GetAvailableQuests()

            assert.are_same({}, availableQuests)
        end)

        it("should return values from C_GossipInfo.GetAvailableQuests", function()
            local expected = {
                {
                    title = "Test Quest",
                    questLevel = 1,
                    questID = 0,
                    isTrivial = false,
                    frequency = 1,
                    repeatable = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                },
                {
                    title = "Test Quest 2",
                    questLevel = 2,
                    questID = 0,
                    isTrivial = true,
                    frequency = 1,
                    repeatable = true,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                },
            }
            _G.C_GossipInfo = {
                GetAvailableQuests = spy.new(function() return expected end)
            }

            local availableQuests = QuestieCompat.GetAvailableQuests()

            assert.are_same(expected, availableQuests)
        end)

        it("should return an empty table when GetGossipAvailableQuests returns nil", function()
            _G.GetGossipAvailableQuests = spy.new(function() return nil end)

            local availableQuests = QuestieCompat.GetAvailableQuests()

            assert.are_same({}, availableQuests)
        end)

        it("should map return values from GetGossipAvailableQuests", function()
            _G.GetGossipAvailableQuests = spy.new(function() return
                "Test Quest", 1, false, 1, false, false, false, "Test Quest 2", 2, true, 1, true, false, false
            end)

            local availableQuests = QuestieCompat.GetAvailableQuests()

            assert.are_same({
                {
                    title = "Test Quest",
                    questLevel = 1,
                    questID = 0,
                    isTrivial = false,
                    frequency = 1,
                    repeatable = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                },
                {
                    title = "Test Quest 2",
                    questLevel = 2,
                    questID = 0,
                    isTrivial = true,
                    frequency = 1,
                    repeatable = true,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                },
            }, availableQuests)
        end)
    end)

    describe("GetActiveQuests", function()
        it("should error when no function is available", function()
            _G.C_GossipInfo = nil
            _G.GetGossipActiveQuests = nil

            assert.has_error(function()
                QuestieCompat.GetActiveQuests()
            end)
        end)

        it("should return an empty table when C_GossipInfo.GetActiveQuests returns an empty table", function()
            _G.C_GossipInfo = {
                GetActiveQuests = spy.new(function() return {} end)
            }

            local activeQuests = QuestieCompat.GetActiveQuests()

            assert.are_same({}, activeQuests)
        end)

        it("should return values from C_GossipInfo.GetActiveQuests", function()
            QuestieDB.IsComplete = spy.new(function() return 0 end)
            local expected = {
                {
                    title = "Test Quest",
                    questLevel = 1,
                    isTrivial = true,
                    frequency = 1,
                    repeatable = false,
                    isComplete = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                    questID = 123,
                },
                {
                    title = "Test Quest",
                    questLevel = 1,
                    isTrivial = false,
                    frequency = 1,
                    repeatable = true,
                    isComplete = true,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                    questID = 456,
                },
            }
            _G.C_GossipInfo = {
                GetActiveQuests = spy.new(function() return expected end)
            }

            local activeQuests = QuestieCompat.GetActiveQuests()

            assert.are_same(expected, activeQuests)
            assert.spy(QuestieDB.IsComplete).was.called_with(123)
            assert.spy(QuestieDB.IsComplete).was.not_called_with(456)
        end)

        it("should override isComplete with QuestieDB.IsComplete for C_GossipInfo.GetActiveQuests", function()
            QuestieDB.IsComplete = spy.new(function() return 1 end)
            local expected = {
                {
                    title = "Test Quest",
                    questLevel = 1,
                    isTrivial = false,
                    frequency = 1,
                    repeatable = false,
                    isComplete = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                    questID = 123,
                },
            }
            _G.C_GossipInfo = {
                GetActiveQuests = spy.new(function() return expected end)
            }

            local activeQuests = QuestieCompat.GetActiveQuests()

            assert.is_true(activeQuests[1].isComplete)
            assert.spy(QuestieDB.IsComplete).was.called_with(123)
        end)

        it("should map return values from GetGossipActiveQuests", function()
            _G.GetGossipActiveQuests = spy.new(function()
                return "Test Quest 1", 1, false, false, false, true, "Test Quest 2", 2, true, false, false, false
            end)

            local activeQuests = QuestieCompat.GetActiveQuests()

            assert.are_same({
                {
                    title = "Test Quest 1",
                    questLevel = 1,
                    isTrivial = false,
                    frequency = nil,
                    repeatable = false,
                    isComplete = false,
                    isLegendary = false,
                    isIgnored = true,
                    isImportant = false,
                    isMeta = false,
                    questID = 0,
                },
                {
                    title = "Test Quest 2",
                    questLevel = 2,
                    isTrivial = true,
                    frequency = nil,
                    repeatable = false,
                    isComplete = false,
                    isLegendary = false,
                    isIgnored = false,
                    isImportant = false,
                    isMeta = false,
                    questID = 0,
                },
            }, activeQuests)
        end)
    end)

    describe("GetCurrentCalendarTime", function()
        local originalDateAndTime, originalGetGameTime

        before_each(function()
            originalDateAndTime = _G.C_DateAndTime
            originalGetGameTime = _G.GetGameTime
            _G.GetGameTime = nil
        end)

        after_each(function()
            _G.C_DateAndTime = originalDateAndTime
            _G.GetGameTime = originalGetGameTime
        end)

        it("should error when no known function is available", function()
            _G.C_DateAndTime = {}

            assert.has_error(function()
                QuestieCompat.GetCurrentCalendarTime()
            end)
        end)

        it("should return values from C_DateAndTime.GetCurrentCalendarTime", function()
            local expected = {
                monthDay = 2,
                month = 12,
                year = 2025,
                weekday = 3,
                hour = 8,
                minute = 47,
            }
            _G.C_DateAndTime = {
                GetCurrentCalendarTime = function() return expected end
            }

            local currentTime = QuestieCompat.GetCurrentCalendarTime()

            assert.are_same(expected, currentTime)
        end)

        it("should preserve an actual native midnight timestamp", function()
            local expected = {
                monthDay = 2,
                month = 12,
                year = 2025,
                weekday = 3,
                hour = 0,
                minute = 0,
            }
            _G.C_DateAndTime = {
                GetCurrentCalendarTime = function() return expected end,
                GetTodaysDate = spy.new(function() end),
            }
            _G.GetGameTime = spy.new(function() return 8, 47 end)

            local currentTime = QuestieCompat.GetCurrentCalendarTime()

            assert.are.equal(expected, currentTime)
            assert.equals(0, currentTime.hour)
            assert.equals(0, currentTime.minute)
            assert.spy(_G.C_DateAndTime.GetTodaysDate).was.not_called()
            assert.spy(_G.GetGameTime).was.not_called()
        end)

        it("should combine the legacy calendar date with the in-game clock", function()
            _G.C_DateAndTime = {
                GetTodaysDate = function()
                    return {
                        weekDay = 3,
                        day = 2,
                        month = 12,
                        year = 2025,
                    }
                end
            }

            _G.GetGameTime = function() return 8, 47 end
            local currentTime = QuestieCompat.GetCurrentCalendarTime()

            assert.are_same({
                monthDay = 2,
                month = 12,
                year = 2025,
                weekday = 3,
                hour = 8,
                minute = 47,
            }, currentTime)

            _G.GetGameTime = function() return 0, 0 end
            currentTime = QuestieCompat.GetCurrentCalendarTime()
            assert.equals(0, currentTime.hour)
            assert.equals(0, currentTime.minute)
        end)

        it("should error rather than return a partial timestamp when the legacy clock is unavailable", function()
            _G.C_DateAndTime = {GetTodaysDate = spy.new(function() return {} end)}

            assert.has_error(function()
                QuestieCompat.GetCurrentCalendarTime()
            end, "Questie tried to call a blizzard API function that does not exist...")
            assert.spy(_G.C_DateAndTime.GetTodaysDate).was.not_called()
        end)
    end)
end)
