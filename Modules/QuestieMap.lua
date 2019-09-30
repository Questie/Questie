QuestieMap = {...}
QuestieMap.ICON_MAP_TYPE = "MAP";
QuestieMap.ICON_MINIMAP_TYPE = "MINIMAP";

QuestieMap.questIdFrames = {}

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")
local HBDMigrate = LibStub("HereBeDragonsQuestie-Migrate")


-- copypaste from old questie (clean up later)
QUESTIE_NOTES_CLUSTERMUL_HACK = 1; -- smaller numbers = less icons on map
QuestieMap.MapCache_ClutterFix = {};
QuestieMap.drawTimer = nil;

function QuestieMap:DrawWorldMap(QuestID)

end

--Get the frames for a quest, this returns all of the frames
function QuestieMap:GetFramesForQuest(QuestId)
    local frames = {}
    --If no frames exists or if the quest does not exist we just return an empty list
    if (QuestieMap.questIdFrames[QuestId]) then
        for i, name in ipairs(QuestieMap.questIdFrames[QuestId]) do
            table.insert(frames, _G[name])
        end
    end
    return frames
end

function QuestieMap:UnloadQuestFrames(questId, iconType)
    if(QuestieMap.questIdFrames[questId]) then
        if(iconType == nil) then
            for index, frame in ipairs(QuestieMap:GetFramesForQuest(questId)) do
                frame:Unload();
            end
            QuestieMap.questIdFrames[questId] = nil;
        else
            for index, frame in ipairs(QuestieMap:GetFramesForQuest(questId)) do
                if(frame and frame.data and frame.data.Icon == iconType) then
                    frame:Unload();
                end
            end
        end
        Questie:Debug(DEBUG_DEVELOP, "[QuestieMap]: ".. QuestieLocale:GetUIString('DEBUG_UNLOAD_QFRAMES', questId))
    end
end

function QuestieMap:RescaleIcons()
    for qId, framelist in pairs(QuestieMap.questIdFrames) do
        for i, frameName in ipairs(framelist) do
            local frame = _G[frameName]
            if frame and frame.data then
                if(frame.data.GetIconScale) then
                    frame.data.IconScale = frame.data:GetIconScale();
                    local scale = nil
                    if(frame.miniMapIcon) then
                        scale = 16 * (frame.data.IconScale or 1) * (Questie.db.global.globalMiniMapScale or 0.7);
                    else
                        scale = 16 * (frame.data.IconScale or 1) * (Questie.db.global.globalScale or 0.7);
                    end

                    if scale > 1 then
                        frame:SetWidth(scale)
                        frame:SetHeight(scale)
                    end
                else
                    Questie:Error("A frame is lacking the GetIconScale function for resizing!", frame.data.Id);
                end
            end
        end
    end
end


local tinsert = table.insert;
local tpack = table.pack;
local tremove = table.remove;
local tunpack = unpack;
local mapDrawQueue = {};
local minimapDrawQueue = {};
function QuestieMap:InitializeQueue()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieMap] Starting draw queue timer!")
    QuestieMap.drawTimer = C_Timer.NewTicker(0.005, QuestieMap.ProcessQueue)
end

function QuestieMap:QueueDraw(drawType, ...)
  if(drawType == QuestieMap.ICON_MAP_TYPE) then
    tinsert(mapDrawQueue, {...});
  elseif(drawType == QuestieMap.ICON_MINIMAP_TYPE) then
    tinsert(minimapDrawQueue, {...});
  end
end

function QuestieMap:ProcessQueue()
  local mapDrawCall = tremove(mapDrawQueue, 1);
  if(mapDrawCall) then
    HBDPins:AddWorldMapIconMap(tunpack(mapDrawCall));
  end
  local minimapDrawCall = tremove(minimapDrawQueue, 1);
  if(minimapDrawCall) then
    HBDPins:AddMinimapIconMap(tunpack(minimapDrawCall));
  end
end
--(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)

