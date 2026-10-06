---@class QuestiePolygon
local QuestiePolygon = QuestieLoader:CreateModule("QuestiePolygon")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type Blob
local Blob = QuestieLoader:ImportModule("Blob")
---@type MapLib
local MapLib = QuestieLoader:ImportModule("MapLib")

-----@class QuestiePolygon
--local QuestiePolygon = QuestieLoader:ImportModule("QuestiePolygon")

---@type MessageHandler
local MessageHandler = QuestieLoader:ImportModule("MessageHandler")

--Local functions
local _QuestiePolygon = {}
--Icon override functions
local _OverrideFunctions = {}

--Active toggled polygons boolean stored here
local toggledPolygonList = {}
local PolygonList = {}

local tInsert = table.insert

local areaCutoff = 0.9
POLYGON_CLUSTER_AMOUNT = 180


function QuestiePolygon:Initialize()
    --Messages subscribed to
    --QuestieMessage:RegisterRepeatingMessage(QuestieMessage.MESSAGES.QUEST.REMOVED, _QuestiePolygon.ForceRemoveQuest)
    --QuestieMessage:RegisterRepeatingMessage(QuestieMessage.MESSAGES.QUEST.COMPLETE, _QuestiePolygon.ForceRemoveQuest)
    --QuestieMessage:RegisterRepeatingMessage(QuestieMessage.MESSAGES.QUEST.UPDATED, _QuestiePolygon.UpdateQuest)

    MessageHandler.RegisterCallback(QuestiePolygon, MessageHandler.events.QUEST.ABANDONED,  _QuestiePolygon.ForceRemoveQuest)
    MessageHandler.RegisterCallback(QuestiePolygon, MessageHandler.events.QUEST.COMPLETE,  _QuestiePolygon.ForceRemoveQuest)
    MessageHandler.RegisterCallback(QuestiePolygon, MessageHandler.events.QUEST.TURNED_IN,  _QuestiePolygon.ForceRemoveQuest)
    MessageHandler.RegisterCallback(QuestiePolygon, MessageHandler.events.QUEST.UPDATED,  _QuestiePolygon.UpdateQuest)

end


local minimapowner = {}
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

--Here we keep the coroutine as to be able to look at its state from other functions
local PolygonQueueRoutine = {}
--The cache for polygons
local hotzoneCache = {}

local allFrames = {}
--Gets called when we want to cluster a quest objective to do an itterative processing using coroutines
---comment
---@param priorityMapUiMapID integer
---@param questId QuestId
---@param objectiveIndex ObjectiveIndex
---@param color table @keyed r=r etc
---@param addAll boolean @Draw all polygons or just priorityMapUiMapID
function QuestiePolygon:DrawPolygon(priorityMapUiMapID, questId, objectiveIndex, color, addAll)
    if(not PolygonQueueRoutine[questId]) then
        PolygonQueueRoutine[questId] = {}
    end

    local function drawHotzones(UiMapID, hotzones)
        --Add the blobs to the map and the polygonList
        for _, hotzone in pairs(hotzones or {}) do
            local drawData = Blob:AddBlobRaw(UiMapID,
                                          hotzone,
                                          color,
                                          color,
                                          _OverrideFunctions)
            if(PolygonList[questId][objectiveIndex]) then
                tInsert(PolygonList[questId][objectiveIndex], drawData)
            end
        end
    end

    local function drawMinimap(UiMapID, hotzones)
        if(not allFrames[questId]) then
            allFrames[questId] = {}
        end
        if(not allFrames[questId][objectiveIndex]) then
            allFrames[questId][objectiveIndex] = {}
        end
        for _, hotzone in pairs(hotzones or {}) do
            local bData = Blob:AddMinimapBlobRaw(UiMapID, hotzone, color, color, {})
            --If there are not enough points no object is created
            if(bData) then
                --print("Drawing minimap Polygon")
                local frame = Blob.MinimapFramePool:Acquire();
                local bFrame = Blob:DrawPointList(frame, bData, {Blob.minimapMask, Blob.playerMask});
                bFrame:Hide()
                --local midPoint = Blob.util:CenterPoint(hotzone)
                --print("Minimap:", midPoint.x, midPoint.y)
                --print("Minimap:", bFrame.center.x, bFrame.center.y)
                table.insert(allFrames[questId][objectiveIndex], bFrame)
                HBDPins:AddMinimapIconMap(questId.."-"..objectiveIndex, bFrame, UiMapID, bFrame.fCenterX, bFrame.fCenterY, true, false) 
            end
        end
    end

    --Use cache or calchotzones
    if(hotzoneCache and hotzoneCache[questId] and hotzoneCache[questId][objectiveIndex]) then
        --print("Using Cache")
        for UiMapID, hotzones in pairs(hotzoneCache[questId][objectiveIndex]) do
            if(addAll == true or UiMapID == priorityMapUiMapID) then
                drawHotzones(UiMapID, hotzones)
            end
            if(addAll == true) then
                drawMinimap(UiMapID, hotzones)
            end
        end
        BlobMapProvider:RefreshAllData(true);
    else
        print("ERROR: Draw call made without any data cached!")
    end
