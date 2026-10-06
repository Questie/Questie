---@class QLAvailable
local Available = QuestieLoader:CreateModule("QLAvailable")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type MessageHandler
local MessageHandler = QuestieLoader:ImportModule("MessageHandler")
---@type QLMapHandler
local MapHandler = QuestieLoader:ImportModule("MapHandler")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
-- Contains library functions that do not have a logical place.
---@type Map
---@param utils table
---@param FramePool table
---@param PinMixin table @NOT USED
---@param MapProvider table
local Map = QuestieLoader:ImportModule("Map")

local _available = {}

local availableObjects = {}

-- Available Mixin
--Mixin Object
local AvailableObjectMixin = {}
local HBD = LibStub("HereBeDragonsQuestie-2.0")


local registered=false
function Available:Initialize()
    --Message:RegisterRepeatingMessage(Message.MESSAGES.QUEST.AVAILABLE_QUESTS_CALCULATED, _available.ProcessCalculatedAvailableQuests)
    --Message:RegisterRepeatingMessage(Message.MESSAGES.QUEST.AVAILABLE_QUEST_REMOVED, _available.ProcessCalculatedAvailableQuests)
    if(not registered) then
        MessageHandler.RegisterCallback(Available, MessageHandler.events.QUEST.AVAILABLE_QUESTS_CALCULATED, _available.ProcessCalculatedAvailableQuests)
        MessageHandler.RegisterCallback(Available, MessageHandler.events.QUEST.AVAILABLE_QUEST_REMOVED, _available.RemoveAvailableQuest)
        registered=true
    end
end

function Available:CreateNewAvailableObject()
    local AvailableObject = Mixin({}, AvailableObjectMixin);
    AvailableObject:Initialize();
end

--A weak table means that if the value/key is removed from GiverData it will also EVENTUALLY be removed here.
local weakKeyMetaTable = {__mode="k"}
local GiverDataByUiMapId = {}

local GiverData = {}
function Available:CreateAvailableObjects(giverType, giverId, questIds, spawnData)
    GiverData[giverId] = {}
    GiverData[giverId].giverId = giverId
    GiverData[giverId].questIds = questIds
    GiverData[giverId].locations = {}
    GiverData[giverId].pinObjects = {}
    for zoneId, coordinates in pairs(spawnData) do
        local UiMapId = ZoneDB:GetUiMapIdByAreaId(zoneId)
        --print("Registered zones", UiMapId, info.name)
        local hotzones = Available:CombineSameGiver(coordinates)
        for _, hotzone in pairs(hotzones) do
            local absCenter = Available:AbsCenterPoint(hotzone)
            --print(giverId, UiMapId, coordinate.x, coordinate.y)
            --local AvailableObject = Mixin({}, AvailableObjectMixin);
            --AvailableObject.point = 
            --print(AvailableObject)
            --blobFrame.SetPosition, blobFrame, minX+(windowX/2), minY+(windowY/2)
            GiverData[giverId].giverType = giverType
            table.insert(GiverData[giverId].locations, {orgX=absCenter.x/100, orgY=absCenter.y/100, UiMapId=UiMapId})
        end

        if(not GiverDataByUiMapId[UiMapId]) then GiverDataByUiMapId[UiMapId] = setmetatable({}, weakKeyMetaTable) end
        GiverDataByUiMapId[UiMapId][GiverData[giverId]] = true

        for _, UiMapIdRelated in pairs(NearbyZonesUiMapId[UiMapId] or {}) do
            local info = C_Map.GetMapInfo(UiMapIdRelated)
            if(UiMapIdRelated ~= UiMapId) then -- 3= zone
                if(not GiverDataByUiMapId[UiMapIdRelated]) then GiverDataByUiMapId[UiMapIdRelated] = setmetatable({}, weakKeyMetaTable) end
                GiverDataByUiMapId[UiMapIdRelated][GiverData[giverId]] = true
            end
        end
        local info = C_Map.GetMapInfo(UiMapId)
        if(info.parentMapID ~= 0) then
            local parentMapInfo = C_Map.GetMapInfo(info.parentMapID)
            if(parentMapInfo.mapType == 2) then --2=Continent
                if(not GiverDataByUiMapId[info.parentMapID]) then GiverDataByUiMapId[info.parentMapID] = setmetatable({}, weakKeyMetaTable) end
                GiverDataByUiMapId[info.parentMapID][GiverData[giverId]] = true
            end
        end
        --for _, coordinate in pairs(coordinates) do
        --    --print(giverId, UiMapId, coordinate.x, coordinate.y)
        --    local AvailableObject = Mixin({}, AvailableObjectMixin);
        --    AvailableObject.point = {x=coordinate.x/100, y=coordinate.y/100}
        --    --print(AvailableObject)
        --    --blobFrame.SetPosition, blobFrame, minX+(windowX/2), minY+(windowY/2)
        --    MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.DRAW_UIMAPID(UiMapId), AvailableObject.DrawIcons, {x=coordinate.x/100, y=coordinate.y/100, UiMapId=UiMapId})
        --    for _, areaID in pairs(NearbyZones[zoneId]) do
        --        local UiMapIdRelated = ZoneDB:GetUiMapIdByAreaId(areaID)
        --        local x,y = HBD:TranslateZoneCoordinates(coordinate.x/100, coordinate.y/100, UiMapId, UiMapIdRelated, false)
        --        if(x and y) then
        --            MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.DRAW_UIMAPID(UiMapIdRelated), AvailableObject.DrawIcons, {x=x, y=y, UiMapId=UiMapId})
        --        end
        --    end
        --    if(info.parentMapID ~= 0) then
        --        local parentMapInfo = C_Map.GetMapInfo(info.parentMapID)
        --        if(parentMapInfo.mapType == 2) then --2=Continent
        --            local x,y = HBD:TranslateZoneCoordinates(coordinate.x/100, coordinate.y/100, UiMapId, info.parentMapID, false)
        --            if(x and y) then
        --                MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.DRAW_UIMAPID(info.parentMapID), AvailableObject.DrawIcons, {x=x, y=y, UiMapId=UiMapId})
        --            end
        --        end
        --    end
        --    table.insert(GiverData.pinObjects, AvailableObject)
        --end
    end
    --local Pin = Map.MapProvider:AquirePin(Map.worldPinTemplate, 2000)
    --Pin.PinMixin = Mixin(Pin, AvailableObjectMixin)
    --Pin.PinMixin:Initialize(questIds, spawnData);
