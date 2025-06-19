---@class QuestieCorrections
local QuestieCorrections = QuestieLoader:CreateModule("QuestieCorrections")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
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
---@type HardcoreBlacklist
local HardcoreBlacklist = QuestieLoader:ImportModule("HardcoreBlacklist")
---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type BlacklistFilter
local BlacklistFilter = QuestieLoader:ImportModule("BlacklistFilter")

---@type QuestieQuestFixes
local QuestieQuestFixes = QuestieLoader:ImportModule("QuestieQuestFixes")
---@type QuestieClassicQuestReputationFixes
local QuestieClassicQuestReputationFixes = QuestieLoader:ImportModule("QuestieClassicQuestReputationFixes")
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

---@type CataQuestFixes
local CataQuestFixes = QuestieLoader:ImportModule("CataQuestFixes")
---@type CataNpcFixes
local CataNpcFixes = QuestieLoader:ImportModule("CataNpcFixes")
---@type CataItemFixes
local CataItemFixes = QuestieLoader:ImportModule("CataItemFixes")
---@type CataObjectFixes
local CataObjectFixes = QuestieLoader:ImportModule("CataObjectFixes")

---@type MopQuestFixes
local MopQuestFixes = QuestieLoader:ImportModule("MopQuestFixes")
---@type MopNpcFixes
local MopNpcFixes = QuestieLoader:ImportModule("MopNpcFixes")
---@type MopItemFixes
local MopItemFixes = QuestieLoader:ImportModule("MopItemFixes")
---@type MopObjectFixes
local MopObjectFixes = QuestieLoader:ImportModule("MopObjectFixes")

---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")

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

local filterExpansion = BlacklistFilter.filterExpansion

QuestieCorrections.killCreditObjectiveFirst = {}
QuestieCorrections.objectObjectiveFirst = {}
QuestieCorrections.itemObjectiveFirst = {}
QuestieCorrections.eventObjectiveFirst = {}