end

function QuestiePolygon:GetAllPoints(questId, objectiveIndex)
    local allPoints = {}
    local totalCount = 0
    --If we already have the hotzones cached we don't need to do this!
    if(not hotzoneCache[questId] or not hotzoneCache[questId][objectiveIndex]) then
        local spawnData = QuestiePolygon:GetSpawnData(questId, objectiveIndex)
        --Make a copy of the spawnpoints and include UiMapID
        for id, areaTable in pairs(spawnData) do
            --Copy the data
            for areaId, mobData in pairs(areaTable.spawns) do
                local UiMapID = ZoneDB:GetUiMapIdByAreaId(areaId)
                if(UiMapID) then
                    if(not allPoints[UiMapID]) then
                        allPoints[UiMapID] = {}
                    end

                    for i, point in pairs(mobData) do
                        tInsert(allPoints[UiMapID], {TooltipKey=areaTable.TooltipKey, x=point[1], y=point[2], UiMapID=UiMapID})
                        totalCount = totalCount + 1
                    end
                end
            end
        end
    end
    return allPoints
end

---comment
---@param questId QuestId
---@param objectiveIndex ObjectiveIndex
---@param drawPayload table @OPTIONAL: a table containing a payload to be used for DrawPolygon(priorityMapUiMapID, questId, objectiveIndex, color, addAll)
function QuestiePolygon:CachePolygon(questId, objectiveIndex, drawPayload)
    if(not PolygonQueueRoutine[questId]) then
        PolygonQueueRoutine[questId] = {}
    end

    --local allPoints = QuestiePolygon:GetAllPoints(questId, objectiveIndex)
    --If we already have the hotzones cached we don't need to do this!

    local allPoints = {}
    if(not hotzoneCache[questId] or not hotzoneCache[questId][objectiveIndex]) then
        --local spawnData = QuestiePolygon:GetSpawnData(questId, objectiveIndex)
        local quest = QuestieDB:GetQuest(questId);
        local spawnData = {}
        if(quest.Objectives and quest.Objectives[objectiveIndex] and quest.Objectives[objectiveIndex].spawnList) then
            spawnData = quest.Objectives[objectiveIndex].spawnList
        end
        --Make a copy of the spawnpoints and include UiMapID
        for id, areaTable in pairs(spawnData) do
            --Remove rare and rare elites
            local spawns = areaTable.Spawns
            if(areaTable.Type == "monster") then
                local rank = QuestieDB.QueryNPCSingle(id, "rank");
                if(rank == 4 or rank == 2) then --Rare and RareElite
                    spawns = {}
                end
            end
            --Copy the data
            for areaId, mobData in pairs(spawns) do
                local UiMapID = ZoneDB:GetUiMapIdByAreaId(areaId)
                if(UiMapID) then
                    if(not allPoints[UiMapID]) then
                        allPoints[UiMapID] = {}
                    end
                    for i, point in pairs(mobData) do
                        tInsert(allPoints[UiMapID], {TooltipKey=areaTable.TooltipKey, x=point[1], y=point[2], UiMapID=UiMapID})
                    end
                end
            end
        end
    end

    if(not hotzoneCache[questId]) then
        hotzoneCache[questId] = {}
    end

    --I think we should always prioritize the current zone on the map or the one the player is in
    local priorityMapUiMapID = WorldMapFrame:GetMapID() or C_Map.GetBestMapForUnit("player");

    --If we have it in the cache, we don't want to create a coroutine (Saves memory)
    --It is then launched lower in the code
    if(hotzoneCache[questId] and not hotzoneCache[questId][objectiveIndex]) then
        PolygonQueueRoutine[questId][objectiveIndex] = coroutine.create(function ()
            if(not hotzoneCache[questId][objectiveIndex]) then
                hotzoneCache[questId][objectiveIndex] = {}
            end

            --print("Processing IconUiMapID:", priorityMapUiMapID)
            --We first run the map we currently have open
            local hz = QuestiePolygon:CalcHotzones(allPoints[priorityMapUiMapID], POLYGON_CLUSTER_AMOUNT, true)
            --hz = QuestiePolygon:PostProcessHotzone(hz, false);
            coroutine.yield(priorityMapUiMapID, hz)

            --We loop through all the maps except the one we have already done
            for UiMapID, points in pairs(allPoints) do
                if(UiMapID ~= priorityMapUiMapID) then
                    --print("Processing UiMapID:", UiMapID)
                    hz = QuestiePolygon:CalcHotzones(points, POLYGON_CLUSTER_AMOUNT, true)
                    --hz = QuestiePolygon:PostProcessHotzone(hz, false);
                    coroutine.yield(UiMapID, hz)
                end
            end
        end)


        local timer
        timer = C_Timer.NewTicker(0, function()
            if(PolygonQueueRoutine[questId][objectiveIndex] and coroutine.status(PolygonQueueRoutine[questId][objectiveIndex]) == "suspended") then
                local status, UiMapID, hotzones = coroutine.resume(PolygonQueueRoutine[questId][objectiveIndex])
                if(hotzones ~= nil) then
                    --We can't modify it in a loop so we create a temporary variable
                    local splinedHotzones = {}
                    for _, hotzone in pairs(hotzones) do
                        local points = Blob:CalcSpine(hotzone);
                        local area, bigEnough = Blob.util:CalculateArea(points, areaCutoff)
                        if(bigEnough) then
                            tInsert(splinedHotzones, points)
                        --elseif(area > 0) then
                        --    ppprint("Area to small:", area)
                        end
                    end
                    hotzoneCache[questId][objectiveIndex][UiMapID] = splinedHotzones

                    -- A little janky but DrawPolygon(priorityMapUiMapID, questId, objectiveIndex, color, addAll)
                    if(drawPayload and (drawPayload[1] == UiMapID or drawPayload[5] == true)) then
                        QuestiePolygon:DrawPolygon(unpack(drawPayload))

                        --Only refresh the icons when we get to the current map.
                        if(UiMapID == priorityMapUiMapID) then
                            BlobMapProvider:RefreshAllData(true);
                        end
                    end

                    hotzones = nil --nil it to speed up GC
                    splinedHotzones = nil --nil to speed up GC
                end
            elseif((PolygonQueueRoutine[questId][objectiveIndex] and coroutine.status(PolygonQueueRoutine[questId][objectiveIndex]) == "dead") or not PolygonQueueRoutine[questId][objectiveIndex]) then
                --print("Cache done!")
                timer:Cancel()
            end
        end)
    --else
    --    print("Cache already exists, exiting")
    end