end

---comment
---@param availableQuests table @availableQuests[type][giverId][questId]
function _available:ProcessCalculatedAvailableQuests(availableQuests)

    local function _process()
        MapHandler.callback:Fire(MapHandler.events.MAP.REMOVE_ALL_AVAILABLE);
        GiverData = {}
        --collectgarbage() --This will clear the GiverDataByUiMapId table
        GiverDataByUiMapId = {}

        for giverType, giverIds in pairs(availableQuests) do
            for giverId, data in pairs(giverIds) do
                --print(giverId, data)
                --local pin = Map.MapProvider:AquirePin(Map.worldPinTemplate, 2000)
                --pin = Available:CreateAvailableObject(pin, 7)
                Available:CreateAvailableObjects(giverType, giverId, data.questIds, data.spawnData)
            end
            coroutine.yield()
        end

        for UiMapId, giverData in pairs(GiverDataByUiMapId or {}) do
            local combinedGivers = Available:CombineGivers2(giverData, UiMapId);
            coroutine.yield()
            for _, pinObject in pairs(combinedGivers) do
                local x,y = HBD:TranslateZoneCoordinates(pinObject.point.orgX, pinObject.point.orgY, pinObject.point.UiMapId, UiMapId, false)
                if(x and y) then
                    local AvailableObject = Mixin({}, AvailableObjectMixin);
                    MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.DRAW_UIMAPID(UiMapId), AvailableObject.DrawIcons, {AvailableObject=AvailableObject, data=pinObject, x=x, y=y, UiMapId=pinObject.point.UiMapId})

                    --We register the object to remove itself if REMOVE_ALL_AVAILABLE is called
                    MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.REMOVE_ALL_AVAILABLE, function()
                        MapHandler.UnregisterAllCallbacks(AvailableObject) -- Does this work?
                        AvailableObject = nil
                    end)
                end
            end
        end
    end
    local processCalculatedAvailableQuestsCoroutine = coroutine.create(_process);
    print("ProcessCalculatedAvailableQuests Start", time())
    local timer;
    timer = C_Timer.NewTicker(0, function()
        if(coroutine.status(processCalculatedAvailableQuestsCoroutine) == "suspended") then
            coroutine.resume(processCalculatedAvailableQuestsCoroutine)
        elseif(coroutine.status(processCalculatedAvailableQuestsCoroutine) == "dead") then
            print("ProcessCalculatedAvailableQuests Done", time())
            timer:Cancel()
            MapHandler.callback:Fire(MapHandler.events.MAP.AVAILABLE_QUESTS_DRAWN)
        end
    end)
    --[[worldMaps[mapType][UiMapId] = {drawObjects}
    --worldMaps = {}
    --combinedGivers = Available:CombineGivers(GiverData)
    --for _, pinObject in pairs(combinedGivers) do
    --    local AvailableObject = Mixin({}, AvailableObjectMixin);
    --    --AvailableObject.ZonesRegistered = {pinObject.point.UiMapId}
    --    MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.DRAW_UIMAPID(pinObject.point.UiMapId), AvailableObject.DrawIcons, {AvailableObject=AvailableObject, data=pinObject, x=pinObject.point.orgX, y=pinObject.point.orgY, UiMapId=pinObject.point.UiMapId})

    --    --Subzones and Azeroth
    --    for _, UiMapIdRelated in pairs(NearbyZonesUiMapId[pinObject.point.UiMapId] or {}) do
    --        local combinedGivers2 = Available:CombineGivers(GiverData, UiMapIdRelated)
    --        --local info = C_Map.GetMapInfo(UiMapIdRelated)
    --        --local x,y = HBD:TranslateZoneCoordinates(pinObject.point.orgX, pinObject.point.orgY, pinObject.point.UiMapId, UiMapIdRelated, false)
    --        --if(x and y) then
    --        --    if(info.mapType == 3) then -- Zone
    --        --        MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.DRAW_UIMAPID(UiMapIdRelated), AvailableObject.DrawIcons, {AvailableObject=AvailableObject, data=pinObject, x=x, y=y, UiMapId=pinObject.point.UiMapId})
    --        --    elseif(info.mapType == 1 or info.mapType == 2) then -- World, Continent
    --        --        if(not worldMaps[info.mapType]) then worldMaps[info.mapType] = {} end
    --        --        if(not worldMaps[info.mapType][UiMapIdRelated]) then worldMaps[info.mapType][UiMapIdRelated] = {} end
    --        --        table.insert(worldMaps[info.mapType][UiMapIdRelated], {AvailableObject=AvailableObject, data=pinObject, x=x, y=y, UiMapId=pinObject.point.UiMapId})
    --        --    end
    --        --end
    --    end
    --    --EK and Kalimdor
    --    local info = C_Map.GetMapInfo(pinObject.point.UiMapId)
    --    if(info.parentMapID ~= 0) then
    --        local parentMapInfo = C_Map.GetMapInfo(info.parentMapID)
    --        if(parentMapInfo.mapType == 2) then --2=Continent
    --            local x,y = HBD:TranslateZoneCoordinates(pinObject.point.orgX, pinObject.point.orgY, pinObject.point.UiMapId, info.parentMapID, false)
    --            if(x and y) then
    --                --MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.DRAW_UIMAPID(info.parentMapID), AvailableObject.DrawIcons, {AvailableObject=AvailableObject, data=pinObject, x=x, y=y, UiMapId=pinObject.point.UiMapId})
    --                --table.insert(AvailableObject.ZonesRegistered, info.parentMapID)
    --                if(not worldMaps[info.mapType]) then worldMaps[info.mapType] = {} end
    --                if(not worldMaps[info.mapType][info.parentMapID]) then worldMaps[info.mapType][info.parentMapID] = {} end
    --                table.insert(worldMaps[info.mapType][info.parentMapID], {AvailableObject=AvailableObject, data=pinObject, x=x, y=y, UiMapId=pinObject.point.UiMapId})
    --            end
    --        end
    --    end

    --    --We register the object to remove itself if REMOVE_ALL_AVAILABLE is called
    --    MapHandler.RegisterCallback(AvailableObject, MapHandler.events.MAP.REMOVE_ALL_AVAILABLE, function()
    --        MapHandler.UnregisterAllCallbacks(AvailableObject) -- Does this work?
    --        AvailableObject = nil
    --    end)
    --end]]--
    --MapHandler.callback:Fire(MapHandler.events.MAP.AVAILABLE_QUESTS_DRAWN)
