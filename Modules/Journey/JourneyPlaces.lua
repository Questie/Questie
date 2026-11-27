---The zones and factions quests can be listed for, and the groups the zones are in, like a continent or the dungeons.
---@class JourneyPlaces
local JourneyPlaces = QuestieLoader:CreateModule("JourneyPlaces")

---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---What a list of quests is about: a zone or a faction with its ID, like "zone:40", or all quests.
---@alias JourneySource string

---@type JourneySource
JourneyPlaces.ALL = "all"

---@class JourneyPlace
---@field id number
---@field name string
---@field group string? For zones, the name of the group
---@field groupId number? For zones

---@param a JourneyPlace
---@param b JourneyPlace
---@return boolean
local function _IsNameBefore(a, b)
    return a.name < b.name
end

-------------------------
-- Zones
-------------------------

---@return JourneyPlace[] groups In the order of their IDs: the continents first, the events last
function JourneyPlaces.GetGroups()
    local groups = {}
    for id, name in pairs(QuestieJourney.continents) do
        if QuestieJourney.zones[id] and next(QuestieJourney.zones[id]) then
            table.insert(groups, {id = id, name = name})
        end
    end
    table.sort(groups, function(a, b) return a.id < b.id end)
    return groups
end

---@param groupId number
---@return string
function JourneyPlaces.GetGroupName(groupId)
    return QuestieJourney.continents[groupId] or ""
end

---@param groupId number
---@return JourneyPlace[] zones Sorted by name
function JourneyPlaces.GetZones(groupId)
    local zones = {}
    for id, name in pairs(QuestieJourney.zones[groupId] or {}) do
        table.insert(zones, {id = id, name = name, group = JourneyPlaces.GetGroupName(groupId), groupId = groupId})
    end
    table.sort(zones, _IsNameBefore)
    return zones
end

---@param zoneId number
---@return number? groupId
function JourneyPlaces.GetGroupOf(zoneId)
    for groupId, zones in pairs(QuestieJourney.zones) do
        if zones[zoneId] then
            return groupId
        end
    end
end

---@param zoneId number
---@return string name Empty when there is none
function JourneyPlaces.GetZoneName(zoneId)
    local groupId = JourneyPlaces.GetGroupOf(zoneId)
    if groupId then
        return QuestieJourney.zones[groupId][zoneId]
    end
    return zoneId > 0 and QuestieJourneyUtils:GetZoneName(zoneId) or ""
end

---@return number zoneId Of a zone with quests of its own, not of a part of it
function JourneyPlaces.GetPlayerZone()
    local subZoneToParentZoneOverride = loadstring(ZoneDB.private.subZoneToParentZoneOverride)()
    local zoneId = QuestiePlayer:GetCurrentZoneId()
    return subZoneToParentZoneOverride[zoneId] or zoneId
end

---@param groupId number
---@return boolean
function JourneyPlaces.IsContinent(groupId)
    return groupId < QuestieJourney.questCategoryKeys.DUNGEONS
end

---@param groupId number
---@return boolean
function JourneyPlaces.IsDungeons(groupId)
    return groupId == QuestieJourney.questCategoryKeys.DUNGEONS
end

-------------------------
-- Maps
-------------------------

---@type table<UiMapId, JourneyPlace> Nil until they are asked for
local zonesByMap
---@type table<number, UiMapId> By group, for the continents
local mapsByGroup

---The map most of the zones of a group are on. Only continents have one.
---@param zones JourneyPlace[]
---@return UiMapId?
local function _GetCommonMap(zones)
    local counts, best = {}, nil
    for _, zone in ipairs(zones) do
        local info = zone.id > 0 and C_Map.GetMapInfo(ZoneDB:GetUiMapIdByAreaId(zone.id) or 0)
        local parent = info and C_Map.GetMapInfo(info.parentMapID)
        if parent and parent.mapType == Enum.UIMapType.Continent then
            counts[parent.mapID] = (counts[parent.mapID] or 0) + 1
            if not best or counts[parent.mapID] > counts[best] then
                best = parent.mapID
            end
        end
    end
    return best and counts[best] > 1 and best or nil
end

