dofile("setupTests.lua")
dofile("Localization/l10n.lua")

describe("QuestieEvent", function()
    ---@type QuestieEvent
    local QuestieEvent
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type QuestieNPCFixes
    local QuestieNPCFixes
    ---@type ContentPhases
    local ContentPhases
    ---@type Expansions
    local Expansions

    ---@type luassert.spy
    local printMock

    before_each(function()
        Questie.IsClassic = false
        Questie.IsAnniversary = false
        _G.Questie.Colorize = function(_, str) return str end
        printMock = spy.new(function() end)
        _G.print = printMock
        _G.GetCVarBool = function() return true end
        _G.SetCVar = function() end
        QuestieCorrections = require("Database.Corrections.QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        Expansions = require("Modules.Expansions")
        QuestieNPCFixes = require("Database.Corrections.classicNPCFixes")
        QuestieNPCFixes.LoadDarkmoonFixes = function() return {} end
        ContentPhases = require("Database.Corrections.ContentPhases.ContentPhases")
        QuestieEvent = require("Database.Corrections.Holidays.QuestieEvent")
        QuestieEvent.eventQuests = {} -- This is done on top level in QuestieEvent.lua
        QuestieEvent.activeQuests = {} -- This is done on top level in QuestieEvent.lua
        dofile("Database/Corrections/Holidays/quests/DarkmoonFaire.lua")
    end)

    describe("Darkmoon Faire", function()
        it("should not load for Anniversary servers in P1", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            }
            ContentPhases.activePhases.Anniversary = 1

            Questie.IsClassic = true
            Questie.IsAnniversary = true

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary HC servers in P1", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            }
            ContentPhases.activePhases.Anniversary = 1

            Questie.IsClassic = true
            Questie.IsAnniversary = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary servers in P2", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            }
            ContentPhases.activePhases.Anniversary = 2

            Questie.IsClassic = true
            Questie.IsAnniversary = true

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary servers in P2", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            }
            ContentPhases.activePhases.Anniversary = 2

            Questie.IsClassic = true
            Questie.IsAnniversary = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should load for Anniversary servers in P3", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            }
            ContentPhases.activePhases.Anniversary = 3

            Questie.IsClassic = true
            Questie.IsAnniversary = true

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should load for Anniversary HC servers in P3", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            }
            ContentPhases.activePhases.Anniversary = 3

            Questie.IsClassic = true
            Questie.IsAnniversary = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should load for Classic servers", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            }

            Questie.IsClassic = true

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should load for MoP servers on days with DMF texture for 'start'", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekDay = 4,
                        monthDay = 3,
                        month = 12,
                        year = 2025
                    }
                end
            }
            local getNumDayEventsMock = spy.new(function() return 1 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return {texture = 235447, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
            assert.spy(getNumDayEventsMock).was.called_with(0, 3)
        end)

        it("should load for MoP servers on days with DMF texture for 'ongoing'", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekDay = 4,
                        monthDay = 3,
                        month = 12,
                        year = 2025
                    }
                end
            }
            local getNumDayEventsMock = spy.new(function() return 1 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return {texture = 235448, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
            assert.spy(getNumDayEventsMock).was.called_with(0, 3)
        end)

        it("should load for MoP servers on days with DMF texture for 'end'", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekDay = 4,
                        monthDay = 3,
                        month = 12,
                        year = 2025
                    }
                end
            }
            local getNumDayEventsMock = spy.new(function() return 1 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return {texture = 235446, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
            assert.spy(getNumDayEventsMock).was.called_with(0, 3)
        end)

        it("should not load for MoP servers on days where DMF is inactive", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekDay = 1,
                        monthDay = 23,
                        month = 11,
                        year = 2025
                    }
                end
            }
            local getNumDayEventsMock = spy.new(function() return 1 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return {texture = 235458, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
            assert.spy(getNumDayEventsMock).was.called_with(0, 23)
        end)

        it("should hide DMF events if user had them hidden before", function()
            local getCvarBoolMock = spy.new(function() return false end)
            _G.GetCVarBool = getCvarBoolMock
            local setCvarMock = spy.new(function() end)
            _G.SetCVar = setCvarMock

            QuestieEvent:Load()

            assert.spy(getCvarBoolMock).was.called_with("calendarShowDarkmoon")
            assert.spy(setCvarMock).was.called_with("calendarShowDarkmoon", "0")
        end)
    end)
end)