end


function _available:RemoveAvailableQuest(questId)

end

function AvailableObjectMixin:Initialize(questIds, spawnData)
    print("Initialize an icon")
    MessageHandler.RegisterCallback(self, MessageHandler.events.QUEST.AVAILABLE_QUEST_REMOVED, _available.RemoveAvailableQuest)
    --for 
end

function AvailableObjectMixin:UnInitialize()
    print("UnInitialize an icon")
    MessageHandler.UnregisterCallback(self, MessageHandler.events.QUEST.AVAILABLE_QUEST_REMOVED)
end

function AvailableObjectMixin:OnMouseEnter()

end

function AvailableObjectMixin:DrawIcons()

    --print(data.x, data.y, event)
    --print("PinPool", Map.worldPinTemplate)
    local Pin = Map.MapProvider:GetMap():AcquirePin(Map.worldPinTemplate)

    local info = C_Map.GetMapInfo(Map.MapProvider:GetMap():GetMapID())
    local normalScale, zoomedScale = 0.8, 1;
    local count = 0
    for _,_ in pairs(self.data.giverIds) do
        count = count + 1
    end
    if(count > 1) then
        normalScale = 1
        zoomedScale = 1.20
    end
    if(info.mapType == 2) then-- continent
        normalScale = normalScale * 0.8
        zoomedScale = zoomedScale * 0.8
    elseif(info.mapType == 1) then --World
        normalScale = normalScale * 0.7
        zoomedScale = zoomedScale * 0.7
    end

    --Pin.subNotes = nil
    Pin.object = self
    Pin:SetSize(8, 16);
    Pin:SetPosition(Pin.object.x, Pin.object.y)
    Pin:SetScalingLimits(1, normalScale, zoomedScale)
    local iconTexture = Map.TexturePool:Acquire();
    iconTexture:ClearAllPoints();
    iconTexture:SetTexture(QuestieLib.AddonPath.."Icons\\available")
    iconTexture:SetSize(16,16)
    iconTexture:SetParent(Pin)
    iconTexture:SetPoint("CENTER");
    iconTexture:Show();
    table.insert(Pin.textures, iconTexture)
    Pin:Show();
    --We want them to overlap in a specific way back -> front, which we base of y
    Pin:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI_AVAILABLE", Round(self.y*100))
    --Pin:SetNudgeFactor(1)
    --Pin:SetNudgeVector(5, 1, 0.1, 0.2)
    --print(Map.MapProvider:GetMap():GetPinFrameLevelsManager():GetValidFrameLevel(Pin.pinFrameLevelType, Pin.pinFrameLevelIndex))
    Pin:ApplyFrameLevel()
    --local _, _, _, xOfs, yOfs = Pin:GetPoint(1)
    --local w, h = Pin:GetSize()
    --local getEffectiveScale = Pin:GetEffectiveScale()

    --local bottom = Pin:GetBottom()*getEffectiveScale;
    --local top = Pin:GetTop()*getEffectiveScale;
    --local left = Pin:GetLeft()*getEffectiveScale;
    --local right = Pin:GetRight()*getEffectiveScale;

    --print("X", xOfs, "Y", yOfs)
    --print("W", w, "(",(w*getEffectiveScale), ")", "H", h, "(",(h*getEffectiveScale), ")")
    --Pin.Rect = CreateRectangle(left, right, top, bottom)
