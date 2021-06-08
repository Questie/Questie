---@class ZoneDB
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
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local areaIdToUiMapId = {}
local uiMapIdToAreaId = {} -- Generated

local dungeons = {}
local dungeonLocations = {}

local dungeonParentZones = {}
local subZoneToParentZone = {}
local parentZoneToSubZone = {} -- Generated

local zoneMap = {} -- Generated

local locale


function ZoneDB:Initialize()
    areaIdToUiMapId, dungeons, dungeonLocations, dungeonParentZones, subZoneToParentZone = unpack(ZoneDB:GetZoneTables())

    _ZoneDB:GenerateUiMapIdToAreaIdTable()
    _ZoneDB:GenerateParentZoneToStartingZoneTable()

    locale = l10n:GetUILocale()
end

function _ZoneDB:GenerateUiMapIdToAreaIdTable()
    for areaId, uiMapId in pairs(areaIdToUiMapId) do
        uiMapIdToAreaId[uiMapId] = areaId
    end
    uiMapIdToAreaId[1946] = 3521 -- fix zangarmarsh reverse lookup (todo: better solution)
end

function _ZoneDB:GenerateParentZoneToStartingZoneTable()
    for startingZone, parentZone in pairs(subZoneToParentZone) do
        parentZoneToSubZone[parentZone] = startingZone
    end
end

function ZoneDB:GetUiMapIdByAreaId(areaId)
    if areaIdToUiMapId[areaId] ~= nil then
        return areaIdToUiMapId[areaId]
    end
    return nil
end

function ZoneDB:GetAreaIdByUiMapId(uiMapId)
    if uiMapIdToAreaId[uiMapId] ~= nil then
        return uiMapIdToAreaId[uiMapId]
    end
    return nil
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

function ZoneDB:GetParentZoneId(areaId)
    local entry = dungeonParentZones[areaId]
    if entry then
        return entry
    end

    entry = subZoneToParentZone[areaId]
    if entry then
        return entry
    end

    return nil
end

function ZoneDB:GetZonesWithQuests()
    for questId in pairs(QuestieDB.QuestPointers) do

        if (not QuestieCorrections.hiddenQuests[questId]) then
            local queryResult = QuestieDB.QueryQuest(questId, "startedBy", "finishedBy", "requiredRaces", "requiredClasses", "zoneOrSort")
            local startedBy, finishedBy, requiredRaces, requiredClasses, zoneOrSort = unpack(queryResult)

            if QuestiePlayer:HasRequiredRace(requiredRaces) and QuestiePlayer:HasRequiredClass(requiredClasses) then
                if zoneOrSort > 0 then
                    local parentZoneId = ZoneDB:GetParentZoneId(zoneOrSort)

                    if parentZoneId then
                        if (not zoneMap[parentZoneId]) then
                            zoneMap[parentZoneId] = {}
                        end
                        zoneMap[parentZoneId][questId] = true
                    else
                        if (not zoneMap[zoneOrSort]) then
                            zoneMap[zoneOrSort] = {}
                        end
                        zoneMap[zoneOrSort][questId] = true
                    end
                elseif _ZoneDB:IsSpecialQuest(zoneOrSort) then
                    if (not zoneMap[zoneOrSort]) then
                        zoneMap[zoneOrSort] = {}
                    end
                    zoneMap[zoneOrSort][questId] = true
                else
                    if startedBy then
                        zoneMap = _ZoneDB:GetZonesWithQuestsFromNPCs(zoneMap, startedBy[1])
                        zoneMap = _ZoneDB:GetZonesWithQuestsFromObjects(zoneMap, startedBy[2])
                    end

                    if finishedBy then
                        zoneMap = _ZoneDB:GetZonesWithQuestsFromNPCs(zoneMap, finishedBy[1])
                        zoneMap = _ZoneDB:GetZonesWithQuestsFromObjects(zoneMap, finishedBy[2])
                    end
                end
            end
        end
    end

    zoneMap = _ZoneDB:SplitSeasonalQuests()

    return zoneMap
end

function _ZoneDB:IsSpecialQuest(zoneOrSort)
    for _, v in pairs(QuestieDB.sortKeys) do
        if zoneOrSort == v then
            return true
        end
    end
    return false
end

function _ZoneDB:GetZonesWithQuestsFromNPCs(zones, npcSpawns)
    if (not npcSpawns) then
        return zones
    end

    for npcId in pairs(npcSpawns) do
        local spawns = QuestieDB.QueryNPCSingle(npcId, "spawns")
        if spawns then
            for zone in pairs(spawns) do
                if not zones[zone] then zones[zone] = {} end
                zones[zone][npcId] = true
            end
        end
    end

    return zones
end

function _ZoneDB:GetZonesWithQuestsFromObjects(zones, objectSpawns)
    if (not objectSpawns) then
        return zones
    end

    for objectId in pairs(objectSpawns) do
        local spawns = QuestieDB.QueryNPCSingle(objectId, "spawns")
        if spawns then
            for zone in pairs(spawns) do
                if not zones[zone] then zones[zone] = {} end
                zones[zone][objectId] = true
            end
        end
    end

    return zones
end

---@return table
function _ZoneDB:SplitSeasonalQuests()
    if not zoneMap[QuestieDB.sortKeys.SPECIAL] then
        return zoneMap
    end
    local questsToSplit = zoneMap[QuestieDB.sortKeys.SEASONAL]
    -- Merging SEASONAL and SPECIAL quests to be split into real groups
    for k, v in pairs(zoneMap[QuestieDB.sortKeys.SPECIAL]) do questsToSplit[k] = v end

    local updatedZoneMap = zoneMap
    updatedZoneMap[-400] = {}
    updatedZoneMap[-401] = {}
    updatedZoneMap[-402] = {}
    updatedZoneMap[-403] = {}
    updatedZoneMap[-404] = {}

    for questId, _ in pairs(questsToSplit) do
        local eventName = QuestieEvent:GetEventNameFor(questId)
        if eventName == "Love is in the Air" then
            updatedZoneMap[-400][questId] = true
        elseif eventName == "Childrens Week" then
            updatedZoneMap[-401][questId] = true
        elseif eventName == "Harvest Festival" then
            updatedZoneMap[-402][questId] = true
        elseif eventName == "Hallows End" then
            updatedZoneMap[-403][questId] = true
        elseif eventName == "Winter Veil" then
            updatedZoneMap[-404][questId] = true
        end
    end

    updatedZoneMap[QuestieDB.sortKeys.SEASONAL] = nil
    updatedZoneMap[QuestieDB.sortKeys.SPECIAL] = nil
    return updatedZoneMap
end

function ZoneDB:GetRelevantZones()
    local zones = {}
    for category, data in pairs(l10n.zoneCategoryLookup["enUS"]) do
        zones[category] = {}
        for id, zoneName in pairs(data) do
            local zoneQuests = zoneMap[id]
            if (not zoneQuests) then
                zones[category][id] = nil
            else
                zones[category][id] = l10n.zoneCategoryLookup[locale][category][id] or zoneName
            end
        end
    end

    return zones
end
