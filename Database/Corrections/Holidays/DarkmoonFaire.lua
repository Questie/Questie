---@class DarkmoonFaire
local DarkmoonFaire = QuestieLoader:CreateModule("DarkmoonFaire")

---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")

---@alias DMFLocation "MULGORE"|"ELWYNN_FOREST"|"TEROKKAR_FOREST"|"DARKMOON_ISLAND"

---@class DarkmoonFaireState
---@field status "active"|"inactive"|"pending"|"unavailable"
---@field location DMFLocation?
---@field startTime CalendarTime?
---@field endTime CalendarTime?

---@class DMFCalendarRange
---@field firstDay number First civil day belonging to the calculated occurrence.
---@field lastDay number Last civil day belonging to the calculated occurrence.

---@class DMFTimingRule
---@field source "monthly"|"fortnightly"|"calendar"
---@field setupWeekday number? First setup weekday of the month, Sunday = 1.
---@field startWeekday number? Opening weekday strictly after setup, Sunday = 1.
---@field startHour number?
---@field startMinute number?
---@field endDayOffset number? Calendar days after opening.
---@field endHour number?
---@field endMinute number?
---@field endInclusive boolean? Include the final minute; calculated Monday 03:00 endings exclude it.
---@field anchor CalendarTime? First opening date for a fortnightly schedule.

---@class DMFLocationRule
---@field source "monthly"|"fortnightly"|"calendar"|"fixed"
---@field locations DMFLocation[]? January-first monthly rotation, or anchor-first fortnightly rotation.
---@field anchor CalendarTime? Location rotation anchor, independent of the timing rule.
---@field location DMFLocation?

---@class DMFAvailabilityRule
---@field phaseKey string Key in ContentPhases.activePhases; an unknown counter is treated as phase 0.
---@field minimumPhase number

---@class DMFRule
---@field timing DMFTimingRule?
---@field location DMFLocationRule?
---@field availability DMFAvailabilityRule?

---@class DMFExpansionRules
---@field default DMFRule
---@field seasons table<number, DMFRule>

-- Expansion defaults also cover non-seasonal Hardcore and unknown seasons.
-- Season entries below deliberately repeat policy so each supported variant is independently editable.
---@type table<number, DMFExpansionRules>
DarkmoonFaire.rules = {
    [Expansions.Era] = {
        default = {
            timing = {
                -- Meta
                source = "monthly",
                setupWeekday = 6,
                -- Start
                startWeekday = 2,
                startHour = 3, startMinute = 0,
                -- End
                endDayOffset = 7,
                endHour = 3, endMinute = 0
            },
            location = {source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}},
        },
        seasons = {
            [Enum.SeasonID.SeasonOfMastery] = {
                timing = {
                    -- Meta
                    source = "monthly",
                    setupWeekday = 6,
                    -- Start
                    startWeekday = 2,
                    startHour = 3, startMinute = 0,
                    -- End
                    endDayOffset = 7,
                    endHour = 3, endMinute = 0
                },
                location = {source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}},
            },
            [Enum.SeasonID.SeasonOfDiscovery] = {
                timing = {
                    -- Meta
                    source = "fortnightly",
                    anchor = {year = 2023, month = 12, monthDay = 4},
                    -- Start
                    startHour = 0, startMinute = 1,
                    -- End
                    endDayOffset = 6,
                    endHour = 23, endMinute = 59,
                    endInclusive = true
                },
                location = {
                    source = "fortnightly",
                    anchor = {year = 2023, month = 12, monthDay = 4},
                    locations = {"MULGORE", "ELWYNN_FOREST"}
                },
            },
            [Enum.SeasonID.Hardcore] = {
                timing = {
                    -- Meta
                    source = "monthly",
                    setupWeekday = 6,
                    -- Start
                    startWeekday = 2,
                    startHour = 3, startMinute = 0,
                    -- End
                    endDayOffset = 7,
                    endHour = 3, endMinute = 0
                },
                location = {source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}},
            },
            [Enum.SeasonID.Fresh] = {
                timing = {
                    -- Meta
                    source = "monthly",
                    setupWeekday = 6,
                    -- Start
                    startWeekday = 2,
                    startHour = 3, startMinute = 0,
                    -- End
                    endDayOffset = 7,
                    endHour = 3, endMinute = 0
                },
                location = {source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}},
                availability = {
                    phaseKey = "Anniversary",
                    minimumPhase = 3,
                },
            },
            [Enum.SeasonID.FreshHardcore] = {
                timing = {
                    -- Meta
                    source = "monthly",
                    setupWeekday = 6,
                    -- Start
                    startWeekday = 2,
                    startHour = 3, startMinute = 0,
                    -- End
                    endDayOffset = 7,
                    endHour = 3, endMinute = 0
                },
                location = {source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}},
                availability = {
                    phaseKey = "Anniversary",
                    minimumPhase = 3,
                },
            },
        },
    },
    [Expansions.Tbc] = {
        default = {
            timing = {
                -- Meta
                source = "monthly",
                setupWeekday = 6,
                -- Start
                startWeekday = 2,
                startHour = 3, startMinute = 0,
                -- End
                endDayOffset = 7,
                endHour = 3, endMinute = 0
            },
            location = {source = "monthly", locations = {"MULGORE", "ELWYNN_FOREST", "TEROKKAR_FOREST"}},
        },
        seasons = {
            [Enum.SeasonID.Fresh] = {
                timing = {
                    -- Meta
                    source = "monthly",
                    setupWeekday = 6,
                    -- Start
                    startWeekday = 2,
                    startHour = 3, startMinute = 0,
                    -- End
                    endDayOffset = 7,
                    endHour = 3, endMinute = 0
                },
                location = {source = "monthly", locations = {"MULGORE", "ELWYNN_FOREST", "TEROKKAR_FOREST"}},
            },
        },
    },
    [Expansions.Wotlk] = {
        default = {
            timing = {source = "calendar"}, location = {source = "calendar"}
        },
        seasons = {
            [Enum.SeasonID.TitanReforged] = {
                timing = {source = "calendar"}, location = {source = "calendar"},
            },
        },
    },
    [Expansions.Cata] = {
        default = {
            timing = {source = "calendar"}, location = {source = "fixed", location = "DARKMOON_ISLAND"}
        },
        seasons = {},
    },
    [Expansions.MoP] = {
        default = {
            timing = {source = "calendar"}, location = {source = "fixed", location = "DARKMOON_ISLAND"}
        },
        seasons = {},
    },
}

