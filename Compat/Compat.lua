---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieStream
local QuestieStream = QuestieLoader:ImportModule("QuestieStreamLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieEventHandler
local QuestieEventHandler = QuestieLoader:ImportModule("QuestieEventHandler")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestEventHandler
local QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
---@class AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type MinimapIcon
local MinimapIcon = QuestieLoader:ImportModule("MinimapIcon")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestXP
local QuestXP = QuestieLoader:ImportModule("QuestXP")
---@class QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords")
---@class Sounds
local Sounds = QuestieLoader:ImportModule("Sounds")
---@class QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@class QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@class QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@class QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")

-- addon/folder name
QuestieCompat.addonName = ...

QuestieCompat.NOOP = function() end
QuestieCompat.NOOP_MT = {__index = function() return QuestieCompat.NOOP end}

-- events handler
QuestieCompat.frame = CreateFrame("Frame")
QuestieCompat.frame:RegisterEvent("ADDON_LOADED")
QuestieCompat.frame:RegisterEvent("PLAYER_LOGIN")
QuestieCompat.frame:RegisterEvent("PLAYER_LOGOUT")
QuestieCompat.frame:SetScript("OnEvent", function(self, event, ...)
    QuestieCompat[event](self, event, ...)
end)

-- current expansion level (https://wowpedia.fandom.com/wiki/WOW_PROJECT_ID)
QuestieCompat.WOW_PROJECT_CLASSIC = 2
QuestieCompat.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
QuestieCompat.WOW_PROJECT_WRATH_CLASSIC = 11
QuestieCompat.WOW_PROJECT_ID = tonumber(GetAddOnMetadata(QuestieCompat.addonName, "X-WOW_PROJECT_ID"))

-- check for a specific type of group
QuestieCompat.LE_PARTY_CATEGORY_HOME = 1 -- home-realm parties
QuestieCompat.LE_PARTY_CATEGORY_INSTANCE = 2 -- instance-specific groups

-- Date stuff
QuestieCompat.CALENDAR_WEEKDAY_NAMES = {
	WEEKDAY_SUNDAY,
	WEEKDAY_MONDAY,
	WEEKDAY_TUESDAY,
	WEEKDAY_WEDNESDAY,
	WEEKDAY_THURSDAY,
	WEEKDAY_FRIDAY,
	WEEKDAY_SATURDAY,
};

-- month names show up differently for full date displays in some languages
QuestieCompat.CALENDAR_FULLDATE_MONTH_NAMES = {
	FULLDATE_MONTH_JANUARY,
	FULLDATE_MONTH_FEBRUARY,
	FULLDATE_MONTH_MARCH,
	FULLDATE_MONTH_APRIL,
	FULLDATE_MONTH_MAY,
	FULLDATE_MONTH_JUNE,
	FULLDATE_MONTH_JULY,
	FULLDATE_MONTH_AUGUST,
	FULLDATE_MONTH_SEPTEMBER,
	FULLDATE_MONTH_OCTOBER,
	FULLDATE_MONTH_NOVEMBER,
	FULLDATE_MONTH_DECEMBER,
};

-- https://wago.tools/db2/ChrRaces?build=3.4.3.52237
QuestieCompat.ChrRaces = {
	Human = 1,
	Orc = 2,
	Dwarf = 3,
	NightElf = 4,
	Scourge = 5,
	Tauren = 6,
	Gnome = 7,
	Troll = 8,
	Goblin = 9,
	BloodElf = 10,
	Draenei = 11,
	FelOrc = 12,
	Naga_ = 13,
	Broken = 14,
	Skeleton = 15,
	Vrykul = 16,
	Tuskarr = 17,
	ForestTroll = 18,
	Taunka = 19,
	NorthrendSkeleton = 20,
	IceTroll = 21,
}

-- https://wago.tools/db2/ChrClasses?build=3.4.3.52237
QuestieCompat.ChrClasses = {
	WARRIOR = 1,
	PALADIN = 2,
	HUNTER = 3,
	ROGUE = 4,
	PRIEST = 5,
	DEATHKNIGHT = 6,
	SHAMAN = 7,
	MAGE = 8,
	WARLOCK = 9,
	DRUID = 11,
}

local activeTimers = {}
local inactiveTimers = {}

local function timerCancel(id)
    local timer = activeTimers[id]
    if not timer then return end

    timer:GetParent():Stop()

    timer.id = nil
    activeTimers[id] = nil
	inactiveTimers[timer] = true
end

local function timerOnFinished(self)
    local id = self.id
    self.callback(id)

    -- Make sure timer wasn't cancelled during the callback and used again
    if id == self.id then
        if self.iterations > 0 then
            self.iterations = self.iterations - 1
            if self.iterations == 0 then
                timerCancel(id)
            end
        end
    end
end

QuestieCompat.C_Timer = {
    -- Schedules a (repeating) timer that can be canceled. (https://wowpedia.fandom.com/wiki/API_C_Timer.NewTimer)
    NewTicker = function(duration, callback, iterations)
        local timer = next(inactiveTimers)
        if timer then
        	inactiveTimers[timer] = nil
        else
        	local anim = QuestieCompat.frame:CreateAnimationGroup()
        	timer = anim:CreateAnimation()
        	timer:SetScript("OnFinished", timerOnFinished)
        end

        if duration < 0.01 then duration = 0.01 end
        timer:SetDuration(duration)

        timer.callback = callback
        timer.iterations = iterations or -1
        timer.id = {Cancel = timerCancel}
        activeTimers[timer.id] = timer

        local anim = timer:GetParent()
        anim:SetLooping("REPEAT")
        anim:Play()

        return timer.id
    end,
    -- Schedules a timer. (https://wowpedia.fandom.com/wiki/API_C_Timer.After)
    After = function(duration, callback)
        return QuestieCompat.C_Timer.NewTicker(duration, callback, 1)
    end
}

local mapIdToUiMapId = {}
-- convert current mapAreaID and mapLevel to UiMapId
-- https://wowpedia.fandom.com/wiki/API_GetCurrentMapAreaID
-- https://wowwiki-archive.fandom.com/wiki/API_GetCurrentMapDungeonLevel
-- https://wowpedia.fandom.com/wiki/UiMapID#Classic
function QuestieCompat.GetCurrentUiMapID()
    local mapID = GetCurrentMapAreaID()
    if mapID == 0 then -- both the "Cosmic" and "Azeroth" maps return a mapID of 0
        mapID = GetCurrentMapContinent()
    end
    return mapIdToUiMapId[mapID + GetCurrentMapDungeonLevel()/10] or 946
end

-- maps mapAreaID to Zone and Continent index
-- https://wowpedia.fandom.com/wiki/API_GetMapContinents
-- https://wowpedia.fandom.com/wiki/API_GetMapZones
local mapIdToCZ = {}
for C in ipairs({GetMapContinents()}) do
    local zones = {GetMapZones(C)}
    for Z in ipairs(zones) do
        SetMapZoom(C, Z)
        local mapId = GetCurrentMapAreaID()
        mapIdToCZ[mapId] = Z + C/10
    end
end

function QuestieCompat.TomTom_AddWaypoint(title, zone, x, y)
    local CZ = mapIdToCZ[QuestieCompat.UiMapData[zone].mapID]
    return TomTom:AddZWaypoint(QuestieCompat.Round(CZ%1 * 10), math.floor(CZ), x, y, title)
end

-- This function will do its utmost to retrieve some sort of valid position
-- for the player, including changing the current map zoom (if needed)
-- https://wowpedia.fandom.com/wiki/API_C_Map.GetPlayerMapPosition?oldid=2167175
function QuestieCompat.GetCurrentPlayerPosition()
	local x, y = GetPlayerMapPosition("player");
	if ( x <= 0 and y <= 0 ) then
		if ( WorldMapFrame:IsVisible() ) then
			-- we know there is a visible world map, so don't cause
			-- WORLD_MAP_UPDATE events by changing map zoom
			return QuestieCompat.GetCurrentUiMapID(), x, y;
		end
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition("player");
		if ( x <= 0 and y <= 0 ) then
			-- attempt to zoom out once - logic copied from WorldMapZoomOutButton_OnClick()
				if ( ZoomOut() ) then
					-- do nothing
				elseif ( GetCurrentMapZone() ~= WORLDMAP_WORLD_ID ) then
					SetMapZoom(GetCurrentMapContinent());
				else
					SetMapZoom(WORLDMAP_WORLD_ID);
				end
			x, y = GetPlayerMapPosition("player");
			if ( x <= 0 and y <= 0 ) then
				-- we are in an instance without a map or otherwise off map
				return QuestieCompat.GetCurrentUiMapID(), x, y;
			end
		end
	end
	return QuestieCompat.GetCurrentUiMapID(), x, y;
end

-- wrapper used by QuestieCoords
local playerPos = {}
function QuestieCompat.GetPlayerMapPosition()
    playerPos.uiMapID, playerPos.x, playerPos.y = QuestieCompat.GetCurrentPlayerPosition()
    return playerPos, playerPos.uiMapID
end

QuestieCompat.C_Map = {
    -- Returns map information.
	-- https://wowpedia.fandom.com/wiki/API_C_Map.GetMapInfo
	GetMapInfo = function(uiMapID)
        if QuestieCompat.UiMapData[uiMapID] then
            return QuestieCompat.UiMapData[uiMapID]
        end
	end,
    -- Returns a map subzone name.
    -- https://wowpedia.fandom.com/wiki/API_C_Map.GetAreaInfo
	GetAreaInfo = function(areaID)
        return
	end,
    -- Returns the current UI map for the given unit.
    -- https://wowpedia.fandom.com/wiki/API_C_Map.GetBestMapForUnit
	GetBestMapForUnit = function(unit)
        if unit == "player" then
            return QuestieCompat.GetCurrentPlayerPosition()
        end
	end,
    -- Translates a map position to a world map position.
    -- https://wowpedia.fandom.com/wiki/API_C_Map.GetWorldPosFromMapPos
	GetWorldPosFromMapPos = function(uiMapID, mapPos)
        local x, y, instanceID = QuestieCompat.HBD:GetWorldCoordinatesFromZone(mapPos.x, mapPos.y, uiMapID)
        return instanceID or 0, {x = x or 0, y = y or 0}
	end,
}

-- https://www.townlong-yak.com/framexml/classic/Blizzard_MapCanvas/Blizzard_MapCanvas.lua
QuestieCompat.WorldMapFrame = {
    IsVisible = function(self)
        return WorldMapFrame:IsVisible()
    end,
    IsShown = function(self)
        return WorldMapFrame:IsShown()
    end,
    Show = function(self)
        ShowUIPanel(WorldMapFrame)
    end,
    GetCanvas = function(self)
        return WorldMapButton
    end,
    GetMapID = QuestieCompat.GetCurrentUiMapID,
    SetMapID = function(self, UiMapID)
        local mapID = QuestieCompat.UiMapData[UiMapID].mapID
        local mapLevel = QuestieCompat.Round(mapID%1 * 10)

        SetMapByID(math.floor(mapID) - 1)
        if mapLevel > 0 then
            SetDungeonMapLevel(mapLevel)
        end
    end,
    EnumeratePinsByTemplate = function(self, template)
        return pairs(QuestieCompat.HBDPins.worldmapPins)
    end,
}

QuestieCompat.C_Calendar = {
    -- Returns information about the calendar month by offset.
	-- https://wowpedia.fandom.com/wiki/API_C_Calendar.GetMonthInfo
	GetMonthInfo = function(offsetMonths)
		local month, year, numdays, firstday = CalendarGetMonth(offsetMonth);
		return {
			month = month,
			year = year,
			numDays = numdays,
			firstWeekday = firstday,
		}
	end,
}

QuestieCompat.C_DateAndTime = {
    -- Returns the realm's current date and time.
	-- https://wowpedia.fandom.com/wiki/API_C_DateAndTime.GetCurrentCalendarTime
	GetCurrentCalendarTime = function()
		local weekday, month, day, year = CalendarGetDate();
		local hours, minutes = GetGameTime()
		return {
			year = year,
			month = month,
			monthDay = day,
			weekday = weekday,
			hour = hours,
			minute = minutes
		}
	end
}

-- Returns the server's Unix time.
-- https://wowpedia.fandom.com/wiki/API_GetServerTime
function QuestieCompat.GetServerTime()
    local weekday, month, day, year = CalendarGetDate()
	local hours, minutes = GetGameTime()

    local currentDate = {
        year = year,
        month = month,
        day = day,
        weekday = weekday,
        hour = hours,
        min = minutes,
    }

    return time(currentDate), currentDate
end

local questObjectivesCache = {}

local function parseQuestObjective(text)
    return string.match(string.gsub(text, "\239\188\154", ":"), "(.*):%s*([%d]+)%s*/%s*([%d]+)")
end

QuestieCompat.C_QuestLog = {
	-- Returns info for the objectives of a quest. (https://wowpedia.fandom.com/wiki/API_C_QuestLog.GetQuestObjectives)
	GetQuestObjectives = function(questID, questLogIndex)
		local questObjectives, objectiveIndex = {}, 1
        if questLogIndex then
		    local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
		    for i = 1, numObjectives do
		    	-- https://wowpedia.fandom.com/wiki/API_GetQuestLogLeaderBoard
		    	local description, objectiveType, isCompleted = GetQuestLogLeaderBoard(i, questLogIndex);
                if objectiveType ~= "log" then
		    	    local objectiveName, numFulfilled, numRequired = parseQuestObjective(description)
                    -- GetQuestLogLeaderBoard randomly returns incorrect objective information.
                    -- Parsing the UI_INFO_MESSAGE event for the correct numFulfilled value seems like the solution.
                    local fulfilled = questObjectivesCache[objectiveName]
                    if fulfilled and (not isCompleted) then
                        numFulfilled = fulfilled
                        questObjectivesCache[objectiveName] = nil
                    end

		    	    table.insert(questObjectives, objectiveIndex, {
		    	    	text = description,
		    	    	type = objectiveType,
		    	    	finished = isCompleted and true or false,
		    	    	numFulfilled = tonumber(numFulfilled) or (isCompleted and 1 or 0),
		    	    	numRequired = tonumber(numRequired) or 1,
		    	    })
					-- "event" should always be last?
					objectiveIndex = objectiveIndex + (objectiveType ~= "event" and 1 or 0)
                end
		    end
        end
		return questObjectives -- can be empty for quests without objectives
	end,
    GetMaxNumQuestsCanAccept = function()
        return MAX_QUESTLOG_QUESTS
    end,
    IsOnQuest = function(questId)
        return QuestieCompat.GetQuestLogIndexByID(questId) and true or false
    end,
}

-- Can't find anything about this function.
-- Apparently, it returns true when quest data is ready to be queried.
function QuestieCompat.HaveQuestData(questID)
	return true
end

-- https://wowpedia.fandom.com/wiki/API_GetQuestLogTitle?oldid=2214753
-- Returns information about a quest in your quest log.
-- Patch 6.0.2 (2014-10-14): Removed returns 'questTag'.
function QuestieCompat.GetQuestLogTitle(questLogIndex)
    local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed,
        isComplete, isDaily, questID = GetQuestLogTitle(questLogIndex);

    if (isComplete == nil) then
        local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
        local requiredMoney = GetQuestLogRequiredMoney(questLogIndex);
        isComplete = (numObjectives == 0 and GetMoney() >= requiredMoney) and 1 or nil
    end
    return questTitle, level, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily and 2 or 1, questID
end

local MAX_QUEST_LOG_INDEX = 75
-- Returns the current quest log index of a quest by its ID.
-- https://wowpedia.fandom.com/wiki/API_GetQuestLogIndexByID
function QuestieCompat.GetQuestLogIndexByID(questId)
    for questLogIndex = 1, MAX_QUEST_LOG_INDEX do
        local title, _, _, _, isHeader, _, _, _, id = GetQuestLogTitle(questLogIndex)
        if (not title) then
            break -- We exceeded the valid quest log entries
        end
        if (not isHeader) then
            if (questId == id) then
                return questLogIndex
            end
        end
    end
end

function QuestieCompat.GetQuestIDFromLogIndex(questLogIndex)
    return select(9, GetQuestLogTitle(questLogIndex))
end

-- https://wowpedia.fandom.com/wiki/API_GetQuestLink
-- Returns a QuestLink for a quest.
-- Between patches 6.2 and 7.3.2 argument was changed to take a QuestID instead of a quest log index.
function QuestieCompat.GetQuestLink(questId)
    local questLogIndex = QuestieCompat.GetQuestLogIndexByID(questId)
    return questLogIndex and GetQuestLink(questLogIndex)
end

function QuestieCompat:GetQuestLinkString(questLevel, questName, questId)
	return QuestieCompat.GetQuestLink(questId) or "[["..tostring(questLevel).."] "..questName.." ("..tostring(questId)..")]"
end

function QuestieCompat:GetQuestLinkStringById(questId)
    local questName = QuestieDB.QueryQuestSingle(questId, "name");
    local questLevel, _ = QuestieLib.GetTbcLevel(questId);
    return QuestieCompat:GetQuestLinkString(questLevel, questName, questId)
end

-- https://wowpedia.fandom.com/wiki/API_GetQuestLogRewardMoney
-- Returns the amount of money rewarded for a quest.
function QuestieCompat.GetQuestLogRewardMoney(questID)
    local rewardMoney = QuestieCompat.RewardMoney[questID] or 0
	local rewardMoneyDifficulty = QuestieCompat.RewardMoneyDifficulty[questID] or 0

    if rewardMoney < 0 then -- required money
        return rewardMoney
    end

    local playerLevel = QuestiePlayer.GetPlayerLevel()
    if playerLevel > 0 and rewardMoneyDifficulty > 0 then
        rewardMoney = QuestieCompat.QuestMoneyReward[playerLevel][rewardMoneyDifficulty]
    end

    -- https://wowpedia.fandom.com/wiki/Quest?oldid=1035002 Formula is XP gained * 6c
    if QuestiePlayer.IsMaxLevel() then
        local xpReward = QuestXP:GetQuestLogRewardXP(questID, true)
        if xpReward > 0 then
            rewardMoney = rewardMoney + xpReward*6
        end
    end

    return rewardMoney
end

function QuestieCompat.CalculateNextResetTime()
    local currentTime, currentDate = QuestieCompat.GetServerTime()
    local timeUntilReset = GetQuestResetTime()

    Questie:Debug(Questie.DEBUG_DEVELOP, "[CalculateNextResetTime] GetQuestResetTime: ", timeUntilReset)
    if timeUntilReset <= 0 then
        Questie:Error("GetQuestResetTime() returns an invalid value: "..timeUntilReset..". Please report on Github!")
        return
    end
    Questie.db.profile.dailyResetTime = Questie.db.profile.dailyResetTime or (currentTime + timeUntilReset)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[CalculateNextResetTime] Next daily rest time: ", date("%m/%d/%y %H:%M:%S", Questie.db.profile.dailyResetTime))

    Questie.db.profile.weeklyResetHour = Questie.db.profile.weeklyResetHour or tonumber(date("%H", Questie.db.profile.dailyResetTime+300))
    local dayOffset = (Questie.db.profile.weeklyResetDay - currentDate.weekday + 7) % 7
    if dayOffset == 0 and currentDate.hour >= Questie.db.profile.weeklyResetHour then
        dayOffset = 7
    end

    Questie.db.profile.weeklyResetTime = Questie.db.profile.weeklyResetTime or time({
        year = currentDate.year,
        month = currentDate.month,
        day = currentDate.day + dayOffset,
        hour = Questie.db.profile.weeklyResetHour,
    })
    Questie:Debug(Questie.DEBUG_DEVELOP, "[CalculateNextResetTime] Next weekly rest time: ", date("%m/%d/%y %H:%M:%S", Questie.db.profile.weeklyResetTime))
end

function QuestieCompat.ResetDailyQuests(reset)
    local currentTime = QuestieCompat.GetServerTime()

    if reset or (currentTime > Questie.db.profile.dailyResetTime) then
        for questId in pairs(Questie.db.char.daily) do
            Questie.db.char.daily[questId] = nil
            Questie.db.char.complete[questId] = nil
        end
        Questie.db.profile.dailyResetTime = nil
        QuestieCompat.CalculateNextResetTime()
        if Questie.started then
            AvailableQuests.CalculateAndDrawAll()
        end
    end
end

local weeklyResetTimer
function QuestieCompat.ResetWeeklyQuests()
    local currentTime = QuestieCompat.GetServerTime()
    local timeUntilReset = Questie.db.profile.weeklyResetTime - currentTime

    if timeUntilReset < 1800 then
        if weeklyResetTimer then
            weeklyResetTimer = weeklyResetTimer:Cancel()
        end

        weeklyResetTimer = weeklyResetTimer or QuestieCompat.C_Timer.After(timeUntilReset, function()
            for questId in pairs(Questie.db.char.weekly) do
                Questie.db.char.weekly[questId] = nil
                Questie.db.char.complete[questId] = nil
            end
            Questie.db.profile.weeklyResetTime = nil
            QuestieCompat.CalculateNextResetTime()
            if Questie.started then
                AvailableQuests.CalculateAndDrawAll()
            end
        end)

        return true
    end
end

function QuestieCompat.SetQuestComplete(questId)
    if (not QuestieDB.IsRepeatable(questId)) then
        Questie.db.char.complete[questId] = true
    end

    if Questie.db.profile.resetDailyQuests then
        if QuestieDB.IsDailyQuest(questId) then
            Questie.db.char.daily[questId] = true
            Questie.db.char.complete[questId] = true
        elseif QuestieDB.IsWeeklyQuest(questId) then
            Questie.db.char.weekly[questId] = true
            Questie.db.char.complete[questId] = true
        end
    end
end

-- Returns a list of quests the character has completed in its lifetime.
-- https://wowpedia.fandom.com/wiki/API_GetQuestsCompleted
function QuestieCompat.GetQuestsCompleted()
    if not Questie.db.char.complete then
        Questie.db.char.complete = {}
    end

    QueryQuestsCompleted()
    return Questie.db.char.complete
end

-- Fires when the data requested by QueryQuestsCompleted() is available.
-- https://wowpedia.fandom.com/wiki/QUEST_QUERY_COMPLETE
function QuestieCompat:QUEST_QUERY_COMPLETE(event)
    GetQuestsCompleted(Questie.db.char.complete)

    for questId in pairs(Questie.db.char.complete) do
        if QuestieDB.IsRepeatable(questId) then
            Questie.db.char.complete[questId] = nil
        end
    end

    if Questie.db.profile.resetDailyQuests then
        QuestieCompat.CalculateNextResetTime()
        QuestieCompat.ResetDailyQuests()
        QuestieCompat.Merge(Questie.db.char.complete, Questie.db.char.daily)

        if Questie.IsWotlk and QuestiePlayer.GetPlayerLevel() >= 78 then
            if (not QuestieCompat.ResetWeeklyQuests()) and (Questie.db.profile.weeklyResetDay == CalendarGetDate()) then
                weeklyResetTimer = weeklyResetTimer or QuestieCompat.C_Timer.NewTicker(1800, QuestieCompat.ResetWeeklyQuests)
            end
            QuestieCompat.Merge(Questie.db.char.complete, Questie.db.char.weekly)
        end
    end
end

-- https://wowpedia.fandom.com/wiki/API_IsQuestFlaggedCompleted
-- Determine if a quest has been completed.
function QuestieCompat.IsQuestFlaggedCompleted(questID)
	return Questie.db.char.complete[questID] or false
end

---Returns the available quests at a quest giver.
-- https://wowpedia.fandom.com/wiki/API_GetGossipAvailableQuests
function QuestieCompat.GetAvailableQuests()
	local availableQuests = {GetGossipAvailableQuests()}
	local numAvailable = GetNumGossipAvailableQuests()
	for i = 1, numAvailable do
		local index = (i - 1) * 5
		availableQuests[index + 3] = availableQuests[index + 3] and true or false
		availableQuests[index + 4] = availableQuests[index + 4] and 2 or 1
		availableQuests[index + 5] = availableQuests[index + 5] and true or false
	end
    for i = 1, numAvailable do
		local index = (i - 1) * 7
		table.insert(availableQuests, index + 6, false)
		table.insert(availableQuests, index + 7, false)
	end
	return unpack(availableQuests)
end

-- Returns the quests which can be turned in at a quest giver.
-- https://wowpedia.fandom.com/wiki/API_GetGossipActiveQuests
function QuestieCompat.GetActiveQuests()
	local activeQuests = {GetGossipActiveQuests()}
	local numActive = GetNumGossipActiveQuests()
	for i = 1, numActive do
		local index = (i - 1) * 4
		activeQuests[index + 3] = activeQuests[index + 3] and true or false
		activeQuests[index + 4] = activeQuests[index + 4] and true or false
	end
    for i = 1, numActive do
		local index = (i - 1) * 6
		table.insert(activeQuests, index + 5, false)
		table.insert(activeQuests, index + 6, false)
	end
	return unpack(activeQuests)
end

local questTagToName = {
	[1] = "Group",
	[41] = "PvP",
	[62] = "Raid",
	[81] = "Dungeon",
	[82] = "World Event",
	[83] = "Legendary",
	[84] = "Escort",
	[85] = "Heroic",
}

-- Retrieves tag information about the quest.
-- https://wowpedia.fandom.com/wiki/API_GetQuestTagInfo
function QuestieCompat.GetQuestTagInfo(questId)
    local tagId = QuestieCompat.QuestTag[questId]
	if tagId then
		return tagId, questTagToName[tagId]
	end
end

-- Returns the ID of the displayed quest at a quest giver.
-- https://wowpedia.fandom.com/wiki/API_GetQuestID
function QuestieCompat.GetQuestID(questStarter, title)
    local title = title or GetTitleText()
    local guid = QuestieCompat.UnitGUID("npc")

	return QuestieDB.GetQuestIDFromName(title, guid, questStarter)
end

function QuestieCompat.GetQuestIDFromName(questTitle)
    for questLogIndex = 1, MAX_QUEST_LOG_INDEX do
        local title, _, _, _, isHeader, _, _, _, id = GetQuestLogTitle(questLogIndex)
        if (not title) then
            break -- We exceeded the valid quest log entries
        end
        if (not isHeader) then
            if (questTitle == title) then
                return id
            end
        end
    end
end

-- https://wowwiki-archive.fandom.com/wiki/API_UnitGUID?oldid=2368080
local GUIDType = {
    [0]="Player",
    [1]="GameObject",
    [3]="Creature",
    [4]="Pet",
    [5]="Vehicle"
}

-- Returns the GUID of the unit.
-- https://wowpedia.fandom.com/wiki/GUID
-- Patch 6.0.2 (2014-10-14): Changed to a new format
function QuestieCompat.UnitGUID(unit)
    local guid = UnitGUID(unit)
    if guid then
        local type = tonumber(guid:sub(5,5), 16) % 8
        if type and (type == 1 or type == 3 or type == 5) then
            local id = tonumber(guid:sub(6, 12), 16)
            -- Creature-0-[serverID]-[instanceID]-[zoneUID]-[npcID]-[spawnUID]
            return string.format("%s-0-4170-0-41-%d-00000F4B37", GUIDType[type], id)
        end
    end
end

function QuestieCompat.GetMaxPlayerLevel()
    return (Questie.IsWotlk and 80) or (Questie.IsTBC and 70) or (Questie.IsClassic and 60)
end

-- https://wowpedia.fandom.com/wiki/API_UnitAura?oldid=2681338
-- Returns the buffs/debuffs for the unit.
-- an alias for UnitAura(unit, index, "HELPFUL"), returning only buffs.
-- Patch 8.0.1 (2018-07-17): Removed 'rank' return value.
function QuestieCompat.UnitBuff(unit, index)
    local name, rank, icon, count, debuffType, duration, expirationTime,
        unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff(unit, index)
    return name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId
end

-- Returns the race of the unit.
-- https://wowpedia.fandom.com/wiki/API_UnitRace
function QuestieCompat.UnitRace(unit)
    local raceName, raceFile = UnitRace(unit)
    return raceName, raceFile, QuestieCompat.ChrRaces[raceFile]
end

-- Returns the class of the unit.
-- https://wowpedia.fandom.com/wiki/API_UnitClass
-- Patch 5.0.4 (2012-08-28): Added classId return value.
function QuestieCompat.UnitClass(unit)
    local className, classFile = UnitClass(unit)
    return className, classFile, QuestieCompat.ChrClasses[classFile]
end

-- Returns info for a faction.
-- https://wowpedia.fandom.com/wiki/API_GetFactionInfo
-- Patch 5.0.4 (2012-08-28): Added new return value: factionID
-- TODO: localize factions name(https://www.curseforge.com/wow/addons/libbabble-faction-3-0)
function QuestieCompat.GetFactionInfo(factionIndex)
    local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
        canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)

    return name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
        canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, QuestieCompat.FactionId[name:trim()]
end

-- Returns true if the unit is a member of your party
-- https://wowpedia.fandom.com/wiki/API_UnitInParty
-- As of 2.0.3, UnitInParty("player") always returns 1, even when you are not in a party.
function QuestieCompat.UnitInParty(unit)
    if unit == "player" then
        return QuestieCompat.IsInGroup()
    end
    return UnitInParty(unit)
end

-- Returns true if the player is in a group.
-- https://wowpedia.fandom.com/wiki/API_IsInGroup
function QuestieCompat.IsInGroup(groupType)
    if groupType then return false end
    return UnitInParty("player") and GetNumPartyMembers() > 0
end

-- Returns true if the player is in a raid.
-- https://wowpedia.fandom.com/wiki/API_IsInRaid
function QuestieCompat.IsInRaid(groupType)
    if groupType then return false end
    return UnitInRaid("player") and GetNumRaidMembers() > 0
end

-- Returns names of characters in your home (non-instance) party.
-- https://wowpedia.fandom.com/wiki/API_GetHomePartyInfo
function QuestieCompat.GetHomePartyInfo(homePlayers)
	if QuestieCompat.UnitInParty("player") then
		homePlayers = homePlayers or {}
		for i=1, MAX_PARTY_MEMBERS do
			if GetPartyMember(i) then
				table.insert(homePlayers, UnitName("party"..i))
			end
		end
		return homePlayers
	end
end

-- Gets a list of the auction house item classes.
-- https://wowpedia.fandom.com/wiki/API_GetAuctionItemClasses?oldid=1835520
local itemClass = {GetAuctionItemClasses()}
for classId, className in ipairs(itemClass) do
    itemClass[className] = classId
    itemClass[classId] = nil
end

-- Returns info for an item.
-- https://wowpedia.fandom.com/wiki/API_GetItemInfo?oldid=2376031
-- Patch 7.0.3 (2016-07-19): Added classID, subclassID returns.
function QuestieCompat.GetItemInfo(item)
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount,itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item)

    return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount,itemEquipLoc, itemTexture, itemSellPrice, itemClass[itemType]
end

-- Returns info for an item in a container slot.
-- https://wowpedia.fandom.com/wiki/API_GetContainerItemInfo
function QuestieCompat.GetContainerItemInfo(bagID, slot)
	local iconFile, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink = GetContainerItemInfo(bagID, slot)
    if hyperlink then
	    local itemID = string.match(hyperlink, "(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+)")
	    -- GetContainerItemInfo does not return a quality value for all items.  If it does not, it returns -1
	    if quality and quality < 0 then
	    	quality = (select(3, GetItemInfo(hyperlink)))
	    end

	    return iconFile, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, false, false, tonumber(itemID), false
    end
end

-- https://wowpedia.fandom.com/wiki/API_IsSpellKnown
QuestieCompat.IsSpellKnownOrOverridesKnown = IsSpellKnown
QuestieCompat.IsPlayerSpell = IsSpellKnown

local LARGE_NUMBER_SEPERATOR = ".";
function QuestieCompat.FormatLargeNumber(amount)
	amount = tostring(amount);
	local newDisplay = "";
	local strlen = amount:len();
	--Add each thing behind a comma
	for i=4, strlen, 3 do
		newDisplay = LARGE_NUMBER_SEPERATOR..amount:sub(-(i - 1), -(i - 3))..newDisplay;
	end
	--Add everything before the first comma
	newDisplay = amount:sub(1, (strlen % 3 == 0) and 3 or (strlen % 3))..newDisplay;
	return newDisplay;
end

local function Round(value)
	if value < 0.0 then
		return math.ceil(value - .5);
	end
	return math.floor(value + .5);
end
QuestieCompat.Round = Round

local function GenerateHexColor(r, g, b, a)
	return ("ff%.2x%.2x%.2x"):format(Round(r * 255), Round(g * 255), Round(b * 255), Round((a or 1) * 255));
end

-- Returns the color value associated with a given class.
function QuestieCompat.GetClassColor(classFilename)
	local color = RAID_CLASS_COLORS[classFilename];
	if color then
		return color.r, color.g, color.b, GenerateHexColor(color.r, color.g, color.b)
	end
	return 1, 1, 1, "ffffffff";
end

-- handle tooltip based on the parent frame
function QuestieCompat.SetupTooltip(frame, OnHide)
    if (frame:GetParent() == WorldMapFrame) then
        WorldMapPOIFrame.allowBlobTooltip = OnHide and true or false
        QuestieCompat.Tooltip = WorldMapTooltip
    else
        QuestieCompat.Tooltip = GameTooltip
    end
    return QuestieCompat.Tooltip
end

local wrappedLines = {}
-- tooltip word wrapping looks fine the way it is, leave it for now
function QuestieCompat.TextWrap(self, line, prefix, combineTrailing, desiredWidth)
    QuestieCompat.Tooltip:AddLine(line, 0.86, 0.86, 0.86, 1);
    return wrappedLines
end

local unboundedFS = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
unboundedFS:SetPoint("TOPLEFT", 0, 0)
unboundedFS:Hide()

-- The minimum width necessary to contain the entire text without truncation
-- https://wowpedia.fandom.com/wiki/API_FontString_GetStringWidth
function QuestieCompat.GetUnboundedStringWidth(self)
    unboundedFS:SetWidth(0)
    unboundedFS:SetFont(self:GetFont())
    unboundedFS:SetText(self:GetText())

    return unboundedFS:GetStringWidth()
end

-- Number of lines of wrapped text
-- https://wowpedia.fandom.com/wiki/API_FontString_GetNumLines
function QuestieCompat.GetNumLines(self)
    local fontName, fontHeight, fontFlags = self:GetFont()
    unboundedFS:SetWidth(self:GetWidth())
    unboundedFS:SetFont(fontName, fontHeight, fontFlags)
    unboundedFS:SetText(self:GetText())

	return math.ceil(unboundedFS:GetHeight()/fontHeight)
end

-- texture			- Texture
-- canvasFrame      - Canvas Frame (for anchoring)
-- startX,startY    - Coordinate of start of line
-- endX,endY		- Coordinate of end of line
-- lineWidth        - Width of line
-- relPoint			- Relative point on canvas to interpret coords (Default BOTTOMLEFT)
local function DrawLine(texture, canvasFrame, startX, startY, endX, endY, lineWidth, lineFactor, relPoint)
	if (not relPoint) then relPoint = "BOTTOMLEFT"; end
	lineFactor = lineFactor * .5;

	-- Determine dimensions and center point of line
	local dx,dy = endX - startX, endY - startY;
	local cx,cy = (startX + endX) / 2, (startY + endY) / 2;

	-- Normalize direction if necessary
	if (dx < 0) then
		dx,dy = -dx,-dy;
	end

	-- Calculate actual length of line
	local lineLength = sqrt((dx * dx) + (dy * dy));

	-- Quick escape if it'sin zero length
	if (lineLength == 0) then
        texture:ClearAllPoints();
		texture:SetTexCoord(0,0,0,0,0,0,0,0);
		texture:SetPoint("BOTTOMLEFT", canvasFrame, relPoint, cx,cy);
		texture:SetPoint("TOPRIGHT",   canvasFrame, relPoint, cx,cy);
		return;
	end

	-- Sin and Cosine of rotation, and combination (for later)
	local sin, cos = -dy / lineLength, dx / lineLength;
	local sinCos = sin * cos;

	-- Calculate bounding box size and texture coordinates
	local boundingWidth, boundingHeight, bottomLeftX, bottomLeftY, topLeftX, topLeftY, topRightX, topRightY, bottomRightX, bottomRightY;
	if (dy >= 0) then
		boundingWidth = ((lineLength * cos) - (lineWidth * sin)) * lineFactor;
		boundingHeight = ((lineWidth * cos) - (lineLength * sin)) * lineFactor;

		bottomLeftX = (lineWidth / lineLength) * sinCos;
		bottomLeftY = sin * sin;
		bottomRightY = (lineLength / lineWidth) * sinCos;
		bottomRightX = 1 - bottomLeftY;

		topLeftX = bottomLeftY;
		topLeftY = 1 - bottomRightY;
		topRightX = 1 - bottomLeftX;
		topRightY = bottomRightX;
	else
		boundingWidth = ((lineLength * cos) + (lineWidth * sin)) * lineFactor;
		boundingHeight = ((lineWidth * cos) + (lineLength * sin)) * lineFactor;

		bottomLeftX = sin * sin;
		bottomLeftY = -(lineLength / lineWidth) * sinCos;
		bottomRightX = 1 + (lineWidth / lineLength) * sinCos;
		bottomRightY = bottomLeftX;

		topLeftX = 1 - bottomRightX;
		topLeftY = 1 - bottomLeftX;
		topRightY = 1 - bottomLeftY;
		topRightX = topLeftY;
	end

	-- Set texture coordinates and anchors
	texture:ClearAllPoints();
	texture:SetTexCoord(topLeftX, topLeftY, bottomLeftX, bottomLeftY, topRightX, topRightY, bottomRightX, bottomRightY);
	texture:SetPoint("BOTTOMLEFT", canvasFrame, relPoint, cx - boundingWidth, cy - boundingHeight);
	texture:SetPoint("TOPRIGHT",   canvasFrame, relPoint, cx + boundingWidth, cy + boundingHeight);
end

-- Mix this into a Texture to be able to treat it like a line
local LineMixin = {};

function LineMixin:SetStartPoint(relPoint, x, y)
	self.startX, self.startY = x, y;
end

function LineMixin:SetEndPoint(relPoint, x, y)
	self.endX, self.endY = x, y;
end

function LineMixin:SetThickness(thickness)
	self.thickness = thickness;
end

function LineMixin:Draw()
	local parent = self:GetParent();
	local x, y = parent:GetLeft(), parent:GetBottom();

	self:ClearAllPoints();
	DrawLine(self, parent, self.startX - x, self.startY - y, self.endX - x, self.endY - y, self.thickness or 32, 1);
end

local function drawLineOnShow(self)
    local line = self.line
    DrawLine(line, self, line.startX, line.startY, line.endX, line.endY, line.thickness*15, 1.2, "TOPLEFT");
end

local stub_line = setmetatable({}, QuestieCompat.NOOP_MT)
-- https://wowpedia.fandom.com/wiki/API_Frame_CreateLine
function QuestieCompat.CreateLine(self)
    if self.line then return stub_line end -- stub lineBorder, as our line texture already has border

    local line = self:CreateTexture(nil, "OVERLAY")
    line:SetTexture(QuestieLib.AddonPath.."Compat\\Icons\\Waypoint-Line.blp")
    line.SetColorTexture = line.SetVertexColor

    for k,v in pairs(LineMixin) do
        line[k] = v
    end

    self:SetScript("OnShow", drawLineOnShow)

    return line
end

QuestieCompat.LibUIDropDownMenu = {
	Create_UIDropDownMenu = function(self, name, parent)
		return CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
	end,
	EasyMenu = function(self, menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
		EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
	end,
	CloseDropDownMenus = function(self, level)
        CloseDropDownMenus(level)
    end,
}

QuestieCompat.KButtons = {
    Add = function(self, templateName, templateType)
        local button = CreateFrame("Button", "Questie_WorldMapButton", WorldMapFrame)
        button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        button:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT", -4, -2);
        button:SetFrameLevel(99)
        button:SetSize(32, 32)
        button:RegisterForClicks("anyUp")
        button:SetScript("OnMouseDown", QuestieWorldMapButtonMixin.OnMouseDown)
        button:SetScript("OnEnter", QuestieWorldMapButtonMixin.OnEnter)
        button:SetScript("OnLeave", function(self) QuestieCompat.SetupTooltip(self, true):Hide() end)

        local background = button:CreateTexture(nil, "BACKGROUND")
        background:SetSize(25, 25)
        background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
        background:SetPoint("TOPLEFT", 2, -4)

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetTexture(QuestieLib.AddonPath.."Icons\\complete.blp")
        icon:SetPoint("TOPLEFT", 6, -5)

        local border = button:CreateTexture(nil, "OVERLAY")
        border:SetSize(54, 54)
        border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        border:SetPoint("TOPLEFT")

        return button
    end,
}

--[[
    xpcall wrapper implementation
]]
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
	local code = [[
		local xpcall, errorhandler = ...
		local method, ARGS
		local function call() return method(ARGS) end

		local function dispatch(func, eh, ...)
			 method = func
			 if not method then return end
			 ARGS = ...
			 return xpcall(call, eh or errorhandler)
		end

		return dispatch
	]]

	local ARGS = {}
	for i = 1, argCount do ARGS[i] = "arg"..i end
	code = code:gsub("ARGS", table.concat(ARGS, ", "))
	return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher = CreateDispatcher(argCount)
	rawset(self, argCount, dispatcher)
	return dispatcher
end})

Dispatchers[0] = function(func, eh)
	return xpcall(func, eh or errorhandler)
end

function QuestieCompat.xpcall(func, eh, ...)
    if type(func) == "function" then
		return Dispatchers[select('#', ...)](func, eh, ...)
	end
end

--[[
    It seems that the table size is capped in 3.3.5, with a maximum of 524,288 entries.
    For instance, this code triggers an error message: 'memory allocation error: block too big.

    local t = {}
	for i=1, 524289 do
		t[i] = true
	end

    Spliting the table into multiple subtables should do the trick.
]]

local stringchar = string.char
local MAX_TABLE_SIZE = 524288

function QuestieCompat._writeByte(self, val)
	local subIndex = math.ceil(self._pointer / MAX_TABLE_SIZE)
	local index = self._pointer - (subIndex - 1) * MAX_TABLE_SIZE

	self._bin[subIndex] = self._bin[subIndex] or {}
	self._bin[subIndex][index] = stringchar(val)

    self._pointer = self._pointer + 1
end

function QuestieCompat._readByte(self)
	local subIndex = math.ceil(self._pointer / MAX_TABLE_SIZE)
	local index = self._pointer - (subIndex - 1) * MAX_TABLE_SIZE

    self._pointer = self._pointer + 1

	return self._bin[subIndex][index]
end

function QuestieCompat.Save(self)
	local result = ""
	for i=1, #self._bin do
		result = result .. table.concat(self._bin[i])
	end
	return result
end

local _QuestieNameplate = QuestieNameplate.private
local npFrames = {}
local npActiveQuestNPCs = {}
local npBorderTexture = "Interface\\Tooltips\\Nameplate-Border"

local function isNamePlate(frame)
    if frame.UnitFrame  -- ElvUI
    or frame.extended   -- TidyPlates
    or frame.aloftData  -- Aloft
    or frame.kui  -- Kui_Nameplate
    then return true end

    local _, borderRegion = frame:GetRegions()
    if borderRegion and borderRegion:GetObjectType() == "Texture" then
        return borderRegion:GetTexture() == npBorderTexture
    end

    return false
end

local function scanWorldFrameChildren(frame, ...)
	if not frame then return end

	if not npFrames[frame] and isNamePlate(frame) then
        npFrames[frame] = select(7, frame:GetRegions())

        frame:HookScript("OnShow", QuestieCompat.NameplateCreated)
        frame:HookScript("OnHide", _QuestieNameplate.RemoveFrame)

        if frame:IsShown() then
		    QuestieCompat.NameplateCreated(frame)
        end
	end
	return scanWorldFrameChildren(...)
end

function QuestieCompat.NameplateCreated(frame)
    local name = npFrames[frame]:GetText()
    local key = npActiveQuestNPCs[name]
    if key then
        local icon = _QuestieNameplate.GetValidIcon(QuestieTooltips.lookupByKey[key])

        if icon then
            local f = _QuestieNameplate.GetFrame(frame)
            f.Icon:SetTexture(icon)
            f.lastIcon = icon -- this is used to prevent updating the texture when it's already what it needs to be
            f:Show()
        end
    end
end

function QuestieCompat.UpdateNameplate()
    for frame in pairs(npFrames) do
        local name = npFrames[frame]:GetText()
        local key = npActiveQuestNPCs[name]

        local icon = _QuestieNameplate.GetValidIcon(QuestieTooltips.lookupByKey[key])

        if icon then
            local f = _QuestieNameplate.GetFrame(frame)
            -- check if the texture needs to be changed
            if f.lastIcon ~= icon then
                f.lastIcon = icon
                f.Icon:SetTexture(icon)
            end
        else
            -- tooltip removed but we still have the frame active, remove it
            _QuestieNameplate.RemoveFrame(frame)
        end
    end
end

function QuestieCompat:QuestieTooltips_RegisterObjectiveTooltip(questId, key, objective)
    if key:find("m_") then
        local name = QuestieDB.QueryNPCSingle(tonumber(key:sub(3)), "name")
        npActiveQuestNPCs[name] = key
    end
end

local _EventHandler = QuestieEventHandler.private
local chatMessagePattern = {
    questInfo = {
        ERR_QUEST_OBJECTIVE_COMPLETE_S,
	    ERR_QUEST_UNKNOWN_COMPLETE,
	    ERR_QUEST_ADD_KILL_SII,
	    ERR_QUEST_ADD_FOUND_SII,
	    ERR_QUEST_ADD_ITEM_SII,
	    ERR_QUEST_ADD_PLAYER_KILL_SII,
	    ERR_QUEST_FAILED_S,
    },
    playerLoot = {
        LOOT_ITEM_CREATED_SELF,
        LOOT_ITEM_CREATED_SELF_MULTIPLE,
        LOOT_ITEM_PUSHED_SELF,
        LOOT_ITEM_PUSHED_SELF_MULTIPLE,
        LOOT_ITEM_SELF,
        LOOT_ITEM_SELF_MULTIPLE,
    }
}

-- parse chat message for quest related info
function QuestieCompat.UiInfoMessage(event, message)
    for _, pattern in pairs(chatMessagePattern.questInfo) do
        if string.find(message, pattern) then
            local objectiveName, numFulfilled = parseQuestObjective(message)
            if objectiveName and numFulfilled then
                questObjectivesCache[objectiveName] = numFulfilled
            end
            MinimapIcon:UpdateText(message)
        end
    end
end

-- parse chat message for player looting an item
local playerName = UnitName("player")
local emptyName = ""
function QuestieCompat.ChatMessageLoot(message)
    for _, pattern in pairs(chatMessagePattern.playerLoot) do
        if string.find(message, pattern) then
            return playerName
        end
    end
    return emptyName
end

-- handle remote questlog of the party/raid
function QuestieCompat.GroupRosterUpdate(event)
    local currentMembers = QuestieCompat.IsInRaid() and GetNumRaidMembers() or GetNumPartyMembers()
    -- Only want to do logic when number increases, not decreases.
    if QuestiePlayer.numberOfGroupMembers < currentMembers then
        if QuestiePlayer.numberOfGroupMembers == 0 then
            _EventHandler:GroupJoined()
        end
        -- Tell comms to send information to members.
        --Questie:SendMessage("QC_ID_BROADCAST_FULL_QUESTLIST")
        QuestiePlayer.numberOfGroupMembers = currentMembers
    else
        if currentMembers == 0 then
            _EventHandler:GroupLeft()
        end
        -- We do however always want the local to be the current number to allow up and down.
        QuestiePlayer.numberOfGroupMembers = currentMembers
    end
end

function QuestieCompat.QuestieEventHandler_RegisterLateEvents()
    -- In fullscreen mode, WorldMap intercepts keyboard input,
    -- preventing the MODIFIER_STATE_CHANGED event
    if WorldMapFrame:GetScript("OnKeyDown") then
        local modifierStateChanged
        WorldMapFrame:HookScript("OnKeyDown", function(self, key)
            if IsModifierKeyDown() then
                _EventHandler:ModifierStateChanged(key, 1)
                modifierStateChanged = true
            end
        end)
        WorldMapFrame:HookScript("OnKeyUp", function(self, key)
            if modifierStateChanged then
                _EventHandler:ModifierStateChanged(key, 0)
                modifierStateChanged = nil
            end
        end)
    end

    Questie:UnregisterEvent("MAP_EXPLORATION_UPDATED") -- https://wowpedia.fandom.com/wiki/MAP_EXPLORATION_UPDATED
    Questie:UnregisterEvent("NEW_RECIPE_LEARNED")

    -- Party join event for QuestieComms, Use bucket to hinder this from spamming (Ex someone using a raid invite addon etc)
    Questie:UnregisterEvent("GROUP_ROSTER_UPDATE") -- https://wowpedia.fandom.com/wiki/GROUP_ROSTER_UPDATE
    Questie:UnregisterEvent("GROUP_JOINED") -- https://wowpedia.fandom.com/wiki/GROUP_JOINED
    Questie:UnregisterEvent("GROUP_LEFT") -- https://wowpedia.fandom.com/wiki/GROUP_LEFT
    Questie:RegisterEvent("PARTY_MEMBERS_CHANGED", QuestieCompat.GroupRosterUpdate)
    Questie:RegisterBucketEvent("RAID_ROSTER_UPDATE", 1, QuestieCompat.GroupRosterUpdate)

    -- Nameplate / Target Frame Objective Events
    Questie:UnregisterEvent("NAME_PLATE_UNIT_ADDED") -- https://wowpedia.fandom.com/wiki/NAME_PLATE_UNIT_ADDED
    Questie:UnregisterEvent("NAME_PLATE_UNIT_REMOVED") -- https://wowpedia.fandom.com/wiki/NAME_PLATE_UNIT_REMOVED

    if Questie.db.profile.nameplateEnabled then
        QuestieNameplate.UpdateNameplate = QuestieCompat.UpdateNameplate
        hooksecurefunc(QuestieQuest, "GetAllQuestIds", QuestieCompat.UpdateNameplate)
        hooksecurefunc(QuestieTooltips, "RegisterObjectiveTooltip", QuestieCompat.QuestieTooltips_RegisterObjectiveTooltip)

        local lastNumChildren
        QuestieCompat.C_Timer.NewTicker(0.1, function()
            local numChildren = WorldFrame:GetNumChildren()
            if numChildren ~= lastNumChildren then
                lastNumChildren = numChildren
                scanWorldFrameChildren(WorldFrame:GetChildren())
            end
        end)
    end
end

local _QuestEventHandler = QuestEventHandler.private
local QUEST_COMPLETE_MSG = string.gsub(ERR_QUEST_COMPLETE_S, "(%%s)", "(.+)")
local completeQuestCache = {}

local DAILY_QUESTS_MSG = DAILY_QUESTS_REMAINING:gsub("%%d", "(%%d+)"):gsub("|4(.-)$", "")

function QuestieCompat:CHAT_MSG_SYSTEM(event, message)
    local questName = message:match(QUEST_COMPLETE_MSG)
    local questId = completeQuestCache[questName]
    if questId then
        _QuestEventHandler:QuestTurnedIn(questId)
        _QuestEventHandler:QuestRemoved(questId)
        completeQuestCache[questName] = nil
    end

    if Questie.db.profile.resetDailyQuests then
        local dailyQuestCount = tonumber(message:match(DAILY_QUESTS_MSG))
        if dailyQuestCount and (dailyQuestCount == GetMaxDailyQuests()) then
            QuestieCompat.C_Timer.After(1, function()
                QuestieCompat.ResetDailyQuests(true)
            end)
        end
    end
end

function QuestieCompat.QuestEventHandler_RegisterEvents()
    QuestieCompat.frame:RegisterEvent("QUEST_QUERY_COMPLETE")
    QuestieCompat.frame:RegisterEvent("CHAT_MSG_SYSTEM")

    -- https://wowpedia.fandom.com/wiki/PLAYER_INTERACTION_MANAGER_FRAME_HIDE
    QuestieQuestEventFrame:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
    for _, event in pairs({
        "TRADE_CLOSED",
        "MERCHANT_CLOSED",
        "BANKFRAME_CLOSED",
        "GUILDBANKFRAME_CLOSED",
        "VENDOR_CLOSED",
        "MAIL_CLOSED",
        "AUCTION_HOUSE_CLOSED",
    }) do
        QuestieCompat.frame:RegisterEvent(event)
        QuestieCompat[event] = _QuestEventHandler.QuestRelatedFrameClosed
    end

    -- https://wowpedia.fandom.com/wiki/QUEST_TURNED_IN
    QuestieQuestEventFrame:UnregisterEvent("QUEST_TURNED_IN")
    hooksecurefunc("GetQuestReward", function(itemChoice)
        local questTitle = GetTitleText()
        local questId = QuestieCompat.GetQuestIDFromName(questTitle)
        if questId and questId > 0 then
            completeQuestCache[questTitle] = questId
        end
    end)

    hooksecurefunc("SetAbandonQuest", function()
        QuestieCompat.abandonQuestID = select(9, GetQuestLogTitle(GetQuestLogSelection()))
    end)

    --https://wowpedia.fandom.com/wiki/QUEST_REMOVED
    QuestieQuestEventFrame:UnregisterEvent("QUEST_REMOVED")
    hooksecurefunc("AbandonQuest", function()
        local questId = QuestieCompat.abandonQuestID or select(9, GetQuestLogTitle(GetQuestLogSelection()))
        _QuestEventHandler:QuestRemoved(QuestieCompat.abandonQuestID)
    end)
end

function QuestieCompat.QuestieTracker_Initialize(trackerQuestFrame)
    -- TrackerHeaderFrame.Initialize
    Questie_HeaderFrame.trackedQuests.label.GetUnboundedStringWidth = QuestieCompat.GetUnboundedStringWidth
    -- TrackerQuestFrame.Initialize
    trackerQuestFrame.ScrollFrame.scrollBarHideable = true
    trackerQuestFrame.ScrollBar:ClearAllPoints()
    trackerQuestFrame.ScrollBar:SetPoint("TOPRIGHT", trackerQuestFrame.ScrollUpButton, "BOTTOMRIGHT", -1, 4)
    trackerQuestFrame.ScrollBar:SetPoint("BOTTOMRIGHT", trackerQuestFrame.ScrollDownButton, "TOPRIGHT", -1, -4)
    trackerQuestFrame.ScrollDownButton:SetPoint("BOTTOMRIGHT", trackerQuestFrame.ScrollFrame, "BOTTOMRIGHT", -4, 12)
    trackerQuestFrame.ScrollBg:SetTexture(0, 0, 0, 0.35)
    trackerQuestFrame.ScrollBg:Show()
    trackerQuestFrame.ScrollBar.Show = function() end
    -- TrackerLinePool.Initialize
    for i = 1, 250 do
        local line = _G["linePool" .. i]
        line.label.GetUnboundedStringWidth = QuestieCompat.GetUnboundedStringWidth
        line.label.GetWrappedWidth = line.label.GetWidth
        line.label.GetNumLines = QuestieCompat.GetNumLines
    end
end

-- prevents the override of existing global variables with the same name(e.g., WorldMapButton)
function QuestieCompat.PopulateGlobals(self)
    for name, module in pairs(QuestieLoader._modules) do
        if not _G[name] then
            _G[name] = module
        end
    end
end

-- change sound files extension from .ogg to .wav
function QuestieCompat.GetSelectedSoundFile(typeSelected)
    return QuestieCompat.orig_GetSelectedSoundFile(typeSelected):gsub("[^.]+$", "wav")
end

QuestieCompat.isReloadingUi = false
function QuestieCompat.OnReloadUi(command)
	command = command or "reloadui"
	if (command == "reloadui") then
		Questie.db.profile.isInitialLogin = false
		QuestieCompat.isReloadingUi = true
	end
end

-- disable builtin quest progress tooltips, re-enable on logout
function QuestieCompat:ToggleQuestTrackingTooltips(event)
    local value = tostring(event:find("LOGOUT") and 1 or 0)
    SetCVar("showQuestTrackingTooltips", value)
end
QuestieCompat.PLAYER_LOGIN = QuestieCompat.ToggleQuestTrackingTooltips

function QuestieCompat:PLAYER_LOGOUT(event)
	if not QuestieCompat.isReloadingUi then
		QuestieCompat:ToggleQuestTrackingTooltips(event)
		
		Questie.db.profile.isInitialLogin = true
	end
end

local townsfolk_texturemap = {
    ["Ammo"] = "Interface\\Icons\\inv_ammo_arrow_02",
    ["Bags"] = "Interface\\Icons\\inv_misc_bag_09",
    ["Potions"] = "Interface\\Icons\\inv_potion_51",
    ["Trade Goods"] ="Interface\\Icons\\inv_fabric_wool_02",
    ["Drink"] = "Interface\\Icons\\inv_potion_01",
    ["Food"] = "Interface\\Icons\\inv_misc_food_11",
    ["Pet Food"] = "Interface\\Icons\\ability_hunter_beasttraining",
    ["Spirit Healer"] = "Interface\\Addons\\"..QuestieCompat.addonName.."\\Compat\\Icons\\Raid-Icon-Rez.blp",
    ["Portal Trainer"] = "Interface\\Addons\\"..QuestieCompat.addonName.."\\Compat\\Icons\\Vehicle-AllianceMagePortal.blp",
}

StaticPopupDialogs["QUESTIE_RELOAD"] = {
    text = "Changes you have made require a UI reload",
    button1 = 'Reload UI',
    button2 = CANCEL,
    OnAccept = function()
        ReloadUI()
    end,
    OnShow = function(self)
        self:SetFrameStrata("TOOLTIP")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

function QuestieCompat.QuestieOptions_Initialize()
    QuestieCompat.orig_QuestieOptions_Initialize()

    local optionsTable = LibStub("AceConfigRegistry-3.0"):GetOptionsTable("Questie", "dialog", "MyLib-1.0")

    -- revert instant quest text to old cvar
    optionsTable.args.general_tab.args.interface_options_group.args.instantQuest.get = function()
        return GetCVar("questFadingDisable") == '1' and true or false
    end
    optionsTable.args.general_tab.args.interface_options_group.args.instantQuest.set = function(info, value)
        QUEST_FADING_DISABLE = tostring(value and 1 or 0)
        SetCVar("questFadingDisable", tostring(value and 1 or 0))
    end

    optionsTable.args.nameplate_tab.args.nameplate_options_group.args.nameplateEnabled.set = function (info, value)
        QuestieOptions:SetProfileValue(info, value)
        StaticPopup_Show("QUESTIE_RELOAD")
    end

    -- disable settings for not implemented functionality
    Questie.db.profile.hideUnexploredMapIcons = false
    optionsTable.args.icons_tab.args.map_settings_group.args.hideUnexploredMapIconsToggle.disabled = true

    -- 3.3.5 section
    optionsTable.args.advanced_tab.args.compat_header = {
        type = "header",
        order = 6,
        name = "3.3.5 Compatibility Settings",
    }
	
	optionsTable.args.advanced_tab.args.initDelay = {
        type = "range",
        order = 6.1,
        name = "Init rate delay",
        desc = "Init rate delay",
        width = "full",
        min = 0.1,
        max = 1,
        step = 0.01,
        hidden = function() return not Questie.db.profile.debugEnabled; end,
        get = function(info) return QuestieOptions:GetProfileValue(info)*10; end,
        set = function (info, value)
            QuestieOptions:SetProfileValue(info, value/10)
        end,
    }

    optionsTable.args.advanced_tab.args.useWotlkMapData = {
        type = "toggle",
        order = 6.2,
        name = "Use WotLK map data",
        desc = "Use WotLK map data",
        width = 1.65,
        disabled = function() return QuestieCompat.WOW_PROJECT_ID == QuestieCompat.WOW_PROJECT_WRATH_CLASSIC end,
        get = function (info) return QuestieOptions:GetProfileValue(info); end,
        set = function (info, value)
            QuestieOptions:SetProfileValue(info, value)
            StaticPopup_Show("QUESTIE_RELOAD")
        end,
    }
	
	optionsTable.args.advanced_tab.args.useQuestieLinks = {
        type = "toggle",
        order = 6.3,
        name = "Use Questie Links",
        desc = "Use Questie Links",
        width = 1.65,
        get = function (info) return QuestieOptions:GetProfileValue(info); end,
        set = function (info, value)
            QuestieOptions:SetProfileValue(info, value)
            StaticPopup_Show("QUESTIE_RELOAD")
        end,
    }

    optionsTable.args.advanced_tab.args.resetDailyQuests = {
        type = "toggle",
        order = 6.4,
        name = "Reset Daily Quests",
        desc = "Reset Daily Quests",
        width = 1.65,
        get = function (info) return QuestieOptions:GetProfileValue(info); end,
        set = function (info, value)
            QuestieOptions:SetProfileValue(info, value)
            Questie.db.profile.dailyResetTime = nil
            StaticPopup_Show("QUESTIE_RELOAD")
        end,
    }

    optionsTable.args.advanced_tab.args.weeklyResetDay = {
        type = "select",
        order = 6.5,
        values = QuestieCompat.CALENDAR_WEEKDAY_NAMES,
        style = 'dropdown',
        disabled = function() return not Questie.db.profile.resetDailyQuests end,
        name = "Weekly Reset Day",
        desc = "Weekly Reset Day",
        width = 1.6,
        get = function (info) return QuestieOptions:GetProfileValue(info) end,
        set = function (info, value)
            QuestieOptions:SetProfileValue(info, value)
            Questie.db.profile.weeklyResetTime = nil
            StaticPopup_Show("QUESTIE_RELOAD")
        end,
    }
end

local correctionsRegistry = {}

function QuestieCompat.RegisterCorrection(dbName, corrections)
    correctionsRegistry[dbName] = correctionsRegistry[dbName] or {}
    table.insert(correctionsRegistry[dbName], corrections)
end

function QuestieCompat.LoadCorrections(_LoadCorrections, validationTables)
    for dbName in pairs(correctionsRegistry) do
        local dbKeysReversed = QuestieDB[dbName:sub(1, -5).."KeysReversed"]
        for i, corrections in ipairs(correctionsRegistry[dbName]) do
            _LoadCorrections(dbName, corrections(), dbKeysReversed, validationTables)
        end
    end
end

local blacklistRegistry = {}

function QuestieCompat.RegisterBlacklist(blName, blacklist)
    blacklistRegistry[blName] = blacklistRegistry[blName] or {}
    table.insert(blacklistRegistry[blName], blacklist)
end

function QuestieCompat.LoadBlacklists()
    for blName in pairs(blacklistRegistry) do
        for _, blacklist in ipairs(blacklistRegistry[blName]) do
            QuestieCompat.Merge(QuestieCorrections[blName], blacklist(), true)
        end
    end
end

function QuestieCompat.Merge(target, source, override)
	if type(target) ~= "table" then target = {} end
	for k,v in pairs(source) do
		if type(v) == "table" then
			target[k] = QuestieCompat.Merge(target[k], v, override)
		elseif target[k] == nil or override then
			target[k] = v
		end
	end
	return target
end

function QuestieCompat:ADDON_LOADED(event, addon)
    if addon ~= QuestieCompat.addonName then return end

    QuestieCompat.Merge(Questie.db, {
        profile = {
			isInitialLogin = true,
            initDelay = 0.03,
            useWotlkMapData = false,
            resetDailyQuests = true,
            weeklyResetDay = 4,
			useQuestieLinks = false,
        },
        char = {
            daily = {},
            weekly = {},
        }
    })

    QuestieCompat.LoadUiMapData(Questie.db.profile.useWotlkMapData and QuestieCompat.WOW_PROJECT_WRATH_CLASSIC)

    for uiMapId, data in pairs(QuestieCompat.UiMapData) do
        mapIdToUiMapId[data.mapID] = uiMapId
    end

    for k, patterns in pairs(chatMessagePattern) do
        for i, str in pairs(patterns) do
            chatMessagePattern[k][i] = QuestieLib:SanitizePattern(str)
        end
    end

    for name, path in pairs(townsfolk_texturemap) do
        QuestieMenu.private.townsfolk_texturemap[name] = path
    end
	
	local DISABLED_MODULES = {
        "HBDHooks",
        "QuestieDebugOffer",
        "SeasonOfDiscovery",
        "QuestieDBMIntegration"
    }
	
	if not Questie.db.profile.useQuestieLinks then
		table.insert(DISABLED_MODULES, "ChatFilter")
		table.insert(DISABLED_MODULES, "Hooks")
		table.insert(DISABLED_MODULES, "QuestieLink")
	end

    for _, moduleName in pairs(DISABLED_MODULES) do
        local module = QuestieLoader:ImportModule(moduleName)
        setmetatable(wipe(module), QuestieCompat.NOOP_MT)
    end

	QuestieLoader.PopulateGlobals = QuestieCompat.PopulateGlobals
    QuestieStream._writeByte = QuestieCompat._writeByte
    QuestieStream._readByte = QuestieCompat._readByte
    QuestieStream.Save = QuestieCompat.Save
    ZoneDB.private.RunTests = QuestieCompat.NOOP
    QuestieLib.TextWrap = QuestieCompat.TextWrap
    QuestieCoords.GetPlayerMapPosition = QuestieCompat.GetPlayerMapPosition
    QuestieCoords.ResetMiniWorldMapText = QuestieCompat.NOOP
    _EventHandler.UiInfoMessage = QuestieCompat.UiInfoMessage
    QuestieCompat.orig_QuestieOptions_Initialize = QuestieOptions.Initialize
    QuestieOptions.Initialize = QuestieCompat.QuestieOptions_Initialize
    QuestieCompat.orig_GetSelectedSoundFile = Sounds.GetSelectedSoundFile
    Sounds.GetSelectedSoundFile = QuestieCompat.GetSelectedSoundFile
	QuestieLink.GetQuestLinkString = rawget(QuestieLink, "GetQuestLinkString") or QuestieCompat.GetQuestLinkString
	QuestieLink.GetQuestLinkStringById = rawget(QuestieLink, "GetQuestLinkStringById") or QuestieCompat.GetQuestLinkStringById
	QuestieLink.GetQuestHyperLink = rawget(QuestieLink, "GetQuestHyperLink") or QuestieCompat.GetQuestLinkStringById

    hooksecurefunc(QuestieEventHandler, "RegisterLateEvents", QuestieCompat.QuestieEventHandler_RegisterLateEvents)
    hooksecurefunc(QuestEventHandler, "RegisterEvents", QuestieCompat.QuestEventHandler_RegisterEvents)
    hooksecurefunc(TrackerLinePool, "Initialize", QuestieCompat.QuestieTracker_Initialize)
    hooksecurefunc(QuestieQuest, "ToggleNotes", QuestieCompat.HBDPins.UpdateWorldMap)
	hooksecurefunc("ReloadUI", QuestieCompat.OnReloadUi)
	hooksecurefunc("ConsoleExec", QuestieCompat.OnReloadUi)


    local Mapster = LibStub("AceAddon-3.0"):GetAddon("Mapster", true)
    if Mapster and Mapster.RefreshQuestObjectivesDisplay then
        hooksecurefunc(Mapster, "RefreshQuestObjectivesDisplay", QuestieCompat.HBDPins.UpdateWorldMap)
    end

    local MBF = LibStub("AceAddon-3.0"):GetAddon("Minimap Button Frame", true)
    if MBF and MBF.db.profile.MinimapIcons then
        table.insert(MBF.db.profile.MinimapIcons, "QuestieFrame")
        MBF:fillDropdowns()
    end
end