end


---Combines different gives with eachother
---@param giverData any
---@return nil
function Available:CombineGivers2(giverData, forUiMapId, widthDistance, heightDistance)
	--print("calc1")
    if(giverData == nil) then return nil; end
    local points = {}
    for data, _ in pairs(giverData) do
        for _, location in pairs(data.locations) do
            table.insert(points, {point=location, giverType=data.giverType, giverId=data.giverId, questIds=data.questIds})
        end
    end

    local worldMapFrameWidth = WorldMapFrame:GetWidth()*WorldMapFrame:GetEffectiveScale()
    local worldMapFrameHeight = WorldMapFrame:GetHeight()*WorldMapFrame:GetEffectiveScale()
    local distWidth = widthDistance or ConvertPixelsToUI(7, WorldMapFrame:GetEffectiveScale()) --actual = 12
    local distHeight = heightDistance or ConvertPixelsToUI(12, WorldMapFrame:GetEffectiveScale()) --actual = 29
    
    local availablePins = {};
    while(true) do
        local FoundUntouched = nil;
        for _, point in pairs(points) do
            if(point.touched == nil) then
                --We touch this
                FoundUntouched = true;
                point.touched = true;
                
                local times = 1;

                if (point.point.orgX > 1 and point.point.orgY > 1) then
                    times = 100
                end

                local aX, aY = HBD:TranslateZoneCoordinates(
                                    (point.point.orgX/times), (point.point.orgY/times),
                                    point.point.UiMapId, forUiMapId)

                --Check if the point is even inside the current map or not
                if(aX and aY) then
                    local availablePin = {giverIds={}}
                    availablePin.giverIds[point.giverId] = point.questIds
                    local notes = {};
                    tinsert(notes, point.point);
                    for _, point2 in pairs(points) do
                        if(point2.touched == nil) then
                            if(point.point.UiMapId == point2.point.UiMapId) then
                                local bX, bY = HBD:TranslateZoneCoordinates(
                                                    (point2.point.orgX/times), (point2.point.orgY/times),
                                                    point2.point.UiMapId, forUiMapId)
                                if(bX and bY) then
                                    local dX = math.abs(aX - bX)
                                    local dY = math.abs(aY - bY)
                                    dX = worldMapFrameWidth * dX
                                    dY = worldMapFrameHeight * dY

                                    --local distance =
                                    --    QuestieLib:Euclid((point.point.orgX / times) or 0, (point.point.orgY / times) or 0, (point2.point.orgX / times) or 0, (point2.point.orgY / times) or 0)
                                    --print(distance)
                                    --if (distance < 0.009) then
                                    if(dX < distWidth and dY < distHeight) then
                                        point2.touched = true
                                        if(availablePin.giverIds[point2.giverId]) then
                                            print("ehh already exists?")
                                        end
                                        availablePin.giverIds[point2.giverId] = point2.questIds
                                        tinsert(notes, point2.point)
                                    end
                                end
                            end
                        end
                    end
                    local absCenter = Available:AbsCenterPoint(notes)
                    availablePin.point = absCenter;
                    availablePin.point.UiMapId = point.point.UiMapId
                    --availablePin.point = point.point
                    tinsert(availablePins, availablePin)
                end
            end
        end
		if (FoundUntouched == nil) then 
			for _, point in pairs(points) do
				point.touched = nil;
			end
			break 
		end
    end
    points = nil --give it to the GC
    return availablePins
