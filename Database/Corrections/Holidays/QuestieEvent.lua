---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

--[[
Feast of Winter Veil    1.2.0    18 December 2004
Noblegarden    1.3.0    7 March 2005    X
Children's Week    1.4.0    5 May 2005
Darkmoon Faire    1.6.0    2 July 2005
Harvest Festival    1.6.0    2 July 2005    X
Hallow's End    1.8.0    10 October 2005
Lunar Festival    1.9.0    3 January 2006    X
Love is in the Air    1.9.3    7 February 2006
Midsummer Fire Festival    1.11.0    20 June 2006
Peon Day    1.12.1    22 August 2006    X

New Year    31st Dec - 1st Jan    New Year's Eve    Gregorian calendar
Lunar Festival    Varies (Spring)    Lunar New Year    Chinese calendar
Love is in the Air    7th Feb - 20th Feb    Valentine's Day
Noblegarden    Varies (Easter)    Easter
Children's Week    1st May - 7th May    Children's Day - Japan
Mother's Day - US (and in most other countries, including: Belgium and the Netherlands)
Midsummer Fire Festival    21st June - 5th July    Midsummer
Canada Day - CAN
Independence Day - US    US observed! Fire in the Sky Engineers' Explosive Extravaganza
Pirates' Day    19th Sept    International Talk Like a Pirate Day    First observed Sept 19th, 2008.
Brewfest    20th Sept - 4th Oct    Oktoberfest - Germany
Harvest Festival    27th Sept - 4th Oct    Roughly Thanksgiving - Canada, US (actually celebrated in October and November in Canada and US, respectively)
Columbus Day - US
US Stress Test ended: September 12, 2004
Peon Day    30th Sept    EU Closed Beta began: September 30, 2004    Observed only in Europe[1]
Hallow's End    18th Oct - 1st Nov    Halloween
Day of the Dead    1st Nov - 2nd Nov    Day of the Dead
WoW's Anniversary    16th Nov - 30th Nov
Pilgrim's Bounty    22nd Nov - 28th Nov    Thanksgiving
Feast of Winter Veil    15th Dec - 2nd Jan    Christmas

Harvest Festival history:         lunar calendar 15/8 in gregorian calendar:
2009: Su-Sa 27/9 - 3/10 (wowpedia)    3/10
2010: Th-We 16/9 - 22/9 (wowpedia)   22/9
2011: Tu-Mo  6/9 - 12/9 (wowpedia)   12/9
2012: Mo-Mo 24/9 - 1/10 (wowpedia)   30/9
2013: Fr-Fr 13/9 - 20/9 (wowpedia)   19/9
2014: Tu-Tu  2/9 -  9/9 (Blizz post)  8/9
2015: Mo-Mo 21/9 - 28/9 (wowpedia)   27/9
2016: Fr-Fr  9/9 - 16/9 (Blizz post) 15/9
2017: Fr-Fr 29/9 - 6/10 (wowpedia)    4/10
2018: Tu-Tu 18/9 - 25/9 (wowpedia)   24/9
2019: Tu-Tu 10/9 - 17/9 (classic Blizz post) 13/9
2020: Tu-Tu 29/9 - 6/10 (retail Blizz post)   1/10
2021: Fr-Fr 17/9 - 24/9 (retail Blizz post)  21/9
]] --

---@class QuestieEvent
---@field public private QuestieEventPrivate
local QuestieEvent = QuestieLoader:CreateModule("QuestieEvent")
---@class QuestieEventPrivate
local _QuestieEvent = QuestieEvent.private

-- QuestieDB states which quests and NPCs belong to which world event, in the signed `eventIds`
-- field: a positive event ID means "only during this event" (any one of several is enough), a
-- negative one "not during this event". This module decides which events are active, because
-- that follows the calendar and changes during a session, and applies the result.

---Event quests of this flavor, read from QuestieDB during Login Initialization. Quests a gate in
---`QuestieQuestBlacklist.LoadEventQuestGates` withholds are left out: they are not event quests here.
---@type table<QuestId, integer[]> Quest ID to its signed event IDs
QuestieEvent.eventQuests = {}

---Ordinary quests that only list "not during" events: they are hidden while such an event runs
---and are not event quests otherwise.
---@type table<QuestId, integer[]> Quest ID to its signed event IDs
QuestieEvent.excludedQuests = {}

---@type table<NpcId, integer[]> NPC ID to its signed event IDs
QuestieEvent.eventNpcs = {}

---@type table<QuestId, boolean>
QuestieEvent.activeQuests = {}
QuestieEvent.calendarDataCached = false

