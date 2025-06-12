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

-- This variable will be cleared at the end of the load, do not use, use QuestieEvent.activeQuests.
QuestieEvent.eventQuests = {}
QuestieEvent.activeQuests = {}
_QuestieEvent.eventNamesForQuests = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")
---@type QuestieNPCFixes
local QuestieNPCFixes = QuestieLoader:ImportModule("QuestieNPCFixes")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local _WithinDates, _LoadDarkmoonFaire, _GetDarkmoonFaireLocation, _GetDarkmoonFaireLocationEra, _GetDarkmoonFaireLocationSoD

local DMF_LOCATIONS = {
    NONE = 0,
    MULGORE = 1,
    ELWYNN_FOREST = 2,
}

function QuestieEvent:Load()
    local year = date("%y")

    -- We want to replace the Lunar Festival date with the date that we estimate
    QuestieEvent.eventDates["Lunar Festival"] = QuestieEvent.lunarFestival[year]
    local activeEvents = {}

    local eventCorrections
    if Questie.IsTBC then
        eventCorrections = QuestieEvent.eventDateCorrections["TBC"]
    elseif Questie.IsClassic then
        eventCorrections = QuestieEvent.eventDateCorrections["CLASSIC"]
    else
        eventCorrections = {}
    end

    for eventName,dates in pairs(eventCorrections) do
        if dates then
            QuestieEvent.eventDates[eventName] = dates
        end
    end

    for eventName, eventData in pairs(QuestieEvent.eventDates) do
        local startDay, startMonth = strsplit("/", eventData.startDate)
        local endDay, endMonth = strsplit("/", eventData.endDate)

        startDay = tonumber(startDay)
        startMonth = tonumber(startMonth)
        endDay = tonumber(endDay)
        endMonth = tonumber(endMonth)

        if _WithinDates(startDay, startMonth, endDay, endMonth) and (eventCorrections[eventName] ~= false) then
            print(Questie:Colorize("[Questie]"), "|cFF6ce314" .. l10n("The '%s' world event is active!", l10n(eventName)))
            activeEvents[eventName] = true
        end
    end

    for _, questData in pairs(QuestieEvent.eventQuests) do
        local eventName = questData[1]
        local questId = questData[2]
        local startDay, startMonth = nil, nil
        local endDay, endMonth = nil, nil

        if questData[3] and questData[4] then
            startDay, startMonth = strsplit("/", questData[3])
            endDay, endMonth = strsplit("/", questData[4])
            startDay = tonumber(startDay)
            startMonth = tonumber(startMonth)
            endDay = tonumber(endDay)
            endMonth = tonumber(endMonth)
        end

        _QuestieEvent.eventNamesForQuests[questId] = eventName

        if activeEvents[eventName] == true and _WithinDates(startDay, startMonth, endDay, endMonth) then
            local hideQuest = questData[5]
            if (not hideQuest) then
                QuestieCorrections.hiddenQuests[questId] = nil
                QuestieEvent.activeQuests[questId] = true
            end
        end
    end

    -- TODO: Also handle WotLK which has a different starting schedule
    if Questie.IsClassic and (((not Questie.IsAnniversary) and (not Questie.IsAnniversaryHardcore)) or (ContentPhases.activePhases.Anniversary >= 3)) then
        _LoadDarkmoonFaire()
    end

    -- Clear the quests to save memory
    QuestieEvent.eventQuests = nil
end

---@return boolean
_GetDarkmoonFaireLocation = function()
    if C_Calendar == nil then
        -- This is a band aid fix for private servers which do not support the `C_Calendar` API.
        -- They won't see Darkmoon Faire quests, but that's the price to pay.
        return false
    end

    local currentDate = C_DateAndTime.GetCurrentCalendarTime()

    if Questie.IsSoD then
        return _GetDarkmoonFaireLocationSoD(currentDate)
    else
        return _GetDarkmoonFaireLocationEra(currentDate)
    end
end

