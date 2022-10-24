---@class QuestieCorrections
local QuestieCorrections = QuestieLoader:CreateModule("QuestieCorrections")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type RamerDouglasPeucker
local RamerDouglasPeucker = QuestieLoader:ImportModule("RamerDouglasPeucker")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieNPCBlacklist
local QuestieNPCBlacklist = QuestieLoader:ImportModule("QuestieNPCBlacklist")
---@type QuestieItemBlacklist
local QuestieItemBlacklist = QuestieLoader:ImportModule("QuestieItemBlacklist")

---@type QuestieQuestFixes
local QuestieQuestFixes = QuestieLoader:ImportModule("QuestieQuestFixes")
---@type QuestieNPCFixes
local QuestieNPCFixes = QuestieLoader:ImportModule("QuestieNPCFixes")
---@type QuestieItemFixes
local QuestieItemFixes = QuestieLoader:ImportModule("QuestieItemFixes")
---@type QuestieObjectFixes
local QuestieObjectFixes = QuestieLoader:ImportModule("QuestieObjectFixes")

---@type QuestieTBCQuestFixes
local QuestieTBCQuestFixes = QuestieLoader:ImportModule("QuestieTBCQuestFixes")
---@type QuestieTBCNpcFixes
local QuestieTBCNpcFixes = QuestieLoader:ImportModule("QuestieTBCNpcFixes")
---@type QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:ImportModule("QuestieTBCItemFixes")
---@type QuestieTBCObjectFixes
local QuestieTBCObjectFixes = QuestieLoader:ImportModule("QuestieTBCObjectFixes")

---@type QuestieWotlkQuestFixes
local QuestieWotlkQuestFixes = QuestieLoader:ImportModule("QuestieWotlkQuestFixes")
---@type QuestieWotlkNpcFixes
local QuestieWotlkNpcFixes = QuestieLoader:ImportModule("QuestieWotlkNpcFixes")
---@type QuestieWotlkItemFixes
local QuestieWotlkItemFixes = QuestieLoader:ImportModule("QuestieWotlkItemFixes")
---@type QuestieWotlkObjectFixes
local QuestieWotlkObjectFixes = QuestieLoader:ImportModule("QuestieWotlkObjectFixes")

--- Automatic corrections
local QuestieItemStartFixes = QuestieLoader:ImportModule("QuestieItemStartFixes")

--[[
    This file load the corrections of the database files.

    It is a separate file so we can upstream those changes easier to cmangos and can still
    update the database files with a script.

    Most of the corrections can be done by accessing a specific key instead of copying the
    whole object over and change it.
    You can find the keys at the beginning of each file (e.g. 'questKeys' are at the beginning of 'questDB.lua').

    Further information on how to use this can be found at the wiki
    https://github.com/Questie/Questie/wiki/Corrections
--]]

-- flags that can be used in corrections (currently only blacklists)
QuestieCorrections.TBC_ONLY = 1
QuestieCorrections.CLASSIC_ONLY = 2
QuestieCorrections.WOTLK_ONLY = 3

QuestieCorrections.killCreditObjectiveFirst = {} -- Only used for TBC quests

-- used during Precompile, how fast to run operations (lower = slower but less lag)
local TICKS_PER_YIELD_DEBUG = 4000
local TICKS_PER_YIELD = 72

-- this function filters a table of values, if the value is TBC_ONLY or CLASSIC_ONLY, set it to true or nil if that case is met
---@generic T
---@param values T
---@return T
local function filterExpansion(values)
    local isTBC = Questie.IsTBC
    local isWotlk = Questie.IsWotlk
    for k, v in pairs(values) do
        if v == QuestieCorrections.WOTLK_ONLY then
            if isWotlk then
                values[k] = true
            else
                values[k] = nil
            end
        elseif v == QuestieCorrections.TBC_ONLY then
            if isTBC then
                values[k] = true
            else
                values[k] = nil
            end
        elseif v == QuestieCorrections.CLASSIC_ONLY then
            if isTBC or isWotlk then
                values[k] = nil
            else
                values[k] = true
            end
        end
    end
    return values
end