do
    local type, assert = type, assert
    --- Add runtime overrides for the database
    ---@param override_table table<number, table<number, string|table|number>>
    ---@param new_overrides table<number, table<number, string|table|number>>
    local function addOverride(override_table, new_overrides)
        assert(type(override_table) == "table", "Override table must be a table!")
        assert(type(new_overrides) == "table", "New overrides must be a table!")
        for id, data in pairs(new_overrides) do
            assert(type(id) == "number", "Override id must be a number!")
            assert(type(data) == "table", "Override data must be a table!")
            -- If no override exist assign it
            if not override_table[id] then
                override_table[id] = data
            else
                -- Override already exists, merge the new data
                for key, value in pairs(data) do
                    override_table[id][key] = value
                end
            end
        end
    end

    function QuestieCorrections:MinimalInit() -- db already compiled
        -- Classic Era Corrections
        addOverride(QuestieDB.itemDataOverrides, QuestieItemFixes:LoadFactionFixes())
        addOverride(QuestieDB.npcDataOverrides, QuestieNPCFixes:LoadFactionFixes())
        addOverride(QuestieDB.objectDataOverrides, QuestieObjectFixes:LoadFactionFixes())
        addOverride(QuestieDB.questDataOverrides, QuestieQuestFixes:LoadFactionFixes())

        -- TBC Corrections
        if (Expansions.Current >= Expansions.Tbc) then
            addOverride(QuestieDB.itemDataOverrides, QuestieTBCItemFixes:LoadFactionFixes())
            addOverride(QuestieDB.npcDataOverrides, QuestieTBCNpcFixes:LoadFactionFixes())
            addOverride(QuestieDB.objectDataOverrides, QuestieTBCObjectFixes:LoadFactionFixes())
            addOverride(QuestieDB.questDataOverrides, QuestieTBCQuestFixes:LoadFactionFixes())
        end

        -- WOTLK Corrections
        if (Expansions.Current >= Expansions.Wotlk) then
            addOverride(QuestieDB.npcDataOverrides, QuestieWotlkNpcFixes:LoadFactionFixes())
            addOverride(QuestieDB.itemDataOverrides, QuestieWotlkItemFixes:LoadFactionFixes())
            addOverride(QuestieDB.objectDataOverrides, QuestieWotlkObjectFixes:LoadFactionFixes())
        end

        -- CATA Corrections
        if (Expansions.Current >= Expansions.Cata) then
            addOverride(QuestieDB.questDataOverrides, CataQuestFixes:LoadFactionFixes())
            addOverride(QuestieDB.npcDataOverrides, CataNpcFixes:LoadFactionFixes())
            addOverride(QuestieDB.itemDataOverrides, CataItemFixes:LoadFactionFixes())
            addOverride(QuestieDB.objectDataOverrides, CataObjectFixes:LoadFactionFixes())
        end

        -- Season of Discovery Corrections
        if Questie.IsSoD then
            addOverride(QuestieDB.questDataOverrides, SeasonOfDiscovery:LoadFactionQuestFixes())
        end

        QuestieCorrections.questItemBlacklist = filterExpansion(QuestieItemBlacklist:Load())
        QuestieCorrections.questNPCBlacklist = filterExpansion(QuestieNPCBlacklist:Load())
        QuestieCorrections.hiddenQuests = filterExpansion(QuestieQuestBlacklist:Load())

        -- TBC Quel Danas Blacklist
        if Questie.db.global.isleOfQuelDanasPhase == IsleOfQuelDanas.MAX_ISLE_OF_QUEL_DANAS_PHASES then
            for id, hide in pairs(IsleOfQuelDanas.quests[Questie.db.global.isleOfQuelDanasPhase]) do
                -- This has to be a nil-check, because the value could be false
                if (QuestieCorrections.hiddenQuests[id] == nil) then
                    QuestieCorrections.hiddenQuests[id] = hide
                end
            end
        end

        -- Wotlk Blacklist
        if (Expansions.Current >= Expansions.Wotlk) then
            -- We only add blacklist if no blacklist entry for the quest already exists
            for id, hide in pairs(QuestieQuestBlacklist.LoadAutoBlacklistWotlk()) do
                -- This has to be a nil-check, because the value could be false
                if (QuestieCorrections.hiddenQuests[id] == nil) then
                    QuestieCorrections.hiddenQuests[id] = hide
                end
            end
        end

        -- Hardcore Blacklist
        if (Questie.IsHardcore) then
            for id, _ in pairs(HardcoreBlacklist:Load()) do
                QuestieCorrections.hiddenQuests[id] = true
            end
        end

        if Questie.db.profile.showEventQuests then
            C_Timer.After(1, function()
                 -- This is done with a delay because on startup the Blizzard API seems to be
                 -- very slow and therefore the date calculation in QuestieEvents isn't done
                 -- correctly.
                QuestieEvent:Load()
            end)
        end
    end
end

---@param databaseTableName string The name of the QuestieDB field that should be manipulated (e.g. "itemData", "questData")
---@param corrections table All corrections for the given databaseTableName (e.g. all quest corrections)
---@param reversedKeys table The reverted QuestieDB keys for the given databaseTableName (e.g. QuestieDB.questKeys)
---@param validationTables table Only used by the CI validation scripts to validate the corrections against the original database values and find irrelevant corrections
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