_GetDarkmoonFaireLocationEra = function(currentDate)
    local baseInfo = C_Calendar.GetMonthInfo() -- In Era+SoD this returns `GetMinDate` (November 2004)
    -- Calculate the offset in months from GetMinDate to make C_Calendar.GetMonthInfo return the correct month
    local monthOffset = (currentDate.year - baseInfo.year) * 12 + (currentDate.month - baseInfo.month)
    local firstWeekday = C_Calendar.GetMonthInfo(monthOffset).firstWeekday

    local eventLocation = (currentDate.month % 2) == 0 and DMF_LOCATIONS.MULGORE or DMF_LOCATIONS.ELWYNN_FOREST

    local dayOfMonth = currentDate.monthDay
    if firstWeekday == 1 then
        -- The 1st is a Sunday
        if dayOfMonth >= 9 and dayOfMonth < 15 then
            return eventLocation
        end
    elseif firstWeekday == 2 then
        -- The 1st is a Monday
        if dayOfMonth >= 8 and dayOfMonth < 14 then
            return eventLocation
        end
    elseif firstWeekday == 3 then
        -- The 1st is a Tuesday
        if dayOfMonth >= 7 and dayOfMonth < 13 then
            return eventLocation
        end
    elseif firstWeekday == 4 then
        -- The 1st is a Wednesday
        if dayOfMonth >= 6 and dayOfMonth < 12 then
            return eventLocation
        end
    elseif firstWeekday == 5 then
        -- The 1st is a Thursday
        if dayOfMonth >= 5 and dayOfMonth < 11 then
            return eventLocation
        end
    elseif firstWeekday == 6 then
        -- The 1st is a Friday
        if dayOfMonth >= 4 and dayOfMonth < 10 then
            return eventLocation
        end
    elseif firstWeekday == 7 then
        -- The 1st is a Saturday
        if dayOfMonth >= 10 and dayOfMonth < 16 then
            return eventLocation
        end
    end

    return DMF_LOCATIONS.NONE
end

-- DMF in SoD is every second week, starting on the 4th of December 2023
_GetDarkmoonFaireLocationSoD = function(currentDate)
    local initialStartDate = time({year=2023, month=12, day=4, hour=0, min=1}) -- The first time DMF started in SoD
    local initialEndDate = time({year=2023, month=12, day=10, hour=23, min=59}) -- The first time DMF ended in SoD
    currentDate = time({ year = currentDate.year, month = currentDate.month, day = currentDate.monthDay, hour = 0, min = 1 })

    local eventDuration = initialEndDate - initialStartDate
    local timeSinceStart = currentDate - initialStartDate

    local positionInCurrentCycle = timeSinceStart % (eventDuration * 2) -- * 2 because the event repeats every two weeks

    local isEventActive = positionInCurrentCycle < eventDuration

    if (not isEventActive) then
        return DMF_LOCATIONS.NONE
    end

    local weeksSinceStart = math.floor(timeSinceStart / eventDuration)

    if weeksSinceStart % 4 == 0 then
        return DMF_LOCATIONS.MULGORE
    else
        return DMF_LOCATIONS.ELWYNN_FOREST
    end
end

--- https://classic.wowhead.com/guides/classic-darkmoon-faire#darkmoon-faire-location-and-schedule
--- Darkmoon Faire starts its setup the first Friday of the month and will begin the following Monday.
--- The faire ends the sunday after it has begun.
_LoadDarkmoonFaire = function()
    local eventLocation = _GetDarkmoonFaireLocation()
    if (eventLocation == DMF_LOCATIONS.NONE) then
        return
    end

    -- TODO: Also handle Terrokar Forest starting with TBC
    local isInMulgore = eventLocation == DMF_LOCATIONS.MULGORE

    -- The faire is setting up right now or is already up
    local announcingQuestId = 7905 -- Alliance announcement quest
    if isInMulgore then
        announcingQuestId = 7926 -- Horde announcement quest
    end
    QuestieCorrections.hiddenQuests[announcingQuestId] = nil
    QuestieEvent.activeQuests[announcingQuestId] = true

    for _, questData in pairs(QuestieEvent.eventQuests) do
        local hideQuest = questData[5]
        if questData[1] == "Darkmoon Faire" and (not hideQuest) then
            local questId = questData[2]
            QuestieCorrections.hiddenQuests[questId] = nil
            QuestieEvent.activeQuests[questId] = true

            -- Update the NPC spawns based on the place of the faire
            for id, data in pairs(QuestieNPCFixes:LoadDarkmoonFixes(isInMulgore)) do
                QuestieDB.npcDataOverrides[id] = data
            end
        end
    end

    print(Questie:Colorize("[Questie]"), "|cFF6ce314" .. l10n("The '%s' world event is active!", l10n("Darkmoon Faire")))
