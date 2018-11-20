QuestieMap = {...}



function QuestieMap:DrawWorldMap(QuestID)

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
  if zoneDataAreaIDToUiMapID[AreaID] == nil then
    Questie:Error("No UiMapID for ".. AreaID)
    return false
  end
  if(showFlag == nil) then showFlag = HBD_PINS_WORLDMAP_SHOW_WORLD; end

  local icon = QuestieFramePool:GetFrame()
  icon.data = data
  HBDPins:AddWorldMapIconMap(Questie, icon, zoneDataAreaIDToUiMapID[AreaID], x/100, y/100, showFlag)
  return true;


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
