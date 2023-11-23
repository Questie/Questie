---@class RelationMapProcessor
local RelationMapProcessor = QuestieLoader:CreateModule("RelationMapProcessor")
--- Bus Imports ---
---@type SystemEventBus
local SystemEventBus = QuestieLoader("SystemEventBus")
---@type QuestEventBus
local QuestEventBus = QuestieLoader("QuestEventBus")
---@type MapEventBus
local MapEventBus = QuestieLoader("MapEventBus")

--- Questie Imports ---
---@type QuestieDB
local QuestieDB = QuestieLoader("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader("ZoneDB")
---@type MapCoordinates
local MapCoodinates = QuestieLoader("MapCoordinates")
---@type RelationMapProcessor
local RelationMapProcessor = QuestieLoader("RelationMapProcessor")
---@type SpawnProcessor
local SpawnProcessor = QuestieLoader("SpawnProcessor")

--- Pin Imports ---
-- Pin Mixin
local RelationPinMixin = QuestieLoader:ImportModule("RelationPinMixin")
---@type RelationRenderers
local RelationRenderers = QuestieLoader:ImportModule("RelationRenderers")

--- Lib Imports ---
---@type ThreadLib
local ThreadLib = QuestieLoader("ThreadLib")

-- Math
local sqrt, floor = math.sqrt, math.floor
local wipe = wipe

local yield = coroutine.yield

--? These are important to keep cached information available, if they are wiped the CG will remove the data.
-- This contains references to the processed waypoints
-- Keeps the weak tables of ProcessedWaypoints from being garbage collected
local AvailableProcessedWaypoints = {}

-- This contains references to the processed waypoints
-- Keeps the weak tables of ProcessedWaypoints from being garbage collected
local CompleteProcessedWaypoints = {}

-- This contains references to the processed spawns
-- Keeps the weak tables of ProcessedSpawns from being garbage collected
local AvailableProcessedSpawns = {}

-- This contains references to the processed spawns
-- Keeps the weak tables of ProcessedSpawns from being garbage collected
local CompleteProcessedSpawns = {}
-- ************


local wayPointColor = { r = 1, g = 0.72, b = 0, a = 0.5 }
local wayPointColorHover = { r = 0.93, g = 0.46, b = 0.13, a = 0.8 }
local defaultLineDataMap = { thickness = 4 }
Mixin(defaultLineDataMap, wayPointColor)

local function Initialize()
    -- This logic allows the code to be cancelled if a new execution is started
    ---@type Ticker?, Ticker?
    local availableTimer, completeTimer
    QuestEventBus:RegisterRepeating(QuestEventBus.events.CALCULATE_AVAILABLE_QUESTS_DONE,
        function(show)
            -- Cancel the previous timer
            if availableTimer then
                availableTimer:Cancel()
            end
            availableTimer = ThreadLib.Thread(function()
                RelationMapProcessor.ProcessAvailableQuests(show)
                availableTimer = nil
            end, 0, "RelationMapProcessor.ProcessAvailableQuests")
        end)
    QuestEventBus:RegisterRepeating(QuestEventBus.events.CALCULATE_COMPLETED_QUESTS_DONE,
        function(show)
            -- Cancel the previous timer
            if completeTimer then
                completeTimer:Cancel()
            end
            completeTimer = ThreadLib.Thread(function()
                RelationMapProcessor.ProcessCompletedQuests(show)
                completeTimer = nil
            end, 0, "RelationMapProcessor.ProcessCompletedQuests")
        end)
end

SystemEventBus:RegisterOnce(SystemEventBus.events.INITIALIZE_DONE, Initialize)

--- Register the draw calls for the waypoints
---@param waypoints table<UiMapId, AvailableWaypointPoints>
---@param renderer function
---@param REMOVE_EVENT EventString
local function RegisterWaypoints(waypoints, renderer, REMOVE_EVENT)
    -- Start / End coordinates
    local sX, sY, eX, eY, dX, dY
    -- Made up "waypointId" which is incremented for every line
    local waypointId = 0
    for UiMapId, data in pairs(waypoints) do
        for i = 1, #data.x, 2 do
            if data.id[i] == data.id[i + 1] and data.type[i] == data.type[i + 1] then
                if data.waypointIndex[i] and data.waypointIndex[i + 1] and
                    data.waypointIndex[i] == data.waypointIndex[i + 1] then
                    if data.x[i] and data.y[i] and data.x[i + 1] and data.y[i + 1] then
                        sX = data.x[i] / 100
                        sY = data.y[i] / 100
                        eX = data.x[i + 1] / 100
                        eY = data.y[i + 1] / 100

                        -- Determine dimensions and center point of line
                        dX, dY = eX - sX, eY - sY;

                        -- Normalize direction if necessary
                        if (dX < 0) then
                            dX, dY = -dX, -dY;
                        end
                        -- If these are zero then the distance is 0
                        if dX ~= 0 or dY ~= 0 then
                            --* Calculate the rectangle corners
                            --? Information can be found: https://stackoverflow.com/questions/1936934/turn-a-line-into-a-rectangle
                            local lineLength = sqrt(dX * dX + dY * dY)
                            dX = dX / lineLength
                            dY = dY / lineLength
                            local thickness = (0.002 / 4) * defaultLineDataMap.thickness -- old 0.0013
                            local px = thickness * (-dY)
                            local py = thickness * dX
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
                                type = data.type[i],
                                waypointId = waypointId,
                                iconData = data.iconData[i],
                                lineCornerPoints = lineCornerPoints,
                                defaultLineDataMap = defaultLineDataMap,
                            }
                            MapEventBus:ObjectRegisterRepeating(iconData, MapEventBus.events.DRAW_WAYPOINTS_UIMAPID[UiMapId], renderer)
                            MapEventBus:RegisterOnce(REMOVE_EVENT, function()
                                MapEventBus:ObjectUnregisterRepeating(iconData, MapEventBus.events.DRAW_WAYPOINTS_UIMAPID[UiMapId])
                            end)
                        end
                    end
                end
            end
            waypointId = waypointId + 1
        end
    end