end

--- Checks wheather the current date is within the given date range
---@param startDay number?
---@param startMonth number?
---@param endDay number?
---@param endMonth number?
---@return boolean @True if the current date is between the given, false otherwise
_WithinDates = function(startDay, startMonth, endDay, endMonth)
    if (not startDay) and (not startMonth) and (not endDay) and (not endMonth) then
        return true
    end
    local date = (C_DateAndTime.GetTodaysDate or C_DateAndTime.GetCurrentCalendarTime)() -- TODO: Move to QuestieCompat
    local day = date.monthDay or date.day
    local month = date.month
    if (startMonth <= endMonth) -- Event start and end during same year
        and ((month < startMonth) or (month > endMonth)) -- Too early or late in the year
        or ((month < startMonth) and (month > endMonth)) -- Event span across year change
        or (month == startMonth and day < startDay) -- Too early in the correct month
        or (month == endMonth and day > endDay) then -- Too late in the correct month
        return false
    else
        return true
    end
end

---@return string
function QuestieEvent:GetEventNameFor(questId)
    return _QuestieEvent.eventNamesForQuests[questId] or ""
end

function QuestieEvent:IsEventQuest(questId)
    return _QuestieEvent.eventNamesForQuests[questId] ~= nil
end

local isChinaRegion = GetCurrentRegion() == 5

-- EUROPEAN FORMAT! NO FUCKING AMERICAN SHIDAZZLE FORMAT!
QuestieEvent.eventDates = {
    ["Love is in the Air"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "03/2",
        endDate = "16/2"
    },
    ["Noblegarden"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "20/4",
        endDate = "26/4"
    },
    ["Children's Week"] = {startDate = "28/4", endDate = "12/5"}, -- TODO: Usually it is only a week long
    ["Midsummer"] = (isChinaRegion and Questie.IsWotlk) and {startDate = "21/6", endDate = "28/7"} or {startDate = "21/6", endDate = "4/7"},
    ["Brewfest"] = {startDate = "20/9", endDate = "5/10"}, -- TODO: This might be different (retail date)
    ["Harvest Festival"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "13/9",
        endDate = "19/9"
    },
    ["Pilgrim's Bounty"] = {startDate = "26/11", endDate = "2/12"},
    ["Hallow's End"] = {startDate = "18/10", endDate = "31/10"},
    ["Winter Veil"] = {startDate = "15/12", endDate = "1/1"},
    ["Day of the Dead"] = {startDate = "1/11", endDate = "2/11"},
}

-- ["EventName"] = false -> event doesn't exists in expansion
-- ["EventName"] = {startDate = "12/3", endDate = "12/3"} -> change dates for the expansion
QuestieEvent.eventDateCorrections = {
    ["CLASSIC"] = {
        ["Brewfest"] = false,
        ["Pilgrim's Bounty"] = false,
        ["Love is in the Air"] = {startDate = "11/2", endDate = "16/2"},
    },
    ["TBC"] = {
        ["Harvest Festival"] = false,
    },
}

QuestieEvent.lunarFestival = {
    ["19"] = {startDate = "5/2", endDate = "19/2"},
    ["20"] = {startDate = "23/1", endDate = "10/2"},
    ["21"] = {startDate = "5/2", endDate = "19/2"}, --when this was for real?
    ["22"] = {startDate = "30/1", endDate = "18/2"},
    -- Below are estimates
    ["23"] = {startDate = "20/1", endDate = "10/2"},
    ["24"] = {startDate = "3/2", endDate = "23/2"},
    ["25"] = {startDate = "28/1", endDate = "17/2"},
    ["26"] = {startDate = "17/2", endDate = "3/3"},
    ["27"] = {startDate = "7/2", endDate = "21/2"},
    ["28"] = {startDate = "27/1", endDate = "10/2"}
}

return QuestieEvent
