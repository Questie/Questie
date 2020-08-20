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
]] --

---@class QuestieEvent
local QuestieEvent = QuestieLoader:CreateModule("QuestieEvent")
QuestieEvent.activeQuests = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieNPCFixes
local QuestieNPCFixes = QuestieLoader:ImportModule("QuestieNPCFixes")


local tinsert = table.insert
local _WithinDates, _LoadDarkmoonFaire, _IsDarkmoonFaireActive

function QuestieEvent:Load()
    local year = date("%y")

    -- We want to replace the Lunar Festival date with the date that we estimate
    QuestieEvent.eventDates["LunarFestival"] = QuestieEvent.lunarFestival[year]
    local activeEvents = {}

    for eventName, eventData in pairs(QuestieEvent.eventDates) do
        local startDay, startMonth = strsplit("/", eventData.startDate)
        local endDay, endMonth = strsplit("/", eventData.endDate)

        startDay = tonumber(startDay)
        startMonth = tonumber(startMonth)
        endDay = tonumber(endDay)
        endMonth = tonumber(endMonth)

        -- startDate = "15/12",
        -- endDate = "2/1",
        if _WithinDates(startDay, startMonth, endDay, endMonth) then
            Questie:Debug(DEBUG_INFO, "[QuestieEvent]", eventName,
                          "event is active!")
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

        if activeEvents[eventName] == true and _WithinDates(startDay, startMonth, endDay, endMonth) then
            QuestieCorrections.hiddenQuests[questId] = nil
            QuestieEvent.activeQuests[questId] = true
        end
    end

    -- Darkmoon Faire is quite special because of its setup days where just two quests are available
    _LoadDarkmoonFaire()

    -- Clear the quests to save memory
    -- QuestieEvent.eventQuests = nil
end

---@param day number
---@param weekDay number
---@return boolean
_IsDarkmoonFaireActive = function(day, weekDay)
    -- The 16 is the highest date the faire can possibly end
    -- And on a Monday (weekDay == 2) the faire ended, when it's the second Monday after the first Friday of the month
    if day > 16 or
        (weekDay == 2 and day >= 11) or
        (weekDay ~= 6 and (day - weekDay < 1)) or
        (weekDay ~= 6 and (day - weekDay == 1)) or
        (weekDay ~= 1 and (day - weekDay == 9)) then -- Sometimes the 1th is a Friday
        return false
    end

    return true
end

--- https://classic.wowhead.com/guides/classic-darkmoon-faire#darkmoon-faire-location-and-schedule
--- Darkmoon Faire starts its setup the first Friday of the month and will begin the following Monday.
--- The faire ends the sunday after it has begun.
--- Sunday is the first weekday
_LoadDarkmoonFaire = function()
    local date = C_DateAndTime.GetTodaysDate()
    local weekDay = date.weekDay
    local day = date.day
    local month = date.month

    local isInMulgore = (month % 2) == 0

    if (not _IsDarkmoonFaireActive(day, weekDay)) then
        return
    end

    -- The faire is setting up right now or is already up
    local annoucingQuestId = 7905 -- Alliance announcement quest
    if isInMulgore then
        annoucingQuestId = 7926 -- Horde announcement quest
    end
    QuestieCorrections.hiddenQuests[annoucingQuestId] = nil
    QuestieEvent.activeQuests[annoucingQuestId] = true

    if (weekDay >= 2 and day >= 5) or (weekDay == 1 and day >= 10 and day <= 16) then
        -- The faire is up right now
        for _, questData in pairs(QuestieEvent.eventQuests) do
            if questData[1] == "DarkmoonFaire" then
                local questId = questData[2]
                QuestieCorrections.hiddenQuests[questId] = nil
                QuestieEvent.activeQuests[questId] = true

                -- Update the NPC spawns based on the place of the faire
                for id, data in pairs(QuestieNPCFixes:LoadDarkmoonFixes(isInMulgore)) do
                    QuestieDB.npcDataOverrides[id] = data
                end
            end
        end
    end
end