-- Quests available for only part of their event: {start "DD/MM", end "DD/MM"}.
---@type table<QuestId, {[1]: string, [2]: string}>
local questWindows = {
    [8744] = {"25/12", "2/1"}, -- A Carefully Wrapped Present
    [8767] = {"25/12", "2/1"}, -- A Gently Shaken Gift
    [8768] = {"25/12", "2/1"}, -- A Gaily Wrapped Present
    [8769] = {"25/12", "2/1"}, -- A Ticking Present
    [8788] = {"25/12", "2/1"}, -- A Gently Shaken Gift
    [8803] = {"25/12", "2/1"}, -- A Festive Gift
    [8827] = {"25/12", "2/1"}, -- Winter's Presents
    [8828] = {"25/12", "2/1"}, -- Winter's Presents
    [8860] = {"31/12", "1/1"}, -- New Year Celebrations!
    [8861] = {"31/12", "1/1"}, -- New Year Celebrations!
    [11528] = {"25/12", "2/1"}, -- A Winter Veil Gift
    [13203] = {"25/12", "2/1"}, -- A Winter Veil Gift
    [13966] = {"25/12", "2/1"}, -- A Winter Veil Gift
    [29385] = {"25/12", "2/1"}, -- A Winter Veil Gift -- only offered in cata
    [33252] = {"25/12", "2/1"}, -- A Winter Veil Gift
    [79637] = {"25/12", "2/1"}, -- A Ticking Present
}

-- Started by an item that drops all year, so they are never hidden outside the Darkmoon Faire.
---@type table<QuestId, boolean>
local neverHiddenQuests = {
    [7907] = true, [7927] = true, [7928] = true, [7929] = true, -- Classic decks
    [10938] = true, [10939] = true, [10940] = true, [10941] = true, -- TBC decks
    [13324] = true, [13325] = true, [13326] = true, [13327] = true, -- WotLK decks
    [27664] = true, [27665] = true, [27666] = true, [27667] = true, -- Cata decks
    [30449] = true, [30450] = true, [30451] = true, [30452] = true, -- MoP decks
}

local alwaysTurnInAbleQuests = {
    [7937] = true, -- Your Fortune Awaits You...
    [7938] = true, -- Your Fortune Awaits You...
    [7944] = true, -- Your Fortune Awaits You...
    [7945] = true, -- Your Fortune Awaits You...
}

---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieClassicPolicyCorrections
local QuestieClassicPolicyCorrections = QuestieLoader:ImportModule("QuestieClassicPolicyCorrections")
---@type QuestieTBCPolicyCorrections
local QuestieTBCPolicyCorrections = QuestieLoader:ImportModule("QuestieTBCPolicyCorrections")
---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")

local eventKeys = QuestieDB.eventKeys

-- The events this module tracks, by the name its date tables, chat messages and Journey
-- grouping use. QuestieDB also knows events without a calendar, such as the Ahn'Qiraj war
-- effort; quests carrying only those are not event quests here.
---@type table<integer, string>
local eventNameById = {
    [eventKeys.WINTER_VEIL] = "Winter Veil",
    [eventKeys.NOBLEGARDEN] = "Noblegarden",
    [eventKeys.CHILDRENS_WEEK] = "Children's Week",
    [eventKeys.HARVEST_FESTIVAL] = "Harvest Festival",
    [eventKeys.HALLOWS_END] = "Hallow's End",
    [eventKeys.LUNAR_FESTIVAL] = "Lunar Festival",
    [eventKeys.LOVE_IS_IN_THE_AIR] = "Love is in the Air",
    [eventKeys.MIDSUMMER] = "Midsummer",
    [eventKeys.BREWFEST] = "Brewfest",
    [eventKeys.PIRATES_DAY] = "Pirates' Day",
    [eventKeys.PILGRIMS_BOUNTY] = "Pilgrim's Bounty",
    [eventKeys.DAY_OF_THE_DEAD] = "Day of the Dead",
    [eventKeys.DARKMOON_FAIRE_ELWYNN] = "Darkmoon Faire",
    [eventKeys.DARKMOON_FAIRE_MULGORE] = "Darkmoon Faire",
    [eventKeys.DARKMOON_FAIRE_TEROKKAR] = "Darkmoon Faire",
    [eventKeys.DARKMOON_FAIRE_ISLAND] = "Darkmoon Faire",
}

-- The reverse for the date-driven events. The Darkmoon Faire is left out: its event ID depends
-- on where the faire is, not on a date window.
---@type table<string, integer>
local eventIdByName = {}
for eventId, eventName in pairs(eventNameById) do
    if eventName ~= "Darkmoon Faire" then
        eventIdByName[eventName] = eventId
    end
end

local _WithinDates, _LoadDarkmoonFaire, _GetDarkmoonFaireLocation, _GetDarkmoonFaireLocationEra, _GetDarkmoonFaireLocationSoD, _GetDarkmoonFaireLocationTBC, _GetDarkmoonFaireLocationWotlK, _IsDarkmoonFaireWeek, _GetLunarFestivalDates
local _TracksAnyEvent, _RequiresEvent, _IsAvailable, _CollectEventEntities

---@enum DMFLocation
local DMF_LOCATIONS = {
    NONE = 0,
    MULGORE = 1,
    ELWYNN_FOREST = 2,
    TEROKKAR_FOREST = 3,
}

