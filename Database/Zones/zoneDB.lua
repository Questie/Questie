---@class ZoneDB
---@field zoneIDs table
---@field GetDungeons fun():table
---@field GetZoneTables fun():table
local ZoneDB = QuestieLoader:CreateModule("ZoneDB")
local _ZoneDB = {}

-------------------------
--Import modules.
-------------------------
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local areaIdToUiMapId = {}
local uiMapIdToAreaId = {} -- Generated

local dungeons = {}
local dungeonLocations = {}

local dungeonParentZones = {}
local subZoneToParentZone = {}
local parentZoneToSubZone = {} -- Generated


function ZoneDB:Initialize()
    areaIdToUiMapId, dungeons, dungeonLocations, dungeonParentZones, subZoneToParentZone = ZoneDB:GetZoneTables()

    _ZoneDB.GenerateUiMapIdToAreaIdTable()
    _ZoneDB.GenerateParentZoneToStartingZoneTable()
end

function _ZoneDB.GenerateUiMapIdToAreaIdTable()
    for areaId, uiMapId in pairs(areaIdToUiMapId) do
        uiMapIdToAreaId[uiMapId] = areaId
    end
    uiMapIdToAreaId[1946] = 3521 -- fix zangarmarsh reverse lookup (todo: better solution)
end

function _ZoneDB.GenerateParentZoneToStartingZoneTable()
    for startingZone, parentZone in pairs(subZoneToParentZone) do
        parentZoneToSubZone[parentZone] = startingZone
    end
end

function ZoneDB:GetUiMapIdByAreaId(areaId)
    return areaIdToUiMapId[areaId]
end

function ZoneDB:GetAreaIdByUiMapId(uiMapId)
    return uiMapIdToAreaId[uiMapId]
end

function ZoneDB:GetDungeonLocation(areaId)
    return dungeonLocations[areaId]
end

function ZoneDB:IsDungeonZone(areaId)
    return dungeonLocations[areaId] ~= nil
end

function ZoneDB:GetAlternativeZoneId(areaId)
    local entry = dungeons[areaId]
    if entry then
        return entry[2]
    end

    entry = parentZoneToSubZone[areaId]
    if entry then
        return entry
    end

    return nil
end

function ZoneDB.GetParentZoneId(areaId)
    return dungeonParentZones[areaId] or subZoneToParentZone[areaId]
end

--- zoneMap[zoneOrSort][questId] = true
---@alias zoneMap table<integer, table<integer, true>>

--- Modifies zoneMap by adding questID into zones where relevant npcs/objects spawn.
---@param zoneMap zoneMap
---@param questId integer
---@param querySingleFunction fun(id:integer, field:string):any # QuerySingle function to relevant DB, where to get spawns of idList
---@param idList integer[]|nil # list of npc/object ids, whose spawns' zones will be added into zoneMap
local function _AddZonesWithQuestsFromSpawns(zoneMap, questId, querySingleFunction, idList)
    if (not idList) then return end

    for id in pairs(idList) do
        ---@type table<integer, table> | nil
        local spawns = querySingleFunction(id, "spawns")
        if spawns then
            for zone in pairs(spawns) do
                if not zoneMap[zone] then
                    zoneMap[zone] = {}
                end
                zoneMap[zone][questId] = true
            end
        end
    end
end

--- Modifies zoneMap by adding quests from SPECIAL and SEASONAL sortIds to their seasonal event specific sortIds.
--- Modifies zoneMap by removing SPECIAL and SEASONAL sortIds.
---@param zoneMap zoneMap
local function _SplitSeasonalQuests(zoneMap)
    if not zoneMap[QuestieDB.sortKeys.SPECIAL] then return end

    local questsToSplit = zoneMap[QuestieDB.sortKeys.SEASONAL]
    -- Merging SEASONAL and SPECIAL quests to be split into real groups
    for questId in pairs(zoneMap[QuestieDB.sortKeys.SPECIAL]) do
        questsToSplit[questId] = true
    end

    zoneMap[-400] = {}
    zoneMap[-401] = {}
    zoneMap[-402] = {}
    zoneMap[-403] = {}
    zoneMap[-404] = {}

    for questId in pairs(questsToSplit) do
        local eventName = QuestieEvent:GetEventNameFor(questId)
        if eventName == "Love is in the Air" then
            zoneMap[-400][questId] = true
        elseif eventName == "Children's Week" then
            zoneMap[-401][questId] = true
        elseif eventName == "Harvest Festival" then
            zoneMap[-402][questId] = true
        elseif eventName == "Hallow's End" then
            zoneMap[-403][questId] = true
        elseif eventName == "Winter Veil" then
            zoneMap[-404][questId] = true
        end
    end

    zoneMap[QuestieDB.sortKeys.SEASONAL] = nil
    zoneMap[QuestieDB.sortKeys.SPECIAL] = nil