--- Checks wheather the current date is within the given date range
---@param startDay number
---@param startMonth number
---@param endDay number
---@param endMonth number
---@return boolean @True if the current date is between the given, false otherwise
_WithinDates = function(startDay, startMonth, endDay, endMonth)
    if (not startDay) and (not startMonth) and (not endDay) and (not endMonth) then
        return true
    end
    local date = C_DateAndTime.GetTodaysDate()
    local day = date.day
    local month = date.month
    if (month < startMonth) or -- Too early in the year
        (month > endMonth) or -- Too late in the year
        (month == startMonth and day < startDay) or -- Too early in the correct month
        (month == endMonth and day > endDay) then -- Too late in the correct month
        return false
    else
        return true
    end
end

-- EUROPEAN FORMAT! NO FUCKING AMERICAN SHIDAZZLE FORMAT!
QuestieEvent.eventDates = {
    ["LunarFestival"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "23/1",
        endDate = "10/2"
    },
    ["LoveIsInTheAir"] = {startDate = "11/2", endDate = "16/2"},
    ["Noblegarden"] = { -- WARNING THIS DATE VARIES!!!!
        startDate = "13/5",
        endDate = "19/5"
    },
    ["MidsummerFireFestival"] = {startDate = "21/6", endDate = "5/7"},
    ["ChildrensWeek"] = {startDate = "1/5", endDate = "7/5"},
    ["HarvestFestival"] = {startDate = "27/9", endDate = "4/10"},
    ["PeonDay"] = {startDate = "30/9", endDate = "30/9"},
    ["HallowsEnd"] = {startDate = "18/10", endDate = "1/11"},
    ["WinterVeil"] = {startDate = "15/12", endDate = "2/1"}
}

QuestieEvent.lunarFestival = {
    ["19"] = {startDate = "5/2", endDate = "19/2"},
    ["20"] = {startDate = "23/1", endDate = "10/2"},
    -- Below are estimates
    ["21"] = {startDate = "12/2", endDate = "26/2"},
    ["22"] = {startDate = "1/2", endDate = "15/2"},
    ["23"] = {startDate = "22/1", endDate = "5/2"},
    ["24"] = {startDate = "10/2", endDate = "24/2"},
    ["25"] = {startDate = "29/1", endDate = "12/2"},
    ["26"] = {startDate = "17/2", endDate = "3/3"},
    ["27"] = {startDate = "7/2", endDate = "21/2"},
    ["28"] = {startDate = "27/1", endDate = "10/2"}
}

-- This variable will be cleared at the end of the load, do not use, use QuestieEvent.activeQuests.
QuestieEvent.eventQuests = {}

tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8684}) -- Dreamseer the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8635}) -- Splitrock the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8883}) -- Valadar Starsong
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8713}) -- Starsong the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8867}) -- Lunar Fireworks
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8865}) -- Festive Lunar Pant Suits
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8868}) -- Elune's Blessing
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8642}) -- Silvervein the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8866}) -- Bronzebeard the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8643}) -- Highpeak the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8678}) -- Proudhorn the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8864}) -- Festive Lunar Dresses
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8670}) -- Runetotem the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8725}) -- Riversong the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8683}) -- Dawnstrider the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8879}) -- Large Rockets
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8716}) -- Starglade the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8650}) -- Snowcrown the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8876}) -- Small Rockets
-- tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8874}) -- The Lunar Festival
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8880}) -- Cluster Rockets
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8722}) -- Meadowrun the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8652}) -- Graveborn the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8878}) -- Festive Recipes
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8873}) -- The Lunar Festival
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8720}) -- Skygleam the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8673}) -- Bloodhoof the Elder
-- tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8875}) -- The Lunar Festival
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8862}) -- Elune's Candle
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8723}) -- Nightwind the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8681}) -- Thunderhorn the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8676}) -- Wildmane the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8651}) -- Ironband the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8863}) -- Festival Dumplings
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8672}) -- Stonespire the Elder
-- tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8870}) -- The Lunar Festival
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8871}) -- The Lunar Festival
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8649}) -- Stormbrow the Elder
-- tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8872}) -- The Lunar Festival
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8726}) -- Brightspear the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8877}) -- Firework Launcher
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8718}) -- Bladeswift the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8685}) -- Mistwalker the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8653}) -- Goldwell the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8671}) -- Ragetotem the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8677}) -- Darkhorn the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8882}) -- Cluster Launcher
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8714}) -- Moonstrike the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8645}) -- Obsidian the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8717}) -- Moonwarden the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8648}) -- Darkcore the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8715}) -- Bladeleaf the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8646}) -- Hammershout the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8724}) -- Morningdew the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8727}) -- Farwhisper the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8679}) -- Grimtotem the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8647}) -- Bellowrage the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8674}) -- Winterhoof the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8680}) -- Windtotem the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8686}) -- High Mountain the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8654}) -- Primestone the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8721}) -- Starweave the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8881}) -- Large Cluster Rockets
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8619}) -- Morndeep the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8688}) -- Windrun the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8682}) -- Skyseer the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8636}) -- Rumblerock the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8644}) -- Stonefort the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8675}) -- Skychaser the Elder
tinsert(QuestieEvent.eventQuests, {"LunarFestival", 8719}) -- Bladesing the Elder

tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8897}) -- Dearest Colara
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8898}) -- Dearest Colara
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8899}) -- Dearest Colara
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8900}) -- Dearest Elenia
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8901}) -- Dearest Elenia
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8902}) -- Dearest Elenia
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8903}) -- Dangerous Love
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8904}) -- Dangerous Love
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8979}) -- Fenstad's Hunch
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8980}) -- Zinge's Assessment
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8981}) -- Gift Giving
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8982}) -- Tracing the Source
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8983}) -- Tracing the Source
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8984}) -- The Source Revealed
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 8993}) -- Gift Giving
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 9024}) -- Aristan's Hunch
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 9025}) -- Morgan's Discovery
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 9026}) -- Tracing the Source
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 9027}) -- Tracing the Source
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 9028}) -- The Source Revealed
tinsert(QuestieEvent.eventQuests, {"LoveIsInTheAir", 9029}) -- A Bubbling Cauldron

tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9388}) -- Flickering Flames in Kalimdor
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9389}) -- Flickering Flames in the Eastern Kingdoms
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9319}) -- A Light in Dark Places
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9386}) -- A Light in Dark Places
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9367}) -- The Festival of Fire
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9368}) -- The Festival of Fire
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9322}) -- Wild Fires in Kalimdor
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9323}) -- Wild Fires in the Eastern Kingdoms
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9324}) -- Stealing Orgrimmar's Flame
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9325}) -- Stealing Thunder Bluff's Flame
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9326}) -- Stealing the Undercity's Flame
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9330}) -- Stealing Stormwind's Flame
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9331}) -- Stealing Ironforge's Flame
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9332}) -- Stealing Darnassus's Flame
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9339}) -- A Thief's Reward
tinsert(QuestieEvent.eventQuests, {"MidsummerFireFestival", 9365}) -- A Thief's Reward

tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 171}) -- A Warden of the Alliance
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 5502}) -- A Warden of the Horde
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 172}) -- Children's Week
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 1468}) -- Children's Week
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 915}) -- You Scream, I Scream...
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 4822}) -- You Scream, I Scream...
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 1687}) -- Spooky Lighthouse
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 558}) -- Jaina's Autograph
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 925}) -- Cairne's Hoofprint
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 1800}) -- Lordaeron Throne Room
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 1479}) -- The Bough of the Eternals
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 1558}) -- The Stonewrought Dam
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 910}) -- Down at the Docks
tinsert(QuestieEvent.eventQuests, {"ChildrensWeek", 911}) -- Gateway to the Frontier

tinsert(QuestieEvent.eventQuests, {"HarvestFestival", 8149}) -- Honoring a Hero
tinsert(QuestieEvent.eventQuests, {"HarvestFestival", 8150}) -- Honoring a Hero

tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8373}) -- The Power of Pine
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 1658}) -- Crashing the Wickerman Festival
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8311}) -- Hallow's End Treats for Jesper!
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8312}) -- Hallow's End Treats for Spoops!
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8322}) -- Rotten Eggs
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 1657}) -- Stinking Up Southshore
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8409}) -- Ruined Kegs
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8357}) -- Dancing for Marzipan
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8355}) -- Incoming Gumdrop
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8356}) -- Flexing for Nougat
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8358}) -- Incoming Gumdrop
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8353}) -- Chicken Clucking for a Mint
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8359}) -- Flexing for Nougat
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8354}) -- Chicken Clucking for a Mint
tinsert(QuestieEvent.eventQuests, {"HallowsEnd", 8360}) -- Dancing for Marzipan

