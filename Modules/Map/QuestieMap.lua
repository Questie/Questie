---@class QuestieMap
local QuestieMap = QuestieLoader:CreateModule("QuestieMap");

-------------------------
--Import modules.
-------------------------
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool");
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

QuestieMap.ICON_MAP_TYPE = "MAP";
QuestieMap.ICON_MINIMAP_TYPE = "MINIMAP";

--Useful links.
-- https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/SharedXML/Pools.lua
-- https://www.townlong-yak.com/framexml/27101/Blizzard_MapCanvas/Blizzard_MapCanvas.lua
-- https://www.townlong-yak.com/framexml/27101/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua
-- https://www.townlong-yak.com/framexml/27101/Blizzard_MapCanvas/MapCanvas_PinFrameLevelsManager.lua

-- List of frames sorted by quest ID (automatic notes)
-- E.g. {[questId] = {[frameName] = frame, ...}, ...}
-- For details about frame.data see calls to QuestieMap.DrawWorldIcon
QuestieMap.questIdFrames = {}
-- List of frames sorted by NPC/object ID (manual notes)
-- id > 0: NPC
-- id < 0: object
-- E.g. {[-objectId] = {[frameName] = frame, ...}, ...}
-- For details about frame.data see QuestieMap.ShowNPC and QuestieMap.ShowObject
QuestieMap.manualFrames = {}


--Used in my fadelogic.
local fadeOverDistance = 10;
local normalizedValue = 1 / fadeOverDistance; --Opacity / Distance to fade over

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

--We should really try and squeeze out all the performance we can, especially in this.
local tostring = tostring;
local tinsert = table.insert;
local pairs = pairs;
local ipairs = ipairs;
local tremove = table.remove;
local tunpack = unpack;


QuestieMap.drawTimer = nil;
QuestieMap.fadeLogicTimerShown = nil;

--Get the frames for a quest, this returns all of the frames
function QuestieMap:GetFramesForQuest(questId)
    local frames = {}
    --If no frames exists or if the quest does not exist we just return an empty list
    if QuestieMap.questIdFrames[questId] then
        for _, name in pairs(QuestieMap.questIdFrames[questId]) do
            if _G[name] then
                frames[name] = _G[name]
            end
        end
    end
    return frames
end

function QuestieMap:UnloadQuestFrames(questId, iconType)
    if QuestieMap.questIdFrames[questId] then
        if iconType == nil then
            for _, frame in pairs(QuestieMap:GetFramesForQuest(questId)) do
                frame:Unload();
            end
            QuestieMap.questIdFrames[questId] = nil;
        else
            for name, frame in pairs(QuestieMap:GetFramesForQuest(questId)) do
                if frame and frame.data and frame.data.Icon == iconType then
                    frame:Unload();
                    QuestieMap.questIdFrames[questId][name] = nil
                    _G[name] = nil
                end
            end
        end
        Questie:Debug(DEBUG_DEVELOP, "[QuestieMap]: Unloading quest frames: %s", questId)
    end
end

--Get the frames for manual note, this returns all of the frames/spawns
---@param id number @The ID of the NPC (>0) or object (<0)
function QuestieMap:GetManualFrames(id, typ)
    typ = typ or "any"
    local frames = {}
    --If no frames exists or if the quest does not exist we just return an empty list
    if QuestieMap.manualFrames[typ] and (QuestieMap.manualFrames[typ][id]) then
        for _, name in pairs(QuestieMap.manualFrames[typ][id]) do
            tinsert(frames, _G[name])
        end
    end
    return frames
end

---@param id number @The ID of the NPC (>0) or object (<0)
function QuestieMap:UnloadManualFrames(id, typ)
    typ = typ or "any"
    if QuestieMap.manualFrames[typ] and (QuestieMap.manualFrames[typ][id]) then
        for _, frame in ipairs(QuestieMap:GetManualFrames(id, typ)) do
            frame:Unload();
        end
        QuestieMap.manualFrames[typ][id] = nil;
    end
end

function QuestieMap:ResetManualFrames(typ)
    typ = typ or "any"
    for id, _ in pairs(QuestieMap.manualFrames[typ]) do
        QuestieMap:UnloadManualFrames(id, typ)
    end
end

-- Rescale all the icons
function QuestieMap:RescaleIcons(modifier)
    for _, framelist in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(framelist) do
            QuestieMap.utils:RecaleIcon(frameName, modifier)
        end
    end
    for _, frameTypeList in pairs(QuestieMap.manualFrames) do
        for _, framelist in pairs(frameTypeList) do
            for _, frameName in ipairs(framelist) do
                QuestieMap.utils:RecaleIcon(frameName, modifier)
            end
        end
    end
end


local mapDrawQueue = {};
local minimapDrawQueue = {};