end

--------------------------------------------
-------------- Processors     --------------
--------------------------------------------

---comment
---@param ShowData Show
function RelationMapProcessor.ProcessCompletedQuests(ShowData)
    print("ProcessCompletedQuests")

    -- -- CountPerYield
    -- local CountPerYield = 10
    -- -- Yield Counter
    -- local count = 0

    --? This is used to remove waypoints that are no longer in use
    wipe(CompleteProcessedWaypoints)

    --? This is used to remove spawns that are no longer in use
    wipe(CompleteProcessedSpawns)

    ---@type table<UiMapId, AvailablePoints>
    local finisherIcons = {}
    ---@type table<UiMapId, AvailableWaypointPoints>
    local finisherWaypoints = {}
    for npcId, npcData in pairs(ShowData.NPC) do
        if npcData.finisher then
            local _, spawns = RelationMapProcessor.GetSpawns(finisherIcons, npcId, npcData.finisher, "npcFinisher", "NPC")
            if spawns then
                CompleteProcessedSpawns[spawns] = true
                local expensiveOperation, waypoints = RelationMapProcessor.GetWaypoints(finisherWaypoints, npcId, npcData.finisher, "npcFinisher", QuestieDB.QueryNPCSingle)
                if waypoints then
                    CompleteProcessedWaypoints[waypoints] = true
                end
                -- -- We add another one if the operation is expensive
                -- if expensiveOperation then
                --     count = count + 10
                -- end
            end
            -- Yield
            -- if count > CountPerYield then
            --     count = 0
            --     yield()
            -- else
            --     count = count + 1
            -- end
        end
    end
    print("CompleteIcons NPC Done")
    for objectId, objectData in pairs(ShowData.GameObject) do
        if objectData.finisher then
            local _, spawns = RelationMapProcessor.GetSpawns(finisherIcons, objectId, objectData.finisher, "objectFinisher", "NPC")
            if spawns then
                CompleteProcessedSpawns[spawns] = true
            end
            -- Yield
            -- if count > CountPerYield then
            --     count = 0
            --     yield()
            -- else
            --     count = count + 1
            -- end
        end
    end
    print("CompleteIcons OBJECT Done")

    -- Redraw
    -- yield()
    MapEventBus.FireEvent.REMOVE_ALL_COMPLETED()

    --! This is not tested, but should work
    -- yield()
    RegisterWaypoints(finisherWaypoints, RelationRenderers.DrawWaypoint, MapEventBus.events.REMOVE_ALL_COMPLETED)
    -- yield()
    print("CompleteIcons WAYPOINT Done")

    -- We return the majority type to control the icon
    -- Hardcode the types because we already know them
    local majorityType = {
        ["npcFinisher"] = 0,
        ["objectFinisher"] = 0,
    }

    for UiMapId, data in pairs(finisherIcons) do
        local combinedGivers = RelationMapProcessor.CombineGivers(UiMapId, data, 4, 4)
        -- print("Finisher", UiMapId, #combinedGivers)
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
                frameLevel = floor(combinedGiver.y + 0.5), --Rounding
                iconData = combinedGiver.iconData,
                id = combinedGiver.id,
                type = combinedGiver.type,
                majorityType = majority
            }
            --* Register draw
            MapEventBus:ObjectRegisterRepeating(iconData, MapEventBus.events.DRAW_RELATION_UIMAPID[UiMapId], RelationRenderers.DrawRelation)
            MapEventBus:RegisterOnce(MapEventBus.events.REMOVE_ALL_COMPLETED, function()
                MapEventBus:ObjectUnregisterRepeating(iconData, MapEventBus.events.DRAW_RELATION_UIMAPID[UiMapId])
            end)
            -- Reset the type counters
            majorityType["npcFinisher"] = 0
            majorityType["objectFinisher"] = 0

            -- Yield
            -- if count > CountPerYield then
            --     count = 0
            --     yield()
            -- else
            --     count = count + 1
            -- end
        end
    end
    print("CompleteIcons REGISTER Done")
    -- yield()
    MapEventBus:Fire(MapEventBus.events.REDRAW_ALL_RELATIONS)