end

---Combines different gives with eachother
---@param giverData any
---@return nil
function Available:CombineGivers(giverData, forUiMapId)
	--print("calc1")
    if(giverData == nil) then return nil; end
    local points = {}
    for giverId, data in pairs(giverData) do
        for _, location in pairs(data.locations) do
            table.insert(points, {point=location, giverType=data.giverType, giverId=data.giverId, questIds=data.questIds})
        end
    end

    local worldMapFrameWidth = WorldMapFrame:GetWidth()*WorldMapFrame:GetEffectiveScale()
    local worldMapFrameHeight = WorldMapFrame:GetHeight()*WorldMapFrame:GetEffectiveScale()
    local distWidth = ConvertPixelsToUI(7, WorldMapFrame:GetEffectiveScale()) --actual = 12
    local distHeight = ConvertPixelsToUI(12, WorldMapFrame:GetEffectiveScale()) --actual = 29

    local availablePins = {};
    local itt = 0;
    while(true) do
        local FoundUntouched = nil;
        for index, point in pairs(points) do
            if(point.touched == nil) then
                ---@class AvailablePin
                ---@field giverIds table @A table of giverId which contains questIds for that giver
                local availablePin = {giverIds={}}
                availablePin.giverIds[point.giverId] = point.questIds
                local notes = {};
                FoundUntouched = true;
                point.touched = true;
                tinsert(notes, point.point);
                for index2, point2 in pairs(points) do
                    if(point2.touched == nil) then
                        if(point.giverType == point2.giverType and point.point.UiMapId == point2.point.UiMapId) then
                            local times = 1;

                            if (point.point.orgX > 1 and point.point.orgY > 1) then
                                times = 100
                            end
                            --local aX, aY = HBD:GetWorldCoordinatesFromZone(
                            --                    point.orgX / times, point.orgY / times,
                            --                    UiMapId)
                            --local bX, bY = HBD:GetWorldCoordinatesFromZone(
                            --                    point2.orgX / times, point2.orgY / times,
                            --                    UiMapId)

                            local dX = math.abs((point.point.orgX/times) - (point2.point.orgX/times))
                            local dY = math.abs((point.point.orgY/times) - (point2.point.orgY/times))
                            dX = worldMapFrameWidth * dX
                            dY = worldMapFrameHeight * dY

                            --local distance =
                            --    QuestieLib:Euclid((point.point.orgX / times) or 0, (point.point.orgY / times) or 0, (point2.point.orgX / times) or 0, (point2.point.orgY / times) or 0)
                            --print(distance)
                            --if (distance < 0.009) then
                            if(dX < distWidth and dY < distHeight) then
                                point2.touched = true
                                if(availablePin.giverIds[point2.giverId]) then
                                    print("ehh already exists?")
                                end
                                availablePin.giverIds[point2.giverId] = point2.questIds
                                tinsert(notes, point2.point)
                            end
                        end
                    end
                end
                local absCenter = Available:AbsCenterPoint(notes)
                availablePin.point = absCenter;
                availablePin.point.UiMapId = point.point.UiMapId
                --availablePin.point = point.point
                tinsert(availablePins, availablePin)
            end
        end
		if (FoundUntouched == nil) then 
			for index, point in pairs(points) do
				point.touched = nil;
			end
			break 
		end
        itt = itt + 1
    end
    return availablePins