local DMF_LOCATION_NAMES = {
    [1] = "Mulgore",
    [2] = "Elwynn Forest",
    [3] = "Terokkar Forest",
}

-- Before Cataclysm the faire's event ID says where it is, so a quest can list the locations it appears for.
---@type table<DMFLocation, integer>
local DMF_EVENT_ID_BY_LOCATION = {
    [DMF_LOCATIONS.MULGORE] = eventKeys.DARKMOON_FAIRE_MULGORE,
    [DMF_LOCATIONS.ELWYNN_FOREST] = eventKeys.DARKMOON_FAIRE_ELWYNN,
    [DMF_LOCATIONS.TEROKKAR_FOREST] = eventKeys.DARKMOON_FAIRE_TEROKKAR,
}

-- The ingame calender adds a texture to the DMF event.
-- We use this to identify the event without relying on dates or localized event titles.
local DMF_CALENDAR_ICON_TEXTURES = {
    [235446] = true, -- End Texture
    [235447] = true, -- Ongoing Texture
    [235448] = true, -- Start Texture
}

-- DMF starts on the first Monday after the first full weekend in Era + TBC
-- Forever also uses this exact timeframe and location rotation
local DMF_START_DAY_BY_FIRST_WEEKDAY_ERA_TBC = {
    [1] = 9,  -- 1st is a Sunday -> Monday is 9th
    [2] = 8,  -- 1st is a Monday -> Monday is 8th
    [3] = 7,  -- 1st is a Tuesday -> Monday is 7th
    [4] = 6,  -- 1st is a Wednesday -> Monday is 6th
    [5] = 5,  -- 1st is a Thursday -> Monday is 5th
    [6] = 4,  -- 1st is a Friday -> Monday is 4th
    [7] = 10, -- 1st is a Saturday -> Monday is 10th
}

-- DMF starts on the first Sunday of the month in Wotlk
local DMF_START_DAY_BY_FIRST_WEEKDAY_WOTLK = {
    [1] = 1,  -- 1st is a Sunday -> Sunday is 1st
    [2] = 7,  -- 1st is a Monday -> Sunday is 7th
    [3] = 6,  -- 1st is a Tuesday -> Sunday is 6th
    [4] = 5,  -- 1st is a Wednesday -> Sunday is 5th
    [5] = 4,  -- 1st is a Thursday -> Sunday is 4th
    [6] = 3,  -- 1st is a Friday -> Sunday is 3rd
    [7] = 2, -- 1st is a Saturday -> Sunday is 2nd
}
-- Determine the DMF start day for the month based on what weekday the 1st is.
local function dmfStartDayByFirstWeekday(firstWeekday)
    if Expansions.Current < Expansions.Wotlk and not Questie.IsSoD then
        return DMF_START_DAY_BY_FIRST_WEEKDAY_ERA_TBC[firstWeekday]
    else
        return DMF_START_DAY_BY_FIRST_WEEKDAY_WOTLK[firstWeekday]
    end
end

---@param eventIds integer[]
---@return boolean @True if the list names an event this module tracks, with either sign
_TracksAnyEvent = function(eventIds)
    for i = 1, #eventIds do
        local eventId = eventIds[i]
        if eventNameById[eventId] or eventNameById[-eventId] then
            return true
        end
    end
    return false
end

---@param eventIds integer[]
---@return boolean @True if the list names an "only during" event this module tracks
_RequiresEvent = function(eventIds)
    for i = 1, #eventIds do
        if eventNameById[eventIds[i]] then
            return true
        end
    end
    return false
end

---Applies QuestieDB's membership rule to the events that are active right now.
---@param eventIds integer[] Signed event IDs of one quest or NPC
---@param activeEventIds table<integer, boolean>
---@return boolean @True if no listed "not during" event is active and, when "only during" events are listed, one of them is
_IsAvailable = function(eventIds, activeEventIds)
    local needsEvent, hasEvent = false, false
    for i = 1, #eventIds do
        local eventId = eventIds[i]
        if eventId < 0 then
            if activeEventIds[-eventId] then
                return false
            end
        elseif eventNameById[eventId] then
            needsEvent = true
            if activeEventIds[eventId] then
                hasEvent = true
            end
        end
    end
    return hasEvent or (not needsEvent)
end