end

---comment
---@param ShowData Show
function RelationMapProcessor.ProcessAvailableQuests(ShowData)
    print("ProcessAvailableQuests")

    -- -- CountPerYield
    -- local CountPerYield = 10
    -- -- Yield Counter
    -- local count = 0

    --? This is used to remove waypoints that are no longer in use
    wipe(AvailableProcessedWaypoints)

    --? This is used to remove spawns that are no longer in use
    wipe(AvailableProcessedSpawns)

    ---@type table<UiMapId, AvailablePoints>
    local starterIcons = {}
    ---@type table<UiMapId, AvailableWaypointPoints>
    local starterWaypoints = {}
    for npcId, npcData in pairs(ShowData.NPC) do
        -- If a NPC has a start, it is a starter. However, if it has a finisher we skip it
        if npcData.available and npcData.finisher == nil then
            local _, spawns = RelationMapProcessor.GetSpawns(starterIcons, npcId, npcData.available, "npc", "NPC")
            if spawns then
                AvailableProcessedSpawns[spawns] = true

                local expensiveOperation, waypoints = RelationMapProcessor.GetWaypoints(starterWaypoints, npcId, npcData.available, "npc")
                if waypoints then
                    AvailableProcessedWaypoints[waypoints] = true
                end
                -- We add another one if the operation is expensive
                -- if expensiveOperation then
                --     count = count + 10
                -- end
            end
            -- Yield
            -- if count > CountPerYield then
            --     count = 0
            --     yield()
            -- else
            --     count = count + 1
            -- end
        end
    end

    local processedObjectSpawns = SpawnProcessor.ProcessedObjectSpawns
    print("StarterIcons NPC Done")
    for objectId, objectData in pairs(ShowData.GameObject) do
        -- If a GameObject has a start, it is a starter. However, if it has a finisher we skip it
        if objectData.available and objectData.finisher == nil then
            local _, spawns = RelationMapProcessor.GetSpawns(starterIcons, objectId, objectData.available, "object", "Object")
            if spawns then
                AvailableProcessedSpawns[spawns] = true
            end
            -- Yield
            -- if count > CountPerYield then
            --     count = 0
            --     yield()
            -- else
            --     count = count + 1
            -- end
        end
    end
    print("StarterIcons OBJECT Done")


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

    -- Redraw
    -- yield()
    MapEventBus.FireEvent.REMOVE_ALL_AVAILABLE()

    -- This is not been "yielded"
    -- yield()
    RegisterWaypoints(starterWaypoints, RelationRenderers.DrawWaypoint, MapEventBus.events.REMOVE_ALL_AVAILABLE)
    print("StarterIcons WAYPOINT Done")
    -- yield()

    -- We return the majority type to control the icon
    -- Hardcode the types because we already know them
    local majorityType = {
        ["item"] = 0,
        ["object"] = 0,
        ["npc"] = 0
    }
    for UiMapId, data in pairs(starterIcons) do
        local EVENT = MapEventBus.events.DRAW_RELATION_UIMAPID[UiMapId]
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
                frameLevel = floor(combinedGiver.y + 0.5), --Rounding
                iconData = combinedGiver.iconData,
                id = combinedGiver.id,
                type = combinedGiver.type,
                majorityType = majority
            }
            --* Register draw
            MapEventBus:ObjectRegisterRepeating(iconData, EVENT, RelationRenderers.DrawRelation)
            MapEventBus:RegisterOnce(MapEventBus.events.REMOVE_ALL_AVAILABLE, function()
                MapEventBus:ObjectUnregisterRepeating(iconData, EVENT)
            end)
            -- Reset the type counters
            majorityType["item"] = 0
            majorityType["object"] = 0
            majorityType["npc"] = 0

            -- Yield
            -- if count > CountPerYield then
            --     count = 0
            --     yield()
            -- else
            --     count = count + 1
            -- end
        end
    end
    print("StarterIcons REGISTER Done")
    -- yield()
    MapEventBus:Fire(MapEventBus.events.REDRAW_ALL_RELATIONS)