end

function QuestiePolygon:ToggleObjective(questId, objectiveIndex, r, g, b)
    --To avoid any issues ignore commands while the coroutine is running
    if(PolygonQueueRoutine[questId][objectiveIndex] == nil or coroutine.status(PolygonQueueRoutine[questId][objectiveIndex]) == "dead") then
        if(not toggledPolygonList[questId.."-"..objectiveIndex]) then
            --We add the objective and then set the toggled polygon, has to be this order because the
            --function looks at that variable if it should add it
            _QuestiePolygon:ForceRemoveQuestObjective(questId, objectiveIndex);
            QuestiePolygon:AddObjective(questId, objectiveIndex, r, g, b, true)
            toggledPolygonList[questId.."-"..objectiveIndex] = true
        else
            --Same here but reversed
            toggledPolygonList[questId.."-"..objectiveIndex] = nil
            QuestiePolygon:RemoveObjective(questId, objectiveIndex)
        end

        BlobMapProvider:RefreshAllData(true);
    end
end

---comment
---@param questId QuestId
---@param objectiveIndex ObjectiveIndex
---@param r integer
---@param g integer
---@param b integer
---@param addAll boolean @Draw all UiMapIds?
function QuestiePolygon:AddObjective(questId, objectiveIndex, r, g, b, addAll)
    --local quest = QuestieDB:GetQuest(questId);

