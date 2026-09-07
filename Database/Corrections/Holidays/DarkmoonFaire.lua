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
---@class DMFRule
---@field timing DMFTimingRule?
---@field location DMFLocationRule?
---@field minimumAnniversaryPhase number?
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
                timing = {source = "monthly", setupWeekday = 6, startWeekday = 2,
                    startHour = 3, startMinute = 0, endDayOffset = 7, endHour = 3, endMinute = 0},
                location = {source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}},
            },
            [Enum.SeasonID.SeasonOfDiscovery] = {
                timing = {source = "fortnightly", anchor = {year = 2023, month = 12, monthDay = 4},
                    startHour = 0, startMinute = 1, endDayOffset = 6, endHour = 23, endMinute = 59, endInclusive = true},
                location = {source = "fortnightly", anchor = {year = 2023, month = 12, monthDay = 4},
                    locations = {"MULGORE", "ELWYNN_FOREST"}},
            },
            [Enum.SeasonID.Fresh] = {
                timing = {source = "monthly", setupWeekday = 6, startWeekday = 2,
                    startHour = 3, startMinute = 0, endDayOffset = 7, endHour = 3, endMinute = 0},
                location = {source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}},
                minimumAnniversaryPhase = 3,
            },
            [Enum.SeasonID.FreshHardcore] = {
                timing = {source = "monthly", setupWeekday = 6, startWeekday = 2,
                    startHour = 3, startMinute = 0, endDayOffset = 7, endHour = 3, endMinute = 0},
                location = {source = "monthly", locations = {"ELWYNN_FOREST", "MULGORE"}},
                minimumAnniversaryPhase = 3,
            },
        },
    },
    [Expansions.Tbc] = {
        default = {
            timing = {source = "monthly", setupWeekday = 6, startWeekday = 2,
                startHour = 3, startMinute = 0, endDayOffset = 7, endHour = 3, endMinute = 0},
            location = {source = "monthly", locations = {"MULGORE", "ELWYNN_FOREST", "TEROKKAR_FOREST"}},
        },
        seasons = {
            [Enum.SeasonID.Fresh] = {
                timing = {source = "monthly", setupWeekday = 6, startWeekday = 2,
                    startHour = 3, startMinute = 0, endDayOffset = 7, endHour = 3, endMinute = 0},
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
        default = {timing = {source = "calendar"}, location = {source = "fixed", location = "DARKMOON_ISLAND"}},
        seasons = {},
    },
    [Expansions.MoP] = {
        default = {timing = {source = "calendar"}, location = {source = "fixed", location = "DARKMOON_ISLAND"}},
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

---@param value CalendarTime?
---@return boolean
local function _HasDate(value)
    return type(value) == "table" and type(value.year) == "number" and value.year > 0
        and type(value.month) == "number" and value.month >= 1 and value.month <= 12
        and type(value.monthDay) == "number" and value.monthDay >= 1 and value.monthDay <= 31
end

---@param value CalendarTime?
---@return boolean
local function _HasTime(value)
    return _HasDate(value) and type(value.hour) == "number" and value.hour >= 0 and value.hour < 24
        and type(value.minute) == "number" and value.minute >= 0 and value.minute < 60
end

---Civil-day arithmetic avoids local timezone/DST changes and cumulative recurrence drift.
---@param value CalendarTime
---@return number dayNumber January 1, year 1 is Monday, day 1.
local function _DayNumber(value)
    local year = value.year - 1
    local days = year * 365 + math.floor(year / 4) - math.floor(year / 100) + math.floor(year / 400)
    local monthDays = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    if value.year % 4 == 0 and (value.year % 100 ~= 0 or value.year % 400 == 0) then
        monthDays[2] = 29
    end
    for month = 1, value.month - 1 do
        days = days + monthDays[month]
    end
    return days + value.monthDay
end

---@param value CalendarTime
---@return number
local function _MinuteNumber(value)
    return _DayNumber(value) * 1440 + value.hour * 60 + value.minute
end

---Converts only the requested occurrence days, without local timezone conversion.
---@param reference CalendarTime
---@param dayNumber number
---@return CalendarTime
local function _DateAtDayNumber(reference, dayNumber)
    local year, month = reference.year, reference.month
    local firstDay = _DayNumber({year = year, month = month, monthDay = 1})
    while dayNumber < firstDay do
        month = month - 1
        if month == 0 then year, month = year - 1, 12 end
        firstDay = _DayNumber({year = year, month = month, monthDay = 1})
    end
    while true do
        local nextYear, nextMonth = year, month + 1
        if nextMonth == 13 then nextYear, nextMonth = year + 1, 1 end
        local nextFirstDay = _DayNumber({year = nextYear, month = nextMonth, monthDay = 1})
        if dayNumber < nextFirstDay then
            return {year = year, month = month, monthDay = dayNumber - firstDay + 1}
        end
        year, month, firstDay = nextYear, nextMonth, nextFirstDay
    end
end

---@param now CalendarTime
---@param timing DMFTimingRule
---@return boolean active
---@return number? firstDay
---@return number? lastDay
local function _CalculatedTiming(now, timing)
    local startDay
    if timing.source == "fortnightly" then
        local anchorDay = _DayNumber(timing.anchor)
        local cycle = math.floor((_DayNumber(now) - anchorDay) / 14)
        if cycle < 0 then
            return false
        end
        startDay = anchorDay + cycle * 14
    else
        local firstDay = _DayNumber({year = now.year, month = now.month, monthDay = 1})
        local setupDay = firstDay + (timing.setupWeekday - (firstDay % 7 + 1)) % 7
        local openingOffset = (timing.startWeekday - timing.setupWeekday) % 7
        startDay = setupDay + (openingOffset == 0 and 7 or openingOffset)
    end
    local startMinute = startDay * 1440 + timing.startHour * 60 + timing.startMinute
    local endMinute = (startDay + timing.endDayOffset) * 1440 + timing.endHour * 60 + timing.endMinute
    local currentMinute = _MinuteNumber(now)
    local beforeEnd = currentMinute < endMinute or (timing.endInclusive and currentMinute == endMinute)
    -- An exclusive midnight ending does not include any calendar entries on the closing day.
    local lastDay = math.floor((endMinute - (timing.endInclusive and 0 or 1)) / 1440)
    return currentMinute >= startMinute and not not beforeEnd, startDay, lastDay
end

---@param texture number?
---@param locationRule DMFLocationRule
---@return DMFLocation?
local function _CalendarLocation(texture, locationRule)
    local location = locationByTexture[texture]
    if locationRule.source == "fixed" and locationRule.location == "DARKMOON_ISLAND" then
        -- Ignore stale rotating-location records on island clients.
        return location == "ELWYNN_FOREST" and "DARKMOON_ISLAND" or nil
    end
    return location
end

---@param now CalendarTime
---@param locationRule DMFLocationRule
---@param useCalendarTiming boolean
---@return DarkmoonFaireState
local function _ReadCalendar(now, locationRule, useCalendarTiming)
    local base = C_Calendar.GetMonthInfo()
    if not base or not base.year or not base.month then
        return {status = "pending"}
    end
    local offset = (now.year - base.year) * 12 + now.month - base.month
    local count = C_Calendar.GetNumDayEvents(offset, now.monthDay)
    if not count then
        return {status = "pending"}
    end
    local pending = false
    for index = 1, count do
        local dayEvent = C_Calendar.GetDayEvent and C_Calendar.GetDayEvent(offset, now.monthDay, index)
        if C_Calendar.GetDayEvent and not dayEvent then
            pending = true
        elseif not dayEvent or dayEvent.calendarType == "HOLIDAY" then
            local holiday = C_Calendar.GetHolidayInfo(offset, now.monthDay, index)
            local location = holiday and _CalendarLocation(holiday.texture, locationRule)
            if not holiday then
                pending = true
            elseif location then
                -- A location-only lookup must not replace the configured calculated opening/closing times.
                if not useCalendarTiming then
                    return {status = "active", location = location}
                end
                if not _HasTime(holiday.startTime) or not _HasTime(holiday.endTime) then
                    pending = true
                else
                    local startMinute = _MinuteNumber(holiday.startTime)
                    local endMinute = _MinuteNumber(holiday.endTime)
                    if startMinute > endMinute then
                        pending = true
                    elseif _MinuteNumber(now) >= startMinute and _MinuteNumber(now) <= endMinute then
                        -- Native calendar endpoints are minute-granular (observed through 23:59).
                        return {status = "active", location = location, startTime = holiday.startTime, endTime = holiday.endTime}
                    end
                end
            end
        end
    end
    return {status = pending and "pending" or "inactive"}
end

---@param now CalendarTime
---@param locationRule DMFLocationRule
---@param calendarReady boolean?
---@param calculatedRange DMFCalendarRange? Search this occurrence for location only; nil uses today's native timing.
---@return DarkmoonFaireState
local function _CalendarState(now, locationRule, calendarReady, calculatedRange)
    if not C_Calendar or not C_Calendar.GetMonthInfo or not C_Calendar.GetNumDayEvents
        or not C_Calendar.GetHolidayInfo or not GetCVarBool or not SetCVar then
        return {status = "unavailable"}
    end
    if not calendarReady then
        return {status = "pending"}
    end

    local wasVisible = GetCVarBool("calendarShowDarkmoon")
    -- Restore the player's filter even when native calendar access throws.
    local ok, state = pcall(function()
        if not wasVisible then
            SetCVar("calendarShowDarkmoon", "1")
        end
        if not calculatedRange then
            return _ReadCalendar(now, locationRule, true)
        end

        -- A calculated closing day may have no native event. Find the location elsewhere in this occurrence.
        for day = calculatedRange.firstDay, calculatedRange.lastDay do
            local date = _DateAtDayNumber(now, day)
            local locationState = _ReadCalendar(date, locationRule, false)
            if locationState.status == "active" then
                return locationState
            end
        end
        -- Timing is known to be active; missing location data must not turn it into an inactive result.
        return {status = "pending"}
    end)
    if not wasVisible then
        SetCVar("calendarShowDarkmoon", "0")
    end
    if not ok then
        return {status = "unavailable"}
    end
    return state
end

---Resolves one startup snapshot; the caller owns calendar requests, readiness, retries and timeout.
---A season replaces each timing/location rule as a whole, with omitted rules inherited from the expansion.
---@param calendarReady boolean? True after the calendar event list has loaded.
---@return DarkmoonFaireState
function DarkmoonFaire.GetCurrentState(calendarReady)
    local expansionRules = DarkmoonFaire.rules[Expansions.Current]
    if not expansionRules and Expansions.Current and Expansions.Current > Expansions.MoP then
        expansionRules = DarkmoonFaire.rules[Expansions.MoP]
    end
    if not expansionRules then
        return {status = "unavailable"}
    end
    local seasonId = C_Seasons and C_Seasons.HasActiveSeason and C_Seasons.GetActiveSeason
        and C_Seasons.HasActiveSeason() and C_Seasons.GetActiveSeason()
    local season = expansionRules.seasons[seasonId] or {}
    local timing = season.timing or expansionRules.default.timing
    local locationRule = season.location or expansionRules.default.location
    local minimumPhase = season.minimumAnniversaryPhase or expansionRules.default.minimumAnniversaryPhase
    if minimumPhase and (not ContentPhases.activePhases or (ContentPhases.activePhases.Anniversary or 0) < minimumPhase) then
        return {status = "inactive"}
    end

    local now = QuestieCompat.GetCurrentCalendarTime()
    if not _HasTime(now) then
        return {status = "pending"}
    end
    local state
    if timing.source == "calendar" then
        state = _CalendarState(now, locationRule, calendarReady)
    else
        local active, firstDay, lastDay = _CalculatedTiming(now, timing)
        if not active then
            return {status = "inactive"}
        end
        if locationRule.source == "calendar" then
            state = _CalendarState(now, locationRule, calendarReady, {firstDay = firstDay, lastDay = lastDay})
        else
            state = {status = "active"}
        end
    end
    if state.status ~= "active" then
        return state
    end

    if locationRule.source == "monthly" then
        state.location = locationRule.locations[(now.month - 1) % #locationRule.locations + 1]
    elseif locationRule.source == "fortnightly" then
        local cycle = math.floor((_DayNumber(now) - _DayNumber(locationRule.anchor)) / 14)
        state.location = locationRule.locations[cycle % #locationRule.locations + 1]
    elseif locationRule.source == "fixed" then
        state.location = locationRule.location
    end
    return state
end
