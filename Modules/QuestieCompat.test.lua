dofile("setupTests.lua")

dofile("Modules/QuestieCompat.lua")

describe("QuestieCompat", function()
    ---@type QuestieCompat
    local QuestieCompat

    before_each(function()
        QuestieCompat = _G.QuestieCompat
        _G.C_GossipInfo = nil
        _G.GetGossipAvailableQuests = nil
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

    describe("GetCurrentCalendarTime", function()
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

        it("should map values from C_DateAndTime.GetTodaysDate", function()
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

            local currentTime = QuestieCompat.GetCurrentCalendarTime()

            assert.are_same({
                monthDay = 2,
                month = 12,
                year = 2025,
                weekday = 3,
                hour = 0,
                minute = 0,
            }, currentTime)
        end)
    end)
end)
