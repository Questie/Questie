QuestieMap = {...}

qQuestIdFrames = {}

-- copypaste from old questie (clean up later)
QUESTIE_NOTES_CLUSTERMUL_HACK = 2; -- smaller numbers = less icons on map
local MapCache_ClutterFix = {};

function QuestieMap:DrawWorldMap(QuestID)

end

--Get the frames for a quest, this returns all of the frames
function QuestieMap:GetFramesForQuest(QuestId)
  frames = {}
  --If no frames exists or if the quest does not exist we just return an empty list
  if (qQuestIdFrames[QuestId]) then
    for i, name in ipairs(qQuestIdFrames[QuestId]) do
      table.insert(frames, _G[name])
    end
  end
  return frames
end

function QuestieMap:UnloadQuestFrames(QuestId)
  for index, frame in ipairs(QuestieMap:GetFramesForQuest(QuestId)) do
    frame.Unload(frame);
  end
  qQuestIdFrames[QuestId] = nil;
  Questie:Debug(DEBUG_DEVELOP, "[QuestieMap]: Unloading quest frames:", QuestId)
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
    Questie:Error("No UiMapID for ("..zoneDataClassic[AreaID]..") :".. AreaID)
    return nil
  end
  if(showFlag == nil) then showFlag = HBD_PINS_WORLDMAP_SHOW_WORLD; end
  if(floatOnEdge == nil) then floatOnEdge = true; end

  local icon = QuestieFramePool:GetFrame()
  icon.data = data
  data.refWorldMap = icon -- used for removing
  icon.texture:SetTexture(data.Icon)
  --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddWorldMapIconMap", icon, zoneDataAreaIDToUiMapID[AreaID], x/100, y/100, showFlag )
  

  local iconMinimap = QuestieFramePool:GetFrame()
  iconMinimap.data = data
  data.refMiniMap = iconMinimap -- used for removing
  iconMinimap.texture:SetTexture(data.Icon)
  
  -- check clustering
  local xcell = math.floor((x*QUESTIE_NOTES_CLUSTERMUL_HACK));
  local ycell = math.floor((x*QUESTIE_NOTES_CLUSTERMUL_HACK));
  
  if MapCache_ClutterFix[AreaID] == nil then MapCache_ClutterFix[AreaID] = {}; end
  if MapCache_ClutterFix[AreaID][xcell] == nil then MapCache_ClutterFix[AreaID][xcell] = {}; end
  if MapCache_ClutterFix[AreaID][xcell][ycell] == nil then MapCache_ClutterFix[AreaID][xcell][ycell] = {}; end

  
  if data.ObjectiveTargetId == nil or not MapCache_ClutterFix[AreaID][xcell][ycell][data.ObjectiveTargetId] then -- the reason why we only prevent adding to HBD is so its easy to "unhide" if we need to, and so the refs still exist
    HBDPins:AddMinimapIconMap(Questie, iconMinimap, zoneDataAreaIDToUiMapID[AreaID], x/100, y/100, true, floatOnEdge)
	HBDPins:AddWorldMapIconMap(Questie, icon, zoneDataAreaIDToUiMapID[AreaID], x/100, y/100, showFlag)
	if data.ObjectiveTargetId ~= nil then
	  MapCache_ClutterFix[AreaID][xcell][ycell][data.ObjectiveTargetId] = true
	end
  end
  if(qQuestIdFrames[data.Id] == nil) then
    qQuestIdFrames[data.Id] = {}
  end

  table.insert(qQuestIdFrames[data.Id], icon:GetName())
  table.insert(qQuestIdFrames[data.Id], iconMinimap:GetName())
  return icon;
end

--function QuestieMap:RemoveIcon(ref)
--	HBDPins:RemoveWorldMapIcon(Questie, ref)
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