---Reads event membership from QuestieDB and hides every event quest until `Load` finds its
---event active. Runs inside the Login Initialization coroutine and yields between chunks.
_CollectEventEntities = function()
    local eventQuests, excludedQuests, eventNpcs = {}, {}, {}
    local gates = QuestieQuestBlacklist.LoadEventQuestGates()
    local hiddenQuests = QuestieCorrections.hiddenQuests

    local count = 0
    for questId in pairs(QuestieDB.QuestPointers) do
        local eventIds = QuestieDB.QueryQuestSingle(questId, "eventIds")
        if eventIds and (not gates[questId]) and _TracksAnyEvent(eventIds) then
            if _RequiresEvent(eventIds) then
                eventQuests[questId] = eventIds
                if not neverHiddenQuests[questId] then
                    hiddenQuests[questId] = true
                end
            else
                excludedQuests[questId] = eventIds
            end
        end
        if count > 700 then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    count = 0
    for npcId in pairs(QuestieDB.NPCPointers) do
        local eventIds = QuestieDB.QueryNPCSingle(npcId, "eventIds")
        if eventIds and _TracksAnyEvent(eventIds) then
            eventNpcs[npcId] = eventIds
        end
        if count > 700 then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    QuestieEvent.eventQuests = eventQuests
    QuestieEvent.excludedQuests = excludedQuests
    QuestieEvent.eventNpcs = eventNpcs
end

function QuestieEvent.Initialize()
    _CollectEventEntities()

    Questie:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST", function()
        QuestieEvent:Load()
        Questie:UnregisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    end)

    -- According to the docs, OpenCalendar queries the server to force a CALENDAR_UPDATE_EVENT_LIST update.
    -- In reality SetMonth is the reliable one. So we simply call both.
    C_Calendar.OpenCalendar()
    C_Calendar.SetMonth(0)
end

function QuestieEvent:Load()
    local year = date("%y")
    local lunarData = _GetLunarFestivalDates(year)

    if lunarData then
        QuestieEvent.eventDates["Lunar Festival"] = lunarData
    end

    local activeEvents = {}

    local eventCorrections
    if Expansions.Current == Expansions.Tbc then
        eventCorrections = QuestieEvent.eventDateCorrections["TBC"]
    elseif Expansions.Current == Expansions.Era then
        eventCorrections = QuestieEvent.eventDateCorrections["CLASSIC"]
    else
        eventCorrections = {}
    end

    for eventName, dates in pairs(eventCorrections) do
        if dates then
            QuestieEvent.eventDates[eventName] = dates
        end
    end

    for eventName, eventData in pairs(QuestieEvent.eventDates) do
        local startDay, startMonth = strsplit("/", eventData.startDate)
        local endDay, endMonth = strsplit("/", eventData.endDate)
        local startHour, startMinute, endHour, endMinute

        startDay = tonumber(startDay)
        startMonth = tonumber(startMonth)
        startHour = eventData.startHour
        startMinute = eventData.startMinute
        endDay = tonumber(endDay)
        endMonth = tonumber(endMonth)
        endHour = eventData.endHour
        endMinute = eventData.endMinute

        if _WithinDates(startDay, startMonth, startHour, startMinute, endDay, endMonth, endHour, endMinute) and (eventCorrections[eventName] ~= false) then
            if Questie.db.profile.showEventQuests then
                print(Questie:Colorize("[Questie]"), "|cFF6ce314" .. l10n("The \"%s\" world event is active!", l10n(eventName)))
            end
            activeEvents[eventName] = true
        end
    end

    -- Store the current setting to restore later
    local shouldShowDmfEvents = GetCVarBool("calendarShowDarkmoon")
    SetCVar("calendarShowDarkmoon", "1")

    local dmfIsActive = false
    if Expansions.Current >= Expansions.MoP then
        local currentDate = QuestieCompat.GetCurrentCalendarTime()
        local numDayEvents = C_Calendar.GetNumDayEvents(0, currentDate.monthDay)

        for i = 1, numDayEvents do
            local event = C_Calendar.GetHolidayInfo(0, currentDate.monthDay, i)
            if event and DMF_CALENDAR_ICON_TEXTURES[event.texture] then
                dmfIsActive = true
                break
            end
        end
    end

    if dmfIsActive then
        if Questie.db.profile.showEventQuests then
            print(Questie:Colorize("[Questie]"), "|cFF6ce314" .. l10n("The \"%s\" world event is active!", l10n("Darkmoon Faire")))
        end
    end

    SetCVar("calendarShowDarkmoon", shouldShowDmfEvents and "1" or "0")


    local dmfAvailable = (Expansions.Current == Expansions.Era and (((not Questie.IsAnniversaryEra) and (not Questie.IsAnniversaryHardcore)) or (ContentPhases.activePhases.Anniversary >= 3)))
            or Questie.IsTBC or Questie.IsWotlk

    local dmfLocation = DMF_LOCATIONS.NONE
    if dmfAvailable then
        dmfLocation = _GetDarkmoonFaireLocation()
        _LoadDarkmoonFaire(dmfLocation)
    end

    -- The events active right now, as the IDs QuestieDB's `eventIds` lists use.
    ---@type table<integer, boolean>
    local activeEventIds = {}
    for eventName in pairs(activeEvents) do
        activeEventIds[eventIdByName[eventName]] = true
    end
    if dmfIsActive then
        activeEventIds[eventKeys.DARKMOON_FAIRE_ISLAND] = true
    end
    if dmfLocation ~= DMF_LOCATIONS.NONE then
        activeEventIds[DMF_EVENT_ID_BY_LOCATION[dmfLocation]] = true
    end

    -- Reveal the quests whose event is active. Every other event quest stays hidden, as
    -- `_CollectEventEntities` left it.
    for questId, eventIds in pairs(QuestieEvent.eventQuests) do
        local startDay, startMonth, endDay, endMonth
        local window = questWindows[questId]
        if window then
            startDay, startMonth = strsplit("/", window[1])
            endDay, endMonth = strsplit("/", window[2])
            startDay, startMonth = tonumber(startDay), tonumber(startMonth)
            endDay, endMonth = tonumber(endDay), tonumber(endMonth)
        end

        if _IsAvailable(eventIds, activeEventIds) and _WithinDates(startDay, startMonth, nil, nil, endDay, endMonth, nil, nil) then
            QuestieCorrections.hiddenQuests[questId] = nil
            QuestieEvent.activeQuests[questId] = true
        end
    end

    -- Hide the ordinary quests an active event makes unavailable.
    for questId, eventIds in pairs(QuestieEvent.excludedQuests) do
        if not _IsAvailable(eventIds, activeEventIds) then
            QuestieCorrections.hiddenQuests[questId] = true
        end
    end

    -- Hide event-only NPCs outside their event.
    for npcId, eventIds in pairs(QuestieEvent.eventNpcs) do
        QuestieCorrections.questNPCBlacklist[npcId] = not _IsAvailable(eventIds, activeEventIds)
    end
