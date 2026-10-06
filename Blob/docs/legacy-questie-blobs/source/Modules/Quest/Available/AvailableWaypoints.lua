---@class AvailableWaypoints
local AvailableWaypoints = QuestieLoader:CreateModule("AvailableWaypoints")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type MessageHandler
local MessageHandler = QuestieLoader:ImportModule("MessageHandler")
---@type QLMapHandler
local MapHandler = QuestieLoader:ImportModule("MapHandler")
---@type MinimapHandler
local MinimapHandler = QuestieLoader:ImportModule("MinimapHandler")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

-- Contains library functions that do not have a logical place.
---@type WaypointMap
---@param utils table
---@param FramePool table
---@param PinMixin table
---@param MapProvider table
local WaypointMap = QuestieLoader:CreateModule("WaypointMap")


---@type SplineMixin
local SplineLib = CreateCatmullRomSpline(2);

---@type Blob
local Blob = QuestieLoader:ImportModule("Blob")


local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

local wayPointColor = {r=1, g=0.72, b=0, a=0.5}
local wayPointColorHover = {r=0.93, g=0.46, b=0.13, a=0.8}
local defaultLineDataMap = {thickness=4}
Mixin(defaultLineDataMap, wayPointColor)

local defaultLineDataMinimap = {thickness=4}
Mixin(defaultLineDataMinimap, wayPointColor)

local function drawMapLine(lineData) --UiMapId, sX, sY, eX, eY
    local UiMapId, sX, sY, eX, eY = unpack(lineData)
    local Pin = WaypointMap.MapProvider:GetMap():AcquirePin(WaypointMap.waypointPinTemplate)
    Pin:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS")
    Pin:DrawLine(UiMapId, sX, sY, eX, eY, defaultLineDataMap)
    Pin:Show();
    return Pin
end

local function drawMinimapLine(lineData) --UiMapId, sX, sY, eX, eY
    local UiMapId, sX, sY, eX, eY = unpack(lineData)
    local Pin, newPin = WaypointMap.MinimapFramePool:Acquire()
    --if(newPin) then
        Pin:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_WAYPOINTS")
        Pin:SetParent(Minimap)
        Pin.parent = Minimap
        Pin:DrawLine(UiMapId, sX, sY, eX, eY, defaultLineDataMinimap, {WaypointMap.minimapMask, WaypointMap.playerMask})
        --print(Pin.minimapScale["outdoor"], Pin.lineTexture.defaultThickness)
        --WaypointMap.PinMixin.DrawLine(Pin, UiMapId, sX, sY, eX, eY, defaultLineDataMinimap)
    --else
    --    Pin.lineTexture:redraw()
    --end
    --local cx,cy = (sX + eX) / 2, (sY + eY) / 2;
    --HBDPins:AddMinimapIconMap("test", Pin, UiMapId, cx, cy, true, false) 
    return Pin
end

function AvailableWaypoints:CreateWaypoint(UiMapId, startX, startY, endX, endY)
    local waypointObject = {}
    local dataObject = {UiMapId, startX, startY, endX, endY}
    MapHandler.RegisterCallback(waypointObject, MapHandler.events.MAP.DRAW_WAYPOINTS_UIMAPID(UiMapId), drawMapLine, dataObject)
    local Pin = drawMinimapLine(dataObject)
    local cx,cy = (startX + endX) / 2, (startY + endY) / 2;
    --MinimapHandler.RegisterCallback(waypointObject, MinimapHandler.events.MINIMAP.SPAWN_UIMAPID(UiMapId), function()
    --    MinimapHandler:AddMinimapIconMap(Pin, UiMapId, cx, cy, true, false)
    --end)
    --MinimapHandler.RegisterCallback(waypointObject, MinimapHandler.events.MINIMAP.DESPAWN_UIMAPID(UiMapId), function()
    --    MinimapHandler:RemoveIcon(Pin)
    --end)
    HBDPins:AddMinimapIconMap(waypointObject, Pin, UiMapId, cx, cy, true, false)
    
    MapHandler.RegisterCallback(waypointObject, MapHandler.events.MAP.REMOVE_ALL_WAYPOINTS_AVAILABLE, function()
        MapHandler.UnregisterAllCallbacks(waypointObject) -- Does this work?
        MinimapHandler.UnregisterAllCallbacks(waypointObject)
        --MinimapHandler:RemoveIcon(Pin)
        HBDPins:RemoveAllMinimapIcons(waypointObject)
        WaypointMap.MinimapFramePool:Release(Pin)
    end)