local function _ReadMaps()
    if zonesByMap then
        return
    end
    zonesByMap, mapsByGroup = {}, {}
    for _, group in ipairs(JourneyPlaces.GetGroups()) do
        local zones = JourneyPlaces.GetZones(group.id)
        mapsByGroup[group.id] = _GetCommonMap(zones)
        for _, zone in ipairs(zones) do
            local uiMapId = zone.id > 0 and ZoneDB:GetUiMapIdByAreaId(zone.id)
            if uiMapId and not zonesByMap[uiMapId] then
                zonesByMap[uiMapId] = zone
            end
        end
    end
end

---@param uiMapId UiMapId
---@return JourneyPlace? zone
function JourneyPlaces.GetZoneOfMap(uiMapId)
    _ReadMaps()
    return zonesByMap[uiMapId]
end

---@param uiMapId UiMapId
---@return JourneyPlace? continent
function JourneyPlaces.GetContinentOfMap(uiMapId)
    _ReadMaps()
    for groupId, groupMap in pairs(mapsByGroup) do
        if groupMap == uiMapId then
            return {id = groupId, name = JourneyPlaces.GetGroupName(groupId)}
        end
    end
end

-------------------------
-- Factions
-------------------------

---@return JourneyPlace[] factions Sorted by name
function JourneyPlaces.GetFactions()
    local factions = {}
    for _, names in pairs(QuestieJourney.factionsByExpansion) do
        for id, name in pairs(names) do
            table.insert(factions, {id = id, name = name})
        end
    end
    table.sort(factions, _IsNameBefore)
    return factions
end

---@param factionId FactionId
---@return string name Empty when there is none
function JourneyPlaces.GetFactionName(factionId)
    for _, names in pairs(QuestieJourney.factionsByExpansion) do
        if names[factionId] then
            return names[factionId]
        end
    end
    return ""
end

-------------------------
-- Sources
-------------------------

---@param source JourneySource
---@return string kind
---@return number? id
function JourneyPlaces.Split(source)
    local kind, id = source:match("^(%a+):(%-?%d+)$")
    return kind or source, tonumber(id)
end

---@param source JourneySource
---@return string
function JourneyPlaces.GetName(source)
    local kind, id = JourneyPlaces.Split(source)
    if kind == JourneyPlaces.ALL then
        return l10n("All Quests")
    elseif kind == "faction" then
        return JourneyPlaces.GetFactionName(id)
    end
    return JourneyPlaces.GetZoneName(id)
end

---Yields, so it runs in a thread.
---@async
---@param source JourneySource
---@return table<QuestId, any>
function JourneyPlaces.GetQuestIds(source)
    local kind, id = JourneyPlaces.Split(source)
    if kind == JourneyPlaces.ALL then
        local questIds = {}
        for _, quests in pairs(QuestieJourney.zoneMap) do
            for questId in pairs(quests) do questIds[questId] = true end
            JourneyThread.YieldIfNeeded()
        end
        return questIds
    elseif kind == "faction" then
        return QuestieJourney.factionMap[id] or {}
    end
    return QuestieJourney.zoneMap[id] or {}
end

-------------------------
-- Search
-------------------------

---@param places JourneyPlace[]
---@param query string In lower case
---@return JourneyPlace[] matches Those that start with it come first
local function _Filter(places, query)
    local starting, containing = {}, {}
    for _, place in ipairs(places) do
        local position = place.name:lower():find(query, 1, true)
        if position then
            table.insert(position == 1 and starting or containing, place)
        end
    end
    for _, place in ipairs(containing) do
        table.insert(starting, place)
    end
    return starting
end

---@param query string
---@return JourneyPlace[] zones
---@return JourneyPlace[] factions
function JourneyPlaces.Search(query)
    local allZones = {}
    for _, group in ipairs(JourneyPlaces.GetGroups()) do
        for _, zone in ipairs(JourneyPlaces.GetZones(group.id)) do
            table.insert(allZones, zone)
        end
    end
    query = query:lower()
    return _Filter(allZones, query), _Filter(JourneyPlaces.GetFactions(), query)
end

---@param place JourneyPlace
---@param query string
---@return boolean
function JourneyPlaces.StartsWith(place, query)
    return place.name:lower():find(query:lower(), 1, true) == 1
end

return JourneyPlaces