-- Holidays DBC rows 374, 375 and 376 have separate start/ongoing/end texture sets.
-- Row 479 (the island) reuses Elwynn's textures; its location is selected by expansion policy.
---@type table<number, DMFLocation>
local locationByTexture = {
    [235448] = "ELWYNN_FOREST", -- Start
    [235447] = "ELWYNN_FOREST", -- Ongoing
    [235446] = "ELWYNN_FOREST", -- End

    [235451] = "MULGORE", -- Start
    [235450] = "MULGORE", -- Ongoing
    [235449] = "MULGORE", -- End

    [235455] = "TEROKKAR_FOREST", -- Start
    [235454] = "TEROKKAR_FOREST", -- Ongoing
    [235453] = "TEROKKAR_FOREST", -- End
}

-- Calendar value checks and civil-date arithmetic

---Checks date-field ranges, not whether a day exists in a particular month (for example, February 31).
---@param value CalendarTime?
---@return boolean
local function _HasDate(value)
    if type(value) ~= "table" then
        return false
    end

    local validYear = type(value.year) == "number" and value.year > 0
    if not validYear then
        return false
    end

    local validMonth = type(value.month) == "number" and value.month >= 1 and value.month <= 12
    if not validMonth then
        return false
    end

    return type(value.monthDay) == "number" and value.monthDay >= 1 and value.monthDay <= 31
end

---A calendar timestamp needs both the date and a complete clock value; a date alone is not midnight.
---@param value CalendarTime?
---@return boolean
local function _HasTime(value)
    if not _HasDate(value) then
        return false
    end

    local validHour = type(value.hour) == "number" and value.hour >= 0 and value.hour < 24
    if not validHour then
        return false
    end

    return type(value.minute) == "number" and value.minute >= 0 and value.minute < 60
end

