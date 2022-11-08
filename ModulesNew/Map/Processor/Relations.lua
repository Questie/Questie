---@class RelationMapProcessor
local RelationMapProcessor = QuestieLoader:CreateModule("RelationMapProcessor")
local QuestEventBus = QuestieLoader:ImportModule("QuestEventBus")

local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

local MapCoodinates = QuestieLoader:ImportModule("MapCoordinates")

-- Pin Mixin
local RelationPinMixin = QuestieLoader:ImportModule("RelationPinMixin")
---@type RelationRenderers
local RelationRenderers = QuestieLoader:ImportModule("RelationRenderers")

-- Math
local abs, sqrt = math.abs, math.sqrt
local tInsert = table.insert
local lRound = Round


local wayPointColor = { r = 1, g = 0.72, b = 0, a = 0.5 }
local wayPointColorHover = { r = 0.93, g = 0.46, b = 0.13, a = 0.8 }
local defaultLineDataMap = { thickness = 4 }
Mixin(defaultLineDataMap, wayPointColor)

local function Initialize()
    QuestEventBus:RegisterRepeating(QuestEventBus.events.CALCULATED_AVAILABLE_QUESTS, RelationMapProcessor.ProcessAvailableQuests)
    QuestEventBus:RegisterRepeating(QuestEventBus.events.CALCULATED_COMPLETED_QUESTS, RelationMapProcessor.ProcessCompletedQuests)
end

C_Timer.After(0, Initialize)