---    ['objectives'] = "objectives", -- table
        --['creatureObjective'] = 1, -- table {{creature(int), text(string)},...}, If text is nil the default "<Name> slain x/y" is used
        --['objectObjective'] = 2, -- table {{object(int), text(string)},...}
        --['itemObjective'] = 3, -- table {{item(int), text(string)},...}
    
    --local spawnData = quest.Objectives[objectiveIndex].spawnList
    --Is the coroutine currently running? If so, skip.
    if(PolygonQueueRoutine[questId] == nil or PolygonQueueRoutine[questId][objectiveIndex] == nil or coroutine.status(PolygonQueueRoutine[questId][objectiveIndex]) == "dead") then
        --Is it manually toggled?
        if(not toggledPolygonList[questId.."-"..objectiveIndex]) then
            --Is it already added?
            if(PolygonList[questId] == nil or PolygonList[questId][objectiveIndex] == nil) then
                if(not PolygonList[questId]) then
                    PolygonList[questId] = {}
                end
                PolygonList[questId][objectiveIndex] = {}

                local priorityMapUiMapID = WorldMapFrame:GetMapID() or C_Map.GetBestMapForUnit("player")
                --_polygonQueue(allPoints, priorityMapUiMapID, questId, objectiveIndex, {r=r, g=g, b=b}, addAll)
                if(not hotzoneCache[questId] or not hotzoneCache[questId][objectiveIndex]) then
                    QuestiePolygon:CachePolygon(questId, objectiveIndex, {priorityMapUiMapID, questId, objectiveIndex, {r=r, g=g, b=b}, addAll});
                else
                    QuestiePolygon:DrawPolygon(priorityMapUiMapID, questId, objectiveIndex, {r=r, g=g, b=b}, addAll);
                end
            end
        end
    end
end

function QuestiePolygon:RemoveObjective(questId, objectiveIndex)
    local timer
    timer = C_Timer.NewTicker(0, function()
        --Is the coroutine currently running? If so, skip.
        if(PolygonQueueRoutine[questId] == nil or PolygonQueueRoutine[questId][objectiveIndex] == nil or coroutine.status(PolygonQueueRoutine[questId][objectiveIndex]) == "dead") then
            --Do we even have polygons and are we toggled?
            if(PolygonList[questId] and PolygonList[questId][objectiveIndex] and not toggledPolygonList[questId.."-"..objectiveIndex]) then
                for _, blobData in pairs(PolygonList[questId][objectiveIndex]) do
                    Blob:RemoveBlob(blobData)
                end
                PolygonList[questId][objectiveIndex] = nil;
                if(WorldMapFrame:IsVisible()) then
                    BlobMapProvider:RefreshAllData(true);
                end

                HBDPins:RemoveAllMinimapIcons(questId.."-"..objectiveIndex)
                if(allFrames[questId] and allFrames[questId][objectiveIndex]) then
                    for _, frame in pairs(allFrames[questId][objectiveIndex] or {}) do
                        Blob.MinimapFramePool:Release(frame)
                    end
                    allFrames[questId][objectiveIndex] = {}
                end

            end
            timer:Cancel();
        end
    end)
end

function _OverrideFunctions:OnMouseEnterPolygon(pinSelf)
    --for k,v in pairs(pinSelf) do print(k) end
    for _, line in pairs(pinSelf.lines) do
        line:SetVertexColor(line.color.r, line.color.g, line.color.b, math.min(line.color.a * 1.5, 1))
        line:SetThickness(line.defaultThickness * 1.2)
        line.redraw(line)
    end
    --print("MouseEnter");
end

function _OverrideFunctions:OnMouseLeavePolygon(pinSelf)
    for _, line in pairs(pinSelf.lines) do
        line:SetVertexColor(line.color.r, line.color.g, line.color.b, line.color.a)
        line:SetThickness(line.defaultThickness)
        line.redraw(line)
    end
    --print("MouseLeave");
end

function _QuestiePolygon:ForceRemoveQuestObjective(questId, objectiveIndex)
    --print("Removing questId", questId, "objectiveIndex", objectiveIndex)
    --Some quests are completed without ever picking up a quest, so we need to check.
    if(PolygonList[questId] and PolygonList[questId][objectiveIndex]) then
        for _, blobData in pairs(PolygonList[questId][objectiveIndex] or {}) do
            Blob:RemoveBlob(blobData)
        end
        if(WorldMapFrame:IsVisible()) then
            BlobMapProvider:RefreshAllData(true);
        end
        PolygonList[questId][objectiveIndex] = nil;

        HBDPins:RemoveAllMinimapIcons(questId.."-"..objectiveIndex)
        if(allFrames[questId] and allFrames[questId][objectiveIndex]) then
            for _, frame in pairs(allFrames[questId][objectiveIndex] or {}) do
                Blob.MinimapFramePool:Release(frame)
            end
            allFrames[questId][objectiveIndex] = {}
        end
    end
end