---Civil-day arithmetic avoids local timezone/DST changes and cumulative recurrence drift.
---@param value CalendarTime
---@return number dayNumber January 1, year 1 is Monday, day 1.
local function _DayNumber(value)
    -- Count completed years, including Gregorian leap days.
    local completedYears = value.year - 1
    local days = completedYears * 365
        + math.floor(completedYears / 4)
        - math.floor(completedYears / 100)
        + math.floor(completedYears / 400)

    -- February's length depends on the current year, not the completed-year count above.
    local daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local isLeapYear = value.year % 4 == 0 and (value.year % 100 ~= 0 or value.year % 400 == 0)
    if isLeapYear then
        daysInMonth[2] = 29
    end

    for month = 1, value.month - 1 do
        days = days + daysInMonth[month]
    end

    return days + value.monthDay
end

---Uses the civil-day scale for clock comparisons, not Unix time or the computer's timezone.
---@param value CalendarTime
---@return number minuteNumber Day number * 1440 plus the hour/minute within that day.
local function _MinuteNumber(value)
    local dayNumber = _DayNumber(value)
    return dayNumber * 1440 + value.hour * 60 + value.minute
end

---Finds the date components for an occurrence day, starting from the nearby reference month.
---@param reference CalendarTime
---@param dayNumber number Civil day on the same scale as _DayNumber.
---@return CalendarTime date Date components only; no clock values are added.
local function _DateAtDayNumber(reference, dayNumber)
    local year, month = reference.year, reference.month
    local firstDayOfMonth = _DayNumber({year = year, month = month, monthDay = 1})

    -- An occurrence can begin in a month before the reference date.
    while dayNumber < firstDayOfMonth do
        month = month - 1
        if month == 0 then
            year = year - 1
            month = 12
        end

        firstDayOfMonth = _DayNumber({year = year, month = month, monthDay = 1})
    end

    -- Walk forward until the requested day falls before the next month's first day.
    while true do
        local nextYear, nextMonth = year, month + 1
        if nextMonth == 13 then
            nextYear = year + 1
            nextMonth = 1
        end

        local firstDayOfNextMonth = _DayNumber({year = nextYear, month = nextMonth, monthDay = 1})
        if dayNumber < firstDayOfNextMonth then
            return {
                year = year,
                month = month,
                monthDay = dayNumber - firstDayOfMonth + 1,
            }
        end

        year, month = nextYear, nextMonth
        firstDayOfMonth = firstDayOfNextMonth
    end
end

-- Calculated occurrence timing

---Resolves activity and the occurrence dates to search when its location comes from the calendar.
---@param now CalendarTime
---@param timing DMFTimingRule
---@return boolean active
---@return number? firstDay First civil day of the occurrence, unless now precedes the fortnightly anchor.
---@return number? lastDay Last civil day containing an included minute of the occurrence.
local function _CalculatedTiming(now, timing)
    -- Find the opening day independently of its clock time.
    local startDay
    if timing.source == "fortnightly" then
        local anchorDay = _DayNumber(timing.anchor)
        local daysSinceAnchor = _DayNumber(now) - anchorDay
        local cycle = math.floor(daysSinceAnchor / 14)
        if cycle < 0 then
            return false
        end

        startDay = anchorDay + cycle * 14
    else
        local firstDayOfMonth = _DayNumber({year = now.year, month = now.month, monthDay = 1})

        -- Civil day 1 is Monday; configured weekday values use Sunday = 1.
        local firstWeekday = firstDayOfMonth % 7 + 1
        local daysUntilSetup = (timing.setupWeekday - firstWeekday) % 7
        local setupDay = firstDayOfMonth + daysUntilSetup

        -- Opening must follow setup strictly, even if both use the same weekday.
        local openingOffset = (timing.startWeekday - timing.setupWeekday) % 7
        if openingOffset == 0 then
            openingOffset = 7
        end

        startDay = setupDay + openingOffset
    end

    -- Opening is inclusive; only rules with endInclusive include the closing minute.
    local openingMinute = startDay * 1440 + timing.startHour * 60 + timing.startMinute
    local closingMinute = (startDay + timing.endDayOffset) * 1440 + timing.endHour * 60 + timing.endMinute
    local currentMinute = _MinuteNumber(now)

    local beforeEnd = currentMinute < closingMinute
    if timing.endInclusive and currentMinute == closingMinute then
        beforeEnd = true
    end

    local active = currentMinute >= openingMinute and beforeEnd

    -- Location-only calendar queries need the dates touched by the occurrence.
    -- An exclusive midnight ending excludes the closing date entirely.
    local lastActiveMinute = closingMinute
    if not timing.endInclusive then
        lastActiveMinute = closingMinute - 1
    end

    local lastDay = math.floor(lastActiveMinute / 1440)
    return active, startDay, lastDay