--A layer to keep the area convertion away from the other parts of the code
--coordinates need to be 0-1 instead of 0-100
--showFlag isn't required but may want to be Modified
function QuestieMap:DrawWorldIcon(data, AreaID, x, y, showFlag)
    if type(data) ~= "table" then
        error(MAJOR..": AddWorldMapIconMap: must have some data")
    end
    if type(AreaID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        error(MAJOR..": AddWorldMapIconMap: 'AreaID', 'x' and 'y' must be numbers "..AreaID.." "..x.." "..y.." "..showFlag)
    end
    if type(data.Id) ~= "number" or type(data.Id) ~= "number"then
        error(MAJOR.."Data.Id must be set to the quests ID!")
    end
    if zoneDataAreaIDToUiMapID[AreaID] == nil then
        --Questie:Error("No UiMapID for ("..tostring(zoneDataClassic[AreaID])..") :".. AreaID .. tostring(data.Name))
        return nil, nil
    end
    if(showFlag == nil) then showFlag = HBD_PINS_WORLDMAP_SHOW_WORLD; end
    -- if(floatOnEdge == nil) then floatOnEdge = true; end
    local floatOnEdge = true

    -- check toggles (not anymore, we need to add then hide)
    --if data.Type then
    --   if (((not Questie.db.global.enableObjectives) and (data.Type == "monster" or data.Type == "object" or data.Type == "event" or data.Type == "item"))
    --     or ((not Questie.db.global.enableTurnins) and data.Type == "complete")
    --     or ((not Questie.db.global.enableAvailable) and data.Type == "available")) then
    --        return -- dont add icon
    --    end
    --end

    -- check clustering
    local xcell = math.floor((x * (QUESTIE_NOTES_CLUSTERMUL_HACK)));
    local ycell = math.floor((x * (QUESTIE_NOTES_CLUSTERMUL_HACK)));

    if QuestieMap.MapCache_ClutterFix[AreaID] == nil then QuestieMap.MapCache_ClutterFix[AreaID] = {}; end
    if QuestieMap.MapCache_ClutterFix[AreaID][xcell] == nil then QuestieMap.MapCache_ClutterFix[AreaID][xcell] = {}; end
    if QuestieMap.MapCache_ClutterFix[AreaID][xcell][ycell] == nil then QuestieMap.MapCache_ClutterFix[AreaID][xcell][ycell] = {}; end


    if (not data.ClusterId) or (not QuestieMap.MapCache_ClutterFix[AreaID][xcell][ycell][data.ClusterId]) then -- the reason why we only prevent adding to HBD is so its easy to "unhide" if we need to, and so the refs still exist
        if data.ClusterId then
            QuestieMap.MapCache_ClutterFix[AreaID][xcell][ycell][data.ClusterId] = true
        end
        --QuestieMap.MapCache_ClutterFix[AreaID][xcell][ycell][data.ObjectiveTargetId] = true
        local icon = QuestieFramePool:GetFrame()
        icon.data = data
        icon.x = x
        icon.y = y
        icon.AreaID = AreaID
        icon.miniMapIcon = false;
        if AreaID then
            data.UiMapID = zoneDataAreaIDToUiMapID[AreaID];
        end


        icon.texture:SetTexture(data.Icon) -- todo: implement .GlowIcon
        local colors = {1, 1, 1}
        if data.IconColor ~= nil and Questie.db.global.questObjectiveColors then
            colors = data.IconColor
        end
        icon.texture:SetVertexColor(colors[1], colors[2], colors[3], 1);
        -- because of how frames work, I cant seem to set the glow as being behind the note. So for now things are draw in reverse.
        if data.IconScale then
            local scale = 16 * (data:GetIconScale()*(Questie.db.global.globalScale or 0.7));
            icon:SetWidth(scale)
            icon:SetHeight(scale)
        else
            icon:SetWidth(16)
            icon:SetHeight(16)
        end

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
        iconMinimap.AreaID = AreaID
        --data.refMiniMap = iconMinimap -- used for removing
        iconMinimap.texture:SetTexture(data.Icon)
        iconMinimap.texture:SetVertexColor(colorsMinimap[1], colorsMinimap[2], colorsMinimap[3], 1);
        --Are we a minimap note?
        iconMinimap.miniMapIcon = true;

        if(not iconMinimap.FadeLogic) then
            function iconMinimap:FadeLogic()
                if self.miniMapIcon and self.x and self.y and self.texture and self.texture.SetVertexColor and Questie and Questie.db and Questie.db.global and Questie.db.global.fadeLevel and HBD and HBD.GetPlayerZonePosition and QuestieLib and QuestieLib.Euclid then
                    local playerX, playerY, playerInstanceID = HBD:GetPlayerZonePosition()
                    if(playerX and playerY) then
                        local distance = QuestieLib:Euclid(playerX, playerY, self.x / 100, self.y / 100);

                        --Very small value before, hard to work with.
                        distance = distance * 10
                        local NormalizedValue = 1 / (Questie.db.global.fadeLevel or 1.5);

                        if(distance > 0.6) then
                            local fadeAmount = (1 - NormalizedValue * distance) + 0.5
                            if self.faded and fadeAmount > Questie.db.global.iconFadeLevel then fadeAmount = Questie.db.global.iconFadeLevel end
                            local dr,dg,db = self.texture:GetVertexColor()
                            self.texture:SetVertexColor(dr, dg, db, fadeAmount)
                            if self.glowTexture and self.glowTexture.GetVertexColor then
                                local r,g,b = self.glowTexture:GetVertexColor()
                                self.glowTexture:SetVertexColor(r,g,b,fadeAmount)
                            end
                        elseif (distance < Questie.db.global.fadeOverPlayerDistance) and Questie.db.global.fadeOverPlayer then
                            local fadeAmount = QuestieLib:Remap(distance, 0, Questie.db.global.fadeOverPlayerDistance, Questie.db.global.fadeOverPlayerLevel, 1);
                           -- local fadeAmount = math.max(fadeAmount, 0.5);
                            if self.faded and fadeAmount > Questie.db.global.iconFadeLevel then fadeAmount = Questie.db.global.iconFadeLevel end
                            local dr,dg,db = self.texture:GetVertexColor()
                            self.texture:SetVertexColor(dr, dg, db, fadeAmount)
                            if self.glowTexture and self.glowTexture.GetVertexColor then
                                local r,g,b = self.glowTexture:GetVertexColor()
                                self.glowTexture:SetVertexColor(r,g,b,fadeAmount)
                            end
                        else
                            if self.faded then
                                local dr,dg,db = self.texture:GetVertexColor()
                                self.texture:SetVertexColor(dr, dg, db, Questie.db.global.iconFadeLevel)
                                if self.glowTexture and self.glowTexture.GetVertexColor then
                                    local r,g,b = self.glowTexture:GetVertexColor()
                                    self.glowTexture:SetVertexColor(r,g,b,Questie.db.global.iconFadeLevel)
                                end
                            else
                                local dr,dg,db = self.texture:GetVertexColor()
                                self.texture:SetVertexColor(dr, dg, db, 1)
                                if self.glowTexture and self.glowTexture.GetVertexColor then
                                    local r,g,b = self.glowTexture:GetVertexColor()
                                    self.glowTexture:SetVertexColor(r,g,b,1)
                                end
                            end
                        end
                    else
                        if self.faded then
                            local dr,dg,db = self.texture:GetVertexColor()
                            self.texture:SetVertexColor(dr, dg, db, Questie.db.global.iconFadeLevel)
                            if self.glowTexture and self.glowTexture.GetVertexColor then
                                local r,g,b = self.glowTexture:GetVertexColor()
                                self.glowTexture:SetVertexColor(r,g,b,Questie.db.global.iconFadeLevel)
                            end
                        else
                            local dr,dg,db = self.texture:GetVertexColor()
                            self.texture:SetVertexColor(dr, dg, db, 1)
                            if self.glowTexture and self.glowTexture.GetVertexColor then
                                local r,g,b = self.glowTexture:GetVertexColor()
                                self.glowTexture:SetVertexColor(r,g,b,1)
                            end
                        end
                    end
                end
            end
            iconMinimap.fadeLogicTimer = C_Timer.NewTicker(0.3, function()
                --Only run if these two are true!
                if (iconMinimap.FadeLogic and iconMinimap.miniMapIcon) then
                   iconMinimap:FadeLogic()
                end
                if iconMinimap.glowUpdate then
                    iconMinimap:glowUpdate()
                end
            end);
            -- We do not want to hook the OnUpdate again!
            -- iconMinimap:SetScript("OnUpdate", )
        end

        if Questie.db.global.enableMiniMapIcons then
            QuestieMap:QueueDraw(QuestieMap.ICON_MINIMAP_TYPE, Questie, iconMinimap, zoneDataAreaIDToUiMapID[AreaID], x / 100, y / 100, true, floatOnEdge);
            --HBDPins:AddMinimapIconMap(Questie, iconMinimap, zoneDataAreaIDToUiMapID[AreaID], x / 100, y / 100, true, floatOnEdge)
        end
        if Questie.db.global.enableMapIcons then
            QuestieMap:QueueDraw(QuestieMap.ICON_MAP_TYPE, Questie, icon, zoneDataAreaIDToUiMapID[AreaID], x / 100, y / 100, showFlag);
            --HBDPins:AddWorldMapIconMap(Questie, icon, zoneDataAreaIDToUiMapID[AreaID], x / 100, y / 100, showFlag)
        end
        if(QuestieMap.questIdFrames[data.Id] == nil) then
            QuestieMap.questIdFrames[data.Id] = {}
        end

        table.insert(QuestieMap.questIdFrames[data.Id], icon:GetName())
        table.insert(QuestieMap.questIdFrames[data.Id], iconMinimap:GetName())

        -- preset hidden state when needed (logic from QuestieQuest:UpdateHiddenNotes
        -- we should add all this code to something like obj:CheckHide() instead of copying it
        if (QuestieQuest.NotesHidden or (((not Questie.db.global.enableObjectives) and (icon.data.Type == "monster" or icon.data.Type == "object" or icon.data.Type == "event" or icon.data.Type == "item"))
                 or ((not Questie.db.global.enableTurnins) and icon.data.Type == "complete")
                 or ((not Questie.db.global.enableAvailable) and icon.data.Type == "available"))
                 or ((not Questie.db.global.enableMapIcons) and (not icon.miniMapIcon))
                 or ((not Questie.db.global.enableMiniMapIcons) and (icon.miniMapIcon))) or (icon.data.ObjectiveData and icon.data.ObjectiveData.HideIcons) or (icon.data.QuestData and icon.data.QuestData.HideIcons and icon.data.Type ~= "complete") then
            icon:FakeHide()
            iconMinimap:FakeHide()
        end

        return icon, iconMinimap;
    end
    return nil, nil
end

--function QuestieMap:RemoveIcon(ref)
--    HBDPins:RemoveWorldMapIcon(Questie, ref)
--end


--DOES NOT WORK
--Temporary functions, will probably need to ge redone.
function QuestieMap:GetZoneDBMapIDFromRetail(Zoneid)
    --Need to manually fix the names above to match.
    for continentID, Zone in pairs(Map) do
        for ZoneIDClassic, NameClassic in pairs(zoneDataClassic) do
            if(Zone[Zoneid] == NameClassic) then
                return ZoneIDClassic
            end
        end
    end
    return nil --DunMorogh
end

--DOES NOT WORK
function QuestieMap:GetRetailMapIDFromZoneDB(Zoneid)
    --Need to manually fix the names above to match.
    for continentID, Zones in pairs(Map) do
        for ZoneIDRetail, NameRetail in pairs(Zones) do
            if(zoneDataClassic[Zoneid] == nil) then return nil; end
            if(NameRetail == zoneDataClassic[Zoneid]) then
                return continentID, ZoneIDRetail
            end
        end
    end
    return nil --DunMorogh
end

--DOES NOT WORK
function GetWorldContinentFromZone(ZoneID)
    if(Map[0][ZoneID] ~= nil)then
        return 0
    elseif(Map[1][ZoneID] ~= nil)then
        return 1
    end
end