QuestieMap._mapDrawQueue = mapDrawQueue
QuestieMap._minimapDrawQueue = minimapDrawQueue

function QuestieMap:InitializeQueue() -- now called on every loading screen
    Questie:Debug(DEBUG_DEVELOP, "[QuestieMap] Starting draw queue timer!")
    local isInInstance, instanceType = IsInInstance()
    if not isInInstance or instanceType == "pvp" then -- dont run map updates while in raid
        QuestieMap._disableQueue = nil
        if not QuestieMap.drawTimer then 
            QuestieMap.drawTimer = C_Timer.NewTicker(0.2, QuestieMap.ProcessQueue)
            QuestieMap.processCounter = 0 -- used to reduce calls on edge notes
            QuestieMap.fadeLogicTimerShown = C_Timer.NewTicker(0.3, QuestieMap.ProcessShownMinimapIcons)
        end
    else
        if QuestieMap.drawTimer then -- cancel existing timer while in dungeon/raid
            QuestieMap.drawTimer:Cancel()
            QuestieMap.drawTimer = nil
            QuestieMap.fadeLogicTimerShown:Cancel()
            QuestieMap.fadeLogicTimerShown = nil
        end
        QuestieMap._disableQueue = true
    end
end


--Override OnMapChanged from MapCanvasDataProviderMixin (https://www.townlong-yak.com/framexml/27101/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua#74)
--This could in theory be skipped by instead using our own MapCanvasDataProviderMixin
--The reason i don't is becauase i want the scaling to happen AFTER HBD has processed all the icons.
HBDPins.worldmapProvider.ORG_OnMapChanged = HBDPins.worldmapProvider.OnMapChanged;
function QuestieMap:GetScaleValue()
    local mapId = HBDPins.worldmapProvider:GetMap():GetMapID();
    local scaling = 1;
    if(mapId == 947) then --Azeroth
        if(Questie.db.char.enableMinimalisticIcons) then
            scaling = 0.4
        else
            scaling = 0.85
        end
    elseif(mapId == 1414 or mapId == 1415) then -- EK and Kalimdor
        if(Questie.db.char.enableMinimalisticIcons) then
            scaling = 0.5
        else
            scaling = 0.9
        end
    end
end

function HBDPins.worldmapProvider:OnMapChanged()
    --Call original one : https://www.townlong-yak.com/framexml/27101/Blizzard_MapCanvas/MapCanvas_DataProviderBase.lua#74
    HBDPins.worldmapProvider:ORG_OnMapChanged();

    if not Questie.db then -- too early
        return
    end

    local scaling = QuestieMap:GetScaleValue()
    for pin in HBDPins.worldmapProvider:GetMap():EnumeratePinsByTemplate("HereBeDragonsPinsTemplateQuestie") do
        local frame = pin.icon;
        QuestieMap.utils:RecaleIcon(frame, scaling)
    end
end

function QuestieMap:ProcessShownMinimapIcons()
    local doEdgeUpdate = false
    QuestieMap.processCounter = QuestieMap.processCounter + 1
    if QuestieMap.processCounter > 13 then -- only update icons on the edge every 4 seconds
        QuestieMap.processCounter = 0
        doEdgeUpdate = true
    end

    local playerX, playerY, _ = HBD:GetPlayerWorldPosition()
    QuestieMap.playerX = playerX
    QuestieMap.playerY = playerY
    ---@param minimapFrame IconFrame
    for minimapFrame, data in pairs(HBDPins.activeMinimapPins) do
        if minimapFrame.miniMapIcon and ((data.distanceFromMinimapCenter < 1.1) or doEdgeUpdate) then
            if minimapFrame.FadeLogic then
                minimapFrame:FadeLogic()
            end
            if minimapFrame.GlowUpdate then
                minimapFrame:GlowUpdate()
            end
        end
    end
end

function QuestieMap:QueueDraw(drawType, ...)
    if not QuestieMap._disableQueue then -- dont queue when in raid
        if(drawType == QuestieMap.ICON_MAP_TYPE) then
            tinsert(mapDrawQueue, {...});
        elseif(drawType == QuestieMap.ICON_MINIMAP_TYPE) then
            tinsert(minimapDrawQueue, {...});
        end
    end
end


function QuestieMap:ProcessQueue()
    if next(mapDrawQueue) ~= nil or next(minimapDrawQueue) ~= nil then
        for _ = 1, math.min(24, math.max(#mapDrawQueue, #minimapDrawQueue)) do
            local mapDrawCall = tremove(mapDrawQueue, 1);
            if(mapDrawCall) then
                local frame = mapDrawCall[2];
                --print(tostring(mapDrawCall[2].data.Name).." "..tostring(mapDrawCall[2]).." "..tostring(mapDrawCall[3]).." "..tostring(mapDrawCall[4]).." "..tostring(mapDrawCall[5]).." "..tostring(mapDrawCall[6]))
                HBDPins:AddWorldMapIconMap(tunpack(mapDrawCall));
                QuestieMap.utils:SetDrawOrder(frame);
            end
            local minimapDrawCall = tremove(minimapDrawQueue, 1);
            if(minimapDrawCall) then
                local frame = minimapDrawCall[2];
                HBDPins:AddMinimapIconMap(tunpack(minimapDrawCall));

                QuestieMap.utils:SetDrawOrder(frame);
            end
            mapDrawCall[2]._loaded = true
            minimapDrawCall[2]._loaded = true
            if mapDrawCall[2]._needsUnload then
                mapDrawCall[2]:Unload()
            end
            if minimapDrawCall[2]._needsUnload then
                minimapDrawCall[2]:Unload()
            end
        end
    end
end

-- Show NPC on map
-- This function does the same for manualFrames as similar functions in
-- QuestieQuest do for questIdFrames
---@param npcID number @The ID of the NPC
function QuestieMap:ShowNPC(npcID, icon, scale, title, body, disableShiftToRemove, typ, excludeDungeon)
    if type(npcID) ~= "number" then
        Questie:Debug(DEBUG_DEVELOP, "[QuestieMap:ShowNPC]", "Got <" .. type(npcID) .. "> instead of <number>")
        return
    end
    -- get the NPC data
    local npc = QuestieDB:GetNPC(npcID)
    if npc == nil or npc.spawns == nil then return end

    -- create the icon data
    local data = {}
    data.id = npc.id
    data.Icon = icon or "Interface\\WorldMap\\WorldMapPartyIcon"

    data.GetIconScale = function() return scale or Questie.db.global.manualScale or 0.7 end
    data.IconScale = data:GetIconScale()
    data.Type = "manual"
    data.spawnType = "monster"
    data.npcData = npc
    data.Name = npc.name
    data.IsObjectiveNote = false
    data.ManualTooltipData = {}
    data.ManualTooltipData.Title = title or (npc.name.." (NPC)")
    local level = tostring(npc.minLevel)
    local health = tostring(npc.minLevelHealth)
    if npc.minLevel ~= npc.maxLevel then
        level = level..'-'..tostring(npc.maxLevel)
        health = health..'-'..tostring(npc.maxLevelHealth)
    end
    data.ManualTooltipData.Body = body or {
        {'ID:', tostring(npc.id)},
        {'Level:', level},
        {'Health:', health},
    }
    data.ManualTooltipData.disableShiftToRemove = disableShiftToRemove

    -- draw the notes
    for zone, spawns in pairs(npc.spawns) do
        if(zone ~= nil and spawns ~= nil) and ((not excludeDungeon) or (not ZoneDB:IsDungeonZone(zone))) then
            for _, coords in ipairs(spawns) do
                -- instance spawn, draw entrance on map
                local dungeonLocation = ZoneDB:GetDungeonLocation(zone)
                if dungeonLocation ~= nil then
                    for _, value in ipairs(dungeonLocation) do
                        QuestieMap:DrawManualIcon(data, value[1], value[2], value[3], typ)
                    end
                -- world spawn
                else
                    QuestieMap:DrawManualIcon(data, zone, coords[1], coords[2], typ)
                end
            end
        end
    end
end

-- Show object on map
-- This function does the same for manualFrames as similar functions in
-- QuestieQuest do for questIdFrames
---@param objectID number
function QuestieMap:ShowObject(objectID, icon, scale, title, body, disableShiftToRemove, typ)
    if type(objectID) ~= "number" then return end
    -- get the gameobject data
    local object = QuestieDB:GetObject(objectID)
    if object == nil then return end

    -- create the icon data
    local data = {}
    -- hack: clean up this code, we shouldnt be using negative indexes
    if typ then
        data.id = object.id
    else
        data.id = -object.id
    end
    data.Icon = icon or "Interface\\WorldMap\\WorldMapPartyIcon"
    data.GetIconScale = function() return scale or Questie.db.global.manualScale or 0.7 end
    data.IconScale = data:GetIconScale()
    data.Type = "manual"
    data.spawnType = "object"
    data.objectData = object
    data.Name = object.name
    data.IsObjectiveNote = false
    data.ManualTooltipData = {}
    data.ManualTooltipData.Title = title or (object.name.." (object)")
    data.ManualTooltipData.Body = body or {
        {'ID:', tostring(object.id)},
    }
    data.ManualTooltipData.disableShiftToRemove = disableShiftToRemove

    -- draw the notes
    for zone, spawns in pairs(object.spawns) do
        if(zone ~= nil and spawns ~= nil) then
            for _, coords in ipairs(spawns) do
                -- instance spawn, draw entrance on map
                local dungeonLocation = ZoneDB:GetDungeonLocation(zone)
                if dungeonLocation ~= nil then
                    for _, value in ipairs(dungeonLocation) do
                        QuestieMap:DrawManualIcon(data, value[1], value[2], value[3], typ)
                    end
                -- world spawn
                else
                    QuestieMap:DrawManualIcon(data, zone, coords[1], coords[2], typ)
                end
            end
        end
    end
end

function QuestieMap:DrawLineIcon(lineFrame, areaID, x, y)
    if type(areaID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error("Questie"..": AddWorldMapIconMap: 'AreaID', 'x' and 'y' must be numbers "..areaID.." "..x.." "..y)
    end

    --print("Drawing line in " .. ZoneDB.zoneIDToInternalName[areaID])

    local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaID)

    HBDPins:AddWorldMapIconMap(Questie, lineFrame, uiMapId, x, y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
end


-- Draw manually added NPC/object notes
-- TODO: item and custom notes
--@param data table<...> @A table created by the calling function, must contain `id`, `Name`, `GetIconScale()`, and `Type`
--@param AreaID number @The zone ID from the raw data
--@param x float @The X coordinate in 0-100 format
--@param y float @The Y coordinate in 0-100 format
function QuestieMap:DrawManualIcon(data, areaID, x, y, typ)
    if type(data) ~= "table" then
        error("Questie"..": AddWorldMapIconMap: must have some data")
    end
    if type(areaID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error("Questie"..": AddWorldMapIconMap: 'AreaID', 'x' and 'y' must be numbers "..areaID.." "..x.." "..y)
    end
    if type(data.id) ~= "number" or type(data.id) ~= "number"then
        error("Questie".."Data.id must be set to the NPC or object ID!")
    end

    -- this needs to be refactored. Fix the capitalization. Who made this id instead of Id?
    data.Id = data.id

    local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaID)
    if (not uiMapId) then
        Questie:Debug(DEBUG_CRITICAL, "No UiMapID for areaId :".. areaID .. " " .. tostring(data.Name))
        return nil, nil
    end
    -- set the icon
    local texture = data.Icon or "Interface\\WorldMap\\WorldMapPartyIcon"
    -- Save new zone ID format, used in QuestieFramePool
    -- create a list for all frames belonging to a NPC (id > 0) or an object (id < 0)
    typ = typ or "any"
    if(QuestieMap.manualFrames[typ] == nil) then
        QuestieMap.manualFrames[typ] = {}
    end
    if(QuestieMap.manualFrames[typ][data.id] == nil) then
        QuestieMap.manualFrames[typ][data.id] = {}
    end

    -- create the map icon
    local icon = QuestieFramePool:GetFrame()
    icon.data = data
    icon.x = x
    icon.y = y
    icon.AreaID = areaID -- used by QuestieFramePool
    icon.UiMapID = uiMapId
    icon.miniMapIcon = false;
    icon.texture:SetTexture(texture)
    icon:SetWidth(16 * (data:GetIconScale() or 0.7))
    icon:SetHeight(16 * (data:GetIconScale() or 0.7))

    -- add the map icon
    QuestieMap:QueueDraw(QuestieMap.ICON_MAP_TYPE, Questie, icon, icon.UiMapID, x/100, y/100, 3) -- showFlag)
    tinsert(QuestieMap.manualFrames[typ][data.id], icon:GetName())

    -- create the minimap icon
    local iconMinimap = QuestieFramePool:GetFrame()
    local colorsMinimap = {1, 1, 1}
    if data.IconColor ~= nil and Questie.db.global.questMinimapObjectiveColors then
        colorsMinimap = data.IconColor
    end
    iconMinimap:SetWidth(16 * ((data:GetIconScale() or 1) * (Questie.db.global.globalMiniMapScale or 0.7)))
    iconMinimap:SetHeight(16 * ((data:GetIconScale() or 1) * (Questie.db.global.globalMiniMapScale or 0.7)))
    iconMinimap.data = data
    iconMinimap.x = x
    iconMinimap.y = y
    iconMinimap.AreaID = areaID -- used by QuestieFramePool
    iconMinimap.UiMapID = uiMapId
    iconMinimap.texture:SetTexture(texture)
    iconMinimap.texture:SetVertexColor(colorsMinimap[1], colorsMinimap[2], colorsMinimap[3], 1);
    iconMinimap.miniMapIcon = true;

    -- add the minimap icon
    QuestieMap:QueueDraw(QuestieMap.ICON_MINIMAP_TYPE, Questie, iconMinimap, iconMinimap.UiMapID, x / 100, y / 100, true, true);
    tinsert(QuestieMap.manualFrames[typ][data.id], iconMinimap:GetName())

    -- make sure notes are only shown when they are supposed to
    if (not Questie.db.char.enabled) then -- TODO: or (not Questie.db.global.manualNotes)
        icon:FakeHide()
        iconMinimap:FakeHide()
    else
        if (not Questie.db.global.enableMapIcons) then
            icon:FakeHide()
        end
        if (not Questie.db.global.enableMiniMapIcons) then
            iconMinimap:FakeHide()
        end
    end

    QuestieMap.utils:RecaleIcon(icon, QuestieMap:GetScaleValue())

    -- return the frames in case they need to be stored seperately from QuestieMap.manualFrames
    return icon, iconMinimap;
end

--A layer to keep the area convertion away from the other parts of the code
--coordinates need to be 0-1 instead of 0-100
--showFlag isn't required but may want to be Modified
---@return IconFrame, IconFrame
function QuestieMap:DrawWorldIcon(data, areaID, x, y, showFlag)
    if type(data) ~= "table" then
        error("Questie"..": AddWorldMapIconMap: must have some data")
    end
    --if type(areaID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
    --    error("Questie"..": AddWorldMapIconMap: 'AreaID', 'x' and 'y' must be numbers "..areaID.." "..x.." "..y.." "..tostring(showFlag))
    --end
    --if type(data.Id) ~= "number" or type(data.Id) ~= "number"then
    --    error("Questie".."Data.Id must be set to the quests ID!")
    --end

    local uiMapId = ZoneDB:GetUiMapIdByAreaId(areaID)
    if (not uiMapId) then
        local parentMapId
        local mapInfo = C_Map.GetMapInfo(areaID)
        if mapInfo then
            parentMapId = mapInfo.parentMapID
        else
            parentMapId = ZoneDB:GetParentZoneId(areaID)
        end

        if (not parentMapId) then
            error("No UiMapID or fitting parentAreaId for areaId : ".. areaID .. " - ".. tostring(data.Name))
            return nil, nil
        else
            areaID = parentMapId
            uiMapId = ZoneDB:GetUiMapIdByAreaId(areaID)
        end
    end

    if (not showFlag) then
        showFlag = HBD_PINS_WORLDMAP_SHOW_WORLD
    end

    --print("UIMAPID: " .. tostring(uiMapId))
    if uiMapId == nil then
        --ZoneDB:GetUiMapIdByAreaId
        error("No UiMapID or fitting uiMapId for areaId : ".. areaID .. " - ".. tostring(data.Name))
        return nil, nil
    end

    local floatOnEdge = true

    ---@type IconFrame
    local iconMap = QuestieFramePool:GetFrame()
    iconMap.data = data
    iconMap.x = x
    iconMap.y = y
    iconMap.AreaID = areaID
    iconMap.UiMapID = uiMapId
    iconMap.miniMapIcon = false;
    iconMap:UpdateTexture(data.Icon);

    ---@type IconFrame
    local iconMinimap = QuestieFramePool:GetFrame()
    iconMinimap.data = data
    iconMinimap.x = x
    iconMinimap.y = y
    iconMinimap.AreaID = areaID
    iconMinimap.UiMapID = uiMapId
    --data.refMiniMap = iconMinimap -- used for removing
    --Are we a minimap note?
    iconMinimap.miniMapIcon = true;
    iconMinimap:UpdateTexture(data.Icon);

    local questieGlobalDB = Questie.db.global

    if (not iconMinimap.FadeLogic) then
        function iconMinimap:SetFade(value)
            if self.lastGlowFade ~= value then
                self.lastGlowFade = value
                if self.glowTexture then
                    local r, g, b = self.glowTexture:GetVertexColor()
                    self.glowTexture:SetVertexColor(r,g,b,value)
                end
                self.texture:SetVertexColor(self.texture.r, self.texture.g, self.texture.b, value)
            end
        end
        function iconMinimap:FadeLogic()
            if self.miniMapIcon and self.x and self.y and self.texture and self.UiMapID and self.texture.SetVertexColor and Questie and Questie.db and Questie.db.global and Questie.db.global.fadeLevel and HBD and HBD.GetPlayerZonePosition and QuestieLib and QuestieLib.Euclid then

                if(QuestieMap.playerX and QuestieMap.playerY) then
                    local x, y
                    if not self.worldX then
                        x, y = HBD:GetWorldCoordinatesFromZone(self.x/100, self.y/100, self.UiMapID)
                        self.worldX = x
                        self.worldY = y
                    else
                        x = self.worldX
                        y = self.worldY
                    end
                    if(x and y) then
                        --Very small value before, hard to work with.
                        local distance = QuestieLib:Euclid(QuestieMap.playerX, QuestieMap.playerY, x, y) / 10;

                        if(distance > questieGlobalDB.fadeLevel) then
                            local fade = 1 - (math.min(10, (distance - questieGlobalDB.fadeLevel)) * normalizedValue);
                            self:SetFade(fade)
                        elseif (distance < questieGlobalDB.fadeOverPlayerDistance) and questieGlobalDB.fadeOverPlayer then
                            local fadeAmount = questieGlobalDB.fadeOverPlayerLevel + distance * (1 - questieGlobalDB.fadeOverPlayerLevel) / questieGlobalDB.fadeOverPlayerDistance
                            -- local fadeAmount = math.max(fadeAmount, 0.5);
                            if self.faded and fadeAmount > questieGlobalDB.iconFadeLevel then
                                fadeAmount = questieGlobalDB.iconFadeLevel
                            end
                            self:SetFade(fadeAmount)
                        else
                            if self.faded then
                                self:SetFade(questieGlobalDB.iconFadeLevel)
                            else
                                self:SetFade(1)
                            end
                        end
                    end
                else
                    if self.faded then
                        self:SetFade(questieGlobalDB.iconFadeLevel)
                    else
                        self:SetFade(1)
                    end
                end
            end
        end
        -- We do not want to hook the OnUpdate again!
        -- iconMinimap:SetScript("OnUpdate", )
    end

    QuestieMap:QueueDraw(QuestieMap.ICON_MINIMAP_TYPE, Questie, iconMinimap, uiMapId, x / 100, y / 100, true, floatOnEdge)
    QuestieMap:QueueDraw(QuestieMap.ICON_MAP_TYPE, Questie, iconMap, uiMapId, x / 100, y / 100, showFlag)
    local r, g, b = iconMinimap.texture:GetVertexColor()
    QuestieDBMIntegration:RegisterHudQuestIcon(tostring(iconMap), data.Icon, uiMapId, x, y, r, g, b)

    if(QuestieMap.questIdFrames[data.Id] == nil) then
        QuestieMap.questIdFrames[data.Id] = {}
    end

    -- tinsert(QuestieMap.questIdFrames[data.Id], iconMap:GetName())
    -- tinsert(QuestieMap.questIdFrames[data.Id], iconMinimap:GetName())
    QuestieMap.questIdFrames[data.Id][iconMap:GetName()] = iconMap:GetName()
    QuestieMap.questIdFrames[data.Id][iconMinimap:GetName()] = iconMinimap:GetName()


    --Hide unexplored logic
    if(not QuestieMap.utils:IsExplored(iconMap.UiMapID, x, y) and Questie.db.char.hideUnexploredMapIcons) then
        iconMap:FakeHide()
        iconMinimap:FakeHide()
    end

    if iconMap:ShouldBeHidden() then
        iconMap:FakeHide()
    end

    if iconMinimap:ShouldBeHidden() then
        iconMinimap:FakeHide()
    end

    return iconMap, iconMinimap;
end

local closestStarter = {}
function QuestieMap:FindClosestStarter()
    local playerX, playerY, _ = HBD:GetPlayerWorldPosition();
    local playerZone = HBD:GetPlayerWorldPosition();
    for questId in pairs(QuestiePlayer.currentQuestlog) do
        if(not closestStarter[questId]) then
            local quest = QuestieDB:GetQuest(questId);
            if quest then
                closestStarter[questId] = {}
                closestStarter[questId].distance = 999999;
                closestStarter[questId].x = -1;
                closestStarter[questId].y = -1;
                closestStarter[questId].zone = -1;
                closestStarter[questId].type = "";
                for starterType, starters in pairs(quest.Starts) do
                        if(starterType == "GameObject") then
                            for _, ObjectID in ipairs(starters or {}) do
                                local obj = QuestieDB:GetObject(ObjectID)
                                if(obj ~= nil and obj.spawns ~= nil) then
                                    for Zone, Spawns in pairs(obj.spawns) do
                                        if(Zone ~= nil and Spawns ~= nil) then
                                            for _, coords in ipairs(Spawns) do
                                                if(coords[1] == -1 or coords[2] == -1) then -- instace locations
                                                    local dungeonLocation = ZoneDB:GetDungeonLocation(Zone)
                                                    if dungeonLocation ~= nil then
                                                        for _, value in ipairs(dungeonLocation) do
                                                            if(value[1] and value[2]) then
                                                                local x, y, _ = HBD:GetWorldCoordinatesFromZone(value[1]/100, value[2]/100, ZoneDB:GetUiMapIdByAreaId(value[3]))
                                                                if(x and y) then
                                                                    local distance = QuestieLib:Euclid(playerX or 0, playerY or 0, x, y);
                                                                    if(closestStarter[questId].distance > distance) then
                                                                        closestStarter[questId].distance = distance;
                                                                        closestStarter[questId].x = x;
                                                                        closestStarter[questId].y = y;
                                                                        closestStarter[questId].zone = ZoneDB:GetUiMapIdByAreaId(Zone);
                                                                        closestStarter[questId].type = "GameObject - " .. obj.name;
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                else
                                                    local uiMapId = ZoneDB:GetUiMapIdByAreaId(Zone)
                                                    local x, y, _ = HBD:GetWorldCoordinatesFromZone(coords[1]/100, coords[2]/100, uiMapId)
                                                    if(x and y) then
                                                        local distance = QuestieLib:Euclid(playerX or 0, playerY or 0, x, y);
                                                        if(closestStarter[questId].distance > distance) then
                                                            closestStarter[questId].distance = distance;
                                                            closestStarter[questId].x = x;
                                                            closestStarter[questId].y = y;
                                                            closestStarter[questId].zone = uiMapId
                                                            closestStarter[questId].type = "GameObject - " .. obj.name;
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        elseif(starterType == "NPC") then
                            for _, NPCID in ipairs(starters or {}) do
                                local NPC = QuestieDB:GetNPC(NPCID)
                                if (NPC ~= nil and NPC.spawns ~= nil and NPC.friendly) then
                                    for Zone, Spawns in pairs(NPC.spawns) do
                                        if(Zone ~= nil and Spawns ~= nil) then
                                            for _, coords in ipairs(Spawns) do
                                                if(coords[1] == -1 or coords[2] == -1) then
                                                    local dungeonLocation = ZoneDB:GetDungeonLocation(Zone)
                                                    if dungeonLocation ~= nil then
                                                        for _, value in ipairs(dungeonLocation) do
                                                            if(value[1] and value[2]) then
                                                                local uiMapId = ZoneDB:GetUiMapIdByAreaId(value[3])
                                                                local x, y, _ = HBD:GetWorldCoordinatesFromZone(value[1]/100, value[2]/100, uiMapId)
                                                                if(x and y) then
                                                                    local distance = QuestieLib:Euclid(playerX or 0, playerY or 0, x, y);
                                                                    if(closestStarter[questId].distance > distance) then
                                                                        closestStarter[questId].distance = distance;
                                                                        closestStarter[questId].x = x;
                                                                        closestStarter[questId].y = y;
                                                                        closestStarter[questId].zone = ZoneDB:GetUiMapIdByAreaId(Zone);
                                                                        closestStarter[questId].type = "NPC - ".. NPC.name;
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                elseif(coords[1] and coords[2]) then
                                                    local uiMapId = ZoneDB:GetUiMapIdByAreaId(Zone)
                                                    local x, y, _ = HBD:GetWorldCoordinatesFromZone(coords[1]/100, coords[2]/100, uiMapId)
                                                    if(x and y) then
                                                        local distance = QuestieLib:Euclid(playerX or 0, playerY or 0, x, y);
                                                        if(closestStarter[questId].distance > distance) then
                                                            closestStarter[questId].distance = distance;
                                                            closestStarter[questId].x = x;
                                                            closestStarter[questId].y = y;
                                                            closestStarter[questId].zone = ZoneDB:GetUiMapIdByAreaId(Zone);
                                                            closestStarter[questId].type = "NPC - ".. NPC.name;
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                if(closestStarter[questId].x == -1) then
                    closestStarter[questId].distance = 0;
                    closestStarter[questId].x = playerX;
                    closestStarter[questId].y = playerY;
                    closestStarter[questId].zone = playerZone;
                    closestStarter[questId].type = "player";
                end
            end
        end
    end
    return closestStarter;
end

function QuestieMap:GetNearestSpawn(objective)
    if objective == nil then
        return nil
    end
    local playerX, playerY, playerI = HBD:GetPlayerWorldPosition()
    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone, bestSpawnId, bestSpawnType, bestSpawnName
    if next(objective.spawnList) then
        for id, spawnData in pairs(objective.spawnList) do
            for zone, spawns in pairs(spawnData.Spawns) do
                for _,spawn in pairs(spawns) do
                    local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
                    local dX, dY, dInstance = HBD:GetWorldCoordinatesFromZone(spawn[1]/100.0, spawn[2]/100.0, uiMapId)
                    local dist = HBD:GetWorldDistance(dInstance, playerX, playerY, dX, dY)
                    if dist then
                        if dInstance ~= playerI then
                            dist = 500000 + dist * 100 -- hack
                        end
                        if dist < bestDistance then
                            bestDistance = dist
                            bestSpawn = spawn
                            bestSpawnZone = zone
                            bestSpawnId = id
                            bestSpawnType = spawnData.Type
                            bestSpawnName = spawnData.Name
                        end
                    end
                end
            end
        end
    end
    return bestSpawn, bestSpawnZone, bestSpawnName, bestSpawnId, bestSpawnType, bestDistance
end

function QuestieMap:GetNearestQuestSpawn(quest)
    if quest == nil then
        return nil
    end
    if quest:IsComplete() == 1 then
        local finisherSpawns
        local finisherName
        if quest.Finisher ~= nil then
            if quest.Finisher.Type == "monster" then
                --finisher = QuestieDB:GetNPC(quest.Finisher.Id)
                finisherSpawns, finisherName = unpack(QuestieDB.QueryNPC(quest.Finisher.Id, "spawns", "name"))
            elseif quest.Finisher.Type == "object" then
                --finisher = QuestieDB:GetObject(quest.Finisher.Id)
                finisherSpawns, finisherName = unpack(QuestieDB.QueryObject(quest.Finisher.Id, "spawns", "name"))
            end
        end
        if finisherSpawns then -- redundant code
            local bestDistance = 999999999
            local playerX, playerY, playerI = HBD:GetPlayerWorldPosition()
            local bestSpawn, bestSpawnZone, bestSpawnId, bestSpawnType, bestSpawnName
            for zone, spawns in pairs(finisherSpawns) do
                for _, spawn in pairs(spawns) do
                    local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
                    local dX, dY, dInstance = HBD:GetWorldCoordinatesFromZone(spawn[1]/100.0, spawn[2]/100.0, uiMapId)
                    local dist = HBD:GetWorldDistance(dInstance, playerX, playerY, dX, dY)
                    if dist then
                        if dInstance ~= playerI then
                            dist = 500000 + dist * 100 -- hack
                        end
                        if dist < bestDistance then
                            bestDistance = dist
                            bestSpawn = spawn
                            bestSpawnZone = zone
                            bestSpawnType = quest.Finisher.Type
                            bestSpawnName = finisherName
                        end
                    end
                end
            end
            return bestSpawn, bestSpawnZone, bestSpawnName, bestSpawnId, bestSpawnType, bestDistance
        end
        return nil
    end
    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone, bestSpawnId, bestSpawnType, bestSpawnName
    if quest.Objectives then -- to prevent error if nil
        for _, objective in pairs(quest.Objectives) do
            local spawn, zone, Name, id, Type, dist = QuestieMap:GetNearestSpawn(objective)
            if spawn and dist < bestDistance and ((not objective.Needed) or objective.Needed ~= objective.Collected) then
                bestDistance = dist
                bestSpawn = spawn
                bestSpawnZone = zone
                bestSpawnId = id
                bestSpawnType = Type
                bestSpawnName = Name
            end
        end
    end -- end of nil error prevention
    if next(quest.SpecialObjectives) then
        for _, objective in pairs(quest.SpecialObjectives) do
            local spawn, zone, Name, id, Type, dist = QuestieMap:GetNearestSpawn(objective)
            if spawn and dist < bestDistance and ((not objective.Needed) or objective.Needed ~= objective.Collected) then
                bestDistance = dist
                bestSpawn = spawn
                bestSpawnZone = zone
                bestSpawnId = id
                bestSpawnType = Type
                bestSpawnName = Name
            end
        end
    end
    return bestSpawn, bestSpawnZone, bestSpawnName, bestSpawnId, bestSpawnType, bestDistance
end

QuestieMap.zoneWaypointColorOverrides = { -- this is used when the default orange color doesn't work well in specific zones. Not needed after 769ea832ff772b10c57351eb199348393625a99b
--    [14] = {0,0.1,0.9,0.7}, -- durotar
--    [38] = {0,0.1,0.9,0.7} -- loch modan
}

QuestieMap.zoneWaypointHoverColorOverrides = {
--    [14] = {0,0.6,1,1}, -- durotar
--    [38] = {0,0.6,1,1} -- loch modan
}

function QuestieMap:DrawWaypoints(icon, waypoints, zone, x, y, color)
    --local cnt = 0 for _, a in pairs(waypoints) do for _ in pairs(a) do cnt = cnt + 1 end end
    --print("Drawing ways in " .. ZoneDB.zoneIDToInternalName[zone] .. " for " .. icon.data.Name .. " " .. tostring(cnt) .. " pts")

    if waypoints and waypoints[1] and waypoints[1][1] and waypoints[1][1][1] then -- check that waypoint data actually exists
        local lineFrames = QuestieFramePool:CreateWaypoints(icon, waypoints, nil, color or QuestieMap.zoneWaypointColorOverrides[zone], zone)
        for _, lineFrame in ipairs(lineFrames) do
            QuestieMap:DrawLineIcon(lineFrame, zone, waypoints[1][1][1], waypoints[1][1][2])
        end
    end
end