end

---@param year string
---@return QuestieEventDateRange|nil
_GetLunarFestivalDates = function(year)
    if Questie.IsTitanReforged and QuestieEvent.lunarFestival.TITAN[year] then
        return QuestieEvent.lunarFestival.TITAN[year]
    end

    return QuestieEvent.lunarFestival.DEFAULT[year]
end

---@return DMFLocation
_GetDarkmoonFaireLocation = function()
    if C_Calendar == nil then
        -- This is a band aid fix for private servers which do not support the `C_Calendar` API.
        -- They won't see Darkmoon Faire quests, but that's the price to pay.
        return DMF_LOCATIONS.NONE
    end

    local currentDate = QuestieCompat.GetCurrentCalendarTime()

    if Questie.IsSoD then
        return _GetDarkmoonFaireLocationSoD(currentDate)
    elseif Questie.IsTBC then
        return _GetDarkmoonFaireLocationTBC(currentDate)
    elseif Questie.IsWotlk then
        return _GetDarkmoonFaireLocationWotlK(currentDate)
    else
        return _GetDarkmoonFaireLocationEra(currentDate)
    end
end

---@param currentDate CalendarTime
---@return DMFLocation
_GetDarkmoonFaireLocationEra = function(currentDate)
    if (not _IsDarkmoonFaireWeek(currentDate)) then
        return DMF_LOCATIONS.NONE
    end

    local remainder = currentDate.month % 2
    if remainder == 1 then
        return DMF_LOCATIONS.ELWYNN_FOREST
    end
    return DMF_LOCATIONS.MULGORE
end

--- DMF in TBC rotates monthly through three locations: Mulgore, Terokkar Forest, and Elwynn Forest.
--- The timing follows the same Monday-start, 7-day schedule as Classic Era.
---@param currentDate CalendarTime
---@return DMFLocation
_GetDarkmoonFaireLocationTBC = function(currentDate)
    if (not _IsDarkmoonFaireWeek(currentDate)) then
        return DMF_LOCATIONS.NONE
    end

    local remainder = currentDate.month % 3
    if remainder == 1 then
        return DMF_LOCATIONS.MULGORE
    elseif remainder == 2 then
        return DMF_LOCATIONS.ELWYNN_FOREST
    end
    return DMF_LOCATIONS.TEROKKAR_FOREST
end

--- DMF in WotlK rotates monthly through three locations: Mulgore, Terokkar Forest, and Elwynn Forest.
--- Event starts after midnight on Sunday, and ends right before midnight on Saturday.
--- Order is different from Era/TBC.
---@param currentDate CalendarTime
---@return DMFLocation
_GetDarkmoonFaireLocationWotlK = function(currentDate)
    if (not _IsDarkmoonFaireWeek(currentDate)) then
        return DMF_LOCATIONS.NONE
    end

    local remainder = currentDate.month % 3
    if remainder == 1 then
        return DMF_LOCATIONS.TEROKKAR_FOREST
    elseif remainder == 2 then
        return DMF_LOCATIONS.ELWYNN_FOREST
    end
    return DMF_LOCATIONS.MULGORE
end

