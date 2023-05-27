---@class ZoneDB
local ZoneDB = QuestieLoader:CreateModule("ZoneDB")
---@type ZoneDBPrivate
ZoneDB.private = ZoneDB.private or {}

local _ZoneDB = ZoneDB.private

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

local areaIdToUiMapId = ZoneDB.private.areaIdToUiMapId or {}
local uiMapIdToAreaId = ZoneDB.private.uiMapIdToAreaId or {}
local dungeons = ZoneDB.private.dungeons or {}
local dungeonLocations = ZoneDB.private.dungeonLocations or {}
local dungeonParentZones = ZoneDB.private.dungeonParentZones or {}
local subZoneToParentZone = ZoneDB.private.subZoneToParentZone or {}

---Zone ids enum
ZoneDB.zoneIDs = ZoneDB.private.zoneIDs or {}


-- Overrides for UiMapId to AreaId
local UiMapIdOverrides = {
    [246] = 3713
}
local parentZoneToSubZone = {} -- Generated
local zoneMap = {} -- Generated


function ZoneDB:Initialize()
    _ZoneDB:GenerateParentZoneToStartingZoneTable()

    -- Run tests if debug enabled
    if Questie.db.global.debugEnabled then
        _ZoneDB:RunTests()
    end
end

function _ZoneDB:GenerateParentZoneToStartingZoneTable()
    for startingZone, parentZone in pairs(subZoneToParentZone) do
        parentZoneToSubZone[parentZone] = startingZone
    end
end

function ZoneDB:GetDungeons()
    return dungeons
end

---@param areaId AreaId
---@return UiMapId
function ZoneDB:GetUiMapIdByAreaId(areaId)
    return areaIdToUiMapId[areaId]
end

--- Use with care, kind of slow.
---@param uiMapId UiMapId
---@return AreaId
function ZoneDB:GetAreaIdByUiMapId(uiMapId)
    --? Some areas have multiple areaIds, so we return the correct AreaId
    if UiMapIdOverrides[uiMapId] then
        return UiMapIdOverrides[uiMapId]
    end

    local foundId
    -- First we look for a direct match
    for AreaUiMapId, lAreaId in pairs(uiMapIdToAreaId) do
        local areaId = lAreaId
        if (AreaUiMapId == uiMapId and not foundId) then
            --Questie:Debug(Questie.DEBUG_DEVELOP, "[ZoneDB:GetAreaIdByUiMapId] : ", " AreaUiMapId: ", AreaUiMapId, " ==  uiMapId: ", uiMapId, " and areaId = ", areaId, " foundID is nil")
            foundId = areaId
        elseif AreaUiMapId == uiMapId and foundId ~= AreaUiMapId then
            -- If we find a second match that does not match the first
            -- Print an error, but we still return the first one we found.

            -- Only print if debug is enabled.
            if Questie.db.global.debugEnabled then
                Questie:Error("[ZoneDB:GetAreaIdByUiMapId] : ", "UiMapId", uiMapId, "has multiple AreaIds:", foundId, areaId)
            end
        end
    end
    if foundId then -- debug --TechnoHunter adding debug print to report found AreaId
        --if Questie.db.global.debugEnabled then
            --local uiMapInfo = C_Map.GetMapInfo(uiMapId)
            --local foundName = C_Map.GetAreaInfo(foundId)
            --Questie:Debug(Questie.DEBUG_DEVELOP, "[ZoneDB:GetAreaIdByUiMapId] : ", "Found AreaId", foundName, ":", foundId, " for UiMapId", uiMapInfo.name, ":", uiMapId, "direct match")
        --end
        return foundId
    else
        -- As a last resort we try to match AreaId and UiMapId by name
        -- uses the original table in zoneTables as the area id's are
        -- all in that and we dont care if the uiMapId is there or not
        for areaId in pairs(areaIdToUiMapId) do
            local mapInfo = C_Map.GetMapInfo(uiMapId)
            local areaName = C_Map.GetAreaInfo(areaId)
            if mapInfo and mapInfo.name == areaName then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[ZoneDB:GetAreaIdByUiMapId] : ", "Found AreaId", areaName, ":", areaId, "for UiMapId", mapInfo.name, ":", uiMapId, "by name")
                return areaId
            end
        end
        error("No AreaId found for UiMapId: " .. uiMapId .. ":" .. C_Map.GetMapInfo(uiMapId).name)
    end
end


---@param areaId AreaId
function ZoneDB:GetDungeonLocation(areaId)
    return dungeonLocations[areaId]
end

---@param areaId AreaId
function ZoneDB.IsDungeonZone(areaId)
    return dungeonLocations[areaId] ~= nil
end

---@param areaId AreaId
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

---@param areaId AreaId
function ZoneDB:GetParentZoneId(areaId)
    return dungeonParentZones[areaId] or subZoneToParentZone[areaId]
end