---@param validationTables table? Only used by the CI validation scripts to validate the corrections against the original database values and find irrelevant corrections
function QuestieCorrections:Initialize(validationTables)
    QuestieQuestFixes:LoadMissingQuests()

    -- Classic Corrections
    if Expansions.Current < Expansions.Cata then
        _LoadCorrections("questData", QuestieClassicQuestReputationFixes:Load(), QuestieDB.questKeysReversed, validationTables)
    end
    _LoadCorrections("questData", QuestieQuestFixes:Load(), QuestieDB.questKeysReversed, validationTables)
    _LoadCorrections("npcData", QuestieNPCFixes:Load(), QuestieDB.npcKeysReversed, validationTables)
    _LoadCorrections("itemData", QuestieItemFixes:Load(), QuestieDB.itemKeysReversed, validationTables)
    _LoadCorrections("objectData", QuestieObjectFixes:Load(), QuestieDB.objectKeysReversed, validationTables)

    if Expansions.Current >= Expansions.Tbc then
        _LoadCorrections("questData", QuestieTBCQuestFixes:Load(), QuestieDB.questKeysReversed, validationTables)
        _LoadCorrections("npcData", QuestieTBCNpcFixes:Load(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("itemData", QuestieTBCItemFixes:Load(), QuestieDB.itemKeysReversed, validationTables)
        _LoadCorrections("objectData", QuestieTBCObjectFixes:Load(), QuestieDB.objectKeysReversed, validationTables)
    end

    if Expansions.Current >= Expansions.Wotlk then
        _LoadCorrections("questData", QuestieWotlkQuestFixes:Load(), QuestieDB.questKeysReversed, validationTables)
        _LoadCorrections("npcData", QuestieWotlkNpcFixes:LoadAutomatics(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("npcData", QuestieWotlkNpcFixes:Load(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("itemData", QuestieWotlkItemFixes:Load(), QuestieDB.itemKeysReversed, validationTables)
        _LoadCorrections("objectData", QuestieWotlkObjectFixes:Load(), QuestieDB.objectKeysReversed, validationTables)
    end

    if Expansions.Current >= Expansions.Cata then
        _LoadCorrections("questData", CataQuestFixes.Load(), QuestieDB.questKeysReversed, validationTables)
        _LoadCorrections("npcData", CataNpcFixes.Load(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("itemData", CataItemFixes.Load(), QuestieDB.itemKeysReversed, validationTables)
        _LoadCorrections("objectData", CataObjectFixes.Load(), QuestieDB.objectKeysReversed, validationTables)
    end

    if Expansions.Current >= Expansions.MoP then
        _LoadCorrections("questData", MopQuestFixes.Load(), QuestieDB.questKeysReversed, validationTables)
        _LoadCorrections("npcData", MopNpcFixes.Load(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("itemData", MopItemFixes.Load(), QuestieDB.itemKeysReversed, validationTables)
        _LoadCorrections("objectData", MopObjectFixes.Load(), QuestieDB.objectKeysReversed, validationTables)
    end

    if Questie.IsSoD then
        _LoadCorrections("questData", SeasonOfDiscovery:LoadBaseQuests(), QuestieDB.questKeysReversed, validationTables)
        _LoadCorrections("questData", SeasonOfDiscovery:LoadQuests(), QuestieDB.questKeysReversed, validationTables)
        _LoadCorrections("npcData", SeasonOfDiscovery:LoadBaseNPCs(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("npcData", SeasonOfDiscovery:LoadNPCs(), QuestieDB.npcKeysReversed, validationTables)
        _LoadCorrections("itemData", SeasonOfDiscovery:LoadBaseItems(), QuestieDB.itemKeysReversed, validationTables)
        _LoadCorrections("itemData", SeasonOfDiscovery:LoadItems(), QuestieDB.itemKeysReversed, validationTables)
        _LoadCorrections("objectData", SeasonOfDiscovery:LoadBaseObjects(), QuestieDB.objectKeysReversed, validationTables)
        _LoadCorrections("objectData", SeasonOfDiscovery:LoadObjects(), QuestieDB.objectKeysReversed, validationTables)
    end

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


local abs, sqrt = math.abs, math.sqrt
local function euclid(x, y, i, e)
    local xd = abs(x - i)
    local yd = abs(y - e)
    return sqrt(xd * xd + yd * yd)
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
                            newWaypoints[#newWaypoints+1] = {way[1] * mul0 + lastWay[1] * mul1, way[2] * mul0 + lastWay[2] * mul1}
                        end
                    else
                        newWaypoints[#newWaypoints+1] = way
                    end
                else
                    newWaypoints[#newWaypoints+1] = way
                end
                lastWay = way
            end
            newWaypointList[#newWaypointList+1] = newWaypoints
        end
        newWaypointZones[zone] = newWaypointList
    end
    return newWaypointZones
end

function QuestieCorrections:PreCompile() -- this happens only if we are about to compile the database. Run intensive preprocessing tasks here (like ramer-douglas-peucker)
    local yieldLimit = 500 -- 500 seems like a good number
    local waypointKey = QuestieDB.npcKeys["waypoints"]
    local npcData = QuestieDB.npcData

    local count = 0
    for id, data in pairs(npcData) do
        local way = data[waypointKey]
        if way then
            npcData[id][waypointKey] = QuestieCorrections:OptimizeWaypoints(way)
        end

        if count > yieldLimit then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    waypointKey = QuestieDB.objectKeys["waypoints"]
    local objData = QuestieDB.objectData
    for id, data in pairs(objData) do
        local way = data[waypointKey]
        if way then
            objData[id][waypointKey] = QuestieCorrections:OptimizeWaypoints(way)
        end

        if count > yieldLimit then
             count = 0
             coroutine.yield()
        end
    end
end

return QuestieCorrections