function _QuestiePolygon:ForceRemoveQuest(questId)
    for objectiveIndex, objectiveData in pairs(PolygonList[questId] or {}) do
        for _, blobData in pairs(objectiveData) do
            Blob:RemoveBlob(blobData)
        end
    end
    if(WorldMapFrame:IsVisible()) then
        BlobMapProvider:RefreshAllData(true);
    end
    for objectiveIndex, frames in pairs(allFrames[questId] or {}) do
        HBDPins:RemoveAllMinimapIcons(questId.."-"..objectiveIndex)
        for _, frame in pairs(frames) do
            Blob.MinimapFramePool:Release(frame)
        end
    end
    allFrames[questId] = nil;
    hotzoneCache[questId] = nil;
    PolygonList[questId] = nil;
end

function _QuestiePolygon:UpdateQuest(questId)
    local questObjectives = QuestieLib:GetQuestObjectives(questId);

    --Remove quest objective polygons that are for finished objectives
    for objectiveIndex, objectiveData in pairs(questObjectives) do
        --print(questId, objectiveIndex, objectiveData.finished)
        if(objectiveData.finished) then
            _QuestiePolygon:ForceRemoveQuestObjective(questId, objectiveIndex)
        end
    end
end

local function avgFromList(list)
	local sum = 0
	for k, v in pairs(list) do
		sum = sum + v
	end
	return sum/#list
end

local HBD = LibStub("HereBeDragonsQuestie-2.0")
---@param points table @table<index, point(.x,.y)
---@param rangeR number @Cluster Amount
---@param yield boolean @Are you running it in a coroutine and want it to yield
function QuestiePolygon:CalcHotzones(points, rangeR, yield)
    if(points == nil) then return nil; end

	--Lets just look it up once!
	local GetWorldCoordinatesFromZone = HBD.GetWorldCoordinatesFromZone
    local Euclid = QuestieLib.Euclid

    --Having different center point calculations produces different results *suprised pikachu*
    local CenterPoint = MapLib.CenterPoint
    local CenterPointPost = MapLib.AvgAbsCenterPoint

    local range = rangeR or 100;
    local hotzones = {};

    while(true) do
        local FoundUntouched = nil;
        for _, point in pairs(points) do
            if(point.touched == nil) then
                local notes = {};
                FoundUntouched = true;
				point.touched = true;
				local checkPoint = point;
				--local avgDistance = {}
                local times = 1;

                if (checkPoint.x > 1 and checkPoint.y > 1) then
                    times = 0.01
                end

                --First calculation for aX and aY, this is modified in the loop
                local aX, aY = GetWorldCoordinatesFromZone(self,
											checkPoint.x * times, checkPoint.y * times,
											checkPoint.UiMapID)

                tInsert(notes, point);
                for _, point2 in pairs(points) do
                    --We only want to cluster icons that are on the same map.
					if(point2.touched == nil and checkPoint.UiMapID == point2.UiMapID) then
                        
						local bX, bY = GetWorldCoordinatesFromZone(self,
											point2.x * times, point2.y * times,
											point2.UiMapID)
						local distance =
							Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)

						if (distance < range) then
							point2.touched = true
                            tInsert(notes, point2)
							local newCheckPoint = CenterPoint(self, notes)
							newCheckPoint.UiMapID = checkPoint.UiMapID
							checkPoint = newCheckPoint
                            
                            --Recalculate aX and aY
                            aX, aY = GetWorldCoordinatesFromZone(self,
											checkPoint.x * times, checkPoint.y * times,
											checkPoint.UiMapID)
						end
                    end
                end
                -- Here we recalculate the distance for all untouched notes due to the drift of the center.
                -- This solves most of the overlap issues

                --First calculation, is modified within the loop
                aX, aY = GetWorldCoordinatesFromZone(self,
                            checkPoint.x * times, checkPoint.y * times,
                            checkPoint.UiMapID)

                for _, opoint in pairs(points) do
                    if(opoint.touched == nil) then
                        local bX, bY = GetWorldCoordinatesFromZone(self,
                            opoint.x * times, opoint.y * times,
                            opoint.UiMapID)
                        local distance =
                            Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)
                        if (distance < range) then
                            --Touch it and add it to the saved list.
                            opoint.touched = true
                            tInsert(notes, opoint)

                            local newCheckPoint = CenterPointPost(self, notes)
                            newCheckPoint.UiMapID = checkPoint.UiMapID
                            checkPoint = newCheckPoint
                            --Recalculate due to new checkpoint
                            aX, aY = GetWorldCoordinatesFromZone(self,
                                checkPoint.x * times, checkPoint.y * times,
                                checkPoint.UiMapID)
                        end
                    end
                end

                tInsert(hotzones, notes)
            end
        end
		if (FoundUntouched == nil) then 
			for _, point in pairs(points) do
				point.touched = nil;
			end
			break 
        end
        if(yield) then
            coroutine.yield()
        end
    end
    return hotzones