---Get the dungeon locations in the correct format or false(because we can't save nil)
---@param AreaId AreaId
---@return false|Coordinates[]
local function getDungeonLocations(AreaId)
    local dungeonLocation = ZoneDB:GetDungeonLocation(AreaId)

    ---@type table<AreaId, Coordinates>
    local locations = {}
    if dungeonLocation ~= nil then
        for _, dungeonCoords in ipairs(dungeonLocation) do
            ---@type AreaId, MapX, MapY
            local areaId, x, y = dungeonCoords[1], dungeonCoords[2], dungeonCoords[3]

            if (not locations[areaId]) then
                locations[areaId] = { x = {}, y = {} } --, areaId = areaId
            end
            -- Add the coordinates to the table
            locations[areaId].x[#locations[areaId].x + 1] = x
            locations[areaId].y[#locations[areaId].y + 1] = y
        end
        return locations
    else
        return false
    end
end

--- A memoized version of the getDungeonLocations function
--- Just use it as a regular table
---@type table<AreaId, Coordinates[]>>
local DungeonLocations = setmetatable({}, {
    __index = function(self, k)
        local v = getDungeonLocations(k);
        self[k] = v
        return v;
    end,
})

---comment
---@param starterIcons table<UiMapId, AvailablePoints>
---@param id NpcId|ObjectId|ItemId
---@param data table
---@param idType RelationPointType
---@param QuerySingleFunction fun(id: NpcId|ObjectId|ItemId, query: "spawns"): table<AreaId, {[1]: MapX, [2]: MapY}[]>>
---@param itemId ItemId? -- This is used to override the ID which is added into starterIcons
function RelationMapProcessor.GetSpawns(starterIcons, id, data, idType, QuerySingleFunction, itemId)
    if starterIcons == nil or type(starterIcons) ~= "table" then
        error("GetSpawns called with invalid starterIcons")
        return
    elseif id == nil or type(id) ~= "number" then
        error("GetSpawns called with invalid id")
        return
    elseif data == nil or type(data) ~= "table" then
        error("GetSpawns called with invalid data")
        return
    elseif idType ~= "npc" and idType ~= "object" and idType ~= "item" and idType ~= "npcFinisher" and idType ~= "objectFinisher" then
        error("GetSpawns called with invalid type")
        return
    elseif QuerySingleFunction == nil or type(QuerySingleFunction) ~= "function" then
        error("GetSpawns called with invalid QuerySingleFunction")
        return
    elseif itemId ~= nil and type(itemId) ~= "number" and idType == "item" then
        error("GetSpawns called with invalid itemId")
        return
    end
    local spawns = QuerySingleFunction(id, "spawns")
    if spawns ~= nil then
        ---@type table<AreaId, {x: MapX[], y: MapY[]}>>
        local starter = {}
        for SpawnAreaId, coords in pairs(spawns) do

            local dungeonLocation = DungeonLocations[SpawnAreaId]

            if starter[SpawnAreaId] == nil and not dungeonLocation then
                starter[SpawnAreaId] = { x = {}, y = {}, questId = {} }
            end

            if not dungeonLocation then
                for coordIndex = 1, #coords do
                    local coord = coords[coordIndex]
                    -- Add the coordinates to the table
                    starter[SpawnAreaId].x[#starter[SpawnAreaId].x + 1] = coord[1]
                    starter[SpawnAreaId].y[#starter[SpawnAreaId].y + 1] = coord[2]
                end
            else
                for areaId, dungeonCoords in pairs(dungeonLocation) do
                    if starter[areaId] == nil then
                        starter[areaId] = { x = {}, y = {}, questId = {} } --, areaId = areaId
                    end
                    for coordIndex = 1, #dungeonCoords.x do
                        local x = dungeonCoords.x[coordIndex]
                        local y = dungeonCoords.y[coordIndex]
                        -- Add the coordinates to the table
                        starter[areaId].x[#starter[areaId].x + 1] = x
                        starter[areaId].y[#starter[areaId].y + 1] = y
                    end
                end
            end
        end
        for areaId, coords in pairs(starter) do
            if coords.x and coords.y then
                for i = 1, #coords.x do


                    local UiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
                    local x = coords.x[i]
                    local y = coords.y[i]

                    -- We only want to handle Maps that are on the worldmap
                    if MapCoodinates.Maps[UiMapId] then
                        if starterIcons[UiMapId] == nil then
                            starterIcons[UiMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {} }
                        end
                        local worldX, worldY = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(x, y)
                        local index = #starterIcons[UiMapId].x + 1
                        starterIcons[UiMapId].x[index] = x
                        starterIcons[UiMapId].y[index] = y
                        starterIcons[UiMapId].iconData[index] = data
                        starterIcons[UiMapId].id[index] = itemId or id
                        starterIcons[UiMapId].type[index] = idType

                        -- All nearby zones but also continents.
                        for NearByUiMapId, _ in pairs(MapCoodinates.Maps[UiMapId].nearbyZones) do
                            if MapCoodinates.Maps[NearByUiMapId] then
                                local mapX, mapY = MapCoodinates.Maps[NearByUiMapId]:ToMapCoordinate(worldX, worldY)
                                if mapX > 0 and mapX < 100 and mapY > 0 and mapY < 100 then
                                    if starterIcons[NearByUiMapId] == nil then
                                        starterIcons[NearByUiMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {} }
                                    end
                                    index = #starterIcons[NearByUiMapId].x + 1
                                    starterIcons[NearByUiMapId].x[index] = mapX
                                    starterIcons[NearByUiMapId].y[index] = mapY
                                    starterIcons[NearByUiMapId].iconData[index] = data
                                    starterIcons[NearByUiMapId].id[index] = itemId or id
                                    starterIcons[NearByUiMapId].type[index] = idType
                                end
                            end
                        end

                        -- Add to world map
                        local worldMapId = MapCoodinates.Maps[UiMapId].worldMapId
                        if not MapCoodinates.Maps[worldMapId] then
                            if starterIcons[worldMapId] == nil then
                                starterIcons[worldMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {} }
                            end
                            index = #starterIcons[worldMapId].x + 1
                            -- This is a bit of a special case WorldX/Y is basicall MapX/Y for the worldMapId
                            starterIcons[worldMapId].x[index] = worldX --[[@as MapX]]
                            starterIcons[worldMapId].y[index] = worldY --[[@as MapY]]
                            starterIcons[worldMapId].iconData[index] = data
                            starterIcons[worldMapId].id[index] = itemId or id
                            starterIcons[worldMapId].type[index] = idType
                        end
                    end
                end
            end
        end
    end
    return starterIcons
end

local SplineLib = CreateCatmullRomSpline(2);

---@param starterWaypoints table<UiMapId, AvailablePoints>
---@param id NpcId|ObjectId|ItemId
---@param data table
---@param idType RelationPointType
---@param QuerySingleFunction fun(id: NpcId|ObjectId|ItemId, query: "waypoints"): table<AreaId, {[1]: MapX, [2]: MapY}[]>>
---@param itemId ItemId? -- This is used to override the ID which is added into starterWaypoints
function RelationMapProcessor.GetWaypoints(starterWaypoints, id, data, idType, QuerySingleFunction, itemId)
    if starterWaypoints == nil or type(starterWaypoints) ~= "table" then
        error("GetSpawns called with invalid starterWaypoints")
        return
    elseif id == nil or type(id) ~= "number" then
        error("GetSpawns called with invalid id")
        return
    elseif data == nil or type(data) ~= "table" then
        error("GetSpawns called with invalid data")
        return
    elseif idType ~= "npc" and idType ~= "object" and idType ~= "item" and idType ~= "npcFinisher" and idType ~= "objectFinisher" then
        error("GetSpawns called with invalid type")
        return
    elseif QuerySingleFunction == nil or type(QuerySingleFunction) ~= "function" then
        error("GetSpawns called with invalid QuerySingleFunction")
        return
    elseif itemId ~= nil and type(itemId) ~= "number" and idType == "item" then
        error("GetSpawns called with invalid itemId")
        return
    end
    local spawns = QuerySingleFunction(id, "waypoints")
    if spawns ~= nil then
        ---@type table<AreaId, {x: MapX[], y: MapY[], waypointIndex: number[]}>>
        local starter = {}
        for zoneId, waypointsList in pairs(spawns) do
            local UiMapId = ZoneDB:GetUiMapIdByAreaId(zoneId)
            local lastPos
            if starter[zoneId] == nil then
                starter[zoneId] = { x = {}, y = {}, questId = {}, waypointIndex = {} }
            end
            for waypointListIndex, rawWaypoints in pairs(waypointsList or {}) do
                SplineLib:ClearPoints()
                for waypointIndex = 1, # rawWaypoints do
                    local waypoint = rawWaypoints[waypointIndex]
                    SplineLib:AddPoint(waypoint[1], waypoint[2])
                end
                local newLines = {}
                local percentageBetweenPoints = 0.10
                for i = 2, SplineLib:GetNumPoints() do
                    for subPoint = 1, math.floor(1 / percentageBetweenPoints) do
                        --print(subPoint*percentageBetweenPoints)
                        --It should never be 0 or 1, but due to us starting on 1 we only need to check for 1
                        if (subPoint * percentageBetweenPoints ~= 1) then
                            local x, y = SplineLib:CalculatePointOnLocalCurveSegment(i, subPoint * percentageBetweenPoints)
                            local point = { x = x, y = y }
                            newLines[#newLines+1] = point
                        end
                    end
                end
                local pReduce = 0.03
                Bezier:init();
                Bezier:setPoints(newLines)
                --Bezier:setAutoStepScale(1)
                Bezier:reduce(pReduce)

                local points = Bezier:getPoints()
                lastPos = nil
                for pointIndex = 1, #points do
                    local point = points[pointIndex]
                    if (lastPos == nil) then
                        lastPos = point;
                    else
                        --local temp = {}
                        --MapHandler.RegisterCallback(temp, MapHandler.events.MAP.DRAW_WAYPOINTS_UIMAPID(UiMapId), drawMapLine, {UiMapId, lastPos.x/100, lastPos.y/100, point.x/100, point.y/100})
                        --local lineFrame = drawMinimapLine({UiMapId, lastPos.x/100, lastPos.y/100, point.x/100, point.y/100})
                        -- AvailableWaypoints:CreateWaypoint(UiMapId, lastPos.x/100, lastPos.y/100, point.x/100, point.y/100)
                        starter[zoneId].x[#starter[zoneId].x + 1] = lastPos.x
                        starter[zoneId].y[#starter[zoneId].y + 1] = lastPos.y
                        starter[zoneId].x[#starter[zoneId].x + 1] = point.x
                        starter[zoneId].y[#starter[zoneId].y + 1] = point.y
                        starter[zoneId].waypointIndex[#starter[zoneId].waypointIndex + 1] = waypointListIndex
                        starter[zoneId].waypointIndex[#starter[zoneId].waypointIndex + 1] = waypointListIndex
                        lastPos = point;
                    end
                end

                --TODO: Fix
                if (lastPos and lastPos ~= points[1]) then
                    local firstPoint = points[1]
                    -- local x1, y1 = HBD:GetWorldCoordinatesFromZone(lastPos.x/100, lastPos.y/100, UiMapId)
                    -- local x2, y2 = HBD:GetWorldCoordinatesFromZone(firstPoint.x/100, firstPoint.y/100, UiMapId)
                    if MapCoodinates.Maps[UiMapId] then
                        local x1, y1 = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(lastPos.x, lastPos.y)
                        local x2, y2 = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(firstPoint.x, firstPoint.y)

                        local sqDistance = math.sqrt(SquaredDistanceBetweenPoints(x1, y1, x2, y2))
                        --We get TexCoords error if the disatnce is to low!
                        if (sqDistance > 0.05 and sqDistance < 0.2) then
                            starter[zoneId].x[#starter[zoneId].x + 1] = lastPos.x
                            starter[zoneId].y[#starter[zoneId].y + 1] = lastPos.y
                            starter[zoneId].x[#starter[zoneId].x + 1] = firstPoint.x
                            starter[zoneId].y[#starter[zoneId].y + 1] = firstPoint.y
                            starter[zoneId].waypointIndex[#starter[zoneId].waypointIndex + 1] = waypointListIndex
                            starter[zoneId].waypointIndex[#starter[zoneId].waypointIndex + 1] = waypointListIndex
                        end
                    else
                        print(UiMapId)
                    end
                end
            end
        end
        for areaId, coords in pairs(starter) do
            if coords.x and coords.y then
                local UiMapId = ZoneDB:GetUiMapIdByAreaId(areaId)
                for i = 1, #coords.x do
                    local x = coords.x[i]
                    local y = coords.y[i]
                    local waypointIndex = coords.waypointIndex[i]

                    -- We only want to handle Maps that are on the worldmap
                    if MapCoodinates.Maps[UiMapId] then
                        if starterWaypoints[UiMapId] == nil then
                            starterWaypoints[UiMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {}, waypointIndex = {} }
                        end
                        local index = #starterWaypoints[UiMapId].x + 1
                        starterWaypoints[UiMapId].x[index] = x
                        starterWaypoints[UiMapId].y[index] = y
                        starterWaypoints[UiMapId].iconData[index] = data
                        starterWaypoints[UiMapId].id[index] = itemId or id
                        starterWaypoints[UiMapId].type[index] = idType
                        starterWaypoints[UiMapId].waypointIndex[index] = waypointIndex


                        --? If we ever want to enable this, here's the code, do not delete!
                        -- All nearby zones.
                        --[[
                        local worldX, worldY = MapCoodinates.Maps[UiMapId]:ToWorldCoordinate(x, y)
                        for NearByUiMapId, _ in pairs(MapCoodinates.Maps[UiMapId].nearbyZones) do
                            if MapCoodinates.Maps[NearByUiMapId] and MapCoodinates.MapInfo[NearByUiMapId].mapType >= 3 then
                                local mapX, mapY = MapCoodinates.Maps[NearByUiMapId]:ToMapCoordinate(worldX, worldY)
                                if mapX > 0 and mapX < 100 and mapY > 0 and mapY < 100 then
                                    if starterWaypoints[NearByUiMapId] == nil then
                                        starterWaypoints[NearByUiMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {}, waypointIndex = {} }
                                    end
                                    index = #starterWaypoints[NearByUiMapId].x + 1
                                    starterWaypoints[NearByUiMapId].x[index] = mapX
                                    starterWaypoints[NearByUiMapId].y[index] = mapY
                                    starterWaypoints[NearByUiMapId].iconData[index] = data
                                    starterWaypoints[NearByUiMapId].id[index] = itemId or id
                                    starterWaypoints[NearByUiMapId].type[index] = idType
                                    starterWaypoints[NearByUiMapId].waypointIndex[index] = waypointIndex
                                end
                            end
                        end

                        Add to world map
                        local worldMapId = MapCoodinates.Maps[UiMapId].worldMapId
                        if not MapCoodinates.Maps[worldMapId] then
                            if starterWaypoints[worldMapId] == nil then
                                starterWaypoints[worldMapId] = { x = {}, y = {}, iconData = {}, id = {}, type = {} }
                            end
                            index = #starterWaypoints[worldMapId].x + 1
                            -- This is a bit of a special case WorldX/Y is basicall MapX/Y for the worldMapId
                            starterWaypoints[worldMapId].x[index] = worldX --[ [@as MapX] ]
                            starterWaypoints[worldMapId].y[index] = worldY --[ [@as MapY] ]
                            starterWaypoints[worldMapId].iconData[index] = data
                            starterWaypoints[worldMapId].id[index] = itemId or id
                            starterWaypoints[worldMapId].type[index] = idType
                        end
                        ]] --
                    end
                end
            end
        end
    end
    return starterWaypoints
end


---comment
---@param ShowData Show
function RelationMapProcessor.ProcessCompletedQuests(ShowData)
    print("ProcessCompletedQuests")
    ---@type table<UiMapId, AvailablePoints>
    local finisherIcons = {}
    for npcId, npcData in pairs(ShowData.NPC) do
        if npcData.finisher then
            RelationMapProcessor.GetSpawns(finisherIcons, npcId, npcData.finisher, "npcFinisher", QuestieDB.QueryNPCSingle)
        end
    end
    for objectId, objectData in pairs(ShowData.GameObject) do
        if objectData.finisher then
            RelationMapProcessor.GetSpawns(finisherIcons, objectId, objectData.finisher, "objectFinisher", QuestieDB.QueryObjectSingle)
        end
    end

    -- We return the majority type to control the icon
    -- Hardcode the types because we already know them
    local majorityType = {
        ["npcFinisher"] = 0,
        ["objectFinisher"] = 0,
    }

    for UiMapId, data in pairs(finisherIcons) do
        local combinedGivers = RelationMapProcessor.CombineGivers(UiMapId, data, 4, 4)
        print("Finisher", UiMapId, #combinedGivers)
        for combinedGiverIndex = 1, #combinedGivers do
            local combinedGiver = combinedGivers[combinedGiverIndex]
            for _, idType in pairs(combinedGiver.type) do
                majorityType[idType] = majorityType[idType] + 1
            end
            local majority = "npcFinisher"
            if majorityType["objectFinisher"] > majorityType[majority] then
                majority = "objectFinisher"
            end
            ---@type RelationPoint
            local iconData = { uiMapId = UiMapId,
                x = combinedGiver.x,
                y = combinedGiver.y,
                frameLevel = lRound(combinedGiver.y),
                iconData = combinedGiver.iconData,
                id = combinedGiver.id,
                type = combinedGiver.type,
                majorityType = majority
            }
            --* Register draw
            MapEventBus:ObjectRegisterRepeating(iconData, MapEventBus.events.MAP.DRAW_RELATION_UIMAPID(UiMapId), RelationRenderers.Draw)
            MapEventBus:RegisterOnce(MapEventBus.events.MAP.REMOVE_ALL_COMPLETED, function()
                MapEventBus:ObjectUnregisterRepeating(iconData, MapEventBus.events.MAP.DRAW_RELATION_UIMAPID(UiMapId))
            end)
            --* Register tooltips
            -- for i = 1, #combinedGiver.id do
            --     local id = combinedGiver.id[i]
            --     local idType = combinedGiver.type[i]
            --     if not registered[idType] then
            --         registered[idType] = {}
            --     end
            --     if not registered[idType][id] then
            --         registered[idType][id] = true
            --         local object
            --         if idType == "npcFinisher" then
            --             object = QuestieQuest.Show.NPC[id]
            --         elseif idType == "objectFinisher" then
            --             object = QuestieQuest.Show.GameObject[id]
            --         -- elseif idType == "item" then
            --         --     object = QuestieQuest.Show.Item[id]
            --         end
            --         local tooltipFunction = function() MapTooltip.SimpleAvailableTooltip(id, idType, object) end
            --         local event = MapEventBus.events.TOOLTIP.ADD_AVAILABLE_TOOLTIP(id, idType)
            --         MapEventBus:ObjectRegisterRepeating(object.finisher, event, tooltipFunction)
            --         MapEventBus:RegisterOnce(MapEventBus.events.MAP.REMOVE_ALL_AVAILABLE, function()
            --             MapEventBus:ObjectUnregisterRepeating(object.finisher, event)
            --         end)
            --     end
            -- end
            -- Reset the type counters
            majorityType["npcFinisher"] = 0
            majorityType["objectFinisher"] = 0
        end
    end

    MapEventBus:Fire(MapEventBus.events.MAP.REDRAW_ALL)
end

---comment
---@param ShowData Show
function RelationMapProcessor.ProcessAvailableQuests(ShowData)
    print("ProcessAvailableQuests")
    ---@type table<UiMapId, AvailablePoints>
    local starterIcons = {}
    ---@type table<UiMapId, AvailablePoints>
    local starterWaypoints = {}
    for npcId, npcData in pairs(ShowData.NPC) do
        if npcData.available and npcData.finisher == nil then
            RelationMapProcessor.GetSpawns(starterIcons, npcId, npcData.available, "npc", QuestieDB.QueryNPCSingle)
            RelationMapProcessor.GetWaypoints(starterWaypoints, npcId, npcData.available, "npc", QuestieDB.QueryNPCSingle)
        end
    end
    for objectId, objectData in pairs(ShowData.GameObject) do
        if objectData.available and objectData.finisher == nil then
            RelationMapProcessor.GetSpawns(starterIcons, objectId, objectData.available, "object", QuestieDB.QueryObjectSingle)
        end
    end
    -- DevTools_Dump(starterWaypoints)

    --! Disabled because the insane amount of icons plus the multiple entries
    --! Also look at the combine givers the "alreadySpawned" stuff.
    --? These should probably be Polygons
    -- for itemId, itemData in pairs(ShowData.Item) do
    --     if itemData.available then
    --         local npcDrops = QuestieDB.QueryItemSingle(itemId, "npcDrops")
    --         if npcDrops then
    --             for _, npcId in pairs(npcDrops) do
    --                 RelationMapProcessor.GetSpawns(starterIcons, npcId, itemData.available, "item", QuestieDB.QueryNPCSingle, itemId)
    --             end
    --         end
    --     end
    -- end

    --? Trying to create a data object usable in polygons
    -- local availableItems = {}
    -- for itemId, itemData in pairs(ShowData.Item) do
    --     if itemData.available then
    --         local npcDrops = QuestieDB.QueryItemSingle(itemId, "npcDrops")
    --         if npcDrops then
    --             local starterIconsItem = {dropsItem = itemId, starterIcons = nil}
    --             for _, npcId in pairs(npcDrops) do
    --                 if not availableItems[npcId] then
    --                     local npcData = {}
    --                     RelationMapProcessor.GetSpawns(npcData, npcId, itemData.available, "npc", QuestieDB.QueryNPCSingle, itemId)
    --                     starterIconsItem.starterIcons = npcData
    --                     availableItems[npcId] = starterIconsItem
    --                 end
    --             end
    --         end
    --     end
    -- end
    -- DevTools_Dump(availableItems)

    -- Start / End coordinates
    local sX, sY, eX, eY
    for UiMapId, data in pairs(starterWaypoints) do
        for i = 1, #data.x do
            if data.id[i] == data.id[i + 1] then
                if data.waypointIndex[i] and data.waypointIndex[i + 1] and
                    data.waypointIndex[i] == data.waypointIndex[i + 1] then
                    if data.x[i] and data.y[i] and data.x[i + 1] and data.y[i + 1] then
                        sX = data.x[i] / 100
                        sY = data.y[i] / 100
                        eX = data.x[i + 1] / 100
                        eY = data.y[i + 1] / 100

                        -- Determine dimensions and center point of line
                        local dx, dy = eX - sX, eY - sY;

                        -- Normalize direction if necessary
                        if (dx < 0) then
                            dx, dy = -dx, -dy;
                        end
                        -- If these are zero then the distance is 0
                        if dx ~= 0 or dy ~= 0 then
                            --* Calculate the rectangle corners
                            --? Information can be found: https://stackoverflow.com/questions/1936934/turn-a-line-into-a-rectangle
                            local lineLength = sqrt(dx * dx + dy * dy)
                            dx = dx / lineLength
                            dy = dy / lineLength
                            local thickness = (0.0015 / 4) * defaultLineDataMap.thickness -- old 0.0013
                            local px = thickness * (-dy)
                            local py = thickness * dx
                            local lineCornerPoints = {
                                { x = sX + px, y = sY + py }, -- x1, y1
                                { x = eX + px, y = eY + py }, -- x2, y2
                                { x = eX - px, y = eY - py }, -- x3, y3
                                { x = sX - px, y = sY - py }, -- x4, y4
                            }
                            ---@class WaypointPoint
                            local iconData = {
                                uiMapId = UiMapId,
                                sX = sX,
                                sY = sY,
                                eX = eX,
                                eY = eY,
                                id = data.id[i],
                                lineCornerPoints = lineCornerPoints,
                                defaultLineDataMap = defaultLineDataMap,
                            }
                            MapEventBus:ObjectRegisterRepeating(iconData, MapEventBus.events.MAP.DRAW_WAYPOINTS_UIMAPID(UiMapId), RelationRenderers.DrawWaypoint)
                            MapEventBus:RegisterOnce(MapEventBus.events.MAP.REMOVE_ALL_AVAILABLE, function()
                                MapEventBus:ObjectUnregisterRepeating(iconData, MapEventBus.events.MAP.DRAW_WAYPOINTS_UIMAPID(UiMapId))
                            end)
                        end
                    end
                end
            end
        end
        -- DevTools_Dump(MapCoodinates.MapInfo[UiMapId])
        -- break
    end


    -- We return the majority type to control the icon
    -- Hardcode the types because we already know them
    local majorityType = {
        ["item"] = 0,
        ["object"] = 0,
        ["npc"] = 0
    }
    for UiMapId, data in pairs(starterIcons) do
        local combinedGivers = RelationMapProcessor.CombineGivers(UiMapId, data, 7, 12)
        for combinedGiverIndex = 1, #combinedGivers do
            local combinedGiver = combinedGivers[combinedGiverIndex]
            for _, idType in pairs(combinedGiver.type) do
                majorityType[idType] = majorityType[idType] + 1
            end
            local majority = "npc"
            if majorityType["item"] > majorityType[majority] then
                majority = "item"
            end
            if majorityType["object"] > majorityType[majority] then
                majority = "object"
            end
            ---@type RelationPoint
            local iconData = { uiMapId = UiMapId,
                x = combinedGiver.x,
                y = combinedGiver.y,
                frameLevel = lRound(combinedGiver.y),
                iconData = combinedGiver.iconData,
                id = combinedGiver.id,
                type = combinedGiver.type,
                majorityType = majority
            }
            --* Register draw
            MapEventBus:ObjectRegisterRepeating(iconData, MapEventBus.events.MAP.DRAW_RELATION_UIMAPID(UiMapId), RelationRenderers.Draw)
            MapEventBus:RegisterOnce(MapEventBus.events.MAP.REMOVE_ALL_AVAILABLE, function()
                MapEventBus:ObjectUnregisterRepeating(iconData, MapEventBus.events.MAP.DRAW_RELATION_UIMAPID(UiMapId))
            end)
            -- Reset the type counters
            majorityType["item"] = 0
            majorityType["object"] = 0
            majorityType["npc"] = 0
        end
    end

    MapEventBus:Fire(MapEventBus.events.MAP.REDRAW_ALL)
end

---Absolute center, not average
-- -@param points table<number, Point> @Point list {x=0, y=0}
---@return MapX x, MapY y
local function AbsCenterPoint(points)
    --Localize the functions
    --local min, max = math.min, math.max
    local minX = 99999999999
    local minY = 99999999999
    local maxX = 0
    local maxY = 0
    local x, y
    local length = #points.x == #points.y and #points.x or 0
    if length == 0 then
        error("AbsCenterPoint: points.x and points.y must be the same length")
    end
    for pointIndex = 1, length do
        x = points.x[pointIndex]
        y = points.y[pointIndex]
        --? Inline is always faster than function call
        if (x and minX > x) then
            minX = x
        end
        if (y and minY > y) then
            minY = y
        end
        if (x and maxX < x) then
            maxX = x
        end
        if (y and maxY < y) then
            maxY = y
        end
        --minX = min(minX, point.x or point.orgX);
        --minY = min(minY, point.y or point.orgY);
        --maxX = max(maxX, point.x or point.orgX);
        --maxY = max(maxY, point.y or point.orgY);
    end
    --local fCenterX = minX + ((maxX - minX)/2)--local fCenterY = minY + ((maxY - minY)/2)
    ---@diagnostic disable-next-line: return-type-mismatch
    return minX + ((maxX - minX) / 2), minY + ((maxY - minY) / 2)
end

---Combines different gives with each other
---@param uiMapId UiMapId
---@param points AvailablePoints
---@param iconWidth number @Width in pixels
---@param iconHeight number @Height in pixels
---@return AvailablePoints[]
function RelationMapProcessor.CombineGivers(uiMapId, points, iconWidth, iconHeight)
    --print("calc1")
    if (points == nil) then return {} end

    points.touched = {}

    local worldMapFrameWidth = WorldMapFrame:GetWidth() * WorldMapFrame:GetEffectiveScale()
    local worldMapFrameHeight = WorldMapFrame:GetHeight() * WorldMapFrame:GetEffectiveScale()
    local distWidth = ConvertPixelsToUI(iconWidth * RelationPinMixin:GetIconScale(uiMapId), WorldMapFrame:GetEffectiveScale()) --actual = 12
    local distHeight = ConvertPixelsToUI(iconHeight * RelationPinMixin:GetIconScale(uiMapId), WorldMapFrame:GetEffectiveScale()) --actual = 29

    local length = #points.x == #points.y and #points.x or nil
    if length == nil then
        error("CombineGivers: points.x and points.y must be the same length")
    end

    ---@type AvailablePoints[]
    local returnPoints = {}

    local FoundUntouched = nil
    ---@type AvailablePoints
    local notes = { x = {}, y = {}, iconData = {}, id = {} }
    while (true) do
        FoundUntouched = nil;
        for sourcePointIndex = 1, length do
            if (points.touched[sourcePointIndex] == nil) then
                --! This stuff works, but i have to figure out a way to not also throw a way the coords.
                -- Prevent the same data from being added twice
                -- local alreadyAdded = {}

                --We touch this
                FoundUntouched = true;
                points.touched[sourcePointIndex] = true;

                local aX, aY = points.x[sourcePointIndex], points.y[sourcePointIndex] -- MapCoodinates.Maps[UiMapId]:ToMapCoordinate(points.x[sourcePointIndex], points.y[sourcePointIndex])
                if (aX and aY) then
                    notes = {
                        x = { aX },
                        y = { aY },
                        iconData = { points.iconData[sourcePointIndex] },
                        id = { points.id[sourcePointIndex] },
                        type = { points.type[sourcePointIndex] }
                    }
                    -- Add the first data to alreadyAdded
                    -- alreadyAdded[points.iconData[sourcePointIndex]] = true

                    --* tinsert(notes.? points.?) is the same as below
                    -- notes.x[#notes.x + 1] = points.x[sourcePointIndex]
                    -- notes.y[#notes.y + 1] = points.y[sourcePointIndex]
                    -- notes.iconData[#notes.iconData + 1] = points.iconData[sourcePointIndex]
                    -- notes.id[#notes.id + 1] = points.id[sourcePointIndex]

                    for targetPointIndex = 1, length do
                        if (points.touched[targetPointIndex] == nil) then
                            local bX, bY = points.x[targetPointIndex], points.y[targetPointIndex] --MapCoodinates.Maps[UiMapId]:ToMapCoordinate(points.x[targetPointIndex], points.y[targetPointIndex])
                            if (bX and bY) then
                                local dX = (aX / 100 - bX / 100)
                                local dY = (aY / 100 - bY / 100)
                                --? This is a fast math.abs function
                                if dX < 0 then
                                    dX = -dX
                                end
                                if dY < 0 then
                                    dY = -dY
                                end
                                dX = worldMapFrameWidth * dX
                                dY = worldMapFrameHeight * dY

                                if (dX < distWidth and dY < distHeight) then
                                    points.touched[targetPointIndex] = true
                                    -- If the data has previously been added already, don't add it again
                                    -- if not alreadyAdded[points.iconData[targetPointIndex]] then

                                    --* tinsert(notes.? points.?) is the same as below
                                    local index = #notes.x + 1
                                    notes.x[index] = points.x[targetPointIndex]
                                    notes.y[index] = points.y[targetPointIndex]
                                    notes.iconData[index] = points.iconData[targetPointIndex]
                                    notes.id[index] = points.id[targetPointIndex]
                                    notes.type[index] = points.type[targetPointIndex]

                                    -- alreadyAdded[points.iconData[targetPointIndex]] = true
                                    -- end
                                end
                            end
                        end
                    end
                    local x, y = AbsCenterPoint(notes)
                    returnPoints[#returnPoints + 1] = {
                        x = x,
                        y = y,
                        iconData = notes.iconData,
                        id = notes.id,
                        type = notes.type
                    }
                end
            end
        end
        if (FoundUntouched == nil) then
            points.touched = nil
            break
        end
    end
    return returnPoints
end