end

-- Native calendar identification and queries

---Identifies recognized Faire artwork while applying the island's shared-texture exception.
---@param texture number?
---@param locationRule DMFLocationRule
---@return DMFLocation?
local function _CalendarLocation(texture, locationRule)
    local textureLocation = locationByTexture[texture]

    if locationRule.source == "fixed" and locationRule.location == "DARKMOON_ISLAND" then
        -- The island shares Elwynn artwork. Stale Mulgore/Terokkar records are not island occurrences.
        if textureLocation == "ELWYNN_FOREST" then
            return "DARKMOON_ISLAND"
        end

        return nil
    end

    return textureLocation
end

---The caller selects this date's month; off-month queries can omit native holiday records.
---@param now CalendarTime
---@param locationRule DMFLocationRule
---@param useCalendarTiming boolean
---@return DarkmoonFaireState
local function _ReadCalendar(now, locationRule, useCalendarTiming)
    local count = C_Calendar.GetNumDayEvents(0, now.monthDay)
    if not count then
        return {status = "pending"}
    end

    local pending = false
    for index = 1, count do
        local dayEvent = C_Calendar.GetDayEvent and C_Calendar.GetDayEvent(0, now.monthDay, index)

        if C_Calendar.GetDayEvent and not dayEvent then
            pending = true
        elseif not dayEvent or dayEvent.calendarType == "HOLIDAY" then
            local holiday = C_Calendar.GetHolidayInfo(0, now.monthDay, index)
            local location = holiday and _CalendarLocation(holiday.texture, locationRule)

            if not holiday then
                pending = true
            elseif location then
                -- A location-only lookup must not replace the configured calculated opening/closing times.
                if not useCalendarTiming then
                    return {status = "active", location = location}
                end

                -- Calendar-timed occurrences require both complete endpoints before comparing activity.
                if not _HasTime(holiday.startTime) or not _HasTime(holiday.endTime) then
                    pending = true
                else
                    local startMinute = _MinuteNumber(holiday.startTime)
                    local endMinute = _MinuteNumber(holiday.endTime)

                    if startMinute > endMinute then
                        pending = true
                    elseif _MinuteNumber(now) >= startMinute and _MinuteNumber(now) <= endMinute then
                        -- Native calendar endpoints are minute-granular (observed through 23:59).
                        return {
                            status = "active",
                            location = location,
                            startTime = holiday.startTime,
                            endTime = holiday.endTime,
                        }
                    end
                end
            end
        end
    end

    return {status = pending and "pending" or "inactive"}
end

---Queries the requested months and attempts to restore the player's calendar settings on every exit.
---@param now CalendarTime
---@param locationRule DMFLocationRule
---@param calendarReady boolean?
---@param calculatedRange DMFCalendarRange? Search this occurrence for location only; nil uses today's native timing.
---@return DarkmoonFaireState
local function _CalendarState(now, locationRule, calendarReady, calculatedRange)
    if not C_Calendar
        or not C_Calendar.GetMonthInfo
        or not C_Calendar.SetAbsMonth
        or not C_Calendar.GetNumDayEvents
        or not C_Calendar.GetHolidayInfo
        or not GetCVarBool
        or not SetCVar
    then
        return {status = "unavailable"}
    end

    if not calendarReady then
        return {status = "pending"}
    end

    local wasVisible, originalMonth
    local monthChanged = false

    local ok, state = pcall(function()
        -- Preserve the player's selection before changing either the month or the holiday filter.
        originalMonth = C_Calendar.GetMonthInfo()
        if not originalMonth or not originalMonth.year or not originalMonth.month then
            return {status = "pending"}
        end

        local selectedMonth = originalMonth

        wasVisible = GetCVarBool("calendarShowDarkmoon")
        if not wasVisible then
            SetCVar("calendarShowDarkmoon", "1")
        end

        ---Select the actual month before accepting an empty list as evidence of inactivity.
        ---@param date CalendarTime
        ---@param useCalendarTiming boolean
        ---@return DarkmoonFaireState
        local function readCalendar(date, useCalendarTiming)
            if selectedMonth.year ~= date.year or selectedMonth.month ~= date.month then
                -- SetMonth(0) only refreshes the selected month. Negative offsets can return false empty lists.
                -- Selecting/restoring a month can notify synchronously; startup's caller guards reentrant checks.
                monthChanged = true
                C_Calendar.SetAbsMonth(date.month, date.year)
                selectedMonth = date
            end

            return _ReadCalendar(date, locationRule, useCalendarTiming)
        end

        if not calculatedRange then
            return readCalendar(now, true)
        end

        -- A calculated closing day may have no native event. Find the location elsewhere in this occurrence.
        for day = calculatedRange.firstDay, calculatedRange.lastDay do
            local date = _DateAtDayNumber(now, day)
            local locationState = readCalendar(date, false)
            if locationState.status == "active" then
                return locationState
            end
        end

        -- Timing is known to be active; missing location data must not turn it into an inactive result.
        return {status = "pending"}
    end)

    -- Attempt both restorations even if querying or one of the restoration calls throws.
    local filterRestored, monthRestored = true, true
    if wasVisible == false then
        filterRestored = pcall(SetCVar, "calendarShowDarkmoon", "0")
    end

    if monthChanged then
        monthRestored = pcall(C_Calendar.SetAbsMonth, originalMonth.month, originalMonth.year)
    end

    if not ok or not filterRestored or not monthRestored then
        return {status = "unavailable"}
    end

    return state