end

function QuestiePolygon:PostProcessHotzone(hotzones, yield)
    if(hotzones == nil) then return nil; end

	--Lets just look it up once!
	local GetWorldCoordinatesFromZone = HBD.GetWorldCoordinatesFromZone
    local Euclid = QuestieLib.Euclid
    local CenterPoint = Blob.util.CenterPoint
    local hotzoneList = {}
    for index, hotzone in pairs(hotzones) do
        hotzoneList[hotzone] = {}
    end

    --local range = rangeR or 100;
    --local iconCount = {};
    local itt = 0;
    --local FoundUntouched = nil;
    for index, hotzone in pairs(hotzones) do
        --print("Hotzone index:", index)
        local minX = 99999999999
        local minY = 99999999999
        local maxX = 0
        local maxY = 0
        for _, point in pairs(hotzone) do
            minX = math.min(minX, point.x);
            minY = math.min(minY, point.y);
            maxX = math.max(maxX, point.x);
            maxY = math.max(maxY, point.y);
        end
        local fCenterX = minX + ((maxX - minX)/2)
        local fCenterY = minY + ((maxY - minY)/2)
        --print("   -", minX, minY, " - ", maxX, maxY)
        --print("   -Center:", fCenterX, "-", fCenterY)
        hotzoneList[hotzone].centerX = fCenterX
        hotzoneList[hotzone].centerY = fCenterY

        --local absCenter = MapLib:AbsCenterPoint(hotzone);
        --hotzoneList[hotzone].centerX = absCenter.x
        --hotzoneList[hotzone].centerY = absCenter.y
    end
    local newHotzoneList = {}
    for hotzone, hotzoneData in pairs(hotzoneList) do
        for _, point in pairs(hotzone) do
            local times = 1;
            if (point.x > 1 and point.y > 1) then
                times = 0.01
            end
            local aX, aY = GetWorldCoordinatesFromZone(self,
                point.x * times, point.y * times,
                point.UiMapID)
            local closestHotzone = hotzone;
            local closestDistance = 999999999999999
            for hotzone2, hotzoneData2 in pairs(hotzoneList) do
                local bX, bY = GetWorldCoordinatesFromZone(self,
                    hotzoneData2.centerX * times, hotzoneData2.centerY * times,
                    point.UiMapID)
                local distance =
                    Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)
                if(distance < closestDistance) then
                    closestHotzone = hotzone2
                    closestDistance = distance
                end
            end
            --Create the missing table
            if(not newHotzoneList[closestHotzone]) then newHotzoneList[closestHotzone] = {} end
            tInsert(newHotzoneList[closestHotzone], point);
        end
    end
    local hotzonesReturn = {}
    for hotzone, points in pairs(newHotzoneList) do
        tInsert(hotzonesReturn, points)
    end

    if(yield) then
        coroutine.yield()
    end
    itt = itt + 1
    return hotzonesReturn
end


local function countSpawns(qSpawns)
    local count = 0
    for _, spawns in pairs(qSpawns) do --UiMapId, spawns
        for _, _ in pairs(spawns) do
            count = count + 1
        end
    end
    return count
end

local function sortTable(tableToSort)
    local tableKeys = {}
    local orderedList = {}
    for k in pairs(tableToSort) do
        tInsert(tableKeys, k)
    end
    table.sort(tableKeys)

    -- use the keys to retrieve the values in the sorted order
    for _, key in ipairs(tableKeys) do
        tInsert(orderedList, tableToSort[key]);
    end
    return orderedList
end