end

--- This function writes data to the input starterIcons and creates a table by UiMapId with the data
---@param starterIcons table<UiMapId, AvailablePoints>
---@param id NpcId|ObjectId|ItemId
---@param data table
---@param idType RelationPointType
---@param spawnType "NPC"| "Object"
---@param itemId ItemId? -- This is used to override the ID which is added into starterIcons
---@return boolean? expensiveOperation @ True = processed, False = cached, nil = no spawns exists
---@return table<AreaId, Coordinates>? Spawns @ The processed spawns
function RelationMapProcessor.GetSpawns(starterIcons, id, data, idType, spawnType, itemId)
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
    elseif spawnType == nil or type(spawnType) ~= "string" then
        error("GetSpawns called with invalid spawnType")
        return
    elseif itemId ~= nil and type(itemId) ~= "number" and idType == "item" then
        error("GetSpawns called with invalid itemId")
        return
    end
    local processedSpawns, spawns = SpawnProcessor.GetSpawns(id, spawnType)
    if spawns ~= nil then
        for areaId, coords in pairs(spawns) do
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
    return processedSpawns, spawns
end

--- This function writes data to the input starterWaypoints and creates a table by UiMapId with the data
---@param starterWaypoints table<UiMapId, AvailableWaypointPoints>
---@param id NpcId|ObjectId|ItemId
---@param data table
---@param idType RelationPointType
---@param itemId ItemId? -- This is used to override the ID which is added into starterWaypoints
---@return boolean? ProcessedWaypoints @ This is true if we run the really expensive operations
---@return table<AreaId, {x: MapX[], y: MapY[], waypointIndex: number[]}>? Waypoints @ The processed spawns
function RelationMapProcessor.GetWaypoints(starterWaypoints, id, data, idType, itemId)
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
    elseif itemId ~= nil and type(itemId) ~= "number" and idType == "item" then
        error("GetSpawns called with invalid itemId")
        return
    end
    local processedWaypoints, waypoints = SpawnProcessor.GetWaypoints(id)
    if waypoints ~= nil then
        for areaId, coords in pairs(waypoints) do
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


                        --? If we ever want to nearby zones for waypoints, here's the code, do not delete!
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
    return processedWaypoints, waypoints
end


--------------------------------------------
-------------- Combiner     ----------------
--------------------------------------------

---Absolute center, not average
-- -@param points table<number, Point> @Point list {x=0, y=0}
---@return MapX x, MapY y
local function AbsCenterPoint(points)
    --Localize the functions
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
    end
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

    --? https://github.com/tomrus88/BlizzardInterfaceCode/blob/wrath/Interface/SharedXML/PixelUtil.lua
    -- distWidth = PixelUtil.GetNearestPixelSize(iconWidth, WorldMapFrame:GetEffectiveScale(), iconWidth)
    -- distHeight = PixelUtil.GetNearestPixelSize(iconHeight, WorldMapFrame:GetEffectiveScale(), iconHeight)

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

                                    --* tinsert(notes.? points.?) is the same as below
                                    local index = #notes.x + 1
                                    notes.x[index] = points.x[targetPointIndex]
                                    notes.y[index] = points.y[targetPointIndex]
                                    notes.iconData[index] = points.iconData[targetPointIndex]
                                    notes.id[index] = points.id[targetPointIndex]
                                    notes.type[index] = points.type[targetPointIndex]
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
