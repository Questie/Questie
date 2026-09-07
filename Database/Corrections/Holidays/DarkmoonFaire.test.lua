dofile("setupTests.lua")

describe("DarkmoonFaire", function()
    local DarkmoonFaire, Expansions, now, seasonId, events, filter, writes
    local originalGlobals

    before_each(function()
        originalGlobals = {
            C_Calendar = _G.C_Calendar, C_Seasons = _G.C_Seasons, QuestieCompat = _G.QuestieCompat,
            GetCVarBool = _G.GetCVarBool, SetCVar = _G.SetCVar, Enum = _G.Enum,
        }
        Expansions = QuestieLoader:ImportModule("Expansions")
        Expansions.Current = Expansions.Era
        now = {year = 2026, month = 8, monthDay = 10, hour = 3, minute = 0}
        seasonId = nil
        events = {}
        filter = false
        writes = {}
        _G.Enum = {SeasonID = {
            SeasonOfMastery = 1, SeasonOfDiscovery = 2, Hardcore = 3, Fresh = 11, FreshHardcore = 12, TitanReforged = 109,
        }}
        _G.C_Seasons = {
            HasActiveSeason = function() return seasonId ~= nil end,
            GetActiveSeason = function() return seasonId end,
        }
        _G.QuestieCompat = {GetCurrentCalendarTime = function() return now end}
        _G.GetCVarBool = function() return filter end
        _G.SetCVar = function(name, value)
            assert.equals("calendarShowDarkmoon", name)
            table.insert(writes, value)
            filter = value == "1"
        end
        _G.C_Calendar = {
            GetMonthInfo = function() return {year = now.year, month = now.month} end,
            SetAbsMonth = spy.new(function() end),
            GetNumDayEvents = function() return #events end,
            GetDayEvent = function(_, _, index) return {calendarType = events[index].calendarType or "HOLIDAY"} end,
            GetHolidayInfo = function(_, _, index)
                assert.is_true(filter)
                return events[index]
            end,
        }
        QuestieLoader:ImportModule("ContentPhases").activePhases = {Anniversary = 3}
        dofile("Database/Corrections/Holidays/DarkmoonFaire.lua")
        DarkmoonFaire = QuestieLoader:ImportModule("DarkmoonFaire")
    end)

    after_each(function()
        for _, name in ipairs({"C_Calendar", "C_Seasons", "QuestieCompat", "GetCVarBool", "SetCVar", "Enum"}) do
            _G[name] = originalGlobals[name]
        end
    end)

    ---@param texture number?
    ---@param startTime CalendarTime?
    ---@param endTime CalendarTime?
    ---@return table
    local function holiday(texture, startTime, endTime)
        return {texture = texture or 235447, name = "Localized name", startTime = startTime or
            {year = 2026, month = 8, monthDay = 2, hour = 0, minute = 1}, endTime = endTime or
            {year = 2026, month = 8, monthDay = 8, hour = 23, minute = 59}}
    end

    ---Fixtures are keyed relative to their original base; changing the selected month does not move the data.
    ---@param year number
    ---@param month number
    ---@param days table<number, table<number, table[]>>
    ---@return nil
    local function mockCalendarDays(year, month, days)
        local selectedYear, selectedMonth = year, month
        ---@param offset number
        ---@param day number
        ---@return table[]
        local function dayEvents(offset, day)
            local dataOffset = (selectedYear - year) * 12 + selectedMonth - month + offset
            return days[dataOffset] and days[dataOffset][day] or {}
        end
        C_Calendar.GetMonthInfo = function() return {year = selectedYear, month = selectedMonth} end
        C_Calendar.SetAbsMonth = spy.new(function(newMonth, newYear)
            selectedMonth, selectedYear = newMonth, newYear
        end)
        C_Calendar.GetNumDayEvents = spy.new(function(offset, day) return #dayEvents(offset, day) end)
        C_Calendar.GetDayEvent = function(offset, day, index)
            local event = dayEvents(offset, day)[index]
            return event and {calendarType = event.calendarType or "HOLIDAY"}
        end
        C_Calendar.GetHolidayInfo = function(offset, day, index)
            assert.is_true(filter)
            return dayEvents(offset, day)[index]
        end
    end

    describe("calculated schedules", function()
        it("opens after the first Friday and excludes closing Monday at 03:00", function()
            now.monthDay = 3 -- August 2026 starts Saturday, so the first Monday is too early.
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
            now.monthDay, now.hour, now.minute = 10, 2, 59
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
            now.hour, now.minute = 3, 0
            assert.same({status = "active", location = "MULGORE"}, DarkmoonFaire.GetCurrentState())
            now.monthDay, now.hour, now.minute = 17, 2, 59
            assert.equals("active", DarkmoonFaire.GetCurrentState().status)
            now.hour, now.minute = 3, 0
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
        end)

        it("handles all seven month-start weekdays without a calendar API", function()
            _G.C_Calendar = nil
            local examples = {{2026, 2, 9}, {2026, 6, 8}, {2026, 9, 7}, {2026, 4, 6},
                {2026, 1, 5}, {2026, 5, 4}, {2026, 8, 10}}
            for _, example in ipairs(examples) do
                now.year, now.month, now.monthDay = unpack(example)
                assert.equals("active", DarkmoonFaire.GetCurrentState().status)
                now.monthDay = now.monthDay - 1
                assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
            end
        end)

        it("defines Era seasons explicitly and preserves unknown/nonseasonal defaults", function()
            for _, id in ipairs({1, 3, 11, 12, 999}) do
                seasonId = id
                assert.equals("MULGORE", DarkmoonFaire.GetCurrentState().location)
            end
            for _, id in ipairs({1, 2, 3, 11, 12}) do
                assert.is_table(DarkmoonFaire.rules[Expansions.Era].seasons[id].timing)
                assert.is_table(DarkmoonFaire.rules[Expansions.Era].seasons[id].location)
            end
            _G.C_Seasons = nil
            assert.equals("MULGORE", DarkmoonFaire.GetCurrentState().location)
        end)

        it("keeps Anniversary Era and Hardcore gated until phase 3 without gating SoM", function()
            QuestieLoader:ImportModule("ContentPhases").activePhases.Anniversary = 2
            for _, id in ipairs({11, 12}) do
                seasonId = id
                assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
            end
            seasonId = 1
            assert.equals("active", DarkmoonFaire.GetCurrentState().status)

            QuestieLoader:ImportModule("ContentPhases").activePhases.Anniversary = 3
            for _, id in ipairs({11, 12}) do
                seasonId = id
                assert.equals("active", DarkmoonFaire.GetCurrentState().status)
            end
        end)

        it("inherits default availability independently of season timing and location", function()
            seasonId = Enum.SeasonID.SeasonOfMastery
            DarkmoonFaire.rules[Expansions.Era].default.availability = {phaseKey = "SoM", minimumPhase = 4}
            local phases = QuestieLoader:ImportModule("ContentPhases").activePhases
            phases.Anniversary, phases.SoM = 6, 3
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)

            phases.SoM = 4
            assert.same({status = "active", location = "MULGORE"}, DarkmoonFaire.GetCurrentState())
        end)

        it("lets a season replace the default availability counter and threshold", function()
            seasonId = Enum.SeasonID.SeasonOfMastery
            DarkmoonFaire.rules[Expansions.Era].default.availability = {phaseKey = "Anniversary", minimumPhase = 6}
            DarkmoonFaire.rules[Expansions.Era].seasons[seasonId].availability = {phaseKey = "SoM", minimumPhase = 4}
            local phases = QuestieLoader:ImportModule("ContentPhases").activePhases
            phases.Anniversary, phases.SoM = 2, 4

            assert.same({status = "active", location = "MULGORE"}, DarkmoonFaire.GetCurrentState())
        end)

        it("treats a missing phase counter as phase zero", function()
            DarkmoonFaire.rules[Expansions.Era].default.availability = {phaseKey = "SoM", minimumPhase = 1}
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)

            QuestieLoader:ImportModule("ContentPhases").activePhases = nil
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
        end)

        it("keeps explicit TBC Anniversary and default rotations in January order", function()
            Expansions.Current = Expansions.Tbc
            for _, id in ipairs({11, 999}) do
                seasonId = id
                for month, location in ipairs({"MULGORE", "ELWYNN_FOREST", "TEROKKAR_FOREST"}) do
                    now.month, now.monthDay = month, 10
                    assert.equals(location, DarkmoonFaire.GetCurrentState().location)
                end
            end
        end)

        it("replaces season timing independently and inherits an omitted location", function()
            seasonId = 11
            DarkmoonFaire.rules[Expansions.Tbc].seasons[11] = {
                timing = {source = "monthly", setupWeekday = 6, startWeekday = 1,
                    startHour = 6, startMinute = 15, endDayOffset = 6, endHour = 9, endMinute = 30},
            }
            Expansions.Current = Expansions.Tbc
            now.monthDay, now.hour, now.minute = 9, 6, 14
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
            now.minute = 15
            assert.equals("ELWYNN_FOREST", DarkmoonFaire.GetCurrentState().location)
            now.monthDay, now.hour, now.minute = 15, 9, 29
            assert.equals("active", DarkmoonFaire.GetCurrentState().status)
            now.minute = 30
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
        end)

        it("keeps configured opening times when only the location comes from the calendar", function()
            DarkmoonFaire.rules[Expansions.Era].default.location = {source = "calendar"}
            events = {holiday(235450,
                {year = 2026, month = 8, monthDay = 10, hour = 6, minute = 0},
                {year = 2026, month = 8, monthDay = 15, hour = 23, minute = 59})}
            mockCalendarDays(2026, 8, {[0] = {
                [10] = events, [11] = events, [12] = events, [13] = events, [14] = events, [15] = events,
            }})
            now.hour, now.minute = 2, 59
            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
            now.hour, now.minute = 3, 0
            assert.equals("MULGORE", DarkmoonFaire.GetCurrentState(true).location)
            events[1].startTime, events[1].endTime = nil, nil
            assert.equals("MULGORE", DarkmoonFaire.GetCurrentState(true).location)
            now.monthDay, now.hour, now.minute = 17, 2, 59
            assert.equals("MULGORE", DarkmoonFaire.GetCurrentState(true).location)
            assert.spy(C_Calendar.GetNumDayEvents).was.called_with(0, 10)
            now.hour, now.minute = 3, 0
            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
        end)

        it("searches calculated occurrence dates across leap-month and year boundaries", function()
            local examples = {
                {anchor = {year = 2024, month = 2, monthDay = 26}, baseYear = 2024, baseMonth = 2,
                    current = {year = 2024, month = 3, monthDay = 3, hour = 2, minute = 59}, lastMonthDay = 29},
                {anchor = {year = 2026, month = 12, monthDay = 28}, baseYear = 2026, baseMonth = 12,
                    current = {year = 2027, month = 1, monthDay = 3, hour = 2, minute = 59}, lastMonthDay = 31},
            }
            for _, example in ipairs(examples) do
                DarkmoonFaire.rules[Expansions.Era].default = {
                    timing = {source = "fortnightly", anchor = example.anchor,
                        startHour = 3, startMinute = 0, endDayOffset = 6, endHour = 3, endMinute = 0},
                    location = {source = "calendar"},
                }
                now = example.current
                mockCalendarDays(example.baseYear, example.baseMonth, {[1] = {[1] = {{texture = 235454}}}})
                assert.equals("TEROKKAR_FOREST", DarkmoonFaire.GetCurrentState(true).location)
                assert.spy(C_Calendar.GetNumDayEvents).was.called_with(0, example.anchor.monthDay)
                assert.spy(C_Calendar.GetNumDayEvents).was.called_with(0, example.lastMonthDay)
                assert.spy(C_Calendar.GetNumDayEvents).was.called_with(0, 1)
                assert.spy(C_Calendar.SetAbsMonth).was.called_with(now.month, now.year)
                assert.same({year = example.baseYear, month = example.baseMonth}, C_Calendar.GetMonthInfo())
                assert.is_false(filter)
            end
        end)

        it("keeps unresolved locations pending and searches only the configured occurrence", function()
            DarkmoonFaire.rules[Expansions.Era].default.location = {source = "calendar"}
            mockCalendarDays(2026, 8, {[0] = {
                [9] = {{texture = 235447}}, [18] = {{texture = 235450}},
            }})
            assert.equals("pending", DarkmoonFaire.GetCurrentState(true).status)
            assert.spy(C_Calendar.GetNumDayEvents).was.called(8)
            assert.spy(C_Calendar.GetNumDayEvents).was.called_with(0, 10)
            assert.spy(C_Calendar.GetNumDayEvents).was.called_with(0, 17)
            assert.spy(C_Calendar.GetNumDayEvents).was.not_called_with(0, 9)
            assert.spy(C_Calendar.GetNumDayEvents).was.not_called_with(0, 18)
            assert.is_false(filter)

            DarkmoonFaire.rules[Expansions.Era].default.timing.endHour = 0
            C_Calendar.GetNumDayEvents:clear()
            assert.equals("pending", DarkmoonFaire.GetCurrentState(true).status)
            assert.spy(C_Calendar.GetNumDayEvents).was.called(7)
            assert.spy(C_Calendar.GetNumDayEvents).was.not_called_with(0, 17)
        end)

        it("keeps the fortnightly location rotation when only timing switches to the calendar", function()
            seasonId = 2
            DarkmoonFaire.rules[Expansions.Era].seasons[2].timing = {source = "calendar"}
            now = {year = 2023, month = 12, monthDay = 18, hour = 12, minute = 0}
            events = {holiday(235450,
                {year = 2023, month = 12, monthDay = 18, hour = 0, minute = 1},
                {year = 2023, month = 12, monthDay = 24, hour = 23, minute = 59})}
            assert.equals("ELWYNN_FOREST", DarkmoonFaire.GetCurrentState(true).location)
        end)

        it("alternates SoD every fourteen civil days without minute or DST drift", function()
            seasonId = 2
            now = {year = 2023, month = 12, monthDay = 4, hour = 0, minute = 0}
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
            now.minute = 1
            assert.equals("MULGORE", DarkmoonFaire.GetCurrentState().location)
            now.monthDay, now.hour, now.minute = 10, 23, 59
            assert.equals("active", DarkmoonFaire.GetCurrentState().status)
            now.monthDay, now.hour, now.minute = 11, 0, 0
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
            now.monthDay, now.minute = 18, 1
            assert.equals("ELWYNN_FOREST", DarkmoonFaire.GetCurrentState().location)
            now = {year = 2024, month = 3, monthDay = 11, hour = 0, minute = 1}
            assert.equals("ELWYNN_FOREST", DarkmoonFaire.GetCurrentState().location)
            now = {year = 2026, month = 8, monthDay = 10, hour = 0, minute = 0}
            assert.equals("inactive", DarkmoonFaire.GetCurrentState().status)
            now.minute = 1
            assert.equals("MULGORE", DarkmoonFaire.GetCurrentState().location)
        end)

    end)

    describe("native month selection", function()
        local selectedMonth, dayEvent, holidayInfo

        before_each(function()
            Expansions.Current = Expansions.MoP
            now = {year = 2026, month = 9, monthDay = 7, hour = 17, minute = 44}
            selectedMonth = {year = 2026, month = 10}
            -- Relevant fields from the live MoP 5.5.4.69585 September 7 capture.
            dayEvent = {
                calendarType = "HOLIDAY", eventID = 479, sequenceType = "ONGOING", iconTexture = 235447,
                startTime = {year = 2026, month = 9, monthDay = 6, hour = 0, minute = 1},
                endTime = {year = 2026, month = 9, monthDay = 12, hour = 23, minute = 59},
            }
            holidayInfo = {
                texture = 235447,
                startTime = {year = 2026, month = 9, monthDay = 6, hour = 0, minute = 1},
                endTime = {year = 2026, month = 9, monthDay = 12, hour = 23, minute = 59},
            }
            C_Calendar.GetMonthInfo = function() return selectedMonth end
            C_Calendar.SetAbsMonth = spy.new(function(month, year)
                selectedMonth = {year = year, month = month}
            end)
            C_Calendar.GetNumDayEvents = spy.new(function(offset, day)
                -- Live queries omitted September 7 when October was selected, even at offset -1.
                if selectedMonth.year ~= 2026 or selectedMonth.month ~= 9 or offset ~= 0 or day ~= 7 then
                    return 0
                end
                return filter and 2 or 1
            end)
            C_Calendar.GetDayEvent = function(_, _, index)
                if filter and index == 1 then return dayEvent end
                return {calendarType = "HOLIDAY", eventID = 436, sequenceType = "END"}
            end
            C_Calendar.GetHolidayInfo = function(_, _, index)
                if filter and index == 1 then return holidayInfo end
                return { -- Call to Arms: Twin Peaks has timestamps but no texture in either record.
                    startTime = {year = 2026, month = 9, monthDay = 4, hour = 0, minute = 1},
                    endTime = {year = 2026, month = 9, monthDay = 7, hour = 23, minute = 59},
                }
            end
        end)

        it("finds the active Faire despite the selected month and hidden filter, then restores both", function()
            assert.equals(0, C_Calendar.GetNumDayEvents(-1, 7))

            assert.same({
                status = "active", location = "DARKMOON_ISLAND",
                startTime = {year = 2026, month = 9, monthDay = 6, hour = 0, minute = 1},
                endTime = {year = 2026, month = 9, monthDay = 12, hour = 23, minute = 59},
            }, DarkmoonFaire.GetCurrentState(true))

            assert.same({year = 2026, month = 10}, selectedMonth)
            assert.is_false(filter)
            assert.same({"1", "0"}, writes)
            assert.spy(C_Calendar.SetAbsMonth).was.called(2)
            assert.spy(C_Calendar.SetAbsMonth).was.called_with(9, 2026)
            assert.spy(C_Calendar.SetAbsMonth).was.called_with(10, 2026)
            assert.spy(C_Calendar.GetNumDayEvents).was.called_with(0, 7)
        end)

        it("does not change the selected month when it already contains the queried date", function()
            selectedMonth = {year = 2026, month = 9}
            assert.equals("active", DarkmoonFaire.GetCurrentState(true).status)
            assert.spy(C_Calendar.SetAbsMonth).was.not_called()
        end)

        it("restores the month and filter after an incomplete record", function()
            holidayInfo.endTime = nil
            assert.equals("pending", DarkmoonFaire.GetCurrentState(true).status)
            assert.same({year = 2026, month = 10}, selectedMonth)
            assert.is_false(filter)
        end)

        it("restores the month and filter after a native query error", function()
            C_Calendar.GetHolidayInfo = function() error("native calendar failure") end
            assert.equals("unavailable", DarkmoonFaire.GetCurrentState(true).status)
            assert.same({year = 2026, month = 10}, selectedMonth)
            assert.is_false(filter)
        end)

        it("still restores the month if restoring the filter throws", function()
            _G.SetCVar = function(_, value)
                if value == "0" then error("filter restoration failure") end
                filter = true
            end
            assert.equals("unavailable", DarkmoonFaire.GetCurrentState(true).status)
            assert.same({year = 2026, month = 10}, selectedMonth)
        end)

        it("returns unavailable with the filter restored if restoring the month throws", function()
            C_Calendar.SetAbsMonth = function(month, year)
                if month == 10 then error("month restoration failure") end
                selectedMonth = {year = year, month = month}
            end
            assert.equals("unavailable", DarkmoonFaire.GetCurrentState(true).status)
            assert.is_false(filter)
            assert.same({year = 2026, month = 9}, selectedMonth)
        end)

        it("requires absolute month selection rather than accepting incomplete off-month lists", function()
            C_Calendar.SetAbsMonth = nil
            assert.equals("unavailable", DarkmoonFaire.GetCurrentState(true).status)
            assert.same({}, writes)
        end)
    end)

    describe("calendar schedules", function()
        before_each(function()
            Expansions.Current = Expansions.Wotlk
            now.monthDay, now.hour = 2, 12
            events = {holiday()}
        end)

        it("checks availability before requesting calendar data", function()
            Expansions.Current = Expansions.MoP
            DarkmoonFaire.rules[Expansions.MoP].default.availability = {phaseKey = "MoP", minimumPhase = 4}
            local phases = QuestieLoader:ImportModule("ContentPhases").activePhases
            phases.MoP = 3
            QuestieCompat.GetCurrentCalendarTime = spy.new(QuestieCompat.GetCurrentCalendarTime)
            C_Calendar.GetMonthInfo = spy.new(C_Calendar.GetMonthInfo)
            C_Calendar.GetNumDayEvents = spy.new(function() return #events end)

            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
            assert.spy(QuestieCompat.GetCurrentCalendarTime).was.not_called()
            assert.spy(C_Calendar.GetMonthInfo).was.not_called()
            assert.spy(C_Calendar.GetNumDayEvents).was.not_called()
            assert.same({}, writes)

            phases.MoP = 4
            assert.equals("pending", DarkmoonFaire.GetCurrentState(false).status)
            assert.equals("active", DarkmoonFaire.GetCurrentState(true).status)
        end)

        it("requires readiness and distinguishes inactive from unavailable", function()
            assert.equals("pending", DarkmoonFaire.GetCurrentState().status)
            assert.same({}, writes)
            events = {}
            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
            _G.C_Calendar.GetHolidayInfo = nil
            assert.equals("unavailable", DarkmoonFaire.GetCurrentState(true).status)
        end)

        it("rejects times outside the returned interval and includes the native ending minute", function()
            now.monthDay, now.hour, now.minute = 1, 12, 0
            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
            now.monthDay, now.hour = 2, 0
            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
            now.minute = 1
            assert.equals("active", DarkmoonFaire.GetCurrentState(true).status)
            now.monthDay, now.hour, now.minute = 8, 23, 59
            assert.equals("active", DarkmoonFaire.GetCurrentState(true).status)
            now.monthDay, now.hour, now.minute = 9, 0, 0
            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
        end)

        it("recognizes all location textures for both original WotLK and Titan", function()
            local titanRule = DarkmoonFaire.rules[Expansions.Wotlk].seasons[Enum.SeasonID.TitanReforged]
            assert.equals("calendar", titanRule.timing.source)
            assert.equals("calendar", titanRule.location.source)
            local expected = {[235448] = "ELWYNN_FOREST", [235447] = "ELWYNN_FOREST", [235446] = "ELWYNN_FOREST",
                [235451] = "MULGORE", [235450] = "MULGORE", [235449] = "MULGORE",
                [235455] = "TEROKKAR_FOREST", [235454] = "TEROKKAR_FOREST", [235453] = "TEROKKAR_FOREST"}
            for _, id in ipairs({109, 999}) do
                seasonId = id
                for texture, location in pairs(expected) do
                    events = {holiday(texture)}
                    assert.equals(location, DarkmoonFaire.GetCurrentState(true).location)
                end
            end
        end)

        it("resolves island clients without accepting stale Mulgore/Terokkar textures", function()
            for _, expansion in ipairs({Expansions.Cata, Expansions.MoP, Expansions.MoP + 1}) do
                Expansions.Current = expansion
                for _, texture in ipairs({235448, 235447, 235446}) do
                    events = {holiday(texture)}
                    assert.equals("DARKMOON_ISLAND", DarkmoonFaire.GetCurrentState(true).location)
                end
                events = {holiday(235450), holiday(235454)}
                assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
            end
        end)

        it("selects the queried month and compares cross-year intervals", function()
            now = {year = 2027, month = 1, monthDay = 1, hour = 0, minute = 1}
            events = {holiday(235447, {year = 2026, month = 12, monthDay = 27, hour = 0, minute = 1},
                {year = 2027, month = 1, monthDay = 2, hour = 23, minute = 59})}
            _G.C_Calendar.GetMonthInfo = function() return {year = 2026, month = 12} end
            _G.C_Calendar.GetNumDayEvents = spy.new(function() return 1 end)
            local state = DarkmoonFaire.GetCurrentState(true)
            assert.equals("active", state.status)
            assert.same(events[1].startTime, state.startTime)
            assert.spy(_G.C_Calendar.GetNumDayEvents).was.called_with(0, 1)
            assert.spy(_G.C_Calendar.SetAbsMonth).was.called_with(1, 2027)
            assert.spy(_G.C_Calendar.SetAbsMonth).was.called_with(12, 2026)
            now.year = 2028
            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
        end)

        it("does not call holiday info for player events", function()
            events = {{calendarType = "PLAYER", texture = 235447}, holiday(1234)}
            local getHoliday = spy.new(_G.C_Calendar.GetHolidayInfo)
            _G.C_Calendar.GetHolidayInfo = getHoliday
            assert.equals("inactive", DarkmoonFaire.GetCurrentState(true).status)
            assert.spy(getHoliday).was.called(1)
            assert.spy(getHoliday).was.called_with(0, 2, 2)
        end)

        it("keeps incomplete or reversed holiday timestamps pending", function()
            events[1].startTime = nil
            assert.equals("pending", DarkmoonFaire.GetCurrentState(true).status)
            events[1].startTime = {year = 2027, month = 1, monthDay = 1, hour = 0, minute = 0}
            assert.equals("pending", DarkmoonFaire.GetCurrentState(true).status)
            _G.C_Calendar.GetDayEvent = function() return nil end
            assert.equals("pending", DarkmoonFaire.GetCurrentState(true).status)
        end)

        it("restores hidden filters after active, pending and error results", function()
            assert.equals("active", DarkmoonFaire.GetCurrentState(true).status)
            assert.is_false(filter)
            events[1].endTime = nil
            assert.equals("pending", DarkmoonFaire.GetCurrentState(true).status)
            assert.is_false(filter)
            _G.C_Calendar.GetHolidayInfo = function() error("native calendar failure") end
            assert.equals("unavailable", DarkmoonFaire.GetCurrentState(true).status)
            assert.is_false(filter)
            assert.same({"1", "0", "1", "0", "1", "0"}, writes)
        end)

        it("leaves an already-visible calendar filter untouched", function()
            filter = true
            assert.equals("active", DarkmoonFaire.GetCurrentState(true).status)
            assert.same({}, writes)
            assert.is_true(filter)
        end)
    end)
end)