function QuestiePolygon:GetSpawnData(questId, objectiveIndex)
    local objectives = QuestieDB.QueryQuestSingle(questId, "objectives")
    local spawnData = {} --Contains the spawn data for everything
    --print("Slay = 1", "Object = 2", "Item = 3")
    for objectiveType, data in pairs(objectives) do
        --print("Type:", objectiveType)
        for objIndex, objectiveData in pairs(data) do
             -- Is the objectives index the same?
            if(objIndex == objectiveIndex) then
                for index, targetId in pairs(objectiveData) do
                    -- Some objectives are {id, name} others are just {id}
                    if targetId == nil or type(targetId) == "string" then
                        targetId = index
                    end

                    if(objectiveType == 1) then --Slay
                        local npcId = targetId;
                        local qSpawns = QuestieDB.QueryNPCSingle(npcId, "spawns")
                        local qName = QuestieDB.QueryNPCSingle(npcId, "name")
                        tInsert(spawnData, {name=qName, id=npcId, spawns=qSpawns, type="monster"})
                    elseif(objectiveType == 2) then --Object?
                        local objectId = targetId;
                        local qSpawns = QuestieDB.QueryObjectSingle(objectId, "spawns")
                        local qName = QuestieDB.QueryObjectSingle(objectId, "name")
                        tInsert(spawnData, {name=qName, id=objectId, spawns=qSpawns, type="object"})
                    elseif(objectiveType == 3) then --Item
                        local spawnDataByCount = {}
                        local itemId = targetId
                        --Get all mobs and objects that drop the item
                        local npcList = QuestieDB.QueryItemSingle(itemId, "npcDrops")
                        local objectList = QuestieDB.QueryItemSingle(itemId, "objectDrops")
                        --Parse the mobs that drop the item
                        if npcList then
                            for index, npcId in pairs(npcList) do
                                -- Some objectives are {id, name} others are just {id}
                                if npcId == nil or type(npcId) == "string" then
                                    npcId = index
                                end
                                local rank = QuestieDB.QueryNPCSingle(npcId, "rank");
                                if(rank and rank ~= 4 and rank ~= 2) then --Rare and RareElite
                                    local qSpawns = QuestieDB.QueryNPCSingle(npcId, "spawns")
                                    local qName = QuestieDB.QueryNPCSingle(npcId, "name")
                                    local count = countSpawns(qSpawns)
                                    --tInsert(spawnData, {name=qName, id=npcId, spawns=qSpawns, type="monster"})
                                    spawnDataByCount[count] = {name=qName, id=npcId, spawns=qSpawns, type="monster"}
                                    
                                    --print(qName, npcId, " : ", count)
                                end
                            end
                        end
                        --Parse the objects that drop the item
                        if objectList then
                            for index, objectId in pairs(objectList) do
                                -- Some objectives are {id, name} others are just {id}
                                if objectId == nil or type(objectId) == "string" then
                                    objectId = index
                                end
                                local qSpawns = QuestieDB.QueryObjectSingle(objectId, "spawns")
                                local qName = QuestieDB.QueryObjectSingle(objectId, "name")
                                tInsert(spawnData, {name=qName, id=objectId, spawns=qSpawns, type="object"})
                            end
                        end

                        --By sorting the spawns we make the clustering code pick more common spawns before uncommon ones
                        --which will create blobs which are more informative
                        local sortedSpawns = sortTable(spawnDataByCount)
                        
                        for _, data in pairs(sortedSpawns) do
                            --print("Qid", data.id, data.name)
                            --tested good with 160 distance
                            --seems good with 180 too, more testing needed
                            tInsert(spawnData, data)
                            --tInsert(spawnData, 1, data) -- It seems to be working better not using 1
                        end
                    end
                end
            end
        end
    end
    return spawnData
end