---@param currentDate CalendarTime
---@return boolean
_IsDarkmoonFaireWeek = function(currentDate)
    local baseInfo = C_Calendar.GetMonthInfo()
    -- Calculate the offset in months from baseInfo to make C_Calendar.GetMonthInfo return the correct month
    local monthOffset = (currentDate.year - baseInfo.year) * 12 + (currentDate.month - baseInfo.month)
    local firstWeekday = C_Calendar.GetMonthInfo(monthOffset).firstWeekday

    -- For Era and TBC the event is from Monday 04:00 to next Monday 04:00
    -- For Wotlk the event is from Sunday 0:01 to Saturday 23:59
    -- For SoD the event is from Monday 0:01 to Sunday 23:59
    local eventDuration = Expansions.Current < Expansions.Wotlk and 7 or 6
    local dmfStartTime = Expansions.Current < Expansions.Wotlk and 400 or 1
    local dmfEndTime = Expansions.Current < Expansions.Wotlk and 400 or 2359
    local startDay = dmfStartDayByFirstWeekday(firstWeekday)
    local endDay = startDay + eventDuration
    local dayOfMonth = currentDate.monthDay
    local currentTimeFormatted = currentDate.hour * 100 + currentDate.minute

    -- If we're on the first day check if it started already
    if dayOfMonth == startDay and currentTimeFormatted < dmfStartTime then
        return false
    end

    -- Check if the event is already finished on the final day
    if dayOfMonth == endDay and currentTimeFormatted >= dmfEndTime then
        return false
    end

    -- Check if we're inbetween first day and final day
    return dayOfMonth >= startDay and dayOfMonth <= endDay
end

-- DMF in SoD is every second week, starting on the 4th of December 2023
---@param currentDate CalendarTime
---@return DMFLocation
_GetDarkmoonFaireLocationSoD = function(currentDate)
    local initialStartDate = time({year = 2023, month = 12, day = 4, hour = 0, min = 1}) -- The first time DMF started in SoD
    local initialEndDate = time({year = 2023, month = 12, day = 10, hour = 23, min = 59}) -- The first time DMF ended in SoD
    local currentDateTimestamp = time({year = currentDate.year, month = currentDate.month, day = currentDate.monthDay, hour = currentDate.hour, min = currentDate.minute})

    local eventDuration = initialEndDate - initialStartDate
    local timeSinceStart = currentDateTimestamp - initialStartDate

    local positionInCurrentCycle = timeSinceStart % ((eventDuration + 120) * 2) -- * 2 because the event repeats every two weeks

    local isEventActive = positionInCurrentCycle < eventDuration

    if (not isEventActive) then
        return DMF_LOCATIONS.NONE
    end

    local weeksSinceStart = math.floor(timeSinceStart / (eventDuration + 120))

    if weeksSinceStart % 4 == 0 then
        return DMF_LOCATIONS.MULGORE
    else
        return DMF_LOCATIONS.ELWYNN_FOREST
    end
end

--- https://classic.wowhead.com/guides/classic-darkmoon-faire#darkmoon-faire-location-and-schedule
--- Darkmoon Faire starts its setup the first Friday of the month and will begin the following Monday.
--- The faire ends the sunday after it has begun.
_LoadDarkmoonFaire = function(eventLocation)
    if eventLocation == DMF_LOCATIONS.NONE then
        -- nil withdraws the slot; an inactive faire must not keep stale NPC coordinates.
        QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", nil)
        return
    end

    local isInMulgore = eventLocation == DMF_LOCATIONS.MULGORE
    local isInTerokkar = eventLocation == DMF_LOCATIONS.TEROKKAR_FOREST

    -- The NPC Policy Correction slot is written exactly once per load. Which quests the location
    -- reveals follows from their `eventIds` in `Load`.
    if Questie.IsTBC or Questie.IsWotlk then
        QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", QuestieTBCPolicyCorrections:LoadDarkmoonFixes(isInMulgore, isInTerokkar))
    else
        QuestieCorrections.SetCorrection("Npc", "DarkmoonFaire", QuestieClassicPolicyCorrections:LoadDarkmoonFixes(isInMulgore))
    end

    if Questie.db.profile.showEventQuests then
        print(Questie:Colorize("[Questie]"), "|cFF6ce314" .. l10n("The Darkmoon Faire is up in %s!", l10n(DMF_LOCATION_NAMES[eventLocation])))
    end
end

--- Checks wheather the current date is within the given date range
---@param startDay number?
---@param startMonth number?
---@param endDay number?
---@param endMonth number?
---@return boolean @True if the current date is between the given, false otherwise
_WithinDates = function(startDay, startMonth, startHour, startMinute, endDay, endMonth, endHour, endMinute)
    -- there are corrections that are missing the HH:MM entries (unknown), but we still want to show those correctly
    if (not startDay) and (not startMonth) and (not endMonth) and (not endDay) then
        return true
    end
    local date = QuestieCompat.GetCurrentCalendarTime()
    local minute = date.minute
    local hour = date.hour
    local day = date.monthDay
    local month = date.month

    -- For missing HH:MM entries we default to 00:00 start HH:MM, and 23:59 end HH:MM
    startHour = startHour or 0
    startMinute = startMinute or 0
    endHour = endHour or 23
    endMinute = endMinute or 59

    -- Convert each date into a sortable value: MMDDHHMM
    local current = month * 1000000 + day * 10000 + hour * 100 + minute
    local start = startMonth * 1000000 + startDay * 10000 + startHour * 100 + startMinute
    local finish = endMonth * 1000000 + endDay * 10000 + endHour * 100 + endMinute

    if start <= finish then
        -- Normal interval (e.g. Mar 10 -> Jul 5)
        return current >= start and current <= finish
    else
        -- Crosses New Year (e.g. Dec 20 -> Jan 10)
        return current >= start or current <= finish
    end