function QuestieCorrections:MinimalInit() -- db already compiled
    for id, data in pairs(QuestieItemFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.itemDataOverrides[id] then
                QuestieDB.itemDataOverrides[id] = {}
            end
            QuestieDB.itemDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.npcDataOverrides[id] then
                QuestieDB.npcDataOverrides[id] = {}
            end
            QuestieDB.npcDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieObjectFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.objectDataOverrides[id] then
                QuestieDB.objectDataOverrides[id] = {}
            end
            QuestieDB.objectDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieQuestFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.questDataOverrides[id] then
                QuestieDB.questDataOverrides[id] = {}
            end
            QuestieDB.questDataOverrides[id][key] = value
        end
    end

    QuestieCorrections.questItemBlacklist = filterExpansion(QuestieItemBlacklist:Load())
    QuestieCorrections.questNPCBlacklist = filterExpansion(QuestieNPCBlacklist:Load())
    QuestieCorrections.hiddenQuests = filterExpansion(QuestieQuestBlacklist:Load())

    if (Questie.IsWotlk) then
        -- We only add blacklist if no blacklist entry for the quest already exists
        for id, hide in pairs(QuestieQuestBlacklist.LoadAutoBlacklistWotlk()) do
            -- This has to be a nil-check, because the value could be false
            if (QuestieCorrections.hiddenQuests[id] == nil) then
                QuestieCorrections.hiddenQuests[id] = hide
            end
        end
    end

    if Questie.db.char.showEventQuests then
        C_Timer.After(1, function()
             -- This is done with a delay because on startup the Blizzard API seems to be
             -- very slow and therefore the date calculation in QuestieEvents isn't done
             -- correctly.
            QuestieEvent:Load()
        end)
    end
end

---@param databaseTableName string The name of the QuestieDB field that should be manipulated (e.g. "itemData", "questData")
---@param corrections table All corrections for the given databaseTableName (e.g. all quest corrections)
---@param reversedKeys table The reverted QuestieDB keys for the given databaseTableName (e.g. QuestieDB.questKeys)
---@param validationTables table Only used by the cli.lua script to validate the corrections against the original database values and find irrelevant corrections
---@param noOverwrites true? Do not overwrite existing values
---@param noNewEntries true? Do not create new entries in the database
local _LoadCorrections = function(databaseTableName, corrections, reversedKeys, validationTables, noOverwrites, noNewEntries)
    for id, data in pairs(corrections) do
        for key, value in pairs(data) do
            -- Create the id if missing unless noNewEntries is set
            if not QuestieDB[databaseTableName][id] and not noNewEntries then
                QuestieDB[databaseTableName][id] = {}
            end
            if validationTables and QuestieDB[databaseTableName][id] then
                if value and QuestieLib.equals(QuestieDB[databaseTableName][id][key], value) and validationTables[databaseTableName][id] and
                    QuestieLib.equals(validationTables[databaseTableName][id][key], value) then
                    Questie:Warning("Correction of " ..
                                    databaseTableName .. " " .. tostring(id) .. "." .. reversedKeys[key] .. " matches base DB! Value:" .. tostring(value))
                end
            end
            if QuestieDB[databaseTableName][id] then
                if noOverwrites and QuestieDB[databaseTableName][id][key] == nil then
                    QuestieDB[databaseTableName][id][key] = value
                elseif not noOverwrites then
                    QuestieDB[databaseTableName][id][key] = value
                end
            end
        end
    end
end


---@param validationTables table Only used by the cli.lua script to validate the corrections against the original database values and find irrelevant corrections
function QuestieCorrections:Initialize(validationTables)
    -- Classic Corrections
    _LoadCorrections("questData", QuestieQuestFixes:Load(), QuestieDB.questKeysReversed, validationTables)
    _LoadCorrections("npcData", QuestieNPCFixes:Load(), QuestieDB.npcKeysReversed, validationTables)
    _LoadCorrections("itemData", QuestieItemFixes:Load(), QuestieDB.itemKeysReversed, validationTables)
    _LoadCorrections("objectData", QuestieObjectFixes:Load(), QuestieDB.objectKeysReversed, validationTables)

    if Questie.IsTBC or Questie.IsWotlk then
        _LoadCorrections("questData", QuestieTBCQuestFixes:Load(), QuestieDB.questKeysReversed, validationTables)
        _LoadCorrections("npcData", QuestieTBCNpcFixes:Load(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("itemData", QuestieTBCItemFixes:Load(), QuestieDB.itemKeysReversed, validationTables)
        _LoadCorrections("objectData", QuestieTBCObjectFixes:Load(), QuestieDB.objectKeysReversed, validationTables)
    end

    if Questie.IsWotlk then
        _LoadCorrections("questData", QuestieWotlkQuestFixes:Load(), QuestieDB.questKeysReversed, validationTables)
        _LoadCorrections("npcData", QuestieWotlkNpcFixes:LoadAutomatics(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("npcData", QuestieWotlkNpcFixes:Load(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("itemData", QuestieWotlkItemFixes:Load(), QuestieDB.itemKeysReversed, validationTables)
        _LoadCorrections("objectData", QuestieWotlkObjectFixes:Load(), QuestieDB.objectKeysReversed, validationTables)
    end


    --- Corrections that apply to all versions
    _LoadCorrections("itemData", QuestieItemStartFixes:LoadAutomaticQuestStarts(), QuestieDB.itemKeysReversed, validationTables, true, true)

    local patchCount = 0
    for _, quest in pairs(QuestieDB.questData) do
        if (not quest[QuestieDB.questKeys.requiredRaces]) or quest[QuestieDB.questKeys.requiredRaces] == 0 then
            -- check against questgiver
            local canHorde = false
            local canAlliance = false
            local starts = quest[QuestieDB.questKeys.startedBy]
            if starts then
                starts = starts[1]
                if starts then
                    for _, id in pairs(starts) do
                        local npc = QuestieDB.npcData[id]
                        if npc then
                            local friendly = npc[QuestieDB.npcKeys.friendlyToFaction]
                            if friendly then
                                if friendly == "H" then
                                    canHorde = true
                                elseif friendly == "A" then
                                    canAlliance = true
                                elseif friendly == "AH" then
                                    canAlliance = true
                                    canHorde = true
                                end
                            end
                        end
                    end
                end
                if canAlliance ~= canHorde then
                    patchCount = patchCount + 1
                    if canAlliance then
                        quest[QuestieDB.questKeys.requiredRaces] = QuestieDB.raceKeys.ALL_ALLIANCE
                    else
                        quest[QuestieDB.questKeys.requiredRaces] = QuestieDB.raceKeys.ALL_HORDE
                    end
                end
            end
        end
    end

    QuestieCorrections:MinimalInit()

end

local WAYPOINT_MIN_DISTANCE = 1.5 -- todo: make this a config value maybe?
local ZONE_SCALES = {
    [ZoneDB.zoneIDs.STORMWIND_CITY] = 0.5,
    [ZoneDB.zoneIDs.IRONFORGE] = 0.5,
    [ZoneDB.zoneIDs.TELDRASSIL] = 0.5,

    [ZoneDB.zoneIDs.ORGRIMMAR] = 0.5,
    [ZoneDB.zoneIDs.THUNDER_BLUFF] = 0.5,
    [ZoneDB.zoneIDs.UNDERCITY] = 0.5,
}

local function euclid(x, y, i, e)
    local xd = math.abs(x - i)
    local yd = math.abs(y - e)
    return math.sqrt(xd * xd + yd * yd)
end

function QuestieCorrections:OptimizeWaypoints(waypointData)
    local newWaypointZones = {}
    for zone, waypointList in pairs(waypointData) do
        local newWaypointList = {}
        if waypointList[1] and type(waypointList[1][1]) == "number" then
            waypointList = {waypointList} -- corrections support both {{x,y}, ...} and {{{x,y}, ...}, {{x,y}, ...}, ...}
        end
        for _, waypoints in pairs(waypointList) do
            -- apply RDP algorithm
            local minDist = WAYPOINT_MIN_DISTANCE * (ZONE_SCALES[zone] or 1)
            local newWaypoints = RamerDouglasPeucker(waypoints, 0.1, true)

            waypoints = newWaypoints
            newWaypoints = {}

            -- subdivide waypoints where needed
            -- We do this because the clickable area of waypoint lines can only be a square, so lines need to be broken up in some places
            local lastWay
            for _, way in pairs(waypoints) do
                if lastWay then
                    local dist = euclid(way[1], way[2], lastWay[1], lastWay[2])
                    if dist > minDist then
                        local divs = math.ceil(dist/minDist)
                        for i=1,divs do
                            local mul0 = i/divs
                            local mul1 = 1-mul0
                            tinsert(newWaypoints, {way[1] * mul0 + lastWay[1] * mul1, way[2] * mul0 + lastWay[2] * mul1})
                        end
                    else
                        tinsert(newWaypoints, way)
                    end
                else
                    tinsert(newWaypoints, way)
                end

                lastWay = way
            end
            tinsert(newWaypointList, newWaypoints)
        end
        newWaypointZones[zone] = newWaypointList

    end
    return newWaypointZones
end

function QuestieCorrections:PreCompile() -- this happens only if we are about to compile the database. Run intensive preprocessing tasks here (like ramer-douglas-peucker)
    local ops = {}

    for id, data in pairs(QuestieDB.npcData) do
        local way = data[QuestieDB.npcKeys["waypoints"]]
        if way then
            tinsert(ops, {way, id})
        end
    end

    while true do
        coroutine.yield()
        for _ = 0, Questie.db.global.debugEnabled and TICKS_PER_YIELD_DEBUG or TICKS_PER_YIELD do
            local op = tremove(ops, 1)
            if op then
                QuestieDB.npcData[op[2]][QuestieDB.npcKeys["waypoints"]] = QuestieCorrections:OptimizeWaypoints(op[1])
            else
                --local totalPoints2 = 0
                --for id, data in pairs(QuestieDB.npcData) do
                --    local way = data[QuestieDB.npcKeys["waypoints"]]
                --    if way then
                --        for _,waypoints in pairs(way) do
                --            totalPoints2 = totalPoints2 + #waypoints
                --        end
                --    end
                --end
                --print("Before RDP: " .. tostring(totalPoints))
                --print("After RDP:" .. tostring(totalPoints2))

                return
            end
        end
    end
end