end

function AvailableWaypoints:CreateWaypoints(availableQuests)
    MapHandler.callback:Fire(MapHandler.events.MAP.REMOVE_ALL_WAYPOINTS_AVAILABLE);
    
    for _, giverIds in pairs(availableQuests) do
        for _, data in pairs(giverIds) do
            for zoneId, waypointsList in pairs(data.waypoints or {}) do
                local UiMapId = ZoneDB:GetUiMapIdByAreaId(zoneId)
                local lastPos
                for waypointListIndex, rawWaypoints in pairs(waypointsList or {}) do
                    SplineLib:ClearPoints()
                    for _, waypoint in pairs(rawWaypoints) do
                        SplineLib:AddPoint(waypoint[1], waypoint[2])
                    end
                    local newLines = {}
                    local percentageBetweenPoints = 0.10
                    for i = 2, SplineLib:GetNumPoints() do
                        for subPoint = 1, math.floor(1/percentageBetweenPoints) do
                            --print(subPoint*percentageBetweenPoints)
                            --It should never be 0 or 1, but due to us starting on 1 we only need to check for 1
                            if(subPoint*percentageBetweenPoints ~= 1) then
                                local x, y = SplineLib:CalculatePointOnLocalCurveSegment(i, subPoint*percentageBetweenPoints)
                                local point = {x=x, y=y}
                                table.insert(newLines, point);
                            end
                        end
                    end
                    local pReduce = 0.03
                    Blob.util.Bezier:init();
                    Blob.util.Bezier:setPoints(newLines)
                    --Blob.util.Bezier:setAutoStepScale(1)
                    Blob.util.Bezier:reduce(pReduce)

                    lastPos = nil
                    for _, point in pairs(Blob.util.Bezier:getPoints() or {}) do
                        if (lastPos == nil) then
                            lastPos = point;
                        else
                            --local temp = {}
                            --MapHandler.RegisterCallback(temp, MapHandler.events.MAP.DRAW_WAYPOINTS_UIMAPID(UiMapId), drawMapLine, {UiMapId, lastPos.x/100, lastPos.y/100, point.x/100, point.y/100})
                            --local lineFrame = drawMinimapLine({UiMapId, lastPos.x/100, lastPos.y/100, point.x/100, point.y/100})
                            AvailableWaypoints:CreateWaypoint(UiMapId, lastPos.x/100, lastPos.y/100, point.x/100, point.y/100)
                            lastPos = point;
                        end
                    end
                    if(lastPos and lastPos ~= Blob.util.Bezier:getPoints()[1]) then
                        local firstPoint = Blob.util.Bezier:getPoints()[1]
                        local x1, y1 = HBD:GetWorldCoordinatesFromZone(lastPos.x/100, lastPos.y/100, UiMapId)
                        local x2, y2 = HBD:GetWorldCoordinatesFromZone(firstPoint.x/100, firstPoint.y/100, UiMapId)
                        local sqDistance = math.sqrt(SquaredDistanceBetweenPoints(x1, y1, x2, y2))
                        --We get TexCoords error if the disatnce is to low!
                        if(sqDistance < 55 and sqDistance > 0.1) then
                            local info = C_Map.GetMapInfo(UiMapId)
                            --print("Distance", math.sqrt(sqDistance), info.name)
                            --local temp = {}
                            --MapHandler.RegisterCallback(temp, MapHandler.events.MAP.DRAW_WAYPOINTS_UIMAPID(UiMapId), drawMapLine, {UiMapId, lastPos.x/100, lastPos.y/100, firstPoint.x/100, firstPoint.y/100})
                            --print(lastPos.x/100, lastPos.y/100, firstPoint.x/100, firstPoint.y/100)
                            AvailableWaypoints:CreateWaypoint(UiMapId, lastPos.x/100, lastPos.y/100, firstPoint.x/100, firstPoint.y/100)
                        end
                    end
                end
            end
        end
    end
    MapHandler.callback:Fire(MapHandler.events.MAP.AVAILABLE_WAYPOINTS_DRAWN)
    MinimapHandler.callback:Fire(MinimapHandler.events.MINIMAP.RESPAWN_ALL)
end
MessageHandler.RegisterCallback(AvailableWaypoints, MessageHandler.events.QUEST.AVAILABLE_QUESTS_CALCULATED, AvailableWaypoints.CreateWaypoints)