end

---@param questId QuestId
---@return string
function QuestieEvent.GetEventNameFor(questId)
    local eventIds = QuestieEvent.eventQuests[questId]
    if eventIds then
        for i = 1, #eventIds do
            local eventName = eventNameById[eventIds[i]]
            if eventName then
                return eventName
            end
        end
    end
    return ""
end

---@param questId QuestId
---@return boolean @True if the quest is part of an event, false otherwise
function QuestieEvent.IsEventQuest(questId)
    return QuestieEvent.eventQuests[questId] ~= nil
end

---@param questId QuestId
---@return boolean @True if the quest is part of an event and the event is currently active, false otherwise
function QuestieEvent.IsEventActiveForQuest(questId)
    return QuestieEvent.activeQuests[questId] == true
end

---@param questId QuestId
---@return boolean @True if the quest can be turned in outside of the event, false otherwise
function QuestieEvent.CanQuestBeTurnedInOutsideOfEvent(questId)
    return alwaysTurnInAbleQuests[questId] == true
end

-- EUROPEAN FORMAT! NO FUCKING AMERICAN SHIDAZZLE FORMAT!
QuestieEvent.eventDates = {
    ["Winter Veil"] =
        not Questie.IsTitanReforged and { -- regular servers
            startDate = "15/12",
            startHour = 10,
            startMinute = 0,
            endDate = "2/1",
            endHour = 10,
            endMinute = 0,
        } or { -- Titan servers
        startDate = "15/12",
        startHour = 6,
        startMinute = 0,
        endDate = "2/1",
        endHour = 6,
        endMinute = 0,
    },
    ["Love is in the Air"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "9/2",
        startHour = 10,
        startMinute = 0,
        endDate = "23/2",
        endHour = 10,
        endMinute = 0,
    },
    ["Noblegarden"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "5/4",
        startHour = 0,
        startMinute = 1,
        endDate = "11/4",
        endHour = 23,
        endMinute = 59,
    },
    ["Children's Week"] = { -- TODO: Usually it is only a week long
        startDate = "27/4",
        startHour = 10,
        startMinute = 0,
        endDate = "4/5",
        endHour = 10,
        endMinute = 0,
    },
    ["Midsummer"] =
        -- Fixed calendar days: 21 Jun 4 AM - 4 Jul 4 AM
        not Questie.IsTitanReforged and { -- regular servers
            startDate = "21/6",
            startHour = 4,
            startMinute = 0,
            endDate = "5/7",
            endHour = 4,
            endMinute = 0,
        } or { -- Titan servers
        startDate = "28/6",
        startHour = 4,
        startMinute = 0,
        endDate = "12/7",
        endHour = 4,
        endMinute = 0,
    },
    ["Pirates' Day"] = { -- no quests associated with it, but listed here to have a reminder in chat
        startDate = "19/9",
        startHour = 10,
        startMinute = 0,
        endDate = "20/9",
        endHour = 10,
        endMinute = 0,
    },
    ["Brewfest"] =
    -- TODO: This might be different (retail date)
    not Questie.IsTitanReforged and { -- regular servers
            startDate = "20/9",
            startHour = 10,
            startMinute = 0,
            endDate = "6/10",
            endHour = 10,
            endMinute = 0,
        } or { -- Titan servers
        startDate = "20/9",
        startHour = 0,
        startMinute = 1,
        endDate = "5/10",
        endHour = 23,
        endMinute = 59,
    },
    ["Harvest Festival"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "21/9",
        startHour = 0,
        startMinute = 1,
        endDate = "27/9",
        endHour = 23,
        endMinute = 59,
    },
    ["Hallow's End"] =  -- WARNING THIS DATE VARIES!!!!
        not Questie.IsTitanReforged and { -- regular servers
            startDate = "18/10",
            startHour = 10,
            startMinute = 0,
            endDate = "1/11",
            endHour = 11,
            endMinute = 0,
        } or { -- Titan servers
        startDate = "18/10",
        startHour = 1,
        startMinute = 0,
        endDate = "31/10",
        endHour = 23,
        endMinute = 59,
    },
    ["Day of the Dead"] = {
        startDate = "1/11",
        startHour = 10,
        startMinute = 0,
        endDate = "3/11",
        endHour = 10,
        endMinute = 0,
    },
    ["Pilgrim's Bounty"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "24/11",
        startHour = 1,
        startMinute = 0,
        endDate = "30/11",
        endHour = 23,
        endMinute = 59,
    },
}