end

-- Startup snapshot resolution

---Resolves one startup snapshot; the caller owns calendar requests, readiness, retries and timeout.
---A season replaces each timing/location/availability rule as a whole; omitted rules inherit the expansion default.
---@param calendarReady boolean? True after the calendar event list has loaded.
---@return DarkmoonFaireState
function DarkmoonFaire.GetCurrentState(calendarReady)
    -- Choose each rule independently, inheriting omitted season rules from the expansion.
    local expansionRules = DarkmoonFaire.rules[Expansions.Current]
    if not expansionRules and Expansions.Current and Expansions.Current > Expansions.MoP then
        expansionRules = DarkmoonFaire.rules[Expansions.MoP]
    end

    if not expansionRules then
        return {status = "unavailable"}
    end

    local seasonId = C_Seasons
        and C_Seasons.HasActiveSeason
        and C_Seasons.GetActiveSeason
        and C_Seasons.HasActiveSeason()
        and C_Seasons.GetActiveSeason()

    local season = expansionRules.seasons[seasonId] or {}
    local timing = season.timing or expansionRules.default.timing
    local locationRule = season.location or expansionRules.default.location
    local availability = season.availability or expansionRules.default.availability

    -- Phase-gated content needs no clock or calendar query until it becomes available.
    if availability then
        local activePhase = ContentPhases.activePhases and ContentPhases.activePhases[availability.phaseKey] or 0
        if activePhase < availability.minimumPhase then
            return {status = "inactive"}
        end
    end

    local now = QuestieCompat.GetCurrentCalendarTime()
    if not _HasTime(now) then
        return {status = "pending"}
    end

    -- Resolve activity first. A calculated schedule may still need the calendar for its location.
    local state
    if timing.source == "calendar" then
        state = _CalendarState(now, locationRule, calendarReady)
    else
        local active, firstDay, lastDay = _CalculatedTiming(now, timing)
        if not active then
            return {status = "inactive"}
        end

        if locationRule.source == "calendar" then
            local occurrenceDates = {firstDay = firstDay, lastDay = lastDay}
            state = _CalendarState(now, locationRule, calendarReady, occurrenceDates)
        else
            state = {status = "active"}
        end
    end

    if state.status ~= "active" then
        return state
    end

    -- Calculated/fixed locations do not replace the timestamps returned by calendar timing.
    if locationRule.source == "monthly" then
        local locationIndex = (now.month - 1) % #locationRule.locations + 1
        state.location = locationRule.locations[locationIndex]
    elseif locationRule.source == "fortnightly" then
        local daysSinceAnchor = _DayNumber(now) - _DayNumber(locationRule.anchor)
        local cycle = math.floor(daysSinceAnchor / 14)
        local locationIndex = cycle % #locationRule.locations + 1
        state.location = locationRule.locations[locationIndex]
    elseif locationRule.source == "fixed" then
        state.location = locationRule.location
    end

    return state
end
