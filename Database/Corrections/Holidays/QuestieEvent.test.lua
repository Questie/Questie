dofile("setupTests.lua")

describe("QuestieEvent", function()
    ---@type QuestieEvent
    local QuestieEvent
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type QuestieNPCFixes
    local QuestieNPCFixes
    ---@type QuestieTBCNpcFixes
    local QuestieTBCNpcFixes
    ---@type ContentPhases
    local ContentPhases
    ---@type Expansions
    local Expansions

    ---@type luassert.spy
    local printMock

    before_each(function()
        Questie.IsClassic = false
        Questie.IsAnniversaryEra = false
        Questie.IsAnniversaryHardcore = false
        Questie.IsTBC = false
        Questie.db.profile.showEventQuests = true
        _G.Questie.Colorize = function(_, str) return str end
        printMock = spy.new(function() end)
        _G.print = printMock
        _G.GetCVarBool = function() return true end
        _G.SetCVar = function() end
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}

        Expansions = QuestieLoader:ImportModule("Expansions")

        QuestieNPCFixes = QuestieLoader:ImportModule("QuestieNPCFixes")
        QuestieNPCFixes.LoadDarkmoonFixes = function() return {} end
        QuestieTBCNpcFixes = QuestieLoader:ImportModule("QuestieTBCNpcFixes")
        QuestieTBCNpcFixes.LoadDarkmoonFixes = function() return {} end

        dofile("Database/Corrections/ContentPhases/ContentPhases.lua")
        ContentPhases = QuestieLoader:ImportModule("ContentPhases")
        dofile("Localization/l10n.lua")

        dofile("Database/Corrections/Holidays/QuestieEvent.lua")
        QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
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
            Questie.IsAnniversaryEra = true

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
            Questie.IsAnniversaryEra = false
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
            Questie.IsAnniversaryEra = true

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
            Questie.IsAnniversaryEra = false
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
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2024, month = 12}
                    else
                        return {firstWeekday = 1}
                    end
                end
            }
            ContentPhases.activePhases.Anniversary = 3

            Questie.IsClassic = true
            Questie.IsAnniversaryEra = true

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
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
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2024, month = 12}
                    else
                        return {firstWeekday = 1}
                    end
                end
            }
            ContentPhases.activePhases.Anniversary = 3

            Questie.IsClassic = true
            Questie.IsAnniversaryEra = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
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
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2024, month = 12}
                    else
                        return {firstWeekday = 1}
                    end
                end
            }

            Questie.IsClassic = true

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should not be active at 02:30 on start Monday for Era (hour gating)", function()
            -- Simulate Era environment and a month where the 1st is a Monday -> startDay = 8
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 2,
                        monthDay = 8,
                        month = 2,
                        year = 2025,
                        hour = 2,
                        minute = 30,
                    }
                end
            }

            Questie.IsClassic = true
            Expansions.Current = Expansions.Era

            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 2}
                    else
                        return {firstWeekday = 2}
                    end
                end
            }

            QuestieEvent:Load()
            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should be active at 03:00 on start Monday for Era (hour gating)", function()
            -- Simulate Era environment and a month where the 1st is a Monday -> startDay = 8
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 2,
                        monthDay = 8,
                        month = 2,
                        year = 2025,
                        hour = 3,
                        minute = 0,
                    }
                end
            }

            Questie.IsClassic = true
            Expansions.Current = Expansions.Era

            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 2}
                    else
                        return {firstWeekday = 2}
                    end
                end
            }

            QuestieEvent:Load()
            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should not be active on the following Monday at 03:00 for Era (end hour gating)", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 2,
                        monthDay = 15,
                        month = 3,
                        year = 2025,
                        hour = 3,
                        minute = 0,
                    }
                end
            }

            Questie.IsClassic = true
            Expansions.Current = Expansions.Era

            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 3}
                    else
                        return {firstWeekday = 2}
                    end
                end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should be active on the following Monday at 02:59 for Era (end hour gating)", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 2,
                        monthDay = 15,
                        month = 3,
                        year = 2025,
                        hour = 2,
                        minute = 59,
                    }
                end
            }

            Questie.IsClassic = true
            Expansions.Current = Expansions.Era

            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 3}
                    else
                        return {firstWeekday = 2}
                    end
                end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Elwynn Forest!")
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
                        year = 2025,
                        hour = 12,
                        minute = 0,
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
                        year = 2025,
                        hour = 12,
                        minute = 0,
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
                        year = 2025,
                        hour = 12,
                        minute = 0,
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
                        year = 2025,
                        hour = 12,
                        minute = 0,
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

        it("should load for TBC servers when faire is in Mulgore and activate Horde announcement quest", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 12,
                        month = 1,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            }
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 1}
                    else
                        return {firstWeekday = 7}
                    end
                end
            }

            QuestieTBCNpcFixes.LoadDarkmoonFixes = spy.new(function() return {} end)

            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
            assert.is_true(QuestieEvent.activeQuests[7926] == true)
            assert.is_nil(QuestieEvent.activeQuests[7905])
            assert.spy(QuestieTBCNpcFixes.LoadDarkmoonFixes).was.called_with(QuestieTBCNpcFixes, true, false)
        end)

        it("should load for TBC servers when faire is in Elwynn Forest", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 10,
                        month = 2,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            }
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 2}
                    else
                        return {firstWeekday = 2}
                    end
                end
            }

            QuestieTBCNpcFixes.LoadDarkmoonFixes = spy.new(function() return {} end)

            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Elwynn Forest!")
            assert.is_true(QuestieEvent.activeQuests[7905] == true)
            assert.is_nil(QuestieEvent.activeQuests[7926])
            assert.spy(QuestieTBCNpcFixes.LoadDarkmoonFixes).was.called_with(QuestieTBCNpcFixes, false, false)
        end)

        it("should load for TBC servers when faire is in Terokkar Forest and activate both announcement quests", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 10,
                        month = 3,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            }
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 3}
                    else
                        return {firstWeekday = 2}
                    end
                end
            }

            QuestieTBCNpcFixes.LoadDarkmoonFixes = spy.new(function() return {} end)

            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Terokkar Forest!")
            assert.is_true(QuestieEvent.activeQuests[7905] == true)
            assert.is_true(QuestieEvent.activeQuests[7926] == true)
            assert.spy(QuestieTBCNpcFixes.LoadDarkmoonFixes).was.called_with(QuestieTBCNpcFixes, false, true)
        end)

        it("should not load for TBC servers when faire is not active", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        weekday = 3,
                        monthDay = 1,
                        month = 4,
                        year = 2025,
                        hour = 0,
                        minute = 0,
                    }
                end
            }
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 4}
                    else
                        return {firstWeekday = 7}
                    end
                end
            }

            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should not activate DMF for MoP servers when GetNumDayEvents returns 0 events", function()
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {
                        minute = 0,
                        hour = 12,
                        weekDay = 1,
                        monthDay = 23,
                        month = 11,
                        year = 2025
                    }
                end
            }
            local getNumDayEventsMock = spy.new(function() return 0 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return nil end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_nil(next(QuestieEvent.activeQuests))
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

    describe("General event HH:MM gating", function()
        before_each(function()
            Expansions.Current = Expansions.Tbc

            QuestieEvent.lunarFestival = {DEFAULT = {}, TITAN = {}}
            -- Clear corrections so tests fully control eventDates without expansion overrides
            QuestieEvent.eventDateCorrections = {TBC = {}}
        end)

        it("should not activate an event before its start hour", function()
            -- Event starts 10:00 on 9 Feb, ends 10:00 on 23 Feb
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 9, month = 2, year = 2025, hour = 9, minute = 59}
                end
            }
            QuestieEvent.eventDates = {
                ["Love is in the Air"] = {startDate = "9/2", startHour = 10, startMinute = 0, endDate = "23/2", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {
                {"Love is in the Air", 9032},
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(next(QuestieEvent.activeQuests))
        end)

        it("should activate an event at exactly its start hour", function()
            -- Event starts 10:00 on 9 Feb, ends 10:00 on 23 Feb
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 9, month = 2, year = 2025, hour = 10, minute = 0}
                end
            }
            QuestieEvent.eventDates = {
                ["Love is in the Air"] = {startDate = "9/2", startHour = 10, startMinute = 0, endDate = "23/2", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {
                {"Love is in the Air", 9032},
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Love is in the Air' world event is active!")
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should not activate an event after its end hour on the end day", function()
            -- Event ends at 10:00 on 23 Feb; 10:01 should be inactive
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 23, month = 2, year = 2025, hour = 10, minute = 1}
                end
            }
            QuestieEvent.eventDates = {
                ["Love is in the Air"] = {startDate = "9/2", startHour = 10, startMinute = 0, endDate = "23/2", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {
                {"Love is in the Air", 9032},
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(next(QuestieEvent.activeQuests))
        end)

        it("should activate a cross-year event in December (Winter Veil)", function()
            -- Winter Veil: Dec 15 10:00 - Jan 2 10:00; date is Dec 20
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {weekday = 6, monthDay = 20, month = 12, year = 2025, hour = 12, minute = 0}
                end
            }
            QuestieEvent.eventDates = {
                ["Winter Veil"] = {startDate = "15/12", startHour = 10, startMinute = 0, endDate = "2/1", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {
                {"Winter Veil", 8763},
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Winter Veil' world event is active!")
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should activate a cross-year event in January (Winter Veil)", function()
            -- Winter Veil: Dec 15 10:00 - Jan 2 10:00; date is Jan 1
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {weekday = 3, monthDay = 1, month = 1, year = 2026, hour = 12, minute = 0}
                end
            }
            QuestieEvent.eventDates = {
                ["Winter Veil"] = {startDate = "15/12", startHour = 10, startMinute = 0, endDate = "2/1", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {
                {"Winter Veil", 8763},
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Winter Veil' world event is active!")
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should not activate a cross-year event outside its window (Winter Veil)", function()
            -- Winter Veil: Dec 15 10:00 - Jan 2 10:00; date is Jun 15
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 15, month = 6, year = 2025, hour = 12, minute = 0}
                end
            }
            QuestieEvent.eventDates = {
                ["Winter Veil"] = {startDate = "15/12", startHour = 10, startMinute = 0, endDate = "2/1", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {
                {"Winter Veil", 8763},
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.is_nil(next(QuestieEvent.activeQuests))
        end)

        it("should not activate a quest outside its own HH:MM window during an active event", function()
            -- Event is active for the whole day; quest has its own narrower window
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 5, month = 4, year = 2025, hour = 14, minute = 0}
                end
            }
            QuestieEvent.eventDates = {
                ["Noblegarden"] = {startDate = "5/4", startHour = 0, startMinute = 1, endDate = "11/4", endHour = 23, endMinute = 59},
            }
            -- Quest has its own date/time sub-window: 6 Apr 10:00 - 10 Apr 10:00 (quest is NOT active on Apr 5)
            QuestieEvent.eventQuests = {
                {"Noblegarden", 13479, "6/4", "10/4", "10:00", "10:00"},
            }

            QuestieEvent:Load()

            -- Event itself prints active
            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Noblegarden' world event is active!")
            -- But quest sub-window (Apr 6-10) does not include Apr 5, so quest should not be active
            assert.is_nil(next(QuestieEvent.activeQuests))
        end)

        it("should activate a quest with its own HH:MM window when inside the sub-window", function()
            -- Event is active; quest sub-window also covers the current date/time
            _G.QuestieCompat = {
                GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 8, month = 4, year = 2025, hour = 14, minute = 0}
                end
            }
            QuestieEvent.eventDates = {
                ["Noblegarden"] = {startDate = "5/4", startHour = 0, startMinute = 1, endDate = "11/4", endHour = 23, endMinute = 59},
            }
            QuestieEvent.eventQuests = {
                {"Noblegarden", 13479, "6/4", "10/4", "10:00", "10:00"},
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The 'Noblegarden' world event is active!")
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)
    end)
end)
