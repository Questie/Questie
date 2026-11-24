dofile("setupTests.lua")
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("QuestieEvent", function()
    ---@type QuestieEvent
    local QuestieEvent
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type ContentPhases
    local ContentPhases
    ---@type Expansions
    local Expansions

    ---@type luassert.spy
    local printMock
    ---@type QuestieDBMock
    local mock
    ---@type QuestieDB
    local QuestieDB
    ---@type table<string, integer> The provider's event IDs.
    local events

    -- Event membership as QuestieDB states it for the quests these tests follow.
    local ANY_LOCATION_QUEST = 7902 -- at the faire wherever it is
    local ALLIANCE_ANNOUNCEMENT = 7905 -- not while the faire is in Mulgore
    local HORDE_ANNOUNCEMENT = 7926 -- not while the faire is in Elwynn Forest
    local ISLAND_QUEST = 29433 -- on Darkmoon Island

    before_each(function()
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
        QuestieCorrections.questNPCBlacklist = {}
        QuestieCorrections.SetCorrection = function() end
        -- The Darkmoon NPC producers are exercised in their own QuestiePolicy tests; here they only need to exist.
        QuestieLoader:ImportModule("QuestieClassicPolicyCorrections").LoadDarkmoonFixes = function() return {} end
        QuestieLoader:ImportModule("QuestieTBCPolicyCorrections").LoadDarkmoonFixes = function() return {} end

        Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Current = Expansions.Wotlk

        dofile("Database/Corrections/ContentPhases/ContentPhases.lua")
        ContentPhases = QuestieLoader:ImportModule("ContentPhases")
        dofile("Localization/l10n.lua")

        mock = LoadQuestieDBMock()
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        events = mock.lib.Enum.eventKeys
        QuestieDB.eventKeys = events
        QuestieLoader:ImportModule("QuestieQuestBlacklist").LoadEventQuestGates = function() return {} end

        dofile("Database/Corrections/Holidays/QuestieEvent.lua")
        QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        -- What Login Initialization would have collected from QuestieDB, with every event quest hidden.
        QuestieEvent.eventQuests = {
            [ANY_LOCATION_QUEST] = {events.DARKMOON_FAIRE_ELWYNN, events.DARKMOON_FAIRE_MULGORE, events.DARKMOON_FAIRE_TEROKKAR},
            [ALLIANCE_ANNOUNCEMENT] = {events.DARKMOON_FAIRE_ELWYNN, events.DARKMOON_FAIRE_TEROKKAR},
            [HORDE_ANNOUNCEMENT] = {events.DARKMOON_FAIRE_MULGORE, events.DARKMOON_FAIRE_TEROKKAR},
            [ISLAND_QUEST] = {events.DARKMOON_FAIRE_ISLAND},
        }
        for questId in pairs(QuestieEvent.eventQuests) do
            QuestieCorrections.hiddenQuests[questId] = true
        end
    end)

    describe("Darkmoon Faire", function()
        it("should not load for Anniversary servers in P1", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            ContentPhases.activePhases.Anniversary = 1

            Expansions.Current = Expansions.Era
            Questie.IsAnniversaryEra = true

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary HC servers in P1", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            ContentPhases.activePhases.Anniversary = 1

            Expansions.Current = Expansions.Era
            Questie.IsAnniversaryEra = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary servers in P2", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            ContentPhases.activePhases.Anniversary = 2

            Expansions.Current = Expansions.Era
            Questie.IsAnniversaryEra = true

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary servers in P2", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            ContentPhases.activePhases.Anniversary = 2

            Expansions.Current = Expansions.Era
            Questie.IsAnniversaryEra = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should load for Anniversary servers in P3", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
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

            Expansions.Current = Expansions.Era
            Questie.IsAnniversaryEra = true

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
            assert.are_same({[ANY_LOCATION_QUEST] = true, [HORDE_ANNOUNCEMENT] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[ANY_LOCATION_QUEST])
            assert.is_true(QuestieCorrections.hiddenQuests[ALLIANCE_ANNOUNCEMENT])
        end)

        it("should load for Anniversary HC servers in P3", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
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

            Expansions.Current = Expansions.Era
            Questie.IsAnniversaryEra = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
            assert.are_same({[ANY_LOCATION_QUEST] = true, [HORDE_ANNOUNCEMENT] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[ANY_LOCATION_QUEST])
            assert.is_true(QuestieCorrections.hiddenQuests[ALLIANCE_ANNOUNCEMENT])
        end)

        it("should load for Classic servers", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 11,
                        month = 12,
                        year = 2024,
                        hour = 0,
                        minute = 0,
                    }
                end
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2024, month = 12}
                    else
                        return {firstWeekday = 1}
                    end
                end
            }

            Expansions.Current = Expansions.Era

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
            assert.are_same({[ANY_LOCATION_QUEST] = true, [HORDE_ANNOUNCEMENT] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[ANY_LOCATION_QUEST])
            assert.is_true(QuestieCorrections.hiddenQuests[ALLIANCE_ANNOUNCEMENT])
        end)

        it("should not be active at 02:30 on start Monday for Era (hour gating)", function()
            -- Simulate Era environment and a month where the 1st is a Monday -> startDay = 8
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 2,
                        monthDay = 8,
                        month = 2,
                        year = 2025,
                        hour = 2,
                        minute = 30,
                    }
                end

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
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should be active at 04:00 on start Monday for Era (hour gating)", function()
            -- Simulate Era environment and a month where the 1st is a Monday -> startDay = 8
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 2,
                        monthDay = 8,
                        month = 2,
                        year = 2025,
                        hour = 4,
                        minute = 0,
                    }
                end

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
            assert.are_same({[ANY_LOCATION_QUEST] = true, [HORDE_ANNOUNCEMENT] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[ANY_LOCATION_QUEST])
            assert.is_true(QuestieCorrections.hiddenQuests[ALLIANCE_ANNOUNCEMENT])
        end)

        it("should not be active on the following Monday at 04:00 for Era (end hour gating)", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 2,
                        monthDay = 15,
                        month = 3,
                        year = 2025,
                        hour = 4,
                        minute = 0,
                    }
                end

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
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should be active on the following Monday at 02:59 for Era (end hour gating)", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 2,
                        monthDay = 15,
                        month = 3,
                        year = 2025,
                        hour = 2,
                        minute = 59,
                    }
                end

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
            assert.are_same({[ANY_LOCATION_QUEST] = true, [ALLIANCE_ANNOUNCEMENT] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[ANY_LOCATION_QUEST])
            assert.is_true(QuestieCorrections.hiddenQuests[HORDE_ANNOUNCEMENT])
        end)

        it("should load for MoP servers on days with DMF texture for 'start'", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekDay = 4,
                        monthDay = 3,
                        month = 12,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            local getNumDayEventsMock = spy.new(function() return 1 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return {texture = 235447, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The \"Darkmoon Faire\" world event is active!")
            assert.are_same({[ISLAND_QUEST] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[ISLAND_QUEST])
            assert.is_true(QuestieCorrections.hiddenQuests[ANY_LOCATION_QUEST])
            assert.spy(getNumDayEventsMock).was.called_with(0, 3)
        end)

        it("should load for MoP servers on days with DMF texture for 'ongoing'", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekDay = 4,
                        monthDay = 3,
                        month = 12,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            local getNumDayEventsMock = spy.new(function() return 1 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return {texture = 235448, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The \"Darkmoon Faire\" world event is active!")
            assert.are_same({[ISLAND_QUEST] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[ISLAND_QUEST])
            assert.is_true(QuestieCorrections.hiddenQuests[ANY_LOCATION_QUEST])
            assert.spy(getNumDayEventsMock).was.called_with(0, 3)
        end)

        it("should load for MoP servers on days with DMF texture for 'end'", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekDay = 4,
                        monthDay = 3,
                        month = 12,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            local getNumDayEventsMock = spy.new(function() return 1 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return {texture = 235446, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The \"Darkmoon Faire\" world event is active!")
            assert.are_same({[ISLAND_QUEST] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[ISLAND_QUEST])
            assert.is_true(QuestieCorrections.hiddenQuests[ANY_LOCATION_QUEST])
            assert.spy(getNumDayEventsMock).was.called_with(0, 3)
        end)

        it("should not load for MoP servers on days where DMF is inactive", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekDay = 1,
                        monthDay = 23,
                        month = 11,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            local getNumDayEventsMock = spy.new(function() return 1 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return {texture = 235458, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
            assert.spy(getNumDayEventsMock).was.called_with(0, 23)
        end)

        it("should load for TBC servers when faire is in Mulgore and activate Horde announcement quest", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 12,
                        month = 1,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 1}
                    else
                        return {firstWeekday = 4}
                    end
                end
            }


            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Mulgore!")
            assert.is_true(QuestieEvent.activeQuests[7926] == true)
            assert.is_nil(QuestieEvent.activeQuests[7905])
        end)

        it("should load for TBC servers when faire is in Elwynn Forest", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 10,
                        month = 2,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 2}
                    else
                        return {firstWeekday = 2}
                    end
                end
            }


            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Elwynn Forest!")
            assert.is_true(QuestieEvent.activeQuests[7905] == true)
            assert.is_nil(QuestieEvent.activeQuests[7926])
        end)

        it("should load for TBC servers when faire is in Terokkar Forest and activate both announcement quests", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 4,
                        monthDay = 10,
                        month = 3,
                        year = 2025,
                        hour = 12,
                        minute = 0,
                    }
                end
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = 2025, month = 3}
                    else
                        return {firstWeekday = 2}
                    end
                end
            }


            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Terokkar Forest!")
            assert.is_true(QuestieEvent.activeQuests[7905] == true)
            assert.is_true(QuestieEvent.activeQuests[7926] == true)
        end)

        it("should not load for TBC servers when faire is not active", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        weekday = 3,
                        monthDay = 1,
                        month = 4,
                        year = 2025,
                        hour = 0,
                        minute = 0,
                    }
                end
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
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should not activate DMF for MoP servers when GetNumDayEvents returns 0 events", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {
                        minute = 0,
                        hour = 12,
                        weekDay = 1,
                        monthDay = 23,
                        month = 11,
                        year = 2025
                    }
                end
            local getNumDayEventsMock = spy.new(function() return 0 end)
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = getNumDayEventsMock,
                GetHolidayInfo = function() return nil end
            }

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
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

    describe("Darkmoon NPC Policy Correction", function()
        ---@type QuestieClassicPolicyCorrections
        local QuestieClassicPolicyCorrections
        ---@type QuestieTBCPolicyCorrections
        local QuestieTBCPolicyCorrections
        ---@type {datatype: string, name: string, rows: table|nil}[]
        local setCorrectionCalls

        ---Points the calendar mocks at one moment; `firstWeekday` is the weekday of the 1st of that month.
        ---@param year number
        ---@param month number
        ---@param monthDay number
        ---@param hour number
        ---@param firstWeekday number
        ---@return nil
        local function _MockCalendar(year, month, monthDay, hour, firstWeekday)
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = monthDay, month = month, year = year, hour = hour, minute = 0}
                end
            _G.C_Calendar = {
                GetMonthInfo = function(offset)
                    if offset == nil then
                        return {year = year, month = month}
                    end
                    return {firstWeekday = firstWeekday}
                end
            }
        end

        before_each(function()
            setCorrectionCalls = {}
            QuestieCorrections.SetCorrection = function(datatype, name, rows)
                table.insert(setCorrectionCalls, {datatype = datatype, name = name, rows = rows})
            end
            QuestieClassicPolicyCorrections = QuestieLoader:ImportModule("QuestieClassicPolicyCorrections")
            QuestieClassicPolicyCorrections.LoadDarkmoonFixes = function(_, isInMulgore)
                return {producer = "classic", isInMulgore = isInMulgore}
            end
            QuestieTBCPolicyCorrections = QuestieLoader:ImportModule("QuestieTBCPolicyCorrections")
            QuestieTBCPolicyCorrections.LoadDarkmoonFixes = function(_, isInMulgore, isInTerokkar)
                return {producer = "tbc", isInMulgore = isInMulgore, isInTerokkar = isInTerokkar}
            end
        end)

        it("publishes the Classic Mulgore table exactly once, independent of the Event Quest count", function()
            -- December 2024, an even month: Mulgore. The 1st is a Sunday, so the faire runs from Monday the 9th.
            _MockCalendar(2024, 12, 11, 0, 1)
            Expansions.Current = Expansions.Era

            QuestieEvent:Load()

            assert.are_same(1, #setCorrectionCalls)
            assert.are_same({datatype = "Npc", name = "DarkmoonFaire", rows = {producer = "classic", isInMulgore = true}}, setCorrectionCalls[1])
        end)

        it("publishes the Classic Elwynn Forest table in an odd month", function()
            -- March 2025, an odd month: Elwynn Forest. The 1st is a Monday, so the faire runs from the 8th until 03:00 on the 15th.
            _MockCalendar(2025, 3, 15, 2, 2)
            Expansions.Current = Expansions.Era

            QuestieEvent:Load()

            assert.are_same({datatype = "Npc", name = "DarkmoonFaire", rows = {producer = "classic", isInMulgore = false}}, setCorrectionCalls[#setCorrectionCalls])
        end)

        it("publishes the TBC Mulgore table", function()
            -- January 2025, month % 3 == 1: Mulgore on TBC. The 1st is a Saturday, so the faire runs from the 10th.
            _MockCalendar(2025, 1, 12, 12, 7)
            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.are_same(1, #setCorrectionCalls)
            assert.are_same({datatype = "Npc", name = "DarkmoonFaire", rows = {producer = "tbc", isInMulgore = true, isInTerokkar = false}}, setCorrectionCalls[1])
        end)

        it("publishes the TBC Terokkar Forest table", function()
            -- March 2025, month % 3 == 0: Terokkar Forest. The 1st is a Monday, so the faire runs from the 8th.
            _MockCalendar(2025, 3, 10, 12, 2)
            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.are_same({datatype = "Npc", name = "DarkmoonFaire", rows = {producer = "tbc", isInMulgore = false, isInTerokkar = true}}, setCorrectionCalls[#setCorrectionCalls])
        end)

        it("withdraws the NPC slot with nil when no faire is active", function()
            -- April 1st 2025 is before the faire week: the 1st is a Saturday, so the faire starts on the 10th.
            _MockCalendar(2025, 4, 1, 0, 7)
            Questie.IsTBC = true
            Expansions.Current = Expansions.Tbc

            QuestieEvent:Load()

            assert.are_same(1, #setCorrectionCalls)
            assert.are_same({datatype = "Npc", name = "DarkmoonFaire"}, setCorrectionCalls[1])
            assert.is_nil(setCorrectionCalls[1].rows)
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("leaves the NPC Policy Correction untouched on Anniversary realms before phase 3", function()
            -- December 2024 would be a Mulgore faire week; phases 1 and 2 have no faire at all.
            _MockCalendar(2024, 12, 11, 0, 1)
            ContentPhases.activePhases.Anniversary = 2
            Expansions.Current = Expansions.Era
            Questie.IsAnniversaryEra = true

            QuestieEvent:Load()

            assert.are_same(0, #setCorrectionCalls)
        end)

        it("uses the Era location behavior on Anniversary realms from phase 3", function()
            -- December 2024, an even month: Mulgore. The 1st is a Sunday, so the faire runs from Monday the 9th.
            _MockCalendar(2024, 12, 11, 0, 1)
            ContentPhases.activePhases.Anniversary = 3
            Expansions.Current = Expansions.Era
            Questie.IsAnniversaryEra = true

            QuestieEvent:Load()

            assert.are_same(1, #setCorrectionCalls)
            assert.are_same({datatype = "Npc", name = "DarkmoonFaire", rows = {producer = "classic", isInMulgore = true}}, setCorrectionCalls[1])
        end)

        it("leaves the NPC Policy Correction untouched on MoP, where the faire is not relocated", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekDay = 4, monthDay = 3, month = 12, year = 2025, hour = 12, minute = 0}
                end
            Expansions.Current = Expansions.MoP
            _G.C_Calendar = {
                GetNumDayEvents = function() return 1 end,
                GetHolidayInfo = function() return {texture = 235447, calendarType = "HOLIDAY"} end
            }

            QuestieEvent:Load()

            assert.are_same(0, #setCorrectionCalls)
            assert.is_not_nil(next(QuestieEvent.activeQuests))
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
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 9, month = 2, year = 2025, hour = 9, minute = 59}
                end
            QuestieEvent.eventDates = {
                ["Love is in the Air"] = {startDate = "9/2", startHour = 10, startMinute = 0, endDate = "23/2", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {[9032] = {events.LOVE_IS_IN_THE_AIR}}

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should activate an event at exactly its start hour", function()
            -- Event starts 10:00 on 9 Feb, ends 10:00 on 23 Feb
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 9, month = 2, year = 2025, hour = 10, minute = 0}
                end
            QuestieEvent.eventDates = {
                ["Love is in the Air"] = {startDate = "9/2", startHour = 10, startMinute = 0, endDate = "23/2", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {[9032] = {events.LOVE_IS_IN_THE_AIR}}

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The \"Love is in the Air\" world event is active!")
            assert.are_same({[9032] = true}, QuestieEvent.activeQuests)
        end)

        it("should not activate an event after its end hour on the end day", function()
            -- Event ends at 10:00 on 23 Feb; 10:01 should be inactive
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 23, month = 2, year = 2025, hour = 10, minute = 1}
                end
            QuestieEvent.eventDates = {
                ["Love is in the Air"] = {startDate = "9/2", startHour = 10, startMinute = 0, endDate = "23/2", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {[9032] = {events.LOVE_IS_IN_THE_AIR}}

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should activate a cross-year event in December (Winter Veil)", function()
            -- Winter Veil: Dec 15 10:00 - Jan 2 10:00; date is Dec 20
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 6, monthDay = 20, month = 12, year = 2025, hour = 12, minute = 0}
                end
            QuestieEvent.eventDates = {
                ["Winter Veil"] = {startDate = "15/12", startHour = 10, startMinute = 0, endDate = "2/1", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {[8763] = {events.WINTER_VEIL}}

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The \"Winter Veil\" world event is active!")
            assert.are_same({[8763] = true}, QuestieEvent.activeQuests)
        end)

        it("should activate a cross-year event in January (Winter Veil)", function()
            -- Winter Veil: Dec 15 10:00 - Jan 2 10:00; date is Jan 1
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 3, monthDay = 1, month = 1, year = 2026, hour = 12, minute = 0}
                end
            QuestieEvent.eventDates = {
                ["Winter Veil"] = {startDate = "15/12", startHour = 10, startMinute = 0, endDate = "2/1", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {[8763] = {events.WINTER_VEIL}}

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The \"Winter Veil\" world event is active!")
            assert.are_same({[8763] = true}, QuestieEvent.activeQuests)
        end)

        it("should not activate a cross-year event outside its window (Winter Veil)", function()
            -- Winter Veil: Dec 15 10:00 - Jan 2 10:00; date is Jun 15
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 15, month = 6, year = 2025, hour = 12, minute = 0}
                end
            QuestieEvent.eventDates = {
                ["Winter Veil"] = {startDate = "15/12", startHour = 10, startMinute = 0, endDate = "2/1", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {[8763] = {events.WINTER_VEIL}}

            QuestieEvent:Load()

            assert.spy(printMock).was.not_called()
            assert.are_same({}, QuestieEvent.activeQuests)
        end)

        it("should not activate a quest before its own window while its event is active", function()
            -- Winter Veil runs from 15 Dec; "A Carefully Wrapped Present" (8744) opens on 25 Dec.
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 6, monthDay = 20, month = 12, year = 2025, hour = 12, minute = 0}
                end
            QuestieEvent.eventDates = {
                ["Winter Veil"] = {startDate = "15/12", startHour = 10, startMinute = 0, endDate = "2/1", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {[8744] = {events.WINTER_VEIL}, [8763] = {events.WINTER_VEIL}}

            QuestieEvent:Load()

            assert.spy(printMock).was.called_with("[Questie]", "|cFF6ce314The \"Winter Veil\" world event is active!")
            assert.are_same({[8763] = true}, QuestieEvent.activeQuests)
        end)

        it("should activate a quest inside its own window", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 6, monthDay = 26, month = 12, year = 2025, hour = 12, minute = 0}
                end
            QuestieEvent.eventDates = {
                ["Winter Veil"] = {startDate = "15/12", startHour = 10, startMinute = 0, endDate = "2/1", endHour = 10, endMinute = 0},
            }
            QuestieEvent.eventQuests = {[8744] = {events.WINTER_VEIL}, [8763] = {events.WINTER_VEIL}}

            QuestieEvent:Load()

            assert.are_same({[8744] = true, [8763] = true}, QuestieEvent.activeQuests)
        end)
    end)
    describe("event membership from QuestieDB", function()
        local questKeys, npcKeys
        ---@type table<QuestId, boolean>
        local gates

        ---Runs Initialize to completion; it yields while it reads QuestieDB.
        ---@return nil
        local function _RunInitialize()
            local initialize = coroutine.create(QuestieEvent.Initialize)
            repeat
                local ok, err = coroutine.resume(initialize)
                if not ok then
                    error(err, 0)
                end
            until coroutine.status(initialize) == "dead"
        end

        ---Loads with Hallow's End as the only active event.
        ---@return nil
        local function _LoadDuringHallowsEnd()
            Expansions.Current = Expansions.Cata -- no date overrides and no travelling faire
            QuestieEvent.lunarFestival = {DEFAULT = {}, TITAN = {}}
            QuestieCompat.GetCurrentCalendarTime = function()
                    return {weekday = 1, monthDay = 20, month = 10, year = 2025, hour = 12, minute = 0}
                end
            QuestieEvent.eventDates = {
                ["Hallow's End"] = {startDate = "18/10", endDate = "1/11"},
                ["Winter Veil"] = {startDate = "15/12", endDate = "2/1"},
            }
            QuestieEvent:Load()
        end

        before_each(function()
            questKeys, npcKeys = QuestieDB.questKeys, QuestieDB.npcKeys
            gates = {}
            QuestieLoader:ImportModule("QuestieQuestBlacklist").LoadEventQuestGates = function() return gates end
            Questie.RegisterEvent = function() end
            _G.C_Calendar = {OpenCalendar = function() end, SetMonth = function() end}
            QuestieCorrections.hiddenQuests = {}

            mock.SetBaseRow("Quest", 1658, {[questKeys.name] = "Crashing the Wickerman Festival", [questKeys.eventIds] = {events.HALLOWS_END}})
            mock.SetBaseRow("Quest", 8763, {[questKeys.name] = "The Hero of the Day", [questKeys.eventIds] = {events.WINTER_VEIL}})
            mock.SetBaseRow("Quest", 6963, {[questKeys.name] = "Stolen Winter Veil Treats", [questKeys.eventIds] = {events.WINTER_VEIL}})
            mock.SetBaseRow("Quest", 7907, {[questKeys.name] = "Darkmoon Beast Deck", [questKeys.eventIds] = {events.DARKMOON_FAIRE_ELWYNN}})
            mock.SetBaseRow("Quest", 8792, {[questKeys.name] = "The Horde Needs Your Help!", [questKeys.eventIds] = {events.AHN_QIRAJ_WAR_EFFORT}})
            mock.SetBaseRow("Quest", 9001, {[questKeys.name] = "Closed for the holiday", [questKeys.eventIds] = {-events.HALLOWS_END}})
            mock.SetBaseRow("Quest", 2, {[questKeys.name] = "Sharptalon's Claw"})
            mock.SetBaseRow("Npc", 15353, {[npcKeys.name] = "Katrina Shimmerstar", [npcKeys.eventIds] = {events.HALLOWS_END}})
            mock.SetBaseRow("Npc", 13418, {[npcKeys.name] = "Kaymard Copperpinch", [npcKeys.eventIds] = {events.WINTER_VEIL}})
            mock.SetBaseRow("Npc", 30, {[npcKeys.name] = "Forest Spider"})

            QuestieDB.QuestPointers = mock.lib.Quest.GetAllIds(true)
            QuestieDB.NPCPointers = mock.lib.Npc.GetAllIds(true)
            QuestieDB.QueryQuestSingle = mock.lib.Quest.Get
            QuestieDB.QueryNPCSingle = mock.lib.Npc.Get
        end)

        it("collects the quests and NPCs that list a tracked event and hides those quests until loaded", function()
            _RunInitialize()

            assert.are_same({events.HALLOWS_END}, QuestieEvent.eventQuests[1658])
            assert.are_same({events.WINTER_VEIL}, QuestieEvent.eventQuests[8763])
            assert.is_nil(QuestieEvent.eventQuests[2])
            assert.are_same({[13418] = {events.WINTER_VEIL}, [15353] = {events.HALLOWS_END}}, QuestieEvent.eventNpcs)
            assert.is_true(QuestieCorrections.hiddenQuests[1658])
            assert.is_true(QuestieCorrections.hiddenQuests[8763])
            assert.is_nil(QuestieCorrections.hiddenQuests[2])
        end)

        it("leaves out a quest whose gate withholds it in this flavor, season or phase", function()
            gates[6963] = true

            _RunInitialize()

            assert.is_nil(QuestieEvent.eventQuests[6963])
            assert.is_false(QuestieEvent.IsEventQuest(6963))
            -- Hiding a withheld quest is the blacklist's job; this module must not touch it.
            assert.is_nil(QuestieCorrections.hiddenQuests[6963])
        end)

        it("keeps a quest whose gate is false as an event quest", function()
            gates[6963] = false

            _RunInitialize()

            assert.is_true(QuestieEvent.IsEventQuest(6963))
            assert.is_true(QuestieCorrections.hiddenQuests[6963])
        end)

        it("ignores a quest that only lists an event without a calendar", function()
            _RunInitialize()

            assert.is_false(QuestieEvent.IsEventQuest(8792))
            assert.is_nil(QuestieCorrections.hiddenQuests[8792])
        end)

        it("treats a deck quest as an event quest without hiding it outside the faire", function()
            _RunInitialize()

            assert.is_true(QuestieEvent.IsEventQuest(7907))
            assert.is_nil(QuestieCorrections.hiddenQuests[7907])
        end)

        it("reveals only the quests of the active event", function()
            _RunInitialize()

            _LoadDuringHallowsEnd()

            assert.are_same({[1658] = true}, QuestieEvent.activeQuests)
            assert.is_nil(QuestieCorrections.hiddenQuests[1658])
            assert.is_true(QuestieCorrections.hiddenQuests[8763])
            assert.is_true(QuestieEvent.IsEventActiveForQuest(1658))
            assert.is_false(QuestieEvent.IsEventActiveForQuest(8763))
        end)

        it("hides an ordinary quest that is unavailable during the active event", function()
            _RunInitialize()
            assert.is_nil(QuestieCorrections.hiddenQuests[9001])
            assert.is_false(QuestieEvent.IsEventQuest(9001))

            _LoadDuringHallowsEnd()

            assert.is_true(QuestieCorrections.hiddenQuests[9001])
            assert.is_nil(QuestieEvent.activeQuests[9001])
        end)

        it("leaves a quest that excludes an inactive event alone", function()
            mock.SetBaseRow("Quest", 9002, {[questKeys.name] = "Closed in winter", [questKeys.eventIds] = {-events.WINTER_VEIL}})
            QuestieDB.QuestPointers = mock.lib.Quest.GetAllIds(true)
            _RunInitialize()

            _LoadDuringHallowsEnd()

            assert.is_nil(QuestieCorrections.hiddenQuests[9002])
        end)

        it("shows event NPCs during their event and hides them outside it", function()
            _RunInitialize()

            _LoadDuringHallowsEnd()

            assert.is_false(QuestieCorrections.questNPCBlacklist[15353])
            assert.is_true(QuestieCorrections.questNPCBlacklist[13418])
            assert.is_nil(QuestieCorrections.questNPCBlacklist[30])
        end)

        it("names the event of a quest for Journey grouping", function()
            _RunInitialize()

            assert.are_equal("Hallow's End", QuestieEvent.GetEventNameFor(1658))
            assert.are_equal("Darkmoon Faire", QuestieEvent.GetEventNameFor(7907))
            assert.are_equal("", QuestieEvent.GetEventNameFor(2))
            assert.are_equal("", QuestieEvent.GetEventNameFor(8792))
        end)
    end)
end)
