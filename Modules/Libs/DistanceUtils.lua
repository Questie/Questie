---@class DistanceUtils
local DistanceUtils = QuestieLoader:CreateModule("DistanceUtils")

---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local HBD = LibStub("HereBeDragonsQuestie-2.0")

local _GetDistance
local alreadyErroredZoneIds = {}

---@param spawns table<AreaId, CoordPair[]>>
---@return CoordPair, AreaId, number
function DistanceUtils.GetNearestSpawn(spawns)
    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone

    local playerX, playerY, playerI = HBD:GetPlayerWorldPosition()
    if (not playerX) or (not playerY) then
        playerX, playerY = 0, 0
    end

    for zoneId, spawnEntries in pairs(spawns) do
        for _, spawn in pairs(spawnEntries) do
            if spawn[1] == -1 or spawn[2] == -1 then
                local dungeonLocation = ZoneDB:GetDungeonLocation(zoneId)
                if (not dungeonLocation) and (not alreadyErroredZoneIds[zoneId]) then
                    alreadyErroredZoneIds[zoneId] = true
                    Questie:Error("No dungeon location found for zoneId:", zoneId, "Please report this on Github or Discord!")
                end
                for _, location in pairs(dungeonLocation or {}) do
                    local dist = _GetDistance(location[1], location[2], location[3], playerX, playerY, playerI)
                    if dist < bestDistance then
                        bestDistance = dist
                        bestSpawn = {location[2], location[3]}
                        bestSpawnZone = location[1]
                    end
                end
            else
                local dist = _GetDistance(zoneId, spawn[1], spawn[2], playerX, playerY, playerI)
                if dist < bestDistance then
                    bestDistance = dist
                    bestSpawn = spawn
                    bestSpawnZone = zoneId
                end
            end
        end
    end

    return bestSpawn, bestSpawnZone, bestDistance
end

---@param objectiveSpawnList SpawnListBase[]
---@return CoordPair, AreaId, string, number
function DistanceUtils.GetNearestObjective(objectiveSpawnList)
    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone, bestSpawnName

    for _, spawnData in pairs(objectiveSpawnList) do
        local spawn, zone, distance = DistanceUtils.GetNearestSpawn(spawnData.Spawns)
        if distance < bestDistance then
            bestDistance = distance
            bestSpawn = spawn
            bestSpawnZone = zone
            bestSpawnName = spawnData.Name
        end
    end

    return bestSpawn, bestSpawnZone, bestSpawnName, bestDistance
end

---@param finisherOrStarter Finisher|Starters
---@return CoordPair, AreaId, string, number
function DistanceUtils.GetNearestFinisherOrStarter(finisherOrStarter)
    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone, bestSpawnName

    for _, npcId in pairs(finisherOrStarter.NPC or {}) do
        local npc = QuestieDB:GetNPC(npcId)
        if npc and npc.spawns and npc.friendly then
            local spawn, zone, distance = DistanceUtils.GetNearestSpawn(npc.spawns)
            if distance < bestDistance then
                bestDistance = distance
                bestSpawn = spawn
                bestSpawnZone = zone
                bestSpawnName = npc.name
            end
        end
    end

    for _, objectId in pairs(finisherOrStarter.GameObject or {}) do
        local object = QuestieDB:GetObject(objectId)
        if object and object.spawns then
            local spawn, zone, distance = DistanceUtils.GetNearestSpawn(object.spawns)
            if distance < bestDistance then
                bestDistance = distance
                bestSpawn = spawn
                bestSpawnZone = zone
                bestSpawnName = object.name
            end
        end
    end

    return bestSpawn, bestSpawnZone, bestSpawnName, bestDistance
end

---@param quest Quest
---@return CoordPair, AreaId, string, number
function DistanceUtils.GetNearestSpawnForQuest(quest)
    if quest:IsComplete() == 1 then
        return DistanceUtils.GetNearestFinisherOrStarter(quest.Finisher)
    end

    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone, bestSpawnName

    for _, objective in pairs(quest.Objectives) do
        if  ((not objective.Needed) or objective.Needed ~= objective.Collected) then
            local spawn, zone, Name, dist = DistanceUtils.GetNearestObjective(objective.spawnList)
            if spawn and dist < bestDistance then
                bestDistance = dist
                bestSpawn = spawn
                bestSpawnZone = zone
                bestSpawnName = Name
            end
        end
    end

    for _, objective in pairs(quest.SpecialObjectives) do
        if objective.spawnList and ((not objective.Needed) or objective.Needed ~= objective.Collected) then
            local spawn, zone, Name, dist = DistanceUtils.GetNearestObjective(objective.spawnList)
            if spawn and dist < bestDistance then
                bestDistance = dist
                bestSpawn = spawn
                bestSpawnZone = zone
                bestSpawnName = Name
            end
        end
    end

    return bestSpawn, bestSpawnZone, bestSpawnName, bestDistance
end

---@param zoneId AreaId
---@param spawnX X
---@param spawnY Y
---@param playerX X
---@param playerY Y
---@param playerZone AreaId
---@return number
_GetDistance = function(zoneId, spawnX, spawnY, playerX, playerY, playerZone)
    local uiMapId = ZoneDB:GetUiMapIdByAreaId(zoneId)
    local dX, dY, dInstance = HBD:GetWorldCoordinatesFromZone(spawnX / 100.0, spawnY / 100.0, uiMapId)
    local dist = QuestieLib.Euclid(playerX, playerY, dX, dY)
    if dInstance ~= playerZone then
        dist = 500000 + dist * 100 -- hack
    end
    return dist
end

return DistanceUtils