-- Old stuff from the clustering code


                --Older stuff but don't want to remove it yet
                --print(avgFromList(avgDistance))
				--local iconCount = 0;
				--local orderedList = {}
				--local tableKeys = {}

				--for k in pairs(pointsByDistance) do
				--	tInsert(tableKeys, k)
				--end
				--table.sort(tableKeys)
				--globalKeys = tableKeys;
				---- use the keys to retrieve the values in the sorted order
				--for _, distance in ipairs(tableKeys) do
				--	iconCount = iconCount + 1;
				--	tInsert(orderedList, pointsByDistance[distance]);
				--end
				--globallist = orderedList
				--A test to try and remove overlaping polygons
				-- Kinda works but at the same time not...
				--local filteredPoints = Blob.util:PreprocessHull(notes)
				--if(#filteredPoints > 3) then
				--	local hull = Blob.util:jarvis_march(filteredPoints)
				--	if(#hull > 3) then
				--		for index, point2 in pairs(points) do
				--			local inside = Blob.util:insidePolygon(hull, point2)
				--			if(inside) then
				--				point2.touched = true
				--				tInsert(notes, point2)
				--			end
				--		end
				--	end
				--end
                -- ((#avgDistance > 0 and distance/avgFromList(avgDistance) < 5) or #avgDistance == 0)
                --if(#avgDistance > 0) then
                --    local newNotes = {}
                --    local avgDistanceNumber = avgFromList(avgDistance);
                --    local avgPercentage = avgDistanceNumber/range;
                --    print("D", avgDistanceNumber, "%", avgPercentage)
                --    for _, note in pairs(notes) do
                --        local aX, aY = GetWorldCoordinatesFromZone(self,
                --                            checkPoint.x * times, checkPoint.y * times,
                --                            checkPoint.UiMapID)
                --        local bX, bY = GetWorldCoordinatesFromZone(self,
                --                            note.x * times, note.y * times,
                --                            note.UiMapID)
                --        --if(	bX < aX+range or --Maybe something like this could improve performance?
                --        --	bX > aX-range or
                --        --	bY < aY+range or
                --        --	bY > aY-range) then
                --        local distance =
                --            Euclid(self, aX or 0, aY or 0, bX or 0, bY or 0)
                --        --print(avgFromList(avgDistance))
                --        --print(distance/avgDistance, " - ", avgDistance/distance)
                --        if(distance <= avgDistanceNumber) then
                --            tInsert(newNotes, note)
                --        else
                --            note.touched = false
                --        end
                --    end
                --    notes = newNotes
                --end

---Old stuff from Add Objective




--[[local function getRect(points)
    local minY = 99999999999
    local maxY = 0;
    local minX = 99999999999
    local maxX = 0
    for k, point in pairs(points) do
        if(point.y < minY) then
            minY = point.y
        end
        if(point.y > maxY) then
            maxY = point.y
        end
        if(point.x < minX) then
            minX = point.x
        end
        if(point.x > maxX) then
            maxX = point.x
        end
    end
    return minX, minY, maxX-minX, maxY-minY
end

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end]]--
            --local hz2 = QuestiePolygon:CalcHotzones3(allPoints, KERNEL_BAND);--335
            ----local hull = Blob.util:jarvis_march(hz2)
            ----globalhull = hull
            --globalhz = hz2
            --for uiMapId, points in pairs(hz2) do
            --    for index, hotzone in pairs(points or {}) do
            --        globalhz2 = hotzone
            --        local drawData = Blob:AddBlob(uiMapId, hotzone, r, g, b)
            --        tInsert(PolygonList[questId.."_"..objectiveIndex], drawData)
            --    end
            --end
            --local drawData = Blob:AddBlob(1429, hull, r, g, b)
            --tInsert(PolygonList[questId.."_"..objectiveIndex], drawData)
            --local new = {}
            --Test to remove overlaping polygons the problem is that it combines too much...
            --for id, drawData in pairs(PolygonList[questId.."_"..objectiveIndex]) do
            --    for id2, drawData2 in pairs(PolygonList[questId.."_"..objectiveIndex]) do
            --        if(id ~= id2 and drawData.UiMapID == drawData2.UiMapID) then
            --            local anyInside = false
            --            local newPoints2 = {}
            --            for k, point in pairs(drawData2.points) do
            --                local inside = Blob.util:insidePolygon(drawData.points, point)
            --                if(inside) then
            --                    print("FOUND INSIDE!")
            --                    --tInsert(drawData.points, point);
            --                    anyInside = true
            --                    --break;
            --                else
            --                    tInsert(newPoints2, point)
            --                end
            --            end

            --            local newPoints = {}
            --            for k, point in pairs(drawData.points) do
            --                local inside = Blob.util:insidePolygon(drawData2.points, point)
            --                if(inside) then
            --                    print("FOUND INSIDE!")
            --                    --tInsert(drawData.points, point);
            --                    anyInside = true
            --                    --break;
            --                else
            --                    tInsert(newPoints, point)
            --                end
            --            end
            --            if(anyInside) then
            --                --local allPoints = {}
            --                --for k, point in pairs(drawData.points) do
            --                --    tInsert(allPoints, point);
            --                --end
            --                --for k, point in pairs(drawData2.points) do
            --                --    tInsert(allPoints, point);
            --                --end
            --                Blob:RemoveBlob(drawData)
            --                PolygonList[questId.."_"..objectiveIndex][id] = nil;
            --                Blob:RemoveBlob(drawData2)
            --                PolygonList[questId.."_"..objectiveIndex][id2] = nil;
            --                local newDrawData = Blob:AddBlobRaw(uiMapId, newPoints, 0, 1, 0)
            --                local newDrawData2 = Blob:AddBlobRaw(uiMapId, newPoints2, 0, 0, 1)
            --                tInsert(new, newDrawData);
            --                tInsert(new, newDrawData2);
            --            else
            --                tInsert(new, drawData2);
            --            end
            --        end
            --    end
            --end
            --PolygonList[questId.."_"..objectiveIndex] = new;