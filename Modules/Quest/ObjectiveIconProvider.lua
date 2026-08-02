---@class ObjectiveIconProvider
local ObjectiveIconProvider = QuestieLoader:CreateModule("ObjectiveIconProvider")

-------------------------
--Import modules.
-------------------------
---@type SpawnListBuilders
local SpawnListBuilders = QuestieLoader:ImportModule("SpawnListBuilders")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type Phasing
local Phasing = QuestieLoader:ImportModule("Phasing")
---@type DistanceUtils
local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")

local LibStub = LibStub
local HBD = LibStub("HereBeDragonsQuestie-2.0")

local TICKS_PER_YIELD = 60
if Questie.IsHardcore then
    TICKS_PER_YIELD = 30
end

--- Resolves the spawn list for an objective if not already populated.
--- Pure data — no drawing, no coroutine required.
--- Mutates objective.spawnList and objective.Icon as a side effect.
---@param objective QuestObjective
---@param objectiveData table  quest.ObjectiveData[index] or objective itself for SpecialObjectives
function ObjectiveIconProvider:BuildSpawnList(objective, objectiveData)
    if (not objective.spawnList or (not next(objective.spawnList)))
        and SpawnListBuilders.builders[objectiveData.Type]
    then
        objective.spawnList = SpawnListBuilders.builders[objectiveData.Type](objective.Id, objective, objectiveData)
    end
end

--- Computes the set of icon candidates for an objective, keyed by distance.
--- Sets up objective.AlreadySpawned slots and caches world coordinates on each entry.
--- Yields periodically when called from a coroutine (large spawn lists).
--- Does NOT draw anything — pass the result to MapIconDrawer:DrawObjectiveIcons.
---@param quest Quest
---@param objective QuestObjective
---@param objectiveIndex ObjectiveIndex
---@param objectiveCenter {x:number, y:number}
---@return table iconsToDraw   keyed by distance; value is array of drawIcon entries
function ObjectiveIconProvider:BuildIconsToDraw(quest, objective, objectiveIndex, objectiveCenter)
    local iconsToDraw = {}

    local yieldCount = 0
    for id, spawnData in pairs(objective.spawnList) do
        if (not objective.Icon) and spawnData.Icon then
            objective.Icon = spawnData.Icon
        end

        if (not objective.AlreadySpawned[id]) and (not objective.Completed) and Questie.db.profile.enableObjectives then
            local data = {
                Id = quest.Id,
                ObjectiveIndex = objectiveIndex,
                QuestData = quest,
                ObjectiveData = objective,
                Icon = spawnData.Icon,
                IconColor = quest.Color,
                GetIconScale = spawnData.GetIconScale,
                IconScale = spawnData.GetIconScale(),
                Name = spawnData.Name,
                Type = objective.Type,
                ObjectiveTargetId = spawnData.Id,
            }

            objective.AlreadySpawned[id] = {
                data = data,
                minimapRefs = {},
                mapRefs = {},
            }

            for zone, spawns in pairs(spawnData.Spawns) do
                local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
                for _, spawn in pairs(spawns) do
                    if spawn[1] and spawn[2] and Phasing.IsSpawnVisible(spawn[3]) then
                        local drawIcon = {
                            AlreadySpawnedId = id,
                            data = data,
                            zone = zone,
                            AreaID = zone,
                            UiMapID = uiMapId,
                            x = spawn[1],
                            y = spawn[2],
                            worldX = 0,
                            worldY = 0,
                            distance = 0,
                            touched = nil, -- TODO: reserved for future use (memory layout hint)
                        }

                        local x, y = HBD:GetWorldCoordinatesFromZone(drawIcon.x / 100, drawIcon.y / 100, uiMapId)
                        if (not x) or (not y) then
                            x, y = 0, 0
                        end

                        drawIcon.worldX = x
                        drawIcon.worldY = y
                        local distance = QuestieLib.Euclid(objectiveCenter.x or 0, objectiveCenter.y or 0, x, y)
                        drawIcon.distance = distance or 0

                        local iconList = iconsToDraw[distance]
                        if iconList then
                            iconList[#iconList + 1] = drawIcon
                        else
                            iconsToDraw[distance] = {drawIcon}
                        end

                        yieldCount = yieldCount + 1
                        if yieldCount >= TICKS_PER_YIELD then
                            yieldCount = 0
                            coroutine.yield()
                        end
                    end
                end
            end
        end
    end

    return iconsToDraw
end

--- Computes the objective center point used for clustering (closest-first ordering).
--- Returns a world-coordinate {x, y} table. Falls back to {x=0, y=0} if unavailable.
--- Pure data — no drawing, no coroutine required.
---@param quest Quest
---@param objective QuestObjective
---@return {x:number, y:number}
function ObjectiveIconProvider:GetObjectiveCenter(quest, objective)
    local zoneCount = 0
    local objectiveZone

    for _, spawnData in pairs(objective.spawnList) do
        for zone in pairs(spawnData.Spawns) do
            if (not objectiveZone) or objectiveZone ~= zone then
                objectiveZone = zone
                zoneCount = zoneCount + 1
            end
        end
    end

    local objectiveCenter
    if zoneCount == 1 then
        local x, y = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, ZoneDB:GetUiMapIdByAreaId(objectiveZone))
        objectiveCenter = {x = x, y = y}
    else
        objectiveCenter = DistanceUtils.GetNearestFinisherOrStarter(quest.Starts)
    end

    if (not objectiveCenter) or (not objectiveCenter.x) or (not objectiveCenter.y) then
        objectiveCenter = {x = 0, y = 0}
    end

    return objectiveCenter
end