-- ["EventName"] = false -> event doesn't exists in expansion
-- ["EventName"] = {startDate = "12/3", endDate = "12/3"} -> change dates for the expansion
QuestieEvent.eventDateCorrections = {
    ["CLASSIC"] = {
        ["Brewfest"] = false,
        ["Pilgrim's Bounty"] = false,
        ["Pirates' Day"] = false,
        ["Day of the Dead"] = false,
        ["Noblegarden"] = { -- WARNING THIS DATE VARIES!!!! -- One day event, on the actual day of Easter.
            -- Date is set for 2027. Please update this every year.
            startDate = "28/3",
            startHour = 0,
            startMinute = 1,
            endDate = "28/3",
            endHour = 23,
            endMinute = 59
        },
        ["Love is in the Air"] = { -- WARNING THIS DATE VARIES!!!!
            startDate = "11/2",
            startHour = 10,
            startMinute = 0,
            endDate = "15/2",
            endHour = 10,
            endMinute = 0
        },
        ["Hallow's End"] = { -- WARNING THIS DATE VARIES!!!!
            startDate = "18/10",
            startHour = 4, -- was active at 05:35 ingame, assuming 4 is start hour
            startMinute = 0,
            endDate = "1/11",
            endHour = 23,
            endMinute = 59,
        },
    },
    ["TBC"] = {
        ["Day of the Dead"] = false,
        ["Noblegarden"] = { -- WARNING THIS DATE VARIES!!!! -- One day event, on the actual day of Easter.
            -- Date is set for 2027. Please update this every year.
            startDate = "28/3",
            startHour = 0,
            startMinute = 1,
            endDate = "28/3",
            endHour = 23,
            endMinute = 59
        },
        ["Love is in the Air"] = { -- WARNING THIS DATE VARIES!!!!
            startDate = "11/2",
            startHour = 10,
            startMinute = 0,
            endDate = "15/2",
            endHour = 10,
            endMinute = 0
        },
        ["Pirates' Day"] = {
            startDate = "19/9",
            startHour = 0,
            startMinute = 0,
            endDate = "20/9",
            endHour = 0,
            endMinute = 0,
        },
        ["Brewfest"] = {
            startDate = "20/9",
            startHour = 0,
            startMinute = 1,
            endDate = "5/10",
            endHour = 23,
            endMinute = 59,
        },
        ["Hallow's End"] = {
            startDate = "18/10",
            startHour = 4,
            startMinute = 0,
            endDate = "1/11",
            endHour = 23,
            endMinute = 59,
        },
        ["Winter Veil"] = {
            startDate = "15/12",
            startHour = 6,
            startMinute = 0,
            endDate = "2/1",
            endHour = 6,
            endMinute = 0,
        },
    },
}

---@class QuestieEventDateRange
---@field startDate string
---@field endDate string

---@class QuestieLunarFestivalTable
---@field DEFAULT table<string, QuestieEventDateRange>
---@field TITAN table<string, QuestieEventDateRange>
QuestieEvent.lunarFestival = {
    DEFAULT = { -- Global default (US/EU, etc.)
        ["19"] = {startDate = "5/2", startHour = 6, startMinute = 0, endDate = "19/2", endHour = 6, endMinute = 0},
        ["20"] = {startDate = "23/1", startHour = 6, startMinute = 0,  endDate = "10/2", endHour = 6, endMinute = 0},
        ["21"] = {startDate = "5/2", startHour = 6, startMinute = 0,  endDate = "19/2", endHour = 6, endMinute = 0},
        ["22"] = {startDate = "30/1", startHour = 6, startMinute = 0,  endDate = "18/2", endHour = 6, endMinute = 0},
        ["23"] = {startDate = "20/1", startHour = 6, startMinute = 0,  endDate = "10/2", endHour = 6, endMinute = 0},
        ["24"] = {startDate = "3/2", startHour = 6, startMinute = 0,  endDate = "23/2", endHour = 6, endMinute = 0},
        ["25"] = {startDate = "28/1", startHour = 6, startMinute = 0,  endDate = "17/2", endHour = 6, endMinute = 0},
        ["26"] = {startDate = "16/2", startHour = 6, startMinute = 0,  endDate = "9/3", endHour = 6, endMinute = 0},
        ["27"] = {startDate = "5/2", startHour = 6, startMinute = 0,  endDate = "19/2", endHour = 6, endMinute = 0},
        ["28"] = {startDate = "24/1", startHour = 6, startMinute = 0,  endDate = "14/2", endHour = 6, endMinute = 0},
    },
    TITAN = { -- Chinese Titan Reforged
        ["26"] = {startDate = "29/1", startHour = 6, startMinute = 0,  endDate = "25/2", endHour = 6, endMinute = 0},
        ["27"] = {startDate = "5/2", startHour = 6, startMinute = 0,  endDate = "19/2", endHour = 6, endMinute = 0},
        ["28"] = {startDate = "24/1", startHour = 6, startMinute = 0,  endDate = "14/2", endHour = 6, endMinute = 0},
    }
}