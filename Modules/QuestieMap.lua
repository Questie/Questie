QuestieMap = {...}

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

--Temporary functions, will probably need to ge redone.
function QuestieMap:GetRetailMapIDFromZoneDB(Zoneid)
  --Need to manually fix the names above to match.
  for continentID, Zones in pairs(Map) do
    for ZoneIDRetail, NameRetail in pairs(Zones) do
      if(zoneDataClassic[Zoneid] == nil) then return nil; end
      if(NameRetail == zoneDataClassic[Zoneid]) then
        return ZoneIDRetail
      end
    end
  end
  return nil --DunMorogh
end

function GetWorldContinentFromZone(ZoneID)
  if(Map[0][ZoneID] ~= nil)then
    return 0
  elseif(Map[1][ZoneID] ~= nil)then
    return 1
  end
end