-- We keep localized variables outside of the function only used by GetZonesWithQuests
do
    -- This is for yielding
    local yieldAmount = 200
    local extraYield = yieldAmount / 4

    --Keep yield here as there is potentially a case where this wants to be run outside of a coroutine

    ---@param yield boolean?
    ---@return table
    function ZoneDB:GetZonesWithQuests(yield)
        local count = 0

        for questId in pairs(QuestieDB.QuestPointers) do
            if (not QuestieCorrections.hiddenQuests[questId]) then
                if QuestiePlayer.HasRequiredRace(QuestieDB.QueryQuestSingle(questId, "requiredRaces"))
                    and QuestiePlayer.HasRequiredClass(QuestieDB.QueryQuestSingle(questId, "requiredClasses")) then

                    local zoneOrSort, requiredSkill = QuestieDB.QueryQuestSingle(questId, "zoneOrSort"), QuestieDB.QueryQuestSingle(questId, "requiredSkill")
                    if requiredSkill and requiredSkill[1] ~= QuestieProfessions.professionKeys.RIDING then
                        zoneOrSort = QuestieProfessions:GetSortIdByProfessionId(requiredSkill[1])

                        if (not zoneMap[zoneOrSort]) then
                            zoneMap[zoneOrSort] = {}
                        end
                        zoneMap[zoneOrSort][questId] = true
                    elseif zoneOrSort > 0 then
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
                        -- This branch is kind of expensive so yield more often if it happens a lot
                        local startedBy = QuestieDB.QueryQuestSingle(questId, "startedBy")

                        if startedBy then
                            zoneMap = _ZoneDB:GetZonesWithQuestsFromNPCs(zoneMap, startedBy[1])
                            zoneMap = _ZoneDB:GetZonesWithQuestsFromObjects(zoneMap, startedBy[2])
                        end
                        if yield then
                            count = count + extraYield
                            if count >= yieldAmount then
                                count = 0
                                coroutine.yield()
                            end
                        end

                        local finishedBy = QuestieDB.QueryQuestSingle(questId, "finishedBy")
                        if finishedBy then
                            zoneMap = _ZoneDB:GetZonesWithQuestsFromNPCs(zoneMap, finishedBy[1])
                            zoneMap = _ZoneDB:GetZonesWithQuestsFromObjects(zoneMap, finishedBy[2])
                        end
                        if yield then count = count + extraYield end
                    end
                end
            end

            if yield then
                if count >= yieldAmount then
                    count = 0
                    coroutine.yield()
                end
                count = count + 1
            end
        end
        if yield then coroutine.yield() end
        zoneMap = _ZoneDB:SplitSeasonalQuests()

        return zoneMap
    end
end


---@param zoneOrSort ZoneOrSort
function _ZoneDB:IsSpecialQuest(zoneOrSort)
    for _, v in pairs(QuestieDB.sortKeys) do
        if zoneOrSort == v then
            return true
        end
    end
    return false
end

---@param zones any @ I have no idea what this is does or looks
---@param npcIds NpcId[]
---@return any @ Ditto
function _ZoneDB:GetZonesWithQuestsFromNPCs(zones, npcIds)
    if (not npcIds) then
        return zones
    end

    for npcId in pairs(npcIds) do
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
---@param zones any @ I have no idea what this is does or looks
---@param objectIds ObjectId[]
---@return any @ Ditto
function _ZoneDB:GetZonesWithQuestsFromObjects(zones, objectIds)
    if (not objectIds) then
        return zones
    end

    for objectId in pairs(objectIds) do
        local spawns = QuestieDB.QueryObjectSingle(objectId, "spawns")
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
    if (not zoneMap[QuestieDB.sortKeys.SPECIAL]) or (not zoneMap[QuestieDB.sortKeys.SEASONAL]) then
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
        elseif eventName == "Children's Week" then
            updatedZoneMap[-401][questId] = true
        elseif eventName == "Harvest Festival" then
            updatedZoneMap[-402][questId] = true
        elseif eventName == "Hallow's End" then
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
    for category, data in pairs(l10n.zoneCategoryLookup) do
        zones[category] = {}
        for id, zoneName in pairs(data) do
            local zoneQuests = zoneMap[id]
            if (not zoneQuests) then
                zones[category][id] = nil
            else
                zones[category][id] = l10n(zoneName)
            end
        end
    end

    return zones
end



----- Tests -----

function _ZoneDB:RunTests()
    -- Fetch all UiMapIds (WOTLK/TBC, ERA)
    local maps = C_Map.GetMapChildrenInfo(946, nil, true) or C_Map.GetMapChildrenInfo(947, nil, true)
    Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("ZoneDBTests", "yellow") .. "] Testing ZoneDB")
    local buggedMaps = {
        [306] = true, -- ScholomanceOLD
        [307] = true, -- ScholomanceOLD
        [308] = true, -- ScholomanceOLD
        [309] = true, -- ScholomanceOLD
    }
    for _, map in pairs(maps) do
        --- We don't care about World, Continent or Cosmic
        if map.mapType ~= Enum.UIMapType.World and map.mapType ~= Enum.UIMapType.Continent and map.mapType ~= Enum.UIMapType.Cosmic then
            local success, result = pcall(ZoneDB.GetAreaIdByUiMapId, ZoneDB, map.mapID)
            if not success and not buggedMaps[map.mapID] then
                Questie:Error("[ZoneDBTests] ZoneDB.GetAreaIdByUiMapId fails for " .. map.name .. " (" .. map.mapID .. "). Result: " .. result)
            end

        end
    end
    Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("ZoneDBTests", "yellow") .. "] Testing ZoneDB done")
end
