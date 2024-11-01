---@class DistanceUtils
local DistanceUtils = QuestieLoader:CreateModule("DistanceUtils")

---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

local HBD = LibStub("HereBeDragonsQuestie-2.0")

---@param spawns table<AreaId, CoordPair[]>>
---@return CoordPair, AreaId, number
function DistanceUtils.GetNearestSpawn(spawns)
    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone

    local playerX, playerY, playerI = HBD:GetPlayerWorldPosition()

    for zoneId, spawnEntries in pairs(spawns) do
        for _, spawn in pairs(spawnEntries) do
            local uiMapId = ZoneDB:GetUiMapIdByAreaId(zoneId)
            local dX, dY, dInstance = HBD:GetWorldCoordinatesFromZone(spawn[1] / 100.0, spawn[2] / 100.0, uiMapId)
            local dist = HBD:GetWorldDistance(dInstance, playerX, playerY, dX, dY)
            if dist then
                if dInstance ~= playerI then
                    dist = 500000 + dist * 100 -- hack
                end
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


return DistanceUtils
