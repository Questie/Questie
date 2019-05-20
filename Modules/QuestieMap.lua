QuestieMap = {...}

qQuestIdFrames = {}

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
    --Questie:Error("No UiMapID for ("..zoneDataClassic[AreaID]..") :".. AreaID)
    return nil
  end
  if(showFlag == nil) then showFlag = HBD_PINS_WORLDMAP_SHOW_WORLD; end

  local icon = QuestieFramePool:GetFrame()
  icon.data = data
  icon.texture:SetTexture(data.Icon)
  HBDPins:AddWorldMapIconMap(Questie, icon, zoneDataAreaIDToUiMapID[AreaID], x/100, y/100, showFlag)
  if(qQuestIdFrames[data.Id] == nil) then
    qQuestIdFrames[data.Id] = {}
  end
  table.insert(qQuestIdFrames[data.Id], icon:GetName())
  return icon;
end


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