tinsert(QuestieEvent.eventQuests, {"WinterVeil", 6961}) -- Great-father Winter is Here!
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7021}) -- Great-father Winter is Here!
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7022}) -- Greatfather Winter is Here!
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7023}) -- Greatfather Winter is Here!
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7024}) -- Great-father Winter is Here!
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 6962}) -- Treats for Great-father Winter
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7025}) -- Treats for Greatfather Winter
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7043}) -- You're a Mean One...
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 6983}) -- You're a Mean One...
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 6984}) -- A Smokywood Pastures' Thank You!
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7045}) -- A Smokywood Pastures' Thank You!
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7063}) -- The Feast of Winter Veil
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7061}) -- The Feast of Winter Veil
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 6963}) -- Stolen Winter Veil Treats
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7042}) -- Stolen Winter Veil Treats
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 7062}) -- The Reason for the Season
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8763}) -- The Hero of the Day
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8799}) -- The Hero of the Day
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 6964}) -- The Reason for the Season
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8762}) -- Metzen the Reindeer
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8746}) -- Metzen the Reindeer
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8744, "25/12", "2/1"}) -- A Carefully Wrapped Present
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8767, "25/12", "2/1"}) -- A Gently Shaken Gift
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8768, "25/12", "2/1"}) -- A Gaily Wrapped Present
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8769, "25/12", "2/1"}) -- A Ticking Present
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8788, "25/12", "2/1"}) -- A Gently Shaken Gift
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8803, "25/12", "2/1"}) -- A Festive Gift
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8827, "25/12", "2/1"}) -- Winter's Presents
tinsert(QuestieEvent.eventQuests, {"WinterVeil", 8828, "25/12", "2/1"}) -- Winter's Presents

-- tinsert(QuestieEvent.eventQuests, {"-1006", 8861}) --New Year Celebrations!
-- tinsert(QuestieEvent.eventQuests, {"-1006", 8860}) --New Year Celebrations!

tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7902}) -- Vibrant Plumes
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7903}) -- Evil Bat Eyes
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 8222}) -- Glowing Scorpid Blood
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7901}) -- Soft Bushy Tails
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7899}) -- Small Furry Paws
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7940}) -- 1200 Tickets - Orb of the Darkmoon
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7900}) -- Torn Bear Pelts
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7907}) -- Darkmoon Beast Deck
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7927}) -- Darkmoon Portals Deck
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7929}) -- Darkmoon Elementals Deck
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7928}) -- Darkmoon Warlords Deck
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7946}) -- Spawn of Jubjub
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 8223}) -- More Glowing Scorpid Blood
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7934}) -- 50 Tickets - Darkmoon Storage Box
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7981}) -- 1200 Tickets - Amulet of the Darkmoon
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7943}) -- More Bat Eyes
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7894}) -- Copper Modulator
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7933}) -- 40 Tickets - Greater Darkmoon Prize
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7898}) -- Thorium Widget
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7885}) -- Armor Kits
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7942}) -- More Thorium Widgets
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7883}) -- The World's Largest Gnome!
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7892}) -- Big Black Mace
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7937}) -- Your Fortune Awaits You...
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7939}) -- More Dense Grinding Stones
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7893}) -- Rituals of Strength
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7891}) -- Green Iron Bracers
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7896}) -- Green Fireworks
-- tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 9249}) -- 40 Tickets - Schematic: Steam Tonk Controller
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7884}) -- Crocolisk Boy and the Bearded Murloc
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7882}) -- Carnival Jerkins
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7897}) -- Mechanical Repair Kits
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7895}) -- Whirring Bronze Gizmo
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7941}) -- More Armor Kits
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7881}) -- Carnival Boots
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7890}) -- Heavy Grinding Stone
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7889}) -- Coarse Weightstone
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7945}) -- Your Fortune Awaits You...
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7935}) -- 10 Tickets - Last Month's Mutton
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7938}) -- Your Fortune Awaits You...
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7944}) -- Your Fortune Awaits You...
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7932}) -- 12 Tickets - Lesser Darkmoon Prize
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7930}) -- 5 Tickets - Darkmoon Flower
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7931}) -- 5 Tickets - Minor Darkmoon Prize
tinsert(QuestieEvent.eventQuests, {"DarkmoonFaire", 7936}) -- 50 Tickets - Last Year's Mutton