end

--- Generate "zoneMap" for current player. i.e. which all zones have quests for player.
---@return zoneMap
function ZoneDB.GetZonesWithQuests()
    local professionRIDING = QuestieProfessions.professionKeys.RIDING
    local hiddenQuests = QuestieCorrections.hiddenQuests
    local QueryQuestSingle = QuestieDB.QueryQuestSingle
    local GetParentZoneId = ZoneDB.GetParentZoneId
    local HasRequiredRace = QuestiePlayer.HasRequiredRace
    local HasRequiredClass = QuestiePlayer.HasRequiredClass

    -- generate a lookup table of values existing in QuestieDB.sortKeys
    ---@type table<integer, true>
    local sortIdentifiersOfSpecialQuestCategories = {}
    for _, v in pairs(QuestieDB.sortKeys) do
        sortIdentifiersOfSpecialQuestCategories[v] = true
    end

    ---@type zoneMap
    local zoneMap = {}

    for questId in pairs(QuestieDB.QuestPointers) do
        if (not hiddenQuests[questId])
        and HasRequiredRace(QueryQuestSingle(questId, "requiredRaces"))
        and HasRequiredClass(QueryQuestSingle(questId, "requiredClasses")) then

            ---@type integer|nil, integer[]|nil
            local zoneOrSort, requiredSkill = QueryQuestSingle(questId, "zoneOrSort"), QueryQuestSingle(questId, "requiredSkill")
            if requiredSkill and (requiredSkill[1] ~= professionRIDING) then
                zoneOrSort = QuestieProfessions:GetSortIdByProfessionId(requiredSkill[1])

                if (not zoneMap[zoneOrSort]) then
                    zoneMap[zoneOrSort] = {}
                end
                zoneMap[zoneOrSort][questId] = true
            elseif zoneOrSort and (zoneOrSort > 0) then -- quest has a zone
                local zoneId = GetParentZoneId(zoneOrSort) or zoneOrSort

                if (not zoneMap[zoneId]) then
                    zoneMap[zoneId] = {}
                end
                zoneMap[zoneId][questId] = true
            elseif sortIdentifiersOfSpecialQuestCategories[zoneOrSort] then -- belongs to values of QuestieDB.sortKeys
                ---@cast zoneOrSort -nil
                if (not zoneMap[zoneOrSort]) then
                    zoneMap[zoneOrSort] = {}
                end
                zoneMap[zoneOrSort][questId] = true
            else
                ---@type integer[][]|nil, integer[][]|nil
                local startedBy, finishedBy = QueryQuestSingle(questId, "startedBy"), QueryQuestSingle(questId, "finishedBy")

                if startedBy then
                    _AddZonesWithQuestsFromSpawns(zoneMap, questId, QuestieDB.QueryNPCSingle, startedBy[1])
                    _AddZonesWithQuestsFromSpawns(zoneMap, questId, QuestieDB.QueryObjectSingle, startedBy[2])
                end

                if finishedBy then
                    _AddZonesWithQuestsFromSpawns(zoneMap, questId, QuestieDB.QueryNPCSingle, finishedBy[1])
                    _AddZonesWithQuestsFromSpawns(zoneMap, questId, QuestieDB.QueryObjectSingle, finishedBy[2])
                end
            end
        end
    end

    _SplitSeasonalQuests(zoneMap)

    return zoneMap
end

---@param zoneMap zoneMap
---@return table # zones[category][zoneOrSortId] = l10n(zoneName)
function ZoneDB.GetRelevantZones(zoneMap)
    local zones = {}
    for category, data in pairs(l10n.zoneCategoryLookup) do
        zones[category] = {}
        for zoneOrSortId, zoneName in pairs(data) do
            if zoneMap[zoneOrSortId] then
                zones[category][zoneOrSortId] = l10n(zoneName)
            else
                zones[category][zoneOrSortId] = nil
            end
        end
    end

    return zones
end