end

---Combines the same giver, say if there are multiple locations of a quest.
---@param points any
---@return nil
function Available:CombineSameGiver(points)
	--print("calc1")
    if(points == nil) then return nil; end

    local range = rangeR or 100;
    local hotzones = {};
    local itt = 0;
    while(true) do
        local FoundUntouched = nil;
        for index, point in pairs(points) do
            if(point.touched == nil) then
                local notes = {};
                FoundUntouched = true;
                point.touched = true;
                tinsert(notes, point);
                for index2, point2 in pairs(points) do
                    local times = 1;

                    if (point.x > 1 and point.y > 1) then
                        times = 100
                    end
                    --local aX, aY = HBD:GetWorldCoordinatesFromZone(
                    --                    point.x / times, point.y / times,
                    --                    UiMapId)
                    --local bX, bY = HBD:GetWorldCoordinatesFromZone(
                    --                    point2.x / times, point2.y / times,
                    --                    UiMapId)
                    local dX = math.abs((point.x/times) - (point2.x/times))
                    local dY = math.abs((point.y/times) - (point2.y/times))
                    --print(dX, dY)

                    --local distance =
                    --    QuestieLib:Euclid(aX or 0, aY or 0, bX or 0, bY or 0)
                    if (point2.touched == nil and dX < 0.05 and dY < 0.1) then
                        point2.touched = true
                        tinsert(notes, point2)
                    end
                end
                tinsert(hotzones, notes)
            end
        end
		if (FoundUntouched == nil) then 
			for index, point in pairs(points) do
				point.touched = nil;
			end
			break 
		end
        itt = itt + 1
    end
    return hotzones
end

---Absolute center, not avarage
---@param points table<number, Point> @Pointlist {x=0, y=0}
---@return Point @{x=?, y=?}
function Available:AbsCenterPoint(points)
    --Localize the functions
    local min, max = math.min, math.max
    local minX = 99999999999
    local minY = 99999999999
    local maxX = 0
    local maxY = 0
    for _, point in pairs(points) do
        minX = min(minX, point.x or point.orgX);
        minY = min(minY, point.y or point.orgY);
        maxX = max(maxX, point.x or point.orgX);
        maxY = max(maxY, point.y or point.orgY);
    end
    --local fCenterX = minX + ((maxX - minX)/2)--local fCenterY = minY + ((maxY - minY)/2)
    if(points[1].orgX and points[1].orgY) then
        return {orgX=minX + ((maxX - minX)/2), orgY=minY + ((maxY - minY)/2)}
    else
        return {x=minX + ((maxX - minX)/2), y=minY + ((maxY - minY)/2)}
    end
end