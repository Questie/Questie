local TestUtils = dofile("setupTests.lua")

describe("QuestieEvent", function()
    local QuestieEvent, QuestieCorrections, QuestieDB, DarkmoonFaire, DarkmoonFaireFixes, Expansions
    local state, timers, originalGlobals
    local initializationThread

    ---@return nil
    local function resumeInitialization()
        local ok, err = coroutine.resume(initializationThread)
        assert.is_true(ok, err)
    end

    ---@return nil
    local function startInitialization()
        initializationThread = coroutine.create(QuestieEvent.Initialize)
        resumeInitialization()
    end

    before_each(function()
        originalGlobals = {}
        for _, name in ipairs({"QuestieCompat", "C_Calendar", "C_Timer", "C_Seasons", "GetCVarBool", "SetCVar", "print", "Enum"}) do
            originalGlobals[name] = _G[name]
        end
        _G.Enum = {SeasonID = {SeasonOfMastery = 1, SeasonOfDiscovery = 2, Fresh = 11, FreshHardcore = 12, TitanReforged = 109}}
        TestUtils.resetEvents()
        Questie.IsTitanReforged = false
        Questie.IsSoD = false
        Questie.db.profile.showEventQuests = true
        Questie.Colorize = function(_, text) return text end
        Questie.Warning = spy.new(function() end)
        _G.print = spy.new(function() end)
        _G.QuestieCompat = {GetCurrentCalendarTime = function()
            return {year = 2026, month = 8, monthDay = 2, hour = 12, minute = 0}
        end}
        _G.C_Seasons = nil
        _G.GetCVarBool = function() return true end
        _G.SetCVar = function() end
        _G.C_Calendar = {OpenCalendar = spy.new(function() end), SetMonth = spy.new(function() end)}
        timers = {}
        ---@param seconds number
        ---@param callback function
        ---@return table
        local function newTimer(seconds, callback)
            local timer = {seconds = seconds, callback = callback, cancelled = false}
            timer.Cancel = function() timer.cancelled = true end
            table.insert(timers, timer)
            return timer
        end
        _G.C_Timer = {NewTimer = newTimer, NewTicker = newTimer}

        Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Current = Expansions.Wotlk
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {[7881] = true, [7905] = true, [7926] = true, [29433] = true}
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.npcDataOverrides = {}
        DarkmoonFaire = QuestieLoader:ImportModule("DarkmoonFaire")
        state = {status = "inactive"}
        DarkmoonFaire.GetCurrentState = spy.new(function() return state end)
        DarkmoonFaireFixes = QuestieLoader:ImportModule("DarkmoonFaireFixes")
        DarkmoonFaireFixes.GetNpcFixes = spy.new(function(location)
            if location == "DARKMOON_ISLAND" then return nil end
            return {[14828] = {"location correction"}}
        end)
        dofile("Localization/l10n.lua")
        dofile("Database/Corrections/Holidays/QuestieEvent.lua")
        QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        QuestieEvent.eventDates = {}
        QuestieEvent.lunarFestival = {DEFAULT = {}, TITAN = {}}
        QuestieEvent.eventDateCorrections = {CLASSIC = {}, TBC = {}}
        QuestieEvent.eventQuests = {
            {"Darkmoon Faire", 7881},
            {"Darkmoon Faire", 7905},
            {"Darkmoon Faire", 7926},
            {"Darkmoon Faire", 29433, nil, nil, nil, nil, true},
        }
    end)

    after_each(function()
        TestUtils.resetEvents()
        for _, name in ipairs({"QuestieCompat", "C_Calendar", "C_Timer", "C_Seasons", "GetCVarBool", "SetCVar", "print", "Enum"}) do
            _G[name] = originalGlobals[name]
        end
    end)

    describe("Darkmoon Faire activation", function()
        it("applies each rotating location once and selects the correct announcement quests", function()
            local cases = {
                {"MULGORE", "Mulgore", false, true},
                {"ELWYNN_FOREST", "Elwynn Forest", true, false},
                {"TEROKKAR_FOREST", "Terokkar Forest", true, true},
            }
            for _, case in ipairs(cases) do
                -- Each case represents a fresh startup snapshot, not a live location transition.
                QuestieEvent.initialized = false
                QuestieDB.npcDataOverrides[14828] = {"previous location correction"}
                QuestieEvent.eventQuests = {{"Darkmoon Faire", 7881}, {"Darkmoon Faire", 29433, nil, nil, nil, nil, true}}
                QuestieEvent:Load({status = "active", location = case[1]})
                assert.is_true(QuestieEvent.activeQuests[7881])
                assert.is_nil(QuestieCorrections.hiddenQuests[7881])
                assert.is_nil(QuestieEvent.activeQuests[29433])
                assert.is_true(QuestieCorrections.hiddenQuests[29433])
                assert.equals(case[3], QuestieEvent.activeQuests[7905] == true)
                assert.equals(case[4], QuestieEvent.activeQuests[7926] == true)
                assert.equals(not case[3], QuestieCorrections.hiddenQuests[7905] == true)
                assert.equals(not case[4], QuestieCorrections.hiddenQuests[7926] == true)
                assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called_with(case[1])
                assert.same({"location correction"}, QuestieDB.npcDataOverrides[14828])
                assert.spy(print).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in " .. case[2] .. "!")
            end
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called(3)
        end)

        it("applies location corrections even when no event quests are visible", function()
            QuestieEvent.eventQuests = {}
            Questie.db.profile.showEventQuests = false
            QuestieEvent:Load({status = "active", location = "MULGORE"})
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called(1)
            assert.same({"location correction"}, QuestieDB.npcDataOverrides[14828])
            assert.spy(print).was.not_called()
        end)

        for _, expansion in ipairs({"Cata", "MoP"}) do
            it("keeps island spawns and both faction announcement quests in " .. expansion, function()
                Expansions.Current = Expansions[expansion]
                QuestieEvent.eventQuests = {}
                dofile("Database/Corrections/Holidays/quests/DarkmoonFaire.lua")
                QuestieDB.npcDataOverrides[14828] = {"existing island correction"}
                QuestieEvent:Load({status = "active", location = "DARKMOON_ISLAND"})
                assert.is_true(QuestieEvent.activeQuests[29506])
                assert.is_true(QuestieEvent.activeQuests[7905])
                assert.is_true(QuestieEvent.activeQuests[7926])
                assert.is_nil(QuestieCorrections.hiddenQuests[7905])
                assert.is_nil(QuestieCorrections.hiddenQuests[7926])
                assert.is_nil(QuestieEvent.activeQuests[7881])
                assert.same({"existing island correction"}, QuestieDB.npcDataOverrides[14828])
                assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called(1)
                assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called_with("DARKMOON_ISLAND")
                assert.spy(print).was.called(1)
                assert.spy(print).was.called_with("[Questie]", "|cFF6ce314The Darkmoon Faire is up in Darkmoon Island!")
            end)
        end

        it("retains pending event data without activating or announcing anything", function()
            state = {status = "pending"}
            assert.is_false(QuestieEvent:Load())
            assert.is_false(QuestieEvent.initialized)
            assert.is_table(QuestieEvent.eventQuests)
            assert.same({}, QuestieEvent.activeQuests)
            assert.spy(print).was.not_called()
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.not_called()
        end)

        it("keeps inactive DMF hidden while preserving event names and turn-in exceptions", function()
            assert.is_true(QuestieEvent:Load())
            assert.is_true(QuestieEvent.initialized)
            assert.is_nil(QuestieEvent.eventQuests)
            assert.same({}, QuestieEvent.activeQuests)
            assert.is_true(QuestieCorrections.hiddenQuests[7881])
            assert.equals("Darkmoon Faire", QuestieEvent.GetEventNameFor(7881))
            assert.is_true(QuestieEvent.IsEventQuest(7881))
            assert.is_false(QuestieEvent.IsEventActiveForQuest(7881))
            assert.is_true(QuestieEvent.CanQuestBeTurnedInOutsideOfEvent(7937))
            assert.spy(print).was.not_called()
        end)

        it("loads only once even if called again with an active result", function()
            QuestieEvent:Load()
            assert.is_true(QuestieEvent:Load({status = "active", location = "MULGORE"}))
            assert.same({}, QuestieEvent.activeQuests)
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.not_called()
        end)
    end)

    describe("calendar startup lifecycle", function()
        before_each(function() state = {status = "pending"} end)

        it("waits for notification before resolving, then cancels every callback", function()
            DarkmoonFaire.GetCurrentState = spy.new(function(ready)
                return ready and {status = "active", location = "ELWYNN_FOREST"} or {status = "pending"}
            end)
            startInitialization()
            QuestieEvent.Initialize()
            assert.is_false(QuestieEvent.initialized)
            assert.equals(2, #timers)
            assert.spy(C_Calendar.OpenCalendar).was.called(1)
            timers[2].callback()
            resumeInitialization()
            assert.is_false(QuestieEvent.initialized)
            TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
            assert.is_false(QuestieEvent.initialized)
            resumeInitialization()
            assert.is_true(QuestieEvent.initialized)
            assert.is_true(QuestieEvent.activeQuests[7905])
            assert.is_false(TestUtils.isEventRegistered("CALENDAR_UPDATE_EVENT_LIST"))
            assert.is_true(timers[1].cancelled)
            assert.is_true(timers[2].cancelled)
            timers[1].callback()
            timers[2].callback()
            TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called(1)
            assert.spy(Questie.Warning).was.not_called()
        end)

        it("retries incomplete timestamps after notification without discarding event data", function()
            startInitialization()
            TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
            resumeInitialization()
            assert.is_table(QuestieEvent.eventQuests)
            state = {status = "active", location = "MULGORE"}
            timers[2].callback()
            resumeInitialization()
            assert.is_true(QuestieEvent.initialized)
            assert.is_true(QuestieEvent.activeQuests[7926])
            assert.spy(DarkmoonFaire.GetCurrentState).was.called_with(true)
        end)

        it("bounds missing calendar data without guessing or suppressing other holidays", function()
            QuestieEvent.eventDates = {Other = {startDate = "1/8", endDate = "5/8"}}
            table.insert(QuestieEvent.eventQuests, {"Other", 123})
            startInitialization()
            assert.equals(5, timers[1].seconds)
            timers[1].callback()
            resumeInitialization()
            assert.is_true(QuestieEvent.initialized)
            assert.is_true(QuestieEvent.activeQuests[123])
            assert.is_nil(QuestieEvent.activeQuests[7881])
            assert.is_true(QuestieCorrections.hiddenQuests[7881])
            assert.is_true(timers[2].cancelled)
            assert.is_false(TestUtils.isEventRegistered("CALENDAR_UPDATE_EVENT_LIST"))
            assert.spy(Questie.Warning).was.called(1)
        end)

        it("finishes immediately when calendar requests are unavailable or fail", function()
            C_Calendar.OpenCalendar = function() error("native calendar failure") end
            startInitialization()
            assert.is_true(QuestieEvent.initialized)
            assert.is_true(timers[1].cancelled)
            assert.is_true(timers[2].cancelled)
            assert.is_false(TestUtils.isEventRegistered("CALENDAR_UPDATE_EVENT_LIST"))
            assert.spy(Questie.Warning).was.called(1)
        end)

        it("ignores reentrant list notifications caused by filter changes", function()
            DarkmoonFaire.GetCurrentState = spy.new(function(ready)
                if not ready then return {status = "pending"} end
                TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
                return {status = "active", location = "TEROKKAR_FOREST"}
            end)
            startInitialization()
            TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
            resumeInitialization()
            assert.is_true(QuestieEvent.initialized)
            assert.spy(DarkmoonFaire.GetCurrentState).was.called(2)
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called(1)
        end)

        it("propagates application failures through the owning coroutine after cleaning up callbacks", function()
            startInitialization()
            state = {status = "active", location = "MULGORE"}
            DarkmoonFaireFixes.GetNpcFixes = function() error("correction failure") end
            TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
            local ok, err = coroutine.resume(initializationThread)
            assert.is_false(ok)
            assert.matches("correction failure", err)
            assert.equals("dead", coroutine.status(initializationThread))
            assert.is_false(QuestieEvent.initialized)
            assert.is_true(timers[1].cancelled)
            assert.is_true(timers[2].cancelled)
            assert.is_false(TestUtils.isEventRegistered("CALENDAR_UPDATE_EVENT_LIST"))
        end)

        it("does not request calendar data for an already-resolved calculated schedule", function()
            state = {status = "active", location = "MULGORE"}
            C_Calendar = nil
            QuestieEvent.Initialize()
            assert.is_true(QuestieEvent.initialized)
            assert.equals(0, #timers)
            assert.is_false(TestUtils.isEventRegistered("CALENDAR_UPDATE_EVENT_LIST"))
        end)
    end)

    describe("resolver integration", function()
        it("uses Era civil dates without depending on a calendar API", function()
            Expansions.Current = Expansions.Era
            QuestieCompat.GetCurrentCalendarTime = function()
                return {year = 2026, month = 8, monthDay = 10, hour = 3, minute = 0}
            end
            C_Calendar = nil
            dofile("Database/Corrections/Holidays/DarkmoonFaire.lua")
            QuestieEvent.Initialize()
            assert.is_true(QuestieEvent.initialized)
            assert.is_true(QuestieEvent.activeQuests[7926])
            assert.same({"location correction"}, QuestieDB.npcDataOverrides[14828])
        end)

        it("uses the tester-captured Titan September dates and Mulgore artwork", function()
            QuestieCompat.GetCurrentCalendarTime = function()
                return {year = 2026, month = 9, monthDay = 8, hour = 0, minute = 4}
            end
            C_Seasons = {HasActiveSeason = function() return true end, GetActiveSeason = function() return 109 end}
            C_Calendar.GetMonthInfo = function() return {year = 2026, month = 9} end
            C_Calendar.SetAbsMonth = spy.new(function() end)
            C_Calendar.GetNumDayEvents = function() return 1 end
            C_Calendar.GetDayEvent = function()
                return {calendarType = "HOLIDAY", eventID = 375, sequenceType = "ONGOING", iconTexture = 235450}
            end
            C_Calendar.GetHolidayInfo = function()
                return {texture = 235450,
                    startTime = {year = 2026, month = 9, monthDay = 6, hour = 0, minute = 1},
                    endTime = {year = 2026, month = 9, monthDay = 12, hour = 23, minute = 59}}
            end
            dofile("Database/Corrections/Holidays/DarkmoonFaire.lua")
            startInitialization()
            TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
            resumeInitialization()
            assert.is_true(QuestieEvent.initialized)
            assert.is_true(QuestieEvent.activeQuests[7926])
            assert.is_nil(QuestieEvent.activeQuests[7905])
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called_with("MULGORE")
        end)

        it("handles synchronous OpenCalendar and nested month-selection notifications before applying corrections", function()
            Expansions.Current = Expansions.MoP
            QuestieCompat.GetCurrentCalendarTime = function()
                return {year = 2026, month = 9, monthDay = 7, hour = 17, minute = 44}
            end
            local selectedMonth = 10
            local visible, cached = false, false
            _G.GetCVarBool = function() return visible end
            _G.SetCVar = function(_, value) visible = value == "1" end
            C_Calendar.GetMonthInfo = function() return {year = 2026, month = selectedMonth} end
            C_Calendar.SetAbsMonth = spy.new(function(month, year)
                assert.equals(2026, year)
                selectedMonth = month
                TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
                assert.is_false(QuestieEvent.initialized)
            end)
            C_Calendar.GetNumDayEvents = spy.new(function(offset, day)
                if not cached then return nil end
                if selectedMonth ~= 9 or offset ~= 0 or day ~= 7 or not visible then return 0 end
                return 1
            end)
            C_Calendar.GetDayEvent = function()
                return {calendarType = "HOLIDAY", eventID = 479, sequenceType = "ONGOING", iconTexture = 235447}
            end
            C_Calendar.GetHolidayInfo = function()
                return {texture = 235447,
                    startTime = {year = 2026, month = 9, monthDay = 6, hour = 0, minute = 1},
                    endTime = {year = 2026, month = 9, monthDay = 12, hour = 23, minute = 59}}
            end
            C_Calendar.OpenCalendar = function()
                -- Cache population, filter visibility and list notification are independent state changes.
                cached = true
                assert.equals(0, C_Calendar.GetNumDayEvents(0, 7))
                TestUtils.triggerMockEvent("CALENDAR_UPDATE_EVENT_LIST")
                assert.is_false(QuestieEvent.initialized)
            end
            dofile("Database/Corrections/Holidays/DarkmoonFaire.lua")

            startInitialization()

            assert.is_true(QuestieEvent.initialized)
            assert.is_true(QuestieEvent.activeQuests[7905])
            assert.is_true(QuestieEvent.activeQuests[7926])
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called(1)
            assert.spy(DarkmoonFaireFixes.GetNpcFixes).was.called_with("DARKMOON_ISLAND")
            assert.equals(10, selectedMonth)
            assert.is_false(visible)
            assert.spy(C_Calendar.SetAbsMonth).was.called(2)
            assert.spy(C_Calendar.SetMonth).was.not_called()
            assert.is_false(TestUtils.isEventRegistered("CALENDAR_UPDATE_EVENT_LIST"))
            assert.is_true(timers[1].cancelled)
            assert.is_true(timers[2].cancelled)
        end)
    end)

    describe("general event HH:MM gating", function()
        local cases = {
            {"before opening", 2025, 2, 9, 9, 59, "9/2", "23/2", false},
            {"at opening", 2025, 2, 9, 10, 0, "9/2", "23/2", true},
            {"after closing", 2025, 2, 23, 10, 1, "9/2", "23/2", false},
            {"cross-year December", 2025, 12, 20, 12, 0, "15/12", "2/1", true},
            {"cross-year January", 2026, 1, 1, 12, 0, "15/12", "2/1", true},
            {"outside cross-year window", 2025, 6, 15, 12, 0, "15/12", "2/1", false},
        }
        for _, case in ipairs(cases) do
            it(case[1], function()
                QuestieCompat.GetCurrentCalendarTime = function()
                    return {year = case[2], month = case[3], monthDay = case[4], hour = case[5], minute = case[6]}
                end
                QuestieEvent.eventDates = {Other = {
                    startDate = case[7], endDate = case[8], startHour = 10, startMinute = 0, endHour = 10, endMinute = 0,
                }}
                QuestieEvent.eventQuests = {{"Other", 123}}
                QuestieEvent:Load()
                assert.equals(case[9], QuestieEvent.activeQuests[123] == true)
                if case[9] then
                    assert.spy(print).was.called(1)
                else
                    assert.spy(print).was.not_called()
                end
            end)
        end

        it("honors quest-specific windows within an active event", function()
            QuestieEvent.eventDates = {Other = {startDate = "1/8", endDate = "5/8"}}
            QuestieEvent.eventQuests = {
                {"Other", 123, "2/8", "3/8", "13:00", "10:00"},
                {"Other", 456, "2/8", "3/8", "10:00", "10:00"},
            }
            QuestieEvent:Load()
            assert.is_nil(QuestieEvent.activeQuests[123])
            assert.is_true(QuestieEvent.activeQuests[456])
        end)
    end)
end)
